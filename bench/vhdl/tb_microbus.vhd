-------------------------------------------------------------------------------
--
-- Testbench for MICROBUS evaluation.
--
-- $Id: tb_microbus.vhd 179 2009-04-01 19:48:38Z arniml $
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

entity tb_microbus is

end tb_microbus;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.t400_system_comp_pack.t420;
use work.tb_pack.all;
use work.t400_opt_pack.all;

architecture behav of tb_microbus is

  -- 5 MHz clock
  constant period_c : time := 200 ns;
  signal   ck_s     : std_logic;
  signal   en_ck_s  : std_logic := '0';

  signal reset_n_s  : std_logic;

  signal io_l_s     : std_logic_vector(7 downto 0);
  signal io_d_s     : std_logic_vector(3 downto 0);
  signal io_g_s     : std_logic_vector(3 downto 0);
  signal io_in_s    : std_logic_vector(3 downto 0);

  signal si_s,
         so_s,
         sk_s       : std_logic;

  signal cs_n_s,
         rd_n_s,
         wr_n_s     : std_logic;

  signal tb_io_l_s  : std_logic_vector(7 downto 0);

begin


  reset_n_s <= '1';

  -----------------------------------------------------------------------------
  -- DUT
  -----------------------------------------------------------------------------
  t420_b : t420
    generic map (
      opt_ck_div_g   => t400_opt_ck_div_4_c,
      opt_microbus_g => t400_opt_microbus_c
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
  io_d_s  <= (others => 'H');
  io_g_s  <= (others => 'H');
  io_in_s <= (others => 'H');


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
      io_d_i  => io_d_s,
      io_g_i  => io_g_s,
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
  -- Process microbus
  --
  -- Purpose:
  --   Implements the microbus testbench element.
  --   a) sends twelve bytes of data to the DUT
  --        HELLO WORLD!
  --   b) reads twelve bytes from the DUT and compares them against
  --      the original sequence
  --
  microbus: process
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

    constant msg_c : string := string'("HELLO WORLD!");
  begin
    -- default settings
    cs_n_s    <= '1';
    rd_n_s    <= '1';
    wr_n_s    <= '1';
    io_l_s    <= (others => 'H');
    tb_io_l_s <= (others => '0');

    --
    -- send the message string
    --
    for idx in msg_c'range loop
      wait until io_g_s(0)'event and io_g_s(0) = '1';
      if idx mod 2 = 0 then
        -- short wait for even positions
        wait for 1 us;
      else
        -- long wait for odd positions
        wait for 1 ms;
      end if;

      io_l_s <= std_logic_vector(to_unsigned(character'pos(msg_c(idx)), 8));
      wait for 10 ns;
      cs_n_s <= '0';
      wr_n_s <= '0';
      wait for 400 ns;
      cs_n_s <= '1';
      wr_n_s <= '1';
      wait for 10 ns;
      io_l_s <= (others => 'H');
    end loop;

    --
    -- and receive it again
    --
    for idx in msg_c'range loop
      wait until io_g_s(0)'event and io_g_s(0) = '1';
      if idx mod 2 = 0 then
        -- short wait for even positions
        wait for 1 us;
      else
        -- long wait for odd positions
        wait for 1 ms;
      end if;

      cs_n_s <= '0';
      rd_n_s <= '0';
      wait for 400 ns;
      if character'pos(msg_c(idx)) /= to_integer(unsigned(io_l_s)) then
        tb_pass_fail(pass => false);
      end if;
      cs_n_s <= '1';
      rd_n_s <= '1';

      -- ack with dummy write
      wait for 1 us;
      cs_n_s <= '0';
      wr_n_s <= '0';
      wait for 400 ns;
      cs_n_s <= '1';
      wr_n_s <= '1';
    end loop;

    tb_pass_fail(pass => true);
    wait;
  end process microbus;
  --
  io_in_s(1) <= rd_n_s;
  io_in_s(2) <= cs_n_s;
  io_in_s(3) <= wr_n_s;
  --
  -----------------------------------------------------------------------------


end behav;
