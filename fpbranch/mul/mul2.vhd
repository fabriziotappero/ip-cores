------------------------------------------------
--! @file mul2.vhd
--! @brief RayTrac Mantissa Multiplier  
--! @author Juli&aacute;n Andr&eacute;s Guar&iacute;n Reyes
--------------------------------------------------


-- RAYTRAC (FP BRANCH)
-- Author Julian Andres Guarin
-- mmp.vhd
-- This file is part of raytrac.
-- 
--     raytrac is free software: you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation, either version 3 of the License, or
--     (at your option) any later version.
-- 
--     raytrac is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
-- 
--     You should have received a copy of the GNU General Public License
--     along with raytrac.  If not, see <http://www.gnu.org/licenses/>


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mul2 is
	port (
		clk 		: in std_logic;
		a32,b32		: in std_logic_vector(31 downto 0);
		p32			: out std_logic_vector(31 downto 0)
		
	);
end mul2;

architecture mul2_arch of mul2 is 

	
	component lpm_mult 
	generic (
		lpm_hint			: string;
		lpm_pipeline		: natural;
		lpm_representation	: string;
		lpm_type			: string;
		lpm_widtha			: natural;
		lpm_widthb			: natural;
		lpm_widthp			: natural
	);
	port (
		dataa	: in std_logic_vector ( lpm_widtha-1 downto 0 );
		datab	: in std_logic_vector ( lpm_widthb-1 downto 0 );
		result	: out std_logic_vector ( lpm_widthp-1 downto 0 )
	);
	end component;	

	--Stage 0 signals
	
	
	
	signal s0sga,s0sgb,s0zrs,s1sgr,s2sgr:std_logic;
	signal s0exa,s0exb,s1exp,s2exp:std_logic_vector(7 downto 0);
	signal s0exp : std_logic_vector(8 downto 0);
	signal s0uma,s0umb:std_logic_vector(22 downto 0);
	signal s0ad,s0bc,s1ad,s1bc:std_logic_vector(23 downto 0);
	signal s0ac:std_logic_vector(35 downto 0);
	
	
	signal s1ac,s1umu:std_logic_vector(35 downto 0);
	signal s2umu:std_logic_vector(24 downto 0);
	
begin

	process(clk)
	begin
	
		if clk'event and clk='1' then
			--! Registro de entrada
			s0sga <= a32(31);
			s0sgb <= b32(31);
			s0exa <= a32(30 downto 23);
			s0exb <= b32(30 downto 23);
			s0uma <= a32(22 downto 0);
			s0umb <= b32(22 downto 0);
			--! Etapa 0 multiplicacion de la mantissa, suma de los exponentes y multiplicaci&oacute;n de los signos.
			s1sgr <= s0sga xor s0sgb;
			s1ad <= s0ad;
			s1bc <= s0bc;
			s1ac <= s0ac;
			s1exp <= s0exp(7 downto 0);
			
			--! Etapa 1 Sumas parciales
			s2umu <= s1umu(35 downto 11);
			s2sgr <= s1sgr;
			s2exp <= s1exp;
			
			--! Etapa 2 entregar el resultado
			p32(31) <= s2sgr;
			p32(30 downto 23) <= s2exp+s2umu(24);
			if s2umu(24) ='1' then
				p32(22 downto 0) <= s2umu(23 downto 1);
			else
				p32(22 downto 0) <= s2umu(22 downto 0);
			end if;
		end if;
	end process;
	
	--! Combinatorial Gremlin Etapa 0 : multiplicacion de la mantissa, suma de los exponentes y multiplicaci&oacute;n de los signos.
	
	--! Multipliers
	mult18x18ac:lpm_mult
	generic	map ("DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9",0,"UNSIGNED","LPM_MULT",18,18,36)
	port 	map (s0zrs&s0uma(22 downto 6),s0zrs&s0umb(22 downto 6),s0ac);
	mult18x6ad:lpm_mult
	generic	map ("DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9",0,"UNSIGNED","LPM_MULT",18,6,24)
	port 	map (s0zrs&s0uma(22 downto 6),s0umb(5 downto 0),s0ad);
	mult18x6bc:lpm_mult
	generic	map ("DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9",0,"UNSIGNED","LPM_MULT",18,6,24)
	port 	map (s0zrs&s0umb(22 downto 6),s0uma(5 downto 0),s0bc);
	
	--! Exponent Addition 
	process (s0sga,s0sgb,s0exa,s0exb)
		variable i8s0exa,i8s0exb: integer range 0 to 255;
	begin
		i8s0exa:=conv_integer(s0exa);
		i8s0exb:=conv_integer(s0exb);
		if i8s0exa = 0 or i8s0exb = 0  then
			s0exp <= (others => '0');
			s0zrs <= '0';
		else 
			s0zrs<='1';
			s0exp <= conv_std_logic_vector(i8s0exb+i8s0exa+129,9);
		end if;
	end process;
	
	--! Etapa 1: Suma parcial de la multiplicacion. Suma del exponente	
	process(s1ac,s1ad,s1bc)
	begin
		s1umu <= s1ac+s1ad(23 downto 6)+s1bc(23 downto 6);
	end process;
	
	
			
	
	
	
end mul2_arch;