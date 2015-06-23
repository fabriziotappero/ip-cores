-------------------------------------------------------------------------------
-- Title      : FPGA Ethernet interface - block receiving packets from Ethernet MAC
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
library work;
use work.pkt_ack_pkg.all;

entity eth_receiver is
  
  port (
    -- Configuration
    peer_mac       : out std_logic_vector(47 downto 0);
    my_mac         : in  std_logic_vector(47 downto 0);
    my_ether_type  : in  std_logic_vector(15 downto 0);
    transmit_data  : out std_logic;
    restart        : out std_logic;
    -- ACK FIFO interface
    ack_fifo_full  : in  std_logic;
    ack_fifo_wr_en : out std_logic;
    ack_fifo_din   : out std_logic_vector(pkt_ack_width-1 downto 0);
    -- System interface
    clk            : in  std_logic;
    rst_n          : in  std_logic;
    -- MAC inerface
    Rx_mac_pa      : in  std_logic;
    Rx_mac_ra      : in  std_logic;
    Rx_mac_rd      : out std_logic;
    Rx_mac_data    : in  std_logic_vector(31 downto 0);
    Rx_mac_BE      : in  std_logic_vector(1 downto 0);
    Rx_mac_sop     : in  std_logic;
    Rx_mac_eop     : in  std_logic
    );

end eth_receiver;


architecture beh1 of eth_receiver is

  type T_STATE is (ST_IDLE, ST_ACK_1, ST_NACK_1, ST_SET_DELAY, ST_READ_SRC1, ST_READ_SRC2, ST_READ_OP);

  type T_RCV_REGS is record
    state         : T_STATE;
    sender        : std_logic_vector(47 downto 0);
    transmit_data : std_logic;
    peer_mac      : std_logic_vector(47 downto 0);
  end record;
  
  constant RCV_REGS_INI : T_RCV_REGS := (
    state         => ST_IDLE,
    sender        => (others => '0'),
    transmit_data => '0',
    peer_mac      => (others => '0')
    );

  signal r, r_i : T_RCV_REGS := RCV_REGS_INI;

  type T_RCV_COMB is record
    ack_fifo_wr_en : std_logic;
    Rx_mac_rd      : std_logic;
    ack_fifo_din   : std_logic_vector(pkt_ack_width-1 downto 0);
    restart        : std_logic;
  end record;

  constant RCV_COMB_DEFAULT : T_RCV_COMB := (
    ack_fifo_wr_en => '0',
    Rx_mac_rd      => '0',
    ack_fifo_din   => (others => '0'),
    restart        => '0'
    );

  signal c : T_RCV_COMB := RCV_COMB_DEFAULT;
  
begin  -- beh1

  transmit_data  <= r.transmit_data;
  peer_mac       <= r.peer_mac;
  ack_fifo_din   <= c.ack_fifo_din;
  ack_fifo_wr_en <= c.ack_fifo_wr_en;
  Rx_mac_rd      <= c.Rx_mac_rd;
  restart        <= c.restart;

  -- Reading of ethernet data
  rdp1 : process (clk, rst_n)
  begin  -- process rdp1
    if rst_n = '0' then                 -- asynchronous reset (active low)
      r <= RCV_REGS_INI;
    elsif clk'event and clk = '1' then  -- rising clock edge
      r <= r_i;
    end if;
  end process rdp1;

  rdp2 : process (Rx_mac_data, Rx_mac_pa, Rx_mac_ra, Rx_mac_sop, ack_fifo_full,
                  my_ether_type, my_mac, r, rx_mac_pa)

    variable ack_pkt_in : pkt_ack;

  begin  -- process
    c   <= RCV_COMB_DEFAULT;
    r_i <= r;
    case r.state is
      when ST_IDLE =>
        if Rx_mac_ra = '1' then
          c.Rx_mac_rd <= '1';
          if Rx_mac_pa = '1' then
            if Rx_mac_sop = '1' then
              if Rx_mac_data(31 downto 0) = my_mac(47 downto 16) then
                r_i.state <= ST_READ_SRC1;
              else
                r_i.state <= ST_IDLE;
              end if;
            end if;
          end if;
        end if;
      when ST_READ_SRC1 =>
        if Rx_mac_ra = '1' then
          c.Rx_mac_rd <= '1';
          if Rx_mac_pa = '1' then
            if Rx_mac_sop = '1' then
              -- This shouldn't happen!
              r_i.state <= ST_IDLE;
            else
              if Rx_mac_data(31 downto 16) = my_mac(15 downto 0) then
                r_i.sender(47 downto 32) <= Rx_mac_data(15 downto 0);
                r_i.state                <= ST_READ_SRC2;
              else
                r_i.state <= ST_IDLE;
              end if;
            end if;
          end if;
        end if;
      when ST_READ_SRC2 =>
        if Rx_mac_ra = '1' then
          c.Rx_mac_rd <= '1';
          if Rx_mac_pa = '1' then
            if Rx_mac_sop = '1' then
              -- This shouldn't happen!
              r_i.state <= ST_IDLE;
            else
              r_i.sender(31 downto 0) <= Rx_mac_data;
              r_i.state               <= ST_READ_OP;
            end if;
          end if;
        end if;
      when ST_READ_OP =>
        if Rx_mac_ra = '1' then
          c.Rx_mac_rd <= '1';
          if rx_mac_pa = '1' then
            if Rx_mac_sop = '1' then
              -- This shouldn't happen!
              r_i.state <= ST_IDLE;
              -- check the Ethernet type
            elsif Rx_mac_data(31 downto 16) /= my_ether_type then
              r_i.state <= ST_IDLE;
            else
              -- This is a packet in our protocol, so we can update
              -- the peer address
              r_i.peer_mac <= r.sender;
              -- check the command
              case Rx_mac_data(15 downto 0) is
                when x"0001" =>
                  -- Start transmission command
                  r_i.transmit_data <= '1';
                  r_i.state         <= ST_IDLE;
                when x"0002" =>
                  -- Stop transmission command
                  r_i.transmit_data <= '0';
                  r_i.state         <= ST_IDLE;
                when x"0003" =>
                  -- Packet ACK command
                  r_i.state <= ST_ACK_1;
                when x"0004" =>
                  -- Packet NACK command (currently not used)
                  r_i.state <= ST_NACK_1;
                when x"0005" =>
                  -- Stop transmission and retransmission
                  c.restart <= '1';
                  r_i.state <= ST_IDLE;
                when others =>
                  r_i.state <= ST_IDLE;
              end case;
            end if;
          end if;
        end if;
      when ST_ACK_1 =>
        if Rx_mac_ra = '1' then
          c.Rx_mac_rd <= '1';
          if Rx_mac_pa = '1' then
            if Rx_mac_sop = '1' then
              -- This shouldn't happen!
              r_i.state <= ST_IDLE;
            else
              -- put the ACK info int the FIFO queue
              -- (if FIFO is full, we simply drop the packet)
              if ack_fifo_full = '0' then
                ack_pkt_in.cmd   := to_unsigned(3, ack_pkt_in.cmd'length);
                ack_pkt_in.set   := unsigned(Rx_mac_data(31 downto 16));
                ack_pkt_in.pkt   := "00" & unsigned(Rx_mac_data(15 downto 10));
                c.ack_fifo_din   <= pkt_ack_to_stlv(ack_pkt_in);
                c.ack_fifo_wr_en <= '1';
              end if;
              r_i.state <= ST_IDLE;
            end if;
          end if;
        end if;
      when ST_NACK_1 =>
        if Rx_mac_ra = '1' then
          c.Rx_mac_rd <= '1';
          if Rx_mac_pa = '1' then
            if Rx_mac_sop = '1' then
              -- This shouldn't happen!
              r_i.state <= ST_IDLE;
            else
              if ack_fifo_full = '0' then
                -- put the ACK info int the FIFO queue
                -- (if FIFO is full, we simply drop the packet)
                ack_pkt_in.cmd   := to_unsigned(4, ack_pkt_in.cmd'length);
                ack_pkt_in.set   := unsigned(Rx_mac_data(31 downto 16));
                ack_pkt_in.pkt   := "00" & unsigned(Rx_mac_data(15 downto 10));
                c.ack_fifo_din   <= pkt_ack_to_stlv(ack_pkt_in);
                c.ack_fifo_wr_en <= '1';
              end if;
              r_i.state <= ST_IDLE;
            end if;
          end if;
        end if;
      when others => null;
    end case;
  end process rdp2;

end beh1;
