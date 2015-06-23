-------------------------------------------------------------------------------
-- Title      : FPGA Ethernet interface - descriptor manager
-- Project    : 
-------------------------------------------------------------------------------
-- File       : desc_manager.vhd
-- Author     : Wojciech M. Zabolotny (wzab@ise.pw.edu.pl)
-- License    : BSD License
-- Company    : 
-- Created    : 2012-03-30
-- Last update: 2014-10-23
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
use std.textio.all;
library work;
use work.pkt_ack_pkg.all;
use work.desc_mgr_pkg.all;
use work.pkt_desc_pkg.all;

entity desc_memory is

  port (
    clk       : in  std_logic;
    desc_we   : in  std_logic;
    desc_addr : in  integer range 0 to N_OF_PKTS-1;
    desc_out  : in  pkt_desc;
    desc_in   : out pkt_desc);

end desc_memory;

architecture beh1 of desc_memory is

  type T_PKT_DESC_MEM is array (0 to N_OF_PKTS-1) of std_logic_vector(pkt_desc_width-1 downto 0);
  signal desc_mem : T_PKT_DESC_MEM                              := (others => (others => '0'));
  signal din      : std_logic_vector(pkt_desc_width-1 downto 0) := (others => '0');
  signal dout     : std_logic_vector(pkt_desc_width-1 downto 0) := (others => '0');
  signal rdaddr   : integer range 0 to N_OF_PKTS-1;

  
begin  -- beh1

  din     <= pkt_desc_to_stlv(desc_out);
  desc_in <= stlv_to_pkt_desc(dout);

  process (clk)
  begin  -- process
    if (clk'event and clk = '1') then   -- rising clock edge
      if (desc_we = '1') then
        desc_mem(desc_addr) <= din;
      end if;
      rdaddr <= desc_addr;
    end if;
  end process;
  dout <= desc_mem(rdaddr);

end beh1;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
library work;
use work.pkt_ack_pkg.all;
use work.desc_mgr_pkg.all;
use work.pkt_desc_pkg.all;

entity desc_manager is
  
  generic (
    LOG2_N_OF_PKTS : integer := LOG2_N_OF_PKTS;
    N_OF_PKTS      : integer := N_OF_PKTS
    );                                  -- Number of packet_logi buffers

  port (
    -- Data input interface
    dta              : in  std_logic_vector(63 downto 0);
    dta_we           : in  std_logic;
    dta_eod          : in  std_logic;
    dta_ready        : out std_logic;
    -- ETH Sender interface
    pkt_number       : out unsigned(31 downto 0);
    seq_number       : out unsigned(15 downto 0);
    cmd_response_out : out std_logic_vector(12*8-1 downto 0);
    snd_cmd_start    : out std_logic;
    snd_start        : out std_logic;
    flushed          : out std_logic;
    snd_ready        : in  std_logic;

    -- Data memory interface
    dmem_addr       : out std_logic_vector(LOG2_NWRDS_IN_PKT+LOG2_N_OF_PKTS-1 downto 0);
    dmem_dta        : out std_logic_vector(63 downto 0);
    dmem_we         : out std_logic;
    -- Interface to the ACK FIFO
    ack_fifo_empty  : in  std_logic;
    ack_fifo_rd_en  : out std_logic;
    ack_fifo_dout   : in  std_logic_vector(pkt_ack_width-1 downto 0);
    -- User command interface
    cmd_code        : out std_logic_vector(15 downto 0);
    cmd_seq         : out std_logic_vector(15 downto 0);
    cmd_arg         : out std_logic_vector(31 downto 0);
    cmd_run         : out std_logic;
    cmd_retr_s      : out std_logic;
    cmd_ack         : in  std_logic;
    cmd_response_in : in  std_logic_vector(8*12-1 downto 0);
    retr_count      : out std_logic_vector(31 downto 0);
    --
    transmit_data   : in  std_logic;
    transm_delay    : out unsigned(31 downto 0);
    --
    dbg             : out std_logic_vector(3 downto 0);
    --
    clk             : in  std_logic;
    rst_n           : in  std_logic);

end desc_manager;

architecture dmgr_a1 of desc_manager is

  constant PKT_CNT_MAX : integer := 3000;


  function is_bigger (
    constant v1, v2 : unsigned(15 downto 0))
    return boolean is
    variable res : boolean;
    variable tmp : unsigned(15 downto 0);
  begin  -- function is_bigger
    -- subtract v2-v1 modulo 2**16
    tmp := v2-v1;
    -- if the result is "negative" - bit 15 is '1'
    -- and we consider v1 to be "bigger" (in modulo sense) than v2
    if tmp(15) = '1' then
      return true;
    else
      return false;
    end if;
    
  end function is_bigger;

  -- To simplify description of state machines, all registers are grouped
  -- in a record :

  type T_DESC_MGR_REGS is record
    cmd_ack        : std_logic;
    cmd_ack_0      : std_logic;
    cmd_run        : std_logic;
    cmd_retr       : std_logic;
    cmd_code       : unsigned(15 downto 0);
    cmd_seq        : unsigned(15 downto 0);
    cmd_arg        : unsigned(31 downto 0);
    pkt            : unsigned(31 downto 0);
    cur_pkt        : unsigned(31 downto 0);
    seq            : unsigned(15 downto 0);
    ack_seq        : unsigned(15 downto 0);
    retr_flag      : std_logic;
    flushed        : std_logic;
    all_pkt_count  : integer range 0 to PKT_CNT_MAX;
    retr_pkt_count : integer range 0 to PKT_CNT_MAX;
    retr_delay     : unsigned(31 downto 0);
    retr_count     : unsigned(31 downto 0);
    transm_delay   : unsigned(31 downto 0);
    nxt            : unsigned(LOG2_N_OF_PKTS-1 downto 0);
    tail_ptr       : unsigned(LOG2_N_OF_PKTS-1 downto 0);
    head_ptr       : unsigned(LOG2_N_OF_PKTS-1 downto 0);
    retr_ptr       : unsigned(LOG2_N_OF_PKTS-1 downto 0);  -- Number of the packet buffer, which is retransmitted
                                        -- when equal to head_ptr -
                                        -- retransmission is finished
    retr_nxt       : unsigned(LOG2_N_OF_PKTS-1 downto 0);  -- buffer, which will be
                                        -- retransmitted next
                                                           -- when equal to head_ptr -- no retransmission
                                                           -- is performed
  end record;

  constant DESC_MGR_REGS_INI : T_DESC_MGR_REGS := (
    retr_delay     => (others => '0'),
    retr_count     => (others => '0'),
    transm_delay   => to_unsigned(16, 32),
    all_pkt_count  => 0,
    retr_pkt_count => 0,
    cmd_ack_0      => '0',
    cmd_ack        => '0',
    cmd_run        => '0',
    cmd_retr       => '0',
    cmd_code       => (others => '0'),
    cmd_seq        => (others => '0'),
    cmd_arg        => (others => '0'),
    pkt            => (others => '0'),
    seq            => (others => '0'),
    ack_seq        => (others => '0'),
    retr_flag      => '0',
    flushed        => '0',
    cur_pkt        => (others => '0'),
    nxt            => (others => '0'),
    tail_ptr       => (others => '0'),
    head_ptr       => (others => '0'),
    retr_ptr       => (others => '0'),
    retr_nxt       => (others => '0')
    );

  -- To simplify setting of outputs of my Mealy state machine, all combinatorial
  -- outputs are grouped in a record
  type T_DESC_MGR_COMB is record
    dta_buf_free  : std_logic;
    desc_addr     : unsigned(LOG2_N_OF_PKTS-1 downto 0);
    desc_we       : std_logic;
    ack_rd        : std_logic;
    snd_start     : std_logic;
    snd_cmd_start : std_logic;
    desc_out      : pkt_desc;
  end record;

  constant DESC_MGR_COMB_DEFAULT : T_DESC_MGR_COMB :=
    (
      dta_buf_free  => '0',
      desc_addr     => (others => '0'),
      desc_we       => '0',
      ack_rd        => '0',
      snd_start     => '0',
      snd_cmd_start => '0',
      desc_out      => (
        confirmed   => '0',
        valid       => '0',
        sent        => '0',
        flushed     => '0',
        pkt         => (others => '0'),
        seq         => (others => '0')
        )
      );

  type T_DESC_MGR_STATE is (ST_DMGR_IDLE, ST_DMGR_CMD, ST_DMGR_START, ST_DMGR_RST, ST_DMGR_RST1,
                            ST_DMGR_ACK1, ST_DMGR_INS1, ST_DMGR_INS2, ST_DMGR_ACK_TAIL,
                            ST_DMGR_ACK_TAIL_1,
                            ST_DMGR_RETR, ST_DMGR_RETR_2);

  signal desc_in : pkt_desc;

  signal r, r_i                      : T_DESC_MGR_REGS  := DESC_MGR_REGS_INI;
  signal c                           : T_DESC_MGR_COMB;
  signal dmgr_state, dmgr_state_next : T_DESC_MGR_STATE := ST_DMGR_RST;
  attribute keep                     : string;
  attribute keep of dmgr_state       : signal is "true";

  signal dta_buf_full   : std_logic := '0';
  signal dta_buf_flush  : std_logic := '0';
  signal stored_dta_eod : std_logic := '0';

  signal ack_pkt_in : pkt_ack;

  signal wrd_addr : integer range 0 to NWRDS_IN_PKT-1;  -- We use 64-bit words, so the
                                        -- data word address is between
                                        -- 0 and 1023

  component desc_memory
    port (
      clk       : in  std_logic;
      desc_we   : in  std_logic;
      desc_addr : in  integer range 0 to N_OF_PKTS-1;
      desc_out  : in  pkt_desc;
      desc_in   : out pkt_desc);
  end component;


begin  -- dmgr_a1

  retr_count <= std_logic_vector(r.retr_count);

  transm_delay   <= r.transm_delay;
  pkt_number     <= r.pkt;
  seq_number     <= r.seq;
  flushed        <= r.flushed;
  dta_ready      <= not dta_buf_full;
  snd_start      <= c.snd_start;
  ack_fifo_rd_en <= c.ack_rd;

  cmd_code      <= std_logic_vector(r.cmd_code);
  cmd_seq       <= std_logic_vector(r.cmd_seq);
  cmd_arg       <= std_logic_vector(r.cmd_arg);
  cmd_run       <= r.cmd_run;
  cmd_retr_s    <= r.cmd_retr;
  snd_cmd_start <= c.snd_cmd_start;

  ack_pkt_in <= stlv_to_pkt_ack(ack_fifo_dout);

  -- Transmit command response only when the command is completed
  -- (to avoid transmiting unstable values, which could e.g. affect
  -- packet CRC calculations)
  cmd_response_out <= cmd_response_in when r.cmd_ack = r.cmd_run else (others => '0');

  -- Packet descriptors are stored in the desc_memory

  desc_memory_1 : desc_memory
    port map (
      clk       => clk,
      desc_we   => c.desc_we,
      desc_addr => to_integer(c.desc_addr),
      desc_out  => c.desc_out,
      desc_in   => desc_in);

  -- Process used to fill the buffer memory with the data to be transmitted
  -- We simply write words to the memory buffer pointed by r.head_ptr
  -- When we write the last (0xff-th) word, we signal that the buffer
  -- is full.
  -- Additionally, when the buffer is partially filled, but the transmission
  -- is stopped, we should also signal, that the buffer must be transmitted.
  -- However in this case we should also inform the recipient about it.
  -- How we can do it?
  dta_rcv : process (clk, rst_n)
  begin  -- process dta_rcv
    if rst_n = '0' then                 -- asynchronous reset (active low)
      wrd_addr       <= 0;
      dta_buf_flush  <= '0';
      dta_buf_full   <= '0';
      dmem_we        <= '0';
      stored_dta_eod <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      dmem_we <= '0';
      -- if we signalled "data full", we are only waiting for
      -- dta_buf_free;
      -- However even in this state we must receive the "dta_eod" signal
      if dta_buf_full = '1' then
        if dta_eod = '1' then
          stored_dta_eod <= '1';
        end if;
        if c.dta_buf_free = '1' then
          dta_buf_full  <= '0';
          dta_buf_flush <= '0';
          wrd_addr      <= 0;
        end if;
      else
        -- end of data is signalled, mark the last buffer as full
        if (dta_eod = '1') or (stored_dta_eod = '1') then
          -- Clear the stored eod
          stored_dta_eod <= '0';
          -- In the last word of the packet, write the number of written words
          dmem_addr      <= std_logic_vector(r.head_ptr) &
                            std_logic_vector(to_unsigned(NWRDS_IN_PKT-1, LOG2_NWRDS_IN_PKT));
          dmem_dta      <= std_logic_vector(to_unsigned(wrd_addr, 64));
          dmem_we       <= '1';
          dta_buf_flush <= '1';
          dta_buf_full  <= '1';
        -- if data write requested - write it
        elsif dta_we = '1' then
          dmem_addr <= std_logic_vector(r.head_ptr) &
                       std_logic_vector(to_unsigned(wrd_addr, LOG2_NWRDS_IN_PKT));
          dmem_we  <= '1';
          dmem_dta <= dta;
          if wrd_addr < NWRDS_IN_PKT-1 then
            wrd_addr <= wrd_addr + 1;
          else
            dta_buf_flush <= '0';
            dta_buf_full  <= '1';
          end if;
        end if;
      end if;
    end if;
  end process dta_rcv;


  c1 : process (ack_fifo_empty, ack_pkt_in, cmd_ack, desc_in,
                dmgr_state, dta_buf_full, dta_buf_flush, r, snd_ready)
  begin  -- process c1
    c             <= DESC_MGR_COMB_DEFAULT;  -- set defaults
    r_i           <= r;                 -- avoid latches
    -- Synchronize command acknowledge lines
    r_i.cmd_ack_0 <= cmd_ack;
    r_i.cmd_ack   <= r.cmd_ack_0;
    if r.retr_delay /= to_unsigned(0, r.retr_delay'length) then
      r_i.retr_delay <= r.retr_delay-1;
    end if;
    dmgr_state_next <= dmgr_state;
    -- State machine
    case dmgr_state is
      when ST_DMGR_RST =>
        dbg             <= x"1";
        dmgr_state_next <= ST_DMGR_RST1;
      when ST_DMGR_RST1 =>
        -- We should initialize the 0th position of list descriptors
        dbg                  <= x"2";
        c.desc_addr          <= r.head_ptr;
        c.desc_out           <= desc_in;
        c.desc_out.confirmed <= '0';
        c.desc_out.valid     <= '0';
        c.desc_out.sent      <= '0';
        c.desc_out.pkt       <= to_unsigned(0, 32);
        c.desc_we            <= '1';
        dmgr_state_next      <= ST_DMGR_IDLE;
      when ST_DMGR_IDLE =>
        dbg <= x"3";
        -- First we check, if there are any packets to acknowledge
        -- or commands to execute
        if ack_fifo_empty = '0' then
          if (to_integer(ack_pkt_in.cmd) = FCMD_ACK) or
            (to_integer(ack_pkt_in.cmd) = FCMD_NACK) then
            -- Prepare for reading of the command.
            c.desc_addr     <= ack_pkt_in.pkt(LOG2_N_OF_PKTS-1 downto 0);
            dmgr_state_next <= ST_DMGR_ACK1;
          else
            -- This is a command which requires sending of response.
            -- This will be handled by the cmd_proc block (in case
            -- of START and STOP it is not the most efficient way,
            -- but still sufficient).
            -- Always request transmission of result
            r_i.cmd_retr <= '1';
            -- Check if this is a new command (just checking the sequence number,
            -- to avoid more complex logic)
            if ack_pkt_in.seq /= r.cmd_seq then
              -- If no, store the command and it's argument, and order it to be executed
              r_i.cmd_code <= ack_pkt_in.cmd;
              r_i.cmd_seq  <= ack_pkt_in.seq;
              r_i.cmd_arg  <= ack_pkt_in.pkt;
            end if;
            c.ack_rd        <= '1';     -- Confirm, that the command was read
            dmgr_state_next <= ST_DMGR_CMD;
          end if;
        elsif dta_buf_full = '1' then
          -- We should handle reception of data.
          -- If the previously filled buffer is full, pass it for transmission,
          -- and allocate the next one.
          --
          -- Calculate the number of the packet, which shoud be the next "head"
          -- packet. We utilize the fact, that calculations are performed modulo
          -- N_OF_PKTS (because pointers have length of LOG2_N_OF_PKTS)
          r_i.nxt         <= r.head_ptr + 1;
          -- Prepare for reading of the current "head" descriptor
          c.desc_addr     <= r.head_ptr;
          dmgr_state_next <= ST_DMGR_INS1;
        elsif (r.tail_ptr /= r.head_ptr) and (r.retr_delay = to_unsigned(0, r.retr_delay'length)) then
          -- We need to (re)transmit some buffers
          -- prepare reading of the descriptor, which should be transmitted
          c.desc_addr     <= r.retr_nxt;
          dmgr_state_next <= ST_DMGR_RETR;
        elsif r.cmd_retr = '1' and (r.cmd_ack = r.cmd_run) and (r.retr_delay = to_unsigned(0, r.retr_delay'length)) then
          -- No data waiting for transmission, and the command response should
          -- be transmitted
          if snd_ready = '1' then
            r_i.retr_delay  <= r.transm_delay;
            r_i.cmd_retr    <= '0';
            c.snd_cmd_start <= '1';
          end if;
        end if;
      when ST_DMGR_CMD =>
        r_i.cmd_run     <= not r.cmd_run;
        dmgr_state_next <= ST_DMGR_IDLE;
      when ST_DMGR_INS1 =>
        dbg <= x"4";
        -- First we check, if there is free space, r.nxt is the number of the
        -- future head packet.
        if (r.nxt = r.tail_ptr) then
          -- No free place! The packet, which we would like to fill is still
          -- occupied.
          -- Return to idle, waiting until something is freed.
          -- In this case we should also force retransmission
          if r.retr_delay = 0 then
            c.desc_addr     <= r.retr_nxt;
            dmgr_state_next <= ST_DMGR_RETR;
          else
            dmgr_state_next <= ST_DMGR_IDLE;
          end if;
        else
          -- We can fill the next buffer
          -- First we mark the previous head packet
          -- as valid and not confirmed
          -- We also set the "flushed" status appropriately
          c.desc_addr          <= r.head_ptr;
          c.desc_out           <= desc_in;
          c.desc_out.confirmed <= '0';
          c.desc_out.valid     <= '1';
          if dta_buf_flush = '1' then
            c.desc_out.flushed <= '1';
          else
            c.desc_out.flushed <= '0';
          end if;
          c.desc_we       <= '1';
          -- Now we move the "head" pointer
          r_i.head_ptr    <= r.nxt;
          -- Increase the packet number!
          -- We utilize the fact, that packet number automatically
          -- wraps to 0 after sending of 2**32 packets!
          r_i.cur_pkt     <= r.cur_pkt + 1;
          dmgr_state_next <= ST_DMGR_INS2;
        end if;
      when ST_DMGR_INS2 =>
        dbg                  <= x"5";
        -- We fill the new head descriptor
        c.desc_addr          <= r.head_ptr;
        c.desc_out.pkt       <= r.cur_pkt;
        c.desc_out.confirmed <= '0';
        c.desc_out.valid     <= '0';
        c.desc_out.sent      <= '0';
        c.desc_out.flushed   <= '0';
        c.desc_we            <= '1';
        -- Signal, that the buffer is freed
        c.dta_buf_free       <= '1';
        dmgr_state_next      <= ST_DMGR_IDLE;
      when ST_DMGR_ACK1 =>
        dbg <= x"6";
        -- In this state the desc memory should respond with the data of the
        -- buffered packet, so we can state, if this packet is really correctly
        -- acknowledged (here we also ignore the NACK packets!
        case to_integer(ack_pkt_in.cmd) is
          when FCMD_ACK =>
            if (ack_pkt_in.pkt = desc_in.pkt) and
              (desc_in.valid = '1') then
              -- This is really correct, unconfirmed packet
              -- Increase the counter of not-repeated ACK packets
              -- Write the confirmation
              c.desc_addr          <= ack_pkt_in.pkt(LOG2_N_OF_PKTS-1 downto 0);
              c.desc_out           <= desc_in;
              c.desc_out.valid     <= '0';
              c.desc_out.confirmed <= '1';
              c.desc_we            <= '1';
              -- Here we also handle the case, if the acknowledged packet was
              -- the one which is now scheduled for retransmission...
              if ack_pkt_in.pkt(LOG2_N_OF_PKTS-1 downto 0) = r.retr_nxt then
                r_i.retr_nxt <= r.retr_nxt + 1;
              end if;
              -- Check, if we need to update the "tail" pointer
              if r.tail_ptr = ack_pkt_in.pkt(LOG2_N_OF_PKTS-1 downto 0) then
                c.ack_rd        <= '1';
                dmgr_state_next <= ST_DMGR_ACK_TAIL;
              else
                -- If this is not the tail pointer, it means, that some packets
                -- or acknowledgements have been lost
                -- We trigger retransmission of those packets
                r_i.ack_seq     <= ack_pkt_in.seq;
                r_i.retr_nxt    <= r.tail_ptr;
                -- Set the flag stating that only "earlier"  packets should be retransmitted
                r_i.retr_flag   <= '1';
                c.ack_rd        <= '1';
                dmgr_state_next <= ST_DMGR_IDLE;
              end if;
            else
              -- This packet was already confirmed
              -- just flush the ack_fifo
              c.ack_rd        <= '1';
              dmgr_state_next <= ST_DMGR_IDLE;
            end if;
          when FCMD_NACK=>
            -- This was a NACK command, currently we simply ignore it
            -- (later on we will use it to trigger retransmission).
            c.ack_rd        <= '1';
            dmgr_state_next <= ST_DMGR_IDLE;
          when others => null;
        end case;
      when ST_DMGR_ACK_TAIL =>
        dbg             <= x"7";
        c.desc_addr     <= r.tail_ptr;
        dmgr_state_next <= ST_DMGR_ACK_TAIL_1;
      when ST_DMGR_ACK_TAIL_1 =>
        dbg <= x"8";
        -- In this state we update the "tail" pointer if necessary
        if r.tail_ptr /= r.head_ptr then
          if desc_in.confirmed = '1' then
            r_i.tail_ptr <= r.tail_ptr + 1;  -- it will wrap to 0 automatically!
            c.desc_addr  <= r.tail_ptr + 1;
          -- We remain in that state, to check the next packet descriptor
          else
            -- We return to idle
            dmgr_state_next <= ST_DMGR_IDLE;
          end if;
        else
          -- Buffer is empty - return to idle
          dmgr_state_next <= ST_DMGR_IDLE;
        end if;
      when ST_DMGR_RETR =>
        dbg <= x"9";
        -- Here we handle the transmission of a new packet, 
        -- retransmission of not confirmed packet
        -- We must be sure, that the transmitter is ready
        if snd_ready = '0' then
          -- transmitter not ready, return to idle
          dmgr_state_next <= ST_DMGR_IDLE;
        else
          -- We will be able to send the next packet, but let's check if
          -- this is not the currently filled packet
          if r.retr_nxt = r.head_ptr then
            -- All packets (re)transmitted, go to the begining of the list
            r_i.retr_nxt    <= r.tail_ptr;
            -- Clear the flag stating that only packets older than the last
            -- acknowledged should be transmitted
            r_i.retr_flag   <= '0';
            -- and return to idle.
            dmgr_state_next <= ST_DMGR_IDLE;
          else
            -- before jumping to ST_DMGR_RETR, the address bus
            -- was set to the address of r.retr_nxt, so now
            -- we can read the descriptor, and check if the packet
            -- needs to be retransmitted at all...
            r_i.pkt      <= desc_in.pkt;
            r_i.flushed  <= desc_in.flushed;
            r_i.retr_ptr <= r.retr_nxt;
            r_i.retr_nxt <= r.retr_nxt + 1;
            if desc_in.valid = '1' and desc_in.confirmed = '0' and
              ((r.retr_flag = '0') or is_bigger(r.ack_seq, desc_in.seq)) then
              if desc_in.sent = '1' then
                -- Increase count of retransmitted packets for
                -- adaptive adjustment of delay
                if r.retr_pkt_count < PKT_CNT_MAX then
                  r_i.retr_pkt_count <= r.retr_pkt_count + 1;
                end if;
                -- Adjust the cumulative retransmission counter
                r_i.retr_count <= r.retr_count + 1;
              end if;
              -- Increase count of all packets for adaptive adjustment
              -- of delay
              if r.all_pkt_count < PKT_CNT_MAX then
                r_i.all_pkt_count <= r.all_pkt_count + 1;
              end if;
              -- Mark the packet as sent
              c.desc_addr     <= r.retr_nxt;
              c.desc_out      <= desc_in;
              c.desc_out.sent <= '1';
              -- increase the sequential number
              r_i.seq         <= r.seq + 1;
              -- store the packet sequential number
              c.desc_out.seq  <= r.seq + 1;
              c.desc_we       <= '1';
              dmgr_state_next <= ST_DMGR_RETR_2;
            else
              dmgr_state_next <= ST_DMGR_IDLE;
            end if;
          end if;
        end if;
      when ST_DMGR_RETR_2 =>
        dbg         <= x"a";
        -- In this state, we simply trigger the sender!
        c.snd_start <= '1';
        if r.cmd_ack = r.cmd_run then
          -- command response will be transmitted, so clear the related flag
          r_i.cmd_retr <= '0';
        end if;
        r_i.retr_delay <= r.transm_delay;
        -- And we update the delay using the packet statistics
        -- You may change the constants used in expressions
        -- below to change speed of adjustment
        if r.all_pkt_count >= PKT_CNT_MAX then
          if r.retr_pkt_count < PKT_CNT_MAX/300 then
            if r.transm_delay > 16 then
              r_i.transm_delay <= r.transm_delay-r.transm_delay/16;
            end if;
          elsif r.retr_pkt_count > PKT_CNT_MAX/100 then
            if r.transm_delay < 1000000 then
              r_i.transm_delay <= r.transm_delay+r.transm_delay/4;
            end if;
          end if;
          r_i.all_pkt_count  <= 0;
          r_i.retr_pkt_count <= 0;
        end if;
        dmgr_state_next <= ST_DMGR_IDLE;
      when others => null;
    end case;
  end process c1;

-- Synchronous process
  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      r          <= DESC_MGR_REGS_INI;
      dmgr_state <= ST_DMGR_RST;
    elsif clk'event and clk = '1' then  -- rising clock edge
      r          <= r_i;
      dmgr_state <= dmgr_state_next;
    end if;
  end process;

end dmgr_a1;



