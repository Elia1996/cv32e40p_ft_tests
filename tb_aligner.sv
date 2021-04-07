
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
	cv32e40p_aligner_ft aligner
	(
		.clk('0),
		.rst_n('0),
		.fetch_valid_i('0),
		.if_valid_i('0),
		.fetch_rdata_i('0),
		.branch_addr_i('0),
		.branch_i('0),
		.hwlp_addr_i('0),
		.hwlp_update_pc_i('0),
		.set_broken_i('0),
		.aligner_ready_o(),
		.instr_aligned_o(),
		.instr_valid_o(),
		.pc_o(),
		.is_broken_o(),
		.err_detected_o(),
		.err_corrected_o()
	);


 	// Stimulus
	initial begin

		#5 $display("instr_o : %d, %d, %d ... is_compressed: %d, %d, %d ... illegal_instr: %d, %d, %d ",instr_o[0], instr_o[1], instr_o[2], is_compressed[0],is_compressed[1], is_compressed[2], illegal_instr[0], illegal_instr[1], illegal_instr[2] );
		$display("is_broken : %d %d %d", is_broken[0], is_broken[1] , is_broken[2]);
		#10 $finish;
	end
endmodule
 
