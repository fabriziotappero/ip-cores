--This component interfaces with the memory controller and fetches the next instruction according to IP and CS
--Each instruction is 16 bits.

--How it works: IROut keeps the instruction that was featched in the "last" clock cycle. 
--What is basically required is that AddressIn must be the value that CS:IP "will be" in the next clock cycle
--This can cause some (in my opinion) odd logic at times, but should not have any problems synthesizing




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tinycpu.all;

entity fetch is 
  port(
    Enable: in std_logic;
    AddressIn: in std_logic_vector(15 downto 0);
    Clock: in std_logic;
    DataIn: in std_logic_vector(15 downto 0); --interface from memory
    IROut: out std_logic_vector(15 downto 0);
    AddressOut: out std_logic_vector(15 downto 0) --interface to memory
   );
end fetch;

architecture Behavioral of fetch is
  signal IR: std_logic_vector(15 downto 0);
begin
  process(Clock, AddressIn, DataIn, Enable)
  begin
    --if(rising_edge(Clock)) then
      if(Enable='1') then
        IR <= DataIn;
        AddressOut <= AddressIn;
      else
        IR <= x"FFFF"; --avoid a latch
        AddressOut <= "ZZZZZZZZZZZZZZZZ";
      end if;
    --end if;
  end process;
  --AddressOut <= AddressIn when Enable='1' else "ZZZZZZZZZZZZZZZZ";
  IROut <= IR;
end Behavioral;