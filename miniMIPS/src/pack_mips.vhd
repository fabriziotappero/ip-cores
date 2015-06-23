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
--     Processor miniMIPS : Enumerations and components declarations    --
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


library ieee;
use ieee.std_logic_1164.all;

package pack_mips is		    

    -- Type signal on n bits
    subtype bus64 is std_logic_vector(63 downto 0);
    subtype bus33 is std_logic_vector(32 downto 0);
    subtype bus32 is std_logic_vector(31 downto 0);
    subtype bus31 is std_logic_vector(30 downto 0);
    subtype bus26 is std_logic_vector(25 downto 0);
    subtype bus24 is std_logic_vector(23 downto 0);
    subtype bus16 is std_logic_vector(15 downto 0);
    subtype bus8 is std_logic_vector(7 downto 0);
    subtype bus6 is std_logic_vector(5 downto 0);
    subtype bus5 is std_logic_vector(4 downto 0);
    subtype bus4 is std_logic_vector(3 downto 0);
    subtype bus2 is std_logic_vector(1 downto 0);
    subtype bus1 is std_logic;

    -- Address of a register type
    subtype adr_reg_type is std_logic_vector(5 downto 0);

    -- Coding of the level of data availability for UR
    subtype level_type is std_logic_vector(1 downto 0);
    constant LVL_DI  : level_type := "11";  -- Data available from the op2 of DI stage
    constant LVL_EX  : level_type := "10";  -- Data available from the data_ual register of EX stage
    constant LVL_MEM : level_type := "01";  -- Data available from the data_ecr register of MEM stage
    constant LVL_REG : level_type := "00";  -- Data available only in the register bank

    -- Different values of cause exceptions
    constant IT_NOEXC : bus32 := X"00000000";
    constant IT_ITMAT : bus32 := X"00000001";
    constant IT_OVERF : bus32 := X"00000002";
    constant IT_ERINS : bus32 := X"00000004";
    constant IT_BREAK : bus32 := X"00000008";
    constant IT_SCALL : bus32 := X"00000010";


    -- Operation type of the coprocessor system (only the low 16 bits are valid)
    constant SYS_NOP    : bus32 := X"0000_0000";
    constant SYS_MASK   : bus32 := X"0000_0001";
    constant SYS_UNMASK : bus32 := X"0000_0002";
    constant SYS_ITRET  : bus32 := X"0000_0004";

    -- Type for the alu control
    subtype alu_ctrl_type is std_logic_vector(27 downto 0);

    -- Arithmetical operations
    constant OP_ADD   : alu_ctrl_type := "1000000000000000000000000000"; -- op1 + op2 sign‰
    constant OP_ADDU  : alu_ctrl_type := "0100000000000000000000000000"; -- op1 + op2 non sign‰
    constant OP_SUB   : alu_ctrl_type := "0010000000000000000000000000"; -- op1 - op2 sign‰
    constant OP_SUBU  : alu_ctrl_type := "0001000000000000000000000000"; -- op1 - op2 non sign‰e
    -- Logical operations
    constant OP_AND   : alu_ctrl_type := "0000100000000000000000000000"; -- et logique
    constant OP_OR    : alu_ctrl_type := "0000010000000000000000000000"; -- ou logique
    constant OP_XOR   : alu_ctrl_type := "0000001000000000000000000000"; -- ou exclusif logique
    constant OP_NOR   : alu_ctrl_type := "0000000100000000000000000000"; -- non ou logique
    -- Tests : result to one if ok
    constant OP_SLT   : alu_ctrl_type := "0000000010000000000000000000"; -- op1 < op2 (sign‰)
    constant OP_SLTU  : alu_ctrl_type := "0000000001000000000000000000"; -- op1 < op2 (non sign‰)
    constant OP_EQU   : alu_ctrl_type := "0000000000100000000000000000"; -- op1 = op2
    constant OP_NEQU  : alu_ctrl_type := "0000000000010000000000000000"; -- op1 /= op2
    constant OP_SNEG  : alu_ctrl_type := "0000000000001000000000000000"; -- op1 < 0
    constant OP_SPOS  : alu_ctrl_type := "0000000000000100000000000000"; -- op1 > 0
    constant OP_LNEG  : alu_ctrl_type := "0000000000000010000000000000"; -- op1 <= 0
    constant OP_LPOS  : alu_ctrl_type := "0000000000000001000000000000"; -- op1 >= 0
    -- Multiplications
    constant OP_MULT  : alu_ctrl_type := "0000000000000000100000000000"; -- op1 * op2 sign‰ (chargement des poids faibles)
    constant OP_MULTU : alu_ctrl_type := "0000000000000000010000000000"; -- op1 * op2 non sign‰ (chargement des poids faibles)
    -- Shifts
    constant OP_SLL   : alu_ctrl_type := "0000000000000000001000000000"; -- decallage logique a gauche
    constant OP_SRL   : alu_ctrl_type := "0000000000000000000100000000"; -- decallage logique a droite
    constant OP_SRA   : alu_ctrl_type := "0000000000000000000010000000"; -- decallage arithmetique a droite
    constant OP_LUI   : alu_ctrl_type := "0000000000000000000001000000"; -- met en poids fort la valeur immediate
    -- Access to internal registers
    constant OP_MFHI  : alu_ctrl_type := "0000000000000000000000100000"; -- lecture des poids forts
    constant OP_MFLO  : alu_ctrl_type := "0000000000000000000000010000"; -- lecture des poids faibles
    constant OP_MTHI  : alu_ctrl_type := "0000000000000000000000001000"; -- ecriture des poids forts
    constant OP_MTLO  : alu_ctrl_type := "0000000000000000000000000100"; -- ecriture des poids faibles
    -- Operations which do nothing but are useful
    constant OP_OUI   : alu_ctrl_type := "0000000000000000000000000010"; -- met a 1 le bit de poids faible en sortie
    constant OP_OP2   : alu_ctrl_type := "0000000000000000000000000001"; -- recopie l'operande 2 en sortie



    -- Starting boot address (after reset)
    constant ADR_INIT : bus32 := X"00000000";
    constant INS_NOP : bus32 := X"00000000";


    -- Internal component of the pipeline stage

    component alu
    port (
        clock : in bus1;
        reset : in bus1;
        op1 : in bus32;
        op2 : in bus32;
        ctrl : in alu_ctrl_type;

        res : out bus32;
        overflow : out bus1
    );
    end component;

    -- Pipeline stage components

    component pps_pf
    port (
        clock : in bus1;
        reset : in bus1;
        stop_all : in bus1;

	      bra_cmd  : in bus1;
        bra_cmd_pr  : in bus1;
        bra_adr  : in bus32;
        exch_cmd : in bus1;
        exch_adr : in bus32;

        stop_pf : in bus1;

        PF_pc : out bus32
    );
    end component;


    component pps_ei
    port (
        clock : in bus1;
        reset : in bus1;
        clear  : in bus1;
        stop_all : in bus1;

        stop_ei : in bus1;

        CTE_instr : in bus32;
        ETC_adr : out bus32;

        PF_pc : in bus32;

        EI_instr : out bus32;
        EI_adr : out bus32;
        EI_it_ok : out bus1
    );
    end component;


    component pps_di
    port (
        clock : in bus1;
        reset : in bus1;
        stop_all : in bus1;
        clear : in bus1;

        adr_reg1 : out adr_reg_type;
        adr_reg2 : out adr_reg_type;
        use1 : out bus1;
        use2 : out bus1;

        stop_di : in bus1;
        data1 : in bus32;
        data2 : in bus32;

        EI_adr : in bus32;
        EI_instr : in bus32;
        EI_it_ok : in bus1;

        DI_bra : out bus1;
        DI_link : out bus1;
        DI_op1 : out bus32;
        DI_op2 : out bus32;
        DI_code_ual : out alu_ctrl_type;
        DI_offset : out bus32;
        DI_adr_reg_dest : out adr_reg_type;
        DI_ecr_reg : out bus1;
        DI_mode : out bus1;
        DI_op_mem : out bus1;
        DI_r_w : out bus1;
        DI_adr : out bus32;
        DI_exc_cause : out bus32;
        DI_level : out level_type;
        DI_it_ok : out bus1
    );
    end component;


    component pps_ex
    port (
        clock : in bus1;
        reset : in bus1;
        stop_all : in bus1;
        clear : in bus1;

        DI_bra : in bus1;
        DI_link : in bus1;
        DI_op1 : in bus32;
        DI_op2 : in bus32;
        DI_code_ual : in alu_ctrl_type;
        DI_offset : in bus32;
        DI_adr_reg_dest : in adr_reg_type;
        DI_ecr_reg : in bus1;
        DI_mode : in bus1;
        DI_op_mem : in bus1;
        DI_r_w : in bus1;
        DI_adr : in bus32;
        DI_exc_cause : in bus32;
        DI_level : in level_type;
        DI_it_ok : in bus1;

        EX_adr : out bus32;
        EX_bra_confirm : out bus1;
        EX_data_ual : out bus32;
        EX_adresse : out bus32;
        EX_adr_reg_dest : out adr_reg_type;
        EX_ecr_reg : out bus1;
        EX_op_mem : out bus1;
        EX_r_w : out bus1;
        EX_exc_cause : out bus32;
        EX_level : out level_type;
        EX_it_ok : out bus1
    );
    end component;


    component pps_mem
    port (
        clock : in bus1;
        reset : in bus1;
        stop_all : in bus1;
        clear : in bus1;

        MTC_data : out bus32;
        MTC_adr : out bus32;
        MTC_r_w : out bus1;
        MTC_req : out bus1;
        CTM_data : in bus32;

        EX_adr : in bus32;
        EX_data_ual : in bus32;
        EX_adresse : in bus32;
        EX_adr_reg_dest : in adr_reg_type;
        EX_ecr_reg : in bus1;
        EX_op_mem : in bus1;
        EX_r_w : in bus1;
        EX_exc_cause : in bus32;
        EX_level : in level_type;
        EX_it_ok : in bus1;

        MEM_adr : out bus32;
        MEM_adr_reg_dest : out adr_reg_type;
        MEM_ecr_reg : out bus1;
        MEM_data_ecr : out bus32;
        MEM_exc_cause : out bus32;
        MEM_level : out level_type;
        MEM_it_ok : out bus1
    );
    end component;


    component renvoi
    port (
        adr1 : in adr_reg_type;
        adr2 : in adr_reg_type;
        use1 : in bus1;
        use2 : in bus1;

        data1 : out bus32;
        data2 : out bus32;
        alea : out bus1;

        DI_level : in level_type;
        DI_adr : in adr_reg_type;
        DI_ecr : in bus1;
        DI_data : in bus32;

        EX_level : in level_type;
        EX_adr : in adr_reg_type;
        EX_ecr : in bus1;
        EX_data : in bus32;

        MEM_level : in level_type;
        MEM_adr : in adr_reg_type;
        MEM_ecr : in bus1;
        MEM_data : in bus32;

        interrupt : in bus1;

        write_data : out bus32;
        write_adr : out bus5;
        write_GPR : out bus1;
        write_SCP : out bus1;

        read_adr1 : out bus5;
        read_adr2 : out bus5;
        read_data1_GPR : in bus32;
        read_data1_SCP : in bus32;
        read_data2_GPR : in bus32;
        read_data2_SCP : in bus32
    );
    end component;


    component banc
    port (
        clock : in bus1;
        reset : bus1;

        reg_src1 : in bus5;
        reg_src2 : in bus5;

        reg_dest : in bus5;
        donnee   : in bus32;

        cmd_ecr  : in bus1;

        data_src1 : out bus32;
        data_src2 : out bus32
    );
    end component;


    component bus_ctrl
    port
    (
        clock : bus1;
        reset : bus1;

        interrupt      : in std_logic;

        adr_from_ei    : in bus32;
        instr_to_ei    : out bus32;

        req_from_mem   : in bus1;
        r_w_from_mem   : in bus1;
        adr_from_mem   : in bus32;
        data_from_mem  : in bus32;
        data_to_mem    : out bus32;

        req_to_ram     : out std_logic;
        adr_to_ram     : out bus32;
        r_w_to_ram     : out bus1;
        ack_from_ram   : in bus1;
        data_inout_ram : inout bus32;

        stop_all       : out bus1
    );
    end component;


    component syscop
    port
    (
        clock         : in bus1;
        reset         : in bus1;

        MEM_adr       : in bus32;
        MEM_exc_cause : in bus32;
        MEM_it_ok     : in bus1;

        it_mat        : in bus1;

        interrupt     : out bus1;
        vecteur_it    : out bus32;

        write_data    : in bus32;
        write_adr     : in bus5;
        write_SCP     : in bus1;

        read_adr1     : in bus5;
        read_adr2     : in bus5;
        read_data1    : out bus32;
        read_data2    : out bus32
    );
    end component;

    component predict
    generic (
        nb_record : integer := 3
    );
    port (
    
        clock : in std_logic;
        reset : in std_logic;
    
        PF_pc  : in std_logic_vector(31 downto 0);
    
        DI_bra : in std_logic;
        DI_adr : in std_logic_vector(31 downto 0);
    
        EX_bra_confirm : in std_logic;
        EX_adr : in std_logic_vector(31 downto 0);
        EX_adresse : in std_logic_vector(31 downto 0);
        EX_uncleared : in std_logic;
    
        PR_bra_cmd : out std_logic;
        PR_bra_bad : out std_logic;
        PR_bra_adr : out std_logic_vector(31 downto 0);
    
        PR_clear : out std_logic
    );
    end component;


    component minimips
    port (
        clock    : in bus1;
        reset    : in bus1;

        ram_req  : out bus1;
        ram_adr  : out bus32;
        ram_r_w  : out bus1;
        ram_data : inout bus32;
        ram_ack  : in bus1;

        it_mat   : in bus1
    );
    end component;

end pack_mips;
