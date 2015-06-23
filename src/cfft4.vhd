---------------------------------------------------------------------------------------------------
--
-- Title       : cfft4
-- Design      : cfft
-- Author      : ZHAO Ming
-- email	: sradio@opencores.org
--
---------------------------------------------------------------------------------------------------
--
-- File        : cfft4.vhd
-- Generated   : Wed Oct  2 15:49:06 2002
--
---------------------------------------------------------------------------------------------------
--
-- Description : 4 point fft
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

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;


entity cfft4 is
	generic (
		WIDTH : Natural
	);
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 start : in STD_LOGIC;
		 invert : in std_logic;
		 I : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		 Q : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		 Iout : out STD_LOGIC_VECTOR(WIDTH+1 downto 0);
		 Qout : out STD_LOGIC_VECTOR(WIDTH+1 downto 0)
	     );
end cfft4;


architecture cfft4 of cfft4 is
type RegAtype is array (3 downto 0) of std_logic_vector(WIDTH-1 downto 0);
type RegBtype is array (3 downto 0) of std_logic_vector(WIDTH downto 0);

signal counter : std_logic_vector( 1 downto 0 ):="00";
signal RegAI,RegAQ : RegAtype;
signal RegBI,RegBQ : RegBtype;
begin


count:process( clk,rst )
begin					
	if rst='1' then
		counter<="00";
	elsif clk'event and clk='1' then
		if start='1' then
			counter<="00";
		else
			counter<=counter+1;
		end if;
	end if;
end process count;


-------------------------------------------------------------------------
--0 rA(0)<=A0 rB(1)<=rA(0)-rA(2) rB(2)<=rA(1)+rA(3)		B3<=rB(1)-rB(3)--
--1 rA(1)<=A1 rB(3)<=(-j)*(rA(1)-rA(3)) 				B0<=rB(0)+rB(2)--
--2 rA(2)<=A2 											B1<=rB(1)+rB(3)--
--3 rA(3)<=A3 rB(0)<=rA(0)+rA(2) 						B2<=rB(0)-rB(2)--
-------------------------------------------------------------------------
calculate:process( clk )
begin
	if clk'event and clk='1' then
		case counter is
--0 rA(0)<=A0 rB(1)<=rA(0)-rA(2) rB(2)<=rA(1)+rA(3)		B3<=rB(1)-rB(3)--
			when "00" =>
				RegAI(0)<=I;
				RegAQ(0)<=Q;	
				RegBI(1)<=SXT(RegAI(0),WIDTH+1)-SXT(RegAI(2),WIDTH+1);
				RegBQ(1)<=SXT(RegAQ(0),WIDTH+1)-SXT(RegAQ(2),WIDTH+1);
				RegBI(2)<=SXT(RegAI(1),WIDTH+1)+SXT(RegAI(3),WIDTH+1);
				RegBQ(2)<=SXT(RegAQ(1),WIDTH+1)+SXT(RegAQ(3),WIDTH+1);
				Iout<=SXT(RegBI(1),WIDTH+2)-SXT(RegBI(3),WIDTH+2);
				Qout<=SXT(RegBQ(1),WIDTH+2)-SXT(RegBQ(3),WIDTH+2);
--1 rA(1)<=A1 rB(3)<=(-j)*(rA(1)-rA(3)) 				B0<=rB(0)+rB(2)--
			when "01" =>
				RegAI(1)<=I;
				RegAQ(1)<=Q;	
				if invert='0' then			 
					-- for fft *(-j)
					RegBI(3)<=SXT(RegAQ(1),WIDTH+1)-SXT(RegAQ(3),WIDTH+1);
					RegBQ(3)<=SXT(RegAI(3),WIDTH+1)-SXT(RegAI(1),WIDTH+1);
				else				
					-- for fft *(j)
					RegBI(3)<=SXT(RegAQ(3),WIDTH+1)-SXT(RegAQ(1),WIDTH+1);
					RegBQ(3)<=SXT(RegAI(1),WIDTH+1)-SXT(RegAI(3),WIDTH+1);
				end if;					 
				Iout<=SXT(RegBI(0),WIDTH+2)+SXT(RegBI(2),WIDTH+2);
				Qout<=SXT(RegBQ(0),WIDTH+2)+SXT(RegBQ(2),WIDTH+2);
--2 rA(2)<=A2 											B1<=rB(1)+rB(3)--
			when "10" =>
				RegAI(2)<=I;
				RegAQ(2)<=Q;	
				Iout<=SXT(RegBI(1),WIDTH+2)+SXT(RegBI(3),WIDTH+2);
				Qout<=SXT(RegBQ(1),WIDTH+2)+SXT(RegBQ(3),WIDTH+2);
--3 rA(3)<=A3 rB(0)<=rA(0)+rA(2) 						B2<=rB(0)-rB(2)--
			when "11" =>		 
				RegAI(3)<=I;
				RegAQ(3)<=Q;		   
				RegBI(0)<=SXT(RegAI(0),WIDTH+1)+SXT(RegAI(2),WIDTH+1);
				RegBQ(0)<=SXT(RegAQ(0),WIDTH+1)+SXT(RegAQ(2),WIDTH+1);
				Iout<=SXT(RegBI(0),WIDTH+2)-SXT(RegBI(2),WIDTH+2);
				Qout<=SXT(RegBQ(0),WIDTH+2)-SXT(RegBQ(2),WIDTH+2);
			when others => null;
		end case;
	end if;
end process calculate;
end cfft4;
