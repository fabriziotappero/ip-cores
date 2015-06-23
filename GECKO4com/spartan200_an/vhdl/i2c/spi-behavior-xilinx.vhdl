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

library UNISIM;
use UNISIM.VComponents.all;

ARCHITECTURE xilinx OF spi_if IS

   TYPE STATE_TYPE IS (IDLE,INIT_READ,WAIT_READ,ALL_DONE,
                       INIT_PAGE_LOAD,WAIT_I2C_DONE,INIT_STATE_REG_1,
                       POLL_STATE_REG_1,INIT_WRITE,WAIT_WRITE, INIT_WRITE_BACK ,
                       WAIT_WRITE_BACK,INIT_STATE_REG_2,POLL_STATE_REG_2);

   COMPONENT SPI_ACCESS
      GENERIC ( SIM_DEVICE : string );
      PORT( MISO : OUT std_ulogic;
            CLK  : IN  std_ulogic;
            CSB  : IN  std_ulogic;
            MOSI : IN  std_ulogic );
   END COMPONENT;
   
   COMPONENT RAM32X1S
      PORT ( O    : OUT std_logic;
             A0   : IN  std_logic;
             A1   : IN  std_logic;
             A2   : IN  std_logic;
             A3   : IN  std_logic;
             A4   : IN  std_logic;
             D    : IN  std_logic;
             WCLK : IN  std_logic;
             WE   : IN  std_logic);
   END COMPONENT;
   
   SIGNAL s_state_reg             : STATE_TYPE;
   SIGNAL s_spi_shift_reg         : std_logic_vector(31 DOWNTO 0 );
   SIGNAL s_spi_shift_next        : std_logic_vector(31 DOWNTO 0 );
   SIGNAL s_spi_shift_load        : std_logic_vector(31 DOWNTO 0 );
   SIGNAL s_n_ena_spi             : std_logic;
   SIGNAL s_spi_miso              : std_logic;
   SIGNAL s_spi_count_reg         : std_logic_vector( 9 DOWNTO 0 );
   SIGNAL s_spi_count_load        : std_logic_vector( 9 DOWNTO 0 );
   SIGNAL s_start_spi_action      : std_logic;
   SIGNAL s_spi_clk_reg           : std_logic;
   SIGNAL s_spi_mosi              : std_logic;
   SIGNAL s_spi_ram_index_reg     : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_spi_size_reg          : std_logic_vector( 5 DOWNTO 0 );
   SIGNAL s_spi_address_reg       : std_logic_vector(11 DOWNTO 0 );
   SIGNAL s_load_data_byte        : std_logic;
   SIGNAL s_buffer_data           : std_logic_vector( 7 DOWNTO 0 );

BEGIN
   -- Assign outputs
   data_out          <= s_spi_shift_reg( 7 DOWNTO 0 );
   done              <= '1' WHEN s_state_reg = ALL_DONE ELSE '0';
   busy              <= '0' WHEN s_state_reg = IDLE OR
                                 s_state_reg = INIT_READ OR
                                 s_state_reg = WAIT_READ OR
                                 s_state_reg = ALL_DONE ELSE '1';
   
   -- Assign control signals
   s_start_spi_action <= '1' WHEN s_state_reg = INIT_READ OR
                                  s_state_reg = INIT_PAGE_LOAD OR
                                  s_state_reg = INIT_STATE_REG_1 OR
                                  s_state_reg = INIT_WRITE OR
                                  s_state_reg = INIT_WRITE_BACK OR
                                  s_state_reg = INIT_STATE_REG_2 ELSE '0';
   
   s_n_ena_spi       <= s_spi_count_reg(9) AND NOT(s_spi_count_reg(0));
   s_load_data_byte  <= '1' WHEN s_state_reg = WAIT_WRITE AND
                                 s_spi_count_reg( 2 DOWNTO 0 ) = "000" AND
                                 s_spi_clk_reg = '1' ELSE '0';
   s_spi_shift_next  <= s_spi_shift_load
                           WHEN s_start_spi_action = '1' ELSE
                        s_spi_shift_reg WHEN s_n_ena_spi = '1' OR
                                             s_spi_clk_reg = '0' ELSE
                        s_spi_shift_reg(30 DOWNTO 7)&s_buffer_data
                                        WHEN s_load_data_byte = '1' ELSE
                        s_spi_shift_reg(30 DOWNTO 0)&s_spi_miso;
                        
   -- map processes
   make_spi_load_values : PROCESS( s_state_reg , address ,
                                   s_spi_address_reg )
      VARIABLE v_select : std_logic_vector( 1 DOWNTO 0 );
      VARIABLE v_add    : std_logic_vector( 5 DOWNTO 0 );
   BEGIN
      CASE (s_state_reg) IS
         WHEN INIT_READ       => s_spi_shift_load <= X"030F"&"111"&
                                                     s_spi_address_reg(11 DOWNTO 8)&"0"&
                                                     s_spi_address_reg(7 DOWNTO 0);
                                 s_spi_count_load <= "0000100111";
         WHEN INIT_PAGE_LOAD  => s_spi_shift_load <= X"530F"&"111"&
                                                     s_spi_address_reg(11 DOWNTO 8)&"0"&
                                                     X"00";
                                 s_spi_count_load <= "0000011111";
         WHEN INIT_STATE_REG_1 |
              INIT_STATE_REG_2=> s_spi_shift_load <= X"D7000000";
                                 s_spi_count_load <= "0000001111";
         WHEN INIT_WRITE      => s_spi_shift_load <= X"840000"&s_spi_address_reg(7 DOWNTO 0);
                                 v_add := unsigned(s_spi_size_reg) + 3;
                                 s_spi_count_load <= "0"&v_add&"111";
         WHEN INIT_WRITE_BACK => s_spi_shift_load <= X"830F"&"111"&
                                                     s_spi_address_reg(11 DOWNTO 8)&"0"&
                                                     X"00";
                                 s_spi_count_load <= "0000011111";
         WHEN OTHERS          => s_spi_shift_load <= X"00000000";
                                 s_spi_count_load <= "1111111110";
      END CASE;
   END PROCESS make_spi_load_values;
   
   make_state_machine : PROCESS( clock , reset , s_state_reg ,
                                 read_request , s_spi_count_reg ,
                                 write_request , i2c_write_done ,
                                 s_spi_shift_reg )
      VARIABLE v_next_state : STATE_TYPE;
   BEGIN
      CASE (s_state_reg) IS
         WHEN IDLE               => IF (read_request = '1') THEN
                                       v_next_state := INIT_READ;
                                    ELSIF (write_request = '1') THEN
                                       v_next_state := INIT_PAGE_LOAD;
                                                            ELSE
                                       v_next_state := IDLE;
                                    END IF;
         WHEN INIT_READ          => v_next_state := WAIT_READ;
         WHEN WAIT_READ          => IF (s_spi_count_reg(9) = '1') THEN
                                       v_next_state := ALL_DONE;
                                                                  ELSE
                                       v_next_state := WAIT_READ;
                                    END IF;
         WHEN INIT_PAGE_LOAD     => v_next_state := WAIT_I2C_DONE;
         WHEN WAIT_I2C_DONE      => IF (i2c_write_done = '1') THEN
                                       v_next_state := INIT_STATE_REG_1;
                                                              ELSE
                                       v_next_state := WAIT_I2C_DONE;
                                    END IF;
         WHEN INIT_STATE_REG_1   => v_next_state := POLL_STATE_REG_1;
         WHEN POLL_STATE_REG_1   => IF (s_spi_count_reg(9) = '1' AND
                                        s_spi_count_reg(0) = '0') THEN
                                       IF (s_spi_shift_reg(7) = '0') THEN
                                          v_next_state := INIT_STATE_REG_1;
                                                                     ELSE
                                          v_next_state := INIT_WRITE;
                                       END IF;
                                                                  ELSE
                                       v_next_state := POLL_STATE_REG_1;
                                    END IF;
         WHEN INIT_WRITE         => v_next_state := WAIT_WRITE;
         WHEN WAIT_WRITE         => IF (s_spi_count_reg(9) = '1' AND
                                        s_spi_count_reg(0) = '0') THEN
                                       v_next_state := INIT_WRITE_BACK;
                                                                  ELSE
                                       v_next_state := WAIT_WRITE;
                                    END IF;
         WHEN INIT_WRITE_BACK    => v_next_state := WAIT_WRITE_BACK;
         WHEN WAIT_WRITE_BACK    => IF (s_spi_count_reg(9) = '1' AND
                                        s_spi_count_reg(0) = '0') THEN
                                       v_next_state := INIT_STATE_REG_2;
                                                                  ELSE
                                       v_next_state := WAIT_WRITE_BACK;
                                    END IF;
         WHEN INIT_STATE_REG_2   => v_next_state := POLL_STATE_REG_2;
         WHEN POLL_STATE_REG_2   => IF (s_spi_count_reg(9) = '1' AND
                                        s_spi_count_reg(0) = '0') THEN
                                       IF (s_spi_shift_reg(7) = '0') THEN
                                          v_next_state := INIT_STATE_REG_2;
                                                                     ELSE
                                          v_next_state := ALL_DONE;
                                       END IF;
                                                                  ELSE
                                       v_next_state := POLL_STATE_REG_2;
                                    END IF;
         WHEN OTHERS             => v_next_state := IDLE;
      END CASE;
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_state_reg <= IDLE;
                          ELSE s_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_state_machine;


   make_spi_count_reg : PROCESS( clock , reset , s_spi_count_reg ,
                                 s_start_spi_action )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_spi_count_reg <= (0 => '0' , OTHERS => '1');
         ELSIF (s_start_spi_action = '1') THEN s_spi_count_reg <= s_spi_count_load;
         ELSIF ((s_spi_count_reg(9) = '0' OR
                 s_spi_count_reg(0) = '1') AND
                (s_spi_clk_reg = '0' OR
                 (s_spi_count_reg(9) = '1' AND
                  s_spi_count_reg(0) = '1'))) THEN
            s_spi_count_reg <= unsigned(s_spi_count_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_spi_count_reg;
   
   make_spi_shift_reg : PROCESS( clock , s_spi_shift_next )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         s_spi_shift_reg <= s_spi_shift_next;
      END IF;
   END PROCESS make_spi_shift_reg;
   
   make_spi_clock_reg : PROCESS( clock , s_spi_count_reg , reset )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_spi_count_reg(9) = '1') THEN s_spi_clk_reg <= '1';
                                       ELSE s_spi_clk_reg <= NOT(s_spi_clk_reg);
         END IF;
      END IF;
   END PROCESS make_spi_clock_reg;
   
   make_spi_mosi : PROCESS( clock , s_spi_clk_reg , s_spi_shift_reg ,
                            reset )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_spi_clk_reg = '1') THEN s_spi_mosi <= s_spi_shift_reg(31);
         END IF;
      END IF;
   END PROCESS make_spi_mosi;
   
   make_spi_ram_index_reg : PROCESS( clock , reset , s_state_reg ,
                                     write_request , s_load_data_byte )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             s_state_reg = ALL_DONE OR
             s_state_reg = INIT_WRITE) THEN s_spi_ram_index_reg <= (OTHERS => '0');
               IF (s_state_reg /= INIT_WRITE) THEN
                  s_spi_size_reg      <= (OTHERS => '0');
               END IF;
         ELSIF (write_request = '1' OR
                s_load_data_byte = '1') THEN
            s_spi_ram_index_reg <= unsigned(s_spi_ram_index_reg) + 1;
            IF (s_spi_size_reg(5) = '0') THEN
               s_spi_size_reg <= unsigned(s_spi_size_reg) + 1;
            END IF;
         END IF;
      END IF;
   END PROCESS make_spi_ram_index_reg;
   
   make_spi_address_reg : PROCESS( clock , s_state_reg , write_request ,
                                   address , read_request )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF ((write_request = '1' AND
              s_state_reg = IDLE) OR
             read_request = '1') THEN
            s_spi_address_reg <= address;
         END IF;
      END IF;
   END PROCESS make_spi_address_reg;
   
   -- map components
   spiif: SPI_ACCESS
          GENERIC MAP ( SIM_DEVICE => "3S200AN" )
          PORT MAP ( MISO => s_spi_miso,
                     CLK  => s_spi_clk_reg,
                     CSB  => s_n_ena_spi,
                     MOSI => s_spi_mosi );
   write_buffer : FOR n IN 7 DOWNTO 0 GENERATE
      bufbit : RAM32X1S
               PORT MAP ( O    => s_buffer_data(n),
                          A0   => s_spi_ram_index_reg(0),
                          A1   => s_spi_ram_index_reg(1),
                          A2   => s_spi_ram_index_reg(2),
                          A3   => s_spi_ram_index_reg(3),
                          A4   => s_spi_ram_index_reg(4),
                          D    => data_in(n),
                          WCLK => clock,
                          WE   => write_request);
   END GENERATE write_buffer;

END xilinx;
