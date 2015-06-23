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
// Create Date:     20:31:58 03/17/2008 
// Design Name:     Serial Peripheral Interconnect (SPI) Master Interface
// Module Name:     SPIxIF.v 
// Project Name:    VerilogComponentsLib\SPI and SSP Components\SPI Master
// Target Devices:  FPGA
// Tool versions:   ISE 10.1i SP3 
//
// Description:
//
//  This module implements a full-duplex (Master) SPI interface. It is a major
//  revision of the previous implementation which basically implemented the SPI
//  operating modes within a Synchronous Serial Peripheral (SSP) as used in NXP
//  ARM LPC21xx microcontrollers. In an NXP SSP, an SPI-like peripheral is used
//  that has a programmable length shift register which performs serial I/O
//  data transfers in a single cycle: Slave Select (SS) is asserted and de-
//  asserted for each data transfer cycle. The only SPI-like feature of the pre-
//  vious implementation was the ability to program the clock idle state and the
//  data sampling edge, i.e. the SPI operating modes. Because a transfer cycle
//  always deasserted SS, the original implementation would require substan-
//  tial modification in order to be useful with standard SPI-compatible devices
//  such as Serial EEPROMs, serial FRAMs/MRAMs, ADCs/DACs, UARTs, I/O expanders,
//  etc.
//  
//  This module will implement an SPI Master interface that avoids the limita-
//  tions of the previous implementation. It will use a fixed 8-bit interface,
//  but it will support variable length cycles. To operate in this manner, the
//  basic control interface will support an interface that can be easily attach-
//  ed to FIFOs. (The transmit FIFO will use a 9-bit interface, and the receive
//  FIFO will use an 8-bit interface.) An SPI data transfer cycle will start
//  when the transmit FIFO EF indicates that there is data to transmit, and the
//  SPI transfer cycle will terminate when the last bit is shifted out and the
//  transmit FIFO EF indicates that it is empty.
// 
//  The 9th bit of the transmit data will be used to enable the writing of the
//  receive data into the receive FIFO. If the bit is not set, the data shifted
//  in during an 8-bit SPI shift cycle is not captured into the receive FIFO.
//  If the 9th bit is set, then the data shifted into the SPI shift register is
//  captured into the receive FIFO. The 9th bit is expected to be part of the
//  transmit FIFO, so it can be set or cleared for each 8-bit SPI transfer cy-
//  cle. (Note: the 9th bit can be implemented separate from the transmit FIFO,
//  but it would need to be merged into the transmit data bus by the external
//  logic.)
//
//  The explicit read capability provided by the 9th bit is useful when working
//  with SPI devices such as SPI memory devices which do not return any data
//  until a command code and an address have been written. Generally, these
//  devices require several command codes and address bytes to be sent to it
//  before it enables its serial output signal driver and returns the requested
//  data. Therefore, for these devices, the 9th bit is cleared when the command
//  and address bytes are being sent, and the 9th bit set while dummy data is
//  written to and the data received from the device is written into the receive
//  FIFO.
//
//  On the other hand, there are many devices where the data on MISO is consi-
//  dered valid from the onset of a transfer cycle. Devices such as ADCs provide
//  data on MISO that is valid while the conversion command for the next sample
//  is being simultaneously shifted out to the ADC on MOSI. For these devices,
//  the 9th bit is set in the transmit FIFO for each output byte. This causes
//  each received byte to be written to the receive FIFO.
//
//  The SPI interface operates in four modes: Mode 0, 1, 2, and 3. Generally,
//  the mode is selected by two control signals, CPOL and CPHA. CPHA determines
//  the idle state of the SPI clock signal, SCK. The interface shifts data at
//  the beginning of each bit cell. The four operating SPI modes are tabulated
//  in the following table:
//
//  Mode    CPOL    CPHA    :   SCK Idle Level    Sample Edge
//    0       0       0     :         0             Rising
//    1       0       1     :         1             Falling
//    2       1       0     :         0             Falling
//    3       1       1     :         1             Rising
//
//  Examining the table, the sampling edge is set to rising when CPOL and CPHA
//  are the same logic level, and it is set to falling when CPOL and CPHA are
//  complementary logic levels. In other words, the rising edge of SCK occurs in
//  the middle of the bit cell when (CPOL XNOR CPHA) == 1, and the falling edge
//  occurs in the middle of the bit cell when (CPOL XOR CPHA) == 1.
//
//  Two internal signals derived from Mode[1:0] determine the idle state of
//  SCK, SCK_Lvl, and the polarity of SCK used for data sampling, SCK_Inv. A
//  change-of-state (COS) detector is used to dynamically detect changes in the
//  value of SCK_Lvl, and to load the SCK register with the appropriate value
//  when the SPI interface idle, i.e. SS == 0. SCK_Lvl is taken from Mode[0],
//  and SCK_Inv is the XOR of Mode[1] and Mode[0], as indicated in the table
//  above.
//
//  The implementation shifts at one half of the CE frequency. The shift direc-
//  tion is programmable, but MSB first is the default.
//
//  The module contains the SCK generator. A three bit rate select input deter-
//  mines the rate of the SPI clock signal. A 50% duty cycle clock is produced,
//  and two separate clock enables are generated internally for loading and
//  shifting (propagating) the transmit data, and for shifting and writing the
//  receive data. The basic frequency is set by the equation:
//  
//      F(SCK) = Clk / (2**(Rate + 1))
//
//  If rate is set to 0, then the frequency of SCK is one half that of the
//  module's input clock frequency. With Rate set to 7, the SCK frequecy is
//  Clk/256.
//
//  The output shift enable always asserts at the trailing edge of the bit cell,
//  and the input shift enable always asserts in the middle of the bit cell. 
//  These shift enables are independent of the sampling and propagating edges
//  of SCK. The leading edge of the initial output is generated by the output
//  shift register load signal, which is itself generated by a rising edge
//  detector monitoring the DAV signal while slave select is not asserted. Once
//  SS is asserted, the output shift register is synchronously loaded on the TC
//  of the bit counter coincident with output shift register enable signal,
//  CE_OSR. This event also extends SS and reloads the receive enable signal,
//  RdEn. (RdEn was discussed above, and is determined by the 9th of the trans-
//  mit data.) If there is no more data to transmit, SS and RdEn are both de-
//  asserted.
//
//  All of the module control signals are resampled while SS is not asserted.
//  The control signals are held for the duration of a transfer cycle, which is
//  determined by the number of bytes loaded into the external transmit FIFO.
//  To limit the logic complexity, the module does not make prevent the control
//  signals from being changed as the initial transmit data is written. It is
//  necessary for the client of the module to ensure that the control signals
//  signals are stable at least one clock cycle before transmit data is availa-
//  ble.
//
//  With that limitation in mind, the control signals can be changed at any time
//  during a transfer cycle. They will be processed by the module with a one cy-
//  cle delay when SS is not asserted. In this manner, the client logic can dy-
//  namically change the shift direction, SCK operating mode, and SCK operating
//  frequency. This allows the module to be used in situations where the SPI
//  slave devices change modes, rates, and shift directions. For example, a sin-
//  gle SPI interface can be used to support both SPI memory devices (mode 0/3)
//  and SPI ADCs (mode 2) devices.
//
// Dependencies: none
//
// Revision History:
//
//  0.01    08C17   MAM     File Created
//
//  0.02    08C18   MAM     Modified to incorporate SCK_Lvl and a COS detector
//                          on SCK_Lvl to allow the Idle State SCK state to be
//                          dynamically changed.
//
//  0.03    08E09   MAM     Changed comment to reflect that this module is an 
//                          SPI Master Interface.
//
//  1.00    12I07   MAM     Modified to bring into compliance with Verilog 2001.
//                          Modified the interface to use standard control sig-
//                          nals {CPOL, CPHA} and to map the SCK_Lvl and SCK_Inv
//                          signals to the standard SPI modes. To do this, the
//                          standard mode control signals, {CPOL, CPHA}, are run
//                          through a mapping function at the beginning of the
//                          module.
//
//  1.10    12I09   MAM     Restored use of separate transmit and receive shift
//                          registers. Single, combined shift register can't be
//                          used because input data is shifted on the opposite
//                          edge from that used to shift the output data.
//
//  1.20    12I10   MAM     Converted FRE and FWE output signals to FFs. FRE now
//                          pulsed one cycle after the OSR is loaded. FWE now
//                          pulsed one cycle after the last bit is loaded into
//                          the ISR. Converted CE_Cntr from up counter to a down
//                          counter. CE remains a combinatorial signal, but the
//                          CE counter is loaded from a ROM when CE asserts on
//                          basis of the rate captured before SS asserts. CE now
//                          asserts on a fixed value, 0, and the counter is re-
//                          loaded from a ROM. This contrasts with up-counter
//                          implementation which reloaded a fixed value, 0, and
//                          terminated on a variable value. The variable decode
//                          of the counter for CE apparently caused an issue in
//                          simulation that the new down counter resolves.
//
//  1.30    13G06   MAM     Removed code previously commented out. Corrected the
//                          SCK equation. A Rst_SCK was being generated at the
//                          end of every 8 bits. This introduced a discontinuity
//                          in SCK which does not allow frames greater than 8
//                          bits in length to be transmitted. With the removal
//                          the incorrect conditional logic in Rst_SCK, the SSP
//                          Slave and UART modules operate in either SPI Mode 0
//                          or Mode 3.  
//
// Additional Comments:
//
//  The module control signals, LSB, Mode, and Rate, must be set at least one
//  clock cycle before DAV is asserted. Changing these control signals at the
//  same time that DAV is asserted will result in incorrect operation. 
//
////////////////////////////////////////////////////////////////////////////////

module SPIxIF (
    input   Rst,                // System Reset (synchronous)
    input   Clk,                // System Clk
//
    input   LSB,                // SPI LSB First Shift Direction
    input   [1:0] Mode,         // SPI Operating Mode
    input   [2:0] Rate,         // SPI Shift Rate Select: SCK = Clk/2**(Rate+1)
//
    input   DAV,                // SPI Transmit Data Available
    output  reg FRE,            // SPI Transmit FIFO Read Enable
    input   [8:0] TD,           // SPI Transmit Data 
//
    output  reg FWE,            // SPI Receive FIFO Write Enable
    output  [7:0] RD,           // SPI Receive Data
//
    output  reg SS,             // SPI Slave Select
    output  reg SCK,            // SPI Shift Clock
    output  MOSI,               // SPI Master Out, Slave In: Serial Data Output
    input   MISO                // SPI Master In, Slave Out: Serial Data In
);

////////////////////////////////////////////////////////////////////////////////
//
//  Module Parameters
// 

////////////////////////////////////////////////////////////////////////////////    
//
//  Module Declarations
//

reg     Dir;                                // Shift Register Shift Direction

reg     SCK_Lvl, SCK_Inv, COS_SCK_Lvl;      // SCK level and edge control

reg     [2:0] rRate;                        // SPI SCK Rate Select Register
reg     [6:0] CE_Cntr;                      // SPI CE Counter (2x SCK)
wire    CE;                                 // SPI Clock Enable (TC CE_Cntr)

wire    CE_SCK, Rst_SCK;                    // SCK generator control signals

reg     Ld;                                 // SPI Transfer Cycle Start Pulse

wire    CE_OSR, CE_ISR;                     // SPI Shift Register Clock Enables
reg     [7:0] OSR, ISR;                     // SPI Output/Input Shift Registers
reg     RdEn;                               // SPI Read Enable (9th bit in TD)

reg     [2:0] BitCnt;                       // SPI Transfer Cycle Length Cntr
wire    TC_BitCnt;                          // SPI Bit Counter Terminal Count
    
////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Capture the shift direction and hold until end of transfer cycle

always @(posedge Clk)
begin
    if(Rst)
        Dir <= #1 0;            // Default to MSB first
    else if(~SS)
        Dir <= #1 LSB;          // Set shift direction for transfer cycle
end

//  Assign SCK idle level and invert control signals based on Mode

always @(posedge Clk)
begin
    if(Rst) begin
        SCK_Inv <= #1 0;
        SCK_Lvl <= #1 0;
    end else if(~SS) begin
        SCK_Inv <= #1 ^Mode;    // Invert SCK if Mode == 1 or Mode == 2
        SCK_Lvl <= #1 Mode[0];  // Set SCK idle level from LSB of Mode
    end
end

//  Generate change of state pulse when SPI clock idle level changes
//      while Slave Select not asserted

always @(posedge Clk)
begin
    if(Rst)
        COS_SCK_Lvl <= #1 0;
    else
        COS_SCK_Lvl <= #1 ((~SS) ? (SCK_Lvl ^ Mode[0]) : 0);
end

//  Capture SCK rate and hold until the transfer cycle is complete

always @(posedge Clk)
begin
    if(Rst)
        rRate <= #1 ~0;             // Default to slowest rate
    else if(~SS)
        rRate <= #1 Rate;
end

//
//  SPI Transfer Cycle Load Pulse Generator
//

always @(posedge Clk)
begin
    if(Rst)
        Ld <= #1 0;
    else if(~SS)
        Ld <= #1 DAV & ~Ld;
    else if(Ld)
        Ld <= #1 0;
end

//
//  Serial SPI Clock Generator
//

always @(posedge Clk)
begin
    if(Rst)
        CE_Cntr <= #1 ~0;
    else if(CE)
        case(rRate)
            3'b000  : CE_Cntr <= #1 0;
            3'b001  : CE_Cntr <= #1 1;
            3'b010  : CE_Cntr <= #1 3;
            3'b011  : CE_Cntr <= #1 7;
            3'b100  : CE_Cntr <= #1 15;
            3'b101  : CE_Cntr <= #1 31;
            3'b110  : CE_Cntr <= #1 63;
            3'b111  : CE_Cntr <= #1 127;
        endcase
    else if(SS)
        CE_Cntr <= #1 (CE_Cntr - 1);
end

assign CE = (Ld | (~|CE_Cntr));

assign CE_SCK  = CE & SS; // Clock starts with Slave Select Strobe
assign Rst_SCK = Rst | Ld | (COS_SCK_Lvl & ~SS) | (TC_BitCnt & CE_OSR & ~DAV);

always @(posedge Clk)
begin
    if(Rst_SCK) 
        #1 SCK <= (Ld ? SCK_Inv : SCK_Lvl);
    else if(CE_SCK)
        #1 SCK <= ~SCK;
end

//
//  SPI Output Shift Register
//

assign CE_OSR = CE_SCK & (SCK_Inv ^ SCK);   
assign Ld_OSR = Ld | (TC_BitCnt & CE_OSR);   

always @(posedge Clk)
begin
    if(Rst)
        OSR <= #1 0;
    else if(Ld_OSR)
        OSR <= #1 TD;
    else if(CE_OSR)
        OSR <= #1 ((Dir) ? {SCK_Lvl, OSR[7:1]} : {OSR[6:0], SCK_Lvl});
end

assign MOSI = SS & ((Dir) ? OSR[0] : OSR[7]);

//
//  SPI Input Shift Register
//

assign CE_ISR = CE_SCK & (SCK_Inv ^ ~SCK);   

always @(posedge Clk)
begin
    if(Rst)
        ISR <= #1 0;
    else if(Ld)
        ISR <= #1 0;
    else if(CE_ISR)
        ISR <= #1 ((Dir) ? {MISO, ISR[7:1]} : {ISR[6:0], MISO});
end

//
//  SPI SR Bit Counter
//

assign CE_BitCnt  = CE_OSR & SS;
assign Rst_BitCnt = Rst | Ld | (TC_BitCnt & CE_OSR);

always @(posedge Clk)
begin
    if(Rst_BitCnt)
        BitCnt <= #1 7;
    else if(CE_BitCnt)
        BitCnt <= #1 (BitCnt - 1);
end

assign TC_BitCnt = ~|BitCnt;

//
//  SPI Slave Select Generator
//

always @(posedge Clk)
begin
    if(Rst)
        SS <= #1 0;
    else if(Ld_OSR)
        SS <= #1 DAV;
end

//
//  SPI MISO Read Enable Register
//

always @(posedge Clk)
begin
    if(Rst)
        RdEn <= #1 0;
    else if(Ld_OSR)
        RdEn <= #1 ((DAV) ? TD[8] : 0);
end

//
//  SPI Transmit FIFO Read Pulse Generator
//

always @(posedge Clk)
begin
    if(Rst)
        FRE <= #1 0;
    else
        FRE <= #1 (Ld | (DAV & (TC_BitCnt & CE_OSR)));
end

//
//  SPI Receive FIFO Write Pulse Generator
//

always @(posedge Clk)
begin
    if(Rst)
        FWE <= #1 0;
    else
        FWE <= #1 (RdEn & (TC_BitCnt & CE_ISR));
end

assign RD = ISR;

endmodule
