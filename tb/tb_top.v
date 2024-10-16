module tb_top;

    // Parámetros
    localparam NB_DATA = 8;
    localparam NB_STOP = 16;
    localparam NB_OP = 6;
    localparam CLK_PERIOD = 20; // Periodo de reloj en nanosegundos

    // Señales de entrada/salida
    reg clk;
    reg i_rst_n;
    reg i_rx;
    wire o_tx;
    wire o_tick;

    // Instantiate the baudrate generator
    baudrate_generator #(
        .BAUD_RATE(19200),
        .CLK_FREQ(50_000_000),
        .OVERSAMPLING(16)
    ) uut_baudrate_generator (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .o_tick(o_tick)
    );    

    // Instancia del DUT (Device Under Test)
    top #(
        .NB_DATA(NB_DATA),
        .NB_STOP(NB_STOP),
        .NB_OP(NB_OP),
        .BAUD_RATE(19200),
        .CLK_FREQ(50_000_000),
        .OVERSAMPLING(16)
    ) uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_rx(i_rx),
        .o_tx(o_tx)
    );

    // Generación del clock
    always #5 clk = ~clk;

    // Tarea para enviar datos a la interfaz UART (simulando recepción)
    task uart_send(input [NB_DATA-1:0] data);
        integer i;
        begin
        i_rx = 0; // Start bit
        repeat(16) @(posedge o_tick); 
        for (i = 0; i < NB_DATA; i = i + 1) begin
            i_rx = data[i]; // Enviar bit por bit
            repeat(16) @(posedge o_tick);  // Cada bit tarda 16 ticks
        end
        i_rx = 1; // Stop bit
        repeat(16) @(posedge o_tick); 
        end
    endtask

    // Inicialización
    initial begin
        clk = 0;
        i_rst_n = 0;
        i_rx = 1; // UART idle (start bit es 0)
        
        // Reset
        #(5 * CLK_PERIOD);
        i_rst_n = 1;
        
        // Enviar Dato A (tipo y valor)
        uart_send(6'b001000); // Tipo de dato DATOA
        uart_send(8'h01);     // Valor de DATOA = 0x12 (18 en decimal)

        // Enviar Dato B (tipo y valor)
        uart_send(6'b010000); // Tipo de dato DATOB
        uart_send(8'h01);     // Valor de DATOB = 0x34 (52 en decimal)

        // Enviar Operación (tipo y valor)
        uart_send(6'b100000); // Tipo de dato OP
        uart_send(6'b100000); // Operación ADD

        // Esperar resultado
        #(100 * CLK_PERIOD);

        // Probar otra operación (SUB)
        uart_send(6'b001000); // DATOA
        uart_send(8'h05);     // DATOA = 0x05
        uart_send(6'b010000); // DATOB
        uart_send(8'h03);     // DATOB = 0x03
        uart_send(6'b100000); // OP
        uart_send(6'b100010); // Operación SUB

        // Esperar el resultado
        #(100 * CLK_PERIOD);
        
        // Finalizar simulación
        $finish;
    end

    // Monitor para ver los resultados
    initial begin
        $monitor("Time: %0t | i_rst_n: %b | i_rx: %b | o_tx: %b", $time, i_rst_n, i_rx, o_tx);
    end

endmodule
