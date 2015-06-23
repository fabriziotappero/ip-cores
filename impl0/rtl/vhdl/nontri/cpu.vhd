--------------------------------------------------------------
-- cpu.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: main microprocessor, instantiates the datapath and control unit
--        components and perform interconnection
--
-- dependency: cpu_pkg.vhd
--
-- Author: M. Umair Siddiqui (umairsiddiqui@opencores.org)
---------------------------------------------------------------
------------------------------------------------------------------------------------
--                                                                                --
--    Copyright (c) 2005, M. Umair Siddiqui all rights reserved                   --
--                                                                                --
--    This file is part of HPC-16.                                                --
--                                                                                --
--    HPC-16 is free software; you can redistribute it and/or modify              --
--    it under the terms of the GNU Lesser General Public License as published by --
--    the Free Software Foundation; either version 2.1 of the License, or         --
--    (at your option) any later version.                                         --
--                                                                                --
--    HPC-16 is distributed in the hope that it will be useful,                   --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of              --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               --
--    GNU Lesser General Public License for more details.                         --
--                                                                                --
--    You should have received a copy of the GNU Lesser General Public License    --
--    along with HPC-16; if not, write to the Free Software                       --
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   --
--                                                                                --
------------------------------------------------------------------------------------
--------------------------------
--                            --
--    non-tristate version    --
--                            --
--------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_pkg.all;
entity cpu is
   generic
   (
     pc_preset_value : std_logic_vector(15 downto 0) := X"0000";
     sp_preset_value : std_logic_vector(15 downto 0) := X"0000"
   );
   port(
      CLK_I : in std_logic;
      RST_I : in std_logic;
      ACK_I : in std_logic;
      INTR_I : in std_logic;
      --
      SEL_O : out std_logic_vector(1 downto 0);
      STB_O : out std_logic;
      CYC_O : out std_logic;
      WE_O : out std_logic;
      --
      INTA_CYC_O : out std_logic;
      I_CYC_O : out std_logic;
      C_CYC_O : out std_logic;
      D_CYC_O : out std_logic;
      --
      DAT_I : in std_logic_vector(15 downto 0);
      DAT_O : out std_logic_vector(15 downto 0);
      --
      ADR_O : out std_logic_vector(15 downto 0)
   );
end cpu;

architecture struct of cpu is
    signal jcc_ok , int_flag , pc0 , sp0 , mar0 , tr20, intr_ce, ir_ce ,
           mdri_ce, mdri_hl_zse_sign, rf_adwe, pc_pre, pc_ce,
             spin_mux_sel, sp_pre, sp_ce, dfh_ce,
             sbin_mux_sel, asresult_mux_sel, coszin_mux_sel,
             flags_rst, flags_ce, flags_cfce, flags_ifce,
             flags_clc, flags_cmc, flags_stc, flags_cli, flags_sti,
             mar_ce, mdro_ce : std_logic;

      signal ir_high : std_logic_vector(7 downto 0);

      signal intno_mux_sel, adin_mux_sel,
             alub_mux_sel, aopsel, sopsel, mdroin_mux_sel : std_logic_vector(2 downto 0);

      signal pcin_mux_sel, alua_mux_sel, marin_mux_sel : std_logic_vector(1 downto 0);

    for control : con1 use entity work.con1(rtl);

begin

  assert pc_preset_value(0) = '0' and sp_preset_value(0) = '0'
    report "the preset values of sp and pc should be even"
    severity failure;

  control: con1
   PORT MAP(
    CLK_I => CLK_I,
    RST_I => RST_I,
    ACK_I => ACK_I,
    INTR_I => INTR_I,
    SEL_O => SEL_O,
    STB_O => STB_O,
    CYC_O => CYC_O,
    WE_O => WE_O,
    INTA_CYC_O => INTA_CYC_O,
    C_CYC_O => C_CYC_O,
    I_CYC_O => I_CYC_O,
    D_CYC_O => D_CYC_O,
    jcc_ok => jcc_ok,
    int_flag => int_flag,
    pc0 => pc0,
    sp0 => sp0,
    mar0 => mar0,
    tr20 => tr20,
    ir_high => ir_high,
    intr_ce => intr_ce,
    ir_ce => ir_ce,
    mdri_ce => mdri_ce,
    mdri_hl_zse_sign => mdri_hl_zse_sign,
    intno_mux_sel => intno_mux_sel,
    adin_mux_sel => adin_mux_sel,
    rf_adwe => rf_adwe,
    pcin_mux_sel => pcin_mux_sel,
    pc_pre => pc_pre,
    pc_ce => pc_ce,
    spin_mux_sel => spin_mux_sel,
    sp_pre => sp_pre,
    sp_ce => sp_ce,
    dfh_ce => dfh_ce,
    alua_mux_sel => alua_mux_sel,
    alub_mux_sel => alub_mux_sel,
    aopsel => aopsel,
    sopsel => sopsel,
    sbin_mux_sel => sbin_mux_sel,
    asresult_mux_sel => asresult_mux_sel,
    coszin_mux_sel => coszin_mux_sel,
    flags_rst => flags_rst,
    flags_ce => flags_ce,
    flags_cfce => flags_cfce,
    flags_ifce => flags_ifce,
    flags_clc => flags_clc,
    flags_cmc => flags_cmc,
    flags_stc => flags_stc,
    flags_cli => flags_cli,
    flags_sti => flags_sti,
    marin_mux_sel => marin_mux_sel,
    mar_ce => mar_ce,
    mdroin_mux_sel => mdroin_mux_sel,
    mdro_ce => mdro_ce
  );

      datapath : dp
   generic map
   (
        pc_preset_value => pc_preset_value,
              sp_preset_value => sp_preset_value
   )
   PORT MAP(
    CLK_I => CLK_I,
    DAT_I => DAT_I,
    DAT_O => DAT_O,
    ADR_O => ADR_O,
    jcc_ok => jcc_ok,
    int_flag => int_flag,
    pc0 => pc0,
    sp0 => sp0,
    mar0 => mar0,
    tr20 => tr20,
    ir_high => ir_high,
    intr_ce => intr_ce,
    ir_ce => ir_ce,
    mdri_ce => mdri_ce,
    mdri_hl_zse_sign => mdri_hl_zse_sign,
    intno_mux_sel => intno_mux_sel,
    adin_mux_sel => adin_mux_sel,
    rf_adwe => rf_adwe,
    pcin_mux_sel => pcin_mux_sel,
    pc_pre => pc_pre,
    pc_ce => pc_ce,
    spin_mux_sel => spin_mux_sel,
    sp_pre => sp_pre,
    sp_ce => sp_ce,
    dfh_ce => dfh_ce,
    alua_mux_sel => alua_mux_sel,
    alub_mux_sel => alub_mux_sel,
    aopsel => aopsel,
    sopsel => sopsel,
    sbin_mux_sel => sbin_mux_sel,
    asresult_mux_sel => asresult_mux_sel,
    coszin_mux_sel => coszin_mux_sel,
    flags_rst => flags_rst,
    flags_ce => flags_ce,
    flags_cfce => flags_cfce,
    flags_ifce => flags_ifce,
    flags_clc => flags_clc,
    flags_cmc => flags_cmc,
    flags_stc => flags_stc,
    flags_cli => flags_cli,
    flags_sti => flags_sti,
    marin_mux_sel => marin_mux_sel,
    mar_ce => mar_ce,
    mdroin_mux_sel => mdroin_mux_sel,
    mdro_ce => mdro_ce
  );
end struct;