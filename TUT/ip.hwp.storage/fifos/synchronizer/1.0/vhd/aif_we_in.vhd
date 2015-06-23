-------------------------------------------------------------------------------
-- Title      :
-- Project    : 
-------------------------------------------------------------------------------
-- File       : 
-- Author     : kulmala3
-- Created    : 01.07.2005
-- Last update: 10.01.2006
-- Description: Input: regular fifo IF: output asynchronous ack/nack IF
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

entity aif_we_in is
  generic (
    data_width_g : integer := 32
    );
  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic;
    we_in    : in  std_logic;
    data_in  : in  std_logic_vector(data_width_g-1 downto 0);
    data_out : out std_logic_vector(data_width_g-1 downto 0);
    full_out : out std_logic;
    a_we_out : out std_logic;           -- must arrive after data!
    ack_in   : in  std_logic            -- actually, one clock cycle
    );                                  -- more for data in rx
end aif_we_in;

architecture rtl of aif_we_in is
  constant stages_c : integer := 2;     -- only works with 2 now
  signal   ack_r    : std_logic_vector(stages_c-1 downto 0);

  signal a_we_l : std_logic;
  signal data_r : std_logic_vector(data_width_g-1 downto 0);
  signal full_r : std_logic;
begin
  
  a_we_out <= a_we_l;

  data_out <= data_r;

  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      a_we_l <= '0';
      ack_r  <= (others => '0');
      full_r <= '0';
--      first_full_r <= '1';
--        data_r <= (others => '0');
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      for i in 0 to stages_c-2 loop
        ack_r(i+1) <= ack_r(i);
      end loop;  -- i

      ack_r(0) <= ack_in;
      full_r   <= (a_we_l xor ack_r(stages_c-1));
      if we_in = '1' and full_r = '0' then
        a_we_l <= not a_we_l;
        data_r <= data_in;
        full_r <= '1';                  -- react immediatelly
      else
        a_we_l <= a_we_l;
      end if;
      
    end if;
  end process;

  full_out <= full_r;
end rtl;
