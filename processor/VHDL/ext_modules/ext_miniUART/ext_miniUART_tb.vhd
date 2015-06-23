-----------------------------------------------------------------------
-- This file is part of SCARTS.
-- 
-- SCARTS is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- SCARTS is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with SCARTS.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Title      : miniUART Testbench
-- Module     : ext_miniUART
-- Project    : HW/SW-Codesign
-------------------------------------------------------------------------------
-- File       : ext_miniUART_tb.vhd
-- Author     : Roman Seiger
-- Company    : TU Wien - Institut für Technische Informatik
-- Created    : 2005-03-24
-- Last update: 2008-05-29
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tests:
-------------------------------------------------------------------------------
--General:
-- OFF (wrong Addr, not ExtEna)
-- Access Violation: write
-- Access Violation: read
-- ID
-- LooW/LooR
-- transmitting -> Output Disable
-- transmitting -> FSS
-- transmitting -> SoftReset
-------------------------------------------------------------------------------
--Transmit:
-- NOEVENT, transmit, polling, 8 P 1S (Even Parity)
-- NOEVENT, transmit, polling, 8 P 1S (Odd Parity)
-- NOEVENT, transmit, polling, 8 P 2S (alle weiteren P: Even Parity)
-- NOEVENT, transmit, polling, 8 1S 
-- NOEVENT, transmit, polling, 8 2S 
-- NOEVENT, transmit, polling, 1 P 1S 
-- NOEVENT, transmit, polling, 1 P 2S 
-- NOEVENT, transmit, polling, 1 1S 
-- NOEVENT, transmit, polling, 1 2S 
-- NOEVENT, transmit, polling, 16 P 1S 
-- NOEVENT, transmit, polling, 16 P 2S 
-- NOEVENT, transmit, polling, 16 1S 
-- NOEVENT, transmit, polling, 16 2S 
-- EV_TRCOMP, transmit, polling, 1 P 1S
-- EV_TRCOMP, transmit, interrupt, 1 P 1S
-- EV_TRCOMP -> start transmission, transmit, polling, 1 P 1S
-------------------------------------------------------------------------------
--Receive:
-- NOEVENT, receive, polling, 8 P 1S (Even Parity)
-- NOEVENT, receive, polling, 8 P 1S (Odd Parity)
-- NOEVENT, receive, polling, 8 P 2S (alle weiteren P: Even Parity)
-- NOEVENT, receive, polling, 8 1S
-- NOEVENT, receive, polling, 8 2S
-- NOEVENT, receive, polling, 1 P 1S
-- NOEVENT, receive, polling, 1 P 2S
-- NOEVENT, receive, polling, 1 1S
-- NOEVENT, receive, polling, 1 2S
-- NOEVENT, receive, polling, 16 P 1S
-- NOEVENT, receive, polling, 16 P 2S
-- NOEVENT, receive, polling, 16 1S
-- NOEVENT, receive, polling, 16 2S
-- NOEVENT, receive, polling, 1 P 1S, Parity Error + Frame Error, noTrCtrl
-- NOEVENT, receive, polling, 1 P 1S, Parity Error
-- NOEVENT, receive, polling, 1 P 1S, Frame Error
-- NOEVENT, receive, polling, 1 P 1S, Parity Error + ERRI
-- NOEVENT, receive, polling, 1 P 1S, Frame Error + ERRI
-- NOEVENT, receive, polling, 2 P 1S, Overflow
-- STARTBITDETECTION, receive, polling, 1 P 1S
-- STARTBITDETECTION, receive, interrupt, 1 P 1S
-- STARTBITDETECTION -> disable receiver, receive, polling, 1 P 1S
-- EV_RCOMP, receive, polling, 1 P 1S
-- EV_RCOMP, receive, interrupt, 1 P 1S
-- EV_RCOMP -> disable receiver, receive, polling, 1 P 1S
------------------------------------------------------------------------------- 
--Receive & Transmit
-- EV_TRCOMP -> enable receiver, 1 P 1S
-- EV_TRCOMP -> disable receiver, 1 P 1S
-- STARTBITDETECTION -> start transmission, 1 P 1S
-- EV_RCOMP -> start transmission, 1 P 1S
-- NOEVENT, receive & transmit, 8 P 1S
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;

use work.pkg_basic.all;
use work.pkg_miniUART.all;

-------------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------
entity ext_miniUART_tb is
  
end ext_miniUART_tb;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture behaviour of ext_miniUART_tb is

  -- Baudraten (@ 25Mhz)
  -- 9600 bit/s: UBRS = 2604.16(.125)
--  constant BITCLK : integer := 2604;
--  constant UBRS_CONST : std_logic_vector(15 downto 0) := "1010001011000010";

  -- 19200 bit/s: UBRS = 1302.083(.0625)
  constant BITCLK : integer := 1302;
  constant UBRS_CONST : std_logic_vector(15 downto 0) := "0101000101100001";

  -- 115200 bit/s: UBRS = 217.0138(.0)
--  constant BITCLK : integer := 217;
--  constant UBRS_CONST : std_logic_vector(15 downto 0) := "0000110110010000";

  -- Daten
  constant DATA_CONST1 : std_logic_vector(15 downto 0) := "0000000000000001";
  constant DATA_CONST8 : std_logic_vector(15 downto 0) := "0000000001010101";
  constant DATA_CONST16 : std_logic_vector(15 downto 0) := "0101010101010101";

  -- BaseAddress (bei MINIUART_BASE = 51)
  constant MINIUART_BADDR_TB : std_logic_vector(15 downto 3) := "1111111110011";
  
  -- allgemein
  signal clk : std_logic := '0';
  -- clock constant: Dauer eines Clockticks (25Mhz = 40ns) 
  constant cc : time := 40 ns;

  constant DADDR_W : integer := 16;
  constant ACCVIOL_ACT : std_logic := '1';
  constant RES_ACT : std_logic := RST_ACT;

-------------------------------------------------------------------------------
  -- Device under Test: signale
  signal reset : std_logic;               
  signal AccViol : std_logic;
  signal ExtEna : std_logic;
  signal ExtWr : std_logic;
  signal ExtAddr : std_logic_vector(DADDR_W-1 DOWNTO 0);
  signal Data2Ext : std_logic_vector(DATA_W-1 DOWNTO 0);
  signal ExtIntReq : std_logic;
  signal WrBData : std_logic_vector(DATA_W-1 DOWNTO 0);

  signal RxD : std_logic;  -- Empfangsleitung
  signal TxD : std_logic;  -- Sendeleitung

  

  signal extsel : std_logic;
  signal exti   : module_in_type;
  signal exto   : module_out_type;

  -- Device under Test
  component ext_miniUART
    port (
      clk    : IN  std_logic;
      extsel : in  std_logic;
      exti   : in  module_in_type;
      exto   : out module_out_type;
      RxD    : IN  std_logic;
      TxD    : OUT std_logic); 
  end component;



-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- BEGIN ARCHITECTURE
-------------------------------------------------------------------------------
  begin  -- behaviour

-------------------------------------------------------------------------------
    -- DuT: Port map
    ext_miniUART_1: ext_miniUART
      port map (
        clk    => clk,
        extsel => extsel,
        exti   => exti,
        exto   => exto,
        RxD    => RxD,
        TxD    => TxD);



-------------------------------------------------------------------------------
    
    -- Clock Generator
    CLKGEN : PROCESS
     BEGIN
       clk <= '1';
       wait for cc/2;
       clk <= '0';
       wait for cc/2;
     END PROCESS CLKGEN;


     interface_wrapper: process (reset, AccViol, ExtAddr, ExtWr, ExtEna, Data2Ext)
     begin  -- process interface_wrapper
       extsel           <= ExtEna; 
       exti.reset       <= reset;
       exti.write_en    <= ExtWr;
       exti.byte_en     <= "0011";
       exti.data        <= Data2Ext&Data2Ext;
       exti.addr        <= ExtAddr(14 downto 0);
     end process interface_wrapper;
     

     -- Testprocess
     test: process
       -- "cycles" Clockcycles abwarten
       procedure icwait(cycles: Natural) is 
       begin
         for i in 1 to cycles loop
           wait until clk= '0' and clk'event;
         end loop;
       end icwait;

     begin  -- test

-------------------------------------------------------------------------------       
--GENERAL:
-- OFF (wrong Addr, not ExtEna)
       reset <= RES_ACT;
       icwait(5);

       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- irgendwas lesen (wrong Addr)
       ExtAddr <= ("0000000000000000");
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- Status lesen (not ExtEna)
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= not EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       icwait(BITCLK/2);

-- Access Violation: write
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- MSGREG setzen (AccViol)
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= "1000100010001000";
       AccViol <= ACCVIOL_ACT;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       AccViol <= not ACCVIOL_ACT;

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       icwait(BITCLK/2);
       
-- Access Violation: read
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- Status lesen (AccViol)
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       AccViol <= ACCVIOL_ACT;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);
       
       AccViol <= not ACCVIOL_ACT;

       icwait(BITCLK/2);
       
-- ID
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- CONF setzen: noLooW, noEFSS, noOutD, noSRes, Id, noINTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000000000010";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);

       -- DATA0 lesen
       ExtAddr <= "1111111110011010";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- DATA1 lesen
       ExtAddr <= "1111111110011011";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       icwait(BITCLK/2);

-- LooW/LooR
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- CONF setzen: LooW, noEFSS, noOutD, noSRes, noId, noINTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000010000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- CONF setzen: noLooW, noEFSS, noOutD, noSRes, noId, noINTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       icwait(BITCLK/2);
       
-- transmitting -> Output Disable
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST8;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       icwait(3*BITCLK);

       -- CONF setzen: noLooW, noEFSS, OutD, noSRes, noId, noINTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000000001000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);

       icwait(2*BITCLK);

       -- CONF setzen: noLooW, noEFSS, noOutD, noSRes, noId, noINTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);

       icwait(BITCLK/2);

       reset <= RES_ACT;
       icwait(5);
       
-- transmitting -> FSS
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST8;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       icwait(3*BITCLK);

       -- CONF setzen: noLooW, EFSS, noOutD, noSRes, noId, noINTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000000010000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       icwait(BITCLK/2);

       reset <= RES_ACT;
       icwait(5);
       
-- transmitting -> SoftReset
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST8;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       icwait(3*BITCLK);

       -- CONF setzen: noLooW, noEFSS, noOutD, SRes, noId, noINTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000000000100";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);

       icwait(BITCLK/2);

       reset <= RES_ACT;
       icwait(5);
       
-------------------------------------------------------------------------------
--Transmit:
-- NOEVENT, transmit, polling, 8 P 1S (Even Parity)
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST8;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 12 bits warten (1 start + 8 data + 1 parity + 1 Stop = 11 + 1 zum Überprüfen)
       icwait(12*BITCLK);

-- NOEVENT, transmit, polling, 8 P 1S (Odd Parity)
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 P Odd 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1100011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST8;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 12 bits warten (1 start + 8 data + 1 parity + 1 Stop = 11 + 1 zum Überprüfen)
       icwait(12*BITCLK);

-- NOEVENT, transmit, polling, 8 P 2S (alle weiteren P: Even Parity)
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 P Even 2S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1010011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST8;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 13 bits warten (1 start + 8 data + 1 parity + 2 Stop = 12 + 1 zum Überprüfen)
       icwait(13*BITCLK);

-- NOEVENT, transmit, polling, 8 1S 
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0000011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST8;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 11 bits warten (1 start + 8 data + 1 Stop = 10 + 1 zum Überprüfen)
       icwait(11*BITCLK);

-- NOEVENT, transmit, polling, 8 2S 
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 2S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0010011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST8;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 12 bits warten (1 start + 8 data + 2 Stop = 11 + 1 zum Überprüfen)
       icwait(12*BITCLK);

-- NOEVENT, transmit, polling, 1 P 1S 
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST1;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 5 bits warten (1 start + 1 data + 1 parity + 1 Stop = 4 + 1 zum Überprüfen)
       icwait(5*BITCLK);

-- NOEVENT, transmit, polling, 1 P 2S 
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 2S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1010000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST1;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 6 bits warten (1 start + 1 data + 1 parity + 2 Stop = 5 + 1 zum Überprüfen)
       icwait(6*BITCLK);

-- NOEVENT, transmit, polling, 1 1S 
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST1;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 4 bits warten (1 start + 1 data + 1 Stop = 3 + 1 zum Überprüfen)
       icwait(4*BITCLK);

-- NOEVENT, transmit, polling, 1 2S 
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1  2S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0010000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST1;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 5 bits warten (1 start + 1 data + 2 Stop = 4 + 1 zum Überprüfen)
       icwait(5*BITCLK);

-- NOEVENT, transmit, polling, 16 P 1S 
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 16 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000111100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST16;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 20 bits warten (1 start + 16 data + 1 parity + 1 Stop = 19 + 1 zum Überprüfen)
       icwait(20*BITCLK);

-- NOEVENT, transmit, polling, 16 P 2S 
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 16 P Even 2S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1010111100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST16;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 21 bits warten (1 start + 16 data + 1 parity + 2 Stop = 20 + 1 zum Überprüfen)
       icwait(21*BITCLK);

-- NOEVENT, transmit, polling, 16 1S 
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 16 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0000111100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST16;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 19 bits warten (1 start + 16 data + 1 Stop = 18 + 1 zum Überprüfen)
       icwait(19*BITCLK);

-- NOEVENT, transmit, polling, 16 2S 
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 16 2S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0010111100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST16;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 20 bits warten (1 start + 16 data + 2 Stop = 19 + 1 zum Überprüfen)
       icwait(20*BITCLK);

-- EV_TRCOMP, transmit, polling, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST1;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, TRCOMP
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000110";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 5 bits warten (1 start + 1 data + 1 parity + 1 Stop = 4 + 1 zum Überprüfen)
       icwait(5*BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       icwait(BITCLK/2);
       
-- EV_TRCOMP, transmit, interrupt, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST1;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, EI, NOACTION, TRCOMP
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000001000110";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 5 bits warten (1 start + 1 data + 1 parity + 1 Stop = 4 + 1 zum Überprüfen)
       icwait(5*BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);
       
       -- CONF setzen: noLooW, noEFSS, noOutD, noSRes, noId, INTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000000000001";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       icwait(BITCLK/2);
       
-- EV_TRCOMP -> start transmission, transmit, polling, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST1;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(20);

       -- UARTCMD setzen: noERRI, noEI, STRANS, TRCOMP
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011110";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 5 bits warten (1 start + 1 data + 1 parity + 1 Stop = 4 + 1 zum Überprüfen)
       icwait(5*BITCLK);
       
       -- UARTCMD setzen: noERRI, noEI, NOACTION, TRCOMP
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000110";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 5 bits warten (1 start + 1 data + 1 parity + 1 Stop = 4 + 1 zum Überprüfen)
       icwait(5*BITCLK);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       icwait(BITCLK/2);
       
-------------------------------------------------------------------------------
--Receive:
-- NOEVENT, receive, polling, 8 P 1S (Even Parity)
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(BITCLK);
       ExtEna <= not EXT_ACT;       

       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (8)
       icwait(BITCLK);
       RxD <= '0';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 8 P 1S (Odd Parity)
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 P Odd 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1101011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (8)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Odd)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 8 P 2S (alle weiteren P: Even Parity)
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 P Even 2S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1011011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (8)
       icwait(BITCLK);
       RxD <= '0';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- 1. Stopbit
       icwait(BITCLK);
       RxD <= '1';                      -- 2. Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);

-- NOEVENT, receive, polling, 8 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0001011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (8)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);

-- NOEVENT, receive, polling, 8 2S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 2S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0011011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (8)
       icwait(BITCLK);
       RxD <= '1';                      -- 1. Stopbit
       icwait(BITCLK);
       RxD <= '1';                      -- 2. Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 1 P 2S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 2S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1011000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- 1.Stopbit
       icwait(BITCLK);
       RxD <= '1';                      -- 2.Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 1 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 1 2S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 2S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0011000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- 1.Stopbit
       icwait(BITCLK);
       RxD <= '1';                      -- 2.Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 16 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 16 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001111100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (8)
       icwait(BITCLK);
       RxD <= '1';                      -- Message (9)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (16)
       icwait(BITCLK);
       RxD <= '0';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 16 P 2S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 16 P Even 2S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1011111100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (8)
       icwait(BITCLK);
       RxD <= '1';                      -- Message (9)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (16)
       icwait(BITCLK);
       RxD <= '0';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- 1.Stopbit
       icwait(BITCLK);
       RxD <= '1';                      -- 2.Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 16 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 16 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0001111100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (8)
       icwait(BITCLK);
       RxD <= '1';                      -- Message (9)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (16)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 16 2S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 16 2S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "0011111100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (8)
       icwait(BITCLK);
       RxD <= '1';                      -- Message (9)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (16)
       icwait(BITCLK);
       RxD <= '1';                      -- 1.Stopbit
       icwait(BITCLK);
       RxD <= '1';                      -- 2.Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 1 P 1S, Parity Error + Frame Error, noTrCtrl
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      -- wrong Paritybit (Even)
       icwait(BITCLK);
       RxD <= '0';                      -- wrong Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 1 P 1S, Parity Error
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      -- wrong Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 1 P 1S, Frame Error
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '0';                      -- wrong Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 1 P 1S, Parity Error + ERRI
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: ERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000010100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      -- wrong Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- CONF setzen: noLooW, noEFSS, noOutD, noSRes, noId, INTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000000000001";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 1 P 1S, Frame Error + ERRI
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: ERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000010100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '0';                      -- wrong Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- CONF setzen: noLooW, noEFSS, noOutD, noSRes, noId, INTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000000000001";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive, polling, 2 P 1S, Overflow
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 2 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      -- Message (2)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '0';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Message (2)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);
       
       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- STARTBITDETECTION, receive, polling, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, SBD
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000010";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK-4);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- STARTBITDETECTION, receive, interrupt, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, EI, NOACTION, SBD
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000001000010";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK-4);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- CONF setzen: noLooW, noEFSS, noOutD, noSRes, noId, INTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000000000001";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- STARTBITDETECTION -> disable receiver, receive, polling, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, SBD
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101010";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK-4);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- EV_RCOMP, receive, polling, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, NOACTION, RCOMP
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000000100";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK-4);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- EV_RCOMP, receive, interrupt, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, EI, NOACTION, RCOMP
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000001000100";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK-4);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- CONF setzen: noLooW, noEFSS, noOutD, noSRes, noId, INTA
       ExtAddr <= "1111111110011001";
       ExtWr <= '1';
       Data2Ext <= "0000000000000001";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- EV_RCOMP -> disable receiver, receive, polling, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, RCOMP
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101100";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '0';                      -- Startbit
       icwait(BITCLK-4);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);

       reset <= RES_ACT;
       icwait(5);
       
------------------------------------------------------------------------------- 
--Receive & Transmit
-- EV_TRCOMP -> enable receiver, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST1;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, EREC, TRCOMP
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100110";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 5 bits warten (1 start + 1 data + 1 parity + 1 Stop = 4 + 1 zum Überprüfen)
       icwait(5*BITCLK);
       
       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '1';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- EV_TRCOMP -> disable receiver, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, noTrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1000000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST1;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, EREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, TRCOMP
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101110";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;   
       icwait(2);
       
       -- 5 bits warten (1 start + 1 data + 1 parity + 1 Stop = 4 + 1 zum Überprüfen)
       icwait(5*BITCLK);
       
       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '0';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);

-- STARTBITDETECTION -> start transmission, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, SBD
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011010";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST1;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);
       
       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '0';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(2*BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- EV_RCOMP -> start transmission, 1 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 1 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001000000000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, RCOMP
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011100";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST1;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);
       
       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '0';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(BITCLK);

       -- 5 bits warten (1 start + 1 data + 1 Parity + 1 Stop = 4 + 1 zum Überprüfen)
       icwait(5*BITCLK);
       
       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
       
-- NOEVENT, receive & transmit, 8 P 1S
       reset <= not RES_ACT;
       AccViol <= not ACCVIOL_ACT;
       RxD <= '1';
       Data2Ext <= (others => '0');
       ExtEna <= not EXT_ACT;

       -- UBRS setzen
       ExtAddr <= "1111111110011111";
       ExtWr <= '1';
       Data2Ext <= UBRS_CONST;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCONF setzen: 8 P Even 1S, TrCtrl
       ExtAddr <= "1111111110011010";
       ExtWr <= '1';
       Data2Ext <= "1001011100000000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG setzen
       ExtAddr <= "1111111110011100";
       ExtWr <= '1';
       Data2Ext <= DATA_CONST8;
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, ENAREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000100000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, STRANS, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000011000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);
       
       RxD <= '0';                      -- Startbit
       icwait(BITCLK);
       RxD <= '1';                      -- Message (1)
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      
       icwait(BITCLK);
       RxD <= '1';                      
       icwait(BITCLK);
       RxD <= '0';                      -- Message (8)
       icwait(BITCLK);
       RxD <= '0';                      -- Paritybit (Even)
       icwait(BITCLK);
       RxD <= '1';                      -- Stopbit

       icwait(2*BITCLK);

       -- Status lesen
       ExtAddr <= "1111111110011000";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- MSGREG lesen
       ExtAddr <= "1111111110011100";
       ExtWr <= '0';
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       -- UARTCMD setzen: noERRI, noEI, DISABLEREC, NOEVENT
       ExtAddr <= "1111111110011011";
       ExtWr <= '1';
       Data2Ext <= "0000000000101000";
       ExtEna <= EXT_ACT;
       icwait(2);
       ExtEna <= not EXT_ACT;       
       icwait(2);

       RxD <= '1';
       icwait(BITCLK/2);
-------------------------------------------------------------------------------
------------------------------------------------------------------------------- 
       
       assert false
         report "Test finished!"
         severity error;
  
     end process;
  
  end behaviour;

