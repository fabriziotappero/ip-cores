-- functions for resizing vectors with the comma located at the MSB
-- resize_to_msb_trunc realizes a truncation to the new wordsize, if new_size is lower than old size
-- resize_to_msb_trunc realizes a rounding to the new wordsize, if new_size is lower than old size with the use of one additional adder

-- This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along with this program; 
-- if not, see <http://www.gnu.org/licenses/>.

-- Package Definition
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package resize_tools_pkg is

  -- function declarations
  
  function resize_to_msb_trunc(
    x : std_logic_vector;
    new_size : integer
  ) return std_logic_vector;

  function resize_to_msb_round(
    x : std_logic_vector;
    new_size : integer
  ) return std_logic_vector;
    
end resize_tools_pkg;

-- package body

package body resize_tools_pkg is

  -- function implementations

  function resize_to_msb_trunc(
    x : std_logic_vector;
    new_size : integer
  ) return std_logic_vector is
  	variable x_res : std_logic_vector(new_size-1 downto 0);
  begin
		if new_size > x'length then
			x_res(new_size-1 downto new_size-x'length) := x;
			x_res(new_size-x'length-1 downto 0) := (others => '0');
		elsif x'length >= new_size then
			x_res := x(x'length-1 downto x'length-new_size);
		end if;	
    return x_res;
  end resize_to_msb_trunc;
  
  function resize_to_msb_round(
    x : std_logic_vector;
    new_size : integer
  ) return std_logic_vector is
  	variable x_res : std_logic_vector(new_size-1 downto 0);
  begin
		if x'length = new_size then
			x_res := x;
		elsif new_size > x'length then
			x_res(new_size-1 downto new_size-x'length) := x;
			x_res(new_size-x'length-1 downto 0) := (others => '0');
		elsif x'length > new_size then
			if x(x'length-new_size-1) = '1' then
				x_res := std_logic_vector(signed(x(x'length-1 downto x'length-new_size)) + 1);
			else
				x_res := x(x'length-1 downto x'length-new_size);
			end if;			
		end if;	
    return x_res;
  end resize_to_msb_round;  
  
end resize_tools_pkg;

