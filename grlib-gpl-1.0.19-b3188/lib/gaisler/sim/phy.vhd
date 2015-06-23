------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
----------------------------------------------------------------------------
-- Entity:   	phy
-- File:	phy.vhd
-- Description:	Simulation model of an Ethernet PHY
-- Author:      Marko Isomaki
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
library grlib;

use ieee.std_logic_1164.all;
use grlib.stdlib.all;

entity phy is
  generic(
    address       : integer range 0 to 31 := 0;
    extended_regs : integer range 0 to 1  := 1;
    aneg          : integer range 0 to 1  := 1;
    base100_t4    : integer range 0 to 1  := 0;
    base100_x_fd  : integer range 0 to 1  := 1;
    base100_x_hd  : integer range 0 to 1  := 1;
    fd_10         : integer range 0 to 1  := 1;
    hd_10         : integer range 0 to 1  := 1;
    base100_t2_fd : integer range 0 to 1  := 1;
    base100_t2_hd : integer range 0 to 1  := 1;
    base1000_x_fd : integer range 0 to 1  := 0;
    base1000_x_hd : integer range 0 to 1  := 0;
    base1000_t_fd : integer range 0 to 1  := 1;
    base1000_t_hd : integer range 0 to 1  := 1
    );
  port(
    rstn     : in std_logic;
    mdio     : inout std_logic;
    tx_clk   : out std_logic;
    rx_clk   : out std_logic;
    rxd      : out std_logic_vector(7 downto 0);   
    rx_dv    : out std_logic; 
    rx_er    : out std_logic; 
    rx_col   : out std_logic;
    rx_crs   : out std_logic;
    txd      : in std_logic_vector(7 downto 0);   
    tx_en    : in std_logic; 
    tx_er    : in std_logic; 
    mdc      : in std_logic;
    gtx_clk  : in std_logic
  );
end;

architecture behavioral of phy is
  type mdio_state_type is (idle, start_of_frame, start_of_frame2, op, phyad, regad,
    ta, rdata, wdata);
           
  type ctrl_reg_type is record
    reset       : std_ulogic;
    loopback    : std_ulogic;
    speedsel    : std_logic_vector(1 downto 0);
    anegen      : std_ulogic;
    powerdown   : std_ulogic;
    isolate     : std_ulogic;
    restartaneg : std_ulogic;
    duplexmode  : std_ulogic;
    coltest     : std_ulogic;
  end record;

  type status_reg_type is record
    base100_t4    : std_ulogic;
    base100_x_fd  : std_ulogic;
    base100_x_hd  : std_ulogic;
    fd_10         : std_ulogic;
    hd_10         : std_ulogic;
    base100_t2_fd : std_ulogic;
    base100_t2_hd : std_ulogic;
    extstat       : std_ulogic;
    mfpreamblesup : std_ulogic;
    anegcmpt      : std_ulogic;
    remfault      : std_ulogic;
    anegability   : std_ulogic;
    linkstat      : std_ulogic;
    jabdetect     : std_ulogic;
    extcap        : std_ulogic;
  end record;

  type aneg_ab_type is record
    next_page     : std_ulogic;
    remote_fault  : std_ulogic;
    tech_ability  : std_logic_vector(7 downto 0);
    selector      : std_logic_vector(4 downto 0);
  end record;

  type aneg_exp_type is record
    par_detct_flt : std_ulogic;
    lp_np_able    : std_ulogic;
    np_able       : std_ulogic;
    page_rx       : std_ulogic;
    lp_aneg_able  : std_ulogic;
  end record;

  type aneg_nextpage_type is record
    next_page     : std_ulogic;
    message_page  : std_ulogic;
    ack2          : std_ulogic;
    toggle        : std_ulogic;
    message       : std_logic_vector(10 downto 0);
  end record;

  type mst_slv_ctrl_type is record
    tmode         : std_logic_vector(2 downto 0);
    manualcfgen   : std_ulogic;
    cfgval        : std_ulogic;
    porttype      : std_ulogic;
    base1000_t_fd : std_ulogic;
    base1000_t_hd : std_ulogic;
  end record;

  type mst_slv_status_type is record
    cfgfault        : std_ulogic;
    cfgres          : std_ulogic;
    locrxstate      : std_ulogic;
    remrxstate      : std_ulogic;
    lpbase1000_t_fd : std_ulogic;
    lpbase1000_t_hd : std_ulogic;
    idlerrcnt       : std_logic_vector(7 downto 0);
  end record;

  type extended_status_reg_type is record
    base1000_x_fd : std_ulogic;
    base1000_x_hd : std_ulogic;
    base1000_t_fd : std_ulogic;
    base1000_t_hd : std_ulogic;
  end record;
  
  type reg_type is record
    state         : mdio_state_type;
    cnt           : integer;
    op            : std_logic_vector(1 downto 0);
    phyad         : std_logic_vector(4 downto 0);
    regad         : std_logic_vector(4 downto 0);
    wr            : std_ulogic;
    regtmp        : std_logic_vector(15 downto 0);
    -- MII management registers
    ctrl          : ctrl_reg_type;
    status        : status_reg_type;
    anegadv       : aneg_ab_type;
    aneglp        : aneg_ab_type;
    anegexp       : aneg_exp_type;
    anegnptx      : aneg_nextpage_type;
    anegnplp      : aneg_nextpage_type;
    mstslvctrl    : mst_slv_ctrl_type;
    mstslvstat    : mst_slv_status_type;
    extstatus     : extended_status_reg_type;
    rstcnt        : integer;
    anegcnt       : integer;
  end record;

  signal r, rin   : reg_type;
  signal int_clk  : std_ulogic := '0';
  signal clkslow  : std_ulogic := '0';
  signal rcnt     : integer;
  signal anegact  : std_ulogic;
begin
  --mdio signal pull-up
  int_clk <= not int_clk after 8 ns when r.ctrl.speedsel = "01" else
             not int_clk after 40 ns when r.ctrl.speedsel = "10" else
             not int_clk after 400 ns when r.ctrl.speedsel = "00";

  clkslow <= not clkslow after 40 ns when r.ctrl.speedsel = "10" else
             not clkslow after 400 ns;
  
--   rstdelay : process
--   begin
--     loop
--       rstd <= '0';
--       while r.ctrl.reset /= '1' loop
--         wait on r.ctrl.reset;
--       end loop;
--       rstd <= '1';
--       while rstn = '0' loop
--         wait on rstn;
--       end loop;
--       wait on rstn for 3 us;
--       rstd <= '0';
--       wait on rstn until r.ctrl.reset = '0' for 5 us; 
--     end loop;
--   end process;

  anegproc : process is
  begin
    loop
      anegact <= '0';
      while rstn /= '1' loop
        wait on rstn;
      end loop;
      while rstn = '1' loop
        if r.ctrl.anegen = '0' then
          anegact <= '0';
          wait on rstn, r.ctrl.anegen, r.ctrl.restartaneg;
        else
          if r.ctrl.restartaneg = '1' then
            anegact <= '1';
            wait on rstn, r.ctrl.restartaneg, r.ctrl.anegen for 2 us;
            anegact <= '0';
            wait on rstn, r.ctrl.anegen until r.ctrl.restartaneg = '0';
            if (rstn and r.ctrl.anegen) = '1' then
              wait on rstn, r.ctrl.anegen, r.ctrl.restartaneg;
            end if;
          else
            anegact <= '0';
            wait on rstn, r.ctrl.restartaneg, r.ctrl.anegen;
          end if;
        end if;
      end loop;
    end loop;
  end process; 

  mdiocomb : process(rstn, r, anegact, mdio) is
    variable v : reg_type;
  begin
    v := r; 
    if anegact = '0' then
      v.ctrl.restartaneg := '0';
    end if;
    case r.state is
      when idle =>
        mdio <= 'Z';
        if to_X01(mdio) = '1' then
          v.cnt := v.cnt + 1;
          if v.cnt = 31 then
            v.state := start_of_frame; v.cnt := 0;
          end if;
        else
          v.cnt := 0;
        end if;
      when start_of_frame =>
        if to_X01(mdio) = '0' then
          v.state := start_of_frame2;
        elsif to_X01(mdio) /= '1' then
          v.state := idle;
        end if;
      when start_of_frame2 =>
        if to_X01(mdio) = '1' then
          v.state := op;
        else
          v.state := idle;
        end if;
      when op =>
        v.cnt := v.cnt + 1;
        v.op := r.op(0) & to_X01(mdio);
        if r.cnt = 1 then
          if (v.op = "01") or (v.op = "10") then 
            v.state := phyad; v.cnt := 0;
          else
            v.state := idle; v.cnt := 0;
          end if;
        end if;
      when phyad =>
        v.phyad := r.phyad(3 downto 0) & to_X01(mdio);
        v.cnt := v.cnt + 1;
        if r.cnt = 4 then
          v.state := regad; v.cnt := 0;
        end if;
      when regad =>
        v.regad := r.regad(3 downto 0) & to_X01(mdio);
        v.cnt := v.cnt + 1;
        if r.cnt = 4 then
          v.cnt := 0;
          if conv_integer(r.phyad) = address then
            v.state := ta; 
          else
            v.state := idle;
          end if;
        end if;
      when ta =>
        v.cnt := r.cnt + 1;
        if r.cnt = 0 then
          if (r.op = "01") and to_X01(mdio) /= '1' then
            v.cnt := 0; v.state := idle;
          end if;
        else
          if r.op = "10" then
            mdio <= '0'; v.cnt := 0; v.state := rdata;
            case r.regad is
              when "00000" => --ctrl (basic)
                v.regtmp := r.ctrl.reset & r.ctrl.loopback &
                  r.ctrl.speedsel(1) & r.ctrl.anegen & r.ctrl.powerdown &
                  r.ctrl.isolate & r.ctrl.restartaneg & r.ctrl.duplexmode &
                  r.ctrl.coltest & r.ctrl.speedsel(0) & "000000";
              when "00001" => --statuc (basic)
                v.regtmp := r.status.base100_t4 & r.status.base100_x_fd & 
                  r.status.base100_x_hd & r.status.fd_10 & r.status.hd_10 & 
                  r.status.base100_t2_fd & r.status.base100_t2_hd & 
                  r.status.extstat & '0' & r.status.mfpreamblesup & 
                  r.status.anegcmpt & r.status.remfault & r.status.anegability &
                  r.status.linkstat & r.status.jabdetect & r.status.extcap;
              when "00010" => --PHY ID (extended)
                if extended_regs = 1 then
                  v.regtmp := X"BBCD";
                else
                  v.cnt := 0; v.state := idle; 
                end if;
              when "00011" => --PHY ID (extended)
                if extended_regs = 1 then
                  v.regtmp := X"9C83";
                else
                  v.cnt := 0; v.state := idle; 
                end if;
              when "00100" => --Auto-neg adv. (extended)
                if extended_regs = 1 then
                  v.regtmp := r.anegadv.next_page & '0' & r.anegadv.remote_fault & 
                    r.anegadv.tech_ability & r.anegadv.selector;
                else
                  v.cnt := 0; v.state := idle; 
                end if;
              when "00101" => --Auto-neg link partner ability (extended)
                if extended_regs = 1 then
                  v.regtmp := r.aneglp.next_page & '0' & r.aneglp.remote_fault & 
                    r.aneglp.tech_ability & r.aneglp.selector;
                else
                  v.cnt := 0; v.state := idle; 
                end if;
              when "00110" => --Auto-neg expansion (extended)
                if extended_regs = 1 then
                  v.regtmp := "00000000000" & r.anegexp.par_detct_flt & 
                  r.anegexp.lp_np_able &  r.anegexp.np_able & r.anegexp.page_rx &
                  r.anegexp.lp_aneg_able;
                else
                  v.cnt := 0; v.state := idle; 
                end if;
              when "00111" => --Auto-neg next page (extended)
                if extended_regs = 1 then
                  v.regtmp := r.anegnptx.next_page & '0' & r.anegnptx.message_page &
                  r.anegnptx.ack2 & r.anegnptx.toggle & r.anegnptx.message;
                else
                  v.cnt := 0; v.state := idle; 
                end if;
              when "01000" => --Auto-neg link partner received next page (extended)
                if extended_regs = 1 then
                  v.regtmp := r.anegnplp.next_page & '0' & r.anegnplp.message_page &
                  r.anegnplp.ack2 & r.anegnplp.toggle & r.anegnplp.message;
                else
                  v.cnt := 0; v.state := idle; 
                end if;
              when "01001" => --Master-slave control (extended)
                if extended_regs = 1 then
                  v.regtmp := r.mstslvctrl.tmode & r.mstslvctrl.manualcfgen & 
                  r.mstslvctrl.cfgval & r.mstslvctrl.porttype &
                  r.mstslvctrl.base1000_t_fd &  r.mstslvctrl.base1000_t_hd &
                  "00000000";
                else
                  v.cnt := 0; v.state := idle;
                end if;
              when "01010" => --Master-slave status (extended)
                if extended_regs = 1 then
                  v.regtmp := r.mstslvstat.cfgfault & r.mstslvstat.cfgres &
                  r.mstslvstat.locrxstate & r.mstslvstat.remrxstate & 
                  r.mstslvstat.lpbase1000_t_fd & r.mstslvstat.lpbase1000_t_hd &
                  "00" & r.mstslvstat.idlerrcnt;
                else
                  v.cnt := 0; v.state := idle;
                end if;
              when "01111" =>
                if (base1000_x_fd = 1) or (base1000_x_hd = 1) or
                   (base1000_t_fd = 1) or (base1000_t_hd = 1) then
                  v.regtmp := r.extstatus.base1000_x_fd &
                              r.extstatus.base1000_x_hd &
                              r.extstatus.base1000_t_fd &
                              r.extstatus.base1000_t_hd & X"000";
                else
                  v.regtmp := (others => '0');
                end if;
              when others =>
                --PHY shall not drive MDIO when unimplemented registers
                --are accessed
                v.cnt := 0; v.state := idle;
                v.regtmp := (others => '0');
            end case;
            if r.ctrl.reset = '1' then
              if r.regad = "00000" then
                v.regtmp := X"8000";
              else
                v.regtmp := X"0000";
              end if;
            end if;
          else
            if to_X01(mdio) /= '0'then
              v.cnt := 0; v.state := idle; 
            else
              v.cnt := 0; v.state := wdata;
            end if; 
          end if;
        end if;
      when rdata =>
        v.cnt := r.cnt + 1;
        mdio <= r.regtmp(15-r.cnt);
        if r.cnt = 15 then
          v.state := idle; v.cnt := 0;
        end if;
      when wdata =>
        v.cnt := r.cnt + 1;
        v.regtmp := r.regtmp(14 downto 0) & to_X01(mdio);
        if r.cnt = 15 then
          v.state := idle; v.cnt := 0;
          if r.ctrl.reset = '0' then
            case r.regad is
              when "00000" =>
                v.ctrl.reset := v.regtmp(15);
                v.ctrl.loopback := v.regtmp(14);
                v.ctrl.speedsel(1) := v.regtmp(13);
                v.ctrl.anegen := v.regtmp(12);
                v.ctrl.powerdown := v.regtmp(11);
                v.ctrl.isolate := v.regtmp(10);
                v.ctrl.restartaneg := v.regtmp(9);
                v.ctrl.duplexmode := v.regtmp(8);
                v.ctrl.coltest := v.regtmp(7);
                v.ctrl.speedsel(0) := v.regtmp(6);
              when "00100" =>
                if extended_regs = 1 then
                  v.anegadv.remote_fault := r.regtmp(13);
                  v.anegadv.tech_ability := r.regtmp(12 downto 5);
                  v.anegadv.selector := r.regtmp(4 downto 0);
                end if;
              when "00111" =>
                if extended_regs = 1 then
                  v.anegnptx.next_page     := r.regtmp(15);
                  v.anegnptx.message_page  := r.regtmp(13);
                  v.anegnptx.ack2          := r.regtmp(12);
                  v.anegnptx.message       := r.regtmp(10 downto 0);
                end if;
              when "01001" =>
                if extended_regs = 1 then
                  v.mstslvctrl.tmode         := r.regtmp(15 downto 13);
                  v.mstslvctrl.manualcfgen   := r.regtmp(12);
                  v.mstslvctrl.cfgval        := r.regtmp(11);
                  v.mstslvctrl.porttype      := r.regtmp(10);
                  v.mstslvctrl.base1000_t_fd := r.regtmp(9);
                  v.mstslvctrl.base1000_t_hd := r.regtmp(8);
                end if;
              when others =>  --no writable bits for other regs
                null;
            end case;
          end if;
        end if;
      when others =>
        null;
    end case;
    if r.rstcnt > 19 then
      v.ctrl.reset := '0'; v.rstcnt := 0;
    else
      v.rstcnt := r.rstcnt + 1; 
    end if;
    if (v.ctrl.reset and not r.ctrl.reset) = '1' then
      v.rstcnt := 0; 
    end if;
    if r.ctrl.anegen = '1' then
      if r.anegcnt < 10 then
        v.anegcnt := r.anegcnt + 1;
      else
        v.status.anegcmpt := '1';
        if (base1000_x_fd = 1) or (base1000_x_hd = 1) or
           (r.mstslvctrl.base1000_t_fd = '1') or
           (r.mstslvctrl.base1000_t_hd = '1') then
          v.ctrl.speedsel(1 downto 0) := "01";
        elsif (r.anegadv.tech_ability(4) = '1') or
              (r.anegadv.tech_ability(3) = '1') or
              (r.anegadv.tech_ability(2) = '1') or
              (base100_t2_fd = 1) or (base100_t2_hd = 1) then
          v.ctrl.speedsel(1 downto 0) := "10";
        else
          v.ctrl.speedsel(1 downto 0) := "00";
        end if;
        if ((base1000_x_fd = 1) or (r.mstslvctrl.base1000_t_fd = '1')) or
           (((base100_t2_fd = 1) or (r.anegadv.tech_ability(3) = '1')) and
           (r.mstslvctrl.base1000_t_hd = '0') and (base1000_x_hd = 0)) or
           ((r.anegadv.tech_ability(1) = '1') and (base100_t2_hd = 0) and
           (r.anegadv.tech_ability(4) = '0') and
           (r.anegadv.tech_ability(2) = '0')) then
          v.ctrl.duplexmode := '1';
        else
          v.ctrl.duplexmode := '0';
        end if;
      end if;
    end if;
    if r.ctrl.restartaneg = '1' then
      v.anegcnt := 0;
      v.status.anegcmpt := '0';
      v.ctrl.restartaneg := '0';
    end if;
    rin <= v;
  end process;

  reg : process(rstn, mdc) is
  begin
    if rising_edge(mdc) then
      r <= rin;
    end if;
--     -- RESET DELAY
--     if rstd = '1' then
--       r.ctrl.reset <= '1';
--     else
--       r.ctrl.reset <= '0';
--     end if;

    -- RESET
    if (r.ctrl.reset or not rstn) = '1' then
      r.ctrl.loopback <= '0'; r.anegcnt <= 0;
      if (base1000_x_hd = 1) or (base1000_x_fd = 1) or (base1000_t_hd = 1) or
         (base1000_t_fd = 1) then
        r.ctrl.speedsel <= "01";
      elsif (base100_x_hd = 1) or (base100_t2_hd = 1) or (base100_x_fd = 1) or
            (base100_t2_fd = 1) or (base100_t4 = 1) then
        r.ctrl.speedsel <= "10";
      else
        r.ctrl.speedsel <= "00";
      end if;
        
      r.ctrl.anegen <= conv_std_logic(aneg = 1);
      r.ctrl.powerdown <= '0';
      r.ctrl.isolate <= '0';
      r.ctrl.restartaneg <= '0';
      if (base100_x_hd = 0) and (hd_10 = 0) and (base100_t2_hd = 0) and
         (base1000_x_hd = 0) and (base1000_t_hd = 0) then
        r.ctrl.duplexmode <= '1';
      else
        r.ctrl.duplexmode <= '0';
      end if;
      r.ctrl.coltest <= '0';
      
      r.status.base100_t4 <= conv_std_logic(base100_t4 = 1);
      r.status.base100_x_fd <= conv_std_logic(base100_x_fd = 1);
      r.status.base100_x_hd <= conv_std_logic(base100_x_hd = 1);  
      r.status.fd_10 <= conv_std_logic(fd_10 = 1);        
      r.status.hd_10 <= conv_std_logic(hd_10 = 1);        
      r.status.base100_t2_fd <= conv_std_logic(base100_t2_fd = 1);
      r.status.base100_t2_hd <= conv_std_logic(base100_t2_hd = 1);
      r.status.extstat <= conv_std_logic((base1000_x_fd = 1) or
                                         (base1000_x_hd = 1) or
                                         (base1000_t_fd = 1) or
                                         (base1000_t_hd = 1)); 
      r.status.mfpreamblesup <= '0';
      r.status.anegcmpt <= '0';      
      r.status.remfault <= '0';     
      r.status.anegability <= conv_std_logic(aneg = 1); 
      r.status.linkstat <= '0';     
      r.status.jabdetect <= '0';    
      r.status.extcap <= conv_std_logic(extended_regs = 1);

      r.anegadv.next_page <= '0';
      r.anegadv.remote_fault <= '0';
      r.anegadv.tech_ability <= "000" & conv_std_logic(base100_t4 = 1) &
        conv_std_logic(base100_x_fd = 1) & conv_std_logic(base100_x_hd = 1) &
        conv_std_logic(fd_10 = 1) & conv_std_logic(hd_10 = 1);
      r.anegadv.selector <= "00001";

      r.aneglp.next_page <= '0';
      r.aneglp.remote_fault <= '0';
      r.aneglp.tech_ability <= "000" & conv_std_logic(base100_t4 = 1) &
        conv_std_logic(base100_x_fd = 1) & conv_std_logic(base100_x_hd = 1) &
        conv_std_logic(fd_10 = 1) & conv_std_logic(hd_10 = 1);
      r.aneglp.selector <= "00001";

      r.anegexp.par_detct_flt <= '0';
      r.anegexp.lp_np_able    <= '0';
      r.anegexp.np_able       <= '0';
      r.anegexp.page_rx       <= '0';
      r.anegexp.lp_aneg_able  <= '0';

      r.anegnptx.next_page     <= '0';
      r.anegnptx.message_page  <= '1';
      r.anegnptx.ack2          <= '0';
      r.anegnptx.toggle        <= '0';
      r.anegnptx.message       <= "00000000001";

      r.anegnplp.next_page     <= '0';
      r.anegnplp.message_page  <= '1';
      r.anegnplp.ack2          <= '0';
      r.anegnplp.toggle        <= '0';
      r.anegnplp.message       <= "00000000001";

      r.mstslvctrl.tmode         <= (others => '0');
      r.mstslvctrl.manualcfgen   <= '0';
      r.mstslvctrl.cfgval        <= '0';
      r.mstslvctrl.porttype      <= '0';
      r.mstslvctrl.base1000_t_fd <= conv_std_logic(base1000_t_fd = 1);
      r.mstslvctrl.base1000_t_hd <= conv_std_logic(base1000_t_fd = 1);

      r.mstslvstat.cfgfault         <= '0';
      r.mstslvstat.cfgres           <= '1';
      r.mstslvstat.locrxstate       <= '1';
      r.mstslvstat.remrxstate       <= '1';
      r.mstslvstat.lpbase1000_t_fd  <= conv_std_logic(base1000_t_fd = 1);
      r.mstslvstat.lpbase1000_t_hd  <= conv_std_logic(base1000_t_fd = 1);
      r.mstslvstat.idlerrcnt        <= (others => '0');
      
      r.extstatus.base1000_x_fd <= conv_std_logic(base1000_x_fd = 1);
      r.extstatus.base1000_x_hd <= conv_std_logic(base1000_x_hd = 1);
      r.extstatus.base1000_t_fd <= conv_std_logic(base1000_t_fd = 1);
      r.extstatus.base1000_t_hd <= conv_std_logic(base1000_t_hd = 1);
      
    end if;
    
    if rstn = '0' then
      r.cnt <= 0; r.state <= idle; r.rstcnt <= 0;
      r.ctrl.reset <= '1'; 
    end if;
  end process;


  loopback_sel : process(r.ctrl.loopback, int_clk, gtx_clk, r.ctrl.speedsel, txd, tx_en) is
  begin
    if r.ctrl.loopback = '1' then
      rx_col <= '0'; rx_crs <= tx_en; rx_dv <= tx_en; rx_er <= tx_er;
      rxd <= txd;
      if r.ctrl.speedsel /= "01" then
        rx_clk <= int_clk; tx_clk <= int_clk;
      else
        rx_clk <= gtx_clk; tx_clk <= clkslow;
      end if;
    else
      rx_col <= '0'; rx_crs <= '0'; rx_dv <= '0';
      rxd <= (others => '0');
      if r.ctrl.speedsel /= "01" then
        rx_clk <= int_clk; tx_clk <= int_clk after 3 ns;
      else
        rx_clk <= gtx_clk; tx_clk <= clkslow;
      end if;
    end if;
  end process;
end;
-- pragma translate_on
