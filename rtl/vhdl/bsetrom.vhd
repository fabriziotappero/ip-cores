--         FILE NAME: bsetrom.vhd
--       ENTITY NAME: bset_rom
-- ARCHITECTURE NAME: basic
--          REVISION: A
--
--       DESCRIPTION: 8 byte x 8 bit ROM 
--                    For bit set translations
--
-- Written by John Kent for the mc6805 processor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity bset_rom is
  port (
    addr   : in   std_logic_vector(2 downto 0);
    data   : out  std_logic_vector(7 downto 0)
  );
end entity bset_rom;

architecture basic of bset_rom is
  constant width   : integer := 8;
  constant memsize : integer := 8;

  type bset_rom_array is array(0 to memsize-1) of std_logic_vector(width-1 downto 0);

  constant bset_rom_data : bset_rom_array :=
  ( "00000001",
    "00000010",
    "00000100",
    "00001000",
    "00010000",
    "00100000",
    "01000000",
    "10000000"
	 );
begin
   data <= bset_rom_data(conv_integer(addr)); 
end architecture basic;


