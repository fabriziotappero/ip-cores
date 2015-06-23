 --------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      NEXYS2 Wrapper: Switch/LED IO 
--!
--! \details
--!      There is way too much Front Panel IO on this device for each
--!      bit of IO to have its own pin.  This package virtualizes the
--!      Front Panel IO in order to reduce the number of IO pins.
--!
--!      In this implementation, all of the Front Panel IO is
--!      multiplexed onto a 24-bit, bidirectional IO bus.  This
--!      yields to 48 bits of input and 48 bits of output.
--!
--!      A state machine controls the operation of the IO bus.
--!
--!      The reset signal to the CPU is carefully managed such that
--!      complete cycle of the state machine is executed before the
--!      reset signal to the CPU is negated.
--!
--! \file
--!      nexys2_io.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--------------------------------------------------------------------
--
--  Copyright (C) 2011, 2012 Rob Doyle
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- version 2.1 of the License.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE. See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl.txt
--
--------------------------------------------------------------------
--
-- Comments are formatted for doxygen
--

library ieee;                                   --! IEEE Library
use ieee.std_logic_1164.all;                    --! IEEE 1164
use ieee.numeric_std.all;                       --! IEEE Std Logic Unsigned
use work.uart_types.all;                        --! UART types
use work.dk8e_types.all;                        --! DK8E types
use work.kc8e_types.all;                        --! KC8E types
use work.kl8e_types.all;                        --! KL8E types
use work.cpu_types.all;                         --! CPU types
use work.nexys2_types.all;                      --! Nexys2 Board types

--
--! NEXYS2 Switch/LED IO Entity
--

entity eNEXYS2_IO is port (
    clk     : in    std_logic;                  --! Clock
    rstIN   : in    std_logic;                  --! Reset Input
    ttyBR   : out   uartBR_t;                   --! Baud Rate Configuration
    swCPU   : out   swCPU_t;                    --! CPU Configuration
    swOPT   : out   swOPT_t;                    --! Configuration Options
    swROT   : out   swROT_t;                    --! Rotary Switch
    swRTC   : out   swRTC_t;                    --! RTC Configuration
    swDATA  : out   swDATA_t;                   --! Data Switches
    swCNTL  : out   swCNTL_t;                   --! Control Switches
    ledRUN  : in    std_logic;                  --! Run LED
    ledADDR : in    xaddr_t;                    --! Address LEDS
    ledDATA : in    data_t;                     --! Data LEDS
    ioDATA  : inout iodata_t;                   --! IO Data
    inOEA_L : out   std_logic;                  --! Input Data A Output Enable 
    inOEB_L : out   std_logic;                  --! Input Data B Output Enable
    outLEA  : out   std_logic;                  --! Output Data A Latch Enable
    outLEB  : out   std_logic;                  --! Output Data B Latch Enable
    rst     : out   std_logic                   --! Reset Output
);
end eNEXYS2_IO;

--
--! NEXYS2 Switch/LED IO Entity RTL
--

architecture rtl of eNEXYS2_IO is
    type   state_t is (stateRESET,              --! State Machine Type
                       stateRESET1,
                       stateREADAsetup,
                       stateREADA,
                       stateREADAhold,
                       stateWRITEAsetup,
                       stateWRITEA,
                       stateWRITEAhold,
                       stateREADBsetup,
                       stateREADB,
                       stateREADBhold,
                       stateWRITEBsetup,
                       stateWRITEB,
                       stateWRITEBhold);

    signal clken  : std_logic;                  --! Clock enable
    signal state  : state_t;                    --! State Machine state
    signal inA    : iodata_t;                   --! A Input
    signal inB    : iodata_t;                   --! B Input
    signal outA   : iodata_t;                   --! A Output
    signal outB   : iodata_t;                   --! B Output
    signal rstb   : std_logic;                  --! Reset Signal
    signal swDEP  : std_logic;                  --! Undebounced Deposit
    signal swSTEP : std_logic;                  --! Undebounced Step
    signal swHALT : std_logic;                  --! Undebounced Halt
    signal swEXAM : std_logic;                  --! Undebounced Examine
    signal swCONT : std_logic;                  --! Undebounced Continue
    
begin

    --
    --! Clock Divider
    --
  
    CLKDIV : process(clk, rstIN)
        variable count : integer range 0 to 49;
    begin
        if rstIN = '1' then
            clken <= '0';
            count := 0;
        elsif rising_edge(clk) then
            if count = 49 then
                clken <= '1';
                count := 0;
            else
                clken <= '0';
                count := count + 1;
            end if;
        end if;
    end process CLKDIV;

    --
    --! This State Machine operates as follows:
    --!  -# the "A Input" onto the IO Bus, then
    --!  -# the "A Output" onto the IO Bus, then
    --!  -# the "B Input" onto the IO Bus, then 
    --!  -# the "B Output" onto the IO Bus.
    --
    
    IO_MACHINE : process(clk, rstIN)
        
    begin
      
        if rstIN = '1' then
            inA   <= (others => '0');
            inB   <= (others => '0');
            rstb  <= '1';
            state <= stateRESET;
            
        elsif rising_edge(clk) then
          
            if clken = '1' then

                case state is

                    --
                    -- The rst signal is unsynchronized.  Add a few states after
                    -- rst negation to get synchronized.
                    --
                  
                    when stateRESET =>
                        state <= stateRESET1;
                      
                    --
                    -- The rst signal is unsynchronized.  Add a few states after
                    -- rst negation to get synchronized.
                    --
                  
                    when stateRESET1 =>
                        state <= stateREADAsetup;
                      
                    --
                    -- Setup A input data
                    --
                  
                    when stateREADAsetup =>
                        state <= stateREADA;

                    --
                    -- Read the A input data
                    --
                        
                    when stateREADA =>
                        inA   <= not(ioDATA);
                        state <= stateREADAhold;

                    --
                    -- Hold A input data
                    --
                        
                    when stateREADAhold =>
                        state <= stateWRITEAsetup;
                        
                    --
                    -- Setup A output data
                    --

                    when stateWRITEAsetup =>
                        state <= stateWRITEA;

                    --
                    -- Write A output data
                    --

                    when stateWRITEA =>
                       state <= stateWRITEAhold;
                      
                    --
                    -- Hold A output data
                    --

                    when stateWRITEAhold =>
                        state <= stateREADBsetup;

                    --
                    -- Setup B input data
                    --
                  
                    when stateREADBsetup =>
                        state <= stateREADB;

                    --
                    -- Read B input data
                    --
                       
                    when stateREADB =>
                        inB   <= not(ioDATA);
                        state <= stateREADBhold;
                        
                    --
                    -- Hold B input data
                    --
                        
                    when stateREADBhold =>
                        state <= stateWRITEBsetup;

                    --
                    -- Setup B output data
                    --

                    when stateWRITEBsetup => 
                        state <= stateWRITEB;

                    --
                    -- Write B output data
                    --
                        
                    when stateWRITEB =>
                        state <= stateWRITEBhold;
                       
                    --
                    -- Hold B output data
                    -- Take the CPU out of reset
                    --

                    when stateWRITEBhold =>
                        rstb  <= '0';
                        state <= stateREADAsetup;

                    --
                    -- Everything else
                    --
                        
                    when others =>
                        state <= stateRESET;
                        
                end case;
            end if;
        end if;
      
    end process IO_MACHINE;
    
    --
    -- Input Assignments - "A" Inputs
    --

    ttyBR(0)        <= inA( 0);
    ttyBR(1)        <= inA( 1);
    ttyBR(2)        <= inA( 2);
    ttyBR(3)        <= inA( 3);
    swCPU(0)        <= inA( 4);
    swCPU(1)        <= inA( 5);
    swCPU(2)        <= inA( 6);
    swCPU(3)        <= inA( 7);
    swOPT.KE8       <= inA( 8);
    swOPT.KM8E      <= inA( 9);
    swOPT.TSD       <= inA(10);
    swOPT.SP0       <= inA(11);
    swOPT.SP1       <= inA(12);
    swOPT.SP2       <= inA(13);
    swOPT.SP3       <= inA(14);
    swOPT.STARTUP   <= inA(15);
    swRTC(0)        <= inA(16);
    swRTC(1)        <= inA(17);
    swRTC(2)        <= inA(18);
    swCNTL.lock     <= inA(23);

    --
    -- Input Assignments - "B" Inputs
    --
    
    swROT(2)        <= inB( 0);
    swROT(1)        <= inB( 1);
    swROT(0)        <= inB( 2);
    swDEP           <= inB( 3);
    swSTEP          <= inB( 4);
    swHALT          <= inB( 5);
    swEXAM          <= inB( 6);
    swCONT          <= inB( 7);
    swCNTL.clear    <= not(inB( 8));
    swDATA(11)      <= inB( 9);
    swDATA(10)      <= inB(10);
    swDATA( 9)      <= inB(11);
    swDATA( 8)      <= inB(12);
    swDATA( 7)      <= inB(13);
    swDATA( 6)      <= inB(14);
    swDATA( 5)      <= inB(15);
    swDATA( 4)      <= inB(16);
    swDATA( 3)      <= inB(17);
    swDATA( 2)      <= inB(18);
    swDATA( 1)      <= inB(19);
    swDATA( 0)      <= inB(20);
    swCNTL.loadEXTD <= not(inB(21));
    swCNTL.loadADDR <= not(inB(22));
    swCNTL.boot     <= not(inB(23));

    --
    -- Output assignments
    --
    
    outA            <= not(ledDATA(11) & ledDATA(10) & ledDATA( 9) & ledDATA( 8) &
                           ledDATA( 7) & ledDATA( 6) & ledDATA( 5) & ledDATA( 4) &
                           ledDATA( 3) & ledDATA( 2) & ledDATA( 1) & ledDATA( 0) &
                           "000000000000");
    
    outB            <= not(ledRUN      & ledADDR(14) & ledADDR(13) & ledADDR(12) &
                           ledADDR(11) & ledADDR(10) & ledADDR( 9) & ledADDR( 8) &
                           ledADDR( 7) & ledADDR( 6) & ledADDR( 5) & ledADDR( 4) &
                           ledADDR( 3) & ledADDR( 2) & ledADDR( 1) & ledADDR( 0) &
                           "00000000");
    
    --
    -- Front Panel Switch Debounce
    --

    iDEBDEP : entity work.eNEXYS2_DEBOUNCE port map (
         clk   => clk,
         rst   => rstb,
         clken => clken,
         di    => swDEP,
         do    => swCNTL.dep
    );

    iDEBSTEP : entity work.eNEXYS2_DEBOUNCE port map (
         clk   => clk,
         rst   => rstb,
         clken => clken,
         di    => swSTEP,
         do    => swCNTL.step
    );

    iDEBHALT : entity work.eNEXYS2_DEBOUNCE port map (
         clk   => clk,
         rst   => rstb,
         clken => clken,
         di    => swHALT,
         do    => swCNTL.halt
    );

    iDEBEXAM : entity work.eNEXYS2_DEBOUNCE port map (
         clk   => clk,
         rst   => rstb,
         clken => clken,
         di    => swEXAM,
         do    => swCNTL.exam
    );

    iDEBCONT : entity work.eNEXYS2_DEBOUNCE port map (
         clk   => clk,
         rst   => rstb,
         clken => clken,
         di    => swCONT,
         do    => swCNTL.cont
    );

    --
    -- Combinational logic
    --

    rst             <= rstb;
    
    inOEA_L         <= '0' when ((state = stateREADAsetup) or
                                 (state = stateREADA)      or
                                 (state = stateREADAhold)) else
                       '1';
    
    inOEB_L         <= '0' when ((state = stateREADBsetup) or
                                 (state = stateREADB)      or
                                 (state = stateREADBhold)) else
                       '1';
    
    outLEA          <= '1' when (state = stateWRITEA) else
                       '0';
    
    outLEB          <= '1' when (state = stateWRITEB) else
                       '0';
    
    ioDATA          <= outA when ((state = stateWRITEAsetup) or
                                  (state = stateWRITEA)      or
                                  (state = stateWRITEAhold)) else
                       outB when ((state = stateWRITEBsetup) or
                                  (state = stateWRITEB)      or
                                  (state = stateWRITEBhold)) else
                       (others => 'Z');
    
end rtl;
