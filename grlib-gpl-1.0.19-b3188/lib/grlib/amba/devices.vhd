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
-- Entity: 	devices
-- File:	devices.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Vendor and devices id's for amba plug&play
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on

package devices is

-- Vendor codes

  constant VENDOR_GAISLER    : amba_vendor_type := 16#01#;
  constant VENDOR_PENDER     : amba_vendor_type := 16#02#;
  constant VENDOR_ESA        : amba_vendor_type := 16#04#;
  constant VENDOR_ASTRIUM    : amba_vendor_type := 16#06#;
  constant VENDOR_OPENCHIP   : amba_vendor_type := 16#07#;
  constant VENDOR_OPENCORES  : amba_vendor_type := 16#08#;
  constant VENDOR_CONTRIB    : amba_vendor_type := 16#09#;
  constant VENDOR_EONIC      : amba_vendor_type := 16#0B#;
  constant VENDOR_RADIONOR   : amba_vendor_type := 16#0F#;
  constant VENDOR_GLEICHMANN : amba_vendor_type := 16#10#;
  constant VENDOR_MENTA      : amba_vendor_type := 16#11#;
  constant VENDOR_SUN        : amba_vendor_type := 16#13#;
  constant VENDOR_MOVIDIA    : amba_vendor_type := 16#14#;
  constant VENDOR_ORBITA     : amba_vendor_type := 16#17#;
  constant VENDOR_SYNOPSYS   : amba_vendor_type := 16#21#;
  constant VENDOR_NASA       : amba_vendor_type := 16#22#;
  constant VENDOR_CAL        : amba_vendor_type := 16#CA#;
  constant VENDOR_EMBEDDIT   : amba_vendor_type := 16#EA#;
  constant VENDOR_CETON      : amba_vendor_type := 16#CB#;
  constant VENDOR_ACTEL      : amba_vendor_type := 16#AC#;

-- Gaisler Research device id's

  constant GAISLER_LEON2DSU  : amba_device_type := 16#002#;
  constant GAISLER_LEON3     : amba_device_type := 16#003#;
  constant GAISLER_LEON3DSU  : amba_device_type := 16#004#;
  constant GAISLER_ETHAHB    : amba_device_type := 16#005#;
  constant GAISLER_APBMST    : amba_device_type := 16#006#;
  constant GAISLER_AHBUART   : amba_device_type := 16#007#;
  constant GAISLER_SRCTRL    : amba_device_type := 16#008#;
  constant GAISLER_SDCTRL    : amba_device_type := 16#009#;
  constant GAISLER_SSRCTRL   : amba_device_type := 16#00A#;
  constant GAISLER_APBUART   : amba_device_type := 16#00C#;
  constant GAISLER_IRQMP     : amba_device_type := 16#00D#;
  constant GAISLER_AHBRAM    : amba_device_type := 16#00E#;
  constant GAISLER_GPTIMER   : amba_device_type := 16#011#;
  constant GAISLER_PCITRG    : amba_device_type := 16#012#;
  constant GAISLER_PCISBRG   : amba_device_type := 16#013#;
  constant GAISLER_PCIFBRG   : amba_device_type := 16#014#;
  constant GAISLER_PCITRACE  : amba_device_type := 16#015#;
  constant GAISLER_DMACTRL   : amba_device_type := 16#016#;
  constant GAISLER_AHBTRACE  : amba_device_type := 16#017#;
  constant GAISLER_DSUCTRL   : amba_device_type := 16#018#;
  constant GAISLER_CANAHB    : amba_device_type := 16#019#;
  constant GAISLER_GPIO      : amba_device_type := 16#01A#;
  constant GAISLER_AHBROM    : amba_device_type := 16#01B#;
  constant GAISLER_AHBJTAG   : amba_device_type := 16#01C#;
  constant GAISLER_ETHMAC    : amba_device_type := 16#01D#;
  constant GAISLER_SWNODE    : amba_device_type := 16#01E#;
  constant GAISLER_SPW       : amba_device_type := 16#01F#;
  constant GAISLER_AHB2AHB   : amba_device_type := 16#020#;
  constant GAISLER_USBDC     : amba_device_type := 16#021#;
  constant GAISLER_USB_DCL   : amba_device_type := 16#022#;
  constant GAISLER_DDRMP     : amba_device_type := 16#023#;
  constant GAISLER_ATACTRL   : amba_device_type := 16#024#;
  constant GAISLER_DDRSP     : amba_device_type := 16#025#;
  constant GAISLER_EHCI      : amba_device_type := 16#026#;
  constant GAISLER_UHCI      : amba_device_type := 16#027#;
  constant GAISLER_I2CMST    : amba_device_type := 16#028#;
  constant GAISLER_SPW2      : amba_device_type := 16#029#;
  constant GAISLER_AHBDMA    : amba_device_type := 16#02A#;
  constant GAISLER_NUHOSP3   : amba_device_type := 16#02B#;
  constant GAISLER_CLKGATE   : amba_device_type := 16#02C#;
  constant GAISLER_SPICTRL   : amba_device_type := 16#02D#;
  constant GAISLER_DDR2SP    : amba_device_type := 16#02E#;
  constant GAISLER_SLINK     : amba_device_type := 16#02F#;
  constant GAISLER_GRTM      : amba_device_type := 16#030#;
  constant GAISLER_GRTC      : amba_device_type := 16#031#;
  constant GAISLER_GRPW      : amba_device_type := 16#032#;
  constant GAISLER_GRCTM     : amba_device_type := 16#033#;
  constant GAISLER_GRHCAN    : amba_device_type := 16#034#;
  constant GAISLER_GRFIFO    : amba_device_type := 16#035#;
  constant GAISLER_GRADCDAC  : amba_device_type := 16#036#;
  constant GAISLER_GRPULSE   : amba_device_type := 16#037#;
  constant GAISLER_GRTIMER   : amba_device_type := 16#038#;
  constant GAISLER_AHB2PP    : amba_device_type := 16#039#;
  constant GAISLER_GRVERSION : amba_device_type := 16#03A#;
  constant GAISLER_APB2PW    : amba_device_type := 16#03B#;
  constant GAISLER_PW2APB    : amba_device_type := 16#03C#;
  constant GAISLER_GRCAN     : amba_device_type := 16#03D#;
  constant GAISLER_I2CSLV    : amba_device_type := 16#03E#;
  constant GAISLER_U16550    : amba_device_type := 16#03F#;
  constant GAISLER_AHBMST_EM : amba_device_type := 16#040#;
  constant GAISLER_AHBSLV_EM : amba_device_type := 16#041#;
  constant GAISLER_GRTESTMOD : amba_device_type := 16#042#;
  constant GAISLER_ASCS      : amba_device_type := 16#043#;
  constant GAISLER_IPMVBCTRL : amba_device_type := 16#044#;
  constant GAISLER_SPIMCTRL  : amba_device_type := 16#045#;
  constant GAISLER_LEON4     : amba_device_type := 16#048#;
  constant GAISLER_LEON4DSU  : amba_device_type := 16#049#;

  constant GAISLER_FTAHBRAM  : amba_device_type := 16#050#;
  constant GAISLER_FTSRCTRL  : amba_device_type := 16#051#;
  constant GAISLER_AHBSTAT   : amba_device_type := 16#052#;
  constant GAISLER_LEON3FT   : amba_device_type := 16#053#;
  constant GAISLER_FTMCTRL   : amba_device_type := 16#054#;
  constant GAISLER_FTSDCTRL  : amba_device_type := 16#055#;
  constant GAISLER_FTSRCTRL8 : amba_device_type := 16#056#;

  constant GAISLER_APBPS2    : amba_device_type := 16#060#;
  constant GAISLER_VGACTRL   : amba_device_type := 16#061#;
  constant GAISLER_LOGAN     : amba_device_type := 16#062#;
  constant GAISLER_SVGACTRL  : amba_device_type := 16#063#;
  constant GAISLER_T1AHB     : amba_device_type := 16#064#;
  constant GAISLER_MP7WRAP   : amba_device_type := 16#065#;

  constant GAISLER_B1553BC   : amba_device_type := 16#070#;
  constant GAISLER_B1553RT   : amba_device_type := 16#071#;
  constant GAISLER_B1553BRM  : amba_device_type := 16#072#;

  constant GAISLER_SATCAN    : amba_device_type := 16#080#;
  constant GAISLER_CANMUX    : amba_device_type := 16#081#;

  constant GAISLER_GRTMRX    : amba_device_type := 16#082#;
  constant GAISLER_GRTCTX    : amba_device_type := 16#083#;
  constant GAISLER_GRTMDESC  : amba_device_type := 16#084#;
  constant GAISLER_GRTMVC    : amba_device_type := 16#085#;

  constant GAISLER_AES       : amba_device_type := 16#073#;
  constant GAISLER_ECC       : amba_device_type := 16#074#;

  constant GAISLER_PCIF      : amba_device_type := 16#075#;

  constant GAISLER_CLKMOD    : amba_device_type := 16#076#;

  constant GAISLER_HAPSTRAK  : amba_device_type := 16#077#;
  constant GAISLER_TEST_1X2  : amba_device_type := 16#078#;
  constant GAISLER_WILD2AHB  : amba_device_type := 16#079#;
  constant GAISLER_BIO1      : amba_device_type := 16#07A#;

-- Sun Microsystems

  constant SUN_T1	      : amba_device_type := 16#001#;
  constant SUN_S1	      : amba_device_type := 16#011#;

-- Caltech

  constant CAL_DDRCTRL	      : amba_device_type := 16#188#;

-- European Space Agency device id's

  constant ESA_LEON2        : amba_device_type := 16#002#;
  constant ESA_LEON2APB     : amba_device_type := 16#003#;
  constant ESA_IRQ          : amba_device_type := 16#005#;
  constant ESA_TIMER        : amba_device_type := 16#006#;
  constant ESA_UART         : amba_device_type := 16#007#;
  constant ESA_CFG          : amba_device_type := 16#008#;
  constant ESA_IO           : amba_device_type := 16#009#;
  constant ESA_MCTRL        : amba_device_type := 16#00F#;
  constant ESA_PCIARB       : amba_device_type := 16#010#;
  constant ESA_HURRICANE    : amba_device_type := 16#011#;
  constant ESA_SPW_RMAP     : amba_device_type := 16#012#;
  constant ESA_AHBUART      : amba_device_type := 16#013#;
  constant ESA_SPWA         : amba_device_type := 16#014#;
  constant ESA_BOSCHCAN     : amba_device_type := 16#015#;
  constant ESA_IRQ2         : amba_device_type := 16#016#;
  constant ESA_AHBSTAT      : amba_device_type := 16#017#;
  constant ESA_WPROT        : amba_device_type := 16#018#;
  constant ESA_WPROT2       : amba_device_type := 16#019#;

  constant ESA_PDEC3AMBA    : amba_device_type := 16#020#;
  constant ESA_PTME3AMBA    : amba_device_type := 16#021#;

-- OpenChip ID's

  constant OPENCHIP_APBGPIO     : amba_device_type := 16#001#;
  constant OPENCHIP_APBI2C      : amba_device_type := 16#002#;
  constant OPENCHIP_APBSPI      : amba_device_type := 16#003#;
  constant OPENCHIP_APBCHARLCD  : amba_device_type := 16#004#;
  constant OPENCHIP_APBPWM      : amba_device_type := 16#005#;
  constant OPENCHIP_APBPS2      : amba_device_type := 16#006#;
  constant OPENCHIP_APBMMCSD    : amba_device_type := 16#007#;
  constant OPENCHIP_APBNAND     : amba_device_type := 16#008#;
  constant OPENCHIP_APBLPC      : amba_device_type := 16#009#;
  constant OPENCHIP_APBCF       : amba_device_type := 16#00A#;
  constant OPENCHIP_APBSYSACE   : amba_device_type := 16#00B#;
  constant OPENCHIP_APB1WIRE    : amba_device_type := 16#00C#;
  constant OPENCHIP_APBJTAG     : amba_device_type := 16#00D#;
  constant OPENCHIP_APBSUI      : amba_device_type := 16#00E#;


-- Gleichmann's device id's

  constant GLEICHMANN_CUSTOM   : amba_device_type := 16#001#;
  constant GLEICHMANN_GEOLCD01 : amba_device_type := 16#002#;
  constant GLEICHMANN_DAC      : amba_device_type := 16#003#;
  constant GLEICHMANN_HPI      : amba_device_type := 16#004#;
  constant GLEICHMANN_SPI      : amba_device_type := 16#005#;
  constant GLEICHMANN_HIFC     : amba_device_type := 16#006#;
  constant GLEICHMANN_ADCDAC   : amba_device_type := 16#007#;
  constant GLEICHMANN_SPIOC    : amba_device_type := 16#008#;
  constant GLEICHMANN_AC97     : amba_device_type := 16#009#;

-- Orbita device id's

  constant ORBITA_1553B        : amba_device_type := 16#001#;
  constant ORBITA_429          : amba_device_type := 16#002#;
  constant ORBITA_SPI          : amba_device_type := 16#003#;
  constant ORBITA_I2C          : amba_device_type := 16#004#;
  constant ORBITA_SMARTCARD    : amba_device_type := 16#064#;
  constant ORBITA_SDCARD       : amba_device_type := 16#065#;
  constant ORBITA_UART16550    : amba_device_type := 16#066#;
  constant ORBITA_CRYPTO       : amba_device_type := 16#067#;
  constant ORBITA_SYSIF        : amba_device_type := 16#068#;
  constant ORBITA_PIO          : amba_device_type := 16#069#;
  constant ORBITA_RTC          : amba_device_type := 16#0C8#;
  constant ORBITA_COLORLCD     : amba_device_type := 16#12C#;
  constant ORBITA_PCI          : amba_device_type := 16#190#;
  constant ORBITA_DSP          : amba_device_type := 16#1F4#;
  constant ORBITA_USBHOST      : amba_device_type := 16#258#;
  constant ORBITA_USBDEV       : amba_device_type := 16#2BC#;

-- Actel device ids

  constant ACTEL_COREMP7       : amba_device_type := 16#001#;

-- NASA device ids

  constant NASA_EP32           : amba_device_type := 16#001#;

-- Contribution library ID's

  constant CONTRIB_CORE1        : amba_device_type := 16#001#;
  constant CONTRIB_CORE2        : amba_device_type := 16#002#;

-- grlib system device id's

  subtype system_device_type  is integer range 0 to 16#ffff#;

  constant LEON3_RTAX_CID2      : system_device_type := 16#0202#;
  constant LEON3_RTAX_CID5      : system_device_type := 16#0205#;
  constant LEON3_RTAX_CID6      : system_device_type := 16#0206#;
  constant LEON3_RTAX_CID7      : system_device_type := 16#0207#;
  constant LEON3_RTAX_CID8      : system_device_type := 16#0208#;
  constant LEON3_IHP25RH1       : system_device_type := 16#0251#;
  constant LEON3FT_GRXC4V       : system_device_type := 16#0453#;
  constant XILINX_ML401         : system_device_type := 16#0401#;
  constant XILINX_ML501         : system_device_type := 16#0501#;
  constant XILINX_ML505         : system_device_type := 16#0505#;
  constant XILINX_ML506         : system_device_type := 16#0506#;
  constant XILINX_ML507         : system_device_type := 16#0507#;
  constant ORBITA_1             : system_device_type := 16#0631#;
  constant AEROFLEX_UT699       : system_device_type := 16#0699#;
  constant GAISLER_GR702        : system_device_type := 16#0702#;
  constant GAISLER_DARE1        : system_device_type := 16#0704#;
  constant GAISLER_GR712RC      : system_device_type := 16#0712#;

-- pragma translate_off

  constant GAISLER_DESC : vendor_description :=  "Gaisler Research        ";

  constant gaisler_device_table : device_table_type := (
   GAISLER_LEON2DSU  => "Leon2 Debug Support Unit       ",
   GAISLER_LEON3     => "Leon3 SPARC V8 Processor       ",
   GAISLER_LEON3DSU  => "Leon3 Debug Support Unit       ",
   GAISLER_ETHAHB    => "OC ethernet AHB interface      ",
   GAISLER_AHBRAM    => "Generic AHB SRAM module        ",
   GAISLER_APBMST    => "AHB/APB Bridge                 ",
   GAISLER_AHBUART   => "AHB Debug UART                 ",
   GAISLER_SRCTRL    => "Simple SRAM Controller         ",
   GAISLER_SDCTRL    => "PC133 SDRAM Controller         ",
   GAISLER_SSRCTRL   => "Synchronous SRAM Controller    ",
   GAISLER_APBUART   => "Generic UART                   ",
   GAISLER_IRQMP     => "Multi-processor Interrupt Ctrl.",
   GAISLER_GPTIMER   => "Modular Timer Unit             ",
   GAISLER_PCITRG    => "Simple 32-bit PCI Target       ",
   GAISLER_PCISBRG   => "Simple 32-bit PCI Bridge       ",
   GAISLER_PCIFBRG   => "Fast 32-bit PCI Bridge         ",
   GAISLER_PCITRACE  => "32-bit PCI Trace Buffer        ",
   GAISLER_DMACTRL   => "AMBA DMA controller            ",
   GAISLER_AHBTRACE  => "AMBA Trace Buffer              ",
   GAISLER_DSUCTRL   => "DSU/ETH controller             ",
   GAISLER_GRTM      => "CCSDS Telemetry Encoder        ",
   GAISLER_GRTC      => "CCSDS Telecommand Decoder      ",
   GAISLER_GRPW      => "PacketWire to AMBA AHB I/F     ",
   GAISLER_GRCTM     => "CCSDS Time Manager             ",
   GAISLER_GRHCAN    => "ESA HurriCANe CAN with DMA     ",
   GAISLER_GRFIFO    => "FIFO Controller                ",
   GAISLER_GRADCDAC  => "ADC / DAC Interface            ",
   GAISLER_GRPULSE   => "General Purpose I/O with Pulses",
   GAISLER_GRTIMER   => "Timer Unit with Latches        ",
   GAISLER_AHB2PP    => "AMBA AHB to Packet Parallel I/F",
   GAISLER_GRVERSION => "Version and Revision Register  ",
   GAISLER_APB2PW    => "PacketWire Transmit Interface  ",
   GAISLER_PW2APB    => "PacketWire Receive Interface   ",
   GAISLER_GRCAN     => "CAN Controller with DMA        ",
   GAISLER_AHBMST_EM => "AMBA Master Emulator           ",
   GAISLER_AHBSLV_EM => "AMBA Slave Emulator            ",
   GAISLER_CANAHB    => "OC CAN AHB interface           ",
   GAISLER_GPIO      => "General Purpose I/O port       ",
   GAISLER_AHBROM    => "Generic AHB ROM                ",
   GAISLER_AHB2AHB   => "AHB-to-AHB Bridge              ",
   GAISLER_NUHOSP3   => "Nuhorizons Spartan3 IO I/F     ",
   GAISLER_CLKGATE   => "Clock gating unit              ",
   GAISLER_FTAHBRAM  => "Generic FT AHB SRAM module     ",
   GAISLER_FTSRCTRL  => "Simple FT SRAM Controller      ",
   GAISLER_LEON3FT   => "Leon3-FT SPARC V8 Processor    ",
   GAISLER_FTMCTRL   => "Memory controller with EDAC    ",
   GAISLER_FTSDCTRL  => "FT PC133 SDRAM Controller      ",
   GAISLER_FTSRCTRL8 => "FT 8-bit SRAM/16-bit IO Ctrl   ",
   GAISLER_AHBSTAT   => "AHB Status Register            ",
   GAISLER_AHBJTAG   => "JTAG Debug Link                ",
   GAISLER_ETHMAC    => "GR Ethernet MAC                ",
   GAISLER_SWNODE    => "SpaceWire Node Interface       ",
   GAISLER_SPW       => "SpaceWire Serial Link          ",
   GAISLER_VGACTRL   => "VGA controller                 ",
   GAISLER_APBPS2    => "PS2 interface                  ",
   GAISLER_LOGAN     => "On chip Logic Analyzer         ",
   GAISLER_SVGACTRL  => "SVGA frame buffer              ",
   GAISLER_T1AHB     => "Niagara T1 PCX/AHB bridge      ",
   GAISLER_B1553BC   => "AMBA Wrapper for Core1553BBC   ",
   GAISLER_B1553RT   => "AMBA Wrapper for Core1553BRT   ",
   GAISLER_B1553BRM  => "AMBA Wrapper for Core1553BRM   ",
   GAISLER_SATCAN    => "SatCAN controller              ",
   GAISLER_CANMUX    => "CAN Bus multiplexer            ",
   GAISLER_GRTMRX    => "CCSDS Telemetry Receiver       ",
   GAISLER_GRTCTX    => "CCSDS Telecommand Transmitter  ",
   GAISLER_GRTMDESC  => "CCSDS Telemetry Descriptor     ",
   GAISLER_GRTMVC    => "CCSDS Telemetry VC Generator   ",
   GAISLER_AES       => "Advanced Encryption Standard   ",
   GAISLER_ECC       => "Elliptic Curve Cryptography    ",
   GAISLER_PCIF      => "AMBA Wrapper for CorePCIF      ",
   GAISLER_USBDC     => "GR USB 2.0 Device Controller   ",
   GAISLER_USB_DCL   => "USB Debug Communication Link   ",
   GAISLER_DDRMP     => "Multi-port DDR controller      ",
   GAISLER_ATACTRL   => "ATA controller                 ",
   GAISLER_DDRSP     => "Single-port DDR266 controller  ",
   GAISLER_EHCI      => "USB Enhanced Host Controller   ",
   GAISLER_UHCI      => "USB Universal Host Controller  ",
   GAISLER_I2CMST    => "AMBA Wrapper for OC I2C-master ",
   GAISLER_I2CSLV    => "I2C Slave                      ",
   GAISLER_U16550    => "Simple 16550 UART              ",
   GAISLER_SPICTRL   => "SPI Controller                 ",
   GAISLER_DDR2SP    => "Single-port DDR2 controller    ",
   GAISLER_GRTESTMOD => "Test report module             ",
   GAISLER_CLKMOD    => "CPU Clock Switching Ctrl module",
   GAISLER_SLINK     => "SLINK Master                   ",
   GAISLER_HAPSTRAK  => "HAPS HapsTrak I/O Port         ",
   GAISLER_TEST_1X2  => "HAPS TEST_1x2 interface        ",
   GAISLER_WILD2AHB  => "WildCard CardBus interface     ",
   GAISLER_BIO1      => "Basic I/O board BIO1           ",
   GAISLER_ASCS      => "ASCS Master                    ",
   GAISLER_SPW2      => "GRSPW2 SpaceWire Serial Link   ",
   GAISLER_IPMVBCTRL => "IPM-bus/MVBC memory controller ",
   GAISLER_SPIMCTRL  => "SPI Memory Controller          ",
   GAISLER_LEON4     => "Leon4 SPARC V8 Processor       ",
   GAISLER_LEON4DSU  => "Leon4 Debug Support Unit       ",
   GAISLER_MP7WRAP   => "CoreMP7 wrapper                ",
   others            => "Unknown Device                 ");

   constant gaisler_lib : vendor_library_type := (
     vendorid 	     => VENDOR_GAISLER,
     vendordesc      => GAISLER_DESC,
     device_table    => gaisler_device_table
   );

  constant ESA_DESC : vendor_description := "European Space Agency   ";

  constant esa_device_table : device_table_type := (
   ESA_LEON2        => "Leon2 SPARC V8 Processor       ",
   ESA_LEON2APB     => "Leon2 Peripheral Bus           ",
   ESA_IRQ          => "Leon2 Interrupt Controller     ",
   ESA_TIMER        => "Leon2 Timer                    ",
   ESA_UART         => "Leon2 UART                     ",
   ESA_CFG          => "Leon2 Configuration Register   ",
   ESA_IO           => "Leon2 Input/Output             ",
   ESA_MCTRL        => "Leon2 Memory Controller        ",
   ESA_PCIARB       => "PCI Arbiter                    ",
   ESA_HURRICANE    => "HurriCANe/HurryAMBA CAN Ctrl   ",
   ESA_SPW_RMAP     => "UoD/Saab SpaceWire/RMAP link   ",
   ESA_AHBUART      => "Leon2 AHB Debug UART           ",
   ESA_SPWA         => "ESA/ASTRIUM SpaceWire link     ",
   ESA_BOSCHCAN     => "SSC/BOSCH CAN Ctrl             ",
   ESA_IRQ2         => "Leon2 Secondary Irq Controller ",
   ESA_AHBSTAT      => "Leon2 AHB Status Register      ",
   ESA_WPROT        => "Leon2 Write Protection         ",
   ESA_WPROT2       => "Leon2 Extended Write Protection",
   ESA_PDEC3AMBA    => "ESA CCSDS PDEC3AMBA TC Decoder ",
   ESA_PTME3AMBA    => "ESA CCSDS PTME3AMBA TM Encoder ",
   others           => "Unknown Device                 ");

   constant esa_lib : vendor_library_type := (
     vendorid       => VENDOR_ESA,
     vendordesc     => ESA_DESC,
     device_table   => esa_device_table
   );

  constant OPENCHIP_DESC : vendor_description := "OpenChip                ";

  constant openchip_device_table : device_table_type := (
    OPENCHIP_APBGPIO    => "APB General Purpose IO         ",
    OPENCHIP_APBI2C     => "APB I2C Interface              ",
    OPENCHIP_APBSPI     => "APB SPI Interface              ",
    OPENCHIP_APBCHARLCD => "APB Character LCD              ",
    OPENCHIP_APBPWM     => "APB PWM                        ",
    OPENCHIP_APBPS2     => "APB PS/2 Interface             ",
    OPENCHIP_APBMMCSD   => "APB MMC/SD Card Interface      ",
    OPENCHIP_APBNAND    => "APB NAND(SmartMedia) Interface ",
    OPENCHIP_APBLPC     => "APB LPC Interface              ",
    OPENCHIP_APBCF      => "APB CompactFlash (IDE)         ",
    OPENCHIP_APBSYSACE  => "APB SystemACE Interface        ",
    OPENCHIP_APB1WIRE   => "APB 1-Wire Interface           ",
    OPENCHIP_APBJTAG    => "APB JTAG TAP Master            ",
    OPENCHIP_APBSUI     => "APB Simple User Interface      ",

    others              => "Unknown Device                 ");

  constant openchip_lib : vendor_library_type := (
    vendorid 	        => VENDOR_OPENCHIP,
    vendordesc          => OPENCHIP_DESC,
    device_table        => openchip_device_table
  );

  constant GLEICHMANN_DESC : vendor_description := "Gleichmann Electronics  ";

  constant gleichmann_device_table : device_table_type := (
    GLEICHMANN_CUSTOM   => "Custom device                  ",
    GLEICHMANN_GEOLCD01 => "GEOLCD01 graphics system       ",
    GLEICHMANN_DAC      => "Sigma delta DAC                ",
    GLEICHMANN_HPI      => "AHB-to-HPI bridge              ",
    GLEICHMANN_SPI      => "SPI master                     ",
    GLEICHMANN_HIFC     => "Human interface controller     ",
    GLEICHMANN_ADCDAC   => "Sigma delta ADC/DAC            ",
    GLEICHMANN_SPIOC	=> "SPI master for SDCard IF       ",
    GLEICHMANN_AC97	=> "AC97 Controller                ",
    others              => "Unknown Device                 ");

  constant gleichmann_lib : vendor_library_type := (
    vendorid     => VENDOR_GLEICHMANN,
    vendordesc   => GLEICHMANN_DESC,
    device_table => gleichmann_device_table
    );

  constant CONTRIB_DESC : vendor_description := "Various contributions   ";

  constant contrib_device_table : device_table_type := (
   CONTRIB_CORE1    => "Contributed core 1             ",
   CONTRIB_CORE2    => "Contributed core 2             ",
   others           => "Unknown Device                 ");

   constant contrib_lib : vendor_library_type := (
     vendorid 	     => VENDOR_CONTRIB,
     vendordesc      => CONTRIB_DESC,
     device_table    => contrib_device_table
   );

  constant MENTA_DESC : vendor_description :=  "Menta                   ";

  constant menta_device_table : device_table_type := (
   others              => "Unknown Device                 ");

   constant menta_lib : vendor_library_type := (
     vendorid 	       => VENDOR_MENTA,
     vendordesc        => MENTA_DESC,
     device_table      => menta_device_table
   );

  constant SUN_DESC : vendor_description := "Sun Microsystems        ";

  constant sun_device_table : device_table_type := (
   SUN_T1           => "Niagara T1 SPARC V9 Processor  ",
   SUN_S1           => "Niagara S1 SPARC V9 Processor  ",
   others           => "Unknown Device                 ");

   constant sun_lib : vendor_library_type := (
     vendorid 	       => VENDOR_SUN,
     vendordesc        => SUN_DESC,
     device_table      => sun_device_table
   );

  constant OPENCORES_DESC : vendor_description :=  "OpenCores               ";

  constant opencores_device_table : device_table_type := (
   others              => "Unknown Device                 ");

   constant opencores_lib : vendor_library_type := (
     vendorid 	       => VENDOR_OPENCORES,
     vendordesc        => OPENCORES_DESC,
     device_table      => opencores_device_table
   );

  constant CETON_DESC : vendor_description :=  "Ceton Corporation       ";

  constant ceton_device_table : device_table_type := (
   others              => "Unknown Device                 ");

   constant ceton_lib : vendor_library_type := (
     vendorid 	       => VENDOR_CETON,
     vendordesc        => CETON_DESC,
     device_table      => ceton_device_table
   );

  constant SYNOPSYS_DESC : vendor_description :=  "Synopsys Inc.           ";

  constant synopsys_device_table : device_table_type := (
   others              => "Unknown Device                 ");

   constant synopsys_lib : vendor_library_type := (
     vendorid 	       => VENDOR_SYNOPSYS,
     vendordesc        => SYNOPSYS_DESC,
     device_table      => synopsys_device_table
   );

  constant EMBEDDIT_DESC : vendor_description :=  "Embedd.it               ";

  constant embeddit_device_table : device_table_type := (
   others              => "Unknown Device                 ");

   constant embeddit_lib : vendor_library_type := (
     vendorid 	       => VENDOR_EMBEDDIT,
     vendordesc        => EMBEDDIT_DESC,
     device_table      => embeddit_device_table
   );

  constant eonic_device_table : device_table_type := (
   others              => "Unknown Device                 ");

  constant EONIC_DESC : vendor_description :=  "Eonic BV                ";

  constant eonic_lib : vendor_library_type := (
     vendorid 	       => VENDOR_EONIC,
     vendordesc        => EONIC_DESC,
     device_table      => eonic_device_table
   );

  constant radionor_device_table : device_table_type := (
   others              => "Unknown Device                 ");

  constant RADIONOR_DESC : vendor_description :=  "Radionor Communications ";

   constant radionor_lib : vendor_library_type := (
     vendorid 	       => VENDOR_RADIONOR,
     vendordesc        => RADIONOR_DESC,
     device_table      => radionor_device_table
   );

  constant orbita_device_table : device_table_type := (
   ORBITA_1553B       => "MIL-STD-1553B Controller       ",
   ORBITA_429         => "429 Interface                  ",
   ORBITA_SPI         => "SPI Interface                  ",
   ORBITA_I2C         => "I2C Interface                  ",
   ORBITA_SMARTCARD   => "Smart Card Reader              ",
   ORBITA_SDCARD      => "SD Card Reader                 ",
   ORBITA_UART16550   => "16550 UART                     ",
   ORBITA_CRYPTO      => "Crypto Engine                  ",
   ORBITA_SYSIF       => "System Interface               ",
   ORBITA_PIO         => "Programmable IO module         ",
   ORBITA_RTC         => "Real-Time Clock                ",
   ORBITA_COLORLCD    => "Color LCD Controller           ",
   ORBITA_PCI         => "PCI Module                     ",
   ORBITA_DSP         => "DPS Co-Processor               ",
   ORBITA_USBHOST     => "USB Host                       ",
   ORBITA_USBDEV      => "USB Device                     ",
   others              => "Unknown Device                 ");

  constant ORBITA_DESC : vendor_description :=  "Orbita                  ";

  constant orbita_lib : vendor_library_type := (
     vendorid 	       => VENDOR_ORBITA,
     vendordesc        => ORBITA_DESC,
     device_table      => orbita_device_table
   );

  constant ACTEL_DESC : vendor_description :=   "Actel Corporation       ";

  constant actel_device_table : device_table_type := (
   ACTEL_COREMP7      => "CoreMP7 Processor              ",
   others             => "Unknown Device                 ");

  constant actel_lib : vendor_library_type := (
     vendorid 	       => VENDOR_ACTEL,
     vendordesc        => ACTEL_DESC,
     device_table      => actel_device_table
   );

  constant NASA_DESC : vendor_description :=   "NASA                    ";

  constant nasa_device_table : device_table_type := (
   NASA_EP32         => "EP32 Forth processor           ",
   others             => "Unknown Device                 ");

  constant nasa_lib : vendor_library_type := (
     vendorid 	       => VENDOR_NASA,
     vendordesc        => NASA_DESC,
     device_table      => nasa_device_table
   );

  constant UNKNOWN_DESC : vendor_description :=  "Unknown vendor          ";

  constant unknown_device_table : device_table_type := (
   others              => "Unknown Device                 ");

   constant unknown_lib : vendor_library_type := (
     vendorid 	       => 0,
     vendordesc        => UNKNOWN_DESC,
     device_table      => unknown_device_table
   );

  constant iptable : device_array := (
    VENDOR_GAISLER     => gaisler_lib,
    VENDOR_ESA         => esa_lib,
    VENDOR_OPENCHIP    => openchip_lib,
    VENDOR_OPENCORES   => opencores_lib,
    VENDOR_CONTRIB     => contrib_lib,
    VENDOR_EONIC       => eonic_lib,
    VENDOR_GLEICHMANN  => gleichmann_lib,
    VENDOR_MENTA       => menta_lib,
    VENDOR_EMBEDDIT    => embeddit_lib,
    VENDOR_SUN         => sun_lib,
    VENDOR_RADIONOR    => radionor_lib,
    VENDOR_ORBITA      => orbita_lib,
    VENDOR_SYNOPSYS    => synopsys_lib,
    VENDOR_CETON       => ceton_lib,
    VENDOR_ACTEL       => actel_lib,
    VENDOR_NASA        => nasa_lib,
    others             => unknown_lib);

  type system_table_type is array (0 to 4095) of device_description;

  constant system_table : system_table_type := (
   LEON3_RTAX_CID2   => "LEON3FT RTAX Configuration 2   ",
   LEON3_RTAX_CID5   => "LEON3FT RTAX Configuration 5   ",
   LEON3_RTAX_CID6   => "LEON3FT RTAX Configuration 6   ",
   LEON3_RTAX_CID7   => "LEON3FT RTAX Configuration 7   ",
   LEON3_RTAX_CID8   => "LEON3FT RTAX Configuration 8   ",
   XILINX_ML401      => "Xilinx ML401 Development board ",
   XILINX_ML501      => "Xilinx ML501 Development board ",
   XILINX_ML505      => "Xilinx ML505 Development board ",
   XILINX_ML506      => "Xilinx ML506 Development board ",
   XILINX_ML507      => "Xilinx ML507 Development board ",
   AEROFLEX_UT699    => "Aeroflex UT699 Rad-Hard CPU    ",
   GAISLER_DARE1     => "Gaisler DARE1 Rad-Hard CPU     ",
   GAISLER_GR712RC   => "Gaisler GR712RC Rad-Hard CPU   ",
   others            => "Unknown system                 ");

-- pragma translate_on

end;

