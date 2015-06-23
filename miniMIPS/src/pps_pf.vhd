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
--            miniMIPS Processor : Address calculation stage            --
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

entity pps_pf is
port (
    clock       : in bus1;
    reset       : in bus1;
    stop_all    : in bus1;   			-- Unconditionnal locking of the pipeline stage

    -- Asynchronous inputs
    bra_cmd     : in bus1;   			-- Branch
    bra_cmd_pr  : in bus1;        -- Branch which have a priority on stop_pf (bad prediction branch)
    bra_adr     : in bus32;       -- Address to load when an effective branch
    exch_cmd    : in bus1;   			-- Exception branch
    exch_adr    : in bus32;       -- Exception vector
    stop_pf     : in bus1;   			-- Lock the stage

    -- Synchronous output to EI stage
    PF_pc       : out bus32       -- PC value
);
end pps_pf;

architecture rtl of pps_pf is

    signal suivant : bus32;       -- Preparation of the future pc
    signal pc_interne : bus32;    -- Value of the pc output, needed for an internal reading
    signal lock : bus1;       		-- Specify the authorization of the pc evolution

begin

    -- Connexion the pc to the internal pc
    PF_pc <= pc_interne;

    -- Elaboration of an potential future pc
    suivant <= exch_adr when exch_cmd='1'   else
               bra_adr  when bra_cmd_pr='1' else
               bra_adr  when bra_cmd='1'    else
               bus32(unsigned(pc_interne) + 4);

    lock <= '1' when stop_all='1' else -- Lock this stage when all the pipeline is locked
            '0' when exch_cmd='1' else -- Exception
            '0' when bra_cmd_pr='1' else -- Bad prediction restoration
            '1' when stop_pf='1'  else -- Wait for the data hazard
            '0' when bra_cmd='1'  else -- Branch
            '0';                       -- Normal evolution

    -- Synchronous evolution of the pc
    process(clock)
    begin
        if clock='1' and clock'event then
            if reset='1' then
                -- PC reinitialisation with the boot address
                pc_interne <= ADR_INIT;
            elsif lock='0' then
                -- PC not locked
                pc_interne <= suivant;
            end if;
        end if;
    end process;

end rtl;
