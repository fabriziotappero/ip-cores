----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:08:09 02/02/2013 
-- Design Name: 
-- Module Name:    right_shift - Behavioral 
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
use IEEE.numeric_std.all;
use IEEE.math_real.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift is
	generic (INPUT_SIZE : natural := 13;
				SHIFT_SIZE : natural := 4;
				OUTPUT_SIZE : natural := 24;
				DIRECTION : natural := 1;  -- 1 for left shift; 0 for right shift
				PIPELINE : natural := 1; -- 1 if pipelined , 0 no pipeline
				POSITION : std_logic_vector(7 downto 0) := "00000100"); -- the position of pipeline registers
	port (clk, rst : in std_logic;
			a : in std_logic_vector (INPUT_SIZE - 1 downto 0);
			arith : in std_logic;
			shft : in std_logic_vector (SHIFT_SIZE - 1 downto 0);
			shifted_a : out std_logic_vector (OUTPUT_SIZE - 1 downto 0));
end shift;

architecture Behavioral of shift is

	type shift_results is array (0 to SHIFT_SIZE) of std_logic_vector(OUTPUT_SIZE - 1 downto 0);
	
	component d_ff
		generic (N: natural := 8);
		port (clk, rst : in std_logic;
				d : in std_logic_vector (N-1 downto 0);
				q : out std_logic_vector (N-1 downto 0));
	end component;
	
	
	signal a_temp_d : shift_results;
	signal a_temp_q : shift_results;
	
begin
	
	a_temp_q (0) (OUTPUT_SIZE - 1 downto OUTPUT_SIZE - INPUT_SIZE) <= a;
	a_temp_q (0) (OUTPUT_SIZE - 1 - INPUT_SIZE downto 0) <= (others => arith);
	
	BARREL_SHIFTER_GENERATION:
		for i in 0 to SHIFT_SIZE - 1 generate
			LEFT : if DIRECTION = 1 generate
						MUX_GEN_L: 
							for j in 0 to OUTPUT_SIZE - 1 generate
								ZERO_INS_L:
									if j < 2**i generate
										MUX_L1: a_temp_d(i)(j) <= a_temp_q(i)(j) when shft(i) = '0' else
																		arith;
									end generate ZERO_INS_L;
								
								BIT_INS_L:
									if j >= 2**i generate
										MUX_L2: a_temp_d(i)(j) <= a_temp_q(i)(j) when shft(i) = '0' else
																		a_temp_q(i)(j-2**i);
									end generate BIT_INS_L;
							end generate MUX_GEN_L;
			end generate LEFT;
			
			RIGHT : if DIRECTION = 0 generate
				MUX_GEN_R: 
							for j in 0 to OUTPUT_SIZE - 1 generate
								ZERO_INS_R:
									if OUTPUT_SIZE - 1 < 2**i + j generate
										MUX_R1: a_temp_d(i)(j) <= a_temp_q(i)(j) when shft(i) = '0' else
																		arith;
									end generate ZERO_INS_R;
								
								BIT_INS_R:
									if  OUTPUT_SIZE - 1 >= 2**i + j generate
										MUX_R2: a_temp_d(i)(j) <= a_temp_q(i)(j) when shft(i) = '0' else
																		a_temp_q(i)(j+2**i);
									end generate BIT_INS_R;
																	
					end generate MUX_GEN_R;
			end generate RIGHT;
			
			PIPELINE_INSERTION:
				if PIPELINE /= 0 generate	
							LATCH :
									if (POSITION (i) = '1') generate
										D_INS: d_ff 	generic map (N => OUTPUT_SIZE)
															port map ( clk => clk, rst => rst,
																d => a_temp_d(i), q => a_temp_q(i+1));
									end generate LATCH;
							NO_LATCH:
									if (POSITION (i) = '0' ) generate
										ASSIGN : a_temp_q(i+1) <= a_temp_d(i);
									end generate NO_LATCH;
						
				end generate PIPELINE_INSERTION;				
			
			NO_PIPELINE:
				if PIPELINE = 0 generate
					NO_INS:	a_temp_q(i+1) <= a_temp_d(i);
				end generate NO_PIPELINE;
		
		end generate BARREL_SHIFTER_GENERATION;
	
	shifted_a <= a_temp_q(SHIFT_SIZE);
	
	

end Behavioral;

