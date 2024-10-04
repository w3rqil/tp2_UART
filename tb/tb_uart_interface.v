`timescale 1ns/1ps

module tb_uart_interface;

    // Parameters
    localparam NB_DATA  = 8;
    localparam NB_STOP  = 16;
    localparam NB_OP    = 6;

    // Inputs
    reg clk;
    reg [NB_DATA - 1 : 0] i_rx;
    reg i_rxDone;
    reg i_rst_n;

    // Outputs
    wire [NB_DATA - 1 : 0] o_data;

    // Instantiate the DUT (Device Under Test)
    uart_interface #(
        .NB_DATA(NB_DATA),
        .NB_STOP(NB_STOP),
        .NB_OP(NB_OP)
    ) dut (
        .clk(clk),
        .i_rx(i_rx),
        .i_rxDone(i_rxDone),
        .i_rst_n(i_rst_n),
        .o_data(o_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test vectors
    initial begin
        // Initialize inputs
        i_rx = 0;
        i_rxDone = 0;
        i_rst_n = 0;

        // Reset the DUT
        #10;
        i_rst_n = 1;
        #10;
        i_rst_n = 0;
        #100
        i_rst_n = 1;
        #10;

        // Test ADD operation
        // Load DATOA
        i_rx = 8'b00001000;
        i_rxDone = 1;
        #10;
        i_rxDone = 0;
        #10;
        i_rx = 8'b00000001;
        i_rxDone = 1;
        #10;
        i_rxDone = 0;
        #10;
        // Load DATOB
        i_rx = 8'b00010000;
        i_rxDone = 1;
        #10;
        i_rxDone = 0;
        #10;
        i_rx = 8'b00000001;
        i_rxDone = 1;
        #10;
        i_rxDone = 0;
        #10;

        // Load OP (ADD)
        i_rx = 8'b00100000; // op code
        i_rxDone = 1;
        #10;
        i_rxDone = 0;
        #10;
        i_rx = 8'b00100000; // add code
        i_rxDone = 1;
        #10;
        i_rxDone = 0;
        #10;

        // Check result
        #20;
        $display("ADD Result: %d", o_data);

        i_rx = 8'b00100000; // op code
        i_rxDone = 1;
        #10;
        i_rxDone = 0;
        #10;
        i_rx = 8'b00100010; // sub code
        i_rxDone = 1;
        #10;
        i_rxDone = 0;
        #10;

        #20;
        $display("SUB Result: %d", o_data);
        $finish;
    end

endmodule
