`include "sata_defines.v"

module sata_platform (
  input                 rst,

  input                 tx_comm_reset,
  input                 tx_comm_wake,
  output                comm_init_detect,
  output                comm_wake_detect,
  output                rx_elec_idle,
  input                 tx_elec_idle,
  output                rx_byte_is_aligned,


  input         [31:0]  phy_tx_dout,
  input                 phy_tx_isk,
  output        [31:0]  phy_rx_din,
  output        [3:0]   phy_rx_isk,

  //Clock Interface
  input                 mgtclk_in,
  output           reg  cnt_rst,
  output                pll_locked,
  output                clk_75mhz,


  output                platform_ready,

  output                TXP0_OUT,
  output                TXN0_OUT,

  input                 RXP0_IN,
  input                 RXN0_IN,

  output                GTX115_TXP0_OUT,
  output                GTX115_TXN0_OUT,

  input                 GTX115_RXP0_IN,
  input                 GTX115_RXN0_IN
);

//Parameters
//Registers/Wires
//Submodules
//Asynchronous Logic
//Synchronous Logic
endmodule
