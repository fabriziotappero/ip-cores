-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: multiplication entity for the multiplication unit
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

library work;
use work.fpupack.all;

entity mul_24 is
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
end mul_24;

architecture rtl of mul_24 is



signal s_fracta_i, s_fractb_i : std_logic_vector(FRAC_WIDTH downto 0);
signal s_signa_i, s_signb_i, s_sign_o : std_logic;
signal s_fract_o: std_logic_vector(2*FRAC_WIDTH+1 downto 0);
signal s_start_i, s_ready_o : std_logic;

signal a_h, a_l, b_h, b_l : std_logic_vector(11 downto 0);
signal a_h_h, a_h_l, b_h_h, b_h_l, a_l_h, a_l_l, b_l_h, b_l_l : std_logic_vector(5 downto 0);

type op_6 is array (7 downto 0) of std_logic_vector(5 downto 0);
type prod_6 is array (3 downto 0) of op_6;

type prod_48 is array (4 downto 0) of std_logic_vector(47 downto 0);
type sum_24 is array (3 downto 0) of std_logic_vector(23 downto 0);

type a is array (3 downto 0) of std_logic_vector(23 downto 0);
type prod_24 is array (3 downto 0) of a;

signal prod : prod_6;
signal sum : sum_24;
signal prod_a_b : prod_48;

signal count : integer range 0 to 4;


type t_state is (waiting,busy);
signal s_state : t_state;

signal prod2 : prod_24;
begin


-- Input Register
process(clk_i)
begin
	if rising_edge(clk_i) then	
		s_fracta_i <= fracta_i;
		s_fractb_i <= fractb_i;
		s_signa_i<= signa_i;
		s_signb_i<= signb_i;
		s_start_i<=start_i;
	end if;
end process;	

-- Output Register
--process(clk_i)
--begin
--	if rising_edge(clk_i) then	
		fract_o <= s_fract_o;
		sign_o <= s_sign_o;
		ready_o<=s_ready_o;
--	end if;
--end process;


-- FSM
process(clk_i)
begin
	if rising_edge(clk_i) then
		if s_start_i ='1' then
			s_state <= busy;
			count <= 0; 
		elsif count=4 and s_state=busy then
			s_state <= waiting;
			s_ready_o <= '1';
			count <=0; 
		elsif s_state=busy then
			count <= count + 1;
		else
			s_state <= waiting;
			s_ready_o <= '0';
		end if;
	end if;	
end process;

s_sign_o <= s_signa_i xor s_signb_i;

--"000000000000"
-- A = A_h x 2^N + A_l , B = B_h x 2^N + B_l
-- A x B = A_hxB_hx2^2N + (A_h xB_l + A_lxB_h)2^N + A_lxB_l
a_h <= s_fracta_i(23 downto 12);
a_l <= s_fracta_i(11 downto 0);
b_h <= s_fractb_i(23 downto 12);
b_l <= s_fractb_i(11 downto 0);



a_h_h <= a_h(11 downto 6);
a_h_l <= a_h(5 downto 0);
b_h_h <= b_h(11 downto 6);
b_h_l <= b_h(5 downto 0);

a_l_h <= a_l(11 downto 6);
a_l_l <= a_l(5 downto 0);
b_l_h <= b_l(11 downto 6);
b_l_l <= b_l(5 downto 0);


prod(0)(0) <= a_h_h; prod(0)(1) <= b_h_h;
prod(0)(2) <= a_h_h; prod(0)(3) <= b_h_l; 
prod(0)(4) <= a_h_l; prod(0)(5) <= b_h_h;
prod(0)(6) <= a_h_l; prod(0)(7) <= b_h_l;


prod(1)(0) <= a_h_h; prod(1)(1) <= b_l_h;
prod(1)(2) <= a_h_h; prod(1)(3) <= b_l_l;
prod(1)(4) <= a_h_l; prod(1)(5) <= b_l_h;
prod(1)(6) <= a_h_l; prod(1)(7) <= b_l_l;

prod(2)(0) <= a_l_h; prod(2)(1) <= b_h_h;
prod(2)(2) <= a_l_h; prod(2)(3) <= b_h_l;
prod(2)(4) <= a_l_l; prod(2)(5) <= b_h_h;
prod(2)(6) <= a_l_l; prod(2)(7) <= b_h_l;

prod(3)(0) <= a_l_h; prod(3)(1) <= b_l_h;
prod(3)(2) <= a_l_h; prod(3)(3) <= b_l_l;
prod(3)(4) <= a_l_l; prod(3)(5) <= b_l_h;
prod(3)(6) <= a_l_l; prod(3)(7) <= b_l_l;



process(clk_i)
begin
if rising_edge(clk_i) then
	if count < 4 then
		prod2(count)(0)  <= (prod(count)(0)*prod(count)(1))&"000000000000"; 
		prod2(count)(1) <= "000000"&(prod(count)(2)*prod(count)(3))&"000000";
		prod2(count)(2) <= "000000"&(prod(count)(4)*prod(count)(5))&"000000";
		prod2(count)(3) <= "000000000000"&(prod(count)(6)*prod(count)(7));
	end if;
end if;
end process;



process(clk_i)
begin
if rising_edge(clk_i) then
	if count > 0 and s_state=busy then
		sum(count-1) <= prod2(count-1)(0) + prod2(count-1)(1) + prod2(count-1)(2) + prod2(count-1)(3);
	end if;
end if;
end process;



-- Last stage


	prod_a_b(0) <= sum(0)&"000000000000000000000000";
	prod_a_b(1) <= "000000000000"&sum(1)&"000000000000";
	prod_a_b(2) <= "000000000000"&sum(2)&"000000000000";
	prod_a_b(3) <= "000000000000000000000000"&sum(3);

	prod_a_b(4) <= prod_a_b(0) + prod_a_b(1) + prod_a_b(2) + prod_a_b(3);

	s_fract_o <= prod_a_b(4);



end rtl;

