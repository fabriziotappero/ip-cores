--------------------------------------------------------------------------------
-- Object        : Package work.package_hash10_48b
-- Last modified : Thu Oct 10 12:37:02 2013.
--------------------------------------------------------------------------------



library ieee, std;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------------------------------------
-- Library declaration
---------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

---------------------------------------------------------------------------------------------------------------
-- Package declaration
---------------------------------------------------------------------------------------------------------------
package package_hash10_48b is

  -------------------------------------------------------------------------
  -- functions to calculate CRC on the fly
  -------------------------------------------------------------------------
  function CALC_HASH10_48b
    (data : std_logic_vector(47 downto 0))
    return std_logic_vector;
    
end package_hash10_48b;

package body package_hash10_48b is

  --=============================================================================================================
  -- Process		  : 
  -- Description	: 
  --=============================================================================================================     
  function CALC_HASH10_48b
  (data: std_logic_vector(47 downto 0))
  return std_logic_vector is
  
  variable d:      std_logic_vector(47 downto 0);
  variable hash: std_logic_vector(9 downto 0);
  
  begin
    d := data;
    
    hash(0) := d(46) xor d(42) xor d(41) xor d(39) xor d(37) xor d(36) xor d(34) xor d(33) xor d(32) xor d(31) xor d(30) xor d(28) xor d(27) xor d(24) xor d(23) xor d(19) xor d(17) xor d(16) xor d(15) xor d(9)  xor d(4)  xor d(3) xor d(2) xor d(1) xor d(0);
    hash(1) := d(47) xor d(46) xor d(43) xor d(41) xor d(40) xor d(39) xor d(38) xor d(36) xor d(35) xor d(30) xor d(29) xor d(27) xor d(25) xor d(23) xor d(20) xor d(19) xor d(18) xor d(15) xor d(10) xor d(9)  xor d(5)  xor d(0);
    hash(2) := d(47) xor d(44) xor d(42) xor d(41) xor d(40) xor d(39) xor d(37) xor d(36) xor d(31) xor d(30) xor d(28) xor d(26) xor d(24) xor d(21) xor d(20) xor d(19) xor d(16) xor d(11) xor d(10) xor d(6)  xor d(1);
    hash(3) := d(45) xor d(43) xor d(42) xor d(41) xor d(40) xor d(38) xor d(37) xor d(32) xor d(31) xor d(29) xor d(27) xor d(25) xor d(22) xor d(21) xor d(20) xor d(17) xor d(12) xor d(11) xor d(7)  xor d(2);
    hash(4) := d(44) xor d(43) xor d(38) xor d(37) xor d(36) xor d(34) xor d(31) xor d(27) xor d(26) xor d(24) xor d(22) xor d(21) xor d(19) xor d(18) xor d(17) xor d(16) xor d(15) xor d(13) xor d(12) xor d(9)  xor d(8)  xor d(4) xor d(2) xor d(1) xor d(0);
    hash(5) := d(46) xor d(45) xor d(44) xor d(42) xor d(41) xor d(38) xor d(36) xor d(35) xor d(34) xor d(33) xor d(31) xor d(30) xor d(25) xor d(24) xor d(22) xor d(20) xor d(18) xor d(15) xor d(14) xor d(13) xor d(10) xor d(5) xor d(4) xor d(0);
    hash(6) := d(47) xor d(46) xor d(45) xor d(43) xor d(42) xor d(39) xor d(37) xor d(36) xor d(35) xor d(34) xor d(32) xor d(31) xor d(26) xor d(25) xor d(23) xor d(21) xor d(19) xor d(16) xor d(15) xor d(14) xor d(11) xor d(6) xor d(5) xor d(1);
    hash(7) := d(47) xor d(46) xor d(44) xor d(43) xor d(40) xor d(38) xor d(37) xor d(36) xor d(35) xor d(33) xor d(32) xor d(27) xor d(26) xor d(24) xor d(22) xor d(20) xor d(17) xor d(16) xor d(15) xor d(12) xor d(7)  xor d(6) xor d(2);
    hash(8) := d(47) xor d(45) xor d(44) xor d(41) xor d(39) xor d(38) xor d(37) xor d(36) xor d(34) xor d(33) xor d(28) xor d(27) xor d(25) xor d(23) xor d(21) xor d(18) xor d(17) xor d(16) xor d(13) xor d(8)  xor d(7)  xor d(3);
    hash(9) := d(45) xor d(41) xor d(40) xor d(38) xor d(36) xor d(35) xor d(33) xor d(32) xor d(31) xor d(30) xor d(29) xor d(27) xor d(26) xor d(23) xor d(22) xor d(18) xor d(16) xor d(15) xor d(14) xor d(8)  xor d(3)  xor d(2) xor d(1) xor d(0);
    
    return hash;
  end CALC_HASH10_48b;

end package_hash10_48b;