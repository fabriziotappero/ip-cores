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

entity OPB_USBLITE is
  generic (
    C_OPB_AWIDTH : integer                   := 32;
    C_OPB_DWIDTH : integer                   := 32;
    C_BASEADDR   : std_logic_vector(0 to 31) := X"FFFF_0000";
    C_HIGHADDR   : std_logic_vector          := X"FFFF_00FF";
    C_SYSRST  :       std_logic := '1';  -- enable external reset
    C_PHYMODE :       std_logic := '1';  -- phy mode
    C_VENDORID :      std_logic_vector(15 downto 0) := X"1234"; -- VID
    C_PRODUCTID :     std_logic_vector(15 downto 0) := X"5678"; -- PID
    C_VERSIONBCD :    std_logic_vector(15 downto 0) := X"0200"; -- device version
    C_SELFPOWERED :   boolean := false; -- self or bus powered
    C_RXBUFSIZE_BITS: integer range 7 to 12 := 10; -- size of rx buf (2^10 = 1024 bytes)
    C_TXBUFSIZE_BITS: integer range 7 to 12 := 10  -- size of tx buf (2^10 = 1024 bytes)
    );
  port (
    -- Global signals
    OPB_Clk : in std_logic;
    OPB_Rst : in std_logic;
    SYS_Rst : in std_logic;
    USB_Clk : in std_logic;
    -- OPB signals
    OPB_ABus    : in std_logic_vector(0 to 31);
    OPB_BE      : in std_logic_vector(0 to 3);
    OPB_RNW     : in std_logic;
    OPB_select  : in std_logic;
    OPB_seqAddr : in std_logic;
    OPB_DBus    : in std_logic_vector(0 to 31);
    Sl_DBus    : out std_logic_vector(0 to 31);
    Sl_errAck  : out std_logic;
    Sl_retry   : out std_logic;
    Sl_toutSup : out std_logic;
    Sl_xferAck : out std_logic;

    -- Interrupt
    Interrupt : out std_logic;

    -- USB signals
		txdp : out std_logic; -- connect to VPO
		txdn : out std_logic; -- connect to VMO/FSEO
		txoe : out std_logic; -- connect to OE
		rxd : in std_logic;   -- connect to RCV
		rxdp : in std_logic;  -- connect to VP
		rxdn : in std_logic   -- connect to VM
    );

end entity OPB_USBLITE;

library Common_v1_00_a;
use Common_v1_00_a.pselect;

library unisim;
use unisim.all;

library opb_usblite_v1_00_a;
use opb_usblite_v1_00_a.opb_usblite_core;

architecture akre of OPB_USBLITE is

  component pselect is
    generic (
      C_AB  : integer;
      C_AW  : integer;
      C_BAR : std_logic_vector);
    port (
      A      : in  std_logic_vector(0 to C_AW-1);
      AValid : in  std_logic;
      ps     : out std_logic);
  end component pselect;

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

  function nbits (x, y : std_logic_vector(0 to C_OPB_AWIDTH-1)) return integer is
  begin
    for i in 0 to C_OPB_AWIDTH-1 loop
      if x(i) /= y(i) then 
        return i;
      end if;
    end loop;
    return(C_OPB_AWIDTH);
  end function nbits;

  constant C_NBITS : integer := nbits(C_HIGHADDR, C_BASEADDR);

  signal OPB_CS : std_logic;
  signal core_rst : std_logic;
  
begin  -- architecture akre


  -----------------------------------------------------------------------------
  -- OPB bus interface
  -----------------------------------------------------------------------------

  -- Do the OPB address decoding
  pselect_I : pselect
    generic map (
      C_AB  => C_NBITS,
      C_AW  => C_OPB_AWIDTH,
      C_BAR => C_BASEADDR)
    port map (
      A      => OPB_ABus,
      AValid => OPB_select,
      ps     => OPB_CS);


  Sl_errAck                    <= '0';
  Sl_retry                     <= '0';
  Sl_toutSup                   <= '0';
  Sl_DBus(0 to 23)             <= (others=>'0');

  -----------------------------------------------------------------------------
  -- Instanciating the USB core
  -----------------------------------------------------------------------------
  
  core_rst <= SYS_Rst when C_SYSRST='1' else OPB_Rst;
  
  OPB_USBLITE_Core_inst : OPB_USBLITE_Core
  generic map (
    C_PHYMODE => C_PHYMODE,
    C_VENDORID => C_VENDORID,
    C_PRODUCTID => C_PRODUCTID,
    C_VERSIONBCD => C_VERSIONBCD,
    C_SELFPOWERED => C_SELFPOWERED,
    C_RXBUFSIZE_BITS => C_RXBUFSIZE_BITS,
    C_TXBUFSIZE_BITS => C_TXBUFSIZE_BITS
    )
  port map (
    Clk   => OPB_Clk,
    Reset => core_rst,
    Usb_Clk => USB_Clk,
    -- OPB signals
    OPB_CS => OPB_CS,
    OPB_ABus => OPB_ABus(28 to 29),
    OPB_RNW  => OPB_RNW,
    OPB_DBus => OPB_DBus(24 to 31),
    SIn_xferAck => Sl_xferAck,
    SIn_DBus    => Sl_DBus(24 to 31),
    Interrupt => Interrupt,
    -- USB signals
		txdp => txdp,
		txdn => txdn,
		txoe => txoe,
		rxd => rxd,
		rxdp => rxdp,
		rxdn => rxdn
		);

end architecture akre;
