-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : eth_crc32.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2012-11-04
-- Last update: 2012-11-06
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
-- 经过测试没有问题！计算后输出到外面的crc值需要按照以太网的大小端模式发送才是正确的！
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-------------------------------------------------------------------------------
ENTITY eth_crc32 IS

  PORT (
    iClk    : IN  STD_LOGIC;
    iRst_n  : IN  STD_LOGIC;
    iInit   : IN  STD_LOGIC;
    iCalcEn : IN  STD_LOGIC;
    iData   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    oCRC    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oCRCErr : OUT STD_LOGIC);

END ENTITY eth_crc32;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF eth_crc32 IS

  SIGNAL crc, nxtCrc : STD_LOGIC_VECTOR(31 DOWNTO 0);
  
BEGIN  -- ARCHITECTURE rtl

  nxtCrc(0) <= crc(24) XOR crc(30) XOR iData(1) XOR iData(7);
  nxtCrc(1) <= crc(25) XOR crc(31) XOR iData(0) XOR iData(6) XOR crc(24) XOR crc(30) XOR iData(1) XOR iData(7);
  nxtCrc(2) <= crc(26) XOR iData(5) XOR crc(25) XOR crc(31) XOR iData(0) XOR iData(6) XOR crc(24) XOR crc(30) XOR iData(1) XOR iData(7);
  nxtCrc(3) <= crc(27) XOR iData(4) XOR crc(26) XOR iData(5) XOR crc(25) XOR crc(31) XOR iData(0) XOR iData(6);
  nxtCrc(4) <= crc(28) XOR iData(3) XOR crc(27) XOR iData(4) XOR crc(26) XOR iData(5) XOR crc(24) XOR crc(30) XOR iData(1) XOR iData(7);
  nxtCrc(5) <= crc(29) XOR iData(2) XOR crc(28) XOR iData(3) XOR crc(27) XOR iData(4) XOR crc(25) XOR crc(31) XOR iData(0) XOR iData(6) XOR crc(24) XOR crc(30) XOR iData(1) XOR iData(7);
  nxtCrc(6) <= crc(30) XOR iData(1) XOR crc(29) XOR iData(2) XOR crc(28) XOR iData(3) XOR crc(26) XOR iData(5) XOR crc(25) XOR crc(31) XOR iData(0) XOR iData(6);
  nxtCrc(7) <= crc(31) XOR iData(0) XOR crc(29) XOR iData(2) XOR crc(27) XOR iData(4) XOR crc(26) XOR iData(5) XOR crc(24) XOR iData(7);
  nxtCrc(8) <= crc(0) XOR crc(28) XOR iData(3) XOR crc(27) XOR iData(4) XOR crc(25) XOR iData(6) XOR crc(24) XOR iData(7);
  nxtCrc(9) <= crc(1) XOR crc(29) XOR iData(2) XOR crc(28) XOR iData(3) XOR crc(26) XOR iData(5) XOR crc(25) XOR iData(6);
  nxtCrc(10) <= crc(2) XOR crc(29) XOR iData(2) XOR crc(27) XOR iData(4) XOR crc(26) XOR iData(5) XOR crc(24) XOR iData(7);
  nxtCrc(11) <= crc(3) XOR crc(28) XOR iData(3) XOR crc(27) XOR iData(4) XOR crc(25) XOR iData(6) XOR crc(24) XOR iData(7);
  nxtCrc(12) <= crc(4) XOR crc(29) XOR iData(2) XOR crc(28) XOR iData(3) XOR crc(26) XOR iData(5) XOR crc(25) XOR iData(6) XOR crc(24) XOR crc(30) XOR iData(1) XOR iData(7);
  nxtCrc(13) <= crc(5) XOR crc(30) XOR iData(1) XOR crc(29) XOR iData(2) XOR crc(27) XOR iData(4) XOR crc(26) XOR iData(5) XOR crc(25) XOR crc(31) XOR iData(0) XOR iData(6);
  nxtCrc(14) <= crc(6) XOR crc(31) XOR iData(0) XOR crc(30) XOR iData(1) XOR crc(28) XOR iData(3) XOR crc(27) XOR iData(4) XOR crc(26) XOR iData(5);
  nxtCrc(15) <= crc(7) XOR crc(31) XOR iData(0) XOR crc(29) XOR iData(2) XOR crc(28) XOR iData(3) XOR crc(27) XOR iData(4);
  nxtCrc(16) <= crc(8) XOR crc(29) XOR iData(2) XOR crc(28) XOR iData(3) XOR crc(24) XOR iData(7);
  nxtCrc(17) <= crc(9) XOR crc(30) XOR iData(1) XOR crc(29) XOR iData(2) XOR crc(25) XOR iData(6);
  nxtCrc(18) <= crc(10) XOR crc(31) XOR iData(0) XOR crc(30) XOR iData(1) XOR crc(26) XOR iData(5);
  nxtCrc(19) <= crc(11) XOR crc(31) XOR iData(0) XOR crc(27) XOR iData(4);
  nxtCrc(20) <= crc(12) XOR crc(28) XOR iData(3);
  nxtCrc(21) <= crc(13) XOR crc(29) XOR iData(2);
  nxtCrc(22) <= crc(14) XOR crc(24) XOR iData(7);
  nxtCrc(23) <= crc(15) XOR crc(25) XOR iData(6) XOR crc(24) XOR crc(30) XOR iData(1) XOR iData(7);
  nxtCrc(24) <= crc(16) XOR crc(26) XOR iData(5) XOR crc(25) XOR crc(31) XOR iData(0) XOR iData(6);
  nxtCrc(25) <= crc(17) XOR crc(27) XOR iData(4) XOR crc(26) XOR iData(5);
  nxtCrc(26) <= crc(18) XOR crc(28) XOR iData(3) XOR crc(27) XOR iData(4) XOR crc(24) XOR crc(30) XOR iData(1) XOR iData(7);
  nxtCrc(27) <= crc(19) XOR crc(29) XOR iData(2) XOR crc(28) XOR iData(3) XOR crc(25) XOR crc(31) XOR iData(0) XOR iData(6);
  nxtCrc(28) <= crc(20) XOR crc(30) XOR iData(1) XOR crc(29) XOR iData(2) XOR crc(26) XOR iData(5);
  nxtCrc(29) <= crc(21) XOR crc(31) XOR iData(0) XOR crc(30) XOR iData(1) XOR crc(27) XOR iData(4);
  nxtCrc(30) <= crc(22) XOR crc(31) XOR iData(0) XOR crc(28) XOR iData(3);
  nxtCrc(31) <= crc(23) XOR crc(29) XOR iData(2);

  PROCESS (iClk,iRst_n) IS 
  BEGIN 
   IF iRst_n = '0' THEN 
    crc <= (OTHERS => '0');
   ELSIF rising_edge(iClk) THEN
     IF iInit = '1' THEN
       crc <= (OTHERS => '1');
     ELSIF iCalcEn = '1' THEN
       crc <= nxtCrc;
     END IF;
   END IF;
  END PROCESS;
  
  oCRC(31 DOWNTO 24) <= NOT (crc(24)&crc(25)&crc(26)&crc(27)&crc(28)&crc(29)&crc(30)&crc(31));
  oCRC(23 DOWNTO 16) <= NOT (crc(16)&crc(17)&crc(18)&crc(19)&crc(20)&crc(21)&crc(22)&crc(23));
  oCRC(15 DOWNTO 8) <= NOT (crc(8)&crc(9)&crc(10)&crc(11)&crc(12)&crc(13)&crc(14)&crc(15));
  oCRC(7 DOWNTO 0) <= NOT (crc(0)&crc(1)&crc(2)&crc(3)&crc(4)&crc(5)&crc(6)&crc(7));

  oCRCErr <= '1' WHEN crc /= X"c704dd7b" ELSE '0';  -- CRC not equal to magic number
  
END ARCHITECTURE rtl;

