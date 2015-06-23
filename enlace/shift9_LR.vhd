--------------------------------------------------------------------------------
-- Company: University of Vigo
-- Engineer:  L. Jacobo Alvarez Ruiz de Ojeda
--
-- Create Date:    17:58:19 10/17/06
-- Design Name:    
-- Module Name:    shift9_LR - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description: 9 bits shift register with parallel load of the 8 least significant bits, independent load
-- for the 9th bit, shift_enable control signal and right shifting (through LSB output).
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

entity shift9_LR is
    Port ( clk : in std_logic;
           reset : in std_logic;
           load_8_lsb_bits : in std_logic;
			  load_msb_bit : in std_logic;
           data_in : in std_logic_vector(7 downto 0);
			  msb_in: in std_logic;
           shift_enable : in std_logic;
			  q_shift: out std_logic_vector(8 downto 0);
           lsb_out : out std_logic
			  );
end shift9_LR;

architecture Behavioral of shift9_LR is

signal q_shift_aux: std_logic_vector (8 downto 0);

begin

-- Signal assignment
q_shift <= q_shift_aux;

process (clk, reset, load_8_lsb_bits, load_msb_bit, shift_enable, q_shift_aux)
begin
   if reset ='1' then 
      q_shift_aux <= "000000000"; 
   elsif clk'event and clk='1' then  
		if shift_enable = '0' then

			if load_8_lsb_bits = '1' then 
   	   	q_shift_aux (7 downto 0) <= data_in;
			end if;

			if load_msb_bit = '1' then 
      		q_shift_aux (8) <= msb_in;
			end if;

		else
			q_shift_aux <= '0' & q_shift_aux (8 downto 1);
      end if; 
   end if;
lsb_out <= q_shift_aux (0);

end process;

end Behavioral;
