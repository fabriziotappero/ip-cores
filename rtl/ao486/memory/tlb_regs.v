/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

`include "defines.v"

module tlb_regs(
    input               clk,
    input               rst_n,
    
    //RESP:
    input               tlbflushsingle_do,
    input   [31:0]      tlbflushsingle_address,
    //END
    
    //RESP:
    input               tlbflushall_do,
    //END
    
    input               rw,
    
    //RESP:
    input               tlbregs_write_do,
    input   [31:0]      tlbregs_write_linear,
    input   [31:0]      tlbregs_write_physical,
    
    input               tlbregs_write_pwt,
    input               tlbregs_write_pcd,
    input               tlbregs_write_combined_rw,
    input               tlbregs_write_combined_su,
    //END
    
    //RESP:
    input               translate_do,
    input   [31:0]      translate_linear,
    output              translate_valid,
    output  [31:0]      translate_physical,
    output              translate_pwt,
    output              translate_pcd,
    output              translate_combined_rw,
    output              translate_combined_su
    //END
);

//------------------------------------------------------------------------------

/* [19:0]   linear page address
 * [39:20]  physical page address
 * 
 * [40]     PWT
 * [41]     PCD
 * 
 * [42]     valid
 * 
 * [43]     combined r/w
 * [44]     combined s/u
 *
 * [45]     dirty
 */
 
`define TLB_BIT_VALID 42

//------------------------------------------------------------------------------

reg [30:0] plru;

reg [45:0] tlb0;
reg [45:0] tlb1;
reg [45:0] tlb2;
reg [45:0] tlb3;
reg [45:0] tlb4;
reg [45:0] tlb5;
reg [45:0] tlb6;
reg [45:0] tlb7;
reg [45:0] tlb8;
reg [45:0] tlb9;
reg [45:0] tlb10;
reg [45:0] tlb11;
reg [45:0] tlb12;
reg [45:0] tlb13;
reg [45:0] tlb14;
reg [45:0] tlb15;
reg [45:0] tlb16;
reg [45:0] tlb17;
reg [45:0] tlb18;
reg [45:0] tlb19;
reg [45:0] tlb20;
reg [45:0] tlb21;
reg [45:0] tlb22;
reg [45:0] tlb23;
reg [45:0] tlb24;
reg [45:0] tlb25;
reg [45:0] tlb26;
reg [45:0] tlb27;
reg [45:0] tlb28;
reg [45:0] tlb29;
reg [45:0] tlb30;
reg [45:0] tlb31;

//------------------------------------------------------------------------------

wire tlb0_sel;
wire tlb1_sel;
wire tlb2_sel;
wire tlb3_sel;
wire tlb4_sel;
wire tlb5_sel;
wire tlb6_sel;
wire tlb7_sel;
wire tlb8_sel;
wire tlb9_sel;
wire tlb10_sel;
wire tlb11_sel;
wire tlb12_sel;
wire tlb13_sel;
wire tlb14_sel;
wire tlb15_sel;
wire tlb16_sel;
wire tlb17_sel;
wire tlb18_sel;
wire tlb19_sel;
wire tlb20_sel;
wire tlb21_sel;
wire tlb22_sel;
wire tlb23_sel;
wire tlb24_sel;
wire tlb25_sel;
wire tlb26_sel;
wire tlb27_sel;
wire tlb28_sel;
wire tlb29_sel;
wire tlb30_sel;
wire tlb31_sel;

wire tlb0_ena;
wire tlb1_ena;
wire tlb2_ena;
wire tlb3_ena;
wire tlb4_ena;
wire tlb5_ena;
wire tlb6_ena;
wire tlb7_ena;
wire tlb8_ena;
wire tlb9_ena;
wire tlb10_ena;
wire tlb11_ena;
wire tlb12_ena;
wire tlb13_ena;
wire tlb14_ena;
wire tlb15_ena;
wire tlb16_ena;
wire tlb17_ena;
wire tlb18_ena;
wire tlb19_ena;
wire tlb20_ena;
wire tlb21_ena;
wire tlb22_ena;
wire tlb23_ena;
wire tlb24_ena;
wire tlb25_ena;
wire tlb26_ena;
wire tlb27_ena;
wire tlb28_ena;
wire tlb29_ena;
wire tlb30_ena;
wire tlb31_ena;

wire full;

wire tlb0_write;
wire tlb1_write;
wire tlb2_write;
wire tlb3_write;
wire tlb4_write;
wire tlb5_write;
wire tlb6_write;
wire tlb7_write;
wire tlb8_write;
wire tlb9_write;
wire tlb10_write;
wire tlb11_write;
wire tlb12_write;
wire tlb13_write;
wire tlb14_write;
wire tlb15_write;
wire tlb16_write;
wire tlb17_write;
wire tlb18_write;
wire tlb19_write;
wire tlb20_write;
wire tlb21_write;
wire tlb22_write;
wire tlb23_write;
wire tlb24_write;
wire tlb25_write;
wire tlb26_write;
wire tlb27_write;
wire tlb28_write;
wire tlb29_write;
wire tlb30_write;
wire tlb31_write;

wire tlb0_tlbflush;
wire tlb1_tlbflush;
wire tlb2_tlbflush;
wire tlb3_tlbflush;
wire tlb4_tlbflush;
wire tlb5_tlbflush;
wire tlb6_tlbflush;
wire tlb7_tlbflush;
wire tlb8_tlbflush;
wire tlb9_tlbflush;
wire tlb10_tlbflush;
wire tlb11_tlbflush;
wire tlb12_tlbflush;
wire tlb13_tlbflush;
wire tlb14_tlbflush;
wire tlb15_tlbflush;
wire tlb16_tlbflush;
wire tlb17_tlbflush;
wire tlb18_tlbflush;
wire tlb19_tlbflush;
wire tlb20_tlbflush;
wire tlb21_tlbflush;
wire tlb22_tlbflush;
wire tlb23_tlbflush;
wire tlb24_tlbflush;
wire tlb25_tlbflush;
wire tlb26_tlbflush;
wire tlb27_tlbflush;
wire tlb28_tlbflush;
wire tlb29_tlbflush;
wire tlb30_tlbflush;
wire tlb31_tlbflush;

wire [45:0] selected;

wire [45:0] write_data;

wire translate_valid_but_not_dirty;

//------------------------------------------------------------------------------

assign translate_valid_but_not_dirty = selected[`TLB_BIT_VALID] && rw && ~(selected[45]);

//AO-notlb: assign translate_valid          = 1'b0;
assign translate_valid          = selected[`TLB_BIT_VALID] && (~(rw) || selected[45]); //read access or dirty bit already set
assign translate_physical       = (translate_valid)? { selected[39:20], translate_linear[11:0] } : translate_linear;
assign translate_pwt            = selected[40];
assign translate_pcd            = selected[41];
assign translate_combined_rw    = selected[43];
assign translate_combined_su    = selected[44];

assign tlb0_sel  = translate_do && translate_linear[31:12] == tlb0[19:0]  && tlb0 [`TLB_BIT_VALID];
assign tlb1_sel  = translate_do && translate_linear[31:12] == tlb1[19:0]  && tlb1 [`TLB_BIT_VALID];
assign tlb2_sel  = translate_do && translate_linear[31:12] == tlb2[19:0]  && tlb2 [`TLB_BIT_VALID];
assign tlb3_sel  = translate_do && translate_linear[31:12] == tlb3[19:0]  && tlb3 [`TLB_BIT_VALID];
assign tlb4_sel  = translate_do && translate_linear[31:12] == tlb4[19:0]  && tlb4 [`TLB_BIT_VALID];
assign tlb5_sel  = translate_do && translate_linear[31:12] == tlb5[19:0]  && tlb5 [`TLB_BIT_VALID];
assign tlb6_sel  = translate_do && translate_linear[31:12] == tlb6[19:0]  && tlb6 [`TLB_BIT_VALID];
assign tlb7_sel  = translate_do && translate_linear[31:12] == tlb7[19:0]  && tlb7 [`TLB_BIT_VALID];
assign tlb8_sel  = translate_do && translate_linear[31:12] == tlb8[19:0]  && tlb8 [`TLB_BIT_VALID];
assign tlb9_sel  = translate_do && translate_linear[31:12] == tlb9[19:0]  && tlb9 [`TLB_BIT_VALID];
assign tlb10_sel = translate_do && translate_linear[31:12] == tlb10[19:0] && tlb10[`TLB_BIT_VALID];
assign tlb11_sel = translate_do && translate_linear[31:12] == tlb11[19:0] && tlb11[`TLB_BIT_VALID];
assign tlb12_sel = translate_do && translate_linear[31:12] == tlb12[19:0] && tlb12[`TLB_BIT_VALID];
assign tlb13_sel = translate_do && translate_linear[31:12] == tlb13[19:0] && tlb13[`TLB_BIT_VALID];
assign tlb14_sel = translate_do && translate_linear[31:12] == tlb14[19:0] && tlb14[`TLB_BIT_VALID];
assign tlb15_sel = translate_do && translate_linear[31:12] == tlb15[19:0] && tlb15[`TLB_BIT_VALID];
assign tlb16_sel = translate_do && translate_linear[31:12] == tlb16[19:0] && tlb16[`TLB_BIT_VALID];
assign tlb17_sel = translate_do && translate_linear[31:12] == tlb17[19:0] && tlb17[`TLB_BIT_VALID];
assign tlb18_sel = translate_do && translate_linear[31:12] == tlb18[19:0] && tlb18[`TLB_BIT_VALID];
assign tlb19_sel = translate_do && translate_linear[31:12] == tlb19[19:0] && tlb19[`TLB_BIT_VALID];
assign tlb20_sel = translate_do && translate_linear[31:12] == tlb20[19:0] && tlb20[`TLB_BIT_VALID];
assign tlb21_sel = translate_do && translate_linear[31:12] == tlb21[19:0] && tlb21[`TLB_BIT_VALID];
assign tlb22_sel = translate_do && translate_linear[31:12] == tlb22[19:0] && tlb22[`TLB_BIT_VALID];
assign tlb23_sel = translate_do && translate_linear[31:12] == tlb23[19:0] && tlb23[`TLB_BIT_VALID];
assign tlb24_sel = translate_do && translate_linear[31:12] == tlb24[19:0] && tlb24[`TLB_BIT_VALID];
assign tlb25_sel = translate_do && translate_linear[31:12] == tlb25[19:0] && tlb25[`TLB_BIT_VALID];
assign tlb26_sel = translate_do && translate_linear[31:12] == tlb26[19:0] && tlb26[`TLB_BIT_VALID];
assign tlb27_sel = translate_do && translate_linear[31:12] == tlb27[19:0] && tlb27[`TLB_BIT_VALID];
assign tlb28_sel = translate_do && translate_linear[31:12] == tlb28[19:0] && tlb28[`TLB_BIT_VALID];
assign tlb29_sel = translate_do && translate_linear[31:12] == tlb29[19:0] && tlb29[`TLB_BIT_VALID];
assign tlb30_sel = translate_do && translate_linear[31:12] == tlb30[19:0] && tlb30[`TLB_BIT_VALID];
assign tlb31_sel = translate_do && translate_linear[31:12] == tlb31[19:0] && tlb31[`TLB_BIT_VALID];

assign selected =
    (tlb0_sel)?   tlb0 :
    (tlb1_sel)?   tlb1 :
    (tlb2_sel)?   tlb2 :
    (tlb3_sel)?   tlb3 :
    (tlb4_sel)?   tlb4 :
    (tlb5_sel)?   tlb5 :
    (tlb6_sel)?   tlb6 :
    (tlb7_sel)?   tlb7 :
    (tlb8_sel)?   tlb8 :
    (tlb9_sel)?   tlb9 :
    (tlb10_sel)?  tlb10 :
    (tlb11_sel)?  tlb11 :
    (tlb12_sel)?  tlb12 :
    (tlb13_sel)?  tlb13 :
    (tlb14_sel)?  tlb14 :
    (tlb15_sel)?  tlb15 :
    (tlb16_sel)?  tlb16 :
    (tlb17_sel)?  tlb17 :
    (tlb18_sel)?  tlb18 :
    (tlb19_sel)?  tlb19 :
    (tlb20_sel)?  tlb20 :
    (tlb21_sel)?  tlb21 :
    (tlb22_sel)?  tlb22 :
    (tlb23_sel)?  tlb23 :
    (tlb24_sel)?  tlb24 :
    (tlb25_sel)?  tlb25 :
    (tlb26_sel)?  tlb26 :
    (tlb27_sel)?  tlb27 :
    (tlb28_sel)?  tlb28 :
    (tlb29_sel)?  tlb29 :
    (tlb30_sel)?  tlb30 :
    (tlb31_sel)?  tlb31 :
                  46'd0;

assign tlb0_ena  = `TRUE;
assign tlb1_ena  = tlb0_ena  && tlb0 [`TLB_BIT_VALID];
assign tlb2_ena  = tlb1_ena  && tlb1 [`TLB_BIT_VALID];
assign tlb3_ena  = tlb2_ena  && tlb2 [`TLB_BIT_VALID];
assign tlb4_ena  = tlb3_ena  && tlb3 [`TLB_BIT_VALID];
assign tlb5_ena  = tlb4_ena  && tlb4 [`TLB_BIT_VALID];
assign tlb6_ena  = tlb5_ena  && tlb5 [`TLB_BIT_VALID];
assign tlb7_ena  = tlb6_ena  && tlb6 [`TLB_BIT_VALID];
assign tlb8_ena  = tlb7_ena  && tlb7 [`TLB_BIT_VALID];
assign tlb9_ena  = tlb8_ena  && tlb8 [`TLB_BIT_VALID];
assign tlb10_ena = tlb9_ena  && tlb9 [`TLB_BIT_VALID];
assign tlb11_ena = tlb10_ena && tlb10[`TLB_BIT_VALID];
assign tlb12_ena = tlb11_ena && tlb11[`TLB_BIT_VALID];
assign tlb13_ena = tlb12_ena && tlb12[`TLB_BIT_VALID];
assign tlb14_ena = tlb13_ena && tlb13[`TLB_BIT_VALID];
assign tlb15_ena = tlb14_ena && tlb14[`TLB_BIT_VALID];
assign tlb16_ena = tlb15_ena && tlb15[`TLB_BIT_VALID];
assign tlb17_ena = tlb16_ena && tlb16[`TLB_BIT_VALID];
assign tlb18_ena = tlb17_ena && tlb17[`TLB_BIT_VALID];
assign tlb19_ena = tlb18_ena && tlb18[`TLB_BIT_VALID];
assign tlb20_ena = tlb19_ena && tlb19[`TLB_BIT_VALID];
assign tlb21_ena = tlb20_ena && tlb20[`TLB_BIT_VALID];
assign tlb22_ena = tlb21_ena && tlb21[`TLB_BIT_VALID];
assign tlb23_ena = tlb22_ena && tlb22[`TLB_BIT_VALID];
assign tlb24_ena = tlb23_ena && tlb23[`TLB_BIT_VALID];
assign tlb25_ena = tlb24_ena && tlb24[`TLB_BIT_VALID];
assign tlb26_ena = tlb25_ena && tlb25[`TLB_BIT_VALID];
assign tlb27_ena = tlb26_ena && tlb26[`TLB_BIT_VALID];
assign tlb28_ena = tlb27_ena && tlb27[`TLB_BIT_VALID];
assign tlb29_ena = tlb28_ena && tlb28[`TLB_BIT_VALID];
assign tlb30_ena = tlb29_ena && tlb29[`TLB_BIT_VALID];
assign tlb31_ena = tlb30_ena && tlb30[`TLB_BIT_VALID];
    
assign full = tlb31_ena && tlb31[`TLB_BIT_VALID];
    
assign tlb0_write  = tlbregs_write_do && ((~(tlb0[`TLB_BIT_VALID])  && tlb0_ena)  || (full && ~(plru[0]) && ~(plru[1]) && ~(plru[3]) && ~(plru[7])  && ~(plru[15])));
assign tlb1_write  = tlbregs_write_do && ((~(tlb1[`TLB_BIT_VALID])  && tlb1_ena)  || (full && ~(plru[0]) && ~(plru[1]) && ~(plru[3]) && ~(plru[7])  &&  (plru[15])));
assign tlb2_write  = tlbregs_write_do && ((~(tlb2[`TLB_BIT_VALID])  && tlb2_ena)  || (full && ~(plru[0]) && ~(plru[1]) && ~(plru[3]) &&  (plru[7])  && ~(plru[16])));
assign tlb3_write  = tlbregs_write_do && ((~(tlb3[`TLB_BIT_VALID])  && tlb3_ena)  || (full && ~(plru[0]) && ~(plru[1]) && ~(plru[3]) &&  (plru[7])  &&  (plru[16])));
assign tlb4_write  = tlbregs_write_do && ((~(tlb4[`TLB_BIT_VALID])  && tlb4_ena)  || (full && ~(plru[0]) && ~(plru[1]) &&  (plru[3]) && ~(plru[8])  && ~(plru[17])));
assign tlb5_write  = tlbregs_write_do && ((~(tlb5[`TLB_BIT_VALID])  && tlb5_ena)  || (full && ~(plru[0]) && ~(plru[1]) &&  (plru[3]) && ~(plru[8])  &&  (plru[17])));
assign tlb6_write  = tlbregs_write_do && ((~(tlb6[`TLB_BIT_VALID])  && tlb6_ena)  || (full && ~(plru[0]) && ~(plru[1]) &&  (plru[3]) &&  (plru[8])  && ~(plru[18])));
assign tlb7_write  = tlbregs_write_do && ((~(tlb7[`TLB_BIT_VALID])  && tlb7_ena)  || (full && ~(plru[0]) && ~(plru[1]) &&  (plru[3]) &&  (plru[8])  &&  (plru[18])));
assign tlb8_write  = tlbregs_write_do && ((~(tlb8[`TLB_BIT_VALID])  && tlb8_ena)  || (full && ~(plru[0]) &&  (plru[1]) && ~(plru[4]) && ~(plru[9])  && ~(plru[19])));
assign tlb9_write  = tlbregs_write_do && ((~(tlb9[`TLB_BIT_VALID])  && tlb9_ena)  || (full && ~(plru[0]) &&  (plru[1]) && ~(plru[4]) && ~(plru[9])  &&  (plru[19])));
assign tlb10_write = tlbregs_write_do && ((~(tlb10[`TLB_BIT_VALID]) && tlb10_ena) || (full && ~(plru[0]) &&  (plru[1]) && ~(plru[4]) &&  (plru[9])  && ~(plru[20])));
assign tlb11_write = tlbregs_write_do && ((~(tlb11[`TLB_BIT_VALID]) && tlb11_ena) || (full && ~(plru[0]) &&  (plru[1]) && ~(plru[4]) &&  (plru[9])  &&  (plru[20])));
assign tlb12_write = tlbregs_write_do && ((~(tlb12[`TLB_BIT_VALID]) && tlb12_ena) || (full && ~(plru[0]) &&  (plru[1]) &&  (plru[4]) && ~(plru[10]) && ~(plru[21])));
assign tlb13_write = tlbregs_write_do && ((~(tlb13[`TLB_BIT_VALID]) && tlb13_ena) || (full && ~(plru[0]) &&  (plru[1]) &&  (plru[4]) && ~(plru[10]) &&  (plru[21])));
assign tlb14_write = tlbregs_write_do && ((~(tlb14[`TLB_BIT_VALID]) && tlb14_ena) || (full && ~(plru[0]) &&  (plru[1]) &&  (plru[4]) &&  (plru[10]) && ~(plru[22])));
assign tlb15_write = tlbregs_write_do && ((~(tlb15[`TLB_BIT_VALID]) && tlb15_ena) || (full && ~(plru[0]) &&  (plru[1]) &&  (plru[4]) &&  (plru[10]) &&  (plru[22])));
assign tlb16_write = tlbregs_write_do && ((~(tlb16[`TLB_BIT_VALID]) && tlb16_ena) || (full &&  (plru[0]) && ~(plru[2]) && ~(plru[5]) && ~(plru[11]) && ~(plru[23])));
assign tlb17_write = tlbregs_write_do && ((~(tlb17[`TLB_BIT_VALID]) && tlb17_ena) || (full &&  (plru[0]) && ~(plru[2]) && ~(plru[5]) && ~(plru[11]) &&  (plru[23])));
assign tlb18_write = tlbregs_write_do && ((~(tlb18[`TLB_BIT_VALID]) && tlb18_ena) || (full &&  (plru[0]) && ~(plru[2]) && ~(plru[5]) &&  (plru[11]) && ~(plru[24])));
assign tlb19_write = tlbregs_write_do && ((~(tlb19[`TLB_BIT_VALID]) && tlb19_ena) || (full &&  (plru[0]) && ~(plru[2]) && ~(plru[5]) &&  (plru[11]) &&  (plru[24])));
assign tlb20_write = tlbregs_write_do && ((~(tlb20[`TLB_BIT_VALID]) && tlb20_ena) || (full &&  (plru[0]) && ~(plru[2]) &&  (plru[5]) && ~(plru[12]) && ~(plru[25])));
assign tlb21_write = tlbregs_write_do && ((~(tlb21[`TLB_BIT_VALID]) && tlb21_ena) || (full &&  (plru[0]) && ~(plru[2]) &&  (plru[5]) && ~(plru[12]) &&  (plru[25])));
assign tlb22_write = tlbregs_write_do && ((~(tlb22[`TLB_BIT_VALID]) && tlb22_ena) || (full &&  (plru[0]) && ~(plru[2]) &&  (plru[5]) &&  (plru[12]) && ~(plru[26])));
assign tlb23_write = tlbregs_write_do && ((~(tlb23[`TLB_BIT_VALID]) && tlb23_ena) || (full &&  (plru[0]) && ~(plru[2]) &&  (plru[5]) &&  (plru[12]) &&  (plru[26])));
assign tlb24_write = tlbregs_write_do && ((~(tlb24[`TLB_BIT_VALID]) && tlb24_ena) || (full &&  (plru[0]) &&  (plru[2]) && ~(plru[6]) && ~(plru[13]) && ~(plru[27])));
assign tlb25_write = tlbregs_write_do && ((~(tlb25[`TLB_BIT_VALID]) && tlb25_ena) || (full &&  (plru[0]) &&  (plru[2]) && ~(plru[6]) && ~(plru[13]) &&  (plru[27])));
assign tlb26_write = tlbregs_write_do && ((~(tlb26[`TLB_BIT_VALID]) && tlb26_ena) || (full &&  (plru[0]) &&  (plru[2]) && ~(plru[6]) &&  (plru[13]) && ~(plru[28])));
assign tlb27_write = tlbregs_write_do && ((~(tlb27[`TLB_BIT_VALID]) && tlb27_ena) || (full &&  (plru[0]) &&  (plru[2]) && ~(plru[6]) &&  (plru[13]) &&  (plru[28])));
assign tlb28_write = tlbregs_write_do && ((~(tlb28[`TLB_BIT_VALID]) && tlb28_ena) || (full &&  (plru[0]) &&  (plru[2]) &&  (plru[6]) && ~(plru[14]) && ~(plru[29])));
assign tlb29_write = tlbregs_write_do && ((~(tlb29[`TLB_BIT_VALID]) && tlb29_ena) || (full &&  (plru[0]) &&  (plru[2]) &&  (plru[6]) && ~(plru[14]) &&  (plru[29])));
assign tlb30_write = tlbregs_write_do && ((~(tlb30[`TLB_BIT_VALID]) && tlb30_ena) || (full &&  (plru[0]) &&  (plru[2]) &&  (plru[6]) &&  (plru[14]) && ~(plru[30])));
assign tlb31_write = tlbregs_write_do && ((~(tlb31[`TLB_BIT_VALID]) && tlb31_ena) || (full &&  (plru[0]) &&  (plru[2]) &&  (plru[6]) &&  (plru[14]) &&  (plru[30])));
    
    
assign tlb0_tlbflush  = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb0[19:0])  || (translate_valid_but_not_dirty && tlb0_sel);
assign tlb1_tlbflush  = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb1[19:0])  || (translate_valid_but_not_dirty && tlb1_sel);
assign tlb2_tlbflush  = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb2[19:0])  || (translate_valid_but_not_dirty && tlb2_sel);
assign tlb3_tlbflush  = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb3[19:0])  || (translate_valid_but_not_dirty && tlb3_sel);
assign tlb4_tlbflush  = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb4[19:0])  || (translate_valid_but_not_dirty && tlb4_sel);
assign tlb5_tlbflush  = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb5[19:0])  || (translate_valid_but_not_dirty && tlb5_sel);
assign tlb6_tlbflush  = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb6[19:0])  || (translate_valid_but_not_dirty && tlb6_sel);
assign tlb7_tlbflush  = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb7[19:0])  || (translate_valid_but_not_dirty && tlb7_sel);
assign tlb8_tlbflush  = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb8[19:0])  || (translate_valid_but_not_dirty && tlb8_sel);
assign tlb9_tlbflush  = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb9[19:0])  || (translate_valid_but_not_dirty && tlb9_sel);
assign tlb10_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb10[19:0]) || (translate_valid_but_not_dirty && tlb10_sel);
assign tlb11_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb11[19:0]) || (translate_valid_but_not_dirty && tlb11_sel);
assign tlb12_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb12[19:0]) || (translate_valid_but_not_dirty && tlb12_sel);
assign tlb13_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb13[19:0]) || (translate_valid_but_not_dirty && tlb13_sel);
assign tlb14_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb14[19:0]) || (translate_valid_but_not_dirty && tlb14_sel);
assign tlb15_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb15[19:0]) || (translate_valid_but_not_dirty && tlb15_sel);
assign tlb16_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb16[19:0]) || (translate_valid_but_not_dirty && tlb16_sel);
assign tlb17_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb17[19:0]) || (translate_valid_but_not_dirty && tlb17_sel);
assign tlb18_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb18[19:0]) || (translate_valid_but_not_dirty && tlb18_sel);
assign tlb19_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb19[19:0]) || (translate_valid_but_not_dirty && tlb19_sel);
assign tlb20_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb20[19:0]) || (translate_valid_but_not_dirty && tlb20_sel);
assign tlb21_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb21[19:0]) || (translate_valid_but_not_dirty && tlb21_sel);
assign tlb22_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb22[19:0]) || (translate_valid_but_not_dirty && tlb22_sel);
assign tlb23_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb23[19:0]) || (translate_valid_but_not_dirty && tlb23_sel);
assign tlb24_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb24[19:0]) || (translate_valid_but_not_dirty && tlb24_sel);
assign tlb25_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb25[19:0]) || (translate_valid_but_not_dirty && tlb25_sel);
assign tlb26_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb26[19:0]) || (translate_valid_but_not_dirty && tlb26_sel);
assign tlb27_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb27[19:0]) || (translate_valid_but_not_dirty && tlb27_sel);
assign tlb28_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb28[19:0]) || (translate_valid_but_not_dirty && tlb28_sel);
assign tlb29_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb29[19:0]) || (translate_valid_but_not_dirty && tlb29_sel);
assign tlb30_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb30[19:0]) || (translate_valid_but_not_dirty && tlb30_sel);
assign tlb31_tlbflush = (tlbflushsingle_do && tlbflushsingle_address[31:12] == tlb31[19:0]) || (translate_valid_but_not_dirty && tlb31_sel);
    
assign write_data = { rw, tlbregs_write_combined_su, tlbregs_write_combined_rw, 1'b1, tlbregs_write_pcd, tlbregs_write_pwt, tlbregs_write_physical[31:12], tlbregs_write_linear[31:12] };    

//------------------------------------------------------------------------------

/* Tree pseudo LRU
 * 
 *                                                                [0]
 *                              [1]                                                              [2]
 *               [3]                             [4]                            [5]                              [6]
 *       [7]             [8]             [9]            [10]            [11]            [12]            [13]            [14]                
 *  [15]    [16]    [17]    [18]    [19]    [20]    [21]    [22]    [23]    [24]    [25]    [26]    [27]    [28]    [29]    [30]
 *  0  1    2  3    4  5    6  7    8  9    10 11   12 13   14 15   16 17   18 19   20 21   22 23   24 25   26 27   28 29   30 31
 * 
 */
    
localparam [30:0] TLB31_MASK = 31'b1000000000000000100000001000101; //0,2,6,14,30
localparam [30:0] TLB31_VALUE= 31'b0000000000000000000000000000000; //0,2,6,14,30
    
localparam [30:0] TLB30_MASK = 31'b1000000000000000100000001000101; //0,2,6,14,30
localparam [30:0] TLB30_VALUE= 31'b1000000000000000000000000000000; //0,2,6,14,30
    
localparam [30:0] TLB29_MASK = 31'b0100000000000000100000001000101; //0,2,6,14,29
localparam [30:0] TLB29_VALUE= 31'b0000000000000000100000000000000; //0,2,6,14,29
    
localparam [30:0] TLB28_MASK = 31'b0100000000000000100000001000101; //0,2,6,14,29
localparam [30:0] TLB28_VALUE= 31'b0100000000000000100000000000000; //0,2,6,14,29
    
localparam [30:0] TLB27_MASK = 31'b0010000000000000010000001000101; //0,2,6,13,28
localparam [30:0] TLB27_VALUE= 31'b0000000000000000000000001000000; //0,2,6,13,28
    
localparam [30:0] TLB26_MASK = 31'b0010000000000000010000001000101; //0,2,6,13,28
localparam [30:0] TLB26_VALUE= 31'b0010000000000000000000001000000; //0,2,6,13,28
    
localparam [30:0] TLB25_MASK = 31'b0001000000000000010000001000101; //0,2,6,13,27
localparam [30:0] TLB25_VALUE= 31'b0000000000000000010000001000000; //0,2,6,13,27
    
localparam [30:0] TLB24_MASK = 31'b0001000000000000010000001000101; //0,2,6,13,27
localparam [30:0] TLB24_VALUE= 31'b0001000000000000010000001000000; //0,2,6,13,27
    
localparam [30:0] TLB23_MASK = 31'b0000100000000000001000000100101; //0,2,5,12,26
localparam [30:0] TLB23_VALUE= 31'b0000000000000000000000000000100; //0,2,5,12,26
    
localparam [30:0] TLB22_MASK = 31'b0000100000000000001000000100101; //0,2,5,12,26
localparam [30:0] TLB22_VALUE= 31'b0000100000000000000000000000100; //0,2,5,12,26
    
localparam [30:0] TLB21_MASK = 31'b0000010000000000001000000100101; //0,2,5,12,25
localparam [30:0] TLB21_VALUE= 31'b0000000000000000001000000000100; //0,2,5,12,25
    
localparam [30:0] TLB20_MASK = 31'b0000010000000000001000000100101; //0,2,5,12,25
localparam [30:0] TLB20_VALUE= 31'b0000010000000000001000000000100; //0,2,5,12,25
    
localparam [30:0] TLB19_MASK = 31'b0000001000000000000100000100101; //0,2,5,11,24
localparam [30:0] TLB19_VALUE= 31'b0000000000000000000000000100100; //0,2,5,11,24
    
localparam [30:0] TLB18_MASK = 31'b0000001000000000000100000100101; //0,2,5,11,24
localparam [30:0] TLB18_VALUE= 31'b0000001000000000000000000100100; //0,2,5,11,24
    
localparam [30:0] TLB17_MASK = 31'b0000000100000000000100000100101; //0,2,5,11,23
localparam [30:0] TLB17_VALUE= 31'b0000000000000000000100000100100; //0,2,5,11,23
   
localparam [30:0] TLB16_MASK = 31'b0000000100000000000100000100101; //0,2,5,11,23
localparam [30:0] TLB16_VALUE= 31'b0000000100000000000100000100100; //0,2,5,11,23
    
localparam [30:0] TLB15_MASK = 31'b0000000010000000000010000010011; //0,1,4,10,22
localparam [30:0] TLB15_VALUE= 31'b0000000000000000000000000000001; //0,1,4,10,22
    
localparam [30:0] TLB14_MASK = 31'b0000000010000000000010000010011; //0,1,4,10,22
localparam [30:0] TLB14_VALUE= 31'b0000000010000000000000000000001; //0,1,4,10,22
    
localparam [30:0] TLB13_MASK = 31'b0000000001000000000010000010011; //0,1,4,10,21
localparam [30:0] TLB13_VALUE= 31'b0000000000000000000010000000001; //0,1,4,10,21
    
localparam [30:0] TLB12_MASK = 31'b0000000001000000000010000010011; //0,1,4,10,21
localparam [30:0] TLB12_VALUE= 31'b0000000001000000000010000000001; //0,1,4,10,21
    
localparam [30:0] TLB11_MASK = 31'b0000000000100000000001000010011; //0,1,4,9,20
localparam [30:0] TLB11_VALUE= 31'b0000000000000000000000000010001; //0,1,4,9,20
    
localparam [30:0] TLB10_MASK = 31'b0000000000100000000001000010011; //0,1,4,9,20
localparam [30:0] TLB10_VALUE= 31'b0000000000100000000000000010001; //0,1,4,9,20
    
localparam [30:0] TLB9_MASK  = 31'b0000000000010000000001000010011; //0,1,4,9,19
localparam [30:0] TLB9_VALUE = 31'b0000000000000000000001000010001; //0,1,4,9,19
  
localparam [30:0] TLB8_MASK  = 31'b0000000000010000000001000010011; //0,1,4,9,19
localparam [30:0] TLB8_VALUE = 31'b0000000000010000000001000010001; //0,1,4,9,19
    
localparam [30:0] TLB7_MASK  = 31'b0000000000001000000000100001011; //0,1,3,8,18
localparam [30:0] TLB7_VALUE = 31'b0000000000000000000000000000011; //0,1,3,8,18
   
localparam [30:0] TLB6_MASK  = 31'b0000000000001000000000100001011; //0,1,3,8,18
localparam [30:0] TLB6_VALUE = 31'b0000000000001000000000000000011; //0,1,3,8,18
    
localparam [30:0] TLB5_MASK  = 31'b0000000000000100000000100001011; //0,1,3,8,17
localparam [30:0] TLB5_VALUE = 31'b0000000000000000000000100000011; //0,1,3,8,17
    
localparam [30:0] TLB4_MASK  = 31'b0000000000000100000000100001011; //0,1,3,8,17
localparam [30:0] TLB4_VALUE = 31'b0000000000000100000000100000011; //0,1,3,8,17
    
localparam [30:0] TLB3_MASK  = 31'b0000000000000010000000010001011; //0,1,3,7,16
localparam [30:0] TLB3_VALUE = 31'b0000000000000000000000000001011; //0,1,3,7,16
    
localparam [30:0] TLB2_MASK  = 31'b0000000000000010000000010001011; //0,1,3,7,16
localparam [30:0] TLB2_VALUE = 31'b0000000000000010000000000001011; //0,1,3,7,16
    
localparam [30:0] TLB1_MASK  = 31'b0000000000000001000000010001011; //0,1,3,7,15
localparam [30:0] TLB1_VALUE = 31'b0000000000000000000000010001011; //0,1,3,7,15
    
localparam [30:0] TLB0_MASK  = 31'b0000000000000001000000010001011; //0,1,3,7,15
localparam [30:0] TLB0_VALUE = 31'b0000000000000001000000010001011; //0,1,3,7,15
    
//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   plru <= 31'd0;
    else if(tlbflushall_do)             plru <= 31'd0;
    else if(tlb0_write  || tlb0_sel)    plru <= (plru & ~(TLB0_MASK))  | TLB0_VALUE;
    else if(tlb1_write  || tlb1_sel)    plru <= (plru & ~(TLB1_MASK))  | TLB1_VALUE;
    else if(tlb2_write  || tlb2_sel)    plru <= (plru & ~(TLB2_MASK))  | TLB2_VALUE;
    else if(tlb3_write  || tlb3_sel)    plru <= (plru & ~(TLB3_MASK))  | TLB3_VALUE;
    else if(tlb4_write  || tlb4_sel)    plru <= (plru & ~(TLB4_MASK))  | TLB4_VALUE;
    else if(tlb5_write  || tlb5_sel)    plru <= (plru & ~(TLB5_MASK))  | TLB5_VALUE;
    else if(tlb6_write  || tlb6_sel)    plru <= (plru & ~(TLB6_MASK))  | TLB6_VALUE;
    else if(tlb7_write  || tlb7_sel)    plru <= (plru & ~(TLB7_MASK))  | TLB7_VALUE;
    else if(tlb8_write  || tlb8_sel)    plru <= (plru & ~(TLB8_MASK))  | TLB8_VALUE;
    else if(tlb9_write  || tlb9_sel)    plru <= (plru & ~(TLB9_MASK))  | TLB9_VALUE;
    else if(tlb10_write || tlb10_sel)   plru <= (plru & ~(TLB10_MASK)) | TLB10_VALUE;
    else if(tlb11_write || tlb11_sel)   plru <= (plru & ~(TLB11_MASK)) | TLB11_VALUE;
    else if(tlb12_write || tlb12_sel)   plru <= (plru & ~(TLB12_MASK)) | TLB12_VALUE;
    else if(tlb13_write || tlb13_sel)   plru <= (plru & ~(TLB13_MASK)) | TLB13_VALUE;
    else if(tlb14_write || tlb14_sel)   plru <= (plru & ~(TLB14_MASK)) | TLB14_VALUE;
    else if(tlb15_write || tlb15_sel)   plru <= (plru & ~(TLB15_MASK)) | TLB15_VALUE;
    else if(tlb16_write || tlb16_sel)   plru <= (plru & ~(TLB16_MASK)) | TLB16_VALUE;
    else if(tlb17_write || tlb17_sel)   plru <= (plru & ~(TLB17_MASK)) | TLB17_VALUE;
    else if(tlb18_write || tlb18_sel)   plru <= (plru & ~(TLB18_MASK)) | TLB18_VALUE;
    else if(tlb19_write || tlb19_sel)   plru <= (plru & ~(TLB19_MASK)) | TLB19_VALUE;
    else if(tlb20_write || tlb20_sel)   plru <= (plru & ~(TLB20_MASK)) | TLB20_VALUE;
    else if(tlb21_write || tlb21_sel)   plru <= (plru & ~(TLB21_MASK)) | TLB21_VALUE;
    else if(tlb22_write || tlb22_sel)   plru <= (plru & ~(TLB22_MASK)) | TLB22_VALUE;
    else if(tlb23_write || tlb23_sel)   plru <= (plru & ~(TLB23_MASK)) | TLB23_VALUE;
    else if(tlb24_write || tlb24_sel)   plru <= (plru & ~(TLB24_MASK)) | TLB24_VALUE;
    else if(tlb25_write || tlb25_sel)   plru <= (plru & ~(TLB25_MASK)) | TLB25_VALUE;
    else if(tlb26_write || tlb26_sel)   plru <= (plru & ~(TLB26_MASK)) | TLB26_VALUE;
    else if(tlb27_write || tlb27_sel)   plru <= (plru & ~(TLB27_MASK)) | TLB27_VALUE;
    else if(tlb28_write || tlb28_sel)   plru <= (plru & ~(TLB28_MASK)) | TLB28_VALUE;
    else if(tlb29_write || tlb29_sel)   plru <= (plru & ~(TLB29_MASK)) | TLB29_VALUE;
    else if(tlb30_write || tlb30_sel)   plru <= (plru & ~(TLB30_MASK)) | TLB30_VALUE;
    else if(tlb31_write || tlb31_sel)   plru <= (plru & ~(TLB31_MASK)) | TLB31_VALUE;
end

 
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb0 <= 46'd0;  else if(tlbflushall_do || tlb0_tlbflush)  tlb0  <= 46'd0; else if(tlb0_write)  tlb0  <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb1 <= 46'd0;  else if(tlbflushall_do || tlb1_tlbflush)  tlb1  <= 46'd0; else if(tlb1_write)  tlb1  <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb2 <= 46'd0;  else if(tlbflushall_do || tlb2_tlbflush)  tlb2  <= 46'd0; else if(tlb2_write)  tlb2  <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb3 <= 46'd0;  else if(tlbflushall_do || tlb3_tlbflush)  tlb3  <= 46'd0; else if(tlb3_write)  tlb3  <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb4 <= 46'd0;  else if(tlbflushall_do || tlb4_tlbflush)  tlb4  <= 46'd0; else if(tlb4_write)  tlb4  <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb5 <= 46'd0;  else if(tlbflushall_do || tlb5_tlbflush)  tlb5  <= 46'd0; else if(tlb5_write)  tlb5  <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb6 <= 46'd0;  else if(tlbflushall_do || tlb6_tlbflush)  tlb6  <= 46'd0; else if(tlb6_write)  tlb6  <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb7 <= 46'd0;  else if(tlbflushall_do || tlb7_tlbflush)  tlb7  <= 46'd0; else if(tlb7_write)  tlb7  <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb8 <= 46'd0;  else if(tlbflushall_do || tlb8_tlbflush)  tlb8  <= 46'd0; else if(tlb8_write)  tlb8  <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb9 <= 46'd0;  else if(tlbflushall_do || tlb9_tlbflush)  tlb9  <= 46'd0; else if(tlb9_write)  tlb9  <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb10 <= 46'd0; else if(tlbflushall_do || tlb10_tlbflush) tlb10 <= 46'd0; else if(tlb10_write) tlb10 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb11 <= 46'd0; else if(tlbflushall_do || tlb11_tlbflush) tlb11 <= 46'd0; else if(tlb11_write) tlb11 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb12 <= 46'd0; else if(tlbflushall_do || tlb12_tlbflush) tlb12 <= 46'd0; else if(tlb12_write) tlb12 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb13 <= 46'd0; else if(tlbflushall_do || tlb13_tlbflush) tlb13 <= 46'd0; else if(tlb13_write) tlb13 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb14 <= 46'd0; else if(tlbflushall_do || tlb14_tlbflush) tlb14 <= 46'd0; else if(tlb14_write) tlb14 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb15 <= 46'd0; else if(tlbflushall_do || tlb15_tlbflush) tlb15 <= 46'd0; else if(tlb15_write) tlb15 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb16 <= 46'd0; else if(tlbflushall_do || tlb16_tlbflush) tlb16 <= 46'd0; else if(tlb16_write) tlb16 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb17 <= 46'd0; else if(tlbflushall_do || tlb17_tlbflush) tlb17 <= 46'd0; else if(tlb17_write) tlb17 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb18 <= 46'd0; else if(tlbflushall_do || tlb18_tlbflush) tlb18 <= 46'd0; else if(tlb18_write) tlb18 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb19 <= 46'd0; else if(tlbflushall_do || tlb19_tlbflush) tlb19 <= 46'd0; else if(tlb19_write) tlb19 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb20 <= 46'd0; else if(tlbflushall_do || tlb20_tlbflush) tlb20 <= 46'd0; else if(tlb20_write) tlb20 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb21 <= 46'd0; else if(tlbflushall_do || tlb21_tlbflush) tlb21 <= 46'd0; else if(tlb21_write) tlb21 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb22 <= 46'd0; else if(tlbflushall_do || tlb22_tlbflush) tlb22 <= 46'd0; else if(tlb22_write) tlb22 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb23 <= 46'd0; else if(tlbflushall_do || tlb23_tlbflush) tlb23 <= 46'd0; else if(tlb23_write) tlb23 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb24 <= 46'd0; else if(tlbflushall_do || tlb24_tlbflush) tlb24 <= 46'd0; else if(tlb24_write) tlb24 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb25 <= 46'd0; else if(tlbflushall_do || tlb25_tlbflush) tlb25 <= 46'd0; else if(tlb25_write) tlb25 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb26 <= 46'd0; else if(tlbflushall_do || tlb26_tlbflush) tlb26 <= 46'd0; else if(tlb26_write) tlb26 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb27 <= 46'd0; else if(tlbflushall_do || tlb27_tlbflush) tlb27 <= 46'd0; else if(tlb27_write) tlb27 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb28 <= 46'd0; else if(tlbflushall_do || tlb28_tlbflush) tlb28 <= 46'd0; else if(tlb28_write) tlb28 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb29 <= 46'd0; else if(tlbflushall_do || tlb29_tlbflush) tlb29 <= 46'd0; else if(tlb29_write) tlb29 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb30 <= 46'd0; else if(tlbflushall_do || tlb30_tlbflush) tlb30 <= 46'd0; else if(tlb30_write) tlb30 <= write_data; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb31 <= 46'd0; else if(tlbflushall_do || tlb31_tlbflush) tlb31 <= 46'd0; else if(tlb31_write) tlb31 <= write_data; end

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, tlbflushsingle_address[11:0], tlbregs_write_linear[11:0], selected[19:0], tlbregs_write_physical[11:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
