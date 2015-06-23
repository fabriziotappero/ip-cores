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
USE work.arrayio.ALL;

ENTITY proc_reader IS

END ENTITY proc_reader;

ARCHITECTURE Imperative OF proc_reader IS

  SIGNAL sig_mem : cstr_array_type(0 TO 1023);

BEGIN  -- ARCHITECTURE Imperative

  read_var_mem : PROCESS IS
    VARIABLE mem : cstr_array_type(0 TO 1023);
  BEGIN  -- PROCESS read_mem
    init_var_array(mem, "test_input.txt");
    dump_array(mem);
    wait;
  END PROCESS read_var_mem;

END ARCHITECTURE Imperative;
