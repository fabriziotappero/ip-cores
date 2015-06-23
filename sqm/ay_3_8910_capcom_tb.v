`timescale 1ns / 1ps
module ay_3_8910_capcom_tb;

reg reset_n, clk, int_n, sound_clk;
reg [7:0] data;
reg wr_n, cs_n, adr;
parameter dump_text = 1; // set to 1 to dump data to use log2wav later

initial begin
/*    $dumpfile("dump.lxt");
  $dumpvars(1,pwm0);
  $dumpvars(1,pwm1);*/
//		$dumpvars();
//    $dumpon;
	$shm_open( "ay_3_8910_capcom_tb.shm");
	$shm_probe( ay_3_8910_capcom_tb, "ACTFS" );
  reset_n=0;
	data=0;
	wr_n=1;
	cs_n=1;
	adr=0;
  #1500 reset_n=1;
	// write 201 to register 15 
	adr=0;
	data=8'h3F;
	wr_n=0;
	cs_n=0;
	#668
	data=201;
	adr=1;
	#668
	// write 134 to register 4 
	#668
	adr=0;
	data=8'h04;
	wr_n=0;
	cs_n=0;
	#668
	data=134;
	adr=1;
	#668
	// write 63 to register 12
	#668
	adr=0;
	data=12;
	wr_n=0;
	cs_n=0;
	#668
	data= 63;
	adr=1;
	#668
	wr_n=1;
	data=0;
	#700
	$finish;	
end    

always begin // main clock
  clk=0;
  forever clk = #167 ~clk;
end

always begin // sound clock
  sound_clk=0;
  forever sound_clk = #334 ~sound_clk;
end


AY_3_8910_capcom #(1,0) ay( .reset_n(reset_n), .clk(clk), // CPU clock
	.sound_clk(sound_clk), // normally slower than the CPU clock
  .din(data), .adr(adr), .wr_n(wr_n), .cs_n(cs_n), // chip select
  .A(A),.B(B),.C(C) // channel outputs
);

endmodule
