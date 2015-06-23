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

ARCHITECTURE xilinx OF flash_if IS

   COMPONENT FDE
      GENERIC ( INIT : bit );
      PORT ( Q   : OUT std_logic;
             C   : IN  std_logic;
             CE  : IN  std_logic;
             D   : IN  std_logic );
   END COMPONENT;

   COMPONENT FDE_1
      GENERIC ( INIT : bit );
      PORT ( Q   : OUT std_logic;
             C   : IN  std_logic;
             CE  : IN  std_logic;
             D   : IN  std_logic );
   END COMPONENT;

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
   
   COMPONENT RAMB16_S9_S18
      PORT ( DOA     : OUT std_logic_vector( 7 DOWNTO 0 );
             DOPA    : OUT std_logic_vector( 0 DOWNTO 0 );
             ADDRA   : IN  std_logic_vector(10 DOWNTO 0 );
             CLKA    : IN  std_logic;
             DIA     : IN  std_logic_vector( 7 DOWNTO 0 );
             DIPA    : IN  std_logic_vector( 0 DOWNTO 0 );
             ENA     : IN  std_logic;
             SSRA    : IN  std_logic;
             WEA     : IN  std_logic;
             DOB     : OUT std_logic_vector(15 DOWNTO 0 );
             DOPB    : OUT std_logic_vector( 1 DOWNTO 0 );
             ADDRB   : IN  std_logic_vector( 9 DOWNTO 0 );
             CLKB    : IN  std_logic;
             DIB     : IN  std_logic_vector(15 DOWNTO 0 );
             DIPB    : IN  std_logic_vector( 1 DOWNTO 0 );
             ENB     : IN  std_logic;
             SSRB    : IN  std_logic;
             WEB     : IN  std_logic );
   END COMPONENT;

   TYPE FLASH_STATE_TYPE IS (RESET_STATE , SET_AUTOSELECT , READ_ID , IDLE ,
                             CHECK_ID , AUTO_NOP , RESET_AUTO , RESET_NOP ,
                             READ_HW , CHECK_HW , SIGNAL_DONE , INIT_ERASE_S1 ,
                             ERASE_S1 , WAIT_BUSY_LO , WAIT_BUSY_HI , NOP_READ,
                             INIT_READ , COPY_PAYLOAD , CHECK_SIZE , PLAY_WRITE ,
                             SIGNAL_ERROR , RESET_FIFO , INIT_WRITE , DO_WRITE ,
                             WAIT_READY_LO , WAIT_READY_HI , WRITE_UPDATE ,
                             INIT_CHECK_EMPTY , CHECK_EMPTY , DO_PUD_WRITE ,
                             SET_PUD_SIZE_1 , SET_PUD_SIZE_2 , DO_PUD_READ ,
                             COPY_PUD_DATA , NEXT_SECTOR , SIGNAL_INIT );
   
   CONSTANT c_vga_offset          : std_logic_vector( 4 DOWNTO 0 ) := "10010";
   
   SIGNAL s_flash_state_reg       : FLASH_STATE_TYPE;
   SIGNAL s_delay_counter_reg     : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_player_count_reg      : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_command_byte          : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_byte_address          : std_logic_vector(20 DOWNTO 0 );
   SIGNAL s_flash_data_in         : std_logic_vector(15 DOWNTO 0 );
   SIGNAL s_data_out_next         : std_logic_vector(15 DOWNTO 0 );
   SIGNAL s_tri_data_out          : std_logic;
   SIGNAL s_flash_n_ce            : std_logic;
   SIGNAL s_flash_n_oe            : std_logic;
   SIGNAL s_flash_n_we            : std_logic;
   SIGNAL s_state_tick            : std_logic;
   
   SIGNAL s_sector_address_reg    : std_logic_vector(20 DOWNTO 16);
   SIGNAL s_pud_sector_address    : std_logic_vector(20 DOWNTO 16);
   SIGNAL s_in_sector_address_reg : std_logic_vector(15 DOWNTO  1);
   SIGNAL s_flash_mounted_reg     : std_logic;
   SIGNAL s_flash_top_boot_reg    : std_logic;
   SIGNAL s_flash_sec1_empty_reg  : std_logic;
   SIGNAL s_next_address          : std_logic;
   SIGNAL s_next_in_sector_addr   : std_logic_vector(16 DOWNTO 1);
   
   SIGNAL s_word_data_reg         : std_logic_vector(15 DOWNTO 0);
   SIGNAL s_word_bytes_valid_reg  : std_logic_vector( 1 DOWNTO 0);
   SIGNAL s_latch_read_data       : std_logic;
   SIGNAL s_fifo_read_info_reg    : std_logic_vector( 2 DOWNTO 0);
   SIGNAL s_push_lo               : std_logic;
   SIGNAL s_push_hi               : std_logic;
   SIGNAL s_payload_size_cnt_reg  : std_logic_vector(21 DOWNTO 0);
   SIGNAL s_payload_size_cnt_next : std_logic_vector(21 DOWNTO 0);
   
   SIGNAL s_fifo_empty            : std_logic;
   SIGNAL s_fifo_pop              : std_logic;
   SIGNAL s_fifo_pop_data         : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_fifo_pop_last         : std_logic;
   SIGNAL s_fifo_word_reg         : std_logic_vector(15 DOWNTO 0 );
   SIGNAL s_fifo_word_valid_reg   : std_logic_vector( 1 DOWNTO 0 );
   SIGNAL s_invalid_size          : std_logic;
   SIGNAL s_last_byte_reg         : std_logic;
   SIGNAL s_fifo_reset            : std_logic;
   
   SIGNAL s_write_idx_reg         : std_logic_vector( 1 DOWNTO 0 );
   SIGNAL s_write_data_reg        : std_logic_vector(15 DOWNTO 0 );
   SIGNAL s_write_size            : std_logic;
   SIGNAL s_write_data            : std_logic;
   SIGNAL s_done_reg              : std_logic;
   SIGNAL s_write_done_reg        : std_logic;
   SIGNAL s_empty_cnt_reg         : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_write_empty           : std_logic;
   SIGNAL s_empty_size            : std_logic;
   SIGNAL s_empty_data            : std_logic_vector( 7 DOWNTO 0 );
   
   SIGNAL s_start_pud_write       : std_logic;
   SIGNAL s_start_pud_read        : std_logic;
   SIGNAL s_is_pud_action_reg     : std_logic;
   SIGNAL s_pud_word              : std_logic_vector(15 DOWNTO 0 );
   SIGNAL s_write_pud             : std_logic;
   SIGNAL s_we_pud_byte           : std_logic;
   SIGNAL s_ena_pud_byte          : std_logic;
   SIGNAL s_pud_byte_addr_reg     : std_logic_vector(11 DOWNTO 0 );
   SIGNAL s_ena_pud_word_read     : std_logic;
   SIGNAL s_scpi_push             : std_logic;
   SIGNAL s_scpi_n_reset          : std_logic;
   SIGNAL s_pud_byte              : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_pud_size_value        : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_pud_word_address_reg  : std_logic_vector( 9 DOWNTO 0 );
   SIGNAL s_we_pud_payload        : std_logic;
   SIGNAL s_busy_pipe_reg         : std_logic_vector( 3 DOWNTO 0 );
   
   SIGNAL s_we_vga                : std_logic;
   SIGNAL s_we_addr               : std_logic_vector(10 DOWNTO 0);
   SIGNAL s_we_data               : std_logic_vector( 7 DOWNTO 0);
   SIGNAL s_pud_hi_reg            : std_logic;
   SIGNAL s_time_out_cnt_reg      : std_logic_vector( 3 DOWNTO 0 );

BEGIN
--------------------------------------------------------------------------------
--- Here the outputs are defined                                             ---
--------------------------------------------------------------------------------
   flash_n_byte   <= '1';
   flash_idle     <= '1' WHEN s_flash_state_reg = IDLE ELSE '0';
   flash_n_busy   <= '0' WHEN s_flash_state_reg = INIT_CHECK_EMPTY OR
                              s_flash_state_reg = CHECK_EMPTY OR
                              s_flash_state_reg = INIT_ERASE_S1 OR
                              s_flash_state_reg = ERASE_S1 OR
                              s_flash_state_reg = WAIT_BUSY_LO OR
                              s_flash_state_reg = WAIT_BUSY_HI OR
                              s_flash_state_reg = NEXT_SECTOR OR
                              s_flash_state_reg = INIT_WRITE OR
                              s_flash_state_reg = PLAY_WRITE OR
                              s_flash_state_reg = DO_WRITE OR
                              s_flash_state_reg = WAIT_READY_LO OR
                              s_flash_state_reg = WAIT_READY_HI OR
                              s_flash_state_reg = WRITE_UPDATE OR
                              reset = '1' ELSE '1';
   done           <= '1' WHEN s_flash_state_reg = SIGNAL_DONE OR
                              s_done_reg = '1' ELSE '0';
   flash_present  <= s_flash_mounted_reg;
   flash_s1_empty <= s_flash_sec1_empty_reg;
   push           <= ((s_push_lo OR s_push_hi) AND 
                      NOT(s_payload_size_cnt_reg(21))) OR s_write_empty;
   push_data      <= s_word_data_reg( 7 DOWNTO 0 ) WHEN s_push_lo = '1' ELSE
                     s_word_data_reg(15 DOWNTO 8 ) WHEN s_push_hi = '1' ELSE
                     s_empty_data;
   push_last      <= (s_push_lo OR s_push_hi) AND s_payload_size_cnt_next(21);
   push_size      <= (NOT(s_fifo_read_info_reg(2)) AND 
                      (s_push_lo OR s_push_hi)) OR s_empty_size;
   size_error     <= '1' WHEN s_flash_state_reg = SIGNAL_ERROR ELSE '0';
   s_fifo_reset   <= '1' WHEN reset = '1' OR
                              s_flash_state_reg = RESET_FIFO ELSE '0';
   scpi_pop       <= s_we_pud_byte;
   scpi_push_data <= s_pud_size_value OR s_pud_byte;
   
   start_config   <= '0';
   
--------------------------------------------------------------------------------
--- Here the control signals are defined                                     ---
--------------------------------------------------------------------------------
   s_flash_n_ce   <= '1' WHEN reset = '1' OR
                              s_flash_state_reg = IDLE OR
                              s_flash_state_reg = SIGNAL_DONE ELSE '0';
   s_flash_n_oe   <= '0' WHEN s_flash_state_reg = READ_ID OR
                              s_flash_state_reg = RESET_NOP OR
                              s_flash_state_reg = READ_HW OR
                              s_flash_state_reg = NOP_READ OR
                              s_flash_state_reg = INIT_READ OR
                              s_flash_state_reg = CHECK_HW OR
                              s_flash_state_reg = COPY_PAYLOAD OR
                              s_flash_state_reg = INIT_CHECK_EMPTY OR
                              s_flash_state_reg = CHECK_EMPTY OR
                              s_flash_state_reg = COPY_PUD_DATA ELSE '1';
   s_tri_data_out <= '0' WHEN s_flash_state_reg = SET_AUTOSELECT OR
                              s_flash_state_reg = RESET_AUTO OR
                              s_flash_state_reg = ERASE_S1 OR
                              s_flash_state_reg = PLAY_WRITE OR
                              s_flash_state_reg = DO_WRITE ELSE '1';
   s_flash_n_we   <= '0' WHEN (s_delay_counter_reg(1 DOWNTO 0) = "01" OR
                               s_delay_counter_reg(1 DOWNTO 0) = "10") AND
                              (s_flash_state_reg = SET_AUTOSELECT OR
                               s_flash_state_reg = RESET_AUTO OR
                               s_flash_state_reg = ERASE_S1 OR
                               s_flash_state_reg = PLAY_WRITE OR
                               s_flash_state_reg = DO_WRITE) ELSE '1';
   s_state_tick   <= s_delay_counter_reg(1) AND s_delay_counter_reg(0);
   s_next_address <= '1' WHEN (s_delay_counter_reg = "011" AND
                               ((s_word_bytes_valid_reg = "00" AND
                                 s_flash_state_reg = COPY_PAYLOAD) OR
                                s_flash_state_reg = CHECK_HW OR
                                s_flash_state_reg = COPY_PUD_DATA OR
                                s_flash_state_reg = CHECK_EMPTY)) OR
                              s_flash_state_reg = WRITE_UPDATE ELSE '0';
   s_latch_read_data <= '1' WHEN s_word_bytes_valid_reg = "00" AND
                                 s_delay_counter_reg(2) = '1' AND
                                 s_flash_state_reg = COPY_PAYLOAD ELSE '0';
   s_next_in_sector_addr <= unsigned("0"&s_in_sector_address_reg) + 1;
   s_invalid_size <= '1' WHEN bitfile_size(31 DOWNTO 21) /= "000"&X"00" OR
                              bitfile_size(20 DOWNTO 16) = "11111" ELSE '0';
   
   make_addr_data : PROCESS( s_player_count_reg , s_command_byte ,
                             s_sector_address_reg , s_in_sector_address_reg ,
                             s_write_data_reg )
   BEGIN
      CASE (s_player_count_reg) IS
         WHEN  "001"  |
               "101"  => s_byte_address  <= "0"&X"00AAA";
                         s_data_out_next <= X"00AA";
         WHEN  "010"  |
               "110"  => s_byte_address  <= "0"&X"00555";
                         s_data_out_next <= X"0055";
         WHEN  "011"  => s_byte_address  <= "0"&X"00AAA";
                         s_data_out_next <= X"00"&s_command_byte;
         WHEN  "111"  => s_byte_address  <= s_sector_address_reg&X"0000";
                         s_data_out_next <= X"00"&s_command_byte;
         WHEN OTHERS  => s_byte_address  <= s_sector_address_reg&
                                            s_in_sector_address_reg&"0";
                         s_data_out_next <= s_write_data_reg;
      END CASE;
   END PROCESS make_addr_data;
   
   make_done_reg : PROCESS( clock , start_read )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         s_done_reg <= start_read;
      END IF;
   END PROCESS make_done_reg;

--------------------------------------------------------------------------------
--- Here the empty message is defined                                        ---
--------------------------------------------------------------------------------
   s_write_empty <= '0' WHEN fifo_full = '1' OR
                             s_empty_cnt_reg = "000" ELSE '1';
   s_empty_size  <= '1' WHEN s_empty_cnt_reg = "111" ELSE '0';
   
   make_empty_data : PROCESS(s_empty_cnt_reg)
   BEGIN
      CASE (s_empty_cnt_reg) IS
         WHEN  "111"  => s_empty_data <= X"06";
         WHEN  "110"  => s_empty_data <= X"45";
         WHEN  "101"  => s_empty_data <= X"4D";
         WHEN  "100"  => s_empty_data <= X"50";
         WHEN  "011"  => s_empty_data <= X"54";
         WHEN  "010"  => s_empty_data <= X"59";
         WHEN  "001"  => s_empty_data <= X"0A";
         WHEN OTHERS  => s_empty_data <= X"00";
      END CASE;
   END PROCESS make_empty_data;

   make_empty_cnt_reg : PROCESS( clock , reset , start_read , s_write_empty ,
                                 s_empty_cnt_reg , s_flash_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_empty_cnt_reg <= "000";
         ELSIF (start_read = '1' AND
                s_flash_sec1_empty_reg = '1' AND
                s_flash_state_reg = IDLE) THEN
            s_empty_cnt_reg <= "111";
         ELSIF (s_write_empty = '1') THEN
            s_empty_cnt_reg <= unsigned(s_empty_cnt_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_empty_cnt_reg;

--------------------------------------------------------------------------------
--- Here the state machine is defined                                        ---
--------------------------------------------------------------------------------
   make_state_machine : PROCESS( clock , reset , s_flash_state_reg ,
                                 s_state_tick , s_player_count_reg , start_erase,
                                 s_flash_sec1_empty_reg )
      VARIABLE v_next_state : FLASH_STATE_TYPE;
   BEGIN
      CASE (s_flash_state_reg) IS
         WHEN RESET_STATE           => IF (s_state_tick = '1') THEN
                                          v_next_state := SET_AUTOSELECT;
                                                                        ELSE
                                          v_next_state := RESET_STATE;
                                       END IF;
         WHEN SET_AUTOSELECT        => IF (s_player_count_reg = "000" AND
                                           s_state_tick = '1') THEN
                                          v_next_state := AUTO_NOP;
                                                                         ELSE
                                          v_next_state := SET_AUTOSELECT;
                                       END IF;
         WHEN AUTO_NOP              => IF (s_state_tick = '1') THEN
                                          v_next_state := READ_ID;
                                                               ELSE
                                          v_next_state := AUTO_NOP;
                                       END IF;
         WHEN READ_ID               => IF (s_state_tick = '1') THEN
                                          v_next_state := CHECK_ID;
                                                                      ELSE
                                          v_next_state := READ_ID;
                                       END IF;
         WHEN CHECK_ID              => IF (s_state_tick = '1') THEN
                                          v_next_state := RESET_AUTO;
                                                               ELSE
                                          v_next_state := CHECK_ID;
                                       END IF;
         WHEN RESET_AUTO            => IF (s_state_tick = '1') THEN
                                          v_next_state := RESET_NOP;
                                                               ELSE
                                          v_next_state := RESET_AUTO;
                                       END IF;
         WHEN RESET_NOP             => IF (s_state_tick = '1') THEN
                                          v_next_state := READ_HW;
                                                               ELSE
                                          v_next_state := RESET_NOP;
                                       END IF;
         WHEN READ_HW               => IF (s_state_tick = '1') THEN
                                          v_next_state := CHECK_HW;
                                                               ELSE
                                          v_next_state := READ_HW;
                                       END IF;
         WHEN CHECK_HW              => IF (s_state_tick = '1') THEN
                                          IF (s_flash_mounted_reg = '1') THEN
                                             v_next_state := COPY_PUD_DATA;
                                                                         ELSE
                                             v_next_state := IDLE;
                                          END IF;
                                                               ELSE
                                          v_next_state := CHECK_HW;
                                       END IF;
         WHEN COPY_PUD_DATA         => IF (s_state_tick = '1' AND
                                           s_in_sector_address_reg(11) = '1') THEN
                                          v_next_state := IDLE;
                                                               ELSE
                                          v_next_state := COPY_PUD_DATA;
                                       END IF;
         WHEN IDLE                  => IF (s_start_pud_write = '1') THEN 
                                          v_next_state := DO_PUD_WRITE;
                                       ELSIF (s_start_pud_read = '1') THEN
                                          v_next_state := SET_PUD_SIZE_1;
                                       ELSIF (start_erase = '1') THEN
                                          IF (s_flash_sec1_empty_reg = '1') THEN
                                             v_next_state := SIGNAL_DONE;
                                                                            ELSE
                                             v_next_state := INIT_CHECK_EMPTY;
                                          END IF;
                                       ELSIF (start_read = '1' AND
                                              s_flash_sec1_empty_reg = '0') THEN
                                          v_next_state := NOP_READ;
                                       ELSIF (start_write = '1') THEN
                                          IF (s_flash_sec1_empty_reg = '0') THEN
                                             v_next_state := SIGNAL_ERROR;
                                                                            ELSE
                                             v_next_state := CHECK_SIZE;
                                          END IF;
                                                                 ELSE
                                          v_next_state := IDLE;
                                       END IF;
         WHEN INIT_CHECK_EMPTY      => IF (s_delay_counter_reg(2) = '1') THEN
                                          v_next_state := CHECK_EMPTY;
                                                                         ELSE
                                          v_next_state := INIT_CHECK_EMPTY;
                                       END IF;
         WHEN CHECK_EMPTY           => IF (s_state_tick = '1') THEN
                                          IF (s_sector_address_reg =
                                              s_pud_sector_address) THEN
                                             v_next_state := SIGNAL_DONE;
                                          ELSIF (s_flash_data_in = X"FFFF") THEN
                                             v_next_state := CHECK_EMPTY;
                                                                         ELSE
                                             v_next_state := INIT_ERASE_S1;
                                          END IF;
                                                               ELSE
                                          v_next_state := CHECK_EMPTY;
                                       END IF;
         WHEN INIT_ERASE_S1         => IF (s_state_tick = '1') THEN
                                          v_next_state := ERASE_S1;
                                                               ELSE
                                          v_next_state := INIT_ERASE_S1;
                                       END IF;
         WHEN ERASE_S1              => IF (s_player_count_reg = "000" AND
                                           s_state_tick = '1') THEN
                                          v_next_state := WAIT_BUSY_LO;
                                                               ELSE
                                          v_next_state := ERASE_S1;
                                       END IF;
         WHEN WAIT_BUSY_LO          => IF (s_time_out_cnt_reg(3) = '1') THEN
                                          v_next_state := INIT_ERASE_S1;
                                       ELSIF (s_busy_pipe_reg(3) = '0') THEN
                                          v_next_state := WAIT_BUSY_HI;
                                                                     ELSE
                                          v_next_state := WAIT_BUSY_LO;
                                       END IF;
         WHEN WAIT_BUSY_HI          => IF (s_busy_pipe_reg(3) = '1') THEN
                                          IF (s_is_pud_action_reg = '1') THEN
                                             v_next_state := INIT_WRITE;
                                                                          ELSE
                                             v_next_state := NEXT_SECTOR;
                                          END IF;
                                                                     ELSE
                                          v_next_state := WAIT_BUSY_HI;
                                       END IF;
         WHEN NEXT_SECTOR           => v_next_state := INIT_CHECK_EMPTY;
         WHEN NOP_READ              => IF (s_delay_counter_reg(2) = '1') THEN
                                          v_next_state := INIT_READ;
                                                                         ELSE
                                          v_next_state := NOP_READ;
                                       END IF;
         WHEN INIT_READ             => IF (s_delay_counter_reg(2) = '1') THEN
                                          v_next_state := COPY_PAYLOAD;
                                                               ELSE
                                          v_next_state := INIT_READ;
                                       END IF;
         WHEN COPY_PAYLOAD          => IF (s_payload_size_cnt_reg(21) = '1' AND
                                           s_delay_counter_reg = "011") THEN
                                          v_next_state := IDLE;
                                                                        ELSE
                                          v_next_state := COPY_PAYLOAD;
                                       END IF;
         WHEN CHECK_SIZE            => IF (s_invalid_size = '1') THEN
                                          v_next_state := SIGNAL_ERROR;
                                                                 ELSE
                                          v_next_state := INIT_WRITE;
                                       END IF;
         WHEN INIT_WRITE            => IF (s_write_size = '1' OR
                                           s_write_data = '1' OR
                                           s_write_pud = '1') THEN
                                          v_next_state := PLAY_WRITE;
                                                               ELSE
                                          v_next_state := INIT_WRITE;
                                       END IF;
         WHEN PLAY_WRITE            => IF (s_player_count_reg = "000" AND
                                           s_state_tick = '1') THEN
                                          v_next_state := DO_WRITE;
                                                               ELSE
                                          v_next_state := PLAY_WRITE;
                                       END IF;
         WHEN DO_WRITE              => IF (s_state_tick = '1') THEN
                                          v_next_state := WAIT_READY_LO;
                                                               ELSE
                                          v_next_state := DO_WRITE;
                                       END IF;
         WHEN WAIT_READY_LO         => IF (s_busy_pipe_reg(3) = '0') THEN
                                          v_next_state := WAIT_READY_HI;
                                                                     ELSE
                                          v_next_state := WAIT_READY_LO;
                                       END IF;
         WHEN WAIT_READY_HI         => IF (s_busy_pipe_reg(3) = '1') THEN
                                          v_next_state := WRITE_UPDATE;
                                                                     ELSE
                                          v_next_state := WAIT_READY_HI;
                                       END IF;
         WHEN WRITE_UPDATE          => IF (s_write_done_reg = '1') THEN
                                          IF (s_is_pud_action_reg = '1') THEN
                                             v_next_state := SIGNAL_DONE;
                                                                         ELSE
                                             v_next_state := SIGNAL_INIT;
                                          END IF;
                                                                  ELSE
                                          v_next_state := INIT_WRITE;
                                       END IF;
         WHEN SIGNAL_ERROR          => v_next_state := RESET_FIFO;
         WHEN DO_PUD_WRITE          => IF (s_we_pud_byte = '1' AND
                                           scpi_pop_last = '1') THEN
                                          IF (s_flash_mounted_reg = '1') THEN
                                             v_next_state := INIT_ERASE_S1;
                                                                         ELSE
                                             v_next_state := SIGNAL_DONE;
                                          END IF;
                                                                ELSE
                                          v_next_state := DO_PUD_WRITE;
                                       END IF;
         WHEN SET_PUD_SIZE_1        => IF (s_scpi_push = '1') THEN
                                          v_next_state := SET_PUD_SIZE_2;
                                                              ELSE
                                          v_next_state := SET_PUD_SIZE_1;
                                       END IF;
         WHEN SET_PUD_SIZE_2        => IF (s_scpi_push = '1') THEN
                                          v_next_state := DO_PUD_READ;
                                                              ELSE
                                          v_next_state := SET_PUD_SIZE_2;
                                       END IF;
         WHEN DO_PUD_READ           => IF (s_pud_byte_addr_reg(11) = '1') THEN
                                          v_next_state := SIGNAL_DONE;
                                                                          ELSE
                                          v_next_state := DO_PUD_READ;
                                       END IF;
         WHEN SIGNAL_INIT           => v_next_state := SIGNAL_DONE;
         WHEN OTHERS                => v_next_state := IDLE;
      END CASE;
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_flash_state_reg <= RESET_STATE;
                          ELSE s_flash_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_state_machine;
   
   make_time_out_cnt_reg : PROCESS( clock , reset , s_flash_state_reg ,
                                    msec_tick )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_time_out_cnt_reg <= X"F";
         ELSIF (s_flash_state_reg = ERASE_S1) THEN
            s_time_out_cnt_reg <= X"7";
         ELSIF (s_time_out_cnt_reg(3) = '0' AND
                msec_tick = '1') THEN
            s_time_out_cnt_reg <= unsigned(s_time_out_cnt_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_time_out_cnt_reg;

--------------------------------------------------------------------------------
--- Here the word to byte handling is defined                                ---
--------------------------------------------------------------------------------
   s_push_lo <= '1' WHEN fifo_full = '0' AND
                         s_word_bytes_valid_reg(0) = '1' AND
                         s_delay_counter_reg = "000" ELSE '0';
   s_push_hi <= '1' WHEN fifo_full = '0' AND
                         s_word_bytes_valid_reg = "10" AND
                         s_delay_counter_reg = "010" ELSE '0';
   s_payload_size_cnt_next <= unsigned(s_payload_size_cnt_reg) - 1;

   make_word_regs : PROCESS( clock , s_flash_state_reg , s_latch_read_data )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = IDLE) THEN
            s_word_data_reg        <= (OTHERS => '0');
            s_word_bytes_valid_reg <= (OTHERS => '0');
         ELSIF (s_latch_read_data = '1') THEN
            s_word_data_reg        <= s_flash_data_in;
            s_word_bytes_valid_reg <= "11";
         ELSIF (s_push_lo = '1') THEN
            s_word_bytes_valid_reg(0) <= '0';
         ELSIF (s_push_hi = '1') THEN
            s_word_bytes_valid_reg(1) <= '0';
         END IF;
      END IF;
   END PROCESS make_word_regs;
   
   make_fifo_read_info_reg : PROCESS( clock , s_flash_state_reg , reset ,
                                      s_push_lo , s_push_hi )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = IDLE OR
             reset = '1') THEN s_fifo_read_info_reg <= "000";
         ELSIF ((s_push_lo = '1' OR
                 s_push_hi = '1') AND
                s_fifo_read_info_reg(2) = '0') THEN
            s_fifo_read_info_reg <= unsigned(s_fifo_read_info_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_fifo_read_info_reg;
   
   make_payload_size_cnt_reg : PROCESS( clock , s_flash_state_reg ,
                                        s_push_lo , s_push_hi ,
                                        s_payload_size_cnt_next )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = IDLE) THEN
            s_payload_size_cnt_reg <= "01"&X"FFFFF";
         ELSIF (s_push_lo = '1' OR
                s_push_hi = '1') THEN
            CASE (s_fifo_read_info_reg) IS
               WHEN  "000" => s_payload_size_cnt_reg( 7 DOWNTO 0 ) <= 
                                 s_word_data_reg( 7 DOWNTO 0 );
               WHEN  "001" => s_payload_size_cnt_reg( 15 DOWNTO 8 ) <= 
                                 s_word_data_reg(15 DOWNTO 8 );
               WHEN  "010" => s_payload_size_cnt_reg( 21 DOWNTO 16 ) <= 
                                 "0"&s_word_data_reg( 4 DOWNTO 0 );
               WHEN OTHERS => s_payload_size_cnt_reg <= s_payload_size_cnt_next;
            END CASE;
         END IF;
      END IF;
   END PROCESS make_payload_size_cnt_reg;

--------------------------------------------------------------------------------
--- Here the addresses are defined                                           ---
--------------------------------------------------------------------------------
   s_pud_sector_address <= (OTHERS => '1') WHEN s_flash_top_boot_reg = '1' ELSE
                           (OTHERS => '0');
   
   make_sector_address : PROCESS( clock , s_flash_state_reg ,
                                  s_flash_top_boot_reg , s_next_address ,
                                  s_next_in_sector_addr )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = RESET_STATE) THEN
            s_sector_address_reg <= (OTHERS => '0');
         ELSIF (s_flash_state_reg = RESET_AUTO OR
                s_flash_state_reg = IDLE) THEN
            s_sector_address_reg(20 DOWNTO 17) <= (OTHERS => '0');
            s_sector_address_reg(16) <= NOT(s_flash_top_boot_reg);
         ELSIF ((s_flash_state_reg = INIT_ERASE_S1 AND
                 s_is_pud_action_reg = '1') OR
                s_flash_state_reg = READ_HW) THEN
            s_sector_address_reg <= s_pud_sector_address;
         ELSIF ((s_next_address = '1' AND
                 s_next_in_sector_addr(16) = '1') OR
                s_flash_state_reg = NEXT_SECTOR) THEN
            s_sector_address_reg <= unsigned(s_sector_address_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_sector_address;
   
   make_in_sector_address : PROCESS( clock , s_flash_state_reg ,
                                     s_next_address , s_next_in_sector_addr )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = RESET_STATE) THEN
            s_in_sector_address_reg <= (1=>'1', OTHERS => '0');
         ELSIF (s_flash_state_reg = RESET_AUTO OR
                s_flash_state_reg = IDLE OR
                s_flash_state_reg = INIT_ERASE_S1 OR
                s_flash_state_reg = READ_HW) THEN
            s_in_sector_address_reg <= (OTHERS => '0');
         ELSIF (s_next_address = '1') THEN
            s_in_sector_address_reg <= s_next_in_sector_addr( 15 DOWNTO 1 );
         END IF;
      END IF;
   END PROCESS make_in_sector_address;
   
--------------------------------------------------------------------------------
--- Here the command player is defined                                       ---
--------------------------------------------------------------------------------
   make_player_count_reg : PROCESS( clock , s_flash_state_reg ,
                                    s_delay_counter_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = RESET_STATE OR
             s_flash_state_reg = INIT_ERASE_S1 OR
             s_flash_state_reg = INIT_WRITE) THEN
            s_player_count_reg <= "001";
         ELSIF (s_flash_state_reg = CHECK_ID) THEN
            s_player_count_reg <= "011";
         ELSIF (s_delay_counter_reg(2) = '1') THEN
            CASE (s_player_count_reg) IS
               WHEN  "000" => NULL;
               WHEN  "011" => IF (s_flash_state_reg = SET_AUTOSELECT OR
                                  s_flash_state_reg = RESET_AUTO OR
                                  s_flash_state_reg = PLAY_WRITE) THEN
                                s_player_count_reg <= "000";
                                                                  ELSE
                                s_player_count_reg <= "101";
                              END IF;
               WHEN OTHERS => s_player_count_reg <= unsigned(s_player_count_reg) + 1;
            END CASE;
         END IF;
      END IF;
   END PROCESS make_player_count_reg;
   
   make_command_byte : PROCESS( s_flash_state_reg , s_player_count_reg )
   BEGIN
      CASE (s_flash_state_reg) IS
         WHEN SET_AUTOSELECT     => s_command_byte <= X"90";
         WHEN RESET_AUTO         => s_command_byte <= X"F0";
         WHEN ERASE_S1           => IF (s_player_count_reg(2) = '0') THEN
                                       s_command_byte <= X"80";
                                                                     ELSE
                                       s_command_byte <= X"30";
                                    END IF;
         WHEN PLAY_WRITE         => s_command_byte <= X"A0";
         WHEN OTHERS             => s_command_byte <= X"00";
      END CASE;
   END PROCESS make_command_byte;
   
--------------------------------------------------------------------------------
--- Here the delay counter is defined                                        ---
--------------------------------------------------------------------------------
   make_delay_counter : PROCESS( clock , reset , s_flash_state_reg ,
                                 s_delay_counter_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = IDLE OR
             s_delay_counter_reg(2) = '1' OR
             reset = '1') THEN s_delay_counter_reg <= "000";
                          ELSE
            s_delay_counter_reg <= unsigned(s_delay_counter_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_delay_counter;
   
--------------------------------------------------------------------------------
--- Here the flash id regs are defined                                       ---
--------------------------------------------------------------------------------
   make_flash_mt_regs : PROCESS( clock , s_flash_state_reg , s_flash_data_in )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_flash_mounted_reg  <= '0';
                               s_flash_top_boot_reg <= '0';
         ELSIF (s_flash_state_reg = CHECK_ID) THEN
            CASE (s_flash_data_in) IS
               WHEN X"22C4" => s_flash_mounted_reg  <= '1';
                               s_flash_top_boot_reg <= '1';
               WHEN X"2249" => s_flash_mounted_reg  <= '1';
                               s_flash_top_boot_reg <= '0';
               WHEN OTHERS  => s_flash_mounted_reg  <= '0';
                               s_flash_top_boot_reg <= '0';
            END CASE;
         END IF;
      END IF;
   END PROCESS make_flash_mt_regs;
   
   make_flash_sec1_empty_reg : PROCESS( clock , s_flash_state_reg ,
                                        s_flash_data_in )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             (s_flash_state_reg = WRITE_UPDATE AND
              s_is_pud_action_reg = '0')) THEN s_flash_sec1_empty_reg <= '0';
         ELSIF (s_flash_state_reg = CHECK_HW) THEN
            IF (s_flash_data_in = X"FFFF") THEN s_flash_sec1_empty_reg <= '1';
                                           ELSE s_flash_sec1_empty_reg <= '0';
            END IF;
         ELSIF (s_flash_state_reg = INIT_ERASE_S1 AND
                s_is_pud_action_reg = '0') THEN
            s_flash_sec1_empty_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_flash_sec1_empty_reg;

--------------------------------------------------------------------------------
--- Here the write signals are defined                                       ---
--------------------------------------------------------------------------------
   s_write_size <= '1' WHEN s_flash_state_reg = INIT_WRITE AND
                            s_write_idx_reg(1) = '0' AND
                            s_state_tick = '1' AND
                            s_is_pud_action_reg = '0' ELSE '0';
   s_write_data <= '1' WHEN s_flash_state_reg = INIT_WRITE AND
                            s_write_idx_reg(1) = '1' AND
                            s_state_tick = '1' AND
                            s_fifo_word_valid_reg(1) = '1' AND
                            s_is_pud_action_reg = '0' ELSE '0';
   
   make_write_done_reg : PROCESS( clock , reset , s_write_data , 
                                  s_flash_state_reg , s_last_byte_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = WRITE_UPDATE OR
             reset = '1') THEN s_write_done_reg <= '0';
         ELSIF (s_write_data = '1') THEN s_write_done_reg <= s_last_byte_reg;
         ELSIF (s_write_pud = '1') THEN 
            s_write_done_reg <= s_next_in_sector_addr(11);
         END IF;
      END IF;
   END PROCESS make_write_done_reg;
   
   
   make_write_idx_reg : PROCESS( clock , s_flash_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = IDLE) THEN
            s_write_idx_reg <= "00";
         ELSIF (s_write_size = '1') THEN
            s_write_idx_reg <= unsigned(s_write_idx_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_write_idx_reg;
   
   make_write_data_reg : PROCESS( clock , s_fifo_pop , s_write_size ,
                                  s_write_idx_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_is_pud_action_reg = '1') THEN s_write_data_reg <= s_pud_word;
         ELSIF (s_write_size = '1' OR
                s_write_data = '1') THEN
            CASE (s_write_idx_reg) IS
               WHEN  "00"  => s_write_data_reg <= bitfile_size(15 DOWNTO 0);
               WHEN  "01"  => s_write_data_reg <= bitfile_size(31 DOWNTO 16);
               WHEN OTHERS => s_write_data_reg <= s_fifo_word_reg;
            END CASE;
         END IF;
      END IF;
   END PROCESS make_write_data_reg;
   
--------------------------------------------------------------------------------
--- Here the write fifo interface is defined                                 ---
--------------------------------------------------------------------------------
   s_fifo_pop   <= '1' WHEN s_fifo_empty = '0' AND
                            s_fifo_word_valid_reg(1) = '0' AND
                            s_last_byte_reg = '0' ELSE '0';


   make_fifo_word_reg : PROCESS( clock , s_fifo_reset , s_fifo_pop ,
                                 s_fifo_pop_data , s_fifo_word_valid_reg ,
                                 s_write_data )
      VARIABLE v_select : std_logic_vector( 2 DOWNTO 0 );
   BEGIN
      IF (clock'event AND (clock = '1')) THEN 
         IF (s_fifo_reset = '1' OR
             s_write_data = '1') THEN s_fifo_word_valid_reg <= "00";
                                      s_fifo_word_reg       <= (OTHERS => '0');
         ELSIF (s_fifo_pop = '1') THEN
            IF (s_fifo_word_valid_reg = "00" AND
                s_fifo_pop_last = '1') THEN
               s_fifo_word_valid_reg <= "11";
               s_fifo_word_reg       <= X"FF"&s_fifo_pop_data;
                                       ELSE
               s_fifo_word_reg <= s_fifo_pop_data&s_fifo_word_reg(15 DOWNTO 8);
               s_fifo_word_valid_reg <= s_fifo_word_valid_reg(0)&"1";
            END IF;
         END IF;
      END IF;
   END PROCESS make_fifo_word_reg;
   
   make_last_byte_reg : PROCESS( clock , s_fifo_pop ,
                                 s_fifo_pop_last , s_flash_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = IDLE) THEN s_last_byte_reg <= '0';
         ELSIF (s_fifo_pop = '1' AND
                s_fifo_pop_last = '1') THEN s_last_byte_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_last_byte_reg;
   
   
   write_fifo : fifo_2kb
                PORT MAP ( clock      => clock,
                           reset      => s_fifo_reset,
                           -- push port
                           push       => we_fifo,
                           push_data  => we_data,
                           push_size  => we_last,
                           -- pop port
                           pop        => s_fifo_pop,
                           pop_data   => s_fifo_pop_data,
                           pop_size   => s_fifo_pop_last,
                           -- control port
                           fifo_full  => we_fifo_full,
                           fifo_empty => s_fifo_empty );

--------------------------------------------------------------------------------
--- Here the PUD signals are defined                                         ---
--------------------------------------------------------------------------------
   s_write_pud  <= '1' WHEN s_flash_state_reg = INIT_WRITE AND
                            s_state_tick = '1' AND
                            s_is_pud_action_reg = '1' ELSE '0';
   s_start_pud_write      <= '1' WHEN start_command = '1' AND
                                      command_id = "0001101" ELSE '0';
   s_start_pud_read       <= '1' WHEN start_command = '1' AND
                                      command_id = "0001110" ELSE '0';
   s_we_pud_byte          <= '1' WHEN s_flash_state_reg = DO_PUD_WRITE AND
                                      scpi_empty = '0' ELSE '0';
   s_ena_pud_byte         <= '1' WHEN s_we_pud_byte = '1' OR 
                                      (s_scpi_push = '1' AND
                                       s_flash_state_reg = DO_PUD_READ) ELSE '0';
   s_ena_pud_word_read    <= (NOT(s_we_pud_byte) AND s_is_pud_action_reg) OR
                             s_we_pud_payload;
   s_scpi_push            <= '1' WHEN scpi_full = '0' AND
                                      (s_flash_state_reg = SET_PUD_SIZE_1 OR
                                       s_flash_state_reg = SET_PUD_SIZE_2 OR
                                       (s_flash_state_reg = DO_PUD_READ AND
                                        s_pud_byte_addr_reg(11) = '0')) ELSE '0';
   s_scpi_n_reset         <= '0' WHEN s_flash_state_reg = DO_PUD_READ ELSE '1';
   s_we_pud_payload       <= '1' WHEN s_flash_state_reg = COPY_PUD_DATA AND
                                      s_delay_counter_reg = "000" ELSE '0';
   
   make_scpi_push : PROCESS( clock , s_scpi_push )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         scpi_push <= s_scpi_push;
         IF (s_scpi_push = '1' AND
             s_flash_state_reg = SET_PUD_SIZE_2) THEN
            s_pud_size_value <= X"08";
                                                 ELSE
            s_pud_size_value <= X"00";
         END IF;
         IF (s_scpi_push = '1' AND
             (s_flash_state_reg = SET_PUD_SIZE_1 OR
              s_flash_state_reg = SET_PUD_SIZE_2)) THEN
            scpi_push_size <= '1';
                                                   ELSE
            scpi_push_size <= '0';
         END IF;
      END IF;
   END PROCESS make_scpi_push;
   
   make_is_pud_action_reg : PROCESS( clock , reset , s_start_pud_write ,
                                     s_flash_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_start_pud_write = '1') THEN
            s_is_pud_action_reg <= '1';
         ELSIF (reset = '1' OR
                s_flash_state_reg = IDLE) THEN s_is_pud_action_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_is_pud_action_reg;
   
   make_pud_byte_addr_reg : PROCESS( clock , reset , s_flash_state_reg ,
                                     s_ena_pud_byte )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = IDLE OR
             reset = '1') THEN s_pud_byte_addr_reg <= (OTHERS => '0');
         ELSIF (s_ena_pud_byte = '1') THEN
            s_pud_byte_addr_reg <= unsigned(s_pud_byte_addr_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_pud_byte_addr_reg;
   
   make_pud_word_address_reg : PROCESS( clock , s_flash_state_reg , reset ,
                                        s_next_address , s_next_in_sector_addr )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_flash_state_reg = IDLE OR
             reset = '1') THEN s_pud_word_address_reg <= (OTHERS => '0');
         ELSIF (s_next_address = '1' AND
                s_is_pud_action_reg = '1') THEN
            s_pud_word_address_reg <= s_next_in_sector_addr( 10 DOWNTO 1 );
         ELSIF (s_pud_hi_reg = '1') THEN
            s_pud_word_address_reg <= s_in_sector_address_reg( 10 DOWNTO 1 );
         END IF;
      END IF;
   END PROCESS make_pud_word_address_reg;
   
   s_we_vga <= '1' WHEN (s_we_pud_byte = '1' AND
                         unsigned(s_pud_byte_addr_reg( 10 DOWNTO 6)) >
                         unsigned(c_vga_offset)) OR
                        ((s_pud_hi_reg = '1' OR
                          s_we_pud_payload = '1') AND
                         unsigned(s_pud_word_address_reg( 9 DOWNTO 5 )) >
                         unsigned(c_vga_offset)) ELSE '0';
   s_we_addr(10 DOWNTO 8) <= unsigned(s_pud_byte_addr_reg( 9 DOWNTO 7 )) - 1
                                WHEN s_we_pud_byte = '1' ELSE
                             unsigned(s_pud_word_address_reg( 8 DOWNTO 6 )) - 1;
   s_we_addr(7)           <= s_pud_byte_addr_reg(6)
                                WHEN s_we_pud_byte = '1' ELSE
                             s_pud_word_address_reg(5);
   s_we_addr(6)           <= '1';
   s_we_addr( 5 DOWNTO 0) <= s_pud_byte_addr_reg( 5 DOWNTO 0 )
                                WHEN s_we_pud_byte = '1' ELSE
                             s_pud_word_address_reg(4 DOWNTO 0)&s_pud_hi_reg;
   s_we_data              <= scpi_pop_data WHEN s_we_pud_byte = '1' ELSE
                             s_flash_data_in( 7 DOWNTO 0) 
                                WHEN s_pud_hi_reg = '0' ELSE
                             s_flash_data_in(15 DOWNTO 8) ;
   
   make_vga_signals : PROCESS( clock )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         we_char  <= s_we_vga;
         we_ascii <= s_we_data;
         we_addr  <= s_we_addr;
      END IF;
   END PROCESS make_vga_signals;
   
   make_pud_hi_reg : PROCESS( clock )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         s_pud_hi_reg <= s_we_pud_payload;
      END IF;
   END PROCESS make_pud_hi_reg;
   
                                        

   pud_buffer : RAMB16_S9_S18
                PORT MAP ( DOA     => s_pud_byte,
                           DOPA    => OPEN,
                           ADDRA   => s_pud_byte_addr_reg( 10 DOWNTO 0 ),
                           CLKA    => clock,
                           DIA     => scpi_pop_data,
                           DIPA    => "0",
                           ENA     => '1',
                           SSRA    => s_scpi_n_reset,
                           WEA     => s_we_pud_byte,
                           DOB     => s_pud_word,
                           DOPB    => OPEN,
                           ADDRB   => s_pud_word_address_reg,
                           CLKB    => clock,
                           DIB     => s_flash_data_in,
                           DIPB    => "00",
                           ENB     => s_ena_pud_word_read,
                           SSRB    => '0',
                           WEB     => s_we_pud_payload );
   
   make_busy_pipe_reg : PROCESS( clock , reset , flash_ready_n_busy )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_busy_pipe_reg <= X"0";
                          ELSE
            s_busy_pipe_reg( 2 DOWNTO 0 ) <= s_busy_pipe_reg(1 DOWNTO 0)&flash_ready_n_busy;
            IF (s_busy_pipe_reg( 2 DOWNTO 0 ) = "000") THEN s_busy_pipe_reg(3) <= '0';
            ELSIF (s_busy_pipe_reg( 2 DOWNTO 0 ) = "111") THEN s_busy_pipe_reg(3) <= '1';
            END IF;
         END IF;
      END IF;
   END PROCESS make_busy_pipe_reg;

--------------------------------------------------------------------------------
--- Here the IOB flipflops are defined                                       ---
--------------------------------------------------------------------------------
   address_ffs : FOR n IN 19 DOWNTO 0 GENERATE
      one_ff : FDE
               GENERIC MAP ( INIT => '1')
               PORT MAP ( Q   => flash_address(n),
                          C   => clock,
                          CE  => s_delay_counter_reg(2),
                          D   => s_byte_address(n+1) );
   END GENERATE address_ffs;
   
   data_in_out_ffs : FOR n IN 15 DOWNTO 0 GENERATE
      in_ff : FDE_1
              GENERIC MAP ( INIT => '1')
              PORT MAP ( Q   => s_flash_data_in(n),
                         C   => clock,
                         CE  => s_delay_counter_reg(2),
                         D   => flash_data_in(n) );
      out_ff : FDE
               GENERIC MAP ( INIT => '1')
               PORT MAP ( Q  => flash_data_out(n),
                          C  => clock,
                          CE => s_delay_counter_reg(2),
                          D  => s_data_out_next(n) );
      oe_ff : FDE
              GENERIC MAP ( INIT => '1')
              PORT MAP ( Q  => flash_data_oe(n),
                         C  => clock,
                         CE => s_delay_counter_reg(2),
                         D  => s_tri_data_out );
   END GENERATE data_in_out_ffs;
   
   nce_reg : FD
             GENERIC MAP ( INIT => '1')
             PORT MAP ( Q => flash_n_ce,
                        C => clock,
                        D => s_flash_n_ce );
   noe_reg : FD
             GENERIC MAP ( INIT => '1')
             PORT MAP ( Q => flash_n_oe,
                        C => clock,
                        D => s_flash_n_oe );
   nwe_reg : FD
             GENERIC MAP ( INIT => '1')
             PORT MAP ( Q => flash_n_we,
                        C => clock,
                        D => s_flash_n_we );
END xilinx;
