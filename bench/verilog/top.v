//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "top.v"                                           ////
////                                                              ////
////  This file is part of the "PCI bridge" project               ////
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
// Revision 1.2  2004/01/24 11:54:16  mihad
// Update! SPOCI Implemented!
//
// Revision 1.1  2003/12/15 12:21:29  mihad
// Moved top.v to bench directory. Removed unneeded meta_flop,
// modified files list files accordingly.
//
// Revision 1.12  2003/10/17 09:11:52  markom
// mbist signals updated according to newest convention
//
// Revision 1.11  2003/08/21 20:49:03  tadejm
// Added signals for WB Master B3.
//
// Revision 1.10  2003/08/03 18:05:06  mihad
// Added limited WISHBONE B3 support for WISHBONE Slave Unit.
// Doesn't support full speed bursts yet.
//
// Revision 1.9  2003/01/27 16:49:31  mihad
// Changed module and file names. Updated scripts accordingly. FIFO synchronizations changed.
//
// Revision 1.8  2002/10/18 03:36:37  tadejm
// Changed wrong signal name mbist_sen into mbist_ctrl_i.
//
// Revision 1.7  2002/10/17 22:49:22  tadejm
// Changed BIST signals for RAMs.
//
// Revision 1.6  2002/10/11 10:09:01  mihad
// Added additional testcase and changed rst name in BIST to trst
//
// Revision 1.5  2002/10/08 17:17:06  mihad
// Added BIST signals for RAMs.
//
// Revision 1.4  2002/03/21 07:36:04  mihad
// Files updated with missing includes, resolved some race conditions in test bench
//
// Revision 1.3  2002/02/01 15:25:13  mihad
// Repaired a few bugs, updated specification, added test bench files and design document
//
// Revision 1.2  2001/10/05 08:14:30  mihad
// Updated all files with inclusion of timescale file for simulation purposes.
//
// Revision 1.1.1.1  2001/10/02 15:33:47  mihad
// New project directory structure
//
//

// This top module is primarly used for testing plain PCI bridge core without any other cores attached.
// Other cores can be included in this top module and appropriate changes incorporated for overall design

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "pci_constants.v"

module TOP
(
    CLK,
    AD,
    CBE,
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

    CLK_I,
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
    CTI_I,
    BTE_I,
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
    CTI_O,
    BTE_O,
    ACK_I,
    RTY_I,
    ERR_I

`ifdef PCI_BIST
    ,
    // debug chain signals
    mbist_si_i,       // bist scan serial in
    mbist_so_o,       // bist scan serial out
    mbist_ctrl_i        // bist chain shift control
`endif

`ifdef PCI_CPCI_HS_IMPLEMENT
    ,
    // Compact PCI Hot Swap signals
    ENUM    ,
    LED     ,
    ES
`endif

`ifdef PCI_SPOCI
    ,
    SCL ,
    SDA
`endif
);

`ifdef ACTIVE_LOW_OE
parameter oe_act = 1'b0 ;
`endif

`ifdef ACTIVE_HIGH_OE
parameter oe_act = 1'b1 ;
`endif

input           CLK ;
inout   [31:0]  AD ;
inout   [3:0]   CBE ;

`ifdef HOST
output          RST ;
`endif

`ifdef GUEST
input           RST ;
`endif

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

// WISHBONE system signals
input   CLK_I ;
input   RST_I ;
output  RST_O ;
input   INT_I ;
output  INT_O ;

// WISHBONE slave interface
input   [31:0]  ADR_I ;
input   [31:0]  SDAT_I ;
output  [31:0]  SDAT_O ;
input   [3:0]   SEL_I ;
input           CYC_I ;
input           STB_I ;
input           WE_I  ;
input           CAB_I ;
input   [ 2:0]  CTI_I ;
input   [ 1:0]  BTE_I ;
output          ACK_O ;
output          RTY_O ;
output          ERR_O ;

// WISHBONE master interface
output  [31:0]  ADR_O ;
input   [31:0]  MDAT_I ;
output  [31:0]  MDAT_O ;
output  [3:0]   SEL_O ;
output          CYC_O ;
output          STB_O ;
output          WE_O  ;
output  [2:0]   CTI_O ;
output  [1:0]   BTE_O ;
input           ACK_I ;
input           RTY_I ;
input           ERR_I ;

`ifdef PCI_BIST
/*-----------------------------------------------------
BIST debug chain port signals
-----------------------------------------------------*/
input   mbist_si_i;       // bist scan serial in
output  mbist_so_o;       // bist scan serial out
input [`PCI_MBIST_CTRL_WIDTH - 1:0] mbist_ctrl_i;       // bist chain shift control
`endif

`ifdef PCI_CPCI_HS_IMPLEMENT
output  ENUM    ;
output  LED     ;
input   ES      ;

wire ENUM_en    ;
wire ENUM_out   ;
wire LED_out    ;
wire LED_en     ;
`endif

`ifdef PCI_SPOCI
output  SCL ;
inout   SDA ;

wire    SCL_out ;
wire    SCL_en  ;
wire    SDA_out ;
wire    SDA_en  ;
`endif

wire    [31:0]  AD_out ;
wire    [31:0]  AD_en ;

wire    [31:0]  AD_in   ;
assign AD_in[0 ] = (AD_en[0 ] == oe_act) ? 1'bx : AD[0 ] ;
assign AD_in[1 ] = (AD_en[1 ] == oe_act) ? 1'bx : AD[1 ] ;
assign AD_in[2 ] = (AD_en[2 ] == oe_act) ? 1'bx : AD[2 ] ;
assign AD_in[3 ] = (AD_en[3 ] == oe_act) ? 1'bx : AD[3 ] ;
assign AD_in[4 ] = (AD_en[4 ] == oe_act) ? 1'bx : AD[4 ] ;
assign AD_in[5 ] = (AD_en[5 ] == oe_act) ? 1'bx : AD[5 ] ;
assign AD_in[6 ] = (AD_en[6 ] == oe_act) ? 1'bx : AD[6 ] ;
assign AD_in[7 ] = (AD_en[7 ] == oe_act) ? 1'bx : AD[7 ] ;
assign AD_in[8 ] = (AD_en[8 ] == oe_act) ? 1'bx : AD[8 ] ;
assign AD_in[9 ] = (AD_en[9 ] == oe_act) ? 1'bx : AD[9 ] ;
assign AD_in[10] = (AD_en[10] == oe_act) ? 1'bx : AD[10] ;
assign AD_in[11] = (AD_en[11] == oe_act) ? 1'bx : AD[11] ;
assign AD_in[12] = (AD_en[12] == oe_act) ? 1'bx : AD[12] ;
assign AD_in[13] = (AD_en[13] == oe_act) ? 1'bx : AD[13] ;
assign AD_in[14] = (AD_en[14] == oe_act) ? 1'bx : AD[14] ;
assign AD_in[15] = (AD_en[15] == oe_act) ? 1'bx : AD[15] ;
assign AD_in[16] = (AD_en[16] == oe_act) ? 1'bx : AD[16] ;
assign AD_in[17] = (AD_en[17] == oe_act) ? 1'bx : AD[17] ;
assign AD_in[18] = (AD_en[18] == oe_act) ? 1'bx : AD[18] ;
assign AD_in[19] = (AD_en[19] == oe_act) ? 1'bx : AD[19] ;
assign AD_in[20] = (AD_en[20] == oe_act) ? 1'bx : AD[20] ;
assign AD_in[21] = (AD_en[21] == oe_act) ? 1'bx : AD[21] ;
assign AD_in[22] = (AD_en[22] == oe_act) ? 1'bx : AD[22] ;
assign AD_in[23] = (AD_en[23] == oe_act) ? 1'bx : AD[23] ;
assign AD_in[24] = (AD_en[24] == oe_act) ? 1'bx : AD[24] ;
assign AD_in[25] = (AD_en[25] == oe_act) ? 1'bx : AD[25] ;
assign AD_in[26] = (AD_en[26] == oe_act) ? 1'bx : AD[26] ;
assign AD_in[27] = (AD_en[27] == oe_act) ? 1'bx : AD[27] ;
assign AD_in[28] = (AD_en[28] == oe_act) ? 1'bx : AD[28] ;
assign AD_in[29] = (AD_en[29] == oe_act) ? 1'bx : AD[29] ;
assign AD_in[30] = (AD_en[30] == oe_act) ? 1'bx : AD[30] ;
assign AD_in[31] = (AD_en[31] == oe_act) ? 1'bx : AD[31] ;

wire    [3:0]   CBE_out ;
wire    [3:0]   CBE_en ;
wire    [3:0]   CBE_in  ;
assign CBE_in[3] = (CBE_en[3] == oe_act) ? 1'bx : CBE[3] ;
assign CBE_in[2] = (CBE_en[2] == oe_act) ? 1'bx : CBE[2] ;
assign CBE_in[1] = (CBE_en[1] == oe_act) ? 1'bx : CBE[1] ;
assign CBE_in[0] = (CBE_en[0] == oe_act) ? 1'bx : CBE[0] ;

`ifdef HOST
wire            RST_in = 1'bx;
`else
wire            RST_in = RST ;
`endif
wire            RST_out ;
wire            RST_en ;

wire            INTA_en ;
wire            INTA_out ;
wire            INTA_in = (INTA_en == oe_act) ? 1'bx : INTA  ;

wire            REQ_en ;
wire            REQ_out ;

wire            FRAME_out ;
wire            FRAME_en ;
wire            FRAME_in = (FRAME_en == oe_act) ? 1'bx : FRAME ;

wire            IRDY_out ;
wire            IRDY_en ;
wire            IRDY_in = (IRDY_en == oe_act) ? 1'bx : IRDY ;

wire            DEVSEL_out ;
wire            DEVSEL_en ;
wire            DEVSEL_in = (DEVSEL_en == oe_act) ? 1'bx : DEVSEL ;

wire            TRDY_out ;
wire            TRDY_en ;
wire            TRDY_in = (TRDY_en == oe_act) ? 1'bx : TRDY ;

wire            STOP_out ;
wire            STOP_en ;
wire            STOP_in = (STOP_en == oe_act) ? 1'bx : STOP ;

wire            PAR_out ;
wire            PAR_en ;
wire            PAR_in = (PAR_en == oe_act) ? 1'bx : PAR ;

wire            PERR_out ;
wire            PERR_en ;
wire            PERR_in = (PERR_en == oe_act) ? 1'bx : PERR ;

wire            SERR_out ;
wire            SERR_en ;

pci_bridge32 bridge
(
    // WISHBONE system signals
    .wb_clk_i(CLK_I),
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

`ifdef PCI_WB_REV_B3

    .wbs_cti_i(CTI_I),
    .wbs_bte_i(BTE_I),

`else

    .wbs_cab_i(CAB_I),

`endif

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
    .wbm_cti_o(CTI_O),
    .wbm_bte_o(BTE_O),
    .wbm_ack_i(ACK_I),
    .wbm_rty_i(RTY_I),
    .wbm_err_i(ERR_I),

    // pci interface - system pins
    .pci_clk_i    (CLK),
    .pci_rst_i    ( RST_in ),
    .pci_rst_o    ( RST_out ),
    .pci_inta_i   ( INTA_in ),
    .pci_inta_o   ( INTA_out),
    .pci_rst_oe_o ( RST_en),
    .pci_inta_oe_o(INTA_en),

    // arbitration pins
    .pci_req_o   ( REQ_out ),
    .pci_req_oe_o( REQ_en ),

    .pci_gnt_i   ( GNT ),

    // protocol pins
    .pci_frame_i   ( FRAME_in),
    .pci_frame_o   ( FRAME_out ),
                    
    .pci_frame_oe_o( FRAME_en ),
    .pci_irdy_oe_o ( IRDY_en ),
    .pci_devsel_oe_o( DEVSEL_en ),
    .pci_trdy_oe_o ( TRDY_en ),
    .pci_stop_oe_o ( STOP_en ),
    .pci_ad_oe_o   (AD_en),
    .pci_cbe_oe_o  ( CBE_en) ,
                    
    .pci_irdy_i    ( IRDY_in ),
    .pci_irdy_o    ( IRDY_out ),
                    
    .pci_idsel_i   ( IDSEL ),
                    
    .pci_devsel_i  ( DEVSEL_in ),
    .pci_devsel_o  ( DEVSEL_out ),
                    
    .pci_trdy_i    ( TRDY_in ),
    .pci_trdy_o    ( TRDY_out ),
                    
    .pci_stop_i    ( STOP_in ),
    .pci_stop_o    ( STOP_out ),

    // data transfer pins
    .pci_ad_i(AD_in),
    .pci_ad_o(AD_out),
              
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

`ifdef PCI_BIST
    ,
    .mbist_si_i       (mbist_si_i),
    .mbist_so_o       (mbist_so_o),
    .mbist_ctrl_i       (mbist_ctrl_i)
`endif

`ifdef PCI_CPCI_HS_IMPLEMENT
    ,
    // Compact PCI Hot Swap signals
    .pci_cpci_hs_enum_o     (ENUM_out)  ,
    .pci_cpci_hs_enum_oe_o  (ENUM_en)   ,
    .pci_cpci_hs_led_o      (LED_out)   ,
    .pci_cpci_hs_led_oe_o   (LED_en)    ,
    .pci_cpci_hs_es_i       (ES)
`endif

`ifdef PCI_SPOCI
    ,
    // Serial power on configuration interface
    .spoci_scl_o     (SCL_out)  ,
    .spoci_scl_oe_o  (SCL_en)   ,
    .spoci_sda_i     (SDA)      ,
    .spoci_sda_o     (SDA_out)  ,
    .spoci_sda_oe_o  (SDA_en)
`endif
);
   
   
// PCI IO buffers instantiation
`ifdef ACTIVE_LOW_OE

bufif0 AD_buf0   ( AD[0],  AD_out[0], AD_en[0]) ;
bufif0 AD_buf1   ( AD[1],  AD_out[1], AD_en[1]) ;
bufif0 AD_buf2   ( AD[2],  AD_out[2], AD_en[2]) ;
bufif0 AD_buf3   ( AD[3],  AD_out[3], AD_en[3]) ;
bufif0 AD_buf4   ( AD[4],  AD_out[4], AD_en[4]) ;
bufif0 AD_buf5   ( AD[5],  AD_out[5], AD_en[5]) ;
bufif0 AD_buf6   ( AD[6],  AD_out[6], AD_en[6]) ;
bufif0 AD_buf7   ( AD[7],  AD_out[7], AD_en[7]) ;
bufif0 AD_buf8   ( AD[8],  AD_out[8], AD_en[8]) ;
bufif0 AD_buf9   ( AD[9],  AD_out[9], AD_en[9]) ;
bufif0 AD_buf10  ( AD[10], AD_out[10],AD_en[10] ) ;
bufif0 AD_buf11  ( AD[11], AD_out[11],AD_en[11] ) ;
bufif0 AD_buf12  ( AD[12], AD_out[12],AD_en[12] ) ;
bufif0 AD_buf13  ( AD[13], AD_out[13],AD_en[13] ) ;
bufif0 AD_buf14  ( AD[14], AD_out[14],AD_en[14] ) ;
bufif0 AD_buf15  ( AD[15], AD_out[15],AD_en[15] ) ;
bufif0 AD_buf16  ( AD[16], AD_out[16],AD_en[16] ) ;
bufif0 AD_buf17  ( AD[17], AD_out[17],AD_en[17] ) ;
bufif0 AD_buf18  ( AD[18], AD_out[18],AD_en[18] ) ;
bufif0 AD_buf19  ( AD[19], AD_out[19],AD_en[19] ) ;
bufif0 AD_buf20  ( AD[20], AD_out[20],AD_en[20] ) ;
bufif0 AD_buf21  ( AD[21], AD_out[21],AD_en[21] ) ;
bufif0 AD_buf22  ( AD[22], AD_out[22],AD_en[22] ) ;
bufif0 AD_buf23  ( AD[23], AD_out[23],AD_en[23] ) ;
bufif0 AD_buf24  ( AD[24], AD_out[24],AD_en[24] ) ;
bufif0 AD_buf25  ( AD[25], AD_out[25],AD_en[25] ) ;
bufif0 AD_buf26  ( AD[26], AD_out[26],AD_en[26] ) ;
bufif0 AD_buf27  ( AD[27], AD_out[27],AD_en[27] ) ;
bufif0 AD_buf28  ( AD[28], AD_out[28],AD_en[28] ) ;
bufif0 AD_buf29  ( AD[29], AD_out[29],AD_en[29] ) ;
bufif0 AD_buf30  ( AD[30], AD_out[30],AD_en[30] ) ;
bufif0 AD_buf31  ( AD[31], AD_out[31],AD_en[31] ) ;

bufif0 CBE_buf0 ( CBE[0], CBE_out[0], CBE_en[0] ) ;
bufif0 CBE_buf1 ( CBE[1], CBE_out[1], CBE_en[1] ) ;
bufif0 CBE_buf2 ( CBE[2], CBE_out[2], CBE_en[2] ) ;
bufif0 CBE_buf3 ( CBE[3], CBE_out[3], CBE_en[3] ) ;

bufif0 FRAME_buf    ( FRAME, FRAME_out, FRAME_en ) ;
bufif0 IRDY_buf     ( IRDY, IRDY_out, IRDY_en ) ;
bufif0 DEVSEL_buf   ( DEVSEL, DEVSEL_out, DEVSEL_en ) ;
bufif0 TRDY_buf     ( TRDY, TRDY_out, TRDY_en ) ;
bufif0 STOP_buf     ( STOP, STOP_out, STOP_en ) ;

`ifdef HOST
bufif0 RST_buf      ( RST, RST_out, RST_en ) ;
`endif

bufif0 INTA_buf     ( INTA, INTA_out, INTA_en) ;
bufif0 REQ_buf      ( REQ, REQ_out, REQ_en ) ;
bufif0 PAR_buf      ( PAR, PAR_out, PAR_en ) ;
bufif0 PERR_buf     ( PERR, PERR_out, PERR_en ) ;
bufif0 SERR_buf     ( SERR, SERR_out, SERR_en ) ;

`ifdef PCI_CPCI_HS_IMPLEMENT
bufif0 ENUM_buf (ENUM, ENUM_out, ENUM_en) ;
bufif0 LED_buf  (LED,  LED_out,  LED_en ) ;
`endif

`ifdef PCI_SPOCI
bufif0 SCL_buf (SCL, SCL_out, SCL_en)   ;
bufif0 SDA_buf (SDA, SDA_out, SDA_en)   ;
`endif

`else
`ifdef ACTIVE_HIGH_OE

bufif1 AD_buf0   ( AD[0],  AD_out[0], AD_en[0]) ;
bufif1 AD_buf1   ( AD[1],  AD_out[1], AD_en[1]) ;
bufif1 AD_buf2   ( AD[2],  AD_out[2], AD_en[2]) ;
bufif1 AD_buf3   ( AD[3],  AD_out[3], AD_en[3]) ;
bufif1 AD_buf4   ( AD[4],  AD_out[4], AD_en[4]) ;
bufif1 AD_buf5   ( AD[5],  AD_out[5], AD_en[5]) ;
bufif1 AD_buf6   ( AD[6],  AD_out[6], AD_en[6]) ;
bufif1 AD_buf7   ( AD[7],  AD_out[7], AD_en[7]) ;
bufif1 AD_buf8   ( AD[8],  AD_out[8], AD_en[8]) ;
bufif1 AD_buf9   ( AD[9],  AD_out[9], AD_en[9]) ;
bufif1 AD_buf10  ( AD[10], AD_out[10],AD_en[10] ) ;
bufif1 AD_buf11  ( AD[11], AD_out[11],AD_en[11] ) ;
bufif1 AD_buf12  ( AD[12], AD_out[12],AD_en[12] ) ;
bufif1 AD_buf13  ( AD[13], AD_out[13],AD_en[13] ) ;
bufif1 AD_buf14  ( AD[14], AD_out[14],AD_en[14] ) ;
bufif1 AD_buf15  ( AD[15], AD_out[15],AD_en[15] ) ;
bufif1 AD_buf16  ( AD[16], AD_out[16],AD_en[16] ) ;
bufif1 AD_buf17  ( AD[17], AD_out[17],AD_en[17] ) ;
bufif1 AD_buf18  ( AD[18], AD_out[18],AD_en[18] ) ;
bufif1 AD_buf19  ( AD[19], AD_out[19],AD_en[19] ) ;
bufif1 AD_buf20  ( AD[20], AD_out[20],AD_en[20] ) ;
bufif1 AD_buf21  ( AD[21], AD_out[21],AD_en[21] ) ;
bufif1 AD_buf22  ( AD[22], AD_out[22],AD_en[22] ) ;
bufif1 AD_buf23  ( AD[23], AD_out[23],AD_en[23] ) ;
bufif1 AD_buf24  ( AD[24], AD_out[24],AD_en[24] ) ;
bufif1 AD_buf25  ( AD[25], AD_out[25],AD_en[25] ) ;
bufif1 AD_buf26  ( AD[26], AD_out[26],AD_en[26] ) ;
bufif1 AD_buf27  ( AD[27], AD_out[27],AD_en[27] ) ;
bufif1 AD_buf28  ( AD[28], AD_out[28],AD_en[28] ) ;
bufif1 AD_buf29  ( AD[29], AD_out[29],AD_en[29] ) ;
bufif1 AD_buf30  ( AD[30], AD_out[30],AD_en[30] ) ;
bufif1 AD_buf31  ( AD[31], AD_out[31],AD_en[31] ) ;
 
bufif1 CBE_buf0 ( CBE[0], CBE_out[0], CBE_en[0] ) ;
bufif1 CBE_buf1 ( CBE[1], CBE_out[1], CBE_en[1] ) ;
bufif1 CBE_buf2 ( CBE[2], CBE_out[2], CBE_en[2] ) ;
bufif1 CBE_buf3 ( CBE[3], CBE_out[3], CBE_en[3] ) ;
 
bufif1 FRAME_buf    ( FRAME, FRAME_out, FRAME_en ) ;
bufif1 IRDY_buf     ( IRDY, IRDY_out, IRDY_en ) ;
bufif1 DEVSEL_buf   ( DEVSEL, DEVSEL_out, DEVSEL_en ) ;
bufif1 TRDY_buf     ( TRDY, TRDY_out, TRDY_en ) ;
bufif1 STOP_buf     ( STOP, STOP_out, STOP_en ) ;
 
`ifdef HOST
bufif1 RST_buf      ( RST, RST_out, RST_en ) ;
`endif

bufif1 INTA_buf     ( INTA, INTA_out, INTA_en) ;
bufif1 REQ_buf      ( REQ, REQ_out, REQ_en ) ;
bufif1 PAR_buf      ( PAR, PAR_out, PAR_en ) ;
bufif1 PERR_buf     ( PERR, PERR_out, PERR_en ) ;
bufif1 SERR_buf     ( SERR, SERR_out, SERR_en ) ;

`ifdef PCI_CPCI_HS_IMPLEMENT
bufif1 ENUM_buf (ENUM, ENUM_out, ENUM_en) ;
bufif1 LED_buf  (LED,  LED_out,  LED_en ) ;
`endif

`ifdef PCI_SPOCI
bufif1 SCL_buf (SCL, SCL_out, SCL_en)   ;
bufif1 SDA_buf (SDA, SDA_out, SDA_en)   ;
`endif

`endif
`endif

endmodule
