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

ARCHITECTURE xilinx OF fifo_4kb_16w_8r IS

   COMPONENT RAMB16_S9_S9
      GENERIC ( WRITE_MODE_A : string := "READ_FIRST";
                WRITE_MODE_B : string := "READ_FIRST" );
      PORT (  DOA   : OUT std_logic_vector( 7 DOWNTO 0);
              ADDRA : IN  std_logic_vector(10 DOWNTO 0);
              DIA   : IN  std_logic_vector( 7 DOWNTO 0);
              ENA   : IN  std_ulogic;
              WEA   : IN  std_ulogic;
              DOPA  : OUT std_logic_vector( 0 DOWNTO 0);
              CLKA  : IN  std_ulogic;
              DIPA  : IN  std_logic_vector( 0 DOWNTO 0);
              SSRA  : IN  std_ulogic;
              DOPB  : OUT std_logic_vector( 0 DOWNTO 0);
              CLKB  : IN  std_ulogic;
              DIPB  : IN  std_logic_vector( 0 DOWNTO 0);
              SSRB  : IN  std_ulogic;
              DOB   : OUT std_logic_vector( 7 DOWNTO 0);
              ADDRB : IN  std_logic_vector(10 DOWNTO 0);
              DIB   : IN  std_logic_vector( 7 DOWNTO 0);
              ENB   : IN  std_ulogic;
              WEB   : IN  std_ulogic );
   END COMPONENT;
   
   CONSTANT c_threshold        : std_logic_vector(12 DOWNTO 0 ) := "0"&X"FFD";
   
   SIGNAL s_write_address_reg  : std_logic_vector(10 DOWNTO 0 );
   SIGNAL s_write_address_next : std_logic_vector(10 DOWNTO 0 );
   SIGNAL s_read_address_reg   : std_logic_vector(11 DOWNTO 0 );
   SIGNAL s_read_address_next  : std_logic_vector(11 DOWNTO 0 );
   SIGNAL s_nr_of_bytes_reg    : std_logic_vector(12 DOWNTO 0 );
   SIGNAL s_nr_of_bytes_next   : std_logic_vector(12 DOWNTO 0 );
   SIGNAL s_full               : std_logic;
   SIGNAL s_empty              : std_logic;
   SIGNAL s_execute_push       : std_logic;
   SIGNAL s_execute_pop        : std_logic;
   SIGNAL s_n_clock            : std_logic;
   SIGNAL s_pop_data_lo        : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_pop_data_hi        : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_pop_size_lo        : std_logic;
   SIGNAL s_pop_size_hi        : std_logic;
   
BEGIN
-- Assign outputs
   fifo_full   <= s_full;
   fifo_empty  <= s_empty;
   pop_data    <= s_pop_data_lo WHEN s_read_address_reg(0) = '0' ELSE s_pop_data_hi;
   pop_size    <= s_pop_size_lo WHEN s_read_address_reg(0) = '0' ELSE s_pop_size_hi;
   byte_cnt    <= s_nr_of_bytes_reg;

-- Assign control signals
   s_read_address_next  <= unsigned(s_read_address_reg) + 1;
   s_write_address_next <= unsigned(s_write_address_reg) + 1;
                           
   s_execute_push       <= push AND NOT(s_nr_of_bytes_reg(12));
   s_execute_pop        <= pop  AND NOT(s_empty);
   s_n_clock            <= NOT(clock);
   s_full               <= s_nr_of_bytes_reg(12);
   s_empty              <= '1' WHEN s_nr_of_bytes_reg = "0000000000000" ELSE '0';

-- define processes
   make_nr_of_bytes_next : PROCESS( s_execute_push , s_execute_pop ,
                                    s_nr_of_bytes_reg )
      VARIABLE v_add : std_logic_vector(12 DOWNTO 0 );
      VARIABLE v_sel : std_logic_vector( 1 DOWNTO 0 );
   BEGIN
      v_sel := s_execute_push&s_execute_pop;
      CASE (v_sel) IS
         WHEN  "00"  => v_add := "0"&X"000";
         WHEN  "01"  => v_add := "1"&X"FFF";
         WHEN  "10"  => v_add := "0"&X"002";
         WHEN OTHERS => v_add := "0"&X"001";
      END CASE;
      s_nr_of_bytes_next <= unsigned(s_nr_of_bytes_reg)+
                            unsigned(v_add);
   END PROCESS make_nr_of_bytes_next;
   
   make_read_address_reg : PROCESS( clock , reset , s_execute_pop ,
                                    s_read_address_next )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_read_address_reg <= (OTHERS => '0');
         ELSIF (s_execute_pop = '1') THEN 
            s_read_address_reg <= s_read_address_next;
         END IF;
      END IF;
   END PROCESS make_read_address_reg;
   
   make_write_address_reg : PROCESS( clock , reset , s_execute_push ,
                                     s_write_address_next )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_write_address_reg <= (OTHERS => '0');
         ELSIF (s_execute_push = '1') THEN
            s_write_address_reg <= s_write_address_next;
         END IF;
      END IF;
   END PROCESS make_write_address_reg;
   
   make_nr_of_bytes_reg : PROCESS( clock , reset , s_nr_of_bytes_next )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_nr_of_bytes_reg <= (OTHERS => '0');
                          ELSE s_nr_of_bytes_reg <= s_nr_of_bytes_next;
         END IF;
      END IF;
   END PROCESS make_nr_of_bytes_reg;
   
-- map components
   ram1 : RAMB16_S9_S9
          GENERIC MAP ( WRITE_MODE_A => "READ_FIRST",
                        WRITE_MODE_B => "READ_FIRST" )
          PORT MAP (  DOA     => OPEN,
                      ADDRA   => s_write_address_reg,
                      DIA     => push_data( 7 DOWNTO 0 ),
                      ENA     => s_execute_push,
                      WEA     => s_execute_push,
                      DOPA    => OPEN,
                      CLKA    => clock,
                      DIPA(0) => push_size,
                      SSRA    => '0',
                      DOPB(0) => s_pop_size_lo,
                      CLKB    => s_n_clock,
                      DIPB    => "0",
                      SSRB    => '0',
                      DOB     => s_pop_data_lo,
                      ADDRB   => s_read_address_reg(11 DOWNTO 1),
                      DIB     => X"00",
                      ENB     => '1',
                      WEB     => '0' );
   ram2 : RAMB16_S9_S9
          GENERIC MAP ( WRITE_MODE_A => "READ_FIRST",
                        WRITE_MODE_B => "READ_FIRST" )
          PORT MAP (  DOA     => OPEN,
                      ADDRA   => s_write_address_reg,
                      DIA     => push_data(15 DOWNTO 8 ),
                      ENA     => s_execute_push,
                      WEA     => s_execute_push,
                      DOPA    => OPEN,
                      CLKA    => clock,
                      DIPA(0) => push_size,
                      SSRA    => '0',
                      DOPB(0) => s_pop_size_hi,
                      CLKB    => s_n_clock,
                      DIPB    => "0",
                      SSRB    => '0',
                      DOB     => s_pop_data_hi,
                      ADDRB   => s_read_address_reg(11 DOWNTO 1),
                      DIB     => X"00",
                      ENB     => '1',
                      WEB     => '0' );
END xilinx;
