--------------------------------------------------------------------------------
-- Object        : Package work.package_hash10_24b
-- Last modified : Thu Oct 10 12:37:21 2013.
--------------------------------------------------------------------------------



library ieee, std;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------------------------------------
-- Package declaration
---------------------------------------------------------------------------------------------------------------
package package_hash10_24b is

  -------------------------------------------------------------------------
  -- functions to calculate CRC on the fly
  -------------------------------------------------------------------------
  function CALC_HASH10_24b
    (data : std_logic_vector(23 downto 0))
    return std_logic_vector;
    
end package_hash10_24b;

package body package_hash10_24b is

  --=============================================================================================================
  -- Process		  : 
  -- Description	: 
  --=============================================================================================================     
  function CALC_HASH10_24b
  (data: std_logic_vector(23 downto 0))
  return std_logic_vector is
  
  variable d:      std_logic_vector(23 downto 0);
  variable hash: std_logic_vector(9 downto 0);
  
  begin
    d := data;
    
    hash(0) := d(23) xor d(19) xor d(17) xor d(16) xor d(15) xor d(9)  xor d(4)  xor d(3)  xor d(2)  xor d(1) xor d(0);
    hash(1) := d(23) xor d(20) xor d(19) xor d(18) xor d(15) xor d(10) xor d(9)  xor d(5)  xor d(0);
    hash(2) := d(21) xor d(20) xor d(19) xor d(16) xor d(11) xor d(10) xor d(6)  xor d(1);
    hash(3) := d(22) xor d(21) xor d(20) xor d(17) xor d(12) xor d(11) xor d(7)  xor d(2);
    hash(4) := d(22) xor d(21) xor d(19) xor d(18) xor d(17) xor d(16) xor d(15) xor d(13) xor d(12) xor d(9) xor d(8) xor d(4) xor d(2) xor d(1) xor d(0);
    hash(5) := d(22) xor d(20) xor d(18) xor d(15) xor d(14) xor d(13) xor d(10) xor d(5)  xor d(4)  xor d(0);
    hash(6) := d(23) xor d(21) xor d(19) xor d(16) xor d(15) xor d(14) xor d(11) xor d(6)  xor d(5)  xor d(1);
    hash(7) := d(22) xor d(20) xor d(17) xor d(16) xor d(15) xor d(12) xor d(7)  xor d(6)  xor d(2);
    hash(8) := d(23) xor d(21) xor d(18) xor d(17) xor d(16) xor d(13) xor d(8)  xor d(7)  xor d(3);
    hash(9) := d(23) xor d(22) xor d(18) xor d(16) xor d(15) xor d(14) xor d(8)  xor d(3)  xor d(2)  xor d(1) xor d(0);
    
    return hash;
  end CALC_HASH10_24b;

end package_hash10_24b;