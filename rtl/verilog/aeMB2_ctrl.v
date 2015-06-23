/* $Id: aeMB2_ctrl.v,v 1.7 2008-05-11 13:50:50 sybreon Exp $
**
** AEMB2 EDK 6.2 COMPATIBLE CORE
** Copyright (C) 2004-2008 Shawn Tan <shawn.tan@aeste.net>
**  
** This file is part of AEMB.
**
** AEMB is free software: you can redistribute it and/or modify it
** under the terms of the GNU Lesser General Public License as
** published by the Free Software Foundation, either version 3 of the
** License, or (at your option) any later version.
**
** AEMB is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
** Public License for more details.
**
** You should have received a copy of the GNU Lesser General Public
** License along with AEMB. If not, see <http:**www.gnu.org/licenses/>.
*/
/**
 * Instruction Decode & Control
 * @file aeMB2_ctrl.v
 
 * This is the data decoder that will control the command signals and
   operand fetch. 
 
 */

module aeMB2_ctrl (/*AUTOARG*/
   // Outputs
   opa_of, opb_of, opd_of, opc_of, ra_of, rd_of, imm_of, rd_ex,
   mux_of, mux_ex, hzd_bpc, hzd_fwd,
   // Inputs
   opa_if, opb_if, opd_if, brk_if, bra_ex, rpc_if, alu_ex, ich_dat,
   exc_dwb, exc_ill, exc_iwb, gclk, grst, dena, iena, gpha
   );
   parameter AEMB_HTX = 1;   
   
   // EX CONTROL
   output [31:0] opa_of;
   output [31:0] opb_of;
   output [31:0] opd_of;
   output [5:0]  opc_of;   
   output [4:0]  ra_of,
		 //rb_of,
		 rd_of;
   output [15:0] imm_of;   
   output [4:0]	 rd_ex;   
   
   // REGS
   input [31:0]  opa_if,
		 opb_if,
		 opd_if;   
   
   // WB CONTROL
   output [2:0]  mux_of,
		 mux_ex;   
   
   // INTERNAL
   input [1:0] 	 brk_if;   
   input [1:0] 	 bra_ex;   
   input [31:2]  rpc_if;   
   input [31:0]  alu_ex;   
   input [31:0]  ich_dat;

   input [1:0] 	 exc_dwb;
   input 	 exc_ill;
   input 	 exc_iwb;   
   
   output 	 hzd_bpc;   
   output 	 hzd_fwd;
   
   // SYSTEM
   input 	 gclk,
		 grst,
		 dena,
		 iena,
		 gpha;   
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [15:0]		imm_of;
   reg [2:0]		mux_ex;
   reg [2:0]		mux_of;
   reg [31:0]		opa_of;
   reg [31:0]		opb_of;
   reg [5:0]		opc_of;
   reg [31:0]		opd_of;
   reg [4:0]		ra_of;
   reg [4:0]		rd_ex;
   reg [4:0]		rd_of;
   // End of automatics

   wire 		fINT, fXCE;   
   wire [31:0] 		wXCEOP = 32'hBA2E0020; // Vector 0x20
   wire [31:0] 		wINTOP = 32'hB9CD0010; // Vector 0x10   
   //wire [31:0] 		wNOPOP = 32'h88000000; // branch-no-delay/stall
   
   wire [1:0] 		mux_opa, mux_opb, mux_opd;   
   
   // translate signals
   wire [4:0] 		wRD, wRA, wRB;
   wire [5:0] 		wOPC;
   wire [15:0] 		wIMM;
   wire [31:0] 		imm_if;
   
   assign 		{wOPC, wRD, wRA, wIMM} = (fXCE) ? wXCEOP :
						 (fINT) ? wINTOP : 
						 ich_dat;
   assign 		wRB = wIMM[15:11];

   // decode main opgroups

   //wire 		fSFT = (wOPC == 6'o44);
   //wire 		fLOG = ({wOPC[5:4],wOPC[2]} == 3'o4);      
   wire 		fMUL = (wOPC == 6'o20) | (wOPC == 6'o30);
   wire 		fBSF = (wOPC == 6'o21) | (wOPC == 6'o31);
   //wire 		fDIV = (wOPC == 6'o22);   
   wire 		fRTD = (wOPC == 6'o55);
   wire 		fBCC = (wOPC == 6'o47) | (wOPC == 6'o57);
   wire 		fBRU = (wOPC == 6'o46) | (wOPC == 6'o56);
   //wire 		fBRA = fBRU & wRA[3];      
   wire 		fIMM = (wOPC == 6'o54);
   wire 		fMOV = (wOPC == 6'o45);      
   wire 		fLOD = ({wOPC[5:4],wOPC[2]} == 3'o6);
   wire 		fSTR = ({wOPC[5:4],wOPC[2]} == 3'o7);
   //wire 		fLDST = (wOPC[5:4] == 2'o3);   
   //wire 		fPUT = (wOPC == 6'o33) & wRB[4];
   wire 		fGET = (wOPC == 6'o33) & !wRB[4];   


   // control signals
   localparam [2:0] 	MUX_SFR = 3'o7,
			MUX_BSF = 3'o6,
			MUX_MUL = 3'o5,
			MUX_MEM = 3'o4,
			
			MUX_RPC = 3'o2,
			MUX_ALU = 3'o1,
			MUX_NOP = 3'o0;   							  
   
   always @(posedge gclk)
     if (grst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	imm_of <= 16'h0;
	mux_of <= 3'h0;
	opc_of <= 6'h0;
	ra_of <= 5'h0;
	rd_of <= 5'h0;
	// End of automatics
     end else if (dena) begin

	mux_of <= #1
		  (hzd_bpc | hzd_fwd | fSTR | fRTD | fBCC) ? MUX_NOP :
		  (fLOD | fGET) ? MUX_MEM :
		  (fMOV) ? MUX_SFR :
		  (fMUL) ? MUX_MUL :
		  (fBSF) ? MUX_BSF :
		  (fBRU) ? MUX_RPC :		  
		  MUX_ALU;
	
	opc_of <= #1		  
		  (hzd_bpc | hzd_fwd) ? 6'o42 : // XOR (SKIP) 
		  wOPC;
	
	rd_of <= #1 wRD;	
	ra_of <= #1 wRA;
	imm_of <= #1 wIMM;
	
     end // if (dena)
      
   // immediate implementation
   reg [15:0] 		rIMM0, rIMM1;
   reg 			rFIM0, rFIM1;
   //wire 		wFIMH = (gpha & AEMB_HTX[0]) ? rFIM1 : rFIM0;   
   //wire [15:0] 		wIMMH = (gpha & AEMB_HTX[0]) ? rIMM1 : rIMM0;

   assign 		imm_if[15:0] = wIMM;
   assign 		imm_if[31:16] = (rFIM1) ? rIMM1 :
					{(16){wIMM[15]}};

   // BARREL IMM
   always @(posedge gclk)
     if (grst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rFIM0 <= 1'h0;
	rFIM1 <= 1'h0;
	rIMM0 <= 16'h0;
	rIMM1 <= 16'h0;
	// End of automatics
     end else if (dena) begin
	rFIM1 <= #1 rFIM0;
	rFIM0 <= #1 fIMM & !hzd_bpc;	

	rIMM1 <= #1 rIMM0;
	rIMM0 <= #1 wIMM;	
     end

   assign fINT = brk_if[0] & gpha & !rFIM1;   
   //assign fXCE = brk_if[1];
   assign fXCE = |{exc_ill, exc_iwb, exc_dwb};
   // & ((gpha & !rFIM1) | (!gpha & rFIM0));   
   
   // operand latch   
   reg 			wrb_ex;
   reg 			fwd_ex;   
   reg [2:0] 		mux_mx;
   
   wire 		opb_fwd, opa_fwd, opd_fwd;
   
   assign 		mux_opb = {wOPC[3], opb_fwd};
   assign 		opb_fwd = ((wRB ^ rd_ex) == 5'd0) & // RB forwarding needed
				  fwd_ex & wrb_ex;   

   assign 		mux_opa = {(fBRU|fBCC), opa_fwd};
   assign 		opa_fwd = ((wRA ^ rd_ex) == 5'd0) & // RA forwarding needed
				  fwd_ex & wrb_ex;

   assign 		mux_opd = {fBCC, opd_fwd};		
   assign 		opd_fwd = (( ((wRA ^ rd_ex) == 5'd0) & fBCC) | // RA forwarding
				   ( ((wRD ^ rd_ex) == 5'd0) & fSTR)) & // RD forwarding
				  fwd_ex & wrb_ex;   

   always @(posedge gclk)
     if (grst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	fwd_ex <= 1'h0;
	mux_ex <= 3'h0;
	mux_mx <= 3'h0;
	rd_ex <= 5'h0;
	wrb_ex <= 1'h0;
	// End of automatics
     end else if (dena) begin
	wrb_ex <= #1 |rd_of & |mux_of; // FIXME: check mux	
	fwd_ex <= #1 |mux_of; // FIXME: check mux

	mux_mx <= #1 mux_ex;	
	mux_ex <= #1 mux_of;	
	rd_ex <= #1 rd_of;	
     end
      
   always @(posedge gclk)
     if (grst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	opa_of <= 32'h0;
	opb_of <= 32'h0;
	opd_of <= 32'h0;
	// End of automatics
	
     end else if (dena) begin
		  
	case (mux_opd)
	  2'o2: opd_of <= #1 opa_if; // BCC
	  2'o1: opd_of <= #1 alu_ex; // FWD
	  2'o0: opd_of <= #1 opd_if; // SXX
	  2'o3: opd_of <= #1 alu_ex; // FWD	  	  
	endcase // case (mux_opd)
	
	case (mux_opb)
	  2'o0: opb_of <= #1 opb_if;
	  2'o1: opb_of <= #1 alu_ex;
	  2'o2: opb_of <= #1 imm_if;
	  2'o3: opb_of <= #1 imm_if;	  
	endcase // case (mux_opb)
	
	case (mux_opa)
	  2'o0: opa_of <= #1 opa_if;
	  2'o1: opa_of <= #1 alu_ex;
	  2'o2: opa_of <= #1 {rpc_if, 2'o0};
	  2'o3: opa_of <= #1 {rpc_if, 2'o0};	  
	endcase // case (mux_opa)
	 	
     end // if (dena)
   
   // Hazard Detection
   //wire 		wFMUL = (mux_ex == MUX_MUL);
   //wire 		wFBSF = (mux_ex == MUX_BSF);
   //wire 		wFMEM = (mux_ex == MUX_MEM);
   //wire 		wFMOV = (mux_ex == MUX_SFR);   
   
   assign 		hzd_fwd = (opd_fwd | opa_fwd | opb_fwd) & mux_ex[2];   
				  //(wFMUL | wFBSF | wFMEM | wFMOV);
   assign 		hzd_bpc = (bra_ex[1] & !bra_ex[0]);
   
endmodule // aeMB2_ctrl
