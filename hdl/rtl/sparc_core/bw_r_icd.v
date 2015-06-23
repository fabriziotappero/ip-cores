// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_icd.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
////////////////////////////////////////////////////////////////////////
/*
 //  Module Name:  bw_r_icd
 //  Description:	
 //    The ICD contains the icache data.  
 //    32B line size.  
 //    Write BW: 16B
 //    Read BW: 16Bx2 (fetdata and topdata), collapsed to 4Bx2
 //    Associativity: 4
 //    Write boundary: 34b (32b inst + parity + predec bit)
 //    NOTES: 
 //    1. No clock enable.  Rd/Wr enable is used to trigger the
 //    operation.
 //    2. 2:1 mux on address input.  Selects provided externally.
 //    3. 3:1 mux on data input.   Selects provided and guaranteed
 //    exclusive, externally.
 //    
 */


////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
//`include "sys.h" // system level definition file which contains the 
// time scale definition


////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

/*
/* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: ifu.h
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/
////////////////////////////////////////////////////////////////////////
/*
//
//  Module Name: ifu.h
//  Description:	
//  All ifu defines
*/

//--------------------------------------------
// Icache Values in IFU::ICD/ICV/ICT/FDP/IFQDP
//--------------------------------------------
// Set Values

// IC_IDX_HI = log(icache_size/4ways) - 1


// !!IMPORTANT!! a change to IC_LINE_SZ will mean a change to the code as
//   well.  Unfortunately this has not been properly parametrized.
//   Changing the IC_LINE_SZ param alone is *not* enough.


// !!IMPORTANT!! a change to IC_TAG_HI will mean a change to the code as
//   well.  Changing the IC_TAG_HI param alone is *not* enough to
//   change the PA range. 
// highest bit of PA



// Derived Values
// 4095


// number of entries - 1 = 511


// 12


// 28


// 7


// tags for all 4 ways + parity
// 116


// 115



//----------------------------------------------------------------------
// For thread scheduler in IFU::DTU::SWL
//----------------------------------------------------------------------
// thread states:  (thr_state[4:0])









// thread configuration register bit fields







//----------------------------------------------------------------------
// For MIL fsm in IFU::IFQ
//----------------------------------------------------------------------











//---------------------------------------------------
// Interrupt Block
//---------------------------------------------------







//-------------------------------------
// IFQ
//-------------------------------------
// valid bit plus ifill













//`ifdef SPARC_L2_64B


//`else
//`define BANK_ID_HI 8
//`define BANK_ID_LO 7
//`endif

//`define CPX_INV_PA_HI  116
//`define CPX_INV_PA_LO  112







//----------------------------------------
// IFU Traps
//----------------------------------------
// precise















// disrupting








//FPGA_SYN enables all FPGA related modifications
 





module bw_r_icd(icd_wsel_fetdata_s1, icd_wsel_topdata_s1, icd_fuse_repair_value,
	icd_fuse_repair_en, so, rclk, se, si, reset_l, sehold, fdp_icd_index_bf,
	ifq_icd_index_bf, fcl_icd_index_sel_ifq_bf, ifq_icd_wrway_bf, 
	ifq_icd_worden_bf, ifq_icd_wrdata_i2, fcl_icd_rdreq_bf, 
	fcl_icd_wrreq_bf, bist_ic_data, rst_tri_en, ifq_icd_data_sel_old_i2, 
	ifq_icd_data_sel_fill_i2, ifq_icd_data_sel_bist_i2, fuse_icd_wren, 
	fuse_icd_rid, fuse_icd_repair_value, fuse_icd_repair_en, 
	efc_spc_fuse_clk1);

	input			rclk;
	input			se;
	input			si;
	input			reset_l;
	input			sehold;
	input	[11:2]		fdp_icd_index_bf;
	input	[11:2]		ifq_icd_index_bf;
	input			fcl_icd_index_sel_ifq_bf;
	input	[1:0]		ifq_icd_wrway_bf;
	input	[3:0]		ifq_icd_worden_bf;
	input	[135:0]		ifq_icd_wrdata_i2;
	input			fcl_icd_rdreq_bf;
	input			fcl_icd_wrreq_bf;
	input	[7:0]		bist_ic_data;
	input			rst_tri_en;
	input			ifq_icd_data_sel_old_i2;
	input			ifq_icd_data_sel_fill_i2;
	input			ifq_icd_data_sel_bist_i2;
	input			fuse_icd_wren;
	input	[3:0]		fuse_icd_rid;
	input	[7:0]		fuse_icd_repair_value;
	input	[1:0]		fuse_icd_repair_en;
	input			efc_spc_fuse_clk1;
	output	[135:0]		icd_wsel_fetdata_s1;
	output	[135:0]		icd_wsel_topdata_s1;
	output	[7:0]		icd_fuse_repair_value;
	output	[1:0]		icd_fuse_repair_en;
	output			so;

	reg	[7:0]		icd_fuse_repair_value;
	reg	[1:0]		icd_fuse_repair_en;
	reg	[135:0]		fetdata_f;
	reg	[135:0]		topdata_f;
	reg	[135:0]		fetdata_sa;
	reg	[135:0]		topdata_sa;
	reg	[135:0]		fetdata_s1;
	reg	[135:0]		topdata_s1;
	wire			clk;
	wire	[135:0]		next_wrdata_bf;
	wire	[135:0]		wrdata_f;
	wire	[135:0]		bist_data_expand;
	wire	[11:2]		index_bf;
	reg	[11:2]		index_f;
	reg	[11:0]		wr_index0;
	reg	[11:0]		wr_index1;
	reg	[11:0]		wr_index2;
	reg	[11:0]		wr_index3;
	reg			rdreq_f;
	reg			wrreq_f;
	reg	[3:0]		worden_f;
	reg	[1:0]		wrway_f;

   reg [33:0]     icdata_ary_00_00  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_00_01  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_00_10  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_00_11  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_01_00  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_01_01  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_01_10  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_01_11  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_10_00  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_10_01  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_10_10  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_10_11  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_11_00  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_11_01  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_11_10  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
   reg [33:0]     icdata_ary_11_11  [255:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;



	assign clk = rclk;
	assign index_bf = (fcl_icd_index_sel_ifq_bf ? ifq_icd_index_bf : 
		fdp_icd_index_bf);
  	wire [11:2] top_index = {index_f[11:3] , 1'b1};

	assign bist_data_expand = 136'b0;
	assign icd_wsel_fetdata_s1 = fetdata_s1;
	assign icd_wsel_topdata_s1 = topdata_s1;

	mux3ds #(136) icden_mux(
		.dout				(next_wrdata_bf), 
		.in0				(wrdata_f), 
		.in1				(ifq_icd_wrdata_i2), 
		.in2				(bist_data_expand), 
		.sel0				(ifq_icd_data_sel_old_i2), 
		.sel1				(ifq_icd_data_sel_fill_i2), 
		.sel2				(ifq_icd_data_sel_bist_i2));
	dffe #(136) wrdata_reg(
		.din				(next_wrdata_bf), 
		.clk				(clk), 
		.q				(wrdata_f), 
		.en				((~sehold)), 
		.se				(se));

	always @(posedge clk) begin
	  if (~sehold) begin
	    rdreq_f <= fcl_icd_rdreq_bf;
	    wrreq_f <= fcl_icd_wrreq_bf;
	    index_f <= index_bf;
	    wrway_f <= ifq_icd_wrway_bf;
	    worden_f <= ifq_icd_worden_bf;
	    wr_index0 <= {index_bf[11:4], 2'b0, ifq_icd_wrway_bf};
	    wr_index1 <= {index_bf[11:4], 2'b1, ifq_icd_wrway_bf};
	    wr_index2 <= {index_bf[11:4], 2'b10, ifq_icd_wrway_bf};
	    wr_index3 <= {index_bf[11:4], 2'b11, ifq_icd_wrway_bf};
	  end
	  fetdata_s1 <= fetdata_f;
	  topdata_s1 <= topdata_f;
	end

	reg [33:0] fetch_00_00;
	reg [33:0] fetch_00_01;
	reg [33:0] fetch_00_10;
	reg [33:0] fetch_00_11;

	reg [33:0] fetch_01_00;
	reg [33:0] fetch_01_01;
	reg [33:0] fetch_01_10;
	reg [33:0] fetch_01_11;

	reg [33:0] fetch_10_00;
	reg [33:0] fetch_10_01;
	reg [33:0] fetch_10_10;
	reg [33:0] fetch_10_11;

	reg [33:0] fetch_11_00;
	reg [33:0] fetch_11_01;
	reg [33:0] fetch_11_10;
	reg [33:0] fetch_11_11;

	always @(posedge clk) begin
	  fetch_00_00 <= icdata_ary_00_00[index_bf[11:4]];
	  fetch_00_01 <= icdata_ary_00_01[index_bf[11:4]];
	  fetch_00_10 <= icdata_ary_00_10[index_bf[11:4]];
	  fetch_00_11 <= icdata_ary_00_11[index_bf[11:4]];
          
	  fetch_01_00 <= icdata_ary_01_00[index_bf[11:4]];
	  fetch_01_01 <= icdata_ary_01_01[index_bf[11:4]];
	  fetch_01_10 <= icdata_ary_01_10[index_bf[11:4]];
	  fetch_01_11 <= icdata_ary_01_11[index_bf[11:4]];
          
	  fetch_10_00 <= icdata_ary_10_00[index_bf[11:4]];
	  fetch_10_01 <= icdata_ary_10_01[index_bf[11:4]];
	  fetch_10_10 <= icdata_ary_10_10[index_bf[11:4]];
	  fetch_10_11 <= icdata_ary_10_11[index_bf[11:4]];
          
	  fetch_11_00 <= icdata_ary_11_00[index_bf[11:4]];
	  fetch_11_01 <= icdata_ary_11_01[index_bf[11:4]];
	  fetch_11_10 <= icdata_ary_11_10[index_bf[11:4]];
	  fetch_11_11 <= icdata_ary_11_11[index_bf[11:4]];
	end


	always @(index_f or rdreq_f or fetch_00_00 or fetch_01_00 or fetch_10_00 or fetch_11_00
				    or fetch_00_01 or fetch_01_01 or fetch_10_01 or fetch_11_01
				    or fetch_00_10 or fetch_01_10 or fetch_10_10 or fetch_11_10
				    or fetch_00_11 or fetch_01_11 or fetch_10_11 or fetch_11_11) begin
//	  if (rdreq_f) begin
	    case(index_f[3:2])
	      2'b00: fetdata_f[33:0] = fetch_00_00;
	      2'b01: fetdata_f[33:0] = fetch_01_00;
	      2'b10: fetdata_f[33:0] = fetch_10_00;
	      2'b11: fetdata_f[33:0] = fetch_11_00;
	    endcase
	    case(index_f[3:2])
	      2'b00: fetdata_f[67:34] = fetch_00_01;
	      2'b01: fetdata_f[67:34] = fetch_01_01;
	      2'b10: fetdata_f[67:34] = fetch_10_01;
	      2'b11: fetdata_f[67:34] = fetch_11_01;
	    endcase
	    case(index_f[3:2])
	      2'b00: fetdata_f[101:68] = fetch_00_10;
	      2'b01: fetdata_f[101:68] = fetch_01_10;
	      2'b10: fetdata_f[101:68] = fetch_10_10;
	      2'b11: fetdata_f[101:68] = fetch_11_10;
	    endcase
	    case(index_f[3:2])
	      2'b00: fetdata_f[135:102] = fetch_00_11;
	      2'b01: fetdata_f[135:102] = fetch_01_11;
	      2'b10: fetdata_f[135:102] = fetch_10_11;
	      2'b11: fetdata_f[135:102] = fetch_11_11;
	    endcase
	    case(index_f[3])
              1'b0: topdata_f[33:0] = fetch_01_00;
	      1'b1: topdata_f[33:0] = fetch_11_00;
	    endcase
	    case(index_f[3])
              1'b0: topdata_f[67:34] = fetch_01_01;
	      1'b1: topdata_f[67:34] = fetch_11_01;
	    endcase
	    case(index_f[3])
              1'b0: topdata_f[101:68] = fetch_01_10;
	      1'b1: topdata_f[101:68] = fetch_11_10;
	    endcase
	    case(index_f[3])
              1'b0: topdata_f[135:102] = fetch_01_11;
	      1'b1: topdata_f[135:102] = fetch_11_11;
	    endcase
	  end
//	  else
//	    begin
//	      fetdata_f = 136'b0;
//	      topdata_f = 136'b0;
//	    end
//	end

	always @(negedge clk) begin
	  if (wrreq_f & (~rst_tri_en)) begin
	    if (worden_f[0]) begin
	      if (wr_index0[1:0] == 2'b0) begin
		icdata_ary_00_00[wr_index0[11:4]] <= wrdata_f[135:102];
	      end
	      if (wr_index0[1:0] == 2'b1) begin
		icdata_ary_00_01[wr_index0[11:4]] <= wrdata_f[135:102];
	      end
	      if (wr_index0[1:0] == 2'b10) begin
		icdata_ary_00_10[wr_index0[11:4]] <= wrdata_f[135:102];
	      end
	      if (wr_index0[1:0] == 2'b11) begin
		icdata_ary_00_11[wr_index0[11:4]] <= wrdata_f[135:102];
	      end
	    end
	    if (worden_f[1]) begin
	      if (wr_index1[1:0] == 2'b0) begin
		icdata_ary_01_00[wr_index1[11:4]] <= wrdata_f[101:68];
	      end
	      if (wr_index1[1:0] == 2'b1) begin
		icdata_ary_01_01[wr_index1[11:4]] <= wrdata_f[101:68];
	      end
	      if (wr_index1[1:0] == 2'b10) begin
		icdata_ary_01_10[wr_index1[11:4]] <= wrdata_f[101:68];
	      end
	      if (wr_index1[1:0] == 2'b11) begin
		icdata_ary_01_11[wr_index1[11:4]] <= wrdata_f[101:68];
	      end
	    end
	    if (worden_f[2]) begin
	      if (wr_index2[1:0] == 2'b0) begin
		icdata_ary_10_00[wr_index2[11:4]] <= wrdata_f[67:34];
	      end
	      if (wr_index2[1:0] == 2'b1) begin
		icdata_ary_10_01[wr_index2[11:4]] <= wrdata_f[67:34];
	      end
	      if (wr_index2[1:0] == 2'b10) begin
		icdata_ary_10_10[wr_index2[11:4]] <= wrdata_f[67:34];
	      end
	      if (wr_index2[1:0] == 2'b11) begin
		icdata_ary_10_11[wr_index2[11:4]] <= wrdata_f[67:34];
	      end
	    end
	    if (worden_f[3]) begin
	      if (wr_index3[1:0] == 2'b0) begin
		icdata_ary_11_00[wr_index3[11:4]] <= wrdata_f[33:0];
	      end
	      if (wr_index3[1:0] == 2'b1) begin
		icdata_ary_11_01[wr_index3[11:4]] <= wrdata_f[33:0];
	      end
	      if (wr_index3[1:0] == 2'b10) begin
		icdata_ary_11_10[wr_index3[11:4]] <= wrdata_f[33:0];
	      end
	      if (wr_index3[1:0] == 2'b11) begin
		icdata_ary_11_11[wr_index3[11:4]] <= wrdata_f[33:0];
	      end
	    end
	  end
	end
endmodule




























































































































































































































































































































































































































































































































































