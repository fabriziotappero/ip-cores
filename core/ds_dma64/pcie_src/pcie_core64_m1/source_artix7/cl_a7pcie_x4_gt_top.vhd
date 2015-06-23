-------------------------------------------------------------------------------
--
-- (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------
-- Project    : Series-7 Integrated Block for PCI Express
-- File       : cl_a7pcie_x4_gt_top.vhd
-- Version    : 1.11
---- Description: GTX module for 7-series Integrated PCIe Block
----
----
----
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

entity cl_a7pcie_x4_gt_top is
generic (
   LINK_CAP_MAX_LINK_WIDTH_int    : integer := 1;       -- 1 - x1 , 2 - x2 , 4 - x4 , 8 - x8
   REF_CLK_FREQ                   : integer := 0;       -- 0 - 100 MHz , 1 - 125 MHz , 2 - 250 MHz
   USER_CLK2_DIV2                 : string := "FALSE";  -- "TRUE" => user_clk2 = user_clk/2, where user_clk = 500 or 250 MHz.
                                                        -- "FALSE" => user_clk2 = user_clk
   USER_CLK_FREQ                  : integer := 3;       -- 0 - 31.25 MHz , 1 - 62.5 MHz , 2 - 125 MHz , 3 - 250 MHz , 4 - 500Mhz
   PL_FAST_TRAIN                  : string := "FALSE";  -- Simulation Speedup
   PCIE_EXT_CLK                   : string := "FALSE";  -- External Clock Enable
   PCIE_USE_MODE                  : string := "1.0"  ;  -- 1.0=K325T IES, 1.1=VX48T IES, 3.0 = K325T GES
   PCIE_GT_DEVICE                 : string := "GTX"  ;  -- Select the GT to use (GTP for Artix-7, GTX for K7/V7)
   PCIE_PLL_SEL                   : string := "CPLL" ;  -- Select the PLL (CPLL or QPLL)
   PCIE_ASYNC_EN                  : string := "FALSE";  -- Asynchronous Clocking Enable
   PCIE_TXBUF_EN                  : string := "FALSE";  -- Use the Transmit Buffer
   PCIE_CHAN_BOND                 : integer := 0
);
port (
   -- pl ltssm
   pl_ltssm_state         : in std_logic_vector(5 downto 0);

   -- Pipe Per-Link Signals
   pipe_tx_rcvr_det       : in std_logic;
   pipe_tx_reset          : in std_logic;
   pipe_tx_rate           : in std_logic;
   pipe_tx_deemph         : in std_logic;
   pipe_tx_margin         : in std_logic_vector (2 downto 0);
   pipe_tx_swing          : in std_logic;

   PIPE_PCLK_IN           : in std_logic;
   PIPE_RXUSRCLK_IN       : in std_logic;
   PIPE_RXOUTCLK_IN       : in std_logic_vector(3 downto 0);
   PIPE_DCLK_IN           : in std_logic;
   PIPE_USERCLK1_IN       : in std_logic;
   PIPE_USERCLK2_IN       : in std_logic;
   PIPE_OOBCLK_IN         : in std_logic;
   PIPE_MMCM_LOCK_IN      : in std_logic;

   PIPE_TXOUTCLK_OUT      : out std_logic;
   PIPE_RXOUTCLK_OUT      : out std_logic_vector(3 downto 0);
   PIPE_PCLK_SEL_OUT      : out std_logic_vector(3 downto 0);
   PIPE_GEN3_OUT          : out std_logic;

   -- Pipe Per-Lane Signals - Lane 0
   pipe_rx0_char_is_k     : out std_logic_vector(1 downto 0);
   pipe_rx0_data          : out std_logic_vector(15 downto 0);
   pipe_rx0_valid         : out std_logic;
   pipe_rx0_chanisaligned : out std_logic;
   pipe_rx0_status        : out std_logic_vector(2 downto 0);
   pipe_rx0_phy_status    : out std_logic;
   pipe_rx0_elec_idle     : out std_logic;
   pipe_rx0_polarity      : in std_logic;
   pipe_tx0_compliance    : in std_logic;
   pipe_tx0_char_is_k     : in std_logic_vector(1 downto 0);
   pipe_tx0_data          : in std_logic_vector(15 downto 0);
   pipe_tx0_elec_idle     : in std_logic;
   pipe_tx0_powerdown     : in std_logic_vector(1 downto 0);

   -- Pipe Per-Lane Signals - Lane 1
   pipe_rx1_char_is_k     : out std_logic_vector(1 downto 0);
   pipe_rx1_data          : out std_logic_vector(15 downto 0);
   pipe_rx1_valid         : out std_logic;
   pipe_rx1_chanisaligned : out std_logic;
   pipe_rx1_status        : out std_logic_vector(2 downto 0);
   pipe_rx1_phy_status    : out std_logic;
   pipe_rx1_elec_idle     : out std_logic;
   pipe_rx1_polarity      : in std_logic;
   pipe_tx1_compliance    : in std_logic;
   pipe_tx1_char_is_k     : in std_logic_vector(1 downto 0);
   pipe_tx1_data          : in std_logic_vector(15 downto 0);
   pipe_tx1_elec_idle     : in std_logic;
   pipe_tx1_powerdown     : in std_logic_vector(1 downto 0);

   -- Pipe Per-Lane Signals - Lane 2
   pipe_rx2_char_is_k     : out std_logic_vector(1 downto 0);
   pipe_rx2_data          : out std_logic_vector(15 downto 0);
   pipe_rx2_valid         : out std_logic;
   pipe_rx2_chanisaligned : out std_logic;
   pipe_rx2_status        : out std_logic_vector(2 downto 0);
   pipe_rx2_phy_status    : out std_logic;
   pipe_rx2_elec_idle     : out std_logic;
   pipe_rx2_polarity      : in std_logic;
   pipe_tx2_compliance    : in std_logic;
   pipe_tx2_char_is_k     : in std_logic_vector(1 downto 0);
   pipe_tx2_data          : in std_logic_vector(15 downto 0);
   pipe_tx2_elec_idle     : in std_logic;
   pipe_tx2_powerdown     : in std_logic_vector(1 downto 0);

   -- Pipe Per-Lane Signals - Lane 3
   pipe_rx3_char_is_k     : out std_logic_vector(1 downto 0);
   pipe_rx3_data          : out std_logic_vector(15 downto 0);
   pipe_rx3_valid         : out std_logic;
   pipe_rx3_chanisaligned : out std_logic;
   pipe_rx3_status        : out std_logic_vector(2 downto 0);
   pipe_rx3_phy_status    : out std_logic;
   pipe_rx3_elec_idle     : out std_logic;
   pipe_rx3_polarity      : in std_logic;
   pipe_tx3_compliance    : in std_logic;
   pipe_tx3_char_is_k     : in std_logic_vector(1 downto 0);
   pipe_tx3_data          : in std_logic_vector(15 downto 0);
   pipe_tx3_elec_idle     : in std_logic;
   pipe_tx3_powerdown     : in std_logic_vector(1 downto 0);

   -- Pipe Per-Lane Signals - Lane 4
   pipe_rx4_char_is_k     : out std_logic_vector(1 downto 0);
   pipe_rx4_data          : out std_logic_vector(15 downto 0);
   pipe_rx4_valid         : out std_logic;
   pipe_rx4_chanisaligned : out std_logic;
   pipe_rx4_status        : out std_logic_vector(2 downto 0);
   pipe_rx4_phy_status    : out std_logic;
   pipe_rx4_elec_idle     : out std_logic;
   pipe_rx4_polarity      : in std_logic;
   pipe_tx4_compliance    : in std_logic;
   pipe_tx4_char_is_k     : in std_logic_vector(1 downto 0);
   pipe_tx4_data          : in std_logic_vector(15 downto 0);
   pipe_tx4_elec_idle     : in std_logic;
   pipe_tx4_powerdown     : in std_logic_vector(1 downto 0);

   -- Pipe Per-Lane Signals - Lane 5
   pipe_rx5_char_is_k     : out std_logic_vector(1 downto 0);
   pipe_rx5_data          : out std_logic_vector(15 downto 0);
   pipe_rx5_valid         : out std_logic;
   pipe_rx5_chanisaligned : out std_logic;
   pipe_rx5_status        : out std_logic_vector(2 downto 0);
   pipe_rx5_phy_status    : out std_logic;
   pipe_rx5_elec_idle     : out std_logic;
   pipe_rx5_polarity      : in std_logic;
   pipe_tx5_compliance    : in std_logic;
   pipe_tx5_char_is_k     : in std_logic_vector(1 downto 0);
   pipe_tx5_data          : in std_logic_vector(15 downto 0);
   pipe_tx5_elec_idle     : in std_logic;
   pipe_tx5_powerdown     : in std_logic_vector(1 downto 0);

   -- Pipe Per-Lane Signals - Lane 6
   pipe_rx6_char_is_k     : out std_logic_vector(1 downto 0);
   pipe_rx6_data          : out std_logic_vector(15 downto 0);
   pipe_rx6_valid         : out std_logic;
   pipe_rx6_chanisaligned : out std_logic;
   pipe_rx6_status        : out std_logic_vector(2 downto 0);
   pipe_rx6_phy_status    : out std_logic;
   pipe_rx6_elec_idle     : out std_logic;
   pipe_rx6_polarity      : in std_logic;
   pipe_tx6_compliance    : in std_logic;
   pipe_tx6_char_is_k     : in std_logic_vector(1 downto 0);
   pipe_tx6_data          : in std_logic_vector(15 downto 0);
   pipe_tx6_elec_idle     : in std_logic;
   pipe_tx6_powerdown     : in std_logic_vector(1 downto 0);

   -- Pipe Per-Lane Signals - Lane 7
   pipe_rx7_char_is_k     : out std_logic_vector(1 downto 0);
   pipe_rx7_data          : out std_logic_vector(15 downto 0);
   pipe_rx7_valid         : out std_logic;
   pipe_rx7_chanisaligned : out std_logic;
   pipe_rx7_status        : out std_logic_vector(2 downto 0);
   pipe_rx7_phy_status    : out std_logic;
   pipe_rx7_elec_idle     : out std_logic;
   pipe_rx7_polarity      : in std_logic;
   pipe_tx7_compliance    : in std_logic;
   pipe_tx7_char_is_k     : in std_logic_vector(1 downto 0);
   pipe_tx7_data          : in std_logic_vector(15 downto 0);
   pipe_tx7_elec_idle     : in std_logic;
   pipe_tx7_powerdown     : in std_logic_vector(1 downto 0);

   -- PCI Express signals
   pci_exp_txn            : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
   pci_exp_txp            : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
   pci_exp_rxn            : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
   pci_exp_rxp            : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

   -- Non PIPE signals
   sys_clk                : in std_logic;
   sys_rst_n              : in std_logic;
   PIPE_MMCM_RST_N        : in std_logic;   --     // Async      | Async

   pipe_clk               : out std_logic;
   user_clk               : out std_logic;
   user_clk2              : out std_logic;

   phy_rdy_n              : out std_logic
);
end cl_a7pcie_x4_gt_top;

architecture pcie_7x of cl_a7pcie_x4_gt_top is


   component cl_a7pcie_x4_gt_rx_valid_filter_7x is
      generic (
        CLK_COR_MIN_LAT      : integer := 28;
        TCQ                  : integer := 1
      );
      port (
        USER_RXCHARISK       : out std_logic_vector( 1 downto 0);
        USER_RXDATA          : out std_logic_vector(15 downto 0);
        USER_RXVALID         : out std_logic;
        USER_RXELECIDLE      : out std_logic;
        USER_RX_STATUS       : out std_logic_vector( 2 downto 0);
        USER_RX_PHY_STATUS   : out std_logic;
        GT_RXCHARISK         : in  std_logic_vector( 1 downto 0);
        GT_RXDATA            : in  std_logic_vector(15 downto 0);
        GT_RXVALID           : in  std_logic;
        GT_RXELECIDLE        : in  std_logic;
        GT_RX_STATUS         : in  std_logic_vector( 2 downto 0);
        GT_RX_PHY_STATUS     : in  std_logic;

        PLM_IN_L0            : in  std_logic;
        PLM_IN_RS            : in  std_logic;

        USER_CLK             : in  std_logic;
        RESET                : in  std_logic
      );
   end component;


   component cl_a7pcie_x4_pipe_wrapper is
      generic (
        PCIE_SIM_MODE                 : string  := "false";

        -- pragma synthesis_off
        PCIE_SIM_SPEEDUP              : string  := "TRUE"; -- Simulation Speedup
        -- pragma synthesis_on

        PCIE_TXBUF_EN                 : string  := "false";
        PCIE_CHAN_BOND                : integer := 0;
        PCIE_PLL_SEL                  : string  := "CPLL";
        PCIE_GT_DEVICE                : string  := "GTX";
        PCIE_USE_MODE                 : string  := "1.0";
        PCIE_LPM_DFE                  : string  := "LPM";
        PCIE_LANE                     : integer := 1;
        PCIE_LINK_SPEED               : integer := 3;
        PCIE_REFCLK_FREQ              : integer := 0;
        PCIE_TX_EIDLE_ASSERT_DELAY    : integer := 4;
	PCIE_OOBCLK_MODE              : integer := 0;
        PCIE_USERCLK1_FREQ            : integer := 2;
        PCIE_USERCLK2_FREQ            : integer := 2;
        PCIE_EXT_CLK                  : string  := "FALSE"

      );
      port (

    PIPE_CLK                      : in std_logic;
    PIPE_RESET_N                  : in std_logic;
    PIPE_PCLK                     : out std_logic;

    PIPE_TXDATA                   : in std_logic_vector((32*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_TXDATAK                  : in std_logic_vector((4*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_TXP                      : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_TXN                      : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_RXP                      : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXN                      : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_RXDATA                   : out std_logic_vector((32*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXDATAK                  : out std_logic_vector((4*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_TXDETECTRX               : in std_logic;
    PIPE_TXELECIDLE               : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_TXCOMPLIANCE             : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXPOLARITY               : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_POWERDOWN                : in std_logic_vector((2*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RATE                     : in std_logic_vector(1 downto 0);

    PIPE_TXMARGIN                 : in std_logic_vector(2 downto 0);
    PIPE_TXSWING                  : in std_logic;
    PIPE_TXEQ_CONTROL             : in std_logic_vector((2*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_TXEQ_PRESET              : in std_logic_vector((4*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_TXEQ_PRESET_DEFAULT      : in std_logic_vector((4*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_RXEQ_CONTROL             : in std_logic_vector((2*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXEQ_PRESET              : in std_logic_vector((3*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXEQ_LFFS                : in std_logic_vector((6*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXEQ_TXPRESET            : in std_logic_vector((4*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_TXEQ_COEFF               : out std_logic_vector(((18*LINK_CAP_MAX_LINK_WIDTH_int)-1) downto 0);
    PIPE_RXEQ_USER_EN             : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXEQ_USER_TXCOEFF        : in std_logic_vector((18*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXEQ_USER_MODE           : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_TXDEEMPH                 : in std_logic_vector((1*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_TXEQ_DEEMPH              : in std_logic_vector((6*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_TXEQ_FS                  : out std_logic_vector(5 downto 0);
    PIPE_TXEQ_LF                  : out std_logic_vector(5 downto 0);
    PIPE_TXEQ_DONE                : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_RXEQ_NEW_TXCOEFF         : out std_logic_vector((18*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXEQ_LFFS_SEL            : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXEQ_ADAPT_DONE          : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXEQ_DONE                : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_RXVALID                  : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_PHYSTATUS                : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_PHYSTATUS_RST            : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXELECIDLE               : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXSTATUS                 : out std_logic_vector((3*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXBUFSTATUS              : out std_logic_vector((3*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_MMCM_RST_N               : in std_logic;   --     // Async      | Async

    PIPE_RXSLIDE                  : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_CPLL_LOCK                : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_QPLL_LOCK                : out std_logic_vector(((LINK_CAP_MAX_LINK_WIDTH_int)/8) downto 0);
    PIPE_PCLK_LOCK                : out std_logic;
    PIPE_RXCDRLOCK                : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_USERCLK1                 : out std_logic;
    PIPE_USERCLK2                 : out std_logic;
    PIPE_RXUSRCLK                 : out std_logic;

    PIPE_RXOUTCLK                 : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_TXSYNC_DONE              : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXSYNC_DONE              : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_GEN3_RDY                 : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_RXCHANISALIGNED          : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_ACTIVE_LANE              : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_PCLK_IN                  : in  std_logic;
    PIPE_RXUSRCLK_IN              : in  std_logic;

    PIPE_RXOUTCLK_IN              : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DCLK_IN                  : in  std_logic;
    PIPE_USERCLK1_IN              : in  std_logic;
    PIPE_USERCLK2_IN              : in  std_logic;
    PIPE_OOBCLK_IN                : in std_logic;
    PIPE_JTAG_EN                  : in std_logic;
    PIPE_JTAG_RDY                 : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_MMCM_LOCK_IN             : in  std_logic;

    PIPE_TXOUTCLK_OUT             : out std_logic;
    PIPE_RXOUTCLK_OUT             : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_PCLK_SEL_OUT             : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_GEN3_OUT                 : out std_logic;

    PIPE_TXPRBSSEL                : in std_logic_vector(2 downto 0);
    PIPE_RXPRBSSEL                : in std_logic_vector(2 downto 0);
    PIPE_TXPRBSFORCEERR           : in std_logic;
    PIPE_RXPRBSCNTRESET           : in std_logic;
    PIPE_LOOPBACK                 : in std_logic_vector(2 downto 0);

    PIPE_RXPRBSERR                : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_RST_FSM                  : out std_logic_vector(10 downto 0);
    PIPE_QRST_FSM                 : out std_logic_vector(11 downto 0);
    PIPE_SYNC_FSM_TX              : out std_logic_vector((6*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_SYNC_FSM_RX              : out std_logic_vector((7*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DRP_FSM                  : out std_logic_vector((7*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_TXEQ_FSM                 : out std_logic_vector((6*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_QDRP_FSM                 : out std_logic_vector(((((LINK_CAP_MAX_LINK_WIDTH_int)/8)+1)*9)-1 downto 0);
    PIPE_RATE_FSM                 : out std_logic_vector((31*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
   
    PIPE_RXEQ_FSM                 : out std_logic_vector((6*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_RST_IDLE                 : out std_logic;
    PIPE_QRST_IDLE                : out std_logic;
    PIPE_RATE_IDLE                : out std_logic;

    PIPE_DEBUG_0                  : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DEBUG_1                  : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DEBUG_2                  : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DEBUG_3                  : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DEBUG_4                  : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DEBUG_5                  : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DEBUG_6                  : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DEBUG_7                  : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DEBUG_8                  : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DEBUG_9                  : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);
    PIPE_DEBUG                    : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0);

    PIPE_DMONITOROUT              : out std_logic_vector((15*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0)

    );
   end component;
  -- Calculate USERCLK2 Frequency
  function get_usrclk2_freq (
    constant div2   : string;
    constant freq   : integer)
    return integer is
  begin  -- msb_addr

    if (div2 = "TRUE") then
      if (freq = 4) then
        return 3;
      elsif (freq = 3) then
        return 2;
      else
        return freq;
      end if;
    else
      return freq;
    end if;
  end get_usrclk2_freq;

   -- purpose: Determine LPM_DFE setting for GT
   function get_lpm (
     constant simulation : string)
     return string is
   begin  -- lpm
     if (simulation = "TRUE") then
       return "DFE";
     else
       return "LPM";
     end if;
   end get_lpm;

   -- purpose: Determine TX Electrical Idle Delay
   function get_ei_delay (
     constant simulation : string)
     return integer is
   begin  -- ei_delay
     if (simulation = "TRUE") then
       return 4;
     else
       return 2;
     end if;
   end get_ei_delay;

   -- purpose: Determine Link Speed Configuration for GT
   function get_gt_lnk_spd_cfg (
     constant simulation : string)
     return integer is
   begin  -- get_gt_lnk_spd_cfg
     if (simulation = "TRUE") then
       return 2;
     else
       return 3;
     end if;
   end get_gt_lnk_spd_cfg;
    
    -- purpose: Assign the value to PCIE_OOBCLK_MODE depending on the simulation - 0 / synthesis - 1 
    function get_oobclk_mode (
      constant simulation : string)
      return integer is
   begin  -- get_oobclk_mode
     if (simulation = "TRUE") then 
        return 0;
     else 
        return 1;
     end if; 
   end get_oobclk_mode;

  constant USERCLK2_FREQ : integer := get_usrclk2_freq(USER_CLK2_DIV2, USER_CLK_FREQ);
  constant TCQ           : integer := 1;       -- clock to out delay model
  constant LPM_DFE       : string  := get_lpm(PL_FAST_TRAIN);
  constant LNK_SPD       : integer := get_gt_lnk_spd_cfg(PL_FAST_TRAIN);
  constant EI_DELAY      : integer := get_ei_delay(PL_FAST_TRAIN);
  constant PCIE_OOBCLK_MODE_ENABLE : integer := get_oobclk_mode(PL_FAST_TRAIN);
  
  constant signal_z      : std_logic_vector((18*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0) := (others => '0'); 

  signal gt_rx_phy_status_wire    : std_logic_vector(7 downto 0):= (others => '0');
  signal gt_rxchanisaligned_wire  : std_logic_vector(7 downto 0):= (others => '0');
  signal gt_rx_data_k_wire        : std_logic_vector(31 downto 0):= (others => '0');
  signal gt_rx_data_wire          : std_logic_vector(255 downto 0):= (others => '0');
  signal gt_rx_elec_idle_wire     : std_logic_vector(7 downto 0):= (others => '0');
  signal gt_rx_status_wire        : std_logic_vector(23 downto 0):= (others => '0');
  signal gt_rx_valid_wire         : std_logic_vector(7 downto 0):= (others => '0');
  signal gt_rx_polarity           : std_logic_vector(7 downto 0):= (others => '0');
  signal gt_power_down            : std_logic_vector(15 downto 0):= (others => '0');
  signal gt_tx_char_disp_mode     : std_logic_vector(7 downto 0):= (others => '0');
  signal gt_tx_data_k             : std_logic_vector(31 downto 0):= (others => '0');
  signal gt_tx_data               : std_logic_vector(255 downto 0):= (others => '0');
  signal gt_tx_detect_rx_loopback : std_logic:= '0';
  signal gt_tx_elec_idle          : std_logic_vector(7 downto 0):= (others => '0');
  signal gt_rx_elec_idle_reset    : std_logic_vector(7 downto 0):= (others => '0');
  signal plllkdet                 : std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0):= (others => '0');
  signal phystatus_rst            : std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0):= (others => '0');
  signal clock_locked             : std_logic:= '0';
  signal pipe_rate_concat         : std_logic_vector(1 downto 0):= (others => '0');
  
  signal pipe_tx_deemph_concat    : std_logic_vector((1*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0):= (others => '0');
  signal all_phystatus_rst        : std_logic:= '0';
  signal gt_rx_phy_status_wire_filter : std_logic_vector(  7 downto 0):= (others => '0');
  signal gt_rx_data_k_wire_filter     : std_logic_vector( 31 downto 0):= (others => '0');
  signal gt_rx_data_wire_filter       : std_logic_vector(255 downto 0):= (others => '0');
  signal gt_rx_elec_idle_wire_filter  : std_logic_vector(  7 downto 0):= (others => '0');
  signal gt_rx_status_wire_filter     : std_logic_vector( 23 downto 0):= (others => '0');
  signal gt_rx_valid_wire_filter      : std_logic_vector(  7 downto 0):= (others => '0');

  signal pl_ltssm_state_q             : std_logic_vector(  5 downto 0):= (others => '0');

  signal plm_in_l0                    : std_logic:= '0';
  signal plm_in_rl                    : std_logic:= '0';
  signal plm_in_dt                    : std_logic:= '0';
  signal plm_in_rs                    : std_logic:= '0';

  signal pipe_clk_int                 : std_logic:= '0';
  signal phy_rdy_n_int                : std_logic:= '0';
  signal reg_clock_locked             : std_logic:= '0';


  begin

  -- Register pl_ltssm_state
  process(pipe_clk_int,clock_locked)
  begin
     if (clock_locked = '0') then
        pl_ltssm_state_q <= (others => '0') after (TCQ)*1 ps;
     elsif (pipe_clk_int'event and pipe_clk_int = '1') then
        pl_ltssm_state_q <= pl_ltssm_state after (TCQ)*1 ps;
     end if;
  end process;

  pipe_clk <= pipe_clk_int;


  plm_in_l0 <= '1' when (pl_ltssm_state_q = "010110") else '0';
  plm_in_rl <= '1' when (pl_ltssm_state_q = "011100") else '0';
  plm_in_dt <= '1' when (pl_ltssm_state_q = "101101") else '0';
  plm_in_rs <= '1' when (pl_ltssm_state_q = "011111") else '0';

  pipe_rate_concat      <= ('0' & pipe_tx_rate);

  -- Generate TX Deemph input based on Link Width
  tx_deemph_x1 : if (LINK_CAP_MAX_LINK_WIDTH_int = "000001") generate
    pipe_tx_deemph_concat(0) <= pipe_tx_deemph;
  end generate;

  tx_deemph_x2 : if (LINK_CAP_MAX_LINK_WIDTH_int = "000010") generate
    pipe_tx_deemph_concat <= ("0" & pipe_tx_deemph);
  end generate;

  tx_deemph_x4 : if (LINK_CAP_MAX_LINK_WIDTH_int = "000100") generate
    pipe_tx_deemph_concat <= ("000" & pipe_tx_deemph);
  end generate;

  tx_deemph_x8 : if (LINK_CAP_MAX_LINK_WIDTH_int = "001000") generate
    pipe_tx_deemph_concat <= ("0000000" & pipe_tx_deemph);
  end generate;



--------------RX FILTER Instantiation--------------------------------------------

  gt_rx_valid_filter : for i in 0 to (LINK_CAP_MAX_LINK_WIDTH_int - 1) generate
  begin

   GT_RX_VALID_FILTER_7x_inst : cl_a7pcie_x4_gt_rx_valid_filter_7x
   generic map (
     CLK_COR_MIN_LAT    => 28,
     TCQ                => 1
   )
   port map(
     USER_RXCHARISK     => gt_rx_data_k_wire( (( 2*i)+ 1+( 2*i)) downto (( 2*i)+ ( 2*i))),        --O
     USER_RXDATA        => gt_rx_data_wire(   ((16*i)+15+(16*i)) downto ((16*i)+ (16*i))),        --O
     USER_RXVALID       => gt_rx_valid_wire(i),                                                   --O
     USER_RXELECIDLE    => gt_rx_elec_idle_wire (i),                                              --O
     USER_RX_STATUS     => gt_rx_status_wire( ((3*i)+ 2) downto (3*i)),                           --O
     USER_RX_PHY_STATUS => gt_rx_phy_status_wire (i),                                             --O

     GT_RXCHARISK       => gt_rx_data_k_wire_filter( (( 2*i)+ 1+( 2*i)) downto (( 2*i)+ ( 2*i))), --I
     GT_RXDATA          => gt_rx_data_wire_filter(   ((16*i)+15+(16*i)) downto ((16*i)+ (16*i))), --I
     GT_RXVALID         => gt_rx_valid_wire_filter(i),                                            --I
     GT_RXELECIDLE      => gt_rx_elec_idle_wire_filter(i),                                        --I
     GT_RX_STATUS       => gt_rx_status_wire_filter( (( 3*i)+ 2) downto (3*i)),                   --I
     GT_RX_PHY_STATUS   => gt_rx_phy_status_wire_filter(i),                                       --I

     PLM_IN_L0          => plm_in_l0,                                                             --I
     PLM_IN_RS          => plm_in_rs,                                                             --I
     USER_CLK           => pipe_clk_int,                                                          --I
     RESET              => phy_rdy_n_int                                                          --I
   );

  end generate;

------------ GTX ---------------------------------------------------------------
  pipe_wrapper_i : cl_a7pcie_x4_pipe_wrapper
  generic map (

    PCIE_SIM_MODE                  => PL_FAST_TRAIN,

    -- pragma synthesis_off
    PCIE_SIM_SPEEDUP               => "TRUE", -- Simulation Speedup
    -- pragma synthesis_on

    PCIE_EXT_CLK                   => PCIE_EXT_CLK,
    PCIE_TXBUF_EN                  => PCIE_TXBUF_EN,
    PCIE_GT_DEVICE                 => PCIE_GT_DEVICE,
    PCIE_CHAN_BOND                 => PCIE_CHAN_BOND,
    PCIE_PLL_SEL                   => PCIE_PLL_SEL,
    PCIE_USE_MODE                  => PCIE_USE_MODE,
    PCIE_LPM_DFE                   => LPM_DFE,
    PCIE_LANE                      => LINK_CAP_MAX_LINK_WIDTH_int,
    PCIE_LINK_SPEED                => LNK_SPD,
    PCIE_REFCLK_FREQ               => REF_CLK_FREQ,
    -- PCIE_OOBCLK_MODE               => PCIE_OOBCLK_MODE_ENABLE,
    PCIE_OOBCLK_MODE               => 1,
    PCIE_TX_EIDLE_ASSERT_DELAY     => EI_DELAY,
    PCIE_USERCLK1_FREQ             => (USER_CLK_FREQ +1),
    PCIE_USERCLK2_FREQ             => (USERCLK2_FREQ +1)


  )
  port map (

    ------------ PIPE Clock & Reset Ports ------------------
    PIPE_CLK                        => sys_clk,
    PIPE_RESET_N                    => sys_rst_n,
    PIPE_PCLK                       => pipe_clk_int,

    ----------- PIPE TX Data Ports ------------------
    PIPE_TXDATA                    => gt_tx_data((32*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_TXDATAK                   => gt_tx_data_k((4*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),

    PIPE_TXP                       => pci_exp_txp((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_TXN                       => pci_exp_txn((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),

    ----------- PIPE RX Data Ports ------------------
    PIPE_RXP                       => pci_exp_rxp((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_RXN                       => pci_exp_rxn((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),

    PIPE_RXDATA                    => gt_rx_data_wire_filter((32*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_RXDATAK                   => gt_rx_data_k_wire_filter((4*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),

    ----------- PIPE Command Ports ------------------
    PIPE_TXDETECTRX                => gt_tx_detect_rx_loopback,
    PIPE_TXELECIDLE                => gt_tx_elec_idle((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_TXCOMPLIANCE              => gt_tx_char_disp_mode((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_RXPOLARITY                => gt_rx_polarity((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_POWERDOWN                 => gt_power_down((2*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_RATE                      => pipe_rate_concat,

    ----------- PIPE Electrical Command Ports ------------------
    PIPE_TXMARGIN                  => pipe_tx_margin,
    PIPE_TXSWING                   => pipe_tx_swing,

    PIPE_TXEQ_CONTROL              => signal_z((2*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_TXEQ_PRESET               =>  signal_z((4*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_TXEQ_PRESET_DEFAULT       =>  signal_z((4*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),

    PIPE_RXEQ_CONTROL              => signal_z((2*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_RXEQ_PRESET               => signal_z((3*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_RXEQ_LFFS                 => signal_z((6*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_RXEQ_TXPRESET             => signal_z((4*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
 
    PIPE_TXDEEMPH                  => pipe_tx_deemph_concat,

    PIPE_TXEQ_COEFF                => open,
    PIPE_RXEQ_USER_EN              => signal_z((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_RXEQ_USER_TXCOEFF         => signal_z((18*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_RXEQ_USER_MODE            => signal_z((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_TXEQ_DEEMPH               => signal_z((6*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_TXEQ_FS                   => open,
    PIPE_TXEQ_LF                   => open,
    PIPE_TXEQ_DONE                 => open,

    PIPE_RXEQ_NEW_TXCOEFF          => open,
    PIPE_RXEQ_LFFS_SEL             => open,
    PIPE_RXEQ_ADAPT_DONE           => open,
    PIPE_RXEQ_DONE                 => open,

    ----------- PIPE Status Ports -------------------
    PIPE_RXVALID                   => gt_rx_valid_wire_filter((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_PHYSTATUS                 => gt_rx_phy_status_wire_filter((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_PHYSTATUS_RST             => phystatus_rst,
    PIPE_RXELECIDLE                => gt_rx_elec_idle_wire_filter((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_RXSTATUS                  => gt_rx_status_wire_filter((3*LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_RXBUFSTATUS               => open,

    ----------- PIPE User Ports ---------------------------
    PIPE_MMCM_RST_N                => PIPE_MMCM_RST_N,        -- Async      | Async

    PIPE_RXSLIDE                   => signal_z((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0) ,

    PIPE_CPLL_LOCK                 => plllkdet,
    PIPE_QPLL_LOCK                 => open,
    PIPE_PCLK_LOCK                 => clock_locked,
    PIPE_RXCDRLOCK                 => open,
    PIPE_USERCLK1                  => user_clk,
    PIPE_USERCLK2                  => user_clk2,
    PIPE_RXUSRCLK                  => open,

    PIPE_RXOUTCLK                  => open,
    PIPE_TXSYNC_DONE               => open,
    PIPE_RXSYNC_DONE               => open,
    PIPE_GEN3_RDY                  => open,
    PIPE_RXCHANISALIGNED           => gt_rxchanisaligned_wire((LINK_CAP_MAX_LINK_WIDTH_int-1) downto 0),
    PIPE_ACTIVE_LANE               => open,

    ---------- External Clock Ports ---------------------------
    PIPE_PCLK_IN                   => PIPE_PCLK_IN,
    PIPE_RXUSRCLK_IN               => PIPE_RXUSRCLK_IN,

    PIPE_RXOUTCLK_IN               => PIPE_RXOUTCLK_IN,
    PIPE_DCLK_IN                   => PIPE_DCLK_IN,
    PIPE_USERCLK1_IN               => PIPE_USERCLK1_IN,
    PIPE_USERCLK2_IN               => PIPE_USERCLK2_IN,
    PIPE_OOBCLK_IN                 => PIPE_OOBCLK_IN,
    PIPE_JTAG_EN                   => '0',
    PIPE_JTAG_RDY                  => open,
    PIPE_MMCM_LOCK_IN              => PIPE_MMCM_LOCK_IN,

    PIPE_TXOUTCLK_OUT              => PIPE_TXOUTCLK_OUT,
    PIPE_RXOUTCLK_OUT              => PIPE_RXOUTCLK_OUT,
    PIPE_PCLK_SEL_OUT              => PIPE_PCLK_SEL_OUT,
    PIPE_GEN3_OUT                  => PIPE_GEN3_OUT,

    ----------- PRBS/Loopback Ports ---------------------------
    PIPE_TXPRBSSEL                 => "000",
    PIPE_RXPRBSSEL                 => "000",
    PIPE_TXPRBSFORCEERR            => '0',
    PIPE_RXPRBSCNTRESET            => '0',
    PIPE_LOOPBACK                  => "000",
    PIPE_RXPRBSERR                 => open,

    ----------- FSM Ports ---------------------------
    PIPE_RST_FSM                   => open,
    PIPE_QRST_FSM                  => open,
    PIPE_RATE_FSM                  => open,
    PIPE_SYNC_FSM_TX               => open,
    PIPE_SYNC_FSM_RX               => open,
    PIPE_DRP_FSM                   => open,
    PIPE_TXEQ_FSM                  => open,
    PIPE_RXEQ_FSM                  => open,
    PIPE_QDRP_FSM                  => open,

    PIPE_RST_IDLE                  => open,
    PIPE_QRST_IDLE                 => open,
    PIPE_RATE_IDLE                 => open,

    ----------- Debug Ports ---------------------------
    PIPE_DEBUG_0                   => open,
    PIPE_DEBUG_1                   => open,
    PIPE_DEBUG_2                   => open,
    PIPE_DEBUG_3                   => open,
    PIPE_DEBUG_4                   => open,
    PIPE_DEBUG_5                   => open,
    PIPE_DEBUG_6                   => open,
    PIPE_DEBUG_7                   => open,
    PIPE_DEBUG_8                   => open,
    PIPE_DEBUG_9                   => open,
    PIPE_DEBUG                     => open,

    PIPE_DMONITOROUT               => open

);

  pipe_rx0_phy_status <= gt_rx_phy_status_wire(0);
  pipe_rx1_phy_status <= gt_rx_phy_status_wire(1) when (LINK_CAP_MAX_LINK_WIDTH_int >= 2) else
                         '0';
  pipe_rx2_phy_status <= gt_rx_phy_status_wire(2) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                         '0';
  pipe_rx3_phy_status <= gt_rx_phy_status_wire(3) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                         '0';
  pipe_rx4_phy_status <= gt_rx_phy_status_wire(4) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                         '0';
  pipe_rx5_phy_status <= gt_rx_phy_status_wire(5) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                         '0';
  pipe_rx6_phy_status <= gt_rx_phy_status_wire(6) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                         '0';
  pipe_rx7_phy_status <= gt_rx_phy_status_wire(7) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                         '0';

  pipe_rx0_chanisaligned <= gt_rxchanisaligned_wire(0);
  pipe_rx1_chanisaligned <= gt_rxchanisaligned_wire(1) when (LINK_CAP_MAX_LINK_WIDTH_int >= 2) else
                            '0';
  pipe_rx2_chanisaligned <= gt_rxchanisaligned_wire(2) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                            '0';
  pipe_rx3_chanisaligned <= gt_rxchanisaligned_wire(3) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                            '0';
  pipe_rx4_chanisaligned <= gt_rxchanisaligned_wire(4) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                            '0';
  pipe_rx5_chanisaligned <= gt_rxchanisaligned_wire(5) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                            '0';
  pipe_rx6_chanisaligned <= gt_rxchanisaligned_wire(6) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                            '0';
  pipe_rx7_chanisaligned <= gt_rxchanisaligned_wire(7) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                            '0';

  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  pipe_rx0_char_is_k <= (gt_rx_data_k_wire(1) & gt_rx_data_k_wire(0));
  pipe_rx1_char_is_k <= (gt_rx_data_k_wire(5) & gt_rx_data_k_wire(4)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 2) else
                        "00";
  pipe_rx2_char_is_k <= (gt_rx_data_k_wire(9) & gt_rx_data_k_wire(8)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                        "00";
  pipe_rx3_char_is_k <= (gt_rx_data_k_wire(13) & gt_rx_data_k_wire(12)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                        "00";
  pipe_rx4_char_is_k <= (gt_rx_data_k_wire(17) & gt_rx_data_k_wire(16)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                        "00";
  pipe_rx5_char_is_k <= (gt_rx_data_k_wire(21) & gt_rx_data_k_wire(20)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                        "00";
  pipe_rx6_char_is_k <= (gt_rx_data_k_wire(25) & gt_rx_data_k_wire(24)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                        "00";
  pipe_rx7_char_is_k <= (gt_rx_data_k_wire(29) & gt_rx_data_k_wire(28)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                        "00";

  pipe_rx0_data <= (gt_rx_data_wire(15 downto 8) & gt_rx_data_wire(7 downto 0));
  pipe_rx1_data <= (gt_rx_data_wire(47 downto 40) & gt_rx_data_wire(39 downto 32)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 2) else
                   "0000000000000000";
  pipe_rx2_data <= (gt_rx_data_wire(79 downto 72) & gt_rx_data_wire(71 downto 64)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                   "0000000000000000";
  pipe_rx3_data <= (gt_rx_data_wire(111 downto 104) & gt_rx_data_wire(103 downto 96)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                   "0000000000000000";
  pipe_rx4_data <= (gt_rx_data_wire(143 downto 136) & gt_rx_data_wire(135 downto 128)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                   "0000000000000000";
  pipe_rx5_data <= (gt_rx_data_wire(175 downto 168) & gt_rx_data_wire(167 downto 160)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                   "0000000000000000";
  pipe_rx6_data <= (gt_rx_data_wire(207 downto 200) & gt_rx_data_wire(199 downto 192)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                   "0000000000000000";
  pipe_rx7_data <= (gt_rx_data_wire(239 downto 232) & gt_rx_data_wire(231 downto 224)) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                   "0000000000000000";

  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  pipe_rx0_elec_idle <= gt_rx_elec_idle_wire(0);
  pipe_rx1_elec_idle <= gt_rx_elec_idle_wire(1) when (LINK_CAP_MAX_LINK_WIDTH_int >= 2) else
                        '1';
  pipe_rx2_elec_idle <= gt_rx_elec_idle_wire(2) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                        '1';
  pipe_rx3_elec_idle <= gt_rx_elec_idle_wire(3) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                        '1';
  pipe_rx4_elec_idle <= gt_rx_elec_idle_wire(4) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                        '1';
  pipe_rx5_elec_idle <= gt_rx_elec_idle_wire(5) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                        '1';
  pipe_rx6_elec_idle <= gt_rx_elec_idle_wire(6) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                        '1';
  pipe_rx7_elec_idle <= gt_rx_elec_idle_wire(7) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                        '1';

  pipe_rx0_status <= gt_rx_status_wire(2 downto 0);
  pipe_rx1_status <= gt_rx_status_wire(5 downto 3) when (LINK_CAP_MAX_LINK_WIDTH_int >= 2) else
                     "000";
  pipe_rx2_status <= gt_rx_status_wire(8 downto 6) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                     "000";
  pipe_rx3_status <= gt_rx_status_wire(11 downto 9) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                     "000";
  pipe_rx4_status <= gt_rx_status_wire(14 downto 12) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                     "000";
  pipe_rx5_status <= gt_rx_status_wire(17 downto 15) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                     "000";
  pipe_rx6_status <= gt_rx_status_wire(20 downto 18) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                     "000";
  pipe_rx7_status <= gt_rx_status_wire(23 downto 21) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                     "000";

  pipe_rx0_valid <= gt_rx_valid_wire(0);
  pipe_rx1_valid <= gt_rx_valid_wire(1) when (LINK_CAP_MAX_LINK_WIDTH_int >= 2) else
                    '0';
  pipe_rx2_valid <= gt_rx_valid_wire(2) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                    '0';
  pipe_rx3_valid <= gt_rx_valid_wire(3) when (LINK_CAP_MAX_LINK_WIDTH_int >= 4) else
                    '0';
  pipe_rx4_valid <= gt_rx_valid_wire(4) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                    '0';
  pipe_rx5_valid <= gt_rx_valid_wire(5) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                    '0';
  pipe_rx6_valid <= gt_rx_valid_wire(6) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                    '0';
  pipe_rx7_valid <= gt_rx_valid_wire(7) when (LINK_CAP_MAX_LINK_WIDTH_int >= 8) else
                    '0';


--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

gt_rx_polarity(0) <= pipe_rx0_polarity;
gt_rx_polarity(1) <= pipe_rx1_polarity;
gt_rx_polarity(2) <= pipe_rx2_polarity;
gt_rx_polarity(3) <= pipe_rx3_polarity;
gt_rx_polarity(4) <= pipe_rx4_polarity;
gt_rx_polarity(5) <= pipe_rx5_polarity;
gt_rx_polarity(6) <= pipe_rx6_polarity;
gt_rx_polarity(7) <= pipe_rx7_polarity;

gt_power_down( 1 downto  0) <= pipe_tx0_powerdown;
gt_power_down( 3 downto  2) <= pipe_tx1_powerdown;
gt_power_down( 5 downto  4) <= pipe_tx2_powerdown;
gt_power_down( 7 downto  6) <= pipe_tx3_powerdown;
gt_power_down( 9 downto  8) <= pipe_tx4_powerdown;
gt_power_down(11 downto 10) <= pipe_tx5_powerdown;
gt_power_down(13 downto 12) <= pipe_tx6_powerdown;
gt_power_down(15 downto 14) <= pipe_tx7_powerdown;

 gt_tx_char_disp_mode <= (pipe_tx7_compliance &
                               pipe_tx6_compliance &
                               pipe_tx5_compliance &
                               pipe_tx4_compliance &
                               pipe_tx3_compliance &
                               pipe_tx2_compliance &
                               pipe_tx1_compliance &
                               pipe_tx0_compliance);


 gt_tx_data_k     <= ("00" &
                     pipe_tx7_char_is_k &
                     "00" &
                     pipe_tx6_char_is_k &
                     "00" &
                     pipe_tx5_char_is_k &
                     "00" &
                     pipe_tx4_char_is_k &
                     "00" &
                     pipe_tx3_char_is_k &
                     "00" &
                     pipe_tx2_char_is_k &
                     "00" &
                     pipe_tx1_char_is_k &
                     "00" &
                     pipe_tx0_char_is_k);

  gt_tx_data     <=  (x"0000" &
                     pipe_tx7_data &
                     x"0000" &
                     pipe_tx6_data &
                     x"0000" &
                     pipe_tx5_data &
                     x"0000" &
                     pipe_tx4_data &
                     x"0000" &
                     pipe_tx3_data &
                     x"0000" &
                     pipe_tx2_data &
                     x"0000" &
                     pipe_tx1_data &
                     x"0000" &
                     pipe_tx0_data);

 gt_tx_detect_rx_loopback <= pipe_tx_rcvr_det;

 gt_tx_elec_idle      <= (pipe_tx7_elec_idle &
                          pipe_tx6_elec_idle &
                          pipe_tx5_elec_idle &
                          pipe_tx4_elec_idle &
                          pipe_tx3_elec_idle &
                          pipe_tx2_elec_idle &
                          pipe_tx1_elec_idle &
                          pipe_tx0_elec_idle);

  process(pipe_clk_int,clock_locked)
  begin
    if (clock_locked = '0') then
        reg_clock_locked <= '0' after (TCQ)*1 ps;
    elsif (pipe_clk_int'event and pipe_clk_int='1') then
        reg_clock_locked <= '1' after (TCQ)*1 ps;
    end if;
  end process;
 
  process(pipe_clk_int)
  begin
    if (reg_clock_locked = '0') then
        phy_rdy_n_int <= '0' after (TCQ)*1 ps;
    elsif (pipe_clk_int'event and pipe_clk_int='1') then
        phy_rdy_n_int <= all_phystatus_rst after (TCQ)*1 ps;
    end if;
  end process;
 
 all_phystatus_rst <= and_reduce(phystatus_rst);
 phy_rdy_n         <= phy_rdy_n_int;


end pcie_7x;

