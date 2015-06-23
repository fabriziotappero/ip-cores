-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: post-normalization entity for the division unit
-------------------------------------------------------------------------------
--
--				100101011010011100100
--				110000111011100100000
--				100000111011000101101
--				100010111100101111001
--				110000111011101101001
--				010000001011101001010
--				110100111001001100001
--				110111010000001100111
--				110110111110001011101
--				101110110010111101000
--				100000010111000000000
--
-- 	Author:		 Jidan Al-eryani 
-- 	E-mail: 	 jidan@gmx.net
--
--  Copyright (C) 2006
--
--	This source file may be used and distributed without        
--	restriction provided that this copyright statement is not   
--	removed from the file and that any derivative work contains 
--	the original copyright notice and the associated disclaimer.
--                                                           
--		THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     
--	EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   
--	TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   
--	FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      
--	OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         
--	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    
--	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   
--	GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        
--	BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  
--	LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  
--	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  
--	OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         
--	POSSIBILITY OF SUCH DAMAGE. 
--

library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library work;
use work.fpupack.all;


entity post_norm_div is
	port(
			 clk_i		  		: in std_logic;
			 opa_i				: in std_logic_vector(FP_WIDTH-1 downto 0);
			 opb_i				: in std_logic_vector(FP_WIDTH-1 downto 0);
			 qutnt_i			: in std_logic_vector(FRAC_WIDTH+3 downto 0);
			 rmndr_i			: in std_logic_vector(FRAC_WIDTH+3 downto 0);
			 exp_10_i			: in std_logic_vector(EXP_WIDTH+1 downto 0);
			 sign_i				: in std_logic;
			 rmode_i			: in std_logic_vector(1 downto 0);
			 output_o			: out std_logic_vector(FP_WIDTH-1 downto 0);
			 ine_o				: out std_logic
		);
end post_norm_div;

architecture rtl of post_norm_div is


-- input&output register signals
signal s_opa_i, s_opb_i : std_logic_vector(FP_WIDTH-1 downto 0);
signal s_expa, s_expb : std_logic_vector(EXP_WIDTH-1 downto 0);
signal s_qutnt_i, s_rmndr_i : std_logic_vector(FRAC_WIDTH+3 downto 0);
signal s_r_zeros	: std_logic_vector(5 downto 0);
signal s_exp_10_i			: std_logic_vector(EXP_WIDTH+1 downto 0);
signal s_sign_i 			: std_logic;
signal s_rmode_i			: std_logic_vector(1 downto 0);
signal s_output_o			 : std_logic_vector(FP_WIDTH-1 downto 0);
signal s_ine_o, s_overflow : std_logic;

signal s_opa_dn, s_opb_dn : std_logic; 
signal s_qutdn : std_logic;

signal s_exp_10b : std_logic_vector(9 downto 0);
signal s_shr1, s_shl1 : std_logic_vector(5 downto 0);
signal s_shr2 : std_logic;
signal s_expo1, s_expo2, s_expo3 : std_logic_vector(8 downto 0);
signal s_fraco1 : std_logic_vector(26 downto 0);
signal s_frac_rnd, s_fraco2 : std_logic_vector(24 downto 0);
signal s_guard, s_round, s_sticky, s_roundup : std_logic;
signal s_lost : std_logic;

signal s_op_0, s_opab_0, s_opb_0 : std_logic;
signal s_infa, s_infb : std_logic;
signal s_nan_in, s_nan_op, s_nan_a, s_nan_b : std_logic;
signal s_inf_result: std_logic;

begin

	-- Input Register
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			s_opa_i <= opa_i;
			s_opb_i <= opb_i;	
			s_expa <= opa_i(30 downto 23);
			s_expb <= opb_i(30 downto 23);
			s_qutnt_i <= qutnt_i;
			s_rmndr_i <= rmndr_i;
			s_exp_10_i <= exp_10_i;			
			s_sign_i <= sign_i;
			s_rmode_i <= rmode_i;
		end if;
	end process;	

	-- Output Register
	process(clk_i)
	begin
		if rising_edge(clk_i) then	
			output_o <= s_output_o;
			ine_o	<= s_ine_o;
		end if;
	end process;	 

    -- qutnt_i
    -- 26 25                    3
    -- |  |                     | 
    -- h  fffffffffffffffffffffff grs

	--*** Stage 1 ****
	-- figure out the exponent and howmuch the fraction has to be shiftd right/left
	
	s_opa_dn <= '1' when or_reduce(s_expa)='0' and or_reduce(opa_i(22 downto 0))='1' else '0';
	s_opb_dn <= '1' when or_reduce(s_expb)='0' and or_reduce(opb_i(22 downto 0))='1' else '0';

	s_qutdn <= not s_qutnt_i(26);
	

	s_exp_10b <= s_exp_10_i - ("000000000"&s_qutdn);		

	
	
	process(clk_i)
		variable v_shr, v_shl : std_logic_vector(9 downto 0); 
	begin
		if rising_edge(clk_i) then
		if s_exp_10b(9)='1' or s_exp_10b="0000000000" then
			v_shr := ("0000000001" - s_exp_10b) - s_qutdn;
			v_shl := (others =>'0');
			s_expo1 <= "000000001";
		elsif s_exp_10b(8)='1' then
			v_shr := (others =>'0');
			v_shl := (others =>'0');
			s_expo1 <= s_exp_10b(8 downto 0);
		else
			v_shr := (others =>'0');
			v_shl :=  "000000000"& s_qutdn;
			s_expo1 <= s_exp_10b(8 downto 0);
		end if;
		if  v_shr(6)='1' then
			s_shr1 <= "111111";
		else
			s_shr1 <= v_shr(5 downto 0);
		end if;
		s_shl1 <= v_shl(5 downto 0);
		end if;
	end process;
		

	-- *** Stage 2 ***
	-- Shifting the fraction and rounding
		
		
	-- shift the fraction
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if s_shr1 /= "000000" then
				s_fraco1 <= shr(s_qutnt_i, s_shr1);
			else 
				s_fraco1 <= shl(s_qutnt_i, s_shl1); 
			end if;
		end if;
	end process;
	
	s_expo2 <= s_expo1 - "000000001" when s_fraco1(26)='0' else s_expo1;
	

	s_r_zeros <= count_r_zeros(s_qutnt_i);

	
	s_lost <= '1' when (s_shr1+("00000"&s_shr2)) > s_r_zeros else '0';

	-- ***Stage 3***
	-- Rounding

	s_guard <= s_fraco1(2);
	s_round <= s_fraco1(1);
	s_sticky <= s_fraco1(0) or or_reduce(s_rmndr_i);
	
	s_roundup <= s_guard and ((s_round or s_sticky)or s_fraco1(3)) when s_rmode_i="00" else -- round to nearset even
				 ( s_guard or s_round or s_sticky) and (not s_sign_i) when s_rmode_i="10" else -- round up
				 ( s_guard or s_round or s_sticky) and (s_sign_i) when s_rmode_i="11" else -- round down
				 '0'; -- round to zero(truncate = no rounding)
				 	

	s_frac_rnd <= ("0"&s_fraco1(26 downto 3)) + '1' when s_roundup='1' else "0"&s_fraco1(26 downto 3);
	s_shr2 <= s_frac_rnd(24);

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if s_shr2='1' then
				s_expo3 <= s_expo2 + "1";
				s_fraco2 <= "0"&s_frac_rnd(24 downto 1);
			else 
				s_expo3 <= s_expo2;
				s_fraco2 <= s_frac_rnd;
			end if;
		end if;
	end process;


	---

	---***Stage 4****
	-- Output
		
	s_op_0 <= not ( or_reduce(s_opa_i(30 downto 0)) and or_reduce(s_opb_i(30 downto 0)) );
	s_opab_0 <= not ( or_reduce(s_opa_i(30 downto 0)) or or_reduce(s_opb_i(30 downto 0)) );
	s_opb_0 <= not or_reduce(s_opb_i(30 downto 0));
	
	s_infa <= '1' when s_expa="11111111"  else '0';
	s_infb <= '1' when s_expb="11111111"  else '0';

	s_nan_a <= '1' when (s_infa='1' and or_reduce (s_opa_i(22 downto 0))='1') else '0';
	s_nan_b <= '1' when (s_infb='1' and or_reduce (s_opb_i(22 downto 0))='1') else '0';
	s_nan_in <= '1' when s_nan_a='1' or  s_nan_b='1' else '0';
	s_nan_op <= '1' when (s_infa and s_infb)='1' or s_opab_0='1' else '0';-- 0 / 0, inf / inf

	s_inf_result <= '1' when (and_reduce(s_expo3(7 downto 0)) or s_expo3(8))='1' or s_opb_0='1' else '0';

	s_overflow <= '1' when s_inf_result='1'  and (s_infa or s_infb)='0' and s_opb_0='0' else '0';

	s_ine_o <= '1' when s_op_0='0' and (s_lost or or_reduce(s_fraco1(2 downto 0)) or s_overflow or or_reduce(s_rmndr_i))='1' else '0';
	
	process(s_sign_i, s_expo3, s_fraco2, s_nan_in, s_nan_op, s_infa, s_infb, s_overflow, s_inf_result, s_op_0)
	begin
		if (s_nan_in or s_nan_op)='1' then
			s_output_o <= '1' & QNAN;
		elsif (s_infa or s_infb)='1' or s_overflow='1' or s_inf_result='1' then
				s_output_o <= s_sign_i & INF;
		elsif s_op_0='1' then
				s_output_o <= s_sign_i & ZERO_VECTOR;					
		else
				s_output_o <= s_sign_i & s_expo3(7 downto 0) & s_fraco2(22 downto 0);
		end if;
	end process;

end rtl;