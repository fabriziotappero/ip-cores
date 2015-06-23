------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      demultiplexer1x4
--
-- PURPOSE:     demultiplexer, one input, four outputs
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity demultiplexer1x4 is
    port(   selector:       in std_logic_vector(1 downto 0);
            data_in:        in std_logic;
            data_out_00:    out std_logic;
            data_out_01:    out std_logic;
            data_out_10:    out std_logic;
            data_out_11:    out std_logic
         );
         
end demultiplexer1x4;

architecture rtl of demultiplexer1x4 is   
begin
   data_out_00 <= data_in when selector = "00" else '0';
   data_out_01 <= data_in when selector = "01" else '0';
   data_out_10 <= data_in when selector = "10" else '0';
   data_out_11 <= data_in when selector = "11" else '0';
end rtl;

