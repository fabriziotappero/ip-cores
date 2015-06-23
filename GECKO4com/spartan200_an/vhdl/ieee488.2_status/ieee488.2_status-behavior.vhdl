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

ARCHITECTURE no_target_specific OF status_controller IS

   TYPE STATUS_STATE_TYPE IS (IDLE,SIGNAL_DONE,SIGNAL_ERROR,CLEAR,
                              GET_VALUE,STORE_VALUE,LATCH_RESULT,SET_OPC,
                              CALC_100,CALC_10,INIT_SEND,DO_SEND,
                              SET_TRANSPARENT);
                              
   CONSTANT c_100 : std_logic_vector( 6 DOWNTO 0 ) := "1100100";
   CONSTANT c_10  : std_logic_vector( 3 DOWNTO 0 ) := X"A";

   SIGNAL s_command_state_reg                     : STATUS_STATE_TYPE;
   SIGNAL s_standard_event_status_register        : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_standard_event_status_next            : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_standard_event_status_enable_register : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_service_request_enable_register       : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_status_byte_register                  : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_transparent_reg                       : std_logic;
   SIGNAL s_pop                                   : std_logic;
   SIGNAL s_valid_data                            : std_logic;
   SIGNAL s_value_reg                             : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_overflow                              : std_logic;
   SIGNAL s_result_reg                            : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_100_remain_reg                        : std_logic_vector( 6 DOWNTO 0 );
   SIGNAL s_100_div_reg                           : std_logic_vector( 1 DOWNTO 0 );
   SIGNAL s_10_remain_reg                         : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_10_div_reg                            : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_send_cnt_reg                          : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_push                                  : std_logic;

BEGIN
--------------------------------------------------------------------------------
--- Here the outputs are defined                                             ---
--------------------------------------------------------------------------------
   cmd_error     <= '1' WHEN s_command_state_reg = SIGNAL_ERROR ELSE '0';
   done          <= '1' WHEN s_command_state_reg = SIGNAL_DONE  ELSE '0';
   pop           <= s_pop;
   push          <= s_push;
   push_size     <= '1' WHEN s_send_cnt_reg = X"4" ELSE '0';
   transparent   <= s_transparent_reg;
   status_nibble <= s_status_byte_register( 5 DOWNTO 2 );
   
   make_push_data : PROCESS( s_send_cnt_reg , s_10_div_reg , s_100_div_reg ,
                             s_10_remain_reg )
   BEGIN
      CASE (s_send_cnt_reg) IS
         WHEN  X"4"  => IF (s_10_div_reg = X"0" AND
                            s_100_div_reg = "00") THEN
                           push_data <= X"02";
                        ELSIF (s_100_div_reg = "00") THEN
                           push_data <= X"03";
                                                     ELSE
                           push_data <= X"04";
                        END IF;
         WHEN  X"3"  => push_data <= X"3"&"00"&s_100_div_reg;
         WHEN  X"2"  => push_data <= X"3"&s_10_div_reg;
         WHEN  X"1"  => push_data <= X"3"&s_10_remain_reg;
         WHEN  X"0"  => push_data <= X"0A";
         WHEN OTHERS => push_data <= X"00";
      END CASE;
   END PROCESS make_push_data;

--------------------------------------------------------------------------------
--- Here the control signals are defined                                     ---
--------------------------------------------------------------------------------
   s_pop     <= '1' WHEN s_command_state_reg = GET_VALUE AND
                         pop_empty = '0' ELSE '0';
   s_push    <= '1' WHEN s_send_cnt_reg(3) = '0' AND
                         push_full = '0' ELSE '0';
   s_valid_data <= '1' WHEN (pop_data = X"30" OR
                             pop_data = X"31" OR
                             pop_data = X"32" OR
                             pop_data = X"33" OR
                             pop_data = X"34" OR
                             pop_data = X"35" OR
                             pop_data = X"36" OR
                             pop_data = X"37" OR
                             pop_data = X"38" OR
                             pop_data = X"39") AND
                            s_pop = '1' ELSE '0';
   
   s_status_byte_register(7) <= '0';
   s_status_byte_register(6) <= (s_service_request_enable_register(7) AND
                                 s_status_byte_register(7)) 
                                OR
                                (s_service_request_enable_register(5) AND
                                 s_status_byte_register(5)) 
                                OR
                                (s_service_request_enable_register(4) AND
                                 s_status_byte_register(4)) 
                                OR
                                (s_service_request_enable_register(3) AND
                                 s_status_byte_register(3)) 
                                OR
                                (s_service_request_enable_register(2) AND
                                 s_status_byte_register(2)) 
                                OR
                                (s_service_request_enable_register(1) AND
                                 s_status_byte_register(1)) 
                                OR
                                (s_service_request_enable_register(0) AND
                                 s_status_byte_register(0));
   s_status_byte_register(5) <= ((s_standard_event_status_register(0) AND
                                  s_standard_event_status_enable_register(0))
                                 OR
                                 (s_standard_event_status_register(1) AND
                                  s_standard_event_status_enable_register(1))
                                 OR
                                 (s_standard_event_status_register(2) AND
                                  s_standard_event_status_enable_register(2))
                                 OR
                                 (s_standard_event_status_register(3) AND
                                  s_standard_event_status_enable_register(3))
                                 OR
                                 (s_standard_event_status_register(4) AND
                                  s_standard_event_status_enable_register(4))
                                 OR
                                 (s_standard_event_status_register(5) AND
                                  s_standard_event_status_enable_register(5))
                                 OR
                                 (s_standard_event_status_register(6) AND
                                  s_standard_event_status_enable_register(6))
                                 OR
                                 (s_standard_event_status_register(7) AND
                                  s_standard_event_status_enable_register(7)))
                                   WHEN s_transparent_reg = '0' ELSE
                                ESB_bit;
   s_status_byte_register(4) <= NOT(push_empty); -- MAV bit
   s_status_byte_register(3) <= STATUS3_bit WHEN s_transparent_reg = '1' ELSE
                                fpga_configured;
   s_status_byte_register(2) <= s_transparent_reg;
   s_status_byte_register(1) <= '0';
   s_status_byte_register(0) <= '0';
   
   s_standard_event_status_next(0) <= '1' WHEN s_command_state_reg = SET_OPC ELSE 
                                      s_standard_event_status_register(0);
   s_standard_event_status_next(1) <= s_standard_event_status_register(1);
   s_standard_event_status_next(2) <= s_standard_event_status_register(2);
   s_standard_event_status_next(3) <= s_standard_event_status_register(3);
   s_standard_event_status_next(4) <= s_standard_event_status_register(4) OR
                                      execution_error;
   s_standard_event_status_next(5) <= s_standard_event_status_register(5) OR
                                      command_error;
   s_standard_event_status_next(6) <= s_standard_event_status_register(6);
   s_standard_event_status_next(7) <= s_standard_event_status_register(7);
--------------------------------------------------------------------------------
--- Here the state machine is defined                                        ---
--------------------------------------------------------------------------------
   make_state_machine : PROCESS( clock , reset , s_command_state_reg , start ,
                                 command )
      VARIABLE v_next_state : STATUS_STATE_TYPE;
   BEGIN
      CASE (s_command_state_reg) IS
         WHEN IDLE                  => IF (start = '1') THEN
                                          CASE (command) IS
                                             WHEN "0000010" => v_next_state := CLEAR;
                                             WHEN "0000110" |
                                                  "0010000" => v_next_state := GET_VALUE;
                                             WHEN "0000111" |
                                                  "0001000" |
                                                  "0010001" |
                                                  "0010010" |
                                                  "0001100" |
                                                  "0010100" |
                                                  "0001010" => v_next_state := LATCH_RESULT;
                                             WHEN "0001011" => v_next_state := SET_OPC;
                                             WHEN "0010101" => v_next_state := SIGNAL_DONE;
                                             WHEN "0110011" => v_next_state := SET_TRANSPARENT;
                                             WHEN OTHERS    => v_next_state := IDLE;
                                          END CASE;
                                                        ELSE
                                          v_next_state := IDLE;
                                       END IF;
         WHEN CLEAR                 => v_next_state := SIGNAL_DONE;
         WHEN GET_VALUE             => IF (s_overflow = '1') THEN 
                                          v_next_state := SIGNAL_ERROR;
                                       ELSIF (s_pop = '1') THEN
                                          IF (pop_data = X"0A" OR
                                              pop_data = X"3B" OR
                                              (pop_last = '1' AND
                                               (s_valid_data = '1' OR
                                                pop_data = X"20"))) THEN
                                             v_next_state := STORE_VALUE;
                                          ELSIF (pop_last = '0' AND
                                                 (s_valid_data = '1' OR
                                                  pop_data = X"20")) THEN
                                             v_next_state := GET_VALUE;
                                                                   ELSE
                                             v_next_state := SIGNAL_ERROR;
                                          END IF;
                                                        ELSE 
                                          v_next_state := GET_VALUE;
                                       END IF;
         WHEN STORE_VALUE           => v_next_state := SIGNAL_DONE;
         WHEN LATCH_RESULT          => v_next_state := CALC_100;
         WHEN CALC_100              => v_next_state := CALC_10;
         WHEN CALC_10               => v_next_state := INIT_SEND;
         WHEN INIT_SEND             => v_next_state := DO_SEND;
         WHEN DO_SEND               => IF (s_send_cnt_reg(3) = '1') THEN 
                                          v_next_state := SIGNAL_DONE;
                                                                    ELSE
                                          v_next_state := DO_SEND;
                                       END IF;
         WHEN SET_OPC               => v_next_state := SIGNAL_DONE;
         WHEN SET_TRANSPARENT       => IF (fpga_configured = '1') THEN
                                          v_next_state := SIGNAL_DONE;
                                                                  ELSE
                                          v_next_state := SIGNAL_ERROR;
                                       END IF;
         WHEN OTHERS                => v_next_state := IDLE;
      END CASE;
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_command_state_reg <= IDLE;
                          ELSE s_command_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_state_machine;
   
--------------------------------------------------------------------------------
--- Here the value handling is defined                                       ---
--------------------------------------------------------------------------------
   make_value_reg : PROCESS( clock , s_command_state_reg , pop_data ,
                             s_valid_data )
      VARIABLE v_add_1 : std_logic_vector(11 DOWNTO 0 );
      VARIABLE v_add_2 : std_logic_vector(11 DOWNTO 0 );
      VARIABLE v_add_3 : std_logic_vector(11 DOWNTO 0 );
      VARIABLE v_sum   : std_logic_vector(11 DOWNTO 0 );
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_command_state_reg = IDLE) THEN
            s_value_reg <= X"00";
            s_overflow  <= '0';
         ELSIF (s_valid_data = '1') THEN
            v_add_1 := X"00"&pop_data( 3 DOWNTO 0 );
            v_add_2 := "000"&s_value_reg&"0";
            v_add_3 := "0"&s_value_reg&"000";
            v_sum   := unsigned(v_add_1) + unsigned(v_add_2) + unsigned(v_add_3);
            s_value_reg <= v_sum( 7 DOWNTO 0 );
            s_overflow  <= v_sum(8) OR v_sum(9) OR v_sum(10) OR v_sum(11);
         END IF;
      END IF;
   END PROCESS make_value_reg;
   
--------------------------------------------------------------------------------
--- Here the query handling is defined                                       ---
--------------------------------------------------------------------------------
   make_result_reg : PROCESS( clock , s_command_state_reg , reset )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_result_reg <= X"00";
         ELSIF (s_command_state_reg = LATCH_RESULT) THEN
            CASE (command) IS
               WHEN "0000111" => s_result_reg <= s_standard_event_status_enable_register;
               WHEN "0001000" => s_result_reg <= s_standard_event_status_register;
               WHEN "0010001" => s_result_reg <= s_service_request_enable_register;
               WHEN "0010010" => s_result_reg <= s_status_byte_register;
               WHEN "0001100" => s_result_reg <= X"01";
               WHEN OTHERS    => s_result_reg <= X"00";
            END CASE;
         END IF;
      END IF;
   END PROCESS make_result_reg;
   
   make_100_regs : PROCESS( clock , s_result_reg )
      VARIABLE v_sub_1_1 : std_logic_vector( 8 DOWNTO 0 );
      VARIABLE v_sub_1_2 : std_logic_vector( 8 DOWNTO 0 );
      VARIABLE v_sub_1   : std_logic_vector( 8 DOWNTO 0 );
      VARIABLE v_sub_2_1 : std_logic_vector( 7 DOWNTO 0 );
      VARIABLE v_sub_2_2 : std_logic_vector( 7 DOWNTO 0 );
      VARIABLE v_sub_2   : std_logic_vector( 7 DOWNTO 0 );
   BEGIN
      v_sub_1_1 := "0"&s_result_reg;
      v_sub_1_2 := "0"&c_100&"0";
      v_sub_1 := unsigned(v_sub_1_1)-unsigned(v_sub_1_2);
      IF (v_sub_1(8) = '0') THEN v_sub_2_1 := v_sub_1( 7 DOWNTO 0 );
                            ELSE v_sub_2_1 := s_result_reg;
      END IF;
      v_sub_2_2 := "0"&c_100;
      v_sub_2 := unsigned(v_sub_2_1) - unsigned(v_sub_2_2);
      IF (clock'event AND (clock = '1')) THEN
         IF (v_sub_2(7) = '0') THEN s_100_remain_reg <= v_sub_2( 6 DOWNTO 0 );
                               ELSE s_100_remain_reg <= v_sub_2_1( 6 DOWNTO 0 );
         END IF;
         s_100_div_reg(1) <= NOT(v_sub_1(8));
         s_100_div_reg(0) <= NOT(v_sub_2(7));
      END IF;
   END PROCESS make_100_regs;
   
   make_10_regs : PROCESS( clock , s_100_remain_reg )
      VARIABLE v_sub_1    : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_remain_1 : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_sub_2    : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_remain_2 : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_sub_3    : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_remain_3 : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_sub_4    : std_logic_vector( 4 DOWNTO 0 );
   BEGIN
      v_sub_1 := unsigned("0"&s_100_remain_reg(6 DOWNTO 3)) - 
                 unsigned("0"&c_10);
      IF (v_sub_1(4) = '0') THEN 
         v_remain_1 := v_sub_1(3 DOWNTO 0)&s_100_remain_reg(2);
                            ELSE
         v_remain_1 := s_100_remain_reg(6 DOWNTO 2);
      END IF;
      v_sub_2 := unsigned(v_remain_1) - unsigned("0"&c_10);
      IF (v_sub_2(4) = '0') THEN
         v_remain_2 := v_sub_2(3 DOWNTO 0)&s_100_remain_reg(1);
                            ELSE
         v_remain_2 := v_remain_1(3 DOWNTO 0)&s_100_remain_reg(1);
      END IF;
      v_sub_3 := unsigned(v_remain_2) - unsigned("0"&c_10);
      IF (v_sub_3(4) = '0') THEN
         v_remain_3 := v_sub_3(3 DOWNTO 0)&s_100_remain_reg(0);
                            ELSE
         v_remain_3 := v_remain_2(3 DOWNTO 0)&s_100_remain_reg(0);
      END IF;
      v_sub_4 := unsigned(v_remain_3) - unsigned("0"&c_10);
      IF (clock'event AND (clock = '1')) THEN
         IF (v_sub_4(4) = '0') THEN s_10_remain_reg <= v_sub_4(3 DOWNTO 0);
                               ELSE s_10_remain_reg <= v_remain_3(3 DOWNTO 0);
         END IF;
         s_10_div_reg(3) <= NOT(v_sub_1(4));
         s_10_div_reg(2) <= NOT(v_sub_2(4));
         s_10_div_reg(1) <= NOT(v_sub_3(4));
         s_10_div_reg(0) <= NOT(v_sub_4(4));
      END IF;
   END PROCESS make_10_regs;
   
--------------------------------------------------------------------------------
--- Here the data sending is defined                                         ---
--------------------------------------------------------------------------------
   make_send_cnt_reg : PROCESS( clock , reset , s_command_state_reg , s_push )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_send_cnt_reg <= (OTHERS => '1');
         ELSIF (s_command_state_reg = INIT_SEND) THEN
            s_send_cnt_reg <= X"4";
         ELSIF (s_push = '1') THEN
            CASE (s_send_cnt_reg) IS
               WHEN  X"4"  => IF (s_10_div_reg = X"0" AND
                                  s_100_div_reg = "00") THEN
                                 s_send_cnt_reg <= X"1";
                              ELSIF (s_100_div_reg = "00") THEN
                                 s_send_cnt_reg <= X"2";
                                                           ELSE
                                 s_send_cnt_reg <= X"3";
                              END IF;
               WHEN OTHERS => s_send_cnt_reg <= unsigned(s_send_cnt_reg) - 1;
            END CASE;
         END IF;
      END IF;
   END PROCESS make_send_cnt_reg;

--------------------------------------------------------------------------------
--- Here all registers are defined                                           ---
--------------------------------------------------------------------------------
   make_seser : PROCESS( clock , reset , s_command_state_reg ,
                         command , s_value_reg)
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_standard_event_status_enable_register <= X"00";
         ELSIF (s_command_state_reg = STORE_VALUE AND
                command = "0000110" ) THEN
            s_standard_event_status_enable_register <= s_value_reg;
         END IF;
      END IF;
   END PROCESS make_seser;
   
   make_sesr : PROCESS( clock , reset , s_command_state_reg , 
                        s_standard_event_status_next )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_standard_event_status_register <= X"80";
         ELSIF (s_command_state_reg = CLEAR OR
                (s_command_state_reg = LATCH_RESULT AND
                 command = "0001000")) THEN 
            s_standard_event_status_register <= X"00";
                                             ELSE 
            s_standard_event_status_register <= s_standard_event_status_next;
         END IF;
      END IF;
   END PROCESS make_sesr;
   
   make_srer : PROCESS( clock , reset , s_command_state_reg ,
                        command , s_value_reg)
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_service_request_enable_register <= X"00";
         ELSIF (s_command_state_reg = STORE_VALUE AND
                command = "0010000" ) THEN
            s_service_request_enable_register <= s_value_reg;
         END IF;
      END IF;
   END PROCESS make_srer;
   
   make_transparent_reg : PROCESS( clock , reset , s_command_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_command_state_reg = CLEAR OR
             reset = '1') THEN s_transparent_reg <= '0';
         ELSIF (s_command_state_reg = SET_TRANSPARENT AND
                fpga_configured = '1') THEN
            s_transparent_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_transparent_reg;
   
END no_target_specific;
