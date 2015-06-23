//////////////////////////////////////////////////////////////////////
////                                                              ////
////  USB2UART core level  Module                                 ////
////                                                              ////
////  This file is part of the usb2uart cores project             ////
////  http://www.opencores.org/cores/usb2uart/                    ////
////                                                              ////
////  Description                                                 ////
////  USB2UART core level integration.                            ////
////     Following modules are integrated                         ////
////         1. usb1_phy                                          ////
////         2. usb1_core                                         ////
////         3. uart_core                                         ////
////   Ver 0.1 : 01.Mar.2013                                      ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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


module core(
        clk_i, 
        rst_i,

        // Transciever Interface
        usb_txdp, 
        usb_txdn, 
        usb_txoe,   
        usb_rxd, 
        usb_rxdp, 
        usb_rxdn,

        // USB Misc
        phy_tx_mode ,
        usb_rst,

        // Interrupts
        dropped_frame, 
        misaligned_frame,
        crc16_err,

        // Vendor Features
        v_set_int, 
        v_set_feature, 
        wValue,
        wIndex, 
        vendor_data,

        // USB Status
        usb_busy, 
        ep_sel,

        // Endpoint Interface
        ep1_cfg,
        ep1_din,  
        ep1_we, 
        ep1_full,
        ep1_dout, 
        ep1_re, 
        ep1_empty,
        ep1_bf_en, 
        ep1_bf_size,

        ep2_cfg,
        ep2_din,  
        ep2_we, 
        ep2_full,
        ep2_dout, 
        ep2_re, 
        ep2_empty,
        ep2_bf_en, 
        ep2_bf_size,

        ep3_cfg,
        ep3_din,  
        ep3_we, 
        ep3_full,
        ep3_dout, 
        ep3_re, 
        ep3_empty,
        ep3_bf_en, 
        ep3_bf_size,

        ep4_cfg,
        ep4_din,  
        ep4_we, 
        ep4_full,
        ep4_dout, 
        ep4_re, 
        ep4_empty,
        ep4_bf_en, 
        ep4_bf_size,

        ep5_cfg,
        ep5_din,  
        ep5_we, 
        ep5_full,
        ep5_dout, 
        ep5_re, 
        ep5_empty,
        ep5_bf_en, 
        ep5_bf_size,

        ep6_cfg,
        ep6_din,  
        ep6_we, ep6_full,
        ep6_dout, ep6_re, ep6_empty,
        ep6_bf_en, ep6_bf_size,

        ep7_cfg,
        ep7_din,  ep7_we, ep7_full,
        ep7_dout, ep7_re, ep7_empty,
        ep7_bf_en, ep7_bf_size,
        // Uart Line Interface
        uart_txd, uart_rxd

        );      

input       clk_i;
input       rst_i;

// USB Traceiver interface
output      usb_txdp; // USB TX + 
output      usb_txdn; // USB TX -
output      usb_txoe; // USB TX OEN, Output driven at txoe=0
input       usb_rxd; 
input       usb_rxdp;  // USB RX+
input       usb_rxdn;  // USB RX-

input       phy_tx_mode;
output      usb_rst;
output          dropped_frame, misaligned_frame;
output          crc16_err;

output          v_set_int;
output          v_set_feature;
output  [15:0]  wValue;
output  [15:0]  wIndex;
input   [15:0]  vendor_data;

output      usb_busy;
output  [3:0]   ep_sel;

// Endpoint Interfaces
input   [13:0]  ep1_cfg;
input   [7:0]   ep1_din;
output  [7:0]   ep1_dout;
output      ep1_we, ep1_re;
input       ep1_empty, ep1_full;
input       ep1_bf_en;
input   [6:0]   ep1_bf_size;

input   [13:0]  ep2_cfg;
input   [7:0]   ep2_din;
output  [7:0]   ep2_dout;
output      ep2_we, ep2_re;
input       ep2_empty, ep2_full;
input       ep2_bf_en;
input   [6:0]   ep2_bf_size;

input   [13:0]  ep3_cfg;
input   [7:0]   ep3_din;
output  [7:0]   ep3_dout;
output      ep3_we, ep3_re;
input       ep3_empty, ep3_full;
input       ep3_bf_en;
input   [6:0]   ep3_bf_size;

input   [13:0]  ep4_cfg;
input   [7:0]   ep4_din;
output  [7:0]   ep4_dout;
output      ep4_we, ep4_re;
input       ep4_empty, ep4_full;
input       ep4_bf_en;
input   [6:0]   ep4_bf_size;

input   [13:0]  ep5_cfg;
input   [7:0]   ep5_din;
output  [7:0]   ep5_dout;
output      ep5_we, ep5_re;
input       ep5_empty, ep5_full;
input       ep5_bf_en;
input   [6:0]   ep5_bf_size;

input   [13:0]  ep6_cfg;
input   [7:0]   ep6_din;
output  [7:0]   ep6_dout;
output      ep6_we, ep6_re;
input       ep6_empty, ep6_full;
input       ep6_bf_en;
input   [6:0]   ep6_bf_size;

input   [13:0]  ep7_cfg;
input   [7:0]   ep7_din;
output  [7:0]   ep7_dout;
output      ep7_we, ep7_re;
input       ep7_empty, ep7_full;
input       ep7_bf_en;
input   [6:0]   ep7_bf_size;

//----------------------
// Uart I/F
//-----------------------

input           uart_rxd;
output          uart_txd;

//-----------------------------------
// Register Interface
// ----------------------------------
wire [31:0]   reg_addr;   // Register Address
wire      reg_rdwrn;  // 0 -> write, 1-> read
wire      reg_req;    //  Register Req
wire [31:0]   reg_wdata;  // Register write data
wire  [31:0]   reg_rdata;  // Register Read Data
wire       reg_ack;    // Register Ack
///////////////////////////////////////////////////////////////////
// Local Wires and Registers
///////////////////////////////////////////////////////////////////
//------------------------------------
// UTMI Interface
// -----------------------------------
wire    [7:0]   DataOut;
wire        TxValid;
wire        TxReady;
wire    [7:0]   DataIn;
wire        RxValid;
wire        RxActive;
wire        RxError;
wire    [1:0]   LineState;
wire        clk;
wire        rst;
wire        phy_tx_mode;
wire        usb_rst;
    
usb_phy u_usb_phy(
                    .clk                ( clk_i             ),
                    .rst                ( rst_i             ),  
                    .phy_tx_mode        ( phy_tx_mode       ),
                    .usb_rst            ( usb_rst           ),

        // Transceiver Interface
                    .rxd                ( usb_rxd           ),
                    .rxdp               ( usb_rxdp          ),
                    .rxdn               ( usb_rxdn          ),
                    .txdp               ( usb_txdp          ),
                    .txdn               ( usb_txdn          ),
                    .txoe               ( usb_txoe          ),

        // UTMI Interface
                    .DataIn_o           ( DataIn            ),
                    .RxValid_o          ( RxValid           ),
                    .RxActive_o         ( RxActive          ),
                    .RxError_o          ( RxError           ),
                    .DataOut_i          ( DataOut           ),
                    .TxValid_i          ( TxValid           ),
                    .TxReady_o          ( TxReady           ),
                    .LineState_o        ( LineState         )
        );


usb1_core  u_usb_core(
                    .clk_i              ( clk_i             ), 
                    .rst_i              ( rst_i             ),


                 // USB Misc
                    .phy_tx_mode        ( phy_tx_mode       ), 
                    .usb_rst            ( usb_rst           ), 

                                        // UTMI Interface
                    .DataIn             ( DataIn            ),
                    .RxValid            ( RxValid           ),
                    .RxActive           ( RxActive          ),
                    .RxError            ( RxError           ),
                    .DataOut            ( DataOut           ),
                    .TxValid            ( TxValid           ),
                    .TxReady            ( TxReady           ),
                    .LineState          ( LineState         ),

                 // Interrupts
                    .dropped_frame      ( dropped_frame     ), 
                    .misaligned_frame   ( misaligned_frame  ),
                    .crc16_err          ( crc16_err         ),

                  // Vendor Features
                    .v_set_int          ( v_set_int         ), 
                    .v_set_feature      ( v_set_feature     ), 
                    .wValue             ( wValue            ),
                    .wIndex             ( wIndex            ), 
                    .vendor_data        ( vendor_data       ),

        // USB Status
                    .usb_busy           ( usb_busy          ), 
                    .ep_sel             ( ep_sel            ),

        // Endpoint Interface
                    .ep1_cfg            ( ep1_cfg           ),
                    .ep1_din            ( ep1_din           ),  
                    .ep1_we             ( ep1_we            ), 
                    .ep1_full           ( ep1_full          ),
                    .ep1_dout           ( ep1_dout          ), 
                    .ep1_re             ( ep1_re            ), 
                    .ep1_empty          ( ep1_empty         ),
                    .ep1_bf_en          ( ep1_bf_en         ), 
                    .ep1_bf_size        ( ep1_bf_size       ),

                    .ep2_cfg            ( ep2_cfg           ),
                    .ep2_din            ( ep2_din           ),  
                    .ep2_we             ( ep2_we            ), 
                    .ep2_full           ( ep2_full          ),
                    .ep2_dout           ( ep2_dout          ), 
                    .ep2_re             ( ep2_re            ), 
                    .ep2_empty          ( ep2_empty         ),
                    .ep2_bf_en          ( ep2_bf_en         ), 
                    .ep2_bf_size        ( ep2_bf_size       ),

                    .ep3_cfg            ( ep3_cfg           ),
                    .ep3_din            ( ep3_din           ),  
                    .ep3_we             ( ep3_we            ), 
                    .ep3_full           ( ep3_full          ),
                    .ep3_dout           ( ep3_dout          ), 
                    .ep3_re             ( ep3_re            ), 
                    .ep3_empty          ( ep3_empty         ),
                    .ep3_bf_en          ( ep3_bf_en         ), 
                    .ep3_bf_size        ( ep3_bf_size       ),

                    .ep4_cfg            ( ep4_cfg           ),
                    .ep4_din            ( ep4_din           ),  
                    .ep4_we             ( ep4_we            ), 
                    .ep4_full           ( ep4_full          ),
                    .ep4_dout           ( ep4_dout          ), 
                    .ep4_re             ( ep4_re            ), 
                    .ep4_empty          ( ep4_empty         ),
                    .ep4_bf_en          ( ep4_bf_en         ), 
                    .ep4_bf_size        ( ep4_bf_size       ),

                    .ep5_cfg            ( ep5_cfg           ),
                    .ep5_din            ( ep5_din           ),  
                    .ep5_we             ( ep5_we            ), 
                    .ep5_full           ( ep5_full          ),
                    .ep5_dout           ( ep5_dout          ), 
                    .ep5_re             ( ep5_re            ), 
                    .ep5_empty          ( ep5_empty         ),
                    .ep5_bf_en          ( ep5_bf_en         ), 
                    .ep5_bf_size        ( ep5_bf_size       ),

                    .ep6_cfg            ( ep6_cfg           ),
                    .ep6_din            ( ep6_din           ),  
                    .ep6_we             ( ep6_we            ), 
                    .ep6_full           ( ep6_full          ),
                    .ep6_dout           ( ep6_dout          ), 
                    .ep6_re             ( ep6_re            ), 
                    .ep6_empty          ( ep6_empty         ),
                    .ep6_bf_en          ( ep6_bf_en         ), 
                    .ep6_bf_size        ( ep6_bf_size       ),

                    .ep7_cfg            ( ep7_cfg           ),
                    .ep7_din            ( ep7_din           ),  
                    .ep7_we             ( ep7_we            ), 
                    .ep7_full           ( ep7_full          ),
                    .ep7_dout           ( ep7_dout          ), 
                    .ep7_re             ( ep7_re            ), 
                    .ep7_empty          ( ep7_empty         ),
                    .ep7_bf_en          ( ep7_bf_en         ), 
                    .ep7_bf_size        ( ep7_bf_size       ),

                // Register Interface
                    .reg_addr           ( reg_addr          ),
                    .reg_rdwrn          ( reg_rdwrn         ),
                    .reg_req            ( reg_req           ),
                    .reg_wdata          ( reg_wdata         ),
                    .reg_rdata          ( reg_rdata         ),
                    .reg_ack            ( reg_ack           )


        );      

uart_core  u_uart_core

     (  
        .app_reset_n (rst_i),
        .app_clk     (clk_i),

        // Reg Bus Interface Signal
        .reg_cs     (reg_req),
        .reg_wr     (!reg_rdwrn),
        .reg_addr   (reg_addr[5:2]),
        .reg_wdata  (reg_wdata),
        .reg_be     (4'hF),

        // Outputs
        .reg_rdata   (reg_rdata),
        .reg_ack     (reg_ack),

       // Line Interface
        .si          (uart_rxd),
        .so          (uart_txd)

     );


endmodule
