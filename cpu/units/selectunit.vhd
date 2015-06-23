------------------------------------------------------------------
-- PROJECT:    HiCoVec (highly configurable vector processor)
--
-- ENTITY:      selectunit
--
-- PURPOSE:     selects one word out of a vector
--              register
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.cfg.all;
use work.datatypes.all;

entity selectunit is
    port (
        data_in :   in  vectordata_type;
        k_in:       in  std_logic_vector(31 downto 0);
        data_out:   out std_logic_vector(31 downto 0)
    );
end selectunit;

architecture rtl of selectunit is
    signal index: integer range 0 to k-1;
begin
   index <= conv_integer(k_in) when (k_in < k) else 0;
   data_out <= data_in(index);
end rtl;