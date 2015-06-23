
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
  
ENTITY tb_xtea IS
END tb_xtea;
 
ARCHITECTURE behavior OF tb_xtea IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT xtea
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
	 enc : in std_logic;
         block_in : IN  std_logic_vector(63 downto 0);
         key : IN  std_logic_vector(127 downto 0);
	 v_0_out : out std_logic_vector(31 downto 0);
	 v_1_out : out std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal enc : std_logic := '0';	
   signal block_in : std_logic_vector(63 downto 0) := (others => '0');
   signal key : std_logic_vector(127 downto 0) := (others => '0');

 	--Outputs
	signal v_0_out : std_logic_vector(31 downto 0);
	signal v_1_out : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: xtea PORT MAP (
          clk => clk,
          rst => rst,
	  enc => enc,
          block_in => block_in,
          key => key,
          v_0_out => v_0_out,
	  v_1_out => v_1_out
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
		wait for clk_period/2 + 10*clk_period;
		enc <= '0';
		rst <= '1';
		block_in <= X"bbbbbbbb" & X"aaaaaaaa" ;
		key <= X"44444444" &  X"33333333" & X"22222222" &  X"11111111";

		wait for clk_period;
		
		rst <= '0';

		wait for 4*64*clk_period;

		assert v_0_out = X"3a53039a"
			report "ENCRYPT ERROR (v_0)" severity FAILURE;
			
		wait for clk_period;

		assert v_1_out = X"fe2d9913"
			report "ENCRYPT ERROR (v_1)" severity FAILURE;

		wait for clk_period*10;
		enc <= '1';
		rst <= '1';
		block_in <= X"fe2d9913" & X"3a53039a" ;
		key <= X"44444444" &  X"33333333" & X"22222222" &  X"11111111";

		wait for clk_period;
		
		rst <= '0';

		wait for 4*64*clk_period;

		assert v_0_out = X"bbbbbbbb"
			report "DECRYPT ERROR (v_0)" severity FAILURE;
			
		wait for clk_period;

		assert v_1_out = X"aaaaaaaa" 
			report "DECRYPT ERROR (v_1)" severity FAILURE;		
		

      wait;
   end process;

END;
