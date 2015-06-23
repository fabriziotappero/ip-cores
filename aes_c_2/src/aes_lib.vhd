
-- Two Galois multiplication functions based on http://www.isaakian.com/VHDL/AES/.

library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;


package aes_lib is

  function gfmult2 (
     I : std_logic_vector(7 downto 0))
    return std_logic_vector;
  
  function gfmult3 (
     I : std_logic_vector(7 downto 0))
    return std_logic_vector;

  
end aes_lib;


package body aes_lib is

    function gfmult2 (
     I : std_logic_vector(7 downto 0))
    return std_logic_vector is
      variable  result : std_logic_vector(7 downto 0);      
    begin

      result := (I(6 downto 0) & '0') xor (x"1B" and ("000" & I(7)& I(7) & "0" & I(7)& I(7)));
      return result;
    end gfmult2;

    function gfmult3 (
     I : std_logic_vector(7 downto 0))
    return std_logic_vector is
      variable result : std_logic_vector(7 downto 0);   
    begin
      result := gfmult2(I) xor I;
      return result;
    end gfmult3;
	 
end aes_lib;
