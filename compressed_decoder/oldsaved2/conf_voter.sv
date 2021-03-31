// Copyright 2020 Politecnico di Torino.


////////////////////////////////////////////////////////////////////////////////
// Engineer:       Elia Ribaldone - s265613@studenti.polito.it                //
//                                                                            //
// Design Name:    conf_voter                                                 //
// Project Name:   cv32e40p Fault tolernat                                    //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Configurable voter                                         //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import config_pkg::*;
module conf_voter
#(
	// Number of signals
	parameter int CONF = 0
)
(
	input logic  [CONFIG_MAT[CONF].TNBVI-1:0] in_1_i ,
	input logic [CONFIG_MAT[CONF].TNBVI-1:0] in_2_i,
	input logic [CONFIG_MAT[CONF].TNBVI-1:0] in_3_i,
  	output logic [CONFIG_MAT[CONF].TNBVO-1:0] voted_o,
	// gli errori ci sono per S_VOTE_SET = 1 o 2 !
  	output logic [CONFIG_MAT[CONF].TNBEO-1:0] err_detected_1_o,
  	output logic [CONFIG_MAT[CONF].TNBEO-1:0] err_detected_2_o,
  	output logic [CONFIG_MAT[CONF].TNBEO-1:0] err_detected_3_o,
  	output logic [CONFIG_MAT[CONF].TNBEO-1:0] err_corrected_o,
  	output logic [CONFIG_MAT[CONF].TNBEO-1:0] err_detected_o
);
		
        genvar i,j;	

	$info("TNBVI:%d  TNBVO:%d  TNBEO:%d",CONFIG_MAT[CONF].TNBVI,CONFIG_MAT[CONF].TNBVO,CONFIG_MAT[CONF].TNBEO);

	function int bit_sum_f;
		input int istop;
		int i;
		int sum;
		begin
			sum=0;
			for(i=0;i<istop; i=i+1) begin
				sum = sum + CONFIG_MAT[CONF].BIT_I[i];
			end
			bit_sum_f=sum;
		end
	endfunction
	function int bit_o_sum_f;
		input int istop;
		int i;
		int sum;
		begin
			sum=0;
			for(i=0;i<istop; i=i+1) begin
				if(CONFIG_MAT[CONF].VOTE_SET[i]==2) begin
					sum = sum + CONFIG_MAT[CONF].BIT_I[i]*3;
				end else begin
					sum = sum + CONFIG_MAT[CONF].BIT_I[i];
				end					
			end
			bit_o_sum_f=sum;
		end
	endfunction
	function int bit_err_sum_f;
		input int istop;
		int i;
		int sum;
		begin
			sum=0;
			for(i=0;i<istop; i=i+1) begin
				if(CONFIG_MAT[CONF].VOTE_SET[i]==2) begin
					sum = sum + 3;
				end
		       		if(CONFIG_MAT[CONF].VOTE_SET[i]==1) begin
					sum = sum + 1;
				end					
			end
			bit_err_sum_f=sum;
		end
	endfunction

	generate	
		for (i = 0; i< CONFIG_MAT[CONF].N_O; i=i+1) begin

			// NO TMR --> We use the voter only if S_VOTE_SET[i] is 1 or 2 
			case (CONFIG_MAT[CONF].VOTE_SET[i])
				0: begin
					localparam int bit_sum = bit_sum_f(i); 
					localparam int bit_o_sum = bit_o_sum_f(i); 
					$info("NO TMR: voted_o [ %d: %d ]", bit_o_sum+S_BIT[i]-1, bit_o_sum);
					// bit selection for input variables
					localparam int i_up = CONFIG_MAT[CONF].BIT_O[i] + bit_sum - 1;
					localparam int i_down = bit_sum;
					// bit selection for voted variable
					localparam int o_up = CONFIG_MAT[CONF].BIT_O[i] + bit_o_sum - 1;
					localparam int o_down = bit_o_sum;
					// We simply connect the first input to the
					// voted output
					assign voted_o [o_up : o_down] = in_1_i[i_up:i_down];	
				end
				
				// TMR -> In this case we implement TMR with only one
				// output, so we use only a voter
				1: begin
					localparam int bit_sum = bit_sum_f(i); 
					localparam int bit_o_sum = bit_o_sum_f(i); 
					localparam int bit_err_sum = bit_err_sum_f(i);
					// bit selection for input variables
					localparam int i_up = CONFIG_MAT[CONF].BIT_O[i] + bit_sum - 1;
					localparam int i_down = bit_sum;
					// bit selection for voted variable
					localparam int o_up = CONFIG_MAT[CONF].BIT_O[i] + bit_o_sum - 1;
					localparam int o_down = bit_o_sum;
					// bit selection for error variables
					localparam int err_up = bit_err_sum;
					localparam int err_down = bit_err_sum;
					$info("TMR: in:[%d:%d], out:[%d:%d], err:[%d:%d]",i_up,i_down,o_up,o_down,err_up, err_down);

					voter3 #(CONFIG_MAT[CONF].BIT_O[i],1) v0
					(
						.in_1_i( in_1_i [ i_up : i_down ] ),
						.in_2_i( in_2_i [ i_up : i_down ] ),
						.in_3_i( in_3_i [ i_up : i_down ] ),
						.only_two_i('0),
						.voted_o( voted_o [ o_up : o_down ] ),
						.err_detected_1_o( err_detected_1_o [ err_up : err_down ] ),
						.err_detected_2_o( err_detected_2_o [ err_up : err_down ] ),
						.err_detected_3_o( err_detected_3_o [ err_up : err_down ] ),
						.err_corrected_o( err_corrected_o [ err_up : err_down ] ),
						.err_detected_o( err_detected_o [ err_up : err_down ] )
					);
				end

				// voted three time in three voters, the three ouput
				// are connected to voted_o
				2: begin
					for ( j=0 ; j<3; j=j+1) begin
						localparam int bit_sum = bit_sum_f(i); 
						localparam int bit_o_sum = bit_o_sum_f(i); 
						localparam int bit_err_sum = bit_err_sum_f(i);
						// bit selection for input variables
						localparam int i_up = CONFIG_MAT[CONF].BIT_O[i]*(j+1) + bit_sum - 1;
						localparam int i_down = bit_sum + CONFIG_MAT[CONF].BIT_O[i]*j;
						// bit selection for voted variable
						localparam int o_up = CONFIG_MAT[CONF].BIT_O[i]*(j+1) + bit_o_sum - 1;
						localparam int o_down = bit_o_sum +CONFIG_MAT[CONF].BIT_O[i]*j;
						// bit selection for error variables
						localparam int err_up = bit_err_sum+j;
						localparam int err_down = bit_err_sum+j;
						$info("[%d] TMR Triplicated: in:[%d:%d], out:[%d:%d], err:[%d:%d]",j,i_up,i_down,o_up,o_down,err_up, err_down);

						voter3 #(CONFIG_MAT[CONF].BIT_O[i],1) v0
						(
							.in_1_i( in_1_i [ i_up : i_down ] ),
							.in_2_i( in_2_i [ i_up : i_down ] ),
							.in_3_i( in_3_i [ i_up : i_down ] ),
							.only_two_i('0),
							.voted_o( voted_o [ o_up : o_down ] ),
							.err_detected_1_o( err_detected_1_o [ err_up : err_down ] ),
							.err_detected_2_o( err_detected_2_o [ err_up : err_down ] ),
							.err_detected_3_o( err_detected_3_o [ err_up : err_down ] ),
							.err_corrected_o( err_corrected_o [ err_up : err_down ] ),
							.err_detected_o( err_detected_o [ err_up : err_down ] )
						);
					end
				end
				default: $error("Fail: S_VOTE_SET variable can be only 0, 1 or 2 !!");
			endcase
		end	
	endgenerate
endmodule
