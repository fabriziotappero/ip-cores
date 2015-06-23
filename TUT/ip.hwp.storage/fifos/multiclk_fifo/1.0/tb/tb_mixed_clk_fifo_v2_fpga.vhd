-------------------------------------------------------------------------------
-- Title      : Testbench for design "mixed_clk_fifo"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_mixed_clk_fifo.vhd
-- Author     : kulmala3
-- Created    : 16.12.2005
-- Last update: 08.12.2006
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

entity tb_mixed_clk_fifo is
port (
  clk_we    : in std_logic;
  clk_re    : in std_logic;
  clk_ps_re : in std_logic;
  clk_ps_we : in std_logic;
  error_out : out std_logic;
  rst_n     :  in std_logic
  );
end tb_mixed_clk_fifo;

-------------------------------------------------------------------------------

architecture rtl of tb_mixed_clk_fifo is

  -- component generics

  constant depth_g      : integer := 3;
  constant data_width_g : integer := 4;

  -- component ports
--  signal clk_re         : std_logic;
--  signal clk_we         : std_logic;
--  signal clk_ps_re      : std_logic;
--  signal clk_ps_we      : std_logic;
--  signal rst_n          : std_logic;
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
  DUT : entity work.mixed_clk_fifo
    generic map (
      depth_g      => depth_g,
      data_width_g => data_width_g)
    port map (
      clk_re    => clk_re,
      clk_we    => clk_we,
      clk_ps_re => clk_ps_re,
      clk_ps_we => clk_ps_we,
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
      error_out <= '0';
      if re_to_dut = '1' then
        if data_cnt_r /= data_from_dut then
          error_out <= '1';
          assert data_cnt_r = data_from_dut report "wrong value read: " & str(data_from_dut) & "wait: " & str(data_cnt_r) severity error;
        end if;
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


end rtl;

-------------------------------------------------------------------------------
