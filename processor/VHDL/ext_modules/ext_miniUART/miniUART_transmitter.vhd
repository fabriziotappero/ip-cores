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
-- Title      : miniUART Transmitter v2
-- Module     : ext_miniUART
-- Project    : HW/SW-Codesign
-------------------------------------------------------------------------------
-- File       : miniUART_transmitter.vhd
-- Author     : Roman Seiger
-- Company    : TU Wien - Institut für Technische Informatik
-- Created    : 2005-03-07
-- Last update: 2007-05-02
-------------------------------------------------------------------------------



----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
use IEEE.std_logic_UNSIGNED.all;
--use IEEE.std_logic_UNSIGNED."-";

use work.pkg_basic.all;
use work.pkg_miniUART.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------
entity miniUART_transmitter is
  
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
  
end miniUART_transmitter;

----------------------------------------------------------------------------------
-- ARCHITECTURE
----------------------------------------------------------------------------------
architecture behaviour of miniUART_transmitter is

  -- Definition der States
  type trans_states is (START_S, DATA_S, PARITY_S, STOP_S);

  signal Trans_State : trans_states;
  signal next_Trans_State : trans_states;

  -- interne Signale zur synchronisation der Ausgänge
  signal TxD_i : std_logic;
  signal TransEna_i : std_logic;
  signal TrComp_i : std_logic;
  signal TxD_old : std_logic;
  signal TransEna_old : std_logic;
  signal TrComp_old : std_logic;

  -- interne Signale zur Zwischenspeicherung der Eingänge
  signal MsgLength_i : MsgLength_type;
  signal MsgLength_i_nxt : MsgLength_type;
  signal Stop2_i : std_logic;
  signal Stop2_i_nxt : std_logic;
  signal ParEna_i : std_logic;
  signal ParEna_i_nxt : std_logic;
  signal ParBit_i : std_logic;
  signal ParBit_i_nxt : std_logic;
  signal Data_i : Data_type;
  signal Data_nxt : Data_type;

  -- Bitzähler
  signal Bitcounter : MsgLength_type;
  signal next_Bitcounter : MsgLength_type;

  -- Stopzähler (00: 1. Stopbit; 01: 2. Stopbit oder Ende; 10: Ende)
  signal Stopcounter : std_logic_vector(1 downto 0);
  signal next_Stopcounter : std_logic_vector(1 downto 0);
  
begin  -- behaviour

  TRANS_OUTPUT : process (clk, reset)
  begin  -- process TRANS_OUTPUT
    -- Reset, setzt alles auf Standardwerte
    if reset = RST_ACT then
      TxD <= '1';
      TransEna <= not BUSDRIVER_ON;
      TrComp <= TRANS_COMP;
      TxD_old <= '1';
      TransEna_old <= not BUSDRIVER_ON;
      TrComp_old <= TRANS_COMP;

      Data_i <= (others => '1');
      MsgLength_i <= (others => '0');

      Bitcounter <= (others => '0');
      Stopcounter <= (others => '0');
      Trans_State <= START_S;

      Stop2_i <= '0';
      ParBit_i <= '0';
      ParEna_i <= '0';

    elsif (clk'event and clk = '1') then
      TxD <= TxD_old;
      TransEna <= TransEna_old;
      TrComp <= TrComp_old;

      Data_i <= Data_nxt;
      MsgLength_i <= MsgLength_i_nxt;

      Bitcounter <= Bitcounter;
      Stopcounter <= Stopcounter;
      Trans_State <= Trans_State;
      
      Stop2_i <= Stop2_i_nxt;
      ParBit_i <= ParBit_i_nxt;
      ParEna_i <= ParEna_i_nxt;

      -- Bei Transmitpulse: ausgeben, Zustandswechsel
      if tp = '1' then        
        TxD <= TxD_i;
        TransEna <= TransEna_i;
        TrComp <= TrComp_i;
        TxD_old <= TxD_i;
        TransEna_old <= TransEna_i;
        TrComp_old <= TrComp_i;

        Bitcounter <= next_Bitcounter;   -- Datenbits mitzählen
        Stopcounter <= next_Stopcounter;  -- Stopbits mitzählen

        Trans_State <= next_Trans_State;  -- Zustandswechsel
   
      end if;
    end if;
  end process TRANS_OUTPUT;  


  
  TRANS_STATEMACHINE: process (Trans_State, Bitcounter, Stopcounter,
                               MsgLength, MsgLength_i, Data, Data_i,
                               ParEna, ParEna_i, ParBit, ParBit_i,
                               Stop2, Stop2_i)
  begin  -- process TRANS_STATEMACHINE
    -- Defaultwerte (halten)
    Data_nxt <= Data_i;
    MsgLength_i_nxt <= MsgLength_i;
    ParEna_i_nxt <= ParEna_i;
    ParBit_i_nxt <= ParBit_i;
    Stop2_i_nxt <= Stop2_i;


    case Trans_State is        
      when DATA_S =>
        TrComp_i <= not TRANS_COMP;
        TransEna_i <= BUSDRIVER_ON;
        next_Bitcounter <= Bitcounter + '1';
        next_Stopcounter <= (others => '0');
          
        -- letztes Bit des Datenwortes
        if Bitcounter = MsgLength_i then     
          TxD_i <= Data_i(conv_Integer(unsigned(Bitcounter)));
          
          if ParEna_i = PARITY_ENABLE then
            next_Trans_State <= PARITY_S;
          else
            next_Trans_State <= STOP_S;
          end if;

        -- irgendeine Position im Datenwort
        else
          TxD_i <= Data_i(conv_Integer(unsigned(Bitcounter)));
          next_Trans_State <= DATA_S;
        end if;

      when PARITY_S =>
        TxD_i <= ParBit_i;
        TrComp_i <= not TRANS_COMP;
        TransEna_i <= BUSDRIVER_ON;
        next_Bitcounter <= (others => '0');
        next_Stopcounter <= (others => '0');

        next_Trans_State <= STOP_S;

      when STOP_S =>                   
        TxD_i <= '1';

        next_Bitcounter <= (others => '0');
        next_Stopcounter <= Stopcounter + '1';

        case Stopcounter is
          -- erstes Stopbit
          when "00" =>
            TrComp_i <= not TRANS_COMP;
            TransEna_i <= BUSDRIVER_ON;
            next_Trans_State <= STOP_S;

          -- zweites Stopbit oder Ende
          when "01" =>
            if Stop2_i = SECOND_STOPBIT then
              TrComp_i <= not TRANS_COMP;
              TransEna_i <= BUSDRIVER_ON;
              next_Trans_State <= STOP_S;
            else
              TrComp_i <= TRANS_COMP;
              TransEna_i <= not BUSDRIVER_ON;
              next_Trans_State <= START_S;
            end if;

          -- Ende
          when others => 
            TrComp_i <= TRANS_COMP;
            TransEna_i <= not BUSDRIVER_ON;
            next_Trans_State <= START_S;
        end case;
        
      when others =>                    -- START_S
        TxD_i <= '0';

        -- halten, erst nach Datenübernahme freigeben (DATA_S)
        TrComp_i <= TRANS_COMP;
        
        TransEna_i <= BUSDRIVER_ON;

        -- neue Daten holen
        Data_nxt <= Data;
        MsgLength_i_nxt <= MsgLength;
        ParEna_i_nxt <= ParEna;
        ParBit_i_nxt <= ParBit;
        Stop2_i_nxt <= Stop2;

        next_Bitcounter <= (others => '0');
        next_Stopcounter <= (others => '0');
        next_Trans_State <= DATA_S;
        
    end case;
  end process TRANS_STATEMACHINE;
    
end behaviour;
