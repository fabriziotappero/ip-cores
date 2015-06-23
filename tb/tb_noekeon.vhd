
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
  
ENTITY tb_noekeon IS
END tb_noekeon;
 
ARCHITECTURE behavior OF tb_noekeon IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT noekeon
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         enc : IN  std_logic;
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
   signal rst : std_logic := '0';
   signal enc : std_logic := '0';
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
   uut: noekeon PORT MAP (
          clk => clk,
          rst => rst,
          enc => enc,
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
		rst <= '1';
		enc <= '0';
		
		a_0_in <= X"2a78421b";
		a_1_in <= X"87c7d092";		
		a_2_in <= X"4f26113f";
		a_3_in <= X"1d1349b2";

		k_0_in <= X"b1656851";
		k_1_in <= X"699e29fa";
		k_2_in <= X"24b70148";
		k_3_in <= X"503d2dfc";		
		
		wait for clk_period;
		rst <= '0';

		wait for clk_period*15 + clk_period/2;

      assert a_0_out = X"e2f687e0"
			report "ENCRYPT ERROR (a_0)" severity FAILURE;		

      assert a_1_out = X"7b75660f"
			report "ENCRYPT ERROR (a_1)" severity FAILURE;		

      assert a_2_out = X"fc372233"
			report "ENCRYPT ERROR (a_2)" severity FAILURE;	

      assert a_3_out = X"bc47532c"
			report "ENCRYPT ERROR (a_3)" severity FAILURE;	

		wait for clk_period + clk_period/2;
		rst <= '1';
		enc <= '1';
		
		a_0_in <= X"e2f687e0";
		a_1_in <= X"7b75660f";		
		a_2_in <= X"fc372233";
		a_3_in <= X"bc47532c";

		k_0_in <= X"b1656851";
		k_1_in <= X"699e29fa";
		k_2_in <= X"24b70148";
		k_3_in <= X"503d2dfc";		
		
		wait for clk_period;
		rst <= '0';		

		wait for clk_period*15 + clk_period/2;

      assert a_0_out = X"2a78421b"
			report "DECRYPT ERROR (a_0)" severity FAILURE;		

      assert a_1_out = X"87c7d092"
			report "DECRYPT ERROR (a_1)" severity FAILURE;		

      assert a_2_out = X"4f26113f"
			report "DECRYPT ERROR (a_2)" severity FAILURE;	

      assert a_3_out = X"1d1349b2"
			report "DECRYPT ERROR (a_3)" severity FAILURE;	

      wait;
   end process;

END;
