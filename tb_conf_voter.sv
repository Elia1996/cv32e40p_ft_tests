
module tb;
	logic [2:0][31:0] instr ;
	logic [2:0][31:0] instr_o ;
	logic [2:0] block_err;
	logic clk;
	logic rst_n;
	parameter CLK_PHASE_HI = 5;
	parameter CLK_PHASE_LO = 5;
	parameter RESET_WAIT_CYCLES = 4;
	
	
	// Clock generation
	initial begin : clock_gen
		forever begin
			#CLK_PHASE_HI clk = 1'b0;
			#CLK_PHASE_LO clk = 1'b1;
		end
	end: clock_gen
	
	// Reset generation
	initial begin : rstn_gen
		rst_n = 1'b0;
		repeat (RESET_WAIT_CYCLES) begin
			@(posedge clk);
		end
		#1 rst_n = 1'b1;
	end : rstn_gen


	// DUT init
	cv32e40p_conf_voter
	#(	
		.L1(32),
		.TOUT(1)
	) conf_voter
	(
		.to_vote_i(instr),
		.voted_o(instr_o),
		.block_err_o(block_err)
	);

		

 	// Stimulus
	initial begin
		#40
		instr <=    '{32'd1,32'd0,32'd0};
		#2 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d", block_err[0], block_err[1] , block_err[2]);
		#5 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d", block_err[0], block_err[1] , block_err[2]);
		#5 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d", block_err[0], block_err[1] , block_err[2]);
		#5 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d", block_err[0], block_err[1] , block_err[2]);
		#5 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d", block_err[0], block_err[1] , block_err[2]);
		#5 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d", block_err[0], block_err[1] , block_err[2]);
		#5 instr <= '{32'd1,32'd0,32'd0};



		$display("is_broken : %d %d %d", block_err[0], block_err[1] , block_err[2]);
		#10 $finish;
	end
endmodule
 
