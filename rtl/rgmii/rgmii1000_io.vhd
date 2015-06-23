-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rgmii_io.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2012-10-26
-- Last update: 2013-05-15
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 OE@HUST
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-10-26  1.0      liyi    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-------------------------------------------------------------------------------
ENTITY rgmii1000_io IS

  PORT (
    iRst_n : IN  STD_LOGIC;
	
    ---------------------------------------------------------------------------
    -- RGMII Interface
    ---------------------------------------------------------------------------
    TXC    : OUT STD_LOGIC;
    TX_CTL : OUT STD_LOGIC;
    TD     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    RXC    : IN  STD_LOGIC;
    RX_CTL : IN  STD_LOGIC;
    RD     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);

    ---------------------------------------------------------------------------
    -- data to PHY 
    ---------------------------------------------------------------------------
    iTxData : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    iTxEn   : IN STD_LOGIC;
    iTxErr  : IN STD_LOGIC;

    ---------------------------------------------------------------------------
    -- data from PHY
    ---------------------------------------------------------------------------
    oRxData : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    oRxDV   : OUT STD_LOGIC;
    oRxErr  : OUT STD_LOGIC;

    ---------------------------------------------------------------------------
    -- clock for MAC controller
    ---------------------------------------------------------------------------
    oEthClk      : OUT STD_LOGIC
    );

END ENTITY rgmii1000_io;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF rgmii1000_io IS

  SIGNAL ethIOClk : STD_LOGIC;

  SIGNAL outDataH, outDataL, outData : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL inDataH, inDataL, inData    : STD_LOGIC_VECTOR(4 DOWNTO 0);

  SIGNAL pllLock : STD_LOGIC;
  SIGNAL rstSync : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL rst_n   : STD_LOGIC;

  SIGNAL bufClk : STD_LOGIC;

  SIGNAL ripple      : BOOLEAN;
  TYPE rxState_t IS (IDLE, RECEIVE);
  SIGNAL rxState     : rxState_t;
  SIGNAL rxData      : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL rxErr, rxDV : STD_LOGIC;
  SIGNAL tmp         : STD_LOGIC;

  SIGNAL rxData2       : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL rxErr2, rxDV2 : STD_LOGIC;

  SIGNAL rdreq,wrreq : STD_LOGIC;
  SIGNAL rdempty : STD_LOGIC;
  SIGNAL din,dout : STD_LOGIC_VECTOR(9 DOWNTO 0);
  
BEGIN  -- ARCHITECTURE rtl

  oEthClk <= ethIOClk;
  --oEthClk <= RXC;
  TXC     <= RXC;

  pll: entity work.rgmii1000_pll
	PORT map
	(
		inclk0 => RXC,
		c0		=> ethIOClk
	);

	
  TD       <= outData(3 DOWNTO 0);
  TX_CTL   <= outData(4);
  outDataH <= iTxEn & iTxData(3 DOWNTO 0);
  outDataL <= (iTxEn XOR iTxErr) & iTxData(7 DOWNTO 4);
  eth_ddr_out_1 : ENTITY work.eth_ddr_out
    PORT MAP (
      datain_h => outDataH,
      datain_l => outDataL,
      outclock => ethIOClk,
      dataout  => outData);
	
  inData  <= RX_CTL & RD;
  oRxDV   <= inDataL(4);
  oRxErr  <= inDataH(4) XOR inDataL(4);
  oRxData <= inDataH(3 DOWNTO 0) & inDataL(3 DOWNTO 0);
  eth_ddr_in_1 : ENTITY work.eth_ddr_in
    PORT MAP (
      datain    => inData,
      inclock   => ethIOClk,            -- shift 180~360 degree compared to RXC
      dataout_h => inDataH,
      dataout_l => inDataL);
  
END ARCHITECTURE rtl;
