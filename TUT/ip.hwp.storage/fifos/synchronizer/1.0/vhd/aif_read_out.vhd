-------------------------------------------------------------------------------
-- Title      :
-- Project    : 
-------------------------------------------------------------------------------
-- File       : latch synch
-- Author     : kulmala3
-- Created    : 01.07.2005
-- Last update: 05.01.2006
-- Description: OUT: regular fifo IN: output asynchronous ack/nack IF
--
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 01.07.2005  1.0      AK      Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity aif_read_out is
  generic (
    data_width_g : integer := 32
    ); 
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    a_we_in   : in  std_logic;
    ack_out   : out std_logic;
    empty_out : out std_logic;
    re_in     : in  std_logic;
    data_in   : in  std_logic_vector(data_width_g-1 downto 0);
    data_out  : out std_logic_vector(data_width_g-1 downto 0)

    );
end aif_read_out;

architecture rtl of aif_read_out is

  constant stages_c : integer := 3;

  signal ack_r           : std_logic;
  signal received_data_r : std_logic;
  -- synchronizer, last two are xorred
  signal a_we_r          : std_logic_vector(stages_c-1 downto 0);
  signal data_r          : std_logic_vector(data_width_g-1 downto 0);
begin
  data_out <= data_r;
--  ack_out <= ack_r;

  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      a_we_r          <= (others => '0');
      ack_r           <= '0';
      ack_out         <= '0';
      received_data_r <= '0';
      empty_out       <= '1';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      for i in 0 to stages_c-2 loop
        a_we_r(i+1) <= a_we_r(i);
      end loop;  -- i

      a_we_r(0) <= a_we_in;

      -- now wait until we can write it to fifo

      if (a_we_r(stages_c-1) xor a_we_r(stages_c-2)) = '1' then
        ack_r           <= not ack_r;
        received_data_r <= '1';
        data_r          <= data_in;
        empty_out       <= '0';
      else
        ack_r <= ack_r;
      end if;

      if re_in = '1' and received_data_r = '1' then
        -- acknowledge, stop writing
        ack_out         <= ack_r;
        empty_out       <= '1';
        received_data_r <= '0';
      end if;


    end if;
  end process;
  
end rtl;
