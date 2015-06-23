-------------------------------------------------------------------------------
-- Title      : FPGA Ethernet interface - block receiving packets from MII PHY
-- Project    : 
-------------------------------------------------------------------------------
-- File       : eth_receiver4.vhd
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

-- Uwaga! Tu mamy rzeczywiste problemy z obsluga odebranych pakietow!
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.desc_mgr_pkg.all;
use work.pkt_ack_pkg.all;
use work.pkg_newcrc32_d8.all;

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
                   ST_RCV_PROTO, ST_RCV_WAIT_IDLE, ST_RCV_ARGS, ST_RCV_PROCESS, ST_RCV_UPDATE,
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
    count         : integer range 0 to 256;
    dbg           : std_logic_vector(3 downto 0);
    crc32         : std_logic_vector(31 downto 0);
    cmd           : std_logic_vector(63 downto 0);
    mac_addr      : std_logic_vector(47 downto 0);
    peer_mac      : std_logic_vector(47 downto 0);
  end record;

  constant RCV_REGS_INI : T_RCV_REGS := (
    state         => ST_RCV_IDLE,
    transmit_data => '0',
    restart       => '0',
    update_flag   => '0',
    count         => 0,
    dbg           => (others => '0'),
    crc32         => (others => '0'),
    cmd           => (others => '0'),
    mac_addr      => (others => '0'),
    peer_mac      => (others => '0')
    );

  
  signal r, r_n : T_RCV_REGS := RCV_REGS_INI;

  type T_RCV_COMB is record
    ack_fifo_wr_en : std_logic;
    ack_fifo_din   : std_logic_vector(pkt_ack_width-1 downto 0);
    Rx_mac_rd      : std_logic;
    restart        : std_logic;
  end record;

  constant RCV_COMB_DEFAULT : T_RCV_COMB := (
    ack_fifo_wr_en => '0',
    ack_fifo_din   => (others => '0'),
    Rx_mac_rd      => '0',
    restart        => '0'
    );

  signal c : T_RCV_COMB := RCV_COMB_DEFAULT;

  signal rx_rst_n, rx_rst_n_0, rx_rst_n_1          : std_logic := '0';
  signal update_flag_0, update_flag_1, update_flag : std_logic := '0';

  constant proto_id : std_logic_vector(31 downto 0) := x"fade0100";
  
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

    variable ack_pkt_in : pkt_ack;
    variable v_mac_addr : std_logic_vector(47 downto 0);
    variable v_cmd      : std_logic_vector(63 downto 0);
    
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
          r_n.crc32 <= newcrc32_d8(RxD, r.crc32);
          if my_mac(47-r.count*8 downto 40-r.count*8) /= RxD then
            -- Not our address, return to IDLE!
            r_n.state <= ST_RCV_WAIT_IDLE;
          elsif r.count < 5 then
            r_n.count <= r.count + 1;
          else
            r_n.count <= 0;
            r_n.state <= ST_RCV_SOURCE;
          -- Our address! Receive the sender
          end if;
        else
          -- packet broken?
          r_n.state <= ST_RCV_IDLE;
        end if;
      when ST_RCV_SOURCE =>
        --dbg <= "0011";
        if Rx_Dv = '1' then
          r_n.crc32                                    <= newcrc32_d8(RxD, r.crc32);
          v_mac_addr                                   := r.mac_addr;
          v_mac_addr(47-r.count*8 downto 40-r.count*8) := RxD;
          r_n.mac_addr                                 <= v_mac_addr;
          if r.count < 5 then
            r_n.count <= r.count + 1;
          else
            r_n.count <= 0;
            r_n.state <= ST_RCV_PROTO;
          end if;
        else
          -- packet broken?
          r_n.state <= ST_RCV_IDLE;
        end if;
      when ST_RCV_PROTO =>
        if Rx_Dv = '1' then
          r_n.crc32 <= newcrc32_d8(RxD, r.crc32);
          if proto_id(31-r.count*8 downto 24-r.count*8) /= RxD then
            -- Incorrect type of frame or protocol ID
            r_n.state <= ST_RCV_IDLE;
          elsif r.count < 3 then
            r_n.count <= r.count + 1;
          else
            r_n.count <= 0;
            r_n.state <= ST_RCV_CMD;
          end if;
        end if;
      when ST_RCV_CMD =>
        --dbg <= "0100";
        if Rx_Dv = '1' then
          r_n.crc32                               <= newcrc32_d8(RxD, r.crc32);
          v_cmd                                   := r.cmd;
          v_cmd(63-r.count*8 downto 56-r.count*8) := RxD;
          r_n.cmd                                 <= v_cmd;
          if r.count < 7 then
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
            r_n.state <= ST_RCV_PROCESS;
          end if;
        else
          r_n.crc32 <= newcrc32_d8(RxD, r.crc32);
        end if;
      when ST_RCV_PROCESS =>
        --For ACK 
        --dbg <= "0111";
        -- We can copy the sender
        r_n.peer_mac <= r.mac_addr;
        case to_integer(unsigned(r.cmd(63 downto 48))) is
          -- Handle commands, which require immediate action
          when FCMD_START =>
            r_n.dbg(0)        <= not r.dbg(0);
            -- Start transmission command
            r_n.transmit_data <= '1';
          when FCMD_STOP =>
            r_n.dbg(1)        <= not r.dbg(1);
            -- Stop transmission command
            r_n.transmit_data <= '0';
          when FCMD_RESET =>
            r_n.dbg(3)  <= not r.dbg(3);
            -- Stop transmission and retransmission
            r_n.restart <= '1';
          when others =>
            null;
        end case;
        -- All commands are written to the acknowledge and commands
        -- FIFO, so they will be handled by the descriptor manager
        -- Handle the user commands
        if ack_fifo_full = '0' then
          ack_pkt_in.cmd   := unsigned(r.cmd(63 downto 48));
          ack_pkt_in.seq   := unsigned(r.cmd(47 downto 32));
          ack_pkt_in.pkt   := unsigned(r.cmd(31 downto 0));
          c.ack_fifo_din   <= pkt_ack_to_stlv(ack_pkt_in);
          c.ack_fifo_wr_en <= '1';
        end if;
        r_n.state <= ST_RCV_UPDATE;
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
