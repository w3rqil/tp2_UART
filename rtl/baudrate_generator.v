module baudrate_generator
#(
    parameter BAUD_RATE = 19200,
    parameter CLK_FREQ = 50_000_000,
    parameter OVERSAMPLING = 16
   // parameter NB_COUNTER = 8

)(
    input   wire clk                                                    ,
    input   wire i_rst_n                                                ,
    output  wire o_tick                                                   //! tick que se genera cada NC_PER_TICK

);
localparam NC_PER_TICK = CLK_FREQ / BAUD_RATE / OVERSAMPLING;
localparam NB_COUNTER = clogb2(NC_PER_TICK - 1);
reg [NB_COUNTER-1:0] counter                                            ;

always @(posedge clk or negedge i_rst_n) begin
    if(!i_rst_n) begin 
        counter <= {NB_COUNTER {1'b0}}                                  ;
    end else begin
        if(counter == NC_PER_TICK) counter <= {NB_COUNTER {1'b0}}       ;
        else                       counter <= counter + 1               ;
    end
end

assign o_tick = (counter == NC_PER_TICK)                               ;

function integer clogb2;
    input integer value;
    for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
      // divide por dos
      value = value >> 1;
    end
  endfunction
  
endmodule