/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module memory_instr_tlb_micro(
    input               clk,
    input               rst_n,
    
    //0-cycle; always accepted; highest priority
    input               micro_flush_do,
    
    //0-cycle; always accepted; lower priority
    input               micro_write_do,
    input       [49:0]  micro_write_value,
    
    //0-cycle output; if together with flush, then no match
    input               micro_check_do,
    input       [19:0]  micro_check_vpn,
    input       [5:0]   micro_check_asid,
    output              micro_check_matched,
    output      [49:0]  micro_check_result
);
    
//------------------------------------------------------------------------------

/*
[19:0]  vpn
[39:20] pfn
[45:40] asid
[46]    n noncachable
[47]    d dirty = write-enable
[48]    v valid
[49]    g global

[50]    loaded
*/

//------------------------------------------------------------------------------

reg [50:0] micro00; reg [50:0] micro01; reg [50:0] micro02; reg [50:0] micro03;

wire sel00 = micro_check_do && ~(micro_flush_do) && micro_check_vpn == micro00[19:0] && micro00[50] && (micro00[49] || micro_check_asid == micro00[45:40]);
wire sel01 = micro_check_do && ~(micro_flush_do) && micro_check_vpn == micro01[19:0] && micro01[50] && (micro01[49] || micro_check_asid == micro01[45:40]);
wire sel02 = micro_check_do && ~(micro_flush_do) && micro_check_vpn == micro02[19:0] && micro02[50] && (micro02[49] || micro_check_asid == micro02[45:40]);
wire sel03 = micro_check_do && ~(micro_flush_do) && micro_check_vpn == micro03[19:0] && micro03[50] && (micro03[49] || micro_check_asid == micro03[45:40]);

assign micro_check_matched = sel00 || sel01 || sel02 || sel03;

assign micro_check_result =
    (sel00)?    micro00[49:0] :
    (sel01)?    micro01[49:0] :
    (sel02)?    micro02[49:0] :
                micro03[49:0];

wire ena00 = `TRUE;
wire ena01 = ena00 && micro00[50];
wire ena02 = ena01 && micro01[50];
wire ena03 = ena02 && micro02[50];
wire full  = ena03 && micro03[50];
    
wire write00 = micro_write_do && ((~(micro00[50]) && ena00) || (full && ~(plru[0]) && ~(plru[1])));
wire write01 = micro_write_do && ((~(micro01[50]) && ena01) || (full && ~(plru[0]) &&  (plru[1])));
wire write02 = micro_write_do && ((~(micro02[50]) && ena02) || (full &&  (plru[0]) && ~(plru[2])));
wire write03 = micro_write_do && ((~(micro03[50]) && ena03) || (full &&  (plru[0]) &&  (plru[2])));

/* Tree pseudo LRU
 *        [0]
 *   [1]       [2]
 *  0  1      2  3
 */

localparam [2:0] MICRO_03_MASK  = 3'b101; //0,2
localparam [2:0] MICRO_03_VALUE = 3'b000; //0,2
    
localparam [2:0] MICRO_02_MASK  = 3'b101; //0,2
localparam [2:0] MICRO_02_VALUE = 3'b100; //0,2
    
localparam [2:0] MICRO_01_MASK  = 3'b011; //0,1
localparam [2:0] MICRO_01_VALUE = 3'b001; //0,1
    
localparam [2:0] MICRO_00_MASK  = 3'b011; //0,1
localparam [2:0] MICRO_00_VALUE = 3'b011; //0,1

reg [2:0] plru;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           plru <= 3'd0;
    else if(micro_flush_do)     plru <= 3'd0;
    else if(write00 || sel00)   plru <= (plru & ~(MICRO_00_MASK)) | MICRO_00_VALUE;
    else if(write01 || sel01)   plru <= (plru & ~(MICRO_01_MASK)) | MICRO_01_VALUE;
    else if(write02 || sel02)   plru <= (plru & ~(MICRO_02_MASK)) | MICRO_02_VALUE;
    else if(write03 || sel03)   plru <= (plru & ~(MICRO_03_MASK)) | MICRO_03_VALUE;
end

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) micro00 <= 51'd0; else if(micro_flush_do) micro00 <= 51'd0; else if(write00) micro00 <= { 1'b1, micro_write_value }; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) micro01 <= 51'd0; else if(micro_flush_do) micro01 <= 51'd0; else if(write01) micro01 <= { 1'b1, micro_write_value }; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) micro02 <= 51'd0; else if(micro_flush_do) micro02 <= 51'd0; else if(write02) micro02 <= { 1'b1, micro_write_value }; end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) micro03 <= 51'd0; else if(micro_flush_do) micro03 <= 51'd0; else if(write03) micro03 <= { 1'b1, micro_write_value }; end

endmodule
