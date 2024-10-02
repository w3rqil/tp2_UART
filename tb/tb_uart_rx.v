`timescale 1ns / 1ps

module tb_uart_rx;

    // Parameters
    localparam NB_DATA = 8;
    localparam NB_STOP = 16;

    // Inputs
    reg clk;
    reg i_rst_n;
    reg i_tick;
    reg i_data;

    // Outputs
    wire [NB_DATA - 1 : 0] o_data;
    wire o_rxdone;

    // Instantiate the UART RX module
    uart_rx
    #(
        .NB_DATA(NB_DATA),
        .NB_STOP(NB_STOP)
    ) uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_tick(i_tick),
        .i_data(i_data),
        .o_data(o_data),
        .o_rxdone(o_rxdone)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        i_rst_n = 0;
        i_tick = 0;
        i_data = 1; // idle state of UART is high

        // Reset the system
        #10;
        i_rst_n = 1;

        // Wait for a stable state
        #10;

        // Start transmission of data: 0x55 (01010101)
        send_data(8'b01010101);

        // Wait for reception to complete
        wait(o_rxdone);
        #10;

        // Check output
        if (o_data !== 8'b01010101) begin
            $display("Test Failed: Received data: %b, Expected: 01010101", o_data);
        end else begin
            $display("Test Passed: Received data: %b", o_data);
        end

        // End simulation
        #10;
        $finish;
    end

    // Task to send data
    task send_data(input [NB_DATA-1:0] data);
        integer i;
        begin
            // Start bit
            i_data = 0; // Start bit is low
            i_tick = 1; #10;
            i_tick = 0; #10;

            // Send each bit
            for (i = 0; i < NB_DATA; i = i + 1) begin
                i_data = data[i];
                i_tick = 1; #10;
                i_tick = 0; #10;
            end

            // Stop bit
            i_data = 1; // Stop bit is high
            i_tick = 1; #10;
            i_tick = 0; #10;
        end
    endtask

endmodule
