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

ARCHITECTURE behave OF xc3s200an_top IS

   COMPONENT clocks
      PORT ( system_n_reset    : IN  std_logic;
             clock_25MHz       : IN  std_logic;
             clock_16MHz       : IN  std_logic;
             user_clock_1      : IN  std_logic;
             user_clock_2      : IN  std_logic;
             -- Here the compensated clocks are defined
             user_clock_1_out  : OUT std_logic;
             user_clock_1_fb   : IN  std_logic;
             user_clock_1_lock : OUT std_logic;
             user_clock_2_out  : OUT std_logic;
             user_clock_2_fb   : IN  std_logic;
             user_clock_2_lock : OUT std_logic;
             -- Here the master clocks are defined
             clock_25MHz_out   : OUT std_logic;
             clock_48MHz_out   : OUT std_logic;
             -- Here the FPGA internal clocks are defined
             clk_48MHz         : OUT std_logic;
             clk_96MHz         : OUT std_logic;
             clk_75MHz         : OUT std_logic;
             reset_out         : OUT std_logic;
             msec_tick         : OUT std_logic );
   END COMPONENT;
   
   COMPONENT eeprom_emu
      PORT ( clock     : IN  std_logic;
             reset     : IN  std_logic;
             button    : IN  std_logic;
             SDA_in    : IN  std_logic;
             SCL_in    : IN  std_logic;
             SDA_out   : OUT std_logic );
   END COMPONENT;
   
   COMPONENT USBTMC
      PORT ( clock_96MHz      : IN  std_logic;
             clock_48MHz      : IN  std_logic;
             cpu_reset        : IN  std_logic;
             sync_reset_out   : OUT std_logic;
             -- FX2 control interface
             FX2_n_ready      : IN  std_logic;
             FX2_hi_speed     : IN  std_logic;
             -- SCPI command interpretor interface
             pending_message  : IN  std_logic;
             transfer_in_prog : OUT std_logic;
             -- read fifo interface
             rf_pop           : IN  std_logic;
             rf_pop_data      : OUT std_logic_vector( 7 DOWNTO 0 );
             rf_last_data_byte: OUT std_logic;
             rf_fifo_empty    : OUT std_logic;
             -- Write fifo interface
             wf_push          : IN  std_logic;
             wf_push_data     : IN  std_logic_vector( 7 DOWNTO 0 );
             wf_push_size_bit : IN  std_logic;
             wf_fifo_full     : OUT std_logic;
             wf_fifo_empty    : OUT std_logic;
             -- status interface
             status_nibble    : IN  std_logic_vector( 3 DOWNTO 0 );
             indicator_pulse  : OUT std_logic;
             -- FX2 port D interface
             data_nibble      : OUT std_logic_vector( 3 DOWNTO 0 );
             data_select      : IN  std_logic_vector( 3 DOWNTO 0 );
             -- FX2 FIFO interface
             EP8_n_empty      : IN  std_logic;
             EP6_n_full       : IN  std_logic;
             EP_data_in       : IN  std_logic_vector( 7 DOWNTO 0 );
             EP_address       : OUT std_logic_vector( 1 DOWNTO 0 );
             EP_IFCLOCK       : OUT std_logic;
             EP_n_PKTEND      : OUT std_logic;
             EP_n_OE          : OUT std_logic;
             EP_n_RE          : OUT std_logic;
             EP_n_WE          : OUT std_logic;
             EP_data_out      : OUT std_logic_vector( 7 DOWNTO 0 );
             EP_n_tri_out     : OUT std_logic_vector( 7 DOWNTO 0 ) );
   END COMPONENT;
   
   COMPONENT vga_controller
      PORT ( clock_75MHz         : IN  std_logic;
             reset               : IN  std_logic;
             vga_off             : IN  std_logic;
             clock               : IN  std_logic;
             -- Here the scpi interface is defined
             start_command       : IN  std_logic;
             command_id          : IN  std_logic_vector( 6 DOWNTO 0 );
             command_done        : OUT std_logic;
             command_error       : OUT std_logic;
             -- Here the usbtmc fifo interface is defined
             pop                 : OUT std_logic;
             pop_data            : IN  std_logic_vector(  7 DOWNTO 0 );
             pop_last            : IN  std_logic;
             pop_empty           : IN  std_logic;
             push                : OUT std_logic;
             push_data           : OUT std_logic_vector(  7 DOWNTO 0 );
             push_size           : OUT std_logic;
             push_full           : IN  std_logic;
             -- Here the PUD interface is defined
             we_char             : IN  std_logic;
             we_ascii            : IN  std_logic_vector(  7 DOWNTO 0 );
             we_addr             : IN  std_logic_vector( 10 DOWNTO 0 );
             -- Here the fpga interface is defined
             cursor_pos          : IN  std_logic_vector( 10 DOWNTO 0 );
             screen_offset       : IN  std_logic_vector(  4 DOWNTO 0 );
             fg_color            : IN  std_logic_vector(  2 DOWNTO 0 );
             bg_color            : IN  std_logic_vector(  2 DOWNTO 0 );
             write_address       : IN  std_logic_vector( 10 DOWNTO 0 );
             ascii_data          : IN  std_logic_vector(  7 DOWNTO 0 );
             we                  : IN  std_logic;
             vga_red             : OUT std_logic;
             vga_green           : OUT std_logic;
             vga_blue            : OUT std_logic;
             vga_hsync           : OUT std_logic;
             vga_vsync           : OUT std_logic );
   END COMPONENT;
   
   COMPONENT SCPI_INTERFACE
      PORT ( clock            : IN  std_logic;
             reset            : IN  std_logic;
             -- The command interface
             transparent_mode : IN  std_logic;
             start_command    : OUT std_logic;
             command_id       : OUT std_logic_vector( 6 DOWNTO 0 );
             cmd_gen_respons  : OUT std_logic;
             command_done     : IN  std_logic;
             command_error    : IN  std_logic;
             unknown_command  : OUT std_logic;
             slave_pop        : IN  std_logic;
             -- USBTMC fifo interface
             pop              : OUT std_logic;
             pop_data         : IN  std_logic_vector( 7 DOWNTO 0 );
             pop_empty        : IN  std_logic;
             pop_last         : IN  std_logic);
   END COMPONENT;
   
   COMPONENT IDN_handler
      PORT ( clock     : IN  std_logic;
             reset     : IN  std_logic;
             start     : IN  std_logic;
             command   : IN  std_logic_vector( 6 DOWNTO 0 );
             fifo_full : IN  std_logic;
             done      : OUT std_logic;
             push      : OUT std_logic;
             size_bit  : OUT std_logic;
             push_data : OUT std_logic_vector( 7 DOWNTO 0 ) );
   END COMPONENT;
   
   COMPONENT identify_handler
      PORT ( clock       : IN  std_logic;
             reset       : IN  std_logic;
             start       : IN  std_logic;
             command     : IN  std_logic_vector( 6 DOWNTO 0 );
             indicator   : IN  std_logic;
             done        : OUT std_logic;
             flash_idle  : IN  std_logic;
             msec_tick   : IN  std_logic;
             leds_a_in   : IN  std_logic_vector( 7 DOWNTO 0 );
             leds_k_in   : IN  std_logic_vector( 7 DOWNTO 0 );
             leds_a      : OUT std_logic_vector( 7 DOWNTO 0 );
             leds_k      : OUT std_logic_vector( 7 DOWNTO 0 ));
   END COMPONENT;
   
   COMPONENT fpga_if
      PORT ( clock             : IN  std_logic;
             reset             : IN  std_logic;
             -- Here the FPGA info is provided
             fpga_idle         : OUT std_logic;
             fpga_revision     : OUT std_logic_vector( 3 DOWNTO 0 );
             fpga_type         : OUT std_logic_vector( 2 DOWNTO 0 );
             fpga_configured   : OUT std_logic;
             fpga_crc_error    : OUT std_logic;
             -- Here the bitfile fifo if is defined
             push              : IN  std_logic;
             push_data         : IN  std_logic_vector( 7 DOWNTO 0 );
             last_byte         : IN  std_logic;
             fifo_full         : OUT std_logic;
             -- Here the select map pins are defined
             fpga_done         : IN  std_logic;
             fpga_busy         : IN  std_logic;
             fpga_n_init       : IN  std_logic;
             fpga_n_prog       : OUT std_logic;
             fpga_rd_n_wr      : OUT std_logic;
             fpga_n_cs         : OUT std_logic;
             fpga_cclk         : OUT std_logic;
             fpga_data_in      : IN  std_logic_vector( 7 DOWNTO 0 );
             fpga_data_out     : OUT std_logic_vector( 7 DOWNTO 0 );
             fpga_n_tri        : OUT std_logic_vector( 7 DOWNTO 0 );
             fpga_data_in_ena  : OUT std_logic;
             fpga_data_out_ena : OUT std_logic);
   END COMPONENT;
   
   COMPONENT bitfile_interpreter
      PORT ( clock                 : IN  std_logic;
             reset                 : IN  std_logic;
             msec_tick             : IN  std_logic;
             -- Here the handshake interface is defined
             start                 : IN  std_logic;
             write_flash           : IN  std_logic;
             done                  : OUT std_logic;
             error_detected        : OUT std_logic;
             -- Here the FX2 fifo interface is defined
             pop                   : OUT std_logic;
             pop_data              : IN  std_logic_vector( 7 DOWNTO 0 );
             pop_last              : IN  std_logic;
             fifo_empty            : IN  std_logic;
             -- Here the FPGA_IF fifo interface is defined
             push                  : OUT std_logic;
             push_data             : OUT std_logic_vector( 7 DOWNTO 0 );
             last_byte             : OUT std_logic;
             fifo_full             : IN  std_logic;
             reset_fpga_if         : OUT std_logic;
             -- Here the flash write fifo interface is defined
             bitfile_size          : OUT std_logic_vector(31 DOWNTO 0 );
             we_fifo               : OUT std_logic;
             we_data               : OUT std_logic_vector( 7 DOWNTO 0 );
             we_last               : OUT std_logic;
             we_fifo_full          : IN  std_logic;
             start_write           : OUT std_logic;
             size_error            : IN  std_logic;
             -- Here the debug vga interface is defined
             we_char               : OUT std_logic;
             ascii_data            : OUT std_logic_vector( 7 DOWNTO 0 ));
   END COMPONENT;
   
   COMPONENT flash_if
      PORT ( clock                : IN  std_logic;
             reset                : IN  std_logic;
             msec_tick            : IN  std_logic;
             -- here the control interface is defined
             start_erase          : IN  std_logic;
             start_read           : IN  std_logic;
             start_write          : IN  std_logic;
             done                 : OUT std_logic;
             flash_present        : OUT std_logic;
             flash_s1_empty       : OUT std_logic;
             flash_idle           : OUT std_logic;
             size_error           : OUT std_logic;
             flash_n_busy         : OUT std_logic;
             start_config         : OUT std_logic;
             -- here the push fifo interface is defined
             push                 : OUT std_logic;
             push_data            : OUT std_logic_vector( 7 DOWNTO 0 );
             push_size            : OUT std_logic;
             push_last            : OUT std_logic;
             fifo_full            : IN  std_logic;
             -- here the write fifo is defined
             bitfile_size         : IN  std_logic_vector( 31 DOWNTO 0 );
             we_fifo              : IN  std_logic;
             we_data              : IN  std_logic_vector(  7 DOWNTO 0 );
             we_last              : IN  std_logic;
             we_fifo_full         : OUT std_logic;
             -- Here the scpi interface is defined
             start_command        : IN  std_logic;
             command_id           : IN  std_logic_vector( 6 DOWNTO 0 );
             scpi_pop             : OUT std_logic;
             scpi_pop_data        : IN  std_logic_vector( 7 DOWNTO 0 );
             scpi_pop_last        : IN  std_logic;
             scpi_empty           : IN  std_logic;
             scpi_push            : OUT std_logic;
             scpi_push_data       : OUT std_logic_vector( 7 DOWNTO 0 );
             scpi_push_size       : OUT std_logic;
             scpi_full            : IN  std_logic;
             -- Here the vga interface is defined
             we_char              : OUT std_logic;
             we_ascii             : OUT std_logic_vector(  7 DOWNTO 0 );
             we_addr              : OUT std_logic_vector( 10 DOWNTO 0 );
             -- define the flash interface
             flash_address        : OUT std_logic_vector( 19 DOWNTO 0 );
             flash_data_in        : IN  std_logic_vector( 15 DOWNTO 0 );
             flash_data_out       : OUT std_logic_vector( 15 DOWNTO 0 );
             flash_data_oe        : OUT std_logic_vector( 15 DOWNTO 0 );
             flash_n_byte         : OUT std_logic;
             flash_n_ce           : OUT std_logic;
             flash_n_oe           : OUT std_logic;
             flash_n_we           : OUT std_logic;
             flash_ready_n_busy   : IN  std_logic);
   END COMPONENT;
   
   COMPONENT cmd_18_1e_if
      PORT ( clock           : IN  std_logic;
             reset           : IN  std_logic;
             -- Here the scpi interface is defined
             start_command   : IN  std_logic;
             command_id      : IN  std_logic_vector( 6 DOWNTO 0 );
             command_done    : OUT std_logic;
             -- Here the tx_fifo is defined
             push            : OUT std_logic;
             push_size       : OUT std_logic;
             push_data       : OUT std_logic_vector( 7 DOWNTO 0 );
             fifo_full       : IN  std_logic;
             -- Here the fpga_if is defined
             fpga_type       : IN  std_logic_vector( 2 DOWNTO 0 );
             fpga_configured : IN  std_logic;
             flash_empty     : IN  std_logic;
             -- Here the board interface is defined
             n_usb_power     : IN  std_logic;
             n_bus_power     : IN  std_logic;
             n_usb_charge    : IN  std_logic);
   END COMPONENT;
   
   COMPONENT reset_if
      PORT ( clock          : IN  std_logic;
             reset          : IN  std_logic;
             msec_tick      : IN  std_logic;
             -- Here the fpga_interface is defined
             fpga_configured: IN  std_logic;
             -- Here the scpi interface is defined
             start_command  : IN  std_logic;
             command_id     : IN  std_logic_vector( 6 DOWNTO 0 );
             command_done   : OUT std_logic;
             -- Here the system reset is defined
             n_reset_system : OUT std_logic;
             user_n_reset   : OUT std_logic);
   END COMPONENT;
   
   COMPONENT hexswitch
      PORT ( clock         : IN  std_logic;
             reset         : IN  std_logic;
             n_hex_sw      : IN  std_logic_vector( 3 DOWNTO 0 );
             hex_value     : OUT std_logic_vector( 3 DOWNTO 0 );
             -- here the scpi interface is defined
             start         : IN  std_logic;
             command       : IN  std_logic_vector( 6 DOWNTO 0 );
             command_error : OUT std_logic;
             done          : OUT std_logic;
             pop           : OUT std_logic;
             pop_data      : IN  std_logic_vector( 7 DOWNTO 0 );
             pop_last      : IN  std_logic;
             pop_empty     : IN  std_logic;
             push          : OUT std_logic;
             push_data     : OUT std_logic_vector( 7 DOWNTO 0 );
             push_size     : OUT std_logic;
             push_full     : IN  std_logic );
   END COMPONENT;
   
   COMPONENT config_if
      PORT ( clock                  : IN  std_logic;
             reset                  : IN  std_logic;
             -- here the flash interface is defined
             start_config           : IN  std_logic;
             flash_start_read       : OUT std_logic;
             flash_done             : IN  std_logic;
             flash_present          : IN  std_logic;
             flash_s1_empty         : IN  std_logic;
             flash_idle             : IN  std_logic;
             flash_push             : IN  std_logic;
             flash_push_data        : IN  std_logic_vector( 7 DOWNTO 0 );
             flash_push_size        : IN  std_logic;
             flash_push_last        : IN  std_logic;
             flash_fifo_full        : OUT std_logic;
             -- here the flash usbtmc interface is defined
             flash_u_start_read     : IN  std_logic;
             flash_u_done           : OUT std_logic;
             flash_u_push           : OUT std_logic;
             flash_u_push_data      : OUT std_logic_vector( 7 DOWNTO 0 );
             flash_u_push_size      : OUT std_logic;
             flash_u_fifo_full      : IN  std_logic;
             -- here the bitfile interface is defined
             bitfile_start          : OUT std_logic;
             bitfile_pop            : IN  std_logic;
             bitfile_pop_data       : OUT std_logic_vector( 7 DOWNTO 0 );
             bitfile_last           : OUT std_logic;
             bitfile_fifo_empty     : OUT std_logic;
             -- here the bitfile usbtmc interface is defined
             bitfile_u_start        : IN  std_logic;
             bitfile_u_pop          : OUT std_logic;
             bitfile_u_pop_data     : IN  std_logic_vector( 7 DOWNTO 0 );
             bitfile_u_last         : IN  std_logic;
             bitfile_u_fifo_empty   : IN  std_logic;
             -- here the fpga interface is defined
             fpga_idle              : IN  std_logic;
             fpga_type              : IN  std_logic_vector( 2 DOWNTO 0 );
             -- here the power interface is defined
             n_bus_power            : IN  std_logic;
             -- here the scpi interface is defined
             start_command          : IN  std_logic;
             command_id             : IN  std_logic_vector( 6 DOWNTO 0 );
             command_error          : OUT std_logic );
   END COMPONENT;
   
   COMPONENT status_controller
      PORT ( clock           : IN  std_logic;
             reset           : IN  std_logic;
             fpga_configured : IN  std_logic;
             -- Here the fx2 interface is defined
             status_nibble   : OUT std_logic_vector( 3 DOWNTO 0 );
             -- Here the external status if is defined
             ESB_bit         : IN  std_logic;
             STATUS3_bit     : IN  std_logic;
             -- Here the scpi interface is defined
             start           : IN  std_logic;
             command         : IN  std_logic_vector( 6 DOWNTO 0 );
             cmd_error       : OUT std_logic;
             command_error   : IN  std_logic;
             execution_error : IN  std_logic;
             done            : OUT std_logic;
             transparent     : OUT std_logic;
             pop             : OUT std_logic;
             pop_data        : IN  std_logic_vector( 7 DOWNTO 0 );
             pop_last        : IN  std_logic;
             pop_empty       : IN  std_logic;
             push            : OUT std_logic;
             push_data       : OUT std_logic_vector( 7 DOWNTO 0 );
             push_size       : OUT std_logic;
             push_full       : IN  std_logic;
             push_empty      : IN  std_logic );
   END COMPONENT;
   
   COMPONENT bus_if
      PORT ( clock                    : IN    std_logic;
             reset                    : IN    std_logic;
             -- Here the IOB interface is defined
             bus_reset                : IN    std_logic;
             bus_n_start_transmission : IN    std_logic;
             bus_n_end_transmission   : INOUT std_logic;
             bus_n_data_valid         : INOUT std_logic_vector( 1 DOWNTO 0 );
             bus_data_addr_cntrl      : INOUT std_logic_vector(15 DOWNTO 0 );
             bus_n_start_send         : OUT   std_logic;
             bus_n_error              : OUT   std_logic;
             -- Here the FPGA internal interface is defined
             b_n_reset                : OUT   std_logic;
             b_n_start_transmission   : OUT   std_logic;
             b_n_end_transmission_out : OUT   std_logic;
             b_n_end_transmission_in  : IN    std_logic;
             b_n_data_valid_out       : OUT   std_logic_vector( 1 DOWNTO 0 );
             b_n_data_valid_in        : IN    std_logic_vector( 1 DOWNTO 0 );
             data_out                 : OUT   std_logic_vector(15 DOWNTO 0 );
             data_in                  : IN    std_logic_vector(15 DOWNTO 0 );
             read_n_write             : OUT   std_logic;
             burst_size               : OUT   std_logic_vector( 8 DOWNTO 0 );
             address                  : OUT   std_logic_vector( 5 DOWNTO 0 );
             n_start_send             : IN    std_logic;
             n_bus_error              : IN    std_logic);
   END COMPONENT;
   
   COMPONENT vga_bus
      PORT ( clock                  : IN  std_logic;
             reset                  : IN  std_logic;
             msec_tick              : IN  std_logic;
             -- Here the bus signals are defined
             n_bus_reset            : IN  std_logic;
             n_start_transmission   : IN  std_logic;
             n_end_transmission_in  : IN  std_logic;
             n_end_transmission_out : OUT std_logic;
             n_data_valid_in        : IN  std_logic; -- Only for low byte!
             n_data_valid_out       : OUT std_logic_vector( 1 DOWNTO 0 );
             data_in                : IN  std_logic_vector( 7 DOWNTO 0 );
             data_out               : OUT std_logic_vector(15 DOWNTO 0 );
             read_n_write           : IN  std_logic;
             burst_size             : IN  std_logic_vector( 8 DOWNTO 0 );
             bus_address            : IN  std_logic_vector( 5 DOWNTO 0 );
             n_start_send           : OUT std_logic;
             n_bus_error            : OUT std_logic;
             -- Here the button interface is defined
             n_button_1             : IN  std_logic;
             n_button_2             : IN  std_logic;
             n_button_3             : IN  std_logic;
             hexswitch              : IN  std_logic_vector( 3 DOWNTO 0 );
             -- Here the LED interface is defined
             leds_a                 : OUT std_logic_vector( 7 DOWNTO 0 );
             leds_k                 : OUT std_logic_vector( 7 DOWNTO 0 );
             -- Here the VGA interface is defined
             cursor_pos             : OUT std_logic_vector( 10 DOWNTO 0 );
             screen_offset          : OUT std_logic_vector(  4 DOWNTO 0 );
             fg_color               : OUT std_logic_vector(  2 DOWNTO 0 );
             bg_color               : OUT std_logic_vector(  2 DOWNTO 0 );
             write_address          : OUT std_logic_vector( 10 DOWNTO 0 );
             ascii_data             : OUT std_logic_vector(  7 DOWNTO 0 );
             we                     : OUT std_logic);
   END COMPONENT;
   
   COMPONENT user_fifo
      PORT ( clock                  : IN  std_logic;
             reset                  : IN  std_logic;
             -- Here the bus signals are defined
             n_bus_reset            : IN  std_logic;
             n_start_transmission   : IN  std_logic;
             n_end_transmission_in  : IN  std_logic;
             n_end_transmission_out : OUT std_logic;
             n_data_valid_in        : IN  std_logic_vector( 1 DOWNTO 0 );
             n_data_valid_out       : OUT std_logic_vector( 1 DOWNTO 0 );
             data_in                : IN  std_logic_vector(15 DOWNTO 0 );
             data_out               : OUT std_logic_vector(15 DOWNTO 0 );
             read_n_write           : IN  std_logic;
             burst_size             : IN  std_logic_vector( 8 DOWNTO 0 );
             bus_address            : IN  std_logic_vector( 5 DOWNTO 0 );
             n_start_send           : OUT std_logic;
             n_bus_error            : OUT std_logic;
             -- Here the scpi interface is defined
             start_command          : IN  std_logic;
             command_id             : IN  std_logic_vector( 6 DOWNTO 0 );
             transparent_mode       : IN  std_logic;
             command_done           : OUT std_logic;
             command_error          : OUT std_logic;
             message_available      : OUT std_logic;
             -- Here the tx_fifo is defined
             push                   : OUT std_logic;
             push_size              : OUT std_logic;
             push_data              : OUT std_logic_vector( 7 DOWNTO 0 );
             fifo_full              : IN  std_logic;
             -- Here the rx_fifo is defined
             pop                    : OUT std_logic;
             pop_last               : IN  std_logic;
             pop_data               : IN  std_logic_vector( 7 DOWNTO 0 );
             pop_empty              : IN  std_logic;
             -- Here the big fpga interface is defined
             data_request_irq       : OUT std_logic;
             data_available_irq     : OUT std_logic;
             error_irq              : OUT std_logic);
   END COMPONENT;
   
   COMPONENT DFF
      PORT ( clock  : IN  std_logic;
             D      : IN  std_logic;
             Q      : OUT std_logic );
   END COMPONENT;

   COMPONENT FDE
      PORT ( Q   : OUT std_logic;
             CE  : IN  std_logic;
             C   : IN  std_logic;
             D   : IN  std_logic );
   END COMPONENT;

   COMPONENT FD
      PORT ( Q   : OUT std_logic;
             C   : IN  std_logic;
             D   : IN  std_logic );
   END COMPONENT;

   SIGNAL s_clock_75MHz                : std_logic;
   SIGNAL s_clock_96MHz                : std_logic;
   SIGNAL s_reset                      : std_logic;
   SIGNAL s_vga_red                    : std_logic;
   SIGNAL s_vga_green                  : std_logic;
   SIGNAL s_vga_blue                   : std_logic;
   SIGNAL s_vga_hsync                  : std_logic;
   SIGNAL s_vga_vsync                  : std_logic;
   SIGNAL s_usb_clk                    : std_logic;
   SIGNAL s_n_usb_clk                  : std_logic;
   SIGNAL s_clk_48MHz                  : std_logic;
   SIGNAL s_msec_tick                  : std_logic;
   SIGNAL s_usb_reset                  : std_logic;

   SIGNAL s_SDA                        : std_logic;
   SIGNAL s_SDA_pin                    : std_logic;
   SIGNAL s_SDA_OE                     : std_logic;
   
   SIGNAL s_wf_push                    : std_logic;
   SIGNAL s_wf_push_data               : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_wf_push_size_bit           : std_logic;
   SIGNAL s_wf_fifo_full               : std_logic;
   SIGNAL s_wf_fifo_empty              : std_logic;
   SIGNAL s_fx2_data                   : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_fx2_n_tri                  : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_start_scpi_command         : std_logic;
   SIGNAL s_scpi_command_id            : std_logic_vector(  6 DOWNTO 0 );
   SIGNAL s_scpi_command_done          : std_logic;
   SIGNAL s_cmd_09_done                : std_logic;
   SIGNAL s_cmd_09_push                : std_logic;
   SIGNAL s_cmd_09_push_data           : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_cmd_09_push_size           : std_logic;
   SIGNAL s_cmd_25_done                : std_logic;
   SIGNAL s_pending_message            : std_logic;
   
   SIGNAL s_leds_a                     : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_leds_k                     : std_logic_vector(  7 DOWNTO 0 );

   SIGNAL s_fifo_data                  : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_fifo_empty                 : std_logic;
   SIGNAL s_fifo_pop                   : std_logic;
   SIGNAL s_fifo_last                  : std_logic;
   
   SIGNAL s_fpga_revision              : std_logic_vector(  3 DOWNTO 0 );
   SIGNAL s_fpga_type                  : std_logic_vector(  2 DOWNTO 0 );
   SIGNAL s_fpga_configured            : std_logic;
   SIGNAL s_reset_fpga_if              : std_logic;
   SIGNAL s_fpga_data_in_ena           : std_logic;
   SIGNAL s_fpga_data_out_ena          : std_logic;
   SIGNAL s_fpga_data_in               : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_fpga_data_out              : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_fpga_n_tri                 : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_fpga_data_out_reg          : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_fpga_n_tri_reg             : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_fpga_crc_error             : std_logic;
   
   SIGNAL s_fpga_fifo_push             : std_logic;
   SIGNAL s_fpga_fifo_push_data        : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_fpga_fifo_last_byte        : std_logic;
   SIGNAL s_fpga_fifo_full             : std_logic;
   SIGNAL s_fpga_idle                  : std_logic;
   
   SIGNAL s_bitfile_pop                : std_logic;
   SIGNAL s_bitfile_u_pop              : std_logic;
   SIGNAL s_bitfile_done               : std_logic;
   SIGNAL s_bitfile_start              : std_logic;
   SIGNAL s_bitfile_u_start            : std_logic;
   SIGNAL s_bitfile_pop_data           : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_bitfile_last               : std_logic;
   SIGNAL s_bitfile_fifo_empty         : std_logic;
   
   SIGNAL s_bitfile_error              : std_logic;

   SIGNAL s_bitfile_size               : std_logic_vector(31 DOWNTO 0 );
   SIGNAL s_we_fifo                    : std_logic;
   SIGNAL s_we_data                    : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_we_last                    : std_logic;
   SIGNAL s_we_fifo_full               : std_logic;
   SIGNAL s_start_write                : std_logic;
   SIGNAL s_flash_data_out             : std_logic_vector(15 DOWNTO 0 );
   SIGNAL s_flash_data_oe              : std_logic_vector(15 DOWNTO 0 );
   
   SIGNAL s_start_erase                : std_logic;
   SIGNAL s_start_read                 : std_logic;
   SIGNAL s_start_flash_read           : std_logic;
   SIGNAL s_prog_flash                 : std_logic;
   SIGNAL s_flash_present              : std_logic;
   SIGNAL s_flash_s1_empty             : std_logic;
   SIGNAL s_flash_idle                 : std_logic;
   SIGNAL s_flash_n_busy               : std_logic;
   SIGNAL s_size_error                 : std_logic;
   SIGNAL s_flash_push                 : std_logic;
   SIGNAL s_flash_push_data            : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_flash_push_size            : std_logic;
   SIGNAL s_flash_push_last            : std_logic;
   SIGNAL s_flash_fifo_full            : std_logic;
   SIGNAL s_flash_u_push               : std_logic;
   SIGNAL s_flash_u_push_data          : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_flash_u_push_size          : std_logic;
   SIGNAL s_flash_done                 : std_logic;
   SIGNAL s_flash_u_done               : std_logic;
   
   SIGNAL s_cmd_18_1e_done             : std_logic;
   SIGNAL s_cmd_18_1e_push             : std_logic;
   SIGNAL s_cmd_18_1e_size             : std_logic;
   SIGNAL s_cmd_18_1e_data             : std_logic_vector( 7 DOWNTO 0 );
   
   SIGNAL s_system_reset_done          : std_logic;
   SIGNAL s_vga_command_done           : std_logic;
   SIGNAL s_vga_command_error          : std_logic;
   SIGNAL s_scpi_command_error         : std_logic;
   SIGNAL s_vga_pop                    : std_logic;
   SIGNAL s_custom_pop                 : std_logic;
   SIGNAL s_vga_push                   : std_logic;
   SIGNAL s_vga_push_data              : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_vga_push_size              : std_logic;
   SIGNAL s_config_error               : std_logic;
   SIGNAL s_pud_pop                    : std_logic;
   SIGNAL s_pud_push                   : std_logic;
   SIGNAL s_pud_push_data              : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_pud_push_size              : std_logic;
   SIGNAL s_hex_switch                 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_hex_error                  : std_logic;
   SIGNAL s_hex_done                   : std_logic;
   SIGNAL s_hex_pop                    : std_logic;
   SIGNAL s_hex_push                   : std_logic;
   SIGNAL s_hex_push_data              : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_hex_push_size              : std_logic;
   SIGNAL s_pud_we                     : std_logic;
   SIGNAL s_pud_data                   : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_pud_addr                   : std_logic_vector(10 DOWNTO 0 );
   SIGNAL s_status_error               : std_logic;
   SIGNAL s_status_done                : std_logic;
   SIGNAL s_trans_mode                 : std_logic;
   SIGNAL s_status_pop                 : std_logic;
   SIGNAL s_status_push                : std_logic;
   SIGNAL s_status_push_data           : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_status_push_size           : std_logic;
   SIGNAL s_unknown_command            : std_logic;
   
   SIGNAL s_status_nibble              : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_fx2_data_nibble            : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_indicator_pulse            : std_logic;

   SIGNAL s_b_n_reset                  : std_logic;
   SIGNAL s_b_n_start_transmission     : std_logic;
   SIGNAL s_b_n_end_transmission_out   : std_logic;
   SIGNAL s_b_n_end_transmission_in    : std_logic;
   SIGNAL s_b_n_data_valid_out         : std_logic_vector( 1 DOWNTO 0 );
   SIGNAL s_b_n_data_valid_in          : std_logic_vector( 1 DOWNTO 0 );
   SIGNAL s_b_data_out                 : std_logic_vector(15 DOWNTO 0 );
   SIGNAL s_b_data_in                  : std_logic_vector(15 DOWNTO 0 );
   SIGNAL s_b_read_n_write             : std_logic;
   SIGNAL s_b_burst_size               : std_logic_vector( 8 DOWNTO 0 );
   SIGNAL s_b_address                  : std_logic_vector( 5 DOWNTO 0 );
   SIGNAL s_b_n_start_send             : std_logic;
   SIGNAL s_b_n_bus_error              : std_logic;

   SIGNAL s_vga_cursor_pos             : std_logic_vector( 10 DOWNTO 0 );
   SIGNAL s_vga_screen_offset          : std_logic_vector(  4 DOWNTO 0 );
   SIGNAL s_vga_fg_color               : std_logic_vector(  2 DOWNTO 0 );
   SIGNAL s_vga_bg_color               : std_logic_vector(  2 DOWNTO 0 );
   SIGNAL s_vga_write_address          : std_logic_vector( 10 DOWNTO 0 );
   SIGNAL s_vga_ascii_data             : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_vga_we                     : std_logic;
   SIGNAL s_vga_n_end_transmission_out : std_logic;
   SIGNAL s_vga_n_data_valid_out       : std_logic_vector(  1 DOWNTO 0 );
   SIGNAL s_vga_data_out               : std_logic_vector( 15 DOWNTO 0 );
   SIGNAL s_vga_n_start_send           : std_logic;
   SIGNAL s_vga_n_bus_error            : std_logic;
   
   SIGNAL s_ufifo_push                 : std_logic;
   SIGNAL s_ufifo_push_size            : std_logic;
   SIGNAL s_ufifo_push_data            : std_logic_vector(  7 DOWNTO 0 );
   SIGNAL s_ufifo_error                : std_logic;
   SIGNAL s_ufifo_done                 : std_logic;
   SIGNAL s_ufifo_n_error              : std_logic;
   SIGNAL s_ufifo_n_start              : std_logic;
   SIGNAL s_ufifo_data                 : std_logic_vector( 15 DOWNTO 0 );
   SIGNAL s_ufifo_n_valid              : std_logic_vector(  1 DOWNTO 0 );
   SIGNAL s_ufifo_n_end                : std_logic;
   SIGNAL s_ufifo_pop                  : std_logic;
   SIGNAL s_ufifo_msg_avail            : std_logic;
   SIGNAL s_scpi_msg_avail             : std_logic;
   
   SIGNAL s_start_config               : std_logic;
   
BEGIN

-- Assign outputs
   gen_fx_data : FOR n IN 7 DOWNTO 0 GENERATE
      fx2_data(n) <= s_fx2_data(n) WHEN s_fx2_n_tri(n) = '0' ELSE 'Z';
   END GENERATE gen_fx_data;
   
   fx2_data_nibble <= s_fx2_data_nibble WHEN fx2_pa1 = '0' 
                                             AND s_b_n_data_valid_out(1) = '1' -- DUMMY: REMOVE AFTERWARDS!
                                             ELSE (OTHERS => 'Z');
   
   red           <= 'Z' WHEN jtag_ndet = '0' ELSE s_vga_red   ;
   green         <= 'Z' WHEN jtag_ndet = '0' ELSE s_vga_green ;
   blue          <= 'Z' WHEN jtag_ndet = '0' ELSE s_vga_blue  ;
   hsync         <= 'Z' WHEN jtag_ndet = '0' ELSE s_vga_hsync ;
   vsync         <= 'Z' WHEN jtag_ndet = '0' ELSE s_vga_vsync ;
   SDA           <= s_SDA_pin WHEN s_SDA_OE = '0' ELSE 'Z';
   fx2_n_int0    <= s_reset;
   RxD_out       <= RxD_in;
   TxD_out       <= 'Z' when jtag_ndet = '0' ELSE TxD_in ;
   scpi_disabled <= s_trans_mode;
   
-- Assign control signals
   s_n_usb_clk            <= NOT(s_usb_clk);
   s_bitfile_u_start      <= '1' WHEN s_start_scpi_command = '1' AND
                                      (s_scpi_command_id = "0011101" OR
                                       s_scpi_command_id = "0010110") ELSE '0';
   s_prog_flash           <= '1' WHEN s_scpi_command_id = "0010110" ELSE '0';
   s_start_erase          <= '1' WHEN s_start_scpi_command = '1' AND
                                      s_scpi_command_id = "0011010" ELSE '0';
   s_start_read           <= '1' WHEN s_start_scpi_command = '1' AND
                                      s_scpi_command_id = "0010111" ELSE '0';
                                      
   s_wf_push              <= s_flash_u_push OR s_cmd_09_push OR s_cmd_18_1e_push OR
                             s_vga_push OR s_pud_push OR s_hex_push OR
                             s_status_push OR s_ufifo_push;
   s_wf_push_data         <= s_flash_u_push_data OR s_cmd_09_push_data OR
                             s_cmd_18_1e_data OR s_vga_push_data OR 
                             s_pud_push_data OR s_hex_push_data OR
                             s_status_push_data OR s_ufifo_push_data;
   s_wf_push_size_bit     <= s_flash_u_push_size OR s_cmd_09_push_size OR
                             s_cmd_18_1e_size OR s_vga_push_size OR
                             s_pud_push_size OR s_hex_push_size OR
                             s_status_push_size OR s_ufifo_push_size;

   s_scpi_command_done    <= s_cmd_09_done OR s_cmd_25_done OR s_bitfile_done OR
                             s_flash_u_done OR s_cmd_18_1e_done OR s_hex_done OR
                             s_system_reset_done OR s_vga_command_done OR
                             s_status_done OR s_ufifo_done;
   s_scpi_command_error   <= s_vga_command_error OR s_bitfile_error OR
                             s_config_error OR s_hex_error OR s_status_error OR
                             s_ufifo_error OR s_size_error;
   s_custom_pop           <= s_vga_pop OR s_bitfile_u_pop OR s_pud_pop OR
                             s_hex_pop OR s_status_pop OR s_ufifo_pop;
   
-- Map components
   clockgen : clocks
              PORT MAP ( system_n_reset    => n_reset_system,
                         clock_25MHz       => clock_25MHz,
                         clock_16MHz       => clock_16MHz,
                         user_clock_1      => user_clock_1_in,
                         user_clock_2      => user_clock_2_in,
                         -- Here the compensated clocks are defined
                         user_clock_1_out  => user_clock_1_out,
                         user_clock_1_fb   => user_clock_1_fb,
                         user_clock_1_lock => user_clock_1_lock,
                         user_clock_2_out  => user_clock_2_out,
                         user_clock_2_fb   => user_clock_2_fb,
                         user_clock_2_lock => user_clock_2_lock,
                         -- Here the master clocks are defined
                         clock_25MHz_out   => clock_25MHz_out,
                         clock_48MHz_out   => clock_48MHz_out,
                         -- Here the FPGA internal clocks are defined
                         clk_48MHz         => s_clk_48MHz,
                         clk_96MHz         => s_clock_96MHz,
                         clk_75MHz         => s_clock_75MHz,
                         reset_out         => s_reset,
                         msec_tick         => s_msec_tick );

   usb_dff_1 : DFF
               PORT MAP ( clock => s_clk_48MHz,
                          D     => s_n_usb_clk,
                          Q     => s_usb_clk );
   usb_dff_2 : DFF
               PORT MAP ( clock => s_clk_48MHz,
                          D     => s_usb_clk,
                          Q     => fx2_clk );
                          
   SDA_ff : DFF
            PORT MAP ( clock => clock_16MHz,
                       D     => s_SDA,
                       Q     => s_SDA_pin );
   SDA_oe_ff : DFF
               PORT MAP ( clock => clock_16MHz,
                          D     => s_SDA,
                          Q     => s_SDA_OE );

   i2c : eeprom_emu
         PORT MAP ( clock     => clock_16MHz,
                    reset     => s_reset,
                    button    => button3,
                    SDA_in    => SDA,
                    SCL_in    => SCL,
                    SDA_out   => s_SDA );
                    
   
   s_b_n_end_transmission_in <= s_vga_n_end_transmission_out AND s_ufifo_n_end;
   s_b_n_data_valid_in       <= s_vga_n_data_valid_out AND s_ufifo_n_valid;
   s_b_data_in               <= s_vga_data_out OR s_ufifo_data;
   s_b_n_start_send          <= s_vga_n_start_send AND s_ufifo_n_start;
   s_b_n_bus_error           <= s_vga_n_bus_error AND s_ufifo_n_error;
   
   the_bus : bus_if
             PORT MAP ( clock                    => s_clk_48MHz,
                        reset                    => s_reset,
                        -- Here the IOB interface is defined
                        bus_reset                => bus_reset               ,
                        bus_n_start_transmission => bus_n_start_transmission,
                        bus_n_end_transmission   => bus_n_end_transmission  ,
                        bus_n_data_valid         => bus_n_data_valid        ,
                        bus_data_addr_cntrl      => bus_data_addr_cntrl     ,
                        bus_n_start_send         => bus_n_start_send        ,
                        bus_n_error              => bus_n_error             ,
                        -- Here the FPGA internal interface is defined
                        b_n_reset                => s_b_n_reset               ,
                        b_n_start_transmission   => s_b_n_start_transmission  ,
                        b_n_end_transmission_out => s_b_n_end_transmission_out,
                        b_n_end_transmission_in  => s_b_n_end_transmission_in ,
                        b_n_data_valid_out       => s_b_n_data_valid_out      ,
                        b_n_data_valid_in        => s_b_n_data_valid_in       ,
                        data_out                 => s_b_data_out              ,
                        data_in                  => s_b_data_in               ,
                        read_n_write             => s_b_read_n_write          ,
                        burst_size               => s_b_burst_size            ,
                        address                  => s_b_address               ,
                        n_start_send             => s_b_n_start_send          ,
                        n_bus_error              => s_b_n_bus_error           );
   fifo_if : user_fifo
             PORT MAP ( clock                  => s_clk_48MHz,
                        reset                  => s_usb_reset,
                        -- Here the bus signals are defined
                        n_bus_reset            => s_b_n_reset,
                        n_start_transmission   => s_b_n_start_transmission,
                        n_end_transmission_in  => s_b_n_end_transmission_out,
                        n_end_transmission_out => s_ufifo_n_end,
                        n_data_valid_in        => s_b_n_data_valid_out,
                        n_data_valid_out       => s_ufifo_n_valid,
                        data_in                => s_b_data_out,
                        data_out               => s_ufifo_data,
                        read_n_write           => s_b_read_n_write,
                        burst_size             => s_b_burst_size,
                        bus_address            => s_b_address,
                        n_start_send           => s_ufifo_n_start,
                        n_bus_error            => s_ufifo_n_error,
                        -- Here the scpi interface is defined
                        start_command          => s_start_scpi_command,
                        command_id             => s_scpi_command_id,
                        transparent_mode       => s_trans_mode,
                        command_done           => s_ufifo_done,
                        command_error          => s_ufifo_error,
                        message_available      => s_ufifo_msg_avail,
                        -- Here the tx_fifo is defined
                        push                   => s_ufifo_push,
                        push_size              => s_ufifo_push_size,
                        push_data              => s_ufifo_push_data,
                        fifo_full              => s_wf_fifo_full,
                        -- Here the rx_fifo is defined
                        pop                    => s_ufifo_pop,
                        pop_last               => s_fifo_last,
                        pop_data               => s_fifo_data,
                        pop_empty              => s_fifo_empty,
                        -- Here the big fpga interface is defined
                        data_request_irq       => data_request_irq,
                        data_available_irq     => data_available_irq,
                        error_irq              => error_irq);

   vga_bus_if : vga_bus
                PORT MAP ( clock                  => s_clk_48MHz,
                           reset                  => s_reset,
                           msec_tick              => s_msec_tick,
                           -- Here the bus signals are defined
                           n_bus_reset            => s_b_n_reset,
                           n_start_transmission   => s_b_n_start_transmission,
                           n_end_transmission_in  => s_b_n_end_transmission_out,
                           n_end_transmission_out => s_vga_n_end_transmission_out,
                           n_data_valid_in        => s_b_n_data_valid_out(0),
                           n_data_valid_out       => s_vga_n_data_valid_out,
                           data_in                => s_b_data_out( 7 DOWNTO 0 ),
                           data_out               => s_vga_data_out,
                           read_n_write           => s_b_read_n_write,
                           burst_size             => s_b_burst_size,
                           bus_address            => s_b_address,
                           n_start_send           => s_vga_n_start_send,
                           n_bus_error            => s_vga_n_bus_error,
                           -- Here the button interface is defined
                           n_button_1             => button1,
                           n_button_2             => button2,
                           n_button_3             => button3,
                           hexswitch              => s_hex_switch,
                           -- Here the LED interface is defined
                           leds_a                 => s_leds_a,
                           leds_k                 => s_leds_k,
                           -- Here the VGA interface is defined
                           cursor_pos             => s_vga_cursor_pos   ,
                           screen_offset          => s_vga_screen_offset,
                           fg_color               => s_vga_fg_color     ,
                           bg_color               => s_vga_bg_color     ,
                           write_address          => s_vga_write_address,
                           ascii_data             => s_vga_ascii_data   ,
                           we                     => s_vga_we           );

   
   status : status_controller
            PORT MAP ( clock           => s_clk_48MHz,
                       reset           => s_usb_reset,
                       fpga_configured => s_fpga_configured,
                       -- Here the fx2 interface is defined
                       status_nibble   => s_status_nibble,
                       -- Here the external status if is defined
                       ESB_bit         => ESB_bit,
                       STATUS3_bit     => STATUS3_bit,
                       -- Here the scpi interface is defined
                       start           => s_start_scpi_command,
                       command         => s_scpi_command_id,
                       cmd_error       => s_status_error,
                       command_error   => s_unknown_command,
                       execution_error => s_scpi_command_error,
                       done            => s_status_done,
                       transparent     => s_trans_mode,
                       pop             => s_status_pop,
                       pop_data        => s_fifo_data,
                       pop_last        => s_fifo_last,
                       pop_empty       => s_fifo_empty,
                       push            => s_status_push,
                       push_data       => s_status_push_data,
                       push_size       => s_status_push_size,
                       push_full       => s_wf_fifo_full,
                       push_empty      => s_wf_fifo_empty );

   s_pending_message <= s_ufifo_msg_avail OR s_scpi_msg_avail;
   fx2 : USBTMC
         PORT MAP ( clock_96MHz      => s_clock_96MHz,
                    clock_48MHz      => s_clk_48MHz,
                    cpu_reset        => s_reset,
                    sync_reset_out   => s_usb_reset,
                    -- SCPI command interpretor interface
                    pending_message  => s_pending_message,
                    transfer_in_prog => OPEN,
                    -- FX2 control interface
                    FX2_n_ready      => fx2_pa1,
                    FX2_hi_speed     => fx2_pa3,
                    -- read fifo interface
                    rf_pop           => s_fifo_pop,
                    rf_pop_data      => s_fifo_data,
                    rf_last_data_byte=> s_fifo_last,
                    rf_fifo_empty    => s_fifo_empty,
                    -- Write fifo interface
                    wf_push          => s_wf_push         ,
                    wf_push_data     => s_wf_push_data    ,
                    wf_push_size_bit => s_wf_push_size_bit,
                    wf_fifo_full     => s_wf_fifo_full    ,
                    wf_fifo_empty    => s_wf_fifo_empty   ,
                    -- status interface
                    status_nibble    => s_status_nibble,
                    indicator_pulse  => s_indicator_pulse,
                    -- FX2 port D interface
                    data_nibble      => s_fx2_data_nibble,
                    data_select      => fx2_data_select,
                    -- FX2 FIFO interface
                    EP8_n_empty      => fx2_flaga,
                    EP6_n_full       => fx2_flagb,
                    EP_data_in       => fx2_data,
                    EP_address       => fx2_fifo_addr,
                    EP_IFCLOCK       => fx2_ifclock,
                    EP_n_PKTEND      => fx2_n_pkt_end,
                    EP_n_OE          => fx2_n_oe,
                    EP_n_RE          => fx2_n_re,
                    EP_n_WE          => fx2_n_we,
                    EP_data_out      => s_fx2_data,
                    EP_n_tri_out     => s_fx2_n_tri);

   vga : vga_controller
         PORT MAP ( clock_75MHz         => s_clock_75MHz,
                    reset               => s_reset,
                    vga_off             => s_reset,
                    clock               => s_clk_48MHz,
                    -- Here the scpi interface is defined
                    start_command       => s_start_scpi_command,
                    command_id          => s_scpi_command_id,
                    command_done        => s_vga_command_done,
                    command_error       => s_vga_command_error,
                    -- Here the usbtmc fifo interface is defined
                    pop                 => s_vga_pop,
                    pop_data            => s_fifo_data,
                    pop_last            => s_fifo_last,
                    pop_empty           => s_fifo_empty,
                    push                => s_vga_push,
                    push_data           => s_vga_push_data,
                    push_size           => s_vga_push_size,
                    push_full           => s_wf_fifo_full,
                    -- Here the PUD interface is defined
                    we_char             => s_pud_we,
                    we_ascii            => s_pud_data,
                    we_addr             => s_pud_addr,
                    -- Here the fpga interface is defined
                    cursor_pos          => s_vga_cursor_pos   ,
                    screen_offset       => s_vga_screen_offset,
                    fg_color            => s_vga_fg_color     ,
                    bg_color            => s_vga_bg_color     ,
                    write_address       => s_vga_write_address,
                    ascii_data          => s_vga_ascii_data   ,
                    we                  => s_vga_we           ,
                    vga_red             => s_vga_red   ,
                    vga_green           => s_vga_green ,
                    vga_blue            => s_vga_blue  ,
                    vga_hsync           => s_vga_hsync ,
                    vga_vsync           => s_vga_vsync );

   scpi : SCPI_INTERFACE
          PORT MAP ( clock            => s_clk_48MHz,
                     reset            => s_usb_reset,
                     -- The command interface
                     transparent_mode => s_trans_mode,
                     start_command    => s_start_scpi_command,
                     command_id       => s_scpi_command_id,
                     cmd_gen_respons  => s_scpi_msg_avail,
                     command_done     => s_scpi_command_done,
                     command_error    => s_scpi_command_error,
                     unknown_command  => s_unknown_command,
                     slave_pop        => s_custom_pop,
                     -- USBTMC fifo interface
                     pop              => s_fifo_pop,
                     pop_data         => s_fifo_data,
                     pop_empty        => s_fifo_empty,
                     pop_last         => s_fifo_last);

   cmd_18_1e : cmd_18_1e_if
               PORT MAP ( clock           => s_clk_48MHz,
                          reset           => s_usb_reset,
                          -- Here the scpi interface is defined
                          start_command   => s_start_scpi_command,
                          command_id      => s_scpi_command_id,
                          command_done    => s_cmd_18_1e_done,
                          -- Here the tx_fifo is defined
                          push            => s_cmd_18_1e_push,
                          push_size       => s_cmd_18_1e_size,
                          push_data       => s_cmd_18_1e_data,
                          fifo_full       => s_wf_fifo_full,
                          -- Here the fpga_if is defined
                          fpga_type       => s_fpga_type,
                          fpga_configured => s_fpga_configured,
                          flash_empty     => s_flash_s1_empty,
                          -- Here the board interface is defined
                          n_usb_power     => n_usb_power,
                          n_bus_power     => n_bus_power,
                          n_usb_charge    => n_usb_charge);
   
   cmd_09 : IDN_handler
            PORT MAP ( clock     => s_clk_48MHz,
                       reset     => s_usb_reset,
                       start     => s_start_scpi_command,
                       command   => s_scpi_command_id,
                       fifo_full => s_wf_fifo_full,
                       done      => s_cmd_09_done,
                       push      => s_cmd_09_push,
                       size_bit  => s_cmd_09_push_size,
                       push_data => s_cmd_09_push_data );
   cmd_25 : identify_handler
            PORT MAP ( clock       => s_clk_48MHz,
                       reset       => s_reset,
                       start       => s_start_scpi_command,
                       command     => s_scpi_command_id,
                       indicator   => s_indicator_pulse,
                       done        => s_cmd_25_done,
                       flash_idle  => s_flash_n_busy,
                       msec_tick   => s_msec_tick,
                       leds_a_in   => s_leds_a,
                       leds_k_in   => s_leds_k,
                       leds_a      => leds_a,
                       leds_k      => leds_k);
   cmd_23_24 : hexswitch
               PORT MAP ( clock         => s_clk_48MHz,
                          reset         => s_usb_reset,
                          n_hex_sw      => n_hex_switch,
                          hex_value     => s_hex_switch,
                          -- here the scpi interface is defined
                          start         => s_start_scpi_command,
                          command       => s_scpi_command_id,
                          command_error => s_hex_error,
                          done          => s_hex_done,
                          pop           => s_hex_pop,
                          pop_data      => s_fifo_data,
                          pop_last      => s_fifo_last,
                          pop_empty     => s_fifo_empty,
                          push          => s_hex_push,
                          push_data     => s_hex_push_data,
                          push_size     => s_hex_push_size,
                          push_full     => s_wf_fifo_full );


   system_reset : reset_if
                  PORT MAP ( clock          => s_clk_48MHz,
                             reset          => s_reset,
                             msec_tick      => s_msec_tick,
                             -- Here the fpga_interface is defined
                             fpga_configured=> s_fpga_configured,
                             -- Here the scpi interface is defined
                             start_command  => s_start_scpi_command,
                             command_id     => s_scpi_command_id,
                             command_done   => s_system_reset_done,
                             -- Here the system reset is defined
                             n_reset_system => n_reset_system,
                             user_n_reset   => user_n_reset );


--------------------------------------------------------------------------------
--- Here the FPGA interface is defined                                       ---
--- NOTE: The FPGA data pins have dual function; however the configuration   ---
---       Interface MUST have priority                                       ---
--------------------------------------------------------------------------------
   config : config_if
            PORT MAP ( clock                  => s_clk_48MHz,
                       reset                  => s_reset_fpga_if,
                       -- here the flash interface is defined
                       start_config           => s_start_config,
                       flash_start_read       => s_start_flash_read,
                       flash_done             => s_flash_done,
                       flash_present          => s_flash_present,
                       flash_s1_empty         => s_flash_s1_empty,
                       flash_idle             => s_flash_idle,
                       flash_push             => s_flash_push,
                       flash_push_data        => s_flash_push_data,
                       flash_push_size        => s_flash_push_size,
                       flash_push_last        => s_flash_push_last,
                       flash_fifo_full        => s_flash_fifo_full,
                       -- here the flash usbtmc interface is defined
                       flash_u_start_read     => s_start_read,
                       flash_u_done           => s_flash_u_done,
                       flash_u_push           => s_flash_u_push,
                       flash_u_push_data      => s_flash_u_push_data,
                       flash_u_push_size      => s_flash_u_push_size,
                       flash_u_fifo_full      => s_wf_fifo_full,
                       -- here the bitfile interface is defined
                       bitfile_start          => s_bitfile_start,
                       bitfile_pop            => s_bitfile_pop,
                       bitfile_pop_data       => s_bitfile_pop_data,
                       bitfile_last           => s_bitfile_last,
                       bitfile_fifo_empty     => s_bitfile_fifo_empty,
                       -- here the bitfile usbtmc interface is defined
                       bitfile_u_start        => s_bitfile_u_start,
                       bitfile_u_pop          => s_bitfile_u_pop,
                       bitfile_u_pop_data     => s_fifo_data,
                       bitfile_u_last         => s_fifo_last,
                       bitfile_u_fifo_empty   => s_fifo_empty,
                       -- here the fpga interface is defined
                       fpga_idle              => s_fpga_idle,
                       fpga_type              => s_fpga_type,
                       -- here the power interface is defined
                       n_bus_power            => n_bus_power,
                       -- here the scpi interface is defined
                       start_command          => s_start_scpi_command,
                       command_id             => s_scpi_command_id,
                       command_error          => s_config_error );


   fpga : fpga_if
          PORT MAP ( clock             => s_clk_48MHz,
                     reset             => s_reset_fpga_if,
                     -- Here the FPGA info is provided
                     fpga_idle         => s_fpga_idle,
                     fpga_revision     => s_fpga_revision,
                     fpga_type         => s_fpga_type,
                     fpga_configured   => s_fpga_configured,
                     fpga_crc_error    => s_fpga_crc_error,
                     -- Here the bitfile fifo if is defined
                     push              => s_fpga_fifo_push,
                     push_data         => s_fpga_fifo_push_data,
                     last_byte         => s_fpga_fifo_last_byte,
                     fifo_full         => s_fpga_fifo_full,
                     -- Here the select map pins are defined
                     fpga_done         => fpga_done,
                     fpga_busy         => fpga_busy,
                     fpga_n_init       => fpga_n_init,
                     fpga_n_prog       => fpga_n_prog,
                     fpga_rd_n_wr      => fpga_rd_n_wr,
                     fpga_n_cs         => fpga_n_cs,
                     fpga_cclk         => fpga_cclk,
                     fpga_data_in      => s_fpga_data_in,
                     fpga_data_out     => s_fpga_data_out,
                     fpga_n_tri        => s_fpga_n_tri,
                     fpga_data_in_ena  => s_fpga_data_in_ena,
                     fpga_data_out_ena => s_fpga_data_out_ena);
   bitfile : bitfile_interpreter
             PORT MAP ( clock                 => s_clk_48MHz,
                        reset                 => s_usb_reset,
                        msec_tick             => s_msec_tick,
                        -- Here the handshake interface is defined
                        start                 => s_bitfile_start,
                        write_flash           => s_prog_flash,
                        done                  => s_bitfile_done,
                        error_detected        => s_bitfile_error,
                        -- Here the FX2 fifo interface is defined
                        pop                   => s_bitfile_pop,
                        pop_data              => s_bitfile_pop_data,
                        pop_last              => s_bitfile_last,
                        fifo_empty            => s_bitfile_fifo_empty,
                        -- Here the FPGA_IF fifo interface is defined
                        push                  => s_fpga_fifo_push,
                        push_data             => s_fpga_fifo_push_data,
                        last_byte             => s_fpga_fifo_last_byte,
                        fifo_full             => s_fpga_fifo_full,
                        reset_fpga_if         => s_reset_fpga_if,
                        -- Here the flash write fifo interface is defined
                        bitfile_size          => s_bitfile_size,
                        we_fifo               => s_we_fifo     ,
                        we_data               => s_we_data     ,
                        we_last               => s_we_last     ,
                        we_fifo_full          => s_we_fifo_full,
                        start_write           => s_start_write ,
                        size_error            => s_size_error,
                        -- Here the debug vga interface is defined
                        we_char               => OPEN,
                        ascii_data            => OPEN );
   flash : flash_if
           PORT MAP ( clock                => s_clk_48MHz,
                      reset                => s_reset_fpga_if,
                      msec_tick            => s_msec_tick,
                      -- here the control interface is defined
                      start_erase          => s_start_erase,
                      start_read           => s_start_flash_read,
                      start_write          => s_start_write,
                      done                 => s_flash_done,
                      flash_present        => s_flash_present ,
                      flash_s1_empty       => s_flash_s1_empty,
                      flash_idle           => s_flash_idle    ,
                      size_error           => s_size_error    ,
                      flash_n_busy         => s_flash_n_busy ,
                      start_config         => s_start_config,
                      -- here the push fifo interface is defined
                      push                 => s_flash_push     ,
                      push_data            => s_flash_push_data,
                      push_size            => s_flash_push_size,
                      push_last            => s_flash_push_last,
                      fifo_full            => s_flash_fifo_full,
                      -- here the write fifo is defined
                      bitfile_size         => s_bitfile_size,
                      we_fifo              => s_we_fifo,
                      we_data              => s_we_data,
                      we_last              => s_we_last,
                      we_fifo_full         => s_we_fifo_full,
                      -- Here the scpi interface is defined
                      start_command        => s_start_scpi_command,
                      command_id           => s_scpi_command_id,
                      scpi_pop             => s_pud_pop,
                      scpi_pop_data        => s_fifo_data,
                      scpi_pop_last        => s_fifo_last,
                      scpi_empty           => s_fifo_empty,
                      scpi_push            => s_pud_push,
                      scpi_push_data       => s_pud_push_data,
                      scpi_push_size       => s_pud_push_size,
                      scpi_full            => s_wf_fifo_full,
                      -- Here the vga interface is defined
                      we_char              => s_pud_we,
                      we_ascii             => s_pud_data,
                      we_addr              => s_pud_addr,
                      -- define the flash interface
                      flash_address        => flash_address,
                      flash_data_in        => flash_data,
                      flash_data_out       => s_flash_data_out,
                      flash_data_oe        => s_flash_data_oe,
                      flash_n_byte         => flash_n_byte,
                      flash_n_ce           => flash_n_ce,
                      flash_n_oe           => flash_n_oe,
                      flash_n_we           => flash_n_we,
                      flash_ready_n_busy   => flash_ready_n_busy );
                      
   make_flash_tri : FOR n IN 15 DOWNTO 0 GENERATE
      flash_data(n) <= s_flash_data_out(n) WHEN s_flash_data_oe(n) = '0' 
                                           ELSE 'Z';
   END GENERATE make_flash_tri;


   make_fpga_data_ffs : FOR n IN 7 DOWNTO 0 GENERATE
      fpga_data(n) <= s_fpga_data_out_reg(n) WHEN s_fpga_n_tri_reg(n) = '0'
                                             ELSE 'Z';
      in_ff : FDE
              PORT MAP ( Q   => s_fpga_data_in(n),
                         CE  => s_fpga_data_in_ena,
                         C   => s_clock_96MHz,
                         D   => fpga_data(n) );
      tri_ff : FD
               PORT MAP ( Q  => s_fpga_n_tri_reg(n),
                          C  => s_clock_96MHz,
                          D  => s_fpga_n_tri(n) );
      out_ff : FDE
               PORT MAP ( Q   => s_fpga_data_out_reg(n),
                          CE  => s_fpga_data_out_ena,
                          C   => s_clock_96MHz,
                          D   => s_fpga_data_out(n) );
   END GENERATE make_fpga_data_ffs;

END behave;
