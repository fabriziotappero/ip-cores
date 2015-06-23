
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

ENTITY tb_theta IS
END tb_theta;
 
ARCHITECTURE behavior OF tb_theta IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT theta
    PORT(
         clk : IN  std_logic;
         a_0_in : IN  std_logic_vector(31 downto 0);
         a_1_in : IN  std_logic_vector(31 downto 0);
         a_2_in : IN  std_logic_vector(31 downto 0);
         a_3_in : IN  std_logic_vector(31 downto 0);
         k_0_in : IN  std_logic_vector(31 downto 0);
         k_1_in : IN  std_logic_vector(31 downto 0);
         k_2_in : IN  std_logic_vector(31 downto 0);
         k_3_in : IN  std_logic_vector(31 downto 0);
         a_0_out : OUT  std_logic_vector(31 downto 0);
         a_1_out : OUT  std_logic_vector(31 downto 0);
         a_2_out : OUT  std_logic_vector(31 downto 0);
         a_3_out : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal a_0_in : std_logic_vector(31 downto 0) := (others => '0');
   signal a_1_in : std_logic_vector(31 downto 0) := (others => '0');
   signal a_2_in : std_logic_vector(31 downto 0) := (others => '0');
   signal a_3_in : std_logic_vector(31 downto 0) := (others => '0');
   signal k_0_in : std_logic_vector(31 downto 0) := (others => '0');
   signal k_1_in : std_logic_vector(31 downto 0) := (others => '0');
   signal k_2_in : std_logic_vector(31 downto 0) := (others => '0');
   signal k_3_in : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal a_0_out : std_logic_vector(31 downto 0);
   signal a_1_out : std_logic_vector(31 downto 0);
   signal a_2_out : std_logic_vector(31 downto 0);
   signal a_3_out : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: theta PORT MAP (
          clk => clk,
          a_0_in => a_0_in,
          a_1_in => a_1_in,
          a_2_in => a_2_in,
          a_3_in => a_3_in,
          k_0_in => k_0_in,
          k_1_in => k_1_in,
          k_2_in => k_2_in,
          k_3_in => k_3_in,
          a_0_out => a_0_out,
          a_1_out => a_1_out,
          a_2_out => a_2_out,
          a_3_out => a_3_out
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

		a_0_in <= X"61396c13";
		a_1_in <= X"637434b8";
		a_2_in <= X"fc6559a9";
		a_3_in <= X"5b643f2c";
		
		k_0_in <= X"4ED2552D";
		k_1_in <= X"1AE69D5D";
		k_2_in <= X"C9B75C29";		
		k_3_in <= X"0C49E157";

		wait for clk_period;

		k_0_in <= (others => '0');
		k_1_in <= (others => '0');
		k_2_in <= (others => '0');
		k_3_in <= (others => '0');

		a_0_in <= X"4ED2552D";
		a_1_in <= X"1AE69D5D";
		a_2_in <= X"C9B75C29";
		a_3_in <= X"0C49E157";
		
		wait for clk_period;

		a_0_in <= X"200d6ff9";
		a_1_in <= X"02667af7";
		a_2_in <= X"3a345347";		
		a_3_in <= X"2cd90d69";

		k_0_in <= X"fd178c4d";
		k_1_in <= X"fc0df5d7";
		k_2_in <= X"7a728549";		
		k_3_in <= X"eaa289dd";
				
      wait;
   end process;

END;
