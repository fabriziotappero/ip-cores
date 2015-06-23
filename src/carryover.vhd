library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tinycpu.all;

entity carryover is 
  port(
    EnableCarry: in std_logic; --When disabled, SegmentIn goes to SegmentOut
    DataIn: in std_logic_vector(7 downto 0);
    SegmentIn: in std_logic_vector(7 downto 0);
    Addend: in std_logic_vector(7 downto 0); --How much to increase DataIn by (as a signed number). Believe it or not, that's the actual word for what we need.
    DataOut: out std_logic_vector(7 downto 0);
    SegmentOut: out std_logic_vector(7 downto 0);
    Clock: in std_logic
--    Debug: out std_logic_vector(8 downto 0)
   );
end carryover;

architecture Behavioral of carryover is
  signal temp: std_logic_vector(8 downto 0) := "000000000";
  signal temp2: std_logic_vector(7 downto 0);
begin
  --treat as unsigned because it doesn't actually matter for addition and just make carry and borrow correct
  process(DataIn, SegmentIn,Addend, EnableCarry)
    
  begin
    --if rising_edge(Clock) then
      temp <= std_logic_vector(unsigned('0' & DataIn) + unsigned( Addend)); 
  --    if ('1' and ((not Addend(7)) and DataIn(7) and temp(8)))='1' then 
      if (EnableCarry and ((not Addend(7)) and DataIn(7) and not temp(8)))='1' then 
        SegmentOut <= std_logic_vector(unsigned(SegmentIn)+1);
      elsif (EnableCarry and (Addend(7) and not DataIn(7) and temp(8)))='1' then 
        SegmentOut <= std_logic_vector(unsigned(SegmentIn)-1);
      else
        SegmentOut <= SegmentIn;
      end if;
    --end if;
  end process;
  --Debug <= Temp;
  DataOut <= temp(7 downto 0);
end Behavioral;