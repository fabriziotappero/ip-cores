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
-----------------------------------------------------------------------------
-- Entity:      pcitb_monitor
-- File:        pcitb_monitor.vhd
-- Author:      Alf Vaerneus, Gaisler Research
-- Description: PCI Monitor.
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;

library gaisler;
use gaisler.pcitb.all;
use gaisler.ambatest.all;
library grlib;
use grlib.stdlib.xorv;


entity pcitb_monitor is
  generic (dbglevel : integer := 1);
  port (pciin     : in pci_type);
end pcitb_monitor;

architecture tb of pcitb_monitor is

constant T_O : integer := 9;

type pci_array_type is array(0 to 2) of pci_type;

type reg_type is record
  pci : pci_array_type;
  frame_deass : boolean;
  m_wait_data_phase : boolean;
  t_wait_data_phase : boolean;
  stop_asserted : boolean;
  device_sel : boolean;
  first : boolean;
  current_master : integer;
  master_cnt : integer;
  irdy_cnt : integer;
  trdy_cnt : integer;
end record;

signal r,rin : reg_type;
signal init_done : boolean := false;

begin

  init : process
  begin
    if init_done = false then
      wait until pciin.syst.rst = '0';
      wait until pciin.syst.rst = '1';
      init_done <= true;
    else
      wait until pciin.syst.rst = '0';
      init_done <= false;
    end if;
  end process;


  comb : process(pciin)
  variable i : integer;
  variable v : reg_type;
  begin
    v := r;
    v.pci(0) := pciin; v.pci(1) := r.pci(0); v.pci(2) := r.pci(1);

    if r.pci(0).ifc.frame = 'H' then v.frame_deass := false;
    elsif (r.pci(0).ifc.frame and not r.pci(1).ifc.frame) = '1' then  v.frame_deass := true; end if;

    if ((r.pci(0).ifc.trdy and r.pci(0).ifc.stop) or r.pci(0).ifc.irdy) = '0' then v.m_wait_data_phase := false;
    elsif r.pci(0).ifc.irdy = '0' then v.m_wait_data_phase := true; end if;

    if ((r.pci(0).ifc.trdy and r.pci(0).ifc.stop) or r.pci(0).ifc.irdy) = '0' then v.t_wait_data_phase := false;
    elsif (r.pci(0).ifc.trdy and r.pci(0).ifc.stop) = '0' then v.t_wait_data_phase := true; end if;

    if r.pci(0).ifc.frame = '0' and r.pci(1).ifc.frame = 'H' then
      for i in 0 to 20 loop
        if r.pci(0).arb.gnt(i) = '0' then v.current_master := i; end if;
      end loop;
    end if;

    if (r.pci(0).ifc.frame and r.pci(0).ifc.irdy) = '0' then
      if (r.pci(0).ifc.trdy and r.pci(0).ifc.stop) = '1' then
        v.master_cnt := r.master_cnt+1;
      else v.master_cnt := 0; end if;
    else v.master_cnt := 0; end if;


    if (r.pci(0).ifc.irdy and not r.pci(0).ifc.frame) = '1' then
      v.irdy_cnt := r.irdy_cnt+1;
    else v.irdy_cnt := 0; end if;

    if ((r.pci(0).ifc.trdy and r.pci(0).ifc.stop) and not (r.pci(0).ifc.frame and r.pci(0).ifc.irdy)) = '1' then
      v.trdy_cnt := r.trdy_cnt+1;
    else v.trdy_cnt := 0; end if;

    if r.pci(0).ifc.devsel = '0' then v.device_sel := true;
    elsif (to_x01(r.pci(1).ifc.devsel) and not (r.pci(0).ifc.frame and r.pci(0).ifc.irdy)) = '1' then v.device_sel := false; end if;

    if r.pci(0).ifc.stop = '0' then v.stop_asserted := true;
    elsif r.pci(0).ifc.frame = '0' then v.stop_asserted := false; end if;

    if (r.pci(1).ifc.frame = 'H' and r.pci(0).ifc.frame = '0') then v.first := true;
    elsif (r.pci(0).ifc.trdy and r.pci(0).ifc.stop) = '0' then v.first := false; end if;

    rin <= v;
  end process;

  clkprc : process(pciin.syst)
  begin
    if rising_edge(pciin.syst.clk) then
      r <= rin;

      if init_done then

        if (r.pci(0).ifc.frame = '0' and r.frame_deass = true) then
          if dbglevel > 0 then
            assert false
            report "***PCI ERROR***"
            severity warning;
            printf("PCI_MONITOR: FRAME# was reasserted during the same transaction.");
          end if;
        end if;

        if (r.pci(0).ifc.frame and r.pci(0).ifc.irdy and not r.pci(1).ifc.frame) = '1' then
          if dbglevel > 0 then
            assert false
            report "***PCI ERROR***"
            severity warning;
            printf("PCI_MONITOR: FRAME# was deasserted without IRDY# asserted.");
          end if;
        end if;

        if (r.m_wait_data_phase and r.device_sel) then
          if (r.pci(0).ifc.frame /= r.pci(1).ifc.frame) or (r.pci(0).ifc.irdy /= r.pci(1).ifc.irdy) then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Current master changed IRDY# or FRAME# before current data phase was completed.");
            end if;
          end if;
        end if;

        if ((r.pci(1).ifc.irdy and r.pci(1).ifc.frame and not r.pci(2).ifc.irdy) = '1' and r.stop_asserted = true) then
          if not ((r.pci(1).arb.req(r.current_master) and (r.pci(0).arb.req(r.current_master) or r.pci(2).arb.req(r.current_master))) = '1') then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Current master at slot %d did not release its REQ# when the bus returned to idle state.",r.current_master);
            end if;
          end if;
        end if;

        if (r.pci(0).ifc.stop and not r.pci(1).ifc.stop and not r.pci(0).ifc.frame) = '1' then
          if dbglevel > 0 then
            assert false
            report "***PCI ERROR***"
            severity warning;
            printf("PCI_MONITOR: Target did not keep STOP# asserted until FRAME# was deasserted.");
          end if;
        end if;

        if (r.pci(0).ifc.frame and r.pci(1).ifc.frame and not r.pci(0).ifc.stop and not r.pci(1).ifc.stop) = '1' then
          if dbglevel > 0 then
            assert false
            report "***PCI ERROR***"
            severity warning;
            printf("PCI_MONITOR: Target did not release STOP# after FRAME# was deasserted.");
          end if;
        end if;

        if r.t_wait_data_phase = true then
          if (r.pci(0).ifc.devsel /= r.pci(1).ifc.devsel) or (r.pci(0).ifc.trdy /= r.pci(1).ifc.trdy) or (r.pci(0).ifc.stop /= r.pci(1).ifc.stop) then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Current target changed DEVSEL#, STOP# or TRDY# before current data phase was completed.");
            end if;
          end if;
        end if;

        if (r.pci(0).ifc.frame and r.pci(0).ifc.stop and not r.pci(1).ifc.frame and not r.pci(1).ifc.stop) = '1' then
          if dbglevel > 0 then
            assert false
            report "***PCI ERROR***"
            severity warning;
            printf("PCI_MONITOR: Target did not keep STOP# asserted until the last data phase.");
          end if;
        end if;

        if (r.pci(2).ifc.frame and not (r.pci(2).ifc.trdy and r.pci(2).ifc.stop)) = '1' then
          if r.pci(1).ifc.irdy = '0' then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Master kept IRDY# asserted after last data phase.");
            end if;
          end if;
          if r.pci(1).ifc.trdy = '0' then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Target kept TRDY# asserted after last data phase.");
            end if;
          end if;
          if r.pci(1).ifc.stop = '0' then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Target kept STOP# asserted after last data phase.");
            end if;
          end if;
          if r.pci(1).ifc.frame /= 'H' then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Master did not tri-state FRAME# after turn-around cycle.");
            end if;
          end if;
          if r.pci(0).ifc.irdy /= 'H' then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Master did not tri-state IRDY# after turn-around cycle.");
            end if;
          end if;
          if r.pci(0).ifc.trdy /= 'H' then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Target did not tri-state TRDY# after turn-around cycle.");
            end if;
          end if;
          if r.pci(0).ifc.stop /= 'H' then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Target did not tri-state STOP# after turn-around cycle.");
            end if;
          end if;
        end if;

        if (r.master_cnt > 16 and r.first = true) then
          if dbglevel > 0 then
            assert false
            report "***PCI ERROR***"
            severity warning;
            printf("PCI_MONITOR: Target did not complete its initial data phase in 16 clkc.");
          end if;
        end if;

        if r.irdy_cnt > 8 then
          if dbglevel > 0 then
            assert false
            report "***PCI ERROR***"
            severity warning;
            printf("PCI_MONITOR: Master did not complete its initial data phase in 8 clkc.");
          end if;
        end if;

        if (r.trdy_cnt > 8 and r.device_sel = true and r.first = false) then
          if dbglevel > 0 then
            assert false
            report "***PCI ERROR***"
            severity warning;
            printf("PCI_MONITOR: Target did not complete a data phase in 8 clkc.");
          end if;
        end if;

        if not r.device_sel then
          if (r.pci(0).ifc.irdy and not r.pci(1).ifc.irdy) = '1' then
            if dbglevel > 0 then
              assert false
              report "**"
              severity note;
              printf("PCI_MONITOR: Master abort detected.");
            end if;
          end if;
        end if;

        if ((r.pci(1).ifc.irdy = 'H' and r.pci(1).ifc.frame = '0')
        or (r.pci(1).ifc.irdy or r.pci(1).ifc.trdy) = '0') then
          if r.pci(0).ad.par = 'Z' then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Current Master/Target is not generating parity during a data phase.");
            end if;
          elsif r.pci(0).ad.par /= xorv(r.pci(1).ad.ad & r.pci(1).ad.cbe) then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: Parity error detected.");
            end if;
          end if;
        end if;

      end if;

    end if;
  end process;

  adchk : process(pciin.ad)
  begin

    if init_done then

--      for i in 0 to 31 loop
--        if pciin.ad.ad(i) = 'X' then
--          if dbglevel > 0 then
--            assert false
--            report " **"
--            severity warning;
--            printf("PCI_MONITOR: AD lines have multiple drivers.");
--          end if;
--        end if;
--      end loop;

      for i in 0 to 3 loop
        if pciin.ad.cbe(i) = 'X' then
          if dbglevel > 0 then
            assert false
            report " **"
            severity warning;
            printf("PCI_MONITOR: CBE# lines have multiple drivers.");
          end if;
        end if;
      end loop;

--      if pciin.ad.par = 'X' then
--        if dbglevel > 0 then
--          assert false
--          report " **"
--          severity warning;
--          printf("PCI_MONITOR: PAR line has multiple drivers.");
--        end if;
--      end if;

    end if;

  end process;

  ifcchk : process(pciin.ifc)
  begin

    if init_done then

      if pciin.ifc.frame = 'X' then
        if dbglevel > 0 then
          assert false
          report " **"
          severity warning;
          printf("PCI_MONITOR: FRAME# line has multiple drivers.");
        end if;
      end if;
      if pciin.ifc.irdy = 'X' then
        if dbglevel > 0 then
          assert false
          report " **"
          severity warning;
          printf("PCI_MONITOR: IRDY# line has multiple drivers.");
        end if;
      end if;
      if pciin.ifc.trdy = 'X' then
        if dbglevel > 0 then
          assert false
          report " **"
          severity warning;
          printf("PCI_MONITOR: TRDY# line has multiple drivers.");
        end if;
      end if;
      if pciin.ifc.stop = 'X' then
        if dbglevel > 0 then
          assert false
          report " **"
          severity warning;
          printf("PCI_MONITOR: STOP# line has multiple drivers.");
        end if;
      end if;
      if pciin.ifc.devsel = 'X' then
        if dbglevel > 0 then
          assert false
          report " **"
          severity warning;
          printf("PCI_MONITOR: DEVSEL# line has multiple drivers.");
        end if;
      end if;

    end if;

  end process;

  arbchk : process(pciin.arb)
  variable gnt_set : boolean;
  begin
    gnt_set := false;

    if init_done then

      for i in 0 to 20 loop
        if pciin.arb.gnt(i) = '0' then
          if gnt_set then
            if dbglevel > 0 then
              assert false
              report "***PCI ERROR***"
              severity warning;
              printf("PCI_MONITOR: GNT# is asserted for more than one PCI master.");
            end if;
          else gnt_set := true; end if;
        end if;
      end loop;

    end if;

  end process;

end;

-- pragma translate_on
