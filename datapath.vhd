-- Copyright (C) 1991-2009 Altera Corporation
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
-- VERSION		"Version 9.0 Build 235 06/17/2009 Service Pack 2 SJ Web Edition"
-- CREATED ON		"Wed May 26 16:13:38 2010"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY datapath IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		clk_en :  IN  STD_LOGIC;
		aclr :  IN  STD_LOGIC;
		dataa :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		datab :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		sel :  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		NaN :  OUT  STD_LOGIC;
		underflow :  OUT  STD_LOGIC;
		zero :  OUT  STD_LOGIC;
		overflow :  OUT  STD_LOGIC;
		division_by_zero :  OUT  STD_LOGIC;
		result :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END datapath;

ARCHITECTURE bdf_type OF datapath IS 

COMPONENT ci_altfp_add_sub
	PORT(aclr : IN STD_LOGIC;
		 clk_en : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 dataa : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 datab : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 nan : OUT STD_LOGIC;
		 overflow : OUT STD_LOGIC;
		 underflow : OUT STD_LOGIC;
		 zero : OUT STD_LOGIC;
		 result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT lpm_mux0
	PORT(data0x : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 data1x : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 data2x : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;



--component lpm_mux1
--	PORT
--	(
--		data0x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--		data1x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--		data2x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--		sel		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
--		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
--	);
--end component;



COMPONENT ci_altfp_div
	PORT(aclr : IN STD_LOGIC;
		 clk_en : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 dataa : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 datab : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 division_by_zero : OUT STD_LOGIC;
		 nan : OUT STD_LOGIC;
		 overflow : OUT STD_LOGIC;
		 underflow : OUT STD_LOGIC;
		 zero : OUT STD_LOGIC;
		 result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ci_altfp_mult
	PORT(aclr : IN STD_LOGIC;
		 clk_en : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 dataa : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 datab : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 nan : OUT STD_LOGIC;
		 overflow : OUT STD_LOGIC;
		 underflow : OUT STD_LOGIC;
		 zero : OUT STD_LOGIC;
		 result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;


BEGIN 



b2v_inst1 : ci_altfp_add_sub
PORT MAP(aclr => aclr,
		 clk_en => clk_en,-- and sel(0) and not sel(1),
		 clock => clk,
		 dataa => dataa,
		 datab => datab,
		 nan => SYNTHESIZED_WIRE_14,
		 overflow => SYNTHESIZED_WIRE_11,
		 underflow => SYNTHESIZED_WIRE_8,
		 zero => SYNTHESIZED_WIRE_5,
		 result => SYNTHESIZED_WIRE_1);


b2v_inst10 : lpm_mux0
PORT MAP(data0x => SYNTHESIZED_WIRE_0,
		 data1x => SYNTHESIZED_WIRE_1,
		 data2x => SYNTHESIZED_WIRE_2,
		 sel => sel,
		 result => result);
		 



b2v_inst2 : ci_altfp_div
PORT MAP(aclr => aclr,
		 clk_en => clk_en, -- and not sel(0) and sel(1),
		 clock => clk,
		 dataa => dataa,
		 datab => datab,
		 division_by_zero => division_by_zero,
		 nan => SYNTHESIZED_WIRE_12,
		 overflow => SYNTHESIZED_WIRE_9,
		 underflow => SYNTHESIZED_WIRE_6,
		 zero => SYNTHESIZED_WIRE_3,
		 result => SYNTHESIZED_WIRE_2);


b2v_inst3 : ci_altfp_mult
PORT MAP(aclr => aclr,
		 clk_en => clk_en, -- and not sel(0) and not sel(1) ,
		 clock => clk,
		 dataa => dataa,
		 datab => datab,
		 nan => SYNTHESIZED_WIRE_13,
		 overflow => SYNTHESIZED_WIRE_10,
		 underflow => SYNTHESIZED_WIRE_7,
		 zero => SYNTHESIZED_WIRE_4,
		 result => SYNTHESIZED_WIRE_0);


zero <= SYNTHESIZED_WIRE_3 OR SYNTHESIZED_WIRE_4 OR SYNTHESIZED_WIRE_5;


underflow <= SYNTHESIZED_WIRE_6 OR SYNTHESIZED_WIRE_7 OR SYNTHESIZED_WIRE_8;


overflow <= SYNTHESIZED_WIRE_9 OR SYNTHESIZED_WIRE_10 OR SYNTHESIZED_WIRE_11;


NaN <= SYNTHESIZED_WIRE_12 OR SYNTHESIZED_WIRE_13 OR SYNTHESIZED_WIRE_14;


END bdf_type;