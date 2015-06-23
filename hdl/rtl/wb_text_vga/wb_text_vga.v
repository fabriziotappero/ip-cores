/*
 * Text-only VGA Controller with Wishbone interface
 *
 * Includes a small Video RAM containing the chars to be shown on screen.
 * Handles the VGA display in common VGA resolution (640x480 @ 60 Hz).
 * Fonts are designed with 8x8 resolution and then spread over 16x16 pixels
 * in order to save memory, thus obtaining 40 columns and 30 rows.
 * It should use only 2 Block RAMs on Xilinx devices (2KB+2KB), one ROM to
 * store the bitmap for each of the 256 chars of the ASCII table and a Video
 * RAM to store the ASCII code for each of the 1200 chars on screen.
 * How it works: just write a byte using the Wishbone slave interface and it
 * will show on screen in black & white.
 */

`define HSYNC_COUNTER_MAX 1600
`define HSYNC_PULSE_START 1312
`define HSYNC_PULSE_STOP  1504

`define VSYNC_COUNTER_MAX 521
`define VSYNC_PULSE_START 490
`define VSYNC_PULSE_STOP  492

module wb_text_vga (

    // System
    input sys_clock_i,
    input sys_reset_i,

    // Wishbone slave interface
    input wb_cyc_i,
    input wb_stb_i,
    input wb_we_i,
    input[3:0] wb_sel_i,
    input[31:0] wb_adr_i,
    input[31:0] wb_dat_i,
    output wb_ack_o,
    output[31:0] wb_dat_o,

    // VGA Port
    output vga_rgb_r_o,
    output vga_rgb_g_o,
    output vga_rgb_b_o,
    output reg vga_hsync_o,
    output reg vga_vsync_o

  );

  /*
   * Registers
   */

  // Current position of the cursor
  reg[5:0] text_col;
  reg[4:0] text_row;

  // Horizontal and vertical counters
  reg[10:0] hcounter;
  reg[9:0] vcounter;

  /*
   * Wires
   */

  // Coordinates of the pixel being drawn
  wire[9:0] pixel_x;
  wire[8:0] pixel_y;

  // Video RAM port 1 wires (read/write)
  wire ram_write1;
  wire[10:0] ram_address1;
  wire[7:0] ram_wdata1;
  wire[7:0] ram_rdata1;

  // Video RAM port 2 wires (read-only)
  wire[10:0] ram_address2;
  wire[7:0] ram_rdata2;

  // Fontmap ROM wires
  wire rom_enable;
  wire[10:0] rom_address;
  wire[7:0] rom_data;

  /*
   * Module instances
   */

  // Video RAM instance
  video_ram video_ram_0 (

    // System
    .sys_clock_i(sys_clock_i),

    // Port 1 (read/write)
    .write1_i(ram_write1),
    .address1_i(ram_address1),
    .data1_i(ram_wdata1),
    .data1_o(ram_rdata1),

    // Port 2 (read-only)
    .address2_i(ram_address2),
    .data2_o(ram_rdata2)
  );

  // Fontmap ROM instance
  fontmap_rom fontmap_rom_0 (
    .sys_clock_i(sys_clock_i),
    .read_i(rom_enable),
    .address_i(rom_address),
    .data_o(rom_data)
  );

  /*
   * Combinational logic
   */

  // Wishbone request is always served immediately
  assign wb_ack_o = (wb_cyc_i && wb_stb_i);

  // No Wishbone read allowed
  assign wb_dat_o = 32'h00000000;

  // Wishbone writes go directly to Video RAM
  assign ram_write1 = (wb_cyc_i && wb_stb_i && wb_we_i);
  assign ram_wdata1 = wb_dat_i[7:0];

  // The address of the write to Video RAM is the coordinate of the next char
  assign ram_address1 = { text_row , text_col };

  // The second port of the Video RAM is used to retrieve the ASCII code of the char to be shown on screen
  assign ram_address2 = { vcounter[9:5] , hcounter[10:5] };

  // Read continuously from ROM
  assign rom_enable = 1;

  // The address of the read from Fontmap ROM is the ASCII code concatenated with the number of line in the char
  assign rom_address = { ram_rdata2 , vcounter[4:2] };

  // Now draw the pixel in black & white
  assign vga_rgb_r_o = rom_data[8-hcounter[4:2]];
  assign vga_rgb_g_o = rom_data[8-hcounter[4:2]];
  assign vga_rgb_b_o = rom_data[8-hcounter[4:2]];

  /*
   * Sequential logic
   */

  always @(posedge sys_clock_i) begin

    if(sys_reset_i) begin

      // Reset registers
      text_row <= 0;
      text_col <= 0;
      hcounter <= 0;
      vcounter <= 0;

      // Clear outputs
      vga_hsync_o <= 1;
      vga_vsync_o <= 1;

    end else begin

      // Update counters and handle upper bounds
      if (hcounter == (`HSYNC_COUNTER_MAX-1) ) begin
        hcounter <= 0;
        if (vcounter == (`VSYNC_COUNTER_MAX-1) ) begin
          vcounter <= 0;
        end else begin
          vcounter <= vcounter + 1;
        end
      end else begin
        hcounter <= hcounter + 1;
      end

      // Drive sync outputs 
      if(hcounter>=`HSYNC_PULSE_START && hcounter<`HSYNC_PULSE_STOP)
        vga_hsync_o <= 0;
      else
        vga_hsync_o <= 1;
      if(vcounter>=`VSYNC_PULSE_START && vcounter<`VSYNC_PULSE_STOP)
        vga_vsync_o <= 0;
      else
        vga_vsync_o <= 1;

      // Handle the writing from the Wishbone bus
      if(wb_cyc_i && wb_stb_i && wb_we_i) begin

        // Handle cursor position including New Line Feed
        if(text_col==39 || wb_dat_i[7:0]==8'h0A) begin
          text_col <= 0;
          if(text_row==29) begin
            text_row <= 0;
          end else begin
            text_row <= text_row + 1;
          end
        end else begin
          text_col <= text_col + 1;
        end

        // During simulation print char to stdout
        $display("WB-TEXT: Print char '%c'", wb_dat_i[7:0]);

      end
    end
  end

endmodule
