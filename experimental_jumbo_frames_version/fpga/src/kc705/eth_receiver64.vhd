-------------------------------------------------------------------------------
-- Title      : FPGA Ethernet interface - block receiving packets from MII PHY
-- Project    : 
-------------------------------------------------------------------------------
-- File       : eth_receiver4.vhd
-- Author     : Wojciech M. Zabolotny (wzab@ise.pw.edu.pl)
-- License    : BSD License
-- Company    : 
-- Created    : 2012-03-30
-- Last update: 2014-10-12
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This file implements the state machine, responsible for
-- reception of packets and passing them to the acknowledgements and commands
-- FIFO
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
use work.pkg_newcrc32_d64.all;
use work.pkg_newcrc32_d32.all;
use work.pkg_newcrc32_d16.all;


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
    cmd            : out std_logic_vector(31 downto 0);
    arg            : out std_logic_vector(31 downto 0);
    crc            : out std_logic_vector(31 downto 0);
    -- MAC interface
    Rx_Clk         : in  std_logic;
    RxC            : in  std_logic_vector(7 downto 0);
    RxD            : in  std_logic_vector(63 downto 0)
    );

end eth_receiver;


architecture beh1 of eth_receiver is

  type T_STATE is (ST_RCV_IDLE, ST_RCV_PREAMB, ST_CHECK_PREAMB,
                   ST_RCV_HEADER1, ST_RCV_HEADER2, ST_RCV_CMD,
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

  constant C_PROTO_ID : std_logic_vector(31 downto 0) := x"fade0100";

  type T_RCV_REGS is record
    state         : T_STATE;
    swap_lanes    : std_logic;
    transmit_data : std_logic;
    restart       : std_logic;
    update_flag   : std_logic;
    count         : integer;
    dbg           : std_logic_vector(3 downto 0);
    crc32         : std_logic_vector(31 downto 0);
    cmd           : std_logic_vector(31 downto 0);
    arg           : std_logic_vector(31 downto 0);
    mac_addr      : std_logic_vector(47 downto 0);
    peer_mac      : std_logic_vector(47 downto 0);
  end record;

  constant RCV_REGS_INI : T_RCV_REGS := (
    state         => ST_RCV_IDLE,
    swap_lanes    => '0',
    transmit_data => '0',
    restart       => '0',
    update_flag   => '0',
    count         => 0,
    dbg           => (others => '0'),
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

  signal rxd_sw, rxd_del : std_logic_vector(63 downto 0);
  signal rxc_sw, rxc_del : std_logic_vector(7 downto 0);

  signal rx_rst_n, rx_rst_n_0, rx_rst_n_1          : std_logic := '0';
  signal update_flag_0, update_flag_1, update_flag : std_logic := '0';

begin  -- beh1

  ack_fifo_din   <= c.ack_fifo_din;
  ack_fifo_wr_en <= c.ack_fifo_wr_en;

  --dbg <= r.dbg;
  crc <= r.crc32;
  cmd <= r.cmd;
  arg <= r.arg;
  -- Lane switcher processes
  lsw_c1 : process (RxC, RxC(3 downto 0), RxC_del(7 downto 4), RxD,
                    RxD(31 downto 0), RxD_del(63 downto 32), r.swap_lanes) is
  begin  -- process lsw_c1
    if r.swap_lanes = '1' then
      RxD_Sw(63 downto 32) <= RxD(31 downto 0);
      RxD_Sw(31 downto 0)  <= RxD_del(63 downto 32);
      RxC_Sw(7 downto 4)   <= RxC(3 downto 0);
      RxC_Sw(3 downto 0)   <= RxC_del(7 downto 4);
    else
      RxD_Sw <= RxD;
      RxC_Sw <= RxC;
    end if;
  end process lsw_c1;

  process (Rx_Clk, rx_rst_n) is
  begin  -- process
    if rx_rst_n = '0' then              -- asynchronous reset (active low)
      RxD_del <= (others => '0');
      RxC_del <= (others => '0');
    elsif Rx_Clk'event and Rx_Clk = '1' then  -- rising clock edge
      RxD_del <= RxD;
      RxC_del <= RxC;
    end if;
  end process;

  -- Reading of ethernet data
  rdp1 : process (Rx_Clk, rx_rst_n)
  begin  -- process rdp1
    if rx_rst_n = '0' then              -- asynchronous reset (active low)
      r <= RCV_REGS_INI;
    elsif Rx_Clk'event and Rx_Clk = '1' then  -- rising clock edge
      r <= r_n;
    end if;
  end process rdp1;

  rdp2 : process (RxC, RxC_Sw, RxD, RxD_Sw, ack_fifo_full, my_ether_type,
                  my_mac, r, r.arg(15 downto 10), r.arg(31 downto 16),
                  r.cmd(15 downto 0), r.cmd(31 downto 16), r.crc32, r.dbg(0),
                  r.dbg(1), r.dbg(2), r.dbg(3), r.mac_addr, r.state,
                  r.update_flag)

    variable ack_pkt_in   : pkt_ack;
    variable v_mac_addr   : std_logic_vector(47 downto 0);
    variable v_cmd, v_arg : std_logic_vector(31 downto 0);
    variable v_crc        : std_logic_vector(31 downto 0);
    variable v_proto      : std_logic_vector(31 downto 0);
    
  begin  -- process
    c   <= RCV_COMB_DEFAULT;
    r_n <= r;
    dbg <= "1111";
    case r.state is
      when ST_RCV_IDLE =>
        dbg <= "0000";
        -- We must be prepared to one of two possible events
        -- Either we receive the SOF in the 0-th lane (and then we proceed
        -- normally) or we receive the SOF in the 4-th lane (and then we have
        -- to switch lanes, delaying 4 of them).
        if RxC = b"00011111" and RxD = x"55_55_55_fb_07_07_07_07" then
          -- shifted lanes
          -- switch on the "lane shifter" and go to the state,
          -- where we can check the proper preamble after lane switching
          r_n.swap_lanes <= '1';
          r_n.state      <= ST_CHECK_PREAMB;
        elsif RxC = b"00000001" and RxD = x"d5_55_55_55_55_55_55_fb" then
          -- normal lanes
          r_n.swap_lanes <= '0';
          r_n.crc32      <= (others => '1');
          r_n.state      <= ST_RCV_HEADER1;
        end if;
      when ST_CHECK_PREAMB =>
        dbg <= "0001";
        if RxC_Sw = b"00000001" and RxD_Sw = x"d5_55_55_55_55_55_55_fb" then
          r_n.crc32 <= (others => '1');
          r_n.state <= ST_RCV_HEADER1;
        else
          -- interrupted preamble reception
          r_n.state <= ST_RCV_IDLE;
        end if;
      when ST_RCV_HEADER1 =>
        dbg <= "0010";
        if RxC_Sw = b"00000000" then
          r_n.crc32 <= newcrc32_d64(RxD_Sw, r.crc32);
          -- Change the order of bytes!
          for i in 0 to 5 loop
            v_mac_addr(47-i*8 downto 40-i*8) := RxD_Sw(i*8+7 downto i*8);
          end loop;  -- i
          if v_mac_addr /= my_mac then
            -- This packet is not for us - ignore it!
            r_n.state <= ST_RCV_WAIT_IDLE;
          else
            -- Our packet!
            r_n.count                  <= 0;
            -- Read the lower 16 bits of the sender address
            -- Again, we have to change the order of bytes!
            r_n.mac_addr(39 downto 32) <= RxD_Sw(63 downto 56);
            r_n.mac_addr(47 downto 40) <= RxD_Sw(55 downto 48);
            r_n.state                  <= ST_RCV_HEADER2;
          end if;
        else
          -- packet broken?
          r_n.state <= ST_RCV_IDLE;
        end if;
      when ST_RCV_HEADER2 =>
        dbg <= "0010";
        if RxC_Sw = b"00000000" then
          r_n.crc32  <= newcrc32_d64(RxD_Sw, r.crc32);
          v_mac_addr := r.mac_addr;
          for i in 0 to 3 loop
            v_mac_addr(31-i*8 downto 24-i*8) := RxD_Sw(i*8+7 downto i*8);
          end loop;  -- i
          --v_mac_addr(47 downto 16) := RxD_Sw(31 downto 0);
          r_n.mac_addr <= v_mac_addr;
          -- In the rest of this 64-bit word, we receive the protocol ID
          -- and version
          for i in 0 to 3 loop
            v_proto(i*8+7 downto i*8) := RxD_Sw(63-i*8 downto 56-i*8);
          end loop;  -- i
          -- Check if the proto id is correct
          if v_proto = C_PROTO_ID then
            r_n.state <= ST_RCV_CMD;
          else
            r_n.state <= ST_RCV_IDLE;
          end if;
        else
          -- packet broken?
          r_n.state <= ST_RCV_IDLE;
        end if;
      when ST_RCV_CMD =>
        if RxC_Sw = b"0000_0000" then
          r_n.crc32 <= newcrc32_d64(RxD_Sw, r.crc32);
          -- Copy the command, changing order of bytes!
          for i in 0 to 3 loop
            r_n.cmd(i*8+7 downto i*8) <= RxD_Sw(31-i*8 downto 24-i*8);
          end loop;  -- i          
          -- Copy the argument, changing order of bytes!
          for i in 0 to 3 loop
            r_n.arg(i*8+7 downto i*8) <= RxD_Sw(63-i*8 downto 56-i*8);
          end loop;  -- i
          r_n.state <= ST_RCV_TRAILER;
        -- Currently we ignore rest of the packet!
        else
          -- packet broken?
          r_n.state <= ST_RCV_IDLE;
        end if;
      when ST_RCV_TRAILER =>
        -- No detection of too long frames!
        dbg <= "0110";
        if RxC_Sw /= b"0000_0000" then
          -- It should be a packet with the checksum
          -- The EOF may be on any of 8th positions.
          -- To avoid too big combinational functions,
          -- we handle it in a few states (but this increases requirements
          -- on IFC!)
          -- Current implementation assumes fixed length of frames
          -- but the optimal one should probably pass received data for further
          -- checking, why this machine continues to receive next frame...
          if RxC_Sw = b"1111_1100" then
            v_crc     := r.crc32;
            v_crc     := newcrc32_d16(RxD_Sw(15 downto 0), v_crc);
            r_n.crc32 <= v_crc;
            if (RxD_Sw(23 downto 16) = x"fd") and
              (v_crc = x"c704dd7b") then
              -- Correct packet, go to processing
              r_n.peer_mac <= r.mac_addr;
              r_n.state    <= ST_RCV_PROCESS;
            else
              -- Wrong CRC or EOF
              r_n.state <= ST_RCV_IDLE;
            end if;
          else
            -- Wrong packet
            r_n.state <= ST_RCV_IDLE;
          end if;
        else
          -- Ignore received data, only updating the checksum
          r_n.crc32 <= newcrc32_d64(RxD_Sw, r.crc32);
        end if;
      when ST_RCV_PROCESS =>
        dbg <= "0111";
        case to_integer(unsigned(r.cmd(31 downto 16))) is
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
            -- Restart the whole block(?)
            r_n.restart <= '1';
          when others =>
            null;
        end case;
        -- All commands are written to the acknowledge and commands
        -- FIFO, so that they will be handled by the descriptor manager
        if ack_fifo_full = '0' then
          ack_pkt_in.cmd   := unsigned(r.cmd(31 downto 16));
          ack_pkt_in.pkt   := unsigned(r.arg);
          ack_pkt_in.seq   := unsigned(r.cmd(15 downto 0));
          c.ack_fifo_din   <= pkt_ack_to_stlv(ack_pkt_in);
          c.ack_fifo_wr_en <= '1';
        end if;
        r_n.state <= ST_RCV_UPDATE;
      when ST_RCV_UPDATE =>
        dbg             <= "1000";
        r_n.update_flag <= not r.update_flag;
        r_n.state       <= ST_RCV_IDLE;
      when ST_RCV_WAIT_IDLE =>
        dbg <= "1001";
        if RxC_Sw = b"1111_1111" then
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
