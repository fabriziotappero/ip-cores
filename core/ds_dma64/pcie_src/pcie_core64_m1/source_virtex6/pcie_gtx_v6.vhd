-------------------------------------------------------------------------------
--
-- (c) Copyright 2009-2011 Xilinx, Inc. All rights reserved.
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
-- Project    : Virtex-6 Integrated Block for PCI Express
-- File       : pcie_gtx_v6.vhd
-- Version    : 2.3
-- Description: GTX module for Virtex6 PCIe Block
--
--
--
--------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

entity pcie_gtx_v6 is
   generic (
      NO_OF_LANES                                  : integer := 8;		-- 1 - x1 , 2 - x2 , 4 - x4 , 8 - x8
      LINK_CAP_MAX_LINK_SPEED                      : bit_vector := X"1";		-- 1 - Gen1, 2 - Gen2
      REF_CLK_FREQ                                 : integer := 0;		-- 0 - 100 MHz , 1 - 125 MHz , 2 - 250 MHz
      PL_FAST_TRAIN                                : boolean := FALSE
   );
   port (
      -- Pipe Per-Link Signals	
      pipe_tx_rcvr_det                             : in std_logic;
      pipe_tx_reset                                : in std_logic;
      pipe_tx_rate                                 : in std_logic;
      pipe_tx_deemph                               : in std_logic;
      pipe_tx_margin                               : in std_logic_vector(2 downto 0);
      pipe_tx_swing                                : in std_logic;
      
      -- Pipe Per-Lane Signals - Lane 0
      pipe_rx0_char_is_k                           : out std_logic_vector(1 downto 0);
      pipe_rx0_data                                : out std_logic_vector(15 downto 0);
      pipe_rx0_valid                               : out std_logic;
      pipe_rx0_chanisaligned                       : out std_logic;
      pipe_rx0_status                              : out std_logic_vector(2 downto 0);
      pipe_rx0_phy_status                          : out std_logic;
      pipe_rx0_elec_idle                           : out std_logic;
      pipe_rx0_polarity                            : in std_logic;
      pipe_tx0_compliance                          : in std_logic;
      pipe_tx0_char_is_k                           : in std_logic_vector(1 downto 0);
      pipe_tx0_data                                : in std_logic_vector(15 downto 0);
      pipe_tx0_elec_idle                           : in std_logic;
      pipe_tx0_powerdown                           : in std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 1
      pipe_rx1_char_is_k                           : out std_logic_vector(1 downto 0);
      pipe_rx1_data                                : out std_logic_vector(15 downto 0);
      pipe_rx1_valid                               : out std_logic;
      pipe_rx1_chanisaligned                       : out std_logic;
      pipe_rx1_status                              : out std_logic_vector(2 downto 0);
      pipe_rx1_phy_status                          : out std_logic;
      pipe_rx1_elec_idle                           : out std_logic;
      pipe_rx1_polarity                            : in std_logic;
      pipe_tx1_compliance                          : in std_logic;
      pipe_tx1_char_is_k                           : in std_logic_vector(1 downto 0);
      pipe_tx1_data                                : in std_logic_vector(15 downto 0);
      pipe_tx1_elec_idle                           : in std_logic;
      pipe_tx1_powerdown                           : in std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 2
      pipe_rx2_char_is_k                           : out std_logic_vector(1 downto 0);
      pipe_rx2_data                                : out std_logic_vector(15 downto 0);
      pipe_rx2_valid                               : out std_logic;
      pipe_rx2_chanisaligned                       : out std_logic;
      pipe_rx2_status                              : out std_logic_vector(2 downto 0);
      pipe_rx2_phy_status                          : out std_logic;
      pipe_rx2_elec_idle                           : out std_logic;
      pipe_rx2_polarity                            : in std_logic;
      pipe_tx2_compliance                          : in std_logic;
      pipe_tx2_char_is_k                           : in std_logic_vector(1 downto 0);
      pipe_tx2_data                                : in std_logic_vector(15 downto 0);
      pipe_tx2_elec_idle                           : in std_logic;
      pipe_tx2_powerdown                           : in std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 3
      pipe_rx3_char_is_k                           : out std_logic_vector(1 downto 0);
      pipe_rx3_data                                : out std_logic_vector(15 downto 0);
      pipe_rx3_valid                               : out std_logic;
      pipe_rx3_chanisaligned                       : out std_logic;
      pipe_rx3_status                              : out std_logic_vector(2 downto 0);
      pipe_rx3_phy_status                          : out std_logic;
      pipe_rx3_elec_idle                           : out std_logic;
      pipe_rx3_polarity                            : in std_logic;
      pipe_tx3_compliance                          : in std_logic;
      pipe_tx3_char_is_k                           : in std_logic_vector(1 downto 0);
      pipe_tx3_data                                : in std_logic_vector(15 downto 0);
      pipe_tx3_elec_idle                           : in std_logic;
      pipe_tx3_powerdown                           : in std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 4
      pipe_rx4_char_is_k                           : out std_logic_vector(1 downto 0);
      pipe_rx4_data                                : out std_logic_vector(15 downto 0);
      pipe_rx4_valid                               : out std_logic;
      pipe_rx4_chanisaligned                       : out std_logic;
      pipe_rx4_status                              : out std_logic_vector(2 downto 0);
      pipe_rx4_phy_status                          : out std_logic;
      pipe_rx4_elec_idle                           : out std_logic;
      pipe_rx4_polarity                            : in std_logic;
      pipe_tx4_compliance                          : in std_logic;
      pipe_tx4_char_is_k                           : in std_logic_vector(1 downto 0);
      pipe_tx4_data                                : in std_logic_vector(15 downto 0);
      pipe_tx4_elec_idle                           : in std_logic;
      pipe_tx4_powerdown                           : in std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 5
      pipe_rx5_char_is_k                           : out std_logic_vector(1 downto 0);
      pipe_rx5_data                                : out std_logic_vector(15 downto 0);
      pipe_rx5_valid                               : out std_logic;
      pipe_rx5_chanisaligned                       : out std_logic;
      pipe_rx5_status                              : out std_logic_vector(2 downto 0);
      pipe_rx5_phy_status                          : out std_logic;
      pipe_rx5_elec_idle                           : out std_logic;
      pipe_rx5_polarity                            : in std_logic;
      pipe_tx5_compliance                          : in std_logic;
      pipe_tx5_char_is_k                           : in std_logic_vector(1 downto 0);
      pipe_tx5_data                                : in std_logic_vector(15 downto 0);
      pipe_tx5_elec_idle                           : in std_logic;
      pipe_tx5_powerdown                           : in std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 6
      pipe_rx6_char_is_k                           : out std_logic_vector(1 downto 0);
      pipe_rx6_data                                : out std_logic_vector(15 downto 0);
      pipe_rx6_valid                               : out std_logic;
      pipe_rx6_chanisaligned                       : out std_logic;
      pipe_rx6_status                              : out std_logic_vector(2 downto 0);
      pipe_rx6_phy_status                          : out std_logic;
      pipe_rx6_elec_idle                           : out std_logic;
      pipe_rx6_polarity                            : in std_logic;
      pipe_tx6_compliance                          : in std_logic;
      pipe_tx6_char_is_k                           : in std_logic_vector(1 downto 0);
      pipe_tx6_data                                : in std_logic_vector(15 downto 0);
      pipe_tx6_elec_idle                           : in std_logic;
      pipe_tx6_powerdown                           : in std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 7
      pipe_rx7_char_is_k                           : out std_logic_vector(1 downto 0);
      pipe_rx7_data                                : out std_logic_vector(15 downto 0);
      pipe_rx7_valid                               : out std_logic;
      pipe_rx7_chanisaligned                       : out std_logic;
      pipe_rx7_status                              : out std_logic_vector(2 downto 0);
      pipe_rx7_phy_status                          : out std_logic;
      pipe_rx7_elec_idle                           : out std_logic;
      pipe_rx7_polarity                            : in std_logic;
      pipe_tx7_compliance                          : in std_logic;
      pipe_tx7_char_is_k                           : in std_logic_vector(1 downto 0);
      pipe_tx7_data                                : in std_logic_vector(15 downto 0);
      pipe_tx7_elec_idle                           : in std_logic;
      pipe_tx7_powerdown                           : in std_logic_vector(1 downto 0);
      
      -- PCI Express signals
      pci_exp_txn                                  : out std_logic_vector((NO_OF_LANES - 1) downto 0);
      pci_exp_txp                                  : out std_logic_vector((NO_OF_LANES - 1) downto 0);
      pci_exp_rxn                                  : in std_logic_vector((NO_OF_LANES - 1) downto 0);
      pci_exp_rxp                                  : in std_logic_vector((NO_OF_LANES - 1) downto 0);
      
      -- Non PIPE signals
      sys_clk                                      : in std_logic;
      sys_rst_n                                    : in std_logic;
      pipe_clk                                     : in std_logic;
      drp_clk                                      : in std_logic;
      clock_locked                                 : in std_logic;
      gt_pll_lock                                  : out std_logic;
      pl_ltssm_state                               : in std_logic_vector(5 downto 0);
      phy_rdy_n                                    : out std_logic;
      TxOutClk                                     : out std_logic
   );
end pcie_gtx_v6;

architecture v6_pcie of pcie_gtx_v6 is
  component gtx_wrapper_v6 is
    generic (
      NO_OF_LANES                                  : integer := 1;
      REF_CLK_FREQ                                 : integer := 0;
      PL_FAST_TRAIN                                : boolean := FALSE
      );
    port (
      TX                                           : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      TXN                                          : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      TxData                                       : in std_logic_vector((NO_OF_LANES * 16) - 1 downto 0);
      TxDataK                                      : in std_logic_vector((NO_OF_LANES * 2) - 1 downto 0);
      TxElecIdle                                   : in std_logic_vector(NO_OF_LANES - 1 downto 0);
      TxCompliance                                 : in std_logic_vector(NO_OF_LANES - 1 downto 0);
      RX                                           : in std_logic_vector(NO_OF_LANES - 1 downto 0);
      RXN                                          : in std_logic_vector(NO_OF_LANES - 1 downto 0);
      RxData                                       : out std_logic_vector((NO_OF_LANES * 16) - 1 downto 0);
      RxDataK                                      : out std_logic_vector((NO_OF_LANES * 2) - 1 downto 0);
      RxPolarity                                   : in std_logic_vector(NO_OF_LANES - 1 downto 0);
      RxValid                                      : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      RxElecIdle                                   : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      RxStatus                                     : out std_logic_vector((NO_OF_LANES * 3) - 1 downto 0);
      GTRefClkout                                  : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      plm_in_l0                                    : in std_logic;
      plm_in_rl                                    : in std_logic;
      plm_in_dt                                    : in std_logic;
      plm_in_rs                                    : in std_logic;
      RxPLLLkDet                                   : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      TxDetectRx                                   : in std_logic;
      PhyStatus                                    : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      TXPdownAsynch                                : in std_logic;
      PowerDown                                    : in std_logic_vector((NO_OF_LANES * 2) - 1 downto 0);
      Rate                                         : in std_logic;
      Reset_n                                      : in std_logic;
      GTReset_n                                    : in std_logic;
      PCLK                                         : in std_logic;
      REFCLK                                       : in std_logic;
      TxDeemph                                     : in std_logic;
      TxMargin                                     : in std_logic;
      TxSwing                                      : in std_logic;
      ChanIsAligned                                : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      local_pcs_reset                              : in std_logic;
      RxResetDone                                  : out std_logic;
      SyncDone                                     : out std_logic;
      DRPCLK                                       : in std_logic;
      TxOutClk                                     : out std_logic
      );
  end component;

  constant TCQ                                       : integer := 1;		-- clock to out delay model
  
  FUNCTION to_stdlogic (
    in_val      : IN boolean) RETURN std_logic IS
  BEGIN
    IF (in_val) THEN
      RETURN('1');
    ELSE
      RETURN('0');
    END IF;
  END to_stdlogic;

  FUNCTION and_bw (
    val_in : std_logic_vector) RETURN std_logic IS

    VARIABLE ret : std_logic := '1';
  BEGIN
    FOR index IN val_in'RANGE LOOP
      ret := ret AND val_in(index);
    END LOOP;
    RETURN(ret);
  END and_bw;

  FUNCTION nand_bw (
    val_in : std_logic_vector) RETURN std_logic IS

    VARIABLE ret : std_logic := '1';
  BEGIN
    FOR index IN val_in'RANGE LOOP
      ret := ret AND val_in(index);
    END LOOP;
    RETURN(NOT ret);
  END nand_bw;

  signal gt_rx_phy_status_wire                       : std_logic_vector(7 downto 0);
  signal gt_rxchanisaligned_wire                     : std_logic_vector(7 downto 0);
  signal gt_rx_data_k_wire                           : std_logic_vector(127 downto 0);
  signal gt_rx_data_wire                             : std_logic_vector(127 downto 0);
  signal gt_rx_elec_idle_wire                        : std_logic_vector(7 downto 0);
  signal gt_rx_status_wire                           : std_logic_vector(23 downto 0);
  signal gt_rx_valid_wire                            : std_logic_vector(7 downto 0);
  signal gt_rx_polarity                              : std_logic_vector(7 downto 0);
  signal gt_power_down                               : std_logic_vector(15 downto 0);
  signal gt_tx_char_disp_mode                        : std_logic_vector(7 downto 0);
  signal gt_tx_data_k                                : std_logic_vector(15 downto 0);
  signal gt_tx_data                                  : std_logic_vector(127 downto 0);
  signal gt_tx_detect_rx_loopback                    : std_logic;
  signal gt_tx_elec_idle                             : std_logic_vector(7 downto 0);
  signal gt_rx_elec_idle_reset                       : std_logic_vector(7 downto 0);
  
  signal plllkdet                                    : std_logic_vector(NO_OF_LANES - 1 downto 0);
  signal RxResetDone                                 : std_logic;
  signal plm_in_l0                                   : std_logic;
  signal plm_in_rl                                   : std_logic;
  signal plm_in_dt                                   : std_logic;
  signal plm_in_rs                                   : std_logic;
  
  signal local_pcs_reset                             : std_logic;
  signal local_pcs_reset_done                        : std_logic;
  signal cnt_local_pcs_reset                         : std_logic_vector(3 downto 0);
  signal phy_rdy_pre_cnt                             : std_logic_vector(4 downto 0);
  signal pl_ltssm_state_q                            : std_logic_vector(5 downto 0);

  signal SyncDone                                    : std_logic;

  -- X-HDL generated signals

  signal v6pcie5 : std_logic;
  
  -- Declare intermediate signals for referenced outputs
  signal pci_exp_txn_v6pcie2                         : std_logic_vector((NO_OF_LANES - 1) downto 0);
  signal pci_exp_txp_v6pcie3                         : std_logic_vector((NO_OF_LANES - 1) downto 0);
  signal gt_pll_lock_v6pcie1                         : std_logic;
  signal phy_rdy_n_v6pcie4                           : std_logic;
  signal TxOutClk_v6pcie0                            : std_logic;

  signal plllkdet_nand                               : std_logic;

begin
  -- Drive referenced outputs
  pci_exp_txn <= pci_exp_txn_v6pcie2;
  pci_exp_txp <= pci_exp_txp_v6pcie3;
  gt_pll_lock <= gt_pll_lock_v6pcie1;
  phy_rdy_n <= phy_rdy_n_v6pcie4;
  TxOutClk <= TxOutClk_v6pcie0;
  plm_in_l0 <= to_stdlogic((pl_ltssm_state = "010110"));
  plm_in_rl <= to_stdlogic((pl_ltssm_state = "011100"));
  plm_in_dt <= to_stdlogic((pl_ltssm_state = "101101"));
  plm_in_rs <= to_stdlogic((pl_ltssm_state = "011111"));

  v6pcie5 <= not(clock_locked);

  gtx_v6_i : gtx_wrapper_v6
    generic map (
      NO_OF_LANES    => NO_OF_LANES,
      REF_CLK_FREQ   => REF_CLK_FREQ,
      PL_FAST_TRAIN  => PL_FAST_TRAIN
      )
    port map (
      
      -- TX
      TX               => pci_exp_txp_v6pcie3(((NO_OF_LANES) - 1) downto 0),
      TXN              => pci_exp_txn_v6pcie2(((NO_OF_LANES) - 1) downto 0),
      TxData           => gt_tx_data(((16 * NO_OF_LANES) - 1) downto 0),
      TxDataK          => gt_tx_data_k(((2 * NO_OF_LANES) - 1) downto 0),
      TxElecIdle       => gt_tx_elec_idle(((NO_OF_LANES) - 1) downto 0),
      TxCompliance     => gt_tx_char_disp_mode(((NO_OF_LANES) - 1) downto 0),
      
      -- RX
      RX               => pci_exp_rxp(((NO_OF_LANES) - 1) downto 0),
      RXN              => pci_exp_rxn(((NO_OF_LANES) - 1) downto 0),
      RxData           => gt_rx_data_wire(((16 * NO_OF_LANES) - 1) downto 0),
      RxDataK          => gt_rx_data_k_wire(((2 * NO_OF_LANES) - 1) downto 0),
      RxPolarity       => gt_rx_polarity(((NO_OF_LANES) - 1) downto 0),
      RxValid          => gt_rx_valid_wire(((NO_OF_LANES) - 1) downto 0),
      RxElecIdle       => gt_rx_elec_idle_wire(((NO_OF_LANES) - 1) downto 0),
      RxStatus         => gt_rx_status_wire(((3 * NO_OF_LANES) - 1) downto 0),
      
      -- other
      GTRefClkout      => open,
      plm_in_l0        => plm_in_l0,
      plm_in_rl        => plm_in_rl,
      plm_in_dt        => plm_in_dt,
      plm_in_rs        => plm_in_rs,
      RxPLLLkDet       => plllkdet,
      ChanIsAligned    => gt_rxchanisaligned_wire(((NO_OF_LANES) - 1) downto 0),
      TxDetectRx       => gt_tx_detect_rx_loopback,
      PhyStatus        => gt_rx_phy_status_wire(((NO_OF_LANES) - 1) downto 0),
      TXPdownAsynch    => v6pcie5,
      PowerDown        => gt_power_down(((2 * NO_OF_LANES) - 1) downto 0),
      Rate             => pipe_tx_rate,
      Reset_n          => clock_locked,
      GTReset_n        => sys_rst_n,
      PCLK             => pipe_clk,
      REFCLK           => sys_clk,
      DRPCLK           => drp_clk,
      TxDeemph         => pipe_tx_deemph,
      TxMargin         => pipe_tx_margin(2),
      TxSwing          => pipe_tx_swing,
      local_pcs_reset  => local_pcs_reset,
      RxResetDone      => RxResetDone,
      SyncDone         => SyncDone,
      TxOutClk         => TxOutClk_v6pcie0
      );
  
  pipe_rx0_phy_status <= gt_rx_phy_status_wire(0);
  pipe_rx1_phy_status <= gt_rx_phy_status_wire(1) when (NO_OF_LANES >= 2) else
                         '0';
  pipe_rx2_phy_status <= gt_rx_phy_status_wire(2) when (NO_OF_LANES >= 4) else
                         '0';
  pipe_rx3_phy_status <= gt_rx_phy_status_wire(3) when (NO_OF_LANES >= 4) else
                         '0';
  pipe_rx4_phy_status <= gt_rx_phy_status_wire(4) when (NO_OF_LANES >= 8) else
                         '0';
  pipe_rx5_phy_status <= gt_rx_phy_status_wire(5) when (NO_OF_LANES >= 8) else
                         '0';
  pipe_rx6_phy_status <= gt_rx_phy_status_wire(6) when (NO_OF_LANES >= 8) else
                         '0';
  pipe_rx7_phy_status <= gt_rx_phy_status_wire(7) when (NO_OF_LANES >= 8) else
                         '0';
  
  pipe_rx0_chanisaligned <= gt_rxchanisaligned_wire(0);
  pipe_rx1_chanisaligned <= gt_rxchanisaligned_wire(1) when (NO_OF_LANES >= 2) else
                            '0';
  pipe_rx2_chanisaligned <= gt_rxchanisaligned_wire(2) when (NO_OF_LANES >= 4) else
                            '0';
  pipe_rx3_chanisaligned <= gt_rxchanisaligned_wire(3) when (NO_OF_LANES >= 4) else
                            '0';
  pipe_rx4_chanisaligned <= gt_rxchanisaligned_wire(4) when (NO_OF_LANES >= 8) else
                            '0';
  pipe_rx5_chanisaligned <= gt_rxchanisaligned_wire(5) when (NO_OF_LANES >= 8) else
                            '0';
  pipe_rx6_chanisaligned <= gt_rxchanisaligned_wire(6) when (NO_OF_LANES >= 8) else
                            '0';
  pipe_rx7_chanisaligned <= gt_rxchanisaligned_wire(7) when (NO_OF_LANES >= 8) else
                            '0';
  
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  pipe_rx0_char_is_k <= (gt_rx_data_k_wire(1) & gt_rx_data_k_wire(0));
  pipe_rx1_char_is_k <= (gt_rx_data_k_wire(3) & gt_rx_data_k_wire(2)) when (NO_OF_LANES >= 2) else
                        "00";
  pipe_rx2_char_is_k <= (gt_rx_data_k_wire(5) & gt_rx_data_k_wire(4)) when (NO_OF_LANES >= 4) else
                        "00";
  pipe_rx3_char_is_k <= (gt_rx_data_k_wire(7) & gt_rx_data_k_wire(6)) when (NO_OF_LANES >= 4) else
                        "00";
  pipe_rx4_char_is_k <= (gt_rx_data_k_wire(9) & gt_rx_data_k_wire(8)) when (NO_OF_LANES >= 8) else
                        "00";
  pipe_rx5_char_is_k <= (gt_rx_data_k_wire(11) & gt_rx_data_k_wire(10)) when (NO_OF_LANES >= 8) else
                        "00";
  pipe_rx6_char_is_k <= (gt_rx_data_k_wire(13) & gt_rx_data_k_wire(12)) when (NO_OF_LANES >= 8) else
                        "00";
  pipe_rx7_char_is_k <= (gt_rx_data_k_wire(15) & gt_rx_data_k_wire(14)) when (NO_OF_LANES >= 8) else
                        "00";
  
  pipe_rx0_data <= (gt_rx_data_wire(15 downto 8) & gt_rx_data_wire(7 downto 0));
  pipe_rx1_data <= (gt_rx_data_wire(31 downto 24) & gt_rx_data_wire(23 downto 16)) when (NO_OF_LANES >= 2) else
                   "0000000000000000";
  pipe_rx2_data <= (gt_rx_data_wire(47 downto 40) & gt_rx_data_wire(39 downto 32)) when (NO_OF_LANES >= 4) else
                   "0000000000000000";
  pipe_rx3_data <= (gt_rx_data_wire(63 downto 56) & gt_rx_data_wire(55 downto 48)) when (NO_OF_LANES >= 4) else
                   "0000000000000000";
  pipe_rx4_data <= (gt_rx_data_wire(79 downto 72) & gt_rx_data_wire(71 downto 64)) when (NO_OF_LANES >= 8) else
                   "0000000000000000";
  pipe_rx5_data <= (gt_rx_data_wire(95 downto 88) & gt_rx_data_wire(87 downto 80)) when (NO_OF_LANES >= 8) else
                   "0000000000000000";
  pipe_rx6_data <= (gt_rx_data_wire(111 downto 104) & gt_rx_data_wire(103 downto 96)) when (NO_OF_LANES >= 8) else
                   "0000000000000000";
  pipe_rx7_data <= (gt_rx_data_wire(127 downto 120) & gt_rx_data_wire(119 downto 112)) when (NO_OF_LANES >= 8) else
                   "0000000000000000";
  
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  pipe_rx0_elec_idle <= gt_rx_elec_idle_wire(0);
  pipe_rx1_elec_idle <= gt_rx_elec_idle_wire(1) when (NO_OF_LANES >= 2) else
                        '1';
  pipe_rx2_elec_idle <= gt_rx_elec_idle_wire(2) when (NO_OF_LANES >= 4) else
                        '1';
  pipe_rx3_elec_idle <= gt_rx_elec_idle_wire(3) when (NO_OF_LANES >= 4) else
                        '1';
  pipe_rx4_elec_idle <= gt_rx_elec_idle_wire(4) when (NO_OF_LANES >= 8) else
                        '1';
  pipe_rx5_elec_idle <= gt_rx_elec_idle_wire(5) when (NO_OF_LANES >= 8) else
                        '1';
  pipe_rx6_elec_idle <= gt_rx_elec_idle_wire(6) when (NO_OF_LANES >= 8) else
                        '1';
  pipe_rx7_elec_idle <= gt_rx_elec_idle_wire(7) when (NO_OF_LANES >= 8) else
                        '1';
  
  pipe_rx0_status <= gt_rx_status_wire(2 downto 0);
  pipe_rx1_status <= gt_rx_status_wire(5 downto 3) when (NO_OF_LANES >= 2) else
                     "000";
  pipe_rx2_status <= gt_rx_status_wire(8 downto 6) when (NO_OF_LANES >= 4) else
                     "000";
  pipe_rx3_status <= gt_rx_status_wire(11 downto 9) when (NO_OF_LANES >= 4) else
                     "000";
  pipe_rx4_status <= gt_rx_status_wire(14 downto 12) when (NO_OF_LANES >= 8) else
                     "000";
  pipe_rx5_status <= gt_rx_status_wire(17 downto 15) when (NO_OF_LANES >= 8) else
                     "000";
  pipe_rx6_status <= gt_rx_status_wire(20 downto 18) when (NO_OF_LANES >= 8) else
                     "000";
  pipe_rx7_status <= gt_rx_status_wire(23 downto 21) when (NO_OF_LANES >= 8) else
                     "000";
  
  pipe_rx0_valid <= gt_rx_valid_wire(0);
  pipe_rx1_valid <= gt_rx_valid_wire(1) when (NO_OF_LANES >= 2) else
                    '0';
  pipe_rx2_valid <= gt_rx_valid_wire(2) when (NO_OF_LANES >= 4) else
                    '0';
  pipe_rx3_valid <= gt_rx_valid_wire(3) when (NO_OF_LANES >= 4) else
                    '0';
  pipe_rx4_valid <= gt_rx_valid_wire(4) when (NO_OF_LANES >= 8) else
                    '0';
  pipe_rx5_valid <= gt_rx_valid_wire(5) when (NO_OF_LANES >= 8) else
                    '0';
  pipe_rx6_valid <= gt_rx_valid_wire(6) when (NO_OF_LANES >= 8) else
                    '0';
  pipe_rx7_valid <= gt_rx_valid_wire(7) when (NO_OF_LANES >= 8) else
                    '0';
  
  gt_rx_polarity(0) <= pipe_rx0_polarity;
  gt_rx_polarity(1) <= pipe_rx1_polarity;
  gt_rx_polarity(2) <= pipe_rx2_polarity;
  gt_rx_polarity(3) <= pipe_rx3_polarity;
  gt_rx_polarity(4) <= pipe_rx4_polarity;
  gt_rx_polarity(5) <= pipe_rx5_polarity;
  gt_rx_polarity(6) <= pipe_rx6_polarity;
  gt_rx_polarity(7) <= pipe_rx7_polarity;
  
  gt_power_down(1 downto 0) <= pipe_tx0_powerdown;
  gt_power_down(3 downto 2) <= pipe_tx1_powerdown;
  gt_power_down(5 downto 4) <= pipe_tx2_powerdown;
  gt_power_down(7 downto 6) <= pipe_tx3_powerdown;
  gt_power_down(9 downto 8) <= pipe_tx4_powerdown;
  gt_power_down(11 downto 10) <= pipe_tx5_powerdown;
  gt_power_down(13 downto 12) <= pipe_tx6_powerdown;
  gt_power_down(15 downto 14) <= pipe_tx7_powerdown;
  
  gt_tx_char_disp_mode <= (pipe_tx7_compliance & pipe_tx6_compliance & pipe_tx5_compliance & pipe_tx4_compliance & pipe_tx3_compliance & pipe_tx2_compliance & pipe_tx1_compliance & pipe_tx0_compliance);
  
  gt_tx_data_k <= (pipe_tx7_char_is_k & pipe_tx6_char_is_k & pipe_tx5_char_is_k & pipe_tx4_char_is_k & pipe_tx3_char_is_k & pipe_tx2_char_is_k & pipe_tx1_char_is_k & pipe_tx0_char_is_k);
  
  gt_tx_data <= (pipe_tx7_data & pipe_tx6_data & pipe_tx5_data & pipe_tx4_data & pipe_tx3_data & pipe_tx2_data & pipe_tx1_data & pipe_tx0_data);
  
  gt_tx_detect_rx_loopback <= pipe_tx_rcvr_det;
  
  gt_tx_elec_idle <= (pipe_tx7_elec_idle & pipe_tx6_elec_idle & pipe_tx5_elec_idle & pipe_tx4_elec_idle & pipe_tx3_elec_idle & pipe_tx2_elec_idle & pipe_tx1_elec_idle & pipe_tx0_elec_idle);
  
  gt_pll_lock_v6pcie1 <= and_bw(plllkdet(NO_OF_LANES - 1 downto 0)) or not(phy_rdy_pre_cnt(4));
  
  plllkdet_nand <=  nand_bw(plllkdet(NO_OF_LANES - 1 downto 0));

  -- Asserted after all workarounds have completed.
  
  process (pipe_clk, clock_locked)
  begin
    
    if ((not(clock_locked)) = '1') then

      phy_rdy_n_v6pcie4 <= '1' after (TCQ)*1 ps;

    elsif (pipe_clk'event and pipe_clk = '1') then
      
      if (plllkdet_nand = '1') then
        phy_rdy_n_v6pcie4 <= '1' after (TCQ)*1 ps;
      elsif ((local_pcs_reset_done and RxResetDone and phy_rdy_n_v6pcie4 and SyncDone) = '1') then
        phy_rdy_n_v6pcie4 <= '0' after (TCQ)*1 ps;
      end if;

    end if;
  end process;
  
  
  -- Handle the warm reset case, where sys_rst_n is asseted when
  -- phy_rdy_n is asserted. phy_rdy_n is to be de-asserted
  -- before gt_pll_lock is de-asserted so that synnchronous
  -- logic see reset de-asset before clock is lost.
  
  process (pipe_clk, clock_locked)
  begin
    
    if ((not(clock_locked)) = '1') then

      phy_rdy_pre_cnt <= "11111" after (TCQ)*1 ps;

    elsif (pipe_clk'event and pipe_clk = '1') then
      
      if ((gt_pll_lock_v6pcie1 and phy_rdy_n_v6pcie4) = '1') then
        
        phy_rdy_pre_cnt <= phy_rdy_pre_cnt + "00001" after (TCQ)*1 ps;

      end if;
    end if;
  end process;
  
  
  process (pipe_clk, clock_locked)
  begin
    
    if ((not(clock_locked)) = '1') then
      
      cnt_local_pcs_reset <= "1111" after (TCQ)*1 ps;
      local_pcs_reset <= '0' after (TCQ)*1 ps;
      local_pcs_reset_done <= '0' after (TCQ)*1 ps;

    elsif (pipe_clk'event and pipe_clk = '1') then
      
      if ((local_pcs_reset = '0') and (cnt_local_pcs_reset = "1111")) then
        local_pcs_reset <= '1' after (TCQ)*1 ps;
      elsif ((local_pcs_reset = '1') and (cnt_local_pcs_reset /= "0000")) then
        local_pcs_reset <= '1' after (TCQ)*1 ps;
        cnt_local_pcs_reset <= cnt_local_pcs_reset - "0001" after (TCQ)*1 ps;
      elsif ((local_pcs_reset = '1') and (cnt_local_pcs_reset = "0000")) then
        local_pcs_reset <= '0' after (TCQ)*1 ps;
        local_pcs_reset_done <= '1' after (TCQ)*1 ps;
      end if;

    end if;
  end process;
  
  process (pipe_clk, clock_locked)
  begin
    
    if ((not(clock_locked)) = '1') then

      pl_ltssm_state_q <= "000000" after (TCQ)*1 ps;

    elsif (pipe_clk'event and pipe_clk = '1') then
      
      pl_ltssm_state_q <= pl_ltssm_state_q + "000001" after (TCQ)*1 ps;

    end if;
  end process;
  
  
end v6_pcie;
