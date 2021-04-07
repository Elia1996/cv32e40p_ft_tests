
module tb;
	logic [2:0][31:0] instr ;
	logic [2:0][31:0] instr_o ;
	logic [2:0] is_compressed;
	logic [2:0] illegal_instr;
	logic [2:0] is_broken;
	logic clk;
	logic rst_n;
	logic err_detected;
	logic err_corrected;
	parameter CLK_PHASE_HI = 5;
	parameter CLK_PHASE_LO = 5;
	parameter RESET_WAIT_CYCLES = 2;
	
	
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
	cv32e40p_compressed_decoder_ft compressed_decoder_ft
	(
		.clk(clk),
		.rst_n(rst_n),
		.instr_i(instr),
        	.instr_o(instr_o),
      		.is_compressed_o(is_compressed),
		.illegal_instr_o(illegal_instr),
		.set_broken_i({1'b0,1'b0,1'b0}),
		.is_broken_o(is_broken),
		.err_detected_o(err_detected),
		.err_corrected_o(err_corrected)
	);
		

 	// Stimulus
	initial begin
		#40
		instr <=    '{32'd1,32'd0,32'd0};
		#2 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};

		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd0,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);
		#10 instr <= '{32'd1,32'd0,32'd0};
		$display("is_broken : %d %d %d, errc: %d errd:%d", is_broken[0], is_broken[1] , is_broken[2],
						err_corrected, err_detected);


		#5 $display("instr_o : %d, %d, %d ... is_compressed: %d, %d, %d ... illegal_instr: %d, %d, %d ",instr_o[0], instr_o[1], instr_o[2], is_compressed[0],is_compressed[1], is_compressed[2], illegal_instr[0], illegal_instr[1], illegal_instr[2] );
		$display("is_broken : %d %d %d", is_broken[0], is_broken[1] , is_broken[2]);
		#10 $finish;
	end
endmodule
 
