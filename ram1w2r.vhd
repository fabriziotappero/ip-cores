----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:00:30 11/27/2008 
-- Design Name: 
-- Module Name:    ram1w2r - Behavioral 
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

entity ram1w2r is
    Port ( 
			  addrefa:in  STD_LOGIC_VECTOR (9 downto 0);
			  addrefb:in  STD_LOGIC_VECTOR (9 downto 0);
			  doutrefa:out  STD_LOGIC_VECTOR (9 downto 0);
			  doutrefb:out  STD_LOGIC_VECTOR (9 downto 0);
			  addrW : in  STD_LOGIC_VECTOR (9 downto 0);
           din : in  STD_LOGIC_VECTOR (9 downto 0);
           we : in  STD_LOGIC;
           addrRA : in  STD_LOGIC_VECTOR (9 downto 0);
           doutA : out  STD_LOGIC_VECTOR (9 downto 0);
           addrRB : in  STD_LOGIC_VECTOR (9 downto 0);
           doutB : out  STD_LOGIC_VECTOR (9 downto 0);
           clk : in  STD_LOGIC);
end ram1w2r;

architecture Behavioral of ram1w2r is

type ram_type is array(1023 downto 0) of std_logic_vector(9 downto 0);
signal ram_array : ram_type:=(others=>(others=>'0'));

begin
doutrefa <= ram_array(conv_integer(addrefa));--for reading the memory asynchronously
doutrefb <= ram_array(conv_integer(addrefb));
	process(clk)
	begin
		if clk'event and clk ='1' then
			if we='1' then
				ram_array(conv_integer(addrW)) <= din;
			end if;
			doutA <= ram_array(conv_integer(addrRA));
			doutB <= ram_array(conv_integer(addrRB));
		end if;
		
	end process;


end Behavioral;

