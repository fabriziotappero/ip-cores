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

module read_segment(
    
    //general input
    input       [63:0]  es_cache,
    input       [63:0]  cs_cache,
    input       [63:0]  ss_cache,
    input       [63:0]  ds_cache,
    input       [63:0]  fs_cache,
    input       [63:0]  gs_cache,
    input       [63:0]  tr_cache,
    input       [63:0]  ldtr_cache,
    
    input               es_cache_valid,
    input               cs_cache_valid,
    input               ss_cache_valid,
    input               ds_cache_valid,
    input               fs_cache_valid,
    input               gs_cache_valid,
    
    //address control
    input               address_stack_pop,
    input               address_stack_pop_next,
    input               address_enter_last,
    input               address_enter,
    input               address_leave,
    
    input               address_edi,
    
    //read control
    input               read_virtual,
    input               read_rmw_virtual,
    input               write_virtual_check,
    
    input       [31:0]  rd_address_effective,
    input               rd_address_effective_ready,
    input       [3:0]   read_length,
    
    input       [2:0]   rd_prefix_group_2_seg,
    
    //output
    output      [31:0]  tr_base,
    output      [31:0]  ldtr_base,
    
    output      [31:0]  tr_limit,
    output      [31:0]  ldtr_limit,
    
    output              rd_seg_gp_fault_init,
    output              rd_seg_ss_fault_init,
    
    output      [31:0]  rd_seg_linear
);

//------------------------------------------------------------------------------

wire [31:0] es_limit;
wire [31:0] cs_limit;
wire [31:0] ss_limit;
wire [31:0] ds_limit;
wire [31:0] fs_limit;
wire [31:0] gs_limit;

wire [31:0] es_base;
wire [31:0] cs_base;
wire [31:0] ss_base;
wire [31:0] ds_base;
wire [31:0] fs_base;
wire [31:0] gs_base;

wire [31:0] es_left;
wire [31:0] cs_left;
wire [31:0] ss_left;
wire [31:0] ds_left;
wire [31:0] fs_left;
wire [31:0] gs_left;

wire [2:0]  seg_select;
wire        seg_read;
wire        seg_write;

wire        seg_limit_overflow;
wire [4:0]  seg_left;
wire        seg_invalid_read_access;
wire        seg_invalid_write_access;
wire        seg_valid;

wire        seg_fault;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

assign es_limit    = es_cache[`DESC_BIT_G]? { es_cache[51:48], es_cache[15:0], 12'hFFF } : { 12'd0, es_cache[51:48], es_cache[15:0] };
assign cs_limit    = cs_cache[`DESC_BIT_G]? { cs_cache[51:48], cs_cache[15:0], 12'hFFF } : { 12'd0, cs_cache[51:48], cs_cache[15:0] };
assign ss_limit    = ss_cache[`DESC_BIT_G]? { ss_cache[51:48], ss_cache[15:0], 12'hFFF } : { 12'd0, ss_cache[51:48], ss_cache[15:0] };
assign ds_limit    = ds_cache[`DESC_BIT_G]? { ds_cache[51:48], ds_cache[15:0], 12'hFFF } : { 12'd0, ds_cache[51:48], ds_cache[15:0] };
assign fs_limit    = fs_cache[`DESC_BIT_G]? { fs_cache[51:48], fs_cache[15:0], 12'hFFF } : { 12'd0, fs_cache[51:48], fs_cache[15:0] };
assign gs_limit    = gs_cache[`DESC_BIT_G]? { gs_cache[51:48], gs_cache[15:0], 12'hFFF } : { 12'd0, gs_cache[51:48], gs_cache[15:0] };
assign tr_limit    = tr_cache  [`DESC_BIT_G]? {   tr_cache[51:48],   tr_cache[15:0], 12'hFFF } : { 12'd0, tr_cache  [51:48],   tr_cache[15:0] };
assign ldtr_limit  = ldtr_cache[`DESC_BIT_G]? { ldtr_cache[51:48], ldtr_cache[15:0], 12'hFFF } : { 12'd0, ldtr_cache[51:48], ldtr_cache[15:0] };

assign es_base     = { es_cache[63:56], es_cache[39:16] };
assign cs_base     = { cs_cache[63:56], cs_cache[39:16] };
assign ss_base     = { ss_cache[63:56], ss_cache[39:16] };
assign ds_base     = { ds_cache[63:56], ds_cache[39:16] };
assign fs_base     = { fs_cache[63:56], fs_cache[39:16] };
assign gs_base     = { gs_cache[63:56], gs_cache[39:16] };
assign tr_base     = {   tr_cache[63:56],   tr_cache[39:16] };
assign ldtr_base   = { ldtr_cache[63:56], ldtr_cache[39:16] };

// (CODE or not EXPAND-DOWN)
assign es_left = (es_cache[43] || !es_cache[42])? es_limit - rd_address_effective : { {16{es_cache[54]}}, 16'hFFFF } - rd_address_effective;
assign cs_left = (cs_cache[43] || !cs_cache[42])? cs_limit - rd_address_effective : { {16{cs_cache[54]}}, 16'hFFFF } - rd_address_effective;
assign ss_left = (ss_cache[43] || !ss_cache[42])? ss_limit - rd_address_effective : { {16{ss_cache[54]}}, 16'hFFFF } - rd_address_effective;
assign ds_left = (ds_cache[43] || !ds_cache[42])? ds_limit - rd_address_effective : { {16{ds_cache[54]}}, 16'hFFFF } - rd_address_effective;
assign fs_left = (fs_cache[43] || !fs_cache[42])? fs_limit - rd_address_effective : { {16{fs_cache[54]}}, 16'hFFFF } - rd_address_effective;
assign gs_left = (gs_cache[43] || !gs_cache[42])? gs_limit - rd_address_effective : { {16{gs_cache[54]}}, 16'hFFFF } - rd_address_effective;

//------------------------------------------------------------------------------
    
assign seg_select = 
    (address_stack_pop || address_stack_pop_next || address_enter_last || address_enter || address_leave)?  3'd2 :
    (address_edi)?                                                                                          3'd0 :
                                                                                                            rd_prefix_group_2_seg;

assign seg_read  = read_virtual || read_rmw_virtual;
assign seg_write = read_rmw_virtual || write_virtual_check;

assign seg_limit_overflow =
    (seg_select == 3'd0 && (((es_cache[43] || !es_cache[42]) && rd_address_effective > es_limit) || (!es_cache[43] && es_cache[42] && (rd_address_effective <= es_limit || rd_address_effective > { {16{es_cache[54]}}, 16'hFFFF })))) ||
    (seg_select == 3'd1 && (((cs_cache[43] || !cs_cache[42]) && rd_address_effective > cs_limit) || (!cs_cache[43] && cs_cache[42] && (rd_address_effective <= cs_limit || rd_address_effective > { {16{cs_cache[54]}}, 16'hFFFF })))) ||
    (seg_select == 3'd2 && (((ss_cache[43] || !ss_cache[42]) && rd_address_effective > ss_limit) || (!ss_cache[43] && ss_cache[42] && (rd_address_effective <= ss_limit || rd_address_effective > { {16{ss_cache[54]}}, 16'hFFFF })))) ||
    (seg_select == 3'd3 && (((ds_cache[43] || !ds_cache[42]) && rd_address_effective > ds_limit) || (!ds_cache[43] && ds_cache[42] && (rd_address_effective <= ds_limit || rd_address_effective > { {16{ds_cache[54]}}, 16'hFFFF })))) ||
    (seg_select == 3'd4 && (((fs_cache[43] || !fs_cache[42]) && rd_address_effective > fs_limit) || (!fs_cache[43] && fs_cache[42] && (rd_address_effective <= fs_limit || rd_address_effective > { {16{fs_cache[54]}}, 16'hFFFF })))) ||
    (seg_select == 3'd5 && (((gs_cache[43] || !gs_cache[42]) && rd_address_effective > gs_limit) || (!gs_cache[43] && gs_cache[42] && (rd_address_effective <= gs_limit || rd_address_effective > { {16{gs_cache[54]}}, 16'hFFFF }))));

//NOTE: only valid for (not SYSTEM)
assign seg_left =
    (seg_select == 3'd0)?   ((es_left >= 32'd15)? 5'd16 : es_left[3:0] + 4'd1) :
    (seg_select == 3'd1)?   ((cs_left >= 32'd15)? 5'd16 : cs_left[3:0] + 4'd1) :
    (seg_select == 3'd2)?   ((ss_left >= 32'd15)? 5'd16 : ss_left[3:0] + 4'd1) :
    (seg_select == 3'd3)?   ((ds_left >= 32'd15)? 5'd16 : ds_left[3:0] + 4'd1) :
    (seg_select == 3'd4)?   ((fs_left >= 32'd15)? 5'd16 : fs_left[3:0] + 4'd1) :
                            ((gs_left >= 32'd15)? 5'd16 : gs_left[3:0] + 4'd1);    
    
//NOTE: only valid for SEGMENT (not SYSTEM)
// for read: CODE and (not READABLE); for write: DATA and (not WRITABLE)
assign seg_invalid_read_access =
    (seg_select == 3'd0)?   (es_cache[43] && !es_cache[41]) :  
    (seg_select == 3'd1)?   (cs_cache[43] && !cs_cache[41]) :  
    (seg_select == 3'd2)?   (ss_cache[43] && !ss_cache[41]) :  
    (seg_select == 3'd3)?   (ds_cache[43] && !ds_cache[41]) :  
    (seg_select == 3'd4)?   (fs_cache[43] && !fs_cache[41]) :  
                            (gs_cache[43] && !gs_cache[41]);
 
assign seg_invalid_write_access =
    (seg_select == 3'd0)?   (es_cache[43] || !es_cache[41]) :  
    (seg_select == 3'd1)?   (cs_cache[43] || !cs_cache[41]) :  
    (seg_select == 3'd2)?   (ss_cache[43] || !ss_cache[41]) :  
    (seg_select == 3'd3)?   (ds_cache[43] || !ds_cache[41]) :  
    (seg_select == 3'd4)?   (fs_cache[43] || !fs_cache[41]) :  
                            (gs_cache[43] || !gs_cache[41]);
assign seg_valid =
    (seg_select == 3'd0)?   es_cache[`DESC_BIT_P] && es_cache_valid :
    (seg_select == 3'd1)?   cs_cache[`DESC_BIT_P] && cs_cache_valid :
    (seg_select == 3'd2)?   ss_cache[`DESC_BIT_P] && ss_cache_valid :
    (seg_select == 3'd3)?   ds_cache[`DESC_BIT_P] && ds_cache_valid :
    (seg_select == 3'd4)?   fs_cache[`DESC_BIT_P] && fs_cache_valid :
                            gs_cache[`DESC_BIT_P] && gs_cache_valid;    
    
//------------------------------------------------------------------------------    
    
assign seg_fault = 
    (rd_address_effective_ready && (seg_read || seg_write)) &&
    ((seg_invalid_read_access && seg_read) || (seg_invalid_write_access && seg_write) ||
     seg_limit_overflow || (seg_left < { 1'b0, read_length }) || ~(seg_valid));

assign rd_seg_gp_fault_init = seg_select != 3'd2 && seg_fault;
assign rd_seg_ss_fault_init = seg_select == 3'd2 && seg_fault;

//------------------------------------------------------------------------------

assign rd_seg_linear =
    (seg_select == 3'd0)?       es_base + rd_address_effective :
    (seg_select == 3'd1)?       cs_base + rd_address_effective :
    (seg_select == 3'd2)?       ss_base + rd_address_effective :
    (seg_select == 3'd3)?       ds_base + rd_address_effective :
    (seg_select == 3'd4)?       fs_base + rd_address_effective :
                                gs_base + rd_address_effective;

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0,
    es_cache[53:52], es_cache[46:44], es_cache[40],
    cs_cache[53:52], cs_cache[46:44], cs_cache[40],
    ss_cache[53:52], ss_cache[46:44], ss_cache[40],
    ds_cache[53:52], ds_cache[46:44], ds_cache[40],
    fs_cache[53:52], fs_cache[46:44], fs_cache[40],
    gs_cache[53:52], gs_cache[46:44], gs_cache[40],
    tr_cache[54:52], tr_cache[47:40],
    ldtr_cache[54:52], ldtr_cache[47:40],
    1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------
        
endmodule
