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

module conf_voter 
#(
	// Number of signals
	parameter int N_S = 3,
	/* Number of bit of each signal, {8,32,16} means tre signal, 
	the first with 8 bits, the second with 32 bits and the last with 16 bits */
	parameter int S_BIT [N_S-1:0] = {8,32,16}, 
	/* Voter setting for each signal, 0 means no voting, 1 means TMR with one voter
	2 means TMR with three voter and so 3 output. Whe you set 0 to a signal, you should
	give the signal input in each input anyway but only the first will be given as output,
	for example if TMR is not to be applied to S1: 
		S1 -> in_1_i -> voted_o
		S1 -> in_2_i
		S1 -> in_3_i
	*/
	parameter int S_VOTE_SET [N_S-1:0] = {1,1,2},
	/* Total Number of Bit of Signals , e.g the sum of dimension of all input signal */
	parameter int TNBS = 56, // 8 +32 + 16 = SUM(i=0;i=3){S_BIT[i]}
	/* Total Number of Bit of Voted Output , e.g. depends on S_VOT_SET */	
	parameter int TNBVO = 88, // 8 + 32 + 16*3 = SUM(i=0;i=3){S_BIT[i]+S_BIT[i]*(2*(S_VOTE_SET[i]/2))}
	/* Total Number of Bit of Error Output , e.g. depends on S_VOT_SET  */		
	parameter int TNBEO = 5 // 1 + 1 + 1*3 = SUM(i=0;i=3){1 + 2*(S_VOTE_SET[i]/2)}
)
(
	input logic  [TNBS-1:0] in_1_i ,
	input logic [TNBS-1:0] in_2_i,
	input logic [TNBS-1:0] in_3_i,
  	output logic [TNBVO-1:0] voted_o,
	// gli errori ci sono per S_VOTE_SET = 1 o 2 !
  	output logic [TNBEO-1:0] err_detected_1_o,
  	output logic [TNBEO-1:0] err_detected_2_o,
  	output logic [TNBEO-1:0] err_detected_3_o,
  	output logic [TNBEO-1:0] err_corrected_o,
  	output logic [TNBEO-1:0] err_detected_o
);
		
        genvar i,j;	

	$info("TNBS:%d  TNBVO:%d  TNBEO:%d",TNBS,TNBVO,TNBEO);

	function int bit_sum_f;
		input int istop;
		int i;
		int sum;
		begin
			sum=0;
			for(i=0;i<istop; i=i+1) begin
				sum = sum + S_BIT[i];
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
				if(S_VOTE_SET[i]==2) begin
					sum = sum + S_BIT[i]*3;
				end else begin
					sum = sum + S_BIT[i];
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
				if(S_VOTE_SET[i]==2) begin
					sum = sum + 3;
				end
		       		if(S_VOTE_SET[i]==1) begin
					sum = sum + 1;
				end					
			end
			bit_err_sum_f=sum;
		end
	endfunction

	generate	
		for (i = 0; i< N_S; i=i+1) begin

			// NO TMR --> We use the voter only if S_VOTE_SET[i] is 1 or 2 
			case (S_VOTE_SET[i])
				0: begin
					localparam int bit_sum = bit_sum_f(i); 
					localparam int bit_o_sum = bit_o_sum_f(i); 
					$info("NO TMR: voted_o [ %d: %d ]", bit_o_sum+S_BIT[i]-1, bit_o_sum);
					// bit selection for input variables
					localparam int i_up = S_BIT[i] + bit_sum - 1;
					localparam int i_down = bit_sum;
					// bit selection for voted variable
					localparam int o_up = S_BIT[i] + bit_o_sum - 1;
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
					localparam int i_up = S_BIT[i] + bit_sum - 1;
					localparam int i_down = bit_sum;
					// bit selection for voted variable
					localparam int o_up = S_BIT[i] + bit_o_sum - 1;
					localparam int o_down = bit_o_sum;
					// bit selection for error variables
					localparam int err_up = bit_err_sum;
					localparam int err_down = bit_err_sum;
					$info("TMR: in:[%d:%d], out:[%d:%d], err:[%d:%d]",i_up,i_down,o_up,o_down,err_up, err_down);

					voter3 #(S_BIT[i],1) v0
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
						localparam int i_up = S_BIT[i]*(j+1) + bit_sum - 1;
						localparam int i_down = bit_sum + S_BIT[i]*j;
						// bit selection for voted variable
						localparam int o_up = S_BIT[i]*(j+1) + bit_o_sum - 1;
						localparam int o_down = bit_o_sum + S_BIT[i]*j;
						// bit selection for error variables
						localparam int err_up = bit_err_sum+j;
						localparam int err_down = bit_err_sum+j;
						$info("[%d] TMR Triplicated: in:[%d:%d], out:[%d:%d], err:[%d:%d]",j,i_up,i_down,o_up,o_down,err_up, err_down);

						voter3 #(S_BIT[i],1) v0
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
