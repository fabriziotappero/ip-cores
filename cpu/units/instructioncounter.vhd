------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      instructioncounter
--
-- PURPOSE:     instruction counter
--              basically a 32 bit register with increment
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity instructioncounter is
    port(   clk:        in std_logic;
            load:       in std_logic;
            inc:        in std_logic;
            reset:      in std_logic;
            data_in:    in std_logic_vector(31 downto 0);
            data_out:   out std_logic_vector(31 downto 0)
         );
end instructioncounter;

architecture rtl of instructioncounter is   
    signal data_out_buffer:  unsigned(31 downto 0);
begin
    process 
    begin
        wait until clk='1' and clk'event;
        if reset = '1' then
            data_out_buffer <= "00000000000000000000000000000000";
        else
            if load = '1' and inc = '0' then
                data_out_buffer <= unsigned(data_in);
            end if;
            
            if load = '0' and inc = '1' then
                data_out_buffer <= data_out_buffer + inc;
            end if;
            
            if (load = inc) then
                data_out_buffer <= data_out_buffer;
            end if;
        end if;
	end process;
    
    data_out <= std_logic_vector(data_out_buffer);
    
end rtl;

