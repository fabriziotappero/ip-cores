// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: cpx_spc_rpt.v
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
/*
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


module cpx_spc_rpt (/*AUTOARG*/
   // Outputs
   so, cpx_spc_data_cx3, cpx_spc_data_rdy_cx3, 
   cpx_spc_data_cx3_b144to140, cpx_spc_data_cx3_b120to118, 
   cpx_spc_data_cx3_b0, cpx_spc_data_cx3_b4, cpx_spc_data_cx3_b8, 
   cpx_spc_data_cx3_b12, cpx_spc_data_cx3_b16, cpx_spc_data_cx3_b20, 
   cpx_spc_data_cx3_b24, cpx_spc_data_cx3_b28, cpx_spc_data_cx3_b32, 
   cpx_spc_data_cx3_b35, cpx_spc_data_cx3_b38, cpx_spc_data_cx3_b41, 
   cpx_spc_data_cx3_b44, cpx_spc_data_cx3_b47, cpx_spc_data_cx3_b50, 
   cpx_spc_data_cx3_b53, cpx_spc_data_cx3_b56, cpx_spc_data_cx3_b60, 
   cpx_spc_data_cx3_b64, cpx_spc_data_cx3_b68, cpx_spc_data_cx3_b72, 
   cpx_spc_data_cx3_b76, cpx_spc_data_cx3_b80, cpx_spc_data_cx3_b84, 
   cpx_spc_data_cx3_b88, cpx_spc_data_cx3_b91, cpx_spc_data_cx3_b94, 
   cpx_spc_data_cx3_b97, cpx_spc_data_cx3_b100, 
   cpx_spc_data_cx3_b103, cpx_spc_data_cx3_b106, 
   cpx_spc_data_cx3_b109, 
   // Inputs
   rclk, si, se, cpx_spc_data_cx2, cpx_spc_data_rdy_cx2
   );

input rclk;
   input si;
   input se;

   
input  [145-1:0] cpx_spc_data_cx2;      
input                   cpx_spc_data_rdy_cx2;

   output               so;
output [145-1:0] cpx_spc_data_cx3;
output                  cpx_spc_data_rdy_cx3;    

output [145-1:140] cpx_spc_data_cx3_b144to140 ;
output [120:118] cpx_spc_data_cx3_b120to118 ;
output        cpx_spc_data_cx3_b0 ;
output        cpx_spc_data_cx3_b4 ;
output        cpx_spc_data_cx3_b8 ;
output        cpx_spc_data_cx3_b12 ;
output        cpx_spc_data_cx3_b16 ;
output        cpx_spc_data_cx3_b20 ;
output        cpx_spc_data_cx3_b24 ;
output        cpx_spc_data_cx3_b28 ;

output        cpx_spc_data_cx3_b32 ;
output        cpx_spc_data_cx3_b35 ;
output        cpx_spc_data_cx3_b38 ;
output        cpx_spc_data_cx3_b41 ;
output        cpx_spc_data_cx3_b44 ;
output        cpx_spc_data_cx3_b47 ;
output        cpx_spc_data_cx3_b50 ;
output        cpx_spc_data_cx3_b53 ;

output        cpx_spc_data_cx3_b56 ;
output        cpx_spc_data_cx3_b60 ;
output        cpx_spc_data_cx3_b64 ;
output        cpx_spc_data_cx3_b68 ;
output        cpx_spc_data_cx3_b72 ;
output        cpx_spc_data_cx3_b76 ;
output        cpx_spc_data_cx3_b80 ;
output        cpx_spc_data_cx3_b84 ;

output        cpx_spc_data_cx3_b88 ;
output        cpx_spc_data_cx3_b91 ;
output        cpx_spc_data_cx3_b94 ;
output        cpx_spc_data_cx3_b97 ;
output        cpx_spc_data_cx3_b100 ;
output        cpx_spc_data_cx3_b103 ;
output        cpx_spc_data_cx3_b106 ;
output        cpx_spc_data_cx3_b109 ;


reg [145-1:0] cpx_spc_data_cx3;
reg                  cpx_spc_data_rdy_cx3;
   
always @(posedge rclk) begin
   cpx_spc_data_cx3     <= cpx_spc_data_cx2;
   cpx_spc_data_rdy_cx3 <= cpx_spc_data_rdy_cx2;
end

//timing fix: 9/5/03 - add separate buffer to lsu for signal that are used in bypass i.e. isolate from spu/ffu loading
assign  cpx_spc_data_cx3_b144to140[145-1:140]  =  cpx_spc_data_cx3[145-1:140] ;
assign  cpx_spc_data_cx3_b120to118[120:118]  =  cpx_spc_data_cx3[120:118] ;

assign  cpx_spc_data_cx3_b0  =  cpx_spc_data_cx3[0] ;
assign  cpx_spc_data_cx3_b4  =  cpx_spc_data_cx3[4] ;
assign  cpx_spc_data_cx3_b8  =  cpx_spc_data_cx3[8] ;
assign  cpx_spc_data_cx3_b12  =  cpx_spc_data_cx3[12] ;
assign  cpx_spc_data_cx3_b16  =  cpx_spc_data_cx3[16] ;
assign  cpx_spc_data_cx3_b20  =  cpx_spc_data_cx3[20] ;
assign  cpx_spc_data_cx3_b24  =  cpx_spc_data_cx3[24] ;
assign  cpx_spc_data_cx3_b28  =  cpx_spc_data_cx3[28] ;

assign  cpx_spc_data_cx3_b32  =  cpx_spc_data_cx3[32] ;
assign  cpx_spc_data_cx3_b35  =  cpx_spc_data_cx3[35] ;
assign  cpx_spc_data_cx3_b38  =  cpx_spc_data_cx3[38] ;
assign  cpx_spc_data_cx3_b41  =  cpx_spc_data_cx3[41] ;
assign  cpx_spc_data_cx3_b44  =  cpx_spc_data_cx3[44] ;
assign  cpx_spc_data_cx3_b47  =  cpx_spc_data_cx3[47] ;
assign  cpx_spc_data_cx3_b50  =  cpx_spc_data_cx3[50] ;
assign  cpx_spc_data_cx3_b53  =  cpx_spc_data_cx3[53] ;

assign  cpx_spc_data_cx3_b56  =  cpx_spc_data_cx3[56] ;
assign  cpx_spc_data_cx3_b60  =  cpx_spc_data_cx3[60] ;
assign  cpx_spc_data_cx3_b64  =  cpx_spc_data_cx3[64] ;
assign  cpx_spc_data_cx3_b68  =  cpx_spc_data_cx3[68] ;
assign  cpx_spc_data_cx3_b72  =  cpx_spc_data_cx3[72] ;
assign  cpx_spc_data_cx3_b76  =  cpx_spc_data_cx3[76] ;
assign  cpx_spc_data_cx3_b80  =  cpx_spc_data_cx3[80] ;
assign  cpx_spc_data_cx3_b84  =  cpx_spc_data_cx3[84] ;

assign  cpx_spc_data_cx3_b88  =  cpx_spc_data_cx3[88] ;
assign  cpx_spc_data_cx3_b91  =  cpx_spc_data_cx3[91] ;
assign  cpx_spc_data_cx3_b94  =  cpx_spc_data_cx3[94] ;
assign  cpx_spc_data_cx3_b97  =  cpx_spc_data_cx3[97] ;
assign  cpx_spc_data_cx3_b100  =  cpx_spc_data_cx3[100] ;
assign  cpx_spc_data_cx3_b103  =  cpx_spc_data_cx3[103] ;
assign  cpx_spc_data_cx3_b106  =  cpx_spc_data_cx3[106] ;
assign  cpx_spc_data_cx3_b109  =  cpx_spc_data_cx3[109] ;

endmodule   
