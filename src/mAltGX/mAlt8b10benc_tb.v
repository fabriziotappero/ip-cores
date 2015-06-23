`define NO_PLI
`timescale 1ns / 1ns

module tb;

initial begin
  $display("***********************************************************");
  $display("title:  tb.demo_enc");
  $display("desc:   demonstration testbench");
  $display("        (c) Altera Inc. ALL RIGHTS RESERVED           ");
  $display("        www.altera.com                                ");
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
reg  enc_idle_ins;
reg  enc_kin;
reg  enc_enable;
reg [7:0] enc_datain;
reg  enc_rdin;
reg  enc_rdforce;

wire  enc_kerr;
wire [9:0] enc_dataout;
wire  enc_valid;
wire  enc_rdout;
wire  enc_rdcascade;
  
mAlt8b10benc mAlt8b10benc(
 .clk (clk) // input 
,.reset_n (reset_n) // input 
,.idle_ins (enc_idle_ins) // input 
,.kin (enc_kin) // input 
,.ena (enc_enable) // input 
,.datain (enc_datain) // input [7:0]
,.rdin (enc_rdin) // input 
,.rdforce (enc_rdforce) // input 
,.kerr (enc_kerr) // output 
,.dataout (enc_dataout) // output [9:0]
,.valid (enc_valid) // output 
,.rdout (enc_rdout) // output 
,.rdcascade (enc_rdcascade) // output 
);

initial begin
	enc_enable = 1;
	enc_rdforce = 0;
	enc_rdin = 0;
	enc_idle_ins = 0;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_101_11100;
	while (!reset_n) @(posedge clk);
	repeat (5)
		@(posedge clk) {enc_kin, enc_datain} <= 9'b1_101_11100;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h8;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h82;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hb2;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hb1;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hc2;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h6a;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h7f;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h93;
	@(posedge clk) {enc_kin, enc_datain} <= 9'ha;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h6e;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h18;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_100_11100;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hfc;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h5;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h2c;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h9b;
	@(posedge clk) {enc_kin, enc_datain} <= 9'he2;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hfe;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hb;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hcd;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h28;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h73;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h9;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hd2;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h93;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h32;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_101_11100;
	@(posedge clk) {enc_kin, enc_datain} <= 9'he9;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hea;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h55;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hde;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hdb;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_111_10111;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h24;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h11;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h67;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h96;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h52;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h47;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h42;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_110_11100;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hfa;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hfc;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hec;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h17;
	@(posedge clk) {enc_kin, enc_datain} <= 9'he3;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_111_11110;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_111_11101;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h5d;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hd2;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h66;
	@(posedge clk) {enc_kin, enc_datain} <= 9'he1;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h56;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h56;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_111_11100;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h2b;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h80;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_011_11100;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h7c;
	@(posedge clk) {enc_kin, enc_datain} <= 9'ha7;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hed;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hc9;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h3a;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_111_11111;
	@(posedge clk) {enc_kin, enc_datain} <= 9'ha0;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h12;
	@(posedge clk) {enc_kin, enc_datain} <= 9'heb;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h91;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h8d;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hc;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h19;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h10;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hb1;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h6c;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_010_11100;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h65;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h80;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h8b;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h30;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h96;
	$display("%0t insert idles", $time);
	enc_idle_ins = 1; enc_enable <= 0;
	repeat (4) @(posedge clk);
	$display("%0t stop inserting idles", $time);
	enc_enable <= 1;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h15;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h7c;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_111_11011;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hc2;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hae;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h9c;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h13;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h0;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_001_11100;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h57;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h4f;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h1f;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hb7;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h73;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hc1;
	@(posedge clk) {enc_kin, enc_datain} <= 9'had;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hea;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_000_1100;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h5a;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h71;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h6d;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_000_11100;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h42;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h27;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h57;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h4d;
	$display("%0t turn off enc_enable", $time);
	enc_enable <= 0;
	repeat (4) @(posedge clk);
	$display("%0t turn on enc_enable", $time);
	enc_enable <= 1;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h46;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h26;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hae;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h9c;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h13;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h0;
	@(posedge clk) {enc_kin, enc_datain} <= 9'b1_001_11100;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h57;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h4f;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h1f;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hb7;
	@(posedge clk) {enc_kin, enc_datain} <= 9'h73;
	@(posedge clk) {enc_kin, enc_datain} <= 9'hf3;
	$display("$$$ Exit status for testbench tb.demo_enc :  TESTBENCH_PASSED ");
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
	$display("%0t enc_enable = %b enc_datain = %x, enc_kin = %b, enc_dataout = %x",
		$time, enc_enable, enc_datain, enc_kin, enc_dataout);
end
endmodule
