------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      dataregister
--
-- PURPOSE:     single dataregister of scalar unit
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity dataregister is
    port(   clk:        in std_logic;
            load:       in std_logic;
            data_in:    in std_logic_vector(31 downto 0);
            data_out:   out std_logic_vector(31 downto 0)
         );
end dataregister;

architecture rtl of dataregister is   
    signal data_out_buffer:  unsigned(31 downto 0);
begin
    process 
    begin
        wait until clk='1' and clk'event;
        
        if load = '1' then
            data_out_buffer <= unsigned(data_in);
        else
            data_out_buffer <= data_out_buffer;
        end if;
	end process;
    
    data_out <= std_logic_vector(data_out_buffer);
end rtl;

