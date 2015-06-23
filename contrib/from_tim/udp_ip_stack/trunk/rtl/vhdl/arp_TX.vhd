----------------------------------------------------------------------------------
-- Company: 
-- Engineer:            Peter Fall
-- 
-- Create Date:    12:00:04 05/31/2011 
-- Design Name: 
-- Module Name:    arp_tx - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:
--              handle transmission of an ARP packet.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created - refactored this arp_tx module from the complete arp v0.02 module
-- Additional Comments: 
--
----------------------------------------------------------------------------------
  library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.arp_types.all;

entity arp_tx is
  port (
    -- control signals
    send_I_have     : in  std_logic;    -- pulse will be latched
    arp_entry       : in  arp_entry_t;  -- arp target for I_have req (will be latched)
    send_who_has    : in  std_logic;    -- pulse will be latched
    ip_entry        : in  std_logic_vector (31 downto 0);  -- IP target for who_has req (will be latched)
    -- MAC layer TX signals
    mac_tx_req      : out std_logic;  -- indicates that ip wants access to channel (stays up for as long as tx)
    mac_tx_granted  : in  std_logic;  -- indicates that access to channel has been granted            
    data_out_ready  : in  std_logic;    -- indicates system ready to consume data
    data_out_valid  : out std_logic;    -- indicates data out is valid
    data_out_first  : out std_logic;  -- with data out valid indicates the first byte of a frame
    data_out_last   : out std_logic;  -- with data out valid indicates the last byte of a frame
    data_out        : out std_logic_vector (7 downto 0);  -- ethernet frame (from dst mac addr through to last byte of frame)
    -- system signals
    our_mac_address : in  std_logic_vector (47 downto 0);
    our_ip_address  : in  std_logic_vector (31 downto 0);
    tx_clk          : in  std_logic;
    reset           : in  std_logic
    );
end arp_tx;

architecture Behavioral of arp_tx is

  type count_mode_t is (RST, INCR, HOLD);
  type set_clr_t is (SET, CLR, HOLD);
  type tx_state_t is (IDLE, WAIT_MAC, SEND);
  type tx_mode_t is (REPLY, REQUEST);

  -- state variables
  signal tx_mac_chn_reqd  : std_logic;
  signal tx_state         : tx_state_t;
  signal tx_count         : unsigned (7 downto 0);
  signal send_I_have_reg  : std_logic;
  signal send_who_has_reg : std_logic;
  signal I_have_target    : arp_entry_t;  -- latched target for "I have" request
  signal who_has_target   : std_logic_vector (31 downto 0);  -- latched IP for "who has" request
  signal tx_mode          : tx_mode_t;  -- what sort of tx to make
  signal target           : arp_entry_t;  -- target to send to

  -- busses
  signal next_tx_state : tx_state_t;
  signal tx_mode_val   : tx_mode_t;
  signal target_val    : arp_entry_t;

  -- tx control signals
  signal set_tx_state        : std_logic;
  signal tx_count_mode       : count_mode_t;
  signal set_chn_reqd        : set_clr_t;
  signal kill_data_out_valid : std_logic;
  signal set_send_I_have     : set_clr_t;
  signal set_send_who_has    : set_clr_t;
  signal set_tx_mode         : std_logic;
  signal set_target          : std_logic;
  
begin

  tx_combinatorial : process (
    -- input signals
    send_I_have, send_who_has, arp_entry, ip_entry, data_out_ready, mac_tx_granted,
    our_mac_address, our_ip_address, reset,
    -- state variables
    tx_state, tx_count, tx_mac_chn_reqd, I_have_target, who_has_target,
    send_I_have_reg, send_who_has_reg, tx_mode, target,
    -- busses
    next_tx_state, tx_mode_val, target_val,
    -- control signals
    tx_count_mode, kill_data_out_valid, set_send_I_have, set_send_who_has,
    set_chn_reqd, set_tx_mode, set_target
    )
  begin
    -- set output followers
    mac_tx_req <= tx_mac_chn_reqd;

    -- set combinatorial output defaults
    data_out_first <= '0';

    case tx_state is
      when SEND =>
        if data_out_ready = '1' and kill_data_out_valid = '0' then
          data_out_valid <= '1';
        else
          data_out_valid <= '0';
        end if;
      when others => data_out_valid <= '0';
    end case;

    -- set bus defaults
    next_tx_state  <= IDLE;
    tx_mode_val    <= REPLY;
    target_val.ip  <= (others => '0');
    target_val.mac <= (others => '1');

    -- set signal defaults
    set_tx_state        <= '0';
    tx_count_mode       <= HOLD;
    data_out            <= x"00";
    data_out_last       <= '0';
    set_chn_reqd        <= HOLD;
    kill_data_out_valid <= '0';
    set_send_I_have     <= HOLD;
    set_send_who_has    <= HOLD;
    set_tx_mode         <= '0';
    set_target          <= '0';

    -- process requests in regardless of FSM state
    if send_I_have = '1' then
      set_send_I_have <= SET;
    end if;
    if send_who_has = '1' then
      set_send_who_has <= SET;
    end if;

    -- TX FSM
    case tx_state is
      when IDLE =>
        tx_count_mode <= RST;
        if send_I_have_reg = '1' then
          set_chn_reqd    <= SET;
          tx_mode_val     <= REPLY;
          set_tx_mode     <= '1';
          target_val      <= I_have_target;
          set_target      <= '1';
          set_send_I_have <= CLR;
          next_tx_state   <= WAIT_MAC;
          set_tx_state    <= '1';
        elsif send_who_has_reg = '1' then
          set_chn_reqd     <= SET;
          tx_mode_val      <= REQUEST;
          set_tx_mode      <= '1';
          target_val.ip    <= who_has_target;
          target_val.mac   <= (others => '1');
          set_target       <= '1';
          set_send_who_has <= CLR;
          next_tx_state    <= WAIT_MAC;
          set_tx_state     <= '1';
        else
          set_chn_reqd <= CLR;
        end if;

      when WAIT_MAC =>
        tx_count_mode <= RST;
        if mac_tx_granted = '1' then
          next_tx_state <= SEND;
          set_tx_state  <= '1';
        end if;
        -- TODO - should handle timeout here
        
      when SEND =>
        if data_out_ready = '1' then
          tx_count_mode <= INCR;
        end if;
        case tx_count is
          when x"00" => data_out_first <= data_out_ready;
                        data_out <= target.mac (47 downto 40);       -- target mac--data_out       <= x"ff";    -- dst = broadcast            
          when x"01" => data_out <= target.mac (39 downto 32);                    --data_out <= x"ff";
          when x"02" => data_out <= target.mac (31 downto 24);                    --data_out <= x"ff";
          when x"03" => data_out <= target.mac (23 downto 16);                    --data_out <= x"ff";
          when x"04" => data_out <= target.mac (15 downto 8);                     --data_out <= x"ff";
          when x"05" => data_out <= target.mac (7 downto 0);                      --data_out <= x"ff";
          when x"06" => data_out <= our_mac_address (47 downto 40);  -- src = our mac
          when x"07" => data_out <= our_mac_address (39 downto 32);
          when x"08" => data_out <= our_mac_address (31 downto 24);
          when x"09" => data_out <= our_mac_address (23 downto 16);
          when x"0a" => data_out <= our_mac_address (15 downto 8);
          when x"0b" => data_out <= our_mac_address (7 downto 0);
          when x"0c" => data_out <= x"08";                           -- pkt type = 0806 : ARP
          when x"0d" => data_out <= x"06";
          when x"0e" => data_out <= x"00";                           -- HW type = 0001 : eth
          when x"0f" => data_out <= x"01";
          when x"10" => data_out <= x"08";                           -- protocol = 0800 : ip
          when x"11" => data_out <= x"00";
          when x"12" => data_out <= x"06";                           -- HW size = 06
          when x"13" => data_out <= x"04";                           -- prot size = 04

          when x"14" => data_out <= x"00";  -- opcode =             
          when x"15" =>
            if tx_mode = REPLY then
              data_out <= x"02";            -- 02 : REPLY
            else
              data_out <= x"01";            -- 01 : REQ
            end if;
            
          when x"16" => data_out <= our_mac_address (47 downto 40);  -- sender mac
          when x"17" => data_out <= our_mac_address (39 downto 32);
          when x"18" => data_out <= our_mac_address (31 downto 24);
          when x"19" => data_out <= our_mac_address (23 downto 16);
          when x"1a" => data_out <= our_mac_address (15 downto 8);
          when x"1b" => data_out <= our_mac_address (7 downto 0);
          when x"1c" => data_out <= our_ip_address (31 downto 24);   -- sender ip
          when x"1d" => data_out <= our_ip_address (23 downto 16);
          when x"1e" => data_out <= our_ip_address (15 downto 8);
          when x"1f" => data_out <= our_ip_address (7 downto 0);
          when x"20" => data_out <= target.mac (47 downto 40);       -- target mac
          when x"21" => data_out <= target.mac (39 downto 32);                    
          when x"22" => data_out <= target.mac (31 downto 24);                    
          when x"23" => data_out <= target.mac (23 downto 16);                    
          when x"24" => data_out <= target.mac (15 downto 8);                     
          when x"25" => data_out <= target.mac (7 downto 0);                      
          when x"26" => data_out <= target.ip (31 downto 24);        -- target ip
          when x"27" => data_out <= target.ip (23 downto 16);
          when x"28" => data_out <= target.ip (15 downto 8);

          when x"29" =>
            data_out      <= target.ip(7 downto 0);
            data_out_last <= '1';
            
          when x"2a" =>
            kill_data_out_valid <= '1';  -- data is no longer valid
            next_tx_state       <= IDLE;
            set_tx_state        <= '1';

          when others =>
            next_tx_state <= IDLE;
            set_tx_state  <= '1';
        end case;
    end case;
  end process;

  tx_sequential : process (tx_clk)
  begin
    if rising_edge(tx_clk) then
      if reset = '1' then
        -- reset state variables
        tx_state          <= IDLE;
        tx_count          <= (others => '0');
        tx_mac_chn_reqd   <= '0';
        send_I_have_reg   <= '0';
        send_who_has_reg  <= '0';
        who_has_target    <= (others => '0');
        I_have_target.ip  <= (others => '0');
        I_have_target.mac <= (others => '0');
        target.ip         <= (others => '0');
        target.mac        <= (others => '1');
        
      else
        -- normal (non reset) processing

        -- Next tx_state processing
        if set_tx_state = '1' then
          tx_state <= next_tx_state;
        else
          tx_state <= tx_state;
        end if;

        -- input request latching
        case set_send_I_have is
          when SET =>
            send_I_have_reg <= '1';
            I_have_target   <= arp_entry;
          when CLR =>
            send_I_have_reg <= '0';
            I_have_target   <= I_have_target;
          when HOLD =>
            send_I_have_reg <= send_I_have_reg;
            I_have_target   <= I_have_target;
        end case;

        case set_send_who_has is
          when SET =>
            send_who_has_reg <= '1';
            who_has_target   <= ip_entry;
          when CLR =>
            send_who_has_reg <= '0';
            who_has_target   <= who_has_target;
          when HOLD =>
            send_who_has_reg <= send_who_has_reg;
            who_has_target   <= who_has_target;
        end case;

        -- tx mode
        if set_tx_mode = '1' then
          tx_mode <= tx_mode_val;
        else
          tx_mode <= tx_mode;
        end if;

        -- target latching
        if set_target = '1' then
          target <= target_val;
        else
          target <= target;
        end if;

        -- tx_count processing
        case tx_count_mode is
          when RST =>
            tx_count <= x"00";
          when INCR =>
            tx_count <= tx_count + 1;
          when HOLD =>
            tx_count <= tx_count;
        end case;

        -- control access request to mac tx chn
        case set_chn_reqd is
          when SET  => tx_mac_chn_reqd <= '1';
          when CLR  => tx_mac_chn_reqd <= '0';
          when HOLD => tx_mac_chn_reqd <= tx_mac_chn_reqd;
        end case;
        
      end if;
    end if;
  end process;


end Behavioral;

