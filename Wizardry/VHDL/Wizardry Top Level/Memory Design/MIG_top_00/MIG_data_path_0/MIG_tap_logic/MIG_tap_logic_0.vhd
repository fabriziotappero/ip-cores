-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_tap_logic_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Instantiates the tap_cntrl and the data_tap_inc modules.
--              Used for calibration of the memory data with the FPGA clock.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_tap_logic_0 is
  port(
    clk                  : in  std_logic;
    reset0               : in  std_logic;
    idelay_ctrl_rdy      : in  std_logic;
    ctrl_dummyread_start : in  std_logic;
    dqs_delayed          : in  std_logic_vector((DATA_STROBE_WIDTH - 1) downto 0);
    sel_done             : out std_logic;
    data_idelay_inc      : out std_logic_vector((READENABLE - 1) downto 0);
    data_idelay_ce       : out std_logic_vector((READENABLE - 1) downto 0);
    data_idelay_rst      : out std_logic_vector((READENABLE - 1) downto 0);
    dqs_idelay_inc       : out std_logic_vector((READENABLE - 1) downto 0);
    dqs_idelay_ce        : out std_logic_vector((READENABLE - 1) downto 0);
    dqs_idelay_rst       : out std_logic_vector((READENABLE - 1) downto 0)
    );
end MIG_tap_logic_0;

architecture arch of MIG_tap_logic_0 is

  component MIG_tap_ctrl
    port(
      clk                  : in  std_logic;
      reset                : in  std_logic;
      rdy_status           : in  std_logic;
      dqs                  : in  std_logic;
      ctrl_dummyread_start : in  std_logic;
      dlyinc               : out std_logic;
      dlyce                : out std_logic;
      dlyrst               : out std_logic;
      sel_done             : out std_logic;
      valid_data_tap_count : out std_logic;
      data_tap_count       : out std_logic_vector(5 downto 0)
      );
  end component;

  component MIG_data_tap_inc
    port(
      clk                  : in  std_logic;
      reset                : in  std_logic;
      data_dlyinc          : out std_logic;
      data_dlyce           : out std_logic;
      data_dlyrst          : out std_logic;
      data_tap_sel_done    : out std_logic;
      dqs_sel_done         : in  std_logic;
      valid_data_tap_count : in  std_logic;
      data_tap_count       : in  std_logic_vector(5 downto 0)
      );
  end component;

  signal data_tap_select   : std_logic_vector((READENABLE - 1) downto 0);
  signal dqs_tap_sel_done  : std_logic_vector((READENABLE - 1) downto 0);
  signal valid_tap_count   : std_logic_vector((READENABLE - 1) downto 0);
  signal data_tap_inc_done : std_logic;
  signal tap_sel_done      : std_logic;
  signal rst_r             : std_logic;
  
signal data_tap_count0    : std_logic_vector(5 downto 0);


begin

  -- For controller to stop dummy reads
  sel_done <= tap_sel_done;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      rst_r <= reset0;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if (rst_r = '1') then
        data_tap_inc_done <= '0';
        tap_sel_done      <= '0';
      else
        data_tap_inc_done <=  data_tap_select(0) ;
        tap_sel_done      <= data_tap_inc_done;

      end if;
    end if;
  end process;

  --**********************************************************************
  --  tap_ctrl instances for  ddr_dqs strobes
  --**********************************************************************

  
tap_ctrl_0: MIG_tap_ctrl
  port map (
          clk                       => clk,
          reset                     => reset0,
          rdy_status                => idelay_ctrl_rdy,
          dqs                       => dqs_delayed(3),
          ctrl_dummyread_start      => ctrl_dummyread_start,
          dlyinc                    => dqs_idelay_inc(0),
          dlyce                     => dqs_idelay_ce(0),
          dlyrst                    => dqs_idelay_rst(0),
          sel_done                  => dqs_tap_sel_done(0),
          valid_data_tap_count      => valid_tap_count(0),
          data_tap_count            => data_tap_count0(5 downto 0)
       );


  --**********************************************************************
  --  instances of data_tap_inc for each dqs and associated tap_ctrl
  --**********************************************************************

  
data_tap_inc_0: MIG_data_tap_inc
  port map (
        clk                     => clk,
        reset                   => reset0,
        data_dlyinc             => data_idelay_inc(0),
        data_dlyce              => data_idelay_ce(0),
        data_dlyrst             => data_idelay_rst(0),
        data_tap_sel_done       => data_tap_select(0),
        dqs_sel_done            => dqs_tap_sel_done(0),
        valid_data_tap_count    => valid_tap_count(0),
        data_tap_count          => data_tap_count0(5 downto 0)
             );


end arch;
