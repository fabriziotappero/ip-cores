//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.1
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module - Data Cache Memory Interface
//-----------------------------------------------------------------
module altor32_dcache_mem_if
( 
    input               clk_i /*verilator public*/, 
    input               rst_i /*verilator public*/, 
    
    // Cache interface
    input [31:0]        address_i /*verilator public*/,
    input [31:0]        data_i /*verilator public*/,
    output reg [31:0]   data_o /*verilator public*/,
    input               fill_i /*verilator public*/,
    input               evict_i /*verilator public*/,
    input  [31:0]       evict_addr_i /*verilator public*/,
    input               rd_single_i /*verilator public*/,
    input [3:0]         wr_single_i /*verilator public*/,
    output reg          done_o /*verilator public*/,

    // Cache memory (fill/evict)
    output reg [31:2]   cache_addr_o /*verilator public*/,
    output reg [31:0]   cache_data_o /*verilator public*/,
    input      [31:0]   cache_data_i /*verilator public*/,
    output reg          cache_wr_o /*verilator public*/,
    
    // Memory interface (slave)
    output reg [31:0]   mem_addr_o /*verilator public*/,
    input [31:0]        mem_data_i /*verilator public*/,
    output reg [31:0]   mem_data_o /*verilator public*/,
    output reg [2:0]    mem_cti_o /*verilator public*/,
    output reg          mem_cyc_o /*verilator public*/,
    output reg          mem_stb_o /*verilator public*/,
    output reg          mem_we_o /*verilator public*/,
    output reg [3:0]    mem_sel_o /*verilator public*/,
    input               mem_stall_i/*verilator public*/,
    input               mem_ack_i/*verilator public*/ 
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter CACHE_LINE_SIZE_WIDTH     = 5;                         /* 5-bits -> 32 entries */
parameter CACHE_LINE_WORDS_IDX_MAX  = CACHE_LINE_SIZE_WIDTH - 2; /* 3-bit -> 8 words */

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------

reg [31:CACHE_LINE_SIZE_WIDTH]  line_address;

reg [CACHE_LINE_WORDS_IDX_MAX-1:0] response_idx;

reg [CACHE_LINE_WORDS_IDX_MAX-1:0]  request_idx;
wire [CACHE_LINE_WORDS_IDX_MAX-1:0] next_request_idx = request_idx + 1'b1;

reg [CACHE_LINE_WORDS_IDX_MAX-1:0]  cache_idx;
wire [CACHE_LINE_WORDS_IDX_MAX-1:0] next_cache_idx = cache_idx + 1'b1;


// Current state
parameter STATE_IDLE        = 0;
parameter STATE_FETCH       = 1;
parameter STATE_WRITE_SETUP = 2;
parameter STATE_WRITE       = 3;
parameter STATE_WRITE_WAIT  = 4;
parameter STATE_MEM_SINGLE  = 5;
parameter STATE_FETCH_WAIT  = 6;

reg [3:0] state;

//-----------------------------------------------------------------
// Next State Logic
//-----------------------------------------------------------------
reg [3:0] next_state_r;
always @ *
begin
    next_state_r = state;

    case (state)
    //-----------------------------------------
    // IDLE
    //-----------------------------------------
    STATE_IDLE :
    begin
        // Perform cache evict (write)     
        if (evict_i)
            next_state_r    = STATE_WRITE_SETUP;
        // Perform cache fill (read)
        else if (fill_i)
            next_state_r    = STATE_FETCH;
        // Read/Write single
        else if (rd_single_i | (|wr_single_i))
            next_state_r    = STATE_MEM_SINGLE;
    end
    //-----------------------------------------
    // FETCH - Fetch line from memory
    //-----------------------------------------
    STATE_FETCH :
    begin
        // Line fetch complete?
        if (~mem_stall_i && request_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
            next_state_r    = STATE_FETCH_WAIT;
    end
    //-----------------------------------------
    // FETCH_WAIT - Wait for read responses
    //-----------------------------------------
    STATE_FETCH_WAIT:
    begin
        // Read from memory complete
        if (mem_ack_i && response_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
            next_state_r = STATE_IDLE;
    end  
    //-----------------------------------------
    // WRITE_SETUP - Wait for data from cache
    //-----------------------------------------
    STATE_WRITE_SETUP :
        next_state_r    = STATE_WRITE;
    //-----------------------------------------
    // WRITE - Write word to memory
    //-----------------------------------------
    STATE_WRITE :
    begin
        // Line write complete?
        if (~mem_stall_i && request_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
            next_state_r = STATE_WRITE_WAIT;
        // Fetch next word for line
        else if (~mem_stall_i | ~mem_stb_o)
            next_state_r = STATE_WRITE_SETUP;
    end
    //-----------------------------------------
    // WRITE_WAIT - Wait for write to complete
    //-----------------------------------------
    STATE_WRITE_WAIT:
    begin
        // Write to memory complete
        if (mem_ack_i && response_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
            next_state_r = STATE_IDLE;
    end            
    //-----------------------------------------
    // MEM_SINGLE - Single access to memory
    //-----------------------------------------
    STATE_MEM_SINGLE:
    begin
        // Data ready from memory?
        if (mem_ack_i)
            next_state_r  = STATE_IDLE;
    end  
    default:
        ;
   endcase
end

// Update state
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
        state   <= STATE_IDLE;
   else
        state   <= next_state_r;
end

//-----------------------------------------------------------------
// Control logic
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        line_address    <= {32-CACHE_LINE_SIZE_WIDTH{1'b0}};
        done_o          <= 1'b0;
        data_o          <= 32'h00000000;
   end
   else
   begin
        done_o          <= 1'b0;
        
        case (state)

            //-----------------------------------------
            // IDLE
            //-----------------------------------------
            STATE_IDLE :
            begin
                // Perform cache evict (write)     
                if (evict_i)
                    line_address <= evict_addr_i[31:CACHE_LINE_SIZE_WIDTH];
                // Perform cache fill (read)
                else if (fill_i)
                    line_address <= address_i[31:CACHE_LINE_SIZE_WIDTH];
            end
            //-----------------------------------------
            // FETCH/WRITE_WAIT - Wait for oustanding responses
            //-----------------------------------------
            STATE_WRITE_WAIT,
            STATE_FETCH_WAIT:
            begin
                // Write to memory complete
                if (mem_ack_i)
                begin
                    // Line write complete?
                    if (response_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
                        done_o      <= 1'b1;
                end
            end            
            //-----------------------------------------
            // MEM_SINGLE - Single access to memory
            //-----------------------------------------
            STATE_MEM_SINGLE:
            begin
                // Data ready from memory?
                if (mem_ack_i)
                begin
                    data_o      <= mem_data_i;
                    done_o      <= 1'b1;
                end
            end          
            default:
                ;
           endcase
   end
end

//-----------------------------------------------------------------
// Cache Read / Write
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        cache_addr_o    <= 30'h00000000;
        cache_data_o    <= 32'h00000000;
        cache_wr_o      <= 1'b0;

        cache_idx       <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};
   end
   else
   begin
        cache_wr_o      <= 1'b0;
        
        case (state)

            //-----------------------------------------
            // IDLE
            //-----------------------------------------
            STATE_IDLE :
            begin
                cache_idx       <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};

                // Perform cache evict (write)     
                if (evict_i)
                begin
                    // Read data from cache
                    cache_addr_o  <= {evict_addr_i[31:CACHE_LINE_SIZE_WIDTH], {CACHE_LINE_WORDS_IDX_MAX{1'b0}}};
                end
            end
            //-----------------------------------------
            // FETCH - Fetch line from memory
            //-----------------------------------------
            STATE_FETCH, 
            STATE_FETCH_WAIT:
            begin
                // Data ready from memory?
                if (mem_ack_i)
                begin
                    // Write data into cache
                    cache_addr_o    <= {line_address, cache_idx};
                    cache_data_o    <= mem_data_i;
                    cache_wr_o      <= 1'b1;

                    cache_idx       <= next_cache_idx;
                end
            end
            //-----------------------------------------
            // WRITE - Write word to memory
            //-----------------------------------------
            STATE_WRITE_SETUP:
            begin

            end
            STATE_WRITE,
            STATE_WRITE_WAIT:
            begin
                if (~mem_stall_i | ~mem_stb_o)
                begin
                    // Setup next word read from cache
                    cache_addr_o <= {line_address, next_cache_idx};
                    cache_idx    <= next_cache_idx;
                end
            end        
            default:
                ;
           endcase
   end
end

//-----------------------------------------------------------------
// Request
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        mem_addr_o      <= 32'h00000000;
        mem_data_o      <= 32'h00000000;
        mem_sel_o       <= 4'h0;
        mem_cti_o       <= 3'b0;
        mem_stb_o       <= 1'b0;
        mem_we_o        <= 1'b0;
        request_idx     <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};
   end
   else
   begin
        if (~mem_stall_i)
        begin
            mem_stb_o   <= 1'b0;

            // TMP
            if (mem_cti_o == 3'b111)
            begin
                //mem_addr_o      <= 32'h00000000;
                mem_data_o      <= 32'h00000000;
                mem_sel_o       <= 4'h0;
                mem_cti_o       <= 3'b0;
                mem_stb_o       <= 1'b0;
                mem_we_o        <= 1'b0;            
            end
        end
        
        case (state)

            //-----------------------------------------
            // IDLE
            //-----------------------------------------
            STATE_IDLE :
            begin                
                request_idx     <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};

                // Perform cache evict (write)     
                if (evict_i)
                begin

                end
                // Perform cache fill (read)
                else if (fill_i)
                begin
                    // Start fetch from memory
                    mem_addr_o   <= {address_i[31:CACHE_LINE_SIZE_WIDTH], {CACHE_LINE_SIZE_WIDTH{1'b0}}};
                    mem_data_o   <= 32'h00000000;
                    mem_sel_o    <= 4'b1111;
                    mem_cti_o    <= 3'b010;
                    mem_stb_o    <= 1'b1;
                    mem_we_o     <= 1'b0;

                    request_idx  <= next_request_idx;
                end                
                // Read single
                else if (rd_single_i)
                begin
                    // Start fetch from memory
                    mem_addr_o   <= address_i;
                    mem_data_o   <= 32'h00000000;
                    mem_sel_o    <= 4'b1111;
                    mem_cti_o    <= 3'b111;
                    mem_stb_o    <= 1'b1;
                    mem_we_o     <= 1'b0; 
                end
                // Write single
                else if (|wr_single_i)
                begin
                    // Start fetch from memory
                    mem_addr_o   <= address_i;
                    mem_data_o   <= data_i;
                    mem_sel_o    <= wr_single_i;
                    mem_cti_o    <= 3'b111;
                    mem_stb_o    <= 1'b1;
                    mem_we_o     <= 1'b1; 
                end
            end
            //-----------------------------------------
            // FETCH - Fetch line from memory
            //-----------------------------------------
            STATE_FETCH :
            begin
                // Previous request accepted?
                if (~mem_stall_i)
                begin
                    // Fetch next word for line
                    mem_addr_o <= {line_address, request_idx, 2'b00};
                    mem_stb_o  <= 1'b1;
                    
                    if (request_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
                        mem_cti_o <= 3'b111;

                    request_idx <= next_request_idx;
                end
            end
            //-----------------------------------------
            // WRITE - Write word to memory
            //-----------------------------------------
            STATE_WRITE :
            begin
                // Memory interface can request command?
                if (~mem_stall_i | ~mem_stb_o)
                begin
                    // Write data into memory from cache
                    mem_addr_o   <= {line_address, request_idx, 2'b00};
                    mem_data_o   <= cache_data_i;
                    mem_sel_o    <= 4'b1111;
                    mem_stb_o    <= 1'b1;
                    mem_we_o     <= 1'b1;
                    
                    if (request_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
                        mem_cti_o <= 3'b111;
                    else
                        mem_cti_o <= 3'b010;

                    request_idx <= next_request_idx;
                end                
            end         
            default:
                ;
           endcase
   end
end

//-----------------------------------------------------------------
// Memory Response Counter
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
        response_idx    <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};
   else
   begin
        case (state)

            //-----------------------------------------
            // IDLE
            //-----------------------------------------
            STATE_IDLE :
            begin
                response_idx    <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};         
            end
            //-----------------------------------------
            // FETCH - Fetch line from memory
            //-----------------------------------------
            STATE_FETCH,
            STATE_FETCH_WAIT :
            begin
                // Data ready from memory?
                if (mem_ack_i)
                    response_idx <= response_idx + 1'b1;
            end
            //-----------------------------------------
            // WRITE_WAIT - Wait for write to complete
            //-----------------------------------------
            STATE_WRITE,
            STATE_WRITE_SETUP,
            STATE_WRITE_WAIT:
            begin
                // Write to memory complete
                if (mem_ack_i)
                    response_idx <= response_idx + 1'b1;
            end
            default:
                ;
           endcase
   end
end

//-----------------------------------------------------------------
// CYC_O
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
        mem_cyc_o       <= 1'b0;
   else
   begin
        case (state)

            //-----------------------------------------
            // IDLE
            //-----------------------------------------
            STATE_IDLE :
            begin
                // Perform cache evict (write)     
                if (evict_i)
                begin

                end
                // Perform cache fill (read)
                else if (fill_i)
                    mem_cyc_o    <= 1'b1;
                // Read single
                else if (rd_single_i)
                    mem_cyc_o    <= 1'b1;
                // Write single
                else if (|wr_single_i)
                    mem_cyc_o    <= 1'b1;
            end
            //-----------------------------------------
            // FETCH - Fetch line from memory
            //-----------------------------------------
            STATE_FETCH :
            begin
                // Data ready from memory?
                if (mem_ack_i && response_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
                    mem_cyc_o   <= 1'b0;
            end
            //-----------------------------------------
            // WRITE - Write word to memory
            //-----------------------------------------
            STATE_WRITE :
            begin
                // Write data into memory from cache
                mem_cyc_o    <= 1'b1;
            end            
            //-----------------------------------------
            // FETCH/WRITE_WAIT - Wait for responses
            //-----------------------------------------
            STATE_WRITE_WAIT,
            STATE_FETCH_WAIT:
            begin
                // Write to memory complete
                if (mem_ack_i && response_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
                    mem_cyc_o   <= 1'b0;
            end            
            //-----------------------------------------
            // MEM_SINGLE - Single access to memory
            //-----------------------------------------
            STATE_MEM_SINGLE:
            begin
                // Data ready from memory?
                if (mem_ack_i)
                    mem_cyc_o   <= 1'b0;
            end        
            default:
                ;
           endcase
   end
end

endmodule
