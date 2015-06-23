----------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2007 GAISLER RESEARCH
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
-----------------------------------------------------------------------------
-- Package: 	components
-- File:	components.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Component declaration of Hynix RAM
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.HY5PS121621F_PACK.all;

package components is

component HY5PS121621F
  generic (
     TimingCheckFlag : boolean := TRUE;
     PUSCheckFlag : boolean := FALSE;
     Part_Number : PART_NUM_TYPE := B400);
  Port (  DQ    :  inout   std_logic_vector(15 downto 0) := (others => 'Z');
          LDQS  :  inout   std_logic := 'Z';
          LDQSB :  inout   std_logic := 'Z';
          UDQS  :  inout   std_logic := 'Z';
          UDQSB :  inout   std_logic := 'Z';
          LDM   :  in      std_logic;
          WEB   :  in      std_logic;
          CASB  :  in      std_logic;
          RASB  :  in      std_logic;
          CSB   :  in      std_logic;
          BA    :  in      std_logic_vector(1 downto 0);
          ADDR  :  in      std_logic_vector(12 downto 0);
          CKE   :  in      std_logic;
          CLK   :  in      std_logic;
          CLKB  :  in      std_logic;
          UDM   :  in      std_logic );
End component;

end;

-- pragma translate_on
