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
-- Entity:      pcitb_arb
-- File:        pcitb_arb.vhd
-- Author:      Alf Vaerneus, Gaisler Research
-- Description: PCI arbiter
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;

library gaisler;
use gaisler.pcitb.all;

entity pcitb_arb is
  generic (
    slots : integer := 5;
    tval : time := 7 ns);
  port (
    systclk : in pci_syst_type;
    ifcin : in pci_ifc_type;
    arbin : in pci_arb_type;
    arbout : out pci_arb_type);
end pcitb_arb;

architecture tb of pcitb_arb is

type queue_type is array (0 to slots-1) of integer range 0 to slots;

signal queue : queue_type;
signal queue_nr : integer range 0 to slots;
signal wfbus : boolean;

begin

  arb : process(systclk)
  variable i, slotgnt : integer;
  variable set : boolean;
  variable bus_idle : boolean;
  variable vqueue_nr : integer range 0 to slots;
  variable gnt,req : std_logic_vector(slots-1 downto 0);
  begin
    set := false; vqueue_nr := queue_nr;
    if (ifcin.frame and ifcin.irdy) = '1' then bus_idle := true; else bus_idle := false; end if;
    gnt := to_x01(arbin.gnt(slots-1 downto 0));
    req := to_x01(arbin.req(slots-1 downto 0));

    if systclk.rst = '0' then
      gnt := (others => '1');
      wfbus <= false;
      for i in 0 to slots-1 loop
        queue(i) <= 0;
      end loop;
      queue_nr <= 0;
    elsif rising_edge(systclk.clk) then
      for i in 0 to slots-1 loop
        if (gnt(i) or req(i)) = '0' then
          if (bus_idle or wfbus) then
            set := true;
          end if;
        end if;
      end loop;

      for i in 0 to slots-1 loop
        if (gnt(i) and not req(i)) = '1' then
          if queue(i) = 0 then
            vqueue_nr := vqueue_nr+1;
            queue(i) <= vqueue_nr;
          elsif (queue(i) = 1 and set = false) then
            gnt := (others => '1'); gnt(i) := '0';
            queue(i) <= 0;
            if not bus_idle then wfbus <= true; end if;
            if vqueue_nr > 0 then vqueue_nr := vqueue_nr-1; end if;
          elsif queue(i) >= 2 then
            if (set = false or vqueue_nr <= 1) then
              queue(i) <= queue(i)-1;
--              if vqueue_nr > 0 then vqueue_nr := vqueue_nr-1; end if;
            end if;
          end if;
        elsif (req(i) and not gnt(i)) = '1' then
          queue(i) <= 0; gnt(i) := '1';
--          if vqueue_nr > 0 then vqueue_nr := vqueue_nr-1; end if;
        elsif (req(i) and gnt(i)) = '1' then
          if (queue(i) > 0 and set = false) then
            queue(i) <= queue(i)-1;
            if (vqueue_nr > 0 and queue(i) = 1) then vqueue_nr := vqueue_nr-1; end if;
          end if;
        end if;
      end loop;
    end if;

    if bus_idle then wfbus <= false; end if;

    queue_nr <= vqueue_nr;
    arbout.req <= (others => 'Z');
    arbout.gnt <= (others => 'Z');
    arbout.gnt(slots-1 downto 0) <= gnt;
  end process;

end;

-- pragma translate_on
