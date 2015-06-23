-------------------------------------------------------------------------------
--
-- T420/421 controller toplevel without tri-states.
--
-- $Id: t420_notri.vhd 179 2009-04-01 19:48:38Z arniml $
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

entity t420_notri is

  generic (
    opt_type_g           : integer := t400_opt_type_420_c;
    opt_ck_div_g         : integer := t400_opt_ck_div_16_c;
    opt_cko_g            : integer := t400_opt_cko_crystal_c;
    opt_l_out_type_7_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_6_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_5_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_4_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_3_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_2_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_1_g   : integer := t400_opt_out_type_std_c;
    opt_l_out_type_0_g   : integer := t400_opt_out_type_std_c;
    opt_microbus_g       : integer := t400_opt_no_microbus_c;
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
    ck_i      : in  std_logic;
    ck_en_i   : in  std_logic;
    reset_n_i : in  std_logic;
    cko_i     : in  std_logic;
    io_l_i    : in  std_logic_vector(7 downto 0);
    io_l_o    : out std_logic_vector(7 downto 0);
    io_l_en_o : out std_logic_vector(7 downto 0);
    io_d_o    : out std_logic_vector(3 downto 0);
    io_d_en_o : out std_logic_vector(3 downto 0);
    io_g_i    : in  std_logic_vector(3 downto 0);
    io_g_o    : out std_logic_vector(3 downto 0);
    io_g_en_o : out std_logic_vector(3 downto 0);
    io_in_i   : in  std_logic_vector(3 downto 0);
    si_i      : in  std_logic;
    so_o      : out std_logic;
    so_en_o   : out std_logic;
    sk_o      : out std_logic;
    sk_en_o   : out std_logic
  );

end t420_notri;


use work.t400_core_comp_pack.t400_core;
use work.t400_tech_comp_pack.t400_por;
use work.t400_tech_comp_pack.generic_ram_ena;

architecture struct of t420_notri is

  component t420_rom
    port (
      ck_i   : in  std_logic;
      addr_i : in  std_logic_vector(9 downto 0);
      data_o : out std_logic_vector(7 downto 0)
    );
  end component;

  signal por_n_s             : std_logic;

  signal pm_addr_s           : std_logic_vector(9 downto 0);
  signal pm_data_s           : std_logic_vector(7 downto 0);

  signal dm_addr_s           : std_logic_vector(5 downto 0);
  signal dm_we_s             : std_logic;
  signal dm_data_to_core_s,
         dm_data_from_core_s : std_logic_vector(3 downto 0);

begin

  -----------------------------------------------------------------------------
  -- T400 core
  -----------------------------------------------------------------------------
  core_b : t400_core
    generic map (
      opt_type_g           => opt_type_g,
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
      opt_microbus_g       => opt_microbus_g,
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
      por_n_i   => por_n_s,
      reset_n_i => reset_n_i,
      cko_i     => cko_i,
      pm_addr_o => pm_addr_s,
      pm_data_i => pm_data_s,
      dm_addr_o => dm_addr_s,
      dm_we_o   => dm_we_s,
      dm_data_o => dm_data_from_core_s,
      dm_data_i => dm_data_to_core_s,
      io_l_i    => io_l_i,
      io_l_o    => io_l_o,
      io_l_en_o => io_l_en_o,
      io_d_o    => io_d_o,
      io_d_en_o => io_d_en_o,
      io_g_i    => io_g_i,
      io_g_o    => io_g_o,
      io_g_en_o => io_g_en_o,
      io_in_i   => io_in_i,
      si_i      => si_i,
      so_o      => so_o,
      so_en_o   => so_en_o,
      sk_o      => sk_o,
      sk_en_o   => sk_en_o
    );


  -----------------------------------------------------------------------------
  -- Program memory
  -----------------------------------------------------------------------------
  pmem_b : t420_rom
    port map (
      ck_i   => ck_i,
      addr_i => pm_addr_s,
      data_o => pm_data_s
    );


  -----------------------------------------------------------------------------
  -- Data memory
  -----------------------------------------------------------------------------
  dmem_b : generic_ram_ena
    generic map (
      addr_width_g => 6,
      data_width_g => 4
    )
    port map (
      clk_i => ck_i,
      a_i   => dm_addr_s,
      we_i  => dm_we_s,
      ena_i => ck_en_i,
      d_i   => dm_data_from_core_s,
      d_o   => dm_data_to_core_s
    );


  -----------------------------------------------------------------------------
  -- Power-on reset circuit
  -----------------------------------------------------------------------------
  por_b : t400_por
    generic map (
      delay_g     => 4,
      cnt_width_g => 2
    )
    port map (
      clk_i   => ck_i,
      por_n_o => por_n_s
    );

end struct;
