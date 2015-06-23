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
-- File       : ext_generic.vhd
-- Author     : Martin Delvai
-- Company    : TU Wien - Institut fr Technische Informatik
-- Created    : 2007/04/16
-- Last update: 2007-08-21
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

use work.pkg_basic.all;
use work.pkg_timer.all;


architecture behaviour of ext_timer is

subtype BYTE is std_logic_vector(7 downto 0);
type register_set is array (0 to 19) of BYTE;

signal clk_cnt_nxt, inst_cnt_nxt : std_logic_vector(31 downto 0);
signal clk_match_nxt, inst_match_nxt : std_logic_vector(31 downto 0);
signal start_i_nxt, start_c_nxt : std_logic;
signal stop_i_nxt, stop_c_nxt : std_logic;
signal cint_nxt, iint_nxt : std_logic;


type reg_type is record
  ifacereg  : register_set;
end record;


signal r, r_next : reg_type;
signal rstint : std_ulogic;

begin

-- Synchronous process 
reg : process(clk, rstint)
  begin
    if rstint = RST_ACT then
      for i in 0 to 19 loop
        r.ifacereg(i) <= (others => '0');
      end loop;
    elsif rising_edge(clk) then 
   
      r <= r_next;
      
    end if;
  end process;

  
comb : process(r, exti, extsel, clk_cnt_nxt, clk_match_nxt, inst_match_nxt,
               inst_cnt_nxt,  stop_c_nxt, stop_i_nxt, start_c_nxt, start_i_nxt,
               cint_nxt, iint_nxt)

  variable v : reg_type;
  variable clk_cnt_v, inst_cnt_v : std_logic_vector(31 downto 0);
  variable clk_match_v, inst_match_v : std_logic_vector(31 downto 0);
 
begin
  -- Default Values
  v := r;
 

  --berechnen der neuen status flags
  v.ifacereg(STATUSREG)(STA_LOOR) := r.ifacereg(CONFIGREG)(CONF_LOOW);
  v.ifacereg(STATUSREG)(STA_FSS)  := '0';
  v.ifacereg(STATUSREG)(STA_RESH) := '0';
  v.ifacereg(STATUSREG)(STA_RESL) := '0';
  v.ifacereg(STATUSREG)(STA_BUSY) := '0';
  v.ifacereg(STATUSREG)(STA_ERR)  := '0';
  v.ifacereg(STATUSREG)(STA_RDY)  := '1';
    
  --Merging soft- and hard-reset 
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
  

--end process;


  -- Module Specific part

 -- mod_specific: process (r)
 -- begin  -- process mod_specific

    clk_cnt_v(7 downto 0)   :=  r.ifacereg(CLK_CNT_0);
    clk_cnt_v(15 downto 8)  :=  r.ifacereg(CLK_CNT_1);
    clk_cnt_v(23 downto 16) :=  r.ifacereg(CLK_CNT_2);
    clk_cnt_v(31 downto 24) :=  r.ifacereg(CLK_CNT_3);

    clk_match_v(7 downto 0)   :=  r.ifacereg(CLK_MATCH_0);
    clk_match_v(15 downto 8)  :=  r.ifacereg(CLK_MATCH_1);
    clk_match_v(23 downto 16) :=  r.ifacereg(CLK_MATCH_2);
    clk_match_v(31 downto 24) :=  r.ifacereg(CLK_MATCH_3);

    inst_cnt_v(7 downto 0)   :=  r.ifacereg(INST_CNT_0);
    inst_cnt_v(15 downto 8)  :=  r.ifacereg(INST_CNT_1);
    inst_cnt_v(23 downto 16) :=  r.ifacereg(INST_CNT_2);
    inst_cnt_v(31 downto 24) :=  r.ifacereg(INST_CNT_3);

    inst_match_v(7 downto 0)   :=  r.ifacereg(INST_MATCH_0);
    inst_match_v(15 downto 8)  :=  r.ifacereg(INST_MATCH_1);
    inst_match_v(23 downto 16) :=  r.ifacereg(INST_MATCH_2);
    inst_match_v(31 downto 24) :=  r.ifacereg(INST_MATCH_3);

    cint_nxt <= '0';
    iint_nxt <= '0'; 
    
    start_i_nxt <= r.ifacereg(CONFIG_C)(START_I);
    start_c_nxt <= r.ifacereg(CONFIG_C)(START_C); 

    stop_i_nxt <= r.ifacereg(CONFIG_C)(STOP_I);
    stop_c_nxt <= r.ifacereg(CONFIG_C)(STOP_C); 


    clk_cnt_nxt <= (others => '0');
    inst_cnt_nxt <= (others => '0');

    clk_match_nxt <= clk_match_v;
    inst_match_nxt <= inst_match_v;
    
    
    if r.ifacereg(CONFIG_C)(START_C)='1' then 
      clk_cnt_nxt <= std_logic_vector(unsigned(clk_cnt_v) + 1); 
    end if;
    
    if r.ifacereg(CONFIG_C)(START_I)='1' then 
      inst_cnt_nxt <= std_logic_vector(unsigned(inst_cnt_v) + 1); 
    end if;

    if r.ifacereg(CONFIG_C)(STOP_C)='1' then 
      clk_cnt_nxt <= clk_cnt_v; 
    end if;
    
    if r.ifacereg(CONFIG_C)(STOP_I)='1' then 
      inst_cnt_nxt <= inst_cnt_v; 
    end if;

    if clk_cnt_v = clk_match_v and r.ifacereg(STATUS_C)(CINT) = '0' then    
      if r.ifacereg(CONFIG_C)(CMI) = '1' then
       cint_nxt <= '1';    
      end if;

      if r.ifacereg(CONFIG_C)(MCI)= '1' then
        inst_match_nxt <= inst_cnt_v;
      end if;

      start_c_nxt <= '0';
      stop_c_nxt <= '0';
      
    end if;
    
    if inst_cnt_v = inst_match_v and r.ifacereg(STATUS_C)(IINT) = '0' then    
      if r.ifacereg(CONFIG_C)(IMI) = '1' then
       iint_nxt <= '1';
      end if;

      if r.ifacereg(CONFIG_C)(MCC)= '1' then
        clk_match_nxt <= clk_cnt_v;
      end if;

      start_i_nxt <= '0';
      stop_i_nxt <= '0';
      
    end if;
       -- Module specific output
  
  v.ifacereg(CLK_CNT_0) :=     clk_cnt_nxt(7 downto 0)   ; 
  v.ifacereg(CLK_CNT_1) :=     clk_cnt_nxt(15 downto 8)  ; 
  v.ifacereg(CLK_CNT_2) :=     clk_cnt_nxt(23 downto 16) ; 
  v.ifacereg(CLK_CNT_3) :=     clk_cnt_nxt(31 downto 24) ; 
  
  v.ifacereg(CLK_MATCH_0) :=   clk_match_nxt(7 downto 0)   ; 
  v.ifacereg(CLK_MATCH_1) :=   clk_match_nxt(15 downto 8)  ; 
  v.ifacereg(CLK_MATCH_2) :=   clk_match_nxt(23 downto 16) ; 
  v.ifacereg(CLK_MATCH_3) :=   clk_match_nxt(31 downto 24) ; 
  
  v.ifacereg(INST_CNT_0) :=     inst_cnt_nxt(7 downto 0)   ; 
  v.ifacereg(INST_CNT_1) :=     inst_cnt_nxt(15 downto 8)  ; 
  v.ifacereg(INST_CNT_2) :=     inst_cnt_nxt(23 downto 16) ; 
  v.ifacereg(INST_CNT_3) :=     inst_cnt_nxt(31 downto 24) ; 
  
  v.ifacereg(INST_MATCH_0) :=     inst_match_nxt(7 downto 0)   ; 
  v.ifacereg(INST_MATCH_1) :=     inst_match_nxt(15 downto 8)  ; 
  v.ifacereg(INST_MATCH_2) :=     inst_match_nxt(23 downto 16) ; 
  v.ifacereg(INST_MATCH_3) :=     inst_match_nxt(31 downto 24) ; 
  
  v.ifacereg(CONFIG_C)(START_I) :=     start_i_nxt ;
  v.ifacereg(CONFIG_C)(START_C) :=      start_c_nxt ;
  
  v.ifacereg(CONFIG_C)(STOP_I) :=     stop_i_nxt ;
  v.ifacereg(CONFIG_C)(STOP_C) :=      stop_c_nxt ;
  
  v.ifacereg(STATUS_C)(IINT) := iint_nxt;
  v.ifacereg(STATUS_C)(CINT) := cint_nxt;
  
  v.ifacereg(STATUSREG)(STA_INT) := cint_nxt or iint_nxt;

-- Begin: Neues Interface
-- schreiben
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
          
        when "010" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(8) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(9) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(10) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(11) := exti.data(31 downto 24);
          end if;
          
        when "011" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(12) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(13) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(14) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(15) := exti.data(31 downto 24);
          end if;
          
        when "100" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(16) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(17) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(18) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(19) := exti.data(31 downto 24);
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
            exto.data <= r.ifacereg(7) & r.ifacereg(6) & r.ifacereg(5) & r.ifacereg(4);
          end if;
        when "010" =>
              exto.data <= r.ifacereg(11) & r.ifacereg(10) & r.ifacereg(9) & r.ifacereg(8);
        when "011" =>
              exto.data <= r.ifacereg(15) & r.ifacereg(14) & r.ifacereg(13) & r.ifacereg(12);
        when "100" =>
              exto.data <= r.ifacereg(19) & r.ifacereg(18) & r.ifacereg(17) & r.ifacereg(16);
        when others =>
          null;
      end case;
    end if;
-- Ende Neues Interface

  
  
  
   r_next <= v;   

end process;
  
end behaviour;
