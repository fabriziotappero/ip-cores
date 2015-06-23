-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: addition/subtraction entity for the addition/subtraction unit
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
use IEEE.std_logic_arith.all;

library work;
use work.fpupack.all;

entity addsub_28 is
	port(
			clk_i 			: in std_logic;
			fpu_op_i		: in std_logic;
			fracta_i		: in std_logic_vector(FRAC_WIDTH+4 downto 0); -- carry(1) & hidden(1) & fraction(23) & guard(1) & round(1) & sticky(1)
			fractb_i		: in std_logic_vector(FRAC_WIDTH+4 downto 0);
			signa_i 		: in std_logic;
			signb_i 		: in std_logic;
			fract_o			: out std_logic_vector(FRAC_WIDTH+4 downto 0);
			sign_o 			: out std_logic);
end addsub_28;


architecture rtl of addsub_28 is

signal s_fracta_i, s_fractb_i : std_logic_vector(FRAC_WIDTH+4 downto 0);
signal s_fract_o : std_logic_vector(FRAC_WIDTH+4 downto 0);
signal s_signa_i, s_signb_i, s_sign_o : std_logic;
signal s_fpu_op_i : std_logic;

signal fracta_lt_fractb : std_logic;
signal s_addop: std_logic;

begin

-- Input Register
--process(clk_i)
--begin
--	if rising_edge(clk_i) then	
		s_fracta_i <= fracta_i;
		s_fractb_i <= fractb_i;
		s_signa_i<= signa_i;
		s_signb_i<= signb_i;
		s_fpu_op_i <= fpu_op_i;
--	end if;
--end process;	

-- Output Register
process(clk_i)
begin
	if rising_edge(clk_i) then	
		fract_o <= s_fract_o;
		sign_o <= s_sign_o;	
	end if;
end process;

fracta_lt_fractb <= '1' when s_fracta_i > s_fractb_i else '0';

-- check if its a subtraction or an addition operation
s_addop <= ((s_signa_i xor s_signb_i)and not (s_fpu_op_i)) or ((s_signa_i xnor s_signb_i)and (s_fpu_op_i));

-- sign of result
s_sign_o <= '0' when s_fract_o = conv_std_logic_vector(0,28) and (s_signa_i and s_signb_i)='0' else 
										((not s_signa_i) and ((not fracta_lt_fractb) and (fpu_op_i xor s_signb_i))) or
										((s_signa_i) and (fracta_lt_fractb or (fpu_op_i xor s_signb_i)));

-- add/substract
process(s_fracta_i, s_fractb_i, s_addop, fracta_lt_fractb)
begin
	if s_addop='0' then
		s_fract_o <= s_fracta_i + s_fractb_i;
	else
		if fracta_lt_fractb = '1' then 
			s_fract_o <= s_fracta_i - s_fractb_i;
		else
			s_fract_o <= s_fractb_i - s_fracta_i;				
		end if;
	end if;
end process;




end rtl;

