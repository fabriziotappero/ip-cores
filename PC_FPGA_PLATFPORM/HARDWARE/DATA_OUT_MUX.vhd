----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:25:55 03/21/2011 
-- Design Name: 
-- Module Name:    DATA_OUT_MUX - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DATA_OUT_MUX is
    Port ( status : in  STD_LOGIC_VECTOR (2 downto 0);
           addr : in  STD_LOGIC_VECTOR (2 downto 0);
			  usr_d_on: in  STD_LOGIC;
           data_8 : in  STD_LOGIC_VECTOR (7 downto 0);
           data_16 : in  STD_LOGIC_VECTOR (15 downto 0);
           data_32 : in  STD_LOGIC_VECTOR (31 downto 0);
           data_64 : in  STD_LOGIC_VECTOR (63 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end DATA_OUT_MUX;

architecture Behavioral of DATA_OUT_MUX is

signal sel_char, sel_short, sel_int, sel_float, sel_long, sel_double: std_logic;
signal sel_char_v, sel_short_v, sel_int_v, sel_double_v: std_logic_vector(7 downto 0);
signal char_data, short_data, int_data, double_data: std_logic_vector(7 downto 0);
signal sel_shortA, sel_shortB: std_logic;
signal sel_intA, sel_intB, sel_intC, sel_intD: std_logic;
signal sel_doubleA_v, sel_doubleB_v, sel_doubleC_v, sel_doubleD_v, 
		 sel_doubleE_v, sel_doubleF_v, sel_doubleG_v, sel_doubleH_v: std_logic_vector(7 downto 0);
signal sel_shortA_v, sel_shortB_v: std_logic_vector(7 downto 0);
signal sel_intA_v, sel_intB_v, sel_intC_v, sel_intD_v: std_logic_vector(7 downto 0);
signal sel1, sel2, sel3, sel4, sel5, sel6, sel7, sel8: std_logic;

begin

sel_char 	<= (not status(2)) and (not status(1)) and (    status(0));
sel_short 	<= (not status(2)) and (    status(1)) and (not status(0));
sel_int 		<= (not status(2)) and (    status(1)) and (    status(0));
sel_float 	<= (    status(2)) and (not status(1)) and (not status(0));
sel_long 	<= (    status(2)) and (not status(1)) and (    status(0));
sel_double 	<= (    status(2)) and (    status(1)) and (not status(0));

sel_char_v <= (others=> sel_char);
sel_short_v <= (others=> sel_short);
sel_int_v <= (others=> sel_int or sel_float);
sel_double_v <= (others=> sel_long or sel_double);

char_data <= data_8;


sel1 <= (not addr(2)) and (not addr(1)) and (not addr(0));
sel2 <= (not addr(2)) and (not addr(1)) and (    addr(0));
sel3 <= (not addr(2)) and (    addr(1)) and (not addr(0));
sel4 <= (not addr(2)) and (    addr(1)) and (    addr(0));
sel5 <= (    addr(2)) and (not addr(1)) and (not addr(0));
sel6 <= (    addr(2)) and (not addr(1)) and (    addr(0));
sel7 <= (    addr(2)) and (    addr(1)) and (not addr(0));
sel8 <= (    addr(2)) and (    addr(1)) and (    addr(0));


sel_shortA <= sel1 or sel3 or sel5 or sel7;
sel_shortB <= sel2 or sel4 or sel6 or sel8;

sel_shortA_v <=(others=> sel_shortA);
sel_shortB_v <=(others=> sel_shortB);

short_data <= (sel_shortA_v and data_16(15 downto 8)) or ((sel_shortB_v and data_16(7 downto 0)));



sel_intA <= sel1 or sel5;
sel_intB <= sel2 or sel6;
sel_intC <= sel3 or sel7;
sel_intD <= sel4 or sel8; 

sel_intA_v <= (others=> sel_intA);
sel_intB_v <= (others=> sel_intB);
sel_intC_v <= (others=> sel_intC);
sel_intD_v <= (others=> sel_intD);


int_data <= (sel_intA_v and data_32(31 downto 24)) or
				(sel_intB_v and data_32(23 downto 16)) or
				(sel_intC_v and data_32(15 downto 8)) or
				(sel_intD_v and data_32(7 downto 0)) ;
				
				
sel_doubleA_v <= (others=> sel1);
sel_doubleB_v <= (others=> sel2);
sel_doubleC_v <= (others=> sel3);
sel_doubleD_v <= (others=> sel4);
sel_doubleE_v <= (others=> sel5);
sel_doubleF_v <= (others=> sel6);
sel_doubleG_v <= (others=> sel7);
sel_doubleH_v <= (others=> sel8);

double_data <= (sel_doubleA_v and data_64(63 downto 56)) or
					(sel_doubleB_v and data_64(55 downto 48)) or
					(sel_doubleC_v and data_64(47 downto 40)) or
					(sel_doubleD_v and data_64(39 downto 32)) or
					(sel_doubleE_v and data_64(31 downto 24)) or
					(sel_doubleF_v and data_64(23 downto 16)) or
					(sel_doubleG_v and data_64(15 downto 8)) or
					(sel_doubleH_v and data_64(7 downto 0)) ;
				

data_out <= (sel_char_v and char_data) or
				(sel_short_v and short_data) or
				(sel_int_v and int_data) or
				(sel_double_v and double_data) ;

end Behavioral;

