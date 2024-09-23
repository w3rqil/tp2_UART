/*
    
    Secuencia de estados Rx
    ◼ Asumiendo N bits de datos, M bits de Stop.
        1) Esperar a que la señal de entrada sea 0, momento en el
        que inicia el bit de Start. Iniciar el Tick Counter.

        2) Cuando el contador llega a 7, la señal de entrada está en
        el punto medio del bit de Start. Reinicar el contador.
        
        3) Cuando el contador llega a 15, la señal de entrada avanza
        1 bit, y alcanza la mitad del primer bit de datos. Tomar este
        valor e ingresarlo en un shift register. Reinicar el contador.
        
        4) Repetir el paso 3 N-1 veces para tomar los bits restantes.
        
        5) Si se usa bit de paridad, repetir el paso 3 una vez mas.
        
        6) Reperir el paso 3 M veces, para obtener los bits de Stop.
*/

module uart_rx
#(
    NB_DATA = 1                                 ,
    NB_STOP  = 1
)(
    input   wire                    clk         ,
    input   wire                    i_rst_n     ,
    input   wire                    i_tick      ,
    input   wire                    i_data      ,
    output  wire [NB_DATA - 1 : 0]  o_data      ,
    output  wire                    o_rxdone
);




endmodule
