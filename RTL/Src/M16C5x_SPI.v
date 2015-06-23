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
// Create Date:     14:18:11 06/16/2013 
// Design Name:     M16C5x SPI Interface
// Module Name:     M16C5x_SPI
// Project Name:    C:\XProjects\ISE10.1i\M16C5x 
// Target Devices:  SRAM-based FPGAs
// Tool versions:   Xilinx ISE 10.1i SP3
//
// Description:
//
//  This module implements an SPI Master for the M16C5x microcontroller. The
//  interface is mapped onto the TRISC and PORTA output/input registers. It pro-
//  vides status outputs that can be read using the PORTA input register. Thus,
//  a sophisticated SPI interface is implemented such that the M16C5x firmware
//  is not required to manage the low level elements of the interface. This
//  frees up the M16C5x core to perform other functions: servicing other peri-
//  pherals or making computations.
//
//  The control register for the SPI interface is mapped onto TRISC. This is a
//  write-only register in the M16C5x core. The TRISC register will provide the
//  following:
//
//      (1). SPI Read Enable        (1) - 0 - Disable Reads; 1 - Enable Reads
//      (2). Slave Select           (1) - 0 - nCS[0]; 1 - nCS[1]
//      (3). SPI Mode Select        (2) - 0, 1, 2, 3
//      (4). Shift Clk Rate Select  (3) - 2, 4, 8, 16, 32, 64 (default), 128
//      (5). Shift Direction        (1) - 0 - MSB first (default); 1 - LSB first
//
//  A complete description of the Shift Clock Rate Select and SPI Mode Select
//  fields is provided in the Description section of SPIxIF.v module. The Slave
//  Select bit allows the M16C5x core to select between two SPI devices; the
//  interface drives nCS[0] if the bit is set to 0 (default), or nCS[1] if the
//  bit is set to 1. The SPI Read Enable bit is the value written to bit 9 of
//  the transmit FIFO. If bit 9 is set, the SPI data received on MISO is written to
//  the Receive FIFO. Refer to the Description section of SPIxIF.v for more
//  information regarding the use of bit 9 of the transmit FIFO. The Shift
//  Direction bit determines if the shift direction is MSB first (default) or 
//  LSB first. (Unless otherwise set, the default after Rst of the CR sets the
//  SPIxIF to operate MSB first, divide Clk by 64, Mode 0, select slave 0, and
//  disable SPI reads: 0x60.)
//
//  Five bits are output by the module for use by the M16C5x core to manage the
//  peripheral. The SS bit is set when the SPIxIF is performing an SPI shift. It
//  is used, along with the Slave Select bit, to generate nCS[1:0]. If SS is a
//  logic 1, the SPIxIF is busy. The FIFO Full and Empty flags for each FIFO are
//  output. The M16C5x core firmware can their state along with information on
//  their depth to manage the sending and receiving of data to/from an SPI com-
//  ponent.
//
// Dependencies:    SPIxIF.v    - SPI Master Interface
//                  DPSFnmCE.v  - LUT-based Synchronous Parameterizable FIFO 
//
// Revision: 
//
//  0.01    13F16   MAM     Initial creation
//
//  1.00    13F26   MAM     Included ClkEn in the transmit FIFO write enable and
//                          receive FIFO read enable signals.
//
//  1.10    13F06   MAM     Changed polarity of chip select outputs from active
//                          low to active high.
//
//  1.20    13G14   MAM     Improved parameterization. All relevant parameters
//                          can be set through instantiation interface.
//  
// Additional Comments:
//
//  CR[0] - Read FIFO Disable
//
////////////////////////////////////////////////////////////////////////////////

module M16C5x_SPI #(
    parameter pCR_Default = 8'b0_110_00_0_0,    // Default SPI Interface Setting
    parameter pTF_Depth = 4,    // Default Transmit FIFO Depth: 2**pTF_Depth
    parameter pRF_Depth = 4,    // Default Receive FIFO Depth:  2**pRF_Depth
    parameter pTF_Init  = "Src/TF_Init.coe",    // Tx FIFO Memory Initialization
    parameter pRF_Init  = "Src/RF_Init.coe"     // Rx FIFO Memory Initialization
)(
    input   Rst,                // System Reset
    input   Clk,                // System Clk; SCK derived from Clk
    
    input   ClkEn,              // System Clock Enable
    
    input   WE_CR,              // Control Register Write Enable (WE_TRISx)
    input   WE_TF,              // Transmit FIFO Write Enable (WE_PORTx)
    input   RE_RF,              // Receive FIFO Read Enable (RE_PORTx)
    input   [7:0] DI,           // Data Input (Cntl Reg/Transmit FIFO Data In)
    output  [7:0] DO,           // Data Output (Receive FIFO Data Out)
    
    output  [1:0] CS,           // SPI Interface Chip Select (active high)
    output  SCK,                // SPI Interface Serial Clock (idle set by Mode)
    output  MOSI,               // SPI Interface Master Out/Slave In Serial Out
    input   MISO,               // SPI Interface Master In/Slave Out Serial In
    
    output  SS,                 // SPI Interface Slave Select Active
    output  TF_FF,              // SPI Interface Transmit FIFO Full Flag
    output  TF_EF,              // SPI Interface Transmit FIFO Empty Flag
    output  RF_FF,              // SPI Interface Receive FIFO Full Flag
    output  RF_EF               // SPI Interface Receive FIFO Empty Flag
);

////////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

reg     [7:0] CR = pCR_Default; // Control Register

wire    REn;
wire    Sel;
wire    [1:0] Mode;
wire    [2:0] Rate;
wire    Dir;

wire    DAV;
wire    FRE;
wire    [8:0] TD;

wire    FWE;
wire    [7:0] RD;

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

always @(posedge Clk)
begin
    if(Rst)
        CR <= #1 pCR_Default;
    else if(WE_CR & ClkEn)
        CR <= #1 DI;
end

assign REn  = CR[0];
assign Sel  = CR[1];
assign Mode = CR[3:2];
assign Rate = CR[6:4];
assign Dir  = CR[7];

// Instantiate the Transmit FIFO module

DPSFnmCE    #(
                .addr(pTF_Depth),
                .width(9),
                .init(pTF_Init)
            ) TF (
                .Rst(Rst), 
                .Clk(Clk),
                
                .WE(WE_TF & ClkEn), 
                .DI({REn, DI}), 

                .RE(FRE), 
                .DO(TD),
                
                .FF(TF_FF), 
                .EF(TF_EF), 
                .HF(), 
                .Cnt()
            );

assign DAV = ~TF_EF;

// Instantiate the Receive FIFO module

DPSFnmCE    #(
                .addr(pRF_Depth),
                .width(8),
                .init(pRF_Init)
            ) RF (
                .Rst(Rst), 
                .Clk(Clk),
                
                .WE(FWE), 
                .DI(RD), 

                .RE(RE_RF & ClkEn), 
                .DO(DO),
                
                .FF(RF_FF), 
                .EF(RF_EF), 
                .HF(), 
                .Cnt()
            );

// Instantiate the SPI Master Interface module

SPIxIF  MSTR (
            .Rst(Rst),              // System Reset
            .Clk(Clk),              // System Clock
            
            .LSB(Dir),              // Shift Direction 
            .Mode(Mode),            // SPI Operating Mode
            .Rate(Rate),            // SCK Rate Divider
            
            .DAV(DAV),              // Complement of TF_EF

            .FRE(FRE),              // Transmit FIFO Read Enable 
            .TD(TD),                // Transmit Data; bit 8 enables receiver

            .FWE(FWE),              // Receive FIFO Write Enable
            .RD(RD),                // Receive Data

            .SS(SS),                // SPI Slave Select
            .SCK(SCK),              // SPI Serial Clock
            .MOSI(MOSI),            // SPI Master Out/Slave In
            .MISO(MISO)             // SPI Master In/Slave Out
        );
        
//  Generate Slave Device Chip Select based on SS and Sel bit in CR
        
assign CS[0] = ((~Sel) ? SS : 0);
assign CS[1] = (( Sel) ? SS : 0);
    
endmodule
