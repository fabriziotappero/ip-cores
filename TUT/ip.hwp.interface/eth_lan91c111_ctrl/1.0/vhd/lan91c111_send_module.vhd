-------------------------------------------------------------------------------
-- Title      : LAN91C111 controller, sender module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Original: DM9kA_send_module.vhd
-- Author     : Jussi Nieminen. Antti Alhonen for LAN91C111.
-- Last update: 2011-11-08
-------------------------------------------------------------------------------
-- Description: Handles sending procedures
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/25  1.0      niemin95	Created
-- 2011/07/??  lan91c111 alhonena
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lan91c111_ctrl_pkg.all;


entity lan91c111_send_module is

  generic (
    mode_16bit_g : integer := 0);
  
  port (
    clk                     : in  std_logic;
    rst_n                   : in  std_logic;
    -- from interrupt handler
    tx_completed_in         : in  std_logic;
    -- to and from comm module
    comm_req_out            : out std_logic;
    comm_grant_in           : in  std_logic;
    reg_addr_out            : out std_logic_vector( real_addr_width_c-1 downto 0 );
    config_data_out         : out std_logic_vector( lan91_data_width_c-1 downto 0 );
    config_nBE_out          : out std_logic_vector( 3 downto 0 );
    read_not_write_out      : out std_logic;
    config_valid_out        : out std_logic;
    data_from_comm_in       : in  std_logic_vector( lan91_data_width_c-1 downto 0 );
    data_from_comm_valid_in : in  std_logic;
    comm_busy_in            : in  std_logic;
    -- from upper level
    tx_data_in              : in  std_logic_vector( lan91_data_width_c-1 downto 0 );
    tx_data_valid_in        : in  std_logic;
    tx_re_out               : out std_logic;
    tx_MAC_addr_in          : in  std_logic_vector( 47 downto 0 );
    new_tx_in               : in  std_logic;
    tx_len_in               : in  std_logic_vector( tx_len_w_c-1 downto 0 );
    tx_frame_type_in        : in  std_logic_vector( 15 downto 0 )
    );

end lan91c111_send_module;


architecture rtl of lan91c111_send_module is

  signal trgt_MAC_r : std_logic_vector(6*8-1 downto 0);
  
  type tx_state_type is (wait_tx,
                         alloc_mem,
                         wait_alloc,
                         copy_packet_number,
                         write_pointer,                        
                         write_byte_count,
                         write_MACs1,
                         write_MACs2,
                         write_MACs3,
                         write_frame_type,
                         write_payload,
                         write_payload_last16,  -- skipped if tx_len mod 4 = 0 or 1
                         write_padding,  -- SMSC bug workaround: autopadding does not work.
                         write_control_byte_and_last,
                         enqueue_packet_number_to_tx_fifo);
  signal tx_state_r : tx_state_type;

  signal tx_len_r : std_logic_vector( tx_len_w_c-1 downto 0 );
  signal payload_len_r : std_logic_vector( tx_len_w_c-1 downto 0 );
  signal tx_len_r_int : integer range 0 to 2**tx_len_w_c-1;
  signal payload_len_int : integer range 0 to 2**tx_len_w_c-1;

  signal tx_data_cnt_r : integer range 0 to 2**tx_len_w_c-1;

  signal pad_cnt_r : integer range 0 to 46;
  
  signal tx_data_r : std_logic_vector( lan91_data_width_c-1 downto 0 );
  signal tx_data_valid_r : std_logic;

  signal comm_req_r : std_logic;
  signal config_valid_r : std_logic;

  constant pnt_set_wait_cnt_c : integer := clk_hz_c/2702702;  -- 370 ns wait after pointer is set.
  signal pnt_set_wait_cnt_r : integer range 0 to pnt_set_wait_cnt_c;

  signal got_the_odd_r : std_logic;
  signal odd_r : std_logic_vector(7 downto 0);

  signal need_padding_r : std_logic;       -- Set if packet is short to overcome a bug/feature in lan91c111
  
-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------


  comm_req_out <= comm_req_r;
  tx_len_r_int <= to_integer( unsigned( tx_len_r ));
  payload_len_int <= to_integer( unsigned( payload_len_r ));

  config_valid_out <= config_valid_r;

  main: process (clk, rst_n)

    -- helping with odd length transfers
    variable odd_len_compensation_v : integer range 0 to 1;
    
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)

      tx_state_r   <= wait_tx;
      
      trgt_MAC_r <= (others => '0');

      reg_addr_out <= (others => '0');
      config_data_out <= (others => '0');
      config_valid_r <= '0';
      read_not_write_out <= '0';

      comm_req_r       <= '0';
      tx_data_r        <= (others => '0');
      tx_data_valid_r  <= '0';
      tx_len_r         <= (others => '0');
      got_the_odd_r    <= '0';
      need_padding_r      <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- new_tx_in, tx_len_in and tx_MAC_addr_in must remain stable until
      -- the first data is read from the upper level.
      
      -- tx state machine

      -- Note: We must be in BANK 2; The initialization algorithm sets the correct
      -- bank. If any other module switch banks, you must either switch
      -- back in those modules (recommended as switches are not usually needed)
      -- or add a new state to switch to bank 2 by using the bank change register at location E.

      -- DEFAULTS:
      config_valid_r <= '0';
      tx_re_out <= '0';

      
      case tx_state_r is
        when wait_tx =>
          got_the_odd_r <= '0';
          -- new transfer waiting
          if new_tx_in = '1' then
            comm_req_r <= '1';
            tx_len_r <= std_logic_vector( unsigned( tx_len_in ) + to_unsigned( eth_header_len_c, tx_len_w_c ));
            payload_len_r <= tx_len_in;
            trgt_MAC_r <= tx_MAC_addr_in;
            
            if comm_grant_in = '1' and comm_req_r = '1' then
              -- we got permission to use the comm module.
              tx_state_r <= alloc_mem;
              reg_addr_out <= "000";
              config_nBE_out <= "1100";  -- 16 bit accesses follow.
              read_not_write_out <= '0';
              config_data_out <= x"000000" & "00100000";
              config_valid_r <= '1';             
            end if;
          end if;
          
        when alloc_mem =>
          if comm_busy_in = '0' and config_valid_r = '0' then
            -- Comm not busy anymore; the next operation.
            tx_state_r <= wait_alloc;
            reg_addr_out <= "110";
            read_not_write_out <= '1';
            config_valid_r <= '1';
          end if;

          if tx_len_r_int < 71 then
            need_padding_r <= '1';
            pad_cnt_r <= 72 - tx_len_r_int;
          else
            need_padding_r <= '0';
          end if;        

        when wait_alloc =>
          if data_from_comm_valid_in = '1' then  -- data_valid = '1' means also
                                                 -- busy = '0'. See comm module.
            if data_from_comm_in(3) = '1' then  -- ALLOC INT flag = ready.
              tx_state_r <= copy_packet_number;
              reg_addr_out <= "001";
              read_not_write_out <= '1';
              config_valid_r <= '1';
            else
              -- Not ready yet...
              tx_state_r <= alloc_mem;  -- Poll again.
            end if;
          end if;

        when copy_packet_number =>
          if data_from_comm_valid_in = '1' then
            reg_addr_out <= "001";
            -- Copy from ALLOCATED PACKET NUMBER to PACKET NUMBER TX AREA. Both
            -- are within the same word.
            config_nBE_out <= "1100";
            config_data_out <= x"000000" & "00" & data_from_comm_in(13 downto 8);
            read_not_write_out <= '0';
            config_valid_r <= '1';                                                            
            tx_state_r <= write_pointer;
          end if;

        when write_pointer =>
          if comm_busy_in = '0'  and config_valid_r = '0' then
            reg_addr_out <= "011";
            -- Set pointer to RAM offset 2 (Byte count starts here),
            -- with Auto Increment on.
            config_nBE_out <= "1100";
            config_data_out <= x"0000" & "01000" & "00000000010";
            read_not_write_out <= '0';
            config_valid_r <= '1';
            tx_state_r <= write_byte_count;
            pnt_set_wait_cnt_r <= pnt_set_wait_cnt_c;
          end if;

        when write_byte_count =>
          if comm_busy_in = '0'  and config_valid_r = '0' then
            if pnt_set_wait_cnt_r = 0 then
              reg_addr_out <= "100";      -- All further operations go to this address.
              config_nBE_out <= "1100";
              read_not_write_out <= '0';  -- Everything after this will be writes.
              if need_padding_r = '1' then
                config_data_out <= x"0000" & "00000" & "00001001000";
              else
                config_data_out <= x"0000" & "00000" & tx_len_r;                
              end if;
              config_valid_r <= '1';
              tx_state_r <= write_MACs1;
            else
              pnt_set_wait_cnt_r <= pnt_set_wait_cnt_r - 1;
            end if;
          end if;

        when write_MACs1 =>
          if comm_busy_in = '0' and config_valid_r = '0' then
            config_nBE_out <= "0000";   -- 32 bit access.
            config_data_out <= trgt_MAC_r(3*8-1 downto 2*8) & trgt_MAC_r(4*8-1 downto 3*8) & trgt_MAC_r(5*8-1 downto 4*8) & trgt_MAC_r(6*8-1 downto 5*8);
            config_valid_r <= '1';
            tx_state_r <= write_MACs2;
          end if;

        when write_MACs2 =>
          if comm_busy_in = '0' and config_valid_r = '0'  then
            config_nBE_out <= "0000";
            config_data_out <= MAC_addr_c(5*8-1 downto 4*8) & MAC_addr_c(6*8-1 downto 5*8) & trgt_MAC_r(1*8-1 downto 0) & trgt_MAC_r(2*8-1 downto 1*8);
            config_valid_r <= '1';
            tx_state_r <= write_MACs3;
          end if;

        when write_MACs3 =>
          if comm_busy_in = '0' and config_valid_r = '0'  then
            config_nBE_out <= "0000";
            config_data_out <= MAC_addr_c(1*8-1 downto 0*8) & MAC_addr_c(2*8-1 downto 1*8) & MAC_addr_c(3*8-1 downto 2*8) & MAC_addr_c(4*8-1 downto 3*8);
            config_valid_r <= '1';
            tx_state_r <= write_frame_type;
          end if;
          
        when write_frame_type =>
          if comm_busy_in = '0' and config_valid_r = '0'  then
            config_nBE_out <= "1100";   -- 16 bit access!
            config_data_out <= x"0000" & tx_frame_type_in(7 downto 0) & tx_frame_type_in(15 downto 8);
            config_valid_r <= '1';
            if payload_len_int = 1 then
              if need_padding_r = '1' then
                tx_state_r <= write_padding;
              else
                tx_state_r <= write_control_byte_and_last;                
              end if;
            elsif mode_16bit_g = 0 and (payload_len_int = 2 or payload_len_int = 3) then
              tx_state_r <= write_payload_last16;
            else
              tx_state_r <= write_payload;
            end if;
            tx_data_cnt_r <= payload_len_int;
          end if;

        when write_payload =>
          if comm_busy_in = '0' and config_valid_r = '0' and tx_data_valid_in = '1' then
            if mode_16bit_g = 1 then
              config_nBE_out <= "1100";

              config_data_out <= tx_data_in;
              config_valid_r <= '1';
              tx_re_out <= '1';

              if tx_data_cnt_r = 2 or tx_data_cnt_r = 3 then
                if need_padding_r = '1' then
                  tx_state_r <= write_padding;
                else
                  tx_state_r <= write_control_byte_and_last;                
                end if;
              end if;
                           
              tx_data_cnt_r <= tx_data_cnt_r - 2;             

            else                        -- 32 bit mode (original)
              config_nBE_out <= "0000";

              config_data_out <= tx_data_in;
              config_valid_r <= '1';
              tx_re_out <= '1';

              if tx_data_cnt_r = 4 or tx_data_cnt_r = 5 then
                if need_padding_r = '1' then
                  tx_state_r <= write_padding;
                else
                  tx_state_r <= write_control_byte_and_last;
                end if;
              elsif tx_data_cnt_r = 6 or tx_data_cnt_r = 7 then
                tx_state_r <= write_payload_last16;
              end if;

              tx_data_cnt_r <= tx_data_cnt_r - 4;
              
            end if;
          end if;

        when write_payload_last16 =>
          assert mode_16bit_g = 0 report "Shouldn't be here!" severity failure;
          if comm_busy_in = '0' and config_valid_r = '0' and tx_data_valid_in = '1' then
            config_nBE_out <= "1100";
            config_data_out(15 downto 0) <= tx_data_in(15 downto 0);
            got_the_odd_r <= '1';
            odd_r <= tx_data_in(23 downto 16);
            config_valid_r <= '1';           
            tx_re_out <= '1';
            if need_padding_r = '1' then
              tx_state_r <= write_padding;
            else
              tx_state_r <= write_control_byte_and_last;
            end if;

          end if;

        when write_padding =>
          if comm_busy_in = '0' and config_valid_r = '0' then
            -- Padding as 16-bit writes to simplify.
            config_nBE_out <= "1100";

            config_data_out <= x"00000000";
            config_valid_r <= '1';

            if pad_cnt_r = 2 or pad_cnt_r = 3 then
              tx_state_r <= write_control_byte_and_last;                
            end if;
                           
            pad_cnt_r <= pad_cnt_r - 2;
          end if;
          
        when write_control_byte_and_last =>
          if comm_busy_in = '0' and config_valid_r = '0'  then
            if tx_data_cnt_r = 0 or tx_data_cnt_r = 2 then
              -- no odd byte.
              config_nBE_out <= "1100";
              config_data_out <= x"0000" & "00010000" & x"00";
              config_valid_r <= '1';
              tx_state_r <= enqueue_packet_number_to_tx_fifo;
            else
              if tx_data_valid_in = '1' or got_the_odd_r = '1' then
                config_nBE_out <= "1100";
                if got_the_odd_r = '1' then
                  config_data_out <= x"0000" & "00110000" & odd_r;
                else
                  config_data_out <= x"0000" & "00110000" & tx_data_in(7 downto 0);
                  tx_re_out <= '1';           -- read the odd byte.                  
                end if;
                config_valid_r <= '1';
                tx_state_r <= enqueue_packet_number_to_tx_fifo;
              end if;
            end if;
          end if;

        when enqueue_packet_number_to_tx_fifo =>
          if comm_busy_in = '0' and config_valid_r = '0' then
            reg_addr_out <= "000";
            read_not_write_out <= '0';
            config_data_out <= x"000000" & "11000000";
            config_valid_r <= '1';
            tx_state_r <= wait_tx;
            comm_req_r <= '0';
          end if;
          
        when others => null;
      end case;                     -- tx_state_r
    end if;
  end process main;
  

end rtl;
