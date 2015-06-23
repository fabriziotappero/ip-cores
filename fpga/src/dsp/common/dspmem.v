//
// dspmem.v -- display memory
//


module dspmem(rdwr_row, rdwr_col, wr_data, rd_data, en, wr,
              clk, pixclk,
              txtrow, txtcol, attcode, chrcode,
              chrrow_in, chrcol_in, blank_in,
              hsync_in, vsync_in, blink_in,
              chrrow_out, chrcol_out, blank_out,
              hsync_out, vsync_out, blink_out);
    input [4:0] rdwr_row;
    input [6:0] rdwr_col;
    input [15:0] wr_data;
    output [15:0] rd_data;
    input en;
    input wr;
    input clk;
    input pixclk;
    input [4:0] txtrow;
    input [6:0] txtcol;
    output [7:0] attcode;
    output [7:0] chrcode;
    input [3:0] chrrow_in;
    input [2:0] chrcol_in;
    input blank_in;
    input hsync_in;
    input vsync_in;
    input blink_in;
    output reg [3:0] chrrow_out;
    output reg [2:0] chrcol_out;
    output reg blank_out;
    output reg hsync_out;
    output reg vsync_out;
    output reg blink_out;

  wire [11:0] rdwr_addr;
  wire [3:0] rdwr_din_n3;
  wire [3:0] rdwr_din_n2;
  wire [3:0] rdwr_din_n1;
  wire [3:0] rdwr_din_n0;
  wire [3:0] rdwr_dout_n3;
  wire [3:0] rdwr_dout_n2;
  wire [3:0] rdwr_dout_n1;
  wire [3:0] rdwr_dout_n0;

  wire [11:0] rfsh_addr;
  wire [3:0] rfsh_din_n3;
  wire [3:0] rfsh_din_n2;
  wire [3:0] rfsh_din_n1;
  wire [3:0] rfsh_din_n0;
  wire [3:0] rfsh_dout_n3;
  wire [3:0] rfsh_dout_n2;
  wire [3:0] rfsh_dout_n1;
  wire [3:0] rfsh_dout_n0;

  assign rdwr_addr[11:7] = rdwr_row[4:0];
  assign rdwr_addr[6:0] = rdwr_col[6:0];
  assign rdwr_din_n3 = wr_data[15:12];
  assign rdwr_din_n2 = wr_data[11: 8];
  assign rdwr_din_n1 = wr_data[ 7: 4];
  assign rdwr_din_n0 = wr_data[ 3: 0];
  assign rd_data[15:12] = rdwr_dout_n3;
  assign rd_data[11: 8] = rdwr_dout_n2;
  assign rd_data[ 7: 4] = rdwr_dout_n1;
  assign rd_data[ 3: 0] = rdwr_dout_n0;

  assign rfsh_addr[11:7] = txtrow[4:0];
  assign rfsh_addr[6:0] = txtcol[6:0];
  assign rfsh_din_n3 = 4'b0000;
  assign rfsh_din_n2 = 4'b0000;
  assign rfsh_din_n1 = 4'b0000;
  assign rfsh_din_n0 = 4'b0000;
  assign attcode[7:4] = rfsh_dout_n3;
  assign attcode[3:0] = rfsh_dout_n2;
  assign chrcode[7:4] = rfsh_dout_n1;
  assign chrcode[3:0] = rfsh_dout_n0;

  // RAMB16_S4_S4: Spartan-3 4k x 4 Dual-Port RAM

  RAMB16_S4_S4 display_att_hi (
    .DOA(rdwr_dout_n3),  // Port A 4-bit Data Output
    .DOB(rfsh_dout_n3),  // Port B 4-bit Data Output
    .ADDRA(rdwr_addr),   // Port A 12-bit Address Input
    .ADDRB(rfsh_addr),   // Port B 12-bit Address Input
    .CLKA(clk),          // Port A Clock
    .CLKB(clk),          // Port B Clock
    .DIA(rdwr_din_n3),   // Port A 4-bit Data Input
    .DIB(rfsh_din_n3),   // Port B 4-bit Data Input
    .ENA(en),            // Port A RAM Enable Input
    .ENB(pixclk),        // Port B RAM Enable Input
    .SSRA(1'b0),         // Port A Synchronous Set/Reset Input
    .SSRB(1'b0),         // Port B Synchronous Set/Reset Input
    .WEA(wr),            // Port A Write Enable Input
    .WEB(1'b0)           // Port B Write Enable Input
  );

  `include "dspatthi.init"

  // RAMB16_S4_S4: Spartan-3 4k x 4 Dual-Port RAM

  RAMB16_S4_S4 display_att_lo (
    .DOA(rdwr_dout_n2),  // Port A 4-bit Data Output
    .DOB(rfsh_dout_n2),  // Port B 4-bit Data Output
    .ADDRA(rdwr_addr),   // Port A 12-bit Address Input
    .ADDRB(rfsh_addr),   // Port B 12-bit Address Input
    .CLKA(clk),          // Port A Clock
    .CLKB(clk),          // Port B Clock
    .DIA(rdwr_din_n2),   // Port A 4-bit Data Input
    .DIB(rfsh_din_n2),   // Port B 4-bit Data Input
    .ENA(en),            // Port A RAM Enable Input
    .ENB(pixclk),        // Port B RAM Enable Input
    .SSRA(1'b0),         // Port A Synchronous Set/Reset Input
    .SSRB(1'b0),         // Port B Synchronous Set/Reset Input
    .WEA(wr),            // Port A Write Enable Input
    .WEB(1'b0)           // Port B Write Enable Input
  );

  `include "dspattlo.init"

  // RAMB16_S4_S4: Spartan-3 4k x 4 Dual-Port RAM

  RAMB16_S4_S4 display_chr_hi (
    .DOA(rdwr_dout_n1),  // Port A 4-bit Data Output
    .DOB(rfsh_dout_n1),  // Port B 4-bit Data Output
    .ADDRA(rdwr_addr),   // Port A 12-bit Address Input
    .ADDRB(rfsh_addr),   // Port B 12-bit Address Input
    .CLKA(clk),          // Port A Clock
    .CLKB(clk),          // Port B Clock
    .DIA(rdwr_din_n1),   // Port A 4-bit Data Input
    .DIB(rfsh_din_n1),   // Port B 4-bit Data Input
    .ENA(en),            // Port A RAM Enable Input
    .ENB(pixclk),        // Port B RAM Enable Input
    .SSRA(1'b0),         // Port A Synchronous Set/Reset Input
    .SSRB(1'b0),         // Port B Synchronous Set/Reset Input
    .WEA(wr),            // Port A Write Enable Input
    .WEB(1'b0)           // Port B Write Enable Input
  );

  `include "dspchrhi.init"

  // RAMB16_S4_S4: Spartan-3 4k x 4 Dual-Port RAM

  RAMB16_S4_S4 display_chr_lo (
    .DOA(rdwr_dout_n0),  // Port A 4-bit Data Output
    .DOB(rfsh_dout_n0),  // Port B 4-bit Data Output
    .ADDRA(rdwr_addr),   // Port A 12-bit Address Input
    .ADDRB(rfsh_addr),   // Port B 12-bit Address Input
    .CLKA(clk),          // Port A Clock
    .CLKB(clk),          // Port B Clock
    .DIA(rdwr_din_n0),   // Port A 4-bit Data Input
    .DIB(rfsh_din_n0),   // Port B 4-bit Data Input
    .ENA(en),            // Port A RAM Enable Input
    .ENB(pixclk),        // Port B RAM Enable Input
    .SSRA(1'b0),         // Port A Synchronous Set/Reset Input
    .SSRB(1'b0),         // Port B Synchronous Set/Reset Input
    .WEA(wr),            // Port A Write Enable Input
    .WEB(1'b0)           // Port B Write Enable Input
  );

  `include "dspchrlo.init"

  always @(posedge clk) begin
    if (pixclk == 1) begin
      chrrow_out <= chrrow_in;
      chrcol_out <= chrcol_in;
      blank_out <= blank_in;
      hsync_out <= hsync_in;
      vsync_out <= vsync_in;
      blink_out <= blink_in;
    end
  end

endmodule
