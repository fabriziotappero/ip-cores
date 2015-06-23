-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_infrastructure.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Instantiates the DCM of the FPGA device. The system clock is
--              given as the input and two clocks that are phase shifted by
--              90 degrees are taken out. It also give the reset signals in
--              phase with the clocks.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_infrastructure is
  port (
      idelay_ctrl_rdy  : in std_logic;
     sys_clk_n         : in std_logic;
          sys_clk_p         : in std_logic;
          clk200_n          : in std_logic;
          clk200_p          : in std_logic;
			 clk_100_top				: in std_logic;
			 clk_200_top				: in std_logic;
          sys_reset_in_n    : in std_logic;

     clk               : out std_logic;
          clk90             : out std_logic;
          clk200            : out std_logic;
      sys_rst    : out std_logic;
      sys_rst90  : out std_logic;
      sys_rst_r1 : out std_logic
      );
end MIG_infrastructure;

architecture arch of MIG_infrastructure is

signal clk0_bufg_in     : std_logic;
signal clk90_bufg_in    : std_logic;
signal clk0_bufg_out    : std_logic;
signal clk90_bufg_out   : std_logic;
signal clk0_bufg1_out   : std_logic;
--signal sys_clk_in       : std_logic;
signal dcm_lock           : std_logic;



  constant RST_SYNC_NUM        : integer := 12;

  signal rst0_sync_r           : std_logic_vector((RST_SYNC_NUM -1) downto 0);
  signal rst200_sync_r         : std_logic_vector((RST_SYNC_NUM -1) downto 0);
  signal rst90_sync_r          : std_logic_vector((RST_SYNC_NUM -1) downto 0);
  signal rst_tmp               : std_logic;
--  signal ref_clk200_in         : std_logic;
  signal sys_reset             : std_logic;

  constant add_const           : std_logic_vector(15 downto 0) := X"FFFF" ;


begin

  clk         <= clk0_bufg_out;
clk90       <= clk90_bufg_out;
clk200       <= clk0_bufg1_out;

  sys_reset   <= (not sys_reset_in_n) when (reset_active_low = '1') else
                  sys_reset_in_n;

  
  

--lvds_sys_clk_input: IBUFGDS_LVPECL_25
--  port map (
--          I  => sys_clk_p,
--          IB => sys_clk_n,
--          O  => sys_clk_in
--        );
--
--lvpecl_clk200_in: IBUFGDS_LVPECL_25
--  port map (
--          I  => clk200_p,
--          IB => clk200_n,
--          O  => ref_clk200_in
--        );

DCM_BASE0: DCM_BASE
    generic map(
             CLKDV_DIVIDE      => 16.0,
             CLKFX_DIVIDE      => 8,
             CLKFX_MULTIPLY    => 2,
             DCM_PERFORMANCE_MODE  => "MAX_SPEED",
             DFS_FREQUENCY_MODE    => "LOW",
             DLL_FREQUENCY_MODE    => "LOW",
             DUTY_CYCLE_CORRECTION => TRUE,
             FACTORY_JF            => X"F0F0"
           )
    port map(
          CLK0      => clk0_bufg_in,
          CLK180    => open,
          CLK270    => open,
          CLK2X     => open,
          CLK2X180  => open,
          CLK90     => clk90_bufg_in,
          CLKDV     => open,
          CLKFX     => open,
          CLKFX180  => open,
          LOCKED    => dcm_lock,
          CLKFB     => clk0_bufg_out,
          CLKIN     => clk_100_top,
          RST       => sys_reset
        );

  dcm_clk0: BUFG
    port map (
      O => clk0_bufg_out,
      I => clk0_bufg_in
    );

  dcm_clk90: BUFG
    port map (
      O => clk90_bufg_out,
      I => clk90_bufg_in
    );

  dcm1_clk0: BUFG
    port map (
      O => clk0_bufg1_out,
      I => clk_200_top
      );


  rst_tmp  <= (not dcm_lock) or (not idelay_ctrl_rdy) or (sys_reset);

  process(clk0_bufg_out, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rst0_sync_r <= add_const(RST_SYNC_NUM-1 downto 0);
    elsif (clk0_bufg_out'event and clk0_bufg_out = '1') then
      rst0_sync_r(RST_SYNC_NUM-1 downto 1) <= rst0_sync_r(RST_SYNC_NUM-2 downto 0);
      rst0_sync_r(0) <= '0';
    end if;
  end process;

  process(clk90_bufg_out, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rst90_sync_r <= add_const(RST_SYNC_NUM-1 downto 0);
    elsif (clk90_bufg_out'event and clk90_bufg_out = '1') then
      rst90_sync_r(RST_SYNC_NUM-1 downto 1) <= rst90_sync_r(RST_SYNC_NUM-2 downto 0);
      rst90_sync_r(0) <= '0';
    end if;
  end process;

  process(clk0_bufg1_out, dcm_lock)
  begin
    if (dcm_lock = '0') then
      rst200_sync_r <= add_const(RST_SYNC_NUM-1 downto 0);
    elsif (clk0_bufg1_out'event and clk0_bufg1_out = '1') then
      rst200_sync_r(RST_SYNC_NUM-1 downto 1) <= rst200_sync_r(RST_SYNC_NUM-2 downto 0);
      rst200_sync_r(0) <= '0';
    end if;
  end process;


  sys_rst    <= rst0_sync_r(RST_SYNC_NUM-1);
  sys_rst90  <= rst90_sync_r(RST_SYNC_NUM-1);
  sys_rst_r1 <= rst200_sync_r(RST_SYNC_NUM-1);

end arch;
