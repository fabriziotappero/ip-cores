-------------------------------------------------------------------------------
-- Title      : FPGA Ethernet interface - block receiving packets from MII PHY
-- Project    : 
-------------------------------------------------------------------------------
-- File       : eth_receiver4.vhd
-- Author     : Wojciech M. Zabolotny (wzab@ise.pw.edu.pl)
-- License    : BSD License
-- Company    : 
-- Created    : 2012-03-30
-- Last update: 2013-04-21
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

-- Uwaga! Tu mamy rzeczywiste problemy z obsluga odebranych pakietow!
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.pkt_ack_pkg.all;
use work.PCK_CRC32_D8.all;

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
    dbg            : out std_logic_vector(3 downto 0);
    -- MAC inerface
    Rx_Clk         : in  std_logic;
    Rx_Er          : in  std_logic;
    Rx_Dv          : in  std_logic;
    RxD            : in  std_logic_vector(7 downto 0)
    );

end eth_receiver;


architecture beh1 of eth_receiver is

  type T_STATE is (ST_RCV_IDLE, ST_RCV_PREAMB, ST_RCV_DEST, ST_RCV_SOURCE, ST_RCV_CMD,
                   ST_RCV_WAIT_IDLE, ST_RCV_ARGS, ST_RCV_PROCESS, ST_RCV_UPDATE,
                   ST_RCV_TRAILER);



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


  type T_RCV_REGS is record
    state         : T_STATE;
    transmit_data : std_logic;
    restart       : std_logic;
    update_flag   : std_logic;
    count         : integer;
    dbg         : std_logic_vector(3 downto 0);
    crc32         : std_logic_vector(31 downto 0);
    cmd           : std_logic_vector(31 downto 0);
    arg           : std_logic_vector(31 downto 0);
    mac_addr      : std_logic_vector(47 downto 0);
    peer_mac      : std_logic_vector(47 downto 0);
  end record;

  constant RCV_REGS_INI : T_RCV_REGS := (
    state         => ST_RCV_IDLE,
    transmit_data => '0',
    restart       => '0',
    update_flag   => '0',
    count         => 0,
    dbg         => (others => '0'),
    crc32         => (others => '0'),
    cmd           => (others => '0'),
    arg           => (others => '0'),
    mac_addr      => (others => '0'),
    peer_mac      => (others => '0')
    );

  signal r, r_n : T_RCV_REGS := RCV_REGS_INI;

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

  signal rx_rst_n, rx_rst_n_0, rx_rst_n_1          : std_logic := '0';
  signal update_flag_0, update_flag_1, update_flag : std_logic := '0';

begin  -- beh1

  ack_fifo_din   <= c.ack_fifo_din;
  ack_fifo_wr_en <= c.ack_fifo_wr_en;

  dbg <= r.dbg;

  -- Reading of ethernet data
  rdp1 : process (Rx_Clk, rx_rst_n)
  begin  -- process rdp1
    if rx_rst_n = '0' then              -- asynchronous reset (active low)
      r <= RCV_REGS_INI;
    elsif Rx_Clk'event and Rx_Clk = '1' then  -- rising clock edge
      r <= r_n;
    end if;
  end process rdp1;

  rdp2 : process (RxD, Rx_Dv, ack_fifo_full, my_ether_type, my_mac, r,
                  update_flag)

    variable ack_pkt_in   : pkt_ack;
    variable v_mac_addr   : std_logic_vector(47 downto 0);
    variable v_cmd, v_arg : std_logic_vector(31 downto 0);
    
  begin  -- process
    c   <= RCV_COMB_DEFAULT;
    r_n <= r;
    --dbg <= "1111";
    case r.state is
      when ST_RCV_IDLE =>
        --dbg <= "0000";
        if Rx_Dv = '1' then
          if RxD = x"55" then
            r_n.count <= 1;
            r_n.state <= ST_RCV_PREAMB;
          end if;
        end if;
      when ST_RCV_PREAMB =>
        --dbg <= "0001";
        if Rx_Dv = '0' then
          -- interrupted preamble reception
          r_n.state <= ST_RCV_IDLE;
        elsif RxD = x"55" then
          if r.count < 7 then
            r_n.count <= r.count + 1;
          end if;
        elsif (RxD = x"d5") and (r.count = 7) then  --D
          -- We start reception of the packet
          r_n.crc32 <= (others => '1');
          r_n.count <= 0;
          -- First we receive the sender address
          r_n.state <= ST_RCV_DEST;
        else
          -- something wrong happened during preamble detection
          r_n.state <= ST_RCV_WAIT_IDLE;
        end if;
      when ST_RCV_DEST =>
        --dbg <= "0010";
        if Rx_Dv = '1' then
          r_n.crc32                                            <= nextCRC32_D8(rev(RxD), r.crc32);
          v_mac_addr                                           := r.mac_addr;
          v_mac_addr(47-r.count*8 downto 40-r.count*8) := RxD;
          r_n.mac_addr                                         <= v_mac_addr;
          if r.count < 5 then
            r_n.count <= r.count + 1;
          else
            if v_mac_addr /= my_mac then
              -- This packet is not for us - ignore it!
              r_n.state <= ST_RCV_WAIT_IDLE;
            else
              r_n.count <= 0;
              r_n.state <= ST_RCV_SOURCE;
              -- Our address! Receive the sender
            end if;
          end if;
        else
          -- packet broken?
          r_n.state <= ST_RCV_IDLE;
        end if;
      when ST_RCV_SOURCE =>
        --dbg <= "0011";
        if Rx_Dv = '1' then
          r_n.crc32                                            <= nextCRC32_D8(rev(RxD), r.crc32);
          v_mac_addr                                           := r.mac_addr;
          v_mac_addr(47-r.count*8 downto 40-r.count*8) := RxD;
          r_n.mac_addr                                         <= v_mac_addr;
          if r.count < 5 then
            r_n.count <= r.count + 1;
          else
            r_n.count <= 0;
            r_n.state <= ST_RCV_CMD;
          end if;
        else
          -- packet broken?
          r_n.state <= ST_RCV_IDLE;
        end if;
      when ST_RCV_CMD =>
        --dbg <= "0100";
        if Rx_Dv = '1' then
          r_n.crc32                                       <= nextCRC32_D8(rev(RxD), r.crc32);
          v_cmd                                           := r.cmd;
          v_cmd(31-r.count*8 downto 24-r.count*8) := RxD;
          r_n.cmd                                         <= v_cmd;
          if r.count < 3 then
            r_n.count <= r.count + 1;
          else
            r_n.count <= 0;
            r_n.state <= ST_RCV_ARGS;
          end if;
        end if;
      when ST_RCV_ARGS =>
        --dbg <= "0101";
        if Rx_Dv = '1' then
          r_n.crc32                                       <= nextCRC32_D8(rev(RxD), r.crc32);
          v_arg                                           := r.arg;
          v_arg(31-r.count*8 downto 24-r.count*8) := RxD;
          r_n.arg                                         <= v_arg;
          if r.count < 3 then
            r_n.count <= r.count + 1;
          else
            r_n.count <= 0;
            r_n.state <= ST_RCV_TRAILER;
          end if;
        end if;
      when ST_RCV_TRAILER =>
        -- No detection of too long frames!
        --dbg <= "0110";
        if Rx_Dv = '0' then
          -- End of packet, check the checksum
          if r.crc32 /= x"c704dd7b" then
            -- Wrong checksum, ignore packet
            r_n.state <= ST_RCV_IDLE;
          else
            -- Checksum OK, process the packet
            -- We can copy the sender
            r_n.peer_mac <= r.mac_addr;
            r_n.state    <= ST_RCV_PROCESS;
          end if;
        else
          r_n.crc32 <= nextCRC32_D8(rev(RxD), r.crc32);
        end if;
      when ST_RCV_PROCESS =>
        --dbg <= "0111";
        if r.cmd(31 downto 16) /= my_ether_type then
          r_n.state <= ST_RCV_WAIT_IDLE;
        else
          case r.cmd(15 downto 0) is
            when x"0001" =>
              r_n.dbg(0) <= not r.dbg(0);
              -- Start transmission command
              r_n.transmit_data <= '1';
              r_n.state         <= ST_RCV_UPDATE;
            when x"0002" =>
              r_n.dbg(1) <= not r.dbg(1);
              -- Stop transmission command
              r_n.transmit_data <= '0';
              r_n.state         <= ST_RCV_UPDATE;
            when x"0003" =>
              r_n.dbg(2) <= not r.dbg(2);
              -- Packet ACK command
              if ack_fifo_full = '0' then
                ack_pkt_in.cmd   := to_unsigned(3, ack_pkt_in.cmd'length);
                ack_pkt_in.set   := unsigned(r.arg(31 downto 16));
                ack_pkt_in.pkt   := "00" & unsigned(r.arg(15 downto 10));
                c.ack_fifo_din   <= pkt_ack_to_stlv(ack_pkt_in);
                c.ack_fifo_wr_en <= '1';
              end if;

              r_n.state <= ST_RCV_UPDATE;
            when x"0004" =>
              -- Packet NACK command (currently not used)
              if ack_fifo_full = '0' then
                ack_pkt_in.cmd   := to_unsigned(4, ack_pkt_in.cmd'length);
                ack_pkt_in.set   := unsigned(r.arg(31 downto 16));
                ack_pkt_in.pkt   := "00" & unsigned(r.arg(15 downto 10));
                c.ack_fifo_din   <= pkt_ack_to_stlv(ack_pkt_in);
                c.ack_fifo_wr_en <= '1';
              end if;
              r_n.state <= ST_RCV_UPDATE;
            when x"0005" =>
              r_n.dbg(3) <= not r.dbg(3);

              -- Stop transmission and retransmission
              r_n.restart <= '1';
              r_n.state   <= ST_RCV_UPDATE;
            when others =>
              r_n.state <= ST_RCV_IDLE;
          end case;
        end if;
      when ST_RCV_UPDATE =>
        --dbg             <= "1000";
        r_n.update_flag <= not r.update_flag;
        r_n.state       <= ST_RCV_IDLE;
      when ST_RCV_WAIT_IDLE =>
        --dbg             <= "1001";
        if Rx_Dv = '0' then
          r_n.state <= ST_RCV_IDLE;
        end if;
      when others => null;
    end case;
  end process rdp2;

  -- Synchronization of the reset signal for the Rx_Clk domain
  process (Rx_Clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      rx_rst_n_0 <= '0';
      rx_rst_n_1 <= '0';
      rx_rst_n   <= '0';
    elsif Rx_Clk'event and Rx_Clk = '1' then  -- rising clock edge
      rx_rst_n_0 <= rst_n;
      rx_rst_n_1 <= rx_rst_n_0;
      rx_rst_n   <= rx_rst_n_1;
    end if;
  end process;


  -- Synchronization of output signals between the clock domains
  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      peer_mac      <= (others => '0');
      transmit_data <= '0';
      restart       <= '0';
      update_flag_0 <= '0';
      update_flag_1 <= '0';
      update_flag   <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- Synchronization of the update_flag
      update_flag_0 <= r.update_flag;
      update_flag_1 <= update_flag_0;
      update_flag   <= update_flag_1;
      -- When update flag has changed, rewrite synchronized fields
      if update_flag /= update_flag_1 then
        peer_mac      <= r.peer_mac;
        transmit_data <= r.transmit_data;
        restart       <= r.restart;
      end if;
    end if;
  end process;

end beh1;
