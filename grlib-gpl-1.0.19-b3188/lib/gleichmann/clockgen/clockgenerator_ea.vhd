--------------------------------------------------------------------------------
-- Project     : Sandbox
-- Module      : ClockGenerator
-- File        : ClockGenerator.vhd
-- Description : Generate the clocks for the AudioCodec.
--------------------------------------------------------------------------------
-- Author       : Andreas Voggeneder
-- Organisation : FH-Hagenberg
-- Department   : Hardware/Software Systems Engineering
-- Language     : VHDL'87
--------------------------------------------------------------------------------
-- Copyright (c) 2003 by Andreas Voggeneder
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.CodecGlobal.all;

entity ClockGenerator is
  
  port (
    Clk     : in  std_ulogic;
    Reset   : in  std_ulogic;
    oMCLK   : out std_ulogic; -- 12 MHz
    oBCLK   : out std_ulogic; -- I2S bit clk
    oSCLK   : out std_ulogic; -- SPI Data Clk
    oLRCOUT : out std_ulogic);

end ClockGenerator;

architecture rtl of ClockGenerator is

  constant cResetActive : std_ulogic := '0';

begin  -- rtl

  createclock : process (Clk, Reset)
--    variable cntMCLK        : std_ulogic;            -- counter MCLK
    variable cntBCLK        : std_ulogic;            -- counter BCLK
    variable cntLRC         : unsigned(5 downto 0);  -- counter LRC
    variable internalMCLK   : std_ulogic;
    variable internalBCLK   : std_ulogic;
    variable internalSCLK   : std_ulogic; --_vector(1 downto 0);
    variable internalLRCOUT : std_ulogic;
  begin  -- process createclock
    if Reset = cResetActive then                     -- asynchronous reset
      internalMCLK   := '0';
      internalBCLK   := '0';
      internalSCLK   := '0';  --"00";
      internalLRCOUT := '1';
--      cntMCLK        := '0';
      cntBCLK        := '0';
      cntLRC         := (others => '0');
    elsif Clk'event and Clk = '1' then               -- rising clock edge
      internalSCLK := not (internalSCLK);
--      internalSCLK := std_ulogic_vector(unsigned(internalSCLK)+1);
--        if (cntMCLK = '1') then
--          cntMCLK      := '0';
          internalMCLK := not internalMCLK;       -- 25/2
          if (internalMCLK = '1') then
          -- == 25/2
            if (cntBCLK = '1') then
            -- == 25/4
              internalBCLK := not internalBCLK; --25/8
              cntBCLK      := '0';
              if (internalBCLK = '0') then
                if (cntLRC = "100001") then -- 33
                  internalLRCOUT := not internalLRCOUT;
                  cntLRC         := (others => '0');
                else
                  cntLRC := cntLRC + 1;
                end if;
              end if;
            else
              cntBCLK := '1';
            end if;
          end if;
--        else
--          cntMCLK := '1';
--        end if;
      
    end if;
    oMCLK   <= internalMCLK;
    oBCLK   <= internalBCLK;
    oSCLK   <= internalSCLK;  --(1);
    oLRCOUT <= internalLRCOUT;
  end process createclock;

end rtl;

-- 44,1kHz: Fs=44100
-- MCLK = 256*Fs = 11.2896 MHz. Gewählt 12.5 MHz
-- BCLK = Fs*2*32 = 2.82 MHz. Gewählt 3.125 MHz
-- => Fs real = 48.8 kHz

