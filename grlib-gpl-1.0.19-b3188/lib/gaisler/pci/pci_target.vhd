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
-- Entity: 	pci_target
-- File:	pci_target.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Simple PCI target interface
------------------------------------------------------------------------------
                           
library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.pci.all;
use gaisler.misc.all;
 
entity pci_target is 
  generic (
    hindex    : integer := 0;
    abits     : integer := 21;
    device_id : integer := 0;		-- PCI device ID
    vendor_id : integer := 0;	        -- PCI vendor ID
    nsync : integer range 1 to 2 := 1;	-- 1 or 2 sync regs between clocks
    oepol     : integer := 0); 
  port( 
    rst       : in std_logic;   
    clk       : in std_logic;   
    pciclk    : in std_logic;   
    pcii      : in  pci_in_type;
    pcio      : out pci_out_type;
    ahbmi     : in  ahb_mst_in_type;
    ahbmo     : out ahb_mst_out_type
  );
end; 
 
architecture rtl of pci_target is 

constant REVISION : amba_version_type := 0;
constant hconfig : ahb_config_type := (
  0 => ahb_device_reg(VENDOR_GAISLER, GAISLER_PCITRG, 0, REVISION, 0), 
  others => zero32);

constant CSYNC : integer := nsync-1;
constant MADDR_WIDTH : integer := abits;
constant zero : std_logic_vector(31 downto 0) := (others => '0');
subtype word4 is std_logic_vector(3 downto 0);
subtype word32 is std_logic_vector(31 downto 0);
constant pci_memory_read : word4 := "0110";
constant pci_memory_write : word4 := "0111";
constant pci_config_read : word4 := "1010";
constant pci_config_write : word4 := "1011";
type pci_input_type is record
  ad       : std_logic_vector(31 downto 0);  
  cbe      : std_logic_vector(3 downto 0);  
  frame    : std_logic;  
  devsel   : std_logic;  
  idsel    : std_logic;  
  trdy     : std_logic;  
  irdy     : std_logic;  
  par      : std_logic;
  stop 	   : std_logic;
  rst  	   : std_logic;
end record;

type pci_target_state_type is (idle, b_busy, s_data, backoff, turn_ar);
type pci_reg_type is record
  addr     : std_logic_vector(MADDR_WIDTH-1 downto 0);  
  data     : std_logic_vector(31 downto 0);  
  cmd      : std_logic_vector(3 downto 0);  
  state    : pci_target_state_type;
  csel     : std_logic;
  msel     : std_logic;
  read     : std_logic;
  devsel   : std_logic;  
  trdy     : std_logic;  
  stop     : std_logic;  
  par      : std_logic;  
  oe_par   : std_logic;
  oe_ad    : std_logic;
  oe_ctrl  : std_logic;
  noe_par  : std_logic;
  noe_ad   : std_logic;
  noe_ctrl : std_logic;
  bar0     : std_logic_vector(31 downto MADDR_WIDTH);  
  page     : std_logic_vector(31 downto MADDR_WIDTH-1);  
  men      : std_logic;
  laddr    : std_logic_vector(31 downto 0);  
  ldata    : std_logic_vector(31 downto 0);  
  lwrite   : std_logic;
  start    : std_logic;
  rready   : std_logic_vector(csync downto 0);
  wready   : std_logic_vector(csync downto 0);
  sync     : std_logic_vector(csync downto 0);
end record;

type cpu_state_type is (idle, sync1, busy, sync2);
type cpu_reg_type is record
  data     : std_logic_vector(31 downto 0);  
  state    : cpu_state_type;
  start    : std_logic_vector(csync downto 0);
  sync     : std_logic;
  rready    : std_logic;
  wready    : std_logic;
end record;

signal clk_int : std_logic;  
signal pr : pci_input_type;
signal r, rin : pci_reg_type;
signal r2, r2in : cpu_reg_type;
signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;

signal roe_ad, rioe_ad : std_logic_vector(31 downto 0);
attribute syn_preserve : boolean;
attribute syn_preserve of roe_ad : signal is true; 
begin

-- Back-end state machine (AHB clock domain)

  comb : process (rst, r2, r, dmao)
  variable vdmai : ahb_dma_in_type;
  variable v : cpu_reg_type;
  begin
    v := r2; 
    vdmai.start := '0'; vdmai.burst := '0'; vdmai.size := "10";
    vdmai.address := r.laddr; v.sync := '1';
    vdmai.wdata := r.ldata; vdmai.write := r.lwrite; vdmai.irq := '0';
    v.start(0) := r2.start(csync); v.start(csync) := r.start;
    case r2.state is
    when idle =>
      v.sync := '0';
      if r2.start(0) = '1' then
        if r.lwrite = '1' then v.state := sync1; v.wready := '0';
        else v.state := busy; vdmai.start := '1'; end if;
      end if;
    when sync1 =>
      if r2.start(0) = '0' then v.state := busy; vdmai.start := '1'; end if;
    when busy =>
      if dmao.active = '1' then
	if dmao.ready = '1' then
          v.rready := not r.lwrite; v.data := dmao.rdata; v.state := sync2;
        end if;
      else vdmai.start := '1'; end if;
    when sync2 =>
      if r2.start(0) = '0' then 
	v.state := idle;  v.wready := '1'; v.rready := '0';
      end if;
    end case;

    if rst = '0' then 
      v.state := idle; v.rready := '0'; v.wready := '1';
    end if;
    r2in <= v; dmai <= vdmai;
  end process;

-- PCI target core (PCI clock domain)

  pcicomb : process(pr, pcii, r, r2, roe_ad)
  variable v : pci_reg_type;
  variable chit, mhit, hit, ready, cwrite, mwrite : std_logic;
  variable cdata, cwdata : std_logic_vector(31 downto 0);  
  variable caddr : std_logic_vector(7 downto 2);  
  variable voe_ad : std_logic_vector(31 downto 0);
  variable oe_ctrl, oe_par, oe_ad : std_ulogic; 
  begin
    v := r; v.trdy := '1'; v.stop := '1'; voe_ad := roe_ad; 
    v.oe_ad := '1'; v.devsel := '1'; mwrite := '0';
    v.rready(0) := r.rready(csync); v.rready(csync) := r2.rready; 
    v.wready(0) := r.wready(csync); v.wready(csync) := r2.wready;
    v.sync(0) := r.sync(csync); v.sync(csync) := r2.sync;

-- address decoding

    if (r.state = s_data) and ((pr.irdy or r.trdy or r.read) = '0') then
      cwrite := r.csel;
      if ((r.msel and r.addr(MADDR_WIDTH-1)) = '1') and (pr.cbe = "0000") then
	v.page := pr.ad(31 downto MADDR_WIDTH-1);
      end if;
      if (pr.cbe = "0000") and  (r.addr(MADDR_WIDTH-1) = '1') then 
	mwrite := r.msel;
      end if;
    else cwrite := '0'; end if;
    cdata := (others => '0'); caddr :=  r.addr(7 downto 2);
    case caddr is
    when "000000" =>			-- 0x00, device & vendor id
      cdata := conv_std_logic_vector(DEVICE_ID, 16) &
     	conv_std_logic_vector(VENDOR_ID, 16);
    when "000001" =>			-- 0x04, status & command
      cdata(1) := r.men; cdata(26) := '1';
    when "000010" =>			-- 0x08, class code & revision
    when "000011" =>			-- 0x0c, latency & cacheline size
    when "000100" =>			-- 0x10, BAR0
      cdata(31 downto MADDR_WIDTH) := r.bar0;
    when others =>
    end case;

    cwdata := pr.ad;
    if pr.cbe(3) = '1' then cwdata(31 downto 24) := cdata(31 downto 24); end if;
    if pr.cbe(2) = '1' then cwdata(23 downto 16) := cdata(23 downto 16); end if;
    if pr.cbe(1) = '1' then cwdata(15 downto  8) := cdata(15 downto  8); end if;
    if pr.cbe(0) = '1' then cwdata( 7 downto  0) := cdata( 7 downto  0); end if;
    if cwrite = '1' then
      case caddr is
      when "000001" =>			-- 0x04, status & command
        v.men := cwdata(1);
      when "000100" =>			-- 0x10, BAR0
        v.bar0 := cwdata(31 downto MADDR_WIDTH);
      when others =>
      end case;
    end if;

    if (((pr.cbe = pci_config_read) or (pr.cbe = pci_config_write))
	and (pr.ad(1 downto 0) = "00"))
    then chit := '1'; else chit := '0'; end if;
    if ((pr.cbe = pci_memory_read) or (pr.cbe = pci_memory_write))
	and (r.bar0 = pr.ad(31 downto MADDR_WIDTH))
	and (r.bar0 /= zero(31 downto MADDR_WIDTH))
    then mhit := '1'; else mhit := '0'; end if;
    hit := r.csel or r.msel;
    ready := r.csel or (r.rready(0) and r.read) or (r.wready(0) and not r.read and not r.start) or
	 r.addr(MADDR_WIDTH-1);

-- target state machine

    case r.state is
    when idle  =>
      if pr.frame = '0' then v.state := b_busy; end if; -- !HIT ?
      v.addr := pr.ad(MADDR_WIDTH-1 downto 0); v.cmd := pr.cbe; 
      v.csel := pr.idsel and chit;
      v.msel := r.men and mhit; v.read := not pr.cbe(0);
      if (r.sync(0) and r.start and r.lwrite)  = '1' then v.start := '0'; end if;
    when turn_ar =>
      if pr.frame = '1' then v.state := idle; end if;
      if pr.frame = '0' then v.state := b_busy; end if; -- !HIT ?
      v.addr := pr.ad(MADDR_WIDTH-1 downto 0); v.cmd := pr.cbe;
      v.csel := pr.idsel and chit;
      v.msel := r.men and mhit; v.read := not pr.cbe(0);
      if (r.sync(0) and r.start and r.lwrite)  = '1' then v.start := '0'; end if;
    when b_busy  =>
      if hit = '1' then 
	v.state := s_data; v.trdy := not ready; v.stop := pr.frame and ready;
        v.devsel := '0';
      else
	v.state := backoff;
      end if;
    when s_data  =>
      v.stop := r.stop; v.devsel := '0';
      v.trdy := r.trdy or not pcii.irdy; 
      if (pcii.frame and not pcii.irdy) = '1' then
        v.state := turn_ar; v.stop := '1'; v.trdy := '1'; v.devsel := '1';
      end if;
    when backoff =>
      if pr.frame = '1' then v.state := idle; end if;
    end case;

    if ((r.state = s_data) or (r.state = turn_ar)) and
       (((pr.irdy or pr.trdy) = '0') or
        ((not pr.irdy and not pr.stop and pr.trdy and not r.start and r.wready(0)) = '1'))
    then
      if (pr.trdy and r.read)= '0' then v.start := '0'; end if;
      if (r.start = '0') and ((r.msel and not r.addr(MADDR_WIDTH-1)) = '1') and
	(((pr.trdy and r.read and not r.rready(0)) or (not pr.trdy and not r.read)) = '1')
      then
        v.laddr := r.page & r.addr(MADDR_WIDTH-2 downto 0);
        v.ldata := pr.ad; v.lwrite := not r.read; v.start := '1';
      end if;
    end if;

    if (v.state = s_data) and (r.read = '1') then v.oe_ad := '0'; end if;
    v.oe_par := r.oe_ad;
    if r.csel = '1' then v.data := cdata; 
    elsif r.addr(MADDR_WIDTH-1) = '1' then 
      v.data(31 downto MADDR_WIDTH-1) := r.page;
      v.data(MADDR_WIDTH-2 downto 0) := (others => '0');
    else v.data := r2.data; end if;
    v.par := xorv(r.data & pcii.cbe);

    if (v.state = s_data) or (r.state = s_data) then
      v.oe_ctrl := '0';
    else v.oe_ctrl := '1'; end if;

    v.noe_ctrl := not v.oe_ctrl; v.noe_ad := not v.oe_ad; v.noe_par := not v.oe_par;
    
    if oepol = 1 then
      oe_ctrl := r.noe_ctrl; oe_ad := r.noe_ad; oe_par := r.noe_par;
      voe_ad := (others => v.noe_ad);
    else
      oe_ctrl := r.oe_ctrl; oe_ad := r.oe_ad; oe_par := r.oe_par;
      voe_ad := (others => v.oe_ad);
    end if; 
    
    if pr.rst = '0' then
      v.state := idle; v.men := '0'; v.start := '0';
      v.bar0 := (others => '0'); v.msel := '0'; v.csel := '0';
      v.page := (others => '0');
      v.page(31 downto 30) := "01";
    end if;
    rin <= v;
    rioe_ad <= voe_ad;


    pcio.ctrlen   <= oe_ctrl;
    pcio.trdy     <= r.trdy;
    pcio.trdyen   <= oe_ctrl;
    pcio.stop     <= r.stop;
    pcio.stopen   <= oe_ctrl;
    pcio.devsel   <= r.devsel;
    pcio.devselen <= oe_ctrl;
    pcio.par      <= r.par;
    pcio.paren    <= oe_par;
    pcio.aden     <= oe_ad;
    pcio.ad       <= r.data;

    pcio.rst      <= '1';
    
  end process;

  pcir : process (pciclk, pcii.rst, r2)
  begin
    if rising_edge (pciclk) then
      pr.ad         <= to_x01(pcii.ad);
      pr.cbe        <= to_x01(pcii.cbe);
      pr.devsel     <= to_x01(pcii.devsel);
      pr.frame      <= to_x01(pcii.frame);
      pr.idsel      <= to_x01(pcii.idsel);
      pr.irdy       <= to_x01(pcii.irdy);
      pr.trdy       <= to_x01(pcii.trdy);
      pr.par        <= to_x01(pcii.par);
      pr.stop       <= to_x01(pcii.stop);
      pr.rst        <= to_x01(pcii.rst);
      r <= rin;
      roe_ad <= rioe_ad; 
    end if;
    if pcii.rst = '0' then	-- asynch reset required
      r.oe_ctrl <= '1'; r.oe_par <= '1'; r.oe_ad <= '1';
      r.noe_ctrl <= '0'; r.noe_par <= '0'; r.noe_ad <= '0';

      if oepol = 0 then roe_ad <= (others => '1');
      else roe_ad <= (others => '0'); end if; 
    end if;
  end process;

  cpur : process (clk)
  begin
    if rising_edge (clk) then
      r2 <= r2in;
    end if;
  end process;

  oe0 : if oepol = 0 generate 
    pcio.perren  <= '1';
    pcio.cbeen   <= (others => '1');
    pcio.serren  <= '1';
    pcio.inten   <= '1';
    pcio.reqen   <= not pcii.rst;
    pcio.frameen <= '1';
    pcio.irdyen  <= '1';
    pcio.locken  <= '1';
  end generate;

  oe1 : if oepol = 1 generate 
    pcio.perren  <= '0';
    pcio.cbeen   <= (others => '0');
    pcio.serren  <= '0';
    pcio.inten   <= '0';
    pcio.reqen   <= pcii.rst;
    pcio.frameen <= '0';
    pcio.irdyen  <= '0';
    pcio.locken  <= '0';
  end generate;

  pcio.vaden   <= roe_ad;

  pcio.cbe   <= "1111";
  pcio.perr  <= '1';
  pcio.serr  <= '1';
  pcio.int   <= '1';
  pcio.req   <= '1';
  pcio.frame <= '1';
  pcio.irdy  <= '1';
  

  ahbmst0 : ahbmst generic map (hindex => hindex, devid => GAISLER_PCITRG) 
	port map (rst, clk, dmai, dmao, ahbmi, ahbmo);

-- pragma translate_off
    bootmsg : report_version 
    generic map ("pci_target" & tost(hindex) & 
	": 32-bit PCI Target rev " & tost(REVISION) & 
	", " & tost(abits) & "-bit PCI memory BAR" );
-- pragma translate_on


end;
