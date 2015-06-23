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

ARCHITECTURE no_platform_specific OF fpga_if IS

   COMPONENT FDE
      GENERIC( INIT : bit );
      PORT ( Q   : OUT std_logic;
             C   : IN  std_logic;
             CE  : IN  std_logic;
             D   : IN  std_logic );
   END COMPONENT;
   
   COMPONENT FD
      GENERIC( INIT : bit );
      PORT ( Q   : OUT std_logic;
             C   : IN  std_logic;
             D   : IN  std_logic );
   END COMPONENT;
   
   COMPONENT idreg_rom
      PORT( index : IN  std_logic_vector( 4 DOWNTO 0 );
            data  : OUT std_logic_vector( 7 DOWNTO 0 ) );
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
   
   TYPE FPGA_STATE_TYPE IS (IDLE , RESET_STATE , GENERATE_N_PROG , 
                            WAIT_N_INIT_HI , WAIT_AFTER_N_INIT , SET_RDNWR_LO ,
                            WAIT_RDNWR_LO , SET_N_CS_LO_WRITE , DO_WRITE , 
                            WAIT_DONE , SET_CS_HI_WRITE , WAIT_CS_HI_WRITE ,
                            SET_RDNWR_HI , WAIT_RDNWR_HI , SET_CS_LO_READ ,
                            DO_READ , SET_CS_HI_READ , WAIT_AFTER_DONE ,
                            DO_FLUSH , SIGNAL_ERROR );

   SIGNAL s_fpga_state_reg      : FPGA_STATE_TYPE;
   SIGNAL s_data_to_fpga        : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_data_from_fpga      : std_logic_vector( 7 DOWNTO 0 );
   
   SIGNAL s_cclk_reg            : std_logic;
   SIGNAL s_n_prog_reg          : std_logic;
   SIGNAL s_n_cs_reg            : std_logic;
   SIGNAL s_rd_n_wr_reg         : std_logic;
   SIGNAL s_n_init              : std_logic;
   SIGNAL s_busy                : std_logic;
   SIGNAL s_done                : std_logic;
   SIGNAL s_ena_in_ffs          : std_logic;
   SIGNAL s_ena_out_ffs         : std_logic;
   
   SIGNAL s_wait_counter_reg    : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_wait_counter_load   : std_logic;
   SIGNAL s_wait_counter_ena    : std_logic;
   
   SIGNAL s_last_byte           : std_logic;
   SIGNAL s_next_idx_byte       : std_logic;
   SIGNAL s_last_idx_byte       : std_logic;
   SIGNAL s_idx_index_reg       : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_idx_data            : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_idx_count_reg       : std_logic_vector( 1 DOWNTO 0 );
   SIGNAL s_idx_valid_reg       : std_logic;
   SIGNAL s_idx_valid           : std_logic;
   SIGNAL s_first_time_reg      : std_logic;
   
   SIGNAL s_fpga_rev_reg        : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_fpga_type_reg       : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_valid_out_byte      : std_logic;
   SIGNAL s_n_cs_next           : std_logic;
   
   SIGNAL s_fifo_pop            : std_logic;
   SIGNAL s_fifo_data           : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_fifo_last_byte      : std_logic;
   SIGNAL s_fifo_empty          : std_logic;
   SIGNAL s_ena_fpga_data_in    : std_logic;
   SIGNAL s_ena_data_to_fpga    : std_logic;

BEGIN
   fpga_revision   <= s_fpga_rev_reg;
   fpga_configured <= s_done;
   fpga_idle       <= '1' WHEN s_fpga_state_reg = IDLE ELSE '0';
   
   fpga_type       <= s_fpga_type_reg;
   
   s_data_to_fpga    <= (OTHERS => '1') WHEN
                                           s_fpga_state_reg = GENERATE_N_PROG
                                        ELSE
                        s_idx_data WHEN s_first_time_reg = '1' ELSE
                        s_fifo_data;
   fpga_n_tri        <= X"00" WHEN s_rd_n_wr_reg = '0' ELSE (OTHERS => '1');
   fpga_data_in_ena  <= s_ena_fpga_data_in;
   fpga_data_out_ena <= s_ena_data_to_fpga;
   
   swap: FOR n IN 7 DOWNTO 0 GENERATE
      fpga_data_out(7-n)    <= s_data_to_fpga(n);
      s_data_from_fpga(7-n) <= fpga_data_in(n);
--    For simulation mask above and unmask below
--     in_ff : FDE
--             GENERIC MAP (INIT => '1')
--             PORT MAP ( Q  => s_data_from_fpga(n),
--                        CE => s_ena_fpga_data_in,
--                        C  => clock,
--                        D  => fpga_data_in(n));
--     one_ff : FDE
--              GENERIC MAP ( INIT => '1' )
--              PORT MAP ( Q  => fpga_data_out(n),
--                         CE => s_ena_data_to_fpga,
--                         C  => clock,
--                         D  => s_data_to_fpga(n) );
   END GENERATE swap;
   
-------------------------------------------------------------------------------
--- here all control signals are defined                                    ---
-------------------------------------------------------------------------------
   s_ena_in_ffs     <= s_cclk_reg;
   s_ena_out_ffs    <= NOT(s_cclk_reg);
   s_last_byte      <= s_last_idx_byte WHEN s_first_time_reg = '1' ELSE
                       s_fifo_last_byte;
   s_valid_out_byte <= s_ena_out_ffs
                          WHEN
                             s_fpga_state_reg = DO_WRITE AND
                             NOT (s_n_cs_reg = '0' AND
                                  s_busy = '1') AND
                             (s_first_time_reg = '1' OR
                              s_fifo_empty = '0')
                          ELSE '0';
   s_n_cs_next      <= '0' WHEN s_fpga_state_reg = DO_READ OR
                                (s_fpga_state_reg = DO_WRITE AND
                                 s_valid_out_byte = '1') OR
                                (s_n_cs_reg = '0' AND
                                 s_busy = '1') ELSE '1';
   s_ena_fpga_data_in <= s_ena_in_ffs WHEN
                                         s_fpga_state_reg = DO_READ
                                      ELSE '0';
   s_ena_data_to_fpga <= '1' WHEN 
                                s_valid_out_byte = '1' OR
                                s_fpga_state_reg = GENERATE_N_PROG
                             ELSE '0';

-------------------------------------------------------------------------------
--- Here the IOB intermediate flipflops are defined                         ---
-------------------------------------------------------------------------------
   make_cclk_reg : PROCESS( clock , reset , s_fpga_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             s_fpga_state_reg = IDLE) THEN s_cclk_reg <= '1';
                                      ELSE s_cclk_reg <= NOT(s_cclk_reg);
         END IF;
      END IF;
   END PROCESS make_cclk_reg;
   
   make_n_prog_reg : PROCESS( clock , s_fpga_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_fpga_state_reg = GENERATE_N_PROG) THEN s_n_prog_reg <= '0';
                                                 ELSE s_n_prog_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_n_prog_reg;
   
   make_n_cs_reg : PROCESS( clock , s_ena_out_ffs )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_ena_out_ffs = '1') THEN
            s_n_cs_reg <= s_n_cs_next;
         END IF;
      END IF;
   END PROCESS make_n_cs_reg;
   
   make_rd_n_wr_reg : PROCESS( clock , reset , s_fpga_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             s_fpga_state_reg = RESET_STATE OR
             s_fpga_state_reg = SET_RDNWR_HI OR
             s_fpga_state_reg = DO_FLUSH) THEN s_rd_n_wr_reg <= '1';
         ELSIF (s_fpga_state_reg = SET_RDNWR_LO) THEN s_rd_n_wr_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_rd_n_wr_reg;
   
   make_crc_error : PROCESS( clock , s_fpga_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_fpga_state_reg = RESET_STATE) THEN fpga_crc_error <= '0';
         ELSIF (s_fpga_state_reg = SIGNAL_ERROR) THEN fpga_crc_error <= '1';
         END IF;
      END IF;
   END PROCESS make_crc_error;

-------------------------------------------------------------------------------
--- Here the state machine is defined                                       ---
-------------------------------------------------------------------------------
   fpga_state_machine : PROCESS( clock , reset , s_fpga_state_reg ,
                                 s_wait_counter_reg , s_n_init , s_idx_valid ,
                                 s_idx_count_reg )
      VARIABLE v_next_state : FPGA_STATE_TYPE;
   BEGIN
      CASE (s_fpga_state_reg) IS
         WHEN RESET_STATE           => v_next_state := GENERATE_N_PROG;
         WHEN GENERATE_N_PROG       => IF (s_wait_counter_reg(7) = '1' AND
                                           s_n_init = '0') THEN
                                          v_next_state := WAIT_N_INIT_HI;
                                                           ELSE
                                          v_next_state := GENERATE_N_PROG;
                                       END IF;
         WHEN WAIT_N_INIT_HI        => IF (s_n_init = '1') THEN 
                                          v_next_state := WAIT_AFTER_N_INIT;
                                                           ELSE
                                          v_next_state := WAIT_N_INIT_HI;
                                       END IF;
         WHEN WAIT_AFTER_N_INIT     => IF (s_wait_counter_reg(7) = '1') THEN
                                          v_next_state := SET_RDNWR_LO;
                                                                        ELSE
                                          v_next_state := WAIT_AFTER_N_INIT;
                                       END IF;
         WHEN SET_RDNWR_LO          => v_next_state := WAIT_RDNWR_LO;
         WHEN WAIT_RDNWR_LO         => IF (s_wait_counter_reg(7) = '1' AND
                                           s_ena_out_ffs = '1') THEN
                                          v_next_state := SET_N_CS_LO_WRITE;
                                                                    ELSE
                                          v_next_state := WAIT_RDNWR_LO;
                                       END IF;
         WHEN SET_N_CS_LO_WRITE     => v_next_state := DO_WRITE;
         WHEN DO_WRITE              => IF (s_last_byte = '1' AND
                                           s_valid_out_byte = '1') THEN
                                          v_next_state := SET_CS_HI_WRITE;
                                       ELSIF (s_n_init = '0') THEN
                                          v_next_state := DO_FLUSH;
                                                                ELSE
                                          v_next_state := DO_WRITE;
                                       END IF;
         WHEN SET_CS_HI_WRITE       => IF (s_n_cs_reg = '1') THEN
                                          v_next_state := WAIT_CS_HI_WRITE;
                                                             ELSE
                                          v_next_state := SET_CS_HI_WRITE;
                                       END IF;
         WHEN WAIT_CS_HI_WRITE      => IF (s_wait_counter_reg(7) = '1') THEN
                                          v_next_state := SET_RDNWR_HI;
                                                                        ELSE
                                          v_next_state := WAIT_CS_HI_WRITE;
                                       END IF;
         WHEN SET_RDNWR_HI          => v_next_state := WAIT_RDNWR_HI;
         WHEN WAIT_RDNWR_HI         => IF (s_wait_counter_reg(7) = '1' AND
                                           s_ena_out_ffs = '1') THEN
                                          IF (s_first_time_reg = '1') THEN
                                             v_next_state := SET_CS_LO_READ;
                                                                      ELSE
                                             v_next_state := WAIT_DONE;
                                          END IF;
                                                                ELSE
                                          v_next_state := WAIT_RDNWR_HI;
                                       END IF;
         WHEN SET_CS_LO_READ        => v_next_state := DO_READ;
         WHEN DO_READ               => IF (s_idx_valid = '1' AND
                                           s_idx_count_reg = "11") THEN 
                                          v_next_state := SET_CS_HI_READ;
                                                         ELSE
                                          v_next_state := DO_READ;
                                       END IF;
         WHEN WAIT_DONE             => IF (s_done = '1') THEN 
                                          v_next_state := WAIT_AFTER_DONE;
                                                         ELSE
                                          v_next_state := WAIT_DONE;
                                       END IF;
         WHEN WAIT_AFTER_DONE       => IF (s_wait_counter_reg(7) = '1') THEN
                                          v_next_state := IDLE;
                                                                        ELSE
                                          v_next_state := WAIT_AFTER_DONE;
                                       END IF;
         WHEN IDLE                  => IF (s_fifo_empty = '0') THEN
                                          v_next_state := RESET_STATE;
                                                               ELSE
                                          v_next_state := IDLE;
                                       END IF;
         WHEN DO_FLUSH              => IF (s_last_byte = '1' OR
                                           s_first_time_reg = '1') THEN
                                          v_next_state := SIGNAL_ERROR;
                                                                   ELSE
                                          v_next_state := DO_FLUSH;
                                       END IF;
         WHEN OTHERS                => v_next_state := IDLE;
      END CASE;
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_fpga_state_reg <= RESET_STATE;
                          ELSE s_fpga_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS fpga_state_machine;
   
-------------------------------------------------------------------------------
--- Here the identification signals are defined                             ---
-------------------------------------------------------------------------------

   s_next_idx_byte  <= '1' WHEN
                              s_fpga_state_reg = DO_WRITE AND
                              s_ena_out_ffs = '1' AND
                              NOT( s_n_cs_reg = '0' AND
                                   s_busy = '1' ) AND
                              s_first_time_reg = '1'
                           ELSE '0';
   s_last_idx_byte  <= '1' WHEN
                              s_idx_index_reg = "00000"
                           ELSE '0';
   s_idx_valid      <= '1' WHEN
                              s_idx_valid_reg = '1' AND
                              s_first_time_reg = '1' AND
                              s_busy = '0'
                           ELSE '0';
                           
   make_idx_valid : PROCESS( clock , s_fpga_state_reg ,
                             s_ena_in_ffs )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_fpga_state_reg = DO_READ) THEN
            s_idx_valid_reg <= s_ena_in_ffs;
                                         ELSE
            s_idx_valid_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_idx_valid;
   
   make_idx_count_reg : PROCESS( clock , reset , s_idx_valid )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_idx_count_reg <= "00";
         ELSIF (s_idx_valid = '1') THEN
            s_idx_count_reg <= unsigned(s_idx_count_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_idx_count_reg;
   
   make_idx_index_reg : PROCESS( clock , reset , s_next_idx_byte )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_idx_index_reg <= "10011";
         ELSIF (s_next_idx_byte = '1') THEN
            s_idx_index_reg <= unsigned(s_idx_index_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_idx_index_reg;
   
   make_fpga_rev_reg : PROCESS( clock , reset , s_idx_valid ,
                                s_idx_count_reg , s_data_from_fpga )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_fpga_rev_reg <= X"F";
         ELSIF (s_idx_valid = '1' AND
                s_idx_count_reg = "00") THEN
            s_fpga_rev_reg <= s_data_from_fpga( 7 DOWNTO 4 );
         END IF;
      END IF;
   END PROCESS make_fpga_rev_reg;
   
   make_fpga_type_reg : PROCESS( clock , reset , s_idx_valid ,
                                 s_idx_count_reg , s_data_from_fpga )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_fpga_type_reg <= "111";
         ELSIF (s_idx_valid = '1') THEN
            CASE (s_idx_count_reg) IS
               WHEN  "00"  => IF (s_data_from_fpga(3 DOWNTO 0) = X"1") THEN
                                 s_fpga_type_reg <= "000";
                                                                       ELSE
                                 s_fpga_type_reg <= "111";
                              END IF;
               WHEN  "01"  => CASE (s_data_from_fpga) IS
                                 WHEN X"42" => NULL;
                                 WHEN X"43" => s_fpga_type_reg(0) <= '1';
                                 WHEN X"44" => s_fpga_type_reg(1) <= '1';
                                 WHEN X"45" => s_fpga_type_reg(2) <= '1';
                                 WHEN OTHERS=> s_fpga_type_reg <= "111";
                              END CASE;
               WHEN  "10"  => CASE (s_data_from_fpga) IS
                                 WHEN X"00"  |
                                      X"40"  => NULL;
                                 WHEN X"80"  => s_fpga_type_reg(0) <=
                                                   s_fpga_type_reg(1);
                                 WHEN OTHERS => s_fpga_type_reg <= "111";
                              END CASE;
               WHEN OTHERS => IF (s_data_from_fpga /= X"93") THEN
                                 s_fpga_type_reg <= "111";
                              END IF;
            END CASE;
         END IF;
      END IF;
   END PROCESS make_fpga_type_reg;
   
   make_first_time_reg : PROCESS( clock , reset , s_fpga_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_first_time_reg <= '1';
         ELSIF (s_fpga_state_reg = SET_CS_HI_READ) THEN s_first_time_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_first_time_reg;
   
   idx_rom : idreg_rom
             PORT MAP ( index => s_idx_index_reg,
                        data  => s_idx_data );

   
-------------------------------------------------------------------------------
--- Here the wait counter is defined                                        ---
-------------------------------------------------------------------------------

   s_wait_counter_load <= '1' WHEN
                                 s_fpga_state_reg = RESET_STATE OR
                                 s_fpga_state_reg = WAIT_N_INIT_HI OR
                                 s_fpga_state_reg = SET_RDNWR_LO OR
                                 s_fpga_state_reg = SET_CS_HI_WRITE OR
                                 s_fpga_state_reg = SET_RDNWR_HI OR
                                 s_fpga_state_reg = WAIT_DONE
                              ELSE '0';
   s_wait_counter_ena  <= NOT(s_wait_counter_reg(7))
                             WHEN
                                s_fpga_state_reg = GENERATE_N_PROG OR
                                s_fpga_state_reg = WAIT_AFTER_N_INIT OR
                                s_fpga_state_reg = WAIT_RDNWR_LO OR
                                s_fpga_state_reg = WAIT_CS_HI_WRITE OR
                                s_fpga_state_reg = WAIT_RDNWR_HI OR
                                s_fpga_state_reg = WAIT_AFTER_DONE
                             ELSE '0';
   
   make_wait_counter_reg : PROCESS( clock , s_wait_counter_load ,
                                    s_wait_counter_ena )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_wait_counter_load = '1') THEN
            s_wait_counter_reg <= X"7F";
         ELSIF (s_wait_counter_ena = '1') THEN
            s_wait_counter_reg <= unsigned(s_wait_counter_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_wait_counter_reg;
   
-------------------------------------------------------------------------------
--- Here the bitfile handling is defined                                    ---
-------------------------------------------------------------------------------
   s_fifo_pop <= '1' WHEN s_first_time_reg = '0' AND
                          (s_valid_out_byte = '1' OR
                           s_fpga_state_reg = DO_FLUSH ) ELSE '0';
   
   bitfifo : fifo_2kb
             PORT MAP ( clock      => clock,
                        reset      => reset,
                        -- push port
                        push       => push,
                        push_data  => push_data,
                        push_size  => last_byte,
                        -- pop port
                        pop        => s_fifo_pop,
                        pop_data   => s_fifo_data,
                        pop_size   => s_fifo_last_byte,
                        -- control port
                        fifo_full  => fifo_full,
                        fifo_empty => s_fifo_empty );

   
-------------------------------------------------------------------------------
--- Here the IOB flipflops are defined                                      ---
-------------------------------------------------------------------------------
   cclk_ff : FD
             GENERIC MAP ( INIT => '1' )
             PORT MAP ( Q => fpga_cclk,
                        C => clock,
                        D => s_cclk_reg );
   n_prog_ff : FD
               GENERIC MAP ( INIT => '1' )
               PORT MAP ( Q  => fpga_n_prog,
                          C  => clock,
                          D  => s_n_prog_reg );
   n_cs_ff : FDE
             GENERIC MAP ( INIT => '1' )
             PORT MAP ( Q  => fpga_n_cs,
                        C  => clock,
                        CE => s_ena_out_ffs,
                        D  => s_n_cs_next );
   rd_n_wr_ff : FDE
                GENERIC MAP ( INIT => '1' )
                PORT MAP ( Q  => fpga_rd_n_wr,
                           C  => clock,
                           CE => s_ena_out_ffs,
                           D  => s_rd_n_wr_reg );
   n_init_ff : FDE
               GENERIC MAP ( INIT => '1' )
               PORT MAP ( Q  => s_n_init,
                          C  => clock,
                          CE => s_ena_in_ffs,
                          D  => fpga_n_init );
   busy_ff   : FDE
               GENERIC MAP ( INIT => '0' )
               PORT MAP ( Q  => s_busy,
                          C  => clock,
                          CE => s_ena_in_ffs,
                          D  => fpga_busy );
   done_ff : FDE
             GENERIC MAP ( INIT => '0' )
             PORT MAP ( Q  => s_done,
                        C  => clock,
                        CE => s_ena_in_ffs,
                        D  => fpga_done );

END no_platform_specific;
