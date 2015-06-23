-------------------------------------------------------------------------------
--
-- GCpad controller core
--
-- $Id: gcpad_tx.vhd 41 2009-04-01 19:58:04Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--      http://www.opencores.org/cvsweb.shtml/gamepads/
--
-- The project homepage is located at:
--      http://www.opencores.org/projects.cgi/web/gamepads/overview
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity gcpad_tx is

  generic (
    reset_level_g    :     natural := 0;
    clocks_per_1us_g :     natural := 2
  );
  port (
    -- System Interface -------------------------------------------------------
    clk_i            : in  std_logic;
    reset_i          : in  std_logic;
    -- Pad Interface ----------------------------------------------------------
    pad_data_o       : out std_logic;
    -- Control Interface ------------------------------------------------------
    tx_start_i       : in  boolean;
    tx_finished_o    : out boolean;
    tx_size_i        : in  std_logic_vector( 1 downto 0);
    tx_command_i     : in  std_logic_vector(23 downto 0)
  );

end gcpad_tx;


library ieee;
use ieee.numeric_std.all;

use work.gcpad_pack.all;

architecture rtl of gcpad_tx is

  subtype  command_t is std_logic_vector(24 downto 0);

  signal   command_q      : command_t;
  signal   load_command_s : boolean;
  signal   shift_bits_s   : boolean;

  constant cnt_long_c       : natural := clocks_per_1us_g * 4 - 1;
  constant cnt_short_c      : natural := clocks_per_1us_g * 1 - 1;
  subtype  cnt_t            is natural range 0 to cnt_long_c;
  signal   cnt_q            : cnt_t;
  signal   cnt_load_long_s  : boolean;
  signal   cnt_load_short_s : boolean;
  signal   cnt_finished_s   : boolean;

  subtype  num_bits_t      is unsigned(4 downto 0);
  signal   num_bits_q      : num_bits_t;
  signal   all_bits_sent_s : boolean;
  signal   cnt_bit_s       : boolean;

  type     state_t is (IDLE,
                       LOAD_COMMAND,
                       SEND_COMMAND_PHASE1,
                       SEND_COMMAND_PHASE2);
  signal   state_s,
           state_q  : state_t;

  signal   pad_data_s,
           pad_data_q  : std_logic;

  signal   tx_finished_s,
           tx_finished_q  : boolean;

begin

  -----------------------------------------------------------------------------
  -- Process seq
  --
  -- Purpose:
  --   Implements the sequential elements of this module.
  --
  seq: process (reset_i, clk_i)
    variable size_v : std_logic_vector(num_bits_t'range);
  begin
    if reset_i = reset_level_g then
      command_q     <= (others => '1');
      cnt_q         <= cnt_long_c;
      num_bits_q    <= (others => '0');
      pad_data_q    <= '1';
      state_q       <= IDLE;
      tx_finished_q <= false;

    elsif clk_i'event and clk_i = '1' then
      tx_finished_q <= tx_finished_s;

      -- fsm
      state_q    <= state_s;

      -- command register and bit counter
      if load_command_s then
        command_q(24 downto 1)  <= tx_command_i;
        command_q(0)            <= '1';

        -- workaround for GHDL concatenation
        size_v(num_bits_t'high downto 3) := tx_size_i;
        size_v(2 downto 0)               := (others => '0');
        num_bits_q              <= unsigned(size_v) + 1;

      else
        if shift_bits_s then
          command_q(command_t'high downto 1) <= command_q(command_t'high-1 downto 0);
        end if;

        if cnt_bit_s and not all_bits_sent_s then
          num_bits_q <= num_bits_q - 1;
        end if;

      end if;


      -- PWM counter
      if cnt_load_long_s then
        cnt_q   <= cnt_long_c;
      elsif cnt_load_short_s then
        cnt_q   <= cnt_short_c;
      else
        if not cnt_finished_s then
          cnt_q <= cnt_q - 1;
        end if;
      end if;

      -- PWM output = pad data
      pad_data_q <= pad_data_s;

    end if;

  end process seq;
  --
  -----------------------------------------------------------------------------

  -- indicates that PWM counter has finished
  cnt_finished_s  <= cnt_q = 0;
  -- indicates that all bits have been sent
  all_bits_sent_s <= num_bits_q = 0;


  -----------------------------------------------------------------------------
  -- Process fsm
  --
  -- Purpose:
  --   Models the controlling state machine.
  --
  fsm: process (state_q,
                cnt_finished_s,
                all_bits_sent_s,
                tx_start_i,
                command_q)
  begin
    -- defaul assignments
    state_s          <= IDLE;
    shift_bits_s     <= false;
    cnt_load_long_s  <= false;
    cnt_load_short_s <= false;
    pad_data_s       <= '1';
    tx_finished_s    <= false;
    load_command_s   <= false;
    cnt_bit_s        <= false;

    case state_q is
      -- IDLE -----------------------------------------------------------------
      -- The idle state.
      -- Advances when the transmitter is started
      when IDLE =>
        if tx_start_i then
          state_s <= LOAD_COMMAND;
        else
          state_s <= IDLE;
        end if;


      -- LOAD_COMMAND ---------------------------------------------------------
      -- Prepares the first and all subsequent low phases on pad_data_s.
      when LOAD_COMMAND =>
        state_s          <= SEND_COMMAND_PHASE2;
        load_command_s   <= true;

        -- start counter once to kick the loop
        cnt_load_short_s <= true;


      -- SEND_COMMAND_PHASE1 --------------------------------------------------
      -- Wait for completion of phase 1, the low phase of pad_data_s.
      -- The high phase is prepared when the PWM counter has expired.
      when SEND_COMMAND_PHASE1 =>
        state_s              <= SEND_COMMAND_PHASE1;
        pad_data_s           <= '0';

        if cnt_finished_s then
          -- initiate high phase
          pad_data_s         <= '1';
          if command_q(command_t'high) = '1' then
            cnt_load_long_s  <= true;
          else
            cnt_load_short_s <= true;
          end if;

          state_s            <= SEND_COMMAND_PHASE2;
          -- provide next bit
          shift_bits_s       <= true;

        end if;

      -- SEND_COMMAND_PHASE2 --------------------------------------------------
      -- Wait for completion of phase 2, the high phase of pad_data_s.
      -- The next low phase is prepared when the PWM counter has expired.
      -- In case all bits have been sent, the tx handshake is asserted and
      -- the FSM returns to IDLE state.
      when SEND_COMMAND_PHASE2 =>
        pad_data_s        <= '1';
        state_s           <= SEND_COMMAND_PHASE2;

        if cnt_finished_s then
          if not all_bits_sent_s then
            -- more bits to send so loop

            -- prepare low phase
            if command_q(command_t'high) = '1' then
              cnt_load_short_s <= true;
            else
              cnt_load_long_s  <= true;
            end if;

            -- decrement bit counter
            cnt_bit_s     <= true;

            state_s       <= SEND_COMMAND_PHASE1;

          else
            -- all bits sent, we're finished
            tx_finished_s <= true;
            state_s       <= IDLE;

          end if;

        end if;

      when others =>
        null;

    end case;

  end process fsm;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  tx_finished_o <= tx_finished_q;
  pad_data_o    <= pad_data_q;

end rtl;
