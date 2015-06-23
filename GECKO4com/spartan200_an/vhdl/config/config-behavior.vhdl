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

ARCHITECTURE no_target_specific OF config_if IS

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
   
   TYPE CONFIG_STATE_TYPE IS (IDLE,SEND_START,WAIT_END,SIGNAL_ERROR);
   
   SIGNAL s_config_state_reg : CONFIG_STATE_TYPE;
   
   SIGNAL s_fifo_full        : std_logic;
   SIGNAL s_push             : std_logic;
   SIGNAL s_pop              : std_logic;
   SIGNAL s_pop_data         : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_pop_last         : std_logic;
   SIGNAL s_fifo_empty       : std_logic;
   SIGNAL s_boot_up_config   : std_logic;
   SIGNAL s_boot_up_reg      : std_logic;

BEGIN
--------------------------------------------------------------------------------
--- Here the outputs are defined                                             ---
--------------------------------------------------------------------------------
   flash_start_read <= '1' WHEN s_config_state_reg = SEND_START OR
                                (s_config_state_reg = IDLE AND
                                 flash_u_start_read = '1') ELSE '0';
   flash_u_done     <= flash_done WHEN s_config_state_reg = IDLE ELSE '0';
   flash_u_push     <= flash_push WHEN s_config_state_reg = IDLE ELSE '0';
   flash_u_push_data<= flash_push_data WHEN s_config_state_reg = IDLE ELSE (OTHERS => '0');
   flash_u_push_size<= flash_push_size WHEN s_config_state_reg = IDLE ELSE '0';
   flash_fifo_full  <= flash_u_fifo_full WHEN s_config_state_reg = IDLE ELSE s_fifo_full;
   bitfile_start    <= '1' WHEN s_config_state_reg = SEND_START OR
                                (s_config_state_reg = IDLE AND
                                 bitfile_u_start = '1') ELSE '0';
   bitfile_u_pop    <= bitfile_pop WHEN s_config_state_reg = IDLE ELSE '0';
   bitfile_pop_data <= bitfile_u_pop_data WHEN s_config_state_reg = IDLE ELSE
                       s_pop_data;
   bitfile_last     <= bitfile_u_last WHEN s_config_state_reg = IDLE ELSE
                       s_pop_last;
   bitfile_fifo_empty <= bitfile_u_fifo_empty WHEN s_config_state_reg = IDLE ELSE
                         s_fifo_empty;
   command_error    <= '1' WHEN s_config_state_reg = SIGNAL_ERROR ELSE '0';

--------------------------------------------------------------------------------
--- Here the control signals are defined                                     ---
--------------------------------------------------------------------------------
   s_push   <= '1' WHEN s_config_state_reg = WAIT_END AND
                        flash_push = '1' AND
                        flash_push_size = '0' ELSE '0';
   s_pop    <= bitfile_pop WHEN s_config_state_reg = WAIT_END ELSE '0';
   
--------------------------------------------------------------------------------
--- Here the state machine is defined                                        ---
--------------------------------------------------------------------------------
   make_state_machine : PROCESS( clock , reset , s_config_state_reg )
      VARIABLE v_next_state : CONFIG_STATE_TYPE;
   BEGIN
      CASE (s_config_state_reg) IS
         WHEN IDLE               => IF (start_command = '1' AND
                                        command_id = "0011001") THEN
                                       IF (flash_present = '0' OR
                                           flash_s1_empty = '1' OR
                                           fpga_type = "111") THEN
                                          v_next_state := SIGNAL_ERROR;
                                                              ELSE
                                          v_next_state := SEND_START;
                                       END IF;
                                    ELSIF (s_boot_up_config = '1' OR
                                           start_config = '1') THEN
                                       v_next_state := SEND_START;
                                                                   ELSE
                                       v_next_state := IDLE;
                                    END IF;
         WHEN SEND_START         => v_next_state := WAIT_END;
         WHEN WAIT_END           => IF (s_pop = '1' AND
                                        s_pop_last = '1') THEN 
                                       v_next_state := IDLE;
                                                          ELSE
                                       v_next_state := WAIT_END;
                                    END IF;
         WHEN OTHERS             => v_next_state := IDLE;
      END CASE;
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_config_state_reg <= IDLE;
                          ELSE s_config_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_state_machine;
   
--------------------------------------------------------------------------------
--- Here the boot-up is defined                                              ---
--------------------------------------------------------------------------------
   s_boot_up_config <= '1' WHEN s_boot_up_reg = '1' AND
                                flash_present = '1' AND
                                n_bus_power = '0' AND
                                flash_s1_empty = '0' AND
                                flash_idle = '1' AND
                                fpga_idle = '1' AND
                                fpga_type /= "111" ELSE '0';

   make_boot_up_reg : PROCESS( clock , reset , start_command , s_boot_up_config)
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_boot_up_reg <= '1';
         ELSIF (start_command = '1' OR
                s_boot_up_config = '1') THEN s_boot_up_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_boot_up_reg;

--------------------------------------------------------------------------------
--- Here the components are defined                                          ---
--------------------------------------------------------------------------------
   fifo : fifo_2kb
          PORT MAP ( clock      => clock,
                     reset      => reset,
                     -- push port
                     push       => s_push,
                     push_data  => flash_push_data,
                     push_size  => flash_push_last,
                     -- pop port
                     pop        => s_pop,
                     pop_data   => s_pop_data,
                     pop_size   => s_pop_last,
                     -- control port
                     fifo_full  => s_fifo_full,
                     fifo_empty => s_fifo_empty );


END no_target_specific;
