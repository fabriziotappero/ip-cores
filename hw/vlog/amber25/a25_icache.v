//////////////////////////////////////////////////////////////////
//                                                              //
//  L1 Instruction Cache for Amber 25 Core                      //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Synthesizable L1 Instruction Cache.                         //
//  Cache is 2,3,4 or 8 way, 256 line and 16 bytes per line.    //
//  a total of 16KB. The cache is read only. Writes from        //
//  the core to through the data cache.                         //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2011 Authors and OPENCORES.ORG                 //
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
`include "a25_config_defines.vh"

module a25_icache 
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
parameter WAYS              = `A25_ICACHE_WAYS ,

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
input                               i_core_stall,
output                              o_stall,

// Read / Write requests from core
input                               i_select,
input      [31:0]                   i_address,          // registered address from execute
input      [31:0]                   i_address_nxt,      // un-registered version of address from execute stage
input                               i_cache_enable,     // from co-processor 15 configuration register
input                               i_cache_flush,      // from co-processor 15 register

output     [127:0]                  o_read_data,                                                       

// WB Read Request                                                          
output                              o_wb_req,          // Read Request
input      [127:0]                  i_wb_read_data,                 
input                               i_wb_ready
);

`include "a25_localparams.vh"
`include "a25_functions.vh"

// One-hot encoded
localparam       C_INIT   = 0,
                 C_CORE   = 1,
                 C_FILL   = 2,
                 C_INVA   = 3,
                 C_STATES = 4;
                 
localparam [3:0] CS_INIT            = 4'd0,
                 CS_IDLE            = 4'd1,
                 CS_FILL0           = 4'd2,
                 CS_FILL1           = 4'd3,
                 CS_FILL2           = 4'd4,
                 CS_FILL3           = 4'd5,
                 CS_FILL4           = 4'd6,
                 CS_FILL_COMPLETE   = 4'd7,
                 CS_TURN_AROUND     = 4'd8,
                 CS_WRITE_HIT1      = 4'd9,
                 CS_EX_DELETE       = 4'd10;
                 

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

wire [CACHE_ADDR_WIDTH-1:0] data_address;
wire [31:0]                 write_data_word;

wire                        idle_hit;
wire                        read_miss;
wire                        read_miss_fill;
wire                        invalid_read;
wire                        fill_state;

reg  [31:0]                 miss_address = 'd0;
wire [CACHE_LINE_WIDTH-1:0] hit_rdata;

wire                        cache_busy_stall;
wire                        read_stall;

wire                        enable;
wire [CACHE_ADDR_WIDTH-1:0] address;
wire [31:0]                 address_c;
reg  [31:0]                 address_r = 'd0;

reg  [31:0]                 wb_address = 'd0;
wire                        wb_hit;
wire                        read_buf_hit;
reg  [127:0]                read_buf_data_r;
reg  [31:0]                 read_buf_addr_r;
reg                         read_buf_valid_r;
genvar                      i;

// ======================================
// Address to use for cache access
// ======================================
// If currently stalled then the address for the next
// cycle will be the same as it is in the current cycle
//
assign address_c = i_core_stall ? i_address    : 
                                  i_address_nxt; 

assign address   = address_c[CACHE_ADDR32_MSB:CACHE_ADDR32_LSB];


// ======================================
// Outputs
// ======================================
assign o_read_data      = wb_hit       ? i_wb_read_data  : 
                          read_buf_hit ? read_buf_data_r :
                                         hit_rdata ;


// Don't allow the cache to stall the wb i/f for an exclusive access
// The cache needs a couple of cycles to flush a potential copy of the exclusive
// address, but the wb can do the access in parallel. So there is no
// stall in the state CS_EX_DELETE, even though the cache is out of action. 
// This works fine as long as the wb is stalling the core
assign o_stall          = read_stall  || cache_busy_stall;

assign o_wb_req         = read_miss && c_state == CS_IDLE;


// ======================================
// Read Buffer
// ======================================
always@(posedge i_clk)
    if ( i_cache_flush )
        read_buf_valid_r <= 1'd0;
    else if (i_wb_ready && c_state == CS_FILL3)
        begin
        read_buf_data_r  <= i_wb_read_data;
        read_buf_addr_r  <= miss_address;
        read_buf_valid_r <= 1'd1;
        end
    else if (o_wb_req)
        read_buf_valid_r <= 1'd0;
    
    
assign read_buf_hit     = read_buf_valid_r && i_address[31:4] == read_buf_addr_r[31:4];
     
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
        `ifdef A25_CACHE_DEBUG  
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
                
                if ( read_miss ) 
                    c_state <= CS_FILL3; 
               end
                   
                
             CS_FILL3 :
                begin
                // Pick a way to write the cache update into
                // Either pick one of the invalid caches, or if all are valid, then pick
                // one randomly
                select_way  <= next_way; 
                random_num  <= {random_num[2], random_num[1], random_num[0], 
                                 random_num[3]^random_num[2]};
                                 
                // third read of burst of 4
                // wb read request asserted, wait for ack
                if ( i_wb_ready ) 
                    begin
                    c_state     <= CS_FILL_COMPLETE;
                    end
                end
                

             // Write the read fetch data in this cycle
             CS_FILL_COMPLETE : 
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
                
        endcase                       


// ======================================
// Miss Address
// ======================================
always @ ( posedge i_clk )
    if ( c_state == CS_IDLE )
        miss_address <= i_address;


always @ ( posedge i_clk )
    address_r <= address_c;

assign invalid_read = address_r != i_address;


always @(posedge i_clk)
    if ( o_wb_req )
        wb_address <= i_address;
    else if ( i_wb_ready && fill_state )    
        wb_address <= {wb_address[31:4], wb_address[3:2] + 1'd1, 2'd0};
        
assign fill_state       = c_state == CS_FILL3;
assign wb_hit           = i_address == wb_address && i_wb_ready && fill_state;

assign tag_address      = read_miss_fill     ? miss_address      [CACHE_ADDR32_MSB:CACHE_ADDR32_LSB] :
                          source_sel[C_INIT] ? init_count[CACHE_ADDR_WIDTH-1:0]                      :
                                               address                                               ;
                                               

assign data_address     = read_miss_fill     ? miss_address[CACHE_ADDR32_MSB:CACHE_ADDR32_LSB] : 
                                               address                                         ;

                                                          
assign tag_wdata        = read_miss_fill     ? {1'd1, miss_address[31:TAG_ADDR32_LSB]} :
                                               {TAG_WIDTH{1'd0}}                       ;


assign read_miss_fill   = c_state == CS_FILL3 && i_wb_ready;

                          

assign tag_wenable      = read_miss_fill     ? 1'd1  :
                          source_sel[C_INVA] ? 1'd1  :
                          source_sel[C_FILL] ? 1'd1  :
                          source_sel[C_INIT] ? 1'd1  :
                          source_sel[C_CORE] ? 1'd0  :
                                               1'd0  ;

                          
assign enable           = i_select && i_cache_enable;

assign idle_hit         = |data_hit_way;

assign read_miss        = enable && !idle_hit && !invalid_read;

assign read_stall       = enable && !idle_hit && !wb_hit && !read_buf_hit;

assign cache_busy_stall = (c_state == CS_TURN_AROUND  && enable && !read_buf_hit) || c_state == CS_INIT;


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
            .i_write_data               ( i_wb_read_data                ),
            .i_write_enable             ( data_wenable_way[i]           ),
            .i_address                  ( data_address                  ),
            .i_byte_enable              ( {CACHE_LINE_WIDTH/8{1'd1}}    ),
            .o_read_data                ( data_rdata_way[i]             )
            );                                                     


        // Per tag-ram write-enable
        assign tag_wenable_way[i]  = tag_wenable && ( select_way[i] || source_sel[C_INIT] );

        // Per data-ram write-enable
        assign data_wenable_way[i] = ( source_sel[C_FILL] || read_miss_fill ) && select_way[i];

        // Per data-ram idle_hit flag
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
                     c_state == CS_FILL0           ? "CS_FILL0"         :
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
        $display("Set A25_ICACHE_WAYS in a25_config_defines.v to either 2,3,4 or 8");
        end

end
endgenerate
    
//synopsys translate_on
    
endmodule

