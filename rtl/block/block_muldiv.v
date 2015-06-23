/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module block_muldiv(
    input               clk,
    input               rst_n,

    input       [6:0]   exe_cmd_for_muldiv,
    input       [31:0]  exe_a,
    input       [31:0]  exe_b,
    input       [4:0]   exe_instr_rd,
    
    output              muldiv_busy,
    
    output      [4:0]   muldiv_result_index,
    output      [31:0]  muldiv_result
); /* verilator public_module */

//------------------------------------------------------------------------------ lo, hi, busy

reg [31:0] hi;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               hi <= 32'd0;
    else if(exe_cmd_for_muldiv == `CMD_muldiv_mthi) hi <= exe_a;
    else if(mult_ready)                             hi <= mult_result[63:32];
    else if(div_ready && div_busy)                  hi <= div_remainder;
end

reg [31:0] lo;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               lo <= 32'd0;
    else if(exe_cmd_for_muldiv == `CMD_muldiv_mtlo) lo <= exe_a;
    else if(mult_ready)                             lo <= mult_result[31:0];
    else if(div_ready && div_busy)                  lo <= div_quotient;
end

reg busy;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                   busy <= `FALSE;
    else if(exe_cmd_for_muldiv == `CMD_muldiv_mfhi || exe_cmd_for_muldiv == `CMD_muldiv_mflo || busy)   busy <= mult_busy || div_busy;                                       
end

wire muldiv_busy_start = ((exe_cmd_for_muldiv == `CMD_muldiv_mfhi || exe_cmd_for_muldiv == `CMD_muldiv_mflo) && (mult_busy || div_busy));

assign muldiv_busy = muldiv_busy_start || busy;

reg [4:0] muldiv_index_value;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       muldiv_index_value <= 5'd0;
    else if(muldiv_busy_start)              muldiv_index_value <= exe_instr_rd;
    else if(~(mult_busy) && ~(div_busy))    muldiv_index_value <= 5'd0;
end

reg muldiv_index_type_is_lo;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                           muldiv_index_type_is_lo <= `FALSE;
    else if(exe_cmd_for_muldiv == `CMD_muldiv_mfhi || exe_cmd_for_muldiv == `CMD_muldiv_mflo)   muldiv_index_type_is_lo <= exe_cmd_for_muldiv == `CMD_muldiv_mflo;
end

assign muldiv_result_index =
    (muldiv_busy && (~(busy) || mult_busy || div_busy))?                                    5'd0 :
    (exe_cmd_for_muldiv == `CMD_muldiv_mfhi || exe_cmd_for_muldiv == `CMD_muldiv_mflo)?     exe_instr_rd :
                                                                                            muldiv_index_value;
assign muldiv_result =
    (exe_cmd_for_muldiv == `CMD_muldiv_mfhi)?   hi :
    (exe_cmd_for_muldiv == `CMD_muldiv_mflo)?   lo :
    (muldiv_index_type_is_lo)?                  lo :
                                                hi;

//------------------------------------------------------------------------------ multiply

wire mult_busy = mult_counter > 2'd0;
wire mult_ready= mult_counter == 2'd1;

reg [1:0] mult_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                           mult_counter <= 2'd0;
    else if(exe_cmd_for_muldiv == `CMD_muldiv_mult || exe_cmd_for_muldiv == `CMD_muldiv_multu)  mult_counter <= 2'd2;
    else if(mult_counter != 2'd0)                                                               mult_counter <= mult_counter - 2'd1;
end

wire [65:0] mult_result;

model_mult
#(
    .widtha     (33),
    .widthb     (33),
    .widthp     (66)
)
model_mult_inst(
    .clk        (clk),
    .a          ((exe_cmd_for_muldiv == `CMD_muldiv_mult)? { exe_a[31], exe_a[31:0] } : { 1'b0, exe_a[31:0] }),
    .b          ((exe_cmd_for_muldiv == `CMD_muldiv_mult)? { exe_b[31], exe_b[31:0] } : { 1'b0, exe_b[31:0] }),
    .out        (mult_result)
);

//------------------------------------------------------------------------------ divide

reg div_busy;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                       div_busy <= `FALSE;
    else if(exe_cmd_for_muldiv ==`CMD_muldiv_div || exe_cmd_for_muldiv == `CMD_muldiv_divu) div_busy <= `TRUE;
    else if(div_ready)                                                                      div_busy <= `FALSE;
end

wire        div_ready;
wire [31:0] div_quotient;
wire [31:0] div_remainder;
        
block_long_div block_long_div_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .start      (exe_cmd_for_muldiv == `CMD_muldiv_div || exe_cmd_for_muldiv == `CMD_muldiv_divu),  //input
    .dividend   ({ exe_cmd_for_muldiv == `CMD_muldiv_div & exe_a[31], exe_a[31:0] }),               //input [32:0]
    .divisor    ({ exe_cmd_for_muldiv == `CMD_muldiv_div & exe_b[31], exe_b[31:0] }),               //input [32:0]
    
    .ready      (div_ready),                                                    //output
    .quotient   (div_quotient),                                                 //output [31:0]
    .remainder  (div_remainder)                                                 //output [31:0]
);

//------------------------------------------------------------------------------
// synthesis translate_off
wire _unused_ok = &{ 1'b0, mult_result[65:64],  1'b0 };
// synthesis translate_on
//------------------------------------------------------------------------------


endmodule
