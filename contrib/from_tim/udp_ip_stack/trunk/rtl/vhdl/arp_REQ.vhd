----------------------------------------------------------------------------------
-- Company: 
-- Engineer:            Peter Fall
-- 
-- Create Date:    12:00:04 05/31/2011 
-- Design Name: 
-- Module Name:    arp_REQ - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:
--              handle requests for ARP resolution
--              responds from single entry cache or searches external arp store, or asks to send a request
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created from arp.vhd 0.2
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.arp_types.all;

entity arp_req is
  generic (
    no_default_gateway : boolean := true;  -- set to false if communicating with devices accessed
                                            -- through a "default gateway or router"
    CLOCK_FREQ      : integer := 125000000;  -- freq of data_in_clk -- needed to timout cntr
    ARP_TIMEOUT     : integer := 60;    -- ARP response timeout (s)
    ARP_MAX_PKT_TMO : integer := 5      -- # wrong nwk pkts received before set error
    );
  port (
    -- lookup request signals
    arp_req_req      : in  arp_req_req_type;   -- request for a translation from IP to MAC
    arp_req_rslt     : out arp_req_rslt_type;  -- the result
    -- external arp store signals
    arp_store_req    : out arp_store_rdrequest_t;          -- requesting a lookup or store
    arp_store_result : in  arp_store_result_t;             -- the result
    -- network request signals
    arp_nwk_req      : out arp_nwk_request_t;  -- requesting resolution via the network
    arp_nwk_result   : in  arp_nwk_result_t;   -- the result
    -- system signals
    clear_cache      : in  std_logic;   -- clear the internal cache
    nwk_gateway      : in  std_logic_vector(31 downto 0);  -- IP address of default gateway
    nwk_mask         : in  std_logic_vector(31 downto 0);  -- Net mask
    clk              : in  std_logic;
    reset            : in  std_logic
    );
end arp_req;

architecture Behavioral of arp_req is

  type req_state_t is (IDLE, LOOKUP, WAIT_REPLY, PAUSE1, PAUSE2, PAUSE3);
  type set_cntr_t is (HOLD, CLR, INCR);
  type set_clr_type is (SET, CLR, HOLD);

  -- state variables
  signal req_state       : req_state_t;
  signal req_ip_addr     : std_logic_vector (31 downto 0);  -- IP address to lookup
  signal arp_entry_cache : arp_entry_t;           -- single entry cache for fast response
  signal cache_valid     : std_logic;   -- single entry cache is valid
  signal nwk_rx_cntr     : unsigned(7 downto 0);  -- counts nwk rx pkts that dont satisfy
  signal freq_scaler     : unsigned (31 downto 0);          -- scales data_in_clk downto 1Hz
  signal timer           : unsigned (7 downto 0);           -- counts seconds timeout
  signal timeout_reg     : std_logic;

  -- busses
  signal next_req_state : req_state_t;
  signal arp_entry_val  : arp_entry_t;

  -- requester control signals
  signal set_req_state     : std_logic;
  signal set_req_ip        : std_logic;
  signal store_arp_cache   : std_logic;
  signal set_nwk_rx_cntr   : set_cntr_t;
  signal set_timer         : set_cntr_t;    -- timer reset, count, hold control
  signal timer_enable      : std_logic;     -- enable the timer counting
  signal set_timeout       : set_clr_type;  -- control the timeout register
  signal clear_cache_valid : std_logic;

  signal l_arp_req_req_ip : std_logic_vector(31 downto 0);  -- local network IP address for resolution

begin

  default_GW: if (not no_default_gateway) generate
    default_gw_comb_p: process (arp_req_req.ip, nwk_gateway, nwk_mask) is
    begin  -- process default_gw_comb_p
      -- translate IP addresses to local IP address if necessary
      if ((nwk_mask and arp_req_req.ip) = (nwk_mask and nwk_gateway)) then
        -- on local network
        l_arp_req_req_ip <= arp_req_req.ip;
      else
        -- on remote network
        l_arp_req_req_ip <= nwk_gateway;
      end if;
    end process default_gw_comb_p;
  end generate default_GW;
  
  no_default_GW: if (no_default_gateway) generate
    no_default_gw_comb_p: process (arp_req_req.ip) is
    begin  -- process no_default_gw_comb_p
      l_arp_req_req_ip <= arp_req_req.ip;
    end process no_default_gw_comb_p;
  end generate no_default_GW;

  req_combinatorial : process (
    arp_entry_cache.ip, arp_entry_cache.mac, arp_nwk_result.entry, arp_nwk_result.entry.ip,
    arp_nwk_result.entry.mac, arp_nwk_result.status, arp_req_req.lookup_req,
    arp_store_result.entry, arp_store_result.entry.mac, arp_store_result.status, cache_valid,
    clear_cache, freq_scaler, l_arp_req_req_ip, nwk_rx_cntr, req_ip_addr, req_state,
    timeout_reg, timer)
  begin
    -- set output followers
    arp_req_rslt.got_mac <= '0';        -- set initial value of request result outputs
    arp_req_rslt.got_err <= '0';
    arp_req_rslt.mac     <= (others => '0');
    arp_store_req.req    <= '0';
    arp_store_req.ip     <= (others => '0');
    arp_nwk_req.req      <= '0';
    arp_nwk_req.ip       <= (others => '0');

    -- zero time response to lookup request if already in cache
    if arp_req_req.lookup_req = '1' and l_arp_req_req_ip = arp_entry_cache.ip and cache_valid = '1' then
      arp_req_rslt.got_mac <= '1';
      arp_req_rslt.mac     <= arp_entry_cache.mac;
    elsif arp_req_req.lookup_req = '1' then
      -- hold off got_mac while req is there as arp_entry will not be correct yet
      arp_req_rslt.got_mac <= '0';
      arp_req_rslt.mac     <= arp_entry_cache.mac;
    else
      arp_req_rslt.got_mac <= cache_valid;
      arp_req_rslt.mac     <= arp_entry_cache.mac;
    end if;

    if arp_req_req.lookup_req = '1' then
      -- ensure any existing error report is killed at the start of a request
      arp_req_rslt.got_err <= '0';
    else
      arp_req_rslt.got_err <= timeout_reg;
    end if;

    -- set signal defaults
    next_req_state    <= IDLE;
    set_req_state     <= '0';
    set_req_ip        <= '0';
    store_arp_cache   <= '0';
    arp_entry_val.ip  <= (others => '0');
    arp_entry_val.mac <= (others => '0');
    set_nwk_rx_cntr   <= HOLD;
    set_timer         <= INCR;          -- default is timer running, unless we hold or reset it
    set_timeout       <= HOLD;
    timer_enable      <= '0';
    clear_cache_valid <= clear_cache;

    -- combinatorial logic
    if freq_scaler = x"00000000" then
      timer_enable <= '1';
    end if;

    -- REQ FSM
    case req_state is
      when IDLE =>
        set_timer <= CLR;
        if arp_req_req.lookup_req = '1' then
                                        -- check if we already have the info in cache
          if l_arp_req_req_ip = arp_entry_cache.ip and cache_valid = '1' then
                                        -- already have this IP - feed output back
            arp_req_rslt.got_mac <= '1';
            arp_req_rslt.mac     <= arp_entry_cache.mac;
          else
            clear_cache_valid <= '1';   -- remove cache entry
            set_timeout       <= CLR;
            next_req_state    <= LOOKUP;
            set_req_state     <= '1';
            set_req_ip        <= '1';
          end if;
        end if;

      when LOOKUP =>
        -- put request on the store
        arp_store_req.ip  <= req_ip_addr;
        arp_store_req.req <= '1';
        case arp_store_result.status is
          when FOUND =>
                                        -- update the cache
            arp_entry_val        <= arp_store_result.entry;
            store_arp_cache      <= '1';
                                        -- and feed output back
            arp_req_rslt.got_mac <= '1';
            arp_req_rslt.mac     <= arp_store_result.entry.mac;
            next_req_state       <= IDLE;
            set_req_state        <= '1';
            
          when NOT_FOUND =>
                                        -- need to request from the network
            set_timer       <= CLR;
            set_nwk_rx_cntr <= CLR;
            arp_nwk_req.req <= '1';
            arp_nwk_req.ip  <= req_ip_addr;
            next_req_state  <= WAIT_REPLY;
            set_req_state   <= '1';
            
          when others =>
                                        -- just keep waiting - no timeout (assumes lookup with either succeed or fail)
        end case;
        
      when WAIT_REPLY =>
        case arp_nwk_result.status is
          when RECEIVED =>
            if arp_nwk_result.entry.ip = req_ip_addr then
              -- store into cache
              arp_entry_val   <= arp_nwk_result.entry;
              store_arp_cache <= '1';
              -- and feed output back
              arp_req_rslt.got_mac <= '1';
              arp_req_rslt.mac     <= arp_nwk_result.entry.mac;
              next_req_state       <= IDLE;
              set_req_state        <= '1';
            else
              if nwk_rx_cntr > ARP_MAX_PKT_TMO then
                set_timeout    <= SET;
                next_req_state <= IDLE;
                set_req_state  <= '1';
              else
                set_nwk_rx_cntr <= INCR;
              end if;
            end if;

          when error =>
            set_timeout <= SET;

          when others =>
            if timer >= ARP_TIMEOUT then
              set_timeout    <= SET;
              next_req_state <= PAUSE1;
              set_req_state  <= '1';
            end if;
        end case;

      when PAUSE1 =>
        next_req_state <= PAUSE2;
        set_req_state  <= '1';

      when PAUSE2 =>
        next_req_state <= PAUSE3;
        set_req_state  <= '1';

      when PAUSE3 =>
        next_req_state <= IDLE;
        set_req_state  <= '1';
        
    end case;
  end process;

  req_sequential : process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        -- reset state variables
        req_state           <= IDLE;
        req_ip_addr         <= (others => '0');
        arp_entry_cache.ip  <= (others => '0');
        arp_entry_cache.mac <= (others => '0');
        cache_valid         <= '0';
        nwk_rx_cntr         <= (others => '0');
        freq_scaler         <= to_unsigned(CLOCK_FREQ, 32);
        timer               <= (others => '0');
        timeout_reg         <= '0';
      else
        -- Next req_state processing
        if set_req_state = '1' then
          req_state <= next_req_state;
        else
          req_state <= req_state;
        end if;

        -- Latch the requested IP address
        if set_req_ip = '1' then
          req_ip_addr <= l_arp_req_req_ip;
        else
          req_ip_addr <= req_ip_addr;
        end if;

        -- network received counter
        case set_nwk_rx_cntr is
          when CLR  => nwk_rx_cntr <= (others => '0');
          when INCR => nwk_rx_cntr <= nwk_rx_cntr + 1;
          when HOLD => nwk_rx_cntr <= nwk_rx_cntr;
        end case;

        -- set the arp_entry_cache
        if clear_cache_valid = '1' then
          arp_entry_cache <= arp_entry_cache;
          cache_valid     <= '0';
        elsif store_arp_cache = '1' then
          arp_entry_cache <= arp_entry_val;
          cache_valid     <= '1';
        else
          arp_entry_cache <= arp_entry_cache;
          cache_valid     <= cache_valid;
        end if;

        -- freq scaling and 1-sec timer
        if freq_scaler = x"00000000" then
          freq_scaler <= to_unsigned(CLOCK_FREQ, 32);
        else
          freq_scaler <= freq_scaler - 1;
        end if;

        -- timer processing
        case set_timer is
          when CLR =>
            timer <= x"00";
          when INCR =>
            if timer_enable = '1' then
              timer <= timer + 1;
            else
              timer <= timer;
            end if;
          when HOLD =>
            timer <= timer;
        end case;

        -- timeout latching
        case set_timeout is
          when CLR  => timeout_reg <= '0';
          when SET  => timeout_reg <= '1';
          when HOLD => timeout_reg <= timeout_reg;
        end case;

      end if;
    end if;
  end process;

end Behavioral;
