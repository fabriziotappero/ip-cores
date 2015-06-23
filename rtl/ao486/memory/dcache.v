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

module dcache(
    // global
    input               clk,
    input               rst_n,
    
    //RESP:
    input               dcacheread_do,
    output              dcacheread_done,
    
    input   [3:0]       dcacheread_length,
    input               dcacheread_cache_disable,
    input   [31:0]      dcacheread_address,
    output  [63:0]      dcacheread_data,
    //END
    
    //RESP:
    input               dcachewrite_do,
    output              dcachewrite_done,
    
    input   [2:0]       dcachewrite_length,
    input               dcachewrite_cache_disable,
    input   [31:0]      dcachewrite_address,
    input               dcachewrite_write_through,
    input   [31:0]      dcachewrite_data,
    //END
    
    //REQ:
    output              readline_do,
    input               readline_done,
    
    output  [31:0]      readline_address,
    input   [127:0]     readline_line,
    //END
    
    //REQ:
    output              readburst_do,
    input               readburst_done,
    
    output  [31:0]      readburst_address,
    output  [1:0]       readburst_dword_length,
    output  [3:0]       readburst_byte_length,
    input   [95:0]      readburst_data,
    //END
    
    //REQ: write line
    output              writeline_do,
    input               writeline_done,
    
    output      [31:0]  writeline_address,
    output      [127:0] writeline_line,
    //END
    
    //REQ:
    output              writeburst_do,
    input               writeburst_done,
    
    output      [31:0]  writeburst_address,
    output      [1:0]   writeburst_dword_length,
    output      [3:0]   writeburst_byteenable_0,
    output      [3:0]   writeburst_byteenable_1,
    output      [55:0]  writeburst_data,
    //END
    
    output              dcachetoicache_write_do,
    output      [31:0]  dcachetoicache_write_address,
    
    //RESP:
    input               invddata_do,
    output              invddata_done,
    //END
    
    //RESP:
    input               wbinvddata_do,
    output              wbinvddata_done,
    //END
    
    output              dcache_busy
);

//------------------------------------------------------------------------------

reg [31:0]  address;
reg         cache_disable;
reg [3:0]   length;

reg         write_through;
reg [31:0]  write_data;

reg         is_write;
reg [2:0]   state;

//------------------------------------------------------------------------------

localparam [2:0] STATE_IDLE          = 3'd0;
localparam [2:0] STATE_READ_CHECK    = 3'd1;
localparam [2:0] STATE_READ_BURST    = 3'd2;
localparam [2:0] STATE_WRITE_BACK    = 3'd3;
localparam [2:0] STATE_READ_LINE     = 3'd4;
localparam [2:0] STATE_WRITE_CHECK   = 3'd5;
localparam [2:0] STATE_WRITE_THROUGH = 3'd6;

//------------------------------------------------------------------------------

wire        wbinvdread_do;
wire [7:0]  wbinvdread_address;

wire            dcache_writeline_do;
wire [31:0]     dcache_writeline_address;
wire [127:0]    dcache_writeline_line;

//------------------------------------------------------------------------------

assign writeline_do         = dcache_writeline_do || control_ram_writeline_do;
assign writeline_address    = (dcache_writeline_do)? dcache_writeline_address : control_ram_writeline_address;
assign writeline_line       = (dcache_writeline_do)? dcache_writeline_line    : control_ram_writeline_line;

assign dcache_busy = state != STATE_IDLE;

//------------------------------------------------------------------------------

wire [31:0] control_ram_address;
wire        control_ram_read_do;
wire        control_ram_write_do;
wire [10:0] control_ram_data;
wire [10:0] control_ram_q;

wire            control_ram_writeline_do;
wire [31:0]     control_ram_writeline_address;
wire [127:0]    control_ram_writeline_line;

//------------------------------------------------------------------------------

wire         matched;
wire [1:0]   matched_index;
wire [127:0] matched_data_line;

wire [1:0]   plru_index;
wire [147:0] plru_data_line;

wire [10:0]  control_after_match;
wire [10:0]  control_after_line_read;
wire [10:0]  control_after_write_to_existing;
wire [10:0]  control_after_write_to_new;

wire         writeback_needed;

//------------------------------------------------------------------------------

wire [63:0] read_from_line;
wire [1:0]  read_burst_dword_length;
wire [3:0]  read_burst_byte_length;
wire [63:0] read_from_burst;

//------------------------------------------------------------------------------

wire [127:0] line_merged;
wire [1:0]   write_burst_dword_length;
wire [3:0]   write_burst_byteenable_0;
wire [3:0]   write_burst_byteenable_1;
wire [55:0]  write_burst_data;

//------------------------------------------------------------------------------

wire            data_ram0_read_do;
wire [31:0]     data_ram0_address;
wire            data_ram0_write_do;
wire [127:0]    data_ram0_data;
wire [147:0]    data_ram0_q;

wire            data_ram1_read_do;
wire [31:0]     data_ram1_address;
wire            data_ram1_write_do;
wire [127:0]    data_ram1_data;
wire [147:0]    data_ram1_q;

wire            data_ram2_read_do;
wire [31:0]     data_ram2_address;
wire            data_ram2_write_do;
wire [127:0]    data_ram2_data;
wire [147:0]    data_ram2_q;

wire            data_ram3_read_do;
wire [31:0]     data_ram3_address;
wire            data_ram3_write_do;
wire [127:0]    data_ram3_data;
wire [147:0]    data_ram3_q;

//------------------------------------------------------------------------------

dcache_matched dcache_matched_inst(
    .address    (address),  //input [31:0]
    
    .control    (control_ram_q),    //input [10:0]
    
    .data_0     (data_ram0_q),      //input [147:0]
    .data_1     (data_ram1_q),      //input [147:0]
    .data_2     (data_ram2_q),      //input [147:0]
    .data_3     (data_ram3_q),      //input [147:0]
    
    .matched            (matched),              //output
    .matched_index      (matched_index),        //output [2:0]
    .matched_data_line  (matched_data_line),    //output [127:0]
                                   
    .plru_index         (plru_index),           //output [1:0]
    .plru_data_line     (plru_data_line),       //output [147:0]
                                   
    .control_after_match                (control_after_match),              //output [10:0]
    .control_after_line_read            (control_after_line_read),          //output [10:0]
    .control_after_write_to_existing    (control_after_write_to_existing),  //output [10:0]
    .control_after_write_to_new         (control_after_write_to_new),       //output [10:0]

    .writeback_needed                   (writeback_needed)                  //output
);



dcache_read dcache_read_inst(
    
    .line       ((state == STATE_READ_LINE)? readline_line : matched_data_line),    //input [127:0]
    .read_data  (readburst_data),                                                   //input [95:0]                         
                             
    .address    (address),                                                          //input [31:0]
    .length     (length),                                                           //input [3:0]

    .read_from_line             (read_from_line),               //output [63:0]
    .read_burst_dword_length    (read_burst_dword_length),      //output [1:0]
    .read_burst_byte_length     (read_burst_byte_length),       //output [11:0]
    .read_from_burst            (read_from_burst)               //output [63:0]
);

dcache_write dcache_write_inst(
    
    .line       ((state == STATE_READ_LINE)? readline_line : matched_data_line),    //input [127:0]
    .address    (address),                                                          //input [31:0]
    .length     (length[2:0]),                                                      //input [2:0]
    .write_data (write_data),                                                       //input [31:0]
                               
    .write_burst_dword_length   (write_burst_dword_length),     //output [1:0]
    .write_burst_byteenable_0   (write_burst_byteenable_0),     //output [3:0]
    .write_burst_byteenable_1   (write_burst_byteenable_1),     //output [3:0]
    .write_burst_data           (write_burst_data),             //output [55:0]
    .line_merged                (line_merged)                   //output [127:0]
);

dcache_control_ram dcache_control_ram_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .address        (control_ram_address),      //input [31:0]
    .data           (control_ram_data),         //input [10:0]
                                           
    .q              (control_ram_q),            //output [10:0]
                                           
    .read_do        (control_ram_read_do),
    
                                           
    .write_do       (control_ram_write_do),
    
    //RESP:
    .invddata_do        (invddata_do && state == STATE_IDLE),   //input
    .invddata_done      (invddata_done),                        //output
    //END
    
    //RESP:
    .wbinvddata_do      (wbinvddata_do && state == STATE_IDLE), //input
    .wbinvddata_done    (wbinvddata_done),                      //output
    //END
    
    
    //REQ:
    .wbinvdread_do      (wbinvdread_do),        //output
    .wbinvdread_address (wbinvdread_address),   //output [7:0]
    
    .wbinvdread_ram0_q      (data_ram0_q),  //input [147:0]
    .wbinvdread_ram1_q      (data_ram1_q),  //input [147:0]
    .wbinvdread_ram2_q      (data_ram2_q),  //input [147:0]
    .wbinvdread_ram3_q      (data_ram3_q),  //input [147:0]
    //END
    
    //REQ: write line
    .writeline_do           (control_ram_writeline_do),         //output
    .writeline_done         (writeline_done),                   //input
    
    .writeline_address      (control_ram_writeline_address),    //output [31:0]
    .writeline_line         (control_ram_writeline_line)        //output [127:0]
    //END
);

cache_data_ram cache_data_ram0_inst(
    .clk        (clk),
    .rst_n      (rst_n),
                                       
    .read_do        (data_ram0_read_do),
    .address        (data_ram0_address),
    
    .write_do       (data_ram0_write_do),
    .data           (data_ram0_data),
    .q              (data_ram0_q)
);



cache_data_ram cache_data_ram1_inst(
    .clk        (clk),
    .rst_n      (rst_n),
                                       
    .read_do    (data_ram1_read_do),
    .address    (data_ram1_address),
    
    .write_do       (data_ram1_write_do),
    .data           (data_ram1_data),
    .q              (data_ram1_q)
);



cache_data_ram cache_data_ram2_inst(
    .clk        (clk),
    .rst_n      (rst_n),
                                       
    .read_do        (data_ram2_read_do),
    .address        (data_ram2_address),
    
    .write_do       (data_ram2_write_do),
    .data           (data_ram2_data),
    .q              (data_ram2_q)
);

cache_data_ram cache_data_ram3_inst(
    .clk        (clk),
    .rst_n      (rst_n),
                                       
    .read_do        (data_ram3_read_do),
    .address        (data_ram3_address),
                                      
    .write_do       (data_ram3_write_do),
    .data           (data_ram3_data),
    .q              (data_ram3_q)
);


//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
    
    
/*******************************************************************************SCRIPT

IF(state == STATE_IDLE);
    
    IF(invddata_do);
        
        //wait
        
    ELSE_IF(wbinvddata_do);
        
        SET(data_ram0_read_do, wbinvdread_do);
        SET(data_ram0_address, { 20'd0, wbinvdread_address, 4'd0 });
        
        SET(data_ram1_read_do, wbinvdread_do);
        SET(data_ram1_address, { 20'd0, wbinvdread_address, 4'd0 });
        
        SET(data_ram2_read_do, wbinvdread_do);
        SET(data_ram2_address, { 20'd0, wbinvdread_address, 4'd0 });
        
        SET(data_ram3_read_do, wbinvdread_do);
        SET(data_ram3_address, { 20'd0, wbinvdread_address, 4'd0 });
    
    ELSE_IF(dcachewrite_do);
        
        SAVE(address,        dcachewrite_address);
        SAVE(cache_disable,  dcachewrite_cache_disable);
        SAVE(length,         { 1'b0, dcachewrite_length });
        
        SAVE(write_through,  dcachewrite_write_through);
        SAVE(write_data,     dcachewrite_data);
        
        SAVE(is_write, `TRUE);
        
        SET(control_ram_read_do);
        SET(control_ram_address, dcachewrite_address);
        
        SET(data_ram0_read_do);
        SET(data_ram0_address, dcachewrite_address);
        
        SET(data_ram1_read_do);
        SET(data_ram1_address, dcachewrite_address);
        
        SET(data_ram2_read_do);
        SET(data_ram2_address, dcachewrite_address);
        
        SET(data_ram3_read_do);
        SET(data_ram3_address, dcachewrite_address);
        
        SET(dcachewrite_done);
        
        SAVE(state, STATE_WRITE_CHECK);
        
    ELSE_IF(dcacheread_do);
        
        SAVE(address,        dcacheread_address);
        SAVE(cache_disable,  dcacheread_cache_disable);
        SAVE(length,         dcacheread_length);
    
        SAVE(is_write, `FALSE);
        
        SET(control_ram_read_do);
        SET(control_ram_address,     dcacheread_address);
        
        SET(data_ram0_read_do);
        SET(data_ram0_address, dcacheread_address);
        
        SET(data_ram1_read_do);
        SET(data_ram1_address, dcacheread_address);
        
        SET(data_ram2_read_do);
        SET(data_ram2_address, dcacheread_address);
        
        SET(data_ram3_read_do);
        SET(data_ram3_address, dcacheread_address);
        
        SAVE(state, STATE_READ_CHECK);
        
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_READ_CHECK);

    IF(matched);
        
        SET(control_ram_write_do);
        SET(control_ram_address,     address);
        SET(control_ram_data,        control_after_match);
        
        SET(dcacheread_data, read_from_line);
        SET(dcacheread_done);
        
        SAVE(state, STATE_IDLE);
    
    ELSE_IF(cache_disable);
        
        SET(readburst_do);
        SET(readburst_address,      address);
        SET(readburst_dword_length, read_burst_dword_length);
        SET(readburst_byte_length,  read_burst_byte_length);
        
        SAVE(state, STATE_READ_BURST);
        
    ELSE_IF(writeback_needed);
        
        SET(dcache_writeline_do);
        SET(dcache_writeline_address, { plru_data_line[147:128], address[11:4], 4'd0 });
        SET(dcache_writeline_line,    plru_data_line[127:0]);
        
        SAVE(state, STATE_WRITE_BACK);
        
    ELSE();
        
        SET(readline_do);
        SET(readline_address, { address[31:4], 4'd0 });
    
        SAVE(state, STATE_READ_LINE);
    ENDIF();
    
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_WRITE_CHECK);

    IF(matched);
        
        SET(control_ram_write_do);
        SET(control_ram_address,     address);
        SET(control_ram_data,        control_after_write_to_existing);
        
        IF(matched_index == 2'd0);
            SET(data_ram0_write_do);
            SET(data_ram0_address,   address);
            SET(data_ram0_data,      line_merged);
        ENDIF();
        
        IF(matched_index == 2'd1);
            SET(data_ram1_write_do);
            SET(data_ram1_address,   address);
            SET(data_ram1_data,      line_merged);
        ENDIF();
        
        IF(matched_index == 2'd2);
            SET(data_ram2_write_do);
            SET(data_ram2_address,   address);
            SET(data_ram2_data,      line_merged);
        ENDIF();
        
        IF(matched_index == 2'd3);
            SET(data_ram3_write_do);
            SET(data_ram3_address,   address);
            SET(data_ram3_data,      line_merged);
        ENDIF();
        
        IF(write_through);
            
            SET(writeburst_do);
            SET(writeburst_address,      address);
            SET(writeburst_dword_length, write_burst_dword_length);
            SET(writeburst_byteenable_0, write_burst_byteenable_0);
            SET(writeburst_byteenable_1, write_burst_byteenable_1);
            SET(writeburst_data,         write_burst_data);
            
            SAVE(state, STATE_WRITE_THROUGH);
            
        ELSE();
            
            SET(dcachetoicache_write_do);
            SET(dcachetoicache_write_address, address);
            
            SAVE(state, STATE_IDLE);
        ENDIF();
    
    ELSE_IF(cache_disable);
        
        SET(writeburst_do);
        SET(writeburst_address,      address);
        SET(writeburst_dword_length, write_burst_dword_length);
        SET(writeburst_byteenable_0, write_burst_byteenable_0);
        SET(writeburst_byteenable_1, write_burst_byteenable_1);
        SET(writeburst_data,         write_burst_data);
        
        SAVE(state, STATE_WRITE_THROUGH);
    
    ELSE_IF(writeback_needed); // cache enabled and full
        
        SET(dcache_writeline_do);
        SET(dcache_writeline_address, { plru_data_line[147:128], address[11:4], 4'd0 });
        SET(dcache_writeline_line,    plru_data_line[127:0]);
        
        SAVE(state, STATE_WRITE_BACK);
    
    ELSE(); // cache enabled and not full
    
        SET(readline_do);
        SET(readline_address, { address[31:4], 4'd0 });
        
        SAVE(state, STATE_READ_LINE);
        
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_READ_BURST);

    IF(readburst_done);
        
        SET(dcacheread_data, read_from_burst);
        SET(dcacheread_done);
        
        SAVE(state, STATE_IDLE);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_WRITE_BACK);

    IF(writeline_done);
        
        SET(readline_do);
        SET(readline_address, { address[31:4], 4'd0 });
        
        SAVE(state, STATE_READ_LINE);
    
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_READ_LINE);

    IF(readline_done);
        
        IF(is_write);
            
            SET(control_ram_write_do);
            SET(control_ram_address,     address);
            SET(control_ram_data,        control_after_write_to_new);
            
            IF(plru_index == 2'd0);
                SET(data_ram0_write_do);
                SET(data_ram0_address,   address);
                SET(data_ram0_data,      line_merged);
            ENDIF();
            
            IF(plru_index == 2'd1);
                SET(data_ram1_write_do);
                SET(data_ram1_address,   address);
                SET(data_ram1_data,      line_merged);
            ENDIF();
            
            IF(plru_index == 2'd2);
                SET(data_ram2_write_do);
                SET(data_ram2_address,   address);
                SET(data_ram2_data,      line_merged);
            ENDIF();
            
            IF(plru_index == 2'd3);
                SET(data_ram3_write_do);
                SET(data_ram3_address,   address);
                SET(data_ram3_data,      line_merged);
            ENDIF();
        
            IF(write_through);
                
                SET(writeburst_do);
                SET(writeburst_address,      address);
                SET(writeburst_dword_length, write_burst_dword_length);
                SET(writeburst_byteenable_0, write_burst_byteenable_0);
                SET(writeburst_byteenable_1, write_burst_byteenable_1);
                SET(writeburst_data,         write_burst_data);
                
                SAVE(state, STATE_WRITE_THROUGH);
            
            ELSE();
            
                SET(dcachetoicache_write_do);
                SET(dcachetoicache_write_address, address);
            
                SAVE(state, STATE_IDLE);
            ENDIF();
            
        ELSE();
        
            SET(control_ram_write_do);
            SET(control_ram_address,     address);
            SET(control_ram_data,        control_after_line_read);
        
            IF(plru_index == 2'd0);
                SET(data_ram0_write_do);
                SET(data_ram0_address,   address);
                SET(data_ram0_data,      readline_line);
            ENDIF();
            
            IF(plru_index == 2'd1);
                SET(data_ram1_write_do);
                SET(data_ram1_address,    address);
                SET(data_ram1_data, readline_line);
            ENDIF();
            
            IF(plru_index == 2'd2);
                SET(data_ram2_write_do);
                SET(data_ram2_address,   address);
                SET(data_ram2_data,      readline_line);
            ENDIF();
            
            IF(plru_index == 2'd3);
                SET(data_ram3_write_do);
                SET(data_ram3_address,   address);
                SET(data_ram3_data,      readline_line);
            ENDIF();
            
            SET(dcacheread_data, read_from_line);
            SET(dcacheread_done);
        
            SAVE(state, STATE_IDLE);
        ENDIF();
        
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_WRITE_THROUGH);

    IF(writeburst_done);
        
        SET(dcachetoicache_write_do);
        SET(dcachetoicache_write_address, address);
        
        SAVE(state, STATE_IDLE);
    ENDIF();
ENDIF();
*/

//------------------------------------------------------------------------------

`include "autogen/dcache.v"

endmodule
