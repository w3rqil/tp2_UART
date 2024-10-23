module uart_interface
#(
    NB_DATA  = 8                                                            , //! numero de bits de datos
    NB_STOP  = 16                                                           , //! numero de bits de stop                               
    NB_OP    = 6                                                              //! numero de bits de operacion
)(
    input       wire                            clk                         , //! Clock
    input       wire signed [NB_DATA - 1 : 0]   i_rx                        , //! Input data para el modulo UART_RX
    input       wire                            i_rxDone                    , //! UART_RX done bit
    input       wire                            i_txDone                    , //! UART_TX done bit
    input       wire                            i_rst_n                     , //! Reset de flanco de bajada
    output      wire                            o_tx_start                  ,
    output      wire        [NB_DATA - 1 : 0]   o_data                      , //! Resultado de la ALU para ser enviado por UART_TX



    /*
        ------------------------
        ------- ALU I/O --------
        ------------------------
    */
    output      wire        [NB_OP   - 1 : 0]   o_operation                , //! Operacion de la ALU
    output      wire        [NB_DATA - 1 : 0]   o_datoB                    , //! Dato B de la ALU
    output      wire        [NB_DATA - 1 : 0]   o_datoA                    , //! Dato A de la ALU
    output      wire                            o_valid                    , //! Valid de la ALU
    input       wire        [NB_DATA - 1 : 0]   i_result                     //! Resultado de la ALU
);

    // Estados de la máquina de estados
    localparam [2:0] 
    IDLE    = 3'b001,                                                       //! Estado inicial
    PARSE   = 3'b010,                                                       //! Estado de parseo
    STOP    = 3'b100;                                                       //! Estado de parada

    // Tipos de registros para los datos
    localparam [5:0]
    DATOA   = 6'b001000,                                                     //! Tipo de dato A
    DATOB   = 6'b010000,                                                     //! Tipo de dato B
    OP      = 6'b100000;                                                     //! Tipo de operacion
    reg [2:0]               state                                           ; //! Estado de la maquina de estados
    reg [1:0]               done_counter                                    ; //! Contador de done
    // ALU
    reg [NB_OP   - 1 : 0]   op                                              ; //! Operacion de la interfaz
    reg [NB_DATA - 1 : 0]   datoB                                           ; //! Dato B de la interfaz
    reg [NB_DATA - 1 : 0]   datoA                                           ; //! Dato A de la interfaz
    reg                     valid                                           ; //! Valid de la interfaz
    reg                     next_valid                                      ; //! Siguiente Valid de la interfaz
    reg  [NB_DATA - 1 : 0]  next_datoA                                      ; //! Siguiente Dato A de la interfaz
    reg  [NB_DATA - 1 : 0]  next_datoB                                      ; //! Siguiente Dato B de la interfaz
    reg  [NB_OP - 1 : 0  ]  next_op                                         ; //! Siguiente Operacion de la interfaz
    wire signed [NB_DATA - 1 : 0]  leds_reg                                 ; //! Registro de salida de la ALU en leds
    // vars
    reg                     tx_start, next_tx_start                         ; //! Start de la transmision
    reg  [2:0]              next_state                                      ; //! Siguiente estado
    reg  [1:0]              next_done_counter                               ; //! Siguiente contador de done
    reg  [NB_OP - 1 : 0]    type_reg                                        ; //! Registro de tipo de dato (op, datoA, datoB)  


    always @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            state <= IDLE                                                   ;
            done_counter <= 0                                               ;
            valid <= 0                                                      ;
            datoA <= 0                                                      ;
            datoB <= 0                                                      ;
            tx_start <= 0                                                   ;
            op <= 0                                                         ;
        end else begin              
            state <= next_state                                             ;
            done_counter <= next_done_counter                               ;
            valid <= next_valid                                             ;
            datoA <= next_datoA                                             ;
            datoB <= next_datoB                                             ;
            op <= next_op                                                   ;
            tx_start <= next_tx_start                                       ;

        end
    end

    // RX-ALU interface
    always @(*) begin
        next_state = state;
        next_done_counter = done_counter;
        next_valid = valid;
        next_datoA = datoA;
        next_datoB = datoB;
        next_op = op;
        next_tx_start = tx_start;
        //type_reg = i_rx[NB_OP-1:0];
        case(state)
            IDLE: begin
                if (i_rxDone) begin 
                    //next_done_counter = done_counter + 1                    ;
                    type_reg = i_rx[NB_OP-1:0]                              ;
                    next_state = PARSE                                      ;
                    
                end else begin                  
                    next_state = IDLE                                       ;
                    next_done_counter = 0                                   ;
                end
                
            end
            PARSE: begin
                next_valid = 0                                              ;
                if (i_rxDone) begin                          
                        case(type_reg) 
                            DATOA: begin               
                                next_datoA = i_rx                           ;
                            end      
                            DATOB : begin                
                                next_datoB = i_rx                           ;
                            end            
                            OP: begin                       
                                next_op = i_rx[NB_OP-1:0]                   ;
                                next_valid = 1                              ;
                                next_tx_start = 1                           ;
                            end
                            default: begin
                                next_datoA =   next_datoA                   ;
                                next_datoB = next_datoB                     ;
                                next_op = next_op                           ;
                                next_tx_start = next_tx_start               ;
                                next_valid = next_valid                     ;
                            end
                        endcase
                    
                    next_done_counter =  1                                  ;
                end
                next_state = (done_counter) ? STOP : PARSE                  ;
                //next_done_counter = 0                                       ;  
            end
            STOP: begin
                next_state = IDLE                                           ;
                next_done_counter = 0                                       ;
                next_valid = 0                                              ;
                next_tx_start = 1'b0                                        ;
            //    next_datoA = 0                                              ;
            //    next_datoB = 0                                              ;
            //    next_op = 0                                                 ;                
            end
            default: begin
                next_datoA =   next_datoA                                   ;
                next_datoB = next_datoB                                     ;
                next_op = next_op                                           ;
                next_state = next_state                                     ;
                next_valid = next_valid                                     ;
                next_done_counter = next_done_counter                       ;
                
            end
        endcase
    end

    //! ALU-TX interface


    // assign

    assign o_operation  = op                                                ;
    assign o_datoA      = datoA                                             ;
    assign o_datoB      = datoB                                             ;
    assign o_valid      = valid                                             ;
    assign o_tx_start   = tx_start                                          ;
    assign o_data       = i_result                                          ;
    //assign o_data = leds_reg;
/*
    alu
    #(
        .NB_DATA        (NB_DATA    ),
        .NB_OP          (NB_OP      )
    )
    u_alu
    (
        .i_valid        (valid      ),
        .i_datoA        (datoA      ),
        .i_datoB        (datoB      ),
        .i_operation    (op         ),
        .o_leds         (leds_reg   )
    );
*/
endmodule