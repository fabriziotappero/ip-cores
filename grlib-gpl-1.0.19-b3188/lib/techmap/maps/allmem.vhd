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
-- Package: 	allmem
-- File:	allmem.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	All tech specific memories
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package allmem is

-- AX & RTAX family

  component axcel_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic); 
  end component;

  component axcel_syncram_2p
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    rclk  : in std_ulogic;
    rena  : in std_ulogic;
    raddr : in std_logic_vector (abits -1 downto 0);
    dout  : out std_logic_vector (dbits -1 downto 0);
    wclk  : in std_ulogic;
    waddr : in std_logic_vector (abits -1 downto 0);
    din   : in std_logic_vector (dbits -1 downto 0);
    write : in std_ulogic);
  end component;

-- Proasic + Proasicplus family

  component proasic_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic); 
  end component;

  component proasic_syncram_2p
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    rclk  : in std_ulogic;
    rena  : in std_ulogic;
    raddr : in std_logic_vector (abits -1 downto 0);
    dout  : out std_logic_vector (dbits -1 downto 0);
    wclk  : in std_ulogic;
    waddr : in std_logic_vector (abits -1 downto 0);
    din   : in std_logic_vector (dbits -1 downto 0);
    write : in std_ulogic);
  end component;

-- Proasic3 family

  component proasic3_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic); 
  end component;

  component proasic3_syncram_2p
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    rclk  : in std_ulogic;
    rena  : in std_ulogic;
    raddr : in std_logic_vector (abits -1 downto 0);
    dout  : out std_logic_vector (dbits -1 downto 0);
    wclk  : in std_ulogic;
    waddr : in std_logic_vector (abits -1 downto 0);
    din   : in std_logic_vector (dbits -1 downto 0);
    write : in std_ulogic);
  end component;

  component proasic3_syncram_dp is
  generic ( abits : integer := 6; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   ); 
  end component;

component altera_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
   ); 
end component;

component altera_syncram_dp
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   ); 
end component;

component generic_syncram
  generic (abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    write    : in std_ulogic
   ); 
end component;

component generic_syncram_2p
  generic (abits : integer := 8; dbits : integer := 32; sepclk : integer := 0);
  port (
    rclk : in std_ulogic;
    wclk : in std_ulogic;
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    data: in std_logic_vector (dbits -1 downto 0);
    wren : in std_ulogic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
end component;

-- synchronous 3-port regfile (2 read, 1 write port)

  component generic_regfile_3p
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 32;
           wrfst : integer := 0; numregs : integer := 40);
  port (
    wclk   : in  std_ulogic;
    waddr  : in  std_logic_vector((abits -1) downto 0);
    wdata  : in  std_logic_vector((dbits -1) downto 0);
    we     : in  std_ulogic;
    rclk   : in  std_ulogic;
    raddr1 : in  std_logic_vector((abits -1) downto 0);
    re1    : in  std_ulogic;
    rdata1 : out std_logic_vector((dbits -1) downto 0);
    raddr2 : in  std_logic_vector((abits -1) downto 0);
    re2    : in  std_ulogic;
    rdata2 : out std_logic_vector((dbits -1) downto 0)
  );
  end component;

  component ihp25_syncram
    generic ( abits : integer := 10; dbits : integer := 8 );
    port (
      clk      : in std_logic;
      address  : in std_logic_vector(abits -1 downto 0);
      datain   : in std_logic_vector(dbits -1 downto 0);
      dataout  : out std_logic_vector(dbits -1 downto 0);
      enable   : in std_logic;
      write    : in std_logic
    );
  end component;

  component ec_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
   ); 
  end component;

  component ec_syncram_dp
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   ); 
  end component;

  component rh_lib18t_syncram_2p
  generic (abits : integer := 6; dbits : integer := 8);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    diagin   : in std_logic_vector(3 downto 0));
  end component;

  component rh_lib18t_syncram is
  generic (abits : integer := 6; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic; 
    diagin   : in std_logic_vector(1 downto 0) := "00");
  end component;

  component umc_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector(abits -1 downto 0);
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic);
  end component;

  component rhumc_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector(abits -1 downto 0);
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic);
  end component;

  component virage_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector(abits -1 downto 0);
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic);
  end component;

  component virage_syncram_dp
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic); 
  end component;

  component virage90_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector(abits -1 downto 0);
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic);
  end component;  
  
  component virtex_syncram
  generic ( abits : integer := 6; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
   ); 
  end component;

  component virtex_syncram_dp
  generic ( abits : integer := 6; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   ); 
  end component;

  component virtex2_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
   ); 
  end component;

  component virtex2_syncram_dp
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   ); 
  end component;

  component virage90_syncram_dp 
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   );
  end component;
  
  component virtex2_syncram64
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (63 downto 0);
    dataout : out std_logic_vector (63 downto 0);
    enable  : in  std_logic_vector (1 downto 0);
    write   : in  std_logic_vector (1 downto 0)
  );
  end component;

  component ut025crh_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
   ); 
  end component;

  component ut025crh_syncram_2p
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    rclk  : in std_ulogic;
    rena  : in std_ulogic;
    raddr : in std_logic_vector (abits -1 downto 0);
    dout  : out std_logic_vector (dbits -1 downto 0);
    wclk  : in std_ulogic;
    waddr : in std_logic_vector (abits -1 downto 0);
    din   : in std_logic_vector (dbits -1 downto 0);
    write : in std_ulogic);
  end component;

  component peregrine_regfile_3p
  generic (abits : integer := 6; dbits : integer := 32);
  port (
    wclk   : in  std_ulogic;
    waddr  : in  std_logic_vector((abits -1) downto 0);
    wdata  : in  std_logic_vector((dbits -1) downto 0);
    we     : in  std_ulogic;
    raddr1 : in  std_logic_vector((abits -1) downto 0);
    re1    : in  std_ulogic;
    rdata1 : out std_logic_vector((dbits -1) downto 0);
    raddr2 : in  std_logic_vector((abits -1) downto 0);
    re2    : in  std_ulogic;
    rdata2 : out std_logic_vector((dbits -1) downto 0));
  end component;

  component eclipse_syncram_2p is
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    rclk  : in std_ulogic;
    rena  : in std_ulogic;
    raddr : in std_logic_vector (abits -1 downto 0);
    dout  : out std_logic_vector (dbits -1 downto 0);
    wclk  : in std_ulogic;
    waddr : in std_logic_vector (abits -1 downto 0);
    din   : in std_logic_vector (dbits -1 downto 0);
    write : in std_ulogic);
  end component;

  component nextreme_syncram_2p is
  generic (abits : integer := 6; dbits : integer := 8);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0));
  end component;

  component custom1_syncram_2p is
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0));
  end component;

  component artisan_syncram_2p is
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0));
  end component;

  component ihp25rh_syncram
    generic ( abits : integer := 10; dbits : integer := 8 );
    port (
      clk      : in std_logic;
      address  : in std_logic_vector(abits -1 downto 0);
      datain   : in std_logic_vector(dbits -1 downto 0);
      dataout  : out std_logic_vector(dbits -1 downto 0);
      enable   : in std_logic;
      write    : in std_logic);
  end component;

  component peregrine_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
   ); 
  end component;

  component artisan_syncram
  generic ( abits : integer := 10; dbits : integer := 32 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
   ); 
  end component;

  component custom1_syncram
  generic ( abits : integer := 10; dbits : integer := 32 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
   ); 
  end component;

  component nextreme_syncram 
  generic (abits : integer := 6; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic); 
  end component;

  component virtex2_syncram_2p is
  generic (abits : integer := 6; dbits : integer := 8; sepclk : integer := 0;
	wrfst : integer := 0);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0));
  end component;

  component virage_syncram_2p
  generic (abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0));
  end component;

  component atc18rha_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector(abits -1 downto 0);
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic;
    testin   : in std_logic_vector(3 downto 0));
  end component;

  component atc18rha_syncram_dp
  generic ( abits : integer := 10; dbits : integer := 8);
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic;
    testin   : in std_logic_vector(3 downto 0));
  end component;

  component atc18rha_syncram_2p
  generic ( abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    testin   : in std_logic_vector(3 downto 0));
  end component;

  component artisan_syncram_dp
  generic ( abits : integer := 10; dbits : integer := 32 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   );
  end component;

end;
