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
-- Entity: 	sui
-- File:	apbsui.vhd
-- Author:	Antti Lukats, OpenChip
-- Description:	Simple User Interface
--
-- Single Peripheral containting the following:
-- Input:
--  Switches 0..31
--  Buttons 0..31
-- Output
--  LED 7 Segment, 4 digits non multiplexed, 32 digits in multiplexed mode
--  Single LED 0..31
--  Buzzer
--  Character LCD
--
-- Version 0: All functions are software assisted, IP Core has minimal
--  intelligence providing bit-bang access to all the connected hardware
--
--
--
--
--
--
--
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library openchip;
use openchip.sui.all;

--pragma translate_off
use std.textio.all;
--pragma translate_on

entity apbsui is
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
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    suii   : in  sui_in_type;
    suio   : out sui_out_type);
end;

architecture rtl of apbsui is

constant REVISION : integer := 0;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_OPENCHIP, OPENCHIP_APBSUI, 0, REVISION, pirq),
  1 => apb_iobar(paddr, pmask));

type suiregs is record
  ledreg	:  std_logic_vector(31 downto 0); -- Output Latch, single LEDs
  led7reg	:  std_logic_vector(31 downto 0); -- Output Latch, 7 Seg LEDs
  lcdreg	:  std_logic_vector(15 downto 0); -- Output Latch LCD
  buzreg	:  std_logic_vector(0 downto 0);  -- Buzzer

  sw_inreg	:  std_logic_vector(31 downto 0); -- Switches in
  btn_inreg	:  std_logic_vector(31 downto 0); -- Buttons in


  irq       	:  std_ulogic;	-- interrupt (internal), not used
end record;

signal r, rin : suiregs;

begin

  comb : process(rst, r, apbi, suii )

  variable rdata : std_logic_vector(31 downto 0);
  variable irq   : std_logic_vector(NAHBIRQ-1 downto 0);
  variable v : suiregs;



  begin
    v := r;
    v.sw_inreg := suii.switch_in;
    v.btn_inreg := suii.button_in;

    irq := (others => '0');
    --irq(pirq) := r.irq;
    v.irq := '0';
    rdata := (others => '0');

-- read/write registers

    case apbi.paddr(4 downto 2) is
    when "100" =>
      rdata(31 downto 0) := r.sw_inreg;  -- read switches
    when "101" =>
      rdata(31 downto 0) := r.btn_inreg; -- read buttons
    when others =>
    end case;

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(4 downto 2) is
      when "000" =>
	v.ledreg := apbi.pwdata(31 downto 0);
      when "001" =>
	v.led7reg := apbi.pwdata(31 downto 0);
      when "010" =>
	v.lcdreg(15 downto 0) := apbi.pwdata(15 downto 0);
      when "011" =>
	v.buzreg(0) := apbi.pwdata(0);

      when others =>
      end case;
    end if;

-- reset operation

    if rst = '0' then
      v.ledreg := (others => '0');
      v.led7reg := (others => '0');
    end if;

-- update registers

    rin <= v;

-- drive outputs

    suio.lcd_out       <= r.lcdreg(7 downto 0);
    suio.lcd_en        <= r.lcdreg(11 downto 8);
    suio.lcd_rs        <= r.lcdreg(12);
    suio.lcd_r_wn      <= r.lcdreg(13);
    suio.lcd_backlight <= r.lcdreg(14);
    suio.lcd_oe        <= r.lcdreg(15);

    suio.buzzer        <= r.buzreg(0);
    suio.led_out <= r.ledreg;



    suio.led_a_out(0)  <= r.led7reg(0);
    suio.led_b_out(0)  <= r.led7reg(1);
    suio.led_c_out(0)  <= r.led7reg(2);
    suio.led_d_out(0)  <= r.led7reg(3);
    suio.led_e_out(0)  <= r.led7reg(4);
    suio.led_f_out(0)  <= r.led7reg(5);
    suio.led_g_out(0)  <= r.led7reg(6);
    suio.led_dp_out(0) <= r.led7reg(7);

    suio.led_a_out(1)  <= r.led7reg(8);
    suio.led_b_out(1)  <= r.led7reg(9);
    suio.led_c_out(1)  <= r.led7reg(10);
    suio.led_d_out(1)  <= r.led7reg(11);
    suio.led_e_out(1)  <= r.led7reg(12);
    suio.led_f_out(1)  <= r.led7reg(13);
    suio.led_g_out(1)  <= r.led7reg(14);
    suio.led_dp_out(1) <= r.led7reg(15);

    suio.led_a_out(2)  <= r.led7reg(16);
    suio.led_b_out(2)  <= r.led7reg(17);
    suio.led_c_out(2)  <= r.led7reg(18);
    suio.led_d_out(2)  <= r.led7reg(19);
    suio.led_e_out(2)  <= r.led7reg(20);
    suio.led_f_out(2)  <= r.led7reg(21);
    suio.led_g_out(2)  <= r.led7reg(22);
    suio.led_dp_out(2) <= r.led7reg(23);

    suio.led_a_out(3)  <= r.led7reg(24);
    suio.led_b_out(3)  <= r.led7reg(25);
    suio.led_c_out(3)  <= r.led7reg(26);
    suio.led_d_out(3)  <= r.led7reg(27);
    suio.led_e_out(3)  <= r.led7reg(28);
    suio.led_f_out(3)  <= r.led7reg(29);
    suio.led_g_out(3)  <= r.led7reg(30);
    suio.led_dp_out(3) <= r.led7reg(31);






    apbo.prdata <= rdata;
    apbo.pirq <= irq;
    apbo.pindex <= pindex;

  end process;

  apbo.pconfig <= pconfig;

  regs : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process;

-- pragma translate_off
    bootmsg : report_version
    generic map ("apbsui" & tost(pindex) &
	": SUI rev " & tost(REVISION) & ", irq " & tost(pirq));
-- pragma translate_on

end;
