--	Package Filea Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use work.mem_interface_top_parameters_0.all;

package port_block_Constants is

constant MAX_NUM_PORTS_2_FIND : integer := 64;
constant MAX_NUM_FRAME_COUNTERS : integer := 8;
constant	TCP_SOURCE : std_logic_vector(7 downto 0) := X"24";
constant	TCP_DESTINATION : std_logic_vector(7 downto 0) := X"25";
constant UDP_SOURCE : std_logic_vector(7 downto 0) := X"2E";
constant UDP_DESTINATION : std_logic_vector(7 downto 0) := X"2F";
constant SHARED_MEM_PREFIX_SOURCE : std_logic_vector(8 downto 0) := "011011000";
constant SHARED_MEM_PREFIX_DEST   : std_logic_vector(8 downto 0) := "011011001";
constant SHARED_MEM_LUT_SRC_START : std_logic_Vector(8 downto 0) := "011011010";
constant SHARED_MEM_LUT_DST_START : std_logic_Vector(8 downto 0) := "011011011";
constant	SHARED_MEM_COUNTER_START : STD_logic_vector(8 downto 0) := "011011100";
constant baud : std_logic_vector := "110";--"000";
--sharable memory id map----
constant ID_0_SHARED : std_logic_vector(5 downto 0) := "100000";
constant ID_EmPAC_SHARED : std_logic_vector(5 downto 0) := "100001";
constant ID_wc_uart_SHARED : std_logic_vector(5 downto 0) := "100010";
constant ID_eRCP_SHARED : std_logic_vector(5 downto 0) := "100011";
constant ID_eRCP0_SHARED : std_logic_vector(5 downto 0) := "100100";
constant ID_5_SHARED : std_logic_vector(5 downto 0) := "100101";
constant ID_6_SHARED : std_logic_vector(5 downto 0) := "100110";
constant ID_7_SHARED : std_logic_vector(5 downto 0) := "100111";
constant ID_8_SHARED : std_logic_vector(5 downto 0) := "101000";
constant ID_9_SHARED : std_logic_vector(5 downto 0) := "101001";
constant ID_10_SHARED : std_logic_vector(5 downto 0) := "101010";
constant ID_11_SHARED : std_logic_vector(5 downto 0) := "101011";
constant ID_12_SHARED : std_logic_vector(5 downto 0) := "101100";
constant ID_13_SHARED : std_logic_vector(5 downto 0) := "101101";
constant ID_14_SHARED : std_logic_vector(5 downto 0) := "101110";
constant ID_15_SHARED : std_logic_vector(5 downto 0) := "101111";
constant ID_16_SHARED : std_logic_vector(5 downto 0) := "110000";
constant ID_17_SHARED : std_logic_vector(5 downto 0) := "110001";
constant ID_18_SHARED : std_logic_vector(5 downto 0) := "110010";
constant ID_19_SHARED : std_logic_vector(5 downto 0) := "110011";
constant ID_20_SHARED : std_logic_vector(5 downto 0) := "110100";
constant ID_21_SHARED : std_logic_vector(5 downto 0) := "110101";
constant ID_22_SHARED : std_logic_vector(5 downto 0) := "110110";
constant ID_23_SHARED : std_logic_vector(5 downto 0) := "110111";
constant ID_24_SHARED : std_logic_vector(5 downto 0) := "111000";
constant ID_25_SHARED : std_logic_vector(5 downto 0) := "111001";
constant ID_26_SHARED : std_logic_vector(5 downto 0) := "111010";
constant ID_27_SHARED : std_logic_vector(5 downto 0) := "111011";
constant ID_28_SHARED : std_logic_vector(5 downto 0) := "111100";
constant ID_29_SHARED : std_logic_vector(5 downto 0) := "111101";
constant ID_30_SHARED : std_logic_vector(5 downto 0) := "111110";
constant ID_31_SHARED : std_logic_vector(5 downto 0) := "111111";


constant SRC_MINI_PREFIX : std_logic_vector(2 downto 0) := "000";
constant DST_MINI_PREFIX : std_logic_vector(2 downto 0) := "001";
constant LUT_SRC_MINI_PREFIX : std_logic_vector(2 downto 0) := "010";
constant LUT_DST_MINI_PREFIX : std_logic_vector(2 downto 0) := "011";
constant COUNTER_MINI_PREFIX : std_logic_vector(2 downto 0) := "100";
--constant MAX_NUM_PORTS_2_FIND : integer := 64;
type array_table is array (0 to 63) of std_logic_vector(16 downto 0);		

type frame_counters_type is 
	record
		count0 : std_logic_vector(31 downto 0);
		count1 : std_logic_vector(31 downto 0);
		count2 : std_logic_vector(31 downto 0);
		count3 : std_logic_vector(31 downto 0);
		count4 : std_logic_vector(31 downto 0);
		count5 : std_logic_vector(31 downto 0);
		count6 : std_logic_vector(31 downto 0);
		count7 : std_logic_vector(31 downto 0);
	end record;

type frame_counters_array_type is array (0 to 7) of std_logic_vector(31 downto 0);

type lut_check is
	record
		in_lut : boolean;
		lut_pointer : integer range 0 to MAX_NUM_PORTS_2_FIND -1;
	end record;
		



function check_lut (signal l : in array_table; signal m : in std_logic_vector(16 downto 0)) return lut_check;

end port_block_Constants;


package body port_block_Constants is
	
function check_lut (signal l : in array_table; signal m : in std_logic_Vector(16 downto 0)) return lut_check is
		variable return_v : lut_check;
--	  variable return_v : boolean;
--	  variable return_port : integer range 0 to num_of_ports -1;
		begin  
		for i in 0 to MAX_NUM_PORTS_2_FIND -1 loop
			if(l(i) = m) then
				return_v.in_lut := true;
				return_v.lut_pointer := i;
				exit;
			else
				return_v.in_lut := false;
				return_v.lut_pointer := 0;
			end if;
		end loop;
		return return_v;
	end check_lut;

end port_block_Constants;
