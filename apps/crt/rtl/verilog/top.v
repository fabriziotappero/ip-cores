//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "top.v"                                           ////
////                                                              ////
////  This file is part of the PCI bridge sample aplication       ////
////  project (CRT controller).                                   ////
////  http://www.opencores.org/cores/pci/                         ////
////                                                              ////
////  Author(s):                                                  ////
////      - Miha Dolenc (mihad@opencores.org)                     ////
////                                                              ////
////  All additional information is avaliable in the README       ////
////  file.                                                       ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Miha Dolenc, mihad@opencores.org          ////
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
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2002/09/30 16:03:06  mihad
// Added meta flop module for easier meta stable FF identification during synthesis
//
// Revision 1.2  2002/02/01 15:24:46  mihad
// Repaired a few bugs, updated specification, added test bench files and design document
//
// Revision 1.1.1.1  2001/10/02 15:33:33  mihad
// New project directory structure
//
//

// This top module is used for simulation and synthesys of CRT controller
// sample aplication.

module TOP
(
    CLK,
    RST,
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
    AD0,
    AD1,
    AD2,
    AD3,
    AD4,
    AD5,
    AD6,
    AD7,
    AD8,
    AD9,
    AD10,
    AD11,
    AD12,
    AD13,
    AD14,
    AD15,
    AD16,
    AD17,
    AD18,
    AD19,
    AD20,
    AD21,
    AD22,
    AD23,
    AD24,
    AD25,
    AD26,
    AD27,
    AD28,
    AD29,
    AD30,
    AD31,
    CBE0,
    CBE1,
    CBE2,
    CBE3,

/*    CLK_I,
    RST_I,
    RST_O,
    INT_I,
    INT_O,

    // WISHBONE slave interface
    ADR_I,
    SDAT_I,
    SDAT_O,
    SEL_I,
    CYC_I,
    STB_I,
    WE_I,
    CAB_I,
    ACK_O,
    RTY_O,
    ERR_O,

    // WISHBONE master interface
    ADR_O,
    MDAT_I,
    MDAT_O,
    SEL_O,
    CYC_O,
    STB_O,
    WE_O,
    CAB_O,
    ACK_I,
    RTY_I,
    ERR_I    */

    CRT_CLK,
    HSYNC,
    VSYNC,

    RGB4,
    RGB5,
    RGB6,
    RGB7,
    RGB8,
    RGB9,
    RGB10,
    RGB11,
    RGB12,
    RGB13,
    RGB14,
    RGB15,
    
    LED
);

input           CLK ;
inout           AD0,
                AD1,
                AD2,
                AD3,
                AD4,
                AD5,
                AD6,
                AD7,
                AD8,
                AD9,
                AD10,
                AD11,
                AD12,
                AD13,
                AD14,
                AD15,
                AD16,
                AD17,
                AD18,
                AD19,
                AD20,
                AD21,
                AD22,
                AD23,
                AD24,
                AD25,
                AD26,
                AD27,
                AD28,
                AD29,
                AD30,
                AD31 ;

inout           CBE0,
                CBE1,
                CBE2,
                CBE3 ;

inout           RST ;
inout           INTA ;
output          REQ ;
input           GNT ;
inout           FRAME ;
inout           IRDY ;
input           IDSEL ;
inout           DEVSEL ;
inout           TRDY ;
inout           STOP ;
inout           PAR ;
inout           PERR ;
output          SERR ;

input           CRT_CLK ;
// CRT outputs
output          HSYNC ;
output          VSYNC ;
output          RGB4,
                RGB5,
                RGB6,
                RGB7,
                RGB8,
                RGB9,
                RGB10,
                RGB11,
                RGB12,
                RGB13,
                RGB14,
                RGB15 ;
output			LED ;

// WISHBONE system signals
wire    RST_I = 1'b0 ;
wire    RST_O ;
wire    INT_I = 1'b0 ;
wire    INT_O ;

wire [15:0] rgb_int ;
// WISHBONE slave interface
wire    [31:0]  ADR_I ;
wire    [31:0]  SDAT_I ;
wire    [31:0]  SDAT_O ;
wire    [3:0]   SEL_I ;
wire            CYC_I ;
wire            STB_I ;
wire            WE_I  ;
wire            CAB_I ;
wire            ACK_O ;
wire            RTY_O ;
wire            ERR_O ;

// WISHBONE master interface
wire    [31:0]  ADR_O ;
wire    [31:0]  MDAT_I ;
wire    [31:0]  MDAT_O ;
wire    [3:0]   SEL_O ;
wire            CYC_O ;
wire            STB_O ;
wire            WE_O  ;
wire            CAB_O ;
wire            ACK_I ;
wire            RTY_I ;
wire            ERR_I ;

wire    [31:0]  AD_out ;
wire    [31:0]  AD_en ;


wire    [31:0]  AD_in = 
{
    AD31,
    AD30,
    AD29,
    AD28,
    AD27,
    AD26,
    AD25,
    AD24,
    AD23,
    AD22,
    AD21,
    AD20,
    AD19,
    AD18,
    AD17,
    AD16,
    AD15,
    AD14,
    AD13,
    AD12,
    AD11,
    AD10,
    AD9,
    AD8,
    AD7,
    AD6,
    AD5,
    AD4,
    AD3,
    AD2,
    AD1,
    AD0
} ;

wire    [3:0]   CBE_in = 
{
    CBE3,
    CBE2,
    CBE1,
    CBE0
} ;

wire    [3:0]   CBE_out ;
wire    [3:0]   CBE_en ;



wire            RST_in = RST ;
wire            RST_out ;
wire            RST_en ;

wire            INTA_in = INTA ;
wire            INTA_en ;
wire            INTA_out ;

wire            REQ_en ;
wire            REQ_out ;

wire            FRAME_in = FRAME ;
wire            FRAME_out ;
wire            FRAME_en ;

wire            IRDY_in = IRDY ;
wire            IRDY_out ;
wire            IRDY_en ;

wire            DEVSEL_in = DEVSEL ;
wire            DEVSEL_out ;
wire            DEVSEL_en ;

wire            TRDY_in = TRDY ;
wire            TRDY_out ;
wire            TRDY_en ;

wire            STOP_in = STOP ;
wire            STOP_out ;
wire            STOP_en ;

wire            PAR_in = PAR ;
wire            PAR_out ;
wire            PAR_en ;

wire            PERR_in = PERR ;
wire            PERR_out ;
wire            PERR_en ;

wire            SERR_out ;
wire            SERR_en ;

pci_bridge32 bridge
(
    // WISHBONE system signals
    .wb_clk_i(CRT_CLK),
    .wb_rst_i(RST_I),
    .wb_rst_o(RST_O),
    .wb_int_i(INT_I),
    .wb_int_o(INT_O),

    // WISHBONE slave interface
    .wbs_adr_i(ADR_I),
    .wbs_dat_i(SDAT_I),
    .wbs_dat_o(SDAT_O),
    .wbs_sel_i(SEL_I),
    .wbs_cyc_i(CYC_I),
    .wbs_stb_i(STB_I),
    .wbs_we_i (WE_I),
    .wbs_cab_i(CAB_I),
    .wbs_ack_o(ACK_O),
    .wbs_rty_o(RTY_O),
    .wbs_err_o(ERR_O),

    // WISHBONE master interface
    .wbm_adr_o(ADR_O),
    .wbm_dat_i(MDAT_I),
    .wbm_dat_o(MDAT_O),
    .wbm_sel_o(SEL_O),
    .wbm_cyc_o(CYC_O),
    .wbm_stb_o(STB_O),
    .wbm_we_o (WE_O),
    .wbm_cab_o(CAB_O),
    .wbm_ack_i(ACK_I),
    .wbm_rty_i(RTY_I),
    .wbm_err_i(ERR_I),

    // pci interface - system pins
    .pci_clk_i    ( CLK ),
    .pci_rst_i    ( RST_in ),
    .pci_rst_o    ( RST_out ),
    .pci_inta_i   ( INTA_in ),
    .pci_inta_o   ( INTA_out),
    .pci_rst_oe_o ( RST_en),
    .pci_inta_oe_o( INTA_en ),

    // arbitration pins
    .pci_req_o   ( REQ_out ),
    .pci_req_oe_o( REQ_en ),
                  
    .pci_gnt_i   ( GNT ),

    // protocol pins
    .pci_frame_i     ( FRAME_in),
    .pci_frame_o     ( FRAME_out ),
                     
    .pci_frame_oe_o  ( FRAME_en ),
    .pci_irdy_oe_o   ( IRDY_en ),
    .pci_devsel_oe_o ( DEVSEL_en ),
    .pci_trdy_oe_o   ( TRDY_en ),
    .pci_stop_oe_o   ( STOP_en ),
    .pci_ad_oe_o     ( AD_en ),
    .pci_cbe_oe_o    ( CBE_en) ,
                     
    .pci_irdy_i      ( IRDY_in ),
    .pci_irdy_o      ( IRDY_out ),
                     
    .pci_idsel_i     ( IDSEL ),
                     
    .pci_devsel_i    ( DEVSEL_in ),
    .pci_devsel_o    ( DEVSEL_out ),
                     
    .pci_trdy_i      ( TRDY_in ),
    .pci_trdy_o      ( TRDY_out ),
                     
    .pci_stop_i      ( STOP_in ),
    .pci_stop_o      ( STOP_out ),

    // data transfer pins
    .pci_ad_i (AD_in),
    .pci_ad_o (AD_out),
               
    .pci_cbe_i( CBE_in ),
    .pci_cbe_o( CBE_out ),

    // parity generation and checking pins
    .pci_par_i    ( PAR_in ),
    .pci_par_o    ( PAR_out ),
    .pci_par_oe_o ( PAR_en ),
                   
    .pci_perr_i   ( PERR_in ),
    .pci_perr_o   ( PERR_out ),
    .pci_perr_oe_o( PERR_en ),

    // system error pin
    .pci_serr_o   ( SERR_out ),
    .pci_serr_oe_o( SERR_en )
);

// PCI IO buffers instantiation
bufif0 AD_buf0   ( AD0,  AD_out[0], AD_en[0]) ;
bufif0 AD_buf1   ( AD1,  AD_out[1], AD_en[1]) ;
bufif0 AD_buf2   ( AD2,  AD_out[2], AD_en[2]) ;
bufif0 AD_buf3   ( AD3,  AD_out[3], AD_en[3]) ;
bufif0 AD_buf4   ( AD4,  AD_out[4], AD_en[4]) ;
bufif0 AD_buf5   ( AD5,  AD_out[5], AD_en[5]) ;
bufif0 AD_buf6   ( AD6,  AD_out[6], AD_en[6]) ;
bufif0 AD_buf7   ( AD7,  AD_out[7], AD_en[7]) ;
bufif0 AD_buf8   ( AD8,  AD_out[8], AD_en[8]) ;
bufif0 AD_buf9   ( AD9,  AD_out[9], AD_en[9]) ;
bufif0 AD_buf10  ( AD10, AD_out[10],AD_en[10] ) ;
bufif0 AD_buf11  ( AD11, AD_out[11],AD_en[11] ) ;
bufif0 AD_buf12  ( AD12, AD_out[12],AD_en[12] ) ;
bufif0 AD_buf13  ( AD13, AD_out[13],AD_en[13] ) ;
bufif0 AD_buf14  ( AD14, AD_out[14],AD_en[14] ) ;
bufif0 AD_buf15  ( AD15, AD_out[15],AD_en[15] ) ;
bufif0 AD_buf16  ( AD16, AD_out[16],AD_en[16] ) ;
bufif0 AD_buf17  ( AD17, AD_out[17],AD_en[17] ) ;
bufif0 AD_buf18  ( AD18, AD_out[18],AD_en[18] ) ;
bufif0 AD_buf19  ( AD19, AD_out[19],AD_en[19] ) ;
bufif0 AD_buf20  ( AD20, AD_out[20],AD_en[20] ) ;
bufif0 AD_buf21  ( AD21, AD_out[21],AD_en[21] ) ;
bufif0 AD_buf22  ( AD22, AD_out[22],AD_en[22] ) ;
bufif0 AD_buf23  ( AD23, AD_out[23],AD_en[23] ) ;
bufif0 AD_buf24  ( AD24, AD_out[24],AD_en[24] ) ;
bufif0 AD_buf25  ( AD25, AD_out[25],AD_en[25] ) ;
bufif0 AD_buf26  ( AD26, AD_out[26],AD_en[26] ) ;
bufif0 AD_buf27  ( AD27, AD_out[27],AD_en[27] ) ;
bufif0 AD_buf28  ( AD28, AD_out[28],AD_en[28] ) ;
bufif0 AD_buf29  ( AD29, AD_out[29],AD_en[29] ) ;
bufif0 AD_buf30  ( AD30, AD_out[30],AD_en[30] ) ;
bufif0 AD_buf31  ( AD31, AD_out[31],AD_en[31] ) ;

bufif0 CBE_buf0 ( CBE0, CBE_out[0], CBE_en[0] ) ;
bufif0 CBE_buf1 ( CBE1, CBE_out[1], CBE_en[1] ) ;
bufif0 CBE_buf2 ( CBE2, CBE_out[2], CBE_en[2] ) ;
bufif0 CBE_buf3 ( CBE3, CBE_out[3], CBE_en[3] ) ;

bufif0 FRAME_buf    ( FRAME, FRAME_out, FRAME_en ) ;
bufif0 IRDY_buf     ( IRDY, IRDY_out, IRDY_en ) ;
bufif0 DEVSEL_buf   ( DEVSEL, DEVSEL_out, DEVSEL_en ) ;
bufif0 TRDY_buf     ( TRDY, TRDY_out, TRDY_en ) ;
bufif0 STOP_buf     ( STOP, STOP_out, STOP_en ) ;

bufif0 RST_buf      ( RST, RST_out, RST_en ) ;
bufif0 INTA_buf     ( INTA, INTA_out, INTA_en) ;
bufif0 REQ_buf      ( REQ, REQ_out, REQ_en ) ;
bufif0 PAR_buf      ( PAR, PAR_out, PAR_en ) ;
bufif0 PERR_buf     ( PERR, PERR_out, PERR_en ) ;
bufif0 SERR_buf     ( SERR, SERR_out, SERR_en ) ;

wire crt_hsync ;
wire crt_vsync ;

// CRT controler instance
ssvga_top CRT
(
	// Clock and reset
	.wb_clk_i(CRT_CLK),
    .wb_rst_i(RST_O),

	// WISHBONE Master I/F
	.wbm_cyc_o  (CYC_I),
    .wbm_stb_o  (STB_I),
    .wbm_sel_o  (SEL_I),
    .wbm_we_o   (WE_I),
	.wbm_adr_o  (ADR_I),
    .wbm_dat_o  (SDAT_I),
    .wbm_cab_o  (CAB_I),
	.wbm_dat_i  (SDAT_O),
    .wbm_ack_i  (ACK_O),
    .wbm_err_i  (ERR_O),
    .wbm_rty_i  (RTY_O),

	// WISHBONE Slave I/F
	.wbs_cyc_i  (CYC_O),
    .wbs_stb_i  (STB_O),
    .wbs_sel_i  (SEL_O),
    .wbs_we_i   (WE_O),
	.wbs_adr_i  (ADR_O),
    .wbs_dat_i  (MDAT_O),
    .wbs_cab_i  (CAB_O),
	.wbs_dat_o  (MDAT_I),
    .wbs_ack_o  (ACK_I),
    .wbs_err_o  (ERR_I),
    .wbs_rty_o  (RTY_I),

	// Signals to VGA display
	.pad_hsync_o    (crt_hsync),
    .pad_vsync_o    (crt_vsync),
    .pad_rgb_o      (rgb_int),
    .led_o			(LED)
);

CRTC_IOB crt_out_reg
(
    .reset_in(RST_O),
    .clk_in(CRT_CLK),
    .hsync_in(crt_hsync),
    .vsync_in(crt_vsync),
    .rgb_in(rgb_int[15:4]),
    .hsync_out(HSYNC),
    .vsync_out(VSYNC),
    .rgb_out({RGB15, RGB14, RGB13, RGB12, RGB11, RGB10, RGB9, RGB8, RGB7, RGB6, RGB5, RGB4})
) ;

endmodule
