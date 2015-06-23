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

module dcache_control_ram(
    input               clk,
    input               rst_n,
    
    input [31:0]        address,
    
    output [10:0]       q,
    input  [10:0]       data,
    
    //RESP:
    input               read_do,
    //END
    
    //RESP:
    input               write_do,
    //END
    
    //RESP:
    input               invddata_do,
    output              invddata_done,
    //END
    
    //RESP:
    input               wbinvddata_do,
    output              wbinvddata_done,
    //END
    
    
    //REQ:
    output              wbinvdread_do,
    output  [7:0]       wbinvdread_address,
    
    input   [147:0]     wbinvdread_ram0_q,
    input   [147:0]     wbinvdread_ram1_q,
    input   [147:0]     wbinvdread_ram2_q,
    input   [147:0]     wbinvdread_ram3_q,
    //END
    
    //REQ: write line
    output              writeline_do,
    input               writeline_done,
    
    output      [31:0]  writeline_address,
    output      [127:0] writeline_line
    //END
    
);

//------------------------------------------------------------------------------

reg [1:0]   state;

reg [7:0]   last_address;

reg         after_invalidate;

reg         init_done;

reg [7:0]   invd_counter;

reg [9:0]   wbinvd_counter;


//------------------------------------------------------------------------------

wire [10:0]     ram_q_a;

wire            start_wbinvd;

wire            wbinvd_write_control;

wire [9:0]      wbinvd_counter_next;

wire            wbinvd_valid;

wire [147:0]    wbinvd_line;

//------------------------------------------------------------------------------


assign q = (~(init_done) || state == STATE_INVD || start_wbinvd || state == STATE_WBINVD || after_invalidate)? 11'd0 : ram_q_a;

assign wbinvd_counter_next = wbinvd_counter + 10'd1;

assign wbinvd_valid = 
    (wbinvd_counter[1:0] == 2'd0)?  ram_q_a[1:0] == 2'b11 :
    (wbinvd_counter[1:0] == 2'd1)?  ram_q_a[3:2] == 2'b11 :
    (wbinvd_counter[1:0] == 2'd2)?  ram_q_a[5:4] == 2'b11 :
                                    ram_q_a[7:6] == 2'b11;
        
assign wbinvd_line =
    (wbinvd_counter[1:0] == 2'd0)?  wbinvdread_ram0_q :
    (wbinvd_counter[1:0] == 2'd1)?  wbinvdread_ram1_q :
    (wbinvd_counter[1:0] == 2'd2)?  wbinvdread_ram2_q :
                                    wbinvdread_ram3_q;


//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   last_address <= 8'd0;
    else if(read_do)    last_address <= address[11:4];
end


//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

localparam [1:0] STATE_IDLE   = 2'd0;
localparam [1:0] STATE_INVD   = 2'd1;
localparam [1:0] STATE_WBINVD = 2'd2;

//------------------------------------------------------------------------------

// port a: q - 11 bits; {3 pLRU, 8 msi}; msi: x0 - invalid; 01 - valid clean; 11 - valid dirty

simple_ram #(
    .width      (11),
    .widthad    (8)
)
dcache_control_ram_inst(
    .clk        (clk),  //input
    
    .wraddress  ((~(init_done) || state == STATE_INVD)?     invd_counter :
                 (state == STATE_WBINVD)?                   wbinvd_counter[9:2] :
                                                            address[11:4]),                                                                             //input [7:0]
    
    .wren       ((~(init_done) || state == STATE_INVD) || wbinvd_write_control || (init_done && state == STATE_IDLE && ~(start_wbinvd) && write_do)),   //input
    .data       ((~(init_done) || state == STATE_INVD || state == STATE_WBINVD)? 11'd0 : data),                                                         //input [10:0]
    
    .rdaddress  ((start_wbinvd || state == STATE_WBINVD)?   wbinvdread_address :
                 (read_do)?                                 address[11:4] :
                                                            last_address),      //input [7:0]
    .q          (ram_q_a)                                                       //output [10:0]
);

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, address[31:12], address[3:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

    
/*******************************************************************************SCRIPT
IF(init_done == `FALSE);

    SAVE(invd_counter, invd_counter + 8'd1);
    
    IF(invd_counter == 8'd255);
        SAVE(after_invalidate, `TRUE);
        SAVE(init_done,        `TRUE);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_IDLE);
    SAVE(after_invalidate, `FALSE);

    IF(init_done && invddata_do);
        SAVE(state, STATE_INVD);
    
    ELSE_IF(init_done && wbinvddata_do);
    
        SET(start_wbinvd);
        
        SET(wbinvdread_do);
        SET(wbinvdread_address, wbinvd_counter[9:2]);
        
        SAVE(state, STATE_WBINVD);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_INVD);
    SAVE(invd_counter, invd_counter + 8'd1);
    
    IF(invd_counter == 8'd255);
        SET(invddata_done);
        
        SAVE(after_invalidate, `TRUE);
        SAVE(state, STATE_IDLE);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT
IF(state == STATE_WBINVD);

    IF(wbinvd_valid);
        
        SET(writeline_do);
        SET(writeline_address, { wbinvd_line[147:128], wbinvd_counter[9:2], 4'd0 });
        SET(writeline_line,    wbinvd_line[127:0]);
        
        IF(writeline_done);
            SAVE(wbinvd_counter,      wbinvd_counter_next);
            
            SET(wbinvd_write_control, wbinvd_counter[1:0] == 2'd3);
            
            SET(wbinvdread_do);
            SET(wbinvdread_address, wbinvd_counter_next[9:2]);
            
            IF(wbinvd_counter == 10'd1023);
                SET(wbinvddata_done);
                
                SAVE(after_invalidate, `TRUE);
                SAVE(state, STATE_IDLE);
            ENDIF();
        ELSE();
            SET(wbinvdread_address, wbinvd_counter[9:2]);
        ENDIF();
    ELSE();
        SAVE(wbinvd_counter, wbinvd_counter_next);
        
        SET(wbinvd_write_control, wbinvd_counter[1:0] == 2'd3);
        
        SET(wbinvdread_do);
        SET(wbinvdread_address, wbinvd_counter_next[9:2]);
        
        IF(wbinvd_counter == 10'd1023);
            SET(wbinvddata_done);
            
            SAVE(after_invalidate, `TRUE);
            SAVE(state, STATE_IDLE);
        ENDIF();
    ENDIF();
ENDIF();
*/

//------------------------------------------------------------------------------

`include "autogen/dcache_control_ram.v"

endmodule
