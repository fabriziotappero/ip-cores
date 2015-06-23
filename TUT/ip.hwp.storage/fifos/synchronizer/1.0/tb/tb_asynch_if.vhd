
-------------------------------------------------------------------------------
-- Title      : Testbench for design "asynch_if_s"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_asynch_if_send.vhd
-- Author     : 
-- Created    : 04.01.2006
-- Last update: 05.01.2006
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

entity tb_asynch_if is

end tb_asynch_if;

-------------------------------------------------------------------------------

architecture rtl of tb_asynch_if is

  component asynch_if_rx
    generic (
      data_width_g : integer := 32
      );
    port (
      clk      : in  std_logic;
      rst_n    : in  std_logic;
      a_we_in  : in  std_logic;
      ack_out  : out std_logic;
      we_out   : out std_logic;
      data_in  : in  std_logic_vector(data_width_g-1 downto 0);
      data_out : out std_logic_vector(data_width_g-1 downto 0);
      full_in : in  std_logic);
  end component;

  constant data_width_g : integer := 32;

  -- component ports
  signal clk          : std_logic;
  signal rst_n        : std_logic;
  signal ack_from_rx  : std_logic;
  signal we_from_rx   : std_logic;
  signal data_from_rx : std_logic_vector(data_width_g-1 downto 0);
  signal full_to_rx  : std_logic;

  -- clock and reset
  constant Period : time := 10 ns;

  component asynch_if_tx
    generic (
      data_width_g : integer);
    port (
    clk : in std_logic;      
      rst_n    : in  std_logic;
      we_in    : in  std_logic;
      data_in  : in  std_logic_vector(data_width_g-1 downto 0);
      data_out : out std_logic_vector(data_width_g-1 downto 0);
      full_out : out std_logic;
      a_we_out : out std_logic;
      ack_in   : in  std_logic
      );
  end component;

  signal we_to_tx     : std_logic;
  signal data_to_tx   : std_logic_vector(data_width_g-1 downto 0);
  signal data_from_tx : std_logic_vector(data_width_g-1 downto 0);
  signal full_from_tx : std_logic;
  signal a_we_from_tx : std_logic;

  signal   clk2        : std_logic;
  constant clk2_scaler : integer := 3;

  signal cnt_tx_data_r  : std_logic_vector(data_width_g-1 downto 0);
  signal cnt_rx_data_r  : std_logic_vector(data_width_g-1 downto 0);
  signal rx_full_cnt_r : integer;
  signal tx_we_cnt_r    : integer;

  constant full_after_we_c : integer := 3;   -- after n data issue full
  constant full_length_c   : integer := 10;  -- cc full is asserted
  constant time_before_we_c : integer := 0;   -- delay after sending
  constant start_value_c    : integer := 3;
  
begin  -- rtl

  -- component instantiation
  DUT : asynch_if_rx
    generic map (
      data_width_g => data_width_g)
    port map (
      clk      => clk,
      rst_n    => rst_n,
      a_we_in  => a_we_from_tx,
      ack_out  => ack_from_rx,
      data_in  => data_from_tx,
      data_out => data_from_rx,
      we_out   => we_from_rx,
      full_in => full_to_rx
      );

  asynch_if_tx_1 : asynch_if_tx
    generic map (
      data_width_g => data_width_g)
    port map (
      clk      => clk2,
      rst_n    => rst_n,
      we_in    => we_to_tx,
      data_in  => data_to_tx,
      data_out => data_from_tx,
      full_out => full_from_tx,
      a_we_out => a_we_from_tx,
      ack_in   => ack_from_rx
      );


  -- receiving, use clk
  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      cnt_rx_data_r  <= conv_std_logic_vector(start_value_c, data_width_g);
      full_to_rx    <= '0';
      rx_full_cnt_r <= 0;
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      if we_from_rx = '1' and full_to_rx = '0' then
        assert cnt_rx_data_r = data_from_rx report "Error: rx data wrong wait: " &
          str(conv_integer(cnt_rx_data_r)) & "got: " &
          str(conv_integer(data_from_rx))
          severity error;
        cnt_rx_data_r  <= cnt_rx_data_r+1;
        rx_full_cnt_r <= rx_full_cnt_r + 1;
      end if;

      if rx_full_cnt_r > full_after_we_c + full_after_we_c -1 then
        full_to_rx    <= '0';
        rx_full_cnt_r <= 0;
      elsif rx_full_cnt_r > full_after_we_c-1 then
        full_to_rx    <= '1';
        rx_full_cnt_r <= rx_full_cnt_r+1;
      end if;
      
    end if;
    
  end process;

  -- transmit, use different clock.
  tx : process (clk2, rst_n)
  begin  -- process tx
    if rst_n = '0' then                 -- asynchronous reset (active low)
      tx_we_cnt_r   <= 0;
      data_to_tx    <= conv_std_logic_vector(start_value_c, data_width_g);
      cnt_tx_data_r <= conv_std_logic_vector(start_value_c, data_width_g);
      we_to_tx      <= '0';
      
    elsif clk2'event and clk2 = '1' then  -- rising clock edge
      if tx_we_cnt_r > 0 then
        tx_we_cnt_r <= tx_we_cnt_r-1;
        we_to_tx <= '0';
      end if;
      if full_from_tx = '0' then
        if tx_we_cnt_r = 0 then
          we_to_tx      <= '1';
          data_to_tx    <= cnt_tx_data_r;
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
    wait for PERIOD/clk2_scaler;
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
