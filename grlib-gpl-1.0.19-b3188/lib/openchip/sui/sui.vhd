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
-- package: 	sui
-- File:	sui.vhd
-- Author:	Antti Lukats, OpenChip
-- Description:	Simple User Interface types and components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;

package sui is

type sui_in_type is record
  post_code_in 	: std_logic_vector(7 downto 0);
  switch_in  	: std_logic_vector(31 downto 0);
  button_in  	: std_logic_vector(31 downto 0);

  lcd_in   	: std_logic_vector(7 downto 0);
end record;

type sui_out_type is record
  led_a_out   	: std_logic_vector(3 downto 0);
  led_b_out   	: std_logic_vector(3 downto 0);
  led_c_out   	: std_logic_vector(3 downto 0);
  led_d_out   	: std_logic_vector(3 downto 0);
  led_e_out   	: std_logic_vector(3 downto 0);
  led_f_out   	: std_logic_vector(3 downto 0);
  led_g_out   	: std_logic_vector(3 downto 0);
  led_dp_out   	: std_logic_vector(3 downto 0);
  led_com_out  	: std_logic_vector(31 downto 0);

  led_out   	: std_logic_vector(31 downto 0);

  lcd_out   	: std_logic_vector(7 downto 0);
  lcd_oe   	: std_logic;  
  lcd_en   	: std_logic_vector(3 downto 0);
  lcd_rs   	: std_logic;  
  lcd_r_wn   	: std_logic;  
  lcd_backlight	: std_logic;  


  buzzer   	: std_logic;
end record;

component apbsui
  generic (
    pindex  : integer := 0; 
    paddr   : integer := 0;
    pmask   : integer := 16#fff#;
    pirq    : integer := 0;
-- active level for Segment LED segments
    led7act : integer := 1;
-- active level for single LED's
    ledact  : integer := 1);

  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    apbi    : in  apb_slv_in_type;
    apbo    : out apb_slv_out_type;
    suii    : in  sui_in_type;
    suio    : out sui_out_type);
end component; 

end;
