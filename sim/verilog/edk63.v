/*
** AEMB2 EDK 6.3 COMPATIBLE CORE
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
 Simulation Test Bench
 @file edk62.v
 
*/

`include "random.v"
  
module edk63();
   localparam AEMB_DWB = 18;
   localparam AEMB_XWB = 5;   
   localparam AEMB_IWB = 18;
   localparam AEMB_ICH = 11;
   localparam AEMB_IDX = 6;   
   localparam AEMB_HTX = 1; 
   localparam AEMB_BSF = 1;
   localparam AEMB_MUL = 1;
   localparam AEMB_XSL = 1;   
   localparam AEMB_DIV = 0;
   localparam AEMB_FPU = 0;
   
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			dwb_ack_i;		// To uut of aeMB2_edk63.v
   reg			iwb_ack_i;		// To uut of aeMB2_edk63.v
   reg			sys_clk_i;		// To uut of aeMB2_edk63.v
   reg			sys_ena_i;		// To uut of aeMB2_edk63.v
   reg			sys_int_i;		// To uut of aeMB2_edk63.v
   reg			sys_rst_i;		// To uut of aeMB2_edk63.v
   reg			xwb_ack_i;		// To uut of aeMB2_edk63.v
   // End of automatics

   always #5 sys_clk_i <= !sys_clk_i;
   
   initial begin
      `ifdef VCD_DUMP
      $dumpfile ("dump.vcd");
      $dumpvars (1,uut);           
      `endif
      
      sys_clk_i = $random(`randseed);
      sys_rst_i = 1;
      sys_ena_i = 1;
      sys_int_i = 1;
      
      xwb_ack_i = 0;      
      
      #50 sys_rst_i = 0;      
      #4000000 $displayh("\n*** TIMEOUT ", $stime, " ***"); $finish;
      
   end // initial begin
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [AEMB_DWB-1:2]	dwb_adr_o;		// From uut of aeMB2_edk63.v
   wire			dwb_cyc_o;		// From uut of aeMB2_edk63.v
   wire [31:0]		dwb_dat_o;		// From uut of aeMB2_edk63.v
   wire [3:0]		dwb_sel_o;		// From uut of aeMB2_edk63.v
   wire			dwb_stb_o;		// From uut of aeMB2_edk63.v
   wire			dwb_tag_o;		// From uut of aeMB2_edk63.v
   wire			dwb_wre_o;		// From uut of aeMB2_edk63.v
   wire [AEMB_IWB-1:2]	iwb_adr_o;		// From uut of aeMB2_edk63.v
   wire			iwb_cyc_o;		// From uut of aeMB2_edk63.v
   wire [3:0]		iwb_sel_o;		// From uut of aeMB2_edk63.v
   wire			iwb_stb_o;		// From uut of aeMB2_edk63.v
   wire			iwb_tag_o;		// From uut of aeMB2_edk63.v
   wire			iwb_wre_o;		// From uut of aeMB2_edk63.v
   wire [AEMB_XWB-1:2]	xwb_adr_o;		// From uut of aeMB2_edk63.v
   wire			xwb_cyc_o;		// From uut of aeMB2_edk63.v
   wire [31:0]		xwb_dat_o;		// From uut of aeMB2_edk63.v
   wire [3:0]		xwb_sel_o;		// From uut of aeMB2_edk63.v
   wire			xwb_stb_o;		// From uut of aeMB2_edk63.v
   wire			xwb_tag_o;		// From uut of aeMB2_edk63.v
   wire			xwb_wre_o;		// From uut of aeMB2_edk63.v
   // End of automatics

   // FAKE MEMORY ////////////////////////////////////////////////////////

   reg [31:0] 		rom[0:65535];
   reg [31:0] 		ram[0:65535];
   reg [31:0] 		dwblat;
   reg [31:0] 		xwblat;   
   reg [31:2] 		dadr, iadr;
   
   wire [31:0] 		dwb_dat_t = ram[dwb_adr_o];   
   wire [31:0] 		iwb_dat_i = rom[iadr]; 
   wire [31:0] 		dwb_dat_i = ram[dadr];     
   wire [31:0] 		xwb_dat_i = xwblat;   
   
   always @(posedge sys_clk_i) 
     if (sys_rst_i) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dwb_ack_i <= 1'h0;
	iwb_ack_i <= 1'h0;
	xwb_ack_i <= 1'h0;
	// End of automatics
     end else begin
	iwb_ack_i <= #1 iwb_stb_o & !iwb_ack_i;      
	dwb_ack_i <= #1 dwb_stb_o & !dwb_ack_i;
	xwb_ack_i <= #1 xwb_stb_o & !xwb_ack_i;
     end // else: !if(sys_rst_i)
   
   always @(posedge sys_clk_i) begin
      iadr <= #1 iwb_adr_o;      
      dadr <= #1 dwb_adr_o;

      if (xwb_wre_o & xwb_stb_o & xwb_ack_i) begin
	 xwblat <= #1 xwb_dat_o;	 
      end
      
      // SPECIAL PORTS
      if (dwb_wre_o & dwb_stb_o & dwb_ack_i) begin
	 case ({dwb_adr_o,2'o0})
	   32'hFFFFFFD0: $displayh(dwb_dat_o);
	   32'hFFFFFFC0: $write("%c",dwb_dat_o[31:24]);
	   32'hFFFFFFE0: sys_int_i <= #1 !sys_int_i;	   
	 endcase // case ({dwb_adr_o,2'o0})
	 
	 case (dwb_sel_o)
	   4'h1: ram[dwb_adr_o] <= {dwb_dat_t[31:8], dwb_dat_o[7:0]};
	   4'h2: ram[dwb_adr_o] <= {dwb_dat_t[31:16], dwb_dat_o[15:8], dwb_dat_t[7:0]};
	   4'h4: ram[dwb_adr_o] <= {dwb_dat_t[31:24], dwb_dat_o[23:16], dwb_dat_t[15:0]};
	   4'h8: ram[dwb_adr_o] <= {dwb_dat_o[31:24], dwb_dat_t[23:0]};
	   4'h3: ram[dwb_adr_o] <= {dwb_dat_t[31:16], dwb_dat_o[15:0]};
	   4'hC: ram[dwb_adr_o] <= {dwb_dat_o[31:16], dwb_dat_t[15:0]};
	   4'hF: ram[dwb_adr_o] <= {dwb_dat_o};
	   default: begin
	      //$displayh("\n*** INVALID WRITE ",{dwb_adr_o,2'o0}, " ***");
	      //$finish;	      
	   end	   
	 endcase // case (dwb_sel_o)
      end // if (dwb_wre_o & dwb_stb_o & dwb_ack_i)

      if (dwb_stb_o & !dwb_wre_o & dwb_ack_i) begin
	 case (dwb_sel_o)
	   4'h1,4'h2,4'h4,4'h8,4'h3,4'hC,4'hF: begin
	   end
	   default: begin
	      //$displayh("\n*** INVALID READ ",{dwb_adr_o,2'd0}, " ***");	      
	      //$finish;	      
	   end	   
	 endcase // case (dwb_sel_o)	 
      end
      
   end // always @ (posedge sys_clk_i)
   
   integer i;   
   initial begin
      for (i=0;i<65535;i=i+1) begin
	 ram[i] <= $random;
      end
      #1 $readmemh("dump.vmem",rom);
      #1 $readmemh("dump.vmem",ram);
   end

   // DUMP CYCLES   
   always @(posedge sys_clk_i)
     if (uut.dena) begin
     //begin
`ifdef AEMB2_SIM_KERNEL
	$displayh("TME=",($stime/10),
		  ",PHA=",uut.gpha,
		  ",IWB=",{uut.rpc_if,2'o0},
		  ",ASM=",uut.ich_dat,
		  ",OPA=",uut.opa_of,
		  ",OPB=",uut.opb_of,
		  ",OPD=",uut.opd_of,
		  ",MSR=",uut.msr_ex,	       
		  ",MEM=",{uut.mem_ex,2'o0},
		  ",BRA=",uut.bra_ex,
		  ",BPC=",{uut.bpc_ex,2'o0},
		  ",MUX=",uut.mux_ex,
		  ",ALU=",uut.alu_mx,
		  //",WRE=",dwb_wre_o,
		  ",SEL=",dwb_sel_o,
		  //",DWB=",dwb_dat_o,
		  ",REG=",uut.regs0.gprf0.wRW0,
		  //",DAT=",uut.regs0.gprf0.regd,
		  ",MUL=",uut.mul_mx,	     
		  ",BSF=",uut.bsf_mx,
		  ",DWB=",uut.dwb_mx,
		  ",LNK=",{uut.rpc_mx,2'o0},
		  ",SFR=",uut.sfr_mx,
		  ",E"
		  );	
`endif
	if (uut.ich_dat == 32'hB8000000) begin 
	   $displayh("\n*** EXIT ", $stime, " ***");
	   $finish;
	end
     end // if (uut.dena)
   
   aeMB2_edk63
     #(/*AUTOINSTPARAM*/
       // Parameters
       .AEMB_IWB			(AEMB_IWB),
       .AEMB_DWB			(AEMB_DWB),
       .AEMB_XWB			(AEMB_XWB),
       .AEMB_ICH			(AEMB_ICH),
       .AEMB_IDX			(AEMB_IDX),
       .AEMB_BSF			(AEMB_BSF),
       .AEMB_MUL			(AEMB_MUL),
       .AEMB_DIV			(AEMB_DIV),
       .AEMB_FPU			(AEMB_FPU))
   uut
     (/*AUTOINST*/
      // Outputs
      .dwb_adr_o			(dwb_adr_o[AEMB_DWB-1:2]),
      .dwb_cyc_o			(dwb_cyc_o),
      .dwb_dat_o			(dwb_dat_o[31:0]),
      .dwb_sel_o			(dwb_sel_o[3:0]),
      .dwb_stb_o			(dwb_stb_o),
      .dwb_tag_o			(dwb_tag_o),
      .dwb_wre_o			(dwb_wre_o),
      .iwb_adr_o			(iwb_adr_o[AEMB_IWB-1:2]),
      .iwb_cyc_o			(iwb_cyc_o),
      .iwb_sel_o			(iwb_sel_o[3:0]),
      .iwb_stb_o			(iwb_stb_o),
      .iwb_tag_o			(iwb_tag_o),
      .iwb_wre_o			(iwb_wre_o),
      .xwb_adr_o			(xwb_adr_o[AEMB_XWB-1:2]),
      .xwb_cyc_o			(xwb_cyc_o),
      .xwb_dat_o			(xwb_dat_o[31:0]),
      .xwb_sel_o			(xwb_sel_o[3:0]),
      .xwb_stb_o			(xwb_stb_o),
      .xwb_tag_o			(xwb_tag_o),
      .xwb_wre_o			(xwb_wre_o),
      // Inputs
      .dwb_ack_i			(dwb_ack_i),
      .dwb_dat_i			(dwb_dat_i[31:0]),
      .iwb_ack_i			(iwb_ack_i),
      .iwb_dat_i			(iwb_dat_i[31:0]),
      .sys_clk_i			(sys_clk_i),
      .sys_ena_i			(sys_ena_i),
      .sys_int_i			(sys_int_i),
      .sys_rst_i			(sys_rst_i),
      .xwb_ack_i			(xwb_ack_i),
      .xwb_dat_i			(xwb_dat_i[31:0]));   

endmodule // edk62

// Local Variables:
// verilog-library-directories:("." "../../rtl/verilog/")
// verilog-library-files:("")
// End:
