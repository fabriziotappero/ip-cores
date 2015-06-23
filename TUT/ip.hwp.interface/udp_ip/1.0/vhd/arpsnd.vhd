-------------------------------------------------------------------------------
-- arpsnd.vhd
--
-- Author(s):     Jussi Nieminen after Ashley Partis and Jorgen Peddersen
-- Created:       Feb 2001
-- Last Modified: Feb 2001
-- 
-- Sits transparently between the internet send and ethernet send layers.
-- All frame send requests from the internet layer are passed through after
-- the destination MAC is either looked up from the ARP table, or an ARP 
-- request is sent out and an ARP reply is receiver.  ARP replies are created
-- and then sent to the ethernet later after being requested by the ARP layer.  
-- After each frame is passed on to the ethernet layer and then sent, it informs
-- the layer above that the frame has been sent.
--
-- Licenced under LGPL.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.udp_ip_pkg.all;

entity ARPSnd is
  port (
    clk                : in  std_logic;  -- clock
    rstn               : in  std_logic;  -- aysnchronous active low reset
    request_MAC_in     : in  std_logic;  -- IP layer want's to know a MAC addr
    targer_IP_in       : in  std_logic_vector (31 downto 0);  -- destination IP from the internet layer
    ARP_entry_valid_in : in  std_logic;  -- input from ARP indicating that it contains the requested IP
    gen_ARP_reply_in   : in  std_logic;  -- input from ARP requesting an ARP reply
    gen_ARP_IP_in      : in  std_logic_vector (31 downto 0);  -- input from ARP saying which IP to send a reply to
    lookup_MAC_in      : in  std_logic_vector (47 downto 0);  -- input from ARP giving a requested MAC
    lookup_IP_out      : out std_logic_vector (31 downto 0);  -- output to ARP requesting an IP to be looked up in the table
    sending_reply_out  : out std_logic;  -- output to ARP to tell it's sending the ARP reply
    target_MAC_out     : out std_logic_vector (47 downto 0);  -- destination MAC for the physical layer
    requested_MAC_out  : out std_logic_vector( 47 downto 0 );  -- requested MAC to UDP/IP
    req_MAC_valid_out  : out std_logic;
    gen_frame_out      : out std_logic;  -- tell the ethernet layer (PHY) to send a frame
    frame_type_out     : out std_logic_vector( frame_type_w_c-1 downto 0 );
    frame_size_out     : out std_logic_vector (10 downto 0);  -- tell the PHY what size the frame size is
    tx_ready_out           : out std_logic;  -- idle signal
    wr_data_valid_out  : out std_logic;
    wr_data_out        : out std_logic_vector (15 downto 0);
    wr_re_in           : in  std_logic
    );
end ARPSnd;

architecture ARPSnd_arch of ARPSnd is

-- FSM state definitions
  type STATETYPE is (stIdle, stGenARPReply, stGetReplyMAC, stStoreARPReply, stCheckARPEntry, stCheckARPEntry2,
                     stGenARPRequest, stStoreARPRequest, stWaitForValidEntry, stGiveMAC);
  signal presState : STATETYPE;
  signal nextState : STATETYPE;

-- signals to synchronously increment and reset the counter
  signal cnt    : std_logic_vector (4 downto 0);
  signal incCnt : std_logic;
  signal rstCnt : std_logic;

-- next write data value
  signal nextWrData : std_logic_vector (15 downto 0);

-- signals and buffers to latch input data
  signal latchTargetIP   : std_logic;
  signal latchInternetIP : std_logic;
  signal IP_r            : std_logic_vector (31 downto 0);
  signal latchTargetMAC  : std_logic;
  signal MAC_r           : std_logic_vector (47 downto 0);

-- 20 second ARP reply timeout counter at 50MHz
  signal ARP_timeout_cnt_r  : std_logic_vector (29 downto 0);
  signal rstARPCnt          : std_logic;
  signal ARP_cnt_overflow_r : std_logic;

  signal wr_data_r     : std_logic_vector( 15 downto 0 );
  signal wr_data_valid : std_logic;
  signal start_tx      : std_logic;
  signal MAC_to_output : std_logic;
  signal req_MAC_valid_r : std_logic;

  constant ARP_frame_size_c : std_logic_vector( 10 downto 0 ) := "00000011100";

-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------

  -- connect output to register
  wr_data_out <= wr_data_r;
  req_MAC_valid_out <= req_MAC_valid_r;

  process (rstn, clk)
  begin
    -- set up the asynchronous active low reset
    if rstn = '0' then
      
      presState         <= stIdle;
      cnt               <= (others => '0');
      wr_data_valid_out <= '0';
      wr_data_r         <= (others => '0');
      
      ARP_timeout_cnt_r  <= (others => '0');
      ARP_cnt_overflow_r <= '0';
      IP_r               <= (others => '0');
      MAC_r              <= (others => '0');
      
      gen_frame_out     <= '0';
      target_MAC_out    <= (others => '0');
      frame_size_out    <= (others => '0');
      frame_type_out    <= (others => '0');
      req_MAC_valid_r   <= '0';
      requested_MAC_out <= (others => '0');

    elsif clk'event and clk = '1' then

      presState <= nextState;
      -- set the write data bus to it's next value
      wr_data_r <= nextWrData;

      -- register valid signal
      if wr_data_valid = '1' then
        wr_data_valid_out <= '1';
      end if;

      -- start a tx
      if start_tx = '1' then
        if latchTargetMAC = '1' then
          target_MAC_out <= lookup_MAC_in;
        else
          target_MAC_out <= x"FFFFFFFFFFFF";
        end if;
        gen_frame_out    <= '1';        -- goes to 'new tx' and 'snd_req' (udp)
        frame_size_out   <= ARP_frame_size_c;
        frame_type_out   <= ARP_frame_type_c;
      end if;

      if wr_re_in = '1' then
        -- clear gen_frame_out when eth cntrl starts to read
        gen_frame_out     <= '0';
        -- also clear the valid signal
        wr_data_valid_out <= '0';
      end if;


      -- increment and reset the counter synchronously to avoid race conditions
      if incCnt = '1' then
        cnt <= cnt + 1;
      elsif rstCnt = '1' then
        cnt <= (others => '0');
      end if;

      -- set the ARP counter to 1
      if rstARPCnt = '1' then
        ARP_timeout_cnt_r  <= "00" & x"0000001";
        ARP_cnt_overflow_r <= '0';
        -- if the ARP counter isn't 0, keep incrementing it
      elsif ARP_timeout_cnt_r /= "00" & x"0000000" then
        ARP_timeout_cnt_r  <= ARP_timeout_cnt_r + 1;
        ARP_cnt_overflow_r <= '0';
        -- if the counter is 0, set the overflow signal
      else
        ARP_cnt_overflow_r <= '1';
      end if;

      -- latch the IP to send the ARP request to, send the ARP reply to or to lookup
      -- from either the ARP layer or internet send layer
      if latchTargetIP = '1' then
        IP_r <= gen_ARP_IP_in;
      elsif latchInternetIP = '1' then
        IP_r <= targer_IP_in;
      end if;

      -- latch the MAC from the ARP table that has been looked up
      if latchTargetMAC = '1' then
        MAC_r <= lookup_MAC_in;
      end if;

      if MAC_to_output = '1' then
        -- put out the MAC when we have it
        requested_MAC_out <= MAC_r;
        req_MAC_valid_r <= '1';
        
      elsif request_MAC_in = '0' then
        -- clear the valid signal when IP layer stops requesting
        req_MAC_valid_r <= '0';
      end if;

    end if;
  end process;



-- ARP header format
--
--      0                     8                     16                                             31
--      --------------------------------------------------------------------------------------------
--      |                Hardware Type               |               Protocol Type                 |
--      |                                            |                                             |
--      --------------------------------------------------------------------------------------------
--      |   Hardware Address  |   Protocol Address   |                 Operation                   |
--      |       Length        |       Length         |                                             |
--      --------------------------------------------------------------------------------------------
--      |                          Sender Hardware Address (MAC) (bytes 0 - 3)                     |
--      |                                                                                          |
--      --------------------------------------------------------------------------------------------
--      |           Sender MAC (bytes 4 - 5)         |        Sender IP Address (bytes 0 - 1)      |
--      |                                            |                                             |
--      --------------------------------------------------------------------------------------------
--      |            Sender IP (bytes 2 - 3)         |    Target Hardware Address (bytes 0 - 1)    |
--      |                                            |                                             |
--      --------------------------------------------------------------------------------------------
--      |                                  Target MAC (bytes 2 - 5)                                |
--      |                                                                                          |
--      --------------------------------------------------------------------------------------------
--      |                               Target IP Address (bytes 0 - 3)                            |
--      |                                                                                          |
--      --------------------------------------------------------------------------------------------
--

  -- main FSM process
  process (presState, gen_ARP_reply_in, cnt, IP_r, MAC_r, wr_data_r, req_MAC_valid_r,
           ARP_entry_valid_in, ARP_cnt_overflow_r, request_MAC_in, wr_re_in)
  begin
    -- remember the value of the RAM write data bus by default
    nextWrData        <= wr_data_r;
    -- lookup the latched IP by default
    lookup_IP_out     <= IP_r;
    rstCnt            <= '0';
    incCnt            <= '0';
    sending_reply_out <= '0';
    tx_ready_out      <= '0';
    latchInternetIP   <= '0';
    latchTargetIP     <= '0';
    latchTargetMAC    <= '0';
    rstARPCnt         <= '0';
    wr_data_valid     <= '0';
    MAC_to_output     <= '0';

    start_tx <= '0';

    case presState is
      when stIdle =>
        -- wait for a frame to arrive
        -- if req_MAC_valid_r = '1', we have just arrived from state stGiveMAC
        -- and we don't want to get again to stCheckARPEntry.
        if (req_MAC_valid_r = '1' or request_MAC_in = '0')
          and gen_ARP_reply_in = '0'
        then
          nextState    <= stIdle;
          tx_ready_out <= '1';
          rstCnt       <= '1';

          -- create an ARP reply when asked, giving ARP message priority
        elsif gen_ARP_reply_in = '1' then
          nextState     <= stGetReplyMAC;
          -- latch the target IP from the ARP layer
          latchTargetIP <= '1';

        -- IP layer wants to have a MAC address
        else
          nextState       <= stCheckARPEntry;
          -- latch input from the IP layer
          latchInternetIP <= '1';
        end if;

        -- create the ARP reply, getting the target MAC from the ARP table
      when stGetReplyMAC =>
        nextState         <= stGenARPReply;
        lookup_IP_out     <= IP_r;
        latchTargetMAC    <= '1';
        -- tell the ARP table that we're sending the reply
        sending_reply_out <= '1';
        start_tx          <= '1';

        -- generate each byte of the ARP reply according to count
      when stGenARPReply =>

        wr_data_valid <= '1';
        nextState     <= stStoreARPReply;

        case cnt is

          -- Hardware type
          when "00000" =>
            nextWrData <= x"0100";       -- remember, it's x"LSByte MSByte"

          -- Protocol type
          when "00001" =>
            nextWrData <= x"0008";

            -- Hardware and protocol Address lengths in bytes (x"PAL HAL")
          when "00010" =>
            nextWrData <= x"0406";

            -- Operation
          when "00011" =>
            nextWrData <= x"0200";

            -- Sender Hardware Address bytes 1 and 0
          when "00100" =>
            nextWrData <= MAC_addr_c( 39 downto 32 ) & MAC_addr_c (47 downto 40);

            -- Sender Hardware Address bytes 3 and 2
          when "00101" =>
            nextWrData <= MAC_addr_c( 23 downto 16 ) & MAC_addr_c (31 downto 24);

            -- Sender Hardware Address bytes 5 and 4
          when "00110" =>
            nextWrData <= MAC_addr_c( 7 downto 0 ) & MAC_addr_c (15 downto 8);

            -- Sender IP Address bytes 1 and 0
          when "00111" =>
            nextWrData <= own_IP_c( 23 downto 16 ) & own_IP_c (31 downto 24);

            -- Sender IP Address bytes 3 and 2
          when "01000" =>
            nextWrData <= own_IP_c( 7 downto 0 ) & own_IP_c (15 downto 8);

            -- Target Hardware Address bytes 1 and 0
          when "01001" =>
            nextWrData <= MAC_r( 39 downto 32 ) & MAC_r( 47 downto 40 );

            -- Target Hardware Address bytes 3 and 2
          when "01010" =>
            nextWrData <= MAC_r( 23 downto 16 ) & MAC_r( 31 downto 24 );

            -- Target Hardware Address bytes 5 and 4
          when "01011" =>
            nextWrData <= MAC_r( 7 downto 0 ) & MAC_r( 15 downto 8 );

            -- Target IP Address bytes 1 and 0
          when "01100" =>
            nextWrData <= IP_r( 23 downto 16 ) & IP_r (31 downto 24);

            -- Target IP Address bytes 3 and 2
          when "01101" =>
            nextWrData <= IP_r( 7 downto 0 ) & IP_r (15 downto 8);

          when others => null;
        end case;

        -- store the ARP reply for the Ethernet sender
      when stStoreARPReply =>

        if wr_re_in = '1' then
          if cnt = "01101" then
            nextState <= stIdle;
          else
            nextState <= stGenARPReply;
            incCnt    <= '1';
          end if;

        else
          nextState <= stStoreARPReply;
        end if;


        -----------------------------------------------------------------------------------
        -- handle frames passed on to us from the Internet layer
        -- check to the see if the desired IP is in the ARP table
      when stCheckARPEntry =>
        nextState     <= stCheckARPEntry2;
        lookup_IP_out <= IP_r;

        -- check to see if the ARP entry is valid
      when stCheckARPEntry2 =>
        lookup_IP_out    <= IP_r;
        -- if it's not a valid ARP entry, then generate an ARP request to find the
        -- desired MAC address
        if ARP_entry_valid_in = '0' then
          nextState      <= stGenArpRequest;
          start_tx       <= '1';
          -- otherwise pass the MAC to the UDP/IP block
        else
          nextState      <= stGiveMAC;
          latchTargetMAC <= '1';
        end if;

        -- create each byte of the ARP request according to cnt
      when stGenARPRequest =>

        wr_data_valid <= '1';
        nextState <= stStoreARPRequest;
        case cnt is


          -- Hardware type
          when "00000" =>
            nextWrData <= x"0100";       -- remember, it's x"LSByte MSByte"

            -- Protocol type
          when "00001" =>
            nextWrData <= x"0008";

            -- Hardware and protocol Address lengths in bytes (x"PAL HAL")
          when "00010" =>
            nextWrData <= x"0406";

            -- Operation
          when "00011" =>
            nextWrData <= x"0100";

            -- Sender Hardware Address bytes 1 and 0
          when "00100" =>
            nextWrData <= MAC_addr_c( 39 downto 32 ) & MAC_addr_c (47 downto 40);

            -- Sender Hardware Address bytes 3 and 2
          when "00101" =>
            nextWrData <= MAC_addr_c( 23 downto 16 ) & MAC_addr_c (31 downto 24);

            -- Sender Hardware Address bytes 5 and 4
          when "00110" =>
            nextWrData <= MAC_addr_c( 7 downto 0 ) & MAC_addr_c (15 downto 8);

            -- Sender IP Address bytes 1 and 0
          when "00111" =>
            nextWrData <= own_IP_c( 23 downto 16 ) & own_IP_c (31 downto 24);

            -- Sender IP Address bytes 3 and 2
          when "01000" =>
            nextWrData <= own_IP_c( 7 downto 0 ) & own_IP_c (15 downto 8);

            -- Target Hardware Address bytes 1 and 0
          when "01001"            =>
            nextWrData <= (others => '0');

            -- Target Hardware Address bytes 3 and 2
          when "01010"            =>
            nextWrData <= (others => '0');

            -- Target Hardware Address bytes 5 and 4
          when "01011"            =>
            nextWrData <= (others => '0');

            -- Target IP Address bytes 1 and 0
          when "01100" =>
            nextWrData <= IP_r( 23 downto 16 ) & IP_r (31 downto 24);

            -- Target IP Address bytes 3 and 2
          when "01101" =>
            nextWrData <= IP_r( 7 downto 0 ) & IP_r (15 downto 8);

          when others => null;
        end case;

        -- store the ARP reply for the Ethernet sender
      when stStoreARPRequest =>

        if wr_re_in = '1' then
          if cnt = "01101" then
            nextState <= stWaitForValidEntry;
            rstARPCnt <= '1';
          else
            nextState <= stGenARPRequest;
            incCnt    <= '1';
          end if;

        else
          nextState <= stStoreARPRequest;
        end if;


        -- wait for the ARP entry to become valid
      when stWaitForValidEntry =>
        -- if the ARP entry becomes valid then we fire off the reply
        if ARP_entry_valid_in = '1' then
          tx_ready_out   <= '1';
          nextState      <= stGiveMAC;
          latchTargetMAC <= '1';
          
          -- otherwise give a certain amount of time for the ARP reply to come
          -- back in (21.5 secs on a 50MHz clock)
        else
          -- if the reply doesn't come back, then inform the above layer that the
          -- frame was sent.  Assume the higher level protocol can account for this
          -- problem, or possibly an error signal could be created once a higher level
          -- protocol has been written that can accomodate this
          if ARP_cnt_overflow_r = '1' then
            nextState         <= stIdle;
          else
            nextState         <= stWaitForValidEntry;
          end if;
        end if;
        lookup_IP_out         <= IP_r;


      when stGiveMAC =>

        MAC_to_output <= '1';
        nextState     <= stIdle;
        
      when others => nextState <= stIdle;
    end case;
  end process;

end ARPSnd_arch;
