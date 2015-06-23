--------------------------------------------------------------------------------
-- Create Date:    15:24:38 11/05/2006
-- Design Name:    
-- Module Name:    Hash key
-- Project Name:   Deflate
-- Target Device:  
-- Dependencies: Hashchain.vhdl
-- 
-- Revision:
-- Revision 0.50 - Works but not optimised
-- Additional Comments:
-- A wrapper for the DJB2 algorithm has a 3 byte buffer and uses an extra input byte  generate 
-- to generate 4 byte hash keys
-- 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.mat.all;
use work.all;

entity hash_key is
--generic definitions, data bus widths.
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
		 ready, -- Not used
		 busy: out bit);
end hash_key;

architecture genhash of hash_key is
component HashChain
          Generic (																					  
			 Data_Width : natural := 8;	  -- Data Bus width
			 Hash_Width : natural := 32	  -- Width of the hash key generated 
			         );
           Port(
			  Hash_o   : out std_logic_vector (Hash_Width - 1 downto 0);      -- Hash key
           Data_in  : in  std_logic_vector (Data_Width -1 downto 0);       -- Data input from byte stream
			  Busy,																				-- Busy
			  Done: out bit;																	-- Key generated
			  Clock,													                     -- Clock
			  Reset,													                     -- Reset
			  Start,																				-- Start the hash key generation
			  O_E : in  bit		                     						      -- Output Enable
           );
end component;

signal hg1:    std_logic_vector ( (Hash_Width -1) downto 0);			 -- Accept a 32 bit hash input	
signal Datain, Buffer_1, Buffer_2, Buffer_3 : std_logic_vector (Data_Width-1 downto 0);  -- 8 bit io buffers
signal Algo_start, Algo_clk,Algo_rst,Algo_op, Algo_bsy, Key_done: bit;						  -- Algorithm interface aignals
signal mode, buff_count, proc_count :integer;

begin
glink:HashChain port map (Hash_O  => hg1, 
                          Data_in => Datain,
			                 Clock   => Algo_clk,	
			                 Reset	 => Algo_rst,
			                 Start	 => Algo_start,											                
			                 O_E     => Algo_op,            						   
                          Busy	 => Algo_bsy,
			                 Done	 => Key_done);
-- 3 byte input buffer
-- Stores the last 3 bytes used to generate a hash key to keep the hash keys current
-- The hash algorightm is reset after every 4 byte key is generated 
--	to ensure that the matches are of 4 byte lengths
Buffer_1 <= X"00"    when mode = 0 else
				Buffer_2 when mode = 2 else
				Buffer_1;

Buffer_2 <= X"00"    when mode = 0 else
				Buffer_3 when mode = 2 else
				Buffer_2;

Buffer_3 <= X"00"    when mode = 0 else
				Data_in  when mode = 2 else
				Buffer_3;

--Common Clock
Algo_clk <= Clock;

--	Reset the hash algorithm when reset
Algo_rst <= '1' when mode = 0 or mode = 1else
            '0';

--Sync signals
busy <= '1' when mode > 1 else
        '0';

--Send a start for every input byte.
Algo_start <= '1' when mode = 2 and buff_count = 3 else -- the 3 byte buffer is empty
              '1' when mode = 4 else						  -- 3 byte buffer is full and one byte has been processed
              '0';

-- 4 bytes sent one after the other	to the hashing algorithm
Datain <= X"00" when mode = 0 or mode = 1 else
          Buffer_1 when mode = 2 and buff_count = 3  else
			 Buffer_1 when mode = 4 and buff_count = 3 and proc_count = 1 else
			 Buffer_2 when mode = 4 and buff_count = 3 and proc_count = 2 else
			 Buffer_3 when mode = 4 and buff_count = 3 and proc_count = 3 else
			 X"00";

-- Enabling hash algo output
Algo_op <= '1' when proc_count > 2 else
           '0';

--Buffer counter 
buffer_counter: process (mode)
begin
   if mode = 0 then
       buff_count <= 0;      -- Reset
	elsif	mode = 2 and buff_count < 3 then
	    buff_count <= buff_count + 1;  -- 1 byte added to buffer
   else
	    buff_count <= buff_count;      -- BUffer is full keep the buffered values and the count
	end if;
end process buffer_counter;

-- Procesed bytes counter
processed_counter: process (mode)
begin
   if (mode = 2 and buff_count = 3) or mode = 4 then
	   proc_count <= proc_count + 1 ; 
	elsif mode = 3 then 
		proc_count <= proc_count;
   else 
	   proc_count <= 0;
   end if;
end process processed_counter;


-- mealy machine, sends 4 bytes sequentially to the hashing algorithm
--	Waits for the buffer to get filled, on the first +ve clock edge afer the start input
-- is made 1 it sends the bytes to the DJB algorithm.

mealy_mach: process (Clock, Reset, Start)
Begin
 -- +ve clock
 if Clock'event and Clock = '1' then 
	if Reset = '1' then  -- Reset
	   mode <= 0;
   --Start either fill the buffer or Process the first byte in buffer
	elsif Start = '1' and mode < 2 then 
	   mode <= 2;
   -- Buffer is still processing first byte
	-- wait while algorithm finishes generating hash
	elsif (mode = 2 and buff_count = 3) or (mode > 1 and Algo_bsy = '1')  then  
	   mode <= 3;		 
   --  To hash the next 3 bytes
	elsif mode = 3 and proc_count < 4 then
	   mode <= 4;        
	--  Wait
	else
	   mode <= 1;       
   end if;
 end if;
end process mealy_mach;
end genhash;