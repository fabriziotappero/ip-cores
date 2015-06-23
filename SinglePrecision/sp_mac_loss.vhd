----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:13:48 02/13/2013 
-- Design Name: 
-- Module Name:    sp_mac_loss - Behavioral 
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

entity sp_mac_loss is
	port (clk, rst : in std_logic;
			mantissa_a, mantissa_b : in std_logic_vector(23 downto 0);
			mantissa_c : in std_logic_vector (23 downto 0);
			exp_a, exp_b : in std_logic_vector(7 downto 0);
			exp_c : in std_logic_vector(7 downto 0);
			sign_a, sign_b : in std_logic;
			sign_c : in std_logic;
			sub : in std_logic;
			mantissa_res : out std_logic_vector(23 downto 0);
			exp_res : out std_logic_vector(7 downto 0);
			sign_res : out std_logic);
end sp_mac_loss;

architecture Behavioral of sp_mac_loss is

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
	
	component dsp_unit_sp
		port (clk, rst : in std_logic;
			a : in std_logic_vector(33 downto 0);
			b : in std_logic_vector(23 downto 0);
			c:  in std_logic_vector(71 downto 0);
			comp : in std_logic;  -- 1 a*b > c; 0 a*b <= c
			sub : in std_logic;  --
			p1: out std_logic_vector (47 downto 0);
			p2: out std_logic_vector (48 downto 0);
			pattern_detect : out std_logic);
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

	signal mantissa_a_q, mantissa_b_q, mantissa_c_q : std_logic_vector(23 downto 0);
	signal mantissa_b_q0 : std_logic_vector(23 downto 0);
	
	signal eff_sub : std_logic;
	signal comp : std_logic;
	signal sub_vec : std_logic_vector(0 downto 0);
	signal comp_vec : std_logic_vector(0 downto 0);
	signal sub_dsp : std_logic_vector(0 downto 0);
	signal sub_vec0 : std_logic_vector(0 downto 0);
	signal comp_vec0 : std_logic_vector(0 downto 0);
	signal sub_vec1 : std_logic_vector(0 downto 0);
	signal comp_vec1 : std_logic_vector(0 downto 0);
	signal sub_dsp0 : std_logic_vector(0 downto 0);
	signal comp_dsp : std_logic_vector(0 downto 0);
	signal sub_dsp1 : std_logic_vector(0 downto 0);
	signal comp_dsp1 : std_logic_vector(0 downto 0);
	signal sub_dsp2 : std_logic_vector(0 downto 0);
	signal comp_dsp2 : std_logic_vector(0 downto 0);
	signal sub_dsp3 : std_logic_vector(0 downto 0);
	signal comp_dsp3 : std_logic_vector(0 downto 0);
	signal sign_d : std_logic_vector (2 downto 0);
	signal sign_q : std_logic_vector (2 downto 0);
	signal sign_q0 : std_logic_vector (2 downto 0);
	signal sign_q1 : std_logic_vector (2 downto 0);
	signal sign_q2 : std_logic_vector (2 downto 0);
	signal sign_q3 : std_logic_vector (2 downto 0);
	signal sign_q4 : std_logic_vector (2 downto 0);
	signal sign_mantissa_add : std_logic;
	signal sign_res1 : std_logic_vector(0 downto 0);
	signal sign_res2 : std_logic_vector(0 downto 0);
	signal sign_res3 : std_logic_vector(0 downto 0);
	signal sign_res4 : std_logic_vector(0 downto 0);
	signal sign_res5 : std_logic_vector(0 downto 0);
	signal sign_res6 : std_logic_vector(0 downto 0);

	
	signal align_d, align_q : std_logic_vector(7 downto 0);
	signal exp_int : std_logic_vector(8 downto 0);
	signal exp_int_q0 : std_logic_vector (8 downto 0);
	signal exp_int_q1 : std_logic_vector(8 downto 0);
	signal exp_int_q2 : std_logic_vector(8 downto 0);
	signal exp_int_q3 : std_logic_vector(8 downto 0);
	signal exp_int_q4 : std_logic_vector(8 downto 0);
	signal exp_int_q5 : std_logic_vector(8 downto 0);
	signal exp_int_q6 : std_logic_vector(8 downto 0);
	signal exp_lzc_d, exp_lzc_q : std_logic_vector (8 downto 0);
	signal exp_res_int : std_logic_vector (8 downto 0);
	
	signal align_a_d : std_logic_vector(4 downto 0);
	signal align_c_d : std_logic_vector(5 downto 0);
	signal align_a : std_logic_vector(4 downto 0);
	signal align_c : std_logic_vector(5 downto 0);
		
	signal aligned_mantissa_a : std_logic_vector(33 downto 0);
	signal aligned_mantissa_c_d : std_logic_vector(71 downto 0);
	signal aligned_mantissa_c_q : std_logic_vector(71 downto 0);

	signal p1 : std_logic_vector(47 downto 0);
	signal p2 : std_logic_vector(48 downto 0);
	signal p : std_logic_vector(60 downto 0);
	signal p_q : std_logic_vector(60 downto 0);
	signal mantissa_abs_d : std_logic_vector(59 downto 0);
	signal mantissa_abs_q1 : std_logic_vector(59 downto 0);
	signal mantissa_abs_q2 : std_logic_vector(59 downto 0);
	signal mantissa_lzc_d : std_logic_vector(59 downto 0);
	signal mantissa_lzc_q : std_logic_vector(59 downto 0);
	signal mantissa_res_d: std_logic_vector (23 downto 0); 
	
	signal ovf_round: std_logic;
	signal ovf_norm : std_logic_vector (1 downto 0);
	
	signal ovf_mac : std_logic;

	signal lzc_d, lzc_q : std_logic_vector(5 downto 0);
	signal zero : std_logic:= '0';
	
	signal add_msbs_p : std_logic_vector(60 downto 0);
	signal add_lsbs_p : std_logic_vector(60 downto 0);

begin

	--STAGE 1

	EFFECTIVE_SUB:
		effective_op port map (sign_a => sign_a, sign_b => sign_b, sign_c => sign_c,
								sub => sub, eff_sub => eff_sub);
	
	EXP_ALIGN : exponent_align
						generic map (SIZE_EXP => 8, PIPELINE => 1)
						port map (clk => clk, rst => rst, 
							exp_a => exp_a, exp_b => exp_b,
							exp_c => exp_c, align => align_d,
							exp_int => exp_int, comp=>comp);
	
	
	sub_vec(0) <= eff_sub;
	comp_vec(0) <= comp;
	
	sign_d(0) <= sign_c;
	sign_d(1) <= sign_b;
	sign_d(2) <= sign_a;
	
	--first stage pipeline
	
	S0_mantissa_a : d_ff
					generic map(N=>24)
					port map (clk => clk, rst => rst,
					d=> mantissa_a, q => mantissa_a_q);
					
	S0_mantissa_b : d_ff
					generic map(N=>24)
					port map (clk => clk, rst => rst,
					d=> mantissa_b, q => mantissa_b_q);
	
	S0_mantissa_c : d_ff
					generic map(N=>24)
					port map (clk => clk, rst => rst,
					d=> mantissa_c, q => mantissa_c_q);
	
	LATCH_sub_S0: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> sub_vec, q => sub_vec0);
	
	LATCH_comp_S0: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> comp_vec, q => comp_vec0);
	
	LATCH_sign_S0 : d_ff
					generic map (N => 3)
					port map (clk => clk, rst => rst,
								d=> sign_d, q => sign_q);
	
	--end of 
	
	align_a_d(3 downto 0) <= align_d(3 downto 0) when comp_vec(0) = '0' else
						(others => '0');
	
	align_a_d(4) <= (align_d(4) or align_d(5) or align_d(6) or align_d(7)) when comp_vec(0) = '0' else
						'0';
	
	align_c_d(4 downto 0) <= align_d (4 downto 0) when comp_vec(0) = '1' else
						(others => '0');
	
	align_c_d(5) <= (align_d(5) or align_d(6) or align_d(7)) when comp_vec(0) = '1' else
						'0';
					
	align_a(0) <= align_a_d(0);
	align_c(0) <= align_c_d(0);
	
		
	-- second stage pipeline
	S1_exp_int : d_ff
					generic map(N => 9)
					port map (clk => clk, rst => rst,
					d => exp_int, q => exp_int_q0);
	
	S1_mantissa_b : d_ff
					generic map(N=>24)
					port map (clk => clk, rst => rst,
					d=> mantissa_b_q, q => mantissa_b_q0);
	
	
	LATCH_sub_S1: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> sub_vec, q => sub_vec1);
	
	LATCH_comp_S1: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> comp_vec, q => comp_vec1);
	
	LATCH_sign_S1 : d_ff
					generic map (N => 3)
					port map (clk => clk, rst => rst,
								d=> sign_q, q => sign_q0);				
	
	
	LATCH_align_c : d_ff
					generic map (N => 5)
					port map (clk => clk, rst => rst,
								d=> align_c_d(5 downto 1), q => align_c(5 downto 1));
	
	LATCH_align_a : d_ff
					generic map (N => 4)
					port map (clk => clk, rst => rst,
								d=> align_a_d(4 downto 1), q => align_a(4 downto 1));
	
	--end of pipeline
	
	SHIFT_A : shift
					generic map (INPUT_SIZE => 24,
									SHIFT_SIZE => 5,
									OUTPUT_SIZE => 34,
									DIRECTION => 0,
									PIPELINE => 1,
									POSITION => "00000001")
					port map (clk => clk, rst => rst,
							a => mantissa_a_q,
							shft => align_a(4 downto 0),
							arith => zero,
							shifted_a => aligned_mantissa_a); 

	SHIFT_C : shift
					generic map (INPUT_SIZE => 24,
									SHIFT_SIZE => 6,
									OUTPUT_SIZE => 58,
									DIRECTION => 0,
									PIPELINE => 1,
									POSITION => "00000001")
					port map (clk => clk, rst => rst,
							a => mantissa_c_q,
							shft => align_c (5 downto 0),
							arith => zero,
							shifted_a => aligned_mantissa_c_d (57 downto 0));
	
	aligned_mantissa_c_d (71 downto 58) <= (others => '0');




	-- first pipeline register 
-- latching mantissa_c, sub_eff, comp, exp_int, signs 
-- a and b are latched inside the dsp block	
			
	
	
	LATCH_C_S2: d_ff
					generic map ( N => 72)
					port map (clk => clk, rst => rst, 
							d => aligned_mantissa_c_d, q => aligned_mantissa_c_q);
	LATCH_sub_S2: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> sub_vec1, q => sub_dsp);
	
	LATCH_comp_S2: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> comp_vec1, q => comp_dsp);
	
	LATCH_sign_S2 : d_ff
					generic map (N => 3)
					port map (clk => clk, rst => rst,
								d=> sign_q0, q => sign_q1);
	
	LATCH_exp_S2 : d_ff 
					generic map (N => 9)
					port map (clk => clk, rst => rst,
								d=> exp_int_q0, q => exp_int_q1);

 -- instantiating the DSP
	DSP:
		dsp_unit_sp 
			port map(clk => clk, rst => rst,
			a => aligned_mantissa_a,--"00"&x"00000001",--"00"&x"00800000",--
			b => mantissa_b_q0,--x"000001",--x"800000",--
			c => aligned_mantissa_c_q,--x"000000000000000001",--x"000000000000800000",--
			comp => comp_dsp(0),  -- 1 a*b > c; 0 a*b <= c
			sub => sub_dsp(0),  --
			p1 => p1,
			p2 => p2,
			pattern_detect => open);

--pipeline statges outside the dsp
	LATCH_sub_S3: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> sub_dsp, q => sub_dsp1);
	
	LATCH_comp_S3: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> comp_dsp, q => comp_dsp1);
	
	LATCH_sign_S3 : d_ff
					generic map (N => 3)
					port map (clk => clk, rst => rst,
								d=> sign_q1, q => sign_q2);
	
	LATCH_exp_S3 : d_ff 
					generic map (N => 9)
					port map (clk => clk, rst => rst,
								d=> exp_int_q1, q => exp_int_q2);
	
	LATCH_sub_S4: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> sub_dsp1, q => sub_dsp2);
	
	LATCH_comp_S4: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> comp_dsp1, q => comp_dsp2);
	
	LATCH_sign_S4 : d_ff
					generic map (N => 3)
					port map (clk => clk, rst => rst,
								d=> sign_q2, q => sign_q3);
	
	LATCH_exp_S4 : d_ff 
					generic map (N => 9)
					port map (clk => clk, rst => rst,
								d=> exp_int_q2, q => exp_int_q3);
	
	--computing the mantissa mac
	
	--add_msbs_p <= (60 downto 48 => '0') & p1;
	--add_lsbs_p <= p2(43 downto 0) & (16 downto 0=>'0');
		
	add_msbs_p <= p1(43 downto 0) & (16 downto 0=>'0');
	add_lsbs_p <= (60 downto 48 => '0') & p2(47 downto 0);
	p <= add_msbs_p + add_lsbs_p; 
	
	--latching the result
	
	LATCH_sub_S5: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> sub_dsp2, q => sub_dsp3);
	
	LATCH_comp_S5: d_ff
					generic map ( N => 1)
					port map ( clk => clk, rst => rst,
								d=> comp_dsp2, q => comp_dsp3);
	
	LATCH_sign_S5 : d_ff
					generic map (N => 3)
					port map (clk => clk, rst => rst,
								d=> sign_q3, q => sign_q4);
	
	LATCH_exp_S5 : d_ff 
					generic map (N => 9)
					port map (clk => clk, rst => rst,
								d=> exp_int_q3, q => exp_int_q4);

	LATCH_p_S5 : 	d_ff
					generic map(N=>61)
					port map (clk => clk, rst => rst,
							d => p, q => p_q);
							
	-- absolute value
	sign_mantissa_add <= p_q(60);
	
	mantissa_abs_d <= p_q (59 downto 0) when sign_mantissa_add = '0' else
							-(p_q(59 downto 0));
	
	SIGN_RESULT_COMP :  
			sign_comp
				port map(sign_a => sign_q4(2), sign_b => sign_q4(1),
					sign_c => sign_q4(0),
					comp_exp => comp_dsp3(0),
					eff_sub => sub_dsp3(0),
					sign_add => sign_mantissa_add,
					sign_res => sign_res1(0));

-- Fifth PIPELINE REGISTERS
	-- abs value of mantissa, exp_int, sign_res
	LATCH_MANTISSA_ABS_S6:
		d_ff generic map (n => 60)
				port map (clk => clk, rst => rst,
							d => mantissa_abs_d, q=>mantissa_abs_q1);
	
	LATCH_sign_res_S6 : d_ff
					generic map (N => 1)
					port map (clk => clk, rst => rst,
								d=> sign_res1, q => sign_res2);
	
	LATCH_exp_S6 : d_ff 
					generic map (N => 9)
					port map (clk => clk, rst => rst,
								d=> exp_int_q4, q => exp_int_q5);
	
	--pipeline stage
	ovf_mac <= mantissa_abs_q1(59) or mantissa_abs_q1(58);
	LZC_COUNT : lzc_tree 
					generic map ( SIZE_INT => 58,
										PIPELINE => 0)
					port map (clk => clk, rst => rst,
								a => mantissa_abs_q1(57 downto 0),
								ovf => ovf_mac, lz => lzc_d);
   --pipeline_registers
	LATCH_MANTISSA_ABS_S7:
		d_ff generic map (n => 60)
				port map (clk => clk, rst => rst,
							d => mantissa_abs_q1, q=>mantissa_abs_q2);
	
	LATCH_sign_res_S7 : d_ff
					generic map (N => 1)
					port map (clk => clk, rst => rst,
								d=> sign_res2, q => sign_res3);
	
	LATCH_exp_S7 : d_ff 
					generic map (N => 9)
					port map (clk => clk, rst => rst,
								d=> exp_int_q5, q => exp_int_q6);
	
	LATCH_lzc_S7 : d_ff 
					generic map (N => 6)
					port map (clk => clk, rst => rst,
								d=> lzc_d, q => lzc_q);
	
	-- another stage
	
	SHIFT_MANTISSA : shift
						generic map (INPUT_SIZE => 60,
										SHIFT_SIZE => 6,
										OUTPUT_SIZE => 60,
										DIRECTION => 1,
										PIPELINE => 0)
						port map (clk => clk, rst => rst,
								a => mantissa_abs_q2,
								shft => lzc_q,
								shifted_a => mantissa_lzc_d,
								arith => zero);
	
	SUB_LZC_EXP : 
		exp_add_lzc 
			generic map(SIZE_EXP => 9, SIZE_LZC => 6)
			port map (exp_in => exp_int_q6, lzc => lzc_q, exp_out => exp_lzc_d); 
	

	-- pipeline register 7
	-- mantissa_lzc, exp_lzc, sign_res
	LATCH_MANTISSA_LZC_S8:
				d_ff generic map (n => 60)
						port map (clk => clk, rst => rst,
									d => mantissa_lzc_d, q=>mantissa_lzc_q);
	
	LATCH_sign_res_S8 : d_ff
					generic map (N => 1)
					port map (clk => clk, rst => rst,
								d=> sign_res3, q => sign_res4);
	
	LATCH_exp_S8 : d_ff 
					generic map (N => 9)
					port map (clk => clk, rst => rst,
								d=> exp_lzc_d, q => exp_lzc_q);
			
	--rounding
	ROUND:
		round_norm generic map(OPERAND_SIZE => 58,
										MANTISSA_SIZE => 24,
										RND_PREC => 0,
										PIPELINE => 1)
						port map (clk => clk, rst => rst,
									mantissa_in => mantissa_lzc_q,
									mantissa_out => mantissa_res_d,
									ovf_norm => ovf_norm,
									neg => zero,
									ovf_rnd => ovf_round);	
		
	EXP_UPDATE:
		exp_add_norm generic map (SIZE_EXP => 9, PIPELINE => 1)
						port map (clk => clk, rst => rst,
							exp_in => exp_lzc_q,
							ovf_norm => ovf_norm, 
							ovf_rnd => ovf_round,
							exp_out => exp_res_int);	
		
	--PIPELINE STAGE 6
	-- sign res
		LATCH_sign_res_S9 : d_ff
					generic map (N => 1)
					port map (clk => clk, rst => rst,
								d=> sign_res4, q => sign_res5);
		
		
		sign_res <= sign_res5(0);
		exp_res <= exp_res_int (7 downto 0);		
		mantissa_res <= mantissa_res_d;
			
		
end Behavioral;

