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

ARCHITECTURE xilinx OF cmd_18_1e_if IS

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
   
   SIGNAL s_n_clock                     : std_logic;
   SIGNAL s_string_data                 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_string_index                : std_logic_vector(10 DOWNTO 0 );
   SIGNAL s_push                        : std_logic;
   SIGNAL s_valid_command               : std_logic;
   SIGNAL s_string_select_reg           : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_string_cnt_reg              : std_logic_vector( 5 DOWNTO 0 );
   
BEGIN
--------------------------------------------------------------------------------
--- Here the outputs are defined                                             ---
--------------------------------------------------------------------------------
   push_size <= s_string_data(7);
   push_data <= "0"&s_string_data(6 DOWNTO 0);
   push      <= s_push;

--------------------------------------------------------------------------------
--- Here the control signals are defined                                     ---
--------------------------------------------------------------------------------
   s_n_clock            <= NOT(clock);
   s_push               <= '0' WHEN s_string_data = X"00" OR
                                    fifo_full = '1' ELSE '1';
   s_valid_command      <= '1' WHEN start_command = '1' AND
                                    (command_id = "0011000" OR
                                     command_id = "0011110") ELSE '0';
   s_string_index       <= s_string_select_reg&s_string_cnt_reg;

--------------------------------------------------------------------------------
--- Here the processes are defined                                           ---
--------------------------------------------------------------------------------
   make_command_done : PROCESS( clock , s_push , s_string_data )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
        IF (s_push = '1' AND
            s_string_data = X"0A") THEN command_done <= '1';
                                   ELSE command_done <= '0';
        END IF;
      END IF;
   END PROCESS make_command_done;
   
   make_string_select_reg : PROCESS( clock , reset , s_valid_command ,
                                     command_id , n_usb_power , n_usb_charge ,
                                     n_bus_power , fpga_configured , 
                                     fpga_type , flash_empty )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_string_select_reg <= (OTHERS => '0');
         ELSIF (s_valid_command = '1') THEN
            IF (command_id = "0011000") THEN
               s_string_select_reg <= "1"&flash_empty&n_usb_power&n_usb_charge&n_bus_power;
                                        ELSE
               s_string_select_reg <= "0"&fpga_configured&fpga_type;
            END IF;
         END IF;
      END IF;
   END PROCESS make_string_select_reg;
   
   make_string_cnt_reg : PROCESS( clock , reset , s_valid_command , s_push )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_string_cnt_reg <= (OTHERS => '1');
         ELSIF (s_valid_command = '1') THEN s_string_cnt_reg <= (OTHERS => '0');
         ELSIF (s_push = '1') THEN 
            s_string_cnt_reg <= unsigned(s_string_cnt_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_string_cnt_reg;

--------------------------------------------------------------------------------
--- Here the string rom is defined                                           ---
--------------------------------------------------------------------------------
   string_rom : RAMB16_S9
      GENERIC MAP ( INIT_00 => X"36373647474630303031533343582033206E61747261705320786E696C6958B0",
                    INIT_01 => X"0000000000000000000000000000000A646572756769666E6F6320746F6E202C",
                    INIT_02 => X"36373647474630303531533343582033206E61747261705320786E696C6958B0",
                    INIT_03 => X"0000000000000000000000000000000A646572756769666E6F6320746F6E202C",
                    INIT_04 => X"36373647474630303032533343582033206E61747261705320786E696C6958B0",
                    INIT_05 => X"0000000000000000000000000000000A646572756769666E6F6320746F6E202C",
                    INIT_06 => X"36373647474630303034533343582033206E61747261705320786E696C6958B0",
                    INIT_07 => X"0000000000000000000000000000000A646572756769666E6F6320746F6E202C",
                    INIT_08 => X"36373647474630303035533343582033206E61747261705320786E696C6958B0",
                    INIT_09 => X"0000000000000000000000000000000A646572756769666E6F6320746F6E202C",
                    INIT_0A => X"41475046206E776F6E6B6E7520726F206465746E756F6D2041475046206F4EA5",
                    INIT_0B => X"00000000000000000000000000000000000000000000000000000A6570797420",
                    INIT_0C => X"41475046206E776F6E6B6E7520726F206465746E756F6D2041475046206F4EA5",
                    INIT_0D => X"00000000000000000000000000000000000000000000000000000A6570797420",
                    INIT_0E => X"41475046206E776F6E6B6E7520726F206465746E756F6D2041475046206F4EA5",
                    INIT_0F => X"00000000000000000000000000000000000000000000000000000A6570797420",
                    INIT_10 => X"36373647474630303031533343582033206E61747261705320786E696C6958A9",
                    INIT_11 => X"000000000000000000000000000000000000000000000A676E696E6E7572202C",
                    INIT_12 => X"36373647474630303531533343582033206E61747261705320786E696C6958A9",
                    INIT_13 => X"000000000000000000000000000000000000000000000A676E696E6E7572202C",
                    INIT_14 => X"36373647474630303032533343582033206E61747261705320786E696C6958A9",
                    INIT_15 => X"000000000000000000000000000000000000000000000A676E696E6E7572202C",
                    INIT_16 => X"36373647474630303034533343582033206E61747261705320786E696C6958A9",
                    INIT_17 => X"000000000000000000000000000000000000000000000A676E696E6E7572202C",
                    INIT_18 => X"36373647474630303035533343582033206E61747261705320786E696C6958A9",
                    INIT_19 => X"000000000000000000000000000000000000000000000A676E696E6E7572202C",
                    INIT_1A => X"41475046206E776F6E6B6E7520726F206465746E756F6D2041475046206F4EA5",
                    INIT_1B => X"00000000000000000000000000000000000000000000000000000A6570797420",
                    INIT_1C => X"41475046206E776F6E6B6E7520726F206465746E756F6D2041475046206F4EA5",
                    INIT_1D => X"00000000000000000000000000000000000000000000000000000A6570797420",
                    INIT_1E => X"41475046206E776F6E6B6E7520726F206465746E756F6D2041475046206F4EA5",
                    INIT_1F => X"00000000000000000000000000000000000000000000000000000A6570797420",
                    INIT_20 => X"626F727020676E697265646C6F73202C65746174532064656E696665646E55A4",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000A3F6D656C",
                    INIT_22 => X"7265776F70202C6465696C7070757320425355203A6E69616D344F4B434547B9",
                    INIT_23 => X"0000000000000A64656D6D6172676F7270206873616C46202C53554220676E69",
                    INIT_24 => X"626F727020676E697265646C6F73202C65746174532064656E696665646E55A4",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000A3F6D656C",
                    INIT_26 => X"6873616C46202C6465696C7070757320425355203A6E69616D344F4B434547AB",
                    INIT_27 => X"00000000000000000000000000000000000000000A64656D6D6172676F727020",
                    INIT_28 => X"6F70202C6465696C7070757320314F494E4547203A6E69616D344F4B434547BC",
                    INIT_29 => X"0000000A64656D6D6172676F7270206873616C46202C53554220676E69726577",
                    INIT_2A => X"626F727020676E697265646C6F73202C65746174532064656E696665646E55A4",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000A3F6D656C",
                    INIT_2C => X"6C46202C6465696C7070757320314F494E4547203A6E69616D344F4B434547AE",
                    INIT_2D => X"00000000000000000000000000000000000A64656D6D6172676F727020687361",
                    INIT_2E => X"626F727020676E697265646C6F73202C65746174532064656E696665646E55A4",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000A3F6D656C",
                    INIT_30 => X"626F727020676E697265646C6F73202C65746174532064656E696665646E55A4",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000A3F6D656C",
                    INIT_32 => X"7265776F70202C6465696C7070757320425355203A6E69616D344F4B434547B4",
                    INIT_33 => X"00000000000000000000000A7974706D65206873616C46202C53554220676E69",
                    INIT_34 => X"626F727020676E697265646C6F73202C65746174532064656E696665646E55A4",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000A3F6D656C",
                    INIT_36 => X"6873616C46202C6465696C7070757320425355203A6E69616D344F4B434547A6",
                    INIT_37 => X"000000000000000000000000000000000000000000000000000A7974706D6520",
                    INIT_38 => X"6F70202C6465696C7070757320314F494E4547203A6E69616D344F4B434547B7",
                    INIT_39 => X"00000000000000000A7974706D65206873616C46202C53554220676E69726577",
                    INIT_3A => X"626F727020676E697265646C6F73202C65746174532064656E696665646E55A4",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000A3F6D656C",
                    INIT_3C => X"6C46202C6465696C7070757320314F494E4547203A6E69616D344F4B434547A9",
                    INIT_3D => X"000000000000000000000000000000000000000000000A7974706D6520687361",
                    INIT_3E => X"626F727020676E697265646C6F73202C65746174532064656E696665646E55A4",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000A3F6D656C")
      PORT MAP ( DO   => s_string_data,
                 DOP  => OPEN,
                 ADDR => s_string_index,
                 DI   => X"00",
                 DIP  => "0",
                 EN   => '1',
                 WE   => '0',
                 CLK  => s_n_clock,
                 SSR  => '0' );

END xilinx;
