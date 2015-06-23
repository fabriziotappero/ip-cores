
-- Copyright (c) 2013 Antonio de la Piedra
 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package sha_fun is

  function sigma_0  (signal x : in std_logic_vector) return std_logic_vector;
  function sigma_1  (signal x : in std_logic_vector) return std_logic_vector;

  function sum_0  (signal x : in std_logic_vector) return std_logic_vector;
  function sum_1  (signal x : in std_logic_vector) return std_logic_vector;

  function chi  (signal x : in std_logic_vector;
					  signal y : in std_logic_vector;
					  signal z : in std_logic_vector) return std_logic_vector;

  function maj  (signal x : in std_logic_vector;
					  signal y : in std_logic_vector;
					  signal z : in std_logic_vector) return std_logic_vector;					 
end sha_fun;


package body sha_fun is

  function sigma_0  (signal x : in std_logic_vector) return std_logic_vector is
	variable tmp_0 : std_logic_vector(31 downto 0);
	variable tmp_1 : std_logic_vector(31 downto 0);
	variable tmp_2 : std_logic_vector(31 downto 0); 
	
	variable r : std_logic_vector(31 downto 0); 
  begin
	tmp_0 := x(6 downto 0) & x(31 downto 7);
	tmp_1 := x(17 downto 0) & x(31 downto 18);
	tmp_2 := "000" & x(31 downto 3);
	
	r := tmp_0 xor tmp_1 xor tmp_2;   
   
	return r; 
  end sigma_0;

  function sigma_1  (signal x : in std_logic_vector) return std_logic_vector is
	variable tmp_0 : std_logic_vector(31 downto 0);
	variable tmp_1 : std_logic_vector(31 downto 0);
	variable tmp_2 : std_logic_vector(31 downto 0); 
	
	variable r : std_logic_vector(31 downto 0); 
  begin
	tmp_0 := x(16 downto 0) & x(31 downto 17);
	tmp_1 := x(18 downto 0) & x(31 downto 19);
	tmp_2 := "0000000000" & x(31 downto 10);
	
	r := tmp_0 xor tmp_1 xor tmp_2; 
   
	return r; 
  end sigma_1;

  function chi  (signal x : in std_logic_vector;
					  signal y : in std_logic_vector;
					  signal z : in std_logic_vector) return std_logic_vector is
					  
    variable r : std_logic_vector(31 downto 0);
	 
  begin
			r := (x and y) xor (not(x) and z); 
			
			return r;
  end chi;

  function maj  (signal x : in std_logic_vector;
					  signal y : in std_logic_vector;
					  signal z : in std_logic_vector) return std_logic_vector is
	  variable r : std_logic_vector(31 downto 0);
  
  begin
		   r := (x and y) xor (x and z) xor (y and z);
		
			return r;

  end maj;  


  function sum_0  (signal x : in std_logic_vector) return std_logic_vector is
	variable tmp_0 : std_logic_vector(31 downto 0);
	variable tmp_1 : std_logic_vector(31 downto 0);
	variable tmp_2 : std_logic_vector(31 downto 0);
	
	variable r : std_logic_vector(31 downto 0);
  begin
	tmp_0 := x(1 downto 0) & x(31 downto 2);
	tmp_1 := x(12 downto 0) & x(31 downto 13);
	tmp_2 := x(21 downto 0) & x(31 downto 22);
	
	r := tmp_0 xor tmp_1 xor tmp_2;
	
	return r;
	
  end sum_0;
  
  function sum_1  (signal x : in std_logic_vector) return std_logic_vector is
	variable tmp_0 : std_logic_vector(31 downto 0);
	variable tmp_1 : std_logic_vector(31 downto 0);
	variable tmp_2 : std_logic_vector(31 downto 0);
	
	variable r : std_logic_vector(31 downto 0);
  begin

	tmp_0 := x(5 downto 0) & x(31 downto 6);
	tmp_1 := x(10 downto 0) & x(31 downto 11);
	tmp_2 := x(24 downto 0) & x(31 downto 25);
	
	r := tmp_0 xor tmp_1 xor tmp_2;
	
	return r;
  end sum_1;
  
 end sha_fun;
