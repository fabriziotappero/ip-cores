 /*
  *  Phase accumulator clock:
  *   Fo = Fc * N / 2^bits
  *   here N: 12507 and bits: 32
  *   it gives a frequency of 18.200080376 Hz
  */

module timer #(
    parameter res   = 33,   // bit resolution (default: 33 bits)
    parameter phase = 12507 // phase value for the counter
  )
  (
    // Wishbone slave interface
    input      wb_clk_i,
    input      wb_rst_i,
    output reg wb_tgc_o   // intr
  );

  // Registers and nets
  reg [res-1:0] cnt;
  reg           old_clk2;
  wire          clk2;

  // Continuous assignments
  assign clk2 = cnt[res-1];

  // Behaviour
  // cnt
  always @(posedge wb_clk_i)
    cnt <= wb_rst_i ? 0 : (cnt + phase);

  // old_clk2
  always @(posedge wb_clk_i)
    old_clk2 <= wb_rst_i ? 1'b0 : clk2;

  // intr
  always @(posedge wb_clk_i)
    wb_tgc_o <= wb_rst_i ? 1'b0 : (!old_clk2 & clk2);

endmodule
