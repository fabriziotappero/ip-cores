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

library work;

entity usimplez_top is 
	generic
	(	WIDTH_WORD: natural:= 12;
		WIDTH_ADDRESS: natural:= 9
	);
	port
	(	clk_i :  in  std_logic;
		rst_i :  in  std_logic;
		we_o :  out  std_logic;
		in0_o :  out  std_logic;
		in1_o :  out  std_logic;
		op0_o :  out  std_logic;
		op1_o :  out  std_logic
	);
end usimplez_top;

architecture str of usimplez_top is
 
	component usimplez_cpu
		generic
		(	WIDTH_WORD:	natural;
			WIDTH_OPERATION_CODE: natural;
			WIDTH_ADDRESS: natural;
			--Instructions:
			ST: 	std_logic_vector;
			LD: 	std_logic_vector;
			ADD: 	std_logic_vector;
			BR: 	std_logic_vector;
			BZ: 	std_logic_vector;
			CLR: 	std_logic_vector;
			DEC: 	std_logic_vector;
			HALT: 	std_logic_vector
		);
		port
		(	clk_i : in std_logic;
			rst_i : in std_logic;
			data_bus_i : in std_logic_vector(WIDTH_WORD-1 downto 0);
			we_o : out std_logic;
			in0_o : out std_logic;
			in1_o : out std_logic;
			op0_o : out std_logic;
			op1_o : out std_logic;
			addr_bus_o : out std_logic_vector(WIDTH_ADDRESS-1 downto 0);
			data_bus_o : out std_logic_vector(WIDTH_WORD-1 downto 0)
		);
	end component;
	
	component usimplez_ram
		generic 
		(	WIDTH_ADDRESS : natural;
			WIDTH_WORD : natural
		);
		port
		(	clk_i : in std_logic;
			we_i : in std_logic;
			addr_i : in std_logic_vector(WIDTH_ADDRESS-1 downto 0);
			data_i : in std_logic_vector(WIDTH_WORD-1 downto 0);
			data_o : out std_logic_vector(WIDTH_WORD-1 downto 0)
		);
	end component;
	
	signal	rd_data_bus_s :  std_logic_vector(WIDTH_WORD-1 downto 0);
	signal	we_s :  std_logic;
	signal	addr_bus_s :  std_logic_vector(WIDTH_ADDRESS-1 downto 0);
	signal	wr_data_bus_s :  std_logic_vector(WIDTH_WORD-1 downto 0);
	
begin 

we_o <= we_s;

cpu:usimplez_cpu
	generic map
	(	WIDTH_WORD => 12,
		WIDTH_ADDRESS => 9,
		WIDTH_OPERATION_CODE => 3,
		ST		=> "000",
		LD		=> "001",
		ADD		=> "010",
		BR		=> "011",
		BZ		=> "100",
		CLR		=> "101",
		DEC		=> "110",
		HALT	=> "111"
	)
	port map
	(	clk_i => clk_i,
		rst_i => rst_i,
		data_bus_i => rd_data_bus_s,
		we_o => we_s,
		in0_o => in0_o,
		in1_o => in1_o,
		op0_o => op0_o,
		op1_o => op1_o,
		addr_bus_o => addr_bus_s,
		data_bus_o => wr_data_bus_s
	);

ram:usimplez_ram
	generic map
	(	WIDTH_ADDRESS  => 9,
		WIDTH_WORD => 12
	)
	port map
	(	clk_i => clk_i,
		we_i => we_s,
		addr_i => addr_bus_s,
		data_i => wr_data_bus_s,
		data_o => rd_data_bus_s
	);

end str;