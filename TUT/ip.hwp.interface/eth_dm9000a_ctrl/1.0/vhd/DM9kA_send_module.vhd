-------------------------------------------------------------------------------
-- Title      : DM9kA controller, sender module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DM9kA_send_module.vhd
-- Author     : Jussi Nieminen  <niemin95@galapagosinkeiju.cs.tut.fi>
-- Last update: 2012-04-04
-------------------------------------------------------------------------------
-- Description: Handles sending procedures application -> eth
-- Includes a state machine where two states (init and done) include their own
-- sub-state machines.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/25  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.DM9kA_ctrl_pkg.all;


entity DM9kA_send_module is
  
  port (
    clk                     : in  std_logic;
    rst_n                   : in  std_logic;
    -- from interrupt handler
    tx_completed_in         : in  std_logic;
    -- to and from comm module
    comm_req_out            : out std_logic;
    comm_grant_in           : in  std_logic;
    reg_addr_out            : out std_logic_vector(7 downto 0);
    config_data_out         : out std_logic_vector(7 downto 0);
    read_not_write_out      : out std_logic;
    config_valid_out        : out std_logic;
    data_from_comm_in       : in  std_logic_vector(data_width_c-1 downto 0);
    data_from_comm_valid_in : in  std_logic;
    comm_busy_in            : in  std_logic;
    -- to comm module
    tx_data_out             : out std_logic_vector(data_width_c-1 downto 0);
    tx_data_valid_out       : out std_logic;
    tx_re_in                : in  std_logic;
    -- from upper level
    tx_data_in              : in  std_logic_vector(data_width_c-1 downto 0);
    tx_data_valid_in        : in  std_logic;
    tx_re_out               : out std_logic;
    tx_MAC_addr_in          : in  std_logic_vector(47 downto 0);
    new_tx_in               : in  std_logic;
    tx_len_in               : in  std_logic_vector(tx_len_w_c-1 downto 0);
    tx_frame_type_in        : in  std_logic_vector(15 downto 0)
    );

end DM9kA_send_module;


architecture rtl of DM9kA_send_module is

  -- There are 3 state machines.
  -- not much to initialize, but our own MAC we must get
  type   init_state_type is (get_MAC, done);
  signal init_state_r : init_state_type;

  -- This FSM is used during init to read mac addr
  type   conf_state_type is (write_conf, read_reply, wait_busy);
  signal conf_state_r : conf_state_type;

  -- counter used when getting the MAC address
  signal addr_cnt_r : integer range 0 to MAC_len_c-1;

  -- vhdl doesn't understand signals indexing std_logic_vectors, so we have to
  -- do this:
  type MAC_addr_type is array (0 to MAC_len_c-1) of std_logic_vector(7 downto 0);

  signal own_MAC_r  : MAC_addr_type;
  signal trgt_MAC_r : MAC_addr_type;

  -- This FSM is used in normal operation
  type tx_state_type is (wait_tx, conf_len_hi, conf_len_lo, conf_tx_reg,
                         write_trgt_MAC, write_own_MAC, write_frame_type,
                         count_data, send_cmd);
  signal tx_state_r : tx_state_type;


  
  signal tx_len_r      : std_logic_vector(tx_len_w_c-1 downto 0);
  signal tx_len_int    : integer range 0 to 2**tx_len_w_c-1;
  signal tx_data_cnt_r : integer range 0 to 2**tx_len_w_c-1;

  signal tx_data_r       : std_logic_vector(data_width_c-1 downto 0);
  signal tx_data_valid_r : std_logic;

  signal comm_req_r       : std_logic;
  signal start_counting_r : std_logic;

  -- there can be maximum of 2 transfers at a time
  signal tx_count_r : integer range 0 to 2;


-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  --
  -- Combinatorial process
  -- switch between inner registers and data input
  -- 
  tx_data_mux : process (tx_data_in, tx_data_valid_in, tx_state_r,
                        tx_data_r, tx_data_valid_r, tx_re_in)
  begin  -- process tx_data_mux

    if tx_state_r /= count_data then
      -- writing ethernet frame headers
      tx_data_out       <= tx_data_r;
      tx_data_valid_out <= tx_data_valid_r;
      -- no re to upper level
      tx_re_out         <= '0';

    else
      -- writing payload
      tx_data_out       <= tx_data_in;
      tx_data_valid_out <= tx_data_valid_in;
      tx_re_out         <= tx_re_in;
      
    end if;
  end process tx_data_mux;

  comm_req_out <= comm_req_r;
  tx_len_int   <= to_integer(unsigned(tx_len_r));


  --
  -- Sequential process for state machine
  --
  main : process (clk, rst_n)

    -- helping with odd length transfers
    variable odd_len_compensation_v : integer range 0 to 1;
    
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)

      init_state_r <= get_MAC;
      tx_state_r   <= wait_tx;
      conf_state_r <= write_conf;

      own_MAC_r  <= (others => (others => '0'));
      trgt_MAC_r <= (others => (others => '0'));
      addr_cnt_r <= 0;

      reg_addr_out       <= (others => '0');
      config_data_out    <= (others => '0');
      config_valid_out   <= '0';
      read_not_write_out <= '0';

      comm_req_r       <= '0';
      tx_data_r        <= (others => '0');
      tx_data_valid_r  <= '0';
      tx_len_r         <= (others => '0');
      start_counting_r <= '0';
      tx_count_r       <= 0;
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- decrease counter when a tx is completed
      if tx_completed_in = '1' then
        tx_count_r <= tx_count_r - 1;
      end if;



      case init_state_r is
        -----------------------------------------------------------------------
        -- Getting our own MAC address, needs another state machine
        when get_MAC =>

          comm_req_r <= '1';

          if comm_grant_in = '1' then
            -- sender has comm modules attention
            
            case conf_state_r is
              when write_conf =>

                -- MAC address is in registers x'10 -> x'15
                reg_addr_out       <= std_logic_vector(unsigned(MAC6_c) - to_unsigned(addr_cnt_r, 8));
                read_not_write_out <= '1';
                config_valid_out   <= '1';

                -- when busy comes up, comm module has started working
                if comm_busy_in = '1' then
                  conf_state_r <= read_reply;
                end if;

              when read_reply =>

                if data_from_comm_valid_in = '1' then
                  own_MAC_r(addr_cnt_r) <= data_from_comm_in(7 downto 0);
                  conf_state_r          <= wait_busy;
                end if;

              when wait_busy =>

                if comm_busy_in = '0' then

                  if addr_cnt_r = MAC_len_c-1 then
                    init_state_r     <= done;
                    addr_cnt_r       <= 0;
                    comm_req_r       <= '0';
                    config_valid_out <= '0';
                  else
                    addr_cnt_r <= addr_cnt_r + 1;
                  end if;
                  conf_state_r <= write_conf;
                  
                end if;
              when others => null;
            end case;
          end if;
          -----------------------------------------------------------------------
          -- MAC address received, moving on
          
        when done =>
          -- init done, meaning normal operation

          -- new_tx_in, tx_len_in and tx_MAC_addr_in must remain stable until
          -- the first data is read from the upper level.

          -- tx state machine
          case tx_state_r is
            when wait_tx =>

              -- new transfer waiting, and less than 2 on the way
              if new_tx_in = '1' and tx_count_r /= 2 then
                -- add here checking of number of on-going txs

                comm_req_r <= '1';
                tx_len_r   <= std_logic_vector(unsigned(tx_len_in) + to_unsigned(eth_header_len_c, tx_len_w_c));

                for n in 0 to MAC_len_c-1 loop
                  trgt_MAC_r(n) <= tx_MAC_addr_in((n+1)*8-1 downto n*8);
                end loop;  -- n

                if comm_grant_in = '1' and comm_req_r = '1' then
                  -- increase number of txs
                  tx_count_r <= tx_count_r + 1;
                  tx_state_r <= conf_len_hi;
                end if;
              end if;

            when conf_len_hi =>

              -- write high part of the tx len
              case conf_state_r is
                when write_conf =>

                  reg_addr_out                             <= TXPLH_c;
                  -- upper bits remain zero while lower ones get the values of
                  -- higher tx len bits
                  config_data_out                          <= (others => '0');
                  config_data_out(tx_len_w_c-8-1 downto 0) <= tx_len_r(tx_len_w_c-1 downto 8);
                  read_not_write_out                       <= '0';
                  config_valid_out                         <= '1';

                  if comm_busy_in = '1' then
                    conf_state_r <= wait_busy;
                  end if;

                when wait_busy =>

                  if comm_busy_in = '0' then
                    config_valid_out <= '0';
                    conf_state_r     <= write_conf;
                    tx_state_r       <= conf_len_lo;
                  end if;
                  
                when others => null;
              end case;

            when conf_len_lo =>

              -- write lower part of the tx len
              case conf_state_r is
                when write_conf =>

                  reg_addr_out       <= TXPLL_c;
                  config_data_out    <= tx_len_r(7 downto 0);
                  read_not_write_out <= '0';
                  config_valid_out   <= '1';

                  if comm_busy_in = '1' then
                    conf_state_r <= wait_busy;
                  end if;

                when wait_busy =>

                  if comm_busy_in = '0' then
                    config_valid_out <= '0';
                    conf_state_r     <= write_conf;
                    tx_state_r       <= conf_tx_reg;
                  end if;
                  
                when others => null;
              end case;


            when conf_tx_reg =>

              -- when the address of tx register is written, comm module
              -- automagically switches to tx mode and starts receiving tx data
              -- until config_valid_out signal is lowered.

              reg_addr_out       <= tx_data_reg_c;
              read_not_write_out <= '0';
              config_valid_out   <= '1';

              -- when comm busy, move to send phase
              if comm_busy_in = '1' then
                tx_state_r <= write_trgt_MAC;
                addr_cnt_r <= 0;
              end if;


            when write_trgt_MAC =>

              -- write two bytes of address at once (MSB first)
              tx_data_r <= trgt_MAC_r(MAC_len_c - 2*addr_cnt_r - 2)
                           & trgt_MAC_r(MAC_len_c - 2*addr_cnt_r - 1);
              tx_data_valid_r <= '1';

              -- when comm reads, increase counter or move on
              if tx_re_in = '1' then
                if addr_cnt_r = MAC_len_c/2 - 1 then
                  tx_data_valid_r <= '0';
                  addr_cnt_r      <= 0;
                  tx_state_r      <= write_own_MAC;
                else
                  addr_cnt_r <= addr_cnt_r + 1;
                end if;
              end if;


            when write_own_MAC =>

              tx_data_r <= own_MAC_r(MAC_len_c - 2*addr_cnt_r - 2)
                           & own_MAC_r(MAC_len_c - 2*addr_cnt_r - 1);
              tx_data_valid_r <= '1';

              -- when comm reads, increase counter or move on
              if tx_re_in = '1' then
                if addr_cnt_r = MAC_len_c/2 - 1 then
                  tx_data_valid_r <= '0';
                  addr_cnt_r      <= 0;
                  tx_state_r      <= write_frame_type;
                else
                  addr_cnt_r <= addr_cnt_r + 1;
                end if;
              end if;


            when write_frame_type =>

              tx_data_r       <= tx_frame_type_in(7 downto 0) & tx_frame_type_in(15 downto 8);
              tx_data_valid_r <= '1';

              if tx_re_in = '1' then
                -- the tx_data mux now switches the output, so we can clear
                -- these registers
                tx_data_r        <= (others => '0');
                tx_data_valid_r  <= '0';
                tx_data_cnt_r    <= 0;
                start_counting_r <= '1';
              end if;

              -- delay, so that changing input of tx_re_out doesn't cause a glitch
              if start_counting_r = '1' then
                tx_data_r        <= (others => '0');
                tx_data_valid_r  <= '0';
                tx_data_cnt_r    <= 0;
                start_counting_r <= '0';
                tx_state_r       <= count_data;
              end if;


            when count_data =>
              -- data comes straight from the upper level, just count how much
              -- has been sent and stop the transmission in time

              if tx_re_in = '1' then

                -- tx len in bytes but writing words, that's why the division
                -- by two
                odd_len_compensation_v := to_integer(unsigned(tx_len_r(0 downto 0)));
                if tx_data_cnt_r = (tx_len_int - eth_header_len_c) / 2 - 1 + odd_len_compensation_v then
                  -- All sent. Notify the comm module by lowering the config_valid_out
                  config_valid_out <= '0';
                  tx_data_cnt_r    <= 0;

                  -- request send if constant says so (if DM9kA is configured
                  -- to start sending in advance, there is no need to raise the
                  -- tx request bit)
                  if send_cmd_en_c = 1 then
                    tx_state_r <= send_cmd;
                  else
                    tx_state_r <= wait_tx;
                    comm_req_r <= '0';
                  end if;
                  
                else
                  tx_data_cnt_r <= tx_data_cnt_r + 1;
                end if;
              end if;

              
            when send_cmd =>

              -- feed in send cmd
              case conf_state_r is
                when write_conf =>

                  reg_addr_out       <= TCR_c;
                  -- start tx
                  config_data_out    <= x"01";
                  read_not_write_out <= '0';
                  config_valid_out   <= '1';

                  if comm_busy_in = '1' then
                    conf_state_r <= wait_busy;
                  end if;

                when wait_busy =>

                  if comm_busy_in = '0' then
                    config_valid_out <= '0';
                    conf_state_r     <= write_conf;
                    tx_state_r       <= wait_tx;
                    comm_req_r       <= '0';
                  end if;
                  
                when others => null;
              end case;
              
              
            when others => null;
          end case;  -- tx_state_r
        when others => null;
      end case;  -- init_state_r
    end if;
  end process main;
  

end rtl;
