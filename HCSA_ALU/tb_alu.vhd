-------------------------------------------------------------------------------
--  File: tb_alu.vhd                                                         --
--                                                                           --
--  Copyright (C) Deversys, 2003                                             --
--                                                                           --
--  ALU VHDL model                                                           --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
     
use work.types.all; 


entity alu_tb is
end alu_tb;

architecture behavior of alu_tb is

component ALU_HCSA
port (clk                    : in std_logic;
      a_bus                  : in std_logic_vector(15 downto 0);  
      b_bus                  : in std_logic_vector(15 downto 0);  
      carry_flag             : in std_logic;
      alu_op_next            : in alu_operation;
      current_operand_type   : in operand_type;
      r_bus                  : out std_logic_vector(15 downto 0); -- result out
      carry_out              : out std_logic
     );
end component;



  signal clk : std_logic;
--  signal mul_bit : std_logic;   
	signal alu_op_next : alu_operation;
	signal alu_op_del : alu_operation;
	signal alu_op_del1 : alu_operation;
	signal alu_op_watch : alu_operation;
	signal a_bus : std_logic_vector(15 downto 0);
	signal b_bus : std_logic_vector(15 downto 0);
	signal a_bus_out : std_logic_vector(15 downto 0);
	signal b_bus_out : std_logic_vector(15 downto 0);
  signal carry_flag : std_logic;
	signal carry_flag_out : std_logic;
	signal current_operand_type : operand_type;
	signal current_operand_type_out : operand_type;

	signal a_bus_del : std_logic_vector(15 downto 0);
	signal b_bus_del : std_logic_vector(15 downto 0);
  signal carry_flag_del : std_logic;
	signal current_operand_type_del : operand_type;
	signal a_bus_del1 : std_logic_vector(15 downto 0);
	signal b_bus_del1 : std_logic_vector(15 downto 0);
  signal carry_flag_del1 : std_logic;
	signal current_operand_type_del1 : operand_type;
	signal a_bus_del2 : std_logic_vector(15 downto 0);
	signal b_bus_del2 : std_logic_vector(15 downto 0);
  signal carry_flag_del2 : std_logic;
	signal current_operand_type_del2 : operand_type;

  signal a_bus_test : std_logic_vector(15 downto 0);
	signal b_bus_test : std_logic_vector(15 downto 0);
  signal carry_flag_test : std_logic;
	signal current_operand_type_test : operand_type;
  
  
  
 	signal r_bus : std_logic_vector(15 downto 0); -- output bus
	signal carry_from_alu : std_logic;
 
  
  --   signal MUL_CTL: STD_LOGIC;

  signal clk1: std_logic:='0';


begin

  
	ALU1 : ALU_HCSA
		port map
			(clk => clk,
			a_bus => a_bus_out,
			b_bus => b_bus_out,
			r_bus => r_bus,
      alu_op_next => alu_op_next,
      current_operand_type => current_operand_type_out,
			carry_flag => carry_flag_out,
    	carry_out => carry_from_alu
      ); 
         
         
         
    clk1 <= not clk1 after 20 ns;
    clk <= clk1;

-- register input signals
inputs_register: process(clk)
begin
  if clk'event and clk = '1' then
    a_bus_out <= a_bus;
    b_bus_out <= b_bus;
    carry_flag_out <= carry_flag;
    current_operand_type_out <= current_operand_type;
  end if;
end process;
    
    
    
-- delay outputs for watching
-- it is convinient to watch  a_bus_test and b_bus_test and carry_flag_out
-- (delayed ALU inputs) at the same clock as result of operation
-- (ALU outputs): r_bus and carry_from_alu. 
  
out_delay: process(clk)
begin
  if clk'event and clk = '1' then
    alu_op_del <= alu_op_next;
    alu_op_del1 <= alu_op_del;
    alu_op_watch <= alu_op_del1;

    a_bus_del <= a_bus;
    b_bus_del <= b_bus;
    carry_flag_del <= carry_flag;
    current_operand_type_del <= current_operand_type;

    a_bus_del1 <= a_bus_del;
    b_bus_del1 <= b_bus_del;
    carry_flag_del1 <= carry_flag_del;
    current_operand_type_del1 <= current_operand_type_del;

    a_bus_del2 <= a_bus_del1;
    b_bus_del2 <= b_bus_del1;
    carry_flag_del2 <= carry_flag_del1;
    current_operand_type_del2 <= current_operand_type_del1;
    
    
    a_bus_test <= a_bus_del2;
    b_bus_test <= b_bus_del2;
    carry_flag_test <= carry_flag_del2;
    current_operand_type_test <= current_operand_type_del2;
    
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
    
--    A := RND(RND'high downto RND'high-7) & RND(7 downto 0);
--    B := RND(RND'high - 8 downto 8);
    A := RND(RND'high downto A'high+1);
    B := RND(A'high downto 0);
    
  end RND_GEN;

begin
    RND_GEN(A1,B1);
    a_bus <= A1;
    b_bus <= B1;
    carry_flag <= A1(3) xor B1(7);

    wait until rising_edge(clk);  
end process;


operations_checking: process

begin

    current_operand_type <= Op_Word;
    alu_op_next <= ALU_passA;

   
    wait until rising_edge(clk);-- for 20 ns;

    alu_op_next <= ALU_xor;

    wait until rising_edge(clk);-- for 20 ns;

      alu_op_next <= ALU_and;

    wait until rising_edge(clk);-- for 20 ns;

      alu_op_next <= ALU_or;

    wait until rising_edge(clk);-- for 20 ns;
      
      wait for 1 ns;
      assert (r_bus = (a_bus_test xor b_bus_test)) report "error";
      alu_op_next <= ALU_not;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (a_bus_test and b_bus_test)) report "error";
      alu_op_next <= ALU_inc;
     
    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (a_bus_test or b_bus_test)) report "error";
      alu_op_next <= ALU_neg;
 
    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (not a_bus_test)) report "error";
      alu_op_next <= ALU_add;
    
    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (a_bus_test+1)) report "error";
      alu_op_next <= ALU_adc;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (0 - a_bus_test)) report "error";
      alu_op_next <= ALU_sub;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (a_bus_test + b_bus_test)) report "error";
      alu_op_next <= ALU_sbb;


    wait until rising_edge(clk);-- for 20 ns;
    
      wait for 1 ns;
      assert (r_bus = (a_bus_test + b_bus_test + carry_flag_test)) report "error";
      alu_op_next <= ALU_dec;

    wait until rising_edge(clk);-- for 20 ns;
    
      wait for 1 ns;
      assert (r_bus = (a_bus_test - b_bus_test)) report "error";
      alu_op_next <= ALU_shl;

    wait until rising_edge(clk);-- for 20 ns;
    
      wait for 1 ns;
      assert (r_bus = (a_bus_test - b_bus_test - carry_flag_test)) report "error";
      alu_op_next <= ALU_sal;

    wait until rising_edge(clk);-- for 20 ns;
    
      wait for 1 ns;
      assert (r_bus = (a_bus_test - 1)) report "error";
      alu_op_next <= ALU_rol;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus = (a_bus_test(a_bus_test'high - 1 downto 0) & '0')) and
              (carry_from_alu = a_bus_test(a_bus_test'high))) report "error";
      alu_op_next <= ALU_rcl;

    wait until rising_edge(clk);-- for 20 ns;

     wait for 1 ns;
     assert ((r_bus = (a_bus_test(a_bus_test'high - 1 downto 0) & '0')) and
              (carry_from_alu = a_bus_test(a_bus_test'high))) report "error";
      alu_op_next <= ALU_shr;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus = (a_bus_test(a_bus_test'high - 1 downto 0) & a_bus_test(a_bus_test'high))) and
              (carry_from_alu = a_bus_test(a_bus_test'high))) report "error";
      alu_op_next <= ALU_sar;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus = (a_bus_test(a_bus_test'high - 1 downto 0) & carry_flag_test)) and
              (carry_from_alu = a_bus_test(a_bus_test'high))) report "error";
      alu_op_next <= ALU_ror;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus = ('0' & a_bus_test(a_bus_test'high downto 1) )) and
              (carry_from_alu = a_bus_test(0))) report "error";
      alu_op_next <= ALU_rcr;

    wait until rising_edge(clk);-- for 20 ns;

current_operand_type <= Op_Byte;

    
    
      wait for 1 ns;
      assert ((r_bus = (a_bus_test(a_bus_test'high) & a_bus_test(a_bus_test'high downto 1) )) and
              (carry_from_alu = a_bus_test(0))) report "error";
     alu_op_next <= ALU_xor;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus = (a_bus_test(0) & a_bus_test(a_bus_test'high downto 1) )) and
              (carry_from_alu = a_bus_test(0))) report "error";
      alu_op_next <= ALU_and;
    
    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus = (carry_flag_test & a_bus_test(a_bus_test'high downto 1) )) and
              (carry_from_alu = a_bus_test(0))) report "error";
      alu_op_next <= ALU_or;
    


    wait until rising_edge(clk);-- for 20 ns;
      
      wait for 1 ns;
      assert (r_bus = (a_bus_test xor b_bus_test)) report "error";
      alu_op_next <= ALU_not;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (a_bus_test and b_bus_test)) report "error";
      alu_op_next <= ALU_inc;
     
    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (a_bus_test or b_bus_test)) report "error";
      alu_op_next <= ALU_neg;
 
    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (not a_bus_test)) report "error";
      alu_op_next <= ALU_add;
    
    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (a_bus_test+1)) report "error";
      alu_op_next <= ALU_adc;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (0 - a_bus_test)) report "error";
      alu_op_next <= ALU_sub;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (a_bus_test + b_bus_test)) report "error";
      alu_op_next <= ALU_sbb;


    wait until rising_edge(clk);-- for 20 ns;
    
      wait for 1 ns;
      assert (r_bus = (a_bus_test + b_bus_test + carry_flag_test)) report "error";
      alu_op_next <= ALU_dec;

    wait until rising_edge(clk);-- for 20 ns;
    
      wait for 1 ns;
      assert (r_bus = (a_bus_test - b_bus_test)) report "error";
      alu_op_next <= ALU_shl;

    wait until rising_edge(clk);-- for 20 ns;
    
      wait for 1 ns;
      assert (r_bus = (a_bus_test - b_bus_test - carry_flag_test)) report "error";
      alu_op_next <= ALU_sal;

    wait until rising_edge(clk);-- for 20 ns;
    
      wait for 1 ns;
      assert (r_bus = (a_bus_test - 1)) report "error";
      alu_op_next <= ALU_rol;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus(7 downto 0) = (a_bus_test(6 downto 0) & '0')) and
              (carry_from_alu = a_bus_test(7))) report "error";
      alu_op_next <= ALU_rcl;

    wait until rising_edge(clk);-- for 20 ns;

     wait for 1 ns;
     assert ((r_bus(7 downto 0) = (a_bus_test(6 downto 0) & '0')) and
              (carry_from_alu = a_bus_test(7))) report "error";
      alu_op_next <= ALU_shr;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus(7 downto 0) = (a_bus_test(6 downto 0) & a_bus_test(7))) and
              (carry_from_alu = a_bus_test(7))) report "error";
      alu_op_next <= ALU_sar;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus(7 downto 0) = (a_bus_test(6 downto 0) & carry_flag_test)) and
              (carry_from_alu = a_bus_test(7))) report "error";
      alu_op_next <= ALU_ror;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus(7 downto 0) = ('0' & a_bus_test(7 downto 1) )) and
              (carry_from_alu = a_bus_test(0))) report "error";
      alu_op_next <= ALU_rcr;

    wait until rising_edge(clk);-- for 20 ns;

current_operand_type <= Op_Byte;

    
    
      wait for 1 ns;
      assert ((r_bus(7 downto 0) = (a_bus_test(7) & a_bus_test(7 downto 1) )) and
              (carry_from_alu = a_bus_test(0))) report "error";
     alu_op_next <= ALU_xor;

    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus(7 downto 0) = (a_bus_test(0) & a_bus_test(7 downto 1) )) and
              (carry_from_alu = a_bus_test(0))) report "error";
      alu_op_next <= ALU_and;
    
    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert ((r_bus(7 downto 0) = (carry_flag_test & a_bus_test(7 downto 1) )) and
              (carry_from_alu = a_bus_test(0))) report "error";
      alu_op_next <= ALU_or;
    
    wait until rising_edge(clk);-- for 20 ns;
    
      wait for 1 ns;
      assert (r_bus = (a_bus_test xor b_bus_test)) report "error";
      alu_op_next <= ALU_not;
    
    wait until rising_edge(clk);-- for 20 ns;

      wait for 1 ns;
      assert (r_bus = (a_bus_test and b_bus_test)) report "error";
      alu_op_next <= ALU_add;
    



    alu_op_next <= ALU_passA;
    
--wait;



end process;    

    
    
end behavior;



configuration TESTBENCH_FOR_ALU of alu_tb is
	for behavior
		for ALU1 : ALU_HCSA
			use entity work.ALU_HCSA(RTL);
--			use entity work.ALU_HCSA(SYN_RTL);
		end for;
	end for;
end TESTBENCH_FOR_ALU;


