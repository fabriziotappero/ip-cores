------------------------------------------------------------------------------------
--                                                                                --
--    Copyright (c) 2004, Hangouet Samuel                                         --
--                  , Jan Sebastien                                               --
--                  , Mouton Louis-Marie                                          --
--                  , Schneider Olivier     all rights reserved                   --
--                                                                                --
--    This file is part of miniMIPS.                                              --
--                                                                                --
--    miniMIPS is free software; you can redistribute it and/or modify            --
--    it under the terms of the GNU Lesser General Public License as published by --
--    the Free Software Foundation; either version 2.1 of the License, or         --
--    (at your option) any later version.                                         --
--                                                                                --
--    miniMIPS is distributed in the hope that it will be useful,                 --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of              --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               --
--    GNU Lesser General Public License for more details.                         --
--                                                                                --
--    You should have received a copy of the GNU Lesser General Public License    --
--    along with miniMIPS; if not, write to the Free Software                     --
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   --
--                                                                                --
------------------------------------------------------------------------------------


-- If you encountered any problem, please contact :
--
--   lmouton@enserg.fr
--   oschneid@enserg.fr
--   shangoue@enserg.fr
--



--------------------------------------------------------------------------
--                                                                      --
--                                                                      --
--        Processor miniMIPS : Instruction decoding stage               --
--                                                                      --
--                                                                      --
--                                                                      --
-- Authors : Hangouet  Samuel                                           --
--           Jan       Sébastien                                        --
--           Mouton    Louis-Marie                                      --
--           Schneider Olivier                                          --
--                                                                      --
--                                                          june 2003   --
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.pack_mips.all;

entity pps_di is
port (
    clock : in std_logic;
    reset : in std_logic;
    stop_all : in std_logic;            -- Unconditionnal locking of the outputs
    clear : in std_logic;               -- Clear the pipeline stage (nop in the outputs)

    -- Asynchronous connexion with the register management and data bypass unit
    adr_reg1 : out adr_reg_type;        -- Address of the first register operand
    adr_reg2 : out adr_reg_type;        -- Address of the second register operand
    use1 : out std_logic;               -- Effective use of operand 1
    use2 : out std_logic;               -- Effective use of operand 2

    stop_di : in std_logic;             -- Unresolved detected : send nop in the pipeline
    data1 : in bus32;                   -- Operand register 1
    data2 : in bus32;                   -- Operand register 2

    -- Datas from EI stage
    EI_adr : in bus32;                  -- Address of the instruction
    EI_instr : in bus32;                -- The instruction to decode
    EI_it_ok : in std_logic;            -- Allow hardware interruptions

    -- Synchronous output to EX stage
    DI_bra : out std_logic;             -- Branch decoded 
    DI_link : out std_logic;            -- A link for that instruction
    DI_op1 : out bus32;                 -- operand 1 for alu
    DI_op2 : out bus32;                 -- operand 2 for alu
    DI_code_ual : out alu_ctrl_type;    -- Alu operation
    DI_offset : out bus32;              -- Offset for the address calculation
    DI_adr_reg_dest : out adr_reg_type; -- Address of the destination register of the result
    DI_ecr_reg : out std_logic;         -- Effective writing of the result
    DI_mode : out std_logic;            -- Address mode (relative to pc or indexed to a register)
    DI_op_mem : out std_logic;          -- Memory operation request
    DI_r_w : out std_logic;             -- Type of memory operation (reading or writing)
    DI_adr : out bus32;                 -- Address of the decoded instruction
    DI_exc_cause : out bus32;           -- Potential exception detected
    DI_level : out level_type;          -- Availability of the result for the data bypass
    DI_it_ok : out std_logic            -- Allow hardware interruptions
);
end entity;


architecture rtl of pps_di is

    -- Enumeration type used for the micro-code of the instruction
    type op_mode_type is (OP_NORMAL, OP_SPECIAL, OP_REGIMM, OP_COP0);   -- selection du mode de l'instruction
    type off_sel_type is (OFS_PCRL, OFS_NULL, OFS_SESH, OFS_SEXT);      -- selection de la valeur de l'offset
    type rdest_type is ( D_RT, D_RD, D_31, D_00);                       -- selection du registre destination

    -- Record type containg the micro-code of an instruction
    type micro_instr_type is
    record
        op_mode : op_mode_type;    -- Instruction codop mode
        op_code : bus6;            -- Instruction codop
        bra : std_logic;           -- Branch instruction
        link : std_logic;          -- Branch with link : the return address is saved in a register
        code_ual : alu_ctrl_type;  -- Operation code for the alu
        op_mem : std_logic;        -- Memory operation needed
        r_w : std_logic;           -- Read/Write selection in memory
        mode : std_logic;          -- Address calculation from the current pc ('1') or the alu operand 1 ('0')
        off_sel : off_sel_type;    -- Offset source : PC(31..28) & Adresse & 00 || 0 || sgn_ext(Imm) & 00 || sgn_ext(Imm)
        exc_cause : bus32;         -- Unconditionnal exception cause to generate
        cop_org1 : std_logic;      -- Source register 1 : general register if 0, coprocessor register if 1
        cop_org2 : std_logic;      -- Source register 2 : general register if 0, coprocessor register if 1
        cs_imm1 : std_logic;       -- Use of immediat operand 1 instead of register bank
        cs_imm2 : std_logic;       -- Use of immediat operand 2 instead of register bank
        imm1_sel : std_logic;      -- Origine of immediat operand 1
        imm2_sel : std_logic;      -- Origine of immediat operand 2
        level : level_type;        -- Data availability stage for the bypass
        ecr_reg : std_logic;       -- Writing the result in a register
        bank_des : std_logic;      -- Register bank selection : GPR if 0, coprocessor system if 1
        des_sel : rdest_type ;     -- Destination register address : Rt, Rd, $31, $0
    end record;

    type micro_code_type is array (natural range <>) of micro_instr_type;

    constant micro_code : micro_code_type :=
( -- Instruction decoding in micro-instructions table
(OP_SPECIAL, "100000", '0', '0', OP_ADD  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- ADD
(OP_NORMAL , "001000", '0', '0', OP_ADD  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '1', '0', '1', LVL_EX , '1', '0', D_RT), -- ADDI
(OP_NORMAL , "001001", '0', '0', OP_ADDU , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_EX , '1', '0', D_RT), -- ADDIU
(OP_SPECIAL, "100001", '0', '0', OP_ADDU , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- ADDU
(OP_SPECIAL, "100100", '0', '0', OP_AND  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- AND
(OP_NORMAL , "001100", '0', '0', OP_AND  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_EX , '1', '0', D_RT), -- ANDI
(OP_NORMAL , "000100", '1', '0', OP_EQU  , '0', '0', '1', OFS_SESH, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_DI , '0', '0', D_RT), -- BEQ
(OP_REGIMM , "000001", '1', '0', OP_LPOS , '0', '0', '1', OFS_SESH, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_DI , '0', '0', D_RT), -- BGEZ
(OP_REGIMM , "010001", '1', '1', OP_LPOS , '0', '0', '1', OFS_SESH, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_EX , '1', '0', D_31), -- BGEZAL
(OP_NORMAL , "000111", '1', '0', OP_SPOS , '0', '0', '1', OFS_SESH, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_DI , '0', '0', D_RT), -- BGTZ
(OP_NORMAL , "000110", '1', '0', OP_LNEG , '0', '0', '1', OFS_SESH, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_DI , '0', '0', D_RT), -- BLEZ
(OP_REGIMM , "000000", '1', '0', OP_SNEG , '0', '0', '1', OFS_SESH, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_DI , '0', '0', D_RT), -- BLTZ
(OP_REGIMM , "010000", '1', '1', OP_SNEG , '0', '0', '1', OFS_SESH, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_EX , '1', '0', D_31), -- BLTZAL
(OP_NORMAL , "000101", '1', '0', OP_NEQU , '0', '0', '1', OFS_SESH, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_DI , '0', '0', D_RT), -- BNE
(OP_SPECIAL, "001101", '0', '0', OP_OUI  , '0', '0', '0', OFS_PCRL, IT_BREAK, '0', '0', '1', '1', '0', '0', LVL_DI , '0', '0', D_RT), -- BREAK
(OP_COP0   , "000001", '0', '0', OP_OP2  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '1', '1', '0', '0', LVL_DI , '1', '1', D_00), -- COP0
(OP_NORMAL , "000010", '1', '0', OP_OUI  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '1', '1', '0', '0', LVL_DI , '0', '0', D_RT), -- J
(OP_NORMAL , "000011", '1', '1', OP_OUI  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '1', '1', '0', '0', LVL_EX , '1', '0', D_31), -- JAL
(OP_SPECIAL, "001001", '1', '1', OP_OUI  , '0', '0', '0', OFS_NULL, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_EX , '1', '0', D_RD), -- JALR
(OP_SPECIAL, "001000", '1', '0', OP_OUI  , '0', '0', '0', OFS_NULL, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_DI , '0', '0', D_RT), -- JR
(OP_NORMAL , "001111", '0', '0', OP_LUI  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '1', '1', '0', '0', LVL_EX , '1', '0', D_RT), -- LUI
(OP_NORMAL , "100011", '0', '0', OP_OUI  , '1', '0', '0', OFS_SEXT, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_MEM, '1', '0', D_RT), -- LW
(OP_NORMAL , "110000", '0', '0', OP_OUI  , '1', '0', '0', OFS_SEXT, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_MEM, '1', '1', D_RT), -- LWC0
(OP_COP0   , "000000", '0', '0', OP_OP2	 , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '1', '1', '0', '0', '0', LVL_DI , '1', '0', D_RD), -- MFC0
(OP_SPECIAL, "010000", '0', '0', OP_MFHI , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '1', '1', '0', '0', LVL_EX , '1', '0', D_RD), -- MFHI
(OP_SPECIAL, "010010", '0', '0', OP_MFLO , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '1', '1', '0', '0', LVL_EX , '1', '0', D_RD), -- MFLO
(OP_COP0   , "000100", '0', '0', OP_OP2  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '1', '0', '0', '0', LVL_DI , '1', '1', D_RD), -- MTC0
(OP_SPECIAL, "010001", '0', '0', OP_MTHI , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_DI , '0', '0', D_RT), -- MTHI
(OP_SPECIAL, "010011", '0', '0', OP_MTLO , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_DI , '0', '0', D_RT), -- MTLO
(OP_SPECIAL, "011000", '0', '0', OP_MULT , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '0', '0', D_RT), -- MULT
(OP_SPECIAL, "011001", '0', '0', OP_MULTU, '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '0', '0', D_RT), -- MULT
(OP_SPECIAL, "100111", '0', '0', OP_NOR  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- NOR
(OP_SPECIAL, "100101", '0', '0', OP_OR   , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- OR
(OP_NORMAL , "001101", '0', '0', OP_OR   , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_EX , '1', '0', D_RT), -- ORI
(OP_SPECIAL, "000000", '0', '0', OP_SLL  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '1', '0', '1', '0', LVL_EX , '1', '0', D_RD), -- SLL
(OP_SPECIAL, "000100", '0', '0', OP_SLL  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- SLLV
(OP_SPECIAL, "101010", '0', '0', OP_SLT  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- SLT
(OP_NORMAL , "001010", '0', '0', OP_SLT  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '1', '0', '1', LVL_EX , '1', '0', D_RT), -- SLTI
(OP_NORMAL , "001011", '0', '0', OP_SLTU , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '1', '0', '1', LVL_EX , '1', '0', D_RT), -- SLTIU
(OP_SPECIAL, "101011", '0', '0', OP_SLTU , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- SLTU
(OP_SPECIAL, "000011", '0', '0', OP_SRA  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '1', '0', '1', '0', LVL_EX , '1', '0', D_RD), -- SRA
(OP_SPECIAL, "000111", '0', '0', OP_SRA  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- SRAV
(OP_SPECIAL, "000010", '0', '0', OP_SRL  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '1', '0', '1', '0', LVL_EX , '1', '0', D_RD), -- SRL
(OP_SPECIAL, "000110", '0', '0', OP_SRL  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- SRLV
(OP_SPECIAL, "100010", '0', '0', OP_SUB  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- SUB
(OP_SPECIAL, "100011", '0', '0', OP_SUBU , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- SUBU
(OP_NORMAL , "101011", '0', '0', OP_OP2  , '1', '1', '0', OFS_SEXT, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_DI , '0', '0', D_RT), -- SW
(OP_NORMAL , "111000", '0', '0', OP_OP2  , '1', '1', '0', OFS_SEXT, IT_NOEXC, '0', '1', '0', '0', '0', '0', LVL_DI , '0', '0', D_RT), -- SWC0
(OP_SPECIAL, "001100", '0', '0', OP_OUI  , '0', '0', '0', OFS_PCRL, IT_SCALL, '0', '0', '1', '1', '0', '0', LVL_DI , '0', '0', D_RT), -- SYSC
(OP_SPECIAL, "100110", '0', '0', OP_XOR  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '0', '0', '0', LVL_EX , '1', '0', D_RD), -- XOR
(OP_NORMAL , "001110", '0', '0', OP_XOR  , '0', '0', '0', OFS_PCRL, IT_NOEXC, '0', '0', '0', '1', '0', '0', LVL_EX , '1', '0', D_RT)  -- XORI
);

    -- Preparation of the synchronous outputs
    signal PRE_bra : std_logic;             -- Branch operation
    signal PRE_link : std_logic;            -- Branch with link
    signal PRE_op1 : bus32;                 -- operand 1 of the ual
    signal PRE_op2 : bus32;                 -- operand 2 of the ual
    signal PRE_code_ual : alu_ctrl_type;    -- Alu operation
    signal PRE_offset : bus32;              -- Address offset for calculation
    signal PRE_adr_reg_dest : adr_reg_type; -- Destination register adress for result
    signal PRE_ecr_reg : std_logic;         -- Writing of result in the bank register
    signal PRE_mode : std_logic;            -- Address calculation with current pc
    signal PRE_op_mem : std_logic;          -- Memory access operation instruction 
    signal PRE_r_w : std_logic;             -- Read/write selection in memory
    signal PRE_exc_cause : bus32;           -- Potential exception cause
    signal PRE_level : level_type;          -- Result availability stage for bypass

begin


    -- Instruction decoding
    process (EI_instr, EI_adr, data1, data2)
        variable op_code : bus6;             -- Effective codop of the instruction
        variable op_mode : op_mode_type;     -- Instruction mode
        variable flag : boolean;             -- Is true if valid instruction
        variable instr : integer;            -- Current micro-instruction adress

        -- Instruction fields
        variable rs : bus5;
        variable rt : bus5;
        variable rd : bus5;
        variable shamt : bus5;
        variable imm : bus16;
        variable address : bus26;
    begin

        -- Selection of the instruction codop and its mode
        case EI_instr(31 downto 26) is
            when "000000" => -- special mode 
                op_mode := OP_SPECIAL;
                op_code := EI_instr(5 downto 0);
            when "000001" => -- regimm mode
                op_mode := OP_REGIMM;
                op_code := '0' & EI_instr(20 downto 16);
            when "010000" => -- cop0 mode
                op_mode := OP_COP0;
                op_code := '0' & EI_instr(25 downto 21);
            when others   => -- normal mode
                op_mode := OP_NORMAL;
                op_code := EI_instr(31 downto 26);
        end case;


        -- Search the current instruction in the micro-code table
        flag := false;
        instr := 0;
        for i in micro_code'range loop
            if micro_code(i).op_mode=op_mode and micro_code(i).op_code=op_code then
                flag := true;           -- The instruction exists
                instr := i;             -- Index memorisation
            end if;
        end loop;

        -- Read the instruction field
        rs      := EI_instr(25 downto 21);
        rt      := EI_instr(20 downto 16);
        rd      := EI_instr(15 downto 11);
        shamt   := EI_instr(10 downto  6);
        imm     := EI_instr(15 downto  0);
        address := EI_instr(25 downto  0);

        if not flag then -- Unknown instruction

            -- Synchronous output preparation
            PRE_bra          <= '0';              -- Branch operation
            PRE_link         <= '0';              -- Branch with link
            PRE_op1          <= (others => '0');  -- operand 1 of the ual
            PRE_op2          <= (others => '0');  -- operand 2 of the ual
            PRE_code_ual     <= OP_OUI;           -- Alu operation
            PRE_offset       <= (others => '0');  -- Address offset for calculation
            PRE_adr_reg_dest <= (others => '0');  -- Destination register adress for result
            PRE_ecr_reg      <= '0';              -- Writing of result in the bank register
            PRE_mode         <= '0';              -- Address calculation with current pc
            PRE_op_mem       <= '0';              -- Memory access operation instruction 
            PRE_r_w          <= '0';              -- Read/write selection in memory
            PRE_exc_cause    <= IT_ERINS;         -- Potential exception cause
            PRE_level        <= LVL_DI;           -- Result availability stage for bypass

            -- Set asynchronous outputs
            adr_reg1 <= (others => '0');    -- First operand register
            adr_reg2 <= (others => '0');    -- Second operand register
            use1 <= '0';                    -- Effective use of operand 1
            use2 <= '0';                    -- Effective use of operand 2

        else -- Valid instruction

            -- Offset signal preparation
            case micro_code(instr).off_sel is
                when OFS_PCRL => -- PC(31..28) & Adresse & 00
                    PRE_offset <= EI_adr(31 downto 28) & address & "00";
                when OFS_NULL => -- 0
                    PRE_offset <= (others => '0');
                when OFS_SESH => -- sgn_ext(Imm) & 00
                    if imm(15)='1' then
                        PRE_offset <= "11111111111111" & imm & "00";
                    else
                        PRE_offset <= "00000000000000" & imm & "00";
                    end if;
                when OFS_SEXT => -- sgn_ext(Imm)
                    if imm(15)='1' then
                        PRE_offset <= "1111111111111111" & imm;
                    else
                        PRE_offset <= "0000000000000000" & imm;
                    end if;
            end case;


            -- Alu operand preparation
            if micro_code(instr).cs_imm1='0' then
                -- Datas from register banks
                PRE_op1 <= data1;
            else
                -- Immediate datas
                if micro_code(instr).imm1_sel='0' then
                    PRE_op1 <= (others => '0');             -- Immediate operand = 0
                else
                    PRE_op1 <= X"000000" & "000" & shamt;   -- Immediate operand = shamt
                end if;
            end if;


            if micro_code(instr).cs_imm2='0' then
                -- Datas from register banks
                PRE_op2 <= data2;
            else
                -- Immediate datas
                if micro_code(instr).imm2_sel='0' then
                    PRE_op2 <= X"0000" & imm;               -- Immediate operand = imm
                else
                    if imm(15)='1' then                     -- Immediate operand = sgn_ext(imm)
                        PRE_op2 <= X"FFFF" & imm;
                    else
                        PRE_op2 <= X"0000" & imm;
                    end if;
                end if;
            end if;

            -- Selection of destination register address
            case micro_code(instr).des_sel is
                when D_RT => PRE_adr_reg_dest <= micro_code(instr).bank_des & rt;
                when D_RD => PRE_adr_reg_dest <= micro_code(instr).bank_des & rd;
                when D_31 => PRE_adr_reg_dest <= micro_code(instr).bank_des & "11111";
                when D_00 => PRE_adr_reg_dest <= micro_code(instr).bank_des & "00000";
            end case;

            -- Command signal affectation
            PRE_bra       <= micro_code(instr).bra;        -- Branch operation
            PRE_link      <= micro_code(instr).link;       -- Branch with link
            PRE_code_ual  <= micro_code(instr).code_ual;   -- Alu operation
            PRE_ecr_reg   <= micro_code(instr).ecr_reg;    -- Writing the result in a bank register
            PRE_mode      <= micro_code(instr).mode;       -- Type of calculation for the address with current pc
            PRE_op_mem    <= micro_code(instr).op_mem;     -- Memory operation needed
            PRE_r_w       <= micro_code(instr).r_w;        -- Read/Write in memory selection
            PRE_exc_cause <= micro_code(instr).exc_cause;  -- Potential cause exception
            PRE_level     <= micro_code(instr).level;

            -- Set asynchronous outputs
            adr_reg1 <= micro_code(instr).cop_org1 & rs; -- First operand register address
            adr_reg2 <= micro_code(instr).cop_org2 & rt; -- Second operand register address
            use1 <= not micro_code(instr).cs_imm1;       -- Effective use of operande 1
            use2 <= not micro_code(instr).cs_imm2;       -- Effective use of operande 2
        end if;

    end process;



    -- Set the synchronous outputs
    process (clock)
    begin
        if clock='1' and clock'event then
            if reset='1' then
                DI_bra <= '0';
                DI_link <= '0';
                DI_op1 <= (others => '0');
                DI_op2 <= (others => '0');
                DI_code_ual <= OP_OUI;
                DI_offset <= (others => '0');
                DI_adr_reg_dest <= (others => '0');
                DI_ecr_reg <= '0';
                DI_mode <= '0';
                DI_op_mem <= '0';
                DI_r_w <= '0';
                DI_adr <= (others => '0');
                DI_exc_cause <= IT_NOEXC;
                DI_level <= LVL_DI;
                DI_it_ok <= '0';
            elsif stop_all='0' then
                if clear='1' or stop_di='1' then
                    -- Nop instruction
                    DI_bra <= '0';
                    DI_link <= '0';
                    DI_op1 <= (others => '0');
                    DI_op2 <= (others => '0');
                    DI_code_ual <= OP_OUI;
                    DI_offset <= (others => '0');
                    DI_adr_reg_dest <= (others => '0');
                    DI_ecr_reg <= '0';
                    DI_mode <= '0';
                    DI_op_mem <= '0';
                    DI_r_w <= '0';
                    DI_adr <= EI_adr;
                    DI_exc_cause <= IT_NOEXC;
                    DI_level <= LVL_DI;
                    if clear='1' then
                      DI_it_ok <= '0';
                    else
                      DI_it_ok <= EI_it_ok;
                    end if;
                else -- Noraml step
                    DI_bra <= PRE_bra;
                    DI_link <= PRE_link;
                    DI_op1 <= PRE_op1;
                    DI_op2 <= PRE_op2;
                    DI_code_ual <= PRE_code_ual;
                    DI_offset <= PRE_offset;
                    DI_adr_reg_dest <= PRE_adr_reg_dest;
                    DI_ecr_reg <= PRE_ecr_reg;
                    DI_mode <= PRE_mode;
                    DI_op_mem <= PRE_op_mem;
                    DI_r_w <= PRE_r_w;
                    DI_adr <= EI_adr;
                    DI_exc_cause <= PRE_exc_cause;
                    DI_level <= PRE_level;
                    DI_it_ok <= EI_it_ok;
                end if;
            end if;
        end if;
    end process;

end rtl;


