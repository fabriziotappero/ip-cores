-------------------------------------------------------------------------------
--
-- GCpad controller core
--
-- $Id: gcpad_rx.vhd 41 2009-04-01 19:58:04Z arniml $
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
use work.gcpad_pack.buttons_t;

entity gcpad_rx is

  generic (
    reset_level_g    :     integer := 0;
    clocks_per_1us_g :     integer := 2
  );
  port (
    -- System Interface -------------------------------------------------------
    clk_i            : in  std_logic;
    reset_i          : in  std_logic;
    -- Control Interface ------------------------------------------------------
    rx_en_i          : in  boolean;
    rx_done_o        : out boolean;
    rx_data_ok_o     : out boolean;
    rx_size_i        : in  std_logic_vector(3 downto 0);
    -- Gamepad Interface ------------------------------------------------------
    pad_data_i       : in  std_logic;
    -- Data Interface ---------------------------------------------------------
    rx_data_o        : out buttons_t
  );

end gcpad_rx;


library ieee;
use ieee.numeric_std.all;
use work.gcpad_pack.all;

architecture rtl of gcpad_rx is

  component gcpad_sampler
    generic (
      reset_level_g      :     integer := 0;
      clocks_per_1us_g   :     integer := 2
    );
    port (
      clk_i              : in  std_logic;
      reset_i            : in  std_logic;
      wrap_sample_i      : in  boolean;
      sync_sample_i      : in  boolean;
      sample_underflow_o : out boolean;
      pad_data_i         : in  std_logic;
      pad_data_o         : out std_logic;
      sample_o           : out std_logic
    );
  end component;

  type state_t is (IDLE,
                   DETECT_TIMEOUT,
                   WAIT_FOR_1,
                   WAIT_FOR_0,
                   FINISHED);
  signal state_s,
         state_q  : state_t;

  signal buttons_q,
         shift_buttons_q : buttons_t;
  signal save_buttons_s  : boolean;
  signal shift_buttons_s : boolean;

  signal sync_sample_s   : boolean;
  signal wrap_sample_s   : boolean;

  -- timeout counter counts three sample undeflows
  constant cnt_timeout_high_c : natural := 3;
  subtype  cnt_timeout_t      is natural range 0 to cnt_timeout_high_c;
  signal   cnt_timeout_q      : cnt_timeout_t;
  signal   timeout_q          : boolean;
  signal   sync_timeout_s     : boolean;


  subtype num_buttons_read_t  is unsigned(6 downto 0);
  signal  num_buttons_read_q  : num_buttons_read_t;
  signal  all_buttons_read_s  : boolean;
  signal  reset_num_buttons_s : boolean;

  signal pad_data_s         : std_logic;
  signal sample_s           : std_logic;
  signal sample_underflow_s : boolean;

  signal rx_done_s,
         rx_done_q  : boolean;

begin

  sampler_b : gcpad_sampler
    generic map (
      reset_level_g => reset_level_g,
      clocks_per_1us_g => clocks_per_1us_g
    )
    port map (
      clk_i              => clk_i,
      reset_i            => reset_i,
      wrap_sample_i      => wrap_sample_s,
      sync_sample_i      => sync_sample_s,
      sample_underflow_o => sample_underflow_s,
      pad_data_i         => pad_data_i,
      pad_data_o         => pad_data_s,
      sample_o           => sample_s
    );

  -----------------------------------------------------------------------------
  -- Process seq
  --
  -- Purpose:
  --   Implements the sequential elements of this module.
  --
  seq: process (reset_i, clk_i)
    variable size_v : std_logic_vector(num_buttons_read_t'range);
  begin
    if reset_i = reset_level_g then
      buttons_q       <= (others => '0');
      shift_buttons_q <= (others => '0');

      state_q              <= IDLE;

      cnt_timeout_q        <= cnt_timeout_high_c;

      timeout_q            <= false;

      num_buttons_read_q   <= (others => '0');
      rx_done_q            <= false;

    elsif clk_i'event and clk_i = '1' then
      state_q   <= state_s;

      rx_done_q <= rx_done_s;

      -- timeout counter
      if sync_timeout_s then
        -- explicit preload
        cnt_timeout_q <= cnt_timeout_high_c;
        timeout_q     <= false;
      elsif cnt_timeout_q = 0 then
        -- wrap-around
        cnt_timeout_q <= cnt_timeout_high_c;
        timeout_q     <= true;
      elsif sample_underflow_s then
        -- decrement counter when sampler wraps around
        cnt_timeout_q <= cnt_timeout_q - 1;
      end if;


      -- count remaining number of buttons to read
      if shift_buttons_s then
        shift_buttons_q(buttons_t'high downto 1) <= shift_buttons_q(buttons_t'high-1 downto 0);

        if sample_s = '1' then
          shift_buttons_q(0) <= '1';
        else
          shift_buttons_q(0) <= '0';
        end if;

      end if;

      if reset_num_buttons_s then
        -- explicit preload
        size_v(num_buttons_read_t'high downto 3) := rx_size_i;
        size_v(2 downto 0)                       := (others => '0');
        num_buttons_read_q   <= unsigned(size_v);
      elsif shift_buttons_s then
        -- decrement counter when a button bit has been read
        if not all_buttons_read_s then
          num_buttons_read_q <= num_buttons_read_q - 1;
        end if;
      end if;


      -- the buttons
      if save_buttons_s then
        buttons_q <= shift_buttons_q;
      end if;

    end if;

  end process seq;
  --
  -----------------------------------------------------------------------------

  -- indicates that all buttons have been read
  all_buttons_read_s <= num_buttons_read_q = 0;


  -----------------------------------------------------------------------------
  -- Process fsm
  --
  -- Purpose:
  --   Models the controlling state machine.
  --
  fsm: process (state_q,
                rx_en_i,
                pad_data_s,
                wrap_sample_s,
                all_buttons_read_s,
                sample_underflow_s,
                timeout_q)
  begin
    sync_sample_s       <= false;
    sync_timeout_s      <= false;
    state_s             <= IDLE;
    shift_buttons_s     <= false;
    save_buttons_s      <= false;
    rx_done_s           <= false;
    reset_num_buttons_s <= false;
    wrap_sample_s       <= false;

    case state_q is
      -- IDLE -----------------------------------------------------------------
      -- The idle state.
      when IDLE =>
        if rx_en_i then
          state_s             <= DETECT_TIMEOUT;

        else
          -- keep counters synchronized when no reception is running
          sync_sample_s       <= true;
          sync_timeout_s      <= true;
          reset_num_buttons_s <= true;
          state_s             <= IDLE;

        end if;

      when DETECT_TIMEOUT =>
        state_s             <= DETECT_TIMEOUT;

        if pad_data_s = '0' then
          sync_sample_s     <= true;
          state_s           <= WAIT_FOR_1;

        else
          -- wait for timeout
          wrap_sample_s     <= true;
          if timeout_q then
            rx_done_s       <= true;
            state_s         <= IDLE;
          end if;

        end if;


      -- WAIT_FOR_1 -----------------------------------------------------------
      -- Sample counter has expired and a 0 bit has been detected.
      -- We must now wait for pad_data_s to become 1.
      -- Or abort upon timeout.
      when WAIT_FOR_1 =>
        if pad_data_s = '0' then
          if not sample_underflow_s then
            state_s       <= WAIT_FOR_1;
          else
            -- timeout while reading buttons!
            rx_done_s     <= true;
            state_s       <= IDLE;
          end if;

        else
          state_s         <= WAIT_FOR_0;
        end if;

      -- WAIT_FOR_0 -----------------------------------------------------------
      -- pad_data_s is at 1 level now and no timeout occured so far.
      -- We wait for the next 0 level on pad_data_s or abort upon timeout.
      when WAIT_FOR_0 =>
        -- wait for falling edge of pad data
        if pad_data_s = '0' then
          sync_sample_s       <= true;

          -- loop again in any case
          state_s             <= WAIT_FOR_1;
          if not all_buttons_read_s then
            shift_buttons_s   <= true;
          end if;

        else
          if sample_underflow_s then
            if all_buttons_read_s then
              -- last button was read
              -- so it's ok to timeout
              state_s         <= FINISHED;
            else
              -- timeout while reading buttons!
              rx_done_s       <= true;
              state_s         <= IDLE;
            end if;

          else
            state_s           <= WAIT_FOR_0;

          end if;

        end if;

      when FINISHED =>
        -- finally save buttons
        save_buttons_s <= true;
        rx_done_s      <= true;

      when others =>
        null;

    end case;

  end process fsm;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output Mapping
  -----------------------------------------------------------------------------
  rx_done_o    <= rx_done_q;
  rx_data_ok_o <= save_buttons_s;
  rx_data_o    <= buttons_q;


end rtl;
