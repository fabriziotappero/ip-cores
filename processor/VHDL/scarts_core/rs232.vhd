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
-- Last update: 2011-03-16
-------------------------------------------------------------------------------

-- TODO: Herstellernummer

----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------

ENTITY ext_miniUART IS
 	PORT(   ---------------------------------------------------------------
                -- Generic Ports
                ---------------------------------------------------------------
                clk           : IN  std_logic; 	
                extsel        : in  std_logic;
                exti          : in  module_in_type;
                exto          : out module_out_type;
                ---------------------------------------------------------------
                -- Module Specific Ports
                ---------------------------------------------------------------
                RxD           : IN std_logic;  -- Empfangsleitung
                TxD           : OUT std_logic 
                );
END ext_miniUART;


----------------------------------------------------------------------------------
-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE behaviour OF ext_miniUART IS
  
------------------------------------------------------------------------------
-- Definition der Constanten für Module Type und versionsnummer
-------------------------------------------------------------------------------
-- ID für miniUART definieren
  constant MOD_TYPE     : std_logic_vector(15 downto 0):="0000000100000001";
  constant MOD_VERSION  : std_logic_vector(15 downto 0):="0000000000000000";

  
-------------------------------------------------------------------------------
-- Definieren eines Types "ext_register_set" : Array vom 8 Registern die
-- jeweils 16 Bit breit sind => Register der Module Interfaces
-------------------------------------------------------------------------------  
  subtype ext_register is std_logic_vector(7 downto 0);
  type    ext_register_set is array (0 to 9) of ext_register;
  signal  ExtReg,ExtReg_next         : ext_register_set;

-------------------------------------------------------------------------------
--  Interne Signale, siehe Programm-Code 
-------------------------------------------------------------------------------    
  signal ExtReset                        : std_logic;  -- reset oder SRes
--  signal Ena                             : std_logic;  -- Modul angesprochen
  signal IntAckClrNxt                    : std_logic;
  --signal WriteDataNxt                    : std_logic_vector(DATA_W-1 downto 0);
  -- ganzes Statusregister überschreiben!
--  signal StatusNxt                       : std_logic_vector((DATA_W/2)-1 downto 0);
  signal StatusNxt                       : std_logic_vector(DATA_W-1 downto 0);
--  signal MsgNxt                          : std_logic_vector(DATA_W-1 downto 0);
--  signal CmdNxt                          : std_logic_vector(DATA_W-1 downto 0);
  signal UBRS                            : std_logic_vector(DATA_W-1 downto 0);
  
--  signal parity : std_logic;            -- für Parityberechnung
  signal newmessage : std_logic;        -- neue Nachricht ins Messageregister geschrieben?
  signal messageread : std_logic;       -- empfangene Nachricht abgeholt?
  signal statusread : std_logic;        -- Status gelesen? (für Eventflag)
  signal old_statusread : std_logic;

  --signal MINIUART_BADDR                  : std_logic_vector(DATA_W-1 downto 3);
  
-------------------------------------------------------------------------------
-- Verbindungssignale
-------------------------------------------------------------------------------
  -- Transmitter
  signal ParBit : std_logic;            -- berechnetes Paritybit für Transmitter

  -- Busdriver
  signal OutD : std_logic;              -- Output disable
  
  -- UARTCtrl
  signal ParErr : std_logic;          -- Parity Error
  signal FrameErr : std_logic;        -- Frame Error (Transmission Error)
  signal Data_r : Data_type;            -- empfangene Daten
  signal RBR : std_logic;               -- Receive Buffer Ready
  signal TBR : std_logic;               -- Transmit Buffer Ready
  signal event : std_logic;             -- event occured?

  -- UARTCtrl <=> receiver
  signal Data_r2c : Data_type;  
  signal Data_c2t : Data_type;
  signal ParBit_r2c : std_logic;
  signal FrameErr_r2c : std_logic;
  signal RecComp_r2c : std_logic;
  signal RecBusy_r2c : std_logic;
  signal EnaRec_c2r : std_logic;

  -- UARTCtrl <=> transmitter
  signal TransComp_t2c : std_logic;

  -- UARTcontrol <=> BRG
  signal StartTrans_c2brg : std_logic;
  
  -- transmitter <=> BRG
  signal tp_brg2t : std_logic;

  -- transmitter <=> busdriver
  signal TransEna_t2bd : std_logic;
  signal TxD_t2bd : std_logic;

  -- receiver <=> BRG
  signal rp_brg2r : std_logic;
  signal StartRecPulse_r2brg : std_logic;
  
  -- receiver <=> busdriver
  signal RecEna_r2bd : std_logic;
  signal RxD_bd2r : std_logic;
  
-------------------------------------------------------------------------------
-- begin architecture
-------------------------------------------------------------------------------
  begin  -- behaviour

-------------------------------------------------------------------------------
-- Port mapping der Komponenten
-------------------------------------------------------------------------------
    -- miniUART_control
    miniUART_control_unit : miniUART_control
      port map (
        clk => clk,
        reset => ExtReset,
        ParEna => ExtReg(EXTUARTCONF)(EXTCONF_PARENA),
        Odd => ExtReg(EXTUARTCONF)(EXTCONF_PARODD),
        AsA => ExtReg(EXTCMD)(EXTCMD_ASA_H downto EXTCMD_ASA_L),
        EvS => ExtReg(EXTCMD)(EXTCMD_EVS_H downto EXTCMD_EVS_L),
        Data_r => Data_r2c,
        ParBit_r => ParBit_r2c,
        FrameErr => FrameErr_r2c,
        RecComp => RecComp_r2c,
        RecBusy => RecBusy_r2c,
        TransComp => TransComp_t2c,
        EnaRec => EnaRec_c2r,
        Data_r_out => Data_r,
        FrameErr_out => FrameErr,
        ParityErr => ParErr,
        RBR => RBR,
        StartTrans => StartTrans_c2brg,
        TBR => TBR,
        event => event
        );
	
		Data_c2t(7 downto 0) <= ExtReg(MSGREG_LOW);
		Data_c2t(15 downto 8) <= ExtReg(MSGREG_HIGH);

    -- miniUART_transmitter
    miniUART_transmitter_unit : miniUART_transmitter
      port map (
        clk => clk,
        reset => ExtReset,
        MsgLength => ExtReg(EXTUARTCONF)(EXTCONF_MSGL_H downto EXTCONF_MSGL_L),
        Stop2 => ExtReg(EXTUARTCONF)(EXTCONF_STOP),
        ParEna => ExtReg(EXTUARTCONF)(EXTCONF_PARENA),
        ParBit => ParBit,
        Data => Data_c2t,
        tp => tp_brg2t,
        TransEna => TransEna_t2bd,
        TrComp => TransComp_t2c,
        TxD => TxD_t2bd
        );

    -- miniUART_receiver
    miniUART_receiver_unit : miniUART_receiver
      port map (
        clk => clk,
		reset => ExtReset,
        enable => EnaRec_c2r,
        MsgLength => ExtReg(EXTUARTCONF)(EXTCONF_MSGL_H downto EXTCONF_MSGL_L),
        Stop2 => ExtReg(EXTUARTCONF)(EXTCONF_STOP),
        ParEna => ExtReg(EXTUARTCONF)(EXTCONF_PARENA),
        rp => rp_brg2r,
        RxD => RxD_bd2r,
        Data => Data_r2c,
        ParBit => ParBit_r2c,
        RecEna => RecEna_r2bd,
        StartRecPulse => StartRecPulse_r2brg,
        busy => RecBusy_r2c,
        RecComplete => RecComp_r2c,
        FrameErr => FrameErr_r2c
        );

     UBRS(7 downto 0)  <= ExtReg(UBRSREG_LOW);
     UBRS(15 downto 8) <= ExtReg(UBRSREG_HIGH);

    -- miniUART_BRG
    miniUART_BRG_unit : miniUART_BRG
      port map (
        clk => clk, 
		reset => ExtReset,
        StartTrans => StartTrans_c2brg,
        StartRec => StartRecPulse_r2brg,
        UBRS => UBRS,--ExtReg(UBRSREG),
        tp => tp_brg2t,
        rp => rp_brg2r
        );

    
    -- miniUART_busdriver
    miniUART_busdriver_unit : miniUART_busdriver
      port map (
        clk => clk, 
		reset => ExtReset,
        OutD => OutD,
        TransEna => TransEna_t2bd,
        RecEna => RecEna_r2bd,
        Data_t => TxD_t2bd,
        Data_r => RxD_bd2r,
        TxD => TxD,
        RxD => RxD
        );
    

-------------------------------------------------------------------------------
-- Synchroner Prozess:
-- Bei einem Reset werden alle Register mit Null initialisiert.
-- Anschliessend werden mit jeder steigenden Flanke die neuen Werte in das
-- Register geschrieben.
-- Zu beachten ist dabei die Reigenfolge: StatusNxt wird
-- als letztes zugewiesen - daher wird in jedem Fall das Status Register mit
-- diesem Wert beschreiben, auch wenn man von aussen versucht  dieses zu
-- überschreiben  -> read-only Funktion  (nur die unteren 8 Bits). Beim
-- Config-Register ist es genau umgekehrt - dadurch kann man das INTA-Bit vom
-- Prozessor aus überschreiben..
-------------------------------------------------------------------------------        
    SYNC_SM: process (clk, ExtReset)
    begin  

      if ExtReset = RST_ACT then
        for i in 0 to 9 loop
          ExtReg(i) <= (others => '0');
        end loop;  -- i
        old_statusread <= '0';
      elsif clk'event and clk = '1' then    
        ExtReg <= ExtReg_next;
        
        ExtReg(STATUSREG) <= StatusNxt(7 downto 0);
        ExtReg(STATUSREG_CUST) <= StatusNxt(15 downto 8);
        old_statusread <= statusread;

      end if;
    end process SYNC_SM;


    
    
-------------------------------------------------------------------------------
-- Schreiben in die Register:
-- Defaultmässig wird der ältere Wert beibehalten
------------------------------------------------------------------------------- 
    WRITE_REG: process (exti, ExtReg, RBR, TBR,  Data_r, extsel, IntAckClrNxt)--(ExtAddr, Data2Ext, ExtWr, Ena, ExtReg) --DE, AccViol)
    begin

      -- Defaultwert
      ExtReg_next <= ExtReg;
      ExtReg_next(CONFIGREG)(CONF_INTA)  <= IntAckClrNxt;      
      --WriteDataNxt <=  ExtReg(conv_integer(unsigned(exti.ExtAddr)));
      newmessage <= '0';
      if RBR = RB_READY then
        ExtReg_next(MSGREG_LOW)   <= Data_r(7 downto 0);       -- empfangene Nachricht übernehmen
        ExtReg_next(MSGREG_HIGH) <= Data_r(15 downto 8);
      end if;

      if TBR = TB_READY then
        if ExtReg(EXTCMD)(EXTCMD_ASA_H downto EXTCMD_ASA_L) = ASA_STRANS then
             ExtReg_next(EXTCMD)(EXTCMD_ASA_H downto EXTCMD_ASA_L) <= "000"; 
        end if;
      end if;
      
      
      -- neue Daten übernehmen
      if ((extsel = '1') and (exti.write_en = '1')) then
        case exti.addr(4 downto 2) is
          when "000" =>
            if ((exti.byte_en(0) = '1')) then
              ExtReg_next(2) <= exti.data(7 downto 0);
            end if;
            if ((exti.byte_en(1) = '1')) then
              ExtReg_next(3) <= exti.data(15 downto 8);
            end if;
            if ((exti.byte_en(2) = '1')) then
              ExtReg_next(2) <= exti.data(23 downto 16);
            end if;
            if ((exti.byte_en(3) = '1')) then
              ExtReg_next(3) <= exti.data(31 downto 24);
            end if;
          when "001" =>
            if ((exti.byte_en(0) = '1')) then
              ExtReg_next(4) <= exti.data(7 downto 0);
            end if;
            if ((exti.byte_en(1) = '1')) then
              ExtReg_next(5) <= exti.data(15 downto 8);
            end if;
            if ((exti.byte_en(2) = '1')) then
              ExtReg_next(6) <= exti.data(23 downto 16);
              newmessage <= '1';
            end if;
            if ((exti.byte_en(3) = '1')) then
              ExtReg_next(7) <= exti.data(31 downto 24);
            end if;
          when "010" =>
            if ((exti.byte_en(0) = '1')) then
              ExtReg_next(8) <= exti.data(7 downto 0);
            end if;
            if ((exti.byte_en(1) = '1')) then
              ExtReg_next(9) <= exti.data(15 downto 8);
            end if;
          when others =>
            null;
        end case;
      end if;
    end process WRITE_REG;

-------------------------------------------------------------------------------
-- Lesezugriff auf das Extension Module
-- Wenn das ID-Bit im Config Register gesetzt ist, so wird auf Data 0/1 der
-- Module Type und die Versionsnummer ausgegeben
-- Bei einem Interrupt wird auf DATA0 der Interruptvector ausgegeben
-------------------------------------------------------------------------------
    READ_REG: process (exti, ExtReg, extsel) --DE AccViol)
    begin
      --Defaultwert (Hochohmig)-> neue Konvention, Default auf 0
--      WrBData <= (others => 'Z');
      exto.data <= (others => '0');

      messageread <= '0';
      statusread <= '0';

      -- Lesezugriff auf das Module? (ohne Access Violation (AccViol))
      if ((extsel = '1') and (exti.write_en = '0')) then
        case exti.addr(4 downto 2) is
          when "000" =>
              if ((exti.byte_en(0) = '1')) then
                statusread <= '1';
              end if;
            exto.data<= ExtReg(3) & ExtReg(2) & ExtReg(1) & ExtReg(0);
          when "001" =>
            if (ExtReg(CONFIGREG)(CONF_ID) = '1') then
              exto.data<= MODULE_VER & MODULE_ID;
            else
              if ((exti.byte_en(2) = '1')) then
                messageread <= '1';
              end if;
              exto.data<= ExtReg(7) & ExtReg(6) & ExtReg(5) & ExtReg(4);
            end if;
          when "010" =>
            exto.data<= "00000000" & "00000000" & ExtReg(9) & ExtReg(8);
          when others =>
            null;
        end case;
      end if;
    end process READ_REG;


-------------------------------------------------------------------------------
-- Setzen der Status-Bits
-------------------------------------------------------------------------------    
    STATUS_EXT: process(ExtReg, RBR, TBR, ParErr, FrameErr, --Data_r,
                        newmessage, messageread, statusread, event, old_statusread)
    begin
      -- Defaultwerte
     -- MsgNxt(7 downto 0) <= ExtReg(MSGREG_LOW);   
	--  MsgNxt(15 downto 8) <= ExtReg(MSGREG_HIGH);
    --  CmdNxt(7 downto 0) <= ExtReg(EXTCMD);
  --    CmdNxt(15 downto 8) <= (others =>'0');

      StatusNxt(STA_LOOR) <= ExtReg(CONFIGREG)(CONF_LOOW);
      StatusNxt(STA_FSS)  <= ExtReg(STATUSREG)(STA_FSS);      -- Failsafestate
      StatusNxt(STA_RESH) <= '0';                               --not used
      StatusNxt(STA_RESL) <= '0';                               --not used
      StatusNxt(STA_BUSY) <= '0';      -- miniUART is never too busy!
      StatusNxt(STA_ERR)  <= ExtReg(STATUSREG)(STA_ERR);  -- Error occured
      StatusNxt(STA_RDY)  <= '1';                               --not used
      StatusNxt(STA_INT)  <= ExtReg(STATUSREG)(STA_INT); 
      IntAckClrNxt         <= ExtReg(CONFIGREG)(CONF_INTA);

      StatusNxt(15)          <= '0';    -- not used
      StatusNxt(STA_TRANSERR +8) <= ExtReg(STATUSREG_CUST)(STA_TRANSERR); -- Transmission Error (Frame Error)
      StatusNxt(STA_PARERR+8)   <= ExtReg(STATUSREG_CUST)(STA_PARERR); -- Parity Error
      StatusNxt(STA_EVF+8)      <= ExtReg(STATUSREG_CUST)(STA_EVF);    -- EventFlag
      StatusNxt(STA_OVF+8)      <= ExtReg(STATUSREG_CUST)(STA_OVF);    -- OverflowFlag
      StatusNxt(STA_RBR+8)      <= ExtReg(STATUSREG_CUST)(STA_RBR);     -- Receive Buffer Ready
      StatusNxt(STA_TBR+8)      <= ExtReg(STATUSREG_CUST)(STA_TBR);    -- Transmit Buffer Ready
      StatusNxt(8)           <= '0';    -- not used
      
      -- Nachricht empfangen
      if RBR = RB_READY then
        StatusNxt(STA_RBR+8) <= RB_READY;
        -- Overflow?
        if ExtReg(STATUSREG_CUST)(STA_RBR) = RB_READY then
          StatusNxt(STA_OVF) <= OVERFLOW;
        end if;
        -- übernehmen
   --     MsgNxt <= Data_r;
        -- Parity bzw. Transmission (Frame) Error (nur wenn TrCtrl oder ERRI)
        if (ExtReg(EXTUARTCONF)(EXTCONF_TRCTRL) = TRCTRL_ENA) or (ExtReg(EXTCMD)(EXTCMD_ERRI) = TRCTRL_ENA) then
          StatusNxt(STA_PARERR+8) <= ParErr;
          StatusNxt(STA_TRANSERR +8) <= FrameErr;
          if (ParErr = PARITY_ERROR) or (FrameErr = FRAME_ERROR) then
            StatusNxt(STA_ERR) <= '1';
          end if;
          -- Interrupt auslösen?
          if (ExtReg(EXTCMD)(EXTCMD_ERRI) = TRCTRL_ENA) and ((ParErr = PARITY_ERROR) or (FrameErr = FRAME_ERROR)) then
            StatusNxt(STA_INT) <= '1';
            IntAckClrNxt <= '0';            
          end if;
        end if;
      elsif messageread = '1' then
        -- clear receive flags
        StatusNxt(STA_RBR+8) <= not RB_READY;
        StatusNxt(STA_OVF+8) <= not OVERFLOW;
        StatusNxt(STA_PARERR+8) <= not PARITY_ERROR;
        StatusNxt(STA_TRANSERR+8) <= not FRAME_ERROR;
        StatusNxt(STA_ERR) <= '0';
      end if;

      -- Nachricht wird gesendet, TBR für eine Taktperiode auf high => signal
-- ist irreführend, es zeigt legilich an, dass mit dem Senden der Nachricht
-- begonnen wurde, nicht dass sie erfolgreich übertragen wurde. 
      if TBR = TB_READY then
        StatusNxt(STA_TBR+8) <= TB_READY;
        -- erneutes Senden verhindern!
       -- if ExtReg(EXTCMD)(EXTCMD_ASA_H downto EXTCMD_ASA_L) = ASA_STRANS then
       --   CmdNxt(EXTCMD_ASA_H downto EXTCMD_ASA_L) <= "000"; 
       -- end if;
      elsif newmessage = '1' then
        -- clear TBR
        StatusNxt(STA_TBR+8) <= not TB_READY;        
      end if;

      -- Event
      if event = EV_OCC then
        StatusNxt(STA_EVF+8) <= EV_OCC;
        -- Interrupt auslösen
        if ExtReg(EXTCMD)(EXTCMD_EI) = EV_INT then
          StatusNxt(STA_INT) <= '1';
          IntAckClrNxt <= '0';                      
        end if;
      elsif (old_statusread = '1') and (statusread = '0') then
        StatusNxt(STA_EVF+8) <= not EV_OCC;
      end if;

      -- Failsafestate
      if ExtReg(CONFIGREG)(CONF_EFSS) = FAILSAFE then
        StatusNxt(STA_FSS) <= '1';
        StatusNxt(STA_INT) <= '1';
        IntAckClrNxt <= '0';
      else
        StatusNxt(STA_FSS) <= '0';       
      end if;
      
      -- Interruptstatus (bei Acknowledge abdrehen)
      if ExtReg(CONFIGREG)(CONF_INTA) = '1' then
        StatusNxt(STA_INT)  <= '0';
        IntAckClrNxt        <= '0';
      end if;
      
    end process STATUS_EXT;


-------------------------------------------------------------------------------
-- Ein Reset kann durch ein externes Signal oder durch setzen eines Bits im
-- Config-Register ausgelöst werden.
-------------------------------------------------------------------------------
    RESET_EXT: process (exti, ExtReg)
    begin
      -- Defaultwert
      ExtReset <= not RST_ACT;
      if exti.reset = RST_ACT or ExtReg(CONFIGREG)(CONF_SRES)= '1' then
        ExtReset <= RST_ACT;
      end if;
    end process RESET_EXT;
 


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Module Specific Part
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
    
-------------------------------------------------------------------------------
-- Parity berechnen
-------------------------------------------------------------------------------    
    PARITY_CALC: process (ExtReg)
--      variable i : integer;
      variable parity : std_logic;
    begin  -- process PARITY_CALC
      parity := '0';
      for i in 15 downto 0 loop
        if to_integer(unsigned(ExtReg(EXTUARTCONF)(EXTCONF_MSGL_H downto EXTCONF_MSGL_L))) < i then
          parity := parity;
        else
		  if i < 8 then
          	parity := parity xor ExtReg(MSGREG_LOW)(i);
		  else  	
			parity := parity xor ExtReg(MSGREG_HIGH)(i-8);
          end if;
		end if;
      end loop;

      -- Odd oder even?
      ParBit <= parity xor ExtReg(EXTUARTCONF)(EXTCONF_PARODD);    
    end process PARITY_CALC;

-------------------------------------------------------------------------------
-- Output disable (explizit oder im FSS)
-------------------------------------------------------------------------------    
    OUTPUT_CONTROL: process (ExtReg)
    begin  -- process FSS_CONTROL
      if (ExtReg(STATUSREG)(STA_FSS) = '1') or (ExtReg(CONFIGREG)(EXTCONF_OUTD) = OUTD_ACT) then
        OutD <= OUTD_ACT;
      else
        OutD <= not OUTD_ACT;
      end if;
    end process OUTPUT_CONTROL;

    
-------------------------------------------------------------------------------
-- Interrupt request
-------------------------------------------------------------------------------    

   INT_CONTROL: process (ExtReg)
   begin  -- process INT_CONTROL
     if ExtReg(STATUSREG)(STA_INT) = '1' then
       exto.intreq <= '1';--EXC_ACT;
     else
       exto.intreq <= '0';--not EXC_ACT;
     end if;
   end process INT_CONTROL;
  
end behaviour;

----------------------------------------------------------------------------------
-- END ARCHITECTURE
----------------------------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
use IEEE.std_logic_UNSIGNED.all;

use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------
entity miniUART_BRG is
  
  port (
    clk : in std_logic;
    reset : in std_logic;
    StartTrans : in std_logic;          -- Transmitterpulse eingeschaltet?
    StartRec : in std_logic;            -- Receiverpulse eingeschaltet?
    UBRS : in std_logic_vector(15 downto 0);  -- Baud Rate Selection Register 
                                              -- (12 bit ganzzahlig, 4 bit fraction)
    
    tp : out std_logic;                 -- Transmitterpulse
    rp : out std_logic                  -- Receiverpulse
    );
  
end miniUART_BRG;

----------------------------------------------------------------------------------
-- ARCHITECTURE
----------------------------------------------------------------------------------
architecture behaviour of miniUART_BRG is
  
  -- Zählerbreite (11bit aus UBRS + 1bit Überlaufschutz)
  constant COUNTERWIDTH : integer := 12;
  -- Zählerkonstanten
  constant COUNTER_ZERO : std_logic_vector(COUNTERWIDTH-1 downto 0) := (0 => '1', others => '0');
  -- Überlaufregisterbreite (4bit aus UBRS + 1bit Überlauf)
  constant OVERFLOWWIDTH : integer := 6;

  
  -- interne Signale zur Zwischenspeicherung der Eingänge
  signal UBRS_i, UBRS_nxt : std_logic_vector(16 downto 0);
  
  -- Zähler
  signal counter : std_logic_vector(COUNTERWIDTH-1 downto 0);
  signal next_counter : std_logic_vector(COUNTERWIDTH-1 downto 0);

  -- Überlaufregister
  signal overflow : std_logic_vector(OVERFLOWWIDTH-1 downto 0);
  signal next_overflow : std_logic_vector(OVERFLOWWIDTH-1 downto 0);

  -- Transmitpulse oder Receivepulse?
  signal pulse_toggle : std_logic;
  signal next_pulse_toggle : std_logic;
  
begin  -- behaviour

  BRG_COUNTER: process (clk, reset)
  begin  -- process BRG_COUNTER
    
    -- ausgeschaltet, entspricht reset
    if reset = RST_ACT then
      counter <= COUNTER_ZERO;
      overflow(4 downto 0) <= (others => '0');-- UBRS(4 downto 0);
      overflow(OVERFLOWWIDTH-1) <= '0';
      UBRS_i(16) <= '0';
      UBRS_i(15 downto 0) <= (others => '1'); --UBRS;          -- UBRS übernehmen
      pulse_toggle <= '0';              -- Transmitter zuerst!
      -- in Betrieb, runterzählen
    elsif (clk'event and clk = '1') then
      counter <= next_counter;
      overflow <= next_overflow;
      UBRS_i <= UBRS_nxt;
      pulse_toggle <= next_pulse_toggle;
    end if;
  end process BRG_COUNTER;


  BRG_CALC_NEXT: process (counter, overflow, UBRS_i, UBRS, StartTrans,
                          StartRec, pulse_toggle)
  begin  -- process BRG_CALC_NEXT
    -- Defaultwerte

    tp <= '0';
    rp <= '0';
    UBRS_nxt <= UBRS_i;
     -- counter weiterzählen
    next_counter <= counter - '1';
    next_overflow <= overflow;
    -- pulse_toggle halten
    next_pulse_toggle <= pulse_toggle;

    if (StartTrans /= BRG_ON) and (StartRec /= BRG_ON) then
      next_counter <= COUNTER_ZERO;
      next_overflow(4 downto 0) <= UBRS(4 downto 0);
      next_overflow(OVERFLOWWIDTH-1) <= '0';
      next_pulse_toggle <= '0';
      UBRS_nxt(16) <= '0';
      UBRS_nxt(15 downto 0) <= UBRS; 
 -- counter zurücksetzen, neues overflow berechnen
    elsif counter = COUNTER_ZERO then
      next_counter <= UBRS_i(16 downto 5) + overflow(5);
      next_overflow <= (overflow and "011111") + UBRS_i(4 downto 0);
      -- Pulses ausgeben
      tp <= (not pulse_toggle) and StartTrans;
      rp <= pulse_toggle and StartRec;
      next_pulse_toggle <= not pulse_toggle;
    end if;
    
  end process BRG_CALC_NEXT;

end behaviour;




----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

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




----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;

use work.scarts_core_pkg.all;
USE work.scarts_pkg.all;

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







----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
use IEEE.std_logic_UNSIGNED."+";
use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

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



----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
use IEEE.std_logic_UNSIGNED.all;
--use IEEE.std_logic_UNSIGNED."-";

use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

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
