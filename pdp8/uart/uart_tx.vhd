--------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      KL8E Generic UART Transmitter
--!
--! \details
--!      The UART Transmitter is hard configured for:
--!      - 8 data bits
--!      - no parity
--!      - 1 stop bit
--!
--!      To transmit a word of data, provide the data on the data
--!      bus and assert the 'load' input for a clock cycle.  When
--!      the data is sent, the 'intr' output will be asserted for
--!      a single clock cycle.
--!
--! \note
--!      This UART primitive transmitter is kept simple
--!      intentionally and is therefore unbuffered.  If you
--!      require a double buffered UART, then you will need to
--!      layer a set of buffers on top of this device.
--!
--! \file
--!      uart_tx.vhd
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
--! KL8E Generic UART Transmitter Entity
--

entity eUART_TX is port (
    sys   : in  sys_t;                          --! Clock/Reset
    clkBR : in  std_logic;                      --! Clock Enable (for Baud Rate)
    data  : in  ascii_t;                        --! Data Input
    load  : in  std_logic;                      --! Load Data
    intr  : out std_logic;                      --! Interrupt
    txd   : out std_logic                       --! Serial Data Out
);
end eUART_TX;

--
--! KL8E Generic UART Transmitter RTL
--

architecture rtl of eUART_TX is
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
                       stateStop1,              --! Working on Stop Bit
                       stateDone);              --! Generate Interrupt
    signal state   : state_t;                   --! Transmitter State
    signal txReg   : ascii_t;                   --! Transmitter Register

begin
   
    --
    --! UART Transmitter:
    --!
    --!  The clkBR is 16 clocks per bit.  The UART transmits LSB first.
    --! 
    --!  When the load input is asserted, the data is loaded into the
    --!  Transmit Register and the state machine is started.
    --!
    --!  Once the state machine is started, it proceeds as follows:
    --!   -# Send Start Bit, then
    --!   -# Send bit 7 (LSB)
    --!   -# Send bit 6
    --!   -# Send bit 5
    --!   -# Send bit 4
    --!   -# Send bit 3
    --!   -# Send bit 2
    --!   -# Send bit 1
    --!   -# Send bit 0 (MSB)
    --!   -# Send Stop Bit 1
    --!   -# Send Stop Bit 2
    --!   -# Trigger Interrupt output
    --
  
    UARTTX : process(sys)
        variable brdiv : integer range 0 to 15;
    begin
      
        if sys.rst = '1' then
          
            brdiv := 0;
            txReg <= (others => '0');
            state <= stateIdle;
            
        elsif rising_edge(sys.clk) then

            case state is

                --
                -- Transmitter is sitting idle
                --
              
                when stateIdle =>
                    if load = '1' then
                        brdiv := 15;
                        txReg <= data;
                        state <= stateStart;
                    end if;

                --
                -- Sending Start Bit
                --
                    
                when stateStart =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            state <= stateBit7;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;

                --
                -- Sending Bit 7 (LSB)
                --
                    
                when stateBit7 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            state <= stateBit6;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;

                --
                -- Sending Bit 6
                --
                    
                when stateBit6 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            state <= stateBit5;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;

                --
                -- Sending Bit 5
                --
                    
                when stateBit5 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            state <= stateBit4;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;

                --
                -- Sending Bit 4
                --
                    
                when stateBit4 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            state <= stateBit3;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;

                --
                -- Sending Bit 3
                --
                    
                when stateBit3 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            state <= stateBit2;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;

                --
                -- Sending Bit 2
                --
                    
                when stateBit2 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            state <= stateBit1;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;

                --
                -- Sending Bit 1
                --
                    
                when stateBit1 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            state <= stateBit0;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;

                --
                -- Sending Bit 0
                --
                    
                when stateBit0 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            state <= stateStop1;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;

                --
                -- Sending Bit Stop Bit 1
                --
                    
                when stateStop1 =>
                    if clkBR = '1' then
                        if brdiv = 0 then
                            brdiv := 15;
                            state <= stateDone;
                        else
                            brdiv := brdiv - 1;
                        end if;
                    end if;

                --
                -- Done State.  Trigger Interrupt output.
                --
                    
                when stateDone =>
                    state <= stateIdle;
                    
            end case;
            
        end if;
    end process UARTTX;

    --
    -- Data selector for TXD
    --

    with state select
        txd <= '1'      when stateIdle,
               '0'      when stateStart,
               txReg(7) when stateBit7,
               txReg(6) when stateBit6,
               txReg(5) when stateBit5,
               txReg(4) when stateBit4,
               txReg(3) when stateBit3,
               txReg(2) when stateBit2,
               txReg(1) when stateBit1,
               txReg(0) when stateBit0,
               '1'      when stateStop1,
               '1'      when others;

    --
    -- Interrupt
    --

    intr <= '1' when state = stateDone else '0';

end rtl;
