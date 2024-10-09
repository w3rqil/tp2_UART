`timescale 1ns/1ps

module tb_uart_rx;

    // Parameters
    localparam NB_DATA = 8;
    localparam NB_STOP = 16;

    // Signals
    reg clk;
    reg i_rst_n;
    reg i_data;
    wire o_tick;
    wire [NB_DATA-1:0] o_data;
    wire o_rxdone;

    // Instantiate the baudrate generator
    baudrate_generator #(
        .NC_PER_TICK(163),
        .NB_COUNTER(8)
    ) uut_baudrate_generator (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .o_tick(o_tick)
    );

    // Instantiate the UART RX module
    uart_rx #(
        .NB_DATA(NB_DATA),
        .NB_STOP(NB_STOP)
    ) uut_uart_rx (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_tick(o_tick),
        .i_data(i_data),
        .o_data(o_data),
        .o_rxdone(o_rxdone)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // // Monitor signals for debugging
    // initial begin
    //     $monitor("Time: %0t | i_data: %b | o_tick: %b | o_data: %b | o_rxdone: %b", 
    //               $time, i_data, o_tick, o_data, o_rxdone);
    // end

    // Test sequence
    initial begin
        // Initialize signals
        i_rst_n = 0;
        i_data = 1;

        // Apply reset
        #20;
        i_rst_n = 1;
        
        // Wait for a few ticks
        repeat(10) @(posedge o_tick);

        // Send a start bit
        i_data = 0; // Start bit
        repeat(16) @(posedge o_tick);
        
    // Send data bits (example: 0b11100010)
        i_data = 1; // Bit 7
        repeat(16) @(posedge o_tick); // Espera 16 ticks
        i_data = 1; // Bit 6
        repeat(16) @(posedge o_tick); // Espera 16 ticks
        i_data = 1; // Bit 5
        repeat(16) @(posedge o_tick); // Espera 16 ticks
        i_data = 0; // Bit 4
        repeat(16) @(posedge o_tick); // Espera 16 ticks
        i_data = 0; // Bit 3
        repeat(16) @(posedge o_tick); // Espera 16 ticks
        i_data = 0; // Bit 2
        repeat(16) @(posedge o_tick); // Espera 16 ticks
        i_data = 1; // Bit 1
        repeat(16) @(posedge o_tick); // Espera 16 ticks
        i_data = 0; // Bit 0
        repeat(16) @(posedge o_tick); // Espera 16 ticks

        // Send stop bits
        i_data = 1;
        repeat(NB_STOP) @(posedge o_tick);

        // Wait for RX done
        // wait(o_rxdone);

        // Check received data
        if (o_data == 8'b10101010) begin
            $display("Test Passed: Received data is correct: %b", o_data);
        end else begin
            $display("Test Failed: Received data is incorrect: %b", o_data);
        end

        // // Wait a bit to observe the DONE state
        // repeat(5) @(posedge o_tick); // You can adjust the number of ticks to observe
        
        $display("Finalizando la simulación en el tiempo: %0t", $time);
        // Finish the simulation
        $finish; // This will stop the simulation
    end
endmodule
