------------------------------------------------------------------------------
-- TUT / DCS
-------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 22.06.2004 09:26:51
-- File                 : IDCT_pkg.vhd
-- Design               : Generic declarations for IDCT
------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
PACKAGE IDCT_pkg IS
  --NOTE: Some of these constants can be changed. However,
  --that is not tested, and changing these values may require
  --at least modifications to testbench.

  CONSTANT IDCT_inputw_co         : integer := 12;  --IDCT input width
  CONSTANT IDCT_resultw_co        : integer := 9;  --IDCT output width
  CONSTANT IDCT_dataw_co          : integer := 16;  -- internal datawidth for IDTC
  CONSTANT IDCT_rounding_value_co : integer := 4096;
  CONSTANT IDCT_coeffw_co         : integer := 15;  -- width of constant coefficients
END IDCT_pkg;













