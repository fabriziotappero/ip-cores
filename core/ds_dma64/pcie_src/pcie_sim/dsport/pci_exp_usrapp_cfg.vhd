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
-- File       : pci_exp_usrapp_cfg.vhd
-- Version    : 2.3
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.test_interface.all;

entity pci_exp_usrapp_cfg is

port (

  cfg_do                   : in std_logic_vector((32 - 1) downto 0);
  cfg_di                   : out std_logic_vector((32 - 1) downto 0);
  cfg_byte_en_n            : out std_logic_vector(((32/8) - 1) downto 0);
  cfg_dwaddr               : out std_logic_vector((10 - 1) downto 0);
  cfg_wr_en_n              : out std_logic;
  cfg_rd_en_n              : out std_logic;
  cfg_rd_wr_done_n         : in std_logic;
  cfg_err_cor_n            : out std_logic;
  cfg_err_ur_n             : out std_logic;
  cfg_err_ecrc_n           : out std_logic;
  cfg_err_cpl_timeout_n    : out std_logic;
  cfg_err_cpl_abort_n      : out std_logic;
  cfg_err_cpl_unexpect_n   : out std_logic;
  cfg_err_posted_n         : out std_logic;
  cfg_err_tlp_cpl_header   : out std_logic_vector(( 48 - 1) downto 0);
  cfg_interrupt_n          : out std_logic;
  cfg_interrupt_rdy_n      : in std_logic;
  cfg_turnoff_ok_n         : out std_logic;
  cfg_to_turnoff_n         : in std_logic;
  cfg_pm_wake_n	           : out std_logic;
  cfg_bus_number           : in std_logic_vector((8 -1) downto 0);
  cfg_device_number        : in std_logic_vector((5 - 1) downto 0);
  cfg_function_number      : in std_logic_vector((3 - 1) downto 0);
  cfg_status               : in std_logic_vector((16 - 1) downto 0);
  cfg_command              : in std_logic_vector((16 - 1) downto 0);
  cfg_dstatus              : in std_logic_vector((16 - 1) downto 0);
  cfg_dcommand             : in std_logic_vector((16 - 1) downto 0);
  cfg_lstatus              : in std_logic_vector((16 - 1) downto 0);
  cfg_lcommand             : in std_logic_vector((16 - 1) downto 0);
  cfg_pcie_link_state_n    : in std_logic_vector((3 - 1) downto 0);
  cfg_trn_pending_n        : out std_logic;

  trn_clk                  : in std_logic;
  trn_reset_n              : in std_logic

);


end pci_exp_usrapp_cfg;

architecture rtl of pci_exp_usrapp_cfg is

begin

  -- Signals not used by testbench at this point
  cfg_err_cor_n <= '1';
  cfg_err_ur_n <= '1';
  cfg_err_ecrc_n <= '1';
  cfg_err_cpl_timeout_n <= '1';
  cfg_err_cpl_abort_n <= '1';
  cfg_err_cpl_unexpect_n <= '1';
  cfg_err_posted_n <= '0';
  cfg_interrupt_n <= '1';
  cfg_turnoff_ok_n <= '1';
  cfg_err_tlp_cpl_header <= (others => '0');
  cfg_pm_wake_n <= '1';
  cfg_trn_pending_n <= '0';

  ------------------
  -- The following signals are driven by processes defined in
  -- test_package and called from tests.vhd
  ------------------

  -- Inputs to CFG procecces / Outputs of core
  cfg_rdwr_int.trn_clk          <= trn_clk;
  cfg_rdwr_int.trn_reset_n      <= trn_reset_n;
  cfg_rdwr_int.cfg_rd_wr_done_n <= cfg_rd_wr_done_n;
  cfg_rdwr_int.cfg_do           <= cfg_do;

  -- Outputs of CFG processes / Inputs to core
  cfg_dwaddr     <= cfg_rdwr_int.cfg_dwaddr;
  cfg_di         <= cfg_rdwr_int.cfg_di;
  cfg_byte_en_n  <= cfg_rdwr_int.cfg_byte_en_n;
  cfg_wr_en_n    <= cfg_rdwr_int.cfg_wr_en_n;
  cfg_rd_en_n    <= cfg_rdwr_int.cfg_rd_en_n;

end;  -- pci_exp_usrapp_cfg
