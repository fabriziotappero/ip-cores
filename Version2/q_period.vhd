----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:04:51 11/17/2013 
-- Design Name: 
-- Module Name:    q_period - Behavioral 
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity q_period is
    Port ( period : in  STD_LOGIC_VECTOR (6 downto 0);
           period01 : out  STD_LOGIC_VECTOR (6 downto 0);
           periodA : out  STD_LOGIC_VECTOR (6 downto 0);
           period10 : out  STD_LOGIC_VECTOR (6 downto 0));
end q_period;

architecture Behavioral of q_period is

begin

process(period)

variable varA:STD_LOGIC_VECTOR (6 downto 0);
variable var01:STD_LOGIC_VECTOR (6 downto 0);

begin
	if(period(0)='1')then
		varA:=(6=>'0')&period(6 downto 1)+1;
	else
		varA:=(6=>'0')&period(6 downto 1);
	end if;
	var01:=(6 downto 5=>'0')&period(6 downto 2);
	
	periodA<=varA;
	period01<=var01;
	period10<=varA + var01;

end process;




end Behavioral;

