

module test_serial (
    input  clk_,
    output trx_
  );

  // Registers and nets
  wire clk_100M;
  wire rst;
  wire clk_921600;
  wire rst2;
  wire ack;
  wire lock;
  wire [19:0] inc_dat;
  reg  [19:0] dat;

  // Module instantiation
  clocks c0 (
    .CLKIN_IN   (clk_),
    .CLK0_OUT   (clk_100M),
    .LOCKED_OUT (lock)
  );

  clk_uart clk0 (
    .clk_100M   (clk_100M),
    .rst        (rst),
    .clk_921600 (clk_921600),
    .rst2       (rst2)
  );

  send_addr ser0 (
    .trx_     (trx_),
    .wb_clk_i (clk_921600),
    .wb_rst_i (rst2),
    .wb_dat_i (dat),
    .wb_we_i  (1'b1),
    .wb_stb_i (1'b1),
    .wb_cyc_i (1'b1),
    .wb_ack_o (ack)
  );

  assign rst = !lock;
  assign inc_dat = dat + 20'h1;

  always @(posedge clk_921600)
    dat <= rst2 ? 20'h12345 : (ack ? inc_dat : dat);
endmodule
