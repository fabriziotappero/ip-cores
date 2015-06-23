--==========================================================================================================--
--                                                                                                          --
--  Copyright (C) 2011  by  Martin Neumann martin@neumanns-mail.de                                          --
--                                                                                                          --
--  This source file may be used and distributed without restriction provided that this copyright statement --
--  is not removed from the file and that any derivative work contains the original copyright notice and    --
--  the associated disclaimer.                                                                              --
--                                                                                                          --
--  This software is provided ''as is'' and without any express or implied warranties, including, but not   --
--  limited to, the implied warranties of merchantability and fitness for a particular purpose. in no event --
--  shall the author or contributors be liable for any direct, indirect, incidental, special, exemplary, or --
--  consequential damages (including, but not limited to, procurement of substitute goods or services; loss --
--  of use, data, or profits; or business interruption) however caused and on any theory of liability,      --
--  whether in  contract, strict liability, or tort (including negligence or otherwise) arising in any way  --
--  out of the use of this software, even if advised of the possibility of such damage.                     --
--                                                                                                          --
--==========================================================================================================--
--                                                                                                          --
--  File name   : usb_commands.vhd                                                                          --
--  Author      : Martin Neumann  martin@neumanns-mail.de                                                   --
--  Description : Defines, functions and procedures for the usb_Stimuli.vhd file - the USB data source for  --
--                the test bench file.                                                                      --
--                                                                                                          --
--==========================================================================================================--
--                                                                                                          --
-- Change history                                                                                           --
--                                                                                                          --
-- Version / date        Description                                                                        --
--                                                                                                          --
-- 01  05 Mar 2011 MN    Initial version                                                                    --
--                                                                                                          --
-- End change history                                                                                       --
--==========================================================================================================--
--                                                                                                          --
--  USB control concept                                                                                     --
--  -------------------                                                                                     --
--  The usb signal controls the usb command execution and its proper timing :                               --
--                                                                                                          --
--  Each command in the test case file 'usb_stimuli.vhd' is a procedure call with an output signal 'usb'.   --                                                                                        --
--  Its states (of type usb_action) control the correct timing sequence of the process 'p_stimuli_bit' in   --
--  the file'usb_master'. This procedure sets the signal usb first to any one of the active states, then    --
--  after completion to inactive (idle).                                                                    --
--                                                                                                          --
--==========================================================================================================--
--                                                                                                          --
--  Syntax Examples                                                                                         --
--                                                                                                          --
--  Procedure                                             Function,   Parameters                            --
--                                                                                                          --
--  list      (T_No, 30);                                 Test No  listed in transcript and report file     --
--  List      ("Any Text Message ");                      Message     any text                              --
--  Setup     (usb, X"00", X"0");                         usb setup:  device address, endp address (+CRC5)  --
--  send_D0   (usb, (X"10",X"46",X"11",X"47",                                                               --
--                  X"12",X"48",X"13",X"49"));            usb write data0 :  byte string (+CRC16)           --
--  send_D1   (usb, (X"20",X"36",X"21",X"37",                                                               --
--                  X"22",X"38",X"23",X"39"));            usb write data1 :  byte string (+CRC16)           --
--  send_ACK  (usb);                                      usb ACK Handshake                                 --
--  send_NAK  (usb);                                      usb NAK Handshake                                 --
--  send_STALL(usb);                                      usb Stall Handshake                               --
--  send_NYET (usb);                                      usb NYET (No Response Yet) Handshake              --
--  wait_slv  (usb);                                      wait until transfer of USB-slave completed        --
--                                                                                                          --
--==========================================================================================================--

LIBRARY IEEE;
  USE IEEE.std_logic_1164.all;
  USE IEEE.std_logic_textio.all;
  USE IEEE.std_logic_arith.all;
  USE IEEE.std_logic_unsigned.all;
  USE std.textio.all;

PACKAGE usb_commands IS

--==========================================================================================================--

  TYPE   usb_action IS (idle, sync, pid, addr, rd, wr_odd, wr_even, wr_crc5, wr_crc16, reset, send_eop, recv_eop);
  TYPE   byte_array IS ARRAY (NATURAL RANGE <>) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL          usb_status       : usb_action;
  SIGNAL          usb_busy         : BOOLEAN := FALSE;
  SHARED VARIABLE ok               : BOOLEAN;
  SHARED VARIABLE sv_usb_byte      : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SHARED VARIABLE sv_usb_addr      : STD_LOGIC_VECTOR(10 DOWNTO 0);
  SHARED VARIABLE sv_read_loop     : BOOLEAN := FALSE;
  FILE            screen           : TEXT OPEN WRITE_MODE IS "STD_OUTPUT";
  FILE            outpdata         : TEXT OPEN WRITE_MODE IS "Result.out";


  PROCEDURE list(message : IN STRING);
  PROCEDURE list(SIGNAL no_out : OUT NATURAL; no_in : IN NATURAL);

  PROCEDURE end_of_test(stop : IN BOOLEAN := TRUE);

--==========================================================================================================--

  PROCEDURE send_ACK  (SIGNAL usb : OUT usb_action);

  PROCEDURE send_NAK  (SIGNAL usb : OUT usb_action);

  PROCEDURE send_STALL(SIGNAL usb : OUT usb_action);

  PROCEDURE send_NYET (SIGNAL usb : OUT usb_action);

  PROCEDURE handshake(SIGNAL usb : OUT usb_action; CONSTANT pid_val : IN std_logic_vector(3 DOWNTO 0));

  PROCEDURE setup(
    SIGNAL usb           : OUT usb_action;
    CONSTANT device_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    CONSTANT endp_addr   : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
  );

  PROCEDURE in_token(
    SIGNAL usb           : OUT usb_action;
    CONSTANT device_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    CONSTANT endp_addr   : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
  );

  PROCEDURE out_token(
    SIGNAL usb           : OUT usb_action;
    CONSTANT device_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    CONSTANT endp_addr   : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
  );

  PROCEDURE sof_token(
    SIGNAL usb           : OUT usb_action;
    CONSTANT frame_no    : IN STD_LOGIC_VECTOR(11 DOWNTO 0)
  );

  PROCEDURE token(
    SIGNAL   usb         : OUT usb_action;
    CONSTANT pid_val     : IN  std_logic_vector(3 DOWNTO 0);
    CONSTANT token_val   : IN STD_LOGIC_VECTOR(10 DOWNTO 0)
  );

  PROCEDURE send_d0(SIGNAL usb : OUT usb_action; CONSTANT wr_data : IN  byte_array);
  PROCEDURE send_D0(SIGNAL usb : OUT usb_action);

  PROCEDURE send_d1(SIGNAL usb : OUT usb_action; CONSTANT wr_data : IN  byte_array);
  PROCEDURE send_D1(SIGNAL usb : OUT usb_action);

  PROCEDURE send_d2(SIGNAL usb : OUT usb_action; CONSTANT wr_data : IN  byte_array);
  PROCEDURE send_D2(SIGNAL usb : OUT usb_action);

  PROCEDURE send_dm(SIGNAL usb : OUT usb_action; CONSTANT wr_data : IN  byte_array);
  PROCEDURE send_Dm(SIGNAL usb : OUT usb_action);

  PROCEDURE send_dx(
    SIGNAL   usb         : OUT usb_action;
    CONSTANT pid_val     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    CONSTANT wr_data     : IN  byte_array
  );
  PROCEDURE send_dx(
    SIGNAL   usb     : OUT usb_action;
    CONSTANT pid_val : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
  );

  PROCEDURE send_RES(SIGNAL usb : OUT usb_action);

  PROCEDURE wait_slv(SIGNAL usb : OUT usb_action);

--==========================================================================================================--
  -- internal functions and procedures --

  FUNCTION to_01x(d : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR;

  FUNCTION hex_to_string(D: STD_LOGIC_VECTOR) RETURN STRING;

  PROCEDURE HexWrite( VARIABLE L        : INOUT LINE;
                      CONSTANT VALUE    : IN    STD_LOGIC_VECTOR;
                      CONSTANT JUSTIFIED: IN    SIDE := right;
                      CONSTANT FIELD    : IN    WIDTH := 0);

  PROCEDURE PrintLine (VARIABLE v_Line : INOUT Line);

  END usb_commands;

--==========================================================================================================--

  PACKAGE BODY usb_commands IS

  FUNCTION to_01x(d : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
    VARIABLE result : STD_LOGIC_VECTOR (d'RANGE);
  BEGIN
    FOR i IN d'RANGE LOOP
      IF d(i) ='0' OR d(i) ='L' THEN    --reduce data to 0, 1 or X
        result(i) := '0';
      ELSIF d(i) ='1' OR d(i) ='H' THEN
        result(i) := '1';
      ELSE
        result(i) := 'X';
      END IF;
    END LOOP;
    RETURN result;
  END to_01x;

--==========================================================================================================--

  FUNCTION hex_to_string(d: STD_LOGIC_VECTOR) RETURN STRING is
    -- vector is padded with leadin '0's if not modula 4 --
    VARIABLE j, k, p : INTEGER;
    VARIABLE d_ext   : STD_LOGIC_VECTOR(1 to ((d'LENGTH +3)/4)*4);
    VARIABLE nibble  : STD_LOGIC_VECTOR(1 to 4);
    VARIABLE result  : STRING(1 TO (d'HIGH +4 - d'LOW)/4);
    VARIABLE hex_val : STRING(1 TO 16) := "0123456789ABCDEF";
    TYPE hex_type IS ARRAY (1 TO 16) OF STD_LOGIC_VECTOR(0 to 3);
    CONSTANT hex_tbl : hex_type :=
      ("0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111",
       "1000", "1001", "1010", "1011", "1100", "1101", "1110", "1111");
  BEGIN
    j := d_ext'LENGTH - d'LENGTH;
    IF j = 0 THEN
      d_ext := to_01x(d);
    ELSE
      d_ext(1 TO j) := (OTHERS =>'0');
      d_ext(j +1 TO d_ext'LENGTH) := to_01x(d);
    END IF;
    j := 1;
    k := 1;
    FOR i IN d_ext'RANGE LOOP
      nibble(j) := d_ext(i);
      IF j = 4 THEN                             --data nibble is ...
        result(k) := 'X';                       -- ... default X ...
        HEX_CHAR: for h in 1 to 16 LOOP
          IF nibble = hex_tbl(h) THEN
            result(k) := hex_val(h);            -- ... or 1 to F
            EXIT HEX_CHAR;
          END IF;
        END LOOP;
        k := k+1;
      END IF;
      j := (j MOD 4) +1;
    END LOOP;
    RETURN result;
  END;

  PROCEDURE HexWrite( VARIABLE L        : INOUT LINE;
                      CONSTANT VALUE    : IN    STD_LOGIC_VECTOR;
                      CONSTANT JUSTIFIED: IN    SIDE := right;
                      CONSTANT FIELD    : IN    WIDTH := 0) IS
  BEGIN
    write (L, STRING'(hex_to_string(VALUE)), JUSTIFIED, FIELD);
  END;

--==========================================================================================================--

  PROCEDURE list(message : IN STRING) IS
    VARIABLE v_Line : line := NULL;
  BEGIN
    WAIT FOR 0 ns;
    write(v_Line, "                 " & Message);
    write(Screen, v_Line.all & LF);
    writeline(OutpData, v_Line);
  END list;

  PROCEDURE list(SIGNAL no_out : OUT NATURAL; no_in : IN NATURAL) IS
    VARIABLE v_Line : line := NULL;
  BEGIN
    IF usb_busy THEN  -- set in usb_monitor
      WAIT UNTIL NOT usb_busy;
    END IF;
    write(v_Line, STRING'("Test_No "), right, 25);
    write(v_Line, no_in);
    PrintLine(v_Line);
    no_out <= no_in;
  END list;

--==========================================================================================================--

  PROCEDURE end_of_test(stop : IN BOOLEAN := TRUE) IS
  BEGIN
    IF usb_busy THEN  -- set in usb_monitor
      WAIT UNTIL NOT usb_busy;
    END IF;
    ASSERT stop = FALSE REPORT"End of Test" SEVERITY FAILURE;
  END end_of_test;

--==========================================================================================================--

  PROCEDURE PrintLine(VARIABLE v_Line : INOUT Line) IS
  BEGIN
    IF v_Line /= NULL THEN
      write(Screen, v_Line.all & LF);
    END IF;
    writeline(OutpData, v_Line);
  END PrintLine;

--==========================================================================================================--

  PROCEDURE send_ACK(SIGNAL usb : OUT usb_action) IS
  BEGIN
    handshake(usb, X"2");
  END send_ACK;

  PROCEDURE send_NAK(SIGNAL usb : OUT usb_action) IS
  BEGIN
    handshake(usb, X"A");
  END send_NAK;

  PROCEDURE send_STALL(SIGNAL usb : OUT usb_action) IS
  BEGIN
    handshake(usb, X"E");
  END send_STALL;

  PROCEDURE send_NYET(SIGNAL usb : OUT usb_action) IS
  BEGIN
    handshake(usb, X"6");
  END send_NYET;

  PROCEDURE handshake(SIGNAL usb : OUT usb_action; CONSTANT pid_val : IN std_logic_vector(3 DOWNTO 0)) IS
  BEGIN
    usb <= sync;
    WAIT UNTIL usb_status = sync;
    WAIT UNTIL usb_status = idle;
    sv_usb_byte := NOT pid_val & pid_val;
    usb <= pid;
    WAIT UNTIL usb_status = pid;
    WAIT UNTIL usb_status = idle;
    usb <= send_eop;
    WAIT UNTIL usb_status = send_eop;
    WAIT UNTIL usb_status = idle;
    usb <= idle;
  END handshake;

--==========================================================================================================--

  PROCEDURE setup(
    SIGNAL usb           : OUT usb_action;
    CONSTANT device_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    CONSTANT endp_addr   : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
  )IS
  BEGIN
    ASSERT device_addr(7) = '0' REPORT" Token device address out of range 0 to 127" SEVERITY FAILURE;
    token(usb, X"D", endp_addr & device_addr(6 DOWNTO 0));
  END setup;

  PROCEDURE in_token(
    SIGNAL usb           : OUT usb_action;
    CONSTANT device_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    CONSTANT endp_addr   : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
  )IS
  BEGIN
    ASSERT device_addr(7) = '0' REPORT" Token device address out of range 0 to 127" SEVERITY FAILURE;
    token(usb, X"9", endp_addr & device_addr(6 DOWNTO 0));
  END in_token;

  PROCEDURE out_token(
    SIGNAL usb           : OUT usb_action;
    CONSTANT device_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    CONSTANT endp_addr   : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
  )IS
  BEGIN
    ASSERT device_addr(7) = '0' REPORT" Token device address out of range 0 to 127" SEVERITY FAILURE;
    token(usb, X"1", endp_addr & device_addr(6 DOWNTO 0));
  END out_token;

  PROCEDURE sof_token(
    SIGNAL usb           : OUT usb_action;
    CONSTANT frame_no    : IN STD_LOGIC_VECTOR(11 DOWNTO 0)
  )IS
  BEGIN
    token(usb, X"5", frame_no(10  DOWNTO 0));
  END sof_token;

  PROCEDURE token(
    SIGNAL   usb         : OUT usb_action;
    CONSTANT pid_val     : IN  std_logic_vector(3 DOWNTO 0);
    CONSTANT token_val   : IN STD_LOGIC_VECTOR(10 DOWNTO 0)
  )IS
  BEGIN
    usb <= sync;
    WAIT UNTIL usb_status = sync;
    WAIT UNTIL usb_status = idle;
    sv_usb_byte := NOT pid_val & pid_val;
    usb <= pid;
    WAIT UNTIL usb_status = pid;
    WAIT UNTIL usb_status = idle;
    sv_usb_addr := token_val;
    usb <= addr;
    WAIT UNTIL usb_status = addr;
    WAIT UNTIL usb_status = idle;
    usb <= wr_crc5;
    WAIT UNTIL usb_status = wr_crc5;
    WAIT UNTIL usb_status = idle;
    usb <= send_eop;
    WAIT UNTIL usb_status = send_eop;
    WAIT UNTIL usb_status = idle;
    usb <= idle;
  END token;

----==========================================================================================================--

  PROCEDURE send_D0(SIGNAL usb : OUT usb_action; CONSTANT wr_data : IN  byte_array) IS
  BEGIN
    send_dx(usb, X"3", wr_data);
  END send_D0;

  PROCEDURE send_D1(SIGNAL usb : OUT usb_action; CONSTANT wr_data : IN  byte_array) IS
  BEGIN
    send_dx(usb, X"B", wr_data);
  END send_D1;

  PROCEDURE send_D2(SIGNAL usb : OUT usb_action; CONSTANT wr_data : IN  byte_array) IS
  BEGIN
    send_dx(usb, X"7", wr_data);
  END send_D2;

  PROCEDURE send_Dm(SIGNAL usb : OUT usb_action; CONSTANT wr_data : IN  byte_array) IS
  BEGIN
    send_dx(usb, X"F", wr_data);
  END send_Dm;

  PROCEDURE send_dx(
    SIGNAL   usb     : OUT usb_action;
    CONSTANT pid_val : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    CONSTANT wr_data : IN  byte_array
  )IS
  BEGIN
    usb <= sync;
    WAIT UNTIL usb_status = sync;
    WAIT UNTIL usb_status = idle;
    sv_usb_byte := NOT pid_val & pid_val;
    usb <= pid;
    WAIT UNTIL usb_status = pid;
    WAIT UNTIL usb_status = idle;
    FOR i in 0 TO wr_data'LENGTH -1 LOOP
      sv_usb_byte := wr_data(i);
      IF i MOD 2 = 0 THEN
        usb <= wr_even;
        WAIT UNTIL usb_status = wr_even;
      ELSE
        usb <= wr_odd;
        WAIT UNTIL usb_status = wr_odd;
      END IF;
      WAIT UNTIL usb_status = idle;
    END LOOP;
    usb <= wr_crc16;
    WAIT UNTIL usb_status = wr_crc16;
    WAIT UNTIL usb_status = idle;
    usb <= send_eop;
    WAIT UNTIL usb_status = send_eop;
    WAIT UNTIL usb_status = idle;
    usb <= idle;
  END send_dx;

----==========================================================================================================--

  PROCEDURE send_D0(SIGNAL usb : OUT usb_action) IS
  BEGIN
    send_dx(usb, X"3");
  END send_D0;

  PROCEDURE send_D1(SIGNAL usb : OUT usb_action) IS
  BEGIN
    send_dx(usb, X"B");
  END send_D1;

  PROCEDURE send_D2(SIGNAL usb : OUT usb_action) IS
  BEGIN
    send_dx(usb, X"7");
  END send_D2;

  PROCEDURE send_Dm(SIGNAL usb : OUT usb_action) IS
  BEGIN
    send_dx(usb, X"F");
  END send_Dm;

  PROCEDURE send_dx(
    SIGNAL   usb     : OUT usb_action;
    CONSTANT pid_val : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
  )IS
  BEGIN
    usb <= sync;
    WAIT UNTIL usb_status = sync;
    WAIT UNTIL usb_status = idle;
    sv_usb_byte := NOT pid_val & pid_val;
    usb <= pid;
    WAIT UNTIL usb_status = pid;
    WAIT UNTIL usb_status = idle;
    usb <= wr_crc16;
    WAIT UNTIL usb_status = wr_crc16;
    WAIT UNTIL usb_status = idle;
    usb <= send_eop;
    WAIT UNTIL usb_status = send_eop;
    WAIT UNTIL usb_status = idle;
    usb <= idle;
  END send_dx;

----==========================================================================================================--

  PROCEDURE send_RES(SIGNAL usb : OUT usb_action) IS
  BEGIN
    usb <= reset;
    WAIT UNTIL usb_status = reset;
    WAIT UNTIL usb_status = idle;
    usb <= idle;
  END send_RES;

----==========================================================================================================--

  PROCEDURE wait_slv(SIGNAL usb : OUT usb_action) IS
  BEGIN
    usb <= recv_eop;
    WAIT UNTIL usb_status = recv_eop;
    WAIT UNTIL usb_status = idle;
    usb <= idle;
  END wait_slv;

----==========================================================================================================--
END usb_commands;
