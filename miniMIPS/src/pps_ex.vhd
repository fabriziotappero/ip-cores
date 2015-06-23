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
--             Processor miniMIPS : Execution stage                     --
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
use work.alu;

entity pps_ex is
port(
    clock : in std_logic;
    reset : in std_logic;
    stop_all : in std_logic;            -- Unconditionnal locking of outputs
    clear : in std_logic;               -- Clear the pipeline stage

    -- Datas from DI stage
    DI_bra : in std_logic;              -- Branch instruction
    DI_link : in std_logic;             -- Branch with link
    DI_op1 : in bus32;                  -- Operand 1 for alu
    DI_op2 : in bus32;                  -- Operand 2 for alu
    DI_code_ual : in alu_ctrl_type;     -- Alu operation
    DI_offset : in bus32;               -- Offset for address calculation
    DI_adr_reg_dest : in adr_reg_type;  -- Destination register address for the result
    DI_ecr_reg : in std_logic;          -- Effective writing of the result
    DI_mode : in std_logic;             -- Address mode (relative to pc ou index by a register)
    DI_op_mem : in std_logic;           -- Memory operation
    DI_r_w : in std_logic;              -- Type of memory operation (read or write)
    DI_adr : in bus32;                  -- Instruction address
    DI_exc_cause : in bus32;            -- Potential cause exception
    DI_level : in level_type;           -- Availability stage of the result for bypassing
    DI_it_ok : in std_logic;            -- Allow hardware interruptions

    -- Synchronous outputs to MEM stage
    EX_adr : out bus32;                 -- Instruction address
    EX_bra_confirm : out std_logic;     -- Branch execution confirmation
    EX_data_ual : out bus32;            -- Ual result
    EX_adresse : out bus32;             -- Address calculation result
    EX_adr_reg_dest : out adr_reg_type; -- Destination register for the result
    EX_ecr_reg : out std_logic;         -- Effective writing of the result
    EX_op_mem : out std_logic;          -- Memory operation needed
    EX_r_w : out std_logic;             -- Type of memory operation (read or write)
    EX_exc_cause : out bus32;           -- Potential cause exception
    EX_level : out level_type;          -- Availability stage of result for bypassing
    EX_it_ok : out std_logic            -- Allow hardware interruptions
);
end entity;


architecture rtl of pps_ex is

component alu
    port (
        clock : in bus1;
        reset : in bus1;
        op1 : in bus32;              		-- Operand 1
        op2 : in bus32;	               	-- Operand 2
        ctrl : in alu_ctrl_type;			  -- Operation

        res : out bus32;	              -- Result
        overflow : out bus1		          -- Overflow
    );
    end component;

    signal res_ual         : bus32;      -- Alu result output
    signal base_adr        : bus32;      -- Output of the address mode mux selection

    signal pre_ecr_reg     : std_logic;  -- Output of mux selection for writing command to register
    signal pre_data_ual    : bus32;      -- Mux selection of the data to write
    signal pre_bra_confirm : std_logic;  -- Result of the test in alu when branch instruction
    signal pre_exc_cause   : bus32;      -- Preparation of the exception detection signal
    signal overflow_ual    : std_logic;  -- Dectection of the alu overflow

begin

    -- Alu instantiation
    U1_alu : alu port map (clock => clock, reset => reset, op1=>DI_op1, op2=>DI_op2, ctrl=>DI_code_ual,
                                res=>res_ual, overflow=>overflow_ual);

    -- Calculation of the future outputs
    base_adr <= DI_op1 when DI_mode='0' else DI_adr;
    pre_ecr_reg <= DI_ecr_reg when DI_link='0' else pre_bra_confirm;
    pre_data_ual <= res_ual when DI_link='0' else bus32(unsigned(DI_adr) + 4);
    pre_bra_confirm <= DI_bra and res_ual(0);
    pre_exc_cause <= DI_exc_cause when DI_exc_cause/=IT_NOEXC else
                     IT_OVERF when overflow_ual='1' else
                     IT_NOEXC;

    -- Set the synchronous outputs
    process(clock) is
    begin
        if clock='1' and clock'event then
            if reset='1' then
                EX_adr <= (others => '0');
                EX_bra_confirm <= '0';
                EX_data_ual <= (others => '0');
                EX_adresse <= (others => '0');
                EX_adr_reg_dest <= (others => '0');
                EX_ecr_reg <= '0';
                EX_op_mem <= '0';
                EX_r_w <= '0';
                EX_exc_cause <= IT_NOEXC;
                EX_level <= LVL_DI;
                EX_it_ok <= '0';
            elsif stop_all = '0' then
                if clear = '1' then -- Clear the stage
                    EX_adr <= DI_adr;
                    EX_bra_confirm <= '0';
                    EX_data_ual <= (others => '0');
                    EX_adresse <= (others => '0');
                    EX_adr_reg_dest <= (others => '0');
                    EX_ecr_reg <= '0';
                    EX_op_mem <= '0';
                    EX_r_w <= '0';
                    EX_exc_cause <= IT_NOEXC;
                    EX_level <= LVL_DI;
                    EX_it_ok <= '0';
                else -- Normal evolution
                    EX_adr <= DI_adr;
                    EX_bra_confirm <= pre_bra_confirm;
                    EX_data_ual <= pre_data_ual;
                    EX_adr_reg_dest <= DI_adr_reg_dest;
                    EX_ecr_reg <= pre_ecr_reg;
                    EX_op_mem <= DI_op_mem;
                    EX_r_w <= DI_r_w;
                    EX_exc_cause <= pre_exc_cause;
                    EX_level <= DI_level;
                    EX_it_ok <= DI_it_ok;
		    						EX_adresse <= bus32(unsigned(DI_offset) + unsigned(base_adr));
                end if;
            end if;
        end if;
    end process;

end architecture;
