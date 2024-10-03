module uart_interface
#(
    NB_DATA  = 8                                                    ,
    NB_STOP  = 16 , //stops at 16 count                               
    NB_OP    = 6
)(
    input       wire                            clk                 ,
    input       wire        [NB_DATA - 1 : 0]   i_rx                ,
    input       wire                            i_rxDone            ,
    input       wire                            i_rst_n             ,     
    output      wire        [NB_DATA - 1 : 0]   o_data
);

    reg [5:0]               state                                           ;
    reg [1:0]               done_counter                                    ;
    reg [NB_OP   - 1 : 0]   op                                              ;
    reg [NB_DATA - 1 : 0]   datoB                                           ;
    reg [NB_DATA - 1 : 0]   datoA                                           ;
    reg                     valid                                           ;
    
    reg  [5:0]              next_state                                      ;
    reg  [1:0]              next_done_counter                               ;
    reg  [5:0]              type_reg                                        ;
    reg                     next_valid                                      ;
    reg  [NB_DATA - 1 : 0]  next_datoA                                      ;
    reg  [NB_DATA - 1 : 0]  next_datoB                                      ;
    reg  [NB_OP - 1 : 0  ]  next_op                                         ;
    wire signed [NB_DATA - 1 : 0]  leds_reg                                        ;


    localparam [5:0]
                    IDLE   =  000001,
                    PARSER =  000010,
                    DATOA  =  000100,
                    DATOB  =  001000,
                    OP     =  010000,
                    STOP   =  100000;

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
                    next_state = PARSER                                     ;
                    next_done_counter = done_counter + 1                    ;
                    type_reg = i_rx[5:0]                                         ;

                end else begin                  
                    next_state = IDLE                                       ;
                    next_done_counter = 0                                   ;
                end
                
            end
            PARSER: begin
                next_valid = 0                                              ;
                if(i_rxDone) begin                          
                    case(type_reg)                          
                        DATOA: begin                            
                            next_datoA = i_rx                               ;
                        end                         
                        DATOB: begin                            
                            next_datoB = i_rx                               ;
                        end                         
                        OP: begin                           
                            next_op = i_rx                                  ;
                            next_valid = 1                                  ;
                        end
                    endcase
                    next_done_counter = done_counter + 1                    ;
                end
                next_state = (done_counter == 2) ? STOP : PARSER            ;
                //next_done_counter = 0                                       ;  
            end
            STOP: begin
                next_state = IDLE                                          ;
                next_done_counter = 0                                           ;
                next_valid = 0                                                  ;
                next_datoA = 0                                                  ;
                next_datoB = 0                                                  ;
                next_op = 0                                                     ;                
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
        .i_operation    (operation  ),
        .o_leds         (leds_reg   )
    );

endmodule