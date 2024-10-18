`timescale 1ns/1ps

module tb_top;

    // Parámetros
    localparam CLK_PERIOD = 20; // Periodo de reloj en nanosegundos
    localparam BAUD_RATE  = 19200;
    localparam CLK_FREQ   = 50_000_000;
    localparam OVERSAMPLING = 16;
    // Señales de entrada/salida
    reg clk;
    reg i_rst_n;
    reg i_rx;
    wire o_tx;



    // Instancia del DUT (Device Under Test)
    top uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_rx(i_rx),
        .o_tx(o_tx)
    );
        // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    // Inicialización
    initial begin
        // Initialize signals
        i_rst_n = 0;
        i_rx = 1;

        // Apply reset
        #20;
        i_rst_n = 1;
        
        // Wait for a few ticks
        repeat(10) #1635;

        // Send a start bit
        i_rx = 0; // Start bit
        repeat(16) #1635;
        
    // Send data bits (example: 0b11100010)
        i_rx = 1; // Bit 7
        repeat(16) #1635; // Espera 16 ticks
        i_rx = 1; // Bit 6
        repeat(16) #1635; // Espera 16 tickss
        i_rx = 1; // Bit 5
        repeat(16) #1635; // Espera 16 ticks
        i_rx = 0; // Bit 4
        repeat(16) #1635; // Espera 16 ticks
        i_rx = 0; // Bit 3
        repeat(16) #1635; // Espera 16 ticks
        i_rx = 0; // Bit 2
        repeat(16) #1635; // Espera 16 ticks
        i_rx = 1; // Bit 1
        repeat(16) #1635; // Espera 16 ticks
        i_rx = 0; // Bit 0
        repeat(16) #1635; // Espera 16 ticks

        // Send stop bits
        i_rx = 1;
        repeat(16*16) #1635;        
        $display("Finalizando la simulación en el tiempo: %0t", $time);
        $finish; // This will stop the simulation
    end
endmodule
