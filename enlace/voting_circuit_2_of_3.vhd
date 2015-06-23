--------------------------------------------------------------------------------
-- Company: University of Vigo
-- Engineer: L. Jacobo Alvarez Ruiz de Ojeda
--
-- Create Date:    10:57:05 10/18/06
-- Design Name:    
-- Module Name:    voting_circuit_2_of_3 - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity voting_circuit_2_of_3 is
    Port ( clk : in std_logic;
           reset : in std_logic;
           load_sample_1 : in std_logic;
           load_sample_2 : in std_logic;
           load_sample_3 : in std_logic;
           bit_input : in std_logic;
           sampled_bit : out std_logic;
           discrepancy : out std_logic);
end voting_circuit_2_of_3;

architecture Behavioral of voting_circuit_2_of_3 is

-- Signals declaration
signal sample_1, sample_2, sample_3: std_logic;
signal sample_vector: std_logic_vector (2 downto 0);

begin

-- Vector of samples
sample_vector <= sample_3 & sample_2 & sample_1;

-- Sample 1 register
Sample_1_register: process (clk, reset, load_sample_1)
begin
if reset = '1' then
	sample_1 <= '0';
elsif clk'event and clk ='1' then
	if load_sample_1 = '1' then sample_1 <= bit_input;
	end if; 
end if;
end process;

-- Sample 2 register
Sample_2_register: process (clk, reset, load_sample_2)
begin
if reset = '1' then
	sample_2 <= '0';
elsif clk'event and clk ='1' then
	if load_sample_2 = '1' then sample_2 <= bit_input;
	end if; 
end if;
end process;

-- Sample 3 register
Sample_3_register: process (clk, reset, load_sample_3)
begin
if reset = '1' then
	sample_3 <= '0';
elsif clk'event and clk ='1' then
	if load_sample_3 = '1' then sample_3 <= bit_input;
	end if; 
end if;
end process;

-- Voting circuit (2 of 3)
with sample_vector select
	sampled_bit <= '1' when "011"|"101"|"110"|"111",
						'0' when others;

with sample_vector select
	discrepancy <= '0' when "000"|"111",
						'1' when others;

end Behavioral;
