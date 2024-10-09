`timescale 1ns / 1ps

module uart_tx_tb;

  // Parameters
  parameter NB_DATA = 8;
  parameter NB_STOP = 16;
  parameter NC_PER_TICK = 163;
  parameter NB_COUNTER = 8;

  // Testbench signals
  reg clk;
  reg i_rst_n;
  reg i_start_tx;
  reg [NB_DATA-1:0] i_data;
  wire o_txdone;
  wire o_data;
  wire o_tick;

  // Instantiate the UART TX and Baudrate Generator modules
  uart_tx #(
    .NB_DATA(NB_DATA),
    .NB_STOP(NB_STOP)
  ) uut (
    .clk(clk),
    .i_rst_n(i_rst_n),
    .i_tick(o_tick),
    .i_start_tx(i_start_tx),
    .i_data(i_data),
    .o_txdone(o_txdone),
    .o_data(o_data)
  );

  baudrate_generator #(
    .NC_PER_TICK(NC_PER_TICK),
    .NB_COUNTER(NB_COUNTER)
  ) brg (
    .clk(clk),
    .i_rst_n(i_rst_n),
    .o_tick(o_tick)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100MHz clock
  end

  // Test sequence
  initial begin
    // Initialize signals
    //clk=0;
    i_rst_n = 0;
    i_start_tx = 0;
    i_data = 0;
    #100;

    // Reset the system
    i_rst_n = 1;
    #20;

    // Test case 1: Send a byte (e.g., 0xA5)
    i_data = 8'hA5;
    i_start_tx = 1;
    #10;
    i_start_tx = 0;

    // Wait for transmission to complete
    wait(o_txdone);
    #20;

    // Check transmitted data
    $display("Transmitted data: 0x%0h", i_data);
    $finish;
  end

endmodule
