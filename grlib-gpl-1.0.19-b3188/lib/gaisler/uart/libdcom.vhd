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
-----------------------------------------------------------------------------
-- Package: 	libdcom
-- File:	libdcom.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Types, functions and components for DSU uart
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.uart.all;
use gaisler.misc.all;

package libdcom is

type dcom_uart_in_type is record
  read    	: std_ulogic;
  write   	: std_ulogic;
  data		: std_logic_vector(7 downto 0);
end record;

type dcom_uart_out_type is record
  dready 	: std_ulogic;
  tsempty	: std_ulogic;
  thempty	: std_ulogic;
  lock    	: std_ulogic;
  enable 	: std_ulogic;
  data		: std_logic_vector(7 downto 0);
end record;

component dcom_uart
  generic (
    pindex : integer := 0;
    paddr  : integer := 0;
    pmask  : integer := 16#fff#
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ui     : in  uart_in_type;
    uo     : out uart_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    uarti  : in  dcom_uart_in_type;
    uarto  : out dcom_uart_out_type
  );
end component; 

component dcom
   port (
      rst   : in  std_ulogic;
      clk   : in  std_ulogic;
      dmai   : out ahb_dma_in_type;
      dmao   : in  ahb_dma_out_type;
      uarti  : out dcom_uart_in_type;
      uarto  : in  dcom_uart_out_type;
      ahbi   : in  ahb_mst_in_type
      );
end component;      


-- pragma translate_off

  procedure rxc(signal rxd : in std_logic; d: out std_logic_vector;
		txperiod : time);

  procedure rxi(signal rxd : in std_logic; d: out std_logic_vector;
		txperiod : time; lresp : boolean);

  procedure txc(signal txd : out std_logic; td : integer;
		txperiod : time);

  procedure txa(signal txd : out std_logic; td1, td2, td3, td4 : integer;
		txperiod : time);

  procedure txi(signal rxd : in std_logic; signal txd : out std_logic; 
		td1, td2, td3, td4 : integer; txperiod : time;
		lresp : boolean);

-- pragma translate_on

end;

-- pragma translate_off

package body libdcom is

  procedure rxc(signal rxd : in std_logic; d: out std_logic_vector;
		txperiod : time) is
    variable rxdata : std_logic_vector(7 downto 0);
  begin
    wait until rxd = '0'; wait for TXPERIOD/2;
    for i in 0 to 7 loop wait for TXPERIOD; rxdata(i):= rxd; end loop;
    wait for TXPERIOD ; 
    d := rxdata;
  end;

  procedure rxi(signal rxd : in std_logic; d: out std_logic_vector;
		txperiod : time; lresp : boolean) is
    variable rxdata : std_logic_vector(31 downto 0);
    variable resp : std_logic_vector(7 downto 0);
  begin
    for i in 3 downto 0 loop 
      rxc(rxd, rxdata((i*8 +7) downto i*8), txperiod);
    end loop; 
    d := rxdata;
    if LRESP then 
      rxc(rxd, resp, txperiod);
--      print("RESP   : 0x" & tosth(resp));
    end if;
  end;

  procedure txc(signal txd : out std_logic; td : integer;
		txperiod : time) is
    variable txdata : std_logic_vector(10 downto 0);
  begin
    txdata := "11" & conv_std_logic_vector(td, 8) & '0';
    for i in 0 to 10 loop wait for TXPERIOD ; txd <= txdata(i); end loop;
  end;

  procedure txa(signal txd : out std_logic; td1, td2, td3, td4 : integer;
		txperiod : time) is
    variable txdata : std_logic_vector(43 downto 0);
  begin
    txdata := "11" & conv_std_logic_vector(td4, 8) & '0'
            & "11" & conv_std_logic_vector(td3, 8) & '0'
            & "11" & conv_std_logic_vector(td2, 8) & '0'
            & "11" & conv_std_logic_vector(td1, 8) & '0';
    for i in 0 to 43 loop wait for TXPERIOD ; txd <= txdata(i); end loop;
  end;

  procedure txi(signal rxd : in std_logic; signal txd : out std_logic; 
		td1, td2, td3, td4 : integer; txperiod : time;
		lresp : boolean) is
    variable txdata : std_logic_vector(43 downto 0);
  begin
    txdata := "11" & conv_std_logic_vector(td4, 8) & '0'
            & "11" & conv_std_logic_vector(td3, 8) & '0'
            & "11" & conv_std_logic_vector(td2, 8) & '0'
            & "11" & conv_std_logic_vector(td1, 8) & '0';
    for i in 0 to 43 loop wait for TXPERIOD ; txd <= txdata(i); end loop;
    if LRESP then
      rxc(rxd, txdata(7 downto 0), txperiod); 
--      print("RESP   : 0x" & tosth(txdata(7 downto 0)));
    end if;
  end;

end;

-- pragma translate_on
