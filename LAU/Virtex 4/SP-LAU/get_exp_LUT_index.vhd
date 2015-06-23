----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:25:14 06/22/2009 
-- Design Name: 
-- Module Name:    get_exp_LUT_index - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity get_exp_LUT_index is
    Port ( input_val : in  STD_LOGIC_VECTOR (7 downto 0);
           output_val : out  STD_LOGIC_VECTOR (6 downto 0);
			  get_negative_val : out std_logic);
end get_exp_LUT_index;

architecture Behavioral of get_exp_LUT_index is

constant value_254 : std_logic_vector(7 downto 0):="11111110";
signal under_127_vec , greater_127_vec : std_logic_vector(6 downto 0);
signal tmp_val : std_logic_Vector(7 downto 0);
begin

under_127_vec<=(others=>not input_val(7));
greater_127_vec<=(others=>input_val(7));
get_negative_val<=input_val(7);
tmp_val <= value_254 - input_val;

output_val <= (tmp_val(6 downto 0) and greater_127_vec) or (input_val(6 downto 0) and under_127_vec);
end Behavioral;

