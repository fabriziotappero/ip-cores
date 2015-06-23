`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////////
// 
// 4004 CPU Integration Module
// 
// This file is part of the MCS-4 project hosted at OpenCores:
//      http://www.opencores.org/cores/mcs-4/
// 
// Copyright © 2012 by Reece Pollack <rrpollack@opencores.org>
// 
// These materials are provided under the Creative Commons
// "Attribution-NonCommercial-ShareAlike" Public License. They
// are NOT "public domain" and are protected by copyright.
// 
// This work based on materials provided by Intel Corporation and
// others under the same license. See the file doc/License for
// details of this license.
//
////////////////////////////////////////////////////////////////////////

module i4004(
    input  wire			sysclk,
    input  wire			clk1_pad,
    input  wire			clk2_pad,
    input  wire			poc_pad,
    input  wire			test_pad,
    inout  wire	[3:0]	data_pad,
    output wire			cmrom_pad,
    output wire			cmram0_pad,
    output wire			cmram1_pad,
    output wire			cmram2_pad,
    output wire			cmram3_pad,
    output wire			sync_pad
    );

	// Common BiDir data bus
	wire [3:0]		data;

	// Timing and I/O Board Outputs
	wire			clk1;
	wire			clk2;
	wire			a12;
	wire			a22;
	wire			a32;
	wire			m12;
	wire			m22;
	wire			x12;
	wire			x22;
	wire			x32;
	wire			gate;
	wire			poc;			// Clean POC_PAD
	wire			n0432;			// Clean TEST_PAD

	// Outputs from the Instruction Decode board
	wire			jcn_isz;
	wire			jin_fin;
	wire			jun_jms;
	wire			cn_n;
	wire			bbl;
	wire			jms;
	wire			sc;
	wire			dc;
	wire			sc_m22_clk2;
	wire			fin_fim_src_jin;
	wire			inc_isz_add_sub_xch_ld;
	wire			inc_isz_xch;
	wire			opa0_n;
	wire			cma;
	wire			write_acc_1;
	wire			write_carry_2;
	wire			read_acc_3;
	wire			add_group_4;
	wire			inc_group_5;
	wire			sub_group_6;
	wire			ior;
	wire			iow;
	wire			ral;
	wire			rar;
	wire			ope_n;
	wire			daa;
	wire			dcl;
	wire			inc_isz;
	wire			kbp;
	wire			o_ib;
	wire			tcs;
	wire			xch;
	wire			n0342;
	wire			x21_clk2;
	wire			x31_clk2;
	wire			com_n;

	// Outputs from the ALU board
	wire			acc_0;
	wire			add_0;
	wire			cy_1;
	wire			cmram0;
	wire			cmram1;
	wire			cmram2;
	wire			cmram3;
	wire			cmrom;

	// Instantiate the Timing and I/O board
	timing_io tio_board (
		.sysclk(sysclk), 
		.clk1_pad(clk1_pad), 
		.clk2_pad(clk2_pad), 
		.poc_pad(poc_pad), 
		.ior(ior), 
		.clk1(clk1), 
		.clk2(clk2), 
		.a12(a12), 
		.a22(a22), 
		.a32(a32), 
		.m12(m12), 
		.m22(m22), 
		.x12(x12), 
		.x22(x22), 
		.x32(x32), 
		.gate(gate), 
		.poc(poc), 
		.data(data), 
		.data_pad(data_pad), 
		.test_pad(test_pad), 
		.n0432(n0432), 
		.sync_pad(sync_pad), 
		.cmrom(cmrom), 
		.cmrom_pad(cmrom_pad), 
		.cmram0(cmram0), 
		.cmram0_pad(cmram0_pad), 
		.cmram1(cmram1), 
		.cmram1_pad(cmram1_pad), 
		.cmram2(cmram2), 
		.cmram2_pad(cmram2_pad), 
		.cmram3(cmram3), 
		.cmram3_pad(cmram3_pad)
	);

	// Instantiate the Instruction Decode board
	instruction_decode id_board (
		.sysclk(sysclk), 
		.clk1(clk1), 
		.clk2(clk2), 
		.a22(a22), 
		.m12(m12), 
		.m22(m22), 
		.x12(x12), 
		.x22(x22), 
		.x32(x32), 
		.poc(poc), 
		.n0432(n0432), 
		.data(data), 
		.jcn_isz(jcn_isz), 
		.jin_fin(jin_fin), 
		.jun_jms(jun_jms), 
		.cn_n(cn_n), 
		.bbl(bbl), 
		.jms(jms), 
		.sc(sc), 
		.dc(dc), 
		.sc_m22_clk2(sc_m22_clk2), 
		.fin_fim_src_jin(fin_fim_src_jin), 
		.inc_isz_add_sub_xch_ld(inc_isz_add_sub_xch_ld), 
		.inc_isz_xch(inc_isz_xch), 
		.opa0_n(opa0_n), 
		.acc_0(acc_0), 
		.add_0(add_0), 
		.cy_1(cy_1), 
		.cma(cma), 
		.write_acc_1(write_acc_1), 
		.write_carry_2(write_carry_2), 
		.read_acc_3(read_acc_3), 
		.add_group_4(add_group_4), 
		.inc_group_5(inc_group_5), 
		.sub_group_6(sub_group_6), 
		.ior(ior), 
		.iow(iow), 
		.ral(ral), 
		.rar(rar), 
		.ope_n(ope_n), 
		.daa(daa), 
		.dcl(dcl), 
		.inc_isz(inc_isz), 
		.kbp(kbp), 
		.o_ib(o_ib), 
		.tcs(tcs), 
		.xch(xch), 
		.n0342(n0342), 
		.x21_clk2(x21_clk2), 
		.x31_clk2(x31_clk2), 
		.com_n(com_n)
	);

	// Instantiate the ALU board
	alu alu_board (
		.sysclk(sysclk), 
		.a12(a12), 
		.m12(m12), 
		.x12(x12), 
		.poc(poc), 
		.data(data), 
		.acc_0(acc_0), 
		.add_0(add_0), 
		.cy_1(cy_1), 
		.cma(cma), 
		.write_acc_1(write_acc_1), 
		.write_carry_2(write_carry_2), 
		.read_acc_3(read_acc_3), 
		.add_group_4(add_group_4), 
		.inc_group_5(inc_group_5), 
		.sub_group_6(sub_group_6), 
		.ior(ior), 
		.iow(iow), 
		.ral(ral), 
		.rar(rar), 
		.ope_n(ope_n), 
		.daa(daa), 
		.dcl(dcl), 
		.inc_isz(inc_isz), 
		.kbp(kbp), 
		.o_ib(o_ib), 
		.tcs(tcs), 
		.xch(xch), 
		.n0342(n0342), 
		.x21_clk2(x21_clk2), 
		.x31_clk2(x31_clk2), 
		.com_n(com_n), 
		.cmram0(cmram0), 
		.cmram1(cmram1), 
		.cmram2(cmram2), 
		.cmram3(cmram3), 
		.cmrom(cmrom)
	);

	// Instantiate the Instruction Pointer board
	instruction_pointer ip_board (
		.sysclk(sysclk), 
		.clk1(clk1), 
		.clk2(clk2), 
		.a12(a12), 
		.a22(a22), 
		.a32(a32), 
		.m12(m12), 
		.m22(m22), 
		.x12(x12), 
		.x22(x22), 
		.x32(x32), 
		.poc(poc), 
		.m12_m22_clk1_m11_m12(gate), 
		.data(data), 
		.jcn_isz(jcn_isz), 
		.jin_fin(jin_fin), 
		.jun_jms(jun_jms), 
		.cn_n(cn_n), 
		.bbl(bbl), 
		.jms(jms), 
		.sc(sc), 
		.dc(dc)
	);

	// Instantiate the Scratchpad board
	scratchpad sp_board (
		.sysclk(sysclk), 
		.clk1(clk1), 
		.clk2(clk2), 
		.a12(a12), 
		.a22(a22), 
		.a32(a32), 
		.m12(m12), 
		.m22(m22), 
		.x12(x12), 
		.x22(x22), 
		.x32(x32), 
		.poc(poc), 
		.m12_m22_clk1_m11_m12(gate), 
		.data(data), 
		.sc_m22_clk2(sc_m22_clk2), 
		.fin_fim_src_jin(fin_fim_src_jin), 
		.inc_isz_add_sub_xch_ld(inc_isz_add_sub_xch_ld), 
		.inc_isz_xch(inc_isz_xch), 
		.opa0_n(opa0_n), 
		.sc(sc), 
		.dc(dc)
	);

endmodule
