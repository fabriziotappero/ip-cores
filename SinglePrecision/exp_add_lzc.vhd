----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:35:50 02/07/2013 
-- Design Name: 
-- Module Name:    exp_add_lzc - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity exp_add_lzc is
	generic( SIZE_EXP : natural := 5;
				SIZE_LZC : natural := 4);
	port (exp_in : in std_logic_vector(SIZE_EXP - 1 downto 0);
				lzc : in std_logic_vector(SIZE_LZC - 1 downto 0);
				exp_out : out std_logic_vector (SIZE_EXP - 1 downto 0));
end exp_add_lzc;

architecture Behavioral of exp_add_lzc is

	signal bias : std_logic_vector(SIZE_EXP - 1 downto 0);
	--signal lzc_fp: std_logic_vector(SIZE_LZC - 1 downto 0);
	
begin
	bias_gen:
		for i in 0 to SIZE_EXP - 3 generate
			one_bit : bias (i) <= '1';
		end generate;
		
	bias (SIZE_EXP-1 downto SIZE_EXP - 2) <= "00";
	--lzc_fp <= 	"000000" when (lzc < "010001") else
	--			"010001";
	
	--exp_out <= exp_in - lzc - bias;
	exp_out <= exp_in - lzc - bias + 1;
	
end Behavioral;

