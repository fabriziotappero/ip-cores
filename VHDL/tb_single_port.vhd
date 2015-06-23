----------------------------------------------------------------------
----                                                              ----
---- Single port asynchronous RAM simulation model                ----
----                                                              ----
---- This file is part of the single_port project                 ----
----                                                              ----
---- Description                                                  ----
---- This file specifies test bench harness for the single_port   ----
---- Memory. It also contains the configuration files for all the ----
---- tests.                                                       ----
----                                                              ----
---- Authors:                                                     ----
---- - Robert Paley, rpaley_yid@yahoo.com                         ----
---- - Michael Geng, vhdl@MichaelGeng.de                          ----
----                                                              ----
---- References:                                                  ----
----   1. The Designer's Guide to VHDL by Peter Ashenden          ----
----      ISBN: 1-55860-270-4 (pbk.)                              ----
----   2. Writing Testbenches - Functional Verification of HDL    ----
----      models by Janick Bergeron | ISBN: 0-7923-7766-4         ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2005 Authors and OPENCORES.ORG                 ----
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
-- Revision 1.2  2005/10/12 19:39:27  mgeng
-- Buses unconstrained, LGPL header added
--
-- Revision 1.1.1.1  2003/01/14 21:48:11  rpaley_yid
-- initial checkin 
--
-- Revision 1.1  2003/01/14 17:49:04  Default
-- Initial revision
--
-- Revision 1.2  2002/12/31 19:19:43  Default
-- Updated 'transaction statements for fixed simulator.
--
-- Revision 1.1  2002/12/24 18:10:18  Default
-- Initial revision
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.linked_list_mem_pkg.ALL;
USE WORK.single_port_pkg.all;
USE STD.TEXTIO.ALL;

ENTITY tb_single_port IS
END ENTITY tb_single_port;

ARCHITECTURE BHV of tb_single_port IS

COMPONENT single_port IS
  GENERIC (
    rnwtQ : TIME := 1 NS);
  PORT (
    d           : IN STD_LOGIC_VECTOR;
    q           : OUT STD_LOGIC_VECTOR;
    a           : IN STD_LOGIC_VECTOR;
    nce         : IN  STD_LOGIC;
    nwe         : IN  STD_LOGIC;
    noe         : IN  STD_LOGIC;
    dealloc_mem : BOOLEAN);
END COMPONENT single_port;  

COMPONENT tc_single_port IS
  PORT (
    to_srv  : OUT to_srv_typ;
    frm_srv : IN  STD_LOGIC_VECTOR);
END COMPONENT tc_single_port;
  CONSTANT DATA_WIDTH : INTEGER := 32;
  CONSTANT ADDR_WIDTH : INTEGER := 16;

  SIGNAL d             : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
  SIGNAL q             : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
  SIGNAL a             : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
  SIGNAL nce, nwe, noe : STD_LOGIC;
  SIGNAL dealloc_mem   : BOOLEAN;
  SIGNAL to_srv        : to_srv_typ;
  SIGNAL frm_srv       : STD_LOGIC_VECTOR(d'RANGE);
  SIGNAL tie_vdd       : STD_LOGIC := '1';
BEGIN
  dut : single_port 
    PORT MAP (
      d           => d,
      a           => a,
      q           => q,
      nce         => nce,
      nwe         => nwe,
      noe         => noe,
      dealloc_mem => dealloc_mem);

  tc : tc_single_port
    PORT MAP (
       to_srv  => to_srv,
       frm_srv => frm_srv);

  single_port_server : PROCESS
    VARIABLE frm_srv_v    : STD_LOGIC_VECTOR(d'RANGE);
    CONSTANT ACCESS_DELAY : TIME := 5 NS;
  BEGIN
    -- Wait until the test case is finished setting up the next memory access.
    WAIT ON to_srv'TRANSACTION;
    CASE to_srv.do IS
      WHEN init =>
        ASSERT FALSE
          REPORT "initialized"
          SEVERITY NOTE; 
      WHEN read => -- perform memory read
        d <= STD_LOGIC_VECTOR(TO_SIGNED(to_srv.data, d'length));
        a <= STD_LOGIC_VECTOR(TO_UNSIGNED(to_srv.addr, a'length));
        nce <= '0';
        noe <= '0';
        nwe <= '1';
        -- Wait for data to appear 
        WAIT FOR ACCESS_DELAY;
      WHEN write => -- perform memory write
        d <= STD_LOGIC_VECTOR(TO_SIGNED(to_srv.data, d'length));
        a <= STD_LOGIC_VECTOR(TO_UNSIGNED(to_srv.addr, a'length));
        nce <= '0';
        noe <= '1';
        nwe <= '0';
        WAIT FOR ACCESS_DELAY;
      WHEN dealloc => -- deallocate the linked list for the LL architecture
        dealloc_mem <= true;
      WHEN end_test => -- reached the end of the test case
        WAIT; 
    END CASE;
    frm_srv_v := q;
    -- Send message to test case to continue the test.
    frm_srv <= frm_srv_v ; WAIT FOR 0 NS;
  END PROCESS single_port_server;
END BHV;

CONFIGURATION ll_main_cfg OF TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(LinkedList);
    END FOR; -- dut 
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC0);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION ll_main_cfg;

CONFIGURATION ll_error_cfg OF TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(LinkedList);
    END FOR; -- dut 
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC1);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION ll_error_cfg ;

CONFIGURATION mem_main_cfg of TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(ArrayMem);
    END FOR; -- dut
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC0);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION mem_main_cfg;

CONFIGURATION mem_error_cfg of TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(ArrayMem);
    END FOR; -- dut
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC1);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION mem_error_cfg;

CONFIGURATION memnoflag_main_cfg of TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(ArrayMemNoFlag);
    END FOR; -- dut
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC0);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION memnoflag_main_cfg;

CONFIGURATION memnoflag_error_cfg of TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(ArrayMemNoFlag);
    END FOR; -- dut
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC1);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION memnoflag_error_cfg;
