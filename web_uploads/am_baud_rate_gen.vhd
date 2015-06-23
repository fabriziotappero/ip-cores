-----------------------------------------------------------------------------
--	Filename:	am_baud_rate_gen.vhd
--
--	Description:
--		a paramatizable baud rate generator
--
--	input a 'high speed' clock, and get out a clock enable of x times the baud rate, and the baud rate.
--	  paramiters are the high speed clock frequency, the baud rate required, and the over sample needed.
--
-- works by having two counters,
-- fast counter, counts down to x time baud rate
-- slow counter, then divides this to give baud rate.
--
--
--	Copyright (c) 2007 by Andrew Mulcock 
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       		Author    	Comment
--	-------- 	---------- 		---------	-----------
--	1.0      	26/Nov/07  	A Mulcock	Initial revision
--
-----------------------------------------------------------------------------
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity am_baud_rate_gen is
   generic( 
      baudrate       : integer := 115200;
      clock_freq_mhz : real    := 200.0;
      over_sample    : integer := 4
   );
	port(
		clk     	 : in std_logic;	
		rst     	 : in std_logic;
		baud_x_en : out std_logic;
		baud_en   : out std_logic
		);
end entity;

-- ==========================================================================================

architecture baud_rtl of am_baud_rate_gen is

-- calculate from the clock freq, the baud rate, and the over sample ratio
--  the size and count of the two counters.

constant	div_ratio_real 	: real	   := ( clock_freq_mhz * 1000000.0) / ((real(baudrate) * real(over_sample)) );
constant	div_ratio_int		: integer	:= integer ( div_ratio_real - 0.5); -- 0.5 gives rounding up / down 
constant over_sample_ratio : integer   := over_sample -1;
constant max_count         : integer   := div_ratio_int;

signal   fast_counter      : integer range 0 to div_ratio_int;
signal   slow_counter      : integer range 0 to over_sample_ratio;
signal   slow_cnt_en       : std_logic;

begin



------------------------------------------------------------
------------ baud rate counter -----------------------------
------------------------------------------------------------

-- in an fpga, don't need to reset a wrap around counter,
-- but somepeople still like to for simulation
-- so comparmise and reset syncronously, as suits the syncronous counter.

process(clk)
begin
   if rising_edge(clk) then 
      if ( (rst = '1')  or (fast_counter = 0) ) then                    
         fast_counter <= max_count;
         slow_cnt_en <= not( rst );
      else
         fast_counter <= fast_counter - 1;
         slow_cnt_en <= '0';
      end if;
	end if;
end process;

process(clk)
begin
   if rising_edge(clk) then 
      if (rst = '1') or ( slow_counter = 0 and slow_cnt_en = '1' ) then                    
         slow_counter <= over_sample_ratio;
         baud_en <= not( rst);
      elsif slow_cnt_en = '1' then
         slow_counter <= slow_counter - 1;
         baud_en <= '0';
      else
         slow_counter <= slow_counter;
         baud_en <= '0';
      end if;
	end if;
end process;

         baud_x_en <= slow_cnt_en;

end baud_rtl;

