-------------------------------------------------------------------------------
-- Title      : FPGA Ethernet interface - block sending packets via Ethernet MAC
-- Project    : 
-------------------------------------------------------------------------------
-- File       : desc_manager.vhd
-- Author     : Wojciech M. Zabolotny (wzab@ise.pw.edu.pl)
-- License    : BSD License
-- Company    : 
-- Created    : 2012-03-30
-- Last update: 2012-05-03
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This file implements the state machine, which manages the
-- table of packet descriptors, used to resend only not confirmed packets
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-03-30  1.0      WZab      Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eth_sender is
  
  port (
    -- Configuration
    peer_mac      : in  std_logic_vector(47 downto 0);
    my_mac        : in  std_logic_vector(47 downto 0);
    my_ether_type : in  std_logic_vector(15 downto 0);
    set_number    : in  unsigned(15 downto 0);
    pkt_number    : in  unsigned(15 downto 0);
    retry_number  : in  unsigned(15 downto 0);
    transm_delay  : in  unsigned(31 downto 0);
    -- System interface
    clk           : in  std_logic;
    rst_n         : in  std_logic;
    -- Control interface
    ready         : out std_logic;
    start         : in  std_logic;
    -- Data memory interface
    tx_mem_addr   : out std_logic_vector(13 downto 0);
    tx_mem_data   : in  std_logic_vector(31 downto 0);
    -- MAC inerface
    Tx_mac_wa     : in  std_logic;
    Tx_mac_wr     : out std_logic;
    Tx_mac_data   : out std_logic_vector(31 downto 0);
    Tx_mac_BE     : out std_logic_vector(1 downto 0);
    Tx_mac_sop    : out std_logic;
    Tx_mac_eop    : out std_logic
    );

end eth_sender;


architecture beh1 of eth_sender is

  type T_ETH_SENDER_STATE is (WST_IDLE, WST_SEND_1, WST_SEND_1a, WST_SEND_1b,
                              WST_SEND_2, WST_SEND_3, WST_SEND_4, WST_SEND_5);

  type T_ETH_SENDER_REGS is record
    state       : T_ETH_SENDER_STATE;
    ready       : std_logic;
    tx_mem_addr : unsigned (7 downto 0);
  end record;
  
  constant ETH_SENDER_REGS_INI : T_ETH_SENDER_REGS := (
    tx_mem_addr => (others => '0'),
    state       => WST_IDLE,
    ready       => '1'
    ) ;

  signal r, r_i : T_ETH_SENDER_REGS := ETH_SENDER_REGS_INI;

  type T_ETH_SENDER_COMB is record
    Tx_mac_wr   : std_logic;
    Tx_mac_sop  : std_logic;
    Tx_mac_eop  : std_logic;
    Tx_mac_data : std_logic_vector(31 downto 0);
    tx_mem_addr : unsigned(7 downto 0);
  end record;

  constant ETH_SENDER_COMB_DEFAULT : T_ETH_SENDER_COMB := (
    Tx_mac_wr   => '0',
    Tx_mac_sop  => '0',
    Tx_mac_eop  => '0',
    Tx_mac_data => (others => '0'),
    tx_mem_addr => (others => '0')
    );

  signal c : T_ETH_SENDER_COMB := ETH_SENDER_COMB_DEFAULT;
  
begin  -- beh1

  -- Connection of the signals
  Tx_mac_data <= c.Tx_mac_data;
  Tx_mac_eop  <= c.Tx_mac_eop;
  Tx_mac_sop  <= c.Tx_mac_sop;
  Tx_mac_wr   <= C.Tx_mac_wr;
  Tx_mac_be   <= "00";

  ready <= r.ready;

  -- The memory address is built from the packet number (6 bits) and word
  -- number (8 bits)
  tx_mem_addr <= std_logic_vector(pkt_number(5 downto 0)) & std_logic_vector(c.tx_mem_addr);

  -- Main state machine used to send the packet
  snd1 : process (clk, rst_n)
  begin
    if rst_n = '0' then                 -- asynchronous reset (active low)
      r <= ETH_SENDER_REGS_INI;
    elsif clk'event and clk = '1' then  -- rising clock edge
      r <= r_i;
    end if;
  end process snd1;  -- snd1

  snd2 : process (Tx_mac_wa, my_ether_type, my_mac, peer_mac, pkt_number, r,
                  retry_number, set_number, start, transm_delay,
                  tx_mem_data)
  begin  -- process snd1
    -- default values
    c   <= ETH_SENDER_COMB_DEFAULT;
    r_i <= r;
    case r.state is
      when WST_IDLE =>
        if start = '1' then
          r_i.ready <= '0';
          r_i.state <= WST_SEND_1;
        end if;
      when WST_SEND_1 =>
        if Tx_mac_wa = '1' then
          c.tx_mac_data <= peer_mac(47 downto 16);
          c.Tx_mac_sop  <= '1';
          c.tx_mac_wr   <= '1';
          r_i.state     <= WST_SEND_1a;
        end if;
      when WST_SEND_1a =>
        if Tx_mac_wa = '1' then
          c.tx_mac_data <= peer_mac(15 downto 0) & my_mac(47 downto 32);
          c.tx_mac_wr   <= '1';
          r_i.state     <= WST_SEND_1b;
        end if;
      when WST_SEND_1b =>
        if Tx_mac_wa = '1' then
          c.tx_mac_data <= my_mac(31 downto 0);
          c.tx_mac_wr   <= '1';
          r_i.state     <= WST_SEND_2;
        end if;
      when WST_SEND_2 =>
        if Tx_mac_wa = '1' then
          c.tx_mac_data <= my_ether_type & x"a5a5";
          c.tx_mac_wr   <= '1';
          r_i.state     <= WST_SEND_3;
        end if;
      when WST_SEND_3 =>
        -- Now we send the set & packet number & retry_number
        if Tx_mac_wa = '1' then
          c.tx_mac_data   <= std_logic_vector(set_number(15 downto 0)) & std_logic_vector(pkt_number(5 downto 0)) & std_logic_vector(retry_number(9 downto 0));
          c.tx_mac_wr     <= '1';
          r_i.tx_mem_addr <= (others => '0');
          r_i.state       <= WST_SEND_4;
        end if;
      when WST_SEND_4 =>
        -- Now we send the set & packet number & retry_number
        if Tx_mac_wa = '1' then
          c.tx_mac_data   <= std_logic_vector(transm_delay);
          c.tx_mac_wr     <= '1';
          r_i.tx_mem_addr <= (others => '0');
          r_i.state       <= WST_SEND_5;
        end if;
      when WST_SEND_5 =>
        -- Now we send the packet data
        -- If the address is not incremented,
        -- we still send the last address to the memory...
        c.tx_mem_addr <= r.tx_mem_addr;
        if Tx_mac_wa = '1' then
          c.tx_mac_data <= tx_mem_data;
          c.tx_mac_wr   <= '1';
          if r.tx_mem_addr < 255 then
            -- Still some data should be sent
            -- We increase the address, so the data are available
            -- in the next cycle
            r_i.tx_mem_addr <= r.tx_mem_addr + 1;
            c.tx_mem_addr   <= r.tx_mem_addr + 1;
            r_i.state       <= WST_SEND_5;  -- we remain in the same state
          else
            -- All data sent
            -- set the "end_of_packet" flag
            c.Tx_mac_eop <= '1';
            r_i.state    <= WST_IDLE;
            r_i.ready    <= '1';
          end if;
        end if;
    end case;
  end process snd2;

end beh1;
