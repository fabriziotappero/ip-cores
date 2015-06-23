-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: post-normalization entity for the square-root unit
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

entity post_norm_sqrt is
	port(	 
			clk_i		  	: in std_logic;
			opa_i			: in std_logic_vector(FP_WIDTH-1 downto 0);
			fract_26_i		: in std_logic_vector(FRAC_WIDTH+2 downto 0);	-- hidden(1) & fraction(11)
			exp_i			: in std_logic_vector(EXP_WIDTH-1 downto 0);
			ine_i			: in std_logic;
			rmode_i			: in std_logic_vector(1 downto 0);
			output_o		: out std_logic_vector(FP_WIDTH-1 downto 0);
			ine_o			: out std_logic
		);
end post_norm_sqrt;

architecture rtl of post_norm_sqrt is

signal s_expa, s_exp_i : std_logic_vector(EXP_WIDTH-1 downto 0);
signal s_fract_26_i : std_logic_vector(FRAC_WIDTH+2 downto 0);
signal s_ine_i		: std_logic;
signal s_rmode_i			: std_logic_vector(1 downto 0);
signal s_output_o	: std_logic_vector(FP_WIDTH-1 downto 0);
signal s_sign_i : std_logic;
signal s_opa_i : std_logic_vector(FP_WIDTH-1 downto 0);
signal s_ine_o : std_logic;

signal s_expo : std_logic_vector(EXP_WIDTH-1 downto 0);
signal s_fraco1 : std_logic_vector(FRAC_WIDTH+2 downto 0);

signal s_guard, s_round, s_sticky, s_roundup : std_logic;
signal s_frac_rnd : std_logic_vector(FRAC_WIDTH downto 0);


signal s_infa : std_logic;
signal s_nan_op, s_nan_a: std_logic;

begin

	-- Input Register
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			s_opa_i <= opa_i;	
			s_expa <= opa_i(30 downto 23);
			s_sign_i <= opa_i(31);
			s_fract_26_i <= fract_26_i;
			s_ine_i <= ine_i;
			s_exp_i <= exp_i;
			s_rmode_i <= rmode_i;
		end if;
	end process;	

	-- Output Register
	process(clk_i)
	begin
		if rising_edge(clk_i) then	
			output_o <= s_output_o;
			ine_o <= s_ine_o;
		end if;
	end process;	 


	-- *** Stage 1 ***
	
	s_expo <= s_exp_i;
	
	s_fraco1 <= s_fract_26_i;
	

	-- ***Stage 2***
	-- Rounding
	
	s_guard <= s_fraco1(1);
	s_round <= s_fraco1(0);
	s_sticky <= s_ine_i;
	
	s_roundup <= s_guard and ((s_round or s_sticky)or s_fraco1(3)) when s_rmode_i="00" else -- round to nearset even
				 ( s_guard or s_round or s_sticky) and (not s_sign_i) when s_rmode_i="10" else -- round up
				 ( s_guard or s_round or s_sticky) and (s_sign_i) when s_rmode_i="11" else -- round down
				 '0'; -- round to zero(truncate = no rounding)
				 	
	process(clk_i)
	begin
	if rising_edge(clk_i) then
		if s_roundup='1' then 
			s_frac_rnd <= s_fraco1(25 downto 2) + '1'; 
		else 
			s_frac_rnd <= s_fraco1(25 downto 2);
		end if;
	end if;
	end process;
	
	
	
	-- ***Stage 3***
	-- Output
	
	s_infa <= '1' when s_expa="11111111"  else '0';
	s_nan_a <= '1' when (s_infa='1' and or_reduce (s_opa_i(22 downto 0))='1') else '0';
	s_nan_op <= '1' when s_sign_i='1' and or_reduce(s_opa_i(30 downto 0))='1' else '0'; -- sqrt(-x) = NaN
	
	s_ine_o <= '1' when s_ine_i='1' and (s_infa or s_nan_a or s_nan_op)='0' else '0';
	
	process( s_nan_a, s_nan_op, s_infa, s_sign_i, s_expo, s_frac_rnd)
	begin
		if (s_nan_a or s_nan_op)='1' then
			s_output_o <= s_sign_i & QNAN;
		elsif s_infa ='1'  then
				s_output_o <= s_sign_i & INF;	
		else
				s_output_o <= s_sign_i & s_expo & s_frac_rnd(22 downto 0);

		end if;
	end process;

end rtl;