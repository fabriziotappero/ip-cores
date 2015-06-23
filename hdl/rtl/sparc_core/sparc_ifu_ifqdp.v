// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_ifu_ifqdp.v
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
//  Module Name: sparc_ifu_ifqdp
//  Description:	
//  The IFQ is the icache fill queue.  This communicates between the
//  IFU and the outside world.  It handles icache misses and
//  invalidate requests from the crossbar.  
//
*/

//FPGA_SYN enables all FPGA related modifications
 




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








////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

module sparc_ifu_ifqdp(/*AUTOARG*/
   // Outputs
   so, ifu_lsu_pcxpkt_e, ifq_fdp_fill_inst, ifq_erb_asidata_i2, 
   ifd_inv_ifqop_i2, ifq_icd_index_bf, ifq_icd_wrdata_i2, 
   ifq_ict_wrtag_f, ifq_erb_wrindex_f, ifq_icd_wrway_bf, 
   ifd_ifc_milhit_s, ifd_ifc_instoffset0, ifd_ifc_instoffset1, 
   ifd_ifc_instoffset2, ifd_ifc_instoffset3, ifd_ifc_cpxthr_nxt, 
   ifd_ifc_cpxreq_nxt, ifd_ifc_cpxreq_i1, ifd_ifc_destid0, 
   ifd_ifc_destid1, ifd_ifc_destid2, ifd_ifc_destid3, 
   ifd_ifc_newdestid_s, ifd_ifc_pcxline_d, ifd_ifc_asi_vachklo_i2, 
   ifd_ifc_cpxvld_i2, ifd_ifc_asiaddr_i2, ifd_ifc_iobpkt_i2, 
   ifd_ifc_fwd2ic_i2, ifd_ifc_4bpkt_i2, ifd_ifc_cpxnc_i2, 
   ifd_ifc_cpxce_i2, ifd_ifc_cpxue_i2, ifd_ifc_cpxms_i2, 
   ifd_ifc_miladdr4_i2, ifd_inv_wrway_i2, 
   // Inputs
   rclk, se, si, lsu_ifu_cpxpkt_i1, lsu_ifu_asi_addr, 
   lsu_ifu_stxa_data, itlb_ifq_paddr_s, fdp_ifq_paddr_f, 
   ifc_ifd_reqvalid_e, ifc_ifd_filladdr4_i2, ifc_ifd_repway_s, 
   ifc_ifd_uncached_e, ifc_ifd_thrid_e, ifc_ifd_pcxline_adj_d, 
   ifc_ifd_errinv_e, ifc_ifd_ldmil_sel_new, ifc_ifd_ld_inq_i1, 
   ifc_ifd_idx_sel_fwd_i2, ifc_ifd_milreq_sel_d_l, 
   ifc_ifd_milfill_sel_i2_l, ifc_ifd_finst_sel_l, 
   ifc_ifd_ifqbyp_sel_fwd_l, ifc_ifd_ifqbyp_sel_inq_l, 
   ifc_ifd_ifqbyp_sel_asi_l, ifc_ifd_ifqbyp_sel_lsu_l, 
   ifc_ifd_ifqbyp_en_l, ifc_ifd_addr_sel_bist_i2_l, 
   ifc_ifd_addr_sel_asi_i2_l, ifc_ifd_addr_sel_old_i2_l, 
   ifc_ifd_addr_sel_fill_i2_l, mbist_icache_way, mbist_icache_word, 
   mbist_icache_index
   );

   input 	 rclk, 
           se, 
           si;
   
   input [145-1:0] lsu_ifu_cpxpkt_i1;
   input [17:0]   lsu_ifu_asi_addr;
   input [47:0]   lsu_ifu_stxa_data;
   
   input [39:10]  itlb_ifq_paddr_s;
   input [9:2]    fdp_ifq_paddr_f;
   
   // from ifqctl
   input         ifc_ifd_reqvalid_e;
   input         ifc_ifd_filladdr4_i2;
   input [1:0]   ifc_ifd_repway_s;
   input         ifc_ifd_uncached_e;
   input [1:0]   ifc_ifd_thrid_e;
   input [4:2]   ifc_ifd_pcxline_adj_d;
   
   input         ifc_ifd_errinv_e;
   
   // 2:1 mux selects
   input [3:0]   ifc_ifd_ldmil_sel_new;  // mil load enable
   
   input        ifc_ifd_ld_inq_i1;        // ld new cpxreq to in buffer
   input        ifc_ifd_idx_sel_fwd_i2;
   
   // other mux selects
   input [3:0]  ifc_ifd_milreq_sel_d_l,   // selects outgoing mil_req
		            ifc_ifd_milfill_sel_i2_l; // selects the mil entry just
	 // returned from the fill
	 // port
   input [3:0]  ifc_ifd_finst_sel_l;    // address to load to thr IR

   input        ifc_ifd_ifqbyp_sel_fwd_l, // select next input to process
		            ifc_ifd_ifqbyp_sel_inq_l,
		            ifc_ifd_ifqbyp_sel_asi_l,
		            ifc_ifd_ifqbyp_sel_lsu_l;
	 input        ifc_ifd_ifqbyp_en_l;   

   input        ifc_ifd_addr_sel_bist_i2_l,
		            ifc_ifd_addr_sel_asi_i2_l,
                ifc_ifd_addr_sel_old_i2_l,
		            ifc_ifd_addr_sel_fill_i2_l;
   
   input [1:0]  mbist_icache_way;
   input        mbist_icache_word;
   input [7:0]  mbist_icache_index;
   
   output       so;
   
   output [51:0] ifu_lsu_pcxpkt_e;

   output [32:0] ifq_fdp_fill_inst;
   output [47:0] ifq_erb_asidata_i2;

   output [145-1:0] ifd_inv_ifqop_i2;

   output [11:2]  ifq_icd_index_bf;   // index for wr and bist
   
   output [135:0]         ifq_icd_wrdata_i2;
   output [(39 - 11):0]  ifq_ict_wrtag_f;      // fill tag
//   output [`IC_TAG_SZ-1:0] ifq_erb_wrtag_f;      // tag w/o parity
   output [11:4]   ifq_erb_wrindex_f;
   output [1:0]            ifq_icd_wrway_bf;     // fill data way
   
   output [3:0]           ifd_ifc_milhit_s;     // if an Imiss hits in MIL
//   output [7:0]           ifd_ifc_mil_repway_s;
   
   output [1:0]           ifd_ifc_instoffset0;   // to select inst to TIR
   output [1:0]           ifd_ifc_instoffset1;   // to select inst to TIR
   output [1:0]           ifd_ifc_instoffset2;   // to select inst to TIR
   output [1:0]           ifd_ifc_instoffset3;   // to select inst to TIR

   output [1:0]            ifd_ifc_cpxthr_nxt;
   output [3:0]            ifd_ifc_cpxreq_nxt;    // cpx reqtype + vbit
   output [(143 - 140 + 1):0] ifd_ifc_cpxreq_i1;    // cpx reqtype + vbit

   
   output [2:0]            ifd_ifc_destid0,
		                       ifd_ifc_destid1,
		                       ifd_ifc_destid2,
		                       ifd_ifc_destid3,
		                       ifd_ifc_newdestid_s;

   output [4:2]            ifd_ifc_pcxline_d;

   output                  ifd_ifc_asi_vachklo_i2;
                         
   output                  ifd_ifc_cpxvld_i2;
   output [3:2]            ifd_ifc_asiaddr_i2;   
   output                  ifd_ifc_iobpkt_i2;
   output                  ifd_ifc_fwd2ic_i2;
   output                  ifd_ifc_4bpkt_i2;
   output                  ifd_ifc_cpxnc_i2;
   output                  ifd_ifc_cpxce_i2,
		                       ifd_ifc_cpxue_i2,
                           ifd_ifc_cpxms_i2;
   
   output [3:0]            ifd_ifc_miladdr4_i2;
   
   output [1:0]            ifd_inv_wrway_i2;

   
 	 
   //----------------------------------------------------------------------
   // Declarations
   //----------------------------------------------------------------------   

   // local signals
   wire [39:0]             imiss_paddr_s;
   wire [9:2]              lcl_paddr_s;
   
   wire [42:2]             mil_entry0,         // mil entries
		                       mil_entry1,
		                       mil_entry2,
		                       mil_entry3;

//   wire [42:2]             mil0_in_s,          // inputs to mil
//		                       mil1_in_s,
//		                       mil2_in_s,
//		                       mil3_in_s;

   wire                    tag_par_s,
		                       tag_par_i2;

   wire [42:2]             newmil_entry_s;
   
   wire [42:2]             mil_pcxreq_d,        // outgoing request from mil
		                       pcxreq_d,            // mil or direct ic or prev req
		                       pcxreq_e;          // outgoing request to lsu

   wire [42:2]             fill_addr_i2,
		                       fill_addr_adj,
		                       icaddr_i2,
		                       asi_addr_i2,
		                       bist_addr_i2;

   wire [42:4]             wraddr_f;


   wire [145-1:0]   inq_cpxpkt_i1,   // output from inq
//			                     inq_cpxpkt_nxt,
			                     stxa_data_pkt,
                           fwd_data_pkt,
			                     ifqop_i1,
			                     ifqop_i2;        // ifq op currently being processed

   wire [3:0]              swc_i2;
   
   wire [135:0]            icdata_i2;
   
   wire [3:0]              parity_i2,
		                       par_i2;

   wire [17:0]             asi_va_i2,
                           asi_va_i1;
   wire [13:2]             asi_fwd_index;
   wire                    clk;
   
   
//   wire [`IC_IDX_HI:6]     inv_addr_i2;
   
   //
   // Code start here 
   //

   assign                  clk = rclk;
   
   //----------------------------------------------------------------------
   // Instruction Miss - Fill Request Datapath
   //----------------------------------------------------------------------

   // new set of flops
   dff #(8) pcs_reg(.din (fdp_ifq_paddr_f[9:2]),
                    .q   (lcl_paddr_s[9:2]),
                    .clk (clk), .se(se), .si(), .so());
                    

   // bits 1:0 are floating
   assign  imiss_paddr_s = {itlb_ifq_paddr_s[39:10], 
                            lcl_paddr_s[9:2],
                            2'b0};
   
   // Check for hit in MIL
   // Should we enable the comps to save power? -- timing problem

   // compare only top 35 bits (bot 5 bits are line offset of 32B line)
   sparc_ifu_cmp35 milcmp0 (.hit (ifd_ifc_milhit_s[0]),
			                      .a (imiss_paddr_s[39:5]),
			                      .b (mil_entry0[39:5]),
			                      .valid (1'b1)
			                      );
   
   sparc_ifu_cmp35 milcmp1 (.hit (ifd_ifc_milhit_s[1]),
			                      .a (imiss_paddr_s[39:5]),
			                      .b (mil_entry1[39:5]),
			                      .valid (1'b1)
			                      );
   
   sparc_ifu_cmp35 milcmp2 (.hit (ifd_ifc_milhit_s[2]),
			                      .a (imiss_paddr_s[39:5]),
			                      .b (mil_entry2[39:5]),
			                      .valid (1'b1)
			                      );
   sparc_ifu_cmp35 milcmp3 (.hit (ifd_ifc_milhit_s[3]),
			                      .a (imiss_paddr_s[39:5]),
			                      .b (mil_entry3[39:5]),
			                      .valid (1'b1)
			                      );

   // Send replacement way to ctl logic
//   assign  ifd_ifc_mil_repway_s =  {mil_entry3[41:40],
//	                                  mil_entry2[41:40],
//	                                  mil_entry1[41:40],
//	                                  mil_entry0[41:40]};


   // calculate tag parity
   sparc_ifu_par32 tag_par(.in  ({{(32 - (39 - 11)){1'b0}}, 
                                  imiss_paddr_s[39:(11 + 1)]}),
			                     .out (tag_par_s));


   // Missed Instruction List
   // 43    - NOT cacheable
   // 42    - tag parity
   // 41:40 - repl way
   // 39:0  - paddr

   // Prepare Missed Instruction List entry
   assign  newmil_entry_s = {tag_par_s,
			                       ifc_ifd_repway_s,			    
			                       imiss_paddr_s[39:2]};

   // ldmil_sel is thr_s[3:0] & imiss_s
//   dp_mux2es  #(41)    milin_mux0(.dout (mil0_in_s),
//				                          .in0  (mil_entry0), 
//				                          .in1  (newmil_entry_s),
//				                          .sel  (ifc_ifd_ldmil_sel_new[0]));
//   dp_mux2es  #(41)    milin_mux1(.dout (mil1_in_s),
//				                        .in0  (mil_entry1), 
//				                        .in1  (newmil_entry_s),
//				                        .sel  (ifc_ifd_ldmil_sel_new[1]));
//   dp_mux2es  #(41)    milin_mux2(.dout (mil2_in_s),
//				                        .in0  (mil_entry2), 
//				                        .in1  (newmil_entry_s),
//				                        .sel  (ifc_ifd_ldmil_sel_new[2]));
//   dp_mux2es  #(41)    milin_mux3(.dout (mil3_in_s),
//				                        .in0  (mil_entry3), 
//				                        .in1  (newmil_entry_s),
//				                        .sel  (ifc_ifd_ldmil_sel_new[3]));

   wire    clk_mil0;







   wire    clk_mil1;







   wire    clk_mil2;







   wire    clk_mil3;







   


   dffe #(41)   mil0(.din  (newmil_entry_s), 
		                .en (~(~ifc_ifd_ldmil_sel_new[0])), .clk(rclk), 
		                .q    (mil_entry0), 
		                .se   (se), .si(), .so());








   dffe #(41)   mil1(.din (newmil_entry_s), 
		                .en (~(~ifc_ifd_ldmil_sel_new[1])), .clk(rclk), 
		                .q   (mil_entry1), 
		                .se  (se), .si(), .so());








   dffe #(41)   mil2(.din (newmil_entry_s), 
		                .en (~(~ifc_ifd_ldmil_sel_new[2])), .clk(rclk), 
		                .q   (mil_entry2), 
		                .se  (se), .si(), .so());








   dffe #(41)   mil3(.din (newmil_entry_s), 
		                .en (~(~ifc_ifd_ldmil_sel_new[3])), .clk(rclk), 
		                .q   (mil_entry3), 
		                .se  (se), .si(), .so());







   assign  ifd_ifc_newdestid_s = {imiss_paddr_s[39], 
				                          imiss_paddr_s[7:6]};
   assign  ifd_ifc_destid0 = {mil_entry0[39], 
			                        mil_entry0[7:6]};
   assign  ifd_ifc_destid1 = {mil_entry1[39], 
			                        mil_entry1[7:6]};
   assign  ifd_ifc_destid2 = {mil_entry2[39], 
			                        mil_entry2[7:6]};
   assign  ifd_ifc_destid3 = {mil_entry3[39], 
			                        mil_entry3[7:6]};

   assign  ifd_ifc_instoffset0 = mil_entry0[3:2];
   assign  ifd_ifc_instoffset1 = mil_entry1[3:2];
   assign  ifd_ifc_instoffset2 = mil_entry2[3:2];
   assign  ifd_ifc_instoffset3 = mil_entry3[3:2];
   
   
   // MIL Request Out mux
   dp_mux4ds  #(41)  milreq_mux (.dout (mil_pcxreq_d),
			                         .in0  ({mil_entry0[42:2]}),
			                         .in1  ({mil_entry1[42:2]}),
			                         .in2  ({mil_entry2[42:2]}),
			                         .in3  ({mil_entry3[42:2]}),
			                         .sel0_l  (ifc_ifd_milreq_sel_d_l[0]),
			                         .sel1_l  (ifc_ifd_milreq_sel_d_l[1]),
			                         .sel2_l  (ifc_ifd_milreq_sel_d_l[2]),
			                         .sel3_l  (ifc_ifd_milreq_sel_d_l[3]));
   
   // Next PCX Request Mux
//   dp_mux3ds  #(44)  nxtpcx_mux (.dout  (pcxreq_d),
//			                         .in0   (mil_pcxreq_d), 
//			                         .in1   (44'bx),
//			                         .in2   (pcxreq_e),
//			                         .sel0_l  (ifc_ifd_nxtpcx_sel_new_d_l),
//			                         .sel1_l  (ifc_ifd_nxtpcx_sel_err_d_l),
//			                         .sel2_l  (ifc_ifd_nxtpcx_sel_prev_d_l));


   // TBD: If destid == any L2 bank, need to zero out bit 4 for Rams
   //    -- done
   assign  ifd_ifc_pcxline_d[4:2] = mil_pcxreq_d[4:2];
   
   assign  pcxreq_d[42:5] = mil_pcxreq_d[42:5];
   assign  pcxreq_d[4:2] = ifc_ifd_pcxline_adj_d[4:2];
//   assign  pcxreq_d[1:0] = mil_pcxreq_d[1:0];  // dont need this

   dff #(41) pcxreq_reg (.din  (pcxreq_d),
			                    .clk  (clk),
			                    .q    (pcxreq_e),
			                    .se   (se), .si(), .so());

// CHANGE to regular dff   
//   dffe #(44) pcxreq_reg (.din  (pcxreq_d),
//			                    .clk  (clk),
//			                    .q    (pcxreq_e),
//                          .en   (ifc_ifd_nxtpcx_sel_new_d),
//			                    .se   (se), .si(), .so());
   
   // PCX Req Reg -- req type is 5 bits
   assign   ifu_lsu_pcxpkt_e = {ifc_ifd_reqvalid_e,   // 51    - valid
			                          ifc_ifd_errinv_e,     // 50 - inv all ways
                                ifc_ifd_uncached_e,   // 49 - not cacheable
			                          {5'b10000},          // 48:44 - req type
			                          pcxreq_e[41:40],      // 43:42 - rep way
			                          ifc_ifd_thrid_e[1:0], // 41:40 - thrid
			                          pcxreq_e[39:2],       // 39:2  - word address
			                          2'b0};                // force to zero
   

   //----------------------------------------------------------------------
   // Fill Return Address
   //----------------------------------------------------------------------

   // MIL Fill Return Mux
   dp_mux4ds  #(41)  milfill_mux(.dout (fill_addr_i2),
			                         .in0 ( mil_entry0),
			                         .in1 ( mil_entry1),
			                         .in2 ( mil_entry2),
			                         .in3 ( mil_entry3),
			                         .sel0_l (ifc_ifd_milfill_sel_i2_l[0]),
			                         .sel1_l (ifc_ifd_milfill_sel_i2_l[1]),
			                         .sel2_l (ifc_ifd_milfill_sel_i2_l[2]),
			                         .sel3_l (ifc_ifd_milfill_sel_i2_l[3]));

   assign   ifd_ifc_miladdr4_i2[3:0]  = {mil_entry3[4],
                                         mil_entry2[4],
                                         mil_entry1[4],
                                         mil_entry0[4]};
   
   assign   ifd_ifc_iobpkt_i2 = fill_addr_i2[39];
   assign   fill_addr_adj = {fill_addr_i2[42:5], 
			                       ifc_ifd_filladdr4_i2,
			                       fill_addr_i2[3:2]};
   // determine if this is cacheable in I$
   // moved to ifqctl
//   assign   ifd_ifc_uncached_i2 = fill_addr_i2[43];

   // merged with addren mux to save some timing
   dp_mux4ds #(41) icadr_mux(.dout (icaddr_i2),
			                       .in0  (fill_addr_adj),
			                       .in1  (asi_addr_i2),
			                       .in2  (bist_addr_i2),
                             .in3  ({wraddr_f[42:4], 2'b0}),
			                       .sel0_l (ifc_ifd_addr_sel_fill_i2_l),
			                       .sel1_l (ifc_ifd_addr_sel_asi_i2_l),
			                       .sel2_l (ifc_ifd_addr_sel_bist_i2_l),
                             .sel3_l (ifc_ifd_addr_sel_old_i2_l));
   
   // way, 32B line sel
   assign ifd_inv_wrway_i2 =  icaddr_i2[41:40];

//   dp_mux2es  #(39)  addren_mux(.dout (wraddr_i2),
//			                        .in0  (wraddr_f),
//			                        .in1  (icaddr_i2[42:4]),
//			                        .sel  (ifc_ifd_ifqadv_i2));

   
   dff #(39) wraddr_reg(.din  (icaddr_i2[42:4]),
		                    .clk  (clk),
		                    .q    (wraddr_f[42:4]),
		                    .se   (se), .si(), .so());

   // tag = parity bit + `IC_TAG_SZ bits of address
   assign  ifq_erb_wrindex_f = wraddr_f[11:4];
   assign  ifq_ict_wrtag_f = {wraddr_f[42], wraddr_f[39:(11 + 1)]};

   assign  ifq_icd_index_bf = icaddr_i2[11:2];
   assign  ifq_icd_wrway_bf = icaddr_i2[41:40];

   //----------------------------------------------------------------------
   // Fill Return Data
   //----------------------------------------------------------------------
   // IFQ-IBUF
   // inq is the same size as the cpx_width
   // inq is replaced with a single flop, ibuf

   // ibuf enable mux
//   dp_mux2es  #(`CPX_WIDTH)  ifqen_mux(.dout (inq_cpxpkt_nxt),
//				                             .in0 (inq_cpxpkt_i1),
//				                             .in1 (lsu_ifu_cpxpkt_i1), 
//				                             .sel (ifc_ifd_ld_inq_i1));

   wire    clk_ibuf1;







                             

   dffe #(145) ibuf(.din (lsu_ifu_cpxpkt_i1),
			                  .q   (inq_cpxpkt_i1),
			                  .en (~(~ifc_ifd_ld_inq_i1)), .clk(rclk),
			                  .se  (se), .si(), .so());







   assign  ifd_ifc_cpxreq_i1 = {inq_cpxpkt_i1[144], 
			                          inq_cpxpkt_i1[143:140]};

   // ifq operand bypass mux
   // fill pkt is 128d+2w+2t+3iw+1v+1nc+4r = 140
   dp_mux4ds  #(145)  ifq_bypmux(.dout (ifqop_i1),
				                              .in0 (fwd_data_pkt), 
				                              .in1 (inq_cpxpkt_i1),
				                              .in2 (stxa_data_pkt),
				                              .in3 (lsu_ifu_cpxpkt_i1),
				                              .sel0_l (ifc_ifd_ifqbyp_sel_fwd_l),
				                              .sel1_l (ifc_ifd_ifqbyp_sel_inq_l),
				                              .sel2_l (ifc_ifd_ifqbyp_sel_asi_l),
				                              .sel3_l (ifc_ifd_ifqbyp_sel_lsu_l));
   
   wire    clk_ifqop;







   

   dffe #(145)  ifqop_reg(.din (ifqop_i1), 
			                        .q   (ifqop_i2), 
			                        .en (~(ifc_ifd_ifqbyp_en_l)), .clk(rclk), 
			                        .se  (se), .si(), .so());






   assign  ifd_inv_ifqop_i2 = ifqop_i2;
   
   // switch condition pre decode
   sparc_ifu_swpla  swpla0(.in  (ifqop_i2[31:0]),
			                     .out (swc_i2[0]));
   sparc_ifu_swpla  swpla1(.in  (ifqop_i2[63:32]),
			                     .out (swc_i2[1]));
   sparc_ifu_swpla  swpla2(.in  (ifqop_i2[95:64]),
			                     .out (swc_i2[2]));
   sparc_ifu_swpla  swpla3(.in  (ifqop_i2[127:96]),
			                     .out (swc_i2[3]));

   // Add Parity to each inst.
   sparc_ifu_par32 par0(.in  (ifqop_i2[31:0]),
			                  .out (par_i2[0]));
   sparc_ifu_par32 par1(.in  (ifqop_i2[63:32]),
			                  .out (par_i2[1]));
   sparc_ifu_par32 par2(.in  (ifqop_i2[95:64]),
			                  .out (par_i2[2]));
   sparc_ifu_par32 par3(.in  (ifqop_i2[127:96]),
			                  .out (par_i2[3]));

   // add 8 xor gates in the dp
   //   assign parity_i2 = par_i2 ^ swc_i2 ^ {4{ifc_ifd_insert_pe}};
   //   assign tag_par_i2 = par_i2[0] ^ ifc_ifd_insert_pe;

   // Make the par32 cell above, par33 and include cpxue_i2
   assign   parity_i2 = par_i2 ^ swc_i2 ^ {4{ifd_ifc_cpxue_i2}};
   assign   tag_par_i2 = par_i2[0] ^ ifd_ifc_cpxue_i2;
   
   // parity, swc, inst[31:0]
   assign   icdata_i2 = {parity_i2[3], ifqop_i2[127:96], swc_i2[3],
		                     parity_i2[2], ifqop_i2[95:64],  swc_i2[2],
		                     parity_i2[1], ifqop_i2[63:32],  swc_i2[1],
		                     parity_i2[0], ifqop_i2[31:0],   swc_i2[0]};

   // write data to icache
   assign ifq_icd_wrdata_i2 = icdata_i2;


   // very critical
   assign ifd_ifc_cpxreq_nxt   = ifqop_i1[143:140];
   assign ifd_ifc_cpxthr_nxt   = ifqop_i1[135:134];

   assign ifd_ifc_cpxvld_i2   = ifqop_i2[144];
   assign ifd_ifc_4bpkt_i2    = ifqop_i2[130];
   assign ifd_ifc_cpxce_i2    = ifqop_i2[137];
   assign ifd_ifc_cpxue_i2    = ifqop_i2[(137 + 1)];
   assign ifd_ifc_cpxms_i2    = ifqop_i2[(137 + 2)];
   assign ifd_ifc_cpxnc_i2    = ifqop_i2[136];
   assign ifd_ifc_fwd2ic_i2   = ifqop_i2[103];

   // instr sel mux to write to thread inst regsiter in S stage
   // instr is always BIG ENDIAN
   dp_mux4ds  #(33)  fillinst_mux(.dout (ifq_fdp_fill_inst),
				                        .in0 (icdata_i2[134:102]),
				                        .in1 (icdata_i2[100:68]),
				                        .in2 (icdata_i2[66:34]),
				                        .in3 (icdata_i2[32:0]),
				                        .sel0_l (ifc_ifd_finst_sel_l[0]),
				                        .sel1_l (ifc_ifd_finst_sel_l[1]),
				                        .sel2_l (ifc_ifd_finst_sel_l[2]),
				                        .sel3_l (ifc_ifd_finst_sel_l[3]));

   // synopsys translate_off
//`ifdef DEFINE_0IN
//`else
//   always @ (ifq_fdp_fill_inst or ifd_ifc_cpxreq_i2)
//     if (((^ifq_fdp_fill_inst[32:0]) == 1'bx) && (ifd_ifc_cpxreq_i2 == `CPX_IFILLPKT))
//       begin
//          $display("ifqdp.v: Imiss Return val = %h\n", ifqop_i2);
//          $display("IFQCPX", "Error: X's detected in Imiss Return Inst %h", 
//                 ifq_fdp_fill_inst[31:0]);
//       end
//`endif
   // synopsys translate_on
   
   
   // TBD: 1. inv way in fill pkt -- DONE
   //      2. inv packet -- DONE
   //      3. DFT pkt from TAP -- NO NEED
   //      4. Ld pkt to invalidate i$  -- DONE

   //----------------------------------------------------------------------
   // ASI Access
   //----------------------------------------------------------------------
   // mux stxa pkt into the cpx
   assign  stxa_data_pkt[144] = 1'b0;
   // vbits and parity are muxed into the cpxreq
   assign  stxa_data_pkt[143:140] = {1'b1, lsu_ifu_stxa_data[34:32]}; 
//   assign  stxa_data_pkt[`CPX_THRFIELD] = lsu_ifu_asi_thrid[1:0];
   assign  stxa_data_pkt[135:134] = 2'b0;   
   // use parity to insert error in icache inst or tag
   assign  stxa_data_pkt[(137 + 1)] = lsu_ifu_stxa_data[32];   
   assign  stxa_data_pkt[127:0] = {4{lsu_ifu_stxa_data[31:0]}};

   // other bits need to be tied off
   assign  stxa_data_pkt[133:128] = 6'b0;   
   assign  stxa_data_pkt[137:136] = 2'b0;   
   assign  stxa_data_pkt[139] = 1'b0;

   // format fwd data pkt in a similar way
   assign  fwd_data_pkt[144:(137 + 2)] = ifqop_i2[144:(137 + 2)];
   assign  fwd_data_pkt[(137 + 1)] = ifqop_i2[32];   
   assign  fwd_data_pkt[137:128] = ifqop_i2[137:128];
   assign  fwd_data_pkt[127:0] = {4{ifqop_i2[31:0]}};
   

   
   dff #(16) stxa_ff(.din (lsu_ifu_stxa_data[47:32]),
		                 .q   (ifq_erb_asidata_i2[47:32]), 
		                 .clk (clk), .se(se), .si(), .so());
   assign  ifq_erb_asidata_i2[31:0] = ifqop_i2[31:0];

   // va[63:32] is truncated
   // In this architecture we only need va[17:0]
   // rest of the bits ar ehere only for the address range check
   // 12 new muxes (10 for addr, 2 for way)
   // CHANGE: this mux has been moved before the asi_addr_reg, rather
   // than after.
   // Use mux flop soffm2?
   dp_mux2es #(12) asifwd_mx(.dout (asi_fwd_index[13:2]),
                             .in0  ({lsu_ifu_asi_addr[17:16],   // asi way
                                     lsu_ifu_asi_addr[12:3]}),  // asi addr
                             .in1  ({ifqop_i2[81:80],    // fwd rq way
                                     ifqop_i2[76:67]}),  // fwd rq addr
                             .sel  (ifc_ifd_idx_sel_fwd_i2));

   assign asi_va_i1 = {asi_fwd_index[13:12],
                       lsu_ifu_asi_addr[15:13],
                       asi_fwd_index[11:2],
                       lsu_ifu_asi_addr[2:0]};
   
   dff #(18) asi_addr_reg(.din (asi_va_i1[17:0]),  // 15:13 is not used
			                    .q   (asi_va_i2[17:0]),
			                    .clk (clk),
			                    .se  (se), .si(), .so());

   // 16b zero cmp: leave out bit 3!! (imask is 0x8)
   assign  ifd_ifc_asi_vachklo_i2 = (|asi_va_i2[16:4]) | (|asi_va_i2[2:0]);

   // mux in ifqop and asi_va_i2 to create new asi va?
   // asi va is shifted by 1 bit to look like 64b op
   assign    ifd_ifc_asiaddr_i2[3:2] = asi_va_i2[4:3];

   assign    asi_addr_i2 = {tag_par_i2,           // tag parity 42
			                      asi_va_i2[17:16],     // way 41:40
			                      ifqop_i2[27:0],       // tag 39:12
			                      asi_va_i2[12:3]       // index 11:2
                            };                 

   // bist has to go to icache in the same cycle
   // cannot flop it
   assign    bist_addr_i2 = {1'b0,                    // par
			                       mbist_icache_way[1:0],   // way 41:40
			                       28'b0,                   // tag 39:12
			                       mbist_icache_index[7:0], // index 11:4
                             mbist_icache_word,       // 3
			                       1'b0
			                       };

   // floating signals
   sink #(2) s0(.in (imiss_paddr_s[1:0]));
   sink s1(.in (pcxreq_e[42]));
   sink s2(.in (fill_addr_i2[4]));
   
   
endmodule // sparc_ifu_ifqdp



