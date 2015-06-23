/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores54 DSP, CPU                                       ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
				
//
// NOTE: Read the pipeline information for the CMPS instruction
//

//
// Xilinx Virtex-E WC: 41 CLB slices @ 130MHz
//
									 
//  CVS Log														     
//																     
//  $Id: oc54_cpu.v,v 1.1.1.1 2002-04-10 09:34:41 rherveille Exp $														     
//																     
//  $Date: 2002-04-10 09:34:41 $														 
//  $Revision: 1.1.1.1 $													 
//  $Author: rherveille $													     
//  $Locker:  $													     
//  $State: Exp $														 
//																     
// Change History:												     
//               $Log: not supported by cvs2svn $											 
																
`include "timescale.v"

module oc54_cpu (
	clk_i, 
	ena_mac_i, ena_alu_i, ena_bs_i, ena_exp_i,
	ena_treg_i, ena_acca_i, ena_accb_i,

	// mac
	mac_sel_xm_i, mac_sel_ym_i, mac_sel_ya_i,
	mac_xm_sx_i, mac_ym_sx_i,	mac_add_sub_i,

	// alu
	alu_inst_i, alu_sel_i, alu_doublet_i,

	// bs
	bs_sel_i, bs_selo_i, l_na_i,
	cssu_sel_i, is_cssu_i,

	// 
	exp_sel_i, treg_sel_i, 
	acca_sel_i, accb_sel_i,

	// common
	pb_i, cb_i, db_i,
	bp_a_i, bp_b_i,

	ovm_i, frct_i, smul_i, sxm_i, c16_i, rnd_i,
	c_i, tc_i,
	asm_i, imm_i,

	// outputs
	c_alu_o, c_bs_o, tc_cssu_o, tc_alu_o,
	ovf_a_o, zf_a_o, ovf_b_o, zf_b_o,
	trn_o, eb_o
	);

//
// parameters
//

//
// inputs & outputs
//
input         clk_i;
input         ena_mac_i, ena_alu_i, ena_bs_i, ena_exp_i;
input         ena_treg_i, ena_acca_i, ena_accb_i;
input  [ 1:0] mac_sel_xm_i, mac_sel_ym_i, mac_sel_ya_i;
input         mac_xm_sx_i, mac_ym_sx_i, mac_add_sub_i;
input  [ 6:0] alu_inst_i;
input  [ 1:0] alu_sel_i;
input         alu_doublet_i;
input  [ 1:0] bs_sel_i, bs_selo_i;
input         l_na_i;
input         cssu_sel_i, is_cssu_i;
input         exp_sel_i, treg_sel_i;
input  [ 1:0] acca_sel_i, accb_sel_i;
input  [15:0] pb_i, cb_i, db_i;
input         bp_a_i, bp_b_i;
input         ovm_i, frct_i, smul_i, sxm_i;
input         c16_i, rnd_i, c_i, tc_i, asm_i, imm_i;
output        c_alu_o, c_bs_o, tc_cssu_o, tc_alu_o;
output        ovf_a_o, zf_a_o, ovf_b_o, zf_b_o;
output [15:0] trn_o, eb_o;

//
// variables
//

wire [39:0] acc_a, acc_b, bp_ar, bp_br;
wire [39:0] mac_result, alu_result, bs_result;
wire [15:0] treg;
wire [ 5:0] exp_result;

//
// module body
//

	//
	// instantiate MAC
	oc54_mac cpu_mac(
		.clk(clk_i),             // clock input
		.ena(ena_mac_i),         // MAC clock enable input
		.a(acc_a),               // accumulator A input
		.b(acc_b),               // accumulator B input
		.t(treg),                // TREG input
		.p(pb_i),                // Program Data Bus input
		.c(cb_i),                // Coefficient Data Bus input
		.d(db_i),                // Data Bus input
		.sel_xm(mac_sel_xm_i),   // select multiplier-X input
		.sel_ym(mac_sel_ym_i),   // select muliplier-Y input
		.sel_ya(mac_sel_ya_i),   // select adder-Y input
		.bp_a(bp_a_i),           // bypass accumulator A select input
		.bp_b(bp_b_i),           // bypass accumulator B select input
		.bp_ar(bp_ar),           // bypass accumulator A input
		.bp_br(bp_br),           // bypass accumulator B input
		.xm_s(mac_xm_sx_i),      // sign extend multiplier x-input
		.ym_s(mac_ym_sx_i),      // sign extend multiplier y-input
		.ovm(ovm_i),             // overflow mode input
		.frct(frct_i),           // fractional mode input
		.smul(smul_i),           // saturate on multiply input
		.add_sub(mac_add_sub_i), // add/subtract input
		.result(mac_result)      // MAC result output
	);

	//
	// instantiate ALU
	oc54_alu cpu_alu(
		.clk(clk_i),             // clock input
		.ena(ena_alu_i),         // ALU clock enable input
		.inst(alu_inst_i),       // ALU instruction
		.seli(alu_sel_i),        // ALU x-input select
		.doublet(alu_doublet_i), // double t {treg, treg}
		.a(acc_a),               // accumulator A input
		.b(acc_b),               // accumulator B input
		.s(bs_result),           // barrel shifter result input
		.t(treg),                // TREG input
		.cb(cb_i),               // Coefficient Data Bus input
		.bp_a(bp_a_i),           // bypass accumulator A select input
		.bp_b(bp_b_i),           // bypass accumulator B select input
		.bp_ar(bp_ar),           // bypass accumulator A input
		.bp_br(bp_br),           // bypass accumulator B input
		.c16(c16_i),             // c16 (double 16/long-word) input
		.sxm(sxm_i),             // sign extend mode input
		.ci(c_i),                // carry input
		.tci(tc_i),              // test/control flag input
		.co(c_alu_o),            // ALU carry output
		.tco(tc_alu_o),          // ALU test/control flag output
		.result(alu_result)      // ALU result output
	);

	//
	// instantiate barrel shifter
	oc54_bshft cpu_bs(
		.clk(clk_i),             // clock input
		.ena(ena_bs_i),          // BS clock enable input
		.seli(bs_sel_i),         // BS operand select input
		.a(acc_a),               // accumulator A input
		.b(acc_b),               // accumulator B input
		.cb(cb_i),               // Coefficient Data Bus input
		.db(db_i),               // Data Bus input
		.bp_a(bp_a_i),           // bypass accumulator A select input
		.bp_b(bp_b_i),           // bypass accumulator B select input
		.bp_ar(bp_ar),           // bypass accumulator A input
		.bp_br(bp_br),           // bypass accumulator B input
		.selo(bs_selo_i),        // BS operator select input
		.t(treg),                // TREG input
		.asm(asm_i),             // Accumulator Shift Mode input
		.imm(imm_i),             // Opcode Immediate input
		.l_na(l_na_i),           // BS logical/arithmetic shift mode input
		.sxm(sxm_i),             // sign extend mode input
		.co(c_bs_o),             // BS carry output (1 cycle ahead)
		.result(bs_result)       // BS result output
	);

	// instantiate Compare Select Store Unit
	oc54_cssu cpu_cssu(
		.clk(clk_i),             // clock input
		.ena(ena_bs_i),          // BS/CSSU clock enable input
		.sel_acc(cssu_sel_i),    // CSSU accumulator select input
		.a(acc_a),               // accumulator A input
		.b(acc_b),               // accumulator B input
		.s(bs_result),           // BarrelShifter result input
		.is_cssu(is_cssu_i),     // CSSU/NormalShift operation
		.tco(tc_cssu_o),         // test/control flag output
		.trn(trn_o),             // Transition register output
		.result(eb_o)            // Result Data Bus output
	);

	//
	// instantiate Exponent Encoder
	oc54_exp cpu_exp_enc(
		.clk(clk_i),             // clock input
		.ena(ena_exp_i),         // Exponent Encoder clock enable input
		.sel_acc(exp_sel_i),     // ExpE. accumulator select input
		.a(acc_a),               // accumulator A input
		.b(acc_b),               // accumulator B input
		.bp_a(bp_a_i),           // bypass accumulator A select input
		.bp_b(bp_b_i),           // bypass accumulator B select input
		.bp_ar(bp_ar),           // bypass accumulator A input
		.bp_br(bp_br),           // bypass accumulator B input
		.result(exp_result)      // Exponent Encoder result output
	);
	
	//
	// instantiate Temporary Register
	oc54_treg cpu_treg(
		.clk(clk_i),             // clock input
		.ena(ena_treg_i),        // treg clock enable input
		.we(1'b1),               // treg write enable input
		.seli(treg_sel_i),       // treg select input
		.exp(exp_result),        // Exponent Encoder Result input
		.d(db_i),                // Data Bus input
		.result(treg)            // TREG
	);

	//
	// instantiate accumulators
	oc54_acc cpu_acc_a(
		.clk(clk_i),             // clock input
		.ena(ena_acca_i),        // accumulator A clock enable input
		.seli(acca_sel_i),       // accumulator A select input      
		.we(1'b1),               // write enable input
		.a(acc_a),               // accumulator A input
		.b(acc_b),               // accumulator B input
		.alu(alu_result),        // ALU result input
		.mac(mac_result),        // MAC result input
		.ovm(ovm_i),             // overflow mode input
		.rnd(rnd_i),             // mac-rounding input
		.zf(zf_a_o),             // accumulator A zero flag output
		.ovf(ovf_a_o),           // accumulator A overflow flag output
		.bp_result(bp_ar),       // bypass accumulator A output
		.result(acc_a)           // accumulator A output
	);
	
	oc54_acc cpu_acc_b(
		.clk(clk_i),             // clock input
		.ena(ena_accb_i),        // accumulator B clock enable input
		.seli(accb_sel_i),       // accumulator B select input      
		.we(1'b1),               // write enable input
		.a(acc_a),               // accumulator A input
		.b(acc_b),               // accumulator B input
		.alu(alu_result),        // ALU result input
		.mac(mac_result),        // MAC result input
		.ovm(ovm_i),             // overflow mode input
		.rnd(rnd_i),             // mac-rounding input
		.zf(zf_b_o),             // accumulator B zero flag output
		.ovf(ovf_b_o),           // accumulator B overflow flag output
		.bp_result(bp_br),       // bypass accumulator B output
		.result(acc_b)           // accumulator B output
	);
endmodule

