------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      multiplexer4
--
-- PURPOSE:     multiplexer, four inputs
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

entity multiplexer4 is
    generic (
        w : positive
    );
    port (
        selector:    in std_logic_vector(1 downto 0);
        data_in_00:  in std_logic_vector(w-1 downto 0);
        data_in_01:  in std_logic_vector(w-1 downto 0);
        data_in_10:  in std_logic_vector(w-1 downto 0);
        data_in_11:  in std_logic_vector(w-1 downto 0);
        data_out:    out std_logic_vector(w-1 downto 0)
    );
end multiplexer4;

architecture rtl of multiplexer4 is   
begin
   data_out <=  data_in_00 when selector = "00" else
                data_in_01 when selector = "01" else
                data_in_10 when selector = "10" else
                data_in_11;
end rtl;

