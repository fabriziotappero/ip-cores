-------------------------------------------------------------------------------
-- arp3.vhd
--
-- Author(s):     Jussi Nieminen after Ashley Partis and Jorgen Peddersen
-- Created:       Feb 2001
-- Last Modified: 2009-09-03
-- 
-- Manages an ARP table for the network stack project.  This protocol listens
-- to incoming data and when an ARP request or reply arrives, the data of the
-- source is added to the ARP table.  The ARP table contains two entries.
-- When a request arrives a signal is also asserted telling the arp sender to
-- send an ARP reply when possible.  The incoming data from the ethernet layer
-- is a byte stream.
-- Licenced under LGPL.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.udp_ip_pkg.all;

entity ARP is
  port (
    clk               : in  std_logic;  -- clock signal
    rstn              : in  std_logic;  -- asynchronous active low reset
    new_frame_in      : in  std_logic;  -- from ethernet layer indicates data arrival
    new_word_valid_in : in  std_logic;  -- indicates a new word in the stream
    frame_re_out      : out std_logic;
    frame_data_in     : in  std_logic_vector (15 downto 0);  -- the stream data
    frame_valid_in    : in  std_logic;  -- indicates validity
    frame_len_in      : in  std_logic_vector( tx_len_w_c-1 downto 0 );
    sending_reply_in  : in  std_logic;  -- ARP sender asserts this when the reply is been transmitted
    req_IP_in         : in  std_logic_vector (31 downto 0);  -- ARP sender can request MACs for this address
    gen_ARP_rep_out   : out std_logic;  -- tell ARP sender to generate a reply
    gen_ARP_IP_out    : out std_logic_vector (31 downto 0);  -- destination IP for generated reply
    lookup_MAC_out    : out std_logic_vector (47 downto 0);  -- if valid, MAC for requested IP
    valid_entry_out   : out std_logic;   -- indicates if req_IP_in is in table
    done_out          : out std_logic
    );
end ARP;

architecture ARP_arch of ARP is

-- State signals and types
  type STATETYPE is (stIdle, stHandleARP, stOperate, stCheckValid);
  signal presState : STATETYPE;
  signal nextState : STATETYPE;

  -- range of 0 to 25 should be enough, but just to be sure..
  signal cnt    : integer range 0 to 2**tx_len_w_c-1;
  signal incCnt : std_logic;              -- signal to increment cnt
  signal rstCnt : std_logic;              -- signal to clear cnt

  signal latchFrameData   : std_logic;  -- signal to latch stream data
  signal frameData_r      : std_logic_vector (15 downto 0);  -- register for latched data
  signal shiftSourceIPIn  : std_logic;  -- signal to shift in source IP
  signal source_IP_r      : std_logic_vector (31 downto 0);  -- stores source IP
  signal shiftSourceMACIn : std_logic;  -- signal to shift in source MAC
  signal source_MAC_r     : std_logic_vector (47 downto 0);  -- stores source MAC

  signal ARP_operation_r    : std_logic;  -- '0' for reply, '1' for request
  signal determineOperation : std_logic;  -- signal to latch ARP_operation_r from stream

  signal updateARPTable      : std_logic;  -- this signal updates the ARP table
  signal ARP_entry_IP_r      : std_logic_vector (31 downto 0);  -- most recent ARP entry IP
  signal ARP_entry_MAC_r     : std_logic_vector (47 downto 0);  -- most recent ARP entry MAC
  signal ARP_entry_IP_old_r  : std_logic_vector (31 downto 0);  -- 2nd ARP entry IP
  signal ARP_entry_MAC_old_r : std_logic_vector (47 downto 0);  -- 2nd ARP entry MAC

  signal doGenARPRep : std_logic;       -- asserted when an ARP reply must be generated

  signal frame_len_r : integer range 0 to 2**tx_len_w_c-1;
  signal frame_invalid_r : std_logic;
  signal frame_invalid : std_logic;
  signal clear_invalid : std_logic;

-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
  
  process (clk, rstn)
  begin
    if rstn = '0' then                  -- reset state and ARP entries

      presState           <= stIdle;
      ARP_entry_IP_r      <= (others => '0');
      ARP_entry_MAC_r     <= (others => '0');
      ARP_entry_IP_old_r  <= (others => '0');
      ARP_entry_MAC_old_r <= (others => '0');
      frame_re_out <= '0';
      cnt <= 0;
      ARP_operation_r <= '0';
      frameData_r <= (others => '0');
      source_IP_r <= (others => '0');
      source_MAC_r <= (others => '0');
      frame_invalid_r <= '0';
      gen_ARP_rep_out <= '0';
      gen_ARP_IP_out <= (others => '0');

    elsif clk'event and clk = '1' then
      presState <= nextState;           -- go to next state
      frame_re_out <= '0';

      if incCnt = '1' then              -- handle counter
        cnt <= cnt + 1;
      elsif rstCnt = '1' then
        cnt <= 0;
      end if;

      if latchFrameData = '1' then      -- latch stream data
        frameData_r <= frame_data_in;
        frame_re_out <= '1';
      end if;

      if determineOperation = '1' then  -- determine ARP Operation value
        ARP_operation_r <= frameData_r(8);
      end if;

      if shiftSourceIPIn = '1' then     -- shift in IP
        source_IP_r <= source_IP_r (15 downto 0) &
                       frameData_r( 7 downto 0 ) & frameData_r( 15 downto 8 );
      end if;

      if shiftSourceMACIn = '1' then    -- shift in MAC
        source_MAC_r <= source_MAC_r (31 downto 0) &
                        frameData_r( 7 downto 0 ) & frameData_r( 15 downto 8 );
      end if;

      if updateARPTable = '1' then      -- update ARP table
        if ARP_entry_IP_r = source_IP_r then  -- We already have this ARP, so update
          ARP_entry_MAC_r     <= source_MAC_r;
        else                            -- Lose one old ARP entry and add new one.
          ARP_entry_IP_old_r  <= ARP_entry_IP_r;
          ARP_entry_MAC_old_r <= ARP_entry_MAC_r;
          ARP_entry_IP_r      <= source_IP_r;
          ARP_entry_MAC_r     <= source_MAC_r;
        end if;
      end if;

      if frame_invalid = '1' then
        frame_invalid_r <= '1';
      elsif clear_invalid = '1' then
        frame_invalid_r <= '0';
      end if;

      if new_frame_in = '1' then
        frame_len_r <= to_integer( unsigned( frame_len_in ));
      end if;

      -- gen_ARP_rep_out is asserted by doGenARPRep and will stay high until cleared 
      -- by sending_reply_in
      if doGenARPRep = '1' then
        gen_ARP_rep_out <= '1';         -- when a request is needed assert gen_ARP_rep_out
        gen_ARP_IP_out  <= source_IP_r;  -- and latch the outgoing address
      elsif sending_reply_in = '1' then
        gen_ARP_rep_out <= '0';         -- when the request is been generated, stop requesting
      end if;
    end if;
  end process;

  process (presState, ARP_operation_r, cnt, new_frame_in, frame_invalid_r,
           new_word_valid_in, frameData_r, frame_valid_in, frame_len_r)
  begin
    -- defaulting of signals
    rstCnt             <= '0';
    incCnt             <= '0';
    shiftSourceIPIn    <= '0';
    determineOperation <= '0';
    updateARPTable     <= '0';
    shiftSourceIPIn    <= '0';
    shiftSourceMACIn   <= '0';
    latchFrameData     <= '0';
    doGenARPRep        <= '0';
    frame_invalid      <= '0';
    clear_invalid      <= '0';
    done_out           <= '0';

    case presState is
      when stIdle =>
        -- wait for an ARP frame to arrive (udp_ip makes sure that it really is
        -- an ARP frame)
        if new_frame_in = '1' then
          nextState <= stHandleARP;
          rstCnt    <= '1';
        else
          -- if there is data still coming to ARP, just pretend to be reading it
          if new_word_valid_in = '1' then
            latchFrameData <= '1';
          end if;
          
          nextState <= stIdle;
        end if;

      when stHandleARP =>
        -- receive a byte from the stream
        if new_word_valid_in = '0' then
          nextState      <= stHandleARP;
        else
          nextState      <= stOperate;
          latchFrameData <= '1';
        end if;

      when stOperate =>
        -- increment counter
        incCnt <= '1';
        -- choose state based on values in the header
        -- The following will make us ignore the frame (all values hexadecimal):
        -- Hardware Type /= 1
        -- Protocol Type /= 800
        -- Hardware Length /= 6
        -- Protocol Length /= 4
        -- Operation /= 1 or 2
        -- Target IP /= our IP (i.e. message is not meant for us)
        if (cnt = 0 and frameData_r /= x"0100") or
          (cnt = 1 and frameData_r /= x"0008") or  -- MSByte = 0 to 7, LSByte = 8 to 15
          (cnt = 2 and frameData_r /= x"0406") or
          (cnt = 3 and frameData_r /= x"0100" and frameData_r /= x"0200") or
          (cnt = 12 and frameData_r /= own_ip_c( 23 downto 16 ) & own_ip_c( 31 downto 24 )) or
          (cnt = 13 and frameData_r /= own_ip_c( 7 downto 0 ) & own_ip_c( 15 downto 8 )) then

          --if ((cnt = "00000" or cnt = "00011" or cnt = "00110") and frameData_r /= 0 )or
          --  (cnt = "00001" and frameData_r /= 1) or
          --  (cnt = "00010" and frameData_r /= 8) or
          --  (cnt = "00100" and frameData_r /= 6) or
          --  (cnt = "00101" and frameData_r /= 4) or
          --  (cnt = "00111" and frameData_r /= 1 and frameData_r /= 2 )or
          --  (cnt = "11000" and frameData_r /= DEVICE_IP (31 downto 24)) or
          --  (cnt = "11001" and frameData_r /= DEVICE_IP (23 downto 16)) or
          --  (cnt = "11010" and frameData_r /= DEVICE_IP (15 downto 8)) or
          --  (cnt = "11011" and frameData_r /= DEVICE_IP (7 downto 0)) then

          frame_invalid <= '1';
        end if;

        -- frame len is in bytes, so divide by two
        if cnt = frame_len_r/2-1 then
          nextState <= stCheckValid;  -- exit when data is totally received
        else
          nextState <= stHandleARP;   -- otherwise loop until complete
        end if;
        

        -- latch and shift in signals from stream when needed
        if cnt = 3 then
          determineOperation <= '1';
        end if;
        if cnt = 4 or cnt = 5 or cnt = 6 then
          shiftSourceMACIn   <= '1';
        end if;
        if cnt = 7 or cnt = 8 then
          shiftSourceIPIn    <= '1';
        end if;

      when stCheckValid =>
        clear_invalid <= '1';

        done_out  <= '1';
        nextState <= stIdle;
        
        if frame_valid_in = '1' and frame_invalid_r = '0' then
          -- frame didn't fail CRC and it's not invalid in any other way either
          -- generate a reply if required and wait for more messages
          if ARP_operation_r = '1' then
            doGenARPRep  <= '1';
          end if;
          updateARPTable <= '1';        -- update the ARP table with the new data
        end if;

      when others => null;

    end case;
  end process;

  -- handle requests for entries in the ARP table.
  process (req_IP_in, ARP_entry_IP_r, ARP_entry_MAC_r, ARP_entry_IP_old_r, ARP_entry_MAC_old_r)
  begin
    if req_IP_in = ARP_entry_IP_r then  -- check most recent entry
      valid_entry_out <= '1';
      lookup_MAC_out  <= ARP_entry_MAC_r;
    elsif req_IP_in = ARP_entry_IP_old_r then  -- check 2nd entry
      valid_entry_out <= '1';
      lookup_MAC_out  <= ARP_entry_MAC_old_r;
    else                                -- if neither entry matches, valid = 0
      valid_entry_out <= '0';
      lookup_MAC_out  <= (others => '1');
    end if;
  end process;
end ARP_arch;
