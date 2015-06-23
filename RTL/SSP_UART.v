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

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     12:30:30 05/11/2008 
// Design Name:     Synchronous Serial Peripheral (SSP) Interface UART 
// Module Name:     ../VerilogCoponentsLib/SSP_UART/SSP_UART.v
// Project Name:    Verilog Components Library
// Target Devices:  XC3S50A-4VQG100I, XC3S200A-4VQG100I, XC3S700AN-4FFG484I 
// Tool versions:   ISE 10.1i SP3 
//
// Description: This module integrates the various elements of a simplified 
//              UART to create a UART that is efficiently supported using a 
//              serial interface. The module also incorporates the logic to 
//              support four operating modes, and controls the signal muxes 
//              necessary.
//
// Dependencies: re1ce.v, BRSFmnCE.v, UART_BRG.v, UART_TXSM.v, UART_RXSM.v,
//               UART_RTO.v, UART_INT.v, redet.v
//
// Revision History:
//
//  0.01    08E10   MAM     File Created
//
//  0.10    O8E12   MAM     Incorporated the ROMs for decoding the format
//                          and buad rate. Updated the interfaces to the
//                          BRG, TxSM, and RxSM.
//
//  0.11    08E14   MAM     Added the RTO ROM for setting the length of the
//                          receive timeout interval on the basis of the 
//                          character frame format. Modified the baud rate 
//                          table to remove the 300 and 600 baud entries and
//                          add entries for 28.8k and 14.4k baud. Reduced the
//                          width of the baud rate divider from 10 to 8 bits.
//
//  1.00    08G23   MAM     Modified the SSP Interface to operate with the new
//                          SSPx_Slv interface which uses registers for SSP_DI
//                          and SSP_DO. The falling edge of SCK is used for the
//                          latching and transfering read/write operations from
//                          the SCK clock domain to the Clk clock domain.
//
//  1.01    08G24   MAM     Corrected error in the TFC/RFC pulse enables that
//                          allowed any write to the SSP UART with 1's in these
//                          bit positions to generate a THR/RHR FIFO reset.
//
//  1.10    08G26   MAM     Modified to implement a multiplexed register set
//                          with the SPR address. Additional status registers
//                          added for various purposes including revision, 
//                          FIFO output, FIFO len, and FIFO count registers.
//                          Since an XC2S30 is required, and there is no other
//                          function required in the FPGA, increased the FIFO
//                          depth of the Tx FIFO to 128 words using distributed
//                          RAM.
//
//  1.11    08G27   MAM     Modified the organization of the SPR window status
//                          registers to match Table 5 in the 1700-0403C SSP
//                          UART specification.
//
//  1.20    08G27   MAM     Modified Tx signal path to include a FF that will 
//                          prevent the Tx SM from shifting until the Tx FIFO
//                          is loaded with the full message up to the size of
//                          FIFO. The bit is normally written as a 0 and ORed
//                          with the TF_EF. In this state, Tx SM starts the
//                          shift operation immediately. When the bit is set,
//                          then the OR with the TF_EF prevents the Tx SM from
//                          sending the Tx FIFO contents until HLD bit is reset
//
//  1.30    08H02   MAM     Modified the FIFOs to use the Block RAM FIFOs. 
//                          Updated the default parameters to set the depth to
//                          match the 1024 word depth of the Block RAM FIFOs.
//
//  1.40    08H09   MAM     Added Rx/Tx FIFO Threshold Resgister, reordered SPR
//                          sub-registers to incorporate programmable threshold
//                          for the FIFOs into the design. Set the default of 
//                          the threshold for the Rx/Tx FIFOs to half.
//
//  1.41    08H12   MAM     Registered the RxD input signal; reset State forced
//                          mark condition. Modified the RTFThr register so
//                          a logic 1 is required in SSP_DI[8] to write it.
//
//  2.00    11B06   MAM     Converted to Verilog 2001. Added an external enable
//                          signal, reordered the registers, and set the SPI
//                          interface to operate in the same manner as for the
//                          LTAS module.
//
//  2.01    11B08   MAM     Changed En to SSP_SSEL, and changed the SSP_DO bus
//                          to a tri-state bus enabled by SSP_SSEL so that the
//                          module can used along with other SSP-compatible
//                          modules in the same FPGA. Corrected minor encoding
//                          error for RS/TS fields.
//
//  2.10    13G10   MAM     Adjusted baud rate table to support Profibus rates
//                          from 3M down to 187.5k, and standard baud rates from
//                          1200 to 230.4k baud.
//
//  2.20    13G12   MAM     Removed baud rate table controlled by 4 bits in the
//                          UART control register. Replaced by a 12-bit write-
//                          only register mapped to the address of the read-only
//                          UART status register. The new Baud Rate Register re-
//                          places the the baud rate ROM: PS[3:0] <= BRR[11:8],
//                          and Div[7:0] <= BRR[7:8]. (N-1) must be loaded into
//                          each of these fields to set the correct divider.
//                          Also added parameters for default values for the 
//                          baud rate generator PS (Prescaler) and Div (Divider)
//                          values. Default values selected for 9600 bps at the
//                          UART operating frequency, which is 73.728 MHz for
//                          this application.
//
//  2.30    13G14   MAM     Changed the parameterization so module can be para-
//                          meterized from the instantiating module. Removed
//                          (commented out) Block RAM FIFO instantiations and 
//                          associated FIFO configuration parameters. Updated
//                          the Additional Comments section.
//
//  2.40    13G21   MAM     Added asynchronous reset to several functions in 
//                          order to correctly simulate in ISim.
//
//  2.50    13G28   MAM     Corrected issue with polling of the Receive Data
//                          Register. A race condition was found. Corrected by
//                          registering the data on the SCK clock domain and 
//                          by requiring that the read pulse for the receive
//                          FIFO is only generated if the empty flag status is
//                          present on the SCK clock domain. This prevents the
//                          same race condition as found when polling the UART
//                          Status Register. Examining the condition/flags of
//                          these registers, without polling via the SSP inter-
//                          face, avoids these issues. Given the limited I/O
//                          resources of the M16C5x, examining the condition/
//                          flags bits directly without polling is not a viable
//                          option. Therefore, corrected the race condition. If
//                          examining the condition/flags directly is an option,
//                          then that is the preferred method from a performance
//                          perspective.
//
// Additional Comments:
//
//  The SSP UART is defined in 1700-0403C. The following is a summary of the 
//  register and field definitions contained in the referenced document. If any
//  conflicts arise in the definitions, the implementation defined in this file
//  will take precedence over the document.
//
//  The UART consists of six registers:
// 
//      (1) UCR - UART Control Register     (3'b000)
//      (2) USR - UART Status Register      (3'b001)
//      (3) BRR - Baud Rate Register        (3'b001)
//      (3) TDR - Transmit Data Register    (3'b010)
//      (4) RDR - Receive Data Register     (3'b011)
//      (5) SPR - Scratch Pad Register      (3'b100)
//
//  The Synchronous Serial Peripheral of the ARM is configured to send 16 bits.
//  The result is that the 3 most significant bits are interpreted as an regis-
//  ter select. Bit 12, the fourth transmitted bit, sets the write/read mode of
//  transfer. The remaining twelve bits, bits 11...0, are data bits. In this
//  manner, the SSP UART minimizes the number of serial transfers required to
//  send and receive serial data from the SSP UART. The reads from the TDR/RDR
//  addresses also provide status information regarding the transmit and receive
//  state machines, and the FIFO-based holding registers. Thus, polling of the 
//  status register is not necessary in most circumstances to determine if the
//  FIFOs are ready to receive data from the host or have data to provide the
//  host.
//
//  With each SSP/SPI operation to the TDR/RDR address, the SSP UART will read
//  and write the receive and transmit holding registers, respectively. These
//  holding registers are implemented using 9-bit and 8-bit FIFOs, respective-
//  ly. The FIFOs are independently configured so that they can be easily
//  replaced with other implementations as required.
//
//  The USR implements a read-only register for the UART status bits other than
//  the RERR - Receiver Error, RTO - Receiver Time-Out, RRDY - Receiver Ready,
//  and the TRDY - Transmitter Ready status bits read out in the RDR. The USR
//  provides access to the UART mode and baud rate bits from the UCR. The RTSi 
//  and CTSi bits reflect the state of the external RTS and CTS signals in the
//  RS-232 modes. In the RS-485 modes, RTSi reflects the state of the external
//  transceiver drive enable signal, and CTSi should be read as a logic 1. The
//  CTSi bit is set internally to a logic 1 by the SSP UART in the RS-485 modes
//  because it is always ready to receive. The receiver serial input data pin 
//  is controlled in the RS-485 modes so that the external transceiver output
//  enable can always be enabled. 
//
//  UART Control Register - UCR (RA = 3'b000)
//
//  11:10 - MD  :   Mode (see table below)
//      9 - RTSo:   Request To Send, set to assert external RTS in Mode 0
//      8 - IE  :   Interrupt Enable, set to enable Xmt/Rcv interrupts
//    7:4 - FMT :   Format (see table below)
//    3:0 - Rsvd:   Reserved (previously used for Baud Rate (see table below))
//
//  UART Status Register - USR (RA = 3'b001) (Read-Only)
//
//  11:10 - MD  :   Mode (see table below)
//      9 - RTSi:   Request To Send In, set as discussed above
//      8 - CTSi:   Clear To Send In, set as discussed above
//    7:6 - RS  :   Receive Status:  0 - Empty, 1 < Half, 2 >= Half, 3 - Full
//    5:4 - TS  :   Transmit Status: 0 - Empty, 1 < Half, 2 >= Half, 3 - Full
//      3 - iRTO:   Receive Timeout Interrupt Flag
//      2 - iRDA:   Receive Data Available Interupt Flag (FIFO >= Half Full)
//      1 - iTHE:   Transmit FIFO Half Empty Interrupt Flag
//      0 - iTFE:   Transmit FIFO Empty Interrupt Flag
//
//  Buad Rate Register - BRR (RA = 3'b001) (Write-Only)
//
//   11:8 - PS  :   Baud Rate Prescaler (see table below) - load with (M - 1)
//    7:0 - Div :   Baud Rate Divider (see table below) - load with (N - 1)
//
//   {PS, Div}  :   Baud Rate = (Clk / 16) / ((PS + 1) * (Div + 1))
//
//  Transmit Data Register - TDR (RA = 3'b010)
//
//   11 - TFC   :   Transmit FIFO Clear, cleared at end of current cycle
//   10 - RFC   :   Receive FIFO Clear, cleared at end of current cycle
//    9 - HLD   :   Transmit Hold: 0 - normal; 1 - hold until Tx FIFO filled
//    8 - Rsvd  :   Reserved for Future Use
//  7:0 - TD    :   Transmit Data, written to Xmit FIFO when WnR is set.
//
//  Receive Data Register - RDR (RA = 3'b011)
//
//   11 - TRDY  :   Transmit Ready, set if Xmt FIFO not full
//   10 - RRDY  :   Receive Ready, set if Rcv FIFO has data 
//    9 - RTO   :   Receive Time Out, set if no data received in 3 char. times
//    8 - RERR  :   Receiver Error, set if current RD[7:0] has an error
//  7:0 - RD    :   Receive Data
//
//  Scratch Pad Register - SPR (RA = 3'b100)
//
//  11:0 - SPR  :   Scratch Pad Data, R/W location set by bits 11:9 (see below)
//
////////////////////////////////////////////////////////////////////////////////
//
//  MD[1:0] - Operating Mode
//
//   2'b00 - RS-232 without Handshaking, xRTS <= RTSi <= RTSo, CTSi <= xCTS
//   2'b01 - RS-232 with Handshaking, xRTS <= RTSi <= ~TxIdle, CTSi <= xCTS
//   2'b10 - RS-485 without Loopback, RD <= CTSi <= 1, DE <= RTSi <= ~TxIdle
//   2'b11 - RS-485 with Loopback, RD <= RxD, DE <= RTSi <= ~TxIdle, CTSi <= 1
//
//  FMT[3:0] - Asynchronous Serial Format
//
//   4'b0000 - 8N1, 4'b1000 - 8O2
//   4'b0001 - 8N1, 4'b1001 - 8E2
//   4'b0010 - 8O1, 4'b1010 - 8S2
//   4'b0011 - 8E1, 4'b1011 - 8M2
//   4'b0100 - 8S1, 4'b1100 - 7O1
//   4'b0101 - 8M1, 4'b1101 - 7E1
//   4'b0110 - 8N1, 4'b1110 - 7O2
//   4'b0111 - 8N2, 4'b1111 - 7E2
//
////////////////////////////////////////////////////////////////////////////////
//
//  SPR Sub-Addresses - Additional Status Registers
//
//      Accessed by setting SPR[11:9] to the address of the desired extended
//      status register. Unused bits in the status registers set to 0.
//      Unassigned sub-addresses default to the SPR.
//
//   1 - [7:0] Revision Register
//   2 - [7:0] FIFO Length: RFLen - 7:4, TFLen - 3:0; (1 << (xFLen + 4))
//   3 - [7:0] Rx/Tx FIFO Threshold: RFThr - 7:4, TFThr - 3:0; (xFLen >> 1)
//   4 - [7:0] Tx Holding Register, "peeking" into THR does not advance Tx FIFO
//   5 - [8:0] Rx Holding Register, "peeking" into RHR does not advance Rx FIFO
//   6 - [(TFLen + 4):0] Tx FIFO Count
//   7 - [(RFLen + 4):0] Rx FIFO Count
//
////////////////////////////////////////////////////////////////////////////////

module SSP_UART #( 
    // Default BRR Settings Parameters

    parameter pPS_Default   = 4'h1,         // see baud rate tables below
    parameter pDiv_Default  = 8'hEF,        // see baud rate tables below

    // Default Receive Time Out Character Delay Count

    parameter pRTOChrDlyCnt = 3,

    // FIFO Configuration Parameters

    parameter pTF_Depth = 2,                // Tx FIFO Depth: 2**(TF_Depth + 4)
    parameter pRF_Depth = 2,                // Rx FIFO Depth: 2**(RF_Depth + 4)
    parameter pTF_Init  = "Src/UART_TF.coe",    // Tx FIFO Memory Initialization
    parameter pRF_Init  = "Src/UART_RF.coe"     // Rx FIFO Memory Initialization
)(
    input   Rst,                    // System Reset
    input   Clk,                    // System Clock
    
    //  SSP Interface
    
    input   SSP_SSEL,               // SSP Slave Select
    
    input   SSP_SCK,                // Synchronous Serial Port Serial Clock
    input   [2:0] SSP_RA,           // SSP Register Address
    input   SSP_WnR,                // SSP Command
    input   SSP_En,                 // SSP Start Data Transfer Phase (Bits 11:0)
    input   SSP_EOC,                // SSP End-Of-Cycle (Bit 0)
    input   [11:0] SSP_DI,          // SSP Data In
    output  reg [11:0] SSP_DO,      // SSP Data Out
    
    //  External UART Interface
    
    output  TxD_232,                // RS-232 Mode TxD
    input   RxD_232,                // RS-232 Mode RxD
    output  reg xRTS,               // RS-232 Mode RTS (Ready-To-Receive)
    input   xCTS,                   // RS-232 Mode CTS (Okay-To-Send)
    
    output  TxD_485,                // RS-485 Mode TxD
    input   RxD_485,                // RS-485 Mode RxD
    output  xDE,                    // RS-485 Mode Transceiver Drive Enable

    //  External Interrupt Request
    
    output  reg IRQ,                // Interrupt Request
    
    //  TxSM/RxSM Status
    
    output  TxIdle,
    output  RxIdle
); 

////////////////////////////////////////////////////////////////////////////////
//
//  Module Parameters
// 

localparam pVersion = 8'h23;    // Version: 2.3

//  Register Addresses

localparam pUCR = 0;            // UART Control Register
localparam pUSR = 1;            // UART Status Register
localparam pTDR = 2;            // Tx Data Register
localparam pRDR = 3;            // Rx Data Register
localparam pSPR = 4;            // Scratch Pad Register (and Aux. Status Regs)

//  TDR Bit Positions

localparam pTFC = 11;           // Tx FIFO Clear bit position
localparam pRFC = 10;           // Rx FIFO Clear bit position
localparam pHLD =  9;           // Tx SM Hold bit position

//  SPR Sub-Addresses

localparam pRev   = 1;          // Revision Reg:    {0, pVersion}
localparam pLen   = 2;          // Length Reg:      {0, pRF_Depth, pTF_Depth}
localparam pFThr  = 3;          // Rx/Tx FIFO Thres:{0, RFThr[3:0], TFThr[3:0]}
localparam pTHR   = 4;          // Tx Holding Reg:  {0, THR[7:0]}
localparam pRHR   = 5;          // Rx Holding Reg:  {0, RHR[8:0]}
localparam pTFCnt = 6;          // Tx Count:        {0, TFCnt[(pTF_Depth+4):0]}
localparam pRFCnt = 7;          // Rx Count:        {0, RFCnt[(pRF_Depth+4):0]}

//  FIFO Configuration Parameters

localparam pWidth = 8;          // Maximum Character width
localparam pxFThr = 8;          // TF/RF Half-Full Flag Theshold (%, 4 bits)

////////////////////////////////////////////////////////////////////////////////   
//
//  Local Signal Declarations
//

    wire    SCK;                    // Internal name for SSP_SCK
    
    wire    [2:0] RSel;             // Internal name for SSP_RA
    wire    Sel_TDR;                // Select - Transmit Data Register
    wire    Sel_RDR;                // Select - Receive Data Register
    wire    Sel_UCR;                // Select - UART Control Register
    wire    Sel_SPR;                // Select - Scratch Pad Register
    
    wire    [7:0] TD, THR;          // Transmit Data, Transmit Holding Register
    wire    TFC;                    // TDR: Transmit FIFO Clear
    reg     HLD;                    // TDR: Transmit Hold
    reg     TxHold;                 // Transmit Hold, synchronized to Clk
    wire    RE_THR;                 // Read Enable - Transmit Holding Register
    wire    WE_THR, ClrTHR;         // Write Enable - THR, Clear/Reset THR
    wire    TF_FF, TF_EF, TF_HF;    // Transmit FIFO Flags - Full, Empty, Half

    wire    [8:0] RD, RHR;          // Receive Data (In), Receive Holding Reg
    wire    RFC;                    // TDR: Receive FIFO Clear
    wire    WE_RHR;                 // Write Enable - RHR
    wire    RE_RHR, ClrRHR;         // Read Enable - RHR, Clear/Reset RHR
    wire    RF_FF, RF_EF, RF_HF;    // Receive FIFO Flags - Full, Empty, Half
    wire    [(pTF_Depth + 4):0] TFCnt;  // Tx FIFO Count
    wire    [(pRF_Depth + 4):0] RFCnt;  // RX FIFO Count
    
    reg     [ 7:0] TDR;             // Transmit Data Register
    reg     [11:0] RDR;             // Receive Data Register, UART Status Reg
    reg     [11:0] UCR, USR, SPR;   // UART Control, Status, & Scratch Pad Regs
    reg     [ 7:0] RTFThr;          // UART Rx/Tx FIFO Threshold Register
    
    wire    [1:0] MD;               // UCR: Operating Mode
    wire    RTSo, IE;               // UCR: RTS Output, Interrupt Enable
    wire    [3:0] FMT;              // UCR: Format (UCR[3:0] Reserved for Baud)

    reg     Len, NumStop, ParEn;    // Char Length, # Stop Bits, Parity Enable
    reg     [1:0] Par;              // Parity Selector
    reg     [3:0] PS;               // Baud Rate Prescaler
    reg     [7:0] Div;              // Baud Rate Divider
    reg     [3:0] CCntVal;          // RTO Character Length: {10 | 11 | 12} - 1
    wire    [3:0] RTOVal;           // RTO Character Delay Value: (N - 1)
    
    wire    RTSi, CTSi;             // USR: RTS Input, CTS Input
    reg     [1:0] RS, TS;           // USR: Rcv Status, Xmt Status
    wire    iRTO;                   // USR: Receive Timeout Interrupt
    wire    iRHF;                   // USR: Receive Half Full Interrupt
    wire    iTHE;                   // USR: Transmit Half Empty Interrupt
    wire    iTFE;                   // USR: Transmit FIFO Empty Interrupt
    
    reg     En;                     // delayed SSP_En (1 SCK period)
    wire    Clr_Int;                // Clear Interrupt Flags - read of USR
    
    wire    WE_SPR;                 // Write Enable: Scratch Pad Register
    wire    WE_RTFThr;              // Write Enable: Rx/Tx FIFO Threshold Reg.
    reg     [11:0] SPR_DO;          // SPR Output Data
    
    wire    TxD;                    // UART TxD Output (Mode Multiplexer Input)
    reg     RxD;                    // UART RxD Input (Mode Multiplexer Output)
    
    wire    TRDY;                   // RDR: Transmit Ready
    wire    RRDY;                   // RDR: Receive Ready
    wire    RTO;                    // RDR: Receive Timeout
    wire    RERR;                   // RDR: Receive Error 
    
    wire    RcvTimeout;             // Receive Timeout
    
    wire    [7:0] Version = pVersion;
    wire    [3:0] TFLen   = pTF_Depth;  // Len = (2**(pTF_Depth + 4))
    wire    [3:0] RFLen   = pRF_Depth;
    wire    [3:0] TFThr   = pxFThr;     // Thr = pxFThr ? pxFThr*(2**pTFLen) : 1
    wire    [3:0] RFThr   = pxFThr;   

////////////////////////////////////////////////////////////////////////////////    
//
//  Implementation
//

assign SCK = SSP_SCK;

//  Assign SSP Read/Write Strobes

assign SSP_WE = SSP_SSEL &  SSP_WnR & SSP_EOC;
assign SSP_RE = SSP_SSEL & ~SSP_WnR & SSP_EOC;

//  Break out Register Select Address

assign RSel = SSP_RA;

assign Sel_TDR = (RSel == pTDR);
assign Sel_RDR = (RSel == pRDR);
assign Sel_USR = (RSel == pUSR);
assign Sel_UCR = (RSel == pUCR);
assign Sel_SPR = (RSel == pSPR);

//  Assign SPR Data Output based on sub-addresses: SPR[11:9]

always @(*)
begin
    case(SPR[11:9])
        pRev    : SPR_DO <= {4'b0, Version[7:0]};
        pLen    : SPR_DO <= {4'b0, pRF_Depth[3:0], pTF_Depth[3:0]};
        pFThr   : SPR_DO <= {4'b0, RTFThr};
        pTHR    : SPR_DO <= {4'b0, THR};
        pRHR    : SPR_DO <= {3'b0, RHR};
        pTFCnt  : SPR_DO <= {1'b0, TFCnt[(pTF_Depth + 4):0]};
        pRFCnt  : SPR_DO <= {1'b0, RFCnt[(pRF_Depth + 4):0]};
        default : SPR_DO <= SPR;
    endcase
end

//  Drive SSP Output Data Bus

always @(*)
begin
    case(RSel)
        pUCR    : SSP_DO <= ((SSP_SSEL) ? UCR                              : 0);
        pUSR    : SSP_DO <= ((SSP_SSEL) ? USR                              : 0);
        pTDR    : SSP_DO <= ((SSP_SSEL) ? TDR                              : 0);
        pRDR    : SSP_DO <= ((SSP_SSEL) ? RDR                              : 0);
        pSPR    : SSP_DO <= ((SSP_SSEL) ? SPR_DO                           : 0);
        default : SSP_DO <= ((SSP_SSEL) ? {1'b0, RFCnt[(pRF_Depth+4) : 0]} : 0);
    endcase
end

//  Assert IRQ when IE is set

assign Rst_IRQ = Rst | Clr_Int;

always @(posedge Clk)
begin
    if(Rst_IRQ)
        IRQ <= 0;
    else if(~IRQ)
        IRQ <= #1 IE & (iTFE | iTHE | iRHF | iRTO);
end

////////////////////////////////////////////////////////////////////////////////
//
//  Write UART Control Register
//

always @(negedge SCK or posedge Rst)
begin
    if(Rst)
        UCR <= #1 0;
    else if(Sel_UCR)
        UCR <= #1 ((SSP_WE) ? SSP_DI : USR);
end

//  Assign UCR Fields

assign MD   = UCR[11:10];
assign RTSo = UCR[9];
assign IE   = UCR[8];
assign FMT  = UCR[7:4];

//  Format Decode

always @(FMT)
case(FMT)
    4'b0000 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
    4'b0001 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
    4'b0010 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b1, 2'b00};   // 8O1
    4'b0011 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b1, 2'b01};   // 8E1
    4'b0100 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b1, 2'b10};   // 8S1
    4'b0101 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b1, 2'b11};   // 8M1
    4'b0110 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
    4'b0111 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b1, 1'b0, 2'b00};   // 8N2
    4'b1000 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b1, 1'b1, 2'b00};   // 8O2
    4'b1001 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b1, 1'b1, 2'b01};   // 8E2
    4'b1010 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b1, 1'b1, 2'b10};   // 8S2
    4'b1011 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b1, 1'b1, 2'b11};   // 8M2
    4'b1100 : {Len, NumStop, ParEn, Par} <= {1'b1, 1'b0, 1'b1, 2'b00};   // 7O1
    4'b1101 : {Len, NumStop, ParEn, Par} <= {1'b1, 1'b0, 1'b1, 2'b01};   // 7E1
    4'b1110 : {Len, NumStop, ParEn, Par} <= {1'b1, 1'b1, 1'b1, 2'b00};   // 7O2
    4'b1111 : {Len, NumStop, ParEn, Par} <= {1'b1, 1'b1, 1'b1, 2'b01};   // 7E2
endcase

//  Baud Rate Generator's PS and Div for defined Baud Rates (48 MHz Osc)
//
//  Profibus Baud Rates
//
//  {PS, Div} <= {4'h0, 8'h00}; // PS= 1; Div=  1; BR=3.0M
//  {PS, Div} <= {4'h0, 8'h01}; // PS= 1; Div=  2; BR=1.5M
//  {PS, Div} <= {4'h0, 8'h05}; // PS= 1; Div=  6; BR=500.0k
//  {PS, Div} <= {4'h0, 8'h0F}; // PS= 1; Div= 16; BR=187.5k
//
//  Standard Baud Rates
//
//  {PS, Div} <= {4'hC, 8'h00}; // PS=13; Div=  1; BR=230.4k
//  {PS, Div} <= {4'hC, 8'h01}; // PS=13; Div=  2; BR=115.2k
//  {PS, Div} <= {4'hC, 8'h02}; // PS=13; Div=  3; BR= 76.8k
//  {PS, Div} <= {4'hC, 8'h03}; // PS=13; Div=  4; BR= 57.6k
//  {PS, Div} <= {4'hC, 8'h05}; // PS=13; Div=  6; BR= 38.4k
//  {PS, Div} <= {4'hC, 8'h07}; // PS=13; Div=  8; BR= 28.8k
//  {PS, Div} <= {4'hC, 8'h0B}; // PS=13; Div= 12; BR= 19.2k
//  {PS, Div} <= {4'hC, 8'h0F}; // PS=13; Div= 16; BR= 14.4k
//  {PS, Div} <= {4'hC, 8'h17}; // PS=13; Div= 24; BR=  9.6k
//  {PS, Div} <= {4'hC, 8'h2F}; // PS=13; Div= 48; BR=  4.8k
//  {PS, Div} <= {4'hC, 8'h5F}; // PS=13; Div= 96; BR=  2.4k
//  {PS, Div} <= {4'hC, 8'hBF}; // PS=13; Div=192; BR=  1.2k
//
//  Baud Rate Generator's PS and Div for defined Baud Rates (29.4912 MHz)
//
//  Extended Baud Rates
//
//  {PS, Div} <= {4'h0, 8'h00}; // PS= 1; Div=  1; BR=1843.2k
//  {PS, Div} <= {4'h0, 8'h01}; // PS= 1; Div=  2; BR= 921.6k
//  {PS, Div} <= {4'h0, 8'h02}; // PS= 1; Div=  3; BR= 614.4k
//  {PS, Div} <= {4'h0, 8'h03}; // PS= 1; Div=  4; BR= 460.8k
//  {PS, Div} <= {4'h0, 8'h05}; // PS= 1; Div=  6; BR= 307.2k
//  {PS, Div} <= {4'h0, 8'h07}; // PS= 1; Div=  8; BR= 230.4k
//  {PS, Div} <= {4'h0, 8'h0B}; // PS= 1; Div= 12; BR= 153.6k
//
//  Standard Baud Rates
//
//  {PS, Div} <= {4'h0, 8'h0F}; // PS= 1; Div= 16; BR= 115.2k
//  {PS, Div} <= {4'h0, 8'h17}; // PS= 1; Div= 24; BR=  76.8k
//  {PS, Div} <= {4'h0, 8'h1F}; // PS= 1; Div= 32; BR=  57.6k
//  {PS, Div} <= {4'h0, 8'h2F}; // PS= 1; Div= 48; BR=  38.4k
//  {PS, Div} <= {4'h0, 8'h3F}; // PS= 1; Div= 64; BR=  28.8k
//  {PS, Div} <= {4'h0, 8'h5F}; // PS= 1; Div= 96; BR=  19.2k
//  {PS, Div} <= {4'h0, 8'h7F}; // PS= 1; Div=128; BR=  14.4k
//  {PS, Div} <= {4'h0, 8'hBF}; // PS= 1; Div=192; BR=   9.6k
//  {PS, Div} <= {4'h0, 8'hFF}; // PS= 1; Div=256; BR=   7.2k
//  {PS, Div} <= {4'h1, 8'hBF}; // PS= 2; Div=192; BR=   4.8k
//  {PS, Div} <= {4'h1, 8'hFF}; // PS= 3; Div=256; BR=   3.6k
//  {PS, Div} <= {4'h3, 8'hBF}; // PS= 4; Div=192; BR=   2.4k
//  {PS, Div} <= {4'h3, 8'hFF}; // PS= 4; Div=256; BR=   1.8k
//  {PS, Div} <= {4'h7, 8'hBF}; // PS= 8; Div=192; BR=   1.2k
//  {PS, Div} <= {4'h7, 8'hFF}; // PS= 8; Div=256; BR=   0.9k
//  {PS, Div} <= {4'hF, 8'hBF}; // PS=16; Div=192; BR=   0.6k
//  {PS, Div} <= {4'hF, 8'hFF}; // PS=16; Div=256; BR=   0.45k

//  Receive Timeout Character Frame Length

always @(FMT)
case(FMT)
    4'b0000 : CCntVal <= 4'h9;   // 8N1,  9 <= 10 - 1
    4'b0001 : CCntVal <= 4'h9;   // 8N1,  9 <= 10 - 1
    4'b0010 : CCntVal <= 4'hA;   // 8O1, 10 <= 11 - 1
    4'b0011 : CCntVal <= 4'hA;   // 8E1, 10 <= 11 - 1
    4'b0100 : CCntVal <= 4'hA;   // 8S1, 10 <= 11 - 1
    4'b0101 : CCntVal <= 4'hA;   // 8M1, 10 <= 11 - 1
    4'b0110 : CCntVal <= 4'h9;   // 8N1,  9 <= 10 - 1
    4'b0111 : CCntVal <= 4'hA;   // 8N2, 10 <= 11 - 1
    4'b1000 : CCntVal <= 4'hB;   // 8O2, 11 <= 12 - 1
    4'b1001 : CCntVal <= 4'hB;   // 8E2, 11 <= 12 - 1
    4'b1010 : CCntVal <= 4'hB;   // 8S2, 11 <= 12 - 1
    4'b1011 : CCntVal <= 4'hB;   // 8M2, 11 <= 12 - 1
    4'b1100 : CCntVal <= 4'h9;   // 7O1,  9 <= 10 - 1
    4'b1101 : CCntVal <= 4'h9;   // 7E1,  9 <= 10 - 1
    4'b1110 : CCntVal <= 4'h9;   // 7O2,  9 <= 10 - 1
    4'b1111 : CCntVal <= 4'h9;   // 7E2,  9 <= 10 - 1
endcase

assign RTOVal = (pRTOChrDlyCnt - 1);    // Set RTO Character Delay Count

////////////////////////////////////////////////////////////////////////////////
//
//  USR Register and Operations
//

always @(*)
begin
    case({RF_FF, RF_HF, RF_EF})
        3'b000 : RS <= 2'b01;   // Not Empty, < Half Full
        3'b001 : RS <= 2'b00;   // Empty
        3'b010 : RS <= 2'b10;   // > Half Full, < Full
        3'b011 : RS <= 2'b00;   // Not Possible/Not Allowed
        3'b100 : RS <= 2'b00;   // Not Possible/Not Allowed
        3'b101 : RS <= 2'b00;   // Not Possible/Not Allowed
        3'b110 : RS <= 2'b11;   // Full
        3'b111 : RS <= 2'b00;   // Not Possible/Not Allowed
    endcase
end

always @(*)
begin
    case({TF_FF, TF_HF, TxIdle})
        3'b000 : TS <= 2'b01;   // Not Empty, < Half Full
        3'b001 : TS <= 2'b00;   // Empty
        3'b010 : TS <= 2'b10;   // > Half Full, < Full
        3'b011 : TS <= 2'b00;   // Not Possible/Not Allowed
        3'b100 : TS <= 2'b00;   // Not Possible/Not Allowed
        3'b101 : TS <= 2'b00;   // Not Possible/Not Allowed
        3'b110 : TS <= 2'b11;   // Full
        3'b111 : TS <= 2'b00;   // Not Possible/Not Allowed
    endcase
end

always @(posedge SCK or posedge Rst)
begin
    if(Rst)
        USR <= #1 0;
    else
        USR <= #1 {MD, RTSi, CTSi, RS, TS, iRTO, iRHF, iTHE, iTFE};
end

//  Read UART Status Register

always @(posedge SCK or posedge Rst)
begin
    if(Rst)
        En <= #1 0;
    else
        En <= #1 SSP_En;
end

//  Generate Clr_Int on rising edge of SSP_En if Sel_USR asserted
//      and rising edge on SSP_En and any interrupt flags set in USR
//      change clock domains from SCK to Clk (UART)

re1ce   RED1 (
            .den(Sel_USR & (SSP_En & ~En) & |USR[3:0]),
            .din(SCK), 
            .clk(Clk),
            .rst(Rst), 
            .trg(),
            .pls(Clr_Int)
        );

////////////////////////////////////////////////////////////////////////////////
//
//  BRR - Baud Rate Register
//

always @(posedge SCK or posedge Rst)
begin
    if(Rst)
        {PS, Div} <= #1 {pPS_Default, pDiv_Default};        // Default: 9600 bps
    else if(Sel_USR)
        {PS, Div} <= #1 ((SSP_WE) ? SSP_DI : {PS, Div});
end

////////////////////////////////////////////////////////////////////////////////
//
//  TDR/RDR Registers and Operations
//

//  Write Transmit Data Register

assign WE_TDR = SSP_WE & Sel_TDR & TRDY;

always @(posedge SCK or posedge Rst)
begin
    if(Rst)
        TDR <= #1 8'b0;
    else if(WE_TDR)
        TDR <= #1 SSP_DI[7:0];
end

assign TD = TDR;

//  Clear Transmit Holding Register

assign TFC = SSP_DI[pTFC] & WE_TDR;

re1ce   RED2 (
            .den(TFC),
            .din(SCK), 
            .clk(Clk),
            .rst(Rst), 
            .trg(),
            .pls(ClrTHR)
        );

//  Clear Receive Holding Register

assign RFC = SSP_DI[pRFC] & WE_TDR;

re1ce   RED3 (
            .den(RFC), 
            .din(SCK), 
            .clk(Clk),
            .rst(Rst), 
            .trg(),
            .pls(ClrRHR)
        );

//  Latch/Register the Transmit Hold Bit on writes to TDR

always @(posedge SCK or posedge Rst)
begin
    if(Rst)
        HLD <= #1 0;
    else if(WE_TDR)
        HLD <= #1 SSP_DI[pHLD];
end

//  Write Transmit Holding Register (FIFO)

re1ce   RED4 (
            .den(WE_TDR),
            .din(SCK), 
            .clk(Clk),
            .rst(Rst), 
            .trg(),
            .pls(WE_THR)
        );

//  Set TxHold when the THR is written
           
always @(posedge Clk)
begin
    if(Rst)
        TxHold <= #1 0;
    else if(WE_THR)
        TxHold <= #1 HLD;
end

//  Read Receive Data Register

assign TRDY = ~TF_FF;
assign RRDY = ~RF_EF;
assign RTO  = RcvTimeout;
assign RERR = RHR[8];

//  Capture and Hold Receive Data Register on SCK clock domain

always @(posedge SCK or posedge Rst)
begin
    if(Rst)
        RDR <= #1 0;
    else if(~SSP_En)
        RDR <= #1 {TRDY, RRDY, RTO, RERR, RHR[7:0]};
end    

//  Read Receive Holding Register
//      Generate RE_RHR read pulse only when the captured value indicates that
//      RDR contains data because there is data in the Receive FIFO, i.e. RHR.

assign RE_RDR = Sel_RDR & ~SSP_WnR & (SSP_En & ~En) & RDR[10];

re1ce   RED5 (
            .den(RE_RDR), 
            .din(SCK), 
            .clk(Clk),
            .rst(Rst), 
            .trg(),
            .pls(RE_RHR)
        );

////////////////////////////////////////////////////////////////////////////////
//
//  Write Scratch Pad Register
//

assign WE_SPR = SSP_WE & Sel_SPR;

always @(posedge SCK or posedge Rst)
begin
    if(Rst)
        SPR <= #1 0;
    else if(WE_SPR)
        SPR <= #1 SSP_DI;
end

assign WE_RTFThr = SSP_WE & Sel_SPR & (SSP_DI[11:9] == pFThr) & SSP_DI[8];

always @(posedge SCK or posedge Rst)
begin
    if(Rst)
        RTFThr <= #1 {RFThr, TFThr};
    else if(WE_RTFThr)
        RTFThr <= #1 SSP_DI;
end

////////////////////////////////////////////////////////////////////////////////
//
//  Xmt/Rcv Holding Register Instantiations - Dual-Port Synchronous FIFOs
//
//  THR FIFO - 2**(pTFLen + 4) x pWidth FIFO

DPSFnmCE    #(
                .addr((pTF_Depth + 4)),
                .width(pWidth),
                .init(pTF_Init)
            ) TF1 (
                .Rst(Rst | ClrTHR), 
                .Clk(Clk), 
                .WE(WE_THR), 
                .RE(RE_THR), 
                .DI(TD), 
                .DO(THR), 
                .FF(TF_FF),
                .HF(TF_HF), 
                .EF(TF_EF), 
                .Cnt(TFCnt)
            );

//  RHR FIFO - 2**(pRFLen + 4) x (pWidth + 1) FIFO

DPSFnmCE    #(
                .addr((pRF_Depth + 4)),
                .width((pWidth + 1)),
                .init(pRF_Init)
            ) RF1 (
                .Rst(Rst | ClrRHR), 
                .Clk(Clk), 
                .WE(WE_RHR), 
                .RE(RE_RHR), 
                .DI(RD), 
                .DO(RHR), 
                .FF(RF_FF),
                .HF(RF_HF), 
                .EF(RF_EF), 
                .Cnt(RFCnt)
            );

////////////////////////////////////////////////////////////////////////////////
//
//  Configure external/internal serial port signals according to MD[1:0]
//      MD[1:0] = 0,1 - RS-233; 2,3 - RS-485

assign RS232 = ~MD[1];
assign RS485 =  MD[1];

//  Set RS-232/Rs-485 TxD

assign TxD_232 = (RS232 ? TxD : 1);
assign TxD_485 = (RS485 ? TxD : 1);

//  Assert DE in the RS-485 modes whenever the TxSM is not idle, and deassert
//      whenever the RS-485 modes are not selected

assign xDE = (RS485 ? ~TxIdle : 0);

//  Connect the UART's RxD serial input to the appropriate external RxD input
//      Hold RxD to logic 1 when in the RS-485 w/o Loopback mode and the TxSM
//      is transmitting data. In this manner, the external xOE signal to the 
//      RS-485 transceiver can always be asserted.

always @(posedge Clk or posedge Rst)
begin
    if(Rst)
        RxD <= #1 1;
    else
        case(MD)
            2'b00 : RxD <= #1 RxD_232;
            2'b01 : RxD <= #1 RxD_232;
            2'b10 : RxD <= #1 (TxIdle ? RxD_485 : 1);
            2'b11 : RxD <= #1 RxD_485;
        endcase
end

// RS-232 auto-Handshaking is implemented as Ready-To-Receive (RTR) based on
//      the Rcv FIFO flag settings. xRTS, which should connect to the receiving
//      side's xCTS, is asserted whenever the local receive FIFO is less than 
//      half full. If a similar UART with hardware handshaking is connected,
//      then that transmitter should stop sending until the local FIFO is read
//      so that it is below the HF mark. Since local reads of the receive FIFO
//      are expected to be much faster than the RS-232 baud rate, it is not 
//      expected that hysteresis will be required to prevent rapid assertion
//      and deassertion of RTS.
//
//      This handshaking mechanism was selected for the automatic handshaking
//      mode because it prevents (or attempts to prevent) receive FIFO over-
//      flow in the receiver. Furthermore, it reduces the software workload in
//      the transmitter's send routines.
//
//      For all other modes, the CTSi control signal to the UART_TXSM is held
//      at logic one. This effectively disables the TxSM's handshaking logic,
//      and allows the transmitter to send data as soon as data is written to
//      Xmt FIFO.

always @(*)
begin
    case(MD)
        2'b00 : xRTS <= RTSo;
        2'b01 : xRTS <= ~RF_HF;
        2'b10 : xRTS <= 0;
        2'b11 : xRTS <= 0;
    endcase
end

assign RTSi = ((RS232) ? xRTS : xDE);
assign CTSi = ((MD == 1) ? xCTS : 1);

////////////////////////////////////////////////////////////////////////////////
//
//  UART Baud Rate Generator Instantiation
//

UART_BRG    BRG (
                .Rst(Rst), 
                .Clk(Clk), 
                .PS(PS), 
                .Div(Div), 
                .CE_16x(CE_16x)
            );

////////////////////////////////////////////////////////////////////////////////
//
//  UART Transmitter State Machine & Shift Register Instantiation
//

UART_TXSM   XMT (
                .Rst(Rst), 
                .Clk(Clk), 
                
                .CE_16x(CE_16x), 
                
                .Len(Len), 
                .NumStop(NumStop), 
                .ParEn(ParEn), 
                .Par(Par),
                
                .TF_RE(RE_THR), 
                .THR(THR), 
                .TF_EF(TF_EF | TxHold), 
                
                .TxD(TxD), 
                .CTSi(CTSi), 
            
                .TxIdle(TxIdle), 
                .TxStart(), 
                .TxShift(), 
                .TxStop()
            );

////////////////////////////////////////////////////////////////////////////////
//
//  UART Receiver State Machine & Shift Register Instantiation
//

UART_RXSM   RCV (
                .Rst(Rst), 
                .Clk(Clk), 
                
                .CE_16x(CE_16x),
                
                .Len(Len), 
                .NumStop(NumStop), 
                .ParEn(ParEn), 
                .Par(Par),
                
                .RxD(RxD), 
                
                .RD(RD), 
                .WE_RHR(WE_RHR), 
                
                .RxWait(), 
                .RxIdle(RxIdle), 
                .RxStart(), 
                .RxShift(), 
                .RxParity(), 
                .RxStop(), 
                .RxError()
            );

////////////////////////////////////////////////////////////////////////////////
//
//  UART Receive Timeout Module Instantiation
//

UART_RTO    TMR (
                .Rst(Rst), 
                .Clk(Clk),
                
                .CE_16x(CE_16x),
                
                .WE_RHR(WE_RHR), 
                .RE_RHR(RE_RHR),
                
                .CCntVal(CCntVal), 
                .RTOVal(RTOVal),
                
                .RcvTimeout(RcvTimeout)
            );

////////////////////////////////////////////////////////////////////////////////
//
//  UART Interrupt Generator Instantiation
//

UART_INT    INT (
                .Rst(Rst), 
                .Clk(Clk), 
                
                .TF_HF(TF_HF), 
                .TF_EF(TF_EF), 
                .RF_HF(RF_HF), 
                .RF_EF(RF_EF),
                
                .RTO(RTO), 
                
                .Clr_Int(Clr_Int),
                .USR(USR[3:0]),
                
                .iTFE(iTFE), 
                .iTHE(iTHE), 
                .iRHF(iRHF), 
                .iRTO(iRTO)
            );

endmodule
