-------------------------------------------------------------------------------
-- Title      : Testbench for design "multiclk_fifo"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_multiclk_fifo.vhd
-- Author     : kulmala3
-- Created    : 16.12.2005
-- Last update: 16.12.2005
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 16.12.2005  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use work.txt_util.all;

-------------------------------------------------------------------------------

entity tb_multiclk_fifo is

end tb_multiclk_fifo;

-------------------------------------------------------------------------------

architecture rtl of tb_multiclk_fifo is

  component multiclk_fifo
    generic (
      re_freq_g    : integer;
      we_freq_g    : integer;
      depth_g      : integer;
      data_width_g : integer);
    port (
      clk_re    : in  std_logic;
      clk_we    : in  std_logic;
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

  -- component generics
  constant re_freq_g : integer := 3;
  constant we_freq_g : integer := 1;
  constant Period_re : time    := 10 ns;
  constant Period_we : time    := 30 ns;
--  constant re_freq_g  : integer := 1;
--  constant we_freq_g  : integer := 3;
--  constant Period_re : time    := 30 ns;
--  constant Period_we : time    := 10 ns;
  constant re_freq_g : integer := 1;
  constant we_freq_g : integer := 1;
  constant Period_re : time    := 10 ns;
  constant Period_we : time    := 10 ns;

  constant depth_g      : integer := 3;
  constant data_width_g : integer := 4;

  -- component ports
  signal clk_re         : std_logic;
  signal clk_we         : std_logic;
  signal rst_n          : std_logic;
  signal data_to_dut    : std_logic_vector (data_width_g-1 downto 0);
  signal we_to_dut      : std_logic;
  signal full_from_dut  : std_logic;
  signal one_p_from_dut : std_logic;
  signal re_to_dut      : std_logic;
  signal data_from_dut  : std_logic_vector (data_width_g-1 downto 0);
  signal empty_from_dut : std_logic;
  signal one_d_from_dut : std_logic;
  signal data_cnt_r     : std_logic_vector(data_width_g-1 downto 0);

  -- to create periods of not reading or not writing,
  -- full and empty cases
  constant write_phase_c : integer := 7;
  constant read_phase_c  : integer := 6;
  signal   read_phase_r  : integer;
  signal   write_phase_r : integer;
  signal   int_re_r      : std_logic;
  signal   int_we_r      : std_logic;
  
begin  -- rtl

  -- component instantiation
  DUT : multiclk_fifo
    generic map (
      re_freq_g    => re_freq_g,
      we_freq_g    => we_freq_g,
      depth_g      => depth_g,
      data_width_g => data_width_g)
    port map (
      clk_re    => clk_re,
      clk_we    => clk_we,
      rst_n     => rst_n,
      data_in   => data_to_dut,
      we_in     => we_to_dut,
      full_out  => full_from_dut,
      one_p_out => one_p_from_dut,
      re_in     => re_to_dut,
      data_out  => data_from_dut,
      empty_out => empty_from_dut,
      one_d_out => one_d_from_dut
      );

  we_to_dut <= (not full_from_dut) and int_we_r;

  wr : process (clk_we, rst_n)
  begin  -- process write
    if rst_n = '0' then                 -- asynchronous reset (active low)
      data_to_dut   <= (others => '0');
--      we_to_dut     <= '0';
      write_phase_r <= 0;
      int_we_r      <= '0';
      
    elsif clk_we'event and clk_we = '1' then  -- rising clock edge
      if we_to_dut = '1' then
        if data_to_dut /= data_to_dut'high then
          data_to_dut <= data_to_dut+1;
        else
          data_to_dut <= (others => '0');
        end if;
      else
--          we_to_dut   <= '1';
        data_to_dut <= data_to_dut;
      end if;

      if write_phase_r < write_phase_c then
        write_phase_r <= write_phase_r+1;
        int_we_r      <= '1';
        
      else
        if write_phase_r < write_phase_c*2 then
          int_we_r      <= '0';
--          we_to_dut     <= '0';
          write_phase_r <= write_phase_r+1;
        else
          write_phase_r <= 0;
--          we_to_dut <= '1';
        end if;
      end if;
      
    end if;

  end process wr;

  re_to_dut <= not empty_from_dut and int_re_r;

  re : process (clk_re, rst_n)
  begin  -- process re
    if rst_n = '0' then                 -- asynchronous reset (active low)
--      re_to_dut  <= '0';
      data_cnt_r   <= conv_std_logic_vector(0, data_width_g);
      read_phase_r <= 0;
      int_re_r     <= '1';
    elsif clk_re'event and clk_re = '1' then  -- rising clock edge

      if re_to_dut = '1' then
        assert data_cnt_r = data_from_dut report "wrong value read: " & str(data_from_dut) & "wait: " & str(data_cnt_r) severity error;
        if data_cnt_r /= data_cnt_r'high then
          data_cnt_r <= data_cnt_r+1;
        else
          data_cnt_r <= (others => '0');
        end if;
      else
        data_cnt_r <= data_cnt_r;
      end if;

      if read_phase_r < read_phase_c then
        int_re_r     <= '1';
        read_phase_r <= read_phase_r+1;
        
      else
        if read_phase_r < read_phase_c*2 then
          int_re_r     <= '0';
          read_phase_r <= read_phase_r+1;
        else
          int_re_r     <= '0';
          read_phase_r <= 0;
        end if;
      end if;
      
    end if;
  end process re;



  -- clock generation
  -- PROC  
  CLOCK1 : process                      -- generate clock signal for design
    variable clktmp : std_logic := '0';
  begin
    clktmp := not clktmp;
    clk_re <= clktmp;
    wait for Period_re/2;
  end process CLOCK1;

  CLOCK2 : process                      -- generate clock signal for design
    variable clktmp : std_logic := '0';
  begin
    clktmp := not clktmp;
    clk_we <= clktmp;
    wait for Period_we/2;
  end process CLOCK2;

  -- PROC
  RESET : process
  begin
    Rst_n <= '0';                       -- Reset the testsystem
    wait for 6*Period_re;               -- Wait 
    Rst_n <= '1';                       -- de-assert reset
    wait;
  end process RESET;

  

end rtl;

-------------------------------------------------------------------------------
