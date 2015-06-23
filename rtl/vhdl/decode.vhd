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
-- File: decode.vhd
-- Description: This decoder recieves short bursts of 16 bit data words encoded with as manchester data.
--   Because this is not a stream decoder, it has no sync pattern or packet alignment typical of manchester decoders.
--   It therefore uses start and stop bits much like a UART. Both the start and stop bits are always ones. The idle 
--   state is always high, and the ones are a low to high transition in the middle of the bit period, and a zero is a 
--   high to low transition in the middle of the bit period. A high for 3 bit periods is a reset/resync.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decode is
  Port(
    clk16x : in STD_LOGIC;
    srst : in STD_LOGIC;
    rxd : in STD_LOGIC;
    rx_data : out STD_LOGIC_VECTOR (15 downto 0);
    rx_stb : out STD_LOGIC;
    fm_err : out STD_LOGIC;
    rx_idle : out STD_LOGIC
  );
end decode;

architecture rtl of decode is
  signal shifter : std_logic_vector(15 downto 0);
  signal tick_cnt : integer range 0 to 31 := 0;
  signal bit_cnt : integer range 0 to 15 := 0;
  signal rcv_stb : std_logic := '0';
  signal debounce : std_logic_vector(3 downto 0) := (others=>'1');
  signal filt : std_logic := '1';
  signal filt_old : std_logic := '1';
  signal fall_det : std_logic := '0';
  signal rst_det : std_logic := '0';
  signal rst_cnt :integer range 0 to 15 := 0;
  signal rise_det : std_logic := '0';
  
  
  type rcv_state_type is (SM_SEEK, SM_START, SM_RCV, SM_END, SM_ERR);
  signal rcv_state : rcv_state_type := SM_SEEK;
  
begin
  --this process debounces the input signal to remove noise. It also detects rising 
  --  and falling edges and reset conditions.
  p_debounce: process(clk16x)
  begin
    if rising_edge(clk16x) then
      if srst = '1' then
        debounce <= "1111";
        rise_det <= '0';
        fall_det <= '0';
        rst_cnt <= 0;
        rst_det <= '0';
        filt_old <= '1';
      else
        if filt_old = '0' and filt = '1' then
          rise_det <= '1';
          fall_det <= '0';
        elsif filt_old = '1' and filt = '0' then
          rise_det <= '0';
          fall_det <= '1';
        else
          rise_det <= '0';
          fall_det <= '0';
        end if;
        if filt = '0' then 
          rst_cnt <= 0;
          rst_det <= '0';
        elsif rst_cnt = 47 then
          rst_det <= '1';
        else
          rst_det <= '0';
          rst_cnt <= rst_cnt +1;
        end if;
        debounce <= debounce(2 downto 0) & rxd;
        filt_old <= filt;
      end if;
    end if;
  end process;
  
  --this is the actual debounce logic. It is a basic 2 out of three majority vote
  with debounce(3 downto 1) select filt <=
    '1' when "111",
    '1' when "110",
    '1' when "101",
    '1' when "011",
    '0' when others;
        
  
  --This process is the main reciever. It detects the start bit, 16 data bits and the stop bit.
  --  it does this by having a window for which it looks for the midbit transistions. When a transition is found,
  --  it syncs on the new transition so that it can look for the next. This allows the wide variation in clock rates
  --  between the transmitter and reciever.
  p_reciever: process(clk16x)
  begin
    if rising_edge(clk16x) then
      if srst = '1' then
         rcv_state <= SM_SEEK;
         rcv_stb <= '0';
         tick_cnt <= 0;
         bit_cnt <= 0;
      else
        case rcv_state is
          --The idle state is high, so look for the leading edge of the start bit which is a falling edge
          when SM_SEEK =>
            rcv_stb <= '0';
            tick_cnt <= 0;
            bit_cnt <= 0;
            if fall_det = '1' then
              rcv_state <= SM_START;
            end if;
          --After the falling edge, there should be the mid bit rising edge of the start bit, Make sure 
          -- this appears in the right window
          when SM_START =>
              --skip the first 4 clock periods
              if tick_cnt < 4 then
                tick_cnt <= tick_cnt + 1;
              --The active window is ticks 4 to 10, look for the rising edge in this window
              elsif tick_cnt < 11 then
                --a rising edge in the window allows us to start recieveing data
                if rise_det = '1' then
                  tick_cnt <= 0;
                  rcv_state <= SM_RCV;
                --two falling edges in a row is an error
                elsif fall_det = '1' then
                  rcv_state <= SM_ERR;
                  tick_cnt <= 0;
                  bit_cnt <= 0;
                else
                  tick_cnt <= tick_cnt + 1;
                end if;
              --if there was no rising edge in the window, than error out
              else
                rcv_state <= SM_ERR;
                tick_cnt <= 0;
                bit_cnt <= 0;
              end if;
          when SM_RCV =>
            --During recieve, we only look for the mid bit transisions in the window of
            --  12 to 18 ticks from the previous mid bit transition
            if tick_cnt < 12 then
              tick_cnt <= tick_cnt + 1;
            elsif tick_cnt < 19 then
              if rise_det = '1' or fall_det = '1' then
                tick_cnt <= 0;
                shifter <= shifter(14 downto 0) & rise_det;
                if bit_cnt = 15 then
                  rcv_state <= SM_END;
                  tick_cnt <= 0;
                else
                  bit_cnt <= bit_cnt + 1;
                end if;
              else
                tick_cnt <= tick_cnt + 1;
              end if;
            else
              rcv_state <= SM_ERR;
              tick_cnt <= 0;
              bit_cnt <= 0;
            end if;
          when SM_END => 
            --after all 16 data bits, we should see a stop bit which is always 1 (rising edge)
            if tick_cnt < 12 then
              tick_cnt <= tick_cnt + 1;
            elsif tick_cnt < 19 then
              if rise_det = '1' then
                tick_cnt <= 0;
                bit_cnt <= 0;
                rcv_stb <= '1';
                rcv_state <= SM_SEEK;
              elsif fall_det  = '1' then
                rcv_state <= SM_ERR;
                tick_cnt <= 0;
                bit_cnt <= 0;
              else
                 tick_cnt <= tick_cnt + 1;
              end if;
            else
              rcv_state <= SM_ERR;
              tick_cnt <= 0;
              bit_cnt <= 0;
            end if;
          --this state handles the error conditions. The error persists until a reset condition
          --It is up to external logic to latch errors if nessesary
          when SM_ERR =>
            rcv_stb <= '0';
            tick_cnt <= 4;
            bit_cnt <= 0;
            if rst_det = '1' then
              rcv_state <= SM_SEEK;
            end if;
          --we should never get here
          when others =>
            rcv_stb <= '0';
            tick_cnt <= 4;
            bit_cnt <= 0;
            rcv_state <= SM_SEEK;
        end case;
      end if; --srst
    end if;  --clk16x
  end process;
       
  rx_idle <= '1' when rcv_state = SM_SEEK else '0';
  fm_err <= '1' when rcv_state = SM_ERR else '0';
  rx_data <= shifter;
  rx_stb <= rcv_stb;

end rtl;
