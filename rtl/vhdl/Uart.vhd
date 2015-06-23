-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- Generic UART with FIFO interface.
--
-- To Do:
-- -
-- 
-- Author(s): 
-- - Magnus Rosenius, magro732@opencores.org 
-- 
-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2013 Authors and OPENCORES.ORG 
-- 
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains 
-- the original copyright notice and the associated disclaimer. 
-- 
-- This source file is free software; you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General 
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any 
-- later version. 
-- 
-- This source is distributed in the hope that it will be 
-- useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE. See the GNU Lesser General Public License for more 
-- details. 
-- 
-- You should have received a copy of the GNU Lesser General 
-- Public License along with this source; if not, download it 
-- from http://www.opencores.org/lgpl.shtml 
-- 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Uart implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-------------------------------------------------------------------------------
-- Entity for Uart.
-------------------------------------------------------------------------------
entity Uart is
  generic(
    DIVISOR_WIDTH : natural;
    DATA_WIDTH : natural);
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    divisor_i : in std_logic_vector(DIVISOR_WIDTH-1 downto 0);
    
    serial_i : in std_logic;
    serial_o : out std_logic;
    
    empty_o : out std_logic;
    read_i : in std_logic;
    data_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
    
    full_o : out std_logic;
    write_i : in std_logic;
    data_i : in std_logic_vector(DATA_WIDTH-1 downto 0));
end entity;
       

-------------------------------------------------------------------------------
-- Architecture for Uart.
-------------------------------------------------------------------------------
architecture UartImpl of Uart is
  signal bitDuration : unsigned(DIVISOR_WIDTH-1 downto 0);
  signal bitSample : unsigned(DIVISOR_WIDTH-1 downto 0);
  
  type StateTypeRx is (STATE_INIT, STATE_IDLE,
                       STATE_START, STATE_DATA, STATE_STOP);
  signal rxState : StateTypeRx;
  signal rxShifter : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rxCounter : unsigned(DIVISOR_WIDTH-1 downto 0);
  signal rxBitCounter : natural range 0 to DATA_WIDTH-1;
  signal rxComplete : std_logic;
  signal rxData : std_logic_vector(DATA_WIDTH-1 downto 0);

  type StateTypeRxFifo is (STATE_EMPTY, STATE_WAITREAD);
  signal rxFifoState : StateTypeRxFifo;

  type StateTypeTx is (STATE_IDLE, STATE_SEND);
  signal txState : StateTypeTx;
  signal txShifter : std_logic_vector(DATA_WIDTH downto 0);
  signal txCounter : unsigned(DIVISOR_WIDTH-1 downto 0);
  signal txBitCounter : natural range 0 to DATA_WIDTH+1;
  
begin

  -- Setup the tick values when a bit is complete and when to sample it.
  bitDuration <= unsigned(divisor_i);
  bitSample <= '0' & unsigned(divisor_i(DIVISOR_WIDTH-1 downto 1));

  -----------------------------------------------------------------------------
  -- UART receiving process.
  -----------------------------------------------------------------------------
  Receiver: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      rxState <= STATE_INIT;
      rxShifter <= (others => '0');
      rxBitCounter <= 0;
      rxCounter <= (others => '0');

      rxComplete <= '0';
      rxData <= (others => '0');
    elsif (clk'event and (clk = '1')) then
      rxComplete <= '0';
      
      case rxState is

        when STATE_INIT =>
          ---------------------------------------------------------------------
          -- Wait for the line to become idle.
          ---------------------------------------------------------------------
          if (serial_i = '1') then
            rxState <= STATE_IDLE;
          end if;
          
        when STATE_IDLE =>
          ---------------------------------------------------------------------
          -- Wait for a long enough start pulse.
          ---------------------------------------------------------------------
          if (serial_i = '0') then
            -- The serial input is zero, indicating a start bit.

            -- Check how long it has been zero.
            if (rxCounter = bitSample) then
              -- It has been zero long enough.
              -- Proceed to read the full start bit before starting to sample
              -- the data.
              rxState <= STATE_START;
            else
              -- Stay in this state until it has lasted long enough.
            end if;

            -- Update to next sampling interval.
            rxCounter <= rxCounter + 1;
          else
            -- The serial input is not zero.
            -- Restart the sampling interval.
            rxCounter <= (others => '0');
          end if;
          
        when STATE_START =>
          ---------------------------------------------------------------------
          -- Wait for the startbit to end.
          ---------------------------------------------------------------------
          if (rxCounter = bitDuration) then
            rxCounter <= (others => '0');
            rxState <= STATE_DATA;
          else
            rxCounter <= rxCounter + 1;
          end if;
          
        when STATE_DATA =>
          ---------------------------------------------------------------------
          -- Sample data bits where it's appropriate.
          ---------------------------------------------------------------------
          if (rxCounter = bitDuration) then
            -- End of bit.
            -- Check if all the data bits has been read.
            if (rxBitCounter = (DATA_WIDTH-1)) then
              -- All data bits read.
              -- Read the stop bit.
              rxState <= STATE_STOP;
              rxBitCounter <= 0;
            else
              -- Continue to read more data bits.
              rxBitCounter <= rxBitCounter + 1;
            end if;

            -- Restart sampling interval.
            rxCounter <= (others => '0');
          elsif (rxCounter = bitSample) then
            -- Sample the bit and continue to sample until the bit ends.
            rxShifter <= serial_i & rxShifter((DATA_WIDTH-1) downto 1);
            rxCounter <= rxCounter + 1;
          else
            -- Wait for the middle or the end of the data to be reached.
            rxCounter <= rxCounter + 1;
          end if;

        when STATE_STOP =>
          ---------------------------------------------------------------------
          -- Sample stop bit where it's appropriate.
          ---------------------------------------------------------------------
          if (rxCounter = bitSample) then
            -- Sample the stop bit.

            -- Check if the stop bit is valid.
            if (serial_i = '1') then
              -- The stop bit is ok.
              -- Forward the read data.
              rxComplete <= '1';
              rxData <= rxShifter;
            else
              -- The stop bit is not ok.
              -- Do not forward the data character.
            end if;

            -- Reset sampling counter and go back to the init state.
            rxState <= STATE_INIT;
            rxCounter <= (others => '0');
          else
            -- Wait for the middle or the end of the data to be reached.
            rxCounter <= rxCounter + 1;
          end if;

        when others =>
          ---------------------------------------------------------------------
          -- Undefined state.
          ---------------------------------------------------------------------
          rxState <= STATE_IDLE;
          rxCounter <= (others => '0');
          
      end case;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- UART receiver fifo.
  -----------------------------------------------------------------------------
  ReceiverFifo: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      empty_o <= '1';
      data_o <= (others => '0');
      rxFifoState <= STATE_EMPTY;
    elsif (clk'event and (clk = '1')) then
      case rxFifoState is

        when STATE_EMPTY =>
          -- Wait for data to be forwarded from the UART receiver.
          if (rxComplete = '1') then
            -- Indicate there is data to read from.
            empty_o <= '0';
            data_o <= rxData;
            rxFifoState <= STATE_WAITREAD;
          else
            -- Wait for data to be received.
          end if;
          
        when STATE_WAITREAD =>
          -- Wait for the data to be read from the output port.
          if (read_i = '1') then
            -- The data has been read.
            empty_o <= '1';
            rxFifoState <= STATE_EMPTY;
          end if;
          -- Check if new data has been forwarded from the UART.
          if (rxComplete = '1') then
            -- New data has been forwarded without the output port being read.
            -- Overrun. Data has been lost.
            -- REMARK: Indicate this???
          end if;
          
        when others =>
          -- Undefined state.
          rxFifoState <= STATE_EMPTY;
      end case;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- UART transmitter process.
  -----------------------------------------------------------------------------
  Transmitter: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      txState <= STATE_IDLE;
      txShifter <= (others => '0');
      txBitCounter <= 0;
      txCounter <= (others => '0');
      
      full_o <= '0';
      serial_o <= '1';
    elsif (clk'event and (clk = '1')) then
      case txState is
        
        when STATE_IDLE =>
          ---------------------------------------------------------------------
          -- Wait for new data to be input on the input port.
          ---------------------------------------------------------------------
          if (write_i = '1') then
            -- New data present.
            full_o <= '1';
            txShifter <= "1" & data_i;
            txCounter <= (others => '0');
            txBitCounter <= 0;
            txState <= STATE_SEND;
            serial_o <= '0';
          end if;
          
        when STATE_SEND =>
          ---------------------------------------------------------------------
          -- Wait for the bit to be completly transmitted.
          ---------------------------------------------------------------------
          if (txCounter = bitDuration) then
            -- The bit has been sent.

            -- Check if the full character has been sent.
            if (txBitCounter = (DATA_WIDTH+1)) then
              -- Character has been sent.
              full_o <= '0';
              txState <= STATE_IDLE;
            else
              -- Character has not been sent yet.
              -- Send the next bit.
              serial_o <= txShifter(0);
              txShifter <= "0" & txShifter(DATA_WIDTH downto 1);
              txBitCounter <= txBitCounter + 1;
            end if;

            -- Update to the next bit.
            txCounter <= (others => '0');
          else
            -- Wait for the end of the bit.
            txCounter <= txCounter + 1;
          end if;

        when others =>
          ---------------------------------------------------------------------
          -- Undefined state.
          ---------------------------------------------------------------------
          txState <= STATE_IDLE;

      end case;
    end if;
  end process;

end architecture;
  
