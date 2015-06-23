
-------------------------------------------------------------------------------
--
-- (c) Copyright 2009-2011 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------
-- Project    : Virtex-6 Integrated Block for PCI Express
-- File       : pci_exp_usrapp_rx_m2.vhd
-- Version    : 2.3
--
--------------------------------------------------------------------------------
--
-- Version    : 2.3.1 (28.10.2011) dsmv
--  Description: update TRN_RX_TIMEOUT value (for fix RD problem in simulation)
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package	pci_exp_usrapp_rx_m2_pkg is

component pci_exp_usrapp_rx_m2 is

generic (


  --TRN_RX_TIMEOUT  : INTEGER :=30000
  TRN_RX_TIMEOUT  : INTEGER :=3000000

);

port (

  trn_rdst_rdy_n           : out std_logic;
  trn_rnp_ok_n             : out std_logic;
  trn_rd                   : in std_logic_vector ((64 - 1) downto 0 );
  trn_rrem_n               : in std_logic_vector ((8 - 1) downto 0 );
  trn_rsof_n               : in std_logic;
  trn_reof_n               : in std_logic;
  trn_rsrc_rdy_n           : in std_logic;
  trn_rsrc_dsc_n           : in std_logic;
  trn_rerrfwd_n            : in std_logic;
  trn_rbar_hit_n           : in std_logic_vector ((7 - 1) downto 0 );

  trn_clk                  : in std_logic;
  trn_reset_n              : in std_logic;
  trn_lnk_up_n             : in std_logic;

  --sim_time                 : in TIME;
  rx_tx_read_data          : out std_logic_vector(31 downto 0);
  rx_tx_read_data_valid    : out std_logic;
  tx_rx_read_data_valid    : in std_logic



);

end component;

end package;


library ieee;
use ieee.std_logic_1164.all;  
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

use work.root_memory_pkg.all;

entity pci_exp_usrapp_rx_m2 is

generic (


  TRN_RX_TIMEOUT  : INTEGER :=30000

);

port (

  trn_rdst_rdy_n           : out std_logic;
  trn_rnp_ok_n             : out std_logic;
  trn_rd                   : in std_logic_vector ((64 - 1) downto 0 );
  trn_rrem_n               : in std_logic_vector ((8 - 1) downto 0 );
  trn_rsof_n               : in std_logic;
  trn_reof_n               : in std_logic;
  trn_rsrc_rdy_n           : in std_logic;
  trn_rsrc_dsc_n           : in std_logic;
  trn_rerrfwd_n            : in std_logic;
  trn_rbar_hit_n           : in std_logic_vector ((7 - 1) downto 0 );

  trn_clk                  : in std_logic;
  trn_reset_n              : in std_logic;
  trn_lnk_up_n             : in std_logic;

  --sim_time                 : in TIME;
  rx_tx_read_data          : out std_logic_vector(31 downto 0);
  rx_tx_read_data_valid    : out std_logic;
  tx_rx_read_data_valid    : in std_logic



);

end pci_exp_usrapp_rx_m2;

architecture rtl of pci_exp_usrapp_rx_m2 is

type BYTE_ARRAY is array (999 downto 0) of std_logic_vector(7 downto 0);

constant TRN_RX_RESET      : std_logic_vector(4 downto 0) := "00001";
constant TRN_RX_DOWN       : std_logic_vector(4 downto 0) := "00010";
constant TRN_RX_IDLE       : std_logic_vector(4 downto 0) := "00100";
constant TRN_RX_ACTIVE     : std_logic_vector(4 downto 0) := "01000";
constant TRN_RX_SRC_DSC    : std_logic_vector(4 downto 0) := "10000";

constant PCI_EXP_MEM_READ32            : std_logic_vector(6 downto 0) := "0000000";
constant PCI_EXP_IO_READ               : std_logic_vector(6 downto 0) := "0000010";
constant PCI_EXP_CFG_READ0             : std_logic_vector(6 downto 0) := "0000100";
constant PCI_EXP_COMPLETION_WO_DATA    : std_logic_vector(6 downto 0) := "0001010";
constant PCI_EXP_MEM_READ64            : std_logic_vector(6 downto 0) := "0100000";
constant PCI_EXP_MSG_NODATA            : std_logic_vector(6 downto 3) := "0110";
constant PCI_EXP_MEM_WRITE32           : std_logic_vector(6 downto 0) := "1000000";
constant PCI_EXP_IO_WRITE              : std_logic_vector(6 downto 0) := "1000010";
constant PCI_EXP_CFG_WRITE0            : std_logic_vector(6 downto 0) := "1000100";
constant PCI_EXP_COMPLETION_DATA       : std_logic_vector(6 downto 0) := "1001010";
constant PCI_EXP_MEM_WRITE64           : std_logic_vector(6 downto 0) := "1100000";
constant PCI_EXP_MSG_DATA              : std_logic_vector(6 downto 3) := "1110";

constant COMPLETER_ID_CFG : std_logic_vector(15 downto 0) := X"01A0";


-- Global variables

shared variable frame_store_rx         : BYTE_ARRAY;
shared variable frame_store_rx_idx     : INTEGER;
shared variable next_trn_rx_timeout    : INTEGER;

signal trn_rdst_rdy_n_c       : std_logic;
signal trn_rnp_ok_n_c         : std_logic;
signal read_data_valid_int    : std_logic;
signal read_data_valid_int_d : std_logic; -- added to prevent race condition
signal trn_rx_state           : std_logic_vector(4 downto 0);		 

signal	mem64r_request0 		: std_logic;
signal	mem64r_request1 		: std_logic;

file RX_file : TEXT open write_mode is "rx.dat";



--************************************************************
--     Proc : writeNowToRx
--     Inputs : Text String
--     Outputs : None
--     Description : Displays text string to Rx file pre-appended with
--         current simulation time..
--   *************************************************************/

procedure writeNowToRx (

  text_string                 : in string

) is

  variable L      : line;

begin

  write (L, String'("[ "));
  write (L, now);
  write (L, String'(" ] : "));
  write (L, text_string);
  writeline (rx_file, L);

end writeNowToRx;


--************************************************************
--     Proc : writeNowToScreen
--     Inputs : Text String
--     Outputs : None
--     Description : Displays current simulation time and text string to
--          standard output.
--   *************************************************************

procedure writeNowToScreen (

  text_string                 : in string

) is

  variable L      : line;

begin

  write (L, String'("[ "));
  write (L, now);
  write (L, String'(" ] : "));
  write (L, text_string);
  writeline (output, L);

end writeNowToScreen;


--************************************************************
--     Proc : writeHexToRx
--     Inputs : hex value with bit width that is multiple of 4
--     Outputs : None
--     Description : Displays nibble aligned hex value to Rx file
--
--   *************************************************************

procedure writeHexToRx (

  text_string                 : in string;
  hexValue                  : in std_logic_vector

) is

  variable L      : line;

begin

  write (L, text_string);
  hwrite(L, hexValue);
  writeline (rx_file, L);

end writeHexToRx;


--************************************************************
--     Proc : PROC_READ_DATA
--     Inputs : None
--     Outputs : None
--     Description : Consume clocks.
--   *************************************************************/

procedure PROC_READ_DATA (

  last                  : in INTEGER;
  trn_d                 : in std_logic_vector (63 downto 0);
  trn_rem               : in std_logic_vector (7 downto 0)

) is

  variable i            : INTEGER;
  variable data_byte    : std_logic_vector (7 downto 0);
  variable remain       : INTEGER;
  variable hi_index     : INTEGER;
  variable low_index    : INTEGER;
  variable my_line      : line;

begin

  hi_index := 63;
  low_index := 56;
  if (last = 1) then
    if (trn_rem = X"0F") then
      remain := 4;
    else
      remain := 8;
    end if;
  else
      remain := 8;
  end if;

  for i in 0 to (remain - 1) loop

    data_byte := trn_d( hi_index downto low_index);
    hi_index := hi_index - 8;
    low_index := low_index - 8;
    frame_store_rx(frame_store_rx_idx) := data_byte;
    frame_store_rx_idx := frame_store_rx_idx + 1;

  end loop;

end PROC_READ_DATA;


--************************************************************
--  Proc : PROC_DECIPHER_FRAME
--  Inputs : None
-- Outputs : fmt, tlp_type, traffic_class, td, ep, attr, length
--  Description : Deciphers frame
--  *************************************************************/

procedure PROC_DECIPHER_FRAME (

  fmt                   : out std_logic_vector (1 downto 0);
  tlp_type              : out std_logic_vector (4 downto 0);
  traffic_class         : out std_logic_vector (2 downto 0);
  td                    : out std_logic;
  ep                    : out std_logic;
  attr                  : out std_logic_vector (1 downto 0);
  length                : out std_logic_vector (9 downto 0)

) is

begin

  fmt := frame_store_rx(0)(6 downto 5);
  tlp_type := frame_store_rx(0)(4 downto 0);
  traffic_class := frame_store_rx(1)(6 downto 4);
  td := frame_store_rx(2)(7);
  ep := frame_store_rx(2)(6);
  attr := frame_store_rx(2)(5 downto 4);
  length(9 downto 8) := frame_store_rx(2)(1 downto 0);
  length(7 downto 0) := frame_store_rx(3);

end PROC_DECIPHER_FRAME;


-- ************************************************************
--  Proc : PROC_3DW
--  Inputs : fmt, type, traffic_class, td, ep, attr, length,
--  payload,
--  Outputs : None
--  Description : Gets variables and prints frame
--  *************************************************************/

procedure PROC_3DW (

  fmt                           : in std_logic_vector (1 downto 0);
  tlp_type                      : in std_logic_vector (4 downto 0);
  traffic_class                 : in std_logic_vector (2 downto 0);
  td                            : in std_logic;
  ep                            : in std_logic;
  attr                          : in std_logic_vector (1 downto 0);
  length                        : in std_logic_vector (9 downto 0);
  payload                       : in INTEGER;
  signal rx_tx_read_data        : out std_logic_vector(31 downto 0);
  signal read_data_valid_int    : out std_logic

) is

  variable requester_id         : std_logic_vector (15 downto 0);
  variable tag                  : std_logic_vector (7 downto 0);
  variable byte_enables         : std_logic_vector (7 downto 0);
  variable address_low          : std_logic_vector (31 downto 0);
  variable completer_id         : std_logic_vector (15 downto 0);
  variable register_address     : std_logic_vector (9 downto 0);
  variable completion_status    : std_logic_vector (2 downto 0);
  variable i                    : INTEGER;
  variable L                    : line;
  variable fmt_type             : std_logic_vector (6 downto 0);

begin

  writeHexToRx (String'("     Traffic Class: 0x"), '0' & traffic_class);
  write (L, String'("     TD: ")); write(L,  td); writeline (rx_file, L);
  write (L, String'("     EP: ")); write(L, ep); writeline (rx_file, L);
  writeHexToRx (String'("     Attributes: 0x"), "00" & attr);
  writeHexToRx (String'("     Length: 0x"), "00" & length);


  fmt_type := fmt & tlp_type;
  case (fmt_type) is

    when PCI_EXP_CFG_READ0 | PCI_EXP_CFG_WRITE0 =>

      requester_id := frame_store_rx(4) & frame_store_rx(5);
      tag := frame_store_rx(6);
      byte_enables := frame_store_rx(7);
      completer_id := frame_store_rx(8) & frame_store_rx(9);
      register_address(9 downto 8) := frame_store_rx(10)(1 downto 0);
      register_address(7 downto 0) := frame_store_rx(11);

      writeHexToRx ( String'("     Requester Id: 0x"), requester_id);
      writeHexToRx ( String'("     Tag: 0x"), tag);
      writeHexToRx ( String'("     Last and First Byte Enables: 0x"), byte_enables);
      writeHexToRx ( String'("     Completer Id: 0x"), completer_id);
      writeHexToRx (String'("     Register Address: 0x"), "00" & register_address);

      if (payload = 1) then

        write (L, String'("")); writeline(rx_file, L);
        for i in 12 to (frame_store_rx_idx - 1) loop
          writeHexToRx ( String'("     0x"), frame_store_rx(i));
        end loop;

      end if;
      write (L, String'("")); writeline(rx_file, L);

    when PCI_EXP_COMPLETION_WO_DATA | PCI_EXP_COMPLETION_DATA=>

      completer_id := frame_store_rx(4) & frame_store_rx(5);
      completion_status(2 downto 0) := frame_store_rx(6)(7 downto 5);
      requester_id := frame_store_rx(8) & frame_store_rx(9);
      tag := frame_store_rx(10);

      writeHexToRx ( String'("     Completer Id: 0x"), completer_id);
      writeHexToRx ( String'("     Completion Status: 0x"), '0' & completion_status);
      writeHexToRx ( String'("     Requester Id: 0x"), requester_id);
      writeHexToRx ( String'("     Tag: 0x"), tag);

      if (payload = 1) then

        write (L, String'("")); writeline(rx_file, L);
        for i in 12 to (frame_store_rx_idx - 1) loop
          writeHexToRx ( String'("     0x"), frame_store_rx(i));
        end loop;

        rx_tx_read_data <= frame_store_rx(15) & frame_store_rx(14) &
        frame_store_rx(13) & frame_store_rx(12);
        read_data_valid_int <= '1';

      end if;
      write (L, String'("")); writeline(rx_file, L);

    when others =>

      requester_id := frame_store_rx(4) & frame_store_rx(5);
      tag := frame_store_rx(6);
      byte_enables := frame_store_rx(7);
      address_low(31 downto 24) := frame_store_rx(8);
      address_low(23 downto 16) := frame_store_rx(9);
      address_low(15 downto 8) := frame_store_rx(10);
      address_low( 7 downto 0) := frame_store_rx(11);

      writeHexToRx ( String'("     Requester Id: 0x"), requester_id);
      writeHexToRx ( String'("     Tag: 0x"), tag);
      writeHexToRx ( String'("     Last and First Byte Enables: 0x"), byte_enables);
      writeHexToRx ( String'("     Address Low: 0x"), address_low);

      if (payload = 1) then

        write (L, String'("")); writeline(rx_file, L);
        for i in 12 to (frame_store_rx_idx - 1) loop
          writeHexToRx ( String'("     0x"), frame_store_rx(i));
        end loop;

      end if;
      write (L, String'("")); writeline(rx_file, L);

  end case;

end PROC_3DW;


-- ************************************************************
--  Proc : PROC_4DW
--  Inputs : fmt, type, traffic_class, td, ep, attr, length
--  payload
--  Outputs : None
--  Description : Gets variables and prints frame
--  *************************************************************/

procedure PROC_4DW (

  fmt                      : in std_logic_vector (1 downto 0);
  tlp_type                 : in std_logic_vector (4 downto 0);
  traffic_class            : in std_logic_vector (2 downto 0);
  td                       : in std_logic;
  ep                       : in std_logic;
  attr                     : in std_logic_vector (1 downto 0);
  length                   : in std_logic_vector (9 downto 0);
  payload                  : in INTEGER

) is
  variable requester_id    : std_logic_vector (15 downto 0);
  variable tag             : std_logic_vector (7 downto 0);
  variable byte_enables    : std_logic_vector (7 downto 0);
  variable message_code    : std_logic_vector (7 downto 0);
  variable address_high    : std_logic_vector (31 downto 0);
  variable address_low     : std_logic_vector (31 downto 0);
  variable msg_type        : std_logic_vector (2 downto 0);
  variable i               : INTEGER;
  variable L               : line;
  variable fmt_type        : std_logic_vector (6 downto 0);

begin


  writeHexToRx (String'("     Traffic Class: 0x"), '0' & traffic_class);
  write (L, String'("     TD: ")); write(L,  td); writeline (rx_file, L);
  write (L, String'("     EP: ")); write(L, ep); writeline (rx_file, L);
  writeHexToRx (String'("     Attributes: 0x"), "00" & attr);
  writeHexToRx (String'("     Length: 0x"), "00" & length);

  requester_id := frame_store_rx(4) & frame_store_rx(5);
  tag := frame_store_rx(6);
  byte_enables := frame_store_rx(7);
  message_code := frame_store_rx(7);
  address_high(31 downto 24) := frame_store_rx(8);
  address_high(23 downto 16) := frame_store_rx(9) ;
  address_high(15 downto 8) := frame_store_rx(10);
  address_high(7 downto 0) := frame_store_rx(11);
  address_low(31 downto 24) := frame_store_rx(12);
  address_low(23 downto 16) := frame_store_rx(13);
  address_low(15 downto 8) := frame_store_rx(14) ;
  address_low(7 downto 0) := frame_store_rx(15);
  
--  mem64r_adr_low := address_low;
--  mem64r_adr_high := address_high;
--  mem64r_tag := tag; 
--  mem64r_size := conv_integer( length );
--  mem64r_requester_id := requester_id;
  

  writeHexToRx ( String'("     Requester Id: 0x"), requester_id);
  writeHexToRx ( String'("     Tag: 0x"), tag);

  fmt_type := fmt & tlp_type;

  if ((fmt_type(6 downto 3) = PCI_EXP_MSG_NODATA)
     or (fmt_type(6 downto 3) = PCI_EXP_MSG_DATA)) then

    msg_type := tlp_type(2 downto 0);
    writeHexToRx ( String'("     Message Type: 0x"), '0' & msg_type);
    writeHexToRx ( String'("     Message Code: 0x"), message_code);
    writeHexToRx ( String'("     Address High: 0x"), address_high);
    writeHexToRx ( String'("     Address Low:  0x"), address_low);

    if (payload = 1) then

      write (L, String'("")); writeline(rx_file, L);
      for i in 16 to (frame_store_rx_idx - 1) loop

        writeHexToRx ( String'("     0x"), frame_store_rx(i));

      end loop;

    end if;
    write (L, String'("")); writeline(rx_file, L);

  else

    case (fmt_type) is

      when PCI_EXP_MEM_READ64 | PCI_EXP_MEM_WRITE64 =>

        writeHexToRx ( String'("     Last and First Byte Enables: 0x"), byte_enables);
        writeHexToRx ( String'("     Address High: 0x"), address_high);
        writeHexToRx ( String'("     Address Low:  0x"), address_low);

        if (payload = 1) then

          write (L, String'("")); writeline(rx_file, L);
          for i in 16 to (frame_store_rx_idx - 1) loop

            writeHexToRx ( String'("     0x"), frame_store_rx(i));

    end loop;

        end if;

        write (L, String'("")); writeline(rx_file, L);

      when others =>

        write (L, String'(": Not a vaild frame")); writeline (rx_file, L); write (L, String'("")); writeline(rx_file, L);
        assert (false)
          report "Simulation Ended"
          severity failure;

    end  case;

  end if;

end PROC_4DW;


--************************************************************
--  Proc : PROC_PARSE_FRAME
--  Inputs : None
--  Outputs : None
--  Description : Parse frame data
--  *************************************************************/

procedure PROC_PARSE_FRAME  (

  signal rx_tx_read_data        : out std_logic_vector(31 downto 0);
  signal read_data_valid_int    : out std_logic;
  signal mem_request			: out std_logic

) is

  variable fmt                  : std_logic_vector (1 downto 0);
  variable tlp_type             : std_logic_vector (4 downto 0);
  variable traffic_class        : std_logic_vector (2 downto 0);
  variable td                   : std_logic;
  variable ep                   : std_logic;
  variable attr                 : std_logic_vector (1 downto 0);
  variable length               : std_logic_vector (9 downto 0);
  variable payload              : INTEGER;
--  variable reqester_id          : std_logic_vector(15 downto 0);
  variable completer_id         : std_logic_vector(15 downto 0);
  variable tag                  : std_logic_vector(7 downto 0);
  variable byte_enables         : std_logic_vector(7 downto 0);
  variable message_code         : std_logic_vector(7 downto 0);
  variable address_low          : std_logic_vector(31 downto 0);
  variable address_high         : std_logic_vector(31 downto 0);
  variable register_address     : std_logic_vector (9 downto 0);
  variable completion_status    : std_logic_vector (2 downto 0);
  variable log_file_ptr         : std_logic_vector (31 downto 0);
  variable frame_store_idx      : INTEGER;
  variable fmt_type             : std_logic_vector (6 downto 0);
  variable L                    : line;
  
  variable requester_id    : std_logic_vector (15 downto 0);
  
  variable mem64r				: type_memory_request_item;
  
  variable	frame_wr_index		: integer;
  variable	frame_wr_size		: integer;
  variable  frame_wr_data		: std_logic_vector( 31 downto 0 );
  
begin

  writeNowToScreen ( String'("PROC_PARSE_FRAME on Receive"));

  PROC_DECIPHER_FRAME (fmt, tlp_type, traffic_class, td, ep, attr, length);

  -- decode the packets received based on fmt and type
  fmt_type := fmt & tlp_type;

  if (fmt_type(6 downto 3) = PCI_EXP_MSG_NODATA) then

    writeNowToRx("Message With No Data Frame");
    payload := 0;
    PROC_4DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

  elsif (fmt_type(6 downto 3) = PCI_EXP_MSG_DATA) then

    writeNowToRx("Message With Data Frame");
    payload := 1;
    PROC_4DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

  else

    case (fmt_type) is

      when PCI_EXP_MEM_READ32 =>

        writeNowToRx("Memory Read-32 Frame");
        payload := 0;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload, rx_tx_read_data, read_data_valid_int );
		
		
  		address_high(31 downto 24) := x"00";
  		address_high(23 downto 16) := x"00";
  		address_high(15 downto 8) := x"00";
  		address_high(7 downto 0) := x"00";
		  
  		address_low(31 downto 24) := frame_store_rx(8);
  		address_low(23 downto 16) := frame_store_rx(9);
  		address_low(15 downto 8) := frame_store_rx(10) ;
  		address_low(7 downto 0) := frame_store_rx(11);
	  
		  requester_id := frame_store_rx(4) & frame_store_rx(5);
		  tag := frame_store_rx(6);
  
		  mem64r.adr_low := address_low;
		  mem64r.adr_high := address_high;
		  mem64r.tag := tag; 
		  mem64r.size := conv_integer( length );
		  mem64r.requester_id := requester_id;
		  
		  memory_request_write( mem64r );
		
		  mem_request <= '1', '0' after 1 ns;		

      when PCI_EXP_IO_READ =>

        writeNowToRx("IO Read Frame");
        payload := 0;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload, rx_tx_read_data, read_data_valid_int );

      when PCI_EXP_CFG_READ0 =>

        writeNowToRx("Config Read Type 0 Frame");
        payload := 0;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload, rx_tx_read_data, read_data_valid_int );

      when PCI_EXP_COMPLETION_WO_DATA =>

        writeNowToRx("Completion Without Data Frame");
        payload := 0;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload, rx_tx_read_data, read_data_valid_int );

      when PCI_EXP_MEM_READ64 =>

        writeNowToRx("Memory Read-64 Frame");
        payload := 0;
        PROC_4DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload); --, rx_tx_read_data, rx_tx_read_data_valid );
		
		writeNowToRx("Memory Read-64 wait completion");
		--mem64r_request <= 10;			   
		
  		address_high(31 downto 24) := frame_store_rx(8);
  		address_high(23 downto 16) := frame_store_rx(9) ;
  		address_high(15 downto 8) := frame_store_rx(10);
  		address_high(7 downto 0) := frame_store_rx(11);
  		address_low(31 downto 24) := frame_store_rx(12);
  		address_low(23 downto 16) := frame_store_rx(13);
  		address_low(15 downto 8) := frame_store_rx(14) ;
  		address_low(7 downto 0) := frame_store_rx(15);
	  
		  requester_id := frame_store_rx(4) & frame_store_rx(5);
		  tag := frame_store_rx(6);
  
		  mem64r.adr_low := address_low;
		  mem64r.adr_high := address_high;
		  mem64r.tag := tag; 
		  mem64r.size := conv_integer( length );
		  mem64r.requester_id := requester_id;
		  
		  memory_request_write( mem64r );
		
		  mem_request <= '1', '0' after 1 ns;
--		loop
--			if( mem64r_request = 0 ) then
--				exit;
--			end if;
--			wait for 200 ns;
--		end loop;

      when PCI_EXP_MEM_WRITE32 =>

        writeNowToRx("Memory Write-32 Frame");
        payload := 1;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload, rx_tx_read_data, read_data_valid_int );
		
		
  		address_high(31 downto 24) := x"00";
  		address_high(23 downto 16) := x"00";
  		address_high(15 downto 8) :=  x"00";
  		address_high(7 downto 0) :=   x"00";
		  
  		address_low(31 downto 24) := frame_store_rx(8);
  		address_low(23 downto 16) := frame_store_rx(9);
  		address_low(15 downto 8) := frame_store_rx(10) ;
  		address_low(7 downto 0) := frame_store_rx(11);
	  		
		
		 frame_wr_size:=(frame_store_rx_idx-16)/4;
		 for ii in 0 to frame_wr_size-1 loop
			 frame_wr_data( 7 downto 0 ) 	:= frame_store_rx( 12+ii*4 );
			 frame_wr_data( 15 downto 8 ) 	:= frame_store_rx( 12+ii*4+1 );
			 frame_wr_data( 23 downto 16 ) 	:= frame_store_rx( 12+ii*4+2 );
			 frame_wr_data( 31 downto 24 ) 	:= frame_store_rx( 12+ii*4+3 );
			 
			 memory_write( address_high, address_low+ii*4, frame_wr_data );
			 
		 end loop;	
		 
      when PCI_EXP_IO_WRITE =>

        writeNowToRx("IO Write Frame");
        payload := 1;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload, rx_tx_read_data, read_data_valid_int );

      when PCI_EXP_CFG_WRITE0 =>

        writeNowToRx("Config Write Type 0 Frame");
        payload := 1;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload, rx_tx_read_data, read_data_valid_int );

      when PCI_EXP_COMPLETION_DATA =>

        writeNowToRx("Completion With Data Frame");
        payload := 1;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload, rx_tx_read_data, read_data_valid_int );

      when PCI_EXP_MEM_WRITE64 =>

        writeNowToRx("Memory Write-64 Frame");
        payload := 1;
        PROC_4DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);
		
  		address_high(31 downto 24) := frame_store_rx(8);
  		address_high(23 downto 16) := frame_store_rx(9) ;
  		address_high(15 downto 8) := frame_store_rx(10);
  		address_high(7 downto 0) := frame_store_rx(11);
  		address_low(31 downto 24) := frame_store_rx(12);
  		address_low(23 downto 16) := frame_store_rx(13);
  		address_low(15 downto 8) := frame_store_rx(14) ;
  		address_low(7 downto 0) := frame_store_rx(15);
	  		
		
		 frame_wr_size:=(frame_store_rx_idx-16)/4;
		 for ii in 0 to frame_wr_size-1 loop
			 frame_wr_data( 7 downto 0 ) 	:= frame_store_rx( 16+ii*4 );
			 frame_wr_data( 15 downto 8 ) 	:= frame_store_rx( 16+ii*4+1 );
			 frame_wr_data( 23 downto 16 ) 	:= frame_store_rx( 16+ii*4+2 );
			 frame_wr_data( 31 downto 24 ) 	:= frame_store_rx( 16+ii*4+3 );
			 
			 memory_write( address_high, address_low+ii*4, frame_wr_data );
			 
		 end loop;		
		 
      when others =>					 
	  

        writeNowToRx("Not a vaild frame. fmt_type = ");
        write (L, fmt_type);
        writeline (rx_file, L);
        assert (false)
          report "Simulation Ended"
          severity failure;

    end case;

  end if;

  frame_store_rx_idx := 0; -- reset frame pointer

end PROC_PARSE_FRAME;


begin

trn_rdst_rdy_n      <= trn_rdst_rdy_n_c;
trn_rnp_ok_n        <= '0';
trn_rdst_rdy_n_c    <= '0';

-- Transaction Receive User Interface State Machine

process (trn_clk, trn_reset_n)
begin

  if (trn_reset_n = '0' ) then

    trn_rx_state  <= TRN_RX_RESET;
    frame_store_rx_idx := 0;
    rx_tx_read_data <= X"FFFFFFFF";
    read_data_valid_int <= '0';

  else

    if (trn_clk'event and trn_clk = '1') then

      case (trn_rx_state) is

        when TRN_RX_RESET =>

          if (trn_reset_n = '0') then

            trn_rx_state <= TRN_RX_RESET;

          else

            trn_rx_state <= TRN_RX_DOWN;

          end if;

        when TRN_RX_DOWN =>

          if (trn_lnk_up_n = '1') then

            trn_rx_state <= TRN_RX_DOWN;

          else

            trn_rx_state <= TRN_RX_IDLE;

          end if;

        when TRN_RX_IDLE =>

          read_data_valid_int <= '0';
          if (trn_reset_n = '0') then

            trn_rx_state <= TRN_RX_RESET;

          elsif (trn_lnk_up_n = '1') then

            trn_rx_state <= TRN_RX_DOWN;

          elsif ((trn_rsof_n = '0') and (trn_rsrc_rdy_n = '0') and (trn_rdst_rdy_n_c = '0')) then

            PROC_READ_DATA (0, trn_rd, trn_rrem_n);
            trn_rx_state <= TRN_RX_ACTIVE;

          else

            trn_rx_state <= TRN_RX_IDLE;

          end if;

        when TRN_RX_ACTIVE =>

          if (trn_reset_n = '0') then

            trn_rx_state <= TRN_RX_RESET;

          elsif (trn_lnk_up_n = '1') then

            trn_rx_state <= TRN_RX_DOWN;

          elsif ((trn_rsrc_rdy_n = '0') and (trn_reof_n = '0') and (trn_rdst_rdy_n_c = '0')) then

			  
--			if( mem64r_request/=0 ) then
--				wait until ;
--			end if;
			  
            PROC_READ_DATA (1, trn_rd, trn_rrem_n);
            PROC_PARSE_FRAME  (rx_tx_read_data , read_data_valid_int, mem64r_request );
            trn_rx_state <= TRN_RX_IDLE;	
			

          elsif ((trn_rsrc_rdy_n = '0') and (trn_rdst_rdy_n_c = '0')) then

            PROC_READ_DATA (0, trn_rd, trn_rrem_n);
            trn_rx_state <= TRN_RX_ACTIVE;

          elsif ((trn_rsrc_rdy_n = '0') and (trn_reof_n = '0') and (trn_rsrc_dsc_n = '0')) then

--			if( mem64r_request/=0 ) then
--				wait until mem64r_request=0;
--			end if;

			PROC_READ_DATA (1, trn_rd, trn_rrem_n);
            PROC_PARSE_FRAME  (rx_tx_read_data , read_data_valid_int, mem64r_request );
            trn_rx_state <= TRN_RX_SRC_DSC;

          else

            trn_rx_state <= TRN_RX_ACTIVE;

          end if;

        when TRN_RX_SRC_DSC =>

          if (trn_reset_n = '0') then

            trn_rx_state <= TRN_RX_RESET;

          elsif (trn_lnk_up_n = '1') then

            trn_rx_state <= TRN_RX_DOWN;

          else

            trn_rx_state <= TRN_RX_IDLE;

          end if;

        when others =>

          trn_rx_state <= TRN_RX_RESET;

      end case;

    end if;

  end if;

end process;


process (trn_clk, trn_reset_n)
begin

  if (trn_reset_n = '0' ) then

    next_trn_rx_timeout  := TRN_RX_TIMEOUT;

  else

    if (trn_clk'event and trn_clk = '1') then

      if (next_trn_rx_timeout = 0) then

        assert (false)
          report "RX Simulation Timeout."
          severity failure;

      elsif (trn_lnk_up_n = '0') then

        next_trn_rx_timeout := next_trn_rx_timeout - 1;

      end if;

    end if;

  end if;

end process;


--  Following is used to allow rx to tx communication to occur over two trn clocks - avoiding race conditions
process (trn_clk)
begin

  if (trn_clk'event and trn_clk = '1') then

     read_data_valid_int_d <= read_data_valid_int;
  end if;

end process;


process (trn_clk)
begin

  if (trn_clk'event and trn_clk = '1') then

    if (trn_lnk_up_n = '0') then

      if ((tx_rx_read_data_valid = '1' ) and ((read_data_valid_int = '1') or (read_data_valid_int_d = '1'))) then

        rx_tx_read_data_valid <= '1';

      else

        rx_tx_read_data_valid <= '0';

      end if;

    end if;

  end if;

end process;

--mem64r_request <= mem64r_request0 or mem64r_request1;
end; -- pci_exp_usrapp_rx_m2
