module adder
  #(
    parameter integer BIT = 8
  )
  (
    input logic [BIT-1:0] a,
    input logic [BIT-1:0] b,
    input logic cin,
    output logic [BIT-1:0] out,
    output logic cout
  );
  
  always_comb
    begin
      {cout , out } = a + b + cin;
  end
  
endmodule
