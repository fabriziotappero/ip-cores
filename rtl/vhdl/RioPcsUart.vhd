-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- This file contains a PCS (Physical Control Sublayer) that can transfer
-- RapidIO symbols accross a 2Mbit 8-bit UART transmission channel.
-- The coding is similar to the coding used by PPP and uses flags (0x7e)
-- and escape-sequences (0x7d) to encode special characters.
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
-- RioPcsUart
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for RioPcsUart.
-------------------------------------------------------------------------------
entity RioPcsUart is
  generic(
    DIVISOR_WIDTH : natural);
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    divisor_i : in std_logic_vector(DIVISOR_WIDTH-1 downto 0);
    
    portInitialized_o : out std_logic;
    outboundSymbolEmpty_i : in std_logic;
    outboundSymbolRead_o : out std_logic;
    outboundSymbol_i : in std_logic_vector(33 downto 0);
    inboundSymbolFull_i : in std_logic;
    inboundSymbolWrite_o : out std_logic;
    inboundSymbol_o : out std_logic_vector(33 downto 0);

    serial_o : out std_logic;
    serial_i : in std_logic);
end entity;


-------------------------------------------------------------------------------
-- Architecture for RioPcsUart.
-------------------------------------------------------------------------------
architecture RioPcsUartImpl of RioPcsUart is

  component RioSymbolConverter is
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      portInitialized_o : out std_logic;
      outboundSymbolEmpty_i : in std_logic;
      outboundSymbolRead_o : out std_logic;
      outboundSymbol_i : in std_logic_vector(33 downto 0);
      inboundSymbolFull_i : in std_logic;
      inboundSymbolWrite_o : out std_logic;
      inboundSymbol_o : out std_logic_vector(33 downto 0);

      uartEmpty_i : in std_logic;
      uartRead_o : out std_logic;
      uartData_i : in std_logic_vector(7 downto 0);
      uartFull_i : in std_logic;
      uartWrite_o : out std_logic;
      uartData_o : out std_logic_vector(7 downto 0));
  end component;

  component Uart is
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
  end component;

  signal uartEmpty : std_logic;
  signal uartRead : std_logic;
  signal uartReadData : std_logic_vector(7 downto 0);
  signal uartFull : std_logic;
  signal uartWrite : std_logic;
  signal uartWriteData : std_logic_vector(7 downto 0);

begin

  SymbolConverter: RioSymbolConverter
    port map(
      clk=>clk, areset_n=>areset_n, 
      portInitialized_o=>portInitialized_o,
      outboundSymbolEmpty_i=>outboundSymbolEmpty_i,
      outboundSymbolRead_o=>outboundSymbolRead_o, outboundSymbol_i=>outboundSymbol_i, 
      inboundSymbolFull_i=>inboundSymbolFull_i,
      inboundSymbolWrite_o=>inboundSymbolWrite_o, inboundSymbol_o=>inboundSymbol_o, 
      uartEmpty_i=>uartEmpty, uartRead_o=>uartRead, uartData_i=>uartReadData, 
      uartFull_i=>uartFull, uartWrite_o=>uartWrite, uartData_o=>uartWriteData);

  UartInst: Uart
    generic map(DIVISOR_WIDTH=>DIVISOR_WIDTH, DATA_WIDTH=>8)
    port map(
      clk=>clk, areset_n=>areset_n,
      divisor_i=>divisor_i,
      serial_i=>serial_i, serial_o=>serial_o,
      empty_o=>uartEmpty, read_i=>uartRead, data_o=>uartReadData,
      full_o=>uartFull, write_i=>uartWrite, data_i=>uartWriteData);

end architecture;



-------------------------------------------------------------------------------
-- This module encodes and decodes RapidIO symbols for transmission on a 8-bit
-- UART using HDLC-like framing (see PPP).
-- When an idle-symbol is received it will be preceeded by an idle link for a
-- few micro seconds. This idle link time is used to synchronize the receiver
-- in the link partner that needs to know when a character is starting and not.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for RioSymbolConverter.
-------------------------------------------------------------------------------
entity RioSymbolConverter is
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    portInitialized_o : out std_logic;
    outboundSymbolEmpty_i : in std_logic;
    outboundSymbolRead_o : out std_logic;
    outboundSymbol_i : in std_logic_vector(33 downto 0);
    inboundSymbolFull_i : in std_logic;
    inboundSymbolWrite_o : out std_logic;
    inboundSymbol_o : out std_logic_vector(33 downto 0);

    uartEmpty_i : in std_logic;
    uartRead_o : out std_logic;
    uartData_i : in std_logic_vector(7 downto 0);
    uartFull_i : in std_logic;
    uartWrite_o : out std_logic;
    uartData_o : out std_logic_vector(7 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for RioSymbolConverter.
-------------------------------------------------------------------------------
architecture RioSymbolConverterImpl of RioSymbolConverter is

  -- Define the flag sequence and the control escape sequence.
  constant FLAG_SEQUENCE : std_logic_vector(7 downto 0) := x"7e";
  constant CONTROL_ESCAPE : std_logic_vector(7 downto 0) := x"7d";
  constant SILENCE_TIME : natural := 4095;
  constant IDLE_SYMBOL_TIME : natural := 256;
  constant LINK_LOST_TIME : natural := 4095;
  
  type TxStateType is (STATE_SILENCE, STATE_IDLE_0, STATE_IDLE_1,
                       STATE_BUSY_1, STATE_BUSY_2, STATE_SEND_FLAG);
  signal txState : TxStateType;
  signal txStateCounter : unsigned(1 downto 0);
  signal outboundSymbolData : std_logic_vector(7 downto 0);
  
  type RxStateType is (STATE_INIT, STATE_NORMAL);
  signal rxState : RxStateType;
  signal rxStateCounter : unsigned(1 downto 0);
  signal escapeFound : std_logic;

  signal txTimerReset : std_logic;
  signal txTimerEnable : std_logic;
  signal txTimerCounter : unsigned(11 downto 0);
  signal silenceTxTimerDone : std_logic;
  signal idleTxTimerDone : std_logic;
  
  signal rxTimerReset : std_logic;
  signal rxTimerEnable : std_logic;
  signal rxTimerCounter : unsigned(11 downto 0);
  signal lostRxTimerDone : std_logic;
    
  signal uartWrite : std_logic;
  signal uartRead : std_logic;

begin

  -- Set the port initialized once the receiver enters its normal state.
  portInitialized_o <= '1' when (rxState = STATE_NORMAL) else '0';
    
  -----------------------------------------------------------------------------
  -- Timer functionallity.
  -----------------------------------------------------------------------------

  silenceTxTimerDone <= '1' when (txTimerCounter = SILENCE_TIME) else '0';
  idleTxTimerDone <= '1' when (txTimerCounter = IDLE_SYMBOL_TIME) else '0';
  
  process(areset_n, clk)
  begin
    if (areset_n = '0') then
      txTimerCounter <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (txTimerReset = '1') then
        txTimerCounter <= (others => '0');
      elsif (txTimerEnable = '1') then
        txTimerCounter <= txTimerCounter + 1;
      end if;
    end if;
  end process;

  lostRxTimerDone <= '1' when (rxTimerCounter = LINK_LOST_TIME) else '0';
  
  process(areset_n, clk)
  begin
    if (areset_n = '0') then
      rxTimerCounter <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (rxTimerReset = '1') then
        rxTimerCounter <= (others => '0');
      elsif (rxTimerEnable = '1') then
        rxTimerCounter <= rxTimerCounter + 1;
      end if;
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Link symbol encoder process.
  -----------------------------------------------------------------------------
  outboundSymbolData <= outboundSymbol_i(31 downto 24) when txStateCounter = 0 else
                        outboundSymbol_i(23 downto 16) when txStateCounter = 1 else
                        outboundSymbol_i(15 downto 8) when txStateCounter = 2 else
                        outboundSymbol_i(7 downto 0);
                        
  uartWrite_o <= uartWrite;
  Outbound: process(areset_n, clk)
  begin
    if (areset_n = '0') then
      txState <= STATE_SILENCE;
      txStateCounter <= (others => '0');

      txTimerReset <= '0';
      txTimerEnable <= '0';
      
      outboundSymbolRead_o <= '0';
      
      uartWrite <= '0';
      uartData_o <= (others => '0');
    elsif (clk'event and clk = '1') then
      txTimerReset <= '0';
      outboundSymbolRead_o <= '0';
      uartWrite <= '0';

      -- Check if the UART is ready for new data.
      if (uartFull_i = '0') and (uartWrite = '0') then
        -- The UART want new data to transmitt.

        -- Check the transmission state.
        case txState is

          when STATE_SILENCE =>
            -------------------------------------------------------------------
            -- Wait for a while to let the linkpartner detect a link break.
            -------------------------------------------------------------------
            -- Check if the silence timer has expired.
            if (silenceTxTimerDone = '1') then
              -- Silence timer expired.
              -- Reset the timer and proceed to transmitting symbols.
              txTimerReset <= '1';
              txTimerEnable <= '0';
              txState <= STATE_IDLE_0;
            else
              txTimerEnable <= '1';
            end if;
          
          when STATE_IDLE_0 =>
            -----------------------------------------------------------------
            -- Wait for a new symbol to be received. An idle symbol is followed
            -- by a small inter-character idle time to let the receiver in the
            -- link partner synchronize itself to the link.
            -----------------------------------------------------------------
            
            -- Reset the state counter for the symbol generation.
            txStateCounter <= "00";
              
            -- Check if a new symbol is available.
            if (outboundSymbolEmpty_i = '0') then
              -- A new symbol is available.

              -- Check if the new symbol is idle, control or data.
              if (outboundSymbol_i(33 downto 32) /= SYMBOL_IDLE) then
                -- Control or data symbol.
                txState <= STATE_BUSY_1;
              else
                -- Send idle sequence.
                txState <= STATE_IDLE_1;
              end if;
            else
              -- No new symbols are ready.
              -- Dont do anything.
            end if;

          when STATE_IDLE_1 =>
            -------------------------------------------------------------------
            -- Wait until the idle timer has expired to let the link be idle in
            -- between idle symbols.
            -------------------------------------------------------------------

            -- Check if the idle timer has expired.
            if (idleTxTimerDone = '1') then
              -- Idle timer has expired.
              -- Reset the timer and disable it.
              txTimerReset <= '1';
              txTimerEnable <= '0';

              -- Write a flag to indicate idle link.
              uartWrite <= '1';
              uartData_o <= FLAG_SEQUENCE;

              -- Get a new symbol.
              outboundSymbolRead_o <= '1';
              txState <= STATE_IDLE_0;
            else
              -- Idle timer has not expired yet.
              txTimerEnable <= '1';
            end if;
            
          when STATE_BUSY_1 =>
            -----------------------------------------------------------------
            -- Encode a control or data symbol. If stuffing is needed the next
            -- busy state is called.
            -----------------------------------------------------------------
            
            -- Check if the octet is a flag or escape character.
            if ((outboundSymbolData = FLAG_SEQUENCE) or
                (outboundSymbolData = CONTROL_ESCAPE)) then
              -- Flag or escape octet.
              uartWrite <= '1';
              uartData_o <= CONTROL_ESCAPE;
              txState <= STATE_BUSY_2;
            else
              -- Ordinary octet.

              -- Write the octet to the uart.
              uartWrite <= '1';
              uartData_o <= outboundSymbolData;

              -- Update to the next octet in the symbol.
              txStateCounter <= txStateCounter + 1;

              -- Check if the symbol has been sent.
              if (txStateCounter = 3) then
                -- Data symbol sent.
                outboundSymbolRead_o <= '1';
                txState <= STATE_IDLE_0;
              elsif ((txStateCounter = 2) and
                     (outboundSymbol_i(33 downto 32) /= SYMBOL_DATA)) then
                -- Control symbol sent.
                txState <= STATE_SEND_FLAG;
              else
                -- Symbol not completly sent.
                txState <= STATE_BUSY_1;
              end if;
            end if;
            
          when STATE_BUSY_2 =>
            -----------------------------------------------------------------
            -- Byte stuff a flag or escape sequence found in the symbol data
            -- content.
            -----------------------------------------------------------------
            
            -- Byte stuff the control character.
            uartWrite <= '1';
            uartData_o <= outboundSymbolData xor x"20";

            -- Update to the next symbol.
            txStateCounter <= txStateCounter + 1;

            -- Check if the symbol has been sent.
            if (txStateCounter = 3) then
              -- Data symbol sent.
              outboundSymbolRead_o <= '1';
              txState <= STATE_IDLE_0;
            elsif ((txStateCounter = 2) and
                   (outboundSymbol_i(33 downto 32) /= SYMBOL_DATA)) then
              -- Control symbol sent.
              txState <= STATE_SEND_FLAG;
            else
              -- Symbol not completly sent.
              txState <= STATE_BUSY_1;
            end if;

          when STATE_SEND_FLAG =>
            -----------------------------------------------------------------
            -- Force a flag to be written to the link.
            -----------------------------------------------------------------
            
            uartWrite <= '1';
            uartData_o <= FLAG_SEQUENCE;
            outboundSymbolRead_o <= '1';
            txState <= STATE_IDLE_0;
            
          when others =>
            -----------------------------------------------------------------
            -- Unknown state.
            -----------------------------------------------------------------
            txState <= STATE_IDLE_0;
            
        end case;
      else
        -- The UART is busy transmitting.
        -- Wait for the UART to complete.
      end if;
    end if;
  end process;

  
  -----------------------------------------------------------------------------
  -- Link symbol decoder process.
  -----------------------------------------------------------------------------
  uartRead_o <= uartRead;
  Inbound: process(areset_n, clk)
  begin
    if (areset_n = '0') then
      rxState <= STATE_INIT;
      rxStateCounter <= (others => '0');
      escapeFound <= '0';

      rxTimerReset <= '0';
      rxTimerEnable <= '0';
      
      inboundSymbolWrite_o <= '0';
      inboundSymbol_o <= (others => '0');
      
      uartRead <= '0';
    elsif (clk'event and clk = '1') then
      rxTimerReset <= '0';
      inboundSymbolWrite_o <= '0';
      uartRead <= '0';

      case rxState is
        
        when STATE_INIT =>
          -------------------------------------------------------------------
          -- Wait for a flag to be received.
          -------------------------------------------------------------------
          -- Check if any new data is ready.
          if (uartRead = '0') and (uartEmpty_i = '0') then
            -- New data is ready from the uart.

            -- Check if a flag has been received.
            if (uartData_i = FLAG_SEQUENCE) then
              -- A flag has been received.
              -- Considder the port to be initialized.
              rxState <= STATE_NORMAL;
              rxStateCounter <= (others => '0');
              escapeFound <= '0';
              rxTimerReset <= '1';
              rxTimerEnable <= '1';
              uartRead <= '1';
            else
              -- Something that is not a flag has been received.
              -- Discard the data and wait for a flag.
              uartRead <= '1';
            end if;
          else
            -- Waiting for inbound data.
            -- Dont do anything.
          end if;
          
        when STATE_NORMAL =>
          -------------------------------------------------------------------
          -- Parse the incoming stream and create symbols.
          -------------------------------------------------------------------

          -- Check if the link lost timer has expired.
          if (lostRxTimerDone = '1') then
            -- The link lost timer has expired.
            -- Reset the timer, disable it and go back to the initial state.
            rxTimerReset <= '1';
            rxTimerEnable <= '0';
            rxState <= STATE_INIT;
          else
            -- The link lost timer has not expired.
            
            -- Check if any new data is ready.
            if (uartRead = '0') and (uartEmpty_i = '0') then
              -- New data is ready from the uart.

              -- Reset the link lost timer.
              rxTimerReset <= '1';
              
              -- Check if a flag has been received.
              if (uartData_i /= FLAG_SEQUENCE) then
                -- The received octet was not a flag.

                -- Check if the octet was a contol character.
                if (uartData_i /= CONTROL_ESCAPE) then
                  -- The octet was not a control character.

                  -- Check where in a symbol the reception is.
                  case rxStateCounter is
                    
                    when "00" =>
                      inboundSymbol_o(33 downto 32) <= SYMBOL_IDLE;
                      if (escapeFound = '0') then
                        inboundSymbol_o(31 downto 24) <= uartData_i;
                      else
                        inboundSymbol_o(31 downto 24) <= uartData_i xor x"20";
                      end if;
                      rxStateCounter <= rxStateCounter + 1;
                      
                    when "01" =>
                      inboundSymbol_o(33 downto 32) <= SYMBOL_IDLE;
                      if (escapeFound = '0') then
                        inboundSymbol_o(23 downto 16) <= uartData_i;
                      else
                        inboundSymbol_o(23 downto 16) <= uartData_i xor x"20";
                      end if;
                      rxStateCounter <= rxStateCounter + 1;
                      
                    when "10" =>
                      inboundSymbol_o(33 downto 32) <= SYMBOL_CONTROL;
                      if (escapeFound = '0') then
                        inboundSymbol_o(15 downto 8) <= uartData_i;
                      else
                        inboundSymbol_o(15 downto 8) <= uartData_i xor x"20";
                      end if;
                      rxStateCounter <= rxStateCounter + 1;
                      
                    when "11" =>
                      inboundSymbol_o(33 downto 32) <= SYMBOL_DATA;
                      if (escapeFound = '0') then
                        inboundSymbol_o(7 downto 0) <= uartData_i;
                      else
                        inboundSymbol_o(7 downto 0) <= uartData_i xor x"20";
                      end if;
                      rxStateCounter <= rxStateCounter + 1;
                      inboundSymbolWrite_o <= '1';
                      
                    when others =>
                      rxStateCounter <= "00";
                      
                  end case;

                  -- Read the octet from the uart.
                  uartRead <= '1';
                  escapeFound <= '0';
                else
                  -- Control escape received.
                  
                  -- Read the octet and indicate that an escape character has been received.
                  uartRead <= '1';
                  escapeFound <= '1';
                end if;
              else
                -- Flag received.

                -- Check if there are any unsent symbols pending.
                if (rxStateCounter = 0) then
                  -- No pending symbol.
                  -- Send an idle symbol.
                  inboundSymbolWrite_o <= '1';
                  inboundSymbol_o(33 downto 32) <= SYMBOL_IDLE;
                else
                  -- Pending symbol.
                  -- Send the pending symbol.
                  inboundSymbolWrite_o <= '1';
                end if;

                -- Read and discard the octet.
                uartRead <= '1';
                rxStateCounter <= "00";
              end if;
            else
              -- Waiting for inbound data.
              -- Dont do anything.
            end if;
          end if;
          
        when others =>
          -------------------------------------------------------------------
          -- Unknown state.
          -------------------------------------------------------------------
          null;
          
      end case;
    end if;
  end process;
  
end architecture;
