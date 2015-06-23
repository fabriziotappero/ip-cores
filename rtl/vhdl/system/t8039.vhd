-------------------------------------------------------------------------------
--
-- T8039 Microcontroller System
--
-- $Id: t8039.vhd 295 2009-04-01 19:32:48Z arniml $
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

entity t8039 is

  port (
    xtal_i    : in    std_logic;
    reset_n_i : in    std_logic;
    t0_b      : inout std_logic;
    int_n_i   : in    std_logic;
    ea_i      : in    std_logic;
    rd_n_o    : out   std_logic;
    psen_n_o  : out   std_logic;
    wr_n_o    : out   std_logic;
    ale_o     : out   std_logic;
    db_b      : inout std_logic_vector( 7 downto 0);
    t1_i      : in    std_logic;
    p2_b      : inout std_logic_vector( 7 downto 0);
    p1_b      : inout std_logic_vector( 7 downto 0);
    prog_n_o  : out   std_logic
  );

end t8039;


use work.t48_system_comp_pack.t8039_notri;

architecture struct of t8039 is

  signal t0_s             : std_logic;
  signal t0_dir_s         : std_logic;
  signal db_s             : std_logic_vector( 7 downto 0);
  signal db_dir_s         : std_logic;
  signal p2_s             : std_logic_vector( 7 downto 0);
  signal p2l_low_imp_s    : std_logic;
  signal p2h_low_imp_s    : std_logic;
  signal p1_s             : std_logic_vector( 7 downto 0);
  signal p1_low_imp_s     : std_logic;

  signal vdd_s            : std_logic;

begin

  vdd_s <= '1';

  t8039_notri_b : t8039_notri
    generic map (
      -- we don't need explicit gating of input ports
      -- this is done implicitely by the bidirectional pads
      gate_port_input_g => 0
    )

    port map (
      xtal_i        => xtal_i,
      xtal_en_i     => vdd_s,
      reset_n_i     => reset_n_i,
      t0_i          => t0_b,
      t0_o          => t0_s,
      t0_dir_o      => t0_dir_s,
      int_n_i       => int_n_i,
      ea_i          => ea_i,
      rd_n_o        => rd_n_o,
      psen_n_o      => psen_n_o,
      wr_n_o        => wr_n_o,
      ale_o         => ale_o,
      db_i          => db_b,
      db_o          => db_s,
      db_dir_o      => db_dir_s,
      t1_i          => t1_i,
      p2_i          => p2_b,
      p2_o          => p2_s,
      p2l_low_imp_o => p2l_low_imp_s,
      p2h_low_imp_o => p2h_low_imp_s,
      p1_i          => p1_b,
      p1_o          => p1_s,
      p1_low_imp_o  => p1_low_imp_s,
      prog_n_o      => prog_n_o
    );

  -----------------------------------------------------------------------------
  -- Process bidirs
  --
  -- Purpose:
  --   Assign bidirectional signals.
  --
  bidirs: process (t0_b, t0_s, t0_dir_s,
                   db_b, db_s, db_dir_s,
                   p1_b, p1_s, p1_low_imp_s,
                   p2_b, p2_s, p2l_low_imp_s, p2h_low_imp_s)

    function port_bidir_f(port_value : in std_logic_vector;
                          low_imp    : in std_logic) return std_logic_vector is
      variable result_v : std_logic_vector(port_value'range);
    begin
      for idx in port_value'high downto port_value'low loop
        if low_imp = '1' then
          result_v(idx) := port_value(idx);
        elsif port_value(idx) = '0' then
          result_v(idx) := '0';
        else
          result_v(idx) := 'Z';
        end if;
      end loop;

      return result_v;
    end;

  begin
    -- Test 0 -----------------------------------------------------------------
    if t0_dir_s = '1' then
      t0_b <= t0_s;
    else
      t0_b <= 'Z';
    end if;

    -- Data Bus ---------------------------------------------------------------
    if db_dir_s = '1' then
      db_b <= db_s;
    else
      db_b <= (others => 'Z');
    end if;

    -- Port 1 -----------------------------------------------------------------
    p1_b <= port_bidir_f(port_value => p1_s,
                         low_imp => p1_low_imp_s);

    -- Port 2 -----------------------------------------------------------------
    p2_b(3 downto 0) <= port_bidir_f(port_value => p2_s(3 downto 0),
                                     low_imp    => p2l_low_imp_s);
    p2_b(7 downto 4) <= port_bidir_f(port_value => p2_s(7 downto 4),
                                     low_imp    => p2h_low_imp_s);

  end process bidirs;
  --
  -----------------------------------------------------------------------------

end struct;
