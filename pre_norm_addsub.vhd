-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: pre-normalization entity for the addition/subtraction unit
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

entity pre_norm_addsub is
	port(
			clk_i 			: in std_logic;
			opa_i			: in std_logic_vector(FP_WIDTH-1 downto 0);
			opb_i			: in std_logic_vector(FP_WIDTH-1 downto 0);
			fracta_28_o		: out std_logic_vector(FRAC_WIDTH+4 downto 0);	-- carry(1) & hidden(1) & fraction(23) & guard(1) & round(1) & sticky(1)
			fractb_28_o		: out std_logic_vector(FRAC_WIDTH+4 downto 0);
			exp_o			: out std_logic_vector(EXP_WIDTH-1 downto 0)
		);
end pre_norm_addsub;


architecture rtl of pre_norm_addsub is


	signal s_exp_o : std_logic_vector(EXP_WIDTH-1 downto 0);
	signal s_fracta_28_o, s_fractb_28_o : std_logic_vector(FRAC_WIDTH+4 downto 0);
	signal s_expa, s_expb : std_logic_vector(EXP_WIDTH-1 downto 0);
	signal s_fracta, s_fractb : std_logic_vector(FRAC_WIDTH-1 downto 0);
	
	signal s_fracta_28, s_fractb_28, s_fract_sm_28, s_fract_shr_28 : std_logic_vector(FRAC_WIDTH+4 downto 0);
	
	signal s_exp_diff : std_logic_vector(EXP_WIDTH-1 downto 0);
	signal s_rzeros : std_logic_vector(5 downto 0);

	signal s_expa_eq_expb : std_logic;
	signal s_expa_lt_expb : std_logic;
	signal s_fracta_1 : std_logic;
	signal s_fractb_1 : std_logic;
	signal s_op_dn,s_opa_dn, s_opb_dn : std_logic;
	signal s_mux_diff : std_logic_vector(1 downto 0);
	signal s_mux_exp : std_logic;
	signal s_sticky : std_logic;
begin

	-- Input Register
	--process(clk_i)
	--begin
	--	if rising_edge(clk_i) then	
			s_expa <= opa_i(30 downto 23);
			s_expb <= opb_i(30 downto 23);
			s_fracta <= opa_i(22 downto 0);
			s_fractb <= opb_i(22 downto 0);
	--	end if;
	--end process;		
	
	-- Output Register
	process(clk_i)
	begin
		if rising_edge(clk_i) then	
		exp_o <= s_exp_o;
		fracta_28_o <= s_fracta_28_o;
		fractb_28_o <= s_fractb_28_o;	
		end if;
	end process;	
	
	s_expa_eq_expb <= '1' when s_expa = s_expb else '0';
	s_expa_lt_expb <= '1' when s_expa > s_expb else '0';
	
	-- '1' if fraction is not zero
	s_fracta_1 <= or_reduce(s_fracta);
	s_fractb_1 <= or_reduce(s_fractb); 
	
	-- opa or Opb is denormalized
	s_op_dn <= s_opa_dn or s_opb_dn; 
	s_opa_dn <= not or_reduce(s_expa);
	s_opb_dn <= not or_reduce(s_expb);
	
	-- output the larger exponent 
	s_mux_exp <= s_expa_lt_expb;
	process(clk_i)
	begin
		if rising_edge(clk_i) then	 
			case s_mux_exp is
				when '0' => s_exp_o <= s_expb;
				when '1' => s_exp_o <= s_expa;
				when others => s_exp_o <= "11111111";
			end case; 
		end if;
	end process;
	
	-- convert to an easy to handle floating-point format
	s_fracta_28 <= "01" & s_fracta & "000" when s_opa_dn='0' else "00" & s_fracta & "000";
	s_fractb_28 <= "01" & s_fractb & "000" when s_opb_dn='0' else "00" & s_fractb & "000";
	
	
	s_mux_diff <= s_expa_lt_expb & (s_opa_dn xor s_opb_dn);
	process(clk_i)
	begin
		if rising_edge(clk_i) then	
			-- calculate howmany postions the fraction will be shifted
			case s_mux_diff is
				when "00"=> s_exp_diff <= s_expb - s_expa;
				when "01"=>	s_exp_diff <= s_expb - (s_expa+"00000001");
				when "10"=> s_exp_diff <= s_expa - s_expb;
				when "11"=> s_exp_diff <= s_expa - (s_expb+"00000001");
				when others => s_exp_diff <= "11110000";
			end case;
		end if;
	end process;
	
	
	s_fract_sm_28 <= s_fracta_28 when s_expa_lt_expb='0' else s_fractb_28;
	
	-- shift-right the fraction if necessary
	s_fract_shr_28 <= shr(s_fract_sm_28, s_exp_diff);
	
	-- count the zeros from right to check if result is inexact
	s_rzeros <= count_r_zeros(s_fract_sm_28);
	s_sticky <= '1' when s_exp_diff > s_rzeros and or_reduce(s_fract_sm_28)='1' else '0';
	
	s_fracta_28_o <= s_fracta_28 when s_expa_lt_expb='1' else s_fract_shr_28(27 downto 1) & (s_sticky or s_fract_shr_28(0));
	s_fractb_28_o <= s_fractb_28 when s_expa_lt_expb='0' else s_fract_shr_28(27 downto 1) & (s_sticky or s_fract_shr_28(0));
	

end rtl;
