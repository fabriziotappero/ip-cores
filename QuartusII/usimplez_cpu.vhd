--//////////////////////////////////////////////////////////////////////
--//// 																////
--//// 																////
--//// 																////
--//// This file is part of the MicroSimplez project				////
--//// http://opencores.org/project,usimplez						////
--//// 																////
--//// Description 													////
--//// Implementation of MicroSimplez IP core according to			////
--//// MicroSimplez IP core specification document. 				////
--//// 																////
--//// To Do: 														////
--//// - 															////
--//// 																////
--//// Author(s): 													////
--//// - Daniel Peralta, peraltahd@opencores.org, designer			////
--//// - Martin Montero, monteromrtn@opencores.org, designer		////
--//// - Julian Castro, julyan@opencores.org, reviewer				////
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity usimplez_cpu is

	generic(	
		WIDTH_WORD:	natural:=12;
		WIDTH_OPERATION_CODE: natural:=3;
		WIDTH_ADDRESS: natural:=9;
		--Instructions:
		ST: 	unsigned:="000";
		LD: 	unsigned:="001";
		ADD: 	unsigned:="010";
		BR: 	unsigned:="011";
		BZ: 	unsigned:="100";
		CLR: 	unsigned:="101";
		DEC: 	unsigned:="110";
		HALT: 	unsigned:="111"
		);

	port(	
		clk_i: in std_logic;
		rst_i: in std_logic;
		data_bus_i: in std_logic_vector((WIDTH_WORD-1) downto 0); 
		data_bus_o: out std_logic_vector((WIDTH_WORD-1) downto 0); 
		addr_bus_o: out std_logic_vector((WIDTH_ADDRESS-1) downto 0); 
		we_o: out std_logic;
		--To Debug:
			In0_o: out std_logic;
			In1_o: out std_logic;
			Op0_o: out std_logic;
			Op1_o: out std_logic
		--
		);
		
end usimplez_cpu;  

architecture fsm of usimplez_cpu is
	 
	type T_estado is (In0,In1,Op0,Op1);
	signal estado: T_estado;
	--Registros:
	 --Acumulador (AC)
	signal ac_reg_s: unsigned((WIDTH_WORD-1) downto 0);
	 --Codigo de Operacion (CO)
	signal co_reg_s: unsigned((WIDTH_OPERATION_CODE-1) downto 0);
	 --Campo de Direccion (CD)
	signal cd_reg_s: unsigned((WIDTH_ADDRESS-1) downto 0);
	 --Contador de Programa (CP)
	signal cp_reg_s: unsigned((WIDTH_ADDRESS-1) downto 0);
	--Buses:
	signal data_bus_s: unsigned((WIDTH_WORD-1) downto 0); 
	signal addr_bus_s: unsigned((WIDTH_ADDRESS-1) downto 0);
	
begin

    process(clk_i,rst_i)
    begin
		if(rising_edge(clk_i)) then
			if(rst_i='1') then
				co_reg_s <= (others=>'0');
				ac_reg_s <= (others=>'0');
				cd_reg_s <= (others=>'0');
				cp_reg_s <= (others=>'0');
				addr_bus_o <= (others=>'1');
				data_bus_o <= (others=>'0');
				we_o<='0'; 
				--
				estado <= In0;
				--
			else
				case estado is
					when In0 =>
						-- (MP[CD])->CO;
						co_reg_s<=unsigned(data_bus_i(11 downto 9));
						cd_reg_s<=unsigned(data_bus_i(8 downto 0));
						-- (CP)+1->CP
						cp_reg_s<=cp_reg_s+1;
						--
							In0_o<='1';
							In1_o<='0';
							Op0_o<='0';
							Op1_o<='0';
						--
						estado<=In1;
					when In1 =>
						--
							In0_o<='0';
							In1_o<='1';
							Op0_o<='0';
							Op1_o<='0';
						--
						case (co_reg_s) is
							when CLR =>
								-- 0->AC
								ac_reg_s<=(others=>'0');
								-- (CP)->CD
								addr_bus_o<=std_logic_vector(cp_reg_s);
								estado<=In0;
							when DEC =>
								-- (AC)-1 -> AC
								ac_reg_s<=ac_reg_s-1;
								-- (CP)->CD
								addr_bus_o<=std_logic_vector(cp_reg_s);
								estado<=In0;
							when BR =>
								-- (CD)->CP,CD
								cp_reg_s<=cd_reg_s;
								addr_bus_o<=std_logic_vector(cd_reg_s);
								estado<=In0;
							when BZ =>
								--Si AC>0 igual BR
								if(ac_reg_s=0) then
									cp_reg_s<=cp_reg_s;
									addr_bus_o<=std_logic_vector(cd_reg_s);
								else
								--Si no (CP)->CD
									addr_bus_o<=std_logic_vector(cp_reg_s);
								end if;
								estado<=In0;
							when HALT =>
								-- 0->CP
								cp_reg_s<=(others=>'0');
								estado<=In1;
							when LD =>
								-- (CD)->CD
								addr_bus_o<=std_logic_vector(cd_reg_s);
								estado<=Op0;
							when ST =>
								addr_bus_o<=std_logic_vector(cd_reg_s);
								estado<=Op0;
							when ADD =>
								addr_bus_o<=std_logic_vector(cd_reg_s); 
								estado<=Op0;
							when others=>
								estado<=In0;
						end case;
					when Op0 =>
						--
							In0_o<='0';
							In1_o<='0';
							Op0_o<='1';
							Op1_o<='0';
						--
						case (co_reg_s) is
							when LD =>
								-- (MP[CD])->AC
								ac_reg_s<=unsigned(data_bus_i);
								estado<=Op1;
							when ST =>
								-- (AC)->MP[CD]
								data_bus_o<=std_logic_vector(ac_reg_s);
								we_o<='1'; 
								estado<=Op1;
							when ADD =>
								ac_reg_s<=ac_reg_s+unsigned(data_bus_i);
								estado<=Op1;
							when others =>
								estado<=In0;
						end case;
					when OP1 =>
						-- (CP)->CD
						addr_bus_o<=std_logic_vector(cp_reg_s);
						we_o<='0'; 
						estado<=In0;
						--
							In0_o<='0';
							In1_o<='0';
							Op0_o<='0';
							Op1_o<='1';
						--
					when others =>
						estado<=In0;
				end case;
			end if;	
		end if;
	end process;
	
end fsm;