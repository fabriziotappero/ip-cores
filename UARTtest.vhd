--============================================================================--
-- Design units   : TestBench for miniUART device. 
--
-- File name      : UARTTest.vhd
--
-- Purpose        : Implements the test bench for miniUART device.
--
-- Library        : uart_Lib.vhd
--
-- Dependencies   : IEEE.Std_Logic_1164
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Revision list
-- Version   Author             Date          Changes
--
-- 0.1      Ovidiu Lupas     December 1999     New model
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Clock generator
-------------------------------------------------------------------------------
library IEEE,work;
use IEEE.Std_Logic_1164.all;
--
entity ClkGen is
   port (
      Clk     : out Std_Logic);   -- Oscillator clock
end ClkGen;--==================== End of entity ==============================--
--------------------------------------------------------------------------------
-- Architecture for clock and reset signals generator
--------------------------------------------------------------------------------
architecture Behaviour of ClkGen is
begin --========================== Architecture ==============================-- 
  ------------------------------------------------------------------------------
  -- Provide the system clock signal
  ------------------------------------------------------------------------------
  ClkDriver : process
    variable clktmp : Std_Logic := '1';
    variable tpw_CI_posedge : Time := 12 ns; -- ~40 MHz
  begin
     Clk <= clktmp;
     clktmp := not clktmp;
    wait for tpw_CI_posedge;
  end process;
end Behaviour; --=================== End of architecure =====================--
-------------------------------------------------------------------------------
-- LoopBack Device
-------------------------------------------------------------------------------
library IEEE,work;
use IEEE.Std_Logic_1164.all;
--
entity LoopBack is
   port (
      Clk     : in  Std_Logic;   -- Oscillator clock
      RxWr    : in  Std_Logic;   -- Rx line
      TxWr    : out Std_Logic);  -- Tx line
end LoopBack; --==================== End of entity ==========================--
--------------------------------------------------------------------------------
-- Architecture for clock and reset signals generator
--------------------------------------------------------------------------------
architecture Behaviour of LoopBack is
begin --========================== Architecture ==============================-- 
  ------------------------------------------------------------------------------
  -- Provide the external clock signal
  ------------------------------------------------------------------------------
  ClkTrig : process(Clk)
  begin
      TxWr <= RxWr;
  end process;
end Behaviour; --=================== End of architecure =====================--

--------------------------------------------------------------------------------
-- Testbench for UART device 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Uart_Def.all;

entity UARTTEST is
end UARTTEST;

architecture stimulus of UARTTEST is
  -------------------------------------------------------------------
  -- Signals
  -------------------------------------------------------------------
  signal Reset   : Std_Logic;  -- Synchro signal
  signal Clk     : Std_Logic;  -- Clock signal
  signal DataIn  : Std_Logic_Vector(7 downto 0);
  signal DataOut : Std_Logic_Vector(7 downto 0);
  signal RxD     : Std_Logic;  -- RS-232 data input
  signal TxD     : Std_Logic;  -- RS-232 data output
  signal CS_N    : Std_Logic;
  signal RD_N    : Std_Logic;
  signal WR_N    : Std_Logic;
  signal IntRx_N : Std_Logic;  -- Receive interrupt
  signal IntTx_N : Std_Logic;  -- Transmit interrupt
  signal Addr    : Std_Logic_Vector(1 downto 0); -- 
  -------------------------------------------------------------------
  -- Clock Divider
  -------------------------------------------------------------------
  component ClkGen is
   port (
      Clk     : out Std_Logic);   -- Oscillator clock
  end component;
  -------------------------------------------------------------------
  -- LoopBack Device
  -------------------------------------------------------------------
  component LoopBack is
   port (
      Clk     : in  Std_Logic;   -- Oscillator clock
      RxWr    : in  Std_Logic;   -- Rx line
      TxWr    : out Std_Logic);  -- Tx line
  end component;
  -------------------------------------------------------------------
  -- UART Device
  -------------------------------------------------------------------
  component miniUART is
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
  end component;
begin --======================== Architecture ========================--
  ---------------------------------------------------------------------
  -- Instantiation of components
  ---------------------------------------------------------------------
  Clock       : ClkGen port map (Clk); 
  LoopDev     : LoopBack port map (Clk,TxD,RxD); 
  miniUARTDev : miniUART port map (Clk,Reset,CS_N,RD_N,WR_N,RxD,TxD,
                                   IntRx_N,IntTx_N,Addr,DataIn,DataOut);
  ---------------------------------------------------------------------
  -- Reset cycle
  ---------------------------------------------------------------------
  RstCyc : process
  begin
     Reset <= '1';
     wait for 5 ns;
     Reset <= '0';
     wait for 250 ns;
     Reset <= '1';
     wait;     
  end process;
  ---------------------------------------------------------------------
  -- 
  ---------------------------------------------------------------------
  ProcCyc : process(Clk,IntRx_N,IntTx_N,Reset)
      variable counter : unsigned(3 downto 0);
      constant cone : unsigned(3 downto 0):= "0001";
      variable temp : bit := '0';
  begin
     if Rising_Edge(Reset) then
        counter := "0000";
          WR_N <= '1';        
          RD_N <= '1';
          CS_N <= '1';
     elsif Rising_Edge(Clk) then
        if IntTx_N = '0' then
           if temp = '0' then
              temp := '1';
              case counter is
                 when "0000" =>
                      Addr <= "00";
                      DataIn <= x"AA";
                      WR_N <= '0';        
                      CS_N <= '0';        
                      counter := counter + cone;
                 when "0001" =>
                      Addr <= "00";
                      DataIn <= x"AF";
                      WR_N <= '0';        
                      CS_N <= '0';        
                      counter := counter + cone;
                 when "0010" =>
                      Addr <= "00";
                      DataIn <= x"55";
                      WR_N <= '0';        
                      CS_N <= '0';        
                      counter := counter + cone;
                 when "0011" =>
                      Addr <= "00";
                      DataIn <= x"E8";
                      WR_N <= '0';        
                      CS_N <= '0';        
                      counter := "0000";
                 when others => null;
              end case;
           elsif temp = '1' then
              temp := '0';
           end if;
        elsif IntRx_N = '0' then
           Addr <= "00";
           RD_N <= '0';
           CS_N <= '0';        
        else
          RD_N <= '1';        
          CS_N <= '1';        
          WR_N <= '1';        
          DataIn <= "ZZZZZZZZ";
        end if;
     end if;
  end process;
end stimulus; --================== End of TestBench ==================--