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

ARCHITECTURE no_platform_specific OF DFF IS

BEGIN
   make_ff : PROCESS( clock , D )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         Q <= D;
      END IF;
   END PROCESS make_ff;
END no_platform_specific;

ARCHITECTURE no_platform_specific OF DFF_E IS

BEGIN
   make_ff : PROCESS( clock , D , enable )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (enable = '1') THEN Q <= D;
	 END IF;
      END IF;
   END PROCESS make_ff;
END no_platform_specific;

ARCHITECTURE no_platform_specific OF DFF_AR IS

BEGIN
   make_ff : PROCESS( clock , D , reset )
   BEGIN
      IF (reset = '1') THEN Q <= '0'; 
      ELSIF (clock'event AND (clock = '1')) THEN
         Q <= D;
      END IF;
   END PROCESS make_ff;
END no_platform_specific;

ARCHITECTURE no_platform_specific OF DFF_BUS IS

BEGIN
   make_ff : PROCESS( clock , D )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         Q <= D;
      END IF;
   END PROCESS make_ff;
END no_platform_specific;

ARCHITECTURE no_platform_specific OF DFF_E_BUS IS

BEGIN
   make_ff : PROCESS( clock , D , enable )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (enable = '1') THEN Q <= D;
	 END IF;
      END IF;
   END PROCESS make_ff;
END no_platform_specific;

