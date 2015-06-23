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

module decode(
    input               clk,
    input               rst_n,
    
    input               dec_reset,
    
    //global input
    input       [63:0]  cs_cache,
    
    input               protected_mode,
    
    //eip
    input               pr_reset,
    input       [31:0]  prefetch_eip,
    output reg  [31:0]  eip,
    
    //fetch interface
    input       [3:0]   fetch_valid,
    input       [63:0]  fetch,
    input               fetch_limit,
    input               fetch_page_fault,
    
    output      [3:0]   dec_acceptable,
    
    //exceptions
    output reg          dec_gp_fault,
    output reg          dec_ud_fault,
    output reg          dec_pf_fault,
    
    //pipeline
    input               micro_busy,
    output              dec_ready,
    
    output      [95:0]  decoder,
    output      [31:0]  dec_eip,
    output              dec_operand_32bit,
    output              dec_address_32bit,
    output      [1:0]   dec_prefix_group_1_rep,
    output              dec_prefix_group_1_lock,
    output      [2:0]   dec_prefix_group_2_seg,
    output              dec_prefix_2byte,
    output      [3:0]   dec_consumed,
    output      [2:0]   dec_modregrm_len,  
    output              dec_is_8bit,
    output      [6:0]   dec_cmd,
    output      [3:0]   dec_cmdex,
    output              dec_is_complex
);

//------------------------------------------------------------------------------

wire        enable;
wire        instr_prefix;
wire        instr_finished;
wire        stop;

wire [3:0]  consume_count;

wire        gp_fault;
wire        pf_fault;

wire        is_prefix;
wire [3:0]  decoder_count;

wire consume_one;
wire consume_one_one;
wire consume_one_two;
wire consume_one_three;
wire consume_call_jmp_imm;
wire consume_modregrm_one;
wire consume_one_imm;
wire consume_modregrm_imm;
wire consume_mem_offset;

//------------------------------------------------------------------------------

reg gp_fault_last;
reg pf_fault_last;

//------------------------------------------------------------------------------

wire        dec_ready_one;
wire        dec_ready_one_one;
wire        dec_ready_one_two;
wire        dec_ready_one_three;
wire        dec_ready_2byte_one;
wire        dec_ready_modregrm_one;
wire        dec_ready_2byte_modregrm;
wire        dec_ready_call_jmp_imm;
wire        dec_ready_one_imm;
wire        dec_ready_2byte_imm;
wire        dec_ready_mem_offset;
wire        dec_ready_modregrm_imm;
wire        dec_ready_2byte_modregrm_imm;

wire [3:0]  consume_count_local;

wire        dec_is_modregrm;

decode_ready decode_ready_inst(
    
    .enable                         (enable),                       //input
    .is_prefix                      (is_prefix),                    //input
    .decoder_count                  (decoder_count),                //input [3:0]
    
    .decoder                        (decoder),                      //input [95:0]
    
    .dec_operand_32bit              (dec_operand_32bit),            //input
    .dec_address_32bit              (dec_address_32bit),            //input
    
    .dec_prefix_2byte               (dec_prefix_2byte),             //input
    .dec_modregrm_len               (dec_modregrm_len),             //input [2:0]
    
    
    .dec_ready_one                  (dec_ready_one),                //output
    .dec_ready_one_one              (dec_ready_one_one),            //output
    .dec_ready_one_two              (dec_ready_one_two),            //output
    .dec_ready_one_three            (dec_ready_one_three),          //output
    .dec_ready_2byte_one            (dec_ready_2byte_one),          //output
    .dec_ready_modregrm_one         (dec_ready_modregrm_one),       //output
    .dec_ready_2byte_modregrm       (dec_ready_2byte_modregrm),     //output
    .dec_ready_call_jmp_imm         (dec_ready_call_jmp_imm),       //output
    .dec_ready_one_imm              (dec_ready_one_imm),            //output
    .dec_ready_2byte_imm            (dec_ready_2byte_imm),          //output
    .dec_ready_mem_offset           (dec_ready_mem_offset),         //output
    .dec_ready_modregrm_imm         (dec_ready_modregrm_imm),       //output
    .dec_ready_2byte_modregrm_imm   (dec_ready_2byte_modregrm_imm), //output
    
    .consume_one                    (consume_one),                  //input
    .consume_one_one                (consume_one_one),              //input
    .consume_one_two                (consume_one_two),              //input
    .consume_one_three              (consume_one_three),            //input
    .consume_call_jmp_imm           (consume_call_jmp_imm),         //input
    .consume_modregrm_one           (consume_modregrm_one),         //input
    .consume_one_imm                (consume_one_imm),              //input
    .consume_modregrm_imm           (consume_modregrm_imm),         //input
    .consume_mem_offset             (consume_mem_offset),           //input
    
    .consume_count_local            (consume_count_local),          //output [3:0]
    .dec_is_modregrm                (dec_is_modregrm)               //output
);

//------------------------------------------------------------------------------

wire [3:0]  prefix_count;
wire        prefix_group_1_lock;

decode_prefix decode_prefix_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    .cs_cache                   (cs_cache),                 //input [63:0]
    .dec_is_modregrm            (dec_is_modregrm),          //input
    .decoder                    (decoder),                  //input [95:0]
    
    .instr_prefix               (instr_prefix),             //input
    .instr_finished             (instr_finished),           //input
                                 
    .dec_operand_32bit          (dec_operand_32bit),        //output
    .dec_address_32bit          (dec_address_32bit),        //output
    
    .dec_prefix_group_1_rep     (dec_prefix_group_1_rep),   //output [1:0]
    .dec_prefix_group_1_lock    (dec_prefix_group_1_lock),  //output
    .dec_prefix_group_2_seg     (dec_prefix_group_2_seg),   //output [2:0],
    
    .dec_prefix_2byte           (dec_prefix_2byte),         //output
    .dec_modregrm_len           (dec_modregrm_len),         //output [2:0]
                                 
    .prefix_count               (prefix_count),             // output [3:0]
    .is_prefix                  (is_prefix),                // output
    .prefix_group_1_lock        (prefix_group_1_lock)       // output
);

//------------------------------------------------------------------------------

decode_regs decode_regs_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .dec_reset          (dec_reset),        //input
    
    .fetch_valid        (fetch_valid),      //input [3:0]
    .fetch              (fetch),            //input [63:0]
    
    .prefix_count       (prefix_count),     //input [3:0]
    .consume_count      (consume_count),    //input [3:0]
    
    .dec_acceptable     (dec_acceptable),   //output [3:0]
    
    .decoder            (decoder),          //output [95:0]
    .decoder_count      (decoder_count)     //output [3:0]
);

//------------------------------------------------------------------------------

wire dec_exception_ud;

decode_commands decode_commands_inst(
    .protected_mode                 (protected_mode),               //input
    
    .dec_ready_one                  (dec_ready_one),                //input
    .dec_ready_one_one              (dec_ready_one_one),            //input
    .dec_ready_one_two              (dec_ready_one_two),            //input
    .dec_ready_one_three            (dec_ready_one_three),          //input
    .dec_ready_2byte_one            (dec_ready_2byte_one),          //input
    .dec_ready_modregrm_one         (dec_ready_modregrm_one),       //input
    .dec_ready_2byte_modregrm       (dec_ready_2byte_modregrm),     //input
    .dec_ready_call_jmp_imm         (dec_ready_call_jmp_imm),       //input
    .dec_ready_one_imm              (dec_ready_one_imm),            //input
    .dec_ready_2byte_imm            (dec_ready_2byte_imm),          //input
    .dec_ready_mem_offset           (dec_ready_mem_offset),         //input
    .dec_ready_modregrm_imm         (dec_ready_modregrm_imm),       //input
    .dec_ready_2byte_modregrm_imm   (dec_ready_2byte_modregrm_imm), //input
    
    .decoder                        (decoder),                      //input [95:0]
    .prefix_group_1_lock            (prefix_group_1_lock),          //input
    .dec_prefix_group_1_rep         (dec_prefix_group_1_rep),       //input [1:0]
    .dec_prefix_2byte               (dec_prefix_2byte),             //input
    
    .consume_one                    (consume_one),                  //output
    .consume_one_one                (consume_one_one),              //output
    .consume_one_two                (consume_one_two),              //output
    .consume_one_three              (consume_one_three),            //output
    .consume_call_jmp_imm           (consume_call_jmp_imm),         //output
    .consume_modregrm_one           (consume_modregrm_one),         //output
    .consume_one_imm                (consume_one_imm),              //output
    .consume_modregrm_imm           (consume_modregrm_imm),         //output
    .consume_mem_offset             (consume_mem_offset),           //output
    
    .dec_exception_ud               (dec_exception_ud),             //output
    
    .dec_is_8bit                    (dec_is_8bit),                  //output
    .dec_cmd                        (dec_cmd),                      //output [6:0]
    .dec_cmdex                      (dec_cmdex),                    //output [3:0]
    .dec_is_complex                 (dec_is_complex)                //output
);


//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//input: micro_busy, dec_reset

assign enable           = ~(stop);

assign instr_prefix     = enable && ~(dec_prefix_2byte) && is_prefix && decoder_count > 4'd0; 

assign dec_ready        = ~(dec_reset) && enable && ~(instr_prefix) && consume_count_local > 4'd0 && ~(micro_busy);

assign instr_finished   = dec_ready || dec_reset;

assign stop             = dec_ud_fault || dec_gp_fault || dec_pf_fault;

assign consume_count =
    (instr_prefix)?     4'd1 :
    (dec_reset)?        4'd0 :
    (micro_busy)?       4'd0 :
                        consume_count_local;

assign dec_consumed = (dec_ready)? consume_count_local + prefix_count : 4'd0;


//------------------------------------------------------------------------------


//-------------------------- GP

assign gp_fault = enable && ~(instr_prefix) && consume_count_local == 4'd0 && (
    ( fetch_valid == 4'd0 && fetch_limit ) ||   // external limit reached
    ( dec_acceptable == 4'd0 )                  // instruction length limit reached
);

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   gp_fault_last <= 1'b0;
    else                gp_fault_last <= gp_fault;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   dec_gp_fault <= `FALSE;
    else if(dec_reset)                  dec_gp_fault <= `FALSE;
    else if(gp_fault && gp_fault_last)  dec_gp_fault <= `TRUE;
end

//-------------------------- UD


always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           dec_ud_fault <= `FALSE;
    else if(dec_reset)          dec_ud_fault <= `FALSE;
    else if(dec_exception_ud)   dec_ud_fault <= `TRUE;
end

//-------------------------- PF

assign pf_fault = enable && ~(instr_prefix) && consume_count_local == 4'd0 && (
    ( fetch_valid == 4'd0 && fetch_page_fault )
);

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   pf_fault_last <= 1'b0;
    else                pf_fault_last <= pf_fault;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   dec_pf_fault <= `FALSE;
    else if(dec_reset)                  dec_pf_fault <= `FALSE;
    else if(pf_fault && pf_fault_last)  dec_pf_fault <= `TRUE;
end

//------------------------------------------------------------------------------ eip

assign dec_eip = eip + { 28'd0, dec_consumed };

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           eip <= `STARTUP_EIP;
    else if(pr_reset)                           eip <= prefetch_eip;
    else if(dec_ready)                          eip <= dec_eip;
end

//------------------------------------------------------------------------------

endmodule
