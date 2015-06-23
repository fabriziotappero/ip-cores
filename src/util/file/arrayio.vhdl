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

PACKAGE arrayio IS

  -- This type must be used for base memory arrays
  TYPE cstr_array_type IS ARRAY(INTEGER RANGE <>) OF INTEGER;

  -- This procedure fills a variable memory array with the contents of a file.
  -- Each line must contain a single hexadecimally formatted value.
  PROCEDURE init_var_array (
    VARIABLE array_in : INOUT cstr_array_type;
    CONSTANT filename : IN    STRING);

  PROCEDURE init_sig_array (
    SIGNAL array_in   : INOUT cstr_array_type;
    CONSTANT filename : IN    STRING);

  FUNCTION init_cstr (
    CONSTANT array_size : IN INTEGER;
    CONSTANT input_file : IN STRING)
    RETURN cstr_array_type;
  
  PROCEDURE dump_array (
    CONSTANT array_in : IN cstr_array_type);

END PACKAGE arrayio;

PACKAGE BODY arrayio IS

  -- Private declarations
  PROCEDURE read_hex (
    VARIABLE input_line : IN  STRING;
    VARIABLE hex_value  : OUT INTEGER);

  FUNCTION hex_char_to_value (
    CONSTANT chr : IN CHARACTER)
    RETURN INTEGER;

  PROCEDURE fill_var_array (
    CONSTANT value    : IN    INTEGER;
    VARIABLE in_array : INOUT cstr_array_type);

  PROCEDURE fill_sig_array (
    CONSTANT value  : IN    INTEGER;
    SIGNAL in_array : INOUT cstr_array_type);

  PROCEDURE read_file_into_var_array (
    VARIABLE array_in : INOUT cstr_array_type;
    CONSTANT filename : IN    STRING);

  PROCEDURE read_file_into_sig_array (
    SIGNAL array_in   : INOUT cstr_array_type;
    CONSTANT filename : IN    STRING);

  -- Procedure and function body definitions
  FUNCTION init_cstr (
    CONSTANT array_size : IN INTEGER;
    CONSTANT input_file : IN STRING)
    RETURN cstr_array_type IS

    VARIABLE rv : cstr_array_type(0 TO array_size - 1) := (OTHERS => 0);
  BEGIN  -- FUNCTION init_cstr

    init_var_array(rv, input_file);
    
    RETURN rv;
  END FUNCTION init_cstr;

  -- Fill a signal array with the contents of a file
  PROCEDURE init_sig_array (
    SIGNAL array_in   : INOUT cstr_array_type;
    CONSTANT filename : IN    STRING) IS

  BEGIN

    fill_sig_array(0, array_in);
    read_file_into_sig_array(array_in, filename);

  END PROCEDURE init_sig_array;

  -- General procedure to fill an array of integers. This is to make sure that
  -- the array does not contain any meta-data any more.
  PROCEDURE fill_sig_array (
    CONSTANT value  : IN    INTEGER;
    SIGNAL in_array : INOUT cstr_array_type) IS

  BEGIN  -- PROCEDURE fill_array

    FOR i IN in_array'RANGE LOOP
      in_array(i) <= value;
    END LOOP;  -- i
  END PROCEDURE fill_sig_array;

  -- Read the file into the signal array
  PROCEDURE read_file_into_sig_array (
    SIGNAL array_in   : INOUT cstr_array_type;
    CONSTANT filename : IN    STRING) IS

    FILE input_file : TEXT;

    VARIABLE input_line : LINE;
    VARIABLE fstatus    : FILE_OPEN_STATUS;

    VARIABLE a_index : INTEGER := 0;
    VARIABLE i_value : INTEGER := 0;

    VARIABLE output_line : LINE;
    VARIABLE line_value  : STRING(1 TO 4);

  BEGIN  -- PROCEDURE read_file_into_sig_array

    file_open(fstatus, input_file, filename, READ_MODE);

    IF fstatus = OPEN_OK THEN
      WHILE NOT endfile(input_file) LOOP
        -- Read the next line and put its contents in a string
        readline(input_file, input_line);
        read(input_line, line_value);

        -- Current debugging feedback
        write(output_line, line_value);
        writeline(OUTPUT, output_line);

        -- Turn a hex value into an integer value
        read_hex(line_value, i_value);

        array_in(a_index) <= i_value;
        a_index           := a_index + 1;

        write(output_line, STRING'("Index :"));
        write(output_line, a_index);
        write(output_line, STRING'(" Value: "));
        write(output_line, i_value);
        writeline(OUTPUT, output_line);
      END LOOP;

      file_close(input_file);

    END IF;

  END PROCEDURE read_file_into_sig_array;

  --
  --

  -- Initialise a variable array
  PROCEDURE init_var_array (
    VARIABLE array_in : INOUT cstr_array_type;
    CONSTANT filename : IN    STRING) IS

  BEGIN

    fill_var_array(0, array_in);
    read_file_into_var_array(array_in, filename);

  END PROCEDURE init_var_array;

  -- General procedure to fill an array of integers. This is to make sure that
  -- the array does not contain any meta-data any more.
  PROCEDURE fill_var_array (
    CONSTANT value    : IN    INTEGER;
    VARIABLE in_array : INOUT cstr_array_type) IS

  BEGIN  -- PROCEDURE fill_array

    FOR i IN in_array'RANGE LOOP
      in_array(i) := value;
    END LOOP;  -- i
    
  END PROCEDURE fill_var_array;

  PROCEDURE read_file_into_var_array (
    VARIABLE array_in : INOUT cstr_array_type;
    CONSTANT filename : IN    STRING) IS

    FILE input_file : TEXT;

    VARIABLE input_line : LINE;
    VARIABLE fstatus    : FILE_OPEN_STATUS;

    VARIABLE a_index : INTEGER := 0;
    VARIABLE i_value : INTEGER := 0;

    VARIABLE output_line : LINE;
    VARIABLE line_value  : STRING(1 TO 4);

  BEGIN  -- PROCEDURE read_file

    file_open(fstatus, input_file, filename, READ_MODE);

    IF fstatus = OPEN_OK THEN
      WHILE NOT endfile(input_file) LOOP
        -- Read the next line and put its contents in a string
        readline(input_file, input_line);
        read(input_line, line_value);

        -- Current debugging feedback
        write(output_line, line_value);
        writeline(OUTPUT, output_line);

        -- Turn a hex value into an integer value
        read_hex(line_value, i_value);

        array_in(a_index) := i_value;
        a_index           := a_index + 1;

        write(output_line, STRING'("Index :"));
        write(output_line, a_index);
        write(output_line, STRING'(" Value: "));
        write(output_line, i_value);
        writeline(OUTPUT, output_line);
      END LOOP;

      file_close(input_file);

    END IF;

  END PROCEDURE read_file_into_var_array;

  -- Shared and generic procedures

  -- Read a hexadecimal value from the input string and turn it into an integer.
  PROCEDURE read_hex (
    VARIABLE input_line : IN  STRING;
    VARIABLE hex_value  : OUT INTEGER) IS

    VARIABLE input_length : INTEGER := input_line'LENGTH;
    VARIABLE chr          : CHARACTER;
    VARIABLE output_line  : LINE;

    VARIABLE chr_value : INTEGER := 0;
    VARIABLE radix     : INTEGER := 1;
    VARIABLE result    : INTEGER := 0;

  BEGIN  -- PROCEDURE read_hex

    FOR i IN input_line'REVERSE_RANGE LOOP
      chr       := input_line(i);
      chr_value := hex_char_to_value(chr);
      result    := chr_value * radix + result;
      radix     := radix * 16;
    END LOOP;

    hex_value := result;

  END PROCEDURE read_hex;

  -- Return the integer value matching with the hexadecimal character
  FUNCTION hex_char_to_value (
    CONSTANT chr : IN CHARACTER)
    RETURN INTEGER IS

    VARIABLE digit : INTEGER := 0;
  BEGIN  -- PROCEDURE hex_char_to_value

    CASE chr IS
      WHEN '0'    => digit := 0;
      WHEN '1'    => digit := 1;
      WHEN '2'    => digit := 2;
      WHEN '3'    => digit := 3;
      WHEN '4'    => digit := 4;
      WHEN '5'    => digit := 5;
      WHEN '6'    => digit := 6;
      WHEN '7'    => digit := 7;
      WHEN '8'    => digit := 8;
      WHEN '9'    => digit := 9;
      WHEN 'A'    => digit := 10;
      WHEN 'B'    => digit := 11;
      WHEN 'C'    => digit := 12;
      WHEN 'D'    => digit := 13;
      WHEN 'E'    => digit := 14;
      WHEN 'F'    => digit := 15;
      WHEN OTHERS => digit := 0;
    END CASE;

    RETURN digit;

  END FUNCTION hex_char_to_value;

  PROCEDURE dump_array (
    CONSTANT array_in : IN cstr_array_type) IS

    VARIABLE output_line : LINE;
  BEGIN  -- PROCEDURE dump_array

    FOR i IN array_in'RANGE LOOP

      write(output_line, string'("Index: "));
      write(output_line, i);

      write(output_line, string'(" Value: "));
      write(output_line, array_in(i));

      writeline(OUTPUT, output_line);
      
    END LOOP;  -- i
    
    
  END PROCEDURE dump_array;

END PACKAGE BODY arrayio;
