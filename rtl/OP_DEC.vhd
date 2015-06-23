-- ########################################################
-- #         << ATLAS Project - OpCode Decoder >>         #
-- # **************************************************** #
-- #  OpCode (instruction) decoding unit.                 #
-- # **************************************************** #
-- #  Last modified: 28.11.2014                           #
-- # **************************************************** #
-- #  by Stephan Nolting 4788, Hanover, Germany           #
-- ########################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.atlas_core_package.all;

entity op_dec is
  port	(
-- ###############################################################################################
-- ##           Decoder Interface Input                                                         ##
-- ###############################################################################################

        instr_i         : in  std_ulogic_vector(data_width_c-1 downto 0); -- instruction input
        instr_adr_i     : in  std_ulogic_vector(data_width_c-1 downto 0); -- corresponding address
        t_flag_i        : in  std_ulogic; -- t-flag input
        m_flag_i        : in  std_ulogic; -- mode flag input
        multi_cyc_i     : in  std_ulogic; -- multi-cycle indicator
        cp_ptc_i        : in  std_ulogic; -- user coprocessor protection

-- ###############################################################################################
-- ##           Decoder Interface Output                                                        ##
-- ###############################################################################################

        multi_cyc_req_o : out std_ulogic; -- multi-cycle reqest
        ctrl_o          : out std_ulogic_vector(ctrl_width_c-1 downto 0); -- decoder ctrl lines
        imm_o           : out std_ulogic_vector(data_width_c-1 downto 0)  -- immediate
      );
end op_dec;

architecture op_dec_structure of op_dec is

  -- formated instruction --
  signal instr_int : std_ulogic_vector(15 downto 0);

begin

  -- Data Format Converter -------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    data_conv: process(instr_i, instr_adr_i)
      variable instr_sel_v : std_ulogic_vector(31 downto 0);
      variable instr_tmp_v : std_ulogic_vector(15 downto 0);
    begin
      instr_sel_v := (others => '0');
      for i in 0 to data_width_c-1 loop
        instr_sel_v(i) := instr_i(i);
      end loop;
      if (data_width_c = 16) then -- 16-bit mode
        instr_tmp_v := instr_sel_v(15 downto 0);
      else -- 32-bit mode
        if (instr_adr_i(1) = '0') then
          instr_tmp_v := instr_sel_v(15 downto 0);
        else
          instr_tmp_v := instr_sel_v(31 downto 16);
        end if;
      end if;
      if (big_endian_c = false) then -- endian converter
        instr_int <= instr_tmp_v(7 downto 0) & instr_tmp_v(15 downto 8);
      else
        instr_int <= instr_tmp_v;
      end if;
    end process data_conv;


  -- Opcode Decoder --------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    opcode_decoder: process(instr_int, multi_cyc_i, t_flag_i, m_flag_i, cp_ptc_i)
      variable mem_acc_temp_v  : std_ulogic_vector(3 downto 0);
      variable redundant_reg_v : std_ulogic;
    begin

      -- defaults --
      imm_o                                      <= (others => '0');                  -- zero immediate
      multi_cyc_req_o                            <= '0';                              -- no multi-cycle operation
      ctrl_o                                     <= (others => '0');                  -- all signals disabled
      ctrl_o(ctrl_en_c)                          <= '1';                              -- but we're enabled ^^
      ctrl_o(ctrl_cp_id_c)                       <= instr_int(10);                    -- coprocessor id
      ctrl_o(ctrl_ra_3_c   downto ctrl_ra_0_c)   <= m_flag_i & instr_int(6 downto 4); -- operand a register
      ctrl_o(ctrl_rb_3_c   downto ctrl_rb_0_c)   <= m_flag_i & instr_int(2 downto 0); -- operand b register
      ctrl_o(ctrl_rd_3_c   downto ctrl_rd_0_c)   <= m_flag_i & instr_int(9 downto 7); -- destination register
      ctrl_o(ctrl_cond_3_c downto ctrl_cond_0_c) <= instr_int(13 downto 10);          -- branch condition

      -- both operands have same addresses? --
      redundant_reg_v := '0';
      if (instr_int(6 downto 4) = instr_int(2 downto 0)) then
        redundant_reg_v := '1';
      end if;

      -- decoder --
      case (instr_int(15 downto 14)) is

        when "00" => -- class 0: alu data processing // bank / pc / msr transfer
        -- ==============================================================================
          ctrl_o(ctrl_rd_wb_c)   <= '1'; -- allow write back
          ctrl_o(ctrl_fupdate_c) <= instr_int(3); -- flag update
          imm_o(2 downto 0)      <= instr_int(2 downto 0); -- 3-bit immediate
          if (instr_int(13 downto 10) = fs_inc_c) or (instr_int(13 downto 10) = fs_dec_c) or (instr_int(13 downto 10) = fs_sft_c) then
            ctrl_o(ctrl_rb_is_imm_c) <= '1'; -- yes, this is an immediate
          end if;
          -- mapping to alu elementary operation --
          case (instr_int(13 downto 10)) is

            when fs_orr_c => -- logical or // load from user bank register if redundant
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_orr_c; -- logical or
              if (redundant_reg_v = '1') then -- user bank load
                ctrl_o(ctrl_ra_3_c) <= user_mode_c; -- load from user bank
                ctrl_o(ctrl_rb_3_c) <= user_mode_c; -- load from user bank
                if (m_flag_i = user_mode_c) then -- unauthorized access
                  ctrl_o(ctrl_cmd_err_c) <= '1'; -- access violation - cmd_err trap
                end if;
              end if;

            when fs_and_c => -- logical and // store to user bank register if redundant
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_and_c; -- logical and
              if (redundant_reg_v = '1') then -- user bank store
                ctrl_o(ctrl_rd_3_c) <= user_mode_c; -- store to user bank
                if (m_flag_i = user_mode_c) then -- unauthorized access
                  ctrl_o(ctrl_cmd_err_c) <= '1'; -- access violation - cmd_err trap
                end if;
              end if;

            when fs_cmp_c => -- compare by sbtraction // load from msr if s = 0
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_sbc_c; -- compare by subtraction
              ctrl_o(ctrl_rd_wb_c) <= '0'; -- disable write back
              ctrl_o(ctrl_msr_am_1_c) <= instr_int(6);
              ctrl_o(ctrl_msr_am_0_c) <= instr_int(5);
              if (instr_int(3) = '0') then -- load from msr
                if (instr_int(6 downto 5) /= "11") and (m_flag_i = user_mode_c) then
                  ctrl_o(ctrl_cmd_err_c) <= '1'; -- access violation - cmd_err trap
                end if;
                ctrl_o(ctrl_msr_rd_c) <= '1'; -- read msr
                ctrl_o(ctrl_rd_wb_c)  <= '1'; -- re-enable write back
              end if;

            when fs_cpx_c => -- extended compare with flags // store to msr if s = 0
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_sbc_c; -- compare by subtraction with flags
              ctrl_o(ctrl_alu_usec_c)   <= '1'; -- use carry input
              ctrl_o(ctrl_alu_usez_c)   <= '1'; -- use zero input
              ctrl_o(ctrl_rd_wb_c)      <= '0'; -- disable write back
              ctrl_o(ctrl_msr_am_1_c)   <= instr_int(6); -- only for msr immediate write access
              ctrl_o(ctrl_msr_am_0_c)   <= instr_int(5); -- only for msr immediate write access
              ctrl_o(ctrl_alu_cf_opt_c) <= instr_int(9); -- invert carry flag option?
              ctrl_o(ctrl_alu_zf_opt_c) <= instr_int(8); -- use old zero flag option?
              imm_o(msr_sys_z_flag_c)   <= instr_int(0); -- only for msr immediate write access
              imm_o(msr_usr_z_flag_c)   <= instr_int(0); -- only for msr immediate write access
              imm_o(msr_sys_c_flag_c)   <= instr_int(1); -- only for msr immediate write access
              imm_o(msr_usr_c_flag_c)   <= instr_int(1); -- only for msr immediate write access
              imm_o(msr_sys_o_flag_c)   <= instr_int(2); -- only for msr immediate write access
              imm_o(msr_usr_o_flag_c)   <= instr_int(2); -- only for msr immediate write access
              imm_o(msr_sys_n_flag_c)   <= instr_int(7); -- only for msr immediate write access
              imm_o(msr_usr_n_flag_c)   <= instr_int(7); -- only for msr immediate write access
              imm_o(msr_sys_t_flag_c)   <= instr_int(8); -- only for msr immediate write access
              imm_o(msr_usr_t_flag_c)   <= instr_int(8); -- only for msr immediate write access
              if (instr_int(3) = '0') then -- store to msr
                if ((m_flag_i = user_mode_c) and (instr_int(6 downto 5) /= "11")) then
                  ctrl_o(ctrl_cmd_err_c) <= '1'; -- access violation -> cmd_err trap
                end if;
                if(multi_cyc_i = '0') then
                  ctrl_o(ctrl_msr_wr_c)    <= '1'; -- write msr
                  multi_cyc_req_o          <= '1'; -- we need a dummy cycle afterwards
                  ctrl_o(ctrl_rb_is_imm_c) <= instr_int(4); -- store immediate
                else
                  ctrl_o(ctrl_en_c) <= '0'; -- insert empty cycle
                end if;
              end if;

            when fs_tst_c => -- compare by logical xor // load from pc if s = 0
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_eor_c; -- compare by logical xor
              ctrl_o(ctrl_rd_wb_c) <= '0'; -- disable write back
              if (instr_int(3) = '0') then -- load from pc
                ctrl_o(ctrl_ra_is_pc_c) <= '1'; -- read pc
                ctrl_o(ctrl_rb_is_imm_c) <= instr_int(3); -- this is an immediate
                ctrl_o(ctrl_rd_wb_c)  <= '1'; -- re-enable write back
              end if;

            when fs_teq_c => -- compare by logical and // store to pc if s = 0
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_and_c; -- compare by logical and
              ctrl_o(ctrl_rd_3_c downto ctrl_rd_0_c) <= m_flag_i & link_reg_adr_c; -- link register
              ctrl_o(ctrl_rd_wb_c) <= '0'; -- disable write back
              if (instr_int(3) = '0') then -- store to pc
                if ((m_flag_i = user_mode_c) and ((instr_int(1 downto 0) /= "00") or (instr_int(7) = '1'))) then
                  ctrl_o(ctrl_cmd_err_c) <= '1'; -- access violation - cmd_err trap
                end if;
                ctrl_o(ctrl_pc_wr_c)                           <= '1'; -- write pc
                ctrl_o(ctrl_rb_is_imm_c)                       <= '1'; -- this is an immediate
                imm_o                                          <= (others => '0'); -- zero
                ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_orr_c; -- logical or with 0
                ctrl_o(ctrl_ctx_down_c)                        <= instr_int(0); -- goto user mode when bit 0 = '1'
                ctrl_o(ctrl_re_xint_c)                         <= instr_int(1); -- re-enable global xint flag
                ctrl_o(ctrl_link_c)                            <= instr_int(2); -- link
                ctrl_o(ctrl_rd_wb_c)                           <= instr_int(2); -- allow write back for linking
                ctrl_o(ctrl_restsm_c)                          <= instr_int(7); -- restore saved mode
              end if;

            when fs_inc_c | fs_add_c => -- immediate addition // addition
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_adc_c;

            when fs_dec_c => -- immediate subtraction
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_sbc_c;

            when fs_sub_c => -- subtraction
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_sbc_c;
              if (redundant_reg_v = '1') then -- sub instruction with ra = rb: rd = 0 - ra (neg rd, ra)
                ctrl_o(ctrl_clr_la_c) <= '1'; -- set low byte of a to 0
                ctrl_o(ctrl_clr_ha_c) <= '1'; -- set high byte of a to 0
              end if;

            when fs_adc_c => -- addition with carry
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_adc_c;
              ctrl_o(ctrl_alu_usec_c) <= '1'; -- use carry input

            when fs_sbc_c => -- subtraction with carry
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_sbc_c;
              ctrl_o(ctrl_alu_usec_c) <= '1'; -- use carry input
              if (redundant_reg_v = '1') then -- sbc instruction with ra = rb: rd = 0 - ra - c (nec rd, ra)
                ctrl_o(ctrl_clr_la_c) <= '1'; -- set low byte of a to 0
                ctrl_o(ctrl_clr_ha_c) <= '1'; -- set high byte of a to 0
              end if;

            when fs_eor_c => -- logical xor
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_eor_c;

            when fs_nand_c => -- logical not-and
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_nand_c;

            when fs_bic_c => -- bit clear
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_bic_c;

            when fs_sft_c => -- shift operation
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_sft_c;

            when others => -- undefined
              null; -- use defaults

          end case;


        when "01" => -- class 1: memory access
        -- ==============================================================================
          imm_o(2 downto 0) <= instr_int(2 downto 0); -- immediate offset
          if (instr_int(12) = '1') then
            ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_adc_c; -- add index
          else
            ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_sbc_c; -- sub index
          end if;
          mem_acc_temp_v := instr_int(10) & instr_int(3) & instr_int(13) & instr_int(11); -- l,i,p,w
          case (mem_acc_temp_v) is

            when "0000" | "0100" => -- load, imm/reg offset, pre, no wb
              ctrl_o(ctrl_mem_acc_c)   <= '1'; -- this is a memory access
              ctrl_o(ctrl_rb_is_imm_c) <= instr_int(3); -- this is an immediate
              ctrl_o(ctrl_rd_wb_c)     <= '1'; -- allow data write back

            when "0001" | "0101" => -- load, imm/reg offset, pre, do wb
              ctrl_o(ctrl_rb_is_imm_c) <= instr_int(3); -- this is an immediate
              ctrl_o(ctrl_rd_wb_c)     <= '1'; -- allow data write back
              if (multi_cyc_i = '0') then -- fist cycle: add/sub r_base, r_base, offset
                ctrl_o(ctrl_rd_3_c downto ctrl_rd_0_c) <= m_flag_i & instr_int(6 downto 4); -- base adr
                multi_cyc_req_o      <= '1'; -- prepare second cycle
              else -- second cycle: ld r_data, [r_base]
                ctrl_o(ctrl_mem_acc_c)  <= '1'; -- this is a memory access
                ctrl_o(ctrl_mem_bpba_c) <= '1'; -- use bypassed adr from prev cycle
              end if;

            when "0011" | "0111" => -- load, imm/reg offset, post, do wb
              ctrl_o(ctrl_rb_is_imm_c) <= instr_int(3); -- this is an immediate
              ctrl_o(ctrl_rd_wb_c)     <= '1'; -- allow data write back
              if (multi_cyc_i = '0') then -- fist cycle: ld r_data, [r_base]
                ctrl_o(ctrl_mem_acc_c)  <= '1'; -- this is a memory access
                ctrl_o(ctrl_mem_bpba_c) <= '1'; -- use bypassed adr from prev cycle
                multi_cyc_req_o         <= '1'; -- prepare second cycle
              else -- second cycle: add/sub r_base, r_base, offset
                ctrl_o(ctrl_rd_3_c downto ctrl_rd_0_c) <= m_flag_i & instr_int(6 downto 4); -- base adr
              end if;

            when "1000" | "1001" => -- store, reg offset, pre, (no) wb
              if (multi_cyc_i = '0') then -- fist cycle: add/sub r_base, r_base, r_offset
                ctrl_o(ctrl_rd_3_c downto ctrl_rd_0_c) <= m_flag_i & instr_int(6 downto 4); -- base adr
                ctrl_o(ctrl_rd_wb_c)   <= instr_int(11); -- write back base?
                multi_cyc_req_o        <= '1'; -- prepare second cycle
              else -- second cycle: st r_data, [r_base]
                ctrl_o(ctrl_rb_3_c downto ctrl_rb_0_c) <= m_flag_i & instr_int(9 downto 7); -- store data
                ctrl_o(ctrl_mem_daa_c) <= '1'; -- use delayed adr from prev cycle
                ctrl_o(ctrl_mem_acc_c) <= '1'; -- this is a memory access
                ctrl_o(ctrl_mem_wr_c)  <= '1'; -- write access
              end if;

            when "1011" =>  -- store, reg offset, post, do wb
              if (multi_cyc_i = '0') then -- fist cycle: st r_data, [r_base]
                ctrl_o(ctrl_rb_3_c downto ctrl_rb_0_c) <= m_flag_i & instr_int(9 downto 7); -- store data
                ctrl_o(ctrl_mem_bpba_c) <= '1'; -- use bypassed adr from prev cycle
                ctrl_o(ctrl_mem_acc_c)  <= '1'; -- this is a memory access
                ctrl_o(ctrl_mem_wr_c)   <= '1'; -- write access
                multi_cyc_req_o         <= '1'; -- prepare second cycle
              else -- second cycle: add/sub r_base, r_base, r_offset
                ctrl_o(ctrl_rd_3_c downto ctrl_rd_0_c) <= m_flag_i & instr_int(6 downto 4); -- base adr
                ctrl_o(ctrl_rd_wb_c)    <= '1'; -- write back base
              end if;

            when "1100" | "1101" | "1111" => -- store, imm offset, pre/post, (no) wb
              ctrl_o(ctrl_rd_3_c downto ctrl_rd_0_c) <= m_flag_i & instr_int(6 downto 4); -- base adr
              ctrl_o(ctrl_rb_3_c downto ctrl_rb_0_c) <= m_flag_i & instr_int(9 downto 7); -- store data
              ctrl_o(ctrl_rb_is_imm_c) <= '1'; -- this is an immediate
              ctrl_o(ctrl_mem_acc_c)   <= '1'; -- this is a memory access
              ctrl_o(ctrl_mem_wr_c)    <= '1'; -- write access
              ctrl_o(ctrl_mem_bpba_c)  <= instr_int(13); -- use bypassed adr base
              ctrl_o(ctrl_rd_wb_c)     <= instr_int(11); -- write back base

            -- data swap operations r_b => m[r_a] => r_d --------------------------------
            when "0010" | "0110" | "1010" | "1110" => -- load/store, imm/reg offset, post, no wb [redundant!]
              ctrl_o(ctrl_mem_acc_c)   <= '1'; -- this is a memory access
              ctrl_o(ctrl_mem_bpba_c)  <= '1'; -- use bypassed adr from prev cycle
              ctrl_o(ctrl_rb_is_imm_c) <= '1'; -- this is an immediate (pseudo)
              if (multi_cyc_i = '0') then -- first cycle: ld r_d, [r_a]
                ctrl_o(ctrl_rd_wb_c)  <= '1'; -- write back base
                multi_cyc_req_o       <= '1'; -- prepare second cycle
              else -- second cycle: st r_b, [r_a]
                ctrl_o(ctrl_mem_wr_c) <= '1'; -- write access
              end if;

            when others => -- undefined
              null; -- wayne ^^

          end case;


        when "10" => -- class 2: branch and link
        -- ==============================================================================
          ctrl_o(ctrl_branch_c)    <= '1'; -- this is a branch
          ctrl_o(ctrl_link_c)      <= instr_int(9); -- link?
          ctrl_o(ctrl_ra_is_pc_c)  <= '1'; -- operand a is the pc
          ctrl_o(ctrl_rb_is_imm_c) <= '1'; -- operand b is an immediate
          ctrl_o(ctrl_rd_wb_c)     <= instr_int(9); -- allow write back for linking
          ctrl_o(ctrl_rd_3_c     downto ctrl_rd_0_c)     <= m_flag_i & link_reg_adr_c; -- link register
          ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_adc_c; -- add offset (without carry)
          if (word_mode_en_c = false) then -- byte addressing mode
            imm_o(9 downto 0) <= instr_int(8 downto 0) & '0'; -- offset = offset * 2 (byte offset)
            for i in 10 to data_width_c-1 loop
              imm_o(i) <= instr_int(8); -- sign extension
            end loop;
          else -- word addressing mode
            imm_o(8 downto 0) <= instr_int(8 downto 0); -- offset = offset (word offset)
            for i in 9 to data_width_c-1 loop
              imm_o(i) <= instr_int(8); -- sign extension
            end loop;
          end if;


        when "11" => -- class 3: sub classes
        -- ==============================================================================
          case (instr_int(13 downto 12)) is

            when "00" => -- class 3a: load immediate
            -- --------------------------------------------------------------------------------
              ctrl_o(ctrl_rd_wb_c)                           <= '1'; -- allow write back
              ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_orr_c; -- logical or
              ctrl_o(ctrl_ra_3_c downto ctrl_ra_0_c)         <= m_flag_i & instr_int(9 downto 7); -- op a = source & destination
              ctrl_o(ctrl_rb_is_imm_c)                       <= '1'; -- b is an immediate
              if (instr_int(11) = '0') then -- load and expand low part
                ctrl_o(ctrl_clr_la_c) <= '1'; -- set low byte of a to 0
                imm_o(7 downto 0) <= instr_int(10) & instr_int(6 downto 0);
                if (ldil_sign_ext_c = true) then -- use sign extension
                  for i in 8 to data_width_c-1 loop -- sign extension
                    imm_o(i) <= instr_int(10);
                  end loop;
                  ctrl_o(ctrl_clr_ha_c) <= '1'; -- set high byte of a to 0
                end if;
              else -- load high part
                imm_o(15 downto 8) <= instr_int(10) & instr_int(6 downto 0);
                ctrl_o(ctrl_clr_ha_c) <= '1'; -- set high byte of a to 0
              end if;	
              

            when "01" => -- class 3b: bit transfer
            -- --------------------------------------------------------------------------------
              ctrl_o(ctrl_rb_is_imm_c) <= '1'; -- b is an immediate
              case (instr_int(11 downto 10)) is
                when "00" => -- modifiy bit -> clear bit
                  imm_o(to_integer(unsigned(instr_int(3 downto 0)))) <= '1';
                  ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c)     <= alu_bic_c; -- bit clear
                  ctrl_o(ctrl_rd_wb_c)                               <= '1'; -- allow write back
                when "01" => -- modify bit -> set bit
                  imm_o(to_integer(unsigned(instr_int(3 downto 0)))) <= '1';
                  ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c)     <= alu_orr_c; -- logical or
                  ctrl_o(ctrl_rd_wb_c)                               <= '1'; -- allow write back
                when "10" => -- t-flag transfer, load from t
                  imm_o(to_integer(unsigned(instr_int(3 downto 0)))) <= '1';
                  ctrl_o(ctrl_rd_wb_c)                               <= '1'; -- allow write back
                  if (t_flag_i = '0') then
                    ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_bic_c; -- bit clear
                  else
                    ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_orr_c; -- logical or
                  end if;
                when others => -- "11" -- t-flag transfer, store to t
                  imm_o(3 downto 0)        <= instr_int(3 downto 0);
                  ctrl_o(ctrl_rb_is_imm_c) <= not instr_int(9); -- b is an immediate or reg
                  ctrl_o(ctrl_tf_store_c)  <= '1'; -- store to t-flag
                  ctrl_o(ctrl_tf_inv_c)    <= instr_int(7); -- invert bit to be transfered to t-flag
                  ctrl_o(ctrl_get_par_c)   <= instr_int(8); -- get parity bit of op_a
              end case;


            when "10" => -- class 3c: coprocessor access
            -- --------------------------------------------------------------------------------
              ctrl_o(ctrl_cp_acc_c)   <= '1'; -- this is a cp access
                            ctrl_o(ctrl_cp_trans_c) <= instr_int(11); -- data transfer/access
              if (instr_int(11) = '1') then -- data transfer
                ctrl_o(ctrl_cp_wr_c)    <= instr_int(3); -- read / write
                ctrl_o(ctrl_rd_wb_c)    <= not instr_int(3); -- allow write back
              end if;
              if (m_flag_i = user_mode_c) then -- access violation?
                if ((cp_ptc_i = '1') and (instr_int(10) = '0')) or (instr_int(10) = '1') then -- unauthorized acces?
                  ctrl_o(ctrl_cmd_err_c) <= '1'; -- access violation/undefined instruction - cmd_err trap
                end if;
              end if;


            when others => -- class 3d: sub sub classes
            -- ==============================================================================
              case (instr_int(11 downto 10)) is

                when "00" => -- class 3c0: multiplication
                -- --------------------------------------------------------------------------------
                  if (instr_int(3) = '1') then -- mul32
                    if (build_mul_c = true) and (build_mul32_c = true) then -- unit present?
                      ctrl_o(ctrl_ext_mul_c) <= '1'; -- use high result
                      ctrl_o(ctrl_use_mul_c) <= '1'; -- use mul unit
                                            ctrl_o(ctrl_rd_wb_c)   <= '1'; -- allow write back
                    else -- not present
                      ctrl_o(ctrl_cmd_err_c) <= '1'; -- invalid instruction - cmd_err trap
                    end if;
                  else -- mul16
                    if (build_mul_c = true) then -- unit present?
                      ctrl_o(ctrl_use_mul_c) <= '1'; -- use mul unit
                                            ctrl_o(ctrl_rd_wb_c)   <= '1'; -- allow write back
                    else -- not present
                      ctrl_o(ctrl_cmd_err_c) <= '1'; -- invalid instruction - cmd_err trap
                    end if;
                  end if;
                                    
                  if (instr_int(3) = '1') then -- mul32
                    if (build_mul_c = true) and (build_mul32_c = true) then -- unit present?
                      ctrl_o(ctrl_ext_mul_c) <= '1'; -- use high result
                      ctrl_o(ctrl_use_mul_c) <= '1'; -- use mul unit
                                            ctrl_o(ctrl_rd_wb_c)   <= '1'; -- allow write back
                    else -- not present
                      ctrl_o(ctrl_cmd_err_c) <= '1'; -- invalid instruction - cmd_err trap
                    end if;
                  else -- mul16
                    if (build_mul_c = true) then -- unit present?
                      ctrl_o(ctrl_use_mul_c) <= '1'; -- use mul unit
                                            ctrl_o(ctrl_rd_wb_c)   <= '1'; -- allow write back
                    else -- not present
                      ctrl_o(ctrl_cmd_err_c) <= '1'; -- invalid instruction - cmd_err trap
                    end if;
                  end if;


                when "01" => -- class 3c1: special (sleep, reg-based branch)
                -- --------------------------------------------------------------------------------
                  if (instr_int(9) = '0') then -- sleep mode
                                        if (m_flag_i = user_mode_c) then -- access violation?
                                            ctrl_o(ctrl_cmd_err_c) <= '1'; -- access violation - cmd_err trap
                                        else
                                            ctrl_o(ctrl_sleep_c)   <= '1'; -- go to sleep
                                        end if;
                  elsif (reg_branches_en_c = true) then -- register-based branches enabled
                    ctrl_o(ctrl_cond_3_c   downto ctrl_cond_0_c)   <= instr_int(6 downto 3); -- branch condition
                    ctrl_o(ctrl_rd_3_c     downto ctrl_rd_0_c)     <= m_flag_i & link_reg_adr_c; -- link register
                    ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_adc_c; -- add offset (without carry)
                    ctrl_o(ctrl_branch_c)   <= '1'; -- this is a branch
                    ctrl_o(ctrl_link_c)     <= instr_int(7); -- link?
                    ctrl_o(ctrl_rd_wb_c)    <= instr_int(7); -- allow write back for linking
                    ctrl_o(ctrl_ra_is_pc_c) <= '1'; -- operand a is the pc
                    ctrl_o(ctrl_clr_la_c)   <= instr_int(8); -- set low byte of a to 0
                    ctrl_o(ctrl_clr_ha_c)   <= instr_int(8); -- set high byte of a to 0
                  else
                    ctrl_o(ctrl_cmd_err_c)  <= '1'; -- undefined instruction - cmd_err trap
                  end if;


                when "10" => -- class 3c2: conditional move = if (cond=true) then rd <= rb
                -- --------------------------------------------------------------------------------
                                    if (cond_moves_en_c = true) then -- conditional moves enabled
                                        ctrl_o(ctrl_cond_3_c   downto ctrl_cond_0_c)   <= instr_int(6 downto 3); -- branch condition
                                        ctrl_o(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) <= alu_orr_c; -- logical or
                                        ctrl_o(ctrl_rd_wb_c)   <= '1'; -- allow write back
                                        ctrl_o(ctrl_clr_la_c)  <= '1'; -- set low byte of a to 0
                                        ctrl_o(ctrl_clr_ha_c)  <= '1'; -- set high byte of a to 0
                                        ctrl_o(ctrl_cond_wb_c) <= '1'; -- is conditional write back
                  else
                    ctrl_o(ctrl_cmd_err_c)  <= '1'; -- undefined instruction - cmd_err trap
                  end if;


                when others => -- class 3c3: system call with 10-bit tag
                -- --------------------------------------------------------------------------------
                  ctrl_o(ctrl_syscall_c) <= '1'; -- is system call

              end case;

          end case;


        when others => -- undefined
        -- ==============================================================================
          null; -- wayne...


      end case;
    
    end process opcode_decoder;



end op_dec_structure;
