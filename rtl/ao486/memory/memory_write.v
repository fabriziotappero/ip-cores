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

module memory_write(
    input               clk,
    input               rst_n,
    
    // write step
    input               wr_reset,
    
    //RESP:
    input               write_do,
    output              write_done,
    output              write_page_fault,
    output              write_ac_fault,
    
    input       [1:0]   write_cpl,
    input       [31:0]  write_address,
    input       [2:0]   write_length,
    input               write_lock,
    input               write_rmw,
    input       [31:0]  write_data,
    //END
    
    //REQ: done at least one cycle later, do has to wait for doing
    output              tlbwrite_do,
    input               tlbwrite_done,
    input               tlbwrite_page_fault,
    input               tlbwrite_ac_fault,

    output      [1:0]   tlbwrite_cpl,
    output      [31:0]  tlbwrite_address,
    output      [2:0]   tlbwrite_length,
    output      [2:0]   tlbwrite_length_full,
    output              tlbwrite_lock,
    output              tlbwrite_rmw,
    output      [31:0]  tlbwrite_data
    //END
);


//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

reg [1:0]   state;

reg [23:0]  buffer;

reg [2:0]   length_2_reg;

reg [31:0]  address_2_reg;

reg         reset_waiting;

reg         page_fault;
reg         ac_fault;

//------------------------------------------------------------------------------

wire [4:0]  left_in_line;

wire [2:0]  length_1;

wire [2:0]  length_2;

wire [31:0] address_2;

//------------------------------------------------------------------------------

assign write_page_fault = tlbwrite_page_fault || page_fault;

assign write_ac_fault   = tlbwrite_ac_fault || ac_fault;

assign left_in_line = 5'd16 - { 1'b0, write_address[3:0] };

assign length_1 = (left_in_line >= { 2'd0, write_length })? write_length : left_in_line[2:0];

assign length_2 = write_length - length_1;

assign address_2 = { write_address[31:4], 4'd0 } + 32'd16;

assign tlbwrite_cpl         = write_cpl;
assign tlbwrite_length_full = write_length;
assign tlbwrite_lock        = write_lock;
assign tlbwrite_rmw         = write_rmw;

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           reset_waiting <= `FALSE;
    else if(wr_reset && state != STATE_IDLE)    reset_waiting <= `TRUE;
    else if(state == STATE_IDLE)                reset_waiting <= `FALSE;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   page_fault <= `FALSE;
    else if(wr_reset)                                   page_fault <= `FALSE;
    else if(tlbwrite_page_fault && ~(reset_waiting))    page_fault <= `TRUE;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               ac_fault <= `FALSE;
    else if(wr_reset)                               ac_fault <= `FALSE;
    else if(tlbwrite_ac_fault && ~(reset_waiting))  ac_fault <= `TRUE;
end

//------------------------------------------------------------------------------

localparam [1:0] STATE_IDLE        = 2'd0;
localparam [1:0] STATE_FIRST_WAIT  = 2'd1;
localparam [1:0] STATE_SECOND      = 2'd2;

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, address_2[3:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

/*
tlbwrite_cpl             -- constant assign from read
tlbwrite_address         -- set
tlbwrite_length          -- set
tlbwrite_length_full     -- constant assign from read
tlbwrite_lock            -- constant assign from read
tlbwrite_rmw             -- constant assign from read
tlbwrite_data            -- set
*/ 


/*******************************************************************************SCRIPT

IF(state == STATE_IDLE);
    
    IF(length_1 == 3'd1);      SAVE(buffer, write_data[31:8]);
    ELSE_IF(length_1 == 3'd2); SAVE(buffer, { 8'd0,  write_data[31:16] });
    ELSE();                       SAVE(buffer, { 16'd0, write_data[31:24] });
    ENDIF();
    
    SAVE(length_2_reg,  length_2);
    SAVE(address_2_reg, { address_2[31:4], 4'd0 });
    
    SET(tlbwrite_address, write_address);
    SET(tlbwrite_length,  length_1);
    SET(tlbwrite_data,    write_data);
    
    IF(write_do && ~(wr_reset) && ~(write_page_fault) && ~(write_ac_fault));
    
        SET(tlbwrite_do);
        
        SAVE(state, STATE_FIRST_WAIT);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_FIRST_WAIT);
    
    SET(tlbwrite_do);
    
    SET(tlbwrite_address, write_address);
    SET(tlbwrite_length,  length_1);
    SET(tlbwrite_data,    write_data);
    
    IF(tlbwrite_page_fault || tlbwrite_ac_fault);
        SAVE(state, STATE_IDLE);
        
    ELSE_IF(tlbwrite_done && length_2_reg != 3'd0);
        SAVE(state, STATE_SECOND);
        
    ELSE_IF(tlbwrite_done);
        IF(reset_waiting == `FALSE); SET(write_done); ENDIF(); //does not depend on: wr_reset == `FALSE
        SAVE(state, STATE_IDLE);
        
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_SECOND);
    
    SET(tlbwrite_do);
    
    SET(tlbwrite_address, address_2_reg);
    SET(tlbwrite_length,  length_2_reg);
    SET(tlbwrite_data,    { 8'd0, buffer });
    
    IF(tlbwrite_page_fault || tlbwrite_ac_fault || tlbwrite_done);
        SAVE(state, STATE_IDLE);
    ENDIF();
    
    IF(tlbwrite_done && reset_waiting == `FALSE); //does not depend on: wr_reset == `FALSE
        SET(write_done);
    ENDIF();
ENDIF();
*/

//------------------------------------------------------------------------------

`include "autogen/memory_write.v"

endmodule
