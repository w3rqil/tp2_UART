module top 
(              
    input   wire    clk                     ,
    input   wire    i_rst_n                 ,   
    input   wire    i_rx                    ,
   output    wire    o_tx
);
    localparam  NB_DATA = 8                   ;
    localparam  NB_STOP = 16                  ;
    localparam  NB_OP   = 6                   ;
    localparam  BAUD_RATE = 19200             ;
    localparam  CLK_FREQ = 50_000_000         ;
    localparam  OVERSAMPLING = 16             ;
    // baud rate generator
    wire tick;
    // interface2UART
    wire                    rxDone          ;
    wire                    txDone          ;
//   wire                    txStart         ;
    wire [NB_DATA - 1 : 0]  data_RX2i       ;
//    wire [NB_DATA - 1 : 0]  data_i2TX       ;

    wire  tx;
    baudrate_generator #(
        .BAUD_RATE  (BAUD_RATE      ),
        .CLK_FREQ   (CLK_FREQ       ),
        .OVERSAMPLING(OVERSAMPLING  )
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
        .i_data     (i_rx             ), //???????????????????????????????????????
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
        .i_start_tx (rxDone         ),
        .i_data     (data_RX2i      ),
        .o_txdone   (txDone         ),
        .o_data     (tx           ) //???????????????????????????????????????

    );
    assign o_tx = tx;

endmodule