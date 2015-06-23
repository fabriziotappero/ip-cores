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

ARCHITECTURE no_platform_specific OF hexswitch IS

   TYPE HEX_STATE_TYPE IS ( IDLE , SEND_SIZE , SEND_VALUE , SEND_END , GET_VALUE ,
                            SIGNAL_DONE , SIGNAL_ERROR );

   SIGNAL s_override_reg      : std_logic;
   SIGNAL s_hexswitch_reg     : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_hex_state_reg     : HEX_STATE_TYPE;
   SIGNAL s_push              : std_logic;
   SIGNAL s_fetched_value     : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_pop               : std_logic;
   SIGNAL s_update            : std_logic;

BEGIN
--------------------------------------------------------------------------------
--- Here the outputs are defined                                             ---
--------------------------------------------------------------------------------
   hex_value     <= s_hexswitch_reg;
   done          <= '1' WHEN s_hex_state_reg = SIGNAL_DONE ELSE '0';
   command_error <= '1' WHEN s_hex_state_reg = SIGNAL_ERROR ELSE '0';
   push_size     <= '1' WHEN s_hex_state_reg = SEND_SIZE ELSE '0';
   push          <= s_push;
   pop           <= s_pop;
   
   make_push_data : PROCESS( s_hex_state_reg , s_hexswitch_reg )
   BEGIN
      CASE (s_hex_state_reg) IS
         WHEN SEND_SIZE    => push_data <= X"02";
         WHEN SEND_VALUE   => CASE (s_hexswitch_reg) IS
                                 WHEN  X"0"  => push_data <= X"30";
                                 WHEN  X"1"  => push_data <= X"31";
                                 WHEN  X"2"  => push_data <= X"32";
                                 WHEN  X"3"  => push_data <= X"33";
                                 WHEN  X"4"  => push_data <= X"34";
                                 WHEN  X"5"  => push_data <= X"35";
                                 WHEN  X"6"  => push_data <= X"36";
                                 WHEN  X"7"  => push_data <= X"37";
                                 WHEN  X"8"  => push_data <= X"38";
                                 WHEN  X"9"  => push_data <= X"39";
                                 WHEN  X"A"  => push_data <= X"41";
                                 WHEN  X"B"  => push_data <= X"42";
                                 WHEN  X"C"  => push_data <= X"43";
                                 WHEN  X"D"  => push_data <= X"44";
                                 WHEN  X"E"  => push_data <= X"45";
                                 WHEN OTHERS => push_data <= X"46";
                              END CASE;
         WHEN SEND_END     => push_data <= X"0A";
         WHEN OTHERS       => push_data <= X"00";
      END CASE;
   END PROCESS make_push_data;
   
--------------------------------------------------------------------------------
--- Here the control signals are defined                                     ---
--------------------------------------------------------------------------------
   s_push    <= '1' WHEN push_full = '0' AND
                         (s_hex_state_reg = SEND_SIZE OR
                          s_hex_state_reg = SEND_VALUE OR
                          s_hex_state_reg = SEND_END) ELSE '0';
   s_pop     <= '1' WHEN pop_empty = '0' AND
                         s_hex_state_reg = GET_VALUE ELSE '0';
   s_update  <= s_pop AND s_fetched_value(4);
                          
   make_fetched_value : PROCESS( pop_data )
   BEGIN
      CASE (pop_data) IS
         WHEN  X"30"  => s_fetched_value <= "1"&X"0";
         WHEN  X"31"  => s_fetched_value <= "1"&X"1";
         WHEN  X"32"  => s_fetched_value <= "1"&X"2";
         WHEN  X"33"  => s_fetched_value <= "1"&X"3";
         WHEN  X"34"  => s_fetched_value <= "1"&X"4";
         WHEN  X"35"  => s_fetched_value <= "1"&X"5";
         WHEN  X"36"  => s_fetched_value <= "1"&X"6";
         WHEN  X"37"  => s_fetched_value <= "1"&X"7";
         WHEN  X"38"  => s_fetched_value <= "1"&X"8";
         WHEN  X"39"  => s_fetched_value <= "1"&X"9";
         WHEN  X"41"  => s_fetched_value <= "1"&X"A";
         WHEN  X"42"  => s_fetched_value <= "1"&X"B";
         WHEN  X"43"  => s_fetched_value <= "1"&X"C";
         WHEN  X"44"  => s_fetched_value <= "1"&X"D";
         WHEN  X"45"  => s_fetched_value <= "1"&X"E";
         WHEN  X"46"  => s_fetched_value <= "1"&X"F";
         WHEN  X"61"  => s_fetched_value <= "1"&X"A";
         WHEN  X"62"  => s_fetched_value <= "1"&X"B";
         WHEN  X"63"  => s_fetched_value <= "1"&X"C";
         WHEN  X"64"  => s_fetched_value <= "1"&X"D";
         WHEN  X"65"  => s_fetched_value <= "1"&X"E";
         WHEN  X"66"  => s_fetched_value <= "1"&X"F";
         WHEN OTHERS  => s_fetched_value <= "0"&X"0";
      END CASE;
   END PROCESS make_fetched_value;
   
--------------------------------------------------------------------------------
--- Here the state machine is defined                                        ---
--------------------------------------------------------------------------------
   make_state_machine : PROCESS( clock , reset , s_hex_state_reg , start ,
                                 command , s_push )
      VARIABLE v_next_state : HEX_STATE_TYPE;
   BEGIN
      CASE (s_hex_state_reg) IS
         WHEN IDLE                  => IF (start = '1') THEN
                                          CASE (command) IS
                                             WHEN "0100011" => v_next_state := GET_VALUE;
                                             WHEN "0100100" => v_next_state := SEND_SIZE;
                                             WHEN OTHERS    => v_next_state := IDLE;
                                          END CASE;
                                                        ELSE
                                          v_next_state := IDLE;
                                       END IF;
         WHEN SEND_SIZE             => IF (s_push = '1') THEN 
                                          v_next_state := SEND_VALUE;
                                                         ELSE
                                          v_next_state := SEND_SIZE;
                                       END IF;
         WHEN SEND_VALUE            => IF (s_push = '1') THEN 
                                          v_next_state := SEND_END;
                                                         ELSE
                                          v_next_state := SEND_VALUE;
                                       END IF;
         WHEN SEND_END              => IF (s_push = '1') THEN 
                                          v_next_state := SIGNAL_DONE;
                                                         ELSE
                                          v_next_state := SEND_END;
                                       END IF;
         WHEN GET_VALUE             => IF (s_pop = '1') THEN
                                          IF (s_fetched_value(4) = '1') THEN
                                             v_next_state := SIGNAL_DONE;
                                          ELSIF (pop_data = X"20" AND
                                                 pop_last = '0') THEN
                                             v_next_state := GET_VALUE;
                                                                 ELSE
                                             v_next_state := SIGNAL_ERROR;
                                          END IF;
                                                        ELSE
                                          v_next_state := GET_VALUE;
                                       END IF;
         WHEN OTHERS                => v_next_state := IDLE;
      END CASE;
      IF (clock'event AND (clock = '1')) THEN 
         IF (reset = '1') THEN s_hex_state_reg <= IDLE;
                          ELSE s_hex_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_state_machine;

--------------------------------------------------------------------------------
--- Here the base registers are defined                                      ---
--------------------------------------------------------------------------------
   make_override_reg : PROCESS( clock , reset )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_override_reg <= '0';
         ELSIF (s_update = '1') THEN s_override_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_override_reg;
   
   make_hexswitch_reg : PROCESS( clock , s_override_reg , n_hex_sw )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_update = '1') THEN 
            s_hexswitch_reg <= s_fetched_value( 3 DOWNTO 0 );
         ELSIF (s_override_reg = '0') THEN s_hexswitch_reg <= NOT(n_hex_sw);
         END IF;
      END IF;
   END PROCESS make_hexswitch_reg;
END no_platform_specific;
