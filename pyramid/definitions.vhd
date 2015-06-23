-------------------------------------------------------------------------------
--  File: definitions.vhd                                                    --
--                                                                           --
--  Copyright (C) Deversys, 2003                                             --
--                                                                           --
--  definition of data width                                                 --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

package definitions is
  constant data_width : integer:= 16;
end package;
