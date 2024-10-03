module tb_alu();

  // Parameters
  localparam NB_DATA = 8;
  localparam NB_OP = 6;

  // Inputs
  reg i_valid;
  reg signed [NB_DATA-1:0] i_datoA;
  reg signed [NB_DATA-1:0] i_datoB;
  reg [NB_OP-1:0] i_operation;

  // Outputs
  wire signed [NB_DATA-1:0] o_leds;

  // Instantiate the ALU module
  alu #(
    .NB_DATA(NB_DATA),
    .NB_OP(NB_OP)
  ) uut (
    .i_valid(i_valid),
    .i_datoA(i_datoA),
    .i_datoB(i_datoB),
    .i_operation(i_operation),
    .o_leds(o_leds)
  );

  // Test sequence
  initial begin
    // Initialize inputs
    i_valid = 0;
    i_datoA = 0;
    i_datoB = 0;
    i_operation = 0;

    // Wait for global reset
    #10;

    // Test OP_ADD
    i_datoA = 8'h0A; // 10
    i_datoB = 8'h05; // 5
    i_operation = 6'b100000; // OP_ADD
    i_valid = 1;
    #10;
    i_valid = 0;
    #10;

    // Test OP_SUB
    i_datoA = 8'h0A; // 10
    i_datoB = 8'h05; // 5
    i_operation = 6'b100010; // OP_SUB
    i_valid = 1;
    #10;
    i_valid = 0;
    #10;

    // Test OP_AND
    i_datoA = 8'h0F; // 15
    i_datoB = 8'hF0; // 240
    i_operation = 6'b100100; // OP_AND
    i_valid = 1;
    #10;
    i_valid = 0;
    #10;

    // Test OP_OR
    i_datoA = 8'h0F; // 15
    i_datoB = 8'hF0; // 240
    i_operation = 6'b100101; // OP_OR
    i_valid = 1;
    #10;
    i_valid = 0;
    #10;

    // Test OP_XOR
    i_datoA = 8'h0F; // 15
    i_datoB = 8'hF0; // 240
    i_operation = 6'b100110; // OP_XOR
    i_valid = 1;
    #10;
    i_valid = 0;
    #10;

    // Test OP_SRA
    i_datoA = 8'hF0; // -16 (signed)
    i_datoB = 8'h02; // 2
    i_operation = 6'b000011; // OP_SRA
    i_valid = 1;
    #10;
    i_valid = 0;
    #10;

    // Test OP_SRL
    i_datoA = 8'hF0; // 240 (unsigned)
    i_datoB = 8'h02; // 2
    i_operation = 6'b000010; // OP_SRL
    i_valid = 1;
    #10;
    i_valid = 0;
    #10;

    // Test OP_NOR
    i_datoA = 8'h0F; // 15
    i_datoB = 8'hF0; // 240
    i_operation = 6'b100111; // OP_NOR
    i_valid = 1;
    #10;
    i_valid = 0;
    #10;

    // End of test
    $stop;
  end

  // Monitor to display the output values
  initial begin
    $monitor("At time %t, i_datoA = %h, i_datoB = %h, i_operation = %b, o_leds = %h", 
              $time, i_datoA, i_datoB, i_operation, o_leds);
  end

endmodule
