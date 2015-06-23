
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
  
ENTITY tb_rc_gen IS
END tb_rc_gen;
 
ARCHITECTURE behavior OF tb_rc_gen IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rc_gen
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         enc : IN  std_logic;
         rc_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal enc : std_logic := '0';

 	--Outputs
   signal rc_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rc_gen PORT MAP (
          clk => clk,
          rst => rst,
          enc => enc,
          rc_out => rc_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for clk_period/2 + clk_period;
		rst <= '1';
		enc <= '0';
		wait for clk_period;
		rst <= '0';
		
		wait for clk_period*15;
		rst <= '1';
		enc <= '1';
		wait for clk_period;
		rst <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
