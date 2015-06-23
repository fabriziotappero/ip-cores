--------------------------------------------------------------------------------
-- Filename: operpack.vhd
-- Purpose : Package for various arithmetic operators:
--           * Variable shifter (left shift unsigned, left shift signed, right 
--             shift unsigned, right shift signed)
--           * Multipliers (mul, smul, umul)
--           * Dividers and modulo extractors (divqr, divq, divr)
--           * Bit manipulation operators (bitinsert, bitextract)
--             
-- Author  : Nikolaos Kavvadias (C) 2009, 2010, 2011, 2012, 2013, 2014
-- Date    : 22-Feb-2014
-- Revision: 0.0.0 (03/10/09)
--           Initial version.
--           0.2.0 (12/10/09)
--           Added mul, umul, smul operators.
--           0.3.0 (22/01/10)
--           Added divqr, divq, divr operators.
--           0.3.1 (20/07/10)
--           All input procedure parameters are not necessarily of the signal 
--           type.
--           0.3.2 (14/10/10)
--           Spin-off of file "operpack.vhd". Supports the "real" IEEE standard
--           libraries (numeric_std).
--           0.3.3 (01/05/11)
--           Added bitinsert, bitextract operators.
--           0.4.9 (25/02/12)
--           Added support for shrv6, shlv6 (64-bit quantities).
--           1.0.0 (22/02/14)
--           Underhanded version: removed all functionality except shrv4 which 
--           needed for the CORDIC IP CORE.
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


package operpack is 
  
  function shrv4 (a, b : std_logic_vector; mode : std_logic) return std_logic_vector; 
  constant  ONE : std_logic_vector(0 downto 0) := "1";

end operpack;


package body operpack is

  function shrv4 (a, b : std_logic_vector; mode : std_logic) return std_logic_vector is
    variable shift1R, shift2R, shift4R, shift8R : std_logic_vector(a'RANGE);
    variable fills : std_logic_vector(a'LENGTH-1 downto a'LENGTH/2);
  begin
   if (mode = '1' and a(a'LENGTH-1) = '1') then
     fills := (others => '1');
   else
     fills := (others => '0');
   end if;
   if (b(0) = '1') then
     shift1R := fills(a'LENGTH-1 downto a'LENGTH-1) & a(a'LENGTH-1 downto 1);
   else
     shift1R := a;
   end if;
   if (b(1) = '1') then
     shift2R := fills(a'LENGTH-1 downto a'LENGTH-2) & shift1R(a'LENGTH-1 downto 2);
   else
     shift2R := shift1R;
   end if;
   if (b(2) = '1') then
     shift4R := fills(a'LENGTH-1 downto a'LENGTH-4) & shift2R(a'LENGTH-1 downto 4);
   else
     shift4R := shift2R;
   end if;
   if (b(3) = '1') then
     shift8R := fills(a'LENGTH-1 downto a'LENGTH-8) & shift4R(a'LENGTH-1 downto 8);
   else
     shift8R := shift4R;
   end if;
   return (shift8R);
  end shrv4;

end operpack;
