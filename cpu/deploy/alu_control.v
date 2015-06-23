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
// CREATED		"Tue Oct 21 20:41:52 2014"

module alu_control(
	alu_shift_db0,
	alu_shift_db7,
	ctl_shift_en,
	alu_low_gt_9,
	alu_high_gt_9,
	alu_high_eq_9,
	ctl_daa_oe,
	ctl_alu_op_low,
	alu_parity_out,
	flags_cf,
	flags_zf,
	flags_pf,
	flags_sf,
	ctl_cond_short,
	alu_vf_out,
	iff2,
	ctl_alu_core_hf,
	ctl_eval_cond,
	repeat_en,
	flags_cf_latch,
	flags_hf2,
	flags_hf,
	ctl_66_oe,
	clk,
	ctl_pf_sel,
	op543,
	alu_shift_in,
	alu_shift_right,
	alu_shift_left,
	shift_cf_out,
	alu_parity_in,
	flags_cond_true,
	daa_cf_out,
	pf_sel,
	alu_op_low,
	alu_core_cf_in,
	db
);


input wire	alu_shift_db0;
input wire	alu_shift_db7;
input wire	ctl_shift_en;
input wire	alu_low_gt_9;
input wire	alu_high_gt_9;
input wire	alu_high_eq_9;
input wire	ctl_daa_oe;
input wire	ctl_alu_op_low;
input wire	alu_parity_out;
input wire	flags_cf;
input wire	flags_zf;
input wire	flags_pf;
input wire	flags_sf;
input wire	ctl_cond_short;
input wire	alu_vf_out;
input wire	iff2;
input wire	ctl_alu_core_hf;
input wire	ctl_eval_cond;
input wire	repeat_en;
input wire	flags_cf_latch;
input wire	flags_hf2;
input wire	flags_hf;
input wire	ctl_66_oe;
input wire	clk;
input wire	[1:0] ctl_pf_sel;
input wire	[2:0] op543;
output wire	alu_shift_in;
output wire	alu_shift_right;
output wire	alu_shift_left;
output wire	shift_cf_out;
output wire	alu_parity_in;
output reg	flags_cond_true;
output wire	daa_cf_out;
output wire	pf_sel;
output wire	alu_op_low;
output wire	alu_core_cf_in;
output wire	[7:0] db;

wire	condition;
wire	[7:0] out;
wire	[1:0] sel;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
reg	DFFE_latch_pf_tmp;
wire	SYNTHESIZED_WIRE_20;
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
wire	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_18;

assign	alu_op_low = ctl_alu_op_low;
assign	daa_cf_out = SYNTHESIZED_WIRE_21;
assign	SYNTHESIZED_WIRE_22 = 0;
assign	SYNTHESIZED_WIRE_18 = 1;



assign	condition = SYNTHESIZED_WIRE_0 ^ SYNTHESIZED_WIRE_1;



assign	db[7] = SYNTHESIZED_WIRE_2 ? out[7] : 1'bz;
assign	db[6] = SYNTHESIZED_WIRE_2 ? out[6] : 1'bz;
assign	db[5] = SYNTHESIZED_WIRE_2 ? out[5] : 1'bz;
assign	db[4] = SYNTHESIZED_WIRE_2 ? out[4] : 1'bz;
assign	db[3] = SYNTHESIZED_WIRE_2 ? out[3] : 1'bz;
assign	db[2] = SYNTHESIZED_WIRE_2 ? out[2] : 1'bz;
assign	db[1] = SYNTHESIZED_WIRE_2 ? out[1] : 1'bz;
assign	db[0] = SYNTHESIZED_WIRE_2 ? out[0] : 1'bz;

assign	alu_shift_right = ctl_shift_en & op543[0];

assign	alu_parity_in = ctl_alu_op_low | DFFE_latch_pf_tmp;

assign	SYNTHESIZED_WIRE_2 = ctl_66_oe | ctl_daa_oe;

assign	sel[0] = op543[1];


assign	out[1] = SYNTHESIZED_WIRE_20;


assign	out[2] = SYNTHESIZED_WIRE_20;


assign	out[5] = SYNTHESIZED_WIRE_21;


assign	out[6] = SYNTHESIZED_WIRE_21;


assign	alu_shift_left = ctl_shift_en & SYNTHESIZED_WIRE_7;

assign	SYNTHESIZED_WIRE_21 = ctl_66_oe | alu_high_gt_9 | flags_cf_latch | SYNTHESIZED_WIRE_8;

assign	SYNTHESIZED_WIRE_9 = flags_hf2 | alu_low_gt_9;

assign	SYNTHESIZED_WIRE_8 = alu_low_gt_9 & alu_high_eq_9;

assign	SYNTHESIZED_WIRE_20 = SYNTHESIZED_WIRE_9 | ctl_66_oe;

assign	SYNTHESIZED_WIRE_0 =  ~op543[0];

assign	sel[1] = op543[2] & SYNTHESIZED_WIRE_10;

assign	SYNTHESIZED_WIRE_12 = alu_shift_db0 & op543[0];

assign	SYNTHESIZED_WIRE_13 = alu_shift_db7 & SYNTHESIZED_WIRE_11;

assign	shift_cf_out = SYNTHESIZED_WIRE_12 | SYNTHESIZED_WIRE_13;

assign	SYNTHESIZED_WIRE_16 = ctl_alu_core_hf & flags_hf;

assign	SYNTHESIZED_WIRE_15 = SYNTHESIZED_WIRE_14 & flags_cf;

assign	alu_core_cf_in = SYNTHESIZED_WIRE_15 | SYNTHESIZED_WIRE_16;

assign	SYNTHESIZED_WIRE_14 =  ~ctl_alu_core_hf;


always@(posedge clk)
begin
if (ctl_eval_cond)
	begin
	flags_cond_true <= condition;
	end
end


alu_mux_4	b2v_inst_cond_mux(
	.in0(flags_zf),
	.in1(flags_cf),
	.in2(flags_pf),
	.in3(flags_sf),
	.sel(sel),
	.out(SYNTHESIZED_WIRE_1));


alu_mux_4	b2v_inst_pf_sel(
	.in0(alu_parity_out),
	.in1(alu_vf_out),
	.in2(iff2),
	.in3(repeat_en),
	.sel(ctl_pf_sel),
	.out(pf_sel));


alu_mux_8	b2v_inst_shift_mux(
	.in0(alu_shift_db7),
	.in1(alu_shift_db0),
	.in2(flags_cf_latch),
	.in3(flags_cf_latch),
	.in4(SYNTHESIZED_WIRE_22),
	.in5(alu_shift_db7),
	.in6(SYNTHESIZED_WIRE_18),
	.in7(SYNTHESIZED_WIRE_22),
	.sel(op543),
	.out(alu_shift_in));


always@(posedge clk)
begin
if (ctl_alu_op_low)
	begin
	DFFE_latch_pf_tmp <= alu_parity_out;
	end
end

assign	SYNTHESIZED_WIRE_7 =  ~op543[0];

assign	SYNTHESIZED_WIRE_11 =  ~op543[0];

assign	SYNTHESIZED_WIRE_10 =  ~ctl_cond_short;


assign	out[3] = 0;
assign	out[7] = 0;
assign	out[0] = 0;
assign	out[4] = 0;

endmodule
