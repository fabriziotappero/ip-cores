//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: top_pci_lpc_host.v,v 1.4 2008-07-26 19:15:31 hharte Exp $   ////
////  top_pci_lpc_host.v - Top Level for PCI to LPC Host          ////
////  for the Enterpoint Raggedstone1 PCI Card.  Based on the     ////
////  OpenCores raggedstone project, and uses the OpenCores       ////
////  pci32tlite core.                                            ////
////                                                              ////
////  This file is part of the Wishbone LPC Bridge project        ////
////  http://www.opencores.org/projects/wb_lpc/                   ////
////                                                              ////
////  Author:                                                     ////
////      - Howard M. Harte (hharte@opencores.org)                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Howard M. Harte                           ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module pci_lpc_host
(
    CLK,
    RST, // Active Low
    INTA,
    REQ,
    GNT,
    FRAME,
    IRDY,
    IDSEL,
    DEVSEL,
    TRDY,
    STOP,
    PAR,
    PERR,
    SERR,
    PCI_AD,
    CBE0,
    CBE1,
    CBE2,
    CBE3,

    DISP_SEL,
    DISP_LED,

    LPC_RST,
    LPC_CLK,
    LFRAME,
    LAD,
    LAD_OE,
    LPC_INT,

    LPC_GND,

    PREVENT_STRIPPING_OF_UNUSED_INPUTS
);

input           CLK ;
input           RST ;

inout [31:0]    PCI_AD ;

input           CBE0,
                CBE1,
                CBE2,
                CBE3 ;

output          PAR ;
input           FRAME ;
input           IRDY ;
output          TRDY ;
output          DEVSEL ;
inout           STOP ;
input           IDSEL ;
inout           PERR ;
inout           SERR ;
output          INTA ;
//attribute s: string; -- SAVE NET FLAG
input           REQ ;       // attribute s of PCI_nREQ: signal is "yes"; 
input           GNT ;       // attribute s of PCI_nGNT: signal is "yes"; 
output  [3:0]   DISP_SEL ;
output  [6:0]   DISP_LED ;

output          LPC_RST;
output          LPC_CLK;
output          LFRAME;
inout   [3:0]   LAD;
inout           LPC_INT;
output          LAD_OE;

output  [6:0]   LPC_GND;
assign LPC_GND = 7'b0000000;

output          PREVENT_STRIPPING_OF_UNUSED_INPUTS ;

assign PREVENT_STRIPPING_OF_UNUSED_INPUTS = REQ & GNT;

wire    [2:0]   dma_chan_i = 3'b000; 
wire            dma_tc_i = 1'b0; 
wire            lframe_o; 
wire    [3:0]   lad_i; 
wire    [3:0]   lad_o; 
wire            host_lad_oe;

assign LPC_RST = RST;
assign LAD = (host_lad_oe ? lad_o : 4'bzzzz);
assign LAD_OE = host_lad_oe;
assign LFRAME = ~lframe_o;

wire    [3:0]   CBE_in = 
{
    CBE3,
    CBE2,
    CBE1,
    CBE0
} ;

wire    [24:0]  wb_adr_o;
wire    [31:0]  wb_dat_i;
wire    [31:0]  wb_dat_o;
wire    [3:0]   wb_sel_o;
wire    [1:0]   wb_tga;
wire            wb_we_o;
wire            wb_stb_o;
wire            wb_cyc_o;
wire            wb_ack_i;
wire            wb_rty_i = 1'b0;
wire            wb_err_i = 1'b0;
wire            wb_int_i;

//assign wb_tga = wb_adr_o[17:16];  // I/O Cycle
assign wb_tga = 2'b10;  // Firmware cycle

// Instantiate the pci32tlite module
pci32tLite #(
    .vendorID(16'h10ee),
    .deviceID(16'hf00d),
    .revisionID(8'h01),
    .subsystemID(16'h0),
    .subsystemvID(16'h0),
    .BARS("1BARMEM"),
    .WBSIZE(32),
    .WBENDIAN("LITTLE"))
pci_target (
    .clk33(PCI_CLK), 
    .rst(~RST), 
    .ad(PCI_AD),
    .cbe(CBE_in), 
    .par(PAR), 
    .frame(FRAME), 
    .irdy(IRDY), 
    .trdy(TRDY), 
    .devsel(DEVSEL), 
    .stop(STOP), 
    .idsel(IDSEL), 
    .perr(PERR), 
    .serr(SERR), 
    .intb(INTA), 
    .wb_adr_o(wb_adr_o), 
    .wb_dat_i(wb_dat_i), 
    .wb_dat_o(wb_dat_o), 
    .wb_sel_o(wb_sel_o), 
    .wb_we_o(wb_we_o), 
    .wb_stb_o(wb_stb_o), 
    .wb_cyc_o(wb_cyc_o), 
    .wb_ack_i(wb_ack_i), 
    .wb_rty_i(wb_rty_i), 
    .wb_err_i(wb_err_i), 
    .wb_int_i(wb_int_i)
    );

// Instantiate the LPC clock generator.
// The LPC clock is phase shifted by about -3ns to compensate
// for the skew to the LPC slave over the cable.
lpc_clkgen lpc_clkgen (
    .CLKIN_IN(CLK), 
    .RST_IN(~RST), 
    .CLKIN_IBUFG_OUT(PCI_CLK), 
    .CLK0_OUT(LPC_CLK)
    );

wb_lpc_host lpc_host (
    .clk_i(PCI_CLK), 
    .nrst_i(RST), 
    .wbs_adr_i(wb_adr_o), 
    .wbs_dat_o(wb_dat_i), 
    .wbs_dat_i(wb_dat_o), 
    .wbs_sel_i(wb_sel_o), 
    .wbs_tga_i(wb_tga), 
    .wbs_we_i(wb_we_o), 
    .wbs_stb_i(wb_stb_o), 
    .wbs_cyc_i(wb_cyc_o), 
    .wbs_ack_o(wb_ack_i),
    .wbs_err_o(wb_err_i), 	 
    .dma_chan_i(dma_chan_i), 
    .dma_tc_i(dma_tc_i), 
    .lframe_o(lframe_o), 
    .lad_i(LAD), 
    .lad_o(lad_o), 
    .lad_oe(host_lad_oe)
    );

wire         serirq_mode = 1'b0;
wire  [31:0] irq_o;
wire         serirq_i;
wire         serirq_o;
wire         serirq_oe;

assign LPC_INT = (serirq_oe ? serirq_o : 1'bz);
assign serirq_i = LPC_INT;
assign wb_int_i = ~irq_o[1];
// Instantiate the module
serirq_host lpc_serirq_host (
    .clk_i(PCI_CLK), 
    .nrst_i(RST), 
    .serirq_mode_i(serirq_mode), 
    .irq_o(irq_o), 
    .serirq_o(serirq_o), 
    .serirq_i(serirq_i), 
    .serirq_oe(serirq_oe)
    );

// The 7-segment display is write-only from the PCI interface.
// Use some dummy nets for inputs that are ignored.
wire    [31:0] wb2_dat_i;
wire           wb2_ack_i;
wire           wb2_err_i;
wire           wb2_int_i;

// Instantiate the 7-Segment module on the host
wb_7seg seven_seg0 (
    .clk_i(PCI_CLK), 
    .nrst_i(RST), 
    .wb_adr_i(wb_adr_o), 
    .wb_dat_o(wb2_dat_i), 
    .wb_dat_i(wb_dat_o), 
    .wb_sel_i(wb_sel_o), 
    .wb_we_i(wb_we_o), 
    .wb_stb_i(wb_stb_o), 
    .wb_cyc_i(wb_cyc_o), 
    .wb_ack_o(wb2_ack_i), 
    .wb_err_o(wb2_err_i), 
    .wb_int_o(wb2_int_i), 
    .DISP_SEL(DISP_SEL), 
    .DISP_LED(DISP_LED)
    );
endmodule


// FPGA-specific: use a Xilinx DCM Block to deskew the LPC_CLK
module lpc_clkgen(CLKIN_IN, 
                  RST_IN, 
                  CLKIN_IBUFG_OUT, 
                  CLK0_OUT);

    input CLKIN_IN;
    input RST_IN;
    output CLKIN_IBUFG_OUT;
    output CLK0_OUT;
   
    wire CLKFB_IN;
    wire CLKIN_IBUFG;
    wire CLK0_BUF;
    wire GND_BIT;
   
    assign GND_BIT = 0;
    assign CLKIN_IBUFG_OUT = CLKIN_IBUFG;
    assign CLK0_OUT = CLKFB_IN;
    IBUFG CLKIN_IBUFG_INST (.I(CLKIN_IN), 
                            .O(CLKIN_IBUFG));
    BUFG CLK0_BUFG_INST (.I(CLK0_BUF), 
                         .O(CLKFB_IN));
    DCM DCM_INST (.CLKFB(CLKFB_IN), 
                  .CLKIN(CLKIN_IBUFG), 
                  .DSSEN(GND_BIT), 
                  .PSCLK(GND_BIT), 
                  .PSEN(GND_BIT), 
                  .PSINCDEC(GND_BIT), 
                  .RST(RST_IN), 
                  .CLKDV(), 
                  .CLKFX(), 
                  .CLKFX180(), 
                  .CLK0(CLK0_BUF), 
                  .CLK2X(), 
                  .CLK2X180(), 
                  .CLK90(), 
                  .CLK180(), 
                  .CLK270(), 
                  .LOCKED(), 
                  .PSDONE(), 
                  .STATUS());
    defparam DCM_INST.CLK_FEEDBACK = "1X";
    defparam DCM_INST.CLKDV_DIVIDE = 2.0;
    defparam DCM_INST.CLKFX_DIVIDE = 1;
    defparam DCM_INST.CLKFX_MULTIPLY = 4;
    defparam DCM_INST.CLKIN_DIVIDE_BY_2 = "FALSE";
    defparam DCM_INST.CLKIN_PERIOD = 30.000;
    defparam DCM_INST.CLKOUT_PHASE_SHIFT = "FIXED";
    defparam DCM_INST.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS";
    defparam DCM_INST.DFS_FREQUENCY_MODE = "LOW";
    defparam DCM_INST.DLL_FREQUENCY_MODE = "LOW";
    defparam DCM_INST.DUTY_CYCLE_CORRECTION = "TRUE";
    defparam DCM_INST.FACTORY_JF = 16'h8080;
    defparam DCM_INST.PHASE_SHIFT = -18;
    defparam DCM_INST.STARTUP_WAIT = "FALSE";
endmodule
// End of FPGA-specific
