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
-- Entity:      net
-- File:        net.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: Package with component and type declarations for network cores
------------------------------------------------------------------------------
  
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;

package net is

  type eth_in_type is record
    gtx_clk    : std_ulogic;                     
    rmii_clk   : std_ulogic;
    tx_clk     : std_ulogic;
    rx_clk     : std_ulogic;
    rxd        : std_logic_vector(7 downto 0);   
    rx_dv      : std_ulogic; 
    rx_er      : std_ulogic; 
    rx_col     : std_ulogic;
    rx_crs     : std_ulogic;
    mdio_i     : std_ulogic;
    phyrstaddr : std_logic_vector(4 downto 0);
    edcladdr   : std_logic_vector(3 downto 0);   
  end record;

  type eth_out_type is record
    reset   : std_ulogic;
    txd     : std_logic_vector(7 downto 0);   
    tx_en   : std_ulogic; 
    tx_er   : std_ulogic; 
    mdc     : std_ulogic;    
    mdio_o  : std_ulogic; 
    mdio_oe : std_ulogic;
  end record;
     
  component eth_arb
    generic(
      fullduplex : integer := 0;
      mdiomaster : integer := 0);
    port(
      rst   : in std_logic;
      clk   : in std_logic; 
      ethi  : in eth_in_type;
      etho  : out eth_out_type;
      methi : in eth_out_type;
      metho : out eth_in_type; 
      dethi : in eth_out_type;
      detho : out eth_in_type
      );
  end component;


  component greth is
    generic(
      hindex         : integer := 0;
      pindex         : integer := 0;
      paddr          : integer := 0;
      pmask          : integer := 16#FFF#;
      pirq           : integer := 0;
      memtech        : integer := 0;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      mdcscaler      : integer range 0 to 255 := 25; 
      enable_mdio    : integer range 0 to 1 := 0;
      fifosize       : integer range 4 to 512 := 8;
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 2 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 32 := 0;
      rmii           : integer range 0 to 1  := 0; 
      oepol          : integer range 0 to 1  := 0; 
      scanen         : integer range 0 to 1  := 0;
      ft             : integer range 0 to 1  := 0); 
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

  component greth_gbit is
    generic(
      hindex         : integer := 0;
      pindex         : integer := 0;
      paddr          : integer := 0;
      pmask          : integer := 16#FFF#;
      pirq           : integer := 0;
      memtech        : integer := 0;
      ifg_gap        : integer := 24; 
      attempt_limit  : integer := 16;
      backoff_limit  : integer := 10;
      slot_time      : integer := 128;
      mdcscaler      : integer range 0 to 255 := 25; 
      nsync          : integer range 1 to 2 := 2;
      edcl           : integer range 0 to 1 := 0;
      edclbufsz      : integer range 1 to 64 := 1;
      burstlength    : integer range 4 to 128 := 32;
      macaddrh       : integer := 16#00005E#;
      macaddrl       : integer := 16#000000#;
      ipaddrh        : integer := 16#c0a8#;
      ipaddrl        : integer := 16#0035#;
      phyrstadr      : integer range 0 to 32 := 0;
      sim            : integer range 0 to 1 := 0;
      oepol          : integer range 0 to 1  := 0; 
      scanen         : integer range 0 to 1  := 0); 
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

  component grethm
  generic(
    hindex         : integer := 0;
    pindex         : integer := 0;
    paddr          : integer := 0;
    pmask          : integer := 16#FFF#;
    pirq           : integer := 0;
    memtech        : integer := 0;
    ifg_gap        : integer := 24; 
    attempt_limit  : integer := 16;
    backoff_limit  : integer := 10;
    slot_time      : integer := 128;
    mdcscaler      : integer range 0 to 255 := 25; 
    enable_mdio    : integer range 0 to 1 := 0;
    fifosize       : integer range 4 to 64 := 8;
    nsync          : integer range 1 to 2 := 2;
    edcl           : integer range 0 to 2 := 0;
    edclbufsz      : integer range 1 to 64 := 1;
    burstlength    : integer range 4 to 128 := 32;
    macaddrh       : integer := 16#00005E#;
    macaddrl       : integer := 16#000000#;
    ipaddrh        : integer := 16#c0a8#;
    ipaddrl        : integer := 16#0035#;
    phyrstadr      : integer range 0 to 32 := 0;
    rmii           : integer range 0 to 1 := 0;
    sim            : integer range 0 to 1 := 0;
    giga           : integer range 0 to 1  := 0;
    oepol          : integer range 0 to 1  := 0;
    scanen         : integer range 0 to 1  := 0); 
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

end;
