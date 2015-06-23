----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:51:49 04/11/2012 
-- Design Name: 
-- Module Name:    adder - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder is

Port    
(
           A : in  STD_LOGIC_VECTOR (31 downto 0);
           B : in  STD_LOGIC_VECTOR (31 downto 0);
           ALUop : in  STD_LOGIC_VECTOR (1 downto 0);
			  --ov : out std_logic;
			  S : out  STD_LOGIC_VECTOR (31 downto 0)
);
end adder;

architecture Behavioral of adder is
begin
adder:process(ALUop,A,B) 
variable  add_sub : STD_LOGIC_VECTOR (32 downto 0);
variable  ov_temp : STD_LOGIC;
--variable  A_sn,B_sn,result :  signed(31 downto 0);
--variable  A_i,B_i :integer; 
	 begin
	 	 
	 CASE ALUop IS
	      When  "00"  => 
			          		add_sub := (A(31) & A) + (B(31) & B);
								ov_temp := (A(31) and B(31) and (not add_sub(31))) or 
								((not A(31)) and (not B(31)) and add_sub(31));
								--ov <= ov_temp;
			When  "01"  =>					
								add_sub := ('0' & A) + ('0' & B);
								ov_temp := add_sub(32);
			When  "10"  =>  
			               add_sub := (A(31) & A) - (B(31) & B);
								ov_temp := ((not A(31)) and B(31) and add_sub(31)) or 
								(A(31) and (not B(31)) and (add_sub(31)));
								--ov <= ov_temp;
			When  "11"  =>					
								add_sub := ('0' & A) - ('0' & B);
								ov_temp := add_sub(32);
         When others =>  
			                S <= (others =>'0');
	 end Case;
	     S <= add_sub(31 downto 0);
		       end process adder;
end Behavioral;

