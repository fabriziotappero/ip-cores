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
// CREATED		"Sun Oct 19 14:48:51 2014"

module alu_flags(
	ctl_flags_oe,
	ctl_flags_bus,
	ctl_flags_alu,
	alu_sf_out,
	alu_yf_out,
	alu_xf_out,
	ctl_flags_nf_set,
	alu_zero,
	shift_cf_out,
	alu_core_cf_out,
	daa_cf_out,
	ctl_flags_cf_set,
	ctl_flags_cf_cpl,
	pf_sel,
	ctl_flags_cf_we,
	ctl_flags_sz_we,
	ctl_flags_xy_we,
	ctl_flags_hf_we,
	ctl_flags_pf_we,
	ctl_flags_nf_we,
	ctl_flags_cf2_we,
	ctl_flags_hf_cpl,
	ctl_flags_use_cf2,
	ctl_flags_hf2_we,
	ctl_flags_nf_clr,
	ctl_alu_zero_16bit,
	clk,
	ctl_flags_cf2_sel,
	flags_sf,
	flags_zf,
	flags_hf,
	flags_pf,
	flags_cf,
	flags_nf,
	flags_cf_latch,
	flags_hf2,
	db
);


input wire	ctl_flags_oe;
input wire	ctl_flags_bus;
input wire	ctl_flags_alu;
input wire	alu_sf_out;
input wire	alu_yf_out;
input wire	alu_xf_out;
input wire	ctl_flags_nf_set;
input wire	alu_zero;
input wire	shift_cf_out;
input wire	alu_core_cf_out;
input wire	daa_cf_out;
input wire	ctl_flags_cf_set;
input wire	ctl_flags_cf_cpl;
input wire	pf_sel;
input wire	ctl_flags_cf_we;
input wire	ctl_flags_sz_we;
input wire	ctl_flags_xy_we;
input wire	ctl_flags_hf_we;
input wire	ctl_flags_pf_we;
input wire	ctl_flags_nf_we;
input wire	ctl_flags_cf2_we;
input wire	ctl_flags_hf_cpl;
input wire	ctl_flags_use_cf2;
input wire	ctl_flags_hf2_we;
input wire	ctl_flags_nf_clr;
input wire	ctl_alu_zero_16bit;
input wire	clk;
input wire	[1:0] ctl_flags_cf2_sel;
output wire	flags_sf;
output wire	flags_zf;
output wire	flags_hf;
output wire	flags_pf;
output wire	flags_cf;
output wire	flags_nf;
output wire	flags_cf_latch;
output reg	flags_hf2;
inout wire	[7:0] db;

reg	flags_xf;
reg	flags_yf;
wire	SYNTHESIZED_WIRE_0;
reg	DFFE_inst_latch_hf;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
reg	SYNTHESIZED_WIRE_38;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_17;
wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_19;
wire	SYNTHESIZED_WIRE_20;
wire	SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_22;
reg	DFFE_inst_latch_sf;
wire	SYNTHESIZED_WIRE_23;
reg	DFFE_inst_latch_pf;
reg	DFFE_inst_latch_nf;
wire	SYNTHESIZED_WIRE_24;
wire	SYNTHESIZED_WIRE_25;
wire	SYNTHESIZED_WIRE_26;
wire	SYNTHESIZED_WIRE_27;
wire	SYNTHESIZED_WIRE_28;
wire	SYNTHESIZED_WIRE_39;
wire	SYNTHESIZED_WIRE_31;
wire	SYNTHESIZED_WIRE_32;
wire	SYNTHESIZED_WIRE_33;
wire	SYNTHESIZED_WIRE_34;
wire	SYNTHESIZED_WIRE_35;
wire	SYNTHESIZED_WIRE_36;
reg	DFFE_inst_latch_cf;
reg	DFFE_inst_latch_cf2;
wire	SYNTHESIZED_WIRE_37;

assign	flags_sf = DFFE_inst_latch_sf;
assign	flags_zf = SYNTHESIZED_WIRE_38;
assign	flags_hf = SYNTHESIZED_WIRE_23;
assign	flags_pf = DFFE_inst_latch_pf;
assign	flags_cf = SYNTHESIZED_WIRE_24;
assign	flags_nf = DFFE_inst_latch_nf;
assign	flags_cf_latch = DFFE_inst_latch_cf;
assign	SYNTHESIZED_WIRE_37 = 0;



assign	SYNTHESIZED_WIRE_27 = ctl_flags_cf_we & SYNTHESIZED_WIRE_0;

assign	SYNTHESIZED_WIRE_10 = db[7] & ctl_flags_bus;

assign	SYNTHESIZED_WIRE_17 = alu_xf_out & ctl_flags_alu;

assign	SYNTHESIZED_WIRE_20 = db[2] & ctl_flags_bus;

assign	SYNTHESIZED_WIRE_19 = pf_sel & ctl_flags_alu;

assign	SYNTHESIZED_WIRE_3 = db[1] & ctl_flags_bus;

assign	SYNTHESIZED_WIRE_23 = DFFE_inst_latch_hf ^ ctl_flags_hf_cpl;

assign	SYNTHESIZED_WIRE_22 = db[0] & ctl_flags_bus;

assign	SYNTHESIZED_WIRE_21 = ctl_flags_alu & alu_core_cf_out;

assign	SYNTHESIZED_WIRE_0 =  ~ctl_flags_cf2_we;

assign	SYNTHESIZED_WIRE_24 = SYNTHESIZED_WIRE_1 ^ ctl_flags_cf_cpl;

assign	SYNTHESIZED_WIRE_2 = alu_sf_out & ctl_flags_alu;

assign	SYNTHESIZED_WIRE_9 = alu_sf_out & ctl_flags_alu;

assign	SYNTHESIZED_WIRE_6 = ctl_flags_nf_set | SYNTHESIZED_WIRE_2 | SYNTHESIZED_WIRE_3;

assign	SYNTHESIZED_WIRE_36 = SYNTHESIZED_WIRE_4 & SYNTHESIZED_WIRE_5;


assign	SYNTHESIZED_WIRE_31 = SYNTHESIZED_WIRE_6 & SYNTHESIZED_WIRE_7;

assign	SYNTHESIZED_WIRE_7 =  ~ctl_flags_nf_clr;

assign	SYNTHESIZED_WIRE_8 =  ~ctl_alu_zero_16bit;

assign	SYNTHESIZED_WIRE_5 = SYNTHESIZED_WIRE_8 | SYNTHESIZED_WIRE_38;

assign	SYNTHESIZED_WIRE_12 = db[6] & ctl_flags_bus;

assign	SYNTHESIZED_WIRE_33 = SYNTHESIZED_WIRE_9 | SYNTHESIZED_WIRE_10;

assign	SYNTHESIZED_WIRE_4 = SYNTHESIZED_WIRE_11 | SYNTHESIZED_WIRE_12;

assign	SYNTHESIZED_WIRE_35 = SYNTHESIZED_WIRE_13 | SYNTHESIZED_WIRE_14;

assign	SYNTHESIZED_WIRE_39 = SYNTHESIZED_WIRE_15 | SYNTHESIZED_WIRE_16;

assign	SYNTHESIZED_WIRE_34 = SYNTHESIZED_WIRE_17 | SYNTHESIZED_WIRE_18;

assign	SYNTHESIZED_WIRE_32 = SYNTHESIZED_WIRE_19 | SYNTHESIZED_WIRE_20;

assign	SYNTHESIZED_WIRE_11 = alu_zero & ctl_flags_alu;

assign	SYNTHESIZED_WIRE_26 = SYNTHESIZED_WIRE_21 | SYNTHESIZED_WIRE_22;

assign	db[7] = ctl_flags_oe ? DFFE_inst_latch_sf : 1'bz;

assign	SYNTHESIZED_WIRE_14 = db[5] & ctl_flags_bus;

assign	db[6] = ctl_flags_oe ? SYNTHESIZED_WIRE_38 : 1'bz;

assign	db[5] = ctl_flags_oe ? flags_yf : 1'bz;

assign	db[4] = ctl_flags_oe ? SYNTHESIZED_WIRE_23 : 1'bz;

assign	db[3] = ctl_flags_oe ? flags_xf : 1'bz;

assign	db[2] = ctl_flags_oe ? DFFE_inst_latch_pf : 1'bz;

assign	db[1] = ctl_flags_oe ? DFFE_inst_latch_nf : 1'bz;

assign	db[0] = ctl_flags_oe ? SYNTHESIZED_WIRE_24 : 1'bz;

assign	SYNTHESIZED_WIRE_13 = alu_yf_out & ctl_flags_alu;

assign	SYNTHESIZED_WIRE_1 = ctl_flags_cf_set | SYNTHESIZED_WIRE_25;

assign	SYNTHESIZED_WIRE_16 = db[4] & ctl_flags_bus;

assign	SYNTHESIZED_WIRE_15 = alu_core_cf_out & ctl_flags_alu;

assign	SYNTHESIZED_WIRE_18 = db[3] & ctl_flags_bus;


always@(posedge clk)
begin
if (SYNTHESIZED_WIRE_27)
	begin
	DFFE_inst_latch_cf <= SYNTHESIZED_WIRE_26;
	end
end


always@(posedge clk)
begin
if (ctl_flags_cf2_we)
	begin
	DFFE_inst_latch_cf2 <= SYNTHESIZED_WIRE_28;
	end
end


always@(posedge clk)
begin
if (ctl_flags_hf_we)
	begin
	DFFE_inst_latch_hf <= SYNTHESIZED_WIRE_39;
	end
end


always@(posedge clk)
begin
if (ctl_flags_hf2_we)
	begin
	flags_hf2 <= SYNTHESIZED_WIRE_39;
	end
end


always@(posedge clk)
begin
if (ctl_flags_nf_we)
	begin
	DFFE_inst_latch_nf <= SYNTHESIZED_WIRE_31;
	end
end


always@(posedge clk)
begin
if (ctl_flags_pf_we)
	begin
	DFFE_inst_latch_pf <= SYNTHESIZED_WIRE_32;
	end
end


always@(posedge clk)
begin
if (ctl_flags_sz_we)
	begin
	DFFE_inst_latch_sf <= SYNTHESIZED_WIRE_33;
	end
end


always@(posedge clk)
begin
if (ctl_flags_xy_we)
	begin
	flags_xf <= SYNTHESIZED_WIRE_34;
	end
end


always@(posedge clk)
begin
if (ctl_flags_xy_we)
	begin
	flags_yf <= SYNTHESIZED_WIRE_35;
	end
end


always@(posedge clk)
begin
if (ctl_flags_sz_we)
	begin
	SYNTHESIZED_WIRE_38 <= SYNTHESIZED_WIRE_36;
	end
end


alu_mux_2	b2v_inst_mux_cf(
	.in0(DFFE_inst_latch_cf),
	.in1(DFFE_inst_latch_cf2),
	.sel1(ctl_flags_use_cf2),
	.out(SYNTHESIZED_WIRE_25));


alu_mux_4	b2v_inst_mux_cf2(
	.in0(alu_core_cf_out),
	.in1(shift_cf_out),
	.in2(daa_cf_out),
	.in3(SYNTHESIZED_WIRE_37),
	.sel(ctl_flags_cf2_sel),
	.out(SYNTHESIZED_WIRE_28));


endmodule
