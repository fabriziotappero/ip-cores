////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2013 by Michael A. Morris, dba M. A. Morris & Associates
//
//  All rights reserved. The source code contained herein is publicly released
//  under the terms and conditions of the GNU Lesser Public License. No part of
//  this source code may be reproduced or transmitted in any form or by any
//  means, electronic or mechanical, including photocopying, recording, or any
//  information storage and retrieval system in violation of the license under
//  which the source code is released.
//
//  The source code contained herein is free; it may be redistributed and/or
//  modified in accordance with the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either version 2.1 of
//  the GNU Lesser General Public License, or any later version.
//
//  The source code contained herein is freely released WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
//  PARTICULAR PURPOSE. (Refer to the GNU Lesser General Public License for
//  more details.)
//
//  A copy of the GNU Lesser General Public License should have been received
//  along with the source code contained herein; if not, a copy can be obtained
//  by writing to:
//
//  Free Software Foundation, Inc.
//  51 Franklin Street, Fifth Floor
//  Boston, MA  02110-1301 USA
//
//  Further, no use of this source code is permitted in any form or means
//  without inclusion of this banner prominently in any derived works.
//
//  Michael A. Morris
//  Huntsville, AL
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris
// 
// Create Date:     20:13:40 07/06/2013 
// Design Name:     M16C5x Microcontroller based on PIC16C5x-compatible core
// Module Name:     M16C5x_UART.v 
// Project Name:    M16C5x 
// Target Devices:  SRAM-based FPGAs
// Tool versions:   Xilinx ISE 10.1i SP3
//
// Description:
//
//  This module implements a UART for use with the M16C5x soft-core processor.
//  The module is based on existing modules developed for use with the NXP ARM
//  LPC213x/LPC214x processor's Synchronous Serial Peripheral interface. A 16-
//  bit frame size is used. The SSPx_Slv module is an SSP-compatible serial
//  slave I/F that can be connected to an SPI Master interface. The SSPx_Slv
//  controls the synchronous serial interface transactions to/from the SSP_UART
//  which is attached. Additional modules can be attached to the SSPx_Slv, but
//  select logic would need to be incorporated to select the additional modules
//  based on the RA, register address, control field. The SSP_UART attached 
//  requires 4 addresses, and RA has a range from 0 to 7, i.e. 3 bits. 
//
//  The UART and its SSP interface is optimized to transfer 4 control signals 
//  and 12 data bits. Standard MSB first shifting is expected by the SSPx_Slv
//  module. This allows on the fly decoding of the 3 address bits and the WnR
//  write control signal.
//
//  The 12-bit data format, more fully described in the headers of the SSPx_Slv
//  and SSP_UART modules, allows efficient control of the UART over a serial
//  link. On every 16-bit serial transfer, the UART provides status information
//  regarding the UART's transmitter and UART's receiver. This allows the pro-
//  grammer access to critical status information with a minimal number of
//  transfers. Transmit and Receive FIFOs are part of the implementation pro-
//  vided, and these elements provide buffering which further reduces the work-
//  load on the processor to which the SSP_UART is attached.
//
// Dependencies:    SSPx_Slv.v
//                  SSP_UART.v
//                      re1ce.v
//                      DPSFmnCE.v
//                      UART_BRG.v
//                      UART_TXSM.v
//                      UART_RXSM.v
//                      UART_RTO.v
//                      UART_INT.v
//                          redet.v
//
// Revision:
// 
//  1.00    13G06   MAM     File Created
//
//  1.00    13G14   MAM     Improved parameterization. Added/pulled parameters
//                          to allow all relevant options to be set through the
//                          instantiation interface.
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module M16C5x_UART #(
    // SSP_UART Default BRR Settings Parameters

    parameter pPS_Default  = 4'h1,          // see baud rate tables SSP_UART
    parameter pDiv_Default = 8'hEF,         // see baud rate tables SSP_UART

    // SSP_UART Default Receive Time Out Character Delay Count

    parameter pRTOChrDlyCnt = 3,

    // SSP_UART FIFO Configuration Parameters

    parameter pTF_Depth = 0,                // Tx FIFO Depth: 2**(TF_Depth + 4)
    parameter pRF_Depth = 3,                // Rx FIFO Depth: 2**(RF_Depth + 4)
    parameter pTF_Init  = "Src/UART_TF.coe",    // Tx FIFO Memory Initialization 
    parameter pRF_Init  = "Src/UART_RF.coe"     // Rx FIFO Memory Initialization 
)(
    input   Rst,        // System Reset
    
    input   Clk_UART,   // UART Clock - expected to be 48 MHz
    
    //  SPI Mode 0/3 Interface
    
    input   SSEL,       // Slave Select
    input   SCK,        // Serial Shift Clock
    input   MOSI,       // Serial Data Input:  Master Out/Slave In
    output  MISO,       // Serial Data Output: Master In/Slave Out
    
    //  UART External Interface
    
    output  TxD,        // Transmit Data
    output  RTS,        // Request to Send
    input   RxD,        // Receive Data
    input   CTS,        // Clear to Send
    
    output  DE,         // Drive Enable for RS-485 Modes
    
    output  IRQ         // Interrupt Request
);

////////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

wire    [2:0] RA;
wire    WnR;
wire    En;
wire    EOC;
wire    [11:0] DI;
wire    [11:0] DO;

wire    TxD_232;
wire    TxD_485;

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Instatiate a 16-bit Synchronous Serial Peripheral Slave Interface Controller

SSPx_Slv    SSP_Slv (
                .Rst(Rst),
                
                .SSEL(SSEL), 
                .SCK(SCK), 
                .MOSI(MOSI), 
                .MISO(MISO),
                
                .RA(RA),
                .WnR(WnR),
                .En(En), 
                .EOC(EOC),
                .DI(DI), 
                .DO(DO),
                
                .BC() 
            );
            
//  Instantiate UART compatible with 16-bit SSP Slave Interface Controller

SSP_UART    #(
                .pPS_Default(pPS_Default),
                .pDiv_Default(pDiv_Default),
                .pRTOChrDlyCnt(pRTOChrDlyCnt),
                .pTF_Depth(pTF_Depth),
                .pRF_Depth(pRF_Depth),
                .pTF_Init(pTF_Init),
                .pRF_Init(pRF_Init)
            ) UART (
                .Rst(Rst), 
                .Clk(Clk_UART),
                
                .SSP_SSEL(SSEL),
                .SSP_SCK(SCK), 
                .SSP_RA(RA),
                .SSP_WnR(WnR),
                .SSP_En(En),
                .SSP_EOC(EOC), 
                .SSP_DI(DI), 
                .SSP_DO(DO),
                
                .TxD_232(TxD_232), 
                .RxD_232(RxD), 
                .xRTS(RTS), 
                .xCTS(CTS),
                
                .TxD_485(TxD_485), 
                .RxD_485(RxD), 
                .xDE(DE),
                
                .IRQ(IRQ),
                
                .TxIdle(),
                .RxIdle()
            );
            
assign TxD = TxD_232 & TxD_485;

endmodule
