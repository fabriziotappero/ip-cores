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

module avalon_io(
    input               clk,
    input               rst_n,
    
    //io_read
    input               io_read_do,
    input       [15:0]  io_read_address,
    input       [2:0]   io_read_length,
    output reg  [31:0]  io_read_data,
    output reg          io_read_done,
    
    //io_write
    input               io_write_do,
    input       [15:0]  io_write_address,
    input       [2:0]   io_write_length,
    input       [31:0]  io_write_data,
    output reg          io_write_done,
    
    input               dcache_busy,
    
    //Avalon
    output reg  [15:0]  avalon_io_address,
    output reg  [3:0]   avalon_io_byteenable,
    
    output              avalon_io_read,
    input               avalon_io_readdatavalid,
    input       [31:0]  avalon_io_readdata,
    
    output              avalon_io_write,
    output reg  [31:0]  avalon_io_writedata,
    
    input               avalon_io_waitrequest
);


//------------------------------------------------------------------------------

reg [2:0] state;

reg       was_readdatavalid;

reg       avalon_io_read_reg;
reg       avalon_io_write_reg;

assign avalon_io_read  = (address_out_of_bounds)? 1'b0 : avalon_io_read_reg;
assign avalon_io_write = (address_out_of_bounds)? 1'b0 : avalon_io_write_reg;

//------------------------------------------------------------------------------

wire address_out_of_bounds =
    (avalon_io_address >= 16'h0010 && avalon_io_address < 16'h0020) ||
    (avalon_io_address == 16'h0020 && avalon_io_byteenable[1:0] == 2'b00) ||
    (avalon_io_address >= 16'h0024 && avalon_io_address < 16'h0040) ||
    (avalon_io_address >= 16'h0044 && avalon_io_address < 16'h0060) ||
    (avalon_io_address >= 16'h0068 && avalon_io_address < 16'h0070) ||
    (avalon_io_address == 16'h0070 && avalon_io_byteenable[1:0] == 2'b00) ||
    (avalon_io_address >= 16'h0074 && avalon_io_address < 16'h0080) ||
    (avalon_io_address == 16'h00A0 && avalon_io_byteenable[1:0] == 2'b00) ||
    (avalon_io_address >= 16'h00A4 && avalon_io_address < 16'h00C0) ||
    (avalon_io_address >= 16'h00E0 && avalon_io_address < 16'h01F0) ||
    (avalon_io_address >= 16'h01F8 && avalon_io_address < 16'h0220) ||
    (avalon_io_address >= 16'h0230 && avalon_io_address < 16'h0388) ||
    (avalon_io_address == 16'h0388 && avalon_io_byteenable[1:0] == 2'b00) ||
    (avalon_io_address >= 16'h038C && avalon_io_address < 16'h03B0) ||
    (avalon_io_address >= 16'h03E0 && avalon_io_address < 16'h03F0) ||
    (avalon_io_address >= 16'h03F8 && avalon_io_address < 16'h8888) ||
    (avalon_io_address >= 16'h8890);
    
wire [31:0] avalon_io_readdata_final =
    (address_out_of_bounds)?            32'hFFFFFFFF :
    (avalon_io_address == 16'h0020)?    { 16'hFFFF, avalon_io_readdata[15:0] } :
    (avalon_io_address == 16'h0070)?    { 16'hFFFF, avalon_io_readdata[15:0] } :
    (avalon_io_address == 16'h00A0)?    { 16'hFFFF, avalon_io_readdata[15:0] } :
    (avalon_io_address == 16'h0388)?    { 16'hFFFF, avalon_io_readdata[15:0] } :
                                        avalon_io_readdata;

//------------------------------------------------------------------------------

wire [3:0]  write_1_byteenable;
wire [3:0]  write_2_byteenable;
wire [31:0] write_1_data;
wire [31:0] write_2_data;
wire        write_two_stage;
wire [15:0] write_address_next;

wire [3:0]  read_1_byteenable;
wire [3:0]  read_2_byteenable;
wire        read_two_stage;
wire [15:0] read_address_next;
wire [31:0] read_data_1;
wire [31:0] read_data_2;

//------------------------------------------------------------------------------

localparam [2:0] STATE_IDLE      = 3'd0;
localparam [2:0] STATE_WRITE_1   = 3'd1;
localparam [2:0] STATE_WRITE_2   = 3'd2;
localparam [2:0] STATE_READ_1    = 3'd3;
localparam [2:0] STATE_READ_2    = 3'd4;

//------------------------------------------------------------------------------

assign write_address_next = io_write_address + 16'd4;
assign read_address_next  = io_read_address  + 16'd4;

//------------------------------------------------------------------------------

assign write_1_byteenable =
    (io_write_length == 3'd1 && io_write_address[1:0] == 2'd0)?     4'b0001 :
    (io_write_length == 3'd1 && io_write_address[1:0] == 2'd1)?     4'b0010 :
    (io_write_length == 3'd1 && io_write_address[1:0] == 2'd2)?     4'b0100 :
    (io_write_length == 3'd1 && io_write_address[1:0] == 2'd3)?     4'b1000 :
    (io_write_length == 3'd2 && io_write_address[1:0] == 2'd0)?     4'b0011 :
    (io_write_length == 3'd2 && io_write_address[1:0] == 2'd1)?     4'b0110 :
    (io_write_length == 3'd2 && io_write_address[1:0] == 2'd2)?     4'b1100 :
    (io_write_length == 3'd2 && io_write_address[1:0] == 2'd3)?     4'b1000 : //write_2 needed
    (io_write_length == 3'd4 && io_write_address[1:0] == 2'd0)?     4'b1111 :
    (io_write_length == 3'd4 && io_write_address[1:0] == 2'd1)?     4'b1110 : //write_2 needed
    (io_write_length == 3'd4 && io_write_address[1:0] == 2'd2)?     4'b1100 : //write_2 needed
                                                                    4'b1000;  //write_2 needed

assign write_2_byteenable =
    (io_write_length == 3'd2 && io_write_address[1:0] == 2'd3)?     4'b0001 :
    (io_write_length == 3'd4 && io_write_address[1:0] == 2'd1)?     4'b0001 :
    (io_write_length == 3'd4 && io_write_address[1:0] == 2'd2)?     4'b0011 :
                                                                    4'b0111;
assign write_1_data =
    (io_write_address[1:0] == 2'd0)?    io_write_data :
    (io_write_address[1:0] == 2'd1)?    { io_write_data[23:0], 8'd0 } :
    (io_write_address[1:0] == 2'd2)?    { io_write_data[15:0], 16'd0 } :
                                        { io_write_data[7:0],  24'd0 };
                                        
assign write_2_data =
    (io_write_length == 3'd2 && io_write_address[1:0] == 2'd3)?     { 24'd0, io_write_data[15:8] } :
    (io_write_length == 3'd4 && io_write_address[1:0] == 2'd1)?     { 24'd0, io_write_data[31:24] } :
    (io_write_length == 3'd4 && io_write_address[1:0] == 2'd2)?     { 16'd0, io_write_data[31:16] } :
                                                                    { 8'd0,  io_write_data[31:8] };
assign write_two_stage =
    (io_write_length == 3'd2 && io_write_address[1:0] == 2'd3) ||
    (io_write_length == 3'd4 && io_write_address[1:0] >= 2'd1);

//------------------------------------------------------------------------------

assign read_1_byteenable =
    (io_read_length == 3'd1 && io_read_address[1:0] == 2'd0)?     4'b0001 :
    (io_read_length == 3'd1 && io_read_address[1:0] == 2'd1)?     4'b0010 :
    (io_read_length == 3'd1 && io_read_address[1:0] == 2'd2)?     4'b0100 :
    (io_read_length == 3'd1 && io_read_address[1:0] == 2'd3)?     4'b1000 :
    (io_read_length == 3'd2 && io_read_address[1:0] == 2'd0)?     4'b0011 :
    (io_read_length == 3'd2 && io_read_address[1:0] == 2'd1)?     4'b0110 :
    (io_read_length == 3'd2 && io_read_address[1:0] == 2'd2)?     4'b1100 :
    (io_read_length == 3'd2 && io_read_address[1:0] == 2'd3)?     4'b1000 : //read_2 needed
    (io_read_length == 3'd4 && io_read_address[1:0] == 2'd0)?     4'b1111 :
    (io_read_length == 3'd4 && io_read_address[1:0] == 2'd1)?     4'b1110 : //read_2 needed
    (io_read_length == 3'd4 && io_read_address[1:0] == 2'd2)?     4'b1100 : //read_2 needed
                                                                  4'b1000;  //read_2 needed

assign read_2_byteenable =
    (io_read_length == 3'd2 && io_read_address[1:0] == 2'd3)?     4'b0001 :
    (io_read_length == 3'd4 && io_read_address[1:0] == 2'd1)?     4'b0001 :
    (io_read_length == 3'd4 && io_read_address[1:0] == 2'd2)?     4'b0011 :
                                                                  4'b0111;
assign read_two_stage =
    (io_read_length == 3'd2 && io_read_address[1:0] == 2'd3) ||
    (io_read_length == 3'd4 && io_read_address[1:0] >= 2'd1);
    
assign read_data_1 =
    (io_read_address[1:0] == 2'd0)?    avalon_io_readdata_final :
    (io_read_address[1:0] == 2'd1)?    { 8'd0,  avalon_io_readdata_final[31:8] } :
    (io_read_address[1:0] == 2'd2)?    { 16'd0, avalon_io_readdata_final[31:16] } :
                                       { 24'd0, avalon_io_readdata_final[31:24] };

assign read_data_2 =
    (io_read_length == 3'd2 && io_read_address[1:0] == 2'd3)?   { avalon_io_readdata_final[23:0], io_read_data[7:0] } :
    (io_read_length == 3'd4 && io_read_address[1:0] == 2'd1)?   { avalon_io_readdata_final[7:0],  io_read_data[23:0] } :
    (io_read_length == 3'd4 && io_read_address[1:0] == 2'd2)?   { avalon_io_readdata_final[15:0], io_read_data[15:0] } :
                                                                { avalon_io_readdata_final[23:0], io_read_data[7:0] };
    
    
//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, write_address_next[1:0], read_address_next[1:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

/*******************************************************************************SCRIPT

IF(state == STATE_IDLE);
    
    SAVE(io_write_done, `FALSE);
    SAVE(io_read_done,  `FALSE);
    
    IF(io_write_do && io_write_done == `FALSE && dcache_busy == `FALSE);
        
        SAVE(avalon_io_address,    { io_write_address[15:2], 2'b0 });
        SAVE(avalon_io_byteenable, write_1_byteenable);
        SAVE(avalon_io_write_reg,  `TRUE);
        SAVE(avalon_io_writedata,  write_1_data);
        
        SAVE(state, STATE_WRITE_1);
    ELSE_IF(io_read_do && io_read_done == `FALSE && dcache_busy == `FALSE);
    
        SAVE(avalon_io_address,     { io_read_address[15:2], 2'b0 });
        SAVE(avalon_io_byteenable,  read_1_byteenable);
        SAVE(avalon_io_read_reg,    `TRUE);
        
        SAVE(was_readdatavalid, `FALSE);
        SAVE(state, STATE_READ_1);
    ENDIF();
ENDIF();

*/

/*******************************************************************************SCRIPT

IF(state == STATE_WRITE_1);
    
    IF(avalon_io_waitrequest == `FALSE || address_out_of_bounds);
    
        IF(write_two_stage);
        
            SAVE(avalon_io_address,     { write_address_next[15:2], 2'b0 });
            SAVE(avalon_io_byteenable,  write_2_byteenable);
            SAVE(avalon_io_write_reg,   `TRUE);
            SAVE(avalon_io_writedata,   write_2_data);
            
            SAVE(state, STATE_WRITE_2);
        ELSE();
            SAVE(avalon_io_write_reg, `FALSE);
            
            SAVE(io_write_done, `TRUE);
            SAVE(state, STATE_IDLE);
        ENDIF();
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_WRITE_2);
    
    IF(avalon_io_waitrequest == `FALSE || address_out_of_bounds);
        SAVE(avalon_io_write_reg, `FALSE);
            
        SAVE(io_write_done, `TRUE);
        SAVE(state, STATE_IDLE);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_READ_1);
    
    IF(avalon_io_readdatavalid || address_out_of_bounds);
        SAVE(io_read_data, read_data_1);
        
        IF(read_two_stage);
                
            SAVE(avalon_io_address,     { read_address_next[15:2], 2'b0 });
            SAVE(avalon_io_byteenable,  read_2_byteenable);
            
            SAVE(avalon_io_read_reg, `TRUE);
            SAVE(state, STATE_READ_2);
        ELSE();
            SAVE(io_read_done, `TRUE);

            SAVE(avalon_io_read_reg, `FALSE);
            SAVE(state, STATE_IDLE);
        ENDIF();
    ENDIF();
    
    IF(avalon_io_waitrequest == `FALSE);
        SAVE(avalon_io_read_reg, `FALSE);
    ENDIF();
    
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_READ_2);
    
    IF(avalon_io_readdatavalid || address_out_of_bounds);
        SAVE(io_read_done, `TRUE);
        SAVE(io_read_data, read_data_2);
            
        SAVE(avalon_io_read_reg, `FALSE);
        SAVE(state, STATE_IDLE);
    ENDIF();
    
    IF(avalon_io_waitrequest == `FALSE);
        SAVE(avalon_io_read_reg, `FALSE);
    ENDIF();
    
ENDIF();
*/

//------------------------------------------------------------------------------

`include "autogen/avalon_io.v"

//------------------------------------------------------------------------------

endmodule
