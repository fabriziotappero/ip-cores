-------------------------------------------------------------------------------
-- Title      : Initialization module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DM9kA_init_module.vhd
-- Author     : Jussi Nieminen
-- Company    : 
-- Last update: 2012-04-04
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Initializes DM9kA. Includes two state machines.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/24  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- constants
use work.DM9kA_ctrl_pkg.all;


entity DM9kA_init_module is

  port (
    clk                     : in  std_logic;
    rst_n                   : in  std_logic;
    ready_out               : out std_logic;
    sleep_time_out          : out std_logic_vector(sleep_time_w_c-1 downto 0);
    reg_addr_out            : out std_logic_vector(7 downto 0);
    config_data_out         : out std_logic_vector(7 downto 0);
    read_not_write_out      : out std_logic;
    config_valid_out        : out std_logic;
    data_from_comm_in       : in  std_logic_vector(data_width_c-1 downto 0);
    data_from_comm_valid_in : in  std_logic;
    comm_busy_in            : in  std_logic
    );

end DM9kA_init_module;


architecture rtl of DM9kA_init_module is
  
  type init_table_type is record
    addr       : std_logic_vector(7 downto 0);
    value      : std_logic_vector(7 downto 0);
    writing    : std_logic;
    sleep_time : integer;
  end record;

  constant init_values_c : integer := 24;
  type     init_table_array is array (0 to init_values_c-1) of init_table_type;
  
  constant init_table_c : init_table_array := (
    (GPCR_c, x"01", '1', 0),            -- 1
    (GPR_c, x"00", '1', power_up_sleep_c),    -- power up PHY
    (NCR_c, x"03", '1', 500),           -- software reset
    (NCR_c, x"00", '1', 0),
    (GPR_c, x"01", '1', 0),  -- shut down PHY, and start it once again
    (GPR_c, x"00", '1', 2*power_up_sleep_c),  -- don't know why, but it must be done
    (ISR_c, x"3F", '1', 0),             -- 16bit mode + reseting status
    (NSR_c, x"2C", '1', 0),             -- 10   reset NSR
    (NCR_c, x"00", '1', 0),

    (MAC1_c, MAC_addr_c(47 downto 40), '1', 0),  -- write MAC address
    (MAC2_c, MAC_addr_c(39 downto 32), '1', 0),
    (MAC3_c, MAC_addr_c(31 downto 24), '1', 0),
    (MAC4_c, MAC_addr_c(23 downto 16), '1', 0),
    (MAC5_c, MAC_addr_c(15 downto 8), '1', 0),
    (MAC6_c, MAC_addr_c(7 downto 0), '1', 0),

    (BPTR_c, x"3F", '1', 0),  -- send 600 us jam pattern when 3k left in RxRAM
    (FCTR_c, x"5A", '1', 0),            -- High/low water overflow thresholds
    (FCR_c, x"29", '1', 0),             -- 20   flow cntrl
    (WUCR_r, x"00", '1', 0),  -- wake up control (all wake up stuff disabled)
    (TCR2_c, x"80", '1', 0),            -- led mode 1
    (ETXCSR_c, x"83", '1', 0),          -- early transmit OFF.
    (IMR_c, x"83", '1', 0),   -- interrupt masks, allow rx and tx interrupts
    (RCR_c, x"39", '1', 0),   -- discard error/too long packets, enable rx
    (NSR_c, x"00", '0', 0));            -- 26   test read, bit 6 is link status

  signal init_cnt_r       : integer range 0 to init_values_c - 1;
  signal ready_r          : std_logic;
  signal data_from_comm_r : std_logic_vector(data_width_c-1 downto 0);

  type   init_state_type is (start, read_data, wait_busy, wait_link_up);
  signal state_r : init_state_type;

  signal reset_sleep_cnt_r : integer range 0 to reset_sleep_c;

  -- 1 second with 25MHz (yes, it's really necessary)
  constant link_wait_time_c : integer := 25_000_000;
  --constant link_wait_time_c : integer := 250;  -- ES simulation only!!!

  type   wait_link_type is (send_query, wait_reply, idle);
  signal wait_link_state_r : wait_link_type;
  signal wait_link_cnt_r   : integer range 0 to link_wait_time_c;


  -- how many seconds we wait until we are ready
  -- **************************************************************************
  -- * Okay, this might seem a bit weird thing to do (wait n seconds even after
  -- * the DM9kA tells us that it's link is up), but there's a reason to it.
  -- * When testing this block I noticed, that the PC on the other end needed
  -- * some time too to figure out that there is someone who might want to send
  -- * something. So if we start sending right after the DM9kA is ready, the PC
  -- * might not be ready to receive it.
  -- **************************************************************************
  constant continue_times_c : integer := 5;
  signal   continue_r       : integer range 0 to continue_times_c;


-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  ready_out <= ready_r;


  --
  -- Sequential process for state machine
  --  
  init : process (clk, rst_n)
  begin  -- process init
    if rst_n = '0' then                 -- asynchronous reset (active low)
      
      ready_r            <= '0';
      init_cnt_r         <= 0;
      data_from_comm_r   <= (others => '0');
      reset_sleep_cnt_r  <= 0;
      wait_link_cnt_r    <= 0;
      continue_r         <= 0;
      sleep_time_out     <= (others => '0');
      reg_addr_out       <= (others => '0');
      config_data_out    <= (others => '0');
      read_not_write_out <= '0';
      config_valid_out   <= '0';
      state_r            <= start;
      wait_link_state_r  <= send_query;
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      if reset_sleep_cnt_r /= reset_sleep_c then
        -- sleep for a while after reset release
        reset_sleep_cnt_r <= reset_sleep_cnt_r + 1;
        
      elsif ready_r = '0' then

        case state_r is
          when start =>

            reg_addr_out       <= init_table_c(init_cnt_r).addr;
            config_data_out    <= init_table_c(init_cnt_r).value;
            read_not_write_out <= not init_table_c(init_cnt_r).writing;
            sleep_time_out     <= std_logic_vector(to_unsigned(init_table_c(init_cnt_r).sleep_time, sleep_time_w_c));
            config_valid_out   <= '1';

            -- change state once busy is up (comm is working)
            if comm_busy_in = '1' then
              if init_table_c(init_cnt_r).writing = '0' then
                state_r <= read_data;
              else
                state_r <= wait_busy;
              end if;
            end if;

          when read_data =>

            -- reading is quite useless at the moment, but for example some
            -- registers can be cleared by reading if necessary
            if data_from_comm_valid_in = '1' then
              data_from_comm_r <= data_from_comm_in;
              state_r          <= wait_busy;
            end if;

          when wait_busy =>

            if comm_busy_in = '0' then
              config_valid_out <= '0';

              if init_cnt_r = init_values_c-1 then
                state_r <= wait_link_up;
              else
                init_cnt_r <= init_cnt_r + 1;
                state_r    <= start;
              end if;
            end if;


          when wait_link_up =>

            -- wait until link is up, before raising ready signal
            case wait_link_state_r is
              when send_query =>

                reg_addr_out       <= NSR_c;
                config_data_out    <= (others => '0');
                read_not_write_out <= '1';
                config_valid_out   <= '1';
                wait_link_state_r  <= wait_reply;

              when wait_reply =>

                if data_from_comm_valid_in = '1' then
                  if data_from_comm_in(6) = '1' then
                    -- if bit 6 from NSR - the link up bit - is up, wait continue_times_c
                    -- more and then continue
                    continue_r <= continue_r + 1;
                  end if;
                  wait_link_state_r <= idle;
                  config_valid_out  <= '0';
                end if;

              when idle =>

                if wait_link_cnt_r = link_wait_time_c then

                  wait_link_cnt_r <= 0;
                  -- check if link is up, and raise ready if so
                  if continue_r = continue_times_c then
                    ready_r <= '1';
                    state_r <= start;
                  end if;
                  wait_link_state_r <= send_query;
                  
                else
                  wait_link_cnt_r <= wait_link_cnt_r + 1;
                end if;
              when others => null;
            end case;
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
