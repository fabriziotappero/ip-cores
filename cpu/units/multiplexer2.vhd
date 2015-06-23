------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      multiplexer2
--
-- PURPOSE:     multiplexer, two inputs
--              one output
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity multiplexer2 is
    generic (
        w : positive -- word width
    );
    port (   
        selector:   in std_logic;
        data_in_0:  in std_logic_vector(w-1 downto 0);
        data_in_1:  in std_logic_vector(w-1 downto 0);
        data_out:   out std_logic_vector(w-1 downto 0)
    );
end multiplexer2;

architecture rtl of multiplexer2 is   
begin
   data_out <=  data_in_0 when selector = '0' else
                data_in_1;
end rtl;

