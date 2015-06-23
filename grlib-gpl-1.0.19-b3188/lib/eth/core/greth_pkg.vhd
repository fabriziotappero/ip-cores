------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;

package grethpkg is
  --gigabit sync types
  type data_sync_type is array (0 to 3) of std_logic_vector(31 downto 0);
  type ctrl_sync_type is array (0 to 3) of std_logic_vector(1 downto 0);
  
  constant HTRANS_IDLE:   std_logic_vector(1 downto 0) := "00";
  constant HTRANS_NONSEQ: std_logic_vector(1 downto 0) := "10";
  constant HTRANS_SEQ:    std_logic_vector(1 downto 0) := "11";

  constant HBURST_INCR:   std_logic_vector(2 downto 0) := "001";

  constant HSIZE_WORD:    std_logic_vector(2 downto 0) := "010";
  
  constant HRESP_OKAY:    std_logic_vector(1 downto 0) := "00";
  constant HRESP_ERROR:   std_logic_vector(1 downto 0) := "01";
  constant HRESP_RETRY:   std_logic_vector(1 downto 0) := "10";
  constant HRESP_SPLIT:   std_logic_vector(1 downto 0) := "11";

  --receiver constants
  constant maxsizerx : std_logic_vector(15 downto 0) :=
    conv_std_logic_vector(1500, 16);
  constant minpload  : std_logic_vector(10 downto 0) :=
    conv_std_logic_vector(60, 11);
  
  type ahb_fifo_in_type is record
    renable   : std_ulogic;
    raddress  : std_logic_vector(4 downto 0);
    write     : std_ulogic;
    data      : std_logic_vector(31 downto 0);
    waddress  : std_logic_vector(4 downto 0);
  end record;

  type ahb_fifo_out_type is record
    data      : std_logic_vector(31 downto 0);    
  end record;

  type nchar_fifo_in_type is record
    renable   : std_ulogic;
    raddress  : std_logic_vector(5 downto 0);
    write     : std_ulogic;
    data      : std_logic_vector(8 downto 0);
    waddress  : std_logic_vector(5 downto 0);
  end record;

  type nchar_fifo_out_type is record
    data      : std_logic_vector(8 downto 0);
  end record;

  type rmapbuf_in_type is record
    renable   : std_ulogic;
    raddress  : std_logic_vector(7 downto 0);
    write     : std_ulogic;
    data      : std_logic_vector(7 downto 0);
    waddress  : std_logic_vector(7 downto 0);
  end record;

  type rmapbuf_out_type is record
    data      : std_logic_vector(7 downto 0);
  end record;

  type ahbc_mst_in_type is record
    hgrant	: std_ulogic;                           -- bus grant
    hready	: std_ulogic;                         	-- transfer done
    hresp	: std_logic_vector(1 downto 0); 	-- response type
    hrdata	: std_logic_vector(31 downto 0); 	-- read data bus
  end record;

  type ahbc_mst_out_type is record
    hbusreq	: std_ulogic;                         	-- bus request
    hlock	: std_ulogic;                         	-- lock request
    htrans	: std_logic_vector(1 downto 0); 	-- transfer type
    haddr	: std_logic_vector(31 downto 0); 	-- address bus (byte)
    hwrite	: std_ulogic;                         	-- read/write
    hsize	: std_logic_vector(2 downto 0); 	-- transfer size
    hburst	: std_logic_vector(2 downto 0); 	-- burst type
    hprot	: std_logic_vector(3 downto 0); 	-- protection control
    hwdata	: std_logic_vector(31 downto 0); 	-- write data bus
  end record;

  type apbc_slv_in_type is record
    psel	: std_ulogic;                           -- slave select
    penable	: std_ulogic;                         	-- strobe
    paddr	: std_logic_vector(31 downto 0); 	-- address bus (byte)
    pwrite	: std_ulogic;                         	-- write
    pwdata	: std_logic_vector(31 downto 0); 	-- write data bus
  end record;

  type apbc_slv_out_type is record
    prdata	: std_logic_vector(31 downto 0); 	-- read data bus
  end record;

  type eth_tx_ahb_in_type is record
    req     : std_ulogic;
    write   : std_ulogic;
    addr    : std_logic_vector(31 downto 0);
    data    : std_logic_vector(31 downto 0);
  end record;

  type eth_tx_ahb_out_type is record
    grant    : std_ulogic;
    data     : std_logic_vector(31 downto 0);
    ready    : std_ulogic;
    error    : std_ulogic; 
    retry    : std_ulogic; 
  end record;

  type eth_rx_ahb_in_type is record
    req     : std_ulogic;
    write   : std_ulogic; 
    addr    : std_logic_vector(31 downto 0);
    data    : std_logic_vector(31 downto 0);
  end record;

  type eth_rx_ahb_out_type is record
    grant   : std_ulogic;
    ready   : std_ulogic;
    error   : std_ulogic;
    retry   : std_ulogic;
    data    : std_logic_vector(31 downto 0);
  end record;

  type eth_rx_gbit_ahb_in_type is record
    req     : std_ulogic;
    write   : std_ulogic; 
    addr    : std_logic_vector(31 downto 0);
    data    : std_logic_vector(31 downto 0);
    size    : std_logic_vector(1 downto 0);
  end record;

  type gbit_host_tx_type is record
    full_duplex : std_ulogic;
    start       : std_ulogic;
    read_ack    : std_ulogic;
    data        : std_logic_vector(31 downto 0);
    valid       : std_ulogic;
    len         : std_logic_vector(10 downto 0);
    rx_col      : std_ulogic;
    rx_crs      : std_ulogic;
  end record;

  type gbit_tx_host_type is record
    txd          : std_logic_vector(3 downto 0);   
    tx_en        : std_ulogic; 
    done         : std_ulogic;
    read         : std_ulogic;
    restart      : std_ulogic;
    status       : std_logic_vector(1 downto 0);
  end record;

  type gbit_rx_host_type is record
    sync_start   : std_ulogic;
    done         : std_ulogic;
    write        : std_logic_vector(3 downto 0);
    dataout      : data_sync_type;
    byte_count   : std_logic_vector(10 downto 0);
    status       : std_logic_vector(3 downto 0);
    gotframe     : std_ulogic;
  end record;

  type gbit_host_rx_type is record
    full_duplex  : std_ulogic;
    gbit         : std_ulogic;
    doneack      : std_ulogic;
    writeack     : std_logic_vector(3 downto 0);
    speed        : std_ulogic;
    writeok      : std_logic_vector(3 downto 0);
    rxenable     : std_ulogic;
    rxd          : std_logic_vector(7 downto 0);
    rx_dv        : std_ulogic;
    rx_er        : std_ulogic;
    rx_col       : std_ulogic;
    rx_crs       : std_ulogic;
  end record;

  type gbit_gtx_host_type is record
    txd          : std_logic_vector(7 downto 0);   
    tx_en        : std_ulogic; 
    tx_er        : std_ulogic;
    done         : std_ulogic;
    restart      : std_ulogic;
    read         : std_logic_vector(3 downto 0);
    status       : std_logic_vector(2 downto 0);
  end record;

  type gbit_host_gtx_type is record
    rx_col        : std_ulogic;
    rx_crs        : std_ulogic;
    full_duplex   : std_ulogic;
    burstmode     : std_ulogic;
    txen          : std_ulogic;
    start_sync    : std_ulogic;
    readack       : std_logic_vector(3 downto 0);
    valid         : std_logic_vector(3 downto 0);
    data          : data_sync_type;
    len           : std_logic_vector(10 downto 0);
  end record;

  type host_tx_type is record
    rx_col      : std_ulogic;
    rx_crs      : std_ulogic;
    full_duplex : std_ulogic;
    start       : std_ulogic;
    readack     : std_ulogic;
    speed       : std_ulogic;
    data        : std_logic_vector(31 downto 0);
    valid       : std_ulogic;
    len         : std_logic_vector(10 downto 0);
  end record;

  type tx_host_type is record
    txd         : std_logic_vector(3 downto 0);
    tx_en       : std_ulogic;
    tx_er       : std_ulogic;
    done        : std_ulogic;
    read        : std_ulogic;
    restart     : std_ulogic;
    status      : std_logic_vector(1 downto 0);
  end record;

  type rx_host_type is record
    dataout    : std_logic_vector(31 downto 0);
    start      : std_ulogic;
    done       : std_ulogic;
    write      : std_ulogic;
    status     : std_logic_vector(3 downto 0);
    gotframe   : std_ulogic;
    byte_count : std_logic_vector(10 downto 0);
    lentype    : std_logic_vector(15 downto 0);
  end record;

  type host_rx_type is record
    writeack : std_ulogic;
    doneack  : std_ulogic;
    speed    : std_ulogic;
    writeok  : std_ulogic;
    rxd      : std_logic_vector(3 downto 0);
    rx_dv    : std_ulogic;
    rx_crs   : std_ulogic;
    rx_er    : std_ulogic;
    enable   : std_ulogic;
  end record;

  component greth_rx is
    generic(
      nsync          : integer range 1 to 2 := 2;
      rmii           : integer range 0 to 1  := 0);
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      rxi            : in  host_rx_type;
      rxo            : out rx_host_type
    );           
  end component;

  component greth_tx is
    generic(
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      nsync          : integer range 1 to 2 := 2;
      rmii           : integer range 0 to 1  := 0);
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      txi            : in  host_tx_type;
      txo            : out tx_host_type
    );           
  end component;

  component eth_rstgen is
    generic(acthigh : integer := 0);
    port (
      rstin     : in  std_ulogic;
      clk       : in  std_ulogic;
      clklock   : in  std_ulogic;
      rstout    : out std_ulogic;
      rstoutraw : out std_ulogic
    );
  end component;

  component greth_gbit_tx is
    generic(
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      nsync          : integer range 1 to 2 := 2);
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      txi            : in  gbit_host_tx_type;
      txo            : out gbit_tx_host_type);           
  end component;

  component greth_gbit_gtx is
    generic(
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      nsync          : integer range 1 to 2 := 2);
    port(
      rst            : in   std_ulogic;
      clk            : in   std_ulogic;
      gtxi           : in   gbit_host_gtx_type;
      gtxo           : out  gbit_gtx_host_type
    );
  end component;

  component greth_gbit_rx is
    generic(
      nsync          : integer range 1 to 2 := 2);
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      rxi            : in  gbit_host_rx_type;
      rxo            : out gbit_rx_host_type);           
  end component;

  component eth_ahb_mst is
    port(
      rst     : in  std_ulogic;
      clk     : in  std_ulogic;
      ahbmi   : in  ahbc_mst_in_type;
      ahbmo   : out ahbc_mst_out_type;
      tmsti   : in  eth_tx_ahb_in_type;
      tmsto   : out eth_tx_ahb_out_type;
      rmsti   : in  eth_rx_ahb_in_type;
      rmsto   : out eth_rx_ahb_out_type
    );
  end component;

  component eth_ahb_mst_gbit is
    port(
      rst         : in  std_ulogic;
      clk         : in  std_ulogic;
      ahbmi       : in  ahbc_mst_in_type;
      ahbmo       : out ahbc_mst_out_type;
      tmsti       : in  eth_tx_ahb_in_type;
      tmsto       : out eth_tx_ahb_out_type;
      rmsti       : in  eth_rx_gbit_ahb_in_type;
      rmsto       : out eth_rx_ahb_out_type);
  end component;
 
  function mirror(din : in std_logic_vector) return std_logic_vector;

  function crc32_4(d   : in std_logic_vector(3 downto 0);
                   crc : in std_logic_vector(31 downto 0))
                         return std_logic_vector;
  function crc16_2(d1   : in std_logic_vector(15 downto 0);
                   d2   : in std_logic_vector(25 downto 0))
                          return std_logic_vector;
  function crc16(d1   : in std_logic_vector(15 downto 0);
                 d2   : in std_logic_vector(15 downto 0))
                        return std_logic_vector;

  function validlen(len   : in std_logic_vector(10 downto 0);
                    bcnt  : in std_logic_vector(10 downto 0);
                    usesz : in std_ulogic)
                            return std_ulogic;
  
  function getfifosize(edcl, fifosize, ebufsize : in integer) return integer;

  function setburstlength(fifosize : in integer) return integer;
  
  function calccrc(d   : in std_logic_vector(3 downto 0);
                   crc : in std_logic_vector(31 downto 0))
                         return std_logic_vector;

  --16-bit one's complement adder
  function crcadder(d1   : in std_logic_vector(15 downto 0);
                    d2   : in std_logic_vector(17 downto 0))
                         return std_logic_vector;
  
end package;

package body grethpkg is
  
  function mirror(din : in std_logic_vector)
                        return std_logic_vector is
    variable do : std_logic_vector(din'high downto din'low);
  begin
    for i in 0 to din'length-1 loop
      do(din'high-i) := din(i+din'low);
    end loop;
    return do;
  end function;

  function crc32_4(d   : in std_logic_vector(3 downto 0);
                   crc : in std_logic_vector(31 downto 0))
                         return std_logic_vector is
    variable ncrc : std_logic_vector(31 downto 0);
    variable tc   : std_logic_vector(3 downto 0);
  begin
    tc(0) := d(0) xor crc(31); tc(1) := d(1) xor crc(30);
    tc(2) := d(2) xor crc(29); tc(3) := d(3) xor crc(28);
    ncrc(31) := crc(27);
    ncrc(30) := crc(26);
    ncrc(29) := tc(0) xor crc(25);
    ncrc(28) := tc(1) xor crc(24);
    ncrc(27) := tc(2) xor crc(23);
    ncrc(26) := tc(0) xor tc(3) xor crc(22);
    ncrc(25) := tc(0) xor tc(1) xor crc(21);
    ncrc(24) := tc(1) xor tc(2) xor crc(20);
    ncrc(23) := tc(2) xor tc(3) xor crc(19);
    ncrc(22) := tc(3) xor crc(18);
    ncrc(21) := crc(17);
    ncrc(20) := crc(16);
    ncrc(19) := tc(0) xor crc(15);
    ncrc(18) := tc(1) xor crc(14);
    ncrc(17) := tc(2) xor crc(13);
    ncrc(16) := tc(3) xor crc(12);
    ncrc(15) := tc(0) xor crc(11);
    ncrc(14) := tc(0) xor tc(1) xor crc(10);
    ncrc(13) := tc(0) xor tc(1) xor tc(2) xor crc(9);
    ncrc(12) := tc(1) xor tc(2) xor tc(3) xor crc(8);
    ncrc(11) := tc(0) xor tc(2) xor tc(3) xor crc(7);
    ncrc(10) := tc(0) xor tc(1) xor tc(3) xor crc(6);
    ncrc(9)  := tc(1) xor tc(2) xor crc(5);
    ncrc(8)  := tc(0) xor tc(2) xor tc(3) xor crc(4);
    ncrc(7)  := tc(0) xor tc(1) xor tc(3) xor crc(3);
    ncrc(6)  := tc(1) xor tc(2) xor crc(2);
    ncrc(5)  := tc(0) xor tc(2) xor tc(3) xor crc(1);
    ncrc(4)  := tc(0) xor tc(1) xor tc(3) xor crc(0);
    ncrc(3)  := tc(0) xor tc(1) xor tc(2);
    ncrc(2)  := tc(1) xor tc(2) xor tc(3);
    ncrc(1)  := tc(2) xor tc(3);
    ncrc(0)  := tc(3);
    return ncrc;
  end function;

  --16-bit one's complement adder
  function crc16(d1   : in std_logic_vector(15 downto 0);
                 d2   : in std_logic_vector(15 downto 0))
                        return std_logic_vector is
    variable vd1  : std_logic_vector(16 downto 0);
    variable vd2  : std_logic_vector(16 downto 0);
    variable sum  : std_logic_vector(16 downto 0);
  begin
    vd1 := '0' & d1; vd2 := '0' & d2;
    sum := vd1 + vd2;
    sum(15 downto 0) := sum(15 downto 0) + sum(16);
    return sum(15 downto 0);
  end function;

  --16-bit one's complement adder for ip/tcp checksum detection
  function crc16_2(d1   : in std_logic_vector(15 downto 0);
                   d2   : in std_logic_vector(25 downto 0))
                          return std_logic_vector is
    variable vd1  : std_logic_vector(25 downto 0);
    variable vd2  : std_logic_vector(25 downto 0);
    variable sum  : std_logic_vector(25 downto 0);
  begin
    vd1 := "0000000000" & d1; vd2 := d2;
    sum := vd1 + vd2;
    return sum;
  end function;

  function validlen(len   : in std_logic_vector(10 downto 0);
                    bcnt  : in std_logic_vector(10 downto 0);
                    usesz : in std_ulogic)
                            return std_ulogic is
    variable valid : std_ulogic;
  begin
    valid := '1';
    if usesz = '1' then
      if len > minpload then
        if bcnt /= len then
          valid := '0';
        end if;
      else
        if bcnt /= minpload then
          valid := '0';
        end if;
      end if;
    end if;
    return valid;
  end function;

  function setburstlength(fifosize : in integer) return integer is
  begin
    if fifosize <= 64 then
      return fifosize/2;
    else
      return 32;
    end if;
  end function;

  function getfifosize(edcl, fifosize, ebufsize : in integer) return integer is
  begin
    if (edcl /= 0) and (ebufsize > fifosize) then
      return ebufsize;
    else
      return fifosize;
    end if;
  end function;
  
  function calccrc(d   : in std_logic_vector(3 downto 0);
                   crc : in std_logic_vector(31 downto 0))
                         return std_logic_vector is
    variable ncrc : std_logic_vector(31 downto 0);
    variable tc   : std_logic_vector(3 downto 0);
  begin
    tc(0) := d(0) xor crc(31); tc(1) := d(1) xor crc(30);
    tc(2) := d(2) xor crc(29); tc(3) := d(3) xor crc(28);
    ncrc(31) := crc(27);
    ncrc(30) := crc(26);
    ncrc(29) := tc(0) xor crc(25);
    ncrc(28) := tc(1) xor crc(24);
    ncrc(27) := tc(2) xor crc(23);
    ncrc(26) := tc(0) xor tc(3) xor crc(22);
    ncrc(25) := tc(0) xor tc(1) xor crc(21);
    ncrc(24) := tc(1) xor tc(2) xor crc(20);
    ncrc(23) := tc(2) xor tc(3) xor crc(19);
    ncrc(22) := tc(3) xor crc(18);
    ncrc(21) := crc(17);
    ncrc(20) := crc(16);
    ncrc(19) := tc(0) xor crc(15);
    ncrc(18) := tc(1) xor crc(14);
    ncrc(17) := tc(2) xor crc(13);
    ncrc(16) := tc(3) xor crc(12);
    ncrc(15) := tc(0) xor crc(11);
    ncrc(14) := tc(0) xor tc(1) xor crc(10);
    ncrc(13) := tc(0) xor tc(1) xor tc(2) xor crc(9);
    ncrc(12) := tc(1) xor tc(2) xor tc(3) xor crc(8);
    ncrc(11) := tc(0) xor tc(2) xor tc(3) xor crc(7);
    ncrc(10) := tc(0) xor tc(1) xor tc(3) xor crc(6);
    ncrc(9)  := tc(1) xor tc(2) xor crc(5);
    ncrc(8)  := tc(0) xor tc(2) xor tc(3) xor crc(4);
    ncrc(7)  := tc(0) xor tc(1) xor tc(3) xor crc(3);
    ncrc(6)  := tc(1) xor tc(2) xor crc(2);
    ncrc(5)  := tc(0) xor tc(2) xor tc(3) xor crc(1);
    ncrc(4)  := tc(0) xor tc(1) xor tc(3) xor crc(0);
    ncrc(3)  := tc(0) xor tc(1) xor tc(2);
    ncrc(2)  := tc(1) xor tc(2) xor tc(3);
    ncrc(1)  := tc(2) xor tc(3);
    ncrc(0)  := tc(3);
    return ncrc;
  end function;

  --16-bit one's complement adder
  function crcadder(d1   : in std_logic_vector(15 downto 0);
                    d2   : in std_logic_vector(17 downto 0))
                         return std_logic_vector is
    variable vd1  : std_logic_vector(17 downto 0);
    variable vd2  : std_logic_vector(17 downto 0);
    variable sum  : std_logic_vector(17 downto 0);
  begin
    vd1 := "00" & d1; vd2 := d2;
    sum := vd1 + vd2;
    return sum;
  end function;
  
end package body;
