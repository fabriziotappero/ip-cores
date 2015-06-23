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
  
ENTITY tb_aes_enc IS
END tb_aes_enc;
 
ARCHITECTURE behavior OF tb_aes_enc IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT aes_enc
    PORT(
         clk : IN  std_logic;
         block_in : IN  std_logic_vector(127 downto 0);
         sub_key : IN std_logic_vector(127 downto 0);
         last : IN std_logic;
         
         block_out : OUT  std_logic_vector(127 downto 0));
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal block_in : std_logic_vector(127 downto 0) := (others => '0');
   signal sub_key : std_logic_vector(127 downto 0) := (others=> '0');
   signal last : std_logic := '0';

 	--Outputs
   signal block_out : std_logic_vector(127 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: aes_enc PORT MAP (
          clk => clk,
          block_in => block_in,
          sub_key => sub_key,
          last => last,
          block_out => block_out);

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
		
		block_in <= X"5b75966825a9e32f5b7c424c37f6652b";
		sub_key  <= X"41bf6904bf0c596cbfc9c2d24e74ffb6";

                wait for clk_period;
		
		assert block_out = X"add6b976204688966765efb4cb5f01d1"
		 report "Stage 1 encryption FAILED" severity FAILURE;

		block_in <= X"add6b976204688966765efb4cb5f01d1";
		sub_key  <= X"fd8d05fdbc326cf9033e3595bcf7f747";

		wait for clk_period;

		assert block_out = X"f191a5f39fe59f7283a1352a4a06178e"
		 report "Stage 2 encryption FAILED" severity FAILURE;
		
                wait;
   end process;

END;
