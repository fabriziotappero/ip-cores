-------------------------------------------------------------------------------
-- Title      : Top entity of heap-sorter
-- Project    : heap-sorter
-------------------------------------------------------------------------------
-- File       : sorter_sys.vhd
-- Author     : Wojciech M. Zabolotny <wzab@ise.pw.edu.pl>
-- Company    : 
-- Created    : 2010-05-14
-- Last update: 2011-07-11
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 Wojciech M. Zabolotny
-- This file is published under the BSD license, so you can freely adapt
-- it for your own purposes.
-- Additionally this design has been described in my article
-- Additionally this design has been described in my article:
--    Wojciech M. Zabolotny, "Dual port memory based Heapsort implementation
--    for FPGA", Proc. SPIE 8008, 80080E (2011); doi:10.1117/12.905281
-- I'd be glad if you cite this article when you publish something based
-- on my design.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-05-14  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
library work;
use work.sorter_pkg.all;
use work.sys_config.all;

entity sorter_sys is
  generic (
    NLEVELS : integer := SYS_NLEVELS     -- number of levels in the sorter heap
    );

  port (
    din   : in  T_DATA_REC;
    we    : in  std_logic;
    dout  : out T_DATA_REC;
    dav   : out std_logic;
    clk   : in  std_logic;
    rst_n : in  std_logic;
    ready : out std_logic);
end sorter_sys;

architecture sorter_sys_arch1 of sorter_sys is

  component sort_dp_ram
    generic (
      ADDR_WIDTH : natural;
      NLEVELS    : natural;
      NAME       : string);
    port (
      clk    : in  std_logic;
      addr_a : in  std_logic_vector(NLEVELS-1 downto 0);
      addr_b : in  std_logic_vector(NLEVELS-1 downto 0);
      data_a : in  T_DATA_REC;
      data_b : in  T_DATA_REC;
      we_a   : in  std_logic;
      we_b   : in  std_logic;
      q_a    : out T_DATA_REC;
      q_b    : out T_DATA_REC);
  end component;

  component sorter_ctrl
    generic (
      NLEVELS   : integer;
      NADDRBITS : integer);
    port (
      tm_din       : in  T_DATA_REC;
      tm_dout      : out T_DATA_REC;
      tm_addr      : out std_logic_vector(NLEVELS-1 downto 0);
      tm_we        : out std_logic;
      lm_din       : in  T_DATA_REC;
      lm_dout      : out T_DATA_REC;
      lm_addr      : out std_logic_vector(NLEVELS-1 downto 0);
      lm_we        : out std_logic;
      rm_din       : in  T_DATA_REC;
      rm_dout      : out T_DATA_REC;
      rm_addr      : out std_logic_vector(NLEVELS-1 downto 0);
      rm_we        : out std_logic;
      up_in        : in  std_logic;
      up_in_val    : in  T_DATA_REC;
      up_in_addr   : in  std_logic_vector(NLEVELS-1 downto 0);
      up_out       : out std_logic;
      up_out_val   : out T_DATA_REC;
      up_out_addr  : out std_logic_vector(NLEVELS-1 downto 0);
      low_out      : out std_logic;
      low_out_val  : out T_DATA_REC;
      low_out_addr : out std_logic_vector(NLEVELS-1 downto 0);
      low_in       : in  std_logic;
      low_in_val   : in  T_DATA_REC;
      low_in_addr  : in  std_logic_vector(NLEVELS-1 downto 0);
      clk          : in  std_logic;
      clk_en       : in  std_logic;
      ready_in     : in  std_logic;
      ready_out    : out std_logic;
      rst_n        : in  std_logic);
  end component;

  -- Create signals for address buses
  -- Some of them will remain unused.
  subtype T_SORT_BUS_ADDR is std_logic_vector(NLEVELS-1 downto 0);
  type T_SORT_ADDR_BUSES is array (NLEVELS downto 0) of T_SORT_BUS_ADDR;
  signal low_addr, up_addr, addr_dr, addr_dl, addr_u                       : T_SORT_ADDR_BUSES                  := (others => (others => '0'));
  type T_SORT_DATA_BUSES is array (NLEVELS downto 0) of T_DATA_REC;
  signal up_update_path, low_update_path, data_d, data_dl, data_dr, data_u : T_SORT_DATA_BUSES                  := (others => DATA_REC_INIT_DATA);
  signal q_dr, q_dl, q_u, q_ul, q_ur                                       : T_SORT_DATA_BUSES                  := (others => DATA_REC_INIT_DATA);
  signal we_ul, we_ur, we_u, we_dl, we_dr, low_update, up_update, s_ready  : std_logic_vector(NLEVELS downto 0) := (others => '0');
  signal addr_switch, addr_switch_del                                      : std_logic_vector(NLEVELS downto 0);
  signal l0_reg                                                            : T_DATA_REC;
  signal clk_en                                                            : std_logic                          := '1';
  
begin  -- sorter_sys_arch1

-- Build the sorting tree
  
  g1 : for i in 0 to NLEVELS-1 generate

    -- Two RAMs from the upper level are seen as a single RAM
    -- We use the most significant bit (i-th bit) to distinguish RAM
    -- In all RAMs the A-ports are used for upstream connections
    -- and the B-ports are used for downstream connections

    -- Below are processes used to combine two upstream RAMs in a single one
    i0a : if i >= 1 generate
      addr_switch(i) <= addr_u(i)(i-1);
    end generate i0a;
    i0b : if i = 0 generate
      addr_switch(i) <= '0';
    end generate i0b;

    -- There is a problem with reading of data provided by two upstream RAMs
    -- we need to multiplex the data...
    -- Delay for read data multiplexer
    s1 : process (clk, rst_n)
    begin  -- process s1
      if rst_n = '0' then                 -- asynchronous reset (active low)
        addr_switch_del(i) <= '0';
      elsif clk'event and clk = '1' then  -- rising clock edge
        addr_switch_del(i) <= addr_switch(i);
      end if;
    end process s1;

    -- Upper RAM signals' multiplexer
    c1 : process (addr_switch, addr_switch_del, q_ul, q_ur, we_u)
    begin  -- process c1
      we_ul(i) <= '0';
      we_ur(i) <= '0';
      if addr_switch(i) = '1' then
        we_ul(i) <= we_u(i);
      else
        we_ur(i) <= we_u(i);
      end if;
      if addr_switch_del(i) = '1' then
        q_u(i) <= q_ul(i);
      else
        q_u(i) <= q_ur(i);
      end if;
    end process c1;

    dp_ram_l : sort_dp_ram
      generic map (
        NLEVELS    => NLEVELS,
        ADDR_WIDTH => i,
        NAME       => "L")
      port map (
        clk    => clk,
        addr_a => addr_dl(i),
        addr_b => addr_u(i+1),
        data_a => data_dl(i),
        data_b => data_u(i+1),
        we_a   => we_dl(i),
        we_b   => we_ul(i+1),
        q_a    => q_dl(i),
        q_b    => q_ul(i+1));

    dp_ram_r : sort_dp_ram
      generic map (
        NLEVELS    => NLEVELS,
        ADDR_WIDTH => i,
        NAME       => "R")
      port map (
        clk    => clk,
        addr_a => addr_dr(i),
        addr_b => addr_u(i+1),
        data_a => data_dr(i),
        data_b => data_u(i+1),
        we_a   => we_dr(i),
        we_b   => we_ur(i+1),
        q_a    => q_dr(i),
        q_b    => q_ur(i+1));

    sorter_ctrl_1 : sorter_ctrl
      generic map (
        NLEVELS   => NLEVELS,
        NADDRBITS => i)
      port map (
        tm_din       => q_u(i),
        tm_dout      => data_u(i),
        tm_addr      => addr_u(i),
        tm_we        => we_u(i),
        lm_din       => q_dl(i),
        lm_dout      => data_dl(i),
        lm_addr      => addr_dl(i),
        lm_we        => we_dl(i),
        rm_din       => q_dr(i),
        rm_dout      => data_dr(i),
        rm_addr      => addr_dr(i),
        rm_we        => we_dr(i),
        up_in        => up_update(i),
        up_in_val    => up_update_path(i),
        up_in_addr   => up_addr(i),
        up_out       => low_update(i),
        up_out_val   => low_update_path(i),
        up_out_addr  => low_addr(i),
        low_in       => low_update(i+1),
        low_in_val   => low_update_path(i+1),
        low_in_addr  => low_addr(i+1),
        low_out      => up_update(i+1),  -- connections to the next level
        low_out_val  => up_update_path(i+1),
        low_out_addr => up_addr(i+1),
        clk          => clk,
        clk_en       => clk_en,
        ready_in     => s_ready(i+1),
        ready_out    => s_ready(i),
        rst_n        => rst_n);

  end generate g1;
  -- top level

  -- On the top level we have only a single register
  process (clk, rst_n)
    variable rline : line;
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      l0_reg <= DATA_REC_INIT_DATA;
    elsif clk'event and clk = '1' then  -- rising clock edge
      dav <= '0';
      if we_u(0) = '1' then
        l0_reg <= data_u(0);
        dout   <= data_u(0);
        dav    <= '1';
        if SORT_DEBUG then
          write(rline, string'("OUT: "));
          write(rline, tdrec2stlv(data_u(0)));
          writeline(reports, rline);
        end if;
      elsif we = '1' then
        if SORT_DEBUG then
          write(rline, string'("IN: "));
          write(rline, tdrec2stlv(din));
          writeline(reports, rline);
        end if;
        l0_reg <= din;
        dout   <= din;
      else
        dout <= l0_reg;
      end if;
    end if;
  end process;
  ready             <= s_ready(0);
  q_ur(0)           <= l0_reg;
  q_ul(0)           <= l0_reg;
  up_update(0)      <= we;
  up_update_path(0) <= din;
  up_addr(0)        <= (others => '0');

  -- signals for the last level

  s_ready(NLEVELS) <= '1';
  --addr(NLEVELS)    <= (others => '0');
  data_dr(NLEVELS) <= DATA_REC_INIT_DATA;
  data_dl(NLEVELS) <= DATA_REC_INIT_DATA;
  we_dl(NLEVELS)   <= '0';
  we_dr(NLEVELS)   <= '0';

  low_update(NLEVELS)      <= '0';
  low_update_path(NLEVELS) <= DATA_REC_INIT_DATA;
  low_addr(0)              <= (others => '0');
  
end sorter_sys_arch1;
