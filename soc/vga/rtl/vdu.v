/*
 *  Copyright (c) 2008  Zeus Gomez Marmolejo <zeus@opencores.org>
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

`timescale 1ns/10ps

module vdu (
    // Wishbone signals
    input             wb_clk_i,     // 25 Mhz VDU clock
    input             wb_rst_i,
    input      [15:0] wb_dat_i,
    output reg [15:0] wb_dat_o,
    input      [11:1] wb_adr_i,
    input             wb_we_i,
    input             wb_tga_i,
    input      [ 1:0] wb_sel_i,
    input             wb_stb_i,
    input             wb_cyc_i,
    output            wb_ack_o,

    // VGA pad signals
    output reg [ 1:0] vga_red_o,
    output reg [ 1:0] vga_green_o,
    output reg [ 1:0] vga_blue_o,
    output reg        horiz_sync,
    output reg        vert_sync
  );

  // Net, registers and parameters

  // Synchronization constants, these values are taken from:
  //  http://tinyvga.com/vga-timing/640x400@70Hz

  parameter HOR_DISP_END = 10'd639; // Last horizontal pixel displayed
  parameter HOR_SYNC_BEG = 10'd655; // Start of horizontal synch pulse
  parameter HOR_SYNC_END = 10'd751; // End of Horizontal Synch pulse
  parameter HOR_SCAN_END = 10'd799; // Last pixel in scan line
  parameter HOR_DISP_CHR = 80;      // Number of characters displayed per row
  parameter HOR_VIDEO_ON = 10'd7;   // When to start displaying characters
  parameter HOR_VIDEO_OFF = 10'd647; // When to stop displaying characters

  parameter VER_DISP_END = 9'd400;  // last row displayed
  parameter VER_SYNC_BEG = 9'd411;  // start of vertical synch pulse
  parameter VER_SYNC_END = 9'd413;  // end of vertical synch pulse
  parameter VER_SCAN_END = 9'd448;  // Last scan row in the frame
  parameter VER_DISP_CHR = 6'd25;   // Number of character rows displayed

  reg        cursor_on_v;
  reg        cursor_on_h;
  reg        video_on_v;
  reg        video_on_h;
  reg [9:0]  h_count;
  reg [8:0]  v_count;       // 0 to VER_SCAN_END
  reg [22:0] blink_count;

  // Character generator ROM
  wire        char_cs;
  wire        char_we;
  wire [11:0] char_addr;
  wire [7:0]  char_data_in;
  wire [7:0]  char_data_out;

  // Control registers
  reg [3:0] reg_adr;
  reg [6:0] reg_hcursor; // 80 columns
  reg [4:0] reg_vcursor; // 25 rows
  reg [3:0] reg_cur_start;
  reg [3:0] reg_cur_end;

  wire      wr_adr;
  wire      wr_reg;
  wire      write;
  wire      wr_hcursor;
  wire      wr_vcursor;
  wire      wr_cur_start;
  wire      wr_cur_end;

  // Video shift register
  reg [7:0] vga_shift;
  reg [2:0] vga_fg_colour;
  reg [2:0] vga_bg_colour;
  reg       cursor_on;
  wire      cursor_on1;
  reg       video_on;
  wire      video_on1;

  // vga character ram access bus
  reg   [6:0] col_addr;  // 0 to 79
  reg   [4:0] row_addr;  // 0 to 49 (25 * 2 -1)
  reg   [6:0] col1_addr; // 0 to 79
  reg   [4:0] row1_addr; // 0 to 49 (25 * 2 - 1)
  reg   [6:0] hor_addr;  // 0 to 79
  reg   [6:0] ver_addr;  // 0 to 124
  reg         vga0_we;
  reg         vga0_rw, vga1_rw, vga2_rw, vga3_rw, vga4_rw, vga5_rw;
  reg         vga1_we;
  reg         vga2_we;
  reg         buff_we;
  reg   [7:0] buff_data_in;
  reg         attr_we;
  reg   [7:0] attr_data_in;
  reg  [10:0] buff_addr;
  reg  [10:0] attr0_addr;
  reg         attr0_we;
  reg  [10:0] buff0_addr;
  reg         buff0_we;
  reg  [10:0] attr_addr;
  reg         intense;
  wire        vga_cs;
  wire  [7:0] vga_data_out;
  wire  [7:0] attr_data_out;
  wire [10:0] vga_addr;  // 2K byte character buffer
  wire [15:0] out_data;
  wire        fg_or_bg;
  wire        stb;
  wire        brown_bg;
  wire        brown_fg;
  wire        status_reg1;
  wire        vh_retrace;
  wire        v_retrace;

  // Module instantiation
  char_rom vdu_char_rom (
    .clk   (wb_clk_i),
    .rst   (wb_rst_i),
    .cs    (char_cs),
    .we    (char_we),
    .addr  (char_addr),
    .wdata (char_data_in),
    .rdata (char_data_out)
  );

  ram_2k char_buff_ram (
    .clk   (wb_clk_i),
    .rst   (wb_rst_i),
    .cs    (vga_cs),
    .we    (buff_we),
    .addr  (buff_addr),
    .wdata (buff_data_in),
    .rdata (vga_data_out)
  );

  ram_2k_attr attr_buff_ram (
    .clk   (wb_clk_i),
    .rst   (wb_rst_i),
    .cs    (vga_cs),
    .we    (attr_we),
    .addr  (attr_addr),
    .wdata (attr_data_in),
    .rdata (attr_data_out)
  );

  // Assignments
  assign video_on1  = video_on_h && video_on_v;
  assign cursor_on1 = cursor_on_h && cursor_on_v;
  assign char_cs    = 1'b1;
  assign char_we    = 1'b0;
  assign char_data_in = 8'b0;
  assign char_addr  = { vga_data_out, v_count[3:0] };
  assign vga_addr   = { 4'b0, hor_addr} + { ver_addr, 4'b0 };
  assign out_data   = {attr_data_out, vga_data_out};

  assign vga_cs     = 1'b1;
  assign stb        = wb_stb_i && wb_cyc_i;

  assign fg_or_bg    = vga_shift[7] ^ cursor_on;
  assign brown_fg    = (vga_fg_colour==3'd6) && !intense;
  assign brown_bg    = (vga_bg_colour==3'd6);

  // Control registers
  assign write        = wb_tga_i & wb_stb_i & wb_cyc_i & wb_we_i;
  assign wr_adr       = write & wb_sel_i[0];
  assign wr_reg       = write & wb_sel_i[1];
  assign wr_hcursor   = wr_reg & (reg_adr==4'hf);
  assign wr_vcursor   = wr_reg & (reg_adr==4'he);
  assign wr_cur_start = wr_reg & (reg_adr==4'ha);
  assign wr_cur_end   = wr_reg & (reg_adr==4'hb);

  assign v_retrace   = !video_on_v;
  assign vh_retrace  = v_retrace | !video_on_h;
  assign status_reg1 = { 11'b0, v_retrace, 3'b0, vh_retrace };
  assign wb_ack_o    = wb_tga_i ? stb : vga5_rw;

  // Behaviour
  // CPU write interface
  always @(posedge wb_clk_i)
    if (wb_rst_i)
      begin
        attr0_addr    <= 11'b0;
        attr0_we      <= 1'b0;
        attr_data_in  <= 8'h0;
        buff0_addr    <= 11'b0;
        buff0_we      <= 1'b0;
        buff_data_in  <= 8'h0;
      end
    else
      begin
        if (stb && !wb_tga_i)
          begin
            attr0_addr   <= wb_adr_i;
            attr0_we     <= wb_we_i & wb_sel_i[1];
            attr_data_in <= wb_dat_i[15:8];
            buff0_addr   <= wb_adr_i;
            buff0_we     <= wb_we_i & wb_sel_i[0];
            buff_data_in <= wb_dat_i[7:0];
          end
      end

  // CPU read interface
  // wb_dat_o
  always @(posedge wb_clk_i)
    wb_dat_o <= wb_rst_i ? 16'h0 : (wb_tga_i ? status_reg1
                                 : (vga4_rw ? out_data : wb_dat_o));

  // Control registers
  always @(posedge wb_clk_i)
    reg_adr <= wb_rst_i ? 4'h0
      : (wr_adr ? wb_dat_i[3:0] : reg_adr);

  always @(posedge wb_clk_i)
    reg_hcursor <= wb_rst_i ? 7'h0
      : (wr_hcursor ? wb_dat_i[14:8] : reg_hcursor);

  always @(posedge wb_clk_i)
    reg_vcursor <= wb_rst_i ? 5'h0
      : (wr_vcursor ? wb_dat_i[12:8] : reg_vcursor);

  always @(posedge wb_clk_i)
    reg_cur_start <= wb_rst_i ? 4'he
      : (wr_cur_start ? wb_dat_i[11:8] : reg_cur_start);

  always @(posedge wb_clk_i)
    reg_cur_end <= wb_rst_i ? 4'hf
      : (wr_cur_end ? wb_dat_i[11:8] : reg_cur_end);

  // Sync generation & timing process
  // Generate horizontal and vertical timing signals for video signal
  always @(posedge wb_clk_i)
    if (wb_rst_i)
      begin
        h_count     <= 10'b0;
        horiz_sync  <= 1'b1;
        v_count     <= 9'b0;
        vert_sync   <= 1'b1;
        video_on_h  <= 1'b1;
        video_on_v  <= 1'b1;
        cursor_on_h <= 1'b0;
        cursor_on_v <= 1'b0;
        blink_count <= 22'b0;
      end
    else
      begin
        h_count    <= (h_count==HOR_SCAN_END) ? 10'b0 : h_count + 10'b1;
        horiz_sync <= (h_count==HOR_SYNC_BEG) ? 1'b0
                    : ((h_count==HOR_SYNC_END) ? 1'b1 : horiz_sync);
        v_count    <= (v_count==VER_SCAN_END && h_count==HOR_SCAN_END) ? 9'b0
                    : ((h_count==HOR_SYNC_END) ? v_count + 9'b1 : v_count);
        vert_sync  <= (v_count==VER_SYNC_BEG) ? 1'b0
                    : ((v_count==VER_SYNC_END) ? 1'b1 : vert_sync);
        video_on_h <= (h_count==HOR_VIDEO_ON) ? 1'b1
                    : ((h_count==HOR_VIDEO_OFF) ? 1'b0 : video_on_h);
        video_on_v <= (v_count==9'h0) ? 1'b1
                    : ((v_count==VER_DISP_END) ? 1'b0 : video_on_v);
        cursor_on_h <= (h_count[9:3] == reg_hcursor[6:0]);
        cursor_on_v <= (v_count[8:4] == reg_vcursor[4:0])
                    && (v_count[3:0] >= reg_cur_start)
                    && (v_count[3:0] <= reg_cur_end);
        blink_count <= blink_count + 22'd1;
      end

  // Video memory access
  always @(posedge wb_clk_i)
    if (wb_rst_i)
      begin
        vga0_we <= 1'b0;
        vga0_rw <= 1'b1;
        row_addr <= 5'b0;
        col_addr <= 7'b0;

        vga1_we  <= 1'b0;
        vga1_rw  <= 1'b1;
        row1_addr <= 5'b0;
        col1_addr <= 7'b0;

        vga2_we  <= 1'b0;
        vga2_rw  <= 1'b0;
        vga3_rw  <= 1'b0;
        vga4_rw  <= 1'b0;
        vga5_rw  <= 1'b0;
        ver_addr <= 7'b0;
        hor_addr <= 7'b0;

        buff_addr <= 10'b0;
        attr_addr <= 10'b0;
        buff_we   <= 1'b0;
        attr_we   <= 1'b0;
      end
    else
      begin
        // on h_count = 0 initiate character write
        // all other cycles are reads
        case (h_count[2:0])
          3'b000:   // pipeline character write
            begin
              vga0_we <= wb_we_i;
              vga0_rw <= stb;
            end
          default:  // other 6 cycles free
            begin
              vga0_we <= 1'b0;
              vga0_rw <= 1'b0;
              col_addr <= h_count[9:3];
              row_addr <= v_count[8:4];
            end
        endcase

        // on vdu_clk + 1 round off row address
        // row1_addr = (row_addr % 80)
        vga1_we <= vga0_we;
        vga1_rw <= vga0_rw;
        row1_addr <= (row_addr < VER_DISP_CHR) ? row_addr
                    : row_addr - VER_DISP_CHR;
        col1_addr <= col_addr;

        // on vdu_clk + 2 calculate vertical address
        // ver_addr = (row_addr % 80) x 5
        vga2_we <= vga1_we;
        vga2_rw <= vga1_rw;
        ver_addr <= { 2'b00, row1_addr } + { row1_addr, 2'b00 }; // x5
        hor_addr <= col1_addr;

        // on vdu_clk + 3 calculate memory address
        // vga_addr = (row_addr % 80) * 80 + hor_addr
        buff_addr <= vga2_rw ? buff0_addr : vga_addr;
        attr_addr <= vga2_rw ? attr0_addr : vga_addr;
        buff_we   <= vga2_rw ? (buff0_we & vga2_we) : 1'b0;
        attr_we   <= vga2_rw ? (attr0_we & vga2_we) : 1'b0;
        vga3_rw   <= vga2_rw;
        vga4_rw   <= vga3_rw;
        vga5_rw   <= vga4_rw;
      end

  // Video shift register
  always @(posedge wb_clk_i)
    if (wb_rst_i)
      begin
        video_on      <= 1'b0;
        cursor_on     <= 1'b0;
        vga_bg_colour <= 3'b000;
        vga_fg_colour <= 3'b111;
        vga_shift     <= 8'b00000000;
        vga_red_o     <= 1'b0;
        vga_green_o   <= 1'b0;
        vga_blue_o    <= 1'b0;
      end
    else
      begin
        if (h_count[2:0] == 3'b000)
          begin
            video_on      <= video_on1;
            cursor_on     <= (cursor_on1 | attr_data_out[7]) & blink_count[22];
            vga_fg_colour <= attr_data_out[2:0];
            vga_bg_colour <= attr_data_out[6:4];
            intense       <= attr_data_out[3];
            vga_shift     <= char_data_out;
          end
        else vga_shift <= { vga_shift[6:0], 1'b0 };

        //
        // Colour mask is
        //  7  6  5  4  3  2  1  0
        //  X BR BG BB  X FR FG FB
        //
        vga_blue_o   <= video_on ? (fg_or_bg ? { vga_fg_colour[0], intense }
                                            : { vga_bg_colour[0], 1'b0 })
                                : 2'b0;

        // Green color exception with color brown
        // http://en.wikipedia.org/wiki/Color_Graphics_Adapter#With_an_RGBI_monitor
        vga_green_o  <= video_on ?
           (fg_or_bg ? (brown_fg ? 2'b01 : { vga_fg_colour[1], intense })
                     : (brown_bg ? 2'b01 : { vga_bg_colour[1], 1'b0 }))
                                : 2'b0;
        vga_red_o    <= video_on ? (fg_or_bg ? { vga_fg_colour[2], intense }
                                            : { vga_bg_colour[2], 1'b0 })
                                : 2'b0;
      end
endmodule
