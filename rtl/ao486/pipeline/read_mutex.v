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

module read_mutex(
    input           rd_req_memory,
    input           rd_req_eflags,
    
    input           rd_req_all,
    input           rd_req_reg,
    input           rd_req_rm,
    input           rd_req_implicit_reg,
    input           rd_req_reg_not_8bit,
    input           rd_req_edi,
    input           rd_req_esi,
    input           rd_req_ebp,
    input           rd_req_esp,
    input           rd_req_ebx,
    input           rd_req_edx_eax,
    input           rd_req_edx,
    input           rd_req_ecx,
    input           rd_req_eax,
    
    input   [87:0]  rd_decoder,
    input           rd_is_8bit,
    input   [1:0]   rd_modregrm_mod,
    input   [2:0]   rd_modregrm_reg,
    input   [2:0]   rd_modregrm_rm,
    input           rd_address_16bit,
    input           rd_address_32bit,
    input   [7:0]   rd_sib,
    
    input   [10:0]  exe_mutex,
    input   [10:0]  wr_mutex,
    
    input           address_bits_transform,
    input           address_xlat_transform,
    input           address_stack_pop,
    input           address_stack_pop_next,
    input           address_enter,
    input           address_enter_last,
    input           address_leave,
    input           address_esi,
    input           address_edi,
    
    output  [10:0]  rd_mutex_next,
    
    output          rd_mutex_busy_active,
    output          rd_mutex_busy_memory,
    output          rd_mutex_busy_eflags,
    output          rd_mutex_busy_ebp,
    output          rd_mutex_busy_esp,
    output          rd_mutex_busy_edx,
    output          rd_mutex_busy_ecx,
    output          rd_mutex_busy_eax,
    output          rd_mutex_busy_modregrm_reg,
    output          rd_mutex_busy_modregrm_rm,
    output          rd_mutex_busy_implicit_reg,
    
    output          rd_address_waiting
);

//------------------------------------------------------------------------------

wire [10:0] rd_mutex_current;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

assign rd_mutex_next = {
    `TRUE, // active bit
    rd_req_memory,
    rd_req_eflags,
    
    (rd_req_reg & (rd_modregrm_reg == 3'd7 & ~(rd_is_8bit))) |
    (rd_req_rm  & (rd_modregrm_rm  == 3'd7 & ~(rd_is_8bit))) |
    (rd_req_implicit_reg & rd_decoder[2:0] == 3'd7 & ~(rd_is_8bit)) | rd_req_all | rd_req_edi |
    (rd_req_reg_not_8bit && rd_modregrm_reg == 3'd7),
    
    (rd_req_reg & (rd_modregrm_reg == 3'd6 & ~(rd_is_8bit))) |
    (rd_req_rm  & (rd_modregrm_rm  == 3'd6 & ~(rd_is_8bit))) |
    (rd_req_implicit_reg & rd_decoder[2:0] == 3'd6 & ~(rd_is_8bit)) | rd_req_all | rd_req_esi |
    (rd_req_reg_not_8bit && rd_modregrm_reg == 3'd6),
    
    (rd_req_reg & (rd_modregrm_reg == 3'd5 & ~(rd_is_8bit))) |
    (rd_req_rm  & (rd_modregrm_rm  == 3'd5 & ~(rd_is_8bit))) |
    (rd_req_implicit_reg & rd_decoder[2:0] == 3'd5 & ~(rd_is_8bit)) | rd_req_all | rd_req_ebp |
    (rd_req_reg_not_8bit && rd_modregrm_reg == 3'd5),
    
    (rd_req_reg & (rd_modregrm_reg == 3'd4 & ~(rd_is_8bit))) |
    (rd_req_rm  & (rd_modregrm_rm  == 3'd4 & ~(rd_is_8bit))) |
    (rd_req_implicit_reg & rd_decoder[2:0] == 3'd4 & ~(rd_is_8bit)) | rd_req_esp | rd_req_all |
    (rd_req_reg_not_8bit && rd_modregrm_reg == 3'd4),
    
    (rd_req_reg & (rd_modregrm_reg == 3'd3 | (rd_modregrm_reg == 3'd7 & rd_is_8bit))) |
    (rd_req_rm  & (rd_modregrm_rm  == 3'd3 | (rd_modregrm_rm  == 3'd7 & rd_is_8bit))) |
    (rd_req_implicit_reg & (rd_decoder[2:0] == 3'd3 | (rd_decoder[2:0] == 3'd7 & rd_is_8bit))) | rd_req_ebx | rd_req_all |
    (rd_req_reg_not_8bit && rd_modregrm_reg == 3'd3),
    
    (rd_req_reg & (rd_modregrm_reg == 3'd2 | (rd_modregrm_reg == 3'd6 & rd_is_8bit))) |
    (rd_req_rm  & (rd_modregrm_rm  == 3'd2 | (rd_modregrm_rm  == 3'd6 & rd_is_8bit))) | rd_req_edx | rd_req_edx_eax |
    (rd_req_implicit_reg & (rd_decoder[2:0] == 3'd2 | (rd_decoder[2:0] == 3'd6 & rd_is_8bit))) | rd_req_all |
    (rd_req_reg_not_8bit && rd_modregrm_reg == 3'd2),
    
    (rd_req_reg & (rd_modregrm_reg == 3'd1 | (rd_modregrm_reg == 3'd5 & rd_is_8bit))) |
    (rd_req_rm  & (rd_modregrm_rm  == 3'd1 | (rd_modregrm_rm  == 3'd5 & rd_is_8bit))) |
    (rd_req_implicit_reg & (rd_decoder[2:0] == 3'd1 | (rd_decoder[2:0] == 3'd5 & rd_is_8bit))) | rd_req_ecx | rd_req_all |
    (rd_req_reg_not_8bit && rd_modregrm_reg == 3'd1),
    
    (rd_req_reg & (rd_modregrm_reg == 3'd0 | (rd_modregrm_reg == 3'd4 & rd_is_8bit))) |
    (rd_req_rm  & (rd_modregrm_rm  == 3'd0 | (rd_modregrm_rm  == 3'd4 & rd_is_8bit))) | rd_req_eax | rd_req_edx_eax |
    (rd_req_implicit_reg & (rd_decoder[2:0] == 3'd0 | (rd_decoder[2:0] == 3'd4 & rd_is_8bit)))  | rd_req_all |
    (rd_req_reg_not_8bit && rd_modregrm_reg == 3'd0)
};

assign rd_mutex_current      = exe_mutex | wr_mutex;

assign rd_mutex_busy_active   = rd_mutex_current[`MUTEX_ACTIVE_BIT];
assign rd_mutex_busy_memory   = rd_mutex_current[9];
assign rd_mutex_busy_eflags   = rd_mutex_current[8];
assign rd_mutex_busy_ebp      = rd_mutex_current[5];
assign rd_mutex_busy_esp      = rd_mutex_current[4];
assign rd_mutex_busy_edx      = rd_mutex_current[2];
assign rd_mutex_busy_ecx      = rd_mutex_current[1];
assign rd_mutex_busy_eax      = rd_mutex_current[0];

assign rd_mutex_busy_modregrm_reg =
    (rd_modregrm_reg == 3'd0 & rd_mutex_current[0]) ||
    (rd_modregrm_reg == 3'd1 & rd_mutex_current[1]) ||
    (rd_modregrm_reg == 3'd2 & rd_mutex_current[2]) ||
    (rd_modregrm_reg == 3'd3 & rd_mutex_current[3]) ||
    (rd_modregrm_reg == 3'd4 & rd_mutex_current[4] & ~(rd_is_8bit)) ||
    (rd_modregrm_reg == 3'd5 & rd_mutex_current[5] & ~(rd_is_8bit)) ||
    (rd_modregrm_reg == 3'd6 & rd_mutex_current[6] & ~(rd_is_8bit)) ||
    (rd_modregrm_reg == 3'd7 & rd_mutex_current[7] & ~(rd_is_8bit)) ||
    (rd_modregrm_reg == 3'd4 & rd_mutex_current[0] & rd_is_8bit) ||
    (rd_modregrm_reg == 3'd5 & rd_mutex_current[1] & rd_is_8bit) ||
    (rd_modregrm_reg == 3'd6 & rd_mutex_current[2] & rd_is_8bit) ||
    (rd_modregrm_reg == 3'd7 & rd_mutex_current[3] & rd_is_8bit);
    
assign rd_mutex_busy_modregrm_rm = 
    (rd_modregrm_rm == 3'd0 & rd_mutex_current[0]) ||
    (rd_modregrm_rm == 3'd1 & rd_mutex_current[1]) ||
    (rd_modregrm_rm == 3'd2 & rd_mutex_current[2]) ||
    (rd_modregrm_rm == 3'd3 & rd_mutex_current[3]) ||
    (rd_modregrm_rm == 3'd4 & rd_mutex_current[4] & ~(rd_is_8bit)) ||
    (rd_modregrm_rm == 3'd5 & rd_mutex_current[5] & ~(rd_is_8bit)) ||
    (rd_modregrm_rm == 3'd6 & rd_mutex_current[6] & ~(rd_is_8bit)) ||
    (rd_modregrm_rm == 3'd7 & rd_mutex_current[7] & ~(rd_is_8bit)) ||
    (rd_modregrm_rm == 3'd4 & rd_mutex_current[0] & rd_is_8bit) ||
    (rd_modregrm_rm == 3'd5 & rd_mutex_current[1] & rd_is_8bit) ||
    (rd_modregrm_rm == 3'd6 & rd_mutex_current[2] & rd_is_8bit) ||
    (rd_modregrm_rm == 3'd7 & rd_mutex_current[3] & rd_is_8bit);
    
assign rd_mutex_busy_implicit_reg =
    (rd_decoder[2:0] == 3'd0 && rd_mutex_current[0]) ||
    (rd_decoder[2:0] == 3'd1 && rd_mutex_current[1]) ||
    (rd_decoder[2:0] == 3'd2 && rd_mutex_current[2]) ||
    (rd_decoder[2:0] == 3'd3 && rd_mutex_current[3]) ||
    (rd_decoder[2:0] == 3'd4 && rd_mutex_current[4]) ||
    (rd_decoder[2:0] == 3'd5 && rd_mutex_current[5]) ||
    (rd_decoder[2:0] == 3'd6 && rd_mutex_current[6]) ||
    (rd_decoder[2:0] == 3'd7 && rd_mutex_current[7]);

//------------------------------------------------------------------------------ Address mutex
wire address_waiting_16bit;
wire address_waiting_32bit_sib;
wire address_waiting_32bit;
wire address_waiting_bits_transform;
    
assign address_waiting_16bit =
    (rd_modregrm_rm == 3'b000 && (rd_mutex_current[`MUTEX_EBX_BIT] || rd_mutex_current[`MUTEX_ESI_BIT])) ||
    (rd_modregrm_rm == 3'b001 && (rd_mutex_current[`MUTEX_EBX_BIT] || rd_mutex_current[`MUTEX_EDI_BIT])) ||
    (rd_modregrm_rm == 3'b010 && (rd_mutex_current[`MUTEX_EBP_BIT] || rd_mutex_current[`MUTEX_ESI_BIT])) ||
    (rd_modregrm_rm == 3'b011 && (rd_mutex_current[`MUTEX_EBP_BIT] || rd_mutex_current[`MUTEX_EDI_BIT])) ||
    (rd_modregrm_rm == 3'b100 && (rd_mutex_current[`MUTEX_ESI_BIT])) ||
    (rd_modregrm_rm == 3'b101 && (rd_mutex_current[`MUTEX_EDI_BIT])) ||
    (rd_modregrm_rm == 3'b110 && (rd_mutex_current[`MUTEX_EBP_BIT])) ||
    (rd_modregrm_rm == 3'b111 && (rd_mutex_current[`MUTEX_EBX_BIT]));

assign address_waiting_32bit_sib =
    ((rd_sib[5:3] == 3'b000 || rd_sib[2:0] == 3'b000) && rd_mutex_current[`MUTEX_EAX_BIT]) ||
    ((rd_sib[5:3] == 3'b001 || rd_sib[2:0] == 3'b001) && rd_mutex_current[`MUTEX_ECX_BIT]) ||
    ((rd_sib[5:3] == 3'b010 || rd_sib[2:0] == 3'b010) && rd_mutex_current[`MUTEX_EDX_BIT]) ||
    ((rd_sib[5:3] == 3'b011 || rd_sib[2:0] == 3'b011) && rd_mutex_current[`MUTEX_EBX_BIT]) ||
    (rd_sib[2:0] == 3'b100 && rd_mutex_current[`MUTEX_ESP_BIT]) ||
    ((rd_sib[5:3] == 3'b101 || (rd_sib[2:0] == 3'b101 && rd_modregrm_mod != 2'b00)) && rd_mutex_current[`MUTEX_EBP_BIT]) ||
    ((rd_sib[5:3] == 3'b110 || rd_sib[2:0] == 3'b110) && rd_mutex_current[`MUTEX_ESI_BIT]) ||
    ((rd_sib[5:3] == 3'b111 || rd_sib[2:0] == 3'b111) && rd_mutex_current[`MUTEX_EDI_BIT]);
    
assign address_waiting_32bit =
    (rd_modregrm_rm == 3'b000 && rd_mutex_current[`MUTEX_EAX_BIT]) ||
    (rd_modregrm_rm == 3'b001 && rd_mutex_current[`MUTEX_ECX_BIT]) ||
    (rd_modregrm_rm == 3'b010 && rd_mutex_current[`MUTEX_EDX_BIT]) ||
    (rd_modregrm_rm == 3'b011 && rd_mutex_current[`MUTEX_EBX_BIT]) ||
    (rd_modregrm_rm == 3'b100 && address_waiting_32bit_sib) ||
    (rd_modregrm_rm == 3'b101 && rd_mutex_current[`MUTEX_EBP_BIT]) ||
    (rd_modregrm_rm == 3'b110 && rd_mutex_current[`MUTEX_ESI_BIT]) ||
    (rd_modregrm_rm == 3'b111 && rd_mutex_current[`MUTEX_EDI_BIT]);

assign address_waiting_bits_transform =
    (rd_modregrm_reg == 3'b000 && rd_mutex_current[`MUTEX_EAX_BIT]) ||
    (rd_modregrm_reg == 3'b001 && rd_mutex_current[`MUTEX_ECX_BIT]) ||
    (rd_modregrm_reg == 3'b010 && rd_mutex_current[`MUTEX_EDX_BIT]) ||
    (rd_modregrm_reg == 3'b011 && rd_mutex_current[`MUTEX_EBX_BIT]) ||
    (rd_modregrm_reg == 3'b100 && rd_mutex_current[`MUTEX_ESP_BIT]) ||
    (rd_modregrm_reg == 3'b101 && rd_mutex_current[`MUTEX_EBP_BIT]) ||
    (rd_modregrm_reg == 3'b110 && rd_mutex_current[`MUTEX_ESI_BIT]) ||
    (rd_modregrm_reg == 3'b111 && rd_mutex_current[`MUTEX_EDI_BIT]);
    
assign rd_address_waiting = 
    (address_bits_transform && address_waiting_bits_transform) ||
    (address_xlat_transform && (rd_mutex_current[`MUTEX_EAX_BIT] || rd_mutex_current[`MUTEX_EBX_BIT])) ||
    (address_stack_pop      && rd_mutex_current[`MUTEX_ESP_BIT]) ||
    (address_stack_pop_next && rd_mutex_current[`MUTEX_ESP_BIT]) ||
    (address_enter_last     && rd_mutex_current[`MUTEX_ESP_BIT]) ||
    (address_enter          && rd_mutex_current[`MUTEX_EBP_BIT]) ||
    (address_leave          && rd_mutex_current[`MUTEX_EBP_BIT]) ||
    (address_esi            && rd_mutex_current[`MUTEX_ESI_BIT]) ||
    (address_edi            && rd_mutex_current[`MUTEX_EDI_BIT]) ||
    (rd_address_16bit       && ~(rd_modregrm_mod == 2'b00 && rd_modregrm_rm == 3'b110) && address_waiting_16bit ) ||
    (rd_address_32bit       && ~(rd_modregrm_mod == 2'b00 && rd_modregrm_rm == 3'b101) && address_waiting_32bit );

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, rd_decoder[87:3], rd_sib[7:6], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
