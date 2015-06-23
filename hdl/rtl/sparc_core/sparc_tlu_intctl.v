// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_tlu_intctl.v
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
//  Module Name: sparc_tlu_intctl
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



// from intdp.v for now


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


module sparc_tlu_intctl(/*AUTOARG*/
   // Outputs
   so, int_rst_l, tlu_ifu_hwint_i3, tlu_ifu_rstthr_i2, tlu_ifu_rstint_i2, 
   tlu_ifu_nukeint_i2, tlu_ifu_resumint_i2, tlu_ifu_pstate_ie, 
   int_tlu_longop_done,  inc_ind_ld_int_i1, inc_indr_req_valid, 
   inc_ind_rstthr_i1, // inc_ind_asi_thr, inc_ind_asi_wr_inrr, 
   // inc_ind_asi_rd_invr, inc_ind_asi_inrr, inc_ind_asi_wr_indr, 
   inc_ind_indr_grant, inc_ind_thr_m, tlu_lsu_int_ld_ill_va_w2,
   inc_indr_req_thrid, tlu_asi_data_nf_vld_w2, tlu_asi_rdata_mxsel_g, 
   // Inputs
   // modified to abide to the Niagara reset methodology 
   // clk, se, si, reset, const_cpuid, lsu_tlu_cpx_vld, lsu_tlu_cpx_req, 
   rclk, se, sehold, si, rst_tri_en, arst_l, grst_l, const_cpuid,  
   lsu_tlu_cpx_vld, lsu_tlu_cpx_req, lsu_tlu_pcxpkt_ack, tlu_ld_data_vld_g, 
   ind_inc_thrid_i1, ind_inc_type_i1, tlu_int_asi_vld, tlu_int_asi_load, 
   tlu_int_asi_store, tlu_int_asi_thrid, tlu_int_asi_state, tlu_int_tid_m, 
   tlu_int_pstate_ie, int_pending_i2_l, // indr_inc_rst_pkt, tlu_int_redmode,  
   tlu_asi_queue_rd_vld_g, tlu_va_ill_g); // tlu_flush_all_w2

//
// modified to abide to the Niagara reset methodology 
//   input            clk, se, si, reset;
   input            rclk, se, si;
   input            arst_l, grst_l;  
   input            sehold; 
   input            rst_tri_en; 
   input [3:0] 	    const_cpuid;

   input 	    lsu_tlu_cpx_vld;    // cpx from lsu
   input [3:0] 	    lsu_tlu_cpx_req;    // cpx req type
   // the flush bit is included in lsu_tlu_cpx_vld
   // input 	    lsu_tlu_cpx_nc;
   input 	    lsu_tlu_pcxpkt_ack;
   
// removed unused pins
// input [`INT_THR_HI:0] lsu_tlu_st_rs3_data_g;
// input 	    lsu_tlu_pmode;
// input [3:0] 	tlu_int_sftint_pend;
   
   input [4:0] 	ind_inc_thrid_i1; // connect to lsu_tlu_intpkt[12:8]
   input [1:0]	ind_inc_type_i1;  // connect to lsu_tlu_intpkt[16]

   input 	    tlu_int_asi_vld;
   input 	    tlu_int_asi_load;  // read enable
   input 	    tlu_int_asi_store; // write enable
   input [1:0] 	tlu_int_asi_thrid; // thread making asi request
   input [7:0] 	tlu_int_asi_state; // asi to be read/written
   // input        tlu_scpd_rd_vld_g; // rdata vld from scratchpad
   // removed no longer necessary 
   // input        tlu_va_all_zero_g; // va address - all zero 
   input        tlu_va_ill_g;      // illega va range 
   input        tlu_asi_queue_rd_vld_g; // rdata vld from asi queues
   input        tlu_ld_data_vld_g; // rdata vld from asi queues
   // input        tlu_flush_all_w2;  // flush pipe from tcl 

   input [1:0] 	tlu_int_tid_m;
   
   input [3:0] 	tlu_int_pstate_ie;
   // input [3:0] 	tlu_int_redmode;
   
   // from int_dp
   input [3:0] 	    int_pending_i2_l;   // uncleared interrupt
   // input 	    indr_inc_rst_pkt;
   // added for timing
   // input [1:0]	lsu_tlu_rst_pkt;

   output 	    int_rst_l, so;

   // to ifu
   output [3:0]     tlu_ifu_hwint_i3;   // interrupt
   output [3:0]     tlu_ifu_rstthr_i2;  // reset, nuke or resume
   output 	    tlu_ifu_rstint_i2;  // reset msg
   output           tlu_ifu_nukeint_i2; // idle/suspend message
   output 	    tlu_ifu_resumint_i2;// resume message
   output [3:0]	    tlu_ifu_pstate_ie;
   
   output [3:0]     int_tlu_longop_done;
// 
// removed - IFU will derive the signal locally
//   output [3:0]     tlu_ifu_int_activate_i3;// wake up signal for thread
   
   // to int_dp
   output [3:0]     inc_ind_ld_int_i1;          // ld new interrupt
   output [3:0]     inc_ind_rstthr_i1;          // ld new rst vector
   
   // convert the signal back to non-inverting version for grape
   // output [3:0]     inc_ind_asi_thr_l;          // choose asi op thread
   // output [3:0]     inc_ind_asi_thr;          // choose asi op thread
   // output [3:0]     inc_ind_asi_wr_inrr;        // write to INRR (per thread)
   // output [3:0]     inc_ind_asi_wr_indr;        // write to INDR
   // output [3:0]     inc_ind_asi_rd_invr;        // read INVR and 
                                                // reset corr. bit in INRR
   // obsolete output
   // output 	    inc_ind_asi_inrr;           // choose which reg to read
   // convert the signal back to non-inverting version for grape
   // output [3:0]     inc_ind_indr_grant_l;       // move on to next pcx pkt
   output [3:0]     inc_ind_indr_grant;       // move on to next pcx pkt
   // convert the signal back to non-inverting version for grape
   // output [3:0]     inc_ind_thr_m_l;            // M stage thread
   output [3:0]     inc_ind_thr_m;            // M stage thread
   
   // pcx pkt fields
   output 	    inc_indr_req_valid;     // valid bit for PCX int pkt
   output [1:0] inc_indr_req_thrid;     // thread sending pcx int pkt

   // to tlu
   // output tlu_lsu_int_ldxa_vld_w2;  // valid asi data from int or scpd 
   output tlu_asi_data_nf_vld_w2;  // valid asi data from int or scpd 
   output tlu_lsu_int_ld_ill_va_w2; // illega va range - load  
   // to intdp
   output [3:0] tlu_asi_rdata_mxsel_g; // mux selects to the asi rdata

   // local signals
   // wire indr_inc_rst_pkt;
   wire inc_ind_asi_inrr;           // choose which reg to read
   wire	int_tlu_asi_data_vld_g, int_tlu_asi_data_vld_w2;
   wire	int_ld_ill_va_g, int_ld_ill_va_w2;
   wire hw_int_i1,
		rst_int_i1,
		nuke_int_i1,
		resum_int_i1;

   wire [3:0] 	    int_thr_i1,
		    rstthr_i1,
		    asi_thr;

   wire [3:0] 	    int_pending_i2;
// 		    int_activate_i2;
   
   wire 	    asi_write, 
		    asi_read,
		    asi_invr,
		    asi_indr;
   
   wire [3:0] 	    indr_vld,
		    indr_rst,
		    indr_vld_next,
		    indr_grant;

   // added for bug 3945
   wire [3:0] indr_req_vec;
   wire indr_req_valid_disable;

   // wire [3:0] 	    int_or_redrst;
   wire [3:0] 	    intd_done;

   // wire 	    red_thread, valid_dest;
   wire 	    local_rst;  // local reset 
   wire 	    local_rst_l;  // local reset 
   wire 	    clk;        // local clk 
   

   //
   // Code Starts Here
   //
   //=========================================================================================
   //	reset
   //=========================================================================================

   dffrl_async dffrl_local_rst_l(
       .din  (grst_l),
       .clk  (clk),
       .rst_l(arst_l),
       .q    (local_rst_l),
       .se   (se),
       .si   (),
       .so   ()
   ); 
   assign local_rst = ~local_rst_l;
   assign int_rst_l = local_rst_l;

   // create local clk
   assign clk = rclk; 

   //-------------------------------------
   // Basic Operation
   //-------------------------------------
   sink s1(const_cpuid[3]);

   assign  tlu_ifu_pstate_ie = tlu_int_pstate_ie;

   // process cpx interrupt type
   // int = 00
   // the flush bit from cpx packet is now included in the
   // lsu_tlu_cpx_vld qualification
   assign  hw_int_i1 = (lsu_tlu_cpx_vld &
			// (lsu_tlu_cpx_req == `INT_RET) & ~lsu_tlu_cpx_nc &
			(lsu_tlu_cpx_req == 4'b0111) & 
			(ind_inc_thrid_i1[4:2] == const_cpuid[2:0])) ?
			 ~ind_inc_type_i1[1] & ~ind_inc_type_i1[0] :
	                 1'b0;
   //reset = 01
   // the flush bit from cpx packet is now included in the
   // lsu_tlu_cpx_vld qualification
   assign  rst_int_i1 = (lsu_tlu_cpx_vld &
			 // (lsu_tlu_cpx_req == `INT_RET) && ~lsu_tlu_cpx_nc &
			 (lsu_tlu_cpx_req == 4'b0111) &
			 (ind_inc_thrid_i1[4:2] == const_cpuid[2:0])) ?
			  ~ind_inc_type_i1[1] & ind_inc_type_i1[0] :
	                  1'b0;
   // idle/nuke = 10
   // the flush bit from cpx packet is now included in the
   // lsu_tlu_cpx_vld qualification
   assign  nuke_int_i1 = (lsu_tlu_cpx_vld &
			   // (lsu_tlu_cpx_req == `INT_RET) & ~lsu_tlu_cpx_nc &
			   (lsu_tlu_cpx_req == 4'b0111) & 
			   (ind_inc_thrid_i1[4:2] == const_cpuid[2:0])) ?
			    ind_inc_type_i1[1] & ~ind_inc_type_i1[0] :
	                    1'b0;
   // resume = 11
   // the flush bit from cpx packet is now included in the
   // lsu_tlu_cpx_vld qualification
   assign  resum_int_i1 = (lsu_tlu_cpx_vld &
			   // (lsu_tlu_cpx_req == `INT_RET) & ~lsu_tlu_cpx_nc &
			   (lsu_tlu_cpx_req == 4'b0111) & 
			   (ind_inc_thrid_i1[4:2] == const_cpuid[2:0])) ?
			    ind_inc_type_i1[1] & ind_inc_type_i1[0] :
	                    1'b0;

   dffr #1  rstint_ff(.din  (rst_int_i1),
		      .q    (tlu_ifu_rstint_i2),
		      .clk  (clk),
//
// modified to abide to the Niagara reset methodology 
//		      .rst  (reset),
		      .rst  (local_rst),
		      .se   (se), .si(), .so());
   
   dffr #1  nukint_ff(.din  (nuke_int_i1),
		      .q    (tlu_ifu_nukeint_i2),
		      .clk  (clk),
//
// modified to abide to the Niagara reset methodology 
//		      .rst  (reset),
		      .rst  (local_rst),
		      .se   (se), .si(), .so());
   
   dffr #1  resint_ff(.din  (resum_int_i1),
		      .q    (tlu_ifu_resumint_i2),
		      .clk  (clk),
//
// modified to abide to the Niagara reset methodology 
//		      .rst  (reset),
		      .rst  (local_rst),
		      .se   (se), .si(), .so());
   
   // decode int thread id
   assign  int_thr_i1[0] = ~ind_inc_thrid_i1[1] & ~ind_inc_thrid_i1[0];
   assign  int_thr_i1[1] = ~ind_inc_thrid_i1[1] &  ind_inc_thrid_i1[0];
   assign  int_thr_i1[2] =  ind_inc_thrid_i1[1] & ~ind_inc_thrid_i1[0];
   assign  int_thr_i1[3] =  ind_inc_thrid_i1[1] &  ind_inc_thrid_i1[0];

   assign  inc_ind_ld_int_i1 = {4{hw_int_i1}} & int_thr_i1;
   assign  inc_ind_rstthr_i1 = {4{rst_int_i1}} & int_thr_i1;
   assign  rstthr_i1 = {4{rst_int_i1 | nuke_int_i1 | resum_int_i1}} 
	                & int_thr_i1;

   // decode thr_m
   // convert the signal back to non-inverting version for grape
   /*
   assign  inc_ind_thr_m_l[0] = ~(~tlu_int_tid_m[1] & ~tlu_int_tid_m[0]);
   assign  inc_ind_thr_m_l[1] = ~(~tlu_int_tid_m[1] &  tlu_int_tid_m[0]);
   assign  inc_ind_thr_m_l[2] = ~( tlu_int_tid_m[1] & ~tlu_int_tid_m[0]);
   assign  inc_ind_thr_m_l[3] = ~( tlu_int_tid_m[1] &  tlu_int_tid_m[0]);
   */

   assign  inc_ind_thr_m[0] = ~tlu_int_tid_m[1] & ~tlu_int_tid_m[0];
   assign  inc_ind_thr_m[1] = ~tlu_int_tid_m[1] &  tlu_int_tid_m[0];
   assign  inc_ind_thr_m[2] =  tlu_int_tid_m[1] & ~tlu_int_tid_m[0];
   assign  inc_ind_thr_m[3] =  tlu_int_tid_m[1] &  tlu_int_tid_m[0];
   

   // Interrupt continues to be signalled even 1 cycle after read is
   // done.  This should not be a problem, since the lsu will probably
   // burn one cycle to complete the read by forwarding it to the reg
   // file.  Otherwise, just burn another cycle in the IFU before
   // starting the thread (this is also done right now).

   assign  int_pending_i2 = ~int_pending_i2_l;

   // removed IFU will derive the siganl locally
   /*
   assign  int_activate_i2 = ~int_pending_i2_l | tlu_int_sftint_pend;
   // send message to SWL to wake up thread if it is halted
   dff #4 act_signal_reg(.din (int_activate_i2[3:0]),
			 .q   (tlu_ifu_int_activate_i3[3:0]),
			 .clk (clk),
			 .se  (se), .si(), .so());
   */
   
   // ask IFU to schedule interrupt
   dff #4 int_signal_reg(.din (int_pending_i2[3:0]),
			 .q   (tlu_ifu_hwint_i3[3:0]),
			 .clk (clk),
			 .se  (se), .si(), .so());

   dff #4 rst_signal_reg(.din (rstthr_i1[3:0]),
			 .q   (tlu_ifu_rstthr_i2[3:0]),
			 .clk (clk),
			 .se  (se), .si(), .so());


   //----------------------------------
   // ASI Registers
   //----------------------------------
   //ASI_INTR_RECEIVE: 0x72
   //ASI_UDB_INTR_W: 0x73
   //ASI_UDB_INTR_R: 0x74
   //ASI_MESSAGE_MASK: 0x7D

   // decode asi thread
   assign  asi_thr[0] = ~tlu_int_asi_thrid[1] & ~tlu_int_asi_thrid[0];
   assign  asi_thr[1] = ~tlu_int_asi_thrid[1] &  tlu_int_asi_thrid[0];
   assign  asi_thr[2] =  tlu_int_asi_thrid[1] & ~tlu_int_asi_thrid[0];
   assign  asi_thr[3] =  tlu_int_asi_thrid[1] &  tlu_int_asi_thrid[0];

   // convert the signal back to non-inverting version for grape
   // assign  inc_ind_asi_thr_l = ~asi_thr;
   // assign  inc_ind_asi_thr = asi_thr;
   
   // read or write op
   assign  asi_write = tlu_int_asi_vld & tlu_int_asi_store;
   assign  asi_read = tlu_int_asi_vld & tlu_int_asi_load;

   // decode asi target
   // ASI_INTR_RECEIVE
   assign inc_ind_asi_inrr = ~tlu_int_asi_state[7] &
	      tlu_int_asi_state[6]  &
	      tlu_int_asi_state[5] &
	      tlu_int_asi_state[4] &
	      ~tlu_int_asi_state[3]  &
	      ~tlu_int_asi_state[2] &
	      tlu_int_asi_state[1] &
	      ~tlu_int_asi_state[0];      // 0x72

   // need to also check if VA=0x40
   // what else is mapped to this asi?
   // ASI_UDB_INTR_R
   assign asi_invr = ~tlu_int_asi_state[7] &
	      tlu_int_asi_state[6]  &
	      tlu_int_asi_state[5]  &
	      tlu_int_asi_state[4]  &
	      ~tlu_int_asi_state[3]  &
	      tlu_int_asi_state[2]  &
	      ~tlu_int_asi_state[1]  &
	      ~tlu_int_asi_state[0];      // 0x74

   // VA<63:19>=0 is not checked
   // ASI_UDB_INTR_W
   assign asi_indr = ~tlu_int_asi_state[7] &
	      tlu_int_asi_state[6]  &
	      tlu_int_asi_state[5]  &
	      tlu_int_asi_state[4]  &
	      ~tlu_int_asi_state[3] &
	      ~tlu_int_asi_state[2]  &
	      tlu_int_asi_state[1]  &
	      tlu_int_asi_state[0];      // 0x73
   /*	       
   // ASI_MESSAGE_MASK_REG
   // not implemented any more
   assign  inc_ind_asi_wr_inrr = asi_thr & {4{inc_ind_asi_inrr & asi_write}};
   assign  inc_ind_asi_wr_indr = asi_thr & {4{asi_indr & asi_write}};
   assign  inc_ind_asi_rd_invr = asi_thr & {4{asi_invr & asi_read}};

   assign  red_thread = (tlu_int_redmode[0] & asi_thr[0] |
			 tlu_int_redmode[1] & asi_thr[1] |
			 tlu_int_redmode[2] & asi_thr[2] |
			 tlu_int_redmode[3] & asi_thr[3]);
   */
   // modified for bug 2109 
   // modified for one-hot mux problem and support of macro test
   // 
   assign tlu_asi_rdata_mxsel_g[0] = 
              asi_invr & ~(rst_tri_en | sehold); 
   assign tlu_asi_rdata_mxsel_g[1] = 
              inc_ind_asi_inrr & ~(rst_tri_en | asi_invr | sehold);
   assign tlu_asi_rdata_mxsel_g[2] = 
              ~((|tlu_asi_rdata_mxsel_g[1:0]) | tlu_asi_rdata_mxsel_g[3]);
   assign tlu_asi_rdata_mxsel_g[3] = 
              tlu_asi_queue_rd_vld_g & ~(rst_tri_en | asi_invr | sehold |
              inc_ind_asi_inrr); 
   // 
   assign int_tlu_asi_data_vld_g = 
          ((asi_invr | inc_ind_asi_inrr) & asi_read) | tlu_ld_data_vld_g; 
            

   dffr dffr_int_tlu_asi_data_vld_w2 (
    .din (int_tlu_asi_data_vld_g),
    .q   (int_tlu_asi_data_vld_w2),
    .clk (clk),
    .rst (local_rst),
    .se  (1'b0),       
    .si  (),          
    .so  ()
);

// modified for timing
// assign tlu_lsu_int_ldxa_vld_w2 = 
//            int_tlu_asi_data_vld_w2 & ~tlu_flush_all_w2;

assign tlu_asi_data_nf_vld_w2 = 
            int_tlu_asi_data_vld_w2; 
   // 
   // illegal va range
   //
   /*
   assign int_ld_ill_va_g = 
          ((asi_invr | inc_ind_asi_inrr) & asi_read &
            ~tlu_va_all_zero_g) | tlu_va_ill_g; 
   */
   assign int_ld_ill_va_g = tlu_va_ill_g; 

   dffr dffr_tlu_lsu_int_ld_ill_va_w2 (
    .din (int_ld_ill_va_g),
    // .q   (tlu_lsu_int_ld_ill_va_w2),
    .q   (int_ld_ill_va_w2),
    .clk (clk),
    .rst (local_rst),
    .se  (1'b0),       
    .si  (),          
    .so  ()
);

assign tlu_lsu_int_ld_ill_va_w2 = int_ld_ill_va_w2;
   // Write to INDR
   // Can send reset pkt's only in red mode
   // modified for timing
   // modified for bug3170
   /*
   assign int_or_redrst[3:0] = 
              ({4{~indr_inc_rst_pkt}} | tlu_int_redmode[3:0]) & 
			    asi_thr[3:0];

   assign indr_vld_next[3:0] = 
              inc_ind_asi_wr_indr[3:0] & int_or_redrst[3:0] |  // set
	          indr_vld[3:0] & ~indr_rst[3:0];         // reset
   // 
   // original code
   assign indr_vld_next[3] = 
              (asi_indr & asi_write & asi_thr[3] & 
              (~(|lsu_tlu_rst_pkt[1:0]) | tlu_int_redmode[3])) |
              (indr_vld[3] & ~indr_rst[3]); 

   assign indr_vld_next[2] = 
              (asi_indr & asi_write & asi_thr[2] & 
              (~(|lsu_tlu_rst_pkt[1:0]) | tlu_int_redmode[2])) |
              (indr_vld[2] & ~indr_rst[2]); 

   assign indr_vld_next[1] = 
              (asi_indr & asi_write & asi_thr[1] & 
              (~(|lsu_tlu_rst_pkt[1:0]) | tlu_int_redmode[1])) |
              (indr_vld[1] & ~indr_rst[1]); 

   assign indr_vld_next[0] = 
              (asi_indr & asi_write & asi_thr[0] & 
              (~(|lsu_tlu_rst_pkt[1:0]) | tlu_int_redmode[0])) |
              (indr_vld[0] & ~indr_rst[0]); 
   */
   assign indr_vld_next[3] = 
              (asi_indr & asi_write & asi_thr[3]) |
              (indr_vld[3] & ~indr_rst[3]); 

   assign indr_vld_next[2] = 
              (asi_indr & asi_write & asi_thr[2]) |
              (indr_vld[2] & ~indr_rst[2]); 

   assign indr_vld_next[1] = 
              (asi_indr & asi_write & asi_thr[1]) |
              (indr_vld[1] & ~indr_rst[1]); 

   assign indr_vld_next[0] = 
              (asi_indr & asi_write & asi_thr[0]) |
              (indr_vld[0] & ~indr_rst[0]); 

   dff #4 indr_vld_reg(.din (indr_vld_next[3:0]),
		       .q   (indr_vld[3:0]),
		       .clk (clk),
		       .se  (se), .si(), .so());
   // 
   // modified for bug 3945
   dffr dffr_indr_req_valid_disable(
       .din (|indr_vld[3:0]),
	   .q   (indr_req_valid_disable),
	   .clk (clk),
	   .rst  (local_rst | lsu_tlu_pcxpkt_ack), 
	   .se  (se), 
       .si(), 
       .so());

   dffe #(4) dffe_indr_req_vec(
       .din (indr_vld_next[3:0]),
	   .q   (indr_req_vec[3:0]),
       .en  (~indr_req_valid_disable),
	   .clk (clk),
	   .se  (se), 
       .si(), 
       .so());
   
   // Round robin scheduler for indr request to pcx
   sparc_ifu_rndrob  indr_sched(
       // .req_vec (indr_vld[3:0]),
       .req_vec (indr_req_vec[3:0]),
	   .advance (lsu_tlu_pcxpkt_ack),
	   .rst_tri_enable (rst_tri_en),
	   .clk (clk),
	   .reset  (local_rst),
	   .se  (se),
	   .si (si),
	   .grant_vec (indr_grant[3:0]),
	   .so ());

// convert the signal back to non-inverting version for grape
// modified to fix one-hot indetermination
     assign  inc_ind_indr_grant[0] = 
                 ~(|inc_ind_indr_grant[3:1]);
     assign  inc_ind_indr_grant[1] = 
                 indr_grant[1]; 
     assign  inc_ind_indr_grant[2] = 
                 indr_grant[2] & ~indr_grant[1];
     assign  inc_ind_indr_grant[3] = 
                 indr_grant[3] & ~(|inc_ind_indr_grant[2:1]);
//
   assign  indr_rst[3:0] = 
               {4{local_rst}} | (indr_grant[3:0] & {4{lsu_tlu_pcxpkt_ack}});
   assign  intd_done[3:0] = 
               (indr_grant[3:0] & indr_vld[3:0] & {4{lsu_tlu_pcxpkt_ack}});

   dffr #(4) intd_reg(
       .din (intd_done[3:0]),
	   .q   (int_tlu_longop_done[3:0]),
	   .clk (clk),
	   .rst  (local_rst),
	   .se  (se), 
       .si(), 
       .so());

   // INDR pcx request control signals
   // modified for bug 3945
   // assign  inc_indr_req_valid = (|indr_vld[3:0]) & ~lsu_tlu_pcxpkt_ack;
   assign  inc_indr_req_valid = indr_req_valid_disable;
   assign  inc_indr_req_thrid[1] = indr_grant[3] | indr_grant[2];
   assign  inc_indr_req_thrid[0] = indr_grant[3] | indr_grant[1];
   
endmodule // sparc_tlu_intctl
