module top 
#(
    NB_DATA = 8                             ,
    NB_STOP = 16                            ,
    NB_OP   = 6                             ,
    NC_PER_TICK = 163                       ,      
    NB_COUNTER = 8              
)(              
    input   wire    clk                     ,
    input   wire    i_rst_n                 ,
    input   wire    i_rx                    ,
    output  wire    o_tx    
);


    // baud rate generator
    wire tick;

    // interface2ALU
    wire                    valid_i2ALU     ;
    wire [NB_DATA - 1 : 0]  datoA_i2ALU     ;
    wire [NB_DATA - 1 : 0]  datoB_i2ALU     ;
    wire [NB_OP   - 1 : 0]  op_i2ALU        ;
    wire [NB_DATA - 1 : 0]  res_i2ALU       ;

    // interface2UART
    wire                    rxDone          ;
    wire                    txDone          ;
    wire                    txStart         ;
    wire [NB_DATA - 1 : 0]  data_RX2i       ;
    wire [NB_DATA - 1 : 0]  data_i2TX       ;


    baudrate_generator #(
        .NC_PER_TICK(NC_PER_TICK    ),
        .NB_COUNTER(NB_COUNTER      )
    ) u_baudRateGen 
    (
        .clk        (clk            ),
        .i_rst_n    (i_rst_n        ),
        .o_tick     (tick           )
    );

    uart_rx #(
        .NB_DATA    (NB_DATA        ),
        .NB_STOP    (NB_STOP        )
    )u_uartRX
    (
        .clk        (clk            ),
        .i_rst_n    (i_rst_n        ),
        .i_tick     (tick           ),
        .i_data     (i_rx           ), //???????????????????????????????????????
        .o_data     (data_RX2i      ),
        .o_rxdone   (rxDone         )
    );

    uart_tx #(
        .NB_DATA    (NB_DATA        ),
        .NB_STOP    (NB_STOP        )
    ) u_uartTX 
    (
        .clk        (clk            ),
        .i_rst_n    (i_rst_n        ),
        .i_tick     (tick           ),
        .i_start_tx (txStart        ),
        .i_data     (data_i2TX      ),
        .o_txdone   (txDone         ),
        .o_data     (o_tx           ) //???????????????????????????????????????

    );

    uart_interface #(
        .NB_DATA    (NB_DATA        ),
        .NB_STOP    (NB_STOP        ),
        .NB_OP      (NB_OP          )
    ) u_interface 
    (
        .clk        (clk            ),
        .i_rx       (data_RX2i      ),
        .i_rxDone   (rxDone         ),
        .i_txDone   (txDone         ),
        .i_rst_n    (i_rst_n        ),
        .o_tx_start (txStart        ),
        .o_data     (data_i2TX      ),

        .o_operation(op_i2ALU       ),
        .o_datoB    (datoB_i2ALU    ),
        .o_datoA    (datoA_i2ALU    ),
        .o_valid    (valid_i2ALU    ),
        .i_result   (res_i2ALU      )

    );

    alu #(
        .NB_DATA(NB_DATA            ),
        .NB_OP  (NB_OP              )
    ) u_ALU (
        .i_valid    (valid_i2ALU    ),
        .i_datoA    (datoA_i2ALU    ),
        .i_datoB    (datoB_i2ALU    ),
        .i_operation(op_i2ALU       ),
        .o_leds     (res_i2ALU      )  
    );

endmodule