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

ARCHITECTURE spartan3 OF idreg_rom IS

BEGIN
   make_data : PROCESS( index )
   BEGIN
      CASE (index) IS
         WHEN "00000" => data <= X"00";
         WHEN "00001" => data <= X"00";
         WHEN "00010" => data <= X"00";
         WHEN "00011" => data <= X"00";
         WHEN "00100" => data <= X"00";
         WHEN "00101" => data <= X"00";
         WHEN "00110" => data <= X"00";
         WHEN "00111" => data <= X"00";
         WHEN "01000" => data <= X"02";
         WHEN "01001" => data <= X"C0";
         WHEN "01010" => data <= X"01";
         WHEN "01011" => data <= X"28";
         WHEN "01100" => data <= X"66";
         WHEN "01101" => data <= X"55";
         WHEN "01110" => data <= X"99";
         WHEN "01111" => data <= X"AA";
         WHEN OTHERS  => data <= X"FF";
      END CASE;
   END PROCESS make_data;
END spartan3;
