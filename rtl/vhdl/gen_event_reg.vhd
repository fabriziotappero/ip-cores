----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- Generic event register.                                      ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Geir Drange, gedra@opencores.org                           ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2004 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
-- Revision 1.5  2004/07/12 17:06:41  gedra
-- Fixed bug with lock event generation.
--
-- Revision 1.4  2004/07/11 16:19:50  gedra
-- Bug-fix.
--
-- Revision 1.3  2004/06/06 15:42:20  gedra
-- Cleaned up lint warnings.
--
-- Revision 1.2  2004/06/04 15:55:07  gedra
-- Cleaned up lint warnings.
--
-- Revision 1.1  2004/06/03 17:49:26  gedra
-- Generic event register. Used in both receiver and transmitter.
--
--

library IEEE;
use IEEE.std_logic_1164.all;

entity gen_event_reg is
   generic (DATA_WIDTH : integer := 32);
   port (
      clk      : in  std_logic;         -- clock  
      rst      : in  std_logic;         -- reset
      evt_wr   : in  std_logic;         -- event register write     
      evt_rd   : in  std_logic;         -- event register read
      evt_din  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- write data
      event    : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- event vector
      evt_mask : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- irq mask
      evt_en   : in  std_logic;         -- irq enable
      evt_dout : out std_logic_vector(DATA_WIDTH - 1 downto 0);  -- read data
      evt_irq  : out std_logic);        -- interrupt  request
end gen_event_reg;

architecture rtl of gen_event_reg is

   signal evt_internal, zero : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

   evt_dout <= evt_internal when evt_rd = '1' else (others => '0');
   zero     <= (others                                     => '0');

-- IRQ generation:
-- IRQ signal will pulse low when writing to the event register. This will
-- capture situations when not all active events are cleared or an event happens
-- at the same time as it is cleared.
   IR : process (clk)
   begin
      if rising_edge(clk) then
         if ((evt_internal and evt_mask) /= zero) and evt_wr = '0'
            and evt_en = '1' then
            evt_irq <= '1';
         else
            evt_irq <= '0';
         end if;
      end if;
   end process IR;

-- event register generation   
   EVTREG : for k in evt_din'range generate
      EBIT : process (clk, rst)
      begin
         if rst = '1' then
            evt_internal(k) <= '0';
         else
            if rising_edge(clk) then
               if event(k) = '1' then                        -- set event
                  evt_internal(k) <= '1';
               elsif evt_wr = '1' and evt_din(k) = '1' then  -- clear event
                  evt_internal(k) <= '0';
               end if;
            end if;
         end if;
      end process EBIT;
   end generate EVTREG;
   
end rtl;
