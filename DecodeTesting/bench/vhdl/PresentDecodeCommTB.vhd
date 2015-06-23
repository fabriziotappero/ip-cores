-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     This test bench simulate data transfer between PC and     ----
---- PresentDecodeComm core. All test data were generated in       ----
---- another program and textio was used for processing. Test bench----
----  is for to distinct data sets.                                ----
---- To Do:                                                        ----
----                                                               ----
---- Author(s):                                                    ----
---- - Krzysztof Gajewski, gajos@opencores.org                     ----
----                       k.gajewski@gmail.com                    ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2013 Authors and OPENCORES.ORG                  ----
----                                                               ----
---- This source file may be used and distributed without          ----
---- restriction provided that this copyright statement is not     ----
---- removed from the file and that any derivative work contains   ----
---- the original copyright notice and the associated disclaimer.  ----
----                                                               ----
---- This source file is free software; you can redistribute it    ----
---- and-or modify it under the terms of the GNU Lesser General    ----
---- Public License as published by the Free Software Foundation;  ----
---- either version 2.1 of the License, or (at your option) any    ----
---- later version.                                                ----
----                                                               ----
---- This source is distributed in the hope that it will be        ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied    ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR       ----
---- PURPOSE. See the GNU Lesser General Public License for more   ----
---- details.                                                      ----
----                                                               ----
---- You should have received a copy of the GNU Lesser General     ----
---- Public License along with this source; if not, download it    ----
---- from http://www.opencores.org/lgpl.shtml                      ----
----                                                               ----
-----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.all;
USE work.txt_util.all;
USE ieee.std_logic_textio.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY PresentDecodeCommTB IS
END PresentDecodeCommTB;
 
ARCHITECTURE behavior OF PresentDecodeCommTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PresentDecodeComm
    PORT(
         DATA_RXD : IN  std_logic;
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         DATA_TXD : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal DATA_RXD : std_logic := '0';
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';

 	--Outputs
   signal DATA_TXD : std_logic;

   -- Clock period definitions
   -- speed of DIGILENT board and RS-232 core
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PresentDecodeComm PORT MAP (
          DATA_RXD => DATA_RXD,
          CLK => CLK,
          RESET => RESET,
          DATA_TXD => DATA_TXD
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
	
	-- Variables
	file txt :text is in "test/data.txt";
	file key  :text is in "test/key.txt";
	file txt2 :text is in "test/data2.txt";
	file key2  :text is in "test/key2.txt";
	
	variable line_in      : line;
	variable line_content : string(1 to 8);
	variable data         : STD_LOGIC;
	
   begin		
	
		DATA_RXD <= '1';
		RESET <= '1';
      wait for 1000 ns;	
		RESET <= '0';
		
      wait for CLK_period*10;

	  -- All data are sent in direction from LSB to MSB

	  -- Reading first 'data' file  each "segment" is one bit of serial data
      while not (endfile(txt)) loop
			readline(txt, line_in);  -- info line
			read(line_in, line_content);
			report line_content;
			
			DATA_RXD <= '0'; -- start bit
			-- this amount is due to estimation of period of time needed for sending
			-- one bit in RS-232 with 115 200 bps bandwith
			wait for 8.75 us;
			
			readline(txt, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt, line_in);
			read(line_in, data);
			DATA_RXD <= data; -- parity bit
			wait for 8.75 us;
			
			report "End of byte";
			DATA_RXD <= '1'; -- stop bit
			wait for 100 us;
		end loop;

		-- Reading first 'key' file  each "segment" is one bit of serial data
		while not (endfile(key)) loop
			readline(key, line_in);  -- info line
			read(line_in, line_content);
			report line_content;
			
			DATA_RXD <= '0'; -- start bit
			wait for 8.75 us;
			
			readline(key, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key, line_in);
			read(line_in, data);
			DATA_RXD <= data; -- parity bit
			wait for 8.75 us;
			
			report "End of byte";
			DATA_RXD <= '1'; -- stop bit
			wait for 100 us;
		end loop;

		-- Cipher counting and sending result
		wait for 2000 us;
		
		-- Reading second 'data2' file  each "segment" is one bit of serial data
		while not (endfile(txt2)) loop
			readline(txt2, line_in);  -- info line
			read(line_in, line_content);
			report line_content;
			
			DATA_RXD <= '0'; -- start bit
			wait for 8.75 us;
			
			readline(txt2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(txt2, line_in);
			read(line_in, data);
			DATA_RXD <= data; -- parity bit
			wait for 8.75 us;
			
			report "End of byte";
			DATA_RXD <= '1'; -- stop bit
			wait for 100 us;
		end loop;

		-- Reading second 'key2' file  each "segment" is one bit of serial data
		while not (endfile(key2)) loop
			readline(key2, line_in);  -- info line
			read(line_in, line_content);
			report line_content;
			
			DATA_RXD <= '0'; -- start bit
			wait for 8.75 us;
			
			readline(key2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key2, line_in);
			read(line_in, data);
			DATA_RXD <= data;
			wait for 8.75 us;
			
			readline(key2, line_in);
			read(line_in, data);
			DATA_RXD <= data; -- parity bit
			wait for 8.75 us;
			
			report "End of byte";
			DATA_RXD <= '1'; -- stop bit
			wait for 100 us;
		end loop;
		
		-- Cipher counting and sending result
		wait for 2000 us;
		
      assert false severity failure;
   end process;

END;
