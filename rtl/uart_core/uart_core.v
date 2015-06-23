//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores UART Interface Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
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
module uart_core (  
        line_reset_n ,
        line_clk ,

	// configuration control
        cfg_tx_enable  , // Enable Transmit Path
        cfg_rx_enable  , // Enable Received Path
        cfg_stop_bit   , // 0 -> 1 Start , 1 -> 2 Stop Bits
        cfg_pri_mod    , // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
	cfg_baud_16x   ,

    // TXD Information
        tx_data_avail,
        tx_rd,
        tx_data,
         

    // RXD Information
        rx_ready,
        rx_wr,
        rx_data,

       // Status information
        frm_error,
	par_error,

	baud_clk_16x,

       // Line Interface
        rxd,
        txd

     );



//---------------------------------
// Global Dec
// ---------------------------------

input        line_reset_n         ; // line reset
input        line_clk             ; // line clock

//-------------------------------------
// Configuration 
// -------------------------------------
input         cfg_tx_enable        ; // Tx Enable
input         cfg_rx_enable        ; // Rx Enable
input         cfg_stop_bit         ; // 0 -> 1 Stop, 1 -> 2 Stop
input   [1:0] cfg_pri_mod          ; // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
input   [11:0] cfg_baud_16x        ; // 16x Baud clock generation

//--------------------------------------
// TXD Path
// -------------------------------------
input         tx_data_avail        ; // Indicate valid TXD Data 
input [7:0]   tx_data              ; // TXD Data to be transmited
output        tx_rd                ; // Indicate TXD Data Been Read


//--------------------------------------
// RXD Path
// -------------------------------------
input         rx_ready            ; // Indicate Ready to accept the Read Data
output [7:0]  rx_data             ; // RXD Data 
output        rx_wr               ; // Valid RXD Data


//--------------------------------------
// ERROR Indication
// -------------------------------------
output        frm_error            ; // framing error
output        par_error            ; // par error

output        baud_clk_16x         ; // 16x Baud clock


//-------------------------------------
// Line Interface
// -------------------------------------
input         rxd                  ; // uart rxd
output        txd                  ; // uart txd

// Wire Declaration

wire [1  : 0]   error_ind          ;


// 16x Baud clock generation
// Example: to generate 19200 Baud clock from 50Mhz Link clock
//    50 * 1000 * 1000 / (2 + cfg_baud_16x) = 19200 * 16
//    cfg_baud_16x = 0xA0 (160)

clk_ctl #(11) u_clk_ctl (
   // Outputs
       .clk_o          (baud_clk_16x),

   // Inputs
       .mclk           (line_clk),
       .reset_n        (line_reset_n), 
       .clk_div_ratio  (cfg_baud_16x)
   );


uart_txfsm u_txfsm (
               . reset_n           ( line_reset_n      ),
               . baud_clk_16x      ( baud_clk_16x      ),

               . cfg_tx_enable     ( cfg_tx_enable     ),
               . cfg_stop_bit      ( cfg_stop_bit      ),
               . cfg_pri_mod       ( cfg_pri_mod       ),

       // FIFO control signal
               . fifo_empty        ( !tx_data_avail    ),
               . fifo_rd           ( tx_rd             ),
               . fifo_data         ( tx_data           ),

          // Line Interface
               . so                ( txd                )
          );


uart_rxfsm u_rxfsm (
               . reset_n           (  line_reset_n     ),
               . baud_clk_16x      (  baud_clk_16x     ) ,

               . cfg_rx_enable     (  cfg_rx_enable    ),
               . cfg_stop_bit      (  cfg_stop_bit     ),
               . cfg_pri_mod       (  cfg_pri_mod      ),

               . error_ind         (  error_ind        ),

       // FIFO control signal
               .  fifo_aval        ( rx_ready          ),
               .  fifo_wr          ( rx_wr             ),
               .  fifo_data        ( rx_data           ),

          // Line Interface
               .  si               (rxd              )
          );


wire   frm_error          = (error_ind == 2'b01);
wire   par_error          = (error_ind == 2'b10);



endmodule
