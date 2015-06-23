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

-- In case of start of transmission:
-- data(15)          => read_n_write
-- data(14 DOWNTO 6) => burst_size
-- data( 5 DOWNTO 0) => address

ARCHITECTURE xilinx OF bus_if IS

   COMPONENT FD
      GENERIC ( INIT : bit );
      PORT ( Q   : OUT std_logic;
             C   : IN  std_logic;
             D   : IN  std_logic );
   END COMPONENT;
   
   SIGNAL s_n_force_bus_reg        : std_logic;
   SIGNAL s_bus_reset              : std_logic;
   SIGNAL s_data_in                : std_logic_vector( 15 DOWNTO 0 );
   SIGNAL s_data_n_valid_in        : std_logic_vector(  1 DOWNTO 0 );
   SIGNAL s_n_start                : std_logic;
   SIGNAL s_n_end_in               : std_logic;
   SIGNAL s_n_error                : std_logic;
   SIGNAL s_n_start_send           : std_logic;
   SIGNAL s_n_end_out              : std_logic;
   SIGNAL s_bus_n_end_transmission : std_logic;
   SIGNAL s_bus_n_end_tri          : std_logic;
   SIGNAL s_n_valid_out            : std_logic_vector( 1 DOWNTO 0 );
   SIGNAL s_bus_n_data_valid       : std_logic_vector( 1 DOWNTO 0 );
   SIGNAL s_bus_n_data_tri         : std_logic_vector( 1 DOWNTO 0 );
   SIGNAL s_bus_data_addr_cntrl    : std_logic_vector(15 DOWNTO 0 );
   SIGNAL s_bus_data_addr_tri      : std_logic_vector(15 DOWNTO 0 );
   
BEGIN

--------------------------------------------------------------------------------
--- Here the outputs are defined                                             ---
--------------------------------------------------------------------------------
   b_n_reset <= NOT(s_bus_reset);
   bus_n_end_transmission <= s_bus_n_end_transmission 
                                WHEN s_bus_n_end_tri = '0' ELSE 'Z';

   make_n_start_reg : PROCESS( clock , s_n_start , s_bus_reset , reset )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN 
         IF (s_bus_reset = '1' OR
             reset = '1') THEN b_n_start_transmission <= '1';
                          ELSE b_n_start_transmission <= s_n_start;
         END IF;
      END IF;
   END PROCESS make_n_start_reg;
   
   make_control_regs : PROCESS( clock , s_n_start , s_bus_reset , reset ,
                                s_data_in )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_bus_reset = '1' OR
             reset = '1') THEN read_n_write <= '1';
                               burst_size   <= (OTHERS => '0');
                               address      <= (OTHERS => '0');
         ELSIF (s_n_start = '0') THEN read_n_write <= s_data_in(15);
                                      burst_size   <= s_data_in(14 DOWNTO 6);
                                      address      <= s_data_in( 5 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS make_control_regs;
   
   make_data_regs : PROCESS( clock , s_bus_reset , reset , s_data_n_valid_in ,
                             s_data_in )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_bus_reset = '1' OR
             reset = '1') THEN data_out                 <= (OTHERS => '0');
                               b_n_data_valid_out       <= "11";
                               b_n_end_transmission_out <= '1';
                          ELSE
            b_n_data_valid_out       <= s_data_n_valid_in;
            b_n_end_transmission_out <= s_n_end_in;
            IF (s_data_n_valid_in /= "11") THEN
               data_out <= s_data_in;
            END IF;
         END IF;
      END IF;
   END PROCESS make_data_regs;

--------------------------------------------------------------------------------
--- Here the control signals are defined                                     ---
--------------------------------------------------------------------------------
   s_n_error <= '0' WHEN s_bus_reset = '0' AND
                         reset = '0' AND
                         (n_bus_error = '0' OR
                          (s_n_start = '0' AND
                           s_data_in(4) = '1')) -- Only vga and fifo for the moment
                    ELSE '1';
   s_n_start_send <= '0' WHEN s_bus_reset = '0' AND
                              reset = '0' AND
                              n_start_send = '0' ELSE '1';
   s_n_end_out    <= '0' WHEN s_bus_reset = '0' AND
                              reset = '0' AND
                              b_n_end_transmission_in = '0' ELSE '1';
   s_n_valid_out  <= "11" WHEN s_bus_reset = '1' OR
                               reset = '1' ELSE b_n_data_valid_in;

--------------------------------------------------------------------------------
--- Here the three state control is defined                                  ---
--------------------------------------------------------------------------------
   make_n_force_bus_reg : PROCESS( clock , reset , s_bus_reset ,
                                   s_n_start , s_data_in )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1' OR
             s_n_error = '0' OR
             s_n_end_out = '0' OR
             s_bus_reset = '1') THEN s_n_force_bus_reg <= '1';
         ELSIF (s_n_start = '0' AND
                s_data_in(15) = '1') THEN s_n_force_bus_reg <= '0';
         END IF;
      END IF;
   END PROCESS make_n_force_bus_reg;

--------------------------------------------------------------------------------
--- Here the IOB ffs are defined                                             ---
--------------------------------------------------------------------------------
   reset_ff : FD
              GENERIC MAP ( INIT => '1' )
              PORT MAP ( Q => s_bus_reset,
                         C => clock,
                         D => bus_reset );
   make_data_ffs : FOR n IN 15 DOWNTO 0 GENERATE
      bus_data_addr_cntrl(n) <= s_bus_data_addr_cntrl(n)
                                   WHEN s_bus_data_addr_tri(n) = '0' ELSE
                                'Z';
      din_ff : FD
               GENERIC MAP ( INIT => '1' )
               PORT MAP ( Q => s_data_in(n),
                          C => clock,
                          D => bus_data_addr_cntrl(n));
      dout_ff : FD
                GENERIC MAP ( INIT => '1' )
                PORT MAP ( Q => s_bus_data_addr_cntrl(n),
                           C => clock,
                           D => data_in(n) );
      tri_ff : FD
               GENERIC MAP ( INIT => '1' )
               PORT MAP ( Q => s_bus_data_addr_tri(n),
                          C => clock,
                          D => s_n_force_bus_reg );
   END GENERATE make_data_ffs;
   
   make_data_valid_ffs : FOR n IN 1 DOWNTO 0 GENERATE
      bus_n_data_valid(n) <= s_bus_n_data_valid(n)
                                WHEN s_bus_n_data_tri(n) = '0' ELSE
                             'Z';
      in_ff : FD
              GENERIC MAP ( INIT => '1' )
              PORT MAP ( Q => s_data_n_valid_in(n),
                         C => clock,
                         D => bus_n_data_valid(n) );
      out_ff : FD
               GENERIC MAP ( INIT => '1' )
               PORT MAP ( Q => s_bus_n_data_valid(n),
                          C => clock,
                          D => s_n_valid_out(n) );
      tri_ff : FD
               GENERIC MAP ( INIT => '1' )
               PORT MAP ( Q => s_bus_n_data_tri(n),
                          C => clock,
                          D => s_n_force_bus_reg );
   END GENERATE make_data_valid_ffs;
   
   end_in_ff : FD
               GENERIC MAP ( INIT => '1' )
               PORT MAP ( Q => s_n_end_in,
                          C => clock,
                          D => bus_n_end_transmission );
   end_out_ff : FD
                GENERIC MAP ( INIT => '1' )
                PORT MAP ( Q => s_bus_n_end_transmission,
                           C => clock,
                           D => s_n_end_out );
   end_tri_ff : FD
                GENERIC MAP ( INIT => '1' )
                PORT MAP ( Q => s_bus_n_end_tri,
                           C => clock,
                           D => s_n_force_bus_reg );
   
   start_trans_ff : FD
                    GENERIC MAP ( INIT => '1' )
                    PORT MAP ( Q => s_n_start,
                               C => clock,
                               D => bus_n_start_transmission );
   n_error_ff : FD
                GENERIC MAP ( INIT => '1' )
                PORT MAP ( Q => bus_n_error,
                           C => clock,
                           D => s_n_error );
   n_send_ff : FD
               GENERIC MAP ( INIT => '1' )
               PORT MAP ( Q => bus_n_start_send,
                          C => clock,
                          D => s_n_start_send );
   
END xilinx;
