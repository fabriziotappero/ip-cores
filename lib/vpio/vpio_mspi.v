/* $Id: fasm_sparam.v,v 1.2 2008/06/05 20:55:15 sybreon Exp $
**
** VIRTUAL PERIPHERAL INPUT/OUTPUT LIBRARY
** Copyright (C) 2004-2009 Shawn Tan <shawn.tan@aeste.net>
** All rights reserved.
** 
** LITE is free software: you can redistribute it and/or modify it
** under the terms of the GNU Lesser General Public License as
** published by the Free Software Foundation, either version 3 of the
** License, or (at your option) any later version.
**
** LITE is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
** Public License for more details.
**
** You should have received a copy of the GNU Lesser General Public
** License along with FASM. If not, see <http:**www.gnu.org/licenses/>.
*/
/*
 * MASTER SERIAL PERIPHERAL INTERFACE
 */

module vpio_mspi (/*AUTOARG*/
   // Outputs
   wb_dat_o, wb_ack_o, int_o, mspi_dat_o, mspi_clk_o,
   // Inputs
   wb_dat_i, wb_adr_i, wb_sel_i, wb_wre_i, wb_stb_i, wb_clk_i,
   wb_rst_i, mspi_dat_i
   );

   // WISHBONE SLAVE INTERFACE
   output [7:0] wb_dat_o;  
   output 	wb_ack_o;
   output 	int_o;   
   input [7:0] 	wb_dat_i;
   input 	wb_adr_i;
   input 	wb_sel_i,
		wb_wre_i,
		wb_stb_i,
		//wb_cyc_i,
		wb_clk_i,
		wb_rst_i;   
   
   // MASTER SPI INTERFACE
   output 	mspi_dat_o, // MOSI
		//mspi_sel_o, // SSEL
		mspi_clk_o; // SCLK
   input 	mspi_dat_i; // MISO

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			int_o;
   reg			mspi_clk_o;
   reg			wb_ack_o;
   reg [7:0]		wb_dat_o;
   // End of automatics

   localparam [1:0] // synopsys enum state FSM
     FSM_IDLE = 2'o0,
     FSM_PHA0 = 2'o1,
     FSM_PHA1 = 2'o2,
     FSM_NULL = 2'o3;
   
   reg [1:0] 		// synopsys enum state FSM		
			rFSM, rFSM_;   
   
   reg [1:0] 		rSPIC_MODE, rSPIC_DIVI;
   reg 			rSPIC_SPIE, rSPIC_SPEN;
   reg 			rSPIC_SPIF, rSPIC_WCOL;

   reg 			rFULL;   
   reg [7:0] 		rSPID, rTBUF;   
   reg [2:0] 		rBCNT;
   
   wire [7:0] 		rSPIC = {rSPIC_SPIE, // RW-SPI interrupt enable
				 rSPIC_SPEN, // RW_SPI enable
				 rSPIC_SPIF, // RO-flag
				 rSPIC_WCOL, // RO-write collision
				 rSPIC_MODE, // RW-SPI mode
				 rSPIC_DIVI}; // RW-SPI clock divider

   wire 		CPOL = rSPIC[3]; // CPOL
   wire 		CPHA = rSPIC[2]; // CPHA
   wire [1:0] 		CDIV = rSPIC[1:0]; // CDIV
   wire 		SPIE = rSPIC[7];
   wire 		SPEN = rSPIC[6];   
   
   wire 		wb_stb = wb_sel_i & wb_stb_i;   
   wire 		wb_wre = wb_sel_i & wb_stb_i & wb_wre_i;   
   
   // WISHBONE INTERFACE - Synchronous Single Transfers
   always @(posedge wb_clk_i)
     if (wb_rst_i) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rSPIC_DIVI <= 2'h0;
	rSPIC_MODE <= 2'h0;
	rSPIC_SPEN <= 1'h0;
	rSPIC_SPIE <= 1'h0;
	rSPID <= 8'h0;
	// End of automatics
     end else if (wb_wre) begin
	if (!wb_adr_i) {rSPIC_SPIE,
			rSPIC_SPEN,
			rSPIC_MODE,
			rSPIC_DIVI} = #1 {wb_dat_i[7:6],
					  wb_dat_i[3:0]};
	if (wb_adr_i) rSPID <= #1 wb_dat_i;
     end

   always @(posedge wb_clk_i)
     if (wb_rst_i) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	wb_ack_o <= 1'h0;
	wb_dat_o <= 8'h0;
	// End of automatics
     end else if (wb_stb) begin
	
	wb_ack_o <= !wb_ack_o & wb_stb_i;
	
	case (wb_adr_i)
	  1'b0: wb_dat_o <= rSPIC;	  
	  1'b1: wb_dat_o <= rSPID;
	endcase // case (wb_adr_i)
     end

   // CLOCK - Loadable Counter
   reg [3:0] rFCNT;
   wire      wena = ~|rFCNT;   
   always @(posedge wb_clk_i)
     if (wb_rst_i) begin // reset
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	rFCNT <= 4'h0;
	// End of automatics
     end else if (rFSM == FSM_IDLE) begin
	case (CDIV)
	  2'o0: rFCNT <= #1 4'h0; // 2  -- original HC11
	  2'o1: rFCNT <= #1 4'h1; // 4  -- original HC11
	  2'o2: rFCNT <= #1 4'h7; // 16 -- original HC11
	  2'o3: rFCNT <= #1 4'hF; // 32 -- original HC11
	endcase // case (CDIV)
     end else if (|rFCNT) begin
	rFCNT <= #1 rFCNT - 1;	
     end
   
   // STATE MACHINE
   wire wbit = ~|rBCNT;
   assign mspi_dat_o = rTBUF[7];
   
   always @(posedge wb_clk_i)
     if (wb_rst_i) begin
	rFSM <= FSM_IDLE;	
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	mspi_clk_o <= 1'h0;
	rBCNT <= 3'h0;
	rFULL <= 1'h0;
	rTBUF <= 8'h0;
	// End of automatics
     end else begin
	
	// BIT COUNT
	case (rFSM)
	  FSM_IDLE: rBCNT <= #1 3'o7;
	  FSM_PHA1: rBCNT <= #1 rBCNT - 1;	  
	  default: rBCNT <= #1 rBCNT;	  
	endcase // case (rFSM)

	// MOSI/MISO
	case (rFSM)
	  FSM_IDLE: rTBUF <= #1 rSPID;
	  FSM_PHA1: rTBUF <= #1 {rTBUF[6:0], mspi_dat_i};	  
	  default: rTBUF <= #1 rTBUF;	  
	endcase // case (rFSM)

	// SCLK
	case (rFSM)
	  FSM_IDLE: mspi_clk_o <= #1 CPOL;
	  FSM_PHA0: mspi_clk_o <= #1 (wena) ? ~mspi_clk_o : mspi_clk_o;
	  FSM_PHA1: mspi_clk_o <= #1 (!wena) ? mspi_clk_o : (wbit) ? CPOL : ~mspi_clk_o;
	  /*
	  FSM_PHA1: case ({wena, wbit})
		      2'o3: mspi_clk_o <= #1 CPOL;
		      2'o2: mspi_clk_o <= #1 ~mspi_clk_o;
		      default: mspi_clk_o <= #1 mspi_clk_o;		      
		    endcase // case ({wena, wbit})	  
	   */
	  default: mspi_clk_o <= #1 mspi_clk_o;	  
	endcase // case (rFSM)

	// FULL/WCOL	
	case (rFSM)
	  FSM_IDLE: rFULL <= #1 (wb_wre & wb_adr_i) | rFULL;
	  FSM_NULL: rFULL <= #1 1'b0;	     
	  default: rFULL <= #1 rFULL;	     
	endcase // case (rFSM)

	// STATE
	case (rFSM)
	  FSM_IDLE: rFSM <= #1 (rFULL) ? FSM_PHA0 : FSM_IDLE;
	  FSM_PHA0: rFSM <= #1 (wena) ? FSM_PHA1 : FSM_PHA0;
	  FSM_PHA1: rFSM <= #1 (!wena) ? FSM_PHA1 : (~|rBCNT) ? FSM_IDLE : FSM_PHA0;	  
	  default: rFSM <= #1 FSM_IDLE;	  
	endcase // case (rFSM)
	
     end // else: !if(wb_rst_i)
   
endmodule // vpio_mspi
