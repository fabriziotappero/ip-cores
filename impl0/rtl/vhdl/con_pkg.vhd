--------------------------------------------------------------
-- con_pkg.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: constants, component and type declarations for control unit(fsm) 
--
-- dependency: sync.vhd
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


library ieee;
use ieee.std_logic_1164.all;

package con_pkg is

-- intruction catagories
   constant mov_rn_rm    : std_logic_vector(7 downto 0) := b"00000_001";
   constant mov_sp_rm    : std_logic_vector(7 downto 0) := b"00000_010";
   constant mov_rn_sp    : std_logic_vector(7 downto 0) := b"00000_100";

   constant ld_rn_rb     : std_logic_vector(7 downto 0) := b"00001_000";
   constant ld_rn_rb_disp     : std_logic_vector(7 downto 0) := b"00001_001";
   constant ld_rn_sp     : std_logic_vector(7 downto 0) := b"00001_010";
   constant ld_rn_sp_disp     : std_logic_vector(7 downto 0) := b"00001_100";

   constant st_rn_rb     : std_logic_vector(7 downto 0) := b"00010_000";
   constant st_rn_rb_disp     : std_logic_vector(7 downto 0) := b"00010_001";
   constant st_rn_sp     : std_logic_vector(7 downto 0) := b"00010_010";
   constant st_rn_sp_disp     : std_logic_vector(7 downto 0) := b"00010_100";
   
   constant lbzx_rn_rb     : std_logic_vector(7 downto 0) := b"00011_000";
   constant lbzx_rn_rb_disp     : std_logic_vector(7 downto 0) := b"00011_100";
   constant lbsx_rn_rb     : std_logic_vector(7 downto 0) := b"00011_001";
   constant lbsx_rn_rb_disp     : std_logic_vector(7 downto 0) := b"00011_101";

   constant sb_rn_rb     : std_logic_vector(7 downto 0) := b"00100_001";
   constant sb_rn_rb_disp     : std_logic_vector(7 downto 0) := b"00100_010";
      
   constant sing_dec   : std_logic_vector(7 downto 0) := b"00101_000";
   constant sing_inc   : std_logic_vector(7 downto 0) := b"00101_001";
   
   constant alur    : std_logic_vector(4 downto 0) := "00110";
   
   constant shiftr  : std_logic_vector(4 downto 0) := "00111";
   
   constant cmp_cmp    : std_logic_vector(7 downto 0) := b"01000_000";
   constant cmp_tst    : std_logic_vector(7 downto 0) := b"01000_101";
   
   constant li_rn     : std_logic_vector(7 downto 0) := b"01001_001";
   constant li_sp     : std_logic_vector(7 downto 0) := b"01001_010";
   
   constant alui   : std_logic_vector(4 downto 0) := "01010";
   
   constant shifti : std_logic_vector(4 downto 0) := "01011";
   
   constant cmpi_cmp   : std_logic_vector(7 downto 0) := b"01100_000";
   constant cmpi_tst   : std_logic_vector(7 downto 0) := b"01100_101";
   
   constant alusp_sub  : std_logic_vector(7 downto 0) := b"01101_000";
   constant alusp_add  : std_logic_vector(7 downto 0) := b"01101_001";
   
   constant stk_pushr    : std_logic_vector(7 downto 0) := b"01110_000";
   constant stk_pushf    : std_logic_vector(7 downto 0) := b"01110_001";
   constant stk_popr    : std_logic_vector(7 downto 0) := b"01110_100";
   constant stk_popf    : std_logic_vector(7 downto 0) := b"01110_101";
   
   constant acall   : std_logic_vector(7 downto 0) := b"01111_001";

   constant lcall   : std_logic_vector(7 downto 0) := b"01111_010";
   
   constant scall   : std_logic_vector(4 downto 0) := "10000"; 
   
   constant ret    : std_logic_vector(4 downto 0) := "10001";
   
   constant int    : std_logic_vector(4 downto 0) := "10010";
   
   constant into   : std_logic_vector(4 downto 0) := "10011";
   
   constant iret   : std_logic_vector(4 downto 0) := "10100";
   
   constant ajmp    : std_logic_vector(7 downto 0) := b"10101_001";

   constant ljmp    : std_logic_vector(7 downto 0) := b"10101_010";
      
   constant sjmp    : std_logic_vector(4 downto 0) := "10110"; 
      
   constant jcc    : std_logic_vector(4 downto 0) := "10111";
   
   constant fop_clc    : std_logic_vector(7 downto 0) := b"11000_000";
   constant fop_stc    : std_logic_vector(7 downto 0) := b"11000_001";
   constant fop_cmc    : std_logic_vector(7 downto 0) := b"11000_010";
   constant fop_cli    : std_logic_vector(7 downto 0) := b"11000_100";  
   constant fop_sti    : std_logic_vector(7 downto 0) := b"11000_101";   
      
   constant nop    : std_logic_vector(4 downto 0) := "11110";
   
   constant hlt    : std_logic_vector(4 downto 0) := "11111";

   -- subop/subtype field

   constant a_sub         : std_logic_vector(2 downto 0) := "000";
   constant a_add         : std_logic_vector(2 downto 0) := "001";
   constant a_sbb         : std_logic_vector(2 downto 0) := "010";
   constant a_adc         : std_logic_vector(2 downto 0) := "011";
   constant a_not         : std_logic_vector(2 downto 0) := "100";
   constant a_and         : std_logic_vector(2 downto 0) := "101";
   constant a_or          : std_logic_vector(2 downto 0) := "110";
   constant a_xor         : std_logic_vector(2 downto 0) := "111";

   constant s_sll       : std_logic_vector(2 downto 0) := "000";
   constant s_slr       : std_logic_vector(2 downto 0) := "001";
   constant s_sal       : std_logic_vector(2 downto 0) := "010";
   constant s_sar       : std_logic_vector(2 downto 0) := "011";
   constant s_rol       : std_logic_vector(2 downto 0) := "100";
   constant s_ror       : std_logic_vector(2 downto 0) := "101";
   constant s_rcl       : std_logic_vector(2 downto 0) := "110";
   constant s_rcr       : std_logic_vector(2 downto 0) := "111";

   -- alu operations
   constant asopsel_sub : std_logic_vector(3 downto 0) := "0000";
   constant asopsel_add : std_logic_vector(3 downto 0) := "0001";
   constant asopsel_sbb : std_logic_vector(3 downto 0) := "0010";
   constant asopsel_adc : std_logic_vector(3 downto 0) := "0011";
   constant asopsel_not : std_logic_vector(3 downto 0) := "0100";
   constant asopsel_and : std_logic_vector(3 downto 0) := "0101";
   constant asopsel_or  : std_logic_vector(3 downto 0) := "0110";
   constant asopsel_xor : std_logic_vector(3 downto 0) := "0111";

   -- shifter operations
   constant asopsel_sll : std_logic_vector(3 downto 0) := "1000";
   constant asopsel_slr : std_logic_vector(3 downto 0) := "1001";
   constant asopsel_sal : std_logic_vector(3 downto 0) := "1010";
   constant asopsel_sar : std_logic_vector(3 downto 0) := "1011";
   constant asopsel_rol : std_logic_vector(3 downto 0) := "1100";
   constant asopsel_ror : std_logic_vector(3 downto 0) := "1101";
   constant asopsel_rcl : std_logic_vector(3 downto 0) := "1110";
   constant asopsel_rcr : std_logic_vector(3 downto 0) := "1111";

   constant intno_mux_sel_invalid : std_logic_vector(2 downto 0) := "000";
   constant intno_mux_sel_align : std_logic_vector(2 downto 0) := "001";
   constant intno_mux_sel_stk : std_logic_vector(2 downto 0) := "010";
   constant intno_mux_sel_df  : std_logic_vector(2 downto 0) := "011"; 
   constant intno_mux_sel_ir : std_logic_vector(2 downto 0) := "100"; 
   constant intno_mux_sel_intr : std_logic_vector(2 downto 0) := "101"; 

   constant adin_mux_sel_tr2 : std_logic_vector(2 downto 0) := "000";
   constant adin_mux_sel_tr5 : std_logic_vector(2 downto 0) := "001";
   constant adin_mux_sel_sp  : std_logic_vector(2 downto 0) := "010";
   constant adin_mux_sel_mdri : std_logic_vector(2 downto 0) := "011";
   constant adin_mux_sel_mdri_high : std_logic_vector(2 downto 0) := "100";
   constant adin_mux_sel_mdri_low : std_logic_vector(2 downto 0) := "101";

   constant pcin_mux_sel_aluout : std_logic_vector(1 downto 0) := "00";
   constant pcin_mux_sel_intno : std_logic_vector(1 downto 0) := "01";
   constant pcin_mux_sel_mdri : std_logic_vector(1 downto 0) := "10";

   constant spin_mux_sel_aluout : std_logic := '0';
   constant spin_mux_sel_mdri : std_logic := '1';

   constant alua_mux_sel_pc : std_logic_vector(1 downto 0) := "00";
   constant alua_mux_sel_sp : std_logic_vector(1 downto 0) := "01";
   constant alua_mux_sel_tr1 : std_logic_vector(1 downto 0) := "10";
   constant alua_mux_sel_tr2 : std_logic_vector(1 downto 0) := "11";

   constant alub_mux_sel_tr2 : std_logic_vector(2 downto 0) := "000";
   constant alub_mux_sel_2 : std_logic_vector(2 downto 0) := "001";
   constant alub_mux_sel_1 : std_logic_vector(2 downto 0) := "010";
   constant alub_mux_sel_0 : std_logic_vector(2 downto 0) := "011";
   constant alub_mux_sel_tr3 : std_logic_vector(2 downto 0) := "100";
   constant alub_mux_sel_tr4 : std_logic_vector(2 downto 0) := "101";
   constant alub_mux_sel_mdri : std_logic_vector(2 downto 0) := "110";

   constant sbin_mux_sel_tr2 : std_logic := '0';
   constant sbin_mux_sel_ir : std_logic := '1';

   constant coszin_mux_sel_asresult : std_logic := '0';
   constant coszin_mux_sel_mdri     : std_logic := '1';

   constant marin_mux_sel_pc : std_logic_vector(1 downto 0) := "00";
   constant marin_mux_sel_aluout : std_logic_vector(1 downto 0) := "01";
   constant marin_mux_sel_sp : std_logic_vector(1 downto 0) := "10";

   constant mdroin_mux_sel_pc : std_logic_vector(2 downto 0) := "000";
   constant mdroin_mux_sel_tr1 : std_logic_vector(2 downto 0) := "001";
   constant mdroin_mux_sel_flags : std_logic_vector(2 downto 0) := "010";
   constant mdroin_mux_sel_dfh : std_logic_vector(2 downto 0) := "011";
   constant mdroin_mux_sel_intno : std_logic_vector(2 downto 0) := "100";
   constant mdroin_mux_sel_tr1_loweven : std_logic_vector(2 downto 0) := "101";
   constant mdroin_mux_sel_tr1_lowodd : std_logic_vector(2 downto 0) := "110";
   
   type ic is (
   ic_mov_rn_rm, ic_mov_sp_rm, ic_mov_rn_sp,

   ic_ld_rn_rb, ic_ld_rn_rb_disp, ic_ld_rn_sp, ic_ld_rn_sp_disp,

   ic_st_rn_rb, ic_st_rn_rb_disp, ic_st_rn_sp, ic_st_rn_sp_disp,
   
   ic_lbzx_rn_rb, ic_lbzx_rn_rb_disp, ic_lbsx_rn_rb, ic_lbsx_rn_rb_disp,

   ic_sb_rn_rb, ic_sb_rn_rb_disp,
      
   ic_sing_dec, ic_sing_inc,
   
   ic_alur,
   
   ic_shiftr,
   
   ic_cmp_cmp, ic_cmp_tst,
   
   ic_li_rn, ic_li_sp,
   
   ic_alui,
   
   ic_shifti,
   
   ic_cmpi_cmp, ic_cmpi_tst,
   
   ic_alusp_sub, ic_alusp_add,
   
   ic_stk_pushr, ic_stk_pushf, ic_stk_popr, ic_stk_popf,
   
   ic_acall, ic_lcall, ic_scall, 
   
   ic_ret,
   
   ic_int,
   
   ic_into,
   
   ic_iret,
   
   ic_ajmp, ic_ljmp, ic_sjmp, 
      
   ic_jcc,
   
   ic_fop_clc, ic_fop_stc, ic_fop_cmc, ic_fop_cli, ic_fop_sti,   
      
   ic_nop,
   
   ic_hlt,

   ic_invalid);

   type state is (
      reset,
      fetch0, fetch1, fetch2,
      exec0, exec1, exec2, exec3, exec4, exec5,
      int_chk,
      int0, int1, int2, int3, int4,
      align0, align1, align2, align3, align4, 
      stkerr0, stkerr1, stkerr2, stkerr3, stkerr4, stkerr5, stkerr6, stkerr7,
      invalid0, invalid1, invalid2, invalid3, invalid4, 
      df0, df1, df2, df3, df4, df5, df6, df7, df8, df9,
      halted
   );
   
   component sync is
      port
      (
      d : in std_logic;
      clk : in std_logic;
      q : out std_logic
      );
   end component;   
         
end package;
