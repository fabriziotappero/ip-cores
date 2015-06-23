--------------------------------------------------------------------------------
-- Company: University of Vigo
-- Engineer:  L. Jacobo Alvarez Ruiz de Ojeda
--
-- Create Date:    10:00:00 10/18/06
-- Design Name:    
-- Module Name:    shift9_R - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description: 9 bits shift register with serial in and parallel out, shift_enable control signal
-- and right shifting.
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

entity shift9_r is
    Port ( clk : in std_logic;
           reset : in std_logic;
           msb_in : in std_logic;
           shift_enable : in std_logic;
           q_shift : out std_logic_vector(8 downto 0));
end shift9_r;

architecture Behavioral of shift9_r is

signal q_shift_aux: std_logic_vector (8 downto 0);

begin

-- Signal assignment
q_shift <= q_shift_aux;

process (clk, reset, msb_in, shift_enable, q_shift_aux)
begin
   if reset ='1' then 
      q_shift_aux <= "000000000"; 
   elsif clk'event and clk='1' then  
		if shift_enable = '1' then
			q_shift_aux <= msb_in & q_shift_aux (8 downto 1);
      end if; 
   end if;
end process;

end Behavioral;
