--------------------------------------------------------------------------------
-- Copyright (c) 1995-2007 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: J.33
--  \   \         Application: netgen
--  /   /         Filename: USB_TMC_IP_synthesis.vhd
-- /___/   /\     Timestamp: Mon Jun 15 19:18:24 2009
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -ar Structure -tm USB_TMC_IP -w -dir netgen/synthesis -ofmt vhdl -sim USB_TMC_IP.ngc USB_TMC_IP_synthesis.vhd 
-- Device	: xc3s1500-4-fg676
-- Input file	: USB_TMC_IP.ngc
-- Output file	: /home/habea2/Geccko3com/gecko3com_v04/netgen/synthesis/USB_TMC_IP_synthesis.vhd
-- # of Entities	: 1
-- Design Name	: USB_TMC_IP
-- Xilinx	: /opt/xilinx/ise_91i
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Development System Reference Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity USB_TMC_IP is
  port (
    i_nReset : in STD_LOGIC := 'X'; 
    o_LEDrx : out STD_LOGIC; 
    o_LEDtx : out STD_LOGIC; 
    o_WRX : out STD_LOGIC; 
    i_RDYU : in STD_LOGIC := 'X'; 
    o_RDYX : out STD_LOGIC; 
    i_WRU : in STD_LOGIC := 'X'; 
    i_SYSCLK : in STD_LOGIC := 'X'; 
    i_IFCLK : in STD_LOGIC := 'X'; 
    o_LEDrun : out STD_LOGIC; 
    b_dbus : inout STD_LOGIC_VECTOR ( 15 downto 0 ) 
  );
end USB_TMC_IP;

architecture Structure of USB_TMC_IP is
  component fifo_U2X_2C_1024B
    port (
      almost_empty : out STD_LOGIC; 
      rd_en : in STD_LOGIC := 'X'; 
      wr_en : in STD_LOGIC := 'X'; 
      full : out STD_LOGIC; 
      empty : out STD_LOGIC; 
      wr_clk : in STD_LOGIC := 'X'; 
      rst : in STD_LOGIC := 'X'; 
      almost_full : out STD_LOGIC; 
      rd_clk : in STD_LOGIC := 'X'; 
      dout : out STD_LOGIC_VECTOR ( 31 downto 0 ); 
      din : in STD_LOGIC_VECTOR ( 15 downto 0 ) 
    );
  end component;
  component fifo_X2U_2C_1024B
    port (
      almost_empty : out STD_LOGIC; 
      rd_en : in STD_LOGIC := 'X'; 
      wr_en : in STD_LOGIC := 'X'; 
      full : out STD_LOGIC; 
      empty : out STD_LOGIC; 
      wr_clk : in STD_LOGIC := 'X'; 
      rst : in STD_LOGIC := 'X'; 
      almost_full : out STD_LOGIC; 
      rd_clk : in STD_LOGIC := 'X'; 
      dout : out STD_LOGIC_VECTOR ( 15 downto 0 ); 
      din : in STD_LOGIC_VECTOR ( 31 downto 0 ) 
    );
  end component;
  signal i_nReset_IBUF_0 : STD_LOGIC; 
  signal o_LEDrx_OBUF_1 : STD_LOGIC; 
  signal o_LEDtx_OBUF_2 : STD_LOGIC; 
  signal o_WRX_OBUF_3 : STD_LOGIC; 
  signal i_RDYU_IBUF_4 : STD_LOGIC; 
  signal o_RDYX_OBUF_5 : STD_LOGIC; 
  signal i_WRU_IBUF_6 : STD_LOGIC; 
  signal i_SYSCLK_BUFGP_7 : STD_LOGIC; 
  signal i_IFCLK_BUFGP_8 : STD_LOGIC; 
  signal o_LEDrun_OBUF_9 : STD_LOGIC; 
  signal s_U2X_AM_EMPTY : STD_LOGIC; 
  signal s_X2U_AM_FULL : STD_LOGIC; 
  signal s_FIFOrst : STD_LOGIC; 
  signal s_U2X_RD_EN : STD_LOGIC; 
  signal s_X2U_RD_EN : STD_LOGIC; 
  signal s_U2X_AM_FULL : STD_LOGIC; 
  signal s_U2X_EMPTY : STD_LOGIC; 
  signal s_X2U_EMPTY : STD_LOGIC; 
  signal s_X2U_WR_EN : STD_LOGIC; 
  signal N3 : STD_LOGIC; 
  signal FSM_GPIF_Mcount_v_setup_eqn_3 : STD_LOGIC; 
  signal FSM_GPIF_Mcount_v_setup_eqn_2_10 : STD_LOGIC; 
  signal FSM_GPIF_Mcount_v_setup_eqn_1_11 : STD_LOGIC; 
  signal FSM_GPIF_Mcount_v_setup_eqn_0_12 : STD_LOGIC; 
  signal FSM_GPIF_i_nReset_inv : STD_LOGIC; 
  signal FSM_GPIF_s_bus_trans_dir_inv : STD_LOGIC; 
  signal FSM_GPIF_v_setup_not0001_13 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_not0001 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd4_In : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd3_In : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd2_In : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd1_In_14 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd4_15 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd3_16 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd2_17 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd1_18 : STD_LOGIC; 
  signal N4 : STD_LOGIC; 
  signal N23 : STD_LOGIC; 
  signal Loopback_pr_stateLoop_FFd2_19 : STD_LOGIC; 
  signal Loopback_pr_stateLoop_FFd3_20 : STD_LOGIC; 
  signal Loopback_pr_stateLoop_FFd2_In : STD_LOGIC; 
  signal N30 : STD_LOGIC; 
  signal N31 : STD_LOGIC; 
  signal FSM_GPIF_o_RDYX_map2 : STD_LOGIC; 
  signal FSM_GPIF_o_RDYX_map9 : STD_LOGIC; 
  signal FSM_GPIF_o_RDYX_map19 : STD_LOGIC; 
  signal N89 : STD_LOGIC; 
  signal N90 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd2_In_map2 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd2_In_map8 : STD_LOGIC; 
  signal N120 : STD_LOGIC; 
  signal N124 : STD_LOGIC; 
  signal FSM_GPIF_Mcount_v_setup_eqn_3_map0 : STD_LOGIC; 
  signal FSM_GPIF_Mcount_v_setup_eqn_3_map11 : STD_LOGIC; 
  signal FSM_GPIF_Mcount_v_setup_eqn_3_map16 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd3_In_map18 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd3_In_map22 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd4_In_map5 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd4_In_map18 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd4_In_map29 : STD_LOGIC; 
  signal FSM_GPIF_pr_state_FFd4_In_map30 : STD_LOGIC; 
  signal N317 : STD_LOGIC; 
  signal N318 : STD_LOGIC; 
  signal N319 : STD_LOGIC; 
  signal N320 : STD_LOGIC; 
  signal N321 : STD_LOGIC; 
  signal N322 : STD_LOGIC; 
  signal N323 : STD_LOGIC; 
  signal N324 : STD_LOGIC; 
  signal N325 : STD_LOGIC; 
  signal N326 : STD_LOGIC; 
  signal N327 : STD_LOGIC; 
  signal N328 : STD_LOGIC; 
  signal N329 : STD_LOGIC; 
  signal N330 : STD_LOGIC; 
  signal N331 : STD_LOGIC; 
  signal N332 : STD_LOGIC; 
  signal N333 : STD_LOGIC; 
  signal N350 : STD_LOGIC; 
  signal N352 : STD_LOGIC; 
  signal N354 : STD_LOGIC; 
  signal N355 : STD_LOGIC; 
  signal N356 : STD_LOGIC; 
  signal N357 : STD_LOGIC; 
  signal N358 : STD_LOGIC; 
  signal N360 : STD_LOGIC; 
  signal N361 : STD_LOGIC; 
  signal N362 : STD_LOGIC; 
  signal N363 : STD_LOGIC; 
  signal N364 : STD_LOGIC; 
  signal N365 : STD_LOGIC; 
  signal NLW_F_IN_full_UNCONNECTED : STD_LOGIC; 
  signal NLW_F_OUT_almost_empty_UNCONNECTED : STD_LOGIC; 
  signal NLW_F_OUT_full_UNCONNECTED : STD_LOGIC; 
  signal FSM_GPIF_o_dbus : STD_LOGIC_VECTOR ( 15 downto 0 ); 
  signal s_opb_in : STD_LOGIC_VECTOR ( 31 downto 0 ); 
  signal Loopback_o_X2U_DATA : STD_LOGIC_VECTOR ( 31 downto 0 ); 
  signal s_dbus_out : STD_LOGIC_VECTOR ( 15 downto 0 ); 
  signal FSM_GPIF_v_setup : STD_LOGIC_VECTOR ( 3 downto 0 ); 
begin
  XST_VCC : VCC
    port map (
      P => N3
    );
  FSM_GPIF_v_setup_3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_v_setup_not0001_13,
      CLR => FSM_GPIF_i_nReset_inv,
      D => FSM_GPIF_Mcount_v_setup_eqn_3,
      Q => FSM_GPIF_v_setup(3)
    );
  FSM_GPIF_v_setup_2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_v_setup_not0001_13,
      CLR => FSM_GPIF_i_nReset_inv,
      D => FSM_GPIF_Mcount_v_setup_eqn_2_10,
      Q => FSM_GPIF_v_setup(2)
    );
  FSM_GPIF_v_setup_1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_v_setup_not0001_13,
      CLR => FSM_GPIF_i_nReset_inv,
      D => FSM_GPIF_Mcount_v_setup_eqn_1_11,
      Q => FSM_GPIF_v_setup(1)
    );
  FSM_GPIF_v_setup_0 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_v_setup_not0001_13,
      CLR => FSM_GPIF_i_nReset_inv,
      D => FSM_GPIF_Mcount_v_setup_eqn_0_12,
      Q => FSM_GPIF_v_setup(0)
    );
  FSM_GPIF_o_dbus_15 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N317,
      Q => FSM_GPIF_o_dbus(15)
    );
  FSM_GPIF_o_dbus_14 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N318,
      Q => FSM_GPIF_o_dbus(14)
    );
  FSM_GPIF_o_dbus_13 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N319,
      Q => FSM_GPIF_o_dbus(13)
    );
  FSM_GPIF_o_dbus_12 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N320,
      Q => FSM_GPIF_o_dbus(12)
    );
  FSM_GPIF_o_dbus_11 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N321,
      Q => FSM_GPIF_o_dbus(11)
    );
  FSM_GPIF_o_dbus_10 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N322,
      Q => FSM_GPIF_o_dbus(10)
    );
  FSM_GPIF_o_dbus_9 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N323,
      Q => FSM_GPIF_o_dbus(9)
    );
  FSM_GPIF_o_dbus_8 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N324,
      Q => FSM_GPIF_o_dbus(8)
    );
  FSM_GPIF_o_dbus_7 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N325,
      Q => FSM_GPIF_o_dbus(7)
    );
  FSM_GPIF_o_dbus_6 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N326,
      Q => FSM_GPIF_o_dbus(6)
    );
  FSM_GPIF_o_dbus_5 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N327,
      Q => FSM_GPIF_o_dbus(5)
    );
  FSM_GPIF_o_dbus_4 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N328,
      Q => FSM_GPIF_o_dbus(4)
    );
  FSM_GPIF_o_dbus_3 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N329,
      Q => FSM_GPIF_o_dbus(3)
    );
  FSM_GPIF_o_dbus_2 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N330,
      Q => FSM_GPIF_o_dbus(2)
    );
  FSM_GPIF_o_dbus_1 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N331,
      Q => FSM_GPIF_o_dbus(1)
    );
  FSM_GPIF_o_dbus_0 : FDE
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_s_bus_trans_dir_inv,
      D => N332,
      Q => FSM_GPIF_o_dbus(0)
    );
  FSM_GPIF_pr_state_FFd4 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_pr_state_not0001,
      CLR => FSM_GPIF_i_nReset_inv,
      D => FSM_GPIF_pr_state_FFd4_In,
      Q => FSM_GPIF_pr_state_FFd4_15
    );
  FSM_GPIF_pr_state_FFd3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_pr_state_not0001,
      CLR => FSM_GPIF_i_nReset_inv,
      D => FSM_GPIF_pr_state_FFd3_In,
      Q => FSM_GPIF_pr_state_FFd3_16
    );
  FSM_GPIF_pr_state_FFd2 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_pr_state_not0001,
      CLR => FSM_GPIF_i_nReset_inv,
      D => FSM_GPIF_pr_state_FFd2_In,
      Q => FSM_GPIF_pr_state_FFd2_17
    );
  FSM_GPIF_pr_state_FFd1 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => i_IFCLK_BUFGP_8,
      CE => FSM_GPIF_pr_state_not0001,
      CLR => FSM_GPIF_i_nReset_inv,
      D => FSM_GPIF_pr_state_FFd1_In_14,
      Q => FSM_GPIF_pr_state_FFd1_18
    );
  Loopback_pr_stateLoop_FFd2 : FDC
    generic map(
      INIT => '0'
    )
    port map (
      C => i_SYSCLK_BUFGP_7,
      CLR => FSM_GPIF_i_nReset_inv,
      D => Loopback_pr_stateLoop_FFd2_In,
      Q => Loopback_pr_stateLoop_FFd2_19
    );
  Loopback_o_X2U_DATA_31 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(31),
      Q => Loopback_o_X2U_DATA(31)
    );
  Loopback_o_X2U_DATA_30 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(30),
      Q => Loopback_o_X2U_DATA(30)
    );
  Loopback_o_X2U_DATA_29 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(29),
      Q => Loopback_o_X2U_DATA(29)
    );
  Loopback_o_X2U_DATA_28 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(28),
      Q => Loopback_o_X2U_DATA(28)
    );
  Loopback_o_X2U_DATA_27 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(27),
      Q => Loopback_o_X2U_DATA(27)
    );
  Loopback_o_X2U_DATA_26 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(26),
      Q => Loopback_o_X2U_DATA(26)
    );
  Loopback_o_X2U_DATA_25 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(25),
      Q => Loopback_o_X2U_DATA(25)
    );
  Loopback_o_X2U_DATA_24 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(24),
      Q => Loopback_o_X2U_DATA(24)
    );
  Loopback_o_X2U_DATA_23 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(23),
      Q => Loopback_o_X2U_DATA(23)
    );
  Loopback_o_X2U_DATA_22 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(22),
      Q => Loopback_o_X2U_DATA(22)
    );
  Loopback_o_X2U_DATA_21 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(21),
      Q => Loopback_o_X2U_DATA(21)
    );
  Loopback_o_X2U_DATA_20 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(20),
      Q => Loopback_o_X2U_DATA(20)
    );
  Loopback_o_X2U_DATA_19 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(19),
      Q => Loopback_o_X2U_DATA(19)
    );
  Loopback_o_X2U_DATA_18 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(18),
      Q => Loopback_o_X2U_DATA(18)
    );
  Loopback_o_X2U_DATA_17 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(17),
      Q => Loopback_o_X2U_DATA(17)
    );
  Loopback_o_X2U_DATA_16 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(16),
      Q => Loopback_o_X2U_DATA(16)
    );
  Loopback_o_X2U_DATA_15 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(15),
      Q => Loopback_o_X2U_DATA(15)
    );
  Loopback_o_X2U_DATA_14 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(14),
      Q => Loopback_o_X2U_DATA(14)
    );
  Loopback_o_X2U_DATA_13 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(13),
      Q => Loopback_o_X2U_DATA(13)
    );
  Loopback_o_X2U_DATA_12 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(12),
      Q => Loopback_o_X2U_DATA(12)
    );
  Loopback_o_X2U_DATA_11 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(11),
      Q => Loopback_o_X2U_DATA(11)
    );
  Loopback_o_X2U_DATA_10 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(10),
      Q => Loopback_o_X2U_DATA(10)
    );
  Loopback_o_X2U_DATA_9 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(9),
      Q => Loopback_o_X2U_DATA(9)
    );
  Loopback_o_X2U_DATA_8 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(8),
      Q => Loopback_o_X2U_DATA(8)
    );
  Loopback_o_X2U_DATA_7 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(7),
      Q => Loopback_o_X2U_DATA(7)
    );
  Loopback_o_X2U_DATA_6 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(6),
      Q => Loopback_o_X2U_DATA(6)
    );
  Loopback_o_X2U_DATA_5 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(5),
      Q => Loopback_o_X2U_DATA(5)
    );
  Loopback_o_X2U_DATA_4 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(4),
      Q => Loopback_o_X2U_DATA(4)
    );
  Loopback_o_X2U_DATA_3 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(3),
      Q => Loopback_o_X2U_DATA(3)
    );
  Loopback_o_X2U_DATA_2 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(2),
      Q => Loopback_o_X2U_DATA(2)
    );
  Loopback_o_X2U_DATA_1 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(1),
      Q => Loopback_o_X2U_DATA(1)
    );
  Loopback_o_X2U_DATA_0 : FD
    port map (
      C => i_SYSCLK_BUFGP_7,
      D => s_opb_in(0),
      Q => Loopback_o_X2U_DATA(0)
    );
  FSM_GPIF_pr_state_Out61 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd4_15,
      I1 => FSM_GPIF_pr_state_FFd1_18,
      O => o_LEDtx_OBUF_2
    );
  FSM_GPIF_pr_state_Out41 : LUT3
    generic map(
      INIT => X"40"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd3_16,
      I1 => FSM_GPIF_pr_state_FFd2_17,
      I2 => FSM_GPIF_pr_state_FFd4_15,
      O => o_LEDrx_OBUF_1
    );
  FSM_GPIF_pr_state_Out91 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd4_15,
      I1 => FSM_GPIF_pr_state_FFd1_18,
      I2 => FSM_GPIF_pr_state_FFd2_17,
      I3 => FSM_GPIF_pr_state_FFd3_16,
      O => o_LEDrun_OBUF_9
    );
  FSM_GPIF_o_WRX_SW0 : LUT4
    generic map(
      INIT => X"FF8F"
    )
    port map (
      I0 => i_RDYU_IBUF_4,
      I1 => i_WRU_IBUF_6,
      I2 => FSM_GPIF_pr_state_FFd3_16,
      I3 => FSM_GPIF_pr_state_FFd2_17,
      O => N30
    );
  FSM_GPIF_o_WRX_SW1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => i_WRU_IBUF_6,
      I1 => i_RDYU_IBUF_4,
      O => N31
    );
  FSM_GPIF_o_WRX : LUT4
    generic map(
      INIT => X"89CD"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd4_15,
      I1 => FSM_GPIF_pr_state_FFd1_18,
      I2 => N30,
      I3 => N31,
      O => o_WRX_OBUF_3
    );
  FSM_GPIF_o_RDYX3 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => i_RDYU_IBUF_4,
      I1 => i_WRU_IBUF_6,
      O => FSM_GPIF_o_RDYX_map2
    );
  FSM_GPIF_o_RDYX19 : LUT4
    generic map(
      INIT => X"4445"
    )
    port map (
      I0 => s_U2X_AM_FULL,
      I1 => FSM_GPIF_pr_state_FFd2_17,
      I2 => FSM_GPIF_pr_state_FFd1_18,
      I3 => FSM_GPIF_pr_state_FFd3_16,
      O => FSM_GPIF_o_RDYX_map9
    );
  FSM_GPIF_o_RDYX47 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd3_16,
      I1 => FSM_GPIF_pr_state_FFd2_17,
      O => FSM_GPIF_o_RDYX_map19
    );
  FSM_GPIF_pr_state_not00011 : LUT3
    generic map(
      INIT => X"A8"
    )
    port map (
      I0 => FSM_GPIF_v_setup(3),
      I1 => FSM_GPIF_v_setup(1),
      I2 => FSM_GPIF_v_setup(2),
      O => FSM_GPIF_pr_state_not0001
    );
  FSM_GPIF_s_bus_trans_dir_inv1 : LUT4
    generic map(
      INIT => X"55D5"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd1_18,
      I1 => i_RDYU_IBUF_4,
      I2 => i_WRU_IBUF_6,
      I3 => FSM_GPIF_pr_state_FFd4_15,
      O => FSM_GPIF_s_bus_trans_dir_inv
    );
  FSM_GPIF_pr_state_FFd1_In_SW0 : LUT3
    generic map(
      INIT => X"D5"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd1_18,
      I1 => i_WRU_IBUF_6,
      I2 => i_RDYU_IBUF_4,
      O => N89
    );
  FSM_GPIF_pr_state_FFd1_In_SW1 : LUT4
    generic map(
      INIT => X"F332"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd2_17,
      I1 => FSM_GPIF_pr_state_FFd1_18,
      I2 => i_WRU_IBUF_6,
      I3 => i_RDYU_IBUF_4,
      O => N90
    );
  FSM_GPIF_pr_state_FFd1_In : LUT4
    generic map(
      INIT => X"0415"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd4_15,
      I1 => FSM_GPIF_pr_state_FFd3_16,
      I2 => N90,
      I3 => N89,
      O => FSM_GPIF_pr_state_FFd1_In_14
    );
  FSM_GPIF_pr_state_FFd2_In17 : LUT4
    generic map(
      INIT => X"0002"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd4_15,
      I1 => s_U2X_AM_FULL,
      I2 => FSM_GPIF_pr_state_FFd3_16,
      I3 => FSM_GPIF_pr_state_FFd1_18,
      O => FSM_GPIF_pr_state_FFd2_In_map8
    );
  FSM_GPIF_Mcount_v_setup_eqn_2_SW0 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => FSM_GPIF_v_setup(0),
      I1 => FSM_GPIF_v_setup(1),
      O => N120
    );
  FSM_GPIF_Mcount_v_setup_eqn_2 : LUT4
    generic map(
      INIT => X"C382"
    )
    port map (
      I0 => N4,
      I1 => FSM_GPIF_v_setup(2),
      I2 => N120,
      I3 => N23,
      O => FSM_GPIF_Mcount_v_setup_eqn_2_10
    );
  Loopback_pr_stateLoop_Out11 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => Loopback_pr_stateLoop_FFd3_20,
      I1 => Loopback_pr_stateLoop_FFd2_19,
      O => s_X2U_WR_EN
    );
  Loopback_s_U2X_RD_EN1 : LUT3
    generic map(
      INIT => X"2A"
    )
    port map (
      I0 => Loopback_pr_stateLoop_FFd3_20,
      I1 => s_X2U_AM_FULL,
      I2 => Loopback_pr_stateLoop_FFd2_19,
      O => s_U2X_RD_EN
    );
  FSM_GPIF_v_setup_not0001_SW0 : LUT3
    generic map(
      INIT => X"1F"
    )
    port map (
      I0 => FSM_GPIF_v_setup(1),
      I1 => FSM_GPIF_v_setup(2),
      I2 => FSM_GPIF_v_setup(3),
      O => N124
    );
  FSM_GPIF_v_setup_not0001 : LUT4
    generic map(
      INIT => X"FF40"
    )
    port map (
      I0 => N364,
      I1 => i_WRU_IBUF_6,
      I2 => i_RDYU_IBUF_4,
      I3 => N124,
      O => FSM_GPIF_v_setup_not0001_13
    );
  FSM_GPIF_Mcount_v_setup_eqn_1211 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => FSM_GPIF_v_setup(3),
      I1 => i_RDYU_IBUF_4,
      I2 => i_WRU_IBUF_6,
      O => N23
    );
  FSM_GPIF_Mcount_v_setup_eqn_0 : LUT4
    generic map(
      INIT => X"4445"
    )
    port map (
      I0 => FSM_GPIF_v_setup(0),
      I1 => N365,
      I2 => FSM_GPIF_v_setup(2),
      I3 => FSM_GPIF_v_setup(1),
      O => FSM_GPIF_Mcount_v_setup_eqn_0_12
    );
  FSM_GPIF_Mcount_v_setup_eqn_1 : LUT4
    generic map(
      INIT => X"6062"
    )
    port map (
      I0 => FSM_GPIF_v_setup(0),
      I1 => FSM_GPIF_v_setup(1),
      I2 => FSM_GPIF_Mcount_v_setup_eqn_3_map0,
      I3 => FSM_GPIF_v_setup(2),
      O => FSM_GPIF_Mcount_v_setup_eqn_1_11
    );
  FSM_GPIF_Mcount_v_setup_eqn_352 : LUT3
    generic map(
      INIT => X"02"
    )
    port map (
      I0 => FSM_GPIF_v_setup(3),
      I1 => FSM_GPIF_v_setup(2),
      I2 => FSM_GPIF_v_setup(1),
      O => FSM_GPIF_Mcount_v_setup_eqn_3_map16
    );
  FSM_GPIF_pr_state_FFd3_In59 : LUT4
    generic map(
      INIT => X"A2B2"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd2_17,
      I1 => FSM_GPIF_pr_state_FFd3_16,
      I2 => s_U2X_AM_FULL,
      I3 => FSM_GPIF_pr_state_FFd1_18,
      O => FSM_GPIF_pr_state_FFd3_In_map18
    );
  FSM_GPIF_pr_state_FFd3_In67 : LUT4
    generic map(
      INIT => X"0A08"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd3_16,
      I1 => i_RDYU_IBUF_4,
      I2 => FSM_GPIF_pr_state_FFd2_17,
      I3 => FSM_GPIF_pr_state_FFd4_15,
      O => FSM_GPIF_pr_state_FFd3_In_map22
    );
  FSM_GPIF_pr_state_FFd4_In96 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => i_RDYU_IBUF_4,
      I1 => i_WRU_IBUF_6,
      O => FSM_GPIF_pr_state_FFd4_In_map29
    );
  FSM_GPIF_pr_state_FFd4_In103 : LUT4
    generic map(
      INIT => X"E060"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd2_17,
      I1 => FSM_GPIF_pr_state_FFd3_16,
      I2 => FSM_GPIF_pr_state_FFd4_In_map29,
      I3 => s_U2X_AM_FULL,
      O => FSM_GPIF_pr_state_FFd4_In_map30
    );
  i_nReset_IBUF : IBUF
    port map (
      I => i_nReset,
      O => i_nReset_IBUF_0
    );
  i_RDYU_IBUF : IBUF
    port map (
      I => i_RDYU,
      O => i_RDYU_IBUF_4
    );
  i_WRU_IBUF : IBUF
    port map (
      I => i_WRU,
      O => i_WRU_IBUF_6
    );
  b_dbus_15_IOBUF : IOBUF
    port map (
      I => s_dbus_out(15),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N317,
      IO => b_dbus(15)
    );
  b_dbus_14_IOBUF : IOBUF
    port map (
      I => s_dbus_out(14),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N318,
      IO => b_dbus(14)
    );
  b_dbus_13_IOBUF : IOBUF
    port map (
      I => s_dbus_out(13),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N319,
      IO => b_dbus(13)
    );
  b_dbus_12_IOBUF : IOBUF
    port map (
      I => s_dbus_out(12),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N320,
      IO => b_dbus(12)
    );
  b_dbus_11_IOBUF : IOBUF
    port map (
      I => s_dbus_out(11),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N321,
      IO => b_dbus(11)
    );
  b_dbus_10_IOBUF : IOBUF
    port map (
      I => s_dbus_out(10),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N322,
      IO => b_dbus(10)
    );
  b_dbus_9_IOBUF : IOBUF
    port map (
      I => s_dbus_out(9),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N323,
      IO => b_dbus(9)
    );
  b_dbus_8_IOBUF : IOBUF
    port map (
      I => s_dbus_out(8),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N324,
      IO => b_dbus(8)
    );
  b_dbus_7_IOBUF : IOBUF
    port map (
      I => s_dbus_out(7),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N325,
      IO => b_dbus(7)
    );
  b_dbus_6_IOBUF : IOBUF
    port map (
      I => s_dbus_out(6),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N326,
      IO => b_dbus(6)
    );
  b_dbus_5_IOBUF : IOBUF
    port map (
      I => s_dbus_out(5),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N327,
      IO => b_dbus(5)
    );
  b_dbus_4_IOBUF : IOBUF
    port map (
      I => s_dbus_out(4),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N328,
      IO => b_dbus(4)
    );
  b_dbus_3_IOBUF : IOBUF
    port map (
      I => s_dbus_out(3),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N329,
      IO => b_dbus(3)
    );
  b_dbus_2_IOBUF : IOBUF
    port map (
      I => s_dbus_out(2),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N330,
      IO => b_dbus(2)
    );
  b_dbus_1_IOBUF : IOBUF
    port map (
      I => s_dbus_out(1),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N331,
      IO => b_dbus(1)
    );
  b_dbus_0_IOBUF : IOBUF
    port map (
      I => s_dbus_out(0),
      T => FSM_GPIF_s_bus_trans_dir_inv,
      O => N332,
      IO => b_dbus(0)
    );
  o_LEDrx_OBUF : OBUF
    port map (
      I => o_LEDrx_OBUF_1,
      O => o_LEDrx
    );
  o_LEDtx_OBUF : OBUF
    port map (
      I => o_LEDtx_OBUF_2,
      O => o_LEDtx
    );
  o_WRX_OBUF : OBUF
    port map (
      I => o_WRX_OBUF_3,
      O => o_WRX
    );
  o_RDYX_OBUF : OBUF
    port map (
      I => o_RDYX_OBUF_5,
      O => o_RDYX
    );
  o_LEDrun_OBUF : OBUF
    port map (
      I => o_LEDrun_OBUF_9,
      O => o_LEDrun
    );
  Loopback_pr_stateLoop_FFd3 : FDCE
    generic map(
      INIT => '0'
    )
    port map (
      C => i_SYSCLK_BUFGP_7,
      CE => Loopback_pr_stateLoop_FFd2_19,
      CLR => FSM_GPIF_i_nReset_inv,
      D => N333,
      Q => Loopback_pr_stateLoop_FFd3_20
    );
  FSM_GPIF_pr_state_FFd3_In20_SW0 : LUT4
    generic map(
      INIT => X"5F4E"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd2_17,
      I1 => FSM_GPIF_pr_state_FFd3_16,
      I2 => FSM_GPIF_pr_state_FFd4_15,
      I3 => FSM_GPIF_pr_state_FFd1_18,
      O => N350
    );
  FSM_GPIF_pr_state_FFd4_In108 : LUT4
    generic map(
      INIT => X"FFAE"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd4_In_map5,
      I1 => FSM_GPIF_pr_state_FFd4_In_map18,
      I2 => FSM_GPIF_pr_state_FFd2_17,
      I3 => FSM_GPIF_pr_state_FFd4_In_map30,
      O => FSM_GPIF_pr_state_FFd4_In
    );
  FSM_GPIF_Mcount_v_setup_eqn_354 : LUT4
    generic map(
      INIT => X"FAF8"
    )
    port map (
      I0 => FSM_GPIF_Mcount_v_setup_eqn_3_map11,
      I1 => N4,
      I2 => FSM_GPIF_Mcount_v_setup_eqn_3_map16,
      I3 => N23,
      O => FSM_GPIF_Mcount_v_setup_eqn_3
    );
  FSM_GPIF_pr_state_FFd3_In98 : LUT4
    generic map(
      INIT => X"FF04"
    )
    port map (
      I0 => N350,
      I1 => s_U2X_AM_FULL,
      I2 => i_RDYU_IBUF_4,
      I3 => N352,
      O => FSM_GPIF_pr_state_FFd3_In
    );
  Loopback_pr_stateLoop_FFd3_In1 : LUT4
    generic map(
      INIT => X"0415"
    )
    port map (
      I0 => s_X2U_AM_FULL,
      I1 => Loopback_pr_stateLoop_FFd3_20,
      I2 => s_U2X_EMPTY,
      I3 => s_U2X_AM_EMPTY,
      O => N333
    );
  FSM_GPIF_pr_state_FFd2_In32 : LUT4
    generic map(
      INIT => X"5F4C"
    )
    port map (
      I0 => i_RDYU_IBUF_4,
      I1 => FSM_GPIF_pr_state_FFd2_In_map2,
      I2 => i_WRU_IBUF_6,
      I3 => FSM_GPIF_pr_state_FFd2_In_map8,
      O => FSM_GPIF_pr_state_FFd2_In
    );
  FSM_GPIF_pr_state_Out11 : LUT4
    generic map(
      INIT => X"0001"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd4_15,
      I1 => FSM_GPIF_pr_state_FFd1_18,
      I2 => FSM_GPIF_pr_state_FFd2_17,
      I3 => FSM_GPIF_pr_state_FFd3_16,
      O => s_FIFOrst
    );
  FSM_GPIF_o_RDYX59 : MUXF5
    port map (
      I0 => N354,
      I1 => N355,
      S => FSM_GPIF_pr_state_FFd4_15,
      O => o_RDYX_OBUF_5
    );
  FSM_GPIF_o_RDYX59_F : LUT3
    generic map(
      INIT => X"40"
    )
    port map (
      I0 => i_RDYU_IBUF_4,
      I1 => i_WRU_IBUF_6,
      I2 => FSM_GPIF_o_RDYX_map19,
      O => N354
    );
  FSM_GPIF_o_RDYX59_G : LUT4
    generic map(
      INIT => X"54DC"
    )
    port map (
      I0 => i_WRU_IBUF_6,
      I1 => FSM_GPIF_o_RDYX_map9,
      I2 => FSM_GPIF_o_RDYX_map19,
      I3 => i_RDYU_IBUF_4,
      O => N355
    );
  i_SYSCLK_BUFGP : BUFGP
    port map (
      I => i_SYSCLK,
      O => i_SYSCLK_BUFGP_7
    );
  i_IFCLK_BUFGP : BUFGP
    port map (
      I => i_IFCLK,
      O => i_IFCLK_BUFGP_8
    );
  Loopback_pr_stateLoop_Rst_inv1_INV_0 : INV
    port map (
      I => i_nReset_IBUF_0,
      O => FSM_GPIF_i_nReset_inv
    );
  XST_GND : GND
    port map (
      G => N356
    );
  Loopback_pr_stateLoop_FFd2_In1 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => Loopback_pr_stateLoop_FFd3_20,
      I1 => Loopback_pr_stateLoop_FFd2_19,
      O => N357
    );
  Loopback_pr_stateLoop_FFd2_In2 : LUT4
    generic map(
      INIT => X"7F5D"
    )
    port map (
      I0 => Loopback_pr_stateLoop_FFd2_19,
      I1 => Loopback_pr_stateLoop_FFd3_20,
      I2 => s_U2X_EMPTY,
      I3 => s_U2X_AM_EMPTY,
      O => N358
    );
  Loopback_pr_stateLoop_FFd2_In_f5 : MUXF5
    port map (
      I0 => N358,
      I1 => N357,
      S => s_X2U_AM_FULL,
      O => Loopback_pr_stateLoop_FFd2_In
    );
  FSM_GPIF_s_X2U_RD_EN1 : LUT4
    generic map(
      INIT => X"A2AA"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd1_18,
      I1 => i_WRU_IBUF_6,
      I2 => FSM_GPIF_pr_state_FFd4_15,
      I3 => i_RDYU_IBUF_4,
      O => N360
    );
  FSM_GPIF_s_X2U_RD_EN2 : LUT4
    generic map(
      INIT => X"88C8"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd4_15,
      I1 => FSM_GPIF_pr_state_FFd1_18,
      I2 => i_RDYU_IBUF_4,
      I3 => i_WRU_IBUF_6,
      O => N361
    );
  FSM_GPIF_s_X2U_RD_EN_f5 : MUXF5
    port map (
      I0 => N361,
      I1 => N360,
      S => s_X2U_EMPTY,
      O => s_X2U_RD_EN
    );
  FSM_GPIF_pr_state_FFd4_In411 : LUT3
    generic map(
      INIT => X"40"
    )
    port map (
      I0 => i_WRU_IBUF_6,
      I1 => FSM_GPIF_pr_state_FFd4_15,
      I2 => s_X2U_EMPTY,
      O => N362
    );
  FSM_GPIF_pr_state_FFd4_In412 : LUT3
    generic map(
      INIT => X"40"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd1_18,
      I1 => FSM_GPIF_o_RDYX_map2,
      I2 => s_U2X_AM_FULL,
      O => N363
    );
  FSM_GPIF_pr_state_FFd4_In41_f5 : MUXF5
    port map (
      I0 => N363,
      I1 => N362,
      S => FSM_GPIF_pr_state_FFd3_16,
      O => FSM_GPIF_pr_state_FFd4_In_map18
    );
  FSM_GPIF_pr_state_FFd2_In5 : LUT3_L
    generic map(
      INIT => X"A2"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd2_17,
      I1 => FSM_GPIF_pr_state_FFd3_16,
      I2 => FSM_GPIF_pr_state_FFd4_15,
      LO => FSM_GPIF_pr_state_FFd2_In_map2
    );
  FSM_GPIF_pr_state_FFd3_In11 : LUT4_D
    generic map(
      INIT => X"EA41"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd4_15,
      I1 => FSM_GPIF_pr_state_FFd2_17,
      I2 => FSM_GPIF_pr_state_FFd3_16,
      I3 => FSM_GPIF_pr_state_FFd1_18,
      LO => N364,
      O => N4
    );
  FSM_GPIF_Mcount_v_setup_eqn_332 : LUT4_L
    generic map(
      INIT => X"6AAA"
    )
    port map (
      I0 => FSM_GPIF_v_setup(3),
      I1 => FSM_GPIF_v_setup(2),
      I2 => FSM_GPIF_v_setup(0),
      I3 => FSM_GPIF_v_setup(1),
      LO => FSM_GPIF_Mcount_v_setup_eqn_3_map11
    );
  FSM_GPIF_pr_state_FFd4_In13 : LUT4_L
    generic map(
      INIT => X"FF80"
    )
    port map (
      I0 => FSM_GPIF_pr_state_FFd1_18,
      I1 => s_X2U_EMPTY,
      I2 => FSM_GPIF_o_RDYX_map2,
      I3 => N4,
      LO => FSM_GPIF_pr_state_FFd4_In_map5
    );
  FSM_GPIF_pr_state_FFd3_In98_SW0 : LUT4_L
    generic map(
      INIT => X"FF54"
    )
    port map (
      I0 => i_WRU_IBUF_6,
      I1 => FSM_GPIF_pr_state_FFd3_In_map22,
      I2 => FSM_GPIF_pr_state_FFd3_In_map18,
      I3 => N4,
      LO => N352
    );
  FSM_GPIF_Mcount_v_setup_eqn_0_SW0 : LUT4_D
    generic map(
      INIT => X"FF7F"
    )
    port map (
      I0 => FSM_GPIF_v_setup(3),
      I1 => i_RDYU_IBUF_4,
      I2 => i_WRU_IBUF_6,
      I3 => N4,
      LO => N365,
      O => FSM_GPIF_Mcount_v_setup_eqn_3_map0
    );
  F_IN : fifo_U2X_2C_1024B
    port map (
      almost_empty => s_U2X_AM_EMPTY,
      rd_en => s_U2X_RD_EN,
      wr_en => N3,
      full => NLW_F_IN_full_UNCONNECTED,
      empty => s_U2X_EMPTY,
      wr_clk => i_IFCLK_BUFGP_8,
      rst => s_FIFOrst,
      almost_full => s_U2X_AM_FULL,
      rd_clk => i_SYSCLK_BUFGP_7,
      dout(31) => s_opb_in(31),
      dout(30) => s_opb_in(30),
      dout(29) => s_opb_in(29),
      dout(28) => s_opb_in(28),
      dout(27) => s_opb_in(27),
      dout(26) => s_opb_in(26),
      dout(25) => s_opb_in(25),
      dout(24) => s_opb_in(24),
      dout(23) => s_opb_in(23),
      dout(22) => s_opb_in(22),
      dout(21) => s_opb_in(21),
      dout(20) => s_opb_in(20),
      dout(19) => s_opb_in(19),
      dout(18) => s_opb_in(18),
      dout(17) => s_opb_in(17),
      dout(16) => s_opb_in(16),
      dout(15) => s_opb_in(15),
      dout(14) => s_opb_in(14),
      dout(13) => s_opb_in(13),
      dout(12) => s_opb_in(12),
      dout(11) => s_opb_in(11),
      dout(10) => s_opb_in(10),
      dout(9) => s_opb_in(9),
      dout(8) => s_opb_in(8),
      dout(7) => s_opb_in(7),
      dout(6) => s_opb_in(6),
      dout(5) => s_opb_in(5),
      dout(4) => s_opb_in(4),
      dout(3) => s_opb_in(3),
      dout(2) => s_opb_in(2),
      dout(1) => s_opb_in(1),
      dout(0) => s_opb_in(0),
      din(15) => FSM_GPIF_o_dbus(15),
      din(14) => FSM_GPIF_o_dbus(14),
      din(13) => FSM_GPIF_o_dbus(13),
      din(12) => FSM_GPIF_o_dbus(12),
      din(11) => FSM_GPIF_o_dbus(11),
      din(10) => FSM_GPIF_o_dbus(10),
      din(9) => FSM_GPIF_o_dbus(9),
      din(8) => FSM_GPIF_o_dbus(8),
      din(7) => FSM_GPIF_o_dbus(7),
      din(6) => FSM_GPIF_o_dbus(6),
      din(5) => FSM_GPIF_o_dbus(5),
      din(4) => FSM_GPIF_o_dbus(4),
      din(3) => FSM_GPIF_o_dbus(3),
      din(2) => FSM_GPIF_o_dbus(2),
      din(1) => FSM_GPIF_o_dbus(1),
      din(0) => FSM_GPIF_o_dbus(0)
    );
  F_OUT : fifo_X2U_2C_1024B
    port map (
      almost_empty => NLW_F_OUT_almost_empty_UNCONNECTED,
      rd_en => s_X2U_RD_EN,
      wr_en => s_X2U_WR_EN,
      full => NLW_F_OUT_full_UNCONNECTED,
      empty => s_X2U_EMPTY,
      wr_clk => i_SYSCLK_BUFGP_7,
      rst => s_FIFOrst,
      almost_full => s_X2U_AM_FULL,
      rd_clk => i_IFCLK_BUFGP_8,
      dout(15) => s_dbus_out(15),
      dout(14) => s_dbus_out(14),
      dout(13) => s_dbus_out(13),
      dout(12) => s_dbus_out(12),
      dout(11) => s_dbus_out(11),
      dout(10) => s_dbus_out(10),
      dout(9) => s_dbus_out(9),
      dout(8) => s_dbus_out(8),
      dout(7) => s_dbus_out(7),
      dout(6) => s_dbus_out(6),
      dout(5) => s_dbus_out(5),
      dout(4) => s_dbus_out(4),
      dout(3) => s_dbus_out(3),
      dout(2) => s_dbus_out(2),
      dout(1) => s_dbus_out(1),
      dout(0) => s_dbus_out(0),
      din(31) => Loopback_o_X2U_DATA(31),
      din(30) => Loopback_o_X2U_DATA(30),
      din(29) => Loopback_o_X2U_DATA(29),
      din(28) => Loopback_o_X2U_DATA(28),
      din(27) => Loopback_o_X2U_DATA(27),
      din(26) => Loopback_o_X2U_DATA(26),
      din(25) => Loopback_o_X2U_DATA(25),
      din(24) => Loopback_o_X2U_DATA(24),
      din(23) => Loopback_o_X2U_DATA(23),
      din(22) => Loopback_o_X2U_DATA(22),
      din(21) => Loopback_o_X2U_DATA(21),
      din(20) => Loopback_o_X2U_DATA(20),
      din(19) => Loopback_o_X2U_DATA(19),
      din(18) => Loopback_o_X2U_DATA(18),
      din(17) => Loopback_o_X2U_DATA(17),
      din(16) => Loopback_o_X2U_DATA(16),
      din(15) => Loopback_o_X2U_DATA(15),
      din(14) => Loopback_o_X2U_DATA(14),
      din(13) => Loopback_o_X2U_DATA(13),
      din(12) => Loopback_o_X2U_DATA(12),
      din(11) => Loopback_o_X2U_DATA(11),
      din(10) => Loopback_o_X2U_DATA(10),
      din(9) => Loopback_o_X2U_DATA(9),
      din(8) => Loopback_o_X2U_DATA(8),
      din(7) => Loopback_o_X2U_DATA(7),
      din(6) => Loopback_o_X2U_DATA(6),
      din(5) => Loopback_o_X2U_DATA(5),
      din(4) => Loopback_o_X2U_DATA(4),
      din(3) => Loopback_o_X2U_DATA(3),
      din(2) => Loopback_o_X2U_DATA(2),
      din(1) => Loopback_o_X2U_DATA(1),
      din(0) => Loopback_o_X2U_DATA(0)
    );

end Structure;

