module testbench;
  logic [7:0] data[4]; // array of 4 8-bit data values
  logic [7:0] result;
  logic       overflow;

  int unsigned expected_result, expected_overflow, fail;
  int unsigned is_subtract, opA, opB;

  // turn on waves
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
  end
 
  // instantiate the design
  dut(.result(result), .overflow(overflow),
      .opcode({is_subtract[0], opA[1:0], opB[1:0]}),
      .data0(data[0]), .data1(data[1]), .data2(data[2]), .data3(data[3]));
 
  initial begin
    fail = 0;
    data[0] = 8'h0C;
    data[1] = 8'h36;
    data[2] = 8'h7B;
    data[3] = 8'hE9;
    
    // STIMULUS GENERATOR: test all 32 combinations of the 4 operands
    // for both add and subtract
    for(is_subtract = 0; is_subtract < 2; is_subtract++) begin
      for(opA = 0; opA < 4; opA++) begin
        for(opB = 0; opB < 4; opB++) begin
          #10;
          // CHECKER: outputs from DUT are stable by now, check them
          // before driving in new inputs
          if(is_subtract)
            expected_result = data[opA[1:0]] - data[opB[1:0]];
          else
            expected_result = data[opA[1:0]] + data[opB[1:0]];
          if(result != expected_result[7:0]) begin
            $error("ERROR! %h %s %h result: golden model = %h, DUT = %h",
                   data[opA], is_subtract ? "-" : "+", data[opB],
                   expected_result[7:0], result);
            fail = 1;
          end
          if( ((!is_subtract && (data[opA[1:0]][7] == data[opB[1:0]][7])) ||
               (is_subtract && (data[opA[1:0]][7] != data[opB[1:0]][7])))
             && ((data[opA[1:0]][7] && !expected_result[7]) ||
                 (!data[opA[1:0]][7] && expected_result[7])) )
            expected_overflow = 1;
          else
            expected_overflow = 0;
          if(overflow != expected_overflow) begin
            $error("ERROR! %h %s %h overflow: golden model = %b, DUT = %b",
                   data[opA], is_subtract ? "-" : "+", data[opB],
                   expected_overflow[0], overflow);
            fail = 1;
          end
        end // for opB
      end // for opA
    end // for is_subtract
    if(fail)
      $display("################\n###  FAILED  ###\n################");
    else
      $display("****************\n***  PASSED  ***\n****************");
    $finish;
  end
endmodule