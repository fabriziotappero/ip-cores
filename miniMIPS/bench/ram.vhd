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



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pack_mips.all;

entity ram is
   generic (mem_size : natural := 256;  -- Size of the memory in words
            latency : time := 0 ns);
   port(
       req         : in std_logic;
       adr         : in bus32;
       data_inout  : inout bus32;
       r_w         : in std_logic;
       ready       : out std_logic
   );
end;


architecture bench of ram is
    type storage_array is array(natural range 1024 to 1024+4*mem_size - 1) of bus8;
    signal storage : storage_array; -- The memory
begin


    process(adr, data_inout, r_w)
        variable inadr : integer;
        variable i : natural;
    begin
        inadr := to_integer(unsigned(adr));

        if (inadr>=storage'low) and (inadr<=storage'high) then
            
            ready <= '0', '1' after latency;
            if req = '1' then    
                if r_w /= '1' then  -- Reading in memory
                    for i in 0 to 3 loop
                        data_inout(8*(i+1)-1 downto 8*i) <= storage(inadr+(3-i)) after latency;
                    end loop;
                else
                    for i in 0 to 3 loop
                        storage(inadr+(3-i)) <= data_inout(8*(i+1)-1 downto 8*i) after latency;
                    end loop;
                    data_inout <= (others => 'Z');
                end if;
            else
                data_inout <= (others => 'Z');
            end if;
        else
            data_inout <= (others => 'Z');
            ready <= 'L';
        end if;
    end process;

end bench;
