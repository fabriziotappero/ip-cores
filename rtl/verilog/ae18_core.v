/*
 * $Id: ae18_core.v,v 1.8 2007-10-11 18:51:49 sybreon Exp $
 * 
 * AE18 8-bit Microprocessor Core
 * Copyright (C) 2006 Shawn Tan Ser Ngiap <shawn.tan@aeste.net>
 *  
 * This library is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU Lesser General Public License as published by 
 * the Free Software Foundation; either version 2.1 of the License, 
 * or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 * USA
 *
 * DESCRIPTION
 * This core provides a PIC18 software compatible core. It does not provide
 * any of the additional functionality needed to form a full PIC18 micro-
 * controller system. Additional functionality such as I/O devices would
 * need to be integrated with the core. This core provides the necessary
 * signals to wire up WISHBONE compatible devices to it.
 *
 * HISTORY
 * $Log: not supported by cvs2svn $
 * Revision 1.7  2007/04/13 22:18:51  sybreon
 * Moved testbench into sim/verilog/testbench.v
 * Minor cleanup.
 *
 * Revision 1.6  2007/04/03 22:13:25  sybreon
 * Fixed various bugs:
 * - STATUS,C not correct for subtraction instructions
 * - Data memory indirect addressing mode bugs
 * - Other minor fixes
 *
 * Revision 1.5  2007/03/04 23:26:37  sybreon
 * Rearranged code to make it synthesisable.
 *
 * Revision 1.4  2006/12/29 18:08:56  sybreon
 * Minor code clean up
 * 
 */

module ae18_core (/*AUTOARG*/
   // Outputs
   wb_clk_o, wb_rst_o, iwb_adr_o, iwb_dat_o, iwb_stb_o, iwb_we_o,
   iwb_sel_o, dwb_adr_o, dwb_dat_o, dwb_stb_o, dwb_we_o,
   // Inputs
   iwb_dat_i, iwb_ack_i, dwb_dat_i, dwb_ack_i, int_i, inte_i, clk_i,
   rst_i
   ) ;
   // Instruction address bit length
   parameter ISIZ = 20;
   // Data address bit length
   parameter DSIZ = 12;
   // WDT length
   parameter WSIZ = 16;   
   
   // System WB
   output 	     wb_clk_o, wb_rst_o;

   // Instruction WB Bus
   output [ISIZ-1:0] iwb_adr_o;
   output [15:0]     iwb_dat_o;
   output 	     iwb_stb_o, iwb_we_o;
   output [1:0]      iwb_sel_o;   
   input [15:0]      iwb_dat_i;
   input 	     iwb_ack_i;

   // Data WB Bus
   output [DSIZ-1:0] dwb_adr_o;
   output [7:0]      dwb_dat_o;
   output 	     dwb_stb_o, dwb_we_o;
   input [7:0] 	     dwb_dat_i;
   input 	     dwb_ack_i;   

   // System
   input [1:0] 	     int_i;
   input [7:6] 	     inte_i;   
   input 	     clk_i, rst_i;

   /*
    * Parameters
    */
   // State Registers
   parameter [2:0] 
		FSM_RUN = 4'h0,
		FSM_ISRL = 4'h1,
		FSM_ISRH = 4'h2,
		FSM_SLEEP = 4'h3;
   
   parameter [1:0]
		FSM_Q0 = 2'h0,
		FSM_Q1 = 2'h1,
		FSM_Q2 = 2'h2,
		FSM_Q3 = 2'h3;   
	
   // MX_SRC
   parameter [1:0]
		MXSRC_MASK = 2'h2,
		MXSRC_LIT = 2'h3,
		MXSRC_WREG = 2'h0,
		MXSRC_FILE = 2'h1;
   // MX_TGT
   parameter [1:0]
		MXTGT_MASK = 2'h2,
		MXTGT_LIT = 2'h3,
		MXTGT_WREG = 2'h0,
		MXTGT_FILE = 2'h1;
   // MX_DST
   parameter [1:0]
		MXDST_NULL = 2'h0,
		MXDST_EXT = 2'h1,
		MXDST_WREG = 2'h2,
		MXDST_FILE = 2'h3;   

   // MX_ALU
   parameter [3:0]
		MXALU_XOR = 4'h0,
		MXALU_IOR = 4'h1,
		MXALU_AND = 4'h2,
		MXALU_SWAP = 4'h3,
		MXALU_ADD = 4'h4,
		MXALU_ADDC = 4'h5,
		MXALU_SUB = 4'h6,
		MXALU_SUBC = 4'h7,
		MXALU_RLNC = 4'h8,
		MXALU_RLC = 4'h9,
		MXALU_RRNC = 4'hA,
		MXALU_RRC = 4'hB,
		MXALU_NEG = 4'hC,
		// EXTRA
		MXALU_MOVLB = 4'hC,
		MXALU_DAW = 4'hD,
		MXALU_LFSR = 4'hE,
		MXALU_MUL = 4'hF;

	// MX_BSR   
   parameter [1:0]
		MXBSR_BSR = 2'o3,
		MXBSR_BSA = 2'o2,
		MXBSR_LIT = 2'o1,
		MXBSR_NUL = 2'o0;   

	// MX_SKP
   parameter [2:0]
		MXSKP_SZ = 3'o1,
		MXSKP_SNZ = 3'o2,
		MXSKP_SNC = 3'o3,
		MXSKP_SU = 3'o4,
		MXSKP_SCC = 3'o7,
		MXSKP_NON = 3'o0;
   
   // NPC_MX
   parameter [2:0]
		MXNPC_FAR = 3'o3,
		MXNPC_NEAR = 3'o2,
		MXNPC_BCC = 3'o7,
		MXNPC_RET = 3'o1,
		MXNPC_RESET = 3'o4,
		MXNPC_ISRH = 3'o5,
		MXNPC_ISRL = 3'o6,
		MXNPC_INC = 3'o0;

   // MX_STA
   parameter [2:0]
		MXSTA_ALL = 3'o7,
		MXSTA_CZN = 3'o1,
		MXSTA_ZN = 3'o2,
		MXSTA_Z = 3'o3,
		MXSTA_C = 3'o4,
		MXSTA_NONE = 3'o0;

   // BCC_MX
   parameter [2:0]
		MXBCC_BZ = 3'o0,
		MXBCC_BNZ = 3'o1,
		MXBCC_BC = 3'o2,
		MXBCC_BNC = 3'o3,
		MXBCC_BOV = 3'o4,
		MXBCC_BNOV = 3'o5,
		MXBCC_BN = 3'o6,
		MXBCC_BNN = 3'o7;

   // STK_MX
   parameter [1:0]
		MXSTK_PUSH = 2'o2,
		MXSTK_POP = 2'o1,
		MXSTK_NONE = 2'o0;

   // SHADOW MX
   parameter [1:0]
		MXSHA_CALL = 2'o2,
		MXSHA_RET = 2'o1,
		MXSHA_NONE = 2'o0;

   // TBLRD/TBLWT MX
   parameter [3:0]
		MXTBL_RD = 4'h8,
		MXTBL_RDINC = 4'h9,
		MXTBL_RDDEC = 4'hA,
		MXTBL_RDPRE = 4'hB,
		MXTBL_WT = 4'hC,
		MXTBL_WTINC = 4'hD,
		MXTBL_WTDEC = 4'hE,
		MXTBL_WTPRE = 4'hF,
		MXTBL_NOP = 4'h0;
   
   // Machine Status
   //output [3:0]      qena_o;
   //output [1:0]      qfsm_o;
   //output [1:0]      qmod_o;   
  
   // Special Function Registers
   reg [4:0] 	     rPCU;
   reg [7:0] 	     rPCH,rPCL, rTOSU, rTOSH, rTOSL,
		     rPCLATU, rPCLATH, 
		     rTBLPTRU, rTBLPTRH, rTBLPTRL, rTABLAT,
		     rPRODH, rPRODL,
		     rFSR0H, rFSR0L, rFSR1H, rFSR1L, rFSR2H, rFSR2L;
   
   reg  	     rSWDTEN, rSTKFUL, rSTKUNF;
   reg 		     rZ,rOV,rDC,rN,rC;
 
   reg [5:0] 	     rSTKPTR, rSTKPTR_;   
   reg [7:0] 	     rWREG, rWREG_;
   reg [7:0] 	     rBSR, rBSR_;
   reg [4:0] 	     rSTATUS_;
 
   // Control Word Registers
   reg [1:0] 	     rMXSRC, rMXTGT, rMXDST, rMXBSR, rMXSTK, rMXSHA;
   reg [2:0] 	     rMXSKP, rMXSTA, rMXNPC, rMXBCC;
   reg [3:0] 	     rMXALU, rMXFSR, rMXTBL;
   reg [15:0] 	     rEAPTR;

   // Control Path Registers
   reg 		     rCLRWDT, rRESET, rSLEEP;   
   reg 		     rNSKP, rBCC, rSFRSTB;
   reg [7:0] 	     rSFRDAT;
   

   // Control flags
    	     
   /*
    * DESCRIPTION
    * AE18 PLL generator.
    * Clock and reset generation using on chip DCM/PLL.
    */
  
   wire 	     clk = clk_i;
   wire 	     xrst = rst_i;
   wire 	     qrst = rRESET;   
   assign 	     wb_clk_o = clk_i;
   assign 	     wb_rst_o = ~rRESET;   

   // WDT
   reg [WSIZ:0]      rWDT;
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rWDT <= {(1+(WSIZ)){1'b0}};
	// End of automatics
     end else if (rCLRWDT|rSLEEP) begin
	$display("\tWDT cleared.");	
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rWDT <= {(1+(WSIZ)){1'b0}};
	// End of automatics
     end else if (rSWDTEN)
	rWDT <= #1 rWDT + 1;	

   // RAND
   reg [7:0] rPRNG;   
   always @(negedge clk or negedge xrst)
     if (!xrst)
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rPRNG <= 8'h0;
	// End of automatics
     else
       rPRNG <= #1 {rPRNG[6:0], ^{rPRNG[7],rPRNG[5:3]}};   
 	     
   /*
    * DESCRIPTION
    * AE18 MCU conductor.
    * Determines and generates the control signal for machine states.
    */
      
   reg [3:0] 	     rQCLK;
   reg [1:0] 	     rQCNT;
   reg [1:0] 	     rFSM, rNXT;
 
   //assign 	     qena_o = rQCLK;
   //assign 	     qfsm_o = rQCNT;
   //assign 	     qmod_o = rFSM;

   wire 	     xrun = !((iwb_stb_o ^ iwb_ack_i) | (dwb_stb_o ^ dwb_ack_i));
   wire 	     qrun = (rFSM != FSM_SLEEP);   
   wire [3:0] 	     qena = rQCLK;
   wire [1:0] 	     qfsm = rQCNT;   
      
   // Interrupt Debounce
   reg [2:0] 	     rINTH,rINTL;   
   wire 	     fINTH = (rINTH == 3'o3);
   wire 	     fINTL = (rINTL == 3'o3);   
   always @(negedge clk or negedge xrst)
     if (!xrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rINTH <= 3'h0;
	rINTL <= 3'h0;
	// End of automatics
     end else begin
	rINTH <= #1 {rINTH[1:0],int_i[1]};
	rINTL <= #1 {rINTL[1:0],int_i[0]};	
     end   
   
   // Control Wires
   wire 	     inth = fINTH;
   wire 	     isrh = inte_i[7] & fINTH;
   wire 	     intl = ~isrh & fINTL;
   wire 	     isrl = intl & inte_i[6];   

   // QCLK and QCNT sync
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	rQCLK <= 4'h8;
	rQCNT <= 2'h3;	
     end else if (xrun & qrun) begin
	rQCLK <= #1 {rQCLK[2:0],rQCLK[3]};
	rQCNT <= #1 rQCNT + 2'd1;	
     end

   // rINTF Latch
   reg [1:0] rINTF;   
   always @(negedge clk or negedge xrst)
     if (!xrst) begin
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       rINTF <= 2'h0;
       // End of automatics
     end else begin
	rINTF <= #1 (^rFSM) ? rFSM :
		 (qena[3]) ? 2'b00 :
		 rINTF;	
     end
   
   // FSM Sync
   always @(negedge clk or negedge qrst)
     if (!qrst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       rFSM <= 2'h0;
       // End of automatics
     else// if (qena[3])
       rFSM <= #1 rNXT;   

   // FSM Logic
   always @(/*AUTOSENSE*/inth or intl or isrh or isrl or rFSM
	    or rSLEEP)
     case (rFSM)
       //FSM_RESET: rNXT <= FSM_RUN;
       FSM_ISRH: rNXT <= FSM_RUN;
       FSM_ISRL: rNXT <= FSM_RUN;
       FSM_SLEEP: begin
	  if (inth) rNXT <= FSM_ISRH;
	  else if (intl) rNXT <= FSM_ISRL;
	  //else if (rWDT[WSIZ]) rNXT <= FSM_RUN;	  
	  else rNXT <= FSM_SLEEP;	  
       end
       default: begin
	  if (isrh) rNXT <= FSM_ISRH;
	  else if (isrl) rNXT <= FSM_ISRL;	  
	  else if (rSLEEP) rNXT <= FSM_SLEEP;	  
	  else rNXT <= FSM_RUN;	  
       end
     endcase // case(rFSM)

   
   /*
    * DESCRIPTION
    * Instruction WB logic
    */   
   
   // WB Registers
   reg [23:0]    rIWBADR;
   reg 		     rIWBSTB, rIWBWE;
   reg [1:0] 	     rIWBSEL;   
   //reg [15:0] 	     rIDAT;
     
   assign 	     iwb_adr_o = {rIWBADR,1'b0};
   assign 	     iwb_stb_o = rIWBSTB;
   assign 	     iwb_we_o = rIWBWE;
   assign 	     iwb_dat_o = {rTABLAT,rTABLAT};
   assign 	     iwb_sel_o = rIWBSEL;

   reg [15:0] 	     rIREG, rROMLAT;
   reg [7:0] 	     rILAT;
   
   reg [ISIZ-2:0]    rPCNXT;
   wire [ISIZ-2:0]   wPCLAT = {rPCU,rPCH,rPCL[7:1]};

   // FIXME: PCL writes do not affect PC
   
   // IWB ADDR signal
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       rIWBADR <= 24'h0;
       // End of automatics
     end else if (qrun)
       case (qfsm)
	 FSM_Q3: begin
	    case (rINTF)
	      FSM_ISRH: rIWBADR <= #1 23'h000004;
	      FSM_ISRL: rIWBADR <= #1 23'h00000C;    
	      default: rIWBADR <= #1 rPCNXT;	      
	    endcase // case(rINTF)
	 end
	 FSM_Q1: begin
	    rIWBADR <= #1 (rMXTBL == MXTBL_NOP) ? rIWBADR : {rTBLPTRU,rTBLPTRH,rTBLPTRL[7:1]};
	 end
       endcase // case(qfsm)

   // PC next calculation
   wire [ISIZ-2:0]   wPCINC = rIWBADR + 1;
   wire [ISIZ-2:0]   wPCBCC = (!rNSKP) ? wPCINC : 
		     (rBCC) ? rIWBADR + {{(ISIZ-8){rIREG[7]}},rIREG[7:0]} : wPCINC;      
   wire [ISIZ-2:0]   wPCNEAR = (!rNSKP) ? wPCINC : rIWBADR + {{(ISIZ-11){rIREG[10]}},rIREG[10:0]};      
   wire [ISIZ-2:0]   wPCFAR = (!rNSKP) ? wPCINC : {rROMLAT[11:0],rIREG[7:0]};   
   wire [ISIZ-2:0]   wPCSTK = (!rNSKP) ? wPCINC : {rTOSU, rTOSH, rTOSL[7:1]};

   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rPCNXT <= {(1+(ISIZ-2)){1'b0}};
	// End of automatics
     end else if (qena[1]) begin
	case (rMXNPC)
	  MXNPC_RET: rPCNXT <= #1 wPCSTK;
	  //MXNPC_RESET: rPCNXT <= #1 24'h00;
	  //MXNPC_PCL: rPCNXT <= #1 wPCLAT;	  
	  MXNPC_ISRH: rPCNXT <= #1 24'h08;
	  MXNPC_ISRL: rPCNXT <= #1 24'h18;	  
	  MXNPC_NEAR: rPCNXT <= #1 wPCNEAR;	  
	  MXNPC_FAR: rPCNXT <= #1 wPCFAR;
	  MXNPC_BCC: rPCNXT <= #1 wPCBCC;	  
	  default: rPCNXT <= #1 wPCINC;	  
	endcase // case(rMXNPC)
     end // if (qena[1])
      
   // ROMLAT + IREG
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rILAT <= 8'h0;
	rIREG <= 16'h0;
	rROMLAT <= 16'h0;
	// End of automatics
     end else if (qrun) begin
	case (qfsm)
	  FSM_Q0: rROMLAT <= #1 iwb_dat_i;
	  FSM_Q3: rIREG <= #1 rROMLAT;	     
	  FSM_Q2: rILAT <= (rTBLPTRL[0]) ? iwb_dat_i[7:0] : iwb_dat_i[15:8];	  
	endcase // case(qfsm)
     end

   // IWB STB signal
   wire wISTB = (rMXTBL != MXTBL_NOP);   
   always @(negedge clk or negedge qrst)
     if (!qrst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       rIWBSTB <= 1'h0;
       // End of automatics
     else if (qrun)
       case (qfsm)
	 FSM_Q3: rIWBSTB <= #1 1'b1;
	 FSM_Q1: rIWBSTB <= #1 wISTB & rNSKP;	 
	 default: rIWBSTB <= #1 1'b0;	   
       endcase // case(qfsm)
      
   // IWB WE signal
   wire wIWE = (rMXTBL == MXTBL_WT) | (rMXTBL == MXTBL_WTINC) | (rMXTBL == MXTBL_WTDEC) | (rMXTBL == MXTBL_WTPRE);   
   always @(negedge clk or negedge qrst)
     if (!qrst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       rIWBWE <= 1'h0;
       // End of automatics
     else if (qrun)
       case (qfsm)
	 FSM_Q1: rIWBWE <= #1 wIWE & rNSKP;	 
	 default: rIWBWE <= #1 1'b0;	 
       endcase // case(qfsm)
   
   // IWB SEL signal
   always @(negedge clk or negedge qrst)
     if (!qrst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       rIWBSEL <= 2'h0;
       // End of automatics
     else if (qrun)
       case (qfsm)
	 FSM_Q3: rIWBSEL <= #1 2'h3;	
	 FSM_Q1: rIWBSEL <= {rTBLPTRL[0],~rTBLPTRL[0]};
	 default: rIWBSEL <= #1 2'd0;
       endcase // case(qfsm)
   
   /*
    * DESCRIPTION
    * Instruction decode logic
    */
   
   wire [3:0] fOPCH = rROMLAT[15:12];
   wire [3:0] fOPCL = rROMLAT[11:8];
   wire [7:0] fOPCK = rROMLAT[7:0];

   // NIBBLE DECODER
   wire       fOPC0 = (fOPCH == 4'h0);
   wire       fOPC1 = (fOPCH == 4'h1);
   wire       fOPC2 = (fOPCH == 4'h2);
   wire       fOPC3 = (fOPCH == 4'h3);
   wire       fOPC4 = (fOPCH == 4'h4);
   wire       fOPC5 = (fOPCH == 4'h5);
   wire       fOPC6 = (fOPCH == 4'h6);
   wire       fOPC7 = (fOPCH == 4'h7);
   wire       fOPC8 = (fOPCH == 4'h8);
   wire       fOPC9 = (fOPCH == 4'h9);
   wire       fOPCA = (fOPCH == 4'hA);
   wire       fOPCB = (fOPCH == 4'hB);
   wire       fOPCC = (fOPCH == 4'hC);
   wire       fOPCD = (fOPCH == 4'hD);
   wire       fOPCE = (fOPCH == 4'hE);
   wire       fOPCF = (fOPCH == 4'hF);
   wire       fOP4G0 = (fOPCL == 4'h0);
   wire       fOP4G1 = (fOPCL == 4'h1);
   wire       fOP4G2 = (fOPCL == 4'h2);
   wire       fOP4G3 = (fOPCL == 4'h3);
   wire       fOP4G4 = (fOPCL == 4'h4);
   wire       fOP4G5 = (fOPCL == 4'h5);
   wire       fOP4G6 = (fOPCL == 4'h6);
   wire       fOP4G7 = (fOPCL == 4'h7);
   wire       fOP4G8 = (fOPCL == 4'h8);
   wire       fOP4G9 = (fOPCL == 4'h9);
   wire       fOP4GA = (fOPCL == 4'hA);
   wire       fOP4GB = (fOPCL == 4'hB);
   wire       fOP4GC = (fOPCL == 4'hC);
   wire       fOP4GD = (fOPCL == 4'hD);
   wire       fOP4GE = (fOPCL == 4'hE);
   wire       fOP4GF = (fOPCL == 4'hF);
   wire       fOP3G0 = (fOPCL[3:1] == 3'h0);
   wire       fOP3G1 = (fOPCL[3:1] == 3'h1);
   wire       fOP3G2 = (fOPCL[3:1] == 3'h2);
   wire       fOP3G3 = (fOPCL[3:1] == 3'h3);
   wire       fOP3G4 = (fOPCL[3:1] == 3'h4);
   wire       fOP3G5 = (fOPCL[3:1] == 3'h5);
   wire       fOP3G6 = (fOPCL[3:1] == 3'h6);
   wire       fOP3G7 = (fOPCL[3:1] == 3'h7); 
   wire       fOP2G0 = (fOPCL[3:2] == 2'h0);
   wire       fOP2G1 = (fOPCL[3:2] == 2'h1);
   wire       fOP2G2 = (fOPCL[3:2] == 2'h2);
   wire       fOP2G3 = (fOPCL[3:2] == 2'h3);
   wire       fOP1G0 = (fOPCL[3] == 1'b0);
   wire       fOP1G1 = (fOPCL[3] == 1'b1);
      
   // GROUP F
   wire       fNOPF = fOPCF;
   // GROUP E
   wire       fBZ = fOPCE & fOP4G0;
   wire       fBNZ = fOPCE & fOP4G1;
   wire       fBC = fOPCE & fOP4G2;
   wire       fBNC = fOPCE & fOP4G3;
   wire       fBOV = fOPCE & fOP4G4;
   wire       fBNOV = fOPCE & fOP4G5;
   wire       fBN = fOPCE & fOP4G6;
   wire       fBNN = fOPCE & fOP4G7;
   wire       fCALL = fOPCE & fOP3G6;
   wire       fLFSR = fOPCE & fOP4GE;
   wire       fGOTO = fOPCE & fOP4GF;
   // GROUP D
   wire       fBRA = fOPCD & fOP1G0;
   wire       fRCALL = fOPCD & fOP1G1;
   // GROUP C
   wire       fMOVFF = fOPCC;
   // GROUP B/A/9/8/7
   wire       fBTFSC = fOPCB;
   wire       fBTFSS = fOPCA;
   wire       fBCF = fOPC9;
   wire       fBSF = fOPC8;
   wire       fBTG = fOPC7;
   // GROUP 6
   wire       fCPFSLT = fOPC6 & fOP3G0;
   wire       fCPFSEQ = fOPC6 & fOP3G1;
   wire       fCPFSGT = fOPC6 & fOP3G2;
   wire       fTSTFSZ = fOPC6 & fOP3G3;
   wire       fSETF = fOPC6 & fOP3G4;
   wire       fCLRF = fOPC6 & fOP3G5;
   wire       fNEGF = fOPC6 & fOP3G6;
   wire       fMOVWF = fOPC6 & fOP3G7;
   // GROUP 5
   wire       fMOVF = fOPC5 & fOP2G0;
   wire       fSUBFWB = fOPC5 & fOP2G1;
   wire       fSUBWFB = fOPC5 & fOP2G2;
   wire       fSUBWF = fOPC5 & fOP2G3;
   // GROUP 4
   wire       fRRNCF = fOPC4 & fOP2G0;
   wire       fRLNCF = fOPC4 & fOP2G1;
   wire       fINFSNZ = fOPC4 & fOP2G2;
   wire       fDCFSNZ = fOPC4 & fOP2G3;
   // GROUP 3
   wire       fRRCF = fOPC3 & fOP2G0;
   wire       fRLCF = fOPC3 & fOP2G1;
   wire       fSWAPF = fOPC3 & fOP2G2;
   wire       fINCFSZ = fOPC3 & fOP2G3;
   // GROUP 2
   wire       fADDWFC = fOPC2 & fOP2G0;
   wire       fADDWF = fOPC2 & fOP2G1;
   wire       fINCF = fOPC2 & fOP2G2;
   wire       fDECFSZ = fOPC2 & fOP2G3;
   // GROUP 1
   wire       fIORWF = fOPC1 & fOP2G0;
   wire       fANDWF = fOPC1 & fOP2G1;
   wire       fXORWF = fOPC1 & fOP2G2;
   wire       fCOMF = fOPC1 & fOP2G3;
   // GROUP 0
   wire       fMISC = fOPC0 & fOP4G0;
   wire       fMOVLB = fOPC0 & fOP4G1;
   wire       fMULWF = fOPC0 & fOP3G1;
   wire       fDECF = fOPC0 & fOP2G1;
   wire       fSUBLW = fOPC0 & fOP4G8;
   wire       fIORLW = fOPC0 & fOP4G9;
   wire       fXORLW = fOPC0 & fOP4GA;
   wire       fANDLW = fOPC0 & fOP4GB;
   wire       fRETLW = fOPC0 & fOP4GC;
   wire       fMULLW = fOPC0 & fOP4GD;
   wire       fMOVLW = fOPC0 & fOP4GE;
   wire       fADDLW = fOPC0 & fOP4GF;
   // GROUP MISC
   wire       fNOP0 = fMISC & (fOPCK == 8'h00);
   wire       fRESET = fMISC & (fOPCK == 8'hFF);
   wire       fSLEEP = fMISC & (fOPCK == 8'h03);
   wire       fCLRWDT = fMISC & (fOPCK == 8'h04);
   wire       fPUSH = fMISC & (fOPCK == 8'h05);
   wire       fPOP = fMISC & (fOPCK == 8'h06);
   wire       fDAW = fMISC & (fOPCK == 8'h07);
   wire       fRETFIE = fMISC & (fOPCK == 8'h10 | fOPCK == 8'h11);
   wire       fRETURN = fMISC & (fOPCK == 8'h12 | fOPCK == 8'h13);
   wire       fNOP = fNOP0 | fNOPF;
   wire       fTBLRDWT = fMISC & (fOPCK[7:3] == 5'h01);   

   // MX INT
   wire       fINT = ^rINTF;
   
   // MX_SRC
   wire [1:0] 	  wMXSRC =                  		
		  (fMOVLW|fRETLW|fCOMF|
		   fDECF|fDECFSZ|fDCFSNZ|
		   fINCF|fINCFSZ|fINFSNZ|
		   fMOVF|fMOVFF|fMOVWF|
		   fSETF|fTSTFSZ) ? MXSRC_LIT :
		  (fBSF|fBTG|fBTFSC|fBTFSS) ? MXSRC_MASK :	
		  (fBCF|fCPFSLT|fSUBFWB) ? MXSRC_FILE : 
		  MXSRC_WREG;
   
   // MX_TGT
   wire [1:0] 	  wMXTGT = 
		  (fBCF) ? MXTGT_MASK :
		  (fRETLW|fMOVLW|
		   fMULLW|
		   fADDLW|fSUBLW|
		   fANDLW|fXORLW|fIORLW) ? MXTGT_LIT :
		  (fBSF|fBTFSC|fBTFSS|fBTG|
		   fADDWF|fADDWFC|fSUBWF|fSUBWFB|fMULWF|
		   fMULWF|fSWAPF|
		   fANDWF|fIORWF|fXORWF|
		   fCOMF|fMOVF|fMOVFF|
		   fCPFSEQ|fCPFSGT|fNEGF|
		   fDECF|fDECFSZ|fDCFSNZ|
		   fINCF|fINCFSZ|fINFSNZ|
		   fRLCF|fRLNCF|fRRCF|fRRNCF|
		   fTSTFSZ) ? MXTGT_FILE :
		  MXTGT_WREG;
	  
   // MX_DST
   wire [1:0] 	  wMXDST =
		  (fMULWF|fMULLW|fMOVLB|fLFSR|fDAW) ? MXDST_EXT :
	      	  (fBCF|fBSF|fBTG|
		   fCLRF|
		   fMOVFF|fMOVWF|
		   fNEGF|fSETF) ? MXDST_FILE :
		  (fADDLW|fSUBLW|
		   fANDLW|fIORLW|fXORLW|
		   fMOVLW|fRETLW) ? MXDST_WREG :
		  (fADDWF|fADDWFC|
		   fANDWF|fIORWF|fXORWF|
		   fMOVF|fSWAPF|fCOMF|
		   fSUBFWB|fSUBWF|fSUBWFB|
		   fDECF|fDECFSZ|fDCFSNZ|
		   fINCF|fINCFSZ|fINFSNZ|
		   fRLCF|fRLNCF|fRRCF|fRRNCF) ? {1'b1,fOPCL[1]} :		 
		  MXDST_NULL;

   // MX_ALU
   wire [3:0] 	  wMXALU =
		  (fDAW) ? MXALU_DAW :
		  (fMOVLB) ? MXALU_MOVLB :
		  (fLFSR) ? MXALU_LFSR :
		  (fMULLW|fMULWF) ? MXALU_MUL :
		  (fNEGF) ? MXALU_NEG :
		  (fADDLW|fADDWF|
		   fDECF|fDECFSZ|fDCFSNZ) ? MXALU_ADD :
		  (fSUBLW|fSUBWF|
		   fCPFSEQ|fCPFSGT|fCPFSLT|
		   fINCF|fINCFSZ|fINFSNZ) ? MXALU_SUB :
		  (fSUBWFB|fSUBFWB) ? MXALU_SUBC :
		  (fADDWFC) ? MXALU_ADDC :
		  (fRRCF) ? MXALU_RRC :
		  (fRRNCF) ? MXALU_RRNC :
		  (fRLCF) ? MXALU_RLC :
		  (fRLNCF) ? MXALU_RLNC :
		  (fSWAPF) ? MXALU_SWAP :
		  (fSETF|fIORWF|fIORLW|fBSF) ? MXALU_IOR :
		  (fBCF|fANDWF|fANDLW|
		   fRETLW|fBTFSS|fBTFSC|fTSTFSZ|
		   fMOVF|fMOVFF|fMOVWF|fMOVLW) ? MXALU_AND :
		  MXALU_XOR;

   // MX_BSR   
   wire [1:0] 	  wMXBSR =
		  (fMOVFF) ? MXBSR_LIT :
		  (fBCF|fBSF|fBTG|fBTFSS|fBTFSC|
		   fANDWF|fIORWF|fXORWF|fCOMF|
		   fADDWF|fADDWFC|fSUBWF|fSUBWFB|fSUBFWB|fMULWF|
		   fCLRF|fMOVF|fMOVWF|fSETF|fSWAPF|
		   fCPFSEQ|fCPFSGT|fCPFSLT|fTSTFSZ|
		   fINCF|fINCFSZ|fINFSNZ|fDECF|fDECFSZ|fDCFSNZ|
		   fRLCF|fRLNCF|fRRCF|fRRNCF) ? {1'b1, fOPCL[0]} :	       
		  MXBSR_NUL;   

   // MX_SKP
   wire [2:0] 	  wMXSKP =
		  (fTSTFSZ|fINCFSZ|fDECFSZ|fCPFSEQ|fBTFSC) ? MXSKP_SZ :
		  (fINFSNZ|fDCFSNZ|fBTFSS) ? MXSKP_SNZ :
		  (fCPFSGT|fCPFSLT) ? MXSKP_SNC :
		  (fBC|fBNC|fBZ|fBNZ|fBN|fBNN|fBOV|fBNOV) ? MXSKP_SCC :
		  (fBRA|fCALL|fRCALL|fGOTO|fRETFIE|fRETURN|fRETLW) ? MXSKP_SU :
		  MXSKP_NON;

   // NPC_MX
   wire [2:0] 	  wMXNPC =
		  (fBC|fBNC|fBN|fBNN|fBOV|fBNOV|fBZ|fBNZ) ? MXNPC_BCC :
		  (fBRA|fRCALL) ? MXNPC_NEAR :
		  (fCALL|fGOTO) ? MXNPC_FAR :
		  (fRETFIE|fRETURN|fRETLW) ? MXNPC_RET :
		  MXNPC_INC;

   // MX_STA
   wire [2:0] 	  wMXSTA =
		  (fADDLW|fADDWF|fADDWFC|
		   fSUBLW|fSUBWF|fSUBWFB|fSUBFWB|
		   fDECF|fINCF|fNEGF) ? MXSTA_ALL :
		  (fRRCF|fRLCF) ? MXSTA_CZN :
		  (fRRNCF|fRLNCF|
		   fMOVF|fCOMF|
		   fIORWF|fANDWF|fXORWF|fIORLW|fANDLW|fXORLW) ? MXSTA_ZN :
		  (fDAW) ? MXSTA_C :
		  (fCLRF) ? MXSTA_Z :		   
		  MXSTA_NONE;
   
   // BCC_MX
   wire [2:0] 	  wMXBCC = fOPCL[2:0];
   
   // STK_MX
   wire [1:0] 	  wMXSTK =
		  (fRETFIE|fRETLW|fRETURN|fPOP) ? MXSTK_POP :
		  (fCALL|fRCALL|fPUSH|fINT) ? MXSTK_PUSH :
		  MXSTK_NONE;

   // SHADOW MX
   wire [1:0] 	  wMXSHA =
		  (fCALL) ? {fOPCL[0] ,1'b0} :
		  (fINT) ? {MXSHA_CALL} :
		  (fRETURN|fRETFIE) ? {1'b0,fOPCK[0]} :
		  1'b0;   

   // TBLRD/TBLWT MX
   wire [3:0] 	  wMXTBL = 
		  (fTBLRDWT) ? fOPCK[3:0] :
		  MXTBL_NOP;   
		  
   // FSR DECODER   
   parameter [15:0]
		aPLUSW2 = 16'hFFDB,
		aPREINC2 = 16'hFFDC,
		aPOSTDEC2 = 16'hFFDD,
		aPOSTINC2 = 16'hFFDE,
		aINDF2 = 16'hFFDF,
		aPLUSW1 = 16'hFFE3,
		aPREINC1 = 16'hFFE4,
		aPOSTDEC1 = 16'hFFE5,
		aPOSTINC1 = 16'hFFE6,
		aINDF1 = 16'hFFE7,
		aPLUSW0 = 16'hFFEB,
		aPREINC0 = 16'hFFEC,
		aPOSTDEC0 = 16'hFFED,
		aPOSTINC0 = 16'hFFEE,
		aINDF0 = 16'hFFEF;   

   wire 	   fGFF = (rEAPTR[15:6] == 10'h03F) | (rEAPTR[15:6] == 10'h3FF);
   wire 	   fGFSR0 = (rEAPTR[5:3] == 3'o5);
   wire 	   fGFSR1 = (rEAPTR[5:3] == 3'o4);
   wire 	   fGFSR2 = (rEAPTR[5:3] == 3'o3);
   wire 	   fGPLUSW = (rEAPTR[2:0] == 3'o3);
   wire 	   fGPREINC = (rEAPTR[2:0] == 3'o4);
   wire 	   fGPOSTDEC = (rEAPTR[2:0] == 3'o5);
   wire 	   fGPOSTINC = (rEAPTR[2:0] == 3'o6);
   wire 	   fGINDF = (rEAPTR[2:0] == 3'o7);     
   
   wire 	   fPLUSW2 = fGFF & fGFSR2 & fGPLUSW;
   wire 	   fPREINC2 = fGFF & fGFSR2 & fGPREINC;
   wire 	   fPOSTDEC2 = fGFF & fGFSR2 & fGPOSTDEC;
   wire 	   fPOSTINC2 = fGFF & fGFSR2 & fGPOSTINC;
   wire 	   fINDF2 = fGFF & fGFSR2 & fGINDF;   
   wire 	   fPLUSW1 = fGFF & fGFSR1 & fGPLUSW;
   wire 	   fPREINC1 = fGFF & fGFSR1 & fGPREINC;
   wire 	   fPOSTDEC1 = fGFF & fGFSR1 & fGPOSTDEC;
   wire 	   fPOSTINC1 = fGFF & fGFSR1 & fGPOSTINC;
   wire 	   fINDF1 = fGFF & fGFSR1 & fGINDF;   
   wire 	   fPLUSW0 = fGFF & fGFSR0 & fGPLUSW;
   wire 	   fPREINC0 = fGFF & fGFSR0 & fGPREINC;
   wire 	   fPOSTDEC0 = fGFF & fGFSR0 & fGPOSTDEC;
   wire 	   fPOSTINC0 = fGFF & fGFSR0 & fGPOSTINC;
   wire 	   fINDF0 = fGFF & fGFSR0 & fGINDF;   
   
   parameter [3:0]
		MXFSR_INDF2 = 4'hF,
		MXFSR_POSTINC2 = 4'hE,
		MXFSR_POSTDEC2 = 4'hD,
		MXFSR_PREINC2 = 4'hC,
		MXFSR_PLUSW2 = 4'hB,
		MXFSR_INDF1 = 4'hA,
		MXFSR_POSTINC1 = 4'h9,
		MXFSR_POSTDEC1 = 4'h8,
		MXFSR_PREINC1 = 4'h7,
		MXFSR_PLUSW1 = 4'h6,
		MXFSR_INDF0 = 4'h5,
		MXFSR_POSTINC0 = 4'h4,
		MXFSR_POSTDEC0 = 4'h3,
		MXFSR_PREINC0 = 4'h2,
		MXFSR_PLUSW0 = 4'h1,
		MXFSR_NORM = 4'h0;   

   wire [3:0] wMXFSR =
	      (fINDF0) ? MXFSR_INDF0 :
	      (fPLUSW0) ? MXFSR_PLUSW0 :
	      (fPREINC0) ? MXFSR_PREINC0 :
	      (fPOSTINC0) ? MXFSR_POSTINC0 :
	      (fPOSTDEC0) ? MXFSR_POSTDEC0 :
	      (fINDF1) ? MXFSR_INDF1 :
	      (fPLUSW1) ? MXFSR_PLUSW1 :
	      (fPREINC1) ? MXFSR_PREINC1 :
	      (fPOSTINC1) ? MXFSR_POSTINC1 :
	      (fPOSTDEC1) ? MXFSR_POSTDEC1 :
	      (fINDF2) ? MXFSR_INDF2 :
	      (fPLUSW2) ? MXFSR_PLUSW2 :
	      (fPREINC2) ? MXFSR_PREINC2 :
	      (fPOSTINC2) ? MXFSR_POSTINC2 :
	      (fPOSTDEC2) ? MXFSR_POSTDEC2 :
	      MXFSR_NORM;

   always @(negedge clk or negedge qrst)
     if (!qrst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       rMXBSR <= 2'h0;
       // End of automatics
     else if (qena[1])
       rMXBSR <= #1 wMXBSR;

   // Control Word
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rMXALU <= 4'h0;
	rMXBCC <= 3'h0;
	rMXDST <= 2'h0;
	rMXFSR <= 4'h0;
	rMXNPC <= 3'h0;
	rMXSHA <= 2'h0;
	rMXSKP <= 3'h0;
	rMXSRC <= 2'h0;
	rMXSTA <= 3'h0;
	rMXSTK <= 2'h0;
	rMXTBL <= 4'h0;
	rMXTGT <= 2'h0;
	// End of automatics
     end else if (qena[3]) begin // if (!qrst)
	rMXTGT <= #1 wMXTGT;
	rMXSRC <= #1 wMXSRC;
	rMXALU <= #1 wMXALU;
	rMXNPC <= #1 wMXNPC;	
	rMXDST <= #1 wMXDST;
	rMXSTA <= #1 wMXSTA;	
	rMXSKP <= #1 wMXSKP;
	rMXBCC <= #1 wMXBCC;
	rMXSTK <= #1 wMXSTK;
	rMXFSR <= #1 wMXFSR;
	rMXSHA <= #1 wMXSHA;
	rMXTBL <= #1 wMXTBL;	
     end // if (qena[3])

   /*
    * DESCRIPTION
    * EA pre calculation
    */
   
   wire [15:0]   wFILEBSR = {rBSR, rROMLAT[7:0]};
   wire [15:0]   wFILEBSA = { {(8){rROMLAT[7]}}, rROMLAT[7:0]};
   wire [15:0]   wFILELIT = {rBSR[7:4],rROMLAT[11:0]};   
   //wire [DSIZ-1:0]   wFILEBSR = {rBSR, rROMLAT[7:0]};
   //wire [DSIZ-1:0]   wFILEBSA = { {(8){rROMLAT[7]}}, rROMLAT[7:0]};
   //wire [DSIZ-1:0]   wFILELIT = {rROMLAT[11:0]};   
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rEAPTR <= 16'h0;
	// End of automatics
     end else if (qena[2]) begin
       case (rMXBSR)
	 MXBSR_BSR: rEAPTR <= #1 wFILEBSR;
	 MXBSR_BSA: rEAPTR <= #1 wFILEBSA;
	 MXBSR_LIT: rEAPTR <= #1 wFILELIT;
	 default: rEAPTR <= #1 rEAPTR;	      
       endcase // case(rMXBSR)
     end
   
   /*
    * DESCRIPTION
    * Arithmetic Shift Logic Unit
    */
     
   // BITMASK
   reg [7:0] 	  rMASK;
   wire [7:0] 	  wMASK = 
		  (fOP3G0) ? 8'h01 :		 
		  (fOP3G1) ? 8'h02 :		 
		  (fOP3G2) ? 8'h04 :		 
		  (fOP3G3) ? 8'h08 :		 
		  (fOP3G4) ? 8'h10 :		 
		  (fOP3G5) ? 8'h20 :		 
		  (fOP3G6) ? 8'h40 :
		  8'h80;      
   always @(negedge clk or negedge qrst)
     if (!qrst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       rMASK <= 8'h0;
       // End of automatics
     else if (qena[2] & rNSKP)
       rMASK <= #1 wMASK;
   
   
   // SRC and TGT
   reg [7:0] 	     rSRC, rTGT;   
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rSRC <= 8'h0;
	rTGT <= 8'h0;
	// End of automatics
     end else if (qena[1] & rNSKP) begin
	case (rMXSRC)
	  MXSRC_FILE: rSRC <= #1 (rSFRSTB) ? rSFRDAT : dwb_dat_i;
	  //MXSRC_FILE: rSRC <= #1 dwb_dat_i;
	  MXSRC_MASK: rSRC <= #1 rMASK;	  
	  MXSRC_LIT: rSRC <= #1 8'hFF;	  
	  default: rSRC <= #1 rWREG;	  
	endcase // case(rMXSRC)

	case (rMXTGT)
	  MXTGT_MASK: rTGT <= #1 ~rMASK;
	  MXTGT_FILE: rTGT <= #1 (rSFRSTB) ? rSFRDAT : dwb_dat_i;
	  //MXTGT_FILE: rTGT <= #1 dwb_dat_i;
	  MXTGT_LIT: rTGT <= #1 rIREG[7:0];	  
	  default: rTGT <= #1 rWREG;	  
	endcase // case(rMXTGT)
     end // if (qena[1] & rNSKP)
   
   // ALU Operations
   wire [8:0] 	  wADD = (rSRC + rTGT);
   wire [8:0] 	  wADDC = wADD + rC;
   wire [8:0] 	  wSUB = (rTGT - rSRC);
   wire [8:0] 	  wSUBC = wSUB - ~rC;   

   wire [8:0] 	  wNEG = (0 - rTGT);   
   
   wire [8:0] 	  wRRC = {rTGT[0],rC,rTGT[7:1]};
   wire [8:0] 	  wRLC = {rTGT[7:0],rC};
   wire [8:0] 	  wRRNC = {1'b0,rTGT[0],rTGT[7:1]};
   wire [8:0] 	  wRLNC = {1'b0,rTGT[6:0],rTGT[7]};

   wire [8:0] 	  wAND = {1'b0, rSRC & rTGT};
   wire [8:0] 	  wIOR = {1'b0, rSRC | rTGT};
   wire [8:0] 	  wXOR = {1'b0, rSRC ^ rTGT};
   wire [8:0] 	  wSWAP = {1'b0, rTGT[3:0], rTGT[7:4]};
   
   // RESULT register
   reg [7:0] 	  rRESULT;	  
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rRESULT <= 8'h0;
	// End of automatics
     end else if (qena[2] & rNSKP) begin
	case (rMXALU)
	  default: rRESULT <= #1 wXOR;
	  MXALU_AND: rRESULT <= #1 wAND;
	  MXALU_IOR: rRESULT <= #1 wIOR;
	  MXALU_SWAP: rRESULT <= #1 wSWAP;
	  MXALU_RRC: rRESULT <= #1 wRRC;
	  MXALU_RLC: rRESULT <= #1 wRLC;
	  MXALU_RRNC: rRESULT <= #1 wRRNC;
	  MXALU_RLNC: rRESULT <= #1 wRLNC;
	  MXALU_ADD: rRESULT <= #1 wADD;
	  MXALU_ADDC: rRESULT <= #1 wADDC;
	  MXALU_SUB: rRESULT <= #1 wSUB;
	  MXALU_SUBC: rRESULT <= #1 wSUBC;
	  MXALU_NEG: rRESULT <= #1 wNEG;	  
	endcase // case(rMXALU)
     end // if (qena[2] & rNSKP)

   // C register
   reg rC_;
   always @(negedge clk or negedge qrst)
     if (!qrst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       rC_ <= 1'h0;
       // End of automatics
     else if (qena[2] & rNSKP)
       case (rMXALU)
	 MXALU_ADD: rC_ <= #1 wADD[8];
	 MXALU_ADDC: rC_ <= #1 wADDC[8];
	 MXALU_SUB: rC_ <= #1 ~wSUB[8];
	 MXALU_SUBC: rC_ <= #1 ~wSUBC[8];
	 MXALU_RRC: rC_ <= #1 wRRC[8];
	 MXALU_RLC: rC_ <= #1 wRLC[8];	
	 MXALU_NEG: rC_ <= #1 wNEG[8];	 
	 default: rC_ <= #1 rC;	 
       endcase // case(rMXALU)
   	  
   wire 	  wC, wZ, wN, wOV, wDC;
   assign 	  wN = rRESULT[7];
   assign 	  wOV = ~(rSRC[7] ^ rTGT[7]) & (rRESULT[7] ^ rSRC[7]);
   assign 	  wZ = (rRESULT[7:0] == 8'h00);
   assign 	  wDC = rRESULT[4];   
   assign 	  wC = rC_;
   
   /*
    * DESCRIPTION
    * Other Execution Units
    */
   
   // SPECIAL OPERATION
   reg rCLRWDT_, rSLEEP_;   
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rCLRWDT <= 1'h0;
	rCLRWDT_ <= 1'h0;
	rSLEEP <= 1'h0;
	rSLEEP_ <= 1'h0;
	// End of automatics
     end else begin
	//rCLRWDT <= #1 (rCLRWDT_ & rNSKP);
	//rSLEEP <= #1 (rSLEEP_ & rNSKP);
	rCLRWDT <= #1 (rCLRWDT_ & rNSKP & qena[3]);
	rSLEEP <= #1 (rSLEEP_ & rNSKP & qena[3]);
	
	rCLRWDT_ <= #1 (qena[3]) ? fCLRWDT : rCLRWDT_;
	rSLEEP_ <= #1 (qena[3]) ? fSLEEP : rSLEEP_;
     end

   reg rRESET_;   
   always @(negedge clk or negedge xrst)
     if (!xrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rRESET <= 1'h0;
	rRESET_ <= 1'h0;
	// End of automatics
     end else begin
	rRESET_ <= #1 ~(fRESET | rWDT[WSIZ]);	
	rRESET <= #1 rRESET_;
     end
   
   // BCC Checker
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rBCC <= 1'h0;
	// End of automatics
     end else if (qena[0]) begin
	case (rMXBCC)
	  MXBCC_BZ: rBCC <= #1 rZ;
	  MXBCC_BNZ: rBCC <= #1 ~rZ;
	  MXBCC_BC: rBCC <= #1 rC;
	  MXBCC_BNC: rBCC <= #1 ~rC;
	  MXBCC_BOV: rBCC <= #1 rOV;
	  MXBCC_BNOV: rBCC <= #1 ~rOV;
	  MXBCC_BN: rBCC <= #1 rN;
	  MXBCC_BNN: rBCC <= #1 ~rN;	  
	endcase // case(rMXBCC)	
     end  
 
   /*
    * DESCRIPTION
    * Data WB logic
    */
   
   reg [15:0] 	   rDWBADR;
   reg 		   rDWBSTB, rDWBWE;
   
   assign 	   dwb_adr_o = rDWBADR;
   assign 	   dwb_stb_o = rDWBSTB;
   assign 	   dwb_we_o = rDWBWE;
   assign 	   dwb_dat_o = rRESULT;
  
   // DWB ADR signal
   wire [DSIZ-1:0] wFSRINC0 = {rFSR0H,rFSR0L} + 1;
   wire [DSIZ-1:0] wFSRINC1 = {rFSR1H,rFSR1L} + 1;
   wire [DSIZ-1:0] wFSRINC2 = {rFSR2H,rFSR2L} + 1;
   wire [DSIZ-1:0] wFSRPLUSW0 = {rFSR0H,rFSR0L} + rWREG;
   wire [DSIZ-1:0] wFSRPLUSW1 = {rFSR1H,rFSR1L} + rWREG;
   wire [DSIZ-1:0] wFSRPLUSW2 = {rFSR2H,rFSR2L} + rWREG;
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rDWBADR <= 16'h0;
	// End of automatics
     end else if (qrun & rNSKP)
       case (qfsm)
	 FSM_Q0:
	   case (rMXFSR)
	     MXFSR_INDF0,MXFSR_POSTINC0,MXFSR_POSTDEC0: rDWBADR <= #1 {rFSR0H,rFSR0L};
	     MXFSR_INDF1,MXFSR_POSTINC1,MXFSR_POSTDEC1: rDWBADR <= #1 {rFSR1H,rFSR1L};
	     MXFSR_INDF2,MXFSR_POSTINC2,MXFSR_POSTDEC2: rDWBADR <= #1 {rFSR2H,rFSR2L};
	     MXFSR_PREINC0: rDWBADR <= #1 wFSRINC0;
	     MXFSR_PREINC1: rDWBADR <= #1 wFSRINC1;
	     MXFSR_PREINC2: rDWBADR <= #1 wFSRINC2;
	     MXFSR_PLUSW2: rDWBADR <= #1 wFSRPLUSW2;
	     MXFSR_PLUSW1: rDWBADR <= #1 wFSRPLUSW1;
	     MXFSR_PLUSW0: rDWBADR <= #1 wFSRPLUSW0;	     	     
	     default: rDWBADR <= #1 rEAPTR;	     
	   endcase // case(rMXFSR)	 
	 FSM_Q1: rDWBADR <= #1 (rMXBSR == MXBSR_LIT) ? {rROMLAT[11:0]} : rDWBADR;
	 default: rDWBADR <= #1 rDWBADR;	 
       endcase // case(qfsm)

   // DWB WE signal
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rDWBWE <= 1'h0;
	// End of automatics
     end else if (qrun & rNSKP)
       case (qfsm)
	 FSM_Q2: rDWBWE <= #1 (rMXDST == MXDST_FILE);
	 default: rDWBWE <= #1 1'b0;	 
       endcase // case(qfsm)

   // DWB STB signal
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rDWBSTB <= 1'h0;
	// End of automatics
     end else if (qrun & rNSKP)
       case (qfsm)
	 FSM_Q2: rDWBSTB <= #1 (rMXDST == MXDST_FILE);
	 FSM_Q0: rDWBSTB <= #1 ((rMXSRC == MXSRC_FILE) | (rMXTGT == MXTGT_FILE));
	 default: rDWBSTB <= #1 1'b0;	 
       endcase // case(qfsm)

   // STACK
   wire [ISIZ-1:0] wSTKW = {rTOSU,rTOSH,rTOSL};
   wire [ISIZ-1:0] wSTKR;
   wire 	   wSTKE = (qena[1]);

   reg [ISIZ-1:0]  rSTKRAM [0:31];
   
   assign 	   wSTKR = rSTKRAM[rSTKPTR[4:0]];   
   always @(posedge clk)
     if (wSTKE) 
       rSTKRAM[rSTKPTR_[4:0]] <= wSTKW;

   /*
    * SFR Bank
    */
   parameter [15:0]
		//aRCON = 16'hFFD0,
		aWDTCON = 16'hFFD1,
		aSTATUS = 16'hFFD8,//
		aFSR2L = 16'hFFD9,//
		aFSR2H = 16'hFFDA,//
		aBSR = 16'hFFE0,//
		aFSR1L = 16'hFFE1,//
		aFSR1H = 16'hFFE2,//
		aWREG = 16'hFFE8,//
		aFSR0L = 16'hFFE9,//
		aFSR0H = 16'hFFEA,//
		aPRODL = 16'hFFF3,//
		aPRODH = 16'hFFF4,//
		aPRNG = 16'hFFD4,//
		aTABLAT = 16'hFFF5,//
		aTBLPTRL = 16'hFFF6,//
		aTBLPTRH = 16'hFFF7,//
		aTBLPTRU = 16'hFFF8,//
		aPCL = 16'hFFF9,//
		aPCLATH = 16'hFFFA,//
		aPCLATU = 16'hFFFB,//
		aSTKPTR = 16'hFFFC,//
		aTOSL = 16'hFFFD,//
		aTOSH = 16'hFFFE,//
		aTOSU = 16'hFFFF;//   

   // Read SFR
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rSFRDAT <= 8'h0;
	// End of automatics
     end else if (rDWBSTB & rNSKP) begin
	case (rDWBADR[5:0])
	  aWDTCON[5:0]: rSFRDAT <= #1 {7'd0,rSWDTEN};
	  aSTATUS[5:0]: rSFRDAT <= #1 {3'd0,rN,rOV,rZ,rDC,rC};
	  aFSR2L[5:0]: rSFRDAT <= #1 rFSR2L;
	  aFSR2H[5:0]: rSFRDAT <= #1 rFSR2H;
	  aBSR[5:0]: rSFRDAT <= #1 rBSR;
	  aFSR1L[5:0]: rSFRDAT <= #1 rFSR1L;
	  aFSR1H[5:0]: rSFRDAT <= #1 rFSR1H;
	  aWREG[5:0]: rSFRDAT <= #1 rWREG;
	  aFSR0L[5:0]: rSFRDAT <= #1 rFSR0L;
	  aFSR0H[5:0]: rSFRDAT <= #1 rFSR0H;
	  aPRODL[5:0]: rSFRDAT <= #1 rPRODL;
	  aPRODH[5:0]: rSFRDAT <= #1 rPRODH;
	  aPRNG[5:0]: rSFRDAT <= #1 rPRNG;	  
	  aTABLAT[5:0]: rSFRDAT <= #1 rTABLAT;
	  aTBLPTRL[5:0]: rSFRDAT <= #1 rTBLPTRL;
	  aTBLPTRH[5:0]: rSFRDAT <= #1 rTBLPTRH;
	  aTBLPTRU[5:0]: rSFRDAT <= #1 rTBLPTRU;
	  aPCL[5:0]: rSFRDAT <= #1 rPCL;
	  aPCLATH[5:0]: rSFRDAT <= #1 rPCLATH;
	  aPCLATU[5:0]: rSFRDAT <= #1 rPCLATU;
	  aSTKPTR[5:0]: rSFRDAT <= #1 {rSTKFUL,rSTKUNF,1'b0,rSTKPTR[4:0]};
	  aTOSU[5:0]: rSFRDAT <= #1 rTOSU;
	  aTOSH[5:0]: rSFRDAT <= #1 rTOSH;
	  aTOSL[5:0]: rSFRDAT <= #1 rTOSL;
	  default rSFRDAT <= #1 rSFRDAT;	  
	endcase // case(rDWBADR)
     end   

   wire wSFRSTB = (rDWBADR[15:6] == 10'h3FF);   
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	// Beginning of autoreset for uninitialized flops
	rSFRSTB <= 1'h0;
	// End of automatics
     end else if (rDWBSTB & rNSKP) begin
	case (rDWBADR[5:0])
	  aFSR2L[5:0],aFSR2H[5:0],aFSR1L[5:0],aFSR1H[5:0],aFSR0H[5:0],aFSR0L[5:0],
	    aWDTCON[5:0],aBSR[5:0],aWREG[5:0],aSTATUS[5:0],
	    aPRODL[5:0],aPRODH[5:0],aPRNG[5:0],
	    aTABLAT[5:0],aTBLPTRH[5:0],aTBLPTRU[5:0],aTBLPTRL[5:0],
	    aPCL[5:0],aPCLATH[5:0],aPCLATU[5:0],
	    aSTKPTR[5:0],aTOSU[5:0],aTOSH[5:0],aTOSL[5:0]: rSFRSTB <= #1 wSFRSTB;
	  default rSFRSTB <= #1 1'b0;	  
	endcase // case(rDWBADR)	
     end          
   
   // WDTCON
   always @(posedge clk or negedge qrst)
     if (!qrst)
       rSWDTEN <= 1;
     else if (qena[3] & rNSKP)
       rSWDTEN <= #1 ((rDWBADR == aWDTCON) & rDWBWE) ? rRESULT[0] : rSWDTEN;   
   
   // TOSH, TOSU, TOSL, STKPTR
   wire [5:0]   wSTKINC = rSTKPTR + 1;
   wire [5:0]   wSTKDEC = rSTKPTR - 1;
   
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rSTKPTR_ <= 6'h0;
	// End of automatics
     end else if (qena[0]) begin
       rSTKPTR_ <= #1 wSTKINC;
     end
      
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rSTKFUL <= 1'h0;
	rSTKPTR <= 6'h0;
	rSTKUNF <= 1'h0;
	// End of automatics
     end else if (qrun & rNSKP) begin
	rSTKFUL <= #1 (wSTKINC == 6'h20);		 
	rSTKUNF <= #1 (wSTKDEC == 6'h3F);		 	
       case (qfsm)
	 FSM_Q3: begin
	    rSTKPTR <= #1 ((rDWBADR == aSTKPTR) & rDWBWE) ? rRESULT : rSTKPTR;	    
	 end
	 FSM_Q2: begin
    	    case (rMXSTK)
	      MXSTK_PUSH: begin
		 rSTKPTR <= #1 (rSTKFUL) ? rSTKPTR : wSTKINC;
	      end
	      MXSTK_POP: begin
		 rSTKPTR <= #1 (rSTKUNF) ? rSTKPTR : wSTKDEC;
	      end
	      default: begin
		 rSTKPTR <= #1 rSTKPTR;
	      end
	    endcase // case(rMXSTK)
	 end // case: FSM_Q2
	 default: begin
	    rSTKPTR <= #1 rSTKPTR;	    
	 end
       endcase // case(qfsm)
     end // if (qrun & rNSKP)
   
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rTOSH <= 8'h0;
	rTOSL <= 8'h0;
	rTOSU <= 8'h0;
	// End of automatics
     end else if (qrun & rNSKP)
       case (qfsm)
	 FSM_Q3: begin
	    rTOSU <= #1 ((rDWBADR == aTOSU) & rDWBWE) ? rRESULT : rTOSU;
	    rTOSH <= #1 ((rDWBADR == aTOSH) & rDWBWE) ? rRESULT : rTOSH;
	    rTOSL <= #1 ((rDWBADR == aTOSL) & rDWBWE) ? rRESULT : rTOSL;	    
	 end
	 FSM_Q2: begin
    	    case (rMXSTK)
	      MXSTK_PUSH: begin
		 {rTOSU,rTOSH,rTOSL} <= #1 {wPCLAT,1'b0};		 
	      end
	      MXSTK_POP: begin
		 {rTOSU,rTOSH,rTOSL} <= #1 wSTKR;		 
	      end
	      default: begin
		 rTOSU <= #1 rTOSU;
		 rTOSH <= #1 rTOSH;
		 rTOSL <= #1 rTOSL;		 
	      end
	    endcase // case(rMXSTK)
	 end // case: FSM_Q2
	 default: begin
	    rTOSU <= #1 rTOSU;
	    rTOSH <= #1 rTOSH;
	    rTOSL <= #1 rTOSL;
	 end
       endcase // case(qfsm)

   
   // SHADOW REGISTERS
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rBSR_ <= 8'h0;
	rSTATUS_ <= 5'h0;
	rWREG_ <= 8'h0;
	// End of automatics
     end else if (qena[3] & rNSKP) begin
	rWREG_ <= #1 (rMXSHA == MXSHA_CALL) ? rWREG : rWREG_;
	rBSR_ <= #1 (rMXSHA == MXSHA_CALL) ? rBSR : rBSR_;
	rSTATUS_ <= #1 (rMXSHA == MXSHA_CALL) ? {rN,rOV,rZ,rDC,rC} : rSTATUS_;	
     end
   
   // STATUS
   reg [2:0] rMXSTAL;
   always @(negedge clk or negedge qrst)
     if (!qrst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       rMXSTAL <= 3'h0;
       // End of automatics
     else if (qena[3])
       rMXSTAL <= #1 rMXSTA;
   
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rC <= 1'h0;
	rDC <= 1'h0;
	rN <= 1'h0;
	rOV <= 1'h0;
	rZ <= 1'h0;
	// End of automatics
     end else if (qrun & rNSKP) begin
	case (qfsm)
	  default: {rN,rOV,rZ,rDC,rC} <= #1 ((rDWBADR == aSTATUS) & rDWBWE) ? rRESULT : {rN,rOV,rZ,rDC,rC};
	  FSM_Q2: {rN,rOV,rZ,rDC,rC} <= #1 (rMXSHA == MXSHA_RET) ? rSTATUS_ : {rN,rOV,rZ,rDC,rC};
	  FSM_Q0: case (rMXSTAL)
		    MXSTA_ALL: {rN,rOV,rZ,rDC,rC} <= #1 {wN,wOV,wZ,wDC,wC};
		    MXSTA_CZN: {rN,rOV,rZ,rDC,rC} <= #1 {wN,rOV,wZ,rDC,wC};
		    MXSTA_ZN:  {rN,rOV,rZ,rDC,rC} <= #1 {wN,rOV,wZ,rDC,rC};
		    MXSTA_Z:  {rN,rOV,rZ,rDC,rC} <= #1 {rN,rOV,wZ,rDC,rC};
		    MXSTA_C:  {rN,rOV,rZ,rDC,rC} <= #1 {rN,rOV,rZ,rDC,wC};	    
		    default:  {rN,rOV,rZ,rDC,rC} <= #1 {rN,rOV,rZ,rDC,rC};	    
		  endcase // case(rMXSTA)
	endcase // case(qfsm)	
     end // if (qena[3] & rNSKP)

   // WREG
   // TODO: DAW
   wire [7:0] wDAW = ((rMXALU == MXALU_DAW) & (rMXDST == MXDST_EXT)) ? 8'h00 : rWREG;   
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rWREG <= 8'h0;
	// End of automatics
     end else if (qena[3] & rNSKP) begin
	rWREG <= #1 (((rDWBADR == aWREG) & rDWBWE) | (rMXDST == MXDST_WREG)) ? rRESULT :
		 (rMXSHA == MXSHA_RET) ? rWREG_ :
		 rWREG;
     end

   // BSR
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rBSR <= 8'h0;
	// End of automatics
     end else if (qrun & rNSKP)
       case (qfsm)
	 FSM_Q3: rBSR <= #1 (((rDWBADR == aBSR) & rDWBWE)) ? rRESULT :
			 (rMXSHA == MXSHA_RET) ? rBSR_ :
			 rBSR;	
	 default: rBSR <= #1 ((rMXALU == MXALU_MOVLB) & (rMXDST == MXDST_EXT)) ? rIREG[7:0] : rBSR;	 
       endcase // case(qfsm)

   // FSRXH/FSRXL
   wire [DSIZ-1:0] wFSRDEC0 = {rFSR0H,rFSR0L} - 1;
   wire [DSIZ-1:0] wFSRDEC1 = {rFSR1H,rFSR1L} - 1;
   wire [DSIZ-1:0] wFSRDEC2 = {rFSR2H,rFSR2L} - 1;
   
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rFSR0H <= 8'h0;
	rFSR0L <= 8'h0;
	rFSR1H <= 8'h0;
	rFSR1L <= 8'h0;
	rFSR2H <= 8'h0;
	rFSR2L <= 8'h0;
	// End of automatics
     end else if (qrun & rNSKP) // if (!qrst)
       case (qfsm)
	 FSM_Q3: begin
	    rFSR0H <= #1 (((rDWBADR == aFSR0H) & rDWBWE)) ? rRESULT : rFSR0H;	    
	    rFSR0L <= #1 (((rDWBADR == aFSR0L) & rDWBWE)) ? rRESULT : rFSR0L;	    
	    rFSR1H <= #1 (((rDWBADR == aFSR1H) & rDWBWE)) ? rRESULT : rFSR1H;	    
	    rFSR1L <= #1 (((rDWBADR == aFSR1L) & rDWBWE)) ? rRESULT : rFSR1L;	    
	    rFSR2H <= #1 (((rDWBADR == aFSR2H) & rDWBWE)) ? rRESULT : rFSR2H;	    
	    rFSR2L <= #1 (((rDWBADR == aFSR2L) & rDWBWE)) ? rRESULT : rFSR2L;	    
	 end
	 FSM_Q2: begin
	    // Post Inc/Dec
	    case (rMXFSR)
	      MXFSR_POSTINC0: {rFSR0H,rFSR0L} <= #1 wFSRINC0;
	      MXFSR_POSTINC1: {rFSR1H,rFSR1L} <= #1 wFSRINC1;
	      MXFSR_POSTINC2: {rFSR2H,rFSR2L} <= #1 wFSRINC2;
	      MXFSR_POSTDEC0: {rFSR0H,rFSR0L} <= #1 wFSRDEC0;
	      MXFSR_POSTDEC1: {rFSR1H,rFSR1L} <= #1 wFSRDEC1;	      
	      MXFSR_POSTDEC2: {rFSR2H,rFSR2L} <= #1 wFSRDEC2;	      
	    endcase // case(rMXFSR)
	 end // case: FSM_Q2	 
	 FSM_Q1: begin
	    // Load Literals
	    if ((rMXALU == MXALU_LFSR) & (rMXDST == MXDST_EXT))
	      case (rIREG[5:4])
		2'o0: {rFSR0H,rFSR0L} <= #1 {rIREG[3:0],rROMLAT[7:0]};		
		2'o1: {rFSR1H,rFSR1L} <= #1 {rIREG[3:0],rROMLAT[7:0]};		
		2'o2: {rFSR2H,rFSR2L} <= #1 {rIREG[3:0],rROMLAT[7:0]};		
	      endcase // case(rIREG[5:4])
	 end // case: FSM_Q1
	 
	 FSM_Q0: begin
	    // Pre inc
	    case (rMXFSR)
	      MXFSR_PREINC0: {rFSR0H,rFSR0L} <= #1 wFSRINC0;
	      MXFSR_PREINC1: {rFSR1H,rFSR1L} <= #1 wFSRINC1;
	      MXFSR_PREINC2: {rFSR2H,rFSR2L} <= #1 wFSRINC2;	      
	    endcase // case(rMXFSR)
	 end	 
	 
       endcase // case(qfsm)
   
   
   // PRODH/PRODL
   wire [15:0] wPRODUCT = ((rMXALU == MXALU_MUL) & (rMXDST == MXDST_EXT)) ? (rSRC * rTGT) : {rPRODH,rPRODL};   
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rPRODH <= 8'h0;
	rPRODL <= 8'h0;
	// End of automatics
     end else if (qena[3] & rNSKP) begin
	rPRODH <= #1 (((rDWBADR == aPRODH) & rDWBWE)) ? rRESULT : wPRODUCT[15:8];
	rPRODL <= #1 (((rDWBADR == aPRODL) & rDWBWE)) ? rRESULT : wPRODUCT[7:0];	
     end

   // TBLATU/TBLATH/TBLATL
   wire [ISIZ-1:0] wTBLINC = {rTBLPTRU,rTBLPTRH,rTBLPTRL} + 1;
   wire [ISIZ-1:0] wTBLAT =  {rTBLPTRU,rTBLPTRH,rTBLPTRL};
   wire [ISIZ-1:0] wTBLDEC = {rTBLPTRU,rTBLPTRH,rTBLPTRL} - 1;   
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rTBLPTRH <= 8'h0;
	rTBLPTRL <= 8'h0;
	rTBLPTRU <= 8'h0;
	// End of automatics
     end else if (qrun & rNSKP)
       case (qfsm)
	 FSM_Q0: {rTBLPTRU,rTBLPTRH,rTBLPTRL} <= #1 ((rMXTBL == MXTBL_WTPRE) | (rMXTBL == MXTBL_RDPRE)) ? wTBLINC : wTBLAT;
	 FSM_Q2: {rTBLPTRU,rTBLPTRH,rTBLPTRL} <= #1 ((rMXTBL == MXTBL_WTINC) | (rMXTBL == MXTBL_RDINC)) ? wTBLINC :
					      ((rMXTBL == MXTBL_WTDEC) | (rMXTBL == MXTBL_RDDEC)) ? wTBLDEC : wTBLAT;
	 default: begin
	    rTBLPTRU <= #1 ((rDWBADR == aTBLPTRU) & rDWBWE) ? rRESULT : rTBLPTRU;	    
	    rTBLPTRH <= #1 ((rDWBADR == aTBLPTRH) & rDWBWE) ? rRESULT : rTBLPTRH;	    
	    rTBLPTRL <= #1 ((rDWBADR == aTBLPTRL) & rDWBWE) ? rRESULT : rTBLPTRL;	    
	 end	 
       endcase // case(qfsm)
   
   // TABLAT
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rTABLAT <= 8'h0;
	// End of automatics
     end else if (qena[3] & rNSKP)
       case (rMXTBL)
	 MXTBL_RD,MXTBL_RDINC,MXTBL_RDDEC,MXTBL_RDPRE:
	   rTABLAT <= #1 rILAT;	 
	 default: rTABLAT <= #1 (rDWBWE & (rDWBADR == aTABLAT)) ? rRESULT : rTABLAT;	 
       endcase // case(rMXTBL)

   // PCLATU/PCLATH
   always @(posedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rPCLATH <= 8'h0;
	rPCLATU <= 8'h0;
	// End of automatics
     end else if (qena[3] & rNSKP) begin
	rPCLATU <= #1 ((rDWBADR == aPCLATU) & rDWBWE) ? rRESULT :
		   ((rDWBADR == aPCL) & ~rDWBWE) ? rPCU :
		   rPCLATU;
	rPCLATH <= #1 ((rDWBADR == aPCLATH) & rDWBWE) ? rRESULT :
		   ((rDWBADR == aPCL) & ~rDWBWE) ? rPCH :
		   rPCLATH;			   	
     end

   // PCU/PCH/PCL
   always @(negedge clk or negedge qrst)
     if (!qrst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rPCH <= 8'h0;
	rPCL <= 8'h0;
	rPCU <= 5'h0;
	// End of automatics
     end else if (qena[3]) begin
	{rPCU,rPCH,rPCL} <= #1 ((rDWBADR == aPCL) & rDWBWE) ? {rPCLATU,rPCLATH,rRESULT} :
			    {rPCNXT,1'b0};	
     end   

   // SKIP register
   wire 	  wSKP = 
		  (rMXSKP == MXSKP_SZ) ? wZ :
		  (rMXSKP == MXSKP_SNZ) ? ~wZ :
		  (rMXSKP == MXSKP_SNC) ? wC :
		  (rMXSKP == MXSKP_SCC) ? rBCC :
		  (rMXSKP == MXSKP_SU) ? (1'b1) :
		  1'b0;   
   always @(negedge clk or negedge qrst)
     if (!qrst)
       rNSKP <= 1'h1;
     else if (qena[3])       
       rNSKP <= #1 ((rDWBADR == aPCL) & rDWBWE) ? 1'b0 : ~(wSKP & rNSKP);
         
endmodule // ae18_core
