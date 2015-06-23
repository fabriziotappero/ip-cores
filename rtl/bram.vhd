library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM is
    Generic (
           Addrbreite  : natural := 10;  -- Speicherlänge = 2^Addrbreite
           Wortbreite  : natural := 8
           );
    Port ( clk   : in  STD_LOGIC;
           Write : in  STD_LOGIC;
           Awr   : in  STD_LOGIC_VECTOR (Addrbreite-1 downto 0);
           Ard   : in  STD_LOGIC_VECTOR (Addrbreite-1 downto 0);
           Din   : in  STD_LOGIC_VECTOR (Wortbreite-1 downto 0);
           Dout  : out STD_LOGIC_VECTOR (Wortbreite-1 downto 0)
         );
end RAM;

architecture BlockRAM of RAM is
type speicher is array(0 to (2**Addrbreite)-1) of STD_LOGIC_VECTOR(Wortbreite-1 downto 0);
signal memory : speicher;   
begin
  process begin
    wait until rising_edge(CLK);
    if (Write='1') then
      memory(to_integer(unsigned(Awr))) <= Din;
    end if;
    Dout <= memory(to_integer(unsigned(Ard)));
  end process;
end BlockRAM;