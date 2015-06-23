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

library ieee;
use ieee.std_logic_1164.all;
library gaisler;
use gaisler.net.all;
library grlib;
use grlib.amba.all;
library techmap;
use techmap.gencomp.all;

package ethernet_mac is
  type eth_tx_in_type is record
    start          : std_ulogic;
    valid          : std_ulogic;
    data           : std_logic_vector(31 downto 0);
    full_duplex    : std_ulogic;
    length         : std_logic_vector(10 downto 0);
    col            : std_ulogic;
    crs            : std_ulogic;
    read_ack       : std_ulogic;
  end record;
  
  type eth_tx_out_type is record
    status         : std_logic_vector(1 downto 0);
    done           : std_ulogic;
    restart        : std_ulogic;
    read           : std_ulogic;
    tx_er          : std_ulogic;
    tx_en          : std_ulogic;
    txd            : std_logic_vector(3 downto 0);
  end record; 

  type eth_rx_in_type is record
    writeok        : std_ulogic;
    rxen           : std_ulogic;
    rx_dv          : std_ulogic;
    rx_er          : std_ulogic;
    rxd            : std_logic_vector(3 downto 0);
    done_ack       : std_ulogic;
    write_ack      : std_ulogic; 
  end record;

  type eth_rx_out_type is record
    write          : std_ulogic;
    data           : std_logic_vector(31 downto 0);
    done           : std_ulogic;
    length         : std_logic_vector(10 downto 0);
    status         : std_logic_vector(2 downto 0);
    start          : std_ulogic; 
  end record;

  type eth_mdio_in_type is record
    mdioi          : std_ulogic; 
    write          : std_ulogic;
    read           : std_ulogic;
    mdiostart      : std_ulogic;
    regadr         : std_logic_vector(4 downto 0);
    phyadr         : std_logic_vector(4 downto 0);
    data           : std_logic_vector(15 downto 0);
  end record;

  type eth_mdio_out_type is record
    mdc            : std_ulogic;
    mdioo          : std_ulogic;
    mdioen         : std_ulogic;
    data           : std_logic_vector(15 downto 0);
    done           : std_ulogic;
    error          : std_ulogic; 
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

  component eth_ahb_mst is
    generic(
      hindex      : integer := 0;
      revision    : integer := 0;
      irq         : integer := 0);
    port(
      rst     : in  std_ulogic;
      clk     : in  std_ulogic;
      ahbmi   : in  ahb_mst_in_type;
      ahbmo   : out ahb_mst_out_type;
      tmsti   : in  eth_tx_ahb_in_type;
      tmsto   : out eth_tx_ahb_out_type;
      rmsti   : in  eth_rx_ahb_in_type;
      rmsto   : out eth_rx_ahb_out_type
    );
  end component;

  component eth_ahb_mst_gbit is
    generic(
      hindex      : integer := 0;
      revision    : integer := 0;
      irq         : integer := 0);
    port(
      rst     : in  std_ulogic;
      clk     : in  std_ulogic;
      ahbmi   : in  ahb_mst_in_type;
      ahbmo   : out ahb_mst_out_type;
      tmsti   : in  eth_tx_ahb_in_type;
      tmsto   : out eth_tx_ahb_out_type;
      rmsti   : in  eth_rx_gbit_ahb_in_type;
      rmsto   : out eth_rx_ahb_out_type
    );
  end component;

  component greth is
    generic(
      hindex         : integer := 0;
      pindex         : integer := 0;
      paddr          : integer := 0;
      pmask          : integer := 16#FFF#;
      pirq           : integer := 0;
      memtech        : integer := inferred;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      mdcscaler      : integer range 0 to 255 := 25; 
      enable_mdio    : integer range 0 to 1 := 0;
      fifosize       : integer range 4 to 512 := 8;
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 1 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer := 0); 
    port(
      rst            : in  std_ulogic;
      clk            : in  std_ulogic;
      ahbmi          : in  ahb_mst_in_type;
      ahbmo          : out ahb_mst_out_type;
      apbi           : in  apb_slv_in_type;
      apbo           : out apb_slv_out_type;
      ethi           : in  eth_in_type;
      etho           : out eth_out_type
    );
  end component;
end package;
