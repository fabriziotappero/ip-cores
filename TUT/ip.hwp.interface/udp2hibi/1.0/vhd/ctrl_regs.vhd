-------------------------------------------------------------------------------
-- Title      : Control registers
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : ctrl_regs.vhd
-- Author     : Jussi Nieminen
-- Last update: 2012-03-22
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Keep track of current sender and update a table with receiver
--              information.
--              Only 1 tx (fpga -> outside world) at a time,
--              but generic number of rx-operations.
--              
--              ES 2012-03-22: Check if there is a bug in table_valid.
--              That note is marked with "!!!", approx. at line 229
--              
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/08  1.0      niemin95        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.udp2hibi_pkg.all;


entity ctrl_regs is

  generic (
    receiver_table_size_g : integer := 4;
    hibi_addr_width_g     : integer := 32
    );

  port (
    clk                : in  std_logic;
    rst_n              : in  std_logic;

    -- from hibi_receiver, new configurations
    release_lock_in    : in  std_logic;
    new_tx_conf_in     : in  std_logic;
    new_rx_conf_in     : in  std_logic;
    ip_in              : in  std_logic_vector( ip_addr_w_c-1 downto 0 );
    dest_port_in       : in  std_logic_vector( udp_port_w_c-1 downto 0 );
    source_port_in     : in  std_logic_vector( udp_port_w_c-1 downto 0 );
    lock_addr_in       : in  std_logic_vector( hibi_addr_width_g-1 downto 0 );
    response_addr_in   : in  std_logic_vector( hibi_addr_width_g-1 downto 0 );
    lock_out           : out std_logic;
    lock_addr_out      : out std_logic_vector( hibi_addr_width_g-1 downto 0 );

    -- to tx_ctrl, config params for sending
    tx_ip_out          : out std_logic_vector( ip_addr_w_c-1 downto 0 );
    tx_dest_port_out   : out std_logic_vector( udp_port_w_c-1 downto 0 );
    tx_source_port_out : out std_logic_vector( udp_port_w_c-1 downto 0 );
    timeout_release_in : in  std_logic;

    -- from rx_ctrl, params of the received ip packet
    rx_ip_in           : in  std_logic_vector( ip_addr_w_c-1 downto 0 );
    rx_dest_port_in    : in  std_logic_vector( udp_port_w_c-1 downto 0 );
    rx_source_port_in  : in  std_logic_vector( udp_port_w_c-1 downto 0 );
    rx_addr_valid_out  : out std_logic;

    -- to hibi_transmitter, send acknowledges
    ack_addr_out       : out std_logic_vector( hibi_addr_width_g-1 downto 0 );
    rx_addr_out        : out std_logic_vector( hibi_addr_width_g-1 downto 0 );
    send_tx_ack_out    : out std_logic;
    send_tx_nack_out   : out std_logic;
    send_rx_ack_out    : out std_logic;
    send_rx_nack_out   : out std_logic;
    
    -- from toplevel
    eth_link_up_in     : in  std_logic
    );

end ctrl_regs;


architecture rtl of ctrl_regs is

  -- Wildcards
  constant any_ip_c   : std_logic_vector( ip_addr_w_c-1 downto 0 )  := x"FFFFFFFF";
  constant any_port_c : std_logic_vector( udp_port_w_c-1 downto 0 ) := x"FFFF";

  
  -- Registers holding current tx info
  signal current_ip_r          : std_logic_vector(ip_addr_w_c-1 downto 0);
  signal current_dest_port_r   : std_logic_vector(udp_port_w_c-1 downto 0);
  signal current_source_port_r : std_logic_vector(udp_port_w_c-1 downto 0);

  -- Tx lock information
  signal locked_r : std_logic;
  signal lock_addr_r : std_logic_vector( hibi_addr_width_g-1 downto 0 );
  
  
  -- Table for rx receivers (each agent willing to receive data will have to
  -- register its hibi address to some source ip and ports)
  type receiver_info_type is
    record
      source_ip   : std_logic_vector(ip_addr_w_c-1 downto 0);
      source_port : std_logic_vector(udp_port_w_c-1 downto 0);
      dest_port   : std_logic_vector(udp_port_w_c-1 downto 0);
      hibi_addr   : std_logic_vector(hibi_addr_width_g-1 downto 0);
    end record;
  type     receiver_table_type is array (0 to receiver_table_size_g-1) of receiver_info_type;
  signal   receiver_table_r    : receiver_table_type;
  -- validness
  signal   table_valid_array_r : std_logic_vector(receiver_table_size_g-1 downto 0);
  -- to easily compare if full:
  constant table_full_c        : std_logic_vector(receiver_table_size_g-1 downto 0) := (others => '1');



  
-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  lock_out      <= locked_r;
  lock_addr_out <= lock_addr_r;
  tx_ip_out     <= current_ip_r;
  
  tx_dest_port_out   <= current_dest_port_r;
  tx_source_port_out <= current_source_port_r;

  -----------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------
  main: process (clk, rst_n)
    variable spot_found_v : std_logic;
    variable match_found_v : std_logic;
  begin  -- process main
    if rst_n = '0' then                 -- asynchronous reset (active low)
      
      current_source_port_r <= (others => '0');
      current_dest_port_r   <= (others => '0');
      current_ip_r          <= (others => '0');
      locked_r              <= '0';
      lock_addr_r           <= (others => '0');
      table_valid_array_r   <= (others => '0');
      receiver_table_r      <= (others => ( (others => '0'), (others => '0'), (others => '0'), (others => '0') ));

      send_rx_nack_out  <= '0';
      send_rx_ack_out   <= '0';
      send_tx_nack_out  <= '0';
      send_tx_ack_out   <= '0';
      ack_addr_out      <= (others => '0');
      rx_addr_out       <= (others => '0');
      rx_addr_valid_out <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- default values
      send_tx_ack_out  <= '0';
      send_tx_nack_out <= '0';
      send_rx_ack_out  <= '0';
      send_rx_nack_out <= '0';

      

      -------------------------------------------------------------------------
      -- Handle the configuration requests
      -------------------------------------------------------------------------
      if new_tx_conf_in = '1' then
        -- New tx conf coming. Ensure that is not already locked at all, or
        -- locked to the same address, and then update values and send ack.
        -- Otherwise send nack.

        if ( locked_r = '0' or lock_addr_r = lock_addr_in )
          and eth_link_up_in = '1'
        then
          -- accept configuration
          current_ip_r          <= ip_in;
          current_dest_port_r   <= dest_port_in;
          current_source_port_r <= source_port_in;
          lock_addr_r           <= lock_addr_in;
          locked_r              <= '1';

          -- send ack
          send_tx_ack_out <= '1';

        else
          -- reject configuration attempt
          send_tx_nack_out <= '1';
        end if;

        ack_addr_out <= response_addr_in;

        
      elsif new_rx_conf_in = '1' then
        -- New rx conf coming. Check if there's room in the table, and store
        -- information if possible. Otherwise send a nack.

        -- Check if table full
        if table_valid_array_r = table_full_c then
          -- send a nack
          send_rx_nack_out <= '1';
        else

          -- Find an empty spot
          spot_found_v := '0';
          for n in 0 to receiver_table_size_g-1 loop
            if table_valid_array_r(n) = '0' and spot_found_v = '0' then
              -- Put it here, to smallest empty spot
              receiver_table_r(n).source_ip   <= ip_in;
              receiver_table_r(n).source_port <= source_port_in;
              receiver_table_r(n).dest_port   <= dest_port_in;
              receiver_table_r(n).hibi_addr   <= response_addr_in;
              table_valid_array_r(n)          <= '1';
              
              spot_found_v := '1';
            end if;
          end loop;  -- n

          send_rx_ack_out <= '1';
          
        end if;

        ack_addr_out <= response_addr_in;

        
      elsif release_lock_in = '1' then
        -- Release tx lock if requested
        locked_r    <= '0';
      end if;
      -- /conf requests


      
      -- !!! ES 2012-03-22
      -- It seems that signal table_valid_array_r(n) is never
      -- assigned to '0' after reset? Once the table gets full,
      -- there is not way to get more room.
      -- !!!

      
      -------------------------------------------------------------------------
      -- Address translation to rx address (hibi addr) according to info
      -- provided by rx_ctrl.
      -- Check that all 3 fields: src ip addr, src port and dst port match.
      -- Wildcards are accepted.
      -------------------------------------------------------------------------
      match_found_v := '0';
      for n in 0 to receiver_table_size_g-1 loop
        if table_valid_array_r(n) = '1'
          and (rx_ip_in = receiver_table_r(n).source_ip
                or
                receiver_table_r(n).source_ip = any_ip_c)
          and (rx_source_port_in = receiver_table_r(n).source_port
                or
                receiver_table_r(n).source_port = any_port_c)
          and (rx_dest_port_in = receiver_table_r(n).dest_port
                or
                receiver_table_r(n).dest_port = any_port_c)
        then
          rx_addr_out   <= receiver_table_r(n).hibi_addr;
          match_found_v := '1';
        end if;
      end loop;  -- n

      if match_found_v = '1' then
        rx_addr_valid_out <= '1';
      else
        rx_addr_valid_out <= '0';
      end if;
      
      -------------------------------------------------------------------------
      -- If timeout occures during a tx, tx_ctrl notifies about it and lock
      -- must be released in order to reset hibi_receiver's state
      -------------------------------------------------------------------------
      if timeout_release_in = '1' then
        locked_r <= '0';
      end if;
      
    end if;
  end process main;

  

end rtl;
