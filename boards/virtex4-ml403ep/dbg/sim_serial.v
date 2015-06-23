`timescale 1ns/10ps

module sim_serial;

  // Registers and nets
  reg  clk_100M;
  reg  rst;
  reg  stb;
  wire clk_921600;
  wire trx_;
  wire rst2;
  wire ack;

  // Module instantiation
  clk_uart clk0 (
    .clk_100M   (clk_100M),
    .rst        (rst),
    .clk_921600 (clk_921600),
    .rst2       (rst2)
  );

  send_serial ser0 (
    .trx_     (trx_),
    .wb_clk_i (clk_921600),
    .wb_rst_i (rst2),
    .wb_dat_i (8'h4b),
    .wb_we_i  (1'b1),
    .wb_stb_i (stb),
    .wb_cyc_i (1'b1),
    .wb_ack_o (ack)
  );

  // Behaviour
  initial
    begin
           stb      <= 1'b1;
           clk_100M <= 1'b0;
           rst      <= 1'b1;
      #400 rst      <= 1'b0;
      #95490 stb    <= 1'b0;
      #40000 stb    <= 1'b1;
    end

  // clk_50M
  always #5 clk_100M <= !clk_100M;
endmodule
