------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      flag
--
-- PURPOSE:     one bit flag for status register
--              carry or zero
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity flag is
    port(   clk:        in std_logic;
            load:       in std_logic;
            data_in:    in std_logic;
            data_out:   out std_logic
         );
end flag;

architecture rtl of flag is   
    signal q:  std_logic;
begin
    process 
    begin
        wait until clk='1' and clk'event;
        
        if load = '1' then
            q <= data_in;
        else
            q <= q;
        end if;

	end process;
    
    data_out <= q;
end rtl;

