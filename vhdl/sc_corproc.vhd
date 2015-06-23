--
-- This file is come from www.opencores.org
--										   
-- It has been modified by ZHAO Ming for 20 bit complex rotation
--

---------------------------------------------------------------------------------------------------
--
-- Title       : sc_corproc
-- Design      : cfft
-- Author      : ZHAO Ming
-- email	   : sradio@opencores.org
--
---------------------------------------------------------------------------------------------------
--
-- File        : sc_corproc.vhd
-- Generated   : Tue Jul 16 10:39:17 2002
--
---------------------------------------------------------------------------------------------------
--
-- Description : complex rotation
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :	0
-- Revision Number : 	1
-- Version         :	1.1.0
-- Date            :	Oct 17 2002
-- Modifier        :   	ZHAO Ming 
-- Desccription    :    Data width configurable	
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :	0
-- Revision Number : 	2
-- Version         :	1.2.0
-- Date            :	Oct 18 2002
-- Modifier        :   	ZHAO Ming 
-- Desccription    :    Data width configurable	
--
---------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity sc_corproc is
	generic (
		WIDTH : Natural;
		STAGE : Natural
	);
	port(
		clk	: in std_logic;
		ena	: in std_logic;
		Xin	: in signed(WIDTH+1 downto 0);
		Yin	: in signed(WIDTH+1 downto 0);
		Ain : in signed(2*STAGE-3 downto 0 );
		
		sin	: out signed(WIDTH+3 downto 0);
		cos	: out signed(WIDTH+3 downto 0)
	);
end entity sc_corproc;

architecture dataflow of sc_corproc is
	constant PipeLength : natural := 2*STAGE+2;
	
	component p2r_cordic is
	generic(
		PIPELINE : integer := 15;
		WIDTH    : integer := 16);
	port(
		clk : in std_logic;
		ena : in std_logic;

		Xi : in signed(WIDTH -1 downto 0);
		Yi : in signed(WIDTH -1 downto 0) := (others => '0');
		Zi : in signed(19 downto 0);
		
		Xo : out signed(WIDTH -1 downto 0);
		Yo : out signed(WIDTH -1 downto 0)
	);
	end component p2r_cordic;
signal phase:signed( 19 downto 0 );
signal Xi,Yi:signed( WIDTH+7 downto 0 );
signal Xo,Yo:signed( WIDTH+7 downto 0 );
signal zeros:signed( 19-STAGE*2 downto 0 );
begin							   
		Xi<= Xin(WIDTH+1)&Xin&"00000";
		Yi<= Yin(WIDTH+1)&Yin&"00000";
		zeros<=(others=>'0');
		phase<="00"&Ain&zeros;
		cos<=Xo(WIDTH+7)&Xo( WIDTH+7 downto 5 ); 
		sin<=Yo(WIDTH+7)&Yo( WIDTH+7 downto 5 );
	
	u1:	p2r_cordic	
			generic map(PIPELINE => PipeLength, WIDTH => WIDTH+8)
			port map(clk => clk, ena => ena, Xi => Xi, Yi=>Yi,Zi => phase, Xo => Xo, Yo => Yo);
end architecture dataflow;
