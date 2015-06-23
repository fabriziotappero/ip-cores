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

module icache(
    input           clk,
    input           rst_n,
    
    //RESP:
    input           pr_reset,
    //END
    
    //RESP:
    input           icacheread_do,
    input   [31:0]  icacheread_address,
    input   [4:0]   icacheread_length, // takes into account: page size and cs segment limit
    input           icacheread_cache_disable,
    //END
    
    //REQ:
    output              readcode_do,
    input               readcode_done,
    
    output      [31:0]  readcode_address,
    input       [127:0] readcode_line,
    input       [31:0]  readcode_partial,
    input               readcode_partial_done,
    //END
    
    //REQ:
    output              dcachetoicache_accept_do,
    input [31:0]        dcachetoicache_accept_address,
    input               dcachetoicache_accept_empty,
    //END
    
    //REQ:
    output              prefetchfifo_write_do,
    output  [135:0]     prefetchfifo_write_data,
    //END
    
    //REQ:
    output              prefetched_do,
    output [4:0]        prefetched_length,
    //END
    
    //RESP:
    input               invdcode_do,
    output              invdcode_done
    //END
);

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

reg [1:0]   state;
reg [31:0]  address;
reg [4:0]   length;
reg         cache_disable;
reg [11:0]  partial_length;
reg         reset_waiting;

//------------------------------------------------------------------------------

wire [4:0] partial_length_current;

//------------------------------------------------------------------------------

localparam [1:0] STATE_IDLE             = 2'd0;
localparam [1:0] STATE_INVALIDATE_WRITE = 2'd1;
localparam [1:0] STATE_CHECK            = 2'd2;
localparam [1:0] STATE_READ             = 2'd3;

//------------------------------------------------------------------------------

//MIN(partial_length, length_saved)
assign partial_length_current =
    ({ 2'b0, partial_length[2:0] } > length)? length : { 2'b0, partial_length[2:0] };
    

//------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           reset_waiting <= `FALSE;
    else if(pr_reset && state != STATE_IDLE)    reset_waiting <= `TRUE;
    else if(state == STATE_IDLE)                reset_waiting <= `FALSE;
end

//------------------------------------------------------------------------------

wire [127:0] matched_data_line;
wire [6:0]   control_after_invalidate_write;
wire [6:0]   control_after_match;
wire [6:0]   control_after_line_read;
wire         matched;
wire [1:0]   plru_index;

//------------------------------------------------------------------------------

wire [11:0]     length_burst;
wire [11:0]     length_line;
wire [135:0]    prefetch_line;
wire [135:0]    prefetch_partial;

//------------------------------------------------------------------------------

wire        control_ram_read_do;
wire [31:0] control_ram_address;
wire        control_ram_write_do;
wire [6:0]  control_ram_data;
wire [6:0]  control_ram_q;

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

//------------------------------------------------------------------------------

icache_matched icache_matched_inst(
    
    .address    (address),      //input [31:0]
    
    .control    (control_ram_q),    //input [6:0]
    
    .data_0     (data_ram0_q),      //input [147:0]
    .data_1     (data_ram1_q),      //input [147:0]
    .data_2     (data_ram2_q),      //input [147:0]
    .data_3     (data_ram3_q),      //input [147:0]
    
    .matched                            (matched),              //output
    .matched_data_line                  (matched_data_line),    //output [127:0]
    
    .plru_index                         (plru_index),           //output [1:0]
                                   
    .control_after_invalidate_write     (control_after_invalidate_write),   //output [6:0]
    .control_after_match                (control_after_match),              //output [6:0]
    .control_after_line_read            (control_after_line_read)           //output [6:0]
);



icache_read icache_read_inst(
   
    .line           (matched_data_line),        //input [127:0]
    .read_data      (readcode_partial),         //input [31:0]
    .read_length    (partial_length[2:0]),      //input [2:0]
                             
    .address    ((state == STATE_IDLE)? icacheread_address : address),  //input [31:0]
    .length     ((state == STATE_IDLE)? icacheread_length : length),    //input [4:0]
                             
    .length_burst   (length_burst),     //output [11:0]
    .length_line    (length_line),      //output [11:0]
                             
    .prefetch_line      (prefetch_line),    //output [135:0]
    .prefetch_partial   (prefetch_partial)  //output [135:0]
);
    
icache_control_ram icache_control_ram_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .address        (control_ram_address),  //input [31:0]
                                           
    //RESP:
    .read_do        (control_ram_read_do),      //input
    .q              (control_ram_q),            //output [6:0]
    //END
                                           
    //RESP:
    .write_do       (control_ram_write_do),     //input
    .data           (control_ram_data),         //input [6:0]  
    //END
                                           
    //RESP:
    .invdcode_do    (invdcode_do && state == STATE_IDLE),       //input
    .invdcode_done  (invdcode_done)                             //output
    //END
);

cache_data_ram cache_data_ram0_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .address        (data_ram0_address),        //input [31:0]
    
    //RESP:
    .read_do        (data_ram0_read_do),        //input
    .q              (data_ram0_q),              //output [147:0]
    //END
    
    //RESP:
    .write_do       (data_ram0_write_do),       //input
    .data           (data_ram0_data)            //input [127:0]
    //END
);

cache_data_ram cache_data_ram1_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .address        (data_ram1_address),        //input [31:0]
    
    //RESP:
    .read_do        (data_ram1_read_do),        //input
    .q              (data_ram1_q),              //output [147:0]
    //END
    
    //RESP:
    .write_do       (data_ram1_write_do),       //input
    .data           (data_ram1_data)            //input [127:0]
    //END
);

cache_data_ram cache_data_ram2_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .address        (data_ram2_address),        //input [31:0]
    
    //RESP:
    .read_do        (data_ram2_read_do),        //input
    .q              (data_ram2_q),              //output [147:0]
    //END
    
    //RESP:
    .write_do       (data_ram2_write_do),       //input
    .data           (data_ram2_data)            //input [127:0]
    //END
);

cache_data_ram cache_data_ram3_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .address        (data_ram3_address),        //input [31:0]
    
    //RESP:
    .read_do        (data_ram3_read_do),        //input
    .q              (data_ram3_q),              //output [147:0]
    //END
    
    //RESP:
    .write_do       (data_ram3_write_do),       //input
    .data           (data_ram3_data)            //input [127:0]
    //END
);


/*******************************************************************************SCRIPT


IF(state == STATE_IDLE);
    
    SAVE(length,          icacheread_length);
    SAVE(cache_disable,   icacheread_cache_disable);
    
    IF(invdcode_do);
    
        //wait
    
    // check if invalidate needed because of write from dcache
    ELSE_IF(~(dcachetoicache_accept_empty));
        
        SET(control_ram_read_do);
        SET(control_ram_address, dcachetoicache_accept_address);
        
        SET(data_ram0_read_do);
        SET(data_ram0_address, dcachetoicache_accept_address);
        
        SET(data_ram1_read_do);
        SET(data_ram1_address, dcachetoicache_accept_address);
        
        SET(data_ram2_read_do);
        SET(data_ram2_address, dcachetoicache_accept_address);
        
        SET(data_ram3_read_do);
        SET(data_ram3_address, dcachetoicache_accept_address);
        
        SET(dcachetoicache_accept_do);
        
        SAVE(address, dcachetoicache_accept_address);

        SAVE(state, STATE_INVALIDATE_WRITE);
    
    ELSE_IF(~(pr_reset) && icacheread_do && icacheread_length > 5'd0);
    
        SET(control_ram_read_do);
        SET(control_ram_address, icacheread_address);
        
        SET(data_ram0_read_do);
        SET(data_ram0_address, icacheread_address);
        
        SET(data_ram1_read_do);
        SET(data_ram1_address, icacheread_address);
        
        SET(data_ram2_read_do);
        SET(data_ram2_address, icacheread_address);
        
        SET(data_ram3_read_do);
        SET(data_ram3_address, icacheread_address);
    
        SAVE(address, icacheread_address);        
        
        IF(icacheread_do && icacheread_cache_disable);
                    
            SAVE(partial_length, length_burst);

            SAVE(state, STATE_CHECK);
        ENDIF();
        
        IF(icacheread_do && ~(icacheread_cache_disable));
        
            SAVE(partial_length, length_line);

            SAVE(state, STATE_CHECK);
        ENDIF();
    
    ENDIF();
ENDIF();
*/    

/*******************************************************************************SCRIPT


IF(state == STATE_INVALIDATE_WRITE);
    
    SET(control_ram_write_do);
    SET(control_ram_address, address);
    SET(control_ram_data,    control_after_invalidate_write);
    
    SAVE(state, STATE_IDLE);
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_CHECK);

    IF(matched);
        
        IF(pr_reset == `FALSE && reset_waiting == `FALSE);
            
            //write to prefetch fifo
            SET(prefetchfifo_write_do);
            SET(prefetchfifo_write_data, prefetch_line);
            
            //inform prefetch
            SET(prefetched_do);
            SET(prefetched_length, 5'd16 - { 1'b0, address[3:0] });
            
            //update pLRU
            SET(control_ram_write_do);
            SET(control_ram_address, address);
            SET(control_ram_data,    control_after_match);
        ENDIF();
        
        SAVE(state, STATE_IDLE);
        
    ELSE_IF(~(cache_disable)); //cache enabled
 
        SET(readcode_do);
        SET(readcode_address, { address[31:4], 4'd0 });
        
        SAVE(state, STATE_READ);
    
    ELSE(); //cache disabled

        SET(readcode_do);
        SET(readcode_address, { address[31:2], 2'd0 });
        
        SAVE(state, STATE_READ);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_READ);
    
    IF(pr_reset == `FALSE && reset_waiting == `FALSE);
    
        IF(readcode_partial_done || readcode_done);

            IF(partial_length[2:0] > 3'd0 && length > 5'd0);
                //write to prefetch fifo
                SET(prefetchfifo_write_do);
                SET(prefetchfifo_write_data, prefetch_partial);
                
                //inform prefetch
                SET(prefetched_do);
                SET(prefetched_length, partial_length_current);
                
                SAVE(length, length - partial_length_current);
            ENDIF();

            SAVE(partial_length, { 3'd0, partial_length[11:3] });

        ENDIF();
    
        IF(readcode_done && ~(cache_disable));

            //update icache control
            SET(control_ram_write_do);
            SET(control_ram_address, address);
            SET(control_ram_data,    control_after_line_read);
            
            //update icache data
            IF(plru_index[1:0] == 2'd0);
                SET(data_ram0_write_do);
                SET(data_ram0_address,   address);
                SET(data_ram0_data,      readcode_line);
            ENDIF();
            
            IF(plru_index[1:0] == 2'd1);
                SET(data_ram1_write_do);
                SET(data_ram1_address,   address);
                SET(data_ram1_data,      readcode_line);
            ENDIF();
            
            IF(plru_index[1:0] == 2'd2);
                SET(data_ram2_write_do);
                SET(data_ram2_address,   address);
                SET(data_ram2_data,      readcode_line);
            ENDIF();
            
            IF(plru_index[1:0] == 2'd3);
                SET(data_ram3_write_do);
                SET(data_ram3_address,   address);
                SET(data_ram3_data,      readcode_line);
            ENDIF();
            
        ENDIF();
    ENDIF();
    
    IF(readcode_done);
        SAVE(state, STATE_IDLE);
    ENDIF();

ENDIF();
*/

//------------------------------------------------------------------------------

`include "autogen/icache.v"

endmodule
