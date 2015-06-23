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
-- Title      : miniUART Receiver v2
-- Module     : ext_miniUART
-- Project    : HW/SW-Codesign
-------------------------------------------------------------------------------
-- File       : miniUART_receiver.vhd
-- Author     : Roman Seiger
-- Company    : TU Wien - Institut für Technische Informatik
-- Created    : 2005-03-08
-- Last update: 2007-05-29
-------------------------------------------------------------------------------



----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
use IEEE.std_logic_UNSIGNED."+";
use work.pkg_basic.all;
use work.pkg_miniUART.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------
entity miniUART_receiver is

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
  
end miniUART_receiver;

----------------------------------------------------------------------------------
-- ARCHITECTURE
----------------------------------------------------------------------------------
architecture behaviour of miniUART_receiver is

  -- max. 20 empfangene Bits (1+16+1+2); 20d = 10100b
  constant BITCOUNTERWIDTH : integer := 5;

  -- Bitnummern der Parity/Stopbits
  constant PARST1 : std_logic_vector(BITCOUNTERWIDTH-1 downto 0) := "10010";
  constant ST1ST2 : std_logic_vector(BITCOUNTERWIDTH-1 downto 0) := "10011";
  constant ST2    : std_logic_vector(BITCOUNTERWIDTH-1 downto 0) := "10100";
  

  -- Definition der States
  type rec_states is (DISABLE_S, STARTBITDETECTION_S, RECEIVE_S);

  signal Rec_State : rec_states;
  signal next_Rec_State : rec_states;

  -- interne Signale zur synchronisation der Ausgänge
  signal ParBit_i : std_logic;
  signal ParBit_old : std_logic;
  signal ParEna_i : std_logic;
  signal Stop2_i : std_logic;
  signal RecEna_i : std_logic;
  signal busy_i : std_logic;
  signal StartRecPulse_i : std_logic;
  signal RecComplete_i : std_logic;       
  signal FrameErr1_i : std_logic;
  signal FrameErr2_i : std_logic;
  signal FrameErr_int : std_logic;
  signal Data_i : Data_type;
--  signal Data : Data_type;
  signal Data_nxt : Data_type;
    
  -- interne Signale zur Zwischenspeicherung der Eingänge
 -- signal RxD_i, RxD_i_nxt : std_logic;
  
  -- Bitzähler
  signal Bitcounter : std_logic_vector(BITCOUNTERWIDTH-1 downto 0);
  signal next_Bitcounter : std_logic_vector(BITCOUNTERWIDTH-1 downto 0);

  -- Nachrichtenlänge
  signal Length : std_logic_vector(3 downto 0);
  signal Length_nxt : std_logic_vector(3 downto 0);
--  signal Length : integer;

  -- alter Empfangswert
  signal old_RxD : std_logic;

  -- alter Pulsewert
--  signal old_rp : std_logic;
  
begin  -- behaviour

  Data <= Data_i;
  
  REC_STATECHANGE: process (clk, reset)
  begin  -- process REC_STATECHANGE
    -- Receiver ausgeschalten, kommt einem reset gleich
    if reset = RST_ACT then
      RecEna <= not BUSDRIVER_ON;
      StartRecPulse <= not BRG_ON;
      busy <= not REC_BUSY;
      RecComplete <= not REC_COMPLETE;
      Bitcounter <= (others => '0');
      Data_i <= (others => '0');
      ParBit <= '0';
      FrameErr_int <= not FRAME_ERROR;
      ParBit_old <= '0';
      old_RxD <= '1';
      Rec_State <= DISABLE_S;
      Length <= (others => '0');
    -- Signale ausgeben, Statechange
    elsif (clk'event and clk = '1') then
      Bitcounter <= next_Bitcounter;
      RecEna <= RecEna_i;
      StartRecPulse <= StartRecPulse_i;
      busy <= busy_i;
      RecComplete <= RecComplete_i;
      ParBit <= ParBit_i;
      ParBit_old <= ParBit_i;
      FrameErr_int <= FrameErr1_i or FrameErr2_i;
      Data_i <= Data_nxt;
      -- Empfangszustand merken (um Flanke zu erkennen!)
      old_RxD <= RxD;
      Rec_State <= next_Rec_State;
      Length <= Length_nxt;
    end if;
    
  end process REC_STATECHANGE;


  
  REC_STATEMACHINE: process (enable, MsgLength, ParEna, Stop2, ParEna_i, Stop2_i,
                              Length, Rec_State, Bitcounter, RxD, Data_i,
                             ParBit_old, FrameErr_int, old_RxD, rp)
  begin  -- process REC_STATEMACHINE

    -- Defaultwerte
    RecEna_i <= not BUSDRIVER_ON;
    StartRecPulse_i <= not BRG_ON;
    busy_i <= not REC_BUSY;
    RecComplete_i <= not REC_COMPLETE;
    next_Bitcounter <= Bitcounter;
    ParEna_i <= ParEna;
    Stop2_i <= Stop2;
    Data_nxt <= Data_i;
    ParBit_i <= ParBit_old;
    FrameErr1_i <= FrameErr_int;
    FrameErr2_i <= FrameErr_int;
    Length_nxt <= Length;
    
    case Rec_State is
      when DISABLE_S => 
        Data_nxt <= (others => '0');
        ParBit_i <= '0';
        FrameErr1_i <= not FRAME_ERROR;
        FrameErr2_i <= not FRAME_ERROR;
        next_Rec_State <= DISABLE_S;
        next_Bitcounter <= (others => '0');
        -- Receiver eingeschalten
        if enable = RECEIVER_ENABLED then
          Length_nxt <= MsgLength; -- Nachrichtenlänge
          ParEna_i <= ParEna;
          Stop2_i <= Stop2;
          RecEna_i <= BUSDRIVER_ON;
          next_Rec_State <= STARTBITDETECTION_S;
        end if;


      when STARTBITDETECTION_S =>
        Data_nxt <= (others => '0');
        ParBit_i <= '0';
        FrameErr1_i <= '0';
        FrameErr2_i <= '0';

        RecEna_i <= BUSDRIVER_ON;       -- Bustreiber einschalten
        next_Rec_State <= STARTBITDETECTION_S;
        next_Bitcounter <= (others => '0');
        if (RxD = '0') and (old_RxD = '1') then -- Startbit empfangen!
          StartRecPulse_i <= BRG_ON;    -- Receivepulse generieren
          busy_i <= REC_BUSY;           -- working
          next_Bitcounter <= Bitcounter + '1';
          next_Rec_State <= RECEIVE_S; 
        end if;
        
      when RECEIVE_S =>
        next_Rec_State <= RECEIVE_S;
        RecEna_i <= BUSDRIVER_ON;       -- Bustreiber einschalten
        StartRecPulse_i <= BRG_ON;      -- Receivepulse generieren
        busy_i <= REC_BUSY;             -- Beschäftigt
        next_Bitcounter <= Bitcounter;        
        if rp = '1' then
--          RxD_i_nxt <= RxD;
          next_Bitcounter <= Bitcounter +1 ;
--        end if;    -
--        next_Bitcounter <= Bitcounter + '1';        
        case Bitcounter is
          when "00000" =>               -- sollte nicht auftreten!!!
            assert false
              report "Wait on first Receceive Impuls -> Recieve Startbit"
              severity NOTE;
            
          when "00001" =>               -- Startbit
            null;

          -- Daten
          when "00010" =>               -- Bit 0
            Data_nxt(0) <= RxD;
            if Length = "0000" then
              next_Bitcounter <= PARST1;
            end if;
          when "00011" =>               -- Bit 1
            Data_nxt(1) <= RxD;
            if Length = "0001" then
              next_Bitcounter <= PARST1;
            end if;
          when "00100" =>               -- Bit 2
            Data_nxt(2) <= RxD;
            if Length = "0010" then
              next_Bitcounter <= PARST1;
            end if;
          when "00101" =>               -- Bit 3
            Data_nxt(3) <= RxD;
            if Length = "0011" then
              next_Bitcounter <= PARST1;
            end if;
          when "00110" =>               -- Bit 4
            Data_nxt(4) <= RxD;
            if Length = "0100" then
              next_Bitcounter <= PARST1;
            end if;
          when "00111" =>               -- Bit 5
            Data_nxt(5) <= RxD;
            if Length = "0101" then
              next_Bitcounter <= PARST1;
            end if;
          when "01000" =>               -- Bit 6
            Data_nxt(6) <= RxD;
            if Length = "0110" then
              next_Bitcounter <= PARST1;
            end if;
          when "01001" =>               -- Bit 7
            Data_nxt(7) <= RxD;
            if Length = "0111" then
              next_Bitcounter <= PARST1;
            end if;
          when "01010" =>               -- Bit 8
            Data_nxt(8) <= RxD;
            if Length = "1000" then
              next_Bitcounter <= PARST1;
            end if;
          when "01011" =>               -- Bit 9
            Data_nxt(9) <= RxD;
            if Length = "1001" then
              next_Bitcounter <= PARST1;
            end if;
          when "01100" =>               -- Bit 10
            Data_nxt(10) <= RxD;
            if Length = "1010" then
              next_Bitcounter <= PARST1;
            end if;
          when "01101" =>               -- Bit 11
            Data_nxt(11) <= RxD;
            if Length = "1011" then
              next_Bitcounter <= PARST1;
            end if;
          when "01110" =>               -- Bit 12
            Data_nxt(12) <= RxD;
            if Length = "1100" then
              next_Bitcounter <= PARST1;
            end if;
          when "01111" =>               -- Bit 13
            Data_nxt(13) <= RxD;
            if Length = "1101" then
              next_Bitcounter <= PARST1;
            end if;
          when "10000" =>               -- Bit 14
            Data_nxt(14) <= RxD;
            if Length = "1110" then
              next_Bitcounter <= PARST1;
            end if;
          when "10001" =>               -- Bit 15
            Data_nxt(15) <= RxD;
            if Length = "1111" then
              next_Bitcounter <= PARST1;
            end if;
            
          -- Paritybit
          when PARST1 =>               -- Parity oder 1. Stopbit
            if ParEna_i = PARITY_ENABLE then
              ParBit_i <= RxD;
            else
              FrameErr1_i <= not RxD;
              if Stop2_i /= SECOND_STOPBIT then  
                next_Rec_State <= DISABLE_S; -- fertig
                RecComplete_i <= REC_COMPLETE;
                StartRecPulse_i <= not BRG_ON;
                next_Bitcounter <= (others => '0');
              end if;
            end if;

          -- Stopbits
          when ST1ST2 =>                -- 1. oder 2. Stopbit
            FrameErr2_i <= not RxD;
            if (ParEna_i /= PARITY_ENABLE) or (Stop2_i /= SECOND_STOPBIT) then
              next_Rec_State <= DISABLE_S; -- fertig
              RecComplete_i <= REC_COMPLETE;
              StartRecPulse_i <= not BRG_ON;
              next_Bitcounter <= (others => '0');
            end if;

          when ST2 =>                   -- 2. Stopbit
            FrameErr1_i <= not RxD; -- fertig
            next_Rec_State <= DISABLE_S; -- fertig
            RecComplete_i <= REC_COMPLETE;                                    
            StartRecPulse_i <= not BRG_ON;
            next_Bitcounter <= (others => '0');
                          
          when others =>                -- nicht erreicht!
            next_Rec_State <= DISABLE_S; 
            RecComplete_i <= REC_COMPLETE;                                    
            StartRecPulse_i <= not BRG_ON;
            next_Bitcounter <= (others => '0');

            assert false
              report "Bitcounter overrun (miniUART_receiver.vhd)!!!"
              severity ERROR;

        end case;
        end if;
      when others =>                    --DISABLE_S
        next_Rec_State <= DISABLE_S;
    end case;
  end process REC_STATEMACHINE;
 
  FrameErr <=        FrameErr_int;
end behaviour;



