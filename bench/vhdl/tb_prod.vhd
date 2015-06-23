-------------------------------------------------------------------------------
--
-- Testbench for the production test as proposed by
--   "Testing of COP400 Familiy Devices"
--   National Semiconductor
--   COP Note 7
--   April 1991
--
-- $Id: tb_prod.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006 Arnim Laeuger (arniml@opencores.org)
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
--      http://www.opencores.org/cvsweb.shtml/t400/
--
-------------------------------------------------------------------------------

entity tb_prod is

end tb_prod;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.t400_system_comp_pack.t420;
use work.tb_pack.all;
use work.t400_opt_pack.all;

architecture behav of tb_prod is

  -- 5 MHz clock
  constant period_c : time := 200 ns;
  signal   ck_s     : std_logic;
  signal   en_ck_s  : std_logic := '0';

  signal reset_n_s  : std_logic;

  signal io_l_s     : std_logic_vector(7 downto 0);
  signal io_d_s,
         d_s        : std_logic_vector(3 downto 0);
  signal exp_d_s    : std_logic_vector(3 downto 0) := "0000";
  signal io_g_s,
         g_s        : std_logic_vector(3 downto 0);
  signal exp_g_s    : std_logic_vector(3 downto 0) := "0000";
  signal io_in_s    : std_logic_vector(3 downto 0);

  signal si_s,
         so_s,
         sk_s       : std_logic;

  signal cs_n_s,
         rd_n_s,
         wr_n_s     : std_logic;

  signal tb_io_l_s  : std_logic_vector(7 downto 0);
  signal disable_s  : boolean   := true;
  signal pass_s     : std_logic := 'L';
  signal fail_s     : std_logic := 'L';

  signal vdd4_s     : std_logic_vector(3 downto 0);

begin

  vdd4_s    <= (others => '1');
  reset_n_s <= '1';

  -----------------------------------------------------------------------------
  -- DUT
  -----------------------------------------------------------------------------
  t420_b : t420
    generic map (
      opt_ck_div_g   => t400_opt_ck_div_4_c
    )
    port map (
      ck_i      => ck_s,
      ck_en_i   => en_ck_s,
      reset_n_i => reset_n_s,
      cko_i     => io_in_s(2),
      si_i      => si_s,
      so_o      => so_s,
      sk_o      => sk_s,
      io_l_b    => io_l_s,
      io_d_o    => io_d_s,
      io_g_b    => io_g_s,
      io_in_i   => io_in_s
    );

  io_l_s  <= (others => 'H');
  io_d_s  <= (others => 'L');
  io_g_s  <= (others => 'L');
  io_in_s <= (others => 'H');

  io_in_s <= io_g_s;                    -- feedthrough for production test

  d_s     <= to_X01(io_d_s);
  g_s     <= to_X01(io_g_s);


  -----------------------------------------------------------------------------
  -- Testbench elements
  -----------------------------------------------------------------------------
  tb_elems_b : tb_elems
    generic map (
      period_g  => period_c,
      d_width_g => 4,
      g_width_g => 4
    )
    port map (
      io_l_i  => tb_io_l_s,
      io_d_i  => vdd4_s,
      io_g_i  => vdd4_s,
      io_in_o => open,
      so_i    => so_s,
      si_o    => si_s,
      sk_i    => sk_s,
      ck_o    => ck_s
    );


  -----------------------------------------------------------------------------
  -- Process ck_div
  --
  -- Purpose:
  --   Generates the en_ck_s signal from the high frequency clock.
  --
  ck_div: process (ck_s)
    variable cnt_v : natural := 0;
  begin
    if ck_s'event and ck_s = '1' then
      en_ck_s <= '0';

      if cnt_v = 25 then
        cnt_v := 0;
        en_ck_s <= '1';
      else
        cnt_v := cnt_v + 1;
      end if;
    end if;
  end process ck_div;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process exp
  --
  -- Purpose:
  --   Sets the expected values for D and G ports.
  --
  exp: process
    procedure w_p(signal sig : in std_logic_vector) is
    begin
      wait until sig'event;
    end;

    procedure exp_d_p(exp : in natural) is
    begin
      w_p(d_s);
      exp_d_s <= std_logic_vector(to_unsigned(exp, 4));
    end;

    procedure exp_g_p(exp : in natural) is
    begin
      w_p(g_s);
      exp_g_s <= std_logic_vector(to_unsigned(exp, 4));
    end;

  begin
    -- default settings
    pass_s  <= 'L';
    exp_d_s <= (others => '0');
    exp_g_s <= (others => '0');

    wait for 1 us;
    disable_s <= false;

    -- G(0 > 9)
    exp_g_p(9);

    -- G(9 > 6)
    exp_g_p(6);

    -- D(0 > 13)
    exp_d_p(13);

    -- D(13 > 3)
    exp_d_p(3);

    -- D(3 > 2)
    exp_d_p(2);

    -- D(2 > 3)
    exp_d_p(3);

    -- G(6 > 7)
    exp_g_p(7);

    -- G(7 > 8)
    exp_g_p(8);

    -- G(8 > 9)
    exp_g_p(9);

    -- G(9 > 11)
    exp_g_p(11);

    -- G(11 > 7)
    exp_g_p(7);

    -- G(7 > 1)
    exp_g_p(1);

    -- D(2 > 0)
    exp_d_p(0);

    -- G(1 > 5)
    exp_g_p(5);

    -- D(0 > 15)
    exp_d_p(15);

    -- G(5 > 9)
    exp_g_p(9);

    -- D(15 > 0)
    exp_d_p(0);

    -- G(9 > 10)
    exp_g_p(10);

    -- G(10 > 9)
    exp_g_p(9);

    -- G(9 > 1)
    exp_g_p(1);

    -- G(1 > 4)
    exp_g_p(4);

    -- G(4 > 14)
    exp_g_p(14);

    -- G(14 > 3)
    exp_g_p(3);

    -- G(3 > 14)
    exp_g_p(14);

    -- G(14 > 7)
    exp_g_p(7);

    -- G(7 > 9)
    exp_g_p(9);

    -- G(9 > 10)
    exp_g_p(10);

    -- G (10 > 7)
    exp_g_p(7);

    -- G(7 > 10)
    exp_g_p(10);

    -- G(10 > 7)
    exp_g_p(7);

    -- G(7 > 10)
    exp_g_p(10);

    -- G(10 > 0)
    exp_g_p(0);

    -- G(0 > 10)
    exp_g_p(10);

    -- G(10 > 7)
    exp_g_p(7);

    -- G(7 > 10)
    exp_g_p(10);

    -- D was at 15 before
--    -- D(15 > 0)
--    exp_d_p(0);

    -- G(10 > 1)
    exp_g_p(1);

    -- G(1 > 0)
    exp_g_p(0);

    -- D(0 > 11)
    exp_d_p(11);

    -- G(10 > 9)
    exp_g_p(9);

    ---------------------------------------------------------------------------
    -- RAM tests
    --
    for reg in 0 to 3 loop
      exp_g_p(7);
      exp_g_p(14);
      exp_g_p(5);
      exp_g_p(12);
      exp_g_p(3);
      exp_g_p(10);
      exp_g_p(1);
      exp_g_p(8);
      exp_g_p(15);
      exp_g_p(6);
      exp_g_p(13);
      exp_g_p(4);
      exp_g_p(11);
      exp_g_p(2);
      exp_g_p(9);
      exp_g_p(0);
    end loop;

    wait for 1 us;
    if fail_s /= '1' then
      pass_s  <= '1';
    end if;
    wait;
  end process exp;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process exp_d
  --
  -- Purpose:
  --  Checks the expected value for the D port.
  --
  exp_d: process (ck_s)
  begin
    if disable_s then
      fail_s <= 'L';
    elsif ck_s'event and ck_s = '0' then
      if d_s /= exp_d_s then
        fail_s <= '1';
      end if;
    end if;
  end process exp_d;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process exp_g
  --
  -- Purpose:
  --  Checks the expected value for the G port.
  --
  exp_g: process (ck_s)
  begin
    if disable_s then
      fail_s <= 'L';
    elsif ck_s'event and ck_s = '0' then
      if g_s /= exp_g_s then
        fail_s <= '1';
      end if;
    end if;
  end process exp_g;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process pass_fail
  --
  -- Purpose:
  --   Collects the pass/fail signal and generates the respective sequence
  --   on tb_io_l_s.
  --
  pass_fail: process
    procedure tb_pass_fail(pass : in boolean) is
    begin
      tb_io_l_s <= "00000000";
      wait for 1 us;
      tb_io_l_s <= "10100000";
      wait for 1 us;
      tb_io_l_s <= "01010000";
      wait for 1 us;

      if pass then
        tb_io_l_s <= "00000000";
      else
        tb_io_l_s <= "11110000";
      end if;
      wait for 1 us;
    end;

  begin
    tb_io_l_s <= (others => '0');

    loop
      wait until pass_s'event or fail_s'event;
      if    fail_s = '1' then
        tb_pass_fail(pass => false);
      elsif pass_s = '1' then
        tb_pass_fail(pass => true);
      end if;
    end loop;
  end process pass_fail;
  --
  -----------------------------------------------------------------------------

end behav;
