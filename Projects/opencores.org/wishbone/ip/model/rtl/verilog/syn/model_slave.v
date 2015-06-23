//////////////////////////////////////////////////////////////////////
////                                                              ////
////  wb_slave_model                                              ////
////                                                              ////

module model_slave
#( parameter dwidth = 32,
   parameter awidth = 32
 )(
  input wire                  clk, 
  input wire                  reset,

  input  wire [awidth   -1:0]  adr,
  input  wire [dwidth   -1:0]  dout,
  input  wire                  cyc, 
  input  wire                  stb,
  input  wire                  we,
  input  wire [dwidth/8 -1:0]  sel,

  output  reg [dwidth   -1:0] din,
  output  reg                 ack, 
  output  reg                 err, 
  output  reg                 rty
);







always@(posedge clk)
  if(reset)
    begin
    din <= {dwidth{1'b0}};
    ack <= (cyc && stb);
    err <= 1'b0;
    rty <= 1'b0;
    end



endmodule
