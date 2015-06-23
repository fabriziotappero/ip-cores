
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  UART2SPI  Top Module                                        ////
////                                                              ////
////  This file is part of the uart2spi  cores project            ////
////  http://www.opencores.org/cores/uart2spi/                    ////
////                                                              ////
////  Description                                                 ////
////  Uart2SPI top level integration.                             ////
////    1. spi_core                                               ////
////    2. uart_core                                              ////
////    3. uart_msg_handler                                       ////
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

module top (  
        line_reset_n ,
        line_clk ,

	// configuration control
        cfg_tx_enable  , // Enable Transmit Path
        cfg_rx_enable  , // Enable Received Path
        cfg_stop_bit   , // 0 -> 1 Start , 1 -> 2 Stop Bits
        cfg_pri_mod    , // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
	cfg_baud_16x   ,

       // Status information
        frm_error      ,
	par_error      ,

	baud_clk_16x,

       // Line Interface
        rxd,
        txd,

      // Spi I/F
        sck,
        so,
        si,
        cs_n  

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

//-------------------------------------
// Spi I/F
//-------------------------------------
output              sck            ; // clock out
output              so             ; // serial data out
input               si             ; // serial data in
output [3:0]        cs_n           ; // cs_n
//---------------------------------------
// Control Unit interface
// --------------------------------------

wire  [15:0] reg_addr           ; // Register Address
wire  [31:0]  reg_wdata          ; // Register Wdata
wire         reg_req            ; // Register Request
wire         reg_wr             ; // 1 -> write; 0 -> read
wire          reg_ack            ; // Register Ack
wire   [31:0] reg_rdata          ;
//--------------------------------------
// TXD Path
// -------------------------------------
wire         tx_data_avail        ; // Indicate valid TXD Data 
wire [7:0]   tx_data              ; // TXD Data to be transmited
wire        tx_rd                ; // Indicate TXD Data Been Read


//--------------------------------------
// RXD Path
// -------------------------------------
wire         rx_ready           ; // Indicate Ready to accept the Read Data
wire [7:0]  rx_data             ; // RXD Data 
wire        rx_wr               ; // Valid RXD Data

spi_core  u_spi (

             .clk                (baud_clk_16x),
             .reset_n            (line_reset_n),
               
        // Reg Bus Interface Signal
             .reg_cs             (reg_req      ),
             .reg_wr             (reg_wr       ),
             .reg_addr           (reg_addr[5:2]),
             .reg_wdata          (reg_wdata    ),
             .reg_be             (4'b1111      ),

            // Outputs
            .reg_rdata           (reg_rdata    ),
            .reg_ack             (reg_ack      ),

          // line interface
               .sck              (sck          ),
               .so               (so           ),
               .si               (si           ),
               .cs_n             (cs_n         ) 

           );

 uart_core u_core (  
          .line_reset_n       (line_reset_n) ,
          .line_clk           (line_clk) ,

	// configuration control
          .cfg_tx_enable      (cfg_tx_enable) , 
          .cfg_rx_enable      (cfg_rx_enable) , 
          .cfg_stop_bit       (cfg_stop_bit) , 
          .cfg_pri_mod        (cfg_pri_mod) , 
	  .cfg_baud_16x       (cfg_baud_16x) ,

    // TXD Information
          .tx_data_avail      (tx_data_avail) ,
          .tx_rd              (tx_rd) ,
          .tx_data            (tx_data) ,
         

    // RXD Information
          .rx_ready           (rx_ready) ,
          .rx_wr              (rx_wr) ,
          .rx_data            (rx_data) ,

       // Status information
          .frm_error          (frm_error) ,
	  .par_error          (par_error) ,

	  .baud_clk_16x       (baud_clk_16x) ,

       // Line Interface
          .rxd                (rxd) ,
          .txd                (txd) 

     );



uart_msg_handler u_msg (  
          .reset_n            (line_reset_n ) ,
          .sys_clk            (baud_clk_16x ) ,


    // UART-TX Information
          .tx_data_avail      (tx_data_avail) ,
          .tx_rd              (tx_rd) ,
          .tx_data            (tx_data) ,
         

    // UART-RX Information
          .rx_ready           (rx_ready) ,
          .rx_wr              (rx_wr) ,
          .rx_data            (rx_data) ,

      // Towards Control Unit
          .reg_addr          (reg_addr),
          .reg_wr            (reg_wr),
          .reg_wdata         (reg_wdata),
          .reg_req           (reg_req),
          .reg_ack           (reg_ack),
	  .reg_rdata         (reg_rdata) 

     );

endmodule
