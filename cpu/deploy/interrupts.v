// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 64-Bit"
// VERSION		"Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"
// CREATED		"Sun Nov 09 09:11:22 2014"

module interrupts(
	ctl_iff1_iff2,
	nmi,
	setM1,
	intr,
	ctl_iffx_we,
	ctl_iffx_bit,
	ctl_im_we,
	clk,
	ctl_no_ints,
	nreset,
	db,
	iff1,
	iff2,
	im1,
	im2,
	in_nmi,
	in_intr
);


input wire	ctl_iff1_iff2;
input wire	nmi;
input wire	setM1;
input wire	intr;
input wire	ctl_iffx_we;
input wire	ctl_iffx_bit;
input wire	ctl_im_we;
input wire	clk;
input wire	ctl_no_ints;
input wire	nreset;
input wire	[1:0] db;
output wire	iff1;
output wire	iff2;
output reg	im1;
output reg	im2;
output wire	in_nmi;
output wire	in_intr;

reg	iff_ALTERA_SYNTHESIZED1;
wire	in_intr_ALTERA_SYNTHESIZED;
reg	in_nmi_ALTERA_SYNTHESIZED;
reg	int_armed;
reg	nmi_armed;
wire	test1;
wire	SYNTHESIZED_WIRE_0;
reg	DFFE_instIFF2;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
reg	DFFE_inst44;
wire	SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_17;
wire	SYNTHESIZED_WIRE_19;
wire	SYNTHESIZED_WIRE_20;

assign	iff2 = DFFE_instIFF2;
assign	SYNTHESIZED_WIRE_10 = 1;



assign	SYNTHESIZED_WIRE_2 = ctl_iffx_bit & SYNTHESIZED_WIRE_0;

assign	SYNTHESIZED_WIRE_1 = ctl_iff1_iff2 & DFFE_instIFF2;

assign	SYNTHESIZED_WIRE_16 = SYNTHESIZED_WIRE_1 | SYNTHESIZED_WIRE_2;

assign	SYNTHESIZED_WIRE_17 = ctl_iffx_we | ctl_iff1_iff2;

assign	SYNTHESIZED_WIRE_21 = SYNTHESIZED_WIRE_3 & nreset;

assign	SYNTHESIZED_WIRE_0 =  ~ctl_iff1_iff2;

assign	SYNTHESIZED_WIRE_4 =  ~db[0];

assign	SYNTHESIZED_WIRE_5 =  ~in_nmi_ALTERA_SYNTHESIZED;

assign	SYNTHESIZED_WIRE_20 = db[1] & db[0];

assign	SYNTHESIZED_WIRE_19 = db[1] & SYNTHESIZED_WIRE_4;


assign	in_intr_ALTERA_SYNTHESIZED = SYNTHESIZED_WIRE_5 & DFFE_inst44;

assign	SYNTHESIZED_WIRE_15 = SYNTHESIZED_WIRE_21 & SYNTHESIZED_WIRE_7;

assign	SYNTHESIZED_WIRE_13 = iff_ALTERA_SYNTHESIZED1 & intr;

assign	test1 = setM1 & SYNTHESIZED_WIRE_8;


always@(posedge nmi or negedge SYNTHESIZED_WIRE_9)
begin
if (!SYNTHESIZED_WIRE_9)
	begin
	nmi_armed <= 0;
	end
else
	begin
	nmi_armed <= SYNTHESIZED_WIRE_10;
	end
end

assign	SYNTHESIZED_WIRE_12 = SYNTHESIZED_WIRE_11 & nreset;


always@(posedge clk or negedge nreset)
begin
if (!nreset)
	begin
	in_nmi_ALTERA_SYNTHESIZED <= 0;
	end
else
if (test1)
	begin
	in_nmi_ALTERA_SYNTHESIZED <= nmi_armed;
	end
end


always@(posedge clk or negedge nreset)
begin
if (!nreset)
	begin
	DFFE_inst44 <= 0;
	end
else
if (test1)
	begin
	DFFE_inst44 <= int_armed;
	end
end


always@(posedge clk or negedge SYNTHESIZED_WIRE_12)
begin
if (!SYNTHESIZED_WIRE_12)
	begin
	int_armed <= 0;
	end
else
	begin
	int_armed <= SYNTHESIZED_WIRE_13;
	end
end

assign	SYNTHESIZED_WIRE_9 = SYNTHESIZED_WIRE_14 & nreset;

assign	SYNTHESIZED_WIRE_8 =  ~ctl_no_ints;


always@(posedge clk or negedge SYNTHESIZED_WIRE_15)
begin
if (!SYNTHESIZED_WIRE_15)
	begin
	iff_ALTERA_SYNTHESIZED1 <= 0;
	end
else
if (SYNTHESIZED_WIRE_17)
	begin
	iff_ALTERA_SYNTHESIZED1 <= SYNTHESIZED_WIRE_16;
	end
end


always@(posedge clk or negedge SYNTHESIZED_WIRE_21)
begin
if (!SYNTHESIZED_WIRE_21)
	begin
	DFFE_instIFF2 <= 0;
	end
else
if (ctl_iffx_we)
	begin
	DFFE_instIFF2 <= ctl_iffx_bit;
	end
end


always@(posedge clk or negedge nreset)
begin
if (!nreset)
	begin
	im1 <= 0;
	end
else
if (ctl_im_we)
	begin
	im1 <= SYNTHESIZED_WIRE_19;
	end
end


always@(posedge clk or negedge nreset)
begin
if (!nreset)
	begin
	im2 <= 0;
	end
else
if (ctl_im_we)
	begin
	im2 <= SYNTHESIZED_WIRE_20;
	end
end

assign	SYNTHESIZED_WIRE_3 =  ~in_intr_ALTERA_SYNTHESIZED;

assign	SYNTHESIZED_WIRE_11 =  ~in_intr_ALTERA_SYNTHESIZED;

assign	SYNTHESIZED_WIRE_7 =  ~in_nmi_ALTERA_SYNTHESIZED;

assign	SYNTHESIZED_WIRE_14 =  ~in_nmi_ALTERA_SYNTHESIZED;

assign	iff1 = iff_ALTERA_SYNTHESIZED1;
assign	in_nmi = in_nmi_ALTERA_SYNTHESIZED;
assign	in_intr = in_intr_ALTERA_SYNTHESIZED;

endmodule
