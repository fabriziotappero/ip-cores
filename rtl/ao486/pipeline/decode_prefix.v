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

module decode_prefix(
    input               clk,
    input               rst_n,
    
    input       [63:0]  cs_cache,
    input               dec_is_modregrm,
    input       [95:0]  decoder,
    
    input               instr_prefix,
    input               instr_finished,
    
    output              dec_operand_32bit,   
    output              dec_address_32bit,
    
    output reg  [1:0]   dec_prefix_group_1_rep,
    output              dec_prefix_group_1_lock,
    output      [2:0]   dec_prefix_group_2_seg,
    
    output reg          dec_prefix_2byte,
    output      [2:0]   dec_modregrm_len,
    
    output reg  [3:0]   prefix_count,
    output              is_prefix,
    output reg          prefix_group_1_lock
);

//------------------------------------------------------------------------------


reg [2:0]   prefix_group_2;
reg         prefix_group_3;
reg         prefix_group_4;

//------------------------------------------------------------------------------

wire        modregrm_ss_selected;
wire        CRx_DRx_condition;

wire        dec_address_16bit;

//------------------------------------------------------------------------------

/*
group 1:
1: F2H    REPNE/REPNZ prefix (used only with string instructions)
2: F3H    REP prefix (used only with string instructions)

group 1 lock:
1: F0H   LOCK prefix

group 2:
0: 26H    ES segment override prefix
1: 2EH    CS segment override prefix
2: 36H    SS segment override prefix
3: 3EH    DS segment override prefix
4: 64H    FS segment override prefix
5: 65H    GS segment override prefix

group 3:
1: 66H    Operand-size override

group 4:
1: 67H    Address-size override
*/

//------------------------------------------------------------------------------

assign dec_operand_32bit = cs_cache[`DESC_BIT_D_B] ^ prefix_group_3;

assign dec_address_32bit = cs_cache[`DESC_BIT_D_B] ^ prefix_group_4;
assign dec_address_16bit = ~dec_address_32bit;

assign dec_modregrm_len =
    (CRx_DRx_condition)?                                                                                    3'd2 :
    (dec_address_16bit && decoder[15:14] == 2'b00 && decoder[10:8] == 3'b110)?                              3'd4 :
    (dec_address_16bit && decoder[15:14] == 2'b01)?                                                         3'd3 :
    (dec_address_16bit && decoder[15:14] == 2'b10)?                                                         3'd4 :
    (dec_address_16bit)?                                                                                    3'd2 :
    (dec_address_32bit && decoder[15:14] == 2'b00 && decoder[10:8] == 3'b101)?                              3'd6 :
    (dec_address_32bit && decoder[15:14] == 2'b00 && decoder[10:8] == 3'b100 && decoder[18:16] == 3'b101)?  3'd7 :
    (dec_address_32bit && decoder[15:14] == 2'b00 && decoder[10:8] == 3'b100)?                              3'd3 :
    
    (dec_address_32bit && decoder[15:14] == 2'b01 && decoder[10:8] == 3'b100)?                              3'd4 :
    (dec_address_32bit && decoder[15:14] == 2'b01)?                                                         3'd3 :
    
    (dec_address_32bit && decoder[15:14] == 2'b10 && decoder[10:8] == 3'b100)?                              3'd7 :
    (dec_address_32bit && decoder[15:14] == 2'b10)?                                                         3'd6 :
                                                                                                            3'd2;
assign is_prefix = 
    decoder[7:0] == 8'hF2 || decoder[7:0] == 8'hF3 || decoder[7:0] == 8'hF0 || decoder[7:0] == 8'h26 ||
    decoder[7:0] == 8'h2E || decoder[7:0] == 8'h36 || decoder[7:0] == 8'h3E || decoder[7:0] == 8'h64 ||
    decoder[7:0] == 8'h65 || decoder[7:0] == 8'h66 || decoder[7:0] == 8'h67 || decoder[7:0] == 8'h0F;

//------------------------------------------------------------------------------


always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               dec_prefix_group_1_rep <= 2'd0;
    else if(instr_finished)                         dec_prefix_group_1_rep <= 2'd0;
    else if(instr_prefix && decoder[7:0] == 8'hF2)  dec_prefix_group_1_rep <= 2'd1;
    else if(instr_prefix && decoder[7:0] == 8'hF3)  dec_prefix_group_1_rep <= 2'd2;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               prefix_group_1_lock <= 1'd0;
    else if(instr_finished)                         prefix_group_1_lock <= 1'd0;
    else if(instr_prefix && decoder[7:0] == 8'hF0)  prefix_group_1_lock <= 1'd1;
end


always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               prefix_group_2 <= 3'd7;
    else if(instr_finished)                         prefix_group_2 <= 3'd7;
    else if(instr_prefix && decoder[7:0] == 8'h26)  prefix_group_2 <= 3'd0;
    else if(instr_prefix && decoder[7:0] == 8'h2E)  prefix_group_2 <= 3'd1;
    else if(instr_prefix && decoder[7:0] == 8'h36)  prefix_group_2 <= 3'd2;
    else if(instr_prefix && decoder[7:0] == 8'h3E)  prefix_group_2 <= 3'd3;
    else if(instr_prefix && decoder[7:0] == 8'h64)  prefix_group_2 <= 3'd4;
    else if(instr_prefix && decoder[7:0] == 8'h65)  prefix_group_2 <= 3'd5;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               prefix_group_3 <= 1'd0;
    else if(instr_finished)                         prefix_group_3 <= 1'd0;
    else if(instr_prefix && decoder[7:0] == 8'h66)  prefix_group_3 <= 1'd1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               prefix_group_4 <= 1'd0;
    else if(instr_finished)                         prefix_group_4 <= 1'd0;
    else if(instr_prefix && decoder[7:0] == 8'h67)  prefix_group_4 <= 1'd1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               dec_prefix_2byte <= 1'd0;
    else if(instr_finished)                         dec_prefix_2byte <= 1'd0;
    else if(instr_prefix && decoder[7:0] == 8'h0F)  dec_prefix_2byte <= 1'd1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       prefix_count <= 4'd0;
    else if(instr_finished) prefix_count <= 4'd0;
    else if(instr_prefix)   prefix_count <= prefix_count + 4'd1;
end

//------------------------------------------------------------------------------

// XCHG always has LOCK
assign dec_prefix_group_1_lock =
    prefix_group_1_lock ||
    (~(dec_prefix_2byte) && { decoder[7:1], 1'b0 } == 8'h86 && decoder[15:14] != 2'b11);

// mod bits are always 2'b11
assign CRx_DRx_condition = dec_prefix_2byte && { decoder[7:2], 2'b00 } == 8'h20;
    
// modregrm using esp or ebp
assign modregrm_ss_selected = dec_is_modregrm && ~(CRx_DRx_condition) &&
(   (dec_address_32bit && (decoder[15:14] == 2'b01 || decoder[15:14] == 2'b10) &&  decoder[10:8]  == 3'b101) ||
    (dec_address_32bit &&  decoder[15:14] != 2'b11 && decoder[10:8]  == 3'b100 &&  decoder[18:16] == 3'b100) ||
    (dec_address_32bit && (decoder[15:14] == 2'b01 || decoder[15:14] == 2'b10) &&  decoder[10:8]  == 3'b100 && decoder[18:16] == 3'b101) ||
    (dec_address_16bit &&  decoder[15:14] == 2'b00 && decoder[10:9]  == 2'b01) ||
    (dec_address_16bit && (decoder[15:14] == 2'b01 || decoder[15:14] == 2'b10) && (decoder[10:9]  == 2'b01 || decoder[10:8] == 3'b110))
);

assign dec_prefix_group_2_seg =
    (prefix_group_2 == 3'd7 && modregrm_ss_selected)?   3'd2 :
    (prefix_group_2 == 3'd7)?                           3'd3 :
                                                        prefix_group_2;
    
//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, cs_cache[63:55], cs_cache[53:0], decoder[95:19], decoder[13:11], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
