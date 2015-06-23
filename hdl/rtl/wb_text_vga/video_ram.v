/*
 * Text-only Video RAM
 *
 * Dual-port RAM containing the ASCII codes for chars to be displayed on screen.
 * Text resolution is 64x32 or less (e.g. 40x30).
 * Address bits [10:5] specify the column and bits [4:0] the row.
 */

// synthesis attribute ram_style of video_ram is block;
module video_ram (

    // System
    input sys_clock_i,

    // Port 1 (read/write)
    input write1_i,
    input[10:0] address1_i,
    input [7:0] data1_i,
    output reg[7:0] data1_o,

    // Port 2 (read-only)
    input[10:0] address2_i,
    output reg[7:0] data2_o

  );

  // Memory array
  reg[7:0] VRAM[2047:0];

  // Initialize memory content
  integer i;
  initial begin
    for(i=0; i<2048; i=i+1)
      VRAM[i] <= 8'h00;
  end

  always @(posedge sys_clock_i) begin
    if (write1_i) begin
      VRAM[address1_i] <= data1_i;
    end
    data1_o <= VRAM[address1_i];
    data2_o <= VRAM[address2_i];
  end

endmodule
