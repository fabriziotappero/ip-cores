--------------------------------------------------------------
-- con1.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: control unit of microprocessor 
--
-- dependency: con_pkg.vhd 
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.con_pkg.all;

entity con1 is
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
   INTA_CYC_O : out std_logic;
   C_CYC_O : out std_logic;
   I_CYC_O : out std_logic;
   D_CYC_O : out std_logic;   
   --
   jcc_ok : in std_logic;
   int_flag : in std_logic; 
   pc0 : in std_logic;
   sp0 : in std_logic;
   mar0 : in std_logic;
   tr20 : in std_logic;
   ir_high : in std_logic_vector(7 downto 0);
   --
   intr_ce : out std_logic;
   ir_ce : out std_logic;
   mdri_ce : out std_logic;
   mdri_hl_zse_sign : out std_logic;   
   intno_mux_sel : out std_logic_vector(2 downto 0);
   adin_mux_sel : out std_logic_vector(2 downto 0);
   rf_adwe : out std_logic;
   pcin_mux_sel : out std_logic_vector(1 downto 0);
   pc_pre : out std_logic;
   pc_ce : out std_logic;
   spin_mux_sel : out std_logic;
   sp_pre : out std_logic;
   sp_ce : out std_logic;
   dfh_ce : out std_logic;
   alua_mux_sel : out std_logic_vector(1 downto 0);
   alub_mux_sel : out std_logic_vector(2 downto 0);
   aopsel : out std_logic_vector(2 downto 0); 
   sopsel : out std_logic_vector(2 downto 0);
   sbin_mux_sel : out std_logic;
   asresult_mux_sel : out std_logic;
   coszin_mux_sel : out std_logic;
   flags_rst : out std_logic;
   flags_ce : out std_logic;
   flags_cfce : out std_logic;
   flags_ifce : out std_logic;
   flags_clc : out std_logic;
   flags_cmc : out std_logic;
   flags_stc : out std_logic;
   flags_cli : out std_logic;
   flags_sti : out std_logic;
   marin_mux_sel : out std_logic_vector(1 downto 0);
   mar_ce : out std_logic;
   mdroin_mux_sel : out std_logic_vector(2 downto 0);
   mdro_ce : out std_logic; 
   mdro_oe : out std_logic
   );   
end con1;
architecture rtl of con1 is
   signal rst_sync : std_logic;
   signal ack_sync : std_logic;
   signal intr_sync : std_logic;
   signal cur_state , nxt_state : state; 
   signal cur_ic : ic; 
   signal asopsel : std_logic_vector(3 downto 0);

   signal rsync_stage0 : std_logic; 
   signal rsync_stage1 : std_logic;

   signal isync_stage0   : std_logic; 
   signal isync_stage1   : std_logic;
   signal isync_stage2   : std_logic;
   signal isync          : std_logic;
   signal intr_sync_rst  : std_logic;
  
begin
   
   process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         rsync_stage0 <= RST_I;
         rsync_stage1 <= rsync_stage0;
         rst_sync     <= rsync_stage1;
      end if;   
   end process;

   process(CLK_I, rst_sync)
   begin
      if rst_sync = '1' then
         ack_sync     <= '0';
      elsif rising_edge(CLK_I)then
         ack_sync     <= ACK_I; 
      end if;   
   end process;
   
   process(CLK_I, rst_sync)
   begin
      if rst_sync = '1' then
         isync_stage0 <= '0';
         isync_stage1 <= '0';
         isync_stage2 <= '0';
      elsif rising_edge(CLK_I)then
         isync_stage0 <= INTR_I;
         isync_stage1 <= isync_stage0;
         isync_stage2 <= isync_stage1;
      end if;   
   end process;
   
   isync <= isync_stage0 and isync_stage1 and not isync_stage2;
   
   process(CLK_I, rst_sync)
   begin
      if rst_sync = '1' then
         intr_sync <= '0';
      elsif rising_edge(CLK_I) then      
         if intr_sync_rst = '1' then
            intr_sync <= '0';
         elsif isync = '1' then
            intr_sync <= '1';
         end if;         
      end if;
   end process;   
   
   process(CLK_I, rst_sync)
   begin
      if rst_sync = '1' then
         cur_state <= reset;
      elsif rising_edge(CLK_I) then
         cur_state <= nxt_state;
      end if;       
   end process;
   
   decode: 
   cur_ic <= ic_mov_rn_rm when ir_high = mov_rn_rm else
             ic_mov_sp_rm when ir_high = mov_sp_rm else
             ic_mov_rn_sp when ir_high = mov_rn_sp else
             ic_ld_rn_rb  when ir_high = ld_rn_rb  else
             ic_ld_rn_rb_disp when ir_high = ld_rn_rb_disp else 
             ic_ld_rn_sp  when ir_high = ld_rn_sp else
             ic_ld_rn_sp_disp when ir_high = ld_rn_sp_disp else
             ic_st_rn_rb  when ir_high = st_rn_rb else
             ic_st_rn_rb_disp when ir_high = st_rn_rb_disp else
             ic_st_rn_sp  when ir_high = st_rn_sp else
             ic_st_rn_sp_disp when ir_high = st_rn_sp_disp else
             ic_lbzx_rn_rb when ir_high = lbzx_rn_rb else
             ic_lbzx_rn_rb_disp when ir_high = lbzx_rn_rb_disp else
             ic_lbsx_rn_rb when ir_high = lbsx_rn_rb else
             ic_lbsx_rn_rb_disp when ir_high = lbsx_rn_rb_disp else
             ic_sb_rn_rb when ir_high = sb_rn_rb else 
             ic_sb_rn_rb_disp when ir_high = sb_rn_rb_disp else
             ic_sing_dec when ir_high = sing_dec else
             ic_sing_inc when ir_high = sing_inc else
             ic_alur when ir_high(7 downto 3) = alur else
             ic_shiftr when ir_high(7 downto 3) = shiftr else
             ic_cmp_cmp when ir_high = cmp_cmp else
             ic_cmp_tst when ir_high = cmp_tst else
             ic_li_rn when ir_high = li_rn else
             ic_li_sp when ir_high = li_sp else
             ic_alui when ir_high(7 downto 3) = alui else 
             ic_shifti when ir_high(7 downto 3) = shifti else
             ic_cmpi_cmp when ir_high = cmpi_cmp else
             ic_cmpi_tst when ir_high = cmpi_tst else
             ic_alusp_sub when ir_high = alusp_sub else
             ic_alusp_add when ir_high = alusp_add else
             ic_stk_pushr when ir_high = stk_pushr else
             ic_stk_pushf when ir_high = stk_pushf else
             ic_stk_popr when ir_high = stk_popr else
             ic_stk_popf when ir_high = stk_popf else
             ic_acall when ir_high = acall else
             ic_lcall when ir_high = lcall else
             ic_scall when ir_high(7 downto 3) = scall else  
             ic_ret when ir_high(7 downto 3) = ret else
             ic_int when ir_high(7 downto 3) = int else
             ic_into when ir_high(7 downto 3) = into else
             ic_iret when ir_high(7 downto 3) = iret else
             ic_ajmp when ir_high = ajmp else
             ic_ljmp when ir_high = ljmp else
             ic_sjmp when ir_high(7 downto 3) = sjmp else 
             ic_jcc when ir_high(7 downto 3) = jcc else
             ic_fop_clc when ir_high = fop_clc else
             ic_fop_stc when ir_high = fop_stc else
             ic_fop_cmc when ir_high = fop_cmc else
             ic_fop_cli when ir_high = fop_cli else
             ic_fop_sti when ir_high = fop_sti else
             ic_nop when ir_high(7 downto 3) = nop else
             ic_hlt when ir_high(7 downto 3) = hlt else
             ic_invalid;

   process(cur_state, cur_ic, jcc_ok, int_flag, pc0, sp0, tr20, mar0, ir_high,
           ack_sync, intr_sync, rst_sync)
   begin
      SEL_O <= "00"; 
      STB_O <= '0'; 
      CYC_O <= '0'; 
      WE_O <= '0'; 
      INTA_CYC_O <= '0';
      C_CYC_O <= '0'; 
      I_CYC_O <= '0'; 
      D_CYC_O <= '0'; 
      intr_ce <= '0';
      ir_ce <= '0'; 
      mdri_ce <= '0'; 
      mdri_hl_zse_sign <= '0'; 
      intno_mux_sel <= "000";
      adin_mux_sel <= "000"; 
      rf_adwe <= '0'; 
      pcin_mux_sel <= "00"; 
      pc_pre <= '0';
      pc_ce <= '0'; 
      spin_mux_sel <= '0'; 
      sp_pre <= '0'; 
      sp_ce <= '0';
      alua_mux_sel <= "00"; 
      alub_mux_sel <= "000"; 
      sbin_mux_sel <= '0';
      asopsel <= "0000"; 
      coszin_mux_sel <= '0'; 
      flags_rst <= '0';
      flags_ce <= '0'; 
      flags_cfce <= '0'; 
      flags_ifce <= '0';
      flags_clc <= '0'; 
      flags_cmc <= '0'; 
      flags_stc <= '0';
      flags_cli <= '0'; 
      flags_sti <= '0'; 
      marin_mux_sel <= "00";
      mar_ce <= '0'; 
      dfh_ce <= '0'; 
      mdroin_mux_sel <= "000";
      mdro_ce <= '0'; 
      mdro_oe <= '0';
      intr_sync_rst <= '0';
      
      case cur_state is
--//////////////////////////////////////
         when reset =>
            pc_pre <= '1'; 
            flags_rst <= '1';
            -- @new start
            sp_pre <= '1';
            -- @new end
            if rst_sync = '0' then
               nxt_state <= fetch0;
            else
               nxt_state <= reset;
            end if;
--//////////////////////////////////////
         when fetch0 =>
            if pc0 = '0' then
               -- mar = pc
               marin_mux_sel <= marin_mux_sel_pc;
               mar_ce <= '1';
               -- pc += 2
               alua_mux_sel <= alua_mux_sel_pc;
               alub_mux_sel <= alub_mux_sel_2;
               asopsel <= asopsel_add;
               pcin_mux_sel <= pcin_mux_sel_aluout;
               pc_ce <= '1';
               --
               nxt_state <= fetch1;
            else
               nxt_state <= align0;
            end if;
--///////////////////////////////////////
         when fetch1 =>
            -- read instruction; note STB_O is one shot
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; I_CYC_O <= '1';
            -- prepare ir
            ir_ce <= '1';
            --
            nxt_state <= fetch2;
--///////////////////////////////////////         
         when fetch2 =>
            if ack_sync = '1' then
               -- read end
               nxt_state <= exec0;
            else
               -- continue read & prepare ir 
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; I_CYC_O <= '1';
               ir_ce <= '1';
               --
               nxt_state <= fetch2;
            end if;
--///////////////////////////////////////
         when exec0 =>
            case cur_ic is
            ----------------------------------------------
               when ic_mov_rn_rm =>
                  -- rn = tr2
                  adin_mux_sel <= adin_mux_sel_tr2;
                  rf_adwe <= '1';
                  --
                  nxt_state <= int_chk;
            ----------------------------------------------
               when ic_mov_sp_rm =>
                  -- sp = (tr2 + 0)
                  alua_mux_sel <= alua_mux_sel_tr2;
                  alub_mux_sel <= alub_mux_sel_0;
                  asopsel <= asopsel_add;
                  spin_mux_sel <= spin_mux_sel_aluout;
                  sp_ce <= '1';
                  --
                  nxt_state <= int_chk;
            ----------------------------------------------
               when ic_mov_rn_sp =>
                  -- rn = sp
                  adin_mux_sel <= adin_mux_sel_sp;
                  rf_adwe <= '1';
                  --
                  nxt_state <= int_chk;
            ----------------------------------------------
               when ic_ld_rn_rb =>
                  if tr20 = '0' then 
                  -- mar = tr2 + 0
                     alua_mux_sel <= alua_mux_sel_tr2;
                     alub_mux_sel <= alub_mux_sel_0;
                     asopsel <= asopsel_add;
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                  -- 
                     nxt_state <= exec1;
                  else
                     nxt_state <= align0;
                  end if;
            ----------------------------------------------
               when ic_ld_rn_rb_disp | ic_ld_rn_sp_disp | 
                    ic_st_rn_rb_disp | ic_st_rn_sp_disp |
                    ic_lbzx_rn_rb_disp | ic_lbsx_rn_rb_disp |
                    ic_sb_rn_rb_disp | ic_li_rn | 
                    ic_li_sp | ic_alui | ic_cmpi_cmp | 
                    ic_cmpi_tst | ic_alusp_add | ic_alusp_sub =>
                  -- mar = pc
                  marin_mux_sel <= marin_mux_sel_pc;
                  mar_ce <= '1';
                  -- pc += 2
                  alua_mux_sel <= alua_mux_sel_pc;
                  alub_mux_sel <= alub_mux_sel_2;
                  asopsel <= asopsel_add;
                  pcin_mux_sel <= pcin_mux_sel_aluout;
                  pc_ce <= '1';
                  --
                  nxt_state <= exec1;
            ----------------------------------------------
               when ic_ld_rn_sp =>
                  if sp0 = '0' then
                     -- mar = sp
                     marin_mux_sel <= marin_mux_sel_sp;
                     mar_ce <= '1';                     
                     --
                     nxt_state <= exec1;
                  else
                     -- dfh = sp
                     dfh_ce <= '1';
                     --
                     nxt_state <= stkerr0;
                  end if;
            ----------------------------------------------
               when ic_st_rn_rb =>
                  if tr20 = '0' then
                     -- mar = tr2 + 0
                     alua_mux_sel <= alua_mux_sel_tr2;
                     alub_mux_sel <= alub_mux_sel_0;
                     asopsel <= asopsel_add;
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                     -- mdro = tr1
                     mdroin_mux_sel <= mdroin_mux_sel_tr1;
                     mdro_ce <= '1';
                     --! mdro_oe <= '1';
                     --
                     nxt_state <= exec1;
                  else
                     nxt_state <= align0;
                  end if;
            ----------------------------------------------
               when ic_st_rn_sp =>
                  if sp0 = '0' then
                  -- mar = sp
                     marin_mux_sel <= marin_mux_sel_sp;
                     mar_ce <= '1';
                  -- mdro = tr1
                     mdroin_mux_sel <= mdroin_mux_sel_tr1;
                     mdro_ce <= '1';
                     --! mdro_oe <= '1';
                  --
                     nxt_state <= exec1;                     
                  else
                  -- dfh = sp
                     dfh_ce <= '1';
                  --
                     nxt_state <= stkerr0;
                  end if;
            ----------------------------------------------
               when ic_lbzx_rn_rb | ic_lbsx_rn_rb =>
                  -- mar = tr2 + 0
                  alua_mux_sel <= alua_mux_sel_tr2;
                  alub_mux_sel <= alub_mux_sel_0;
                  asopsel <= asopsel_add;
                  marin_mux_sel <= marin_mux_sel_aluout;
                  mar_ce <= '1';
                  --
                  nxt_state <= exec1;
            ---------------------------------------------- 
               when ic_sb_rn_rb =>
                  -- mar = tr2 + 0
                  alua_mux_sel <= alua_mux_sel_tr2;
                  alub_mux_sel <= alub_mux_sel_0;
                  asopsel <= asopsel_add;
                  marin_mux_sel <= marin_mux_sel_aluout;
                  mar_ce <= '1';
                  -- 
                  if tr20 = '0' then
                    -- mdro = tr1(7..0) & 0000_0000
                    mdroin_mux_sel <= mdroin_mux_sel_tr1_loweven;
                  else
                    -- mdro = 0000_0000 & tr1(7..0)
                    mdroin_mux_sel <= mdroin_mux_sel_tr1_lowodd;
                  end if;
                  mdro_ce <= '1';
                  --! mdro_oe <= '1';
                  --
                  nxt_state <= exec1;
            ----------------------------------------------
               when ic_sing_inc =>
                  -- tr5 = tr1 + 1
                  alua_mux_sel <= alua_mux_sel_tr1;
                  alub_mux_sel <= alub_mux_sel_1;
                  asopsel <= asopsel_add;
                  -- flags updated (except cf, if)
                  coszin_mux_sel <= coszin_mux_sel_asresult;
                  flags_ce <= '1';
                  --
                  nxt_state <= exec1;
            ----------------------------------------------
               when ic_sing_dec =>
                  -- tr5 = tr1 - 1
                  alua_mux_sel <= alua_mux_sel_tr1;
                  alub_mux_sel <= alub_mux_sel_1;
                  asopsel <= asopsel_sub;
                  -- flags updated (except cf, if)
                  coszin_mux_sel <= coszin_mux_sel_asresult;
                  flags_ce <= '1';
                  -- 
                  nxt_state <= exec1;
            ----------------------------------------------
               when ic_alur =>
                  -- tr5 = tr1 aluop tr2
                  alua_mux_sel <= alua_mux_sel_tr1;
                  alub_mux_sel <= alub_mux_sel_tr2;
                  case ir_high(2 downto 0) is
                     when a_sub =>
                        asopsel <= asopsel_sub;
                     when a_add =>
                        asopsel <= asopsel_add;
                     when a_sbb =>
                        asopsel <= asopsel_sbb;
                     when a_adc =>
                        asopsel <= asopsel_adc;
                     when a_not =>
                        asopsel <= asopsel_not;
                     when a_and =>
                        asopsel <= asopsel_and;
                     when a_or  =>
                        asopsel <= asopsel_or;
                     when a_xor =>
                        asopsel <= asopsel_xor;
                     when others =>
                        asopsel <= (others => '0');
                  end case;
                  -- flags updated (except if)
                  coszin_mux_sel <= coszin_mux_sel_asresult;
                  flags_ce <= '1';
                  flags_cfce <= '1';
                  --
                  nxt_state <= exec1;
            ----------------------------------------------
                when ic_shiftr =>
                  -- tr5 = tr1 shiftop tr2
                  sbin_mux_sel <= sbin_mux_sel_tr2;                  
                  case ir_high(2 downto 0) is
                     when s_sll =>
                        asopsel <= asopsel_sll;
                     when s_slr =>
                        asopsel <= asopsel_slr;
                     when s_sal =>
                        asopsel <= asopsel_sal;
                     when s_sar =>
                        asopsel <= asopsel_sar;
                     when s_rol =>
                        asopsel <= asopsel_rol;
                     when s_ror =>
                        asopsel <= asopsel_ror;
                     when s_rcl  =>
                        asopsel <= asopsel_rcl;
                     when s_rcr =>
                        asopsel <= asopsel_rcr;
                     when others =>
                        asopsel <= (others => '0');
                  end case;
                  -- flags updated (except if)
                  coszin_mux_sel <= coszin_mux_sel_asresult;
                  flags_ce <= '1';
                  flags_cfce <= '1';
                  --
                  nxt_state <= exec1;
            ----------------------------------------------
               when ic_cmp_cmp =>
                  -- tr5 = tr1 - tr2
                  alua_mux_sel <= alua_mux_sel_tr1;
                  alub_mux_sel <= alub_mux_sel_tr2;
                  asopsel <= asopsel_sub;
                  -- flags updated (except if)
                  coszin_mux_sel <= coszin_mux_sel_asresult;
                  flags_ce <= '1';
                  flags_cfce <= '1';
                  --
                  nxt_state <= int_chk;
            ----------------------------------------------      
               when ic_cmp_tst =>
                  -- tr5 = tr1 and tr2
                  alua_mux_sel <= alua_mux_sel_tr1;
                  alub_mux_sel <= alub_mux_sel_tr2;
                  asopsel <= asopsel_and;
                  -- flags updated (except if)
                  coszin_mux_sel <= coszin_mux_sel_asresult;
                  flags_ce <= '1';
                  flags_cfce <= '1';
                  --
                  nxt_state <= int_chk;
            ----------------------------------------------
                when ic_shifti =>
                  -- tr5 = tr1 shiftop ir(3..0)
                  sbin_mux_sel <= sbin_mux_sel_ir;                  
                  case ir_high(2 downto 0) is
                     when s_sll =>
                        asopsel <= asopsel_sll;
                     when s_slr =>
                        asopsel <= asopsel_slr;
                     when s_sal =>
                        asopsel <= asopsel_sal;
                     when s_sar =>
                        asopsel <= asopsel_sar;
                     when s_rol =>
                        asopsel <= asopsel_rol;
                     when s_ror =>
                        asopsel <= asopsel_ror;
                     when s_rcl  =>
                        asopsel <= asopsel_rcl;
                     when s_rcr =>
                        asopsel <= asopsel_rcr;
                     when others =>
                        asopsel <= (others => '0');
                  end case;
                  -- flags updated (except if)
                  coszin_mux_sel <= coszin_mux_sel_asresult;
                  flags_ce <= '1';
                  flags_cfce <= '1';
                  --
                  nxt_state <= exec1;
            ----------------------------------------------      
               when ic_stk_pushr =>
                  if sp0 = '0' then
                     -- 
                     alua_mux_sel <= alua_mux_sel_sp;
                     alub_mux_sel <= alub_mux_sel_2;
                     asopsel <= asopsel_sub;
                     -- sp = old sp - 2
                     spin_mux_sel <= spin_mux_sel_aluout;
                     sp_ce <= '1';
                     -- mar = old sp - 2
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                     -- mdro = tr1
                     mdroin_mux_sel <= mdroin_mux_sel_tr1;                       
                     mdro_ce <= '1';
                     --! mdro_oe <= '1';
                     --
                     nxt_state <= exec1;
                  else
                     -- dfh = sp
                     dfh_ce <= '1';
                     nxt_state <= stkerr0;
                  end if;
            ----------------------------------------------
               when ic_stk_pushf =>
                  if sp0 = '0' then
                     -- 
                     alua_mux_sel <= alua_mux_sel_sp;
                     alub_mux_sel <= alub_mux_sel_2;
                     asopsel <= asopsel_sub;
                     -- sp = old sp - 2
                     spin_mux_sel <= spin_mux_sel_aluout;
                     sp_ce <= '1';
                     -- mar = old sp - 2
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                     -- mdro = flags
                     mdroin_mux_sel <= mdroin_mux_sel_flags;                       
                     mdro_ce <= '1';
                     --! mdro_oe <= '1';
                     --
                     nxt_state <= exec1;
                  else
                     -- dfh = sp
                     dfh_ce <= '1';
                     --
                     nxt_state <= stkerr0;
                  end if;            
            ----------------------------------------------
               when ic_stk_popr | ic_stk_popf | ic_ret | ic_iret =>
                  if sp0 = '0' then
                     -- 
                     alua_mux_sel <= alua_mux_sel_sp;
                     alub_mux_sel <= alub_mux_sel_2;
                     asopsel <= asopsel_add;
                     -- sp = old sp + 2
                     spin_mux_sel <= spin_mux_sel_aluout;
                     sp_ce <= '1';
                     -- mar = old sp 
                     marin_mux_sel <= marin_mux_sel_sp;
                     mar_ce <= '1';
                     --
                     nxt_state <= exec1;
                  else
                     -- dfh = sp
                     dfh_ce <= '1';
                     --
                     nxt_state <= stkerr0;
                  end if;          
            ---------------------------------------------
               when ic_acall | ic_lcall | ic_scall =>
                  if sp0 = '0' then
                     alua_mux_sel <= alua_mux_sel_sp;
                     alub_mux_sel <= alub_mux_sel_2;
                     asopsel <= asopsel_sub;
                     -- sp = old sp - 2
                     spin_mux_sel <= spin_mux_sel_aluout;
                     sp_ce <= '1';
                     -- mar = old sp - 2
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                     -- mdro = pc
                     mdroin_mux_sel <= mdroin_mux_sel_pc;
                     mdro_ce <= '1';
                     --! mdro_oe <= '1';
                     --
                     nxt_state <= exec1;
                  else
                     -- dfh =sp
                     dfh_ce <= '1';
                     --
                     nxt_state <= stkerr0;
                  end if;                     
            ---------------------------------------------
               when ic_int =>
                  if sp0 = '0' then
                     alua_mux_sel <= alua_mux_sel_sp;
                     alub_mux_sel <= alub_mux_sel_2;
                     asopsel <= asopsel_sub;
                     -- sp = old sp - 2
                     spin_mux_sel <= spin_mux_sel_aluout;
                     sp_ce <= '1';
                     -- mar = old sp - 2
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                     -- mdro = flags
                     mdroin_mux_sel <= mdroin_mux_sel_flags;
                     mdro_ce <= '1';
                     --! mdro_oe <= '1';
                     --
                     nxt_state <= exec1;
                  else
                     -- mdro = intno
                     intno_mux_sel <= intno_mux_sel_ir;
                     mdroin_mux_sel <= mdroin_mux_sel_intno;
                     mdro_ce <= '1';
                     --! mdro_oe <= '1';
                     -- dfh =sp
                     dfh_ce <= '1';
                     --
                     nxt_state <= df0;
                  end if;           
            ---------------------------------------------
               when ic_into =>
                  if sp0 = '0' then
                     if jcc_ok = '0' then
                        alua_mux_sel <= alua_mux_sel_sp;
                        alub_mux_sel <= alub_mux_sel_2;
                        asopsel <= asopsel_sub;
                        -- sp = old sp - 2
                        spin_mux_sel <= spin_mux_sel_aluout;
                        sp_ce <= '1';
                        -- mar = old sp - 2
                        marin_mux_sel <= marin_mux_sel_aluout;
                        mar_ce <= '1';
                        -- mdro = flags
                        mdroin_mux_sel <= mdroin_mux_sel_flags;
                        mdro_ce <= '1';
                        --! mdro_oe <= '1';
                        --
                        nxt_state <= exec1;
                     else
                        nxt_state <= int_chk;
                     end if;   
                  else
                     -- mdro = intno
                     intno_mux_sel <= intno_mux_sel_ir;
                     mdroin_mux_sel <= mdroin_mux_sel_intno;
                     mdro_ce <= '1';
                     --! mdro_oe <= '1';
                     -- dfh =sp
                     dfh_ce <= '1';
                     --
                     nxt_state <= df0;
                  end if;    
            ---------------------------------------------
               when ic_ajmp =>
                  -- pc = tr2
                  alua_mux_sel <= alua_mux_sel_tr2;
                  alub_mux_sel <= alub_mux_sel_0;
                  asopsel <= asopsel_add;                  
                  pcin_mux_sel <= pcin_mux_sel_aluout;
                  pc_ce <= '1';
                  --
                  nxt_state <= int_chk;
            --------------------------------------------
               when ic_ljmp =>
                  -- pc += tr2
                  alua_mux_sel <= alua_mux_sel_pc;
                  alub_mux_sel <= alub_mux_sel_tr2;
                  asopsel <= asopsel_add;                  
                  pcin_mux_sel <= pcin_mux_sel_aluout;
                  pc_ce <= '1';
                  --
                  nxt_state <= int_chk;            
            ---------------------------------------------
                when ic_sjmp =>
                  -- pc += tr3
                  alua_mux_sel <= alua_mux_sel_pc;
                  alub_mux_sel <= alub_mux_sel_tr3;
                  asopsel <= asopsel_add;                  
                  pcin_mux_sel <= pcin_mux_sel_aluout;
                  pc_ce <= '1';
                  --
                  nxt_state <= int_chk;
            ----------------------------------------------      
                when ic_jcc =>
                  if jcc_ok = '1' then  
                     -- pc += tr4
                     alua_mux_sel <= alua_mux_sel_pc;
                     alub_mux_sel <= alub_mux_sel_tr4;
                     asopsel <= asopsel_add;                  
                     pcin_mux_sel <= pcin_mux_sel_aluout;
                     pc_ce <= '1';
                     --                     
                  else
                     null;
                  end if;   
                  nxt_state <= int_chk;
            ----------------------------------------------
               when ic_fop_clc =>
                  flags_clc <= '1';
                  nxt_state <= int_chk;
            ----------------------------------------------
               when ic_fop_cmc =>
                  flags_cmc <= '1';
                  nxt_state <= int_chk;
            ----------------------------------------------      
               when ic_fop_stc =>
                  flags_stc <= '1';
                  nxt_state <= int_chk;
            ----------------------------------------------
               when ic_fop_cli =>
                  flags_cli <= '1';
                  nxt_state <= int_chk;
            ----------------------------------------------
               when ic_fop_sti =>
                  flags_sti <= '1';
                  nxt_state <= int_chk;
            ----------------------------------------------
               when ic_nop =>
                  nxt_state <= int_chk;
            ----------------------------------------------
               when ic_hlt =>
                  --flags_sti <= '1';
                  nxt_state <= halted;
            ----------------------------------------------
               when ic_invalid =>
                  nxt_state <= invalid0;
            ----------------------------------------------      
            end case;
--///////////////////////////////////////            
         when exec1 =>
            case cur_ic is
            ----------------------------------------------
               when ic_ld_rn_rb | ic_ld_rn_sp | ic_stk_popr | 
                    ic_stk_popf | ic_ret | ic_iret =>
                  -- read data word
                  SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; D_CYC_O <= '1';
                  -- prepare mdri
                  mdri_ce <= '1';
                  --
                  nxt_state <= exec2;
            ---------------------------------------------
               when ic_ld_rn_rb_disp | ic_ld_rn_sp_disp |
                    ic_st_rn_rb_disp | ic_st_rn_sp_disp |
                    ic_lbzx_rn_rb_disp | ic_lbsx_rn_rb_disp |
                    ic_sb_rn_rb_disp | ic_li_rn | ic_li_sp |
                    ic_alui | ic_cmpi_cmp | ic_cmpi_tst |
                    ic_alusp_add | ic_alusp_sub =>
                  -- read const word
                  SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; C_CYC_O <= '1';
                  -- prepare mdri
                  mdri_ce <= '1';
                  --
                  nxt_state <= exec2;
            --------------------------------------------
               when ic_st_rn_rb | ic_st_rn_sp | ic_stk_pushr | 
                    ic_stk_pushf | ic_acall | ic_lcall | ic_scall |
                    ic_int | ic_into =>
                  mdro_oe <= '1';
                  -- write data word
                  SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                  --
                  nxt_state <= exec2;
            -------------------------------------------      
               when ic_lbzx_rn_rb | ic_lbsx_rn_rb =>
                  -- read data byte
                  if mar0 = '0' then
                     SEL_O <= "10";   
                  else
                     SEL_O <= "01";
                  end if;
                  STB_O <= '1'; CYC_O <= '1'; D_CYC_O <= '1';
                  --
                  mdri_ce <= '1';
                  --
                  nxt_state <= exec2;
            --------------------------------------------
               when ic_sb_rn_rb =>
                  mdro_oe <= '1';
                  -- write data byte
                  if mar0 = '0' then
                     SEL_O <= "10";
                  else
                     SEL_O <= "01";
                  end if;                  
                  STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                  --
                  nxt_state <= exec2;
            --------------------------------------------
               when ic_sing_inc | ic_sing_dec | ic_alur |
                    ic_shiftr | ic_shifti =>
                  -- rn = tr5
                  adin_mux_sel <= adin_mux_sel_tr5;
                  rf_adwe <= '1';
                  --
                  nxt_state <= int_chk;
            --------------------------------------------
               when others =>
                  nxt_state <= halted; -- @new                  
            end case;
--///////////////////////////////////////
         when exec2 =>
            case cur_ic is
            ----------------------------------------------
               when ic_ld_rn_rb | ic_ld_rn_sp =>
                  if ack_sync = '1' then
                     -- rn = mdri
                     adin_mux_sel <= adin_mux_sel_mdri;
                     rf_adwe <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     -- try reading data word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; D_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;                     
                  end if;
            --------------------------------------------
               when ic_ld_rn_rb_disp |  
                    ic_lbzx_rn_rb_disp | ic_lbsx_rn_rb_disp =>
                  if ack_sync = '1' then
                     -- mar = tr2 + mdri
                     alua_mux_sel <= alua_mux_sel_tr2;
                     alub_mux_sel <= alub_mux_sel_mdri;
                     asopsel <= asopsel_add;
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                     --
                     nxt_state <= exec3; 
                  else
                     -- try reading const word data
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            --------------------------------------------
               when ic_ld_rn_sp_disp => 
                  if ack_sync = '1' then
                     -- mar = sp + mdri
                     alua_mux_sel <= alua_mux_sel_sp;
                     alub_mux_sel <= alub_mux_sel_mdri;
                     asopsel <= asopsel_add;
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                     --
                     nxt_state <= exec3; 
                  else
                     -- try reading const word data
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            --------------------------------------------
               when ic_st_rn_rb_disp =>
                  if ack_sync = '1' then
                     -- mar = tr2 + mdri
                     alua_mux_sel <= alua_mux_sel_tr2;
                     alub_mux_sel <= alub_mux_sel_mdri;
                     asopsel <= asopsel_add;
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                     -- mdro = tr1
                     mdroin_mux_sel <= mdroin_mux_sel_tr1;
                     mdro_ce <= '1';
                     --! mdro_oe <= '1';
                     --
                     nxt_state <= exec3; 
                  else
                     -- try reading const word data
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;
                  end if;            
            --------------------------------------------
               when ic_st_rn_sp_disp =>
                  if ack_sync = '1' then
                     -- mar = sp + mdri
                     alua_mux_sel <= alua_mux_sel_sp;
                     alub_mux_sel <= alub_mux_sel_mdri;
                     asopsel <= asopsel_add;
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                     -- mdro = tr1
                     mdroin_mux_sel <= mdroin_mux_sel_tr1;
                     mdro_ce <= '1';
                     --! mdro_oe <= '1';
                     --
                     nxt_state <= exec3; 
                  else
                     -- try reading const word data
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            --------------------------------------------
               when ic_st_rn_rb | ic_st_rn_sp =>
                  if ack_sync = '1' then
                     nxt_state <= int_chk;
                  else
                     mdro_oe <= '1';
                     -- try write data word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                     -- 
                     nxt_state <= exec2;
                  end if;
            --------------------------------------------
               when ic_lbzx_rn_rb =>
                  if ack_sync = '1' then
                     mdri_hl_zse_sign <= '0';
                     if mar0 = '0' then
                        adin_mux_sel <= adin_mux_sel_mdri_high;
                     else
                        adin_mux_sel <= adin_mux_sel_mdri_low;
                     end if;
                     rf_adwe <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     -- try read byte
                     if mar0 = '0' then
                        SEL_O <= "10";
                     else
                        SEL_O <= "01";
                     end if;
                     STB_O <= '0'; CYC_O <= '1'; D_CYC_O <= '1';
                     --
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            --------------------------------------------
               when ic_lbsx_rn_rb =>
                  if ack_sync = '1' then
                     mdri_hl_zse_sign <= '1';
                     if mar0 = '0' then
                        adin_mux_sel <= adin_mux_sel_mdri_high;
                     else
                        adin_mux_sel <= adin_mux_sel_mdri_low;
                     end if;
                     rf_adwe <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     -- try read byte
                     if mar0 = '0' then
                        SEL_O <= "10";
                     else
                        SEL_O <= "01";
                     end if;
                     STB_O <= '0'; CYC_O <= '1'; D_CYC_O <= '1';
                     --
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            --------------------------------------------
               when ic_sb_rn_rb =>
                  if ack_sync = '1' then
                     nxt_state <= int_chk;
                  else
                     mdro_oe <= '1';
                     -- try writing byte
                     if mar0 = '0' then
                        SEL_O <= "10";
                     else
                        SEL_O <= "01";   
                     end if;
                     STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            --------------------------------------------
              when ic_sb_rn_rb_disp =>
                  if ack_sync = '1' then
                     -- mar = tr2 + mdri
                     alua_mux_sel <= alua_mux_sel_tr2;
                     alub_mux_sel <= alub_mux_sel_mdri;
                     asopsel <= asopsel_add;
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                     nxt_state <= exec3; 
                  else
                     -- try reading const word data
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;
                  end if;            
            --------------------------------------------               
               when ic_li_rn =>
                  if ack_sync = '1' then
                     -- rn = mdri
                     adin_mux_sel <= adin_mux_sel_mdri;
                     rf_adwe <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     -- try reading const word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;                     
                  end if;
            --------------------------------------------
                 when ic_li_sp =>
                  if ack_sync = '1' then
                     -- sp = mdri
                     spin_mux_sel <= spin_mux_sel_mdri;
                     sp_ce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     -- try reading const word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;                     
                  end if;          
            --------------------------------------------
               when ic_alui =>
                  if ack_sync = '1' then
                     -- tr5 = tr1 aluop mdri
                     alua_mux_sel <= alua_mux_sel_tr1;
                     alub_mux_sel <= alub_mux_sel_mdri;
                     case ir_high(2 downto 0) is
                        when a_sub => 
                           asopsel <= asopsel_sub;
                        when a_add =>
                           asopsel <= asopsel_add;
                        when a_sbb =>
                           asopsel <= asopsel_sbb;
                        when a_adc =>
                           asopsel <= asopsel_adc;
                        when a_and =>
                           asopsel <= asopsel_and;
                        when a_or =>
                           asopsel <= asopsel_or;
                        when a_xor =>
                           asopsel <= asopsel_xor;
                        when others =>
                           asopsel <= (others => '0');
                     end case;
                     -- flags updated (except if)                     
                     coszin_mux_sel <= coszin_mux_sel_asresult;
                     flags_ce <= '1'; 
                     flags_cfce <= '1';
                     --
                     nxt_state <= exec3;
                  else
                     -- try reading const word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;                     
                  end if;
            --------------------------------------------
               when ic_cmpi_cmp =>
                  if ack_sync = '1' then 
                     -- tr5 = tr1 - mdri
                     alua_mux_sel <= alua_mux_sel_tr1;
                     alub_mux_sel <= alub_mux_sel_mdri;
                     asopsel <= asopsel_sub;
                     -- flags updated
                     coszin_mux_sel <= coszin_mux_sel_asresult;
                     flags_ce <= '1';
                     flags_cfce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     -- try reading const word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;                     
                  end if;                     
            --------------------------------------------
                when ic_cmpi_tst =>
                  if ack_sync = '1' then 
                     -- tr5 = tr1 and mdri
                     alua_mux_sel <= alua_mux_sel_tr1;
                     alub_mux_sel <= alub_mux_sel_mdri;
                     asopsel <= asopsel_and;
                     -- flags updated
                     coszin_mux_sel <= coszin_mux_sel_asresult;
                     flags_ce <= '1';
                     flags_cfce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     -- try reading const word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;                     
                  end if;          
            --------------------------------------------
                when ic_alusp_sub =>
                  if ack_sync = '1' then 
                     -- sp = sp - mdri
                     alua_mux_sel <= alua_mux_sel_sp;
                     alub_mux_sel <= alub_mux_sel_mdri;
                     asopsel <= asopsel_sub;
                     spin_mux_sel <= spin_mux_sel_aluout;
                     sp_ce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     -- try reading const word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;                     
                  end if;               
            --------------------------------------------
                when ic_alusp_add =>
                  if ack_sync = '1' then 
                     -- sp = sp + mdri
                     alua_mux_sel <= alua_mux_sel_sp;
                     alub_mux_sel <= alub_mux_sel_mdri;
                     asopsel <= asopsel_add;
                     spin_mux_sel <= spin_mux_sel_aluout;
                     sp_ce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     -- try reading const word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; C_CYC_O <= '1';
                     -- prepare mdri
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;                     
                  end if;               
            --------------------------------------------
                when ic_stk_pushr | ic_stk_pushf =>
                  if ack_sync = '1' then
                     nxt_state <= int_chk;
                  else
                     mdro_oe <= '1'; 
                     -- try writing data word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            --------------------------------------------
               when ic_stk_popr =>
                  if ack_sync = '1'then
                     -- rn = mdri
                     adin_mux_sel <= adin_mux_sel_mdri;
                     rf_adwe <= '1';
                     nxt_state <= int_chk;
                  else
                     -- try reading data word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; D_CYC_O <= '1';
                     --
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            --------------------------------------------
               when ic_stk_popf =>
                  if ack_sync = '1' then
                     -- flags = mdri
                     coszin_mux_sel <= coszin_mux_sel_mdri;
                     flags_ce <= '1';
                     flags_cfce <= '1';
                     flags_ifce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     -- try reading word data 
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; D_CYC_O <= '1';
                     --
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;                     
                  end if;
            --------------------------------------------
               when ic_acall =>
                  if ack_sync = '1' then
                     -- pc = tr2
                     alua_mux_sel <= alua_mux_sel_tr2;
                     alub_mux_sel <= alub_mux_sel_0;
                     asopsel <= asopsel_add;
                     pcin_mux_sel <= pcin_mux_sel_aluout;
                     pc_ce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     mdro_oe <= '1';
                     -- try writing data word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            --------------------------------------------
               when ic_lcall =>
                  if ack_sync = '1' then
                     -- pc += tr2
                     alua_mux_sel <= alua_mux_sel_pc;
                     alub_mux_sel <= alub_mux_sel_tr2;
                     asopsel <= asopsel_add;
                     pcin_mux_sel <= pcin_mux_sel_aluout;
                     pc_ce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     mdro_oe <= '1';
                     -- try writing data word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            ------------------------------------------
                when ic_scall =>
                  if ack_sync = '1' then
                     -- pc += tr2
                     alua_mux_sel <= alua_mux_sel_pc;
                     alub_mux_sel <= alub_mux_sel_tr3;
                     asopsel <= asopsel_add;
                     pcin_mux_sel <= pcin_mux_sel_aluout;
                     pc_ce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     mdro_oe <= '1';
                     -- try writing data word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec2;
                  end if;           
            -----------------------------------------
               when ic_ret =>
                  if ack_sync = '1' then
                     -- pc = mdri
                     pcin_mux_sel <= pcin_mux_sel_mdri;
                     pc_ce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     -- try reading data word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; D_CYC_O <= '1';
                     --
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            -------------------------------------------  
               when ic_int | ic_into =>
                  if ack_sync = '1' then                  
                     alua_mux_sel <= alua_mux_sel_sp;
                     alub_mux_sel <= alub_mux_sel_2;
                     asopsel <= asopsel_sub;
                     -- mar = old sp -2
                     marin_mux_sel <= marin_mux_sel_aluout;
                     mar_ce <= '1';
                     -- sp = old sp - 2
                     spin_mux_sel <= spin_mux_sel_aluout;
                     sp_ce <= '1';
                     -- mdro = pc
                     mdroin_mux_sel <= mdroin_mux_sel_pc;
                     mdro_ce <= '1';
                     --! mdro_oe <= '1';
                     --
                     nxt_state <= exec3;
                  else
                     mdro_oe <= '1';
                     -- try writing data word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec2;
                  end if;                 
            -----------------------------------------
               when ic_iret =>
                  if ack_sync = '1' then
                     -- pc = mdri
                     pcin_mux_sel <= pcin_mux_sel_mdri;
                     pc_ce <= '1';
                     -- sp = old sp + 2
                     alua_mux_sel <= alua_mux_sel_sp;
                     alub_mux_sel <= alub_mux_sel_2;
                     asopsel <= asopsel_add;
                     spin_mux_sel <= spin_mux_sel_aluout;
                     -- mar = sp
                     marin_mux_sel <= marin_mux_sel_sp;
                     mar_ce <= '1';
                     --
                     nxt_state <= exec3;
                  else
                     -- try reading data word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; D_CYC_O <= '1';
                     --
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec2;
                  end if;
            --------------------------------------------
               when others =>
                  nxt_state <= halted; -- @new
             -------------------------------------------
            end case;                  
--///////////////////////////////////////            
         when exec3 =>
            case cur_ic is
            ----------------------------------------------
               when ic_ld_rn_rb_disp | ic_ld_rn_sp_disp =>
                  if mar0 = '0' then
                     -- try reading data word
                     SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; D_CYC_O <= '1';
                     --
                     mdri_ce <= '1';
                     --
                     nxt_state <= exec4;                     
                  else
                     nxt_state <= align0;
                  end if;
            ----------------------------------------------
               when ic_st_rn_rb_disp | ic_st_rn_sp_disp =>
                  if mar0 = '0' then
                     mdro_oe <= '1';
                  -- try writing data word
                     SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                  --
                     nxt_state <= exec4;
                  else
                     nxt_state <= align0;
                  end if;
            ----------------------------------------------
               when ic_lbzx_rn_rb_disp | ic_lbsx_rn_rb_disp =>
                  -- try reading data byte
                  if mar0 = '0' then
                     SEL_O <= "10";
                  else
                     SEL_O <= "01";
                  end if;
                  STB_O <= '1'; CYC_O <= '1'; D_CYC_O <= '1';
                  --
                  mdri_ce <= '1';
                  --
                  nxt_state <= exec4;
            ----------------------------------------------
               when ic_sb_rn_rb_disp =>
                  --! mdro_oe <= '1';
                  mdro_ce <= '1';
                  if mar0 = '0' then
                     mdroin_mux_sel <= mdroin_mux_sel_tr1_loweven;
                  else
                     mdroin_mux_sel <= mdroin_mux_sel_tr1_lowodd;
                  end if;
                  nxt_state <= exec4;
            ----------------------------------------------
               when ic_alui =>
                  -- rn = tr5
                  adin_mux_sel <= adin_mux_sel_tr5;
                  rf_adwe <= '1';
                  --
                  nxt_state <= int_chk;
            ----------------------------------------------
               when ic_int | ic_into =>
                  mdro_oe <= '1';
                  -- try writting word
                  SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                  --
                  nxt_state <= exec4; 
            ----------------------------------------------
               when ic_iret =>
                  mdri_ce <= '1';
                  -- try reading word
                  SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; D_CYC_O <= '1';
                  --
                  nxt_state <= exec4;
            ----------------------------------------------
               when others =>
                  nxt_state <= halted; -- @new
            ----------------------------------------------
            end case;
--///////////////////////////////////////
         when exec4 =>
            case cur_ic is
            ----------------------------------------------
               when ic_ld_rn_rb_disp | ic_ld_rn_sp_disp =>
                  if ack_sync = '1' then
                     adin_mux_sel <= adin_mux_sel_mdri;
                     rf_adwe <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     mdri_ce <= '1';
                     -- read data word                     
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec4;
                  end if;
            ----------------------------------------------      
               when ic_st_rn_rb_disp | ic_st_rn_sp_disp =>
                  if ack_sync = '1' then
                     nxt_state <= int_chk;
                  else
                     mdro_oe <= '1';
                     -- write data word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec4;
                  end if;
            ----------------------------------------------
               when ic_lbzx_rn_rb_disp =>
                  if ack_sync = '1' then
                     mdri_hl_zse_sign <= '0';
                     if mar0 = '0' then
                        adin_mux_sel <= adin_mux_sel_mdri_high;   
                     else
                        adin_mux_sel <= adin_mux_sel_mdri_low;
                     end if;
                     rf_adwe <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     mdri_ce <= '1';
                     if mar0 = '0' then
                        SEL_O <= "10";
                     else
                        SEL_O <= "01";
                     end if;
                     STB_O <= '0'; CYC_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec4;
                  end if;
            ----------------------------------------------      
                when ic_lbsx_rn_rb_disp =>
                  if ack_sync = '1' then
                     mdri_hl_zse_sign <= '1';
                     if mar0 = '0' then
                        adin_mux_sel <= adin_mux_sel_mdri_high;   
                     else
                        adin_mux_sel <= adin_mux_sel_mdri_low;
                     end if;
                     rf_adwe <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     mdri_ce <= '1';
                     if mar0 = '0' then
                        SEL_O <= "10";
                     else
                        SEL_O <= "01";
                     end if;
                     STB_O <= '0'; CYC_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec4;
                  end if;           
            ----------------------------------------------
               when ic_sb_rn_rb_disp =>
                  mdro_oe <= '1';
                  -- write byte
                  if mar0 = '0' then 
                     SEL_O <= "10";   
                  else
                     SEL_O <= "01";
                  end if;
                  STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                  --
                  nxt_state <= exec5;                  
            ----------------------------------------------      
               when ic_int | ic_into =>
                  if ack_sync = '1' then
                     -- pc = ext(ir(3..0))
                     intno_mux_sel <= intno_mux_sel_ir;
                     pcin_mux_sel <= pcin_mux_sel_intno;
                     pc_ce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     mdro_oe <= '1';
                     -- write word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec4;
                  end if;
            ----------------------------------------------
               when ic_iret =>
                  if ack_sync = '1' then
                     -- flags = mdri
                     coszin_mux_sel <= coszin_mux_sel_mdri;
                     flags_ce <= '1';
                     flags_cfce <= '1';
                     flags_ifce <= '1';
                     --
                     nxt_state <= int_chk;
                  else
                     mdri_ce <= '1';
                     -- try reading word
                     SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; D_CYC_O <= '1';
                     --
                     nxt_state <= exec4;                   
                  end if;
            ---------------------------------------------- 
               when others => 
                  nxt_state <= halted; -- @new
            ----------------------------------------------              
            end case;      
--///////////////////////////////////////
   when exec5 =>
      case cur_ic is   
         when ic_sb_rn_rb_disp =>
            if ack_sync = '1' then
               nxt_state <= int_chk;
            else
               mdro_oe <= '1';
               -- write byte
               if mar0 = '0' then
                  SEL_O <= "10";
               else
                  SEL_O <= "01";
               end if;
               STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               --
               nxt_state <= exec5;
            end if;
         when others =>
            nxt_state <= halted; -- @new
      end case;      
--///////////////////////////////////////
         when int_chk =>
            if int_flag = '1' then
               if intr_sync = '1' then
                  -- read vector no.
                  SEL_O <= "10"; STB_O <= '1'; CYC_O <= '1'; INTA_CYC_O <= '1';
                  -- prepare intr
                  intr_ce <= '1';
                  -- clear intr_sync
                  intr_sync_rst <= '1';
                  -- clear IF 
                  flags_cli <= '1';
                  --
                  nxt_state <= int0;
               else
                  nxt_state <= fetch0;
               end if;
            else
               nxt_state <= fetch0;
            end if;
--///////////////////////////////////////
         when int0 =>
            if ack_sync = '1' then
               if sp0 = '0' then
                  -- mar = old sp - 2
                  alua_mux_sel <= alua_mux_sel_sp;
                  alub_mux_sel <= alub_mux_sel_2;
                  asopsel <= asopsel_sub;
                  marin_mux_sel <= marin_mux_sel_aluout;
                  mar_ce <= '1';
                  -- sp = old sp - 2
                  spin_mux_sel <= spin_mux_sel_aluout;
                  sp_ce <= '1';
                  -- mdro = flags
                  mdroin_mux_sel <= mdroin_mux_sel_flags;
                  mdro_ce <= '1';
                  --! mdro_oe <= '1';
                  --
                  nxt_state <= int1;
               else
                  -- mdro = intno
                  intno_mux_sel <= intno_mux_sel_intr;
                  mdroin_mux_sel <= mdroin_mux_sel_intno;
                  mdro_ce <= '1';
                  --! mdro_oe <= '1';
                  -- dfh = sp
                  dfh_ce <= '1';
                  --
                  nxt_state <= df0;
               end if;               
            else
               -- try reading vector number
               SEL_O <= "10"; STB_O <= '0'; CYC_O <= '1'; INTA_CYC_O <= '1';
               --
               intr_ce <= '1';
               --
               nxt_state <= int0;
            end if;
--///////////////////////////////////////
         when int1 =>
            -- write flags
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            --
            mdro_oe <= '1';
            --
            nxt_state <= int2;
--///////////////////////////////////////
         when int2 =>
            if ack_sync = '1' then
               alua_mux_sel <= alua_mux_sel_sp;
               alub_mux_sel <= alub_mux_sel_2;
               asopsel <= asopsel_sub;
               -- mar = old sp - 2
               marin_mux_sel <= marin_mux_sel_aluout;
               mar_ce <= '1';
               -- sp = old sp - 2
               spin_mux_sel <= spin_mux_sel_aluout;
               sp_ce <= '1';
               -- mdro = pc
               mdroin_mux_sel <= mdroin_mux_sel_pc;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               nxt_state <= int3;
            else
               -- try writing data word (flags)
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               --
               mdro_oe <= '1';
               --
               nxt_state <= int2;
            end if;
--///////////////////////////////////////
         when int3 =>
            -- write pc
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            --
            mdro_oe <= '1';
            --
            nxt_state <= int4;
--///////////////////////////////////////
         when int4 =>
            if ack_sync = '1' then
               intno_mux_sel <= intno_mux_sel_intr;
               pcin_mux_sel <= pcin_mux_sel_intno;
               pc_ce <= '1';
               --
               nxt_state <= fetch0;
            else
               -- writing pc 
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               --
               mdro_oe <= '1';
               --
               nxt_state <= int4;
            end if; 
--///////////////////////////////////////
         when invalid0 =>
            if sp0= '0' then
               -- push flag
               alua_mux_sel <= alua_mux_sel_sp;
               alub_mux_sel <= alub_mux_sel_2;
               asopsel <= asopsel_sub;
               --
               spin_mux_sel <= spin_mux_sel_aluout;
               sp_ce <= '1';
               --
               marin_mux_sel <= marin_mux_sel_aluout;
               mar_ce <= '1';
               --
               mdroin_mux_sel <= mdroin_mux_sel_flags;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               nxt_state <= invalid1;
            else
               -- in case of df
               -- move the vector no to 
               intno_mux_sel <= intno_mux_sel_invalid;
               mdroin_mux_sel <= mdroin_mux_sel_intno;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               dfh_ce <= '1';
               --
               nxt_state <= df0; 
            end if;          
--///////////////////////////////////////
         when invalid1 =>
            -- write flags
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            --
            mdro_oe <= '1';
            --
            nxt_state <= invalid2;
--///////////////////////////////////////
         when invalid2 =>
            if ack_sync = '1' then
               alua_mux_sel <= alua_mux_sel_sp;
               alub_mux_sel <= alub_mux_sel_2;
               asopsel <= asopsel_sub;
               -- mar = old sp - 2
               marin_mux_sel <= marin_mux_sel_aluout;
               mar_ce <= '1';
               -- sp = old sp - 2
               spin_mux_sel <= spin_mux_sel_aluout;
               sp_ce <= '1';
               -- mdro = pc
               mdroin_mux_sel <= mdroin_mux_sel_pc;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               nxt_state <= invalid3;
            else
               -- try writing data word (flags)
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               --
               mdro_oe <= '1';
               --
               nxt_state <= invalid2;
            end if;       
--///////////////////////////////////////
         when invalid3 =>
            -- write pc
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            --
            mdro_oe <= '1';
            --
            nxt_state <= invalid4;
--///////////////////////////////////////
         when invalid4 =>
            if ack_sync = '1' then
               intno_mux_sel <= intno_mux_sel_intr;
               pcin_mux_sel <= pcin_mux_sel_intno;
               pc_ce <= '1';
               --
               nxt_state <= fetch0;
            else
               -- writing pc 
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               --
               mdro_oe <= '1';
               --
               nxt_state <= invalid4;
            end if;  
--///////////////////////////////////////
         when align0 =>
            if sp0= '0' then
               -- push flag
               alua_mux_sel <= alua_mux_sel_sp;
               alub_mux_sel <= alub_mux_sel_2;
               asopsel <= asopsel_sub;
               --
               spin_mux_sel <= spin_mux_sel_aluout;
               sp_ce <= '1';
               --
               marin_mux_sel <= marin_mux_sel_aluout;
               mar_ce <= '1';
               --
               mdroin_mux_sel <= mdroin_mux_sel_flags;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               nxt_state <= align1;
            else
               -- in case of df
               -- move the vector no to 
               intno_mux_sel <= intno_mux_sel_align;
               mdroin_mux_sel <= mdroin_mux_sel_intno;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               dfh_ce <= '1';
               --
               nxt_state <= df0; 
            end if;          
--///////////////////////////////////////
         when align1 =>
            -- write flags
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            --
            mdro_oe <= '1';
            --
            nxt_state <= align2;
--///////////////////////////////////////
         when align2 =>
            if ack_sync = '1' then
               alua_mux_sel <= alua_mux_sel_sp;
               alub_mux_sel <= alub_mux_sel_2;
               asopsel <= asopsel_sub;
               -- mar = old sp - 2
               marin_mux_sel <= marin_mux_sel_aluout;
               mar_ce <= '1';
               -- sp = old sp - 2
               spin_mux_sel <= spin_mux_sel_aluout;
               sp_ce <= '1';
               -- mdro = pc
               mdroin_mux_sel <= mdroin_mux_sel_pc;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               nxt_state <= align3;
            else
               -- try writing data word (flags)
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               --
               mdro_oe <= '1';
               --
               nxt_state <= align2;
            end if;       
--///////////////////////////////////////
         when align3 =>
            -- write pc
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            --
            mdro_oe <= '1';
            --
            nxt_state <= align4;
--///////////////////////////////////////
         when align4 =>
            if ack_sync = '1' then
               intno_mux_sel <= intno_mux_sel_intr;
               pcin_mux_sel <= pcin_mux_sel_intno;
               pc_ce <= '1';
               --
               nxt_state <= fetch0;
            else
               -- writing pc 
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               --
               mdro_oe <= '1';
               --
               nxt_state <= align4;
            end if;  
--///////////////////////////////////////
         when stkerr0 =>
            sp_pre <= '1';
            nxt_state <= stkerr1;            
--//////////////////////////////////////            
         when stkerr1 =>
            alua_mux_sel <= alua_mux_sel_sp;
            alub_mux_sel <= alub_mux_sel_2;
            asopsel <= asopsel_sub;
            --
            marin_mux_sel <= marin_mux_sel_aluout;
            mar_ce <= '1';
            --
            spin_mux_sel <= spin_mux_sel_aluout;
            sp_ce <= '1';
            --
            mdroin_mux_sel <= mdroin_mux_sel_dfh;
            mdro_ce <= '1';
            --! mdro_oe <= '1';
            --
            nxt_state <= stkerr2;
--///////////////////////////////////////
         when stkerr2 =>
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            mdro_oe <= '1';
            nxt_state <= stkerr3;
--///////////////////////////////////////
         when stkerr3 =>
            if ack_sync ='1' then
               alua_mux_sel <= alua_mux_sel_sp;
               alub_mux_sel <= alub_mux_sel_2;
               asopsel <= asopsel_sub;
               --
               marin_mux_sel <= marin_mux_sel_aluout;
               mar_ce <= '1';
               --
               spin_mux_sel <= spin_mux_sel_aluout;
               sp_ce <= '1';
               --
               mdroin_mux_sel <= mdroin_mux_sel_flags;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               nxt_state <= stkerr4;              
            else
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               mdro_oe <= '1';
               nxt_state <= stkerr3;
            end if;
--///////////////////////////////////////
         when stkerr4 =>
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            mdro_oe <= '1';
            nxt_state <= stkerr5;
--///////////////////////////////////////
         when stkerr5 =>
            if ack_sync ='1' then
               alua_mux_sel <= alua_mux_sel_sp;
               alub_mux_sel <= alub_mux_sel_2;
               asopsel <= asopsel_sub;
               --
               marin_mux_sel <= marin_mux_sel_aluout;
               mar_ce <= '1';
               --
               spin_mux_sel <= spin_mux_sel_aluout;
               sp_ce <= '1';
               --
               mdroin_mux_sel <= mdroin_mux_sel_pc;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               nxt_state <= stkerr6;              
            else
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               mdro_oe <= '1';
               nxt_state <= stkerr5;
            end if;
--///////////////////////////////////////
         when stkerr6 => 
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            mdro_oe <= '1';
            nxt_state <= stkerr7;            
--///////////////////////////////////////
         when stkerr7 =>
            if ack_sync = '1' then
               intno_mux_sel <= intno_mux_sel_df;
               pcin_mux_sel <= pcin_mux_sel_intno;
               pc_ce <= '1';
               --
               nxt_state <= fetch0;               
            else
               -- writing pc 
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               --
               mdro_oe <= '1';
               --
               nxt_state <= stkerr7;            
            end if;
--///////////////////////////////////////
         when df0 =>
            sp_pre <= '1';
            nxt_state <= df1;            
--//////////////////////////////////////
         when df1 =>
            alua_mux_sel <= alua_mux_sel_sp;
            alub_mux_sel <= alub_mux_sel_2;
            asopsel <= asopsel_sub;
            --
            marin_mux_sel <= marin_mux_sel_aluout;
            mar_ce <= '1';
            --
            spin_mux_sel <= spin_mux_sel_aluout;
            sp_ce <= '1';            
            --
            nxt_state <= df2;
--//////////////////////////////////////
         when df2 =>
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            mdro_oe <= '1';
            nxt_state <= df3;
--//////////////////////////////////////            
         when df3 =>
            if ack_sync ='1' then
               alua_mux_sel <= alua_mux_sel_sp;
               alub_mux_sel <= alub_mux_sel_2;
               asopsel <= asopsel_sub;
               --
               marin_mux_sel <= marin_mux_sel_aluout;
               mar_ce <= '1';
               --
               spin_mux_sel <= spin_mux_sel_aluout;
               sp_ce <= '1';
               --
               mdroin_mux_sel <= mdroin_mux_sel_dfh;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               nxt_state <= df4;
            else
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               mdro_oe <= '1';
               nxt_state <= df3;            
            end if;
--///////////////////////////////////////
         when df4 =>
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            mdro_oe <= '1';
            nxt_state <= df5;
--///////////////////////////////////////
         when df5 =>
            if ack_sync ='1' then
               alua_mux_sel <= alua_mux_sel_sp;
               alub_mux_sel <= alub_mux_sel_2;
               asopsel <= asopsel_sub;
               --
               marin_mux_sel <= marin_mux_sel_aluout;
               mar_ce <= '1';
               --
               spin_mux_sel <= spin_mux_sel_aluout;
               sp_ce <= '1';
               --
               mdroin_mux_sel <= mdroin_mux_sel_flags;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               nxt_state <= df6;
            else
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               mdro_oe <= '1';
               nxt_state <= df5;            
            end if;
--///////////////////////////////////////            
         when df6 =>
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            mdro_oe <= '1';
            nxt_state <= df7;
--///////////////////////////////////////
         when df7 =>
            if ack_sync ='1' then
               alua_mux_sel <= alua_mux_sel_sp;
               alub_mux_sel <= alub_mux_sel_2;
               asopsel <= asopsel_sub;
               --
               marin_mux_sel <= marin_mux_sel_aluout;
               mar_ce <= '1';
               --
               spin_mux_sel <= spin_mux_sel_aluout;
               sp_ce <= '1';
               --
               mdroin_mux_sel <= mdroin_mux_sel_pc;
               mdro_ce <= '1';
               --! mdro_oe <= '1';
               --
               nxt_state <= df8;
            else
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               mdro_oe <= '1';
               nxt_state <= df7;            
            end if;
--///////////////////////////////////////
         when df8 =>
            SEL_O <= "11"; STB_O <= '1'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
            mdro_oe <= '1';
            nxt_state <= df9;
--///////////////////////////////////////
         when df9 =>
            if ack_sync = '1' then
               intno_mux_sel <= intno_mux_sel_df;
               pcin_mux_sel <= pcin_mux_sel_intno;
               pc_ce <= '1';
               --
               nxt_state <= fetch0;               
            else
               -- writing pc 
               SEL_O <= "11"; STB_O <= '0'; CYC_O <= '1'; WE_O <= '1'; D_CYC_O <= '1';
               --
               mdro_oe <= '1';
               --
               nxt_state <= df9;                
            end if;
--///////////////////////////////////////
         when halted =>
            if int_flag = '1' and intr_sync = '1' then
               -- read vector no.
               SEL_O <= "10"; STB_O <= '1'; CYC_O <= '1'; INTA_CYC_O <= '1';
               -- prepare intr
               intr_ce <= '1';
               --
               nxt_state <= int0; 
            else
               nxt_state <= halted;
            end if;   
--//////////////////////////////////////
      end case;
   end process;
   -- since alu & shifter are not used simultanously...
   aopsel <= asopsel(2 downto 0);
   sopsel <= asopsel(2 downto 0);
   asresult_mux_sel <= asopsel(3);
end rtl;