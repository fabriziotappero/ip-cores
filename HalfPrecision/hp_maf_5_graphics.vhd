----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:33:40 03/24/2013 
-- Design Name: 
-- Module Name:    hp_maf_5_graphics - Behavioral 
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
use IEEE.std_logic_signed.all;
use IEEE.std_logic_arith.all;
use IEEE.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hp_maf_5_graphics is
		port (clk, rst : in std_logic;
			mantissa_a, mantissa_b : in std_logic_vector(10 downto 0);
			mantissa_c : in std_logic_vector (10 downto 0);
			exp_a, exp_b : in std_logic_vector(4 downto 0);
			exp_c : in std_logic_vector(4 downto 0);
			sign_a, sign_b : in std_logic;
			sign_c : in std_logic;
			sub : in std_logic;
			mantissa_res : out std_logic_vector(10 downto 0);
			exp_res : out std_logic_vector(4 downto 0);
			sign_res : out std_logic);
end hp_maf_5_graphics;

architecture Behavioral of hp_maf_5_graphics is

	component exp_add_lzc
		generic( SIZE_EXP : natural := 5;
				SIZE_LZC : natural := 4);
		port (exp_in : in std_logic_vector(SIZE_EXP - 1 downto 0);
				lzc : in std_logic_vector(SIZE_LZC - 1 downto 0);
				exp_out : out std_logic_vector (SIZE_EXP - 1 downto 0));
	end component;
	
	component exp_add_norm
		generic (SIZE_EXP : natural := 5;
				PIPELINE : natural := 0);
		port (clk, rst : in std_logic;
			exp_in : in std_logic_vector(SIZE_EXP - 1 downto 0);
			ovf_norm : in std_logic_vector (1 downto 0);
			ovf_rnd : in std_logic;
			exp_out : out std_logic_vector(SIZE_EXP - 1 downto 0));
	end component;
	
	component sign_comp
		port (sign_a, sign_b : in std_logic;
			sign_c : in std_logic;
			comp_exp : in std_logic;
			eff_sub : in std_logic;
			sign_add : in std_logic;
			sign_res : out std_logic);
	end component;
	
	component exponent_align
		generic (SIZE_EXP : natural := 5;
					PIPELINE : natural := 2); -- nr of pipeline registers -- max 2
		port (clk, rst : in std_logic;
				exp_a, exp_b : in std_logic_vector (SIZE_EXP - 1 downto 0);
				exp_c : in std_logic_vector (SIZE_EXP - 1 downto 0);
				align : out std_logic_vector (SIZE_EXP - 1 downto 0);
				exp_int : out std_logic_vector (SIZE_EXP downto 0);
				comp : out std_logic);
	end component;
	
	component effective_op is
		port (sign_a, sign_b, sign_c : in std_logic;
			sub: in std_logic;
			eff_sub : out std_logic);
	end component;
	
	component shift
		generic (INPUT_SIZE : natural := 13;
				SHIFT_SIZE : natural := 4;
				OUTPUT_SIZE : natural := 24;
				DIRECTION : natural := 1;  -- 1 for left shift; 0 for right shift
				PIPELINE : natural := 1;
				POSITION : std_logic_vector(7 downto 0) := "00000000"); -- number of pipeline registers
		port (clk, rst : in std_logic;
			a : in std_logic_vector (INPUT_SIZE - 1 downto 0);
			arith : in std_logic;
			shft : in std_logic_vector (SHIFT_SIZE - 1 downto 0);
			shifted_a : out std_logic_vector (OUTPUT_SIZE - 1 downto 0));
	end component;
			
	component round_norm
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
	end component;
	
	component dsp_unit
		generic (MULT_REG : natural := 1;
			MULT_STRING : string := "MULT_S");
		port (clk, rst : in std_logic;
			a : in std_logic_vector(23 downto 0);
			b : in std_logic_vector (16 downto 0);
			c : in std_logic_vector (32 downto 0);
			comp : in std_logic; -- 1 for a*b > c ; 0 for a*b <c
			sub : in std_logic;
			acc : in std_logic; -- 0 for add; 1 for accumulate
			p: out std_logic_vector (35 downto 0);
			pattern_detect : out std_logic;
			ovf, udf : out std_logic);
	end component;
	
	component d_ff
		generic (N: natural := 8);
		port (clk, rst : in std_logic;
				d : in std_logic_vector (N-1 downto 0);
				q : out std_logic_vector (N-1 downto 0));
	end component;
	
	component lzc_tree
		generic (SIZE_INT : natural := 42;
				PIPELINE : natural := 2);
		port (clk, rst : in std_logic; 
			a  : in std_logic_vector(SIZE_INT - 1 downto 0);
			ovf : in std_logic;
			lz : out std_logic_vector(integer(CEIL(LOG2(real(SIZE_INT)))) - 1 downto 0));
	end component;
	
	signal mantissa_a_q : std_logic_vector(10 downto 0) := (others => '0');
   signal mantissa_b_q : std_logic_vector(10 downto 0) := (others => '0');
   signal mantissa_c_q : std_logic_vector(10 downto 0) := (others => '0');
--   signal sign_a_q : std_logic := '0';
--   signal sign_b_q : std_logic := '0';
--   signal sign_c_q : std_logic := '0';
   signal sub_q : std_logic := '0';
	
		
	signal eff_sub : std_logic;
	signal comp : std_logic;
	signal align : std_logic_vector (4 downto 0);
	signal align_q : std_logic_vector (4 downto 0);
	signal exp_int : std_logic_vector (5 downto 0);
	signal exp_int_q0 : std_logic_vector (5 downto 0);
	signal exp_int_q1 : std_logic_vector (5 downto 0);
	signal exp_int_q2 : std_logic_vector (5 downto 0);
	signal exp_int_q3 : std_logic_vector (5 downto 0);
	signal exp_int_q4 : std_logic_vector (5 downto 0);
	signal exp_int_q5 : std_logic_vector (5 downto 0);
	signal exp_lzc_d, exp_lzc_q : std_logic_vector (5 downto 0);
	signal exp_res_int : std_logic_vector (5 downto 0);
	
	signal align_a : std_logic_vector(4 downto 0);
	signal align_c : std_logic_vector(4 downto 0);
	
	signal aligned_mantissa_a : std_logic_vector(22 downto 0);
	signal a_input: std_logic_vector(23 downto 0);
	signal aligned_mantissa_c_d : std_logic_vector(32 downto 0);
	signal aligned_mantissa_c_q : std_logic_vector(32 downto 0);
	signal b_input : std_logic_vector (16 downto 0);
	
	
	signal sub_vec0, comp_vec0 : std_logic_vector(0 downto 0);
	signal sub_dsp, comp_dsp : std_logic_vector(0 downto 0);
	signal sub_vec, comp_vec : std_logic_vector(0 downto 0);
	signal sub_dsp1, comp_dsp1 : std_logic_vector(0 downto 0);
	signal sub_dsp2, comp_dsp2 : std_logic_vector(0 downto 0);
	signal sign_d: std_logic_vector (2 downto 0);
	signal sign_q0, sign_q1 : std_logic_vector (2 downto 0);
	signal sign_q2, sign_q3 : std_logic_vector (2 downto 0);
	signal acc : std_logic;
	
	signal mantissa_mac : std_logic_vector (35 downto 0); 
	signal mantissa_abs_d, mantissa_abs_q: std_logic_vector (23 downto 0);
	signal mantissa_abs_q1 : std_logic_vector (23 downto 0);
	signal mantissa_lzc_d : std_logic_vector (23 downto 0);
	signal mantissa_lzc_q : std_logic_vector (23 downto 0);
	signal lzc_d, lzc_q : std_logic_vector (4 downto 0);
	signal mantissa_res_d: std_logic_vector (10 downto 0);
	
	signal sign_res1, sign_res2, sign_res3, sign_res4, sign_res5 : std_logic_vector(0 downto 0);
	
	signal ovf_round: std_logic;
	signal ovf_norm : std_logic_vector (1 downto 0);
	signal sign_mantissa_add : std_logic;
	signal ovf_mac : std_logic;
	
	signal neg1, neg2, neg3, neg4 : std_logic_vector(0 downto 0);
	
	signal res_zero1, res_zero2, res_zero3, res_zero4, res_zero5 : std_logic_vector(0 downto 0);
	
	signal zero : std_logic;
	
begin

		zero <= '0';

	--STAGE 1
		

	
	EFFECTIVE_SUB:
		effective_op port map (sign_a => sign_a, sign_b => sign_b, 
								sign_c => sign_c, 
								sub => sub, eff_sub => eff_sub);
	
	EXP_ALIGN : exponent_align
						generic map (SIZE_EXP => 5, PIPELINE => 0)
						port map (clk => clk, rst => rst, 
							exp_a => exp_a, exp_b => exp_b,
							exp_c => exp_c, align => align,
							exp_int => exp_int, comp=>comp);
	
	acc <= '0';
	
	sub_vec0(0) <= eff_sub;
	comp_vec0(0) <= comp;
	
	sign_d(0) <= sign_c;
	sign_d(1) <= sign_b;
	sign_d(2) <= sign_a;
	
	--pipeline stage 0
--	LATCH_A_S0: d_ff
--					generic map ( N => 11)
--					port map (clk => clk, rst => rst, 
--							d => mantissa_a, q => mantissa_a_q);
--	
	LATCH_B_S0: d_ff
					generic map ( N => 11)
					port map (clk => clk, rst => rst, 
							d => mantissa_b, q => mantissa_b_q);
--	
--	LATCH_C_S0: d_ff
--					generic map ( N => 11)
--					port map (clk => clk, rst => rst, 
--							d => mantissa_c, q => mantissa_c_q);
							
	
	LATCH_sub_S0: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> sub_vec0, q => sub_vec);
	
	LATCH_comp_S0: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> comp_vec0, q => comp_vec);
	
	LATCH_sign_S0 : d_ff
					generic map (N => 3)
					port map (clk => clk, rst => rst,
								d=> sign_d, q => sign_q0);
	
	LATCH_exp_S0 : d_ff 
					generic map (N => 6)
					port map (clk => clk, rst => rst,
								d=> exp_int, q => exp_int_q0);
	
	LATCH_ALIGN: d_ff
					generic map (N=>5)
					port map (clk => clk, rst => rst,
								d=> align, q => align_q);
	
	
	align_a(4 downto 1) <= align_q(4 downto 1) when comp_vec(0) = '0' else 
									(others => '0');
	
	align_a(0 downto 0) <= align(0 downto 0) when comp_vec0(0) = '0' else 
									(others => '0');
	
	align_c(4 downto 1) <= align_q(4 downto 1) when comp_vec(0) = '1' else 
									(others => '0');
	
	align_c(0 downto 0) <= align(0 downto 0) when comp_vec0(0) = '1' else 
									(others => '0');
	
--	align_a <= align_q(4 downto 0)  when comp_vec(0) = '0' else 
--				(others => '0');
--	
--	align_c <= align_q when comp_vec(0) = '1' else
--					(others => '0');
	
	SHIFT_A : shift
					generic map (INPUT_SIZE => 11,
									SHIFT_SIZE => 5,
									OUTPUT_SIZE => 23,
									DIRECTION => 0,
									PIPELINE => 1,
									POSITION => "00000001")
					port map (clk => clk, rst => rst,
							a => mantissa_a,
							arith => zero,
							shft => align_a,
							shifted_a => aligned_mantissa_a); 

	SHIFT_C : shift
					generic map (INPUT_SIZE => 11,
									SHIFT_SIZE => 5,
									OUTPUT_SIZE => 33,
									DIRECTION => 0,
									PIPELINE => 1,
									POSITION => "00000001")
					port map (clk => clk, rst => rst,
							a => mantissa_c,
							arith => zero,
							shft => align_c,
							shifted_a => aligned_mantissa_c_d);
							
	b_input <=(16 downto 11 => '0')& mantissa_b_q;
	a_input <= "0" & aligned_mantissa_a;
-- first pipeline register 
-- latching mantissa_c, sub_eff, comp, exp_int, signs 
-- a and b are latched inside the dsp block	
	
	aligned_mantissa_c_q <= aligned_mantissa_c_d;
	sub_dsp <= sub_vec;
	comp_dsp <= comp_vec;
	sign_q1 <= sign_q0;
	exp_int_q1 <= exp_int_q0;
			

-- instantiating dsp
	
	DSP: dsp_unit
				generic map(0, "MULT")
				port map(clk => clk, rst => rst,
						a => a_input, 
						b => b_input,
						c => aligned_mantissa_c_q,
						comp => comp_dsp(0), -- 1 for a*b > c ; 0 for a*b <c
						sub => sub_dsp(0),
						acc => acc, -- 0 for add; 1 for accumulate
						p => mantissa_mac,
						pattern_detect => res_zero1(0),
						ovf => open, udf => open);
	
	
	--2 pipeline registers for other signals
	-- exp_int, signs, eff_sub 
	
	
	
	LATCH_sub_S2: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> sub_dsp, q => sub_dsp1);
	
	LATCH_comp_S2: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> comp_dsp, q => comp_dsp1);
	
	LATCH_sign_S2 : d_ff
					generic map (N => 3)
					port map (clk => clk, rst => rst,
								d=> sign_q1, q => sign_q2);
	
	LATCH_exp_S2 : d_ff 
					generic map (N => 6)
					port map (clk => clk, rst => rst,
								d=> exp_int_q1, q => exp_int_q2);
		
	LATCH_sub_S3: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> sub_dsp1, q => sub_dsp2);
	
	LATCH_comp_S3: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> comp_dsp1, q => comp_dsp2);
	
	LATCH_sign_S3 : d_ff
					generic map (N => 3)
					port map (clk => clk, rst => rst,
								d=> sign_q2, q => sign_q3);
	
	LATCH_exp_S3 : d_ff 
					generic map (N => 6)
					port map (clk => clk, rst => rst,
								d=> exp_int_q2, q => exp_int_q3);
	
	--absolute value 
	sign_mantissa_add <= mantissa_mac(35);
	neg1(0) <= sign_mantissa_add;
	
	mantissa_abs_d <= mantissa_mac (34 downto 11) when sign_mantissa_add = '0' else
							not(mantissa_mac(34 downto 11));
	
	SIGN_RESULT_COMP :  
			sign_comp
				port map(sign_a => sign_q3(2), sign_b => sign_q3(1),
					sign_c => sign_q3(0),
					comp_exp => comp_dsp2(0),
					eff_sub => sub_dsp2(0),
					sign_add => sign_mantissa_add,
					sign_res => sign_res1(0));

	-- FOURTH PIPELINE REGISTERS
	-- abs value of mantissa, exp_int, sign_res
	mantissa_abs_q <= mantissa_abs_d;
	sign_res2 <= sign_res1;
	exp_int_q4 <= exp_int_q3;
	res_zero2 <= res_zero1;
	neg2 <= neg1;
	
	
	
	--pipeline stage
	ovf_mac <= mantissa_abs_q(23) or mantissa_abs_q(22);

	LZC_COUNT : lzc_tree 
					generic map ( SIZE_INT => 22,
										PIPELINE => 0)
					port map (clk => clk, rst => rst,
								a => mantissa_abs_q(21 downto 0),
								ovf => ovf_mac, lz => lzc_d);
	
	--pipeline register
	LATCH_MANTISSA_ABS_S5:
		d_ff generic map (n => 24)
				port map (clk => clk, rst => rst,
							d => mantissa_abs_q, q=>mantissa_abs_q1);
	
	LATCH_sign_res_S5 : d_ff
					generic map (N => 1)
					port map (clk => clk, rst => rst,
								d=> sign_res2, q => sign_res3);
	
	LATCH_exp_S5 : d_ff 
					generic map (N => 6)
					port map (clk => clk, rst => rst,
								d=> exp_int_q4, q => exp_int_q5);
	
	LATCH_lzc_S5 : d_ff 
					generic map (N => 5)
					port map (clk => clk, rst => rst,
								d=> lzc_d, q => lzc_q);
	
	LATCH_ZERO_S5: d_ff 
					generic map(N=>1)
					port map(clk => clk, rst =>rst,
								d=>res_zero2, q=>res_zero3);
	
	LATCH_NEG_S5: d_ff 
					generic map(N=>1)
					port map(clk => clk, rst =>rst,
								d=>neg2, q=>neg3);
	
	
	
	SHIFT_MANTISSA : shift
						generic map (INPUT_SIZE => 24,
										SHIFT_SIZE => 5,
										OUTPUT_SIZE => 24,
										DIRECTION => 1,
										PIPELINE => 0)
						port map (clk => clk, rst => rst,
								a => mantissa_abs_q1,
								arith => neg3(0),
								shft => lzc_q,
								shifted_a => mantissa_lzc_d);
	
	SUB_LZC_EXP : 
		exp_add_lzc 
			generic map(SIZE_EXP => 6, SIZE_LZC => 5)
			port map (exp_in => exp_int_q5, lzc => lzc_q, exp_out => exp_lzc_d);
	
	-- pipeline register 6
	-- mantissa_lzc, exp_lzc, sign_res
--	LATCH_MANTISSA_LZC_S6:
--				d_ff generic map (n => 24)
--						port map (clk => clk, rst => rst,
--									d => mantissa_lzc_d, q=>mantissa_lzc_q);

	mantissa_lzc_q <= mantissa_lzc_d;
	sign_res4 <= sign_res3;
	exp_lzc_q <= exp_lzc_d;
	res_zero4 <= res_zero3;
	neg4 <= neg3;

--	
--	LATCH_sign_res_S6 : d_ff
--					generic map (N => 1)
--					port map (clk => clk, rst => rst,
--								d=> sign_res3, q => sign_res4);
--	
--	LATCH_exp_S6 : d_ff 
--					generic map (N => 6)
--					port map (clk => clk, rst => rst,
--								d=> exp_lzc_d, q => exp_lzc_q);
--								
--	LATCH_ZERO_S6: d_ff 
--					generic map(N=>1)
--					port map(clk => clk, rst =>rst,
--								d=>res_zero3, q=>res_zero4);
	
--	LATCH_NEG_S6: d_ff 
--					generic map(N=>1)
--					port map(clk => clk, rst =>rst,
--								d=>neg3, q=>neg4);
			
	--rounding
	ROUND:
		round_norm generic map(OPERAND_SIZE => 22,
										MANTISSA_SIZE => 11,
										RND_PREC => 1,
										PIPELINE => 0)
						port map (clk => clk, rst => rst,
									mantissa_in => mantissa_lzc_q,
									mantissa_out => mantissa_res_d,
									neg => neg4(0),
									ovf_norm => ovf_norm,
									ovf_rnd => ovf_round);	
		
	EXP_UPDATE:
		exp_add_norm generic map (SIZE_EXP => 6, PIPELINE => 0)
						port map (clk => clk, rst => rst,
							exp_in => exp_lzc_q,
							ovf_norm => ovf_norm, 
							ovf_rnd => ovf_round,
							exp_out => exp_res_int);	
		
	--PIPELINE_STAGE 6
	-- sign res
		
--		sign_res5 <= sign_res4;
		sign_res5 <= sign_res4;
		res_zero5 <= res_zero4;
		
		sign_res <= sign_res5(0);
		exp_res <= exp_res_int (4 downto 0) when res_zero5(0) = '0' else 
					(others =>'0');		
		mantissa_res <= mantissa_res_d when res_zero5(0) = '0' else
					(others => '0');


end Behavioral;

