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
-- Entity: ocidec2_amba_slave 
-- File: ocidec2_amba_slave.vhd
-- Author:  Nils-Johan Wessman, Gaisler Research
-- Description: ATA controller
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use grlib.devices.all;
use gaisler.memctrl.all;

entity ocidec2_amba_slave is
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#ff0#;
    pirq    : integer := 0;
    DeviceID   : integer := 0;
    RevisionNo : integer := 0;

    -- PIO mode 0 settings (@100MHz clock)
    PIO_mode0_T1 : natural := 6;                -- 70ns
    PIO_mode0_T2 : natural := 28;               -- 290ns
    PIO_mode0_T4 : natural := 2;                -- 30ns
    PIO_mode0_Teoc : natural := 23;             -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
    
    -- Multiword DMA mode 0 settings (@100MHz clock)
    DMA_mode0_Tm : natural := 4;                -- 50ns
    DMA_mode0_Td : natural := 21;               -- 215ns
    DMA_mode0_Teoc : natural := 21              -- 215ns ==> T0 - Td - Tm = 480 - 50 - 215 = 215
  );
  port (
    rst     : in  std_ulogic;
    arst    : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    cf_power: out std_logic;
    -- ata controller signals

    -- PIO control input
    PIOsel     : out std_logic;
    PIOtip,                                         -- PIO transfer in progress
    PIOack     : in std_logic;                      -- PIO acknowledge signal
    PIOq       : in std_logic_vector(15 downto 0);  -- PIO data input
    PIOpp_full : in std_logic;                      -- PIO write-ping-pong buffers full
    irq        : in std_logic;                      -- interrupt signal input
    PIOa       : out std_logic_vector(3 downto 0);
    PIOd       : out std_logic_vector(15 downto 0);
    PIOwe      : out std_logic;

    -- DMA control inputs
    DMAsel    : out std_logic;
    DMAtip,                                     -- DMA transfer in progress
    DMAack,                                     -- DMA transfer acknowledge
    DMARxEmpty,                                 -- DMA receive buffer empty
    DMATxFull,                                  -- DMA transmit buffer full
    DMA_dmarq : in std_logic;                   -- wishbone DMA request
    DMAq      : in std_logic_vector(31 downto 0);
 
    -- outputs
    -- control register outputs
    IDEctrl_rst,
    IDEctrl_IDEen,
    IDEctrl_FATR1,
    IDEctrl_FATR0,
    IDEctrl_ppen,
    DMActrl_DMAen,
    DMActrl_dir,
    DMActrl_BeLeC0,
    DMActrl_BeLeC1 : out std_logic;
 
    -- CMD port timing registers
    PIO_cmdport_T1,
    PIO_cmdport_T2,
    PIO_cmdport_T4,
    PIO_cmdport_Teoc    : out std_logic_vector(7 downto 0);
    PIO_cmdport_IORDYen : out std_logic;
 
    -- data-port0 timing registers
    PIO_dport0_T1,
    PIO_dport0_T2,
    PIO_dport0_T4,
    PIO_dport0_Teoc    : out std_logic_vector(7 downto 0);
    PIO_dport0_IORDYen : out std_logic;
 
    -- data-port1 timing registers
    PIO_dport1_T1,
    PIO_dport1_T2,
    PIO_dport1_T4,
    PIO_dport1_Teoc    : out std_logic_vector(7 downto 0);
    PIO_dport1_IORDYen : out std_logic;
 
    -- DMA device0 timing registers
    DMA_dev0_Tm,
    DMA_dev0_Td,
    DMA_dev0_Teoc    : out std_logic_vector(7 downto 0);
 
    -- DMA device1 timing registers
    DMA_dev1_Tm,
    DMA_dev1_Td,
    DMA_dev1_Teoc    : out std_logic_vector(7 downto 0)
  );
end; 


architecture rtl of ocidec2_amba_slave is

constant VERSION : amba_version_type := 0;
constant hconfig : ahb_config_type := (
  0 => ahb_device_reg(VENDOR_GAISLER, GAISLER_ATACTRL, 0, VERSION, pirq),  
  4 => ahb_iobar(haddr, hmask),
  others => zero32);

type PIOtiming_type is record
   T1,T2,T4,Teoc  : std_logic_vector(7 downto 0);
end record;
type DMAtiming_type is record
   Tm,Td,Teoc  : std_logic_vector(7 downto 0);
end record;

-- local registers
type reg_type is record
   -- AHB signal
   hready    : std_ulogic;                    -- Hready
   hsel      : std_ulogic;                    -- Hsel
   hmbsel    : std_logic_vector(0 to 2);      -- Mem map select
   haddr     : std_logic_vector(31 downto 0); -- Haddr
   hrdata    : std_logic_vector(31 downto 0); -- Hreaddata
   hwdata    : std_logic_vector(31 downto 0); -- Hwritedata
   hwrite    : std_ulogic;                    -- Hwrite
   htrans    : std_logic_vector(1 downto 0);  -- Htrans type
   hburst    : std_logic_vector(2 downto 0);  -- Hburst type
   hresp     : std_logic_vector(1 downto 0);  -- Hresp type
   size      : std_logic_vector(1 downto 0);  -- Part of Hsize
   piosel    : std_logic;
   irq       : std_logic;
   irqv      : std_logic_vector(NAHBIRQ-1 downto 0);
   pioack    : std_logic;
   atasel    : std_logic;
   
   -- reg signal
   ctrlreg  : std_logic_vector(31 downto 0);
   statreg  : std_logic_vector(31 downto 0);
   
   pio_cmd  : PIOtiming_type;
   pio_dp0  : PIOtiming_type;
   pio_dp1  : PIOtiming_type;
   dma_dev0 : DMAtiming_type;
   dma_dev1 : DMAtiming_type;
end record;

signal r, ri : reg_type;
begin

  ctrl : process(rst, ahbsi, r, PIOack, PIOtip, PIOpp_full, irq, PIOq,
	DMAtip, DMARxEmpty, DMATxFull, DMA_dmarq)
  variable v      : reg_type;    -- local variables for registers
  variable int    : std_logic;
  begin

-- Variable default settings to avoid latches
   v := r; 
   v.hresp := HRESP_OKAY; 
   v.irqv := (others => '0');
   int := '1'; 
   v.irq := irq;
   v.irqv(pirq) := v.irq and not r.irq;
   v.pioack := PIOack;


   if (ahbsi.hready = '1') and (ahbsi.hsel(hindex) and ahbsi.htrans(1)) = '1' then       
         v.size   := ahbsi.hsize(1 downto 0); 
         v.hwrite := ahbsi.hwrite;
         v.htrans := ahbsi.htrans; 
         v.hburst := ahbsi.hburst;
         v.hsel   := '1'; 
         v.haddr  := ahbsi.haddr;
         v.piosel := ahbsi.haddr(6);
         v.atasel := ahbsi.haddr(6);
         
         if ahbsi.hwrite = '0' or ahbsi.haddr(6) = '1' then -- Read or ATA 
            v.hready := '0';
         else                                         -- Write
            v.hready := '1';
         end if;
   else
         v.hsel := '0';
         
         if PIOack = '1' then
            v.piosel := '0';
         end if;
         
         v.hready := r.pioack or not r.atasel;
         
         if r.pioack = '1' then
            v.atasel := '0';
         end if;
   end if;

   if r.hsel = '1' and r.atasel = '0' and r.hwrite = '1' then -- Write
      case r.haddr(5 downto 2) is
      when "0000" =>    -- Control register 0x0
         v.ctrlreg := ahbsi.hwdata;
      when "0001" =>    -- Status register 0x4
         int := ahbsi.hwdata(0); -- irq bit in status reg
      when "0010" =>    -- PIO Compatible timing register 0x8
         v.pio_cmd.T1 := ahbsi.hwdata(7 downto 0);
         v.pio_cmd.T2 := ahbsi.hwdata(15 downto 8);
         v.pio_cmd.T4 := ahbsi.hwdata(23 downto 16);
         v.pio_cmd.Teoc := ahbsi.hwdata(31 downto 24);
      when "0011" =>    -- PIO Fast timing register device 0 0xc
         v.pio_dp0.T1 := ahbsi.hwdata(7 downto 0);
         v.pio_dp0.T2 := ahbsi.hwdata(15 downto 8);
         v.pio_dp0.T4 := ahbsi.hwdata(23 downto 16);
         v.pio_dp0.Teoc := ahbsi.hwdata(31 downto 24);
      when "0100" =>    -- PIO Fast timing register device 1 0x10
         v.pio_dp1.T1 := ahbsi.hwdata(7 downto 0);
         v.pio_dp1.T2 := ahbsi.hwdata(15 downto 8);
         v.pio_dp1.T4 := ahbsi.hwdata(23 downto 16);
         v.pio_dp1.Teoc := ahbsi.hwdata(31 downto 24);
      when "0101" =>    -- DMA timing register device 0 0x14
         v.dma_dev0.Tm := ahbsi.hwdata(7 downto 0);
         v.dma_dev0.Td := ahbsi.hwdata(15 downto 8);
         v.dma_dev0.Teoc := ahbsi.hwdata(31 downto 24);
      when "0110" =>    -- DMA timing register device 1 0x18
         v.dma_dev1.Tm := ahbsi.hwdata(7 downto 0);
         v.dma_dev1.Td := ahbsi.hwdata(15 downto 8);
         v.dma_dev1.Teoc := ahbsi.hwdata(31 downto 24);
      when others => null;
      end case;
   elsif r.hsel = '1' and r.atasel = '1' and r.hwrite = '1' then  -- ATA IO device 0x40-
      v.hwdata := ahbsi.hwdata;
   end if;
   
   if r.hsel = '1' and r.atasel = '0' and r.hwrite = '0' then -- Read
      case r.haddr(5 downto 2) is
      when "0000" =>    -- Control register 0x0
         v.hrdata := r.ctrlreg;
      when "0001" =>    -- Status register 0x4
         v.hrdata := r.statreg;
      when "0010" =>    -- PIO Compatible timing register 0x8
         v.hrdata := (r.pio_cmd.Teoc & r.pio_cmd.T4 & r.pio_cmd.T2 & 
                                     r.pio_cmd.T1);
      when "0011" =>    -- PIO Fast timing register device 0 0xc
         v.hrdata := (r.pio_dp0.Teoc & r.pio_dp0.T4 & r.pio_dp0.T2 & 
                                     r.pio_dp0.T1);
      when "0100" =>    -- PIO Fast timing register device 1 0x10
         v.hrdata := (r.pio_dp1.Teoc & r.pio_dp1.T4 & r.pio_dp1.T2 & 
                                     r.pio_dp1.T1);
      when "0101" =>    -- DMA timing register device 0 0x14
         v.hrdata := (r.dma_dev0.Teoc & x"00" & r.dma_dev0.Td & 
                                     r.dma_dev0.Tm);
      when "0110" =>    -- DMA timing register device 1 0x18
         v.hrdata := (r.dma_dev1.Teoc & x"00" & r.dma_dev1.Td & 
                                     r.dma_dev1.Tm);
      when others =>
         v.hrdata := x"aaaaaaaa";
      end case;
   elsif r.atasel = '1' then  -- ATA IO device 0x40-
      v.hrdata := (x"0000" & PIOq);
   end if;
   
   -- Status register
   v.statreg(31 downto 0)  := (others => '0');                -- clear all bits (read unused bits as '0')
   v.statreg(31 downto 28) := std_logic_vector(to_unsigned(DeviceId,4));    -- set Device ID
   v.statreg(27 downto 24) := std_logic_vector(to_unsigned(RevisionNo,4));  -- set revision number
   v.statreg(15) := DMAtip;
   v.statreg(10) := DMARxEmpty;
   v.statreg(9)  := DMATxFull;
   v.statreg(8)  := DMA_dmarq;
   v.statreg(7)  := PIOtip;
   v.statreg(6)  := PIOpp_full;
   v.statreg(0)  := (r.statreg(0) or (v.irq and not r.irq)) and int;
   
-- reset
   if rst = '0' then
      v.ctrlreg := (0 => '1', others => '0');
      v.statreg(0) := '0';

      v.haddr := (others => '0');
      v.hwrite := '0';
      v.hready := '1';
      v.pioack := '0';
      v.atasel := '0';
      v.piosel := '0';

      v.pio_cmd.T1 := conv_std_logic_vector(PIO_mode0_T1,8);
      v.pio_cmd.T2 := conv_std_logic_vector(PIO_mode0_T2,8);
      v.pio_cmd.T4 := conv_std_logic_vector(PIO_mode0_T4,8);
      v.pio_cmd.Teoc := conv_std_logic_vector(PIO_mode0_Teoc,8);

      v.pio_dp0.T1 := conv_std_logic_vector(PIO_mode0_T1,8);
      v.pio_dp0.T2 := conv_std_logic_vector(PIO_mode0_T2,8);
      v.pio_dp0.T4 := conv_std_logic_vector(PIO_mode0_T4,8);
      v.pio_dp0.Teoc := conv_std_logic_vector(PIO_mode0_Teoc,8);
      
      v.pio_dp1.T1 := conv_std_logic_vector(PIO_mode0_T1,8);
      v.pio_dp1.T2 := conv_std_logic_vector(PIO_mode0_T2,8);
      v.pio_dp1.T4 := conv_std_logic_vector(PIO_mode0_T4,8);
      v.pio_dp1.Teoc := conv_std_logic_vector(PIO_mode0_Teoc,8);

      v.dma_dev0.Tm := conv_std_logic_vector(DMA_mode0_Tm,8);
      v.dma_dev0.Td := conv_std_logic_vector(DMA_mode0_Td,8);
      v.dma_dev0.Teoc := conv_std_logic_vector(DMA_mode0_Teoc,8);
      
      v.dma_dev1.Tm := conv_std_logic_vector(DMA_mode0_Tm,8);
      v.dma_dev1.Td := conv_std_logic_vector(DMA_mode0_Td,8);
      v.dma_dev1.Teoc := conv_std_logic_vector(DMA_mode0_Teoc,8);
   end if;
   
   -- assign control bits
   cf_power             <= r.ctrlreg(31);
   DMActrl_DMAen        <= r.ctrlreg(15);
   DMActrl_dir          <= r.ctrlreg(13);
   DMActrl_BeLeC1       <= r.ctrlreg(9);
   DMActrl_BeLeC0       <= r.ctrlreg(8);
   IDEctrl_IDEen        <= r.ctrlreg(7);
   IDEctrl_FATR1        <= r.ctrlreg(6);
   IDEctrl_FATR0        <= r.ctrlreg(5);
   IDEctrl_ppen         <= r.ctrlreg(4);
   PIO_dport1_IORDYen   <= r.ctrlreg(3);
   PIO_dport0_IORDYen   <= r.ctrlreg(2);
   PIO_cmdport_IORDYen  <= r.ctrlreg(1);
   IDEctrl_rst          <= r.ctrlreg(0);

   -- CMD port timing
   PIO_cmdport_T1 <= r.pio_cmd.T1; PIO_cmdport_T2 <= r.pio_cmd.T2;
   PIO_cmdport_T4 <= r.pio_cmd.T4; PIO_cmdport_Teoc <= r.pio_cmd.Teoc;
   
   -- data-port0 timing
   PIO_dport0_T1 <= r.pio_dp0.T1; PIO_dport0_T2 <= r.pio_dp0.T2;
   PIO_dport0_T4 <= r.pio_dp0.T4; PIO_dport0_Teoc <= r.pio_dp0.Teoc;
   
   -- data-port1 timing
   PIO_dport1_T1 <= r.pio_dp1.T1; PIO_dport1_T2 <= r.pio_dp1.T2;
   PIO_dport1_T4 <= r.pio_dp1.T4; PIO_dport1_Teoc <= r.pio_dp1.Teoc;
   
   -- DMA device0 timing
   DMA_dev0_Tm <= r.dma_dev0.Tm; DMA_dev0_Td <= r.dma_dev0.Td;
   DMA_dev0_Teoc <= r.dma_dev0.Teoc;
   
   -- DMA device1 timing
   DMA_dev1_Tm <= r.dma_dev0.Tm; DMA_dev1_Td <= r.dma_dev0.Td;
   DMA_dev1_Teoc <= r.dma_dev0.Teoc;
   
   ri <= v; 
   
   PIOa   <= r.haddr(5 downto 2);
   PIOd   <= r.hwdata(15 downto 0);
   PIOsel <= r.piosel;
   PIOwe  <= r.hwrite;
   DMAsel <= '0'; -- temp ***

   ahbso.hready  <= r.hready;
   ahbso.hresp   <= r.hresp;
   ahbso.hrdata  <= r.hrdata;
   ahbso.hconfig <= hconfig;
   ahbso.hcache  <= '0';
   ahbso.hirq    <= r.irqv;
   ahbso.hindex  <= hindex;
   
  end process;

  regs : process(clk,rst)
  begin 

   if rising_edge(clk) then 
      r <= ri;
   end if;

    if rst = '0' then
    end if;
  end process;

end;

