--  This file is part of the marca processor.
--  Copyright (C) 2007 Wolfgang Puffitsch

--  This program is free software; you can redistribute it and/or modify it
--  under the terms of the GNU Library General Public License as published
--  by the Free Software Foundation; either version 2, or (at your option)
--  any later version.

--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Library General Public License for more details.

--  You should have received a copy of the GNU Library General Public
--  License along with this program; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

-------------------------------------------------------------------------------
-- MARCA decode stage
-------------------------------------------------------------------------------
-- architecture for the instruction-decode pipeline stage
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.marca_pkg.all;

architecture behaviour of decode is

signal pc_reg    : std_logic_vector(REG_WIDTH-1 downto 0);
signal dest_reg  : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal instr_reg : std_logic_vector(PDATA_WIDTH-1 downto 0);

signal src1_reg  : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal src2_reg  : std_logic_vector(REG_COUNT_LOG-1 downto 0);

component regfile is
  port (
    clock    : in  std_logic;
    reset    : in  std_logic;
    hold     : in  std_logic;
    rd1_addr : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    rd2_addr : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    rd1_val  : out std_logic_vector(REG_WIDTH-1 downto 0);
    rd2_val  : out std_logic_vector(REG_WIDTH-1 downto 0);
    wr_ena   : in  std_logic;
    wr_addr  : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    wr_val   : in  std_logic_vector(REG_WIDTH-1 downto 0));
end component;

begin  -- behaviour

  regfile_unit : regfile
    port map (
      clock    => clock,
      reset    => reset,
      hold     => hold,
      rd1_addr => src1_reg,
      rd2_addr => src2_reg,
      rd1_val  => op1,
      rd2_val  => op2,
      wr_ena   => wr_ena,
      wr_addr  => wr_dest,
      wr_val   => wr_val);
  
  syn_proc: process (clock, reset)
  begin  -- process syn_proc
    if reset = RESET_ACTIVE then                 -- asynchronous reset (active low)
      pc_reg <= (others => '0');
      dest_reg <= (others => '0');
      instr_reg <= OPC_PFX_C & OPC_PFX_C2 & OPC_PFX_C2a & OPC_NOP;
      src1_reg <= (others => '0');
      src2_reg <= (others => '0');
    elsif clock'event and clock = '1' then  -- rising clock edge
      if hold = '0' then
        if stall = '1' then
          pc_reg <= (others => '0');
          dest_reg <= (others => '0');
          instr_reg <= OPC_PFX_C & OPC_PFX_C2 & OPC_PFX_C2a & OPC_NOP;
          src1_reg <= (others => '0');
          src2_reg <= (others => '0');
        else
          pc_reg <= pc_in;
          dest_reg <= dest_in;
          instr_reg <= instr;
          src1_reg <= src1_in;
          src2_reg <= src2_in;
        end if;
      end if;
    end if;
  end process syn_proc;

  feedthrough: process (pc_reg, src1_reg, src2_reg)
  begin  -- process feedthrough
    pc_out <= pc_reg;
    src1_out <= src1_reg;
    src2_out <= src2_reg;
  end process feedthrough;

  do_decode: process (instr_reg, src1_reg, src2_reg, dest_reg)
  begin  -- process

    -- all unknown opcodes trigger interrupt EXC_ERR
    imm <= std_logic_vector(to_unsigned(EXC_ERR, REG_WIDTH));
    dest_out <= dest_reg;
    aop <= ALU_INTR;
    mop <= MEM_NOP;
    iop <= INTR_INTR;
    unit <= UNIT_INTR;
    target <= TARGET_PC;
    
    case instr_reg(PDATA_WIDTH-1 downto PDATA_WIDTH-4) is
      when
        OPC_ADD => aop <= ALU_ADD;
                   mop <= MEM_NOP;
                   iop <= INTR_NOP;
                   unit <= UNIT_ALU;
                   target <= TARGET_REGISTER;
                   dest_out <= dest_reg;
      when
        OPC_SUB => aop <= ALU_SUB;
                   mop <= MEM_NOP;
                   iop <= INTR_NOP;
                   unit <= UNIT_ALU;
                   target <= TARGET_REGISTER;
                   dest_out <= dest_reg;
      when
        OPC_ADDC => aop <= ALU_ADDC;
                    mop <= MEM_NOP;
                    iop <= INTR_NOP;
                    unit <= UNIT_ALU;
                    target <= TARGET_REGISTER;
                    dest_out <= dest_reg;
      when
        OPC_SUBC => aop <= ALU_SUBC;
                    mop <= MEM_NOP;
                    iop <= INTR_NOP;
                    unit <= UNIT_ALU;
                    target <= TARGET_REGISTER;
                    dest_out <= dest_reg;
      when
        OPC_AND => aop <= ALU_AND;
                   mop <= MEM_NOP;
                   iop <= INTR_NOP;
                   unit <= UNIT_ALU;
                   target <= TARGET_REGISTER;
                   dest_out <= dest_reg;
      when
        OPC_OR  => aop <= ALU_OR;
                   mop <= MEM_NOP;
                   iop <= INTR_NOP;
                   unit <= UNIT_ALU;
                   target <= TARGET_REGISTER;
                   dest_out <= dest_reg;
      when
        OPC_XOR => aop <= ALU_XOR;
                   mop <= MEM_NOP;
                   iop <= INTR_NOP;
                   unit <= UNIT_ALU;
                   target <= TARGET_REGISTER;
                   dest_out <= dest_reg;
      when
        OPC_MUL => aop <= ALU_MUL;
                   mop <= MEM_NOP;
                   iop <= INTR_NOP;
                   unit <= UNIT_ALU;
                   target <= TARGET_REGISTER;
                   dest_out <= dest_reg;
      when
        OPC_DIV => aop <= ALU_DIV;
                   mop <= MEM_NOP;
                   iop <= INTR_NOP;
                   unit <= UNIT_ALU;
                   target <= TARGET_REGISTER;
                   dest_out <= dest_reg;
      when
        OPC_UDIV => aop <= ALU_UDIV;
                    mop <= MEM_NOP;
                    iop <= INTR_NOP;
                    unit <= UNIT_ALU;
                    target <= TARGET_REGISTER;
                    dest_out <= dest_reg;
      when
        OPC_LDIL => imm <= std_logic_vector(resize(signed(dest_reg & src2_reg), REG_WIDTH));
                    aop <= ALU_LDIL;
                    mop <= MEM_NOP;
                    iop <= INTR_NOP;
                    unit <= UNIT_ALU;
                    target <= TARGET_REGISTER;
                    dest_out <= src1_reg;
      when
        OPC_LDIH => imm <= std_logic_vector(resize(signed(dest_reg & src2_reg), REG_WIDTH));
                    aop <= ALU_LDIH;
                    mop <= MEM_NOP;
                    iop <= INTR_NOP;
                    unit <= UNIT_ALU;
                    target <= TARGET_REGISTER;
                    dest_out <= src1_reg;
      when
        OPC_LDIB => imm <= std_logic_vector(resize(signed(dest_reg & src2_reg), REG_WIDTH));
                    aop <= ALU_LDIB;
                    mop <= MEM_NOP;
                    iop <= INTR_NOP;
                    unit <= UNIT_ALU;
                    target <= TARGET_REGISTER;
                    dest_out <= src1_reg;

      when
        OPC_PFX_A =>
        case instr_reg(PDATA_WIDTH-5 downto PDATA_WIDTH-8) is
          when
            OPC_MOV => aop <= ALU_MOV;
                       mop <= MEM_NOP;
                       iop <= INTR_NOP;
                       unit <= UNIT_ALU;
                       target <= TARGET_REGISTER;
                       dest_out <= src1_reg;
          when
            OPC_MOD => aop <= ALU_MOD;
                       mop <= MEM_NOP;
                       iop <= INTR_NOP;
                       unit <= UNIT_ALU;
                       target <= TARGET_REGISTER;
                       dest_out <= src1_reg;
          when
            OPC_UMOD => aop <= ALU_UMOD;
                        mop <= MEM_NOP;
                        iop <= INTR_NOP;
                        unit <= UNIT_ALU;
                        target <= TARGET_REGISTER;
                        dest_out <= src1_reg;
          when
            OPC_NOT => aop <= ALU_NOT;
                       mop <= MEM_NOP;
                       iop <= INTR_NOP;
                       unit <= UNIT_ALU;
                       target <= TARGET_REGISTER;
                       dest_out <= src1_reg;
          when                   
            OPC_NEG => aop <= ALU_NEG;
                       mop <= MEM_NOP;
                       iop <= INTR_NOP;
                       unit <= UNIT_ALU;
                       target <= TARGET_REGISTER;
                       dest_out <= src1_reg;
          when
            OPC_CMP => aop <= ALU_SUB;      -- it's the same
                       mop <= MEM_NOP;
                       iop <= INTR_NOP;
                       unit <= UNIT_ALU;
                       target <= TARGET_NONE;
                       dest_out <= src1_reg;
          when
            OPC_ADDI => imm <= std_logic_vector(resize(signed(src2_reg), REG_WIDTH));
                        aop <= ALU_ADDI;
                        mop <= MEM_NOP;
                        iop <= INTR_NOP;
                        unit <= UNIT_ALU;
                        target <= TARGET_REGISTER;
                        dest_out <= src1_reg;
          when                    
            OPC_CMPI => imm <= std_logic_vector(resize(signed(src2_reg), REG_WIDTH));
                        aop <= ALU_CMPI;
                        mop <= MEM_NOP;
                        iop <= INTR_NOP;
                        unit <= UNIT_ALU;
                        target <= TARGET_NONE;
                        dest_out <= src1_reg;
          when
            OPC_SHL => aop <= ALU_SHL;
                       mop <= MEM_NOP;
                       iop <= INTR_NOP;
                       unit <= UNIT_ALU;
                       target <= TARGET_REGISTER;
                       dest_out <= src1_reg;
          when                   
            OPC_SHR => aop <= ALU_SHR;
                       mop <= MEM_NOP;
                       iop <= INTR_NOP;
                       unit <= UNIT_ALU;
                       target <= TARGET_REGISTER;
                       dest_out <= src1_reg;
          when                   
            OPC_SAR => aop <= ALU_SAR;
                       mop <= MEM_NOP;
                       iop <= INTR_NOP;
                       unit <= UNIT_ALU;
                       target <= TARGET_REGISTER;
                       dest_out <= src1_reg;
          when
            OPC_ROLC => aop <= ALU_ROLC;
                        mop <= MEM_NOP;
                        iop <= INTR_NOP;
                        unit <= UNIT_ALU;
                        target <= TARGET_REGISTER;
                        dest_out <= src1_reg;
          when
            OPC_RORC => aop <= ALU_RORC;
                        mop <= MEM_NOP;
                        iop <= INTR_NOP;
                        unit <= UNIT_ALU;
                        target <= TARGET_REGISTER;
                        dest_out <= src1_reg;
          when
            OPC_BSET => imm <= std_logic_vector(resize(unsigned(src2_reg), REG_WIDTH));
                        aop <= ALU_BSET;
                        mop <= MEM_NOP;
                        iop <= INTR_NOP;
                        unit <= UNIT_ALU;
                        target <= TARGET_REGISTER;
                        dest_out <= src1_reg;
          when                    
            OPC_BCLR => imm <= std_logic_vector(resize(unsigned(src2_reg), REG_WIDTH));
                        aop <= ALU_BCLR;
                        mop <= MEM_NOP;
                        iop <= INTR_NOP;
                        unit <= UNIT_ALU;
                        target <= TARGET_REGISTER;
                        dest_out <= src1_reg;
          when
            OPC_BTEST => imm <= std_logic_vector(resize(unsigned(src2_reg), REG_WIDTH));
                         aop <= ALU_BTEST;
                         mop <= MEM_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_ALU;
                         target <= TARGET_NONE;
                         dest_out <= src1_reg;
          when others => null;
        end case;

      when OPC_PFX_B =>
        case instr_reg(PDATA_WIDTH-5 downto PDATA_WIDTH-8) is        
          when
            OPC_LOAD => mop <= MEM_LOAD;
                        aop <= ALU_NOP;
                        iop <= INTR_NOP;
                        unit <= UNIT_MEM;
                        target <= TARGET_REGISTER;
                        dest_out <= src1_reg;
          when
            OPC_LOADL => mop <= MEM_LOADL;
                         aop <= ALU_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_MEM;
                         target <= TARGET_REGISTER;
                         dest_out <= src1_reg;
          when
            OPC_LOADH => mop <= MEM_LOADH;
                         aop <= ALU_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_MEM;
                         target <= TARGET_REGISTER;
                         dest_out <= src1_reg;
          when
            OPC_LOADB => mop <= MEM_LOADB;
                         aop <= ALU_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_MEM;
                         target <= TARGET_REGISTER;
                         dest_out <= src1_reg;
          when
            OPC_STORE => mop <= MEM_STORE;
                         aop <= ALU_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_MEM;
                         target <= TARGET_NONE;
                         dest_out <= src1_reg;
          when
            OPC_STOREL => mop <= MEM_STOREL;
                          aop <= ALU_NOP;
                          iop <= INTR_NOP;
                          unit <= UNIT_MEM;
                          target <= TARGET_NONE;
                          dest_out <= src1_reg;
          when
            OPC_STOREH => mop <= MEM_STOREH;
                          aop <= ALU_NOP;
                          iop <= INTR_NOP;
                          unit <= UNIT_MEM;
                          target <= TARGET_NONE;
                          dest_out <= src1_reg;
          when
            OPC_CALL => aop <= ALU_JMP;     -- force alu_pcchg
                        mop <= MEM_NOP;
                        iop <= INTR_NOP;
                        unit <= UNIT_CALL;
                        target <= TARGET_BOTH;
                        dest_out <= src1_reg;
          when others => null;
        end case;

      when OPC_PFX_C =>
        case instr_reg(PDATA_WIDTH-5 downto PDATA_WIDTH-8) is
          when
            OPC_BR => aop <= ALU_NOP;
                      mop <= MEM_NOP;
                      iop <= INTR_NOP;
                      unit <= UNIT_ALU;
                      target <= TARGET_NONE;
                      dest_out <= src1_reg;
          when
            OPC_BRZ  => imm <= std_logic_vector(resize(signed(src2_reg & src1_reg), REG_WIDTH));
                        aop <= ALU_BRZ;
                        mop <= MEM_NOP;
                        iop <= INTR_NOP;
                        unit <= UNIT_ALU;
                        target <= TARGET_PC;
                        dest_out <= src1_reg;
          when
            OPC_BRNZ  => imm <= std_logic_vector(resize(signed(src2_reg & src1_reg), REG_WIDTH));
                         aop <= ALU_BRNZ;
                         mop <= MEM_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_ALU;
                         target <= TARGET_PC;
                         dest_out <= src1_reg;
          when
            OPC_BRLE  => imm <= std_logic_vector(resize(signed(src2_reg & src1_reg), REG_WIDTH));
                         aop <= ALU_BRLE;
                         mop <= MEM_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_ALU;
                         target <= TARGET_PC;
                         dest_out <= src1_reg;
          when
            OPC_BRLT  => imm <= std_logic_vector(resize(signed(src2_reg & src1_reg), REG_WIDTH));
                         aop <= ALU_BRLT;
                         mop <= MEM_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_ALU;
                         target <= TARGET_PC;
                         dest_out <= src1_reg;
          when                     
            OPC_BRGE  => imm <= std_logic_vector(resize(signed(src2_reg & src1_reg), REG_WIDTH));
                         aop <= ALU_BRGE;
                         mop <= MEM_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_ALU;
                         target <= TARGET_PC;
                         dest_out <= src1_reg;
          when                     
            OPC_BRGT  => imm <= std_logic_vector(resize(signed(src2_reg & src1_reg), REG_WIDTH));
                         aop <= ALU_BRGT;
                         mop <= MEM_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_ALU;
                         target <= TARGET_PC;
                         dest_out <= src1_reg;
          when                     
            OPC_BRULE  => imm <= std_logic_vector(resize(signed(src2_reg & src1_reg), REG_WIDTH));
                          aop <= ALU_BRULE;
                          mop <= MEM_NOP;
                          iop <= INTR_NOP;
                          unit <= UNIT_ALU;
                          target <= TARGET_PC;
                          dest_out <= src1_reg;
          when
            OPC_BRULT  => imm <= std_logic_vector(resize(signed(src2_reg & src1_reg), REG_WIDTH));
                          aop <= ALU_BRULT;
                          mop <= MEM_NOP;
                          iop <= INTR_NOP;
                          unit <= UNIT_ALU;
                          target <= TARGET_PC;
                          dest_out <= src1_reg;
          when
            OPC_BRUGE  => imm <= std_logic_vector(resize(signed(src2_reg & src1_reg), REG_WIDTH));
                          aop <= ALU_BRUGE;
                          mop <= MEM_NOP;
                          iop <= INTR_NOP;
                          unit <= UNIT_ALU;
                          target <= TARGET_PC;
                          dest_out <= src1_reg;
          when
            OPC_BRUGT => imm <= std_logic_vector(resize(signed(src2_reg & src1_reg), REG_WIDTH));
                         aop <= ALU_BRUGT;
                         mop <= MEM_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_ALU;
                         target <= TARGET_PC;
                         dest_out <= src1_reg;
          when
            OPC_SEXT =>  aop <= ALU_SEXT;
                         mop <= MEM_NOP;
                         iop <= INTR_NOP;
                         unit <= UNIT_ALU;
                         target <= TARGET_REGISTER;
                         dest_out <= src1_reg;
          when
            OPC_LDVEC => imm <= std_logic_vector(resize(unsigned(src2_reg), REG_WIDTH));
                         iop <= INTR_LDVEC;
                         aop <= ALU_NOP;
                         mop <= MEM_NOP;
                         unit <= UNIT_INTR;
                         target <= TARGET_REGISTER;
                         dest_out <= src1_reg;
          when
            OPC_STVEC => imm <= std_logic_vector(resize(unsigned(src2_reg), REG_WIDTH));
                         iop <= INTR_STVEC;
                         aop <= ALU_NOP;
                         mop <= MEM_NOP;
                         unit <= UNIT_INTR;
                         target <= TARGET_NONE;
                         dest_out <= src1_reg;
          when
            OPC_PFX_C1 =>
            case instr_reg(PDATA_WIDTH-9 downto PDATA_WIDTH-12) is
              when
                OPC_JMP => aop <= ALU_JMP;
                           mop <= MEM_NOP;
                           iop <= INTR_NOP;
                           unit <= UNIT_ALU;
                           target <= TARGET_PC;
                           dest_out <= src1_reg;
              when
                OPC_JMPZ => aop <= ALU_JMPZ;
                            mop <= MEM_NOP;
                            iop <= INTR_NOP;
                            unit <= UNIT_ALU;
                            target <= TARGET_PC;
                            dest_out <= src1_reg;
              when
                OPC_JMPNZ => aop <= ALU_JMPNZ;
                             mop <= MEM_NOP;
                             iop <= INTR_NOP;
                             unit <= UNIT_ALU;
                             target <= TARGET_PC;
                             dest_out <= src1_reg;
              when
                OPC_JMPLE => aop <= ALU_JMPLE;
                             mop <= MEM_NOP;
                             iop <= INTR_NOP;
                             unit <= UNIT_ALU;
                             target <= TARGET_PC;
                             dest_out <= src1_reg;
              when
                OPC_JMPLT => aop <= ALU_JMPLT;
                             mop <= MEM_NOP;
                             iop <= INTR_NOP;
                             unit <= UNIT_ALU;
                             target <= TARGET_PC;
                             dest_out <= src1_reg;
              when
                OPC_JMPGE => aop <= ALU_JMPGE;
                             mop <= MEM_NOP;
                             iop <= INTR_NOP;
                             unit <= UNIT_ALU;
                             target <= TARGET_PC;
                             dest_out <= src1_reg;
              when
                OPC_JMPGT => aop <= ALU_JMPGT;
                             mop <= MEM_NOP;
                             iop <= INTR_NOP;
                             unit <= UNIT_ALU;
                             target <= TARGET_PC;
                             dest_out <= src1_reg;
              when
                OPC_JMPULE => aop <= ALU_JMPULE;
                              mop <= MEM_NOP;
                              iop <= INTR_NOP;
                              unit <= UNIT_ALU;
                              target <= TARGET_PC;
                              dest_out <= src1_reg;
              when
                OPC_JMPULT => aop <= ALU_JMPULT;
                              mop <= MEM_NOP;
                              iop <= INTR_NOP;
                              unit <= UNIT_ALU;
                              target <= TARGET_PC;
                              dest_out <= src1_reg;
              when
                OPC_JMPUGE => aop <= ALU_JMPUGE;
                              mop <= MEM_NOP;
                              iop <= INTR_NOP;
                              unit <= UNIT_ALU;
                              target <= TARGET_PC;
                              dest_out <= src1_reg;
              when
                OPC_JMPUGT => aop <= ALU_JMPUGT;
                              mop <= MEM_NOP;
                              iop <= INTR_NOP;
                              unit <= UNIT_ALU;
                              target <= TARGET_PC;
                              dest_out <= src1_reg;
              when
                OPC_INTR => imm <= std_logic_vector(resize(unsigned(src1_reg), REG_WIDTH));
                            aop <= ALU_INTR;
                            iop <= INTR_INTR;
                            mop <= MEM_NOP;                    
                            unit <= UNIT_INTR;
                            target <= TARGET_PC;
                            dest_out <= src1_reg;
              when
                OPC_GETFL => aop <= ALU_GETFL;
                             mop <= MEM_NOP;
                             iop <= INTR_NOP;
                             unit <= UNIT_ALU;
                             target <= TARGET_REGISTER;
                             dest_out <= src1_reg;
              when
                OPC_SETFL => aop <= ALU_SETFL;
                             mop <= MEM_NOP;
                             iop <= INTR_NOP;
                             unit <= UNIT_ALU;
                             target <= TARGET_NONE;
                             dest_out <= src1_reg;
              when
                OPC_GETIRA => iop <= INTR_GETIRA;
                              aop <= ALU_NOP;
                              mop <= MEM_NOP;
                              unit <= UNIT_INTR;
                              target <= TARGET_REGISTER;
                              dest_out <= src1_reg;

              when
                OPC_SETIRA => iop <= INTR_SETIRA;
                              aop <= ALU_NOP;
                              mop <= MEM_NOP;
                              unit <= UNIT_INTR;
                              target <= TARGET_NONE;
                              dest_out <= src1_reg;
              when others => null;
            end case;
            
          when
            OPC_PFX_C2 =>
            case instr_reg(PDATA_WIDTH-9 downto PDATA_WIDTH-12) is
              when
                OPC_GETSHFL => aop <= ALU_GETSHFL;
                               mop <= MEM_NOP;
                               iop <= INTR_NOP;
                               unit <= UNIT_ALU;
                               target <= TARGET_REGISTER;
                               dest_out <= src1_reg;
              when
                OPC_SETSHFL => aop <= ALU_SETSHFL;
                               mop <= MEM_NOP;
                               iop <= INTR_NOP;
                               unit <= UNIT_ALU;
                               target <= TARGET_NONE;
                               dest_out <= src1_reg;
              when
                OPC_PFX_C2a =>
                case instr_reg(PDATA_WIDTH-13 downto PDATA_WIDTH-16) is
                  when
                    OPC_RETI => aop <= ALU_RETI;
                                iop <= INTR_RETI;
                                mop <= MEM_NOP;
                                unit <= UNIT_INTR;
                                target <= TARGET_PC;
                                dest_out <= src1_reg;
                  when
                    OPC_NOP => aop <= ALU_NOP;
                               mop <= MEM_NOP;
                               iop <= INTR_NOP;
                               unit <= UNIT_ALU;
                               target <= TARGET_NONE;
                               dest_out <= src1_reg;
                  when
                    OPC_SEI => aop <= ALU_SEI;
                               mop <= MEM_NOP;
                               iop <= INTR_NOP;
                               unit <= UNIT_ALU;
                               target <= TARGET_NONE;
                               dest_out <= src1_reg;
                  when
                    OPC_CLI => aop <= ALU_CLI;
                               mop <= MEM_NOP;
                               iop <= INTR_NOP;
                               unit <= UNIT_ALU;
                               target <= TARGET_NONE;
                               dest_out <= src1_reg;                               
                  when others => null;
                end case;
              when others => null;
            end case;
          when others => null;
        end case;
      when others => null;
    end case;
    
  end process;
  
end behaviour;
