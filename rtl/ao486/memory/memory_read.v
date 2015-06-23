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

module memory_read(
    // global
    input               clk,
    input               rst_n,
    
    // read step
    input               rd_reset,
    
    //RESP:
    input               read_do,
    output reg          read_done,
    output reg          read_page_fault,
    output reg          read_ac_fault,
    
    input       [1:0]   read_cpl,
    input       [31:0]  read_address,
    input       [3:0]   read_length,
    input               read_lock,
    input               read_rmw,
    output reg  [63:0]  read_data,
    //END
    
    //REQ:
    output              tlbread_do,
    input               tlbread_done,
    input               tlbread_page_fault,
    input               tlbread_ac_fault,
    input               tlbread_retry,
    
    output      [1:0]   tlbread_cpl,
    output      [31:0]  tlbread_address,
    output      [3:0]   tlbread_length,
    output      [3:0]   tlbread_length_full,
    output              tlbread_lock,
    output              tlbread_rmw,
    input       [63:0]  tlbread_data
    //END
);

//------------------------------------------------------------------------------

reg [1:0]   state;

reg [55:0]  buffer;

reg [3:0]   length_2_reg;

reg [31:0]  address_2_reg;

reg         reset_waiting;

//------------------------------------------------------------------------------

wire [63:0] merged;

wire [4:0]  left_in_line;

wire [3:0]  length_1;

wire [3:0]  length_2;

wire [31:0] address_2;

//------------------------------------------------------------------------------

localparam [1:0] STATE_IDLE        = 2'd0;
localparam [1:0] STATE_FIRST_WAIT  = 2'd1;
localparam [1:0] STATE_SECOND      = 2'd2;

//------------------------------------------------------------------------------

assign left_in_line = 5'd16 - { 1'b0, read_address[3:0] };

assign length_1 = (left_in_line >= { 1'd0, read_length })? read_length : left_in_line[3:0];

assign length_2 = read_length - length_1;

assign address_2 = { read_address[31:4], 4'd0 } + 32'd16;

assign tlbread_cpl         = read_cpl;
assign tlbread_length_full = read_length;
assign tlbread_lock        = read_lock;
assign tlbread_rmw         = read_rmw;

//------------------------------------------------------------------------------

assign merged =
    (length_1 == 4'd1)? { tlbread_data[55:0], buffer[7:0] } :
    (length_1 == 4'd2)? { tlbread_data[47:0], buffer[15:0] } :
    (length_1 == 4'd3)? { tlbread_data[39:0], buffer[23:0] } :
    (length_1 == 4'd4)? { tlbread_data[31:0], buffer[31:0] } :
    (length_1 == 4'd5)? { tlbread_data[23:0], buffer[39:0] } :
    (length_1 == 4'd6)? { tlbread_data[15:0], buffer[47:0] } :
                        { tlbread_data[7:0],  buffer[55:0] };

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           reset_waiting <= `FALSE;
    else if(rd_reset && state != STATE_IDLE)    reset_waiting <= `TRUE;
    else if(state == STATE_IDLE)                reset_waiting <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               read_page_fault <= `FALSE;
    else if(rd_reset)                               read_page_fault <= `FALSE;
    else if(tlbread_page_fault && ~(reset_waiting)) read_page_fault <= `TRUE;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               read_ac_fault <= `FALSE;
    else if(rd_reset)                               read_ac_fault <= `FALSE;
    else if(tlbread_ac_fault && ~(reset_waiting))   read_ac_fault <= `TRUE;
end

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, address_2[3:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

/*
tlbread_cpl             -- constant assign from read
tlbread_address         -- set
tlbread_length          -- set
tlbread_length_full     -- constant assign from read
tlbread_lock            -- constant assign from read
tlbread_rmw             -- constant assign from read
*/  

/*******************************************************************************SCRIPT

IF(state == STATE_IDLE);
    
    SAVE(read_done, `FALSE);
    
    SAVE(length_2_reg,  length_2);
    SAVE(address_2_reg, { address_2[31:4], 4'd0 });
    
    SET(tlbread_address, read_address);
    SET(tlbread_length,  length_1);
    
    IF(read_do && ~(read_done) && ~(rd_reset) && ~(read_page_fault) && ~(read_ac_fault));
        
        SET(tlbread_do);
        
        SAVE(state, STATE_FIRST_WAIT);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_FIRST_WAIT);
    
    SET(tlbread_do);
    
    SET(tlbread_address, read_address);
    SET(tlbread_length,  length_1);
    
    IF(tlbread_page_fault || tlbread_ac_fault || (tlbread_retry && reset_waiting));
        SAVE(state, STATE_IDLE);
        
    ELSE_IF(tlbread_done && length_2_reg != 4'd0);
        SAVE(buffer, tlbread_data[55:0]);
    
        SAVE(state, STATE_SECOND);
        
    ELSE_IF(tlbread_done);
        
        IF(rd_reset == `FALSE && reset_waiting == `FALSE);
            SAVE(read_done, `TRUE);
            SAVE(read_data, tlbread_data);
        ENDIF();
        
        SAVE(state, STATE_IDLE);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_SECOND);
    
    SET(tlbread_address, address_2_reg);
    SET(tlbread_length,  length_2_reg);
    
    SET(tlbread_do);
    
    IF(tlbread_page_fault || tlbread_ac_fault || tlbread_done || (tlbread_retry && reset_waiting));
        SAVE(state, STATE_IDLE);
    ENDIF();
    
    IF(tlbread_done && rd_reset == `FALSE && reset_waiting == `FALSE);
        SAVE(read_done, `TRUE);
        SAVE(read_data, merged);
    ENDIF();
ENDIF();
*/

//------------------------------------------------------------------------------

`include "autogen/memory_read.v"

endmodule
