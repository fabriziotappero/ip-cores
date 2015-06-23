////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2008-2013 by Michael A. Morris, dba M. A. Morris & Associates
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

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     21:22:38 05/10/2008 
// Design Name:     Synchronous Serial Peripheral (SSP) Interface UART 
// Module Name:     ../VerilogCoponentsLib/SSP_UART/UART_TXSM.v
// Project Name:    Verilog Components Library
// Target Devices:  XC3S50A-4VQG100I, XC3S20A-4VQG100I, XC3S700AN-4FFG484I 
// Tool versions:   ISE 10.1i SP3 
//
// Description: This module implements the Transmit State Machine for the SSP
//              UART.
//
//              The Baud Rate Generator implements the 16 baud rates defined
//              in Table 3 of the SSP UART Specification.
//
// Dependencies:    None 
//
// Revision History:
//
//  0.01    08E10   MAM     File Created
//
//  1.00    08E24   MAM     Modified and tested TxSM to allow for several addi-
//                          tional conditions regarding Mode 1 - RS232 w/ Hand-
//                          shaking. In particular, TxSM goes to pStart from 
//                          pShift if CTS is not asserted when the current word
//                          has been shifted.
//
//  1.10    08E28   MAM     Modified to remove I/O signals best processed above
//                          this module: RTSi, RTSo, and DE. Removed from port
//                          list and moved the decoded state ouput bits to the
//                          end of the port list. Modified the TSRI and the TSR
//                          length. TSRI now only processes the two MSBs of the
//                          TSR load value. The length of TSR modified from 12
//                          to 10 bits because the logic 1 fill value and the 
//                          bit counter allow the stop bits to be implicit. The
//                          result is a faster signal path.
//
//  1.20    08F08   MAM     Modified TxSM to use a ROM to decode the [3:0]FMT
//                          input like the RxSM. Changed the SR implementation 
//                          of the shift register into a registered multiplexer
//                          implementation. Removed the bit counter and added
//                          states to the SM to multiplex the data. Result is a
//                          SM and SR that synthesizes to a speed that matches
//                          the reported speed of the RxSM: 110+ MHz. This may
//                          indicated that this UART may be useful as a high-
//                          speed UART with an 8x over-sample instead of a 4x
//                          oversample using a 48MHz clock input and a 2x DLL.
//
//  1.21    08F12   MAM     Pulled Format Decoder ROM and moved to upper level
//                          module. Added the outputs of the ROM to the port
//                          list of the module. Module now supports more format
//                          directly with the new direct inputs including com-
//                          binations not normally used. The upper level module
//                          must restrict the format inputs to those that are 
//                          proper. 7-bit formats require parity, and if not
//                          set on input, then the parity generated will be 
//                          that specified by the Par bits.
//
//  2.00    11B06   MAM     Converted to Verilog 2001.
//
//  2.01    13G06   MAM     Corrected placement of #1 delay statements. Changed
//                          combinatorial always to use @(*) instead of explicit
//                          listing of signals in sensitivity list.
//
// Additional Comments: 
//
///////////////////////////////////////////////////////////////////////////////

module UART_TXSM(
    input   Rst,
    input   Clk,

    input   CE_16x,         // 16x Clock Enable - Baud Rate x16
    
    input   Len,            // Word length: 0 - 8-bits; 1 - 7 bits
    input   NumStop,        // Number Stop Bits: 0 - 1 Stop; 1 - 2 Stop
    input   ParEn,          // Parity Enable
    input   [1:0] Par,      // 0 - Odd; 1 - Even; 2 - Space (0); 3 - Mark (1)

    input   TF_EF,          // Transmit THR Empty Flag

    input   [7:0] THR,      // Transmit Holding Register
    output  reg TF_RE,      // Transmit THR Read Enable Strobe

    input   CTSi,           // RS232 Mode CTS input

    output  reg TxD,        // Serial Data Out, LSB First, Start bit = 0

    output  TxIdle,         // Transmit State Machine - Idle State
    output  TxStart,        // Transmit State Machine - Start State - CTS wait
    output  TxShift,        // Transmit State Machine - Shift State
    output  TxStop          // Transmit State Machine - Stop State - RTS clear
);

///////////////////////////////////////////////////////////////////////////////
//
//  Module Parameters
// 

localparam  pIdle       =  0;   // Idle  - wait for data
localparam  pStopDelay  =  1;   // Stop  - deassert DE/RTS after 1 bit delay
localparam  pStartDelay =  2;   // Start - assert DE/RTS, delay 1 bit & CTSi
localparam  pUnused     =  3;   // Unused State
localparam  pStartBit   = 10;   // Shift - transmit Start Bit
localparam  pShift0     = 11;   // Shift - transmit TSR contents (LSB)
localparam  pShift1     =  9;   // Shift - transmit TSR contents
localparam  pShift2     =  8;   // Shift - transmit TSR contents
localparam  pShift3     = 12;   // Shift - transmit TSR contents
localparam  pShift4     = 13;   // Shift - transmit TSR contents
localparam  pShift5     = 15;   // Shift - transmit TSR contents
localparam  pShift6     = 14;   // Shift - transmit TSR contents
localparam  pShift7     =  6;   // Shift - transmit TSR contents (MSB)
localparam  pParityBit  =  4;   // Shift - transmit Parity Bit
localparam  pStopBit2   =  5;   // Shift - transmit Stop Bit 1
localparam  pStopBit1   =  7;   // Shift - transmit Stop Bit 2

///////////////////////////////////////////////////////////////////////////////    
//
//  Local Signal Declarations
//

    reg     [3:0] Bit;      // Bit Rate Divider
    reg     CE_BCnt;        // CEO Bit Rate Divider
    
    wire    Odd, Evn;       // Odd/Even parity signals
    reg     ParBit;         // Computed/assigned Parity Bit

    reg     [8:0] TSR;      // Transmit Shift Register
    
    (* FSM_ENCODING="SEQUENTIAL", 
       SAFE_IMPLEMENTATION="YES", 
       SAFE_RECOVERY_STATE="4'b0" *) 
    reg [3:0] TxSM = pIdle; // Xmt State Machine
    
///////////////////////////////////////////////////////////////////////////////    
//
//  Implementation
//

//  Set Transmit Idle Status Bit

assign TxIdle  = (TxSM == pIdle);       // Idle state
assign TxStop  = (TxSM == pStopDelay);  // Wait 1 bit to release line
assign TxStart = (TxSM == pStartDelay); // Take line and settle 1 bit
assign TxShift = (TxSM[3] | TxSM[2]);   // Xmt Shift States

//  Transmit State Machine Clock Enable

assign CE_TxSM = (TxIdle ? CE_16x : CE_BCnt);

//  Shift Register Load Signal

assign Ld_TSR = CE_TxSM & ~TF_EF & CTSi
                & (  (TxSM == pStartDelay)
                   | (TxSM == pStopBit1)
                   | (TxSM == pStopDelay) );

//  Generate Transmit FIFO Read Enable

always @(posedge Clk)
begin
    if(TxIdle)
        TF_RE <= #1 1'b0;
    else
        TF_RE <= #1 Ld_TSR;
end

//  Determine Load Value for Transmit Shift Register

assign Evn = ((Len) ? ^{1'b0, THR[6:0]} : ^THR);
assign Odd = ~Evn;

always @(*)
begin
    case(Par)
        2'b00 : ParBit <= Odd;  // Odd
        2'b01 : ParBit <= Evn;  // Even
        2'b10 : ParBit <= 0;    // Space
        2'b11 : ParBit <= 1;    // Mark
    endcase
end

//  Transmit Shift Register

always @(posedge Clk)
begin
    if(TxIdle)
        TSR <= #1 9'b1_1111_1111;
    else if(Ld_TSR)
        TSR <= #1 {ParBit, THR[7:0]};
end

always @(posedge Clk)
begin
    if(Rst)
        #1 TxD <= 1;
    else case(TxSM)
        pStartBit   : #1 TxD <= 0;
        pShift0     : #1 TxD <= TSR[0];
        pShift1     : #1 TxD <= TSR[1];
        pShift2     : #1 TxD <= TSR[2];
        pShift3     : #1 TxD <= TSR[3];
        pShift4     : #1 TxD <= TSR[4];
        pShift5     : #1 TxD <= TSR[5];
        pShift6     : #1 TxD <= TSR[6];
        pShift7     : #1 TxD <= TSR[7];
        pParityBit  : #1 TxD <= TSR[8];
        default     : #1 TxD <= 1;
    endcase
end

//  Bit Rate Divider

always @(posedge Clk)
begin
    if(TxIdle)
        Bit <= #1 4'b0;
    else if(CE_16x)
        Bit <= #1 Bit + 1;
end

always @(posedge Clk)
begin
    if(TxIdle)
        CE_BCnt <= #1 0;
    else
        CE_BCnt <= #1 CE_16x & (Bit == 4'b1111);
end

//  Transmit State Machine

always @(posedge Clk)
begin
    if(Rst)
        #1 TxSM <= pIdle;
    else if(CE_TxSM)
        case(TxSM)
            pIdle       : TxSM <= #1 ((TF_EF) ? pIdle 
                                              : pStartDelay);

            pStartDelay : TxSM <= #1 ((TF_EF) ? pIdle
                                              : ((CTSi) ? pStartBit 
                                                        : pStartDelay));

            pStartBit   : TxSM <= #1 pShift0;
            pShift0     : TxSM <= #1 pShift1;
            pShift1     : TxSM <= #1 pShift2;
            pShift2     : TxSM <= #1 pShift3;
            pShift3     : TxSM <= #1 pShift4;
            pShift4     : TxSM <= #1 pShift5;
            pShift5     : TxSM <= #1 pShift6;
            pShift6     : TxSM <= #1 ((Len)   ? pParityBit
                                              : pShift7   );
            pShift7     : TxSM <= #1 ((ParEn) ? pParityBit
                                              : ((NumStop) ? pStopBit2
                                                           : pStopBit1));

            pParityBit  : TxSM <= #1 ((NumStop) ? pStopBit2
                                                : pStopBit1);

            pStopBit2   : TxSM <= #1 pStopBit1;
            pStopBit1   : TxSM <= #1 ((TF_EF) ? pStopDelay
                                              : pStartBit );
            
            pStopDelay  : TxSM <= #1 ((TF_EF) ? pIdle
                                              : ((CTSi) ? pStartBit
                                                        : pStartDelay));
            
            pUnused     : TxSM <= #1 pIdle;
        endcase 
end

endmodule
