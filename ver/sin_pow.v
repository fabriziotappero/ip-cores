/*
	SQmusic

  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org

*/

`timescale 1ns/1ps

module sin_pow;

reg clk, reset_n;

parameter fnumber = 11'h1;
parameter block   =  3'h0;
parameter multiple=  4'h1;

reg [10:0] phase;
reg [3:0] clk2;

initial begin
  $dumpvars(0,sin_pow);
  $dumpon;
  reset_n = 0;
  #10 reset_n = 1;
  #20 reset_n = 0;
  #1000 reset_n=1;
  $display("SOUND START");  
end


always begin
  clk = 0;
  forever #(400) clk = ~clk & reset_n;
end

always @(posedge clk or negedge reset_n) begin
  if( !reset_n)
    clk2 <= 2'b0;
  else
    clk2 <= clk2+1'b1;
end

always @(posedge clk2[3] or negedge reset_n) begin
  if( !reset_n)
    phase<=11'b0;
  else begin
    phase <= phase+1;  
    $display("%d, %d, %d", phase, sin_log, linear );
    if( phase[10] ) $finish;
  end
end

wire [12:0] sin_log, linear;

sq_sin sin(
  .clk     (clk2[3]),  // slow clock
  .reset_n (reset_n), 
  .phase   (phase[9:0]),
  .val     (sin_log) );
  
sq_pow pow(
  .clk     (clk), 
  .reset_n (reset_n), 
  .rd_n    ( 1'b0 ),
  .x       (sin_log),
  .y       (linear) );

// always #(1e9/44100) $display("%d", linear);
endmodule
