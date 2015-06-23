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
-- Title      : Extension Module: miniUART
-- Project    : HW/SW-Codesign
-------------------------------------------------------------------------------
-- File       : ext_miniUART.vhd
-- Author     : Roman Seiger
-- Company    : TU Wien - Institut für Technische Informatik
-- Created    : 2005-03-10
-- Last update: 2007-05-28
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use work.pkg_basic.all;
-- use work.io.all;

----------------------------------------------------------------------------------
-- PACKAGE
----------------------------------------------------------------------------------
package pkg_miniUART is
  
  constant DATA_W        : integer := 16;
  constant EXTREG_S      : integer := 8;
  
  constant EXT_ACT : std_logic := '1';
  
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                             KONSTANTEN
-------------------------------------------------------------------------------  
-------------------------------------------------------------------------------

  -- globale Konstanten TODO: nur für einzelne Tests!
--constant EXT_ACT         : std_logic := '1';
  constant OUTD_ACT : std_logic := '1';  -- Output Disable
  constant FAILSAFE : std_logic := '1';  -- Failsafestate
 
--  constant MINIUART_BASE : integer := 51;  --TODO: richtige BaseAddr herausfinden!!!
--  constant MINIUART_INTVEC : std_logic_vector(16-1 downto 0) := (others => '0');

  -- Register allgemein
--   constant DATA0        : integer := 2;
--   constant DATA1        : integer := 3;
--   constant DATA2        : integer := 4;
--   constant DATA3        : integer := 5;
--   constant DATA4        : integer := 6;
--   constant DATA5        : integer := 7;
  constant MSGREG_LOW   : integer := 6;--DATA2;   -- Message register
  constant MSGREG_HIGH  : integer := 7;--DATA2;   -- Message register
  constant UBRSREG_LOW  : integer := 4;--DATA5;  -- UART Baud Rate Selection Register
  constant UBRSREG_HIGH : integer := 5;--DATA5;  -- UART Baud Rate Selection Register

  constant STATUSREG_CUST      : integer := 1;
  constant CONFIGREG_CUST      : integer := 3;
  -- Statusregister
--constant EXTSTATUS    : integer := 0;
--  constant EXTSTATUS_CUST    : integer := 1;
  constant STA_TRANSERR  : integer := 6;--14;
  constant STA_PARERR    : integer := 5;--13;f
  constant STA_EVF       : integer := 4;--12;
  constant STA_OVF       : integer := 3;--11;
  constant STA_RBR       : integer := 2;--10;
  constant STA_TBR       : integer := 1;--9;     
--constant ST_LOOR      : integer := 7;
--constant ST_FSS       : integer := 4;
--constant ST_BUSY      : integer := 3;
--constant ST_ERR       : integer := 2;
--constant ST_RDY       : integer := 1;
--constant ST_INT       : integer := 0;

  -- Configregister
--constant EXTCONFIG      : integer := 1;
--constant EXTCONF_LOOW    : integer := 7;
--constant EXTCONF_EFSS    : integer := 4;
constant EXTCONF_OUTD    : integer := 3;
--constant EXTCONF_SRES    : integer := 2;
--constant EXTCONF_ID      : integer := 1;
--constant EXTCONF_INTA    : integer := 0;

  -- UARTConfigregister
  constant EXTUARTCONF         : integer := CONFIGREG_CUST;--4; --DATA0;
  constant EXTCONF_PARENA      : integer := 7;--15;
  constant EXTCONF_PARODD      : integer := 6;--14;
  constant EXTCONF_STOP        : integer := 5;--13;
  constant EXTCONF_TRCTRL      : integer := 4;--12;
  constant EXTCONF_MSGL_H      : integer := 3;--11;
  constant EXTCONF_MSGL_L      : integer := 0;--8;

  -- Commandregister
  constant EXTCMD          : integer := 8;--DATA1;  
  constant EXTCMD_ERRI    : integer := 7;
  constant EXTCMD_EI      : integer := 6;
  constant EXTCMD_ASA_H   : integer := 5;
  constant EXTCMD_ASA_L   : integer := 3;
  constant EXTCMD_EVS_H   : integer := 2;
  constant EXTCMD_EVS_L   : integer := 1;

  -- Config & Statusbits
  constant PARITY_ENABLE : std_logic := '1';  -- Parity enabled
  constant SECOND_STOPBIT : std_logic := '1';  -- Zweites Stopbit enabled
  constant RB_READY : std_logic := '1';  -- Receive Buffer Ready
  constant TB_READY : std_logic := '1';  -- Transmit Buffer Ready
  constant FRAME_ERROR : std_logic := '1';  -- !!!ACHTUNG: FE ist immer 1!!!
  constant PARITY_ERROR : std_logic := '1';  -- Parity Error
  constant OVERFLOW : std_logic := '1';  -- Overflow occured
  constant TRCTRL_ENA : std_logic := '1';  -- Error Control enabled
  

  -- Transmitter
  constant TRANS_COMP : std_logic := '1';  -- Transmission Complete

  -- Receiver
  constant RECEIVER_ENABLED : std_logic := '1';  -- !!!ACHTUNG: muss 1 sein!!!
  constant REC_BUSY : std_logic := '1';  -- Receiving / Startbit detected
  constant REC_COMPLETE : std_logic := '1';  -- komplette Nachricht empfangen

  -- Busdriver
  constant BUSDRIVER_ON : std_logic := '1';  -- Einschaltsignal für Busdriver

  -- Baud Rate Generator
  constant BRG_ON : std_logic := '1';     -- Einschaltsignal für BRG

  -- Events
  constant EV_NONE  : std_logic_vector(1 downto 0) := "00";  -- no event
  constant EV_SBD   : std_logic_vector(1 downto 0) := "01";  -- Startbitdetection
  constant EV_RCOMP : std_logic_vector(1 downto 0) := "10";  -- Receive completion
  constant EV_TCOMP : std_logic_vector(1 downto 0) := "11";  -- Transmit completion
  constant EV_OCC : std_logic := '1';     -- Event occured (muß 1 sein!!!)
  constant EV_INT : std_logic := '1';   -- Event Interrupt enable

  -- Assigned Actions
  constant ASA_STRANS : std_logic_vector(2 downto 0) := "011";  -- start transmission
  constant ASA_EREC : std_logic_vector(2 downto 0) := "100";  -- enable receiver
  constant ASA_DREC : std_logic_vector(2 downto 0) := "101";  -- disable receiver


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                               TYPEN
-------------------------------------------------------------------------------  
-------------------------------------------------------------------------------

  -- Messagelength Signaltyp
  subtype MsgLength_type is std_logic_vector((EXTCONF_MSGL_H - EXTCONF_MSGL_L) downto 0);

  -- Nachricht
  subtype Data_type is std_logic_vector(15 downto 0);
  
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                             KOMPONENTEN
-------------------------------------------------------------------------------  
-------------------------------------------------------------------------------

  component ext_miniUART IS
  --      generic (
	--		GWORD_CFG : integer :=1);
  --        MINIUART_BASE : integer := 51;
  --        MINIUART_INT  : integer := 9);
        PORT(   ---------------------------------------------------------------
                -- Generic Ports
                ---------------------------------------------------------------
                clk           : IN  std_logic; 	
				        extsel        : in  std_logic;
                Exti          : in module_in_type;
                Exto          : out module_out_type;
                
                ---------------------------------------------------------------
                -- Module Specific Ports
                ---------------------------------------------------------------
                RxD           : IN std_logic;  -- Empfangsleitung
                TxD           : OUT std_logic  --;  -- Sendeleitung
                );
  END component;


  component miniUART_control  
    port (
      clk : in std_logic;
      reset : in std_logic;               
--      MsgLength : in MsgLength_type;      
      ParEna : in std_logic;              -- Parity?
      Odd : in std_logic;                 -- Odd or Even Parity?
      AsA : in std_logic_vector(2 downto 0);  -- Assigned Action
      EvS : in std_logic_vector(1 downto 0);  -- Event Selector
      Data_r : in Data_type;              -- received Data
      ParBit_r : in std_logic;            -- empfangenes Paritybit
      FrameErr : in std_logic;
      RecComp : in std_logic;             -- Receive Complete
      RecBusy : in std_logic;             -- Reciever Busy (Startbit detected)        
      TransComp : in std_logic;           -- Transmission complete
      EnaRec : out std_logic;             -- Enable receiver
      Data_r_out : out Data_type;         -- empfangene Daten
      FrameErr_out : out std_logic;
      ParityErr : out std_logic;
      RBR : out std_logic;                -- Receive Buffer Ready (Rec Complete)
      StartTrans : out std_logic;         -- Start Transmitter (halten bis TrComp!)
      TBR : out std_logic;                -- Transmit Buffer Ready (MSGREG read,
                                          -- transmitter started)
      event : out std_logic               -- Selected Event occured!
      );
  end component;


  component miniUART_transmitter
    port (
      clk : in std_logic;
      reset : in std_logic;               
      MsgLength : in MsgLength_type;      
      Stop2 : in std_logic;               -- Zweites Stopbit?
      ParEna : in std_logic;              -- Parity?
      ParBit : in std_logic;              -- Vorberechnetes Paritybit
      Data : in Data_type;
      tp : in std_logic;                  -- Transmitpulse vom BRG
      TransEna : out std_logic;           -- Busdriver einschalten
      TrComp : out std_logic;              -- Transmission complete
      TxD : out std_logic                 -- Sendeausgang
      );
  end component;


  component miniUART_receiver
    port (
      clk : in std_logic;
      reset : in std_logic;               
      enable : in std_logic;              -- Receiver eingeschaltet?
      MsgLength : in MsgLength_type;      
      Stop2 : in std_logic;               -- Zweites Stopbit?
      ParEna : in std_logic;              -- Parity?
      rp : in std_logic;                  -- Receivepulse vom BRG
      RxD : in std_logic;                 -- Empfangseingang
      Data : out Data_type;
      ParBit : out std_logic;             -- Empfangenes Paritybit
      RecEna : out std_logic;             -- Busdriver einschalten
      StartRecPulse : out std_logic;      -- Receivepulse generieren
      busy : out std_logic;               -- Receiving / Startbit detected
      RecComplete : out std_logic;        -- komplettes Frame empfangen
      FrameErr : out std_logic         
      );
  end component;


  component miniUART_BRG  
    port (
      clk : in std_logic;
      reset : in std_logic;               
      StartTrans : in std_logic;          -- Transmitterpulse eingeschaltet?
      StartRec : in std_logic;            -- Receiverpulse eingeschaltet?
      UBRS : in std_logic_vector(15 downto 0);  -- Baud Rate Selection Register 
                                                -- (12bit ganzzahlig, 4bit fraction)
      tp : out std_logic;                 -- Transmitterpulse
      rp : out std_logic                  -- Receiverpulse
      );
  end component;


  component miniUART_busdriver
    port (
      clk : in std_logic;
      reset : in std_logic;               
      OutD : in std_logic;                -- Output disable
      TransEna : in std_logic;            -- Einschalten, von Transmitter
      RecEna : in std_logic;              -- Einschalten, von Receiver
      Data_t : in std_logic;              -- zu sendendes Bit
      Data_r : out std_logic;             -- empfangenes Bit
      TxD : out std_logic;                -- Sendeleitung
      RxD : in std_logic                  -- Empfangsleitung
      );
  end component;

end pkg_miniUART;
