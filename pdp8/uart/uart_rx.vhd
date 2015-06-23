--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      KL8E Generic UART Receiver
--!
--! \details
--!      The UART Receiver is hard configured for:
--!      - 8 data bits
--!      - no parity
--!      - 1 stop bit
--!
--! \note
--!      This UART primitive receiver is kept simple
--!      intentionally and is therefore unbuffered.  If you
--!      require a double buffered UART, then you will need to
--!      layer a set of buffers on top of this device.
--!
--! \file
--!      uart_rx.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2010, 2011, 2012 Rob Doyle
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
use work.uart_types.all;                        --! UART Types
use work.cpu_types.all;                         --! CPU Types

--
--! KL8E Generic UART Receiver Entity
--

entity eUART_RX is port (
    sys   : in  sys_t;                          --! Clock/Reset
    clkBR : in  std_logic;                      --! Clock Enable (for Baud Rate)
    rxd   : in  std_logic;                      --! Serial Data In
    intr  : out std_logic;                      --! Data Received
    data  : out ascii_t                         --! Data Output
);
end eUART_RX;

--
--! KL8E Generic UART Receiver RTL
--

architecture rtl of eUART_RX is
    type   state_t is (stateIdle,               --! Idle
                       stateStart,              --! Working on Start Bit
                       stateBit0,               --! Working on Bit 0
                       stateBit1,               --! Working on Bit 1
                       stateBit2,               --! Working on Bit 2
                       stateBit3,               --! Working on Bit 3
                       stateBit4,               --! Working on Bit 4
                       stateBit5,               --! Working on Bit 5
                       stateBit6,               --! Working on Bit 6
                       stateBit7,               --! Working on Bit 7
                       stateStop,               --! Working on Stop Bit
                       stateDone);              --! Generate Intr
    signal state   : state_t;                   --! Receiver State
    signal rxReg   : ascii_t;                   --! Receiver Register
    signal rxdd    : std_logic_vector(0 to 1);  --! Demet RXD

begin

    --
    --! This process synchronizes the Received Data to this clock
    --! domain.
    --
  
    DEMET_RXD : process(sys)
    begin
        if sys.rst = '1' then
            rxdd <= (others => '0');
        elsif rising_edge(sys.clk) then
            rxdd(0) <= rxd;
            rxdd(1) <= rxdd(0);
        end if;
    end process DEMET_RXD;
      
  
    --
    --! UART Receiver:
    --!  The clkBR is 16 clocks per bit.  The UART receives LSB first.
    --!
    --!  The state machine is initialized to the idle state where it
    --!  looks for a start bit.  When it find the 'edge' of the start
    --!  bit starts the state machine which does the following:
    --!
    --!  -# Continuously sample the start bit for half a bit period.
    --!     If the start bit is narrower than half a bit then, go back
    --!     to the idle state and look for a real start bit.   Othewise,
    --!  -# Delay one bit time from the middle of the Start bit and
    --!     sample bit D7 (LSB), then
    --!  -# Delay one bit time from the middle of D7 and sample bit D6, then
    --!  -# Delay one bit time from the middle of D6 and sample bit D5, then
    --!  -# Delay one bit time from the middle of D5 and sample bit D4, then
    --!  -# Delay one bit time from the middle of D4 and sample bit D3, then
    --!  -# Delay one bit time from the middle of D3 and sample bit D2, then
    --!  -# Delay one bit time from the middle of D2 and sample bit D1, then
    --!  -# Delay one bit time from the middle of D1 and sample bit D0, then
    --!  -# Delay one bit time from the middle of D0 and sample Stop
    --!     Bit, then
    --!  -# Generate INTR pulse for one clock cycle, then
    --!  -# go back to idle state and wait for a stop bit.
    --!

    UARTRX : process(sys)
        variable brdiv : integer range 0 to 15;
    begin
        if sys.rst = '1' then
          
            state <= stateIdle;
            rxReg <= (others => '0');
            brdiv := 0;
            
        elsif rising_edge(sys.clk) then
          
            case state is

                --
                -- Reciever is Idle
                --

                when stateIdle =>
                    if clkBR = '1' then
                        if rxdd(1) = '0' then
                            state <= stateStart;
                            brdiv := 8;
                        end if;
                    end if;

                --
                -- Receive Start Bit
                --
                    
                when stateStart =>
                    if clkBR = '1' then
                        if rxdd(1) = '0' then
                            if brdiv = 0 then
                                brdiv := 15;
                                state <= stateBit7;
                            else
                                brdiv := brdiv - 1;
                            end if;
                        else
                            state <= stateIdle;
                        end if;
                    end if;

                --
                -- Receive Bit 7 (LSB)
                --
                    
                when stateBit7 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            rxReg <= rxdd(1) & rxReg(0 to 6);
                            state <= stateBit6;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;
                    
                --
                -- Receive Bit 6 
                --
                    
                when stateBit6 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            rxReg <= rxdd(1) & rxReg(0 to 6);
                            state <= stateBit5;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;
                    
                --
                -- Receive Bit 5
                --
                    
                when stateBit5 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            rxReg <= rxdd(1) & rxReg(0 to 6);
                            state <= stateBit4;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;
                    
                --
                -- Receive Bit 4 
                --
                    
                when stateBit4 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            rxReg <= rxdd(1) & rxReg(0 to 6);
                            state <= stateBit3;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;
                    
                --
                -- Receive Bit 3
                --
                    
                when stateBit3 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            rxReg <= rxdd(1) & rxReg(0 to 6);
                            state <= stateBit2;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;
                    
                --
                -- Receive Bit 2
                --
                    
                when stateBit2 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            rxReg <= rxdd(1) & rxReg(0 to 6);
                            state <= stateBit1;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;
                    
                --
                -- Receive Bit 1
                --
                    
                when stateBit1 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            rxReg <= rxdd(1) & rxReg(0 to 6);
                            state <= stateBit0;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;
                    
                --
                -- Receive Bit 0 (MSB)
                --
                    
                when stateBit0 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            rxReg <= rxdd(1) & rxReg(0 to 6);
                            state <= stateStop;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;
                    
                --
                -- Receive Stop Bit
                --
                    
                 when stateStop =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            state <= stateDone;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;
                    
                --
                -- Generate Interrupt
                --
                    
               when stateDone =>
                  state <= stateIdle;
                  
            end case;
        end if;
    end process UARTRX;

    data <= rxReg;
    intr <= '1' when state = stateDone else '0';

end rtl;
