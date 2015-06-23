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


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY string_issue IS
  
  GENERIC (
    filename_1 : STRING := "";
    filename_2 : STRING := "");

END ENTITY string_issue;

ARCHITECTURE Behavioral OF string_issue IS

  TYPE fname_array IS ARRAY(0 TO 1) OF STRING(1 TO 100);

  SIGNAL fnames : fname_array := (filename_1, filename_2);

BEGIN  -- ARCHITECTURE Behavioral

END ARCHITECTURE Behavioral;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_issue IS
END ENTITY tb_issue;

ARCHITECTURE Structural OF tb_issue IS

  COMPONENT string_issue IS
    
    GENERIC (
      filename_1 : STRING := "";
      filename_2 : STRING := "");

  END COMPONENT string_issue;

  BEGIN  -- ARCHITECTURE Structural

    SI1 : string_issue
      GENERIC MAP (
        filename_1 => "filename 1",
        filename_2 => "filename 2");

  END ARCHITECTURE Structural;
