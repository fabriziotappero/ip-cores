-------------------------------------------------------------------------------
--
-- The BUS unit.
-- Implements the BUS port logic.
--
-- $Id: db_bus.vhd 295 2009-04-01 19:32:48Z arniml $
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

entity t48_db_bus is

  port (
    -- Global Interface -------------------------------------------------------
    clk_i        : in  std_logic;
    res_i        : in  std_logic;
    en_clk_i     : in  boolean;
    ea_i         : in  std_logic;
    -- T48 Bus Interface ------------------------------------------------------
    data_i       : in  word_t;
    data_o       : out word_t;
    write_bus_i  : in  boolean;
    read_bus_i   : in  boolean;
    -- BUS Interface ----------------------------------------------------------
    output_pcl_i : in  boolean;
    bidir_bus_i  : in  boolean;
    pcl_i        : in  word_t;
    db_i         : in  word_t;
    db_o         : out word_t;
    db_dir_o     : out std_logic
  );

end t48_db_bus;


use work.t48_pack.clk_active_c;
use work.t48_pack.res_active_c;
use work.t48_pack.bus_idle_level_c;
use work.t48_pack.to_stdLogic;

architecture rtl of t48_db_bus is

  -- the BUS output register
  signal bus_q    : word_t;

  -- BUS direction marker
  signal db_dir_q,
         db_dir_qq : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Process bus_regs
  --
  -- Purpose:
  --   Implements the BUS output register.
  --
  bus_regs: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      bus_q      <= (others => '0');
      db_dir_q   <= '0';
      db_dir_qq  <= '0';

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then
        if write_bus_i then
          db_dir_qq <= '1';
        else
          -- extend bus direction by one machine cycle
          db_dir_qq  <= db_dir_q;
        end if;

        if write_bus_i then
          bus_q    <= data_i;

          db_dir_q <= '1';

        elsif ea_i = '1' or bidir_bus_i then
          db_dir_q <= '0';

        end if;

      end if;

    end if;

  end process bus_regs;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output Mapping.
  -----------------------------------------------------------------------------
  db_o     <=   pcl_i
              when output_pcl_i else
                bus_q;
  db_dir_o <= db_dir_qq or
              to_stdLogic(output_pcl_i);
  data_o   <=   (others => bus_idle_level_c)
              when not read_bus_i else
                db_i;

end rtl;
