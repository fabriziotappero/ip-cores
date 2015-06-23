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

ARCHITECTURE xilinx OF eeprom_emu IS

   COMPONENT edge_detector
      PORT ( clock    : IN  std_logic;
             reset    : IN  std_logic;
             data_in  : IN  std_logic;
             pos_edge : OUT std_logic;
             neg_edge : OUT std_logic;
             data_out : OUT std_logic );
   END COMPONENT;
   
   COMPONENT spi_if
      PORT ( clock            : IN  std_logic;
             reset            : IN  std_logic;
             read_request     : IN  std_logic;
             write_request    : IN  std_logic;
             i2c_write_done   : IN  std_logic;
             address          : IN  std_logic_vector( 11 DOWNTO 0 );
             data_in          : IN  std_logic_vector(  7 DOWNTO 0 );
             data_out         : OUT std_logic_vector(  7 DOWNTO 0 );
             done             : OUT std_logic;
             busy             : OUT std_logic );
   END COMPONENT;
   
   TYPE state_type IS (IDLE,GET_CONTROL,CHECK_CONTROL,SEND_CONTROL_ACK,
                       GET_HI_ADDRESS,SEND_HI_ADDR_ACK,GET_LO_ADDRESS,
                       SEND_LO_ADDR_ACK,GET_DATA,SEND_DATA_ACK,
                       LATCH_DATA_OUT,WRITE_DATA, SAMPLE_DATA_ACK );
   
   SIGNAL s_scl_neg_edge     : std_logic;
   SIGNAL s_scl_pos_edge     : std_logic;
   SIGNAL s_scl_value        : std_logic;
   SIGNAL s_sda_neg_edge     : std_logic;
   SIGNAL s_sda_pos_edge     : std_logic;
   SIGNAL s_sda_value        : std_logic;
   SIGNAL s_start_condition  : std_logic;
   SIGNAL s_stop_condition   : std_logic;
   SIGNAL s_shift_reg        : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_bit_count_reg    : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_state_reg        : state_type;
   SIGNAL s_next_state       : state_type;
   SIGNAL s_sda_out_next     : std_logic;
   SIGNAL s_address_reg      : std_logic_vector(11 DOWNTO 0 );
   SIGNAL s_shift_next       : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_spi_busy         : std_logic;
   SIGNAL s_i2c_write_done   : std_logic;
   SIGNAL s_read_request     : std_logic;
   SIGNAL s_write_request    : std_logic;
   SIGNAL s_read_request_reg : std_logic;
   SIGNAL s_write_request_reg: std_logic;

BEGIN
   -- Assign outputs
   make_SDA_out : PROCESS( clock , reset , s_sda_out_next , s_scl_neg_edge )
      VARIABLE v_enable_reg : std_logic;
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN SDA_out      <= '1';
                               v_enable_reg := '0';
                          ELSE
            IF (v_enable_reg = '1') THEN SDA_out <= s_sda_out_next;
            END IF;
            v_enable_reg := s_scl_neg_edge;
         END IF;
      END IF;
   END PROCESS make_SDA_out;
   
   -- Define control signals
   s_read_request    <= '1' WHEN s_start_condition = '1' OR
                                 (s_state_reg = LATCH_DATA_OUT AND
                                  s_scl_neg_edge = '1') ELSE '0';
   s_write_request   <= '1' WHEN (s_state_reg = SEND_DATA_ACK AND
                                  s_scl_pos_edge = '1') ELSE '0';
   s_i2c_write_done  <= s_start_condition OR s_stop_condition;
   s_start_condition <= s_scl_value AND s_sda_neg_edge;
   s_stop_condition  <= s_scl_value AND s_sda_pos_edge;
   s_sda_out_next    <= '0' 
                        WHEN s_state_reg = SEND_CONTROL_ACK OR
                             s_state_reg = SEND_HI_ADDR_ACK OR
                             s_state_reg = SEND_LO_ADDR_ACK OR
                             s_state_reg = SEND_DATA_ACK
                        ELSE
                        s_shift_reg(7) OR NOT(button)
                        WHEN s_state_reg = WRITE_DATA
                        ELSE '1';
   
   -- Define processes
   make_regs : PROCESS( clock , reset , s_read_request , s_write_request )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_read_request_reg <= '0';
                               s_write_request_reg <= '0';
                          ELSE s_read_request_reg <= s_read_request;
                               s_write_request_reg <= s_write_request;
         END IF;
      END IF;
   END PROCESS make_regs;
   
   make_shift_reg : PROCESS( clock , s_state_reg , s_sda_value , s_scl_pos_edge )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_scl_pos_edge = '1' AND
             (s_state_reg = GET_CONTROL OR
              s_state_reg = GET_DATA)) THEN
            s_shift_reg <= s_shift_reg(6 DOWNTO 0)&s_sda_value;
         ELSIF (s_scl_neg_edge = '1' AND
                s_state_reg = LATCH_DATA_OUT) THEN
            s_shift_reg <= s_shift_next;
         ELSIF (s_scl_neg_edge = '1' AND
                s_state_reg = WRITE_DATA) THEN
            s_shift_reg <= s_shift_reg(6 DOWNTO 0)&"1";
         END IF;
      END IF;
   END PROCESS make_shift_reg;
   
   make_bit_count_reg : PROCESS( clock , s_state_reg , s_scl_pos_edge ,
                                 s_start_condition )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_state_reg = IDLE OR
             s_state_reg = SEND_CONTROL_ACK OR
             s_state_reg = SEND_HI_ADDR_ACK OR
             s_state_reg = SEND_LO_ADDR_ACK OR
             s_state_reg = SEND_DATA_ACK OR
             s_start_condition = '1') THEN s_bit_count_reg <= X"0";
         ELSIF (s_state_reg = LATCH_DATA_OUT) THEN s_bit_count_reg <= X"1";
         ELSIF (((s_state_reg = GET_CONTROL OR
                  s_state_reg = GET_HI_ADDRESS OR
                  s_state_reg = GET_LO_ADDRESS OR
                  s_state_reg = GET_DATA)AND
                 s_scl_pos_edge = '1') OR
                (s_state_reg = WRITE_DATA AND
                 s_scl_neg_edge = '1')) THEN 
            s_bit_count_reg <= unsigned(s_bit_count_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_bit_count_reg;
   
   make_address_reg : PROCESS( clock , s_state_reg , s_sda_value , 
                               s_scl_pos_edge , reset , s_scl_neg_edge )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_address_reg <= (OTHERS => '0');
         ELSIF (s_scl_pos_edge = '1') THEN
            CASE (s_state_reg) IS
               WHEN GET_HI_ADDRESS => s_address_reg <= 
                                      s_address_reg(10 DOWNTO 8)&s_sda_value&
                                      s_address_reg( 7 DOWNTO 0);
               WHEN GET_LO_ADDRESS => s_address_reg <=
                                      s_address_reg(11 DOWNTO 8)&
                                      s_address_reg( 6 DOWNTO 0)&s_sda_value;
               WHEN OTHERS         => NULL;
            END CASE;
         ELSIF (s_scl_pos_edge = '1' AND
                s_state_reg = SEND_DATA_ACK) OR
               (s_scl_neg_edge = '1' AND
                s_state_reg = LATCH_DATA_OUT) THEN
            s_address_reg <= unsigned(s_address_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_address_reg;
   
   make_next_state : PROCESS( s_state_reg , s_stop_condition ,
                              s_start_condition , s_bit_count_reg , s_shift_reg ,
                              s_scl_neg_edge , s_scl_pos_edge , s_spi_busy )
   BEGIN
      CASE (s_state_reg) IS
         WHEN GET_CONTROL        => IF (s_bit_count_reg(3) = '1') THEN
                                       s_next_state <= CHECK_CONTROL;
                                                                  ELSE
                                       s_next_state <= GET_CONTROL;
                                    END IF;
         WHEN CHECK_CONTROL      => IF (s_shift_reg(7 DOWNTO 1) /= "1010001" OR
                                        s_spi_busy = '1') THEN
                                       s_next_state <= IDLE;
                                    ELSIF (s_scl_neg_edge = '1') THEN
                                       s_next_state <= SEND_CONTROL_ACK;
                                                                 ELSE
                                       s_next_state <= CHECK_CONTROL;
                                    END IF;
         WHEN SEND_CONTROL_ACK   => IF (s_scl_pos_edge = '1') THEN
                                       IF (s_shift_reg(0) = '0') THEN
                                          s_next_state <= GET_HI_ADDRESS;
                                                                 ELSE
                                          s_next_state <= LATCH_DATA_OUT;
                                       END IF;
                                                                 ELSE
                                       s_next_state <= SEND_CONTROL_ACK;
                                    END IF;
         WHEN GET_HI_ADDRESS     => IF (s_bit_count_reg(3) = '1') THEN
                                       s_next_state <= SEND_HI_ADDR_ACK;
                                                                  ELSE
                                       s_next_state <= GET_HI_ADDRESS;
                                    END IF;
         WHEN SEND_HI_ADDR_ACK   => IF (s_scl_pos_edge = '1') THEN
                                       s_next_state <= GET_LO_ADDRESS;
                                                              ELSE
                                       s_next_state <= SEND_HI_ADDR_ACK;
                                    END IF;
         WHEN GET_LO_ADDRESS     => IF (s_bit_count_reg(3) = '1') THEN
                                       s_next_state <= SEND_LO_ADDR_ACK;
                                                                  ELSE
                                       s_next_state <= GET_LO_ADDRESS;
                                    END IF;
         WHEN SEND_LO_ADDR_ACK   => IF (s_scl_pos_edge = '1') THEN
                                       s_next_state <= GET_DATA;
                                                              ELSE
                                       s_next_state <= SEND_LO_ADDR_ACK;
                                    END IF;
         WHEN GET_DATA           => IF (s_bit_count_reg(3) = '1') THEN
                                       s_next_state <= SEND_DATA_ACK;
                                                                  ELSE
                                       s_next_state <= GET_DATA;
                                    END IF;
         WHEN SEND_DATA_ACK      => IF (s_scl_pos_edge = '1') THEN
                                       s_next_state <= GET_DATA;
                                                              ELSE
                                       s_next_state <= SEND_DATA_ACK;
                                    END IF;
         WHEN LATCH_DATA_OUT     => IF (s_scl_neg_edge = '1') THEN
                                       s_next_state <= WRITE_DATA;
                                                              ELSE
                                       s_next_state <= LATCH_DATA_OUT;
                                    END IF;
         WHEN WRITE_DATA         => IF (s_bit_count_reg(3) = '1' AND
                                        s_scl_pos_edge = '1') THEN
                                       s_next_state <= SAMPLE_DATA_ACK;
                                                                 ELSE
                                       s_next_state <= WRITE_DATA;
                                    END IF;
         WHEN SAMPLE_DATA_ACK    => IF (s_scl_pos_edge = '1') THEN
                                       IF (s_sda_value = '0') THEN
                                          s_next_state <= LATCH_DATA_OUT;
                                                              ELSE
                                          s_next_state <= IDLE;
                                       END IF;
                                                              ELSE
                                          s_next_state <= SAMPLE_DATA_ACK;
                                    END IF;
         WHEN OTHERS             => s_next_state <= IDLE;
      END CASE;
   END PROCESS make_next_state;
   
   make_state_reg : PROCESS( clock , reset , s_stop_condition ,
                             s_start_condition , s_next_state ) 
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             s_stop_condition = '1') THEN s_state_reg <= IDLE;
         ELSIF (s_start_condition = '1') THEN s_state_reg <= GET_CONTROL;
                                         ELSE s_state_reg <= s_next_state;
         END IF;
      END IF;
   END PROCESS make_state_reg;

   -- Map components
   scl_det : edge_detector
             PORT MAP ( clock    => clock,
                        reset    => reset,
                        data_in  => SCL_in,
                        pos_edge => s_scl_pos_edge,
                        neg_edge => s_scl_neg_edge,
                        data_out => s_scl_value );
   sda_det : edge_detector
             PORT MAP ( clock    => clock,
                        reset    => reset,
                        data_in  => SDA_in,
                        pos_edge => s_sda_pos_edge,
                        neg_edge => s_sda_neg_edge,
                        data_out => s_sda_value );
   spi : spi_if
         PORT MAP ( clock            => clock,
                    reset            => reset,
                    read_request     => s_read_request_reg,
                    write_request    => s_write_request_reg,
                    i2c_write_done   => s_i2c_write_done,
                    address          => s_address_reg,
                    data_in          => s_shift_reg,
                    data_out         => s_shift_next,
                    done             => OPEN,
                    busy             => s_spi_busy );

END xilinx;
