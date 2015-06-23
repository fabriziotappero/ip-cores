--------------------------------------------------------------
-- dp.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: microprocessor datapath 
--
-- dependency: dp_pkg.vhd 
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
use ieee.std_logic_arith.all;
use work.dp_pkg.all;

entity dp is
   generic
   ( pc_preset_value : std_logic_vector(15 downto 0) := X"0000";  
     sp_preset_value : std_logic_vector(15 downto 0) := X"0000"
   );
   port
   (
   CLK_I : in std_logic;
   --
   DAT_I: in std_logic_vector(15 downto 0);
   DAT_O: out std_logic_vector(15 downto 0);
   --
   ADR_O : out std_logic_vector(15 downto 0);
   --
   jcc_ok : out std_logic;
   int_flag : out std_logic; 
   pc0 : out std_logic;
   sp0 : out std_logic;
   mar0 : out std_logic;
   tr20 : out std_logic;
   ir_high : out std_logic_vector(7 downto 0);
   --
   intr_ce : in std_logic;
   ir_ce : in std_logic;
   mdri_ce : in std_logic;
   mdri_hl_zse_sign : in std_logic;   
   intno_mux_sel : in std_logic_vector(2 downto 0);
   adin_mux_sel : in std_logic_vector(2 downto 0);
   rf_adwe : in std_logic;
   pcin_mux_sel : in std_logic_vector(1 downto 0);
   pc_pre : in std_logic;
   pc_ce : in std_logic;
   spin_mux_sel : in std_logic;
   sp_pre : in std_logic;
   sp_ce : in std_logic;
   dfh_ce : in std_logic;
   alua_mux_sel : in std_logic_vector(1 downto 0);
   alub_mux_sel : in std_logic_vector(2 downto 0);
   aopsel : in std_logic_vector(2 downto 0); 
   sopsel : in std_logic_vector(2 downto 0);
   sbin_mux_sel : in std_logic;
   asresult_mux_sel : std_logic;
   coszin_mux_sel : in std_logic;
   flags_rst : in std_logic;
   flags_ce : in std_logic;
   flags_cfce : in std_logic;
   flags_ifce : in std_logic;
   flags_clc : in std_logic;
   flags_cmc : in std_logic;
   flags_stc : in std_logic;
   flags_cli : in std_logic;
   flags_sti : in std_logic;
   marin_mux_sel : in std_logic_vector(1 downto 0);
   mar_ce : in std_logic;
   mdroin_mux_sel : in std_logic_vector(2 downto 0);
   mdro_ce : in std_logic
   );   
end dp;

architecture rtl of dp is
   signal ir_out : std_logic_vector(15 downto 0);
   signal mdri_out : std_logic_vector(15 downto 0);
   signal rf_aq_out, rf_bq_out : std_logic_vector(15 downto 0);
   signal tr1_out, tr2_out, tr3_out, tr4_out : std_logic_vector(15 downto 0);
   signal pcin_mux_out : std_logic_vector(15 downto 0);
   signal pc_out : std_logic_vector(15 downto 0);
   signal spin_mux_out : std_logic_vector(15 downto 0);
   signal sp_out : std_logic_vector(15 downto 0);
   signal alua_mux_out : std_logic_vector(15 downto 0);
   signal alub_mux_out : std_logic_vector(15 downto 0);
   signal alu_result_out : std_logic_vector(15 downto 0);
   signal alu_c_out, alu_o_out : std_logic;
   signal sbin_mux_out : std_logic_vector(3 downto 0);
   signal shifter_result_out : std_logic_vector(15 downto 0);
   signal shifter_c_out, shifter_o_out : std_logic;
   signal asresult_mux_result_out : std_logic_vector(15 downto 0);
   signal asresult_mux_c_out, asresult_mux_o_out, 
          asresult_mux_s_out, asresult_mux_z_out : std_logic;  
   signal tr5_out : std_logic_vector(15 downto 0); 
   signal mdri_highlow_zse_high_out, mdri_highlow_zse_low_out : std_logic_vector(15 downto 0);    
   signal coszin_mux_out : std_logic_vector(3 downto 0);   
   signal flags_in : std_logic_vector(4 downto 0);
   signal adin_mux_out : std_logic_vector(15 downto 0);   
   signal flags_out : std_logic_vector(4 downto 0);
   signal intr_out : std_logic_vector(3 downto 0);
   signal intno_mux_out : std_logic_vector(15 downto 0); 
   signal marin_mux_out : std_logic_vector(15 downto 0);
   signal mar_out : std_logic_vector(15 downto 0);
   signal dfh_out : std_logic_vector(15 downto 0);
   signal mdroin_mux_out : std_logic_vector(15 downto 0);  
   signal mdro_out : std_logic_vector(15 downto 0);  
begin
   
   ir : process(CLK_I)
   -- ir is 16-bit register, connected to data bus. cpu store the instruction
   -- fetched from memory. The ir's controlled by fsm signal ``ir_ce". 
   begin
      if rising_edge(CLK_I) then
         if ir_ce = '1' then
            ir_out <= DAT_I;
         end if;   
      end if;
   end process;

   -- ir outputs goes to different components...
   -- ir(15..8) goes to fsm for evaluation of current instruction's opcode
   -- and subop 
   ir_high <= ir_out(15 downto 8);

   mdri : process(CLK_I)
   -- mdri is another 16-bit register connected to databus. cpu store data and
   -- immediate const from memory in the this register. it is controlled by 
   -- fsm signal ``mdri_ce"  
   begin
      if rising_edge(CLK_I) then
         if mdri_ce = '1' then
            mdri_out <= DAT_I;
         end if;   
      end if;
   end process;
      
   mdri_highlow_zse : process (mdri_hl_zse_sign, mdri_out)
   -- while execution of lbzx/lbsx instruction cpu needs to load byte.
   -- after loading byte data, data is either zero extended or sign extended.
   -- additionally there is no alignment restriction on byte data, it may either
   -- present on even address or odd address. byte data on even address appear on 
   -- upper 8 lines of databus and loaded into mdri(15..8) while byte data on odd
   -- address appear on lower 8 lines of databus and loaded into mdri(7..0).
   -- so we have to (sign/zero) extend both of them.     
   begin
      case mdri_hl_zse_sign is
         when '0' => 
            mdri_highlow_zse_high_out <= ext(mdri_out(15 downto 8), 16);
            mdri_highlow_zse_low_out <= ext(mdri_out(7 downto 0), 16);
         when '1' => 
            mdri_highlow_zse_high_out <= sxt(mdri_out(15 downto 8), 16);
            mdri_highlow_zse_low_out <= sxt(mdri_out(7 downto 0), 16);
         when others => 
            mdri_highlow_zse_high_out <= (others => '0');
            mdri_highlow_zse_low_out <= (others => '0');
      end case;
   end process;

   u1 : regfile 
   -- register file contain 16-bit, 16 general purpose registers...
   -- register file has two address inputs (4-bit wide), one connected to aadrin_mux_out,
   -- another connected to ir(3..0). it's write control is connected to fsm 
   -- signal `rf_adwe'. its data input port (16-bit wide) is connected to adin_mux's output.
   -- register file has two outputs (16-bit wide): aq, bq
   -- the data (register contents) can be read asynchronously from register file however,
   -- data writing is done synchronously.      
      port map(
         aadr => ir_out(7 downto 4),
         badr => ir_out(3 downto 0),
         ad => adin_mux_out,
         adwe => rf_adwe,
         clk => CLK_I,
         aq => rf_aq_out,
         bq => rf_bq_out
      );

   -- two 16-bit temporary registers tr1 and tr2 are connected to register file's
   -- aq and bq output respectively. 
   -- two 16-bit temporary registers tr3 and tr4 are connected to sign extended fields of ir:
   -- ir(10..0) and (ir(10..8)&ir(3..0)) respectively
   tr1 : process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         tr1_out <= rf_aq_out;
      end if;
   end process;

   tr2 : process(CLK_I)
   begin
      if rising_edge(CLK_I) then
         tr2_out <= rf_bq_out;
      end if;
   end process;

   -- tr2(0) goes out of datapath (to fsm) for evalution
   tr20 <= tr2_out(0);

   tr3 : process(CLK_I)
   begin
      if rising_edge(CLK_I) then      
         tr3_out <= sxt(ir_out(10 downto 0), 16);
      end if;
   end process;

   tr4 : process(CLK_I) 
   begin
      if rising_edge(CLK_I) then
         tr4_out <= sxt(ir_out(10 downto 8) & ir_out(3 downto 0), 16);
      end if;
   end process;


   alua_mux : process(alua_mux_sel, pc_out, sp_out, tr1_out, tr2_out)
   -- alua_mux is connected to alu's input port `A' and used to select
   -- operand `A'. it is controlled by fsm signal alua_mux_sel. it has four 
   -- inputs which are connected to: pc output, sp output, tr1 output and 
   -- tr2 output. all the inputs and output are 16-bit wide.   
   begin
      case alua_mux_sel is
         when "00" =>
            alua_mux_out <= pc_out;
         when "01" =>
            alua_mux_out <= sp_out;
         when "10" =>
            alua_mux_out <= tr1_out;
         when "11" =>
            alua_mux_out <= tr2_out;
         when others => 
            alua_mux_out <= (others => '-');         
      end case;   
   end process;

   alub_mux : process(alub_mux_sel, tr2_out, tr3_out, tr4_out, mdri_out)
   -- alub_mux is connected to alu's input port `B' and used to select
   -- operand `B'. it is controlled by fsm signal alua_mux_sel. it has 8 inputs,
   -- which are connected to: tr2 output, constant `2', constant `1', constant `0'
   -- tr3, tr4, mdri's ouput and rest don't care.
   -- all the inputs and output are 16-bit wide.
   begin
      case alub_mux_sel is
         when "000" =>
            alub_mux_out <= tr2_out;
         when "001" =>
            alub_mux_out <= X"0002";
         when "010" =>
            alub_mux_out <= X"0001";
         when "011" =>
            alub_mux_out <= X"0000";
         when "100" =>
            alub_mux_out <= tr3_out;
         when "101" =>
            alub_mux_out <= tr4_out;
         when "110" =>
            alub_mux_out <= mdri_out;
         when others => 
            alub_mux_out <= (others => '-');    
      end case;
   end process;
   
   u2 : alu 
   -- Alu perform all the arithmetic and logic operations. it has two 16-bit wide data inputs
   -- `A' and `B', and 1-bit carry input. the alu is controled by fsm signal aopsel(2..0).
   -- the alu has a 16-bit wide output: result, as well as carry out and overflow out 
   -- signals (1-bit each). the carry out and overflow out signals are used 
   -- to update corresponding status flags in ``flags" register. 
   port map(   
      a => alua_mux_out, 
      b => alub_mux_out,
      opsel => aopsel(2 downto 0),
      c_in => flags_out(4), 
      result => alu_result_out,
      c_out => alu_c_out,
      ofl_out => alu_o_out
   );   

   sbin_mux : process(sbin_mux_sel, ir_out(3 downto 0), tr2_out(3 downto 0))
   -- sbin_mux is 4-bit wide 2-1 mux, its output connected to `B' input of 
   -- shifter. one of its input connected to tr2(3..0) while other is connected   
   -- to ir(3..0). this allow us to implement const as well as variable shift operations
   begin
      case sbin_mux_sel is
         when '0' =>
            sbin_mux_out <= tr2_out(3 downto 0);
         when '1' =>
            sbin_mux_out <= ir_out(3 downto 0);
         when others => 
            sbin_mux_out <= (others => '-');
      end case;
   end process;
   
   u3 : shifter
   -- Shifter perform 16-bit data shift and rotate operations. it has a 16-bit data input `A',
   -- the no. of time shift operation is performed, is determined by 4-bit `B' input. To support
   -- operations: ``rotate carry left" and ``rotate carry right", there is 1-bit carry input signal.
   -- like alu, shifter also has a 16-bit wide output: result, as well as carry out and overflow out 
   -- signals (1-bit each). the carry out and overflow out signals are used 
   -- to update corresponding status flags in ``flags" register.      
   port map
   (
      a => tr1_out,
      b => sbin_mux_out,
      c_in => flags_out(4),
      opsel => sopsel(2 downto 0),
      result => shifter_result_out,
      c_out => shifter_c_out,
      ofl_out => shifter_o_out
   );    
   
   asresult_mux : process(asresult_mux_sel, alu_result_out, alu_c_out,
                          alu_o_out, shifter_result_out, shifter_c_out,
                          shifter_o_out)
   -- The result, carry out, and overflow out signals, are comming out from both shifter
   -- and alu. The asresult mux, multiplexed these signals 
   begin
      case asresult_mux_sel is
         when '0' =>
            asresult_mux_result_out <= alu_result_out;
            asresult_mux_c_out <= alu_c_out;
            asresult_mux_o_out <= alu_o_out;
         when '1' =>
            asresult_mux_result_out <= shifter_result_out;
            asresult_mux_c_out <= shifter_c_out;
            asresult_mux_o_out <= shifter_o_out;
         when others =>
            asresult_mux_result_out <= (others => '-');
            asresult_mux_c_out <= '-';
            asresult_mux_o_out <= '-';                         
      end case;
   end process;
   
   -- from ``asresult_mux_result_out" signal, two more signals are generated:
   -- ``asresult_mux_s_out" and ``asresult_mux_z_out". these two signal update
   -- two status flags: sign and zero flags inside flags register, respactively.
   
   asresult_mux_s_out <= asresult_mux_result_out(15);

   asresult_mux_z_out <= '1' when asresult_mux_result_out = X"0000" else
                         '0';

   tr5: process(CLK_I)
   -- the multiplexed result, ``asresult_mux_result_out" goes to 16-bit temporary
   -- register.
   begin
      if rising_edge(CLK_I) then
         tr5_out <= asresult_mux_result_out;   
      end if;
   end process;

   coszin_mux : process(coszin_mux_sel, mdri_out(4 downto 1), asresult_mux_c_out,
                        asresult_mux_o_out, asresult_mux_s_out, asresult_mux_z_out)
   -- The PUSHF instruction, push the content of flags register into memory.
   -- corresponding POPF instruction, pop the content of memory word into flags register.
   -- therefore a 4-bit wide 2-1 mux is required for four status flags (C, O, S, Z) in 
   -- flags register, to either select mdri(4 downto 1) or flag outputs of asresult mux.   
   begin
      case coszin_mux_sel is
         when '0' =>
            coszin_mux_out <= asresult_mux_c_out & asresult_mux_o_out 
                              & asresult_mux_s_out & asresult_mux_z_out;
         when '1' =>
            coszin_mux_out <= mdri_out(4 downto 1);
         when others => 
            coszin_mux_out <= (others => '-');
      end case;   
   end process;
   
   -- flags register contain four status flags: carry, overflow, sign and zero. 
   -- there is also a system flag: int. flags register input consists of 
   -- coszin_mux_out & mdri(0).

   flags_in <= coszin_mux_out & mdri_out(0);
   
   u4 : flags 
   -- flags register has several control signals: async reset which is control by fsm 
   -- signal ``flags_rst" asserted on cpu reset, load control by fsm's ``flags_ce"
   -- signal, separate load controls for carry and interrupt flags which are controlled
   -- by ``flags_cfce" and ``flags_ifce" respectively. 
   -- three control signals ``flags_clc", ``flags_cmc" and ``flags_stc" are provided 
   -- for clearing/complementing/setting carry flag.
   -- two control signals ``flags_cli" and ``flags_sti" are provided 
   -- for clearing/setting int flag.               
   port map(
      Flags_in => flags_in,  
      CLK_in => CLK_I,     
      ResetAll_in => flags_rst,
      CE_in => flags_ce,
      CFCE_in => flags_cfce,
      IFCE_in => flags_ifce, 
      CLC_in => flags_clc,
      CMC_in => flags_cmc,
      STC_in => flags_stc,
      STI_in => flags_sti,
      CLI_in => flags_cli,
      Flags_out => flags_out
   );  
   
   -- when hardware interrupt occurs, cpu need to check the status of interrupt flag.
   -- so this signal goes to fsm  
   int_flag <= flags_out(0);

   adin_mux : process(adin_mux_sel, tr2_out, tr5_out, sp_out, mdri_out,
                      mdri_highlow_zse_high_out, mdri_highlow_zse_low_out)
   -- the adin_mux is 16-bit wide 8-1 mux connected to regfile ad input. it is 
   -- controlled by fsm's signal ``adin_mux_sel". its input are connected to outputs of
   -- tr2, tr5, sp, mdri and mdri_highlow_zse. the rest of inputs are donot care.  
   begin
      case adin_mux_sel is
         when "000" =>
            adin_mux_out <= tr2_out;
         when "001" =>
            adin_mux_out <= tr5_out;
         when "010" =>
            adin_mux_out <= sp_out;
         when "011" =>
            adin_mux_out <= mdri_out;
         when "100" => 
            adin_mux_out <= mdri_highlow_zse_high_out;
         when "101" =>
            adin_mux_out <= mdri_highlow_zse_low_out;
         when others =>
            adin_mux_out <= (others => '-');
      end case;
   end process;
   
   u5: fcmp 
   -- A flag comparator (fcmp) is used during execution of jcc and into instruction.
   -- it has two 4-bit inputs connected to status flags of flags register and 
   -- ir(7..4). it has 1-bit output. It check the status flags according condition 
   -- specified in ir(7..4), if condition holds, the output is asserted.
   -- this output goes to fsm for evaluation.    
   port map( 
      tttnField_in => ir_out(7 downto 4),       
      flags_in => flags_out(4 downto 1),
      result_out => jcc_ok
   );  
   
   intr: process(CLK_I)
   -- the intr is 4-bit register, connected to data bus(11..8) lines of databus.
   -- it is controled by fsm's signal ``intr_ce". it is used to store
   -- interrupt vector no. provided by the interrupting hardware. 
   begin
      if rising_edge(CLK_I) then
         if intr_ce = '1' then
            intr_out <= DAT_I(11 downto 8);
         end if;
      end if;
   end process;

   intno_mux : process(intno_mux_sel, ir_out(3 downto 0), intr_out)
   -- the intno_mux select the vector no. it is controlled by fsm's intno_mux_sel
   -- signal. first four inputs are tied to consts declared in ``dp_pkg", which are
   -- vector numbers of invaild opcode exception, alignment exception, 
   -- stack error exception and double fault respectively. 
   -- the other two are tied to outputs of ir(3..0)and intr. 
   -- the selected vector number is further zero extended and multiplied by 8. 
      variable t1 : std_logic_vector(3 downto 0);
      variable t2 : std_logic_vector(15 downto 0);
   begin
      case intno_mux_sel is
         when "000" =>
            t1 := invaild_inst_vec;
         when "001" =>
            t1 := align_err_vec;
         when "010" =>
            t1 := stack_err_vec;
         when "011" =>
            t1 := df_err_vec;
         when "100" =>
            t1 := ir_out(3 downto 0);
         when "101" =>
            t1 := intr_out;
         when others =>
            t1 := (others => '-');       
      end case;
      t2 := "000000000000" & t1;
      intno_mux_out <= t2(12 downto 0) & "000"; 
   end process;

   pcin_mux : process(pcin_mux_sel, alu_result_out, intno_mux_out, mdri_out)
   -- the pcin_mux is 16-bit wide mux, connected to pc input.
   -- it is controlled by fsm's signal ``pcin_mux_sel". one of its input is connected
   -- alu result output (this allows increament in pc after fetching instruction, place 
   -- effective address calculated during jmp and call), second to intno_mux output
   -- (for int, into and hardware interrupt) and third to mdri output (for ret and iret
   -- instructions)   
   begin
      case pcin_mux_sel is
         when "00" =>
            pcin_mux_out <= alu_result_out;
         when "01" =>
            pcin_mux_out <= intno_mux_out;
         when "10" =>
            pcin_mux_out <= mdri_out;
         when others =>
            pcin_mux_out <= (others => '-');
      end case;
   end process;
  
   pc : process(CLK_I, pc_pre) 
   -- the 16-bit pc register contain the address of for the next instruction 
   -- to be executed. it is advanced from one instruction boundry to the next
   -- in straight line code or it is moved ahead or backwards by a number of instructions
   -- when executing jmp, jcc, call, ret and iret instructions.
   -- on cpu reset, the pc preset to ``pc_preset_value".   
   begin
      if pc_pre = '1' then 
         pc_out <= pc_preset_value;
      elsif rising_edge(CLK_I) then
         if pc_ce = '1' then
            pc_out <= pcin_mux_out;
         end if; 
      end if;    
   end process;

   -- the pc may contain odd address, specially after ret or iret instruction.
   -- therefore lsb of pc output goes to fsm input.
   pc0 <= pc_out(0);

   spin_mux : process(spin_mux_sel, alu_result_out, mdri_out)
   -- the spin_mux is 16-bit wide 2-1 mux, connected to sp input.
   -- it is controlled by fsm's signal ``spin_mux_sel". one of its input is connected
   -- alu result output and other to mdri output.    
   begin
      case spin_mux_sel is
         when '0' =>
            spin_mux_out <= alu_result_out;
         when '1' =>
            spin_mux_out <= mdri_out;
         when others =>
            spin_mux_out <= (others => '-');
      end case;
   end process;

   sp : process(CLK_I, sp_pre) 
   -- sp is 16-bit register, it contain the address of ``top of stack"(TOS).
   -- when items (only 16-bit) are pushed on stack, cpu decreament the sp,
   -- and push the item of TOS. when an item is popped off the stack, the
   -- processor read the items from TOS, then increament the sp register.
   -- on procedure call, cpu automatically push pc and on return pops the TOS
   -- into pc. on interrupt/exception cpu automattically push flags and pc while
   -- on iret, cpu restore pc and flags 
   -- on stack error and double fault, sp preset to ``sp_preset_value"
   begin
      if sp_pre = '1' then
         sp_out <= sp_preset_value;
      elsif rising_edge(CLK_I) then
         if sp_ce = '1' then 
            sp_out <= spin_mux_out;
         end if;
      end if;
   end process;

   -- lsb of sp goes to fsm's input, for alignment checking.
   sp0 <= sp_out(0);

   dfh : process(CLK_I) 
   -- dfh is 16-bit register which used to temporary store the offending sp value,
   -- during stk err and df. it is controlled by fsm's signal: dfh_ce. 
   begin
      if rising_edge(CLK_I) then
         if dfh_ce = '1' then
            dfh_out <= sp_out;
         end if;
      end if;
   end process;
   
   marin_mux : process(marin_mux_sel, pc_out, sp_out, alu_result_out)
   -- marin_mux is 16-bit wide mux. it is controlled by fsm's signal marin_mux_sel.
   -- its inputs are connected to: pc, sp and alu reseult output 
   begin
      case marin_mux_sel is
         when "00" =>
            marin_mux_out <= pc_out;
         when "01" =>
            marin_mux_out <= alu_result_out;
         when "10" => 
            marin_mux_out <= sp_out;   
         when others =>
            marin_mux_out <= (others => '-');
      end case;   
   end process;

   mar : process(CLK_I)
   -- mar is 16-bit regiser, conected to address bus. it is controlled by fsm's signal
   -- ``mar_ce". any address is first loaded into mar and then goes to address bus.    
   begin       
      if rising_edge(CLK_I) then
         if mar_ce = '1' then
            mar_out <= marin_mux_out;
         end if;
      end if;   
   end process;

   mar0 <= mar_out(0);
   
   ADR_O <= mar_out;     
   
   mdroin_mux : process(mdroin_mux_sel, pc_out, tr1_out, flags_out, dfh_out, intno_mux_out)
   -- mdroin_mux is 16-bit wide mux. it is controlled by fsm's signal mdroin_mux_sel.
   -- its inputs are connected to: pc, tr1, zero extended flags output, (tr1(7..0)& X"00")  
   -- zero extended tr1(7..0), dfh output, intno_mux outputs are used in stk and df exception
   begin
      case mdroin_mux_sel is
         when "000" =>
            mdroin_mux_out <= pc_out;
         when "001" =>
            mdroin_mux_out <= tr1_out;
         when "010" =>
            mdroin_mux_out <= "00000000000" & flags_out;
         when "011" =>
            mdroin_mux_out <= dfh_out;
         when "100" =>
            mdroin_mux_out <= intno_mux_out;
         when "101" => 
            mdroin_mux_out <= tr1_out(7 downto 0) & X"00";
         when "110" =>
            mdroin_mux_out <= X"00" & tr1_out(7 downto 0);
         when others =>
            mdroin_mux_out <= (others => '-');
      end case;   
   end process;

   -- mdro is 16-bit register connected to databus, through tri-state buffer. it has for control 
   -- signals: mdro_ce for load control.
   mdro : process(CLK_I)
   begin       
      if rising_edge(CLK_I) then
         if mdro_ce = '1' then 
            mdro_out <= mdroin_mux_out;
         end if;            
      end if;   
   end process;

   DAT_O <= mdro_out;
        
end rtl;
