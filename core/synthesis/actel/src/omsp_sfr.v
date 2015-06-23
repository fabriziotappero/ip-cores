//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
//
// *File Name: omsp_sfr.v
// 
// *Module Description:
//                       Processor Special function register
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 34 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-12-29 20:10:34 +0100 (Di, 29 Dez 2009) $
//----------------------------------------------------------------------------
`include "timescale.v"
`include "openMSP430_defines.v"

module  omsp_sfr (

// OUTPUTs
    nmie,                         // Non-maskable interrupt enable
    per_dout,                     // Peripheral data output
    wdt_irq,                      // Watchdog-timer interrupt
    wdt_reset,                    // Watchdog-timer reset
    wdtie,                        // Watchdog-timer interrupt enable

// INPUTs
    mclk,                         // Main system clock
    nmi_acc,                      // Non-Maskable interrupt request accepted
    per_addr,                     // Peripheral address
    per_din,                      // Peripheral data input
    per_en,                       // Peripheral enable (high active)
    per_wen,                      // Peripheral write enable (high active)
    por,                          // Power-on reset
    puc,                          // Main system reset
    wdtifg_clr,                   // Clear Watchdog-timer interrupt flag
    wdtifg_set,                   // Set Watchdog-timer interrupt flag
    wdtpw_error,                  // Watchdog-timer password error
    wdttmsel                      // Watchdog-timer mode select
);

// OUTPUTs
//=========
output              nmie;         // Non-maskable interrupt enable
output       [15:0] per_dout;     // Peripheral data output
output              wdt_irq;      // Watchdog-timer interrupt
output              wdt_reset;    // Watchdog-timer reset
output              wdtie;        // Watchdog-timer interrupt enable

// INPUTs
//=========
input               mclk;         // Main system clock
input               nmi_acc;      // Non-Maskable interrupt request accepted
input         [7:0] per_addr;     // Peripheral address
input        [15:0] per_din;      // Peripheral data input
input               per_en;       // Peripheral enable (high active)
input         [1:0] per_wen;      // Peripheral write enable (high active)
input               por;          // Power-on reset
input               puc;          // Main system reset
input               wdtifg_clr;   // Clear Watchdog-timer interrupt flag
input               wdtifg_set;   // Set Watchdog-timer interrupt flag
input               wdtpw_error;  // Watchdog-timer password error
input               wdttmsel;     // Watchdog-timer mode select


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register addresses
parameter           IE1        = 9'h000;
parameter           IFG1       = 9'h002;

// Register one-hot decoder
parameter           IE1_D      = (256'h1 << (IE1  /2));
parameter           IFG1_D     = (256'h1 << (IFG1 /2)); 


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Register address decode
reg  [255:0]  reg_dec; 
always @(per_addr)
  case (per_addr)
    (IE1  /2):     reg_dec  =  IE1_D;
    (IFG1 /2):     reg_dec  =  IFG1_D;
    default  :     reg_dec  =  {256{1'b0}};
  endcase

// Read/Write probes
wire         reg_lo_write =  per_wen[0] & per_en;
wire         reg_hi_write =  per_wen[1] & per_en;
wire         reg_read     = ~|per_wen   & per_en;

// Read/Write vectors
wire [255:0] reg_hi_wr    = reg_dec & {256{reg_hi_write}};
wire [255:0] reg_lo_wr    = reg_dec & {256{reg_lo_write}};
wire [255:0] reg_rd       = reg_dec & {256{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// IE1 Register
//--------------
wire [7:0] ie1;
wire       ie1_wr  = IE1[0] ? reg_hi_wr[IE1/2] : reg_lo_wr[IE1/2];
wire [7:0] ie1_nxt = IE1[0] ? per_din[15:8]    : per_din[7:0];

reg        nmie;
always @ (posedge mclk or posedge puc)
  if (puc)          nmie  <=  1'b0;
  else if (nmi_acc) nmie  <=  1'b0; 
  else if (ie1_wr)  nmie  <=  ie1_nxt[4];    

reg        wdtie;
always @ (posedge mclk or posedge puc)
  if (puc)           wdtie <=  1'b0;
  else if (ie1_wr)   wdtie <=  ie1_nxt[0];    

assign  ie1 = {3'b000, nmie, 3'b000, wdtie};


// IFG1 Register
//---------------
wire [7:0] ifg1;
wire       ifg1_wr  = IFG1[0] ? reg_hi_wr[IFG1/2] : reg_lo_wr[IFG1/2];
wire [7:0] ifg1_nxt = IFG1[0] ? per_din[15:8]     : per_din[7:0];

reg        nmiifg;
always @ (posedge mclk or posedge puc)
  if (puc)           nmiifg <=  1'b0;
  else if (nmi_acc)  nmiifg <=  1'b1;
  else if (ifg1_wr)  nmiifg <=  ifg1_nxt[4];

reg        wdtifg;
always @ (posedge mclk or posedge por)
  if (por)                        wdtifg <=  1'b0;
  else if (wdtifg_set)            wdtifg <=  1'b1;
  else if (wdttmsel & wdtifg_clr) wdtifg <=  1'b0;
  else if (ifg1_wr)               wdtifg <=  ifg1_nxt[0];

assign  ifg1 = {3'b000, nmiifg, 3'b000, wdtifg};


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] ie1_rd   = (ie1  & {8{reg_rd[IE1/2]}})  << (8 & {4{IE1[0]}});
wire [15:0] ifg1_rd  = (ifg1 & {8{reg_rd[IFG1/2]}}) << (8 & {4{IFG1[0]}});

wire [15:0] per_dout =  ie1_rd   |
                        ifg1_rd;


//=============================================================================
// 5)  WATCHDOG INTERRUPT & RESET
//=============================================================================

// Watchdog interrupt generation
//---------------------------------
wire    wdt_irq      = wdttmsel & wdtifg & wdtie;

   
// Watchdog reset generation
//-----------------------------
reg     wdt_reset;

always @ (posedge mclk or posedge por)
  if (por) wdt_reset <= 1'b0;
  else     wdt_reset <= wdtpw_error | (wdtifg_set & ~wdttmsel);


endmodule // omsp_sfr

`include "openMSP430_undefines.v"
