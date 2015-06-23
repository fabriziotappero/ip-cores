----------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2004 GAISLER RESEARCH
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
-----------------------------------------------------------------------------
-- Package: 	components
-- File:	components.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Component declaration of Cypress sync-sram
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

package components is

  component cy7c1354

    generic (

	fname  : string := "sram.srec"; -- File to read from
			 
        -- Constant parameters
	addr_bits : INTEGER := 18;
	data_bits : INTEGER := 36;

        -- Timing parameters for -5 (225 Mhz)
        tCYC	: TIME    := 4.4 ns;
        tCH	: TIME    :=  1.8 ns;
        tCL	: TIME    :=  1.8 ns;
        tCO	: TIME    :=  2.8 ns;
        tAS	: TIME    :=  1.4 ns;
        tCENS	: TIME    :=  1.4 ns;
        tWES	: TIME    :=  1.4 ns;
        tDS	: TIME    :=  1.4 ns;
        tAH	: TIME    :=  0.4 ns;
        tCENH	: TIME    :=  0.4 ns;
        tWEH	: TIME    :=  0.4 ns;
        tDH	: TIME    :=  0.4 ns


     
        -- Timing parameters for -5 (200 Mhz)
        --tCYC	: TIME    := 5.0 ns;
        --tCH	: TIME    :=  2.0 ns;
        --tCL	: TIME    :=  2.0 ns;
        --tCO	: TIME    :=  3.2 ns;
        --tAS	: TIME    :=  1.5 ns;
        --tCENS	: TIME    :=  1.5 ns;
        --tWES	: TIME    :=  1.5 ns;
        --tDS	: TIME    :=  1.5 ns;
        --tAH	: TIME    :=  0.5 ns;
        --tCENH	: TIME    :=  0.5 ns;
        --tWEH	: TIME    :=  0.5 ns;
        --tDH	: TIME    :=  0.5 ns
         

        -- Timing parameters for -5 (166 Mhz)
        --tCYC	: TIME    := 6.0 ns;
        --tCH	: TIME    :=  2.4 ns;
        --tCL	: TIME    :=  2.4 ns;
        --tCO	: TIME    :=  3.5 ns;
        --tAS	: TIME    :=  1.5 ns;
        --tCENS	: TIME    :=  1.5 ns;
        --tWES	: TIME    :=  1.5 ns;
        --tDS	: TIME    :=  1.5 ns;
        --tAH	: TIME    :=  0.5 ns;
        --tCENH	: TIME    :=  0.5 ns;
        --tWEH	: TIME    :=  0.5 ns;
        --tDH	: TIME    :=  0.5 ns

         );
    -- Port Declarations
    PORT (
	Dq	: INOUT STD_LOGIC_VECTOR ((data_bits - 1) DOWNTO 0);   	-- Data I/O
	Addr	: IN	STD_LOGIC_VECTOR ((addr_bits - 1) DOWNTO 0);   	-- Address
	Mode	: IN	STD_LOGIC	:= '1'; 			-- Burst Mode
	Clk	: IN	STD_LOGIC;                                   -- Clk
	CEN_n	: IN	STD_LOGIC;                                   -- CEN#
	AdvLd_n	: IN	STD_LOGIC;                                   -- Adv/Ld#
	Bwa_n	: IN	STD_LOGIC;                                   -- Bwa#
	Bwb_n	: IN	STD_LOGIC;                                   -- BWb#
	Bwc_n	: IN	STD_LOGIC;                                   -- Bwc#
	Bwd_n	: IN	STD_LOGIC;                                   -- BWd#
	Rw_n	: IN	STD_LOGIC;                                   -- RW#
	Oe_n	: IN	STD_LOGIC;                                   -- OE#
	Ce1_n	: IN	STD_LOGIC;                                   -- CE1#
	Ce2	: IN	STD_LOGIC;                                   -- CE2
	Ce3_n	: IN	STD_LOGIC;                                   -- CE3#
	Zz	: IN	STD_LOGIC                                    -- Snooze Mode
    );

  end component;

  component CY7C1380D
     GENERIC (
	fname  : string := "sram.srec"; -- File to read from
        -- Constant Parameters
        addr_bits : INTEGER :=      19;         -- This is external address
        data_bits : INTEGER :=      36; 

--Clock timings for 250Mhz
        Cyp_tCO   : TIME := 	2.6 ns;	-- Data Output Valid After CLK Rise

        Cyp_tCYC  : TIME := 	4.0 ns;  -- Clock cycle time
        Cyp_tCH   : TIME :=	        1.7 ns;	-- Clock HIGH time
        Cyp_tCL   : TIME :=	        1.7 ns;	-- Clock LOW time

        Cyp_tCHZ  : TIME := 	2.6 ns;	-- Clock to High-Z
        Cyp_tCLZ  : TIME := 	1.0 ns;	-- Clock to Low-Z
        Cyp_tOEHZ : TIME :=         2.6 ns;	-- OE# HIGH to Output High-Z
        Cyp_tOELZ : TIME :=         0.0 ns;	-- OE# LOW to Output Low-Z 
        Cyp_tOEV  : TIME :=         2.6 ns;	-- OE# LOW to Output Valid 

        Cyp_tAS   : TIME := 	1.2 ns;	-- Address Set-up Before CLK Rise
        Cyp_tADS  : TIME := 	1.2 ns;	-- ADSC#, ADSP# Set-up Before CLK Rise
        Cyp_tADVS : TIME :=         1.2 ns;	-- ADV# Set-up Before CLK Rise
        Cyp_tWES  : TIME :=	        1.2 ns;	-- BWx#, GW#, BWE# Set-up Before CLK Rise
        Cyp_tDS   : TIME :=	        1.2 ns;	-- Data Input Set-up Before CLK Rise
        Cyp_tCES  : TIME :=	        1.2 ns;	-- Chip Enable Set-up 

        Cyp_tAH   : TIME := 	0.3 ns;	-- Address Hold After CLK Rise
        Cyp_tADH  : TIME := 	0.3 ns;	-- ADSC#, ADSP# Hold After CLK Rise
        Cyp_tADVH : TIME :=         0.3 ns;	-- ADV# Hold After CLK Rise
        Cyp_tWEH  : TIME :=	        0.3 ns;	-- BWx#, GW#, BWE# Hold After CLK Rise
        Cyp_tDH   : TIME := 	0.3 ns;	-- Data Input Hold After CLK Rise
        Cyp_tCEH  : TIME := 	0.3 ns	-- Chip Enable Hold After CLK Rise

        );
        PORT (iZZ : IN STD_LOGIC;
              iMode : IN STD_LOGIC;
              iADDR : IN STD_LOGIC_VECTOR ((addr_bits -1) downto 0);
              inGW : IN STD_LOGIC;
              inBWE : IN STD_LOGIC;
              inBWd : IN STD_LOGIC;
              inBWc : IN STD_LOGIC;
              inBWb : IN STD_LOGIC;
              inBWa : IN STD_LOGIC;
              inCE1 : IN STD_LOGIC;
              iCE2 : IN STD_LOGIC;
              inCE3 : IN STD_LOGIC;
              inADSP : IN STD_LOGIC;
              inADSC : IN STD_LOGIC;
              inADV : IN STD_LOGIC;
              inOE : IN STD_LOGIC;
              ioDQ : INOUT STD_LOGIC_VECTOR ((data_bits-1) downto 0);
              iCLK : IN STD_LOGIC);

  end component;

end;

-- pragma translate_on
