--
--    opb_usblite - opb_uartlite replacement
--
--    opb_usblite is using components from Rudolf Usselmann see
--    http://www.opencores.org/cores/usb_phy/
--    and Joris van Rantwijk see http://www.xs4all.nl/~rjoris/fpga/usb.html
--
--    Copyright (C) 2010 Ake Rehnman
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU Lesser General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU Lesser General Public License for more details.
--
--    You should have received a copy of the GNU Lesser General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;


entity tb_USBLITE_Core is
end entity tb_USBLITE_Core;

library unisim;
use unisim.all;

architecture akre of tb_USBLITE_Core is

  component usb_phy is
    port (
      clk : in std_logic;
      rst : in std_logic;
      phy_tx_mode : in std_logic;
      usb_rst : out std_logic;
	
		-- Transciever Interface
		  txdp : out std_logic;
		  txdn : out std_logic;
		  txoe : out std_logic;
		  rxd : in std_logic;
		  rxdp : in std_logic;
		  rxdn : in std_logic;

		-- UTMI Interface
		  DataOut_i : in std_logic_vector (7 downto 0);
		  TxValid_i : in std_logic;
		  TxReady_o : out std_logic;
		  RxValid_o : out std_logic;
		  RxActive_o : out std_logic;
		  RxError_o : out std_logic;
		  DataIn_o : out std_logic_vector (7 downto 0);
		  LineState_o : out std_logic_vector (1 downto 0)
    );
  end component usb_phy;
  
  component OPB_USBLITE_Core is
  generic (
    C_PHYMODE :       std_logic := '1';
    C_VENDORID :      std_logic_vector(15 downto 0) := X"1234";
    C_PRODUCTID :     std_logic_vector(15 downto 0) := X"5678";
    C_VERSIONBCD :    std_logic_vector(15 downto 0) := X"0200";
    C_SELFPOWERED :   boolean := false;
    C_RXBUFSIZE_BITS: integer range 7 to 12 := 10;
    C_TXBUFSIZE_BITS: integer range 7 to 12 := 10 
    );
  port (
    Clk   : in std_logic;
    Reset : in std_logic;
    Usb_Clk : in std_logic;
    -- OPB signals
    OPB_CS : in std_logic;
    OPB_ABus : in std_logic_vector(0 to 1);
    OPB_RNW  : in std_logic;
    OPB_DBus : in std_logic_vector(7 downto 0);
    SIn_xferAck : out std_logic;
    SIn_DBus    : out std_logic_vector(7 downto 0);
    Interrupt : out std_logic;
    -- USB signals
		txdp : out std_logic;
		txdn : out std_logic;
		txoe : out std_logic;
		rxd : in std_logic;
		rxdp : in std_logic;
		rxdn : in std_logic
  );
  end component OPB_USBLITE_Core;
      
  signal clk : std_logic;
  signal usbclk : std_logic;
  signal reset : std_logic;
  signal rxdp : std_logic;
  signal rxdn : std_logic;
  signal rxd : std_logic;
  signal txdp : std_logic;
  signal txdn : std_logic;
  signal txoe : std_logic;

  signal usbtxdata : std_logic_vector (7 downto 0);
  signal usbtxvalid : std_logic;
  signal usbtxready : std_logic;
  signal usbrxvalid : std_logic;
  signal usbrxactive : std_logic;
  signal usbrxerror : std_logic;
  signal usbrxdata : std_logic_vector (7 downto 0);
  signal usblinestate : std_logic_vector (1 downto 0);
  
  signal Bus2IP_CS : std_logic := '0';
  signal Bus2IP_CE : std_logic := '0';
  signal Bus2IP_Addr : std_logic_vector(0 to 31) := X"00000000";
  signal Bus2IP_RNW : std_logic := '0';
  signal Bus2IP_Data : std_logic_vector(0 to 31);
  signal Bus2IP_BE : std_logic_vector(3 downto 0) := "0000";
  signal IP2Bus_Ack : std_logic := '0';
  signal IP2Bus_Data : std_logic_vector(0 to 31) := X"00000000";
  signal Interrupt : std_logic := '0';
  
  signal resetn : std_logic;
  signal usbrxdata_r : std_logic_vector(7 downto 0);
  
--  type txmemarray is array (0 to 2048) of std_logic_vector(7 downto 0);
  type txmemarray is array (0 to 255) of std_logic_vector(7 downto 0);
  shared variable txmem : txmemarray;
  
--  type bufferarray is array (0 to 16384) of std_logic_vector(7 downto 0);
  type bufferarray is array (0 to 255) of std_logic_vector(7 downto 0);
  shared variable buffer1 : bufferarray;
  shared variable buffer0 : bufferarray;
  shared variable buffer1_last : integer;
  shared variable len : integer;
  shared variable setup_pid : std_logic;
  shared variable error_cnt : integer;

  constant USBF_T_PID_OUT : std_logic_vector(3 downto 0):="0001";
  constant USBF_T_PID_IN : std_logic_vector(3 downto 0):="1001";
  constant USBF_T_PID_SOF : std_logic_vector(3 downto 0):="0101";
  constant USBF_T_PID_SETUP : std_logic_vector(3 downto 0):="1101";
  constant USBF_T_PID_DATA0 : std_logic_vector(3 downto 0):="0011";
  constant USBF_T_PID_DATA1 : std_logic_vector(3 downto 0):="1011";
  constant USBF_T_PID_DATA2 : std_logic_vector(3 downto 0):="0111";
  constant USBF_T_PID_MDATA : std_logic_vector(3 downto 0):="1111";
  constant USBF_T_PID_ACK : std_logic_vector(3 downto 0):="0010";
  constant USBF_T_PID_NACK : std_logic_vector(3 downto 0):="1010";
  constant USBF_T_PID_STALL : std_logic_vector(3 downto 0):="1110";
  constant USBF_T_PID_NYET : std_logic_vector(3 downto 0):="0110";
  constant USBF_T_PID_PRE : std_logic_vector(3 downto 0):="1100";
  constant USBF_T_PID_ERR : std_logic_vector(3 downto 0):="1100";
  constant USBF_T_PID_SPLIT : std_logic_vector(3 downto 0):="1000";
  constant USBF_T_PID_PING : std_logic_vector(3 downto 0):="0100";
  constant USBF_T_PID_RES : std_logic_vector(3 downto 0):="0000";
  
  constant  GET_STATUS : std_logic_vector(7 downto 0) :=	X"00";
	constant	CLEAR_FEATURE	: std_logic_vector(7 downto 0) :=	X"01";
	constant	SET_FEATURE	: std_logic_vector(7 downto 0) :=	X"03";
	constant	SET_ADDRESS	: std_logic_vector(7 downto 0) :=	X"05";
	constant	GET_DESCRIPTOR	: std_logic_vector(7 downto 0) :=	X"06";
	constant	SET_DESCRIPTOR	: std_logic_vector(7 downto 0) :=	X"07";
	constant	GET_CONFIG	: std_logic_vector(7 downto 0) :=	X"08";
	constant	SET_CONFIG	: std_logic_vector(7 downto 0) :=	X"09";
	constant	GET_INTERFACE	: std_logic_vector(7 downto 0) :=	X"0a";
	constant	SET_INTERFACE	: std_logic_vector(7 downto 0) :=	X"0b";
	constant	SYNCH_FRAME	: std_logic_vector(7 downto 0) :=	X"0c";
	
  procedure utmi_recv_pack (variable size : inout integer) is
  begin
    size := 0;
    while (usbrxactive /= '1') loop
      wait until rising_edge(usbclk);
    end loop;
    while (usbrxactive= '1') loop
    	while (usbrxvalid /= '1' and usbrxactive = '1') loop
	      wait until rising_edge(usbclk);
    	end loop; 
	    if (usbrxvalid = '1' and usbrxactive = '1') then
			  txmem(size) := usbrxdata;
			  size := size + 1;
	    end if;
	    wait until rising_edge(usbclk);
    end loop;
  end procedure utmi_recv_pack;
  
  procedure utmi_send_pack (constant size : integer; signal usbtxdata: out std_logic_vector; signal usbtxvalid: out std_logic) is
    variable n : integer;
  begin
    for n in 0 to size-1 loop
      wait until rising_edge(usbclk);
	    usbtxvalid <= '1';
      usbtxdata <= txmem(n);
      while (usbtxready/='1') loop
        wait until rising_edge(usbclk);
      end loop;
    end loop;
    wait until rising_edge(usbclk);
    usbtxvalid <= '0';
  end procedure utmi_send_pack;
  
  function crc5 (crc_in:std_logic_vector; din:std_logic_vector) return std_logic_vector is
    variable crc5x : std_logic_vector (4 downto 0);
  begin
    crc5x(0) :=	din(10) xor din(9) xor din(6) xor din(5) xor din(3) xor din(0) xor crc_in(0) xor crc_in(3) xor crc_in(4);
    crc5x(1) :=	din(10) xor din(7) xor din(6) xor din(4) xor din(1) xor	crc_in(0) xor crc_in(1) xor crc_in(4);
    crc5x(2) :=	din(10) xor din(9) xor din(8) xor din(7) xor din(6) xor	din(3) xor din(2) xor din(0) xor crc_in(0) xor crc_in(1) xor crc_in(2) xor crc_in(3) xor crc_in(4);
    crc5x(3) :=	din(10) xor din(9) xor din(8) xor din(7) xor din(4) xor din(3) xor din(1) xor crc_in(1) xor crc_in(2) xor crc_in(3) xor crc_in(4);
    crc5x(4) :=	din(10) xor din(9) xor din(8) xor din(5) xor din(4) xor din(2) xor crc_in(2) xor crc_in(3) xor crc_in(4);
    return crc5x;
  end function crc5;
  
  function crc16 (crc_in: std_logic_vector; din:std_logic_vector) return std_logic_vector is
    variable crc_out : std_logic_vector (15 downto 0);
  begin
		crc_out(0) :=	din(7) xor din(6) xor din(5) xor din(4) xor din(3) xor
		din(2) xor din(1) xor din(0) xor crc_in(8) xor crc_in(9) xor
		crc_in(10) xor crc_in(11) xor crc_in(12) xor crc_in(13) xor
		crc_in(14) xor crc_in(15);
		crc_out(1) :=	din(7) xor din(6) xor din(5) xor din(4) xor din(3) xor din(2) xor
		din(1) xor crc_in(9) xor crc_in(10) xor crc_in(11) xor
		crc_in(12) xor crc_in(13) xor crc_in(14) xor crc_in(15);
		crc_out(2) :=	din(1) xor din(0) xor crc_in(8) xor crc_in(9);
		crc_out(3) :=	din(2) xor din(1) xor crc_in(9) xor crc_in(10);
		crc_out(4) :=	din(3) xor din(2) xor crc_in(10) xor crc_in(11);
		crc_out(5) :=	din(4) xor din(3) xor crc_in(11) xor crc_in(12);
		crc_out(6) :=	din(5) xor din(4) xor crc_in(12) xor crc_in(13);
		crc_out(7) :=	din(6) xor din(5) xor crc_in(13) xor crc_in(14);
		crc_out(8) :=	din(7) xor din(6) xor crc_in(0) xor crc_in(14) xor crc_in(15);
		crc_out(9) :=	din(7) xor crc_in(1) xor crc_in(15);
		crc_out(10) :=	crc_in(2);
		crc_out(11) :=	crc_in(3);
		crc_out(12) :=	crc_in(4);
		crc_out(13) :=	crc_in(5);
		crc_out(14) :=	crc_in(6);
		crc_out(15) :=	din(7) xor din(6) xor din(5) xor din(4) xor din(3) xor din(2) xor
		din(1) xor din(0) xor crc_in(7) xor crc_in(8) xor crc_in(9) xor
		crc_in(10) xor crc_in(11) xor crc_in(12) xor crc_in(13) xor
		crc_in(14) xor crc_in(15);
		return crc_out;
	end function crc16;

	procedure recv_packet(variable pid: inout std_logic_vector(3 downto 0); variable size: inout integer) is
    variable del,n : integer;
    variable crc16r : std_logic_vector(15 downto 0);
    variable x,y : std_logic_vector(7 downto 0);
    variable s : LINE;
	begin
	  crc16r := X"ffff";
    utmi_recv_pack(size);
    for n in 1 to size-3 loop
    	y := txmem(n);
	    x(7) := y(0);
	    x(6) := y(1);
	    x(5) := y(2);
	    x(4) := y(3);
	    x(3) := y(4);
	    x(2) := y(5);
	    x(1) := y(6);
	    x(0) := y(7);
	    crc16r := crc16(crc16r, x);
    end loop;
    n := size-2;

    y := crc16r(15 downto 8); 
    x(7) := y(0);
    x(6) := y(1);
    x(5) := y(2);
    x(4) := y(3);
    x(3) := y(4);
    x(2) := y(5);
    x(1) := y(6);
    x(0) := y(7);
    crc16r(15 downto 8) := not(x);

    y := crc16r(7 downto 0);
    x(7) := y(0);
    x(6) := y(1);
    x(5) := y(2);
    x(4) := y(3);
    x(3) := y(4);
    x(2) := y(5);
    x(1) := y(6);
    x(0) := y(7);
    crc16r(7 downto 0) := not(x);

    if (crc16r /= txmem(n)&txmem(n+1)) then
      --$display("ERROR: CRC Mismatch: Expected: %h, Got: %h%h (%t)",crc16r, txmem[n], txmem[n+1], $time);
      WRITE(s,string'("ERROR: CRC Mismatch got:"));
      HWRITE(s,crc16r);
      WRITE(s,string'(" expected:"));
      HWRITE(s,txmem(n)&txmem(n+1));
      report s.all;
    end if;

    for n in 0 to size-3 loop
	    buffer1(buffer1_last+n) := txmem(n+1);
	  end loop;
    n := size-3;

    buffer1_last := buffer1_last+n;

    -- Check PID
    x := txmem(0);

    if (x(7 downto 4) /= not(x(3 downto 0))) then
      --$display("ERROR: Pid Checksum mismatch: Top: %h Bottom: %h (%t)",x[7:4], x[3:0], $time);
      WRITE(s,string'("ERROR: Pid Checksum mismatch: Top: "));
      HWRITE(s,x(7 downto 4));
      WRITE(s,string'(" Bottom:"));
      HWRITE(s,x(3 downto 0));
      report s.all;
    end if;

    pid := x(3 downto 0);
    size:= size-3;

  end procedure recv_packet;
  
  procedure send_token (constant fa:std_logic_vector(7 downto 0); constant ep:std_logic_vector(3 downto 0); constant pid:std_logic_vector(3 downto 0)) is
    variable tmp_data:std_logic_vector(15 downto 0);
    variable x,y:std_logic_vector(10 downto 0);
    variable len:integer;
  begin
    tmp_data := fa(6 downto 0)&ep&"00000";
    if (pid=USBF_T_PID_ACK)	then
      len := 1;
    else
    	len := 3;  
    end if;
    y := fa(6 downto 0)&ep;
    x(10) := y(4);
    x(9) := y(5);
    x(8) := y(6);
    x(7) := y(7);
    x(6) := y(8);
    x(5) := y(9);
    x(4) := y(10);
    x(3) := y(0);
    x(2) := y(1);
    x(1) := y(2);
    x(0) := y(3);
    y(4 downto 0)  := crc5("11111", x);
    tmp_data(4 downto 0)  := not(y(4 downto 0));
    tmp_data(15 downto 5) := x;
    txmem(0) := (not(pid)&pid);	-- PID
    txmem(1) := (	tmp_data(8)&tmp_data(9)&tmp_data(10)&tmp_data(11)&tmp_data(12)&tmp_data(13)&tmp_data(14)&tmp_data(15));
    txmem(2) := (	tmp_data(0)&tmp_data(1)&tmp_data(2)&tmp_data(3)&tmp_data(4)&tmp_data(5)&tmp_data(6)&tmp_data(7));
    utmi_send_pack(len,usbtxdata,usbtxvalid);
  end procedure send_token;

  procedure send_data (constant pid:std_logic_vector(3 downto 0); constant len:integer; constant mode:integer) is
    variable n : integer;
    variable crc16r : std_logic_vector(15 downto 0);
    variable x,y : std_logic_vector(7 downto 0);
  begin
    txmem(0) := not(pid)&pid;	-- PID
    crc16r := X"ffff";
    for n in 0 to len-1 loop
	    if(mode=1)	then
	      y := buffer1(buffer1_last+n);
	    else
	      y := std_logic_vector(to_unsigned(n,8));
	    end if;
	  
--	    x(7 downto 0) := y(0 to 7);
	    x(7) := y(0);
	    x(6) := y(1);
	    x(5) := y(2);
	    x(4) := y(3);
	    x(3) := y(4);
	    x(2) := y(5);
	    x(1) := y(6);
	    x(0) := y(7);
	    txmem(n+1) := y;
	    crc16r := crc16(crc16r, x);
    end loop;
    
    buffer1_last := buffer1_last + len - 1;
    y := crc16r(15 downto 8);
--    x(7 downto 0) := y(0 to 7);
    x(7) := y(0);
    x(6) := y(1);
    x(5) := y(2);
    x(4) := y(3);
    x(3) := y(4);
    x(2) := y(5);
    x(1) := y(6);
    x(0) := y(7);
    txmem(len+1) := not(x);

    y := crc16r(7 downto 0);
--    x(7 downto 0) := y(0 to 7);
    x(7) := y(0);
    x(6) := y(1);
    x(5) := y(2);
    x(4) := y(3);
    x(3) := y(4);
    x(2) := y(5);
    x(1) := y(6);
    x(0) := y(7);
    txmem(len+2) := not(x);

    utmi_send_pack(len+3,usbtxdata,usbtxvalid);
  end procedure send_data;

  procedure data_in (constant fa:std_logic_vector(7 downto 0); constant pl_size:integer) is
    variable rlen : integer;
    variable pid : std_logic_vector(3 downto 0);
    variable expected_pid : std_logic_vector(3 downto 0);
    variable s : LINE;
  begin
	  buffer1_last := 0;
		send_token(	fa,		    -- Function Address
			X"00",		-- Logical Endpoint Number
			USBF_T_PID_IN	-- PID
		);
	  recv_packet(pid,rlen);
	  if (setup_pid='1') then
	    expected_pid := X"b"; -- DATA 1
	  else
	    expected_pid := X"3";  -- DATA 0
    end if;
	  if (pid /= expected_pid) then
  		--$display("ERROR: Data IN PID mismatch. Expected: %h, Got: %h (%t)",		expect_pid, pid, $time);
  		report "ERROR: Data IN PID mismatch.";
   	  error_cnt := error_cnt + 1;
	  end if;

	  setup_pid := not(setup_pid);
	  if (rlen /= pl_size) then
	    report "ERROR: Data IN Size mismatch.";
			--$display("ERROR: Data IN Size mismatch. Expected: %d, Got: %d (%t)",		pl_size, rlen, $time);
		  error_cnt := error_cnt + 1;
	  end if;

    DEALLOCATE(s);
    WRITE(s,string'("RCV bytes: "));
    WRITE(s,rlen);
    report s.all;
	  for n in 0 to rlen-1 loop
--		  $display("RCV Data[%0d]: %h",n,buffer1[n]);
      DEALLOCATE(s);
      WRITE(s,string'("RCV Data["));
      WRITE(s,n);
      WRITE(s,string'("]="));
      HWRITE(s,buffer1(n));
      report s.all;
		end loop;
		
--	  repeat(5)	@(posedge clk);
    wait for 1 us;

	  send_token(	fa,		-- Function Address
			X"00",		      -- Logical Endpoint Number
			USBF_T_PID_ACK	-- PID
		);

--	  repeat(5)	@(posedge clk);
    wait for 1 us;
  end procedure data_in;  
  
  procedure data_out(fa:std_logic_vector(7 downto 0); pl_size:integer) is
    variable len : integer;
  begin
	  send_token(	fa,		-- Function Address
			X"00",          -- Logical Endpoint Number
			USBF_T_PID_OUT	-- PID
			);
    wait until rising_edge(usbclk);

	  if (setup_pid='0') then
	  	send_data(USBF_T_PID_DATA0, pl_size, 1);
	  else
	    send_data(USBF_T_PID_DATA1, pl_size, 1);
    end if;
	
	  setup_pid := not(setup_pid);

	  -- Wait for ACK
	  
	  utmi_recv_pack(len);

	  if(txmem(0) /= X"d2") then
			--$display("ERROR: ACK mismatch. Expected: %h, Got: %h (%t)",8'hd2, txmem[0], $time);
      report "ERROR: SETUP: ACK mismatch";
		  error_cnt := error_cnt + 1;
	  end if;

	  if(len /= 1) then
		  --$display("ERROR: SETUP: Length mismatch. Expected: %h, Got: %h (%t)",8'h1, len, $time);
      report "ERROR: SETUP: Length mismatch";
		  error_cnt := error_cnt + 1;
	  end if;
	  
		-- repeat(5)	@(posedge clk);
	  wait for 1 us;
  end procedure data_out;  

  procedure send_setup (constant fa:std_logic_vector(7 downto 0);
                        constant req_type:std_logic_vector(7 downto 0);
                        constant request:std_logic_vector(7 downto 0);
                        constant wValue:std_logic_vector(15 downto 0);
                        constant wIndex:std_logic_vector(15 downto 0);
                        constant wLength:std_logic_vector(15 downto 0)) is
  begin
    send_token(fa,X"0",USBF_T_PID_SETUP);
    wait for 1 us;
    buffer1(0) := req_type;
    buffer1(1) := request;
    buffer1(3) := wValue(15 downto 8);
    buffer1(2) := wValue(7 downto 0);
    buffer1(5) := wIndex(15 downto 8);
    buffer1(4) := wIndex(7 downto 0);
    buffer1(7) := wLength(15 downto 8);
    buffer1(6) := wLength(7 downto 0);
    buffer1_last := 0;
    send_data(USBF_T_PID_DATA0, 8, 1);
    utmi_recv_pack(len);
    if (txmem(0) /= x"d2") then
      --$display("ERROR: SETUP: ACK mismatch. Expected: %h, Got: %h (%t)",	8'hd2, txmem[0], $time);
      report "ERROR: SETUP: ACK mismatch";
      error_cnt := error_cnt + 1;      
    end if;
    if (len /= 1) then
	    --$display("ERROR: SETUP: Length mismatch. Expected: %h, Got: %h (%t)", 8'h1, len, $time);    
      report "ERROR: SETUP: Length mismatch. len="&integer'image(len);
      error_cnt := error_cnt + 1;      
    end if;  
    
    wait until rising_edge(usbclk);
    setup_pid := '1';
    wait until rising_edge(usbclk);
    
  end procedure send_setup;
  
  procedure send_sof(constant frmn:integer) is
    variable frmnv : std_logic_vector(10 downto 0);
    variable tmp_data : std_logic_vector(15 downto 0);
    variable x,y : std_logic_vector(10 downto 0);
  begin
    frmnv := std_logic_vector(to_unsigned(frmn,11));
    y := frmnv;
		x(10) := y(0);
		x(9) := y(1);
		x(8) := y(2);
		x(7) := y(3);
		x(6) := y(4);
		x(5) := y(5);
		x(4) := y(6);
		x(3) := y(7);
		x(2) := y(8);
		x(1) := y(9);
		x(0) := y(10);

		tmp_data(15 downto 5) := x;
		y(4 downto 0)  := crc5( X"1F", x );
		tmp_data(4 downto 0)  := not(y(4 downto 0));
		txmem(0) := not(USBF_T_PID_SOF)&USBF_T_PID_SOF;	-- PID
    txmem(1) :=  	tmp_data(8)&tmp_data(9)&tmp_data(10)&tmp_data(11)&
                  tmp_data(12)&tmp_data(13)&tmp_data(14)&tmp_data(15);
    txmem(2) :=  	tmp_data(0)&tmp_data(1)&tmp_data(2)&tmp_data(3)&
		              tmp_data(4)&tmp_data(5)&tmp_data(6)&tmp_data(7);
    txmem(1) := 	frmnv(7 downto 0);
    txmem(2) :=  	tmp_data(0)&tmp_data(1)&tmp_data(2)&tmp_data(3)&
		              tmp_data(4)& frmnv(10 downto 8);
    utmi_send_pack(3,usbtxdata,usbtxvalid);
  end procedure send_sof;
  

  procedure buswrite(constant adr : in std_logic_vector(31 downto 0);
                     constant data : in std_logic_vector(31 downto 0);
                     signal Bus2IP_Clk : in std_logic;
                     signal Bus2IP_Addr : out std_logic_vector(0 to 31);
                     signal Bus2IP_Data : out std_logic_vector(0 to 31);
                     signal Bus2IP_BE : out std_logic_vector(0 to 3);
                     signal Bus2IP_CS : out std_logic;
                     signal Bus2IP_CE : out std_logic;
                     signal Bus2IP_RNW : out std_logic;
                     signal IP2Bus_Data : in std_logic_vector(0 to 31);                     
                     signal IP2Bus_Ack : in std_logic) is
  begin  	
  	wait until (Bus2IP_Clk='1' and Bus2IP_Clk'event);
  	wait for 1 ns;
  	Bus2IP_Addr <= adr;
  	Bus2IP_Data <= data;
  	Bus2IP_RNW <= '0';
  	Bus2IP_CE <= '1';
  	Bus2IP_CS <= '1';
  	Bus2IP_BE <= "1111";
  	wait until (Bus2IP_Clk'event and Bus2IP_Clk='1' and IP2Bus_Ack='1');
  	wait for 1 ns;
  	Bus2IP_Addr <= (others=>'0');
  	Bus2IP_Data <= (others=>'0');
  	Bus2IP_RNW <= '0';
  	Bus2IP_CE <= '0';  	
  	Bus2IP_CS <= '0';
  	Bus2IP_BE <= "0000";
  end buswrite; 

  procedure busread (constant adr : in std_logic_vector(31 downto 0);
                     variable data : out std_logic_vector(31 downto 0);
                     signal Bus2IP_Clk : in std_logic;
                     signal Bus2IP_Addr : out std_logic_vector(0 to 31);
                     signal Bus2IP_Data : out std_logic_vector(0 to 31);
                     signal Bus2IP_BE : out std_logic_vector(0 to 3);
                     signal Bus2IP_CS : out std_logic;
                     signal Bus2IP_CE : out std_logic;
                     signal Bus2IP_RNW : out std_logic;
                     signal IP2Bus_Data : in std_logic_vector(0 to 31);
                     signal IP2Bus_Ack : in std_logic) is
  begin  	
  	wait until (Bus2IP_Clk='1' and Bus2IP_Clk'event);
  	wait for 1 ns;
  	Bus2IP_Addr <= adr;
  	Bus2IP_Data <= (others=>'0');
  	Bus2IP_RNW <= '1';
  	Bus2IP_CS <= '1';
  	Bus2IP_CE <= '1';
  	Bus2IP_BE <= "1111";
  	wait until (Bus2IP_Clk'event and Bus2IP_Clk='1' and IP2Bus_Ack='1');
  	data := IP2Bus_Data;
  	wait for 1 ns;
  	Bus2IP_Addr <= (others=>'0');
  	Bus2IP_Data <= (others=>'0');
  	Bus2IP_RNW <= '0';
  	Bus2IP_CS <= '0';  	
  	Bus2IP_CE <= '0';  	
  	Bus2IP_BE <= "0000";
  end busread; 
  
  procedure uartread (variable d : out std_logic_vector (7 downto 0)) is
    variable tmp : std_logic_vector(31 downto 0);
--    variable ss : LINE;    
  begin
    loop
       busread(X"00000002", tmp, clk, Bus2IP_Addr, Bus2IP_Data, Bus2IP_BE, Bus2IP_CS, Bus2IP_CE, Bus2IP_RNW, IP2Bus_Data, IP2Bus_Ack);
       exit when ((tmp and X"00000001") /= X"00000000");
    end loop;
--      DEALLOCATE(ss);
--      WRITE(ss,string'("uartstatus="));
--      HWRITE(ss,tmp);
--      report ss.all;    
    busread(X"00000000", tmp, clk, Bus2IP_Addr, Bus2IP_Data, Bus2IP_BE, Bus2IP_CS, Bus2IP_CE, Bus2IP_RNW, IP2Bus_Data, IP2Bus_Ack);
    d := tmp(7 downto 0);
  end procedure uartread;
  
  procedure uartwrite (variable d : std_logic_vector (7 downto 0)) is
    variable tmp : std_logic_vector(31 downto 0);
  begin
    loop
       busread(X"00000002", tmp, clk, Bus2IP_Addr, Bus2IP_Data, Bus2IP_BE, Bus2IP_CS, Bus2IP_CE, Bus2IP_RNW, IP2Bus_Data, IP2Bus_Ack);
       exit when ((tmp and X"00000004") /= X"00000000");
    end loop;
    tmp := X"00000000";
    tmp(7 downto 0) := d;    
    buswrite(X"00000001", tmp, clk, Bus2IP_Addr, Bus2IP_Data, Bus2IP_BE, Bus2IP_CS, Bus2IP_CE, Bus2IP_RNW, IP2Bus_Data, IP2Bus_Ack);
  
  end procedure uartwrite;

  shared variable nn : integer;
  shared variable pid : std_logic_vector(3 downto 0); 
  shared variable ss : LINE;
  shared variable dd : std_logic_vector(7 downto 0);
  shared variable rlen : integer;
begin

    
  resetn <= not(reset);
  rxd <= rxdp;

  usb_phy_inst : usb_phy
      port map (
      clk => usbclk,
      rst => resetn,
      phy_tx_mode => '1',
      usb_rst => open,
		  txdp => rxdp,
		  txdn => rxdn,
		  txoe => open,
		  rxd => txdp,
		  rxdp => txdp,
		  rxdn => txdn,

		-- UTMI Interface
		  DataOut_i => usbtxdata,
		  TxValid_i => usbtxvalid,
		  TxReady_o => usbtxready,
		  RxValid_o => usbrxvalid,
		  RxActive_o => usbrxactive,
		  RxError_o => usbrxerror,
		  DataIn_o => usbrxdata,
		  LineState_o => usblinestate
    );


  OPB_USBLITE_Core_inst : OPB_USBLITE_Core
  port map (
    Clk   => clk,
    Reset => reset,
    Usb_Clk => usbclk,
    OPB_CS => Bus2IP_CS,
    OPB_ABus => Bus2IP_Addr(30 to 31),
    OPB_RNW  => Bus2IP_RNW,
    OPB_DBus => Bus2IP_Data(24 to 31),
    SIn_xferAck => IP2Bus_Ack,
    SIn_DBus => IP2Bus_Data(24 to 31),
    Interrupt => Interrupt,
		txdp => txdp,
		txdn => txdn,
		txoe => txoe,
		rxd => rxd,
		rxdp => rxdp,
		rxdn => rxdn
  );
  

  process
  begin
    clk <= '0';
    wait for 6.66666ns;
    clk <= '1';
    wait for 6.66666ns;
  end process;

  process
  begin
    usbclk <= '0';
    wait for 10.41666ns;
    usbclk <= '1';
    wait for 10.41666ns;
  end process;
  
  process(usbclk)
  begin
    if (usbclk'event and usbclk='1') then
      if (usbrxvalid='1') then
        usbrxdata_r <= usbrxdata;
      end if;
    end if;
  end process;
  
  process
  begin
    wait for 100ns;
    reset <= '1';
    wait for 100ns;
    reset <= '0';
    wait for 100 us;

 report "Setting Address ...";
    wait for 1 us;
    send_setup(	X"00", 		-- Function Address
		X"00",		            -- Request Type
		SET_ADDRESS,	        -- Request
		X"0012",	            -- wValue
		X"0000",		          -- wIndex
		X"0000"		            -- wLength
		);

-- Status OK		
		data_in(	X"00",		-- Function Address
		0		                -- Expected payload size
	  );

 report("Getting DEVICE descriptor ...");
    send_setup(	X"12", 		-- Function Address
		X"80",		            -- Request Type
		GET_DESCRIPTOR,	      -- Request
		X"0100",	            -- wValue
		X"0000",	            -- wIndex
		X"0008"		            -- wLength
		);

    data_in(	X"12",		-- Function Address
		8		                -- Expected payload size
		);

-- Status OK
    data_out(	X"12",		-- Function Address
		0   		            -- Expected payload size
	  );

 report("Getting whole DEVICE descriptor ...");
    send_setup(	X"12", 		-- Function Address
		X"80",		            -- Request Type
		GET_DESCRIPTOR,	      -- Request
		X"0100",	            -- wValue
		X"0000",	            -- wIndex
		X"0012"		            -- wLength
		);

    data_in(	X"12",		-- Function Address
		18	                -- Expected payload size
		);

-- Status OK
    data_out(	X"12",		-- Function Address
		0   		            -- Expected payload size
	  );

report "Getting CONFIGURATION descriptor ...";
    send_setup(	X"12", 		-- Function Address
		X"80",		            -- Request Type
		GET_DESCRIPTOR,	      -- Request
		X"0200",	            -- wValue
		X"0000",	            -- wIndex
		X"0008"	              -- wLength
		);

    data_in(	X"12",	    -- Function Address
		8		                  -- Expected payload size
	  );

-- Status OK
    data_out(	X"12",		  -- Function Address
		0	    	              -- Expected payload size
	  );

report "Getting whole CONFIGURATION descriptor ...";
		send_setup(	X"12", 		-- Function Address
		X"80",		            -- Request Type
		GET_DESCRIPTOR,	      -- Request
		X"0200",	            -- wValue
		X"0000",              -- wIndex
		X"0043"		            -- wLength
		);

    data_in(	X"12",		  -- Function Address
		64 	    	            -- Expected payload size
	  );

-- Status OK
    data_out(	X"12",		  -- Function Address
		0		                  -- Expected payload size
	  );

    data_in(	X"12",		  -- Function Address
		3 	    	            -- Expected payload size
	  );

-- Status OK
    data_out(	X"12",		  -- Function Address
		0		                  -- Expected payload size
	  );
	  
report "Set configuration 1...";	  
		send_setup(	X"12", 		-- Function Address
		X"00",		            -- Request Type
		SET_CONFIG,           -- Request
		X"0001",	            -- wValue
		X"0000",              -- wIndex
		X"0000"		            -- wLength
		);

    data_in(	X"12",		  -- Function Address
		0 	    	            -- Expected payload size
	  );
	  
    wait for 1 us;
	  
report "EP1 OUT...";	  
	  for nn in 0 to 63 loop
		  buffer1(nn) := std_logic_vector(to_unsigned(nn+32,8));
    end loop;
	  buffer1_last := 0;
	  pid := "0000";
	
	  send_sof(0);	 -- Send SOF
	  wait until rising_edge(usbclk);

	  send_token(	X"12",	-- Function Address
			X"1",             -- Logical Endpoint Number
			USBF_T_PID_OUT	  -- PID
			);

	  wait until rising_edge(usbclk);

	  if (pid="0000")	then
	    send_data(USBF_T_PID_DATA0, 64, 1);
	  else
	    send_data(USBF_T_PID_DATA1, 64, 1);
	  end if;

	  pid := not(pid);

    -- Wait for ACK
	  utmi_recv_pack(len);		
		
		for nn in 0 to 63 loop
		  uartread(dd);
      DEALLOCATE(ss);
      WRITE(ss,string'("uartread="));
      HWRITE(ss,dd);
      report ss.all;		  
		end loop;

    wait for 1 us;

report "EP1 IN...";	
		
		for nn in 0 to 63 loop
	    dd := std_logic_vector(to_unsigned(nn,8));
      DEALLOCATE(ss);
      WRITE(ss,string'("uartwrite="));
      HWRITE(ss,dd);
      report ss.all;		  
		  uartwrite(dd);
		end loop;
		

	-- Send Data
	  send_sof(1);	        -- Send SOF
	  send_token(	X"12",		-- Function Address
			X"1",		            -- Logical Endpoint Number
			USBF_T_PID_IN	      -- PID
			);

	   recv_packet(pid,rlen);
			
	  for nn in 0 to 63 loop
	    dd := txmem(nn+1);
      DEALLOCATE(ss);
      WRITE(ss,string'("usb recv="));
      HWRITE(ss,dd);
      report ss.all;		  
    end loop;	  
    
	  send_token(	X"12",		-- Function Address
			X"1",		            -- Logical Endpoint Number
			USBF_T_PID_ACK	    -- PID
			);    
			
		wait for 10us;
		
		reset <= '1';
		wait for 1us;
		reset <= '0';
		
    wait;
  end process;
  
  
end architecture akre;
