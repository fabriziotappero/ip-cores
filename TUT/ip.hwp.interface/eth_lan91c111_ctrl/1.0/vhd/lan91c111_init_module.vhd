-------------------------------------------------------------------------------
-- Title      : Initialization Module for LAN91C111
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Originally: DM9kA_init_module.vhd
-- Author     : Antti Alhonen (Original (simple) DM9000A version by Jussi Nieminen)
-- Company    : DCS/TUT
-- Last update: 2011-11-08
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Initializes LAN91C111. Half of the registers on the very same
-- integrated chip are separated from the others for some mystical reason* and are
-- accessed by EMULATING A SERIAL INTERFACE by issuing the serial data signals,
-- including clock timing, through the registers of the other half. YES, you
-- read it correctly, it really is true. 
-- Furthermore, some of the configuration options are located in both sections
-- and you have to manually make sure they match in the correct way; or, some of
-- them are fakes and only the ones in the right section really work. In addition,
-- user has to copy information between the sections. Etc.

-- (*) (yes I know why they did that but that's not an excuse;
-- they probably took two finished designs for MAC & PHY and made a quick
-- hack to connect them together in a way that somehow works but is hell to
-- use; it would be easier to use separate chips. Then, this chip is manufactured
-- for years and years to come. A decent replacement is not made.

-- The design also seems to suffer from some legacy from the ISA bus era,
-- despite the fact that the chip is NOT (specifically) meant for ISA busses; and
-- AFAIK is introduced years after the ISA went obsolete. Quite the opposite,
-- this is marketed as a chip for direct use with an embedded processor etc.

-- It probably would have been too easy to:
-- - Put all the configuration registers behind one unified interface (OMG),
-- - ONCE THEY HAVE THE 15-BIT ADDRESS BUS (for some mystical reason), really use *gasp*
--   FIVE bits (instead of the current three), thus eliminating the dumb concept of "IO
--   BANKS" (which, despite the name, has nothing to do with "IO"s). 
-- Oh, the DM9000A guys did it like that... The specifications may be in poor English
-- for that chip but it's not completely ****** up.
--
-- Congratulations for choosing LAN91C111 :-)! Good luck and have fun!
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/24  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- constants
use work.lan91c111_ctrl_pkg.all;


entity lan91c111_init_module is

  generic (
    enable_tx_g : std_logic := '1';
    enable_rx_g : std_logic := '1');

  port (
    clk                     : in  std_logic;
    rst_n                   : in  std_logic;
    ready_out               : out std_logic;
    reg_addr_out            : out std_logic_vector( real_addr_width_c-1 downto 0 );
    config_data_out         : out std_logic_vector( lan91_data_width_c-1 downto 0 );
    nBE_out                 : out std_logic_vector( 3 downto 0 );
    read_not_write_out      : out std_logic;
    config_valid_out        : out std_logic;
    data_from_comm_in       : in  std_logic_vector( lan91_data_width_c-1 downto 0 );
    data_from_comm_valid_in : in  std_logic;
    comm_busy_in            : in  std_logic
    );

end lan91c111_init_module;


architecture rtl of lan91c111_init_module is

  type init_table_type is record
    phy   : std_logic;                  -- If '1', communicate with PHY registers
                                        -- instead of MAC. Addr will be 5 bits
                                        -- instead of 3, value will be 16 bits
                                        -- instead of 32 and nBE will be ignored.
    addr  : std_logic_vector( 4 downto 0 );  -- for normal MAC operations, use
                                             -- only 2 downto 0.
    value : std_logic_vector( lan91_data_width_c-1 downto 0 );
    nBE   : std_logic_vector( 3 downto 0 );
    writing : std_logic;
    sleep_time : integer range 0 to max_sleep_c;
    only_sleep : std_logic;  -- don't do anything but sleep.

    poll_until : std_logic;  -- use when writing='0'; if set to '1', don't advance to next step until 
    poll_bit_num : integer;  -- poll_bit_num bit of the read value equals to poll_value. Sleeping will
    poll_value : std_logic;  -- be done on every poll cycle, also after a match.

    copy       : std_logic;  -- When writing='1', use copy = '1' to write LAST READ VALUE (from
                             -- the SAME section (phy/mac)) instead of the "value" field; IN ADDITION,
                             -- if "poll_until" is '1', take the copy_bit_num'th bit FROM THE OTHER SECTION
    copy_bit_num: integer;   -- and put it in the poll_bit_num'th place. So: copy one bit from the PHY index x to
                             -- MAC index y; read MAC, READ PHY, write MAC with copy = 1, poll_until = 1,
                             -- copy_bit_num = x and poll_bit_num = y. (So this is not a poll, just reusing fields.
                             -- Poll happens only when writing = '0'.)
  end record;
  
  constant init_values_c : integer := 28;
  type init_table_array is array (0 to init_values_c-1) of init_table_type;

  -- Remember: manually change the bank to 3 before entering any PHY commands.
  constant init_table_c : init_table_array := (
--   PHY    ADDR     DATA                               nBE   W?  Sleep   Sleep_only POLL, POLLBIT, POLLVAL, COPY, COPYBIT
    ('0', "00000", x"00000000",                       "0000", '1', clk_hz_c/20, '1', '0',    0,       '0',    '0',   0),  -- Sleep 50 ms
    ('0', "00111", x"00000000",                       "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- Select BANK 0
    ('0', "00010", x"00008000",                       "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- Soft reset
    ('0', "00010", x"00000000",                       "1100", '1', clk_hz_c/20, '0', '0',    0,       '0',    '0',   0),  -- Clear soft reset and sleep 50 ms.
    ('0', "00000", x"000000" & "0000000" & enable_tx_g,"1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- TX Enable according to enable_tx_g. Padding doesn't work, don't bother
    ('0', "00101", x"0000" & "00111000" & "00010000", "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- Autonegotiation on, leds.
-- Reset the PHY to start autonegotiation.
    ('0', "00111", x"00000003",                       "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- Select BANK 3
    ('1', "00000", x"00008000",                       "1100", '1', clk_hz_c/20, '0', '0',    0,       '0',    '0',   0),  -- Reset PHY, sleep 50 ms.
    ('1', "00000", x"0000" & "0011000100000000",      "1100", '1', clk_hz_c*2,  '0', '0',    0,       '0',    '0',   0),  -- PHY isolation mode off, ANEG on. Sleep 2 sec.
--    ('1', "00010", x"00000000",                       "1100", '0', 50          ,'0', '0',    0,       '0',    '0',   0),  -- DEBUG: Read reg 2 from PHY, company ID.
    ('1', "00001", x"00000000",                       "1100", '0', clk_hz_c/200,'0', '1',    5,       '1',    '0',   0),  -- Poll for ANEG_ACK in PHY for every 5 ms until '1'.
    ('1', "00001", x"00000000",                       "1100", '0', clk_hz_c/200,'0', '1',    2,       '1',    '0',   0),  -- Poll for LINK in PHY for every 5 ms until '1'.
-- Autonegotiation is done.
-- Now, copy one PHY register bit to appropriate location in the MAC register.
    ('0', "00111", x"00000000",                       "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- Select BANK 0
    ('0', "00000", x"00000000",                       "1100", '0', 0,           '0', '0',    0,       '0',    '0',   0),  -- Read BANK 0 offset 0 to get a local copy here (MAC).
    ('0', "00111", x"00000003",                       "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- Select BANK 3 to be able to access PHY.
    ('1', "10010", x"00000000",                       "1100", '0', 0,           '0', '0',    0,       '0',    '0',   0),  -- Read PHY register 18 to get a local copy here (PHY).
    ('0', "00111", x"00000000",                       "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- Select BANK 0
    ('0', "00000", x"ACDCABBA",                       "1100", '1', 0,           '0', '1',   15,       '0',    '1',   6),  -- Copy bit 6 from PHY we read earlier to MAC offset 0 bit 15.
    
-- Now, configure all MAC registers:
    ('0', "00111", x"00000000",                       "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- Select BANK 0
    ('0', "00010", x"0000" & "0000001" & enable_rx_g & x"00", "1100", '1', 0,   '0', '0',    0,       '0',    '0',   0),  -- STRIP CRC = on, RX enable according to enable_rx_g.
    ('0', "00111", x"00000001",                       "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- Select BANK 1
    ('0', "00010", MAC_addr_c(23 downto 16) & MAC_addr_c(31 downto 24) & MAC_addr_c(39 downto 32) & MAC_addr_c(47 downto 40), "0000",'1',0,'0','0',0,'0','0',0), -- MAC Address 32 LSb's.
    ('0', "00100", x"0000" & MAC_addr_c(7 downto 0) & MAC_addr_c(15 downto 8),"1100",'1',0,'0','0',0, '0',    '0',   0),  -- MAC Address 16 MSb's.
    ('0', "00110", x"0000" & "0001101000010000",      "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- AUTO_RELEASE on.
    ('0', "00111", x"00000002",                       "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- Select BANK 2
    ('0', "00000", x"000000" & "01000000",            "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- Issue MMU Reset Command, just to be sure.
    ('0', "00110", x"0000" & "0000000" & enable_rx_g & x"FF", "1100", '1', 0,           '0', '0',    0,       '0',    '0',   0),  -- RCV interrupt mask according to enable_rx_g. Also ack all.
-- Alles in Ordnung, and link should be up. Let's sleep for a few seconds so that the other side is up, too.
    ('0', "00000", x"ACDCABBA",                       "1111", '1', clk_hz_c*3,  '1', '0',    0,       '0',    '0',   0),   -- Sleep only, three seconds.
--    ('0', "00110", x"00000000",                       "1100", '0', 50          ,'0', '0',    0,       '0',    '0',   0),  -- DEBUG: Read that interrupt mask register.
    ('0', "00000", x"ACDCABBA",                       "1111", '1', clk_hz_c*3,  '1', '0',    0,       '0',    '0',   0)    -- Sleep only, three seconds.
    );                                  -- And note, we left in BANK 2, as we should!! Other modules expect this.
  
    
  signal init_cnt_r : integer range 0 to init_values_c - 1;
  signal ready_r : std_logic;
  signal data_from_comm_r : std_logic_vector( lan91_data_width_c-1 downto 0 );

  type init_state_type is (start, read_data, wait_busy, sleep, phy_horror, finished);
  signal state_r : init_state_type;

  type phy_horror_state_type is (start_horror,
                                 write1, wait1, write2, wait2, write3, wait3,
                                 read3, waitread  -- they come after wait2, only if reading
                                 );

  signal phy_horror_state_r : phy_horror_state_type;

  constant phy_horror_length_c : integer := 64;  -- PHY configuration horror
                                                 -- cycle lasts for 64 serial
                                                 -- clock cycles, including the
                                                 -- "IDLE" period that could be
                                                 -- called a START CONDITION
                                                 -- as it is a condition for
                                                 -- a successful start.

  signal phy_horror_counter_r : integer range 0 to phy_horror_length_c;
  -- let's use 250 ns waiting time between clk cycles. There is some extra
  -- cycles in addition to this.
  constant phy_horror_wait_time_c : integer := clk_hz_c/4000000;  
  signal phy_horror_wait_cnt_r : integer range 0 to phy_horror_wait_time_c;
  -- Phy horror register includes first (leftmost) 34 bits hard-wired to the start condition.
  -- Rightmost bits are registers. Leftmosts (MSb's) are send first. Register
  -- is set before the sending of the serial bits starts.
  signal phy_horror_register_r : std_logic_vector(phy_horror_length_c-1 downto 0);
  signal phy_horror_interface_MDOE_r : std_logic;  -- '0' if we want to instruct the Phy horror interface to hi-Z state.
  signal phy_horror_read_data_flowing_r : std_logic;  -- Comes high two Horror Cycles after
                                                      -- MDOE_r goes low.

  signal horror_read_r : std_logic_vector(15 downto 0);
  
  signal reset_sleep_cnt_r : integer range 0 to reset_sleep_c;
  signal sleep_cnt_r : integer range 0 to max_sleep_c;

  -- 1 second with 25MHz (yes, it's really necessary)
  constant link_wait_time_c : integer := 25000000;
  
  
  
-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  assert phy_horror_wait_time_c > 0 report "this has to be 1 or more" severity failure;
  
  ready_out <= ready_r;

  -- Concurrent part of the phy_horror_register: the start condition consisting
  -- of things called "IDLE" and "START BITS".
  phy_horror_register_r(63 downto 30) <= "1111111111111111111111111111111101";
  
  init: process (clk, rst_n)
  begin  -- process init
    if rst_n = '0' then                 -- asynchronous reset (active low)
      
      ready_r           <= '0';
      init_cnt_r        <= 0;
      data_from_comm_r  <= (others => '0');
      reset_sleep_cnt_r <= 0;
      reg_addr_out      <= (others => '0');
      config_data_out   <= (others => '0');
      read_not_write_out <= '0';
      config_valid_out  <= '0';
      state_r           <= start;
      phy_horror_state_r <= start_horror;

      horror_read_r <= (others => '0');
      sleep_cnt_r <= 0;
      
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- DEFAULTS:
      config_valid_out <= '0';
    
      if reset_sleep_cnt_r /= reset_sleep_c then
        -- sleep for a while after reset release
        reset_sleep_cnt_r <= reset_sleep_cnt_r + 1;
        
      elsif ready_r = '0' then

        case state_r is
          when start =>
            if init_table_c(init_cnt_r).only_sleep = '1' then
              sleep_cnt_r <= init_table_c(init_cnt_r).sleep_time;
              state_r <= sleep;
            elsif init_table_c(init_cnt_r).phy = '1' then
              -- Enter the psycho mode. 
              state_r <= phy_horror;
            else
              -- A _*NORMAL*_ OPERATION (at least quite normal)!
              reg_addr_out <= init_table_c( init_cnt_r ).addr(real_addr_width_c-1 downto 0);
              if init_table_c( init_cnt_r ).copy = '1' then
                config_data_out <= data_from_comm_r;
                if init_table_c(init_cnt_r).poll_until = '1' then  -- this means the "modify" command.
                  config_data_out(init_table_c(init_cnt_r).poll_bit_num) <= horror_read_r(init_table_c(init_cnt_r).copy_bit_num);
                  -- bypass this one bit.
                end if;
              else
                config_data_out <= init_table_c( init_cnt_r ).value;
              end if;
              read_not_write_out <= not init_table_c( init_cnt_r ).writing;
              nBE_out <= init_table_c( init_cnt_r ).nBE;
              config_valid_out <= '1';

              -- change state once busy is up (comm is working)
              if comm_busy_in = '1' then
                if init_table_c( init_cnt_r ).writing = '0' then
                  state_r <= read_data;
                else
                  state_r <= wait_busy;
                end if;
              end if;
            end if;

          when read_data =>

            -- reading is quite useless at the moment, but for example some
            -- registers can be cleared by reading if necessary
            if data_from_comm_valid_in = '1' then
              data_from_comm_r <= data_from_comm_in;
              state_r <= wait_busy;
            end if;

          when wait_busy =>
            if comm_busy_in = '0' then
              sleep_cnt_r <= init_table_c(init_cnt_r).sleep_time;
              state_r <= sleep;
            end if;

          when sleep =>
            if sleep_cnt_r /= 0 then
              sleep_cnt_r <= sleep_cnt_r - 1;
            else
              -- Were we polling something?
              if init_table_c(init_cnt_r).poll_until = '1' and
                 ((init_table_c(init_cnt_r).phy = '1' and horror_read_r(init_table_c(init_cnt_r).poll_bit_num) /= init_table_c(init_cnt_r).poll_value) or
                 (init_table_c(init_cnt_r).phy = '0' and data_from_comm_r(init_table_c(init_cnt_r).poll_bit_num) /= init_table_c(init_cnt_r).poll_value))
              then
                state_r <= start;       -- back to start to poll again!
              else
                -- We were not polling, or got what we wanted.
                if init_cnt_r = init_values_c-1 then
                  state_r <= finished;
                else
                  init_cnt_r <= init_cnt_r + 1;  -- to next row.
                  state_r <= start;
                end if;
              end if;
            end if;

          when phy_horror =>
            case phy_horror_state_r is
              when start_horror =>
                phy_horror_register_r(29 downto 0) <=
                  not init_table_c(init_cnt_r).writing &
                  init_table_c(init_cnt_r).writing &
                  "00000" &
                  init_table_c(init_cnt_r).addr(4 downto 0) &
                  "10" &                -- "turnaround" is written always
                                        -- as "10". Request for high-impedance
                                        -- is done separately.
                  init_table_c(init_cnt_r).value(15 downto 0);

                if init_table_c( init_cnt_r ).copy = '1' then
                  phy_horror_register_r(15 downto 0) <= horror_read_r;  -- bypass the value.
                  if init_table_c(init_cnt_r).poll_until = '1' then  -- this means the "modify" command.
                    phy_horror_register_r(init_table_c(init_cnt_r).poll_bit_num) <= data_from_comm_r(init_table_c(init_cnt_r).copy_bit_num);
                    -- bypass this one bit.
                  end if;
                end if;
                
                phy_horror_counter_r <= phy_horror_length_c-1;
                -- Everything will be 16 bit writes to the same stupid
                -- "Management Interface" register.
                reg_addr_out <= "100";
                nBE_out <= "1100";
                phy_horror_interface_MDOE_r <= '1';
                phy_horror_read_data_flowing_r <= '0';
                phy_horror_state_r <= write1;

              when write1 =>
                if comm_busy_in = '0' then
                  read_not_write_out <= '0';
                  config_data_out <= x"0000" & "00110011" & "0011"
                                     & phy_horror_interface_MDOE_r
                                     & '0'  -- MCLK
                                     & '0'  -- MDI
                                     & phy_horror_register_r(phy_horror_counter_r);
                  config_valid_out <= '1';
                  phy_horror_state_r <= wait1;
                  phy_horror_wait_cnt_r <= phy_horror_wait_time_c;
                end if;

              when wait1 =>
                if comm_busy_in = '0' then
                  if phy_horror_wait_cnt_r = 0 then
                    if init_table_c(init_cnt_r).writing = '0' and phy_horror_read_data_flowing_r = '1' then
                      phy_horror_state_r <= read3;
                    else
                      phy_horror_state_r <= write2;
                    end if;
                  else
                    phy_horror_wait_cnt_r <= phy_horror_wait_cnt_r - 1;
                  end if;
                end if;

              when write2 =>
                if comm_busy_in = '0' then
                  read_not_write_out <= '0';
                  config_data_out <= x"0000" & "00110011" & "0011"
                                     & phy_horror_interface_MDOE_r
                                     & '1'  -- OOOOOOOHHH, create the clock edge!!!!
                                     & '0'  -- MDI
                                     & phy_horror_register_r(phy_horror_counter_r);
                  config_valid_out <= '1';
                  phy_horror_state_r <= wait2;
                  phy_horror_wait_cnt_r <= phy_horror_wait_time_c;
                end if;

              when wait2 =>
                if comm_busy_in = '0' then
                  if phy_horror_wait_cnt_r = 0 then
                    phy_horror_state_r <= write3;
                  else
                    phy_horror_wait_cnt_r <= phy_horror_wait_cnt_r - 1;
                  end if;
                end if;

              when read3 =>
                -- This state is skipped when writing.
                if comm_busy_in = '0' then
                  read_not_write_out <= '1';  -- read operation to the same addr
                  config_valid_out <= '1';
                  phy_horror_state_r <= waitread;
                end if;
                
              when waitread =>
                -- This state is skipped when writing.
                if data_from_comm_valid_in = '1' then
                  -- data valid means also not busy so no need to check that.
                  -- Just read the data we are interested in here
                  horror_read_r(phy_horror_counter_r) <= data_from_comm_in(1);
                  phy_horror_state_r <= write2;
                end if;
                
              when write3 =>
                if comm_busy_in = '0' then
                  read_not_write_out <= '0';
                  config_data_out <= x"0000" & "00110011" & "0011"
                                     & phy_horror_interface_MDOE_r
                                     & '0'  -- MCLK  Low again, OMG
                                     & '0'  -- MDI
                                     & phy_horror_register_r(phy_horror_counter_r);
                  config_valid_out <= '1';
                  phy_horror_state_r <= wait3;
                  phy_horror_wait_cnt_r <= phy_horror_wait_time_c;
                end if;

              when wait3 =>
                if comm_busy_in = '0' then
                  if phy_horror_wait_cnt_r = 0 then
                    if phy_horror_counter_r = 0 then
                      -- OH YES, we got all the bits done.
                      phy_horror_state_r <= start_horror;
                      state_r <= wait_busy;  -- This is good, away from the horror FSM.
                    else
                      phy_horror_counter_r <= phy_horror_counter_r - 1;
                      phy_horror_state_r <= write1;  -- To the next bit...
                      if init_table_c(init_cnt_r).writing = '0' then
                        if phy_horror_counter_r = 18 then
                          -- Turnaround time.
                          phy_horror_interface_MDOE_r <= '0';
                        elsif phy_horror_counter_r = 16 then
                          -- Valid data is coming next (hopefully)
                          phy_horror_read_data_flowing_r <= '1';
                        end if;
                      end if;
                    end if;
                  else
                    phy_horror_wait_cnt_r <= phy_horror_wait_cnt_r - 1;
                  end if;
                end if;

                
              when others => null;
            end case;

          when finished =>

            ready_r <= '1';

          when others => null;
        end case;

      else
        -- ready_r = '1'

        reg_addr_out       <= (others => '0');
        config_data_out    <= (others => '0');
        read_not_write_out <= '0';
        config_valid_out   <= '0';
        
      end if;
    end if;
  end process init;
  

end rtl;
