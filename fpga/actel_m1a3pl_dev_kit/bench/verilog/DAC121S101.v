 //----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the authors nor the names of its contributors
//       may be used to endorse or promote products derived from this software
//       without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
// THE POSSIBILITY OF SUCH DAMAGE
//
//----------------------------------------------------------------------------
//
// *File Name: DAC121S101.v
// 
// *Module Description:
//                       Verilog model of National's DAC121S101 12 bit DAC
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 66 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2010-03-07 09:09:38 +0100 (Sun, 07 Mar 2010) $
//----------------------------------------------------------------------------
`timescale 1 ns/100 ps
//`include "timescale.v"
 
module  DAC121S101 (
 
// OUTPUTs
    vout,                           // Peripheral data output
 
// INPUTs
    din,                            // SPI Serial Data
    sclk,                           // SPI Serial Clock
    sync_n                          // SPI Frame synchronization signal (low active)
);

// OUTPUTs
//=========
output       [11:0] vout;           // Peripheral data output
 
// INPUTs
//=========
input               din;            // SPI Serial Data
input               sclk;           // SPI Serial Clock
input               sync_n;         // SPI Frame synchronization signal (low active)
 

//============================================================================
// 1) SPI INTERFACE
//============================================================================

// SPI Transfer Start detection
reg  sync_dly_n;
always @ (negedge sclk)
  sync_dly_n <= sync_n;

wire spi_tfx_start = ~sync_n & sync_dly_n;
   

// Data counter
reg [3:0] spi_cnt;
wire      spi_cnt_done = (spi_cnt==4'hf);
always @ (negedge sclk)
  if (sync_n)              spi_cnt <=  4'hf;
  else if (spi_tfx_start)  spi_cnt <=  4'he;
  else if (~spi_cnt_done)  spi_cnt <=  spi_cnt-1;

wire spi_tfx_done = sync_n & ~sync_dly_n & spi_cnt_done;

   
// Value to be shifted in
reg  [15:0] dac_shifter;
always @ (negedge sclk)
  dac_shifter <=  {dac_shifter[14:0], din};


// DAC Output value
reg  [11:0] vout;
always @ (negedge sclk)
  if (spi_tfx_done)
    vout <=  dac_shifter[11:0];


endmodule // DAC121S101


