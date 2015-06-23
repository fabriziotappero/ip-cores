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
--
--	static const uint16_t IMA_ADPCMStepTable[89] =
--		{
--			7,	  8,	9,	 10,   11,	 12,   13,	 14,
--			16,	 17,   19,	 21,   23,	 25,   28,	 31,
--			34,	 37,   41,	 45,   50,	 55,   60,	 66,
--			73,	 80,   88,	 97,  107,	118,  130,	143,
--		  157,	173,  190,	209,  230,	253,  279,	307,
--		  337,	371,  408,	449,  494,	544,  598,	658,
--		  724,	796,  876,	963, 1060, 1166, 1282, 1411,
--		 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024,
--		 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484,
--		 7132, 7845, 8630, 9493,10442,11487,12635,13899,
--		15289,16818,18500,20350,22385,24623,27086,29794,
--		32767
--		};
--
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;

entity IMA_adpcm_steptable_rom is 
	generic (ROMADDR_W : integer := 7;
				ROMDATA_W : integer := 15);
	port( 
       addr0         : in  STD_LOGIC_VECTOR(ROMADDR_W-1 downto 0); 
       clk           : in  STD_LOGIC; 
       datao0        : out STD_LOGIC_VECTOR(ROMDATA_W-1 downto 0));
end IMA_adpcm_steptable_rom;

architecture RTL of IMA_adpcm_steptable_rom is  
  
  type ROM_TYPE is array (0 to 2**ROMADDR_W-1) 
            of STD_LOGIC_VECTOR(ROMDATA_W-1 downto 0);
  constant rom : ROM_TYPE := 
    (
		"000000000000111",
		"000000000001000",
		"000000000001001",
		"000000000001010",
		"000000000001011",
		"000000000001100",
		"000000000001101",
		"000000000001110",
		"000000000010000",
		"000000000010001",
		"000000000010011",
		"000000000010101",
		"000000000010111",
		"000000000011001",
		"000000000011100",
		"000000000011111",
		"000000000100010",
		"000000000100101",
		"000000000101001",
		"000000000101101",
		"000000000110010",
		"000000000110111",
		"000000000111100",
		"000000001000010",
		"000000001001001",
		"000000001010000",
		"000000001011000",
		"000000001100001",
		"000000001101011",
		"000000001110110",
		"000000010000010",
		"000000010001111",
		"000000010011101",
		"000000010101101",
		"000000010111110",
		"000000011010001",
		"000000011100110",
		"000000011111101",
		"000000100010111",
		"000000100110011",
		"000000101010001",
		"000000101110011",
		"000000110011000",
		"000000111000001",
		"000000111101110",
		"000001000100000",
		"000001001010110",
		"000001010010010",
		"000001011010100",
		"000001100011100",
		"000001101101100",
		"000001111000011",
		"000010000100100",
		"000010010001110",
		"000010100000010",
		"000010110000011",
		"000011000010000",
		"000011010101011",
		"000011101010110",
		"000100000010010",
		"000100011100000",
		"000100111000011",
		"000101010111101",
		"000101111010000",
		"000110011111111",
		"000111001001100",
		"000111110111010",
		"001000101001100",
		"001001100000111",
		"001010011101110",
		"001011100000110",
		"001100101010100",
		"001101111011100",
		"001111010100101",
		"010000110110110",
		"010010100010101",
		"010100011001010",
		"010110011011111",
		"011000101011011",
		"011011001001011",
		"011101110111001",
		"100000110110010",
		"100100001000100",
		"100111101111110",
		"101011101110001",
		"110000000101111",
		"110100111001110",
		"111010001100010",
		"111111111111111",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000",
		"000000000000000"		
     );                
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
