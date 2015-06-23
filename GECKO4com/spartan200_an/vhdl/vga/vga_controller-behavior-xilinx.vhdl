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

LIBRARY unisim;
USE unisim.all;

ARCHITECTURE xilinx OF vga_controller IS

   COMPONENT FDC
      GENERIC ( INIT : bit );
      PORT ( Q   : OUT std_logic;
             C   : IN  std_logic;
             CLR : IN  std_logic;
             D   : IN  std_logic );
   END COMPONENT;
   
   COMPONENT DFF
      PORT ( clock  : IN  std_logic;
             D      : IN  std_logic;
             Q      : OUT std_logic );
   END COMPONENT;
   
   COMPONENT DFF_BUS
      GENERIC ( nr_of_bits : INTEGER );
      PORT ( clock  : IN  std_logic;
             D      : IN  std_logic_vector( (nr_of_bits-1) DOWNTO 0 );
             Q      : OUT std_logic_vector( (nr_of_bits-1) DOWNTO 0 ));
   END COMPONENT;
   
   COMPONENT RAMB16_S9_S9
      PORT ( DOA   : OUT std_logic_vector( 7 DOWNTO 0 );
             DOPA  : OUT std_logic_vector( 0 DOWNTO 0 );
             ADDRA : IN  std_logic_vector(10 DOWNTO 0 );
             CLKA  : IN  std_logic;
             DIA   : IN  std_logic_vector( 7 DOWNTO 0 );
             DIPA  : IN  std_logic_vector( 0 DOWNTO 0 );
             ENA   : IN  std_logic;
             SSRA  : IN  std_logic;
             WEA   : IN  std_logic;
             DOB   : OUT std_logic_vector( 7 DOWNTO 0 );
             DOPB  : OUT std_logic_vector( 0 DOWNTO 0 );
             ADDRB : IN  std_logic_vector(10 DOWNTO 0 );
             CLKB  : IN  std_logic;
             DIB   : IN  std_logic_vector( 7 DOWNTO 0 );
             DIPB  : IN  std_logic_vector( 0 DOWNTO 0 );
             ENB   : IN  std_logic;
             SSRB  : IN  std_logic;
             WEB   : IN  std_logic);
   END COMPONENT;
   
   COMPONENT RAMB16_S1
      PORT ( DO   : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
             ADDR : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
             CLK  : IN STD_ULOGIC;
             DI   : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
             EN   : IN STD_ULOGIC;
             SSR  : IN STD_ULOGIC;
             WE   : IN STD_ULOGIC );
   END COMPONENT;

   TYPE HCOUNT_TYPE IS ( HORIZONTAL_FRONT_PORCH , HORIZONTAL_SYNC , HORIZONTAL_BACK_PORCH , HORIZONTAL_PIXELS );
   TYPE VCOUNT_TYPE IS ( VERTICAL_FRONT_PORCH , VERTICAL_SYNC , VERTICAL_BACK_PORCH , VERTICAL_ACTIVE );
   TYPE USBTMC_STATE_TYPE IS (IDLE,INIT_CLEAR_SCREEN,CLEAR_SCREEN,SIGNAL_DONE,
                              GET_BG_COLOR,SET_BG_COLOR,SIGNAL_ERROR,
                              GET_FG_COLOR,SET_FG_COLOR,WRITE_CHAR,NEW_LINE,
                              INIT_CLEAR_LINE,CLEAR_LINE,CLEAR_NOP,
                              INIT_CURSOR_SEND,SEND_CURSOR,INIT_GET_CURSOR,
                              GET_X_CHAR,MULT_10_X,GET_Y_CHAR,MULT_10_Y,
                              UPDATE_CURSOR);

   CONSTANT H_FRONT_PORCH_COUNT       : std_logic_vector( 9 DOWNTO 0 ) := "0000010111";
   CONSTANT H_SYNC_COUNT              : std_logic_vector( 9 DOWNTO 0 ) := "0010000111";
   CONSTANT H_BACK_PORCH_COUNT        : std_logic_vector( 9 DOWNTO 0 ) := "0010001111";
   CONSTANT H_PIXEL_COUNT             : std_logic_vector( 9 DOWNTO 0 ) := "1111111111";
   CONSTANT V_FRONT_PORCH_COUNT       : std_logic_vector( 9 DOWNTO 0 ) := "0000000010";
   CONSTANT V_SYNC_COUNT              : std_logic_vector( 9 DOWNTO 0 ) := "0000000101";
   CONSTANT V_BACK_PORCH_COUNT        : std_logic_vector( 9 DOWNTO 0 ) := "0000011100";
   CONSTANT V_ACTIVE_COUNT            : std_logic_vector( 9 DOWNTO 0 ) := "1011111111";
   CONSTANT HIGH_RELOAD               : std_logic_vector(12 DOWNTO 0 ) := "1"&X"D4B"; --(=7499)
   CONSTANT LOW_RELOAD                : std_logic_vector(12 DOWNTO 0 ) := "1"&X"387"; --(=4999)
   CONSTANT c_ten                     : std_logic_vector( 4 DOWNTO 0 ) := "01010";
   CONSTANT c_31                      : std_logic_vector( 6 DOWNTO 0 ) := "0011111";
   
   SIGNAL s_horiz_count_reg           : std_logic_vector( 9 DOWNTO 0 );
   SIGNAL s_horiz_load_value          : std_logic_vector( 9 DOWNTO 0 );
   SIGNAL s_horiz_count_is_zero       : std_logic;
   SIGNAL s_horiz_state_reg           : HCOUNT_TYPE;
   SIGNAL s_next_line                 : std_logic;
   SIGNAL s_next_line_reg             : std_logic;
   SIGNAL s_vert_count_reg            : std_logic_vector( 9 DOWNTO 0 );
   SIGNAL s_vert_load_value           : std_logic_vector( 9 DOWNTO 0 );
   SIGNAL s_vert_count_is_zero        : std_logic;
   SIGNAL s_vert_state_reg            : VCOUNT_TYPE;
   SIGNAL s_vsync                     : std_logic;
   SIGNAL s_hsync                     : std_logic;
   SIGNAL s_n_blank                   : std_logic;
   SIGNAL s_red                       : std_logic;
   SIGNAL s_green                     : std_logic;
   SIGNAL s_blue                      : std_logic;
   SIGNAL s_new_screen                : std_logic;
   SIGNAL s_new_screen_reg            : std_logic;
   SIGNAL s_req_line                  : std_logic;
   SIGNAL s_req_line_reg              : std_logic;
   SIGNAL s_line_counter_reg          : std_logic_vector( 9 DOWNTO 0 );
   SIGNAL s_lookup_address            : std_logic_vector(10 DOWNTO 0 );
   SIGNAL s_is_fpga_cursor_pos        : std_logic;
   SIGNAL s_fpga_lookup_address       : std_logic_vector(10 DOWNTO 0 );
   SIGNAL s_usbtmc_lookup_address     : std_logic_vector(10 DOWNTO 0 );
   
   SIGNAL s_ascii_data_1              : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_ascii_data_2              : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_ascii_data_3              : std_logic_vector( 7 DOWNTO 0 );
   
   SIGNAL s_stage_1_data_sel_reg      : std_logic_vector( 1 DOWNTO 0 );
   SIGNAL s_stage_1_line_index_reg    : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_stage_1_pixel_index_reg   : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_stage_1_fg_color_reg      : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_stage_1_bg_color_reg      : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_stage_1_hsync_reg         : std_logic;
   SIGNAL s_stage_1_vsync_reg         : std_logic;
   SIGNAL s_stage_1_n_blank_reg       : std_logic;
   SIGNAL s_stage_1_cursor_reg        : std_logic;
   SIGNAL s_stage_1_draw_line_reg     : std_logic;
   
   SIGNAL s_stage_1_ascii_data        : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_rom_index                 : std_logic_vector(13 DOWNTO 0 );
   SIGNAL s_rom_value_0               : std_logic_vector( 0 DOWNTO 0 );

   SIGNAL s_stage_2_fg_color_reg      : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_stage_2_bg_color_reg      : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_stage_2_hsync_reg         : std_logic;
   SIGNAL s_stage_2_vsync_reg         : std_logic;
   SIGNAL s_stage_2_n_blank_reg       : std_logic;
   SIGNAL s_stage_2_cursor_reg        : std_logic;
   SIGNAL s_stage_2_pixel_inv_reg     : std_logic;
   
   SIGNAL s_stage_2_pixel_set         : std_logic;
   
   SIGNAL s_stage_1_counter_reg       : std_logic_vector( 12 DOWNTO 0 );
   SIGNAL s_stage_1_counter_next      : std_logic_vector( 12 DOWNTO 0 );
   SIGNAL s_stage_1_counter_zero      : std_logic;
   SIGNAL s_stage_1_counter_tick_reg  : std_logic;
   SIGNAL s_stage_1_counter_tick_next : std_logic;
   SIGNAL s_stage_2_counter_reg       : std_logic_vector( 12 DOWNTO 0 );
   SIGNAL s_stage_2_counter_next      : std_logic_vector( 12 DOWNTO 0 );
   SIGNAL s_stage_2_counter_zero      : std_logic;
   SIGNAL s_stage_2_counter_tick_reg  : std_logic;
   SIGNAL s_stage_2_counter_tick_next : std_logic;
   SIGNAL s_blink_reg                 : std_logic;
   SIGNAL s_blink_next                : std_logic;
   SIGNAL s_draw_hor_line             : std_logic;
   
   SIGNAL s_usbtmc_screen_offset_reg  : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_usbtmc_cursor_x_reg       : std_logic_vector( 5 DOWNTO 0 );
   SIGNAL s_usbtmc_cursor_y_reg       : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_usbtmc_cursor_x_bcd_reg   : std_logic_vector( 6 DOWNTO 0 );
   SIGNAL s_usbtmc_cursor_y_bcd_reg   : std_logic_vector( 5 DOWNTO 0 );
   SIGNAL s_usbtmc_fg_color_reg       : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_usbtmc_bg_color_reg       : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_is_usbtmc_cursor          : std_logic;
   SIGNAL s_usbtmc_write_address      : std_logic_vector(10 DOWNTO 0 );
   SIGNAL s_usbtmc_write_data         : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_usbtmc_write_enable       : std_logic;
   SIGNAL s_usbtmc_state_reg          : USBTMC_STATE_TYPE;
   SIGNAL s_clear_counter_reg         : std_logic_vector(11 DOWNTO 0 );
   SIGNAL s_pop_data                  : std_logic;
   SIGNAL s_pop_data_reg              : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_next_cursor_xpos          : std_logic_vector( 6 DOWNTO 0 );
   SIGNAL s_next_cursor_ypos          : std_logic_vector( 5 DOWNTO 0 );
   SIGNAL s_valid_char                : std_logic;
   SIGNAL s_last_char_reg             : std_logic;
   SIGNAL s_push_cnt_reg              : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_push                      : std_logic;
   SIGNAL s_new_cursor_x_pos_reg      : std_logic_vector( 5 DOWNTO 0 );
   SIGNAL s_new_cursor_y_pos_reg      : std_logic_vector( 4 DOWNTO 0 );
   
BEGIN

-- Assign control signals
   s_horiz_count_is_zero     <= '1' WHEN s_horiz_count_reg = "0000000000" ELSE '0';
   s_vert_count_is_zero      <= '1' WHEN s_vert_count_reg = "0000000000" ELSE '0';
   s_next_line               <= '1' WHEN s_horiz_count_is_zero = '1' AND
                                         s_horiz_state_reg = HORIZONTAL_PIXELS ELSE '0';
   s_n_blank                 <= '1' WHEN s_horiz_state_reg = HORIZONTAL_PIXELS AND
                                         s_vert_state_reg = VERTICAL_ACTIVE ELSE '0';
   s_red                     <= '0' WHEN s_stage_2_n_blank_reg = '0' ELSE
                                s_stage_2_fg_color_reg(2) WHEN s_stage_2_pixel_set = '1' ELSE
                                s_stage_2_bg_color_reg(2);
   s_green                   <= '0' WHEN s_stage_2_n_blank_reg = '0' ELSE
                                s_stage_2_fg_color_reg(1) WHEN s_stage_2_pixel_set = '1' ELSE
                                s_stage_2_bg_color_reg(1);
   s_blue                    <= '0' WHEN s_stage_2_n_blank_reg = '0' ELSE
                                s_stage_2_fg_color_reg(0) WHEN s_stage_2_pixel_set = '1' ELSE
                                s_stage_2_bg_color_reg(0);
   s_new_screen              <= '1' WHEN s_horiz_count_is_zero = '1' AND
                                         s_vert_count_is_zero = '1' AND
                                         s_horiz_state_reg = HORIZONTAL_PIXELS AND
                                         s_vert_state_reg = VERTICAL_FRONT_PORCH ELSE '0';
   s_req_line                <= '1' WHEN (s_horiz_count_is_zero = '1' AND
                                          s_horiz_state_reg = HORIZONTAL_PIXELS AND
                                          s_vert_state_reg = VERTICAL_ACTIVE) ELSE '0';
   s_lookup_address          <= s_line_counter_reg(7 DOWNTO 4)&NOT(s_horiz_count_reg(9 DOWNTO 3));
   s_fpga_lookup_address( 5 DOWNTO 0 ) <= NOT(s_horiz_count_reg(8 DOWNTO 3));
   s_fpga_lookup_address(10 DOWNTO 6 ) <= unsigned(screen_offset)+
                                          unsigned(s_line_counter_reg(9)&
                                                   s_line_counter_reg(7 DOWNTO 4));
   s_usbtmc_lookup_address( 5 DOWNTO 0 ) <= NOT(s_horiz_count_reg(8 DOWNTO 3));
   s_usbtmc_lookup_address(10 DOWNTO 6 ) <= unsigned(s_usbtmc_screen_offset_reg)+
                                            unsigned(s_line_counter_reg(9)&
                                                     s_line_counter_reg(7 DOWNTO 4));
   s_hsync                   <= '1' WHEN s_horiz_state_reg = HORIZONTAL_SYNC ELSE '0';
   s_vsync                   <= '1' WHEN s_vert_state_reg = VERTICAL_SYNC ELSE '0';
   s_is_fpga_cursor_pos      <= '1' WHEN cursor_pos(10 DOWNTO 6) = s_line_counter_reg(9)&s_line_counter_reg(7 DOWNTO 4) AND
                                         cursor_pos( 5 DOWNTO 0) = NOT(s_horiz_count_reg( 8 DOWNTO 3)) ELSE '0';
   s_is_usbtmc_cursor        <= '1' WHEN s_usbtmc_cursor_y_reg = s_line_counter_reg(9)&s_line_counter_reg(7 DOWNTO 4) AND
                                         s_usbtmc_cursor_x_reg = NOT(s_horiz_count_reg( 8 DOWNTO 3)) ELSE '0';
   s_draw_hor_line           <= '1' WHEN s_horiz_count_reg(8 DOWNTO 0) = "0"&X"00" OR
                                         s_horiz_count_reg(8 DOWNTO 0) = "1"&X"FF" ELSE '0';
   s_rom_index(13 DOWNTO 7 ) <= s_stage_1_ascii_data( 6 DOWNTO 0 );
   s_rom_index( 6 DOWNTO 3 ) <= s_stage_1_line_index_reg;
   s_rom_index( 2 DOWNTO 0 ) <= s_stage_1_pixel_index_reg;
   s_stage_2_pixel_set       <= (s_rom_value_0(0) XOR s_stage_2_cursor_reg) XOR s_stage_2_pixel_inv_reg;
   s_stage_1_counter_zero    <= '1' WHEN s_stage_1_counter_reg = "0"&X"000" ELSE '0';
   s_stage_2_counter_zero    <= s_stage_1_counter_tick_reg WHEN s_stage_2_counter_reg = "0"&X"000" ELSE '0';

-- Here the update logic is defined
   s_stage_1_counter_next      <= HIGH_RELOAD WHEN s_stage_1_counter_zero = '1' OR
                                                   vga_off = '1' ELSE 
                                  unsigned(s_stage_1_counter_reg) - 1;
   s_stage_1_counter_tick_next <= s_stage_1_counter_zero OR vga_off;
   s_stage_2_counter_next      <= LOW_RELOAD WHEN s_stage_2_counter_zero = '1' OR
                                                  vga_off = '1' ELSE
                                  unsigned(s_stage_2_counter_reg) - 1 WHEN s_stage_1_counter_tick_reg = '1' ELSE
                                  s_stage_2_counter_reg;
   s_stage_2_counter_tick_next <= s_stage_2_counter_zero OR vga_off;
   s_blink_next                <= '0' WHEN vga_off = '1' ELSE
                                  NOT(s_blink_reg) WHEN s_stage_2_counter_tick_reg = '1' ELSE s_blink_reg;

-- Here the flipflops are instantiated
   stage_1_counter_reg : DFF_BUS
                         GENERIC MAP ( nr_of_bits => 13 )
                         PORT MAP ( clock => clock_75MHz,
                                    D     => s_stage_1_counter_next,
                                    Q     => s_stage_1_counter_reg );
   stage_1_counter_tick_reg : DFF
                              PORT MAP ( clock => clock_75MHz,
                                         D     => s_stage_1_counter_tick_next,
                                         Q     => s_stage_1_counter_tick_reg );
   stage_2_counter_reg : DFF_BUS
                         GENERIC MAP ( nr_of_bits => 13 )
                         PORT MAP ( clock => clock_75MHz,
                                    D     => s_stage_2_counter_next,
                                    Q     => s_stage_2_counter_reg );
   stage_2_counter_tick_reg : DFF
                              PORT MAP ( clock => clock_75MHz,
                                         D     => s_stage_2_counter_tick_next,
                                         Q     => s_stage_2_counter_tick_reg );
   blink_reg : DFF
               PORT MAP ( clock => clock_75MHz,
                          D     => s_blink_next,
                          Q     => s_blink_reg );

-- Map processes
   
   make_horiz_count_reg : PROCESS( clock_75MHz , vga_off , 
                                   s_horiz_count_is_zero , s_horiz_load_value )
   BEGIN
      IF (clock_75MHz'event AND (clock_75MHz = '1')) THEN
         IF (vga_off = '1') THEN s_horiz_count_reg <= H_FRONT_PORCH_COUNT;
         ELSIF (s_horiz_count_is_zero = '1') THEN
               s_horiz_count_reg <= s_horiz_load_value;
                                             ELSE
               s_horiz_count_reg <= unsigned( s_horiz_count_reg ) - 1;
         END IF;
      END IF;
   END PROCESS make_horiz_count_reg;
   
   make_horiz_load_value : PROCESS( s_horiz_state_reg )
   BEGIN
      CASE (s_horiz_state_reg) IS
         WHEN HORIZONTAL_FRONT_PORCH => s_horiz_load_value <= H_SYNC_COUNT;
         WHEN HORIZONTAL_SYNC        => s_horiz_load_value <= H_BACK_PORCH_COUNT;
         WHEN HORIZONTAL_BACK_PORCH  => s_horiz_load_value <= H_PIXEL_COUNT;
         WHEN OTHERS                 => s_horiz_load_value <= H_FRONT_PORCH_COUNT;
      END CASE;
   END PROCESS make_horiz_load_value;
   
   make_horiz_state_reg : PROCESS( clock_75MHz , s_horiz_state_reg ,
                                   vga_off , s_horiz_count_is_zero )
      VARIABLE v_next_state : HCOUNT_TYPE;
   BEGIN
      CASE (s_horiz_state_reg) IS
         WHEN HORIZONTAL_FRONT_PORCH => v_next_state := HORIZONTAL_SYNC;
         WHEN HORIZONTAL_SYNC        => v_next_state := HORIZONTAL_BACK_PORCH;
         WHEN HORIZONTAL_BACK_PORCH  => v_next_state := HORIZONTAL_PIXELS;
         WHEN OTHERS                 => v_next_state := HORIZONTAL_FRONT_PORCH;
      END CASE;
      IF (clock_75MHz'event AND (clock_75MHz = '1')) THEN
         IF (vga_off = '1') THEN s_horiz_state_reg <= HORIZONTAL_FRONT_PORCH;
         ELSIF (s_horiz_count_is_zero = '1') THEN s_horiz_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_horiz_state_reg;
   
   make_vert_count_reg : PROCESS( clock_75MHz , vga_off , s_next_line_reg ,
                                  s_vert_count_is_zero , s_vert_load_value )
   BEGIN
      IF (clock_75MHz'event AND (clock_75MHz = '1')) THEN
         IF (vga_off = '1') THEN s_vert_count_reg <= V_FRONT_PORCH_COUNT;
         ELSIF (s_next_line_reg = '1') THEN
            IF (s_vert_count_is_zero = '1') THEN
               s_vert_count_reg <= s_vert_load_value;
                                            ELSE
               s_vert_count_reg <= unsigned( s_vert_count_reg ) - 1;
            END IF;
         END IF;
      END IF;
   END PROCESS make_vert_count_reg;
   
   make_vert_load_value : PROCESS( s_vert_state_reg )
   BEGIN
      CASE (s_vert_state_reg) IS
         WHEN VERTICAL_FRONT_PORCH => s_vert_load_value <= V_SYNC_COUNT;
         WHEN VERTICAL_SYNC        => s_vert_load_value <= V_BACK_PORCH_COUNT;
         WHEN VERTICAL_BACK_PORCH  => s_vert_load_value <= V_ACTIVE_COUNT;
         WHEN OTHERS               => s_vert_load_value <= V_FRONT_PORCH_COUNT;
      END CASE;
   END PROCESS make_vert_load_value;
   
   make_vert_state_reg : PROCESS( clock_75MHz , s_vert_state_reg , s_next_line_reg ,
                                  vga_off , s_vert_count_is_zero )
      VARIABLE v_next_state : VCOUNT_TYPE;
   BEGIN
      CASE ( s_vert_state_reg ) IS
         WHEN VERTICAL_FRONT_PORCH => v_next_state := VERTICAL_SYNC;
         WHEN VERTICAL_SYNC        => v_next_state := VERTICAL_BACK_PORCH;
         WHEN VERTICAL_BACK_PORCH  => v_next_state := VERTICAL_ACTIVE;
         WHEN OTHERS               => v_next_state := VERTICAL_FRONT_PORCH;
      END CASE;
      IF (clock_75MHz'event AND (clock_75MHz = '1')) THEN
         IF (vga_off = '1') THEN s_vert_state_reg <= VERTICAL_FRONT_PORCH;
         ELSIF (s_next_line_reg = '1' AND
                s_vert_count_is_zero = '1') THEN s_vert_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_vert_state_reg;
   
   make_next_line_reg : PROCESS( clock_75MHz , vga_off , s_next_line )
   BEGIN
      IF (clock_75MHz'event AND (clock_75MHz = '1')) THEN
         IF (vga_off = '1') THEN s_next_line_reg <= '0';
                            ELSE s_next_line_reg <= s_next_line;
         END IF;
      END IF;
   END PROCESS make_next_line_reg;
   
   make_new_screen_reg : PROCESS( clock_75MHz , vga_off , s_new_screen , s_req_line )
   BEGIN
      IF (clock_75MHz'event AND (clock_75MHz = '1')) THEN
         IF (vga_off = '1') THEN s_new_screen_reg <= '0';
                                 s_req_line_reg   <= '0';
                            ELSE s_new_screen_reg <= s_new_screen;
                                 s_req_line_reg   <= s_req_line;
         END IF;
      END IF;
   END PROCESS make_new_screen_reg;
   
   make_line_counter_reg : PROCESS( clock_75MHz , s_new_screen_reg , s_req_line_reg )
   BEGIN
      IF (clock_75MHz'event AND (clock_75MHz = '1')) THEN
         IF (s_new_screen_reg = '1') THEN s_line_counter_reg <= (OTHERS => '0');
         ELSIF (s_req_line_reg = '1') THEN s_line_counter_reg <= unsigned(s_line_counter_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_line_counter_reg;
   
   make_stage_1_regs : PROCESS( clock_75MHz , vga_off , s_line_counter_reg ,
                                fg_color , bg_color , s_hsync , s_vsync , s_n_blank ,
                                s_is_fpga_cursor_pos , s_draw_hor_line ,
                                s_vert_count_is_zero , s_is_usbtmc_cursor )
   BEGIN
      IF (clock_75MHz'event AND (clock_75MHz = '1')) THEN
         IF (vga_off = '1') THEN 
            s_stage_1_data_sel_reg    <= "00";
            s_stage_1_line_index_reg  <= X"0";
            s_stage_1_pixel_index_reg <= "000";
            s_stage_1_fg_color_reg    <= "000";
            s_stage_1_bg_color_reg    <= "000";
            s_stage_1_hsync_reg       <= '0';
            s_stage_1_vsync_reg       <= '0';
            s_stage_1_n_blank_reg     <= '0';
            s_stage_1_cursor_reg      <= '0';
            s_stage_1_draw_line_reg   <= '0';
                            ELSE 
            CASE (s_line_counter_reg(9 DOWNTO 8)) IS
               WHEN   "00"  => s_stage_1_data_sel_reg <= "00";
                               IF (s_horiz_count_reg(9) = '0' AND
                                   (s_line_counter_reg(7 DOWNTO 4) /= X"0" AND
                                    s_line_counter_reg(7 DOWNTO 4) /= X"E" AND
                                    s_line_counter_reg(7 DOWNTO 4) /= X"F")) THEN
                                  s_stage_1_fg_color_reg <= "111";
                                  s_stage_1_bg_color_reg <= "000";
                                                               ELSE
                                  s_stage_1_fg_color_reg <= "110";
                                  s_stage_1_bg_color_reg <= "001";
                               END IF;
                               s_stage_1_draw_line_reg<= s_draw_hor_line;
                               s_stage_1_cursor_reg   <= '0';
               WHEN  OTHERS => s_stage_1_data_sel_reg <= "1"&s_horiz_count_reg(9);
                               IF (s_horiz_count_reg(9) = '1') THEN
                                  s_stage_1_fg_color_reg <= s_usbtmc_fg_color_reg;
                                  s_stage_1_bg_color_reg <= s_usbtmc_bg_color_reg;
                                  s_stage_1_cursor_reg   <= s_is_usbtmc_cursor;
                                                               ELSE
                                  s_stage_1_fg_color_reg <= fg_color;
                                  s_stage_1_bg_color_reg <= bg_color;
                                  s_stage_1_cursor_reg   <= s_is_fpga_cursor_pos;
                               END IF;
                               s_stage_1_draw_line_reg <= s_draw_hor_line OR
                                                          s_vert_count_is_zero;
            END CASE;
            s_stage_1_line_index_reg  <= s_line_counter_reg( 3 DOWNTO 0 );
            s_stage_1_pixel_index_reg <= s_horiz_count_reg( 2 DOWNTO 0 );
            s_stage_1_hsync_reg       <= s_hsync;
            s_stage_1_vsync_reg       <= s_vsync;
            s_stage_1_n_blank_reg     <= s_n_blank;
         END IF;
      END IF;
   END PROCESS make_stage_1_regs;
   
   make_stage_1_data : PROCESS( s_stage_1_data_sel_reg , 
                                s_ascii_data_1 , s_ascii_data_2 , s_ascii_data_3 )
   BEGIN
      CASE (s_stage_1_data_sel_reg) IS
         WHEN  "00"  => s_stage_1_ascii_data <= s_ascii_data_1;
         WHEN  "11"  => s_stage_1_ascii_data <= s_ascii_data_2;
         WHEN OTHERS => s_stage_1_ascii_data <= s_ascii_data_3;
      END CASE;
   END PROCESS make_stage_1_data;
   
   make_stage_2_regs : PROCESS( clock_75MHz , vga_off , s_stage_1_fg_color_reg , s_stage_1_bg_color_reg ,
                                s_stage_1_hsync_reg , s_stage_1_vsync_reg , s_stage_1_n_blank_reg ,
                                s_stage_1_cursor_reg , s_stage_1_ascii_data ,
                                s_blink_reg , s_stage_1_draw_line_reg )
   BEGIN
      IF (clock_75MHz'event AND (clock_75MHz = '1')) THEN
         IF (vga_off = '1') THEN 
            s_stage_2_fg_color_reg  <= "000";
            s_stage_2_bg_color_reg  <= "000";
            s_stage_2_hsync_reg     <= '0';
            s_stage_2_vsync_reg     <= '0';
            s_stage_2_n_blank_reg   <= '0';
            s_stage_2_cursor_reg    <= '0';
            s_stage_2_pixel_inv_reg <= '0';
                            ELSE 
            IF (s_stage_1_draw_line_reg = '1') THEN
               s_stage_2_fg_color_reg  <= "001";
               s_stage_2_bg_color_reg  <= "001";
                                               ELSE
               s_stage_2_fg_color_reg  <= s_stage_1_fg_color_reg;
               s_stage_2_bg_color_reg  <= s_stage_1_bg_color_reg;
            END IF;
            s_stage_2_hsync_reg     <= s_stage_1_hsync_reg;
            s_stage_2_vsync_reg     <= s_stage_1_vsync_reg;
            s_stage_2_n_blank_reg   <= s_stage_1_n_blank_reg;
            s_stage_2_cursor_reg    <= s_stage_1_cursor_reg AND s_blink_reg;
            s_stage_2_pixel_inv_reg <= s_stage_1_ascii_data(7);
         END IF;
      END IF;
   END PROCESS make_stage_2_regs;

--------------------------------------------------------------------------------
--- Here the usbtmc handling is defined                                      ---
--------------------------------------------------------------------------------
   command_done  <= '1' WHEN s_usbtmc_state_reg = SIGNAL_DONE OR
                             s_usbtmc_state_reg = SIGNAL_ERROR ELSE '0';
   command_error <= '1' WHEN s_usbtmc_state_reg = SIGNAL_ERROR ELSE '0';
   pop           <= s_pop_data;
   push          <= s_push;
   push_size     <= '1' WHEN s_push_cnt_reg = X"6" ELSE '0';
   
   s_usbtmc_write_address( 10 DOWNTO 6 ) <= unsigned(s_usbtmc_cursor_y_reg)+
                                            unsigned(s_usbtmc_screen_offset_reg)+
                                            unsigned(s_clear_counter_reg(10 DOWNTO 6));
   s_usbtmc_write_address(  5 DOWNTO 0 ) <= unsigned(s_usbtmc_cursor_x_reg)+
                                            unsigned(s_clear_counter_reg( 5 DOWNTO 0));
   s_usbtmc_write_data                   <= X"20" WHEN s_clear_counter_reg(11) = '0' 
                                                  ELSE pop_data;
   s_usbtmc_write_enable <= '1' WHEN s_clear_counter_reg(11) = '0' OR
                                     s_valid_char = '1' ELSE '0';
   s_pop_data    <= '1' WHEN (s_usbtmc_state_reg = GET_BG_COLOR OR
                              s_usbtmc_state_reg = GET_FG_COLOR OR
                              (s_usbtmc_state_reg = WRITE_CHAR AND
                               s_last_char_reg = '0') OR
                              s_usbtmc_state_reg = GET_X_CHAR OR
                              s_usbtmc_state_reg = GET_Y_CHAR) AND
                             pop_empty = '0' ELSE '0';
   s_next_cursor_xpos <= "1000000" WHEN s_pop_data = '1' AND
                                        pop_data = X"0A" AND
                                        s_usbtmc_state_reg = WRITE_CHAR ELSE
                         unsigned("0"&s_usbtmc_cursor_x_reg) + 1 
                            WHEN s_valid_char = '1' ELSE
                         "0"&s_usbtmc_cursor_x_reg;
   s_next_cursor_ypos <= unsigned("0"&s_usbtmc_cursor_y_reg)+1;
   s_push             <= '1' WHEN s_usbtmc_state_reg = SEND_CURSOR AND
                                  push_full = '0' AND
                                  s_push_cnt_reg(3) = '0' ELSE '0';
   s_valid_char       <= '1' WHEN s_pop_data = '1' AND
                                  s_usbtmc_state_reg = WRITE_CHAR AND
                                  (unsigned(pop_data(6 DOWNTO 0)) >
                                   unsigned(c_31)) ELSE '0';

   make_usbtmc_screen_offset_reg : PROCESS( clock , reset , s_usbtmc_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_usbtmc_state_reg = INIT_CLEAR_SCREEN OR
             reset = '1') THEN s_usbtmc_screen_offset_reg <= (OTHERS => '0');
         ELSIF (s_next_cursor_ypos(5) = '1' AND
                s_usbtmc_state_reg = NEW_LINE) THEN
            s_usbtmc_screen_offset_reg <= unsigned(s_usbtmc_screen_offset_reg)+1;
         END IF;
      END IF;
   END PROCESS make_usbtmc_screen_offset_reg;
   
   make_usbtmc_cursor_x_reg : PROCESS( clock , reset , s_usbtmc_state_reg ,
                                       s_new_cursor_x_pos_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_usbtmc_state_reg = INIT_CLEAR_SCREEN OR
             reset = '1') THEN s_usbtmc_cursor_x_reg <= (OTHERS => '0');
         ELSIF (s_usbtmc_state_reg = UPDATE_CURSOR) THEN
            s_usbtmc_cursor_x_reg <= s_new_cursor_x_pos_reg;
                                                    ELSE
            s_usbtmc_cursor_x_reg <= s_next_cursor_xpos(5 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS make_usbtmc_cursor_x_reg;
   
   make_usbtmc_cursor_y_reg : PROCESS( clock , reset , s_usbtmc_state_reg ,
                                       s_next_cursor_ypos , 
                                       s_new_cursor_y_pos_reg)
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_usbtmc_state_reg = INIT_CLEAR_SCREEN OR
             reset = '1') THEN s_usbtmc_cursor_y_reg <= (OTHERS => '0');
         ELSIF (s_usbtmc_state_reg = NEW_LINE AND
                s_next_cursor_ypos(5) = '0') THEN
            s_usbtmc_cursor_y_reg <= s_next_cursor_ypos( 4 DOWNTO 0 );
         ELSIF (s_usbtmc_state_reg = UPDATE_CURSOR) THEN
            s_usbtmc_cursor_y_reg <= s_new_cursor_y_pos_reg;
         END IF;
      END IF;
   END PROCESS make_usbtmc_cursor_y_reg;
   
   make_usbtmc_fg_color_reg : PROCESS( clock , reset )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_usbtmc_fg_color_reg <= "111";
         ELSIF (s_usbtmc_state_reg = SET_FG_COLOR) THEN
            s_usbtmc_fg_color_reg <= s_pop_data_reg( 2 DOWNTO 0 );
         END IF;
      END IF;
   END PROCESS make_usbtmc_fg_color_reg;
   
   make_usbtmc_bg_color_reg : PROCESS( clock , reset )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_usbtmc_bg_color_reg <= "000";
         ELSIF (s_usbtmc_state_reg = SET_BG_COLOR) THEN
            s_usbtmc_bg_color_reg <= s_pop_data_reg( 2 DOWNTO 0 );
         END IF;
      END IF;
   END PROCESS make_usbtmc_bg_color_reg;
   
   make_pop_data_reg : PROCESS( clock , reset , s_pop_data , pop_data )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_pop_data_reg <= X"00";
         ELSIF (s_pop_data = '1') THEN s_pop_data_reg <= pop_data;
         END IF;
      END IF;
   END PROCESS make_pop_data_reg;
   
   make_clear_counter_reg : PROCESS( clock , reset , s_usbtmc_state_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_usbtmc_state_reg = INIT_CLEAR_SCREEN) THEN
            s_clear_counter_reg <= "011111111111";
         ELSIF (s_usbtmc_state_reg = INIT_CLEAR_LINE) THEN
            s_clear_counter_reg <= "000000111111";
         ELSIF (s_clear_counter_reg(11) = '0' AND
                reset = '0') THEN
            s_clear_counter_reg <= unsigned(s_clear_counter_reg) - 1;
         ELSIF (reset = '1' OR
                s_clear_counter_reg(11) = '1') THEN 
            s_clear_counter_reg <= "100000000000";
         END IF;
      END IF;
   END PROCESS make_clear_counter_reg;
   
   make_last_char_reg : PROCESS( clock , reset , s_usbtmc_state_reg ,
                                 s_pop_data , pop_last )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_usbtmc_state_reg = IDLE OR
             reset = '1') THEN s_last_char_reg <= '0';
         ELSIF (s_usbtmc_state_reg = WRITE_CHAR AND
                s_pop_data = '1' AND
                pop_last = '1') THEN s_last_char_reg <= '1';
         END IF;
      END IF;
   END PROCESS make_last_char_reg;
   
   make_usbtmc_cursor_x_bcd_reg : PROCESS( clock , s_usbtmc_cursor_x_reg )
      VARIABLE v_sub1   : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_rest_1 : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_sub2   : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_rest_2 : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_sub3   : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_rest_3 : std_logic_vector( 3 DOWNTO 0 );
   BEGIN
      v_sub1 := unsigned("0"&s_usbtmc_cursor_x_reg(5 DOWNTO 2)) -
                unsigned(c_ten);
      IF (v_sub1(4) = '0') THEN v_rest_1 := v_sub1(3 DOWNTO 0)&
                                            s_usbtmc_cursor_x_reg(1);
                           ELSE v_rest_1 := s_usbtmc_cursor_x_reg(5 DOWNTO 1);
      END IF;
      v_sub2 := unsigned(v_rest_1) - unsigned(c_ten);
      IF (v_sub2(4) = '0') THEN v_rest_2 := v_sub2(3 DOWNTO 0)&
                                            s_usbtmc_cursor_x_reg(0);
                           ELSE v_rest_2 := v_rest_1(3 DOWNTO 0)&
                                            s_usbtmc_cursor_x_reg(0);
      END IF;
      v_sub3 := unsigned(v_rest_2) - unsigned(c_ten);
      IF (v_sub3(4) = '0') THEN v_rest_3 := v_sub3( 3 DOWNTO 0 );
                           ELSE v_rest_3 := v_rest_2( 3 DOWNTO 0 );
      END IF;
      IF (clock'event AND (clock = '1')) THEN
         s_usbtmc_cursor_x_bcd_reg(6) <= NOT(v_sub1(4));
         s_usbtmc_cursor_x_bcd_reg(5) <= NOT(v_sub2(4));
         s_usbtmc_cursor_x_bcd_reg(4) <= NOT(v_sub3(4));
         s_usbtmc_cursor_x_bcd_reg(3 DOWNTO 0) <= v_rest_3;
      END IF;
   END PROCESS make_usbtmc_cursor_x_bcd_reg;
   
   make_usbtmc_cursor_y_bcd_reg : PROCESS( clock , s_usbtmc_cursor_y_reg )
      VARIABLE v_sub1   : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_rest_1 : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_sub2   : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_rest_2 : std_logic_vector( 3 DOWNTO 0 );
   BEGIN
      v_sub1 := unsigned("0"&s_usbtmc_cursor_y_reg(4 DOWNTO 1)) -
                unsigned(c_ten);
      IF (v_sub1(4) = '0') THEN v_rest_1 := v_sub1(3 DOWNTO 0)&
                                            s_usbtmc_cursor_y_reg(0);
                           ELSE v_rest_1 := s_usbtmc_cursor_y_reg(4 DOWNTO 0);
      END IF;
      v_sub2 := unsigned(v_rest_1) - unsigned(c_ten);
      IF (v_sub2(4) = '0') THEN v_rest_2 := v_sub2(3 DOWNTO 0);
                           ELSE v_rest_2 := v_rest_1(3 DOWNTO 0);
      END IF;
      IF (clock'event AND (clock = '1')) THEN
         s_usbtmc_cursor_y_bcd_reg(5) <= NOT(v_sub1(4));
         s_usbtmc_cursor_y_bcd_reg(4) <= NOT(v_sub2(4));
         s_usbtmc_cursor_y_bcd_reg(3 DOWNTO 0) <= v_rest_2;
      END IF;
   END PROCESS make_usbtmc_cursor_y_bcd_reg;
   
   make_push_data : PROCESS( s_push_cnt_reg , s_usbtmc_cursor_x_bcd_reg ,
                             s_usbtmc_cursor_y_bcd_reg)
   BEGIN
      CASE (s_push_cnt_reg) IS
         WHEN  X"6"  => IF (s_usbtmc_cursor_x_bcd_reg(6 DOWNTO 4) = "000" AND
                            s_usbtmc_cursor_y_bcd_reg(5 DOWNTO 4) = "00") THEN
                           push_data <= X"04";
                        ELSIF (s_usbtmc_cursor_x_bcd_reg(6 DOWNTO 4) = "000" OR
                               s_usbtmc_cursor_y_bcd_reg(5 DOWNTO 4) = "00") THEN
                           push_data <= X"05";
                                                                             ELSE
                           push_data <= X"06";
                        END IF;
         WHEN  X"5"  => push_data <= X"3"&"0"&s_usbtmc_cursor_x_bcd_reg(6 DOWNTO 4);
         WHEN  X"4"  => push_data <= X"3"&s_usbtmc_cursor_x_bcd_reg(3 DOWNTO 0);
         WHEN  X"3"  => push_data <= X"2C";
         WHEN  X"2"  => push_data <= X"3"&"00"&s_usbtmc_cursor_y_bcd_reg(5 DOWNTO 4);
         WHEN  X"1"  => push_data <= X"3"&s_usbtmc_cursor_y_bcd_reg(3 DOWNTO 0);
         WHEN  X"0"  => push_data <= X"0A";
         WHEN OTHERS => push_data <= X"00";
      END CASE;
   END PROCESS make_push_data;
   
   make_push_cnt_reg : PROCESS( clock , reset , s_usbtmc_cursor_x_bcd_reg ,
                                s_usbtmc_cursor_y_bcd_reg )
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_push_cnt_reg <= (OTHERS => '1');
         ELSIF (s_usbtmc_state_reg = INIT_CURSOR_SEND) THEN
            s_push_cnt_reg <= X"6";
         ELSIF (s_push = '1') THEN
            CASE (s_push_cnt_reg) IS
               WHEN  X"6"  => IF (s_usbtmc_cursor_x_bcd_reg(6 DOWNTO 4) = "000") THEN
                                 s_push_cnt_reg <= X"4";
                                                                                    ELSE
                                 s_push_cnt_reg <= X"5";
                              END IF;
               WHEN  X"3"  => IF (s_usbtmc_cursor_y_bcd_reg(5 DOWNTO 4) = "00") THEN
                                 s_push_cnt_reg <= X"1";
                                                                                ELSE
                                 s_push_cnt_reg <= X"2";
                              END IF;
               WHEN OTHERS => s_push_cnt_reg <= unsigned(s_push_cnt_reg) - 1;
            END CASE;
         END IF;
      END IF;
   END PROCESS make_push_cnt_reg;
   
   make_new_cursor_x_pos_reg : PROCESS( clock , reset , s_usbtmc_state_reg ,
                                        s_pop_data_reg )
      VARIABLE v_add_1 : std_logic_vector( 5 DOWNTO 0 );
      VARIABLE v_add_2 : std_logic_vector( 5 DOWNTO 0 );
      VARIABLE v_add_3 : std_logic_vector( 5 DOWNTO 0 );
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_usbtmc_state_reg = INIT_GET_CURSOR OR
             reset = '1') THEN
            s_new_cursor_x_pos_reg <= (OTHERS => '0');
         ELSIF (s_usbtmc_state_reg = MULT_10_X) THEN
            v_add_1 := s_new_cursor_x_pos_reg(2 DOWNTO 0)&"000";
            v_add_2 := s_new_cursor_x_pos_reg(4 DOWNTO 0)&"0";
            v_add_3 := "00"&s_pop_data_reg(3 DOWNTO 0);
            s_new_cursor_x_pos_reg <= unsigned(v_add_1) +
                                      unsigned(v_add_2) +
                                      unsigned(v_add_3);
         END IF;
      END IF;
   END PROCESS make_new_cursor_x_pos_reg;
   
   make_new_cursor_y_pos_reg : PROCESS( clock , reset , s_usbtmc_state_reg ,
                                        s_pop_data_reg )
      VARIABLE v_add_1 : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_add_2 : std_logic_vector( 4 DOWNTO 0 );
      VARIABLE v_add_3 : std_logic_vector( 4 DOWNTO 0 );
   BEGIN
      IF (clock'event AND (clock = '1')) THEN
         IF (s_usbtmc_state_reg = INIT_GET_CURSOR OR
             reset = '1') THEN
            s_new_cursor_y_pos_reg <= (OTHERS => '0');
         ELSIF (s_usbtmc_state_reg = MULT_10_Y) THEN
            v_add_1 := s_new_cursor_y_pos_reg( 1 DOWNTO 0 )&"000";
            v_add_2 := s_new_cursor_y_pos_reg( 3 DOWNTO 0 )&"0";
            v_add_3 := "0"&s_pop_data_reg( 3 DOWNTO 0 );
            s_new_cursor_y_pos_reg <= unsigned(v_add_1) +
                                      unsigned(v_add_2) +
                                      unsigned(v_add_3);
         END IF;
      END IF;
   END PROCESS make_new_cursor_y_pos_reg;
   
   make_state_reg : PROCESS( clock , reset , s_usbtmc_state_reg , start_command , 
                             command_id , s_clear_counter_reg )
      VARIABLE v_next_state : USBTMC_STATE_TYPE;
   BEGIN
      CASE (s_usbtmc_state_reg) IS
         WHEN IDLE               => IF (start_command = '1') THEN
                                       CASE (command_id) IS
                                          WHEN "0111011" => v_next_state := GET_BG_COLOR;
                                          WHEN "0111100" => v_next_state := INIT_CLEAR_SCREEN;
                                          WHEN "0111101" => v_next_state := INIT_GET_CURSOR;
                                          WHEN "0111110" => v_next_state := INIT_CURSOR_SEND;
                                          WHEN "0111111" => v_next_state := GET_FG_COLOR;
                                          WHEN "1000000" => v_next_state := WRITE_CHAR;
                                          WHEN OTHERS    => v_next_state := IDLE;
                                       END CASE;
                                                             ELSE
                                       v_next_state := IDLE;
                                    END IF;
         WHEN INIT_CLEAR_SCREEN  => v_next_state := CLEAR_SCREEN;
         WHEN CLEAR_SCREEN       => IF (s_clear_counter_reg(11) = '1') THEN
                                       v_next_state := SIGNAL_DONE;
                                                                       ELSE
                                       v_next_state := CLEAR_SCREEN;
                                    END IF;
         WHEN GET_BG_COLOR       => IF (s_pop_data = '1') THEN
                                       IF (pop_data(7 DOWNTO 4) = X"3") THEN
                                          v_next_state := SET_BG_COLOR;
                                       ELSIF (pop_data = X"20" AND
                                              pop_last = '0') THEN
                                          v_next_state := GET_BG_COLOR;
                                                              ELSE
                                          v_next_state := SIGNAL_ERROR;
                                       END IF;
                                                          ELSE
                                       v_next_state := GET_BG_COLOR;
                                    END IF;
         WHEN SET_BG_COLOR       => v_next_state := SIGNAL_DONE;
         WHEN GET_FG_COLOR       => IF (s_pop_data = '1') THEN
                                       IF (pop_data(7 DOWNTO 4) = X"3") THEN
                                          v_next_state := SET_FG_COLOR;
                                       ELSIF (pop_data = X"20" AND
                                              pop_last = '0') THEN
                                          v_next_state := GET_FG_COLOR;
                                                              ELSE
                                          v_next_state := SIGNAL_ERROR;
                                       END IF;
                                                          ELSE
                                       v_next_state := GET_FG_COLOR;
                                    END IF;
         WHEN SET_FG_COLOR       => v_next_state := SIGNAL_DONE;
         WHEN WRITE_CHAR         => IF (s_last_char_reg = '1') THEN
                                        v_next_state := SIGNAL_DONE;
                                    ELSIF (s_next_cursor_xpos(6) = '1') THEN
                                          v_next_state := NEW_LINE;
                                                                        ELSE
                                          v_next_state := WRITE_CHAR;
                                    END IF;
         WHEN NEW_LINE           => IF (s_next_cursor_ypos(5) = '1') THEN
                                       v_next_state := INIT_CLEAR_LINE;
                                                                     ELSE
                                       v_next_state := WRITE_CHAR;
                                    END IF;
         WHEN INIT_CLEAR_LINE    => v_next_state := CLEAR_LINE;
         WHEN CLEAR_LINE         => IF (s_clear_counter_reg(11) = '1') THEN
                                       v_next_state := CLEAR_NOP;
                                                                       ELSE
                                       v_next_state := CLEAR_LINE;
                                    END IF;
         WHEN CLEAR_NOP          => v_next_state := WRITE_CHAR;
         WHEN INIT_CURSOR_SEND   => v_next_state := SEND_CURSOR;
         WHEN SEND_CURSOR        => IF (s_push_cnt_reg(3) = '1') THEN
                                       v_next_state := SIGNAL_DONE;
                                                                 ELSE
                                       v_next_state := SEND_CURSOR;
                                    END IF;
         WHEN INIT_GET_CURSOR    => v_next_state := GET_X_CHAR;
         WHEN GET_X_CHAR         => IF (s_pop_data = '1') THEN
                                       IF (pop_data = X"20" AND
                                           pop_last = '0') THEN
                                          v_next_state := GET_X_CHAR;
                                       ELSIF (pop_data = X"2C" AND
                                              pop_last = '0') THEN
                                          v_next_state := GET_Y_CHAR;
                                       ELSIF (pop_data(7 DOWNTO 4) = X"3" AND
                                              pop_last = '0') THEN
                                          v_next_state := MULT_10_X;
                                                                           ELSE
                                          v_next_state := SIGNAL_ERROR;
                                       END IF;
                                                          ELSE
                                       v_next_state := GET_X_CHAR;
                                    END IF;
         WHEN MULT_10_X          => v_next_state := GET_X_CHAR;
         WHEN GET_Y_CHAR         => IF (s_pop_data = '1') THEN
                                       IF (pop_data = X"20" AND
                                           pop_last = '0') THEN
                                          v_next_state := GET_Y_CHAR;
                                       ELSIF (pop_data = X"0A" AND
                                              pop_last = '1') THEN
                                          v_next_state := UPDATE_CURSOR;
                                       ELSIF (pop_data(7 DOWNTO 4) = X"3" AND
                                              pop_last = '0') THEN
                                          v_next_state := MULT_10_Y;
                                                                           ELSE
                                          v_next_state := SIGNAL_ERROR;
                                       END IF;
                                                          ELSE
                                       v_next_state := GET_Y_CHAR;
                                    END IF;
         WHEN MULT_10_Y          => v_next_state := GET_Y_CHAR;
         WHEN UPDATE_CURSOR      => v_next_state := SIGNAL_DONE;
         WHEN OTHERS             => v_next_state := IDLE;
      END CASE;
      IF (clock'event AND (clock = '1')) THEN
         IF (reset = '1') THEN s_usbtmc_state_reg <= IDLE;
                          ELSE s_usbtmc_state_reg <= v_next_state;
         END IF;
      END IF;
   END PROCESS make_state_reg;

-- map components
   hsync_ff : FDC
              GENERIC MAP ( INIT => '0' )
              PORT MAP ( Q   => vga_hsync,
                         C   => clock_75MHz,
                         CLR => vga_off,
                         D   => s_stage_2_hsync_reg );

   vsync_ff : FDC
              GENERIC MAP ( INIT => '0' )
              PORT MAP ( Q   => vga_vsync,
                         C   => clock_75MHz,
                         CLR => vga_off,
                         D   => s_stage_2_vsync_reg );
   red_ff : FDC
            GENERIC MAP ( INIT => '0' )
            PORT MAP ( Q   => vga_red,
                       C   => clock_75MHz,
                       CLR => vga_off,
                       D   => s_red );

   green_ff : FDC
              GENERIC MAP ( INIT => '0' )
              PORT MAP ( Q   => vga_green,
                         C   => clock_75MHz,
                         CLR => vga_off,
                         D   => s_green );

   blue_ff : FDC
             GENERIC MAP ( INIT => '0' )
             PORT MAP ( Q   => vga_blue,
                        C   => clock_75MHz,
                        CLR => vga_off,
                        D   => s_blue );

   usbtmc_buf : RAMB16_S9_S9
                PORT MAP ( DOA   => s_ascii_data_2,
                           DOPA  => OPEN,
                           ADDRA => s_usbtmc_lookup_address,
                           CLKA  => clock_75MHz,
                           DIA   => X"00",
                           DIPA  => "0",
                           ENA   => s_n_blank,
                           SSRA  => '0',
                           WEA   => '0',
                           DOB   => OPEN,
                           DOPB  => OPEN,
                           ADDRB => s_usbtmc_write_address,
                           CLKB  => clock,
                           DIB   => s_usbtmc_write_data,
                           DIPB  => "1",
                           ENB   => s_usbtmc_write_enable,
                           SSRB  => '0',
                           WEB   => s_usbtmc_write_enable);
   
   fpga_buf : RAMB16_S9_S9
                PORT MAP ( DOA   => s_ascii_data_3,
                           DOPA  => OPEN,
                           ADDRA => s_fpga_lookup_address,
                           CLKA  => clock_75MHz,
                           DIA   => X"00",
                           DIPA  => "0",
                           ENA   => s_n_blank,
                           SSRA  => '0',
                           WEA   => '0',
                           DOB   => OPEN,
                           DOPB  => OPEN,
                           ADDRB => write_address,
                           CLKB  => clock,
                           DIB   => ascii_data,
                           DIPB  => "1",
                           ENB   => we,
                           SSRB  => '0',
                           WEB   => we);

   ascii_buf0 : RAMB16_S9_S9
                PORT MAP ( DOA   => s_ascii_data_1,
                           DOPA  => OPEN,
                           ADDRA => s_lookup_address,
                           CLKA  => clock_75MHz,
                           DIA   => X"00",
                           DIPA  => "0",
                           ENA   => s_n_blank,
                           SSRA  => '0',
                           WEA   => '0',
                           DOB   => OPEN,
                           DOPB  => OPEN,
                           ADDRB => we_addr,
                           CLKB  => clock,
                           DIB   => we_ascii,
                           DIPB  => "1",
                           ENB   => we_char,
                           SSRB  => '0',
                           WEB   => we_char);
   rom_lo : RAMB16_S1
      PORT MAP ( DO   => s_rom_value_0,
                 ADDR => s_rom_index(13 DOWNTO 0),
                 CLK  => clock_75MHz,
                 DI   => s_rom_value_0,
                 EN   => '1',
                 SSR  => '0',
                 WE   => '0');

END xilinx;
