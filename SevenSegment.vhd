----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:27:13 11/30/2010 
-- Design Name: 
-- Module Name:    SevenSegment - Behavioral 
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
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SevenSegment is
    Port ( Clk : in  STD_LOGIC;
           Enables : out  STD_LOGIC_VECTOR (3 downto 0);
           Segments : out  STD_LOGIC_VECTOR (6 downto 0);
           data : in  STD_LOGIC_VECTOR (15 downto 0));
end SevenSegment;

architecture Behavioral of SevenSegment is

signal Counter,nCounter : STD_LOGIC_VECTOR (16 downto 0);
signal Chosen : STD_LOGIC_VECTOR (3 downto 0);

begin

Chosen <= data(15  downto  12) when Counter(16 downto 15)="00" else
			 data(11  downto   8) when Counter(16 downto 15)="01" else
			 data(7   downto   4) when Counter(16 downto 15)="10" else
			 data(3   downto   0);
Enables <= "1110" when Counter(16 downto 15)="00" else
			  "1101" when Counter(16 downto 15)="01" else
			  "1011" when Counter(16 downto 15)="10" else
			  "0111";
with Chosen Select
Segments <= "1111001" when "0001",   --1
				"0100100" when "0010",   --2
				"0110000" when "0011",   --3
				"0011001" when "0100",   --4
				"0010010" when "0101",   --5
				"0000010" when "0110",   --6
				"1111000" when "0111",   --7
				"0000000" when "1000",   --8
				"0010000" when "1001",   --9
				"0001000" when "1010",   --A
				"0000011" when "1011",   --b
				"1000110" when "1100",   --C
				"0100001" when "1101",   --d
				"0000110" when "1110",   --E
				"0001110" when "1111",   --F
				"1000000" when others;   --0
nCounter <= Counter+1;

process (Clk) begin
	if (rising_edge(Clk)) then
		Counter <= nCounter;
	end if;
end process;

end Behavioral;