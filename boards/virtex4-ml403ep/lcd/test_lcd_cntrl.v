module lcd_test (
    // Pad signals
    input        clk_,
    output       rs_,
    output       rw_,
    output       e_,
    inout  [3:0] db_,
    input        but_,
    output [5:0] led_
  );

  // Registers
  reg [4:0] cnt;

  // Module instantiations
  lcd_display4 lcd0 (
    .clk (cnt[4]),
    .rst (but_),
    .f1  (64'h123456f890abcde7),
    .f2  (64'h7645321dcbaef987),
    .m1  (16'b0101011101011111),
    .m2  (16'b1110101110101111),

    .rs_ (rs_),
    .rw_ (rw_),
    .e_  (e_),
    .db_ (db_),
    .st  (led_)
  );

  // Behaviour
  always @(posedge clk_) cnt <= cnt + 5'b1;
endmodule
