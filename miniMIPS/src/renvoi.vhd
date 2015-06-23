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
--               miniMIPS Processor : Bypass unit                       --
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

entity renvoi is
port (
    -- Register access signals
    adr1 : in adr_reg_type;    -- Operand 1 address
    adr2 : in adr_reg_type;    -- Operand 2 address
    use1 : in std_logic;       -- Operand 1 utilisation
    use2 : in std_logic;       -- Operand 2 utilisation

    data1 : out bus32;         -- First register value
    data2 : out bus32;         -- Second register value
    alea : out std_logic;      -- Unresolved hazards detected

    -- Bypass signals of the intermediary datas
    DI_level : in level_type;  -- Availability level of the data
    DI_adr : in adr_reg_type;  -- Register destination of the result
    DI_ecr : in std_logic;     -- Writing register request
    DI_data : in bus32;        -- Data to used

    EX_level : in level_type;  -- Availability level of the data
    EX_adr : in adr_reg_type;  -- Register destination of the result
    EX_ecr : in std_logic;     -- Writing register request
    EX_data : in bus32;        -- Data to used

    MEM_level : in level_type; -- Availability level of the data
    MEM_adr : in adr_reg_type; -- Register destination of the result
    MEM_ecr : in std_logic;    -- Writing register request
    MEM_data : in bus32;       -- Data to used
    
    interrupt : in std_logic;  -- Exceptions or interruptions

    -- Connexion to the differents bank of register

      -- Writing commands for writing in the registers
    write_data : out bus32;    -- Data to write
    write_adr : out bus5;      -- Address of the register to write
    write_GPR : out std_logic; -- Selection in the internal registers
    write_SCP : out std_logic; -- Selection in the coprocessor system registers

      -- Reading commands for Reading in the registers
    read_adr1 : out bus5;      -- Address of the first register to read
    read_adr2 : out bus5;      -- Address of the second register to read
    read_data1_GPR : in bus32; -- Value of operand 1 from the internal registers
    read_data2_GPR : in bus32; -- Value of operand 2 from the internal registers
    read_data1_SCP : in bus32; -- Value of operand 1 from the coprocessor system registers
    read_data2_SCP : in bus32  -- Value of operand 2 from the coprocessor system registers
);
end renvoi;

architecture rtl of renvoi is
    signal dep_r1 : level_type; -- Dependency level for operand 1
    signal dep_r2 : level_type; -- Dependency level for operand 2
    signal read_data1 : bus32;  -- Data contained in the register asked by operand 1
    signal read_data2 : bus32;  -- Data contained in the register asked by operand 2
    signal res_reg, res_mem, res_ex, res_di : std_logic;
    signal resolution : bus4;   -- Verification of the resolved hazards

    signal idx1, idx2 : integer range 0 to 3;
begin

    -- Connexion of the writing command signals
    write_data <= MEM_data;
    write_adr <= MEM_adr(4 downto 0);
    write_GPR <= not MEM_adr(5) and MEM_ecr when interrupt = '0' else  -- The high bit to 0 selects the internal registers
                 '0';
    write_SCP <= MEM_adr(5) and MEM_ecr;      -- The high bit to 1 selects the coprocessor system registers

    -- Connexion of the writing command signals
    read_adr1 <= adr1(4 downto 0);            -- Connexion of the significative address bits
    read_adr2 <= adr2(4 downto 0);            -- Connexion of the significative address bits

    -- Evaluation of the level of dependencies
    dep_r1 <= LVL_REG when adr1(4 downto 0)="00000" or use1='0' else -- No dependency with register 0
              LVL_DI  when adr1=DI_adr  and DI_ecr ='1' else         -- Dependency with DI stage
              LVL_EX  when adr1=EX_adr  and EX_ecr ='1' else         -- Dependency with DI stage
              LVL_MEM when adr1=MEM_adr and MEM_ecr='1' else         -- Dependency with DI stage
              LVL_REG;                                               -- No dependency detected

    dep_r2 <= LVL_REG when adr2(4 downto 0)="00000" or use2='0' else -- No dependency with register 0
              LVL_DI  when adr2=DI_adr  and DI_ecr ='1' else         -- Dependency with DI stage
              LVL_EX  when adr2=EX_adr  and EX_ecr ='1' else         -- Dependency with DI stage
              LVL_MEM when adr2=MEM_adr and MEM_ecr='1' else         -- Dependency with DI stage
              LVL_REG;                                               -- No dependency detected

    -- Elaboration of the signals with the datas form the bank registers
    read_data1 <= read_data1_GPR when adr1(5)='0' else       -- Selection of the internal registers
                  read_data1_SCP when adr1(5)='1' else       -- Selection of the coprocessor registers
                  (others => '0');

    read_data2 <= read_data2_GPR when adr2(5)='0' else       -- Selection of the internal registers   
                  read_data2_SCP when adr2(5)='1' else       -- Selection of the coprocessor registers
                  (others => '0');

    -- Bypass the datas (the validity is tested later when detecting the hazards)
    data1 <= read_data1 when dep_r1=LVL_REG else
             MEM_data   when dep_r1=LVL_MEM else
             EX_data    when dep_r1=LVL_EX  else
             DI_data;

    data2 <= read_data2 when dep_r2=LVL_REG else
             MEM_data   when dep_r2=LVL_MEM else
             EX_data    when dep_r2=LVL_EX  else
             DI_data;

    -- Detection of a potential unresolved hazard
    res_reg <= '1'; -- This hazard is always resolved
    res_mem <= '1' when MEM_level>=LVL_MEM else '0';
    res_ex  <= '1' when EX_level >=LVL_EX  else '0';
    res_di  <= '1' when DI_level >=LVL_DI  else '0';

    -- Table defining the resolved hazard for each stage
    resolution <= res_di & res_ex & res_mem & res_reg;

    -- Verification of the validity of the transmitted datas (test the good resolution of the hazards)
    idx1 <= to_integer(unsigned(dep_r1(1 downto 0)));
    idx2 <= to_integer(unsigned(dep_r2(1 downto 0)));
    alea <= not resolution(idx1) or not resolution(idx2);

end rtl;
