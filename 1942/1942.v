/*
	1942 simple board setup in order to test SQMUSIC.
	
	Requirements:
		  TV80, Z80 Verilog module
		 	Dump of Z80 ROM from 1942 board

  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org

*/

`timescale 1ns / 1ps

module sound1942;
// inputs to Z80
reg reset_n, clk, int_n, sound_clk;
parameter dump_text = 1; // set to 1 to dump data to use log2wav later
parameter pwm_sound=1;

initial begin
/*    $dumpfile("dump.lxt");
  $dumpvars(1,pwm0);
  $dumpvars(1,pwm1);*/
//		$dumpvars();
//    $dumpon;
//		$shm_open("1942.shm");
//	$shm_probe( sound1942, "ACTFS" );
  reset_n=0;
  #1500 reset_n=1;
	$display("1942 START");
	// change finish time depending on song
//#3000 $finish;
   #6e9 $finish;
end    

always begin // main clock
  clk=0;
  forever clk = #167 ~clk;
end

always begin // sound clock
  sound_clk=0;
  forever sound_clk = #334 ~sound_clk;
end

parameter int_low_time=167*2*80;

always begin // interrupt clock
  int_n=1;
  forever begin
		#(4166667-int_low_time) int_n=0; // 240Hz
		//$display("IRQ request @ %t us",$time/1e6);
		#(int_low_time) int_n=1;
	end
end


wire [3:0] ay0_a, ay0_b, ay0_c, ay1_a, ay1_b, ay1_c;
computer_1942 #(0) game( .clk(clk), .sound_clk(sound_clk),  
  .int_n(int_n), .reset_n(reset_n), 
  .ay0_a(ay0_a), .ay0_b(ay0_b), .ay0_c(ay0_c),
  .ay1_a(ay1_a), .ay1_b(ay1_b), .ay1_c(ay1_c) );

if ( pwm_sound ) begin // PWM OUTPUT
	reg vhf_clk;
	always begin
		vhf_clk=0;
		forever begin
	  	if( vhf_clk && dump_text ) begin
	    	$display("%d, %d, %d, %d, %d, %d",
	      	pwm0_a, pwm0_b, pwm0_c, pwm1_a, pwm1_b, pwm1_c );
	  	end
	  	#10 vhf_clk <= ~vhf_clk; // 50MHz
		end
	end

	SQM_PWM_1 a0pwm( .clk(vhf_clk), .reset_n(reset_n), .din(ay0_a), .pwm(pwm0_a) );
	SQM_PWM_1 b0pwm( .clk(vhf_clk), .reset_n(reset_n), .din(ay0_b), .pwm(pwm0_b) );
	SQM_PWM_1 c0pwm( .clk(vhf_clk), .reset_n(reset_n), .din(ay0_c), .pwm(pwm0_c) );

	SQM_PWM_1 a1pwm( .clk(vhf_clk), .reset_n(reset_n), .din(ay1_a), .pwm(pwm1_a) );
	SQM_PWM_1 b1pwm( .clk(vhf_clk), .reset_n(reset_n), .din(ay1_b), .pwm(pwm1_b) );
	SQM_PWM_1 c1pwm( .clk(vhf_clk), .reset_n(reset_n), .din(ay1_c), .pwm(pwm1_c) );
end
else begin // LINEAR OUTPUT
	wire [15:0] amp0_y, amp1_y;
	SQM_AMP amp0( .A(ay0_a), .B(ay0_b), .C(ay0_c), .Y( amp0_y ));
	SQM_AMP amp1( .A(ay1_a), .B(ay1_b), .C(ay1_c), .Y( amp1_y ));
	always #22676 begin // 44.1kHz sample	
		$display("%d", amp0_y*10 ); 
		$display("%d", amp1_y *10); 		
	end
end
endmodule


