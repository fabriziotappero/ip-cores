----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:32:21 02/06/2013 
-- Design Name: 
-- Module Name:    exponent_align - Behavioral 
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
use IEEE.STD_LOGIC_SIGNED.all;
use ieee.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity exponent_align is
	generic (SIZE_EXP : natural := 5;
				PIPELINE : natural := 2); -- nr of pipeline registers -- max 2
	port (clk, rst : in std_logic;
			exp_a, exp_b : in std_logic_vector (SIZE_EXP - 1 downto 0);
			exp_c : in std_logic_vector (SIZE_EXP - 1 downto 0);
			align : out std_logic_vector (SIZE_EXP - 1 downto 0);
			exp_int : out std_logic_vector (SIZE_EXP downto 0);
			comp : out std_logic);
end exponent_align;

architecture Behavioral of exponent_align is

	component d_ff
		generic (N: natural := 8);
		port (clk, rst : in std_logic;
				d : in std_logic_vector (N-1 downto 0);
				q : out std_logic_vector (N-1 downto 0));
	end component;

	signal exp_a_x_b_bias : std_logic_vector(SIZE_EXP downto 0);
	signal exp_a_x_b_d1, exp_a_x_b_q1 : std_logic_vector (SIZE_EXP downto 0);
	signal exp_a_x_b_q2 : std_logic_vector (SIZE_EXP downto 0);
	
	signal exp_c_d1 : std_logic_vector (SIZE_EXP downto 0);
	signal exp_c_q1, exp_c_q2 : std_logic_vector (SIZE_EXP downto 0);
	
	signal exp_dif_d, exp_dif_q : std_logic_vector(SIZE_EXP downto 0);

	signal bias : std_logic_vector(SIZE_EXP downto 0);
	
begin

	bias_gen:
		for i in 0 to SIZE_EXP - 2 generate
			one_bit : bias (i) <= '1';
		end generate;
		
	bias (SIZE_EXP downto SIZE_EXP - 1) <= "00"; 

	exp_a_x_b_bias <= ("0" & exp_a) + ("0" & exp_b);
	exp_a_x_b_d1 <= exp_a_x_b_bias;
	
	exp_c_d1 <= ("0" & exp_c) + bias;

	exp_dif_d <= exp_c_q1 - exp_a_x_b_q1;
	
	
	exp_int <= exp_c_q2 when exp_dif_q(SIZE_EXP) = '0' else
				exp_a_x_b_q2;

	comp <= exp_dif_q(SIZE_EXP);

	align <= exp_dif_q (SIZE_EXP - 1 downto 0) when exp_dif_q(SIZE_EXP) = '0' else
			 -(exp_dif_q (SIZE_EXP - 1 downto 0));
			 
	--PIPELINING
	ONE_STAGE:
		if (PIPELINE = 1) generate
			A_X_B_1S : D_FF generic map (N => SIZE_EXP+1)
								port map (clk => clk, rst => rst,
										d => exp_a_x_b_d1, q => exp_a_x_b_q1);
			C_1S: D_FF generic map (N => SIZE_EXP + 1)
								port map (clk => clk, rst => rst,
										d => exp_c_d1, q => exp_c_q1);
			ASSIGN_A_X_B_1S : exp_a_x_b_q2 <= exp_a_x_b_q1;
			ASSIGN_C_1S : 	exp_c_q2 <= exp_c_q1;
			ASSIGN_dif_1S : exp_dif_q <= exp_dif_d;
		end generate;
	
	TWO_STAGE:
		if (PIPELINE = 2) generate
			A_X_B_2S_1 : D_FF generic map (N => SIZE_EXP+1)
								port map (clk => clk, rst => rst,
										d => exp_a_x_b_d1, q => exp_a_x_b_q1);
			C_2S_1: D_FF generic map (N => SIZE_EXP+1)
								port map (clk => clk, rst => rst,
										d => exp_c_d1, q => exp_c_q1);
			A_X_B_2S_2 : D_FF generic map (N => SIZE_EXP+1)
								port map (clk => clk, rst => rst,
										d => exp_a_x_b_q1, q => exp_a_x_b_q2);
			C_2S_2: D_FF generic map (N => SIZE_EXP+1)
								port map (clk => clk, rst => rst,
										d => exp_c_q1, q => exp_c_q2);
			DIF_2S : D_FF generic map (N => SIZE_EXP+1)
								port map (clk => clk, rst => rst,
										d => exp_dif_d, q => exp_dif_q);
		end generate;

	NO_STAGE:
		if (PIPELINE = 0) generate
			ASSIGN_A_X_B_NOS_1 : exp_a_x_b_q1 <= exp_a_x_b_d1;
			ASSIGN_C_NOS_1 : 	exp_c_q1 <= exp_c_d1;
			ASSIGN_A_X_B_NOS_2 : exp_a_x_b_q2 <= exp_a_x_b_q1;
			ASSIGN_C_NOS_2 : 	exp_c_q2 <= exp_c_q1;
			ASSIGN_dif_NOS : exp_dif_q <= exp_dif_d;
		end generate;
			

end Behavioral;

