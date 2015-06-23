/* $Id: aeMB2_sim.v,v 1.2 2007-12-29 00:31:48 sybreon Exp $
**
** AEMB2 SIMULATION WRAPPER
** Copyright (C) 2004-2007 Shawn Tan Ser Ngiap <shawn.tan@aeste.net>
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

module aeMB2_sim (/*AUTOARG*/
   // Outputs
   iwb_wre_o, iwb_tga_o, iwb_stb_o, iwb_adr_o, dwb_wre_o, dwb_tga_o,
   dwb_stb_o, dwb_sel_o, dwb_dat_o, dwb_cyc_o, dwb_adr_o, cwb_wre_o,
   cwb_tga_o, cwb_stb_o, cwb_sel_o, cwb_dat_o, cwb_adr_o,
   // Inputs
   sys_rst_i, sys_int_i, sys_clk_i, iwb_dat_i, iwb_ack_i, dwb_dat_i,
   dwb_ack_i, cwb_dat_i, cwb_ack_i
   );

   parameter IWB=16;
   parameter DWB=16;

   parameter TXE = 1; ///< thread execution enable
   
   parameter MUL = 1; ///< enable hardware multiplier
   parameter BSF = 1; ///< enable barrel shifter
   parameter FSL = 1; ///< enable FSL bus
   parameter DIV = 0; ///< enable hardware divider   
   
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [6:2]		cwb_adr_o;		// From sim of aeMB2_edk32.v
   output [31:0]	cwb_dat_o;		// From sim of aeMB2_edk32.v
   output [3:0]		cwb_sel_o;		// From sim of aeMB2_edk32.v
   output		cwb_stb_o;		// From sim of aeMB2_edk32.v
   output [1:0]		cwb_tga_o;		// From sim of aeMB2_edk32.v
   output		cwb_wre_o;		// From sim of aeMB2_edk32.v
   output [DWB-1:2]	dwb_adr_o;		// From sim of aeMB2_edk32.v
   output		dwb_cyc_o;		// From sim of aeMB2_edk32.v
   output [31:0]	dwb_dat_o;		// From sim of aeMB2_edk32.v
   output [3:0]		dwb_sel_o;		// From sim of aeMB2_edk32.v
   output		dwb_stb_o;		// From sim of aeMB2_edk32.v
   output		dwb_tga_o;		// From sim of aeMB2_edk32.v
   output		dwb_wre_o;		// From sim of aeMB2_edk32.v
   output [IWB-1:2]	iwb_adr_o;		// From sim of aeMB2_edk32.v
   output		iwb_stb_o;		// From sim of aeMB2_edk32.v
   output		iwb_tga_o;		// From sim of aeMB2_edk32.v
   output		iwb_wre_o;		// From sim of aeMB2_edk32.v
   // End of automatics
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		cwb_ack_i;		// To sim of aeMB2_edk32.v
   input [31:0]		cwb_dat_i;		// To sim of aeMB2_edk32.v
   input		dwb_ack_i;		// To sim of aeMB2_edk32.v
   input [31:0]		dwb_dat_i;		// To sim of aeMB2_edk32.v
   input		iwb_ack_i;		// To sim of aeMB2_edk32.v
   input [31:0]		iwb_dat_i;		// To sim of aeMB2_edk32.v
   input		sys_clk_i;		// To sim of aeMB2_edk32.v
   input		sys_int_i;		// To sim of aeMB2_edk32.v
   input		sys_rst_i;		// To sim of aeMB2_edk32.v
   // End of automatics
   /*AUTOWIRE*/
   
   aeMB2_edk32
     #(/*AUTOINSTPARAM*/
       // Parameters
       .IWB				(IWB),
       .DWB				(DWB),
       .TXE				(TXE),
       .MUL				(MUL),
       .BSF				(BSF),
       .FSL				(FSL))
   sim
     (/*AUTOINST*/
      // Outputs
      .cwb_adr_o			(cwb_adr_o[6:2]),
      .cwb_dat_o			(cwb_dat_o[31:0]),
      .cwb_sel_o			(cwb_sel_o[3:0]),
      .cwb_stb_o			(cwb_stb_o),
      .cwb_tga_o			(cwb_tga_o[1:0]),
      .cwb_wre_o			(cwb_wre_o),
      .dwb_adr_o			(dwb_adr_o[DWB-1:2]),
      .dwb_cyc_o			(dwb_cyc_o),
      .dwb_dat_o			(dwb_dat_o[31:0]),
      .dwb_sel_o			(dwb_sel_o[3:0]),
      .dwb_stb_o			(dwb_stb_o),
      .dwb_tga_o			(dwb_tga_o),
      .dwb_wre_o			(dwb_wre_o),
      .iwb_adr_o			(iwb_adr_o[IWB-1:2]),
      .iwb_stb_o			(iwb_stb_o),
      .iwb_tga_o			(iwb_tga_o),
      .iwb_wre_o			(iwb_wre_o),
      // Inputs
      .cwb_ack_i			(cwb_ack_i),
      .cwb_dat_i			(cwb_dat_i[31:0]),
      .dwb_ack_i			(dwb_ack_i),
      .dwb_dat_i			(dwb_dat_i[31:0]),
      .iwb_ack_i			(iwb_ack_i),
      .iwb_dat_i			(iwb_dat_i[31:0]),
      .sys_clk_i			(sys_clk_i),
      .sys_int_i			(sys_int_i),
      .sys_rst_i			(sys_rst_i));

   // synopsys translate_off
   
   wire [31:0] 		iwb_adr = {iwb_adr_o, 2'd0};
   wire [31:0] 		dwb_adr = {dwb_adr_o, 2'd0};
   wire [31:0] 		wMSR = sim.aslu.wMSR[31:0];   
   
   always @(posedge sim.clk_i) if (sim.ena_i) begin   

      $write ("\n", ($stime/10));
      $writeh (" T", sim.pha_i);
      $writeh(" PC=", iwb_adr);
      
      $writeh ("\t| ");
      
      case (sim.rOPC_IF)
	6'o00: if (sim.rRD_IF == 0) $write("   "); else $write("ADD");
	6'o01: $write("SUB");	
	6'o02: $write("ADDC");	
	6'o03: $write("SUBC");	
	6'o04: $write("ADDK");	
	6'o05: case (sim.rIMM_IF[1:0])
		 2'o0: $write("SUBK");	
		 2'o1: $write("CMP");	
		 2'o3: $write("CMPU");	
		 default: $write("XXX");
	       endcase // case (sim.rIMM_IF[1:0])
	6'o06: $write("ADDKC");	
	6'o07: $write("SUBKC");	
	
	6'o10: $write("ADDI");	
	6'o11: $write("SUBI");	
	6'o12: $write("ADDIC");	
	6'o13: $write("SUBIC");	
	6'o14: $write("ADDIK");	
	6'o15: $write("SUBIK");	
	6'o16: $write("ADDIKC");	
	6'o17: $write("SUBIKC");	

	6'o20: $write("MUL");	
	6'o21: case (sim.rALT_IF[10:9])
		 2'o0: $write("BSRL");		 
		 2'o1: $write("BSRA");		 
		 2'o2: $write("BSLL");		 
		 default: $write("XXX");		 
	       endcase // case (sim.rALT_IF[10:9])
	6'o22: $write("IDIV");	

	6'o30: $write("MULI");	
	6'o31: case (sim.rALT_IF[10:9])
		 2'o0: $write("BSRLI");		 
		 2'o1: $write("BSRAI");		 
		 2'o2: $write("BSLLI");		 
		 default: $write("XXX");		 
	       endcase // case (sim.rALT_IF[10:9])
	6'o33: case (sim.rRB_IF[4:2])
		 3'o0: $write("GET");
		 3'o4: $write("PUT");		 
		 3'o2: $write("NGET");
		 3'o6: $write("NPUT");		 
		 3'o1: $write("CGET");
		 3'o5: $write("CPUT");		 
		 3'o3: $write("NCGET");
		 3'o7: $write("NCPUT");		 
	       endcase // case (sim.rRB_IF[4:2])

	6'o40: $write("OR");
	6'o41: $write("AND");	
	6'o42: if (sim.rRD_IF == 0) $write("   "); else $write("XOR");
	6'o43: $write("ANDN");	
	6'o44: case (sim.rIMM_IF[6:5])
		 2'o0: $write("SRA");
		 2'o1: $write("SRC");
		 2'o2: $write("SRL");
		 2'o3: if (sim.rIMM_IF[0]) $write("SEXT16"); else $write("SEXT8");		 
	       endcase // case (sim.rIMM_IF[6:5])
	
	6'o45: $write("MOV");	
	6'o46: case (sim.rRA_IF[3:2])
		 3'o0: $write("BR");		 
		 3'o1: $write("BRL");		 
		 3'o2: $write("BRA");		 
		 3'o3: $write("BRAL");		 
	       endcase // case (sim.rRA_IF[3:2])
	
	6'o47: case (sim.rRD_IF[2:0])
		 3'o0: $write("BEQ");	
		 3'o1: $write("BNE");	
		 3'o2: $write("BLT");	
		 3'o3: $write("BLE");	
		 3'o4: $write("BGT");	
		 3'o5: $write("BGE");
		 default: $write("XXX");		 
	       endcase // case (sim.rRD_IF[2:0])
	
	6'o50: $write("ORI");	
	6'o51: $write("ANDI");	
	6'o52: $write("XORI");	
	6'o53: $write("ANDNI");	
	6'o54: $write("IMMI");	
	6'o55: case (sim.rRD_IF[1:0])
		 2'o0: $write("RTSD");
		 2'o1: $write("RTID");
		 2'o2: $write("RTBD");
		 default: $write("XXX");		 
	       endcase // case (sim.rRD_IF[1:0])
	6'o56: case (sim.rRA_IF[3:2])
		 3'o0: $write("BRI");		 
		 3'o1: $write("BRLI");		 
		 3'o2: $write("BRAI");		 
		 3'o3: $write("BRALI");		 
	       endcase // case (sim.rRA_IF[3:2])
	6'o57: case (sim.rRD_IF[2:0])
		 3'o0: $write("BEQI");	
		 3'o1: $write("BNEI");	
		 3'o2: $write("BLTI");	
		 3'o3: $write("BLEI");	
		 3'o4: $write("BGTI");	
		 3'o5: $write("BGEI");	
		 default: $write("XXX");		 
	       endcase // case (sim.rRD_IF[2:0])
	
	6'o60: $write("LBU");	
	6'o61: $write("LHU");	
	6'o62: $write("LW");	
	6'o64: $write("SB");	
	6'o65: $write("SH");	
	6'o66: $write("SW");	
	
	6'o70: $write("LBUI");	
	6'o71: $write("LHUI");	
	6'o72: $write("LWI");	
	6'o74: $write("SBI");	
	6'o75: $write("SHI");	
	6'o76: $write("SWI");

	default: $write("XXX");	
      endcase // case (sim.rOPC_IF)

      case (sim.rOPC_IF[3])
	1'b1: $writeh("\t r",sim.rRD_IF,", r",sim.rRA_IF,", h",sim.rIMM_IF);
	1'b0: $writeh("\t r",sim.rRD_IF,", r",sim.rRA_IF,", r",sim.rRB_IF,"  ");	
      endcase // case (sim.rOPC_IF[3])

      if (sim.bpcu.fHZD)
	$write ("*");      
      
      // ALU
      $write("\t|");
      $writeh(" A=",sim.rOPA_OF);
      $writeh(" B=",sim.rOPB_OF);
      $writeh(" C=",sim.rOPX_OF);
      $writeh(" M=",sim.rOPM_OF);
      
      $writeh(" MSR=", wMSR," ");

      case (sim.rALU_OF)
	3'o0: $write(" ADD");
	3'o1: $write(" BSF");
	3'o2: $write(" SLM");
	3'o3: $write(" MOV");
	default: $write(" XXX");
      endcase // case (sim.rALU_OF)

      // MA
      $write ("\t| ");      
      if (sim.dwb_stb_o)
	$writeh("@",sim.rRES_EX);
      else
	$writeh("=",sim.rRES_EX);

      
      case (sim.rBRA)
	2'b00: $write(" ");
	2'b01: $write(".");	
	2'b10: $write("-");
	2'b11: $write("+");	
      endcase // case (sim.rBRA)
      
      // WRITEBACK
      $write("\t|");
      
      if (|sim.rRD_MA) begin
	 case (sim.rOPD_MA)
	   2'o2: begin
	      if (sim.rSEL_MA != 4'h0) $writeh("R",sim.rRD_MA,"=RAM(",sim.regf.rREGD,")");
	      if (sim.rSEL_MA == 4'h0) $writeh("R",sim.rRD_MA,"=FSL(",sim.regf.rREGD,")");
	   end
	   2'o1: $writeh("R",sim.rRD_MA,"=LNK(",sim.regf.rREGD,")");
	   2'o0: $writeh("R",sim.rRD_MA,"=ALU(",sim.regf.rREGD,")");
	 endcase // case (sim.rOPD_MA)
      end

      /*
      // STORE
      if (dwb_stb_o & dwb_wre_o) begin
	 $writeh("RAM(", dwb_adr ,")=", dwb_dat_o);
	 case (dwb_sel_o)
	   4'hF: $write(":L");
	   4'h3,4'hC: $write(":W");
	   4'h1,4'h2,4'h4,4'h8: $write(":B");
	 endcase // case (dwb_sel_o)
	 
      end
       */
   end // if (sim.ena_i)
   
   // synopsys translate_on
      
endmodule // aeMB2_sim

/* $Log: not supported by cvs2svn $
/* Revision 1.1  2007/12/18 18:54:36  sybreon
/* Partitioned simulation model.
/* */