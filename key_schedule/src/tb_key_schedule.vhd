-- Copyright (c) 2011 Antonio de la Piedra
 
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
  
ENTITY tb_key_schedule IS
END tb_key_schedule;
 
ARCHITECTURE behavior OF tb_key_schedule IS 
  
    COMPONENT key_schedule
	port(clk   : in std_logic;
	     rst   : in std_logic;

	     load  : in std_logic;
	     start : in std_logic;
	     
	     key_in : in std_logic_vector(127 downto 0);
	     
             key_ready : out std_logic;
	     key_out : out std_logic_vector(127 downto 0));

    END COMPONENT;
    

   --Inputs

   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal load : std_logic := '0';
   signal start : std_logic := '0';
   signal key_in : std_logic_vector(127 downto 0);

 	--Outputs
    
   signal key_ready :  std_logic;
   signal key_out :  std_logic_vector(127 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: key_schedule PORT MAP (
         clk => clk,
         rst => rst,
         load => load,
         start => start,
         key_in => key_in,
         key_ready => key_ready,
         key_out => key_out);

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
		
		wait for clk_period/2 + clk_period*2;
		rst <= '1';
		
		wait for clk_period;
		rst <= '0';
		load <= '1';

                key_in <= X"0f0e0d0c0b0a09080706050403020100"; 	     
		wait for clk_period;
		
		load <= '0';
		start <= '1';
		
		wait for 0.55 us;
		
		start <= '0';
		
		wait for 1 us;
		rst <= '1';
		
		wait for clk_period;
		rst <= '0';
		key_in <= (others => '0');
		load <= '1';
		
		wait for clk_period + clk_period/2;
		
		load <= '0';
		start <= '1';
		
		wait for 0.55 us;
		start <= '0';
		
		wait;
   end process;

END;
