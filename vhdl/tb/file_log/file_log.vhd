-- logging of signal values into a text file
-- (c) 2011... Gerhard Hoffmann, Ulm, Germany   opencores@hoffmann-hochfrequenz.de
--
-- V1.0 2011-feb-24 published under BSD license
--
-- This entity logs signals to a file. There are several flavours for use with several types.
-- Logging happens on the rising edge of the clock signal with CE active.
-- The filename is given by a string. The signal log_on, when true, opens the
-- file for writing; setting it to false closes the file.
-- Toggling log_on several times without changing the filename will overwrite
-- the file.
--
-- TODO: integer version

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;	
use     std.textio.all;


entity real_file_log is 
   Port ( 
      clk:      in  std_logic;
      ce:       in  std_logic := '1';
      filename:	in  string    := "log.txt";
      log_on:   in  std_logic := '1';
      d:        in  real
   ); 
end real_file_log;


----------------------------------------------------------------------------------------------------


architecture tb of real_file_log is
begin
   
log_p: process is 

   file     phyle:      text;
   variable l:          line;
   variable filestatus: file_open_status;

begin
      
   wait until rising_edge(log_on);
   file_close(phyle);  -- in case the file was open already
   file_open(filestatus, phyle, filename, write_mode);            
   assert filestatus = open_ok
           report "real_file_log: cannot open destination file <" & filename & ">"
           severity failure;
           
log_loop: 
   loop
      wait until rising_edge(clk) or log_on'event;

      if ( log_on /= '1' )
      then
         file_close(phyle); 
         exit;
      else
         -- must have been a rising clock edge
         if ce = '1'
         then
           write (l, d, right, 20);  -- right justified, 20 digits wide 
         end if;  -- ce='1' 
      end if;     -- not activate   
      writeline(phyle, l);      
   end loop log_loop;
end process log_p;
   
end architecture tb;

