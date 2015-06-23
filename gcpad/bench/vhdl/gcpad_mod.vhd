-------------------------------------------------------------------------------
--
-- A testbench model for the
-- GCpad controller core
--
-- $Id: gcpad_mod.vhd 41 2009-04-01 19:58:04Z arniml $
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

entity gcpad_mod is

  generic (
    clocks_per_1us_g :       natural := 2
  );
  port (
    clk_i            : in    std_logic;
    pad_data_io      : inout std_logic;
    rx_data_i        : in    std_logic_vector(63 downto 0)
  );

end gcpad_mod;


architecture behav of gcpad_mod is

  -----------------------------------------------------------------------------
  -- Procedure wait_n_us
  --
  -- Purpose:
  --   Waits for the given number of clk_i cycles.
  --
  procedure wait_n_us(clocks : in natural) is
  begin
    wait until clk_i = '0';
    for i in 1 to clocks loop
      wait until clk_i = '1';
      wait until clk_i = '0';
    end loop;
  end wait_n_us;
  --
  -----------------------------------------------------------------------------

  signal time_cnt_q : natural;
  signal timeout_s  : boolean;

begin

  -----------------------------------------------------------------------------
  -- Process timeout
  --
  -- Purpose:
  --   Detects a timeout on incoming pad data stream after 5 us of
  --   inactivity. Resynchronizes upon falling edge of pad_data_io.
  --
  timeout: process (clk_i, pad_data_io)
  begin
    if pad_data_io = '0' then
      timeout_s  <= false;
      time_cnt_q <= 0;
    elsif clk_i'event and clk_i = '1' then
      time_cnt_q <= time_cnt_q + 1;

      if time_cnt_q > 5 * clocks_per_1us_g then
        timeout_s <= true;
      else
        timeout_s <= false;
      end if;
    end if;
  end process timeout;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process model
  --
  -- Purpose:
  --   Simple model for the functionality of a GC controller pad.
  --
  model: process

    procedure send_packet(packet : in std_logic_vector) is
      variable time_low_v, time_high_v : time;
    begin
      for i in packet'high downto 0 loop
        if packet(i) = '0' then
          time_low_v  := 3 us;
          time_high_v := 1 us;
        else
          time_low_v  := 1 us;
          time_high_v := 3 us;
        end if;

        pad_data_io <= '0';
        wait for time_low_v;

        pad_data_io <= 'H';
        wait for time_high_v;

      end loop;

    end send_packet;


    variable command_v : std_logic_vector(24 downto 0);
    constant id_c      : std_logic_vector(23 downto 0) := "000010010000000000000000";
  begin

    loop
      command_v   := (others => '1');
      pad_data_io <= 'Z';

      -------------------------------------------------------------------------
      -- Step 1:
      -- Receive command and associated data.
      --
      wait until pad_data_io = '0';
      wait for 1 ns;
      for i in 24 downto 0 loop
        -- skip rest if timeout occured
        if not timeout_s then
          wait_n_us(2 * clocks_per_1us_g);

          command_v(i) := pad_data_io;

          if pad_data_io = '0' then
            wait until pad_data_io /= '0';
          end if;

          -- wait for high -> low edge
          wait until (pad_data_io = '0') or timeout_s;

        end if;

        wait for 1 ns;
      end loop;

      -------------------------------------------------------------------------
      -- Detect command and send response
      --
      case command_v(24 downto 17) is
        -- get ID
        when "00000000" =>
          wait_n_us(5 * clocks_per_1us_g);
          send_packet(id_c);
          send_packet("1");

        -- poll status
        when "0H000000" =>
          wait_n_us(5 * clocks_per_1us_g);
          send_packet(rx_data_i);
          send_packet("1");

        when others =>
          null;

      end case;

    end loop;
  end process model;
  --
  -----------------------------------------------------------------------------

end behav;
