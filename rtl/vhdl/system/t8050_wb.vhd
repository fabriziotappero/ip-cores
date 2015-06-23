-------------------------------------------------------------------------------
--
-- T8048 Microcontroller System
-- 8050 toplevel with Wishbone interface
--
-- $Id: t8050_wb.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2005, Arnim Laeuger (arniml@opencores.org)
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

entity t8050_wb is

  generic (
    gate_port_input_g : integer := 1
  );

  port (
    -- T48 Interface ----------------------------------------------------------
    xtal_i        : in  std_logic;
    reset_n_i     : in  std_logic;
    t0_i          : in  std_logic;
    t0_o          : out std_logic;
    t0_dir_o      : out std_logic;
    int_n_i       : in  std_logic;
    ea_i          : in  std_logic;
    rd_n_o        : out std_logic;
    psen_n_o      : out std_logic;
    wr_n_o        : out std_logic;
    ale_o         : out std_logic;
    t1_i          : in  std_logic;
    p2_i          : in  std_logic_vector( 7 downto 0);
    p2_o          : out std_logic_vector( 7 downto 0);
    p2l_low_imp_o : out std_logic;
    p2h_low_imp_o : out std_logic;
    p1_i          : in  std_logic_vector( 7 downto 0);
    p1_o          : out std_logic_vector( 7 downto 0);
    p1_low_imp_o  : out std_logic;
    prog_n_o      : out std_logic;
    -- Wishbone Interface -----------------------------------------------------
    wb_cyc_o      : out std_logic;
    wb_stb_o      : out std_logic;
    wb_we_o       : out std_logic;
    wb_adr_o      : out std_logic_vector(23 downto 0);
    wb_ack_i      : in  std_logic;
    wb_dat_i      : in  std_logic_vector( 7 downto 0);
    wb_dat_o      : out std_logic_vector( 7 downto 0)

  );

end t8050_wb;


library ieee;
use ieee.numeric_std.all;

use work.t48_core_comp_pack.t48_core;
use work.t48_core_comp_pack.syn_rom;
use work.t48_core_comp_pack.syn_ram;
use work.t48_system_comp_pack.t48_wb_master;

architecture struct of t8050_wb is

  -- Address width of internal ROM
  constant rom_addr_width_c : natural := 12;

  signal xtal3_s          : std_logic;
  signal dmem_addr_s      : std_logic_vector( 7 downto 0);
  signal dmem_we_s        : std_logic;
  signal dmem_data_from_s : std_logic_vector( 7 downto 0);
  signal dmem_data_to_s   : std_logic_vector( 7 downto 0);
  signal pmem_addr_s      : std_logic_vector(11 downto 0);
  signal pmem_data_s      : std_logic_vector( 7 downto 0);

  signal ea_s             : std_logic;

  signal ale_s            : std_logic;
  signal wr_n_s           : std_logic;
  signal rd_n_s           : std_logic;
  signal db_bus_to_t48,
         db_bus_from_t48 : std_logic_vector( 7 downto 0);

  signal wb_en_clk_s      : std_logic;
  signal xtal_en_s        : std_logic;

  signal p1_in_s,
         p1_out_s         : std_logic_vector( 7 downto 0);
  signal p2_in_s,
         p2_out_s         : std_logic_vector( 7 downto 0);

begin

  -----------------------------------------------------------------------------
  -- Check generics for valid values.
  -----------------------------------------------------------------------------
  -- pragma translate_off
  assert gate_port_input_g = 0 or gate_port_input_g = 1
    report "gate_port_input_g must be either 1 or 0!"
    severity failure;
  -- pragma translate_on


  t48_core_b : t48_core
    generic map (
      xtal_div_3_g        => 1,
      register_mnemonic_g => 1,
      include_port1_g     => 1,
      include_port2_g     => 1,
      include_bus_g       => 1,
      include_timer_g     => 1,
      sample_t1_state_g   => 4
    )
    port map (
      xtal_i        => xtal_i,
      xtal_en_i     => xtal_en_s,
      reset_i       => reset_n_i,
      t0_i          => t0_i,
      t0_o          => t0_o,
      t0_dir_o      => t0_dir_o,
      int_n_i       => int_n_i,
      ea_i          => ea_s,
      rd_n_o        => rd_n_s,
      psen_n_o      => psen_n_o,
      wr_n_o        => wr_n_s,
      ale_o         => ale_s,
      db_i          => db_bus_to_t48,
      db_o          => db_bus_from_t48,
      db_dir_o      => open,
      t1_i          => t1_i,
      p2_i          => p2_in_s,
      p2_o          => p2_out_s,
      p2l_low_imp_o => p2l_low_imp_o,
      p2h_low_imp_o => p2h_low_imp_o,
      p1_i          => p1_in_s,
      p1_o          => p1_out_s,
      p1_low_imp_o  => p1_low_imp_o,
      prog_n_o      => prog_n_o,
      clk_i         => xtal_i,
      en_clk_i      => xtal3_s,
      xtal3_o       => xtal3_s,
      dmem_addr_o   => dmem_addr_s,
      dmem_we_o     => dmem_we_s,
      dmem_data_i   => dmem_data_from_s,
      dmem_data_o   => dmem_data_to_s,
      pmem_addr_o   => pmem_addr_s,
      pmem_data_i   => pmem_data_s
    );


  -----------------------------------------------------------------------------
  -- Gate port 1 and 2 input bus with respetive output value
  -----------------------------------------------------------------------------
  gate_ports: if gate_port_input_g = 1 generate
    p1_in_s <= p1_i and p1_out_s;
    p2_in_s <= p2_i and p2_out_s;
  end generate;

  pass_ports: if gate_port_input_g = 0 generate
    p1_in_s <= p1_i;
    p2_in_s <= p2_i;
  end generate;  

  p1_o <= p1_out_s;
  p2_o <= p2_out_s;

  ale_o  <= ale_s;
  wr_n_o <= wr_n_s;
  rd_n_o <= rd_n_s;


  -----------------------------------------------------------------------------
  -- Generate clock enable
  -----------------------------------------------------------------------------
  xtal_en_s <= wb_en_clk_s;


  -----------------------------------------------------------------------------
  -- Process ea
  --
  -- Purpose:
  --   Detects access to external program memory.
  --   Either by ea_i = '1' or when program memory address leaves address
  --   range of internal ROM.
  --
  ea: process (ea_i,
               pmem_addr_s)
  begin
    if ea_i = '1' then
      -- Forced external access
      ea_s <= '1';

--    elsif unsigned(pmem_addr_s(11 downto rom_addr_width_c)) = 0 then
    else
      -- Internal access
      ea_s <= '0';

--     else
--       -- Access to program memory out of internal range
--       ea_s <= '1';

    end if;

  end process ea;
  --
  -----------------------------------------------------------------------------


  wb_master_b : t48_wb_master
    port map (
      xtal_i   => xtal_i,
      res_i    => reset_n_i,
      en_clk_o => wb_en_clk_s,
      ale_i    => ale_s,
      rd_n_i   => rd_n_s,
      wr_n_i   => wr_n_s,
      adr_i    => p2_out_s(4),
      db_bus_i => db_bus_from_t48,
      db_bus_o => db_bus_to_t48,
      wb_cyc_o => wb_cyc_o,
      wb_stb_o => wb_stb_o,
      wb_we_o  => wb_we_o,
      wb_adr_o => wb_adr_o,
      wb_ack_i => wb_ack_i,
      wb_dat_i => wb_dat_i,
      wb_dat_o => wb_dat_o
    );


  rom_4k_b : syn_rom
    generic map (
      address_width_g => rom_addr_width_c
    )
    port map (
      clk_i      => xtal_i,
      rom_addr_i => pmem_addr_s(rom_addr_width_c-1 downto 0),
      rom_data_o => pmem_data_s
    );

  ram_256_b : syn_ram
    generic map (
      address_width_g => 8
    )
    port map (
      clk_i      => xtal_i,
      res_i      => reset_n_i,
      ram_addr_i => dmem_addr_s(7 downto 0),
      ram_data_i => dmem_data_to_s,
      ram_we_i   => dmem_we_s,
      ram_data_o => dmem_data_from_s
    );

end struct;
