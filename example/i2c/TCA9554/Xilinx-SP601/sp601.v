/*******************************************************************************
 *
 * Copyright 2012, Sinclair R.F., Inc.
 *
 * Top-level module to demonstrate reading four TMP100 I2C temperature sensors
 * and  to display their hex outputs to a console about once per second.
 *
 ******************************************************************************/

module sp601(
  // 200 MHz differential clock
  input  wire   pi_sysclk_p,
  input  wire   pi_sysclk_n,
  // I2C bus
  inout  wire   pio_i2c_scl,
  inout  wire   pio_i2c_sda,
  // TCA9554 interrupt
  input  wire   pi_int,
  // UART Tx
  output wire   po_usb_1_rx
);

/*
 * Generate a 25 MHz clock from the 200 MHz oscillator.
 * Note:  The I2C bus signals don't rise enough with a 100 MHz clock (400 kHz
 *        I2C bus) and are still somewhat marginal even with the 25 MHz clock
 *        (100 kHz I2C bus).
 */

wire s_sysclk;
IBUFGDS sysclk_inst(
  .I    (pi_sysclk_p),
  .IB   (pi_sysclk_n),
  .O    (s_sysclk)
);

wire s_divclk;
BUFIO2 #(
  .DIVIDE               (8),
  .DIVIDE_BYPASS        ("FALSE")
) bufio2_inst (
  .I            (s_sysclk),
  .IOCLK        (),
  .DIVCLK       (s_divclk),
  .SERDESSTROBE ()
);

wire s_clk;
BUFG sclk_inst(
  .I    (s_divclk),
  .O    (s_clk)
);

/*
 * Generate a synchronous reset.
 */

reg [3:0] s_reset_count = 4'hF;
always @ (posedge s_clk)
  s_reset_count <= s_reset_count - 4'd1;

reg s_rst = 1'b1;
always @ (posedge s_clk)
  if (s_reset_count == 4'd0)
    s_rst <= 1'b0;
  else
    s_rst <= s_rst;

/*
 * Instantiate the micro controller.
 */

i2c_tca9554 ie_inst(
  // synchronous reset and processor clock
  .i_rst        (s_rst),
  .i_clk        (s_clk),
  // TCA9554 interrupt and I2C bus
  .i_int        (pi_int),
  .io_scl       (pio_i2c_scl),
  .io_sda       (pio_i2c_sda),
  // UART_Tx port
  .o_uart_tx    (po_usb_1_rx)
);

endmodule
