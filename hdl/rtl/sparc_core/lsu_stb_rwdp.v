// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: lsu_stb_rwdp.v
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
///////////////////////////////////////////////////////////////////
/*
//	Description:	Datapath for STB
//				- Mainly for formatting stb data 
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
// system level definition file which contains the /*
/* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: sys.h
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
// -*- verilog -*-
////////////////////////////////////////////////////////////////////////
/*
//
// Description:		Global header file that contain definitions that 
//                      are common/shared at the systme level
*/
////////////////////////////////////////////////////////////////////////
//
// Setting the time scale
// If the timescale changes, JP_TIMESCALE may also have to change.
`timescale	1ps/1ps

//
// JBUS clock
// =========
//



// Afara Link Defines
// ==================

// Reliable Link




// Afara Link Objects


// Afara Link Object Format - Reliable Link










// Afara Link Object Format - Congestion



  







// Afara Link Object Format - Acknowledge











// Afara Link Object Format - Request

















// Afara Link Object Format - Message



// Acknowledge Types




// Request Types





// Afara Link Frame



//
// UCB Packet Type
// ===============
//

















//
// UCB Data Packet Format
// ======================
//






























// Size encoding for the UCB_SIZE_HI/LO field
// 000 - byte
// 001 - half-word
// 010 - word
// 011 - double-word
// 111 - quad-word







//
// UCB Interrupt Packet Format
// ===========================
//










//`define UCB_THR_HI             9      // (6) cpu/thread ID shared with
//`define UCB_THR_LO             4             data packet format
//`define UCB_PKT_HI             3      // (4) packet type shared with
//`define UCB_PKT_LO             0      //     data packet format







//
// FCRAM Bus Widths
// ================
//






//
// ENET clock periods
// ==================
//




//
// JBus Bridge defines
// =================
//











//
// PCI Device Address Configuration
// ================================
//























					// time scale definition

/*
/* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: iop.h
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
//-*- verilog -*-
////////////////////////////////////////////////////////////////////////
/*
//
//  Description:	Global header file that contain definitions that 
//                      are common/shared at the IOP chip level
*/
////////////////////////////////////////////////////////////////////////


// Address Map Defines
// ===================




// CMP space



// IOP space




                               //`define ENET_ING_CSR     8'h84
                               //`define ENET_EGR_CMD_CSR 8'h85















// L2 space



// More IOP space





//Cache Crossbar Width and Field Defines
//======================================













































//bits 133:128 are shared by different fields
//for different packet types.






























































//End cache crossbar defines


// Number of COS supported by EECU 



// 
// BSC bus sizes
// =============
//

// General




// CTags













// reinstated temporarily




// CoS






// L2$ Bank



// L2$ Req













// L2$ Ack








// Enet Egress Command Unit














// Enet Egress Packet Unit













// This is cleaved in between Egress Datapath Ack's








// Enet Egress Datapath
















// In-Order / Ordered Queue: EEPU
// Tag is: TLEN, SOF, EOF, QID = 15






// Nack + Tag Info + CTag




// ENET Ingress Queue Management Req












// ENET Ingress Queue Management Ack








// Enet Ingress Packet Unit












// ENET Ingress Packet Unit Ack







// In-Order / Ordered Queue: PCI
// Tag is: CTAG





// PCI-X Request











// PCI_X Acknowledge











//
// BSC array sizes
//================
//












// ECC syndrome bits per memory element




//
// BSC Port Definitions
// ====================
//
// Bits 7 to 4 of curr_port_id








// Number of ports of each type


// Bits needed to represent above


// How wide the linked list pointers are
// 60b for no payload (2CoS)
// 80b for payload (2CoS)

//`define BSC_OBJ_PTR   80
//`define BSC_HD1_HI    69
//`define BSC_HD1_LO    60
//`define BSC_TL1_HI    59
//`define BSC_TL1_LO    50
//`define BSC_CT1_HI    49
//`define BSC_CT1_LO    40
//`define BSC_HD0_HI    29
//`define BSC_HD0_LO    20
//`define BSC_TL0_HI    19
//`define BSC_TL0_LO    10
//`define BSC_CT0_HI     9
//`define BSC_CT0_LO     0


































// I2C STATES in DRAMctl







//
// IOB defines
// ===========
//



















//`define IOB_INT_STAT_WIDTH   32
//`define IOB_INT_STAT_HI      31
//`define IOB_INT_STAT_LO       0

















































// fixme - double check address mapping
// CREG in `IOB_INT_CSR space










// CREG in `IOB_MAN_CSR space





































// Address map for TAP access of SPARC ASI













//
// CIOP UCB Bus Width
// ==================
//
//`define IOB_EECU_WIDTH       16  // ethernet egress command
//`define EECU_IOB_WIDTH       16

//`define IOB_NRAM_WIDTH       16  // NRAM (RLDRAM previously)
//`define NRAM_IOB_WIDTH        4




//`define IOB_ENET_ING_WIDTH   32  // ethernet ingress
//`define ENET_ING_IOB_WIDTH    8

//`define IOB_ENET_EGR_WIDTH    4  // ethernet egress
//`define ENET_EGR_IOB_WIDTH    4

//`define IOB_ENET_MAC_WIDTH    4  // ethernet MAC
//`define ENET_MAC_IOB_WIDTH    4




//`define IOB_BSC_WIDTH         4  // BSC
//`define BSC_IOB_WIDTH         4







//`define IOB_CLSP_WIDTH        4  // clk spine unit
//`define CLSP_IOB_WIDTH        4





//
// CIOP UCB Buf ID Type
// ====================
//



//
// Interrupt Device ID
// ===================
//
// Caution: DUMMY_DEV_ID has to be 9 bit wide
//          for fields to line up properly in the IOB.



//
// Soft Error related definitions 
// ==============================
//



//
// CMP clock
// =========
//




//
// NRAM/IO Interface
// =================
//










//
// NRAM/ENET Interface
// ===================
//







//
// IO/FCRAM Interface
// ==================
//






//
// PCI Interface
// ==================
// Load/store size encodings
// -------------------------
// Size encoding
// 000 - byte
// 001 - half-word
// 010 - word
// 011 - double-word
// 100 - quad






//
// JBI<->SCTAG Interface
// =======================
// Outbound Header Format



























// Inbound Header Format




















//
// JBI->IOB Mondo Header Format
// ============================
//














// JBI->IOB Mondo Bus Width/Cycle
// ==============================
// Cycle  1 Header[15:8]
// Cycle  2 Header[ 7:0]
// Cycle  3 J_AD[127:120]
// Cycle  4 J_AD[119:112]
// .....
// Cycle 18 J_AD[  7:  0]



////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

module lsu_stb_rwdp (/*AUTOARG*/
   // Outputs
   so, stb_rdata_ramd_buf, stb_rdata_ramd_b74_buf, lsu_stb_st_data_g, 
   // Inputs
   rclk, si, se, rst_tri_en, exu_lsu_rs3_data_e, 
   lsu_stb_data_early_sel_e, lsu_stb_data_final_sel_m, 
   exu_lsu_rs2_data_e, lsu_st_sz_bhww_m, lsu_st_sz_dw_m, 
   lsu_st_sz_bhw_m, lsu_st_sz_wdw_m, lsu_st_sz_b_m, lsu_st_sz_w_m, 
   lsu_st_sz_hw_m, lsu_st_sz_hww_m, ffu_lsu_data, lsu_st_hw_le_g, 
   lsu_st_w_or_dbl_le_g, lsu_st_x_le_g, lsu_swap_sel_default_g, 
   lsu_swap_sel_default_byte_7_2_g, stb_rdata_ramd, 
   stb_rdata_ramd_b74
   ) ;	

   input  rclk ;
   input  si;
   output so;
   input  se;
   input  rst_tri_en;
   
input   [63:0]          exu_lsu_rs3_data_e ;    // data for store.
input	[3:0]		lsu_stb_data_early_sel_e ;// early source of data for stb
input			lsu_stb_data_final_sel_m ;// early source of data for stb
input   [63:0]          exu_lsu_rs2_data_e ;    // rs2 data for cas.
input			lsu_st_sz_bhww_m ;	// byte or hword or word
input			lsu_st_sz_dw_m ;	// double word
input			lsu_st_sz_bhw_m ;	// byte or hword
input			lsu_st_sz_wdw_m ;	// word or dword
input			lsu_st_sz_b_m ;		// byte
input			lsu_st_sz_w_m ;		// word
input			lsu_st_sz_hw_m ;	// hword
input			lsu_st_sz_hww_m ;	// hword or word
input	[63:0]		ffu_lsu_data ;	// fp store data - m stage
//input			lsu_bendian_access_g ;	// bendian st
//input			lsu_stdbl_inst_m ;	// stdbl

   input        lsu_st_hw_le_g;
   input        lsu_st_w_or_dbl_le_g;
   input        lsu_st_x_le_g;
   input        lsu_swap_sel_default_g;
   input        lsu_swap_sel_default_byte_7_2_g;
   
   input [69:0] stb_rdata_ramd;
   input        stb_rdata_ramd_b74;
   
   output [69:0] stb_rdata_ramd_buf;
   output        stb_rdata_ramd_b74_buf;
   
output	[63:0]		lsu_stb_st_data_g ;	// data to be written to stb

wire	[7:0]	byte0, byte1, byte2, byte3 ;
wire	[7:0]	byte4, byte5, byte6, byte7 ;
wire	[7:0]	swap_byte0, swap_byte1, swap_byte2, swap_byte3 ;
wire	[7:0]	swap_byte4, swap_byte5, swap_byte6, swap_byte7 ;

wire	[63:0]	stb_st_data_g ;
wire	[63:0]	stb_st_data_early_e ;
wire	[63:0]	stb_st_data_early_m ;
wire	[63:0]	stb_st_data_final_m ;
wire		st_sz_bhww_g ;
wire		st_sz_dw_g ;
wire		st_sz_bhw_g ;
wire		st_sz_wdw_g ;
wire		st_sz_b_g ;
wire		st_sz_w_g ;
wire		st_sz_hw_g ;
wire		st_sz_hww_g ;
//wire		bendian ;
//wire		stdbl_g ;

   wire clk;
   assign clk = rclk;
   
//assign  stb_st_data_early_e[63:0] =       //@@ bw_u1_muxi41d_2x   
//        lsu_stb_data_early_sel_e[0] ? 64'hffff_ffff_ffff_ffff :            		// ldstub writes all ones
//                lsu_stb_data_early_sel_e[1] ? exu_lsu_rs2_data_e[63:0] :        	// cas pkt1 uses rs2
//                	lsu_stb_data_early_sel_e[2] ? exu_lsu_rs3_data_e[63:0] :   	// use rs3/rd data.
//                		lsu_stb_data_early_sel_e[3] ? {exu_lsu_rs2_data_e[31:0],exu_lsu_rs3_data_e[31:0]} :  
											// else std non-alt
//						64'hxxxx_xxxx_xxxx_xxxx ;				

mux4ds #(64) stb_st_data_early_e_mx (
 .in0 (64'hffff_ffff_ffff_ffff), 
 .in1 (exu_lsu_rs2_data_e[63:0]),
 .in2 (exu_lsu_rs3_data_e[63:0]),
 .in3 ({exu_lsu_rs2_data_e[31:0],exu_lsu_rs3_data_e[31:0]}),
 .sel0(lsu_stb_data_early_sel_e[0]),
 .sel1(lsu_stb_data_early_sel_e[1]),
 .sel2(lsu_stb_data_early_sel_e[2]),
 .sel3(lsu_stb_data_early_sel_e[3]),
 .dout(stb_st_data_early_e[63:0]));
                                    

// Stage early data to m
dff #(64)  stgm_rs2     (             //@@ bw_u1_soffi_2x
        .din            (stb_st_data_early_e[63:0]),
        .q              (stb_st_data_early_m[63:0]),
        .clk            (clk),
        .se             (se), .si     (), .so ()
        );

assign  stb_st_data_final_m[63:0] =    //@@ bw_u1_muxi21_2x
        lsu_stb_data_final_sel_m ? stb_st_data_early_m[63:0] : ffu_lsu_data[63:0] ; 	// mux in fpst data

// Precursor of data to be stored in stb
// For ldstub, all one's need to be written to stb.
// For cas/swap, data remains unmodified.
// Stage final data to g
dff #(64)  stgg_rs2     (             //@@ bw_u1_soffi_2x
        .din            (stb_st_data_final_m[63:0]),
        .q              (stb_st_data_g[63:0]),
        .clk            (clk),
        .se             (se), .si     (), .so ()
        );

dff #(8)  stgm_sel     (             //@@ bw_u1_soff_8x
	.din		({lsu_st_sz_bhww_m,lsu_st_sz_dw_m,lsu_st_sz_bhw_m,lsu_st_sz_wdw_m,
			lsu_st_sz_b_m,lsu_st_sz_w_m,lsu_st_sz_hw_m,lsu_st_sz_hww_m}),
	.q		({st_sz_bhww_g,st_sz_dw_g,st_sz_bhw_g,st_sz_wdw_g,
			st_sz_b_g,st_sz_w_g,st_sz_hw_g,st_sz_hww_g}),
        .clk            (clk),
        .se             (se), .si     (), .so ()
        );

// Now format data for st data.
assign	byte0[7:0] = stb_st_data_g[7:0] ; //@@ PASS
assign	byte1[7:0] = stb_st_data_g[15:8] ; //@@ PASS
assign	byte2[7:0] = stb_st_data_g[23:16] ; //@@ PASS
assign	byte3[7:0] = stb_st_data_g[31:24] ; //@@ PASS
assign	byte4[7:0] = stb_st_data_g[39:32] ; //@@ PASS
assign	byte5[7:0] = stb_st_data_g[47:40] ; //@@ PASS
assign	byte6[7:0] = stb_st_data_g[55:48] ; //@@ PASS
assign	byte7[7:0] = stb_st_data_g[63:56] ; //@@ PASS


//assign	bendian = lsu_bendian_access_g ;	// bendian store

// Control needs to move to lsu_stb_rwctl once this is fully tested.

// First do swap for big-endian vs little-endian case.

//wire	swap_sel_default ;

//assign	swap_sel_default = bendian | (~bendian & st_sz_b_g) ;
 
// swap byte0
//assign	swap_byte0[7:0] =               //@@ bw_u1_muxi41d_4x
//	lsu_swap_sel_default_g ? byte0[7:0] : 
//		lsu_st_hw_le_g ? byte1[7:0] :
//			lsu_st_w_or_dbl_le_g ? byte3[7:0] :
//				lsu_st_x_le_g ? byte7[7:0] : 8'bxxxx_xxxx ; 

mux4ds #(8) swap_byte0_mx (
  .in0 (byte0[7:0]), .sel0(lsu_swap_sel_default_g),
  .in1 (byte1[7:0]), .sel1(lsu_st_hw_le_g),
  .in2 (byte3[7:0]), .sel2(lsu_st_w_or_dbl_le_g),
  .in3 (byte7[7:0]), .sel3(lsu_st_x_le_g),
  .dout(swap_byte0[7:0]));
                         
// swap byte1
//assign	swap_byte1[7:0] =               //@@ bw_u1_muxi41d_4x
//	lsu_swap_sel_default_g ? byte1[7:0] : 
//		lsu_st_hw_le_g ? byte0[7:0] :	
//			 lsu_st_w_or_dbl_le_g ? byte2[7:0] :
//				 lsu_st_x_le_g ? byte6[7:0] : 8'bxxxx_xxxx ; 

mux4ds #(8) swap_byte1_mx (
 .in0 (byte1[7:0]), .sel0(lsu_swap_sel_default_g),
 .in1 (byte0[7:0]), .sel1(lsu_st_hw_le_g),
 .in2 (byte2[7:0]), .sel2(lsu_st_w_or_dbl_le_g),
 .in3 (byte6[7:0]), .sel3(lsu_st_x_le_g),
 .dout (swap_byte1[7:0]));
    
// swap byte2
//assign	swap_byte2[7:0] =                //@@ bw_u1_muxi31d_4x
//	lsu_swap_sel_default_g ? byte2[7:0] : 
//		lsu_st_w_or_dbl_le_g ? byte1[7:0] :
//			lsu_st_x_le_g ? byte5[7:0] : 8'bxxxx_xxxx ; 
   
mux3ds #(8) swap_byte2_mx (
  .in0 (byte2[7:0]), .sel0(lsu_swap_sel_default_byte_7_2_g),
  .in1 (byte1[7:0]), .sel1(lsu_st_w_or_dbl_le_g),
  .in2 (byte5[7:0]), .sel2(lsu_st_x_le_g),
  .dout (swap_byte2[7:0]));
      
// swap byte3
//assign	swap_byte3[7:0] =                 //@@ bw_u1_muxi31d_4x
//	lsu_swap_sel_default_g ? byte3[7:0] : 
//		lsu_st_w_or_dbl_le_g ? byte0[7:0] :
//			lsu_st_x_le_g ? byte4[7:0] : 8'bxxxx_xxxx ; 

mux3ds #(8) swap_byte3_mx (
 .in0 (byte3[7:0]), .sel0(lsu_swap_sel_default_byte_7_2_g),
 .in1 (byte0[7:0]), .sel1(lsu_st_w_or_dbl_le_g),
 .in2 (byte4[7:0]), .sel2(lsu_st_x_le_g),
 .dout(swap_byte3[7:0]));
                          
// swap byte4
//assign	swap_byte4[7:0] =                 //@@ bw_u1_muxi31d_4x
//	lsu_swap_sel_default_g ? byte4[7:0] : 
//		 lsu_st_w_or_dbl_le_g ? byte7[7:0] :
//			 lsu_st_x_le_g ? byte3[7:0] : 8'bxxxx_xxxx ; 

mux3ds #(8) swap_byte4_mx (
.in0 (byte4[7:0]), .sel0(lsu_swap_sel_default_byte_7_2_g),
.in1 (byte7[7:0]), .sel1(lsu_st_w_or_dbl_le_g),
.in2 (byte3[7:0]), .sel2(lsu_st_x_le_g),
.dout(swap_byte4[7:0]));
  
// swap byte5
//assign	swap_byte5[7:0] =                 //@@ bw_u1_muxi31d_4x
//	lsu_swap_sel_default_g ? byte5[7:0] : 
//		 lsu_st_w_or_dbl_le_g ? byte6[7:0] :
//			  lsu_st_x_le_g ? byte2[7:0] : 8'bxxxx_xxxx ; 

mux3ds #(8) swap_byte5_mx (
 .in0 (byte5[7:0]), .sel0(lsu_swap_sel_default_byte_7_2_g),
 .in1 (byte6[7:0]), .sel1(lsu_st_w_or_dbl_le_g),
 .in2 (byte2[7:0]), .sel2(lsu_st_x_le_g),
 .dout(swap_byte5[7:0]));
 
// swap byte6
//assign	swap_byte6[7:0] =                 //@@ bw_u1_muxi31d_4x
//	lsu_swap_sel_default_g ? byte6[7:0] : 
//		 lsu_st_w_or_dbl_le_g ? byte5[7:0] :
//			  lsu_st_x_le_g ? byte1[7:0] : 8'bxxxx_xxxx ; 

mux3ds #(8) swap_byte6_mx (
 .in0 (byte6[7:0]), .sel0 (lsu_swap_sel_default_byte_7_2_g),
 .in1 (byte5[7:0]), .sel1 (lsu_st_w_or_dbl_le_g),
 .in2 (byte1[7:0]), .sel2 (lsu_st_x_le_g),
 .dout(swap_byte6[7:0]));
  
// swap byte7
//assign	swap_byte7[7:0] =                 //@@ bw_u1_muxi31d_4x
//	lsu_swap_sel_default_g ? byte7[7:0] : 
//		 lsu_st_w_or_dbl_le_g ? byte4[7:0] :
//		    lsu_st_x_le_g ? byte0[7:0] : 8'bxxxx_xxxx ; 

mux3ds #(8) swap_byte7_mx (
 .in0 (byte7[7:0]), .sel0 (lsu_swap_sel_default_byte_7_2_g),
 .in1 (byte4[7:0]), .sel1 (lsu_st_w_or_dbl_le_g),
 .in2 (byte0[7:0]), .sel2 (lsu_st_x_le_g),
 .dout (swap_byte7[7:0]));
   
// Now replicate date across 8 bytes.

// replicated byte0
assign	lsu_stb_st_data_g[7:0] = swap_byte0[7:0] ;	// all data sizes //@@ bw_u1_inv_8x

// replicated byte1
assign	lsu_stb_st_data_g[15:8] =                 //@@ bw_u1_muxi21_6x
		st_sz_b_g ? swap_byte0[7:0] : swap_byte1[7:0] ;

// replicated byte2
assign	lsu_stb_st_data_g[23:16] =                //@@ bw_u1_muxi21_6x
		st_sz_bhw_g ? swap_byte0[7:0] : swap_byte2[7:0] ;

// replicated byte3
//assign	lsu_stb_st_data_g[31:24] =                 //@@ bw_u1_muxi31d_6x
//		st_sz_b_g ? swap_byte0 :			// swap_byte
//			st_sz_hw_g ? swap_byte1 :	// hword
//				st_sz_wdw_g ? swap_byte3 : // dword or word
//					8'bxxxx_xxxx ;

   wire st_sz_b_g_sel, st_sz_hw_g_sel, st_sz_wdw_g_sel;
   assign st_sz_b_g_sel = st_sz_b_g & ~rst_tri_en;
   assign st_sz_hw_g_sel = st_sz_hw_g & ~rst_tri_en;
   assign st_sz_wdw_g_sel = st_sz_wdw_g | rst_tri_en;
   
mux3ds #(8) rpl_byte3_mx (
  .in0 (swap_byte0[7:0]), .sel0 (st_sz_b_g_sel),
  .in1 (swap_byte1[7:0]), .sel1 (st_sz_hw_g_sel),
  .in2 (swap_byte3[7:0]), .sel2 (st_sz_wdw_g_sel),
  .dout (lsu_stb_st_data_g[31:24]));
                             
// replicated byte4
assign	lsu_stb_st_data_g[39:32] =                 //@@ bw_u1_muxi21_6x
	st_sz_bhww_g ? swap_byte0[7:0] : swap_byte4[7:0] ;	// dword


// replicated byte5
//assign	lsu_stb_st_data_g[47:40] =                 //@@ bw_u1_muxi31d_6x
//		st_sz_b_g ? swap_byte0 :			// swap_byte 
//			st_sz_hww_g ? swap_byte1 :	// hword or word
//				st_sz_dw_g ? swap_byte5 : // dword
//					8'bxxxx_xxxx ;

    wire  st_sz_hww_g_sel, st_sz_dw_g_sel;
   assign st_sz_hww_g_sel = st_sz_hww_g & ~rst_tri_en;
   assign st_sz_dw_g_sel = st_sz_dw_g | rst_tri_en;
  
mux3ds #(8) rpl_byte5_mx (
  .in0 (swap_byte0[7:0]), .sel0(st_sz_b_g_sel),
  .in1 (swap_byte1[7:0]), .sel1(st_sz_hww_g_sel),
  .in2 (swap_byte5[7:0]), .sel2(st_sz_dw_g_sel),
  .dout(lsu_stb_st_data_g[47:40]));
                           
// replicated byte6
//assign	lsu_stb_st_data_g[55:48] =                 //@@ bw_u1_muxi31d_6x
//		st_sz_bhw_g ? swap_byte0 :		// swap_byte or hword
//			st_sz_w_g ? swap_byte2 :		// word
//				st_sz_wdw_g ? swap_byte6 : // dword
//					8'bxxxx_xxxx ;

   wire   st_sz_bhw_g_sel, st_sz_w_g_sel;
   assign st_sz_bhw_g_sel = st_sz_bhw_g & ~rst_tri_en;
   assign st_sz_w_g_sel = st_sz_w_g & ~rst_tri_en;
   
  
mux3ds #(8) rpl_byte6_mx (
  .in0 (swap_byte0[7:0]),
  .in1 (swap_byte2[7:0]),
  .in2 (swap_byte6[7:0]),
  .sel0(st_sz_bhw_g_sel),
  .sel1(st_sz_w_g_sel),
  .sel2(st_sz_dw_g_sel),
  .dout(lsu_stb_st_data_g[55:48]));
 
// replicated byte7
//assign	lsu_stb_st_data_g[63:56] =                //@@ bw_u1_muxi41d_6x
//		st_sz_b_g ? swap_byte0 :			// swap_byte
//			st_sz_hw_g ? swap_byte1 :	// hword
//				st_sz_w_g ? swap_byte3 :	// word
//					st_sz_dw_g ? swap_byte7 : // dword
//						8'bxxxx_xxxx ;

mux4ds #(8) rpl_byte7_mx (
  .in0(swap_byte0[7:0]), .sel0(st_sz_b_g_sel),
  .in1(swap_byte1[7:0]), .sel1(st_sz_hw_g_sel),
  .in2(swap_byte3[7:0]), .sel2(st_sz_w_g_sel),
  .in3(swap_byte7[7:0]), .sel3(st_sz_dw_g_sel),
  .dout (lsu_stb_st_data_g[63:56]));
    
//=========================================================
//stb rdata buffer
   assign stb_rdata_ramd_buf[69:0] = stb_rdata_ramd[69:0];
   assign stb_rdata_ramd_b74_buf = stb_rdata_ramd_b74;
      
endmodule
