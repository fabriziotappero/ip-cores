----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:14:54 02/07/2013 
-- Design Name: 
-- Module Name:    exp_add_norm - Behavioral 
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

entity exp_add_norm is
	generic (SIZE_EXP : natural := 5;
				PIPELINE : natural := 0);
	port (clk, rst : in std_logic;
			exp_in : in std_logic_vector(SIZE_EXP - 1 downto 0);
			ovf_norm : in std_logic_vector (1 downto 0);
			ovf_rnd : in std_logic;
			exp_out : out std_logic_vector(SIZE_EXP - 1 downto 0));
end exp_add_norm;

architecture Behavioral of exp_add_norm is
	
	component d_ff
		generic (N: natural := 8);
		port (clk, rst : in std_logic;
				d : in std_logic_vector (N-1 downto 0);
				q : out std_logic_vector (N-1 downto 0));
	end component;
	
	signal exp_add_d, exp_add_q : std_logic_vector(SIZE_EXP - 1  downto 0);
	
begin
	
	exp_add_d <= exp_in + ovf_norm;
	
	exp_out <= exp_add_q + ovf_rnd;
	
	NO_LATCH:
		if PIPELINE = 0 generate
			no_ins : exp_add_q <= exp_add_d;
		end generate;
	
	LATCH : 
		if PIPELINE = 1 generate
			ins : d_ff generic map (SIZE_EXP)
						port map (clk, rst, exp_add_d, exp_add_q);
		end generate;
	
end Behavioral;

