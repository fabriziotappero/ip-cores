-------------------------------------------------------------------------------
--  File: tb_adder.vhd                                                       --
--                                                                           --
-- Copyright (C) Deversys, 2003                                              --
--                                                                           --
-- testbench for hirerachical carry save adder                               --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
-------------------------------------------------------------------------------
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
     

entity adder_tb is
end adder_tb;

architecture behavior of adder_tb is

component adder_HCSA
port (CLK                : in std_logic;
      A_BUS              : in std_logic_vector(15 downto 0);  
      B_BUS              : in std_logic_vector(15 downto 0);  
      SUM_OUT            : out std_logic_vector(15 downto 0)
     );
end component;



  signal CLK : std_logic;
	signal A_BUS : std_logic_vector(15 downto 0);
	signal B_BUS : std_logic_vector(15 downto 0);
	signal A_BUS_out : std_logic_vector(15 downto 0);
	signal B_BUS_out : std_logic_vector(15 downto 0);

	signal A_BUS_del : std_logic_vector(15 downto 0);
	signal B_BUS_del : std_logic_vector(15 downto 0);
  signal carry_flag_del : std_logic;
	signal A_BUS_del1 : std_logic_vector(15 downto 0);
	signal B_BUS_del1 : std_logic_vector(15 downto 0);
  signal carry_flag_del1 : std_logic;
	signal A_BUS_del2 : std_logic_vector(15 downto 0);
	signal B_BUS_del2 : std_logic_vector(15 downto 0);
  signal carry_flag_del2 : std_logic;

  signal A_BUS_test : std_logic_vector(15 downto 0);
	signal B_BUS_test : std_logic_vector(15 downto 0);
  signal carry_flag_test : std_logic;
  
  
  
 	signal R_BUS : std_logic_vector(15 downto 0); -- output bus
	signal carry_from_ALU : std_logic;
 
  
  --   signal MUL_CTL: STD_LOGIC;

  signal RST: std_logic;
  signal CLK1: std_logic:='0';


begin

         
	adder1 : adder_HCSA
		port map
			(CLK => CLK,
			 A_BUS => A_BUS,
			 B_BUS => B_BUS,
			 SUM_OUT => R_BUS
      ); 
         
         
         
    CLK1 <= not CLK1 after 20 ns;
    CLK <= CLK1;
    

out_delay: process(CLK)
begin
  if CLK'event and CLK = '1' then
    A_BUS_del <= A_BUS;
    B_BUS_del <= B_BUS;

    A_BUS_test <= A_BUS_del;
    B_BUS_test <= B_BUS_del;
    
    
  end if;
end process;
    
    
    
data_gen: process
  variable    A1 : std_logic_vector(15 downto 0) := X"1111";
  variable    B1 : std_logic_vector(15 downto 0) := X"77EE";
    

  procedure RND_GEN( variable A, B: inout std_logic_vector) is
  -- for random values generation the following polinom is used:
  -- x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x^1+1 
  variable RND: std_logic_vector(31 downto 0); 
  begin
    RND := A & B;
    
    RND := RND(RND'high - 1 downto 0) & (not(
    
           RND(31) xor RND(25) xor RND(22) xor RND(21) xor
           RND(15) xor RND(11) xor RND(10) xor RND(9)  xor RND(7) xor
           RND(6)  xor RND(4)  xor RND(3)  xor RND(1)  xor RND(0)));
    
    A := RND(RND'high downto A'high+1);
    B := RND(A'high downto 0);
    
  end RND_GEN;

begin

    RND_GEN(A1,B1);
    A_BUS <= A1;
    B_BUS <= B1;
    wait until rising_edge(CLK);-- for 20 ns;

      wait for 1 ns;
      assert (R_BUS = (A_BUS_test + B_BUS_test)) report "error";

    
--wait;
end process;    
    
end behavior;



configuration TESTBENCH_FOR_ADDER of adder_tb is
	for behavior
		for adder1 : adder_HCSA
			use entity work.adder_HCSA(RTL);
--			use entity work.adder_HCSA(SYN_RTL);
		end for;
	end for;
end TESTBENCH_FOR_ADDER;


