--===========================================================================--
--
--  S Y N T H E Z I A B L E    miniUART   C O R E
--
--  www.OpenCores.Org - January 2000
--  This core adheres to the GNU public license  
--
-- Design units   : miniUART core for the OCRP-1
--
-- File name      : miniuart.vhd
--
-- Purpose        : Implements an miniUART device for communication purposes 
--                  between the OR1K processor and the Host computer through
--                  an RS-232 communication protocol.
--                  
-- Library        : uart_lib.vhd
--
-- Dependencies   : IEEE.Std_Logic_1164
--
-- Simulator      : ModelSim PE/PLUS version 4.7b on a Windows95 PC
--===========================================================================--
-------------------------------------------------------------------------------
-- Revision list
-- Version   Author                 Date           Changes
--
-- 0.1      Ovidiu Lupas     15 January 2000       New model
-- 1.0      Ovidiu Lupas     January  2000         Synthesis optimizations
-- 2.0      Ovidiu Lupas     April    2000         Bugs removed - RSBusCtrl
--          the RSBusCtrl did not process all possible situations
--
--        olupas@opencores.org
-------------------------------------------------------------------------------
-- Description    : The memory consists of a dual-port memory addressed by
--                  two counters (RdCnt & WrCnt). The third counter (StatCnt)
--                  sets the status signals and keeps a track of the data flow.
-------------------------------------------------------------------------------
-- Entity for miniUART Unit - 9600 baudrate                                  --
-------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
library work;
   use work.UART_Def.all;

entity miniUART is
  port (
     SysClk   : in  Std_Logic;  -- System Clock
     Reset    : in  Std_Logic;  -- Reset input
     CS_N     : in  Std_Logic;
     RD_N     : in  Std_Logic;
     WR_N     : in  Std_Logic;
     RxD      : in  Std_Logic;
     TxD      : out Std_Logic;
     IntRx_N  : out Std_Logic;  -- Receive interrupt
     IntTx_N  : out Std_Logic;  -- Transmit interrupt
     Addr     : in  Std_Logic_Vector(1 downto 0); -- 
     DataIn   : in  Std_Logic_Vector(7 downto 0); -- 
     DataOut  : out Std_Logic_Vector(7 downto 0)); -- 
end entity; --================== End of entity ==============================--
-------------------------------------------------------------------------------
-- Architecture for miniUART Controller Unit
-------------------------------------------------------------------------------
architecture uart of miniUART is
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal RxData : Std_Logic_Vector(7 downto 0); -- 
  signal TxData : Std_Logic_Vector(7 downto 0); -- 
  signal CSReg  : Std_Logic_Vector(7 downto 0); -- Ctrl & status register
  --             CSReg detailed 
  -----------+--------+--------+--------+--------+--------+--------+--------+
  -- CSReg(7)|CSReg(6)|CSReg(5)|CSReg(4)|CSReg(3)|CSReg(2)|CSReg(1)|CSReg(0)|
  --   Res   |  Res   |  Res   |  Res   | UndRun | OvrRun |  FErr  |  OErr  |
  -----------+--------+--------+--------+--------+--------+--------+--------+
  signal EnabRx : Std_Logic;  -- Enable RX unit
  signal EnabTx : Std_Logic;  -- Enable TX unit
  signal DRdy   : Std_Logic;  -- Receive Data ready
  signal TRegE  : Std_Logic;  -- Transmit register empty
  signal TBufE  : Std_Logic;  -- Transmit buffer empty
  signal FErr   : Std_Logic;  -- Frame error
  signal OErr   : Std_Logic;  -- Output error
  signal Read   : Std_Logic;  -- Read receive buffer
  signal Load   : Std_Logic;  -- Load transmit buffer
  -----------------------------------------------------------------------------
  -- Baud rate Generator
  -----------------------------------------------------------------------------
  component ClkUnit is
   port (
     SysClk   : in  Std_Logic;  -- System Clock
     EnableRX : out Std_Logic;  -- Control signal
     EnableTX : out Std_Logic;  -- Control signal
     Reset    : in  Std_Logic); -- Reset input
  end component;
  -----------------------------------------------------------------------------
  -- Receive Unit
  -----------------------------------------------------------------------------
  component RxUnit is
  port (
     Clk    : in  Std_Logic;  -- Clock signal
     Reset  : in  Std_Logic;  -- Reset input
     Enable : in  Std_Logic;  -- Enable input
     RxD    : in  Std_Logic;  -- RS-232 data input
     RD     : in  Std_Logic;  -- Read data signal
     FErr   : out Std_Logic;  -- Status signal
     OErr   : out Std_Logic;  -- Status signal
     DRdy   : out Std_Logic;  -- Status signal
     DataIn : out Std_Logic_Vector(7 downto 0));
  end component;
  -----------------------------------------------------------------------------
  -- Transmitter Unit
  -----------------------------------------------------------------------------
  component TxUnit is
  port (
     Clk    : in  Std_Logic;  -- Clock signal
     Reset  : in  Std_Logic;  -- Reset input
     Enable : in  Std_Logic;  -- Enable input
     Load   : in  Std_Logic;  -- Load transmit data
     TxD    : out Std_Logic;  -- RS-232 data output
     TRegE  : out Std_Logic;  -- Tx register empty
     TBufE  : out Std_Logic;  -- Tx buffer empty
     DataO  : in  Std_Logic_Vector(7 downto 0));
  end component;
begin
  -----------------------------------------------------------------------------
  -- Instantiation of internal components
  -----------------------------------------------------------------------------
  ClkDiv  : ClkUnit port map (SysClk,EnabRX,EnabTX,Reset); 
  TxDev   : TxUnit port map (SysClk,Reset,EnabTX,Load,TxD,TRegE,TBufE,TxData);
  RxDev   : RxUnit port map (SysClk,Reset,EnabRX,RxD,Read,FErr,OErr,DRdy,RxData);
  -----------------------------------------------------------------------------
  -- Implements the controller for Rx&Tx units
  -----------------------------------------------------------------------------
  RSBusCtrl : process(SysClk,Reset,Read,Load)
     variable StatM : Std_Logic_Vector(4 downto 0);
  begin
     if Rising_Edge(SysClk) then
        if Reset = '0' then
           StatM := "00000";
           IntTx_N <= '1';
           IntRx_N <= '1';
           CSReg <= "11110000";
        else
           StatM(0) := DRdy;
           StatM(1) := FErr;
           StatM(2) := OErr;
           StatM(3) := TBufE;
           StatM(4) := TRegE;
        end if;
        case StatM is
             when "00001" =>
                  IntRx_N <= '0';
                  CSReg(2) <= '1';
             when "10001" =>
                  IntRx_N <= '0';
                  CSReg(2) <= '1';
             when "01000" =>
                  IntTx_N <= '0';
             when "11000" =>
                  IntTx_N <= '0';
                  CSReg(3) <= '1';
             when others => null;
        end case;

        if Read = '1' then
           CSReg(2) <= '0';
           IntRx_N <= '1';
        end if;

        if Load = '1' then
           CSReg(3) <= '0';
           IntTx_N <= '1';
        end if;
     end if;
  end process;
  -----------------------------------------------------------------------------
  -- Combinational section
  -----------------------------------------------------------------------------
  process(SysClk)
  begin
     if (CS_N = '0' and RD_N = '0') then
        Read <= '1';
     else Read <= '0';
     end if;
  
     if (CS_N = '0' and WR_N = '0') then
        Load <= '1';
     else Load <= '0';
     end if;

     if Read = '0' then
        DataOut <= "ZZZZZZZZ";
     elsif (Read = '1' and Addr = "00") then
        DataOut <= RxData;
     elsif (Read = '1' and Addr = "01") then
        DataOut <= CSReg;
     end if;

     if Load = '0' then
        TxData <= "ZZZZZZZZ";
     elsif (Load = '1' and Addr = "00") then
        TxData <= DataIn;
     end if;
  end process;
end uart; --===================== End of architecture =======================--