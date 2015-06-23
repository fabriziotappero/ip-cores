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
-- Entity: 	pci_mt
-- File:	pci_mt.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Modified: 	Alf Vaerneus - Gaisler Research
-- Description:	Simple PCI master and target interface
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
use gaisler.pcilib.all;

entity pci_mt is
  generic (
    hmstndx   : integer := 0;
    abits     : integer := 21;
    device_id : integer := 0;		-- PCI device ID
    vendor_id : integer := 0;	        -- PCI vendor ID
    master    : integer := 1; 		-- Enable PCI Master
    hslvndx   : integer := 0;
    haddr     : integer := 16#F00#;
    hmask     : integer := 16#F00#;
    ioaddr    : integer := 16#000#;
    nsync     : integer range 1 to 2 := 1;	-- 1 or 2 sync regs between clocks
    oepol     : integer := 0
);
   port(
      rst       : in std_logic;
      clk       : in std_logic;
      pciclk    : in std_logic;
      pcii      : in  pci_in_type;
      pcio      : out pci_out_type;
      ahbmi     : in  ahb_mst_in_type;
      ahbmo     : out ahb_mst_out_type;
      ahbsi     : in  ahb_slv_in_type;
      ahbso     : out ahb_slv_out_type
);
end;

architecture rtl of pci_mt is

constant REVISION : amba_version_type := 0;

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_PCISBRG, 0, REVISION, 0),
  4 => ahb_membar(haddr, '0', '0', hmask),
  5 => ahb_iobar (ioaddr, 16#E00#),
  others => zero32);

constant CSYNC : integer := nsync-1;
constant MADDR_WIDTH : integer := abits;
constant HADDR_WIDTH : integer := 28;

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
  gnt      : std_logic;
end record;

type ahbs_input_type is record
  haddr    : std_logic_vector(HADDR_WIDTH - 1 downto 0);
  htrans   : std_logic_vector(1 downto 0);
  hwrite   : std_logic;
  hsize    : std_logic_vector(1 downto 0);
  hburst   : std_logic_vector(2 downto 0);
  hwdata   : std_logic_vector(31 downto 0);
  hsel     : std_logic;
  hiosel     : std_logic;
  hready   : std_logic;
end record;


type pci_target_state_type is (idle, b_busy, s_data, backoff, turn_ar);
type pci_master_state_type is (idle, addr, m_data, turn_ar, s_tar, dr_bus);
type pci_config_command_type is record
  ioen     : std_logic; -- I/O access enable
  men      : std_logic; -- Memory access enable
  msen     : std_logic; -- Master enable
  spcen    : std_logic; -- Special cycle enable
  mwie     : std_logic; -- Memory write and invalidate enable
  vgaps    : std_logic; -- VGA palette snooping enable
  per      : std_logic; -- Parity error response enable
  wcc      : std_logic; -- Address stepping enable
  serre    : std_logic; -- Enable SERR# driver
  fbtbe    : std_logic; -- Fast back-to-back enable
end record;
type pci_config_status_type is record
  c66mhz   : std_logic; -- 66MHz capability
  udf      : std_logic; -- UDF supported
  fbtbc    : std_logic; -- Fast back-to-back capability
  dped     : std_logic; -- Data parity error detected
  dst      : std_logic_vector(1 downto 0); -- DEVSEL timing
  sta      : std_logic; -- Signaled target abort
  rta      : std_logic; -- Received target abort
  rma      : std_logic; -- Received master abort
  sse      : std_logic; -- Signaled system error
  dpe      : std_logic; -- Detected parity error
end record;
type pci_reg_type is record
  addr     : std_logic_vector(MADDR_WIDTH-1 downto 0);
  ad     : std_logic_vector(31 downto 0);
  cbe      : std_logic_vector(3 downto 0);
  lcbe      : std_logic_vector(3 downto 0);
  t_state  : pci_target_state_type; -- PCI target state machine
  m_state  : pci_master_state_type; -- PCI master state machine
  csel     : std_logic; -- Configuration chip select
  msel     : std_logic; -- Memory hit
  read     : std_logic;
  devsel   : std_logic; -- PCI device select
  trdy     : std_logic; -- Target ready
  irdy     : std_logic; -- Master ready
  stop     : std_logic; -- Target stop request
  par      : std_logic; -- PCI bus parity
  req      : std_logic; -- Master bus request
  oe_par   : std_logic;
  oe_ad    : std_logic;
  oe_trdy  : std_logic;
  oe_devsel: std_logic;
  oe_ctrl  : std_logic;
  oe_cbe   : std_logic;
  oe_stop  : std_logic;
  oe_frame : std_logic;
  oe_irdy  : std_logic;
  oe_req   : std_logic;
  noe_par   : std_logic;
  noe_ad    : std_logic;
  noe_trdy  : std_logic;
  noe_devsel: std_logic;
  noe_ctrl  : std_logic;
  noe_cbe   : std_logic;
  noe_stop  : std_logic;
  noe_frame : std_logic;
  noe_irdy  : std_logic;
  noe_req   : std_logic;
  request  : std_logic; -- Request from Back-end
  frame    : std_logic; -- Master frame
  bar0     : std_logic_vector(31 downto MADDR_WIDTH);
  page     : std_logic_vector(31 downto MADDR_WIDTH-1);
  comm     : pci_config_command_type;
  stat     : pci_config_status_type;
  laddr    : std_logic_vector(31 downto 0);
  ldata    : std_logic_vector(31 downto 0);
  pwrite   : std_logic;
  hwrite   : std_logic;
  start    : std_logic;
  hreq     : std_logic;
  hreq_ack : std_logic_vector(csync downto 0);
  preq     : std_logic_vector(csync downto 0);
  preq_ack : std_logic;
  rready   : std_logic_vector(csync downto 0);
  wready   : std_logic_vector(csync downto 0);
  sync     : std_logic_vector(csync downto 0);
  pabort   : std_logic;
  mcnt     : std_logic_vector(2 downto 0);
  maddr    : std_logic_vector(31 downto 0);
  mdata    : std_logic_vector(31 downto 0);
  stop_req : std_logic;
end record;

type cpu_master_state_type is (idle, sync1, busy, sync2);
type cpu_slave_state_type is (idle, getd, req, sync, read, sync2, t_done);

type cpu_reg_type is record
  tdata     : std_logic_vector(31 downto 0); -- Target data
  maddr     : std_logic_vector(31 downto 0); -- Master data
  mdata     : std_logic_vector(31 downto 0); -- Master data
  be       : std_logic_vector(3 downto 0);
  m_state  : cpu_master_state_type; -- AMBA master state machine
  s_state  : cpu_slave_state_type; -- AMBA slave state machine
  start    : std_logic_vector(csync downto 0);
  hreq     : std_logic_vector(csync downto 0);
  hreq_ack : std_logic;
  preq     : std_logic;
  preq_ack : std_logic_vector(csync downto 0);
  sync     : std_logic;
  hwrite   : std_logic; -- AHB write on PCI
  pabort   : std_logic_vector(csync downto 0);
  perror   : std_logic;
  rready   : std_logic;
  wready   : std_logic;
  hrdata   : std_logic_vector(31 downto 0);
  hresp    : std_logic_vector(1 downto 0);
  pciba    : std_logic_vector(3 downto 0);
end record;

signal clk_int : std_logic;
signal pr : pci_input_type;
signal hr : ahbs_input_type;
signal r, rin : pci_reg_type;
signal r2, r2in : cpu_reg_type;
signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;
signal roe_ad, rioe_ad : std_logic_vector(31 downto 0);
attribute syn_preserve : boolean;
attribute syn_preserve of roe_ad : signal is true;
begin

-- Back-end state machine (AHB clock domain)

  comb : process (rst, r2, r, dmao, hr, ahbsi)
  variable vdmai : ahb_dma_in_type;
  variable v : cpu_reg_type;
  variable request : std_logic;
  variable hready : std_logic;
  variable hresp, hsize, htrans : std_logic_vector(1 downto 0);
  variable p_done : std_logic;
  begin
    v := r2;
    vdmai.start := '0'; vdmai.burst := '0'; vdmai.size := "10";
    vdmai.address := r.laddr; v.sync := '1';
    vdmai.wdata := r.ldata; vdmai.write := r.pwrite;
    v.start(0) := r2.start(csync); v.start(csync) := r.start;
    v.hreq(0) := r2.hreq(csync); v.hreq(csync) := r.hreq;

    v.pabort(0) := r2.pabort(csync); v.pabort(csync) := r.pabort;
    v.preq_ack(0) := r2.preq_ack(csync); v.preq_ack(csync) := r.preq_ack;
    hready := '1'; hresp := HRESP_OKAY; request := '0';
    hsize := "10"; htrans := "00";
    p_done := r2.hreq(0) or r2.pabort(0);

---- *** APB register access *** ----

    --if (apbi.psel and apbi.penable and apbi.pwrite) = '1' then
      --v.pciba := apbi.pwdata(31 downto 28);
    --end if;
    --apbo.prdata <= r2.pciba & addzero;

    if hr.hiosel = '1' then
      if hr.hwrite = '1' then v.pciba := ahbsi.hwdata(31 downto 28); end if;
      v.hrdata := r2.pciba & addzero(27 downto 0);
    end if;

---- *** AHB MASTER *** ----

    case r2.m_state is
    when idle =>
      v.sync := '0';
      if r2.start(0) = '1' then
        if  r.pwrite = '1' then v.m_state := sync1; v.wready := '0';
        else v.m_state := busy; vdmai.start := '1'; end if;
      end if;
    when sync1 =>
      if r2.start(0) = '0' then v.m_state := busy; vdmai.start := '1'; end if;
    when busy =>
      if dmao.active = '1' then
        if dmao.ready = '1' then
          v.rready := not r.pwrite; v.tdata := dmao.rdata; v.m_state := sync2;
        end if;
      else vdmai.start := '1'; end if;
    when sync2 =>
      if r2.start(0) = '0' then
        v.m_state := idle;  v.wready := '1'; v.rready := '0';
      end if;
    end case;

---- *** AHB MASTER END *** ----

---- *** AHB SLAVE *** ----

    if MASTER = 1 then

      if (hr.hready and hr.hsel) = '1' then
        hsize := hr.hsize; htrans := hr.htrans;
        if (hr.htrans(1) and r.comm.msen) = '1' then request := '1'; end if;
      end if;

      if (request = '1' and r2.s_state = idle) then
  v.maddr := r2.pciba & hr.haddr;
  v.hwrite := hr.hwrite;
  case hsize is
  when "00" => v.be := "1110"; -- Decode byte enable
  when "01" => v.be := "1100";
  when "10" => v.be := "0000";
  when others => v.be := "1111";
  end case;
      elsif r2.s_state = getd and r2.hwrite = '1' then
  v.mdata := hr.hwdata;
      end if;

      if r2.hreq(0) = '1' then v.hrdata := r.ldata; end if;
      if r2.preq_ack(0) = '1' then v.preq := '0'; end if;
      if r2.pabort(0) = '1' then v.perror := '1'; end if;
      if p_done = '0' then v.hreq_ack := '0'; end if;

    -- AHB slave state machine
      case r2.s_state is
      when idle => if request = '1' then v.s_state := getd; end if;
      when getd => v.s_state := req; v.preq := '1';
      when req => if r2.preq_ack(0) = '1' then v.s_state := sync; end if;
      when sync => if r2.preq_ack(0) = '0' then v.s_state := read; end if;
      when read =>
        if p_done = '1' then v.hreq_ack := '1'; v.s_state := sync2; end if;
      when sync2 => if p_done = '0' then v.s_state := t_done; end if;
      when t_done => if request = '1' then v.s_state := idle; end if;
      when others => v.s_state := idle;
      end case;

      if request = '1' then
        if r2.s_state = t_done then
      if r2.perror = '1' then hresp := HRESP_ERROR;
      else hresp := HRESP_OKAY; end if;
      v.perror := '0';
        else hresp := HRESP_RETRY; end if;
      end if;

      if r.comm.msen = '0' then hresp := HRESP_ERROR; end if; -- Master disabled
      if htrans(1) = '0' then hresp := HRESP_OKAY; end if; -- Response OK for BUSY and IDLE
      if (hresp /= HRESP_OKAY and (hr.hready and hr.hsel) = '1') then  -- insert one wait cycle
        hready := '0';
      end if;

      if hr.hready = '0' then hresp := r2.hresp; end if;
      v.hresp := hresp;

    end if;

---- *** AHB SLAVE END *** ----

    if rst = '0' then
      v.s_state := idle; v.rready := '0'; v.wready := '1';
      v.m_state := idle; v.preq := '0'; v.hreq_ack := '0';
      v.perror := '0'; v.be := (others => '1');
      v.pciba := (others => '0'); v.hresp := (others => '0');
    end if;

    r2in <= v; dmai <= vdmai;

    ahbso.hready <= hready;
    ahbso.hresp  <= hresp;
    ahbso.hrdata <= r2.hrdata;

  end process;

  ahbso.hconfig <= hconfig when MASTER = 1 else (others => zero32);
  ahbso.hsplit <= (others => '0');
  ahbso.hirq   <= (others => '0');
  ahbso.hindex <= hslvndx;

-- PCI target core (PCI clock domain)

  pcicomb : process(pcii.rst, pr, pcii, r, r2, roe_ad)
  variable v : pci_reg_type;
  variable chit, mhit, hit, ready, cwrite : std_logic;
  variable cdata, cwdata : std_logic_vector(31 downto 0);
  variable comp : std_logic; -- Last transaction cycle on PCI bus
  variable iready : std_logic;
  variable mto : std_logic;
  variable tad, mad : std_logic_vector(31 downto 0);
--	variable cbe : std_logic_vector(3 downto 0);
  variable caddr : std_logic_vector(7 downto 2);
  variable voe_ad : std_logic_vector(31 downto 0);
  variable oe_par   : std_logic;
  variable oe_ad    : std_logic;
  variable oe_ctrl  : std_logic;
  variable oe_trdy  : std_logic;
  variable oe_devsel: std_logic;
  variable oe_cbe   : std_logic;
  variable oe_stop  : std_logic;
  variable oe_frame : std_logic;
  variable oe_irdy  : std_logic;
  variable oe_req   : std_logic;
  begin

  -- Process defaults
    v := r; v.trdy := '1'; v.stop := '1'; v.frame := '1';
    v.oe_ad := '1'; v.devsel := '1'; v.oe_frame := '1';
    v.irdy := '1'; v.req := '1'; voe_ad := roe_ad;
    v.oe_req := '0'; v.oe_cbe := '1'; v.oe_irdy := '1';
    v.rready(0) := r.rready(csync); v.rready(csync) := r2.rready;
    v.wready(0) := r.wready(csync); v.wready(csync) := r2.wready;
    v.sync(0) := r.sync(csync); v.sync(csync) := r2.sync;
    v.preq(0) := r.preq(csync); v.preq(csync) := r2.preq;
    v.hreq_ack(0) := r.hreq_ack(csync); v.hreq_ack(csync) := r2.hreq_ack;
    comp := '0'; mto := '0'; tad := r.ad; mad := r.ad; v.stop_req := '0';
    --cbe := r.cbe;


----- *** PCI TARGET *** --------

-- address decoding

    if (r.t_state = s_data) and ((pr.irdy or r.trdy or r.read) = '0') then
      cwrite := r.csel;
      if ((r.msel and r.addr(MADDR_WIDTH-1)) = '1') and (pr.cbe = "0000") then
        v.page := pr.ad(31 downto MADDR_WIDTH-1);
      end if;
      if (pr.cbe = "0000") and  (r.addr(MADDR_WIDTH-1) = '1') then
      end if;
    else cwrite := '0'; end if;
    cdata := (others => '0'); caddr :=  r.addr(7 downto 2);
    case caddr is
    when "000000" =>			-- 0x00, device & vendor id
      cdata := conv_std_logic_vector(DEVICE_ID, 16) &
      conv_std_logic_vector(VENDOR_ID, 16);
    when "000001" =>			-- 0x04, status & command
      cdata(1) := r.comm.men; cdata(2) := r.comm.msen; cdata(25) := '1';
      cdata(28) := r.stat.rta; cdata(29) := r.stat.rma;
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
        v.comm.men := cwdata(1);
        v.comm.msen := cwdata(2);
        v.stat.rta := r.stat.rta and not cwdata(28);
        v.stat.rma := r.stat.rma and not cwdata(29);
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

    case r.t_state is
    when idle  =>
      if pr.frame = '0' then v.t_state := b_busy; end if; -- !HIT ?
      v.addr := pr.ad(MADDR_WIDTH-1 downto 0); -- v.cbe := pr.cbe;
      v.csel := pr.idsel and chit;
      v.msel := r.comm.men and mhit; v.read := not pr.cbe(0);
      if (r.sync(0) and r.start and r.pwrite)  = '1' then v.start := '0'; end if;
    when turn_ar =>
      if pr.frame = '1' then v.t_state := idle; end if;
      if pr.frame = '0' then v.t_state := b_busy; end if; -- !HIT ?
      v.addr := pr.ad(MADDR_WIDTH-1 downto 0); -- v.cbe := pr.cbe;
      v.csel := pr.idsel and chit;
      v.msel := r.comm.men and mhit; v.read := not pr.cbe(0);
      if (r.sync(0) and r.start and r.pwrite)  = '1' then v.start := '0'; end if;
    when b_busy  =>
      if hit = '1' then
        v.t_state := s_data; v.trdy := not ready; v.stop := pr.frame and ready;
        v.devsel := '0';
      else
        v.t_state := backoff;
      end if;
    when s_data  =>
      v.stop := r.stop; v.devsel := '0';
      v.trdy := r.trdy or not pcii.irdy;
      if (pcii.frame and not pcii.irdy) = '1' then
        v.t_state := turn_ar; v.stop := '1'; v.trdy := '1'; v.devsel := '1';
      end if;
    when backoff =>
      if pr.frame = '1' then v.t_state := idle; end if;
    end case;

    if ((r.t_state = s_data) or (r.t_state = turn_ar)) and
       (((pr.irdy or pr.trdy) = '0') or
        ((not pr.irdy and not pr.stop and pr.trdy and not r.start and r.wready(0)) = '1'))
    then
      if (pr.trdy and r.read)= '0' then v.start := '0'; end if;
      if (r.start = '0') and ((r.msel and not r.addr(MADDR_WIDTH-1)) = '1') and
      (((pr.trdy and r.read and not r.rready(0)) or (not pr.trdy and not r.read)) = '1')
      then
        v.laddr := r.page & r.addr(MADDR_WIDTH-2 downto 0);
        v.ldata := pr.ad; v.pwrite := not r.read; v.start := '1';
      end if;
    end if;

--    if (v.t_state = s_data) and (r.read = '1') then v.oe_ad := '0'; end if;
--    v.oe_par := r.oe_ad;

    if r.csel = '1' then tad := cdata;
    elsif r.addr(MADDR_WIDTH-1) = '1' then
      tad(31 downto MADDR_WIDTH-1) := r.page;
      tad(MADDR_WIDTH-2 downto 0) := (others => '0');
    else tad := r2.tdata; end if;

    if (v.t_state = s_data) or (r.t_state = s_data) then
      v.oe_ctrl := '0';
    else v.oe_ctrl := '1'; end if;

----- *** PCI TARGET END*** --------

----- *** PCI MASTER *** --------

  if MASTER = 1 then

    if r.preq(0) = '1' then
          if (r.m_state = idle or r.m_state = dr_bus) and r.request = '0' and r.hreq = '0' then
        v.request := '1';
        v.hwrite := r2.hwrite;
        v.lcbe := r2.be;
        v.mdata := r2.mdata;
        v.maddr :=r2.maddr;
      end if;
    end if;

    if r.hreq_ack(0) = '1' then v.hreq := '0'; v.pabort := '0'; end if;
    if r.preq(0) = '0' then v.preq_ack := '0'; end if;

    comp := not(pcii.trdy or pcii.irdy);

    if ((pr.irdy and not pr.frame) or (pr.devsel and r.frame and not r.oe_frame)) = '1' then -- Covers both master timeout and devsel timeout
      if r.mcnt /= "000" then v.mcnt := r.mcnt - 1;
      else mto := '1'; end if;
    else v.mcnt := (others => '1'); end if;


    -- PCI master state machine
    case r.m_state is
    when idle => -- Master idle
      if (pr.gnt = '0' and (pr.frame and pr.irdy) = '1') then
        if r.request = '1' then v.m_state := addr; v.preq_ack := '1';
        else v.m_state := dr_bus; end if;
      end if;
    when addr => -- Always one address cycle at the beginning of an transaction
      v.m_state := m_data;
    when m_data => -- Master transfers data
        --if (r.request and not pr.gnt and pr.frame and not pr.trdy -- Not supporting address stepping!
        --and pr.stop and l_cycle and sa) = '1' then
        --v.m_state <= addr;
      v.hreq := comp;
      if (pr.frame = '0') or ((pr.frame and pcii.trdy and pcii.stop and not mto) = '1') then
        v.m_state := m_data;
      elsif ((pr.frame and (mto or not pcii.stop)) = '1') then
        v.m_state := s_tar;
      else v.m_state := turn_ar; v.request := '0'; end if;
    when turn_ar => -- Transaction complete
      if (r.request and not pr.gnt) = '1' then v.m_state := addr;
      elsif (r.request or pr.gnt) = '0' then v.m_state := dr_bus;
      else v.m_state := idle; end if;
    when s_tar => -- Stop was asserted
      v.request := pr.trdy and not pr.stop and not pr.devsel;
      v.stop_req := '1';
      if (pr.stop or pr.devsel or pr.trdy) = '0' then -- Disconnect with data
        v.m_state := turn_ar;
      elsif pr.gnt = '0' then
        v.pabort := not v.request;
        v.m_state := dr_bus;
      else v.m_state := idle; v.pabort := not v.request; end if;
    when dr_bus => -- Drive bus when parked on this agent
      if (r.request = '1' and (pcii.gnt or r.req) = '0') then v.m_state := addr; v.preq_ack := '1';
      elsif pcii.gnt = '1' then v.m_state := idle; end if;
    end case;

    if v.m_state = addr then mad := r.maddr; else mad := r.mdata; end if;

    if (pr.irdy or pr.trdy or r.hwrite) = '0'  then v.ldata := pr.ad; end if;

    -- Target abort
    if ((pr.devsel and pr.trdy and not pr.gnt and not pr.stop) = '1') then v.stat.rta := '1'; end if;
    -- Master abort
    if mto = '1' then v.stat.rma := '1'; end if;

    -- Drive FRAME# and IRDY#
    if (v.m_state = addr or v.m_state = m_data) then v.oe_frame := '0'; end if;

    -- Drive CBE#
    if (v.m_state = addr or v.m_state = m_data or v.m_state = dr_bus) then v.oe_cbe := '0'; end if;

    -- Drive IRDY# (FRAME# delayed one pciclk)
    v.oe_irdy := r.oe_frame;

    -- FRAME# assert
      if v.m_state = addr then v.frame := '0'; end if; -- Only single transfers valid

    -- IRDY# assert
    if v.m_state = m_data then v.irdy := '0'; end if;

    -- REQ# assert
    if (v.request = '1' and (v.m_state = idle or r.m_state = idle) and (v.stop_req or r.stop_req) = '0') then v.req := '0'; end if;

    -- C/BE# assert
    if v.m_state = addr then v.cbe := "011" & r.hwrite; else v.cbe := r.lcbe; end if;

  end if;

----- *** PCI MASTER END *** --------

----- *** SHARED BUS SIGNALS *** -------

    -- Drive PAR
    v.oe_par := r.oe_ad; --Delayed one clock
    v.par := xorv(r.ad & r.cbe); -- Default asserted by master
    v.ad := mad;  -- Default asserted by master
    -- Master
    if (v.m_state = addr or (v.m_state = m_data and r.hwrite = '1') or v.m_state = dr_bus) then
      v.oe_ad := '0';
    end if;

    -- Drive AD
    -- Target
    if r.read = '1' then
      if v.t_state = s_data then
        v.oe_ad := '0';
        v.ad := tad;
      elsif r.t_state = s_data then
        v.par := xorv(r.ad & pcii.cbe);
      end if;
    end if;

    v.oe_stop := v.oe_ctrl; v.oe_devsel := v.oe_ctrl; v.oe_trdy := v.oe_ctrl;
    v.noe_ad := not v.oe_ad; v.noe_ctrl := not v.oe_ctrl;
    v.noe_par := not v.oe_par; v.noe_req := not v.oe_req;
    v.noe_frame := not v.oe_frame; v.noe_cbe := not v.oe_cbe;
    v.noe_irdy := not v.oe_irdy;
    v.noe_stop := not v.oe_ctrl; v.noe_devsel := not v.oe_ctrl;
    v.noe_trdy := not v.oe_ctrl;

    if oepol  = 0 then
      voe_ad := (others => v.oe_ad);
      oe_ad := r.oe_ad; oe_ctrl := r.oe_ctrl; oe_par := r.oe_par;
      oe_req := r.oe_req; oe_frame := r.oe_frame; oe_cbe := r.oe_cbe;
      oe_irdy := r.oe_irdy; oe_stop := r.oe_stop; oe_trdy := r.oe_trdy;
      oe_devsel := r.oe_devsel;
    else
      voe_ad := (others => v.noe_ad);
      oe_ad := r.noe_ad; oe_ctrl := r.noe_ctrl; oe_par := r.noe_par;
      oe_req := r.noe_req; oe_frame := r.noe_frame; oe_cbe := r.noe_cbe;
      oe_irdy := r.noe_irdy; oe_stop := r.noe_stop; oe_trdy := r.noe_trdy;
      oe_devsel := r.noe_devsel;
    end if;

----- *** SHARED BUS SIGNALS END *** -------

    if pr.rst = '0' then
      v.t_state := idle; v.m_state := idle; v.comm.men := '0'; v.start := '0';
      v.bar0 := (others => '0'); v.msel := '0'; v.csel := '0';
      v.page := (others => '0'); v.page(31 downto 30) := "01"; v.par := '0';
      v.hwrite := '0'; v.request := '0'; v.comm.msen := '0';
      v.laddr := (others => '0'); v.ldata := (others => '0');
      v.hreq := '0'; v.preq_ack := '0'; v.pabort := '0';
      v.mcnt := (others => '1'); v.maddr := (others => '0');
      v.lcbe := (others => '0'); v.mdata := (others => '0');
      v.pwrite := '0'; v.stop_req := '0';
      v.stat.rta := '0'; v.stat.rma := '0';
    end if;
    rin <= v;
    rioe_ad <= voe_ad;

    pcio.reqen    <= oe_req;
    pcio.req      <= r.req;
    pcio.frameen  <= oe_frame;
    pcio.frame    <= r.frame;
    pcio.irdyen   <= oe_irdy;
    pcio.irdy     <= r.irdy;

    pcio.cbeen    <= (others => oe_cbe);
    pcio.cbe      <= r.cbe;

    pcio.vaden    <= roe_ad;
    pcio.aden     <= oe_ad;
    pcio.ad       <= r.ad;

    pcio.trdy     <= r.trdy;
    pcio.ctrlen   <= oe_ctrl;
    pcio.trdyen   <= oe_trdy;
    pcio.devselen <= oe_devsel;
    pcio.stopen   <= oe_stop;
    pcio.stop     <= r.stop;
    pcio.devsel   <= r.devsel;
    pcio.par      <= r.par;
    pcio.paren    <= oe_par;

    pcio.rst      <= '1';
  
  end process;

  pcir : process (pciclk, pcii.rst)
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
      pr.gnt        <= to_x01(pcii.gnt);
      r <= rin;
      roe_ad <= rioe_ad;
    end if;
    if pcii.rst = '0' then	-- asynch reset required
      	r.oe_ad <= '1'; r.oe_ctrl <= '1'; r.oe_par <= '1'; r.oe_stop <= '1';
	r.oe_req <= '1'; r.oe_frame <= '1'; r.oe_cbe <= '1'; r.oe_irdy <= '1';
	r.oe_trdy <= '1'; r.oe_devsel <= '1';

	r.noe_ad <= '0'; r.noe_ctrl <= '0'; r.noe_par <= '0'; r.noe_req <= '0';
	r.noe_frame <= '0'; r.noe_cbe <= '0'; r.noe_irdy <= '0'; r.noe_stop <= '0';
	r.noe_trdy <= '0'; r.noe_devsel <= '0';

	if oepol = 0 then roe_ad <= (others => '1');
	else roe_ad <= (others => '0'); end if;
    end if;
  end process;

  cpur : process (rst,clk)
  begin
    if rising_edge (clk) then
      hr.haddr    <= ahbsi.haddr(HADDR_WIDTH - 1 downto 0);
      hr.htrans   <= ahbsi.htrans;
      hr.hwrite   <= ahbsi.hwrite;
      hr.hsize    <= ahbsi.hsize(1 downto 0);
      hr.hburst   <= ahbsi.hburst;
      hr.hwdata   <= ahbsi.hwdata;
      hr.hsel     <= ahbsi.hsel(hslvndx) and ahbsi.hmbsel(0);
      hr.hiosel   <= ahbsi.hsel(hslvndx) and ahbsi.hmbsel(1);
      hr.hready   <= ahbsi.hready;
      r2 <= r2in;
    end if;
  end process;


  oe0 : if oepol = 0 generate
    pcio.perren   <= '1';
    pcio.serren   <= '1';
    pcio.inten    <= '1';
    pcio.locken   <= '1';
  end generate;

  oe1 : if oepol = 1 generate
    pcio.perren   <= '0';
    pcio.serren   <= '0';
    pcio.inten    <= '0';
    pcio.locken   <= '0';
  end generate;


  pcio.perr     <= '1';
  pcio.serr     <= '1';
  pcio.int      <= '1';





  msttgt : if MASTER = 1 generate

    ahbmst0 : ahbmst generic map (hindex => hmstndx, devid => GAISLER_PCISBRG)
	port map (rst, clk, dmai, dmao, ahbmi, ahbmo);

-- pragma translate_off
    bootmsg : report_version
    generic map ("pci_mt" & tost(hslvndx) &
	": Simple 32-bit PCI Bridge, rev " & tost(REVISION) &
	", " & tost(2**abits/2**20) & " Mbyte PCI memory BAR" );
-- pragma translate_on

  end generate;

  tgtonly : if MASTER = 0 generate
    ahbmst0 : ahbmst generic map (hindex => hmstndx, devid => GAISLER_PCITRG)
	port map (rst, clk, dmai, dmao, ahbmi, ahbmo);

-- pragma translate_off
    bootmsg : report_version
    generic map ("pci_mt" & tost(hmstndx) &
	": Simple 32-bit Bridge, target-only, rev " & tost(REVISION) &
	", " & tost(2**abits/2**20) & " Mbyte PCI memory BAR" );
-- pragma translate_on
  end generate;

end;

