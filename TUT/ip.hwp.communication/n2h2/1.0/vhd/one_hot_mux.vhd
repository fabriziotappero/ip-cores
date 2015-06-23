-------------------------------------------------------------------------------
-- Title      : one hot mux for one bit
-- Project    : 
-------------------------------------------------------------------------------
-- File       : one_hot_mux.vhd
-- Author     : kulmala3
-- Created    : 16.06.2005
-- Last update: 25.06.2007
-- Description: select signal is one-hot, otherwise - a mux for one bit.
-- Asynchronous.
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 16.06.2005  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

entity one_hot_mux is
  
  generic (
    data_width_g : integer := 0);

  port (
    data_in  : in  std_logic_vector(data_width_g-1 downto 0);
    sel_in   : in  std_logic_vector(data_width_g-1 downto 0);
    data_out : out std_logic
    );

end one_hot_mux;

architecture rtl of one_hot_mux is

begin  -- rtl

  m: process (data_in, sel_in)
    variable temp : std_logic_vector(data_width_g-1 downto 0);
  begin  -- process m

    for i in 0 to data_width_g-1 loop
      temp(i) := sel_in(i) and data_in(i);
    end loop;  -- i

  data_out <= or_reduce(temp);

  end process m;


end rtl;
