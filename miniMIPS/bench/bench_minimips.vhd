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


library IEEE;
use IEEE.std_logic_1164.all;

library std;
use std.textio.all;

library work;
use work.pack_mips.all;

entity sim_minimips is
end;

architecture bench of sim_minimips is

  component minimips is 
  port (
      clock    : in std_logic;
      reset    : in std_logic;
  
      ram_req  : out std_logic;
      ram_adr  : out bus32;
      ram_r_w  : out std_logic;
      ram_data : inout bus32;
      ram_ack  : in std_logic;
  
      it_mat   : in std_logic
  );
  end component;
  

  component ram is
    generic (mem_size : natural := 256;
             latency : time := 10 ns);
    port(
        req        : in std_logic;
        adr        : in bus32;
        data_inout : inout bus32;
        r_w        : in std_logic;
        ready      : out std_logic
  );
  end component;

  component rom is
  generic (mem_size : natural := 256;
           start : natural := 0;
           latency : time := 10 ns);
  port(
          adr : in bus32;
          donnee : out bus32;
          ack : out std_logic;
          load : in std_logic;
          fname : in string
  );
  end component;
  
  signal clock : std_logic := '0';
  signal reset : std_logic;

  signal it_mat : std_logic := '0';

  -- Connexion with the code memory
  signal load : std_logic;
  signal fichier : string(1 to 7);

  -- Connexion with the Ram
  signal ram_req : std_logic;
  signal ram_adr : bus32;
  signal ram_r_w : std_logic;
  signal ram_data : bus32;
  signal ram_rdy : std_logic;

begin

    U_minimips : minimips port map (
        clock => clock,
        reset => reset,
        ram_req => ram_req,
        ram_adr => ram_adr,
        ram_r_w => ram_r_w,
        ram_data => ram_data,
        ram_ack => ram_rdy,
        it_mat => it_mat
    );

    U_ram : ram port map (
        req => ram_req,
        adr => ram_adr,
        data_inout => ram_data,
        r_w => ram_r_w,
        ready => ram_rdy
    );

    U_rom : rom port map (
        adr => ram_adr,
        donnee => ram_data,
        ack => ram_rdy,
        load => load,
        fname => fichier
    );

    clock <= not clock after 20 ns;
    reset <= '0', '1' after 5 ns, '0' after 70 ns;
    ram_data <= (others => 'L');

    process
        variable command : line;
        variable nomfichier : string(1 to 3);
    begin
        write (output, "Enter the filename : ");
        readline(input, command);
        read(command, nomfichier);

        fichier <= nomfichier & ".bin";

        load <= '1';
        wait;
    end process;

    -- Memory Mapping
    -- 0000 - 00FF      ROM

    process (ram_adr, ram_r_w, ram_data)
    begin -- Emulation of an I/O controller
        ram_data <= (others => 'Z');

        case ram_adr is
            when X"00001000" => -- program an interrupt after 1000ns
                                it_mat <= '1' after 1000 ns;
                                ram_rdy <= '1' after 5 ns;
            when X"00001001" => -- clear interrupt line on cpu
                                it_mat <= '0';
                                ram_data <= X"FFFFFFFF";
                                ram_rdy <= '1' after 5 ns;
            when others      => ram_rdy <= 'L';
        end case;
    end process;

end bench;



