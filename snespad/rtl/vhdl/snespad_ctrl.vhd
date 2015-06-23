-------------------------------------------------------------------------------
--
-- SNESpad controller core
--
-- $Id: snespad_ctrl.vhd 41 2009-04-01 19:58:04Z arniml $
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

entity snespad_ctrl is

  generic (
    reset_level_g    :     natural := 0;
    clocks_per_6us_g :     natural := 6
  );
  port (
    -- System Interface -------------------------------------------------------
    clk_i            : in  std_logic;
    reset_i          : in  std_logic;
    clk_en_o         : out boolean;
    -- Control Interface ------------------------------------------------------
    shift_buttons_o  : out boolean;
    save_buttons_o   : out boolean;
    -- Pad Interface ----------------------------------------------------------
    pad_clk_o        : out std_logic;
    pad_latch_o      : out std_logic
  );

end snespad_ctrl;


use work.snespad_pack.all;

architecture rtl of snespad_ctrl is

  subtype  clocks_per_6us_t is natural range 0 to clocks_per_6us_g;

  type state_t is (IDLE,
                   IDLE2,
                   LATCH,
                   READ_PAD);

  signal pad_latch_q,
         pad_latch_s  : std_logic;

  signal pad_clk_q,
         pad_clk_s  : std_logic;

  signal num_buttons_read_q : num_buttons_read_t;
  signal clocks_per_6us_q : clocks_per_6us_t;

  signal state_q,
         state_s  : state_t;

  signal clk_en_s        : boolean;
  signal shift_buttons_s : boolean;

begin

  -- pragma translate_off
  -----------------------------------------------------------------------------
  -- Check generics
  -----------------------------------------------------------------------------
  assert (reset_level_g = 0) or (reset_level_g = 1)
    report "reset_level_g must be either 0 or 1!"
    severity failure;

  assert clocks_per_6us_g > 1
    report "clocks_per_6us_g must be at least 2!"
    severity failure;
  -- pragma translate_on


  seq: process (reset_i, clk_i)
  begin
    if reset_i = reset_level_g then
      pad_latch_q <= '1';
      pad_clk_q   <= '1';

      num_buttons_read_q <= num_buttons_c-1;

      clocks_per_6us_q  <= 0;

      state_q     <= IDLE;

    elsif clk_i'event and clk_i = '1' then
      if clk_en_s then
        clocks_per_6us_q <= 0;
      else
        clocks_per_6us_q <= clocks_per_6us_q + 1;
      end if;

      if clk_en_s and shift_buttons_s then
        if num_buttons_read_q = 0 then
          num_buttons_read_q <= num_buttons_c-1;
        else
          num_buttons_read_q <= num_buttons_read_q - 1;
        end if;
      end if;

      if clk_en_s then
        state_q <= state_s;
      end if;

      pad_clk_q   <= pad_clk_s;

      pad_latch_q <= pad_latch_s;

    end if;
  end process;

  clk_en_s <=  clocks_per_6us_q = clocks_per_6us_g-1;


  fsm: process (state_q,
                num_buttons_read_q)
  begin
    -- default assignments
    pad_clk_s       <= '1';
    pad_latch_s     <= '1';
    shift_buttons_s <= false;
    save_buttons_o  <= false;
    state_s         <= IDLE;

    case state_q is
      when IDLE =>
        save_buttons_o <= true;
        state_s        <= IDLE2;

      when IDLE2 =>
        state_s <= LATCH;

      when LATCH =>
        pad_latch_s <= '0';
        state_s     <= READ_PAD;

      when READ_PAD =>
        pad_latch_s <= '0';
        -- set clock low
        -- pad data will be read at end of 6us cycle
        pad_clk_s   <= '0';

        shift_buttons_s <= true;

        if num_buttons_read_q = 0 then
          -- return to IDLE after last button bit has been read
          state_s <= IDLE;
        else
          state_s <= LATCH;
        end if;

      when others =>
        null;

    end case;

  end process fsm;


  -----------------------------------------------------------------------------
  -- Output Mapping
  -----------------------------------------------------------------------------
  clk_en_o        <= clk_en_s;
  shift_buttons_o <= shift_buttons_s;
  pad_clk_o       <= pad_clk_q;
  pad_latch_o     <= pad_latch_q;

end rtl;
