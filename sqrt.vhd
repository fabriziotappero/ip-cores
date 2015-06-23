-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: square-root entity for the square-root unit
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

entity sqrt is
	generic	(RD_WIDTH: integer:=52; SQ_WIDTH: integer:=26); -- SQ_WIDTH = RD_WIDTH/2 (+ 1 if odd)
	port(
			 clk_i 			 : in std_logic;
			 rad_i			: in std_logic_vector(RD_WIDTH-1 downto 0); -- hidden(1) & fraction(23)
			 start_i			: in std_logic;
			 ready_o			: out std_logic;
			 sqr_o			: out std_logic_vector(SQ_WIDTH-1 downto 0);
			 ine_o			: out std_logic
		);
end sqrt;

architecture rtl of sqrt is

signal s_rad_i: std_logic_vector(RD_WIDTH-1 downto 0);
signal s_start_i, s_ready_o : std_logic;
signal s_sqr_o: std_logic_vector(RD_WIDTH-1 downto 0);
signal s_ine_o : std_logic;

constant ITERATIONS : integer:= RD_WIDTH/2; -- iterations = N/2
constant WIDTH_C : integer:= 5; -- log2(ITERATIONS)
                            							  --0000000000000000000000000000000000000000000000000000
constant CONST_B : std_logic_vector(RD_WIDTH-1 downto 0) :="0000000000000000000000000010000000000000000000000000"; -- b = 2^(N/2 - 1)
constant CONST_B_2: std_logic_vector(RD_WIDTH-1 downto 0):="0100000000000000000000000000000000000000000000000000"; -- b^2
constant CONST_C : std_logic_vector(WIDTH_C-1 downto 0):= "11010"; -- c = N/2


signal s_count : integer range 0 to ITERATIONS;

type t_state is (waiting,busy);
signal s_state : t_state;

signal b, b_2, r0, r0_2, r1, r1_2 : std_logic_vector(RD_WIDTH-1 downto 0);
signal c : std_logic_vector(WIDTH_C-1 downto 0);

	signal s_op1, s_op2, s_sum1a, s_sum1b, s_sum2a, s_sum2b : std_logic_vector(RD_WIDTH-1 downto 0);
	
begin


	-- Input Register
	process(clk_i)
	begin
		if rising_edge(clk_i) then	
			s_rad_i <= rad_i;
			s_start_i <= start_i;
		end if;
	end process;	
	
	-- Output Register
	process(clk_i)
	begin
		if rising_edge(clk_i) then	
			sqr_o <= s_sqr_o(SQ_WIDTH-1 downto 0);
			ine_o <= s_ine_o;
			ready_o <= s_ready_o;
		end if;
	end process;


	-- FSM
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if s_start_i ='1' then
				s_state <= busy;
				s_count <= ITERATIONS; 
			elsif s_count=0 and s_state=busy then
				s_state <= waiting;
				s_ready_o <= '1';
				s_count <=ITERATIONS; 
			elsif s_state=busy then
				s_count <= s_count - 1;
			else
				s_state <= waiting;
				s_ready_o <= '0';
			end if;
		end if;	
	end process;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
				if s_start_i='1' then
					b    <= CONST_B;
					b_2  <= CONST_B_2;
					c    <= CONST_C;
				else
					b   <= '0'&b(RD_WIDTH-1 downto 1); -- shr 1
					b_2 <= "00"&b_2(RD_WIDTH-1 downto 2);-- shr 2	
					c <= c - '1';
				end if;
		end if;
	end process;
	

	
	s_op1 <= r0_2 + b_2;
	s_op2 <= shl(r0, c);
	s_sum1a <= "00000000000000000000000000"& (r0(25 downto 0) - b(25 downto 0));
	s_sum2a <= "00000000000000000000000000"& (r0(25 downto 0) + b(25 downto 0));
	s_sum1b <= s_op1 - s_op2;
	s_sum2b <= s_op1 + s_op2;	



	process(clk_i)
		variable v_r1, v_r1_2 : std_logic_vector(RD_WIDTH-1 downto 0);
	begin
		if rising_edge(clk_i) then
				if s_start_i='1' then
					r0   <= (others =>'0');
					r0_2 <= (others =>'0');
				elsif s_state=busy then
					if r0_2 > s_rad_i then
						v_r1 := s_sum1a;
						v_r1_2 := s_sum1b;
					else
						v_r1 := s_sum2a;
						v_r1_2 := s_sum2b;				
					end if;
					r0 <= v_r1;
					r0_2 <= v_r1_2;
					r1 <= v_r1;
					r1_2 <= v_r1_2;
				end if;
		end if;
	end process;
	
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if s_start_i = '1' then
				s_sqr_o <= (others =>'0');
			elsif s_count=0 then
						if r1_2 > s_rad_i then
							s_sqr_o <= r1 - '1';
						else
							s_sqr_o <= r1;
						end if;		
			end if;
		end if;
	end process;
	
	
	-- check if result is inexact. In this way we saved 1 clk cycle!
	process(clk_i)
		variable v_r1_2 : std_logic_vector(RD_WIDTH-1 downto 0);
	begin
		if rising_edge(clk_i) then
			v_r1_2 := r1_2 - (r1(RD_WIDTH-2 downto 0)&"0") + '1';
			if s_count=0 then				
				if r1_2 = s_rad_i or v_r1_2=s_rad_i then
					s_ine_o <= '0';
				else
					s_ine_o <= '1';
				end if;
			end if;
			
		end if;
	end process;				
	
end rtl;