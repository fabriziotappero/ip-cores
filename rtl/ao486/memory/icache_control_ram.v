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

module icache_control_ram(
    input               clk,
    input               rst_n,
    
    input [31:0]        address,
    
    //RESP:
    input               read_do,
    output [6:0]        q,
    //END
    
    //RESP:
    input               write_do,
    input  [6:0]        data,
    //END
    
    //RESP:
    input               invdcode_do,
    output              invdcode_done
    //END
);

//------------------------------------------------------------------------------

reg [7:0] last_address;
reg       after_invalidate;
reg       state;
reg       init_done;
reg [7:0] invd_counter;

//------------------------------------------------------------------------------

wire [6:0] ram_q_a;

//------------------------------------------------------------------------------

localparam STATE_IDLE = 1'd0;
localparam STATE_INVD = 1'd1;

//------------------------------------------------------------------------------

assign q = (~(init_done) || state == STATE_INVD || after_invalidate)? 7'd0 : ram_q_a;

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   last_address <= 8'd0;
    else if(read_do)    last_address <= address[11:4];
end

//------------------------------------------------------------------------------

// port a: q - 7 bits; {3 pLRU, 4 msi}; msi: 0 - invalid; 1 - valid 

simple_ram #(
    .width      (7),
    .widthad    (8)
)
icache_control_ram_inst(
    .clk        (clk),  //input
    
    .wraddress  ((~(init_done) || state == STATE_INVD)? invd_counter : address[11:4]),                      //input [7:0]
    .wren       ((~(init_done) || state == STATE_INVD) || (init_done && state == STATE_IDLE && write_do)),  //input
    .data       ((~(init_done) || state == STATE_INVD)? 7'd0 : data),                                       //input [6:0]
    
    .rdaddress  ((read_do)? address[11:4] : last_address),      //input [7:0]
    .q          (ram_q_a)                                       //output [6:0]
);

//------------------------------------------------------------------------------

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
        SAVE(init_done, `TRUE);    
    ENDIF();
ENDIF();
*/
    
/*******************************************************************************SCRIPT

IF(state == STATE_IDLE);
    SAVE(after_invalidate, `FALSE);
    
    IF(init_done && invdcode_do);
        SAVE(state, STATE_INVD);
    ENDIF();

ENDIF();
*/
    
/*******************************************************************************SCRIPT

IF(state == STATE_INVD);
    SAVE(invd_counter, invd_counter + 8'd1);
    
    IF(invd_counter == 8'd255);
        SET(invdcode_done);
        
        SAVE(after_invalidate, `TRUE);
        SAVE(state, STATE_IDLE);
    ENDIF();
ENDIF();
*/

//------------------------------------------------------------------------------

`include "autogen/icache_control_ram.v"

endmodule
