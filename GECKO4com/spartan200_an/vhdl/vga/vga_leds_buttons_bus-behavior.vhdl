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

ARCHITECTURE no_target_specific OF vga_bus IS
   TYPE VGA_STATE_TYPE IS (IDLE , INIT_CLEAR_SCREEN , CLEAR_SCREEN ,
                           INIT_CLEAR_LINE );

   SIGNAL s_led_0_mode_reg            : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_led_1_mode_reg            : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_led_2_mode_reg            : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_led_3_mode_reg            : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_led_4_mode_reg            : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_led_5_mode_reg            : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_led_6_mode_reg            : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_led_7_mode_reg            : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_led_delay_cnt_reg         : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_led_blink_cnt_reg         : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_my_write_burst_active_reg : std_logic;
   SIGNAL s_n_bus_error_reg           : std_logic;
   SIGNAL s_n_bus_error_next          : std_logic;
   SIGNAL s_n_data_valid_reg          : std_logic;
   SIGNAL s_fg_color_reg              : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_bg_color_reg              : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_cursor_x_pos_reg          : std_logic_vector( 5 DOWNTO 0 );
   SIGNAL s_cursor_y_pos_reg          : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_screen_offset_reg         : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_clear_screen_cnt_reg      : std_logic_vector(11 DOWNTO 0 );
   SIGNAL s_vga_state_reg             : VGA_STATE_TYPE;
   SIGNAL s_we_ascii                  : std_logic;
   SIGNAL s_next_x_pos                : std_logic_vector( 6 DOWNTO 0 );
   SIGNAL s_next_y_pos                : std_logic_vector( 5 DOWNTO 0 );
   SIGNAL s_write_pending_reg         : std_logic;

BEGIN
--------------------------------------------------------------------------------
--- Here the outputs are defined                                             ---
--------------------------------------------------------------------------------
   n_start_send               <= '0' WHEN (n_start_transmission = '0' AND
                                           bus_address(5 DOWNTO 4) = "10" AND
                                           read_n_write = '0' AND
                                           s_n_bus_error_next = '1' AND
                                           s_vga_state_reg = IDLE) OR
                                          (s_write_pending_reg = '1' AND
                                           s_vga_state_reg = IDLE) ELSE '1';
   n_bus_error                <= s_n_bus_error_reg;
   n_end_transmission_out     <= '0' WHEN s_n_bus_error_reg = '0' OR
                                          s_n_data_valid_reg = '0' ELSE '1';
   n_data_valid_out           <= "1"&s_n_data_valid_reg;
   fg_color                   <= s_fg_color_reg;
   bg_color                   <= s_bg_color_reg;
   cursor_pos                 <= s_cursor_y_pos_reg&s_cursor_x_pos_reg;
   write_address(5 DOWNTO 0)  <= unsigned(s_cursor_x_pos_reg)+ 
                                 unsigned(s_clear_screen_cnt_reg( 5 DOWNTO 0 ));
   write_address(10 DOWNTO 6) <= unsigned(s_screen_offset_reg) +
                                 unsigned(s_cursor_y_pos_reg) +
                                 unsigned(s_clear_screen_cnt_reg(10 DOWNTO 6));
   screen_offset              <= s_screen_offset_reg;
   ascii_data                 <= data_in WHEN s_clear_screen_cnt_reg(11) = '1' ELSE X"20";
   we                         <= '1' WHEN s_clear_screen_cnt_reg(11) = '0' OR
                                          (s_we_ascii = '1' AND
                                           data_in /= X"0A") ELSE '0';

--------------------------------------------------------------------------------
--- Here the data out is defined                                             ---
--------------------------------------------------------------------------------
   make_data_out : PROCESS( bus_address , n_button_1 , n_button_2 , n_button_3 ,
                            hexswitch , clock , s_fg_color_reg , s_bg_color_reg,
                            s_led_0_mode_reg , s_led_1_mode_reg , s_led_2_mode_reg ,
                            s_led_3_mode_reg , s_led_4_mode_reg , s_led_5_mode_reg ,
                            s_led_6_mode_reg , s_led_7_mode_reg ,
                            s_cursor_x_pos_reg , s_cursor_y_pos_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (bus_address(5 DOWNTO 4) = "10") THEN
            CASE (bus_address(3 DOWNTO 0)) IS
               WHEN  X"0"  => data_out <= X"000"&"0"&s_fg_color_reg;
               WHEN  X"1"  => data_out <= X"000"&"0"&s_bg_color_reg;
               WHEN  X"2"  => data_out <= X"00"&"00"&s_cursor_x_pos_reg;
               WHEN  X"3"  => data_out <= X"00"&"000"&s_cursor_y_pos_reg;
               WHEN  X"6"  => data_out(15 DOWNTO 3) <= (OTHERS => '0');
                              data_out(2) <= NOT(n_button_3);
                              data_out(1) <= NOT(n_button_2);
                              data_out(0) <= NOT(n_button_1);
               WHEN  X"7"  => data_out <= X"000"&hexswitch;
               WHEN  X"8"  => data_out <= X"000"&s_led_0_mode_reg;
               WHEN  X"9"  => data_out <= X"000"&s_led_1_mode_reg;
               WHEN  X"A"  => data_out <= X"000"&s_led_2_mode_reg;
               WHEN  X"B"  => data_out <= X"000"&s_led_3_mode_reg;
               WHEN  X"C"  => data_out <= X"000"&s_led_4_mode_reg;
               WHEN  X"D"  => data_out <= X"000"&s_led_5_mode_reg;
               WHEN  X"E"  => data_out <= X"000"&s_led_6_mode_reg;
               WHEN  X"F"  => data_out <= X"000"&s_led_7_mode_reg;
               WHEN OTHERS => data_out <= X"FFFF";
            END CASE;
                                             ELSE
            data_out <= X"0000";
         END IF;
      END IF;
   END PROCESS make_data_out;
   
--------------------------------------------------------------------------------
--- Here the bus control signals are defined                                 ---
--------------------------------------------------------------------------------
   s_n_bus_error_next <= '0' WHEN bus_address(5 DOWNTO 4) = "10" AND
                                  n_start_transmission = '0' AND
                                  (burst_size /= "000000000" OR
                                   (read_n_write = '1' AND              -- Write only regs
                                    (bus_address(3 DOWNTO 0) = X"4" OR
                                     bus_address(3 DOWNTO 0) = X"5")) OR
                                   (read_n_write = '0' AND              -- Read only regs
                                    (bus_address(3 DOWNTO 0) = X"6" OR
                                     bus_address(3 DOWNTO 0) = X"7"))) ELSE '1';

   make_my_write_burst_active_reg : PROCESS( clock , reset , bus_address ,
                                             n_start_transmission ,
                                             n_end_transmission_in ,
                                             n_bus_reset , s_n_bus_error_next )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (n_end_transmission_in = '0' OR
             reset = '1' OR
             n_bus_reset = '0') THEN s_my_write_burst_active_reg <= '0';
         ELSIF (n_start_transmission = '0' AND
                bus_address(5 DOWNTO 4) = "10" AND
                read_n_write = '0' AND
                s_n_bus_error_next = '1') THEN
            s_my_write_burst_active_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_my_write_burst_active_reg;
   
   
   make_n_bus_error_reg : PROCESS( clock , s_n_bus_error_next )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         s_n_bus_error_reg <= s_n_bus_error_next;
      END IF;
   END PROCESS make_n_bus_error_reg;
   
   make_n_data_valid_reg : PROCESS( clock , bus_address , n_start_transmission ,
                                    burst_size , read_n_write ,
                                    s_n_bus_error_next )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (bus_address(5 DOWNTO 4) = "10" AND
             n_start_transmission = '0' AND
             burst_size = "000000000") THEN 
                s_n_data_valid_reg <= NOT(read_n_write) OR NOT(s_n_bus_error_next);
                                       ELSE s_n_data_valid_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_n_data_valid_reg;

--------------------------------------------------------------------------------
--- Here the vga controller is defined                                       ---
--------------------------------------------------------------------------------
   s_we_ascii <= '1' WHEN n_data_valid_in = '0' AND
                          s_my_write_burst_active_reg = '1' AND
                          bus_address( 3 DOWNTO 0 ) = X"4" ELSE '0';
   s_next_x_pos <= "0"&s_cursor_x_pos_reg WHEN s_we_ascii = '0' ELSE
                   "1000000" WHEN data_in = X"0A" ELSE
                   unsigned("0"&s_cursor_x_pos_reg) + 1;
   s_next_y_pos <= unsigned("0"&s_cursor_y_pos_reg) + 1;

   make_write_pending_reg : PROCESS( clock , reset , n_end_transmission_in ,
                                     s_vga_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_vga_state_reg = IDLE OR
             n_end_transmission_in = '0' OR
             reset = '1') THEN s_write_pending_reg <= '0';
         ELSIF (n_start_transmission = '0' AND
                bus_address(5 DOWNTO 4) = "10" AND
                read_n_write = '0' AND
                s_n_bus_error_next = '1' AND
                s_vga_state_reg /= IDLE) THEN 
            s_write_pending_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_write_pending_reg;

   make_fg_color_reg : PROCESS( clock , reset , n_bus_reset , data_in ,
                                n_data_valid_in , s_my_write_burst_active_reg ,
                                bus_address )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (n_bus_reset = '0' OR
             reset = '1') THEN s_fg_color_reg <= "100";
         ELSIF (n_data_valid_in = '0' AND
                s_my_write_burst_active_reg = '1' AND
                bus_address( 3 DOWNTO 0 ) = X"0") THEN
            s_fg_color_reg <= data_in( 2 DOWNTO 0 );
         END IF;
      END IF;
   END PROCESS make_fg_color_reg;

   make_bg_color_reg : PROCESS( clock , reset , n_bus_reset , data_in ,
                                n_data_valid_in , s_my_write_burst_active_reg ,
                                bus_address )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (n_bus_reset = '0' OR
             reset = '1') THEN s_bg_color_reg <= "000";
         ELSIF (n_data_valid_in = '0' AND
                s_my_write_burst_active_reg = '1' AND
                bus_address( 3 DOWNTO 0 ) = X"1") THEN
            s_bg_color_reg <= data_in( 2 DOWNTO 0 );
         END IF;
      END IF;
   END PROCESS make_bg_color_reg;
   
   make_cursor_x_pos_reg : PROCESS( clock , reset , data_in , s_next_x_pos ,
                                    n_data_valid_in , s_my_write_burst_active_reg ,
                                    bus_address , s_vga_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_vga_state_reg = INIT_CLEAR_SCREEN OR
             reset = '1') THEN s_cursor_x_pos_reg <= (OTHERS => '0');
         ELSIF (n_data_valid_in = '0' AND
                s_my_write_burst_active_reg = '1' AND
                bus_address( 3 DOWNTO 0 ) = X"2") THEN
            s_cursor_x_pos_reg <= data_in( 5 DOWNTO 0 );
                                                  ELSE
            s_cursor_x_pos_reg <= s_next_x_pos( 5 DOWNTO 0 );
         END IF;
      END IF;
   END PROCESS make_cursor_x_pos_reg;

   make_cursor_y_pos_reg : PROCESS( clock , reset , data_in , s_vga_state_reg ,
                                    n_data_valid_in , s_my_write_burst_active_reg ,
                                    bus_address )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_vga_state_reg = INIT_CLEAR_SCREEN OR
             reset = '1') THEN s_cursor_y_pos_reg <= (OTHERS => '0');
         ELSIF (n_data_valid_in = '0' AND
                s_my_write_burst_active_reg = '1' AND
                bus_address( 3 DOWNTO 0 ) = X"3") THEN
            s_cursor_y_pos_reg <= data_in( 4 DOWNTO 0 );
         ELSIF (s_next_x_pos(6) = '1' AND
                s_next_y_pos(5) = '0') THEN
            s_cursor_y_pos_reg <= s_next_y_pos( 4 DOWNTO 0 );
         END IF;
      END IF;
   END PROCESS make_cursor_y_pos_reg;
   
   make_screen_offset_reg : PROCESS( clock , reset , s_vga_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_vga_state_reg = INIT_CLEAR_SCREEN OR
             reset = '1') THEN s_screen_offset_reg <= (OTHERS => '0');
         ELSIF (s_next_x_pos(6) = '1' AND
                s_next_y_pos(5) = '1') THEN
            s_screen_offset_reg <= unsigned(s_screen_offset_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_screen_offset_reg;
   
   make_clear_screen_cnt_reg : PROCESS( clock , reset , s_vga_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_vga_state_reg = INIT_CLEAR_SCREEN) THEN
            s_clear_screen_cnt_reg <= (11 => '0' , OTHERS => '1');
         ELSIF (s_vga_state_reg = INIT_CLEAR_LINE) THEN
            s_clear_screen_cnt_reg <= "000000111111";
         ELSIF (s_clear_screen_cnt_reg(11) = '1' OR
                reset = '1') THEN 
            s_clear_screen_cnt_reg <= "100000000000";
         ELSIF (s_clear_screen_cnt_reg(11) = '0') THEN
            s_clear_screen_cnt_reg <= unsigned(s_clear_screen_cnt_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_clear_screen_cnt_reg;
   
   make_vga_state_machine : PROCESS( clock , reset , s_vga_state_reg )
      VARIABLE v_next_state : VGA_STATE_TYPE;
   BEGIN
      CASE (s_vga_state_reg) IS
         WHEN IDLE               => IF (n_data_valid_in = '0' AND
                                        s_my_write_burst_active_reg = '1' AND
                                        bus_address(3 DOWNTO 0) = X"5") THEN
                                       v_next_state := INIT_CLEAR_SCREEN;
                                    ELSIF (s_next_x_pos(6) = '1' AND
                                           s_next_y_pos(5) = '1') THEN
                                       v_next_state := INIT_CLEAR_LINE;
                                                                        ELSE
                                       v_next_state := IDLE;
                                    END IF;
         WHEN INIT_CLEAR_SCREEN  => v_next_state := CLEAR_SCREEN;
         WHEN CLEAR_SCREEN       => IF (s_clear_screen_cnt_reg(11) = '1') THEN
                                       v_next_state := IDLE;
                                                                          ELSE
                                       v_next_state := CLEAR_SCREEN;
                                    END IF;
         WHEN INIT_CLEAR_LINE    => v_next_state := CLEAR_SCREEN;
         WHEN OTHERS             => v_next_state := IDLE;
      END CASE;
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_vga_state_reg <= IDLE;
                          ELSE s_vga_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_vga_state_machine;

--------------------------------------------------------------------------------
--- Here the led control is defined                                          ---
--------------------------------------------------------------------------------
   make_led_0_mode_reg : PROCESS( clock , reset , bus_address , data_in ,
                                  n_data_valid_in , s_my_write_burst_active_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             n_bus_reset = '0') THEN s_led_0_mode_reg <= X"0";
         ELSIF (n_data_valid_in = '0' AND
                bus_address( 3 DOWNTO 0) = X"8" AND
                s_my_write_burst_active_reg = '1') THEN
            s_led_0_mode_reg <= data_in(3 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS make_led_0_mode_reg;

   make_led_1_mode_reg : PROCESS( clock , reset , bus_address , data_in ,
                                  n_data_valid_in , s_my_write_burst_active_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             n_bus_reset = '0') THEN s_led_1_mode_reg <= X"0";
         ELSIF (n_data_valid_in = '0' AND
                bus_address( 3 DOWNTO 0) = X"9" AND
                s_my_write_burst_active_reg = '1') THEN
            s_led_1_mode_reg <= data_in(3 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS make_led_1_mode_reg;

   make_led_2_mode_reg : PROCESS( clock , reset , bus_address , data_in ,
                                  n_data_valid_in , s_my_write_burst_active_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             n_bus_reset = '0') THEN s_led_2_mode_reg <= X"0";
         ELSIF (n_data_valid_in = '0' AND
                bus_address( 3 DOWNTO 0) = X"A" AND
                s_my_write_burst_active_reg = '1') THEN
            s_led_2_mode_reg <= data_in(3 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS make_led_2_mode_reg;

   make_led_3_mode_reg : PROCESS( clock , reset , bus_address , data_in ,
                                  n_data_valid_in , s_my_write_burst_active_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             n_bus_reset = '0') THEN s_led_3_mode_reg <= X"0";
         ELSIF (n_data_valid_in = '0' AND
                bus_address( 3 DOWNTO 0) = X"B" AND
                s_my_write_burst_active_reg = '1') THEN
            s_led_3_mode_reg <= data_in(3 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS make_led_3_mode_reg;

   make_led_4_mode_reg : PROCESS( clock , reset , bus_address , data_in ,
                                  n_data_valid_in , s_my_write_burst_active_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             n_bus_reset = '0') THEN s_led_4_mode_reg <= X"0";
         ELSIF (n_data_valid_in = '0' AND
                bus_address( 3 DOWNTO 0) = X"C" AND
                s_my_write_burst_active_reg = '1') THEN
            s_led_4_mode_reg <= data_in(3 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS make_led_4_mode_reg;

   make_led_5_mode_reg : PROCESS( clock , reset , bus_address , data_in ,
                                  n_data_valid_in , s_my_write_burst_active_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             n_bus_reset = '0') THEN s_led_5_mode_reg <= X"0";
         ELSIF (n_data_valid_in = '0' AND
                bus_address( 3 DOWNTO 0) = X"D" AND
                s_my_write_burst_active_reg = '1') THEN
            s_led_5_mode_reg <= data_in(3 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS make_led_5_mode_reg;

   make_led_6_mode_reg : PROCESS( clock , reset , bus_address , data_in ,
                                  n_data_valid_in , s_my_write_burst_active_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             n_bus_reset = '0') THEN s_led_6_mode_reg <= X"0";
         ELSIF (n_data_valid_in = '0' AND
                bus_address( 3 DOWNTO 0) = X"E" AND
                s_my_write_burst_active_reg = '1') THEN
            s_led_6_mode_reg <= data_in(3 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS make_led_6_mode_reg;

   make_led_7_mode_reg : PROCESS( clock , reset , bus_address , data_in ,
                                  n_data_valid_in , s_my_write_burst_active_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             n_bus_reset = '0') THEN s_led_7_mode_reg <= X"0";
         ELSIF (n_data_valid_in = '0' AND
                bus_address( 3 DOWNTO 0) = X"F" AND
                s_my_write_burst_active_reg = '1') THEN
            s_led_7_mode_reg <= data_in(3 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS make_led_7_mode_reg;

   make_led_delay_cnt_reg : PROCESS( clock , reset , msec_tick )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF ((msec_tick = '1' AND
              s_led_delay_cnt_reg = X"00") OR
             reset = '1') THEN s_led_delay_cnt_reg <= X"7C";
         ELSIF (msec_tick = '1') THEN
            s_led_delay_cnt_reg <= unsigned(s_led_delay_cnt_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_led_delay_cnt_reg;
   
   make_led_blink_cnt_reg : PROCESS( clock , reset , msec_tick , 
                                     s_led_delay_cnt_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_led_blink_cnt_reg <= "000";
         ELSIF (msec_tick = '1' AND
                s_led_delay_cnt_reg = X"00") THEN
            s_led_blink_cnt_reg <= unsigned(s_led_blink_cnt_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_led_blink_cnt_reg;
   
   make_led_0 : PROCESS( s_led_0_mode_reg , s_led_blink_cnt_reg )
   BEGIN
      CASE (s_led_0_mode_reg) IS
         WHEN  X"2"  |
               X"A"  => leds_a(0) <= '0';
                        leds_k(0) <= '1';
         WHEN  X"3"  |
               X"B"  => leds_a(0) <= '1';
                        leds_k(0) <= '0';
         WHEN  X"4"  => leds_a(0) <= '0';
                        leds_k(0) <= s_led_blink_cnt_reg(2);
         WHEN  X"5"  => leds_a(0) <= s_led_blink_cnt_reg(2);
                        leds_k(0) <= '0';
         WHEN  X"6"  |
               X"7"  => leds_a(0) <= s_led_blink_cnt_reg(2);
                        leds_k(0) <= NOT(s_led_blink_cnt_reg(2));
         WHEN  X"C"  => leds_a(0) <= '0';
                        leds_k(0) <= s_led_blink_cnt_reg(0);
         WHEN  X"D"  => leds_a(0) <= s_led_blink_cnt_reg(0);
                        leds_k(0) <= '0';
         WHEN  X"E"  |
               X"F"  => leds_a(0) <= s_led_blink_cnt_reg(0);
                        leds_k(0) <= NOT(s_led_blink_cnt_reg(0));
         WHEN OTHERS => leds_a(0) <= '0';
                        leds_k(0) <= '0';
      END CASE;
   END PROCESS make_led_0;

   make_led_1 : PROCESS( s_led_1_mode_reg , s_led_blink_cnt_reg )
   BEGIN
      CASE (s_led_1_mode_reg) IS
         WHEN  X"2"  |
               X"A"  => leds_a(1) <= '0';
                        leds_k(1) <= '1';
         WHEN  X"3"  |
               X"B"  => leds_a(1) <= '1';
                        leds_k(1) <= '0';
         WHEN  X"4"  => leds_a(1) <= '0';
                        leds_k(1) <= s_led_blink_cnt_reg(2);
         WHEN  X"5"  => leds_a(1) <= s_led_blink_cnt_reg(2);
                        leds_k(1) <= '0';
         WHEN  X"6"  |
               X"7"  => leds_a(1) <= s_led_blink_cnt_reg(2);
                        leds_k(1) <= NOT(s_led_blink_cnt_reg(2));
         WHEN  X"C"  => leds_a(1) <= '0';
                        leds_k(1) <= s_led_blink_cnt_reg(0);
         WHEN  X"D"  => leds_a(1) <= s_led_blink_cnt_reg(0);
                        leds_k(1) <= '0';
         WHEN  X"E"  |
               X"F"  => leds_a(1) <= s_led_blink_cnt_reg(0);
                        leds_k(1) <= NOT(s_led_blink_cnt_reg(0));
         WHEN OTHERS => leds_a(1) <= '0';
                        leds_k(1) <= '0';
      END CASE;
   END PROCESS make_led_1;

   make_led_2 : PROCESS( s_led_2_mode_reg , s_led_blink_cnt_reg )
   BEGIN
      CASE (s_led_2_mode_reg) IS
         WHEN  X"2"  |
               X"A"  => leds_a(2) <= '0';
                        leds_k(2) <= '1';
         WHEN  X"3"  |
               X"B"  => leds_a(2) <= '1';
                        leds_k(2) <= '0';
         WHEN  X"4"  => leds_a(2) <= '0';
                        leds_k(2) <= s_led_blink_cnt_reg(2);
         WHEN  X"5"  => leds_a(2) <= s_led_blink_cnt_reg(2);
                        leds_k(2) <= '0';
         WHEN  X"6"  |
               X"7"  => leds_a(2) <= s_led_blink_cnt_reg(2);
                        leds_k(2) <= NOT(s_led_blink_cnt_reg(2));
         WHEN  X"C"  => leds_a(2) <= '0';
                        leds_k(2) <= s_led_blink_cnt_reg(0);
         WHEN  X"D"  => leds_a(2) <= s_led_blink_cnt_reg(0);
                        leds_k(2) <= '0';
         WHEN  X"E"  |
               X"F"  => leds_a(2) <= s_led_blink_cnt_reg(0);
                        leds_k(2) <= NOT(s_led_blink_cnt_reg(0));
         WHEN OTHERS => leds_a(2) <= '0';
                        leds_k(2) <= '0';
      END CASE;
   END PROCESS make_led_2;

   make_led_3 : PROCESS( s_led_3_mode_reg , s_led_blink_cnt_reg )
   BEGIN
      CASE (s_led_3_mode_reg) IS
         WHEN  X"2"  |
               X"A"  => leds_a(3) <= '0';
                        leds_k(3) <= '1';
         WHEN  X"3"  |
               X"B"  => leds_a(3) <= '1';
                        leds_k(3) <= '0';
         WHEN  X"4"  => leds_a(3) <= '0';
                        leds_k(3) <= s_led_blink_cnt_reg(2);
         WHEN  X"5"  => leds_a(3) <= s_led_blink_cnt_reg(2);
                        leds_k(3) <= '0';
         WHEN  X"6"  |
               X"7"  => leds_a(3) <= s_led_blink_cnt_reg(2);
                        leds_k(3) <= NOT(s_led_blink_cnt_reg(2));
         WHEN  X"C"  => leds_a(3) <= '0';
                        leds_k(3) <= s_led_blink_cnt_reg(0);
         WHEN  X"D"  => leds_a(3) <= s_led_blink_cnt_reg(0);
                        leds_k(3) <= '0';
         WHEN  X"E"  |
               X"F"  => leds_a(3) <= s_led_blink_cnt_reg(0);
                        leds_k(3) <= NOT(s_led_blink_cnt_reg(0));
         WHEN OTHERS => leds_a(3) <= '0';
                        leds_k(3) <= '0';
      END CASE;
   END PROCESS make_led_3;

   make_led_4 : PROCESS( s_led_4_mode_reg , s_led_blink_cnt_reg )
   BEGIN
      CASE (s_led_4_mode_reg) IS
         WHEN  X"2"  |
               X"A"  => leds_a(4) <= '0';
                        leds_k(4) <= '1';
         WHEN  X"3"  |
               X"B"  => leds_a(4) <= '1';
                        leds_k(4) <= '0';
         WHEN  X"4"  => leds_a(4) <= '0';
                        leds_k(4) <= s_led_blink_cnt_reg(2);
         WHEN  X"5"  => leds_a(4) <= s_led_blink_cnt_reg(2);
                        leds_k(4) <= '0';
         WHEN  X"6"  |
               X"7"  => leds_a(4) <= s_led_blink_cnt_reg(2);
                        leds_k(4) <= NOT(s_led_blink_cnt_reg(2));
         WHEN  X"C"  => leds_a(4) <= '0';
                        leds_k(4) <= s_led_blink_cnt_reg(0);
         WHEN  X"D"  => leds_a(4) <= s_led_blink_cnt_reg(0);
                        leds_k(4) <= '0';
         WHEN  X"E"  |
               X"F"  => leds_a(4) <= s_led_blink_cnt_reg(0);
                        leds_k(4) <= NOT(s_led_blink_cnt_reg(0));
         WHEN OTHERS => leds_a(4) <= '0';
                        leds_k(4) <= '0';
      END CASE;
   END PROCESS make_led_4;

   make_led_5 : PROCESS( s_led_5_mode_reg , s_led_blink_cnt_reg )
   BEGIN
      CASE (s_led_5_mode_reg) IS
         WHEN  X"2"  |
               X"A"  => leds_a(5) <= '0';
                        leds_k(5) <= '1';
         WHEN  X"3"  |
               X"B"  => leds_a(5) <= '1';
                        leds_k(5) <= '0';
         WHEN  X"4"  => leds_a(5) <= '0';
                        leds_k(5) <= s_led_blink_cnt_reg(2);
         WHEN  X"5"  => leds_a(5) <= s_led_blink_cnt_reg(2);
                        leds_k(5) <= '0';
         WHEN  X"6"  |
               X"7"  => leds_a(5) <= s_led_blink_cnt_reg(2);
                        leds_k(5) <= NOT(s_led_blink_cnt_reg(2));
         WHEN  X"C"  => leds_a(5) <= '0';
                        leds_k(5) <= s_led_blink_cnt_reg(0);
         WHEN  X"D"  => leds_a(5) <= s_led_blink_cnt_reg(0);
                        leds_k(5) <= '0';
         WHEN  X"E"  |
               X"F"  => leds_a(5) <= s_led_blink_cnt_reg(0);
                        leds_k(5) <= NOT(s_led_blink_cnt_reg(0));
         WHEN OTHERS => leds_a(5) <= '0';
                        leds_k(5) <= '0';
      END CASE;
   END PROCESS make_led_5;

   make_led_6 : PROCESS( s_led_6_mode_reg , s_led_blink_cnt_reg )
   BEGIN
      CASE (s_led_6_mode_reg) IS
         WHEN  X"2"  |
               X"A"  => leds_a(6) <= '0';
                        leds_k(6) <= '1';
         WHEN  X"3"  |
               X"B"  => leds_a(6) <= '1';
                        leds_k(6) <= '0';
         WHEN  X"4"  => leds_a(6) <= '0';
                        leds_k(6) <= s_led_blink_cnt_reg(2);
         WHEN  X"5"  => leds_a(6) <= s_led_blink_cnt_reg(2);
                        leds_k(6) <= '0';
         WHEN  X"6"  |
               X"7"  => leds_a(6) <= s_led_blink_cnt_reg(2);
                        leds_k(6) <= NOT(s_led_blink_cnt_reg(2));
         WHEN  X"C"  => leds_a(6) <= '0';
                        leds_k(6) <= s_led_blink_cnt_reg(0);
         WHEN  X"D"  => leds_a(6) <= s_led_blink_cnt_reg(0);
                        leds_k(6) <= '0';
         WHEN  X"E"  |
               X"F"  => leds_a(6) <= s_led_blink_cnt_reg(0);
                        leds_k(6) <= NOT(s_led_blink_cnt_reg(0));
         WHEN OTHERS => leds_a(6) <= '0';
                        leds_k(6) <= '0';
      END CASE;
   END PROCESS make_led_6;

   make_led_7 : PROCESS( s_led_7_mode_reg , s_led_blink_cnt_reg )
   BEGIN
      CASE (s_led_7_mode_reg) IS
         WHEN  X"2"  |
               X"A"  => leds_a(7) <= '0';
                        leds_k(7) <= '1';
         WHEN  X"3"  |
               X"B"  => leds_a(7) <= '1';
                        leds_k(7) <= '0';
         WHEN  X"4"  => leds_a(7) <= '0';
                        leds_k(7) <= s_led_blink_cnt_reg(2);
         WHEN  X"5"  => leds_a(7) <= s_led_blink_cnt_reg(2);
                        leds_k(7) <= '0';
         WHEN  X"6"  |
               X"7"  => leds_a(7) <= s_led_blink_cnt_reg(2);
                        leds_k(7) <= NOT(s_led_blink_cnt_reg(2));
         WHEN  X"C"  => leds_a(7) <= '0';
                        leds_k(7) <= s_led_blink_cnt_reg(0);
         WHEN  X"D"  => leds_a(7) <= s_led_blink_cnt_reg(0);
                        leds_k(7) <= '0';
         WHEN  X"E"  |
               X"F"  => leds_a(7) <= s_led_blink_cnt_reg(0);
                        leds_k(7) <= NOT(s_led_blink_cnt_reg(0));
         WHEN OTHERS => leds_a(7) <= '0';
                        leds_k(7) <= '0';
      END CASE;
   END PROCESS make_led_7;

END no_target_specific;
