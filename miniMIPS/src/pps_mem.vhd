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
--             Processor miniMIPS : Memory access stage                 --
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

library work;
use work.pack_mips.all;

entity pps_mem is
port
(
    clock : in std_logic;
    reset : in std_logic;
    stop_all : in std_logic;             -- Unconditionnal locking of the outputs
    clear : in std_logic;                -- Clear the pipeline stage

    -- Interface with the control bus
    MTC_data : out bus32;                -- Data to write in memory
    MTC_adr : out bus32;                 -- Address for memory
    MTC_r_w : out std_logic;             -- Read/Write in memory
    MTC_req : out std_logic;             -- Request access to memory
    CTM_data : in bus32;                 -- Data from memory

    -- Datas from Execution stage
    EX_adr : in bus32;                   -- Instruction address
    EX_data_ual : in bus32;              -- Result of alu operation
    EX_adresse : in bus32;               -- Result of the calculation of the address
    EX_adr_reg_dest : in adr_reg_type;   -- Destination register address for the result
    EX_ecr_reg : in std_logic;           -- Effective writing of the result
    EX_op_mem : in std_logic;            -- Memory operation needed
    EX_r_w : in std_logic;               -- Type of memory operation (read or write)
    EX_exc_cause : in bus32;             -- Potential exception cause
    EX_level : in level_type;            -- Availability stage for the result for bypassing
    EX_it_ok : in std_logic;             -- Allow hardware interruptions

    -- Synchronous outputs for bypass unit
    MEM_adr : out bus32;                 -- Instruction address
    MEM_adr_reg_dest : out adr_reg_type; -- Destination register address
    MEM_ecr_reg : out std_logic;         -- Writing of the destination register
    MEM_data_ecr : out bus32;            -- Data to write (from alu or memory)
    MEM_exc_cause : out bus32;           -- Potential exception cause
    MEM_level : out level_type;          -- Availability stage for the result for bypassing
    MEM_it_ok : out std_logic            -- Allow hardware interruptions
);
end pps_mem;


architecture rtl of pps_mem is

    signal tmp_data_ecr : bus32;         -- Selection of the data source (memory or alu)

begin

    -- Bus controler connexions
    MTC_adr <= EX_adresse;              -- Connexion of the address
    MTC_r_w <= EX_r_w;                  -- Connexion of R/W
    MTC_data <= EX_data_ual;            -- Connexion of the data bus
    MTC_req <= EX_op_mem and not clear; -- Connexion of the request (if there is no clearing of the pipeline)


    -- Preselection of the data source for the outputs
    tmp_data_ecr <= CTM_data when EX_op_mem = '1' else EX_data_ual;


    -- Set the synchronous outputs
    process (clock)
    begin
        if clock = '1' and clock'event then
            if reset = '1' then
                MEM_adr  <= (others => '0');
                MEM_adr_reg_dest <= (others => '0');
                MEM_ecr_reg <= '0';
                MEM_data_ecr <= (others => '0');
                MEM_exc_cause <= IT_NOEXC;
                MEM_level <= LVL_DI;
                MEM_it_ok <= '0';
            elsif stop_all = '0' then
                if clear = '1' then -- Clear the stage
                    MEM_adr <= EX_adr;
                    MEM_adr_reg_dest <= (others => '0');
                    MEM_ecr_reg <= '0';
                    MEM_data_ecr <= (others => '0');
                    MEM_exc_cause <= IT_NOEXC;
                    MEM_level <= LVL_DI;
                    MEM_it_ok <= '0';
                else -- Normal evolution 
                    MEM_adr <= EX_adr;
                    MEM_adr_reg_dest <= EX_adr_reg_dest;
                    MEM_ecr_reg <= EX_ecr_reg;
                    MEM_data_ecr <= tmp_data_ecr;
                    MEM_exc_cause <= EX_exc_cause;
                    MEM_level <= EX_level;
                    MEM_it_ok <= EX_it_ok;
                end if;
            end if;
        end if;
    end process;

end rtl;
