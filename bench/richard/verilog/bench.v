/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores Memory Controller Testbench                      ////
////  Main testbench                                             ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/mem_ctrl/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
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

// ToDo:
// 1) add power-on configuration
// 2) test SSRAM
// 3) test synchronous devices ???
//

//  CVS Log
//
//  $Id: bench.v,v 1.1 2002-03-06 15:10:34 rherveille Exp $
//
//  $Date: 2002-03-06 15:10:34 $
//  $Revision: 1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//

`include "timescale.v"

`define SDRAM_ROWA_HI 12 // row address hi-bit
`define SDRAM_COLA_HI 8  // column address hi-bit

`define BA_MASK    32'h0000_00e0 // base address mask
`define SDRAM1_LOC 32'h0400_0000 // location of sdram1 in address-space
`define SDRAM2_LOC 32'h0800_0000 // location of sdram2 in address-space
`define SRAM_LOC   32'h0C00_0000 // location of srams  in address-space
`define SSRAM_LOC  32'h1000_0000 // location of ssrams in address-space

module bench_top();

	//
	// internal wires
	//
	reg wb_clk;
	reg mc_clk;

	reg  wb_rst;
	wire [31:0] wb_dat_i, wb_dat_o;
	wire [31:0] wb_adr_o;
	wire        wb_cyc_o, wb_stb_o;
	wire [ 3:0] wb_sel_o;
	wire        wb_ack_i, wb_err_i, wb_rty_i;

	wire        wb_mc_stb;

	wire [23:0] mc_adr_o;
	wire [31:0] mc_dq, mc_dq_o;
	wire [ 3:0] mc_dp, mc_dp_o, pbus_o, pbus_i;
	reg  [ 3:0] set_par;
	wire [31:0] par_con;
	reg         sel_par, sel_pbus;
	wire        par_sdram_cs;
	wire        mc_doe_o;
	wire [ 3:0] mc_dqm_o;
	wire        mc_we_o, mc_oe_o;
	wire        mc_ras_o, mc_cas_o, mc_cke_o;
	wire [ 7:0] mc_cs_o;
	wire        mc_pad_oe;
	wire        mc_adsc_o, mc_adv_o, mc_zz_o; // ssram connections

	wire ext_br, ext_bg;

	//
	// hookup modules
	//

	// hookup watch-dog counter
	watch_dog #(1024) wdog (
		.clk(wb_clk),
		.cyc_i(wb_cyc_o),
		.ack_i(wb_ack_i),
		.adr_i(wb_adr_o)
	);

	// hookup external bus-master model
	bm_model ext_bm(
		.br(ext_br),
		.bg(ext_bg),
		.chk(mc_pad_oe)
	);

	// hookup ERR checker
	err_check err_chk(wb_err_i, sel_par);

	// hookup CSn checker
	cs_check cs_chec(mc_cs_o);

	// hookup memory controller
	mc_top dut (
		// wishbone interface
		.clk_i(wb_clk),
		.rst_i(wb_rst),
		.wb_data_i(wb_dat_o),
		.wb_data_o(wb_dat_i),
		.wb_addr_i(wb_adr_o),
		.wb_sel_i(wb_sel_o),
		.wb_we_i(wb_we_o),
		.wb_cyc_i(wb_cyc_o),
		.wb_stb_i(wb_stb_o),
		.wb_ack_o(wb_ack_i),
		.wb_err_o(wb_err_i), 

		// memory controller
		.susp_req_i(1'b0),
		.resume_req_i(1'b0),
		.suspended_o(),
		.poc_o(),
		.mc_clk_i(mc_clk),
		.mc_br_pad_i(ext_br),
		.mc_bg_pad_o(ext_bg),
		.mc_ack_pad_i(1'b0),
		.mc_addr_pad_o(mc_adr_o),
		.mc_data_pad_i(mc_dq),
		.mc_data_pad_o(mc_dq_o),
		.mc_dp_pad_i(pbus_i), // attach parity bus
		.mc_dp_pad_o(mc_dp_o),
		.mc_doe_pad_doe_o(mc_doe_o),
		.mc_dqm_pad_o(mc_dqm_o),
		.mc_oe_pad_o_(mc_oe_o),
		.mc_we_pad_o_(mc_we_o),
		.mc_cas_pad_o_(mc_cas_o),
		.mc_ras_pad_o_(mc_ras_o),
		.mc_cke_pad_o_(mc_cke_o),
		.mc_cs_pad_o_(mc_cs_o),
		.mc_sts_pad_i(1'b0),
		.mc_rp_pad_o_(),
		.mc_vpen_pad_o(),
		.mc_adsc_pad_o_(mc_adsc_o),
		.mc_adv_pad_o_(mc_adv_o),
		.mc_zz_pad_o(mc_zz_o),
		.mc_coe_pad_coe_o(mc_pad_oe)
	);

	// assign memory controller stb_signal
	assign wb_mc_stb = wb_adr_o[31];

	// generate output buffers for memory controller
	assign mc_dq = mc_doe_o ? mc_dq_o : 32'bz;
	assign mc_dp = mc_doe_o ? mc_dp_o : 4'bz;

	// hookup ssrams (CHIP SELECT 4)
	mt58l1my18d ssram0 (
		.Dq( {par_con[24], par_con[16], mc_dq[31:16]} ),
		.Addr(mc_adr_o[19:0]),
		.Mode(1'b0),       // This input (sometimes called LBO) selects burst order
		                   // 1'b0 = linear burst, 1'b1 = interleaved burst
		.Adv_n(mc_adv_o),
		.Clk(mc_clk),
		.Adsc_n(mc_adsc_o),
		.Adsp_n(1'b1),
		.Bwa_n(mc_dqm_o[3]),
		.Bwb_n(mc_dqm_o[2]), // or the otherway around
		.Bwe_n(mc_we_o),
		.Gw_n(1'b1),       // ??
		.Ce_n(mc_cs_o[4]),
		.Ce2(1'b1),
		.Ce2_n(1'b0),
		.Oe_n(mc_oe_o),
		.Zz(mc_zz_o)
	);

	mt58l1my18d ssram1 (
		.Dq( {par_con[8], par_con[0], mc_dq[15:0]} ),
		.Addr(mc_adr_o[19:0]),
		.Mode(1'b0),       // This input (sometimes called LBO) selects burst order
		                   // 1'b0 = linear burst, 1'b1 = interleaved burst
		.Adv_n(mc_adv_o),
		.Clk(mc_clk),
		.Adsc_n(mc_adsc_o),
		.Adsp_n(1'b1),
		.Bwa_n(mc_dqm_o[1]),
		.Bwb_n(mc_dqm_o[0]), // or the otherway around
		.Bwe_n(mc_we_o),
		.Gw_n(1'b1),
		.Ce_n(mc_cs_o[4]),
		.Ce2(1'b1),
		.Ce2_n(1'b0),
		.Oe_n(mc_oe_o),
		.Zz(mc_zz_o)
	);


	// hookup sdrams (CHIP SELECT 3)
	mt48lc16m16a2 sdram0_3(
		.Dq(mc_dq[31:16]),
		.Addr(mc_adr_o[12:0]),
		.Ba(mc_adr_o[14:13]),
		.Clk(mc_clk),
		.Cke(mc_cke_o),
		.Cs_n(mc_cs_o[3]),
		.Ras_n(mc_ras_o),
		.Cas_n(mc_cas_o),
		.We_n(mc_we_o),
		.Dqm(mc_dqm_o[3:2])
	);
	
	mt48lc16m16a2 sdram1_3(
		.Dq(mc_dq[15:0]),
		.Addr(mc_adr_o[12:0]),
		.Ba(mc_adr_o[14:13]),
		.Clk(mc_clk),
		.Cke(mc_cke_o),
		.Cs_n(mc_cs_o[3]),
		.Ras_n(mc_ras_o),
		.Cas_n(mc_cas_o),
		.We_n(mc_we_o),
		.Dqm(mc_dqm_o[1:0])
	);

	// hookup sdrams (CHIP SELECT 2 or PARITY)
	assign pbus_o = sel_pbus ? (sel_par ? mc_dp : set_par) : mc_dq;
	assign par_con = {7'bz, pbus_o[3], 7'bz, pbus_o[2], 7'bz, pbus_o[1], 7'bz, pbus_o[0]};
	assign pbus_i = {par_con[24], par_con[16], par_con[8], par_con[0]};

	assign par_sdram_cs = sel_pbus ? mc_cs_o[3] : mc_cs_o[2];

	mt48lc16m16a2 sdram0_2(
		.Dq(par_con[31:16]),
		.Addr(mc_adr_o[12:0]),
		.Ba(mc_adr_o[14:13]),
		.Clk(mc_clk),
		.Cke(mc_cke_o),
		.Cs_n(par_sdram_cs),
		.Ras_n(mc_ras_o),
		.Cas_n(mc_cas_o),
		.We_n(mc_we_o),
		.Dqm(mc_dqm_o[3:2])
	);
	
	mt48lc16m16a2 sdram1_2(
		.Dq(par_con[15:0]),
		.Addr(mc_adr_o[12:0]),
		.Ba(mc_adr_o[14:13]),
		.Clk(mc_clk),
		.Cke(mc_cke_o),
		.Cs_n(par_sdram_cs),
		.Ras_n(mc_ras_o),
		.Cas_n(mc_cas_o),
		.We_n(mc_we_o),
		.Dqm(mc_dqm_o[1:0])
	);

	// hookup asynchronous srams (CHIP SELECT 1)
	A8Kx8 asram0 (
		.Address(mc_adr_o[12:0]),
		.dataIO(mc_dq[31:24]),
		.OEn(mc_oe_o),
		.CE1n(mc_cs_o[1]),
		.CE2(1'b1),
		.WEn(mc_we_o)
	);
	
	A8Kx8 asram1 (
		.Address(mc_adr_o[12:0]),
		.dataIO(mc_dq[23:16]),
		.OEn(mc_oe_o),
		.CE1n(mc_cs_o[1]),
		.CE2(1'b1),
		.WEn(mc_we_o)
	);
	
	A8Kx8 asram2 (
		.Address(mc_adr_o[12:0]),
		.dataIO(mc_dq[15: 8]),
		.OEn(mc_oe_o),
		.CE1n(mc_cs_o[1]),
		.CE2(1'b1),
		.WEn(mc_we_o)
	);
	
	A8Kx8 asram3 (
		.Address(mc_adr_o[12:0]),
		.dataIO(mc_dq[ 7: 0]),
		.OEn(mc_oe_o),
		.CE1n(mc_cs_o[1]),
		.CE2(1'b1),
		.WEn(mc_we_o)
	);
	
	// hookup wishbone master
	wb_master_model wbm(
		.clk(wb_clk),
		.rst(wb_rst),
		.adr(wb_adr_o),
		.din(wb_dat_i),
		.dout(wb_dat_o),
		.cyc(wb_cyc_o),
		.stb(wb_stb_o),
		.we(wb_we_o),
		.sel(wb_sel_o),
		.ack(wb_ack_i),
		.err(wb_err_i),
		.rty(wb_rty_i)
	);


	//
	// testbench body
	//

	assign wb_rty_i = 1'b0; // no retries from memory controller

	// generate clock
	always #2.5 wb_clk <= ~wb_clk;

	always@(posedge wb_clk)
//		mc_clk <= #1 ~mc_clk;
		mc_clk <= #0 ~mc_clk;

	// initial statements
	initial
	begin
		wb_clk   = 0; // start with low-level clock
		wb_rst   = 1; // assert reset
		mc_clk   = 0;
		sel_par  = 1; // do not modify parity bits
		sel_pbus = 1; // use second SDRAMS set as parity sdrams

		repeat(20) @(posedge wb_clk);
		wb_rst = 0; // negate reset

		@(posedge wb_clk);
		run_tests;

		// show total errors detected
		wbm.show_tot_err_cnt;

		$stop;
	end


	//////////////////////
	//
	// Internal tasks
	//

	task run_tests;
		begin
			prg_mc;     // program memory controller BA-mask and CSR registers

//			force sdram0_3.Debug = 1'b1; // turn on  SDRAM debug option
			force sdram0_3.Debug = 1'b0; // turn off SDRAM debug option

			///////////////
			// SDRAM tests
//			tst_sdram_memfill;           // test sdrams: Fill entire memory and verify
//			tst_sdram_parity;            // test sdrams: Parity generation
//			tst_sdram_seq;               // test sdrams: Fill-Verify, sequential access
//			tst_sdram_rnd;               // test sdrams: Fill-Verify, random access
//			tst_sdram_rmw_seq;           // test sdrams: Read-Modify-Write test, sequential access
//			tst_sdram_rmw_rnd;           // test sdrams: Read-Modify-Write test, random access
//			tst_sdram_blk_cpy1;          // test sdrams: Perform block copy, different src and dest. address
//			tst_sdram_blk_cpy2;          // test sdrams: Perform block copy, src and dest same address
//			tst_sdram_bytes;             // test sdrams: Peform byte accesses

			//////////////////////////////
			// ASYNCHRONOUS MEMORIES TEST
//			tst_amem_seq;                // test asynchronous memory
			tst_amem_b2b;                // test asynchronous memory back-2-back

			////////////////
			// SSRAMS TESTS
			tst_ssram_seq;

			//////////////////////
			// MULTI MEMORY TESTS
//			tst_blk_cpy1;                // test block-copy: access sdrams + asrams

			// The next test (tst_blk_cyp2) is, saddly to say, useless.
			// It tests n-by-n situations for multiple SDRAMS, testing all possible settings for each SDRAM.
			// It is supposed to test the independence for each SDRAM chip-select.
			// However it is to time-consuming; it runs for about a month on an Athlon-XP 1800 system
//			tst_blk_cpy2;                // test block-copy: access multiple sdrams


			/////////////////////////////
			// EXTERNAL BUS MASTER TESTS
			// turn on external bus-master and rerun some tests
//			force ext_bm.on_off = 1'b1;
//			tst_sdram_seq;               // test sdrams: Fill-Verify, sequential access
//			tst_amem_seq;                // test asynchronous memory
//			tst_amem_b2b;                // test asynchronous memory back-2-back
//			tst_blk_cpy1;                // test block-copy: access sdrams + asrams

		end
	endtask // run_tests


	task prg_mc;
		begin
			wbm.wb_write(0, 0, 32'h6000_0008, `BA_MASK); // program base address register
			wbm.wb_write(0, 0, 32'h6000_0000, 32'h6000_0400); // program CSR

			// check written data
			wbm.wb_cmp(0, 0, 32'h6000_0008, `BA_MASK);
			wbm.wb_cmp(0, 0, 32'h6000_0000, 32'h6000_0400);
		end
	endtask //prg_mc

	////////////////////////////////
	// Register test
	//
	task reg_test;
		begin
		end
	endtask // reg_test


	/////////////////////////
	// include memory tests
	//
	`include "tst_sdram.v"
	`include "tst_asram.v"
	`include "tst_ssram.v"
	`include "tst_multi_mem.v"

endmodule

