--registerfile module
--16 registers, read/write port for all registers. 
--8 bit registers

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all; 
use work.tinycpu.all;

entity registerfile is

port(
  WriteEnable: in regwritetype;
  DataIn: in regdatatype;
  Clock: in std_logic;
  DataOut: out regdatatype
);
end registerfile;

architecture Behavioral of registerfile is
  type registerstype is array(0 to 15) of std_logic_vector(7 downto 0);
  signal registers: registerstype;
  --attribute ram_style : string;
  --attribute ram_style of registers: signal is "distributed";
begin
  regs: for I in 0 to 15 generate
    process(WriteEnable(I), DataIn(I), Clock)
    begin
      if rising_edge(Clock) then --I really hope this one falling_edge component doesn't bite me in the ass later
        if(WriteEnable(I) = '1') then
          registers(I) <= DataIn(I);
        end if;
      end if;
    end process;
    DataOut(I) <= registers(I) when WriteEnable(I)='0' else DataIn(I);
     -- DataOut(I) <= registers(I);
  end generate regs;
end Behavioral;