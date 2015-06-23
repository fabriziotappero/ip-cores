-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_rd_data_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: The delay between the read data with respect to the command
--              issued is calculted in terms of no. of clocks. This data is
--              then stored into the FIFOs and then read back and given as
--              the ouput for comparison.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_rd_data_0 is
  port(
    clk                 : in  std_logic;
    reset               : in  std_logic;
    ctrl_rden           : in  std_logic;
    read_data_rise      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    read_data_fall      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    read_data_fifo_rise : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    read_data_fifo_fall : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    comp_done           : out std_logic;
    read_data_valid     : out std_logic
    );
end MIG_rd_data_0;

architecture arch of MIG_rd_data_0 is

  component MIG_rd_data_fifo_0
    port(
      clk                  : in  std_logic;
      reset                : in  std_logic;
      read_en_delayed_rise : in  std_logic;
      read_en_delayed_fall : in  std_logic;
      first_rising         : in  std_logic;
      read_data_rise       : in  std_logic_vector(MEMORY_WIDTH - 1 downto 0);
      read_data_fall       : in  std_logic_vector(MEMORY_WIDTH - 1 downto 0);
      fifo_rd_enable       : in  std_logic;
      read_data_fifo_rise  : out std_logic_vector(MEMORY_WIDTH - 1 downto 0);
      read_data_fifo_fall  : out std_logic_vector(MEMORY_WIDTH - 1 downto 0);
      read_data_valid      : out std_logic
      );
  end component;

  component MIG_pattern_compare8
    port(
      clk            : in  std_logic;
      rst            : in  std_logic;
      ctrl_rden      : in  std_logic;
      rd_data_rise   : in  std_logic_vector(7 downto 0);
      rd_data_fall   : in  std_logic_vector(7 downto 0);
      comp_done      : out std_logic;
      first_rising   : out std_logic;
      rise_clk_count : out std_logic_vector(2 downto 0);
      fall_clk_count : out std_logic_vector(2 downto 0)
      );
  end component;

  component MIG_pattern_compare4
    port(
      clk            : in  std_logic;
      rst            : in  std_logic;
      ctrl_rden      : in  std_logic;
      rd_data_rise   : in  std_logic_vector(3 downto 0);
      rd_data_fall   : in  std_logic_vector(3 downto 0);
      comp_done      : out std_logic;
      first_rising   : out std_logic;
      rise_clk_count : out std_logic_vector(2 downto 0);
      fall_clk_count : out std_logic_vector(2 downto 0)
      );
  end component;

  signal rd_en_r1          : std_logic_vector(READENABLE - 1 downto 0);
  signal rd_en_r2          : std_logic_vector(READENABLE - 1 downto 0);
  signal rd_en_r3          : std_logic_vector(READENABLE - 1 downto 0);
  signal rd_en_r4          : std_logic_vector(READENABLE - 1 downto 0);
  signal rd_en_r5          : std_logic_vector(READENABLE - 1 downto 0);
  signal rd_en_r6          : std_logic_vector(READENABLE - 1 downto 0);
  signal comp_done_r       : std_logic;
  signal comp_done_r1      : std_logic;
  signal comp_done_r2      : std_logic;
  signal rd_en_rise        : std_logic_vector(DATA_STROBE_WIDTH - 1 downto 0);
  signal rd_en_fall        : std_logic_vector(DATA_STROBE_WIDTH - 1 downto 0);
  signal ctrl_rden1        : std_logic_vector(READENABLE - 1 downto 0);
  signal first_rising_rden : std_logic_vector(READENABLE - 1 downto 0);
  signal fifo_rd_enable1   : std_logic;
  signal fifo_rd_enable    : std_logic;
  signal rst_r             : std_logic;
  
signal read_data_valid0        : std_logic;


signal read_data_valid1        : std_logic;


signal read_data_valid2        : std_logic;


signal read_data_valid3        : std_logic;

  signal comp_done_0 : std_logic; 
  signal rise_clk_count0 : std_logic_vector(2 downto 0);
signal fall_clk_count0 : std_logic_vector(2 downto 0);


begin

   ctrl_rden1(0) <= ctrl_rden; 

  read_data_valid <= read_data_valid0;

  pattern_0 : MIG_pattern_compare8
 port map (
            clk             =>   clk,
            rst             =>   reset,
            ctrl_rden       =>   ctrl_rden1(0),
            rd_data_rise    =>   read_data_rise(31  downto  24),
            rd_data_fall    =>   read_data_fall(31  downto  24),
            comp_done       =>   comp_done_0,
            first_rising    =>   first_rising_rden(0),
            rise_clk_count  =>   rise_clk_count0,
            fall_clk_count  =>   fall_clk_count0
        );


  process(clk)
  begin
    if(clk'event and clk = '1') then
      rst_r <= reset;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        rd_en_r1 <= (others => '0');
        rd_en_r2 <= (others => '0');
        rd_en_r3 <= (others => '0');
        rd_en_r4 <= (others => '0');
        rd_en_r5 <= (others => '0');
        rd_en_r6 <= (others => '0');
      else
        rd_en_r1 <= ctrl_rden1;
        rd_en_r2 <= rd_en_r1;
        rd_en_r3 <= rd_en_r2;
        rd_en_r4 <= rd_en_r3;
        rd_en_r5 <= rd_en_r4;
        rd_en_r6 <= rd_en_r5;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        comp_done_r  <= '0';
        comp_done_r1 <= '0';
        comp_done_r2 <= '0';
      else
        comp_done_r  <=  comp_done_0 ;
        comp_done_r1 <= comp_done_r;
        comp_done_r2 <= comp_done_r1;
      end if;
    end if;
  end process;

  comp_done <= '0' when rst_r = '1' else
                comp_done_0 ;

  
process(CLK)
begin
if(CLK'event and CLK = '1') then
 if(rst_r = '1') then
    rd_en_rise(0) <= '0';
 elsif(comp_done_r2 = '1') then
  case rise_clk_count0 is
    when "011" =>
        rd_en_rise(0) <= rd_en_r2(0);

    when "100" =>
        rd_en_rise(0) <= rd_en_r3(0);

    when "101" =>
        rd_en_rise(0) <= rd_en_r4(0);

    when "110" =>
        rd_en_rise(0) <= rd_en_r5(0);

    when "111" =>
        rd_en_rise(0) <= rd_en_r6(0);

    when others =>
        rd_en_rise(0) <= '0';
  end case;
 end if;
end if;
end process;

process(CLK)
begin
if(CLK'event and CLK = '1') then
 if(rst_r = '1') then
    rd_en_fall(0) <= '0';
 elsif(comp_done_r2 = '1') then
  case fall_clk_count0 is
    when "011" =>
        rd_en_fall(0) <= rd_en_r2(0);

    when "100" =>
        rd_en_fall(0) <= rd_en_r3(0);

    when "101" =>
        rd_en_fall(0) <= rd_en_r4(0);

    when "110" =>
        rd_en_fall(0) <= rd_en_r5(0);

    when "111" =>
        rd_en_fall(0) <= rd_en_r6(0);

    when others =>
        rd_en_fall(0) <= '0';
  end case;
 end if;
end if;
end process;


process(CLK)
begin
if(CLK'event and CLK = '1') then
 if(rst_r = '1') then
    rd_en_rise(1) <= '0';
 elsif(comp_done_r2 = '1') then
  case rise_clk_count0 is
    when "011" =>
        rd_en_rise(1) <= rd_en_r2(0);

    when "100" =>
        rd_en_rise(1) <= rd_en_r3(0);

    when "101" =>
        rd_en_rise(1) <= rd_en_r4(0);

    when "110" =>
        rd_en_rise(1) <= rd_en_r5(0);

    when "111" =>
        rd_en_rise(1) <= rd_en_r6(0);

    when others =>
        rd_en_rise(1) <= '0';
  end case;
 end if;
end if;
end process;

process(CLK)
begin
if(CLK'event and CLK = '1') then
 if(rst_r = '1') then
    rd_en_fall(1) <= '0';
 elsif(comp_done_r2 = '1') then
  case fall_clk_count0 is
    when "011" =>
        rd_en_fall(1) <= rd_en_r2(0);

    when "100" =>
        rd_en_fall(1) <= rd_en_r3(0);

    when "101" =>
        rd_en_fall(1) <= rd_en_r4(0);

    when "110" =>
        rd_en_fall(1) <= rd_en_r5(0);

    when "111" =>
        rd_en_fall(1) <= rd_en_r6(0);

    when others =>
        rd_en_fall(1) <= '0';
  end case;
 end if;
end if;
end process;


process(CLK)
begin
if(CLK'event and CLK = '1') then
 if(rst_r = '1') then
    rd_en_rise(2) <= '0';
 elsif(comp_done_r2 = '1') then
  case rise_clk_count0 is
    when "011" =>
        rd_en_rise(2) <= rd_en_r2(0);

    when "100" =>
        rd_en_rise(2) <= rd_en_r3(0);

    when "101" =>
        rd_en_rise(2) <= rd_en_r4(0);

    when "110" =>
        rd_en_rise(2) <= rd_en_r5(0);

    when "111" =>
        rd_en_rise(2) <= rd_en_r6(0);

    when others =>
        rd_en_rise(2) <= '0';
  end case;
 end if;
end if;
end process;

process(CLK)
begin
if(CLK'event and CLK = '1') then
 if(rst_r = '1') then
    rd_en_fall(2) <= '0';
 elsif(comp_done_r2 = '1') then
  case fall_clk_count0 is
    when "011" =>
        rd_en_fall(2) <= rd_en_r2(0);

    when "100" =>
        rd_en_fall(2) <= rd_en_r3(0);

    when "101" =>
        rd_en_fall(2) <= rd_en_r4(0);

    when "110" =>
        rd_en_fall(2) <= rd_en_r5(0);

    when "111" =>
        rd_en_fall(2) <= rd_en_r6(0);

    when others =>
        rd_en_fall(2) <= '0';
  end case;
 end if;
end if;
end process;


process(CLK)
begin
if(CLK'event and CLK = '1') then
 if(rst_r = '1') then
    rd_en_rise(3) <= '0';
 elsif(comp_done_r2 = '1') then
  case rise_clk_count0 is
    when "011" =>
        rd_en_rise(3) <= rd_en_r2(0);

    when "100" =>
        rd_en_rise(3) <= rd_en_r3(0);

    when "101" =>
        rd_en_rise(3) <= rd_en_r4(0);

    when "110" =>
        rd_en_rise(3) <= rd_en_r5(0);

    when "111" =>
        rd_en_rise(3) <= rd_en_r6(0);

    when others =>
        rd_en_rise(3) <= '0';
  end case;
 end if;
end if;
end process;

process(CLK)
begin
if(CLK'event and CLK = '1') then
 if(rst_r = '1') then
    rd_en_fall(3) <= '0';
 elsif(comp_done_r2 = '1') then
  case fall_clk_count0 is
    when "011" =>
        rd_en_fall(3) <= rd_en_r2(0);

    when "100" =>
        rd_en_fall(3) <= rd_en_r3(0);

    when "101" =>
        rd_en_fall(3) <= rd_en_r4(0);

    when "110" =>
        rd_en_fall(3) <= rd_en_r5(0);

    when "111" =>
        rd_en_fall(3) <= rd_en_r6(0);

    when others =>
        rd_en_fall(3) <= '0';
  end case;
 end if;
end if;
end process;


  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        fifo_rd_enable1 <= '0';
        fifo_rd_enable  <= '0';
      else
        fifo_rd_enable1 <= rd_en_rise(0);
        fifo_rd_enable  <= fifo_rd_enable1;
      end if;
    end if;
  end process;

  
  rd_data_fifo0: MIG_rd_data_fifo_0
    port map (
          clk                   => clk,
          reset                 => reset,
          read_en_delayed_rise  => rd_en_rise(0),
          read_en_delayed_fall  => rd_en_fall(0),
          first_rising          => first_rising_rden(0),
          read_data_rise        => read_data_rise(7 downto 0),
          read_data_fall        => read_data_fall(7 downto 0),
          fifo_rd_enable        => fifo_rd_enable,
          read_data_fifo_rise   => read_data_fifo_rise(7 downto 0),
          read_data_fifo_fall   => read_data_fifo_fall(7 downto 0),
          read_data_valid       => read_data_valid0
        );


  rd_data_fifo1: MIG_rd_data_fifo_0
    port map (
          clk                   => clk,
          reset                 => reset,
          read_en_delayed_rise  => rd_en_rise(1),
          read_en_delayed_fall  => rd_en_fall(1),
          first_rising          => first_rising_rden(0),
          read_data_rise        => read_data_rise(15 downto 8),
          read_data_fall        => read_data_fall(15 downto 8),
          fifo_rd_enable        => fifo_rd_enable,
          read_data_fifo_rise   => read_data_fifo_rise(15 downto 8),
          read_data_fifo_fall   => read_data_fifo_fall(15 downto 8),
          read_data_valid       => read_data_valid1
        );


  rd_data_fifo2: MIG_rd_data_fifo_0
    port map (
          clk                   => clk,
          reset                 => reset,
          read_en_delayed_rise  => rd_en_rise(2),
          read_en_delayed_fall  => rd_en_fall(2),
          first_rising          => first_rising_rden(0),
          read_data_rise        => read_data_rise(23 downto 16),
          read_data_fall        => read_data_fall(23 downto 16),
          fifo_rd_enable        => fifo_rd_enable,
          read_data_fifo_rise   => read_data_fifo_rise(23 downto 16),
          read_data_fifo_fall   => read_data_fifo_fall(23 downto 16),
          read_data_valid       => read_data_valid2
        );


  rd_data_fifo3: MIG_rd_data_fifo_0
    port map (
          clk                   => clk,
          reset                 => reset,
          read_en_delayed_rise  => rd_en_rise(3),
          read_en_delayed_fall  => rd_en_fall(3),
          first_rising          => first_rising_rden(0),
          read_data_rise        => read_data_rise(31 downto 24),
          read_data_fall        => read_data_fall(31 downto 24),
          fifo_rd_enable        => fifo_rd_enable,
          read_data_fifo_rise   => read_data_fifo_rise(31 downto 24),
          read_data_fifo_fall   => read_data_fifo_fall(31 downto 24),
          read_data_valid       => read_data_valid3
        );


end arch;
