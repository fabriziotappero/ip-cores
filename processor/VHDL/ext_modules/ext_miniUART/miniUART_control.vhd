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
-- Title      : miniUART Control
-- Module     : ext_miniUART
-- Project    : HW/SW-Codesign
-------------------------------------------------------------------------------
-- File       : miniUART_control.vhd
-- Author     : Roman Seiger
-- Company    : TU Wien - Institut für Technische Informatik
-- Created    : 2005-03-10
-- Last update: 2007-05-02
-------------------------------------------------------------------------------



----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;

use work.pkg_basic.all;
USE work.pkg_miniUART.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------
entity miniUART_control is
  
  port (
    clk : in std_logic;
    reset : in std_logic;               
--    MsgLength : in MsgLength_type;      
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
  
end miniUART_control;

----------------------------------------------------------------------------------
-- ARCHITECTURE
----------------------------------------------------------------------------------
architecture behaviour of miniUART_control is

  -- interne Signale zur synchronisation der Ausgänge
  signal EnaRec_i : std_logic;
  signal StartTrans_i : std_logic;
  signal EnaRec_old : std_logic;
  signal StartTrans_old : std_logic;
  signal ParityErr_i : std_logic;

  signal TBR_i : std_logic;
  signal RBR_i : std_logic;
  
  -- in/out
  signal Data_r_i : Data_type;
  signal FrameErr_i : std_logic;
  
  -- interne Signale zur Zwischenspeicherung der Eingänge
--  signal MsgLength_i : MsgLength_type;
  signal ParEna_i : std_logic;
  signal Odd_i : std_logic;
  signal ParBit_r_i : std_logic;

  signal old_TransComp : std_logic;
  signal old_RecBusy : std_logic;
  signal old_RecComp : std_logic;
  
  
  -- Events
  signal event_i : std_logic;
  
begin  -- behaviour
  
  -- empfangene Daten direkt übernehmen
  Data_r_i <= Data_r;
  ParBit_r_i <= ParBit_r;
  FrameErr_i <= FrameErr;
  
-------------------------------------------------------------------------------
-- Control Synchronisierung
-------------------------------------------------------------------------------
  CTRL_SYNC: process (clk, reset)
  begin  -- process CTRL_SYNC
    --reset, alles zurücksetzen
    if reset = RST_ACT then
      Data_r_out <= (others => '0');
      FrameErr_out <= not FRAME_ERROR;
      ParityErr <= not PARITY_ERROR;
      EnaRec <= not RECEIVER_ENABLED;
      EnaRec_old <= not RECEIVER_ENABLED;
      StartTrans <= not BRG_ON;
      StartTrans_old <= not BRG_ON;
      event <= not EV_OCC;
      
      TBR <= TB_READY; -- neue Nachricht annehmen
      RBR <= not RB_READY;
      
      old_TransComp <= not TRANS_COMP;
      old_RecBusy <= not REC_BUSY;
      old_RecComp <= not REC_COMPLETE;

--      MsgLength_i <= (others => '0');
      ParEna_i <= not PARITY_ENABLE;
      Odd_i <= '0';
      
    elsif clk'event and clk = '1' then
      -- Daten ausgeben
      Data_r_out <= Data_r_i;
      FrameErr_out <= FrameErr_i;
      ParityErr <= ParityErr_i;
      EnaRec <= EnaRec_i;
      StartTrans <= StartTrans_i;
      EnaRec_old <= EnaRec_i;
      StartTrans_old <= StartTrans_i;
      event <= event_i;
      
      TBR <= TBR_i;
      RBR <= RBR_i;

      -- Zustand merken (um Flanke zu erkennen!)
      old_TransComp <= TransComp;
      old_RecBusy <= RecBusy;
      old_RecComp <= RecComp;

      -- Daten merken
  --    MsgLength_i <= MsgLength_i;
      ParEna_i <= ParEna_i;
      Odd_i <= Odd_i;      

      -- Daten übernehmen (beim Einschalten des Receivers)
      if (EnaRec_old /= RECEIVER_ENABLED) and (EnaRec_i = RECEIVER_ENABLED) then
        -- Aktuelle Daten übernehmen
--        MsgLength_i <= MsgLength;
        ParEna_i <= ParEna;
        Odd_i <= Odd;       
      end if;
    end if;
  end process CTRL_SYNC;

-------------------------------------------------------------------------------
-- Control Logic
-------------------------------------------------------------------------------
  CTRL_LOGIC: process (EvS, AsA, StartTrans_old, EnaRec_old, TransComp, old_TransComp,
                       RecComp, old_RecComp, RecBusy, old_RecBusy)
                   --    ParEna, Odd, ParEna_i, Odd_i)
    
  begin  -- process CTRL_LOGIC
    StartTrans_i <= StartTrans_old;
    EnaRec_i <= EnaRec_old;
    event_i <= not EV_OCC;
    
    TBR_i <= not TB_READY;
    RBR_i <= not RB_READY;
      
-- TRANSMITTER
    -- Transmitter startet (TBR nur 1 clk halten!)
    if (old_TransComp = TRANS_COMP) and (TransComp /= TRANS_COMP) then
      TBR_i <= TB_READY;

    -- Transmission completed
    elsif (old_TransComp /= TRANS_COMP) and (TransComp = TRANS_COMP) then
      -- BRG und damit Transmitter ausschalten
      StartTrans_i <= not BRG_ON;      
      -- Event signalisieren
      if EvS = EV_TCOMP then
        event_i <= EV_OCC;
        if AsA = ASA_STRANS then
          -- Transmitter starten
          StartTrans_i <= BRG_ON;        
        elsif AsA = ASA_EREC then
          -- Receiver einschalten
          EnaRec_i <= RECEIVER_ENABLED;        
        elsif AsA = ASA_DREC then
          -- Receiver ausschalten
          EnaRec_i <= not RECEIVER_ENABLED;
        end if;              
      end if;
    end if;

-- RECEIVER
    -- Startbit detected
    if (old_RecBusy /= REC_BUSY) and (RecBusy = REC_BUSY) then
      
      if EvS = EV_SBD then
        event_i <= EV_OCC;
        if AsA = ASA_DREC then
          -- Receiver ausschalten
          EnaRec_i <= not RECEIVER_ENABLED;
        elsif AsA = ASA_STRANS then
          -- Transmitter starten
          StartTrans_i <= BRG_ON;        
        end if;
      end if;
      
      -- ganze Nachricht empfangen (RBR nur 1 clk halten!)
    elsif (old_RecComp /= REC_COMPLETE) and (RecComp = REC_COMPLETE) then
      RBR_i <= RB_READY;
      if EvS = EV_RCOMP then
        event_i <= EV_OCC;
        if AsA = ASA_DREC then
          -- Receiver ausschalten            
          EnaRec_i <= not RECEIVER_ENABLED;
        elsif AsA = ASA_STRANS then
          -- Transmitter starten
          StartTrans_i <= BRG_ON;                    
        end if;
      end if;
    end if;    
    
-- NOEVENT
    if EvS = EV_NONE then
      if AsA = ASA_STRANS then
        -- Transmitter starten
        StartTrans_i <= BRG_ON;        
      elsif AsA = ASA_EREC then
        -- Receiver einschalten
        EnaRec_i <= RECEIVER_ENABLED;        
      elsif AsA = ASA_DREC then
        -- Receiver ausschalten
        EnaRec_i <= not RECEIVER_ENABLED;
      end if;      
    end if;
    
  end process CTRL_LOGIC;

-------------------------------------------------------------------------------
-- Parity
-------------------------------------------------------------------------------
  PARITY_CALC: process (Data_r_i, Odd_i, ParBit_r_i, ParEna_i)
--    variable i : integer;
    variable parity : std_logic;
  begin  -- process PARITY_CALC
    parity := '0';

--   for i in conv_Integer(unsigned(MsgLength_i)) downto 0 loop
     for i in 15 downto 0 loop
       parity := parity xor Data_r_i(i);
     end loop;
    
    -- Odd oder even?
    if ((parity xor Odd_i) /= ParBit_r_i) and (ParEna_i = PARITY_ENABLE) then
      ParityErr_i <= PARITY_ERROR;
    else
      ParityErr_i <= not PARITY_ERROR;
    end if;
  end process PARITY_CALC;
    
end behaviour;
