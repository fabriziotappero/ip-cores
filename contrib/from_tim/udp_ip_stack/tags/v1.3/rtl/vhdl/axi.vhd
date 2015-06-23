--
--	Package File Template
--
--	Purpose: This package defines data types for AXI transfers


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package axi is

	type axi_in_type is record
		data_in 				: STD_LOGIC_VECTOR (7 downto 0);
		data_in_valid 		: STD_LOGIC;								-- indicates data_in valid on clock
		data_in_last 		: STD_LOGIC;								-- indicates last data in frame
	end record;
	
	
	type axi_out_type is record
		data_out_valid		: std_logic;								-- indicates data out is valid
		data_out_last		: std_logic;								-- with data out valid indicates the last byte of a frame
		data_out				: std_logic_vector (7 downto 0);		-- ethernet frame (from dst mac addr through to last byte of frame)	 
	end record;

end axi;
