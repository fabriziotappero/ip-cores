-------------------------------------------------------------------------------
----                                                                       ----
---- WISHBONE Wishbone_BFM IP Core                                         ----
----                                                                       ----
---- This file is part of the Wishbone_BFM project                         ----
---- http://www.opencores.org/cores/Wishbone_BFM/                          ----
----                                                                       ----
---- Description                                                           ----
---- Implementation of Wishbone_BFM IP core according to                   ----
---- Wishbone_BFM IP core specification document.                          ----
----                                                                       ----
---- To Do:                                                                ----
----	NA                                                                 ----
----                                                                       ----
---- Author(s):                                                            ----
----   Andrew Mulcock, amulcock@opencores.org                              ----
----                                                                       ----
-------------------------------------------------------------------------------
----                                                                       ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG                          ----
----                                                                       ----
---- This source file may be used and distributed without                  ----
---- restriction provided that this copyright statement is not             ----
---- removed from the file and that any derivative work contains           ----
---- the original copyright notice and the associated disclaimer.          ----
----                                                                       ----
---- This source file is free software; you can redistribute it            ----
---- and/or modify it under the terms of the GNU Lesser General            ----
---- Public License as published by the Free Software Foundation           ----
---- either version 2.1 of the License, or (at your option) any            ----
---- later version.                                                        ----
----                                                                       ----
---- This source is distributed in the hope that it will be                ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied            ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               ----
---- PURPOSE. See the GNU Lesser General Public License for more           ----
---- details.                                                              ----
----                                                                       ----
---- You should have received a copy of the GNU Lesser General             ----
---- Public License along with this source; if not, download it            ----
---- from http://www.opencores.org/lgpl.shtml                              ----
----                                                                       ----
-------------------------------------------------------------------------------
----                                                                       ----
-- CVS Revision History                                                    ----
----                                                                       ----
-- $Log: not supported by cvs2svn $                                                                   ----
----                                                                       ----

--
-- wbtb_1m_1s
-- 
-- this testbench joins together 
--  one wishbone master and one wishbone slave,
--  along with the required sys_con module
--
--  having only on emaster and one slave, no logic is 
--   required, outputs of one connect to inputs of the other.
--


use work.io_pack.all;

library ieee;
use ieee.std_logic_1164.all;

ENTITY wbtb_1m_1s_vhd IS
END wbtb_1m_1s_vhd;

ARCHITECTURE behavior OF wbtb_1m_1s_vhd IS 

	-- Component Declaration for wishbone system controler
	COMPONENT syscon
	PORT(
        RST_sys    : in  std_logic;
        CLK_stop   : in  std_logic;
        RST_O      : out std_logic;
        CLK_O      : out std_logic
		);
	END COMPONENT;

	-- Component Declaration for wishbone master
	COMPONENT wb_master
	PORT(
		RST_I    : IN std_logic;
		CLK_I    : IN std_logic;
		DAT_I    : IN std_logic_vector(31 downto 0);
		ACK_I    : IN std_logic;
		ERR_I    : IN std_logic;
		RTY_I    : IN std_logic;
		SEL_O    : OUT std_logic_vector(3 downto 0);          
		RST_sys  : OUT std_logic;
		CLK_stop : OUT std_logic;
		ADR_O    : OUT std_logic_vector(31 downto 0);
		DAT_O    : OUT std_logic_vector(31 downto 0);
		WE_O     : OUT std_logic;
		STB_O    : OUT std_logic;
		CYC_O    : OUT std_logic;
		LOCK_O   : OUT std_logic;
        CYCLE_IS : OUT cycle_type
		);
	END COMPONENT;


	-- Component Declaration for wishbone slave
	COMPONENT wb_mem_32x16
	PORT(
        ACK_O   : out   std_logic;
        ADR_I   : in    std_logic_vector( 3 downto 0 );
        CLK_I   : in    std_logic;
        DAT_I   : in    std_logic_vector( 31 downto 0 );
        DAT_O   : out   std_logic_vector( 31 downto 0 );
        STB_I   : in    std_logic;
        WE_I    : in    std_logic
   		);
	END COMPONENT;

	--Inputs
	SIGNAL RST_I :  std_logic := '0';
	SIGNAL CLK_I :  std_logic := '0';
	SIGNAL ACK_I :  std_logic := '0';
	SIGNAL ERR_I :  std_logic := '0';
	SIGNAL RTY_I :  std_logic := '0';
	SIGNAL DAT_I :  std_logic_vector(31 downto 0) := (others=>'0');

	--Outputs
	SIGNAL RST_sys  :  std_logic;
	SIGNAL CLK_stop :  std_logic;
	SIGNAL ADR_O    :  std_logic_vector(31 downto 0);
	SIGNAL DAT_O    :  std_logic_vector(31 downto 0);
	SIGNAL WE_O     :  std_logic;
	SIGNAL STB_O    :  std_logic;
	SIGNAL CYC_O    :  std_logic;
	SIGNAL LOCK_O   :  std_logic;
	SIGNAL SEL_O    :  std_logic_vector(3 downto 0);
    SIGNAL CYCLE_IS : cycle_type;


-- ---------------------------------------------------------------
BEGIN
-- ---------------------------------------------------------------
 -- module port  => signal name
	-- Instantiate the system controler
	sys_con: syscon PORT MAP(
		RST_sys  => RST_sys,
		CLK_stop => CLK_stop,
		RST_O    => RST_I,
		CLK_O    => CLK_I
	);

	-- Instantiate the wishbone master
	wb_m1: wb_master PORT MAP(
		RST_sys  => RST_sys,
		CLK_stop => CLK_stop,
		RST_I    => RST_I,
		CLK_I    => CLK_I,
		ADR_O    => ADR_O,
		DAT_I    => DAT_I,
		DAT_O    => DAT_O,
		WE_O     => WE_O,
		STB_O    => STB_O,
		CYC_O    => CYC_O,
		ACK_I    => ACK_I,
		ERR_I    => ERR_I,
		RTY_I    => RTY_I,
		LOCK_O   => LOCK_O,
		SEL_O    => SEL_O,
        CYCLE_IS => CYCLE_IS
	);


	-- Instantiate the wishbone slave
	wb_s1: wb_mem_32x16 PORT MAP(
        ACK_O => ACK_I,
        ADR_I => ADR_O( 3 downto 0 ),
        CLK_I => CLK_I,
        DAT_I => DAT_O,
        DAT_O => DAT_I,
        STB_I => STB_O,
        WE_I  => WE_O
	);


END;
