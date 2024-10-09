`timescale 1ns / 1ps

module tb_uart_rx;

    // Parámetros
    parameter NB_DATA = 8;
    parameter NB_STOP = 16;
    parameter NC_PER_TICK = 163;
    parameter NB_COUNTER = 8;
    
    // Señales
    reg clk;
    reg i_rst_n;
    reg i_data;
    wire [NB_DATA-1:0] o_data;
    wire o_rxdone;
    wire o_tick;

    // Instanciación del módulo uart_rx
    uart_rx #(
        .NB_DATA(NB_DATA),
        .NB_STOP(NB_STOP)
    ) uart_rx_inst (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_tick(o_tick),
        .i_data(i_data),
        .o_data(o_data),
        .o_rxdone(o_rxdone)
    );

    // Instanciación del módulo baudrate_generator
    baudrate_generator #(
        .NC_PER_TICK(NC_PER_TICK),
        .NB_COUNTER(NB_COUNTER)
    ) baudrate_generator_inst (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .o_tick(o_tick)
    );

    // Generación del reloj
    always #5 clk = ~clk; // Periodo de 10 ns (100 MHz)

    // Inicialización
    initial begin
        // Inicializar señales
        clk = 0;
        i_rst_n = 0;
        i_data = 1; // Iniciar con nivel alto (línea inactiva)
        
        // Reset
        #20;
        i_rst_n = 1;
        @(posedge clk);

        // Simulación de la recepción de un byte (0xA5 por ejemplo: 10100101)
        send_byte(8'b10100101);

        // Simular otro byte (0x5A por ejemplo: 01011010)
        send_byte(8'b01011010);

        // Finalizar la simulación
        repeat(80000) @(posedge clk); // Esperar 10000 ticks
        
        $finish;
    end

    // Tarea para enviar un byte simulando el protocolo UART
    task send_byte(input [7:0] data);
        integer i;
        
        begin
            // Bit de Start (0)
            i_data = 0;
            @(posedge o_tick); // Esperar a un tick

            // Bits de datos (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                i_data = data[i];
                @(posedge o_tick); // Esperar a un tick por cada bit
            end
            
            // Bit de Stop (1)
            i_data = 1;
            for (i = 0; i < NB_STOP; i = i + 1) begin
                @(posedge o_tick); // Esperar ticks por el número de bits de Stop
            end
        end
    endtask

endmodule
