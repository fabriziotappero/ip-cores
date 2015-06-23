----------------------------------------------------------------------------------
-- Company:       VISENGI S.L. (www.visengi.com)
-- Engineer:      Victor Lopez Lorenzo (victor.lopez (at) visengi (dot) com)
-- 
-- Create Date:    19:34:36 04/November/2008
-- Project Name:   IMA ADPCM Encoder
-- Tool versions:  Xilinx ISE 9.2i
-- Description: 
--
-- Description: This project features a full-hardware sound compressor using the well known algorithm IMA ADPCM.
--              The core acts as a slave WISHBONE device. The output is perfectly compatible with any sound player
--              with the IMA ADPCM codec (included by default in every Windows). Includes a testbench that takes
--              an uncompressed PCM 16 bits Mono WAV file and outputs an IMA ADPCM compressed WAV file.
--              Compression ratio is fixed for IMA-ADPCM, being 4:1.
--
--
-- LICENSE TERMS: GNU GENERAL PUBLIC LICENSE Version 3
--
--     That is you may use it only in NON-COMMERCIAL projects.
--     You are only required to include in the copyrights/about section 
--     that your system contains a "IMA ADPCM Encoder (C) VISENGI S.L. under GPL license"
--     This holds also in the case where you modify the core, as the resulting core
--     would be a derived work.
--     Also, we would like to know if you use this core in a project of yours, just an email will do.
--
--    Please take good note of the disclaimer section of the GPL license, as we don't
--    take any responsability for anything that this core does.
----------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--    WAV HEADER ROM
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;

entity WAV_header_rom is 
	generic (ROMADDR_W : integer := 6;
				ROMDATA_W : integer := 8);
	port( 
       addr0         : in  STD_LOGIC_VECTOR(ROMADDR_W-1 downto 0); 
       clk           : in  STD_LOGIC; 
       datao0        : out STD_LOGIC_VECTOR(ROMDATA_W-1 downto 0));
end WAV_header_rom;

architecture RTL of WAV_header_rom is  
  
  type ROM_TYPE is array (0 to 2**ROMADDR_W-1) 
            of STD_LOGIC_VECTOR(ROMDATA_W-1 downto 0);
  constant rom : ROM_TYPE := 
    (
-- Everything little endian:
-- 52 49 46 46 00 00 00 00 57 41 56 45 66 6D 74 20 14 00 00 00
--  R  I  F  F  x  x  x  x  W  A  V  E  f  m  t     x  x  x  x <-- these last are ok
--x             ^  ^  ^  ^ = change these for (file_size-8 or, simply, bytes that follow)
-- 11 00 <-- wFormatTag = IMA ADPCM
-- 01 00 <-- nChannels = 1 (Mono)
--x40 1F 00 00 <-- nSamplesPerSec = 8000
--xD7 0F 00 00 <-- nAvgBytesPerSec = 4055
--        (505 samples/block -> 8000 samples/sec -> 504/2 + 4 header bytes w. 1 sample = 256 bytes/block -> (8000/505)*256 = 4055 bytes/sec)
--        can be an approximate number and still be reproducible (i.e. nAvgBytesPerSec=nSamplesPerSec/512*256=nSamplesPerSec/2)
-- 00 01 <-- nBlockAlign = 100h = 256 bytes block size
-- 04 00 <-- wBitsPerSample = 4 bits
-- 02 00 <-- cbSize = size of extension = 2 bytes
-- F9 01 <-- wSamplesPerBlock = 505 samples/block
-- 
-- 66 61 63 74 04 00 00 00 00 00 00 00 64 61 74 61 00 00 00 00
--x f  a  c  t  x  x  x  x  x  x  x  x  d  a  t  a  x  x  x  x <-- change these for (file_size-60 or, simply, bytes that follow)
--x                         ^  ^  ^  ^ = # samples per channel in file
         "01010010",
         "01001001",
         "01000110",
         "01000110",
         "11111111",
         "11111111",
         "11111111",
         "01111111",
         "01010111",
         "01000001",
         "01010110",
         "01000101",
         "01100110",
         "01101101",
         "01110100",
         "00100000",
         "00010100",
         "00000000",
         "00000000",
         "00000000",
         "00010001",
         "00000000",
         "00000001",
         "00000000",
         "01000000",
         "00011111",
         "00000000",
         "00000000",
         "11010111",
         "00001111",
         "00000000",
         "00000000",
         "00000000",
         "00000001",
         "00000100",
         "00000000",
         "00000010",
         "00000000",
         "11111001",
         "00000001",
         "01100110",
         "01100001",
         "01100011",
         "01110100",
         "00000100",
         "00000000",
         "00000000",
         "00000000",
         "11111111",
         "11111111",
         "11111111",
         "01111111",
         "01100100",
         "01100001",
         "01110100",
         "01100001",
         "11111111",
         "11111111",
         "11111111",
         "01111111",
         --0 stuffing
         "00000000",
         "00000000",
         "00000000",
         "00000000");                
  signal addr_reg0 : STD_LOGIC_VECTOR(ROMADDR_W-1 downto 0);  
   
begin 

  datao0 <= rom( TO_INTEGER(UNSIGNED(addr_reg0)) );
  
  process(clk)
  begin
   if clk = '1' and clk'event then
     addr_reg0 <= addr0;
   end if;
  end process;  
      
end RTL;
