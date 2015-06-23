-----------------------------------------------------------------------
-- This file is part of SCARTS.
-- 
-- SCARTS is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- SCARTS is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with SCARTS.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Title      : 7 Segment Display Architecture
-- Project    : SCARTS - Scalable Processor for Embedded Applications in
--              Realtime Environment
-------------------------------------------------------------------------------
-- File       : ext_display7seg.vhd
-- Author     : Dipl. Ing. Martin Delvai
-- Company    : TU Wien - Institut fr Technische Informatik
-- Created    : 2002-04-16
-- Last update: 2009-04-29
-- Platform   : SUN Solaris
-------------------------------------------------------------------------------
-- Description:
-- Dieses Module kann zum Ansteuern eines vierstelligen 7 Segment Modules  verwendet
-- werden. Die vier Anzeigen werden gemultiplext angesteuer. 
-- Durch einen Prescaler kann man die Frequenz des weiterschaltens einsetellen.
-- Zus?zlich besitzt es noch einen 8 Bit Ausgang zum Ansteuern von z.B. LEDs 
-------------------------------------------------------------------------------
-- Copyright (c) 2002 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2002-04-16  1.0      delvai	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_basic.all;
use work.pkg_scarts.all;
use work.pkg_counter.all;

architecture behaviour of ext_counter is

subtype BYTE is std_logic_vector(7 downto 0);
type register_set is array (0 to 3) of BYTE;

constant STATUSREG_CUST : integer := 1;
constant CONFIGREG_CUST : integer := 3;

constant ZEROVALUE      : std_logic_vector(15 downto 0) := (others => '0');

constant COUNTER_BYTE0      : integer := 4;
constant COUNTER_BYTE1      : integer := 5;
constant COUNTER_BYTE2      : integer := 6;
constant COUNTER_BYTE3      : integer := 7;

type reg_type is record
  ifacereg  : register_set;
  counter   : std_logic_vector(31 downto 0);
end record;


signal r_next : reg_type;
signal r : reg_type := 
  (
    ifacereg => (others => (others => '0')),
    counter => (others => '0')
  );
  
signal rstint : std_ulogic;

begin


  comb : process(r, exti, extsel)
  variable v : reg_type;
  begin
    v := r;
  
    --schreiben
    if ((extsel = '1') and (exti.write_en = '1')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          if ((exti.byte_en(0) = '1') or (exti.byte_en(1) = '1')) then
            v.ifacereg(STATUSREG)(STA_INT) := '1';
            v.ifacereg(CONFIGREG)(CONF_INTA) :='0';
          else
            if ((exti.byte_en(2) = '1')) then
              v.ifacereg(2) := exti.data(23 downto 16);
            end if;
            if ((exti.byte_en(3) = '1')) then
              v.ifacereg(3) := exti.data(31 downto 24);
            end if;
          end if;
        when "001" =>
          if ((exti.byte_en(0) = '1')) then
            v.counter(7 downto 0) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.counter(15 downto 8) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.counter(23 downto 16) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.counter(31 downto 24) := exti.data(31 downto 24);
          end if;
        when others =>
          null;
      end case;
    end if;

    --auslesen
    exto.data <= (others => '0');
    if ((extsel = '1') and (exti.write_en = '0')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          exto.data <= r.ifacereg(3) & r.ifacereg(2) & r.ifacereg(1) & r.ifacereg(0);
        when "001" =>
          if (r.ifacereg(CONFIGREG)(CONF_ID) = '1') then
            exto.data <= MODULE_VER & MODULE_ID;
          else
            exto.data <= r.counter;
          end if;
        when others =>
          null;
      end case;
    end if;
   
    
    --berechnen der neuen status flags
    v.ifacereg(STATUSREG)(STA_LOOR) := r.ifacereg(CONFIGREG)(CONF_LOOW);
    v.ifacereg(STATUSREG)(STA_FSS) := '0';
    v.ifacereg(STATUSREG)(STA_RESH) := '0';
    v.ifacereg(STATUSREG)(STA_RESL) := '0';
    v.ifacereg(STATUSREG)(STA_BUSY) := '0';
    v.ifacereg(STATUSREG)(STA_ERR) := '0';
    v.ifacereg(STATUSREG)(STA_RDY) := '1';

    -- Output soll Defaultmassig auf eingeschalten sie 
    v.ifacereg(CONFIGREG)(CONF_OUTD) := '1';
    
    
    --soft- und hard-reset vereinen
    rstint <= not RST_ACT;
    if exti.reset = RST_ACT or r.ifacereg(CONFIGREG)(CONF_SRES) = '1' then
      rstint <= RST_ACT;
    end if;
    
    -- Interrupt
    if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) ='0' then
      v.ifacereg(STATUSREG)(STA_INT) := '0';
    end if; 
    exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);

    --module specific part
    v.counter := r.counter;
    
    if r.ifacereg(MY_CONFIGREG)(CMD_COUNT) = '1' then
      v.counter := STD_LOGIC_VECTOR(UNSIGNED(r.counter) + 1);
    elsif r.ifacereg(MY_CONFIGREG)(CMD_CLEAR) = '1' then
      v.counter := (others => '0');
    end if;
    
    r_next <= v;
  end process;

  reg : process(clk)
  begin
    if rising_edge(clk) then 
      if rstint = RST_ACT then
        r.ifacereg <= (others => (others => '0'));
        r.counter <= (others => '0');
      else
        r <= r_next;
      end if;
    end if;
  end process;

end behaviour;
