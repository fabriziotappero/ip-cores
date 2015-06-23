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

-- PROGRAM		"Quartus II"
-- VERSION		"Version 8.1 Build 163 10/28/2008 SJ Web Edition"
-- CREATED ON		"Sun Jun 14 20:47:40 2009"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY RecvMasterTb IS 
	PORT
	(
		CLC :  IN  STD_LOGIC;
		Start :  IN  STD_LOGIC;
		CotinueStart :  IN  STD_LOGIC;
		ShutDown :  IN  STD_LOGIC;
		Res :  IN  STD_LOGIC;
		SDI :  IN  STD_LOGIC;
		SCK :  OUT  STD_LOGIC;
		nSS :  OUT  STD_LOGIC;
		ready :  OUT  STD_LOGIC;
		SDO :  OUT  STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END RecvMasterTb;

LIBRARY lib;
USE lib.all;
ARCHITECTURE bdf_type OF RecvMasterTb IS 

COMPONENT adcrecv
GENERIC (DataLen : INTEGER;
			DataOffset : INTEGER;
			QuietLen : INTEGER;
			SDLen : INTEGER;
			SDMax : INTEGER;
			SPILen : INTEGER
			);
	PORT(CLK : IN STD_LOGIC;
		 Start : IN STD_LOGIC;
		 ContinueStart : IN STD_LOGIC;
		 ShutDown : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 SDI : IN STD_LOGIC;
		 SCK : OUT STD_LOGIC;
		 nSS : OUT STD_LOGIC;
		 Ready : OUT STD_LOGIC;
		 Shift : OUT STD_LOGIC;
		 DQ : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END COMPONENT;



BEGIN 



b2v_inst : adcrecv
GENERIC MAP(DataLen => 10,
			DataOffset => 6,
			QuietLen => 1,
			SDLen => 1,
			SDMax => 10,
			SPILen => 16
			)
PORT MAP(CLK => CLC,
		 Start => Start,
		 ContinueStart => CotinueStart,
		 ShutDown => ShutDown,
		 reset => Res,
		 SDI => SDI,
		 SCK => SCK,
		 nSS => nSS,
		 Ready => ready,
		 DQ => SDO);


END bdf_type;