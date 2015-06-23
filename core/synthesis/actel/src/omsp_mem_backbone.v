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
// *File Name: omsp_mem_backbone.v
// 
// *Module Description:
//                       Memory interface backbone (decoder + arbiter)
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

module  omsp_mem_backbone (

// OUTPUTs
    dbg_mem_din,                    // Debug unit Memory data input
    dmem_addr,                      // Data Memory address
    dmem_cen,                       // Data Memory chip enable (low active)
    dmem_din,                       // Data Memory data input
    dmem_wen,                       // Data Memory write enable (low active)
    eu_mdb_in,                      // Execution Unit Memory data bus input
    fe_mdb_in,                      // Frontend Memory data bus input
    fe_pmem_wait,                   // Frontend wait for Instruction fetch
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_wen,                        // Peripheral write enable (high active)
    per_en,                         // Peripheral enable (high active)
    pmem_addr,                      // Program Memory address
    pmem_cen,                       // Program Memory chip enable (low active)
    pmem_din,                       // Program Memory data input (optional)
    pmem_wen,                       // Program Memory write enable (low active) (optional)

// INPUTs
    dbg_halt_st,                    // Halt/Run status from CPU
    dbg_mem_addr,                   // Debug address for rd/wr access
    dbg_mem_dout,                   // Debug unit data output
    dbg_mem_en,                     // Debug unit memory enable
    dbg_mem_wr,                     // Debug unit memory write
    dmem_dout,                      // Data Memory data output
    eu_mab,                         // Execution Unit Memory address bus
    eu_mb_en,                       // Execution Unit Memory bus enable
    eu_mb_wr,                       // Execution Unit Memory bus write transfer
    eu_mdb_out,                     // Execution Unit Memory data bus output
    fe_mab,                         // Frontend Memory address bus
    fe_mb_en,                       // Frontend Memory bus enable
    mclk,                           // Main system clock
    per_dout,                       // Peripheral data output
    pmem_dout,                      // Program Memory data output
    puc                             // Main system reset
);

// OUTPUTs
//=========
output        [15:0] dbg_mem_din;   // Debug unit Memory data input
output [`DMEM_MSB:0] dmem_addr;     // Data Memory address
output               dmem_cen;      // Data Memory chip enable (low active)
output        [15:0] dmem_din;      // Data Memory data input
output         [1:0] dmem_wen;      // Data Memory write enable (low active)
output        [15:0] eu_mdb_in;     // Execution Unit Memory data bus input
output        [15:0] fe_mdb_in;     // Frontend Memory data bus input
output               fe_pmem_wait;  // Frontend wait for Instruction fetch
output         [7:0] per_addr;      // Peripheral address
output        [15:0] per_din;       // Peripheral data input
output         [1:0] per_wen;       // Peripheral write enable (high active)
output               per_en;        // Peripheral enable (high active)
output [`PMEM_MSB:0] pmem_addr;     // Program Memory address
output               pmem_cen;      // Program Memory chip enable (low active)
output        [15:0] pmem_din;      // Program Memory data input (optional)
output         [1:0] pmem_wen;      // Program Memory write enable (low active) (optional)

// INPUTs
//=========
input                dbg_halt_st;   // Halt/Run status from CPU
input         [15:0] dbg_mem_addr;  // Debug address for rd/wr access
input         [15:0] dbg_mem_dout;  // Debug unit data output
input                dbg_mem_en;    // Debug unit memory enable
input          [1:0] dbg_mem_wr;    // Debug unit memory write
input         [15:0] dmem_dout;     // Data Memory data output
input         [14:0] eu_mab;        // Execution Unit Memory address bus
input                eu_mb_en;      // Execution Unit Memory bus enable
input          [1:0] eu_mb_wr;      // Execution Unit Memory bus write transfer
input         [15:0] eu_mdb_out;    // Execution Unit Memory data bus output
input         [14:0] fe_mab;        // Frontend Memory address bus
input                fe_mb_en;      // Frontend Memory bus enable
input                mclk;          // Main system clock
input         [15:0] per_dout;      // Peripheral data output
input         [15:0] pmem_dout;     // Program Memory data output
input                puc;           // Main system reset


//=============================================================================
// 1)  DECODER
//=============================================================================

// RAM Interface
//------------------

// Execution unit access
wire               eu_dmem_cen   = ~(eu_mb_en & (eu_mab>=(`DMEM_BASE>>1)) &
                                                (eu_mab<((`DMEM_BASE+`DMEM_SIZE)>>1)));
wire        [15:0] eu_dmem_addr  = eu_mab-(`DMEM_BASE>>1);

// Debug interface access
wire               dbg_dmem_cen  = ~(dbg_mem_en & (dbg_mem_addr[15:1]>=(`DMEM_BASE>>1)) &
                                                  (dbg_mem_addr[15:1]<((`DMEM_BASE+`DMEM_SIZE)>>1)));
wire        [15:0] dbg_dmem_addr = dbg_mem_addr[15:1]-(`DMEM_BASE>>1);

   
// RAM Interface
wire [`DMEM_MSB:0] dmem_addr     = ~dbg_dmem_cen ? dbg_dmem_addr[`DMEM_MSB:0] : eu_dmem_addr[`DMEM_MSB:0];
wire               dmem_cen      =  dbg_dmem_cen & eu_dmem_cen;
wire         [1:0] dmem_wen      = ~(dbg_mem_wr | eu_mb_wr);
wire        [15:0] dmem_din      = ~dbg_dmem_cen ? dbg_mem_dout : eu_mdb_out;


// ROM Interface
//------------------
parameter          PMEM_OFFSET   = (16'hFFFF-`PMEM_SIZE+1);

// Execution unit access (only read access are accepted)
wire               eu_pmem_cen   = ~(eu_mb_en & ~|eu_mb_wr & (eu_mab>=(PMEM_OFFSET>>1)));
wire        [15:0] eu_pmem_addr  = eu_mab-(PMEM_OFFSET>>1);

// Front-end access
wire               fe_pmem_cen   = ~(fe_mb_en & (fe_mab>=(PMEM_OFFSET>>1)));
wire        [15:0] fe_pmem_addr  = fe_mab-(PMEM_OFFSET>>1);

// Debug interface access
wire               dbg_pmem_cen  = ~(dbg_mem_en & (dbg_mem_addr[15:1]>=(PMEM_OFFSET>>1)));
wire        [15:0] dbg_pmem_addr = dbg_mem_addr[15:1]-(PMEM_OFFSET>>1);

   
// ROM Interface (Execution unit has priority)
wire [`PMEM_MSB:0] pmem_addr     = ~dbg_pmem_cen ? dbg_pmem_addr[`PMEM_MSB:0] :
                                   ~eu_pmem_cen  ? eu_pmem_addr[`PMEM_MSB:0]  : fe_pmem_addr[`PMEM_MSB:0];
wire               pmem_cen      =  fe_pmem_cen & eu_pmem_cen & dbg_pmem_cen;
wire         [1:0] pmem_wen      = ~dbg_mem_wr;
wire        [15:0] pmem_din      =  dbg_mem_dout;

wire               fe_pmem_wait  = (~fe_pmem_cen & ~eu_pmem_cen);


// Peripherals
//--------------------
wire         dbg_per_en    =  dbg_mem_en & (dbg_mem_addr[15:9]==7'h00);
wire         eu_per_en     =  eu_mb_en   & (eu_mab[14:8]==7'h00);

wire   [7:0] per_addr      =  dbg_mem_en ? dbg_mem_addr[8:1] : eu_mab[7:0];
wire  [15:0] per_din       =  dbg_mem_en ? dbg_mem_dout      : eu_mdb_out;
wire   [1:0] per_wen       =  dbg_mem_en ? dbg_mem_wr        : eu_mb_wr;
wire         per_en        =  dbg_mem_en ? dbg_per_en        : eu_per_en;

reg   [15:0] per_dout_val;
always @ (posedge mclk or posedge puc)
  if (puc)      per_dout_val <= 16'h0000;
  else          per_dout_val <= per_dout;


// Frontend data Mux
//---------------------------------
// Whenever the frontend doesn't access the ROM,  backup the data

// Detect whenever the data should be backuped and restored
reg 	    fe_pmem_cen_dly;
always @(posedge mclk or posedge puc)
  if (puc)     fe_pmem_cen_dly <=  1'b0;
  else         fe_pmem_cen_dly <=  fe_pmem_cen;

wire fe_pmem_save    = ( fe_pmem_cen & ~fe_pmem_cen_dly) & ~dbg_halt_st;
wire fe_pmem_restore = (~fe_pmem_cen &  fe_pmem_cen_dly) |  dbg_halt_st;
   
reg  [15:0] pmem_dout_bckup;
always @(posedge mclk or posedge puc)
  if (puc)               pmem_dout_bckup     <=  16'h0000;
  else if (fe_pmem_save) pmem_dout_bckup     <=  pmem_dout;

// Mux between the ROM data and the backup
reg         pmem_dout_bckup_sel;
always @(posedge mclk or posedge puc)
  if (puc)                  pmem_dout_bckup_sel <=  1'b0;
  else if (fe_pmem_save)    pmem_dout_bckup_sel <=  1'b1;
  else if (fe_pmem_restore) pmem_dout_bckup_sel <=  1'b0;
    
assign fe_mdb_in = pmem_dout_bckup_sel ? pmem_dout_bckup : pmem_dout;


// Execution-Unit data Mux
//---------------------------------

// Select between peripherals, RAM and ROM
reg [1:0] eu_mdb_in_sel;
always @(posedge mclk or posedge puc)
  if (puc)  eu_mdb_in_sel <= 2'b00;
  else      eu_mdb_in_sel <= {~eu_pmem_cen, per_en};

// Mux
assign      eu_mdb_in      = eu_mdb_in_sel[1] ? pmem_dout    :
                             eu_mdb_in_sel[0] ? per_dout_val : dmem_dout;

// Debug interface  data Mux
//---------------------------------

// Select between peripherals, RAM and ROM
reg [1:0] dbg_mem_din_sel;
always @(posedge mclk or posedge puc)
  if (puc)  dbg_mem_din_sel <= 2'b00;
  else      dbg_mem_din_sel <= {~dbg_pmem_cen, dbg_per_en};

// Mux
assign      dbg_mem_din  = dbg_mem_din_sel[1] ? pmem_dout    :
                           dbg_mem_din_sel[0] ? per_dout_val : dmem_dout;

   
endmodule // omsp_mem_backbone

`include "openMSP430_undefines.v"
