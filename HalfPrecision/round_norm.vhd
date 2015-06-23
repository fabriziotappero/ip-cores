----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:44:49 02/05/2013 
-- Design Name: 
-- Module Name:    round_norm - Behavioral 
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

entity round_norm is
	generic ( OPERAND_SIZE : natural := 24;
				MANTISSA_SIZE : natural := 12;
				RND_PREC : natural := 0; --0 RNE, 1 Trunc
				PIPELINE: natural := 1); -- 0 - no pipeline
	port ( clk, rst : std_logic; 
			mantissa_in : in std_logic_vector (OPERAND_SIZE + 1 downto 0);
			mantissa_out: out std_logic_vector (MANTISSA_SIZE - 1 downto 0);
			neg : in std_logic;
			ovf_norm : out std_logic_vector(1 downto 0);
			ovf_rnd : out std_logic);
end round_norm;

architecture Behavioral of round_norm is

	component d_ff
		generic (N: natural := 8);
		port (clk, rst : in std_logic;
				d : in std_logic_vector (N-1 downto 0);
				q : out std_logic_vector (N-1 downto 0));
	end component;

	signal l,g, s: std_logic;
	signal rnd_dec_d, rnd_dec_q : std_logic_vector (0 downto 0);
	
	signal mantissa_temp_norm : std_logic_vector (OPERAND_SIZE - 1 downto 0);
	signal mantissa_add_d : std_logic_vector (MANTISSA_SIZE downto 0);
	signal mantissa_add_q : std_logic_vector (MANTISSA_SIZE downto 0);
	signal mantissa_rnd : std_logic_vector (MANTISSA_SIZE downto 0);
	
	
begin
	
	ovf_norm <= "10" when mantissa_in (OPERAND_SIZE + 1) = '1' else
					"01" when mantissa_in (OPERAND_SIZE) = '1' else
					"00";
	
	mantissa_temp_norm <= mantissa_in(OPERAND_SIZE + 1 downto 2) when mantissa_in(OPERAND_SIZE + 1) = '1' else
								mantissa_in(OPERAND_SIZE downto 1) when mantissa_in(OPERAND_SIZE ) = '1' else
								mantissa_in (OPERAND_SIZE - 1 downto 0);
	
	RNE: 
	if(RND_PREC = 0) generate
		s <= 	'0' when (mantissa_temp_norm (OPERAND_SIZE - 1 - MANTISSA_SIZE - 1 downto 0) =  (OPERAND_SIZE - 1 - MANTISSA_SIZE - 1 downto 0 => '0') and mantissa_in(0) = '0' and mantissa_in (1) = '0') else
				'1';
		l <= mantissa_temp_norm (OPERAND_SIZE - 1 - MANTISSA_SIZE + 1);
		g <= mantissa_temp_norm (OPERAND_SIZE - 1 - MANTISSA_SIZE);
		rnd_dec_d (0)<= g and (l or s);
	end generate;
	
	TRUNC:
	if(RND_PREC = 1) generate
		s <= 	'0';
		l <= mantissa_temp_norm (OPERAND_SIZE - 1 - MANTISSA_SIZE + 1);
		g <= '0';
		rnd_dec_d (0)<= g and (l or s);
	end generate;
	
	mantissa_add_d <= "0" & mantissa_temp_norm (OPERAND_SIZE - 1 downto OPERAND_SIZE - 1 - MANTISSA_SIZE + 1);
	
	mantissa_rnd <= mantissa_add_q + rnd_dec_q;
	
	ovf_rnd <= mantissa_rnd (MANTISSA_SIZE);
	
	mantissa_out <= mantissa_rnd (MANTISSA_SIZE downto 1) when mantissa_rnd (MANTISSA_SIZE) = '1' else
						mantissa_rnd (MANTISSA_SIZE - 1 downto 0);	

	
	PIPELINE_INS:
		if PIPELINE /= 0 generate
			MANTISSA_DFF : d_ff generic map (N => MANTISSA_SIZE + 1)
										port map (clk => clk, rst => rst,
													d => mantissa_add_d, q => mantissa_add_q);
			RND_DEC: d_ff generic map (N => 1)
							port map (clk => clk, rst => rst,
										d => rnd_dec_d, q=> rnd_dec_q);
		
		end generate;
	NO_PIPELINE:
		if PIPELINE = 0 generate
			mantissa_add_q <= mantissa_add_d;
			rnd_dec_q <= rnd_dec_d;
		
		end generate;


end Behavioral;

