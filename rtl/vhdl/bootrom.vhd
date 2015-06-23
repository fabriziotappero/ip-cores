--         FILE NAME: bootrom.vhdl
--       ENTITY NAME: boot_rom
-- ARCHITECTURE NAME: behave
--          REVISION: A
--
--       DESCRIPTION: 64 byte x 8 bit ROM to down a Monitor
--                    program on reset
--
--Written by John Kent for the micro8 processor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
-- use work.memory.all;

entity boot_rom is
  port (
    addr   : in   std_logic_vector(5 downto 0);
    data   : out  std_logic_vector(7 downto 0)
  );
end entity boot_rom;

architecture basic of boot_rom is
  constant width   : integer := 8;
  constant memsize : integer := 64;

  type rom_array is array(0 to memsize-1) of std_logic_vector(width-1 downto 0);

  constant rom_data : rom_array :=
  ( "10011100",				             -- $FFC0 - 9C       RESET RSP
    "10100110", "00010001",             -- $FFC1 - A6 11          LDA #$11
	 "10110111", "00010000",             -- $FFC3 - B7 10          STA ACIACS
    "10101110", "00000000",             -- $FFC5 - AE 00          LDX #$00
	 "11010110", "11111111", "11100010", -- $FFC7 - D6 FFE2  LOOP0 LDA $FFE0,X
	 "00100111", "00001000",             -- $FFCA - 27 08          BEQ INPUT
	 "00000011", "00010000", "11111101", -- $FFCC - 03 10 FD LOOP1 BRCLR 1,$10,LOOP1
	 "10110111", "00010001",             -- $FFCF - B7 11          STA ACIADA
	 "01011100",                         -- $FFD1 - 5C             INCX
	 "00100000", "11110011",             -- $FFD3 - 20 F3          BRA LOOP0
	 "00000001", "00010000", "11111101", -- $FFD5 - 01 10 FD INPUT BRCLR 0,$10,INPUT
	 "10110110", "00010001",             -- $FFD7 - B6 11          LDA ACIADA
	 "11001101", "11111111", "11011111", -- $FFD9 - CD FFDF        JSR SUBR
	 "11001100", "11111111", "11000000", -- $FFDC - CC FFC0        JMP RESET
	 "10110111", "00010001",             -- $FFDF - B7 11    SUBR  STA ACIADA
	 "10000001",                         -- $FFE1 - 81             RTS
    "01001000", "01100101", "01101100", -- $FFE2 - 48 65 6c MSG   FCC "Hel"
	 "01101100", "01101111", "00100000", -- $FFE5 - 6c 6f 20       FCC "lo "
	 "01010111", "01101111", "01110010", -- $FFE8 - 57 6f 72       FCC "Wor"
    "01101100", "01100100",             -- $FFEB - 6c 64          FCC "ld"
    "00001010", "00001101", "00000000", -- $FFED - 0a 0d 00       FCB LF,CR,NULL
	 "11111111", "11000000",             -- $FFF0 - FF C0          FDB RESET           
	 "11111111", "11000000",             -- $FFF2 - FF C0          FDB RESET           
	 "11111111", "11000000",             -- $FFF4 - FF C0          FDB RESET           
	 "11111111", "11000000",             -- $FFF6 - FF C0          FDB RESET           
	 "11111111", "11000000",             -- $FFF8 - FF C0          FDB RESET           
	 "11111111", "11000000",             -- $FFFA - FF C0          FDB RESET           
	 "11111111", "11000000",             -- $FFFC - FF C0          FDB RESET           
	 "11111111", "11000000"              -- $FFFE - FF C0          FDB RESET           
);
begin
   data <= rom_data(conv_integer(addr)); 
end architecture basic;


