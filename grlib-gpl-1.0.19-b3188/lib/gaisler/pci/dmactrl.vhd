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
-- Entity:  dmactrl
-- File:  dmactrl.vhd
-- Author:  Alf Vaerneus - Gaisler Research
-- Modified:  Nils-Johan Wessman - Gaisler Research
-- Description:	Simple DMA controller
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
use gaisler.pci.all;

entity dmactrl is
  generic (
    hindex    : integer := 0;
    slvindex  : integer := 0;
    pindex    : integer := 0;
    paddr     : integer := 0;
    pmask     : integer := 16#fff#;
    blength   : integer := 4
  );
  port (
    rst       : in std_logic;
    clk       : in std_logic;
    apbi      : in apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    ahbmi     : in ahb_mst_in_type;
    ahbmo     : out ahb_mst_out_type;
    ahbsi0    : in ahb_slv_in_type;
    ahbso0    : out ahb_slv_out_type;
    ahbsi1    : out ahb_slv_in_type;
    ahbso1    : in ahb_slv_out_type
  );
end;

architecture rtl of dmactrl is

constant BURST_LENGTH : integer := blength;
constant REVISION : integer := 0;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_DMACTRL, 0, REVISION, 0),
  1 => apb_iobar(paddr, pmask));

type state_type is(idle, read1, read2, read3, read4, read5, write1, write2, writeb, write3, write4, turn); 
type rbuf_type is array (0 to 2) of std_logic_vector(31 downto 0);
type dmactrl_reg_type is record
  state     : state_type;
  addr0     : std_logic_vector(31 downto 2);
  addr1     : std_logic_vector(31 downto 2);
  hmbsel    : std_logic_vector(0 to NAHBAMR-1);
  htrans    : std_logic_vector(1 downto 0);
  rbuf      : rbuf_type;
  write     : std_logic;
  start_req : std_logic;
  start     : std_logic;
  ready     : std_logic;
  err       : std_logic;
  first0    : std_logic;
  first1    : std_logic;
  no_ws     : std_logic; -- no wait states
  blimit    : std_logic; -- 1k limit
  dmao_start: std_logic; 
  two_in_buf: std_logic; -- two words in rbuf to be stored
  burstl_p  : std_logic_vector(BURST_LENGTH - 1 downto 0); -- pci access counter
  burstl_a  : std_logic_vector(BURST_LENGTH - 1 downto 0); -- amba access counter
  ahb0_htrans : std_logic_vector(1 downto 0);
  ahb0_hready : std_logic;
  ahb0_retry  : std_logic;
  ahb0_hsel   : std_logic;
  start_del   : std_logic;
end record;

signal r,rin : dmactrl_reg_type;
signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;

begin

   comb : process(rst,r,dmao,apbi,ahbsi0,ahbso1)
   variable v : dmactrl_reg_type;
   variable vdmai : ahb_dma_in_type;
   variable pdata : std_logic_vector(31 downto 0);
   variable slvbusy : ahb_slv_out_type;
   variable dma_done, pci_done : std_logic;
   variable bufloc : integer range 0 to 2;
   begin
   
   slvbusy := ahbso1; v := r;
   vdmai.burst := '1'; vdmai.address := r.addr0 & "00";
   vdmai.write := not r.write; vdmai.start := '0'; vdmai.size := "10";
   vdmai.wdata := r.rbuf(0); pdata := (others => '0');
   vdmai.busy := '0'; vdmai.irq := '0'; 
   bufloc := 0;


   v.start_del := r.start;
   slvbusy.hready := '1'; slvbusy.hindex := hindex; --slvbusy.hresp := "00"; 
   v.ahb0_htrans := ahbsi0.htrans; v.ahb0_retry := '0';
   v.ahb0_hsel := ahbsi0.hsel(slvindex); v.ahb0_hready := ahbsi0.hready;

   -- AMBA busy response when dma is running 
   if r.ahb0_retry = '1' then slvbusy.hresp := "10";
   else slvbusy.hresp := "00"; end if;

   if r.ahb0_htrans = "10" and (r.start = '1') and r.ahb0_hsel = '1' and r.ahb0_hready = '1' then
      slvbusy.hready := '0';
      slvbusy.hresp := "10";
      v.ahb0_retry := '1';
   end if;

   -- Done signals
   if (r.burstl_a(BURST_LENGTH - 1 downto 1) = zero32(BURST_LENGTH - 1 downto 1)) then -- AMBA access done
     dma_done := '1'; else dma_done := '0'; end if;
   
   if (r.burstl_p(BURST_LENGTH - 1 downto 1) = zero32(BURST_LENGTH - 1 downto 1)) then -- PCI access done
     pci_done := '1'; else pci_done := '0'; end if;

   -- APB interface
   if (apbi.psel(pindex) and apbi.penable) = '1' then
      case apbi.paddr(4 downto 2) is
      when "000" =>
         if apbi.pwrite = '1' then
            v.start_req := apbi.pwdata(0);
            v.write := apbi.pwdata(1);
            v.ready := r.ready and not apbi.pwdata(2);
            v.err := r.err and not apbi.pwdata(3);
            v.hmbsel := apbi.pwdata(7 downto 4);
         end if;
         pdata := zero32(31 downto 8) & r.hmbsel & r.err & r.ready & r.write & r.start_req;
      when "001" =>
         if apbi.pwrite = '1' then v.addr0 := apbi.pwdata(31 downto 2); end if;
         pdata := r.addr0 & "00";
      when "010" =>
         if apbi.pwrite = '1' then v.addr1 := apbi.pwdata(31 downto 2); end if;
         pdata := r.addr1 & "00";
      when "011" =>
         if apbi.pwrite = '1' then 
            v.burstl_p := apbi.pwdata(BURST_LENGTH - 1 downto 0); 
            v.burstl_a := apbi.pwdata(BURST_LENGTH - 1 downto 0); 
         end if;
         pdata := zero32(31 downto BURST_LENGTH) & r.burstl_p;
      when others =>
      end case;
   end if;

   -- can't start dma until AMBA slave is idle
   if r.start_req = '1' and (ahbsi0.hready = '1' and (ahbsi0.htrans = "00" or ahbsi0.hsel(slvindex) = '0')) then
      v.start := '1';
   end if;


   case r.state is
   when idle =>
      v.htrans := "00";
      v.first0 := '1'; v.first1 := '1'; 
      v.no_ws := '0'; v.dmao_start := '0'; v.blimit := '0';
      if r.start = '1' then
         if r.write = '0' then v.state := read1;
         else v.state := write1; end if;
      end if;
   when read1 => -- Start PCI read
      bufloc := 0;
      v.htrans := "10";
      if ahbso1.hready = '1' and ahbso1.hresp = HRESP_OKAY then
         if r.htrans(1) = '1' then
            if pci_done = '1' then
               v.htrans := "00";
               v.state := read5;
            else
               v.htrans := "11";
               v.state := read2;
            end if;
         end if;
      elsif ahbso1.hready = '0' then
         v.htrans := "11";
      else
         v.htrans := "00";
      end if;
   when read2 => -- fill rbuf (3 words)
      if r.first1 = '1' then bufloc := 1; -- store 3 words
      else bufloc := 2; end if; 

      if ahbso1.hready = '1' and ahbso1.hresp = HRESP_OKAY then
         if r.htrans = "11" then
            v.first1 := '0';
            if pci_done = '1' then
               v.htrans := "00";
               v.state := read5;
            elsif r.first1 = '0' then 
               v.htrans := "01";
               v.state := read3;
               v.first0 := '1';
            end if;
         end if;
      end if;
   when read3 => -- write to AMBA and read from PCI
      vdmai.start := '1';
      bufloc := 1;
      
      if (dmao.ready and dmao.start) = '1' then bufloc := 1; v.no_ws := '1'; -- no wait state on AMBA ?
      else 
         bufloc := 2; 
         if dmao.active = '1' then v.no_ws := '0'; end if;
      end if;

      if dmao.active = '0' then v.blimit := '1'; 
      else v.blimit := '0'; end if;

      if dmao.ready = '1' then
         v.first0 := '0'; 
         v.htrans := "11";
      else 
         v.htrans := "01";
      end if;
      
      if r.htrans(1) = '1' and ahbso1.hready = '1' and ahbso1.hresp = HRESP_OKAY and pci_done = '1' then
         v.state := read5;
         v.htrans := "00";
      elsif r.htrans(1) = '1' and ahbso1.hready = '0' and ahbso1.hresp = HRESP_RETRY then
         if dmao.active = '0' then v.two_in_buf := '1'; end if; -- two words in rbuf to store
         v.state := read4;
         v.htrans := "01";
      end if;
   when read4 => -- PCI retry
      bufloc := 1;
      if dmao.ready = '1' then v.two_in_buf := '0'; end if;

      if dmao.start = '1' and r.two_in_buf = '0' then v.dmao_start := '1'; end if;

      if r.no_ws = '1' and r.dmao_start = '1' then vdmai.start := '0';
      elsif dmao.start = '1' and r.two_in_buf = '0' then v.no_ws := '1'; vdmai.start := '0';
      else vdmai.start := '1'; end if;

      --if dmao.ready = '1' and r.no_ws = '1' and r.two_in_buf = '0' then -- handle change of waitstates (sdram refresh)
      if (dmao.ready = '1' or (dmao.active = '0' and r.dmao_start = '1')) and r.no_ws = '1' and r.two_in_buf = '0' then
         v.first0 := '1';
         v.first1 := '1';
         v.no_ws := '0';
         v.dmao_start := '0';
         v.state := read1;
      end if;
   when read5 => -- PCI read done
      if dmao.start = '1' then v.first0 := '0'; -- first amba access
      elsif dmao.active = '0' then v.first0 := '1'; end if; -- 1k limit

      if dma_done = '0' or (r.first0 = '1' and dmao.start = '0') then vdmai.start := '1'; end if;
      
      if (dmao.ready and dmao.start) = '1' then bufloc := 1; v.no_ws := '1'; -- no wait state on AMBA ?
      else bufloc := 2; end if; 

      if dmao.ready = '1' and dma_done = '1' then
         v.state  := turn;   
      end if;
   when write1 => -- Read first from AMBA
      bufloc := 0; 
      v.first1 := '1'; v.no_ws := '0';
      
      if dmao.start = '1' then v.first0 := '0'; -- first amba access
      elsif dmao.active = '0' then v.first0 := '1'; end if; -- 1k limit

      if dma_done = '1' and (r.first0 = '0' or dmao.start = '1') then vdmai.start := '0';
      else vdmai.start := '1'; end if;

      if dmao.ready = '1' then 
         if dma_done = '1' then v.state := write4;
         else v.state := write2; end if;
         v.htrans := "10"; -- start access to PCI
      end if;
   when write2 => -- Read from AMBA and write to PCI
      bufloc := 0;
      if (dmao.ready and dmao.start) = '1' then v.no_ws := '1'; end if; -- no wait state on AMBA ?
      
      if dmao.start = '1' then v.first0 := '0'; -- first amba access
      elsif dmao.active = '0' then v.first0 := '1'; end if; -- 1k limit

      if dmao.ready = '1' then -- Data ready write to PCI 
         v.htrans := "11";
         if dma_done = '1' then
            v.state := write4;
         end if;
      else v.htrans := "01"; end if;

      if ahbso1.hready = '0' then 
         vdmai.start := '0';
         if v.no_ws = '1' then bufloc := 1; end if;
         if dmao.active = '0' then v.state := writeb; -- AMBA 1k limit
         else v.state := write3; end if;
      elsif dma_done = '0' or (r.first0 = '1' and dmao.start = '0') then
         vdmai.start := '1';
      end if;
   when writeb => -- AMBA 1k limit and PCI retry
      bufloc := 1;
      if dmao.active = '1' then vdmai.start := '0';
      else vdmai.start := '1'; end if;
   
      if dmao.ready = '1' then v.state := write3; end if;
   when write3 => -- Retry from PCI
      bufloc := 1;
      --if ahbso1.hready = '1' then v.htrans := "10"; -- wait for AMBA access to be done before retry 
      if (ahbso1.hready and (dmao.ready or not dmao.active)) = '1' then v.htrans := "10"; 
      else v.htrans := "01"; end if;
      if r.htrans(1) = '1' and ahbso1.hready = '1' and ahbso1.hresp = HRESP_OKAY then
         if pci_done = '1' then
            v.htrans := "00";
            v.state := turn;
         elsif dma_done = '1' and r.burstl_a(0) = '0' then
            v.htrans := "01";
            v.state := write4;
         else 
            v.htrans := "11";
            v.first0 := '1';
            v.state := write2; 
         end if;
      end if;
   when write4 => -- Done read AMBA
      v.htrans := "11";
      if pci_done = '1' and ahbso1.hready = '1' and r.htrans(1) = '1' then
         v.htrans := "00";
         v.state := turn;
      elsif ahbso1.hready = '0' then 
         v.state := write3;
         v.htrans := "01";
      end if;
   when turn =>
      v.htrans := "00";
      -- can't switch off dma until AMBA slave is idle
      if (ahbsi0.hsel(slvindex) = '0' and r.ahb0_retry = '0' and ahbsi0.hready = '1') 
          or (ahbsi0.htrans = "00" and ahbsi0.hready = '1') or r.ahb0_retry = '1' then 
         v.ready := '1'; v.first1 := '1'; v.start_req := '0';
         v.start := '0'; v.state := idle;
      end if;
   end case;

   if ((r.htrans(1) and ahbso1.hready) = '1' and ahbso1.hresp = HRESP_OKAY) then -- PCI access done
      v.burstl_p := r.burstl_p - '1'; -- dec counter
      v.addr1 := r.addr1 + '1'; -- inc address (PCI)
      if (r.write = '0' or r.state = write4 or r.state = write3) then 
         if r.state /= read1 and r.state /= read2 and (v.no_ws = '1' or r.state = write3) and v.blimit = '0' then 
            v.rbuf(0) := r.rbuf(1);                                     -- dont update if wait states
            v.rbuf(1) := r.rbuf(2);                                     -- 
         end if;
         if r.write = '0' then v.rbuf(bufloc) := ahbso1.hrdata; end if; -- PCI to AMBA 
      end if;                                                           -- if wait states store in buf(2) else
   end if;                                                              -- in buf(1). Frist word in buf(0)    

   if dmao.ready = '1' then -- AMBA access done
      v.burstl_a := r.burstl_a - '1'; -- dec counter
      v.addr0 := r.addr0 + 1; -- inc address (AMBA master)
      if r.write = '1' then 
         if r.state /= write3 and bufloc = 0 then -- dont update if retry from PCI
            v.rbuf(0) := r.rbuf(1);
            v.rbuf(1) := r.rbuf(2); 
         end if;
         v.rbuf(bufloc) := dmao.rdata; -- AMBA to PCI
      elsif r.write = '0' and (r.first0 = '1' or v.state = read4 or r.state = read5 or (v.no_ws = '0' or r.blimit = '1')) then 
         v.rbuf(0) := r.rbuf(1); -- update when data is written if wait states or PCI retry or PCI done
         v.rbuf(1) := r.rbuf(2); 
      end if;
   end if;
   
   if (ahbso1.hresp = HRESP_ERROR or (dmao.mexc or dmao.retry) = '1') then
      v.err := '1'; v.state := turn; v.htrans := HTRANS_IDLE;
   end if;
   
   --cancel dma
   if r.start = '1' and r.start_req = '0' then
      v.state := turn;
   end if;
   
   if rst = '0' then
      v.state := idle;
      v.start := '0';
      v.start_req := '0';
      v.write := '0';
      v.err := '0';
      v.ready := '0';
      v.first1 := '1';
      v.two_in_buf := '0';
      v.hmbsel := (others => '0');
      v.addr1 := (others => '0');
   end if;


   if r.start = '1' then -- new *** ???
      ahbsi1.hsel <= (others => '1');
      ahbsi1.hmbsel(0 to 3) <= r.hmbsel;
      ahbsi1.hsize <= "010";
      ahbsi1.hwrite <= r.write;
      ahbsi1.htrans <= v.htrans;
--      ahbsi1.haddr <= r.addr1 & "00";
      ahbsi1.haddr <= v.addr1 & "00"; 
      ahbsi1.hburst <= "001";
      ahbsi1.hwdata <= r.rbuf(0);
      ahbsi1.hready <= ahbso1.hready;
      ahbsi1.hmaster <= conv_std_logic_vector(hindex,4);
      ahbso0 <= slvbusy;
   else
      ahbsi1.hsel <= ahbsi0.hsel;
      ahbsi1.hmbsel(0 to 3) <= ahbsi0.hmbsel(0 to 3);
      ahbsi1.hsize <= ahbsi0.hsize;
      ahbsi1.hwrite <= ahbsi0.hwrite;
      ahbsi1.htrans <= ahbsi0.htrans;
      ahbsi1.haddr <= ahbsi0.haddr;
      ahbsi1.hburst <= ahbsi0.hburst;
      ahbsi1.hwdata <= ahbsi0.hwdata;
      ahbsi1.hready <= ahbsi0.hready;
      ahbsi1.hmaster <= ahbsi0.hmaster;
      ahbso0 <= ahbso1;
      
      v.state := idle;
   end if;

   dmai <= vdmai;
   rin <= v;
   apbo.pconfig <= pconfig;
   apbo.prdata <= pdata;
   apbo.pirq <= (others => '0');
   apbo.pindex <= pindex;
   ahbsi1.hirq <= (others => '0');
   ahbsi1.hprot <= (others => '0');
   ahbsi1.hmastlock <= '0';
   ahbsi1.hcache <= '0';

   end process;

   cpur : process (clk)
   begin
      if rising_edge (clk) then
         r <= rin;
      end if;
   end process;

   ahbmst0 : pciahbmst generic map (hindex => hindex, devid => GAISLER_DMACTRL, incaddr => 1)
   port map (rst, clk, dmai, dmao, ahbmi, ahbmo);

-- pragma translate_off
    bootmsg : report_version
    generic map ("dmactrl" & tost(pindex) &
	": 32-bit DMA controller & AHB/AHB bridge  rev " & tost(REVISION));
-- pragma translate_on

end;

