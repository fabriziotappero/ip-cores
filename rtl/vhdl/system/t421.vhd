-------------------------------------------------------------------------------
--
-- T421 system toplevel.
--
-- $Id: t421.vhd 179 2009-04-01 19:48:38Z arniml $
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

library ieee;
use ieee.std_logic_1164.all;

use work.t400_opt_pack.all;

entity t421 is

  generic (
    opt_ck_div_g         : integer := t400_opt_ck_div_8_c;
    opt_cko_g            : integer := t400_opt_cko_crystal_c;
    opt_l_out_type_7_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_6_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_5_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_4_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_3_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_2_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_1_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_0_g   : integer := t400_opt_out_type_std_c;
    opt_d_out_type_3_g   : integer := t400_opt_out_type_std_c;
    opt_d_out_type_2_g   : integer := t400_opt_out_type_std_c;
    opt_d_out_type_1_g   : integer := t400_opt_out_type_std_c;
    opt_d_out_type_0_g   : integer := t400_opt_out_type_std_c;
    opt_g_out_type_3_g   : integer := t400_opt_out_type_std_c;
    opt_g_out_type_2_g   : integer := t400_opt_out_type_std_c;
    opt_g_out_type_1_g   : integer := t400_opt_out_type_std_c;
    opt_g_out_type_0_g   : integer := t400_opt_out_type_std_c;
    opt_so_output_type_g : integer := t400_opt_out_type_std_c;
    opt_sk_output_type_g : integer := t400_opt_out_type_std_c
  );
  port (
    ck_i      : in    std_logic;
    ck_en_i   : in    std_logic;
    reset_n_i : in    std_logic;
    cko_i     : in    std_logic;
    io_l_b    : inout std_logic_vector(7 downto 0);
    io_d_o    : out   std_logic_vector(3 downto 0);
    io_g_b    : inout std_logic_vector(3 downto 0);
    si_i      : in    std_logic;
    so_o      : out   std_logic;
    sk_o      : out   std_logic
  );

end t421;


use work.t400_system_comp_pack.t420_notri;

architecture struct of t421 is

  signal io_l_from_t420_s,
         io_l_en_s         : std_logic_vector(7 downto 0);
  signal io_d_from_t420_s,
         io_d_en_s         : std_logic_vector(3 downto 0);
  signal io_g_from_t420_s,
         io_g_en_s         : std_logic_vector(3 downto 0);

  signal so_s,
         so_en_s           : std_logic;
  signal sk_s,
         sk_en_s           : std_logic;

  signal vdd4_s            : std_logic_vector(3 downto 0);

begin

  vdd4_s <= (others => '1');

  -----------------------------------------------------------------------------
  -- T420 without tri-states in T421 configuration
  -----------------------------------------------------------------------------
  t420_notri_b : t420_notri
    generic map (
      opt_type_g           => t400_opt_type_421_c,
      opt_ck_div_g         => opt_ck_div_g,
      opt_cko_g            => opt_cko_g,
      opt_l_out_type_7_g   => opt_l_out_type_7_g,
      opt_l_out_type_6_g   => opt_l_out_type_6_g,
      opt_l_out_type_5_g   => opt_l_out_type_5_g,
      opt_l_out_type_4_g   => opt_l_out_type_4_g,
      opt_l_out_type_3_g   => opt_l_out_type_3_g,
      opt_l_out_type_2_g   => opt_l_out_type_2_g,
      opt_l_out_type_1_g   => opt_l_out_type_1_g,
      opt_l_out_type_0_g   => opt_l_out_type_0_g,
      opt_microbus_g       => t400_opt_no_microbus_c,
      opt_d_out_type_3_g   => opt_d_out_type_3_g,
      opt_d_out_type_2_g   => opt_d_out_type_2_g,
      opt_d_out_type_1_g   => opt_d_out_type_1_g,
      opt_d_out_type_0_g   => opt_d_out_type_0_g,
      opt_g_out_type_3_g   => opt_g_out_type_3_g,
      opt_g_out_type_2_g   => opt_g_out_type_2_g,
      opt_g_out_type_1_g   => opt_g_out_type_1_g,
      opt_g_out_type_0_g   => opt_g_out_type_0_g,
      opt_so_output_type_g => opt_so_output_type_g,
      opt_sk_output_type_g => opt_sk_output_type_g
    )
    port map (
      ck_i      => ck_i,
      ck_en_i   => ck_en_i,
      reset_n_i => reset_n_i,
      cko_i     => cko_i,
      io_l_i    => io_l_b,
      io_l_o    => io_l_from_t420_s,
      io_l_en_o => io_l_en_s,
      io_d_o    => io_d_from_t420_s,
      io_d_en_o => io_d_en_s,
      io_g_i    => io_g_b,
      io_g_o    => io_g_from_t420_s,
      io_g_en_o => io_g_en_s,
      io_in_i   => vdd4_s,
      si_i      => si_i,
      so_o      => so_s,
      so_en_o   => so_en_s,
      sk_o      => sk_s,
      sk_en_o   => sk_en_s
    );


  -----------------------------------------------------------------------------
  -- Tri-states for output drivers
  -----------------------------------------------------------------------------
  io_l_tri: for idx in 7 downto 0 generate
    io_l_b(idx)  <=   io_l_from_t420_s(idx)
                    when io_l_en_s(idx) = '1' else
                      'Z';
  end generate;
  --
  io_d_tri: for idx in 3 downto 0 generate
    io_d_o(idx)  <=   io_d_from_t420_s(idx)
                    when io_d_en_s(idx) = '1' else
                      'Z';
  end generate;
  --
  io_g_tri: for idx in 3 downto 0 generate
    io_g_b(idx)  <=   io_g_from_t420_s(idx)
                    when io_g_en_s(idx) = '1' else
                      'Z';
  end generate;
  --
  so_o           <=   so_s
                    when so_en_s = '1' else
                      'Z';
  --
  sk_o           <=   sk_s
                    when sk_en_s = '1' else
                      'Z';

end struct;
