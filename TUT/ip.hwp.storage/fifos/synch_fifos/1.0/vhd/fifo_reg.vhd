-------------------------------------------------------------------------------
-- Title      : fifo_reg
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fifo_reg.vhd
-- Author     : 
-- Company    : 
-- Created    : 2005-05-23
-- Last update: 31.05.2005
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2005-05-23  1.0      penttin5        Created
-- 31.5.2005            AK      Naming scheme according to coding rules
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity fifo_reg is
  
  generic (
    width_g : integer := 0
    );

  port (
    clk         : in  std_logic;
    rst_n       : in  std_logic;
    load_in     : in  std_logic;
    data1_in    : in  std_logic_vector(width_g - 1 downto 0);
    data2_in    : in  std_logic_vector(width_g - 1 downto 0);
    data_sel_in : in  std_logic;
    data_out    : out std_logic_vector(width_g - 1 downto 0)
    );

end fifo_reg;

architecture RTL of fifo_reg is

  signal data_r       : std_logic_vector(width_g - 1 downto 0);
  signal load_and_sel : std_logic_vector(1 downto 0);

begin  -- RTL

  load_and_sel <= load_in & data_sel_in;
  data_out     <= data_r;

  fifo_reg : process (clk, rst_n)
  begin  -- process fifo_reg
    if rst_n = '0' then                 -- asynchronous reset (active low)
      data_r <= (others => '0');
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      case load_and_sel is
        when "10" =>
          data_r <= data1_in;
        when "11" =>
          data_r <= data2_in;
        when others =>
          data_r <= data_r;
      end case;
--      if load = '1' then
--        if data_sel = '0' then
--          data_r <= data1_in;
--       elsif data_sel = '1' then
--          data_r <= data2_in;
--        end if;
--      end if;
    end if;
  end process fifo_reg;

end RTL;
