/*
	SQmusic
	logarithmic PWM controller to use with SQMUSIC
  Version 0.1, tested on simulation only with Capcom's 1942

  (c) Jose Tejada Gomez, 11th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org

*/

// Compile with: 
// iverilog sqm_pwm_1_tb.v sqm_pwm.v -s sqm_pwm_1_tb -o sqm_pwm_1_tb

`timescale 1ns/1ps
module sqm_pwm_1_tb;

reg clk;
always begin
  clk=0;
  #10 clk <= ~clk;
end

reg [3:0]A;
always begin
  A=0;
  #5000 A <= A+1;
end

reg reset_n;
initial begin
  $dumpvars();
  $dumpon;
  reset_n=0;
  #15 reset_n=1;
  #80000 $finish;  
end

SQM_PWM_1 apwm( .clk(clk), .reset_n(reset_n), .din(A), .pwm(y_a) );

endmodule
