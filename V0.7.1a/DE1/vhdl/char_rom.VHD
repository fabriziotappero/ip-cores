-------------------------------------------------------------------------------------------------
-- This design is part of:
-- Z80SoC (Z80 System on Chip)
-- Ronivon Candido Costa
-- ronivon.costa@gmail.com
--
-- 2010 - 11 - 22
--

library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY Char_ROM IS
	PORT(	clock						: IN 	STD_LOGIC;
			character_address			: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
			font_row, font_col			: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
			rom_mux_output	: OUT	STD_LOGIC);
END Char_ROM;

ARCHITECTURE a OF Char_ROM IS
	SIGNAL	rom_data: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL	rom_address: STD_LOGIC_VECTOR(10 DOWNTO 0);
BEGIN
-- Small 8 by 8 Character Generator ROM for Video Display
-- Each character is 8 8-bits words of pixel data
 char_gen_rom: lpm_rom
      GENERIC MAP ( lpm_widthad => 11,
        lpm_numwords => 2048,
        lpm_outdata => "UNREGISTERED",
        lpm_address_control => "REGISTERED",
-- Reads in mif file for character generator font data 
         lpm_file => "..\ROM\CHARROM.MIF",
         lpm_width => 8)
      PORT MAP ( inclock => clock, address => rom_address, q => rom_data);

rom_address <= character_address & font_row;
-- Mux to pick off correct rom data bit from 8-bit word
-- for on screen character generation
rom_mux_output <= rom_data ( (CONV_INTEGER(NOT font_col(2 downto 0))));

END a;
