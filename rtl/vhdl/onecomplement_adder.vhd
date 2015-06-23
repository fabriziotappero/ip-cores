----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:01:09 08/19/2009 
-- Design Name: 
-- Module Name:    onecomplement_adder - Behavioral 
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity onecomplement_adder is
	generic (width: Integer := 18);
    Port ( A : in  STD_LOGIC_VECTOR (0 to width-1);
           B : in  STD_LOGIC_VECTOR (0 to width-1) := (others=>'0');
           CI : in  STD_LOGIC := '0';														-- TODO: verify whether overflow is handled correctly with CI=1
						-- it is (so far) only used for the Divide Step instruction, which does not update OV
           SUM : out  STD_LOGIC_VECTOR (0 to width-1);
           OV : out  STD_LOGIC;
           CSUM : out  STD_LOGIC_VECTOR (0 to width-1));	-- cleaned up sum, will not be -0 (all 1s)
end onecomplement_adder;

architecture Behavioral of onecomplement_adder is
	signal s1, s2: unsigned(0 to width);
	signal c: unsigned(0 to 0);
begin
	c <= "1" when CI='1' else "0";
	s1 <= unsigned('0'&A)+unsigned('0'&B)+c;
	s2 <= s1+1 when s1(0)='1' else s1;		-- add carry back in for one's complement - very expensive, this got us a second adder!
	OV <= '1' when s2(1)/=A(0) and A(0)=B(0) else '0';
	sum <= std_logic_vector(s2(1 to width));
	csum <= std_logic_vector(s2(1 to width)) when s2(1 to width)/=(2**width-1) else (others=>'0');
end Behavioral;
