//
//
//

`timescale 10ps/1ps


module camera_link_clk
(
  input             clk_in,

  output reg [3:0]  clk_7x_index,
  output            clk_out_7x,
  output            clock_good,

  input             reset
);

  // --------------------------------------------------------------------
  //
  clock_mult
    #( .MULT(7) )
    clk_out_7x_i
    (
      .clock_in(clk_in),
      .clock_out(clk_out_7x),
      .clock_good(clock_good),

      .reset(reset)
    );


  // --------------------------------------------------------------------
  //
  wire delayed_clk_in;

  assign #1 delayed_clk_in = clk_in;

  wire clk_in_rise = (delayed_clk_in == 1'b0) & (clk_in == 1'b1);

  always @(posedge clk_out_7x)
    begin
      if(clk_in_rise)
        clk_7x_index <= 5;
      else if( clk_7x_index >= 6 )
        clk_7x_index <= 0;
      else
        clk_7x_index <= clk_7x_index + 1;
    end


endmodule



