--------------------------------------------------------------------------------
--     This file is owned and controlled by Xilinx and must be used           --
--     solely for design, simulation, implementation and creation of          --
--     design files limited to Xilinx devices or technologies. Use            --
--     with non-Xilinx devices or technologies is expressly prohibited        --
--     and immediately terminates your license.                               --
--                                                                            --
--     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"          --
--     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                --
--     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION        --
--     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION            --
--     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS              --
--     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                --
--     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE       --
--     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY               --
--     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                --
--     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         --
--     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        --
--     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        --
--     FOR A PARTICULAR PURPOSE.                                              --
--                                                                            --
--     Xilinx products are not intended for use in life support               --
--     appliances, devices, or systems. Use in such applications are          --
--     expressly prohibited.                                                  --
--                                                                            --
--     (c) Copyright 1995-2003 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- You must compile the wrapper file ctrl_mux16x16.vhd when simulating
-- the core, ctrl_mux16x16. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Guide".

-- The synopsys directives "translate_off/translate_on" specified
-- below are supported by XST, FPGA Compiler II, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

-- synopsys translate_off
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

Library XilinxCoreLib;
ENTITY ctrl_mux16x16 IS
	port (
	MA: IN std_logic_VECTOR(15 downto 0);
	MB: IN std_logic_VECTOR(15 downto 0);
	MC: IN std_logic_VECTOR(15 downto 0);
	MD: IN std_logic_VECTOR(15 downto 0);
	ME: IN std_logic_VECTOR(15 downto 0);
	MF: IN std_logic_VECTOR(15 downto 0);
	MG: IN std_logic_VECTOR(15 downto 0);
	MH: IN std_logic_VECTOR(15 downto 0);
	MAA: IN std_logic_VECTOR(15 downto 0);
	MAB: IN std_logic_VECTOR(15 downto 0);
	MAC: IN std_logic_VECTOR(15 downto 0);
	MAD: IN std_logic_VECTOR(15 downto 0);
	MAE: IN std_logic_VECTOR(15 downto 0);
	MAF: IN std_logic_VECTOR(15 downto 0);
	MAG: IN std_logic_VECTOR(15 downto 0);
	MAH: IN std_logic_VECTOR(15 downto 0);
	S: IN std_logic_VECTOR(3 downto 0);
	O: OUT std_logic_VECTOR(15 downto 0));
END ctrl_mux16x16;

ARCHITECTURE ctrl_mux16x16_a OF ctrl_mux16x16 IS

component wrapped_ctrl_mux16x16
	port (
	MA: IN std_logic_VECTOR(15 downto 0);
	MB: IN std_logic_VECTOR(15 downto 0);
	MC: IN std_logic_VECTOR(15 downto 0);
	MD: IN std_logic_VECTOR(15 downto 0);
	ME: IN std_logic_VECTOR(15 downto 0);
	MF: IN std_logic_VECTOR(15 downto 0);
	MG: IN std_logic_VECTOR(15 downto 0);
	MH: IN std_logic_VECTOR(15 downto 0);
	MAA: IN std_logic_VECTOR(15 downto 0);
	MAB: IN std_logic_VECTOR(15 downto 0);
	MAC: IN std_logic_VECTOR(15 downto 0);
	MAD: IN std_logic_VECTOR(15 downto 0);
	MAE: IN std_logic_VECTOR(15 downto 0);
	MAF: IN std_logic_VECTOR(15 downto 0);
	MAG: IN std_logic_VECTOR(15 downto 0);
	MAH: IN std_logic_VECTOR(15 downto 0);
	S: IN std_logic_VECTOR(3 downto 0);
	O: OUT std_logic_VECTOR(15 downto 0));
end component;

-- Configuration specification 
	for all : wrapped_ctrl_mux16x16 use entity XilinxCoreLib.C_MUX_BUS_V6_0(behavioral)
		generic map(
			c_has_aset => 0,
			c_has_en => 0,
			c_sync_priority => 1,
			c_has_sclr => 0,
			c_width => 16,
			c_height => 0,
			c_enable_rlocs => 0,
			c_sel_width => 4,
			c_latency => 0,
			c_ainit_val => "0000000000000000",
			c_has_ce => 0,
			c_mux_type => 0,
			c_has_aclr => 0,
			c_sync_enable => 0,
			c_has_ainit => 0,
			c_sinit_val => "0000000000000000",
			c_has_sset => 0,
			c_has_sinit => 0,
			c_has_q => 0,
			c_has_o => 1,
			c_inputs => 16);
BEGIN

U0 : wrapped_ctrl_mux16x16
		port map (
			MA => MA,
			MB => MB,
			MC => MC,
			MD => MD,
			ME => ME,
			MF => MF,
			MG => MG,
			MH => MH,
			MAA => MAA,
			MAB => MAB,
			MAC => MAC,
			MAD => MAD,
			MAE => MAE,
			MAF => MAF,
			MAG => MAG,
			MAH => MAH,
			S => S,
			O => O);
END ctrl_mux16x16_a;

-- synopsys translate_on

