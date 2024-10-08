`timescale 1ns / 1ps

module tb_baudrate_generator;

// Parameters
localparam NC_PER_TICK = 163;
localparam NB_COUNTER = 8;

// Signals
reg clk;
reg i_rst_n;
wire o_tick;

// Instantiate the Unit Under Test (UUT)
baudrate_generator
#(
    .NC_PER_TICK(NC_PER_TICK),
    .NB_COUNTER(NB_COUNTER)
) uut (
    .clk(clk),
    .i_rst_n(i_rst_n),
    .o_tick(o_tick)
);

// Clock generation
always #5 clk = ~clk;

// Test sequence
initial begin
    // Initialize inputs
    clk = 0;
    i_rst_n = 0;

    // Apply reset
    #20;
    i_rst_n = 1;

    // Wait for a few clock cycles to observe the tick output
    #2000;
    
    // Finish simulation
    $finish;
end

// Monitor output
initial begin
    $monitor("Time: %0t, clk: %b, i_rst_n: %b, o_tick: %b", $time, clk, i_rst_n, o_tick);
end

endmodule

