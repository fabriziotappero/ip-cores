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
--                miniMIPS Processor : Branch prediction                --
--                                                                      --
--                                                                      --
--                                                                      --
-- Author  : Olivier Schneider                                          --
--                                                                      --
--                                                          june 2004   --
--------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.pack_mips.all;


entity predict is
generic (
    nb_record : integer := 3
);
port (

    clock : in std_logic;
    reset : in std_logic;

    -- Datas from PF pipeline stage
    PF_pc  : in std_logic_vector(31 downto 0);      -- PC of the current instruction extracted

    -- Datas from DI pipeline stage
    DI_bra : in std_logic;                          -- Branch detected
    DI_adr : in std_logic_vector(31 downto 0);      -- Address of the branch

    -- Datas from EX pipeline stage
    EX_bra_confirm : in std_logic;                  -- Confirm if the branch test is ok
    EX_adr : in std_logic_vector(31 downto 0);      -- Address of the branch
    EX_adresse : in std_logic_vector(31 downto 0);  -- Result of the branch
    EX_uncleared : in std_logic;                    -- Define if the EX stage is cleared               

    -- Outputs to PF pipeline stage
    PR_bra_cmd : out std_logic;                     -- Defined a branch
    PR_bra_bad : out std_logic;                     -- Defined a branch to restore from a bad prediction
    PR_bra_adr : out std_logic_vector(31 downto 0); -- New PC

    -- Clear the three pipeline stage : EI, DI, EX
    PR_clear : out std_logic
);
end entity;


architecture rtl of predict is

    -- Record contained in the table of prediction
    type pred_type is
    record
        is_affected : std_logic; -- Check if the record is affected
        last_bra    : std_logic; -- The last branch confirmation result
        code_adr    : std_logic_vector(31 downto 0); -- Branch instruction address
        bra_adr     : std_logic_vector(31 downto 0); -- Branch result
    end record;

    type pred_tab_type is array(1 to nb_record) of pred_type;
    
    -- Table of predictions
    signal pred_tab : pred_tab_type;
    signal pre_pred_tab : pred_tab_type;

    signal next_out : integer range 1 to nb_record := 1; -- Next record to be erased in the table
    signal add_record : std_logic;
    
begin

    -- Do the predictions
    process(reset, PF_pc, DI_bra, DI_adr, EX_adr, EX_adresse, EX_bra_confirm, pred_tab)
        
        variable index  : integer range 0 to nb_record; -- Table index if a code_adr match with an instruction address
        variable index2 : integer range 0 to nb_record; -- Table index if a code_adr match with an instruction address
        variable index3 : integer range 0 to nb_record; -- Table index if a code_adr match with an instruction address

        variable bad_pred : std_logic; -- Flag of bad prediction
        
    begin
    
        -- Default signal affectations
        index := 0;
        index2 := 0;
        index3 := 0;
        pre_pred_tab <= pred_tab;      -- No modification in table of prediction by default
        PR_bra_cmd <= '0';
        PR_bra_bad <= '0';
        PR_bra_adr <= (others => '0');
        PR_clear <= '0';
        bad_pred := '0';
        add_record <= '0';

        -- Check a match in the table
        for i in 1 to nb_record loop
            if pred_tab(i).is_affected  = '1' then
                if PF_pc = pred_tab(i).code_adr then
                    index3 := i;
                end if;
                if DI_adr = pred_tab(i).code_adr then
                    index := i;
                end if;
                if EX_adr = pred_tab(i).code_adr then
                    index2 := i;
                end if;
            end if;
        end loop;
        
        -- Branch prediciton
        if index3 /= 0 then
            PR_bra_cmd <= '1';
            PR_bra_adr <= pred_tab(index3).bra_adr;
        end if;

        -- Check if the prediction is ok
        if EX_uncleared = '1' then
            if index2 /= 0 then
                if pred_tab(index2).last_bra /= EX_bra_confirm then -- Bad test result prediction
                    
                    if EX_bra_confirm = '1' then
                        pre_pred_tab(index2).last_bra <= '1';
                        pre_pred_tab(index2).bra_adr <= EX_adresse;
                    else
                        pre_pred_tab(index2).last_bra <= '0';
                        pre_pred_tab(index2).bra_adr <= std_logic_vector(unsigned(pred_tab(index2).code_adr)+4);
                    end if;
                    
                    bad_pred := '1';
                    
                elsif pred_tab(index2).bra_adr /= EX_adresse then  -- Bad adress result prediction
                    
                    pre_pred_tab(index2).bra_adr <= EX_adresse;
                    bad_pred := '1';
                    
                end if;
            end if;
        end if;

        -- Clear the pipeline and branch to the new instruction
        if bad_pred = '1' then
           PR_bra_bad <= '1';
           PR_bra_adr <= pre_pred_tab(index2).bra_adr;
           PR_clear <= '1';
        end if;
       
        -- Add a record in the table
        if DI_bra = '1' then
            if index = 0 then
                add_record <= '1';
                pre_pred_tab(next_out).is_affected <= '1';                               -- The record is affected
                pre_pred_tab(next_out).last_bra <= '0';                                  -- Can't predict the branch the first time
                pre_pred_tab(next_out).code_adr <= DI_adr;                               -- Save the branch address
                pre_pred_tab(next_out).bra_adr <= std_logic_vector(unsigned(DI_adr)+4);  -- Branch result
            end if;
        end if;
        
    end process;

    -- Update the table of prediction
    process(clock, reset)
    begin
        if reset = '1' then
        
            next_out <= 1;  -- At the beginning the first record must be chosen to be filled
        
            for i in 1 to nb_record loop
                pred_tab(i).is_affected <= '0';
            end loop;
            
        elsif rising_edge(clock) then
        
            pred_tab <= pre_pred_tab;
            
            if add_record = '1' then
                if next_out = nb_record then
                    next_out <= 1;
                else
                    next_out <= next_out+1; -- Next record to be erased
                end if;
            end if;
            
        end if;
    end process;
end rtl;

