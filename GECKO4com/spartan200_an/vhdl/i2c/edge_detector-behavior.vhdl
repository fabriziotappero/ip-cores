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

ARCHITECTURE no_platform_specific OF edge_detector IS

   SIGNAL s_pipe_regs : std_logic_vector( 3 DOWNTO 0 );

BEGIN

   make_pipe_regs : PROCESS( clock , reset , data_in )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_pipe_regs <= (OTHERS => '1');
                          ELSE
            s_pipe_regs <= s_pipe_regs( 2 DOWNTO 0 )& data_in;
         END IF;
      END IF;
   END PROCESS make_pipe_regs;
   
   make_output_regs : PROCESS( clock , reset , s_pipe_regs )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN data_out <= '1';
                               pos_edge <= '0';
                               neg_edge <= '0';
                          ELSE data_out <= s_pipe_regs(1);
                               pos_edge <= NOT(s_pipe_regs(3)) AND
                                           NOT(s_pipe_regs(2)) AND
                                           s_pipe_regs(1) AND
                                           s_pipe_regs(0);
                               neg_edge <= NOT(s_pipe_regs(0)) AND
                                           NOT(s_pipe_regs(1)) AND
                                           s_pipe_regs(2) AND
                                           s_pipe_regs(3);
         END IF;
      END IF;
   END PROCESS make_output_regs;
END no_platform_specific;
