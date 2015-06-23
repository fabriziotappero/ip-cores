--//// This file is part of the GNExtrapolator project				////
--//// http://opencores.org/project,gnextrapolator					////
--//// 																////
--//// Description 													////
--//// Implementation of Algoritm for extrapolation functions       //// 
--//// 												 	 			////
--//// 																////
--//// To Do: 														////
--//// - 															////
--//// 																////
--//// Author(s): 													////
--//// - Rodrigo Villegas, ruyvillegas@gmail.com, designer          ////
--//// - Iván Millán, ivanmillan36@gmail.com, designer				////
--//// - Pablo A. Salvadeo,	pas.@opencores, manager					////
--//// 																////
--//////////////////////////////////////////////////////////////////////
--//// 																////
--//// Copyright (C) 2011 Authors and OPENCORES.ORG 				////
--//// 																////
--//// This source file may be used and distributed without 		////
--//// restriction provided that this copyright statement is not 	////
--//// removed from the file and that any derivative work contains	////
--//// the original copyright notice and the associated disclaimer.	////
--//// 																////
--//// This source file is free software; you can redistribute it 	////
--//// and/or modify it under the terms of the GNU Lesser General 	////
--//// Public License as published by the Free Software Foundation;	////
--//// either version 2.1 of the License, or (at your option) any 	////
--//// later version. 												////
--//// 																////
--//// This source is distributed in the hope that it will be 		////
--//// useful, but WITHOUT ANY WARRANTY; without even the implied 	////
--//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 		////
--//// PURPOSE. See the GNU Lesser General Public License for more	////
--//// details. 													////
--//// 																////
--//// You should have received a copy of the GNU Lesser General 	////
--//// Public License along with this source; if not, download it 	////
--//// from http://www.opencores.org/lgpl.shtml 					////
--//// 																////
--//////////////////////////////////////////////////////////////////////

LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.std_logic_signed.all; 
USE ieee.std_logic_arith.all;

entity gnextrapolator is
	port
	(
		rst_i	: in  std_logic;
		clk_i	: in  std_logic;
		distancia_i:	in std_logic_vector(7 downto 0);
		extrapolar_i:	in std_logic;
		--indice_p_o:		out std_logic_vector(4 downto 0);	
		fxx_o:		out std_logic_vector(15 downto 0);
		fxx1_o:		out std_logic_vector(15 downto 0);
		fxx2_o:		out std_logic_vector(15 downto 0);
		fxx3_o:		out std_logic_vector(15 downto 0);
		fxx4_o:		out std_logic_vector(15 downto 0);
		resul_o:	out std_logic_vector(15 downto 0)
	);
end gnextrapolator;


architecture grenew of gnextrapolator is
-------------------------------------------------------------------------------------------------------
type columna is array(0 to 2) of std_logic_vector(15 downto 0);
signal sfx:		columna;	
signal indice:	integer range 0 to 31;
signal sram:	std_logic_vector(15 downto 0);

-------------------------------------------------------------------------------------------------------
	subtype word_t is std_logic_vector(15 downto 0);
	type memory_t is array(0 to 31) of word_t;	
	signal ram : memory_t;
	attribute romstyle : 			string;
	attribute romstyle of ram : 	signal is "M512";
	attribute ram_init_file : 		string;
	attribute ram_init_file of ram :signal is "gnextrapolator.mif";
-------------------------------------------------------------------------------------------------------
	
	
	
begin
process(rst_i,clk_i)
variable i:integer range 0 to 2 ;
variable resultado:std_logic_vector(15 downto 0);
variable fx: columna;
variable nabla1fx: columna;
variable nabla2fx: columna;
variable nabla3fx: columna;
variable nabla4fx: columna;
variable compensacion: columna;
variable cont:integer range 0 to 65535;

begin	
if (rst_i='1') then
	i:=0;
	cont:=0;
	fx(0):= (others=>'0');
	nabla1fx(0):= (others=>'0');
	nabla2fx(0):= (others=>'0');
	nabla3fx(0):= (others=>'0');
	nabla4fx(0):= (others=>'0');
	indice<=0;
elsif(rising_edge(clk_i)) then
	
	if(extrapolar_i = '0') then
	fx(i):= sram;
										--
										-- Se resiben los datos hasta que se ponga en alto el pin
	elsif(extrapolar_i = '1') then		-- 'extrapolar', con lo cual, se comienza a usar como valores 	
	fx(i):=resultado;					--
	cont:= cont+1;						-- de la funcion los resultados calculados, y se deja de tomar datos 
	end if;								-- de la entrada.
 
    									
	nabla1fx(i):=(fx(i)-fx(i-1));										-- Se calculan los nablas y el resultado
	nabla2fx(i):=(nabla1fx(i)-nabla1fx(i-1));							-- de sumar la ultima fila de vaores de 
	nabla3fx(i):=(nabla2fx(i)-nabla2fx(i-1));							-- la tabla.	
	nabla4fx(i):=(nabla3fx(i)-nabla3fx(i-1));							--
																		--
	resultado:=fx(i)+nabla1fx(i)+nabla2fx(i)+nabla3fx(i)+nabla4fx(i);	--	
							
	fxx_o	<=	fx(i);					--
	fxx1_o<=	nabla1fx(i);			-- Se envian los datos a salidas para su observacion,
	fxx2_o<=	nabla2fx(i);			-- el resultado se envia cada cierta cantidad de muestras
	fxx3_o<=	nabla3fx(i);			-- definida por el usuario.
	fxx4_o<=	nabla4fx(i);			--
	if(cont = distancia_i) then	--
	resul_o<=resultado;			--
	cont:=0;					--
	end if;						--
	
	
	fx(0):=			fx(i);			-- se desplaza la fila hacia atras para poder calcular la siguiente
	nabla1fx(0):=	nabla1fx(i);	--
	nabla2fx(0):=	nabla2fx(i);	--
	nabla3fx(0):=	nabla3fx(i);	--
	nabla4fx(0):=	nabla4fx(i);	--

i:=1;
indice <= indice+1;
end if;

end process;
--indice_p_o <= std_logic_vector(indice);
--------------------------------------------------------------------------------------------------------------
process(clk_i)
	begin	
	if(falling_edge(clk_i)) then 
	       sram <= ram(indice);
	end if;
end process;	
-----------------------------------------------------------------------------------------------------------------
end grenew;
