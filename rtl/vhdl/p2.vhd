-------------------------------------------------------------------------------
--
-- The Port 2 unit.
-- Implements the Port 2 logic.
--
-- $Id: p2.vhd 295 2009-04-01 19:32:48Z arniml $
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
--      http://www.opencores.org/cvsweb.shtml/t48/
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.t48_pack.word_t;
use work.t48_pack.nibble_t;

entity t48_p2 is

  port (
    -- Global Interface -------------------------------------------------------
    clk_i         : in  std_logic;
    res_i         : in  std_logic;
    en_clk_i      : in  boolean;
    xtal_i        : in  std_logic;
    xtal_en_i     : in  boolean;
    -- T48 Bus Interface ------------------------------------------------------
    data_i        : in  word_t;
    data_o        : out word_t;
    write_p2_i    : in  boolean;
    write_exp_i   : in  boolean;
    read_p2_i     : in  boolean;
    read_reg_i    : in  boolean;
    read_exp_i    : in  boolean;
    -- Port 2 Interface -------------------------------------------------------
    output_pch_i  : in  boolean;
    pch_i         : in  nibble_t;
    p2_i          : in  word_t;
    p2_o          : out word_t;
    p2l_low_imp_o : out std_logic;
    p2h_low_imp_o : out std_logic
  );

end t48_p2;


use work.t48_pack.clk_active_c;
use work.t48_pack.res_active_c;
use work.t48_pack.bus_idle_level_c;

architecture rtl of t48_p2 is

  -- the port output register
  signal p2_q   : word_t;

  -- the low impedance markers
  signal l_low_imp_q,
         h_low_imp_q      : std_logic;

  signal en_clk_q         : boolean;
  signal l_low_imp_del_q,
         h_low_imp_del_q  : std_logic;
  signal output_pch_q     : boolean;

begin

  -----------------------------------------------------------------------------
  -- Process p2_regs
  --
  -- Purpose:
  --   Implements the port output and expander registers.
  --
  p2_regs: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      p2_q          <= (others => '1');
      l_low_imp_q   <= '0';
      h_low_imp_q   <= '0';

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then
        -- default: reset low impedance marker
        l_low_imp_q <= '0';
        h_low_imp_q <= '0';

        if write_p2_i then
          -- write whole P2
          p2_q        <= data_i;
          l_low_imp_q <= '1';
          h_low_imp_q <= '1';

        elsif write_exp_i then
          -- write lower nibble of P2
          p2_q(nibble_t'range) <= data_i(nibble_t'range);
          l_low_imp_q          <= '1';

        end if;

      end if;

    end if;

  end process p2_regs;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process p2_port
  --
  -- Purpose:
  --   Generates the output byte vector for Port 2.
  --   It is a synchronous process clocked with XTAL. This ensures that
  --   P2 data and low impedance markers are free of glitches and stabilize
  --   during the same clock/machine state.
  --   On the other hand, P2 is delayed by 1 XTAL cycle.
  --
  p2_port: process (res_i, xtal_i)
  begin
    if res_i = res_active_c then
      p2_o            <= (others => '1');
      l_low_imp_del_q <= '0';
      h_low_imp_del_q <= '0';
      output_pch_q    <= false;
      en_clk_q        <= false;

    elsif xtal_i'event and xtal_i = clk_active_c then
      if xtal_en_i then
        -- delay clock enable by one XTAL period
        en_clk_q               <= en_clk_i;

        p2_o                   <= p2_q;
        output_pch_q           <= output_pch_i;

        if output_pch_i then
          p2_o(nibble_t'range) <= pch_i;
        end if;

        -- generate low impedance trigger for one XTAL clock period after
        -- global clock enable when
        -- a) switching to or from PCH
        -- b) l_low_imp_q is active
        if en_clk_q and
          ((output_pch_q xor output_pch_i) or
           l_low_imp_q = '1') then
          l_low_imp_del_q <= '1';
        else
          l_low_imp_del_q <= '0';
        end if;

        -- generate low impedance trigger for on XTAL clock period after
        -- global clock enable when
        -- h_low_imp_q is active
        if en_clk_q and
          h_low_imp_q = '1' then
          h_low_imp_del_q <= '1';
        else
          h_low_imp_del_q <= '0';
        end if;

      end if;
    end if;
  end process p2_port;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process p2_data
  --
  -- Purpose:
  --   Generates the T48 bus data.
  --
  p2_data: process (read_p2_i,
                    p2_i,
                    read_reg_i,
                    p2_q,
                    read_exp_i)
  begin
    data_o   <= (others => bus_idle_level_c);

    if read_p2_i then
      if read_reg_i then
        data_o <= p2_q;
      elsif read_exp_i then
        data_o <= "0000" & p2_i(nibble_t'range);
      else
        data_o <= p2_i;
      end if;
    end if;

  end process p2_data;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output Mapping.
  -----------------------------------------------------------------------------
  p2l_low_imp_o <= l_low_imp_del_q;
  p2h_low_imp_o <= h_low_imp_del_q;

end rtl;
