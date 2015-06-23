-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: post-normalization entity for the multiplication unit
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

entity post_norm_mul is
	port(
			 clk_i		  		: in std_logic;
			 opa_i				: in std_logic_vector(FP_WIDTH-1 downto 0);
			 opb_i				: in std_logic_vector(FP_WIDTH-1 downto 0);
			 exp_10_i			: in std_logic_vector(EXP_WIDTH+1 downto 0);
			 fract_48_i			: in std_logic_vector(2*FRAC_WIDTH+1 downto 0);	-- hidden(1) & fraction(23)
			 sign_i				: in std_logic;
			 rmode_i			: in std_logic_vector(1 downto 0);
			 output_o			: out std_logic_vector(FP_WIDTH-1 downto 0);
			 ine_o				: out std_logic
		);
end post_norm_mul;

architecture rtl of post_norm_mul is

signal s_expa, s_expb : std_logic_vector(EXP_WIDTH-1 downto 0);
signal s_exp_10_i : std_logic_vector(EXP_WIDTH+1 downto 0);
signal s_fract_48_i : std_logic_vector(2*FRAC_WIDTH+1 downto 0);
signal s_sign_i 			: std_logic;
signal s_output_o			 : std_logic_vector(FP_WIDTH-1 downto 0);
signal s_ine_o, s_overflow : std_logic;
signal s_opa_i, s_opb_i : std_logic_vector(FP_WIDTH-1 downto 0);
signal s_rmode_i			: std_logic_vector(1 downto 0);

signal s_zeros  : std_logic_vector(5 downto 0);
signal s_carry   : std_logic;
signal s_shr2, s_shl2 : std_logic_vector(5 downto 0);
signal s_expo1, s_expo2b : std_logic_vector(8 downto 0);
signal s_exp_10a, s_exp_10b : std_logic_vector(9 downto 0); 
signal s_frac2a : std_logic_vector(47 downto 0);

signal s_sticky, s_guard, s_round : std_logic;
signal s_roundup : std_logic;
signal s_frac_rnd, s_frac3 : std_logic_vector(24 downto 0);
signal s_shr3 : std_logic;
signal s_r_zeros : std_logic_vector(5 downto 0);
signal s_lost : std_logic;
signal s_op_0 : std_logic;
signal s_expo3 : std_logic_vector(8 downto 0);

signal s_infa, s_infb : std_logic;
signal s_nan_in, s_nan_op, s_nan_a, s_nan_b : std_logic;

begin

	-- Input Register
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			s_opa_i <= opa_i;
			s_opb_i <= opb_i;	
			s_expa <= opa_i(30 downto 23);
			s_expb <= opb_i(30 downto 23);
			s_exp_10_i <= exp_10_i;
			s_fract_48_i <= fract_48_i;
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

	--*** Stage 1 ****
	-- figure out the exponent and howmuch the fraction has to be shiftd right/left
	
	s_carry <= s_fract_48_i(47);
	
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if s_fract_48_i(47)='0' then	
				s_zeros <= count_l_zeros(s_fract_48_i(46 downto 1));
			else 
				s_zeros <= "000000";
			end if;
			s_r_zeros <= count_r_zeros(s_fract_48_i);
		end if;
	end process;

	s_exp_10a <= s_exp_10_i + ("000000000"&s_carry);		
	s_exp_10b <= s_exp_10a - ("0000"&s_zeros);
	
	process(clk_i)
		variable v_shr1, v_shl1 : std_logic_vector(9 downto 0); 
	begin
	if rising_edge(clk_i) then
		if s_exp_10a(9)='1' or s_exp_10a="0000000000" then
			v_shr1 := "0000000001" - s_exp_10a + ("000000000"&s_carry);
			v_shl1 := (others =>'0');
			s_expo1 <= "000000001";
		else
			if s_exp_10b(9)='1' or s_exp_10b="0000000000" then
				v_shr1 := (others =>'0');
				v_shl1 := ("0000"&s_zeros) - s_exp_10a;
				s_expo1 <= "000000001";
			elsif s_exp_10b(8)='1' then
				v_shr1 := (others =>'0');
				v_shl1 := (others =>'0');
				s_expo1 <= "011111111";
			else
				v_shr1 := ("000000000"&s_carry);
				v_shl1 := ("0000"&s_zeros);
				s_expo1 <= s_exp_10b(8 downto 0);
			end if;
		end if;
		if  v_shr1(6)='1' then --"110000" = 48; maximal shift-right postions
	    	s_shr2 <= "111111";
	    else 
			s_shr2 <= v_shr1(5 downto 0);
		end if;
		s_shl2 <= v_shl1(5 downto 0);
		end if;
	end process;

	
	-- *** Stage 2 ***
	-- Shifting the fraction and rounding
		
		
	-- shift the fraction
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if s_shr2 /= "000000" then
				s_frac2a <= shr(s_fract_48_i, s_shr2);
			else 
				s_frac2a <= shl(s_fract_48_i, s_shl2); 
			end if;
		end if;
	end process;
	
	s_expo2b <= s_expo1 - "000000001" when s_frac2a(46)='0' else s_expo1;

	

	-- signals if precision was last during the right-shift above
	s_lost <= '1' when (s_shr2+("00000"&s_shr3)) > s_r_zeros else '0';
	
	
	-- ***Stage 3***
	-- Rounding

	--								   23
	--									|	
	-- 			xx00000000000000000000000grsxxxxxxxxxxxxxxxxxxxx
	-- guard bit: s_frac2a(23) (LSB of output)
    -- round bit: s_frac2a(22)
	s_guard <= s_frac2a(22);
	s_round <= s_frac2a(21);
	s_sticky <= or_reduce(s_frac2a(20 downto 0)) or s_lost;
	
	s_roundup <= s_guard and ((s_round or s_sticky)or s_frac2a(23)) when s_rmode_i="00" else -- round to nearset even
				 ( s_guard or s_round or s_sticky) and (not s_sign_i) when s_rmode_i="10" else -- round up
				 ( s_guard or s_round or s_sticky) and (s_sign_i) when s_rmode_i="11" else -- round down
				 '0'; -- round to zero(truncate = no rounding)
				 	
	
	process(clk_i)
	begin
	if rising_edge(clk_i) then
		if s_roundup='1' then 
			s_frac_rnd <= (s_frac2a(47 downto 23)) + "1"; 
		else 
			s_frac_rnd <= (s_frac2a(47 downto 23));
		end if;
	end if;
	end process;
	
	s_shr3 <= s_frac_rnd(24);


	
	s_expo3 <= s_expo2b + '1' when s_shr3='1' and s_expo2b /= "011111111" else s_expo2b;
	s_frac3 <= ("0"&s_frac_rnd(24 downto 1)) when s_shr3='1' and s_expo2b /= "011111111" else s_frac_rnd; 
	

	---***Stage 4****
	-- Output
		
	s_op_0 <= not ( or_reduce(s_opa_i(30 downto 0)) and or_reduce(s_opb_i(30 downto 0)) );
	
	s_infa <= '1' when s_expa="11111111"  else '0';
	s_infb <= '1' when s_expb="11111111"  else '0';

	s_nan_a <= '1' when (s_infa='1' and or_reduce (s_opa_i(22 downto 0))='1') else '0';
	s_nan_b <= '1' when (s_infb='1' and or_reduce (s_opb_i(22 downto 0))='1') else '0';
	s_nan_in <= '1' when s_nan_a='1' or  s_nan_b='1' else '0';
	s_nan_op <= '1' when (s_infa or s_infb)='1' and s_op_0='1' else '0';-- 0 * inf = nan


	s_overflow <= '1' when s_expo3 = "011111111" and (s_infa or s_infb)='0' else '0';

	s_ine_o <= '1' when s_op_0='0' and (s_lost or or_reduce(s_frac2a(22 downto 0)) or s_overflow)='1' else '0';
	
	process(s_sign_i, s_expo3, s_frac3, s_nan_in, s_nan_op, s_infa, s_infb, s_overflow, s_r_zeros)
	begin
		if (s_nan_in or s_nan_op)='1' then
			s_output_o <= s_sign_i & QNAN;
		elsif (s_infa or s_infb)='1' or s_overflow='1' then
				s_output_o <= s_sign_i & INF;	
		elsif s_r_zeros=48 then
				s_output_o <= s_sign_i & ZERO_VECTOR;			
		else
				s_output_o <= s_sign_i & s_expo3(7 downto 0) & s_frac3(22 downto 0);

		end if;
	end process;

end rtl;