--	Package Filea Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use work.mem_interface_top_parameters_0.all;

package MAC_Constants is

constant max_burst_length : integer := 8;
constant burst_length : integer := 4;
--constant burst_data_width integer := 
constant num_of_ports : integer := 8;	 
constant virtual_address_width : integer := 22;
constant physical_address_width : integer := 24;  
constant data_width : integer := 32;
constant data_resolution : integer := 4;
constant ID_width : integer := 5;
constant priority_width : integer := 8;
constant stack_depth : integer := 4;
constant cmd_width : integer := 2;
constant WR_FIFO_witdh : integer := (physical_address_width + data_width + cmd_width);
constant dummy_data : std_logic_vector(data_width -1 downto 0) := (others => '0');
constant read_cmd : std_logic_vector(1 downto 0) := "01";
constant write_cmd : std_logic_vector(1 downto 0) := "10";
constant data_delimiter : integer := data_width + 1;
constant address_delimiter : integer := data_width + physical_address_width + 1;
constant read_write_delimiter : integer := 2;


type ID_type is
	array (0 to num_of_ports -1) of  std_logic_vector(ID_width -1 downto 0);

type priority_type is
	array (0 to num_of_ports) of  std_logic_vector(priority_width -1 downto 0);
	
type v_adr_i is
	array (0 to num_of_ports) of  std_logic_vector(virtual_address_width -1 downto 0);

--type v_adr_i_0 is
--	array (0 to num_of_ports -1) of  std_logic_vector(virtual_address_width -2 downto 0);

type v_data_i is
	array (0 to num_of_ports) of  std_logic_vector(data_width -1 downto 0);

type burst_data_o is
	array (0 to burst_length -1) of  std_logic_vector(data_width -1 downto 0);
	
type v_sel_i is
	array (0 to num_of_ports -1) of  std_logic_vector(data_resolution -1 downto 0);
	
type Burst_Data_Array is
	array (0 to burst_length -1) of std_logic_vector((data_width + virtual_address_width) -1 downto 0);

type Data_out_Array is
	array (0 to num_of_ports) of std_logic_vector((data_width + virtual_address_width) -1 downto 0);

type burst_read_data_array is
	array (0 to burst_length -1) of  std_logic_vector(data_width -1 downto 0);

type read_data_array is
	array (0 to num_of_ports) of  std_logic_vector(data_width -1 downto 0);


type Memory_Access_Port_in is
    record
      adr_i	 	:     v_adr_i;
		dat_i	 	:     v_data_i;
		we_i	 	:     std_logic_vector(num_of_ports downto 0); 
		sel_i	 	:     v_sel_i;
		stb_i	 	:     std_logic_vector(num_of_ports downto 0);
		cyc_i	 	:     std_logic_vector(num_of_ports downto 0);
		ID_i	 	:     ID_type;
		priority_i :    priority_type;
		push_i 	: 		std_logic_vector(num_of_ports downto 0);
		lock_i   :  std_logic_vector(num_of_ports downto 0);
		end record;
		
type port_avail is
	record
		id_avail : boolean;
		return_port : integer range 0 to num_of_ports -1;
	end record;
		
type Memory_Access_Port_out is		
	record
		err_o	 	:     std_logic_vector(num_of_ports downto 0);
		ack_o	 	:     std_logic_vector(num_of_ports downto 0);
		burst_full :  std_logic_vector(num_of_ports downto 0);
		burst_empty :  std_logic_vector(num_of_ports downto 0);
		dat_o	 	:     v_data_i;
    end record;

type Preprocessor_Interface_Port_out is		
	record
		write_data_out	 	:     std_logic_vector(data_width -1 downto 0);
		address_out	 		:     std_logic_vector(physical_address_width -1 downto 0);
		write_enable_out	:     std_logic;
		read_enable_out	:     std_logic;
		FIFO_empty_out	:     std_logic;
    end record;

type Preprocessor_Interface_Port_in is		
	record
		Acknowledge_read_data_in 		:     std_logic;
		ack_access_in			: std_logic;
		Read_data_in	 		:     std_logic_vector(data_width -1 downto 0);
    end record;

function find_high_bit (signal l : in STD_LOGIC_VECTOR (num_of_ports downto 0)) return integer;
function check_ID (signal l : in v_adr_i; signal n : in integer range 0 to num_of_ports; signal m : in ID_type) return port_avail;
end MAC_Constants;


package body MAC_Constants is

function find_high_bit (signal l : in STD_LOGIC_VECTOR (num_of_ports downto 0)) return integer is
	  variable return_v : integer range 0 to num_of_ports;
		begin  
		for i in 0 to num_of_ports loop
			if(l(i) = '1') then
				return_v := i ;
				exit;
			end if;
		end loop;
		return return_v;
	end find_high_bit;
	
function check_ID (signal l : in v_adr_i; signal n : in integer range 0 to num_of_ports; signal m : in ID_type) return port_avail is
		variable return_v : port_avail;
--	  variable return_v : boolean;
--	  variable return_port : integer range 0 to num_of_ports -1;
		begin  
		for i in 0 to num_of_ports -1 loop
			if(l(n)(20 downto 16) = m(i)) then
				return_v.id_avail := true;
				return_v.return_port := i;
				exit;
			else
				return_v.id_avail := false;
				return_v.return_port := 0;
			end if;
		end loop;
		return return_v;
	end check_ID;
	
--function decode_a (signal l : in v_adr_i; signal n : in integer range 0 to num_of_ports -1; signal m : in ID_type) return port_avail is
--		variable return_v : port_avail;
----	  variable return_v : boolean;
----	  variable return_port : integer range 0 to num_of_ports -1;
--		begin  
--		for i in 0 to num_of_ports -1 loop
--			if(l(n)(20 downto 16) = m(i)) then
--				return_v.id_avail := true;
--				return_v.return_port := i;
--				exit;
--			else
--				return_v.id_avail := false;
--				return_v.return_port := 0;
--			end if;
--		end loop;
--		return return_v;
--	end check_ID;

--function translate_ID (signal l : in integer; signal n : in integer range 0 to num_of_ports -1; signal m : in ID_type) return boolean is
--	  variable return_v : boolean;
--		begin  
--		for i in 0 to num_of_ports -1 loop
--			if(l(n)(20 downto 16) = m(i)) then
--				return_v := true;
--				exit;
--			else
--				return_v := false;
--			end if;
--		end loop;
--		return return_v;
--	end check_ID;
	
--	if(check_ID(adr_i,index_i_v, id_i) then
	
--function decode (signal l : in std_logic_vector; signal m : in ID_type) return boolean is
--	  variable return_v : boolean;
--		begin  
--		for i in 0 to num_of_ports -1 loop
--			if(m(i) = l) then
--				return_v := true;
--				exit;
--			end if;
--		end loop;
--		return return_v;
--	end check_ID;
 
end MAC_Constants;
