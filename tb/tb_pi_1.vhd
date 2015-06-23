
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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_pi_1 IS
END tb_pi_1;
 
ARCHITECTURE behavior OF tb_pi_1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pi_1
    PORT(
         a_1_in : IN  std_logic_vector(31 downto 0);
         a_2_in : IN  std_logic_vector(31 downto 0);
         a_3_in : IN  std_logic_vector(31 downto 0);
         a_1_out : OUT  std_logic_vector(31 downto 0);
         a_2_out : OUT  std_logic_vector(31 downto 0);
         a_3_out : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal a_1_in : std_logic_vector(31 downto 0) := (others => '0');
   signal a_2_in : std_logic_vector(31 downto 0) := (others => '0');
   signal a_3_in : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal a_1_out : std_logic_vector(31 downto 0);
   signal a_2_out : std_logic_vector(31 downto 0);
   signal a_3_out : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pi_1 PORT MAP (
          a_1_in => a_1_in,
          a_2_in => a_2_in,
          a_3_in => a_3_in,
          a_1_out => a_1_out,
          a_2_out => a_2_out,
          a_3_out => a_3_out
        );


 

   -- Stimulus process
   stim_proc: process
   begin		
		a_1_in <= X"a1abab3c";
      a_2_in <= X"0232b23f";
      a_3_in <= X"f000abbb";
      wait;
   end process;

END;
