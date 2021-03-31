import config_pkg::*;

module adder_ft
  (
    input logic [2:0][CONFIG_MAT[0].BIT_I[2]-1:0] a,
    input logic [2:0][CONFIG_MAT[0].BIT_I[1]-1:0] b,
    input logic [2:0] cin,
    output logic [CONFIG_MAT[0].BIT_O[1]-1:0] out,
    output logic cout
  );
  
  /* Segnali per l'ingresso*/
  
  /* Segnali fra le instanze e il voter */
  logic [2:0][CONFIG_MAT[0].BIT_I[2]-1:0] out_to_vote; 
  logic [2:0] cout_to_vote; 


  // find the Total Number of Bit of Signals , e.g the sum of dimension of all input signal
  function int sum_TNBS;
	  int sum;
	  int i;
 	  begin
		  sum=0;
		  for(i=0; i<CONFIG_MAT[0].N_I; i=i+1) begin
		  	sum = sum + CONFIG_MAT[0].BIT_I[i];
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
		  for(i=0; i<CONFIG_MAT[0].N_I; i=i+1) begin
		  	sum = sum + ((CONFIG_MAT[0].VOTE_SET[i]/2)*2 + 1)*CONFIG_MAT[0].BIT_I[i];
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
		  for(i=0; i<CONFIG_MAT[0].N_I; i=i+1) begin
		  	sum = sum + (CONFIG_MAT[0].VOTE_SET[i]/2)*2 + 1;
			$info("TNBEO: %d",sum);
		  end
		  sum_TNBEO=sum;
	  end
  endfunction


  genvar i;  

  generate
	for ( i=0; i<3; i=i+1) begin
		adder #(.BIT(CONFIG_MAT[0].BIT_I[2])) u0 (.a(a[i]), .b(b[i]), .cin(cin[i]), .out(out_to_vote[i]), .cout(cout_to_vote[i]));
	end
  

	conf_voter 
	#(
		.CONF(ADDER_FT_CONF)
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
