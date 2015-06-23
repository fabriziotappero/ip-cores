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
--               miniMIPS Processor : Register bank                     --
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
use ieee.numeric_std.all;

library work;
use work.pack_mips.all;

entity banc is
port (
       clock : in bus1;
       reset : in bus1;

       -- Register addresses to read
       reg_src1 : in bus5;
       reg_src2 : in bus5;

       -- Register address to write and its data
       reg_dest : in bus5;
       donnee   : in bus32;

       -- Write signal
       cmd_ecr  : in bus1;

       -- Bank outputs
       data_src1 : out bus32;
       data_src2 : out bus32
     );
end banc;


architecture rtl of banc is

    -- The register bank
    type tab_reg is array (1 to 31) of bus32;
    signal registres : tab_reg;
    signal adr_src1 : integer range 0 to 31;
    signal adr_src2 : integer range 0 to 31;
    signal adr_dest : integer range 0 to 31;
begin

    adr_src1 <= to_integer(unsigned(reg_src1));
    adr_src2 <= to_integer(unsigned(reg_src2));
    adr_dest <= to_integer(unsigned(reg_dest));


    data_src1 <= (others => '0') when adr_src1=0 else
                 registres(adr_src1);
    data_src2 <= (others => '0') when adr_src2=0 else
                 registres(adr_src2);

    process(clock)
    begin
        if clock = '1' and clock'event then
            if reset='1' then
                for i in 1 to 31 loop
                    registres(i) <= (others => '0');
                end loop;
            elsif cmd_ecr = '1' and adr_dest /= 0 then
            -- The data is saved
                registres(adr_dest) <= donnee;
            end if;
        end if;
    end process;

end rtl;
