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
-- File       : cl_a7pcie_x4_pcie_pipe_pipeline.vhd
-- Version    : 1.11
-- Description: PIPE module for 7-Series PCIe Block
--
--
--
--------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;

entity cl_a7pcie_x4_pcie_pipe_pipeline is
  generic (
    LINK_CAP_MAX_LINK_WIDTH_int                  : integer := 8;
    PIPE_PIPELINE_STAGES                         : integer := 0  -- 0 - 0 stages, 1 - 1 stage, 2 - 2 stages
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
end cl_a7pcie_x4_pcie_pipe_pipeline;

architecture rtl of cl_a7pcie_x4_pcie_pipe_pipeline is
   component cl_a7pcie_x4_pcie_pipe_lane is
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

   component cl_a7pcie_x4_pcie_pipe_misc is
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

   constant Tc2o                                      : integer := 1;  -- clock to out delay model

begin
   --synthesis translate_off
   --   initial begin
   --      $display("[%t] %m LINK_CAP_MAX_LINK_WIDTH_int %0d  PIPE_PIPELINE_STAGES %0d", $time, LINK_CAP_MAX_LINK_WIDTH_int,
   --      PIPE_PIPELINE_STAGES);
   --   end
   --synthesis translate_on

  pipe_misc_i : cl_a7pcie_x4_pcie_pipe_misc
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

      pipe_tx_rcvr_det_o  => pipe_tx_rcvr_det_o,
      pipe_tx_reset_o     => pipe_tx_reset_o,
      pipe_tx_rate_o      => pipe_tx_rate_o,
      pipe_tx_deemph_o    => pipe_tx_deemph_o,
      pipe_tx_margin_o    => pipe_tx_margin_o,
      pipe_tx_swing_o     => pipe_tx_swing_o,

      pipe_clk            => pipe_clk,
      rst_n               => rst_n
    );

  pipe_lane_0_i : cl_a7pcie_x4_pcie_pipe_lane
    generic map (
      PIPE_PIPELINE_STAGES => PIPE_PIPELINE_STAGES)
    port map (
      pipe_rx_char_is_k_o     => pipe_rx0_char_is_k_o,
      pipe_rx_data_o          => pipe_rx0_data_o,
      pipe_rx_valid_o         => pipe_rx0_valid_o,
      pipe_rx_chanisaligned_o => pipe_rx0_chanisaligned_o,
      pipe_rx_status_o        => pipe_rx0_status_o,
      pipe_rx_phy_status_o    => pipe_rx0_phy_status_o,
      pipe_rx_elec_idle_o     => pipe_rx0_elec_idle_o,
      pipe_rx_polarity_i      => pipe_rx0_polarity_i,
      pipe_tx_compliance_i    => pipe_tx0_compliance_i,
      pipe_tx_char_is_k_i     => pipe_tx0_char_is_k_i,
      pipe_tx_data_i          => pipe_tx0_data_i,
      pipe_tx_elec_idle_i     => pipe_tx0_elec_idle_i,
      pipe_tx_powerdown_i     => pipe_tx0_powerdown_i,
      pipe_rx_char_is_k_i     => pipe_rx0_char_is_k_i,
      pipe_rx_data_i          => pipe_rx0_data_i,
      pipe_rx_valid_i         => pipe_rx0_valid_i,
      pipe_rx_chanisaligned_i => pipe_rx0_chanisaligned_i,
      pipe_rx_status_i        => pipe_rx0_status_i,
      pipe_rx_phy_status_i    => pipe_rx0_phy_status_i,
      pipe_rx_elec_idle_i     => pipe_rx0_elec_idle_i,
      pipe_rx_polarity_o      => pipe_rx0_polarity_o,
      pipe_tx_compliance_o    => pipe_tx0_compliance_o,
      pipe_tx_char_is_k_o     => pipe_tx0_char_is_k_o,
      pipe_tx_data_o          => pipe_tx0_data_o,
      pipe_tx_elec_idle_o     => pipe_tx0_elec_idle_o,
      pipe_tx_powerdown_o     => pipe_tx0_powerdown_o,
      pipe_clk                => pipe_clk,
      rst_n                   => rst_n);

  pipe_lane_2 : if (LINK_CAP_MAX_LINK_WIDTH_int >= 2) generate

    pipe_lane_1_i : cl_a7pcie_x4_pcie_pipe_lane
      generic map (
        PIPE_PIPELINE_STAGES => PIPE_PIPELINE_STAGES)
      port map (
        pipe_rx_char_is_k_o     => pipe_rx1_char_is_k_o,
        pipe_rx_data_o          => pipe_rx1_data_o,
        pipe_rx_valid_o         => pipe_rx1_valid_o,
        pipe_rx_chanisaligned_o => pipe_rx1_chanisaligned_o,
        pipe_rx_status_o        => pipe_rx1_status_o,
        pipe_rx_phy_status_o    => pipe_rx1_phy_status_o,
        pipe_rx_elec_idle_o     => pipe_rx1_elec_idle_o,
        pipe_rx_polarity_i      => pipe_rx1_polarity_i,
        pipe_tx_compliance_i    => pipe_tx1_compliance_i,
        pipe_tx_char_is_k_i     => pipe_tx1_char_is_k_i,
        pipe_tx_data_i          => pipe_tx1_data_i,
        pipe_tx_elec_idle_i     => pipe_tx1_elec_idle_i,
        pipe_tx_powerdown_i     => pipe_tx1_powerdown_i,
        pipe_rx_char_is_k_i     => pipe_rx1_char_is_k_i,
        pipe_rx_data_i          => pipe_rx1_data_i,
        pipe_rx_valid_i         => pipe_rx1_valid_i,
        pipe_rx_chanisaligned_i => pipe_rx1_chanisaligned_i,
        pipe_rx_status_i        => pipe_rx1_status_i,
        pipe_rx_phy_status_i    => pipe_rx1_phy_status_i,
        pipe_rx_elec_idle_i     => pipe_rx1_elec_idle_i,
        pipe_rx_polarity_o      => pipe_rx1_polarity_o,
        pipe_tx_compliance_o    => pipe_tx1_compliance_o,
        pipe_tx_char_is_k_o     => pipe_tx1_char_is_k_o,
        pipe_tx_data_o          => pipe_tx1_data_o,
        pipe_tx_elec_idle_o     => pipe_tx1_elec_idle_o,
        pipe_tx_powerdown_o     => pipe_tx1_powerdown_o,
        pipe_clk                => pipe_clk,
        rst_n                   => rst_n);

  end generate;

  pipe_lane_lt2 : if (LINK_CAP_MAX_LINK_WIDTH_int < 2) generate
    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    pipe_rx1_char_is_k_o <= "00";
    pipe_rx1_data_o <= (others => '0');
    pipe_rx1_valid_o<= '0';
    pipe_rx1_chanisaligned_o<= '0';
    pipe_rx1_status_o<= "000";
    pipe_rx1_phy_status_o<= '0';
    pipe_rx1_elec_idle_o<= '1';
    pipe_rx1_polarity_o<= '0';
    pipe_tx1_compliance_o<= '0';
    pipe_tx1_char_is_k_o<= "00";
    pipe_tx1_data_o<= (others => '0');
    pipe_tx1_elec_idle_o<= '1';
    pipe_tx1_powerdown_o<= "00";
    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  end generate;

  pipe_lane_4 : if (LINK_CAP_MAX_LINK_WIDTH_int >= 4) generate
    pipe_lane_2_i : cl_a7pcie_x4_pcie_pipe_lane
      generic map (
        PIPE_PIPELINE_STAGES => PIPE_PIPELINE_STAGES)
      port map (
        pipe_rx_char_is_k_o     => pipe_rx2_char_is_k_o,
        pipe_rx_data_o          => pipe_rx2_data_o,
        pipe_rx_valid_o         => pipe_rx2_valid_o,
        pipe_rx_chanisaligned_o => pipe_rx2_chanisaligned_o,
        pipe_rx_status_o        => pipe_rx2_status_o,
        pipe_rx_phy_status_o    => pipe_rx2_phy_status_o,
        pipe_rx_elec_idle_o     => pipe_rx2_elec_idle_o,
        pipe_rx_polarity_i      => pipe_rx2_polarity_i,
        pipe_tx_compliance_i    => pipe_tx2_compliance_i,
        pipe_tx_char_is_k_i     => pipe_tx2_char_is_k_i,
        pipe_tx_data_i          => pipe_tx2_data_i,
        pipe_tx_elec_idle_i     => pipe_tx2_elec_idle_i,
        pipe_tx_powerdown_i     => pipe_tx2_powerdown_i,
        pipe_rx_char_is_k_i     => pipe_rx2_char_is_k_i,
        pipe_rx_data_i          => pipe_rx2_data_i,
        pipe_rx_valid_i         => pipe_rx2_valid_i,
        pipe_rx_chanisaligned_i => pipe_rx2_chanisaligned_i,
        pipe_rx_status_i        => pipe_rx2_status_i,
        pipe_rx_phy_status_i    => pipe_rx2_phy_status_i,
        pipe_rx_elec_idle_i     => pipe_rx2_elec_idle_i,
        pipe_rx_polarity_o      => pipe_rx2_polarity_o,
        pipe_tx_compliance_o    => pipe_tx2_compliance_o,
        pipe_tx_char_is_k_o     => pipe_tx2_char_is_k_o,
        pipe_tx_data_o          => pipe_tx2_data_o,
        pipe_tx_elec_idle_o     => pipe_tx2_elec_idle_o,
        pipe_tx_powerdown_o     => pipe_tx2_powerdown_o,
        pipe_clk                => pipe_clk,
        rst_n                   => rst_n);

    pipe_lane_3_i : cl_a7pcie_x4_pcie_pipe_lane
      generic map (
        PIPE_PIPELINE_STAGES => PIPE_PIPELINE_STAGES)
      port map (
        pipe_rx_char_is_k_o     => pipe_rx3_char_is_k_o,
        pipe_rx_data_o          => pipe_rx3_data_o,
        pipe_rx_valid_o         => pipe_rx3_valid_o,
        pipe_rx_chanisaligned_o => pipe_rx3_chanisaligned_o,
        pipe_rx_status_o        => pipe_rx3_status_o,
        pipe_rx_phy_status_o    => pipe_rx3_phy_status_o,
        pipe_rx_elec_idle_o     => pipe_rx3_elec_idle_o,
        pipe_rx_polarity_i      => pipe_rx3_polarity_i,
        pipe_tx_compliance_i    => pipe_tx3_compliance_i,
        pipe_tx_char_is_k_i     => pipe_tx3_char_is_k_i,
        pipe_tx_data_i          => pipe_tx3_data_i,
        pipe_tx_elec_idle_i     => pipe_tx3_elec_idle_i,
        pipe_tx_powerdown_i     => pipe_tx3_powerdown_i,
        pipe_rx_char_is_k_i     => pipe_rx3_char_is_k_i,
        pipe_rx_data_i          => pipe_rx3_data_i,
        pipe_rx_valid_i         => pipe_rx3_valid_i,
        pipe_rx_chanisaligned_i => pipe_rx3_chanisaligned_i,
        pipe_rx_status_i        => pipe_rx3_status_i,
        pipe_rx_phy_status_i    => pipe_rx3_phy_status_i,
        pipe_rx_elec_idle_i     => pipe_rx3_elec_idle_i,
        pipe_rx_polarity_o      => pipe_rx3_polarity_o,
        pipe_tx_compliance_o    => pipe_tx3_compliance_o,
        pipe_tx_char_is_k_o     => pipe_tx3_char_is_k_o,
        pipe_tx_data_o          => pipe_tx3_data_o,
        pipe_tx_elec_idle_o     => pipe_tx3_elec_idle_o,
        pipe_tx_powerdown_o     => pipe_tx3_powerdown_o,
        pipe_clk                => pipe_clk,
        rst_n                   => rst_n);

   end generate;
   pipe_lane_lt4 : if (LINK_CAP_MAX_LINK_WIDTH_int < 4) generate
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      pipe_rx2_char_is_k_o <= "00";
      pipe_rx2_data_o <= (others => '0');
      pipe_rx2_valid_o<= '0';
      pipe_rx2_chanisaligned_o<= '0';
      pipe_rx2_status_o<= "000";
      pipe_rx2_phy_status_o<= '0';
      pipe_rx2_elec_idle_o<= '1';
      pipe_rx2_polarity_o<= '0';
      pipe_tx2_compliance_o<= '0';
      pipe_tx2_char_is_k_o<= "00";
      pipe_tx2_data_o<= (others => '0');
      pipe_tx2_elec_idle_o<= '1';
      pipe_tx2_powerdown_o<= "00";

      pipe_rx3_char_is_k_o <= "00";
      pipe_rx3_data_o <= (others => '0');
      pipe_rx3_valid_o<= '0';
      pipe_rx3_chanisaligned_o<= '0';
      pipe_rx3_status_o<= "000";
      pipe_rx3_phy_status_o<= '0';
      pipe_rx3_elec_idle_o<= '1';
      pipe_rx3_polarity_o<= '0';
      pipe_tx3_compliance_o<= '0';
      pipe_tx3_char_is_k_o<= "00";
      pipe_tx3_data_o<= (others => '0');
      pipe_tx3_elec_idle_o<= '1';
      pipe_tx3_powerdown_o<= "00";
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

   end generate;

  pipe_lane_8 : if (LINK_CAP_MAX_LINK_WIDTH_int >= 8) generate

    pipe_lane_4_i : cl_a7pcie_x4_pcie_pipe_lane
      generic map (
        PIPE_PIPELINE_STAGES => PIPE_PIPELINE_STAGES)
      port map (
        pipe_rx_char_is_k_o     => pipe_rx4_char_is_k_o,
        pipe_rx_data_o          => pipe_rx4_data_o,
        pipe_rx_valid_o         => pipe_rx4_valid_o,
        pipe_rx_chanisaligned_o => pipe_rx4_chanisaligned_o,
        pipe_rx_status_o        => pipe_rx4_status_o,
        pipe_rx_phy_status_o    => pipe_rx4_phy_status_o,
        pipe_rx_elec_idle_o     => pipe_rx4_elec_idle_o,
        pipe_rx_polarity_i      => pipe_rx4_polarity_i,
        pipe_tx_compliance_i    => pipe_tx4_compliance_i,
        pipe_tx_char_is_k_i     => pipe_tx4_char_is_k_i,
        pipe_tx_data_i          => pipe_tx4_data_i,
        pipe_tx_elec_idle_i     => pipe_tx4_elec_idle_i,
        pipe_tx_powerdown_i     => pipe_tx4_powerdown_i,
        pipe_rx_char_is_k_i     => pipe_rx4_char_is_k_i,
        pipe_rx_data_i          => pipe_rx4_data_i,
        pipe_rx_valid_i         => pipe_rx4_valid_i,
        pipe_rx_chanisaligned_i => pipe_rx4_chanisaligned_i,
        pipe_rx_status_i        => pipe_rx4_status_i,
        pipe_rx_phy_status_i    => pipe_rx4_phy_status_i,
        pipe_rx_elec_idle_i     => pipe_rx4_elec_idle_i,
        pipe_rx_polarity_o      => pipe_rx4_polarity_o,
        pipe_tx_compliance_o    => pipe_tx4_compliance_o,
        pipe_tx_char_is_k_o     => pipe_tx4_char_is_k_o,
        pipe_tx_data_o          => pipe_tx4_data_o,
        pipe_tx_elec_idle_o     => pipe_tx4_elec_idle_o,
        pipe_tx_powerdown_o     => pipe_tx4_powerdown_o,
        pipe_clk                => pipe_clk,
        rst_n                   => rst_n);

    pipe_lane_5_i : cl_a7pcie_x4_pcie_pipe_lane
      generic map (
        PIPE_PIPELINE_STAGES => PIPE_PIPELINE_STAGES)
      port map (
        pipe_rx_char_is_k_o     => pipe_rx5_char_is_k_o,
        pipe_rx_data_o          => pipe_rx5_data_o,
        pipe_rx_valid_o         => pipe_rx5_valid_o,
        pipe_rx_chanisaligned_o => pipe_rx5_chanisaligned_o,
        pipe_rx_status_o        => pipe_rx5_status_o,
        pipe_rx_phy_status_o    => pipe_rx5_phy_status_o,
        pipe_rx_elec_idle_o     => pipe_rx5_elec_idle_o,
        pipe_rx_polarity_i      => pipe_rx5_polarity_i,
        pipe_tx_compliance_i    => pipe_tx5_compliance_i,
        pipe_tx_char_is_k_i     => pipe_tx5_char_is_k_i,
        pipe_tx_data_i          => pipe_tx5_data_i,
        pipe_tx_elec_idle_i     => pipe_tx5_elec_idle_i,
        pipe_tx_powerdown_i     => pipe_tx5_powerdown_i,
        pipe_rx_char_is_k_i     => pipe_rx5_char_is_k_i,
        pipe_rx_data_i          => pipe_rx5_data_i,
        pipe_rx_valid_i         => pipe_rx5_valid_i,
        pipe_rx_chanisaligned_i => pipe_rx5_chanisaligned_i,
        pipe_rx_status_i        => pipe_rx5_status_i,
        pipe_rx_phy_status_i    => pipe_rx5_phy_status_i,
        pipe_rx_elec_idle_i     => pipe_rx5_elec_idle_i,
        pipe_rx_polarity_o      => pipe_rx5_polarity_o,
        pipe_tx_compliance_o    => pipe_tx5_compliance_o,
        pipe_tx_char_is_k_o     => pipe_tx5_char_is_k_o,
        pipe_tx_data_o          => pipe_tx5_data_o,
        pipe_tx_elec_idle_o     => pipe_tx5_elec_idle_o,
        pipe_tx_powerdown_o     => pipe_tx5_powerdown_o,
        pipe_clk                => pipe_clk,
        rst_n                   => rst_n);

    pipe_lane_6_i : cl_a7pcie_x4_pcie_pipe_lane
      generic map (
        PIPE_PIPELINE_STAGES => PIPE_PIPELINE_STAGES)
      port map (
        pipe_rx_char_is_k_o     => pipe_rx6_char_is_k_o,
        pipe_rx_data_o          => pipe_rx6_data_o,
        pipe_rx_valid_o         => pipe_rx6_valid_o,
        pipe_rx_chanisaligned_o => pipe_rx6_chanisaligned_o,
        pipe_rx_status_o        => pipe_rx6_status_o,
        pipe_rx_phy_status_o    => pipe_rx6_phy_status_o,
        pipe_rx_elec_idle_o     => pipe_rx6_elec_idle_o,
        pipe_rx_polarity_i      => pipe_rx6_polarity_i,
        pipe_tx_compliance_i    => pipe_tx6_compliance_i,
        pipe_tx_char_is_k_i     => pipe_tx6_char_is_k_i,
        pipe_tx_data_i          => pipe_tx6_data_i,
        pipe_tx_elec_idle_i     => pipe_tx6_elec_idle_i,
        pipe_tx_powerdown_i     => pipe_tx6_powerdown_i,
        pipe_rx_char_is_k_i     => pipe_rx6_char_is_k_i,
        pipe_rx_data_i          => pipe_rx6_data_i,
        pipe_rx_valid_i         => pipe_rx6_valid_i,
        pipe_rx_chanisaligned_i => pipe_rx6_chanisaligned_i,
        pipe_rx_status_i        => pipe_rx6_status_i,
        pipe_rx_phy_status_i    => pipe_rx6_phy_status_i,
        pipe_rx_elec_idle_i     => pipe_rx6_elec_idle_i,
        pipe_rx_polarity_o      => pipe_rx6_polarity_o,
        pipe_tx_compliance_o    => pipe_tx6_compliance_o,
        pipe_tx_char_is_k_o     => pipe_tx6_char_is_k_o,
        pipe_tx_data_o          => pipe_tx6_data_o,
        pipe_tx_elec_idle_o     => pipe_tx6_elec_idle_o,
        pipe_tx_powerdown_o     => pipe_tx6_powerdown_o,
        pipe_clk                => pipe_clk,
        rst_n                   => rst_n);

    pipe_lane_7_i : cl_a7pcie_x4_pcie_pipe_lane
      generic map (
        PIPE_PIPELINE_STAGES => PIPE_PIPELINE_STAGES)
      port map (
        pipe_rx_char_is_k_o     => pipe_rx7_char_is_k_o,
        pipe_rx_data_o          => pipe_rx7_data_o,
        pipe_rx_valid_o         => pipe_rx7_valid_o,
        pipe_rx_chanisaligned_o => pipe_rx7_chanisaligned_o,
        pipe_rx_status_o        => pipe_rx7_status_o,
        pipe_rx_phy_status_o    => pipe_rx7_phy_status_o,
        pipe_rx_elec_idle_o     => pipe_rx7_elec_idle_o,
        pipe_rx_polarity_i      => pipe_rx7_polarity_i,
        pipe_tx_compliance_i    => pipe_tx7_compliance_i,
        pipe_tx_char_is_k_i     => pipe_tx7_char_is_k_i,
        pipe_tx_data_i          => pipe_tx7_data_i,
        pipe_tx_elec_idle_i     => pipe_tx7_elec_idle_i,
        pipe_tx_powerdown_i     => pipe_tx7_powerdown_i,
        pipe_rx_char_is_k_i     => pipe_rx7_char_is_k_i,
        pipe_rx_data_i          => pipe_rx7_data_i,
        pipe_rx_valid_i         => pipe_rx7_valid_i,
        pipe_rx_chanisaligned_i => pipe_rx7_chanisaligned_i,
        pipe_rx_status_i        => pipe_rx7_status_i,
        pipe_rx_phy_status_i    => pipe_rx7_phy_status_i,
        pipe_rx_elec_idle_i     => pipe_rx7_elec_idle_i,
        pipe_rx_polarity_o      => pipe_rx7_polarity_o,
        pipe_tx_compliance_o    => pipe_tx7_compliance_o,
        pipe_tx_char_is_k_o     => pipe_tx7_char_is_k_o,
        pipe_tx_data_o          => pipe_tx7_data_o,
        pipe_tx_elec_idle_o     => pipe_tx7_elec_idle_o,
        pipe_tx_powerdown_o     => pipe_tx7_powerdown_o,
        pipe_clk                => pipe_clk,
        rst_n                   => rst_n);


   end generate;
   pipe_lane_lt8 : if (LINK_CAP_MAX_LINK_WIDTH_int < 8) generate
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      pipe_rx4_char_is_k_o <= "00";
      pipe_rx4_data_o <= (others => '0');
      pipe_rx4_valid_o<= '0';
      pipe_rx4_chanisaligned_o<= '0';
      pipe_rx4_status_o<= "000";
      pipe_rx4_phy_status_o<= '0';
      pipe_rx4_elec_idle_o<= '1';
      pipe_rx4_polarity_o<= '0';
      pipe_tx4_compliance_o<= '0';
      pipe_tx4_char_is_k_o<= "00";
      pipe_tx4_data_o<= (others => '0');
      pipe_tx4_elec_idle_o<= '1';
      pipe_tx4_powerdown_o<= "00";

      pipe_rx5_char_is_k_o <= "00";
      pipe_rx5_data_o <= (others => '0');
      pipe_rx5_valid_o<= '0';
      pipe_rx5_chanisaligned_o<= '0';
      pipe_rx5_status_o<= "000";
      pipe_rx5_phy_status_o<= '0';
      pipe_rx5_elec_idle_o<= '1';
      pipe_rx5_polarity_o<= '0';
      pipe_tx5_compliance_o<= '0';
      pipe_tx5_char_is_k_o<= "00";
      pipe_tx5_data_o<= (others => '0');
      pipe_tx5_elec_idle_o<= '1';
      pipe_tx5_powerdown_o<= "00";

      pipe_rx6_char_is_k_o <= "00";
      pipe_rx6_data_o <= (others => '0');
      pipe_rx6_valid_o<= '0';
      pipe_rx6_chanisaligned_o<= '0';
      pipe_rx6_status_o<= "000";
      pipe_rx6_phy_status_o<= '0';
      pipe_rx6_elec_idle_o<= '1';
      pipe_rx6_polarity_o<= '0';
      pipe_tx6_compliance_o<= '0';
      pipe_tx6_char_is_k_o<= "00";
      pipe_tx6_data_o<= (others => '0');
      pipe_tx6_elec_idle_o<= '1';
      pipe_tx6_powerdown_o<= "00";

      pipe_rx7_char_is_k_o <= "00";
      pipe_rx7_data_o <= (others => '0');
      pipe_rx7_valid_o<= '0';
      pipe_rx7_chanisaligned_o<= '0';
      pipe_rx7_status_o<= "000";
      pipe_rx7_phy_status_o<= '0';
      pipe_rx7_elec_idle_o<= '1';
      pipe_rx7_polarity_o<= '0';
      pipe_tx7_compliance_o<= '0';
      pipe_tx7_char_is_k_o<= "00";
      pipe_tx7_data_o<= (others => '0');
      pipe_tx7_elec_idle_o<= '1';
      pipe_tx7_powerdown_o<= "00";
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

   end generate;

   --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

   --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


end rtl;

