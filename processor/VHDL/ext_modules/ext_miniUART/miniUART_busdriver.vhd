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
-- Title      : miniUART Busdriver
-- Module     : ext_miniUART
-- Project    : HW/SW-Codesign
-------------------------------------------------------------------------------
-- File       : miniUART_busdriver.vhd
-- Author     : Roman Seiger
-- Company    : TU Wien - Institut für Technische Informatik
-- Created    : 2005-03-08
-- Last update: 2007-05-28
-------------------------------------------------------------------------------

-- TODO: OutD Konstante!!!

----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
use work.pkg_basic.all;
use work.pkg_miniUART.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------
entity miniUART_busdriver is
  
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
  
end miniUART_busdriver;

----------------------------------------------------------------------------------
-- ARCHITECTURE
----------------------------------------------------------------------------------
architecture behaviour of miniUART_busdriver is

  signal Data_r_nxt : std_logic;
  signal Data_r_int : std_logic;
  
  -- Zwischenpuffer, um Spitzen auszugleichen
  signal buffer1, buffer1_nxt : std_logic;
  signal buffer2, buffer2_nxt : std_logic;
  signal buffer3, buffer3_nxt : std_logic;

begin  -- behaviour

  BUSDRIVER_BUFFER: process (clk, reset)
  begin  -- process BUSDRIVER_BUFFER
    if reset = RST_ACT then
      buffer1 <= '1';
      buffer2 <= '1';
      buffer3 <= '1';
      Data_r_int <= '1';
    -- Zwischenpuffer der Reihe nach füllen
    elsif (clk'event and clk = '1') then
      buffer1 <= buffer1_nxt;
      buffer2 <= buffer2_nxt;
      buffer3 <= buffer3_nxt;
      Data_r_int <= Data_r_nxt;
    end if;
  end process BUSDRIVER_BUFFER;


  BUSDRIVER_FILTER: process (RecEna, buffer1, buffer2, buffer3, Data_r_int, RxD)
  begin  -- process BUSDRIVER_FILTER
    
    Data_r_nxt <= Data_r_int;

    if RecEna /= BUSDRIVER_ON then
      buffer1_nxt <= '1';
      buffer2_nxt <= '1';
      buffer3_nxt <= '1';
      Data_r_nxt <= '1';
    else
      buffer3_nxt <= buffer2;
      buffer2_nxt <= buffer1;
      buffer1_nxt <= RxD;
     end if; 
        
    -- nur bei gleichen Bufferinhalten weitergeben!
    if (buffer3 = '1' and buffer2 = '1' and buffer1 = '1') then
      Data_r_nxt <= '1';
    elsif (buffer3 = '0' and buffer2 = '0' and buffer1 = '0') then
      Data_r_nxt <= '0';
    end if;
  end process BUSDRIVER_FILTER;


  BUSDRIVER_TRANS: process (TransEna, OutD, Data_t)
  begin  -- process BUSDRIVER_TRANS
    if (TransEna = BUSDRIVER_ON) and (OutD /= OUTD_ACT) then  -- TODO: OutD Konstante!!!
      TxD <= Data_t;
    else  -- interne Signale zur synchronisation der Ausgänge
--       TxD <= 'Z';                      -- Tri-State
       TxD <= '1';                      -- Point2Point
    end if;
  end process BUSDRIVER_TRANS;

  Data_r <= Data_r_int;

end behaviour;
