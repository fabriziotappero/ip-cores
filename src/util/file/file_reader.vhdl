-- Copyright 2015, Jürgen Defurne
--
-- This file is part of the Experimental Unstable CPU System.
--
-- The Experimental Unstable CPU System Is free software: you can redistribute
-- it and/or modify it under the terms of the GNU Lesser General Public License
-- as published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- The Experimental Unstable CPU System is distributed in the hope that it will
-- be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
-- General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with Experimental Unstable CPU System. If not, see
-- http://www.gnu.org/licenses/lgpl.txt.


LIBRARY std;
USE std.textio.ALL;
USE work.exp_io.ALL;

ENTITY file_reader IS

END ENTITY file_reader;

ARCHITECTURE Imperative OF file_reader IS

  -- This provides a hard coded input file.
  -- This is opened when the program starts
  FILE input_file_1 : TEXT OPEN READ_MODE IS "test_input.txt";
  FILE std_out      : TEXT OPEN WRITE_MODE IS "STD_OUTPUT";

  -- These files could also be declared in the process that reads them. Then
  -- they need to be opened by using file_open()

BEGIN  -- ARCHITECTURE Imperative

  read_file : PROCESS IS

    VARIABLE input_line : LINE;

  BEGIN  -- PROCESS read_file

    -- The endfile() function tests if the end of the passed file has been
    -- reached.
    IF NOT endfile(input_file_1) THEN
      -- readline() reads a line from a file
      readline(input_file_1, input_line);
      writeline(std_out, input_line);
    ELSE
      write(input_line,test_f("Z"));
      writeline(std_out, input_line);
      WAIT;
    END IF;

  END PROCESS read_file;

  -- Files are declared by using FILE, in addition to SIGNALs and VARIABLEs.
  -- Since Xilinx XST only knows the type TEXT for file, it is of no use to try
  -- other types.
  -- When a file is declared in the ARCHITECTURE, then it is automatically opened.
  -- When a file is declared in a PROCESS, then the file can be opened by using
  -- the file_open() procedure.
  -- The contents of files are read into a VARIABLE of type LINE.
  -- Standard input and output must be declared as normal files, but with the
  -- file names "STD_INPUT" and "STD_OUTPUT".

END ARCHITECTURE Imperative;
