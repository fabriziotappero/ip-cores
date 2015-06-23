//----------------------------------------------------------------------------
// Copyright (C) 2009 , Olivier Girard
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
// *File Name: omsp_timerA.v
// 
// *Module Description:
//                       Timer A top-level
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 103 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-05 15:44:48 +0100 (Sat, 05 Mar 2011) $
//----------------------------------------------------------------------------
`ifdef OMSP_TA_NO_INCLUDE
`else
`include "omsp_timerA_defines.v"
`endif

module  omsp_timerA (

// OUTPUTs
    irq_ta0,                        // Timer A interrupt: TACCR0
    irq_ta1,                        // Timer A interrupt: TAIV, TACCR1, TACCR2
    per_dout,                       // Peripheral data output
    ta_out0,                        // Timer A output 0
    ta_out0_en,                     // Timer A output 0 enable
    ta_out1,                        // Timer A output 1
    ta_out1_en,                     // Timer A output 1 enable
    ta_out2,                        // Timer A output 2
    ta_out2_en,                     // Timer A output 2 enable

// INPUTs
    aclk_en,                        // ACLK enable (from CPU)
    dbg_freeze,                     // Freeze Timer A counter
    inclk,                          // INCLK external timer clock (SLOW)
    irq_ta0_acc,                    // Interrupt request TACCR0 accepted
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc_rst,                        // Main system reset
    smclk_en,                       // SMCLK enable (from CPU)
    ta_cci0a,                       // Timer A capture 0 input A
    ta_cci0b,                       // Timer A capture 0 input B
    ta_cci1a,                       // Timer A capture 1 input A
    ta_cci1b,                       // Timer A capture 1 input B
    ta_cci2a,                       // Timer A capture 2 input A
    ta_cci2b,                       // Timer A capture 2 input B
    taclk                           // TACLK external timer clock (SLOW)
);

// OUTPUTs
//=========
output              irq_ta0;        // Timer A interrupt: TACCR0
output              irq_ta1;        // Timer A interrupt: TAIV, TACCR1, TACCR2
output       [15:0] per_dout;       // Peripheral data output
output              ta_out0;        // Timer A output 0
output              ta_out0_en;     // Timer A output 0 enable
output              ta_out1;        // Timer A output 1
output              ta_out1_en;     // Timer A output 1 enable
output              ta_out2;        // Timer A output 2
output              ta_out2_en;     // Timer A output 2 enable

// INPUTs
//=========
input               aclk_en;        // ACLK enable (from CPU)
input               dbg_freeze;     // Freeze Timer A counter
input               inclk;          // INCLK external timer clock (SLOW)
input               irq_ta0_acc;    // Interrupt request TACCR0 accepted
input               mclk;           // Main system clock
input        [13:0] per_addr;       // Peripheral address
input        [15:0] per_din;        // Peripheral data input
input               per_en;         // Peripheral enable (high active)
input         [1:0] per_we;         // Peripheral write enable (high active)
input               puc_rst;        // Main system reset
input               smclk_en;       // SMCLK enable (from CPU)
input               ta_cci0a;       // Timer A capture 0 input A
input               ta_cci0b;       // Timer A capture 0 input B
input               ta_cci1a;       // Timer A capture 1 input A
input               ta_cci1b;       // Timer A capture 1 input B
input               ta_cci2a;       // Timer A capture 2 input A
input               ta_cci2b;       // Timer A capture 2 input B
input               taclk;          // TACLK external timer clock (SLOW)


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR  = 15'h0100;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD     =  7;

// Register addresses offset
parameter [DEC_WD-1:0] TACTL      = 'h60,
                       TAR        = 'h70,
                       TACCTL0    = 'h62,
                       TACCR0     = 'h72,
                       TACCTL1    = 'h64,
                       TACCR1     = 'h74,
                       TACCTL2    = 'h66,
                       TACCR2     = 'h76,
                       TAIV       = 'h2E;

// Register one-hot decoder utilities
parameter              DEC_SZ     =  (1 << DEC_WD);
parameter [DEC_SZ-1:0] BASE_REG   =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] TACTL_D    = (BASE_REG << TACTL),
                       TAR_D      = (BASE_REG << TAR),
                       TACCTL0_D  = (BASE_REG << TACCTL0),
                       TACCR0_D   = (BASE_REG << TACCR0),
                       TACCTL1_D  = (BASE_REG << TACCTL1),
                       TACCR1_D   = (BASE_REG << TACCR1),
                       TACCTL2_D  = (BASE_REG << TACCTL2),
                       TACCR2_D   = (BASE_REG << TACCR2),
                       TAIV_D     = (BASE_REG << TAIV);


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel   =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr  =  {per_addr[DEC_WD-2:0], 1'b0};

// Register address decode
wire [DEC_SZ-1:0] reg_dec   =  (TACTL_D    &  {DEC_SZ{(reg_addr == TACTL   )}})  |
                               (TAR_D      &  {DEC_SZ{(reg_addr == TAR     )}})  |
                               (TACCTL0_D  &  {DEC_SZ{(reg_addr == TACCTL0 )}})  |
                               (TACCR0_D   &  {DEC_SZ{(reg_addr == TACCR0  )}})  |
                               (TACCTL1_D  &  {DEC_SZ{(reg_addr == TACCTL1 )}})  |
                               (TACCR1_D   &  {DEC_SZ{(reg_addr == TACCR1  )}})  |
                               (TACCTL2_D  &  {DEC_SZ{(reg_addr == TACCTL2 )}})  |
                               (TACCR2_D   &  {DEC_SZ{(reg_addr == TACCR2  )}})  |
                               (TAIV_D     &  {DEC_SZ{(reg_addr == TAIV    )}});

// Read/Write probes
wire              reg_write =  |per_we & reg_sel;
wire              reg_read  = ~|per_we & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {512{reg_write}};
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {512{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// TACTL Register
//-----------------   
reg   [9:0] tactl;

wire        tactl_wr = reg_wr[TACTL];
wire        taclr    = tactl_wr & per_din[`TACLR];
wire        taifg_set;
wire        taifg_clr;
   
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)       tactl <=  10'h000;
  else if (tactl_wr) tactl <=  ((per_din[9:0] & 10'h3f3) | {9'h000, taifg_set}) & {9'h1ff, ~taifg_clr};
  else               tactl <=  (tactl                    | {9'h000, taifg_set}) & {9'h1ff, ~taifg_clr};


// TAR Register
//-----------------   
reg  [15:0] tar;

wire        tar_wr = reg_wr[TAR];

wire        tar_clk;
wire        tar_clr;
wire        tar_inc;
wire        tar_dec;
wire [15:0] tar_add  = tar_inc ? 16'h0001 :
                       tar_dec ? 16'hffff : 16'h0000;
wire [15:0] tar_nxt  = tar_clr ? 16'h0000 : (tar+tar_add);
  
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                     tar <=  16'h0000;
  else if  (tar_wr)                tar <=  per_din;
  else if  (taclr)                 tar <=  16'h0000;
  else if  (tar_clk & ~dbg_freeze) tar <=  tar_nxt;


// TACCTL0 Register
//------------------   
reg  [15:0] tacctl0;

wire        tacctl0_wr = reg_wr[TACCTL0];
wire        ccifg0_set;
wire        cov0_set;   

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)         tacctl0  <=  16'h0000;
  else if (tacctl0_wr) tacctl0  <=  ((per_din & 16'hf9f7) | {14'h0000, cov0_set, ccifg0_set}) & {15'h7fff, ~irq_ta0_acc};
  else                 tacctl0  <=  (tacctl0              | {14'h0000, cov0_set, ccifg0_set}) & {15'h7fff, ~irq_ta0_acc};

wire        cci0;
reg         scci0;
wire [15:0] tacctl0_full = tacctl0 | {5'h00, scci0, 6'h00, cci0, 3'h0};

   
// TACCR0 Register
//------------------   
reg  [15:0] taccr0;

wire        taccr0_wr = reg_wr[TACCR0];
wire        cci0_cap;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        taccr0 <=  16'h0000;
  else if (taccr0_wr) taccr0 <=  per_din;
  else if (cci0_cap)  taccr0 <=  tar;

   
// TACCTL1 Register
//------------------   
reg  [15:0] tacctl1;

wire        tacctl1_wr = reg_wr[TACCTL1];
wire        ccifg1_set;
wire        ccifg1_clr;
wire        cov1_set;   
   
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)         tacctl1 <=  16'h0000;
  else if (tacctl1_wr) tacctl1 <=  ((per_din & 16'hf9f7) | {14'h0000, cov1_set, ccifg1_set}) & {15'h7fff, ~ccifg1_clr};
  else                 tacctl1 <=  (tacctl1              | {14'h0000, cov1_set, ccifg1_set}) & {15'h7fff, ~ccifg1_clr};

wire        cci1;
reg         scci1;
wire [15:0] tacctl1_full = tacctl1 | {5'h00, scci1, 6'h00, cci1, 3'h0};

   
// TACCR1 Register
//------------------   
reg  [15:0] taccr1;

wire        taccr1_wr = reg_wr[TACCR1];
wire        cci1_cap;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        taccr1 <=  16'h0000;
  else if (taccr1_wr) taccr1 <=  per_din;
  else if (cci1_cap)  taccr1 <=  tar;


// TACCTL2 Register
//------------------   
reg  [15:0] tacctl2;

wire        tacctl2_wr = reg_wr[TACCTL2];
wire        ccifg2_set;
wire        ccifg2_clr;
wire        cov2_set;   
   
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)         tacctl2 <=  16'h0000;
  else if (tacctl2_wr) tacctl2 <=  ((per_din & 16'hf9f7) | {14'h0000, cov2_set, ccifg2_set}) & {15'h7fff, ~ccifg2_clr};
  else                 tacctl2 <=  (tacctl2              | {14'h0000, cov2_set, ccifg2_set}) & {15'h7fff, ~ccifg2_clr};

wire        cci2;
reg         scci2;
wire [15:0] tacctl2_full = tacctl2 | {5'h00, scci2, 6'h00, cci2, 3'h0};

   
// TACCR2 Register
//------------------   
reg  [15:0] taccr2;

wire        taccr2_wr = reg_wr[TACCR2];
wire        cci2_cap;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        taccr2 <=  16'h0000;
  else if (taccr2_wr) taccr2 <=  per_din;
  else if (cci2_cap)  taccr2 <=  tar;

   
// TAIV Register
//------------------   

wire [3:0] taiv = (tacctl1[`TACCIFG] & tacctl1[`TACCIE]) ? 4'h2 : 
                  (tacctl2[`TACCIFG] & tacctl2[`TACCIE]) ? 4'h4 : 
                  (tactl[`TAIFG]     & tactl[`TAIE])     ? 4'hA : 
                                                           4'h0;

assign     ccifg1_clr = (reg_rd[TAIV] | reg_wr[TAIV]) & (taiv==4'h2);
assign     ccifg2_clr = (reg_rd[TAIV] | reg_wr[TAIV]) & (taiv==4'h4);
assign     taifg_clr  = (reg_rd[TAIV] | reg_wr[TAIV]) & (taiv==4'hA);


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] tactl_rd   = {6'h00, tactl}  & {16{reg_rd[TACTL]}};
wire [15:0] tar_rd     = tar             & {16{reg_rd[TAR]}};
wire [15:0] tacctl0_rd = tacctl0_full    & {16{reg_rd[TACCTL0]}};
wire [15:0] taccr0_rd  = taccr0          & {16{reg_rd[TACCR0]}};
wire [15:0] tacctl1_rd = tacctl1_full    & {16{reg_rd[TACCTL1]}};
wire [15:0] taccr1_rd  = taccr1          & {16{reg_rd[TACCR1]}};
wire [15:0] tacctl2_rd = tacctl2_full    & {16{reg_rd[TACCTL2]}};
wire [15:0] taccr2_rd  = taccr2          & {16{reg_rd[TACCR2]}};
wire [15:0] taiv_rd    = {12'h000, taiv} & {16{reg_rd[TAIV]}};

wire [15:0] per_dout   =  tactl_rd   |
                          tar_rd     |
                          tacctl0_rd |
                          taccr0_rd  |
                          tacctl1_rd |
                          taccr1_rd  |
                          tacctl2_rd |
                          taccr2_rd  |
                          taiv_rd;

   
//============================================================================
// 5) Timer A counter control
//============================================================================

// Clock input synchronization (TACLK & INCLK)
//-----------------------------------------------------------
wire taclk_s;
wire inclk_s;

omsp_sync_cell sync_cell_taclk (
    .data_out  (taclk_s),
    .data_in   (taclk),
    .clk       (mclk),
    .rst       (puc_rst)
);

omsp_sync_cell sync_cell_inclk (
    .data_out  (inclk_s),
    .data_in   (inclk),
    .clk       (mclk),
    .rst       (puc_rst)
);


// Clock edge detection (TACLK & INCLK)
//-----------------------------------------------------------

reg  taclk_dly;
   
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) taclk_dly <=  1'b0;
  else         taclk_dly <=  taclk_s;    

wire taclk_en = taclk_s & ~taclk_dly;

   
reg  inclk_dly;
   
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) inclk_dly <=  1'b0;
  else         inclk_dly <=  inclk_s;    

wire inclk_en = inclk_s & ~inclk_dly;

   
// Timer clock input mux
//-----------------------------------------------------------

wire sel_clk = (tactl[`TASSELx]==2'b00) ? taclk_en :
               (tactl[`TASSELx]==2'b01) ?  aclk_en :
               (tactl[`TASSELx]==2'b10) ? smclk_en : inclk_en;

     
// Generate update pluse for the counter (<=> divided clock)
//-----------------------------------------------------------
reg [2:0] clk_div;

assign    tar_clk = sel_clk & ((tactl[`TAIDx]==2'b00) ?  1'b1         :
                               (tactl[`TAIDx]==2'b01) ?  clk_div[0]   :
                               (tactl[`TAIDx]==2'b10) ? &clk_div[1:0] :
                                                        &clk_div[2:0]);
	  
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                               clk_div <=  3'h0;
  else if  (tar_clk | taclr)                 clk_div <=  3'h0;
  else if ((tactl[`TAMCx]!=2'b00) & sel_clk) clk_div <=  clk_div+3'h1;

  
// Time counter control signals
//-----------------------------------------------------------

assign  tar_clr   = ((tactl[`TAMCx]==2'b01) & (tar>=taccr0))         |
                    ((tactl[`TAMCx]==2'b11) & (taccr0==16'h0000));

assign  tar_inc   =  (tactl[`TAMCx]==2'b01) | (tactl[`TAMCx]==2'b10) | 
                    ((tactl[`TAMCx]==2'b11) & ~tar_dec);

reg tar_dir;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                        tar_dir <=  1'b0;
  else if (taclr)                     tar_dir <=  1'b0;
  else if (tactl[`TAMCx]==2'b11)
    begin
       if (tar_clk & (tar==16'h0001)) tar_dir <=  1'b0;
       else if       (tar>=taccr0)    tar_dir <=  1'b1;
    end
  else                                tar_dir <=  1'b0;
   
assign tar_dec = tar_dir | ((tactl[`TAMCx]==2'b11) & (tar>=taccr0));

   
//============================================================================
// 6) Timer A comparator
//============================================================================

wire equ0 = (tar_nxt==taccr0) & (tar!=taccr0);
wire equ1 = (tar_nxt==taccr1) & (tar!=taccr1);
wire equ2 = (tar_nxt==taccr2) & (tar!=taccr2);


//============================================================================
// 7) Timer A capture logic
//============================================================================

// Input selection
//------------------
assign cci0 = (tacctl0[`TACCISx]==2'b00) ? ta_cci0a :
              (tacctl0[`TACCISx]==2'b01) ? ta_cci0b :
              (tacctl0[`TACCISx]==2'b10) ?     1'b0 : 1'b1;

assign cci1 = (tacctl1[`TACCISx]==2'b00) ? ta_cci1a :
              (tacctl1[`TACCISx]==2'b01) ? ta_cci1b :
              (tacctl1[`TACCISx]==2'b10) ?     1'b0 : 1'b1;

assign cci2 = (tacctl2[`TACCISx]==2'b00) ? ta_cci2a :
              (tacctl2[`TACCISx]==2'b01) ? ta_cci2b :
              (tacctl2[`TACCISx]==2'b10) ?     1'b0 : 1'b1;

// CCIx synchronization
wire cci0_s;
wire cci1_s;
wire cci2_s;

omsp_sync_cell sync_cell_cci0 (
    .data_out (cci0_s),
    .data_in  (cci0),
    .clk      (mclk),
    .rst      (puc_rst)
);
omsp_sync_cell sync_cell_cci1 (
    .data_out (cci1_s),
    .data_in  (cci1),
    .clk      (mclk),
    .rst      (puc_rst)
);
omsp_sync_cell sync_cell_cci2 (
    .data_out (cci2_s),
    .data_in  (cci2),
    .clk      (mclk),
    .rst      (puc_rst)
);

// Register CCIx for edge detection
reg cci0_dly;
reg cci1_dly;
reg cci2_dly;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)
    begin
       cci0_dly <=  1'b0;
       cci1_dly <=  1'b0;
       cci2_dly <=  1'b0;
    end
  else
    begin
       cci0_dly <=  cci0_s;
       cci1_dly <=  cci1_s;
       cci2_dly <=  cci2_s;
    end

   
// Generate SCCIx
//------------------

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             scci0 <=  1'b0;
  else if (tar_clk & equ0) scci0 <=  cci0_s;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             scci1 <=  1'b0;
  else if (tar_clk & equ1) scci1 <=  cci1_s;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             scci2 <=  1'b0;
  else if (tar_clk & equ2) scci2 <=  cci2_s;


// Capture mode
//------------------
wire cci0_evt = (tacctl0[`TACMx]==2'b00) ? 1'b0                  :
                (tacctl0[`TACMx]==2'b01) ? ( cci0_s & ~cci0_dly) :   // Rising edge
                (tacctl0[`TACMx]==2'b10) ? (~cci0_s &  cci0_dly) :   // Falling edge
                                           ( cci0_s ^  cci0_dly);    // Both edges

wire cci1_evt = (tacctl1[`TACMx]==2'b00) ? 1'b0                  :
                (tacctl1[`TACMx]==2'b01) ? ( cci1_s & ~cci1_dly) :   // Rising edge
                (tacctl1[`TACMx]==2'b10) ? (~cci1_s &  cci1_dly) :   // Falling edge
                                           ( cci1_s ^  cci1_dly);    // Both edges

wire cci2_evt = (tacctl2[`TACMx]==2'b00) ? 1'b0                  :
                (tacctl2[`TACMx]==2'b01) ? ( cci2_s & ~cci2_dly) :   // Rising edge
                (tacctl2[`TACMx]==2'b10) ? (~cci2_s &  cci2_dly) :   // Falling edge
                                           ( cci2_s ^  cci2_dly);    // Both edges

// Event Synchronization
//-----------------------

reg cci0_evt_s;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)       cci0_evt_s <=  1'b0;
  else if (tar_clk)  cci0_evt_s <=  1'b0;
  else if (cci0_evt) cci0_evt_s <=  1'b1;

reg cci1_evt_s;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)       cci1_evt_s <=  1'b0;
  else if (tar_clk)  cci1_evt_s <=  1'b0;
  else if (cci1_evt) cci1_evt_s <=  1'b1;

reg cci2_evt_s;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)       cci2_evt_s <=  1'b0;
  else if (tar_clk)  cci2_evt_s <=  1'b0;
  else if (cci2_evt) cci2_evt_s <=  1'b1;

reg cci0_sync;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) cci0_sync <=  1'b0;
  else         cci0_sync <=  (tar_clk & cci0_evt_s) | (tar_clk & cci0_evt & ~cci0_evt_s);

reg cci1_sync;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) cci1_sync <=  1'b0;
  else         cci1_sync <=  (tar_clk & cci1_evt_s) | (tar_clk & cci1_evt & ~cci1_evt_s);

reg cci2_sync;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) cci2_sync <=  1'b0;
  else         cci2_sync <=  (tar_clk & cci2_evt_s) | (tar_clk & cci2_evt & ~cci2_evt_s);

   
// Generate final capture command
//-----------------------------------

assign cci0_cap  = tacctl0[`TASCS] ? cci0_sync : cci0_evt;
assign cci1_cap  = tacctl1[`TASCS] ? cci1_sync : cci1_evt;
assign cci2_cap  = tacctl2[`TASCS] ? cci2_sync : cci2_evt;

   
// Generate capture overflow flag
//-----------------------------------

reg  cap0_taken;
wire cap0_taken_clr = reg_rd[TACCR0] | (tacctl0_wr & tacctl0[`TACOV] & ~per_din[`TACOV]);
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             cap0_taken <=  1'b0;
  else if (cci0_cap)       cap0_taken <=  1'b1;
  else if (cap0_taken_clr) cap0_taken <=  1'b0;
   
reg  cap1_taken;
wire cap1_taken_clr = reg_rd[TACCR1] | (tacctl1_wr & tacctl1[`TACOV] & ~per_din[`TACOV]);
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             cap1_taken <=  1'b0;
  else if (cci1_cap)       cap1_taken <=  1'b1;
  else if (cap1_taken_clr) cap1_taken <=  1'b0;
      
reg  cap2_taken;
wire cap2_taken_clr = reg_rd[TACCR2] | (tacctl2_wr & tacctl2[`TACOV] & ~per_din[`TACOV]);
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)             cap2_taken <=  1'b0;
  else if (cci2_cap)       cap2_taken <=  1'b1;
  else if (cap2_taken_clr) cap2_taken <=  1'b0;

   
assign cov0_set = cap0_taken & cci0_cap & ~reg_rd[TACCR0];
assign cov1_set = cap1_taken & cci1_cap & ~reg_rd[TACCR1];   
assign cov2_set = cap2_taken & cci2_cap & ~reg_rd[TACCR2];
  
      
//============================================================================
// 8) Timer A output unit
//============================================================================

// Output unit 0
//-------------------
reg  ta_out0;

wire ta_out0_mode0 = tacctl0[`TAOUT];                // Output
wire ta_out0_mode1 = equ0 ?  1'b1    : ta_out0;      // Set
wire ta_out0_mode2 = equ0 ? ~ta_out0 :               // Toggle/Reset
                     equ0 ?  1'b0    : ta_out0;
wire ta_out0_mode3 = equ0 ?  1'b1    :               // Set/Reset
                     equ0 ?  1'b0    : ta_out0;
wire ta_out0_mode4 = equ0 ? ~ta_out0 : ta_out0;      // Toggle
wire ta_out0_mode5 = equ0 ?  1'b0    : ta_out0;      // Reset
wire ta_out0_mode6 = equ0 ? ~ta_out0 :               // Toggle/Set
                     equ0 ?  1'b1    : ta_out0;
wire ta_out0_mode7 = equ0 ?  1'b0    :               // Reset/Set
                     equ0 ?  1'b1    : ta_out0;

wire ta_out0_nxt   = (tacctl0[`TAOUTMODx]==3'b000) ? ta_out0_mode0 :
                     (tacctl0[`TAOUTMODx]==3'b001) ? ta_out0_mode1 :
                     (tacctl0[`TAOUTMODx]==3'b010) ? ta_out0_mode2 :
                     (tacctl0[`TAOUTMODx]==3'b011) ? ta_out0_mode3 :
                     (tacctl0[`TAOUTMODx]==3'b100) ? ta_out0_mode4 :
                     (tacctl0[`TAOUTMODx]==3'b101) ? ta_out0_mode5 :
                     (tacctl0[`TAOUTMODx]==3'b110) ? ta_out0_mode6 :
                                                     ta_out0_mode7;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                                     ta_out0 <=  1'b0;
  else if ((tacctl0[`TAOUTMODx]==3'b001) & taclr)  ta_out0 <=  1'b0;
  else if (tar_clk)                                ta_out0 <=  ta_out0_nxt;

assign  ta_out0_en = ~tacctl0[`TACAP];

   
// Output unit 1
//-------------------
reg  ta_out1;

wire ta_out1_mode0 = tacctl1[`TAOUT];                // Output
wire ta_out1_mode1 = equ1 ?  1'b1    : ta_out1;      // Set
wire ta_out1_mode2 = equ1 ? ~ta_out1 :               // Toggle/Reset
                     equ0 ?  1'b0    : ta_out1;
wire ta_out1_mode3 = equ1 ?  1'b1    :               // Set/Reset
                     equ0 ?  1'b0    : ta_out1;
wire ta_out1_mode4 = equ1 ? ~ta_out1 : ta_out1;      // Toggle
wire ta_out1_mode5 = equ1 ?  1'b0    : ta_out1;      // Reset
wire ta_out1_mode6 = equ1 ? ~ta_out1 :               // Toggle/Set
                     equ0 ?  1'b1    : ta_out1;
wire ta_out1_mode7 = equ1 ?  1'b0    :               // Reset/Set
                     equ0 ?  1'b1    : ta_out1;

wire ta_out1_nxt   = (tacctl1[`TAOUTMODx]==3'b000) ? ta_out1_mode0 :
                     (tacctl1[`TAOUTMODx]==3'b001) ? ta_out1_mode1 :
                     (tacctl1[`TAOUTMODx]==3'b010) ? ta_out1_mode2 :
                     (tacctl1[`TAOUTMODx]==3'b011) ? ta_out1_mode3 :
                     (tacctl1[`TAOUTMODx]==3'b100) ? ta_out1_mode4 :
                     (tacctl1[`TAOUTMODx]==3'b101) ? ta_out1_mode5 :
                     (tacctl1[`TAOUTMODx]==3'b110) ? ta_out1_mode6 :
                                                     ta_out1_mode7;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                                     ta_out1 <=  1'b0;
  else if ((tacctl1[`TAOUTMODx]==3'b001) & taclr)  ta_out1 <=  1'b0;
  else if (tar_clk)                                ta_out1 <=  ta_out1_nxt;

assign  ta_out1_en = ~tacctl1[`TACAP];

   
// Output unit 2
//-------------------
reg  ta_out2;

wire ta_out2_mode0 = tacctl2[`TAOUT];                // Output
wire ta_out2_mode1 = equ2 ?  1'b1    : ta_out2;      // Set
wire ta_out2_mode2 = equ2 ? ~ta_out2 :               // Toggle/Reset
                     equ0 ?  1'b0    : ta_out2;
wire ta_out2_mode3 = equ2 ?  1'b1    :               // Set/Reset
                     equ0 ?  1'b0    : ta_out2;
wire ta_out2_mode4 = equ2 ? ~ta_out2 : ta_out2;      // Toggle
wire ta_out2_mode5 = equ2 ?  1'b0    : ta_out2;      // Reset
wire ta_out2_mode6 = equ2 ? ~ta_out2 :               // Toggle/Set
                     equ0 ?  1'b1    : ta_out2;
wire ta_out2_mode7 = equ2 ?  1'b0    :               // Reset/Set
                     equ0 ?  1'b1    : ta_out2;

wire ta_out2_nxt   = (tacctl2[`TAOUTMODx]==3'b000) ? ta_out2_mode0 :
                     (tacctl2[`TAOUTMODx]==3'b001) ? ta_out2_mode1 :
                     (tacctl2[`TAOUTMODx]==3'b010) ? ta_out2_mode2 :
                     (tacctl2[`TAOUTMODx]==3'b011) ? ta_out2_mode3 :
                     (tacctl2[`TAOUTMODx]==3'b100) ? ta_out2_mode4 :
                     (tacctl2[`TAOUTMODx]==3'b101) ? ta_out2_mode5 :
                     (tacctl2[`TAOUTMODx]==3'b110) ? ta_out2_mode6 :
                                                     ta_out2_mode7;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                                     ta_out2 <=  1'b0;
  else if ((tacctl2[`TAOUTMODx]==3'b001) & taclr)  ta_out2 <=  1'b0;
  else if (tar_clk)                                ta_out2 <=  ta_out2_nxt;

assign  ta_out2_en = ~tacctl2[`TACAP];

   
//============================================================================
// 9) Timer A interrupt generation
//============================================================================


assign   taifg_set   = tar_clk & (((tactl[`TAMCx]==2'b01) & (tar==taccr0))                  |
                                  ((tactl[`TAMCx]==2'b10) & (tar==16'hffff))                |
                                  ((tactl[`TAMCx]==2'b11) & (tar_nxt==16'h0000) & tar_dec));

assign   ccifg0_set  = tacctl0[`TACAP] ? cci0_cap : (tar_clk &  ((tactl[`TAMCx]!=2'b00) & equ0));
assign   ccifg1_set  = tacctl1[`TACAP] ? cci1_cap : (tar_clk &  ((tactl[`TAMCx]!=2'b00) & equ1));
assign   ccifg2_set  = tacctl2[`TACAP] ? cci2_cap : (tar_clk &  ((tactl[`TAMCx]!=2'b00) & equ2));

  
wire     irq_ta0    = (tacctl0[`TACCIFG] & tacctl0[`TACCIE]);

wire     irq_ta1    = (tactl[`TAIFG]     & tactl[`TAIE])     |
                      (tacctl1[`TACCIFG] & tacctl1[`TACCIE]) |
                      (tacctl2[`TACCIFG] & tacctl2[`TACCIE]);
   

endmodule // omsp_timerA

`ifdef OMSP_TA_NO_INCLUDE
`else
`include "omsp_timerA_undefines.v"
`endif
