---------------------------------------------------------------------------------------------------
--
-- Title       : rofactor
-- Design      : cfft
-- Author      : ZHAO Ming
-- email	   : sradio@opencores.org
--
---------------------------------------------------------------------------------------------------
--
-- File        : rofactor.vhd
-- Generated   : Thu Oct  3 00:12:16 2002
--
---------------------------------------------------------------------------------------------------
--
-- Description : Generate FFT rotation factor 
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


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;

entity rofactor is
	generic (
		POINT : Natural;
		STAGE : Natural
	);
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 start : in STD_LOGIC; 
		 invert : in std_logic;
--		 step : in STD_LOGIC_VECTOR(2 downto 0);
		 angle : out STD_LOGIC_VECTOR(2*STAGE-1 downto 0)
	     );
end rofactor;


architecture rofactor of rofactor is
signal counter : std_logic_vector( STAGE*2-1 downto 0 ):=( others=>'0' );
signal inc,iinc,phase : std_logic_vector( STAGE*2-1 downto 0 ):=( others=>'0' );
signal mask : std_logic_vector( STAGE*2-1 downto 0 ):=( others=>'0' );									
begin
angle<=phase;

count:process( clk,rst )
begin
	if rst='1' then
		counter<=( others=>'0' );
		inc<=( others=>'0' );
		mask<=( others=>'0' );
	elsif clk'event and clk='1' then
		if start='1' then
			counter<=( others=>'0' );				
			mask<=( others=>'0' );
--			state<="000";
			if invert='1' then
				inc<=CONV_STD_LOGIC_VECTOR(1,STAGE*2);
			else
				inc<=CONV_STD_LOGIC_VECTOR(-1,STAGE*2);
			end if;
		else  
			counter<=unsigned(counter)+1;
			if signed(counter)=-1 then
				inc<=inc(STAGE*2-3 downto 0 )&"00";
				mask<="11"&mask( STAGE*2-1 downto 2 );
--				if state/="100" then
--					state<=state+1;		
--				end if;
			end if;
		end if;
	end if;
end process count;

output : process( clk, rst )
begin
	if rst='1' then
		phase<=( others=>'0' );
		iinc<=( others=>'0' );		
	elsif clk'event and clk='1' then
		if start='1' then
			iinc<=( others=>'0' );
			phase<=( others=>'0' );
		else
			if unsigned(counter( 1 downto 0 ))=3 then
				phase<=( others=>'0' );
			else
				phase<=unsigned(phase)+unsigned(iinc);
			end if;
			if signed(counter or mask)=-1 then
				iinc<=(others=>'0');
			elsif unsigned(counter( 1 downto 0 ))=3 then
				iinc<=unsigned(iinc)+unsigned(inc);
			end if;
		end if;
	end if;
end process output;	
end rofactor;
