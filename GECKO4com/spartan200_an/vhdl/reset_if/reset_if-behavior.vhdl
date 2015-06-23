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

ARCHITECTURE no_target_specific OF reset_if IS

   SIGNAL s_reset_count_reg : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_user_count_reg  : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_done_pending_reg: std_logic;

BEGIN
   n_reset_system <= '0' WHEN s_reset_count_reg(4) = '0' ELSE 'Z';
   user_n_reset   <= '0' WHEN s_user_count_reg(4) = '0' ELSE '1';
   command_done   <= '1' WHEN (s_done_pending_reg = '1' AND 
                               s_reset_count_reg(4) = '1' AND
                               s_user_count_reg(4) = '1') OR
                              (start_command = '1' AND
                               (command_id = "0001111" OR
                                command_id = "0111010") AND
                               fpga_configured = '0') ELSE '0';

--------------------------------------------------------------------------------
--- Here the reset counter is defined                                        ---
--------------------------------------------------------------------------------
   make_reset_count_reg : PROCESS( clock , reset , start_command , command_id ,
                                   fpga_configured )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF ((start_command = '1' AND
              command_id = "0001111") OR
             fpga_configured = '0' OR
             reset = '1') THEN s_reset_count_reg <= "0"&X"A";
         ELSIF (msec_tick = '1' AND
                s_reset_count_reg(4) = '0') THEN
            s_reset_count_reg <= unsigned(s_reset_count_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_reset_count_reg;
   
   make_user_count_reg : PROCESS( clock , reset , start_command , command_id ,
                                  fpga_configured )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF ((start_command = '1' AND
              command_id = "0111010") OR
             fpga_configured = '0' OR
             reset = '1') THEN s_user_count_reg <= "0"&X"A";
         ELSIF (msec_tick = '1' AND
                s_user_count_reg(4) = '0') THEN
            s_user_count_reg <= unsigned(s_user_count_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_user_count_reg;
   
   make_done_pending_reg : PROCESS( clock , reset , start_command , command_id ,
                                    s_reset_count_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (start_command = '1' AND
             (command_id = "0001111" OR
              command_id = "0111010") AND
             fpga_configured = '1') THEN s_done_pending_reg <= '1';
         ELSIF (reset = '1' OR
                (s_reset_count_reg(4) = '1' AND
                 s_user_count_reg(4) = '1')) THEN s_done_pending_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_done_pending_reg;
   
END no_target_specific;
