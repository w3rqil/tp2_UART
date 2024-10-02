`timescale 1ns / 1ps

module tb_uart_interface;

    // Parameters
    parameter NB_DATA = 8;
    parameter NB_STOP = 16;
    parameter NB_OP = 6;

    // Inputs
    reg clk;
    reg [NB_DATA - 1 : 0] i_rx;
    reg i_rxDone;
    reg i_rst_n;

    // Outputs
    wire [NB_DATA - 1 : 0] o_data;

    // Instantiate the Unit Under Test (UUT)
    uart_interface uut (
        .clk(clk),
        .i_rx(i_rx),
        .i_rxDone(i_rxDone),
        .i_rst_n(i_rst_n),
        .o_data(o_data)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period = 10 ns
    end

    // Stimulus
    initial begin
        // Initialize Inputs
        i_rx = 0;
        i_rxDone = 0;
        i_rst_n = 0;

        // Apply reset
        #10;
        i_rst_n = 1;

        // Test Case 1: Send DatoA
        #10; 
        i_rx = 8'b00000001; // Simulate DatoA
        i_rxDone = 1; 
        #10; 
        i_rxDone = 0; // Clear the done signal

        // Test Case 2: Send DatoB
        #10; 
        i_rx = 8'b00000010; // Simulate DatoB
        i_rxDone = 1; 
        #10; 
        i_rxDone = 0; // Clear the done signal

        // Test Case 3: Send Operation
        #10; 
        i_rx = 8'b00000011; // Simulate Operation
        i_rxDone = 1; 
        #10; 
        i_rxDone = 0; // Clear the done signal

        // Test Case 4: Verify output after sending DatoA, DatoB and Operation
        #10;

        // Assert output (o_data) - Add checks based on expected behavior
        // You can add specific checks here based on expected outputs
        if (o_data !== expected_output) begin
            $display("Error: o_data is not as expected! Got: %b", o_data);
        end else begin
            $display("Test Passed! o_data: %b", o_data);
        end

        // End of simulation
        #20;
        $finish;
    end
endmodule
