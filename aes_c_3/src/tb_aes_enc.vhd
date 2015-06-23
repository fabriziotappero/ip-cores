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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
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
     
		block_in <= X"0f0e0d0c0b0a09080706050403020100";

		sub_key      <= X"0f0e0d0c0b0a09080706050403020100";

                wait for clk_period*2;
		
                wait;
   end process;

END;
