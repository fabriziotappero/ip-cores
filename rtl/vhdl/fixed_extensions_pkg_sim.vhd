--------------------------------------------------------------------------------
-- Filename: fixed_extensions_pkg_sim.vhd
-- Purpose : Package adding various extensions to the VHDL-2008 (VHDL'93, 2002
--           compatibility versions) fixed-point arithmetic package by David 
--           Bishop.
--           Supported operators:
--           * ceil      : round towards plus infinity.
--           * fix       : round towards zero.
--           * floor     : round towards minus infinity.
--           * round     : round to nearest; ties to greatest absolute value.
--           * nearest   : round to nearest; ties to plus infinity.
--           * convergent: round to nearest; ties to closest even.
--           * bitinsert : bit-field insertion to word
--           * bitextract: bit-field extraction from word
--             
-- Author  : Nikolaos Kavvadias (C) 2011
-- Date    : 25-Jul-2011
-- Revision: 0.0.0 (01/05/11)
--           Initial version. Supports ceil, fix, floor, round, nearest, 
--           convergent based on their MATLAB documentation.
--           0.0.1 (03/05/11)
--           Added bitinsert.
--           0.0.2 (16/07/11)
--           Added bitextract (sfixed, ufixed), bitinsert (ufixed). Commented 
--           non-synthesizable part (assertions) of bitinsert.
--           0.0.3 (19/07/11)
--           Fixed ceil bug with rounding integral (zero fractional part) 
--           values.
--           0.0.4 (21/07/11)
--           Fixed more bugs regarding fix, round and convergent.
--           0.0.5 (25/07/11)
--           Design edited for simulation-oriented use.
--------------------------------------------------------------------------------

use STD.TEXTIO.all;
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
--library IEEE_PROPOSED;
--use IEEE_PROPOSED.fixed_float_types.all;
--use IEEE_PROPOSED.fixed_pkg.all;
--use WORK.fixed_float_types.all;
use WORK.fixed_pkg.all;

package fixed_extensions_pkg is

  function ceil (arg : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;
  function ceil (arg : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;
  function fix (arg : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;
  function fix (arg : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;
  function floor (arg : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;
  function floor (arg : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;
  function round (arg : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;
  function round (arg : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;
  function nearest (arg : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;
  function nearest (arg : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;
  function convergent (arg : UNRESOLVED_sfixed) return UNRESOLVED_sfixed;
  function convergent (arg : UNRESOLVED_ufixed) return UNRESOLVED_ufixed;
  function bitinsert (a, y0 : UNRESOLVED_sfixed; bhi, blo : std_logic_vector) return UNRESOLVED_sfixed;
  function bitinsert (a, y0 : UNRESOLVED_ufixed; bhi, blo : std_logic_vector) return UNRESOLVED_ufixed;
  function bitextract (a : UNRESOLVED_sfixed; bhi, blo : std_logic_vector) return UNRESOLVED_sfixed;
  function bitextract (a : UNRESOLVED_ufixed; bhi, blo : std_logic_vector) return UNRESOLVED_ufixed;

end package fixed_extensions_pkg;

--library IEEE;
--use IEEE.MATH_REAL.all;
--use WORK.MATH_REAL.all;

package body fixed_extensions_pkg is

  -- ceil: round towards plus infinity.
  function ceil (
    arg : UNRESOLVED_sfixed)            -- fixed point input
    return UNRESOLVED_sfixed is
    variable result      : UNRESOLVED_sfixed (arg'high downto arg'low);
    variable fract_zero  : std_logic_vector(-arg'low-1 downto 0) := (others => '0');    
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      if (to_slv(arg(-1 downto arg'low)) = fract_zero) then
        result := arg;
      else
        result := arg + 1;
      end if;
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;
  end function ceil;
  
  -- ceil: round towards plus infinity.
  function ceil (
    arg : UNRESOLVED_ufixed)            -- fixed point input
    return UNRESOLVED_ufixed is
    variable result      : UNRESOLVED_ufixed (arg'high downto arg'low);
    variable fract_zero  : std_logic_vector(-arg'low-1 downto 0) := (others => '0');    
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      if (to_slv(arg(-1 downto arg'low)) = fract_zero) then
        result := arg;
      else
        result := arg + 1;
      end if;
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;
  end function ceil;

  -- fix: round towards zero.
  function fix (
    arg : UNRESOLVED_sfixed)            -- fixed point input
    return UNRESOLVED_sfixed is
    variable result      : UNRESOLVED_sfixed (arg'high downto arg'low);
    variable fract_zero  : std_logic_vector(-arg'low-1 downto 0) := (others => '0');    
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      if (is_negative(arg)) then
        if (to_slv(arg(-1 downto arg'low)) = fract_zero) then
          result := arg;
        else
          result := arg + 1;
        end if;
      else
        result := arg;
      end if;
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;
  end function fix;
  
  -- fix: round towards zero.
  function fix (
    arg : UNRESOLVED_ufixed)            -- fixed point input
    return UNRESOLVED_ufixed is
    variable result      : UNRESOLVED_ufixed (arg'high downto arg'low);
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      result := arg;
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;
  end function fix;
  
  -- floor: round towards minus infinity.
  function floor (
    arg : UNRESOLVED_sfixed)            -- fixed point input
    return UNRESOLVED_sfixed is
    variable result      : UNRESOLVED_sfixed (arg'high downto arg'low);
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      result := arg;
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;
  end function floor;
  
  -- floor: round towards plus infinity.
  function floor (
    arg : UNRESOLVED_ufixed)            -- fixed point input
    return UNRESOLVED_ufixed is
    variable result      : UNRESOLVED_ufixed (arg'high downto arg'low);
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      result := arg;
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;
  end function floor;  

  -- round: round to nearest; ties to greatest absolute value.
  function round (
    arg : UNRESOLVED_sfixed)            -- fixed point input
    return UNRESOLVED_sfixed is
    variable result      : UNRESOLVED_sfixed (arg'high downto arg'low);
    variable onehalf_vec : std_logic_vector(-arg'low-1 downto 0) := (others => '0');
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      onehalf_vec(-arg'low-1) := '1';
      if (is_negative(arg)) then
        if (to_slv(arg(-1 downto arg'low)) > onehalf_vec) then
          result := arg + 1;
        else
          result := arg;
        end if;
      else
        if (to_slv(arg(-1 downto arg'low)) >= onehalf_vec) then
          result := arg + 1;
        else
          result := arg;
        end if;
      end if;
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;
  end function round;
  
  -- round: round to nearest; ties to greatest absolute value.
  function round (
    arg : UNRESOLVED_ufixed)            -- fixed point input
    return UNRESOLVED_ufixed is
    variable result      : UNRESOLVED_ufixed (arg'high downto arg'low);
    variable onehalf_vec : std_logic_vector(-arg'low-1 downto 0) := (others => '0');
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      onehalf_vec(-arg'low-1) := '1';
      if (to_slv(arg(-1 downto arg'low)) >= onehalf_vec) then
        result := arg + 1;
      else
        result := arg;
      end if;
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;    
  end function round;

  -- nearest: round to nearest; ties to plus infinity.
  function nearest (
    arg : UNRESOLVED_sfixed)            -- fixed point input
    return UNRESOLVED_sfixed is
    variable result      : UNRESOLVED_sfixed (arg'high downto arg'low);
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      if (arg(-1) = '1') then
        result := arg + 1;
      else
        result := arg;
      end if;
      result(-1 downto arg'low) := (others => '0');
    else
      result := arg;    
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;
  end function nearest;
  
  -- nearest: round to nearest; ties to plus infinity.
  function nearest (
    arg : UNRESOLVED_ufixed)            -- fixed point input
    return UNRESOLVED_ufixed is
    variable result      : UNRESOLVED_ufixed (arg'high downto arg'low);
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      if (arg(-1) = '1') then
        result := arg + 1;
      else
        result := arg;
      end if;
      result(-1 downto arg'low) := (others => '0');
    else
      result := arg;    
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;
  end function nearest;

  -- convergent: round to nearest; ties to closest even.
  function convergent (
    arg : UNRESOLVED_sfixed)            -- fixed point input
    return UNRESOLVED_sfixed is
    variable result      : UNRESOLVED_sfixed (arg'high downto arg'low);
    variable onehalf_vec : std_logic_vector(-arg'low-1 downto 0) := (others => '0');
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      onehalf_vec(-arg'low-1) := '1';
      if (arg(0) = '1') then
        if (to_slv(arg(-1 downto arg'low)) >= onehalf_vec) then
          result := arg + 1;
        else
          result := arg;
        end if;
      else
        if (to_slv(arg(-1 downto arg'low)) > onehalf_vec) then
          result := arg + 1;
        else
          result := arg;
        end if;
      end if;
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;
  end function convergent;
  
  -- convergent: round to nearest; ties to closest even.
  function convergent (
    arg : UNRESOLVED_ufixed)            -- fixed point input
    return UNRESOLVED_ufixed is
    variable result      : UNRESOLVED_ufixed (arg'high downto arg'low);
    variable onehalf_vec : std_logic_vector(-arg'low-1 downto 0) := (others => '0');
  begin
    if (arg'high <= 0) then
      result := (others => '0');
      return result;
    end if;
    if (arg'low > 0) then
      result := arg;
      return result;
    end if;
    if (arg'low < 0) then
      onehalf_vec(-arg'low-1) := '1';
      if (arg(0) = '1') then
        if (to_slv(arg(-1 downto arg'low)) >= onehalf_vec) then
          result := arg + 1;
        else
          result := arg;
        end if;
      else
        if (to_slv(arg(-1 downto arg'low)) > onehalf_vec) then
          result := arg + 1;
        else
          result := arg;
        end if;
      end if;
      result(-1 downto arg'low) := (others => '0');
    end if;
    return result;
  end function convergent;

  function bitinsert (a, y0 : UNRESOLVED_sfixed; bhi, blo : std_logic_vector) return UNRESOLVED_sfixed is
    variable y : UNRESOLVED_sfixed(a'RANGE);
  begin
--    if (bhi < blo) then
--      assert false 
--        report "Error: Invalid range for bitfield insert." 
--        severity failure;    
--    end if;
--    if (to_integer(signed(bhi)) > y'HIGH) then
--      assert false 
--        report "Error: High bound (bhi) is out of result range." 
--        severity failure;    
--    end if;
--    if (to_integer(signed(blo)) < y'LOW) then
--      assert false 
--        report "Error: Low bound (blo) is out of result range." 
--        severity failure;    
--    end if;
    y := y0;
    y(to_integer(signed(bhi)) downto to_integer(signed(blo))) := 
      a(to_integer(signed(bhi))-to_integer(signed(blo)) downto a'LOW);
    return (y);
  end bitinsert;
    
  function bitinsert (a, y0 : UNRESOLVED_ufixed; bhi, blo : std_logic_vector) return UNRESOLVED_ufixed is
    variable y : UNRESOLVED_ufixed(a'RANGE);
  begin
    y := y0;
    y(to_integer(signed(bhi)) downto to_integer(signed(blo))) := 
      a(to_integer(signed(bhi))-to_integer(signed(blo)) downto a'LOW);
    return (y);
  end bitinsert;

  function bitextract (a : UNRESOLVED_sfixed; bhi, blo : std_logic_vector) return UNRESOLVED_sfixed is
    variable y : sfixed(a'HIGH downto a'LOW);
  begin
    y := a;
    y(to_integer(signed(bhi))-to_integer(signed(blo)) downto a'LOW) := 
      a(to_integer(signed(bhi)) downto to_integer(signed(blo)));
    return (y);
  end bitextract;
  
  function bitextract (a : UNRESOLVED_ufixed; bhi, blo : std_logic_vector) return UNRESOLVED_ufixed is
    variable y : ufixed(a'HIGH downto a'LOW);
  begin
    y := a;
    y(to_integer(signed(bhi))-to_integer(signed(blo)) downto a'LOW) := 
      a(to_integer(signed(bhi)) downto to_integer(signed(blo)));
    return (y);
  end bitextract;

end package body fixed_extensions_pkg;
