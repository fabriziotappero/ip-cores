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

ENTITY sign_reader IS

END ENTITY sign_reader;

ARCHITECTURE Imperative OF sign_reader IS

  SIGNAL sig_mem : cstr_array_type(0 TO 1023) := init_cstr(1024, "test_input.txt");

BEGIN  -- ARCHITECTURE Imperative

  dump_sig_mem : PROCESS IS
  BEGIN  -- PROCESS read_mem
    dump_array(sig_mem);
    wait;
  END PROCESS dump_sig_mem;

END ARCHITECTURE Imperative;
