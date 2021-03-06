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

import cv32e40p_ft_pkg::*;

module cv32e40p_compressed_decoder_ft
#(
	parameter int FPU = 0
)
(
	// clock and reset
	input logic clk,
	input logic rst_n,

	// compressed decoder input output  
	input  logic [2:0][31:0] instr_i,
	output logic [2:0][31:0] instr_o,
	output logic [2:0]      is_compressed_o,
	output logic [2:0]      illegal_instr_o,

	// fault tolerant state
	input logic [2:0] set_broken_i,
	output logic [2:0] is_broken_o,
	output logic err_detected_o,
	output logic err_corrected_o
);

	// Signals out to each compressed decoder block to be voted
 	logic [2:0][31:0] instr_o_to_vote;	
	logic [2:0] is_compressed_o_to_vote;
	logic [2:0] illegal_instr_o_to_vote;
	
	// Error signals
	logic [2:0] instr_o_block_err ;
	logic [2:0] is_compressed_o_block_err ;
	logic [2:0] illegal_instr_o_block_err ;
	
	// Signals that use error signal to find if there is one error on
	// each block, it is the or of previous signals
	logic [2:0] block_err_detected;
	logic [2:0] err_detected;
	logic [2:0] err_corrected;

	// variable for generate cycle
	generate
		case (CDEC_FT)
			0 : begin
				cv32e40p_compressed_decoder #(FPU) compressed_decoder
					(
						.instr_i(instr_i[0]),
						.instr_o(instr_o[0]),
						.is_compressed_o(is_compressed_o[0]),
						.illegal_instr_o(illegal_instr_o[0])
					);
				// Since we don't use FT can't be detected an
				// error
				assign block_err_detected = {1'b0,1'b0,1'b0};
			end
			default : begin
				// Input case 
				case (CDEC_TIN) 
					0 : begin // Single input
						genvar i;
						for (i=0; i<3; i=i+1)  begin : compressed_decoder
							cv32e40p_compressed_decoder #(FPU) compressed_decoder
							(
								.instr_i(instr_i[0]),
								.instr_o(instr_o_to_vote[i]),
								.is_compressed_o(is_compressed_o_to_vote[i]),
								.illegal_instr_o(illegal_instr_o_to_vote[i])
							);
						end						
					end
					default : begin // Triplicated input
						genvar i;
						for (i=0; i<3; i=i+1)  begin : compressed_decoder_3
							cv32e40p_compressed_decoder #(FPU) compressed_decoder
							(
								.instr_i(instr_i[i]),
								.instr_o(instr_o_to_vote[i]),
								.is_compressed_o(is_compressed_o_to_vote[i]),
								.illegal_instr_o(illegal_instr_o_to_vote[i])
							);
						end	
					end
				endcase	

				// Output case for instr_o 
				cv32e40p_conf_voter 
				#(	
					.L1(32),
					.TOUT(CDEC_TOUT[0])
				) v_instr_o
				(
					.to_vote_i( instr_o_to_vote ),
					.voted_o( instr_o),
					.block_err_o( instr_o_block_err),
					.broken_block_i(is_broken_o),
					.err_detected_o(err_detected[0]),
					.err_corrected_o(err_corrected[0])
				);
				
				// Output case for is_compressed_o 
				cv32e40p_conf_voter 
				#(	
					.L1(1),
					.TOUT(CDEC_TOUT[1])
				) v_is_compressed_o
				(
					.to_vote_i( is_compressed_o_to_vote ),
					.voted_o( is_compressed_o),
					.block_err_o( is_compressed_o_block_err),
					.broken_block_i(is_broken_o),
					.err_detected_o(err_detected[1]),
					.err_corrected_o(err_corrected[1])
				);

				// Output case for illega_instr_o
				cv32e40p_conf_voter 
				#(	
					.L1(1),
					.TOUT(CDEC_TOUT[2])
				) v_illegal_instr_o
				(
					.to_vote_i( illegal_instr_o_to_vote ),
					.voted_o( illegal_instr_o),
					.block_err_o( illegal_instr_o_block_err),
					.broken_block_i(is_broken_o),
					.err_detected_o(err_detected[2]),
					.err_corrected_o(err_corrected[2])
				);
				
				
				assign err_detected_o = err_detected[0] | err_detected[1] | err_detected[2];
				assign err_corrected_o = err_corrected[0] | err_corrected[1] | err_corrected[2];	
					
				genvar m;
				for (m=0;  m<3 ; m=m+1) begin 
					assign block_err_detected[m] =   instr_o_block_err[m] 
									| illegal_instr_o_block_err[m] 
									| is_compressed_o_block_err[m];
					// This block is a counter that is incremented each
					// time there is an error and decremented when it
					// there is not. The value returned is is_broken_o
					// , if it is one the block is broken and should't be
					// used
					cv32e40p_breakage_monitor
					#(
						.DECREMENT(CDEC_DECREMENT),
						.INCREMENT(CDEC_INCREMENT),
						.BREAKING_THRESHOLD(CDEC_BREAKING_THRESHOLD),
						.COUNT_BIT(CDEC_COUNT_BIT),
						.INC_DEC_BIT(CDEC_INC_DEC_BIT)
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
