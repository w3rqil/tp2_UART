module baudrate_generator
#(
    parameter BAUD_RATE = 19200,                                        //! Velocidad de transmision
    parameter CLK_FREQ = 50_000_000,                                    //! Frecuencia del reloj
    parameter OVERSAMPLING = 16                                         //! Oversampling
   // parameter NB_COUNTER = 8

)(
    input   wire clk                                                    , //! Reloj
    input   wire i_rst_n                                                , //! Reset
    output  wire o_tick                                                   //! tick que se genera cada NC_PER_TICK

);
localparam NC_PER_TICK = CLK_FREQ / BAUD_RATE / OVERSAMPLING;           //! Numero de ciclos por tick
localparam NB_COUNTER = clogb2(NC_PER_TICK - 1);                        //! Numero de bits del contador
reg [NB_COUNTER-1:0] counter                                            ; //! Contador

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