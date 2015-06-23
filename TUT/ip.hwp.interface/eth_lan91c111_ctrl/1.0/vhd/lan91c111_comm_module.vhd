-------------------------------------------------------------------------------
-- Title      : Communication module for the LAN91C111 controller
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Lan91c111_comm_module.vhd
-- Author     : Jussi Nieminen, Antti Alhonen
-- Last update: 2011-11-06
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/08/21  1.0      niemin95        Created
-- 2011/07/17  2.0      alhonena        Modified for LAN91C111
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lan91c111_ctrl_pkg.all;

entity lan91c111_comm_module is
  port (
    clk                    : in    std_logic;  -- 25 MHz
    rst_n                  : in    std_logic;
    comm_requests_in       : in    std_logic_vector( submodules_c-1 downto 0 );
    comm_grants_out        : out   std_logic_vector( submodules_c-1 downto 0 );
    interrupt_out          : out   std_logic;
    init_ready_in          : in    std_logic;
    -- interface to submodules (and to init block)
    register_addrs_in      : in    std_logic_vector( (submodules_c+1) * real_addr_width_c - 1 downto 0 );  -- from each submodule
    config_datas_in        : in    std_logic_vector( (submodules_c+1) * lan91_data_width_c - 1 downto 0 );
    config_nBEs_in         : in    std_logic_vector( (submodules_c+1) * 4 - 1 downto 0 );
    read_not_write_in      : in    std_logic_vector( submodules_c downto 0 );
    configs_valid_in       : in    std_logic_vector( submodules_c downto 0 );
    data_to_submodules_out : out   std_logic_vector( lan91_data_width_c - 1 downto 0 );
    data_to_sb_valid_out   : out   std_logic;
    busy_to_submodules_out : out   std_logic;
    -- interface to LAN91C111
    eth_data_inout         : inout std_logic_vector( lan91_data_width_c-1 downto 0 );
    eth_addr_out           : out   std_logic_vector( lan91_addr_width_c-1 downto 0 );
    eth_interrupt_in       : in    std_logic;
    eth_read_out           : out   std_logic;
    eth_write_out          : out   std_logic;
    eth_nADS_out           : out   std_logic;
    eth_nAEN_out           : out   std_logic;
    eth_nBE_out            : out   std_logic_vector(3 downto 0)
    );

end lan91c111_comm_module;


architecture rtl of lan91c111_comm_module is

  -- Major change compared to DM9000A controller by Jussi Nieminen;
  -- Data muxes between "config_data", "tx data" and "rx data" have
  -- been moved completely to the Send and Read modules; this module takes only
  -- one type of input from Send and Read, not two types. Hence, this
  -- module is simplified a lot.
  -- The major reason for the change is that whereas DM9000A does not include
  -- "register address" for every write/read operation, LAN91C111 does; all
  -- data is accessed via a single register address, pointed by a separate
  -- pointer register with its own address.
  
  -- WRITING AND READING PROCEDURES by comm_state_r
  -- wait_valid:
  -- Wait until one of the submodules wants to write or read. Immediately put
  -- the address (and data in case of write) on the busses and go to write_data
  -- or read_data, which asserts write or read enable signal to the chip.
  --
  -- write_data:
  -- Set write_out low. Go to data_written.
  --
  -- read_data:
  -- Set read_out low. Go to data_read.
  --
  -- data_written:
  -- Set write_out high. Go to wait_valid.
  --
  -- data_read:
  -- Read the data. Set read_out high. Go to wait_valid.
  --
  -- Example of the read operation:
  --                  |1 |2 |3 |4 |5 |6 |
  -- config_valid_in  ___----------------
  -- readnotwrite     ___----------------
  -- addr_out         xxxxxx< ADDR  >xxxx  (valid for 3 cycles)
  -- data_out         xxxxxxZZZZZZZZZxxxx  (valid for 3 cycles)
  -- nEth_read_out    ---------___------   (1 cycle long in the middle)
  -- Read data here:             <>        (on the rising edge of read enable signal)
  --
  -- Example of the write operation:
  --                  |1 |2 |3 |4 |5 |6 |
  -- config_valid_in  ___----------------
  -- readnotwrite     ___________________
  -- addr_out         xxxxxx< ADDR  >xxxx  (valid for 3 cycles)
  -- data_out         xxxxxx< DATA  >xxxx  (valid for 3 cycles)
  -- nEth_write_out   ---------___------   (1 cycle long in the middle)

  
  type comm_state_type is (wait_valid, write_data, data_written, read_data, data_read);
  signal comm_state_r : comm_state_type;
  
  -- Arbiter side selects one of the incoming communication requests and feeds
  -- data to these:
  signal register_addr  : std_logic_vector( real_addr_width_c-1 downto 0 );
  signal config_data    : std_logic_vector( lan91_data_width_c-1 downto 0 );
  signal config_nBE : std_logic_vector( 3 downto 0 );
  signal read_not_write : std_logic;    -- 1 = read, 0 = write
  signal config_valid   : std_logic;

  signal comm_grants_r : std_logic_vector( submodules_c-1 downto 0 );
  
-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  -- concurrent assignments
  comm_grants_out   <= comm_grants_r;
  interrupt_out     <= eth_interrupt_in;
  eth_nADS_out      <= '0';
  eth_nAEN_out      <= '0';
  
  arbitration: process (clk, rst_n)
    variable reserved_v : std_logic;
  begin  -- process arbitration
    if rst_n = '0' then                 -- asynchronous reset (active low)

      comm_grants_r <= (others => '0');
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      reserved_v := '0';

      if init_ready_in = '1' then
        -- can't use 'others' in comparison, so we do it this way
        if comm_grants_r = std_logic_vector( to_unsigned( 0, submodules_c )) then
        
          -- no one is using comm_module right now
          -- lowest index wins
          for n in 0 to submodules_c-1 loop
            if comm_requests_in(n) = '1' then
              if reserved_v = '0' then
                comm_grants_r(n) <= '1';
                reserved_v := '1';
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


  submodule_mux: process (comm_grants_r, register_addrs_in, config_datas_in, config_nBEs_in,
                          read_not_write_in, configs_valid_in, init_ready_in)
  begin  -- process submodule_mux

    if init_ready_in = '0' then

      -- init block has the highest index, but it doesn't compete for it's turn
      register_addr <= register_addrs_in( (submodules_c+1)*real_addr_width_c - 1 downto submodules_c*real_addr_width_c );
      config_data <= config_datas_in( (submodules_c+1)*lan91_data_width_c - 1 downto submodules_c*lan91_data_width_c );
      config_nBE  <= config_nBEs_in( (submodules_c+1)*4 - 1 downto submodules_c*4 );
      read_not_write <= read_not_write_in( submodules_c );
      config_valid <= configs_valid_in( submodules_c );

    else
      -- init ready, normal arbitration

      -- default:
      register_addr <= (others => '0');
      config_data <= (others => '0');
      config_nBE <= (others => '0');
      read_not_write <= '0';
      config_valid <= '0';

      -- grant signal decides
      for n in 0 to submodules_c-1 loop

        if comm_grants_r(n) = '1' then
          register_addr <= register_addrs_in( (n+1)*real_addr_width_c - 1 downto n*real_addr_width_c );
          config_data <= config_datas_in( (n+1)*lan91_data_width_c - 1 downto n*lan91_data_width_c );
          config_nBE <= config_nBEs_in( (n+1)*4 - 1 downto n*4 );
          read_not_write <= read_not_write_in(n);
          config_valid <= configs_valid_in(n);
        end if;
      end loop;  -- n
    end if;
    
  end process submodule_mux;


  lan91c111_communication: process (clk, rst_n)
  begin  -- process lan91c111_communication
    if rst_n = '0' then                 -- asynchronous reset (active low)

      eth_write_out  <= '1';
      eth_read_out     <= '1';
      eth_data_inout <= (others => 'Z');

      data_to_submodules_out <= (others => '0');
      data_to_sb_valid_out   <= '0';
      busy_to_submodules_out <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- defaults:
      eth_write_out        <= '1';        -- remember, active low
      eth_read_out         <= '1';
      data_to_sb_valid_out <= '0';        -- this is active high
      
      case comm_state_r is
        when wait_valid =>
          busy_to_submodules_out <= '0';

          if config_valid = '1' then
            busy_to_submodules_out <= '1';
            eth_addr_out <= base_addr_c & register_addr;
            if read_not_write = '1' then
              eth_data_inout <= (others => 'Z');
              comm_state_r <= read_data;
            else
              eth_data_inout <= config_data;
              comm_state_r <= write_data;
            end if;

            eth_nBE_out <= config_nBE;
            
          end if;

        when write_data =>
          eth_write_out <= '0';
          comm_state_r <= data_written;

        when data_written =>
          busy_to_submodules_out <= '0';
          comm_state_r <= wait_valid;

        when read_data =>
          eth_read_out <= '0';
          comm_state_r <= data_read;

        when data_read =>
          busy_to_submodules_out <= '0';
          -- read the data here:
          data_to_submodules_out <= eth_data_inout;
          data_to_sb_valid_out <= '1';  -- It is important that the
                                        -- busy_to_submodules_out goes low no
                                        -- later than valid goes high.
                                        -- Currently, the other modules rely on
                                        -- that to simplify the state machines.

          -- Also note that data_to_sb_valid_out is high only for one clock cycle
          -- and you must read the data immediately.

          -- eth_data_inout is left in high-impedance state. If needed for some
          -- reason, you can write something else to it here.
          comm_state_r <= wait_valid;
          
        when others => null;
      end case;
    end if;
  end process lan91c111_communication;
  
end rtl;
