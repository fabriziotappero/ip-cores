----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:56:33 02/06/2013 
-- Design Name: 
-- Module Name:    lzc_tree - Behavioral 
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
use IEEE.math_real.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lzc_tree is
	generic (SIZE_INT : natural := 42;
				PIPELINE : natural := 2);
	port (clk, rst : in std_logic; 
			a  : in std_logic_vector(SIZE_INT - 1 downto 0);
			ovf : in std_logic;
			lz : out std_logic_vector(integer(CEIL(LOG2(real(SIZE_INT)))) - 1 downto 0));
end lzc_tree;

architecture Behavioral of lzc_tree is
	
	component d_ff
		generic (N: natural := 8);
		port (clk, rst : in std_logic;
				d : in std_logic_vector (N-1 downto 0);
				q : out std_logic_vector (N-1 downto 0));
	end component;
	
	constant nr_levels : integer := integer (CEIL(LOG2(real (SIZE_INT)))) - 1	;
	constant max_pow_2 : integer := integer (2.0 ** (CEIL (LOG2 (real (SIZE_INT)))));
	constant size_lz : integer := integer(CEIL(LOG2(real(SIZE_INT))));
		
	type v_type is array (nr_levels - 1 downto 0) of std_logic_vector(max_pow_2 - 1 downto 0);
	type p_type is array(nr_levels - 1 downto 0) of std_logic_vector (max_pow_2 - 1 downto 0);
	
	signal a_complete : std_logic_vector(max_pow_2 - 1 downto 0);
	signal v_d, v_q : v_type;
	signal p_d, p_q : p_type;
	signal lzc : std_logic_vector(size_lz - 1 downto 0);
	
begin

	a_complete (max_pow_2 - 1 downto max_pow_2 - 1 - SIZE_INT + 1) <= a;
	gen_if:
		if(max_pow_2 /= SIZE_INT) generate
			a_complete (max_pow_2 - 1 - SIZE_INT  downto 0) <= (others => '0');
		end generate;

	
	level_0:
		for i in max_pow_2/4 - 1 downto 0 generate
			v_d(0)(i) <= '0' when a_complete(4*i + 3 downto 4*i) = "0000" else
						'1';
			p_d(0)(2*i+1 downto 2*i) <= "00" when a_complete(4*i+3) = '1' else
											"01" when a_complete(4*i+2) = '1' else
											"10" when a_complete(4*i+1) = '1' else
											"11";
		end generate;

		
	level_generation:
		for i in 1 to nr_levels - 1 generate
			v_levels:
				for j in 0 to max_pow_2/(integer(2**(i+2))) - 1 generate
					v_d(i)(j) <= v_q(i-1)(2*j+1) or v_q(i-1)(2*j);
				end generate;
			p_levels:
				for j in 0 to max_pow_2/(integer(2**(i+2))) - 1 generate
					p_d(i)((i+2)*j+i+1) <= not(v_q(i-1)(2*j+1));
					p_d(i)((i+2)*j+i downto (i+2)*j) <= p_q(i-1)(j*(2*i+2) + 2*i + 1 downto j*(2*i+2) + i+1) when v_q(i-1)(2*j+1) = '1'
															else p_q(i-1)(j*(2*i+2) + i downto j*(2*i+2));
				end generate;
	end generate;
	
--	pipeline_stages:
--		if(PIPELINE /= 0) generate
----			INSERTION:
----				for i in 0 to nr_levels - 2 generate
----					INS: if ((i+1) mod nr_levels/(PIPELINE+1) = 0) generate
----								P_D : D_FF generic map (N => max_pow_2)
----												port map( clk => clk, rst => rst,
----															d => p_d(i), q =>p_q(i));
----								V_D : D_FF generic map (N => max_pow_2)
----												port map( clk => clk, rst => rst,
----															d => v_d(i), q =>v_q(i));
----							end generate INS;
--					NO_INS: if ((i+1) mod nr_levels/(PIPELINE+1) /= 0) generate
--									P_ASSIGN: p_q(i) <= p_d(i);
--									V_ASSIGN: v_q(i) <= v_d(i);
--							end generate NO_INS;
--			end generate;
--			p_q(nr_levels - 1) <= p_d(nr_levels - 1);
--			v_q(nr_levels - 1) <= v_d(nr_levels - 1);
--		end generate;
	
	
		
	no_pipeline:
		if(PIPELINE = 0) generate
			NO_INSERTION:
				for i in 0 to nr_levels - 1 generate
						P_ASSIGN_0: p_q(i) <= p_d(i);
						V_ASSIGN_0: v_q(i) <= v_d(i);
				end generate;
		end generate;
	
	lzc (size_lz - 1 downto 0) <= p_q(nr_levels - 1)(size_lz - 1 downto 0);
	
	lz_ovf:
		for i in 0 to size_lz - 1  generate
				lz(i) <= lzc (i) and (not ovf);
		end generate;
	
end Behavioral;

