// Code your testbench here
// or browse Examples

module tb
  #(
  	parameter integer BIT = 8,
	parameter integer S_VOTE_SET [1:0] = {0,0}
  );
  
  logic [2:0][BIT-1:0] a;
  logic [2:0][BIT-1:0] b;
  logic [2:0] cin;
  logic [BIT-1:0] out;
  logic cout;
  
  adder_ft #(.S_VOTE_SET(S_VOTE_SET)) dut
  (
    .a(a),
    .b(b),
    .cin(cin),
    .cout(cout),
    .out(out)
  );
 
  initial begin
    a <= {8'b0010_0101, 8'b0010_0101, 8'b0010_0001};
    b <= {8'b0100_0101, 8'b0100_0101, 8'b0100_0101};
    cin <= {'0,'0,'0};
    
    #5 $display("cout: %d , out: %d, %d, %d, %d, %d, %d, %d ",cout,out,dut.a[0],dut.a[1], dut.a[2], dut.b[0],dut.b[1],dut.b[2] );
    #10 $finish;
  end
endmodule
 
