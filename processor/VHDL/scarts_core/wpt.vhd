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
-- Title      : Template for Extension Module
-- Project    : SCARTS - Scalable Processor for Embedded Applications in
--              Realtime Environment
-------------------------------------------------------------------------------
-- File       : ext_watchpoint.vhd
-- Author     : Martin Delvai
-- Company    : TU Wien - Institut fr Technische Informatik
-- Created    : 2007/04/16
-- Last update: 2011-03-20
-- Platform   : Linux
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-04-16  1.0      delvai	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

entity ext_watchpoint is
  generic (
    CONF : scarts_conf_type);
  port(
    -- SCARTS Interface
    clk                     : IN  std_logic;
    extsel                  : in std_ulogic;
    exti                    : in  module_in_type;
    exto                    : out module_out_type;
    -- Modul specific interface (= Pins) 
    read_en : in std_ulogic;
    --    write_en : in std_ulogic;
    hi_addr : in std_logic_vector(CONF.word_size-1 downto 15) --lower 15 bits in exti.addr
	);
end ext_watchpoint;


architecture behaviour of ext_watchpoint is

subtype BYTE is std_logic_vector(7 downto 0);
type register_set is array (0 to 31) of BYTE;


constant CONFIGREG_CUST : integer := 3;
constant REG_ACCESS_ADDR : integer := 4; -- to 7
constant REG_ADDR0 : integer := 8; 
constant REG_MASK0 : integer := 12; 


constant C_CONF_R0     : integer := 0;
constant C_CONF_W0     : integer := 1;
constant C_CONF_R1     : integer := 2;
constant C_CONF_W1     : integer := 3;
constant C_CONF_R2     : integer := 4;
constant C_CONF_W2     : integer := 5;



type reg_type is record
  ifacereg  : register_set;
end record;


signal r, r_next : reg_type;
signal rstint : std_ulogic;


begin

  
comb : process(r, exti, extsel, hi_addr, read_en)
  variable v : reg_type;
  variable index: integer range 7 downto 0;
  variable dummy_addr:std_logic_vector(31 downto 0);
  variable access_addr, addr, mask: std_logic_vector(CONF.word_size-1 downto 0);
begin
  -- Default Values
  v := r;
  index := to_integer(unsigned(exti.addr(4 downto 2)));
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
        when others =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(index*4) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(index*4+1) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(index*4+2) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(index*4+3) := exti.data(31 downto 24);
          end if;
        --when others =>
          --null;
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
            exto.data <= r.ifacereg(index*4+3) & r.ifacereg(index*4+2) 
            	& r.ifacereg(index*4+1) & r.ifacereg(index*4);
          end if;
        when others =>
            exto.data <= r.ifacereg(index*4+3) & r.ifacereg(index*4+2) 
            	& r.ifacereg(index*4+1) & r.ifacereg(index*4);
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
    
    --Interrupt Behandlung 
    if r.ifacereg(CONFIGREG)(CONF_INTA) = '1' then
      v.ifacereg(STATUSREG)(STA_INT)   := '0';
      v.ifacereg(CONFIGREG)(CONF_INTA) := '0';
    end if;

    exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);

  -- Module Specific part
	access_addr := hi_addr & exti.addr;
	
    for i in 2 downto 0 loop
	    if CONF.word_size = 16 then
			addr := r.ifacereg(REG_ADDR0+i*8+1) & r.ifacereg(REG_ADDR0+i*8); 
			mask := r.ifacereg(REG_MASK0+i*8+1) & r.ifacereg(REG_MASK0+i*8); 
		else
			addr := r.ifacereg(REG_ADDR0+i*8+3) & r.ifacereg(REG_ADDR0+i*8+2) 
					& r.ifacereg(REG_ADDR0+i*8+1) & r.ifacereg(REG_ADDR0+i*8);
			mask := r.ifacereg(REG_MASK0+i*8+3) & r.ifacereg(REG_MASK0+i*8+2) 
					& r.ifacereg(REG_MASK0+i*8+1) & r.ifacereg(REG_MASK0+i*8); 
		end if;	
	
		if ((access_addr or mask) = (addr or mask)) then
			if (read_en = '1' and r.ifacereg(CONFIGREG_CUST)(C_CONF_R0 + i*2) = '1')
				or (exti.write_en = '1' and r.ifacereg(CONFIGREG_CUST)(C_CONF_W0 + i*2) = '1')
			then
				v.ifacereg(STATUSREG)(STA_INT) := '1';
				v.ifacereg(REG_ACCESS_ADDR) := access_addr(7 downto 0);
				v.ifacereg(REG_ACCESS_ADDR+1) := access_addr(15 downto 8);
				v.ifacereg(REG_ACCESS_ADDR+2) := access_addr(23 downto 16);
				v.ifacereg(REG_ACCESS_ADDR+3) := access_addr(31 downto 24);
			end if;
      	end if;
	end loop;    
--   end process mod_specific;
              
  r_next <= v;
end process;



-- Synchronous process 
  reg : process(clk)
  begin
    if rising_edge(clk) then 
      if rstint = RST_ACT then
        r.ifacereg <= (others => (others => '0'));
      else           
        r <= r_next;
      end if;
    end if;
  end process;



  
end behaviour;
