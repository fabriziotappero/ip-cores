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

ARCHITECTURE xilinx OF SCPI_INTERFACE IS

   COMPONENT RAM16X1S
      GENERIC ( INIT : bit_vector(15 DOWNTO 0 ) );
      PORT ( O     : OUT std_ulogic;
             A0    : IN  std_ulogic;
             A1    : IN  std_ulogic;
             A2    : IN  std_ulogic;
             A3    : IN  std_ulogic;
             D     : IN  std_ulogic;
             WCLK  : IN  std_ulogic;
             WE    : IN  std_ulogic );
   END COMPONENT;
   
   COMPONENT RAMB16_S9
      GENERIC ( INIT_00 : bit_vector;
                INIT_01 : bit_vector;
                INIT_02 : bit_vector;
                INIT_03 : bit_vector;
                INIT_04 : bit_vector;
                INIT_05 : bit_vector;
                INIT_06 : bit_vector;
                INIT_07 : bit_vector;
                INIT_08 : bit_vector;
                INIT_09 : bit_vector;
                INIT_0A : bit_vector;
                INIT_0B : bit_vector;
                INIT_0C : bit_vector;
                INIT_0D : bit_vector;
                INIT_0E : bit_vector;
                INIT_0F : bit_vector;
                INIT_10 : bit_vector;
                INIT_11 : bit_vector;
                INIT_12 : bit_vector;
                INIT_13 : bit_vector;
                INIT_14 : bit_vector;
                INIT_15 : bit_vector;
                INIT_16 : bit_vector;
                INIT_17 : bit_vector;
                INIT_18 : bit_vector;
                INIT_19 : bit_vector;
                INIT_1A : bit_vector;
                INIT_1B : bit_vector;
                INIT_1C : bit_vector;
                INIT_1D : bit_vector;
                INIT_1E : bit_vector;
                INIT_1F : bit_vector;
                INIT_20 : bit_vector;
                INIT_21 : bit_vector;
                INIT_22 : bit_vector;
                INIT_23 : bit_vector;
                INIT_24 : bit_vector;
                INIT_25 : bit_vector;
                INIT_26 : bit_vector;
                INIT_27 : bit_vector;
                INIT_28 : bit_vector;
                INIT_29 : bit_vector;
                INIT_2A : bit_vector;
                INIT_2B : bit_vector;
                INIT_2C : bit_vector;
                INIT_2D : bit_vector;
                INIT_2E : bit_vector;
                INIT_2F : bit_vector;
                INIT_30 : bit_vector;
                INIT_31 : bit_vector;
                INIT_32 : bit_vector;
                INIT_33 : bit_vector;
                INIT_34 : bit_vector;
                INIT_35 : bit_vector;
                INIT_36 : bit_vector;
                INIT_37 : bit_vector;
                INIT_38 : bit_vector;
                INIT_39 : bit_vector;
                INIT_3A : bit_vector;
                INIT_3B : bit_vector;
                INIT_3C : bit_vector;
                INIT_3D : bit_vector;
                INIT_3E : bit_vector;
                INIT_3F : bit_vector);
      PORT ( DO   : OUT std_logic_vector(  7 DOWNTO 0 );
             DOP  : OUT std_logic_vector(  0 DOWNTO 0 );
             ADDR : IN  std_logic_vector( 10 DOWNTO 0 );
             DI   : IN  std_logic_vector(  7 DOWNTO 0 );
             DIP  : IN  std_logic_vector(  0 DOWNTO 0 );
             EN   : IN  std_logic;
             WE   : IN  std_logic;
             CLK  : IN  std_logic;
             SSR  : IN  std_logic );
   END COMPONENT;
   
   TYPE SCPI_STATES IS (IDLE,INIT_COMMAND_READ,READ_ONE_COMMAND,
                        FLUSH_MESSAGE,SIGNAL_ERROR,
                        INIT_COMMAND_SEARCH_7 , COMMAND_SEARCH_7 ,
                        INIT_COMMAND_SEARCH_6 , COMMAND_SEARCH_6 ,
                        INIT_COMMAND_SEARCH_5 , COMMAND_SEARCH_5 ,
                        INIT_COMMAND_SEARCH_4 , COMMAND_SEARCH_4 ,
                        INIT_COMMAND_SEARCH_3 , COMMAND_SEARCH_3 ,
                        INIT_COMMAND_SEARCH_2 , COMMAND_SEARCH_2 ,
                        INIT_COMMAND_SEARCH_1 , COMMAND_SEARCH_1 ,
                        INIT_COMMAND_SEARCH_0 , COMMAND_SEARCH_0 ,
                        FETCH_COMMAND_ID , WAIT_FOR_DONE );
   CONSTANT c_small_a_1 : std_logic_vector( 7 DOWNTO 0 ) := X"60";
   CONSTANT c_small_z_1 : std_logic_vector( 7 DOWNTO 0 ) := X"7B";
   
   SIGNAL s_scpi_state_machine         : SCPI_STATES;
   SIGNAL s_n_clock                    : std_logic;
   SIGNAL s_pop_byte                   : std_logic;
   SIGNAL s_upcased_char               : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_is_lower_case              : std_logic;
   SIGNAL s_is_command_seperator       : std_logic;
   SIGNAL s_command_buffer_address_reg : std_logic_vector(  3 DOWNTO 0 );
   SIGNAL s_write_byte                 : std_logic;
   SIGNAL s_command_too_long           : std_logic;
   SIGNAL s_command_stored             : std_logic;
   SIGNAL s_command_byte               : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_command_char               : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_command_rom_search_addr    : std_logic_vector( 10 DOWNTO 0 );
   SIGNAL s_command_rom_data           : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_rom_data_zero              : std_logic;
   SIGNAL s_buffer_data_zero           : std_logic;
   SIGNAL s_command_match              : std_logic;
   SIGNAL s_command_smaller            : std_logic;
   SIGNAL s_command_bigger             : std_logic;
   SIGNAL s_search_command             : std_logic;
   SIGNAL s_cmd_gen_respons_reg        : std_logic;
   SIGNAL s_message_in_progress_reg    : std_logic;

BEGIN
--------------------------------------------------------------------------------
--- Here the outputs are defined                                             ---
--------------------------------------------------------------------------------
   pop             <= s_pop_byte OR slave_pop;
   unknown_command <= '1' WHEN s_scpi_state_machine = COMMAND_SEARCH_0 AND
                               (s_command_smaller = '1' OR
                                s_command_bigger = '1') ELSE '0';
   make_command : PROCESS( clock , reset , s_scpi_state_machine ,
                           s_command_rom_data , s_cmd_gen_respons_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN start_command   <= '0';
                               command_id      <= (OTHERS => '0');
                               cmd_gen_respons <= '0';
                          ELSE
            IF (s_scpi_state_machine = FETCH_COMMAND_ID) THEN
               start_command   <= '1';
               command_id      <= s_command_rom_data( 6 DOWNTO 0 );
               cmd_gen_respons <= s_cmd_gen_respons_reg;
                                                         ELSE
               start_command   <= '0';
               cmd_gen_respons <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS make_command;
   
--------------------------------------------------------------------------------
--- Here the state machine is defined                                        ---
--------------------------------------------------------------------------------
   make_scpi_state_machine : PROCESS( clock , reset , s_scpi_state_machine ,
                                      transparent_mode  , pop_empty,
                                      s_command_too_long ,
                                      s_command_stored , s_command_match ,
                                      s_command_bigger , s_command_smaller )
      VARIABLE v_next_state : SCPI_STATES;
   BEGIN
      CASE (s_scpi_state_machine) IS
         WHEN IDLE                  => IF (transparent_mode = '0' AND
                                           pop_empty = '0') THEN
                                          v_next_state := INIT_COMMAND_READ;
                                                            ELSE
                                          v_next_state := IDLE;
                                       END IF;
         WHEN INIT_COMMAND_READ     => v_next_state := READ_ONE_COMMAND;
         WHEN READ_ONE_COMMAND      => IF (s_command_too_long = '1') THEN
                                          v_next_state := FLUSH_MESSAGE;
                                       ELSIF (s_command_stored = '1') THEN
                                          v_next_state := INIT_COMMAND_SEARCH_7;
                                       ELSIF (pop_last = '1' AND
                                              pop_empty = '0') THEN
                                          v_next_state := SIGNAL_ERROR;
                                                                      ELSE
                                          v_next_state := READ_ONE_COMMAND;
                                       END IF;
         WHEN INIT_COMMAND_SEARCH_7 => v_next_state := COMMAND_SEARCH_7;
         WHEN COMMAND_SEARCH_7      => IF (s_command_match = '1') THEN
                                          v_next_state := FETCH_COMMAND_ID;
                                       ELSIF (s_command_smaller = '1' OR
                                              s_command_bigger = '1') THEN
                                          v_next_state := INIT_COMMAND_SEARCH_6;
                                                                      ELSE
                                          v_next_state := COMMAND_SEARCH_7;
                                       END IF;
         WHEN INIT_COMMAND_SEARCH_6 => v_next_state := COMMAND_SEARCH_6;
         WHEN COMMAND_SEARCH_6      => IF (s_command_match = '1') THEN
                                          v_next_state := FETCH_COMMAND_ID;
                                       ELSIF (s_command_smaller = '1' OR
                                              s_command_bigger = '1') THEN
                                          v_next_state := INIT_COMMAND_SEARCH_5;
                                                                      ELSE
                                          v_next_state := COMMAND_SEARCH_6;
                                       END IF;
         WHEN INIT_COMMAND_SEARCH_5 => v_next_state := COMMAND_SEARCH_5;
         WHEN COMMAND_SEARCH_5      => IF (s_command_match = '1') THEN
                                          v_next_state := FETCH_COMMAND_ID;
                                       ELSIF (s_command_smaller = '1' OR
                                              s_command_bigger = '1') THEN
                                          v_next_state := INIT_COMMAND_SEARCH_4;
                                                                      ELSE
                                          v_next_state := COMMAND_SEARCH_5;
                                       END IF;
         WHEN INIT_COMMAND_SEARCH_4 => v_next_state := COMMAND_SEARCH_4;
         WHEN COMMAND_SEARCH_4      => IF (s_command_match = '1') THEN
                                          v_next_state := FETCH_COMMAND_ID;
                                       ELSIF (s_command_smaller = '1' OR
                                              s_command_bigger = '1') THEN
                                          v_next_state := INIT_COMMAND_SEARCH_3;
                                                                      ELSE
                                          v_next_state := COMMAND_SEARCH_4;
                                       END IF;
         WHEN INIT_COMMAND_SEARCH_3 => v_next_state := COMMAND_SEARCH_3;
         WHEN COMMAND_SEARCH_3      => IF (s_command_match = '1') THEN
                                          v_next_state := FETCH_COMMAND_ID;
                                       ELSIF (s_command_smaller = '1' OR
                                              s_command_bigger = '1') THEN
                                          v_next_state := INIT_COMMAND_SEARCH_2;
                                                                      ELSE
                                          v_next_state := COMMAND_SEARCH_3;
                                       END IF;
         WHEN INIT_COMMAND_SEARCH_2 => v_next_state := COMMAND_SEARCH_2;
         WHEN COMMAND_SEARCH_2      => IF (s_command_match = '1') THEN
                                          v_next_state := FETCH_COMMAND_ID;
                                       ELSIF (s_command_smaller = '1' OR
                                              s_command_bigger = '1') THEN
                                          v_next_state := INIT_COMMAND_SEARCH_1;
                                                                      ELSE
                                          v_next_state := COMMAND_SEARCH_2;
                                       END IF;
         WHEN INIT_COMMAND_SEARCH_1 => v_next_state := COMMAND_SEARCH_1;
         WHEN COMMAND_SEARCH_1      => IF (s_command_match = '1') THEN
                                          v_next_state := FETCH_COMMAND_ID;
                                       ELSIF (s_command_smaller = '1' OR
                                              s_command_bigger = '1') THEN
                                          v_next_state := INIT_COMMAND_SEARCH_0;
                                                                      ELSE
                                          v_next_state := COMMAND_SEARCH_1;
                                       END IF;
         WHEN INIT_COMMAND_SEARCH_0 => v_next_state := COMMAND_SEARCH_0;
         WHEN COMMAND_SEARCH_0      => IF (s_command_match = '1') THEN
                                          v_next_state := FETCH_COMMAND_ID;
                                       ELSIF (s_command_smaller = '1' OR
                                              s_command_bigger = '1') THEN
                                          v_next_state := FLUSH_MESSAGE;
                                                                      ELSE
                                          v_next_state := COMMAND_SEARCH_0;
                                       END IF;
         WHEN FETCH_COMMAND_ID      => v_next_state := WAIT_FOR_DONE;
         WHEN WAIT_FOR_DONE         => IF (command_error = '1') THEN
                                          v_next_state := FLUSH_MESSAGE;
                                       ELSIF (command_done = '1') THEN
                                          v_next_state := IDLE;
                                                                  ELSE
                                          v_next_state := WAIT_FOR_DONE;
                                       END IF;
         WHEN FLUSH_MESSAGE         => IF (s_message_in_progress_reg = '1') THEN
                                          v_next_state := FLUSH_MESSAGE;
                                                                            ELSE
                                          v_next_state := SIGNAL_ERROR;
                                       END IF;
         WHEN OTHERS                => v_next_state := IDLE;
      END CASE;
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_scpi_state_machine <= IDLE;
                          ELSE s_scpi_state_machine <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_scpi_state_machine;
   
--------------------------------------------------------------------------------
--- Here the message in progress reg is defined                              ---
--------------------------------------------------------------------------------
   make_message_in_progress_reg : PROCESS( clock , reset , 
                                           s_scpi_state_machine )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             (pop_last = '1' AND
              (s_pop_byte = '1' OR
               slave_pop = '1'))) THEN s_message_in_progress_reg <= '0';
         ELSIF (s_scpi_state_machine = INIT_COMMAND_READ) THEN
            s_message_in_progress_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_message_in_progress_reg;
   
--------------------------------------------------------------------------------
--- Here the input fifo handling is defined                                  ---
--------------------------------------------------------------------------------
   s_pop_byte <= '1' WHEN (s_scpi_state_machine = READ_ONE_COMMAND OR
                           (s_scpi_state_machine = FLUSH_MESSAGE AND
                            s_message_in_progress_reg = '1')) AND
                           pop_empty = '0'
                     ELSE '0';
   
--------------------------------------------------------------------------------
--- Here the command buffer handling is defined                              ---
--------------------------------------------------------------------------------
   s_n_clock                  <= NOT( clock );
   s_upcased_char(7 DOWNTO 6) <= pop_data(7 DOWNTO 6);
   s_upcased_char(         5) <= pop_data(5) XOR s_is_lower_case;
   s_upcased_char(4 DOWNTO 0) <= pop_data(4 DOWNTO 0);
   s_command_rom_search_addr( 3 DOWNTO 0 ) <= s_command_buffer_address_reg;
   
   
   s_is_lower_case            <= '1' WHEN 
                                    (unsigned(pop_data) > unsigned(c_small_a_1)) AND
                                    (unsigned(pop_data) < unsigned(c_small_z_1)) ELSE '0';
   s_is_command_seperator     <= '1' WHEN pop_data = X"0A" OR
                                          pop_data = X"20" OR
                                          pop_data = X"3B" ELSE '0';
   s_write_byte               <= '1' WHEN 
                                    (s_is_command_seperator = '0' AND
                                     s_pop_byte = '1' AND
                                     s_scpi_state_machine = READ_ONE_COMMAND) OR
                                    s_scpi_state_machine = INIT_COMMAND_SEARCH_7 ELSE '0';
   s_command_too_long         <= '1' WHEN s_is_command_seperator = '0' AND
                                          pop_empty = '0' AND
                                          s_command_buffer_address_reg = X"F"
                                     ELSE '0';
   s_command_stored           <= '1' WHEN 
                                    (s_pop_byte = '1' AND
                                     s_is_command_seperator = '1' AND
                                     s_command_buffer_address_reg /= X"0")
                                     ELSE '0';
   s_command_byte             <= X"00" WHEN s_scpi_state_machine = INIT_COMMAND_SEARCH_7 
                                       ELSE s_upcased_char;
   s_rom_data_zero            <= '1' WHEN s_command_rom_data = X"00" ELSE '0';
   s_buffer_data_zero         <= '1' WHEN s_command_char = X"00" ELSE '0';
   s_command_match            <= s_rom_data_zero AND s_buffer_data_zero;
   s_command_smaller          <= '1' WHEN unsigned(s_command_char) <
                                          unsigned(s_command_rom_data) ELSE '0';
   s_command_bigger           <= '1' WHEN unsigned(s_command_char) >
                                          unsigned(s_command_rom_data) ELSE '0';
   s_search_command           <= '1' WHEN 
                                    s_scpi_state_machine = COMMAND_SEARCH_7 OR
                                    s_scpi_state_machine = COMMAND_SEARCH_6 OR
                                    s_scpi_state_machine = COMMAND_SEARCH_5 OR
                                    s_scpi_state_machine = COMMAND_SEARCH_4 OR
                                    s_scpi_state_machine = COMMAND_SEARCH_3 OR
                                    s_scpi_state_machine = COMMAND_SEARCH_2 OR
                                    s_scpi_state_machine = COMMAND_SEARCH_1 OR
                                    s_scpi_state_machine = COMMAND_SEARCH_0
                                     ELSE '0';

   make_cmd_gen_respons_reg : PROCESS( clock , reset , s_scpi_state_machine ,
                                       s_command_byte , s_write_byte )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_scpi_state_machine = INIT_COMMAND_READ OR
            reset = '1') THEN s_cmd_gen_respons_reg <= '0';
         ELSIF (s_write_byte = '1' AND
            s_command_byte = X"3F") THEN
            s_cmd_gen_respons_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_cmd_gen_respons_reg;

   make_command_rom_search_addr_7 : PROCESS( clock , reset ,
                                             s_scpi_state_machine ,
                                             s_command_smaller )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_scpi_state_machine = INIT_COMMAND_SEARCH_7 OR
             reset = '1') THEN s_command_rom_search_addr(10) <= '1';
         ELSIF (s_scpi_state_machine = COMMAND_SEARCH_7 AND
                s_command_smaller = '1') THEN
            s_command_rom_search_addr(10) <= '0';
         END IF;
      END IF;
   END PROCESS make_command_rom_search_addr_7;
   
   make_command_rom_search_addr_6 : PROCESS( clock , reset ,
                                             s_scpi_state_machine ,
                                             s_command_smaller )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_scpi_state_machine = INIT_COMMAND_SEARCH_7 OR
             reset = '1') THEN s_command_rom_search_addr(9) <= '0';
         ELSIF (s_scpi_state_machine = INIT_COMMAND_SEARCH_6) THEN
            s_command_rom_search_addr(9) <= '1';
         ELSIF (s_scpi_state_machine = COMMAND_SEARCH_6 AND
                s_command_smaller = '1') THEN
            s_command_rom_search_addr(9) <= '0';
         END IF;
      END IF;
   END PROCESS make_command_rom_search_addr_6;
   
   make_command_rom_search_addr_5 : PROCESS( clock , reset ,
                                             s_scpi_state_machine ,
                                             s_command_smaller )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_scpi_state_machine = INIT_COMMAND_SEARCH_7 OR
             reset = '1') THEN s_command_rom_search_addr(8) <= '0';
         ELSIF (s_scpi_state_machine = INIT_COMMAND_SEARCH_5) THEN
            s_command_rom_search_addr(8) <= '1';
         ELSIF (s_scpi_state_machine = COMMAND_SEARCH_5 AND
                s_command_smaller = '1') THEN
            s_command_rom_search_addr(8) <= '0';
         END IF;
      END IF;
   END PROCESS make_command_rom_search_addr_5;
   
   make_command_rom_search_addr_4 : PROCESS( clock , reset ,
                                             s_scpi_state_machine ,
                                             s_command_smaller )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_scpi_state_machine = INIT_COMMAND_SEARCH_7 OR
             reset = '1') THEN s_command_rom_search_addr(7) <= '0';
         ELSIF (s_scpi_state_machine = INIT_COMMAND_SEARCH_4) THEN
            s_command_rom_search_addr(7) <= '1';
         ELSIF (s_scpi_state_machine = COMMAND_SEARCH_4 AND
                s_command_smaller = '1') THEN
            s_command_rom_search_addr(7) <= '0';
         END IF;
      END IF;
   END PROCESS make_command_rom_search_addr_4;
   
   make_command_rom_search_addr_3 : PROCESS( clock , reset ,
                                             s_scpi_state_machine ,
                                             s_command_smaller )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_scpi_state_machine = INIT_COMMAND_SEARCH_7 OR
             reset = '1') THEN s_command_rom_search_addr(6) <= '0';
         ELSIF (s_scpi_state_machine = INIT_COMMAND_SEARCH_3) THEN
            s_command_rom_search_addr(6) <= '1';
         ELSIF (s_scpi_state_machine = COMMAND_SEARCH_3 AND
                s_command_smaller = '1') THEN
            s_command_rom_search_addr(6) <= '0';
         END IF;
      END IF;
   END PROCESS make_command_rom_search_addr_3;
   
   make_command_rom_search_addr_2 : PROCESS( clock , reset ,
                                             s_scpi_state_machine ,
                                             s_command_smaller )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_scpi_state_machine = INIT_COMMAND_SEARCH_7 OR
             reset = '1') THEN s_command_rom_search_addr(5) <= '0';
         ELSIF (s_scpi_state_machine = INIT_COMMAND_SEARCH_2) THEN
            s_command_rom_search_addr(5) <= '1';
         ELSIF (s_scpi_state_machine = COMMAND_SEARCH_2 AND
                s_command_smaller = '1') THEN
            s_command_rom_search_addr(5) <= '0';
         END IF;
      END IF;
   END PROCESS make_command_rom_search_addr_2;
   
   make_command_rom_search_addr_1 : PROCESS( clock , reset ,
                                             s_scpi_state_machine ,
                                             s_command_smaller )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_scpi_state_machine = INIT_COMMAND_SEARCH_7 OR
             s_scpi_state_machine = INIT_COMMAND_SEARCH_0 OR
             reset = '1') THEN s_command_rom_search_addr(4) <= '0';
         ELSIF (s_scpi_state_machine = INIT_COMMAND_SEARCH_1) THEN
            s_command_rom_search_addr(4) <= '1';
         ELSIF (s_scpi_state_machine = COMMAND_SEARCH_1 AND
                s_command_smaller = '1') THEN
            s_command_rom_search_addr(4) <= '0';
         END IF;
      END IF;
   END PROCESS make_command_rom_search_addr_1;
   
   make_command_buffer_address_reg : PROCESS( clock , reset , s_write_byte ,
                                              s_scpi_state_machine ,
                                              s_search_command )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_scpi_state_machine = INIT_COMMAND_READ OR
             s_scpi_state_machine = INIT_COMMAND_SEARCH_7 OR
             s_scpi_state_machine = INIT_COMMAND_SEARCH_6 OR
             s_scpi_state_machine = INIT_COMMAND_SEARCH_5 OR
             s_scpi_state_machine = INIT_COMMAND_SEARCH_4 OR
             s_scpi_state_machine = INIT_COMMAND_SEARCH_3 OR
             s_scpi_state_machine = INIT_COMMAND_SEARCH_2 OR
             s_scpi_state_machine = INIT_COMMAND_SEARCH_1 OR
             s_scpi_state_machine = INIT_COMMAND_SEARCH_0 OR
             reset = '1') THEN s_command_buffer_address_reg <= (OTHERS => '0');
         ELSIF (s_write_byte = '1' OR
                s_search_command = '1') THEN
            s_command_buffer_address_reg <= unsigned(s_command_buffer_address_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_command_buffer_address_reg;
   
   command_buffer : FOR n IN 7 DOWNTO 0 GENERATE
      one_bit : RAM16X1S
                GENERIC MAP ( INIT => X"0000" )
                PORT MAP ( O     => s_command_char(n),
                           A0    => s_command_buffer_address_reg(0),
                           A1    => s_command_buffer_address_reg(1),
                           A2    => s_command_buffer_address_reg(2),
                           A3    => s_command_buffer_address_reg(3),
                           D     => s_command_byte(n),
                           WCLK  => clock,
                           WE    => s_write_byte );
   END GENERATE command_buffer;
   
   command_rom : RAMB16_S9
      GENERIC MAP ( INIT_00 => X"FFFFFFFFFFFFFFFFFFFF06004553452AFFFFFFFFFFFFFFFFFFFF0200534C432A",
                    INIT_01 => X"FFFFFFFFFFFFFFFFFF08003F5253452AFFFFFFFFFFFFFFFFFF07003F4553452A",
                    INIT_02 => X"FFFFFFFFFFFFFFFFFF0A003F5453492AFFFFFFFFFFFFFFFFFF09003F4E44492A",
                    INIT_03 => X"FFFFFFFFFFFFFFFFFF0C003F43504F2AFFFFFFFFFFFFFFFFFFFF0B0043504F2A",
                    INIT_04 => X"FFFFFFFFFFFFFFFFFF0E003F4455502AFFFFFFFFFFFFFFFFFFFF0D004455502A",
                    INIT_05 => X"FFFFFFFFFFFFFFFFFFFF10004552532AFFFFFFFFFFFFFFFFFFFF0F005453522A",
                    INIT_06 => X"FFFFFFFFFFFFFFFFFF12003F4254532AFFFFFFFFFFFFFFFFFF11003F4552532A",
                    INIT_07 => X"FFFFFFFFFFFFFFFFFFFF15004941572AFFFFFFFFFFFFFFFFFF14003F5453542A",
                    INIT_08 => X"FFFFFFFFFF17003F4853414C46544942FFFFFFFFFFFF16004853414C46544942",
                    INIT_09 => X"FFFFFFFFFFFFFFFF19004749464E4F43FFFFFFFFFFFFFFFF18003F4452414F42",
                    INIT_0A => X"FFFFFFFFFFFFFFFFFFFF1B004F464946FFFFFFFFFFFFFFFFFF1A004553415245",
                    INIT_0B => X"FFFFFFFFFFFFFFFFFFFF1D0041475046FFFFFFFFFFFFFFFFFF1C003F4F464946",
                    INIT_0C => X"FFFFFFFFFF2300484354495753584548FFFFFFFFFFFFFFFFFF1E003F41475046",
                    INIT_0D => X"FFFFFFFFFFFF2500594649544E454449FFFFFFFF24003F484354495753584548",
                    INIT_0E => X"FFFFFFFFFF3A00544553455252455355FFFFFFFFFFFFFFFFFF3300534E415254",
                    INIT_0F => X"FFFFFFFFFF3C005241454C433A414756FFFFFFFFFF3B004C4F4347423A414756",
                    INIT_10 => X"FFFFFF3E003F524F535255433A414756FFFFFFFF3D00524F535255433A414756",
                    INIT_11 => X"FFFFFFFF40005254535455503A414756FFFFFFFFFF3F004C4F4347463A414756",
                    INIT_12 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_13 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_14 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_15 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_16 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_17 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_18 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_19 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_1A => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_1B => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_1C => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_1D => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_1E => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_1F => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_20 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_21 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_22 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_23 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_24 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_25 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_26 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_27 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_28 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_29 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_2A => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_2B => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_2C => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_2D => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_2E => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_2F => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_30 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_31 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_32 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_33 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_34 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_35 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_36 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_37 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_38 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_39 => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_3A => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_3B => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_3C => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_3D => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_3E => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE",
                    INIT_3F => X"FEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFEFE")
      PORT MAP ( DO   => s_command_rom_data,
                 DOP  => OPEN,
                 ADDR => s_command_rom_search_addr,
                 DI   => X"00",
                 DIP  => "0",
                 EN   => '1',
                 WE   => '0',
                 CLK  => s_n_clock,
                 SSR  => '0' );

   
END xilinx;
