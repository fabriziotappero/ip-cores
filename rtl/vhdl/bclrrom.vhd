--         FILE NAME: bclrrom.vhdl
--       ENTITY NAME: bclr_rom
-- ARCHITECTURE NAME: basic
--          REVISION: A
--
--       DESCRIPTION: 8 byte x 8 bit ROM 
--                    For Bit clear translations
--
-- Written by John Kent for the mc6805 processor
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity bclr_rom is
  port (
    addr   : in   std_logic_vector(2 downto 0);
    data   : out  std_logic_vector(7 downto 0)
  );
end entity bclr_rom;

architecture basic of bclr_rom is
  constant width   : integer := 8;
  constant memsize : integer := 8;

  type bclr_rom_array is array(0 to memsize-1) of std_logic_vector(width-1 downto 0);

  constant bclr_rom_data : bclr_rom_array :=
  ( "11111110",
    "11111101",
    "11111011",
    "11110111",
    "11101111",
    "11011111",
    "10111111",
    "01111111"
	 );
begin
   data <= bclr_rom_data(conv_integer(addr)); 
end architecture basic;


