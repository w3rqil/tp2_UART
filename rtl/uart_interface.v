module uart_interface
#(
    NB_DATA  = 8                                                            ,
    NB_STOP  = 16                                                           , //stops at 16 count                               
    NB_OP    = 6
)(
    input       wire                            clk                         ,
    input       wire signed       [NB_DATA - 1 : 0]   i_rx                  ,
    input       wire                            i_rxDone                    ,
    input       wire                            i_rst_n                     ,     
    output      wire        [NB_DATA - 1 : 0]   o_data
);

    // Estados de la máquina de estados
    localparam [2:0] 
    IDLE    = 3'b001, 
    PARSE   = 3'b010, 
    STOP    = 3'b100;

    // Tipos de registros para los datos
    localparam [5:0]
    DATOA   = 6'b001000,
    DATOB   = 6'b010000,
    OP      = 6'b100000;
    reg [2:0]               state                                           ;
    reg [1:0]               done_counter                                    ;
    reg [NB_OP   - 1 : 0]   op                                              ;
    reg [NB_DATA - 1 : 0]   datoB                                           ;
    reg [NB_DATA - 1 : 0]   datoA                                           ;
    reg                     valid                                           ;
    
    reg  [2:0]              next_state                                      ;
    reg  [1:0]              next_done_counter                               ;
    reg  [5:0]              type_reg                                        ;
    reg                     next_valid                                      ;
    reg  [NB_DATA - 1 : 0]  next_datoA                                      ;
    reg  [NB_DATA - 1 : 0]  next_datoB                                      ;
    reg  [NB_OP - 1 : 0  ]  next_op                                         ;
    wire signed [NB_DATA - 1 : 0]  leds_reg                                 ;


    always @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            state <= IDLE                                                   ;
            done_counter <= 0                                               ;
            valid <= 0                                                      ;
            datoA <= 0                                                      ;
            datoB <= 0                                                      ;
            op <= 0                                                         ;
        end else begin              
            state <= next_state                                             ;
            done_counter <= next_done_counter                               ;
            valid <= next_valid                                             ;
            datoA <= next_datoA                                             ;
            datoB <= next_datoB                                             ;
            op <= next_op                                                   ;

        end
    end

    // state machine
    always @(*) begin
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
                        if(type_reg == DATOA) begin                 
                            next_datoA = i_rx                               ;
                        end                         
                        else if(type_reg == DATOB) begin                            
                            next_datoB = i_rx                               ;
                        end                         
                        else if (type_reg== OP) begin                           
                            next_op = i_rx[NB_OP-1:0]                       ;
                            next_valid = 1                                  ;
                        end
                    
                    next_done_counter =  1                                  ;
                end
                next_state = (done_counter) ? STOP : PARSE                  ;
                //next_done_counter = 0                                       ;  
            end
            STOP: begin
                next_state = IDLE                                           ;
                next_done_counter = 0                                       ;
                next_valid = 0                                              ;
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
    assign o_data = leds_reg;

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

endmodule