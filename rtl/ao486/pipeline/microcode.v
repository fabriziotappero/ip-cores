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

module microcode(
    input               clk,
    input               rst_n,
    
    input               micro_reset,
    
    input               exc_init,
    input               exc_load,
    input       [31:0]  exc_eip,
    
    input       [31:0]  task_eip,
    
    //command control
    input               real_mode,
    input               v8086_mode,
    input               protected_mode,
    
    input               io_allow_check_needed,
    input               exc_push_error,
    input               cr0_pg,
    input               oflag,
    input               ntflag,
    input       [1:0]   cpl,
    
    input       [31:0]  glob_param_1,
    input       [31:0]  glob_param_3,
    input       [63:0]  glob_descriptor,
    
    //decoder
    output              micro_busy,
    input               dec_ready,
    
    input       [95:0]  decoder,
    input       [31:0]  dec_eip,
    input               dec_operand_32bit,
    input               dec_address_32bit,
    input       [1:0]   dec_prefix_group_1_rep,
    input               dec_prefix_group_1_lock,
    input       [2:0]   dec_prefix_group_2_seg,
    input               dec_prefix_2byte,
    input       [3:0]   dec_consumed,
    input       [2:0]   dec_modregrm_len,  
    input               dec_is_8bit,
    input       [6:0]   dec_cmd,
    input       [3:0]   dec_cmdex,
    
    input               dec_is_complex,
    
    //micro
    input               rd_busy,
    output              micro_ready,
        
    output      [87:0]  micro_decoder,
    output      [31:0]  micro_eip,
    output              micro_operand_32bit,
    output              micro_address_32bit,
    output      [1:0]   micro_prefix_group_1_rep,
    output              micro_prefix_group_1_lock,
    output      [2:0]   micro_prefix_group_2_seg,
    output              micro_prefix_2byte,
    output      [3:0]   micro_consumed,
    output      [2:0]   micro_modregrm_len,
    output              micro_is_8bit,
    output      [6:0]   micro_cmd,
    output      [3:0]   micro_cmdex
);

//------------------------------------------------------------------------------

wire task_start;

wire m_overlay;
wire m_load;

//------------------------------------------------------------------------------

reg         mc_operand_32bit;
reg         mc_address_32bit;
reg [1:0]   mc_prefix_group_1_rep;
reg         mc_prefix_group_1_lock;
reg [2:0]   mc_prefix_group_2_seg;
reg         mc_prefix_2byte;
reg [87:0]  mc_decoder;
reg [2:0]   mc_modregrm_len;
reg         mc_is_8bit;

reg [6:0]   mc_cmd;
reg [3:0]   mc_cmdex;
reg [3:0]   mc_consumed;
reg [31:0]  mc_eip;

reg [5:0]   mc_step;
reg [3:0]   mc_cmdex_last;
//------------------------------------------------------------------------------

assign micro_busy  = rd_busy || m_overlay;

assign micro_ready = ~(micro_reset) && ((~(m_overlay) && dec_ready) || (m_overlay && ~(rd_busy)));

assign m_load      = dec_ready && dec_is_complex;

assign m_overlay   = mc_cmd != `CMD_NULL;

assign task_start  = micro_cmd == `CMD_task_switch_4 && micro_cmdex == `CMDEX_task_switch_4_STEP_1 && micro_ready;

//------------------------------------------------------------------------------

wire [6:0]  mc_cmd_next;
wire [6:0]  mc_cmd_current;

wire [3:0]  mc_cmdex_current;

microcode_commands microcode_commands_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .protected_mode         (protected_mode),    //input
    .real_mode              (real_mode),         //input
    .v8086_mode             (v8086_mode),        //input
    
    .io_allow_check_needed  (io_allow_check_needed), //input
    .exc_push_error         (exc_push_error),        //input
    .cr0_pg                 (cr0_pg),                //input
    .oflag                  (oflag),                 //input
    .ntflag                 (ntflag),                //input
    .cpl                    (cpl),    //input [1:0]
    
    .glob_param_1           (glob_param_1),    //input [31:0]
    .glob_param_3           (glob_param_3),    //input [31:0]
    .glob_descriptor        (glob_descriptor), //input [63:0]
    
    .mc_operand_32bit       (mc_operand_32bit),   //input
    
    .mc_cmd                 (mc_cmd),     //input [6:0]
    .mc_decoder             (mc_decoder), //input [87:0]
    
    .mc_step                (mc_step),    //input [5:0]
    .mc_cmdex_last          (mc_cmdex_last),  //input [3:0]
    
    
    .mc_cmd_next            (mc_cmd_next),        //output [6:0]
    .mc_cmd_current         (mc_cmd_current),     //output [6:0]
    .mc_cmdex_current       (mc_cmdex_current)    //output [3:0]
);


//------------------------------------------------------------------------------
    
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) mc_operand_32bit       <= `FALSE; else if(m_load) mc_operand_32bit       <= dec_operand_32bit;       else if(exc_init) mc_operand_32bit       <= `FALSE;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) mc_address_32bit       <= `FALSE; else if(m_load) mc_address_32bit       <= dec_address_32bit;       else if(exc_init) mc_address_32bit       <= `FALSE;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) mc_prefix_group_1_rep  <= 2'd0;   else if(m_load) mc_prefix_group_1_rep  <= dec_prefix_group_1_rep;  else if(exc_init) mc_prefix_group_1_rep  <= 2'd0;    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) mc_prefix_group_1_lock <= `FALSE; else if(m_load) mc_prefix_group_1_lock <= dec_prefix_group_1_lock; else if(exc_init) mc_prefix_group_1_lock <= `FALSE;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) mc_prefix_group_2_seg  <= 3'd3;   else if(m_load) mc_prefix_group_2_seg  <= dec_prefix_group_2_seg;  else if(exc_init) mc_prefix_group_2_seg  <= 3'd3;    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) mc_prefix_2byte        <= `FALSE; else if(m_load) mc_prefix_2byte        <= dec_prefix_2byte;        else if(exc_init) mc_prefix_2byte        <= `FALSE;  end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) mc_decoder             <= 88'd0;  else if(m_load) mc_decoder             <= decoder[87:0];           else if(exc_init) mc_decoder             <= 88'd0;   end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) mc_modregrm_len        <= 3'd0;   else if(m_load) mc_modregrm_len        <= dec_modregrm_len;        else if(exc_init) mc_modregrm_len        <= 3'd0;    end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) mc_is_8bit             <= `FALSE; else if(m_load) mc_is_8bit             <= dec_is_8bit;             else if(exc_init) mc_is_8bit             <= `FALSE;  end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       mc_cmd <= `CMD_NULL;
    else if(exc_init)       mc_cmd <= `CMD_int;
    else if(micro_reset)    mc_cmd <= `CMD_NULL;
    else if(m_load)         mc_cmd <= dec_cmd;
    else if(micro_ready)    mc_cmd <= mc_cmd_next;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mc_cmdex <= 4'd0;
    else if(m_load)     mc_cmdex <= dec_cmdex;
    else if(exc_init)   mc_cmdex <= `CMDEX_int_STEP_0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mc_consumed <= 4'd0;
    else if(m_load)     mc_consumed <= dec_consumed;
    else if(task_start) mc_consumed <= 4'd0;
    else if(exc_load)   mc_consumed <= 4'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mc_eip <= 32'd0;
    else if(m_load)     mc_eip <= dec_eip;
    else if(task_start) mc_eip <= task_eip;
    else if(exc_load)   mc_eip <= exc_eip;
end

//------------------------------------------------------------------------------

assign micro_operand_32bit       = (m_overlay)? mc_operand_32bit       : dec_operand_32bit;
assign micro_address_32bit       = (m_overlay)? mc_address_32bit       : dec_address_32bit;
assign micro_prefix_group_1_rep  = (m_overlay)? mc_prefix_group_1_rep  : dec_prefix_group_1_rep;
assign micro_prefix_group_1_lock = (m_overlay)? mc_prefix_group_1_lock : dec_prefix_group_1_lock;
assign micro_prefix_group_2_seg  = (m_overlay)? mc_prefix_group_2_seg  : dec_prefix_group_2_seg;
assign micro_prefix_2byte        = (m_overlay)? mc_prefix_2byte        : dec_prefix_2byte;
assign micro_decoder             = (m_overlay)? mc_decoder             : decoder[87:0];
assign micro_modregrm_len        = (m_overlay)? mc_modregrm_len        : dec_modregrm_len;
assign micro_is_8bit             = (m_overlay)? mc_is_8bit             : dec_is_8bit;

assign micro_cmd =
    (exc_load)?   mc_cmd :
    (m_overlay)?        mc_cmd_current :
                        dec_cmd;

assign micro_cmdex =
    (exc_load)?   mc_cmdex :
    (m_overlay)?        mc_cmdex_current :
                        dec_cmdex;

assign micro_consumed =
    (task_start)?       4'd0 :
    (exc_load)?   4'd0 :
    (m_overlay)?        mc_consumed :
                        dec_consumed;

assign micro_eip =
    (task_start)?   task_eip :
    (exc_load)?     exc_eip :
    (m_overlay)?    mc_eip :
                    dec_eip;

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       mc_step <= 6'd0;
    else if(m_load)         mc_step <= 6'd1;
    else if(micro_ready)    mc_step <= mc_step + 6'd1;
    else if(exc_init)       mc_step <= 6'd1;
end


always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       mc_cmdex_last <= 4'd0;
    else if(micro_ready)    mc_cmdex_last <= micro_cmdex;
    else if(exc_init)       mc_cmdex_last <= `CMDEX_int_STEP_0;
end

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, decoder[95:88], 1'b0 };
// synthesis translate_on

endmodule
