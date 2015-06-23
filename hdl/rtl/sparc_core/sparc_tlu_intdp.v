// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_tlu_intdp.v
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
//  Module Name: sparc_tlu_intdp
//  Description:        
//    Contains the code for receiving interrupts from the crossbar,
//    and sending interrupts out to other processors through the corssbar.
//    The interrupt receive register (INRR, asi=0x49/VA=0),  incoming
//    vector register (INVR, asi=0x7f/VA=0x40), and interrupt vector
//    dispatch register (INDR, asi=0x77/VA=0) are implemented in this
//    block.  This block also initiates thread reset/wake up when a
//    reset packet is received.  
//
*/

////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
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
/*
/* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: tlu.h
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
// ifu trap types
















//
// modified for hypervisor support
//
























//


// modified due to bug 2588
// `define	TSA_PSTATE_VRANGE2_LO 16 


//











//
// added due to Niagara SRAMs methodology
// The following defines have been replaced due
// the memory macro replacement from:
// bw_r_rf32x144 -> 2x bw_r_rf32x80
/*
`define	TSA_MEM_WIDTH     144 
`define	TSA_HTSTATE_HI    142 //  3 bits 
`define	TSA_HTSTATE_LO    140 
`define	TSA_TPC_HI        138 // 47 bits 
`define	TSA_TPC_LO         92
`define	TSA_TNPC_HI        90 // 47 bits
`define	TSA_TNPC_LO        44 
`define	TSA_TSTATE_HI      40 // 29 bits 
`define	TSA_TSTATE_LO      12 
`define	TSA_TTYPE_HI        8 //  9 bits
`define	TSA_TTYPE_LO        0
`define	TSA_MEM_CWP_LO	   12
`define	TSA_MEM_CWP_HI	   14
`define	TSA_MEM_PSTATE_LO  15
`define	TSA_MEM_PSTATE_HI  22
`define	TSA_MEM_ASI_LO	   23
`define	TSA_MEM_ASI_HI	   30
`define	TSA_MEM_CCR_LO	   31
`define	TSA_MEM_CCR_HI	   38
`define	TSA_MEM_GL_LO	   39 
`define	TSA_MEM_GL_HI	   40 
*/











//











// HPSTATE position definitions within wsr






// TSTATE postition definitions within wsr







// modified due to bug 2588


// added for bug 2584 




//







//
// tick_cmp and stick_cmp definitions





//
// PIB WRAP



// HPSTATE postition definitions






// HTBA definitions




// TBA definitions




















//
// added for the hypervisor support


// modified due to bug 2588
















//
// compressed PSTATE WSR definitions














//
// ASI_QUEUE for hypervisor
// Queues are: CPU_MONODO
//             DEV_MONODO
//             RESUMABLE_ERROR
//             NON_RESUMABLE_ERROR
//







// for address range checking
















//
// Niagara scratch-pads
// VA address of 0x20 and 0x28 are exclusive to hypervisor
// 







//
// range checking 







// PIB related definitions
// Bit definition for events









// 
// PIB related definitions
// PCR and PIC address definitions



// 
// PCR bit definitions







//









// PIC definitions








// PIC  mask bit position definitions










// added define from sparc_tlu_int.v 










//
// shadow scan related definitions 

// modified due to logic redistribution
// `define TCL_SSCAN_WIDTH 12 





// `define TCL_SSCAN_LO 51 




// 
// position definitions - TDP






// 
// position definitions - TCL




// 
// To speedup POR for verification purposes

//
// modved defines to tlu.h
/*
`define INT_VEC_HI 5
`define INT_VEC_LO 0
`define INT_THR_HI  12
`define INT_THR_LO   8
`define INT_TYPE_HI 17
`define INT_TYPE_LO 16
*/

module sparc_tlu_intdp (/*AUTOARG*/
   // Outputs
   int_pending_i2_l, ind_inc_thrid_i1, // indr_inc_rst_pkt, 
   ind_inc_type_i1, tlu_lsu_int_ldxa_data_w2, int_tlu_rstid_m, 
   tlu_lsu_pcxpkt, so, 
   // Inputs
   //
   // modified to abide to the Niagara reset methodology 
   // clk, se, si, reset, lsu_tlu_intpkt, lsu_tlu_st_rs3_data_g, 
   rclk, se, si, tlu_rst_l, lsu_tlu_st_rs3_data_g, // lsu_tlu_intpkt, 
   inc_ind_ld_int_i1, inc_ind_rstthr_i1, inc_ind_asi_thr, 
   inc_ind_asi_wr_indr, inc_ind_indr_grant, // inc_ind_asi_inrr, 
   inc_ind_thr_m, inc_ind_asi_wr_inrr, inc_ind_asi_rd_invr, 
   inc_indr_req_valid, inc_indr_req_thrid, tlu_asi_rdata_mxsel_g,
   tlu_asi_queue_rdata_g, tlu_scpd_asi_rdata_g, lsu_ind_intpkt_id,
   lsu_ind_intpkt_type, lsu_ind_intpkt_thr 
   );

   //
   // modified to abide to the Niagara reset methodology 
   // input      clk, se, si, reset;
   input      rclk, se, si, tlu_rst_l;

   // from lsu
   // input [17:0]  lsu_tlu_intpkt;   // int pkt from cpx
   input [63:0]  lsu_tlu_st_rs3_data_g;     // write data for int regs

   // select lines from int_ctl
   input [3:0] 	 inc_ind_ld_int_i1;            // ld ext interrupt to inrr
   input [3:0] 	 inc_ind_rstthr_i1;
   
   // changing the select from inverting to non-inverting for grape
   // input [3:0] 	 inc_ind_asi_thr_l;            // thread issuing asi command
   input [3:0] 	 inc_ind_asi_thr;            // thread issuing asi command
   input [3:0] 	 inc_ind_asi_wr_indr;          // write INDR
   // convert the signal to non-inverting version for grape
   // input [3:0] 	 inc_ind_indr_grant_l;         // transmit INDR to PCX
   input [3:0] 	 inc_ind_indr_grant;         // transmit INDR to PCX
   // obsolete input
   // input 	 inc_ind_asi_inrr;             // read INRR
   // convert the signal to non-inverting version for grape
   // input [3:0]	 inc_ind_thr_m_l;
   input [3:0]	 inc_ind_thr_m;
   
   // other controls
   input [3:0] 	 inc_ind_asi_wr_inrr;  // write INRR
   input [3:0] 	 inc_ind_asi_rd_invr;  // read INVR (reset corr bit in INRR)
   
   // indr request
   input 	 inc_indr_req_valid;   // valid value in INDR, i.e make req
   input [1:0] 	 inc_indr_req_thrid;   // thread making request
   //
   // asi rdata mux select
   input [3:0] tlu_asi_rdata_mxsel_g;
   // asi data from other blocks
   input [64-1:0] tlu_scpd_asi_rdata_g;
   input [8-1:0]   tlu_asi_queue_rdata_g;
   input [4:0]  lsu_ind_intpkt_thr;
   input [1:0]  lsu_ind_intpkt_type;
   input [5:0]  lsu_ind_intpkt_id;

   // to int ctl
   output [3:0]  int_pending_i2_l;     // interrupt still pending
   // output 	 indr_inc_rst_pkt;

   output [4:0]  ind_inc_thrid_i1;
   output [1:0]  ind_inc_type_i1;
   
   // to outside world
   output [63:0] tlu_lsu_int_ldxa_data_w2; // read data from asi regs 
   output [5:0]  int_tlu_rstid_m;
   
   output [25:0] tlu_lsu_pcxpkt;       // pcxpkt for inter processor int
   
   output 	 so;

   // local signals
   //
   // added to abide to the Niagara reset methodology 
   wire local_rst; // local reset signal 
   //
   wire [63:0] int_tlu_asi_data;     // read data from int regs
   // interrupt and reset id
   wire [5:0] 	 int_id_i1;
   wire [5:0] 	 t0_rstid_i2,
		 t1_rstid_i2,
		 t2_rstid_i2,
		 t3_rstid_i2,
		 next_t0_rstid_i1,
		 next_t1_rstid_i1,
		 next_t2_rstid_i1,
		 next_t3_rstid_i1;

   // Interrupt receive register
   wire [63:0]	 inrr_dec_i1,
		 inrr_rd_data_i2;

   wire [63:0] 	 t0_inrr_i2,
 		 t1_inrr_i2,
		 t2_inrr_i2,
		 t3_inrr_i2,
		 t0_inrr_aw_i2,
		 t1_inrr_aw_i2,
		 t2_inrr_aw_i2,
		 t3_inrr_aw_i2,
		 t0_inrr_arw_i1,
		 t1_inrr_arw_i1,
		 t2_inrr_arw_i1,
		 t3_inrr_arw_i1,
		 next_t0_inrr_i1,
		 next_t1_inrr_i1,
		 next_t2_inrr_i1,
		 next_t3_inrr_i1;
   
   wire [63:0] 	 new_t0_inrr_i1,
		 new_t1_inrr_i1,
		 new_t2_inrr_i1,
		 new_t3_inrr_i1;

   // clear interrupt through asi
   wire [63:0]   t0_asi_wr_data,
		 t1_asi_wr_data,
		 t2_asi_wr_data,
		 t3_asi_wr_data;

   // interrupt vector
   wire [5:0] 	 t0_invr_i3,
 		 t1_invr_i3,
 		 t2_invr_i3,
 		 t3_invr_i3,
    		 t0_invr_i2,
 		 t1_invr_i2,
 		 t2_invr_i2,
 		 t3_invr_i2;
   wire [5:0] 	 invr_rd_data_i3;

   // highest priority interrupt
   wire [63:0] 	 pe_ivec_i3,
		 t0_pe_ivec_i3,
		 t1_pe_ivec_i3,
		 t2_pe_ivec_i3,
		 t3_pe_ivec_i3;

   // interrupt dispatch
   // removed the obsolete bits 
   // wire [12:0] 	 indr_wr_pkt;
   wire [10:0] 	 indr_wr_pkt;

   // removed the obsolete bits 
   // wire [12:0] 	 indr_pcxpkt,
   wire [10:0] 	 indr_pcxpkt,
		 t0_indr,
		 t1_indr,
		 t2_indr,
		 t3_indr,
		 t0_indr_next,
		 t1_indr_next,
		 t2_indr_next,
		 t3_indr_next;
   // 
   // local clock
   wire clk;

   //
   // Code Starts Here
   //
   //----------------------------------------------------------------------
   // creating local clock
   //----------------------------------------------------------------------
   assign clk = rclk;

   //----------------------------------------------------------------------
   // Interrupt Receive
   //----------------------------------------------------------------------
   //
   // create local reset signal
   assign local_rst = ~tlu_rst_l;
   
   // I1 Stage
   // decode interrupt vector
   // modified due to interface clean-up
   /*
   assign  int_id_i1 = lsu_tlu_intpkt[`INT_VEC_HI:`INT_VEC_LO];
   assign  ind_inc_type_i1 = lsu_tlu_intpkt[`INT_TYPE_HI:`INT_TYPE_LO];
   assign  ind_inc_thrid_i1 = lsu_tlu_intpkt[`INT_THR_HI:`INT_THR_LO];
   */
   assign  int_id_i1[5:0]        = lsu_ind_intpkt_id[5:0];
   assign  ind_inc_type_i1[1:0]  = lsu_ind_intpkt_type[1:0];
   assign  ind_inc_thrid_i1[4:0] = lsu_ind_intpkt_thr[4:0];

   // rstid enable mux
   dp_mux2es #6 rid_mux0(.dout  (next_t0_rstid_i1[5:0]),
			 .in0   (t0_rstid_i2[5:0]),
			 .in1   (int_id_i1[5:0]),
			 .sel   (inc_ind_rstthr_i1[0]));









 
   dp_mux2es #6 rid_mux1(.dout  (next_t1_rstid_i1[5:0]),
			 .in0   (t1_rstid_i2[5:0]),
			 .in1   (int_id_i1[5:0]),
			 .sel   (inc_ind_rstthr_i1[1]));
   
   dp_mux2es #6 rid_mux2(.dout  (next_t2_rstid_i1[5:0]),
			 .in0   (t2_rstid_i2[5:0]),
			 .in1   (int_id_i1[5:0]),
			 .sel   (inc_ind_rstthr_i1[2]));
   
   dp_mux2es #6 rid_mux3(.dout  (next_t3_rstid_i1[5:0]),
			 .in0   (t3_rstid_i2[5:0]),
			 .in1   (int_id_i1[5:0]),
			 .sel   (inc_ind_rstthr_i1[3]));

   // rst id flops
   dff #6 rid0_reg(.din (next_t0_rstid_i1[5:0]),
		   .q   (t0_rstid_i2[5:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());
   dff #6 rid1_reg(.din (next_t1_rstid_i1[5:0]),
		   .q   (t1_rstid_i2[5:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());
   dff #6 rid2_reg(.din (next_t2_rstid_i1[5:0]),
		   .q   (t2_rstid_i2[5:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());
   dff #6 rid3_reg(.din (next_t3_rstid_i1[5:0]),
		   .q   (t3_rstid_i2[5:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());
   
   // rstid to tlu in M stage
   // changing the select from inverting to non-inverting for grape
   /*
   dp_mux4ds #6 tlurid_mux(.dout (int_tlu_rstid_m[5:0]),
			   .in0  (t0_rstid_i2[5:0]),
			   .in1  (t1_rstid_i2[5:0]),
			   .in2  (t2_rstid_i2[5:0]),
			   .in3  (t3_rstid_i2[5:0]),
			   .sel0_l (inc_ind_thr_m_l[0]),
			   .sel1_l (inc_ind_thr_m_l[1]),
			   .sel2_l (inc_ind_thr_m_l[2]),
			   .sel3_l (inc_ind_thr_m_l[3]));
   */
   dp_mux4ds #6 tlurid_mux(.dout (int_tlu_rstid_m[5:0]),
			   .in0  (t0_rstid_i2[5:0]),
			   .in1  (t1_rstid_i2[5:0]),
			   .in2  (t2_rstid_i2[5:0]),
			   .in3  (t3_rstid_i2[5:0]),
			   .sel0_l (~inc_ind_thr_m[0]),
			   .sel1_l (~inc_ind_thr_m[1]),
			   .sel2_l (~inc_ind_thr_m[2]),
			   .sel3_l (~inc_ind_thr_m[3]));

 // !`ifdef FPGA_SYN_1THREAD

   sparc_tlu_dec64 iv_dec(.in  (int_id_i1[5:0]),
			  .out (inrr_dec_i1[63:0]));

   // merge decoded interrupt vector with inrr
   assign  new_t0_inrr_i1 = inrr_dec_i1 | t0_inrr_arw_i1;
   assign  new_t1_inrr_i1 = inrr_dec_i1 | t1_inrr_arw_i1;
   assign  new_t2_inrr_i1 = inrr_dec_i1 | t2_inrr_arw_i1;
   assign  new_t3_inrr_i1 = inrr_dec_i1 | t3_inrr_arw_i1;

   // enable mux to load new interrupt to INRR
   dp_mux2es #64 inrr_en_mux0(.dout  (next_t0_inrr_i1[63:0]),
			  .in0   (t0_inrr_arw_i1[63:0]),
			  .in1   (new_t0_inrr_i1[63:0]),
			  .sel   (inc_ind_ld_int_i1[0]));














   
   dp_mux2es #64 inrr_en_mux1(.dout  (next_t1_inrr_i1[63:0]),
			  .in0   (t1_inrr_arw_i1[63:0]),
			  .in1   (new_t1_inrr_i1[63:0]),
			  .sel   (inc_ind_ld_int_i1[1]));
   dp_mux2es #64 inrr_en_mux2(.dout  (next_t2_inrr_i1[63:0]),
			  .in0   (t2_inrr_arw_i1[63:0]),
			  .in1   (new_t2_inrr_i1[63:0]),
			  .sel   (inc_ind_ld_int_i1[2]));
   dp_mux2es #64 inrr_en_mux3(.dout  (next_t3_inrr_i1[63:0]),
			  .in0   (t3_inrr_arw_i1[63:0]),
			  .in1   (new_t3_inrr_i1[63:0]),
			  .sel   (inc_ind_ld_int_i1[3]));

   // interrupt receive register (INRR)
   // change to dff -- software will reset before IE turns on
   dffr #64 t0_inrr (.din (next_t0_inrr_i1[63:0]),
		     .q   (t0_inrr_i2[63:0]),
		     .clk (clk),
   //
   // modified to abide to the Niagara reset methodology 
   //		     .rst (reset),
   		     .rst (local_rst),
		     .se  (se), .si(), .so());
   dffr #64 t1_inrr (.din (next_t1_inrr_i1[63:0]),
		     .q   (t1_inrr_i2[63:0]),
		     .clk (clk),
   //
   // modified to abide to the Niagara reset methodology 
   //		     .rst (reset),
   		     .rst (local_rst),
		     .se  (se), .si(), .so());
   dffr #64 t2_inrr (.din (next_t2_inrr_i1[63:0]),
		     .q   (t2_inrr_i2[63:0]),
		     .clk (clk),
   //
   // modified to abide to the Niagara reset methodology 
   //		     .rst (reset),
   		     .rst (local_rst),
		     .se  (se), .si(), .so());
   dffr #64 t3_inrr (.din (next_t3_inrr_i1[63:0]),
		     .q   (t3_inrr_i2[63:0]),
		     .clk (clk),
   //
   // modified to abide to the Niagara reset methodology 
   //		     .rst (reset),
   		     .rst (local_rst),
		     .se  (se), .si(), .so());

   // I2 Stage
   // read out INRR to asi
   // changing the select from inverting to non-inverting for grape
   /*
   dp_mux4ds #64 inrr_rd_mux(.dout (inrr_rd_data_i2[63:0]),
			 .in0  (t0_inrr_i2[63:0]),
			 .in1  (t1_inrr_i2[63:0]),
			 .in2  (t2_inrr_i2[63:0]),
			 .in3  (t3_inrr_i2[63:0]),
			 .sel0_l (inc_ind_asi_thr_l[0]),
			 .sel1_l (inc_ind_asi_thr_l[1]),
			 .sel2_l (inc_ind_asi_thr_l[2]),
			 .sel3_l (inc_ind_asi_thr_l[3]));
    */
   dp_mux4ds #64 inrr_rd_mux(.dout (inrr_rd_data_i2[63:0]),
			 .in0  (t0_inrr_i2[63:0]),
			 .in1  (t1_inrr_i2[63:0]),
			 .in2  (t2_inrr_i2[63:0]),
			 .in3  (t3_inrr_i2[63:0]),
			 .sel0_l (~inc_ind_asi_thr[0]),
			 .sel1_l (~inc_ind_asi_thr[1]),
			 .sel2_l (~inc_ind_asi_thr[2]),
			 .sel3_l (~inc_ind_asi_thr[3]));

 // !`ifdef FPGA_SYN_1THREAD
		     
   // signal interrupt pending
   sparc_tlu_zcmp64  zcmp0(.in  (t0_inrr_i2[63:0]),
			   .zero (int_pending_i2_l[0]));














   
   sparc_tlu_zcmp64  zcmp1(.in  (t1_inrr_i2[63:0]),
			   .zero (int_pending_i2_l[1]));
   sparc_tlu_zcmp64  zcmp2(.in  (t2_inrr_i2[63:0]),
			   .zero (int_pending_i2_l[2]));
   sparc_tlu_zcmp64  zcmp3(.in  (t3_inrr_i2[63:0]),
			   .zero (int_pending_i2_l[3]));

   // write data -- only zeros may be written to the INRR.  An attempt
   // to write 1 is ignored.
   // Force to all 1 if no write
   assign  t0_asi_wr_data = ~(~lsu_tlu_st_rs3_data_g & 
			      {64{inc_ind_asi_wr_inrr[0]}});
   assign  t1_asi_wr_data = ~(~lsu_tlu_st_rs3_data_g & 
			      {64{inc_ind_asi_wr_inrr[1]}});
   assign  t2_asi_wr_data = ~(~lsu_tlu_st_rs3_data_g & 
			      {64{inc_ind_asi_wr_inrr[2]}});
   assign  t3_asi_wr_data = ~(~lsu_tlu_st_rs3_data_g & 
			      {64{inc_ind_asi_wr_inrr[3]}});
   
   assign  t0_inrr_aw_i2 = t0_inrr_i2 & t0_asi_wr_data;
   assign  t1_inrr_aw_i2 = t1_inrr_i2 & t1_asi_wr_data;
   assign  t2_inrr_aw_i2 = t2_inrr_i2 & t2_asi_wr_data;
   assign  t3_inrr_aw_i2 = t3_inrr_i2 & t3_asi_wr_data;

   // priority encode INRR to 6 bits to get INVR
   // b63 has the highest priority
   sparc_tlu_penc64 t0_invr_penc(.in  (t0_inrr_i2[63:0]),
				 .out (t0_invr_i2[5:0]));
   sparc_tlu_penc64 t1_invr_penc(.in  (t1_inrr_i2[63:0]),
				 .out (t1_invr_i2[5:0]));
   sparc_tlu_penc64 t2_invr_penc(.in  (t2_inrr_i2[63:0]),
				 .out (t2_invr_i2[5:0]));
   sparc_tlu_penc64 t3_invr_penc(.in  (t3_inrr_i2[63:0]),
				 .out (t3_invr_i2[5:0]));

   // Interrupt Vector Register (INVR)
   // Cannot write to INVR
   dff #6 t0_invr (.din (t0_invr_i2[5:0]),
		   .q   (t0_invr_i3[5:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());
   dff #6 t1_invr (.din (t1_invr_i2[5:0]),
		   .q   (t1_invr_i3[5:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());
   dff #6 t2_invr (.din (t2_invr_i2[5:0]),
		   .q   (t2_invr_i3[5:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());
   dff #6 t3_invr (.din (t3_invr_i2[5:0]),
		   .q   (t3_invr_i3[5:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());

   // I3 stage
   // read out to asi data 
   // changing the select from inverting to non-inverting for grape
   /*
   dp_mux4ds #6 invr_rd_mux(.dout (invr_rd_data_i3[5:0]),
			    .in0  (t0_invr_i3[5:0]),
			    .in1  (t1_invr_i3[5:0]),
			    .in2  (t2_invr_i3[5:0]),
			    .in3  (t3_invr_i3[5:0]),
			    .sel0_l (inc_ind_asi_thr_l[0]),
			    .sel1_l (inc_ind_asi_thr_l[1]),
			    .sel2_l (inc_ind_asi_thr_l[2]),
			    .sel3_l (inc_ind_asi_thr_l[3]));
   */
   dp_mux4ds #6 invr_rd_mux(.dout (invr_rd_data_i3[5:0]),
			    .in0  (t0_invr_i3[5:0]),
			    .in1  (t1_invr_i3[5:0]),
			    .in2  (t2_invr_i3[5:0]),
			    .in3  (t3_invr_i3[5:0]),
			    .sel0_l (~inc_ind_asi_thr[0]),
			    .sel1_l (~inc_ind_asi_thr[1]),
			    .sel2_l (~inc_ind_asi_thr[2]),
			    .sel3_l (~inc_ind_asi_thr[3]));
 // !`ifdef FPGA_SYN_1THREAD
   
   //
   // modified for bug 2109
   // asi rd data mux
   dp_mux4ds #(64) asi_rd_mux(
			   .in0  ({58'b0, invr_rd_data_i3[5:0]}),
			   .in1  (inrr_rd_data_i2[63:0]),
			   .in2  (tlu_scpd_asi_rdata_g[64-1:0]),
			   .in3  ({50'b0, tlu_asi_queue_rdata_g[8-1:0],6'b0}),
			   .sel0_l (~tlu_asi_rdata_mxsel_g[0]),
			   .sel1_l (~tlu_asi_rdata_mxsel_g[1]),
			   .sel2_l (~tlu_asi_rdata_mxsel_g[2]),
			   .sel3_l (~tlu_asi_rdata_mxsel_g[3]),
               .dout (int_tlu_asi_data[63:0]));

   dff #(64) dff_tlu_lsu_int_ldxa_data_w2 (
        .din (int_tlu_asi_data[63:0]),
		.q   (tlu_lsu_int_ldxa_data_w2[63:0]),
		.clk (clk),
		.se  (se), 
        .si(), 
        .so());
   
   sparc_tlu_dec64 inrr_pe_dec(.in  (invr_rd_data_i3[5:0]),
			       .out (pe_ivec_i3[63:0]));

   // when INVR is read, zero out the corresponding bit in INRR
   assign  t0_pe_ivec_i3 = pe_ivec_i3 & {64{inc_ind_asi_rd_invr[0]}};
   assign  t1_pe_ivec_i3 = pe_ivec_i3 & {64{inc_ind_asi_rd_invr[1]}};
   assign  t2_pe_ivec_i3 = pe_ivec_i3 & {64{inc_ind_asi_rd_invr[2]}};
   assign  t3_pe_ivec_i3 = pe_ivec_i3 & {64{inc_ind_asi_rd_invr[3]}};

   assign  t0_inrr_arw_i1 = t0_inrr_aw_i2 & ~t0_pe_ivec_i3;
   assign  t1_inrr_arw_i1 = t1_inrr_aw_i2 & ~t1_pe_ivec_i3;
   assign  t2_inrr_arw_i1 = t2_inrr_aw_i2 & ~t2_pe_ivec_i3;
   assign  t3_inrr_arw_i1 = t3_inrr_aw_i2 & ~t3_pe_ivec_i3;

   //----------------------------------------------------------------------
   // Interrupt Dispatch
   //----------------------------------------------------------------------
   // modified to remove the unused bits
   //
   // assign  indr_wr_pkt = {lsu_tlu_st_rs3_data_g[`INT_TYPE_HI:`INT_TYPE_LO], 
   assign  indr_wr_pkt = {lsu_tlu_st_rs3_data_g[12:8], 
			  lsu_tlu_st_rs3_data_g[5:0]};
   // 
   // removed for timing 
   // assign  indr_inc_rst_pkt = lsu_tlu_st_rs3_data_g[`INT_TYPE_HI] |
   // 	                      lsu_tlu_st_rs3_data_g[`INT_TYPE_LO];
   
   dp_mux2es  #11   t0_indr_mux(.dout (t0_indr_next[10:0]),
				.in0  (t0_indr[10:0]),
				.in1  (indr_wr_pkt[10:0]),
				.sel  (inc_ind_asi_wr_indr[0]));








   
   dp_mux2es  #11   t1_indr_mux(.dout (t1_indr_next[10:0]),
				.in0  (t1_indr[10:0]),
				.in1  (indr_wr_pkt[10:0]),
				.sel  (inc_ind_asi_wr_indr[1]));
   dp_mux2es  #11   t2_indr_mux(.dout (t2_indr_next[10:0]),
				.in0  (t2_indr[10:0]),
				.in1  (indr_wr_pkt[10:0]),
				.sel  (inc_ind_asi_wr_indr[2]));
   dp_mux2es  #11   t3_indr_mux(.dout (t3_indr_next[10:0]),
				.in0  (t3_indr[10:0]),
				.in1  (indr_wr_pkt[10:0]),
				.sel  (inc_ind_asi_wr_indr[3]));
   
   dff #11 t0_indr_reg(.din (t0_indr_next[10:0]),
		   .q   (t0_indr[10:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());
   dff #11 t1_indr_reg(.din (t1_indr_next[10:0]),
		   .q   (t1_indr[10:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());
   dff #11 t2_indr_reg(.din (t2_indr_next[10:0]),
		   .q   (t2_indr[10:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());
   dff #11 t3_indr_reg(.din (t3_indr_next[10:0]),
		   .q   (t3_indr[10:0]),
		   .clk (clk),
		   .se  (se), .si(), .so());

   // changing the select from inverting to non-inverting for grape
   /*
   dp_mux4ds #13 int_dsp_mux(.dout (indr_pcxpkt[12:0]),
			     .in0  (t0_indr[12:0]),
			     .in1  (t1_indr[12:0]),
			     .in2  (t2_indr[12:0]),
			     .in3  (t3_indr[12:0]),
			     .sel0_l (inc_ind_indr_grant_l[0]),
			     .sel1_l (inc_ind_indr_grant_l[1]),
			     .sel2_l (inc_ind_indr_grant_l[2]),
			     .sel3_l (inc_ind_indr_grant_l[3]));
    */
   dp_mux4ds #11 int_dsp_mux(.dout (indr_pcxpkt[10:0]),
			     .in0  (t0_indr[10:0]),
			     .in1  (t1_indr[10:0]),
			     .in2  (t2_indr[10:0]),
			     .in3  (t3_indr[10:0]),
			     .sel0_l (~inc_ind_indr_grant[0]),
			     .sel1_l (~inc_ind_indr_grant[1]),
			     .sel2_l (~inc_ind_indr_grant[2]),
			     .sel3_l (~inc_ind_indr_grant[3]));
 // !`ifdef FPGA_SYN_1THREAD
   
   
   assign  tlu_lsu_pcxpkt[25:0] = {inc_indr_req_valid,  // 25
				   {5'b01001},               // 24:20
				   inc_indr_req_thrid[1:0], // 19:18
//				   indr_pcxpkt[12:11],  -- cannot send rst
				   {2'b00},             // 17:16
				   3'b0,                // 15:13 rsvd
				   indr_pcxpkt[10:6],   // 12:8
				   2'b0,                // 7:6   rsvd
				   indr_pcxpkt[5:0]};   // 5:0
   
   // TBD:
   // 1. disable sending of reset/nuke/resum packets from indr -- DONE 1/6
   
endmodule
   
   
