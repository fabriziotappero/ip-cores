----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:09:01 02/20/2012 
-- Design Name: 
-- Module Name:    arp_SYNC - Behavioral - synchronises between rx and tx clock domains
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.arp_types.all;

entity arp_SYNC is
  port (
    -- REQ to TX
    arp_nwk_req           : in  arp_nwk_request_t;  -- request for a translation from IP to MAC
    send_who_has          : out std_logic;
    ip_entry              : out std_logic_vector (31 downto 0);
    -- RX to TX
    recv_who_has          : in  std_logic;          -- this is for us, we will respond
    arp_entry_for_who_has : in  arp_entry_t;
    send_I_have           : out std_logic;
    arp_entry             : out arp_entry_t;
    -- RX to REQ
    I_have_received       : in  std_logic;
    nwk_result_status     : out arp_nwk_rslt_t;
    -- System Signals
    rx_clk                : in  std_logic;
    tx_clk                : in  std_logic;
    reset                 : in  std_logic
    );
end arp_SYNC;

architecture Behavioral of arp_SYNC is

  type sync_state_t is (IDLE, HOLD1, HOLD2);

  -- state registers
  signal ip_entry_state  : sync_state_t;
  signal arp_entry_state : sync_state_t;
  signal ip_entry_reg    : std_logic_vector (31 downto 0);
  signal arp_entry_reg   : arp_entry_t;

  -- synchronisation registers  
  signal send_who_has_r1 : std_logic;
  signal send_who_has_r2 : std_logic;
  signal send_I_have_r1  : std_logic;
  signal send_I_have_r2  : std_logic;
  
begin

  combinatorial : process (
    -- input signals
    arp_nwk_req, recv_who_has, arp_entry_for_who_has, I_have_received, reset,
    -- state
    ip_entry_state, ip_entry_reg, arp_entry_state, arp_entry_reg,
    -- synchronisation registers
    send_who_has_r1, send_who_has_r2,
    send_I_have_r1, send_I_have_r2
    )
  begin
    -- set output followers
    send_who_has <= send_who_has_r2;
    ip_entry     <= ip_entry_reg;
    send_I_have  <= send_I_have_r2;
    arp_entry    <= arp_entry_reg;

    -- combinaltorial outputs
    if I_have_received = '1' then
      nwk_result_status <= RECEIVED;
    else
      nwk_result_status <= IDLE;
    end if;
  end process;

  -- process for stablisising RX clock domain data registers
  -- essentially holds data registers ip_entry and arp_entry static for 2 rx clk cycles
  -- during transfer to TX clk domain
  rx_sequential : process (tx_clk)
  begin
    if rising_edge(tx_clk) then
      if reset = '1' then
        -- reset state variables
        ip_entry_reg      <= (others => '0');
        arp_entry_reg.ip  <= (others => '0');
        arp_entry_reg.mac <= (others => '0');
      else
        -- normal (non reset) processing
        case ip_entry_state is
          when IDLE =>
            if arp_nwk_req.req = '1' then
              ip_entry_reg   <= arp_nwk_req.ip;
              ip_entry_state <= HOLD1;
            else
              ip_entry_reg   <= ip_entry_reg;
              ip_entry_state <= IDLE;
            end if;
          when HOLD1 =>
            ip_entry_reg   <= ip_entry_reg;
            ip_entry_state <= HOLD2;
          when HOLD2 =>
            ip_entry_reg   <= ip_entry_reg;
            ip_entry_state <= IDLE;
        end case;

        case arp_entry_state is
          when IDLE =>
            if recv_who_has = '1' then
              arp_entry_reg   <= arp_entry_for_who_has;
              arp_entry_state <= HOLD1;
            else
              arp_entry_reg   <= arp_entry_reg;
              arp_entry_state <= IDLE;
            end if;
          when HOLD1 =>
            arp_entry_reg   <= arp_entry_reg;
            arp_entry_state <= HOLD2;
          when HOLD2 =>
            arp_entry_reg   <= arp_entry_reg;
            arp_entry_state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  -- process for syncing to the TX clock domain
  -- clocks control signals through 2 layers of tx clocking
  tx_sequential : process (tx_clk)
  begin
    if rising_edge(tx_clk) then
      if reset = '1' then
        -- reset state variables
        send_who_has_r1 <= '0';
        send_who_has_r2 <= '0';
        send_I_have_r1  <= '0';
        send_I_have_r2  <= '0';
      else
        -- normal (non reset) processing
        
        send_who_has_r1 <= arp_nwk_req.req;
        send_who_has_r2 <= send_who_has_r1;

        send_I_have_r1 <= recv_who_has;
        send_I_have_r2 <= send_I_have_r1;
      end if;
    end if;
  end process;


end Behavioral;

