-------------------------------------------------------------------------------
-- Title      : Testbench for design "asynch_if_s"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_asynch_if_send.vhd
-- Author     : 
-- Created    : 04.01.2006
-- Last update: 02.03.2006
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 04.01.2006  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.txt_util.all;
-------------------------------------------------------------------------------

entity tb_aif_top is

end tb_aif_top;

-------------------------------------------------------------------------------

architecture rtl of tb_aif_top is

  constant data_width_g : integer := 32;

  -- component ports
  signal clk   : std_logic;
  signal rst_n : std_logic;

  -- clock and reset
  constant Period : time := 10 ns;
  constant Period2 : time := 100 ns;

  component aif_read_top
    generic (
      data_width_g : integer);
    port (
      tx_clk       : in  std_logic;
      tx_rst_n     : in  std_logic;
      tx_data_in   : in  std_logic_vector(data_width_g-1 downto 0);
      tx_empty_in  : in  std_logic;
      tx_re_out    : out std_logic;
      rx_clk       : in  std_logic;
      rx_rst_n     : in  std_logic;
      rx_empty_out : out std_logic;
      rx_re_in     : in  std_logic;
      rx_data_out  : out std_logic_vector(data_width_g-1 downto 0));
  end component;

  signal tx_data_to    : std_logic_vector(data_width_g-1 downto 0);
  signal tx_empty_to   : std_logic;
  signal tx_re_from    : std_logic;
  signal rx_empty_from : std_logic;
  signal rx_re_to      : std_logic;
  signal rx_data_from  : std_logic_vector(data_width_g-1 downto 0);

  signal   clk2        : std_logic;
  constant clk_scaler : integer := 1;
  constant clk2_scaler : integer := 1;

  signal cnt_tx_data_r : std_logic_vector(data_width_g-1 downto 0);
  signal cnt_rx_data_r : std_logic_vector(data_width_g-1 downto 0);
  signal rx_full_cnt_r : integer;
  signal tx_we_cnt_r   : integer;

  constant full_after_we_c  : integer := 3;   -- after n data issue full
  constant full_length_c    : integer := 10;  -- cc full is asserted
  constant time_before_we_c : integer := 10;   -- delay after sending
  constant start_value_c    : integer := 3;
  
begin  -- rtl


  aif_read_top_1 : aif_read_top
    generic map (
      data_width_g => data_width_g)
    port map (
      tx_clk       => clk2,
      tx_rst_n     => rst_n,
      tx_data_in   => tx_data_to,
      tx_empty_in  => tx_empty_to,
      tx_re_out    => tx_re_from,
      rx_clk       => clk,
      rx_rst_n     => rst_n,
      rx_empty_out => rx_empty_from,
      rx_re_in     => rx_re_to,
      rx_data_out  => rx_data_from
      );


  -- use clk
  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      cnt_rx_data_r <= conv_std_logic_vector(start_value_c, data_width_g);
      rx_re_to      <= '0';
      rx_full_cnt_r <= 0;
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      if rx_empty_from = '0' and rx_re_to = '1' then
        cnt_rx_data_r <= cnt_rx_data_r+1;
        assert cnt_rx_data_r = rx_data_from report "Error: rx data wrong wait: " &
          str(conv_integer(cnt_rx_data_r)) & "got: " &
          str(conv_integer(rx_data_from))
          severity error;

      end if;
      if rx_empty_from = '0' then

        if rx_full_cnt_r > full_after_we_c + full_after_we_c -1 then
          rx_re_to      <= '1';
          rx_full_cnt_r <= 0;
        elsif rx_full_cnt_r > full_after_we_c-1 then
          rx_re_to      <= '0';
          rx_full_cnt_r <= rx_full_cnt_r+1;
        else
          rx_re_to      <= '1';
          rx_full_cnt_r <= rx_full_cnt_r+1;
        end if;

      else
        rx_re_to <= '0';
      end if;
      -- rx re to always '1', resemble n2h2 behavior
      -- rx_re_to <= '1';
    end if;
    
  end process;


  -- transmit, use different clock.
  tx : process (clk2, rst_n)
  begin  -- process tx
    if rst_n = '0' then                 -- asynchronous reset (active low)
      tx_we_cnt_r   <= 0;
      tx_data_to    <= conv_std_logic_vector(start_value_c, data_width_g);
      cnt_tx_data_r <= conv_std_logic_vector(start_value_c+1, data_width_g);
      tx_empty_to   <= '1';
      
    elsif clk2'event and clk2 = '1' then  -- rising clock edge
      if tx_we_cnt_r > 0 then
        tx_we_cnt_r <= tx_we_cnt_r-1;
        tx_empty_to <= '1';
      else
        tx_empty_to <= '0';
        if tx_re_from = '1' then
          tx_data_to    <= cnt_tx_data_r;
          cnt_tx_data_r <= cnt_tx_data_r+1;
          tx_we_cnt_r   <= time_before_we_c;
        end if;
        
      end if;
    end if;
  end process tx;

  -- clock generation
  -- PROC  
  CLOCK1 : process                      -- generate clock signal for design
    variable clktmp : std_logic := '0';
  begin
    wait for PERIOD/2;
    clktmp := not clktmp;
    Clk    <= clktmp;
  end process CLOCK1;

  CLOCK2 : process                      -- generate clock signal for design
    variable clktmp : std_logic := '0';
  begin
    wait for PERIOD2/2;
    clktmp := not clktmp;
    Clk2   <= clktmp;
  end process CLOCK2;

  -- PROC
  RESET : process
  begin
    Rst_n <= '0';                       -- Reset the testsystem
    wait for 6*PERIOD;                  -- Wait 
    Rst_n <= '1';                       -- de-assert reset
    wait;
  end process RESET;

  

end rtl;

-------------------------------------------------------------------------------
