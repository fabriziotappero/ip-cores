



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


--============================================================================--
-- Design unit  : pci_arb
--
-- File name    : pci_arb.vhd
--
-- Purpose      : Arbiter for the PCI bus
--                - configurable size: 4, 8, 16, 32 agents
--                - nested round-robbing in two different priority levels
--                - priority assignment hard-coded or APB-programmable
--
-- Reference    : PCI Local Bus Specification, Revision 2.1,
--                PCI Special Interest Group, 1st June 1995
--                (for information: http:
-- Reference    : AMBA(TM) Specification (Rev 2.0), ARM IHI 0011A,
--                13th May 1999, issue A, first release, ARM Limited
--                The document can be retrieved from http:
--
-- Note         : Numbering for req_n, gnt_n, or priority levels is in
--                increasing order <0 = left> to <NUMBER-1 = right>.
--                APB data/address arrays are in the conventional order:
--                The least significant bit is located to the
--                right, carrying the lower index number (usually 0).
--                The arbiter considers strong signal levels ('1' and '0')
--                only. Weak levels ('H', 'L') are not considered. The
--                appropriate translation function (to_X01) must be applied
--                to the inputs. This is usually done by the pads,
--                and therefore not contained in this model.
--
-- Configuration: The arbiter can be configured to NB_AGENTS = 4, 8, 16 or 32.
--                A priority level (0 = high, 1 = low) is assigned to each device.
--                Exception is agent NB_AGENTS-1, which has always lowest priority.
--
--                a) The priority levels are hard-coded, when APB_PRIOS = false.
--                In this case, the APB ports (pbi/pbo) are unconnected.
--                The constant ARB_LVL_C must then be set to appropriate values.
--
--                b) When APB_PRIOS = true, the levels are programmable via the
--                APB-address 0x80 (allows to be ored with the PCI interface):
--                Bit 31 (leftmost) = master 31 . . bit 0 (rightmost) = master 0.
--                Bit NB_AGENTS-1 is dont care at write and reads 1.
--                Bits NB_AGENTS to 31, if existing, are dont care and read 0.
--                The constant ARB_LVL_C is then the reset value.
--
-- Algorithm    : The algorithm is described in the implementation note of
--                section 3.4 of the PCI standard:
--                The bus is granted by two nested round-robbing loops.
--                An agent number and a priority level is assigned to each agent.
--                The agent number determines, the pair of req_n/gnt_n lines.
--                Agents are counted from 0 to NB_AGENTS-1.
--                All agents in one level have equal access to the bus
--                (round-robbing); all agents of level 1 as a group have access
--                equal to each agent of level 0.
--                Re-arbitration occurs, when frame_n is asserted, as soon
--                as any other master has requested the bus, but only
--                once per transaction.
--
--                b) With programmable priorities. The priority level of all
--                   agents (except NB_AGENTS-1) is  programmable via APB.
--                   In a 256 byte APB address range, the priority level of
--                   agent N is accessed via the address 0x80 + 4*N. The APB
--                   slave returns 0 on all non-implemented addresses, the
--                   address bits (1:0) are not decoded. Since only addresses
--                   >= 0x80 are occupied, it can be used in parallel (ored
--                   read data) with our PCI interface (uses <= 0x78).
--                   The constant ARB_LVL_C in pci_arb_pkg is the reset value.
--
-- Timeout:       The "broken master" timeout is another reason for
--                re-arbitration (section 3.4.1 of the standard). Grant is
--                removed from an agent, which has not started a cycle
--                within 16 cycles after request (and grant). Reporting of
--                such a 'broken' master is not implemented.
--
-- Turnover:      A turnover cycle is required by the standard, when re-
--                arbitration occurs during idle state of the bus.
--                Notwithstanding to the standard, "idle state" is assumed,
--                when frame_n is high for more than 1 cycle.
--
-- Bus parking  : The bus is parked to agent 0 after reset, it remains granted
--                to the last owner, if no other agent requests the bus.
--                When another request is asserted, re-arbitration occurs
--                after one turnover cycle.
--
-- Lock         : Lock is defined as a resource lock by the PCI standard.
--                The optional bus lock mentioned in the standard is not
--                considered here and there are no special conditions to
--                handle when lock_n is active.
--                in arbitration.
--
-- Latency      : Latency control in PCI is via the latency counters of each
--                agent. The arbiter does not perform any latency check and
--                a once granted agent continues its transaction until its
--                grant is removed AND its own latency counter has expired.
--                Even though, a bus re-arbitration occurs during a
--                transaction, the hand-over only becomes effective,
--                when the current owner deasserts frame_n.
--
-- Limitations  : [add here known bugs and limitations]
--
-- Library      : work
--
-- Dependencies : LEON config package
--                package amba, can be retrieved from:
--                http:
--
-- Author       : Roland Weigand  <Roland.Weigand@gmx.net>
--                European Space Agency (ESA)
--                Microelectronics Section (TOS-ESM)
--                P.O. Box 299
--                NL-2200 AG Noordwijk ZH
--                The Netherlands
--
-- Contact      : mailto:microelectronics@estec.esa.int
--                http:

-- Copyright (C): European Space Agency (ESA) 2002.
--                This source code is free software; you can redistribute it
--                and/or modify it under the terms of the GNU Lesser General
--                Public License as published by the Free Software Foundation;
--                either version 2 of the License, or (at your option) any
--                later version. For full details of the license see file
--                http:
--
--                It is recommended that any use of this VHDL source code is
--                reported to the European Space Agency. It is also recommended
--                that any use of the VHDL source code properly acknowledges the
--                European Space Agency as originator.

-- Disclaimer   : All information is provided "as is", there is no warranty that
--                the information is correct or suitable for any purpose,
--                neither implicit nor explicit. This information does not
--                necessarily reflect the policy of the European Space Agency.
--
-- Simulator    : Modelsim 5.5e on Linux RedHat 7.2
--
-- Synthesis    : Synopsys Version 1999.10 on Sparc + Solaris 5.5.1
--
--------------------------------------------------------------------------------
-- Version  Author   Date       Changes
--
-- 0.0      R. W.    2000/11/02 File created
-- 0.1      J.Gaisler     2001/04/10   Integrated in LEON
-- 0.2      R. Weigand    2001/04/25   Connect arb_lvl reg to AMBA clock/reset
-- 0.3      R. Weigand    2002/03/19   Default assignment to owneri in find_next
-- 1.0      RW.           2002/04/08   Implementation of TMR registers
--                                     Removed recursive function call
--                                     Fixed ARB_LEVELS = 2
-- 3.0      R. Weigand    2002/04/16   Released for leon2
-- 4.0      M. Isomaki    2004/10/19   Minor changes for GRLIB integration
-- 4.1      J.Gaisler     2004/11/17   Minor changes for GRLIB integration
--$Log$
-- Revision 3.1  2002/07/31 13:22:09  weigand
-- Bugfix for cases where no valid request in level 0 (level 1 was not rearbitrated)
--
-- Revision 3.0  2002/07/24 12:19:38  weigand
-- Installed RCS with version 3.0
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;

library esa;
use esa.pci_arb_pkg.all;

entity pci_arb is
   generic(NB_AGENTS : integer  := 4;
	   ARB_SIZE  : integer  := 2;
	   APB_EN    : integer  := 1
	   );
   port (clk     : in  clk_type;                            -- clock
         rst_n   : in  std_logic;                           -- async reset active low
         req_n   : in  std_logic_vector(0 to NB_AGENTS-1);  -- bus request
         frame_n : in  std_logic;
         gnt_n   : out std_logic_vector(0 to NB_AGENTS-1);  -- bus grant
         pclk    : in  clk_type;                            -- APB clock
         prst_n  : in  std_logic;                           -- APB reset
         pbi     : in  EAPB_Slv_In_Type;                     -- APB inputs
         pbo     : out EAPB_Slv_Out_Type                     -- APB outputs
         );

end pci_arb;


architecture rtl of pci_arb is

   subtype agent_t is std_logic_vector(ARB_SIZE-1 downto 0);
   subtype arb_lvl_t is std_logic_vector(NB_AGENTS-1 downto 0);
   subtype agentno_t is integer range 0 to NB_AGENTS-1;

   -- Note: the agent with the highest index (3, 7, 15, 31) is always in level 1
   -- Example: x010 = prio 0 for agent 2 and 0, prio 1 for agent 3 and 1.
   -- Default: start with all devices equal priority at level 1.
   constant ARB_LVL_C : arb_lvl_t := (others => '1');

   constant all_ones : std_logic_vector(0 to NB_AGENTS-1) := (others => '1');

   --Necessary definitions from amba.vhd and iface.vhd
   --added to pci_arb package with modified names to avoid
   --name clashes in GRLIB

   constant APB_PRIOS : boolean := APB_EN = 1;

   signal owner0, owneri0   : agent_t;  -- current owner in level 0
   signal owner1, owneri1   : agent_t;  -- current owner in level 1
   signal cown, cowni       : agent_t;  -- current level
   signal rearb, rearbi     : std_logic;            -- re-arbitration flag
   signal tout, touti       : std_logic_vector(3 downto 0);  -- timeout counter
   signal turn, turni       : std_logic;            -- turnaround cycle
   signal arb_lvl, arb_lvli : arb_lvl_t := ARB_LVL_C;  -- level registers

   type nmstarr is array (0 to 3) of agentno_t;
   type nvalarr is array (0 to 3) of boolean;


begin  -- rtl

   ----------------------------------------------------------------------------
   -- PCI ARBITER
   ----------------------------------------------------------------------------
   -- purpose: Grants the bus depending on the request signals. All agents have
   -- equal priority, if another request occurs during a transaction, the bus is
   -- granted to the new agent. However, PCI protocol specifies that the master
   -- can finish the current transaction within the limit of its latency timer.
   arbiter : process(cown, owner0, owner1, req_n, rearb, tout, turn, frame_n,
                     arb_lvl, rst_n)

      variable owner0v, owner1v : agentno_t;  -- integer variables for current owner
      variable new_request      : agentno_t;  -- detected request
      variable nmst             : nmstarr;
      variable nvalid           : nvalarr;

   begin  -- process arbiter

      -- default assignments
      rearbi  <= rearb;
      owneri0 <= owner0;
      owneri1 <= owner1;
      cowni   <= cown;
      touti   <= tout;
      turni   <= '0';                    -- no turnaround

      -- re-arbitrate once during the transaction,
      -- or when timeout counter expired (bus idle).
      if (frame_n = '0' and rearb = '0') or turn = '1' then

         owner0v        := conv_integer(owner0);
         owner1v        := conv_integer(owner1);
         new_request    := conv_integer(cown);
         nvalid(0 to 3) := (others => false);
         nmst(0 to 3)   := (others => 0);

         -- Determine next request in both priority levels
         rob : for i in NB_AGENTS-1 downto 0 loop
            -- consider all masters with valid request
            if req_n(i) = '0' then
               -- next in prio level 0
               if arb_lvl(i) = '0' then
                  if i > owner0v then
                     nmst(0) := i; nvalid(0) := true;
                  elsif i < owner0v then
                     nmst(1) := i; nvalid(1) := true;
                  end if;
               -- next in prio level 1
               elsif arb_lvl(i) = '1' then
                  if i > owner1v then
                     nmst(2) := i; nvalid(2) := true;
                  elsif i < owner1v then
                     nmst(3) := i; nvalid(3) := true;
                  end if;
               end if;                  -- arb_lvl
            end if;                     -- req_n
         end loop rob;

         -- select new master
         if nvalid(0) then              -- consider level 0 before wrap
            new_request    := nmst(0);
            owner0v        := nmst(0);
         -- consider level 1 only once, except when no request in level 0
         elsif owner0v /= NB_AGENTS-1 or not nvalid(1) then
            if nvalid(2) then           -- level 1 before wrap
               new_request := nmst(2);
               owner0v     := NB_AGENTS-1;
               owner1v     := nmst(2);
            elsif nvalid(3) then        -- level 1 after wrap
               new_request := nmst(3);
               owner0v     := NB_AGENTS-1;
               owner1v     := nmst(3);
            end if;
         elsif nvalid(1) then           -- level 0 after wrap
            new_request    := nmst(1);
            owner0v        := nmst(1);
         end if;

         owneri0 <= conv_std_logic_vector(owner0v, ARB_SIZE);
         owneri1 <= conv_std_logic_vector(owner1v, ARB_SIZE);

         -- rearbitration if any request asserted & different from current owner
         if conv_integer(cown) /= new_request then
            -- if idle state: turnaround cycle required by PCI standard
            cowni <= conv_std_logic_vector(new_request, ARB_SIZE);
            touti <= "0000";                 -- reset timeout counter
            if turn = '0' then
               rearbi <= '1';           -- only one re-arbitration
            end if;
         end if;
      elsif frame_n = '1' then
         rearbi <= '0';
      end if;

      -- if frame deasserted, but request asserted: count timeout
      if req_n = all_ones then          -- no request: prepare timeout counter
         touti <= "1111";
      elsif frame_n = '1' then          -- request, but no transaction
         if tout = "1111" then              -- timeout expired, re-arbitrate
            turni <= '1';               -- remove grant, turnaround cycle
            touti <= "0000";                 -- next cycle re-arbitrate
         else
            touti <= tout + 1;
         end if;
      end if;

      grant : for i in 0 to NB_AGENTS-1 loop
         if i = conv_integer(cown) and turn = '0' then
            gnt_n(i) <= '0';
         else
            gnt_n(i) <= '1';
         end if;
      end loop grant;

      -- synchronous reset
      if rst_n = '0' then
         touti    <= "0000";
         cowni    <= (others => '0');
         owneri0  <= (others => '0');
         owneri1  <= (others => '0');
         rearbi   <= '0';
         turni    <= '0';
         new_request := 0;
      end if;

   end process arbiter;

   arb_lvl(NB_AGENTS-1) <= '1';  -- always prio 1.

   fixed_prios : if not APB_PRIOS generate  -- assign constant value
      arb_lvl(NB_AGENTS-2 downto 0) <= ARB_LVL_C(NB_AGENTS-2 downto 0);
   end generate fixed_prios;

   -- Generate APB regs and APB slave
   apbgen : if APB_PRIOS generate
      -- purpose: APB read and write of arb_lvl configuration registers
      -- type:    memoryless
      -- inputs:  pbi, arb_lvl, prst_n
      -- outputs: pbo, arb_lvli
      config : process (pbi, arb_lvl, prst_n)

      begin  -- process config
         arb_lvli <= arb_lvl;

         pbo.PRDATA <= (others => '0');  -- default for unimplemented addresses

         -- register select at (byte-) addresses 0x80
         if pbi.PADDR(7 downto 0) = "10000000" and pbi.PSEL = '1' then -- address select
            if (pbi.PWRITE and pbi.PENABLE) = '1' then  -- APB write
                  arb_lvli <= pbi.PWDATA(NB_AGENTS-1 downto 0);
            end if;
            pbo.PRDATA(NB_AGENTS-1 downto 0) <= arb_lvl;
         end if;
         -- synchronous reset
         if prst_n = '0' then
            arb_lvli <= ARB_LVL_C;          -- assign default value
         end if;
      end process config;

      -- APB registers

      apb_regs : process (pclk)
      begin  -- process regs
         -- activities triggered by asynchronous reset (active low)
         if pclk'event and pclk = '1' then  -- '
            arb_lvl(NB_AGENTS-2 downto 0) <= arb_lvli(NB_AGENTS-2 downto 0);
         end if;
      end process apb_regs;

   end generate apbgen;

   -- PCI registers

   regs0 : process (clk)

   begin  -- process regs
      if clk'event and clk = '1' then  -- '
         tout    <= touti;
         owner0  <= owneri0;
         owner1  <= owneri1;
         cown    <= cowni;
         rearb   <= rearbi;
         turn    <= turni;
      end if;
   end process regs0;

end rtl;



