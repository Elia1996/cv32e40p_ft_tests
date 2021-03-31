module adder_ft
  #(
	parameter int IN_N = 3,
	parameter int OUT_N = 2,
  	parameter int BIT_IN [IN_N-1:0] = {8,8,1},
  	parameter int BIT_OUT [OUT_N-1:0] = {8,1},
	// Output signal settings 1 o 3
	parameter int S_VOTE_SET [OUT_N-1:0] = {1,1} 
  )
  (
    input logic [2:0][BIT_IN[2]-1:0] a,
    input logic [2:0][BIT_IN[1]-1:0] b,
    input logic [2:0] cin,
    output logic [BIT_OUT[1]-1:0] out,
    output logic cout
  );
  
  /* Segnali per l'ingresso*/
  
  /* Segnali fra le instanze e il voter */
  logic [2:0][BIT_IN[2]-1:0] out_to_vote; 
  logic [2:0] cout_to_vote; 

  // find the Total Number of Bit of Signals , e.g the sum of dimension of all input signal
  function int sum_TNBS;
	  int sum;
	  int i;
 	  begin
		  sum=0;
		  for(i=0; i<IN_N; i=i+1) begin
		  	sum = sum + BIT_IN[i];
			$info("TNBS: %d",sum);
		  end
		  sum_TNBS=sum;
	  end
  endfunction
  /* Total Number of Bit of Voted Output , e.g. depends on S_VOT_SET */
  function int sum_TNBVO;
	  int sum;
	  int i;
 	  begin
		  sum=0;
		  for(i=0; i<IN_N; i=i+1) begin
		  	sum = sum + (S_VOTE_SET[i]/2)*BIT_IN[i]*2 + BIT_IN[i];
			$info("TNBVO: %d",sum);
		  end
		  sum_TNBVO=sum;
	  end
  endfunction
  /* Total Number of Bit of Error Output , e.g. depends on S_VOT_SET  */
  function int sum_TNBEO;
	  int sum;
	  int i;
 	  begin
		  sum=0;
		  for(i=0; i<IN_N; i=i+1) begin
		  	sum = sum + (S_VOTE_SET[i]/2)*2 + 1;
			$info("TNBEO: %d",sum);
		  end
		  sum_TNBEO=sum;
	  end
  endfunction


  genvar i;  

  generate
	for ( i=0; i<3; i=i+1) begin
		adder #(.BIT(BIT_IN[2])) u0 (.a(a[i]), .b(b[i]), .cin(cin[i]), .out(out_to_vote[i]), .cout(cout_to_vote[i]));
	end
  

	conf_voter 
	#(
		.N_S(OUT_N),
		.S_BIT(BIT_OUT),
		.S_VOTE_SET(S_VOTE_SET),
		.TNBS(sum_TNBS),
		.TNBVO(sum_TNBVO),
		.TNBEO(sum_TNBEO)
	) voter
	(
		.in_1_i({out_to_vote[0],cout_to_vote[0]}),
		.in_2_i({out_to_vote[1],cout_to_vote[1]}),
		.in_3_i({out_to_vote[2],cout_to_vote[2]}),
		.voted_o({out,cout}),
		.err_detected_1_o(),
		.err_detected_2_o(),
		.err_detected_3_o(),
		.err_corrected_o(),
		.err_detected_o()
	);
  endgenerate
  
endmodule
