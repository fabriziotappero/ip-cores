--------------------------------------------------------------------
--  Entity:         SPI_OC
--  File:           spi_oc.vhd
--  Author:         Thomas Ameseder, Gleichmann Electronics
--
--  Description:    VHDL wrapper for the Opencores SPI core with APB
--                  interface
--------------------------------------------------------------------
--  CVS Entries:
--  $Date: 2006/12/04 14:44:05 $
--  $Author: tame $
--  $Log: spi_oc.vhd,v $
--  Revision 1.3  2006/12/04 14:44:05  tame
--  Changed interrupt output to LEON from a level (that is active until it is reset) to
--  a short pulse.
--
--  Revision 1.1  2006/11/17 12:28:56  tame
--  Added SPI files: Simple SPI package and a wrapper for the (modified)
--  OpenCores Simple SPI Core with APB interface.
--
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library opencores;
use opencores.occomp.all;

library gleichmann;
use gleichmann.sspi.all;

--  pragma translate_off
use std.textio.all;
--  pragma translate_on


entity spi_oc is
  generic (
    pindex : integer := 0;              -- Leon-Index
    paddr  : integer := 0;              -- Leon-Address
    pmask  : integer := 16#FFF#;        -- Leon-Mask
    pirq   : integer := 0               -- Leon-IRQ
    );
  port (
    rstn    : in  std_ulogic;           -- global Reset, active low
    clk     : in  std_ulogic;           -- global Clock
    apbi    : in  apb_slv_in_type;      -- APB-Input
    apbo    : out apb_slv_out_type;     -- APB-Output
    spi_in  : in  sspi_in_type;          -- MultIO-Inputs
    spi_out : out sspi_out_type          -- Spi-Outputs
    );
end entity spi_oc;


architecture implementation of spi_oc is

  constant data_width    : integer := 8;
  constant address_width : integer := 3;
  constant REVISION      : integer := 0;

  constant pconfig : apb_config_type := (
    0 => ahb_device_reg (VENDOR_GLEICHMANN, GLEICHMANN_SPIOC, 0, REVISION, pirq),
    1 => apb_iobar(paddr, pmask)
    );

  signal irq       : std_ulogic;
  signal irq_1t    : std_ulogic;
  signal irq_adapt : std_ulogic;        -- registered and converted to rising edge activity

begin

  simple_spi_top_1 : simple_spi_top
    port map (
      prdata_o  => apbo.prdata(data_width-1 downto 0),
      pirq_o    => irq,
      sck_o     => spi_out.sck,
      mosi_o    => spi_out.mosi,
      ssn_o     => spi_out.ssn,
      pclk_i    => clk,
      prst_i    => rstn,
      psel_i    => apbi.psel(pindex),
      penable_i => apbi.penable,
      paddr_i   => apbi.paddr(address_width+1 downto 2),  -- 32-bit addresses
      pwrite_i  => apbi.pwrite,
      pwdata_i  => apbi.pwdata(data_width-1 downto 0),
      miso_i    => spi_in.miso);

  -- drive selected interrupt, remaining bits with zeroes
  apbo.pirq(NAHBIRQ-1 downto pirq+1) <= (others => '0');
  -- apbo.pirq(pirq)                    <= irq;  -- corrected by MH, 28.11.2006
  apbo.pirq(pirq)                    <= irq_adapt;
  apbo.pirq(pirq-1 downto 0)         <= (others => '0');

  -- drive unused data bits with don't cares
  apbo.prdata(31 downto data_width) <= (others => '0');
  -- drive index for diagnostic use
  apbo.pindex                       <= pindex;
  -- drive slave configuration
  apbo.pconfig                      <= pconfig;


  ---------------------------------------------------------------------------------------
  -- Synchronous process to convert the high level interrupt from the core to
  -- to an rising edge triggered interrupt to be suitable for the Leon IRQCTL
  --    asynchronous low active reset like the open core simple SPI module !!!
  ---------------------------------------------------------------------------------------
  irq_adaption: process (clk, rstn)  -- added by MH, 28.11.2006
  begin  -- process irq_adaption)
    if rstn = '0' then
      irq_adapt <= '0';
      irq_1t    <= '0';
    elsif clk'event and clk = '1' then
      irq_1t    <= irq;
      irq_adapt <= irq and not irq_1t;
    end if;
  end process irq_adaption;




  ---------------------------------------------------------------------------------------
  -- DEBUG SECTION
  ---------------------------------------------------------------------------------------

--  pragma translate_off
  assert (pirq < 15 and pirq > 0 ) report
    "Simple SPI Controller interrupt warning: " &
    "0 does not exist, 15 is unmaskable, 16 to 31 are unused"
    severity warning;

  bootmsg : report_version
    generic map ("SPI_OC: Simple SPI Controller rev " & tost(REVISION) &
                 ", IRQ " & tost(pirq) &
                 ", APB slave " & tost(pindex));
--  pragma translate_on

end architecture implementation;
