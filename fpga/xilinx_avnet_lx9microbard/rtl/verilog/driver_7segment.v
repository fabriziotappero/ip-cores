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
// *File Name: driver_7segment.v
// 
// *Module Description:
//                      Driver for the four-digit, seven-segment LED display.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 111 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-05-20 22:39:02 +0200 (Fri, 20 May 2011) $
//----------------------------------------------------------------------------

module  driver_7segment (

// OUTPUTs
    per_dout,                       // Peripheral data output
    seg_a,                          // Segment A control
    seg_b,                          // Segment B control
    seg_c,                          // Segment C control
    seg_d,                          // Segment D control
    seg_e,                          // Segment E control
    seg_f,                          // Segment F control
    seg_g,                          // Segment G control
    seg_dp,                         // Segment DP control
    seg_an0,                        // Anode 0 control
    seg_an1,                        // Anode 1 control
    seg_an2,                        // Anode 2 control
    seg_an3,                        // Anode 3 control

// INPUTs
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc_rst                         // Main system reset
);

// OUTPUTs
//=========
output      [15:0] per_dout;        // Peripheral data output
output             seg_a;           // Segment A control
output             seg_b;           // Segment B control
output             seg_c;           // Segment C control
output             seg_d;           // Segment D control
output             seg_e;           // Segment E control
output             seg_f;           // Segment F control
output             seg_g;           // Segment G control
output             seg_dp;          // Segment DP control
output             seg_an0;         // Anode 0 control
output             seg_an1;         // Anode 1 control
output             seg_an2;         // Anode 2 control
output             seg_an3;         // Anode 3 control

// INPUTs
//=========
input              mclk;            // Main system clock
input       [13:0] per_addr;        // Peripheral address
input       [15:0] per_din;         // Peripheral data input
input              per_en;          // Peripheral enable (high active)
input        [1:0] per_we;          // Peripheral write enable (high active)
input              puc_rst;         // Main system reset


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR   = 15'h0090;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD      =  2;

// Register addresses offset
parameter [DEC_WD-1:0] DIGIT0      =  'h0,
                       DIGIT1      =  'h1,
                       DIGIT2      =  'h2,
                       DIGIT3      =  'h3;

   
// Register one-hot decoder utilities
parameter              DEC_SZ      =  2**DEC_WD;
parameter [DEC_SZ-1:0] BASE_REG    =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] DIGIT0_D  = (BASE_REG << DIGIT0),
                       DIGIT1_D  = (BASE_REG << DIGIT1), 
                       DIGIT2_D  = (BASE_REG << DIGIT2), 
                       DIGIT3_D  = (BASE_REG << DIGIT3); 


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel      =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr     =  {1'b0, per_addr[DEC_WD-2:0]};

// Register address decode
wire [DEC_SZ-1:0] reg_dec      = (DIGIT0_D  &  {DEC_SZ{(reg_addr==(DIGIT0 >>1))}}) |
                                 (DIGIT1_D  &  {DEC_SZ{(reg_addr==(DIGIT1 >>1))}}) |
                                 (DIGIT2_D  &  {DEC_SZ{(reg_addr==(DIGIT2 >>1))}}) |
                                 (DIGIT3_D  &  {DEC_SZ{(reg_addr==(DIGIT3 >>1))}});

// Read/Write probes
wire              reg_lo_write =  per_we[0] & reg_sel;
wire              reg_hi_write =  per_we[1] & reg_sel;
wire              reg_read     = ~|per_we   & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_hi_wr    = reg_dec & {DEC_SZ{reg_hi_write}};
wire [DEC_SZ-1:0] reg_lo_wr    = reg_dec & {DEC_SZ{reg_lo_write}};
wire [DEC_SZ-1:0] reg_rd       = reg_dec & {DEC_SZ{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// DIGIT0 Register
//-----------------
reg  [7:0] digit0;

wire       digit0_wr  = DIGIT0[0] ? reg_hi_wr[DIGIT0] : reg_lo_wr[DIGIT0];
wire [7:0] digit0_nxt = DIGIT0[0] ? per_din[15:8]     : per_din[7:0];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        digit0 <=  8'h00;
  else if (digit0_wr) digit0 <=  digit0_nxt;

   
// DIGIT1 Register
//-----------------
reg  [7:0] digit1;

wire       digit1_wr  = DIGIT1[0] ? reg_hi_wr[DIGIT1] : reg_lo_wr[DIGIT1];
wire [7:0] digit1_nxt = DIGIT1[0] ? per_din[15:8]     : per_din[7:0];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        digit1 <=  8'h00;
  else if (digit1_wr) digit1 <=  digit1_nxt;

   
// DIGIT2 Register
//-----------------
reg  [7:0] digit2;

wire       digit2_wr  = DIGIT2[0] ? reg_hi_wr[DIGIT2] : reg_lo_wr[DIGIT2];
wire [7:0] digit2_nxt = DIGIT2[0] ? per_din[15:8]     : per_din[7:0];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        digit2 <=  8'h00;
  else if (digit2_wr) digit2 <=  digit2_nxt;

   
// DIGIT3 Register
//-----------------
reg  [7:0] digit3;

wire       digit3_wr  = DIGIT3[0] ? reg_hi_wr[DIGIT3] : reg_lo_wr[DIGIT3];
wire [7:0] digit3_nxt = DIGIT3[0] ? per_din[15:8]     : per_din[7:0];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        digit3 <=  8'h00;
  else if (digit3_wr) digit3 <=  digit3_nxt;


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] digit0_rd   = (digit0  & {8{reg_rd[DIGIT0]}})  << (8 & {4{DIGIT0[0]}});
wire [15:0] digit1_rd   = (digit1  & {8{reg_rd[DIGIT1]}})  << (8 & {4{DIGIT1[0]}});
wire [15:0] digit2_rd   = (digit2  & {8{reg_rd[DIGIT2]}})  << (8 & {4{DIGIT2[0]}});
wire [15:0] digit3_rd   = (digit3  & {8{reg_rd[DIGIT3]}})  << (8 & {4{DIGIT3[0]}});

wire [15:0] per_dout  =  digit0_rd  |
                         digit1_rd  |
                         digit2_rd  |
                         digit3_rd;

   
//============================================================================
// 5) FOUR-DIGIT, SEVEN-SEGMENT LED DISPLAY DRIVER
//============================================================================

// Anode selection
//------------------

// Free running counter
reg [23:0] anode_cnt;
always @ (posedge mclk or posedge puc_rst)
if (puc_rst) anode_cnt <=  24'h00_0000;
else         anode_cnt <=  anode_cnt+24'h00_0001;

// Anode selection
wire [3:0] seg_an  = (4'h1 << anode_cnt[17:16]);
wire       seg_an0 = ~seg_an[0];
wire       seg_an1 = ~seg_an[1];
wire       seg_an2 = ~seg_an[2];
wire       seg_an3 = ~seg_an[3];


// Segment selection
//----------------------------

wire [7:0] digit  = seg_an[0] ? digit0 :
	            seg_an[1] ? digit1 : 
                    seg_an[2] ? digit2 :
                                digit3;

wire       seg_a  = ~digit[7];
wire       seg_b  = ~digit[6];
wire       seg_c  = ~digit[5];
wire       seg_d  = ~digit[4];
wire       seg_e  = ~digit[3];
wire       seg_f  = ~digit[2];
wire       seg_g  = ~digit[1];
wire       seg_dp = ~digit[0];

	   
endmodule // driver_7segment








