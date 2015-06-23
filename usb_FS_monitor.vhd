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
--  File name   : usb_fs_monitor.vhd                                                                        --
--  Author      : Martin Neumann  martin@neumanns-mail.de                                                   --
--  Description : USB bus monitor, logs all USB activities in result.out file.                              --
--                                                                                                          --
--==========================================================================================================--
--                                                                                                          --
-- Change history                                                                                           --
--                                                                                                          --
-- Version / date        Description                                                                        --
--                                                                                                          --
-- 01  05 Mar 2011 MN    Initial version                                                                    --
-- 02  01 Nov 2011 MN    clk_60MHz now internally generated; next_state corrected                           --
-- 03  30 Jan 2012 MN    fixed problems at transfer end, modified for protocol checking                     --
--                                                                                                          --
-- End change history                                                                                       --
--==========================================================================================================--

LIBRARY work, IEEE;
  USE work.usb_commands.ALL;
  USE IEEE.std_logic_1164.all;
  USE IEEE.std_logic_textio.all;
  USE std.textio.all;

ENTITY usb_fs_monitor IS PORT(
  master_oe       : IN STD_LOGIC;
  usb_Dp          : IN STD_LOGIC;
  usb_Dn          : IN STD_LOGIC);
END usb_fs_monitor;

ARCHITECTURE SIM OF usb_fs_monitor IS
  TYPE   state_mode   IS(idle, pid, token1, token2, frame1, frame2, data, eop, err);
  SIGNAL clk_en         : STD_LOGIC;
  SIGNAL clk_60MHz      : STD_LOGIC;
  SIGNAL usb_state      : state_mode;
  SIGNAL byte_valid     : STD_LOGIC;
  SIGNAL usb_dp_sync    : STD_LOGIC;
  SIGNAL usb_dn_sync    : STD_LOGIC;
  SIGNAL usb_bit        : STD_LOGIC;
  SIGNAL usb_byte       : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL bit_cntr       : NATURAL;
  SIGNAL dll_cntr       : NATURAL;
  SIGNAL stuffing_det   : STD_LOGIC;
  SIGNAL edge_detect    : STD_LOGIC;
  SIGNAL usb_dp_s0      : STD_LOGIC;
  SIGNAL usb_dp_s1      : STD_LOGIC;
  SIGNAL usb_dn_s0      : STD_LOGIC;
  SIGNAL usb_dn_s1      : STD_LOGIC;
  SIGNAL usb_dp_last    : STD_LOGIC;
  SIGNAL se0            : BOOLEAN;

BEGIN

--==========================================================================================================--
  -- Synchronize Inputs                                                                                     --
--==========================================================================================================--

  p_clk_60MHz : PROCESS
  BEGIN
    clk_60MHz <= '0';
    While true loop
      clk_60MHz <= '0';
      WAIT FOR 8333 ps;
      clk_60MHz <= '1';
      WAIT FOR 8334 ps; -- 60 MHz
    end loop;
  END PROCESS;

  p_usb_dp_sync: process (clk_60MHz)
  begin
    if rising_edge(clk_60MHz) then
      usb_dp_s0  <= usb_dp;
      usb_dp_s1  <= usb_dp_s0;
      if (usb_dp_s0 and usb_dp_s1) ='1' then
        usb_dp_sync <= '1';
      elsif (usb_dp_s0 OR usb_dp_s1) ='0' then
        usb_dp_sync <= '0';
      end if;
    end if;
  end process;

  p_usb_dn_sync: process (clk_60MHz)
  begin
    if rising_edge(clk_60MHz) then
      usb_dn_s0  <= usb_Dn;
      usb_dn_s1  <= usb_dn_s0;
      if (usb_dn_s0 and usb_dn_s1) ='1' then
        usb_dn_sync <= '1';
      elsif (usb_dn_s0 OR usb_dn_s1) ='0' then
        usb_dn_sync <= '0';
      end if;
    end if;
  end process;

  usb_bit <= usb_dp_sync AND NOT usb_dn_sync;

  p_usb_d_last: process (clk_60MHz)
  begin
    if rising_edge(clk_60MHz) THEN
      usb_dp_last <= usb_dp_sync;
    end if;
  end process;

  edge_detect <= usb_dp_last XOR usb_dp_sync;

  p_dll_cntr: PROCESS (clk_60MHz)
  BEGIN
    IF rising_edge(clk_60MHz) THEN
      IF edge_detect ='1' THEN
        IF dll_cntr >= 8 THEN
          dll_cntr <= 2;         -- clk_en to be centered in next count sequence
        ELSE
          dll_cntr <= 7;         -- clk_en is now centered
        END IF;
      ELSIF dll_cntr >= 8 THEN   -- normal count sequence is 8->4->5->6->7->8->4...
        dll_cntr <= 4;
      ELSE
        dll_cntr <= dll_cntr +1;
      END IF;
    END IF;
  END PROCESS;

  clk_en <= '1' WHEN dll_cntr >= 8 ELSE '0';

--==========================================================================================================--
  -- Analyse USB Inputs                                                                                     --
--==========================================================================================================--

  --se0 <= usb_Dp_sync='0' AND usb_Dn_sync='0';

  p_se0 : PROCESS(clk_60MHz)
  BEGIN
    IF rising_edge(clk_60MHz) THEN
      IF clk_en ='1' THEN
        se0 <= usb_Dp_sync='0' AND usb_Dn_sync='0';
      END IF;
    END IF;
  END PROCESS;

  p_reset_det : PROCESS(clk_60MHz)
    VARIABLE se0_lev      : BOOLEAN;
    VARIABLE se0_time     : Time := 0 ns;
    VARIABLE v_LineWr     : line := NULL;
  BEGIN
    IF rising_edge(clk_60MHz) THEN
      IF clk_en ='1' THEN
        IF se0 THEN
          IF NOT se0_lev THEN
            se0_lev  := TRUE;
            se0_time := now;
          END IF;
        ELSE
          IF se0_lev THEN
            se0_time := now - se0_time;
            IF se0_time >= 200 ns THEN
              write (v_LineWr, now, right,15);
              IF se0_time >= 2500 ns THEN
                write (v_LineWr, STRING'("  USB Reset detected for "));
              ELSE
                write (v_LineWr, STRING'("  USB lines at SE0 for "));
              END IF;
              write (v_LineWr, se0_time, right,15);
              PrintLine(v_LineWr);
            END IF;
          END IF;
          se0_lev := FALSE;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  p_usb_byte : PROCESS(usb_state, clk_60MHz)
    VARIABLE hold, usb_last : STD_LOGIC;
    VARIABLE ones_cnt : NATURAL;
  BEGIN
    IF rising_edge(clk_60MHz) THEN
      IF usb_state = idle OR usb_state = eop THEN
        usb_last := usb_bit;
        bit_cntr <= 0;
        ones_cnt := 0;
        byte_valid <= '0';
        usb_byte <= (OTHERS => 'H');
      ELSIF clk_en ='1' THEN
        IF usb_bit = usb_last THEN
          usb_byte <= '1' & usb_byte(7 DOWNTO 1);
          bit_cntr <= (bit_cntr +1) MOD 8;
          ones_cnt := (ones_cnt +1);
          IF ones_cnt > 6 THEN
            ASSERT FALSE REPORT"Stuffing error" SEVERITY ERROR;
          END IF;
          hold := '0';
        ELSE
          IF ones_cnt /= 6 THEN
            usb_byte <= '0' & usb_byte(7 DOWNTO 1);
            bit_cntr <= (bit_cntr +1) MOD 8;
            hold := '0';
          ELSE
            hold := '1';
          END IF;
          ones_cnt := 0;
        END IF;
        IF bit_cntr=7 THEN
          byte_valid <= NOT hold;
        ELSE
          byte_valid <= '0';
        END IF;
        usb_last := usb_bit;
      END IF;
      stuffing_det <= hold;
    END IF;
  END PROCESS;

  p_usb_state : PROCESS(clk_60MHz)
    VARIABLE address  : STD_LOGIC_VECTOR(6 DOWNTO 0);
    VARIABLE endpoint : STD_LOGIC_VECTOR(3 DOWNTO 0);
    VARIABLE frame_no : STD_LOGIC_VECTOR(10 DOWNTO 0);
    VARIABLE byte_cnt : NATURAL;
    VARIABLE sync_pattern : STD_LOGIC_VECTOR(7 DOWNTO 0);
    VARIABLE v_LineWr : line := NULL;
  BEGIN
    IF rising_edge(clk_60MHz) THEN
      IF clk_en ='1' THEN
        IF se0 THEN
          sync_pattern := (OTHERS => '0');
        ELSE
          sync_pattern := sync_pattern(6 DOWNTO 0) & usb_bit;
        END IF;
        CASE usb_state IS
          WHEN idle   => IF sync_pattern = "01010100" THEN
                           usb_state <= pid;
                         ELSE
                           usb_state <= idle;
                         END IF;
          WHEN pid    => IF byte_valid ='1' THEN
                           IF usb_byte(3 DOWNTO 0) /= NOT usb_byte(7 DOWNTO 4) THEN  --+------+------+-------------+
                             ASSERT FALSE REPORT"PID error" SEVERITY ERROR;          --| PID  | usb- | String      |
                           END IF;                                                   --|Bit3:0|state |             |
                           write (v_LineWr, now, right,15);                          --|------|------|-------------|
                           IF master_oe ='1' THEN                                    --| x"1" | token| "OUT-Token" |
                             write (v_LineWr, STRING'("  Send "));                   --| x"2" | idle | "ACK"       |
                           ELSE                                                      --| x"3" | data | "Data0"     |
                             write (v_LineWr, STRING'("  Recv "));                   --| x"4" | N/A  | "Ping"      |
                           END IF;                                                   --| x"5" | frame| "SOF-Token" |
                           byte_cnt := 0;                                            --| x"6" | idle | "NYET"      |
                           ASSERT usb_byte(3 DOWNTO 0) = NOT usb_byte(7 DOWNTO 4)    --| x"7" | data | "Data2"     |
                             REPORT"PID error detected" SEVERITY ERROR;              --| x"8" | N/A  | "Split"     |
                           CASE usb_byte(3 DOWNTO 0) IS                              --| x"9" | token| "IN-Token"  |
                             WHEN x"1"   => write (v_LineWr, STRING'("OUT-Token"));  --| x"A" | idle | "NAK"       |
                             WHEN x"9"   => write (v_LineWr, STRING'("IN-Token"));   --| x"B" | data | "Data1"     |
                             WHEN x"5"   => write (v_LineWr, STRING'("SOF-Token"));  --| x"C" | N/A  | "Preamble"  |
                             WHEN x"D"   => write (v_LineWr, STRING'("Setup"));      --| x"D" | token| "Setup"     |
                             WHEN x"3"   => write (v_LineWr, STRING'("Data0"));      --| x"E" | idle | "STALL"     |
                             WHEN x"B"   => write (v_LineWr, STRING'("Data1"));      --| x"F" | data | "MData"     |
                             WHEN x"7"   => write (v_LineWr, STRING'("Data2"));      --| x"0" | idle | "Error"     |
                             WHEN x"F"   => write (v_LineWr, STRING'("MData"));      --+------+------+-------------+
                             WHEN x"2"   => write (v_LineWr, STRING'("ACK"));
                             WHEN x"A"   => write (v_LineWr, STRING'("NAK"));
                             WHEN x"E"   => write (v_LineWr, STRING'("STALL"));
                             WHEN x"6"   => write (v_LineWr, STRING'("NYET"));
                             WHEN x"C"   => write (v_LineWr, STRING'("Preamble"));
                          -- WHEN x"C"   => write (v_LineWr, STRING'("SPLIT-ERR"));
                             WHEN x"8"   => write (v_LineWr, STRING'("Split"));
                             WHEN x"4"   => write (v_LineWr, STRING'("Ping"));
                             WHEN OTHERS => ASSERT FALSE REPORT"PID is zero" SEVERITY ERROR;
                           END CASE;
                           CASE usb_byte(3 DOWNTO 0) IS
                             WHEN x"1" | x"9" | x"D"        => usb_state <= token1;
                             WHEN x"5"                      => usb_state <= frame1;
                             WHEN x"3" | x"B" | x"7" | x"F" => usb_state <= data;
                             WHEN x"2" | x"A" | x"E" | x"6" => usb_state <= eop;
                                                               PrintLine(v_LineWr); -- print as soon as possible
                             WHEN others                    => usb_state <= idle;
                               ASSERT FALSE REPORT "FS-Monitor: This PID is not impemented" SEVERITY WARNING;
                           END CASE;
                         END IF;
                         IF se0 THEN
                           usb_state <= err;
                         END IF;
          WHEN token1 => IF byte_valid ='1' THEN
                           address  := usb_byte(6 DOWNTO 0);
                           endpoint(0) := usb_byte(7);
                           usb_state <= token2;
                         END IF;
                         IF se0 THEN
                           usb_state <= err;
                         END IF;
          WHEN token2 => IF byte_valid ='1' THEN
                           endpoint(3 DOWNTO 1) := usb_byte(2 DOWNTO 0);
                           write (v_LineWr, STRING'(": Address 0x"));
                           HexWrite (v_LineWr, address);
                           write (v_LineWr, STRING'(", Endpoint 0x"));
                           HexWrite (v_LineWr, endpoint);
                           write (v_LineWr, STRING'(", CRC5 0x"));
                           HexWrite (v_LineWr, usb_byte(7 DOWNTO 3));
                           usb_state <= eop;
                           PrintLine(v_LineWr);
                         END IF;
          WHEN frame1 => IF byte_valid ='1' THEN
                           frame_no(7 DOWNTO 0) := usb_byte;
                           usb_state <= frame2;
                         END IF;
                         IF se0 THEN
                           usb_state <= err;
                         END IF;
          WHEN frame2 => IF byte_valid ='1' THEN
                           frame_no(10 DOWNTO 8) := usb_byte(2 DOWNTO 0);
                           write (v_LineWr, STRING'(": Frame No 0x"));
                           HexWrite (v_LineWr, frame_no);
                           write (v_LineWr, STRING'(", CRC5 0x"));
                           HexWrite (v_LineWr, usb_byte(7 DOWNTO 3));
                           usb_state <= err;
                           usb_state <= eop;
                           PrintLine(v_LineWr);
                         END IF;
          WHEN data   => IF byte_valid ='1' THEN
                           byte_cnt := byte_cnt +1;
                           IF byte_cnt = 17 THEN
                             PrintLine(v_LineWr);
                             write (v_LineWr, now, right,15);
                             write (v_LineWr, STRING'("       ....."));
                             byte_cnt := 1;
                           END IF;
                           write (v_LineWr, STRING'(" 0x"));
                           HexWrite (v_LineWr, usb_byte);
                         ELSIF se0 THEN
                           PrintLine(v_LineWr);
                           IF bit_cntr <= 1 THEN
                             usb_state <= idle;
                           ELSE
                             usb_state <= err;
                           END IF;
                         END IF;
          WHEN eop    => IF se0 THEN
                           usb_state <= idle;
                         ELSIF stuffing_det = '0' THEN
                           usb_state <= err;
                         END IF;
          WHEN OTHERS => PrintLine(v_LineWr); -- CASE err
                         ASSERT FALSE REPORT "FS monitor: protocol error" SEVERITY ERROR;
                         usb_state <= idle;
        END CASE;
      END IF;
    END IF;
  END PROCESS;

  usb_busy <= NOT(usb_state = idle OR usb_state = eop); -- global signal, defiened and used in usb_commands --

END SIM;

--======================================== END OF usb_fs_monitor.vhd =======================================--
