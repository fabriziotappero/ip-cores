-------------------------------------------------------------------------------
--  File: mult_testbench.vhd                                                 --
--                                                                           --
--  Copyright (C) Deversys, 2003                                             --
--                                                                           --
--  function: testbench for multiplication algorithms                        --
--  (8*8 and 16*16 - bit implementations only !!!)                           --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;

library work;
use definitions.all;


entity mult_tb is
end mult_tb;

architecture TB_ARCHITECTURE of mult_tb is


component MULT_UNIT is
	port (
		CLK: in std_logic;
		A: in STD_LOGIC_VECTOR (data_width -1  downto 0);
		B: in STD_LOGIC_VECTOR (data_width - 1 downto 0);
		MUL_OUT: out STD_LOGIC_VECTOR (data_width * 2 -1 downto 0)
		);
end component;


	-- Stimuli
	signal A : std_logic_vector(data_width -1 downto 0); -- 1-st multiplicand
	signal B : std_logic_vector(data_width -1 downto 0); -- 2-nd multiplicand
  
	-- Observed
	signal MUL_OUT : std_logic_vector(data_width * 2 - 1 downto 0); -- result of multiplication
  signal MR : std_logic_vector(data_width * 2 - 1 downto 0) := (others => '0'); -- expected result

	signal AP : std_logic_vector(data_width -1 downto 0):= (others => '0'); -- delayed value of 1-st multiplicand
	signal BP : std_logic_vector(data_width -1 downto 0):= (others => '0'); -- delayed value of 2-nd multiplicand

  signal CLK1: std_logic := '0'; -- clock
  signal CLK: std_logic;  -- clock output
   
   
begin

   CLK1 <= not CLK1 after 20 ns;
   CLK <= CLK1;

process
  variable    A1 : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  variable    B1 : std_logic_vector(data_width - 1 downto 0) := (others => '0');
    

  procedure RND_GEN( variable A, B: inout std_logic_vector) is
  -- for random values generation the following polinom is used:
  -- x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x^1+1 
  variable RND: std_logic_vector(data_width * 2 - 1 downto 0); 
  begin
    RND := A & B;
    
    RND := RND(RND'high - 1 downto 0) & (not(
    
           -- comment next line for 8*8 bit implementation
           RND(31) xor RND(25) xor RND(22) xor RND(21) xor
           RND(15) xor RND(11) xor RND(10) xor RND(9)  xor RND(7) xor
           RND(6)  xor RND(4)  xor RND(3)  xor RND(1)  xor RND(0)));
    
    A := RND(RND'high downto A'high+1);
    B := RND(A'high downto 0);
    
  end RND_GEN;


  begin

    RND_GEN(A1,B1);
    A <= A1;
    B <= B1;
    wait until CLK'event and CLK = '1';
    
  end process; 

check:process
  begin
   wait until CLK'event and CLK = '1';
   AP <= A;
   BP <= B;
  
   MR <= AP*BP;
  
   assert MR = MUL_OUT report " error";
 
end process;


    UUT : MULT_UNIT 
		port map
      (  CLK => CLK,
         A => A,
			   B => B,
			   MUL_OUT => MUL_OUT
         );


end TB_ARCHITECTURE;



configuration TESTBENCH_FOR_mult of mult_tb is
	for TB_ARCHITECTURE
		for UUT : MULT_UNIT
			use entity work.MULT_UNIT(rtl);
		end for;
	end for;
end TESTBENCH_FOR_mult;

