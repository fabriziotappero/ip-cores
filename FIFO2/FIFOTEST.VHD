--============================================================================--
-- Design units   : TestBench for FIFO memory device. 
--
-- File name      : FIFOTest.vhd
--
-- Purpose        : Implements the test bench for FIFO memory device.
--
-- Library        : ECO_Lib.vhd
--
-- Dependencies	: None
--
-- Author         : Ovidiu Lupas
--                 http://www.opencores.org/people/olupas
--                 olupas@opencores.org
--
-- Simulator     : ModelSim PE/PLUS version 4.7b on a Windows95 PC
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Revision list
-- Version   Author             Date          Changes
--
-- 0.1      Ovidiu Lupas     18 April 99     New model
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Clock generator
-------------------------------------------------------------------------------
library IEEE,work;
use IEEE.Std_Logic_1164.all;
--
entity ClkGen is
   port (
      WrClk     : out Std_Logic;
      RdClk     : out Std_Logic);   -- Oscillator clock
end ClkGen;--==================== End of entity ==============================--
--------------------------------------------------------------------------------
-- Architecture for clock and reset signals generator
--------------------------------------------------------------------------------
architecture Behaviour of ClkGen is
begin --========================== Architecture ==============================-- 
  ------------------------------------------------------------------------------
  -- Provide the external clock signal
  ------------------------------------------------------------------------------
  WrClkDriver : process
    variable clktmp : Std_Logic := '1';
    variable tpw_CI_posedge : Time := 31 ns; -- 16 MHz
  begin
     WrClk <= clktmp;
     clktmp := not clktmp;
    wait for tpw_CI_posedge;
  end process;
  ------------------------------------------------------------------------------
  -- Provide the external clock signal
  ------------------------------------------------------------------------------
  RdClkDriver : process
    variable clktmp : Std_Logic := '1';
    variable tpw_CI_posedge : Time := 51 ns; -- 16 MHz
  begin
     RdClk <= clktmp;
     clktmp := not clktmp;
    wait for tpw_CI_posedge;
  end process;
end Behaviour; --=================== End of architecure =====================--
--------------------------------------------------------------------------------
-- Testbench for FIFO memory 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.ECO_Def.all;

entity FIFOTEST is
end FIFOTEST;

architecture stimulus of FIFOTEST is
  -------------------------------------------------------------------
  -- Global declarations
  -------------------------------------------------------------------
  type MEMORY is array(0 to 15) of Std_Logic_Vector(15 downto 0);
  constant Data : MEMORY := ("0101010101010101", "1010101010101010",
                             "1111101010100000", "1111010101010000",
                             "1111101010100000", "1111010101010000",
                             "0101010101010101", "1010101010101010",
                             "1111111111111111", "0000000000000000",
                             "1111101010100000", "1111010101010000",
                             "0101010101010101", "1010101010101010",
                             "1111111111111111", "0000000000000000");
  -------------------------------------------------------------------
  -- Signals
  -------------------------------------------------------------------
  signal Reset    : Std_Logic;  -- Synchro signal
  signal RdClk    : Std_Logic;  -- Clock signal
  signal WrClk    : Std_Logic;  -- Clock signal
  signal DataIn   : Std_Logic_Vector(15 downto 0);
  signal DataOut  : Std_Logic_Vector(15 downto 0);
  signal Push_N   : Std_Logic;
  signal Pop_N    : Std_Logic;
  signal AlmFull  : Std_Logic;
  signal AlmEmpty : Std_Logic;
  signal Full     : Std_Logic;
  signal Empty    : Std_Logic;
  -------------------------------------------------------------------
  -- Clock Generator
  -------------------------------------------------------------------
  component ClkGen is
   port (
      WrClk     : out Std_Logic;   -- Oscillator clock
      RdClk     : out Std_Logic);   -- Oscillator clock
  end component;
  -------------------------------------------------------------------
  -- Sensor Control Unit
  -------------------------------------------------------------------
  component FIFO is
     port (
       DataIn   : in  Std_Logic_Vector(15 downto 0);
       DataOut  : out Std_Logic_Vector(15 downto 0);
       WrClk    : in  Std_Logic;  -- Clock signal
       Push_N   : in  Std_Logic;  -- Clock signal
       RdClk    : in  Std_Logic;  -- Clock signal
       Pop_N    : in  Std_Logic;  -- Clock signal
       AlmFull  : out Std_Logic;  -- Status signal
       AlmEmpty : out Std_Logic;  -- Status signal
       Full     : out Std_Logic;  -- Status signal
       Empty    : out Std_Logic;  -- Status signal
       Reset    : in  Std_Logic); -- Reset input
  end component;
begin --======================== Architecture ========================--
  ---------------------------------------------------------------------
  -- Instantiation of components
  ---------------------------------------------------------------------
  Clock  : ClkGen port map (WrClk,RdClk); 
  Mem    : FIFO   port map (DataIn,DataOut,WrClk,Push_N,RdClk,Pop_N,
                            AlmFull,AlmEmpty,Full,Empty,Reset);
  ---------------------------------------------------------------------
  -- Reset cycle
  ---------------------------------------------------------------------
  RstCyc : process
  begin
     Reset <= '1';
     wait for 5 ns;
     Reset <= '0';
     wait for 50 ns;
     Reset <= '1';
     wait;     
  end process;
  ---------------------------------------------------------------------
  -- Read cycle
  ---------------------------------------------------------------------
  RdCyc : process(RdClk,Reset)
      variable temp : Std_Logic := '0';
      variable i    : Integer := 0;
  begin
     if Falling_Edge(Reset) then
        temp := '0';
        i := 0;
        Pop_N <= '1';
     elsif (Rising_Edge(RdClk) and Empty = '0') then
        temp := not temp;
        i := i + 1;
        if i = 15 then
           i := 0;
        end if;
        if temp = '0' then
           Pop_N <= '0';
        else
           Pop_N <= '1';
        end if;
     end if;
  end process;
  ---------------------------------------------------------------------
  -- Write cycle
  ---------------------------------------------------------------------
  WrCyc : process(WrClk,Reset)
     variable temp : Std_Logic := '1';
     variable i    : Integer := 0;
  begin
     if Falling_Edge(Reset) then
        temp := '0';
        i := 0;
        Push_N <= '1';
     elsif (Rising_Edge(WrClk) and Full = '0') then
        temp := not temp;
        i := i + 1;
        if i = 15 then
           i := 0;
        end if;
        if temp = '0' then
           Push_N <= '0';
           DataIn <= Data(i);
        else
           Push_N <= '1';
           DataIn <= "ZZZZZZZZZZZZZZZZ";
        end if;
     end if;
  end process;
end stimulus; --================== End of TestBench ==================--

