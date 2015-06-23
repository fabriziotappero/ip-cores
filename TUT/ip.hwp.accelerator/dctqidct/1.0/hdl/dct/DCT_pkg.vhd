------------------------------------------------------------------------------
-- TTY / TKT
-------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 22.06.2004 09:26:51
-- File                 : DCT_pkg.vhd
-- Design               : Generic declarations for DCT
------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
PACKAGE DCT_pkg IS
  --NOTE: Some of these constants can be changed. However,
  --that is not tested, and changing these values  may require
  --at least modifications to testbench.
  
  CONSTANT DCT_inputw_co         : integer := 9;  --DCT input width
  CONSTANT DCT_resultw_co        : integer := 12;  --DCT output width
  CONSTANT DCT_dataw_co          : integer := 18;  --internal datawidth for DCT
  CONSTANT DCT_rounding_value_co : integer := 0;
  CONSTANT DCT_coeffw_co         : integer := 15;  -- width of constant coefficients
END DCT_pkg;













