`define NO_PLI
`timescale 1ns / 1ps

module tb;

initial begin
  $display("***********************************************************");
  $display("title:  tb.demo_dec");
  $display("desc:   demonstration testbench");
  $display("        (c) Altera Inc. ALL RIGHTS RESERVED           ");
  $display("        www.altera.com                                     ");
  $display("***********************************************************");
  $display("PURPOSE: Demonstrate basic function and provide hookup example.");
  $display("PURPOSE: Note: no error checking is performed.");
  $display("METHOD:  A generator emits several random data and control values.");
  $display("***********************************************************");
end

/**********************************************************************/
// DEFINES AND INCLUDES
/**********************************************************************/

`define TBID "tb.demo_enc"

reg  clk;
reg  reset_n;
reg  dec_idle_del;
reg  dec_enable;
reg [9:0] dec_datain;
reg  dec_rdin;
reg  dec_rdforce;

wire  dec_kerr;
wire [7:0] dec_dataout;
wire  dec_valid;
wire  dec_rdout;
wire  dec_rdcascade;
wire  dec_kout;
wire     dec_rderr;

  
mAlt8b10bdec mAlt8b10bdec(
 .clk (clk) // input 
,.reset_n (reset_n) // input 
,.idle_del (dec_idle_del) // input 
,.ena (dec_enable) // input 
,.datain (dec_datain) // input [9:0]
,.rdforce (dec_rdforce) // input 
,.rdin (dec_rdin) // input 
,.valid (dec_valid) // output 
,.dataout (dec_dataout) // output [7:0]
,.kout (dec_kout) // output 
,.kerr (dec_kerr) // output 
//,.disparity (dec_disparity) // output [1:0]
,.rdout (dec_rdout) // output
,.rderr (dec_rderr) // output 
);

initial begin
	dec_enable = 1;
	dec_rdforce = 0;
	dec_rdin = 0;
	dec_idle_del = 0;
	@(posedge clk)  dec_datain <= 10'h0b9;
	@(posedge clk)  dec_datain <= 10'h0b9;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h358;
	@(posedge clk)  dec_datain <= 10'h2d2;
	@(posedge clk)  dec_datain <= 10'h172;
	@(posedge clk)  dec_datain <= 10'h171;
	@(posedge clk)  dec_datain <= 10'h192;
	@(posedge clk)  dec_datain <= 10'h0ea;
	@(posedge clk)  dec_datain <= 10'h335;
	@(posedge clk)  dec_datain <= 10'h113;
	@(posedge clk)  dec_datain <= 10'h36a;
	@(posedge clk)  dec_datain <= 10'h30e;
	@(posedge clk)  dec_datain <= 10'h34c;
	@(posedge clk)  dec_datain <= 10'h2c3;
	@(posedge clk)  dec_datain <= 10'h21c;
	@(posedge clk)  dec_datain <= 10'h365;
	@(posedge clk)  dec_datain <= 10'h26c;
	@(posedge clk)  dec_datain <= 10'h2e4;
	@(posedge clk)  dec_datain <= 10'h1d2;
	@(posedge clk)  dec_datain <= 10'h1e1;
	@(posedge clk)  dec_datain <= 10'h08b;
	@(posedge clk)  dec_datain <= 10'h18d;
	@(posedge clk)  dec_datain <= 10'h267;
	@(posedge clk)  dec_datain <= 10'h313;
	@(posedge clk)  dec_datain <= 10'h0a9;
	@(posedge clk)  dec_datain <= 10'h1b2;
	@(posedge clk)  dec_datain <= 10'h2d3;
	@(posedge clk)  dec_datain <= 10'h272;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h1e9;
	@(posedge clk)  dec_datain <= 10'h22a;
	@(posedge clk)  dec_datain <= 10'h295;
	@(posedge clk)  dec_datain <= 10'h19e;
	@(posedge clk)  dec_datain <= 10'h1a4;
	@(posedge clk)  dec_datain <= 10'h057;
	@(posedge clk)  dec_datain <= 10'h26b;
	@(posedge clk)  dec_datain <= 10'h0b1;
	@(posedge clk)  dec_datain <= 10'h0c7;
	@(posedge clk)  dec_datain <= 10'h2d6;
	@(posedge clk)  dec_datain <= 10'h2b2;
	@(posedge clk)  dec_datain <= 10'h2b8;
	@(posedge clk)  dec_datain <= 10'h292;
	@(posedge clk)  dec_datain <= 10'h1bc;
	@(posedge clk)  dec_datain <= 10'h21a;
	@(posedge clk)  dec_datain <= 10'h1dc;
	@(posedge clk)  dec_datain <= 10'h22c;
	@(posedge clk)  dec_datain <= 10'h097;
	@(posedge clk)  dec_datain <= 10'h1e3;
	@(posedge clk)  dec_datain <= 10'h3a1;
	@(posedge clk)  dec_datain <= 10'h3a2;
	@(posedge clk)  dec_datain <= 10'h2a2;
	@(posedge clk)  dec_datain <= 10'h1b2;
	@(posedge clk)  dec_datain <= 10'h0e6;
	@(posedge clk)  dec_datain <= 10'h22e;
	@(posedge clk)  dec_datain <= 10'h296;
	@(posedge clk)  dec_datain <= 10'h296;
	@(posedge clk)  dec_datain <= 10'h07c;
	@(posedge clk)  dec_datain <= 10'h24b;
	@(posedge clk)  dec_datain <= 10'h139;
	@(posedge clk)  dec_datain <= 10'h33c;
	@(posedge clk)  dec_datain <= 10'h31c;
	@(posedge clk)  dec_datain <= 10'h178;
	@(posedge clk)  dec_datain <= 10'h04d;
	@(posedge clk)  dec_datain <= 10'h1a9;
	@(posedge clk)  dec_datain <= 10'h25a;
	@(posedge clk)  dec_datain <= 10'h23c;
	@(posedge clk)  dec_datain <= 10'h179;
	@(posedge clk)  dec_datain <= 10'h0b2;
	@(posedge clk)  dec_datain <= 10'h1cb;
	@(posedge clk)  dec_datain <= 10'h131;
	@(posedge clk)  dec_datain <= 10'h2cd;
	@(posedge clk)  dec_datain <= 10'h0ac;
	@(posedge clk)  dec_datain <= 10'h359;
	@(posedge clk)  dec_datain <= 10'h349;
	@(posedge clk)  dec_datain <= 10'h171;
	@(posedge clk)  dec_datain <= 10'h32c;
	@(posedge clk)  dec_datain <= 10'h143;
	@(posedge clk)  dec_datain <= 10'h0e5;
	@(posedge clk)  dec_datain <= 10'h139;
	@(posedge clk)  dec_datain <= 10'h2cb;
	@(posedge clk)  dec_datain <= 10'h249;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h2d6;
	@(posedge clk)  dec_datain <= 10'h095;
	@(posedge clk)  dec_datain <= 10'h0dc;
	@(posedge clk)  dec_datain <= 10'h05b;
	@(posedge clk)  dec_datain <= 10'h1ad;
	@(posedge clk)  dec_datain <= 10'h14e;
	@(posedge clk)  dec_datain <= 10'h11c;
	@(posedge clk)  dec_datain <= 10'h353;
	@(posedge clk)  dec_datain <= 10'h346;
	@(posedge clk)  dec_datain <= 10'h183;
	@(posedge clk)  dec_datain <= 10'h297;
	@(posedge clk)  dec_datain <= 10'h285;
	@(posedge clk)  dec_datain <= 10'h0b5;
	@(posedge clk)  dec_datain <= 10'h157;
	@(posedge clk)  dec_datain <= 10'h313;
	@(posedge clk)  dec_datain <= 10'h191;
	@(posedge clk)  dec_datain <= 10'h14d;
	@(posedge clk)  dec_datain <= 10'h1ea;
	@(posedge clk)  dec_datain <= 10'h12c;
	@(posedge clk)  dec_datain <= 10'h29a;
	@(posedge clk)  dec_datain <= 10'h0f1;
	@(posedge clk)  dec_datain <= 10'h0cd;
	@(posedge clk)  dec_datain <= 10'h0bc;
	@(posedge clk)  dec_datain <= 10'h2ad;
	@(posedge clk)  dec_datain <= 10'h278;
	@(posedge clk)  dec_datain <= 10'h2a8;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h17c;
	@(posedge clk)  dec_datain <= 10'h283;
	@(posedge clk)  dec_datain <= 10'h28d;
	@(posedge clk)  dec_datain <= 10'h2a6;
	@(posedge clk)  dec_datain <= 10'h266;
	@(posedge clk)  dec_datain <= 10'h14e;
	@(posedge clk)  dec_datain <= 10'h2dc;
	@(posedge clk)  dec_datain <= 10'h093;
	@(posedge clk)  dec_datain <= 10'h0b9;
	@(posedge clk)  dec_datain <= 10'h27c;
	@(posedge clk)  dec_datain <= 10'h2a8;
	@(posedge clk)  dec_datain <= 10'h2ba;
	$display("$$$ Exit status for testbench tb.demo_dec :  TESTBENCH_PASSED ");
	$finish;

end

// clock generator (100 MHz)
initial begin
	clk <= 0;
	forever begin
		#10;
		clk = !clk;
	end
end

// reset task
initial begin
	reset_n <= 0;
	repeat (10) @(posedge clk);
	reset_n <= 1;
end

// logging task

always @(posedge clk) begin
	$display("%0t dec_enable = %b dec_datain = %x, dec_kout = %b, dec_dataout = %x",
		$time, dec_enable, dec_datain, dec_kout, dec_dataout);
end
endmodule
