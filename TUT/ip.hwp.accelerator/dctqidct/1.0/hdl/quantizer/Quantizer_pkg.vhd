------------------------------------------------------------------------------
-- TUT / DCS
-------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 22.06.2004 09:26:51
-- File                 : Quantizer_pkg.vhd
-- Design               : Generic declarations for Quantizer
------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
PACKAGE Quantizer_pkg IS
  CONSTANT QUANT_inputw_co : integer := 12;  -- width of quantizer input
  CONSTANT QUANT_resultw_co  : integer := 8;  --width of quantized values
  CONSTANT IQUANT_resultw_co : integer := 12;  --width of inverse quantized values
END Quantizer_pkg;













