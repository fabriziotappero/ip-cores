-------------------------------------------------------------------------------
-- Title      : Read pulse synchronizer for Mixed clock FIFO
-- WE faster than re
-- Project    :
-------------------------------------------------------------------------------
-- File       : 
-- Author     : kulmala3
-- Created    : 16.12.2005
-- Last update: 15.12.2006
-- Description: An extra FIFO slot that synchronizes the data between different
-- clock domains
-------------------------------------------------------------------------------
-- Copyright (c) 2005
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 16.12.2005  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity re_pulse_synchronizer is
  
  generic (
    data_width_g : integer := 0
    );
  port (
    clk_re    : in std_logic;           -- THIS IS ALWAYS THE SLOWER CLOCK!!!
    clk_ps_re : in std_logic;           -- phase shifted pulse
    clk_we    : in std_logic;
    clk_ps_we : in std_logic;           -- phase shifted pulse
    rst_n     : in std_logic;

    -- from/to we domain
    data_in  : in  std_logic_vector (data_width_g-1 downto 0);
    empty_in : in  std_logic;
    re_out   : out std_logic;

    -- from/to re domain
    data_out  : out std_logic_vector (data_width_g-1 downto 0);
    re_in     : in  std_logic;
    empty_out : out std_logic

    -- From clk_re domain FIFO
--    full_in : in std_logic;
--    one_p_in : in std_logic



    );
end re_pulse_synchronizer;

architecture rtl of re_pulse_synchronizer is

  signal clk_re_was_r    : std_logic;
  signal clk_re_period_r : std_logic;

  signal derived_clk : std_logic;

  signal re_to_fifo : std_logic;
--  signal re_between_r : std_logic;

--  signal data_between_r  : std_logic_vector(data_width_g-1 downto 0);
  signal data_out_r : std_logic_vector(data_width_g-1 downto 0);
  signal valid_r    : std_logic;
--  signal valid_between_r : std_logic;
  signal clk_was_r  : std_logic;
  signal re_valid_r : std_logic;
  signal re_was_r   : std_logic;
begin  -- rtl

  
  derived_clk <= (clk_ps_re nand clk_ps_we) and clk_re;

  -- read the fifo signals and read to the slot
  derclk : process (derived_clk, rst_n)
  begin  -- process derclk
    if rst_n = '0' then                 -- asynchronous reset (active low)
      data_out_r      <= (others => '0');
      re_to_fifo      <= '0';
      valid_r         <= '0';
      clk_re_period_r <= '0';
      
    elsif derived_clk'event and derived_clk = '1' then  -- rising clock edge
      if re_valid_r = '1'  or (re_was_r = '1') then
        -- by default, read invalidates data. next if will set again
        -- if new one is read instead.
        valid_r <= '0';
      end if;
      if empty_in = '0' and (valid_r = '0' or
                             (valid_r = '1' and
                              (re_valid_r = '1' or
                               (re_was_r = '1' and re_in = '1')))) then
        -- read data to output from fifo
        re_to_fifo <= '1';
        data_out_r <= data_in;
        valid_r    <= '1';
      else
        re_to_fifo <= '0';
        data_out_r <= data_out_r;
      end if;

      clk_re_period_r <= not clk_re_period_r;
      
    end if;
  end process derclk;

  empty_out <= not valid_r;
  data_out  <= data_out_r;
  re_out    <= re_to_fifo and (clk_re_was_r xor clk_re_period_r);

  re_valid_r <= (clk_was_r xnor clk_re_period_r) and re_in;

  process (clk_re, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      clk_was_r <= '0';
      re_was_r        <= '0';
      
    elsif clk_re'event and clk_re = '1' then  -- rising clock edge
      clk_was_r <= not clk_was_r;
      re_was_r <= re_in;

    end if;
  end process;

--  refaster : process (clk_re, rst_n)
--  begin  -- process refaster
--    if rst_n = '0' then                 -- asynchronous reset (active low)
--      re_between_r <= '0';
--      valid_r      <= '0';
--      data_out_r   <= (others => '0');

--    elsif clk_re'event and clk_re = '1' then  -- rising clock edge
--      if re_in = '1' then
--        -- by default, read invalidates data. next if will set again
--        -- if new one is read instead.
--        valid_r <= '0';
--      end if;
--      if valid_between_r = '0' and (valid_r = '0' or
--                            (valid_r = '1' and re_in = '1')) then
--        -- read data to output from fifo
--        re_between_r <= '1';
--        data_out_r   <= data_in;
--        valid_r      <= '1';
--      else
--        re_between_r <= '0';
--        data_out_r   <= data_between_r;
--      end if;
--    end if;
--  end process refaster;


-- we faster, make the pulse length equal
  process (clk_we, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      clk_re_was_r <= '0';
      
    elsif clk_we'event and clk_we = '1' then  -- rising clock edge
      clk_re_was_r <= clk_re_period_r;
    end if;
  end process;


end rtl;
