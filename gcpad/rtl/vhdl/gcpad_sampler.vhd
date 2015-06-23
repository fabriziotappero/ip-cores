-------------------------------------------------------------------------------
--
-- GCpad controller core
--
-- $Id: gcpad_sampler.vhd 41 2009-04-01 19:58:04Z arniml $
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

entity gcpad_sampler is

  generic (
    reset_level_g      :     integer := 0;
    clocks_per_1us_g   :     integer := 2
  );
  port (
    -- System Interface -------------------------------------------------------
    clk_i              : in  std_logic;
    reset_i            : in  std_logic;
    -- Control Interface ------------------------------------------------------
    wrap_sample_i      : in  boolean;
    sync_sample_i      : in  boolean;
    sample_underflow_o : out boolean;
    -- Pad Interface ----------------------------------------------------------
    pad_data_i         : in  std_logic;
    pad_data_o         : out std_logic;
    sample_o           : out std_logic
  );

end gcpad_sampler;


use work.gcpad_pack.all;

architecture rtl of gcpad_sampler is

  signal pad_data_sync_q : std_logic_vector(1 downto 0);
  signal pad_data_s      : std_logic;

  constant cnt_sample_high_c  : natural := clocks_per_1us_g * 4 - 1;
  subtype  cnt_sample_t       is natural range 0 to cnt_sample_high_c;
  signal   cnt_zeros_q        : cnt_sample_t;
  signal   cnt_ones_q         : cnt_sample_t;
  signal   sample_underflow_q : boolean;

  signal   more_ones_q    : boolean;

begin

  seq: process (reset_i, clk_i)
    variable dec_timeout_v : boolean;
  begin
    if reset_i = reset_level_g then
      cnt_zeros_q          <= cnt_sample_high_c;
      cnt_ones_q           <= cnt_sample_high_c;
      more_ones_q          <= false;
      sample_underflow_q   <= false;

      pad_data_sync_q      <= (others => '1');

    elsif clk_i'event and clk_i = '1' then
      -- synchronizer for pad data
      pad_data_sync_q(0) <= pad_data_i;
      pad_data_sync_q(1) <= pad_data_sync_q(0);

      -- sample counter
      dec_timeout_v := false;
      if sync_sample_i then
        -- explicit preload
        cnt_zeros_q     <= cnt_sample_high_c;
        cnt_ones_q      <= cnt_sample_high_c;
      else
        if cnt_zeros_q = 0 then
          if wrap_sample_i then
            cnt_zeros_q <= cnt_sample_high_c;
          end if;
          dec_timeout_v := true;
        elsif pad_data_s = '0' then
          cnt_zeros_q   <= cnt_zeros_q - 1;
        end if;

        if cnt_ones_q = 0 then
          if wrap_sample_i then
            cnt_ones_q  <= cnt_sample_high_c;
          end if;
          dec_timeout_v := true;
        elsif pad_data_s /= '0' then
          cnt_ones_q    <= cnt_ones_q - 1;
        end if;
      end if;

      if cnt_ones_q < cnt_zeros_q then
        more_ones_q <= true;
      else
        more_ones_q <= false;
      end if;

      -- detect sample underflow
      sample_underflow_q <= dec_timeout_v;

    end if;

  end process seq;

  pad_data_s <= pad_data_sync_q(1);


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  pad_data_o         <= pad_data_s;
  sample_o           <=   '1'
                        when more_ones_q else
                          '0';
  sample_underflow_o <= sample_underflow_q;

end rtl;
