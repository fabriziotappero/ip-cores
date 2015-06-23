----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Lazaridis Dimitris
-- 
-- Create Date:    00:52:08 06/13/2012 
-- Design Name: 
-- Module Name:    pc - Behavioral 
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
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

use IEEE.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pc is
    Port ( clk : in  STD_LOGIC;
	        rst : in  STD_LOGIC;
			  npc : in std_logic_vector(31 downto 0);
			  PCWrite : in  STD_LOGIC;
			  Err : out STD_LOGIC;
			  N : out std_logic_vector(31 downto 0);
	        address : out std_logic_vector(12 downto 0)
			);
end pc;

architecture Behavioral of pc is
begin

      process(clk,rst,npc,PCWrite)
		variable  addr : std_logic_vector(12 downto 0) := "0000000000000";
		variable fix_addr :std_logic_vector(31 downto 0);
		begin
		if rst = '0' then
         addr := "0000000000000";
			N <= "00000000000000000000000000000000";
		  elsif (RISING_EDGE(clk))then  
              if PCWrite = '1' then
				    if npc(31 downto 13) > "0000000000000000001" then 
				    Err <= '1';  --to soft reset cpu in conjuction with Fsm
					 --elsif program_on = '1' then
					 --addr :=  "0000010001100"; 
					 else
				    addr :=  npc(12 downto 0);
					 end if;
              end if;			 
      end if;
		
	  if rst /= '0' then
			  if (FALLING_EDGE(clk))then
			       if PCWrite /= '1' then
			              fix_addr(12 downto 0) := addr + "100";
			              fix_addr(31 downto 13) := "0000000000000000000";
		                 N(31 downto 0) <= fix_addr;
				    end if;
			  end if;
	 end if; 
			  address <= addr;
		end process;


end Behavioral;

