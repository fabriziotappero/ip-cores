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
-- File       : xilinx_pcie_rport_m2.vhd
-- Version    : 2.3
--
-- Description:  PCI Express Root Port example FPGA design
--
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.cmd_sim_pkg.all;

package	xilinx_pcie_rport_m2_pkg is

component xilinx_pcie_rport_m2 is
  generic (
     REF_CLK_FREQ                      : integer := 0;		-- 0 - 100MHz, 1 - 125 MHz, 2 - 250 MHz
     ALLOW_X8_GEN2                     : boolean := FALSE;
     PL_FAST_TRAIN                     : boolean := FALSE;
     LINK_CAP_MAX_LINK_SPEED           : bit_vector := X"1";
     DEVICE_ID                         : bit_vector := X"0007";
     LINK_CAP_MAX_LINK_WIDTH           : bit_vector := X"08";
     LTSSM_MAX_LINK_WIDTH              : bit_vector := X"08";
     LINK_CAP_MAX_LINK_WIDTH_int       : integer := 8;
     LINK_CTRL2_TARGET_LINK_SPEED      : bit_vector := X"2";
     DEV_CAP_MAX_PAYLOAD_SUPPORTED     : integer := 2;
     USER_CLK_FREQ                     : integer := 3;
     VC0_TX_LASTPACKET                 : integer := 31;
     VC0_RX_RAM_LIMIT                  : bit_vector := X"03FF";
     VC0_TOTAL_CREDITS_CD              : integer := 154;
     VC0_TOTAL_CREDITS_PD              : integer := 154
    );
  port (
		pci_exp_txp                   	: out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
		pci_exp_txn                   	: out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
		pci_exp_rxp                   	: in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
		pci_exp_rxn                   	: in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
		
		sys_clk                       	: in std_logic;
		sys_reset_n                   	: in std_logic;
		
		---- Test ----
		cmd								: in  bh_cmd; 	-- команда
		ret								: out bh_ret 	-- ответ
  
);	 

end component;

end package;



library ieee;
use ieee.std_logic_1164.all;

library work;
use work.cmd_sim_pkg.all;	   


use work.pci_exp_usrapp_tx_m2_pkg.all;	 
use work.pci_exp_usrapp_rx_m2_pkg.all;

entity xilinx_pcie_rport_m2 is
  generic (
     REF_CLK_FREQ                      : integer := 0;		-- 0 - 100MHz, 1 - 125 MHz, 2 - 250 MHz
     ALLOW_X8_GEN2                     : boolean := FALSE;
     PL_FAST_TRAIN                     : boolean := FALSE;
     LINK_CAP_MAX_LINK_SPEED           : bit_vector := X"1";
     DEVICE_ID                         : bit_vector := X"0007";
     LINK_CAP_MAX_LINK_WIDTH           : bit_vector := X"08";
     LTSSM_MAX_LINK_WIDTH              : bit_vector := X"08";
     LINK_CAP_MAX_LINK_WIDTH_int       : integer := 8;
     LINK_CTRL2_TARGET_LINK_SPEED      : bit_vector := X"2";
     DEV_CAP_MAX_PAYLOAD_SUPPORTED     : integer := 2;
     USER_CLK_FREQ                     : integer := 3;
     VC0_TX_LASTPACKET                 : integer := 31;
     VC0_RX_RAM_LIMIT                  : bit_vector := X"03FF";
     VC0_TOTAL_CREDITS_CD              : integer := 154;
     VC0_TOTAL_CREDITS_PD              : integer := 154
    );
  port (
		pci_exp_txp                   	: out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
		pci_exp_txn                   	: out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
		pci_exp_rxp                   	: in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
		pci_exp_rxn                   	: in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
		
		sys_clk                       	: in std_logic;
		sys_reset_n                   	: in std_logic;
		
		---- Test ----
		cmd								: in  bh_cmd; 	-- команда
		ret								: out bh_ret 	-- ответ
  
);	 

end xilinx_pcie_rport_m2;

architecture rtl of xilinx_pcie_rport_m2 is 

  component pcie_2_0_rport_v6
    generic (
      REF_CLK_FREQ : integer;
      ALLOW_X8_GEN2 : boolean;
      PL_FAST_TRAIN : boolean;
      LINK_CAP_MAX_LINK_SPEED : bit_vector;
      DEVICE_ID : bit_vector;
      LINK_CAP_MAX_LINK_WIDTH : bit_vector;
      LINK_CAP_MAX_LINK_WIDTH_int : integer;
      LINK_CTRL2_TARGET_LINK_SPEED : bit_vector;
      LTSSM_MAX_LINK_WIDTH : bit_vector;
      DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer;
      USER_CLK_FREQ : integer;
      VC0_TX_LASTPACKET : integer;
      VC0_RX_RAM_LIMIT : bit_vector;
      VC0_TOTAL_CREDITS_CD : integer;
      VC0_TOTAL_CREDITS_PD : integer
);
    port (
      pci_exp_txp                               : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
      pci_exp_txn                               : out std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
      pci_exp_rxp                               : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
      pci_exp_rxn                               : in std_logic_vector((LINK_CAP_MAX_LINK_WIDTH_int - 1) downto 0);
      trn_clk                                   : out std_logic;
      trn_reset_n                               : out std_logic;
      trn_lnk_up_n                              : out std_logic;
      trn_tbuf_av                               : out std_logic_vector(5 downto 0);
      trn_tcfg_req_n                            : out std_logic;
      trn_terr_drop_n                           : out std_logic;
      trn_tdst_rdy_n                            : out std_logic;
      trn_td                                    : in std_logic_vector(63 downto 0);
      trn_trem_n                                : in std_logic;
      trn_tsof_n                                : in std_logic;
      trn_teof_n                                : in std_logic;
      trn_tsrc_rdy_n                            : in std_logic;
      trn_tsrc_dsc_n                            : in std_logic;
      trn_terrfwd_n                             : in std_logic;
      trn_tcfg_gnt_n                            : in std_logic;
      trn_tstr_n                                : in std_logic;
      trn_rd                                    : out std_logic_vector(63 downto 0);
      trn_rrem_n                                : out std_logic;
      trn_rsof_n                                : out std_logic;
      trn_reof_n                                : out std_logic;
      trn_rsrc_rdy_n                            : out std_logic;
      trn_rsrc_dsc_n                            : out std_logic;
      trn_rerrfwd_n                             : out std_logic;
      trn_rbar_hit_n                            : out std_logic_vector(6 downto 0);
      trn_rdst_rdy_n                            : in std_logic;
      trn_rnp_ok_n                              : in std_logic;
      trn_recrc_err_n                           : out std_logic;
      trn_fc_cpld                               : out std_logic_vector(11 downto 0);
      trn_fc_cplh                               : out std_logic_vector(7 downto 0);
      trn_fc_npd                                : out std_logic_vector(11 downto 0);
      trn_fc_nph                                : out std_logic_vector(7 downto 0);
      trn_fc_pd                                 : out std_logic_vector(11 downto 0);
      trn_fc_ph                                 : out std_logic_vector(7 downto 0);
      trn_fc_sel                                : in std_logic_vector(2 downto 0);
      cfg_do                                    : out std_logic_vector(31 downto 0);
      cfg_rd_wr_done_n                          : out std_logic;
      cfg_di                                    : in std_logic_vector(31 downto 0);
      cfg_byte_en_n                             : in std_logic_vector(3 downto 0);
      cfg_dwaddr                                : in std_logic_vector(9 downto 0);
      cfg_wr_en_n                               : in std_logic;
      cfg_wr_rw1c_as_rw_n                       : in std_logic;
      cfg_rd_en_n                               : in std_logic;
      cfg_err_cor_n                             : in std_logic;
      cfg_err_ur_n                              : in std_logic;
      cfg_err_ecrc_n                            : in std_logic;
      cfg_err_cpl_timeout_n                     : in std_logic;
      cfg_err_cpl_abort_n                       : in std_logic;
      cfg_err_cpl_unexpect_n                    : in std_logic;
      cfg_err_posted_n                          : in std_logic;
      cfg_err_locked_n                          : in std_logic;
      cfg_err_tlp_cpl_header                    : in std_logic_vector(47 downto 0);
      cfg_err_cpl_rdy_n                         : out std_logic;
      cfg_interrupt_n                           : in std_logic;
      cfg_interrupt_rdy_n                       : out std_logic;
      cfg_interrupt_assert_n                    : in std_logic;
      cfg_interrupt_di                          : in std_logic_vector(7 downto 0);
      cfg_interrupt_do                          : out std_logic_vector(7 downto 0);
      cfg_interrupt_mmenable                    : out std_logic_vector(2 downto 0);
      cfg_interrupt_msienable                   : out std_logic;
      cfg_interrupt_msixenable                  : out std_logic;
      cfg_interrupt_msixfm                      : out std_logic;
      cfg_trn_pending_n                         : in std_logic;
      cfg_pm_send_pme_to_n                      : in std_logic;
      cfg_status                                : out std_logic_vector(15 downto 0);
      cfg_command                               : out std_logic_vector(15 downto 0);
      cfg_dstatus                               : out std_logic_vector(15 downto 0);
      cfg_dcommand                              : out std_logic_vector(15 downto 0);
      cfg_lstatus                               : out std_logic_vector(15 downto 0);
      cfg_lcommand                              : out std_logic_vector(15 downto 0);
      cfg_dcommand2                             : out std_logic_vector(15 downto 0);
      cfg_pcie_link_state_n                     : out std_logic_vector(2 downto 0);
      cfg_dsn                                   : in std_logic_vector(63 downto 0);
      cfg_pmcsr_pme_en                          : out std_logic;
      cfg_pmcsr_pme_status                      : out std_logic;
      cfg_pmcsr_powerstate                      : out std_logic_vector(1 downto 0);
      cfg_msg_received                          : out std_logic;
      cfg_msg_data                              : out std_logic_vector(15 downto 0);
      cfg_msg_received_err_cor                  : out std_logic;
      cfg_msg_received_err_non_fatal            : out std_logic;
      cfg_msg_received_err_fatal                : out std_logic;
      cfg_msg_received_pme_to_ack               : out std_logic;
      cfg_msg_received_assert_inta              : out std_logic;
      cfg_msg_received_assert_intb              : out std_logic;
      cfg_msg_received_assert_intc              : out std_logic;
      cfg_msg_received_assert_intd              : out std_logic;
      cfg_msg_received_deassert_inta            : out std_logic;
      cfg_msg_received_deassert_intb            : out std_logic;
      cfg_msg_received_deassert_intc            : out std_logic;
      cfg_msg_received_deassert_intd            : out std_logic;
      cfg_ds_bus_number                         : in std_logic_vector(7 downto 0);
      cfg_ds_device_number                      : in std_logic_vector(4 downto 0);
      pl_initial_link_width                     : out std_logic_vector(2 downto 0);
      pl_lane_reversal_mode                     : out std_logic_vector(1 downto 0);
      pl_link_gen2_capable                      : out std_logic;
      pl_link_partner_gen2_supported            : out std_logic;
      pl_link_upcfg_capable                     : out std_logic;
      pl_ltssm_state                            : out std_logic_vector(5 downto 0);
      pl_sel_link_rate                          : out std_logic;
      pl_sel_link_width                         : out std_logic_vector(1 downto 0);
      pl_directed_link_auton                    : in std_logic;
      pl_directed_link_change                   : in std_logic_vector(1 downto 0);
      pl_directed_link_speed                    : in std_logic;
      pl_directed_link_width                    : in std_logic_vector(1 downto 0);
      pl_upstream_prefer_deemph                 : in std_logic;
      pl_transmit_hot_rst                       : in std_logic;
      pcie_drp_clk                              : in std_logic;
      pcie_drp_den                              : in std_logic;
      pcie_drp_dwe                              : in std_logic;
      pcie_drp_daddr                            : in std_logic_vector(8 downto 0);
      pcie_drp_di                               : in std_logic_vector(15 downto 0);
      pcie_drp_do                               : out std_logic_vector(15 downto 0);
      pcie_drp_drdy                             : out std_logic;
      sys_clk                                   : in std_logic;
      sys_reset_n                               : in std_logic);
  end component;

component pci_exp_usrapp_cfg
  port (
    cfg_do                 : in  std_logic_vector(31 downto 0);
    cfg_di                 : out std_logic_vector(31 downto 0);
    cfg_byte_en_n          : out std_logic_vector(3 downto 0);
    cfg_dwaddr             : out std_logic_vector(9 downto 0);
    cfg_wr_en_n            : out std_logic;
    cfg_rd_en_n            : out std_logic;
    cfg_rd_wr_done_n       : in  std_logic;
    cfg_err_cor_n          : out std_logic;
    cfg_err_ur_n           : out std_logic;
    cfg_err_ecrc_n         : out std_logic;
    cfg_err_cpl_timeout_n  : out std_logic;
    cfg_err_cpl_abort_n    : out std_logic;
    cfg_err_cpl_unexpect_n : out std_logic;
    cfg_err_posted_n       : out std_logic;
    cfg_err_tlp_cpl_header : out std_logic_vector(47 downto 0);
    cfg_interrupt_n        : out std_logic;
    cfg_interrupt_rdy_n    : in  std_logic;
    cfg_turnoff_ok_n       : out std_logic;
    cfg_to_turnoff_n       : in  std_logic;
    cfg_pm_wake_n          : out std_logic;
    cfg_bus_number         : in  std_logic_vector((8 -1) downto 0);
    cfg_device_number      : in  std_logic_vector((5 - 1) downto 0);
    cfg_function_number    : in  std_logic_vector((3 - 1) downto 0);
    cfg_status             : in  std_logic_vector((16 - 1) downto 0);
    cfg_command            : in  std_logic_vector((16 - 1) downto 0);
    cfg_dstatus            : in  std_logic_vector((16 - 1) downto 0);
    cfg_dcommand           : in  std_logic_vector((16 - 1) downto 0);
    cfg_lstatus            : in  std_logic_vector((16 - 1) downto 0);
    cfg_lcommand           : in  std_logic_vector((16 - 1) downto 0);
    cfg_pcie_link_state_n  : in  std_logic_vector((3 - 1) downto 0);
    cfg_trn_pending_n      : out std_logic;
    trn_clk                : in  std_logic;
    trn_reset_n            : in  std_logic);
end component;




component pci_exp_usrapp_pl
  generic (
    LINK_CAP_MAX_LINK_SPEED : integer);
  port (
    pl_initial_link_width          : in  std_logic_vector(2 downto 0);
    pl_lane_reversal_mode          : in  std_logic_vector(1 downto 0);
    pl_link_gen2_capable           : in  std_logic;
    pl_link_partner_gen2_supported : in  std_logic;
    pl_link_upcfg_capable          : in  std_logic;
    pl_ltssm_state                 : in  std_logic_vector(5 downto 0);
    pl_received_hot_rst            : in  std_logic;
    pl_sel_link_rate               : in  std_logic;
    pl_sel_link_width              : in  std_logic_vector(1 downto 0);
    pl_directed_link_auton         : out std_logic;
    pl_directed_link_change        : out std_logic_vector(1 downto 0);
    pl_directed_link_speed         : out std_logic;
    pl_directed_link_width         : out std_logic_vector(1 downto 0);
    pl_upstream_prefer_deemph      : out std_logic;
    speed_change_done_n            : out std_logic;
    trn_lnk_up_n                   : in  std_logic;
    trn_clk                        : in  std_logic;
    trn_reset_n                    : in  std_logic);
end component;

  FUNCTION to_integer (
      val_in    : bit_vector) RETURN integer IS
      
      CONSTANT vctr   : bit_vector(val_in'high-val_in'low DOWNTO 0) := val_in;
      VARIABLE ret    : integer := 0;
   BEGIN
      FOR index IN vctr'RANGE LOOP
         IF (vctr(index) = '1') THEN
            ret := ret + (2**index);
         END IF;
      END LOOP;
      RETURN(ret);
   END to_integer;
         
   constant LINK_CAP_MAX_LINK_SPEED_int : integer := to_integer(LINK_CAP_MAX_LINK_SPEED);

  signal rx_tx_read_data       : std_logic_vector(31 downto 0);
  signal rx_tx_read_data_valid : std_logic;
  signal tx_rx_read_data_valid : std_logic;
  signal speed_change_done_n   : std_logic;

  -- Tx
  signal trn_tbuf_av : std_logic_vector(5 downto 0);
  signal trn_tdst_dsc_n : std_logic;
  signal trn_tdst_rdy_n : std_logic;
  signal trn_td : std_logic_vector(63 downto 0);
  signal trn_trem_n : std_logic;
  signal trn_trem_n_out : std_logic_vector(7 downto 0);
  signal trn_tsof_n : std_logic;
  signal trn_teof_n : std_logic;
  signal trn_tsrc_rdy_n : std_logic;
  signal trn_tsrc_dsc_n : std_logic;
  signal trn_terrfwd_n : std_logic;

  -- Rx
  signal trn_rd : std_logic_vector(63 downto 0);
  signal trn_rrem_n : std_logic;
  signal trn_rrem_n_in : std_logic_vector(7 downto 0);
  signal trn_rsof_n : std_logic;
  signal trn_reof_n : std_logic;
  signal trn_rsrc_rdy_n : std_logic;
  signal trn_rsrc_dsc_n : std_logic;
  signal trn_rerrfwd_n : std_logic;
  signal trn_rbar_hit_n : std_logic_vector(6 downto 0);
  signal trn_rdst_rdy_n : std_logic;
  signal trn_rnp_ok_n : std_logic;

  signal trn_clk : std_logic;
  signal trn_reset_n : std_logic;
  signal trn_lnk_up_n : std_logic;

  ---------------------------------------------------------
  -- 3. Configuration (CFG) Interface
  ---------------------------------------------------------

  signal cfg_do : std_logic_vector(31 downto 0);
  signal cfg_rd_wr_done_n : std_logic;
  signal cfg_di : std_logic_vector(31 downto 0);
  signal cfg_byte_en_n : std_logic_vector(3 downto 0);
  signal cfg_dwaddr : std_logic_vector(9 downto 0);
  signal cfg_wr_en_n : std_logic;
  signal cfg_rd_en_n : std_logic;

  signal cfg_err_cor_n: std_logic;
  signal cfg_err_ur_n : std_logic;
  signal cfg_err_ecrc_n : std_logic;
  signal cfg_err_cpl_timeout_n : std_logic;
  signal cfg_err_cpl_abort_n : std_logic;
  signal cfg_err_cpl_unexpect_n : std_logic;
  signal cfg_err_posted_n : std_logic;
  signal cfg_err_tlp_cpl_header : std_logic_vector(47 downto 0);
  signal cfg_err_cpl_rdy_n : std_logic;
  signal cfg_interrupt_n : std_logic;
  signal cfg_interrupt_rdy_n : std_logic;
  signal cfg_interrupt_mmenable : std_logic_vector(2 downto 0);
  signal cfg_interrupt_msienable : std_logic;
  signal cfg_interrupt_msixenable : std_logic;
  signal cfg_interrupt_msixfm : std_logic;
  signal cfg_trn_pending_n : std_logic;
  signal cfg_status : std_logic_vector(15 downto 0);
  signal cfg_command : std_logic_vector(15 downto 0);
  signal cfg_dstatus : std_logic_vector(15 downto 0);
  signal cfg_dcommand : std_logic_vector(15 downto 0);
  signal cfg_lstatus : std_logic_vector(15 downto 0);
  signal cfg_lcommand : std_logic_vector(15 downto 0);
  signal cfg_pcie_link_state_n : std_logic_vector(2 downto 0);

  signal cfg_msg_received : std_logic;
  signal cfg_msg_data     : std_logic_vector(15 downto 0);
  signal cfg_msg_received_err_cor : std_logic;
  signal cfg_msg_received_err_non_fatal : std_logic;
  signal cfg_msg_received_err_fatal : std_logic;
  signal cfg_msg_received_pme_to_ack : std_logic;
  signal cfg_msg_received_assert_inta : std_logic;
  signal cfg_msg_received_assert_intb : std_logic;
  signal cfg_msg_received_assert_intc : std_logic;
  signal cfg_msg_received_assert_intd : std_logic;
  signal cfg_msg_received_deassert_inta : std_logic;
  signal cfg_msg_received_deassert_intb : std_logic;
  signal cfg_msg_received_deassert_intc : std_logic;
  signal cfg_msg_received_deassert_intd : std_logic;

  ---------------------------------------------------------
  -- 4. Physical Layer Control and Status (PL) Interface
  ---------------------------------------------------------

  signal pl_initial_link_width : std_logic_vector(2 downto 0);
  signal pl_lane_reversal_mode : std_logic_vector(1 downto 0);
  signal pl_link_gen2_capable : std_logic;
  signal pl_link_partner_gen2_supported : std_logic;
  signal pl_link_upcfg_capable : std_logic;
  signal pl_ltssm_state : std_logic_vector(5 downto 0);
  signal pl_sel_link_rate : std_logic;
  signal pl_sel_link_width : std_logic_vector(1 downto 0);
  signal pl_directed_link_auton : std_logic;
  signal pl_directed_link_change : std_logic_vector(1 downto 0);
  signal pl_directed_link_speed : std_logic;
  signal pl_directed_link_width : std_logic_vector(1 downto 0);
  signal pl_upstream_prefer_deemph : std_logic;

  -------------------------------------------------------

begin

  trn_trem_n                <= '1' when (trn_trem_n_out = X"0F") else
                               '0';
  trn_rrem_n_in             <= X"0F" when (trn_rrem_n = '1') else
                               X"00";

rport : pcie_2_0_rport_v6 
  generic map( 
     REF_CLK_FREQ                   => REF_CLK_FREQ,
     ALLOW_X8_GEN2                  => ALLOW_X8_GEN2,
     PL_FAST_TRAIN                  => PL_FAST_TRAIN,
     LINK_CAP_MAX_LINK_SPEED        => LINK_CAP_MAX_LINK_SPEED,
     DEVICE_ID                      => DEVICE_ID,
     LINK_CAP_MAX_LINK_WIDTH        => LINK_CAP_MAX_LINK_WIDTH,
     LINK_CAP_MAX_LINK_WIDTH_int    => LINK_CAP_MAX_LINK_WIDTH_int,
     LINK_CTRL2_TARGET_LINK_SPEED   => LINK_CTRL2_TARGET_LINK_SPEED,
     LTSSM_MAX_LINK_WIDTH           => LTSSM_MAX_LINK_WIDTH,
     DEV_CAP_MAX_PAYLOAD_SUPPORTED  => DEV_CAP_MAX_PAYLOAD_SUPPORTED,
     USER_CLK_FREQ                  => USER_CLK_FREQ,
     VC0_TX_LASTPACKET              => VC0_TX_LASTPACKET,
     VC0_RX_RAM_LIMIT               => VC0_RX_RAM_LIMIT,
     VC0_TOTAL_CREDITS_CD           => VC0_TOTAL_CREDITS_CD,
     VC0_TOTAL_CREDITS_PD           => VC0_TOTAL_CREDITS_CD
)
  port map(
  pci_exp_txp        =>  pci_exp_txp,
  pci_exp_txn        =>  pci_exp_txn,
  pci_exp_rxp        =>  pci_exp_rxp,
  pci_exp_rxn        =>  pci_exp_rxn,
  trn_clk            =>  trn_clk ,
  trn_reset_n        =>  trn_reset_n ,
  trn_lnk_up_n       =>  trn_lnk_up_n ,
  trn_tbuf_av        =>  trn_tbuf_av ,
  trn_tcfg_req_n     =>  open,
  trn_terr_drop_n    =>  trn_tdst_dsc_n ,
  trn_tdst_rdy_n     =>  trn_tdst_rdy_n ,
  trn_td             =>  trn_td ,
  trn_trem_n         =>  trn_trem_n,
  trn_tsof_n         =>  trn_tsof_n ,
  trn_teof_n         =>  trn_teof_n ,
  trn_tsrc_rdy_n     =>  trn_tsrc_rdy_n ,
  trn_tsrc_dsc_n     =>  trn_tsrc_dsc_n ,
  trn_terrfwd_n      =>  trn_terrfwd_n ,
  trn_tcfg_gnt_n     =>  '0' ,
  trn_tstr_n         =>  '1' ,
  trn_rd             =>  trn_rd ,
  trn_rrem_n         =>  trn_rrem_n ,
  trn_rsof_n         =>  trn_rsof_n ,
  trn_reof_n         =>  trn_reof_n ,
  trn_rsrc_rdy_n     =>  trn_rsrc_rdy_n ,
  trn_rsrc_dsc_n     =>  trn_rsrc_dsc_n ,
  trn_rerrfwd_n      =>  trn_rerrfwd_n ,
  trn_rbar_hit_n     =>  trn_rbar_hit_n ,
  trn_rdst_rdy_n     =>  trn_rdst_rdy_n ,
  trn_rnp_ok_n       =>  trn_rnp_ok_n ,
  trn_recrc_err_n    =>  open,
  trn_fc_cpld        =>  open,
  trn_fc_cplh        =>  open,
  trn_fc_npd         =>  open,
  trn_fc_nph         =>  open,
  trn_fc_pd          =>  open,
  trn_fc_ph          =>  open,
  trn_fc_sel         =>  "000" ,
  cfg_do             =>  cfg_do ,
  cfg_rd_wr_done_n   =>  cfg_rd_wr_done_n,
  cfg_di             =>  cfg_di ,
  cfg_byte_en_n      =>  cfg_byte_en_n ,
  cfg_dwaddr         =>  cfg_dwaddr ,
  cfg_wr_en_n        =>  cfg_wr_en_n ,
  cfg_wr_rw1c_as_rw_n  => '1',
  cfg_rd_en_n        =>  cfg_rd_en_n ,

  cfg_err_cor_n                   =>  cfg_err_cor_n ,
  cfg_err_ur_n                    =>  cfg_err_ur_n ,
  cfg_err_ecrc_n                  =>  cfg_err_ecrc_n ,
  cfg_err_cpl_timeout_n           =>  cfg_err_cpl_timeout_n ,
  cfg_err_cpl_abort_n             =>  cfg_err_cpl_abort_n ,
  cfg_err_cpl_unexpect_n          =>  cfg_err_cpl_unexpect_n ,
  cfg_err_posted_n                =>  cfg_err_posted_n ,
  cfg_err_locked_n                =>  '1',
  cfg_err_tlp_cpl_header          =>  cfg_err_tlp_cpl_header ,
  cfg_err_cpl_rdy_n               =>  open,
  cfg_interrupt_n                 =>  cfg_interrupt_n ,
  cfg_interrupt_rdy_n             =>  cfg_interrupt_rdy_n ,
  cfg_interrupt_assert_n          =>  '1' ,
  cfg_interrupt_di                =>  X"00" ,
  cfg_interrupt_do                =>  open,
  cfg_interrupt_mmenable          =>  open,
  cfg_interrupt_msienable         =>  open,
  cfg_interrupt_msixenable        =>  open,
  cfg_interrupt_msixfm            =>  open,
  cfg_trn_pending_n               =>  cfg_trn_pending_n ,
  cfg_pm_send_pme_to_n            =>  '1' ,
  cfg_status                      =>  cfg_status ,
  cfg_command                     =>  cfg_command ,
  cfg_dstatus                     =>  cfg_dstatus ,
  cfg_dcommand                    =>  cfg_dcommand ,
  cfg_lstatus                     =>  cfg_lstatus ,
  cfg_lcommand                    =>  cfg_lcommand ,
  cfg_dcommand2                   =>  open,
  cfg_pcie_link_state_n           =>  cfg_pcie_link_state_n ,
  cfg_dsn                         =>  (others => '0') ,
  cfg_pmcsr_pme_en                =>  open,
  cfg_pmcsr_pme_status            =>  open,
  cfg_pmcsr_powerstate            =>  open,
  cfg_msg_received                =>  cfg_msg_received ,
  cfg_msg_data                    =>  cfg_msg_data ,
  cfg_msg_received_err_cor        =>  cfg_msg_received_err_cor ,
  cfg_msg_received_err_non_fatal  =>  cfg_msg_received_err_non_fatal ,
  cfg_msg_received_err_fatal      =>  cfg_msg_received_err_fatal ,
  cfg_msg_received_pme_to_ack     =>  cfg_msg_received_pme_to_ack ,
  cfg_msg_received_assert_inta    =>  cfg_msg_received_assert_inta ,
  cfg_msg_received_assert_intb    =>  cfg_msg_received_assert_intb ,
  cfg_msg_received_assert_intc    =>  cfg_msg_received_assert_intc ,
  cfg_msg_received_assert_intd    =>  cfg_msg_received_assert_intd ,
  cfg_msg_received_deassert_inta  =>  cfg_msg_received_deassert_inta ,
  cfg_msg_received_deassert_intb  =>  cfg_msg_received_deassert_intb ,
  cfg_msg_received_deassert_intc  =>  cfg_msg_received_deassert_intc ,
  cfg_msg_received_deassert_intd  =>  cfg_msg_received_deassert_intd ,
  cfg_ds_bus_number               =>  X"00",
  cfg_ds_device_number            =>  "00000",
  pl_initial_link_width           =>  pl_initial_link_width ,
  pl_lane_reversal_mode           =>  pl_lane_reversal_mode ,
  pl_link_gen2_capable            =>  pl_link_gen2_capable ,
  pl_link_partner_gen2_supported  =>  pl_link_partner_gen2_supported ,
  pl_link_upcfg_capable           =>  pl_link_upcfg_capable ,
  pl_ltssm_state                  =>  pl_ltssm_state ,
  pl_sel_link_rate                =>  pl_sel_link_rate ,
  pl_sel_link_width               =>  pl_sel_link_width ,
  pl_directed_link_auton          =>  pl_directed_link_auton ,
  pl_directed_link_change         =>  pl_directed_link_change ,
  pl_directed_link_speed          =>  pl_directed_link_speed ,
  pl_directed_link_width          =>  pl_directed_link_width ,
  pl_upstream_prefer_deemph       =>  pl_upstream_prefer_deemph ,
  pl_transmit_hot_rst             =>  '0',
  pcie_drp_clk                    => '0',
  pcie_drp_den                    => '0',
  pcie_drp_dwe                    => '0',
  pcie_drp_daddr                  => "000000000",
  pcie_drp_di                     => X"0000",
  pcie_drp_do                     => open,
  pcie_drp_drdy                   => open,
  sys_clk                         =>  sys_clk ,
  sys_reset_n                     =>  sys_reset_n 

);

CFG_APP : pci_exp_usrapp_cfg
  port map (
    cfg_do                 => cfg_do,
    cfg_di                 => cfg_di,
    cfg_byte_en_n          => cfg_byte_en_n,
    cfg_dwaddr             => cfg_dwaddr,
    cfg_wr_en_n            => cfg_wr_en_n,
    cfg_rd_en_n            => cfg_rd_en_n,
    cfg_rd_wr_done_n       => cfg_rd_wr_done_n,
    cfg_err_cor_n          => cfg_err_cor_n,
    cfg_err_ur_n           => cfg_err_ur_n,
    cfg_err_ecrc_n         => cfg_err_ecrc_n,
    cfg_err_cpl_timeout_n  => cfg_err_cpl_timeout_n,
    cfg_err_cpl_abort_n    => cfg_err_cpl_abort_n,
    cfg_err_cpl_unexpect_n => cfg_err_cpl_unexpect_n,
    cfg_err_posted_n       => cfg_err_posted_n,
    cfg_err_tlp_cpl_header => cfg_err_tlp_cpl_header,
    cfg_interrupt_n        => cfg_interrupt_n,
    cfg_interrupt_rdy_n    => cfg_interrupt_rdy_n,
    cfg_turnoff_ok_n       => open,
    cfg_to_turnoff_n       => '1',
    cfg_pm_wake_n          => open,
    cfg_bus_number         => X"00",
    cfg_device_number      => "00000",
    cfg_function_number    => "000",
    cfg_status             => cfg_status,
    cfg_command            => cfg_command,
    cfg_dstatus            => cfg_dstatus,
    cfg_dcommand           => cfg_dcommand,
    cfg_lstatus            => cfg_lstatus,
    cfg_lcommand           => cfg_lcommand,
    cfg_pcie_link_state_n  => cfg_pcie_link_state_n,
    cfg_trn_pending_n      => cfg_trn_pending_n,
    trn_clk                => trn_clk,
    trn_reset_n            => trn_reset_n);


RX_APP : pci_exp_usrapp_rx_m2
  port map (
    trn_rdst_rdy_n        => trn_rdst_rdy_n,
    trn_rnp_ok_n          => trn_rnp_ok_n,
    trn_rd                => trn_rd,
    trn_rrem_n            => trn_rrem_n_in,
    trn_rsof_n            => trn_rsof_n,
    trn_reof_n            => trn_reof_n,
    trn_rsrc_rdy_n        => trn_rsrc_rdy_n,
    trn_rsrc_dsc_n        => trn_rsrc_dsc_n,
    trn_rerrfwd_n         => trn_rerrfwd_n,
    trn_rbar_hit_n        => trn_rbar_hit_n,
    trn_clk               => trn_clk,
    trn_reset_n           => trn_reset_n,
    trn_lnk_up_n          => trn_lnk_up_n,
    rx_tx_read_data       => rx_tx_read_data,
    rx_tx_read_data_valid => rx_tx_read_data_valid,
    tx_rx_read_data_valid => tx_rx_read_data_valid);

TX_APP : pci_exp_usrapp_tx_m2
  port map (
    trn_td                => trn_td,
    trn_trem_n            => trn_trem_n_out,
    trn_tsof_n            => trn_tsof_n,
    trn_teof_n            => trn_teof_n,
    trn_terrfwd_n         => trn_terrfwd_n,
    trn_tsrc_rdy_n        => trn_tsrc_rdy_n,
    trn_tsrc_dsc_n        => trn_tsrc_dsc_n,
    trn_clk               => trn_clk,
    trn_reset_n           => trn_reset_n,
    trn_lnk_up_n          => trn_lnk_up_n,
    trn_tdst_rdy_n        => trn_tdst_rdy_n,
    trn_tdst_dsc_n        => trn_tdst_dsc_n,
    trn_tbuf_av           => trn_tbuf_av,
    speed_change_done_n   => speed_change_done_n,
    rx_tx_read_data       => rx_tx_read_data,
    rx_tx_read_data_valid => rx_tx_read_data_valid,
    tx_rx_read_data_valid => tx_rx_read_data_valid,

	cmd		=> cmd,
	ret		=> ret
	
);

PL_APP : pci_exp_usrapp_pl
  generic map (
    LINK_CAP_MAX_LINK_SPEED => LINK_CAP_MAX_LINK_SPEED_int)
  port map (
    pl_initial_link_width          => pl_initial_link_width,
    pl_lane_reversal_mode          => pl_lane_reversal_mode,
    pl_link_gen2_capable           => pl_link_gen2_capable,
    pl_link_partner_gen2_supported => pl_link_partner_gen2_supported,
    pl_link_upcfg_capable          => pl_link_upcfg_capable,
    pl_ltssm_state                 => pl_ltssm_state,
    pl_received_hot_rst            => '0',
    pl_sel_link_rate               => pl_sel_link_rate,
    pl_sel_link_width              => pl_sel_link_width,
    pl_directed_link_auton         => pl_directed_link_auton,
    pl_directed_link_change        => pl_directed_link_change,
    pl_directed_link_speed         => pl_directed_link_speed,
    pl_directed_link_width         => pl_directed_link_width,
    pl_upstream_prefer_deemph      => pl_upstream_prefer_deemph,
    speed_change_done_n            => speed_change_done_n,
    trn_lnk_up_n                   => trn_lnk_up_n,
    trn_clk                        => trn_clk,
    trn_reset_n                    => trn_reset_n);

end rtl;
