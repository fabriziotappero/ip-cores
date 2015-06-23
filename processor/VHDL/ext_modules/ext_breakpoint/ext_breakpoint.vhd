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
-- File       : ext_breakpoint.vhd
-- Author     : Martin Delvai
-- Company    : TU Wien - Institut fr Technische Informatik
-- Created    : 2007/04/16
-- Last update: 2011-03-17
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

use work.scarts_pkg.all;
use work.scarts_core_pkg.all;
use work.pkg_breakpoint.all;


architecture behaviour of ext_breakpoint is

subtype BYTE is std_logic_vector(7 downto 0);
type register_set is array (0 to 31) of BYTE;

--signal mul_result : std_logic_vector(63 downto 0);

constant CONFIGREG_CUST : integer := 3;


type reg_type is record
  ifacereg  : register_set;
end record;


signal r, r_next : reg_type;
signal do_trap, do_trap_next : std_ulogic;
signal rstint : std_ulogic;


begin

  
comb : process(r, exti, extsel, debugo_raddr)
  variable v : reg_type;
  variable anz: integer range 7 downto 0;  
  variable index: integer range 7 downto 0;
  variable dummy_addr:std_logic_vector(31 downto 0);
begin
  -- Default Values

  do_trap_next <= '0';
  
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
  if r.ifacereg(CONFIGREG_CUST)(6 downto 3) /= "0000" then
    --Single Stepping. 
--    if pc /= s_debugo_pc then
      -- Decrement single-step counter whenever an instruction is executed.
      v.ifacereg(CONFIGREG_CUST)(6 downto 3) := std_logic_vector(UNSIGNED(r.ifacereg(CONFIGREG_CUST)(6 downto 3)) - 1);
      if v.ifacereg(CONFIGREG_CUST)(6 downto 3) = "0000" then
	    --Counter reached zero. Raise interrupt.
	    v.ifacereg(STATUSREG)(STA_INT) := '1';
      end if;
--    end if;
  elsif r.ifacereg(CONFIGREG_CUST)(7) = '1' -- Enabled
    and r.ifacereg(CONFIGREG_CUST)(2 downto 0) /= "000" then
--    --Compare breakpoint-addresses with current PC.
    anz := to_integer(UNSIGNED(r.ifacereg(CONFIGREG_CUST)(2 downto 0)));
    dummy_addr := (others => '0');
    dummy_addr(INSTR_RAM_CFG_C-1 downto 0) := debugo_raddr;

    for i in 7 downto 1 loop
      if anz >= i then 
        if v.ifacereg(4*i + 0) = dummy_addr(7 downto 0)
          and v.ifacereg(4*i + 1) = dummy_addr(15 downto 8)
          --Add the next 2 lines for 32-Bit configurations.
          and (WORD_CFG_C = 1 or v.ifacereg(4*i + 2) = dummy_addr(23 downto 16))
          and (WORD_CFG_C = 1 or v.ifacereg(4*i + 3) = dummy_addr(31 downto 24))
        then
          --Breapoint hit. Return TRAP0 as opcode.
          do_trap_next <= '1';
        end if;
      end if;
    end loop;
  end if;

--  s_debugo_pc_next <= pc;
        
  r_next <= v;
end process;


  -- Module Specific part

--  mod_specific: process (r)
--  begin  -- process mod_specific
    
-- Multiplikation von 2 32 Bit Zahlen:
--   mul_result <= (r.ifacereg(4)&r.ifacereg(5)) *(r.ifacereg(6)&r.ifacereg(7));

--   end process mod_specific;


-- Synchronous process 
  reg : process(clk)
  begin
    if rising_edge(clk) then 
      if rstint = RST_ACT then
        r.ifacereg <= (others => (others => '0'));
        do_trap <= '0';
      else           
        r <= r_next;
        do_trap <= do_trap_next;
      end if;
    end if;
  end process;


  output : process(do_trap, debugo_rdata, watchpoint_act)
  begin
    if do_trap = '1' 
    	or watchpoint_act = '1' --Watchpoints can asynchronously request generation of Trap-instructions. 
    then
      debugi_rdata <= "1110101100000000"; --TRAP0
    else
      debugi_rdata <= debugo_rdata;
    end if;
  end process;

  
end behaviour;
