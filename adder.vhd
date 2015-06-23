-- RAYTRAC
-- Author Julian Andres Guarin
-- adder.vhd
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
--     along with raytrac.  If not, see <http://www.gnu.org/licenses/>.

--! Libreria de definici&oacute;n de segnales y tipos estandares, comportamiento de operadores aritmeticos y logicos.\n 
library ieee;
--! Paquete de definicion estandard de logica. 
use ieee.std_logic_1164.all;
--! Se usaran en esta descripcion los componentes del package arithpack.vhd. 
use work.arithpack.all;
entity adder is 
	generic (
		width : integer := 4;
		carry_logic : string := "CLA";
		substractor_selector : string := "YES"
	);

	port (
		a,b	: in std_logic_vector(width-1 downto 0);
		s,ci	: in std_logic;
		result	: out std_logic_vector(width-1 downto 0);
		cout	: out std_logic	
	);
end adder;

--! @brief 	Arquitectura del sumador
architecture adder_arch of adder is 

	signal sa,p,g:	std_logic_vector(width-1 downto 0);
	signal sCarry:	std_logic_vector(width downto 1); 
	

begin

		

 
	-- Usual Structural Model / wether or not CLA/RCA is used and wether or not add/sub selector is used, this port is always instanced --
	
	result(0)<= a(0) xor b(0) xor ci;
	wide_adder:
	
	
	if (width>1) generate
		wide_adder_generate_loop:
		for i in 1 to width-1 generate
			result(i) <= a(i) xor b(i) xor sCarry(i);
		end generate wide_adder_generate_loop;
	end generate wide_adder;
	cout <= sCarry(width);    
	g<= sa and b;
	p<= sa or b;
	
	
	--! Si se configura una se&ntilde;al para seleccionar entre suma y resta, se generar&aacute; el circuito a continuaci&oacute;n.
	
	adder_sub_logic :	-- adder substractor logic
	if substractor_selector = "YES" generate
		a_xor_s: 
		for i in 0 to width-1 generate
			sa(i) <= a(i) xor s;
		end generate a_xor_s;
	end generate adder_sub_Logic;
		
	add_logic:	--!Si no se configura una se&ntilde;al de selecci&oacute;n entonces sencillamente se conecta a a sa.
	if substractor_selector = "NO" generate
		sa <= a;
	end generate add_logic;
	


	-- Conditional Instantiation / RCA/CLA Logical Blocks Generation --
	
	--! Si se selecciona un ripple carry adder se instancia el siguiente circuito
	rca_logic_block_instancing:	-- Ripple Carry Adder
	if carry_logic="RCA" generate	
		rca_x: rca_logic_block 
		generic map (width=>width)
		port map (
			p=>p,
			g=>g,
			cin=>ci,
			c=>sCarry
		);
	end generate rca_logic_block_instancing;
	
	--! Si se selecciona un Carry Lookahead adder se instancia el siguiente circuito
	cla_logic_block_instancing:	-- Carry Lookahead Adder
	if carry_logic="CLA" generate
		cla_x: cla_logic_block
		generic map (width=>width)
		port map (
			p=>p,
			g=>g,
			cin=>ci,
			c=>sCarry
		);
	end generate cla_logic_block_instancing;
	

end adder_arch;

		
