-------------------------------------------------------------------------------
-- Title      : UART
-- Project    : UART
-------------------------------------------------------------------------------
-- File        : Rxunit.vhd
-- Author      : Philippe CARTON 
--               (philippe.carton2@libertysurf.fr)
-- Organization:
-- Created     : 15/12/2001
-- Last update : 8/1/2003
-- Platform    : Foundation 3.1i
-- Simulators  : ModelSim 5.5b
-- Synthesizers: Xilinx Synthesis
-- Targets     : Xilinx Spartan
-- Dependency  : IEEE std_logic_1164
-------------------------------------------------------------------------------
-- Description: RxUnit is a serial to parallel unit Receiver.
-------------------------------------------------------------------------------
-- Copyright (c) notice
--    This core adheres to the GNU public license 
--
-------------------------------------------------------------------------------
-- Revisions       :
-- Revision Number :
-- Version         :
-- Date    :
-- Modifier        : name <email>
-- Description     :
--
------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   
entity RxUnit is
  port (
     Clk    : in  std_logic;  -- system clock signal
     Reset  : in  std_logic;  -- Reset input
     Enable : in  std_logic;  -- Enable input
     ReadA  : in  Std_logic;  -- Async Read Received Byte
     RxD    : in  std_logic;  -- RS-232 data input
     RxAv   : out std_logic;  -- Byte available
     DataO  : out std_logic_vector(7 downto 0)); -- Byte received
end RxUnit;

architecture Behaviour of RxUnit is
  signal RReg    : std_logic_vector(7 downto 0); -- receive register  
  signal RRegL   : std_logic;                    -- Byte received
begin
  -- RxAv process
  RxAvProc : process(RRegL,Reset,ReadA)
  begin
     if ReadA = '1' or Reset = '1' then
        RxAv <= '0';  -- Negate RxAv when RReg read     
     elsif Rising_Edge(RRegL) then
        RxAv <= '1';  -- Assert RxAv when RReg written
     end if;
  end process;
  
  -- Rx Process
  RxProc : process(Clk,Reset,Enable,RxD,RReg)
  variable BitPos : INTEGER range 0 to 10;   -- Position of the bit in the frame
  variable SampleCnt : INTEGER range 0 to 3; -- Count from 0 to 3 in each bit 
  begin
     if Reset = '1' then -- Reset
        RRegL <= '0';
        BitPos := 0;
     elsif Rising_Edge(Clk) then
        if Enable = '1' then
           case BitPos is
              when 0 => -- idle
                 RRegL <= '0';
                 if RxD = '0' then -- Start Bit
                    SampleCnt := 0;
                    BitPos := 1;
                 end if;
              when 10 => -- Stop Bit
                 BitPos := 0;    -- next is idle
                 RRegL <= '1';   -- Indicate byte received
                 DataO <= RReg;  -- Store received byte
              when others =>
                 if (SampleCnt = 1 and BitPos >= 2) then -- Sample RxD on 1
                    RReg(BitPos-2) <= RxD; -- Deserialisation
                 end if;
                 if SampleCnt = 3 then -- Increment BitPos on 3
                    BitPos := BitPos + 1;
                 end if;
           end case;
           if SampleCnt = 3 then
              SampleCnt := 0;
           else
              sampleCnt := SampleCnt + 1;
           end if;
           
        end if;
     end if;
  end process;
end Behaviour;
