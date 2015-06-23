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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

entity scarts_prog is
  generic (
    CONF : scarts_conf_type);
  port (
    clk     : in  std_ulogic;
    extrst  : in  std_ulogic;
    progrst : out std_ulogic;
    hold    : in  std_ulogic;
    extsel  : in  std_ulogic;
    exti    : in  module_in_type;
    exto    : out module_out_type;

    instrsrc    : out std_ulogic;
    prupdate    : out std_ulogic;
    praddr      : out std_logic_vector(CONF.instr_ram_size-1 downto 0);
    prdata      : out INSTR);
end scarts_prog;

architecture behaviour of scarts_prog is

constant WORD_W : natural := CONF.word_size;
subtype WORD is std_logic_vector(WORD_W-1 downto 0);

subtype BYTE is std_logic_vector(7 downto 0);
type register_set is array (0 to 9) of BYTE;


constant STATUSREG_CUST : integer := 1;
constant CONFIGREG_CUST : integer := 3;

constant PR_ADDR_0 :integer := 4;
constant PR_ADDR_1 :integer := 5;
constant PR_ADDR_2 :integer := 6;
constant PR_ADDR_3 :integer := 7;

constant PR_DATA_0 :integer := 8;
constant PR_DATA_1 :integer := 9;


type reg_type is record
  ifacereg  : register_set;
end record;


signal r_next : reg_type;
signal r : reg_type := 
  (
    ifacereg => (others => (others => '0'))
  );

begin

  comb : process(r, extrst, exti, extsel)
  variable v : reg_type;
  variable pr_addr_v, pr_addr_new_v : WORD;
  
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
            v.ifacereg(4) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(5) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            if CONF.word_size = 32 then
              v.ifacereg(6) := exti.data(23 downto 16);
            end if;
          end if;
          if ((exti.byte_en(3) = '1')) then
            if CONF.word_size = 32 then
              v.ifacereg(7) := exti.data(31 downto 24);
            end if;
          end if;
        when "010" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(8) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(9) := exti.data(15 downto 8);
          end if;
        when others =>
          null;
      end case;
    end if;
    
    
    --auslesen
    if CONF.word_size = 32 then
    exto.data <= (others => '0');
    if ((extsel = '1') and (exti.write_en = '0')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          exto.data <= r.ifacereg(3) & r.ifacereg(2) & r.ifacereg(1) & r.ifacereg(0);
        when "001" =>
          if (r.ifacereg(CONFIGREG)(CONF_ID) = '1') then
            exto.data <= MODULE_VER & MODULE_ID;
          else
            if CONF.word_size = 32 then
              exto.data <= r.ifacereg(7) & r.ifacereg(6) & r.ifacereg(5) & r.ifacereg(4);
            else
              exto.data <= "00000000"    & "00000000"    & r.ifacereg(5) & r.ifacereg(4);
            end if;
          end if;
        when "010" =>
          exto.data <= "00000000" & "00000000" & r.ifacereg(9) & r.ifacereg(8);
        when others =>
          null;
      end case;
    end if;

      exto.data <= (others => '0');
      if ((extsel = '1') and (exti.write_en = '0')) then
        case exti.addr(4 downto 1) is
          when "0000" =>
            exto.data(15 downto 0) <= r.ifacereg(1) & r.ifacereg(0);
          when "0001" =>
            exto.data(15 downto 0) <= r.ifacereg(3) & r.ifacereg(2);
          when "0010" =>
            if (r.ifacereg(CONFIGREG)(CONF_ID) = '1') then
              exto.data(15 downto 0) <= MODULE_ID;
            else
              exto.data(15 downto 0) <= r.ifacereg(5) & r.ifacereg(4);
            end if;
          when "0011" =>
            if (r.ifacereg(CONFIGREG)(CONF_ID) = '1') then
              exto.data(15 downto 0) <= MODULE_VER;
            else
              exto.data(15 downto 0) <= r.ifacereg(7) & r.ifacereg(6);
            end if;
          when "0100" =>
            exto.data(15 downto 0) <= r.ifacereg(9) & r.ifacereg(8);
          when others =>
            null;
        end case;
      end if;
    end if;
    
    --berechnen der neuen status flags
    v.ifacereg(STATUSREG)(STA_LOOR) := r.ifacereg(CONFIGREG)(CONF_LOOW);
    v.ifacereg(STATUSREG)(STA_FSS) := '0';
    v.ifacereg(STATUSREG)(STA_RESH) := '0';
    v.ifacereg(STATUSREG)(STA_RESL) := '0';
    v.ifacereg(STATUSREG)(STA_BUSY) := '0';
    v.ifacereg(STATUSREG)(STA_ERR) := '0';
    v.ifacereg(STATUSREG)(STA_RDY) := '1';
  --  v.ifacereg(STATUSREG)(STA_INT) := '0';

--    if exti.extaddr(2) = '1' then
--      v.ifacereg(STATUSREG)(STA_ERR) := '1';
--      v.ifacereg(STATUSREG)(STA_INT) := '1';
--      v.ifacereg(CONFIGREG)(CONF_INTA):= '0';
--    end if;

    if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) ='1' then
      v.ifacereg(STATUSREG)(STA_INT) := '0';
    end if; 
    exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);


    --module specific part
    pr_addr_v(7 downto 0) := r.ifacereg(PR_ADDR_0);
    pr_addr_v(15 downto 8) := r.ifacereg(PR_ADDR_1);
    if CONF.word_size = 32 then
      pr_addr_v(WORD_W-9 downto WORD_W-16) := r.ifacereg(PR_ADDR_2);
      pr_addr_v(WORD_W-1 downto WORD_W-8) := r.ifacereg(PR_ADDR_3);
    end if;
	  pr_addr_new_v := pr_addr_v;
    
    if r.ifacereg(CONFIGREG_CUST)(CONF_PREXE) = PR_UPDATE then
      v.ifacereg(CONFIGREG_CUST)(CONF_PREXE) := not PR_UPDATE;
      pr_addr_new_v := std_logic_vector(unsigned(pr_addr_v) + 1);
    end if;
    
    v.ifacereg(PR_ADDR_0) :=   pr_addr_new_v(7 downto 0);
	  v.ifacereg(PR_ADDR_1) :=   pr_addr_new_v(15 downto 8);
    if CONF.word_size = 32 then
      v.ifacereg(PR_ADDR_2) :=   pr_addr_new_v(WORD_W-9 downto WORD_W-16);
      v.ifacereg(PR_ADDR_3) :=   pr_addr_new_v(WORD_W-1 downto WORD_W-8);
    end if;

    --soft- und hard-reset vereinen
    progrst <= not RST_ACT;
    if extrst = RST_ACT or r.ifacereg(CONFIGREG_CUST)(CONF_CLR) = '1' then
      progrst <= RST_ACT;
      v.ifacereg(CONFIGREG_CUST)(CONF_CLR) := '0';
    end if;
    
    -- output
    instrsrc <= r.ifacereg(CONFIGREG_CUST)(CONF_INSTRSRC);
    prupdate <= r.ifacereg(CONFIGREG_CUST)(CONF_PREXE);

    praddr <= pr_addr_v(CONF.instr_ram_size-1 downto 0);

    prdata(7 downto 0) <= r.ifacereg(PR_DATA_1);
    prdata(15 downto 8) <= r.ifacereg(PR_DATA_0);

    r_next <= v;
  end process;

  reg : process(clk)--, extrst)
  begin
    if rising_edge(clk) then 
      if extrst = RST_ACT then
        r.ifacereg <= (others => (others => '0'));
      else
        if (hold = not HOLD_ACT) then
          r <= r_next;
        end if;
      end if;
    end if;
  end process;

end behaviour;
