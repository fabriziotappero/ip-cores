//////////////////////////////////////////////////////////////////
//                                                              //
//  L1 Cache for Amber 2 Core                                   //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Synthesizable L1 Unified Data and Instruction Cache         //
//  Cache is 4-way, 256 line and 16 bytes per line for          //
//  a total of 16KB. The cache policy is write-through and      //
//  read allocate. For swap instructions (SWP and SWPB) the     //
//  location is evicted from the cache and read from main       //
//  memory.                                                     //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////
`include "global_defines.vh"
`include "a23_config_defines.vh"

module a23_cache 
#(

// ---------------------------------------------------------
// Cache Configuration

// Limited to Linux 4k page sizes -> 256 lines
parameter CACHE_LINES          = 256,  

// This cannot be changed without some major surgeory on
// this module                                       
parameter CACHE_WORDS_PER_LINE = 4,

// Changing this parameter is the recommended
// way to change the overall cache size; 2, 4 and 8 ways are supported.
//   2 ways -> 8KB  cache
//   4 ways -> 16KB cache
//   8 ways -> 32KB cache
parameter WAYS              = `A23_CACHE_WAYS ,

// derived configuration parameters
parameter CACHE_ADDR_WIDTH  = log2 ( CACHE_LINES ),                        // = 8
parameter WORD_SEL_WIDTH    = log2 ( CACHE_WORDS_PER_LINE ),               // = 2
parameter TAG_ADDR_WIDTH    = 32 - CACHE_ADDR_WIDTH - WORD_SEL_WIDTH - 2,  // = 20
parameter TAG_WIDTH         = TAG_ADDR_WIDTH + 1,                          // = 21, including Valid flag
parameter CACHE_LINE_WIDTH  = CACHE_WORDS_PER_LINE * 32,                   // = 128
parameter TAG_ADDR32_LSB    = CACHE_ADDR_WIDTH + WORD_SEL_WIDTH + 2,       // = 12
parameter CACHE_ADDR32_MSB  = CACHE_ADDR_WIDTH + WORD_SEL_WIDTH + 2 - 1,   // = 11
parameter CACHE_ADDR32_LSB  =                    WORD_SEL_WIDTH + 2    ,   // = 4
parameter WORD_SEL_MSB      = WORD_SEL_WIDTH + 2 - 1,                      // = 3
parameter WORD_SEL_LSB      =                  2                           // = 2
// ---------------------------------------------------------
)


(
input                               i_clk,

// Read / Write requests from core
input                               i_select,
input                               i_exclusive,        // exclusive access, part of swap instruction
input      [31:0]                   i_write_data,
input                               i_write_enable,     // core issued write request
input      [31:0]                   i_address,          // registered address from execute
input      [31:0]                   i_address_nxt,      // un-registered version of address from execute stage
input      [3:0]                    i_byte_enable,
input                               i_cache_enable,     // from co-processor 15 configuration register
input                               i_cache_flush,      // from co-processor 15 register

output      [31:0]                  o_read_data,                                                       
input                               i_core_stall,
output                              o_stall,

// WB Read Request                                                          
output                              o_wb_req,          // Read Request
input      [31:0]                   i_wb_address,      // wb bus                                 
input      [31:0]                   i_wb_read_data,    // wb bus                              
input                               i_wb_stall         // wb_stb && !wb_ack
);

`include "a23_localparams.vh"
`include "a23_functions.vh"

// One-hot encoded
localparam       C_INIT   = 0,
                 C_CORE   = 1,
                 C_FILL   = 2,
                 C_INVA   = 3,
                 C_STATES = 4;
                 
localparam [3:0] CS_INIT            = 4'd0,
                 CS_IDLE            = 4'd1,
                 CS_FILL1           = 4'd2,
                 CS_FILL2           = 4'd3,
                 CS_FILL3           = 4'd4,
                 CS_FILL4           = 4'd5,
                 CS_FILL_COMPLETE   = 4'd6,
                 CS_TURN_AROUND     = 4'd7,
                 CS_WRITE_HIT1      = 4'd8,
                 CS_EX_DELETE       = 4'd9;
                 

reg  [3:0]                  c_state    = CS_IDLE;
reg  [C_STATES-1:0]         source_sel = 1'd1 << C_CORE;
reg  [CACHE_ADDR_WIDTH:0]   init_count = 'd0;
                 
wire [TAG_WIDTH-1:0]        tag_rdata_way [WAYS-1:0];
wire [CACHE_LINE_WIDTH-1:0] data_rdata_way[WAYS-1:0];
wire [WAYS-1:0]             data_wenable_way;
wire [WAYS-1:0]             data_hit_way;
wire [WAYS-1:0]             tag_wenable_way;
reg  [WAYS-1:0]             select_way = 'd0;
wire [WAYS-1:0]             next_way;
reg  [WAYS-1:0]             valid_bits_r = 'd0;

reg  [3:0]                  random_num = 4'hf;

wire [CACHE_ADDR_WIDTH-1:0] tag_address;
wire [TAG_WIDTH-1:0]        tag_wdata;
wire                        tag_wenable;

wire [CACHE_LINE_WIDTH-1:0] read_miss_wdata;
wire [CACHE_LINE_WIDTH-1:0] write_hit_wdata;
wire [CACHE_LINE_WIDTH-1:0] data_wdata;
wire [CACHE_ADDR_WIDTH-1:0] data_address;
wire [31:0]                 write_data_word;

wire                        hit;
wire                        read_miss;
wire                        write_miss;
wire                        write_hit;

reg  [31:0]                 miss_address = 'd0;
wire [CACHE_LINE_WIDTH-1:0] hit_rdata;

wire                        write_stall;
wire                        cache_busy_stall;
wire                        read_stall;

wire                        enable;
wire [CACHE_ADDR_WIDTH-1:0] address;

reg  [CACHE_LINE_WIDTH-1:0] wb_rdata_burst = 'd0;
reg                         wb_read_buf_valid = 'd0;
reg  [31:0]                 wb_read_buf_address = 'd0;
reg  [31:0]                 wb_read_buf_data = 'd0;
wire                        wb_read_buf_hit;

wire                        exclusive_access;
wire                        ex_read_hit;
reg                         ex_read_hit_r = 'd0;
reg  [WAYS-1:0]             ex_read_hit_way = 'd0;
reg  [CACHE_ADDR_WIDTH-1:0] ex_read_address;
wire                        ex_read_hit_clear;
wire                        ex_read_cache_busy;

genvar                      i;

// ======================================
// Address to use for cache access
// ======================================
// If currently stalled then the address for the next
// cycle will be the same as it is in the current cycle
//
assign address = i_core_stall ? i_address    [CACHE_ADDR32_MSB:CACHE_ADDR32_LSB] :
                                i_address_nxt[CACHE_ADDR32_MSB:CACHE_ADDR32_LSB] ;

// ======================================
// Outputs
// ======================================
assign o_read_data      = wb_read_buf_hit                              ? wb_read_buf_data   :
                          i_address[WORD_SEL_MSB:WORD_SEL_LSB] == 2'd0 ? hit_rdata [31:0]   :
                          i_address[WORD_SEL_MSB:WORD_SEL_LSB] == 2'd1 ? hit_rdata [63:32]  :
                          i_address[WORD_SEL_MSB:WORD_SEL_LSB] == 2'd2 ? hit_rdata [95:64]  :
                                                                         hit_rdata [127:96] ;

// Don't allow the cache to stall the wb i/f for an exclusive access
// The cache needs a couple of cycles to flush a potential copy of the exclusive
// address, but the wb can do the access in parallel. So there is no
// stall in the state CS_EX_DELETE, even though the cache is out of action. 
// This works fine as long as the wb is stalling the core
assign o_stall          = read_stall || write_stall || cache_busy_stall || ex_read_cache_busy;

assign o_wb_req        = (( read_miss || write_miss ) && c_state == CS_IDLE ) || 
                          c_state == CS_WRITE_HIT1;

     
// ======================================
// Cache State Machine
// ======================================

// Little State Machine to Flush Tag RAMS
always @ ( posedge i_clk )
    if ( i_cache_flush )
        begin
        c_state     <= CS_INIT;
        source_sel  <= 1'd1 << C_INIT;
        init_count  <= 'd0;
        `ifdef A23_CACHE_DEBUG  
        `TB_DEBUG_MESSAGE  
        $display("Cache Flush");
        `endif            
        end
    else    
        case ( c_state )
            CS_INIT :
                if ( init_count < CACHE_LINES [CACHE_ADDR_WIDTH:0] )
                    begin
                    init_count  <= init_count + 1'd1;
                    source_sel  <= 1'd1 << C_INIT;
                    end
                else
                    begin
                    source_sel  <= 1'd1 << C_CORE;
                    c_state     <= CS_TURN_AROUND;
                    end 
                       
             CS_IDLE :
                begin
                source_sel  <= 1'd1 << C_CORE;
                
                if ( ex_read_hit || ex_read_hit_r )
                    begin
                    select_way  <= data_hit_way | ex_read_hit_way;
                    c_state     <= CS_EX_DELETE;        
                    source_sel  <= 1'd1 << C_INVA;
                    end
                else if ( read_miss ) 
                    begin
                    // wb read request asserted, wait for ack
                    if ( !i_wb_stall )   
                        c_state <= CS_FILL1; 
                    end           
                else if ( write_hit )
                    c_state <= CS_WRITE_HIT1;        
               end
                   
                   
             CS_FILL1 :
                begin
                // wb read request asserted, wait for ack
                if ( !i_wb_stall )
                    c_state <= CS_FILL2;
                end
                
                
             CS_FILL2 :
                // first read of burst of 4
                // wb read request asserted, wait for ack
                if ( !i_wb_stall )
                    c_state <= CS_FILL3;


             CS_FILL3 :
                // second read of burst of 4
                // wb read request asserted, wait for ack
                if ( !i_wb_stall )
                    c_state <= CS_FILL4;
                
                
             CS_FILL4 :
                // third read of burst of 4
                // wb read request asserted, wait for ack
                if ( !i_wb_stall ) 
                    begin
                    c_state     <= CS_FILL_COMPLETE;
                    source_sel  <= 1'd1 << C_FILL;
                
                    // Pick a way to write the cache update into
                    // Either pick one of the invalid caches, or if all are valid, then pick
                    // one randomly
                    
                    select_way  <= next_way; 
                    random_num  <= {random_num[2], random_num[1], random_num[0], 
                                     random_num[3]^random_num[2]};
                    end


             // Write the read fetch data in this cycle
             CS_FILL_COMPLETE : 
                // fourth read of burst of 4
                // wb read request asserted, wait for ack
                if ( !i_wb_stall )
                    begin
                    // Back to normal cache operations, but
                    // use physical address for first read as
                    // address moved before the stall was asserted for the read_miss
                    // However don't use it if its a non-cached address!
                    source_sel  <= 1'd1 << C_CORE;              
                    c_state     <= CS_TURN_AROUND;    
                    end                                 
                                                        

             // Ignore the tag read data in this cycle   
             // Wait 1 cycle to pre-read the cache and return to normal operation                 
             CS_TURN_AROUND : 
                begin
                c_state     <= CS_IDLE;
                end
                

             // Flush the entry matching an exclusive access         
             CS_EX_DELETE:       
                begin
                `ifdef A23_CACHE_DEBUG    
                `TB_DEBUG_MESSAGE
                $display("Cache deleted Locked entry");
                `endif    
                c_state    <= CS_TURN_AROUND;
                source_sel <= 1'd1 << C_CORE;
                end
                
                                 
             CS_WRITE_HIT1:
                begin
                // wait for an ack on the wb bus to complete the write
                if ( !i_wb_stall )           
                    c_state     <= CS_IDLE;
                    
                end
        endcase                       


// ======================================
// Capture WB Block Read - burst of 4 words
// ======================================
always @ ( posedge i_clk )
    if ( !i_wb_stall )
        wb_rdata_burst <= {i_wb_read_data, wb_rdata_burst[127:32]};


// ======================================
// WB Read Buffer
// ======================================
always @ ( posedge i_clk )
    begin
    if ( c_state == CS_FILL1 || c_state == CS_FILL2 || 
         c_state == CS_FILL3 || c_state == CS_FILL4 )
        begin
        if ( !i_wb_stall )
            begin
            wb_read_buf_valid   <= 1'd1;
            wb_read_buf_address <= i_wb_address;
            wb_read_buf_data    <= i_wb_read_data;
            end
        end
    else    
        wb_read_buf_valid   <= 1'd0;
    end
        

// ======================================
// Miss Address
// ======================================
always @ ( posedge i_clk )
    if ( o_wb_req )
        miss_address <= i_address;
        

// ======================================
// Remember Read-Modify-Write Hit
// ======================================
assign ex_read_hit_clear = c_state == CS_EX_DELETE;

always @ ( posedge i_clk )
    if ( ex_read_hit_clear )
        begin
        ex_read_hit_r   <= 1'd0;
        ex_read_hit_way <= 'd0;
        end
    else if ( ex_read_hit )
        begin
        
        `ifdef A23_CACHE_DEBUG
            `TB_DEBUG_MESSAGE
            $display ("Exclusive access cache hit address 0x%08h", i_address);
        `endif
        
        ex_read_hit_r   <= 1'd1;
        ex_read_hit_way <= data_hit_way;
        end
    else if ( c_state == CS_FILL_COMPLETE && ex_read_hit_r )
        ex_read_hit_way <= select_way;

        
always @ (posedge i_clk)
    if ( ex_read_hit )
        ex_read_address <= i_address[CACHE_ADDR32_MSB:CACHE_ADDR32_LSB];


assign tag_address      = source_sel[C_FILL] ? miss_address      [CACHE_ADDR32_MSB:CACHE_ADDR32_LSB] :
                          source_sel[C_INVA] ? ex_read_address                                       :
                          source_sel[C_INIT] ? init_count[CACHE_ADDR_WIDTH-1:0]                      :
                          source_sel[C_CORE] ? address                                               :
                                               {CACHE_ADDR_WIDTH{1'd0}}                              ;


assign data_address     = write_hit          ? i_address   [CACHE_ADDR32_MSB:CACHE_ADDR32_LSB] :
                          source_sel[C_FILL] ? miss_address[CACHE_ADDR32_MSB:CACHE_ADDR32_LSB] : 
                          source_sel[C_CORE] ? address                                         :
                                               {CACHE_ADDR_WIDTH{1'd0}}                        ;

                                                          
assign tag_wdata        = source_sel[C_FILL] ? {1'd1, miss_address[31:TAG_ADDR32_LSB]} :
                                               {TAG_WIDTH{1'd0}}                       ;


    // Data comes in off the WB bus in wrap4 with the missed data word first
assign data_wdata       = write_hit && c_state == CS_IDLE ? write_hit_wdata : read_miss_wdata;

assign read_miss_wdata  = miss_address[3:2] == 2'd0 ? wb_rdata_burst                              :
                          miss_address[3:2] == 2'd1 ? { wb_rdata_burst[95:0], wb_rdata_burst[127:96] }:
                          miss_address[3:2] == 2'd2 ? { wb_rdata_burst[63:0], wb_rdata_burst[127:64] }:
                                                      { wb_rdata_burst[31:0], wb_rdata_burst[127:32] };


assign write_hit_wdata  = i_address[3:2] == 2'd0 ? {hit_rdata[127:32], write_data_word                   } :
                          i_address[3:2] == 2'd1 ? {hit_rdata[127:64], write_data_word, hit_rdata[31:0]  } :
                          i_address[3:2] == 2'd2 ? {hit_rdata[127:96], write_data_word, hit_rdata[63:0]  } :
                                                   {                   write_data_word, hit_rdata[95:0]  } ;

// Use Byte Enables
assign write_data_word  = i_byte_enable == 4'b0001 ? { o_read_data[31: 8], i_write_data[ 7: 0]                   } :
                          i_byte_enable == 4'b0010 ? { o_read_data[31:16], i_write_data[15: 8], o_read_data[ 7:0]} :
                          i_byte_enable == 4'b0100 ? { o_read_data[31:24], i_write_data[23:16], o_read_data[15:0]} :
                          i_byte_enable == 4'b1000 ? {                     i_write_data[31:24], o_read_data[23:0]} :
                          i_byte_enable == 4'b0011 ? { o_read_data[31:16], i_write_data[15: 0]                   } :
                          i_byte_enable == 4'b1100 ? {                     i_write_data[31:16], o_read_data[15:0]} :
                                                     i_write_data                                                  ;
                          

assign tag_wenable      = source_sel[C_INVA] ? 1'd1  :
                          source_sel[C_FILL] ? 1'd1  :
                          source_sel[C_INIT] ? 1'd1  :
                          source_sel[C_CORE] ? 1'd0  :
                                               1'd0  ;

                          
assign enable           = i_select && i_cache_enable;

assign exclusive_access = i_exclusive && i_cache_enable;


                          // the wb read buffer returns data directly from the wb bus to the
                          // core during a read miss operation
assign wb_read_buf_hit  = enable && wb_read_buf_address == i_address && wb_read_buf_valid;

assign hit              = |data_hit_way;

assign write_hit        = enable &&  i_write_enable && hit;
                                                           
assign write_miss       = enable &&  i_write_enable && !hit && c_state != CS_WRITE_HIT1;
                                                           
assign read_miss        = enable && !i_write_enable && !(hit || wb_read_buf_hit);

                          // Exclusive read hit
assign ex_read_hit      = exclusive_access && !i_write_enable && (hit || wb_read_buf_hit);

                          // Added to fix rare swap bug which occurs when the cache starts
                          // a fill just as the swap instruction starts to execute. The cache
                          // fails to check for a read hit on the swap read cycle.
                          // This signal stalls the core in that case until after the
                          // fill has completed.
assign ex_read_cache_busy = exclusive_access && !i_write_enable && c_state != CS_IDLE;

                          // Need to stall for a write miss to wait for the current wb 
                          // read miss access to complete. Also for a write hit, need 
                          // to stall for 1 cycle while the data cache is being written to
assign write_stall      = ( write_hit  && c_state != CS_WRITE_HIT1 ) ||
                          ( write_miss && ( c_state != CS_IDLE ) )   ||
                           i_wb_stall                                ;

assign read_stall       = read_miss;

                          // Core may or may not be trying to access cache memory during
                          // this phase of the read fetch. It could be doing e.g. a wb access
assign cache_busy_stall = ((c_state == CS_TURN_AROUND || c_state == CS_FILL1) && enable) ||
                           c_state == CS_INIT;


// ======================================
// Instantiate RAMS
// ======================================

generate
    for ( i=0; i<WAYS;i=i+1 ) begin : rams

        // Tag RAMs 
        `ifdef XILINX_SPARTAN6_FPGA
        xs6_sram_256x21_line_en
        `endif

        `ifdef XILINX_VIRTEX6_FPGA
        xv6_sram_256x21_line_en
        `endif

        `ifndef XILINX_FPGA
        generic_sram_line_en 
        `endif

            #(
            .DATA_WIDTH                 ( TAG_WIDTH             ),
            .INITIALIZE_TO_ZERO         ( 1                     ),
            .ADDRESS_WIDTH              ( CACHE_ADDR_WIDTH      ))
        u_tag (
            .i_clk                      ( i_clk                 ),
            .i_write_data               ( tag_wdata             ),
            .i_write_enable             ( tag_wenable_way[i]    ),
            .i_address                  ( tag_address           ),

            .o_read_data                ( tag_rdata_way[i]      )
            );
            
        // Data RAMs 
        `ifdef XILINX_SPARTAN6_FPGA
        xs6_sram_256x128_byte_en
        `endif

        `ifdef XILINX_VIRTEX6_FPGA
        xv6_sram_256x128_byte_en
        `endif

        `ifndef XILINX_FPGA
        generic_sram_byte_en
        `endif

            #(
            .DATA_WIDTH    ( CACHE_LINE_WIDTH) ,
            .ADDRESS_WIDTH ( CACHE_ADDR_WIDTH) )
        u_data (
            .i_clk                      ( i_clk                         ),
            .i_write_data               ( data_wdata                    ),
            .i_write_enable             ( data_wenable_way[i]           ),
            .i_address                  ( data_address                  ),
            .i_byte_enable              ( {CACHE_LINE_WIDTH/8{1'd1}}    ),
            .o_read_data                ( data_rdata_way[i]             )
            );                                                     


        // Per tag-ram write-enable
        assign tag_wenable_way[i]  = tag_wenable && ( select_way[i] || source_sel[C_INIT] );

        // Per data-ram write-enable
        assign data_wenable_way[i] = (source_sel[C_FILL] && select_way[i]) || 
                                     (write_hit && data_hit_way[i] && c_state == CS_IDLE);
        // Per data-ram hit flag
        assign data_hit_way[i]     = tag_rdata_way[i][TAG_WIDTH-1] &&                                                  
                                     tag_rdata_way[i][TAG_ADDR_WIDTH-1:0] == i_address[31:TAG_ADDR32_LSB] &&  
                                     c_state == CS_IDLE;                                                               
    end                                                         
endgenerate


// ======================================
// Register Valid Bits
// ======================================
generate
if ( WAYS == 2 ) begin : valid_bits_2ways

    always @ ( posedge i_clk )
        if ( c_state == CS_IDLE )
            valid_bits_r <= {tag_rdata_way[1][TAG_WIDTH-1], 
                             tag_rdata_way[0][TAG_WIDTH-1]};
                           
end
else if ( WAYS == 3 ) begin : valid_bits_3ways

    always @ ( posedge i_clk )
        if ( c_state == CS_IDLE )
            valid_bits_r <= {tag_rdata_way[2][TAG_WIDTH-1], 
                             tag_rdata_way[1][TAG_WIDTH-1], 
                             tag_rdata_way[0][TAG_WIDTH-1]};
                           
end
else if ( WAYS == 4 ) begin : valid_bits_4ways

    always @ ( posedge i_clk )
        if ( c_state == CS_IDLE )
            valid_bits_r <= {tag_rdata_way[3][TAG_WIDTH-1], 
                             tag_rdata_way[2][TAG_WIDTH-1], 
                             tag_rdata_way[1][TAG_WIDTH-1], 
                             tag_rdata_way[0][TAG_WIDTH-1]};
                           
end
else begin : valid_bits_8ways

    always @ ( posedge i_clk )
        if ( c_state == CS_IDLE )
            valid_bits_r <= {tag_rdata_way[7][TAG_WIDTH-1], 
                             tag_rdata_way[6][TAG_WIDTH-1], 
                             tag_rdata_way[5][TAG_WIDTH-1], 
                             tag_rdata_way[4][TAG_WIDTH-1], 
                             tag_rdata_way[3][TAG_WIDTH-1], 
                             tag_rdata_way[2][TAG_WIDTH-1], 
                             tag_rdata_way[1][TAG_WIDTH-1], 
                             tag_rdata_way[0][TAG_WIDTH-1]};
                           
end
endgenerate


// ======================================
// Select read hit data
// ======================================
generate
if ( WAYS == 2 ) begin : read_data_2ways

    assign hit_rdata    = data_hit_way[0] ? data_rdata_way[0] :
                          data_hit_way[1] ? data_rdata_way[1] :
                                     {CACHE_LINE_WIDTH{1'd1}} ;  // all 1's for debug
                           
end
else if ( WAYS == 3 ) begin : read_data_3ways

    assign hit_rdata    = data_hit_way[0] ? data_rdata_way[0] :
                          data_hit_way[1] ? data_rdata_way[1] :
                          data_hit_way[2] ? data_rdata_way[2] :
                                     {CACHE_LINE_WIDTH{1'd1}} ;  // all 1's for debug
                           
end
else if ( WAYS == 4 ) begin : read_data_4ways

    assign hit_rdata    = data_hit_way[0] ? data_rdata_way[0] :
                          data_hit_way[1] ? data_rdata_way[1] :
                          data_hit_way[2] ? data_rdata_way[2] :
                          data_hit_way[3] ? data_rdata_way[3] :
                                     {CACHE_LINE_WIDTH{1'd1}} ;  // all 1's for debug
                           
end
else begin : read_data_8ways

    assign hit_rdata    = data_hit_way[0] ? data_rdata_way[0] :
                          data_hit_way[1] ? data_rdata_way[1] :
                          data_hit_way[2] ? data_rdata_way[2] :
                          data_hit_way[3] ? data_rdata_way[3] :
                          data_hit_way[4] ? data_rdata_way[4] :
                          data_hit_way[5] ? data_rdata_way[5] :
                          data_hit_way[6] ? data_rdata_way[6] :
                          data_hit_way[7] ? data_rdata_way[7] :
                                     {CACHE_LINE_WIDTH{1'd1}} ;  // all 1's for debug
                           
end
endgenerate


// ======================================
// Function to select the way to use
// for fills
// ======================================
generate
if ( WAYS == 2 ) begin : pick_way_2ways

    assign next_way = pick_way ( valid_bits_r, random_num );

    function [WAYS-1:0] pick_way;
    input [WAYS-1:0] valid_bits;
    input [3:0]      random_num;
    begin
        if (      valid_bits[0] == 1'd0 )
            // way 0 not occupied so use it
            pick_way     = 2'b01;
        else if ( valid_bits[1] == 1'd0 )
            // way 1 not occupied so use it
            pick_way     = 2'b10;
        else
            begin
            // All ways occupied so pick one randomly
            case (random_num[3:1])
                3'd0, 3'd3,
                3'd5, 3'd6: pick_way = 2'b10;
                default:    pick_way = 2'b01;
            endcase
            end
    end
    endfunction
                                                      
end
else if ( WAYS == 3 ) begin : pick_way_3ways

    assign next_way = pick_way ( valid_bits_r, random_num );

    function [WAYS-1:0] pick_way;
    input [WAYS-1:0] valid_bits;
    input [3:0]      random_num;
    begin
        if (      valid_bits[0] == 1'd0 )
            // way 0 not occupied so use it
            pick_way     = 3'b001;
        else if ( valid_bits[1] == 1'd0 )
            // way 1 not occupied so use it
            pick_way     = 3'b010;
        else if ( valid_bits[2] == 1'd0 )
            // way 2 not occupied so use it
            pick_way     = 3'b100;
        else
            begin
            // All ways occupied so pick one randomly
            case (random_num[3:1])
                3'd0, 3'd1, 3'd2: pick_way = 3'b010;
                3'd2, 3'd3, 3'd4: pick_way = 3'b100;
                default:          pick_way = 3'b001;
            endcase
            end
    end
    endfunction
                           
end
else if ( WAYS == 4 ) begin : pick_way_4ways

    assign next_way = pick_way ( valid_bits_r, random_num );

    function [WAYS-1:0] pick_way;
    input [WAYS-1:0] valid_bits;
    input [3:0]      random_num;
    begin
        if (      valid_bits[0] == 1'd0 )
            // way 0 not occupied so use it
            pick_way     = 4'b0001;
        else if ( valid_bits[1] == 1'd0 )
            // way 1 not occupied so use it
            pick_way     = 4'b0010;
        else if ( valid_bits[2] == 1'd0 )
            // way 2 not occupied so use it
            pick_way     = 4'b0100;
        else if ( valid_bits[3] == 1'd0 )
            // way 3 not occupied so use it
            pick_way     = 4'b1000;
        else
            begin
            // All ways occupied so pick one randomly
            case (random_num[3:1])
                3'd0, 3'd1: pick_way = 4'b0100;
                3'd2, 3'd3: pick_way = 4'b1000;
                3'd4, 3'd5: pick_way = 4'b0001;
                default:    pick_way = 4'b0010;
            endcase
            end
    end
    endfunction
                           
end
else begin : pick_way_8ways

    assign next_way = pick_way ( valid_bits_r, random_num );

    function [WAYS-1:0] pick_way;
    input [WAYS-1:0] valid_bits;
    input [3:0]      random_num;
    begin
        if (      valid_bits[0] == 1'd0 )
            // way 0 not occupied so use it
            pick_way     = 8'b00000001;
        else if ( valid_bits[1] == 1'd0 )
            // way 1 not occupied so use it
            pick_way     = 8'b00000010;
        else if ( valid_bits[2] == 1'd0 )
            // way 2 not occupied so use it
            pick_way     = 8'b00000100;
        else if ( valid_bits[3] == 1'd0 )
            // way 3 not occupied so use it
            pick_way     = 8'b00001000;
        else if ( valid_bits[4] == 1'd0 )
            // way 3 not occupied so use it
            pick_way     = 8'b00010000;
        else if ( valid_bits[5] == 1'd0 )
            // way 3 not occupied so use it
            pick_way     = 8'b00100000;
        else if ( valid_bits[6] == 1'd0 )
            // way 3 not occupied so use it
            pick_way     = 8'b01000000;
        else if ( valid_bits[7] == 1'd0 )
            // way 3 not occupied so use it
            pick_way     = 8'b10000000;
        else
            begin
            // All ways occupied so pick one randomly
            case (random_num[3:1])
                3'd0:       pick_way = 8'b00010000;
                3'd1:       pick_way = 8'b00100000;
                3'd2:       pick_way = 8'b01000000;
                3'd3:       pick_way = 8'b10000000;
                3'd4:       pick_way = 8'b00000001;
                3'd5:       pick_way = 8'b00000010;
                3'd6:       pick_way = 8'b00000100;
                default:    pick_way = 8'b00001000;
            endcase
            end
    end
    endfunction
                           
end
endgenerate


// ========================================================
// Debug WB bus - not synthesizable
// ========================================================
//synopsys translate_off
wire    [(6*8)-1:0]     xSOURCE_SEL;
wire    [(20*8)-1:0]    xC_STATE;

assign xSOURCE_SEL = source_sel[C_CORE]            ? "C_CORE"           :
                     source_sel[C_INIT]            ? "C_INIT"           :
                     source_sel[C_FILL]            ? "C_FILL"           :
                     source_sel[C_INVA]            ? "C_INVA"           :
                                                     "UNKNON"           ;
 
assign xC_STATE    = c_state == CS_INIT            ? "CS_INIT"          :
                     c_state == CS_IDLE            ? "CS_IDLE"          :
                     c_state == CS_FILL1           ? "CS_FILL1"         :
                     c_state == CS_FILL2           ? "CS_FILL2"         :
                     c_state == CS_FILL3           ? "CS_FILL3"         :
                     c_state == CS_FILL4           ? "CS_FILL4"         :
                     c_state == CS_FILL_COMPLETE   ? "CS_FILL_COMPLETE" :
                     c_state == CS_EX_DELETE       ? "CS_EX_DELETE"     :
                     c_state == CS_TURN_AROUND     ? "CS_TURN_AROUND"   :
                     c_state == CS_WRITE_HIT1      ? "CS_WRITE_HIT1"    :
                                                     "UNKNOWN"          ;


generate
if ( WAYS == 2 ) begin : check_hit_2ways

    always @( posedge i_clk )
        if ( (data_hit_way[0] + data_hit_way[1] ) > 4'd1 )
            begin
            `TB_ERROR_MESSAGE
            $display("Hit in more than one cache ways!");                                                  
            end
                                                      
end
else if ( WAYS == 3 ) begin : check_hit_3ways

    always @( posedge i_clk )
        if ( (data_hit_way[0] + data_hit_way[1] + data_hit_way[2] ) > 4'd1 )
            begin
            `TB_ERROR_MESSAGE
            $display("Hit in more than one cache ways!");                                                  
            end
                           
end
else if ( WAYS == 4 ) begin : check_hit_4ways

    always @( posedge i_clk )
        if ( (data_hit_way[0] + data_hit_way[1] + 
              data_hit_way[2] + data_hit_way[3] ) > 4'd1 )
            begin
            `TB_ERROR_MESSAGE
            $display("Hit in more than one cache ways!");                                                  
            end
                           
end
else if ( WAYS == 8 )  begin : check_hit_8ways

    always @( posedge i_clk )
        if ( (data_hit_way[0] + data_hit_way[1] + 
              data_hit_way[2] + data_hit_way[3] +
              data_hit_way[4] + data_hit_way[5] +
              data_hit_way[6] + data_hit_way[7] ) > 4'd1 )
            begin
            `TB_ERROR_MESSAGE
            $display("Hit in more than one cache ways!");                                                  
            end
                           
end
else begin : check_hit_nways

    initial
        begin
        `TB_ERROR_MESSAGE
        $display("Unsupported number of ways %0d", WAYS);
        $display("Set A23_CACHE_WAYS in a23_config_defines.v to either 2,3,4 or 8");
        end

end
endgenerate
    
//synopsys translate_on
    
endmodule

