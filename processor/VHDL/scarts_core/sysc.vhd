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

entity scarts_sysc is
  generic (
    CONF : scarts_conf_type);
  port (
    clk     : in  std_ulogic;
    extrst  : in  std_ulogic;
    sysrst  : out std_ulogic;
    hold    : in  std_ulogic;
    cpu_halt : out std_ulogic;
    extsel  : in std_ulogic;
    exti    : in  module_in_type;
    exto    : out module_out_type;

    staen       : in  std_ulogic;
    stactrl     : in  STACTRL;
    staflag     : in  std_logic_vector(ALUFLAG_W-1 downto 0);
    interruptin : in  std_logic_vector(15 downto 0);
    fptrwnew    : in  std_logic_vector(CONF.word_size-1 downto 0);
    fptrxnew    : in  std_logic_vector(CONF.word_size-1 downto 0);
    fptrynew    : in  std_logic_vector(CONF.word_size-1 downto 0);
    fptrznew    : in  std_logic_vector(CONF.word_size-1 downto 0);

    condflag    : out std_ulogic;
    carryflag   : out std_ulogic;
    interruptnr : out std_logic_vector(EXCADDR_W-2 downto 0);
    intcmd      : out std_ulogic;
    fptrw       : out std_logic_vector(CONF.word_size-1 downto 0);
    fptrx       : out std_logic_vector(CONF.word_size-1 downto 0);
    fptry       : out std_logic_vector(CONF.word_size-1 downto 0);
    fptrz       : out std_logic_vector(CONF.word_size-1 downto 0));
end scarts_sysc;

architecture behaviour of scarts_sysc is

  constant WORD_W : natural := CONF.word_size;
  subtype WORD is std_logic_vector(WORD_W-1 downto 0);

  subtype BYTE is std_logic_vector(7 downto 0);
  type register_set is array (0 to 24) of BYTE;
  
  constant STATUSREG_CUST : integer := 1;
  constant CONFIGREG_CUST : integer := 3;
  
  constant INT_PROT_LOW   : integer := 4;
  constant INT_PROT_HIGH  : integer := 5;
  
  constant INT_MASK_LOW   : integer := 6;
  constant INT_MASK_HIGH  : integer := 7;
  
  constant FPTRW_0        : integer := 8;
  constant FPTRW_1        : integer := 9;
  constant FPTRW_2        : integer := 10;
  constant FPTRW_3        : integer := 11;
  
  constant FPTRX_0        : integer := 12;
  constant FPTRX_1        : integer := 13;
  constant FPTRX_2        : integer := 14;
  constant FPTRX_3        : integer := 15;
  
  constant FPTRY_0        : integer := 16;
  constant FPTRY_1        : integer := 17;
  constant FPTRY_2        : integer := 18;
  constant FPTRY_3        : integer := 19;
  
  constant FPTRZ_0        : integer := 20;
  constant FPTRZ_1        : integer := 21;
  constant FPTRZ_2        : integer := 22;
  constant FPTRZ_3        : integer := 23;
  
  constant STATUSREG_CUST_SAVE : integer := 24;
  
  type reg_type is record
    ifacereg      : register_set;
    tmp_int_prot  : std_logic_vector(15 downto 0);
    savedsr       : std_ulogic;
    gie_backup    : std_logic;
    nmiact        : std_ulogic;
  end record;


  signal r_next : reg_type;								 
  signal r : reg_type := (
      ifacereg      => (INT_MASK_LOW => (others => '1'), INT_MASK_HIGH => (others => '1'), others => (others => '0')),
      tmp_int_prot  => (others => '0'),
      savedsr       => '0',
      gie_backup    => '0',
      nmiact        => '0');

  signal rstint : std_ulogic;
  signal int_hold : std_ulogic;

begin

  comb : process(r, staen, stactrl, staflag, interruptin, fptrwnew, fptrxnew, fptrynew, fptrznew,
                 exti, extsel, rstint, extrst, hold, int_hold)
  variable v : reg_type;
  variable v_interruptnr : std_logic_vector(EXCADDR_W-2 downto 0);
  variable v_intcmd : std_ulogic;
  begin
    v := r;
    v.ifacereg(FPTRW_0) := fptrwnew(7 downto 0);
    v.ifacereg(FPTRX_0) := fptrxnew(7 downto 0);
    v.ifacereg(FPTRY_0) := fptrynew(7 downto 0);
    v.ifacereg(FPTRZ_0) := fptrznew(7 downto 0);

    v.ifacereg(FPTRW_1) := fptrwnew(15 downto 8);
    v.ifacereg(FPTRX_1) := fptrxnew(15 downto 8);
    v.ifacereg(FPTRY_1) := fptrynew(15 downto 8);
    v.ifacereg(FPTRZ_1) := fptrznew(15 downto 8);

    if CONF.word_size = 32 then
      v.ifacereg(FPTRW_2) := fptrwnew(WORD_W-9 downto WORD_W-16);
      v.ifacereg(FPTRX_2) := fptrxnew(WORD_W-9 downto WORD_W-16);
      v.ifacereg(FPTRY_2) := fptrynew(WORD_W-9 downto WORD_W-16);
      v.ifacereg(FPTRZ_2) := fptrznew(WORD_W-9 downto WORD_W-16);
  
      v.ifacereg(FPTRW_3) := fptrwnew(WORD_W-1 downto WORD_W-8);
      v.ifacereg(FPTRX_3) := fptrxnew(WORD_W-1 downto WORD_W-8);
      v.ifacereg(FPTRY_3) := fptrynew(WORD_W-1 downto WORD_W-8);
      v.ifacereg(FPTRZ_3) := fptrznew(WORD_W-1 downto WORD_W-8);
    end if;

   --interrupts protokollieren
--    v.tmp_int_prot := interruptin;
--    v.ifacereg(INT_PROT_LOW) := r.ifacereg(INT_PROT_LOW) or interruptin(7 downto 0) or r.tmp_int_prot(7 downto 0);
--    v.ifacereg(INT_PROT_HIGH) := r.ifacereg(INT_PROT_HIGH) or interruptin(15 downto 8) or r.tmp_int_prot(15 downto 8);

    
    -- detect positve edge on interrupt lines and set flag in protocol register
    v.tmp_int_prot := interruptin;
    v.ifacereg(INT_PROT_LOW) := r.ifacereg(INT_PROT_LOW) or ((not r.tmp_int_prot(7 downto 0)) and interruptin(7 downto 0));
    v.ifacereg(INT_PROT_HIGH) := r.ifacereg(INT_PROT_HIGH) or ((not r.tmp_int_prot(15 downto 8)) and interruptin(15 downto 8));
    
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
            v.ifacereg(4) := v.ifacereg(4) xor exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(5) := v.ifacereg(5) xor exti.data(15 downto 8);
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
          if CONF.word_size = 32 then
            if ((exti.byte_en(2) = '1')) then
              v.ifacereg(10) := exti.data(23 downto 16);
            end if;
            if ((exti.byte_en(3) = '1')) then
              v.ifacereg(11) := exti.data(31 downto 24);
            end if;
          end if;
        when "011" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(12) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(13) := exti.data(15 downto 8);
          end if;
          if CONF.word_size = 32 then
            if ((exti.byte_en(2) = '1')) then
              v.ifacereg(14) := exti.data(23 downto 16);
            end if;
            if ((exti.byte_en(3) = '1')) then
              v.ifacereg(15) := exti.data(31 downto 24);
            end if;
          end if;
        when "100" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(16) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(17) := exti.data(15 downto 8);
          end if;
          if CONF.word_size = 32 then
            if ((exti.byte_en(2) = '1')) then
              v.ifacereg(18) := exti.data(23 downto 16);
            end if;
            if ((exti.byte_en(3) = '1')) then
              v.ifacereg(19) := exti.data(31 downto 24);
            end if;
          end if;
        when "101" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(20) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(21) := exti.data(15 downto 8);
          end if;
          if CONF.word_size = 32 then
            if ((exti.byte_en(2) = '1')) then
              v.ifacereg(22) := exti.data(23 downto 16);
            end if;
            if ((exti.byte_en(3) = '1')) then
              v.ifacereg(23) := exti.data(31 downto 24);
            end if;
          end if;
        when "110" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(24) := exti.data(7 downto 0);
          end if;
        when others =>
          null;
      end case;
    end if;

    -- Löschen des Interrupt Signals
    if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) ='1' then
      v.ifacereg(STATUSREG)(STA_INT) := '0';
    end if;
    exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);

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
          if CONF.word_size = 32 then
            exto.data <= r.ifacereg(11) & r.ifacereg(10) & r.ifacereg(9) & r.ifacereg(8);
          else
            exto.data <= "00000000"     & "00000000"     & r.ifacereg(9) & r.ifacereg(8);
          end if;
        when "011" =>
          if CONF.word_size = 32 then
            exto.data <= r.ifacereg(15) & r.ifacereg(14) & r.ifacereg(13) & r.ifacereg(12);
          else
            exto.data <= "00000000"     & "00000000"     & r.ifacereg(13) & r.ifacereg(12);
          end if;
        when "100" =>
          if CONF.word_size = 32 then
            exto.data <= r.ifacereg(19) & r.ifacereg(18) & r.ifacereg(17) & r.ifacereg(16);
          else
            exto.data <= "00000000"     & "00000000"     & r.ifacereg(17) & r.ifacereg(16);
          end if;
        when "101" =>
          if CONF.word_size = 32 then
            exto.data <= r.ifacereg(23) & r.ifacereg(22) & r.ifacereg(21) & r.ifacereg(20);
          else
            exto.data <= "00000000"     & "00000000"     & r.ifacereg(21) & r.ifacereg(20);
          end if;
        when "110" =>
          exto.data <= "00000000" & "00000000" & "00000000" & r.ifacereg(24);
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
--    if exti.extaddr(2 downto 1) = "11" then
--      v.ifacereg(STATUSREG)(STA_ERR) := '1';
--    end if;
    
    --module specific part
    --interupt handler
    v_interruptnr := (others => '0');
    v_intcmd := not EXC_ACT;
    v.ifacereg(INT_MASK_LOW)(0) := '0';
    if r.ifacereg(INT_PROT_LOW)(0) = '1' and r.nmiact = not EXC_ACT then
      --v_intcmd := EXC_ACT;
      v.nmiact := EXC_ACT;
      v_interruptnr := std_logic_vector(to_unsigned(0,EXCADDR_W-1));
      v.ifacereg(INT_MASK_LOW)(0) := '1';
      v.ifacereg(INT_PROT_LOW)(0) := '0';
    else
      for i in 1 to 7 loop
        if (r.ifacereg(INT_PROT_LOW)(i) = '1') and (r.ifacereg(INT_MASK_LOW)(i) = '0') 
          and (r.ifacereg(INT_MASK_LOW)(0) = '0') and (r.ifacereg(CONFIGREG_CUST)(GIE) = '1') then
          v_intcmd := EXC_ACT;
          v_interruptnr := std_logic_vector(to_unsigned(i,EXCADDR_W-1));
          v.ifacereg(INT_MASK_LOW)(0) := '1';
          v.ifacereg(INT_PROT_LOW)(i) := '0';
        end if;
      end loop;
      for i in 0 to 7 loop
        if (r.ifacereg(INT_PROT_HIGH)(i) = '1') and (r.ifacereg(INT_MASK_HIGH)(i) = '0') 
         and (r.ifacereg(INT_MASK_LOW)(0) = '0') and (r.ifacereg(CONFIGREG_CUST)(GIE) = '1') then          
          v_intcmd := EXC_ACT;
          v_interruptnr := std_logic_vector(to_unsigned(i+8,EXCADDR_W-1));
          v.ifacereg(INT_MASK_LOW)(0) := '1';
          v.ifacereg(INT_PROT_HIGH)(i) := '0';
        end if;
      end loop;
    end if;
    
    --update der status flags
    if staen = STA_EN then
      case stactrl is
        when SET_FLAG =>
          v.ifacereg(STATUSREG_CUST)(ZERO) := staflag(ZERO);
          v.ifacereg(STATUSREG_CUST)(NEG) := staflag(NEG);
          v.ifacereg(STATUSREG_CUST)(CARRY) := staflag(CARRY);
          v.ifacereg(STATUSREG_CUST)(OVER) := staflag(OVER);
        when SET_COND =>
          v.ifacereg(STATUSREG_CUST)(COND) := staflag(COND);
          v.ifacereg(STATUSREG_CUST)(ZERO) := staflag(ZERO);
          v.ifacereg(STATUSREG_CUST)(NEG) := staflag(NEG);
          v.ifacereg(STATUSREG_CUST)(CARRY) := staflag(CARRY);
          v.ifacereg(STATUSREG_CUST)(OVER) := staflag(OVER);
        when SAVE_SR =>
          v.ifacereg(STATUSREG_CUST_SAVE) := r.ifacereg(STATUSREG_CUST);
          v.gie_backup := r.ifacereg(CONFIGREG_CUST)(GIE);
          v.ifacereg(STATUSREG_CUST) := (others => '0');
          v.ifacereg(CONFIGREG_CUST)(GIE) := '0';
          if v_intcmd = EXC_ACT then
            v.savedsr := '1';
          end if;
        when REST_SR =>
          v.nmiact := not EXC_ACT;
          if r.savedsr = '1' then
            v.savedsr := '0';
          else
            v.ifacereg(STATUSREG_CUST) := r.ifacereg(STATUSREG_CUST_SAVE);
            v.ifacereg(CONFIGREG_CUST)(GIE) := r.gie_backup;
          end if;
        when others => null;
      end case;
    end if;
    
    --soft- und hard-reset vereinen
    rstint <= not RST_ACT;
    if extrst = RST_ACT or r.ifacereg(CONFIGREG)(CONF_SRES) = '1' then
      rstint <= RST_ACT;
    end if;
    
    -- output
    condflag <= r.ifacereg(STATUSREG_CUST)(COND);
    carryflag <= r.ifacereg(STATUSREG_CUST)(CARRY);
    interruptnr <= v_interruptnr;
    intcmd <= v_intcmd;
    sysrst <= rstint;


    fptrw(7 downto 0)   <=    r.ifacereg(FPTRW_0) ; 
    fptrx(7 downto 0)   <=    r.ifacereg(FPTRX_0) ; 
    fptry(7 downto 0)   <=    r.ifacereg(FPTRY_0) ; 
    fptrz(7 downto 0)   <=    r.ifacereg(FPTRZ_0) ; 

    fptrw(15 downto 8)  <=    r.ifacereg(FPTRW_1) ; 
    fptrx(15 downto 8)  <=    r.ifacereg(FPTRX_1) ; 
    fptry(15 downto 8)  <=    r.ifacereg(FPTRY_1) ; 
    fptrz(15 downto 8)  <=    r.ifacereg(FPTRZ_1) ; 

    if CONF.word_size = 32 then
      fptrw(WORD_W-9 downto WORD_W-16) <=    r.ifacereg(FPTRW_2) ; 
      fptrx(WORD_W-9 downto WORD_W-16) <=    r.ifacereg(FPTRX_2) ; 
      fptry(WORD_W-9 downto WORD_W-16) <=    r.ifacereg(FPTRY_2) ; 
      fptrz(WORD_W-9 downto WORD_W-16) <=    r.ifacereg(FPTRZ_2) ; 
  
      fptrw(WORD_W-1 downto WORD_W-8) <=    r.ifacereg(FPTRW_3) ; 
      fptrx(WORD_W-1 downto WORD_W-8) <=    r.ifacereg(FPTRX_3) ; 
      fptry(WORD_W-1 downto WORD_W-8) <=    r.ifacereg(FPTRY_3) ; 
      fptrz(WORD_W-1 downto WORD_W-8) <=    r.ifacereg(FPTRZ_3) ;
    end if;
    
    if (v_intcmd = EXC_ACT) then
      v.ifacereg(CONFIGREG_CUST)(SLEEP) := '0';
    end if;
    int_hold <= hold or r.ifacereg(CONFIGREG_CUST)(SLEEP);
    cpu_halt <= int_hold;

    r_next <= v;
  end process;

  reg : process(clk)--, rstint)
  begin
    if rising_edge(clk) then 
      if rstint = RST_ACT then
        r.ifacereg      <= (INT_MASK_LOW => (others => '1'), INT_MASK_HIGH => (others => '1'), others => (others => '0'));
        r.tmp_int_prot  <= (others => '0');
        r.savedsr       <= '0';
        r.gie_backup    <= '0';
        r.nmiact        <= not EXC_ACT;
      else
        if (int_hold = not HOLD_ACT) then
          r <= r_next;
        end if;
        r.tmp_int_prot <= r_next.tmp_int_prot;
        r.ifacereg(CONFIGREG_CUST)(SLEEP) <= r_next.ifacereg(CONFIGREG_CUST)(SLEEP);
      end if;
    end if;
  end process;

end behaviour;
