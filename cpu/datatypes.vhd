------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      datatypes
--
-- PURPOSE:     definition of basic datatype
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cfg.all;

package datatypes is
    type vectordata_type is array (k-1 downto 0) of std_logic_vector(31 downto 0);
end datatypes;

