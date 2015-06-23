-------------------------------------------------------------------------------
--
-- The Port 1 unit.
-- Implements the Port 1 logic.
--
-- $Id: p1.vhd 295 2009-04-01 19:32:48Z arniml $
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

entity t48_p1 is

  port (
    -- Global Interface -------------------------------------------------------
    clk_i        : in  std_logic;
    res_i        : in  std_logic;
    en_clk_i     : in  boolean;
    -- T48 Bus Interface ------------------------------------------------------
    data_i       : in  word_t;
    data_o       : out word_t;
    write_p1_i   : in  boolean;
    read_p1_i    : in  boolean;
    read_reg_i   : in  boolean;
    -- Port 1 Interface -------------------------------------------------------
    p1_i         : in  word_t;
    p1_o         : out word_t;
    p1_low_imp_o : out std_logic
  );

end t48_p1;


use work.t48_pack.clk_active_c;
use work.t48_pack.res_active_c;
use work.t48_pack.bus_idle_level_c;

architecture rtl of t48_p1 is

  -- the port output register
  signal p1_q   : word_t;

  -- the low impedance marker
  signal low_imp_q : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Process p1_reg
  --
  -- Purpose:
  --   Implements the port output register.
  --
  p1_reg: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      p1_q          <= (others => '1');
      low_imp_q     <= '0';

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        if write_p1_i then
          p1_q      <= data_i;
          low_imp_q <= '1';
        else
          low_imp_q <= '0';
        end if;

      end if;

    end if;

  end process p1_reg;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process p1_data
  --
  -- Purpose:
  --   Generates the T48 bus data.
  --
  p1_data: process (read_p1_i,
                    p1_i,
                    read_reg_i,
                    p1_q)
  begin
    data_o   <= (others => bus_idle_level_c);

    if read_p1_i then
      if read_reg_i then
        data_o <= p1_q;
      else
        data_o <= p1_i;
      end if;
    end if;

  end process p1_data;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output Mapping.
  -----------------------------------------------------------------------------
  p1_o         <= p1_q;
  p1_low_imp_o <= low_imp_q;

end rtl;
