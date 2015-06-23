-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: pre-normalization entity for the multiplication unit
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

entity pre_norm_mul is
	port(
			 clk_i		  : in std_logic;
			 opa_i			: in std_logic_vector(FP_WIDTH-1 downto 0);
			 opb_i			: in std_logic_vector(FP_WIDTH-1 downto 0);
			 exp_10_o			: out std_logic_vector(EXP_WIDTH+1 downto 0);
			 fracta_24_o		: out std_logic_vector(FRAC_WIDTH downto 0);	-- hidden(1) & fraction(23)
			 fractb_24_o		: out std_logic_vector(FRAC_WIDTH downto 0)
		);
end pre_norm_mul;

architecture rtl of pre_norm_mul is

signal s_expa, s_expb : std_logic_vector(EXP_WIDTH-1 downto 0);
signal s_fracta, s_fractb : std_logic_vector(FRAC_WIDTH-1 downto 0);
signal s_exp_10_o, s_expa_in, s_expb_in : std_logic_vector(EXP_WIDTH+1 downto 0);

signal s_opa_dn, s_opb_dn : std_logic;

begin

	
		s_expa <= opa_i(30 downto 23);
		s_expb <= opb_i(30 downto 23);
		s_fracta <= opa_i(22 downto 0);
		s_fractb <= opb_i(22 downto 0);

 	-- Output Register
	process(clk_i)
	begin
		if rising_edge(clk_i) then	
			exp_10_o <= s_exp_10_o;
		end if;
	end process;
	
	-- opa or opb is denormalized
	s_opa_dn <= not or_reduce(s_expa);
	s_opb_dn <= not or_reduce(s_expb);
	
	
	fracta_24_o <= not(s_opa_dn) & s_fracta;
	fractb_24_o <= not(s_opb_dn) & s_fractb;

	s_expa_in <= ("00"&s_expa) + ("000000000"&s_opa_dn);
	s_expb_in <= ("00"&s_expb) + ("000000000"&s_opb_dn);

	

	s_exp_10_o <= s_expa_in + s_expb_in - "0001111111";		



end rtl;
