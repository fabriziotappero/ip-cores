-------------------------------------------------------------------------------
-- Title      : LAN91C111 controller, read module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Original: DM9kA_read_module.vhd
-- Author     : Jussi Nieminen (Antti Alhonen for LAN91C111)
-- Last update: 2011-11-07
-------------------------------------------------------------------------------
-- Description: Handles reading of rx data from LAN91C111
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/09/02  1.0      niemin95        Created
-- 2011/07/??  lan91c111 alhonena
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lan91c111_ctrl_pkg.all;


entity lan91c111_read_module is

  generic (
    mode_16bit_g : integer := 0);
  
  port (
    clk                     : in  std_logic;
    rst_n                   : in  std_logic;
    -- from interrupt handler
    rx_waiting_in           : in  std_logic;
    -- from/to comm module
    reg_addr_out            : out std_logic_vector( real_addr_width_c-1 downto 0 );
    config_data_out         : out std_logic_vector( lan91_data_width_c-1 downto 0 );
    nBE_out                 : out std_logic_vector( 3 downto 0 );
    read_not_write_out      : out std_logic;
    config_valid_out        : out std_logic;
    data_from_comm_in       : in  std_logic_vector( lan91_data_width_c-1 downto 0 );
    data_from_comm_valid_in : in  std_logic;
    comm_busy_in            : in  std_logic;
    comm_req_out            : out std_logic;
    comm_grant_in           : in  std_logic;
    -- from/to upper level
    rx_data_out             : out std_logic_vector( lan91_data_width_c-1 downto 0 );
    rx_data_valid_out       : out std_logic;
    rx_bytes_valid_out      : out std_logic_vector( 3 downto 0);  -- you may want to use this to help reading, or as a debug signal, or to ignore it.
    rx_re_in                : in  std_logic;
    new_rx_out              : out std_logic;
    rx_len_out              : out std_logic_vector( tx_len_w_c-1 downto 0 );  -- Actual number of bytes of payload.
    frame_type_out          : out std_logic_vector( 15 downto 0 );
    rx_erroneous_out        : out std_logic;
    fatal_error_out         : out std_logic  -- worse than some network error
    );

end lan91c111_read_module;


architecture rtl of lan91c111_read_module is

  type read_state_type is (wait_rx,      -- wait until interrupt module rises rx_waiting_in.
                           set_pointer_to_status,  -- set the pointer register to read packet status.
                           read_status_and_len,    -- read the packet status and length
                           frame_type,  -- Ethernet frame type is read.
                           frame_type2,
                           start_read,
                           read_normal,
                           read_last_24,
                           read_last_16,
                           read_last_odd,
                           wait_re,
                           remove_from_fifo,  -- issue a command to MMU to remove the RX and free memory.
                           wait_for_mmu,  -- poll the MMU until it has processed the command.
                           check_mmu,
                           check_for_more);  -- check if there are more rx's in the FIFO.

  signal state_r : read_state_type;

  signal comm_req_r         : std_logic;

  signal rx_len_r : integer range 0 to 2**tx_len_w_c-1;

  signal config_valid_r : std_logic;

  signal first_r : std_logic;

  signal new_r : std_logic;

  signal new_rx_r : std_logic;
  signal rx_data_valid_r : std_logic;

  constant pnt_set_wait_cnt_c : integer := clk_hz_c/2702702;  -- 370 ns wait after pointer is set.
  signal pnt_set_wait_cnt_r : integer range 0 to pnt_set_wait_cnt_c;
  
-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  comm_req_out <= comm_req_r;

  config_valid_out <= config_valid_r;

  new_rx_out <= new_rx_r;

  rx_data_valid_out <= rx_data_valid_r;

  main : process (clk, rst_n)

    variable rx_len_v : integer range 0 to 2**tx_len_w_c-1;
    
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)

      state_r            <= wait_rx;
      comm_req_r         <= '0';
      rx_len_r           <= 0;

      reg_addr_out       <= (others => '0');
      config_data_out    <= (others => '0');
      config_valid_r   <= '0';
      read_not_write_out <= '0';
      rx_len_out         <= (others => '0');
      rx_erroneous_out   <= '0';
      fatal_error_out    <= '0';
      frame_type_out     <= (others => '0');
      new_r              <= '0';

      new_rx_r           <= '0';
      rx_data_valid_r    <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      if new_rx_r = '1' and rx_re_in = '1' then
        new_rx_r <= '0';
      end if;

      if rx_data_valid_r = '1' and rx_re_in = '1' then
        rx_data_valid_r <= '0';
      end if;
      
      -- DEFAULTS:
      config_valid_r <= '0';

      
      case state_r is
        
        when wait_rx =>
          -- notification from int handler
          if rx_waiting_in = '1' or new_r = '1' then
            new_r <= '0';
            -- ask for a turn
            comm_req_r <= '1';
          end if;

          if comm_req_r = '1' and comm_grant_in = '1' and comm_busy_in = '0' then
            -- our turn
            state_r <= set_pointer_to_status;
            -- again, we suppose that we are in BANK 2.
            config_data_out <= x"0000" & "11100" & "000" & x"00";  -- pointer to 0 (status), with rcv, read, autoincr.
            reg_addr_out <= "011"; nBE_out <= "1100"; read_not_write_out <= '0'; config_valid_r <= '1';
            pnt_set_wait_cnt_r <= pnt_set_wait_cnt_c;
          end if;

        when set_pointer_to_status =>
          if comm_busy_in = '0' and config_valid_r = '0' then
            if pnt_set_wait_cnt_r = 0 then
              -- pointer set, start reading.
              reg_addr_out <= "100"; nBE_out <= "0000"; read_not_write_out <= '1'; config_valid_r <= '1'; 
              state_r <= read_status_and_len;
            else
              pnt_set_wait_cnt_r <= pnt_set_wait_cnt_r - 1;
            end if;
          end if;

        when read_status_and_len =>
          if data_from_comm_valid_in = '1' then  -- this also means "not busy", remember that?
            rx_erroneous_out <= data_from_comm_in(10) or  -- too short
                                  data_from_comm_in(11) or  -- too long
                                  data_from_comm_in(13) or  -- bad crc
                                  data_from_comm_in(15);  -- alignment error.
            rx_len_v := to_integer(unsigned(data_from_comm_in(16+11-1 downto 17) & data_from_comm_in(12))) - 16;  -- actual data length.
            rx_len_r <= rx_len_v;
            rx_len_out <= std_logic_vector(to_unsigned(rx_len_v, tx_len_w_c));

            config_data_out <= x"0000" & "11100" & "000" & x"10";  -- set pointer to 16 (frame type), with rcv, read, autoincr.
            reg_addr_out <= "011"; nBE_out <= "1100"; read_not_write_out <= '0'; config_valid_r <= '1';
            pnt_set_wait_cnt_r <= pnt_set_wait_cnt_c;
            state_r <= frame_type;
          end if;

        when frame_type =>
          if comm_busy_in ='0' and config_valid_r = '0' then
            if pnt_set_wait_cnt_r = 0 then
              reg_addr_out <= "100"; nBE_out <= "1100"; read_not_write_out <= '1'; config_valid_r <= '1';  -- 16 bit read for frame type.
              state_r <= frame_type2;
            else
              pnt_set_wait_cnt_r <= pnt_set_wait_cnt_r - 1;
            end if;
          end if;

        when frame_type2 =>
          if data_from_comm_valid_in = '1' then
            frame_type_out <= data_from_comm_in(7 downto 0) & data_from_comm_in(15 downto 8);
            new_rx_r <= '1';
            state_r <= start_read;
            first_r <= '1';
          end if;
          
        when start_read =>
          if rx_re_in = '1' or first_r = '1' then  -- previous word was read by the application; or this is the first word.
            first_r <= '0';

            if mode_16bit_g = 1 then
              -- 16-bit mode:
              if rx_len_r = 1 then
                reg_addr_out <= "100"; nBE_out <= "1100"; read_not_write_out <= '1'; config_valid_r <= '1';
                state_r <= read_last_odd;   -- zero "data area" left; read control byte and last data byte.
              else
                reg_addr_out <= "100"; nBE_out <= "1100"; read_not_write_out <= '1'; config_valid_r <= '1';
                state_r <= read_normal;         -- normal 16-bit read.
              end if;

            else
              -- Original 32-bit mode:
              if rx_len_r = 1 then
                reg_addr_out <= "100"; nBE_out <= "1100"; read_not_write_out <= '1'; config_valid_r <= '1';
                state_r <= read_last_odd;   -- zero "data area" left; read control byte and last data byte.
              elsif rx_len_r = 2 then
                reg_addr_out <= "100"; nBE_out <= "1100"; read_not_write_out <= '1'; config_valid_r <= '1';
                state_r <= read_last_16;    -- two bytes of "data area" left; read it and ignore ctrl byte and last byte.
              elsif rx_len_r = 3 then
                reg_addr_out <= "100"; nBE_out <= "0000"; read_not_write_out <= '1'; config_valid_r <= '1';
                state_r <= read_last_24;    -- two bytes of "data area" left; do a 32-bit read to data + ctrl + odd byte.
              else
                reg_addr_out <= "100"; nBE_out <= "0000"; read_not_write_out <= '1'; config_valid_r <= '1';
                state_r <= read_normal;         -- normal 32-bit read.
              end if;
              
            end if;
            
          end if;
        
        when read_normal =>
          if data_from_comm_valid_in = '1' then
            rx_data_valid_r <= '1';
            rx_data_out <= data_from_comm_in;
            if mode_16bit_g = 1 then
              rx_bytes_valid_out <= "0011";
            else
              rx_bytes_valid_out <= "1111";              
            end if;
            state_r <= start_read;
            if (mode_16bit_g = 0 and rx_len_r = 4) or
               (mode_16bit_g = 1 and rx_len_r = 2) then        -- this was last and it was even.
              state_r <= wait_re;
            end if;
            if mode_16bit_g = 1 then
              rx_len_r <= rx_len_r - 2;
            else
              rx_len_r <= rx_len_r - 4;              
            end if;
          end if;

        when read_last_24 =>
          assert mode_16bit_g = 0 report "Shouldn't be here!" severity failure;
          
          if data_from_comm_valid_in = '1' then
            rx_data_valid_r <= '1';
            rx_data_out <= x"00" & data_from_comm_in(23 downto 0);
            rx_bytes_valid_out <= "0111";
            state_r <= wait_re;
          end if;

        when read_last_16 =>
          assert mode_16bit_g = 0 report "Shouldn't be here!" severity failure;
          
          if data_from_comm_valid_in = '1' then
            rx_data_valid_r <= '1';
            rx_data_out <= x"0000" & data_from_comm_in(15 downto 0);
            rx_bytes_valid_out <= "0011";
            state_r <= wait_re;
          end if;
          
        when read_last_odd =>
          if data_from_comm_valid_in = '1' then
            rx_data_valid_r <= '1';
            rx_data_out <= x"000000" & data_from_comm_in(7 downto 0);
            rx_bytes_valid_out <= "0001";
            state_r <= wait_re;
          end if;

        when wait_re =>             -- wait for last re from the application.
          if rx_re_in = '1' then
            state_r <= remove_from_fifo;
          end if;
          
        when remove_from_fifo =>
          if comm_busy_in = '0' and config_valid_r = '0' then
            config_data_out <= x"000000" & "10000000";  -- REMOVE AND RELEASE TOP OF RX FIFO
            reg_addr_out <= "000"; nBE_out <= "1100"; read_not_write_out <= '0'; config_valid_r <= '1';
            state_r <= wait_for_mmu;
          end if;

        when wait_for_mmu =>
          if comm_busy_in = '0' and config_valid_r = '0' then
            reg_addr_out <= "000"; nBE_out <= "1100"; read_not_write_out <= '1'; config_valid_r <= '1';
            state_r <= check_mmu;
          end if;

        when check_mmu =>
          if data_from_comm_valid_in = '1' then
            if data_from_comm_in(0) = '1' then  -- BUSY, poll again.
              state_r <= wait_for_mmu;
            else
              state_r <= check_for_more;  -- Everything finished, let's check if there are new rx's waiting...
              reg_addr_out <= "010"; nBE_out <= "1100"; read_not_write_out <= '1'; config_valid_r <= '1';
            end if;
          end if;

        when check_for_more =>
          if data_from_comm_valid_in = '1' then
            new_r <= not data_from_comm_in(15);  -- RX FIFO not empty.

            state_r <= wait_rx;
            comm_req_r <= '0';
          end if;

        when others => null;
      end case;

    end if;
  end process main;

end rtl;
