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





  // Wishbone write cycle
  task wb_write;
    input [awidth -1:0] a;
    input [(dwidth/8) -1:0] s;
    input [dwidth -1:0] d;
    begin
      $display("%t %m cycle %h %h",$realtime,a,d );
      // assert wishbone signal
      adr  <= a;
      dout <= d;
      cyc  <= 1'b1;
      stb  <= 1'b1;
      we   <= 1'b1;
      sel  <= s;
      next(1);
      // wait for acknowledge from slave
      while(~ack) next(1);
      // negate wishbone signals
      cyc  <= 1'b0;
      stb  <= 1'b0;
      adr  <= {awidth{1'b0}};
      dout <= {dwidth{1'b0}};
      we   <= 1'h0;
      sel  <= {dwidth/8{1'b0}};
    end
  endtask
  // Wishbone read cycle
  task wb_read;
    input   [awidth -1:0]  a;
    output  [dwidth -1:0]  d;
    begin
      // assert wishbone signals
      adr  <= a;
      dout <= {dwidth{1'b0}};
      cyc  <= 1'b1;
      stb  <= 1'b1;
      we   <= 1'b0;
      sel  <= {dwidth/8{1'b1}};
      next(1);
      // wait for acknowledge from slave
      while(~ack) next(1);
      $display("%t %m  cycle %h %h",$realtime,a,din );
      // negate wishbone signals
      cyc  <= 1'b0;
      stb  <= 1'b0;
      adr  <= {awidth{1'b0}};
      dout <= {dwidth{1'b0}};
      we   <= 1'h0;
      sel  <= {dwidth/8{1'b0}};
      d    <= din;
    end
  endtask
  // Wishbone compare cycle (read data from location and compare with expected data)
  task wb_cmp;
    input  [awidth-1:0] a;
    input [(dwidth/8) -1:0] s;
    input  [dwidth-1:0] d_exp;
     begin
      // assert wishbone signals
       adr  <= a;
      dout <= {dwidth{1'b0}};
      cyc  <= 1'b1;
      stb  <= 1'b1;
      we   <= 1'b0;
      sel  <= s;
      next(1);
      // wait for acknowledge from slave
      while(~ack) next(1);
      $display("%t %m   check %h %h %h",$realtime,a,din,d_exp );
      if (!(d_exp === din))  cg.fail(" Data compare error");  
      // negate wishbone signals
      cyc  <= 1'b0;
      stb  <= 1'b0;
      adr  <= {awidth{1'b0}};
      dout <= {dwidth{1'b0}};
      we   <= 1'h0;
      sel  <= {dwidth/8{1'b0}};
   end
  endtask
endmodule
