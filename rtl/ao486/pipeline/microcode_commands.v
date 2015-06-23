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

//PARSED_COMMENTS: this file contains parsed script comments

module microcode_commands(
    input               clk,
    input               rst_n,
    
    input               protected_mode,
    input               real_mode,
    input               v8086_mode,
    
    input               io_allow_check_needed,
    input               exc_push_error,
    input               cr0_pg,
    input               oflag,
    input               ntflag,
    input       [1:0]   cpl,
    
    input       [31:0]  glob_param_1,
    input       [31:0]  glob_param_3,
    input       [63:0]  glob_descriptor,
    
    input               mc_operand_32bit,
    
    input       [6:0]   mc_cmd,
    input       [87:0]  mc_decoder,
    
    input       [5:0]   mc_step,
    input       [3:0]   mc_cmdex_last,
    
    
    output      [6:0]   mc_cmd_next,
    output      [6:0]   mc_cmd_current,
    output      [3:0]   mc_cmdex_current
);

//------------------------------------------------------------------------------

reg [6:0]   mc_saved_command;
reg [3:0]   mc_saved_cmdex;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, glob_param_1[31:18], glob_param_1[15:2], glob_param_3[31:25], glob_param_3[16:0], glob_descriptor[63:47], glob_descriptor[39:0], mc_decoder[87:29], mc_decoder[23:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

`include "autogen/microcode_commands.v"

endmodule
