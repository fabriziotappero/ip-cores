//
// display.v -- 30x80 character display, with attributes
//


module display(clk,
               dsp_row, dsp_col, dsp_en, dsp_wr,
               dsp_wr_data, dsp_rd_data,
               hsync, vsync, r, g, b);
    input clk;
    input [4:0] dsp_row;
    input [6:0] dsp_col;
    input dsp_en;
    input dsp_wr;
    input [15:0] dsp_wr_data;
    output [15:0] dsp_rd_data;
    output hsync;
    output vsync;
    output r;
    output g;
    output b;

  wire pixclk;
  wire [4:0] timing_txtrow;
  wire [6:0] timing_txtcol;
  wire [3:0] timing_chrrow;
  wire [2:0] timing_chrcol;
  wire timing_blank;
  wire timing_hsync;
  wire timing_vsync;
  wire timing_blink;
  wire [7:0] dspmem_attcode;
  wire [7:0] dspmem_chrcode;
  wire [3:0] dspmem_chrrow;
  wire [2:0] dspmem_chrcol;
  wire dspmem_blank;
  wire dspmem_hsync;
  wire dspmem_vsync;
  wire dspmem_blink;
  wire [7:0] chrgen_attcode;
  wire chrgen_pixel;
  wire chrgen_blank;
  wire chrgen_hsync;
  wire chrgen_vsync;
  wire chrgen_blink;

  timing timing1(
    .clk(clk),
    .pixclk(pixclk),
    .txtrow(timing_txtrow[4:0]),
    .txtcol(timing_txtcol[6:0]),
    .chrrow(timing_chrrow[3:0]),
    .chrcol(timing_chrcol[2:0]),
    .blank(timing_blank),
    .hsync(timing_hsync),
    .vsync(timing_vsync),
    .blink(timing_blink)
  );

  dspmem dspmem1(
    .rdwr_row(dsp_row[4:0]),
    .rdwr_col(dsp_col[6:0]),
    .wr_data(dsp_wr_data[15:0]),
    .rd_data(dsp_rd_data[15:0]),
    .en(dsp_en),
    .wr(dsp_wr),
    .clk(clk),
    .pixclk(pixclk),
    .txtrow(timing_txtrow[4:0]),
    .txtcol(timing_txtcol[6:0]),
    .attcode(dspmem_attcode[7:0]),
    .chrcode(dspmem_chrcode[7:0]),
    .chrrow_in(timing_chrrow[3:0]),
    .chrcol_in(timing_chrcol[2:0]),
    .blank_in(timing_blank),
    .hsync_in(timing_hsync),
    .vsync_in(timing_vsync),
    .blink_in(timing_blink),
    .chrrow_out(dspmem_chrrow[3:0]),
    .chrcol_out(dspmem_chrcol[2:0]),
    .blank_out(dspmem_blank),
    .hsync_out(dspmem_hsync),
    .vsync_out(dspmem_vsync),
    .blink_out(dspmem_blink)
  );

  chrgen chrgen1(
    .clk(clk),
    .pixclk(pixclk),
    .chrcode(dspmem_chrcode[7:0]),
    .chrrow(dspmem_chrrow[3:0]),
    .chrcol(dspmem_chrcol[2:0]),
    .pixel(chrgen_pixel),
    .attcode_in(dspmem_attcode[7:0]),
    .blank_in(dspmem_blank),
    .hsync_in(dspmem_hsync),
    .vsync_in(dspmem_vsync),
    .blink_in(dspmem_blink),
    .attcode_out(chrgen_attcode[7:0]),
    .blank_out(chrgen_blank),
    .hsync_out(chrgen_hsync),
    .vsync_out(chrgen_vsync),
    .blink_out(chrgen_blink)
  );

  pixel pixel1(
    .clk(clk),
    .pixclk(pixclk),
    .attcode(chrgen_attcode[7:0]),
    .pixel(chrgen_pixel),
    .blank(chrgen_blank),
    .hsync_in(chrgen_hsync),
    .vsync_in(chrgen_vsync),
    .blink(chrgen_blink),
    .hsync(hsync),
    .vsync(vsync),
    .r(r),
    .g(g),
    .b(b)
  );

endmodule
