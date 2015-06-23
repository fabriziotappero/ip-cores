--------------------------------------------------------------------------------
--            _   _            __   ____                                      --
--           / / | |          / _| |  __|                                     --
--           | |_| |  _   _  / /   | |_                                       --
--           |  _  | | | | | | |   |  _|                                      --
--           | | | | | |_| | \ \_  | |__                                      --
--           |_| |_| \_____|  \__| |____| microLab                            --
--                                                                            --
--           Bern University of Applied Sciences (BFH)                        --
--           Quellgasse 21                                                    --
--           Room HG 4.33                                                     --
--           2501 Biel/Bienne                                                 --
--           Switzerland                                                      --
--                                                                            --
--           http://www.microlab.ch                                           --
--------------------------------------------------------------------------------
--   GECKO4com
--  
--   2010/2011 Dr. Theo Kluter
--  
--   This VHDL code is free code: you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation, either version 3 of the License, or
--   (at your option) any later version.
--  
--   This VHDL code is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU General Public License for more details. 
--   You should have received a copy of the GNU General Public License
--   along with these sources.  If not, see <http://www.gnu.org/licenses/>.
--

ARCHITECTURE no_target_specific OF IDN_handler IS

   SIGNAL s_rom_index : std_logic_vector( 5 DOWNTO 0 );
   SIGNAL s_done      : std_logic;
   SIGNAL s_push      : std_logic;
   SIGNAL s_start     : std_logic;

BEGIN
   done     <= s_done;
   push     <= s_push;
   size_bit <= '1' WHEN s_rom_index = "000000" ELSE '0';

   s_done  <= '1' WHEN s_rom_index = "011110" AND fifo_full = '0' ELSE '0';
   s_push  <= '1' WHEN s_rom_index(5) = '0' AND fifo_full = '0' ELSE '0';
   s_start <= '1' WHEN command = "0001001" AND
                       start = '1' ELSE '0';

   make_rom_index : PROCESS( clock , s_start , reset , s_done ,
                             s_push )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR s_done = '1') THEN 
            s_rom_index <= (OTHERS => '1');
         ELSIF (s_start = '1') THEN
            s_rom_index <= (OTHERS => '0');
         ELSIF (s_rom_index(5) = '0' AND
                 s_push = '1') THEN 
            s_rom_index <= unsigned(s_rom_index) + 1;
         END IF;
      END IF;
   END PROCESS make_rom_index;

   make_rom_data : PROCESS( s_rom_index )
   BEGIN
      CASE (s_rom_index) IS
         WHEN "011110" => push_data <= X"0A";
         WHEN "011101" => push_data <= X"39";
         WHEN "011100" => push_data <= X"2E";
         WHEN "011011" => push_data <= X"30";
         WHEN "011010" => push_data <= X"2C";
         WHEN "011001" => push_data <= X"30";
         WHEN "011000" => push_data <= X"2C";
         WHEN "010111" => push_data <= X"4D";
         WHEN "010110" => push_data <= X"4F";
         WHEN "010101" => push_data <= X"43";
         WHEN "010100" => push_data <= X"34";
         WHEN "010011" => push_data <= X"4F";
         WHEN "010010" => push_data <= X"4B";
         WHEN "010001" => push_data <= X"43";
         WHEN "010000" => push_data <= X"45";
         WHEN "001111" => push_data <= X"47";
         WHEN "001110" => push_data <= X"2C";
         WHEN "001101" => push_data <= X"62";
         WHEN "001100" => push_data <= X"61";
         WHEN "001011" => push_data <= X"4C";
         WHEN "001010" => push_data <= X"6F";
         WHEN "001001" => push_data <= X"72";
         WHEN "001000" => push_data <= X"63";
         WHEN "000111" => push_data <= X"69";
         WHEN "000110" => push_data <= X"6D";
         WHEN "000101" => push_data <= X"2D";
         WHEN "000100" => push_data <= X"45";
         WHEN "000011" => push_data <= X"43";
         WHEN "000010" => push_data <= X"55";
         WHEN "000001" => push_data <= X"48";
         WHEN "000000" => push_data <= X"1E";
         WHEN OTHERS   => push_data <= X"00";
      END CASE;
   END PROCESS make_rom_data;
END no_target_specific;
