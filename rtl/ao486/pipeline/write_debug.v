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

module write_debug(
    input               clk,
    input               rst_n,
    
    //general input
    input       [31:0]  dr0,
    input       [31:0]  dr1,
    input       [31:0]  dr2,
    input       [31:0]  dr3,
    input       [31:0]  dr7,
    
    input       [2:0]   debug_len0,
    input       [2:0]   debug_len1,
    input       [2:0]   debug_len2,
    input       [2:0]   debug_len3,
    
    input               rflag_to_reg,
    input               tflag_to_reg,
    
    input       [31:0]  wr_eip,
    
    input       [31:0]  cs_base,
    input       [31:0]  cs_limit,
    
    //memory write
    input       [31:0]  write_address,
    input       [2:0]   write_length,
    input               write_for_wr_ready,
    
    //write control
    input               w_load,
    input               wr_finished,
    input               wr_inhibit_interrupts_and_debug,
    input               wr_debug_task_trigger,
    input               wr_debug_trap_clear,
    
    input               wr_string_in_progress,
    
    //pipeline input
    input       [3:0]   exe_debug_read,
    
    //output
    output              wr_debug_prepare,
    
    output reg  [3:0]   wr_debug_code_reg,
    output reg  [3:0]   wr_debug_write_reg,
    output reg  [3:0]   wr_debug_read_reg,
    output reg          wr_debug_step_reg,
    output reg          wr_debug_task_reg
);

//------------------------------------------------------------------------------

wire wr_debug_breakpoints_disabled;

assign wr_debug_breakpoints_disabled = dr7[7:0] == 8'h00;
    
//NOTE: GD exception -- has to have: (single_step / breakpoint data) saved

//------------------------------------------------------------------------------ debug read

wire        wr_debug_read_active;
wire [3:0]  wr_debug_read_current;

assign wr_debug_read_current = (wr_debug_breakpoints_disabled)? 4'd0 : exe_debug_read;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               wr_debug_read_reg <= 4'd0;
    
    else if(wr_inhibit_interrupts_and_debug || wr_debug_prepare)    wr_debug_read_reg <= wr_debug_read_reg; // no change
    else if(wr_debug_trap_clear)                                    wr_debug_read_reg <= 4'd0;
    
    //w_load -> no debug exception; no interrupt
    else if(wr_finished && w_load)                              wr_debug_read_reg <= wr_debug_read_current;
    else if(wr_finished && ~(w_load))                           wr_debug_read_reg <= 4'd0;
    else if(w_load)                                             wr_debug_read_reg <= wr_debug_read_reg | wr_debug_read_current;
end

assign wr_debug_read_active =
    (wr_debug_read_reg[3] && dr7[7:6] != 2'b00) || (wr_debug_read_reg[2] && dr7[5:4] != 2'b00) ||
    (wr_debug_read_reg[1] && dr7[3:2] != 2'b00) || (wr_debug_read_reg[0] && dr7[1:0] != 2'b00);

//------------------------------------------------------------------------------ write breakpoints

wire [31:0] wr_debug_linear_last;    
reg         wr_debug_b0_write_trigger;
reg         wr_debug_b1_write_trigger;
reg         wr_debug_b2_write_trigger;
reg         wr_debug_b3_write_trigger;

reg  [31:0] wr_debug_linear_last_reg;
reg  [31:0] write_address_last;

assign wr_debug_linear_last = write_address + { 29'd0, write_length } - 32'd1;


//NOTE: write_for_wr_ready at least two cycles after valid write_address
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_debug_linear_last_reg <= 32'd0;
    else                wr_debug_linear_last_reg <= wr_debug_linear_last;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   write_address_last <= 32'd0;
    else                write_address_last <= write_address;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_debug_b0_write_trigger <= `FALSE;
    else                wr_debug_b0_write_trigger <= dr7[16] == 1'b1 && // RW bits = (read or write) or write only
                                                     ( write_address_last        <= { dr0[31:3], dr0[2:0] | ~(debug_len0)} ) &&
                                                     ( wr_debug_linear_last_reg  >= { dr0[31:3], dr0[2:0] &   debug_len0 } );
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_debug_b1_write_trigger <= `FALSE;
    else                wr_debug_b1_write_trigger <= dr7[20] == 1'b1 && // RW bits = (read or write) or write only
                                                     ( write_address_last        <= { dr1[31:3], dr1[2:0] | ~(debug_len1)} ) &&
                                                     ( wr_debug_linear_last_reg  >= { dr1[31:3], dr1[2:0] &   debug_len1 } );
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_debug_b2_write_trigger <= `FALSE;
    else                wr_debug_b2_write_trigger <= dr7[24] == 1'b1 && // RW bits = (read or write) or write only
                                                     ( write_address_last        <= { dr2[31:3], dr2[2:0] | ~(debug_len2)} ) &&
                                                     ( wr_debug_linear_last_reg  >= { dr2[31:3], dr2[2:0] &   debug_len2 } );
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wr_debug_b3_write_trigger <= `FALSE;
    else                wr_debug_b3_write_trigger <= dr7[28] == 1'b1 && // RW bits = (read or write) or write only
                                                     ( write_address_last        <= { dr3[31:3], dr3[2:0] | ~(debug_len3)} ) &&
                                                     ( wr_debug_linear_last_reg  >= { dr3[31:3], dr3[2:0] &   debug_len3 } );
end

//------------------------------------------------------------------------------ debug write

wire [3:0]  wr_debug_write;
wire        wr_debug_write_active;
wire [3:0]  wr_debug_write_current;

assign wr_debug_write_current = (wr_debug_breakpoints_disabled)? 4'd0 :
    { wr_debug_b3_write_trigger, wr_debug_b2_write_trigger, wr_debug_b1_write_trigger, wr_debug_b0_write_trigger };
    

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               wr_debug_write_reg <= 4'd0;
    
    else if(wr_inhibit_interrupts_and_debug)        wr_debug_write_reg <= wr_debug_write_reg; // no change
    else if(wr_debug_trap_clear)                    wr_debug_write_reg <= 4'd0;
    
    else if(write_for_wr_ready || wr_debug_prepare) wr_debug_write_reg <= wr_debug_write;
    else if(wr_finished)                            wr_debug_write_reg <= 4'd0;
end

assign wr_debug_write = wr_debug_write_current | wr_debug_write_reg;

assign wr_debug_write_active =
    (wr_debug_write[3] && dr7[7:6] != 2'b00) || (wr_debug_write[2] && dr7[5:4] != 2'b00) ||
    (wr_debug_write[1] && dr7[3:2] != 2'b00) || (wr_debug_write[0] && dr7[1:0] != 2'b00);


//------------------------------------------------------------------------------ debug code

wire        wr_debug_code_trigger;
wire        wr_debug_b0_code_trigger;
wire        wr_debug_b1_code_trigger;
wire        wr_debug_b2_code_trigger;
wire        wr_debug_b3_code_trigger;
wire        wr_debug_code_active;
wire [3:0]  wr_debug_code;

wire [31:0] wr_code_linear;

assign wr_code_linear = cs_base + wr_eip;

assign wr_debug_code_trigger =
    wr_finished && wr_eip <= cs_limit && rflag_to_reg == 1'b0 && ~(wr_debug_breakpoints_disabled) && ~(wr_string_in_progress);
    
assign wr_debug_b0_code_trigger =
    wr_debug_code_trigger && dr7[17:16] == 2'b00 && { dr0[31:3], dr0[2:0] & debug_len0 } == { wr_code_linear[31:3], wr_code_linear[2:0] & debug_len0 };
    
assign wr_debug_b1_code_trigger =
    wr_debug_code_trigger && dr7[21:20] == 2'b00 && { dr1[31:3], dr1[2:0] & debug_len1 } == { wr_code_linear[31:3], wr_code_linear[2:0] & debug_len1 };
      
assign wr_debug_b2_code_trigger =
    wr_debug_code_trigger && dr7[25:24] == 2'b00 && { dr2[31:3], dr2[2:0] & debug_len2 } == { wr_code_linear[31:3], wr_code_linear[2:0] & debug_len2 };

assign wr_debug_b3_code_trigger =
    wr_debug_code_trigger && dr7[29:28] == 2'b00 && { dr3[31:3], dr3[2:0] & debug_len3 } == { wr_code_linear[31:3], wr_code_linear[2:0] & debug_len3 };
    
assign wr_debug_code_active =
    (wr_debug_b3_code_trigger && dr7[7:6] != 2'b00) || (wr_debug_b2_code_trigger && dr7[5:4] != 2'b00) ||
    (wr_debug_b1_code_trigger && dr7[3:2] != 2'b00) || (wr_debug_b0_code_trigger && dr7[1:0] != 2'b00);

assign wr_debug_code = (wr_debug_code_active)? 
    { wr_debug_b3_code_trigger, wr_debug_b2_code_trigger, wr_debug_b1_code_trigger, wr_debug_b0_code_trigger } : 4'd0;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           wr_debug_code_reg <= 4'd0;
    else if(wr_debug_prepare)   wr_debug_code_reg <= wr_debug_code;
end

//------------------------------------------------------------------------------ debug single step

reg wr_debug_step;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           wr_debug_step_reg <= `FALSE;
    else if(wr_debug_prepare)   wr_debug_step_reg <= wr_debug_step;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               wr_debug_step <= `FALSE;
    else if(wr_debug_trap_clear)    wr_debug_step <= `FALSE;
    else if(wr_finished)            wr_debug_step <= tflag_to_reg;
end

//------------------------------------------------------------------------------ debug task switch

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           wr_debug_task_reg <= `FALSE;
    else if(wr_debug_prepare)   wr_debug_task_reg <= wr_debug_task_trigger;
end

//------------------------------------------------------------------------------ final debug init

assign wr_debug_prepare =
    wr_finished && ~(wr_inhibit_interrupts_and_debug) && (
        wr_debug_task_trigger || wr_debug_step || wr_debug_code_active || wr_debug_read_active || wr_debug_write_active
    );

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, dr7[31:30], dr7[27:26], dr7[23:22], dr7[19:18], dr7[15:8], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
