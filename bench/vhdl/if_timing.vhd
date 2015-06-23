-------------------------------------------------------------------------------
--
-- Interface Timing Checker.
--
-- $Id: if_timing.vhd 295 2009-04-01 19:32:48Z arniml $
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

entity if_timing is

  port (
    xtal_i   : in std_logic;
    ale_i    : in std_logic;
    psen_n_i : in std_logic;
    rd_n_i   : in std_logic;
    wr_n_i   : in std_logic;
    prog_n_i : in std_logic;
    db_bus_i : in std_logic_vector(7 downto 0);
    p2_i     : in std_logic_vector(7 downto 0)
  );

end if_timing;



architecture behav of if_timing is

  signal last_xtal_rise_s    : time;
  signal period_s            : time;

  signal last_ale_rise_s,
         last_ale_fall_s     : time;

  signal last_psen_n_rise_s,
         last_psen_n_fall_s  : time;

  signal last_rd_n_rise_s,
         last_rd_n_fall_s    : time;

  signal last_wr_n_rise_s,
         last_wr_n_fall_s    : time;

  signal last_prog_n_rise_s,
         last_prog_n_fall_s  : time;

  signal last_bus_change_s,
         bus_change_ale_s    : time;
  signal last_p2_change_s    : time;

  signal t_CY                : time;

begin

  t_CY <= 15 * period_s;

  -----------------------------------------------------------------------------
  -- Check RD
  --
  rd_check: process (rd_n_i)
  begin
    case rd_n_i is
      -- RD active
      when '0' =>
        -- tLAFC1: ALE to Control RD
        assert (now - last_ale_fall_s) > (t_CY / 5 - 75 ns)
          report "Timing violation of tLAFC1 on RD!"
          severity error;

        -- tAFC1: Addr Float to RD
        assert (now - last_bus_change_s) > (t_CY * 2/15 - 40 ns)
          report "Timing violation of tAFC1 on RD!"
          severity error;

        -- RD inactive
      when '1' =>
        -- tCC1: Control Pulse Width RD
        assert (now - last_rd_n_fall_s) > (t_CY / 2 - 200 ns)
          report "Timing violation of tCC1 on RD!"
          severity error;

      when others =>
        null;
    end case;

  end process rd_check;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Check WR
  --
  wr_check: process (wr_n_i)
  begin
    case wr_n_i is
      -- WR active
      when '0' =>
        -- tLAFC1: ALE to Control WR
        assert (now - last_ale_fall_s) > (t_CY / 5 - 75 ns)
          report "Timing violation of tLAFC1 on WR!"
          severity error;

        -- tAW: Addr Setup to WR
        assert (now - bus_change_ale_s) > (t_CY / 3 - 150 ns)
          report "Timing violation of tAW on WR!"
          severity error;

        -- WR inactive
      when '1' =>
        -- tCC1: Control Pulse Width WR
        assert (now - last_wr_n_fall_s) > (t_CY / 2 - 200 ns)
          report "Timing violation of tCC1 on WR!"
          severity error;

        -- tDW: Data Setup before WR
        assert (now - last_bus_change_s) > (t_CY * 13/30 - 200 ns)
          report "Timing violation of tDW on WR!"
          severity error;

      when others =>
        null;
    end case;

  end process wr_check;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Check BUS
  --
  bus_check: process (db_bus_i)
  begin
    -- RD access
    -- tAD1 and tRD1 are not checked as they are constraints for the
    -- external memory, not the t48!

    -- WR access
    if wr_n_i = '0' then
      -- tDW: Data Hold after WR
      assert (now - last_wr_n_rise_s) > (t_CY / 15 - 50 ns)
        report "Timing violation of tDW on BUS vs. WR!"
        severity error;

    end if;

    -- Address strobe
    if ale_i = '0' then
      -- tLA: Addr Hold from ALE
      assert (now - last_ale_fall_s) > (t_CY / 15 - 40 ns)
        report "Timing violation of tLA on BUS vs. ALE!"
        severity error;
    end if;

    -- PSEN
    if psen_n_i = '0' then
      -- tRD2: PSEN to Data In
      assert (now - last_psen_n_fall_s) < (t_CY * 4/15 - 170 ns)
        report "Timing violation of tRD2 on BUS vs. PSEN!"
        severity error;
    end if;

  end process bus_check;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Check ALE
  --
  ale_check: process (ale_i)
    variable t_CA1 : time;
    variable t_AL  : time;
  begin
    case ale_i is
      when '0' =>
        t_AL := t_CY * 2/15 - 110 ns;

        -- tAL: Addr Setup to ALE
        assert (now - last_bus_change_s) > t_AL
          report "Timing violation of tAL on BUS vs. ALE!"
          severity error;
        assert (now - last_p2_change_s) > t_AL
          report "Timing violation of tAL on P2 vs. ALE!"
          severity error;

      when '1' =>
        -- tCA1: Control to ALE (RD, WR, PROG)
        t_CA1 := t_CY / 15 - 40 ns;

        assert (now - last_rd_n_rise_s) > t_CA1
          report "Timing violation of tCA1 on RD vs. ALE!"
          severity error;
        assert (now - last_wr_n_rise_s) > t_CA1
          report "Timing violation of tCA1 on WR vs. ALE!"
          severity error;
        assert (now - last_prog_n_rise_s) > t_CA1
          report "Timing violation of tCA1 on PROG vs. ALE!"
          severity error;

        -- tCA2: Control to ALE (PSEN)
        assert (now - last_psen_n_rise_s) > (t_CY * 4/15 - 40 ns)
          report "Timing violation of tCA2 on PSEN vs. ALE!"
          severity error;

        -- tPL: Port 2 I/O Setup to ALE
        assert (now - last_p2_change_s) > (t_CY * 4/15 - 200 ns)
          report "Timing violation of tPL on P2 vs. ALE!"
          severity error;

      when others =>
        null;

    end case;

  end process ale_check;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Check P2
  --
  p2_check: process (p2_i)
  begin
    case ale_i is
      when '0' =>
        -- tLA: Addr Hold from ALE
        assert ((now - last_ale_fall_s) > (t_CY / 15 - 40 ns)) or
               now = 0 ns
          report "Timing violation of tLA on P2 vs. ALE!"
          severity error;

        if last_ale_fall_s < last_ale_rise_s then
          -- tPV: Port Output from ALE
          assert (now - last_ale_fall_s) < (t_CY * 3/10 + 100 ns)
            report "Timing violation of tPV on P2 vs. ALE!"
            severity error;
        end if;

        if prog_n_i = '1' then
          -- tPD: Output Data Hold
          assert ((now - last_prog_n_rise_s) > (t_CY / 10 - 50 ns)) or
                 now = 0 ns
            report "Timing violation of tPD on P2 vs. PROG!"
            severity error;

        end if;

      when '1' =>
        -- tLP: Port 2 I/O to ALE
        assert (now - last_ale_rise_s) > (t_CY / 30 - 30 ns)
          report "Timing violation of tLP on P2 vs. ALE!"
          severity error;

      when others =>
        null;

    end case;

  end process p2_check;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Check PROG
  --
  prog_check: process (prog_n_i)
  begin
    case prog_n_i is
      when '0' =>
        -- tCP: Port Control Setup to PROG'
        assert (now - last_p2_change_s) > (t_CY * 2/15 - 80 ns)
          report "Timing violation of tCP on P2 vs PROG'!"
          severity error;

      when '1' =>
        -- tPP: PROG Pulse Width
        assert (now - last_prog_n_fall_s) > (t_CY * 7/10 - 250 ns)
          report "Timing violation of tPP!"
          severity error;

        -- tDP: Output Data Setup
        assert (now - last_p2_change_s) > (t_CY * 2/5 - 150 ns)
          report "Timing violation of tDP on P2 vs. PROG!"
          severity error;

      when others =>
        null;
    end case;

  end process prog_check;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Check PSEN
  --
  psen_check: process (psen_n_i)
  begin
    case psen_n_i is
      when '1' =>
        -- tCC2: Control Pulse Width PSEN
        assert (now - last_psen_n_fall_s) > (t_CY * 2/5 - 200 ns)
          report "Timing violation of tCC2 on PSEN!"
          severity error;

      when '0' => 
        -- tLAFC2: ALE to Control PSEN
        assert (now - last_ale_fall_s) > (t_CY / 10 - 75 ns)
          report "Timing violation of tLAFC2 on PSEN vs. ALE!"
          severity error;

      when others =>
        null;

    end case;

  end process psen_check;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Check cycle overlap
  --
  cycle_overlap_check: process (psen_n_i,
                                rd_n_i,
                                wr_n_i)
    variable tmp_v : std_logic_vector(2 downto 0);
  begin
    tmp_v := psen_n_i & rd_n_i & wr_n_i;
    case tmp_v is
      when "001" |
           "010" |
           "100" |
           "000" =>
        assert false
          report "Cycle overlap deteced on PSEN, RD and WR!"
          severity error;
      when others =>
        null;

    end case;

  end process cycle_overlap_check;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Monitor XTAL
  --
  xtal_mon: process
  begin
    last_xtal_rise_s     <= 0 ns;
    period_s             <= 90 ns;

    while true loop
      wait on xtal_i;

      if xtal_i = '1' then
        period_s         <= now - last_xtal_rise_s;
        last_xtal_rise_s <= now;
      end if;

    end loop;

  end process xtal_mon;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Monitor ALE
  --
  ale_mon: process
  begin
    last_ale_rise_s       <= 0 ns;
    last_ale_fall_s       <= 0 ns;

    while true loop
      wait on ale_i;

      case ale_i is
        when '0' =>
          last_ale_fall_s <= now;
        when '1' =>
          last_ale_rise_s <= now;
        when others =>
          null;
      end case;

    end loop;

  end process ale_mon;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Monitor PSEN
  --
  psen_mon: process
  begin
    last_psen_n_rise_s       <= 0 ns;
    last_psen_n_fall_s       <= 0 ns;

    while true loop
      wait on psen_n_i;

      case psen_n_i is
        when '0' =>
          last_psen_n_fall_s <= now;
        when '1' =>
          last_psen_n_rise_s <= now;
        when others =>
          null;
      end case;

    end loop;

  end process psen_mon;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Monitor RD
  --
  rd_mon: process
  begin
    last_rd_n_rise_s       <= 0 ns;
    last_rd_n_fall_s       <= 0 ns;

    while true loop
      wait on rd_n_i;

      case rd_n_i is
        when '0' =>
          last_rd_n_fall_s <= now;
        when '1' =>
          last_rd_n_rise_s <= now;
        when others =>
          null;
      end case;

    end loop;

  end process rd_mon;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Monitor WR
  --
  wr_mon: process
  begin
    last_wr_n_rise_s       <= 0 ns;
    last_wr_n_fall_s       <= 0 ns;

    while true loop
      wait on wr_n_i;

      case wr_n_i is
        when '0' =>
          last_wr_n_fall_s <= now;
        when '1' =>
          last_wr_n_rise_s <= now;
        when others =>
          null;
      end case;

    end loop;

  end process wr_mon;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Monitor PROG
  --
  prog_mon: process
  begin
    last_prog_n_rise_s       <= 0 ns;
    last_prog_n_fall_s       <= 0 ns;

    while true loop
      wait on prog_n_i;

      case prog_n_i is
        when '0' =>
          last_prog_n_fall_s <= now;
        when '1' =>
          last_prog_n_rise_s <= now;
        when others =>
          null;
      end case;

    end loop;

  end process prog_mon;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Monitor BUS
  --
  bus_mon: process
  begin
    last_bus_change_s    <= 0 ns;
    bus_change_ale_s     <= 0 ns;

    while true loop
      wait on db_bus_i;

      last_bus_change_s  <= now;

      if ale_i = '1' then
        bus_change_ale_s <= now;
      end if;
    end loop;

  end process bus_mon;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Monitor P2
  --
  p2_mon: process
  begin
    last_p2_change_s   <= 0 ns;

    while true loop
      wait on p2_i;

      last_p2_change_s <= now;
    end loop;

  end process p2_mon;
  --
  -----------------------------------------------------------------------------

end behav;
