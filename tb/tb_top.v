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

    task uart_send(input [7:0] data);
        integer i;
        begin
        i_rx = 0; // Start bit
        repeat(16) #3270;
        for (i = 0; i < 8; i = i + 1) begin
            i_rx = data[i]; // Enviar bit por bit
            repeat(16) #3270;  // Cada bit tarda 16 ticks
        end
        i_rx = 1; // Stop bit
        repeat(100) #3270; 
        end
    endtask


    // Inicialización
    initial begin
        // Initialize signals
        i_rst_n = 0;
        i_rx = 1;

        // Apply reset
        #20;
        i_rst_n = 1;
        
        // Wait for a few ticks
        repeat(10) #3270;

        // Enviar Dato A (tipo y valor)
        uart_send(8'b00001000); // Tipo de dato DATOA
        uart_send(8'h01);     // Valor de DATOA = 0x12 (18 en decimal)
        
         // Enviar Dato B (tipo y valor)
        uart_send(8'b00010000); // Tipo de dato DATOB
        uart_send(8'h08);     // Valor de DATOB = 0x34 (52 en decimal)

        // Enviar Operación (tipo y valor)
        uart_send(8'b00100000); // Tipo de dato OP
        uart_send(8'b00100000); // Operación ADD

        #100;
    // Send data bits (example: 0b11100010)
//        i_rx = 1; // Bit 7
//        repeat(16) #1635; // Espera 16 ticks
//        i_rx = 1; // Bit 6
//        repeat(16) #1635; // Espera 16 tickss
//        i_rx = 1; // Bit 5
//        repeat(16) #1635; // Espera 16 ticks
//        i_rx = 0; // Bit 4
//        repeat(16) #1635; // Espera 16 ticks
//        i_rx = 0; // Bit 3
//        repeat(16) #1635; // Espera 16 ticks
//        i_rx = 0; // Bit 2
//        repeat(16) #1635; // Espera 16 ticks
//        i_rx = 1; // Bit 1
//        repeat(16) #1635; // Espera 16 ticks
//        i_rx = 0; // Bit 0
//        repeat(16) #1635; // Espera 16 ticks

        // Send stop bits
        //i_rx = 1;
        repeat(16*16) #3270;        
        $display("Finalizando la simulación en el tiempo: %0t", $time);
        $finish; // This will stop the simulation
    end
endmodule
