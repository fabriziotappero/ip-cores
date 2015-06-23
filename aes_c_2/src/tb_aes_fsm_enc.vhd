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
 
ENTITY tb_aes_fsm_enc IS
END tb_aes_fsm_enc;
 
ARCHITECTURE behavior OF tb_aes_fsm_enc IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT aes_fsm_enc
	port(	  clk: in std_logic;
		  rst : in std_logic;
		  block_in : in std_logic_vector(127 downto 0);
		  key : in std_logic_vector(127 downto 0);
		  enc : in std_logic;
		  block_out : out std_logic_vector(127 downto 0);
		  block_ready : out std_logic);
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal block_in : std_logic_vector(127 downto 0) := (others => '0');
   signal key : std_logic_vector(127 downto 0) := (others=> '0');
   signal enc : std_logic := '0';

 	--Outputs
   signal block_out : std_logic_vector(127 downto 0);
   signal block_ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: aes_fsm_enc PORT MAP (
          clk => clk,
          rst => rst,
          block_in => block_in,
          key => key,
          enc => enc,
          block_out => block_out,
          block_ready => block_ready);

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
                enc <= '1';
                		
		block_in <= X"0f0e0d0c0b0a09080706050403020100";
		key      <= X"0f0e0d0c0b0a09080706050403020100";
		
		wait for 0.815 us;
		enc <= '0';
		
		wait for 2 us;
		
		enc <= '1';
		
		wait for 0.195 us;
		
		enc <= '0';
		
		wait for 1.23 us;
		
		enc <= '1';
		
                wait;
   end process;

END;
