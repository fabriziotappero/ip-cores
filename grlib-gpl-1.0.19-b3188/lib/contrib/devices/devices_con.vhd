----------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2004 GAISLER RESEARCH
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
-----------------------------------------------------------------------------
-- Entity: 	devices
-- File:	devices.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Vendor and devices id's for amba plug&play
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on

package devices_con is

-- Vendor code

  constant VENDOR_CONTRIB   : amba_vendor_type := 16#07#;

-- Dummy ID's

  constant CONTRIB_CORE1        : amba_device_type := 16#001#;
  constant CONTRIB_CORE2        : amba_device_type := 16#002#;

-- pragma translate_off

  constant CONTRIB_DESC : vendor_description := "Various contributions   ";

  constant contrib_device_table : device_table_type := (
   CONTRIB_CORE1    => "Contributed core 1             ",
   CONTRIB_CORE2    => "Contributed core 2             ",
   others           => "Unknown Device                 ");

   constant contrib_lib : vendor_library_type := (
     vendorid 	     => VENDOR_CONTRIB,
     vendordesc      => CONTRIB_DESC,
     device_table    => contrib_device_table
   );

-- pragma translate_on

end;
