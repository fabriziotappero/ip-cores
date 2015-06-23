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
-- Author:	Antti Lukats, OpenChip
-- Description:	Vendor and devices id's for amba plug&play
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;

-- pragma translate_off
use std.textio.all;
-- pragma translate_on

package devices_ocp is

-- Vendor code

  constant VENDOR_OPENCHIP      : amba_vendor_type := 16#06#;

-- OpenChip ID's

  constant OPENCHIP_APBGPIO     : amba_device_type := 16#001#;
  constant OPENCHIP_APBI2C      : amba_device_type := 16#002#;
  constant OPENCHIP_APBSPI      : amba_device_type := 16#003#;
  constant OPENCHIP_APBCHARLCD  : amba_device_type := 16#004#;
  constant OPENCHIP_APBPWM      : amba_device_type := 16#005#;
  constant OPENCHIP_APBPS2      : amba_device_type := 16#006#;
  constant OPENCHIP_APBMMCSD    : amba_device_type := 16#007#;
  constant OPENCHIP_APBNAND     : amba_device_type := 16#008#;
  constant OPENCHIP_APBLPC      : amba_device_type := 16#009#;
  constant OPENCHIP_APBCF       : amba_device_type := 16#00A#;
  constant OPENCHIP_APBSYSACE   : amba_device_type := 16#00B#;
  constant OPENCHIP_APB1WIRE    : amba_device_type := 16#00C#;
  constant OPENCHIP_APBJTAG     : amba_device_type := 16#00D#;
  constant OPENCHIP_APBSUI      : amba_device_type := 16#00E#;



-- pragma translate_off

  constant OPENCHIP_DESC : vendor_description := "OpenChip                ";

  constant openchip_device_table : device_table_type := (
    OPENCHIP_APBGPIO    => "APB General Purpose IO         ",
    OPENCHIP_APBI2C     => "APB I2C Interface              ",
    OPENCHIP_APBSPI     => "APB SPI Interface              ",
    OPENCHIP_APBCHARLCD => "APB Character LCD              ",
    OPENCHIP_APBPWM     => "APB PWM                        ",
    OPENCHIP_APBPS2     => "APB PS/2 Interface             ",
    OPENCHIP_APBMMCSD   => "APB MMC/SD Card Interface      ",
    OPENCHIP_APBNAND    => "APB NAND(SmartMedia) Interface ",
    OPENCHIP_APBLPC     => "APB LPC Interface              ",
    OPENCHIP_APBCF      => "APB CompactFlash (IDE)         ",
    OPENCHIP_APBSYSACE  => "APB SystemACE Interface        ",
    OPENCHIP_APB1WIRE   => "APB 1-Wire Interface           ",
    OPENCHIP_APBJTAG    => "APB JTAG TAP Master            ",
    OPENCHIP_APBSUI     => "APB Simple User Interface      ",

    others              => "Unknown Device                 ");

  constant openchip_lib : vendor_library_type := (
    vendorid 	        => VENDOR_OPENCHIP,
    vendordesc          => OPENCHIP_DESC,
    device_table        => openchip_device_table
  );

-- pragma translate_on

end;
