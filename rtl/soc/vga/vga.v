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

module vga(
    input               clk_26,
    input               rst_n,
    
    //avalon slave for system overlay
    input       [7:0]   sys_address,
    input               sys_read,
    output      [31:0]  sys_readdata,
    input               sys_write,
    input       [31:0]  sys_writedata,
    
    //avalon slave vga io
    input       [3:0]   io_b_address,
    input               io_b_read,
    output      [7:0]   io_b_readdata,
    input               io_b_write,
    input       [7:0]   io_b_writedata,
    
    //avalon slave vga io
    input       [3:0]   io_c_address,
    input               io_c_read,
    output      [7:0]   io_c_readdata,
    input               io_c_write,
    input       [7:0]   io_c_writedata,
    
    //avalon slave vga io
    input       [3:0]   io_d_address,
    input               io_d_read,
    output      [7:0]   io_d_readdata,
    input               io_d_write,
    input       [7:0]   io_d_writedata,
    
    //avalon slave vga memory
    input       [16:0]  mem_address,
    input               mem_read,
    output      [7:0]   mem_readdata,
    input               mem_write,
    input       [7:0]   mem_writedata,
    
    //vga
    output              vga_clock,
    output              vga_sync_n,
    output              vga_blank_n,
    output              vga_horiz_sync,
    output              vga_vert_sync,
    
    output      [7:0]   vga_r,
    output      [7:0]   vga_g,
    output      [7:0]   vga_b
);

//------------------------------------------------------------------------------

//not needed sys_read_valid

reg io_b_read_last;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) io_b_read_last <= 1'b0; else if(io_b_read_last) io_b_read_last <= 1'b0; else io_b_read_last <= io_b_read; end 
wire io_b_read_valid = io_b_read && io_b_read_last == 1'b0;

reg io_c_read_last;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) io_c_read_last <= 1'b0; else if(io_c_read_last) io_c_read_last <= 1'b0; else io_c_read_last <= io_c_read; end 
wire io_c_read_valid = io_c_read && io_c_read_last == 1'b0;

reg io_d_read_last;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) io_d_read_last <= 1'b0; else if(io_d_read_last) io_d_read_last <= 1'b0; else io_d_read_last <= io_d_read; end 
wire io_d_read_valid = io_d_read && io_d_read_last == 1'b0;

reg mem_read_last;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) mem_read_last <= 1'b0; else if(mem_read_last) mem_read_last <= 1'b0; else mem_read_last <= mem_read; end 
wire mem_read_valid = mem_read && mem_read_last == 1'b0;

//------------------------------------------------------------------------------

wire [7:0] io_writedata =
    (io_b_write)?   io_b_writedata :
    (io_c_write)?   io_c_writedata :
                    io_d_writedata;

//------------------------------------------------------------------------------ sequencer io

reg seq_async_reset_n;
reg seq_sync_reset_n;

reg seq_8dot_char;

reg seq_dotclock_divided;

reg seq_screen_disable; //sync works, data blank

reg [3:0] seq_map_write_enable;

reg [2:0] seq_char_map_a; // depends on seq_access_256kb
reg [2:0] seq_char_map_b; // depends on seq_access_256kb

reg seq_access_256kb;
reg seq_access_odd_even_disabled;
reg seq_access_chain4;

// not implemented sequencer regs: 
reg seq_not_impl_shift_load_2;
reg seq_not_impl_shift_load_4;

//------------------------------------------------------------------------------

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_async_reset_n <= 1'b1; else if(seq_io_write && seq_io_index == 3'd0) seq_async_reset_n <= io_writedata[0]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_sync_reset_n  <= 1'b1; else if(seq_io_write && seq_io_index == 3'd0) seq_sync_reset_n  <= io_writedata[1]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_8dot_char        <= 1'b1; else if(seq_io_write && seq_io_index == 3'd1) seq_8dot_char        <= io_writedata[0]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_dotclock_divided <= 1'b0; else if(seq_io_write && seq_io_index == 3'd1) seq_dotclock_divided <= io_writedata[3]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_screen_disable   <= 1'b0; else if(seq_io_write && seq_io_index == 3'd1) seq_screen_disable   <= io_writedata[5]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_map_write_enable <= 4'hF; else if(seq_io_write && seq_io_index == 3'd2) seq_map_write_enable <= io_writedata[3:0]; end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                               seq_char_map_a <= 3'd0;
    else if(seq_io_write && seq_io_index == 3'd3)   seq_char_map_a <= { io_writedata[5], io_writedata[3:2] };
    else if(seq_sync_reset_n || seq_async_reset_n)  seq_char_map_a <= 3'd0;
end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                               seq_char_map_b <= 3'd0;
    else if(seq_io_write && seq_io_index == 3'd3)   seq_char_map_b <= { io_writedata[4], io_writedata[1:0] };
    else if(seq_sync_reset_n || seq_async_reset_n)  seq_char_map_b <= 3'd0;
end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_access_256kb             <= 1'b1; else if(seq_io_write && seq_io_index == 3'd4) seq_access_256kb             <= io_writedata[1]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_access_odd_even_disabled <= 1'b1; else if(seq_io_write && seq_io_index == 3'd4) seq_access_odd_even_disabled <= io_writedata[2]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_access_chain4            <= 1'b1; else if(seq_io_write && seq_io_index == 3'd4) seq_access_chain4            <= io_writedata[3]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_not_impl_shift_load_2 <= 1'b0; else if(seq_io_write && seq_io_index == 3'd1) seq_not_impl_shift_load_2 <= io_writedata[2]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_not_impl_shift_load_4 <= 1'b0; else if(seq_io_write && seq_io_index == 3'd1) seq_not_impl_shift_load_4 <= io_writedata[4]; end

//------------------------------------------------------------------------------

wire [7:0] host_io_read_seq =
    (seq_io_index == 3'd0)?     { 6'd0, seq_sync_reset_n, seq_async_reset_n } :
    (seq_io_index == 3'd1)?     { 2'd0, seq_screen_disable, seq_not_impl_shift_load_4, seq_dotclock_divided, seq_not_impl_shift_load_2, 1'b0, seq_8dot_char } :
    (seq_io_index == 3'd2)?     { 4'd0, seq_map_write_enable } :
    (seq_io_index == 3'd3)?     { 2'd0, seq_char_map_a[2], seq_char_map_b[2], seq_char_map_a[1:0], seq_char_map_b[1:0] } :
    (seq_io_index == 3'd4)?     { 4'd0, seq_access_chain4, seq_access_odd_even_disabled, seq_access_256kb, 1'b0 } :
                                8'h00;

//------------------------------------------------------------------------------ crtc io

reg [7:0]   crtc_horizontal_total;
reg [7:0]   crtc_horizontal_display_size;
reg [7:0]   crtc_horizontal_blanking_start;
reg [5:0]   crtc_horizontal_blanking_end;
reg [7:0]   crtc_horizontal_retrace_start;
reg [1:0]   crtc_horizontal_retrace_skew;
reg [4:0]   crtc_horizontal_retrace_end;

reg [9:0]   crtc_vertical_total;
reg [9:0]   crtc_vertical_retrace_start;
reg [3:0]   crtc_vertical_retrace_end;
reg [9:0]   crtc_vertical_display_size;
reg [9:0]   crtc_vertical_blanking_start;
reg [7:0]   crtc_vertical_blanking_end;

reg         crtc_vertical_doublescan;

reg [4:0]   crtc_row_preset;
reg [4:0]   crtc_row_max;
reg [4:0]   crtc_row_underline;

reg         crtc_cursor_off;
reg [4:0]   crtc_cursor_row_start;
reg [4:0]   crtc_cursor_row_end;
reg [1:0]   crtc_cursor_skew;

reg [15:0]  crtc_address_start;
reg [1:0]   crtc_address_byte_panning;
reg [7:0]   crtc_address_offset;
reg [15:0]  crtc_address_cursor;
reg         crtc_address_doubleword;
reg         crtc_address_byte;
reg         crtc_address_bit0;
reg         crtc_address_bit13;
reg         crtc_address_bit14;

reg         crtc_enable_sync;

reg [9:0]   crtc_line_compare;

reg         crtc_protect;

//not implemented crtc regs:
reg [1:0]   crtc_not_impl_display_enable_skew;
reg         crtc_not_impl_clear_vert_int;
reg         crtc_not_impl_enable_vert_int;
reg         crtc_not_impl_5_refresh_cycles;
reg         crtc_not_impl_scan_line_clk_div_2;
reg         crtc_not_impl_address_clk_div_2;
reg         crtc_not_impl_address_clk_div_4;

//------------------------------------------------------------------------------

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_horizontal_total          <= 8'd95; else if(crtc_io_write && crtc_io_index == 5'h00) crtc_horizontal_total          <= io_writedata[7:0]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_horizontal_display_size   <= 8'd79; else if(crtc_io_write && crtc_io_index == 5'h01) crtc_horizontal_display_size   <= io_writedata[7:0]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_horizontal_blanking_start <= 8'd80; else if(crtc_io_write && crtc_io_index == 5'h02) crtc_horizontal_blanking_start <= io_writedata[7:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_not_impl_display_enable_skew <= 2'd0; else if(crtc_io_write && crtc_io_index == 5'h03) crtc_not_impl_display_enable_skew <= io_writedata[6:5]; end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                   crtc_horizontal_blanking_end <= 6'd34;
    else if(crtc_io_write && crtc_io_index == 5'h03)    crtc_horizontal_blanking_end <= { crtc_horizontal_blanking_end[5], io_writedata[4:0] };
    else if(crtc_io_write && crtc_io_index == 5'h05)    crtc_horizontal_blanking_end <= { io_writedata[7], crtc_horizontal_blanking_end[4:0] };
end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_horizontal_retrace_start <= 8'd84; else if(crtc_io_write && crtc_io_index == 5'h04) crtc_horizontal_retrace_start <= io_writedata[7:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_horizontal_retrace_skew <= 2'd0; else if(crtc_io_write && crtc_io_index == 5'h05) crtc_horizontal_retrace_skew <= io_writedata[6:5]; end        
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_horizontal_retrace_end  <= 5'd0; else if(crtc_io_write && crtc_io_index == 5'h05) crtc_horizontal_retrace_end  <= io_writedata[4:0]; end         
        
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                   crtc_vertical_total <= 10'd447;
    else if(crtc_io_write && crtc_io_index == 5'h06)    crtc_vertical_total <= { crtc_vertical_total[9:8], io_writedata[7:0] };
    else if(crtc_io_write && crtc_io_index == 5'h07)    crtc_vertical_total <= { io_writedata[5], io_writedata[0], crtc_vertical_total[7:0] };
end        
        
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                   crtc_vertical_retrace_start <= 10'd412;
    else if(crtc_io_write && crtc_io_index == 5'h10)    crtc_vertical_retrace_start <= { crtc_vertical_retrace_start[9:8], io_writedata[7:0] };
    else if(crtc_io_write && crtc_io_index == 5'h07)    crtc_vertical_retrace_start <= { io_writedata[7], io_writedata[2], crtc_vertical_retrace_start[7:0] };
end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                   crtc_vertical_display_size <= 10'd399;
    else if(crtc_io_write && crtc_io_index == 5'h12)    crtc_vertical_display_size <= { crtc_vertical_display_size[9:8], io_writedata[7:0] };
    else if(crtc_io_write && crtc_io_index == 5'h07)    crtc_vertical_display_size <= { io_writedata[6], io_writedata[1], crtc_vertical_display_size[7:0] };
end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                           crtc_line_compare <= 10'd1023;
    else if(crtc_io_write_compare && crtc_io_index == 5'h18)    crtc_line_compare <= { crtc_line_compare[9:8], io_writedata[7:0] };
    else if(crtc_io_write_compare && crtc_io_index == 5'h07)    crtc_line_compare <= { crtc_line_compare[9], io_writedata[4], crtc_line_compare[7:0] };
    else if(crtc_io_write_compare && crtc_io_index == 5'h09)    crtc_line_compare <= { io_writedata[6], crtc_line_compare[8:0] };
end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                   crtc_vertical_blanking_start <= 10'd406;
    else if(crtc_io_write && crtc_io_index == 5'h15)    crtc_vertical_blanking_start <= { crtc_vertical_blanking_start[9:8], io_writedata[7:0] };
    else if(crtc_io_write && crtc_io_index == 5'h07)    crtc_vertical_blanking_start <= { crtc_vertical_blanking_start[9], io_writedata[3], crtc_vertical_blanking_start[7:0] };
    else if(crtc_io_write && crtc_io_index == 5'h09)    crtc_vertical_blanking_start <= { io_writedata[5], crtc_vertical_blanking_start[8:0] };
end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_address_byte_panning <= 2'd0; else if(crtc_io_write && crtc_io_index == 5'h08) crtc_address_byte_panning <= io_writedata[6:5]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_row_preset           <= 5'd0; else if(crtc_io_write && crtc_io_index == 5'h08) crtc_row_preset           <= io_writedata[4:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_vertical_doublescan  <= 1'd0; else if(crtc_io_write && crtc_io_index == 5'h09) crtc_vertical_doublescan  <= io_writedata[7]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_row_max              <= 5'd1; else if(crtc_io_write && crtc_io_index == 5'h09) crtc_row_max              <= io_writedata[4:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_cursor_off           <= 1'd0; else if(crtc_io_write && crtc_io_index == 5'h0A) crtc_cursor_off           <= io_writedata[5]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_cursor_row_start     <= 5'd0; else if(crtc_io_write && crtc_io_index == 5'h0A) crtc_cursor_row_start     <= io_writedata[4:0]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_cursor_skew          <= 2'd0; else if(crtc_io_write && crtc_io_index == 5'h0B) crtc_cursor_skew          <= io_writedata[6:5]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_cursor_row_end       <= 5'd0; else if(crtc_io_write && crtc_io_index == 5'h0B) crtc_cursor_row_end       <= io_writedata[4:0]; end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                   crtc_address_start <= 16'd0;
    else if(crtc_io_write && crtc_io_index == 5'h0C)    crtc_address_start <= { io_writedata[7:0], crtc_address_start[7:0] };
    else if(crtc_io_write && crtc_io_index == 5'h0D)    crtc_address_start <= { crtc_address_start[15:8], io_writedata[7:0] };
end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                   crtc_address_cursor <= 16'd0;
    else if(crtc_io_write && crtc_io_index == 5'h0E)    crtc_address_cursor <= { io_writedata[7:0], crtc_address_cursor[7:0] };
    else if(crtc_io_write && crtc_io_index == 5'h0F)    crtc_address_cursor <= { crtc_address_cursor[15:8], io_writedata[7:0] };
end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_protect                   <= 1'd1;  else if(crtc_io_write && crtc_io_index == 5'h11) crtc_protect                   <= io_writedata[7]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_not_impl_5_refresh_cycles <= 1'd0;  else if(crtc_io_write && crtc_io_index == 5'h11) crtc_not_impl_5_refresh_cycles <= io_writedata[6]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_not_impl_enable_vert_int  <= 1'd0;  else if(crtc_io_write && crtc_io_index == 5'h11) crtc_not_impl_enable_vert_int  <= io_writedata[5]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_not_impl_clear_vert_int   <= 1'd0;  else if(crtc_io_write && crtc_io_index == 5'h11) crtc_not_impl_clear_vert_int   <= io_writedata[4]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_vertical_retrace_end      <= 4'd14; else if(crtc_io_write && crtc_io_index == 5'h11) crtc_vertical_retrace_end      <= io_writedata[3:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_address_offset            <= 8'd40; else if(crtc_io_write && crtc_io_index == 5'h13) crtc_address_offset            <= io_writedata[7:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_address_doubleword         <= 1'b1; else if(crtc_io_write && crtc_io_index == 5'h14) crtc_address_doubleword        <= io_writedata[6]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_not_impl_address_clk_div_4 <= 1'b0; else if(crtc_io_write && crtc_io_index == 5'h14) crtc_not_impl_address_clk_div_4<= io_writedata[5]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_row_underline              <= 5'd0; else if(crtc_io_write && crtc_io_index == 5'h14) crtc_row_underline             <= io_writedata[4:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_vertical_blanking_end <= 8'd185; else if(crtc_io_write && crtc_io_index == 5'h16) crtc_vertical_blanking_end <= io_writedata[7:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_enable_sync                  <= 1'd1;  else if(crtc_io_write && crtc_io_index == 5'h17) crtc_enable_sync                  <= io_writedata[7]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_address_byte                 <= 1'd0;  else if(crtc_io_write && crtc_io_index == 5'h17) crtc_address_byte                 <= io_writedata[6]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_address_bit0                 <= 1'd1;  else if(crtc_io_write && crtc_io_index == 5'h17) crtc_address_bit0                 <= io_writedata[5]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_not_impl_address_clk_div_2   <= 1'd0;  else if(crtc_io_write && crtc_io_index == 5'h17) crtc_not_impl_address_clk_div_2   <= io_writedata[3]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_not_impl_scan_line_clk_div_2 <= 1'd0;  else if(crtc_io_write && crtc_io_index == 5'h17) crtc_not_impl_scan_line_clk_div_2 <= io_writedata[2]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_address_bit14                <= 1'd1;  else if(crtc_io_write && crtc_io_index == 5'h17) crtc_address_bit14                <= io_writedata[1]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) crtc_address_bit13                <= 1'd1;  else if(crtc_io_write && crtc_io_index == 5'h17) crtc_address_bit13                <= io_writedata[0]; end

//------------------------------------------------------------------------------

wire [7:0] host_io_read_crtc =
    (crtc_io_index == 5'h00)?       crtc_horizontal_total :
    (crtc_io_index == 5'h01)?       crtc_horizontal_display_size :
    (crtc_io_index == 5'h02)?       crtc_horizontal_blanking_start :
    (crtc_io_index == 5'h03)?       { 1'b1, crtc_not_impl_display_enable_skew, crtc_horizontal_blanking_end[4:0] } :
    (crtc_io_index == 5'h04)?       crtc_horizontal_retrace_start :
    (crtc_io_index == 5'h05)?       { crtc_horizontal_blanking_end[5], crtc_horizontal_retrace_skew, crtc_horizontal_retrace_end } :
    (crtc_io_index == 5'h06)?       crtc_vertical_total[7:0] :
    (crtc_io_index == 5'h07)?       { crtc_vertical_retrace_start[9], crtc_vertical_display_size[9], crtc_vertical_total[9], crtc_line_compare[8], crtc_vertical_blanking_start[8],
                                      crtc_vertical_retrace_start[8], crtc_vertical_display_size[8], crtc_vertical_total[8] } :
    (crtc_io_index == 5'h08)?       { 1'b0, crtc_address_byte_panning, crtc_row_preset } :
    (crtc_io_index == 5'h09)?       { crtc_vertical_doublescan, crtc_line_compare[9], crtc_vertical_blanking_start[9], crtc_row_max } :
    (crtc_io_index == 5'h0A)?       { 2'b0, crtc_cursor_off, crtc_cursor_row_start } :
    (crtc_io_index == 5'h0B)?       { 1'b0, crtc_cursor_skew, crtc_cursor_row_end } :
    (crtc_io_index == 5'h0C)?       crtc_address_start[15:8] :
    (crtc_io_index == 5'h0D)?       crtc_address_start[7:0] :
    (crtc_io_index == 5'h0E)?       crtc_address_cursor[15:8] :
    (crtc_io_index == 5'h0F)?       crtc_address_cursor[7:0] :
    (crtc_io_index == 5'h10)?       crtc_vertical_retrace_start[7:0] :
    (crtc_io_index == 5'h11)?       { crtc_protect, crtc_not_impl_5_refresh_cycles, crtc_not_impl_enable_vert_int, crtc_not_impl_clear_vert_int, crtc_vertical_retrace_end } :
    (crtc_io_index == 5'h12)?       crtc_vertical_display_size[7:0] :
    (crtc_io_index == 5'h13)?       crtc_address_offset :
    (crtc_io_index == 5'h14)?       { 1'b0, crtc_address_doubleword, crtc_not_impl_address_clk_div_4, crtc_row_underline } :
    (crtc_io_index == 5'h15)?       crtc_vertical_blanking_start[7:0] :
    (crtc_io_index == 5'h16)?       crtc_vertical_blanking_end :
    (crtc_io_index == 5'h17)?       { crtc_enable_sync, crtc_address_byte, crtc_address_bit0, 1'b0, crtc_not_impl_address_clk_div_2, crtc_not_impl_scan_line_clk_div_2, crtc_address_bit14, crtc_address_bit13 } :
    (crtc_io_index == 5'h18)?       crtc_line_compare[7:0] :
                                    8'h00;

//------------------------------------------------------------------------------ graphic io                                    
                                    
reg [3:0] graph_color_compare_map;
reg [3:0] graph_color_compare_dont_care;

reg [3:0] graph_write_set_map;
reg [3:0] graph_write_enable_map;
reg [1:0] graph_write_function;
reg [2:0] graph_write_rotate;
reg [7:0] graph_write_mask;
reg [1:0] graph_write_mode;

reg [1:0] graph_read_map_select;
reg       graph_read_mode;

reg [1:0] graph_shift_mode;

reg [1:0] graph_system_memory;

//not implemented graphic regs:
reg       graph_not_impl_chain_odd_even;
reg       graph_not_impl_host_odd_even;
reg       graph_not_impl_graphic_mode;

//------------------------------------------------------------------------------

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_write_set_map     <= 4'd0; else if(graph_io_write && graph_io_index == 4'd0) graph_write_set_map     <= io_writedata[3:0]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_write_enable_map  <= 4'd0; else if(graph_io_write && graph_io_index == 4'd1) graph_write_enable_map  <= io_writedata[3:0]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_color_compare_map <= 4'd0; else if(graph_io_write && graph_io_index == 4'd2) graph_color_compare_map <= io_writedata[3:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_write_function <= 2'd0; else if(graph_io_write && graph_io_index == 4'd3) graph_write_function <= io_writedata[4:3]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_write_rotate   <= 3'd0; else if(graph_io_write && graph_io_index == 4'd3) graph_write_rotate   <= io_writedata[2:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_read_map_select<= 2'd0; else if(graph_io_write && graph_io_index == 4'd4) graph_read_map_select <= io_writedata[1:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_shift_mode             <= 2'd2; else if(graph_io_write && graph_io_index == 4'd5) graph_shift_mode             <= io_writedata[6:5]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_not_impl_host_odd_even <= 1'd0; else if(graph_io_write && graph_io_index == 4'd5) graph_not_impl_host_odd_even <= io_writedata[4]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_read_mode              <= 1'd0; else if(graph_io_write && graph_io_index == 4'd5) graph_read_mode              <= io_writedata[3]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_write_mode             <= 2'd0; else if(graph_io_write && graph_io_index == 4'd5) graph_write_mode             <= io_writedata[1:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_system_memory           <= 2'd1; else if(graph_io_write && graph_io_index == 4'd6) graph_system_memory           <= io_writedata[3:2]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_not_impl_chain_odd_even <= 1'd0; else if(graph_io_write && graph_io_index == 4'd6) graph_not_impl_chain_odd_even <= io_writedata[1]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_not_impl_graphic_mode   <= 1'd1; else if(graph_io_write && graph_io_index == 4'd6) graph_not_impl_graphic_mode   <= io_writedata[0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_color_compare_dont_care <= 4'hF; else if(graph_io_write && graph_io_index == 4'd7) graph_color_compare_dont_care <= io_writedata[3:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_write_mask <= 8'hFF; else if(graph_io_write && graph_io_index == 4'd8) graph_write_mask <= io_writedata[7:0]; end

//------------------------------------------------------------------------------

wire [7:0] host_io_read_graph =
    (graph_io_index == 4'd0)?       { 4'b0, graph_write_set_map } :
    (graph_io_index == 4'd1)?       { 4'b0, graph_write_enable_map } :
    (graph_io_index == 4'd2)?       { 4'b0, graph_color_compare_map } :
    (graph_io_index == 4'd3)?       { 3'b0, graph_write_function, graph_write_rotate } :
    (graph_io_index == 4'd4)?       { 6'd0, graph_read_map_select } :
    (graph_io_index == 4'd5)?       { 1'b0, graph_shift_mode, graph_not_impl_host_odd_even, graph_read_mode, 1'b0, graph_write_mode } :
    (graph_io_index == 4'd6)?       { 4'd0, graph_system_memory, graph_not_impl_chain_odd_even, graph_not_impl_graphic_mode } :
    (graph_io_index == 4'd7)?       { 4'd0, graph_color_compare_dont_care } :
    (graph_io_index == 4'd8)?       graph_write_mask :
                                    8'h00;

//------------------------------------------------------------------------------ attribute io

reg       attrib_color_8bit_enable;

reg       attrib_color_bit5_4_enable;
reg [1:0] attrib_color_bit7_6_value;
reg [1:0] attrib_color_bit5_4_value;

reg       attrib_panning_after_compare_match;

reg [3:0] attrib_panning_value;

reg       attrib_blinking;

reg       attrib_9bit_same_as_8bit;

reg       attrib_graphic_mode;

reg [7:0] attrib_color_overscan;

reg [3:0] attrib_mask;

//not implemented attribute regs:
reg attrib_not_impl_mono_emulation;

//------------------------------------------------------------------------------

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_color_bit5_4_enable         <= 1'd0; else if(attrib_io_write && attrib_io_index == 5'h10) attrib_color_bit5_4_enable         <= io_writedata[7]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_color_8bit_enable           <= 1'd1; else if(attrib_io_write && attrib_io_index == 5'h10) attrib_color_8bit_enable           <= io_writedata[6]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_panning_after_compare_match <= 1'd0; else if(attrib_io_write && attrib_io_index == 5'h10) attrib_panning_after_compare_match <= io_writedata[5]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_blinking                    <= 1'd0; else if(attrib_io_write && attrib_io_index == 5'h10) attrib_blinking                    <= io_writedata[3]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_9bit_same_as_8bit           <= 1'd0; else if(attrib_io_write && attrib_io_index == 5'h10) attrib_9bit_same_as_8bit           <= io_writedata[2]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_not_impl_mono_emulation     <= 1'd0; else if(attrib_io_write && attrib_io_index == 5'h10) attrib_not_impl_mono_emulation     <= io_writedata[1]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_graphic_mode                <= 1'd1; else if(attrib_io_write && attrib_io_index == 5'h10) attrib_graphic_mode                <= io_writedata[0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_color_overscan <= 8'd0;        else if(attrib_io_write && attrib_io_index == 5'h11) attrib_color_overscan <= io_writedata[7:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_mask <= 4'hF;                  else if(attrib_io_write && attrib_io_index == 5'h12) attrib_mask <= io_writedata[3:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_panning_value <= 4'd0;         else if(attrib_io_write && attrib_io_index == 5'h13) attrib_panning_value <= io_writedata[3:0]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_color_bit7_6_value <= 2'd0;    else if(attrib_io_write && attrib_io_index == 5'h14) attrib_color_bit7_6_value <= io_writedata[3:2]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_color_bit5_4_value <= 2'd0;    else if(attrib_io_write && attrib_io_index == 5'h14) attrib_color_bit5_4_value <= io_writedata[1:0]; end

//------------------------------------------------------------------------------

wire [7:0] host_io_read_attrib =
    (attrib_io_index == 5'h10)?     { attrib_color_bit5_4_enable, attrib_color_8bit_enable, attrib_panning_after_compare_match, 1'b0,
                                      attrib_blinking, attrib_9bit_same_as_8bit, attrib_not_impl_mono_emulation, attrib_graphic_mode } :
    (attrib_io_index == 5'h11)?     attrib_color_overscan :
    (attrib_io_index == 5'h12)?     { 4'd0, attrib_mask } :
    (attrib_io_index == 5'h13)?     { 4'd0, attrib_panning_value } :
    (attrib_io_index == 5'h14)?     { 4'd0, attrib_color_bit7_6_value, attrib_color_bit5_4_value } :
                                    8'h00;

//------------------------------------------------------------------------------ external io

reg general_vsync;
reg general_hsync;

reg general_enable_ram;
reg general_io_space;

//not implemented external regs:
reg [1:0] general_not_impl_clock_select;
reg       general_not_impl_odd_even_page;

//------------------------------------------------------------------------------

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) general_vsync <= 1'd0;                    else if(general_io_write_misc) general_vsync <= io_writedata[7]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) general_hsync <= 1'd1;                    else if(general_io_write_misc) general_hsync <= io_writedata[6]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) general_not_impl_odd_even_page <= 1'd1;   else if(general_io_write_misc) general_not_impl_odd_even_page <= io_writedata[5]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) general_not_impl_clock_select <= 2'd0;    else if(general_io_write_misc) general_not_impl_clock_select <= io_writedata[3:2]; end

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) general_enable_ram <= 1'd1;               else if(general_io_write_misc) general_enable_ram <= io_writedata[1]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) general_io_space   <= 1'd1;               else if(general_io_write_misc) general_io_space   <= io_writedata[0]; end

//------------------------------------------------------------------------------ io

wire host_io_ignored = 
    (general_io_space    && (io_b_read_valid || io_b_write)) ||
    (~(general_io_space) && (io_d_read_valid || io_d_write));
    
    
reg [3:0] host_io_read_address_last;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) host_io_read_address_last <= 4'd0; else if(io_c_read_valid) host_io_read_address_last <= io_c_address; end
    
reg [2:0]   seq_io_index;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) seq_io_index <= 3'd0; else if(io_c_write && io_c_address == 4'h4) seq_io_index <= io_writedata[2:0]; end

wire        seq_io_write = io_c_write && io_c_address == 4'h5;

reg [4:0]   crtc_io_index;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   crtc_io_index <= 5'd0;
    else if(io_b_write && io_b_address == 4'h4 && ~(host_io_ignored))   crtc_io_index <= io_b_writedata[4:0];
    else if(io_d_write && io_d_address == 4'h4 && ~(host_io_ignored))   crtc_io_index <= io_d_writedata[4:0];
end

wire crtc_io_write = ((io_b_write && io_b_address == 4'd5) || (io_d_write && io_d_address == 4'd5)) && ~(host_io_ignored) && (~(crtc_protect) || crtc_io_index >= 5'd8);

wire crtc_io_write_compare = ((io_b_write && io_b_address == 4'd5) || (io_d_write && io_d_address == 4'd5)) && ~(host_io_ignored);

reg [3:0]   graph_io_index;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) graph_io_index <= 4'd0; else if(io_c_write && io_c_address == 4'hE) graph_io_index <= io_c_writedata[3:0]; end

wire        graph_io_write = io_c_write && io_c_address == 4'hF;

reg [4:0]   attrib_io_index;
reg         attrib_video_enable;
reg         attrib_flip_flop;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_video_enable <= 1'd1; else if(io_c_write && io_c_address == 4'h0 && ~(attrib_flip_flop)) attrib_video_enable <= io_c_writedata[5]; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) attrib_io_index     <= 5'd0; else if(io_c_write && io_c_address == 4'h0 && ~(attrib_flip_flop)) attrib_io_index     <= io_c_writedata[4:0]; end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                       attrib_flip_flop <= 1'b0;
    else if(((io_b_read_valid && io_b_address == 4'hA) || (io_d_read_valid && io_d_address == 4'hA)) && ~(host_io_ignored)) attrib_flip_flop <= 1'b0;
    else if(io_c_write && io_c_address == 4'h0)                                                                             attrib_flip_flop <= ~attrib_flip_flop;
end

wire attrib_io_write = io_c_write && io_c_address == 4'h0 && attrib_flip_flop == 1'b1;

wire general_io_write_misc = io_c_write && io_c_address == 4'h2;

//------------------------------------------------------------------------------

reg [7:0] dac_mask;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) dac_mask <= 8'hFF; else if(io_c_write && io_c_address == 4'h6) dac_mask <= io_c_writedata[7:0]; end

reg       dac_is_read;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                           dac_is_read <= 1'd0;
    else if(io_c_write && io_c_address == 4'h7) dac_is_read <= 1'b1;
    else if(io_c_write && io_c_address == 4'h8) dac_is_read <= 1'b0;
end

reg [11:0] dac_write_buffer;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                           dac_write_buffer <= 12'd0;
    else if(io_c_write && io_c_address == 4'h9) dac_write_buffer <= { dac_write_buffer[5:0], io_c_writedata[5:0] };
end

reg [7:0] dac_write_index;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                               dac_write_index <= 8'd0;
    else if(io_c_write && io_c_address == 4'h8)                     dac_write_index <= io_c_writedata[7:0];
    else if(io_c_write && io_c_address == 4'h9 && dac_cnt == 2'd2)  dac_write_index <= dac_write_index + 8'd1;
end

reg [7:0] dac_read_index;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       dac_read_index <= 8'd0;
    else if(io_c_write && io_c_address == 4'h7)                             dac_read_index <= io_c_writedata[7:0];
    else if(io_c_read_valid  && io_c_address == 4'h9 && dac_cnt == 2'd2)    dac_read_index <= dac_read_index + 8'd1;
end

reg [1:0] dac_cnt;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   dac_cnt <= 2'd0;
    else if(io_c_write && io_c_address == 4'h7)                                         dac_cnt <= 2'd0;
    else if(io_c_write && io_c_address == 4'h8)                                         dac_cnt <= 2'd0;
    else if((io_c_read_valid || io_c_write) && io_c_address == 4'h9 && dac_cnt == 2'd2) dac_cnt <= 2'd0;
    else if((io_c_read_valid || io_c_write) && io_c_address == 4'h9)                    dac_cnt <= dac_cnt + 2'd1;
end

//------------------------------------------------------------------------------

wire host_io_vertical_retrace;
wire host_io_not_displaying;

wire [7:0]  host_io_read_wire =
    (host_io_ignored)?                                  8'hFF :
    (io_c_read_valid && io_c_address == 4'hC)?          { general_vsync, general_hsync, general_not_impl_odd_even_page, 1'b0, general_not_impl_clock_select, general_enable_ram, general_io_space } : //misc output reg
    (io_c_read_valid && io_c_address == 4'h2)?          { 3'b0, 1'b1, 4'b0 } : //input status 0
    ((io_b_read_valid && io_b_address == 4'hA) || (io_d_read_valid && io_d_address == 4'hA))?
                                                        { 4'b0, host_io_vertical_retrace, 2'b0, host_io_not_displaying } : //input status 1
    (io_c_read_valid && io_c_address == 4'h0 && attrib_flip_flop)? 
                                                        8'h00 : //attrib index in write mode
    (io_c_read_valid && io_c_address == 4'h0)?          { 2'b0, attrib_video_enable, attrib_io_index } : //attrib in address mode
    (io_c_read_valid && io_c_address == 4'h1)?          host_io_read_attrib : //attrib read
    (io_c_read_valid && io_c_address == 4'h4)?          { 5'd0, seq_io_index } : //seq index
    (io_c_read_valid && io_c_address == 4'h5)?          host_io_read_seq : //seq data
    (io_c_read_valid && io_c_address == 4'h6)?          dac_mask : //pel mask
    (io_c_read_valid && io_c_address == 4'h7)?          { 6'd0, dac_is_read? 2'b11 : 2'b00 } : //dac state
    (io_c_read_valid && io_c_address == 4'h8)?          dac_write_index :
    (io_c_read_valid && io_c_address == 4'hE)?          { 4'd0, graph_io_index } :
    (io_c_read_valid && io_c_address == 4'hF)?          host_io_read_graph :
    (io_d_read_valid && io_d_address == 4'h4)?          { 3'b0, crtc_io_index } :
    ((io_b_read_valid && io_b_address == 4'h5) || (io_d_read_valid && io_d_address == 4'h5))? 
                                                        host_io_read_crtc :
    (io_b_read_valid || io_d_read_valid)?               8'hFF :
                                                        8'h00; // 6'h1A (Feature Control Register)

reg [7:0] host_io_read_reg;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) host_io_read_reg <= 8'd0; else host_io_read_reg <= host_io_read_wire; end

wire [5:0]  host_palette_q;
wire [17:0] dac_read_q;

assign io_c_readdata =
    (host_io_read_address_last == 4'h1 && attrib_io_index <= 5'hF)?     { 2'b0, host_palette_q } :
    (host_io_read_address_last == 4'h9 && ~(dac_is_read))?              8'h3F :              
    (host_io_read_address_last == 4'h9 && dac_cnt == 2'd1)?             { 2'b0, dac_read_q[17:12] } :
    (host_io_read_address_last == 4'h9 && dac_cnt == 2'd2)?             { 2'b0, dac_read_q[11:6] } :
    (host_io_read_address_last == 4'h9 && dac_cnt == 2'd0)?             { 2'b0, dac_read_q[5:0] } :
                                                                        host_io_read_reg;
                                                                        
assign io_b_readdata = host_io_read_reg;
assign io_d_readdata = host_io_read_reg;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

wire host_memory_out_of_bounds =
    (graph_system_memory == 2'd1 && mem_address > 17'h0FFFF) ||
    (graph_system_memory == 2'd2 && (mem_address < 17'h10000 || mem_address > 17'h17FFF)) ||
    (graph_system_memory == 2'd3 && mem_address < 17'h17FFF);

wire [16:0] host_address_reduced =
    (graph_system_memory == 2'd1)?  { 1'b0, mem_address[15:0] } :
    (graph_system_memory == 2'd2)?  { 2'b0, mem_address[14:0] } :
    (graph_system_memory == 2'd3)?  { 2'b0, mem_address[14:0] } :
                                    mem_address;

wire [15:0] host_address =
    (seq_access_chain4)?                { host_address_reduced[15:2], 2'b00 } :
    (~(seq_access_odd_even_disabled))?  { host_address_reduced[15:1], 1'b0 } :
                                        host_address_reduced[15:0];

//------------------------------------------------------------------------------ mem read

wire [7:0] host_ram0_q;
wire [7:0] host_ram1_q;
wire [7:0] host_ram2_q;
wire [7:0] host_ram3_q;

reg [7:0] host_ram0_reg;
reg [7:0] host_ram1_reg;
reg [7:0] host_ram2_reg;
reg [7:0] host_ram3_reg;

reg host_read_out_of_bounds;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                       host_read_out_of_bounds <= 1'b0;
    else if(mem_read_valid && host_memory_out_of_bounds)    host_read_out_of_bounds <= 1'b1;
    else                                                    host_read_out_of_bounds <= 1'b0;
end

reg [16:0] host_address_reduced_last;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)       host_address_reduced_last <= 17'd0;
    else if(mem_read_valid) host_address_reduced_last <= host_address_reduced;
end

reg host_read_last;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)   host_read_last <= 1'd0;
    else                host_read_last <= mem_read_valid && ~(host_memory_out_of_bounds);
end

wire [7:0] host_read_mode_1 = {
    (graph_color_compare_dont_care[0]? ~(host_ram0_q[7] ^ graph_color_compare_map[0]) : 1'b1) & (graph_color_compare_dont_care[1]? ~(host_ram1_q[7] ^ graph_color_compare_map[1]) : 1'b1) &
    (graph_color_compare_dont_care[2]? ~(host_ram2_q[7] ^ graph_color_compare_map[2]) : 1'b1) & (graph_color_compare_dont_care[3]? ~(host_ram3_q[7] ^ graph_color_compare_map[3]) : 1'b1),
    (graph_color_compare_dont_care[0]? ~(host_ram0_q[6] ^ graph_color_compare_map[0]) : 1'b1) & (graph_color_compare_dont_care[1]? ~(host_ram1_q[6] ^ graph_color_compare_map[1]) : 1'b1) &
    (graph_color_compare_dont_care[2]? ~(host_ram2_q[6] ^ graph_color_compare_map[2]) : 1'b1) & (graph_color_compare_dont_care[3]? ~(host_ram3_q[6] ^ graph_color_compare_map[3]) : 1'b1),
    (graph_color_compare_dont_care[0]? ~(host_ram0_q[5] ^ graph_color_compare_map[0]) : 1'b1) & (graph_color_compare_dont_care[1]? ~(host_ram1_q[5] ^ graph_color_compare_map[1]) : 1'b1) &
    (graph_color_compare_dont_care[2]? ~(host_ram2_q[5] ^ graph_color_compare_map[2]) : 1'b1) & (graph_color_compare_dont_care[3]? ~(host_ram3_q[5] ^ graph_color_compare_map[3]) : 1'b1),
    (graph_color_compare_dont_care[0]? ~(host_ram0_q[4] ^ graph_color_compare_map[0]) : 1'b1) & (graph_color_compare_dont_care[1]? ~(host_ram1_q[4] ^ graph_color_compare_map[1]) : 1'b1) &
    (graph_color_compare_dont_care[2]? ~(host_ram2_q[4] ^ graph_color_compare_map[2]) : 1'b1) & (graph_color_compare_dont_care[3]? ~(host_ram3_q[4] ^ graph_color_compare_map[3]) : 1'b1),
    (graph_color_compare_dont_care[0]? ~(host_ram0_q[3] ^ graph_color_compare_map[0]) : 1'b1) & (graph_color_compare_dont_care[1]? ~(host_ram1_q[3] ^ graph_color_compare_map[1]) : 1'b1) &
    (graph_color_compare_dont_care[2]? ~(host_ram2_q[3] ^ graph_color_compare_map[2]) : 1'b1) & (graph_color_compare_dont_care[3]? ~(host_ram3_q[3] ^ graph_color_compare_map[3]) : 1'b1),
    (graph_color_compare_dont_care[0]? ~(host_ram0_q[2] ^ graph_color_compare_map[0]) : 1'b1) & (graph_color_compare_dont_care[1]? ~(host_ram1_q[2] ^ graph_color_compare_map[1]) : 1'b1) &
    (graph_color_compare_dont_care[2]? ~(host_ram2_q[2] ^ graph_color_compare_map[2]) : 1'b1) & (graph_color_compare_dont_care[3]? ~(host_ram3_q[2] ^ graph_color_compare_map[3]) : 1'b1),
    (graph_color_compare_dont_care[0]? ~(host_ram0_q[1] ^ graph_color_compare_map[0]) : 1'b1) & (graph_color_compare_dont_care[1]? ~(host_ram1_q[1] ^ graph_color_compare_map[1]) : 1'b1) &
    (graph_color_compare_dont_care[2]? ~(host_ram2_q[1] ^ graph_color_compare_map[2]) : 1'b1) & (graph_color_compare_dont_care[3]? ~(host_ram3_q[1] ^ graph_color_compare_map[3]) : 1'b1),
    (graph_color_compare_dont_care[0]? ~(host_ram0_q[0] ^ graph_color_compare_map[0]) : 1'b1) & (graph_color_compare_dont_care[1]? ~(host_ram1_q[0] ^ graph_color_compare_map[1]) : 1'b1) &
    (graph_color_compare_dont_care[2]? ~(host_ram2_q[0] ^ graph_color_compare_map[2]) : 1'b1) & (graph_color_compare_dont_care[3]? ~(host_ram3_q[0] ^ graph_color_compare_map[3]) : 1'b1)
};

assign mem_readdata =
    (host_read_out_of_bounds)?                                                                              8'hFF :
    (seq_access_chain4 && host_address_reduced_last[1:0] == 2'b00)?                                         host_ram0_q :
    (seq_access_chain4 && host_address_reduced_last[1:0] == 2'b01)?                                         host_ram1_q :
    (seq_access_chain4 && host_address_reduced_last[1:0] == 2'b10)?                                         host_ram2_q :
    (seq_access_chain4 && host_address_reduced_last[1:0] == 2'b11)?                                         host_ram3_q :
    (graph_read_mode == 1'b0 && ~(seq_access_odd_even_disabled) && host_address_reduced_last[0] == 1'b0)?   host_ram0_q :
    (graph_read_mode == 1'b0 && ~(seq_access_odd_even_disabled) && host_address_reduced_last[0] == 1'b1)?   host_ram1_q :
    (graph_read_mode == 1'b0 && graph_read_map_select == 2'd0)?                                             host_ram0_q :
    (graph_read_mode == 1'b0 && graph_read_map_select == 2'd1)?                                             host_ram1_q :
    (graph_read_mode == 1'b0 && graph_read_map_select == 2'd2)?                                             host_ram2_q :
    (graph_read_mode == 1'b0 && graph_read_map_select == 2'd3)?                                             host_ram3_q :
                                                                                                            host_read_mode_1;

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) host_ram0_reg <= 8'd0; else if(host_read_last) host_ram0_reg <= host_ram0_q; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) host_ram1_reg <= 8'd0; else if(host_read_last) host_ram1_reg <= host_ram1_q; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) host_ram2_reg <= 8'd0; else if(host_read_last) host_ram2_reg <= host_ram2_q; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) host_ram3_reg <= 8'd0; else if(host_read_last) host_ram3_reg <= host_ram3_q; end


//------------------------------------------------------------------------------ mem write

wire host_write = mem_write && ~(host_memory_out_of_bounds);

wire [7:0] host_writedata_rotate =
    (graph_write_rotate == 3'd0)?     mem_writedata[7:0] :
    (graph_write_rotate == 3'd1)?   { mem_writedata[0],   mem_writedata[7:1] } :
    (graph_write_rotate == 3'd2)?   { mem_writedata[1:0], mem_writedata[7:2] } :
    (graph_write_rotate == 3'd3)?   { mem_writedata[2:0], mem_writedata[7:3] } :
    (graph_write_rotate == 3'd4)?   { mem_writedata[3:0], mem_writedata[7:4] } :
    (graph_write_rotate == 3'd5)?   { mem_writedata[4:0], mem_writedata[7:5] } :
    (graph_write_rotate == 3'd6)?   { mem_writedata[5:0], mem_writedata[7:6] } :
                                    { mem_writedata[6:0], mem_writedata[7] };
    
wire [7:0] host_write_set_0 = (graph_write_mode == 2'd2)? {8{mem_writedata[0]}} : graph_write_enable_map[0]?  {8{graph_write_set_map[0]}} : host_writedata_rotate;
wire [7:0] host_write_set_1 = (graph_write_mode == 2'd2)? {8{mem_writedata[1]}} : graph_write_enable_map[1]?  {8{graph_write_set_map[1]}} : host_writedata_rotate;
wire [7:0] host_write_set_2 = (graph_write_mode == 2'd2)? {8{mem_writedata[2]}} : graph_write_enable_map[2]?  {8{graph_write_set_map[2]}} : host_writedata_rotate;
wire [7:0] host_write_set_3 = (graph_write_mode == 2'd2)? {8{mem_writedata[3]}} : graph_write_enable_map[3]?  {8{graph_write_set_map[3]}} : host_writedata_rotate;

wire [31:0] host_write_function =
    (graph_write_function == 2'd1)? { host_write_set_3, host_write_set_2, host_write_set_1, host_write_set_0 } & { host_ram3_reg, host_ram2_reg, host_ram1_reg, host_ram0_reg } :
    (graph_write_function == 2'd2)? { host_write_set_3, host_write_set_2, host_write_set_1, host_write_set_0 } | { host_ram3_reg, host_ram2_reg, host_ram1_reg, host_ram0_reg } :
    (graph_write_function == 2'd3)? { host_write_set_3, host_write_set_2, host_write_set_1, host_write_set_0 } ^ { host_ram3_reg, host_ram2_reg, host_ram1_reg, host_ram0_reg } :
                                    { host_write_set_3, host_write_set_2, host_write_set_1, host_write_set_0 };

wire [7:0] host_write_mask_0 = (graph_write_mask & host_write_function[7:0])   | (~(graph_write_mask) & host_ram0_reg);
wire [7:0] host_write_mask_1 = (graph_write_mask & host_write_function[15:8])  | (~(graph_write_mask) & host_ram1_reg);
wire [7:0] host_write_mask_2 = (graph_write_mask & host_write_function[23:16]) | (~(graph_write_mask) & host_ram2_reg);
wire [7:0] host_write_mask_3 = (graph_write_mask & host_write_function[31:24]) | (~(graph_write_mask) & host_ram3_reg);

wire [7:0] host_write_mode_3_mask = host_writedata_rotate & graph_write_mask;
wire [7:0] host_write_mode_3_ram0 = (host_write_mode_3_mask & {8{graph_write_set_map[0]}})   | (~(host_write_mode_3_mask) & host_ram0_reg);
wire [7:0] host_write_mode_3_ram1 = (host_write_mode_3_mask & {8{graph_write_set_map[1]}})   | (~(host_write_mode_3_mask) & host_ram1_reg);
wire [7:0] host_write_mode_3_ram2 = (host_write_mode_3_mask & {8{graph_write_set_map[2]}})   | (~(host_write_mode_3_mask) & host_ram2_reg);
wire [7:0] host_write_mode_3_ram3 = (host_write_mode_3_mask & {8{graph_write_set_map[3]}})   | (~(host_write_mode_3_mask) & host_ram3_reg);

wire [31:0] host_writedata =
    (graph_write_mode == 2'd0 || graph_write_mode == 2'd2)?     { host_write_mask_3, host_write_mask_2, host_write_mask_1, host_write_mask_0 } :
    (graph_write_mode == 2'd1)?                                 { host_ram3_reg, host_ram2_reg, host_ram1_reg, host_ram0_reg } :
                                                                { host_write_mode_3_ram3, host_write_mode_3_ram2, host_write_mode_3_ram1, host_write_mode_3_ram0 };
    
wire [3:0] host_write_enable_for_chain4 =
    (host_address_reduced[1:0] == 2'd0)?    4'b0001 :
    (host_address_reduced[1:0] == 2'd1)?    4'b0010 :
    (host_address_reduced[1:0] == 2'd2)?    4'b0100 :
                                            4'b1000;
wire [3:0] host_write_enable_for_odd_even =
    (host_address_reduced[0] == 1'd0)?      4'b0101 :
                                            4'b1010;
                                            
wire [3:0] host_write_enable = 
    {4{host_write}} & seq_map_write_enable & (
    (seq_access_chain4)?                host_write_enable_for_chain4 :
    (~(seq_access_odd_even_disabled))?  host_write_enable_for_odd_even :
                                        4'b1111); 

//------------------------------------------------------------------------------

wire dot_memory_load;
wire dot_memory_load_first_in_frame;
wire dot_memory_load_first_in_line_matched;
wire dot_memory_load_first_in_line;
wire dot_memory_load_vertical_retrace_start;

wire memory_address_load = dot_memory_load_first_in_frame || dot_memory_load_first_in_line_matched || dot_memory_load_first_in_line;

reg [15:0] memory_start_line;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)               memory_start_line <= 16'd0;
    else if(memory_address_load)    memory_start_line <= memory_address;
end

reg [15:0] memory_address_reg;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                               memory_address_reg <= 16'd0;
    else if(memory_address_load || dot_memory_load) memory_address_reg <= memory_address;
end

reg [4:0] memory_row_scan_reg;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)               memory_row_scan_reg <= 5'd0;
    else if(memory_address_load)    memory_row_scan_reg <= memory_row_scan;
end

reg memory_row_scan_double;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                               memory_row_scan_double <= 1'b0;
    else if(crtc_vertical_doublescan && (dot_memory_load_first_in_frame || dot_memory_load_first_in_line_matched))  memory_row_scan_double <= 1'b1;
    else if(crtc_vertical_doublescan && dot_memory_load_first_in_line)                                              memory_row_scan_double <= ~memory_row_scan_double;
    else if(~(crtc_vertical_doublescan) || dot_memory_load_vertical_retrace_start)                                  memory_row_scan_double <= 1'b0;
end

//do not change charmap in the middle of a character row scan
reg [2:0] memory_char_map_a;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                                               memory_char_map_a <= 3'd0;
    else if(dot_memory_load_first_in_frame || dot_memory_load_first_in_line_matched || (dot_memory_load_first_in_line && memory_row_scan == 5'd0))  memory_char_map_a <= seq_char_map_a;
end

reg [2:0] memory_char_map_b;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                                               memory_char_map_b <= 3'd0;
    else if(dot_memory_load_first_in_frame || dot_memory_load_first_in_line_matched || (dot_memory_load_first_in_line && memory_row_scan == 5'd0))  memory_char_map_b <= seq_char_map_b;
end


reg [3:0] memory_panning_reg;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                       memory_panning_reg <= 4'd0;
    else if(dot_memory_load_first_in_line_matched && attrib_panning_after_compare_match)    memory_panning_reg <= 4'd0;
    else if(dot_memory_load_first_in_frame)                                                 memory_panning_reg <= attrib_panning_value;
end

reg memory_load_step_a;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           memory_load_step_a <= 1'b0;
    else if(dot_memory_load)    memory_load_step_a <= 1'b1;
    else                        memory_load_step_a <= 1'b0;
end

reg memory_load_step_b;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           memory_load_step_b <= 1'b0;
    else if(memory_load_step_a) memory_load_step_b <= 1'b1;
    else                        memory_load_step_b <= 1'b0;
end

wire [15:0] memory_address =
    (dot_memory_load_first_in_line_matched)?                                    16'd0 :
    (dot_memory_load_first_in_frame)?                                           crtc_address_start + { 14'd0, crtc_address_byte_panning } :
    (dot_memory_load_first_in_line && memory_row_scan_double)?                  memory_start_line :
    (dot_memory_load_first_in_line && memory_row_scan_reg < crtc_row_max)?      memory_start_line :
    (dot_memory_load_first_in_line)?                                            memory_start_line + { 7'd0, crtc_address_offset[7:0], 1'b0 } :
    (dot_memory_load)?                                                          memory_address_reg + 16'd1 :
                                                                                memory_address_reg;
    
wire [4:0] memory_row_scan =
    (dot_memory_load_first_in_line_matched)?                                5'd0 :
    (dot_memory_load_first_in_frame && crtc_row_preset <= crtc_row_max)?    crtc_row_preset :
    (dot_memory_load_first_in_frame)?                                       5'd0 :
    (dot_memory_load_first_in_line && memory_row_scan_double)?              memory_row_scan_reg :
    (dot_memory_load_first_in_line && memory_row_scan_reg == crtc_row_max)? 5'd0 :
    (dot_memory_load_first_in_line)?                                        memory_row_scan_reg + 5'd1 :
                                                                            memory_row_scan_reg;

wire [15:0] memory_address_step_1 =
    (crtc_address_doubleword)?  { memory_address[13:0], memory_address[15:14] } :
    (crtc_address_byte)?        memory_address :
    (crtc_address_bit0)?        { memory_address[14:0], memory_address[15] } :
                                { memory_address[14:0], memory_address[13] };

wire [15:0] memory_address_step_2 = {
    memory_address_step_1[15],
    (crtc_address_bit14)?           memory_address_step_1[14] : memory_row_scan[1],
    (crtc_address_bit13)?           memory_address_step_1[13] : memory_row_scan[0],
    memory_address_step_1[12:0]
};

reg [15:0] memory_address_reg_final;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           memory_address_reg_final <= 16'd0;
    else if(dot_memory_load)    memory_address_reg_final <= memory_address;
end

wire [2:0] memory_txt_index = plane_ram1_q[3]? memory_char_map_a : memory_char_map_b;

wire [15:0] memory_txt_address_base =
    ((~(seq_access_256kb) && memory_txt_index[2] == 1'b0) || memory_txt_index == 3'b000)?   16'h0000 :
    ((~(seq_access_256kb) && memory_txt_index[2] == 1'b1) || memory_txt_index == 3'b100)?   16'h2000 :
    (memory_txt_index == 3'b001)?                                                           16'h4000 :
    (memory_txt_index == 3'b101)?                                                           16'h6000 :
    (memory_txt_index == 3'b010)?                                                           16'h8000 :
    (memory_txt_index == 3'b110)?                                                           16'hA000 :
    (memory_txt_index == 3'b011)?                                                           16'hC000 :
                                                                                            16'hE000;

wire [15:0] memory_txt_address = { memory_txt_address_base[15:13], plane_ram0_q[7:0], memory_row_scan_reg };

//------------------------------------------------------------------------------

wire [7:0] plane_ram0_q;
wire [7:0] plane_ram1_q;
wire [7:0] plane_ram2_q;
wire [7:0] plane_ram3_q;


simple_bidir_ram #(
    .widthad    (16),
    .width      (8)
)
plane_ram_inst0(
    .clk            (clk_26),
    
    .address_a      (host_address),
    .data_a         (host_writedata[7:0]),
    .wren_a         (general_enable_ram && host_write_enable[0]),
    .q_a            (host_ram0_q),
    
    .address_b      (memory_address_step_2),
    .q_b            (plane_ram0_q)
);

simple_bidir_ram #(
    .widthad    (16),
    .width      (8)
)
plane_ram_inst1(
    .clk            (clk_26),
    
    .address_a      (host_address),
    .data_a         (host_writedata[15:8]),
    .wren_a         (general_enable_ram && host_write_enable[1]),
    .q_a            (host_ram1_q),
    
    .address_b      (memory_address_step_2),
    .q_b            (plane_ram1_q)
);

simple_bidir_ram #(
    .widthad    (16),
    .width      (8)
)
plane_ram_inst2(
    .clk            (clk_26),
    
    .address_a      (host_address),
    .data_a         (host_writedata[23:16]),
    .wren_a         (general_enable_ram && host_write_enable[2]),
    .q_a            (host_ram2_q),
    
    .address_b      (memory_load_step_a? memory_txt_address : memory_address_step_2),
    .q_b            (plane_ram2_q)
);

simple_bidir_ram #(
    .widthad    (16),
    .width      (8)
)
plane_ram_inst3(
    .clk            (clk_26),
    
    .address_a      (host_address),
    .data_a         (host_writedata[31:24]),
    .wren_a         (general_enable_ram && host_write_enable[3]),
    .q_a            (host_ram3_q),
    
    .address_b      (memory_address_step_2),
    .q_b            (plane_ram3_q)
);

//------------------------------------------------------------------------------

reg [7:0] plane_ram0;
reg [7:0] plane_ram1;
reg [7:0] plane_ram2;
reg [7:0] plane_ram3;

always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) plane_ram0 <= 8'd0; else if(memory_load_step_a) plane_ram0 <= plane_ram0_q; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) plane_ram1 <= 8'd0; else if(memory_load_step_a) plane_ram1 <= plane_ram1_q; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) plane_ram2 <= 8'd0; else if(memory_load_step_a) plane_ram2 <= plane_ram2_q; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) plane_ram3 <= 8'd0; else if(memory_load_step_a) plane_ram3 <= plane_ram3_q; end

//------------------------------------------------------------------------------

reg [5:0] plane_shift_cnt;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                   plane_shift_cnt <= 6'd0;
    else if(memory_load_step_b)         plane_shift_cnt <= 6'd1;
    else if(plane_shift_cnt == 6'd34)   plane_shift_cnt <= 6'd0;
    else if(plane_shift_cnt != 6'd0)    plane_shift_cnt <= plane_shift_cnt + 6'd1;
end

wire plane_shift_enable = 
    (~(seq_dotclock_divided) && plane_shift_cnt >= 6'd1) ||
    (  seq_dotclock_divided  && plane_shift_cnt >= 6'd1 && plane_shift_cnt[0]);
    
wire plane_shift_9dot =
    ~(seq_8dot_char) && plane_shift_enable &&
    (~(seq_dotclock_divided) && plane_shift_cnt == 6'd9) ||
    (  seq_dotclock_divided  && plane_shift_cnt == 6'd17);

//------------------------------------------------------------------------------

reg [7:0] plane_shift0;
reg [7:0] plane_shift1;
reg [7:0] plane_shift2;
reg [7:0] plane_shift3;

wire [7:0] plane_shift_value0 =
    (graph_shift_mode == 2'b00)?    plane_ram0 :
    (graph_shift_mode == 2'b01)?    { plane_ram0[6],plane_ram0[4],plane_ram0[2],plane_ram0[0], plane_ram1[6],plane_ram1[4],plane_ram1[2],plane_ram1[0] } :
                                    { plane_ram0[4],plane_ram0[0],plane_ram1[4],plane_ram1[0], plane_ram2[4],plane_ram2[0],plane_ram3[4],plane_ram3[0] };

wire [7:0] plane_shift_value1 =
    (graph_shift_mode == 2'b00)?    plane_ram1 :
    (graph_shift_mode == 2'b01)?    { plane_ram0[7],plane_ram0[5],plane_ram0[3],plane_ram0[1], plane_ram1[7],plane_ram1[5],plane_ram1[3],plane_ram1[1] } :
                                    { plane_ram0[5],plane_ram0[1],plane_ram1[5],plane_ram1[1], plane_ram2[5],plane_ram2[1],plane_ram3[5],plane_ram3[1] };

wire [7:0] plane_shift_value2 =
    (graph_shift_mode == 2'b00)?    plane_ram2 :
    (graph_shift_mode == 2'b01)?    { plane_ram2[6],plane_ram2[4],plane_ram2[2],plane_ram2[0], plane_ram3[6],plane_ram3[4],plane_ram3[2],plane_ram3[0] } :
                                    { plane_ram0[6],plane_ram0[2],plane_ram1[6],plane_ram1[2], plane_ram2[6],plane_ram2[2],plane_ram3[6],plane_ram3[2] };

wire [7:0] plane_shift_value3 =
    (graph_shift_mode == 2'b00)?    plane_ram3 :
    (graph_shift_mode == 2'b01)?    { plane_ram2[7],plane_ram2[5],plane_ram2[3],plane_ram2[1], plane_ram3[7],plane_ram3[5],plane_ram3[3],plane_ram3[1] } :
                                    { plane_ram0[7],plane_ram0[3],plane_ram1[7],plane_ram1[3], plane_ram2[7],plane_ram2[3],plane_ram3[7],plane_ram3[3] };
                                    
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           plane_shift0 <= 8'd0;
    else if(memory_load_step_b) plane_shift0 <= plane_shift_value0;
    else if(plane_shift_enable) plane_shift0 <= { plane_shift0[6:0], 1'b0 };
end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           plane_shift1 <= 8'd0;
    else if(memory_load_step_b) plane_shift1 <= plane_shift_value1;
    else if(plane_shift_enable) plane_shift1 <= { plane_shift1[6:0], 1'b0 };
end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           plane_shift2 <= 8'd0;
    else if(memory_load_step_b) plane_shift2 <= plane_shift_value2;
    else if(plane_shift_enable) plane_shift2 <= { plane_shift2[6:0], 1'b0 };
end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           plane_shift3 <= 8'd0;
    else if(memory_load_step_b) plane_shift3 <= plane_shift_value3;
    else if(plane_shift_enable) plane_shift3 <= { plane_shift3[6:0], 1'b0 };
end

//------------------------------------------------------------------------------

reg [7:0] plane_txt_shift;

wire blink_txt_value;
wire blink_cursor_value;

wire txt_blink_enabled = attrib_blinking && plane_ram1[7] && blink_txt_value;

wire txt_underline_enable = plane_ram1[2:0] == 3'b001 && plane_ram1[6:4] == 3'b000 && crtc_row_underline > 5'd0 && crtc_row_underline - 5'd1 == memory_row_scan_reg;

wire txt_cursor_enable =
    ~(crtc_cursor_off) &&
    blink_cursor_value &&
    memory_address_reg_final == crtc_address_cursor + { 14'd0, crtc_cursor_skew } &&
    memory_row_scan_reg >= crtc_cursor_row_start &&
    memory_row_scan_reg <= crtc_cursor_row_end &&
    crtc_cursor_row_start <= crtc_cursor_row_end;

wire [7:0] plane_txt_shift_value =
    (txt_blink_enabled)?        8'd0 :
    (txt_underline_enable)?     8'hFF :
    (txt_cursor_enable)?        8'hFF :
                                plane_ram2_q;

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           plane_txt_shift <= 8'd0;
    else if(memory_load_step_b) plane_txt_shift <= plane_txt_shift_value;
    else if(plane_shift_enable) plane_txt_shift <= { plane_txt_shift[6:0], 1'b0 };
end

reg [3:0] txt_foreground;
reg [3:0] txt_background;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           txt_foreground <= 4'd0;
    else if(memory_load_step_b) txt_foreground <= plane_ram1[3:0];
end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           txt_background <= 4'd0;
    else if(memory_load_step_b) txt_background <= (attrib_blinking)? { 1'b0, plane_ram1[6:4] } : plane_ram1[7:4];
end

wire txt_line_graphic_char = plane_ram0 >= 8'hB0 && plane_ram0 <= 8'hDF;

//------------------------------------------------------------------------------

wire [3:0] pel_input =
    (plane_shift_9dot && attrib_9bit_same_as_8bit && pel_line_graphic_char)?   pel_input_last :
    (plane_shift_9dot)?                                                        pel_background :
    
    (attrib_graphic_mode)?  { plane_shift3[7], plane_shift2[7], plane_shift1[7], plane_shift0[7] } :
    (plane_txt_shift[7])?   txt_foreground :
                            txt_background;

reg [3:0] pel_input_last;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           pel_input_last <= 4'd0;
    else if(plane_shift_enable) pel_input_last <= pel_input;
end

reg pel_line_graphic_char;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           pel_line_graphic_char <= 1'b0;
    else if(plane_shift_enable) pel_line_graphic_char <= txt_line_graphic_char;
end

reg [3:0] pel_background;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           pel_background <= 4'd0;
    else if(plane_shift_enable) pel_background <= txt_background;
end

//------------------------------------------------------------------------------

wire [3:0] pel_after_enable = attrib_mask & pel_input;

//APA blinking logic (undocumented)
wire [3:0] pel_after_blink =
    (attrib_graphic_mode && attrib_blinking && blink_txt_value)?    { 1'b1, pel_after_enable[2:0] } :
    (attrib_graphic_mode && attrib_blinking)?                       pel_after_enable ^ 4'b1000 :
                                                                    pel_after_enable;

reg [35:0] pel_shift_reg;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           pel_shift_reg <= 36'd0;
    else if(plane_shift_enable) pel_shift_reg <= { pel_after_blink, pel_shift_reg[35:4] };
end

wire [7:0] pel_after_panning =
    (memory_panning_reg == 4'd0)?     pel_shift_reg[11:4] :
    (memory_panning_reg == 4'd1)?     pel_shift_reg[15:8] :
    (memory_panning_reg == 4'd2)?     pel_shift_reg[19:12] :
    (memory_panning_reg == 4'd3)?     pel_shift_reg[23:16] :
    (memory_panning_reg == 4'd4)?     pel_shift_reg[27:20] :
    (memory_panning_reg == 4'd5)?     pel_shift_reg[31:24] :
    (memory_panning_reg == 4'd6)?     pel_shift_reg[35:28] :
    (memory_panning_reg == 4'd7)?     { 4'd0, pel_shift_reg[35:32] } :
                                      pel_shift_reg[7:0];

reg plane_shift_enable_last;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) plane_shift_enable_last <= 1'b0; else plane_shift_enable_last <= plane_shift_enable; end
                                      
reg pel_color_8bit_cnt;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                               pel_color_8bit_cnt <= 1'b0;
    else if(plane_shift_enable && plane_shift_enable_last == 1'b0)  pel_color_8bit_cnt <= 1'b1;
    else                                                            pel_color_8bit_cnt <= ~pel_color_8bit_cnt;
end

reg [7:0] pel_color_8bit_buffer;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                   pel_color_8bit_buffer <= 8'd0;
    else if(pel_color_8bit_cnt == 1'b0) pel_color_8bit_buffer <= pel_after_panning;
end
//------------------------------------------------------------------------------

wire [5:0] pel_palette;

simple_bidir_ram #(
    .widthad    (4),
    .width      (6)
)
internal_palette_ram_inst(
    .clk            (clk_26),
    
    .address_a      (attrib_io_index[3:0]),
    .data_a         (io_c_writedata[5:0]),
    .wren_a         (attrib_io_write && attrib_io_index < 5'h10),
    .q_a            (host_palette_q),
    
    .address_b      (pel_after_panning[3:0]),
    .q_b            (pel_palette)
);

wire [7:0] pel_palette_index = {
    attrib_color_bit7_6_value,
    (attrib_color_bit5_4_enable)? attrib_color_bit5_4_value : pel_palette[5:4],
    pel_palette[3:0]
};

wire vgaprep_overscan;

wire [7:0] pel_index =
    (vgaprep_overscan)?             attrib_color_overscan :
    (~(attrib_video_enable))?       8'h00 :
    (attrib_color_8bit_enable)?     { pel_color_8bit_buffer[3:0], pel_color_8bit_buffer[7:4] } :
                                    pel_palette_index;

//------------------------------------------------------------------------------

wire [17:0] dac_color;

simple_bidir_ram #(
    .widthad    (8),
    .width      (18)
)
dac_ram_inst(
    .clk            (clk_26),
    
    .address_a      (dac_is_read? dac_read_index : dac_write_index),
    .data_a         ({ dac_write_buffer, io_c_writedata[5:0] }),
    .wren_a         (io_c_write && io_c_address == 4'h9 && dac_cnt == 2'd2),
    .q_a            (dac_read_q),
    
    .address_b      (pel_index),
    .q_b            (dac_color)
);

//------------------------------------------------------------------------------

wire character_last_dot = dot_cnt_enable && ((dot_cnt == 4'd8 && ~(seq_8dot_char)) || (dot_cnt == 4'd7 && seq_8dot_char));
wire line_last_dot      = horiz_cnt == crtc_horizontal_total + 8'd4 && character_last_dot;
wire screen_last_dot    = vert_cnt == crtc_vertical_total - 10'd1   && line_last_dot;

reg [3:0] dot_cnt;
reg [7:0] horiz_cnt;
reg [9:0] vert_cnt;

reg dot_cnt_div;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)   dot_cnt_div <= 1'b0;
    else                dot_cnt_div <= ~(dot_cnt_div);
end

wire dot_cnt_enable = ~(seq_dotclock_divided) || dot_cnt_div;

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                               dot_cnt <= 4'd0;
    else if(dot_cnt_enable && character_last_dot)   dot_cnt <= 4'd0;
    else if(dot_cnt_enable)                         dot_cnt <= dot_cnt + 4'd1;
end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           horiz_cnt <= 8'd0;
    else if(line_last_dot)      horiz_cnt <= 8'd0;
    else if(character_last_dot) horiz_cnt <= horiz_cnt + 8'd1;
end

always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           vert_cnt <= 10'd0;
    else if(screen_last_dot)    vert_cnt <= 10'd0;
    else if(line_last_dot)      vert_cnt <= vert_cnt + 10'd1;
end

assign dot_memory_load = 
    (   (seq_8dot_char    && ~(seq_dotclock_divided) && dot_cnt_enable    && dot_cnt == 4'd3) ||
        (seq_8dot_char    && seq_dotclock_divided    && ~(dot_cnt_enable) && dot_cnt == 4'd6) ||
        (~(seq_8dot_char) && ~(seq_dotclock_divided) && dot_cnt_enable    && dot_cnt == 4'd4) ||
        (~(seq_8dot_char) && seq_dotclock_divided    && ~(dot_cnt_enable) && dot_cnt == 4'd7)
    ) &&
    (   (vert_cnt == crtc_vertical_total - 10'd1 && horiz_cnt >= crtc_horizontal_total + 8'd3) ||
        (vert_cnt < crtc_vertical_display_size && (horiz_cnt <= crtc_horizontal_display_size - 8'd2 || horiz_cnt >= crtc_horizontal_total + 8'd3)) ||
        (vert_cnt == crtc_vertical_display_size && horiz_cnt <= crtc_horizontal_display_size - 8'd2)
    );
    
assign dot_memory_load_first_in_frame = dot_memory_load && vert_cnt == crtc_vertical_total - 10'd1 && horiz_cnt == crtc_horizontal_total + 8'd3;
assign dot_memory_load_first_in_line  = dot_memory_load && horiz_cnt == crtc_horizontal_total + 8'd3;
assign dot_memory_load_first_in_line_matched =
    dot_memory_load_first_in_line && (
    (crtc_line_compare > 10'd0 && vert_cnt == crtc_line_compare - 10'd1) ||
    (crtc_line_compare == 10'd0 && vert_cnt == crtc_vertical_total - 10'd1));

assign dot_memory_load_vertical_retrace_start = vert_cnt == crtc_vertical_retrace_start;
    
//------------------------------------------------------------------------------

reg host_io_vertical_retrace_last;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)   host_io_vertical_retrace_last <= 1'b0;
    else                host_io_vertical_retrace_last <= host_io_vertical_retrace;
end

reg [5:0] blink_cnt;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)           blink_cnt <= 6'd0;
    else if(host_io_vertical_retrace_last == 1'b1 && host_io_vertical_retrace == 1'b0) blink_cnt <= blink_cnt + 6'd1;
end

assign blink_txt_value    = blink_cnt[5];
assign blink_cursor_value = blink_cnt[4];

//------------------------------------------------------------------------------

reg vgaprep_horiz_blank;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                       vgaprep_horiz_blank <= 1'b0;
    else if(horiz_cnt == crtc_horizontal_blanking_start)                                                    vgaprep_horiz_blank <= 1'b1;
    else if(horiz_cnt > crtc_horizontal_blanking_start && horiz_cnt[5:0] == crtc_horizontal_blanking_end)   vgaprep_horiz_blank <= 1'b0;
end

reg vgaprep_vert_blank;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                               vgaprep_vert_blank <= 1'b0;
    else if(vert_cnt == crtc_vertical_blanking_start)                                               vgaprep_vert_blank <= 1'b1;
    else if(vert_cnt > crtc_vertical_blanking_start && vert_cnt[7:0] == crtc_vertical_blanking_end) vgaprep_vert_blank <= 1'b0;
end

wire vgaprep_blank = 
    seq_screen_disable || ~(seq_sync_reset_n) || ~(seq_async_reset_n) ||
    //horizontal
    horiz_cnt == crtc_horizontal_blanking_start || (horiz_cnt > crtc_horizontal_blanking_start && vgaprep_horiz_blank && horiz_cnt[5:0] != crtc_horizontal_blanking_end) ||
    //line before vertical blank
    (horiz_cnt >= crtc_horizontal_blanking_start && vert_cnt + 10'd1 == crtc_vertical_blanking_start) ||
    //last line of vertical blank
    ((~(vgaprep_vert_blank) || (vert_cnt[7:0] + 8'd1 != crtc_vertical_blanking_end) || horiz_cnt < crtc_horizontal_blanking_start) &&
        //vertical
        (vert_cnt == crtc_vertical_blanking_start    || (vert_cnt > crtc_vertical_blanking_start && vgaprep_vert_blank && vert_cnt[7:0] != crtc_vertical_blanking_end)));

wire vgaprep_horiz_sync =
    horiz_cnt == (crtc_horizontal_retrace_start + { 6'd0, crtc_horizontal_retrace_skew }) ||
    (horiz_cnt > (crtc_horizontal_retrace_start + { 6'd0, crtc_horizontal_retrace_skew }) && vgareg0_horiz_sync == ~(general_hsync) && horiz_cnt[4:0] != crtc_horizontal_retrace_end);
    
wire vgaprep_vert_sync =
    vert_cnt == crtc_vertical_retrace_start ||
    (vert_cnt > crtc_vertical_retrace_start && vgareg0_vert_sync == ~(general_vsync) && vert_cnt[3:0] != crtc_vertical_retrace_end);
    
//one cycle before input to vgareg_*
assign vgaprep_overscan = 
    (horiz_cnt > crtc_horizontal_display_size  && ~(line_last_dot)) ||
    (horiz_cnt == crtc_horizontal_display_size && character_last_dot) ||
    (vert_cnt > crtc_vertical_display_size     && ~(screen_last_dot)) ||
    (vert_cnt == crtc_vertical_display_size    && line_last_dot);

//------------------------------------------------------------------------------

wire [8:0] sys_readdata_from_ram;

assign sys_readdata = { 23'd0, sys_readdata_from_ram };

reg sys_enabled;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                               sys_enabled <= 1'b0;
    else if(sys_write && sys_writedata[15] == 1'b1) sys_enabled <= sys_writedata[14];
end

wire [8:0] sys_character;
wire [7:0] sys_line;

reg [6:0] sys_horiz_cnt;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                   sys_horiz_cnt <= 7'd0;
    else if(sys_horiz_cnt == 7'd0 && horiz_cnt == 8'd1) sys_horiz_cnt <= 7'd1;
    else if(sys_horiz_cnt > 7'd0)                       sys_horiz_cnt <= sys_horiz_cnt + 7'd1;
end

wire [6:0] sys_horiz_cnt_plus_4 = sys_horiz_cnt + 7'd2;


simple_bidir_ram #(
    .widthad    (8),
    .width      (9)
)
vga_system_ram (
    .clk        (clk_26),

    .address_a  (sys_address),
    .wren_a     (sys_write && sys_writedata[15:9] == 7'd0),
    .data_a     (sys_writedata[8:0]),
    .q_a        (sys_readdata_from_ram),

    .address_b  ({ ((vert_cnt >= 10'd256)? 4'd0 : vert_cnt[7:4]), sys_horiz_cnt_plus_4[6:3] }),
    .q_b        (sys_character)
);

reg sys_inverted;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)   sys_inverted <= 1'b0;
    else                sys_inverted <= sys_character[8];
end

simple_single_rom #(
    .widthad    (11),
    .width      (8),
    .datafile   ("./../soc/vga/vga_font.bin")
)
vga_font_rom_inst (
    .clk        (clk_26),
    .addr       ({ sys_character[6:0], vert_cnt[3:0] }),
    .q          (sys_line)
);

wire sys_pixel =
    (sys_horiz_cnt[2:0] == 3'd0)? sys_line[0] :
    (sys_horiz_cnt[2:0] == 3'd1)? sys_line[1] :
    (sys_horiz_cnt[2:0] == 3'd2)? sys_line[2] :
    (sys_horiz_cnt[2:0] == 3'd3)? sys_line[3] :
    (sys_horiz_cnt[2:0] == 3'd4)? sys_line[4] :
    (sys_horiz_cnt[2:0] == 3'd5)? sys_line[5] :
    (sys_horiz_cnt[2:0] == 3'd6)? sys_line[6] :
                                  sys_line[7];
    
wire [7:0] sys_pixel_color = (sys_pixel ^ sys_inverted)? 8'd255 : 8'd30;

//------------------------------------------------------------------------------

assign host_io_vertical_retrace = vgaprep_vert_sync;
assign host_io_not_displaying   = vgaprep_blank;

reg vgareg_blank_n;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) vgareg_blank_n <= 1'b0; else vgareg_blank_n <= ~(vgaprep_blank); end

reg vgareg0_horiz_sync;
reg vgareg1_horiz_sync;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) vgareg0_horiz_sync <= 1'b0; else vgareg0_horiz_sync <= (vgaprep_horiz_sync && crtc_enable_sync)? ~(general_hsync) : general_hsync; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) vgareg1_horiz_sync <= 1'b0; else vgareg1_horiz_sync <= vgareg0_horiz_sync; end

reg vgareg0_vert_sync;
reg vgareg1_vert_sync;
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) vgareg0_vert_sync <= 1'b0; else vgareg0_vert_sync <= (vgaprep_vert_sync && crtc_enable_sync)? ~(general_vsync) : general_vsync; end
always @(posedge clk_26 or negedge rst_n) begin if(rst_n == 1'b0) vgareg1_vert_sync <= 1'b0; else vgareg1_vert_sync <= vgareg0_vert_sync; end

reg [7:0] vgareg_r;
reg [7:0] vgareg_g;
reg [7:0] vgareg_b;
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                           vgareg_r <= 8'b0;
    else if(sys_enabled && (horiz_cnt == 8'd1 || sys_horiz_cnt > 7'd0) && vert_cnt < 10'd256)   vgareg_r <= sys_pixel_color;
    else                                                                                        vgareg_r <= { dac_color[17:12], 2'b0 };
end
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                           vgareg_g <= 8'b0;
    else if(sys_enabled && (horiz_cnt == 8'd1 || sys_horiz_cnt > 7'd0) && vert_cnt < 10'd256)   vgareg_g <= sys_pixel_color;
    else                                                                                        vgareg_g <= { dac_color[11:6], 2'b0 };
end
always @(posedge clk_26 or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                           vgareg_b <= 8'b0;
    else if(sys_enabled && (horiz_cnt == 8'd1 || sys_horiz_cnt > 7'd0) && vert_cnt < 10'd256)   vgareg_b <= sys_pixel_color;
    else                                                                                        vgareg_b <= { dac_color[5:0], 2'b0 };
end

assign vga_clock  = clk_26;
assign vga_sync_n = 1'b0;

assign vga_blank_n    = vgareg_blank_n;
assign vga_horiz_sync = vgareg1_horiz_sync;
assign vga_vert_sync  = vgareg1_vert_sync;

assign vga_r = vgareg_r;
assign vga_g = vgareg_g;
assign vga_b = vgareg_b;

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, sys_read, sys_writedata[31:16], host_address_reduced_last[16:2], memory_txt_address_base[12:0], sys_character[7], sys_horiz_cnt_plus_4[2:0], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule
