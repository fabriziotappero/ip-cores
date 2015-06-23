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
// Create Date:     08:44:44 05/31/2008 
// Design Name:     Synchronous Serial Peripheral (SSP) Interface UART 
// Module Name:     ../VerilogCoponentsLib/SSP_UART/UART_RXSM.v
// Project Name:    Verilog Components Library
// Target Devices:  XC3S50A-4VQG100I, XC3S20A-4VQG100I, XC3S700AN-4FFG484I 
// Tool versions:   ISE 10.1i SP3 
//
// Description: This module implements the SSP UART Receive State Machine
//
// Dependencies:    None 
//
// Revision History:
//
//  0.01    08E31   MAM     File Created
//
//  1.00    08F08   MAM     Module Released
//
//  1.01    08F12   MAM     Pulled Format Decoder ROM and added its outputs to 
//                          the port list. Allows greater format specification
//                          flexibility. 7-bit formats require parity. If ParEn
//                          is not set, the parity will be tested according to 
//                          the settings of the Par bits, which may result in 
//                          anomalous behavior.
//
//  2.00    11B06   MAM     Converted to Verilog 2001.
//
// Additional Comments: 
//
///////////////////////////////////////////////////////////////////////////////

module UART_RXSM(
    input   Rst,
    input   Clk,
    
    input   CE_16x,         // 16x Clock Enable - Baud Rate x16
    
    input   Len,            // Word length: 0 - 8-bits; 1 - 7 bits
    input   NumStop,        // Number Stop Bits: 0 - 1 Stop; 1 - 2 Stop
    input   ParEn,          // Parity Enable
    input   [1:0] Par,      // 0 - Odd; 1 - Even; 2 - Space (0); 3 - Mark (1)

    input   RxD,            // Input Asynchronous Serial Receive Data
    
    output  reg [8:0] RD,   // Receive Data Output - bit 8 = Rcv Error (RERR)
    output  reg WE_RHR,     // Write Enable - Receive Holding Register
    
    output  RxWait,         // RxSM - Wait State
    output  RxIdle,         // RxSM - Idle State
    output  RxStart,        // RxSM - Start Bit Check State
    output  RxShift,        // RxSM - RxD Shift State
    output  RxParity,       // RxSM - RxD Parity Shift State
    output  RxStop,         // RxSM - RxD Stop Bit Check States
    output  RxError         // RxSM - Error State
);

///////////////////////////////////////////////////////////////////////////////
//
//  Module Parameters
// 

//  Receive State Machine Declarations (Binary)

localparam pWaitMark  =  0;
localparam pChkMark   =  1;
localparam pIdle      =  3;
localparam pChkStart  =  2;
localparam pShift0    = 10;
localparam pShift1    = 11;
localparam pShift2    =  9;
localparam pShift3    =  8;
localparam pShift4    = 12;
localparam pShift5    = 13;
localparam pShift6    = 15;
localparam pShift7    = 14;
localparam pChkStop1  =  6;
localparam pChkStop2  =  7;
localparam pChkParity =  5;
localparam pRcvError  =  4;

///////////////////////////////////////////////////////////////////////////////    
//
//  Local Signal Declarations
//

    (* FSM_ENCODING="SEQUENTIAL", 
       SAFE_IMPLEMENTATION="YES", 
       SAFE_RECOVERY_STATE="4'b0" *) reg [3:0] RxSM = pWaitMark;
       
    reg     [3:0] BCnt;
    reg     [7:0] RSR;

    reg     Err;
    
///////////////////////////////////////////////////////////////////////////////    
//
//  Implementation
//

///////////////////////////////////////////////////////////////////////////////    
//
//  RxSM Decode
//

assign RxSM_Wait = (  (RxSM == pWaitMark)
                    | (RxSM == pChkMark)
                    | (RxSM == pIdle)
                    | (RxSM == pRcvError) );

assign RxWait   = RxSM_Wait;
assign RxIdle   = (RxSM == pIdle);
assign RxStart  = (RxSM == pChkStart);
assign RxShift  = (  (RxSM == pShift0) 
                   | (RxSM == pShift1) 
                   | (RxSM == pShift2)
                   | (RxSM == pShift3)
                   | (RxSM == pShift4)
                   | (RxSM == pShift5)
                   | (RxSM == pShift6)
                   | (RxSM == pShift7) );
assign RxParity = (RxSM == pChkParity);
assign RxStop   = (RxSM == pChkStop1) | (RxSM == pChkStop2);
assign RxError  = (RxSM == pRcvError);

///////////////////////////////////////////////////////////////////////////////    
//
//  Bit Rate Prescaler
//
//      Prescaler is held in the half-bit load state during reset and when the 
//      RXSM is in the RxSM_Wait states. As a consequence, the first overflow
//      is only half a bit period, and only occurs in the pChkStart state. 
//      Subsequent, overflows are occur once per bit period in the middle of
//      each of the remaining bits.
//

assign Rst_BCnt = Rst | RxSM_Wait;

always @(posedge Clk)
begin
    if(Rst_BCnt)
         BCnt <= #1 4'b1000;
    else if(CE_16x)
         BCnt <= #1 BCnt + 1;
end

assign TC_BCnt = CE_16x & (BCnt == 4'b1111);

///////////////////////////////////////////////////////////////////////////////    

assign CE_RxSM = (RxSM_Wait ? CE_16x : TC_BCnt);

///////////////////////////////////////////////////////////////////////////////    
//
//  Receive Shift Register
//

always @(posedge Clk)
begin
    if(Rst)
         RSR <= #1 8'b0;
    else if(CE_RxSM)
        case(RxSM)
            pChkStart :  RSR    <= #1 8'b0; 
            pShift0   :  RSR[0] <= #1 RxD;
            pShift1   :  RSR[1] <= #1 RxD;
            pShift2   :  RSR[2] <= #1 RxD;
            pShift3   :  RSR[3] <= #1 RxD;
            pShift4   :  RSR[4] <= #1 RxD;
            pShift5   :  RSR[5] <= #1 RxD;
            pShift6   :  RSR[6] <= #1 RxD;
            pShift7   :  RSR[7] <= #1 RxD;
            default   :  RSR    <= #1 RSR;
        endcase
end

///////////////////////////////////////////////////////////////////////////////    
//
//  Parity Checker
//      if not Check Parity State, then ParErr = 0
//

assign OddPar = ^{RxD, RSR};
assign EvnPar = ~OddPar;

always @(*)
begin
    case(Par)
        2'b00 : Err <= ~OddPar;
        2'b01 : Err <= ~EvnPar;
        2'b10 : Err <=  RxD;
        2'b11 : Err <= ~RxD;
    endcase
end

assign ParErr = Err & (RxSM == pChkParity);

///////////////////////////////////////////////////////////////////////////////    
//
//  Receive Holding Register Data
//

assign CE_RD = CE_RxSM & (((RxSM == pChkStop1) & RxD) | (RxSM == pRcvError));

always @(posedge Clk)
begin
    if(Rst)
         RD <= #1 9'b0;
    else if(CE_RD)
         RD <= #1 {(RxSM == pRcvError), RSR};
end

always @(posedge Clk)
begin
    if(Rst)
         WE_RHR <= #1 1'b0;
    else
         WE_RHR <= #1 CE_RD;
end

///////////////////////////////////////////////////////////////////////////////    
//
//  RxSM - Receive State Machine
//
//      The Receive State Machine starts in the WaitMark state to insure that
//      the receive line is in the marking state before continuing. The ChkMark
//      state validates that the receive line is in the marking state. If it 
//      is, then the RxSM is adanced to the Idle state to wait for the start
//      bit. Otherwise, RxSM returns to the WaitMark state to wait for the line
//      to return to the marking (idle) state.
//
//      The format is processed through the receive sequence. The length,
//      parity options, and the number of stop bits determine the state tran-
//      sitions that the RxSM makes. A parity or a framing error is simply 
//      recorded as an error with the 9th bit of the receive holding register.
//      Line break conditions, invalid stop bits, etc. are handled through the
//      pRcvError and the pWaitMark states. Thus, line break conditions are not
//      expected to cause the RxSM to receive more than one character, and the
//      pWaitMark state holds the receiver in a wait state until the line 
//      returns to the marking (idle) state.
//

always @(posedge Clk)
begin
    if(Rst)
         RxSM <= #1 pWaitMark;
    else if(CE_RxSM)
        case(RxSM)
            pWaitMark  :  RxSM <= #1 ( RxD ? pChkMark 
                                           : pWaitMark);
    
            pChkMark   :  RxSM <= #1 ( RxD ? pIdle 
                                           : pWaitMark);
    
            pIdle      :  RxSM <= #1 (~RxD ? pChkStart 
                                           : pIdle);
    
            pChkStart  :  RxSM <= #1 ( RxD ? pIdle 
                                           : pShift0);
    
            pShift0    :  RxSM <= #1 pShift1;
            pShift1    :  RxSM <= #1 pShift2;
            pShift2    :  RxSM <= #1 pShift3;
            pShift3    :  RxSM <= #1 pShift4;
            pShift4    :  RxSM <= #1 pShift5;
            pShift5    :  RxSM <= #1 pShift6;
    
            pShift6    :  RxSM <= #1 (Len    ? pChkParity 
                                             : pShift7);
    
            pShift7    :  RxSM <= #1 (ParEn  ? pChkParity
                                             : (NumStop ? pChkStop2 
                                                        : pChkStop1));
    
            pChkParity :  RxSM <= #1 (ParErr ? pRcvError 
                                             : (NumStop ? pChkStop2 
                                                        : pChkStop1));
    
            pChkStop2  :  RxSM <= #1 (RxD ? pChkStop1 
                                          : pRcvError);
    
            pChkStop1  :  RxSM <= #1 (RxD ? pIdle 
                                          : pRcvError);
    
            pRcvError  :  RxSM <= #1 pWaitMark;
            
            default    :  RxSM <= #1 pWaitMark;
        endcase
end

endmodule
