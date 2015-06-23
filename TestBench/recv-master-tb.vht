-- Copyright (C) 1991-2008 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- *****************************************************************************
-- This file contains a Vhdl test bench with test vectors .The test vectors     
-- are exported from a vector file in the Quartus Waveform Editor and apply to  
-- the top level entity of the current Quartus project .The user can use this   
-- testbench to simulate his design using a third-party simulation tool .       
-- *****************************************************************************
-- Generated on "06/12/2009 19:55:56"
                                                                        
-- Vhdl Self-Checking Test Bench (with test vectors) for design :       RecvMasterTb
-- 
-- Simulation tool : 3rd Party
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY RecvMasterTb_vhd_vec_tst IS
END RecvMasterTb_vhd_vec_tst;
ARCHITECTURE RecvMasterTb_arch OF RecvMasterTb_vhd_vec_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL CLC : STD_LOGIC;
SIGNAL CotinueStart : STD_LOGIC;
SIGNAL nSS : STD_LOGIC;
SIGNAL ready : STD_LOGIC;
SIGNAL Res : STD_LOGIC;
SIGNAL SCK : STD_LOGIC;
SIGNAL SDI : STD_LOGIC;
SIGNAL SDO : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL ShutDown : STD_LOGIC;
SIGNAL Start : STD_LOGIC;
COMPONENT RecvMasterTb
	PORT (
	CLC : IN STD_LOGIC;
	CotinueStart : IN STD_LOGIC;
	nSS : OUT STD_LOGIC;
	ready : OUT STD_LOGIC;
	Res : IN STD_LOGIC;
	SCK : OUT STD_LOGIC;
	SDI : IN STD_LOGIC;
	SDO : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	ShutDown : IN STD_LOGIC;
	Start : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : RecvMasterTb
	PORT MAP (
-- list connections between master ports and signals
	CLC => CLC,
	CotinueStart => CotinueStart,
	nSS => nSS,
	ready => ready,
	Res => Res,
	SCK => SCK,
	SDI => SDI,
	SDO => SDO,
	ShutDown => ShutDown,
	Start => Start
	);

-- CLC
t_prcs_CLC: PROCESS
BEGIN
LOOP
	CLC <= '0';
	WAIT FOR 25000 ps;
	CLC <= '1';
	WAIT FOR 25000 ps;
	IF (NOW >= 100000000 ps) THEN WAIT; END IF;
END LOOP;
END PROCESS t_prcs_CLC;

-- CotinueStart
t_prcs_CotinueStart: PROCESS
BEGIN
	CotinueStart <= '0';
	WAIT FOR 25600000 ps;
	CotinueStart <= '1';
	WAIT FOR 3200000 ps;
	CotinueStart <= '0';
	WAIT FOR 3200000 ps;
	CotinueStart <= '1';
	WAIT FOR 3840000 ps;
	CotinueStart <= '0';
WAIT;
END PROCESS t_prcs_CotinueStart;

-- Res
t_prcs_Res: PROCESS
BEGIN
	Res <= '0';
	WAIT FOR 20000 ps;
	Res <= '1';
	WAIT FOR 40000 ps;
	Res <= '0';
WAIT;
END PROCESS t_prcs_Res;

-- ShutDown
t_prcs_ShutDown: PROCESS
BEGIN
	ShutDown <= '0';
	WAIT FOR 8800000 ps;
	ShutDown <= '1';
	WAIT FOR 3200000 ps;
	ShutDown <= '0';
	WAIT FOR 3040000 ps;
	ShutDown <= '1';
	WAIT FOR 4160000 ps;
	ShutDown <= '0';
	WAIT FOR 1600000 ps;
	ShutDown <= '1';
	WAIT FOR 960000 ps;
	ShutDown <= '0';
WAIT;
END PROCESS t_prcs_ShutDown;

-- Start
t_prcs_Start: PROCESS
BEGIN
	Start <= '0';
	WAIT FOR 420000 ps;
	Start <= '1';
	WAIT FOR 20000 ps;
	Start <= '0';
	WAIT FOR 2440000 ps;
	Start <= '1';
	WAIT FOR 5040000 ps;
	Start <= '0';
	WAIT FOR 1120000 ps;
	Start <= '1';
	WAIT FOR 4640000 ps;
	Start <= '0';
	WAIT FOR 3440000 ps;
	Start <= '1';
	WAIT FOR 160000 ps;
	Start <= '0';
	WAIT FOR 8000000 ps;
	Start <= '1';
	WAIT FOR 160000 ps;
	Start <= '0';
	WAIT FOR 4800000 ps;
	Start <= '1';
	WAIT FOR 160000 ps;
	Start <= '0';
	WAIT FOR 1600000 ps;
	Start <= '1';
	WAIT FOR 160000 ps;
	Start <= '0';
WAIT;
END PROCESS t_prcs_Start;

-- SDI
t_prcs_SDI: PROCESS
BEGIN
	SDI <= '0';
	WAIT FOR 3120000 ps;
	SDI <= '1';
	WAIT FOR 80000 ps;
	SDI <= '0';
	WAIT FOR 480000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 400000 ps;
	SDI <= '1';
	WAIT FOR 160000 ps;
	SDI <= '0';
	WAIT FOR 240000 ps;
	SDI <= '1';
	WAIT FOR 320000 ps;
	SDI <= '0';
	WAIT FOR 240000 ps;
	SDI <= '1';
	WAIT FOR 960000 ps;
	SDI <= '0';
	WAIT FOR 400000 ps;
	SDI <= '1';
	WAIT FOR 80000 ps;
	SDI <= '0';
	WAIT FOR 240000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 160000 ps;
	SDI <= '1';
	WAIT FOR 160000 ps;
	SDI <= '0';
	WAIT FOR 160000 ps;
	SDI <= '1';
	WAIT FOR 480000 ps;
	SDI <= '0';
	WAIT FOR 800000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 560000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 320000 ps;
	SDI <= '1';
	WAIT FOR 320000 ps;
	SDI <= '0';
	WAIT FOR 240000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 400000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 240000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 400000 ps;
	SDI <= '1';
	WAIT FOR 80000 ps;
	SDI <= '0';
	WAIT FOR 160000 ps;
	SDI <= '1';
	WAIT FOR 80000 ps;
	SDI <= '0';
	WAIT FOR 400000 ps;
	SDI <= '1';
	WAIT FOR 400000 ps;
	SDI <= '0';
	WAIT FOR 11760000 ps;
	SDI <= '1';
	WAIT FOR 80000 ps;
	SDI <= '0';
	WAIT FOR 480000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 400000 ps;
	SDI <= '1';
	WAIT FOR 160000 ps;
	SDI <= '0';
	WAIT FOR 240000 ps;
	SDI <= '1';
	WAIT FOR 320000 ps;
	SDI <= '0';
	WAIT FOR 240000 ps;
	SDI <= '1';
	WAIT FOR 960000 ps;
	SDI <= '0';
	WAIT FOR 400000 ps;
	SDI <= '1';
	WAIT FOR 80000 ps;
	SDI <= '0';
	WAIT FOR 240000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 160000 ps;
	SDI <= '1';
	WAIT FOR 160000 ps;
	SDI <= '0';
	WAIT FOR 160000 ps;
	SDI <= '1';
	WAIT FOR 480000 ps;
	SDI <= '0';
	WAIT FOR 800000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 560000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 320000 ps;
	SDI <= '1';
	WAIT FOR 320000 ps;
	SDI <= '0';
	WAIT FOR 240000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 400000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 240000 ps;
	SDI <= '1';
	WAIT FOR 240000 ps;
	SDI <= '0';
	WAIT FOR 400000 ps;
	SDI <= '1';
	WAIT FOR 80000 ps;
	SDI <= '0';
	WAIT FOR 160000 ps;
	SDI <= '1';
	WAIT FOR 80000 ps;
	SDI <= '0';
	WAIT FOR 400000 ps;
	SDI <= '1';
	WAIT FOR 400000 ps;
	SDI <= '0';
WAIT;
END PROCESS t_prcs_SDI;
END RecvMasterTb_arch;
