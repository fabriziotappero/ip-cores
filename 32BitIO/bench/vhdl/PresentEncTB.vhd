-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Test bench of Present encoder with 32 bit IO.             ----
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
use work.kody.ALL;
 
ENTITY PresentEncTB IS
END PresentEncTB;
 
ARCHITECTURE behavior OF PresentEncTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PresentEnc
    PORT(
         input : IN  std_logic_vector(31 downto 0);
         output : OUT  std_logic_vector(31 downto 0);
         ctrl : IN  std_logic_vector(3 downto 0);
         clk : IN  std_logic;
         reset : IN  std_logic;
         ready : out  std_logic
        );
    END COMPONENT;
    
	-- Clock period definitions
   constant clk_period : time := 1ns;
	constant p10 : time := clk_period/10;
	constant edge : time := clk_period-p10;

   --Inputs
   signal input : std_logic_vector(31 downto 0) := (others => '0');
   signal ctrl : std_logic_vector(3 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
	signal strobe : std_logic;

 	--Outputs
   signal output : std_logic_vector(31 downto 0);
	signal ready : std_logic := '0';
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PresentEnc PORT MAP (
          input => input,
          output => output,
          ctrl => ctrl,
          clk => clk,
          reset => reset,
          ready => ready
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
	
	file infile :text is in "input.txt";
	variable line_in :line;
	variable line_string : string(1 to 12);
	variable bytes : std_logic_vector(31 downto 0);
	variable bytes2 : std_logic_vector(3 downto 0);
	variable xbit : std_logic;
	
		
   begin		
      -- hold reset state for 100ms.
      wait for 100ns;	
		reset <= '1';
		wait for 10ns;
		reset <= '0';
		wait for 10ns;
      -- insert stimulus here 
		-- Below loop which iterates through "input.txt" file
			while not (endfile(infile)) loop
			   
				readline(infile, line_in);  -- info line
				read(line_in, line_string);
				report line_string;
				
				readline(infile, line_in);  -- info line
				read(line_in, line_string);
				report line_string;
				
				readline(infile, line_in);  -- command line "no operation to prepare encoder"
				hread(line_in, bytes2);
				ctrl <= bytes2;
				wait for clk_period;
				
				readline(infile, line_in);  -- info line
				read(line_in, line_string);
				report line_string;
				
				readline(infile, line_in);  -- command line for reading key 1/3
				hread(line_in, bytes2);
				ctrl <= bytes2;
				readline(infile, line_in); -- read data
				read(line_in, xbit);
				input <= (others => xbit);
				wait for clk_period;
				
				readline(infile, line_in);  -- info line
				read(line_in, line_string);
				report line_string;
				
				readline(infile, line_in);  -- command line for reading key 2/3
				hread(line_in, bytes2);
				ctrl <= bytes2;
				readline(infile, line_in);  -- read data
				read(line_in, xbit);
				input <= (others => xbit);
				wait for clk_period;
				
				readline(infile, line_in);  -- info line
				read(line_in, line_string);
				report line_string;				
				
				readline(infile, line_in);  -- command line for reading key 3/3
				hread(line_in, bytes2);
				ctrl <= bytes2;
				readline(infile, line_in);  -- read data
				read(line_in, xbit);
				input <= (others => xbit);
				wait for clk_period;
				
				readline(infile, line_in);  -- info line
				read(line_in, line_string);
				report line_string;	
				
				readline(infile, line_in);  -- command line for reading text 1/2
				hread(line_in, bytes2);
				ctrl <= bytes2;
				readline(infile, line_in);  --read data
				read(line_in, xbit);
				input <= (others => xbit);
				wait for clk_period;
				
				readline(infile, line_in);  -- info line
				read(line_in, line_string);
				report line_string;	
				
				readline(infile, line_in);  -- command line for reading text 2/2
				hread(line_in, bytes2);
				ctrl <= bytes2;
				readline(infile, line_in);  --read data
				read(line_in, xbit);
				input <= (others => xbit);
				wait for clk_period;
				
				readline(infile, line_in);  -- info line
				read(line_in, line_string);
				report line_string;	
				
				readline(infile, line_in);  -- command line for coding input text to ciphertext
				hread(line_in, bytes2);
				ctrl <= bytes2;			
				wait for clk_period*33;
				
				readline(infile, line_in);  -- info line
				read(line_in, line_string);
				report line_string;	
				
				readline(infile, line_in);  -- command line for retrieving output 1/2
				hread(line_in, bytes2);
				ctrl <= bytes2;			
				wait for clk_period;
				
				readline(infile, line_in);  -- retrieve expected value 1/2 from input file
				hread(line_in, bytes);
				
				if output /= bytes then
				    report "RESULT MISMATCH! Least significant bytes failed" severity ERROR;
			       assert false severity failure;
				else
				    report "Least significant bytes successful" severity note;	
				end if;
				
				readline(infile, line_in);  -- info line
				read(line_in, line_string);
				report line_string;	
				
				readline(infile, line_in);  -- command line for retrieving output 2/2
				hread(line_in, bytes2);
				ctrl <= bytes2;			
				wait for clk_period*2;
				
				readline(infile, line_in);  -- retrieve expected value 3/2 from input file
				hread(line_in, bytes);
				
				if output /= bytes then
				    report "RESULT MISMATCH! Most significant bytes failed" severity ERROR;
			       assert false severity failure;
				else
				    report "Most significant bytes successful" severity note;	
				end if;
				
				report "";	-- "new line"
				
			end loop;
		assert false severity failure;
   end process;
	
	strobe <= TRANSPORT clk AFTER edge;
	
	outs: PROCESS (strobe)
		variable str :string(1 to 29);
		variable lineout :line;
		variable init_file :std_logic := '1';
		file outfile :text is out "output.txt";
		
		-------- conversion function: std_logic_vector => character --------
		function conv_to_hex_char (sig: std_logic_vector(3 downto 0)) RETURN character IS
			begin
			case sig is
				when "0000" => return '0';
				when "0001" => return '1';
				when "0010" => return '2';
				when "0011" => return '3';
				when "0100" => return '4';
				when "0101" => return '5';
				when "0110" => return '6';
				when "0111" => return '7';
				when "1000" => return '8';
				when "1001" => return '9';
				when "1010" => return 'A';
				when "1011" => return 'B';
				when "1100" => return 'C';
				when "1101" => return 'D';
				when "1110" => return 'E';								
				when others => return 'F';
			end case;
		end conv_to_hex_char;
		
		-------- conversion function: std_logic => character --------
		function conv_to_char (sig: std_logic) RETURN character IS
			begin
			case sig is
				when '1' => return '1';
				when '0' => return '0';
				when 'Z' => return 'Z';
				when others => return 'X';
			end case;
		end conv_to_char;
		
		-------- conversion function: std_logic_vector => string --------
		function conv_to_string (inp: std_logic_vector; length: integer) RETURN string IS
			variable x : integer := length/4;
			variable s : string(1 to x);
			begin				
				for i in 0 to (x-1) loop
				s(x-i) := conv_to_hex_char(inp(4*i+3 downto 4*i));
				end loop;
			return s;
		end conv_to_string;
		
		-------------------------------------
		begin
		-------- output file header (columns) --------
			if init_file = '1' then
				str:="clk                          ";
				write(lineout,str); writeline(outfile,lineout);
				str:="| reset                      ";
				write(lineout,str); writeline(outfile,lineout);
				str:="| | ready                    ";
				write(lineout,str); writeline(outfile,lineout);
				str:="| | | ctrl                   ";
				write(lineout,str); writeline(outfile,lineout);
				str:="| | | | input                ";
				write(lineout,str); writeline(outfile,lineout);
				str:="| | | | |        output      ";
				write(lineout,str); writeline(outfile,lineout);
				str:="| | | | |        |           ";
				write(lineout,str); writeline(outfile,lineout);
				init_file := '0';
			end if;
		
		-------- write to output "output" --------
			if (strobe'EVENT and strobe='0') then
				str := (others => ' ');
				str(1) := conv_to_char(clk);
				str(2) := '|';
				str(3) := conv_to_char(reset);
				str(4) := '|';
				str(5) := conv_to_char(ready);
				str(6) := '|';
				str(7) := conv_to_hex_char(ctrl);
				str(8) := '|';
				str(9 to 16) := conv_to_string(input,32);
				str(17) := '|';
				str(18 to 25) := conv_to_string(output,32);
				str(26) := '|';				
				write(lineout,str);
				writeline(outfile,lineout);
			end if;
	end process outs;
end;