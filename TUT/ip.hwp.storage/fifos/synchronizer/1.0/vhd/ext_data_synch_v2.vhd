-------------------------------------------------------------------------------
-- Title      : Off-chip data bus for same clock frequencies at different phase
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ext_data_synch.vhd
-- Author     : 
-- Created    : 11.08.2006
-- Last update: 07.08.2007
-- Description: REQUIRES THE SAME CLOCK FREQUENCIES FROM BOTH ENDS!
-- Possible hazard in empty: not synchronized. maybe change it later if errors
-- occure.
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 11.08.2006  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ext_data_synch is
  
  generic (
    sync_freq_g  : integer := 1;
    bus_freq_g   : integer := 1;
    data_width_g : integer := 4;
    depth_g      : integer := 10        -- FIFO size & max transfer size
    );

  port (
      
    clk_re : in std_logic;
    clk_we : in std_logic;
    rst_n : in std_logic;

    tx_data_in  : in  std_logic_vector(data_width_g-1 downto 0);
    tx_empty_in : in  std_logic;
    tx_re_out   : out std_logic;

    rx_re_in     : in  std_logic;
    rx_data_out  : out std_logic_vector(data_width_g-1 downto 0);
    rx_empty_out : out std_logic;

    a_empty_in  : in  std_logic;
    a_empty_out : out std_logic;
    a_we_out    : out std_logic;
    a_we_in     : in  std_logic;
    a_data_out  : out std_logic_vector(data_width_g-1 downto 0);
    a_data_in   : in  std_logic_vector(data_width_g-1 downto 0)
    );

end ext_data_synch;

architecture rtl of ext_data_synch is
  constant stable_period_c   : integer := 3;   -- stable for n clock cycles.
  -- works with 3 in FPGA.
  constant n_data_on_lines_c : integer := 10;  -- amount of data packets that may be
  -- travelling currently to the other side. used to approximate the rquired
  -- FIFO depth (depth_g+n_data_on_lines_c = fifo depth)

  -- tx signals
  signal a_we_out_r   : std_logic;
  signal data_cnt_r   : integer range depth_g downto 0;
  signal stable_cnt_r : integer range stable_period_c-1 downto 0;
  signal a_data_out_r : std_logic_vector(data_width_g-1 downto 0);
  signal a_empty_in_r : std_logic_vector(1 downto 0);
  --rx signals
  signal a_we_in_r    : std_logic_vector(1 downto 0);
  signal read_in      : std_logic;

  signal rx_fifo_data_in   : std_logic_vector (data_width_g-1 downto 0);
  signal rx_fifo_we_in     : std_logic;
  signal rx_fifo_full_out  : std_logic;
--  signal rx_fifo_re_in     : std_logic;
--  signal rx_fifo_data_out  : std_logic_vector (data_width_g-1 downto 0);
  signal rx_fifo_empty_out : std_logic;

  -- receiving FIFO
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

--  component fifo
--    generic (
--      data_width_g : integer;
--      depth_g      : integer);
--    port (
--      clk       : in  std_logic;
--      rst_n     : in  std_logic;
--      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
--      we_in     : in  std_logic;
--      full_out  : out std_logic;
--      one_p_out : out std_logic;
--      re_in     : in  std_logic;
--      data_out  : out std_logic_vector (data_width_g-1 downto 0);
--      empty_out : out std_logic;
--      one_d_out : out std_logic);
--  end component;

  type   tx_states is (send, keep_stable);
  signal tx_ctrl_r : tx_states;
  
begin  -- rtl

  -- purpose: tx side of the block
  a_data_out <= a_data_out_r;
  a_we_out   <= a_we_out_r;

  process (clk_we, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      a_we_out_r   <= '0';
      data_cnt_r   <= 0;                -- could also be depth_g
      tx_ctrl_r    <= send;
      stable_cnt_r <= 0;
      a_data_out_r <= (others => '0');
      tx_re_out    <= '0';
      a_empty_in_r <= (others => '0');
      
    elsif clk_we'event and clk_we = '1' then  -- rising clock edge
      a_empty_in_r(0) <= a_empty_in;
      a_empty_in_r(1) <= a_empty_in_r(0);
      case tx_ctrl_r is
        when send =>
          if tx_empty_in = '0' and (a_empty_in_r(1) = '1' or data_cnt_r /= 0) then
            a_data_out_r <= tx_data_in;
            tx_re_out    <= '1';
            a_we_out_r   <= not a_we_out_r;
            tx_ctrl_r    <= keep_stable;
            stable_cnt_r <= stable_period_c-1;
            if a_empty_in_r(1) = '1' then
              data_cnt_r <= depth_g;
            else
              data_cnt_r <= data_cnt_r-1;
            end if;

          else
            tx_re_out <= '0';
          end if;
          
        when keep_stable =>
          a_data_out_r <= a_data_out_r;
          a_we_out_r   <= a_we_out_r;
          tx_re_out    <= '0';
          if stable_cnt_r /= 0 then
            stable_cnt_r <= stable_cnt_r-1;
          else
            tx_ctrl_r    <= send;
            stable_cnt_r <= stable_period_c-1;
          end if;
          
      end case;

    end if;
  end process;


  read_in <= a_we_in_r(1) xor a_we_in_r(0);
  -- purpose: rx side of the block
  process (clk_we, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      a_we_in_r     <= (others => '0');
      rx_fifo_we_in <= '0';
      
    elsif clk_we'event and clk_we = '1' then  -- rising clock edge
      -- if FIFO is full, we are anyway screwed, no reason to check it...
      a_we_in_r(0) <= a_we_in;
      a_we_in_r(1) <= a_we_in_r(0);
      if read_in = '1' then
        rx_fifo_data_in <= a_data_in;
        rx_fifo_we_in   <= '1';
        assert rx_fifo_full_out = '0' report "Writing to full FIFO!!" severity error;
      else
        rx_fifo_we_in <= '0';
      end if;
    end if;
  end process;

  fifo_1 : multiclk_fifo
    generic map (
      re_freq_g    => sync_freq_g,
      we_freq_g    => sync_freq_g,
      data_width_g => data_width_g,
      depth_g      => depth_g+n_data_on_lines_c)
    port map (

      clk_we   => clk_we,
      clk_re   => clk_we,
      rst_n => rst_n,

      data_in  => rx_fifo_data_in,
      we_in    => rx_fifo_we_in,
      full_out => rx_fifo_full_out,

--      one_p_out => one_p_out,
      re_in     => rx_re_in,
      data_out  => rx_data_out,
      empty_out => rx_fifo_empty_out
--    one_d_out => one_d_out
      );

  rx_empty_out <= rx_fifo_empty_out;
  a_empty_out  <= rx_fifo_empty_out;
  
end rtl;

