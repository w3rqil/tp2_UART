module baudrate_generator
#(
    NC_PER_TICK = 163,  
    NB_COUNTER = 8

)(
    input   wire clk                                                    ,
    input   wire i_rst_n                                                ,
    output  wire o_tick                                                   //! tick que se genera cada NC_PER_TICK

);

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
endmodule