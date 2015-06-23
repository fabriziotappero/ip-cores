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

use work.scarts_pkg.all;
use work.ext_key_matrix_pkg.all;
use work.key_matrix_pkg.all;

architecture behaviour of ext_key_matrix is

subtype BYTE is std_logic_vector(7 downto 0);
type register_set is array (0 to 7) of BYTE;

constant STATUSREG_CUST : integer := 1;
constant CONFIGREG_CUST : integer := 3;

constant ZEROVALUE      : std_logic_vector(15 downto 0) := (others => '0');

constant KEYPRESSED_REG : integer := 4;
constant NOKEY : std_logic_vector(3 downto 0) := (others => '0');

type reg_type is record
  ifacereg  : register_set;
end record;


signal r_next : reg_type;
signal r : reg_type := 
  (
    ifacereg => (others => (others => '0'))
  );
  
signal rstint : std_ulogic;
signal currentKey    : std_logic_vector(3 downto 0);
signal lastKey : std_logic_vector(3 downto 0);

begin

  key_matrix_unit : key_matrix
    generic map
    (
      CLK_FREQ => CLK_FREQ,
      SCAN_TIME_INTERVAL => 100 ms,
      DEBOUNCE_TIMEOUT => 1 ms,
      SYNC_STAGES => 2,
      COLUMN_COUNT => 3,
      ROW_COUNT => 4
    )
    port map
    (
      sys_clk => clk,
      sys_res_n => exti.reset,
      columns => columns,
      rows => rows,
      key => currentKey
    );


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

    -- Output soll Defaultmassig eingeschalten sein
    v.ifacereg(CONFIGREG)(CONF_OUTD) := '1';
    
    
    --soft- und hard-reset vereinen
    rstint <= not RST_ACT;
    if exti.reset = RST_ACT or r.ifacereg(CONFIGREG)(CONF_SRES) = '1' then
      rstint <= RST_ACT;
    end if;
    
    -- Interrupt
    if r.ifacereg(CONFIGREG)(CONF_INTA) ='1' then
      v.ifacereg(STATUSREG)(STA_INT) := '0';
      v.ifacereg(CONFIGREG)(CONF_INTA) := '0';
    end if; 
    exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);

    --module specific part
    if lastKey = NOKEY and currentKey /= NOKEY then
      v.ifacereg(KEYPRESSED_REG) := (others => '0');
      v.ifacereg(KEYPRESSED_REG)(currentKey'high downto currentKey'low) := currentKey;
      v.ifacereg(STATUSREG)(STA_INT) := '1';
    end if;
    
    r_next <= v;
  end process;

  reg : process(clk)
  begin
    if rising_edge(clk) then 
      if rstint = RST_ACT then
        r.ifacereg <= (others => (others => '0'));
        lastKey <= NOKEY;
      else
        r <= r_next;
        lastKey <= currentKey;
      end if;
    end if;
  end process;

end behaviour;
