-------------------------------------------------------------------------------
-- Title      : FPGA Ethernet interface - block sending packets via MII Phy
-- Project    : 
-------------------------------------------------------------------------------
-- File       : desc_manager.vhd
-- Author     : Wojciech M. Zabolotny (wzab@ise.pw.edu.pl)
-- License    : BSD License
-- Company    : 
-- Created    : 2012-03-30
-- Last update: 2013-06-16
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
library work;
use work.PCK_CRC32_D4.all;

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
    -- TX Phy interface
    Tx_Clk        : in  std_logic;
    Tx_En         : out std_logic;
    TxD           : out std_logic_vector(3 downto 0)
    );

end eth_sender;


architecture beh1 of eth_sender is

  type T_ETH_SENDER_STATE is (WST_IDLE, WST_SEND_PREAMB, WST_SEND_SOF,
                              WST_SEND_HEADER, WST_SEND_DATA, WST_SEND_CRC,
                              WST_SEND_COMPLETED);

  type T_ETH_SENDER_REGS is record
    state    : T_ETH_SENDER_STATE;
    ready    : std_logic;
    count    : integer;
    nibble   : integer;
    mem_addr : unsigned (7 downto 0);
    crc32    : std_logic_vector(31 downto 0);
  end record;
  
  constant ETH_SENDER_REGS_INI : T_ETH_SENDER_REGS := (
    state    => WST_IDLE,
    ready    => '1',
    count    => 0,
    nibble   => 0,
    mem_addr => (others => '0'),
    crc32    => (others => '0')
    ) ;

  signal r, r_n : T_ETH_SENDER_REGS := ETH_SENDER_REGS_INI;

  type T_ETH_SENDER_COMB is record
    TxD      : std_logic_vector(3 downto 0);
    Tx_En    : std_logic;
    mem_addr : unsigned(7 downto 0);
  end record;

  constant ETH_SENDER_COMB_DEFAULT : T_ETH_SENDER_COMB := (
    TxD      => (others => '0'),
    Tx_En    => '0',
    mem_addr => (others => '0')
    );

  signal c : T_ETH_SENDER_COMB := ETH_SENDER_COMB_DEFAULT;

  signal s_header     : std_logic_vector(6*32-1 downto 0) := (others => '0');
  constant HEADER_LEN : integer                           := 6*8;  -- 6 words,
                                                                   -- 8 nibbles each
  
  function select_nibble (
    constant vec        : std_logic_vector;
    constant nibble_num : integer)
    return std_logic_vector is
    variable byte_num : integer;
    variable v_byte   : std_logic_vector(7 downto 0);
    variable v_nibble : std_logic_vector(3 downto 0);
  begin
    -- first select byte
    byte_num := nibble_num / 2;
    v_byte   := vec(vec'left-byte_num*8 downto vec'left-byte_num*8-7);
    -- then select nibble (lower nibble is sent first!)
    if nibble_num mod 2 = 0 then
      v_nibble := v_byte(3 downto 0);
    else
      v_nibble := v_byte(7 downto 4);
    end if;
    return v_nibble;
  end select_nibble;

  function rev(a : in std_logic_vector)
    return std_logic_vector is
    variable result : std_logic_vector(a'range);
    alias aa        : std_logic_vector(a'reverse_range) is a;
  begin
    for i in aa'range loop
      result(i) := aa(i);
    end loop;
    return result;
  end;  -- function reverse_any_bus

  signal tx_rst_n, tx_rst_n_0, tx_rst_n_1          : std_logic := '0';
  signal update_flag_0, update_flag_1, update_flag : std_logic := '0';

  signal start_0, tx_start, tx_start_1, tx_start_0 : std_logic := '0';
  signal tx_ready, ready_0, ready_1                : std_logic := '0';

  type T_STATE1 is (ST1_IDLE, ST1_WAIT_NOT_READY, ST1_WAIT_NOT_START,
                    ST1_WAIT_READY);
  signal state1 : T_STATE1;

  type T_STATE2 is (ST2_IDLE, ST2_WAIT_NOT_READY, ST2_WAIT_READY);
  signal state2 : T_STATE2;
begin  -- beh1

  -- Packet header
  s_header <= peer_mac & my_mac & my_ether_type & x"a5a5" &
              std_logic_vector(set_number(15 downto 0)) &
              std_logic_vector(pkt_number(5 downto 0)) &
              std_logic_vector(retry_number(9 downto 0)) &
              std_logic_vector(transm_delay);
  -- Connection of the signals

  -- The memory address is built from the packet number (6 bits) and word
  -- number (8 bits)
  tx_mem_addr <= std_logic_vector(pkt_number(5 downto 0)) & std_logic_vector(c.mem_addr);

  -- Main state machine used to send the packet
  -- W calej maszynie trzeba jeszcze dodac obsluge kolizji!!!
  -- Oprocz tego trzeba przeanalizowac poprawnosc przejsc miedzy domenami zegara


  snd1 : process (Tx_Clk, tx_rst_n)
  begin
    if tx_rst_n = '0' then              -- asynchronous reset (active low)
      r     <= ETH_SENDER_REGS_INI;
      TxD   <= (others => '0');
      Tx_En <= '0';
    elsif Tx_Clk'event and Tx_Clk = '1' then  -- rising clock edge
      r     <= r_n;
      -- To minimize glitches and propagation delay, let's add pipeline register
      Tx_En <= c.Tx_En;
      TxD   <= c.TxD;
    end if;
  end process snd1;  -- snd1

  snd2 : process (r, s_header, tx_mem_data, tx_start)
    variable v_TxD : std_logic_vector(3 downto 0);
  begin  -- process snd1
    -- default values
    c   <= ETH_SENDER_COMB_DEFAULT;
    r_n <= r;
    case r.state is
      when WST_IDLE =>
        r_n.ready <= '1';
        if tx_start = '1' then
          r_n.ready <= '0';
          r_n.state <= WST_SEND_PREAMB;
          r_n.count <= 15;
        end if;
      when WST_SEND_PREAMB =>
        -- Trzeba dodac wykrywanie kolizji!
        c.TxD     <= x"5";
        c.Tx_En   <= '1';
        r_n.count <= r.count - 1;
        if r.count = 1 then
          r_n.state <= WST_SEND_SOF;
        end if;
      when WST_SEND_SOF =>
        c.TxD     <= x"D";
        c.Tx_En   <= '1';
        -- Prepare for sending of header
        r_n.crc32 <= (others => '1');
        r_n.state <= WST_SEND_HEADER;
        r_n.count <= 0;
      when WST_SEND_HEADER =>
        v_TxD     := select_nibble(s_header, r.count);
        c.TxD     <= v_TxD;
        c.Tx_En   <= '1';
        r_n.crc32 <= nextCRC32_D4(rev(v_TxD), r.crc32);
        if r.count < HEADER_LEN-1 then
          r_n.count <= r.count + 1;
        else
          r_n.count    <= 0;
          r_n.nibble   <= 0;
          r_n.mem_addr <= (others => '0');
          c.mem_addr   <= (others => '0');
          r_n.state    <= WST_SEND_DATA;
        end if;
      when WST_SEND_DATA =>
        -- send the data nibble by nibble
        v_TxD     := select_nibble(tx_mem_data, r.nibble);
        c.TxD     <= v_TxD;
        c.Tx_En   <= '1';
        r_n.crc32 <= nextCRC32_D4(rev(v_TxD), r.crc32);
        if r.nibble < 7 then
          r_n.nibble <= r.nibble + 1;
          c.mem_addr <= r.mem_addr;
        else
          r_n.nibble <= 0;
          -- Check, if we have sent all the data
          if r.mem_addr < 255 then
            r_n.mem_addr <= r.mem_addr + 1;
            c.mem_addr   <= r.mem_addr + 1;
          else
            -- We send the CRC
            r_n.state <= WST_SEND_CRC;
          end if;
        end if;
      when WST_SEND_CRC =>
        v_TxD   := r.crc32(31-r.nibble*4 downto 28-r.nibble*4);
        c.TxD   <= not rev(v_TxD);
        c.Tx_En <= '1';
        if r.nibble < 7 then
          r_n.nibble <= r.nibble + 1;
        else
          r_n.count <= 24;              -- generate the IFG - 24 nibbles = 96
                                        -- bits
          r_n.state <= WST_SEND_COMPLETED;
        end if;
      when WST_SEND_COMPLETED =>
        if r.count > 0 then
          r_n.count <= r.count - 1;
        else
          r_n.ready <= '1';
          r_n.state <= WST_IDLE;
        end if;
    end case;
  end process snd2;


  -- Synchronization of the reset signal for the Tx_Clk domain
  process (Tx_Clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      tx_rst_n_0 <= '0';
      tx_rst_n_1 <= '0';
      tx_rst_n   <= '0';
    elsif Tx_Clk'event and Tx_Clk = '1' then  -- rising clock edge
      tx_rst_n_0 <= rst_n;
      tx_rst_n_1 <= tx_rst_n_0;
      tx_rst_n   <= tx_rst_n_1;
    end if;
  end process;

  -- Synchronization of signals passing clock domains
  -- Signal start is sent from the Clk domain.
  -- When it is asserted, we must immediately deassert signal ready,
  -- then generate the synchronized start and after internal ready
  -- is asserted, we can output it again...

  -- Ustawienie na 1 takt zegara "clk" sygnalu start powinno zainicjowac wysylanie
  -- w tym bloku musimy zadbac o stosowne wydluzenie sygnalu start i jego synchronizacje
  -- miedzy domenami zegara...
  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      ready   <= '0';
      ready_0 <= '0';
      ready_1 <= '0';
      state2  <= ST2_IDLE;
    elsif clk'event and clk = '1' then  -- rising clock edge
      ready_1 <= tx_ready;
      ready_0 <= ready_1;
      case state2 is
        when ST2_IDLE =>
          if start = '1' and ready_0 = '1' then
            start_0 <= '1';
            ready   <= '0';
            state2  <= ST2_WAIT_NOT_READY;
          else
            ready <= ready_0;           -- Needed to provide correct start!
          end if;
        when ST2_WAIT_NOT_READY =>
          if ready_0 = '0' then
            start_0 <= '0';
            state2  <= ST2_WAIT_READY;
          end if;
        when ST2_WAIT_READY =>
          if ready_0 = '1' then
            ready  <= '1';
            state2 <= ST2_IDLE;
          end if;
        when others => null;
      end case;
    end if;
  end process;

  process (Tx_Clk, tx_rst_n)
  begin  -- process
    if tx_rst_n = '0' then              -- asynchronous reset (active low)
      tx_start   <= '0';
      tx_start_0 <= '0';
      state1     <= ST1_IDLE;
      tx_ready   <= '1';
    elsif Tx_Clk'event and Tx_Clk = '1' then  -- rising clock edge
      tx_start_0 <= start_0;
      tx_start   <= tx_start_0;
      case state1 is
        when ST1_IDLE =>
          if tx_start = '1' then
            tx_ready <= '0';            -- this should cause tx_start to go low
            state1   <= ST1_WAIT_NOT_READY;
          end if;
        when ST1_WAIT_NOT_READY =>
          if r.ready = '0' then
            state1 <= ST1_WAIT_NOT_START;
          end if;
        when ST1_WAIT_NOT_START =>
          if tx_start = '0' then
            state1 <= ST1_WAIT_READY;
          end if;
        when ST1_WAIT_READY =>
          if r.ready = '1' then
            tx_ready <= '1';
            state1   <= ST1_IDLE;
          end if;
        when others => null;
      end case;
    end if;
  end process;
  
end beh1;
