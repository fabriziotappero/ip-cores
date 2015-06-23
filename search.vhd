--------------------------------------------------------------------------------
-- Create Date:    Open source, from 12c core hosted at  www.opencores.org
-- Design Name:    
-- Module Name:    Log function base 2
-- Project Name:   Deflate
-- Target Device:  
-- Dependencies: 
-- 
-- Revision: NA
-- Additional Comments:
-- Use this to convert the memeory lengths to the 2^x values
-- to dynamically assign the widths of the address
-- 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Function to find the log of a number 
--Is used to convert the addresses
package mat is
	 function log2(v: in natural) return natural;
end package mat;

--Function definition
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


package body mat is

function log2(v: in natural) return natural is
	variable n: natural;
	variable logn: natural;
begin
	n := 1;
	for i in 0 to 128 loop
		logn := i;
		exit when (n>=v);
		n := n * 2;
	end loop;
	return logn;
end function log2;
end package body mat;
--End of the package




--------------------------------------------------------------------------------
-- Create Date:    17:24:38 20/05/2006
-- Design Name:    
-- Module Name:    
-- Project Name:   Deflate
-- Target Device:  
-- Dependencies: hahskey.vhdl
-- 
-- Revision:
-- Revision 0.50 - Works but not optimised
-- Additional Comments:
-- This componenet controls the data input and stores the data alongwith 
-- the source in 32k buffers ,
-- It recieves the data directly and then on finding a minimum match 
-- Drives its match output high along with the match address on the address output
-- and the current offset on the next clock cycle
-- waits for the next +ve edge on the Active data input 
-- to go high before resuming, the output/ input is +ve edge triggered
-- 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.mat.all;

entity input_process is
	Generic 
	      (
			 -- Number of bits in the key
			 Hash_Width      : natural := 32;	 
			 -- Data bus width
			 Data_Width      : natural := 8;
			 -- Buffer allocated to the hash table and the source buffer = 32k tables
			 -- The key buffer has to be equal to the Hash_Width above and 
			 -- the source buffer of  Dat width 
 			 -- Start address for the memory bank at which the hash keys need to be stored
			 -- The end address is calculated by adding the length of the table to that address  
			 Length_of_Table : natural :=	32768            
			 );
	Port
	      (
			 --Outputs to read/write the key values.
			 hash_tbl_dat    : inout std_logic_vector ( Hash_Width - 1 downto 0);          
			 --Port to read/write data values
			 source_buff_dat : inout std_logic_vector ( Data_Width - 1 downto 0);          
			 -- Matching 4 bytes fond for the last 4 inputs
			 Match,
			 -- Ready for crunching
			 Ready,
			 -- The sync signals to the memory, read write operations 
			 -- done simultaneously on both memry banks
			 -- The design will currently work with SRAM and will need a wrapper to  
			 -- work with DRAM
			 -- Active data on output
			 Act_data_out,
			 --Read or write operation 0 = read, 1 = write
			 RW              : out bit	;
			 -- Current address in buffers
          Curr_addres     : out std_logic_vector (log2 ( Length_of_Table ) - 1 downto 0); 
			 --******
			 --Input signals
			 --Data in
			 source_dat : inout std_logic_vector ( Data_Width - 1 downto 0);          
			 -- Input Data Clock
			 Act_dat,
			 -- Clock
			 Src_clk,
			 -- Reset
			 Reset : in bit
			 
			 );
end input_process;

architecture mealy_machine of input_process is
component hash_key is
generic
       (
		 hash_width: natural := 32;
		 data_width: natural := 8);
port
       (
		 data_in: in std_logic_vector(data_width -1 downto 0);
		 hash_out: out std_logic_vector (hash_width -1 downto 0);
		 Clock,
		 reset,
		 start : in bit;
		 ready,
		 busy: out bit);
end component;
       -- Buffer address start for the key table
Signal key_address,
       buffer_address:   std_logic_vector (log2 ( Length_of_Table ) - 1 downto 0); 
		 -- Accept a 32 bit hash input	
signal hg1:    std_logic_vector ( (Hash_Width -1) downto 0);
-- 8 bit io buffer	
signal Buffer_1 : std_logic_vector (Data_Width-1 downto 0);  
--Component signals from the key algorithm
signal Algo_start, 
       Algo_clk,
		 Algo_rst,
		 Algo_op, 
		 Algo_bsy, 	 -- Algorithm sync aignals
		 Search_done,
		 Busy,
		 red_rst,
		 red_opr, 
		 val_match: bit := '0';	--Internal sync sgnals					  
signal mode,
       store_count :integer;

begin

--Unlike the sub components this module has a slightly complex reset cycle
--It resets the offset counters to 0, uses the next 7 clock cyces to read the 
--start addresses for the data and key buffer

resetter: process (Src_Clk)
variable tmp: integer;
variable red: bit :='0';
Begin
 if Src_Clk'event and Src_Clk = '1' then
  if mode /= 0 then 
    red_rst <= '0'; 
	 tmp := 0;
  else
    case tmp  is
	    when 0 =>
				buffer_address (7 downto 0) <= source_dat;
       when 1 =>
		      buffer_address (14 downto 8) <= source_dat (6 downto 0);
       when 2 =>
				key_address    (7 downto 0) <= source_dat;
		 when 3 =>
		      key_address    (14 downto 8) <= source_dat (6 downto 0);
       when 4 =>
		      red_rst <= '1';
       when others =>
				red_rst <= '0';
     end case;
	  end if;
 end if;
end process resetter; 

--The main input mealy machine is defined below
-- It has 6 states of operation
-- Mode 0 : Reset
-- Mode 1 : Wait
-- Mode 2 :	Active data input generationg a key for it and the last 3 bytes
-- Mode 3 : Storing the key and the input data
-- Mode 4 : Searching the hash buffer for a 4 byte match
-- Mode 5 : Match found, on the next clock cycle output current buffer offet
--          and on the second clock cycle output the match offset    
  
input_control : process (Act_dat, Src_Clk, Reset )
begin
--+ Ve edge triggered
 if Src_Clk'event and Src_Clk = '1' then 
   -- Mealy machine
	If Reset = '1' or ( mode = 0 and red_rst ='0' ) then
     mode <= 0;
   elsif	mode < 2 and Act_dat = '1' then
	  mode <= 2;
 	elsif	mode = 2 and Algo_bsy = '0' and store_count < 3 then
	  mode <= 3;
 	elsif	mode = 2 and Algo_bsy = '0' then
	  mode <= 4;
 	elsif	mode = 4 and Search_done = '1' and val_match = '1' then
	  mode <= 5;
 	elsif	mode = 4 and Search_done = '1' then
	  mode <= 3;
 	elsif	( mode = 5 or mode = 3 ) and Busy = '0' then
	  mode <= 1;
 	else
	  mode <= mode;
   end if;
 end if;
end process input_control;
--************************************************
-- Algorithm component addition
Key_Gen: hash_key port map 
                 (
					  data_in => Buffer_1,
		           hash_out => hg1,
		           Clock => Algo_clk,
		           reset => Algo_rst,
		           start => Algo_start,
		           ready => Algo_op,
		           busy  => Algo_bsy
					  );
-- ************************************************
Ready <= red_rst or red_opr;
end mealy_machine;