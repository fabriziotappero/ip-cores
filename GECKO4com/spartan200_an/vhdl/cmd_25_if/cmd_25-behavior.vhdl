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

ARCHITECTURE no_platform_specific OF identify_handler IS

   SIGNAL s_real_start     : std_logic;
   SIGNAL s_active_reg     : std_logic;
   SIGNAL s_down_count_reg : std_logic_vector( 5 DOWNTO 0 );
   SIGNAL s_shift_tick     : std_logic;
   SIGNAL s_shift_dir_reg  : std_logic;
   SIGNAL s_shift_a_reg    : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_shift_k_reg    : std_logic_vector( 8 DOWNTO 0 );
   SIGNAL s_stop           : std_logic;

BEGIN
   -- Assign outputs
   done   <= s_stop;
   leds_a <= X"80" WHEN flash_idle = '0' ELSE
             s_shift_a_reg WHEN s_active_reg = '1' ELSE leds_a_in;
   leds_k <= (OTHERS => '0') WHEN flash_idle = '0' ELSE
             s_shift_k_reg(8 DOWNTO 1) WHEN s_active_reg = '1' ELSE leds_k_in;
   
   -- Assign control signals
   s_real_start <= '1' WHEN (start = '1' AND command = "0100101") OR
                            indicator = '1' ELSE '0';
   s_shift_tick <= '1' WHEN msec_tick = '1' AND
                            s_down_count_reg = "000000" ELSE '0';
   s_stop       <= '1' WHEN s_shift_tick = '1' AND
                            s_shift_k_reg(1) = '0' AND
                            s_shift_k_reg(0) = '1' ELSE '0';
   
   -- make processes
   make_active_reg : PROCESS( clock , reset , s_real_start , s_stop )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             s_stop = '1') THEN s_active_reg <= '0';
         ELSIF (s_real_start = '1') THEN s_active_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_active_reg;
   
   make_shift_dir_reg : PROCESS( clock , s_active_reg , s_shift_a_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_active_reg = '0') THEN s_shift_dir_reg <= '1';
         ELSIF (s_shift_a_reg(7) = '1') THEN s_shift_dir_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_shift_dir_reg;
   
   make_shift_a_reg : PROCESS( clock , s_active_reg , s_shift_dir_reg ,
                               s_shift_tick )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_active_reg = '0') THEN s_shift_a_reg <= (OTHERS => '0');
         ELSIF (s_shift_tick = '1') THEN
            IF (s_shift_dir_reg = '1') THEN 
               s_shift_a_reg <= s_shift_a_reg(6 DOWNTO 0)&'1';
                                       ELSE
               s_shift_a_reg <= '0'&s_shift_a_reg(7 DOWNTO 1);
            END IF;
         END IF;
      END IF;
   END PROCESS make_shift_a_reg;
   
   make_shift_k_reg : PROCESS( clock , s_active_reg , s_shift_dir_reg ,
                               s_shift_tick , s_shift_a_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_active_reg = '0') THEN s_shift_k_reg <= (OTHERS => '0');
         ELSIF (s_shift_tick = '1' AND s_shift_dir_reg = '0') THEN
            s_shift_k_reg <= s_shift_a_reg(0)&s_shift_k_reg(8 DOWNTO 1);
         END IF;
      END IF;
   END PROCESS make_shift_k_reg;
   
   make_down_count_reg : PROCESS( clock , reset , s_active_reg ,
                                  msec_tick , s_shift_tick )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_shift_tick = '1' OR
             (s_active_reg = '0' AND
              flash_idle = '1') OR
             reset = '1') THEN s_down_count_reg <= "100111";
         ELSIF (msec_tick = '1') THEN
            s_down_count_reg <= unsigned(s_down_count_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_down_count_reg;
   
END no_platform_specific;
