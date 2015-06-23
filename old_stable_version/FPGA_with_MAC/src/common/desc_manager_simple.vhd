-------------------------------------------------------------------------------
-- Title      : FPGA Ethernet interface - descriptor manager
-- Project    : 
-------------------------------------------------------------------------------
-- File       : desc_manager.vhd
-- Author     : Wojciech M. Zabolotny (wzab@ise.pw.edu.pl)
-- License    : BSD License
-- Company    : 
-- Created    : 2012-03-30
-- Last update: 2012-08-30
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
use ieee.std_logic_textio.all;
library work;
use work.pkt_ack_pkg.all;

package desc_mgr_pkg is

  constant N_OF_PKTS : integer := 32;
  constant N_OF_SETS : integer := 65536;

  type T_PKT_DESC is record
    set       : integer range 0 to N_OF_SETS-1;  -- number of sets
    confirmed : std_logic;
    valid     : std_logic;
    sent      : std_logic;
  end record;

end desc_mgr_pkg;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
library work;
use work.pkt_ack_pkg.all;
use work.desc_mgr_pkg.all;

-- The below implementation of the descriptor memory is awfull,
-- but seemed to be necessary to force XST to infer it as an
-- single port BRAM.
-- I simply provide vector long enough to accomodate my T_PKT_DESC
-- type, and hope that the synthesis tool (XST) will optimize out
-- unused bits.should be inferred as block memory (so be carefull
-- when modifying the below process)!

entity desc_memory is

  port (
    clk       : in  std_logic;
    desc_we   : in  std_logic;
    desc_addr : in  integer range 0 to N_OF_PKTS-1;
    desc_out  : in  T_PKT_DESC;
    desc_in   : out T_PKT_DESC);

end desc_memory;

architecture beh1 of desc_memory is

  type T_PKT_DESC_MEM is array (0 to N_OF_PKTS-1) of unsigned(22 downto 0);
  signal desc_mem : T_PKT_DESC_MEM        := (others => (others => '0'));
  signal din      : unsigned(22 downto 0) := (others => '0');
  signal dout     : unsigned(22 downto 0) := (others => '0');
  signal rdaddr   : integer range 0 to N_OF_PKTS-1;
  
begin  -- beh1

  process (desc_out, dout)
  begin  -- process
    din               <= (others => '0');
    din(22)           <= desc_out.valid;
    din(21)           <= desc_out.confirmed;
    din(20)           <= desc_out.sent;
    din(19 downto 0)  <= to_unsigned(desc_out.set, 20);
    desc_in.valid     <= dout(22);
    desc_in.confirmed <= dout(21);
    desc_in.sent      <= dout(20);
    desc_in.set       <= to_integer(dout(19 downto 0));
  end process;

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

entity desc_manager is
  
  generic (
    N_OF_PKTS : integer := 64);         -- Number of packet_logi buffers

  port (
    -- Data input interface
    dta        : in  std_logic_vector(31 downto 0);
    dta_we     : in  std_logic;
    dta_ready  : out std_logic;
    -- ETH Sender interface
    set_number : out unsigned(15 downto 0);
    pkt_number : out unsigned(15 downto 0);
    snd_start  : out std_logic;
    snd_ready  : in  std_logic;

    -- Data memory interface
    dmem_addr      : out std_logic_vector(13 downto 0);
    dmem_dta       : out std_logic_vector(31 downto 0);
    dmem_we        : out std_logic;
    -- Interface to the ACK FIFO
    ack_fifo_empty : in  std_logic;
    ack_fifo_rd_en : out std_logic;
    ack_fifo_dout  : in  std_logic_vector(pkt_ack_width-1 downto 0);

    --
    transmit_data : in  std_logic;
    transm_delay  : out unsigned(31 downto 0);

    --
    clk   : in std_logic;
    rst_n : in std_logic);

end desc_manager;

architecture dmgr_a1 of desc_manager is

  constant PKT_CNT_MAX : integer := 10000;

  -- To simplify description of state machines, all registers are grouped
  -- in a record:

  type T_DESC_MGR_REGS is record
    set            : integer range 0 to N_OF_SETS-1;
    cur_set        : integer range 0 to N_OF_SETS-1;
    all_pkt_count  : integer range 0 to PKT_CNT_MAX;
    retr_pkt_count : integer range 0 to PKT_CNT_MAX;
    retr_delay     : unsigned(31 downto 0);
    transm_delay   : unsigned(31 downto 0);
    nxt            : integer range 0 to N_OF_PKTS-1;
    tail_ptr       : integer range 0 to N_OF_PKTS-1;
    head_ptr       : integer range 0 to N_OF_PKTS-1;
    retr_ptr       : integer range 0 to N_OF_PKTS-1;  -- buffer, which is retransmitted
                                        -- when equal to head_ptr -
                                        -- retransmission is finished
    retr_nxt       : integer range 0 to N_OF_PKTS-1;  -- buffer, which will be
                                                      -- retransmitted next
                                                      -- when equal to head_ptr -- no retransmission
                                                      -- is performed
  end record;

  constant DESC_MGR_REGS_INI : T_DESC_MGR_REGS := (
    retr_delay     => (others => '0'),
    transm_delay   => to_unsigned(10000, 32),
    all_pkt_count  => 0,
    retr_pkt_count => 0,
    set            => 0,
    cur_set        => 0,
    nxt            => 0,
    tail_ptr       => 0,
    head_ptr       => 0,
    retr_ptr       => 0,
    retr_nxt       => 0
    );

  -- To simplify setting of outputs of my Mealy state machine, all combinatorial
  -- outputs are grouped in a record
  type T_DESC_MGR_COMB is record
    dta_buf_free : std_logic;
    desc_addr    : integer range 0 to N_OF_PKTS-1;
    desc_we      : std_logic;
    ack_rd       : std_logic;
    snd_start    : std_logic;
    desc_out     : T_PKT_DESC;
  end record;
  
  constant DESC_MGR_COMB_DEFAULT : T_DESC_MGR_COMB := (
    dta_buf_free => '0',
    desc_addr    => 0,
    desc_we      => '0',
    ack_rd       => '0',
    snd_start    => '0',
    desc_out     => (confirmed => '0', valid => '0', sent => '0', set => 0)
    );

  type T_DESC_MGR_STATE is (ST_DMGR_IDLE, ST_DMGR_START, ST_DMGR_RST, ST_DMGR_RST1,
                            ST_DMGR_ACK1, ST_DMGR_INS1, ST_DMGR_INS2, ST_DMGR_ACK_TAIL,
                            ST_DMGR_ACK_TAIL_1,
                            ST_DMGR_RETR, ST_DMGR_RETR_2);

  signal desc_in : T_PKT_DESC;

  signal r, r_i                      : T_DESC_MGR_REGS  := DESC_MGR_REGS_INI;
  signal c                           : T_DESC_MGR_COMB;
  signal dmgr_state, dmgr_state_next : T_DESC_MGR_STATE := ST_DMGR_RST;
  attribute keep                     : string;
  attribute keep of dmgr_state       : signal is "true";

  signal dta_buf_full : std_logic := '0';

  signal ack_pkt_in : pkt_ack;

  signal wrd_addr : integer range 0 to 255;

  component desc_memory
    port (
      clk       : in  std_logic;
      desc_we   : in  std_logic;
      desc_addr : in  integer range 0 to N_OF_PKTS-1;
      desc_out  : in  T_PKT_DESC;
      desc_in   : out T_PKT_DESC);
  end component;


begin  -- dmgr_a1

  transm_delay   <= r.transm_delay;
  set_number     <= to_unsigned(r.set, 16);
  pkt_number     <= to_unsigned(r.retr_ptr, 16);
  dta_ready      <= not dta_buf_full;
  snd_start      <= c.snd_start;
  ack_fifo_rd_en <= c.ack_rd;

  ack_pkt_in <= stlv_to_pkt_ack(ack_fifo_dout);


  -- Packet descriptors are stored in the desc_memory

  desc_memory_1 : desc_memory
    port map (
      clk       => clk,
      desc_we   => c.desc_we,
      desc_addr => c.desc_addr,
      desc_out  => c.desc_out,
      desc_in   => desc_in);

  -- Process used to fill the buffer memory with the data to be transmitted
  -- We simply write words to the memory buffer pointed by r.head_ptr
  -- When we write the last (0xff-th) word, we signal that the buffer
  -- is full. Only after reception of 
  dta_rcv : process (clk, rst_n)
  begin  -- process dta_rcv
    if rst_n = '0' then                 -- asynchronous reset (active low)
      wrd_addr     <= 0;
      dta_buf_full <= '0';
      dmem_we      <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      dmem_we <= '0';
      -- if we signalled "data full", we are only waiting for
      -- dta_buf_free;
      if dta_buf_full = '1' then
        if c.dta_buf_free = '1' then
          dta_buf_full <= '0';
          wrd_addr     <= 0;
        end if;
      else
        -- if data write requested - write it
        if dta_we = '1' then
          dmem_addr <= std_logic_vector(to_unsigned(r.head_ptr, 6)) &
                       std_logic_vector(to_unsigned(wrd_addr, 8));
          dmem_we  <= '1';
          dmem_dta <= dta;
          if wrd_addr < 255 then
            wrd_addr <= wrd_addr + 1;
          else
            dta_buf_full <= '1';
          end if;
        end if;
      end if;
    end if;
  end process dta_rcv;


  c1 : process (ack_fifo_empty, ack_pkt_in, desc_in, dmgr_state, dta_buf_full,
                r, snd_ready)
  begin  -- process c1
    c   <= DESC_MGR_COMB_DEFAULT;       -- set defaults
    r_i <= r;                           -- avoid latches

    if r.retr_delay /= to_unsigned(0, r.retr_delay'length) then
      r_i.retr_delay <= r.retr_delay-1;
    end if;
    dmgr_state_next <= dmgr_state;
    -- State machine
    case dmgr_state is
      when ST_DMGR_RST =>
        dmgr_state_next <= ST_DMGR_RST1;
      when ST_DMGR_RST1 =>
        -- We should initialize the 0th position of list descriptors
        c.desc_addr          <= r.head_ptr;
        c.desc_out           <= desc_in;
        c.desc_out.confirmed <= '0';
        c.desc_out.valid     <= '0';
        c.desc_out.sent      <= '0';
        c.desc_out.set       <= 0;
        c.desc_we            <= '1';
        dmgr_state_next      <= ST_DMGR_IDLE;
      when ST_DMGR_IDLE =>
        -- First we check, if there are any packets to acknowledge
        if ack_fifo_empty = '0' then
          -- Read the description of the acknowledged packet
          c.desc_addr     <= to_integer(ack_pkt_in.pkt);
          dmgr_state_next <= ST_DMGR_ACK1;
        elsif dta_buf_full = '1' then
          -- We should handle reception of data.
          -- If the previously filled buffer is full, pass it for transmission,
          -- and allocate the next one.
          --
          -- Calculate the number of the packet, which shoud be the next "head"
          -- packet.
          if r.head_ptr = N_OF_PKTS-1 then
            r_i.nxt <= 0;
          else
            r_i.nxt <= r.head_ptr + 1;
          end if;
          -- Prepare for reading of the current "head" descriptor
          c.desc_addr     <= r.head_ptr;
          dmgr_state_next <= ST_DMGR_INS1;
        elsif (r.tail_ptr /= r.head_ptr) and (r.retr_delay = to_unsigned(0, r.retr_delay'length)) then
          -- We need to (re)transmit some buffers
          -- prepare reading of the descriptor, which should be transmitted
          c.desc_addr     <= r.retr_nxt;
          dmgr_state_next <= ST_DMGR_RETR;
        end if;
      when ST_DMGR_INS1 =>
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
          c.desc_addr          <= r.head_ptr;
          c.desc_out           <= desc_in;
          c.desc_out.confirmed <= '0';
          c.desc_out.valid     <= '1';
          c.desc_we            <= '1';
          -- Now we move the "head" pointer
          r_i.head_ptr         <= r.nxt;
          -- Increase the set number if we wrapped around
          if r.nxt = 0 then
            if r.cur_set = N_OF_SETS-1 then
              r_i.cur_set <= 0;
            else
              r_i.cur_set <= r.cur_set + 1;
            end if;
          end if;
          dmgr_state_next <= ST_DMGR_INS2;
        end if;
      when ST_DMGR_INS2 =>
        -- We fill the new head descriptor
        c.desc_addr          <= r.head_ptr;
        c.desc_out.set       <= r.cur_set;
        c.desc_out.confirmed <= '0';
        c.desc_out.valid     <= '0';
        c.desc_out.sent      <= '0';
        c.desc_we            <= '1';
        -- Signal, that the buffer is freed
        c.dta_buf_free       <= '1';
        dmgr_state_next      <= ST_DMGR_IDLE;
      when ST_DMGR_ACK1 =>
        -- In this state the desc memory should respond with the data of the
        -- buffered packet, so we can state, if this packet is really correctly
        -- acknowledged (here we also ignore the NACK packets!
        if (ack_pkt_in.set = desc_in.set) and
          (ack_pkt_in.cmd = to_unsigned(3,ack_pkt_in.cmd'length)) and 
          (desc_in.valid = '1') then
          -- This is really correct, unconfirmed packet
          -- Increase the counter of not-repeated ACK packets
          -- Write the confirmation
          c.desc_addr          <= to_integer(ack_pkt_in.pkt);
          c.desc_out           <= desc_in;
          c.desc_out.valid     <= '0';
          c.desc_out.confirmed <= '1';
          c.desc_we            <= '1';
          -- Here we also handle the case, if the acknowledged packet was
          -- the one which is now scheduled for retransmission...
          if ack_pkt_in.pkt = r.retr_nxt then
            if r.retr_nxt < N_OF_PKTS-1 then
              r_i.retr_nxt <= r.retr_nxt + 1;
            else
              r_i.retr_nxt <= 0;
            end if;
          end if;
          -- Check, if we need to update the "tail" pointer
          if r.tail_ptr = ack_pkt_in.pkt then
            c.ack_rd        <= '1';
            dmgr_state_next <= ST_DMGR_ACK_TAIL;
          else
            c.ack_rd        <= '1';
            dmgr_state_next <= ST_DMGR_IDLE;
          end if;
        else
          -- This packet was already confirmed or it was NACK
          -- just flush the ack_fifo
          c.ack_rd        <= '1';
          dmgr_state_next <= ST_DMGR_IDLE;
        end if;
      when ST_DMGR_ACK_TAIL =>
        c.desc_addr     <= r.tail_ptr;
        dmgr_state_next <= ST_DMGR_ACK_TAIL_1;
      when ST_DMGR_ACK_TAIL_1 =>
        -- In this state we update the "tail" pointer if necessary
        if r.tail_ptr /= r.head_ptr then
          if desc_in.confirmed = '1' then
            if r.tail_ptr < N_OF_PKTS-1 then
              r_i.tail_ptr <= r.tail_ptr + 1;
              c.desc_addr  <= r.tail_ptr + 1;
            else
              r_i.tail_ptr <= 0;
              c.desc_addr  <= 0;
            end if;
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
            -- and return to idle.
            r_i.retr_nxt    <= r.tail_ptr;
            dmgr_state_next <= ST_DMGR_IDLE;
          else
            -- before jumping to ST_DMGR_RETR, the address bus
            -- was set to the address of r.retr_nxt, so now
            -- we can read the descriptor, and check if the packet
            -- needs to be retransmitted at all...
            r_i.set      <= desc_in.set;
            r_i.retr_ptr <= r.retr_nxt;
            if r.retr_nxt < N_OF_PKTS-1 then
              r_i.retr_nxt <= r.retr_nxt + 1;
            else
              r_i.retr_nxt <= 0;
            end if;
            if desc_in.valid = '1' and desc_in.confirmed = '0' then
              if desc_in.sent = '1' then
                -- Increase count of retransmitted packets for
                -- adaptive adjustment of delay
                if r.retr_pkt_count < PKT_CNT_MAX then
                  r_i.retr_pkt_count <= r.retr_pkt_count + 1;
                end if;
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
              c.desc_we       <= '1';
              dmgr_state_next <= ST_DMGR_RETR_2;
            else
              dmgr_state_next <= ST_DMGR_IDLE;
            end if;
          end if;
        end if;
      when ST_DMGR_RETR_2 =>
        -- In this state, we simply trigger the sender!
        c.snd_start    <= '1';
        r_i.retr_delay <= r.transm_delay;
        -- And we update the delay using the packet statistics
        -- You may change the constants used in expressions
        -- below to change speed of adjustment
        if r.all_pkt_count >= PKT_CNT_MAX then
          if r.retr_pkt_count < PKT_CNT_MAX/32 then
            if r.transm_delay > 32 then
              r_i.transm_delay <= r.transm_delay-r.transm_delay/4;
            end if;
          elsif r.retr_pkt_count > PKT_CNT_MAX/8 then
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

-- Process debugging the descriptors memory - for simulation only!
--  process (clk, rst_n)
--    variable L : line;
--  begin  -- process
--    if rst_n = '0' then                 -- asynchronous reset (active low)
--      null;
--    elsif clk'event and clk = '1' then  -- rising clock edge
--      if c.desc_we = '1' then
--        write(L, string'("nr="));
--        write(L, c.desc_addr);
--        write(L, string'(" set="));
--        write(L, c.desc_out.set);
--        write(L, string'(" valid="));
--        --write(L,c.desc_out.valid);
--        if c.desc_out.valid = '1' then
--          write(L, string'("1"));
--        else
--          write(L, string'("0"));
--        end if;
--        write(L, string'(" confirmed="));
--        --write(L,c.desc_out.valid);
--        if c.desc_out.confirmed = '1' then
--          write(L, string'("1"));
--        else
--          write(L, string'("0"));
--        end if;
--        write(L, string'(" r.tail="));
--        write(L, r.tail_ptr);
--        write(L, string'(" r.head="));
--        write(L, r.head_ptr);
--        writeline(output, L);
--      end if;
--    end if;
--  end process;

end dmgr_a1;



