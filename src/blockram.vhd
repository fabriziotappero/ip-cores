--RAM module
--4096*8 bit file
--simultaneous write/read support
--16 bit or 8 bit data bus
--16 bit address bus
--On Reset, will load a "default" RAM image

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all; 

entity blockram is
  port(
    Address: in std_logic_vector(7 downto 0); --memory address
    WriteEnable: in std_logic_vector(1 downto 0); --write 1 byte at a time option
    Enable: in std_logic; 
    Clock: in std_logic;
    DataIn: in std_logic_vector(15 downto 0);
    DataOut: out std_logic_vector(15 downto 0)
  );
end blockram;

architecture Behavioral of blockram is
    type ram_type is array (255 downto 0) of std_logic_vector (7 downto 0);
    signal RAM0: ram_type; --Spartan 3Es don't natively support byte-wide write enables, so we'll just emulate it with 2 banks of RAM
    signal RAM1: ram_type;
    signal di0, di1: std_logic_vector(7 downto 0);
    signal do : std_logic_vector(15 downto 0);
begin
  di0 <= DataIn(7 downto 0) when WriteEnable(0)='1' else do(7 downto 0);
    di1 <= DataIn(15 downto 8) when WriteEnable(1)='1' else do(15 downto 8);
  process (Clock)
  begin
    if rising_edge(Clock) then
      if Enable = '1' then
        if WriteEnable(0)='1' then
          RAM0(conv_integer(Address)) <= di0;
        else
          do(7 downto 0) <= RAM0(conv_integer(Address)) ;
        end if;
        if WriteEnable(1)='1' then
          RAM1(conv_integer(Address)) <= di1;
        else
          do(15 downto 8) <= RAM1(conv_integer(Address));
        end if;
      end if;
    end if;
  end process;
  DataOut <= do;
end Behavioral;