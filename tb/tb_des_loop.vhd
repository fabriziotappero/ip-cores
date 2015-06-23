
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
  
ENTITY tb_des_loop IS
END tb_des_loop;
 
ARCHITECTURE behavior OF tb_des_loop IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT des_loop
	port(clk :  in std_logic;
		  rst : in std_logic;
		  mode : in std_logic; -- 0 encrypt, 1 decrypt
		  key_in : in std_logic_vector(63 downto 0);
		  key_pre_w_in : in std_logic_vector(63 downto 0);
		  key_pos_w_in : in std_logic_vector(63 downto 0);
		  blk_in : in std_logic_vector(63 downto 0);
		  blk_out : out std_logic_vector(63 downto 0));
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal mode : std_logic := '0';
   signal key_in : std_logic_vector(63 downto 0) := (others => '0');
   signal blk_in : std_logic_vector(63 downto 0) := (others => '0');

	signal key_pre_w_in : std_logic_vector(63 downto 0);
	signal key_pos_w_in : std_logic_vector(63 downto 0);

 	--Outputs
   signal blk_out : std_logic_vector(63 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: des_loop PORT MAP (
          clk => clk,
          rst => rst,
          mode => mode,
          key_in => key_in,
			 key_pre_w_in => key_pre_w_in,
			 key_pos_w_in => key_pos_w_in,		 
          blk_in => blk_in,
          blk_out => blk_out
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
		mode <= '0';
		blk_in <= X"4E45565251554954";
		key_in <= X"4B41534849534142";
		key_pre_w_in <= X"F0DE87C455F0247D";
		key_pos_w_in <= X"BC8E72E928DFDD66";	
		rst <= '1';
		wait for clk_period;
		rst <= '0';
      wait for clk_period*16;
		
		assert blk_out = X"A937617ABB16ED28"
			report "ENCRYPT ERROR" severity FAILURE;
			
		wait for clk_period;

		mode <= '1';
		blk_in <=  X"A937617ABB16ED28";
		key_in <=  X"4B41534849534142";
		key_pre_w_in <= X"F0DE87C455F0247D";
		key_pos_w_in <= X"BC8E72E928DFDD66";			
		rst <= '1';
		wait for clk_period;
		rst <= '0';
      wait for clk_period*16;		

		assert blk_out = X"4E45565251554954"
			report "DECRYPT ERROR" severity FAILURE;

      wait;
   end process;

END;
