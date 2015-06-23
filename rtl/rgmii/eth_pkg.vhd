-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : eth_pkg.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2012-11-04
-- Last update: 2012-12-03
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 OE@HUST
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-11-04  1.0      root    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
PACKAGE eth_pkg IS

  CONSTANT ETH_TYPE_IPv4  : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0800";
  CONSTANT ETH_TYPE_ARP   : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0806";
  CONSTANT ETH_TYPE_RARP  : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"8035";
  CONSTANT ETH_TYPE_8021Q : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"8100";
  CONSTANT ETH_TYPE_CTRL  : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"8808";
  CONSTANT ETH_TYPE_JUMBO : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"8870";

  CONSTANT IPv4_PROTOCOL_ICMP : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"01";
  CONSTANT IPv4_PROTOCOL_TCP  : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"06";
  CONSTANT IPv4_PROTOCOL_UDP  : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"11";

  -- multicast address for control frame
  CONSTANT MAC_ADDR_CTRL : STD_LOGIC_VECTOR(47 DOWNTO 0) := X"0180C2000001";

  CONSTANT TCP_OPT_EOL : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"00";  --end of list
  CONSTANT TCP_OPT_NOP : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"01";
  CONSTANT TCP_OPT_MSS : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"02";
  CONSTANT TCP_OPT_WS  : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"03";  --window scale

  -----------------------------------------------------------------------------
  -- registers address
  -----------------------------------------------------------------------------
  CONSTANT REG_ADDR_WIDTH  : INTEGER                             := 5;
  CONSTANT MDIO_MODER_addr : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(0, REG_ADDR_WIDTH);
  CONSTANT MDIO_CMD_addr   : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(1, REG_ADDR_WIDTH);
  CONSTANT MDIO_ADDR_addr  : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(2, REG_ADDR_WIDTH);
  CONSTANT MDIO_TxD_addr   : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(3, REG_ADDR_WIDTH);
  CONSTANT MDIO_RxD_addr   : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(4, REG_ADDR_WIDTH);

  CONSTANT RGMII_STATUS_addr : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(5, REG_ADDR_WIDTH);
  CONSTANT MAC_ADDR0L_addr   : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(6, REG_ADDR_WIDTH);
  CONSTANT MAC_ADDR0H_addr   : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(7, REG_ADDR_WIDTH);
  CONSTANT MAC_ADDR1L_addr   : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(8, REG_ADDR_WIDTH);
  CONSTANT MAC_ADDR1H_addr   : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(9, REG_ADDR_WIDTH);
  CONSTANT IP_ADDR0_addr     : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(10, REG_ADDR_WIDTH);
  CONSTANT IP_ADDR1_addr     : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(11, REG_ADDR_WIDTH);
  CONSTANT LISTEN_PORT_addr  : UNSIGNED(REG_ADDR_WIDTH-1 DOWNTO 0) := to_unsigned(12, REG_ADDR_WIDTH);

  
END PACKAGE eth_pkg;
-------------------------------------------------------------------------------
PACKAGE BODY eth_pkg IS



END PACKAGE BODY eth_pkg;
