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
-- File       : pcie_pipe_v6.vhd
-- Version    : 2.3
---- Description: PIPE module for Virtex6 PCIe Block
----
----
----
----------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;

entity pcie_pipe_v6 is
   generic (
      NO_OF_LANES                                  : integer := 8;
      LINK_CAP_MAX_LINK_SPEED                      : bit_vector := X"1";
      PIPE_PIPELINE_STAGES                         : integer := 0		-- 0 - 0 stages, 1 - 1 stage, 2 - 2 stages
   );
   port (
      -- Pipe Per-Link Signals	
      pipe_tx_rcvr_det_i                           : in std_logic;
      pipe_tx_reset_i                              : in std_logic;
      pipe_tx_rate_i                               : in std_logic;
      pipe_tx_deemph_i                             : in std_logic;
      pipe_tx_margin_i                             : in std_logic_vector(2 downto 0);
      pipe_tx_swing_i                              : in std_logic;

      pipe_tx_rcvr_det_o                           : out std_logic;
      pipe_tx_reset_o                              : out std_logic;
      pipe_tx_rate_o                               : out std_logic;
      pipe_tx_deemph_o                             : out std_logic;
      pipe_tx_margin_o                             : out std_logic_vector(2 downto 0);
      pipe_tx_swing_o                              : out std_logic;
      
      -- Pipe Per-Lane Signals - Lane 0
      pipe_rx0_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_rx0_data_o                              : out std_logic_vector(15 downto 0);
      pipe_rx0_valid_o                             : out std_logic;
      pipe_rx0_chanisaligned_o                     : out std_logic;
      pipe_rx0_status_o                            : out std_logic_vector(2 downto 0);
      pipe_rx0_phy_status_o                        : out std_logic;
      pipe_rx0_elec_idle_o                         : out std_logic;
      pipe_rx0_polarity_i                          : in std_logic;

      pipe_tx0_compliance_i                        : in std_logic;
      pipe_tx0_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_tx0_data_i                              : in std_logic_vector(15 downto 0);
      pipe_tx0_elec_idle_i                         : in std_logic;
      pipe_tx0_powerdown_i                         : in std_logic_vector(1 downto 0);

      pipe_rx0_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_rx0_data_i                              : in std_logic_vector(15 downto 0);
      pipe_rx0_valid_i                             : in std_logic;
      pipe_rx0_chanisaligned_i                     : in std_logic;
      pipe_rx0_status_i                            : in std_logic_vector(2 downto 0);
      pipe_rx0_phy_status_i                        : in std_logic;
      pipe_rx0_elec_idle_i                         : in std_logic;
      pipe_rx0_polarity_o                          : out std_logic;

      pipe_tx0_compliance_o                        : out std_logic;
      pipe_tx0_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_tx0_data_o                              : out std_logic_vector(15 downto 0);
      pipe_tx0_elec_idle_o                         : out std_logic;
      pipe_tx0_powerdown_o                         : out std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 1
      pipe_rx1_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_rx1_data_o                              : out std_logic_vector(15 downto 0);
      pipe_rx1_valid_o                             : out std_logic;
      pipe_rx1_chanisaligned_o                     : out std_logic;
      pipe_rx1_status_o                            : out std_logic_vector(2 downto 0);
      pipe_rx1_phy_status_o                        : out std_logic;
      pipe_rx1_elec_idle_o                         : out std_logic;
      pipe_rx1_polarity_i                          : in std_logic;

      pipe_tx1_compliance_i                        : in std_logic;
      pipe_tx1_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_tx1_data_i                              : in std_logic_vector(15 downto 0);
      pipe_tx1_elec_idle_i                         : in std_logic;
      pipe_tx1_powerdown_i                         : in std_logic_vector(1 downto 0);

      pipe_rx1_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_rx1_data_i                              : in std_logic_vector(15 downto 0);
      pipe_rx1_valid_i                             : in std_logic;
      pipe_rx1_chanisaligned_i                     : in std_logic;
      pipe_rx1_status_i                            : in std_logic_vector(2 downto 0);
      pipe_rx1_phy_status_i                        : in std_logic;
      pipe_rx1_elec_idle_i                         : in std_logic;
      pipe_rx1_polarity_o                          : out std_logic;

      pipe_tx1_compliance_o                        : out std_logic;
      pipe_tx1_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_tx1_data_o                              : out std_logic_vector(15 downto 0);
      pipe_tx1_elec_idle_o                         : out std_logic;
      pipe_tx1_powerdown_o                         : out std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 2
      pipe_rx2_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_rx2_data_o                              : out std_logic_vector(15 downto 0);
      pipe_rx2_valid_o                             : out std_logic;
      pipe_rx2_chanisaligned_o                     : out std_logic;
      pipe_rx2_status_o                            : out std_logic_vector(2 downto 0);
      pipe_rx2_phy_status_o                        : out std_logic;
      pipe_rx2_elec_idle_o                         : out std_logic;
      pipe_rx2_polarity_i                          : in std_logic;

      pipe_tx2_compliance_i                        : in std_logic;
      pipe_tx2_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_tx2_data_i                              : in std_logic_vector(15 downto 0);
      pipe_tx2_elec_idle_i                         : in std_logic;
      pipe_tx2_powerdown_i                         : in std_logic_vector(1 downto 0);

      pipe_rx2_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_rx2_data_i                              : in std_logic_vector(15 downto 0);
      pipe_rx2_valid_i                             : in std_logic;
      pipe_rx2_chanisaligned_i                     : in std_logic;
      pipe_rx2_status_i                            : in std_logic_vector(2 downto 0);
      pipe_rx2_phy_status_i                        : in std_logic;
      pipe_rx2_elec_idle_i                         : in std_logic;
      pipe_rx2_polarity_o                          : out std_logic;

      pipe_tx2_compliance_o                        : out std_logic;
      pipe_tx2_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_tx2_data_o                              : out std_logic_vector(15 downto 0);
      pipe_tx2_elec_idle_o                         : out std_logic;
      pipe_tx2_powerdown_o                         : out std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 3
      pipe_rx3_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_rx3_data_o                              : out std_logic_vector(15 downto 0);
      pipe_rx3_valid_o                             : out std_logic;
      pipe_rx3_chanisaligned_o                     : out std_logic;
      pipe_rx3_status_o                            : out std_logic_vector(2 downto 0);
      pipe_rx3_phy_status_o                        : out std_logic;
      pipe_rx3_elec_idle_o                         : out std_logic;
      pipe_rx3_polarity_i                          : in std_logic;

      pipe_tx3_compliance_i                        : in std_logic;
      pipe_tx3_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_tx3_data_i                              : in std_logic_vector(15 downto 0);
      pipe_tx3_elec_idle_i                         : in std_logic;
      pipe_tx3_powerdown_i                         : in std_logic_vector(1 downto 0);

      pipe_rx3_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_rx3_data_i                              : in std_logic_vector(15 downto 0);
      pipe_rx3_valid_i                             : in std_logic;
      pipe_rx3_chanisaligned_i                     : in std_logic;
      pipe_rx3_status_i                            : in std_logic_vector(2 downto 0);
      pipe_rx3_phy_status_i                        : in std_logic;
      pipe_rx3_elec_idle_i                         : in std_logic;
      pipe_rx3_polarity_o                          : out std_logic;

      pipe_tx3_compliance_o                        : out std_logic;
      pipe_tx3_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_tx3_data_o                              : out std_logic_vector(15 downto 0);
      pipe_tx3_elec_idle_o                         : out std_logic;
      pipe_tx3_powerdown_o                         : out std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 4
      pipe_rx4_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_rx4_data_o                              : out std_logic_vector(15 downto 0);
      pipe_rx4_valid_o                             : out std_logic;
      pipe_rx4_chanisaligned_o                     : out std_logic;
      pipe_rx4_status_o                            : out std_logic_vector(2 downto 0);
      pipe_rx4_phy_status_o                        : out std_logic;
      pipe_rx4_elec_idle_o                         : out std_logic;
      pipe_rx4_polarity_i                          : in std_logic;

      pipe_tx4_compliance_i                        : in std_logic;
      pipe_tx4_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_tx4_data_i                              : in std_logic_vector(15 downto 0);
      pipe_tx4_elec_idle_i                         : in std_logic;
      pipe_tx4_powerdown_i                         : in std_logic_vector(1 downto 0);

      pipe_rx4_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_rx4_data_i                              : in std_logic_vector(15 downto 0);
      pipe_rx4_valid_i                             : in std_logic;
      pipe_rx4_chanisaligned_i                     : in std_logic;
      pipe_rx4_status_i                            : in std_logic_vector(2 downto 0);
      pipe_rx4_phy_status_i                        : in std_logic;
      pipe_rx4_elec_idle_i                         : in std_logic;
      pipe_rx4_polarity_o                          : out std_logic;

      pipe_tx4_compliance_o                        : out std_logic;
      pipe_tx4_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_tx4_data_o                              : out std_logic_vector(15 downto 0);
      pipe_tx4_elec_idle_o                         : out std_logic;
      pipe_tx4_powerdown_o                         : out std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 5
      pipe_rx5_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_rx5_data_o                              : out std_logic_vector(15 downto 0);
      pipe_rx5_valid_o                             : out std_logic;
      pipe_rx5_chanisaligned_o                     : out std_logic;
      pipe_rx5_status_o                            : out std_logic_vector(2 downto 0);
      pipe_rx5_phy_status_o                        : out std_logic;
      pipe_rx5_elec_idle_o                         : out std_logic;
      pipe_rx5_polarity_i                          : in std_logic;

      pipe_tx5_compliance_i                        : in std_logic;
      pipe_tx5_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_tx5_data_i                              : in std_logic_vector(15 downto 0);
      pipe_tx5_elec_idle_i                         : in std_logic;
      pipe_tx5_powerdown_i                         : in std_logic_vector(1 downto 0);

      pipe_rx5_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_rx5_data_i                              : in std_logic_vector(15 downto 0);
      pipe_rx5_valid_i                             : in std_logic;
      pipe_rx5_chanisaligned_i                     : in std_logic;
      pipe_rx5_status_i                            : in std_logic_vector(2 downto 0);
      pipe_rx5_phy_status_i                        : in std_logic;
      pipe_rx5_elec_idle_i                         : in std_logic;
      pipe_rx5_polarity_o                          : out std_logic;

      pipe_tx5_compliance_o                        : out std_logic;
      pipe_tx5_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_tx5_data_o                              : out std_logic_vector(15 downto 0);
      pipe_tx5_elec_idle_o                         : out std_logic;
      pipe_tx5_powerdown_o                         : out std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 6
      pipe_rx6_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_rx6_data_o                              : out std_logic_vector(15 downto 0);
      pipe_rx6_valid_o                             : out std_logic;
      pipe_rx6_chanisaligned_o                     : out std_logic;
      pipe_rx6_status_o                            : out std_logic_vector(2 downto 0);
      pipe_rx6_phy_status_o                        : out std_logic;
      pipe_rx6_elec_idle_o                         : out std_logic;
      pipe_rx6_polarity_i                          : in std_logic;

      pipe_tx6_compliance_i                        : in std_logic;
      pipe_tx6_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_tx6_data_i                              : in std_logic_vector(15 downto 0);
      pipe_tx6_elec_idle_i                         : in std_logic;
      pipe_tx6_powerdown_i                         : in std_logic_vector(1 downto 0);

      pipe_rx6_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_rx6_data_i                              : in std_logic_vector(15 downto 0);
      pipe_rx6_valid_i                             : in std_logic;
      pipe_rx6_chanisaligned_i                     : in std_logic;
      pipe_rx6_status_i                            : in std_logic_vector(2 downto 0);
      pipe_rx6_phy_status_i                        : in std_logic;
      pipe_rx6_elec_idle_i                         : in std_logic;
      pipe_rx6_polarity_o                          : out std_logic;

      pipe_tx6_compliance_o                        : out std_logic;
      pipe_tx6_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_tx6_data_o                              : out std_logic_vector(15 downto 0);
      pipe_tx6_elec_idle_o                         : out std_logic;
      pipe_tx6_powerdown_o                         : out std_logic_vector(1 downto 0);
      
      -- Pipe Per-Lane Signals - Lane 7
      pipe_rx7_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_rx7_data_o                              : out std_logic_vector(15 downto 0);
      pipe_rx7_valid_o                             : out std_logic;
      pipe_rx7_chanisaligned_o                     : out std_logic;
      pipe_rx7_status_o                            : out std_logic_vector(2 downto 0);
      pipe_rx7_phy_status_o                        : out std_logic;
      pipe_rx7_elec_idle_o                         : out std_logic;
      pipe_rx7_polarity_i                          : in std_logic;

      pipe_tx7_compliance_i                        : in std_logic;
      pipe_tx7_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_tx7_data_i                              : in std_logic_vector(15 downto 0);
      pipe_tx7_elec_idle_i                         : in std_logic;
      pipe_tx7_powerdown_i                         : in std_logic_vector(1 downto 0);

      pipe_rx7_char_is_k_i                         : in std_logic_vector(1 downto 0);
      pipe_rx7_data_i                              : in std_logic_vector(15 downto 0);
      pipe_rx7_valid_i                             : in std_logic;
      pipe_rx7_chanisaligned_i                     : in std_logic;
      pipe_rx7_status_i                            : in std_logic_vector(2 downto 0);
      pipe_rx7_phy_status_i                        : in std_logic;
      pipe_rx7_elec_idle_i                         : in std_logic;
      pipe_rx7_polarity_o                          : out std_logic;

      pipe_tx7_compliance_o                        : out std_logic;
      pipe_tx7_char_is_k_o                         : out std_logic_vector(1 downto 0);
      pipe_tx7_data_o                              : out std_logic_vector(15 downto 0);
      pipe_tx7_elec_idle_o                         : out std_logic;
      pipe_tx7_powerdown_o                         : out std_logic_vector(1 downto 0);
      
      -- Non PIPE signals
      pl_ltssm_state                               : in std_logic_vector(5 downto 0);
      pipe_clk                                     : in std_logic;
      rst_n                                        : in std_logic
   );
end pcie_pipe_v6;

architecture v6_pcie of pcie_pipe_v6 is
   component pcie_pipe_lane_v6 is
      generic (
         PIPE_PIPELINE_STAGES                         : integer := 0
      );
      port (
         pipe_rx_char_is_k_o                          : out std_logic_vector(1 downto 0);
         pipe_rx_data_o                               : out std_logic_vector(15 downto 0);
         pipe_rx_valid_o                              : out std_logic;
         pipe_rx_chanisaligned_o                      : out std_logic;
         pipe_rx_status_o                             : out std_logic_vector(2 downto 0);
         pipe_rx_phy_status_o                         : out std_logic;
         pipe_rx_elec_idle_o                          : out std_logic;
         pipe_rx_polarity_i                           : in std_logic;
         pipe_tx_compliance_i                         : in std_logic;
         pipe_tx_char_is_k_i                          : in std_logic_vector(1 downto 0);
         pipe_tx_data_i                               : in std_logic_vector(15 downto 0);
         pipe_tx_elec_idle_i                          : in std_logic;
         pipe_tx_powerdown_i                          : in std_logic_vector(1 downto 0);
         pipe_rx_char_is_k_i                          : in std_logic_vector(1 downto 0);
         pipe_rx_data_i                               : in std_logic_vector(15 downto 0);
         pipe_rx_valid_i                              : in std_logic;
         pipe_rx_chanisaligned_i                      : in std_logic;
         pipe_rx_status_i                             : in std_logic_vector(2 downto 0);
         pipe_rx_phy_status_i                         : in std_logic;
         pipe_rx_elec_idle_i                          : in std_logic;
         pipe_rx_polarity_o                           : out std_logic;
         pipe_tx_compliance_o                         : out std_logic;
         pipe_tx_char_is_k_o                          : out std_logic_vector(1 downto 0);
         pipe_tx_data_o                               : out std_logic_vector(15 downto 0);
         pipe_tx_elec_idle_o                          : out std_logic;
         pipe_tx_powerdown_o                          : out std_logic_vector(1 downto 0);
         pipe_clk                                     : in std_logic;
         rst_n                                        : in std_logic
      );
   end component;
   
   component pcie_pipe_misc_v6 is
      generic (
         PIPE_PIPELINE_STAGES                         : integer := 0
      );
      port (
         pipe_tx_rcvr_det_i                           : in std_logic;
         pipe_tx_reset_i                              : in std_logic;
         pipe_tx_rate_i                               : in std_logic;
         pipe_tx_deemph_i                             : in std_logic;
         pipe_tx_margin_i                             : in std_logic_vector(2 downto 0);
         pipe_tx_swing_i                              : in std_logic;
         pipe_tx_rcvr_det_o                           : out std_logic;
         pipe_tx_reset_o                              : out std_logic;
         pipe_tx_rate_o                               : out std_logic;
         pipe_tx_deemph_o                             : out std_logic;
         pipe_tx_margin_o                             : out std_logic_vector(2 downto 0);
         pipe_tx_swing_o                              : out std_logic;
         pipe_clk                                     : in std_logic;
         rst_n                                        : in std_logic
      );
   end component;
   
      --******************************************************************//
      -- Reality check.                                                   //
      --******************************************************************//
      
   constant Tc2o                                      : integer := 1;		-- clock to out delay model

   signal pipe_rx0_char_is_k_q                         : std_logic_vector(1 downto 0);
   signal pipe_rx0_data_q                              : std_logic_vector(15 downto 0);
   signal pipe_rx1_char_is_k_q                         : std_logic_vector(1 downto 0);
   signal pipe_rx1_data_q                              : std_logic_vector(15 downto 0);
   signal pipe_rx2_char_is_k_q                         : std_logic_vector(1 downto 0);
   signal pipe_rx2_data_q                              : std_logic_vector(15 downto 0);
   signal pipe_rx3_char_is_k_q                         : std_logic_vector(1 downto 0);
   signal pipe_rx3_data_q                              : std_logic_vector(15 downto 0);
   signal pipe_rx4_char_is_k_q                         : std_logic_vector(1 downto 0);
   signal pipe_rx4_data_q                              : std_logic_vector(15 downto 0);
   signal pipe_rx5_char_is_k_q                         : std_logic_vector(1 downto 0);
   signal pipe_rx5_data_q                              : std_logic_vector(15 downto 0);
   signal pipe_rx6_char_is_k_q                         : std_logic_vector(1 downto 0);
   signal pipe_rx6_data_q                              : std_logic_vector(15 downto 0);
   signal pipe_rx7_char_is_k_q                         : std_logic_vector(1 downto 0);
   signal pipe_rx7_data_q                              : std_logic_vector(15 downto 0);
   
   -- Declare intermediate signals for referenced outputs
   signal pipe_tx_rcvr_det_o_v6pcie91                  : std_logic;
   signal pipe_tx_reset_o_v6pcie92                     : std_logic;
   signal pipe_tx_rate_o_v6pcie90                      : std_logic;
   signal pipe_tx_deemph_o_v6pcie88                    : std_logic;
   signal pipe_tx_margin_o_v6pcie89                    : std_logic_vector(2 downto 0);
   signal pipe_tx_swing_o_v6pcie93                     : std_logic;
   signal pipe_rx0_valid_o_v6pcie5                     : std_logic;
   signal pipe_rx0_chanisaligned_o_v6pcie0             : std_logic;
   signal pipe_rx0_status_o_v6pcie4                    : std_logic_vector(2 downto 0);
   signal pipe_rx0_phy_status_o_v6pcie2                : std_logic;
   signal pipe_rx0_elec_idle_o_v6pcie1                 : std_logic;
   signal pipe_rx0_polarity_o_v6pcie3                  : std_logic;
   signal pipe_tx0_compliance_o_v6pcie49               : std_logic;
   signal pipe_tx0_char_is_k_o_v6pcie48                : std_logic_vector(1 downto 0);
   signal pipe_tx0_data_o_v6pcie50                     : std_logic_vector(15 downto 0);
   signal pipe_tx0_elec_idle_o_v6pcie51                : std_logic;
   signal pipe_tx0_powerdown_o_v6pcie52                : std_logic_vector(1 downto 0);
   signal pipe_rx1_valid_o_v6pcie11                    : std_logic;
   signal pipe_rx1_chanisaligned_o_v6pcie6             : std_logic;
   signal pipe_rx1_status_o_v6pcie10                   : std_logic_vector(2 downto 0);
   signal pipe_rx1_phy_status_o_v6pcie8                : std_logic;
   signal pipe_rx1_elec_idle_o_v6pcie7                 : std_logic;
   signal pipe_rx1_polarity_o_v6pcie9                  : std_logic;
   signal pipe_tx1_compliance_o_v6pcie54               : std_logic;
   signal pipe_tx1_char_is_k_o_v6pcie53                : std_logic_vector(1 downto 0);
   signal pipe_tx1_data_o_v6pcie55                     : std_logic_vector(15 downto 0);
   signal pipe_tx1_elec_idle_o_v6pcie56                : std_logic;
   signal pipe_tx1_powerdown_o_v6pcie57                : std_logic_vector(1 downto 0);
   signal pipe_rx2_valid_o_v6pcie17                    : std_logic;
   signal pipe_rx2_chanisaligned_o_v6pcie12            : std_logic;
   signal pipe_rx2_status_o_v6pcie16                   : std_logic_vector(2 downto 0);
   signal pipe_rx2_phy_status_o_v6pcie14               : std_logic;
   signal pipe_rx2_elec_idle_o_v6pcie13                : std_logic;
   signal pipe_rx2_polarity_o_v6pcie15                 : std_logic;
   signal pipe_tx2_compliance_o_v6pcie59               : std_logic;
   signal pipe_tx2_char_is_k_o_v6pcie58                : std_logic_vector(1 downto 0);
   signal pipe_tx2_data_o_v6pcie60                     : std_logic_vector(15 downto 0);
   signal pipe_tx2_elec_idle_o_v6pcie61                : std_logic;
   signal pipe_tx2_powerdown_o_v6pcie62                : std_logic_vector(1 downto 0);
   signal pipe_rx3_valid_o_v6pcie23                    : std_logic;
   signal pipe_rx3_chanisaligned_o_v6pcie18            : std_logic;
   signal pipe_rx3_status_o_v6pcie22                   : std_logic_vector(2 downto 0);
   signal pipe_rx3_phy_status_o_v6pcie20               : std_logic;
   signal pipe_rx3_elec_idle_o_v6pcie19                : std_logic;
   signal pipe_rx3_polarity_o_v6pcie21                 : std_logic;
   signal pipe_tx3_compliance_o_v6pcie64               : std_logic;
   signal pipe_tx3_char_is_k_o_v6pcie63                : std_logic_vector(1 downto 0);
   signal pipe_tx3_data_o_v6pcie65                     : std_logic_vector(15 downto 0);
   signal pipe_tx3_elec_idle_o_v6pcie66                : std_logic;
   signal pipe_tx3_powerdown_o_v6pcie67                : std_logic_vector(1 downto 0);
   signal pipe_rx4_valid_o_v6pcie29                    : std_logic;
   signal pipe_rx4_chanisaligned_o_v6pcie24            : std_logic;
   signal pipe_rx4_status_o_v6pcie28                   : std_logic_vector(2 downto 0);
   signal pipe_rx4_phy_status_o_v6pcie26               : std_logic;
   signal pipe_rx4_elec_idle_o_v6pcie25                : std_logic;
   signal pipe_rx4_polarity_o_v6pcie27                 : std_logic;
   signal pipe_tx4_compliance_o_v6pcie69               : std_logic;
   signal pipe_tx4_char_is_k_o_v6pcie68                : std_logic_vector(1 downto 0);
   signal pipe_tx4_data_o_v6pcie70                     : std_logic_vector(15 downto 0);
   signal pipe_tx4_elec_idle_o_v6pcie71                : std_logic;
   signal pipe_tx4_powerdown_o_v6pcie72                : std_logic_vector(1 downto 0);
   signal pipe_rx5_valid_o_v6pcie35                    : std_logic;
   signal pipe_rx5_chanisaligned_o_v6pcie30            : std_logic;
   signal pipe_rx5_status_o_v6pcie34                   : std_logic_vector(2 downto 0);
   signal pipe_rx5_phy_status_o_v6pcie32               : std_logic;
   signal pipe_rx5_elec_idle_o_v6pcie31                : std_logic;
   signal pipe_rx5_polarity_o_v6pcie33                 : std_logic;
   signal pipe_tx5_compliance_o_v6pcie74               : std_logic;
   signal pipe_tx5_char_is_k_o_v6pcie73                : std_logic_vector(1 downto 0);
   signal pipe_tx5_data_o_v6pcie75                     : std_logic_vector(15 downto 0);
   signal pipe_tx5_elec_idle_o_v6pcie76                : std_logic;
   signal pipe_tx5_powerdown_o_v6pcie77                : std_logic_vector(1 downto 0);
   signal pipe_rx6_valid_o_v6pcie41                    : std_logic;
   signal pipe_rx6_chanisaligned_o_v6pcie36            : std_logic;
   signal pipe_rx6_status_o_v6pcie40                   : std_logic_vector(2 downto 0);
   signal pipe_rx6_phy_status_o_v6pcie38               : std_logic;
   signal pipe_rx6_elec_idle_o_v6pcie37                : std_logic;
   signal pipe_rx6_polarity_o_v6pcie39                 : std_logic;
   signal pipe_tx6_compliance_o_v6pcie79               : std_logic;
   signal pipe_tx6_char_is_k_o_v6pcie78                : std_logic_vector(1 downto 0);
   signal pipe_tx6_data_o_v6pcie80                     : std_logic_vector(15 downto 0);
   signal pipe_tx6_elec_idle_o_v6pcie81                : std_logic;
   signal pipe_tx6_powerdown_o_v6pcie82                : std_logic_vector(1 downto 0);
   signal pipe_rx7_valid_o_v6pcie47                    : std_logic;
   signal pipe_rx7_chanisaligned_o_v6pcie42            : std_logic;
   signal pipe_rx7_status_o_v6pcie46                   : std_logic_vector(2 downto 0);
   signal pipe_rx7_phy_status_o_v6pcie44               : std_logic;
   signal pipe_rx7_elec_idle_o_v6pcie43                : std_logic;
   signal pipe_rx7_polarity_o_v6pcie45                 : std_logic;
   signal pipe_tx7_compliance_o_v6pcie84               : std_logic;
   signal pipe_tx7_char_is_k_o_v6pcie83                : std_logic_vector(1 downto 0);
   signal pipe_tx7_data_o_v6pcie85                     : std_logic_vector(15 downto 0);
   signal pipe_tx7_elec_idle_o_v6pcie86                : std_logic;
   signal pipe_tx7_powerdown_o_v6pcie87                : std_logic_vector(1 downto 0);
begin
   -- Drive referenced outputs
   pipe_tx_rcvr_det_o <= pipe_tx_rcvr_det_o_v6pcie91;
   pipe_tx_reset_o <= pipe_tx_reset_o_v6pcie92;
   pipe_tx_rate_o <= pipe_tx_rate_o_v6pcie90;
   pipe_tx_deemph_o <= pipe_tx_deemph_o_v6pcie88;
   pipe_tx_margin_o <= pipe_tx_margin_o_v6pcie89;
   pipe_tx_swing_o <= pipe_tx_swing_o_v6pcie93;
   pipe_rx0_valid_o <= pipe_rx0_valid_o_v6pcie5;
   pipe_rx0_chanisaligned_o <= pipe_rx0_chanisaligned_o_v6pcie0;
   pipe_rx0_status_o <= pipe_rx0_status_o_v6pcie4;
   pipe_rx0_phy_status_o <= pipe_rx0_phy_status_o_v6pcie2;
   pipe_rx0_elec_idle_o <= pipe_rx0_elec_idle_o_v6pcie1;
   pipe_rx0_polarity_o <= pipe_rx0_polarity_o_v6pcie3;
   pipe_tx0_compliance_o <= pipe_tx0_compliance_o_v6pcie49;
   pipe_tx0_char_is_k_o <= pipe_tx0_char_is_k_o_v6pcie48;
   pipe_tx0_data_o <= pipe_tx0_data_o_v6pcie50;
   pipe_tx0_elec_idle_o <= pipe_tx0_elec_idle_o_v6pcie51;
   pipe_tx0_powerdown_o <= pipe_tx0_powerdown_o_v6pcie52;
   pipe_rx1_valid_o <= pipe_rx1_valid_o_v6pcie11;
   pipe_rx1_chanisaligned_o <= pipe_rx1_chanisaligned_o_v6pcie6;
   pipe_rx1_status_o <= pipe_rx1_status_o_v6pcie10;
   pipe_rx1_phy_status_o <= pipe_rx1_phy_status_o_v6pcie8;
   pipe_rx1_elec_idle_o <= pipe_rx1_elec_idle_o_v6pcie7;
   pipe_rx1_polarity_o <= pipe_rx1_polarity_o_v6pcie9;
   pipe_tx1_compliance_o <= pipe_tx1_compliance_o_v6pcie54;
   pipe_tx1_char_is_k_o <= pipe_tx1_char_is_k_o_v6pcie53;
   pipe_tx1_data_o <= pipe_tx1_data_o_v6pcie55;
   pipe_tx1_elec_idle_o <= pipe_tx1_elec_idle_o_v6pcie56;
   pipe_tx1_powerdown_o <= pipe_tx1_powerdown_o_v6pcie57;
   pipe_rx2_valid_o <= pipe_rx2_valid_o_v6pcie17;
   pipe_rx2_chanisaligned_o <= pipe_rx2_chanisaligned_o_v6pcie12;
   pipe_rx2_status_o <= pipe_rx2_status_o_v6pcie16;
   pipe_rx2_phy_status_o <= pipe_rx2_phy_status_o_v6pcie14;
   pipe_rx2_elec_idle_o <= pipe_rx2_elec_idle_o_v6pcie13;
   pipe_rx2_polarity_o <= pipe_rx2_polarity_o_v6pcie15;
   pipe_tx2_compliance_o <= pipe_tx2_compliance_o_v6pcie59;
   pipe_tx2_char_is_k_o <= pipe_tx2_char_is_k_o_v6pcie58;
   pipe_tx2_data_o <= pipe_tx2_data_o_v6pcie60;
   pipe_tx2_elec_idle_o <= pipe_tx2_elec_idle_o_v6pcie61;
   pipe_tx2_powerdown_o <= pipe_tx2_powerdown_o_v6pcie62;
   pipe_rx3_valid_o <= pipe_rx3_valid_o_v6pcie23;
   pipe_rx3_chanisaligned_o <= pipe_rx3_chanisaligned_o_v6pcie18;
   pipe_rx3_status_o <= pipe_rx3_status_o_v6pcie22;
   pipe_rx3_phy_status_o <= pipe_rx3_phy_status_o_v6pcie20;
   pipe_rx3_elec_idle_o <= pipe_rx3_elec_idle_o_v6pcie19;
   pipe_rx3_polarity_o <= pipe_rx3_polarity_o_v6pcie21;
   pipe_tx3_compliance_o <= pipe_tx3_compliance_o_v6pcie64;
   pipe_tx3_char_is_k_o <= pipe_tx3_char_is_k_o_v6pcie63;
   pipe_tx3_data_o <= pipe_tx3_data_o_v6pcie65;
   pipe_tx3_elec_idle_o <= pipe_tx3_elec_idle_o_v6pcie66;
   pipe_tx3_powerdown_o <= pipe_tx3_powerdown_o_v6pcie67;
   pipe_rx4_valid_o <= pipe_rx4_valid_o_v6pcie29;
   pipe_rx4_chanisaligned_o <= pipe_rx4_chanisaligned_o_v6pcie24;
   pipe_rx4_status_o <= pipe_rx4_status_o_v6pcie28;
   pipe_rx4_phy_status_o <= pipe_rx4_phy_status_o_v6pcie26;
   pipe_rx4_elec_idle_o <= pipe_rx4_elec_idle_o_v6pcie25;
   pipe_rx4_polarity_o <= pipe_rx4_polarity_o_v6pcie27;
   pipe_tx4_compliance_o <= pipe_tx4_compliance_o_v6pcie69;
   pipe_tx4_char_is_k_o <= pipe_tx4_char_is_k_o_v6pcie68;
   pipe_tx4_data_o <= pipe_tx4_data_o_v6pcie70;
   pipe_tx4_elec_idle_o <= pipe_tx4_elec_idle_o_v6pcie71;
   pipe_tx4_powerdown_o <= pipe_tx4_powerdown_o_v6pcie72;
   pipe_rx5_valid_o <= pipe_rx5_valid_o_v6pcie35;
   pipe_rx5_chanisaligned_o <= pipe_rx5_chanisaligned_o_v6pcie30;
   pipe_rx5_status_o <= pipe_rx5_status_o_v6pcie34;
   pipe_rx5_phy_status_o <= pipe_rx5_phy_status_o_v6pcie32;
   pipe_rx5_elec_idle_o <= pipe_rx5_elec_idle_o_v6pcie31;
   pipe_rx5_polarity_o <= pipe_rx5_polarity_o_v6pcie33;
   pipe_tx5_compliance_o <= pipe_tx5_compliance_o_v6pcie74;
   pipe_tx5_char_is_k_o <= pipe_tx5_char_is_k_o_v6pcie73;
   pipe_tx5_data_o <= pipe_tx5_data_o_v6pcie75;
   pipe_tx5_elec_idle_o <= pipe_tx5_elec_idle_o_v6pcie76;
   pipe_tx5_powerdown_o <= pipe_tx5_powerdown_o_v6pcie77;
   pipe_rx6_valid_o <= pipe_rx6_valid_o_v6pcie41;
   pipe_rx6_chanisaligned_o <= pipe_rx6_chanisaligned_o_v6pcie36;
   pipe_rx6_status_o <= pipe_rx6_status_o_v6pcie40;
   pipe_rx6_phy_status_o <= pipe_rx6_phy_status_o_v6pcie38;
   pipe_rx6_elec_idle_o <= pipe_rx6_elec_idle_o_v6pcie37;
   pipe_rx6_polarity_o <= pipe_rx6_polarity_o_v6pcie39;
   pipe_tx6_compliance_o <= pipe_tx6_compliance_o_v6pcie79;
   pipe_tx6_char_is_k_o <= pipe_tx6_char_is_k_o_v6pcie78;
   pipe_tx6_data_o <= pipe_tx6_data_o_v6pcie80;
   pipe_tx6_elec_idle_o <= pipe_tx6_elec_idle_o_v6pcie81;
   pipe_tx6_powerdown_o <= pipe_tx6_powerdown_o_v6pcie82;
   pipe_rx7_valid_o <= pipe_rx7_valid_o_v6pcie47;
   pipe_rx7_chanisaligned_o <= pipe_rx7_chanisaligned_o_v6pcie42;
   pipe_rx7_status_o <= pipe_rx7_status_o_v6pcie46;
   pipe_rx7_phy_status_o <= pipe_rx7_phy_status_o_v6pcie44;
   pipe_rx7_elec_idle_o <= pipe_rx7_elec_idle_o_v6pcie43;
   pipe_rx7_polarity_o <= pipe_rx7_polarity_o_v6pcie45;
   pipe_tx7_compliance_o <= pipe_tx7_compliance_o_v6pcie84;
   pipe_tx7_char_is_k_o <= pipe_tx7_char_is_k_o_v6pcie83;
   pipe_tx7_data_o <= pipe_tx7_data_o_v6pcie85;
   pipe_tx7_elec_idle_o <= pipe_tx7_elec_idle_o_v6pcie86;
   pipe_tx7_powerdown_o <= pipe_tx7_powerdown_o_v6pcie87;
   
   --synthesis translate_off
   --   initial begin
   --      $display("[%t] %m NO_OF_LANES %0d  PIPE_PIPELINE_STAGES %0d", $time, NO_OF_LANES, PIPE_PIPELINE_STAGES);
   --   end
   --synthesis translate_on
   
   pipe_misc_i : pcie_pipe_misc_v6
      generic map (
         PIPE_PIPELINE_STAGES  => PIPE_PIPELINE_STAGES
      )
      port map (
         
         pipe_tx_rcvr_det_i  => pipe_tx_rcvr_det_i,
         pipe_tx_reset_i     => pipe_tx_reset_i,
         pipe_tx_rate_i      => pipe_tx_rate_i,
         pipe_tx_deemph_i    => pipe_tx_deemph_i,
         pipe_tx_margin_i    => pipe_tx_margin_i,
         pipe_tx_swing_i     => pipe_tx_swing_i,
         
         pipe_tx_rcvr_det_o  => pipe_tx_rcvr_det_o_v6pcie91,
         pipe_tx_reset_o     => pipe_tx_reset_o_v6pcie92,
         pipe_tx_rate_o      => pipe_tx_rate_o_v6pcie90,
         pipe_tx_deemph_o    => pipe_tx_deemph_o_v6pcie88,
         pipe_tx_margin_o    => pipe_tx_margin_o_v6pcie89,
         pipe_tx_swing_o     => pipe_tx_swing_o_v6pcie93,
         
         pipe_clk            => pipe_clk,
         rst_n               => rst_n
      );
   
   pipe_lane_0_i : pcie_pipe_lane_v6
      generic map (
         PIPE_PIPELINE_STAGES  => PIPE_PIPELINE_STAGES
      )
      port map (
         
         pipe_rx_char_is_k_o      => pipe_rx0_char_is_k_q,
         pipe_rx_data_o           => pipe_rx0_data_q,
         pipe_rx_valid_o          => pipe_rx0_valid_o_v6pcie5,
         pipe_rx_chanisaligned_o  => pipe_rx0_chanisaligned_o_v6pcie0,
         pipe_rx_status_o         => pipe_rx0_status_o_v6pcie4,
         pipe_rx_phy_status_o     => pipe_rx0_phy_status_o_v6pcie2,
         pipe_rx_elec_idle_o      => pipe_rx0_elec_idle_o_v6pcie1,
         pipe_rx_polarity_i       => pipe_rx0_polarity_i,
         pipe_tx_compliance_i     => pipe_tx0_compliance_i,
         pipe_tx_char_is_k_i      => pipe_tx0_char_is_k_i,
         pipe_tx_data_i           => pipe_tx0_data_i,
         pipe_tx_elec_idle_i      => pipe_tx0_elec_idle_i,
         pipe_tx_powerdown_i      => pipe_tx0_powerdown_i,
         
         pipe_rx_char_is_k_i      => pipe_rx0_char_is_k_i,
         pipe_rx_data_i           => pipe_rx0_data_i,
         pipe_rx_valid_i          => pipe_rx0_valid_i,
         pipe_rx_chanisaligned_i  => pipe_rx0_chanisaligned_i,
         pipe_rx_status_i         => pipe_rx0_status_i,
         pipe_rx_phy_status_i     => pipe_rx0_phy_status_i,
         pipe_rx_elec_idle_i      => pipe_rx0_elec_idle_i,
         pipe_rx_polarity_o       => pipe_rx0_polarity_o_v6pcie3,
         pipe_tx_compliance_o     => pipe_tx0_compliance_o_v6pcie49,
         pipe_tx_char_is_k_o      => pipe_tx0_char_is_k_o_v6pcie48,
         pipe_tx_data_o           => pipe_tx0_data_o_v6pcie50,
         pipe_tx_elec_idle_o      => pipe_tx0_elec_idle_o_v6pcie51,
         pipe_tx_powerdown_o      => pipe_tx0_powerdown_o_v6pcie52,
         
         pipe_clk                 => pipe_clk,
         rst_n                    => rst_n
      );
   
   v6pcie94 : if (NO_OF_LANES >= 2) generate
      
      pipe_lane_1_i : pcie_pipe_lane_v6
         generic map (
            PIPE_PIPELINE_STAGES  => PIPE_PIPELINE_STAGES
         )
         port map (
            
            pipe_rx_char_is_k_o      => pipe_rx1_char_is_k_q,
            pipe_rx_data_o           => pipe_rx1_data_q,
            pipe_rx_valid_o          => pipe_rx1_valid_o_v6pcie11,
            pipe_rx_chanisaligned_o  => pipe_rx1_chanisaligned_o_v6pcie6,
            pipe_rx_status_o         => pipe_rx1_status_o_v6pcie10,
            pipe_rx_phy_status_o     => pipe_rx1_phy_status_o_v6pcie8,
            pipe_rx_elec_idle_o      => pipe_rx1_elec_idle_o_v6pcie7,
            pipe_rx_polarity_i       => pipe_rx1_polarity_i,
            pipe_tx_compliance_i     => pipe_tx1_compliance_i,
            pipe_tx_char_is_k_i      => pipe_tx1_char_is_k_i,
            pipe_tx_data_i           => pipe_tx1_data_i,
            pipe_tx_elec_idle_i      => pipe_tx1_elec_idle_i,
            pipe_tx_powerdown_i      => pipe_tx1_powerdown_i,
            
            pipe_rx_char_is_k_i      => pipe_rx1_char_is_k_i,
            pipe_rx_data_i           => pipe_rx1_data_i,
            pipe_rx_valid_i          => pipe_rx1_valid_i,
            pipe_rx_chanisaligned_i  => pipe_rx1_chanisaligned_i,
            pipe_rx_status_i         => pipe_rx1_status_i,
            pipe_rx_phy_status_i     => pipe_rx1_phy_status_i,
            pipe_rx_elec_idle_i      => pipe_rx1_elec_idle_i,
            pipe_rx_polarity_o       => pipe_rx1_polarity_o_v6pcie9,
            pipe_tx_compliance_o     => pipe_tx1_compliance_o_v6pcie54,
            pipe_tx_char_is_k_o      => pipe_tx1_char_is_k_o_v6pcie53,
            pipe_tx_data_o           => pipe_tx1_data_o_v6pcie55,
            pipe_tx_elec_idle_o      => pipe_tx1_elec_idle_o_v6pcie56,
            pipe_tx_powerdown_o      => pipe_tx1_powerdown_o_v6pcie57,
            
            pipe_clk                 => pipe_clk,
            rst_n                    => rst_n
         );
      
   end generate;
   v6pcie95 : if (not(NO_OF_LANES >= 2)) generate
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      pipe_rx1_char_is_k_q <= "00";
      pipe_rx1_data_q <= "0000000000000000";
      pipe_rx1_valid_o_v6pcie11 <= '0';
      pipe_rx1_chanisaligned_o_v6pcie6 <= '0';
      pipe_rx1_status_o_v6pcie10 <= "000";
      pipe_rx1_phy_status_o_v6pcie8 <= '0';
      pipe_rx1_elec_idle_o_v6pcie7 <= '1';
      pipe_rx1_polarity_o_v6pcie9 <= '0';
      pipe_tx1_compliance_o_v6pcie54 <= '0';
      pipe_tx1_char_is_k_o_v6pcie53 <= "00";
      pipe_tx1_data_o_v6pcie55 <= "0000000000000000";
      pipe_tx1_elec_idle_o_v6pcie56 <= '1';
      pipe_tx1_powerdown_o_v6pcie57 <= "00";
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      
   end generate;
   v6pcie96 : if (NO_OF_LANES >= 4) generate
      pipe_lane_2_i : pcie_pipe_lane_v6
         generic map (
            PIPE_PIPELINE_STAGES  => PIPE_PIPELINE_STAGES
         )
         port map (
            
            pipe_rx_char_is_k_o      => pipe_rx2_char_is_k_q,
            pipe_rx_data_o           => pipe_rx2_data_q,
            pipe_rx_valid_o          => pipe_rx2_valid_o_v6pcie17,
            pipe_rx_chanisaligned_o  => pipe_rx2_chanisaligned_o_v6pcie12,
            pipe_rx_status_o         => pipe_rx2_status_o_v6pcie16,
            pipe_rx_phy_status_o     => pipe_rx2_phy_status_o_v6pcie14,
            pipe_rx_elec_idle_o      => pipe_rx2_elec_idle_o_v6pcie13,
            pipe_rx_polarity_i       => pipe_rx2_polarity_i,
            pipe_tx_compliance_i     => pipe_tx2_compliance_i,
            pipe_tx_char_is_k_i      => pipe_tx2_char_is_k_i,
            pipe_tx_data_i           => pipe_tx2_data_i,
            pipe_tx_elec_idle_i      => pipe_tx2_elec_idle_i,
            pipe_tx_powerdown_i      => pipe_tx2_powerdown_i,
            
            pipe_rx_char_is_k_i      => pipe_rx2_char_is_k_i,
            pipe_rx_data_i           => pipe_rx2_data_i,
            pipe_rx_valid_i          => pipe_rx2_valid_i,
            pipe_rx_chanisaligned_i  => pipe_rx2_chanisaligned_i,
            pipe_rx_status_i         => pipe_rx2_status_i,
            pipe_rx_phy_status_i     => pipe_rx2_phy_status_i,
            pipe_rx_elec_idle_i      => pipe_rx2_elec_idle_i,
            pipe_rx_polarity_o       => pipe_rx2_polarity_o_v6pcie15,
            pipe_tx_compliance_o     => pipe_tx2_compliance_o_v6pcie59,
            pipe_tx_char_is_k_o      => pipe_tx2_char_is_k_o_v6pcie58,
            pipe_tx_data_o           => pipe_tx2_data_o_v6pcie60,
            pipe_tx_elec_idle_o      => pipe_tx2_elec_idle_o_v6pcie61,
            pipe_tx_powerdown_o      => pipe_tx2_powerdown_o_v6pcie62,
            
            pipe_clk                 => pipe_clk,
            rst_n                    => rst_n
         );

      pipe_lane_3_i : pcie_pipe_lane_v6
         generic map (
            PIPE_PIPELINE_STAGES  => PIPE_PIPELINE_STAGES
         )
         port map (
            
            pipe_rx_char_is_k_o      => pipe_rx3_char_is_k_q,
            pipe_rx_data_o           => pipe_rx3_data_q,
            pipe_rx_valid_o          => pipe_rx3_valid_o_v6pcie23,
            pipe_rx_chanisaligned_o  => pipe_rx3_chanisaligned_o_v6pcie18,
            pipe_rx_status_o         => pipe_rx3_status_o_v6pcie22,
            pipe_rx_phy_status_o     => pipe_rx3_phy_status_o_v6pcie20,
            pipe_rx_elec_idle_o      => pipe_rx3_elec_idle_o_v6pcie19,
            pipe_rx_polarity_i       => pipe_rx3_polarity_i,
            pipe_tx_compliance_i     => pipe_tx3_compliance_i,
            pipe_tx_char_is_k_i      => pipe_tx3_char_is_k_i,
            pipe_tx_data_i           => pipe_tx3_data_i,
            pipe_tx_elec_idle_i      => pipe_tx3_elec_idle_i,
            pipe_tx_powerdown_i      => pipe_tx3_powerdown_i,
            
            pipe_rx_char_is_k_i      => pipe_rx3_char_is_k_i,
            pipe_rx_data_i           => pipe_rx3_data_i,
            pipe_rx_valid_i          => pipe_rx3_valid_i,
            pipe_rx_chanisaligned_i  => pipe_rx3_chanisaligned_i,
            pipe_rx_status_i         => pipe_rx3_status_i,
            pipe_rx_phy_status_i     => pipe_rx3_phy_status_i,
            pipe_rx_elec_idle_i      => pipe_rx3_elec_idle_i,
            pipe_rx_polarity_o       => pipe_rx3_polarity_o_v6pcie21,
            pipe_tx_compliance_o     => pipe_tx3_compliance_o_v6pcie64,
            pipe_tx_char_is_k_o      => pipe_tx3_char_is_k_o_v6pcie63,
            pipe_tx_data_o           => pipe_tx3_data_o_v6pcie65,
            pipe_tx_elec_idle_o      => pipe_tx3_elec_idle_o_v6pcie66,
            pipe_tx_powerdown_o      => pipe_tx3_powerdown_o_v6pcie67,
            
            pipe_clk                 => pipe_clk,
            rst_n                    => rst_n
         );
      
   end generate;
   v6pcie97 : if (not(NO_OF_LANES >= 4)) generate
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      pipe_rx2_char_is_k_q <= "00";
      pipe_rx2_data_q <= "0000000000000000";
      pipe_rx2_valid_o_v6pcie17 <= '0';
      pipe_rx2_chanisaligned_o_v6pcie12 <= '0';
      pipe_rx2_status_o_v6pcie16 <= "000";
      pipe_rx2_phy_status_o_v6pcie14 <= '0';
      pipe_rx2_elec_idle_o_v6pcie13 <= '1';
      pipe_rx2_polarity_o_v6pcie15 <= '0';
      pipe_tx2_compliance_o_v6pcie59 <= '0';
      pipe_tx2_char_is_k_o_v6pcie58 <= "00";
      pipe_tx2_data_o_v6pcie60 <= "0000000000000000";
      pipe_tx2_elec_idle_o_v6pcie61 <= '1';
      pipe_tx2_powerdown_o_v6pcie62 <= "00";
      
      pipe_rx3_char_is_k_q <= "00";
      pipe_rx3_data_q <= "0000000000000000";
      pipe_rx3_valid_o_v6pcie23 <= '0';
      pipe_rx3_chanisaligned_o_v6pcie18 <= '0';
      pipe_rx3_status_o_v6pcie22 <= "000";
      pipe_rx3_phy_status_o_v6pcie20 <= '0';
      pipe_rx3_elec_idle_o_v6pcie19 <= '1';
      pipe_rx3_polarity_o_v6pcie21 <= '0';
      pipe_tx3_compliance_o_v6pcie64 <= '0';
      pipe_tx3_char_is_k_o_v6pcie63 <= "00";
      pipe_tx3_data_o_v6pcie65 <= "0000000000000000";
      pipe_tx3_elec_idle_o_v6pcie66 <= '1';
      pipe_tx3_powerdown_o_v6pcie67 <= "00";
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      
   end generate;
   v6pcie98 : if (NO_OF_LANES >= 8) generate
      
      pipe_lane_4_i : pcie_pipe_lane_v6
         generic map (
            PIPE_PIPELINE_STAGES  => PIPE_PIPELINE_STAGES
         )
         port map (
            
            pipe_rx_char_is_k_o      => pipe_rx4_char_is_k_q,
            pipe_rx_data_o           => pipe_rx4_data_q,
            pipe_rx_valid_o          => pipe_rx4_valid_o_v6pcie29,
            pipe_rx_chanisaligned_o  => pipe_rx4_chanisaligned_o_v6pcie24,
            pipe_rx_status_o         => pipe_rx4_status_o_v6pcie28,
            pipe_rx_phy_status_o     => pipe_rx4_phy_status_o_v6pcie26,
            pipe_rx_elec_idle_o      => pipe_rx4_elec_idle_o_v6pcie25,
            pipe_rx_polarity_i       => pipe_rx4_polarity_i,
            pipe_tx_compliance_i     => pipe_tx4_compliance_i,
            pipe_tx_char_is_k_i      => pipe_tx4_char_is_k_i,
            pipe_tx_data_i           => pipe_tx4_data_i,
            pipe_tx_elec_idle_i      => pipe_tx4_elec_idle_i,
            pipe_tx_powerdown_i      => pipe_tx4_powerdown_i,
            
            pipe_rx_char_is_k_i      => pipe_rx4_char_is_k_i,
            pipe_rx_data_i           => pipe_rx4_data_i,
            pipe_rx_valid_i          => pipe_rx4_valid_i,
            pipe_rx_chanisaligned_i  => pipe_rx4_chanisaligned_i,
            pipe_rx_status_i         => pipe_rx4_status_i,
            pipe_rx_phy_status_i     => pipe_rx4_phy_status_i,
            pipe_rx_elec_idle_i      => pipe_rx4_elec_idle_i,
            pipe_rx_polarity_o       => pipe_rx4_polarity_o_v6pcie27,
            pipe_tx_compliance_o     => pipe_tx4_compliance_o_v6pcie69,
            pipe_tx_char_is_k_o      => pipe_tx4_char_is_k_o_v6pcie68,
            pipe_tx_data_o           => pipe_tx4_data_o_v6pcie70,
            pipe_tx_elec_idle_o      => pipe_tx4_elec_idle_o_v6pcie71,
            pipe_tx_powerdown_o      => pipe_tx4_powerdown_o_v6pcie72,
            
            pipe_clk                 => pipe_clk,
            rst_n                    => rst_n
         );
      
      pipe_lane_5_i : pcie_pipe_lane_v6
         generic map (
            PIPE_PIPELINE_STAGES  => PIPE_PIPELINE_STAGES
         )
         port map (
            
            pipe_rx_char_is_k_o      => pipe_rx5_char_is_k_q,
            pipe_rx_data_o           => pipe_rx5_data_q,
            pipe_rx_valid_o          => pipe_rx5_valid_o_v6pcie35,
            pipe_rx_chanisaligned_o  => pipe_rx5_chanisaligned_o_v6pcie30,
            pipe_rx_status_o         => pipe_rx5_status_o_v6pcie34,
            pipe_rx_phy_status_o     => pipe_rx5_phy_status_o_v6pcie32,
            pipe_rx_elec_idle_o      => pipe_rx5_elec_idle_o_v6pcie31,
            pipe_rx_polarity_i       => pipe_rx5_polarity_i,
            pipe_tx_compliance_i     => pipe_tx5_compliance_i,
            pipe_tx_char_is_k_i      => pipe_tx5_char_is_k_i,
            pipe_tx_data_i           => pipe_tx5_data_i,
            pipe_tx_elec_idle_i      => pipe_tx5_elec_idle_i,
            pipe_tx_powerdown_i      => pipe_tx5_powerdown_i,
            
            pipe_rx_char_is_k_i      => pipe_rx5_char_is_k_i,
            pipe_rx_data_i           => pipe_rx5_data_i,
            pipe_rx_valid_i          => pipe_rx5_valid_i,
            pipe_rx_chanisaligned_i  => pipe_rx5_chanisaligned_i,
            pipe_rx_status_i         => pipe_rx5_status_i,
            pipe_rx_phy_status_i     => pipe_rx4_phy_status_i,
            pipe_rx_elec_idle_i      => pipe_rx4_elec_idle_i,
            pipe_rx_polarity_o       => pipe_rx5_polarity_o_v6pcie33,
            pipe_tx_compliance_o     => pipe_tx5_compliance_o_v6pcie74,
            pipe_tx_char_is_k_o      => pipe_tx5_char_is_k_o_v6pcie73,
            pipe_tx_data_o           => pipe_tx5_data_o_v6pcie75,
            pipe_tx_elec_idle_o      => pipe_tx5_elec_idle_o_v6pcie76,
            pipe_tx_powerdown_o      => pipe_tx5_powerdown_o_v6pcie77,
            
            pipe_clk                 => pipe_clk,
            rst_n                    => rst_n
         );
      
      pipe_lane_6_i : pcie_pipe_lane_v6
         generic map (
            PIPE_PIPELINE_STAGES  => PIPE_PIPELINE_STAGES
         )
         port map (
            
            pipe_rx_char_is_k_o      => pipe_rx6_char_is_k_q,
            pipe_rx_data_o           => pipe_rx6_data_q,
            pipe_rx_valid_o          => pipe_rx6_valid_o_v6pcie41,
            pipe_rx_chanisaligned_o  => pipe_rx6_chanisaligned_o_v6pcie36,
            pipe_rx_status_o         => pipe_rx6_status_o_v6pcie40,
            pipe_rx_phy_status_o     => pipe_rx6_phy_status_o_v6pcie38,
            pipe_rx_elec_idle_o      => pipe_rx6_elec_idle_o_v6pcie37,
            pipe_rx_polarity_i       => pipe_rx6_polarity_i,
            pipe_tx_compliance_i     => pipe_tx6_compliance_i,
            pipe_tx_char_is_k_i      => pipe_tx6_char_is_k_i,
            pipe_tx_data_i           => pipe_tx6_data_i,
            pipe_tx_elec_idle_i      => pipe_tx6_elec_idle_i,
            pipe_tx_powerdown_i      => pipe_tx6_powerdown_i,
            
            pipe_rx_char_is_k_i      => pipe_rx6_char_is_k_i,
            pipe_rx_data_i           => pipe_rx6_data_i,
            pipe_rx_valid_i          => pipe_rx6_valid_i,
            pipe_rx_chanisaligned_i  => pipe_rx6_chanisaligned_i,
            pipe_rx_status_i         => pipe_rx6_status_i,
            pipe_rx_phy_status_i     => pipe_rx4_phy_status_i,
            pipe_rx_elec_idle_i      => pipe_rx6_elec_idle_i,
            pipe_rx_polarity_o       => pipe_rx6_polarity_o_v6pcie39,
            pipe_tx_compliance_o     => pipe_tx6_compliance_o_v6pcie79,
            pipe_tx_char_is_k_o      => pipe_tx6_char_is_k_o_v6pcie78,
            pipe_tx_data_o           => pipe_tx6_data_o_v6pcie80,
            pipe_tx_elec_idle_o      => pipe_tx6_elec_idle_o_v6pcie81,
            pipe_tx_powerdown_o      => pipe_tx6_powerdown_o_v6pcie82,
            
            pipe_clk                 => pipe_clk,
            rst_n                    => rst_n
         );
      
      pipe_lane_7_i : pcie_pipe_lane_v6
         generic map (
            PIPE_PIPELINE_STAGES  => PIPE_PIPELINE_STAGES
         )
         port map (
            
            pipe_rx_char_is_k_o      => pipe_rx7_char_is_k_q,
            pipe_rx_data_o           => pipe_rx7_data_q,
            pipe_rx_valid_o          => pipe_rx7_valid_o_v6pcie47,
            pipe_rx_chanisaligned_o  => pipe_rx7_chanisaligned_o_v6pcie42,
            pipe_rx_status_o         => pipe_rx7_status_o_v6pcie46,
            pipe_rx_phy_status_o     => pipe_rx7_phy_status_o_v6pcie44,
            pipe_rx_elec_idle_o      => pipe_rx7_elec_idle_o_v6pcie43,
            pipe_rx_polarity_i       => pipe_rx7_polarity_i,
            pipe_tx_compliance_i     => pipe_tx7_compliance_i,
            pipe_tx_char_is_k_i      => pipe_tx7_char_is_k_i,
            pipe_tx_data_i           => pipe_tx7_data_i,
            pipe_tx_elec_idle_i      => pipe_tx7_elec_idle_i,
            pipe_tx_powerdown_i      => pipe_tx7_powerdown_i,
            
            pipe_rx_char_is_k_i      => pipe_rx7_char_is_k_i,
            pipe_rx_data_i           => pipe_rx7_data_i,
            pipe_rx_valid_i          => pipe_rx7_valid_i,
            pipe_rx_chanisaligned_i  => pipe_rx7_chanisaligned_i,
            pipe_rx_status_i         => pipe_rx7_status_i,
            pipe_rx_phy_status_i     => pipe_rx4_phy_status_i,
            pipe_rx_elec_idle_i      => pipe_rx7_elec_idle_i,
            pipe_rx_polarity_o       => pipe_rx7_polarity_o_v6pcie45,
            pipe_tx_compliance_o     => pipe_tx7_compliance_o_v6pcie84,
            pipe_tx_char_is_k_o      => pipe_tx7_char_is_k_o_v6pcie83,
            pipe_tx_data_o           => pipe_tx7_data_o_v6pcie85,
            pipe_tx_elec_idle_o      => pipe_tx7_elec_idle_o_v6pcie86,
            pipe_tx_powerdown_o      => pipe_tx7_powerdown_o_v6pcie87,
            
            pipe_clk                 => pipe_clk,
            rst_n                    => rst_n
         );
      
   end generate;
   v6pcie99 : if (not(NO_OF_LANES >= 8)) generate
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      pipe_rx4_char_is_k_q <= "00";
      pipe_rx4_data_q <= "0000000000000000";
      pipe_rx4_valid_o_v6pcie29 <= '0';
      pipe_rx4_chanisaligned_o_v6pcie24 <= '0';
      pipe_rx4_status_o_v6pcie28 <= "000";
      pipe_rx4_phy_status_o_v6pcie26 <= '0';
      pipe_rx4_elec_idle_o_v6pcie25 <= '1';
      pipe_rx4_polarity_o_v6pcie27 <= '0';
      pipe_tx4_compliance_o_v6pcie69 <= '0';
      pipe_tx4_char_is_k_o_v6pcie68 <= "00";
      pipe_tx4_data_o_v6pcie70 <= "0000000000000000";
      pipe_tx4_elec_idle_o_v6pcie71 <= '1';
      pipe_tx4_powerdown_o_v6pcie72 <= "00";
      
      pipe_rx5_char_is_k_q <= "00";
      pipe_rx5_data_q <= "0000000000000000";
      pipe_rx5_valid_o_v6pcie35 <= '0';
      pipe_rx5_chanisaligned_o_v6pcie30 <= '0';
      pipe_rx5_status_o_v6pcie34 <= "000";
      pipe_rx5_phy_status_o_v6pcie32 <= '0';
      pipe_rx5_elec_idle_o_v6pcie31 <= '1';
      pipe_rx5_polarity_o_v6pcie33 <= '0';
      pipe_tx5_compliance_o_v6pcie74 <= '0';
      pipe_tx5_char_is_k_o_v6pcie73 <= "00";
      pipe_tx5_data_o_v6pcie75 <= "0000000000000000";
      pipe_tx5_elec_idle_o_v6pcie76 <= '1';
      pipe_tx5_powerdown_o_v6pcie77 <= "00";
      
      pipe_rx6_char_is_k_q <= "00";
      pipe_rx6_data_q <= "0000000000000000";
      pipe_rx6_valid_o_v6pcie41 <= '0';
      pipe_rx6_chanisaligned_o_v6pcie36 <= '0';
      pipe_rx6_status_o_v6pcie40 <= "000";
      pipe_rx6_phy_status_o_v6pcie38 <= '0';
      pipe_rx6_elec_idle_o_v6pcie37 <= '1';
      pipe_rx6_polarity_o_v6pcie39 <= '0';
      pipe_tx6_compliance_o_v6pcie79 <= '0';
      pipe_tx6_char_is_k_o_v6pcie78 <= "00";
      pipe_tx6_data_o_v6pcie80 <= "0000000000000000";
      pipe_tx6_elec_idle_o_v6pcie81 <= '1';
      pipe_tx6_powerdown_o_v6pcie82 <= "00";
      
      pipe_rx7_char_is_k_q <= "00";
      pipe_rx7_data_q <= "0000000000000000";
      pipe_rx7_valid_o_v6pcie47 <= '0';
      pipe_rx7_chanisaligned_o_v6pcie42 <= '0';
      pipe_rx7_status_o_v6pcie46 <= "000";
      pipe_rx7_phy_status_o_v6pcie44 <= '0';
      pipe_rx7_elec_idle_o_v6pcie43 <= '1';
      pipe_rx7_polarity_o_v6pcie45 <= '0';
      pipe_tx7_compliance_o_v6pcie84 <= '0';
      pipe_tx7_char_is_k_o_v6pcie83 <= "00";
      pipe_tx7_data_o_v6pcie85 <= "0000000000000000";
      pipe_tx7_elec_idle_o_v6pcie86 <= '1';
      pipe_tx7_powerdown_o_v6pcie87 <= "00";
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      
   end generate;
   
   --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   
   --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   
   pipe_rx0_char_is_k_o <= pipe_rx0_char_is_k_q;
   pipe_rx0_data_o <= pipe_rx0_data_q;
   pipe_rx1_char_is_k_o <= pipe_rx1_char_is_k_q;
   pipe_rx1_data_o <= pipe_rx1_data_q;
   pipe_rx2_char_is_k_o <= pipe_rx2_char_is_k_q;
   pipe_rx2_data_o <= pipe_rx2_data_q;
   pipe_rx3_char_is_k_o <= pipe_rx3_char_is_k_q;
   pipe_rx3_data_o <= pipe_rx3_data_q;
   pipe_rx4_char_is_k_o <= pipe_rx4_char_is_k_q;
   pipe_rx4_data_o <= pipe_rx4_data_q;
   pipe_rx5_char_is_k_o <= pipe_rx5_char_is_k_q;
   pipe_rx5_data_o <= pipe_rx5_data_q;
   pipe_rx6_char_is_k_o <= pipe_rx6_char_is_k_q;
   pipe_rx6_data_o <= pipe_rx6_data_q;
   pipe_rx7_char_is_k_o <= pipe_rx7_char_is_k_q;
   pipe_rx7_data_o <= pipe_rx7_data_q;
   
end v6_pcie;
