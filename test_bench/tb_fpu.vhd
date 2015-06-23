-------------------------------------------------------------------------------
--
-- Project:	<Floating Point Unit Core>
--  	
-- Description: test bench for the FPU core
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
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use std.textio.all;
use work.txt_util.all;

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
		
        -- Rounding Mode: 
        -- ==============
        -- 00 = round to nearest even(default), 
        -- 01 = round to zero, 
        -- 10 = round up, 
        -- 11 = round down


entity tb_fpu is
end tb_fpu;

architecture rtl of tb_fpu is

component fpu 
    port (
        clk_i       	: in std_logic;
        opa_i       	: in std_logic_vector(31 downto 0);   
        opb_i       	: in std_logic_vector(31 downto 0);
        fpu_op_i		: in std_logic_vector(2 downto 0);
        rmode_i 		: in std_logic_vector(1 downto 0);  
        output_o    	: out std_logic_vector(31 downto 0);
		ine_o 			: out std_logic;
        overflow_o  	: out std_logic;
        underflow_o 	: out std_logic;
        div_zero_o  	: out std_logic;
        inf_o			: out std_logic;
        zero_o			: out std_logic;
        qnan_o			: out std_logic;
        snan_o			: out std_logic;
        start_i	  		: in  std_logic;
        ready_o 		: out std_logic	
	);   
end component;


signal clk_i : std_logic:= '1';
signal opa_i, opb_i : std_logic_vector(31 downto 0);
signal fpu_op_i		: std_logic_vector(2 downto 0);
signal rmode_i : std_logic_vector(1 downto 0);
signal output_o : std_logic_vector(31 downto 0);
signal start_i, ready_o : std_logic ; 
signal ine_o, overflow_o, underflow_o, div_zero_o, inf_o, zero_o, qnan_o, snan_o: std_logic;



signal slv_out : std_logic_vector(31 downto 0);

constant CLK_PERIOD :time := 10 ns; -- period of clk period


begin

    -- instantiate fpu
    i_fpu: fpu port map (
			clk_i => clk_i,
			opa_i => opa_i,
			opb_i => opb_i,
			fpu_op_i =>	fpu_op_i,
			rmode_i => rmode_i,	
			output_o => output_o,  
			ine_o => ine_o,
			overflow_o => overflow_o,
			underflow_o => underflow_o,		
        	div_zero_o => div_zero_o,
        	inf_o => inf_o,
        	zero_o => zero_o,		
        	qnan_o => qnan_o, 		
        	snan_o => snan_o,
        	start_i => start_i,
        	ready_o => ready_o);		
			

    ---------------------------------------------------------------------------
    -- toggle clock
    ---------------------------------------------------------------------------
    clk_i <= not(clk_i) after 5 ns;


    verify : process 
		--The operands and results are in Hex format. The test vectors must be placed in a strict order for the verfication to work.
		file testcases_file: TEXT open read_mode is "testcases.txt"; --Name of the file containing the test cases. 

		variable file_line: line;
		variable str_in: string(8 downto 1);
		variable str_fpu_op: string(3 downto 1);
		variable str_rmode: string(2 downto 1);
    begin


		---------------------------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------SoftFloat test vectors (10000 test cases for each operation) --------------------------------------------------------------------
		start_i <= '0';
		while not endfile(testcases_file) loop

			wait for CLK_PERIOD; start_i <= '1';
			
			str_read(testcases_file,str_in);
			opa_i <= strhex_to_slv(str_in);
			
			str_read(testcases_file,str_in);
			opb_i <= strhex_to_slv(str_in);

			str_read(testcases_file,str_fpu_op);
			fpu_op_i <= to_std_logic_vector(str_fpu_op);
			
			str_read(testcases_file,str_rmode);
			rmode_i <= to_std_logic_vector(str_rmode);
			
			str_read(testcases_file,str_in);
			slv_out <= strhex_to_slv(str_in);
			
			wait for CLK_PERIOD; start_i <= '0'; wait until ready_o='1';

			assert output_o = slv_out
			report "Error!!!"
			severity failure;
			str_read(testcases_file,str_in);
			
		end loop;		

		-------- Boundary values-----
		
		start_i <= '0';
		--		  seeeeeeeefffffffffffffffffffffff
		--infinity
		wait for CLK_PERIOD; start_i <= '1'; 
		opa_i <= "01111111011111111111111111111111";  
		opb_i <= "01111111011111111111111111111111"; 
		fpu_op_i <= "000";
		rmode_i <= "00";
		wait for CLK_PERIOD; start_i <= '0'; wait until ready_o='1';
		assert output_o="01111111100000000000000000000000"
		report "Error!!!"
		severity failure;
		
		--		  seeeeeeeefffffffffffffffffffffff
		-- 1 x1.001 - 1x1.000 = 0x0.001
		wait for CLK_PERIOD; start_i <= '1'; 
		opa_i <= "00000000100100000000000000000000";  
		opb_i <= "10000000100000000000000000000000"; 
		fpu_op_i <= "000";
		rmode_i <= "00";
		wait for CLK_PERIOD; start_i <= '0'; wait until ready_o='1';
		assert output_o="00000000000100000000000000000000"
		report "Error!!!"
		severity failure;	

		--		  seeeeeeeefffffffffffffffffffffff
		-- 10 x 1.0001 - 10 x 1.0000 = 
		wait for CLK_PERIOD; start_i <= '1'; 
		opa_i <= "00000001000010000000000000000000";  
		opb_i <= "10000001000000000000000000000000"; 
		fpu_op_i <= "000";
		rmode_i <= "00";
		wait for CLK_PERIOD; start_i <= '0'; wait until ready_o='1';
		assert output_o="00000000000100000000000000000000"
		report "Error!!!"
		severity failure;
		

		--		  seeeeeeeefffffffffffffffffffffff
		-- -0 -0 = -0  
		wait for CLK_PERIOD; start_i <= '1'; 
		opa_i <= "10000000000000000000000000000000";  
		opb_i <= "10000000000000000000000000000000"; 
		fpu_op_i <= "000";
		rmode_i <= "00";
		wait for CLK_PERIOD; start_i <= '0'; wait until ready_o='1';
		assert output_o="10000000000000000000000000000000"
		report "Error!!!"
		severity failure;
		
		--		  seeeeeeeefffffffffffffffffffffff
		-- 0 + x = x 
		wait for CLK_PERIOD; start_i <= '1'; 
		opa_i <= "00000000000000000000000000000000";  
		opb_i <= "01000010001000001000000000100000"; 
		fpu_op_i <= "000";
		rmode_i <= "00";
		wait for CLK_PERIOD; start_i <= '0'; wait until ready_o='1';
		assert output_o="01000010001000001000000000100000"
		report "Error!!!"
		severity failure;
		

		----------------------------------------------------------------------------------------------------------------------------------------------------
		assert false
		report "Success!!!.......Yahoooooooooooooo"
		severity failure;	
				
    	wait;

    end process verify;

end rtl;