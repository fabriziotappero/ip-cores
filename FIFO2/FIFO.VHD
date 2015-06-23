--===========================================================================--
--
--  S Y N T H E Z I A B L E    FIFO controller C O R E
--
--  www.OpenCores.Org - May 2000
--  This core adheres to the GNU public license  
--
-- Design units   : FIFO Memory Controller Unit 
--
-- File name      : Fifo.vhd
--
-- Purpose        : Implements the memory controller device.
--                  
-- Library        : FIFO_Lib
--
-- Dependencies   : IEEE.Std_Logic_1164
--
-- Author         : Ovidiu Lupas
--                 http://www.opencores.org/people/olupas
--                 olupas@opencores.org
--
-- Simulator      : ModelSim PE/PLUS version 4.7b on a Windows95 PC
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Revision list
-- Version   Author             Date            Changes
--
-- 0.1      Ovidiu Lupas       20 April 1999    New model
--       olupas@opencores.org
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Entity for FIFO Unit - 16 bit Data Bus width                              --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.FIFO_Def.all;
-------------------------------------------------------------------------------
entity FIFO is
  port (
     DataIn   : in  Std_Logic_Vector(15 downto 0);
     DataOut  : out Std_Logic_Vector(15 downto 0);
     WrClk    : in  Std_Logic;  -- Clock signal
     Push_N   : in  Std_Logic;  -- Write to FIFO signal
     RdClk    : in  Std_Logic;  -- Clock signal
     Pop_N    : in  Std_Logic;  -- Read from FIFO signal
     AlmFull  : out Std_Logic;  -- Status signal
     AlmEmpty : out Std_Logic;  -- Status signal
     Full     : out Std_Logic;  -- Status signal
     Empty    : out Std_Logic;  -- Status signal
     Reset    : in  Std_Logic); -- Reset input
end entity; --================== End of entity ==============================--
-------------------------------------------------------------------------------
-- Architecture for Sensor Control Unit
-------------------------------------------------------------------------------
architecture Structural of FIFO is
  -------------------------------------------------------------------
  -- Global declarations
  -------------------------------------------------------------------
  type MEMORY is array(0 to 15) of Std_Logic_Vector(15 downto 0);
  signal MEM       : Memory;
  -------------------------------------------------------------------
  -- Signals
  -------------------------------------------------------------------
  signal Rst    : Std_Logic;  -- Reset signal
  signal RdEn   : Std_Logic;  -- Read Enable
  signal WrEn   : Std_Logic;  -- Write Enable
  signal Clk    : Std_Logic;  -- 
  signal UpDn   : Std_Logic;  -- 
  signal En     : Std_Logic;  -- 
  signal WrAddr : Std_Logic_Vector(3 downto 0);  -- Write address
  signal RdAddr : Std_Logic_Vector(3 downto 0);  -- Read address
  -------------------------------------------------------------------
  -- Address counter for read and write operations
  -------------------------------------------------------------------
  component FIFOcnt is
    port (
        ClkIn  : in  Std_Logic;
        Reset  : in  Std_Logic;
        Enable : in  Std_Logic;
        CntOut : out Std_Logic_Vector(3 downto 0));
  end component;
  -------------------------------------------------------------------
  -- Status counter 
  -------------------------------------------------------------------
  component StatCnt is
    port (
        ClkIn    : in   Std_Logic;
        Reset    : in   Std_Logic;
        Enable   : in   Std_Logic;
        UpDown   : in   Std_Logic;
        Full     : out  Std_Logic;
        Empty    : out  Std_Logic;
        AlmFull  : out  Std_Logic;
        AlmEmpty : out  Std_Logic);
  end component;
begin
  ---------------------------------------------------------------------
  -- Instantiation of internal components
  ---------------------------------------------------------------------
  WrCnt  : FIFOCnt port map (WrClk,Rst,WrEn,WrAddr);
  RdCnt  : FIFOCnt port map (RdClk,Rst,RdEn,RdAddr);
  Status : StatCnt port map (Clk,Rst,En,UpDn,Full,Empty,AlmFull,AlmEmpty);
  ---------------------------------------------------------------------
  -- Latching the Reset command
  ---------------------------------------------------------------------
  RstEn : process(Reset)
  begin
     Rst <= not Reset;
  end process;
  ---------------------------------------------------------------------
  -- Latching the Push command
  ---------------------------------------------------------------------
  PushEn : process(Push_N)
  begin
     WrEn <= not Push_N;
  end process;
  ---------------------------------------------------------------------
  -- Latching the Pop command
  ---------------------------------------------------------------------
  PopEn : process(Pop_N)
  begin
     RdEn <= not Pop_N;
  end process;
  ---------------------------------------------------------------------
  -- write to memory process
  ---------------------------------------------------------------------
  WrCycle : process(WrClk,WrEn)
  begin
     if (Rising_Edge(WrClk) and WrEn = '1') then
        MEM(BV2Integer(WrAddr)) <= DataIn;
     end if;
  end process;
  ---------------------------------------------------------------------
  -- read from memory process
  ---------------------------------------------------------------------
  RdCycle : process(Reset,RdClk,RdEn)
  begin
     if Reset = '1' then
        DataOut <= "ZZZZZZZZZZZZZZZZ";
     elsif (Rising_Edge(RdClk) and RdEn = '1') then
        DataOut <= MEM(BV2Integer(RdAddr));
     end if;
  end process;
  ---------------------------------------------------------------------
  -- generating the signals for status counter
  ---------------------------------------------------------------------
  StatCycle : process(WrClk,RdClk,RdEn,WrEn)
    variable RdC    : Std_Logic;  -- 
    variable WrC    : Std_Logic;  -- 
  begin
    RdC := RdClk and RdEn;
    WrC := WrClk and WrEn;
    En <= RdEn xor WrEn;
    UpDn <= WrEn;
    Clk <= WrC xor RdC;
  end process;
end Structural; --==================== End of architecture ====================--