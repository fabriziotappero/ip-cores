---------------------------------------------------------------------------------------------------
--
-- Title       : mulfactor
-- Design      : cfft
-- Author      : ZHAO Ming
-- email	   : sradio@opencores.org
--
---------------------------------------------------------------------------------------------------
--
-- File        : mulfactor.vhd
-- Generated   : Thu Oct  3 00:37:40 2002
--
---------------------------------------------------------------------------------------------------
--
-- Description : 360 degee complex rotation 
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
-- Version         :	1.2.1
-- Date            :	Oct 18 2002
-- Modifier        :   	ZHAO Ming 
-- Desccription    :    Point configurable	
--
---------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity mulfactor is
	generic (
		WIDTH : Natural;
		STAGE : Natural
	);
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 angle : in signed(2*STAGE-1 downto 0);
		 I : in signed(WIDTH+1 downto 0);
		 Q : in signed(WIDTH+1 downto 0);
		 Iout : out signed(WIDTH+3 downto 0);
		 Qout : out signed(WIDTH+3 downto 0)
	     );
end mulfactor;


architecture mulfactor of mulfactor is
signal phase : signed( 2*STAGE-3 downto 0 );
signal Xi,Yi : signed( WIDTH+1 downto 0 );
component sc_corproc
	generic(
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
		cos	: out signed(WIDTH+3 downto 0));
end component;

begin
	
	u1: sc_corproc
	generic map(
		WIDTH=>WIDTH,
		STAGE=>STAGE
	)
	port map (
		clk=>clk,
		ena=>'1',
		Xin=>Xi,
		Yin=>Yi,
		Ain=>phase,
		
		sin=>Qout,
		cos=>Iout
	);

process( clk, rst )
variable temp : std_logic_vector( 1 downto 0 );
begin
	if rst='1' then
		phase<=( others=>'0' );
		Xi<=( others=>'0' );
		Yi<=( others=>'0' );
	elsif clk'event and clk='1' then
		phase<=angle( 2*STAGE-3 downto 0 );
		temp:=std_logic_vector(angle( 2*STAGE-1 downto 2*STAGE-2 ));
		case  temp is
			when "00" =>
			Xi<=I;
			Yi<=Q;
			when "01" =>
			Xi<=0-Q;
			Yi<=I;
			when "10" =>
			Xi<=0-I;
			Yi<=0-Q;
			when "11" =>
			Xi<=Q;
			Yi<=0-I;
			when others=>
			null;
		end case;
	end if;
end process;
	
end mulfactor;
