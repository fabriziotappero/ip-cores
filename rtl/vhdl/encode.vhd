--*************************************************************************
--*                                                                       *
--* Copyright (C) 2014 William B Hunter - LGPL                            *
--*                                                                       *
--* This source file may be used and distributed without                  *
--* restriction provided that this copyright statement is not             *
--* removed from the file and that any derivative work contains           *
--* the original copyright notice and the associated disclaimer.          *
--*                                                                       *
--* This source file is free software; you can redistribute it            *
--* and/or modify it under the terms of the GNU Lesser General            *
--* Public License as published by the Free Software Foundation;          *
--* either version 2.1 of the License, or (at your option) any            *
--* later version.                                                        *
--*                                                                       *
--* This source is distributed in the hope that it will be                *
--* useful, but WITHout ANY WARRANTY; without even the implied            *
--* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               *
--* PURPOSE.  See the GNU Lesser General Public License for more          *
--* details.                                                              *
--*                                                                       *
--* You should have received a copy of the GNU Lesser General             *
--* Public License along with this source; if not, download it            *
--* from http://www.opencores.org/lgpl.shtml                              *
--*                                                                       *
--*************************************************************************
--
-- Engineer: William B Hunter
-- Create Date: 08/08/2014
-- Project: Manchester Uart
-- File: encode.vhd
-- Description: This encoder sends out short bursts of 16 bit data words encoded with as manchester data.
--   Because this is not a stream encoder, it has no sync pattern or packet alignment typical of manchester encoders.
--   It therefor uses start and stop bits much like a UART. Both the start and stop bits are always ones. The idle 
--   state is always high, and the ones are a low to high transition in the middle of the bit period, and a zero is a 
--   high to low transition in the middle of the bit period. A high for 3 bit periods is a reset/resync.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity encode is
  Port (
    clk16x : in STD_LOGIC;
    srst : in STD_LOGIC;
    tx_data : in STD_LOGIC_VECTOR (15 downto 0);
    tx_stb : in STD_LOGIC;
    txd : out STD_LOGIC;
    or_err : out STD_LOGIC;
    tx_idle : out STD_LOGIC
  );
end encode;

architecture rtl of encode is
  signal shifter : std_logic_vector(15 downto 0);
  signal tick_cnt : integer range 0 to 15 := 0;
  signal bit_cnt : integer range 0 to 15 := 0;
  signal txd_int : std_logic := '1';
  signal err_int : std_logic := '0';

  type txr_state_type is (SM_IDLE, SM_START, SM_SEND, SM_STOP);
  signal txr_state : txr_state_type := SM_IDLE;

begin

  p_transmitter: process(clk16x)
  begin
    if rising_edge(clk16x) then
      if srst = '1' then
         txr_state <= SM_IDLE;
         tick_cnt <= 0;
         bit_cnt <= 0;
      else
        case txr_state is
          --wait for a tx strobe to start a transmission
          when SM_IDLE =>
            tick_cnt <=  0;
            bit_cnt <=  0;
            if tx_stb = '1' then
              txr_state <= SM_START;
              shifter <= tx_data;
            end if;
          --the start is a one, which is 8 ticks low followed by 8 ticks high
          when SM_START =>
            if tick_cnt < 8 then
              txd_int <= '0';
              tick_cnt <= tick_cnt + 1;
            elsif  tick_cnt < 15 then
              txd_int <= '1';
              tick_cnt <= tick_cnt + 1;
            else
              txd_int <= '1';
              tick_cnt <= 0;
              bit_cnt <= 0;
              txr_state <= SM_SEND;
            end if;
          when SM_SEND =>
            --for each bit, a one is 8 ticks low followed by 8 ticks high, and a zero is 8 ticks high followed by 8 ticks low
            if tick_cnt < 8 then
              txd_int <= not shifter(15);
              tick_cnt <= tick_cnt + 1;
            elsif  tick_cnt < 15 then
              txd_int <= shifter(15);
              tick_cnt <= tick_cnt + 1;
            else
              txd_int <= shifter(15);
              tick_cnt <= 0;
              shifter <= shifter(14 downto 0) & '1';
              --at end of this bit check to see if we have more bits or if it's time for the stop bit
              if bit_cnt < 15 then
                bit_cnt <= bit_cnt + 1;
              else
                bit_cnt <=0;
                txr_state <= SM_STOP;
              end if;
            end if;    
          when SM_STOP =>
            --stop bits are always ones, which are 8 ticks low followed by 8 ticks high
            if tick_cnt < 8 then
              txd_int <= '0';
              tick_cnt <= tick_cnt + 1;
            elsif  tick_cnt < 15 then
              txd_int <= '1';
              tick_cnt <= tick_cnt + 1;
            else
              txd_int <= '1';
              tick_cnt <= 0;
              txr_state <= SM_IDLE;
            end if;
          --we should never get to the iothers state.
          when others =>
            tick_cnt <= 4;
            bit_cnt <= 0;
            txr_state <= SM_IDLE;
        end case;
      end if; --srst
    end if;  --clk16x
  end process;


  --An overrun error occurs when the transmit strobe is triggered and we are not finished with the previous state.
  -- The error is cleared when the transmitter goes back to idle
  p_or_err: process(clk16x)
  begin
    if rising_edge(clk16x) then
      if srst = '1' then
        err_int <='0';
      elsif tx_stb = '1' and txr_state /= SM_IDLE then
        err_int <= '1';
      elsif txr_state = SM_IDLE then
        err_int <= '0';
      end if;
    end if;
  end process;

  txd <= txd_int;
  or_err <= err_int;
  tx_idle <= '1' when txr_state = SM_IDLE else '0';
  
end rtl;
