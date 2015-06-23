--------------------------------------------------------------
-- cpu_pkg.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: component declaration of datapath and control unit 
--
-- dependency: dp.vhd, con1.vhd 
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

library ieee;
use ieee.std_logic_1164.all;

package cpu_pkg is
  COMPONENT con1
  PORT(
    CLK_I : IN std_logic;
    RST_I : IN std_logic;
    ACK_I : IN std_logic;
    INTR_I : IN std_logic;
    jcc_ok : IN std_logic;
    int_flag : IN std_logic;
    pc0 : IN std_logic;
    sp0 : IN std_logic;
    mar0 : IN std_logic;
    tr20 : IN std_logic;
    ir_high : IN std_logic_vector(7 downto 0);          
    SEL_O : OUT std_logic_vector(1 downto 0);
    STB_O : OUT std_logic;
    CYC_O : OUT std_logic;
    WE_O : OUT std_logic;
    INTA_CYC_O : OUT std_logic;
    C_CYC_O : OUT std_logic;
    I_CYC_O : OUT std_logic;
    D_CYC_O : OUT std_logic;
    intr_ce : OUT std_logic;
    ir_ce : OUT std_logic;
    mdri_ce : OUT std_logic;
    mdri_hl_zse_sign : OUT std_logic;
    intno_mux_sel : OUT std_logic_vector(2 downto 0);
    adin_mux_sel : OUT std_logic_vector(2 downto 0);
    rf_adwe : OUT std_logic;
    pcin_mux_sel : OUT std_logic_vector(1 downto 0);
    pc_pre : OUT std_logic;
    pc_ce : OUT std_logic;
    spin_mux_sel : OUT std_logic;
    sp_pre : OUT std_logic;
    sp_ce : OUT std_logic;
    dfh_ce : OUT std_logic;
    alua_mux_sel : OUT std_logic_vector(1 downto 0);
    alub_mux_sel : OUT std_logic_vector(2 downto 0);
    aopsel : OUT std_logic_vector(2 downto 0);
    sopsel : OUT std_logic_vector(2 downto 0);
    sbin_mux_sel : OUT std_logic;
    asresult_mux_sel : OUT std_logic;
    coszin_mux_sel : OUT std_logic;
    flags_rst : OUT std_logic;
    flags_ce : OUT std_logic;
    flags_cfce : OUT std_logic;
    flags_ifce : OUT std_logic;
    flags_clc : OUT std_logic;
    flags_cmc : OUT std_logic;
    flags_stc : OUT std_logic;
    flags_cli : OUT std_logic;
    flags_sti : OUT std_logic;
    marin_mux_sel : OUT std_logic_vector(1 downto 0);
    mar_ce : OUT std_logic;
    mdroin_mux_sel : OUT std_logic_vector(2 downto 0);
    mdro_ce : OUT std_logic
    );  
  END COMPONENT;
  COMPONENT dp
  generic
    ( pc_preset_value : std_logic_vector(15 downto 0) ;  
        sp_preset_value : std_logic_vector(15 downto 0) 
    );
  PORT(
    CLK_I : IN std_logic;
    intr_ce : IN std_logic;
    ir_ce : IN std_logic;
    mdri_ce : IN std_logic;
    mdri_hl_zse_sign : IN std_logic;
    intno_mux_sel : IN std_logic_vector(2 downto 0);
    adin_mux_sel : IN std_logic_vector(2 downto 0);
    rf_adwe : IN std_logic;
    pcin_mux_sel : IN std_logic_vector(1 downto 0);
    pc_pre : IN std_logic;
    pc_ce : IN std_logic;
    spin_mux_sel : IN std_logic;
    sp_pre : IN std_logic;
    sp_ce : IN std_logic;
    dfh_ce : IN std_logic;
    alua_mux_sel : IN std_logic_vector(1 downto 0);
    alub_mux_sel : IN std_logic_vector(2 downto 0);
    aopsel : IN std_logic_vector(2 downto 0);
    sopsel : IN std_logic_vector(2 downto 0);
    sbin_mux_sel : IN std_logic;
    asresult_mux_sel : IN std_logic;
    coszin_mux_sel : IN std_logic;
    flags_rst : IN std_logic;
    flags_ce : IN std_logic;
    flags_cfce : IN std_logic;
    flags_ifce : IN std_logic;
    flags_clc : IN std_logic;
    flags_cmc : IN std_logic;
    flags_stc : IN std_logic;
    flags_cli : IN std_logic;
    flags_sti : IN std_logic;
    marin_mux_sel : IN std_logic_vector(1 downto 0);
    mar_ce : IN std_logic;
    mdroin_mux_sel : IN std_logic_vector(2 downto 0);
    mdro_ce : IN std_logic;
    DAT_I : IN std_logic_vector(15 downto 0);      
    DAT_O : OUT std_logic_vector(15 downto 0);
    ADR_O : OUT std_logic_vector(15 downto 0);
    jcc_ok : OUT std_logic;
    int_flag : OUT std_logic;
    pc0 : OUT std_logic;
    sp0 : OUT std_logic;
    mar0 : OUT std_logic;
    tr20 : OUT std_logic;
    ir_high : OUT std_logic_vector(7 downto 0)
    );
  END COMPONENT; 
end cpu_pkg;