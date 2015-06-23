-------------------------------------------------------------------------------
-- Title      : Mixed clock FIFO
-- Project    :
-------------------------------------------------------------------------------
-- File       : 
-- Author     : kulmala3
-- Created    : 16.12.2005
-- Last update: 14.12.2006
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-- Works in fpga testbench. 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 16.12.2005  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mixed_clk_fifo is
  
  generic (
    depth_g      : integer := 0;
    data_width_g : integer := 0
    );
  port (
    clk_re    : in std_logic;
    clk_ps_re : in std_logic;           -- phase shifted pulse
    clk_we    : in std_logic;
    clk_ps_we : in std_logic;           -- phase shifted pulse
    rst_n     : in std_logic;

    data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    we_in     : in  std_logic;
    full_out  : out std_logic;
    one_p_out : out std_logic;

    re_in     : in  std_logic;
    data_out  : out std_logic_vector (data_width_g-1 downto 0);
    empty_out : out std_logic;
    one_d_out : out std_logic
    );
end mixed_clk_fifo;

architecture rtl of mixed_clk_fifo is

  component fifo
    generic (
      data_width_g : integer;
      depth_g      : integer);
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;
      re_in     : in  std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_out : out std_logic;
      one_d_out : out std_logic);
  end component;

  signal data_to_fifo : std_logic_vector (data_width_g-1 downto 0);
  signal we_to_fifo   : std_logic;
  signal we_local_r   : std_logic;
  signal clk_we_was_r : std_logic;

  signal data_between_r  : std_logic_vector (data_width_g-1 downto 0);
  signal we_between_r    : std_logic;
  signal full_between_r  : std_logic;
  signal one_p_between_r : std_logic;
  signal full_from_fifo  : std_logic;
  signal one_p_from_fifo : std_logic;
  signal re_to_fifo      : std_logic;
  signal data_from_fifo  : std_logic_vector (data_width_g-1 downto 0);
  signal empty_from_fifo : std_logic;
  signal one_d_from_fifo : std_logic;
  signal empty_out_r     : std_logic;
  signal full_out_r      : std_logic;
  signal clk_we_period_r : std_logic;

  signal derived_clk : std_logic;
  
begin  -- rtl

  full_out  <= full_out_r;              --from_fifo;
  data_out  <= data_from_fifo;
  empty_out <= empty_from_fifo;

  regular_fifo : fifo
    generic map (
      data_width_g => data_width_g,
      depth_g      => depth_g)
    port map (
      clk       => clk_re,
      rst_n     => rst_n,
      data_in   => data_to_fifo,
      we_in     => we_to_fifo,
      full_out  => full_from_fifo,
      one_p_out => one_p_from_fifo,
      re_in     => re_in,
      data_out  => data_from_fifo,
      empty_out => empty_from_fifo,
      one_d_out => one_d_from_fifo
      );

  -----------------------------------------------------------------------------
  -- RE CLK IS FASTER
  
  process (clk_we, rst_n)
  begin  -- process wefaster
    if rst_n = '0' then                 -- asynchronous reset (active low)
      full_out_r     <= '1';
      data_between_r <= (others => '0');
      we_between_r   <= '0';
      
    elsif clk_we'event and clk_we = '1' then  -- rising clock edge
      if full_between_r = '0' then
        data_between_r <= data_in;
        we_between_r   <= we_in;
      end if;
      full_out_r <= full_between_r or one_p_between_r;
    end if;
  end process;


  derived_clk <= (clk_ps_we nand clk_ps_re) and clk_we;

  derclk : process (derived_clk, rst_n)
  begin  -- process derclk
    if rst_n = '0' then                 -- asynchronous reset (active low)
      data_to_fifo    <= (others => '0');
      we_local_r      <= '0';
      full_between_r  <= '0';
      one_p_between_r <= '0';
      clk_we_period_r <= '0';
      
    elsif derived_clk'event and derived_clk = '1' then  -- rising clock edge
      if full_from_fifo = '0' then
        data_to_fifo <= data_between_r;
        we_local_r   <= we_between_r;
      else
        we_local_r <= '0';
      end if;
      full_between_r  <= full_from_fifo;
      one_p_between_r <= one_p_from_fifo;
      clk_we_period_r <= not clk_we_period_r;
    end if;
  end process derclk;

  we_to_fifo <= (clk_we_period_r xor clk_we_was_r) and we_local_r;

  process (clk_re, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      clk_we_was_r <= '0';
      
    elsif clk_re'event and clk_re = '1' then  -- rising clock edge
      clk_we_was_r <= clk_we_period_r;
    end if;
  end process;

  
end rtl;
