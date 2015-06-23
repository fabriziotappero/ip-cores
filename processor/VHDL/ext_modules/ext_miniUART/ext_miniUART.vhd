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
-- Last update: 2007-05-17
-------------------------------------------------------------------------------

-- TODO: Herstellernummer

----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.pkg_basic.all;
use work.pkg_miniUART.all;

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
