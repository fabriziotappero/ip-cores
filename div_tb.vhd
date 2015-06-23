-------------------------------------------------------------------------------
--  File: div_unit.vhd                                                       --
--                                                                           --
--  Copyright (C) Deversys, 2004                                             --
--                                                                           --
--  testbench for one-clock division algorithm                               --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--          e-mails: vladvas@deversys.com; vladvas@verilog.ru;               --
--                                                                           --
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------
--
-- REMARK1: Error reports during first 3 cycles are not valuable!!!
-- REMARK2: For overflow and error detections check uncomment appropriate line




package definitions is
  constant data_width : integer:= 16;
end package;


library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

library std;
use STD.textio.all;

library work;
use definitions.all;


entity div_tb is
end div_tb;

architecture TB_ARCHITECTURE of div_tb is

  component DIV_UNIT
	port (
		CLK: in std_logic;
		DIVIDEND: in STD_LOGIC_VECTOR (data_width*2 - 1 downto 0);
		DIVISOR: in STD_LOGIC_VECTOR (data_width - 1 downto 0);
		DIV_RESULT: out STD_LOGIC_VECTOR (data_width*2 downto 0)
	);
end component;

	signal A : std_logic_vector(data_width -1 downto 0):= (others => '0');
	signal B : std_logic_vector(data_width -1 downto 0):= (others => '0');
	signal REST : std_logic_vector(data_width -1 downto 0);
	signal MUL_REZ, MUL_REZ_del, dividend : std_logic_vector(data_width * 2 - 1 downto 0);

  signal DIV_OUT : std_logic_vector(32 downto 0); --result of division

	signal A_DEL1 : std_logic_vector(data_width -1 downto 0):= (others => '0');
	signal B_DEL1 : std_logic_vector(data_width -1 downto 0):= (others => '0');
	signal R_DEL1 : std_logic_vector(data_width -1 downto 0):= (others => '0');
	signal A_DEL2 : std_logic_vector(data_width -1 downto 0):= (others => '0');
	signal B_DEL2 : std_logic_vector(data_width -1 downto 0):= (others => '0');
	signal R_DEL2 : std_logic_vector(data_width -1 downto 0):= (others => '0');
	signal quotient : std_logic_vector(data_width -1 downto 0):= (others => '0');
	signal divisor : std_logic_vector(data_width -1 downto 0):= (others => '0');
	signal remainder : std_logic_vector(data_width -1 downto 0):= (others => '0');

  signal CLK1: std_logic := '0';
  signal CLK: std_logic;
  
  
  
begin

   CLK1 <= not CLK1 after 20 ns;
   CLK <= CLK1;
   
process
variable    A1 : std_logic_vector(data_width -1 downto 0) := (others => '0');
variable    B1 : std_logic_vector(data_width -1 downto 0) := (others => '0');
    

procedure RND_GEN( variable A, B: inout std_logic_vector) is
--x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x^1+1 
variable C: std_logic_vector(data_width * 2 -1 downto 0); 
begin
  C := A & B;
  C := C(C'high-1 downto 0) & (not 
       (C(31) xor C(25) xor C(22) xor C(21) xor C(15) xor C(11) xor C(10) 
              xor C(9) xor C(7) xor C(6) xor C(4) xor C(3) xor C(1) xor C(0)));
  A := C(C'high downto A'high+1);
  B := C(A'high downto 0);
end RND_GEN;


begin

  RND_GEN(A1,B1);
  
    A <= A1;
    B <= B1; 
    
    
    REST <= (B1 - 1) and A1;  -- pseudo-random value less than B1
   
    wait until CLK'event and CLK = '1';
    
end process; 

check:process

  variable out_line: line;
  variable report_out: string (1 to 80);


begin
 wait until CLK'event and CLK = '1';
 A_DEL1 <= A;
 B_DEL1 <= B;
 R_DEL1 <= REST;
 
 
 A_DEL2 <= A_DEL1;
 B_DEL2 <= B_DEL1;
 R_DEL2 <= R_DEL1;
 
 quotient <= A_DEL2;
 divisor <= B_DEL2;
 remainder <= R_DEL2;

 
 MUL_REZ <= A * B + REST; --for unsigned 
-- MUL_REZ(MUL_REZ'high) <= '1';   --overflow and error detections check 


--MUL_REZ <=  signed(A) * signed(B) + REST; --for signed division   

 
 MUL_REZ_del <= MUL_REZ;   
 dividend <= MUL_REZ_del;   



 if (not (quotient = DIV_OUT(DIV_OUT'high - 1 downto data_width) and 
          remainder = DIV_OUT(data_width - 1 downto 0))) or 
                                            DIV_OUT(DIV_OUT'high) = '1' then 
   if DIV_OUT(DIV_OUT'high) = '0' then
       
     write(out_line, "dividend = ", left, 10);  
     hwrite(out_line, dividend, right, 8);
     write(out_line, ", divisor = ", left, 9);  
     hwrite(out_line, divisor, right, 4);
     write(out_line, ", exp_result = ", left, 11);  
     hwrite(out_line, quotient, right, 4);
     write(out_line, ":", right, 1);  
     hwrite(out_line, remainder, right, 4);
     write(out_line, ", result = ", left, 11);  
     hwrite(out_line, DIV_OUT(DIV_OUT'high - 1 downto data_width), right, 4);
     write(out_line, ":", right, 1);  
     hwrite(out_line, DIV_OUT(data_width - 1 downto 0), right, 4);
     write(out_line, " ", right, 1);
     
     read (out_line, report_out);
   else
     write(out_line, "overflow, ", left, 10);  
     write(out_line, "dividend = ", left, 10);  
     hwrite(out_line, dividend, right, 8);
     write(out_line, ", divisor = ", left, 9);  
     hwrite(out_line, divisor, right, 4);
     write(out_line, " ", right, 35);

     read (out_line, report_out);
   end if;
   assert false report report_out;

 end if;
 
 
end process;

   
    UUT : DIV_UNIT
		port map
      (  CLK => CLK,
         DIVIDEND => MUL_REZ,
			   DIVISOR => B_DEL1,
			   DIV_RESULT => DIV_OUT
         );


end TB_ARCHITECTURE;





configuration TESTBENCH_FOR_DIV of div_tb is
	for TB_ARCHITECTURE
		for UUT : DIV_UNIT
			use entity work.DIV_UNIT(rtl);
		end for;
	end for;
end TESTBENCH_FOR_DIV;

