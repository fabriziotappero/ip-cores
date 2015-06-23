--!
--! Copyright (C) 2010 - 2012 Creonic GmbH
--!
--! This file is part of the Creonic Viterbi Decoder, which is distributed
--! under the terms of the GNU General Public License version 2.
--!
--! @file
--! @brief  Testbench file reading package
--! @author Matthias Alles
--! @date   2010/04/05
--!
--! @details Offers functions to read files
--!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;


package pkg_tb_fileio is


	------------------------------
	-- Data type definitions
	------------------------------

	--! Data type to store the file conent in integer format.
	type t_int_array is array (natural range <>) of integer;

	--! Data type to store the file conent in natural format.
	type t_nat_array is array (natural range <>) of natural;

	--! Access type of t_int_array.
	type t_int_array_ptr is access t_int_array;

	--! Access type of t_nat_array.
	type t_nat_array_ptr is access t_nat_array;

	--! String access type, e.g., for file names of variable length.
	type t_string_ptr is access string;


	------------------------------
	-- File I/O Functions.
	------------------------------

	--!
	--! Open file, get number of lines, create a new memory of type t_int_array
	--! at address data, read the file, saturate the values to bit_width bits.
	--! Format within file: One signed integer per line (decimal).
	--!
	procedure read_file (data      : inout t_int_array_ptr;
	                     num_lines : inout natural;
	                     bit_width : in natural;
	                     filename  : in string);


	--!
	--! Open file, get number of lines, create a new memory of type t_int_array
	--! at address data, read the file, saturate the values to bit_width bits.
	--! Format within file: One signed integer per line (decimal).
	--!
	procedure read_file (data      : inout t_nat_array_ptr;
	                     num_lines : inout natural;
	                     bit_width : in natural;
	                     filename  : in string);

	--!
	--! Open file, get number of lines, create new memorys of type t_int_array
	--! at address data, read the file, saturate each single value to bit_width bits.
	--! Format within file: One "(real,imag)" couple per line. real and imag have to
	--! be one signed integer (decimal).
	--!
	procedure read_file_complex (data_real : inout t_int_array_ptr;
	                             data_imag : inout t_int_array_ptr;
	                             num_lines : inout natural;
	                             bit_width : in natural;
	                             filename  : in string);

	--! Open file and return the number of lines stored within.
	impure function get_num_lines(filename : in string) return natural;


	-----------------------------------------------------
	-- Obsolete functions, should no longer be used!!
	-----------------------------------------------------

	--! Read no_values lines of file and return the values as integer array. OBSOLETE.
	procedure read_file (data      : inout t_int_array;
	                     bit_width : in natural;
	                     no_values : in natural;
	                     filename  : in string);

	--! Read no_values lines of file and return the values as natural array. OBSOLETE.
	procedure read_file (data      : inout t_nat_array;
	                     bit_width : in natural;
	                     no_values : in natural;
	                     filename  : in string);


end pkg_tb_fileio;


package body pkg_tb_fileio is


	procedure read_file (data      : inout t_int_array_ptr;
	                     num_lines : inout natural;
	                     bit_width : in natural;
	                     filename  : in string) is

		file     file_handler : text open read_mode is filename;
		variable line_in      : line;
		variable line_out     : line;
		variable value        : integer;

	begin
		write(line_out, string'("Reading "));
		write(line_out, filename );
		write(line_out, string'("."));
		writeline(output, line_out);

		num_lines := get_num_lines(filename);

		deallocate(data);

		data := new t_int_array(0 to num_lines - 1);

		for i in 0 to num_lines - 1 loop

			-- read integer value from line
			readline(file_handler, line_in);
			read(line_in, value);

			-- saturate
			if value > 2 ** (bit_width - 1) - 1 then
				value := 2 ** (bit_width - 1) - 1;
			elsif value < -2 ** (bit_width - 1) then
				value := -2 ** (bit_width - 1);
			end if;

			data(i) := value;
		end loop;

	end read_file;


	procedure read_file (data      : inout t_nat_array_ptr;
	                     num_lines : inout natural;
	                     bit_width : in natural;
	                     filename  : in string) is

		file     file_handler : text open read_mode is filename;
		variable line_in      : line;
		variable line_out     : line;
		variable value        : integer;

	begin
		write(line_out, string'("Reading "));
		write(line_out, filename );
		write(line_out, string'("."));
		writeline(output, line_out);

		num_lines := get_num_lines(filename);

		deallocate(data);

		data := new t_nat_array(0 to num_lines - 1);

		for i in 0 to num_lines - 1 loop

			-- read integer value from line
			readline(file_handler, line_in);
			read(line_in, value);

			-- saturate
			if value > 2 ** bit_width - 1 then
				value := 2 ** bit_width - 1;
			end if;

			data(i) := value;
		end loop;

	end read_file;

	procedure read_file_complex (data_real : inout t_int_array_ptr;
	                             data_imag : inout t_int_array_ptr;
	                             num_lines : inout natural;
	                             bit_width : in natural;
	                             filename  : in string) is

		file     file_handler : text open read_mode is filename;
		variable line_in      : line;
		variable line_out     : line;
		variable char         : character;
		variable value        : integer;

	begin
		write(line_out, string'("Reading "));
		write(line_out, filename );
		write(line_out, string'("."));
		writeline(output, line_out);

		num_lines := get_num_lines(filename);

		deallocate(data_real);
		deallocate(data_imag);
		data_real := new t_int_array(0 to num_lines - 1);
		data_imag := new t_int_array(0 to num_lines - 1);

		for i in 0 to num_lines - 1 loop

			-- read integer value from line
			readline(file_handler, line_in);

			-- read "("
			read(line_in, char);

			-- read number
			read(line_in, value);

			-- saturate
			if value > 2 ** (bit_width - 1) - 1 then
				value := 2 ** (bit_width - 1) - 1;
			elsif value < -2 ** (bit_width - 1) then
				value := -2 ** (bit_width - 1);
			end if;

			data_real.all(i) := value;

			-- read ","
			read(line_in, char);

			-- read number
			read(line_in, value);

			-- saturate
			if value > 2 ** (bit_width - 1) - 1 then
				value := 2 ** (bit_width - 1) - 1;
			elsif value < -2 ** (bit_width - 1) then
				value := -2 ** (bit_width - 1);
			end if;

			data_imag.all(i) := value;
		end loop;

	end read_file_complex;


	impure function get_num_lines(filename : in string) return natural is
		file     file_handler : text open read_mode is filename;
		variable line_in      : line;
		variable num_lines    : natural := 0;
	begin

		while not endfile(file_handler) loop
			readline(file_handler, line_in);
			num_lines := num_lines + 1;
		end loop;

		return num_lines;
	end get_num_lines;



	-----------------------------------------------------
	-- Obsolete functions, should no longer be used!!
	-----------------------------------------------------

	procedure read_file (data      : inout t_int_array;
	                     bit_width : in natural;
	                     no_values : in natural;
	                     filename  : in string) is

		file     file_handler : text open read_mode is filename;
		variable line_in      : line;
		variable line_out     : line;
		variable value        : integer;

	begin
		write(line_out, string'("Reading "));
		write(line_out, filename );
		write(line_out, string'("."));
		writeline(output, line_out);

		for i in 0 to no_values - 1 loop

			-- read integer value from line
			readline(file_handler, line_in);
			read(line_in, value);

			-- saturate
			if value > 2 ** (bit_width - 1) - 1 then
				value := 2 ** (bit_width - 1) - 1;
			elsif value < -2 ** (bit_width - 1) then
				value := -2 ** (bit_width - 1);
			end if;

			data(i) := value;
		end loop;

	end read_file;


	procedure read_file (data      : inout t_nat_array;
	                     bit_width : in natural;
	                     no_values : in natural;
	                     filename  : in string) is

		file     file_handler : text open read_mode is filename;
		variable line_in      : line;
		variable line_out     : line;
		variable value        : natural;

	begin
		write(line_out, string'("Reading "));
		write(line_out, filename );
		write(line_out, string'("."));
		writeline(output, line_out);

		for i in 0 to no_values - 1 loop

			-- read integer value from line
			readline(file_handler, line_in);
			read(line_in, value);

			-- saturate natural
			if value > 2 ** bit_width - 1 then
				value := 2 ** bit_width - 1;
			end if;

			data(i) := value;
		end loop;

	end read_file;
end pkg_tb_fileio;
