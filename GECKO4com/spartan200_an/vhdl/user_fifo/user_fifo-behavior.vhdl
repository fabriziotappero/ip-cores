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

--memory map:
-- 0x00 -> TX-fifo write data (WO)
-- 0x01 -> TX-fifo write message size (WO)
-- 0x02 -> Nr. of bytes in TX-fifo (RO)
-- 0x03 -> Max. size in bytes of TX-fifo (RO)
-- 0x04 -> Nr. of shorts in TX-fifo (RO)
-- 0x05 -> Max. size in shorts of TX-fifo (RO)
-- 0x06 -> Nr. of words in TX-fifo (RO)
-- 0x07 -> Max. size in words of TX-fifo (RO)
-- 0x08 -> RX-fifo read data (RO)
-- 0x09 -> RX-fifo read data (RO)
-- 0x0A -> Nr. of bytes in RX-fifo (RO)
-- 0x0B -> Max. size in bytes of RX-fifo (RO)
-- 0x0C -> Nr. of shorts in RX-fifo (RO)
-- 0x0D -> Max. size in shorts of RX-fifo (RO)
-- 0x0E -> Nr. of words in RX-fifo (RO)
-- 0x0F -> Max. size in words of RX-fifo (RO)

ARCHITECTURE no_target_specific OF user_fifo IS

   COMPONENT fifo_4kb_16w_8r
      PORT ( clock      : IN  std_logic;
             reset      : IN  std_logic;
             -- push port
             push       : IN  std_logic;
             push_data  : IN  std_logic_vector( 15 DOWNTO 0 );
             push_size  : IN  std_logic;
             -- pop port
             pop        : IN  std_logic;
             pop_data   : OUT std_logic_vector(  7 DOWNTO 0 );
             pop_size   : OUT std_logic;
             -- control port
             fifo_full  : OUT std_logic;
             fifo_empty : OUT std_logic;
             byte_cnt   : OUT std_logic_vector( 12 DOWNTO 0 ) );
   END COMPONENT;
   
   COMPONENT fifo_4kb_8w_16r
      PORT ( clock      : IN  std_logic;
             reset      : IN  std_logic;
             -- push port
             push       : IN  std_logic;
             push_data  : IN  std_logic_vector(  7 DOWNTO 0 );
             push_last  : IN  std_logic;
             -- pop port
             pop        : IN  std_logic;
             pop_data   : OUT std_logic_vector( 15 DOWNTO 0 );
             pop_last   : OUT std_logic_vector(  1 DOWNTO 0 );
             -- control port
             fifo_full  : OUT std_logic;
             fifo_empty : OUT std_logic;
             byte_cnt   : OUT std_logic_vector( 12 DOWNTO 0 ) );
   END COMPONENT;
   
   TYPE STATE_TYPE IS (IDLE,SIGNAL_DONE,SIGNAL_ERROR,SIGNAL_REQUEST,
                       GET_SIZE_0,GET_SIZE_1,GET_SIZE_2,GET_SIZE_3,
                       INIT_COPY,FLUSH_TX,COPY_TX_DATA,SIGNAL_MESSAGE,
                       COPY_RX_DATA,INSERT_DUMMY,SIGNAL_AVAILABLE);
   
   SIGNAL s_tx_fifo_byte_count_value   : std_logic_vector( 12 DOWNTO 0 );
   SIGNAL s_n_bus_error_next           : std_logic;
   SIGNAL s_tx_fifo_full               : std_logic;
   SIGNAL s_tx_fifo_empty              : std_logic;
   SIGNAL s_n_bus_error_reg            : std_logic;
   SIGNAL s_burst_cnt_reg              : std_logic_vector(  9 DOWNTO 0 );
   SIGNAL s_burst_cnt_next             : std_logic_vector(  9 DOWNTO 0 );
   SIGNAL s_n_end_reg                  : std_logic;
   SIGNAL s_is_my_write_burst_reg      : std_logic;
   SIGNAL s_do_push                    : std_logic;
   
   SIGNAL s_fifo_state_reg             : STATE_TYPE;
   SIGNAL s_tx_pop                     : std_logic;
   SIGNAL s_tx_pop_size                : std_logic;
   SIGNAL s_tx_pop_data                : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_tx_payload_cnt_reg         : std_logic_vector( 32 DOWNTO 0 );

   SIGNAL s_rx_fifo_byte_count_value   : std_logic_vector( 12 DOWNTO 0 );
   SIGNAL s_rx_push                    : std_logic;
   SIGNAL s_rx_fifo_full               : std_logic;
   SIGNAL s_rx_byte_cnt_reg            : std_logic_vector(  1 DOWNTO 0 );
   SIGNAL s_pop_data                   : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_pop_last                   : std_logic;
   SIGNAL s_dummy_data_reg             : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_rx_fifo_empty              : std_logic;
   SIGNAL s_rx_fifo_pop                : std_logic;
   SIGNAL s_rx_fifo_data               : std_logic_vector( 15 DOWNTO 0 );
   SIGNAL s_rx_fifo_last               : std_logic_vector(  1 DOWNTO 0 );
   SIGNAL s_reset                      : std_logic;
   
BEGIN
   s_reset <= reset OR NOT(n_bus_reset);

--------------------------------------------------------------------------------
--- Here the signalling is defined                                           ---
--------------------------------------------------------------------------------
   make_error_irq : PROCESS( clock , s_do_push , s_tx_fifo_full ,
                             s_rx_fifo_empty , s_rx_fifo_pop )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF ((s_do_push = '1' AND
              s_tx_fifo_full = '1') OR
             (s_rx_fifo_empty = '1' AND
              s_rx_fifo_pop = '1') OR
             (s_fifo_state_reg = FLUSH_TX)) THEN error_irq <= '1';
                                            ELSE error_irq <= '0';
         END IF;
      END IF;
   END PROCESS make_error_irq;
   
   make_data_req_irg : PROCESS( clock , reset , s_fifo_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '0' AND
             s_fifo_state_reg = SIGNAL_REQUEST) THEN data_request_irq <= '1';
                                                ELSE data_request_irq <= '0';
         END IF;
      END IF;
   END PROCESS make_data_req_irg;
   
   make_data_available_irq : PROCESS( clock , reset , s_fifo_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '0' AND
             s_fifo_state_reg = SIGNAL_AVAILABLE) THEN data_available_irq <= '1';
                                                  ELSE data_available_irq <= '0';
         END IF;
      END IF;
   END PROCESS make_data_available_irq;

--------------------------------------------------------------------------------
--- Here the bus handling is defined                                         ---
--------------------------------------------------------------------------------
   n_start_send           <= '0' WHEN bus_address( 5 DOWNTO 4 ) = "00" AND
                                      n_start_transmission = '0' AND
                                      read_n_write = '0' AND
                                      s_n_bus_error_next = '1' ELSE '1';
   n_bus_error            <= s_n_bus_error_reg;
   n_end_transmission_out <= '0' WHEN s_n_bus_error_reg = '0' OR
                                      s_n_end_reg = '0' ELSE '1';
   make_data_valid : PROCESS( clock , reset , n_bus_reset , s_burst_cnt_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '0' AND
             n_bus_reset = '1' AND
             s_burst_cnt_reg(9) = '0') THEN 
            IF (s_rx_fifo_pop = '1' AND
                s_rx_fifo_last /= "00") THEN n_data_valid_out <= "01";
                                        ELSE n_data_valid_out <= "00";
            END IF;
                                       ELSE n_data_valid_out <= "11";
         END IF;
      END IF;
   END PROCESS make_data_valid;

   s_n_bus_error_next <= '0' WHEN bus_address( 5 DOWNTO 4) = "00" AND
                                  n_start_transmission = '0' AND
                                  ((bus_address(3 DOWNTO 1) = "000" AND
                                    (read_n_write = '1' OR
                                     s_tx_fifo_full = '1')) OR
                                   (bus_address(3 DOWNTO 1) /= "000" AND
                                    read_n_write = '0')) ELSE '1';
   s_burst_cnt_next   <= unsigned(s_burst_cnt_reg) - 1;
   
   make_data_out : PROCESS( clock , bus_address , s_tx_fifo_byte_count_value )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (bus_address(5 DOWNTO 4) = "00") THEN
            CASE (bus_address( 3 DOWNTO 0 )) IS
               WHEN  X"2"  => data_out <= "000"&s_tx_fifo_byte_count_value;
               WHEN  X"3"  => data_out <= X"1000";
               WHEN  X"4"  => data_out <= X"0"&s_tx_fifo_byte_count_value( 12 DOWNTO 1);
               WHEN  X"5"  => data_out <= X"0800";
               WHEN  X"6"  => data_out <= X"0"&"0"&s_tx_fifo_byte_count_value( 12 DOWNTO 2);
               WHEN  X"7"  => data_out <= X"0400";
               WHEN  X"8" |
                     X"9"  => data_out <= s_rx_fifo_data;
               WHEN  X"A"  => data_out <= "000"&s_rx_fifo_byte_count_value;
               WHEN  X"B"  => data_out <= X"1000";
               WHEN  X"C"  => data_out <= X"0"&s_rx_fifo_byte_count_value( 12 DOWNTO 1 );
               WHEN  X"D"  => data_out <= X"0800";
               WHEN  X"E"  => data_out <= X"0"&"0"&s_rx_fifo_byte_count_value( 12 DOWNTO 2 );
               WHEN  X"F"  => data_out <= X"0400";
               WHEN OTHERS => data_out <= X"0000";
            END CASE;
                                             ELSE
            data_out <= X"0000";
         END IF;
      END IF;
   END PROCESS make_data_out;
   
   make_n_bus_error_reg : PROCESS( clock , s_n_bus_error_next )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         s_n_bus_error_reg <= s_n_bus_error_next;
      END IF;
   END PROCESS make_n_bus_error_reg;
   
   make_n_end_reg : PROCESS( clock , reset , n_bus_reset , s_burst_cnt_reg ,
                             s_burst_cnt_next )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '0' AND
             n_bus_reset = '1' AND
             s_burst_cnt_reg(9) = '0' AND
             s_burst_cnt_next(9) = '1') THEN s_n_end_reg <= '0';
                                        ELSE s_n_end_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_n_end_reg;
   
   make_burst_cnt_reg : PROCESS( clock , reset , n_bus_reset , s_burst_cnt_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (n_bus_reset = '0' OR
             reset = '1') THEN s_burst_cnt_reg <= (OTHERS => '1');
         ELSIF (bus_address( 5 DOWNTO 4 ) = "00" AND
                n_start_transmission = '0' AND
                read_n_write = '1' AND
                s_n_bus_error_next = '1') THEN
            s_burst_cnt_reg <= "0"&burst_size;
         ELSIF (s_burst_cnt_reg(9) = '0') THEN
            s_burst_cnt_reg <= s_burst_cnt_next;
         END IF;
      END IF;
   END PROCESS make_burst_cnt_reg;
   
   make_is_my_write_burst_reg : PROCESS( clock , reset , n_bus_reset )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             n_bus_reset = '0' OR
             n_end_transmission_in = '0') THEN s_is_my_write_burst_reg <= '0';
         ELSIF (bus_address( 5 DOWNTO 4 ) = "00" AND
                n_start_transmission = '0' AND
                read_n_write = '0' AND
                s_n_bus_error_next = '1') THEN s_is_my_write_burst_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_is_my_write_burst_reg;
   
--------------------------------------------------------------------------------
--- Here the usbtmc interface is defined                                     ---
--------------------------------------------------------------------------------
   command_done  <= '1' WHEN s_fifo_state_reg = SIGNAL_DONE OR
                             s_fifo_state_reg = SIGNAL_ERROR ELSE '0';
   command_error <= '1' WHEN s_fifo_state_reg = SIGNAL_ERROR ELSE '0';
   message_available <= '1' WHEN s_fifo_state_reg = SIGNAL_MESSAGE ELSE '0';
   
   make_state_machine : PROCESS( clock , reset , s_fifo_state_reg )
      VARIABLE v_next_state : STATE_TYPE;
   BEGIN
      CASE (s_fifo_state_reg) IS
         WHEN IDLE                        => IF (start_command = '1' AND
                                                 command_id = "0011100") THEN
                                                v_next_state := SIGNAL_REQUEST;
                                             ELSIF ((start_command = '1' AND
                                                     command_id = "0011011") OR
                                                    (transparent_mode = '1' AND
                                                     pop_empty = '0')) THEN
                                                v_next_state := SIGNAL_AVAILABLE;
                                             ELSIF (transparent_mode = '1' AND
                                                    s_tx_fifo_empty = '0') THEN
                                                v_next_state := SIGNAL_MESSAGE;
                                                                  ELSE
                                                v_next_state := IDLE;
                                             END IF;
         WHEN SIGNAL_REQUEST              |
              SIGNAL_MESSAGE              => v_next_state := GET_SIZE_0;
         WHEN GET_SIZE_0                  => IF (s_tx_fifo_empty = '0') THEN
                                                IF (s_tx_pop_size = '0') THEN
                                                   v_next_state := FLUSH_TX;
                                                                         ELSE
                                                   v_next_state := GET_SIZE_1;
                                                END IF;
                                                                        ELSE
                                                v_next_state := GET_SIZE_0;
                                             END IF;
         WHEN GET_SIZE_1                  => IF (s_tx_fifo_empty = '0') THEN
                                                v_next_state := GET_SIZE_2;
                                                                        ELSE
                                                v_next_state := GET_SIZE_1;
                                             END IF;
         WHEN GET_SIZE_2                  => IF (s_tx_fifo_empty = '0') THEN
                                                v_next_state := GET_SIZE_3;
                                                                        ELSE
                                                v_next_state := GET_SIZE_2;
                                             END IF;
         WHEN GET_SIZE_3                  => IF (s_tx_fifo_empty = '0') THEN
                                                v_next_state := INIT_COPY;
                                                                        ELSE
                                                v_next_state := GET_SIZE_3;
                                             END IF;
         WHEN INIT_COPY                   => v_next_state := COPY_TX_DATA;
         WHEN COPY_TX_DATA                => IF (s_tx_payload_cnt_reg(32) = '1') THEN
                                                v_next_state := SIGNAL_DONE;
                                                                                 ELSE
                                                v_next_state := COPY_TX_DATA;
                                             END IF;
         WHEN FLUSH_TX                    => IF (s_tx_fifo_empty = '1') THEN
                                                v_next_state := SIGNAL_ERROR;
                                                                        ELSE
                                                v_next_state := FLUSH_TX;
                                             END IF;
         WHEN SIGNAL_AVAILABLE            => v_next_state := COPY_RX_DATA;
         WHEN COPY_RX_DATA                => IF (s_rx_push = '1' AND
                                                 pop_last = '1') THEN
                                                v_next_state := INSERT_DUMMY;
                                                                 ELSE
                                                v_next_state := COPY_RX_DATA;
                                             END IF;
         WHEN INSERT_DUMMY                => IF (s_rx_byte_cnt_reg = "00") THEN
                                                v_next_state := SIGNAL_DONE;
                                                                           ELSE
                                                v_next_state := INSERT_DUMMY;
                                             END IF;
         WHEN OTHERS                      => v_next_state := IDLE;
      END CASE;
      IF (clock'event AND (clock = '1')) THEN 
         IF (reset = '1') THEN s_fifo_state_reg <= IDLE;
                          ELSE s_fifo_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_state_machine;
   
   make_tx_payload_cnt_reg : PROCESS( clock , reset , s_tx_payload_cnt_reg )
      VARIABLE v_pop_data : std_logic_vector( 7 DOWNTO 0 );
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_tx_payload_cnt_reg <= (OTHERS => '1');
         ELSIF (s_tx_fifo_empty = '0' AND
                (s_fifo_state_reg = GET_SIZE_0 OR
                 s_fifo_state_reg = GET_SIZE_1 OR
                 s_fifo_state_reg = GET_SIZE_2 OR
                 s_fifo_state_reg = GET_SIZE_3)) THEN
            IF (s_tx_pop = '1') THEN v_pop_data := s_tx_pop_data;
                                ELSE v_pop_data := X"00";
            END IF;
            s_tx_payload_cnt_reg(32) <= '0';
            s_tx_payload_cnt_reg(31 DOWNTO 24) <= v_pop_data;
            s_tx_payload_cnt_reg(23 DOWNTO  0) <= s_tx_payload_cnt_reg(31 DOWNTO 8 );
         ELSIF (s_tx_pop = '1' OR
                s_fifo_state_reg = INIT_COPY) THEN
            s_tx_payload_cnt_reg <= unsigned(s_tx_payload_cnt_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_tx_payload_cnt_reg;
   
   make_rx_byte_cnt_reg : PROCESS( clock , reset , s_fifo_state_reg , s_rx_push)
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             s_fifo_state_reg = IDLE) THEN s_rx_byte_cnt_reg <= "00";
         ELSIF (s_rx_push = '1') THEN
            s_rx_byte_cnt_reg <= unsigned(s_rx_byte_cnt_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_rx_byte_cnt_reg;
   
--------------------------------------------------------------------------------
--- Here the tx-fifo is defined                                              ---
--------------------------------------------------------------------------------
   s_do_push     <= '1' WHEN s_is_my_write_burst_reg = '1' AND
                             n_data_valid_in = "00" ELSE '0';
   s_tx_pop      <= '1' WHEN s_tx_fifo_empty = '0' AND
                             (s_fifo_state_reg = FLUSH_TX OR
                              (s_tx_pop_size = '1' AND
                               (s_fifo_state_reg = GET_SIZE_0 OR
                                s_fifo_state_reg = GET_SIZE_1 OR
                                s_fifo_state_reg = GET_SIZE_2 OR
                                s_fifo_state_reg = GET_SIZE_3)) OR
                              (s_fifo_state_reg = COPY_TX_DATA AND
                               s_tx_payload_cnt_reg(32) = '0' AND
                               fifo_full = '0')) ELSE '0';
   s_rx_push     <= '1' WHEN (s_fifo_state_reg = COPY_RX_DATA AND
                              s_rx_fifo_full = '0' AND
                              pop_empty = '0') OR
                             (s_fifo_state_reg = INSERT_DUMMY AND
                              s_rx_byte_cnt_reg /= "00") ELSE '0';
   pop           <= '1' WHEN s_fifo_state_reg = COPY_RX_DATA AND
                             s_rx_push = '1' ELSE '0';
   s_pop_data    <= s_dummy_data_reg WHEN s_fifo_state_reg = INSERT_DUMMY ELSE pop_data;
   s_pop_last    <= '1' WHEN s_fifo_state_reg = INSERT_DUMMY ELSE pop_last;
   s_rx_fifo_pop <= '1' WHEN s_burst_cnt_reg(9) = '0' AND
                             (bus_address( 3 DOWNTO 0 ) = X"8" OR
                              bus_address( 3 DOWNTO 0 ) = X"9") ELSE '0';
   
   make_scpi_fifo_if : PROCESS( clock , reset )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             s_tx_pop = '0') THEN push      <= '0';
                                  push_size <= '0';
                                  push_data <= (OTHERS => '0');
                             ELSE
            IF (s_fifo_state_reg = FLUSH_TX) THEN push <= '0';
                                             ELSE push <= '1';
            END IF;
            push_size <= s_tx_pop_size;
            push_data <= s_tx_pop_data;
         END IF;
      END IF;
   END PROCESS make_scpi_fifo_if;
   
   make_dummy_data_reg : PROCESS( clock , reset , pop_data , pop_last ,
                                  s_rx_push )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_dummy_data_reg <= X"00";
         ELSIF (s_rx_push = '1' AND
                pop_last = '1') THEN s_dummy_data_reg <= NOT(pop_data);
         END IF;
      END IF;
   END PROCESS make_dummy_data_reg;

   tx_fifo : fifo_4kb_16w_8r
             PORT MAP ( clock      => clock,
                        reset      => s_reset,
                        -- push port
                        push       => s_do_push,
                        push_data  => data_in,
                        push_size  => bus_address(0),
                        -- pop port
                        pop        => s_tx_pop,
                        pop_data   => s_tx_pop_data,
                        pop_size   => s_tx_pop_size,
                        -- control port
                        fifo_full  => s_tx_fifo_full,
                        fifo_empty => s_tx_fifo_empty,
                        byte_cnt   => s_tx_fifo_byte_count_value );

   rx_fifo : fifo_4kb_8w_16r
             PORT MAP ( clock      => clock,
                        reset      => s_reset,
                        -- push port
                        push       => s_rx_push,
                        push_data  => s_pop_data,
                        push_last  => s_pop_last,
                        -- pop port
                        pop        => s_rx_fifo_pop,
                        pop_data   => s_rx_fifo_data,
                        pop_last   => s_rx_fifo_last,
                        -- control port
                        fifo_full  => s_rx_fifo_full,
                        fifo_empty => s_rx_fifo_empty,
                        byte_cnt   => s_rx_fifo_byte_count_value );


END no_target_specific;
