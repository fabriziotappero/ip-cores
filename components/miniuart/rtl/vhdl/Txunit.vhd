-------------------------------------------------------------------------------
-- Title      : UART
-- Project    : UART
-------------------------------------------------------------------------------
-- File        : Txunit.vhd
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
-- Description: Txunit is a parallel to serial unit transmitter.
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

entity TxUnit is
  port (
     Clk    : in  std_logic;  -- Clock signal
     Reset  : in  std_logic;  -- Reset input
     Enable : in  std_logic;  -- Enable input
     LoadA  : in  std_logic;  -- Asynchronous Load
     TxD    : out std_logic;  -- RS-232 data output
     Busy   : out std_logic;  -- Tx Busy
     DataI  : in  std_logic_vector(7 downto 0)); -- Byte to transmit
end TxUnit;

architecture Behaviour of TxUnit is

  component synchroniser
  port (
     C1 : in std_logic;	 -- Asynchronous signal
     C :  in std_logic;	 -- Clock
     O :  out Std_logic);-- Synchronised signal
  end component;
  
  signal TBuff    : std_logic_vector(7 downto 0); -- transmit buffer
  signal TReg     : std_logic_vector(7 downto 0); -- transmit register
  signal TBufL    : std_logic;  -- Buffer loaded
  signal LoadS    : std_logic;	-- Synchronised load signal

begin
  -- Synchronise Load on Clk
  SyncLoad : Synchroniser port map (LoadA, Clk, LoadS);
  Busy <= LoadS or TBufL;

  -- Tx process
  TxProc : process(Clk, Reset, Enable, DataI, TBuff, TReg, TBufL)
  variable BitPos : INTEGER range 0 to 10; -- Bit position in the frame
  begin
     if Reset = '1' then
        TBufL <= '0';
        BitPos := 0;
        TxD <= '1';
     elsif Rising_Edge(Clk) then
        if LoadS = '1' then
           TBuff <= DataI;
           TBufL <= '1';
        end if;
        if Enable = '1' then
           case BitPos is
              when 0 => -- idle or stop bit
                 TxD <= '1';
                 if TBufL = '1' then -- start transmit. next is start bit
                    TReg <= TBuff;
                    TBufL <= '0';
                    BitPos := 1;
                 end if;
              when 1 => -- Start bit
                 TxD <= '0';
                 BitPos := 2;
              when others =>
                 TxD <= TReg(BitPos-2); -- Serialisation of TReg
                 BitPos := BitPos + 1;
           end case;
           if BitPos = 10 then -- bit8. next is stop bit
              BitPos := 0;
           end if;
        end if;
     end if;
  end process;
end Behaviour;
