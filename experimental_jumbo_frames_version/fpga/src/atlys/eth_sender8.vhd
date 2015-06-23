-------------------------------------------------------------------------------
-- Title      : FPGA Ethernet interface - block sending packets via GMII Phy
-- Project    : 
-------------------------------------------------------------------------------
-- File       : eth_sender8.vhd
-- Author     : Wojciech M. Zabolotny (wzab@ise.pw.edu.pl)
-- License    : BSD License
-- Company    : 
-- Created    : 2012-03-30
-- Last update: 2014-10-19
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
use work.pkg_newcrc32_d8.all;
use work.desc_mgr_pkg.all;

entity eth_sender is
  
  port (
    -- Configuration
    peer_mac      : in  std_logic_vector(47 downto 0);
    my_mac        : in  std_logic_vector(47 downto 0);
    my_ether_type : in  std_logic_vector(15 downto 0);
    pkt_number    : in  unsigned(31 downto 0);
    seq_number    : in  unsigned(15 downto 0);
    transm_delay  : in  unsigned(31 downto 0);
    -- System interface
    clk           : in  std_logic;
    rst_n         : in  std_logic;
    -- Control interface
    ready         : out std_logic;
    flushed       : in  std_logic;
    start         : in  std_logic;
    cmd_start     : in  std_logic;
    -- Data memory interface
    tx_mem_addr   : out std_logic_vector(LOG2_N_OF_PKTS+LOG2_NWRDS_IN_PKT-1 downto 0);
    tx_mem_data   : in  std_logic_vector(63 downto 0);
    -- User command response interface
    cmd_response  : in  std_logic_vector(12*8-1 downto 0);
    -- TX Phy interface
    Tx_Clk        : in  std_logic;
    Tx_En         : out std_logic;
    TxD           : out std_logic_vector(7 downto 0)
    );

end eth_sender;


architecture beh1 of eth_sender is

  type T_ETH_SENDER_STATE is (WST_IDLE, WST_SEND_PREAMB, WST_SEND_SOF,
                              WST_SEND_HEADER, WST_SEND_CMD_HEADER, WST_SEND_CMD_TRAILER,
                              WST_SEND_DATA, WST_SEND_CRC,
                              WST_SEND_COMPLETED);

  type T_ETH_SENDER_REGS is record
    state    : T_ETH_SENDER_STATE;
    ready    : std_logic;
    count    : integer;
    byte     : integer;
    mem_addr : unsigned (LOG2_NWRDS_IN_PKT-1 downto 0);
    crc32    : std_logic_vector(31 downto 0);
  end record;
  
  constant ETH_SENDER_REGS_INI : T_ETH_SENDER_REGS := (
    state    => WST_IDLE,
    ready    => '1',
    count    => 0,
    byte     => 0,
    mem_addr => (others => '0'),
    crc32    => (others => '0')
    ) ;

  signal r, r_n : T_ETH_SENDER_REGS := ETH_SENDER_REGS_INI;

  type T_ETH_SENDER_COMB is record
    TxD      : std_logic_vector(7 downto 0);
    Tx_En    : std_logic;
    mem_addr : unsigned(LOG2_NWRDS_IN_PKT-1 downto 0);
  end record;

  constant ETH_SENDER_COMB_DEFAULT : T_ETH_SENDER_COMB := (
    TxD      => (others => '0'),
    Tx_En    => '0',
    mem_addr => (others => '0')
    );

  signal c : T_ETH_SENDER_COMB := ETH_SENDER_COMB_DEFAULT;

  signal s_header         : std_logic_vector(8*40-1 downto 0) := (others => '0');
  constant HEADER_LEN     : integer                           := 40;  -- 40 bytes
  signal s_cmd_header     : std_logic_vector(8*32-1 downto 0) := (others => '0');
  constant CMD_HEADER_LEN : integer                           := 32;  -- 32 bytes

  signal cmd_only : std_logic := '0';

  function select_byte (
    constant vec      : std_logic_vector;
    constant byte_num : integer)
    return std_logic_vector is
    variable v_byte : std_logic_vector(7 downto 0);
  begin
    -- first select byte
    v_byte := vec(vec'left-byte_num*8 downto vec'left-byte_num*8-7);
    return v_byte;
  end select_byte;

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
  signal state2          : T_STATE2;
  signal dta_packet_type : std_logic_vector(15 downto 0) := (others => '0');
  
begin  -- beh1
  dta_packet_type <= x"a5a5" when flushed = '0' else x"a5a6";
  -- Packet header
  s_header        <= peer_mac & my_mac & my_ether_type & x"0100" &
              dta_packet_type & std_logic_vector(seq_number(15 downto 0)) &
              std_logic_vector(pkt_number) & std_logic_vector(transm_delay) & cmd_response;
  -- Command response packet header - we have unused 16 bits in the response packet...
  s_cmd_header <= peer_mac & my_mac & my_ether_type & x"0100" &
                  x"a55a" & x"0000" & cmd_response;

  -- Connection of the signals

  -- The memory address is built from the packet number (6 bits) and word
  -- number (8 bits)
  tx_mem_addr <= std_logic_vector(pkt_number(LOG2_N_OF_PKTS-1 downto 0)) & std_logic_vector(c.mem_addr);

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
    variable v_TxD : std_logic_vector(7 downto 0);
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
          r_n.count <= 7;
        end if;
      when WST_SEND_PREAMB =>
        -- Trzeba dodac wykrywanie kolizji!
        c.TxD     <= x"55";
        c.Tx_En   <= '1';
        r_n.count <= r.count - 1;
        if r.count = 1 then
          r_n.state <= WST_SEND_SOF;
        end if;
      when WST_SEND_SOF =>
        c.TxD     <= x"D5";
        c.Tx_En   <= '1';
        -- Prepare for sending of header
        r_n.crc32 <= (others => '1');
        if cmd_only = '1' then
          r_n.state <= WST_SEND_CMD_HEADER;
        else
          r_n.state <= WST_SEND_HEADER;
        end if;
        r_n.count <= 0;
      when WST_SEND_CMD_HEADER =>
        v_TxD     := select_byte(s_cmd_header, r.count);
        c.TxD     <= v_TxD;
        c.Tx_En   <= '1';
        r_n.crc32 <= newcrc32_d8(v_TxD, r.crc32);
        if r.count < CMD_HEADER_LEN-1 then
          r_n.count <= r.count + 1;
        else
          r_n.count    <= 0;
          r_n.byte     <= 0;
          r_n.mem_addr <= (others => '0');
          c.mem_addr   <= (others => '0');
          r_n.state    <= WST_SEND_CMD_TRAILER;
        end if;
      when WST_SEND_CMD_TRAILER =>
        v_TxD     := (others => '0');
        c.TxD     <= v_TxD;
        c.Tx_En   <= '1';
        r_n.crc32 <= newcrc32_d8(v_TxD, r.crc32);
        if r.count < 64-CMD_HEADER_LEN-1 then
          r_n.count <= r.count + 1;
        else
          r_n.count    <= 0;
          r_n.byte     <= 0;
          r_n.mem_addr <= (others => '0');
          c.mem_addr   <= (others => '0');
          r_n.state    <= WST_SEND_CRC;
        end if;
      when WST_SEND_HEADER =>
        v_TxD     := select_byte(s_header, r.count);
        c.TxD     <= v_TxD;
        c.Tx_En   <= '1';
        r_n.crc32 <= newcrc32_d8(v_TxD, r.crc32);
        if r.count < HEADER_LEN-1 then
          r_n.count <= r.count + 1;
        else
          r_n.count    <= 0;
          r_n.byte     <= 0;
          r_n.mem_addr <= (others => '0');
          c.mem_addr   <= (others => '0');
          r_n.state    <= WST_SEND_DATA;
        end if;
      when WST_SEND_DATA =>
        -- send the data byte by byte
        v_TxD     := select_byte(tx_mem_data, r.byte);
        c.TxD     <= v_TxD;
        c.Tx_En   <= '1';
        r_n.crc32 <= newcrc32_d8(v_TxD, r.crc32);
        if r.byte < 7 then
          r_n.byte   <= r.byte + 1;
          c.mem_addr <= r.mem_addr;
        else
          r_n.byte <= 0;
          -- Check, if we have sent all the data
          -- We send 8192 bytes, which takes 1024 64-bit words
          if r.mem_addr < 1023 then
            r_n.mem_addr <= r.mem_addr + 1;
            c.mem_addr   <= r.mem_addr + 1;
          else
            -- We send the CRC
            r_n.state <= WST_SEND_CRC;
          end if;
        end if;
      when WST_SEND_CRC =>
        v_TxD   := r.crc32(31-r.byte*8 downto 24-r.byte*8);
        c.TxD   <= not rev(v_TxD);
        c.Tx_En <= '1';
        if r.byte < 3 then
          r_n.byte <= r.byte + 1;
        else
          r_n.count <= 12;              -- generate the IFG - 12 bytes = 96
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
      ready_1 <= '0';
      ready_0 <= '0';
      state2  <= ST2_IDLE;
    elsif clk'event and clk = '1' then  -- rising clock edge
      ready_1 <= tx_ready;
      ready_0 <= ready_1;
      case state2 is
        when ST2_IDLE =>
          if start = '1' and ready_0 = '1' then
            cmd_only <= '0';
            start_0  <= '1';
            ready    <= '0';
            state2   <= ST2_WAIT_NOT_READY;
          elsif cmd_start = '1' and ready_0 = '1' then
            cmd_only <= '1';
            start_0  <= '1';
            ready    <= '0';
            state2   <= ST2_WAIT_NOT_READY;
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
