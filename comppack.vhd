-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: component package
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

library  ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fpupack.all;

package comppack is


--- Component Declartions ---	

	--***Add/Substract units***
	
	component pre_norm_addsub is
	port(clk_i 			: in std_logic;
			 opa_i			: in std_logic_vector(31 downto 0);
			 opb_i			: in std_logic_vector(31 downto 0);
			 fracta_28_o		: out std_logic_vector(27 downto 0);	-- carry(1) & hidden(1) & fraction(23) & guard(1) & round(1) & sticky(1)
			 fractb_28_o		: out std_logic_vector(27 downto 0);
			 exp_o			: out std_logic_vector(7 downto 0));
	end component;
	
	component addsub_28 is
	port(clk_i 			  : in std_logic;
			 fpu_op_i		   : in std_logic;
			 fracta_i			: in std_logic_vector(27 downto 0); -- carry(1) & hidden(1) & fraction(23) & guard(1) & round(1) & sticky(1)
			 fractb_i			: in std_logic_vector(27 downto 0);
			 signa_i 			: in std_logic;
			 signb_i 			: in std_logic;
			 fract_o			: out std_logic_vector(27 downto 0);
			 sign_o 			: out std_logic);
	end component;
	
	component post_norm_addsub is
	port(clk_i 				: in std_logic;
			 opa_i 				: in std_logic_vector(31 downto 0);
			 opb_i 				: in std_logic_vector(31 downto 0);
			 fract_28_i		: in std_logic_vector(27 downto 0);	-- carry(1) & hidden(1) & fraction(23) & guard(1) & round(1) & sticky(1)
			 exp_i			  : in std_logic_vector(7 downto 0);
			 sign_i			  : in std_logic;
			 fpu_op_i			: in std_logic;
			 rmode_i			: in std_logic_vector(1 downto 0);
			 output_o			: out std_logic_vector(31 downto 0);
			 ine_o				: out std_logic
		);
	end component;
	
	--***Multiplication units***
	
	component pre_norm_mul is
	port(
			 clk_i		  : in std_logic;
			 opa_i			: in std_logic_vector(31 downto 0);
			 opb_i			: in std_logic_vector(31 downto 0);
			 exp_10_o			: out std_logic_vector(9 downto 0);
			 fracta_24_o		: out std_logic_vector(23 downto 0);	-- hidden(1) & fraction(23)
			 fractb_24_o		: out std_logic_vector(23 downto 0)
		);
	end component;
	
	component mul_24 is
	port(
			 clk_i 			  : in std_logic;
			 fracta_i			: in std_logic_vector(23 downto 0); -- hidden(1) & fraction(23)
			 fractb_i			: in std_logic_vector(23 downto 0);
			 signa_i 			: in std_logic;
			 signb_i 			: in std_logic;
			 start_i			: in std_logic;
			 fract_o			: out std_logic_vector(47 downto 0);
			 sign_o 			: out std_logic;
			 ready_o			: out std_logic
			 );
	end component;
	
	component serial_mul is
	port(
			 clk_i 			  	: in std_logic;
			 fracta_i			: in std_logic_vector(FRAC_WIDTH downto 0); -- hidden(1) & fraction(23)
			 fractb_i			: in std_logic_vector(FRAC_WIDTH downto 0);
			 signa_i 			: in std_logic;
			 signb_i 			: in std_logic;
			 start_i			: in std_logic;
			 fract_o			: out std_logic_vector(2*FRAC_WIDTH+1 downto 0);
			 sign_o 			: out std_logic;
			 ready_o			: out std_logic
			 );
	end component;
	
	component post_norm_mul is
	port(
			 clk_i		  		: in std_logic;
			 opa_i					: in std_logic_vector(31 downto 0);
			 opb_i					: in std_logic_vector(31 downto 0);
			 exp_10_i			: in std_logic_vector(9 downto 0);
			 fract_48_i		: in std_logic_vector(47 downto 0);	-- hidden(1) & fraction(23)
			 sign_i					: in std_logic;
			 rmode_i			: in std_logic_vector(1 downto 0);
			 output_o				: out std_logic_vector(31 downto 0);
			 ine_o					: out std_logic
		);
	end component;
	
	--***Division units***
	
	component pre_norm_div is
	port(
			 clk_i		  	: in std_logic;
			 opa_i			: in std_logic_vector(FP_WIDTH-1 downto 0);
			 opb_i			: in std_logic_vector(FP_WIDTH-1 downto 0);
			 exp_10_o		: out std_logic_vector(EXP_WIDTH+1 downto 0);
			 dvdnd_50_o		: out std_logic_vector(2*(FRAC_WIDTH+2)-1 downto 0); 
			 dvsor_27_o		: out std_logic_vector(FRAC_WIDTH+3 downto 0)
		);
	end component;
	
	component serial_div is
	port(
			 clk_i 			  	: in std_logic;
			 dvdnd_i			: in std_logic_vector(2*(FRAC_WIDTH+2)-1 downto 0); -- hidden(1) & fraction(23)
			 dvsor_i			: in std_logic_vector(FRAC_WIDTH+3 downto 0);
			 sign_dvd_i 		: in std_logic;
			 sign_div_i 		: in std_logic;
			 start_i			: in std_logic;
			 ready_o			: out std_logic;
			 qutnt_o			: out std_logic_vector(FRAC_WIDTH+3 downto 0);
			 rmndr_o			: out std_logic_vector(FRAC_WIDTH+3 downto 0);
			 sign_o 			: out std_logic;
			 div_zero_o			: out std_logic
			 );
	end component;	
	
	component post_norm_div is
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
	end component;	
	
	
	--***Square units***
	
	component pre_norm_sqrt is
		port(
			 clk_i		  : in std_logic;
			 opa_i			: in std_logic_vector(31 downto 0);
			 fracta_52_o		: out std_logic_vector(51 downto 0);
			 exp_o				: out std_logic_vector(7 downto 0));
	end component;
	
	component sqrt is
		generic	(RD_WIDTH: integer; SQ_WIDTH: integer); -- SQ_WIDTH = RD_WIDTH/2 (+ 1 if odd)
		port(
			 clk_i 			 : in std_logic;
			 rad_i			: in std_logic_vector(RD_WIDTH-1 downto 0); -- hidden(1) & fraction(23)
			 start_i			: in std_logic;
			 ready_o			: out std_logic;
			 sqr_o			: out std_logic_vector(SQ_WIDTH-1 downto 0);
			 ine_o			: out std_logic);
	end component;
	
	
	component post_norm_sqrt is
	port(	 clk_i		  		: in std_logic;
			 opa_i					: in std_logic_vector(31 downto 0);
			 fract_26_i		: in std_logic_vector(25 downto 0);	-- hidden(1) & fraction(11)
			 exp_i				: in std_logic_vector(7 downto 0);
			 ine_i				: in std_logic;
			 rmode_i			: in std_logic_vector(1 downto 0);
			 output_o				: out std_logic_vector(31 downto 0);
			 ine_o					: out std_logic);
	end component;
	
		
end comppack;