--==========================================================================================================--
--                                                                                                          --
--  Copyright (C) 2011  by  Martin Neumann martin@neumanns-mail.de                                          --
--                                                                                                          --
--  This source file may be used and distributed without restriction provided that this copyright statement --
--  is not removed from the file and that any derivative work contains the original copyright notice and    --
--  the associated disclaimer.                                                                              --
--                                                                                                          --
--  This software is provided ''as is'' and without any express or implied warranties, including, but not   --
--  limited to, the implied warranties of merchantability and fitness for a particular purpose. In no event --
--  shall the author or contributors be liable for any direct, indirect, incidental, special, exemplary, or --
--  consequential damages (including, but not limited to, procurement of substitute goods or services; loss --
--  of use, data, or profits; or business interruption) however caused and on any theory of liability,      --
--  whether in  contract, strict liability, or tort (including negligence or otherwise) arising in any way  --
--  out of the use of this software, even if advised of the possibility of such damage.                     --
--                                                                                                          --
--==========================================================================================================--
--                                                                                                          --
--  File name   : usb_fs_master.vhd                                                                         --
--  Author      : Martin Neumann  martin@neumanns-mail.de                                                   --
--  Description : USB FS Master, used with usb_Stimuli.vhd data source and usb_fs_monitor.vhd.              --
--                                                                                                          --
--==========================================================================================================--
--                                                                                                          --
-- Change history                                                                                           --
--                                                                                                          --
-- Version / date        Description                                                                        --
--                                                                                                          --
-- 01  05 Mar 2011 MN    Initial version                                                                    --
-- 02  01 Nov 2011 MN    Removed application specific interface, gererate 12 MHz clk internally             --
--                                                                                                          --
-- End change history                                                                                       --
--==========================================================================================================--
--                                                                                                          --
-- http://en.wikipedia.org/wiki/Universal_Serial_Bus                                                        --
-- USB  data is transmitted by  toggling the data lines between the J state and the opposite K state. USB   --
-- encodes data using the  NRZI convention; a 0 bit is transmitted by toggling the data lines from J to K   --
-- or vice-versa, while a 1 bit is transmitted by leaving the data lines as-is.                             --
-- To ensure a minimum density of signal transitions, USB  uses bit stuffing - an extra 0 bit is inserted   --
-- into the data stream after any appearance of six consecutive 1 bits. Seven consecutive '1's are always   --
-- an error.                                                                                                --
-- A USB packet begins with an 8-bit synchronization sequence '00000001'. That is, after the initial idle   --
-- state J, the data lines  toggle KJKJKJKK. The final 1 bit (repeated K state) marks the end of the sync   --
-- pattern  and the beginning of the USB frame. For high bandwidth  USB, the packet  begins with a 32-bit   --
-- synchronization sequence.                                                                                --
-- A USB packet's end, called EOP (end-of-packet), is indicated by the transmitter driving 2 bit times of   --
-- SE0 (D+ and D- both below max) and 1 bit time of J state.  After this, the transmitter ceases to drive   --
-- the D+/D- lines and the aforementioned pull up resistors hold it in the J (idle) state. Sometimes skew   --
-- due to hubs can add as much as one bit time before the SE0 of the end of packet.                         --
-- This  extra bit  can result in a "bit stuff violation" if  the six bits before it  in the CRC are '1's.  --
-- This bit should be ignored by receiver.                                                                  --
-- A USB bus is reset using a prolonged (10 to 20 milliseconds) SE0 signal.                                 --
--                                                                                                          --
--==========================================================================================================--

LIBRARY IEEE;
  USE IEEE.std_logic_1164.all;
  USE IEEE.std_logic_textio.all;
  USE std.textio.all;

LIBRARY work;
  USE work.usb_commands.all;

ENTITY usb_fs_master IS PORT(
  rst_neg_ext     : OUT   STD_LOGIC;
  usb_Dp          : INOUT STD_LOGIC;
  usb_Dn          : INOUT STD_LOGIC
);
END usb_fs_master;

ARCHITECTURE SIM OF usb_fs_master IS

  SIGNAL T_No           : NATURAL;
  SIGNAL usb_clk        : STD_LOGIC;
  SIGNAL crc_16         : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL crc_5          : STD_LOGIC_VECTOR( 4 DOWNTO 0);
  SIGNAL master_oe      : STD_LOGIC;
  SIGNAL stimuli_bit    : STD_LOGIC := 'Z';
  SIGNAL stuffing_requ  : BOOLEAN;
  SIGNAL usb_request    : usb_action;

  function next_CRC_5 (Data: std_logic; crc:  std_logic_vector(4 downto 0)) return std_logic_vector is
    -- Copyright (C) 1999-2008 Easics NV. http://www.easics.com/webtools/crctool
    variable d:       std_logic;
    variable c:       std_logic_vector(4 downto 0);
    variable new_crc: std_logic_vector(4 downto 0);
  begin
    d          := Data;
    c          := crc;
    new_crc(0) := d xor c(4);
    new_crc(1) := c(0);
    new_crc(2) := d xor c(1) xor c(4);
    new_crc(3) := c(2);
    new_crc(4) := c(3);
    return new_crc;
  end next_CRC_5;

  function next_CRC_16 (Data: std_logic; crc:  std_logic_vector(15 downto 0)) return std_logic_vector is
    -- Copyright (C) 1999-2008 Easics NV. http://www.easics.com/webtools/crctool
    variable d:      std_logic;
    variable c:      std_logic_vector(15 downto 0);
    variable new_crc: std_logic_vector(15 downto 0);
  begin
    d                     := Data;
    c                     := crc;
    new_crc(0)            := d xor c(15);
    new_crc(1)            := c(0);
    new_crc(2)            := d xor c(1) xor c(15);
    new_crc(14 DOWNTO 3)  := c(13 DOWNTO 2);
    new_crc(15)           := d xor c(14) xor c(15);
    return new_crc;
  end next_CRC_16;

  FUNCTION nrzi(data_bit, last_level : std_logic) RETURN STD_LOGIC IS
  BEGIN
    IF data_bit = '0' THEN
      RETURN not last_level;
    ELSE
      RETURN last_level;
    END IF;
  END nrzi;

--==========================================================================================================--

begin

  p_usb_clk : PROCESS
  BEGIN
    usb_clk <= '0';
    WAIT FOR 20866 ps;
    usb_clk <= '1';
    WAIT FOR 41600 ps;
    usb_clk <= '0';
    WAIT FOR 20867 ps;
  END PROCESS;

  test_case : ENTITY work.usb_stimuli
  PORT MAP(
    usb         => usb_request,
    rst_neg_ext => rst_neg_ext,
    T_No        => T_No
  );

  usb_fs_monitor : ENTITY work.usb_fs_monitor
  port map (
    master_oe   => master_oe,
    usb_Dp      => usb_dp,
    usb_Dn      => usb_dn
  );

  master_oe <= '0' WHEN usb_request = idle OR usb_request = recv_eop ELSE '1';

  p_usb_data : PROCESS
    VARIABLE d_new    : STD_LOGIC;
    VARIABLE ones_cnt : NATURAL;
  BEGIN
    WAIT UNTIL rising_edge(usb_clk);
    stuffing_requ <= FALSE;
    IF stimuli_bit = 'L' THEN
      usb_Dp <= '0';
      usb_Dn <= '0';
    ELSIF stimuli_bit = 'Z' THEN
      usb_Dp <= 'Z';
      usb_Dn <= 'L';
    ELSIF stimuli_bit = '1' THEN
      ones_cnt := ones_cnt +1;
      d_new  := nrzi('1', usb_Dp);
      usb_Dp <= d_new;
      usb_Dn <= not d_new;
      IF ones_cnt = 6 THEN   -- add stuffing bit
        stuffing_requ <= TRUE;
        ones_cnt := 0;
        WAIT UNTIL rising_edge(usb_clk);
        stuffing_requ <= FALSE;
        d_new  := nrzi('0', usb_Dp);
        usb_Dp <= d_new;
        usb_Dn <= not d_new;
      END IF;
    ELSE
      ones_cnt := 0;
      d_new  := nrzi('0', usb_Dp);
      usb_Dp <= d_new;
      usb_Dn <= not d_new;
    END IF;
  END PROCESS;

  p_stimuli_bit : PROCESS                                        --always transfer LSB first (exception crc)
    CONSTANT sync_data : std_logic_vector(7 DOWNTO 0) := X"80";  --USB FS : sync patter is KJKJKJKK
    CONSTANT eop_data  : std_logic_vector(3 DOWNTO 0) := "Z0LL"; --'L' forces both usb_up, usb_dn low !!
  BEGIN
    WAIT ON usb_request;
    IF usb_request = reset THEN
      usb_status <= usb_request;
      stimuli_bit <= 'L';
      WAIT FOR 5 us;
      WAIT UNTIL rising_edge(usb_clk);
      stimuli_bit <= 'Z';
      usb_status <= idle;
    ELSIF usb_request = sync THEN
      usb_status <= usb_request;
      FOR i IN 0 TO 7  LOOP -- Sync pattern
        WAIT UNTIL rising_edge(usb_clk);
        stimuli_bit <= sync_data(i);
      END LOOP;
      usb_status <= idle;
    ELSIF usb_request = pid THEN
      usb_status <= usb_request;
      FOR i IN 0 TO 7  LOOP
        WAIT UNTIL rising_edge(usb_clk) AND NOT stuffing_requ;
        stimuli_bit <= sv_usb_byte(i);
      END LOOP;
      crc_5   <= (others =>'1');
      crc_16  <= (others =>'1');
      usb_status <= idle;
    ELSIF usb_request = addr THEN
      usb_status <= usb_request;
      FOR i IN 0 TO 10 LOOP
        WAIT UNTIL rising_edge(usb_clk) AND NOT stuffing_requ;
        stimuli_bit <= sv_usb_addr(i);
        crc_5  <= next_crc_5(sv_usb_addr(i),crc_5);
      END LOOP;
      usb_status <= idle;
    ELSIF usb_request = wr_odd OR usb_request = wr_even THEN
      usb_status <= usb_request;
      FOR i IN 0 TO 7 LOOP
        WAIT UNTIL rising_edge(usb_clk) AND NOT stuffing_requ;
        stimuli_bit <= sv_usb_byte(i);
        crc_16  <= next_crc_16(sv_usb_byte(i),crc_16);
      END LOOP;
      usb_status <= idle;
   --   WAIT for 1 ns;
    ELSIF usb_request = wr_crc5 THEN
      usb_status <= usb_request;
      FOR i IN 4 DOWNTO 0 LOOP   -- Token crc5, LSB last
        WAIT UNTIL rising_edge(usb_clk) AND NOT stuffing_requ;
        stimuli_bit <= NOT crc_5(i);
      END LOOP;
      usb_status <= idle;
    ELSIF usb_request = wr_crc16 THEN
      usb_status <= usb_request;
      FOR i IN 15 DOWNTO 0 LOOP  -- Data crc16, LSB last
        WAIT UNTIL rising_edge(usb_clk) AND NOT stuffing_requ;
        stimuli_bit <= NOT crc_16(i);
      END LOOP;
      usb_status <= idle;
    ELSIF usb_request = send_eop THEN
      usb_status <= usb_request;
      FOR i IN 0 TO 3 LOOP
        WAIT UNTIL rising_edge(usb_clk) AND NOT stuffing_requ;
        stimuli_bit <= eop_data(i);
      END LOOP;
      usb_status <= idle;
    ELSIF usb_request = Recv_eop THEN
      usb_status <= usb_request;
      WAIT UNTIL rising_edge(usb_clk) AND usb_Dp ='0' AND usb_Dn ='0';
      WAIT FOR 400 ns;
      usb_status <= idle;
    ELSE
      stimuli_bit <= 'Z';
      usb_status <= idle;
    END IF;
  END PROCESS;

END SIM;

--======================================== END OF usb_fs_master.vhd ========================================--
