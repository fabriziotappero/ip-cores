--------------------------------------------------------------------------------
-- Object        : Package work.package_crc32_8b
-- Last modified : Thu Oct 10 12:37:58 2013.
--------------------------------------------------------------------------------



library ieee, std;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------------------------------------
-- Package declaration
---------------------------------------------------------------------------------------------------------------
package package_crc32_8b is

  -----------------------------------------------------------------------------------------
  -- functions to invert data/CRC (data: only applicable for the first 32 bits of a packet)
  -----------------------------------------------------------------------------------------
  function INVERT_CRC32_DATA
    (din : std_logic_vector(7 downto 0))
  return std_logic_vector;
    
  function INVERT_CRC32_RESULT
    (din : std_logic_vector(31 downto 0))
  return std_logic_vector;
  
  -------------------------------------------------------------------------
  -- functions to swap bit order due to bit order on physical interface
  -------------------------------------------------------------------------
  function SWAP_CRC32_DATA
    (din : std_logic_vector(7 downto 0))
  return std_logic_vector;
    
  function SWAP_CRC32_RESULT
    (din : std_logic_vector(31 downto 0))
  return std_logic_vector;
    
  -------------------------------------------------------------------------
  -- functions to calculate CRC on the fly
  -------------------------------------------------------------------------
  function CALC_CRC32
    (din : std_logic_vector(7 downto 0);
     cin : std_logic_vector(31 downto 0))
    return std_logic_vector;
end package_crc32_8b;

package body package_crc32_8b is

--=============================================================================================================
-- Process		  : 
-- Description	: 
--=============================================================================================================
  function INVERT_CRC32_DATA
    (din : std_logic_vector(7 downto 0))
  return std_logic_vector is
  begin
    return not(din);
  end INVERT_CRC32_DATA;
  
--=============================================================================================================
-- Process		  : 
-- Description	: 
--=============================================================================================================  
  function INVERT_CRC32_RESULT
    (din : std_logic_vector(31 downto 0))
  return std_logic_vector is
  begin
   return not(din);  
  end INVERT_CRC32_RESULT;
  
--=============================================================================================================
-- Process		  : 
-- Description	: 
--=============================================================================================================  
  function SWAP_CRC32_DATA
    (din : std_logic_vector(7 downto 0))
  return std_logic_vector is

  variable d   : std_logic_vector(7 downto 0);
  
  begin
    d(7) := din(0);
    d(6) := din(1);
    d(5) := din(2);
    d(4) := din(3);
    d(3) := din(4);
    d(2) := din(5);
    d(1) := din(6);
    d(0) := din(7);
    
    return d;
  end SWAP_CRC32_DATA;
  
--=============================================================================================================
-- Process		  : 
-- Description	: 
--=============================================================================================================      
  function SWAP_CRC32_RESULT
    (din : std_logic_vector(31 downto 0))
  return std_logic_vector is
  
  variable d   : std_logic_vector(31 downto 0);
  
  begin
    for i in 3 downto 0 loop
      d(i*8+7) := din(i*8);
      d(i*8+6) := din(i*8+1);
      d(i*8+5) := din(i*8+2);
      d(i*8+4) := din(i*8+3);
      d(i*8+3) := din(i*8+4);
      d(i*8+2) := din(i*8+5);
      d(i*8+1) := din(i*8+6);
      d(i*8+0) := din(i*8+7);
    end loop;
    
    return d;
  end SWAP_CRC32_RESULT;
  
--=============================================================================================================
-- Process		  : 
-- Description	: 
--=============================================================================================================     
    function CALC_CRC32
    (din : std_logic_vector(7 downto 0);
     cin :  std_logic_vector(31 downto 0))
    return std_logic_vector is

    variable d   : std_logic_vector(7 downto 0);
    variable c   : std_logic_vector(31 downto 0);
    variable cout: std_logic_vector(31 downto 0);

    begin
      d := din;
      c := cin;
  
      cout(0) := d(6) xor d(0) xor c(24) xor c(30);
      cout(1) := d(7) xor d(6) xor d(1) xor d(0) xor c(24) xor c(25) xor c(30) xor c(31);
      cout(2) := d(7) xor d(6) xor d(2) xor d(1) xor d(0) xor c(24) xor c(25) xor c(26) xor c(30) xor c(31);
      cout(3) := d(7) xor d(3) xor d(2) xor d(1) xor c(25) xor c(26) xor c(27) xor c(31);
      cout(4) := d(6) xor d(4) xor d(3) xor d(2) xor d(0) xor c(24) xor c(26) xor c(27) xor c(28) xor c(30);
      cout(5) := d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(1) xor d(0) xor c(24) xor c(25) xor c(27) xor c(28) xor c(29) xor c(30) xor c(31);
      cout(6) := d(7) xor d(6) xor d(5) xor d(4) xor d(2) xor d(1) xor c(25) xor c(26) xor c(28) xor c(29) xor c(30) xor c(31);
      cout(7) := d(7) xor d(5) xor d(3) xor d(2) xor d(0) xor c(24) xor c(26) xor c(27) xor c(29) xor c(31);
      cout(8) := d(4) xor d(3) xor d(1) xor d(0) xor c(0) xor c(24) xor c(25) xor c(27) xor c(28);
      cout(9) := d(5) xor d(4) xor d(2) xor d(1) xor c(1) xor c(25) xor c(26) xor c(28) xor c(29);
      cout(10) := d(5) xor d(3) xor d(2) xor d(0) xor c(2) xor c(24) xor c(26) xor c(27) xor c(29);
      cout(11) := d(4) xor d(3) xor d(1) xor d(0) xor c(3) xor c(24) xor c(25) xor c(27) xor c(28);
      cout(12) := d(6) xor d(5) xor d(4) xor d(2) xor d(1) xor d(0) xor c(4) xor c(24) xor c(25) xor c(26) xor c(28) xor c(29) xor c(30);
      cout(13) := d(7) xor d(6) xor d(5) xor d(3) xor d(2) xor d(1) xor c(5) xor c(25) xor c(26) xor c(27) xor c(29) xor c(30) xor c(31);
      cout(14) := d(7) xor d(6) xor d(4) xor d(3) xor d(2) xor c(6) xor c(26) xor c(27) xor c(28) xor c(30) xor c(31);
      cout(15) := d(7) xor d(5) xor d(4) xor d(3) xor c(7) xor c(27) xor c(28) xor c(29) xor c(31);
      cout(16) := d(5) xor d(4) xor d(0) xor c(8) xor c(24) xor c(28) xor c(29);
      cout(17) := d(6) xor d(5) xor d(1) xor c(9) xor c(25) xor c(29) xor c(30);
      cout(18) := d(7) xor d(6) xor d(2) xor c(10) xor c(26) xor c(30) xor c(31);
      cout(19) := d(7) xor d(3) xor c(11) xor c(27) xor c(31);
      cout(20) := d(4) xor c(12) xor c(28);
      cout(21) := d(5) xor c(13) xor c(29);
      cout(22) := d(0) xor c(14) xor c(24);
      cout(23) := d(6) xor d(1) xor d(0) xor c(15) xor c(24) xor c(25) xor c(30);
      cout(24) := d(7) xor d(2) xor d(1) xor c(16) xor c(25) xor c(26) xor c(31);
      cout(25) := d(3) xor d(2) xor c(17) xor c(26) xor c(27);
      cout(26) := d(6) xor d(4) xor d(3) xor d(0) xor c(18) xor c(24) xor c(27) xor c(28) xor c(30);
      cout(27) := d(7) xor d(5) xor d(4) xor d(1) xor c(19) xor c(25) xor c(28) xor c(29) xor c(31);
      cout(28) := d(6) xor d(5) xor d(2) xor c(20) xor c(26) xor c(29) xor c(30);
      cout(29) := d(7) xor d(6) xor d(3) xor c(21) xor c(27) xor c(30) xor c(31);
      cout(30) := d(7) xor d(4) xor c(22) xor c(28) xor c(31);
      cout(31) := d(5) xor c(23) xor c(29);
      
      return cout;
    end CALC_CRC32;

end package_crc32_8b;
