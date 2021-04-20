// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Elia Ribaldone  - ribaldoneelia@gmail.com                  //
//                                                                            //
// Additional contributions by:                                               //
//                  Marcello Neri - s257090@studenti.polito.it                //
//                   Luca Fiore - luca.fiore@studenti.polito.it               //
// Design Name:    Compressed instruction decoder fault tolerant              //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Decodes RISC-V compressed instructions into their RV32     //
//                 equivalent. This module is fully combinatorial.            //
//                 Float extensions added                                     //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import ft_pkg::*;


module cv32e40p_aligner_ft
(	
	// Clock and reset
	input  logic clk,
	input  logic rst_n,

	// aligner input/ouput triplicated 
	input  logic [2:0]       fetch_valid_i,
	output logic [2:0]       aligner_ready_o,  //prevents overwriting the fethced instruction

	input  logic [2:0]       if_valid_i,

	input  logic [2:0][31:0] fetch_rdata_i,
	output logic [2:0][31:0] instr_aligned_o,
	output logic [2:0]       instr_valid_o,

	input  logic [2:0][31:0] branch_addr_i,
	input  logic [2:0]       branch_i,         // Asserted if we are branching/jumping now

	input  logic [2:0][31:0] hwlp_addr_i,
	input  logic [2:0]       hwlp_update_pc_i,

	output logic [2:0][31:0] pc_o,

	// Fault Tolerant State
	input logic [2:0] set_broken_i,
	output logic [2:0] is_broken_o,
	output logic err_detected_o,
	output logic err_corrected_o

);
	
	// Signals out to each compressed decoder block to be voted
        logic [2:0] aligner_ready_o_to_vote ;
        logic [2:0][31:0] instr_aligned_o_to_vote ;
        logic [2:0] instr_valid_o_to_vote ;
        logic [2:0][31:0] pc_o_to_vote ;
        // Error signals
        logic [2:0] aligner_ready_o_block_err ;
        logic [2:0] instr_aligned_o_block_err ;
        logic [2:0] instr_valid_o_block_err ;
        logic [2:0] pc_o_block_err ;
        // Signals that use error signal to find if there is one error on
        // each block, it is the or of previous signals
        logic [2:0] block_err_detected;
        logic [3:0] err_detected;
        logic [3:0] err_corrected;



	// generate case on ALIG_FT variable, if is is zero
	// will be instantiated only one aligner, otherwise will
	// be used configurable TMR
	generate 
		case (ALIG_FT) 
			0: begin // In this case TMR is not required and cv32e40p_aligner_ft became as
				// cv32e40p_aligner
				cv32e40p_aligner aligner (
					.clk(clk),
					.rst_n(rst_n),
					// input 
					.fetch_valid_i(fetch_valid_i[0]),
					.if_valid_i(if_valid_i[0]),
					.fetch_rdata_i(fetch_rdata_i[0]),
					.branch_addr_i(branch_addr_i[0]),
					.branch_i(branch_i[0]),
					.hwlp_addr_i(hwlp_addr_i[0]),
					.hwlp_update_pc_i(hwlp_update_pc_i[0]),
					// output 
					.aligner_ready_o(aligner_ready_o[0]),
					.instr_aligned_o(instr_aligned_o[0]),
					.instr_valid_o(instr_valid_o[0]),
					.pc_o(pc_o[0])
				);
			end
			default: begin // In this case we should implement TMR
				// Case for triplicated input 
				case (ALIG_TIN)
					0: begin // Single input on 0 element of each input arrayt
						genvar i;
						for(i=0;i<3;i=i+1) begin : single_input_aligner
							cv32e40p_aligner aligner (
								.clk(clk),
								.rst_n(rst_n),
								// input isn't
								// triplicated and so connected
								// to the first output 
								.fetch_valid_i(fetch_valid_i[0]),
								.if_valid_i(if_valid_i[0]),
								.fetch_rdata_i(fetch_rdata_i[0]),
								.branch_addr_i(branch_addr_i[0]),
								.branch_i(branch_i[0]),
								.hwlp_addr_i(hwlp_addr_i[0]),
								.hwlp_update_pc_i(hwlp_update_pc_i[0]),
								// output -> only the output is triplicated
								// since it should pass into voter
								.aligner_ready_o(aligner_ready_o_to_vote[i]),
								.instr_aligned_o(instr_aligned_o_to_vote[i]),
								.instr_valid_o(instr_valid_o_to_vote[i]),
								.pc_o(pc_o_to_vote[i])
							);
						end
					end
					default: begin
					        genvar i;
						for(i=0;i<3;i=i+1) begin : triplicated_input_aligner
							cv32e40p_aligner aligner (
								.clk(clk),
								.rst_n(rst_n),
								// input -> in this case olso input
								// is triplicated
								.fetch_valid_i(fetch_valid_i[i]),
								.if_valid_i(if_valid_i[i]),
								.fetch_rdata_i(fetch_rdata_i[i]),
								.branch_addr_i(branch_addr_i[i]),
								.branch_i(branch_i[i]),
								.hwlp_addr_i(hwlp_addr_i[i]),
								.hwlp_update_pc_i(hwlp_update_pc_i[i]),
								// output -> the output is triplicated
								// since it should pass into voter
								.aligner_ready_o(aligner_ready_o_to_vote[i]),
								.instr_aligned_o(instr_aligned_o_to_vote[i]),
								.instr_valid_o(instr_valid_o_to_vote[i]),
								.pc_o(pc_o_to_vote[i])
							);
						end	
					end
				endcase
				// Voter for TOVOTE signal, triple voter if
                                // ALIG_TOUT[0] == 1
                                cv32e40p_conf_voter
                                #(
                                	.L1(1),
                                	.TOUT(ALIG_TOUT[0])
                                ) voter_0_aligner_ready_o
                                (
                                	.to_vote_i( aligner_ready_o_to_vote ),
                                	.voted_o( aligner_ready_o),
                                	.block_err_o( aligner_ready_o_block_err),
                                	.broken_block_i(is_broken_o),
                                	.err_detected_o(err_detected[0]),
                                	.err_corrected_o(err_corrected[0])
                                );


                                // Voter for TOVOTE signal, triple voter if
                                // ALIG_TOUT[1] == 1
                                cv32e40p_conf_voter
                                #(
                                	.L1(32),
                                	.TOUT(ALIG_TOUT[1])
                                ) voter_1_instr_aligned_o
                                (
                                	.to_vote_i( instr_aligned_o_to_vote ),
                                	.voted_o( instr_aligned_o),
                                	.block_err_o( instr_aligned_o_block_err),
                                	.broken_block_i(is_broken_o),
                                	.err_detected_o(err_detected[1]),
                                	.err_corrected_o(err_corrected[1])
                                );


                                // Voter for TOVOTE signal, triple voter if
                                // ALIG_TOUT[2] == 1
                                cv32e40p_conf_voter
                                #(
                                	.L1(1),
                                	.TOUT(ALIG_TOUT[2])
                                ) voter_2_instr_valid_o
                                (
                                	.to_vote_i( instr_valid_o_to_vote ),
                                	.voted_o( instr_valid_o),
                                	.block_err_o( instr_valid_o_block_err),
                                	.broken_block_i(is_broken_o),
                                	.err_detected_o(err_detected[2]),
                                	.err_corrected_o(err_corrected[2])
                                );


                                // Voter for TOVOTE signal, triple voter if
                                // ALIG_TOUT[3] == 1
                                cv32e40p_conf_voter
                                #(
                                	.L1(32),
                                	.TOUT(ALIG_TOUT[3])
                                ) voter_3_pc_o
                                (
                                	.to_vote_i( pc_o_to_vote ),
                                	.voted_o( pc_o),
                                	.block_err_o( pc_o_block_err),
                                	.broken_block_i(is_broken_o),
                                	.err_detected_o(err_detected[3]),
                                	.err_corrected_o(err_corrected[3])
                                );

				assign err_detected_o = |err_detected;
				assign err_corrected_o = |err_corrected;
				
				assign block_err_detected[0] =    aligner_ready_o_block_err[0]
                                                                | instr_aligned_o_block_err[0]
                                                                | instr_valid_o_block_err[0]
                                                                | pc_o_block_err[0];
                                assign block_err_detected[1] =    aligner_ready_o_block_err[1]
                                                                | instr_aligned_o_block_err[1]
                                                                | instr_valid_o_block_err[1]
                                                                | pc_o_block_err[1];
                                assign block_err_detected[2] =    aligner_ready_o_block_err[2]
                                                                | instr_aligned_o_block_err[2]
                                                                | instr_valid_o_block_err[2]
                                                                | pc_o_block_err[2];

				
				genvar m;
                                for (m=0;  m<3 ; m=m+1) begin
                                        // This block is a counter that is incremented each
                                        // time there is an error and decremented when it
                                        // there is not. The value returned is is_broken_o
                                        // , if it is one the block is broken and should't be
                                        // used
                                        cv32e40p_breakage_monitor
                                        #(
                                                .DECREMENT(ALIG_DECREMENT),
                                                .INCREMENT(ALIG_INCREMENT),
                                                .BREAKING_THRESHOLD(ALIG_BREAKING_THRESHOLD),
                                                .COUNT_BIT(ALIG_COUNT_BIT),
                                                .INC_DEC_BIT(ALIG_INC_DEC_BIT)
                                        ) breakage_monitor
                                        (
                                                .rst_n(rst_n),
                                                .clk(clk),
                                                .err_detected_i(block_err_detected[m]),
                                                .set_broken_i(set_broken_i[m]),
                                                .is_broken_o(is_broken_o[m])
                                        );
                                        // We find is the block have an error.
                                end


			end			
		endcase
	endgenerate

endmodule
