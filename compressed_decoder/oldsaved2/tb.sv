// Code your testbench here
// or browse Examples
import config_pkg::*;

module tb;
  
  logic [2:0][CONFIG_MAT[0].BIT_I[2]-1:0] a;
  logic [2:0][CONFIG_MAT[0].BIT_I[1]-1:0] b;
  logic [2:0] cin;
  logic [CONFIG_MAT[0].BIT_O[1]-1:0] out;
  logic cout;

     //     CONFIG_MAT[0].N_I = 3;
     //   CONFIG_MAT[0].N_O = 2;
     //   CONFIG_MAT[0].TNBS = 17;
     //   CONFIG_MAT[0].TNBVO = 9;
     //   CONFIG_MAT[0].TNBEO = 2;
     //   CONFIG_MAT[0].BIT_I = {8,8,1};
     //   CONFIG_MAT[0].BIT_O = {8,1};
     //   CONFIG_MAT[0].VOTE_SET = {1,1};
  
  adder_ft  dut
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
 
