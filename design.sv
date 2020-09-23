module dut(result, overflow, opcode, data0, data1, data2, data3);
  input logic  [7:0] data0, data1, data2, data3;
  input logic  [4:0] opcode;
  output logic [7:0] result;
  output logic overflow;
  
  logic [7:0] A,B;
  
  
  // turn on waves
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
  end
  

  // your SV description for the DUT module goes here.
  mux mux1(.in0(data0),.in1(data1),.in2(data2),.in3(data3),.sel(opcode[3:2]), .out(A));
  mux mux2(.in0(data0),.in1(data1),.in2(data2),.in3(data3),.sel(opcode[1:0]), .out(B));
  
  ALU alu1(A, B,opcode[4],result[7:0],overflow);
endmodule


// your auxiliary module declarations go here.
module half_adder(input logic a,b, output logic c_out, sum);
    assign c_out = a&b;
    assign sum = a^b;
  endmodule
  
module full_adder(input logic x,y,c_in, output logic sum,c_out);
    logic sum1;
    logic half1_carry;
    logic half2_carry;
    
    
  half_adder half1(.a(x),.b(y),
         	.c_out(half1_carry), .sum(sum1));
  half_adder half2(.a(c_in),.b(sum1),
            .c_out(half2_carry),.sum(sum));
    
    assign c_out = half1_carry | half2_carry;
    
  endmodule
  
module ALU(operand_A, operand_B,subtract,result,overflow);
    input logic [7:0]operand_A;
    input logic [7:0]operand_B;
    input logic subtract;
    output logic [7:0]result;
    output logic overflow;
   	logic of1, of2,of3,of4,of5,of6,of7;
  	logic b0,b1,b2,b3,b4,b5,b6,b7,b8;
    
  assign b0 = subtract^operand_B[0];
  assign b1 = subtract^operand_B[1];
  assign b2 = subtract^operand_B[2];
  assign b3 = subtract^operand_B[3];
  assign b4 = subtract^operand_B[4];
  assign b5 = subtract^operand_B[5];
  assign b6 = subtract^operand_B[6];
  assign b7 = subtract^operand_B[7];
  
  full_adder adder1(operand_A[0],b0,subtract,result[0],of1);
  full_adder adder2(operand_A[1],b1,of1,result[1],of2);
  full_adder adder3(operand_A[2],b2,of2,result[2],of3);
  full_adder adder4(operand_A[3],b3,of3,result[3],of4);
  full_adder adder5(operand_A[4],b4,of4,result[4],of5);
  full_adder adder6(operand_A[5],b5,of5,result[5],of6);
  full_adder adder7(operand_A[6],b6,of6,result[6],of7);
  full_adder adder8(operand_A[7],b7,of7,result[7],b8);
  assign overflow = of7^b8;
endmodule

module mux(in0,in1,in2,in3,sel,out);
  input logic [7:0] in0,in1,in2,in3;
  input logic [1:0] sel;
  output logic [7:0] out;
            
            always_comb begin
              case(sel)
                2'b00: out = in0;
                2'b01: out = in1;
                2'b10: out = in2;
                2'b11: out = in3;
                default: out = 2'bXX;
              endcase
            end
    endmodule
