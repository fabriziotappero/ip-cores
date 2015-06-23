-------------------------------------------------------------------------------
--
-- GCpad controller core
--
-- $Id: gcpad_ctrl.vhd 41 2009-04-01 19:58:04Z arniml $
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

entity gcpad_ctrl is

  generic (
    reset_level_g :     integer := 0
  );
  port (
    -- System Interface -------------------------------------------------------
    clk_i         : in  std_logic;
    reset_i       : in  std_logic;
    pad_request_i : in  std_logic;
    pad_avail_o   : out std_logic;
    rx_timeout_o  : out std_logic;
    -- Control Interface ------------------------------------------------------
    tx_start_o    : out boolean;
    tx_finished_i : in  boolean;
    rx_en_o       : out boolean;
    rx_done_i     : in  boolean;
    rx_data_ok_i  : in  boolean
  );

end gcpad_ctrl;


use work.gcpad_pack.all;

architecture rtl of gcpad_ctrl is

  type state_t is (IDLE,
                   TX,
                   RX1_START,
                   RX1_WAIT,
                   RX2_START,
                   RX2_WAIT,
                   RX3_START,
                   RX3_WAIT,
                   RX4_START,
                   RX4_WAIT);
  signal state_s,
         state_q  : state_t;

  signal set_txrx_finished_s    : boolean;
  signal enable_txrx_finished_s : boolean;
  signal txrx_finished_q        : std_logic;

  signal timeout_q : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Process seq
  --
  -- Purpose:
  --   Implements the sequential elements.
  --
  seq: process (reset_i, clk_i)
  begin
    if reset_i = reset_level_g then
      state_q         <= IDLE;

      txrx_finished_q <= '0';

      timeout_q <= '1';

    elsif clk_i'event and clk_i = '1' then
      state_q <= state_s;

      -- transmit/receive finished flag
      if set_txrx_finished_s then
        txrx_finished_q <= '1';
      elsif pad_request_i = '1' then
        txrx_finished_q <= '0';
      end if;

      if pad_request_i = '1' then
        timeout_q <= '1';
      elsif rx_data_ok_i then
        timeout_q <= '0';
      end if;

    end if;

  end process seq;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process fsm
  --
  -- Purpose:
  --   Models the controlling state machine.
  --
  fsm: process (state_q,
                tx_finished_i,
                rx_done_i,
                pad_request_i)
  begin
    rx_en_o                <= false;
    state_s                <= IDLE;
    tx_start_o             <= false;
    set_txrx_finished_s    <= false;
    enable_txrx_finished_s <= false;

    case state_q is
      when IDLE =>
        -- enable output of txrx_finished flag
        -- the flag has to be suppressed while the FSM probes four times
        enable_txrx_finished_s <= true;

        if pad_request_i = '1' then
          state_s    <= TX;
          tx_start_o <= true;
        else
          state_s    <= IDLE;
        end if;

      when TX =>
        if not tx_finished_i then
          state_s <= TX;
        else
          state_s <= RX1_START;
        end if;

      when RX1_START =>
        rx_en_o <= true;
        state_s <= RX1_WAIT;

      when RX1_WAIT =>
        if rx_done_i then
          state_s <= RX2_START;
        else
          state_s <= RX1_WAIT;
        end if;

      when RX2_START =>
        rx_en_o <= true;
        state_s <= RX2_WAIT;

      when RX2_WAIT =>
        if rx_done_i then
          state_s <= RX3_START;
        else
          state_s <= RX2_WAIT;
        end if;

      when RX3_START =>
        rx_en_o <= true;
        state_s <= RX3_WAIT;

      when RX3_WAIT =>
        if rx_done_i then
          state_s <= RX4_START;
        else
          state_s <= RX3_WAIT;
        end if;

      when RX4_START =>
        rx_en_o <= true;
        state_s <= RX4_WAIT;

      when RX4_WAIT =>
        if rx_done_i then
          state_s             <= IDLE;
          set_txrx_finished_s <= true;
        else
          state_s             <= RX4_WAIT;
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
  pad_avail_o  <=   txrx_finished_q
                  when enable_txrx_finished_s else
                    '0';
  rx_timeout_o <=   timeout_q
                  when enable_txrx_finished_s else
                    '0';

end rtl;
