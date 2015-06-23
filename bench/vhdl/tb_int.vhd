-------------------------------------------------------------------------------
--
-- Testbench for interrupt evaluation.
--
-- $Id: tb_int.vhd 179 2009-04-01 19:48:38Z arniml $
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

entity tb_int is

end tb_int;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.t400_system_comp_pack.t420;
use work.tb_pack.all;
use work.t400_opt_pack.all;

architecture behav of tb_int is

  -- 210.4 kHz clock
  constant period_c : time := 4.75 us;
  signal   ck_s     : std_logic;

  signal reset_n_s  : std_logic;

  signal io_l_s     : std_logic_vector(7 downto 0);
  signal io_d_s     : std_logic_vector(3 downto 0);
  signal io_g_s     : std_logic_vector(3 downto 0);
  signal io_in_s    : std_logic_vector(3 downto 0);

  signal si_s,
         so_s,
         sk_s       : std_logic;

  signal vdd_8_s    : std_logic_vector(7 downto 0);

begin


  vdd_8_s   <= (others => '1');
  reset_n_s <= '1';

  -----------------------------------------------------------------------------
  -- DUT
  -----------------------------------------------------------------------------
  t420_b : t420
    generic map (
      opt_ck_div_g       => t400_opt_ck_div_4_c,
      opt_l_out_type_3_g => t400_opt_out_type_od_c,
      opt_l_out_type_2_g => t400_opt_out_type_od_c,
      opt_l_out_type_1_g => t400_opt_out_type_od_c,
      opt_l_out_type_0_g => t400_opt_out_type_od_c
    )
    port map (
      ck_i      => ck_s,
      ck_en_i   => vdd_8_s(0),
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
      io_l_i  => vdd_8_s,
      io_d_i  => io_d_s,
      io_g_i  => vdd_8_s(3 downto 0),
      io_in_o => open,
      so_i    => so_s,
      si_o    => si_s,
      sk_i    => sk_s,
      ck_o    => ck_s
    );


  -----------------------------------------------------------------------------
  -- Process int
  --
  -- Purpose:
  --   Generates interrupts based on current PC.
  --
  int: process
    variable int_v : std_logic;
  begin
    loop
      wait until tb_pc_s'event;
      -- see if we need to generate an interrupt
      case to_integer(tb_pc_s) is
        when 16#030# =>
          int_v := '0';
        when 16#0b0# =>
          int_v := '0';
        when 16#1b0# =>
          int_v := '0';
        when 16#230# =>
          int_v := '0';
        when 16#2b0# =>
          int_v := '0';
        when 16#330# =>
          int_v := '0';
        when 16#3b0# =>
          int_v := '0';
        when others =>
          int_v := 'H';
      end case;

      io_in_s(1) <= int_v;

      if int_v = '0' then
        -- wait for appropriate interrupt active time
        wait for period_c * 4 * 3;        -- three instruction cycles
        io_in_s(1) <= 'H';
      end if;
    end loop;
  end process int;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- MUX the nibbles of SA to L
  -----------------------------------------------------------------------------
  io_l_s(3 downto 0) <=   std_logic_vector(tb_sa_s(3 downto 0))
                        when io_g_s(1 downto 0) = "00" else
                          std_logic_vector(tb_sa_s(7 downto 4))
                        when io_g_s(1 downto 0) = "01" else
                          '0' & '0' & std_logic_vector(tb_sa_s(9 downto 8))
                        when io_g_s(1 downto 0) = "10" else
                          (others => 'H');

end behav;
