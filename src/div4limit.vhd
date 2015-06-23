---------------------------------------------------------------------------------------------------
--
-- Title       : div4limit
-- Design      : cfft
-- Author      : ZHAO Ming
-- email	   : sradio@opencores.org
--
---------------------------------------------------------------------------------------------------
--
-- File        : div4limit.vhd
-- Generated   : Tue Jul 16 10:39:17 2002
--
---------------------------------------------------------------------------------------------------
--
-- Description : Div 4 Limit to 12 bit
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :	0
-- Revision Number : 	1
-- Version         :	1
-- Date            :	Oct 17 2002
-- Modifier        :   	ZHAO Ming 
-- Desccription    :    Data width configurable	
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity div4limit is
	generic (
		WIDTH : Natural
	);
	port(
		clk : in std_logic;
		 D : in STD_LOGIC_VECTOR(WIDTH+3 downto 0);
		 Q : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
	     );
end div4limit;

architecture div4limit of div4limit is
begin

process( clk )
variable Temp_D:std_logic_vector( WIDTH+1 downto 0 );
begin		
	if clk'event and clk='1' then
		Temp_D:=D( WIDTH+3 downto 2 )+D(1);
		if Temp_D(WIDTH+1)='1' and Temp_D(WIDTH downto WIDTH-1)/="11" then
			Temp_D(WIDTH+1 downto WIDTH-1):="111";
			Temp_D(WIDTH-2 downto 1):=( others=>'0' );
			Temp_D(0):='1';
		elsif Temp_D(WIDTH+1)='0' and Temp_D(WIDTH downto WIDTH-1)/="00" then
			Temp_D(WIDTH+1 downto WIDTH-1):="000";
			Temp_D(WIDTH-2 downto 0):=( others=>'1' );
		end if;
		Q<=Temp_D(WIDTH-1 downto 0 );
	end if;
end process;
	
end div4limit;
