----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:16:44 03/07/2009 
-- Design Name: 
-- Module Name:    flagcross - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 	Module to send a flag (1-cycle high pulse) from one clock domain to another.
--						Intended to work both fast to slow and slow to fast, but fast to slow may give
--						a single pulse for several incoming.
--				Extension: add a register transfer, enabled by flag.
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity flagcross is
  generic ( width : integer := 0 );
  Port ( ClkA : in  STD_LOGIC;
         ClkB : in  STD_LOGIC;
         FastClk : in STD_LOGIC;
         A : in  STD_LOGIC;
         B : out  STD_LOGIC := '0';
         A_reg : in STD_LOGIC_VECTOR(0 to width-1) := (others => '0');
         B_reg : out STD_LOGIC_VECTOR(0 to width-1));
end flagcross;

architecture Behavioral of flagcross is
  signal toggle_a, old_a0, old_a1, seen_a, toggle_b : std_logic := '0';
  signal reg : std_logic_vector(0 to width-1);
begin
  process(ClkA)
  begin
    if rising_edge(ClkA) then
      if A='1' then
        toggle_a <= not toggle_a;
        reg <= A_reg;
      end if;
    end if;
  end process;
  
  process(FastClk)
  begin
    if rising_edge(FastClk) then
      if width>0 then
        old_a0 <= toggle_a;             -- make sure reg can settle
        old_a1 <= old_a0;
      else
        old_a1 <= toggle_a;
      end if;
      if old_a1/=toggle_a then
        seen_a <= not toggle_b;
      end if;
    end if;
  end process;
  
  process(ClkB)
  begin
    if rising_edge(ClkB) then
      if seen_a/=toggle_b then
        B <= '1';
        B_reg <= reg;
        toggle_b <= not toggle_b;
      else
        B <= '0';
      end if;
    end if;
  end process;
end Behavioral;

