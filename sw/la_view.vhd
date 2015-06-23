-- LOGIC ANALYSER VIEWER
-- this file is only for simulation !!!!!!!!!
-- this file allows for viewing data obtained by internal logic analyzer
-- file la_data.bin should be on your computer
-- this file is obtained by a log_anal.vhd component and others components loaded into a FPGA (virtex)
-- and a proper WISHBONE reads
-- readblock  la_data.bin adr_start adr_stop
-- where adr_start= LA_base_address, adr_stop= LA_base_address + 2^(adr_width-1) + (15)dec
-- the last 16 bytes of la_data.bin contains control registers

-- adjust data_width and  mem_adr_width !!!! to be the same as in the log_anal entity !!!
-- also define your own signals (the same which where connected to log_anal data input
-- and then assign these signals to proper d(index) data

library IEEE;
use IEEE.std_logic_1164.all;
library IEEE;
use IEEE.std_logic_arith.all;

entity la_view is
end;

architecture la_view_arch of la_view is
  -- constants - should be the same as generics in the log_anal entity !!!
  constant data_width: integer:= 16; -- width of the data that are analysed (must be power of 2)
  constant mem_adr_width: integer:= 9; -- internal memory address width  
  -- update the follows values if you want to watch triger
  constant trig_width: integer:= 8; -- updatate or no (the circuit can work properly with value 32 also
  constant trigger_same_as_data: boolean:= true; -- if the input to the entity log_anal 
	  -- data is the same as trig, i.e. trig(trig_width-1 downto 0)= data(trig_width-1 downto 0) 

------------------------------------ internal LA logic do not change 
  constant mem_size: integer:= 2 ** mem_adr_width;
  constant file_name: string := "la_data.bin"; -- file name which contains acquired data
  constant file_length: integer:= 2**(mem_adr_width)*data_width/32; 
  		-- number of dwords (32-bits) in the file (excluding control registers)
  type la_mem_type is array (mem_size-1 downto 0) of std_logic_vector (data_width-1 downto 0); 

		  
procedure ReadControlReg(variable stop_count: out integer;
  signal trigger_value: out std_logic_vector(trig_width-1 downto 0) ) is -- read stop counter value form la_data.bin file

  variable DataIn: integer;
  variable trig_care: std_logic_vector(trig_width-1 downto 0);
  type BIT_VECTOR_FILE is file of integer;
  file Data_In_File : BIT_VECTOR_FILE;   
begin
   	FILE_OPEN (Data_In_File, file_name, READ_MODE); 
	for i in 0 to file_length loop
	   READ (Data_In_File, DataIn );
	end loop;
	-- Data_In contains status register (MSBs should be filled with zero
	assert DataIn<256
	  report "Error. Incorrect data format in la_data.bin, check if the same generic values: data_width and mem_adr_width has been set in the log_anal and la_view entities or wrong read size"
	  severity failure;
	assert DataIn<128
	  report "Warning. The log_anal was still in run mode when acquired data were read"
	  severity warning;
	assert DataIn>=64
	  report "Warning. The log_anal has not finished data acquisition or file format error, check generic values seting and WISHBONE read size"
	  severity warning;
	
	READ (Data_In_File, DataIn ); --  stop counter
	assert DataIn< 2**mem_adr_width
	  report "Error. Incorect stop counter value in la_data.bin. Check if the same generic values: data_width and mem_adr_width has been set in the log_anal and la_view entities"
		  severity failure;
	stop_count:= DataIn;
	
	READ (Data_In_File, DataIn ); -- trig_value
	trigger_value<= conv_std_logic_vector(DataIn, trig_width);
	READ (Data_In_File, DataIn ); -- trig_care
	trig_care:= conv_std_logic_vector(DataIn, trig_width);
	for i in trig_width-1 downto 0 loop
		if trig_care(i)='0' then
			trigger_value(i)<= '-';
		end if;
	end loop;
	FILE_CLOSE ( Data_In_File );
end ReadControlReg;
	


procedure ReadData(variable stop_count: in integer; signal mem : out la_mem_type ) is -- read recorded data from la_data.bin file
  variable DataIn : integer; 
  variable Data32 : std_logic_vector(31 downto 0);
  variable address:integer; 
  type BIT_VECTOR_FILE is file of integer;
  file DataInFile : BIT_VECTOR_FILE;   

begin
	address:= (mem_size - stop_count) rem mem_size; -- the start address (rem is for stop_count=0)
   	FILE_OPEN (DataInFile, file_name, READ_MODE); 
	for i in 1 to file_length loop -- for every data in the file
	  READ(DataInFile, DataIn);
	  Data32:= conv_std_logic_vector(DataIn, 32);
	  for j in 0 to (32/data_width) -1 loop
		  mem(address)<= Data32((j+1)*data_width-1 downto j*data_width);
		  address:= address + 1;
		  if address= mem_size then
			  address:= 0; 
		  end if;
	  end loop;
	end loop;
	FILE_CLOSE (DataInFile);
end;

  signal la_mem : la_mem_type; -- data read form la_data.bin file
  signal d: std_logic_vector(data_width-1 downto 0); -- data  recorder by the LA
  signal trigger_value: std_logic_vector(trig_width-1 downto 0); -- the value specified by writes to the trigger value and care registers
  signal trigger: std_logic; -- trigger condition is now satisfied
  signal clk: std_logic; -- data has been recoreded according to this clock activity
 
 -----------------------------------------------------------------------------------
 -- User area (changes can be done here)
  -- define here your signal names

  signal counter: std_logic_vector(data_width-1 downto 0); 

begin
  -- write here which signal is assigned to which LA data bus (see log_anal instantiation)
  -- signal 'd' is the same as data input in the log_anal entity
  counter<= d;
  
  
  -- clk generation
  process begin
	  wait for 10 ns; -- this value can be change freely
	  clk<= '0';
	  wait for 10 ns;
	  clk<= '1';
  end process;
  

-------------------------------------------------------------------------------------------
-- Internal LA logic do not change it !!!
process
  variable Initialize : integer := 0;	-- initialisation flag
  variable stop_count : integer; -- the count points where the last data has been written to the LA memory
begin
	if Initialize=0 then	-- run only one time at the beginning
	  ReadControlReg(stop_count, trigger_value);
	  ReadData(stop_count, la_mem); -- read data recorded by the LA
	  Initialize := 1;
	  wait for 1000 ms;
    end if;
end process;


process(clk)
  variable i: integer:= 0;
  variable trigger_tmp: std_logic;
  variable d_tmp: std_logic_vector(data_width-1 downto 0);
begin 
  if clk'event and clk='1' then
	  d_tmp:= la_mem(i); -- data recorded in the LA
	  d<= d_tmp;
	  -- trigger logic
	  if trigger_same_as_data=true  and trig_width <= data_width then
		trigger_tmp:= '1';
	    for j in trig_width-1 downto 0 loop
		  if trigger_value(j)/= '-' then -- check only if not don't care
			  trigger_tmp:= trigger_tmp AND not (trigger_value(j) XOR d_tmp(j));
		  end if;
	    end loop;	
	  	trigger<= trigger_tmp;
	  else -- do not show trigger because trigger data are different from watched data
		trigger<= 'Z';
	  end if;
	  
	  i:= i +1;
	  if i= mem_size then
		  i:= mem_size-1;
		  assert false 
	        report "O.K. All acquired data in the LA has already been shown"
	        severity failure; 
	  end if;
  end if;
end process;
   	assert data_width=32 or data_width=16 or data_width=8
	  report "Error in la_view: constant data_width must be 8, 16 or 32"
 		severity failure; 

end la_view_arch;

-- logic analyser (LA) for FPGAs
-- ver 1.0
-- Author: Ernest Jamro

--//////////////////////////////////////////////////////////////////////
--//// Copyright (C) 2001 Authors and OPENCORES.ORG                 ////
--////                                                              ////
--//// This source file may be used and distributed without         ////
--/// restriction provided that this copyright statement is not    ////
--//// removed from the file and that any derivative work contains  ////
--//// the original copyright notice and the associated disclaimer. ////
--////                                                              ////
--//// This source file is free software; you can redistribute it   ////
--//// and/or modify it under the terms of the GNU Lesser General   ////
--//// Public License as published by the Free Software Foundation; ////
--//// either version 2.1 of the License, or (at your option) any   ////
--//// later version.                                               ////
--////                                                              ////
--//// This source is distributed in the hope that it will be       ////
--//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
--//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
--//// PURPOSE. See the GNU Lesser General Public License for more  ////
--//// details.                                                     ////
--////                                                              ////
--//// You should have received a copy of the GNU Lesser General    ////
--//// Public License along with this source; if not, download it   ////
--//// from <http://www.opencores.org/lgpl.shtml>                   ////
