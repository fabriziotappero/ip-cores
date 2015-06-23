-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: top entity
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library work;
use work.comppack.all;
use work.fpupack.all;


entity fpu is
    port (
        clk_i 			: in std_logic;

        -- Input Operands A & B
        opa_i        	: in std_logic_vector(FP_WIDTH-1 downto 0);  -- Default: FP_WIDTH=32 
        opb_i           : in std_logic_vector(FP_WIDTH-1 downto 0);
        
        -- fpu operations (fpu_op_i):
		-- ========================
		-- 000 = add, 
		-- 001 = substract, 
		-- 010 = multiply, 
		-- 011 = divide,
		-- 100 = square root
		-- 101 = unused
		-- 110 = unused
		-- 111 = unused
        fpu_op_i		: in std_logic_vector(2 downto 0);
        
        -- Rounding Mode: 
        -- ==============
        -- 00 = round to nearest even(default), 
        -- 01 = round to zero, 
        -- 10 = round up, 
        -- 11 = round down
        rmode_i 		: in std_logic_vector(1 downto 0);
        
        -- Output port   
        output_o        : out std_logic_vector(FP_WIDTH-1 downto 0);
        
        -- Control signals
        start_i			: in std_logic; -- is also restart signal
        ready_o 		: out std_logic;
        
        -- Exceptions
        ine_o 			: out std_logic; -- inexact
        overflow_o  	: out std_logic; -- overflow
        underflow_o 	: out std_logic; -- underflow
        div_zero_o  	: out std_logic; -- divide by zero
        inf_o			: out std_logic; -- infinity
        zero_o			: out std_logic; -- zero
        qnan_o			: out std_logic; -- queit Not-a-Number
        snan_o			: out std_logic -- signaling Not-a-Number
	);   
end fpu;

architecture rtl of fpu is
    

	constant MUL_SERIAL: integer range 0 to 1 := 0; -- 0 for parallel multiplier, 1 for serial
	constant MUL_COUNT: integer:= 11; --11 for parallel multiplier, 34 for serial
		
	-- Input/output registers
	signal s_opa_i, s_opb_i : std_logic_vector(FP_WIDTH-1 downto 0);
	signal s_fpu_op_i		: std_logic_vector(2 downto 0);
	signal s_rmode_i : std_logic_vector(1 downto 0);
	signal s_output_o : std_logic_vector(FP_WIDTH-1 downto 0);
    signal s_ine_o, s_overflow_o, s_underflow_o, s_div_zero_o, s_inf_o, s_zero_o, s_qnan_o, s_snan_o : std_logic;
	
	type   t_state is (waiting,busy);
	signal s_state : t_state;
	signal s_start_i : std_logic;
	signal s_count : integer;
	signal s_output1 : std_logic_vector(FP_WIDTH-1 downto 0);	
	signal s_infa, s_infb : std_logic;
	
	--	***Add/Substract units signals***

	signal prenorm_addsub_fracta_28_o, prenorm_addsub_fractb_28_o : std_logic_vector(27 downto 0);
	signal prenorm_addsub_exp_o : std_logic_vector(7 downto 0); 
	
	signal addsub_fract_o : std_logic_vector(27 downto 0); 
	signal addsub_sign_o : std_logic;
	
	signal postnorm_addsub_output_o : std_logic_vector(31 downto 0); 
	signal postnorm_addsub_ine_o : std_logic;
	
	--	***Multiply units signals***
	
	signal pre_norm_mul_exp_10 : std_logic_vector(9 downto 0);
	signal pre_norm_mul_fracta_24	: std_logic_vector(23 downto 0);
	signal pre_norm_mul_fractb_24	: std_logic_vector(23 downto 0);
	 	
	signal mul_24_fract_48 : std_logic_vector(47 downto 0);
	signal mul_24_sign	: std_logic;
	signal serial_mul_fract_48 : std_logic_vector(47 downto 0);
	signal serial_mul_sign	: std_logic;
	
	signal mul_fract_48: std_logic_vector(47 downto 0);
	signal mul_sign: std_logic;
	
	signal post_norm_mul_output	: std_logic_vector(31 downto 0);
	signal post_norm_mul_ine	: std_logic;
	
	--	***Division units signals***
	
	signal pre_norm_div_dvdnd : std_logic_vector(49 downto 0);
	signal pre_norm_div_dvsor : std_logic_vector(26 downto 0);
	signal pre_norm_div_exp	: std_logic_vector(EXP_WIDTH+1 downto 0);
	
	signal serial_div_qutnt : std_logic_vector(26 downto 0);
	signal serial_div_rmndr : std_logic_vector(26 downto 0);
	signal serial_div_sign : std_logic;
	signal serial_div_div_zero : std_logic;
	
	signal post_norm_div_output : std_logic_vector(31 downto 0);
	signal post_norm_div_ine : std_logic;
	
	--	***Square units***
	
	signal pre_norm_sqrt_fracta_o		: std_logic_vector(51 downto 0);
	signal pre_norm_sqrt_exp_o				: std_logic_vector(7 downto 0);
			 
	signal sqrt_sqr_o			: std_logic_vector(25 downto 0);
	signal sqrt_ine_o			: std_logic;

	signal post_norm_sqrt_output	: std_logic_vector(31 downto 0);
	signal post_norm_sqrt_ine_o		: std_logic;
	
	
begin
	--***Add/Substract units***
	
	i_prenorm_addsub: pre_norm_addsub
    	port map (
    	  clk_i => clk_i,
				opa_i => s_opa_i,
				opb_i => s_opb_i,
				fracta_28_o => prenorm_addsub_fracta_28_o,
				fractb_28_o => prenorm_addsub_fractb_28_o,
				exp_o=> prenorm_addsub_exp_o);
				
	i_addsub: addsub_28
		port map(
			 clk_i => clk_i, 			
			 fpu_op_i => s_fpu_op_i(0),		 
			 fracta_i	=> prenorm_addsub_fracta_28_o,	
			 fractb_i	=> prenorm_addsub_fractb_28_o,		
			 signa_i =>  s_opa_i(31),			
			 signb_i =>  s_opb_i(31),				
			 fract_o => addsub_fract_o,			
			 sign_o => addsub_sign_o);	
			 
	i_postnorm_addsub: post_norm_addsub
	port map(
		clk_i => clk_i,		
		opa_i => s_opa_i,
		opb_i => s_opb_i,	
		fract_28_i => addsub_fract_o,
		exp_i => prenorm_addsub_exp_o,
		sign_i => addsub_sign_o,
		fpu_op_i => s_fpu_op_i(0), 
		rmode_i => s_rmode_i,
		output_o => postnorm_addsub_output_o,
		ine_o => postnorm_addsub_ine_o
		);
	
	--***Multiply units***
	
	i_pre_norm_mul: pre_norm_mul
	port map(
		clk_i => clk_i,		
		opa_i => s_opa_i,
		opb_i => s_opb_i,
		exp_10_o => pre_norm_mul_exp_10,
		fracta_24_o	=> pre_norm_mul_fracta_24,
		fractb_24_o	=> pre_norm_mul_fractb_24);
			 	
	i_mul_24 : mul_24
	port map(
			 clk_i => clk_i,
			 fracta_i => pre_norm_mul_fracta_24,
			 fractb_i => pre_norm_mul_fractb_24,
			 signa_i => s_opa_i(31),
			 signb_i => s_opb_i(31),
			 start_i => start_i,
			 fract_o => mul_24_fract_48, 
			 sign_o =>	mul_24_sign,
			 ready_o => open);	
			 
	i_serial_mul : serial_mul
	port map(
			 clk_i => clk_i,
			 fracta_i => pre_norm_mul_fracta_24,
			 fractb_i => pre_norm_mul_fractb_24,
			 signa_i => s_opa_i(31),
			 signb_i => s_opb_i(31),
			 start_i => s_start_i,
			 fract_o => serial_mul_fract_48, 
			 sign_o =>	serial_mul_sign,
			 ready_o => open);	
	
	-- serial or parallel multiplier will be choosed depending on constant MUL_SERIAL
	mul_fract_48 <= mul_24_fract_48 when MUL_SERIAL=0 else serial_mul_fract_48;
	mul_sign <= mul_24_sign when MUL_SERIAL=0 else serial_mul_sign;
	
	i_post_norm_mul : post_norm_mul
	port map(
			 clk_i => clk_i,
			 opa_i => s_opa_i,
			 opb_i => s_opb_i,
			 exp_10_i => pre_norm_mul_exp_10,
			 fract_48_i	=> mul_fract_48,
			 sign_i	=> mul_sign,
			 rmode_i => s_rmode_i,
			 output_o => post_norm_mul_output,
			 ine_o => post_norm_mul_ine
			);
		
	--***Division units***
	
	i_pre_norm_div : pre_norm_div
	port map(
			 clk_i => clk_i,
			 opa_i => s_opa_i,
			 opb_i => s_opb_i,
			 exp_10_o => pre_norm_div_exp,
			 dvdnd_50_o	=> pre_norm_div_dvdnd,
			 dvsor_27_o	=> pre_norm_div_dvsor);
			 
	i_serial_div : serial_div
	port map(
			 clk_i=> clk_i,
			 dvdnd_i => pre_norm_div_dvdnd,
			 dvsor_i => pre_norm_div_dvsor,
			 sign_dvd_i => s_opa_i(31),
			 sign_div_i => s_opb_i(31),
			 start_i => s_start_i,
			 ready_o => open,
			 qutnt_o => serial_div_qutnt,
			 rmndr_o => serial_div_rmndr,
			 sign_o => serial_div_sign,
			 div_zero_o	=> serial_div_div_zero);
	
	i_post_norm_div : post_norm_div
	port map(
			 clk_i => clk_i,
			 opa_i => s_opa_i,
			 opb_i => s_opb_i,
			 qutnt_i =>	serial_div_qutnt,
			 rmndr_i => serial_div_rmndr,
			 exp_10_i => pre_norm_div_exp,
			 sign_i	=> serial_div_sign,
			 rmode_i =>	s_rmode_i,
			 output_o => post_norm_div_output,
			 ine_o => post_norm_div_ine);
			 
	
	--***Square units***

	i_pre_norm_sqrt : pre_norm_sqrt
	port map(
			 clk_i => clk_i,
			 opa_i => s_opa_i,
			 fracta_52_o => pre_norm_sqrt_fracta_o,
			 exp_o => pre_norm_sqrt_exp_o);
		
	i_sqrt: sqrt 
	generic map(RD_WIDTH=>52, SQ_WIDTH=>26) 
	port map(
			 clk_i => clk_i,
			 rad_i => pre_norm_sqrt_fracta_o, 
			 start_i => s_start_i, 
	   		 ready_o => open, 
	  		 sqr_o => sqrt_sqr_o,
			 ine_o => sqrt_ine_o);

	i_post_norm_sqrt : post_norm_sqrt
	port map(
			clk_i => clk_i,
			opa_i => s_opa_i,
			fract_26_i => sqrt_sqr_o,
			exp_i => pre_norm_sqrt_exp_o,
			ine_i => sqrt_ine_o,
			rmode_i => s_rmode_i,
			output_o => post_norm_sqrt_output,
			ine_o => post_norm_sqrt_ine_o);
			
			
			
-----------------------------------------------------------------			

	-- Input Register
	process(clk_i)
	begin
		if rising_edge(clk_i) then	
			s_opa_i <= opa_i;
			s_opb_i <= opb_i;
			s_fpu_op_i <= fpu_op_i;
			s_rmode_i <= rmode_i;
			s_start_i <= start_i;
		end if;
	end process;
	  
	-- Output Register
	process(clk_i)
	begin
		if rising_edge(clk_i) then	
			output_o <= s_output_o;
			ine_o <= s_ine_o;
			overflow_o <= s_overflow_o;
			underflow_o <= s_underflow_o;
			div_zero_o <= s_div_zero_o;
			inf_o <= s_inf_o;
			zero_o <= s_zero_o;
			qnan_o <= s_qnan_o;
			snan_o <= s_snan_o;
		end if;
	end process;	

    
	-- FSM
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if s_start_i ='1' then
				s_state <= busy;
				s_count <= 0;
			elsif s_count=6 and ((fpu_op_i="000") or (fpu_op_i="001")) then
				s_state <= waiting;
				ready_o <= '1';
				s_count <=0;
			elsif s_count=MUL_COUNT and fpu_op_i="010" then
				s_state <= waiting;
				ready_o <= '1';
				s_count <=0;
			elsif s_count=33 and fpu_op_i="011" then
				s_state <= waiting;
				ready_o <= '1';
				s_count <=0;
			elsif s_count=33 and fpu_op_i="100" then
				s_state <= waiting;
				ready_o <= '1';
				s_count <=0;			
			elsif s_state=busy then
				s_count <= s_count + 1;
			else
				s_state <= waiting;
				ready_o <= '0';
			end if;
	end if;	
	end process;
	        
	-- Output Multiplexer
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if fpu_op_i="000" or fpu_op_i="001" then	
				s_output1 		<= postnorm_addsub_output_o;
				s_ine_o 		<= postnorm_addsub_ine_o;
			elsif fpu_op_i="010" then
				s_output1 	<= post_norm_mul_output;
				s_ine_o 		<= post_norm_mul_ine;
			elsif fpu_op_i="011" then
				s_output1 	<= post_norm_div_output;
				s_ine_o 		<= post_norm_div_ine;		
			elsif fpu_op_i="100" then
				s_output1 	<= post_norm_sqrt_output;
				s_ine_o 	<= post_norm_sqrt_ine_o;			
			else
				s_output1 	<= (others => '0');
				s_ine_o 		<= '0';
			end if;
		end if;
	end process;	

	
	s_infa <= '1' when s_opa_i(30 downto 23)="11111111"  else '0';
	s_infb <= '1' when s_opb_i(30 downto 23)="11111111"  else '0';
	

	--In round down: the subtraction of two equal numbers other than zero are always -0!!!
	process(s_output1, s_rmode_i, s_div_zero_o, s_infa, s_infb, s_qnan_o, s_snan_o, s_zero_o, s_fpu_op_i, s_opa_i, s_opb_i )
	begin
			if s_rmode_i="00" or (s_div_zero_o or (s_infa or s_infb) or s_qnan_o or s_snan_o)='1' then --round-to-nearest-even
				s_output_o <= s_output1;
			elsif s_rmode_i="01" and s_output1(30 downto 23)="11111111" then
				--In round-to-zero: the sum of two non-infinity operands is never infinity,even if an overflow occures
				s_output_o <= s_output1(31) & "1111111011111111111111111111111";
			elsif s_rmode_i="10" and s_output1(31 downto 23)="111111111" then
				--In round-up: the sum of two non-infinity operands is never negative infinity,even if an overflow occures
				s_output_o <= "11111111011111111111111111111111";
			elsif s_rmode_i="11" then
				--In round-down: a-a= -0
				if (s_fpu_op_i="000" or s_fpu_op_i="001") and s_zero_o='1' and (s_opa_i(31) or (s_fpu_op_i(0) xor s_opb_i(31)))='1' then
					s_output_o <= "1" & s_output1(30 downto 0);	
				--In round-down: the sum of two non-infinity operands is never postive infinity,even if an overflow occures
				elsif s_output1(31 downto 23)="011111111" then
					s_output_o <= "01111111011111111111111111111111";
				else
					s_output_o <= s_output1;
				end if;			
			else
				s_output_o <= s_output1;
			end if;
	end process;
		

	-- Generate Exceptions 
	s_underflow_o <= '1' when s_output1(30 downto 23)="00000000" and s_ine_o='1' else '0'; 
	s_overflow_o <= '1' when s_output1(30 downto 23)="11111111" and s_ine_o='1' else '0';
	s_div_zero_o <= serial_div_div_zero when fpu_op_i="011" else '0';
	s_inf_o <= '1' when s_output1(30 downto 23)="11111111" and (s_qnan_o or s_snan_o)='0' else '0';
	s_zero_o <= '1' when or_reduce(s_output1(30 downto 0))='0' else '0';
	s_qnan_o <= '1' when s_output1(30 downto 0)=QNAN else '0';
    s_snan_o <= '1' when s_opa_i(30 downto 0)=SNAN or s_opb_i(30 downto 0)=SNAN else '0';


end rtl;