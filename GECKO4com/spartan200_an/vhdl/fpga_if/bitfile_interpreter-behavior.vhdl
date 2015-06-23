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

ARCHITECTURE no_platform_specific OF bitfile_interpreter IS

   TYPE INTERPRETER_STATES IS (IDLE , SIGNAL_DONE , INIT_GET_LENGTH , GET_LENGTH ,
                               MAKE_FIELD_DESC , INIT_DUMMY_READ , DUMMY_READ ,
                               GET_FIELD_CHAR , UPDATE_FIELD_ID , 
                               CHECK_FIELD_CHAR , FLUSH_FIFO , INIT_GET_B_LENGTH , 
                               GET_B_LENGTH , CHECK_B_LENGTH , INIT_WRITE_STR , 
                               WRITE_STR , COPY_BITSTREAM , SIGNAL_ERROR ,
                               EXECUTE_FLUSH_FIFO );
   TYPE FIELD_TYPES IS (FIELD_1,FIELD_2,FIELD_3,FIELD_4,FIELD_5,FIELD_6,
                        FIELD_7,RAW_DATA,HEADER_ERROR);
   
   SIGNAL s_interpreter_state_reg   : INTERPRETER_STATES;
   SIGNAL s_current_field_reg       : FIELD_TYPES;
   SIGNAL s_down_counter_reg        : std_logic_vector( 16 DOWNTO 0 );
   SIGNAL s_down_counter_load       : std_logic;
   SIGNAL s_down_counter_ena        : std_logic;
   SIGNAL s_down_counter_load_value : std_logic_vector( 16 DOWNTO 0 );
   SIGNAL s_field_length_reg        : std_logic_vector( 15 DOWNTO 0 );
   SIGNAL s_pop_a_byte              : std_logic;
   SIGNAL s_data_reg                : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_ena_data_reg            : std_logic;
   SIGNAL s_we_char_reg             : std_logic;
   SIGNAL s_bitstream_length_reg    : std_logic_vector( 31 DOWNTO 0 );
   SIGNAL s_push_reg                : std_logic;
   SIGNAL s_bitstream_count_reg     : std_logic_vector( 32 DOWNTO 0 );
   SIGNAL s_bitstream_count_next    : std_logic_vector( 32 DOWNTO 0 );
   SIGNAL s_bitstream_count_ena     : std_logic;
   SIGNAL s_error_reg               : std_logic;
   SIGNAL s_watchdog_timer_reg      : std_logic_vector( 11 DOWNTO 0 );
   SIGNAL s_bitstream_size_reg      : std_logic_vector( 31 DOWNTO 0 );
   SIGNAL s_write_flash_reg         : std_logic;

BEGIN
--------------------------------------------------------------------------------
--- Here the outputs are defined                                             ---
--------------------------------------------------------------------------------
   pop            <= s_pop_a_byte;
   done           <= '1' WHEN s_interpreter_state_reg = SIGNAL_DONE ELSE '0';
   ascii_data     <= s_data_reg WHEN s_we_char_reg = '1' ELSE (OTHERS => '0');
   we_char        <= s_we_char_reg;
   push           <= s_push_reg AND NOT(s_write_flash_reg);
   push_data      <= s_data_reg WHEN s_push_reg = '1' ELSE (OTHERS => '0');
   last_byte      <= s_bitstream_count_reg(32);
   error_detected <= s_error_reg WHEN s_interpreter_state_reg = SIGNAL_DONE ELSE '0';
   reset_fpga_if  <= reset OR s_error_reg;
   bitfile_size   <= s_bitstream_size_reg;
   we_data        <= s_data_reg;
   we_fifo        <= s_push_reg AND s_write_flash_reg;
   we_last        <= s_bitstream_count_reg(32) WHEN 
                        s_interpreter_state_reg = COPY_BITSTREAM ELSE '0';
   start_write    <= '1' WHEN s_interpreter_state_reg = CHECK_B_LENGTH AND
                              s_write_flash_reg = '1' ELSE '0';

--------------------------------------------------------------------------------
--- Here the control signals are defined                                     ---
--------------------------------------------------------------------------------
   s_pop_a_byte        <= '1' WHEN
                                 ((s_interpreter_state_reg = GET_LENGTH OR
                                   s_interpreter_state_reg = DUMMY_READ OR
                                   s_interpreter_state_reg = WRITE_STR OR
                                   s_interpreter_state_reg = GET_B_LENGTH) AND
                                  fifo_empty = '0' AND
                                  we_fifo_full = '0' AND
                                  s_down_counter_reg(16) = '0') OR
                                 (s_interpreter_state_reg = GET_FIELD_CHAR AND
                                  fifo_empty = '0' AND
                                  we_fifo_full = '0') OR
                                 (s_interpreter_state_reg = COPY_BITSTREAM AND
                                  fifo_empty = '0' AND
                                  fifo_full = '0' AND
                                  we_fifo_full = '0' AND
                                  s_bitstream_count_reg(32) = '0') OR
                                 (s_interpreter_state_reg = EXECUTE_FLUSH_FIFO AND
                                  fifo_empty = '0' AND
                                  s_bitstream_count_reg(32) = '0')
                              ELSE '0';

--------------------------------------------------------------------------------
--- Here the intermediate data buffer is defined                             ---
--------------------------------------------------------------------------------
   s_ena_data_reg <= s_pop_a_byte;

   make_data_reg : PROCESS( clock , reset , s_ena_data_reg , pop_data )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_data_reg <= X"FF";
         ELSIF (s_ena_data_reg = '1') THEN s_data_reg <= pop_data;
         END IF;
      END IF;
   END PROCESS make_data_reg;

   make_we_char : PROCESS( clock , s_interpreter_state_reg , s_pop_a_byte )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_interpreter_state_reg = WRITE_STR) THEN
            s_we_char_reg <= s_pop_a_byte;
                                                  ELSE
            s_we_char_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_we_char;
   
   make_push_reg : PROCESS( clock , s_interpreter_state_reg , s_pop_a_byte )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_interpreter_state_reg = COPY_BITSTREAM OR
             (s_interpreter_state_reg /= EXECUTE_FLUSH_FIFO AND
              s_write_flash_reg = '1')) THEN
            s_push_reg <= s_pop_a_byte;
                                                 ELSE
            s_push_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_push_reg;

--------------------------------------------------------------------------------
--- Here the general purpose down counter is defined                         ---
--------------------------------------------------------------------------------
   s_down_counter_load <= '1' WHEN
                                 s_interpreter_state_reg = INIT_GET_LENGTH OR
                                 s_interpreter_state_reg = INIT_DUMMY_READ OR
                                 s_interpreter_state_reg = INIT_WRITE_STR OR
                                 s_interpreter_state_reg = INIT_GET_B_LENGTH
                              ELSE '0';
   s_down_counter_ena  <= '1' WHEN
                                 ((s_interpreter_state_reg = GET_LENGTH OR
                                   s_interpreter_state_reg = DUMMY_READ OR
                                   s_interpreter_state_reg = WRITE_STR OR
                                   s_interpreter_state_reg = GET_B_LENGTH) AND
                                  s_pop_a_byte = '1')
                              ELSE '0';
   
   make_down_counter_load_value : PROCESS( s_interpreter_state_reg ,
                                           s_field_length_reg )
      VARIABLE v_length : std_logic_vector( 16 DOWNTO 0 );
   BEGIN
      CASE (s_interpreter_state_reg) IS
         WHEN INIT_GET_LENGTH       => s_down_counter_load_value <= "0"&X"0001";
         WHEN INIT_GET_B_LENGTH     => s_down_counter_load_value <= "0"&X"0003";
         WHEN OTHERS                => v_length := "0"&s_field_length_reg;
                                       s_down_counter_load_value <=
                                          unsigned(v_length) - 1;
      END CASE;
   END PROCESS make_down_counter_load_value;
   
   make_down_counter : PROCESS( clock , s_down_counter_reg ,
                                s_down_counter_load , s_down_counter_ena ,
                                s_down_counter_load_value )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_down_counter_load = '1') THEN
            s_down_counter_reg <= s_down_counter_load_value;
         ELSIF (s_down_counter_ena = '1') THEN
            s_down_counter_reg <= unsigned(s_down_counter_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_down_counter;

--------------------------------------------------------------------------------
--- Here the field length reg is defined                                     ---
--------------------------------------------------------------------------------
   make_field_reg : PROCESS( clock , reset , s_interpreter_state_reg , pop_data ,
                             s_down_counter_reg , s_pop_a_byte )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_field_length_reg <= (OTHERS => '0');
         ELSIF (s_interpreter_state_reg = GET_LENGTH AND
                s_pop_a_byte = '1') THEN
            IF (s_down_counter_reg(0) = '1') THEN
               s_field_length_reg(15 DOWNTO 8) <= pop_data;
                                                    ELSE
               s_field_length_reg( 7 DOWNTO 0) <= pop_data;
            END IF;
         END IF;
      END IF;
   END PROCESS make_field_reg;

--------------------------------------------------------------------------------
--- Here the state machine is defined                                        ---
--------------------------------------------------------------------------------
   make_state_machine : PROCESS( clock , reset , s_interpreter_state_reg ,
                                 start , s_down_counter_reg ,
                                 s_current_field_reg ,
                                 s_bitstream_count_reg , s_watchdog_timer_reg )
      VARIABLE v_next_state : INTERPRETER_STATES;
   BEGIN
      CASE (s_interpreter_state_reg) IS
         WHEN IDLE                  => IF (start = '1') THEN 
                                          v_next_state := INIT_GET_LENGTH;
                                                        ELSE
                                          v_next_state := IDLE;
                                       END IF;
         WHEN INIT_GET_LENGTH       => v_next_state := GET_LENGTH;
         WHEN GET_LENGTH            => IF (s_down_counter_reg(16) = '1') THEN
                                          v_next_state := MAKE_FIELD_DESC;
                                                                         ELSE
                                          v_next_state := GET_LENGTH;
                                       END IF;
         WHEN MAKE_FIELD_DESC       => CASE (s_current_field_reg) IS
                                          WHEN FIELD_1 => v_next_state := INIT_DUMMY_READ;
                                          WHEN FIELD_2 => v_next_state := GET_FIELD_CHAR;
                                          WHEN FIELD_3 |
                                               FIELD_4 |
                                               FIELD_5 |
                                               FIELD_6 => v_next_state := INIT_WRITE_STR;
                                          WHEN OTHERS  => v_next_state := FLUSH_FIFO;
                                       END CASE;
         WHEN INIT_DUMMY_READ       => v_next_state := DUMMY_READ;
         WHEN DUMMY_READ            => IF (s_down_counter_reg(16) = '1') THEN 
                                          v_next_state := INIT_GET_LENGTH;
                                                                         ELSE
                                          v_next_state := DUMMY_READ;
                                       END IF;
         WHEN GET_FIELD_CHAR        => IF (s_pop_a_byte = '1') THEN
                                          v_next_state := UPDATE_FIELD_ID;
                                                               ELSE
                                          v_next_state := GET_FIELD_CHAR;
                                       END IF;
         WHEN UPDATE_FIELD_ID       => v_next_state := CHECK_FIELD_CHAR;
         WHEN CHECK_FIELD_CHAR      => CASE (s_current_field_reg) IS
                                          WHEN HEADER_ERROR => v_next_state := FLUSH_FIFO;
                                          WHEN FIELD_7      => v_next_state := INIT_GET_B_LENGTH;
                                          WHEN OTHERS       => v_next_state := INIT_GET_LENGTH;
                                       END CASE;
         WHEN INIT_GET_B_LENGTH     => v_next_state := GET_B_LENGTH;
         WHEN GET_B_LENGTH          => IF(s_down_counter_reg(16) = '1') THEN
                                          v_next_state := CHECK_B_LENGTH;
                                                                        ELSE
                                          v_next_state := GET_B_LENGTH;
                                       END IF;
         WHEN CHECK_B_LENGTH        => v_next_state := COPY_BITSTREAM;
         WHEN COPY_BITSTREAM        => IF (size_error = '1') THEN
                                          v_next_state := IDLE;
                                       ELSIF (s_bitstream_count_reg(32) = '1') THEN
                                          v_next_state := SIGNAL_DONE;
                                                                            ELSE
                                          v_next_state := COPY_BITSTREAM;
                                       END IF;
         WHEN INIT_WRITE_STR        => v_next_state := WRITE_STR;
         WHEN WRITE_STR             => IF (s_down_counter_reg(16) = '1') THEN
                                          v_next_state := GET_FIELD_CHAR;
                                                                         ELSE
                                          v_next_state := WRITE_STR;
                                       END IF;
         WHEN FLUSH_FIFO            => v_next_state := EXECUTE_FLUSH_FIFO;
         WHEN SIGNAL_ERROR          => v_next_state := SIGNAL_DONE;
         WHEN EXECUTE_FLUSH_FIFO    => IF (pop_last = '1' AND
                                           s_pop_a_byte = '1') THEN
                                          v_next_state := SIGNAL_ERROR;
                                                                            ELSE
                                          v_next_state := EXECUTE_FLUSH_FIFO;
                                       END IF;
         WHEN OTHERS                => v_next_state := IDLE;
      END CASE;
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_interpreter_state_reg <= IDLE;
         ELSIF (s_watchdog_timer_reg(11) = '1') THEN
            s_interpreter_state_reg <= SIGNAL_ERROR;
                                                ELSE 
            s_interpreter_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_state_machine;
   
--------------------------------------------------------------------------------
--- Here the current field identifier is defined                             ---
--------------------------------------------------------------------------------
   make_field_id : PROCESS( clock , s_interpreter_state_reg , s_data_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         CASE (s_interpreter_state_reg) IS
            WHEN IDLE                  => s_current_field_reg <= FIELD_1;
            WHEN INIT_DUMMY_READ       => s_current_field_reg <= FIELD_2;
            WHEN UPDATE_FIELD_ID       => CASE (s_data_reg) IS
                                             WHEN X"61" => s_current_field_reg <= FIELD_3;
                                             WHEN X"62" => s_current_field_reg <= FIELD_4;
                                             WHEN X"63" => s_current_field_reg <= FIELD_5;
                                             WHEN X"64" => s_current_field_reg <= FIELD_6;
                                             WHEN X"65" => s_current_field_reg <= FIELD_7;
                                             WHEN OTHERS=> s_current_field_reg <= HEADER_ERROR;
                                          END CASE;
            WHEN OTHERS                => NULL;
         END CASE;
      END IF;
   END PROCESS make_field_id;

--------------------------------------------------------------------------------
--- Here the bitstream length reg is defined                                 ---
--------------------------------------------------------------------------------
   make_bitstream_length_reg : PROCESS( clock , s_interpreter_state_reg ,
                                        s_pop_a_byte , s_down_counter_reg ,
                                        pop_data )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_interpreter_state_reg = GET_B_LENGTH AND
             s_pop_a_byte = '1') THEN
            CASE (s_down_counter_reg(1 DOWNTO 0)) IS
               WHEN  "11"  => s_bitstream_length_reg( 31 DOWNTO 24 ) <= pop_data;
               WHEN  "10"  => s_bitstream_length_reg( 23 DOWNTO 16 ) <= pop_data;
               WHEN  "01"  => s_bitstream_length_reg( 15 DOWNTO  8 ) <= pop_data;
               WHEN OTHERS => s_bitstream_length_reg(  7 DOWNTO  0 ) <= pop_data;
            END CASE;
         END IF;
      END IF;
   END PROCESS make_bitstream_length_reg;

--------------------------------------------------------------------------------
--- Here the bitstream counter is defined                                    ---
--------------------------------------------------------------------------------
   s_bitstream_count_ena <= '1' WHEN (s_interpreter_state_reg = COPY_BITSTREAM OR
                                      s_interpreter_state_reg = EXECUTE_FLUSH_FIFO) AND
                                     s_pop_a_byte = '1' ELSE '0';
   
   s_bitstream_count_next <= unsigned(s_bitstream_count_reg) - 1;
   
   make_bitstream_count_reg : PROCESS( clock , s_interpreter_state_reg ,
                                       s_bitstream_count_ena ,
                                       s_bitstream_count_next )
      VARIABLE v_length : std_logic_vector( 32 DOWNTO 0 );
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_interpreter_state_reg = GET_B_LENGTH AND
             s_pop_a_byte = '1') THEN
            CASE (s_down_counter_reg(1 DOWNTO 0)) IS
               WHEN  "11"  => s_bitstream_count_reg( 32 DOWNTO 24 ) <= "0"&pop_data;
               WHEN  "10"  => s_bitstream_count_reg( 23 DOWNTO 16 ) <= pop_data;
               WHEN  "01"  => s_bitstream_count_reg( 15 DOWNTO  8 ) <= pop_data;
               WHEN OTHERS => s_bitstream_count_reg(  7 DOWNTO  0 ) <= pop_data;
            END CASE;
         ELSIF (s_bitstream_count_ena = '1' OR
                s_interpreter_state_reg = CHECK_B_LENGTH) THEN
            s_bitstream_count_reg <= s_bitstream_count_next;
         END IF;
      END IF;
   END PROCESS make_bitstream_count_reg;

--------------------------------------------------------------------------------
--- Here the error reg is defined                                            ---
--------------------------------------------------------------------------------
   make_error_reg : PROCESS( clock , s_interpreter_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_interpreter_state_reg = IDLE) THEN s_error_reg <= '0';
         ELSIF (s_interpreter_state_reg = SIGNAL_ERROR) THEN s_error_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_error_reg;

--------------------------------------------------------------------------------
--- Here the watchdog timer is defined                                       ---
--------------------------------------------------------------------------------
   make_watchdog_timer_reg : PROCESS( clock , s_interpreter_state_reg ,
                                      s_pop_a_byte , s_watchdog_timer_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_interpreter_state_reg = IDLE OR
             s_interpreter_state_reg = SIGNAL_ERROR OR
             s_pop_a_byte = '1') THEN
            s_watchdog_timer_reg <= (11=>'0' , OTHERS => '1');
         ELSIF (s_watchdog_timer_reg(11) = '0' AND
                msec_tick = '1') THEN
            s_watchdog_timer_reg <= unsigned(s_watchdog_timer_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_watchdog_timer_reg;

--------------------------------------------------------------------------------
--- Here the bitstream size count reg is defined                             ---
--------------------------------------------------------------------------------
   make_bitstream_size_reg : PROCESS( clock , s_pop_a_byte , 
                                      s_interpreter_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_interpreter_state_reg = IDLE) THEN
            s_bitstream_size_reg <= (OTHERS => '0');
         ELSIF (s_interpreter_state_reg /= COPY_BITSTREAM AND
                s_interpreter_state_reg /= FLUSH_FIFO AND
                s_pop_a_byte = '1') THEN
            s_bitstream_size_reg <= unsigned(s_bitstream_size_reg) + 1;
         ELSIF (s_interpreter_state_reg = CHECK_B_LENGTH) THEN
            s_bitstream_size_reg <= unsigned(s_bitstream_size_reg) +
                                    unsigned(s_bitstream_length_reg);
         END IF;
      END IF;
   END PROCESS make_bitstream_size_reg;
   
   make_write_flash_reg : PROCESS( clock , reset , start , write_flash )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_write_flash_reg <= '0';
         ELSIF (start = '1') THEN s_write_flash_reg <= write_flash;
         END IF;
      END IF;
   END PROCESS make_write_flash_reg;

END no_platform_specific;
