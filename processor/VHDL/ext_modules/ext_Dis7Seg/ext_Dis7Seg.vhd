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
-- Last update: 2011-03-24
-- Platform   : SUN Solaris
-------------------------------------------------------------------------------
-- Description:
-- This module can be used for controlling a multi-digit sevensegment display.
-- The digits can be controlled in parallel or can be multipled with an
-- adjustable prescaler.
-------------------------------------------------------------------------------
-- Copyright (c) 2011
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2002-04-16  1.0      delvai	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_pkg.all;
use work.pkg_dis7seg.all;

architecture behaviour of ext_Dis7Seg is

subtype byte is std_logic_vector(7 downto 0);
subtype nibble is std_logic_vector(3 downto 0);
type register_set is array (0 to 7) of byte;
type digit_data_t is array (DIGIT_COUNT-1 downto 0) of nibble;

constant STATUSREG_CUST : integer := 1;
constant CONFIGREG_CUST : integer := 3;

constant ZEROVALUE      : std_logic_vector(15 downto 0) := (others => '0');
constant PRESCALE_VALUE : std_logic_vector(15 downto 0) := (others => '1');

constant PRESCALER_LOW      : integer := 4;
constant PRESCALER_HIGH     : integer := 5;
constant CMD_REG            : integer := 6;
constant VALUE_REG          : integer := 7;

constant CMD_SETVALUE : std_logic_vector(1 downto 0) := "01";
constant CMD_SETDOT   : std_logic_vector(1 downto 0) := "10";
constant CMD_GETVALUE : std_logic_vector(1 downto 0) := "11";

type reg_type is record
  ifacereg   : register_set;
  digit_data : digit_data_t;
  digit_out  : digit_vector_t(DIGIT_COUNT-1 downto 0);
end record;


signal r_next : reg_type;
signal r : reg_type := 
  (
    ifacereg => ((PRESCALER_LOW) => (others => '1'), 
                (PRESCALER_HIGH) => (others => '1'), 
                others => (others => '0')),
    digit_data => (others => (others => '0')),
    digit_out  => (others => (others => '1'))
  );
  
signal rstint : std_ulogic;

begin


  comb : process(r, exti, extsel)
    variable v : reg_type;
    variable v_digit_index : integer range 0 to DIGIT_COUNT-1;
  begin
    v := r;
        
    -- write memory mapped addresses
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
            v.ifacereg(4) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(5) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(6) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(7) := exti.data(31 downto 24);
          end if;
        when others =>
          null;
      end case;
    end if;
    
    -- read memory mapped addresses
    exto.data <= (others => '0');
    if ((extsel = '1') and (exti.write_en = '0')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          exto.data <= r.ifacereg(3) & r.ifacereg(2) & r.ifacereg(1) & r.ifacereg(0);
        when "001" =>
          if (r.ifacereg(CONFIGREG)(CONF_ID) = '1') then
            exto.data <= MODULE_VER & MODULE_ID;
          else
            exto.data <= r.ifacereg(7) & r.ifacereg(6) & r.ifacereg(5) & r.ifacereg(4);
          end if;
        when others =>
          null;
      end case;
    end if;
   
    -- compute status flags
    v.ifacereg(STATUSREG)(STA_LOOR) := r.ifacereg(CONFIGREG)(CONF_LOOW);
    v.ifacereg(STATUSREG)(STA_FSS) := '0';
    v.ifacereg(STATUSREG)(STA_RESH) := '0';
    v.ifacereg(STATUSREG)(STA_RESL) := '0';
    v.ifacereg(STATUSREG)(STA_BUSY) := '0';
    v.ifacereg(STATUSREG)(STA_ERR) := '0';
    v.ifacereg(STATUSREG)(STA_RDY) := '1';

    -- set output enabled (default)
    v.ifacereg(CONFIGREG)(CONF_OUTD) := '1';
    
    -- module specific part
    DisEna <=  r.ifacereg(CONFIGREG)(CONF_OUTD);

    v_digit_index := to_integer(unsigned(r.ifacereg(CMD_REG)(5 downto 0)));

    if v_digit_index < DIGIT_COUNT then
      case r.ifacereg(CMD_REG)(7 downto 6) is
        when CMD_SETVALUE =>
          v.digit_data(v_digit_index) := r.ifacereg(VALUE_REG)(3 downto 0);
          v.digit_out(v_digit_index) := bin2digit(r.ifacereg(VALUE_REG)(3 downto 0));
        when CMD_GETVALUE =>
          v.ifacereg(VALUE_REG) := "0000" & v.digit_data(v_digit_index);
        when others => null;
      end case;
    end if;
    
    -- combine soft- and hard-reset
    rstint <= not RST_ACT;
    if exti.reset = RST_ACT or r.ifacereg(CONFIGREG)(CONF_SRES) = '1' then
      rstint <= RST_ACT;
    end if;
    
    -- reset interrupt
    if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) ='0' then
      v.ifacereg(STATUSREG)(STA_INT) := '0';
    end if; 
    exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);

    r_next <= v;
  end process;


  muliplexed_7seg: if MULTIPLEXED = 1 generate

    signal sel, sel_next               : integer range 0 to DIGIT_COUNT-1;
    signal count, count_next           : std_logic_vector(15 downto 0);
    
  begin
    
    process (r, count, sel)
    begin  -- process
		sel_next <= sel;
      if count = ZEROVALUE then
        count_next(7 downto 0) <= r.ifacereg(PRESCALER_LOW);
        count_next(15 downto 8) <= r.ifacereg(PRESCALER_HIGH);
        if sel = DIGIT_COUNT-1 then
          sel_next <= 0;
        else
          sel_next <= sel + 1;
        end if;
      else
        count_next <= std_logic_vector(unsigned(count) - 1); 
      end if;
    end process;

    reg : process(clk)
    begin
      if rising_edge(clk) then 
        if rstint = RST_ACT then
          count <= (others => '0');
          sel <= 0;        
        else
          count <= count_next;
          sel <= sel_next;        
        end if;
      end if;
    end process;
    
    digits(0) <= r.digit_out(sel);
	 
    process (sel)
    begin
      PIN_select <= (others => '0');
      PIN_select(sel) <= '1';
    end process;
	 
  end generate muliplexed_7seg;
  

  parallel_7seg: if MULTIPLEXED = 0 generate
    PIN_select <= (others => '0');
    digits <= r.digit_out;
  end generate parallel_7seg; 

  
  reg : process(clk)
  begin
    if rising_edge(clk) then 
      if rstint = RST_ACT then
        r.ifacereg <= ((PRESCALER_LOW) => (others => '1'), 
                    (PRESCALER_HIGH) => (others => '1'), 
                    others => (others => '0'));
        r.digit_data <= (others => (others => '0'));
        r.digit_out  <= (others => (others => '1'));
      else
        r <= r_next;
      end if;
    end if;
  end process;


end behaviour;
