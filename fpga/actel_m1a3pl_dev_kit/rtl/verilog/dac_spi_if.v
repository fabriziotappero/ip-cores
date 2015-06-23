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
// *File Name: dac_spi_if.v
// 
// *Module Description:
//                       SPI interface for National's DAC121S101 12 bit DAC
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 66 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2010-03-07 09:09:38 +0100 (Sun, 07 Mar 2010) $
//----------------------------------------------------------------------------
 
module  dac_spi_if (
 
// OUTPUTs
    cntrl1,                         // Control value 1
    cntrl2,                         // Control value 2
    din,                            // SPI Serial Data
    per_dout,                       // Peripheral data output
    sclk,                           // SPI Serial Clock
    sync_n,                         // SPI Frame synchronization signal (low active)
 
// INPUTs
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc_rst                         // Main system reset
);

// PARAMETERs
//============
parameter           SCLK_DIV  = 0;       // Serial clock divider (Tsclk=Tmclk*(SCLK_DIV+1)*2)
parameter           BASE_ADDR = 9'h190;  // Registers base address
 
// OUTPUTs
//=========
output        [3:0] cntrl1;         // Control value 1
output        [3:0] cntrl2;         // Control value 2
output              din;            // SPI Serial Data
output       [15:0] per_dout;       // Peripheral data output
output              sclk;           // SPI Serial Clock
output              sync_n;         // SPI Frame synchronization signal (low active)
 
// INPUTs
//=========
input               mclk;           // Main system clock
input        [13:0] per_addr;       // Peripheral address
input        [15:0] per_din;        // Peripheral data input
input               per_en;         // Peripheral enable (high active)
input         [1:0] per_we;         // Peripheral write enable (high active)
input               puc_rst;        // Main system reset
 
 
//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================
 
// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD      =  3;

// Register addresses offset
parameter [DEC_WD-1:0] DAC_VAL     = 'h0,
                       DAC_STAT    = 'h2,
                       CNTRL1      = 'h4,
                       CNTRL2      = 'h6;

// Register one-hot decoder utilities
parameter              DEC_SZ      =  2**DEC_WD;
parameter [DEC_SZ-1:0] BASE_REG    =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] DAC_VAL_D   = (BASE_REG << DAC_VAL),
                       DAC_STAT_D  = (BASE_REG << DAC_STAT),
                       CNTRL1_D    = (BASE_REG << CNTRL1),
                       CNTRL2_D    = (BASE_REG << CNTRL2);

 
//============================================================================
// 2)  REGISTER DECODER
//============================================================================
 
// Local register selection
wire              reg_sel   =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr  =  {per_addr[DEC_WD-2:0], 1'b0};

// Register address decode
wire [DEC_SZ-1:0] reg_dec   =  (DAC_VAL_D  &  {DEC_SZ{(reg_addr == DAC_VAL )}})  |
                               (DAC_STAT_D &  {DEC_SZ{(reg_addr == DAC_STAT)}})  |
                               (CNTRL1_D   &  {DEC_SZ{(reg_addr == CNTRL1  )}})  |
                               (CNTRL2_D   &  {DEC_SZ{(reg_addr == CNTRL2  )}});

// Read/Write probes
wire              reg_write =  |per_we & reg_sel;
wire              reg_read  = ~|per_we & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {DEC_SZ{reg_write}};
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {DEC_SZ{reg_read}};

 
//============================================================================
// 3) REGISTERS
//============================================================================
 
// DAC_VAL Register
//------------------   
reg  [11:0] dac_val;
reg         dac_pd0;
reg         dac_pd1;
 
wire        dac_val_wr = reg_wr[DAC_VAL];
 
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)
    begin
       dac_val <= 12'h000;
       dac_pd0 <=  1'b0;
       dac_pd1 <=  1'b0;
    end
  else if (dac_val_wr)
    begin
       dac_val <=  per_din[11:0];
       dac_pd0 <=  per_din[12];
       dac_pd1 <=  per_din[13];
    end
 

// CNTRL1 Register
//------------------   
reg   [3:0] cntrl1;
 
wire        cntrl1_wr = reg_wr[CNTRL1];
 
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        cntrl1 <=  4'h0;
  else if (cntrl1_wr) cntrl1 <=  per_din;
 
 
// CNTRL2 Register
//------------------   
reg   [3:0] cntrl2;
 
wire        cntrl2_wr = reg_wr[CNTRL2];
 
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        cntrl2 <=  4'h0;
  else if (cntrl2_wr) cntrl2 <=  per_din;

 
 
//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================
 
// Data output mux
wire [15:0] dac_val_rd  = { 2'b00,   dac_pd1, dac_pd0, dac_val} & {16{reg_rd[DAC_VAL]}};
wire [15:0] dac_stat_rd = {15'h0000, ~sync_n}                   & {16{reg_rd[DAC_STAT]}};
wire [15:0] cntrl1_rd   = {12'h000,  cntrl1}                    & {16{reg_rd[CNTRL1]}};
wire [15:0] cntrl2_rd   = {12'h000,  cntrl2}                    & {16{reg_rd[CNTRL2]}};
 
wire [15:0] per_dout    =  dac_val_rd   |
                           dac_stat_rd  |
                           cntrl1_rd    |
                           cntrl2_rd;
 

//============================================================================
// 5) SPI INTERFACE
//============================================================================
 
// SPI Clock divider
reg [3:0] spi_clk_div;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             spi_clk_div <=  SCLK_DIV;
  else if (spi_clk_div==0) spi_clk_div <=  SCLK_DIV;
  else                     spi_clk_div <=  spi_clk_div-1;

// SPI Clock generation
reg       sclk;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             sclk        <=  1'b0;
  else if (spi_clk_div==0) sclk        <=  ~sclk;

wire      sclk_re = (spi_clk_div==0) & ~sclk;
   
// SPI Transfer trigger
reg       spi_tfx_trig;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               spi_tfx_trig <= 1'b0;
  else if (dac_val_wr)       spi_tfx_trig <= 1'b1;
  else if (sclk_re & sync_n) spi_tfx_trig <= 1'b0;

wire      spi_tfx_init = spi_tfx_trig & sync_n;
   
// Data counter
reg [3:0] spi_cnt;
wire      spi_cnt_done = (spi_cnt==4'hf);
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               spi_cnt <=  4'hf;
  else if (sclk_re)
    if (spi_tfx_init)        spi_cnt <=  4'he;
    else if (~spi_cnt_done)  spi_cnt <=  spi_cnt-1;


// Frame synchronization signal (low active)
reg sync_n;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               sync_n  <=  1'b1;
  else if (sclk_re)
    if (spi_tfx_init)        sync_n  <=  1'b0;
    else if (spi_cnt_done)   sync_n  <=  1'b1;

   
// Value to be shifted_out
reg  [15:0] dac_shifter;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dac_shifter <=  16'h000;
  else if (sclk_re)
    if (spi_tfx_init) dac_shifter <=  {2'b00, dac_pd1, dac_pd0, dac_val[11:0]};
    else              dac_shifter <=  {dac_shifter[14:0], 1'b0};

assign din = dac_shifter[15];


endmodule // dac_spi_if
 
