--------------------------------------------------------------------------------
---
---  Gigabit Ethernet MAC
---
---  :Author: Jonathan P Dawson
---  :Date: 17/10/2013
---  :email: chips@jondawson.org.uk
---  :license: MIT
---  :Copyright: Copyright (C) Jonathan P Dawson 2013
---
---  A gigabit ethernet MAC
---
--------------------------------------------------------------------------------
---
---Gigabit Ethernet
---================
---
---Send and receive Ethernet packets. Using a Ethernet Physical Interface.
---
---Features:
---
---+ Supports 1Gbit/s ethernet only via a gmii interface.
---+ Supports full duplex mode only.
---
---Interface
------------
---:input: TX - Data to send (16 bits).
---:output: RX - Data to send (16 bits).
---
---Ethernet Packet Structure
----------------------------
---
---+-------------+-------------+--------+--------+---------+---------+-----+
---| Description | destination | source | length | payload | padding | FSC |
---+=============+=============+========+========+=========+=========+=====+
---|    Bytes    |      6      |   6    |    2   |  0-1500 |   0-46  |  4  |
---+-------------+-------------+--------+--------+---------+---------+-----+
---
---Notes:
---
---+ The *length* field is the length of the ethernet payload.
---+ The *Ethernet Output* block will automatically append the FSC to 
---  outgoing packets.
---+ The *FSC* of incoming packets will be checked, and bad packets will
---  be discarded. The *FSC* will be stripped from incoming packets.
---+ The length of the *payload* + *padding* must be 46-1500 bytes.
---+ Incoming packets of incorrect *length* will be discarded.
---
---Usage
--------
---
---Transmit
---~~~~~~~~
---The first 16 bit word on the TX input is interpreted as the length of the
---packet in bytes (including the MAC address, length and payload, but not the 
---preamble or FSC). Subsequent words on the TX input are interpreted as the
---content of the packet. If length is an odd number of bytes, then the least
---significant byte of the last word will be ignored.
---The FSC will be appended for you, but you need to supply the destination,
---source and length fields.
---
---Receive
---~~~~~~~~
---The first 16 bit word on the RX output will be the length of the packet in 
---bytes (including the MAC address, length and payload, but not the 
---preamble or FSC). Subsequent words on the RX output will be the
---content of the packet. If length is an odd number of bytes, then the least
---significant byte of the last word will not contain usefull data.
---The FSC will be stripped from incoming packets, but the destination,
---source and length fields will be included.
---
---Hardware details
-------------------
---This component used two clocks, the local clock used to transfer data
---between components, and a 125MHz clock source for sending data to the
---Ethernet physical interface. This clock is also forwarded along with the
---data to the ethernet phy.
---

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity gigabit_ethernet is
  port(
    CLK         : in  std_logic;
    RST         : in  std_logic;

    --Ethernet Clock
    CLK_125_MHZ : in  std_logic;

    --GMII IF
    GTXCLK      : out std_logic;
    TXCLK       : in  std_logic;
    TXER        : out std_logic;
    TXEN        : out std_logic;
    TXD         : out std_logic_vector(7 downto 0);
    PHY_RESET   : out std_logic;
    RXCLK       : in  std_logic;
    RXER        : in  std_logic;
    RXDV        : in  std_logic;
    RXD         : in  std_logic_vector(7 downto 0);

    --RX STREAM
    TX          : in  std_logic_vector(15 downto 0);
    TX_STB      : in  std_logic;
    TX_ACK      : out std_logic;

    --RX STREAM
    RX          : out std_logic_vector(15 downto 0);
    RX_STB      : out std_logic;
    RX_ACK      : in  std_logic
  );
end entity gigabit_ethernet;

architecture RTL of gigabit_ethernet is

  -- polynomial: (0 1 2 4 5 7 8 10 11 12 16 22 23 26 32)
  -- data width: 8
  -- convention: the first serial bit is D[0]
  function NEXTCRC32_D8
    (DATA: std_logic_vector(7 downto 0);
    CRC:  std_logic_vector(31 downto 0))
    return std_logic_vector is

    variable D:      std_logic_vector(7 downto 0);
    variable C:      std_logic_vector(31 downto 0);
    variable NEWCRC: std_logic_vector(31 downto 0);
    
  begin
    D := DATA;
    C := CRC;
    NewCRC(0):=C(24) xor C(30) xor D(1) xor D(7);
    NewCRC(1):=C(25) xor C(31) xor D(0) xor D(6) xor C(24) xor C(30) xor D(1) 
               xor D(7);
    NewCRC(2):=C(26) xor D(5) xor C(25) xor C(31) xor D(0) xor D(6) xor C(24) 
               xor C(30) xor D(1) xor D(7);
    NewCRC(3):=C(27) xor D(4) xor C(26) xor D(5) xor C(25) xor C(31) xor D(0) 
               xor D(6);
    NewCRC(4):=C(28) xor D(3) xor C(27) xor D(4) xor C(26) xor D(5) xor C(24) 
              xor C(30) xor D(1) xor D(7);
    NewCRC(5):=C(29) xor D(2) xor C(28) xor D(3) xor C(27) xor D(4) xor C(25) 
              xor C(31) xor D(0) xor D(6) xor C(24) xor C(30) xor D(1) xor D(7);
    NewCRC(6):=C(30) xor D(1) xor C(29) xor D(2) xor C(28) xor D(3) xor C(26) 
              xor D(5) xor C(25) xor C(31) xor D(0) xor D(6);
    NewCRC(7):=C(31) xor D(0) xor C(29) xor D(2) xor C(27) xor D(4) xor C(26) 
              xor D(5) xor C(24) xor D(7);
    NewCRC(8):=C(0) xor C(28) xor D(3) xor C(27) xor D(4) xor C(25) xor D(6) 
              xor C(24) xor D(7);
    NewCRC(9):=C(1) xor C(29) xor D(2) xor C(28) xor D(3) xor C(26) xor D(5)
              xor C(25) xor D(6);
    NewCRC(10):=C(2) xor C(29) xor D(2) xor C(27) xor D(4) xor C(26) xor D(5) 
              xor C(24) xor D(7);
    NewCRC(11):=C(3) xor C(28) xor D(3) xor C(27) xor D(4) xor C(25) xor D(6) 
              xor C(24) xor D(7);
    NewCRC(12):=C(4) xor C(29) xor D(2) xor C(28) xor D(3) xor C(26) xor D(5) 
              xor C(25) xor D(6) xor C(24) xor C(30) xor D(1) xor D(7);
    NewCRC(13):=C(5) xor C(30) xor D(1) xor C(29) xor D(2) xor C(27) xor D(4) 
              xor C(26) xor D(5) xor C(25) xor C(31) xor D(0) xor D(6);
    NewCRC(14):=C(6) xor C(31) xor D(0) xor C(30) xor D(1) xor C(28) xor D(3) 
              xor C(27) xor D(4) xor C(26) xor D(5);
    NewCRC(15):=C(7) xor C(31) xor D(0) xor C(29) xor D(2) xor C(28) xor D(3) 
              xor C(27) xor D(4);
    NewCRC(16):=C(8) xor C(29) xor D(2) xor C(28) xor D(3) xor C(24) xor D(7);
    NewCRC(17):=C(9) xor C(30) xor D(1) xor C(29) xor D(2) xor C(25) xor D(6);
    NewCRC(18):=C(10) xor C(31) xor D(0) xor C(30) xor D(1) xor C(26) xor D(5);
    NewCRC(19):=C(11) xor C(31) xor D(0) xor C(27) xor D(4);
    NewCRC(20):=C(12) xor C(28) xor D(3);
    NewCRC(21):=C(13) xor C(29) xor D(2);
    NewCRC(22):=C(14) xor C(24) xor D(7);
    NewCRC(23):=C(15) xor C(25) xor D(6) xor C(24) xor C(30) xor D(1) xor D(7);
    NewCRC(24):=C(16) xor C(26) xor D(5) xor C(25) xor C(31) xor D(0) xor D(6);
    NewCRC(25):=C(17) xor C(27) xor D(4) xor C(26) xor D(5);
    NewCRC(26):=C(18) xor C(28) xor D(3) xor C(27) xor D(4) xor C(24) xor C(30) 
              xor D(1) xor D(7);
    NewCRC(27):=C(19) xor C(29) xor D(2) xor C(28) xor D(3) xor C(25) xor C(31) 
              xor D(0) xor D(6);
    NewCRC(28):=C(20) xor C(30) xor D(1) xor C(29) xor D(2) xor C(26) xor D(5);
    NewCRC(29):=C(21) xor C(31) xor D(0) xor C(30) xor D(1) xor C(27) xor D(4);
    NewCRC(30):=C(22) xor C(31) xor D(0) xor C(28) xor D(3);
    NewCRC(31):=C(23) xor C(29) xor D(2);

    return NEWCRC;
  end NEXTCRC32_D8;

  -- Reverse the input vector.
  function REVERSED(slv: std_logic_vector) return std_logic_vector is
     variable result: std_logic_vector(slv'reverse_range);
  begin
     for i in slv'range loop
       result(i) := slv(i);
     end loop;
     return result;
  end REVERSED;

  --constants
  constant ADDRESS_BITS : integer := 11;
  constant ADDRESS_MAX : integer := (2**ADDRESS_BITS) - 1;

  --memories
  type TX_MEMORY_TYPE is array (0 to 511) of
    std_logic_vector(15 downto 0);
  shared variable TX_MEMORY : TX_MEMORY_TYPE;

  type RX_MEMORY_TYPE is array (0 to ADDRESS_MAX) of
    std_logic_vector(15 downto 0);
  shared variable RX_MEMORY : RX_MEMORY_TYPE;

  type ADDRESS_ARRAY is array (0 to 31) of 
    unsigned(ADDRESS_BITS - 1 downto 0);

  --state variables
  type TX_PHY_STATE_TYPE is (WAIT_NEW_PACKET, PREAMBLE_0, PREAMBLE_1, 
    PREAMBLE_2, PREAMBLE_3, PREAMBLE_4, PREAMBLE_5, PREAMBLE_6, SFD, 
    SEND_DATA_HI, SEND_DATA_LO, SEND_CRC_3, SEND_CRC_2, SEND_CRC_1, 
    SEND_CRC_0, DONE_STATE);
  signal TX_PHY_STATE : TX_PHY_STATE_TYPE;

  type TX_PACKET_STATE_TYPE is(GET_LENGTH, GET_DATA, SEND_PACKET, 
    WAIT_NOT_DONE);
  signal TX_PACKET_STATE : TX_PACKET_STATE_TYPE;

  type RX_PHY_STATE_TYPE is (WAIT_START, PREAMBLE, DATA_HIGH, DATA_LOW,
    END_OF_FRAME, NOTIFY_NEW_PACKET);
  signal RX_PHY_STATE : RX_PHY_STATE_TYPE;

  type RX_PACKET_STATE_TYPE is (WAIT_INITIALISE, WAIT_NEW_PACKET, 
    SEND_DATA, PREFETCH0, PREFETCH1, SEND_LENGTH);
  signal RX_PACKET_STATE : RX_PACKET_STATE_TYPE;

  --TX signals
  signal TX_WRITE                  : std_logic;
  signal TX_WRITE_DATA             : std_logic_vector(15 downto 0);
  signal TX_READ_DATA              : std_logic_vector(15 downto 0);
  signal TX_WRITE_ADDRESS          : integer range 0 to 1513;
  signal TX_WRITE_ADDRESS_DEL      : integer range 0 to 1513;
  signal TX_READ_ADDRESS           : integer range 0 to 1513;
  signal TX_CRC                    : std_logic_vector(31 downto 0);
  signal TX_IN_COUNT               : integer range 0 to 1513;
  signal TX_OUT_COUNT              : integer range 0 to 1513;
  signal TX_PACKET_LENGTH          : std_logic_vector(15 downto 0);
  signal GO, GO_DEL, GO_SYNC       : std_logic;
  signal DONE, DONE_DEL, DONE_SYNC : std_logic;
  signal S_TX_ACK                  : std_logic;

  --RX signals
  signal RX_WRITE_ADDRESS          : unsigned(ADDRESS_BITS - 1 downto 0);
  signal RX_READ_ADDRESS           : unsigned(ADDRESS_BITS - 1 downto 0);
  signal RX_START_ADDRESS          : unsigned(ADDRESS_BITS - 1 downto 0);
  signal RX_PACKET_LENGTH          : unsigned(ADDRESS_BITS - 1 downto 0);
  signal RX_START_ADDRESS_BUFFER   : ADDRESS_ARRAY;
  signal RX_PACKET_LENGTH_BUFFER   : ADDRESS_ARRAY;
  signal RX_WRITE_BUFFER           : integer range 0 to 31;
  signal RX_READ_BUFFER            : integer range 0 to 31;
  signal RX_BUFFER_BUSY            : std_logic_vector(31 downto 0);
  signal RX_BUFFER_BUSY_DEL        : std_logic_vector(31 downto 0);
  signal RX_BUFFER_BUSY_SYNC       : std_logic_vector(31 downto 0);
  signal RX_START_ADDRESS_SYNC     : unsigned(ADDRESS_BITS - 1 downto 0);
  signal RX_PACKET_LENGTH_SYNC     : unsigned(ADDRESS_BITS - 1 downto 0);
  signal RX_END_ADDRESS            : unsigned(ADDRESS_BITS - 1 downto 0);
  signal RX_WRITE_DATA             : std_logic_vector(15 downto 0);
  signal RX_WRITE_ENABLE           : std_logic;
  signal RX_ERROR                  : std_logic;
  signal RX_CRC                    : std_logic_vector(31 downto 0);
  signal RXD_D                     : std_logic_vector(7 downto 0);
  signal RXDV_D                    : std_logic;
  signal RXER_D                    : std_logic;

begin
  
  --This process is in the local clock domain. 
  --It gets data and puts it into a RAM.
  --Once a packets worth of data has been stored it is
  --sent to the packet sending state machine.
  TX_PACKET_FSM : process
  begin
    wait until rising_edge(CLK);
    TX_WRITE <= '0';
    case TX_PACKET_STATE is

      when GET_LENGTH =>
        S_TX_ACK <= '1';
        if S_TX_ACK = '1' and TX_STB = '1' then
          S_TX_ACK <= '0';
          TX_PACKET_LENGTH <= TX;
	        TX_IN_COUNT <= 2;
          TX_PACKET_STATE <= GET_DATA;
        end if;

      when GET_DATA =>
        S_TX_ACK <= '1';
        if S_TX_ACK = '1' and TX_STB = '1' then
          TX_WRITE_DATA <= TX;
          TX_WRITE <= '1';
          if TX_IN_COUNT >= unsigned(TX_PACKET_LENGTH) then
            TX_PACKET_STATE <= SEND_PACKET;
            S_TX_ACK <= '0';
          else
            TX_WRITE_ADDRESS <= TX_WRITE_ADDRESS + 1;
            TX_IN_COUNT <= TX_IN_COUNT + 2;
          end if;
        end if;

      when SEND_PACKET =>
        GO <= '1';
        TX_WRITE_ADDRESS <= 0;
        if DONE_SYNC = '1' then
          GO <= '0';
          TX_PACKET_STATE <= WAIT_NOT_DONE;
        end if;

      when WAIT_NOT_DONE =>
        if DONE_SYNC = '0' then
          TX_PACKET_STATE <= GET_LENGTH;
        end if;

    end case;
    if RST = '1' then
      TX_PACKET_STATE <= GET_LENGTH;
      TX_WRITE_ADDRESS <= 0;
      S_TX_ACK <= '0';
      GO <= '0';
    end if;
  end process TX_PACKET_FSM;

  TX_ACK <= S_TX_ACK;


  --This process writes data into a dual port RAM
  WRITE_DUAL_PORT_MEMORY : process
  begin
    wait until rising_edge(CLK);
    TX_WRITE_ADDRESS_DEL <= TX_WRITE_ADDRESS;
    if TX_WRITE = '1' then
      TX_MEMORY(TX_WRITE_ADDRESS_DEL) := TX_WRITE_DATA;
    end if;
  end process;

  --This process read data from a dual port RAM
  READ_DUAL_PORT_MEMORY : process
  begin
    wait until rising_edge(CLK_125_MHZ);
    TX_READ_DATA <= TX_MEMORY(TX_READ_ADDRESS);
  end process;

  --This process synchronises ethernet signals
  --to the local clock domain
  LOCAL_TO_CLK_125 : process
  begin
    wait until rising_edge(CLK_125_MHZ);
    GO_DEL <= GO; GO_SYNC <= GO_DEL;
  end process;

  --This process synchronises local signals to the ethernet clock domain
  CLK_125_TO_LOCAL : process
  begin
    wait until rising_edge(CLK);
    DONE_DEL <= DONE; DONE_SYNC <= DONE_DEL;
  end process;

  --Transmit the stored packet via the phy.
  TX_PHY_FSM : process
  begin
    wait until rising_edge(CLK_125_MHZ);
    case TX_PHY_STATE is

      when WAIT_NEW_PACKET => 
        if GO_SYNC = '1' then
          TX_PHY_STATE <= PREAMBLE_0;
          TX_READ_ADDRESS <= 0;
          TX_OUT_COUNT <= to_integer(unsigned(TX_PACKET_LENGTH)-1);
        end if;

      when PREAMBLE_0 => 
        TXD <= X"55"; 
        TX_PHY_STATE <= PREAMBLE_1; 
        TXEN <= '1';

      when PREAMBLE_1 => 
        TXD <= X"55"; 
        TX_PHY_STATE <= PREAMBLE_2;

      when PREAMBLE_2 => 
        TXD <= X"55"; 
        TX_PHY_STATE <= PREAMBLE_3;

      when PREAMBLE_3 => 
        TXD <= X"55"; 
        TX_PHY_STATE <= PREAMBLE_4;

      when PREAMBLE_4 => 
        TXD <= X"55"; 
        TX_PHY_STATE <= PREAMBLE_5;

      when PREAMBLE_5 => 
        TXD <= X"55"; 
        TX_PHY_STATE <= PREAMBLE_6;

      when PREAMBLE_6 => 
        TXD <= X"55"; 
        TX_PHY_STATE <= SFD;
      
      when SFD => 
        TXD <= X"D5";
        TX_PHY_STATE <= SEND_DATA_HI;
        TX_CRC <= X"FFFFFFFF";
          
      when SEND_DATA_HI =>
        TX_CRC <= NEXTCRC32_D8(TX_READ_DATA(15 downto 8), TX_CRC);
        TXD <= TX_READ_DATA(15 downto 8);
        If TX_OUT_COUNT = 0 then
          TX_PHY_STATE <= SEND_CRC_3;
        else
		      TX_PHY_STATE <= SEND_DATA_LO;
          TX_READ_ADDRESS <= TX_READ_ADDRESS + 1;
          TX_OUT_COUNT <= TX_OUT_COUNT - 1;
        end if;
        
      when SEND_DATA_LO =>
        TX_CRC   <= NEXTCRC32_D8(TX_READ_DATA(7 downto 0), TX_CRC);
        TXD   <= TX_READ_DATA(7 downto 0);
        If TX_OUT_COUNT = 0 then
          TX_PHY_STATE <= SEND_CRC_3;
        else
          TX_PHY_STATE <= SEND_DATA_HI;
          TX_OUT_COUNT <= TX_OUT_COUNT - 1;
        end if;
      
      when SEND_CRC_3 => 
        TXD <= not REVERSED(TX_CRC(31 downto  24)); 
        TX_PHY_STATE <= SEND_CRC_2; 

      when SEND_CRC_2 => 
        TXD <= not REVERSED(TX_CRC(23 downto  16)); 
        TX_PHY_STATE <= SEND_CRC_1;

      when SEND_CRC_1 => 
        TXD <= not REVERSED(TX_CRC(15 downto   8)); 
        TX_PHY_STATE <= SEND_CRC_0;

      when SEND_CRC_0 => 
        TXD <= not REVERSED(TX_CRC(7  downto   0)); 
        TX_PHY_STATE <= DONE_STATE;
        
      when DONE_STATE => 
        TXEN <= '0'; 
        DONE <= '1';
        if GO_SYNC = '0' then
          TX_PHY_STATE <= WAIT_NEW_PACKET;
          DONE <= '0';
        end if;         
         
    end case;
    if RST = '1' then
      TXEN <= '0';
      TX_PHY_STATE <= WAIT_NEW_PACKET;
      DONE <= '0';
      TXD <= (others => '0');
    end if;
  end process TX_PHY_FSM;

  TXER   <= '0';
  GTXCLK <= CLK_125_MHZ;
  
  --This process reads data out of the phy and puts it into a buffer.
  --There are many buffers on the RX side to cope with data arriving at
  --a high rate. If a very large packet is received, followed by many small
  --packets, a large number of packets need to be stored.
  RX_PHY_FSM : process
  begin
    wait until rising_edge(RXCLK);
    RX_WRITE_ENABLE <= '0';
    RXDV_D <= RXDV;
    RXER_D <= RXER;
    RXD_D <= RXD;
    case RX_PHY_STATE is

      when WAIT_START =>
        if RXDV_D = '1' and RXD_D = X"55" then
          RX_PHY_STATE <= PREAMBLE;
          RX_ERROR <= '0';
        end if;

      when PREAMBLE =>
        if RXD_D = X"d5" then
          RX_PHY_STATE <= DATA_HIGH;
          RX_START_ADDRESS <= RX_WRITE_ADDRESS;
          RX_PACKET_LENGTH <= to_unsigned(0, ADDRESS_BITS);
          RX_CRC <= X"ffffffff";
        elsif RXD_D /= X"55" or RXDV_D = '0' then
          RX_PHY_STATE <= WAIT_START;
        end if;

      when DATA_HIGH =>
        RX_WRITE_DATA(15 downto 8) <= RXD_D;
        if RXDV_D = '1' then
          RX_PACKET_LENGTH <= RX_PACKET_LENGTH + 1;
          RX_PHY_STATE <= DATA_LOW;
          RX_CRC <= nextCRC32_D8(RXD_D, RX_CRC);
        else
          RX_PHY_STATE <= END_OF_FRAME;
        end if;

      when DATA_LOW =>
        RX_WRITE_DATA(7 downto 0) <= RXD_D;
        RX_WRITE_ENABLE <= '1';
        if RXDV_D = '1' then
          RX_PACKET_LENGTH <= RX_PACKET_LENGTH + 1;
          RX_PHY_STATE <= DATA_HIGH;
          RX_CRC <= nextCRC32_D8(RXD_D, RX_CRC);
        else
          RX_PHY_STATE <= END_OF_FRAME;
        end if;

      when END_OF_FRAME =>
        if RX_ERROR = '1' then
          RX_PHY_STATE <= WAIT_START;
        elsif RX_PACKET_LENGTH < 64 then
          RX_PHY_STATE <= WAIT_START;
        elsif RX_PACKET_LENGTH > 1518 then
          RX_PHY_STATE <= WAIT_START;
        elsif RX_CRC /= X"C704dd7B" then
          RX_PHY_STATE <= WAIT_START;
        else
          RX_PHY_STATE <= NOTIFY_NEW_PACKET;
        end if;

      when NOTIFY_NEW_PACKET =>
        RX_PHY_STATE <= WAIT_START;
        RX_START_ADDRESS_BUFFER(RX_WRITE_BUFFER) <= RX_START_ADDRESS;
        RX_PACKET_LENGTH_BUFFER(RX_WRITE_BUFFER) <= RX_PACKET_LENGTH;
        if RX_WRITE_BUFFER = 31 then
          RX_WRITE_BUFFER <= 0;
        else
          RX_WRITE_BUFFER <= RX_WRITE_BUFFER + 1;
        end if;
        
    end case;

    if RXER_D = '1' then
      RX_ERROR <= '1';
    end if;

    if RST = '1' then
      RX_PHY_STATE <= WAIT_START;
    end if;
  end process RX_PHY_FSM;

  --generate a signal for each buffer to indicate that is is being used.
  GENERATE_BUFFER_BUSY : process
  begin
    wait until rising_edge(RXCLK);
    for I in 0 to 31 loop
      if I = RX_WRITE_BUFFER then
        RX_BUFFER_BUSY(I) <= '1';
      else
        RX_BUFFER_BUSY(I) <= '0';
      end if;
    end loop;
  end process GENERATE_BUFFER_BUSY;

  --This is the memory that implements the RX buffers
  WRITE_RX_MEMORY : process
  begin
    wait until rising_edge(RXCLK);
    if RX_WRITE_ENABLE = '1' then
      RX_MEMORY(to_integer(RX_WRITE_ADDRESS)) := RX_WRITE_DATA;
      RX_WRITE_ADDRESS <= RX_WRITE_ADDRESS + 1;
    end if;
    if RST = '1' then
      RX_WRITE_ADDRESS <= (others => '0');
    end if;
  end process WRITE_RX_MEMORY;

  SYNCHRONISE_BUFFER_BUSY : process
  begin
    wait until rising_edge(CLK);
    RX_BUFFER_BUSY_DEL <= RX_BUFFER_BUSY;
    RX_BUFFER_BUSY_SYNC <= RX_BUFFER_BUSY_DEL;
  end process SYNCHRONISE_BUFFER_BUSY;

  --CLK                  __/""\__/"   _/" "\__/""\
  --RX_BUFFER_BUSY_SYNC[0] ""\_______   ____________
  --RX_BUFFER_BUSY_SYNC[1] ________/"   "\__________
  --RX_BUFFER_BUSY_SYNC[2] __________   _______/""""
  --                       ^
  --                       Start to read packet 0 here.
  -- Note: since RX_BUFFER_BUSY originates in a different clock domain,
  -- it is possible that a clock cycle or so could elapse between
  -- RX_BUFFER_BUSY_SYNC[0] becoming low and RX_BUFFER_BUSY_SYNC[1] becoming
  -- high. We are relying on the delay through the state machine to be
  -- long enough that we don't try to read BUFFER1 during this period.
  
  RX_PACKET_FSM : process
  begin
    wait until rising_edge(CLK);
    case RX_PACKET_STATE is

      when WAIT_INITIALISE =>
        if RX_BUFFER_BUSY_SYNC(0) = '1' then
          RX_PACKET_STATE <= WAIT_NEW_PACKET;
          RX_READ_BUFFER <= 0;
        end if;

      when WAIT_NEW_PACKET =>
        if RX_BUFFER_BUSY_SYNC(RX_READ_BUFFER) = '0' then
          RX_PACKET_STATE <= SEND_LENGTH;
          RX_START_ADDRESS_SYNC <= RX_START_ADDRESS_BUFFER(RX_READ_BUFFER);
          RX_PACKET_LENGTH_SYNC <= RX_PACKET_LENGTH_BUFFER(RX_READ_BUFFER);
          RX <= 
            std_logic_vector(
              resize(RX_PACKET_LENGTH_BUFFER(RX_READ_BUFFER)-4, 16));
          RX_STB <= '1';
        end if;
        
      when SEND_LENGTH =>
        if RX_ACK = '1' then
          RX_PACKET_STATE <= PREFETCH0;
          RX_STB <= '0';
        end if;
        
      when PREFETCH0 =>
        RX_READ_ADDRESS <= RX_START_ADDRESS_SYNC;
        RX_END_ADDRESS <= RX_START_ADDRESS_SYNC + (RX_PACKET_LENGTH_SYNC-3)/2;
        RX_PACKET_STATE <= PREFETCH1;
        
      when PREFETCH1 =>
        RX_READ_ADDRESS <= RX_READ_ADDRESS + 1;
        RX <= RX_MEMORY(to_integer(RX_READ_ADDRESS));
        RX_STB <= '1';
        RX_PACKET_STATE <= SEND_DATA;
        
      when SEND_DATA =>
        if RX_ACK = '1' then
          RX_READ_ADDRESS <= RX_READ_ADDRESS + 1;
          RX <= RX_MEMORY(to_integer(RX_READ_ADDRESS));
          if RX_READ_ADDRESS = RX_END_ADDRESS then --don't send last packet
            RX_STB <= '0';
            RX_PACKET_STATE <= WAIT_NEW_PACKET;
            if RX_READ_BUFFER = 31 then
              RX_READ_BUFFER <= 0;
            else
              RX_READ_BUFFER <= RX_READ_BUFFER + 1;
            end if;
          end if;
        end if;
          
    end case;
    if RST = '1' then
      RX_STB <= '0';
      RX_PACKET_STATE <= WAIT_INITIALISE;
    end if;
  end process RX_PACKET_FSM;

  ----------------------------------------------------------------------
  -- RESET PHY CHIP
  ----------------------------------------------------------------------
  PHY_RESET <= not RST;
  
end architecture RTL;
