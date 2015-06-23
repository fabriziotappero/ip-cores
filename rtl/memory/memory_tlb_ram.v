/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module memory_tlb_ram(
    input               clk,
    input               rst_n,

    //
    input               tlb_ram_read_do,
    input       [5:0]   tlb_ram_read_index,
    output reg          tlb_ram_read_result_ready,
    output      [49:0]  tlb_ram_read_result,
    
    //
    input               tlb_ram_write_do,
    input       [5:0]   tlb_ram_write_index,
    input       [49:0]  tlb_ram_write_value,
    
    //
    input       [5:0]   entryhi_asid,
    
    //
    input               tlb_ram_data_start,
    input       [19:0]  tlb_ram_data_vpn,
    output reg          tlb_ram_data_hit,
    output reg  [5:0]   tlb_ram_data_index,
    output reg  [49:0]  tlb_ram_data_result,
    output              tlb_ram_data_missed,
    
    //
    input               tlb_ram_fetch_start,
    input       [19:0]  tlb_ram_fetch_vpn,
    output reg          tlb_ram_fetch_hit,
    output reg  [49:0]  tlb_ram_fetch_result,
    output              tlb_ram_fetch_missed
); /* verilator public_module */

//------------------------------------------------------------------------------

/*
[19:0]  vpn
[39:20] pfn
[45:40] asid
[46]    n noncachable
[47]    d dirty = write-enable
[48]    v valid
[49]    g global
*/

//------------------------------------------------------------------------------

reg invalid_ram_q;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   invalid_ram_q <= `FALSE;
    else                invalid_ram_q <= tlb_ram_read_do || tlb_ram_write_do;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   tlb_ram_read_result_ready <= `FALSE;
    else                tlb_ram_read_result_ready <= tlb_ram_read_do;
end

//------------------------------------------------------------------------------

reg [2:0] index;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   index <= 3'd0;
    else                index <= index_next;
end

wire [2:0] index_next = (tlb_ram_read_do || tlb_ram_write_do)? index : index + 3'd1;

wire [2:0] read_index = (tlb_ram_read_do)? tlb_ram_read_index[5:3] : index_next;

//------------------------------------------------------------------------------

wire [49:0] tlb0_q_a;
wire [49:0] tlb0_q_b;
wire [49:0] tlb1_q_a;
wire [49:0] tlb1_q_b;
wire [49:0] tlb2_q_a;
wire [49:0] tlb2_q_b;
wire [49:0] tlb3_q_a;
wire [49:0] tlb3_q_b;

reg [2:0] read_index_part;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   read_index_part <= 3'd0;
    else                read_index_part <= tlb_ram_read_index[2:0];
end

assign tlb_ram_read_result =
    (read_index_part == 3'd0)?  tlb0_q_a[49:0] :
    (read_index_part == 3'd1)?  tlb0_q_b[49:0] :
    (read_index_part == 3'd2)?  tlb1_q_a[49:0] :
    (read_index_part == 3'd3)?  tlb1_q_b[49:0] :
    (read_index_part == 3'd4)?  tlb2_q_a[49:0] :
    (read_index_part == 3'd5)?  tlb2_q_b[49:0] :
    (read_index_part == 3'd6)?  tlb3_q_a[49:0] :
                                tlb3_q_b[49:0];

//------------------------------------------------------------------------------

wire match_data0 = tlb_ram_data_vpn == tlb0_q_a[19:0] && (tlb0_q_a[49] || entryhi_asid == tlb0_q_a[45:40]);
wire match_data1 = tlb_ram_data_vpn == tlb0_q_b[19:0] && (tlb0_q_b[49] || entryhi_asid == tlb0_q_b[45:40]);
wire match_data2 = tlb_ram_data_vpn == tlb1_q_a[19:0] && (tlb1_q_a[49] || entryhi_asid == tlb1_q_a[45:40]);
wire match_data3 = tlb_ram_data_vpn == tlb1_q_b[19:0] && (tlb1_q_b[49] || entryhi_asid == tlb1_q_b[45:40]);
wire match_data4 = tlb_ram_data_vpn == tlb2_q_a[19:0] && (tlb2_q_a[49] || entryhi_asid == tlb2_q_a[45:40]);
wire match_data5 = tlb_ram_data_vpn == tlb2_q_b[19:0] && (tlb2_q_b[49] || entryhi_asid == tlb2_q_b[45:40]);
wire match_data6 = tlb_ram_data_vpn == tlb3_q_a[19:0] && (tlb3_q_a[49] || entryhi_asid == tlb3_q_a[45:40]);
wire match_data7 = tlb_ram_data_vpn == tlb3_q_b[19:0] && (tlb3_q_b[49] || entryhi_asid == tlb3_q_b[45:40]);

wire match_fetch0 = tlb_ram_fetch_vpn == tlb0_q_a[19:0] && (tlb0_q_a[49] || entryhi_asid == tlb0_q_a[45:40]);
wire match_fetch1 = tlb_ram_fetch_vpn == tlb0_q_b[19:0] && (tlb0_q_b[49] || entryhi_asid == tlb0_q_b[45:40]);
wire match_fetch2 = tlb_ram_fetch_vpn == tlb1_q_a[19:0] && (tlb1_q_a[49] || entryhi_asid == tlb1_q_a[45:40]);
wire match_fetch3 = tlb_ram_fetch_vpn == tlb1_q_b[19:0] && (tlb1_q_b[49] || entryhi_asid == tlb1_q_b[45:40]);
wire match_fetch4 = tlb_ram_fetch_vpn == tlb2_q_a[19:0] && (tlb2_q_a[49] || entryhi_asid == tlb2_q_a[45:40]);
wire match_fetch5 = tlb_ram_fetch_vpn == tlb2_q_b[19:0] && (tlb2_q_b[49] || entryhi_asid == tlb2_q_b[45:40]);
wire match_fetch6 = tlb_ram_fetch_vpn == tlb3_q_a[19:0] && (tlb3_q_a[49] || entryhi_asid == tlb3_q_a[45:40]);
wire match_fetch7 = tlb_ram_fetch_vpn == tlb3_q_b[19:0] && (tlb3_q_b[49] || entryhi_asid == tlb3_q_b[45:40]);

wire tlb_ram_data_hit_next  = (data_cnt > 4'd0)                      && (match_data0  || match_data1  || match_data2  || match_data3  || match_data4  || match_data5  || match_data6  || match_data7);
wire tlb_ram_fetch_hit_next = (fetch_cnt > 4'd0 && ~(invalid_ram_q)) && (match_fetch0 || match_fetch1 || match_fetch2 || match_fetch3 || match_fetch4 || match_fetch5 || match_fetch6 || match_fetch7);

wire [5:0] tlb_ram_data_index_next =
    (match_data0)?   { index, 3'd0 } :
    (match_data1)?   { index, 3'd1 } :
    (match_data2)?   { index, 3'd2 } :
    (match_data3)?   { index, 3'd3 } :
    (match_data4)?   { index, 3'd4 } :
    (match_data5)?   { index, 3'd5 } :
    (match_data6)?   { index, 3'd6 } :
                     { index, 3'd7 };

wire [49:0] tlb_ram_data_result_next =
    (match_data0)?   tlb0_q_a :
    (match_data1)?   tlb0_q_b :
    (match_data2)?   tlb1_q_a :
    (match_data3)?   tlb1_q_b :
    (match_data4)?   tlb2_q_a :
    (match_data5)?   tlb2_q_b :
    (match_data6)?   tlb3_q_a :
                     tlb3_q_b;

wire [49:0] tlb_ram_fetch_result_next =
    (match_fetch0)? tlb0_q_a :
    (match_fetch1)? tlb0_q_b :
    (match_fetch2)? tlb1_q_a :
    (match_fetch3)? tlb1_q_b :
    (match_fetch4)? tlb2_q_a :
    (match_fetch5)? tlb2_q_b :
    (match_fetch6)? tlb3_q_a :
                    tlb3_q_b;

always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb_ram_data_hit     <= `FALSE; else tlb_ram_data_hit     <= tlb_ram_data_hit_next;     end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb_ram_fetch_hit    <= `FALSE; else tlb_ram_fetch_hit    <= tlb_ram_fetch_hit_next;    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb_ram_data_index   <= 6'd0;   else tlb_ram_data_index   <= tlb_ram_data_index_next;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb_ram_data_result  <= 50'd0;  else tlb_ram_data_result  <= tlb_ram_data_result_next;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) tlb_ram_fetch_result <= 50'd0;  else tlb_ram_fetch_result <= tlb_ram_fetch_result_next; end

//------------------------------------------------------------------------------

reg [3:0] data_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               data_cnt <= 4'd0;
    else if(tlb_ram_data_start)     data_cnt <= 4'd1;
    else if(tlb_ram_data_hit)       data_cnt <= 4'd0;
    else if(data_cnt == 4'd9)       data_cnt <= 4'd0;
    else if(data_cnt > 4'd0)        data_cnt <= data_cnt + 4'd1;
end
assign tlb_ram_data_missed = data_cnt == 4'd9 && ~(tlb_ram_data_hit);

//------------------------------------------------------------------------------

reg [3:0] fetch_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               fetch_cnt <= 4'd0;
    else if(tlb_ram_fetch_start)                    fetch_cnt <= 4'd1;
    else if(tlb_ram_fetch_hit)                      fetch_cnt <= 4'd0;
    else if(fetch_cnt == 4'd9)                      fetch_cnt <= 4'd0;
    else if(fetch_cnt > 4'd0 && ~(invalid_ram_q))   fetch_cnt <= fetch_cnt + 4'd1;
end
assign tlb_ram_fetch_missed = fetch_cnt == 4'd9 && ~(tlb_ram_fetch_hit);

//------------------------------------------------------------------------------

model_true_dual_ram #(
    .width          (50),
    .widthad        (4)
)
tlb0_inst(
    .clk            (clk),
    
    .address_a      (tlb_ram_write_do? { 1'b0, tlb_ram_write_index[5:3] } : { 1'b0, read_index }),
    .wren_a         (tlb_ram_write_do && tlb_ram_write_index[2:0] == 3'd0),
    .data_a         (tlb_ram_write_value),
    .q_a            (tlb0_q_a),
    
    .address_b      (tlb_ram_write_do? { 1'b1, tlb_ram_write_index[5:3] } : { 1'b1, read_index }),
    .wren_b         (tlb_ram_write_do && tlb_ram_write_index[2:0] == 3'd1),
    .data_b         (tlb_ram_write_value),
    .q_b            (tlb0_q_b)
);

model_true_dual_ram #(
    .width          (50),
    .widthad        (4)
)
tlb1_inst(
    .clk            (clk),
    
    .address_a      (tlb_ram_write_do? { 1'b0, tlb_ram_write_index[5:3] } : { 1'b0, read_index }),
    .wren_a         (tlb_ram_write_do && tlb_ram_write_index[2:0] == 3'd2),
    .data_a         (tlb_ram_write_value),
    .q_a            (tlb1_q_a),
    
    .address_b      (tlb_ram_write_do? { 1'b1, tlb_ram_write_index[5:3] } : { 1'b1, read_index }),
    .wren_b         (tlb_ram_write_do && tlb_ram_write_index[2:0] == 3'd3),
    .data_b         (tlb_ram_write_value),
    .q_b            (tlb1_q_b)
);

model_true_dual_ram #(
    .width          (50),
    .widthad        (4)
)
tlb2_inst(
    .clk            (clk),
    
    .address_a      (tlb_ram_write_do? { 1'b0, tlb_ram_write_index[5:3] } : { 1'b0, read_index }),
    .wren_a         (tlb_ram_write_do && tlb_ram_write_index[2:0] == 3'd4),
    .data_a         (tlb_ram_write_value),
    .q_a            (tlb2_q_a),
    
    .address_b      (tlb_ram_write_do? { 1'b1, tlb_ram_write_index[5:3] } : { 1'b1, read_index }),
    .wren_b         (tlb_ram_write_do && tlb_ram_write_index[2:0] == 3'd5),
    .data_b         (tlb_ram_write_value),
    .q_b            (tlb2_q_b)
);

model_true_dual_ram #(
    .width          (50),
    .widthad        (4)
)
tlb3_inst(
    .clk            (clk),
    
    .address_a      (tlb_ram_write_do? { 1'b0, tlb_ram_write_index[5:3] } : { 1'b0, read_index }),
    .wren_a         (tlb_ram_write_do && tlb_ram_write_index[2:0] == 3'd6),
    .data_a         (tlb_ram_write_value),
    .q_a            (tlb3_q_a),
    
    .address_b      (tlb_ram_write_do? { 1'b1, tlb_ram_write_index[5:3] } : { 1'b1, read_index }),
    .wren_b         (tlb_ram_write_do && tlb_ram_write_index[2:0] == 3'd7),
    .data_b         (tlb_ram_write_value),
    .q_b            (tlb3_q_b)
);

//------------------------------------------------------------------------------

endmodule
