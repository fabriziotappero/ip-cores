------------------------------------------------
--! @file ema32x2.vhd
--! @brief RayTrac Floating Point Adder  
--! @author Juli&aacute;n Andr&eacute;s Guar&iacute;n Reyes
--------------------------------------------------


-- RAYTRAC (FP BRANCH)
-- Author Julian Andres Guarin
-- ema32x2.vhd
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


--! Esta entidad recibe dos n&uacutemeros en formato punto flotante IEEE 754, de precision simple y devuelve las mantissas signadas y corridas, y el exponente correspondiente al resultado antes de normalizarlo al formato float. 
--!\nLas 2 mantissas y el exponente entran despues a la entidad add2 que suma las mantissas y entrega el resultado en formato IEEE 754.
entity ema32x2 is 
	port (
		clk,dpc		: in std_logic;
		a32,b32		: in std_logic_vector (31 downto 0);
		res32		: out std_logic_vector(31 downto 0)
	);
end ema32x2;

architecture ema32x2_arch of ema32x2 is
	
	component shftr
	port (
		dir		: in std_logic;
		places	: in std_logic_vector (3 downto 0);
		data24	: in std_logic_vector (23 downto 0);
		data40	: out std_logic_vector (39 downto 0)
	);
	end component;
		
	signal s2slr										: std_logic_vector(1 downto 0); 
	signal s3lshift,s4lshift							: std_logic_vector(4 downto 0);
	signal s0sdelta,s0udelta,s0udeltaa,s0udeltab,s2exp,s3exp,s4exp		: std_logic_vector(7 downto 0);
	signal s4slab										: std_logic_vector(15 downto 0);
	signal s2slab										: std_logic_vector(16 downto 0);
	signal b1s,s4nrmP									: std_logic_vector(22 downto 0); -- Inversor de la mantissa
	signal s0a,s0b,s1a,s1b								: std_logic_vector(31 downto 0); -- Float 32 bit 
	signal s1sma,s2sma,s2smb,s3sma,s3smb,s3ures,s4ures	: std_logic_vector(24 downto 0); -- Signed mantissas
	signal s3res										: std_logic_vector(25 downto 0); -- Signed mantissa result
	signal s1pS,s1pH,s1pL,s4nrmL,s4nrmH,s4nrmS			: std_logic_vector(17 downto 0); -- Shifert Product
	signal s0zeroa,s0zerob,s1zeroa,s1zerob,s1z,s4sgr			: std_logic; 
	signal s2sma,s2smb									: std_logic_vector (56 downto 0);
	
begin

	process (clk)
	begin
		if clk'event and clk='1' then 
		
			--!Registro de entrada
			s0a <= a32;
			
			s0b(31) <= dpc xor b32(31);	--! Importante: Integrar el signo en el operando B
			s0b(30 downto 0) <= b32(30 downto 0);
			s0b(22 downto 0) <= b32(22 downto 0);
			
			--!Etapa 0,Calcular la manera en que se llevara a cabo la desnormalizacion
			s1signa 	<= s0a(31);
			s1signb 	<= s0b(31); 
			s1dira		<= s0sdelta(7);
		 	s1uma		<= s0a(22 downto 0);
		 	s1umb		<= s0b(22 downto 0);
			if sa(30 downto 23) = "00000000" or sb(30 downto 23) = "00000000" then
				s1expb	<= s0b(30 downto 23) or s0a(30 downto 23);
				s1udeltaa	<= "0000";
				s1udeltab	<= "0000";
				s1zero		<= '1';
			else
				s1expb	<= s0b(30 downto 23);	
				s1udeltaa	<= s0udeltaa(3 downto 0);
				s1udeltab	<= s1udeltab(3 downto 0);
				s1zero  <= '0'; 
			end if;
					 	 
		 			
			--! Etapa 1: Denormalizaci&oacute;n de las mantissas.  
			--! A
			s2exp <= s1a(30 downto 23);
			s2sma <= s1sma;
			
			--! B
			for i in 23 downto 15 loop
				s2smb(i)	<= s1pL(23-i) xor s1b(31);
			end loop;
			for i in 14 downto 6 loop
				s2smb(i) 	<= (s1pH(14-i) or s1pL(14-i+9)) xor s1b(31);
			end loop;			
			for i in 5 downto 0 loop
				s2smb(i) 	<= (s1pS(5-i) or s1pH(5-i+9)) xor s1b(31);
			end loop;
			 
			if s1b(30 downto 28)>"000" then
				s2slr <= "11";
			else
				s2slr <= s1b(27 downto 26);
			end if;
			
			s2smb(24) <= s1b(31);
			
			--! Etapa2: Finalizar la denormalizaci&oacute;n de b.
			--! A
			s3sma <= s2sma;		
			s3exp <= s2exp;
			
			--! B
			case (s2slr) is
				when "00" =>
					s3smb 	<= s2smb(24 downto 0)+s2smb(24);
				when "01" => 
					s3smb 	<= ( s2slab(8 downto 0) & s2smb(23 downto 8) ) + s2smb(24);
				when "10"  =>
					s3smb 	<= ( s2slab(16 downto 0) & s2smb(23 downto 16)) + s2smb(24);
				when others => 
					s3smb 	<= (others => '0');
			end case;  
				
			
			--! Etapa 3: Etapa 3 Realizar la suma, quitar el signo de la mantissa y codificar el corrimiento hacia la izquierda.
			s4ures	<= s3ures+s3res(25); 				--Resultado no signado
			s4sgr	<= s3res(25);						--Signo
			s4exp 	<= s3exp;							--Exponente 
			s4lshift <= s3lshift;						--Corrimiento hacia la izquierda. 
			
			--! Etapa 4: Corrimiento y normalizaci&oacute;n de la mantissa resultado.
			res32(31) <= s4sgr;
			if s4ures(24)='1' then 
				res32(22 downto 0) <= s4ures(23 downto 1);
				res32(30 downto 23) <= s4exp+1;
			else
				case s4lshift(4 downto 3) is
					when "00" => 
						res32(22 downto 0) 	<= s4nrmP(22 downto 0);
						res32(30 downto 23) <= s4exp - s4lshift;
					when "01" => 
						res32(22 downto 0) 	<= s4nrmP(14 downto 0)	& s4slab(7 downto 0);
						res32(30 downto 23) <= s4exp - s4lshift;
					when "10" => 
						res32(22 downto 0)	<= s4nrmP(6 downto 0)	& s4slab(15 downto 0);
						res32(30 downto 23) <= s4exp - s4lshift;  
					when others => 
						res32(30 downto 0) <= (others => '0');	
				end case;	
				
			end if;
		
		end if;
	end process;
	--! Combinatorial gremlin, Etapa 0, Calcular la manera en que se llevara a cabo la desnormalizacion.
	process (s0b(30 downto 23),s0a(30 downto 23))
	begin
		--! Diferencia signada entre el valor del exponente a y el exponente b
		s0sdelta <= s0a(30 downto 23) - s0b(30 downto 23);
		
		--! Manejo de cero
		if sa(30 downto 23) = "00000000" then
			s0zeroa <= '0';
		else
			s0zeroa <= '1';
		end if;
		
		if sb(30 downto 23) = "00000000" then
			s0zerob <= '0';
		else
			s0zerob <= '1';
		end if;
		
		
	end process;
	
	process (s0sdelta)
	begin
		--! Esta parte define en que rango de la grafica de normalizac&oacute;n se movera la normalizaci—n del resultado de la mantissa
		case s0sdelta(7 downto 1) is
			when "0000000" => 
				s0nrmshftype <= '0';
			when "1111111" => 
				s0nrmshftype <= not(s0sdelta(0));
			when others => 
				s0nrmshftype <= '1';
		end case;
		
		--! Valor absoluto de la diferencia entre el exponente a y el b
		for i in 7 downto 0 loop
			s0udelta(i) <= s0sdelta(7) xor s0sdelta(i);
		end loop;
		
			 
	end process
	
	process (s0udelta,s0sdelta(7))
	begin
		s0udeltaa <= (s0udelta(7)&s0udelta(7 downto 1))+("0000000"&s0sdelta(7));
		s0udeltab <= (s0udelta(7)&s0udelta(7 downto 1))+("0000000"&s0udelta(0));
	end process;
	
	
	--! Combinatorial Gremlin, Etapa 1 Denormalizaci&oacute;n de las mantissas.
	shftra:shftr
	port 	map (s1dira,s1udeltaa(3 downto 0),'1'&s1uma,s1data40a);
	shftrb:shftr
	port	map (not(s1dira),s1udeltab(3 downto 0),'1'&s1umb,s1data40b); 
	
	process (s1data40b,s1data40a)
	begin 
		
		if s1dira='1' then
			s1signeddata56a(55 downto 40) <= (others => '0');
			s1signeddata56b(15 downto 0) <= (others => '0');
			for i in 39 downto 0 loop
				s1signeddata56a(i)  <= s1signa xor s1data40a(i);
				s1signeddata56b(i+16) <= s1signb xor s1data40b(i);
			end loop;
		else
			s1signeddata56a(15 downto 0) <= (others => '0');
			s1signeddata56b(55 downto 40) <= (others => '0');
			for i in 39 downto 0 loop
				s1signeddata56a(i+16)  <= s1signa xor s1data40a(i);
				s1signeddata56b(i) <= s1signb xor s1data40b(i);
			end loop;
		end if;
	end process;
	s1b2b1s:
	for i in 22 downto 0 generate
		b1s(i) <= s1b(22-i);
	end generate s1b2b1s;
	signa:
	for i in 22 downto 0 generate
		s1sma(i) <= s1a(31) xor s1a(i);
	end generate;
	s1sma(23) <= not(s1a(31));
	s1sma(24) <= s1a(31);	
	--! Combinatorial Gremlin, Etapa2: Finalizar la denormalizaci&oacute;n de b.
	s2signslab:
	for i in 16 downto 0 generate
		s2slab(i) <= s2smb(24);
	end generate s2signslab;
	--! Combinatorial Gremlin, Etapa 3 Realizar la suma, quitar el signo de la mantissa y codificar el corrimiento hacia la izquierda. 
	--adder:sadd2
	--port map (s3sma(24)&s3sma,s3smb(24)&s3smb,dpc,s3res);
	process (s3sma,s3smb)
	begin
		--! Magia: La suma ocurre aqui
		s3res <= (s3sma(24)&s3sma)+(s3smb(24)&s3smb);
	end process;
	process(s3res)
		variable lshift : integer range 24 downto 0; 
	begin
		lshift:=24;
 
		for i in 0 to 23 loop
			s3ures(i) <= s3res(25) xor s3res(i);
			if (s3res(25) xor s3res(i))='1' then
				lshift:=23-i;
			end if;
		end loop;
		s3ures(24) <= s3res(24) xor s3res(25);  
		s3lshift <= conv_std_logic_vector(lshift,5);
	end process;	
	--! Combinatorial Gremlin, Etapa 4 corrimientos y normalizaci&oacute;n de la mantissa resultado.
	normsupershiftermult:lpm_mult
	generic	map ("DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9","UNSIGNED","LPM_MULT",9,9,18)
	port 	map (shl(conv_std_logic_vector(1,9),s4lshift(2 downto 0)),s4ures(22 downto 14),s4nrmS);	
	normhighshiftermult:lpm_mult
	generic	map ("DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9","UNSIGNED","LPM_MULT",9,9,18)
	port 	map (shl(conv_std_logic_vector(1,9),s4lshift(2 downto 0)),s4ures(13 downto 5),s4nrmH);	
	normlowshiftermult:lpm_mult
	generic	map ("DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9","UNSIGNED","LPM_MULT",9,9,18)
	port 	map (shl(conv_std_logic_vector(1,9),s4lshift(2 downto 0)),s4ures(4 downto 0)&conv_std_logic_vector(0,4),s4nrmL);
	process (s4nrmS,s4nrmH,s4nrmL)
	begin 
		s4nrmP(22 downto 14) <= s4nrmS(8 downto 0) or s4nrmH(17 downto 9);
		s4nrmP(13 downto 5) <= s4nrmH(8 downto 0) or s4nrmL(17 downto 9);
		s4nrmP(4 downto 0) <= s4nrmL(8 downto 4);
	end process;
	s4signslab:
	for i in 15 downto 0 generate
		s4slab(i) <= '0';
	end generate s4signslab;
end ema32x2_arch;

		