library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all; 

Library XilinxCoreLib;
 
ENTITY charrom IS
	port (
	clk		: IN 	STD_LOGIC;
			character_address			: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
			font_row, font_col			: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
			rom_mux_output	: OUT	STD_LOGIC);
END charrom;

ARCHITECTURE charrom_a OF charrom IS
	SIGNAL	dout: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL	addr: STD_LOGIC_VECTOR(10 DOWNTO 0);

component char
        port (
        clka: IN std_logic;
        addra: IN std_logic_VECTOR(10 downto 0);
        douta: OUT std_logic_VECTOR(7 downto 0));
end component;

BEGIN
addr <= character_address & font_row;
-- Mux to pick off correct rom data bit from 8-bit word
-- for on screen character generation
rom_mux_output <= dout ( (CONV_INTEGER(NOT font_col(2 downto 0))));

char_inst : char
		port map (
			addra => addr,
			clka => clk,
			douta => dout);

END charrom_a;

