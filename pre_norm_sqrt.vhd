-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: pre-normalization entity for the square-root unit
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

entity pre_norm_sqrt is
	port(
			 clk_i		  	: in std_logic;
			 opa_i			: in std_logic_vector(FP_WIDTH-1 downto 0);
			 fracta_52_o	: out std_logic_vector(2*(FRAC_WIDTH+3)-1 downto 0);
			 exp_o			: out std_logic_vector(EXP_WIDTH-1 downto 0)
		);
end pre_norm_sqrt;

architecture rtl of pre_norm_sqrt is

signal s_expa : std_logic_vector(EXP_WIDTH-1 downto 0);
signal s_exp_o, s_exp_tem : std_logic_vector(EXP_WIDTH downto 0);
signal s_fracta : std_logic_vector(FRAC_WIDTH-1 downto 0);
signal s_fracta_24 : std_logic_vector(FRAC_WIDTH downto 0);
signal s_fracta_52_o, s_fracta1_52_o, s_fracta2_52_o : std_logic_vector(2*(FRAC_WIDTH+3)-1 downto 0);
signal s_sqr_zeros_o : std_logic_vector(5 downto 0);


signal s_opa_dn : std_logic;

begin

	s_expa <= opa_i(30 downto 23);
	s_fracta <= opa_i(22 downto 0);


	exp_o <= s_exp_o(7 downto 0);
	fracta_52_o <= s_fracta_52_o;	

	-- opa or opb is denormalized
	s_opa_dn <= not or_reduce(s_expa);
	
	s_fracta_24 <= (not s_opa_dn) & s_fracta;
	
	-- count leading zeros
	s_sqr_zeros_o <= count_l_zeros(s_fracta_24 ); 
	
	-- adjust the exponent
	s_exp_tem <= ("0"&s_expa)+"001111111" - ("000"&s_sqr_zeros_o);
	
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if or_reduce(opa_i(30 downto 0))='1' then
				s_exp_o <= ("0"&s_exp_tem(8 downto 1)); 
			else 
				s_exp_o <= "000000000";
			end if;
		end if;
	end process;

	-- left-shift the radicand	
	s_fracta1_52_o <= shl(s_fracta_24, s_sqr_zeros_o) & "0000000000000000000000000000";
	s_fracta2_52_o <= '0' & shl(s_fracta_24, s_sqr_zeros_o) & "000000000000000000000000000";
	
	s_fracta_52_o <= s_fracta1_52_o when s_expa(0)='0' else s_fracta2_52_o; 

end rtl;
