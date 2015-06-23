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
use ieee.std_logic_textio.all;
use std.textio.all;

library work;
use work.pack_mips.all;

entity rom is
   generic (mem_size : natural := 256; -- Size of the memory in words
            start : natural := 32768;
            latency : time := 0 ns);  
   port(
       adr : in bus32;
       donnee : out bus32;
       ack : out std_logic;
       load : in std_logic;
       fname : in string
   );
end;


architecture bench of rom is
    type storage_array is array(natural range start to start+4*mem_size - 1) of bus8;
    signal storage : storage_array := (others => (others => '0'));    -- The memory
    signal adresse : bus16;
    signal taille : bus16;
begin


    process (load)
        -- Variables for loading the memory
        -- The reading is done by blocks
        type bin is file of integer;                    -- Binary type file
        file load_file : bin;

        variable c : integer ;                          -- Integer (32 bits) read in the file
        variable index : integer range storage'range;   -- Index for loading
        variable word : bus32;                          -- Word read in the file
        variable taille_bloc : integer;                 -- Current size of the block to load
        variable tmp : bus16;
        variable status : file_open_status;

        variable s : line;
        variable big_endian : boolean := true;          -- Define if the processor (on which we work) is little or big endian
    begin

    if load='1' then

        -- Reading of the file de fill the memory at the defined address
        file_open(status, load_file, fname, read_mode);

        if status=open_ok then

            while not endfile(load_file) loop

                -- Read the header of the block
                read(load_file, c);                             -- Read a 32 bit long word
                word := bus32(to_unsigned(c, 32));              -- Conversion to a bit vector

                if big_endian then
                    tmp := word(7 downto 0) & word(15 downto 8);
                else
                    tmp := word(31 downto 16);
                end if;

                index := to_integer(unsigned(tmp));
                adresse <= tmp;

                if big_endian then
                    tmp := word(23 downto 16) & word(31 downto 24);
                else
                    tmp := word(15 downto 0);
                end if;


                taille_bloc := to_integer(unsigned(tmp)) / 4;
                taille <= tmp;

                -- Load the block in the ROM
                for n in 1 to taille_bloc loop

                    -- The header file is not correct (block too small, ROM to small ...)
                    -- The simulation is stopped
                    assert (not endfile(load_file) and (index<=storage'high))
                        report "L'image n'a pas le bon format ou ne rentre pas dans la rom."
                        severity error;

                    if not endfile(load_file) and (index<=storage'high) then
                        read(load_file, c);                  
                        word := bus32(to_unsigned(c, 32));  
                        if (c < 0) then
                          word := not(word);
                          word := std_logic_vector(unsigned(word)+1);
                        end if;
                        for i in 0 to 3 loop

                            if big_endian then
                                storage(index+i) <= word(8*(i+1)-1 downto 8*i);
                            else
                                storage(index+(3-i)) <= word(8*(i+1)-1 downto 8*i);
                            end if;

                        end loop;
                        index := index + 4;
                    end if;
                end loop;

            end loop;

            file_close(load_file);

        else
            assert false
                report "Impossible d'ouvrir le fichier specifie."
                severity error;

        end if;

    end if;

    end process;




    process(adr) -- Request for reading the ROM
        variable inadr : integer;
        variable i : natural;
    begin
            inadr := to_integer(unsigned(adr));

            if (inadr>=storage'low) and (inadr<=storage'high) then
                for i in 0 to 3 loop
                    donnee(8*(i+1)-1 downto 8*i) <= storage(inadr+3-i) after latency;
                end loop;
                ack <= '0', '1' after latency;
            else
                donnee <= (others => 'Z');
                ack <= 'L';
            end if;
    end process;

end bench;



