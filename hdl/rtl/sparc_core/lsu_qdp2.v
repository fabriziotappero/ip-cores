// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: lsu_qdp2.v
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
///////////////////////////////////////////////////////////////////////
/*
//  Module Name:  LSU_QDP2
//  Description:  LSU CPX Datapath.
*/
////////////////////////////////////////////////////////////////////////
// header file includes
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


 
/*
/* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: lsu.h
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








//`define STB_PCX_WY_HI   107
//`define STB_PCX_WY_LO   106



















































































// TLB Tag and Data Format
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	


// I-TLB version - lsu_tlb only.
























// Invalidate Format
//addr<5:4>=00

















//addr<5:4>=01

















//addr<5:4>=10

















//addr<5:4>=11

















// cpuid - 4b



// CPUany, addr<5:4>=00,10





// CPUany, addr<5:4>=01,11




// CPUany, addr<5:4>=01,11




// DTAG parity error Invalidate




// CPX BINIT STORE


////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

//FPGA_SYN enables all FPGA related modifications
 




module lsu_qdp2 ( /*AUTOARG*/
   // Outputs
   so, lsu_l2fill_data, dfq_wdata, dfq_tid, lsu_dcache_fill_data_e, 
   lsu_ifill_pkt, lsu_pcx_fwd_pkt, lsu_cpx_pkt_strm_ack, 
   lsu_cpx_pkt_vld, lsu_cpx_pkt_atm_st_cmplt, lsu_cpx_pkt_tid, 
   lsu_cpx_pkt_invwy, lsu_cpx_pkt_inv_pa, lsu_cpx_pkt_l2miss, 
   lsu_dfq_byp_invwy_vld, lsu_dfq_byp_type, lsu_dfq_byp_flush, 
   lsu_dfq_byp_tid, lsu_cpu_inv_data_b13to9, lsu_cpu_inv_data_b7to2, 
   lsu_cpu_inv_data_b0, lsu_iobrdge_wr_data, lsu_iobrdge_tap_rq_type, 
   lsu_cpx_pkt_perror_dinv, lsu_cpx_pkt_perror_iinv, 
   lsu_cpx_pkt_perror_set, lsu_cpx_pkt_ld_err, lsu_dfq_byp_binit_st, 
   lsu_cpx_pkt_binit_st, lsu_cpx_pkt_prefetch, lsu_cpx_pkt_prefetch2, 
   lsu_dfq_byp_cpx_inv, lsu_dfq_byp_stack_adr_b54, 
   lsu_dfq_byp_stack_wrway, lsu_dfq_byp_atm, dcache_iob_addr_e, 
   st_dcfill_addr, lsu_st_way_e, lsu_dcache_iob_way_e, 
   lsu_st_dcfill_size_e, lsu_cpx_pkt_ifill_type, lsu_cpx_pkt_atomic, 
   // Inputs
   rst_tri_en, rclk, si, se, lsu_dfill_data_sel_hi, dfq_byp_ff_en, 
   dfq_rd_vld_d1, dfq_rdata, cpx_spc_data_cx, stb_rdata_ramd_buf, 
   stb_rdata_ramd_b74_buf, stb_rdata_ramc_buf, lsu_stb_pcx_rvld_d1, 
   lsu_diagnstc_wr_data_e, lsu_diagnstc_dc_prty_invrt_e, 
   mbist_write_data, cpx_fwd_pkt_en_cx, lsu_cpu_dcd_sel, 
   lsu_cpu_uhlf_sel, lsu_cpxpkt_type_dcd_cx, lsu_dc_iob_access_e, 
   lsu_dcfill_data_mx_sel_e, lsu_cpx_spc_inv_vld, lsu_cpx_thrdid, 
   lsu_cpx_stack_dcfill_vld, pcx_rq_for_stb_d1, lsu_dfq_ld_vld, 
   lsu_dfq_st_vld, lsu_dfq_ldst_vld
   ) ;  

/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
// End of automatics
//
   input rst_tri_en;
   
input                     rclk ;
input                     si;
input                     se;
output                    so;

input                       lsu_dfill_data_sel_hi ; // select hi or low order 8B. 
//input                       dcfill_src_dfq_sel ;
input                       dfq_byp_ff_en ;
input                       dfq_rd_vld_d1 ;
input [151:0]        dfq_rdata ;             // dfq rd output
input [145-1:0]      cpx_spc_data_cx;        // cpx to processor pkt
//input [2:0]                 stb_dfq_rd_id ;         // stb entry id 
input [69:0]                stb_rdata_ramd_buf ;        // stb0 data ram output.
input                       stb_rdata_ramd_b74_buf ;        // stb0 data ram output.
input [14:9]                stb_rdata_ramc_buf ;        // stb0 tag ram output.
input                       lsu_stb_pcx_rvld_d1 ;   // stb has been read-delayby1cycle
//input                       lsu_stb_dfq_rvld ;      // wr to dfq stb bypass ff
//input [1:0]                 lmq_pcx_pkt_sz ;
//input [39:0]                lmq_pcx_pkt_addr ;

// diagnostic write information
//input                       lsu_diagnstc_wr_src_sel_e ;    // diagnstc write - diag/store
input  [63:0]               lsu_diagnstc_wr_data_e ;       // Store data
input  [7:0]                lsu_diagnstc_dc_prty_invrt_e ; // invert parity of dw
//input  [3:0]                lsu_diagnstc_wr_way_e ;        // cache way to be written
//input  [10:0]               lsu_diagnstc_wr_addr_e ;       // address

//input                     lsu_ifill_pkt_vld ;     // ifill pkt vld
//input                     lsu_bist_wvld_e ;       // bist write to dcache
//input                     lsu_bist_rvld_e ;       // bist read from dcache  

//input   [6:0]             mbist_dcache_index ;    // bist rd/wr address 
//input                     mbist_dcache_word;
//input   [1:0]             mbist_dcache_way;   
input   [7:0]             mbist_write_data ;      // bist wdata
   
input                     cpx_fwd_pkt_en_cx ;     // cpx fwd reply/req
input   [7:0]             lsu_cpu_dcd_sel ;
input                     lsu_cpu_uhlf_sel ;
input   [5:0]             lsu_cpxpkt_type_dcd_cx ;
//input                     lsu_st_wr_sel_e ;
//input   [1:0]             lmq_ld_way ;
//input   [1:0]             lsu_st_ack_wrwy ;       // cache set way to write to.  
//input   [1:0]             lsu_st_ack_addr_b54 ;
//input   [1:0]             lsu_stb_rd_tid ;
input			  lsu_dc_iob_access_e ;	// iob read/write of dcache

//input                     tmb_l;
//input   [3:0]             lsu_dcfill_mx_sel_e;
//input                     lsu_dcfill_addr_mx_sel_e;
input                     lsu_dcfill_data_mx_sel_e;

input                     lsu_cpx_spc_inv_vld;
input   [3:0]             lsu_cpx_thrdid;
input                     lsu_cpx_stack_dcfill_vld ;
input   [3:0]             pcx_rq_for_stb_d1;

input                     lsu_dfq_ld_vld ;
input                     lsu_dfq_st_vld ;
input                     lsu_dfq_ldst_vld ;

/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
// End of automatics
//

output  [63:0]            lsu_l2fill_data ;       // dfill data for write to irf

output  [151:0]    dfq_wdata ;
output  [1:0]             dfq_tid ;               // thread-id for load at head of DFQ.

output  [143:0]           lsu_dcache_fill_data_e ;// store-write/ld-miss fill 

output  [144-1:0]  lsu_ifill_pkt ;
output  [107:0]           lsu_pcx_fwd_pkt ;       // local fwd reply/req 
output               	  lsu_cpx_pkt_strm_ack ;
output                    lsu_cpx_pkt_vld ;
output                    lsu_cpx_pkt_atm_st_cmplt ;
output  [1:0]             lsu_cpx_pkt_tid ;
output  [1:0]             lsu_cpx_pkt_invwy ;     // invalidate way
output  [4:0]             lsu_cpx_pkt_inv_pa ;    // invalidate pa [10:6]
output			  lsu_cpx_pkt_l2miss ;	// ld req missed in L2
output                    lsu_dfq_byp_invwy_vld ;
output  [5:0]             lsu_dfq_byp_type ;
output                    lsu_dfq_byp_flush ;
//output  [2:0]             lsu_dfq_byp_cpuid ;
output  [1:0]             lsu_dfq_byp_tid ;
//output  [13:0]            lsu_cpu_inv_data ;
output  [13:9]            lsu_cpu_inv_data_b13to9 ;
output  [7:2]             lsu_cpu_inv_data_b7to2 ;
output                    lsu_cpu_inv_data_b0 ;
//output                    lsu_dfq_byp_stquad_pkt2 ;
//output                    lsu_cpx_pkt_stquad_pkt2 ;
output  [43:0]            lsu_iobrdge_wr_data ;
output  [8:0]             lsu_iobrdge_tap_rq_type ;
//output                    lsu_dfq_byp_perror_dinv ;  // dtag perror corr. st ack
//output                    lsu_dfq_byp_perror_iinv ;  // itag perror corr. st ack
output                    lsu_cpx_pkt_perror_dinv ;  // dtag perror corr. st ack
output                    lsu_cpx_pkt_perror_iinv ;  // itag perror corr. st ack
output  [1:0]             lsu_cpx_pkt_perror_set ;  // dtag perror - spec. b54
output  [1:0]             lsu_cpx_pkt_ld_err ;      // err field - cpx ld pkt
output			  lsu_dfq_byp_binit_st ;	// blk-init st in bypass.
output			  lsu_cpx_pkt_binit_st ;    // blk-init store
output			  lsu_cpx_pkt_prefetch;    // prefetch
output			  lsu_cpx_pkt_prefetch2;   // prefetch - for dctl

output                    lsu_dfq_byp_cpx_inv;
//output			  lsu_dfq_byp_stack_dcfill_vld;
output  [1:0]             lsu_dfq_byp_stack_adr_b54;
output  [1:0]             lsu_dfq_byp_stack_wrway;
output                    lsu_dfq_byp_atm;

   //dcache_fill_addr_e change
   output [7:0]           dcache_iob_addr_e;
   output [10:0]          st_dcfill_addr;

   output [1:0]           lsu_st_way_e;
   output [1:0]           lsu_dcache_iob_way_e;

   output [1:0]           lsu_st_dcfill_size_e;
   
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
// End of automatics
wire  [13:0]      cpx_cpulo_inv_data ;
wire  [13:0]      cpx_cpuhi_inv_data ;
//wire  [`STB_PCX_WIDTH-1:0]  stb_pcx_pkt ;
//wire  [`STB_DFQ_WIDTH-1:0]  stb_dfq_pkt_data ;
wire  [83-1:0]  stb_dfq_data_in ;
//wire  [`DFQ_WIDTH-1:0]  cpx_dfq_data ;
//wire  [`DFQ_WIDTH-1:0]  cpx_dfq_data_d1 ;
//wire  [`CPX_WIDTH-1:0]  cpx_data_cx_d1 ;
//wire        cpx_st_cmplt_d1 ;
wire  [151:0]  dfq_byp_mx_data ;
wire  [151-1:0]    dfq_byp_ff_data ;
//wire  [`STB_DFQ_WIDTH-1:0]  store_dfq_pkt ;
wire  [127:0]   st_dcfill_data ;
wire  [63:0]      dcache_wr_data ;
wire  [127:0]   ldinv_dcfill_data ;
//wire  [`LMQ_WIDTH-1:0]  lmq0_pcx_pkt, lmq1_pcx_pkt ;
//wire  [`LMQ_WIDTH-1:0]  lmq2_pcx_pkt, lmq3_pcx_pkt ;
wire  [127:0] lsu_dcfill_data ;
wire  [15:0]      dcache_wr_parity_mod ;
//wire  [3:0]     bist_rsel_way_e ;
wire  [107:0]     cpx_fwd_pkt_din ;

//wire [3:0]     bist_rsel_way_m ;
//wire [3:0]     lsu_bist_rsel_way_wb ;  // way select for read
wire  [1:0]  cpx_st_dcfill_wrway;
wire  [82:0]   stb_dcfill_data_mx;
wire           clk;
wire  [13:0]            lsu_cpu_inv_data ;

assign  clk = rclk;


//=================================================================================================
//      STB Datapath
//=================================================================================================

// PCX PKT FORMATTING
// THREAD0
//assign stb_pcx_pkt[`STB_PCX_VLD] = lsu_stb_pcx_rvld_d1 ;    // Valid
// Support stores for now.
//assign stb_pcx_pkt[`STB_PCX_RQ_HI:`STB_PCX_RQ_LO] = stb_rdata_ramd[74:72] ; // Rq-type
//assign stb_pcx_pkt[`STB_PCX_NC] = stb_rdata_ramd[74] ;  // NC
// cpu-id will be inserted on way out of core.
//assign  stb_pcx_pkt[`STB_PCX_TH_HI:`STB_PCX_TH_LO] = lsu_stb_rd_tid[1:0] ;  // TID
// bf-id is not required.
//assign  stb_pcx_pkt[`STB_PCX_WY_HI:`STB_PCX_WY_LO] = stb_rdata_ramd[71:70] ;  // WAY
//assign  stb_pcx_pkt[`STB_PCX_SZ_HI:`STB_PCX_SZ_LO] = 
//      stb_rdata_ramd[69:68];        // Size
//assign  stb_pcx_pkt[`STB_PCX_AD_HI:`STB_PCX_AD_LO] = 
//      {stb_rdata_ramc[44:9],stb_rdata_ramd[67:64]} ;// Addr        
//assign  stb_pcx_pkt[`STB_PCX_DA_HI:`STB_PCX_DA_LO] = 
//      stb_rdata_ramd[63:0];         // Data   

// STB to DFQ Data Formatting
// THREAD0
assign  stb_dfq_data_in[83-1:0] =
  {lsu_stb_pcx_rvld_d1,                         // 82:82 vld  //stb_pcx_pkt[`STB_PCX_VLD],
  stb_rdata_ramd_b74_buf,                           // 81:81 ??   //stb_rdata_ramd[74],
  2'b00,                                        // 80:79 not used
  //stb_pcx_pkt[`STB_PCX_WY_HI:`STB_PCX_WY_LO],
  3'b000,                                       // 78:76 instead of stb_dfq_rd_id[2:0],
  stb_rdata_ramd_buf[69:68],                        // 75:74 size //stb_pcx_pkt[`STB_PCX_SZ_HI:`STB_PCX_SZ_LO], 
  {stb_rdata_ramc_buf[14:9],stb_rdata_ramd_buf[67:64]}, // 73:64 Addr //stb_pcx_pkt[`STB_PCX_AD_LO+9:`STB_PCX_AD_LO],
  stb_rdata_ramd_buf[63:0]};                        // 63:0  data  //stb_pcx_pkt[`STB_PCX_DA_HI:`STB_PCX_DA_LO]};


// STB DATA BYPASS FLOP
// Data is read out on read for pcx. The data is then
// bypassed to the dfq when the st-ack is received.
//wire  [3:0]   pcx_rq_for_stb_d1;
wire  [3:0]   clk_stb_data;
wire  [82:0]  stb_dfq_pkt_data0,
                        stb_dfq_pkt_data1,
                        stb_dfq_pkt_data2,
                        stb_dfq_pkt_data3;

// timing fix: 9/15/03 - reduce loading on pcx_rq_for_stb[3:0] to stb_clt[0-3]. it had FO2 (stb_ctl,qdp2 - cap=0.5-0.8)
//             move the flop from qdp2 to qctl1

//flop pcx rq to read stb data
//dff  #(4) pcx_rq_for_stb_ff (                       
//           .din  (pcx_rq_for_stb[3:0]),
//           .q    (pcx_rq_for_stb_d1[3:0]),
//           .clk  (clk), 
//           .se   (1'b0),       .si (),          .so ());                                

//dffe  #(83) stb_dfq_byp_ff (
//        .din  (stb_dfq_data_in[`STB_DFQ_VLD:0]), 
//  .q    (stb_dfq_pkt_data[`STB_DFQ_VLD:0]),
//        .en   (lsu_stb_dfq_rvld), .clk (clk),
//        .se     (1'b0),       .si (),          .so ()
//        );

//THREAD0








                                                 

dffe  #(83) stb_dfq_byp0_ff (                       
           .din  (stb_dfq_data_in[82:0]),
           .q    (stb_dfq_pkt_data0[82:0]),
           .en (~(~pcx_rq_for_stb_d1[0])), .clk(clk), 
           .se   (1'b0),       .si (),          .so ());                                








//THREAD1








                                                 

dffe  #(83) stb_dfq_byp1_ff (                       
           .din  (stb_dfq_data_in[82:0]),
           .q    (stb_dfq_pkt_data1[82:0]),
           .en (~(~pcx_rq_for_stb_d1[1])), .clk(clk), 
           .se   (1'b0),       .si (),          .so ());                                








//THREAD2








                                                 

dffe  #(83) stb_dfq_byp2_ff (                       
           .din  (stb_dfq_data_in[82:0]),
           .q    (stb_dfq_pkt_data2[82:0]),
           .en (~(~pcx_rq_for_stb_d1[2])), .clk(clk), 
           .se   (1'b0),       .si (),          .so ());                                








//THREAD3








                                                 

dffe  #(83) stb_dfq_byp3_ff (                       
           .din  (stb_dfq_data_in[82:0]),
           .q    (stb_dfq_pkt_data3[82:0]),
           .en (~(~pcx_rq_for_stb_d1[3])), .clk(clk), 
           .se   (1'b0),       .si (),          .so ());                                








// MUX the store data if cpx_pkt==st_ack w/ dcfill vld=1
mux4ds  #(82+1) stb_data_mx (
  .in0  (stb_dfq_pkt_data0[82:0]),
  .in1  (stb_dfq_pkt_data1[82:0]),
  .in2  (stb_dfq_pkt_data2[82:0]),
  .in3  (stb_dfq_pkt_data3[82:0]),
  .sel0 (lsu_cpx_thrdid[0]),  
  .sel1 (lsu_cpx_thrdid[1]),
  .sel2 (lsu_cpx_thrdid[2]),
  .sel3 (lsu_cpx_thrdid[3]),
  .dout (stb_dcfill_data_mx[82:0])
);

//NOTE: mux this raw data w/ modified data to generate dfq input and feed into dfq_wdata




//=================================================================================================
//    FWD PKT - REQ/REPLY
//=================================================================================================

// Design Note !! - Bus can be decreased - do not have to keep tag.

// TAP ACCESS FORMAT
// BEGIN (OLD)
// Control bits :
// R/W,TID,BIST,MARGIN,DEFEATURE,PC (R=1,W=0)
// These 7b are mapped to bits 70:64 of the cpx pkt.
// (R/W is the highest order bit). 
// *Note that a write to pc is ignored by hardware.
// *The cpx-reply will not contain the control information.
// *TID(Thread id) applies only to pc and defeature.
// Data bits :
// PC(48b),Margin(36b),Bist-Ctl(14b),Defeature(4b).
// The largest field of 48b is mapped to bits 47:0 of the cpx pkt.
// END (OLD)

// Control bits (mapped to data[127:96] of cpx packet):
// L1I data,L1D data,BIST,MARGIN,DEFEATURE,PC,TID[1:0]
// These 8b are mapped to bits 103:96 of the cpx pkt.
// Unused bits are zeros.
// (TID is the lowest order 2 bits).
// *Note that a write to pc is ignored by hardware.
// *The cpx-reply will not contain the control information.
// *TID(Thread id) applies only to pc and defeature.
//
// Address bits (mapped to data[95:64] of cpx packet):
// This is used to access the L1 cache arrays.  This field
// is a dont-care for the bist/margin/defeature/pc ASIs.
// Only the lower 32 address bits are specified here.
// The core (lsu) will pad zeros create a 64-bit address.
//
// Data bits (mapped to data[63:0] of cpx packet):
// PC(48b),Margin(36b),Bist-Ctl(14b),Defeature(4b).
// The largest field of 48b is mapped to bits 47:0 of the cpx pkt.


// Formatted to contain fwd req which is of largest size.
// Truncate address !!! 40b should not be required.
assign  cpx_fwd_pkt_din[107:0] = 
  {
  cpx_spc_data_cx[136], // r/!w   (1b)
  cpx_spc_data_cx[133:131], // src/tar  (3b)
  cpx_spc_data_cx[103:0]    // 64b data + 40b addr (104b)
  } ;

// Contains cpx fwd reply or req
//dffe  #(108) fwdpkt_ff  (
//        .din  (cpx_fwd_pkt_din[107:0]), 
//  .q    (lsu_pcx_fwd_pkt[107:0]),
//        .en   (cpx_fwd_pkt_en_cx), 
//  .clk  (clk),
//        .se     (1'b0),       .si (),          .so ()
//        );









                                                         

dffe  #(108) fwdpkt_ff  (                                  
            .din  (cpx_fwd_pkt_din[107:0]),                
            .q    (lsu_pcx_fwd_pkt[107:0]),                 
            .en (~(~cpx_fwd_pkt_en_cx)), .clk(clk),                   
            .se     (1'b0),       .si (),          .so ());   









// New mapping for address bits given that tag is gone. (OBSOLETE)
// pkt[74:73] - Way
// pkt[72:65] - Set Index
// pkt[64] - Word
// New mapping - based on 0-in testing, alignment with PRM.
// pkt[76:75] - Way
// pkt[74:68] - Set Index
// pkt[67] -DWord

wire [7:0] dcache_iob_addr_e ;
assign	dcache_iob_addr_e[7:0] = lsu_pcx_fwd_pkt[74:67] ;

//wire [3:0] dcache_iob_wy_e ; 
//assign	dcache_iob_wy_e[0] = ~lsu_pcx_fwd_pkt[76] & ~lsu_pcx_fwd_pkt[75] ;
//assign	dcache_iob_wy_e[1] = ~lsu_pcx_fwd_pkt[76] &  lsu_pcx_fwd_pkt[75] ;
//assign	dcache_iob_wy_e[2] =  lsu_pcx_fwd_pkt[76] & ~lsu_pcx_fwd_pkt[75] ;
//assign	dcache_iob_wy_e[3] =  lsu_pcx_fwd_pkt[76] &  lsu_pcx_fwd_pkt[75] ;

assign lsu_dcache_iob_way_e [1:0] =  {lsu_pcx_fwd_pkt[76],  lsu_pcx_fwd_pkt[75]};
  
wire [63:0] dcache_iob_data_e ; 
assign	dcache_iob_data_e[63:0] = lsu_pcx_fwd_pkt[63:0] ;

assign  lsu_iobrdge_wr_data[43:0] = lsu_pcx_fwd_pkt[43:0] ;
assign  lsu_iobrdge_tap_rq_type[8:0] = {lsu_pcx_fwd_pkt[107],lsu_pcx_fwd_pkt[103:96]} ;

//=================================================================================================
//    DFQ PKT SELECTION
//=================================================================================================

// There are two sources :
// - from the ccx - load,inv 
// - from the stb - ack'ed store update.
// ** store updates do not have to be inserted into DFQ for ordering purposes. An inv will
// clear stale data in the stb and bypass flops to ensure TSO.

// to be written to dfq if bypass full else wr to byp mx.
//assign  dfq_wdata[`DFQ_WIDTH:0] = 
//  {lsu_cpx_spc_inv_vld,lsu_cpxpkt_type_dcd_cx[5:0],cpx_spc_data_cx[`CPX_WIDTH-1:0]};
//  //{{(`DFQ_WIDTH-`CPX_WIDTH)1'b0},cpx_spc_data_cx[`CPX_WIDTH-1:0]},

wire  [151:0]  dfq_st_data,dfq_cpx_raw_wdata;
wire  [1:0]           cpx_st_ack_addr_b54;

assign  dfq_cpx_raw_wdata[151:0] = 
  {lsu_cpx_spc_inv_vld,lsu_cpxpkt_type_dcd_cx[5:0],cpx_spc_data_cx[145-1:0]};

assign  dfq_st_data[151:0]  =  
        {lsu_cpx_spc_inv_vld,lsu_cpxpkt_type_dcd_cx[5:0],
         cpx_spc_data_cx[145-1:87],
         cpx_st_ack_addr_b54[1:0],             // 86:85
         cpx_st_dcfill_wrway[1:0],             // 84:83
         stb_dcfill_data_mx[82:0]};  // 82:0

mux2ds  #(151+1) dfq_st_data_mx (
  .in0  (dfq_st_data[151:0]),
  .in1  (dfq_cpx_raw_wdata[151:0]),
  .sel0 (lsu_cpx_stack_dcfill_vld),  
  .sel1 (~lsu_cpx_stack_dcfill_vld),
  .dout (dfq_wdata[151:0])
);

//timing fix: 05/31/03: decouple byp mux from lsu_cpx_stack_dcfill_vld
//            i.e. replace dfq_wdata w/ dfq_cpx_raw_wdata in byp mux
// select between dfq output and cpx bypass.
mux2ds  #(151+1) dfq_byp_mx (
  .in0  (dfq_rdata[151:0]),
  .in1  (dfq_cpx_raw_wdata[151:0]),
  .sel0 (dfq_rd_vld_d1),  
  .sel1 (~dfq_rd_vld_d1),
  .dout (dfq_byp_mx_data[151:0])
);

assign  lsu_dfq_byp_cpx_inv     =   dfq_byp_mx_data[151];
assign  lsu_dfq_byp_tid[1:0]    =   dfq_byp_mx_data[135:134] ;
//assign  lsu_dfq_byp_cpuid[2:0]  =   dfq_byp_mx_data[`CPX_INV_CID_HI:`CPX_INV_CID_LO] ;
assign  lsu_dfq_byp_flush = 	dfq_byp_mx_data[136] ;
assign  lsu_dfq_byp_invwy_vld = dfq_byp_mx_data[133] ;

//assign  lsu_dfq_byp_type[5:0]   =   dfq_byp_mx_data[`DFQ_WIDTH-1:`DFQ_WIDTH-6] ;
assign  lsu_dfq_byp_type[5:3]   =   dfq_byp_mx_data[151-1:151-3] ;
assign  lsu_dfq_byp_type[2]   =   dfq_byp_mx_data[151-4] & dfq_rd_vld_d1;
assign  lsu_dfq_byp_type[1:0]   =   dfq_byp_mx_data[151-5:151-6] ;

//assign  lsu_dfq_byp_stquad_pkt2 =   dfq_byp_mx_data[130] ;
assign  lsu_dfq_byp_binit_st =   dfq_byp_mx_data[125] ;
//assign  lsu_dfq_byp_perror_iinv    = dfq_byp_mx_data[`CPX_PERR_DINV+1] ;
//assign  lsu_dfq_byp_perror_dinv    = dfq_byp_mx_data[`CPX_PERR_DINV] ;
//assign  lsu_dfq_byp_stack_dcfill_vld =   dfq_byp_mx_data[87] ;
assign  lsu_dfq_byp_stack_adr_b54[1:0] =   dfq_byp_mx_data[86:85] ;
assign  lsu_dfq_byp_stack_wrway[1:0] =   dfq_byp_mx_data[84:83] ;

assign  lsu_ifill_pkt[144-1:0] = dfq_byp_mx_data[144-1:0] ;
//assign  lsu_ifill_pkt[`CPX_WIDTH-1:0] = {lsu_ifill_pkt_vld,dfq_byp_mx_data[`CPX_VLD-1:0]} ;

assign  lsu_dfq_byp_atm  = dfq_byp_mx_data[129] ;

// Decode in qctl !!!
//assign  dfq_byp_tid[1:0] = dfq_byp_mx_data[`CPX_TH_HI:`CPX_TH_LO] ;
//assign  dfq_byp_tid[1:0] = dfq_byp_mx_data[`DFQ_TH_HI:`DFQ_TH_LO] ;

// Stage dfq output
// In case of multiple inv or other such cases, pkt will be held in
// byp ff until pkt completely utilized.
//dffe  #(`DFQ_WIDTH) dfq_data_stg (
//        .din  (dfq_byp_mx_data[`DFQ_WIDTH-1:0]),
//  .q    (dfq_byp_ff_data[`DFQ_WIDTH-1:0]),
//        .en (dfq_byp_ff_en),  .clk  (clk),
//        .se     (1'b0),     .si (),          .so ()
//);









                                                        

dffe  #(151) dfq_data_stg (                        
                  .din  (dfq_byp_mx_data[151-1:0]),
                  .q    (dfq_byp_ff_data[151-1:0]),
                  .en (~(~dfq_byp_ff_en)), .clk(clk),
                  .se   (1'b0),     .si (),          .so ());









// To be decoded in qctl
//assign  lsu_st_cmplt_type = dfq_byp_ff_data[`DFQ_ST_CMPLT];

assign  dfq_tid[1:0] = dfq_byp_ff_data[135:134] ;

output    lsu_cpx_pkt_ifill_type;
output    lsu_cpx_pkt_atomic ;

// Should some of these be in-flight ?
//assign  lsu_cpx_pkt_rqtype[3:0]   = dfq_byp_ff_data[`CPX_RQ_HI:`CPX_RQ_LO] ;
assign  lsu_cpx_pkt_ifill_type    = dfq_byp_ff_data[151-2];
assign  lsu_cpx_pkt_tid[1:0]      = dfq_byp_ff_data[135:134] ;
assign  lsu_cpx_pkt_vld     = dfq_byp_ff_data[144] ;
assign  lsu_cpx_pkt_atm_st_cmplt  = dfq_byp_ff_data[129] ;
assign  lsu_cpx_pkt_invwy[1:0]    = dfq_byp_ff_data[132:131] ;
// Upper 6bits are used to store decoded request type information.
assign  lsu_cpx_pkt_strm_ack   = dfq_byp_ff_data[151-5];
//assign  lsu_cpx_pkt_inv_pa[4:0]   = dfq_byp_ff_data[`CPX_INV_PA_HI-1:`CPX_INV_PA_LO];  //!!
assign  lsu_cpx_pkt_inv_pa[4:0]   = dfq_byp_ff_data[116:112];
assign  lsu_cpx_pkt_atomic    = dfq_byp_ff_data[129]  | //atomic st ack
            dfq_byp_ff_data[131]  ; //stquad pkt1
//assign  lsu_cpx_pkt_stquad_pkt2   = dfq_byp_ff_data[130] ;
assign  lsu_cpx_pkt_binit_st   = dfq_byp_ff_data[125] ;
assign  lsu_cpx_pkt_prefetch = dfq_byp_ff_data[128] ; // for qctl2
assign  lsu_cpx_pkt_prefetch2 = dfq_byp_ff_data[128] ;  // for dctl
//assign	lsu_spu_strm_st = dfq_byp_ff_data[134] ; // strm store ack (vs. ma)

assign  lsu_cpx_pkt_perror_iinv    = dfq_byp_ff_data[123+1] ;
assign  lsu_cpx_pkt_perror_dinv    = dfq_byp_ff_data[123] ;
assign  lsu_cpx_pkt_perror_set[1:0] = 
	dfq_byp_ff_data[122:121] ;

assign  lsu_cpx_pkt_ld_err[1:0] = dfq_byp_ff_data[138:137] ;  
assign  lsu_cpx_pkt_l2miss = dfq_byp_ff_data[139] ;  


//=================================================================================================
//      DFQ OUTPUT - LOCAL PROCESSING
//=================================================================================================


mux4ds  #(14) invfld_lo_sel (
        .in0    ({dfq_byp_mx_data[90:88],
                  dfq_byp_mx_data[59:56],
                  dfq_byp_mx_data[34:32],
                  dfq_byp_mx_data[3:0]}),
        .in1    ({dfq_byp_mx_data[93:91],
                  dfq_byp_mx_data[63:60],
                  dfq_byp_mx_data[37:35],
                  dfq_byp_mx_data[7:4]}),
        .in2    ({dfq_byp_mx_data[96:94],
                  dfq_byp_mx_data[67:64],
                  dfq_byp_mx_data[40:38],
                  dfq_byp_mx_data[11:8]}),
        .in3    ({dfq_byp_mx_data[99:97],
                  dfq_byp_mx_data[71:68],
                  dfq_byp_mx_data[43:41],
                  dfq_byp_mx_data[15:12]}),
        .sel0   (lsu_cpu_dcd_sel[0]),
        .sel1   (lsu_cpu_dcd_sel[1]),
        .sel2   (lsu_cpu_dcd_sel[2]),
        .sel3   (lsu_cpu_dcd_sel[3]),
        .dout   (cpx_cpulo_inv_data[13:0])
);

mux4ds  #(14) invfld_hi_sel (
        .in0    ({dfq_byp_mx_data[102:100],
                  dfq_byp_mx_data[75:72],
                  dfq_byp_mx_data[46:44],
                  dfq_byp_mx_data[19:16]}),
        .in1    ({dfq_byp_mx_data[105:103],
                  dfq_byp_mx_data[79:76],
                  dfq_byp_mx_data[49:47],
                  dfq_byp_mx_data[23:20]}),
        .in2    ({dfq_byp_mx_data[108:106],
                  dfq_byp_mx_data[83:80],
                  dfq_byp_mx_data[52:50],
                  dfq_byp_mx_data[27:24]}),
        .in3    ({dfq_byp_mx_data[111:109],
                  dfq_byp_mx_data[87:84],
                  dfq_byp_mx_data[55:53],
                  dfq_byp_mx_data[31:28]}),
        .sel0   (lsu_cpu_dcd_sel[4]),
        .sel1   (lsu_cpu_dcd_sel[5]),
        .sel2   (lsu_cpu_dcd_sel[6]),
        .sel3   (lsu_cpu_dcd_sel[7]),
        .dout   (cpx_cpuhi_inv_data[13:0])
);


mux2ds  #(14) invfld_sel (
        .in0    (cpx_cpulo_inv_data[13:0]),
        .in1    (cpx_cpuhi_inv_data[13:0]),
        .sel0   (~lsu_cpu_uhlf_sel),  
        .sel1   (lsu_cpu_uhlf_sel),
        .dout   (lsu_cpu_inv_data[13:0])
);

assign  lsu_cpu_inv_data_b13to9[13:9]  =  lsu_cpu_inv_data[13:9] ;
assign  lsu_cpu_inv_data_b7to2[7:2]  =  lsu_cpu_inv_data[7:2] ;
assign  lsu_cpu_inv_data_b0  =  lsu_cpu_inv_data[0] ;

// same structure as above for st data write way
wire  [13:0] cpx_cpulo_dcfill_wrway,
             cpx_cpuhi_dcfill_wrway,
             cpx_st_dcfill_wrway_sel;
             

mux4ds  #(14) st_dcfill_wrway_lo (
        .in0    ({cpx_spc_data_cx[90:88],
                  cpx_spc_data_cx[59:56],
                  cpx_spc_data_cx[34:32],
                  cpx_spc_data_cx[3:0]}),
        .in1    ({cpx_spc_data_cx[93:91],
                  cpx_spc_data_cx[63:60],
                  cpx_spc_data_cx[37:35],
                  cpx_spc_data_cx[7:4]}),
        .in2    ({cpx_spc_data_cx[96:94],
                  cpx_spc_data_cx[67:64],
                  cpx_spc_data_cx[40:38],
                  cpx_spc_data_cx[11:8]}),
        .in3    ({cpx_spc_data_cx[99:97],
                  cpx_spc_data_cx[71:68],
                  cpx_spc_data_cx[43:41],
                  cpx_spc_data_cx[15:12]}),
        .sel0   (lsu_cpu_dcd_sel[0]),
        .sel1   (lsu_cpu_dcd_sel[1]),
        .sel2   (lsu_cpu_dcd_sel[2]),
        .sel3   (lsu_cpu_dcd_sel[3]),
        .dout   (cpx_cpulo_dcfill_wrway[13:0])
);

mux4ds  #(14) st_dcfill_wrway_hi (
        .in0    ({cpx_spc_data_cx[102:100],
                  cpx_spc_data_cx[75:72],
                  cpx_spc_data_cx[46:44],
                  cpx_spc_data_cx[19:16]}),
        .in1    ({cpx_spc_data_cx[105:103],
                  cpx_spc_data_cx[79:76],
                  cpx_spc_data_cx[49:47],
                  cpx_spc_data_cx[23:20]}),
        .in2    ({cpx_spc_data_cx[108:106],
                  cpx_spc_data_cx[83:80],
                  cpx_spc_data_cx[52:50],
                  cpx_spc_data_cx[27:24]}),
        .in3    ({cpx_spc_data_cx[111:109],
                  cpx_spc_data_cx[87:84],
                  cpx_spc_data_cx[55:53],
                  cpx_spc_data_cx[31:28]}),
        .sel0   (lsu_cpu_dcd_sel[4]),
        .sel1   (lsu_cpu_dcd_sel[5]),
        .sel2   (lsu_cpu_dcd_sel[6]),
        .sel3   (lsu_cpu_dcd_sel[7]),
        .dout   (cpx_cpuhi_dcfill_wrway[13:0])
);



mux2ds  #(14) st_dcfill_wrway_sel (
        .in0    (cpx_cpulo_dcfill_wrway[13:0]),
        .in1    (cpx_cpuhi_dcfill_wrway[13:0]),
        .sel0   (~lsu_cpu_uhlf_sel),
        .sel1   (lsu_cpu_uhlf_sel),
        .dout   (cpx_st_dcfill_wrway_sel[13:0])
);

// select the appropriate offset

//bug3718 - 0in bug - cpx_st_dcfill_wrway_sel can be multi-hot foe non-stack cpx responses
//          hence qual w/ stack req type
wire  [3:0]  st_dcfill_wrway_mxsel ;

assign st_dcfill_wrway_mxsel[0] =  (lsu_cpxpkt_type_dcd_cx[2] & cpx_st_dcfill_wrway_sel[0]) & ~rst_tri_en ;
assign st_dcfill_wrway_mxsel[1] =  (lsu_cpxpkt_type_dcd_cx[2] & cpx_st_dcfill_wrway_sel[4]) & ~rst_tri_en ;
assign st_dcfill_wrway_mxsel[2] =  (lsu_cpxpkt_type_dcd_cx[2] & cpx_st_dcfill_wrway_sel[7]) & ~rst_tri_en ;
assign st_dcfill_wrway_mxsel[3] =  ~|st_dcfill_wrway_mxsel[2:0] | rst_tri_en;

mux4ds  #(2) st_dcfill_wrway_sel_b54 (
        .in0    (cpx_st_dcfill_wrway_sel[3:2]),
        .in1    (cpx_st_dcfill_wrway_sel[6:5]),
        .in2    (cpx_st_dcfill_wrway_sel[10:9]),
        .in3    (cpx_st_dcfill_wrway_sel[13:12]),
        .sel0   (st_dcfill_wrway_mxsel[0]),
        .sel1   (st_dcfill_wrway_mxsel[1]),
        .sel2   (st_dcfill_wrway_mxsel[2]),
        .sel3   (st_dcfill_wrway_mxsel[3]),
        .dout   (cpx_st_dcfill_wrway[1:0])
);


assign  cpx_st_ack_addr_b54[0] = cpx_st_dcfill_wrway_sel[4] | cpx_st_dcfill_wrway_sel[11] ;
assign  cpx_st_ack_addr_b54[1] = cpx_st_dcfill_wrway_sel[7] | cpx_st_dcfill_wrway_sel[11] ;

//=================================================================================================


//assign store_dfq_pkt[`STB_DFQ_WIDTH-1:0] = stb_dfq_pkt_data[`STB_DFQ_WIDTH-1:0] ;

// Items generated/prior to fill cycle (but after DFQ read).
// This logic will be put in qctl and then be fwded to dcache.
// - Parity (16b) - load & store.
// - Byte Enable (16b) - store (8b), ld (16b) all high.
// - Cache Tag (30b) - obtained from LMQ.
// - RD1 (5b) - obtained from LMQ.
// - RD2 (5b) - obtained from LMQ.
// ** DFQ will contain either loads or inv.

// Need to do alignment. Assume dw for now.
// For a load, a bypass will always happen, a write is 
  
// Mux in diagnostic information. Only data is muxed in because
// all other info is critical

   wire [63:0] diagnstc_wr_data;
   
dff  #(64) diagnstc_wr_data_ff (
        .din    (lsu_diagnstc_wr_data_e[63:0]), 
        .q      (diagnstc_wr_data[63:0]),
        .clk    (clk),
        .se     (1'b0),     .si (),          .so ()
        ); 
   
mux2ds  #(64) dcwr_sel (
  //.in0  ({store_dfq_pkt[`STB_DFQ_DA_HI:`STB_DFQ_DA_LO]}),
  .in0  ({dfq_byp_ff_data[63:0]}),
  .in1  ({diagnstc_wr_data[63:0]}),
  .sel0 ( lsu_dfq_st_vld),  
  .sel1 (~lsu_dfq_st_vld),
  //.sel0 (~lsu_diagnstc_wr_src_sel_e),  
  //.sel1 ( lsu_diagnstc_wr_src_sel_e),
  .dout (dcache_wr_data[63:0])
);


// store currently assumed to be dword.
// st dword is duplicated across 16B.
// currently assume st and not atomics supported.
// The width can be reduced !!!
assign st_dcfill_data[127:0] =
  {                                                            //dfq_byp_ff_data[`STB_DFQ_VLD],
                                                               //2'b00,   // need thread-id
                                                               //2'b00,1'b0,5'b00000,
//   dfq_byp_ff_data[84:83],                          // 131:130 - wr_way[1:0]
//   dfq_byp_ff_data[`STB_DFQ_SZ_HI:`STB_DFQ_SZ_LO],  // 129:128 - size[1:0]
                                                               //29'd0,                                           //!!! reduce 
                                                               //{dfq_byp_ff_data[`CPX_INV_PA_HI:`CPX_INV_PA_LO], // addr 10:6
                                                               //dfq_byp_ff_data[86:85],        // addr 5:4
                                                               //dfq_byp_ff_data[`STB_DFQ_AD_LO+3:`STB_DFQ_AD_LO]}, // addr 3:0
   dcache_wr_data[63:0],                            // 127:64
   dcache_wr_data[63:0]};                           // 63:0

   assign st_dcfill_addr[10:0] =    
   {dfq_byp_ff_data[116:112],    // addr 10:6
    dfq_byp_ff_data[86:85],                            // addr 5:4
    dfq_byp_ff_data[64+3:64]}; // addr 3:0
   
// lmq0_pcx_pkt will have to be brought in. Same for lmq_ld_addr
// The width can be reduced !!!

//potentially we can take one cycle earlier version dfq_st_data   
   assign lsu_st_way_e[1:0] = dfq_byp_ff_data[84:83];
   assign lsu_st_dcfill_size_e [1:0] = dfq_byp_ff_data[75:74];
       
assign ldinv_dcfill_data[127:0] =
  {                                                            //1'b0,
                                                               //dfq_byp_ff_data[`DFQ_TH_HI:`DFQ_TH_LO],
                                                               //dfq_byp_ff_data[`DFQ_LD_TYPE:`DFQ_INV_TYPE],
                                                               //1'b1,  //assume ld always writes.
                                                               //5'b00000,
//   lmq_ld_way[1:0],                                // 131:130 - way[1:0]- dfq_byp_ff_data[`DFQ_WY_HI:`DFQ_WY_LO],
//   2'b0,                                           // 129:128 - size[1:0]- lmq_pcx_pkt_sz[1:0],      //!!! reduce 
                                                               //40'b0,  //lmq_pcx_pkt_addr[39:0],   //!!! reduce
   dfq_byp_ff_data[127:0]};        // 127:0


// Select between dfq-bypass (ld-inv) and store.
// *** cpu-id currently hardwired in pkt
// This may be further restricted in width !!!

mux2ds  #(128) dfq_pkt_src (
  .in0  (st_dcfill_data[127:0]),    
  .in1  (ldinv_dcfill_data[127:0]), 
  .sel0 (~lsu_dfq_ld_vld),  
  .sel1 (lsu_dfq_ld_vld),
  .dout (lsu_dcfill_data[127:0])
);

// Parity Generation for write data - from load or store.
wire  [15:0]  dcache_wr_parity ;
lsu_dc_parity_gen parity_gen (
    .data_in  (lsu_dcfill_data[127:0]),
    .parity_out (dcache_wr_parity[15:0])
  );

// Bug 4125. Corrupt parity if l2 unc err detected. Corrupt both upper and lower half
// as subsequent read will pick up one of two halves.
//wire	parity_byte0_flip ;
//wire	parity_byte8_flip ;
wire	ld_unc_error ;
assign	ld_unc_error = (dfq_byp_ff_data[138] & dfq_byp_ff_data[151-1]); // not critical !

//bug7021/ECO7022
//assign	parity_byte0_flip = dcache_wr_parity[0] ^ ld_unc_error ;
//assign	parity_byte8_flip = dcache_wr_parity[8] ^ ld_unc_error ;

   wire [15:0] parity_byte_flip;
   assign      parity_byte_flip[15:0] = dcache_wr_parity[15:0] ^ {16{ld_unc_error }};
   
//assign  dcache_wr_parity_mod[15:0]  =
//    lsu_diagnstc_wr_src_sel_e ? 
//    ({lsu_diagnstc_dc_prty_invrt_e[7:0],lsu_diagnstc_dc_prty_invrt_e[7:0]} ^ dcache_wr_parity[15:0]) :
//    dcache_wr_parity[15:0] ;

wire  [15:0]  diagnstc_wr_parity;

assign diagnstc_wr_parity[15:0]  =  {lsu_diagnstc_dc_prty_invrt_e[7:0],lsu_diagnstc_dc_prty_invrt_e[7:0]} ^ dcache_wr_parity[15:0];

mux2ds  #(16) dcache_wr_parity_mod_mux (
              .in0(diagnstc_wr_parity[15:0]),
//              .in1({dcache_wr_parity[15:9],parity_byte8_flip,dcache_wr_parity[7:1],parity_byte0_flip}),
              .in1(parity_byte_flip[15:0]),        //bug7021/ECO7022                  
              .sel0(~lsu_dfq_ldst_vld),
              .sel1( lsu_dfq_ldst_vld),
              //.sel0(lsu_diagnstc_wr_src_sel_e),
              //.sel1(~lsu_diagnstc_wr_src_sel_e),
              .dout(dcache_wr_parity_mod[15:0])
);


// Bist read and write address sent thru fill_addr
//assign  lsu_dcache_fill_addr_e[10:0] = 
//lsu_dc_iob_access_e ? {dcache_iob_addr_e[7:0],2'b00} :
//(lsu_bist_wvld_e | lsu_bist_rvld_e) ? {1'b0, lsu_bist_addr_e[7:0],2'b00} :  //??FIX
//  lsu_diagnstc_wr_src_sel_e ? lsu_diagnstc_wr_addr_e[10:0] :
//    lsu_dcfill_data[`DCFILL_AD_LO+10:`DCFILL_AD_LO];

//   wire [10:0] lsu_dcache_fill_addr_e;
   
//mux4ds  #(11) lsu_dcache_fill_addr_e_mux (
//  .in0  ({dcache_iob_addr_e[8:0],2'b00}),
//  .in1  ({mbist_dcache_index[6:0], mbist_dcache_word, 3'b00}),
//  .in2  (lsu_diagnstc_wr_addr_e[10:0]),
//  .in3  (lsu_dcfill_data[`DCFILL_AD_LO+10:`DCFILL_AD_LO]),
//  .sel0 (lsu_dcfill_mx_sel_e[0]),
//  .sel1 (lsu_dcfill_mx_sel_e[1]),
//  .sel2 (lsu_dcfill_mx_sel_e[2]),
//  .sel3 (lsu_dcfill_mx_sel_e[3]),
//  .dout (lsu_dcache_fill_addr_e[10:0])
//);

wire	[63:0] misc_fill_data_e ;
// Use smaller width mux to save area.
//assign	misc_fill_data_e[63:0] =
//lsu_dc_iob_access_e ? dcache_iob_data_e[63:0] :
//	 		{32{lsu_bist_wdata_e[1:0]}} ;

   wire [7:0] mbist_write_data_d1;

dff #(8) mbist_write_data_ff (
   .din (mbist_write_data[7:0]),
   .q   (mbist_write_data_d1[7:0]),
   .clk    (clk),
   .se     (1'b0),     .si (),          .so ()
); 
    

   wire      [3:0] misc_fill_parity_e;
assign    misc_fill_parity_e[3:0] = {4{~lsu_dc_iob_access_e}} & mbist_write_data_d1[3:0];

mux2ds  #(64) misc_fill_data_e_mux (
              .in0(dcache_iob_data_e[63:0]),
              .in1({8{mbist_write_data_d1[7:0]}}),
              .sel0(lsu_dc_iob_access_e),
              .sel1(~lsu_dc_iob_access_e),
              .dout(misc_fill_data_e[63:0])
);

mux2ds  #(144) lsu_dcache_fill_data_e_mux (
               .in0({misc_fill_data_e[63:0],misc_fill_data_e[63:0],{4{misc_fill_parity_e[3:0]}}}),
               .in1({lsu_dcfill_data[127:0],dcache_wr_parity_mod[15:0]}),
               .sel0(lsu_dcfill_data_mx_sel_e),
               .sel1(~lsu_dcfill_data_mx_sel_e),
               .dout(lsu_dcache_fill_data_e[143:0])
);

//assign  lsu_dcache_fill_size_e[1:0] = 
//(lsu_dc_iob_access_e | lsu_bist_wvld_e | lsu_diagnstc_wr_src_sel_e) ? 2'b11 :
//    lsu_dcfill_data[`DCFILL_SZ_HI:`DCFILL_SZ_LO] ;



//   wire [1:0] bist_way_e;
   
//assign bist_way_e[1:0] = (lsu_bist_rvld_e | lsu_bist_wvld_e) ? 
//                          mbist_dcache_way[1:0] : 2'b00;
   
//assign  bist_rsel_way_e[0] = ~bist_way_e[1] & ~bist_way_e[0] ;
//assign  bist_rsel_way_e[1] = ~bist_way_e[1] &  bist_way_e[0] ;
//assign  bist_rsel_way_e[2] =  bist_way_e[1] & ~bist_way_e[0] ;
//assign  bist_rsel_way_e[3] =  bist_way_e[1] &  bist_way_e[0] ;

//   assign lsu_bist_rsel_way_e[3:0] = bist_rsel_way_e[3:0];
   
 
// This staging may have to go elsewhere 
//always @(posedge clk)
//  begin
//    bist_rsel_way_m[3:0] <= bist_rsel_way_e[3:0] ;  
//  end

//always @(posedge clk)
//  begin
//    lsu_bist_rsel_way_wb[3:0] <= bist_rsel_way_m[3:0] ; 
//  end

//dff #(4) bist_rsel_way_m_ff (
//        .din    (bist_rsel_way_e[3:0]),
//        .q      (bist_rsel_way_m[3:0]),
//        .clk    (clk),
//        .se     (1'b0),       .si (),          .so ()
//        );

//dff #(4) lsu_bist_rsel_way_wb_ff (
//        .din    (bist_rsel_way_m[3:0]),
//        .q      (lsu_bist_rsel_way_wb[3:0]),
//        .clk    (clk),
//        .se     (1'b0),       .si (),          .so ()
//        );

//assign  lsu_dcache_fill_way_e[0] = 
//lsu_dc_iob_access_e ? dcache_iob_wy_e[0] : 
//	(lsu_bist_wvld_e | lsu_bist_rvld_e) ? bist_rsel_way_e[0] :
//  		lsu_diagnstc_wr_src_sel_e ? lsu_diagnstc_wr_way_e[0] : 
//    			~lsu_dcfill_data[`DCFILL_WY_HI] & ~lsu_dcfill_data[`DCFILL_WY_LO] ;
//assign  lsu_dcache_fill_way_e[1] = 
//lsu_dc_iob_access_e ? dcache_iob_wy_e[1] : 
//	(lsu_bist_wvld_e | lsu_bist_rvld_e) ? bist_rsel_way_e[1] :
//  		lsu_diagnstc_wr_src_sel_e ? lsu_diagnstc_wr_way_e[1] : 
//    			~lsu_dcfill_data[`DCFILL_WY_HI] &  lsu_dcfill_data[`DCFILL_WY_LO] ;
//assign  lsu_dcache_fill_way_e[2] =  
//lsu_dc_iob_access_e ? dcache_iob_wy_e[2] : 
//	(lsu_bist_wvld_e | lsu_bist_rvld_e) ?  bist_rsel_way_e[2] :
//  		lsu_diagnstc_wr_src_sel_e ? lsu_diagnstc_wr_way_e[2] : 
//    			lsu_dcfill_data[`DCFILL_WY_HI] & ~lsu_dcfill_data[`DCFILL_WY_LO] ;
//assign  lsu_dcache_fill_way_e[3] =  
//lsu_dc_iob_access_e ? dcache_iob_wy_e[3] : 
//	(lsu_bist_wvld_e | lsu_bist_rvld_e) ?  bist_rsel_way_e[3] :
//  		lsu_diagnstc_wr_src_sel_e ? lsu_diagnstc_wr_way_e[3] : 
//    			lsu_dcfill_data[`DCFILL_WY_HI] &  lsu_dcfill_data[`DCFILL_WY_LO] ;

/*   
mux4ds  #(1) lsu_dcache_fill_way0_e_mux (
  .in0  (dcache_iob_wy_e[0]),
  .in1  (bist_rsel_way_e[0]),        
  .in2  (lsu_diagnstc_wr_way_e[0]),    
  .in3  (~lsu_dcfill_data[131] & ~lsu_dcfill_data[130]),
  .sel0 (lsu_dcfill_mx_sel_e[0]),
  .sel1 (lsu_dcfill_mx_sel_e[1]),
  .sel2 (lsu_dcfill_mx_sel_e[2]),
  .sel3 (lsu_dcfill_mx_sel_e[3]),
  .dout (lsu_dcache_fill_way_e[0]));                                 

mux4ds  #(1) lsu_dcache_fill_way1_e_mux (
  .in0  (dcache_iob_wy_e[1]),
  .in1  (bist_rsel_way_e[1]),        
  .in2  (lsu_diagnstc_wr_way_e[1]),    
  .in3  (~lsu_dcfill_data[131] &  lsu_dcfill_data[130]),
  .sel0 (lsu_dcfill_mx_sel_e[0]),
  .sel1 (lsu_dcfill_mx_sel_e[1]),
  .sel2 (lsu_dcfill_mx_sel_e[2]),
  .sel3 (lsu_dcfill_mx_sel_e[3]),
  .dout (lsu_dcache_fill_way_e[1]));                                 

mux4ds  #(1) lsu_dcache_fill_way2_e_mux (
  .in0  (dcache_iob_wy_e[2]),
  .in1  (bist_rsel_way_e[2]),        
  .in2  (lsu_diagnstc_wr_way_e[2]),    
  .in3  ( lsu_dcfill_data[131] & ~lsu_dcfill_data[130]),
  .sel0 (lsu_dcfill_mx_sel_e[0]),
  .sel1 (lsu_dcfill_mx_sel_e[1]),
  .sel2 (lsu_dcfill_mx_sel_e[2]),
  .sel3 (lsu_dcfill_mx_sel_e[3]),
  .dout (lsu_dcache_fill_way_e[2]));                                 


mux4ds  #(1) lsu_dcache_fill_way3_e_mux (
  .in0  (dcache_iob_wy_e[3]),
  .in1  (bist_rsel_way_e[3]),        
  .in2  (lsu_diagnstc_wr_way_e[3]),    
  .in3  ( lsu_dcfill_data[131] &  lsu_dcfill_data[130]),
  .sel0 (lsu_dcfill_mx_sel_e[0]),
  .sel1 (lsu_dcfill_mx_sel_e[1]),
  .sel2 (lsu_dcfill_mx_sel_e[2]),
  .sel3 (lsu_dcfill_mx_sel_e[3]),
  .dout (lsu_dcache_fill_way_e[3]));                
*/
//   assign lsu_dcache_fill_way_enc_e[0] =  lsu_dcache_fill_way_e[1] |  lsu_dcache_fill_way_e[3];
//   assign lsu_dcache_fill_way_enc_e[1] =  lsu_dcache_fill_way_e[2] |  lsu_dcache_fill_way_e[3];

wire [63:0] l2fill_data_e;
 
mux2ds        #(64) half_sel (
      .in0    (lsu_dcfill_data[127:0+64]),
      .in1    (lsu_dcfill_data[0+63:0]),
      .sel0   (lsu_dfill_data_sel_hi),  .sel1 (~lsu_dfill_data_sel_hi),
      .dout   (l2fill_data_e[63:0])
);

dff #(64) stgm_l2fd (
        .din    (l2fill_data_e[63:0]),
        .q      (lsu_l2fill_data[63:0]),
        .clk    (clk),
        .se     (se),       .si (),          .so ()
        );

endmodule
