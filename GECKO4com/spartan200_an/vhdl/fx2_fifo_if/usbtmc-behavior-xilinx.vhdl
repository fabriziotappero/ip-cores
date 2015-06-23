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

-- The unisim library is used for simulation of the xilinx specific components
-- For generic usage please use:
-- LIBRARY work;
-- USE work.xilinx_generic.all;
-- And use the xilinx generic package found in the xilinx generic module
LIBRARY unisim;
USE unisim.all;

-- For sending messages to the PC, the FIFO has to contain:
-- 1) The size of the message (in bytes) with the size bit set (can have 1,
--    2,3, or 4 bytes to indicate size (LSB first))
-- 2) The message itself.

ARCHITECTURE xilinx OF USBTMC IS

   TYPE USBTMC_STATE_TYPE IS (WAIT_HEADER,INIT_READ_HEADER,READ_HEADER,
                              INTERPRET_HEADER,SIGNAL_ERROR,ERROR_WAIT,
                              INIT_COPY_PAYLOAD,DET_RX_SIZE,CHECK_TX_FIFO,
                              REQUEST_PAYLOAD_BYTES,CHECK_PAYLOAD_BYTES,
                              INIT_DUMMY_READ,DO_DUMMY_READ,DUMMY_NOP,
                              DET_MAX_TRASF_SIZE,CHECK_FIFO_STATUS,
                              RESET_MESSAGE_SIZE,GET_MESSAGE_SIZE_0,
                              GET_MESSAGE_SIZE_1,GET_MESSAGE_SIZE_2,
                              GET_MESSAGE_SIZE_3,MESSAGE_UPDATE,SEND_HEADER,
                              SEND_PAYLOAD,SEND_PKT_END,CHECK_FULL_STATUS,
                              TX_NOP);

   COMPONENT FD
      GENERIC ( INIT : bit );
      PORT ( Q   : OUT std_logic;
             C   : IN  std_logic;
             D   : IN  std_logic );
   END COMPONENT;
   
   COMPONENT FD_1
      GENERIC ( INIT : bit );
      PORT ( Q   : OUT std_logic;
             C   : IN  std_logic;
             D   : IN  std_logic );
   END COMPONENT;
   
   COMPONENT FDE
      GENERIC ( INIT : bit );
      PORT ( Q   : OUT std_logic;
             CE  : IN  std_logic;
             C   : IN  std_logic;
             D   : IN  std_logic );
   END COMPONENT;
   
   COMPONENT fifo_2kb_ef
      PORT ( clock      : IN  std_logic;
             reset      : IN  std_logic;
             high_speed : IN  std_logic;
             -- push port
             push       : IN  std_logic;
             push_data  : IN  std_logic_vector(  7 DOWNTO 0 );
             push_last  : IN  std_logic;
             -- pop port
             pop        : IN  std_logic;
             pop_data   : OUT std_logic_vector(  7 DOWNTO 0 );
             pop_last   : OUT std_logic;
             -- control port
             fifo_full  : OUT std_logic;
             early_full : OUT std_logic;
             fifo_empty : OUT std_logic );
   END COMPONENT;
   
   COMPONENT fifo_2kb
      PORT ( clock      : IN  std_logic;
             reset      : IN  std_logic;
             -- push port
             push       : IN  std_logic;
             push_data  : IN  std_logic_vector(  7 DOWNTO 0 );
             push_size  : IN  std_logic;
             -- pop port
             pop        : IN  std_logic;
             pop_data   : OUT std_logic_vector(  7 DOWNTO 0 );
             pop_size   : OUT std_logic;
             -- control port
             fifo_full  : OUT std_logic;
             fifo_empty : OUT std_logic );
   END COMPONENT;
   
   CONSTANT c_high_speed_packet_size : std_logic_vector( 9 DOWNTO 0 ) := "10"&X"00";
   CONSTANT c_full_speed_packet_size : std_logic_vector( 9 DOWNTO 0 ) := "00"&X"40";
   
   SIGNAL s_fifo_clock_reg              : std_logic;
   SIGNAL s_reset                       : std_logic;
   SIGNAL s_reset_count_reg             : std_logic_vector( 2 DOWNTO 0 );
   
   SIGNAL s_EP8_not_empty               : std_logic;
   SIGNAL s_EP6_not_full                : std_logic;
   SIGNAL s_endpoint_addr_next          : std_logic_vector( 1 DOWNTO 0 );
   SIGNAL s_endpoint_n_oe_next          : std_logic;
   SIGNAL s_endpoint_n_re_next          : std_logic;
   
   SIGNAL s_ena_out_ffs                 : std_logic;
   SIGNAL s_ena_in_ffs                  : std_logic;
   SIGNAL s_ena_data_in                 : std_logic;
   SIGNAL s_ready_to_receive_reg        : std_logic;
   
   SIGNAL s_usbtmc_state_reg            : USBTMC_STATE_TYPE;
   SIGNAL s_request_header_byte         : std_logic;
   SIGNAL s_header_byte_request_pending : std_logic;
   SIGNAL s_header_byte_valid           : std_logic;
   SIGNAL s_header_byte_pending_id      : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_header_byte_valid_id        : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_header_byte_request_id      : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_header_request_done         : std_logic;
   SIGNAL s_header_error_reg            : std_logic;
   SIGNAL s_header_error_next           : std_logic;
   SIGNAL s_Message_ID_reg              : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_known_Message_ID            : std_logic;
   SIGNAL s_bTag_reg                    : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_bTag_inverse                : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_bTag_error                  : std_logic;
   SIGNAL s_data_in_is_zero             : std_logic;
   SIGNAL s_reserved_3_error            : std_logic;
   SIGNAL s_transfer_size_reg           : std_logic_vector( 31 DOWNTO 0 );
   SIGNAL s_zero_payload_size_reg       : std_logic;
   SIGNAL s_eom_bit_reg                 : std_logic;
   SIGNAL s_rx_message_in_progress_reg  : std_logic;
   
   SIGNAL s_data_in                     : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_read_fifo_full              : std_logic;
   SIGNAL s_last_message_byte           : std_logic;
   
   SIGNAL s_data_out_reg                : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_ep_n_we_reg                 : std_logic;
   SIGNAL s_ep_pkt_end_reg              : std_logic;
   SIGNAL s_ep_n_tri_next               : std_logic;
   SIGNAL s_tx_pop_data                 : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_tx_pop_data_reg             : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_tx_pop_size                 : std_logic;
   SIGNAL s_tx_fifo_empty               : std_logic;
   
   SIGNAL s_tx_fifo_data_reg            : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_tx_fifo_data_valid_reg      : std_logic;
   SIGNAL s_tx_fifo_size_bit_reg        : std_logic;
   SIGNAL s_tx_fifo_pop                 : std_logic;
   SIGNAL s_outstanding_messages_reg    : std_logic_vector(  9 DOWNTO 0 );
   SIGNAL s_message_in_progress_reg     : std_logic;
   SIGNAL s_message_size_reg            : std_logic_vector( 31 DOWNTO 0 );
   SIGNAL s_valid_msg_size_byte         : std_logic;
   SIGNAL s_valid_payload_byte          : std_logic;
   SIGNAL s_tx_data_pop                 : std_logic;
   SIGNAL s_can_tx_complete_message     : std_logic;
   SIGNAL s_can_tx_complete_message_reg : std_logic;
   SIGNAL s_real_payload_size_reg       : std_logic_vector( 32 DOWNTO 0 );
   SIGNAL s_header_insert_count_reg     : std_logic_vector(  4 DOWNTO 0 );
   SIGNAL s_bytes_send_cnt_reg          : std_logic_vector(  9 DOWNTO 0 );
   SIGNAL s_require_n_pkt_end           : std_logic;
   SIGNAL s_send_payload_byte           : std_logic;
   
   SIGNAL s_nr_of_bytes_req_cnt_reg     : std_logic_vector(  9 DOWNTO 0 );
   SIGNAL s_resting_buffer_bytes        : std_logic_vector(  9 DOWNTO 0 );
   SIGNAL s_rx_payload_cnt_reg          : std_logic_vector( 32 DOWNTO 0 );
   SIGNAL s_rx_payload_cnt_next         : std_logic_vector( 32 DOWNTO 0 );
   SIGNAL s_rx_cnt_reg                  : std_logic_vector(  9 DOWNTO 0 );
   SIGNAL s_can_rx_all                  : std_logic;
   SIGNAL s_req_payload_byte            : std_logic;
   SIGNAL s_rx_pending_pipe_reg         : std_logic_vector(  1 DOWNTO 0 );
   SIGNAL s_lmb_pipe_reg                : std_logic_vector(  1 DOWNTO 0 );
   SIGNAL s_rf_last_data_byte           : std_logic;
   SIGNAL s_dummy_read_cnt_reg          : std_logic_vector(  2 DOWNTO 0 );
   
   SIGNAL s_wf_push                     : std_logic;
   SIGNAL s_wf_push_data                : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_wf_push_size                : std_logic;
   
   SIGNAL s_fx2_data_nibble             : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_fx2_data_select             : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_ind_pipe_reg                : std_logic_vector( 1 DOWNTO 0 );
   
BEGIN

--------------------------------------------------------------------------------
-- define outputs                                                             --
--------------------------------------------------------------------------------
   sync_reset_out   <= s_reset;
   transfer_in_prog <= s_rx_message_in_progress_reg;
   rf_last_data_byte<= s_rf_last_data_byte;
   wf_fifo_empty    <= s_tx_fifo_empty;
   indicator_pulse  <= s_ind_pipe_reg(0) AND NOT(s_ind_pipe_reg(1));
   
--------------------------------------------------------------------------------
-- define control signals                                                     --
--------------------------------------------------------------------------------
   s_endpoint_addr_next <= "11" WHEN 
                                   s_usbtmc_state_reg = INIT_READ_HEADER OR
                                   s_usbtmc_state_reg = READ_HEADER OR
                                   s_usbtmc_state_reg = INTERPRET_HEADER OR
                                   s_usbtmc_state_reg = INIT_COPY_PAYLOAD OR
                                   s_usbtmc_state_reg = DET_RX_SIZE OR
                                   s_usbtmc_state_reg = CHECK_TX_FIFO OR
                                   s_usbtmc_state_reg = REQUEST_PAYLOAD_BYTES OR
                                   s_usbtmc_state_reg = CHECK_PAYLOAD_BYTES OR
                                   s_usbtmc_state_reg = INIT_DUMMY_READ OR
                                   s_usbtmc_state_reg = DO_DUMMY_READ OR
                                   s_usbtmc_state_reg = DUMMY_NOP
                                ELSE
                           "10" WHEN
                                   s_usbtmc_state_reg = CHECK_FIFO_STATUS OR
                                   s_usbtmc_state_reg = RESET_MESSAGE_SIZE OR
                                   s_usbtmc_state_reg = GET_MESSAGE_SIZE_0 OR
                                   s_usbtmc_state_reg = GET_MESSAGE_SIZE_1 OR
                                   s_usbtmc_state_reg = GET_MESSAGE_SIZE_2 OR
                                   s_usbtmc_state_reg = GET_MESSAGE_SIZE_3 OR
                                   s_usbtmc_state_reg = MESSAGE_UPDATE OR
                                   s_usbtmc_state_reg = SEND_HEADER OR
                                   s_usbtmc_state_reg = SEND_PAYLOAD OR
                                   s_usbtmc_state_reg = SEND_PKT_END OR
                                   s_usbtmc_state_reg = CHECK_FULL_STATUS OR
                                   s_usbtmc_state_reg = TX_NOP
                                ELSE "00";
   s_endpoint_n_oe_next <= '0' WHEN
                                  s_usbtmc_state_reg = INIT_READ_HEADER OR
                                  s_usbtmc_state_reg = READ_HEADER OR
                                  s_usbtmc_state_reg = INTERPRET_HEADER OR
                                  s_usbtmc_state_reg = INIT_COPY_PAYLOAD OR
                                  s_usbtmc_state_reg = DET_RX_SIZE OR
                                  s_usbtmc_state_reg = CHECK_TX_FIFO OR
                                  s_usbtmc_state_reg = REQUEST_PAYLOAD_BYTES OR
                                  s_usbtmc_state_reg = CHECK_PAYLOAD_BYTES OR
                                  s_usbtmc_state_reg = INIT_DUMMY_READ OR
                                  s_usbtmc_state_reg = DO_DUMMY_READ OR
                                  s_usbtmc_state_reg = DUMMY_NOP
                               ELSE '1';
   s_endpoint_n_re_next <= '0' WHEN s_request_header_byte = '1' OR
                                    s_req_payload_byte = '1' OR
                                    s_usbtmc_state_reg = DO_DUMMY_READ ELSE
                           '1';
   s_ena_in_ffs         <= NOT(s_fifo_clock_reg);
   s_ena_out_ffs        <= s_fifo_clock_reg;
   s_ena_data_in        <= (s_header_byte_request_pending OR
                            s_rx_pending_pipe_reg(0)) AND s_ena_in_ffs;
   s_ep_n_tri_next      <= '0' WHEN 
                                   s_usbtmc_state_reg = CHECK_FIFO_STATUS OR
                                   s_usbtmc_state_reg = RESET_MESSAGE_SIZE OR
                                   s_usbtmc_state_reg = GET_MESSAGE_SIZE_0 OR
                                   s_usbtmc_state_reg = GET_MESSAGE_SIZE_1 OR
                                   s_usbtmc_state_reg = GET_MESSAGE_SIZE_2 OR
                                   s_usbtmc_state_reg = GET_MESSAGE_SIZE_3 OR
                                   s_usbtmc_state_reg = MESSAGE_UPDATE OR
                                   s_usbtmc_state_reg = SEND_HEADER OR
                                   s_usbtmc_state_reg = SEND_PAYLOAD OR
                                   s_usbtmc_state_reg = SEND_PKT_END OR
                                   s_usbtmc_state_reg = CHECK_FULL_STATUS OR
                                   s_usbtmc_state_reg = TX_NOP
                               ELSE '1';

--------------------------------------------------------------------------------
-- Here the state machine is defined                                          --
--------------------------------------------------------------------------------
   make_state_reg : PROCESS( clock_48MHz , s_reset , s_usbtmc_state_reg ,
                             s_EP8_not_empty , s_header_request_done ,
                             s_header_error_reg , s_header_byte_valid ,
                             s_message_in_progress_reg ,
                             s_ready_to_receive_reg , s_outstanding_messages_reg ,
                             s_tx_fifo_empty , s_tx_pop_size , s_EP6_not_full )
      VARIABLE v_next_state : USBTMC_STATE_TYPE;
   BEGIN
      CASE (s_usbtmc_state_reg) IS
         WHEN WAIT_HEADER           => IF (s_EP8_not_empty = '1' AND
                                           s_ready_to_receive_reg = '1') THEN
                                          v_next_state := INIT_READ_HEADER;
                                                                  ELSE
                                          v_next_state := WAIT_HEADER;
                                       END IF;
         WHEN INIT_READ_HEADER      => v_next_state := READ_HEADER;
         WHEN READ_HEADER           => IF (s_header_request_done = '1') THEN
                                          v_next_state := INTERPRET_HEADER;
                                       ELSIF (s_EP8_not_empty = '0') THEN
                                          v_next_state := SIGNAL_ERROR;
                                                                     ELSE
                                          v_next_state := READ_HEADER;
                                       END IF;
         WHEN INTERPRET_HEADER      => IF (s_header_byte_valid = '1') THEN
                                          v_next_state := INTERPRET_HEADER;
                                       ELSIF (s_header_error_reg = '1') THEN
                                          v_next_state := SIGNAL_ERROR;
                                                                     ELSE
                                          CASE (s_Message_ID_reg) IS
                                             WHEN  X"01" => v_next_state := INIT_COPY_PAYLOAD;
                                             WHEN  X"02" => v_next_state := DET_MAX_TRASF_SIZE;
                                             WHEN OTHERS => v_next_state := SIGNAL_ERROR;
                                          END CASE;
                                       END IF;
         WHEN INIT_COPY_PAYLOAD     => v_next_state := DET_RX_SIZE;
         WHEN DET_RX_SIZE           => v_next_state := CHECK_TX_FIFO;
         WHEN CHECK_TX_FIFO         => IF (s_read_fifo_full = '1') THEN
                                          v_next_state := CHECK_TX_FIFO;
                                                                   ELSE
                                          v_next_state := REQUEST_PAYLOAD_BYTES;
                                       END IF;
         WHEN REQUEST_PAYLOAD_BYTES => IF (s_rx_cnt_reg(9) = '1') THEN
                                          v_next_state := CHECK_PAYLOAD_BYTES;
                                                                  ELSE
                                          v_next_state := REQUEST_PAYLOAD_BYTES;
                                       END IF;
         WHEN CHECK_PAYLOAD_BYTES   => IF (s_rx_payload_cnt_reg(32) = '1') THEN
                                          IF (s_transfer_size_reg(1 DOWNTO 0) = "00") THEN
                                             v_next_state := DUMMY_NOP;
                                                                                      ELSE
                                             v_next_state := INIT_DUMMY_READ;
                                          END IF;
                                                                           ELSE
                                          IF (s_EP8_not_empty = '1') THEN
                                             v_next_state := DET_RX_SIZE;
                                                                     ELSE
                                             v_next_state := CHECK_PAYLOAD_BYTES;
                                          END IF;
                                       END IF;
         WHEN INIT_DUMMY_READ       => v_next_state := DO_DUMMY_READ;
         WHEN DO_DUMMY_READ         => IF (s_dummy_read_cnt_reg(2) = '1') THEN
                                          v_next_state := DUMMY_NOP;
                                                                          ELSE
                                          v_next_state := DO_DUMMY_READ;
                                       END IF;
         WHEN DET_MAX_TRASF_SIZE    => IF (s_message_in_progress_reg = '1') THEN
                                           v_next_state := CHECK_FIFO_STATUS;
                                                                            ELSE
                                           v_next_state := RESET_MESSAGE_SIZE;
                                       END IF;
         WHEN RESET_MESSAGE_SIZE    => IF (s_outstanding_messages_reg(9) = '0') THEN 
                                          v_next_state := GET_MESSAGE_SIZE_0;
                                                                                ELSE
                                          v_next_state := CHECK_FIFO_STATUS;
                                       END IF;
         WHEN GET_MESSAGE_SIZE_0    => IF (s_tx_data_pop = '1') THEN
                                          v_next_state := GET_MESSAGE_SIZE_1;
                                                                ELSE
                                          v_next_state := GET_MESSAGE_SIZE_0;
                                       END IF;
         WHEN GET_MESSAGE_SIZE_1    => IF (s_tx_data_pop = '1' OR
                                           s_valid_payload_byte = '1') THEN
                                          v_next_state := GET_MESSAGE_SIZE_2;
                                                                ELSE
                                          v_next_state := GET_MESSAGE_SIZE_1;
                                       END IF;
         WHEN GET_MESSAGE_SIZE_2    => IF (s_tx_data_pop = '1' OR
                                           s_valid_payload_byte = '1') THEN
                                          v_next_state := GET_MESSAGE_SIZE_3;
                                                                ELSE
                                          v_next_state := GET_MESSAGE_SIZE_2;
                                       END IF;
         WHEN GET_MESSAGE_SIZE_3    => IF (s_tx_data_pop = '1' OR
                                           s_valid_payload_byte = '1') THEN
                                          v_next_state := MESSAGE_UPDATE;
                                                                ELSE
                                          v_next_state := GET_MESSAGE_SIZE_3;
                                       END IF;
         WHEN MESSAGE_UPDATE        => v_next_state := CHECK_FIFO_STATUS;
         WHEN CHECK_FIFO_STATUS     => IF (s_EP6_not_full = '0') THEN
                                          v_next_state := CHECK_FIFO_STATUS;
                                                                 ELSE
                                          v_next_state := SEND_HEADER;
                                       END IF;
         WHEN SEND_HEADER           => IF (s_header_insert_count_reg(4) = '1') THEN
                                          v_next_state := SEND_PAYLOAD;
                                                                               ELSE
                                          v_next_state := SEND_HEADER;
                                       END IF;
         WHEN SEND_PAYLOAD          => IF (s_require_n_pkt_end = '1' OR
                                           s_real_payload_size_reg(32) = '1') THEN
                                          v_next_state := SEND_PKT_END;
                                                                      ELSE
                                          v_next_state := SEND_PAYLOAD;
                                       END IF;
         WHEN SEND_PKT_END          => v_next_state := CHECK_FULL_STATUS;
         WHEN CHECK_FULL_STATUS     => IF (s_real_payload_size_reg(32) = '1') THEN
                                          v_next_state := TX_NOP;
                                       ELSIF (s_EP6_not_full = '0') THEN
                                          v_next_state := CHECK_FULL_STATUS;
                                                                 ELSE
                                          v_next_state := SEND_PAYLOAD;
                                       END IF;
         WHEN SIGNAL_ERROR          => v_next_state := ERROR_WAIT;
         WHEN ERROR_WAIT            => v_next_state := ERROR_WAIT;
         WHEN OTHERS                => v_next_state := WAIT_HEADER;
      END CASE;
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_usbtmc_state_reg <= WAIT_HEADER;
                            ELSE s_usbtmc_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_state_reg;
   
   make_ready_to_receive_reg : PROCESS( clock_48MHz , s_reset ,
                                        s_usbtmc_state_reg , rf_pop )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1' OR
             (rf_pop = '1' AND
              s_rf_last_data_byte = '1')) THEN s_ready_to_receive_reg <= '1';
         ELSIF (s_usbtmc_state_reg = INIT_COPY_PAYLOAD) THEN
            s_ready_to_receive_reg <= s_rx_message_in_progress_reg;
         END IF;
      END IF;
   END PROCESS make_ready_to_receive_reg;

--------------------------------------------------------------------------------
-- Here the message sending is defined                                        --
--------------------------------------------------------------------------------
   s_tx_fifo_pop         <= '1' WHEN (s_tx_fifo_data_valid_reg = '0' OR
                                      s_tx_data_pop = '1' OR
                                      s_send_payload_byte = '1') AND
                                     s_tx_fifo_empty = '0' ELSE '0';
   s_valid_msg_size_byte <= s_tx_fifo_data_valid_reg AND
                            s_tx_fifo_size_bit_reg;
   s_valid_payload_byte  <= s_tx_fifo_data_valid_reg AND
                            NOT(s_tx_fifo_size_bit_reg);
   s_tx_data_pop         <= '1' WHEN s_valid_msg_size_byte = '1' AND
                                     (s_usbtmc_state_reg = GET_MESSAGE_SIZE_0 OR
                                      s_usbtmc_state_reg = GET_MESSAGE_SIZE_1 OR
                                      s_usbtmc_state_reg = GET_MESSAGE_SIZE_2 OR
                                      s_usbtmc_state_reg = GET_MESSAGE_SIZE_3)
                                ELSE '0';
   s_can_tx_complete_message <= '0' WHEN unsigned(s_message_size_reg) >
                                         unsigned(s_transfer_size_reg)
                                    ELSE '1';
   s_require_n_pkt_end       <= s_bytes_send_cnt_reg(9) WHEN FX2_hi_speed = '1' ELSE
                                s_bytes_send_cnt_reg(6);
   s_send_payload_byte       <= '1' WHEN s_usbtmc_state_reg = SEND_PAYLOAD AND
                                         s_require_n_pkt_end = '0' AND
                                         s_real_payload_size_reg(32) = '0' AND
                                         s_valid_payload_byte = '1' ELSE '0';
   
   make_tx_fifo_regs : PROCESS( clock_48MHz , s_reset , s_tx_fifo_pop ,
                                s_tx_pop_data , s_tx_pop_size , s_tx_data_pop ,
                                s_send_payload_byte )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_tx_fifo_pop = '1') THEN
            s_tx_fifo_data_reg       <= s_tx_pop_data;
            s_tx_fifo_data_valid_reg <= '1';
            s_tx_fifo_size_bit_reg   <= s_tx_pop_size;
         ELSIF (s_reset = '1' OR
                s_tx_data_pop = '1' OR
                s_send_payload_byte = '1') THEN 
            s_tx_fifo_data_reg       <= (OTHERS => '0');
            s_tx_fifo_data_valid_reg <= '0';
            s_tx_fifo_size_bit_reg   <= '0';
         END IF;
      END IF;
   END PROCESS make_tx_fifo_regs;
   
   make_message_in_progress_reg : PROCESS( clock_48MHz , s_reset )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_message_in_progress_reg <= '0';
         ELSIF (s_usbtmc_state_reg = CHECK_FIFO_STATUS) THEN
            s_message_in_progress_reg <= NOT(s_can_tx_complete_message);
         END IF;
      END IF;
   END PROCESS make_message_in_progress_reg;
   
   make_outstanding_messages_reg : PROCESS( clock_48MHz , s_reset )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_outstanding_messages_reg <= (OTHERS => '1');
         ELSIF (s_usbtmc_state_reg = MESSAGE_UPDATE AND
                pending_message = '0') THEN
            s_outstanding_messages_reg <= unsigned(s_outstanding_messages_reg)-1;
         ELSIF (s_usbtmc_state_reg /= MESSAGE_UPDATE AND
                pending_message = '1') THEN
            s_outstanding_messages_reg <= unsigned(s_outstanding_messages_reg)+1;
         END IF;
      END IF;
   END PROCESS make_outstanding_messages_reg;
   
   make_message_size_reg : PROCESS( clock_48MHz , s_reset , s_usbtmc_state_reg ,
                                    s_send_payload_byte )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_usbtmc_state_reg = RESET_MESSAGE_SIZE OR
             s_reset = '1') THEN s_message_size_reg <= (OTHERS => '0');
         ELSIF (s_usbtmc_state_reg = GET_MESSAGE_SIZE_0 OR
                s_usbtmc_state_reg = GET_MESSAGE_SIZE_1 OR
                s_usbtmc_state_reg = GET_MESSAGE_SIZE_2 OR
                s_usbtmc_state_reg = GET_MESSAGE_SIZE_3) THEN
            IF (s_valid_payload_byte = '1') THEN
               s_message_size_reg <= X"00"&s_message_size_reg(31 DOWNTO 8);
            ELSIF (s_tx_data_pop = '1') THEN
               s_message_size_reg <= s_tx_fifo_data_reg&s_message_size_reg(31 DOWNTO 8);
            END IF;
         ELSIF (s_send_payload_byte = '1') THEN
            s_message_size_reg <= unsigned(s_message_size_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_message_size_reg;
   
   make_can_tx_complete_message_reg : PROCESS( clock_48MHz , s_reset ,
                                               s_usbtmc_state_reg ,
                                               s_can_tx_complete_message )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_can_tx_complete_message_reg <= '0';
         ELSIF (s_usbtmc_state_reg = CHECK_FIFO_STATUS) THEN
            s_can_tx_complete_message_reg <= s_can_tx_complete_message;
         END IF;
      END IF;
   END PROCESS make_can_tx_complete_message_reg;
   
   make_real_payload_size_reg : PROCESS( clock_48MHz , s_reset , s_usbtmc_state_reg ,
                                         s_can_tx_complete_message ,
                                         s_transfer_size_reg ,
                                         s_send_payload_byte )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_real_payload_size_reg <= (OTHERS => '1');
         ELSIF (s_usbtmc_state_reg = CHECK_FIFO_STATUS) THEN
            IF (s_can_tx_complete_message = '1') THEN
               s_real_payload_size_reg <= "0"&s_message_size_reg;
                                                     ELSE
               s_real_payload_size_reg <= "0"&s_transfer_size_reg;
            END IF;
         ELSIF ((s_header_insert_count_reg(4) = '1' AND
                 s_usbtmc_state_reg = SEND_HEADER) OR
                s_send_payload_byte = '1') THEN
            s_real_payload_size_reg <= unsigned(s_real_payload_size_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_real_payload_size_reg;
   
   make_header_insert_count_reg : PROCESS( clock_48MHz , s_reset , 
                                           s_usbtmc_state_reg )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_usbtmc_state_reg = CHECK_FIFO_STATUS OR
             s_reset = '1') THEN s_header_insert_count_reg <= "0"&X"A";
         ELSIF (s_usbtmc_state_reg = SEND_HEADER) THEN
            s_header_insert_count_reg <= unsigned(s_header_insert_count_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_header_insert_count_reg;
   
   make_bytes_send_cnt_reg : PROCESS( clock_48MHz , s_reset , 
                                      s_usbtmc_state_reg , s_send_payload_byte )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_usbtmc_state_reg = CHECK_FIFO_STATUS OR
             s_usbtmc_state_reg = SEND_PKT_END OR
             s_reset = '1') THEN s_bytes_send_cnt_reg <= (OTHERS => '0');
         ELSIF (s_usbtmc_state_reg = SEND_HEADER OR
                s_send_payload_byte = '1') THEN
            s_bytes_send_cnt_reg <= unsigned(s_bytes_send_cnt_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_bytes_send_cnt_reg;
   
   make_fx2_data_reg : PROCESS( clock_48MHz , s_header_insert_count_reg ,
                                s_Message_ID_reg , s_bTag_reg ,
                                s_real_payload_size_reg ,
                                s_can_tx_complete_message_reg ,
                                s_tx_fifo_data_reg )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         CASE (s_header_insert_count_reg) IS
            WHEN "01010" => s_data_out_reg <= s_Message_ID_reg;
            WHEN "01001" => s_data_out_reg <= s_bTag_reg;
            WHEN "01000" => s_data_out_reg <= NOT(s_bTag_reg);
            WHEN "00111" => s_data_out_reg <= X"00";
            WHEN "00110" => s_data_out_reg <= s_real_payload_size_reg(  7 DOWNTO  0 );
            WHEN "00101" => s_data_out_reg <= s_real_payload_size_reg( 15 DOWNTO  8 );
            WHEN "00100" => s_data_out_reg <= s_real_payload_size_reg( 23 DOWNTO 16 );
            WHEN "00011" => s_data_out_reg <= s_real_payload_size_reg( 31 DOWNTO 24 );
            WHEN "00010" => s_data_out_reg <= "0000000"&s_can_tx_complete_message_reg;
            WHEN "00001" |
                 "00000" |
                 "11111" => s_data_out_reg <= X"00";
            WHEN OTHERS  => s_data_out_reg <= s_tx_fifo_data_reg;
         END CASE;
      END IF;
   END PROCESS make_fx2_data_reg;
   
   make_n_we_reg : PROCESS( clock_48MHz , s_usbtmc_state_reg ,
                            s_send_payload_byte )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_usbtmc_state_reg = SEND_HEADER OR
             s_send_payload_byte = '1') THEN
            s_ep_n_we_reg <= '0';
                                               ELSE
            s_ep_n_we_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_n_we_reg;
   
   make_ep_pkt_end_reg : PROCESS( clock_48MHz , s_usbtmc_state_reg )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_usbtmc_state_reg = SEND_PKT_END) THEN s_ep_pkt_end_reg <= '0';
                                                ELSE s_ep_pkt_end_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_ep_pkt_end_reg;
   
   make_pip_regs : PROCESS( clock_48MHz )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         s_wf_push      <= wf_push;
         s_wf_push_data <= wf_push_data;
         s_wf_push_size <= wf_push_size_bit;
      END IF;
   END PROCESS make_pip_regs;

   tx_fifo : fifo_2kb
             PORT MAP ( clock      => clock_48MHz,
                        reset      => s_reset,
                        -- push port
                        push       => s_wf_push,
                        push_data  => s_wf_push_data,
                        push_size  => s_wf_push_size,
                        -- pop port
                        pop        => s_tx_fifo_pop,
                        pop_data   => s_tx_pop_data,
                        pop_size   => s_tx_pop_size,
                        -- control port
                        fifo_full  => wf_fifo_full,
                        fifo_empty => s_tx_fifo_empty );

--------------------------------------------------------------------------------
-- Here the payload copying is defined                                        --
--------------------------------------------------------------------------------
   
   s_resting_buffer_bytes <= unsigned(c_high_speed_packet_size) -
                             unsigned(s_nr_of_bytes_req_cnt_reg)
                                WHEN FX2_hi_speed = '1' ELSE
                             unsigned(c_full_speed_packet_size) -
                             unsigned(s_nr_of_bytes_req_cnt_reg);
   s_can_rx_all           <= '0' WHEN s_rx_payload_cnt_reg(31 DOWNTO 10) /=
                                      "0000000000000000000000" OR
                                      unsigned(s_resting_buffer_bytes) <
                                      unsigned(s_rx_payload_cnt_reg(9 DOWNTO 0))
                                 ELSE '1';
   s_req_payload_byte     <= '1' WHEN s_usbtmc_state_reg = REQUEST_PAYLOAD_BYTES AND
                                      s_rx_cnt_reg(9) = '0' ELSE '0';
   s_rx_payload_cnt_next  <= unsigned(s_rx_payload_cnt_reg) - 1;
   s_last_message_byte    <= s_rx_payload_cnt_next(32) AND
                             s_req_payload_byte AND
                             s_eom_bit_reg;
   
   make_nr_of_bytes_req_cnt_reg : PROCESS( clock_48MHz , s_usbtmc_state_reg )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_usbtmc_state_reg = WAIT_HEADER OR
             s_usbtmc_state_reg = CHECK_PAYLOAD_BYTES) THEN
            s_nr_of_bytes_req_cnt_reg <= (OTHERS => '0');
         ELSIF (s_request_header_byte = '1' OR
                s_req_payload_byte = '1') THEN
            s_nr_of_bytes_req_cnt_reg <= unsigned(s_nr_of_bytes_req_cnt_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_nr_of_bytes_req_cnt_reg;
   
   make_rx_payload_cnt_reg : PROCESS( clock_48MHz , s_reset , s_usbtmc_state_reg,
                                      s_transfer_size_reg )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_rx_payload_cnt_reg <= (OTHERS => '0');
         ELSIF (s_usbtmc_state_reg = INIT_COPY_PAYLOAD) THEN
            s_rx_payload_cnt_reg <= unsigned("0"&s_transfer_size_reg) - 1;
         ELSIF (s_req_payload_byte = '1') THEN
            s_rx_payload_cnt_reg <= s_rx_payload_cnt_next;
         END IF;
      END IF;
   END PROCESS make_rx_payload_cnt_reg;
   
   make_rx_cnt_reg : PROCESS( clock_48MHz , s_reset , s_usbtmc_state_reg )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_rx_cnt_reg <= (OTHERS => '0');
         ELSIF (s_usbtmc_state_reg = DET_RX_SIZE) THEN
            IF (s_can_rx_all = '1') THEN
               s_rx_cnt_reg <= s_rx_payload_cnt_reg(9 DOWNTO 0);
                                    ELSE
               s_rx_cnt_reg <= unsigned(s_resting_buffer_bytes)-1;
            END IF;
         ELSIF (s_req_payload_byte = '1') THEN
            s_rx_cnt_reg <= unsigned(s_rx_cnt_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_rx_cnt_reg;
   
   make_rx_pending_regs : PROCESS( clock_96MHz , s_reset )
   BEGIN
      IF (clock_96MHz'event AND (clock_96MHz = '1')) THEN
         IF (s_reset = '1') THEN s_rx_pending_pipe_reg <= "00";
                                 s_lmb_pipe_reg        <= "00";
         ELSIF (s_ena_out_ffs = '1') THEN
            s_rx_pending_pipe_reg(0) <= s_req_payload_byte;
            s_lmb_pipe_reg(0)        <= s_last_message_byte;
         ELSIF (s_ena_in_ffs = '1') THEN
            s_rx_pending_pipe_reg(1) <= s_rx_pending_pipe_reg(0);
            s_lmb_pipe_reg(1)        <= s_lmb_pipe_reg(0);
         END IF;
      END IF;
   END PROCESS make_rx_pending_regs;
   
   make_dummy_read_cnt_reg : PROCESS( clock_48MHz , s_reset ,
                                      s_usbtmc_state_reg )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_dummy_read_cnt_reg <= "000";
         ELSIF (s_usbtmc_state_reg = INIT_DUMMY_READ) THEN
            CASE (s_transfer_size_reg( 1 DOWNTO 0 )) IS
               WHEN  "01"  => s_dummy_read_cnt_reg <= "001";
               WHEN  "10"  => s_dummy_read_cnt_reg <= "000";
               WHEN OTHERS => s_dummy_read_cnt_reg <= "111";
            END CASE;
         ELSIF (s_usbtmc_state_reg = DO_DUMMY_READ) THEN
            s_dummy_read_cnt_reg <= unsigned(s_dummy_read_cnt_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_dummy_read_cnt_reg;
   
   read_fifo : fifo_2kb_ef
               PORT MAP ( clock      => clock_48MHz,
                          reset      => s_reset,
                          high_speed => FX2_hi_speed,
                          -- push port
                          push       => s_rx_pending_pipe_reg(1),
                          push_data  => s_data_in,
                          push_last  => s_lmb_pipe_reg(1),
                          -- pop port
                          pop        => rf_pop,
                          pop_data   => rf_pop_data,
                          pop_last   => s_rf_last_data_byte,
                          -- control port
                          fifo_full  => OPEN,
                          early_full => s_read_fifo_full,
                          fifo_empty => rf_fifo_empty );
                          
--------------------------------------------------------------------------------
-- Here the header read is defined                                            --
--------------------------------------------------------------------------------
   s_header_request_done <= '1' WHEN s_header_byte_request_id = X"B" ELSE '0';
   s_request_header_byte <= '1' WHEN s_usbtmc_state_reg = READ_HEADER ELSE '0';
   s_header_error_next   <= '0' WHEN s_usbtmc_state_reg = INIT_READ_HEADER OR
                                     s_reset = '1' 
                                ELSE
                            '1' WHEN s_known_Message_ID = '0' OR
                                     s_bTag_error = '1' OR
                                     s_reserved_3_error = '1' OR
                                     (s_zero_payload_size_reg = '1' AND
                                      s_header_byte_valid_id = X"8" AND
                                      s_header_byte_valid = '1')
                                ELSE s_header_error_reg;
   s_known_Message_ID    <= '1' WHEN s_Message_ID_reg = X"01" OR
                                     s_Message_ID_reg = X"02" OR
                                     s_Message_ID_reg = X"7E" OR
                                     s_Message_ID_reg = X"7F" ELSE '0';
   s_bTag_inverse        <= NOT(s_bTag_reg);
   s_bTag_error          <= '1' WHEN s_bTag_inverse /= s_data_in AND
                                     s_header_byte_valid = '1' AND
                                     s_header_byte_valid_id = X"2" ELSE '0';
   s_data_in_is_zero     <= '1' WHEN s_data_in = X"00" ELSE '0';
   s_reserved_3_error    <= '1' WHEN s_data_in_is_zero = '0' AND
                                     s_header_byte_valid = '1' AND
                                     (s_header_byte_valid_id = X"3" OR
                                      s_header_byte_valid_id = X"A" OR
                                      s_header_byte_valid_id = X"B") ELSE '0';
                                     

   make_header_byte_request_id : PROCESS( s_reset , clock_48MHz , 
                                          s_usbtmc_state_reg )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_usbtmc_state_reg = INIT_READ_HEADER OR
             s_reset = '1') THEN 
            s_header_byte_request_id <= X"0";
         ELSIF (s_usbtmc_state_reg = READ_HEADER) THEN
            s_header_byte_request_id <= unsigned(s_header_byte_request_id)+1;
         END IF;
      END IF;
   END PROCESS make_header_byte_request_id;
   
   make_pending_regs : PROCESS( s_reset , clock_96MHz , s_ena_out_ffs ,
                                s_request_header_byte , s_header_byte_request_id )
   BEGIN
      IF (clock_96MHz'event AND (clock_96MHz = '1')) THEN
         IF (s_reset = '1') THEN s_header_byte_request_pending <= '0';
                                 s_header_byte_pending_id      <= X"0";
         ELSIF (s_ena_out_ffs = '1') THEN
            s_header_byte_request_pending <= s_request_header_byte;
            s_header_byte_pending_id      <= s_header_byte_request_id;
         END IF;
      END IF;
   END PROCESS make_pending_regs;
   
   make_valid_regs : PROCESS( s_reset , clock_96MHz , s_ena_in_ffs ,
                              s_header_byte_request_pending ,
                              s_header_byte_pending_id )
   BEGIN
      IF (clock_96MHz'event AND (clock_96MHz = '1')) THEN
         IF (s_reset = '1') THEN s_header_byte_valid    <= '0';
                                 s_header_byte_valid_id <= X"0";
         ELSIF (s_ena_in_ffs = '1') THEN
            s_header_byte_valid    <= s_header_byte_request_pending;
            s_header_byte_valid_id <= s_header_byte_pending_id;
         END IF;
      END IF;
   END PROCESS make_valid_regs;
   
   make_header_error_reg : PROCESS( clock_48MHz , s_header_error_next )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         s_header_error_reg <= s_header_error_next;
      END IF;
   END PROCESS make_header_error_reg;
   
   make_message_id_reg : PROCESS( clock_48MHz , s_reset , s_data_in ,
                                  s_header_byte_valid , s_header_byte_valid_id )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_Message_ID_reg <= X"01";
         ELSIF (s_header_byte_valid = '1' AND
                s_header_byte_valid_id = X"0") THEN
            s_Message_ID_reg <= s_data_in;
         END IF;
      END IF;
   END PROCESS make_message_id_reg;
   
   make_btag_reg : PROCESS( clock_48MHz , s_reset , s_data_in ,
                            s_header_byte_valid , s_header_byte_valid_id )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_bTag_reg <= X"00";
         ELSIF (s_header_byte_valid = '1' AND
                s_header_byte_valid_id = X"1") THEN
            s_bTag_reg <= s_data_in;
         END IF;
      END IF;
   END PROCESS make_btag_reg;
   
   make_transfer_size_reg : PROCESS( clock_48MHz , s_reset , s_data_in ,
                                     s_header_byte_valid , s_header_byte_valid_id )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_transfer_size_reg <= (OTHERS => '0');
         ELSIF (s_header_byte_valid = '1') THEN
            CASE (s_header_byte_valid_id) IS
               WHEN  X"4"  => s_transfer_size_reg(  7 DOWNTO  0 ) <= s_data_in;
               WHEN  X"5"  => s_transfer_size_reg( 15 DOWNTO  8 ) <= s_data_in;
               WHEN  X"6"  => s_transfer_size_reg( 23 DOWNTO 16 ) <= s_data_in;
               WHEN  X"7"  => s_transfer_size_reg( 31 DOWNTO 24 ) <= s_data_in;
               WHEN OTHERS => NULL;
            END CASE;
         END IF;
      END IF;
   END PROCESS make_transfer_size_reg;
   
   make_zero_payload_size_reg : PROCESS( clock_48MHz , s_reset , 
                                         s_data_in_is_zero , s_header_byte_valid ,
                                         s_header_byte_valid_id ,
                                         s_usbtmc_state_reg )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_usbtmc_state_reg = INIT_READ_HEADER OR
             s_reset = '1') THEN s_zero_payload_size_reg <= '1';
         ELSIF ((s_header_byte_valid_id = X"4" OR
                 s_header_byte_valid_id = X"5" OR
                 s_header_byte_valid_id = X"6" OR
                 s_header_byte_valid_id = X"7") AND
                s_data_in_is_zero = '0') THEN s_zero_payload_size_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_zero_payload_size_reg;
   
   make_eom_bit_reg : PROCESS( clock_48MHz , s_reset , s_header_byte_valid ,
                               s_header_byte_valid_id , s_data_in )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_eom_bit_reg                <= '1';
                                 s_rx_message_in_progress_reg <= '0';
         ELSIF (s_header_byte_valid = '1' AND
                s_header_byte_valid_id = X"8") THEN
            IF (s_Message_ID_reg = X"01") THEN
               s_rx_message_in_progress_reg <= NOT(s_data_in(0));
               s_eom_bit_reg                <= s_data_in(0);
                                          ELSE
               s_rx_message_in_progress_reg <= '0';
               s_eom_bit_reg                <= '1';
            END IF;
         END IF;
      END IF;
   END PROCESS make_eom_bit_reg;
   
--------------------------------------------------------------------------------
-- Define the synchronized clock signal for this module                       --
--------------------------------------------------------------------------------
   s_reset <= s_reset_count_reg(2);
   
   make_reset_count_reg : PROCESS( cpu_reset , clock_48MHz , FX2_n_ready ,
                                   s_reset_count_reg , s_reset )
   BEGIN
      IF (cpu_reset = '1' OR
          FX2_n_ready = '1') THEN s_reset_count_reg <= (OTHERS => '1');
      ELSIF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN 
            s_reset_count_reg <= unsigned(s_reset_count_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_reset_count_reg;
   
--------------------------------------------------------------------------------
-- Define the clock of the FX2 FIFOs                                          --
--------------------------------------------------------------------------------
   make_fifo_clock_reg : PROCESS( clock_96MHz , cpu_reset , s_fifo_clock_reg )
   BEGIN
      IF (cpu_reset = '1') THEN s_fifo_clock_reg <= '1';
      ELSIF (clock_96MHz'event AND (clock_96MHz = '1')) THEN
         s_fifo_clock_reg <= NOT(s_fifo_clock_reg);
      END IF;
   END PROCESS make_fifo_clock_reg;
   
--------------------------------------------------------------------------------
--- Define the fx2 data reporting                                            ---
--------------------------------------------------------------------------------
   make_fx2_data_nibble : PROCESS( clock_48MHz , s_fx2_data_select , 
                                   status_nibble , s_bTag_reg )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         CASE (s_fx2_data_select) IS
            WHEN  X"C"  => s_fx2_data_nibble <= s_bTag_reg( 3 DOWNTO 0 );
            WHEN  X"D"  => s_fx2_data_nibble <= s_bTag_reg( 7 DOWNTO 4 );
            WHEN  X"F"  => s_fx2_data_nibble <= status_nibble;
            WHEN OTHERS => s_fx2_data_nibble <= X"F";
         END CASE;
      END IF;
   END PROCESS make_fx2_data_nibble;
   
   make_ind_pipe_reg : PROCESS( clock_48MHz , s_reset , s_fx2_data_select )
   BEGIN
      IF (clock_48MHz'event AND (clock_48MHz = '1')) THEN
         IF (s_reset = '1') THEN s_ind_pipe_reg <= "00";
                            ELSE
            s_ind_pipe_reg(1) <= s_ind_pipe_reg(0);
            IF (s_fx2_data_select = X"E") THEN
               s_ind_pipe_reg(0) <= '1';
                                          ELSE
               s_ind_pipe_reg(0) <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS make_ind_pipe_reg;
   
--------------------------------------------------------------------------------
-- Define the IOB flipflops and tri-state buffers used                        --
--------------------------------------------------------------------------------
   gen_data_nibble : FOR n IN 3 DOWNTO 0 GENERATE
      in_ff : FD
              GENERIC MAP ( INIT => '1' )
              PORT MAP ( Q => s_fx2_data_select(n),
                         C => clock_48MHz,
                         D => data_select(n) );
      out_ff : FD
               GENERIC MAP ( INIT => '1' )
               PORT MAP ( Q => data_nibble(n),
                          C => clock_48MHz,
                          D => s_fx2_data_nibble(n) );
   END GENERATE gen_data_nibble;
   
   IFCLK_FF : FD_1
              GENERIC MAP ( INIT => '0' )
              PORT MAP ( Q => EP_IFCLOCK,
                         C => clock_96MHz,
                         D => s_fifo_clock_reg );
   EP8_flag_FF : FDE
                 GENERIC MAP ( INIT => '0' )
                 PORT MAP ( Q => s_EP8_not_empty,
                            CE => s_ena_in_ffs,
                            C => clock_96MHz,
                            D => EP8_n_empty );
   EP6_flag_ff : FDE
                 GENERIC MAP ( INIT => '0' )
                 PORT MAP( Q  => s_EP6_not_full,
                           CE => s_ena_in_ffs,
                           C  => clock_96MHz,
                           D  => EP6_n_full );
   EP_n_WE_FF : FDE
                GENERIC MAP ( INIT => '0' )
                PORT MAP ( Q  => EP_n_WE,
                           CE => s_ena_out_ffs,
                           C  => clock_96MHz,
                           D  => s_ep_n_we_reg );
   EP_n_PKTEND_FF : FDE
                    GENERIC MAP ( INIT => '0' )
                    PORT MAP ( Q  => EP_n_PKTEND,
                               CE => s_ena_out_ffs,
                               C  => clock_96MHz,
                               D  => s_ep_pkt_end_reg );
   make_addr_ff : FOR n IN 1 DOWNTO 0 GENERATE
      one_ff : FDE
               GENERIC MAP ( INIT => '0' )
               PORT MAP ( Q => EP_address(n),
                          CE => s_ena_out_ffs,
                          C => clock_96MHz,
                          D => s_endpoint_addr_next(n) );
   END GENERATE make_addr_ff;
   n_oe_ff : FDE
             GENERIC MAP ( INIT => '0' )
             PORT MAP ( Q => EP_n_OE,
                        CE => s_ena_out_ffs,
                        C => clock_96MHz,
                        D => s_endpoint_n_oe_next );
   n_re_ff : FDE
             GENERIC MAP ( INIT => '0' )
             PORT MAP ( Q => EP_n_RE,
                        CE => s_ena_out_ffs,
                        C => clock_96MHz,
                        D => s_endpoint_n_re_next );
   make_data_in_ff : FOR n IN 7 DOWNTO 0 GENERATE
      one_ff : FDE
               GENERIC MAP ( INIT => '0' )
               PORT MAP ( Q => s_data_in(n),
                          CE => s_ena_data_in,
                          C => clock_96MHz,
                          D => EP_data_in(n) );
      out_ff : FDE
               GENERIC MAP ( INIT => '0' )
               PORT MAP ( Q  => EP_data_out(n),
                          CE => s_ena_out_ffs,
                          C  => clock_96MHz,
                          D  => s_data_out_reg(n) );
      tri_ff : FDE
               GENERIC MAP ( INIT => '0' )
               PORT MAP( Q  => EP_n_tri_out(n),
                         CE => s_ena_out_ffs,
                         C  => clock_96MHz,
                         D  => s_ep_n_tri_next );
   END GENERATE make_data_in_ff;
END xilinx;
