--===========================================================================--
--
--  S Y N T H E Z I A B L E    miniUART   C O R E
--
--  www.OpenCores.Org - January 2000
--  This core adheres to the GNU public license  

-- Design units   : miniUART core for the OCRP-1
--
-- File name      : clkUnit.vhd
--
-- Purpose        : Implements an miniUART device for communication purposes 
--                  between the OR1K processor and the Host computer through
--                  an RS-232 communication protocol.
--                  
-- Library        : uart_lib.vhd
--
-- Dependencies   : IEEE.Std_Logic_1164
--
--===========================================================================--
-------------------------------------------------------------------------------
-- Revision list
-- Version   Author              Date                Changes
--
-- 1.0     Ovidiu Lupas      15 January 2000         New model
-- 1.1     Ovidiu Lupas      28 May 2000     EnableRx/EnableTx ratio corrected
--      olupas@opencores.org
-------------------------------------------------------------------------------
-- Description    : Generates the Baud clock and enable signals for RX & TX
--                  units. 
-------------------------------------------------------------------------------
-- Entity for Baud rate generator Unit - 9600 baudrate                       --
-------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
library work;
   use work.UART_Def.all;
-------------------------------------------------------------------------------
-- Baud rate generator
-------------------------------------------------------------------------------
entity ClkUnit is
  port (
     SysClk   : in  Std_Logic;  -- System Clock
     EnableRx : out Std_Logic;  -- Control signal
     EnableTx : out Std_Logic;  -- Control signal
     Reset    : in  Std_Logic); -- Reset input
end entity; --================== End of entity ==============================--
-------------------------------------------------------------------------------
-- Architecture for Baud rate generator Unit
-------------------------------------------------------------------------------
architecture Behaviour of ClkUnit is
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal ClkDiv26  : Std_Logic;
  signal tmpEnRX   : Std_Logic;
  signal tmpEnTX   : Std_Logic;
begin
  -----------------------------------------------------------------------------
  -- Divides the system clock of 40 MHz by 26
  -----------------------------------------------------------------------------
  DivClk26 : process(SysClk,Reset)
     constant CntOne : unsigned(4 downto 0) := "00001";
     variable Cnt26  : unsigned(4 downto 0);
  begin
     if Rising_Edge(SysClk) then
        if Reset = '0' then
           Cnt26 := "00000";
           ClkDiv26 <= '0';
        else
           Cnt26 := Cnt26 + CntOne;
           case Cnt26 is
              when "11010" =>
                  ClkDiv26 <= '1';
                  Cnt26 := "00000";
              when others =>
                  ClkDiv26 <= '0';
           end case;
        end if;
     end if;
  end process;
  -----------------------------------------------------------------------------
  -- Provides the EnableRX signal, at ~ 155 KHz
  -----------------------------------------------------------------------------
  DivClk10 : process(SysClk,Reset,Clkdiv26)
     constant CntOne : unsigned(3 downto 0) := "0001";
     variable Cnt10  : unsigned(3 downto 0);
  begin
     if Rising_Edge(SysClk) then
        if Reset = '0' then
           Cnt10 := "0000";
           tmpEnRX <= '0';
        elsif ClkDiv26 = '1' then
           Cnt10 := Cnt10 + CntOne;
        end if;
        case Cnt10 is
             when "1010" =>
                tmpEnRX <= '1';
                Cnt10 := "0000";
             when others =>
                tmpEnRX <= '0';
        end case;
     end if;
  end process;
  -----------------------------------------------------------------------------
  -- Provides the EnableTX signal, at 9.6 KHz
  -----------------------------------------------------------------------------
  DivClk16 : process(SysClk,Reset,tmpEnRX)
     constant CntOne : unsigned(4 downto 0) := "00001";
     variable Cnt16  : unsigned(4 downto 0);
  begin
     if Rising_Edge(SysClk) then
        if Reset = '0' then
           Cnt16 := "00000";
           tmpEnTX <= '0';
        elsif tmpEnRX = '1' then
           Cnt16 := Cnt16 + CntOne;
        end if;
        case Cnt16 is
           when "01111" =>
                tmpEnTX <= '1';
                Cnt16 := Cnt16 + CntOne;
           when "10001" =>
                Cnt16 := "00000";
                tmpEnTX <= '0';
           when others =>
                tmpEnTX <= '0';
        end case;
     end if;
  end process;

  EnableRX <= tmpEnRX;
  EnableTX <= tmpEnTX;
end Behaviour; --==================== End of architecture ===================--