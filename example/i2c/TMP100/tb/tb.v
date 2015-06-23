/*******************************************************************************
 *
 * Copyright 2012, Sinclair R.F., Inc.
 *
 * Test bench for examples/i2c_tmp100
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

// 97 MHz clock
reg s_clk = 1'b1;
always @ (s_clk) s_clk <= #5.155 ~s_clk;

reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk);
  s_rst <= 1'b0;
end

tri1 s_SCL;
tri1 s_SDA;
wire s_UART_Tx;
i2c_tmp100 it_inst(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // I2C ports
  .io_scl       (s_SCL),
  .io_sda       (s_SDA),
  // UART_Tx ports
  .o_UART_Tx    (s_UART_Tx)
);

integer ix_i2c;
reg [0:26] i2c_out = 27'b111111110_101010101_010100001;
reg s_sensor_sda = 1'b1;
initial begin
  @ (negedge s_SDA);
  if (s_SCL == 1'b0) begin
    $display("%13d : Malformed I2C start signal");
    $finish;
  end
  ix_i2c = 0;
  repeat (27) begin
    @ (negedge s_SCL);
    #700;
    s_sensor_sda = i2c_out[ix_i2c];
    ix_i2c = ix_i2c + 1;
  end
  s_sensor_sda = 1'b1;
end
assign s_SDA = (s_sensor_sda) ? 1'bz : 1'b0;

localparam baud = 9600;
localparam dt_baud = 1.0e9/baud;
reg [8:0] deser = 9'h1FF;
initial forever begin
  @ (negedge s_UART_Tx);
  #(dt_baud/2.0);
  repeat (9) begin
    #dt_baud;
    deser = { s_UART_Tx, deser[1+:8] };
  end
  if (deser[8] != 1'b1)
    $display("%13d : Malformed UART transmition, $time");
  else if ((8'h20 <= deser[0+:8]) && (deser[0+:8]<=8'h80))
    $display("%13d : Sent 0x%02H : %c", $time, deser[0+:8], deser[0+:8]);
  else
    $display("%13d : Sent 0x%02H", $time, deser[0+:8]);
end

// Progress meter
initial forever begin #100_000_000; $display("%13d : progress report", $time); end

// terminate after 10 msec (use 2.1e9 for 2.1 sec)
initial begin
  while ($realtime < 1.0e7) @ (posedge s_clk);
  $finish;
end

initial begin
  $dumpfile("tb.lxt");
  $dumpvars();
end

endmodule
