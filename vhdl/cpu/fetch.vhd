----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:18:39 02/11/2007 
-- Design Name: 
-- Module Name:    fetch - Behavioral 
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
use ieee.numeric_std.all;
use work.types.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fetch is
    Port ( clk : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  pc : out slv_32;
			  brzero: in std_logic_vector(2 downto 0);            
			  newpc: in slv_32;           
			  testv: in slv_32;
			  result: in slv_32;
			  fw: in std_logic;
			  fw2_pc: in std_logic; 
			  instr : out slv_16;
			  	
				paddr: out std_logic_VECTOR(9 downto 0);
				pdin: in slv_16
			);
end fetch;

architecture Behavioral of fetch is

--signal nextpc: slv_32;
signal curpc: unsigned(31 downto 0);
signal cpc: slv_32;
signal r: unsigned(31 downto 0);
signal newjump: std_logic_vector(31 downto 0); -- address of jump

signal finstr: slv_16;
signal first: std_logic;

begin

	r <= unsigned(testv) when fw = '0' else unsigned(result); -- fw is forward of rb (reg1)
	newjump <= newpc when fw2_pc = '0' else result; -- fw2 is forward of ra (reg2)
	
--	r <= unsigned(testv);

	cpc <= 	newpc		when	((r /= 0) and unsigned(brzero) = 2) or
									((r = 0)  and unsigned(brzero) = 3) else
				newjump	when	(unsigned(brzero) = 1) else
				std_logic_vector(curpc);

	paddr <= cpc(9 downto 0);

	
	process (clk, reset)
	begin
		if (reset='0') then 
		   curpc <= (others => '0'); 
			pc <= (others => '0');
			first <= '1';
      elsif rising_edge(clk) then
			if first = '1' then
				first <= '0';
			end if;
			curpc(9 downto 0) <= unsigned(cpc(9 downto 0)) + 1;
			curpc(31 downto 10) <= curpc(31 downto 10);
			pc <= cpc;
		end if;
	end process;

	finstr <= pdin;
	instr <= "0110000000000000" when first = '1' else finstr;

end Behavioral;

