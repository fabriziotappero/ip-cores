-------------------------------------------------------------------------------
-- Title      : Communication module for the DM9000A controller block
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DM9kA_comm_module.vhd
-- Author     : Jussi Nieminen
-- Last update: 2012-04-04
-------------------------------------------------------------------------------
-- Description: Handles communication with DM9000A chip and arbitrates
-- between init, interrupt handler, read, and send modules. Includes a state
-- machine where one state (config) includes another state machine.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/21  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.DM9kA_ctrl_pkg.all;

entity DM9kA_comm_module is

  port (
    clk   : in std_logic;               -- 25 MHz
    rst_n : in std_logic;

    -- Common interfaces to submodules (and to init block)
    comm_requests_in       : in  std_logic_vector(submodules_c-1 downto 0);
    comm_grants_out        : out std_logic_vector(submodules_c-1 downto 0);
    register_addrs_in      : in  std_logic_vector((submodules_c+1) * 8 - 1 downto 0);  -- from each submodule
    config_datas_in        : in  std_logic_vector((submodules_c+1) * 8 - 1 downto 0);
    read_not_write_in      : in  std_logic_vector(submodules_c downto 0);
    configs_valid_in       : in  std_logic_vector(submodules_c downto 0);
    data_to_submodules_out : out std_logic_vector(data_width_c - 1 downto 0);
    data_to_sb_valid_out   : out std_logic;
    busy_to_submodules_out : out std_logic;

    -- Sepatate ports for each submodule
    interrupt_out : out std_logic;

    tx_data_in       : in  std_logic_vector(data_width_c-1 downto 0);
    tx_data_valid_in : in  std_logic;
    tx_re_out        : out std_logic;
    rx_data_out      : out std_logic_vector(data_width_c-1 downto 0);

    rx_data_valid_out : out std_logic;
    rx_re_in          : in  std_logic;

    init_ready_in      : in std_logic;
    init_sleep_time_in : in std_logic_vector(sleep_time_w_c-1 downto 0);


    -- Interface to DM9000A
    eth_data_inout   : inout std_logic_vector(data_width_c-1 downto 0);
    eth_clk_out      : out   std_logic;
    eth_cmd_out      : out   std_logic;
    eth_chip_sel_out : out   std_logic;
    eth_interrupt_in : in    std_logic;
    eth_read_out     : out   std_logic;
    eth_write_out    : out   std_logic;
    eth_reset_out    : out   std_logic
    );

end DM9kA_comm_module;


architecture rtl of DM9kA_comm_module is

  -- WRITING PROCEDURES
  -- *** Step 1, register address
  -- * cmd '0' means writing a configuration register address
  -- * address is byte wide, so upper bits of data are meaningless
  --
  -- *** Step 2, wait for at least a cycle
  -- * write signal must be up at least a cycle after writing the address
  --
  -- *** Step 3, the data
  -- * cmd '1' means that we write to the register selected in step 1
  -- * we can also read the value by pulling down read instead of write
  --
  -- *** Step 4, read if necessary
  -- * if reading, read the value here, else, just do nothing
  --
  -- *** Step 5, another pause
  -- * DM9000A needs a delay of at least 2 cycles after writing to
  --   a configuration register
  --
  -- *** Step 6 (optional), sleep
  -- * sometimes the DM9000A needs a bit more time to do something,
  --   e.g. when PHY is started, it needs time to become fully functional

  type   comm_state_type is (config, write_data, read_data);
  signal comm_state_r : comm_state_type;

  type   conf_state_type is (wait_valid, addr, pause1, write_conf, read_conf, pause2, pause3, sleep);
  signal conf_state_r : conf_state_type;


  -- Arbiter side selects one of the incoming communication requests and feeds
  -- data to these:
  signal register_addr  : std_logic_vector(7 downto 0);
  signal config_data    : std_logic_vector(7 downto 0);
  signal read_not_write : std_logic;    -- 1 = read, 0 = write
  signal config_valid   : std_logic;

  signal comm_grants_r : std_logic_vector(submodules_c-1 downto 0);

  signal tx_data_coming_r : std_logic;
  signal rx_data_coming_r : std_logic;
  signal sleep_cnt_r      : integer;

  signal tx_re_r         : std_logic;
  signal rx_data_valid_r : std_logic;
  signal eth_read_r      : std_logic;


-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  --
  -- concurrent assignments
  -- 
  comm_grants_out   <= comm_grants_r;
  interrupt_out     <= eth_interrupt_in;
  eth_chip_sel_out  <= '0';             -- active low
  eth_clk_out       <= clk;
  eth_reset_out     <= rst_n;
  eth_read_out      <= eth_read_r;
  rx_data_valid_out <= rx_data_valid_r;
  tx_re_out         <= tx_re_r;


  --
  -- Sequential
  --  
  arbitration : process (clk, rst_n)
    variable reserved_v : std_logic;
  begin  -- process arbitration
    if rst_n = '0' then                 -- asynchronous reset (active low)

      comm_grants_r <= (others => '0');
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      reserved_v := '0';

      if init_ready_in = '1' then
        -- can't use 'others' in comparison, so we do it this way
        if comm_grants_r = std_logic_vector(to_unsigned(0, submodules_c)) then

          -- no one is using comm_module right now
          -- lowest index wins
          for n in 0 to submodules_c-1 loop
            if comm_requests_in(n) = '1' then
              if reserved_v = '0' then
                comm_grants_r(n) <= '1';
                reserved_v       := '1';
              end if;
            end if;
          end loop;  -- n

        else

          -- clear grant when request goes out
          for n in 0 to submodules_c-1 loop
            if comm_grants_r(n) = '1' and comm_requests_in(n) = '0' then
              comm_grants_r(n) <= '0';
            end if;
          end loop;  -- n
          
        end if;

      else
        -- no grants during initialization
        comm_grants_r <= (others => '0');
      end if;
      
    end if;
  end process arbitration;

  --
  -- Combinatorial
  --
  submodule_mux : process (comm_grants_r, register_addrs_in, config_datas_in,
                          read_not_write_in, configs_valid_in, init_ready_in)
  begin  -- process submodule_mux

    if init_ready_in = '0' then

      -- init block has the highest index, but it doesn't compete for it's turn
      register_addr  <= register_addrs_in((submodules_c+1)*8 - 1 downto submodules_c*8);
      config_data    <= config_datas_in((submodules_c+1)*8 - 1 downto submodules_c*8);
      read_not_write <= read_not_write_in(submodules_c);
      config_valid   <= configs_valid_in(submodules_c);

    else
      -- init ready, normal arbitration

      -- default:
      register_addr  <= (others => '0');
      config_data    <= (others => '0');
      read_not_write <= '0';
      config_valid   <= '0';

      -- grant signal decides
      for n in 0 to submodules_c-1 loop

        if comm_grants_r(n) = '1' then
          register_addr  <= register_addrs_in((n+1)*8 - 1 downto n*8);
          config_data    <= config_datas_in((n+1)*8 - 1 downto n*8);
          read_not_write <= read_not_write_in(n);
          config_valid   <= configs_valid_in(n);
        end if;
      end loop;  -- n
    end if;
    
  end process submodule_mux;


  --
  -- Sequential process for state machine
  --  
  DM9kA_communication : process (clk, rst_n)
  begin  -- process DM9kA_communication
    if rst_n = '0' then                 -- asynchronous reset (active low)

      eth_write_out  <= '1';
      eth_read_r     <= '1';
      eth_data_inout <= (others => 'Z');
      eth_cmd_out    <= '0';

      data_to_submodules_out <= (others => '0');
      data_to_sb_valid_out   <= '0';
      busy_to_submodules_out <= '0';

      tx_data_coming_r <= '0';
      rx_data_coming_r <= '0';
      sleep_cnt_r      <= 0;

      tx_re_r         <= '0';
      rx_data_valid_r <= '0';

      rx_data_out <= (others => '0');

      -- Should we reset both state regsiters? ES 2012-04-04

      
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- defaults:
      eth_write_out        <= '1';      -- remember, active low
      eth_read_r           <= '1';
      data_to_sb_valid_out <= '0';      -- this is active high

      case comm_state_r is
        when config =>

          -- Configuration needs another FSM to complete all the steps
          case conf_state_r is
            when wait_valid =>

              busy_to_submodules_out <= '0';

              if config_valid = '1' then
                conf_state_r           <= addr;
                busy_to_submodules_out <= '1';
              end if;

            when addr =>

              -- cmd tells the chip that register address coming
              eth_cmd_out    <= '0';
              -- and here comes the address
              eth_data_inout <= x"00" & register_addr;
              -- remember, write and read are active low
              eth_write_out  <= '0';

              -- check if we are planning to start writing/reading tx/rx data
              if register_addr = tx_data_reg_c then
                conf_state_r     <= pause3;
                tx_data_coming_r <= '1';
              elsif register_addr = rx_data_reg_c then
                conf_state_r     <= pause3;
                rx_data_coming_r <= '1';
              else
                conf_state_r <= pause1;
              end if;

              
            when pause1 =>

              -- just 1 clk cycle pause, required by the dm9k device
              conf_state_r <= write_conf;

              
            when write_conf =>

              if read_not_write = '1' then
                -- next we read
                eth_data_inout <= (others => 'Z');
                eth_read_r     <= '0';
                conf_state_r   <= read_conf;
              else
                eth_data_inout <= x"00" & config_data;
                eth_write_out  <= '0';
                conf_state_r   <= pause2;
              end if;

              eth_cmd_out <= '1';

              
            when read_conf =>

              data_to_submodules_out <= eth_data_inout;
              data_to_sb_valid_out   <= '1';
              conf_state_r           <= pause2;

              
            when pause2 =>
              -- DM9kA needs 2 clk cycles after writing/reading to/from data register
              conf_state_r <= pause3;

              if init_ready_in = '1' or
                init_sleep_time_in = std_logic_vector(to_unsigned(0, sleep_time_w_c))
              then
                -- lower busy already here to reduce delays with arbitration
                -- (submodules clear their request signals once busy is down)
                busy_to_submodules_out <= '0';
              end if;

              
            when pause3 =>

              -- if initializing, we might sleep for a while
              if init_ready_in = '0' and
                init_sleep_time_in /= std_logic_vector(to_unsigned(0, sleep_time_w_c))
              then
                conf_state_r <= sleep;
              else
                -- ok, done with this waiting, back to business
                conf_state_r <= wait_valid;

                -- if reg addr was either for tx data or rx data
                if tx_data_coming_r = '1' then
                  comm_state_r <= write_data;
                elsif rx_data_coming_r = '1' then
                  eth_data_inout <= (others => 'Z');
                  comm_state_r   <= read_data;
                end if;

                -- clear both registers
                tx_data_coming_r <= '0';
                rx_data_coming_r <= '0';
              end if;

              
            when sleep =>

              if sleep_cnt_r = to_integer(unsigned(init_sleep_time_in)) then
                sleep_cnt_r  <= 0;
                conf_state_r <= wait_valid;
              elsif sleep_cnt_r = to_integer(unsigned(init_sleep_time_in)) - 1 then
                -- lower busy once cycle earlier
                busy_to_submodules_out <= '0';
                sleep_cnt_r            <= sleep_cnt_r + 1;
              else
                sleep_cnt_r <= sleep_cnt_r + 1;
              end if;
              
            when others => null;
          end case;


        when write_data =>

          -- write data until send submodule lowers the config_valid signal
          if config_valid = '1' then

            if tx_data_valid_in = '1' and tx_re_r = '0' then
              tx_re_r <= '1';
            end if;

            if tx_re_r = '1' then

              tx_re_r        <= '0';
              eth_cmd_out    <= '1';
              eth_data_inout <= tx_data_in;
              eth_write_out  <= '0';
              
            end if;

          else
            -- all written
            comm_state_r <= config;
          end if;

        when read_data =>

          eth_cmd_out <= '1';

          -- Read data until read submodule lowers the config_valid signal.
          -- DM9kA needs 1 clk cycle time after every read signal, so receiving
          -- block can get data every second cycle.
          if config_valid = '1' or rx_data_valid_r = '1' then

            -- remember, eth_read_r is active low
            if rx_data_valid_r = '0' and eth_read_r = '1' then
              eth_read_r <= '0';
            end if;

            if eth_read_r = '0' then
              rx_data_out     <= eth_data_inout;
              rx_data_valid_r <= '1';
            end if;

            if rx_re_in = '1' and rx_data_valid_r = '1' then
              rx_data_valid_r <= '0';

              if config_valid = '1' then
                eth_read_r <= '0';
              end if;
            end if;

          else
            -- all read
            eth_cmd_out  <= '0';
            comm_state_r <= config;
          end if;
          
        when others => null;
      end case;
    end if;
  end process DM9kA_communication;
  







  
end rtl;
