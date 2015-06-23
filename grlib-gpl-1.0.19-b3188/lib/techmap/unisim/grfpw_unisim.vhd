------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2006, Gaisler Research AB - all rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE GAISLER LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.
-----------------------------------------------------------------------------
-- Entity: 	grfpw_unisim
-- File:	grfpw_unisim.vhd
-- Author:	Jan Andersson - Gaisler Research 
-- Description: tech wrapper for xilinx/unisim grfpw netlist
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.all;
library techmap;
use techmap.gencomp.all;

entity grfpw_unisim is
  generic (tech : integer := 0);
  port(
    rst :  in std_logic;
    clk :  in std_logic;
    holdn :  in std_logic;
    cpi_flush :  in std_logic;
    cpi_exack :  in std_logic;
    cpi_a_rs1 : in std_logic_vector(4 downto 0);
    cpi_d_pc : in std_logic_vector(31 downto 0);
    cpi_d_inst : in std_logic_vector(31 downto 0);
    cpi_d_cnt : in std_logic_vector(1 downto 0);
    cpi_d_trap :  in std_logic;
    cpi_d_annul :  in std_logic;
    cpi_d_pv :  in std_logic;
    cpi_a_pc : in std_logic_vector(31 downto 0);
    cpi_a_inst : in std_logic_vector(31 downto 0);
    cpi_a_cnt : in std_logic_vector(1 downto 0);
    cpi_a_trap :  in std_logic;
    cpi_a_annul :  in std_logic;
    cpi_a_pv :  in std_logic;
    cpi_e_pc : in std_logic_vector(31 downto 0);
    cpi_e_inst : in std_logic_vector(31 downto 0);
    cpi_e_cnt : in std_logic_vector(1 downto 0);
    cpi_e_trap :  in std_logic;
    cpi_e_annul :  in std_logic;
    cpi_e_pv :  in std_logic;
    cpi_m_pc : in std_logic_vector(31 downto 0);
    cpi_m_inst : in std_logic_vector(31 downto 0);
    cpi_m_cnt : in std_logic_vector(1 downto 0);
    cpi_m_trap :  in std_logic;
    cpi_m_annul :  in std_logic;
    cpi_m_pv :  in std_logic;
    cpi_x_pc : in std_logic_vector(31 downto 0);
    cpi_x_inst : in std_logic_vector(31 downto 0);
    cpi_x_cnt : in std_logic_vector(1 downto 0);
    cpi_x_trap :  in std_logic;
    cpi_x_annul :  in std_logic;
    cpi_x_pv :  in std_logic;
    cpi_lddata : in std_logic_vector(31 downto 0);
    cpi_dbg_enable :  in std_logic;
    cpi_dbg_write :  in std_logic;
    cpi_dbg_fsr :  in std_logic;
    cpi_dbg_addr : in std_logic_vector(4 downto 0);
    cpi_dbg_data : in std_logic_vector(31 downto 0);
    cpo_data : out std_logic_vector(31 downto 0);
    cpo_exc :  out std_logic;
    cpo_cc : out std_logic_vector(1 downto 0);
    cpo_ccv :  out std_logic;
    cpo_ldlock :  out std_logic;
    cpo_holdn :  out std_logic;
    cpo_dbg_data : out std_logic_vector(31 downto 0);
    rfi1_rd1addr : out std_logic_vector(3 downto 0);
    rfi1_rd2addr : out std_logic_vector(3 downto 0);
    rfi1_wraddr : out std_logic_vector(3 downto 0);
    rfi1_wrdata : out std_logic_vector(31 downto 0);
    rfi1_ren1 :  out std_logic;
    rfi1_ren2 :  out std_logic;
    rfi1_wren :  out std_logic;
    rfi2_rd1addr : out std_logic_vector(3 downto 0);
    rfi2_rd2addr : out std_logic_vector(3 downto 0);
    rfi2_wraddr : out std_logic_vector(3 downto 0);
    rfi2_wrdata : out std_logic_vector(31 downto 0);
    rfi2_ren1 :  out std_logic;
    rfi2_ren2 :  out std_logic;
    rfi2_wren :  out std_logic;
    rfo1_data1 : in std_logic_vector(31 downto 0);
    rfo1_data2 : in std_logic_vector(31 downto 0);
    rfo2_data1 : in std_logic_vector(31 downto 0);
    rfo2_data2 : in std_logic_vector(31 downto 0);
    disasen     :  in std_logic);
end grfpw_unisim;

architecture rtl of grfpw_unisim is

component grfpw_0_unisim_v2
  port(
  rst :  in std_logic;
  clk :  in std_logic;
  holdn :  in std_logic;
  cpi_flush :  in std_logic;
  cpi_exack :  in std_logic;
  cpi_a_rs1 : in std_logic_vector(4 downto 0);
  cpi_d_pc : in std_logic_vector(31 downto 0);
  cpi_d_inst : in std_logic_vector(31 downto 0);
  cpi_d_cnt : in std_logic_vector(1 downto 0);
  cpi_d_trap :  in std_logic;
  cpi_d_annul :  in std_logic;
  cpi_d_pv :  in std_logic;
  cpi_a_pc : in std_logic_vector(31 downto 0);
  cpi_a_inst : in std_logic_vector(31 downto 0);
  cpi_a_cnt : in std_logic_vector(1 downto 0);
  cpi_a_trap :  in std_logic;
  cpi_a_annul :  in std_logic;
  cpi_a_pv :  in std_logic;
  cpi_e_pc : in std_logic_vector(31 downto 0);
  cpi_e_inst : in std_logic_vector(31 downto 0);
  cpi_e_cnt : in std_logic_vector(1 downto 0);
  cpi_e_trap :  in std_logic;
  cpi_e_annul :  in std_logic;
  cpi_e_pv :  in std_logic;
  cpi_m_pc : in std_logic_vector(31 downto 0);
  cpi_m_inst : in std_logic_vector(31 downto 0);
  cpi_m_cnt : in std_logic_vector(1 downto 0);
  cpi_m_trap :  in std_logic;
  cpi_m_annul :  in std_logic;
  cpi_m_pv :  in std_logic;
  cpi_x_pc : in std_logic_vector(31 downto 0);
  cpi_x_inst : in std_logic_vector(31 downto 0);
  cpi_x_cnt : in std_logic_vector(1 downto 0);
  cpi_x_trap :  in std_logic;
  cpi_x_annul :  in std_logic;
  cpi_x_pv :  in std_logic;
  cpi_lddata : in std_logic_vector(31 downto 0);
  cpi_dbg_enable :  in std_logic;
  cpi_dbg_write :  in std_logic;
  cpi_dbg_fsr :  in std_logic;
  cpi_dbg_addr : in std_logic_vector(4 downto 0);
  cpi_dbg_data : in std_logic_vector(31 downto 0);
  cpo_data : out std_logic_vector(31 downto 0);
  cpo_exc :  out std_logic;
  cpo_cc : out std_logic_vector(1 downto 0);
  cpo_ccv :  out std_logic;
  cpo_ldlock :  out std_logic;
  cpo_holdn :  out std_logic;
  cpo_dbg_data : out std_logic_vector(31 downto 0);
  rfi1_rd1addr : out std_logic_vector(3 downto 0);
  rfi1_rd2addr : out std_logic_vector(3 downto 0);
  rfi1_wraddr : out std_logic_vector(3 downto 0);
  rfi1_wrdata : out std_logic_vector(31 downto 0);
  rfi1_ren1 :  out std_logic;
  rfi1_ren2 :  out std_logic;
  rfi1_wren :  out std_logic;
  rfi2_rd1addr : out std_logic_vector(3 downto 0);
  rfi2_rd2addr : out std_logic_vector(3 downto 0);
  rfi2_wraddr : out std_logic_vector(3 downto 0);
  rfi2_wrdata : out std_logic_vector(31 downto 0);
  rfi2_ren1 :  out std_logic;
  rfi2_ren2 :  out std_logic;
  rfi2_wren :  out std_logic;
  rfo1_data1 : in std_logic_vector(31 downto 0);
  rfo1_data2 : in std_logic_vector(31 downto 0);
  rfo2_data1 : in std_logic_vector(31 downto 0);
  rfo2_data2 : in std_logic_vector(31 downto 0);
  disasen     :  in std_logic);
end component;

component grfpw_0_unisim_v4
port(
  rst :  in std_logic;
  clk :  in std_logic;
  holdn :  in std_logic;
  cpi_flush :  in std_logic;
  cpi_exack :  in std_logic;
  cpi_a_rs1 : in std_logic_vector(4 downto 0);
  cpi_d_pc : in std_logic_vector(31 downto 0);
  cpi_d_inst : in std_logic_vector(31 downto 0);
  cpi_d_cnt : in std_logic_vector(1 downto 0);
  cpi_d_trap :  in std_logic;
  cpi_d_annul :  in std_logic;
  cpi_d_pv :  in std_logic;
  cpi_a_pc : in std_logic_vector(31 downto 0);
  cpi_a_inst : in std_logic_vector(31 downto 0);
  cpi_a_cnt : in std_logic_vector(1 downto 0);
  cpi_a_trap :  in std_logic;
  cpi_a_annul :  in std_logic;
  cpi_a_pv :  in std_logic;
  cpi_e_pc : in std_logic_vector(31 downto 0);
  cpi_e_inst : in std_logic_vector(31 downto 0);
  cpi_e_cnt : in std_logic_vector(1 downto 0);
  cpi_e_trap :  in std_logic;
  cpi_e_annul :  in std_logic;
  cpi_e_pv :  in std_logic;
  cpi_m_pc : in std_logic_vector(31 downto 0);
  cpi_m_inst : in std_logic_vector(31 downto 0);
  cpi_m_cnt : in std_logic_vector(1 downto 0);
  cpi_m_trap :  in std_logic;
  cpi_m_annul :  in std_logic;
  cpi_m_pv :  in std_logic;
  cpi_x_pc : in std_logic_vector(31 downto 0);
  cpi_x_inst : in std_logic_vector(31 downto 0);
  cpi_x_cnt : in std_logic_vector(1 downto 0);
  cpi_x_trap :  in std_logic;
  cpi_x_annul :  in std_logic;
  cpi_x_pv :  in std_logic;
  cpi_lddata : in std_logic_vector(31 downto 0);
  cpi_dbg_enable :  in std_logic;
  cpi_dbg_write :  in std_logic;
  cpi_dbg_fsr :  in std_logic;
  cpi_dbg_addr : in std_logic_vector(4 downto 0);
  cpi_dbg_data : in std_logic_vector(31 downto 0);
  cpo_data : out std_logic_vector(31 downto 0);
  cpo_exc :  out std_logic;
  cpo_cc : out std_logic_vector(1 downto 0);
  cpo_ccv :  out std_logic;
  cpo_ldlock :  out std_logic;
  cpo_holdn :  out std_logic;
  cpo_dbg_data : out std_logic_vector(31 downto 0);
  rfi1_rd1addr : out std_logic_vector(3 downto 0);
  rfi1_rd2addr : out std_logic_vector(3 downto 0);
  rfi1_wraddr : out std_logic_vector(3 downto 0);
  rfi1_wrdata : out std_logic_vector(31 downto 0);
  rfi1_ren1 :  out std_logic;
  rfi1_ren2 :  out std_logic;
  rfi1_wren :  out std_logic;
  rfi2_rd1addr : out std_logic_vector(3 downto 0);
  rfi2_rd2addr : out std_logic_vector(3 downto 0);
  rfi2_wraddr : out std_logic_vector(3 downto 0);
  rfi2_wrdata : out std_logic_vector(31 downto 0);
  rfi2_ren1 :  out std_logic;
  rfi2_ren2 :  out std_logic;
  rfi2_wren :  out std_logic;
  rfo1_data1 : in std_logic_vector(31 downto 0);
  rfo1_data2 : in std_logic_vector(31 downto 0);
  rfo2_data1 : in std_logic_vector(31 downto 0);
  rfo2_data2 : in std_logic_vector(31 downto 0);
  disasen     :  in std_logic);
end component;
    
begin

  v2 : if (tech = virtex2) or (tech = spartan3) or  (tech = spartan3e) 
  generate
    grfpw0 : grfpw_0_unisim_v2
      port map (rst, clk, holdn, cpi_flush, cpi_exack, cpi_a_rs1, cpi_d_pc,
    	cpi_d_inst, cpi_d_cnt, cpi_d_trap, cpi_d_annul, cpi_d_pv, cpi_a_pc,
    	cpi_a_inst, cpi_a_cnt, cpi_a_trap, cpi_a_annul, cpi_a_pv, cpi_e_pc, 
    	cpi_e_inst, cpi_e_cnt, cpi_e_trap, cpi_e_annul, cpi_e_pv, cpi_m_pc, 
    	cpi_m_inst, cpi_m_cnt, cpi_m_trap, cpi_m_annul, cpi_m_pv, cpi_x_pc, 
    	cpi_x_inst, cpi_x_cnt, cpi_x_trap, cpi_x_annul, cpi_x_pv, cpi_lddata, 
    	cpi_dbg_enable, cpi_dbg_write, cpi_dbg_fsr, cpi_dbg_addr, cpi_dbg_data, 
    	cpo_data, cpo_exc, cpo_cc, cpo_ccv, cpo_ldlock, cpo_holdn, cpo_dbg_data, 
    	rfi1_rd1addr, rfi1_rd2addr, rfi1_wraddr, rfi1_wrdata, rfi1_ren1, 
    	rfi1_ren2, rfi1_wren, rfi2_rd1addr, rfi2_rd2addr, rfi2_wraddr,
    	rfi2_wrdata, rfi2_ren1, rfi2_ren2, rfi2_wren, rfo1_data1, 
    	rfo1_data2, rfo2_data1, rfo2_data2, disasen);
  end generate;

  v4 : if (tech = virtex4) or (tech = virtex5)
  generate
    grfpw0 : grfpw_0_unisim_v4
      port map (rst, clk, holdn, cpi_flush, cpi_exack, cpi_a_rs1, cpi_d_pc,
    	cpi_d_inst, cpi_d_cnt, cpi_d_trap, cpi_d_annul, cpi_d_pv, cpi_a_pc,
    	cpi_a_inst, cpi_a_cnt, cpi_a_trap, cpi_a_annul, cpi_a_pv, cpi_e_pc, 
    	cpi_e_inst, cpi_e_cnt, cpi_e_trap, cpi_e_annul, cpi_e_pv, cpi_m_pc, 
    	cpi_m_inst, cpi_m_cnt, cpi_m_trap, cpi_m_annul, cpi_m_pv, cpi_x_pc, 
    	cpi_x_inst, cpi_x_cnt, cpi_x_trap, cpi_x_annul, cpi_x_pv, cpi_lddata, 
    	cpi_dbg_enable, cpi_dbg_write, cpi_dbg_fsr, cpi_dbg_addr, cpi_dbg_data, 
    	cpo_data, cpo_exc, cpo_cc, cpo_ccv, cpo_ldlock, cpo_holdn, cpo_dbg_data, 
    	rfi1_rd1addr, rfi1_rd2addr, rfi1_wraddr, rfi1_wrdata, rfi1_ren1, 
    	rfi1_ren2, rfi1_wren, rfi2_rd1addr, rfi2_rd2addr, rfi2_wraddr,
    	rfi2_wrdata, rfi2_ren1, rfi2_ren2, rfi2_wren, rfo1_data1, 
    	rfo1_data2, rfo2_data1, rfo2_data2, disasen);
  end generate;

-- pragma translate_off

  nomap : if not ((tech = virtex4) or (tech = virtex5) or (tech = virtex2) or
                  (tech = spartan3) or  (tech = spartan3e)) generate
    err : process 
    begin
      assert false report "ERROR: No appropriate netlist available"
        severity failure;
      wait;
    end process;

  end generate;
  
-- pragma translate_on
  
end;
