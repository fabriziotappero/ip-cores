/*
	SQmusic

  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org

*/

`timescale 1ns/1ps

module sq_opn_basic;

reg clk, reset_n;
reg [6:0] gain;
wire signed [13:0] linear;

parameter fnumber = 11'h40E;
parameter block   =  3'h4;
parameter multiple=  4'h1;

initial begin
  $dumpvars(0,sq_opn_basic);
  $dumpon;
  reset_n = 0;
  gain = 7'd0;
  #300 reset_n=1;
  $display("SOUND START");
  #0.01e9
  forever #0.01e9 begin
    if( gain == 7'h7F ) 
      $finish;
    else
      gain <= gain + 1;
//    if( $realtime > 64*0.01e9 ) $finish;
  end
//  $finish;
end

always begin
  clk = 0;
  forever #(125/2) clk = ~clk & reset_n;
end

sq_slot slot(
	.clk     (clk),
	.reset_n (reset_n),
	.fnumber (fnumber),
	.block   (block),
  .multiple(multiple),
  .totallvl(gain),
  .linear  (linear)
);

//always #(1e9/44100) $display("%d", linear);
	

endmodule
