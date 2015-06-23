/*******************************************************************************
 *
 * Copyright 2012, Sinclair R.F., Inc.
 *
 * Test bench for hello_world.v.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

// 100 MHz clock (as per hello_world.9x8/baudmethod)
reg s_clk = 1'b1;
always @ (s_clk) s_clk <= #5 ~s_clk;

reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk);
  s_rst <= 1'b0;
  repeat((13+1)*10*((100_000_000+115200/2)/115200+12)) @ (posedge s_clk);
  $finish;
end

wire s_UART_Tx;
hello_world uut(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // outport ports
  .o_UART_Tx    (s_UART_Tx)
);

localparam baud = 115200;
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
    $display("%13d : Malformed UART transmition", $time);
  else if ((8'h20 <= deser[0+:8]) && (deser[0+:8]<=8'h80))
    $display("%13d : Sent 0x%02H : %c", $time, deser[0+:8], deser[0+:8]);
  else
    $display("%13d : Sent 0x%02H", $time, deser[0+:8]);
end

initial begin
  $dumpfile("tb.vcd");
  $dumpvars();
end

endmodule
