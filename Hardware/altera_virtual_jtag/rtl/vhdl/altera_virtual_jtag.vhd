----------------------------------------------------------------------
----                                                              ----
----  altera_virtual_jtag.vhd                                     ----
----                                                              ----
----                                                              ----
----                                                              ----
----  Author(s):                                                  ----
----       Nathan Yawn (nathan.yawn@opencores.org)                ----
----                                                              ----
----                                                              ----
----                                                              ----
---------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2008-2010 Authors                              ----
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
---- PURPOSE.  See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
--                                                                  --
-- This file is a wrapper for the Altera Virtual JTAG device.       --
-- It is designed to take the place of a separate TAP               --
-- controller in Altera systems, to allow a user to access a CPU    --
-- debug module (such as that of the OR1200) through the FPGA's     --
-- dedicated JTAG / configuration port.                             --
--                                                                  --
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY altera_virtual_jtag IS
	PORT
	(
		tck_o              : OUT STD_LOGIC;
		debug_tdo_i        :  IN STD_LOGIC;
		tdi_o              : OUT STD_LOGIC;
		test_logic_reset_o : OUT STD_LOGIC;
		run_test_idle_o    : OUT STD_LOGIC;
		shift_dr_o         : OUT STD_LOGIC;
		capture_dr_o       : OUT STD_LOGIC;
		pause_dr_o         : OUT STD_LOGIC;
		update_dr_o        : OUT STD_LOGIC;
		debug_select_o     : OUT STD_LOGIC 
	);
END altera_virtual_jtag;


ARCHITECTURE OC OF altera_virtual_jtag IS

	CONSTANT CMD_DEBUG : STD_LOGIC_VECTOR (3 downto 0) := "1000";

	SIGNAL ir_value	: STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL exit1_dr	: STD_LOGIC;
	SIGNAL exit2_dr	: STD_LOGIC;
	SIGNAL capture_ir	: STD_LOGIC;
	SIGNAL update_ir	: STD_LOGIC;

	COMPONENT sld_virtual_jtag
	GENERIC (
		sld_auto_instance_index : STRING;
		sld_instance_index      : NATURAL;
		sld_ir_width            : NATURAL;
		sld_sim_action          : STRING;
		sld_sim_n_scan          : NATURAL;
		sld_sim_total_length    : NATURAL;
		lpm_type                : STRING
	);
	PORT (
			tdi	: OUT STD_LOGIC ;
			jtag_state_rti	: OUT STD_LOGIC ;
			jtag_state_e1dr	: OUT STD_LOGIC ;
			jtag_state_e2dr	: OUT STD_LOGIC ;
			tms	: OUT STD_LOGIC ;
			jtag_state_pir	: OUT STD_LOGIC ;
			jtag_state_tlr	: OUT STD_LOGIC ;
			tck	: OUT STD_LOGIC ;
			jtag_state_sir	: OUT STD_LOGIC ;
			ir_in	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			virtual_state_cir	: OUT STD_LOGIC ;
			virtual_state_pdr	: OUT STD_LOGIC ;
			ir_out	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			virtual_state_uir	: OUT STD_LOGIC ;
			jtag_state_cir	: OUT STD_LOGIC ;
			jtag_state_uir	: OUT STD_LOGIC ;
			jtag_state_pdr	: OUT STD_LOGIC ;
			tdo	: IN STD_LOGIC ;
			jtag_state_sdrs	: OUT STD_LOGIC ;
			virtual_state_sdr	: OUT STD_LOGIC ;
			virtual_state_cdr	: OUT STD_LOGIC ;
			jtag_state_sdr	: OUT STD_LOGIC ;
			jtag_state_cdr	: OUT STD_LOGIC ;
			virtual_state_udr	: OUT STD_LOGIC ;
			jtag_state_udr	: OUT STD_LOGIC ;
			jtag_state_sirs	: OUT STD_LOGIC ;
			jtag_state_e1ir	: OUT STD_LOGIC ;
			jtag_state_e2ir	: OUT STD_LOGIC ;
			virtual_state_e1dr	: OUT STD_LOGIC ;
			virtual_state_e2dr	: OUT STD_LOGIC 
	);
	END COMPONENT;

BEGIN



	sld_virtual_jtag_component : sld_virtual_jtag
	GENERIC MAP (
		sld_auto_instance_index => "YES",
		sld_instance_index => 0,
		sld_ir_width => 4,
		sld_sim_action => "",
		sld_sim_n_scan => 0,
		sld_sim_total_length => 0,
		lpm_type => "sld_virtual_jtag"
	)
	PORT MAP (
		ir_out => ir_value,
		tdo => debug_tdo_i,
		tdi => tdi_o,
		jtag_state_rti => run_test_idle_o,
		tck => tck_o,
		ir_in => ir_value,
		jtag_state_tlr => test_logic_reset_o,
		virtual_state_cir => capture_ir,
		virtual_state_pdr => pause_dr_o,
		virtual_state_uir => update_ir,
		virtual_state_sdr => shift_dr_o,
		virtual_state_cdr => capture_dr_o,
		virtual_state_udr => update_dr_o,
		virtual_state_e1dr => exit1_dr,
		virtual_state_e2dr => exit2_dr
	);

	debug_select_o <= '1' when (ir_value = CMD_DEBUG) else '0';

END OC;
