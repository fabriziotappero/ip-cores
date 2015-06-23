-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: It is the top most module which interfaces with the system and
--              the memory.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG is
  port(
    cntrl0_ddr_dq                        : inout  std_logic_vector(31 downto 0);
    cntrl0_ddr_a                         : out  std_logic_vector(12 downto 0);
    cntrl0_ddr_ba                        : out  std_logic_vector(1 downto 0);
    cntrl0_ddr_cke                       : out std_logic;
    cntrl0_ddr_cs_n                      : out std_logic;
    cntrl0_ddr_ras_n                     : out std_logic;
    cntrl0_ddr_cas_n                     : out std_logic;
    cntrl0_ddr_we_n                      : out std_logic;
    cntrl0_ddr_dm                        : out  std_logic_vector(3 downto 0);
    sys_clk_p                            : in std_logic;
    sys_clk_n                            : in std_logic;
    clk200_p                             : in std_logic;
    clk200_n                             : in std_logic;
	 clk_100_top				: in std_logic;
	 clk_200_top				: in std_logic;
    init_done                            : out std_logic;
    sys_reset_in_n                       : in std_logic;
    cntrl0_clk_tb                        : out std_logic;
    cntrl0_reset_tb                      : out std_logic;
    cntrl0_wdf_almost_full               : out std_logic;
    cntrl0_af_almost_full                : out std_logic;
    cntrl0_read_data_valid               : out std_logic;
    cntrl0_app_wdf_wren                  : in std_logic;
    cntrl0_app_af_wren                   : in std_logic;
    cntrl0_burst_length_div2             : out  std_logic_vector(2 downto 0);
    cntrl0_app_af_addr                   : in  std_logic_vector(35 downto 0);
    cntrl0_app_wdf_data                  : in  std_logic_vector(63 downto 0);
    cntrl0_read_data_fifo_out            : out  std_logic_vector(63 downto 0);
    cntrl0_app_mask_data                 : in  std_logic_vector(7 downto 0);
    cntrl0_ddr_dqs                       : inout  std_logic_vector(3 downto 0);
    cntrl0_ddr_ck                        : out  std_logic_vector(1 downto 0);
    cntrl0_ddr_ck_n                      : out  std_logic_vector(1 downto 0)
         );
end MIG;

architecture arc_mem_interface_top of MIG is

  component MIG_top_0  port (
   ddr_dq                         : inout  std_logic_vector(31 downto 0);
   ddr_a                          : out  std_logic_vector(12 downto 0);
   ddr_ba                         : out  std_logic_vector(1 downto 0);
   ddr_cke                        : out std_logic;
   ddr_cs_n                       : out std_logic;
   ddr_ras_n                      : out std_logic;
   ddr_cas_n                      : out std_logic;
   ddr_we_n                       : out std_logic;
   ddr_dm                         : out  std_logic_vector(3 downto 0);
   init_done                      : out std_logic;
   clk_tb                         : out std_logic;
   reset_tb                       : out std_logic;
   wdf_almost_full                : out std_logic;
   af_almost_full                 : out std_logic;
   read_data_valid                : out std_logic;
   app_wdf_wren                   : in std_logic;
   app_af_wren                    : in std_logic;
   burst_length_div2              : out  std_logic_vector(2 downto 0);
   app_af_addr                    : in  std_logic_vector(35 downto 0);
   app_wdf_data                   : in  std_logic_vector(63 downto 0);
   read_data_fifo_out             : out  std_logic_vector(63 downto 0);
   app_mask_data                  : in  std_logic_vector(7 downto 0);
   ddr_dqs                        : inout  std_logic_vector(3 downto 0);
   ddr_ck                         : out  std_logic_vector(1 downto 0);
   ddr_ck_n                       : out  std_logic_vector(1 downto 0);
   
   clk_0                          : in std_logic;   
   clk_90                         : in std_logic;   
   sys_rst                        : in std_logic;   
   sys_rst90                      : in std_logic;   
   idelay_ctrl_rdy                : in std_logic

   );
end component;

  component MIG_infrastructure
    port(
      idelay_ctrl_rdy                : in std_logic;
      clk                            : out std_logic;
      clk90                          : out std_logic;
      clk200                         : out std_logic;
      sys_rst                        : out std_logic;
      sys_rst90                      : out std_logic;
      sys_rst_r1                     : out std_logic;
      sys_clk_p                      : in std_logic;
      sys_clk_n                      : in std_logic;
      clk200_p                       : in std_logic;
      clk200_n                       : in std_logic;
		clk_100_top				: in std_logic;
		clk_200_top				: in std_logic;
      sys_reset_in_n                 : in std_logic
      );
  end component;

  component MIG_idelay_ctrl
    port(
      clk200     : in  std_logic;
      reset      : in  std_logic;
      rdy_status : out std_logic
      );
  end component;



  signal clk_0           : std_logic;
  signal clk_90          : std_logic;
  signal clk_200         : std_logic;
  signal sys_rst         : std_logic;
  signal sys_rst90       : std_logic;
  signal idelay_ctrl_rdy : std_logic;
  signal sys_rst_r1      : std_logic;

  attribute syn_useioff : boolean ;
  attribute syn_useioff of arc_mem_interface_top : architecture is true;

begin

  top_00 :    MIG_top_0 port map (
   ddr_dq                         => cntrl0_ddr_dq,
   ddr_a                          => cntrl0_ddr_a,
   ddr_ba                         => cntrl0_ddr_ba,
   ddr_cke                        => cntrl0_ddr_cke,
   ddr_cs_n                       => cntrl0_ddr_cs_n,
   ddr_ras_n                      => cntrl0_ddr_ras_n,
   ddr_cas_n                      => cntrl0_ddr_cas_n,
   ddr_we_n                       => cntrl0_ddr_we_n,
   ddr_dm                         => cntrl0_ddr_dm,
   init_done                      => init_done,
   clk_tb                         => cntrl0_clk_tb,
   reset_tb                       => cntrl0_reset_tb,
   wdf_almost_full                => cntrl0_wdf_almost_full,
   af_almost_full                 => cntrl0_af_almost_full,
   read_data_valid                => cntrl0_read_data_valid,
   app_wdf_wren                   => cntrl0_app_wdf_wren,
   app_af_wren                    => cntrl0_app_af_wren,
   burst_length_div2              => cntrl0_burst_length_div2,
   app_af_addr                    => cntrl0_app_af_addr,
   app_wdf_data                   => cntrl0_app_wdf_data,
   read_data_fifo_out             => cntrl0_read_data_fifo_out,
   app_mask_data                  => cntrl0_app_mask_data,
   ddr_dqs                        => cntrl0_ddr_dqs,
   ddr_ck                         => cntrl0_ddr_ck,
   ddr_ck_n                       => cntrl0_ddr_ck_n,
   
   clk_0                          => clk_0,
   clk_90                         => clk_90,
   idelay_ctrl_rdy                => idelay_ctrl_rdy,
   sys_rst                        => sys_rst,
   sys_rst90                      => sys_rst90
   );


  infrastructure0 : MIG_infrastructure
    port map (
      clk                            => clk_0,
      clk90                          => clk_90,
      clk200                         => clk_200,
      idelay_ctrl_rdy                => idelay_ctrl_rdy,
      sys_rst                        => sys_rst,
      sys_rst90                      => sys_rst90,
      sys_rst_r1                     => sys_rst_r1,
      sys_clk_p                      => sys_clk_p,
      sys_clk_n                      => sys_clk_n,
      clk200_p                       => clk200_p,
      clk200_n                       => clk200_n,
		clk_100_top				=> clk_100_top,
		clk_200_top				=> clk_200_top,
		
      sys_reset_in_n                 => sys_reset_in_n
      );

  idelay_ctrl0 : MIG_idelay_ctrl
    port map (
      clk200     => clk_200,
      reset      => sys_rst_r1,
      rdy_status => idelay_ctrl_rdy
      );

end arc_mem_interface_top;
