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
-- Entity:  pci_mtf
-- File:   pci_mtf.vhd
-- Author:  Jiri Gaisler - Gaisler Research
-- Modified:  Alf Vaerneus - Gaisler Research
-- Description: PCI master and target interface
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.pci.all;
use gaisler.pcilib.all;
use gaisler.misc.all;

entity pci_mtf is
  generic (
    memtech   : integer := DEFMEMTECH;
    hmstndx   : integer := 0;
    dmamst    : integer := NAHBMST;
    readpref  : integer := 0;
    abits     : integer := 21;
    dmaabits  : integer := 26;
    fifodepth : integer := 3; -- FIFO depth
    device_id : integer := 0; -- PCI device ID
    vendor_id : integer := 0; -- PCI vendor ID
    master    : integer := 1; -- Enable PCI Master
    hslvndx   : integer := 0;
    pindex    : integer := 0;
    paddr     : integer := 0;
    pmask     : integer := 16#fff#;
    haddr     : integer := 16#F00#;
    hmask     : integer := 16#F00#;
    ioaddr    : integer := 16#000#;
    irq       : integer := 0;
    irqmask   : integer := 0;
    nsync     : integer range 1 to 2 := 2;	-- 1 or 2 sync regs between clocks
    oepol     : integer := 0;
    endian    : integer := 0;   -- 0 little, 1 big
    class_code: integer := 16#0B4000#;
    rev       : integer := 0;
    scanen    : integer := 0;
    syncrst   : integer := 0;
    hostrst   : integer := 0);
   port(
      rst       : in std_logic;
      clk       : in std_logic;
      pciclk    : in std_logic;
      pcii      : in  pci_in_type;
      pcio      : out pci_out_type;
      apbi      : in apb_slv_in_type;
      apbo      : out apb_slv_out_type;
      ahbmi     : in  ahb_mst_in_type;
      ahbmo     : out ahb_mst_out_type;
      ahbsi     : in  ahb_slv_in_type;
      ahbso     : out ahb_slv_out_type
);
end;

architecture rtl of pci_mtf is

function byte_twist(di : in std_logic_vector(31 downto 0); enable : in std_logic) return std_logic_vector is
  variable do : std_logic_vector(31 downto 0);
begin
  if enable = '1' then
    for i in 0 to 3 loop
      do(31-i*8 downto 24-i*8) := di(31-(3-i)*8 downto 24-(3-i)*8);
    end loop;
  else
    do := di;
  end if;
  return do; 
end function;

function nr_of_1(di : in integer) return integer is
    variable vec : unsigned(31 downto 0);
    variable ones : integer;
begin
    ones := 0;
    vec := to_unsigned(di,32);
    for i in 0 to 31 loop
        if vec(i) = '1' then
            ones := ones + 1;
        end if;
    end loop;
    return ones;
end function;

constant REVISION : amba_version_type := rev;
constant CSYNC : integer := nsync-1;
constant HADDR_WIDTH : integer := 28;
constant MADDR_WIDTH : integer := abits;
constant DMAMADDR_WIDTH : integer := dmaabits;
constant FIFO_DEPTH : integer := fifodepth;
constant FIFO_FULL : std_logic_vector(FIFO_DEPTH - 2 downto 0) := (others => '1');
constant FIFO_DATA_BITS : integer := 32; -- One valid bit
constant NO_CPU_REGS : integer := 6;
constant NO_PCI_REGS : integer := 6;
constant HMASK_WIDTH : integer := nr_of_1(hmask);

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_PCIFBRG, 0, REVISION, irq),
  1 => apb_iobar(paddr, pmask));

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_PCIFBRG, 0, REVISION, 0),
  4 => ahb_membar(haddr, '0', '0', hmask),
  5 => ahb_iobar (ioaddr, 16#E00#),
  others => zero32);

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
  gnt      : std_logic;
  host     : std_logic;
end record;

type pci_fifo_in_type is record
  ren : std_logic;
  raddr : std_logic_vector(FIFO_DEPTH - 1 downto 0);
  wen : std_logic;
  waddr : std_logic_vector(FIFO_DEPTH - 1 downto 0);
  wdata : std_logic_vector(FIFO_DATA_BITS - 1 downto 0);
end record;

type pci_fifo_out_type is record
  rdata : std_logic_vector(FIFO_DATA_BITS - 1 downto 0);
end record;

type fifo_type is record
  side     : std_logic; -- Owner access side. Receiver accesses the other side
  raddr    : std_logic_vector(FIFO_DEPTH - 2 downto 0);
  waddr    : std_logic_vector(FIFO_DEPTH - 2 downto 0);
end record;

type pci_target_state_type is (idle, b_busy, s_data, backoff, turn_ar);
type pci_master_state_type is (idle, addr, m_data, turn_ar, s_tar, dr_bus);
type pci_master_fifo_state_type is (idle, addr, incr, last1, sync, t_retry, ttermwd, ttermnd, abort, done, wdone);

type pci_target_type is record
  state    : pci_target_state_type;
  cnt      : std_logic_vector(2 downto 0);
  csel     : std_logic; -- Configuration chip select
  msel     : std_logic; -- Memory hit
  barsel   : std_logic; -- Memory hit
  psel     : std_logic; -- Page hit
  addr     : std_logic_vector(31 downto 0);
  laddr    : std_logic_vector(31 downto 0);
  lsize    : std_logic_vector(1 downto 0);
  lcbe     : std_logic_vector(3 downto 0);
  lwrite   : std_logic;
  lburst   : std_logic;
  lmult    : std_logic;
  mult     : std_logic;
  read     : std_logic; -- PCI target read
  burst    : std_logic;
  pending  : std_logic;
  wdel     : std_logic;
  last     : std_logic;
  fifo     : fifo_type;
  trdy_del : std_logic; -- (delay trdy to send last word in fifo) bug fix *** 
end record;

type pci_master_type is record
  state    : pci_master_state_type;
  fstate   : pci_master_fifo_state_type;
  cnt      : std_logic_vector(2 downto 0);
  ltim     : std_logic_vector(7 downto 0); -- Latency timer
  request  : std_logic;
  hwrite   : std_logic;
  stop_req : std_logic;
  last     : std_logic;
  valid    : std_logic;
  split    : std_logic;
  first    : std_logic;
  firstw   : std_logic;
  fifo     : fifo_type;
  rmdone   : std_logic; -- bug fix ***
  stopframe: std_logic;
  lto      : std_logic; -- bug fix latency timer timeout
end record;

type pci_sync_regs is array (0 to NO_PCI_REGS - 1) of std_logic_vector(csync downto 0);

type pci_reg_type is record
  pci       : pci_sigs_type;
  noe_par   : std_logic;
  noe_ad    : std_logic;
  noe_ctrl  : std_logic;
  noe_cbe   : std_logic;
  noe_frame : std_logic;
  noe_irdy  : std_logic;
  noe_req   : std_logic;
  noe_perr  : std_logic;
  m         : pci_master_type;
  t         : pci_target_type;
  comm      : pci_config_command_type; -- Command register
  stat      : pci_config_status_type; -- Status register
  bar0      : std_logic_vector(31 downto MADDR_WIDTH); -- Base Address register 0
  bar1      : std_logic_vector(31 downto DMAMADDR_WIDTH); -- Base Address register 1
  bar0_conf : std_logic;
  bar1_conf : std_logic;
  page      : std_logic_vector(31 downto MADDR_WIDTH-1); -- AHB page
  bt_enable : std_logic;                    -- Byte twist enable, page0 bit 0
  ltim      : std_logic_vector(7 downto 0); -- Latency timer
  cline     : std_logic_vector(7 downto 0); -- Cache Line Size
  intline   : std_logic_vector(7 downto 0); -- Interrupt Line
  syncs     : pci_sync_regs;
  trans     : std_logic_vector(NO_CPU_REGS - 1 downto 0);
end record;

type cpu_master_state_type is (idle, cbe_prepare, write, read_w, read, stop);
type cpu_slave_state_type is (idle, w_wait, t_data, r_hold, r_wait, w_done, t_done);

type cpu_master_type is record
  state     : cpu_master_state_type; -- AMBA master state machine
  dmaddr    : std_logic_vector(31 downto 0);
  fifo      : fifo_type;
  cbe_fifo  : fifo_type;
  cur_cbe   : std_logic_vector(3 downto 0);
  cbe_prep_cnt : std_ulogic;
  read_half : std_logic;
  last_side_wr : std_ulogic;
end record;

type cpu_slave_type is record
  state       : cpu_slave_state_type; -- AMBA slave state machine
  maddr       : std_logic_vector(31 downto 0);
  mdata       : std_logic_vector(31 downto 0);
  be          : std_logic_vector(3 downto 0);
  perror      : std_logic;
  hresp       : std_logic_vector(1 downto 0);
  hready      : std_logic;
  htrans      : std_logic_vector(1 downto 0);
  hmaster     : std_logic_vector(3 downto 0); 
  pcicomm     : std_logic_vector(3 downto 0);
  hold        : std_logic;
  fifos_write : std_logic;
  fifo        : fifo_type;
  last_side   : std_logic;
end record;

type cpu_sync_regs is array (0 to NO_CPU_REGS - 1) of std_logic_vector(csync downto 0);

type cpu_reg_type is record
  m        : cpu_master_type;
  s        : cpu_slave_type;
  syncs    : cpu_sync_regs;
  trans    : std_logic_vector(NO_PCI_REGS - 1 downto 0);
  pciba    : std_logic_vector(HMASK_WIDTH-1 downto 0);
  cfto     : std_logic;
  wcomm    : std_logic;
  rcomm    : std_logic;
  werr     : std_logic;
  clscnt   : std_logic_vector(8 downto 0);
  dmapage  : std_logic_vector(31 downto DMAMADDR_WIDTH); -- DMA page
  ioba     : std_logic_vector(15 downto 0);
  pciirq   : std_logic_vector(1 downto 0);
  bus_nr   : std_logic_vector(3 downto 0);
end record;

signal clk_int : std_logic;
signal pr : pci_input_type;
signal r, rin : pci_reg_type;
signal r2, r2in : cpu_reg_type;
signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;
signal fifo1i, fifo2i, fifo3i, fifo4i, cbe_fifoi : pci_fifo_in_type;
signal fifo1o, fifo2o, fifo3o, fifo4o, cbe_fifoo : pci_fifo_out_type;
signal roe_ad, rioe_ad : std_logic_vector(31 downto 0); 
signal pcirst  : std_logic;
signal prrst  : std_logic;
signal pcirstin : std_logic;
attribute sync_set_reset : string;
attribute sync_set_reset of prrst : signal is "true";
attribute async_set_reset : string;
attribute async_set_reset of pcirst : signal is "true";

attribute syn_preserve : boolean;
attribute syn_preserve of roe_ad : signal is true; 
begin

-----------------------------------------------
-- Back-end state machine (AHB clock domain) --
-----------------------------------------------
    
    comb : process (rst, r2, r, dmao, ahbsi, fifo2o, fifo4o, apbi)
        
        variable vdmai : ahb_dma_in_type;
        variable v : cpu_reg_type;
        variable hready : std_logic;
        variable hresp, hsize : std_logic_vector(1 downto 0);
        variable p_done, wsdone, wmdone, rtdone, rmdone : std_logic;
        variable pstart, habort, hstart_ack : std_logic;
        variable hstart, pabort, pstart_ack, pcidc : std_logic;
        variable i : integer range 0 to NO_CPU_REGS;
        variable fifom_write, fifos_write : std_logic;
        variable prdata : std_logic_vector(31 downto 0);
        variable wmvalid, wsvalid, rmvalid, rsvalid, burst_read, hold : std_logic;
        variable fifors_limit, fifows_limit,fiform_limit, fifowm_limit, fifows_stop : std_logic;
        variable comp, request, s_read_side, m_read_side : std_logic;
        variable ahb_access : std_logic; -- *** access control fix
        variable start, single_access : std_logic;
        variable next_cbe : std_logic_vector(3 downto 0);
        variable byteaddr : std_logic_vector(1 downto 0);
        
    begin

        
        v := r2;
        vdmai.start := '0'; 
        vdmai.irq := '0'; vdmai.busy := '0'; vdmai.burst := '1';
        vdmai.wdata := fifo2o.rdata(31 downto 0); vdmai.write := r.t.lwrite;
        rmvalid := '1'; wmvalid := '1'; request := '0'; hold := '0';
        rsvalid := '1'; wsvalid := '1'; burst_read := '0';
        hready := '1'; hresp := HRESP_OKAY; hsize := "10";
        fifom_write := '0'; v.s.fifos_write := '0';
        comp := '0'; prdata := (others => '0'); v.s.hold := '0';
        s_read_side := not r.m.fifo.side; m_read_side := not r.t.fifo.side;
        ahb_access := '0'; -- *** access control fix
       
        -- Synch registers
        pstart     := r2.trans(0);
        habort     := r2.trans(1);
        hstart_ack := r2.trans(2);
--    fifows_limit := r2.trans(3);
        wsdone     := r2.trans(4);
        wmdone     := r2.trans(5);

        for i in 0 to NO_CPU_REGS - 1 loop
            v.syncs(i)(csync) := r.trans(i);
            if csync /= 0 then v.syncs(i)(0) := r2.syncs(i)(csync); end if;
        end loop;

        hstart      := r2.syncs(0)(0);
        pabort      := r2.syncs(1)(0);
        pstart_ack  := r2.syncs(2)(0);
        pcidc       := r2.syncs(3)(0);
        rtdone      := r2.syncs(4)(0);
        rmdone      := r2.syncs(5)(0);

        p_done := pstart_ack or pabort;

        if r2.m.fifo.raddr = FIFO_FULL then fiform_limit := '1'; else fiform_limit := '0'; end if;
        
        if r2.m.fifo.waddr = FIFO_FULL then fifowm_limit := '1'; else fifowm_limit := '0'; end if;
        if r2.s.fifo.raddr = FIFO_FULL then fifors_limit := '1'; else fifors_limit := '0'; end if;
        if r2.s.fifo.waddr = FIFO_FULL then fifows_limit := '1'; else fifows_limit := '0'; end if;
        if r2.s.fifo.waddr(FIFO_DEPTH - 2 downto 1) = FIFO_FULL(FIFO_DEPTH - 2 downto 1) then fifows_stop := '1'; else fifows_stop := '0'; end if;

-----------------------------------
---- APB Control & Status regs ----
-----------------------------------
        
        if (apbi.psel(pindex) and apbi.penable) = '1' then
            case apbi.paddr(4 downto 2) is
                when "000" =>
                    if apbi.pwrite = '1' then
                        v.pciba := apbi.pwdata(31 downto 31-HMASK_WIDTH+1);
                        v.bus_nr := apbi.pwdata(26 downto 23);
                        v.werr := r2.werr and not apbi.pwdata(14);
                        v.wcomm := apbi.pwdata(10) and r.comm.mwie;
                        v.rcomm := apbi.pwdata(9);
                    end if;
                    prdata(31 downto 31-HMASK_WIDTH+1) := r2.pciba;
                    prdata(26 downto 23) := r2.bus_nr;
                    prdata(22 downto 0) := r.ltim & r2.werr & not pr.host & r.comm.msen & r.comm.men & r2.wcomm & r2.rcomm & r2.cfto & r.cline;
                when "001" =>
                    prdata := r.bar0(31 downto MADDR_WIDTH) & addzero(MADDR_WIDTH-1 downto 0);
                when "010" =>
                    prdata := r.page(31 downto MADDR_WIDTH-1) & addzero(MADDR_WIDTH-2 downto 1) & r.bt_enable;
                when "011" =>
                    prdata := r.bar1(31 downto DMAMADDR_WIDTH) & addzero(DMAMADDR_WIDTH-1 downto 0);
                when "100" =>
                    if apbi.pwrite = '1' then
                        v.dmapage(31 downto DMAMADDR_WIDTH) := apbi.pwdata(31 downto DMAMADDR_WIDTH);
                    end if;
                    prdata := r2.dmapage(31 downto DMAMADDR_WIDTH) & addzero(DMAMADDR_WIDTH-1 downto 0);
                when "101" =>
                    if apbi.pwrite = '1' then
                        v.ioba := apbi.pwdata(31 downto 16);
                    end if;
                    prdata := r2.ioba & addzero(15 downto 4) & hstart & hstart_ack & pstart & pstart_ack;
                when "110" =>
                    prdata(1) := r.comm.men; prdata(2) := r.comm.msen;
                    prdata(4) := r.comm.mwie; prdata(6) := r.comm.per;
                    prdata(24) := r.stat.dped; prdata(26) := '1';
                    prdata(27) := r.stat.sta; prdata(28) := r.stat.rta;
                    prdata(29) := r.stat.rma; prdata(31) := r.stat.dpe;
                when others =>
            end case;
        end if;
        
---------------------
---- AHB MASTER  ----
---------------------
        
        -- Burst control
        if (r2.m.state = read or r2.m.state = read_w) then
            if r.t.lmult = '1' then
                comp := fifowm_limit and r2.m.fifo.side;
            elsif r.t.lburst = '1' then
                if r2.clscnt(8) = '1' then comp := '1';
                else v.clscnt := r2.clscnt - (dmao.active and dmao.ready); end if;
            else comp := '1'; end if;
        else
            v.clscnt := '0' & (r.cline - '1'); -- set burst counter to cache line size
        end if;
     
        if (rtdone = '1' and (r2.m.fifo.raddr + '1') = r.t.fifo.waddr) then rmvalid := '0'; end if;

        -- step DMA address
        if dmao.ready = '1' then
            v.m.dmaddr(31 downto 2) := r2.m.dmaddr(31 downto 2) + '1';
        end if;

        -- Translate current CBE to hsize and address
        byteaddr := "00";        
        if endian = 0 then -- pci is little endian
            case r2.m.cur_cbe is
                when "0000" =>       -- 32 bit access
                    vdmai.size := "10";  byteaddr  := "00";
                when "1100" =>       -- 16 bit 
                    vdmai.size := "01";  byteaddr  := "00";
                when "0011" =>
                    vdmai.size := "01";  byteaddr  := "10";
                when "1110" =>       -- 8 bit
                    vdmai.size := "00";  byteaddr  := "00";
                when "1101" =>
                    vdmai.size := "00";  byteaddr  := "01";
                when "1011" =>
                    vdmai.size := "00";  byteaddr  := "10";
                when "0111" =>
                    vdmai.size := "00";  byteaddr  := "11";
                when others => vdmai.size := "10";
            end case;
        else -- big endian
            case  r2.m.cur_cbe is
                when "0000" =>       -- 32 bit access
                    vdmai.size := "10";  byteaddr  := "00";
                when "0011" =>       -- 16 bit 
                    vdmai.size := "01";  byteaddr  := "00";
                when "1100" =>
                    vdmai.size := "01";  byteaddr  := "10";
                when "0111" =>       -- 8 bit
                    vdmai.size := "00";  byteaddr  := "00";
                when "1011" =>
                    vdmai.size := "00";  byteaddr  := "01";
                when "1101" =>
                    vdmai.size := "00";  byteaddr  := "10";
                when "1110" =>
                    vdmai.size := "00";  byteaddr  := "11";
                when others => vdmai.size := "10";
            end case;
        end if;

        vdmai.address := r2.m.dmaddr(31 downto 2) & byteaddr;
        next_cbe := cbe_fifoo.rdata(3 downto 0);
        
        -- AHB master state machine
        case r2.m.state is
            
            when idle =>
                v.m.read_half := '0';
                v.m.last_side_wr := '0';
                v.m.cur_cbe := (others => '0');
                v.m.fifo.waddr := (others => '0');

                if hstart = '1' then
                    
                    wmdone         := '0';
                    fifowm_limit   := '0';
--                    v.m.fifo.waddr := (others => '0');
                                        
                    if r.t.lwrite = '1'  then

                        v.m.dmaddr := r.t.laddr;
                        v.m.state := write;
                        v.m.cur_cbe := cbe_fifoo.rdata(3 downto 0);

                        -- burst access
                        if rtdone = '0' or conv_integer(r.t.fifo.waddr) /= 1 then
                            v.m.cbe_fifo.raddr := r2.m.cbe_fifo.raddr + 1;
                            v.m.state := cbe_prepare;
                            v.m.cbe_prep_cnt := '1';
                        end if;

--                      vdmai.busy := '1';
--                      if rmvalid = '1' then v.m.state := write;
--                      else vdmai.start := '0'; v.m.state := stop; end if;
                        
                    else
                        vdmai.start := '1';
                        v.m.state := read_w;
                    end if;
                    
                else v.m.dmaddr := r.t.laddr; end if;

            when cbe_prepare =>
                v.m.cur_cbe := next_cbe;

                -- Need to wait for correct cycle to sample next
                -- cbe if we have switched FIFO side.
                if r2.m.cbe_prep_cnt = '1' then
                    v.m.state := write;
                else
                    v.m.cbe_prep_cnt := '1';
                end if;
                
            when write =>

                start := '0';

                --if fiform_limit = '1' then
                --if fiform_limit = '1' and dmao.start = '1' then  -- 1k bug fix (store last word in first 
                --    v.m.read_half := '1';                        --             fifo half if addr = 0x400 ...)
                --end if;
                if fiform_limit = '1' and dmao.start = '1' and dmao.ready = '1' then  -- 1k bug fix (store last word in first 
                    v.m.read_half := '1';                        --             fifo half if addr = 0x400 ...)
                end if;
                
                -- Don't start again until PCI side is done filling second half of fifo (bug fix kc)
                if r2.m.read_half = '1' then
                    if rtdone = '1' then
                        start := ((rmvalid and not fiform_limit) or (not dmao.active and not rmvalid));
                    end if;
                else
--                  vdmai.start := ((rmvalid and not fiform_limit) or (not dmao.active and not rmvalid));
                    -- 1k bug fix (store last word in first fifo half if addr = 0x400 ...)

                    start := ((rmvalid and not v.m.read_half) or (not dmao.active and not rmvalid));
                end if;
                                
                -- Burst CBE handling
                if rtdone = '0' or conv_integer(r.t.fifo.waddr) /= 1 then 

                    -- Current or access is subword. Must be forced to single access
                    if r2.m.cur_cbe /= "0000" then
                        
                        vdmai.burst := '0';
                        
                        if dmao.active = '1' then
                            start := '0';
                        end if;
                            
                    end if;

                    -- Next access is subword. Make current access last in burst
                    if rmvalid = '1' and next_cbe /= "0000" then
                        
                        if dmao.active = '1' then
                            start := '0';
                        end if;
                            
                    end if;
                    
                end if;

                vdmai.start := start;

                -- End of data phase for access with cur_cbe
                if (dmao.active and dmao.ready) = '1' then

                    v.m.fifo.raddr     := r2.m.fifo.raddr     + (rmvalid and not fiform_limit and not dmao.mexc);
                    v.m.cbe_fifo.raddr := r2.m.cbe_fifo.raddr + (rmvalid and not fiform_limit and not dmao.mexc);

                    v.m.last_side_wr := m_read_side;
                    
                    -- First half of FIFO
                    if v.m.read_half = '0' then
                        v.m.cur_cbe := next_cbe;
                        
                    -- FIFO side switch
                    elsif r2.m.read_half = '0' then
                        v.m.cbe_prep_cnt := '0';
                        v.m.state := cbe_prepare;

                    elsif v.m.last_side_wr = '0' then
                        v.m.cbe_prep_cnt := '0';
                        v.m.state := cbe_prepare;
                        
                    -- Second side of FIFO
                    else
                        v.m.cur_cbe := next_cbe;
                    end if;

                    if (dmao.mexc = '1' or rmvalid = '0') then
                        habort := dmao.mexc and not r.t.lwrite;
                        v.werr := r2.werr or (dmao.mexc and r.t.lwrite);
                        v.m.state := stop;
                    end if;
                end if;
                
            when read_w =>
                
                vdmai.start := not (comp and dmao.active);

                if dmao.mexc = '1' then
                    habort := not r.t.lwrite;
                    v.werr := '1';
                    v.m.state := stop;
                    
                elsif dmao.ready = '1' then
                    fifom_write := '1';
                    wmvalid := not (comp or dmao.mexc);
                    if comp = '1' then
                        v.m.state := stop;
                        v.m.fifo.waddr := r2.m.fifo.waddr + '1';
                        
                    else
                        v.m.fifo.waddr := r2.m.fifo.waddr + (not fifowm_limit);
                        v.m.state := read; end if;
                end if;
                
            when read =>
                
                vdmai.start := not (comp and dmao.active);
                fifom_write := dmao.ready; wmvalid := not (comp or dmao.mexc);
--      if ((comp and dmao.ready) or dmao.retry) = '1' then
                if (comp and dmao.ready) = '1' then
                    v.m.state := stop; v.m.fifo.waddr := r2.m.fifo.waddr + '1';
                elsif (dmao.active and dmao.ready) = '1' then
                    v.m.fifo.waddr := r2.m.fifo.waddr + (not dmao.mexc and not fifowm_limit);
                    if dmao.mexc = '1' then habort := not r.t.lwrite; v.werr := r2.werr or r.t.lwrite; v.m.state := stop; end if;
                end if;
                
            when stop =>
                
                if hstart = '0' and ((r.t.lwrite and not fiform_limit) = '1' or wmdone = '1') then
                    v.m.state := idle; hstart_ack := '0';
                    v.m.fifo.side := '0'; habort := '0';

                    v.m.fifo.raddr := (others => '0');
                    v.m.cbe_fifo.raddr := (others => '0');
                else
                    comp := '1';
                    fiform_limit := r.t.lwrite;
                    fifowm_limit := not r.t.lwrite;
                end if;
        end case;

        -- FIFO control
        if fifowm_limit = '1' then
--      if (((r2.m.fifo.side or hstart_ack or (not hstart)) = '0' and not (dmao.active and not dmao.ready) = '1')
            if (((r2.m.fifo.side or hstart_ack or (not hstart)) = '0' and (dmao.ready or comp) = '1')
                or ((hstart_ack and not hstart) = '1' and v.m.state = stop)) then
                if v.m.state = stop then wmdone := '1';
                else v.m.fifo.waddr := (others => '0'); end if;
                hstart_ack := '1';
                v.m.fifo.side := not r2.m.fifo.side;
            end if;
        elsif fiform_limit = '1' then
--      if dmao.active = '0' then
            if dmao.active = '0' and dmai.start = '0' then -- 1k bug fix ***
                m_read_side := '1';
                hstart_ack := '1';
--        v.m.fifo.raddr := (others => hstart);

                v.m.fifo.raddr := (others => '0'); -- 1k bug fix ***
                v.m.cbe_fifo.raddr := conv_std_logic_vector(1, FIFO_DEPTH-1);
                
            end if;
        end if;

-----------------------        
--- AHB MASTER END ----
-----------------------

        
-------------------
---- AHB SLAVE ----
-------------------
        
--    if MASTER = 1 then

        -- Access decode
        if (ahbsi.hready and ahbsi.hsel(hslvndx)) = '1' then
            if (ahbsi.hmbsel(0) or ahbsi.hmbsel(1)) = '1' then
                hsize := ahbsi.hsize(1 downto 0); v.s.htrans := ahbsi.htrans;
                --if (v.s.htrans(1) and r.comm.msen) = '1' then request := '1'; end if;
                if (v.s.htrans(1) and r.comm.msen) = '1' then -- fix access control ***
                    ahb_access := '1';
                    --if (r2.s.state /= r_wait and r2.s.state /= r_hold) or r2.s.hmaster = ahbsi.hmaster then
                    --if (r2.s.state = idle or r2.s.state = t_done) or r2.s.hmaster = ahbsi.hmaster then
                    if (r2.s.state = idle) or r2.s.hmaster = ahbsi.hmaster then
                        request := '1';
                    end if;
                end if;
            end if;
        end if;

        -- Access latches
        if (request = '1' and r2.s.state = idle) then
            
            if ahbsi.hmbsel(1)  = '1' then
                if ahbsi.haddr(16) = '1' then -- Configuration cycles

                    v.s.maddr := (others => '0');
                    
                    if r2.bus_nr = "0000" then -- Type 0
                        
                        v.s.maddr(conv_integer(ahbsi.haddr(15 downto 11)) + 10) := '1';
                        v.s.maddr(10 downto 0) := ahbsi.haddr(10 downto 2) & "00";

                    else -- Type 1

                        v.s.maddr(19 downto 0) := r2.bus_nr & ahbsi.haddr(15 downto 2) & "01";

                    end if;

                    v.s.pcicomm := "101" & ahbsi.hwrite;
                    
                else -- I/O space access
                    
                    v.s.maddr(31 downto 16) := r2.ioba;
                    v.s.maddr(15 downto 0) := ahbsi.haddr(15 downto 0);
                    v.s.pcicomm := "001" & ahbsi.hwrite;
                    
                end if;
                
            else -- Memory space access
                
                if conv_integer(ahbsi.hmaster) = dmamst then
                    v.s.maddr := ahbsi.haddr;
                else
                    v.s.maddr := r2.pciba & ahbsi.haddr(31-HMASK_WIDTH downto 2) & "00";
                end if;
                
                if ahbsi.hwrite = '1' then
                    v.s.pcicomm := r2.wcomm & "111";
                else
                    v.s.pcicomm := ahbsi.hburst(0) & '1' & (r2.rcomm or not ahbsi.hburst(0)) & '0';
                end if;
                
            end if;

            -- Decode HSIZE and HADDR
            if endian = 0 then -- pci is little endian
                
                case hsize is
                    when "00" => -- Decode byte enable
                        case ahbsi.haddr(1 downto 0) is
                            when "00" => v.s.be := "1110";
                            when "01" => v.s.be := "1101";
                            when "10" => v.s.be := "1011";
                            when "11" => v.s.be := "0111";
                            when others => v.s.be := "1111";
                        end case;
                    when "01" =>
                        case ahbsi.haddr(1 downto 0) is
                            when "00" =>   v.s.be := "1100";
                            when "10" =>   v.s.be := "0011";
                            when others => v.s.be := "1111";
                        end case;
                    when  "10" => v.s.be := "0000";
                    when others => v.s.be := "1111";
                end case;
                
            else     -- pci is big endian
                
                case hsize is
                    when "00" => -- Decode byte enable
                        case ahbsi.haddr(1 downto 0) is
                            when "00" => v.s.be   := "0111";
                            when "01" => v.s.be   := "1011";
                            when "10" => v.s.be   := "1101";
                            when "11" => v.s.be   := "1110";
                            when others => v.s.be := "1111";
                        end case;
                    when "01" =>
                        case ahbsi.haddr(1 downto 0) is
                            when "00" =>   v.s.be := "0011";
                            when "10" =>   v.s.be := "1100";
                            when others => v.s.be := "1111";
                        end case;
                    when  "10" => v.s.be := "0000";
                    when others => v.s.be := "1111";
                end case;

            end if;

        end if;

        if ((rmdone and not r2.s.pcicomm(0)) = '1' and (r2.s.fifo.raddr + '1' + pcidc) = r.m.fifo.waddr) then rsvalid := '0'; end if;

        -- FIFO address counters
--      if (r2.s.state = t_data or r2.s.state = w_wait) then
        if (r2.s.state = t_data or r2.s.state = w_wait or  -- bug fix ***
            (r2.s.state = r_hold and fifors_limit = '0' and ((pstart_ack or pstart) = '0') and request = '1')) then -- (r_hold -> t_data) bug fix ***
            v.s.fifos_write := r2.s.pcicomm(0) and r2.s.htrans(1);
            v.s.fifo.waddr := r2.s.fifo.waddr + r2.s.fifos_write;
            v.s.fifo.raddr := r2.s.fifo.raddr + ((ahbsi.htrans(1) and not r2.s.pcicomm(0) and not fifors_limit and rsvalid) or not ahbsi.hready);

        end if;

        if pstart_ack = '1' then
            if pabort = '1' then
                if (r2.s.pcicomm = CONF_WRITE or r2.s.pcicomm = CONF_READ) then v.cfto := '1';
                else v.s.perror := '1'; end if;
            else v.s.perror := '0'; v.cfto := '0'; end if;
        end if;
        
        --

        
        -- AHB slave state machine
        case r2.s.state is
            
            when idle =>
                
                if request = '1' and p_done = '0' then
                    if ahbsi.hwrite = '1' then
                        v.s.state := w_wait;
                        v.s.fifo.side := '0';
                    else
                        pstart := '1'; v.s.state := r_wait;
                    end if;
                    v.s.hmaster := ahbsi.hmaster; 
                end if;
                
            when w_wait =>
                
                if ((ahbsi.hready and not ahbsi.htrans(0)) = '1') then
                    v.s.state := w_done; fifows_limit := not wsvalid;
                else
                    v.s.state := t_data;
                end if;
                
            when t_data =>
                
                burst_read := ahbsi.htrans(1) and not fifors_limit;
                
                if (fifows_stop and r2.s.fifos_write) = '1' then
                    if r2.s.fifo.side = '1' then
                        v.s.state := w_done;
                    end if;
                    
                elsif ((fifors_limit or not rsvalid) = '1' and v.s.htrans(1) = '1') then
                    if (r.m.fifo.side = '0') or (rsvalid = '0') then
                        v.s.state := t_done;
                    else v.s.state := r_hold; end if;
                end if;
                
                if ((ahbsi.hready and not ahbsi.htrans(0)) = '1') then
                    if r2.s.pcicomm(0) = '1' then
                        --v.s.state := w_done; wsvalid := '0';
                        v.s.state := w_done; 
                        if ahbsi.htrans /= "00" then wsvalid := '0'; end if; -- fix dont set wsvalid if amba idle
                    else                                                   -- (if wsvalid = 0 side is changed before last write 
                        v.s.state := t_done;                                 -- to fifo if hrans = 00)        
                        wsvalid := '0'; -- Bug fix, must give RETRY here! /KC
                    end if;
                end if;
                
            when r_hold =>
                
                s_read_side := '1';
                if fifors_limit = '0' and ((pstart_ack or pstart) = '0') and request = '1' then
                    if rmdone = '0' then -- bug fix *** 
                        v.s.state := t_data;
                        burst_read := ahbsi.htrans(1) and not fifors_limit; -- bug fix ***
                    else
                        v.s.state := t_done;  
                    end if;
                elsif (ahbsi.hready = '1' and ahbsi.htrans = "00" and r2.s.hresp = HRESP_OKAY) then -- (idle -> t_done) bug fix *** 
                    v.s.state := t_done;
                else v.s.hold := '1'; end if;
            when r_wait =>
                
                s_read_side := '0';
                if (pstart_ack and request) = '1' then
                    v.s.state := t_data; hready := '0';
                end if;

                if r2.s.hmaster /= ahbsi.hmaster and conv_integer(ahbsi.hmaster) = dmamst and pstart_ack = '1' then -- if pcidma cancel read  
                    v.s.state := t_done;
                end if;

            when w_done =>
                
                v.s.state := t_done; wsvalid := '0';
--        if (r2.s.htrans(1) or not fifows_limit) = '1' then
--        if (r2.s.htrans(1) and fifows_limit) = '1' then
                v.s.fifo.waddr := r2.s.fifo.waddr + r2.s.fifos_write;

                
--          end if;

                fifows_limit := '1'; 
            when t_done =>
                
                wsvalid := '0';
                fifors_limit := not r2.s.pcicomm(0);
                if (pstart or pstart_ack) = '0' then
                    v.s.state := idle; v.s.perror := '0';
                    v.s.fifo.waddr := (others => '0'); wsdone := '0'; fifows_limit := '0';
                    v.s.pcicomm := (0 => '1', others => '0'); -- default write
                else fifows_limit := r2.s.pcicomm(0); end if;
        end case;

        -- Respond encoder
        if v.s.state = t_data
            or (v.s.state = r_hold and v.s.hold = '0') -- bug fix ***
            or (v.s.state = t_done and r2.s.state = t_data) -- (end of trans) bug fix ***
            or (v.s.state = w_wait and ahbsi.hwrite = '1') then
            if r2.s.perror = '1' then hresp := HRESP_ERROR;
            elsif wsvalid = '1' then hresp := HRESP_OKAY;
            else hresp := HRESP_RETRY; end if;
            v.s.perror := '0';
        else hresp := HRESP_RETRY; end if;

        if r.comm.msen = '0' then hresp := HRESP_ERROR; end if; -- Master disabled
        --if (v.s.htrans(1) and request) = '0' then hresp := HRESP_OKAY; end if; -- Response OK for BUSY and IDLE
        if (v.s.htrans(1) and ahb_access) = '0' then hresp := HRESP_OKAY; end if; -- Response OK for BUSY and IDLE -- *** access control fix
        if (hresp /= HRESP_OKAY or hready = '0') then v.s.hready := '0'; else v.s.hready := '1'; end if;

        -- Dont change hresp during wait states
        if ahbsi.hready = '0' then hresp := r2.s.hresp; end if;
        v.s.hresp := hresp;

        -- FIFO controller
        if fifows_limit = '1' then
            if (r2.s.fifos_write or not wsvalid) = '1' and (r2.s.fifo.side = '0' or pstart_ack = '1')   then
                --if wsvalid = '0' then wsdone := '1';
                if wsvalid = '0' or v.s.state = w_done then wsdone := '1'; -- fix set wsdone and pstart at the same time
                else v.s.fifo.waddr := (others => '0'); end if;
                pstart := not pstart_ack;
                v.s.fifo.side := pstart;
            end if;
        elsif ((r2.s.state = t_done or r2.s.state = r_hold) and fifors_limit = '1') then
            if pstart_ack = '1' then pstart := '0'; v.s.fifo.raddr := (others => '0');
            else v.s.fifo.raddr := (others => '0'); end if;
        end if;

        -- Set last fifo side written so that PCI master knows when to stop
        if (r2.s.fifos_write = '1') then
            v.s.last_side := r2.s.fifo.side;
        end if;

--    end if;

-----------------------
---- AHB SLAVE END ----
-----------------------
        
        -- Sync registers
        v.trans(0) := pstart;
        v.trans(1) := habort;
        v.trans(2) := hstart_ack;
        v.trans(3) := fifows_limit;
        v.trans(4) := wsdone;
        v.trans(5) := wmdone;

        -- input data for write accesses
        if r2.s.pcicomm(0) = '1' then v.s.mdata := ahbsi.hwdata; end if;
        -- output data for read accesses
--    if (ahbsi.htrans(1) and not r2.s.hold and not r2.s.pcicomm(0)) = '1' then v.s.mdata := fifo4o.rdata(31 downto 0); end if;
        if (ahbsi.htrans(1) and not r2.s.pcicomm(0)) = '1' then v.s.mdata := fifo4o.rdata(31 downto 0); end if; -- bug fix ***

        -- irq
        apbo.pirq <= (others => '0');
        if irq /= 0 then
            if to_x01(pcii.host) = '0' then
                apbo.pirq(irq) <= orv((not pcii.int) and conv_std_logic_vector(irqmask,4));
            end if;
        end if;
        
        if rst = '0' then
            v.s.state := idle;
            v.m.state := idle;
            v.s.perror := '0';
            v.pciba := (others => '0');
            v.trans := (others => '0');
            v.m.cbe_fifo.waddr := (others => '0');
            v.m.cbe_fifo.raddr := (others => '0');
            v.m.fifo.waddr := (others => '0');
            v.m.fifo.raddr := (others => '0');
            v.s.fifo.waddr := (others => '0');
            v.s.fifo.raddr := (others => '0');
            v.m.fifo.side := '0';
            v.s.fifo.side := '0';
            v.wcomm := '0';
            v.rcomm := '0';
            v.werr := '0';
            v.cfto := '0';
            v.dmapage := (others => '0');
            v.ioba := (others => '0');
            v.pciirq := "11";
            v.bus_nr := (others => '0');
        end if;

        apbo.prdata  <= prdata;
        ahbso.hready <= r2.s.hready;
        ahbso.hresp  <= r2.s.hresp;
        ahbso.hrdata <= byte_twist(r2.s.mdata, r.bt_enable);
        ahbso.hindex <= hslvndx;

        fifo1i.wen   <= fifom_write;
        fifo1i.waddr <= r2.m.fifo.side & r2.m.fifo.waddr;
        fifo1i.wdata <= dmao.rdata;

        fifo2i.ren   <= '1';
        fifo2i.raddr <= m_read_side & (r2.m.fifo.raddr + dmao.ready);
        
        fifo3i.wen   <= r2.s.fifos_write;
        fifo3i.waddr <= r2.s.fifo.side & r2.s.fifo.waddr;
        fifo3i.wdata <= byte_twist(r2.s.mdata, r.bt_enable);
        
        fifo4i.ren   <= '1';
        fifo4i.raddr <= s_read_side & (r2.s.fifo.raddr + burst_read);

        cbe_fifoi.ren   <= '1';
        cbe_fifoi.raddr <= m_read_side & (r2.m.cbe_fifo.raddr + dmao.ready); -- read one cycle before data fifo

        r2in <= v; dmai <= vdmai;
        
    end process;

    ahbso.hconfig <= hconfig when MASTER = 1 else (others => zero32);
    ahbso.hcache  <= '0';
    apbo.pconfig  <= pconfig;
    apbo.pindex   <= pindex;
    ahbso.hsplit  <= (others => '0');
    ahbso.hirq    <= (others => '0');


---------------------------------
-- PCI core (PCI clock domain) --
---------------------------------
    
    pcicomb : process(pr, pcii, r, r2, fifo1o, fifo3o, roe_ad, prrst)
        
        variable v : pci_reg_type;
        variable chit, mhit0, mhit1, phit, hit, hosthit, ready, cwrite, retry : std_logic;
        variable cdata, cwdata : std_logic_vector(31 downto 0);
        variable comp : std_logic; -- Last transaction cycle on PCI bus
        variable mto, tto, term, ben_err, lto : std_logic;
        variable i : integer range 0 to NO_PCI_REGS;
        variable tad, mad : std_logic_vector(31 downto 0);
        variable pstart, habort, hstart_ack, wsdone, wmdone : std_logic;
        variable hstart, pabort, pstart_ack, pcidc, rtdone, rmdone : std_logic;
        variable fifort_limit, fifowt_limit, fiform_limit, fifowm_limit, fifowm_stop, t_valid : std_logic;
        variable d_ready, tabort, backendnr : std_logic;
        variable m_fifo_write, t_fifo_write, grant : std_logic;
        variable write_access, memwrite, memread, read_match, m_read_side, t_read_side : std_logic;
        variable readt_dly : std_logic; -- 1 turnaround cycle
        variable bus_idle, data_transfer, data_transfer_r, data_phase, targ_d_w_data, targ_abort, m_request : std_logic;
        variable voe_ad : std_logic_vector(31 downto 0);
        variable oe_par   : std_logic;
        variable oe_ad    : std_logic;
        variable oe_ctrl  : std_logic;
        variable oe_cbe   : std_logic;
        variable oe_frame : std_logic;
        variable oe_irdy  : std_logic;
        variable oe_req   : std_logic;
        variable oe_perr  : std_logic;
        
    begin

        -- Process defaults
        v := r; v.pci.trdy := '1'; v.pci.stop := '1'; v.pci.frame := '1';
        v.pci.oe_ad := '1'; v.pci.devsel := '1'; v.pci.oe_frame := '1';
        v.pci.irdy := '1'; v.pci.req := '1'; hosthit := '0'; m_request := '0';
        v.pci.oe_req := '0'; v.pci.oe_cbe := '1'; v.pci.oe_irdy := '1';
        mto := '0'; tto := '0'; v.m.stop_req := '0'; lto := '0';
        cdata := (others => '0'); retry := '0'; t_fifo_write := '0';
        chit := '0'; phit := '0'; mhit0 := '0'; mhit1 := '0'; tabort := '0';
        readt_dly := '0'; m_fifo_write := '0'; voe_ad := roe_ad; 
        tad := r.pci.ad; mad := r.pci.ad; grant := pcii.gnt; d_ready := '0';
        m_read_side := not r2.s.fifo.side; t_read_side := not r2.m.fifo.side;
        v.m.rmdone := '0';

        write_access := not r.t.read and not pr.irdy and not pr.trdy;
        memwrite := r.t.msel and r.t.lwrite and not r.t.read;
        memread := r.t.msel and not r.t.lwrite and r.t.read;

        -- Synch registers
        hstart := r.trans(0);
        pabort := r.trans(1);
        pstart_ack := r.trans(2);
        pcidc := r.trans(3);
        rtdone := r.trans(4);
        rmdone := r.trans(5);

        for i in 0 to NO_PCI_REGS - 1 loop
            v.syncs(i)(csync) := r2.trans(i);
            if csync /= 0 then v.syncs(i)(0) := r.syncs(i)(csync); end if;
        end loop;

        pstart     := r.syncs(0)(0);
        habort     := r.syncs(1)(0);
        hstart_ack := r.syncs(2)(0);
        backendnr  := r.syncs(3)(0);
        wsdone     := r.syncs(4)(0);
        wmdone     := r.syncs(5)(0);

        -- FIFO limit detector
        if r.t.fifo.raddr = FIFO_FULL then fifort_limit := '1'; else fifort_limit := '0'; end if;
        if r.t.fifo.waddr = FIFO_FULL then fifowt_limit := '1'; else fifowt_limit := '0'; end if;
        if r.m.fifo.raddr = FIFO_FULL then fiform_limit := '1'; else fiform_limit := '0'; end if;
        if r.m.fifo.waddr = FIFO_FULL then fifowm_limit := '1'; else fifowm_limit := '0'; end if;
        if r.m.fifo.waddr(FIFO_DEPTH - 2 downto 1) = FIFO_FULL(FIFO_DEPTH - 2 downto 1) then fifowm_stop := '1'; else fifowm_stop := '0'; end if;

        -- useful control variables
        --if (r.t.laddr = r.page & r.t.addr(MADDR_WIDTH-2 downto 0) or r.t.laddr = r2.dmapage & r.t.addr(DMAMADDR_WIDTH-1 downto 0))
        if (r.t.laddr(31 downto 2) = r.page & r.t.addr(MADDR_WIDTH-2 downto 2) -- bug fix match if byte access 
            or r.t.laddr(31 downto 2) = r2.dmapage & r.t.addr(DMAMADDR_WIDTH-1 downto 2)) 
            and (r.t.lcbe = pr.cbe) -- bug fix match byte access
            and (r.t.lburst = r.t.burst) then read_match := r.t.pending; else read_match := r.t.csel or r.t.psel; end if;

--    if (pr.cbe = "0000" and r.t.lsize = "10") or (pr.cbe = "1100" and r.t.lsize = "01") or (pr.cbe = "1110" and r.t.lsize = "00")
-- pragma translate_off
--    or (pr.cbe = "XXXX") -- For simulation purposes
-- pragma translate_on
--    then ben_err := '0'; else ben_err := '1'; end if;
        ben_err := '0';
        
        if r.stat.dpe = '0' then v.stat.dpe := not r.pci.perr; end if;

-------------------------
----- PCI TARGET --------
-------------------------
        
        -- Data valid?
        if ((wmdone and not r.t.lwrite) = '1' and (r.t.fifo.raddr + '1') = r2.m.fifo.waddr) then t_valid := '0';
        else t_valid := not fifowt_limit or not r.t.fifo.side; end if;

        -- Step addresses
        if (r.t.state = s_data or r.t.state = turn_ar or r.t.state = backoff) then
            if (pcii.irdy or r.pci.trdy) = '0' then
                v.t.addr := r.t.addr + ((r.t.csel and r.t.read) & "00");
                readt_dly := '1';
                if r.t.msel = '1' then
                    v.t.wdel := (fifort_limit and r2.m.fifo.side) or r.t.lwrite;
                    v.t.fifo.raddr := r.t.fifo.raddr + (r.t.read and not fifort_limit and t_valid);
                end if;
            end if;
            if write_access = '1' then
                v.t.fifo.waddr := r.t.fifo.waddr + (r.t.msel and not r.t.read and not ben_err);
                t_fifo_write := r.t.msel;
                v.t.addr := r.t.addr + ((r.t.csel and not r.t.read) & "00");
            end if;
            tabort := habort;
        else v.t.wdel := '0'; end if;

        -- Config space read access
        case r.t.addr(7 downto 2) is
            when "000000" =>      -- 0x00, device & vendor id
                cdata := conv_std_logic_vector(DEVICE_ID, 16) &
                         conv_std_logic_vector(VENDOR_ID, 16);
            when "000001" =>      -- 0x04, status & command
                cdata(1) := r.comm.men; cdata(2) := r.comm.msen;
                cdata(4) := r.comm.mwie; cdata(6) := r.comm.per;
                cdata(24) := r.stat.dped; cdata(26) := '1';
                cdata(27) := r.stat.sta; cdata(28) := r.stat.rta;
                cdata(29) := r.stat.rma; cdata(31) := r.stat.dpe;
            when "000010" =>      -- 0x08, class code & revision
                cdata(31 downto 0) := conv_std_logic_vector(CLASS_CODE,24) & conv_std_logic_vector(REV,8) ;
            when "000011" =>      -- 0x0C, latency & cacheline size
                cdata(7 downto 0) := r.cline;
                cdata(15 downto 8) := r.ltim;
            when "000100" =>      -- 0x10, BAR0
                cdata(31 downto MADDR_WIDTH) := r.bar0;
            when "000101" =>      -- 0x14, BAR1
                cdata(31 downto DMAMADDR_WIDTH) := r.bar1;
            when "001111" =>      -- 0x3C, Interrupts & Latency timer settings
                cdata(7 downto 0) := r.intline; -- Interrupt line
                cdata(8) := '1'; -- Use interrupt pin INTA#
                if fifodepth < 11 then cdata(fifodepth+13) := '1'; end if; --Define wanted burst period
            when others =>
        end case;

        -- Config space write access
        cwdata := pr.ad;
        if pr.cbe(3) = '1' then cwdata(31 downto 24) := cdata(31 downto 24); end if;
        if pr.cbe(2) = '1' then cwdata(23 downto 16) := cdata(23 downto 16); end if;
        if pr.cbe(1) = '1' then cwdata(15 downto  8) := cdata(15 downto  8); end if;
        if pr.cbe(0) = '1' then cwdata( 7 downto  0) := cdata( 7 downto  0); end if;
        if (r.t.csel and write_access) = '1' then
            case r.t.addr(7 downto 2) is
                when "000001" =>      -- 0x04, status & command
                    v.comm.men := cwdata(1);
                    if MASTER = 1 then v.comm.msen := cwdata(2); end if;
                    v.comm.mwie := cwdata(4); v.comm.per := cwdata(6);
                    v.stat.dped := r.stat.dped and not cwdata(24); -- Sticky bit
                    v.stat.sta := r.stat.sta and not cwdata(27); -- Sticky bit
                    v.stat.rta := r.stat.rta and not cwdata(28); -- Sticky bit
                    v.stat.rma := r.stat.rma and not cwdata(29); -- Sticky bit
                    v.stat.dpe := r.stat.dpe and not cwdata(31); -- Sticky bit
                when "000011" =>      -- 0x0c, latency & cacheline size
                    if FIFO_DEPTH <= 7 then v.cline(FIFO_DEPTH - 1 downto 0) := cwdata(FIFO_DEPTH - 1 downto 0);
                    else v.cline := cwdata(7 downto 0); end if;
                    v.ltim := cwdata(15 downto 8);
                when "000100" =>      -- 0x10, BAR0
                    v.bar0 := cwdata(31 downto MADDR_WIDTH);
                    if v.bar0 = zero(31 downto MADDR_WIDTH) then v.bar0_conf := '0'; else v.bar0_conf := '1'; end if;
                when "000101" =>      -- 0x14, BAR1
                    v.bar1 := cwdata(31 downto DMAMADDR_WIDTH);
                    if v.bar1 = zero(31 downto DMAMADDR_WIDTH) then v.bar1_conf := '0'; else v.bar1_conf := '1'; end if;
                when "001111" =>  -- 0x3C, Interrupts & Latency timer settings
                    v.intline := cwdata(7 downto 0); -- Interrupt line
                when others =>
            end case;
        end if;

        -- Page bar write
        if (r.t.psel and write_access) = '1' then
            v.page := pr.ad(31 downto MADDR_WIDTH - 1);
            v.bt_enable := pr.ad(0);
        end if;

        -- Command and address decode
        case pr.cbe is
            when CONF_READ | CONF_WRITE =>
                if pr.ad(1 downto 0) = "00" then chit := '1'; end if;
                if pr.host = '0' then --Active low
                    if pr.ad(31 downto 11) = "000000000000000000000" then hosthit := '1'; end if;
                end if;
            when MEM_READ | MEM_WRITE =>
                if pr.ad(31 downto MADDR_WIDTH) = r.bar0 then
                    phit := r.bar0_conf and pr.ad(MADDR_WIDTH - 1);
                    mhit0 := r.bar0_conf and not pr.ad(MADDR_WIDTH - 1);
                elsif pr.ad(31 downto DMAMADDR_WIDTH) = r.bar1 then
                    mhit1 := r.bar1_conf;
                end if;
            when MEM_R_MULT | MEM_R_LINE | MEM_W_INV =>
                if pr.ad(31 downto MADDR_WIDTH - 1) = r.bar0 & '0' then mhit0 := r.bar0_conf;
                elsif pr.ad(31 downto DMAMADDR_WIDTH) = r.bar1 then mhit1 := r.bar1_conf; end if;
            when others => phit := '0'; mhit0 := '0'; chit := '0'; mhit1 := '0';
        end case;

        -- Hit detect
        hit := r.t.csel or r.t.msel or r.t.psel;

        if (hstart and r.pci.devsel) = '1' then
            if (r.t.pending or r.t.lwrite) = '0' then
                hstart := not hstart_ack;
                v.t.fifo.raddr := (others => '0');
            end if;
        end if;

        -- Ready to transfer data  
        if ((r.t.csel and not readt_dly) or r.t.psel) = '1'
            or ((((memwrite and not r.pci.devsel) = '1')
                 or (memread = '1' and not (hstart_ack and v.t.wdel) = '1')) and ben_err = '0')
        then ready := '1'; else ready := '0'; t_read_side := r.t.read and not hstart; end if;

        -- Target timeout counter
        --if (hit and pr.trdy and not (pr.frame and pr.irdy)) = '1' then 
        --if (hit and pr.trdy and not (pr.frame and pr.irdy) and v.t.wdel) = '1' then 
        if (hit and pr.trdy and not (pr.frame and pr.irdy) and not ready) = '1' then
            if r.t.cnt /= "000" then v.t.cnt := r.t.cnt - 1;
            else tto := '1'; end if;
        else v.t.cnt := (0 => '0', others => '1'); end if;

--    -- Ready to transfer data
--    if ((r.t.csel and not readt_dly) or r.t.psel) = '1'
--       or ((((memwrite and not r.pci.devsel) = '1')
--       or (memread = '1' and not (hstart_ack and v.t.wdel) = '1')) and ben_err = '0')
--       then ready := '1'; else ready := '0'; t_read_side := r.t.read and not hstart; end if;

        -- Terminate current transaction
        if (((r.t.fifo.waddr >= (FIFO_FULL - "10") and r.t.fifo.side = '1')
             or (t_valid = '0') or r.pci.stop = '0') and pcii.frame = '0')
            or ((r.t.read xor r.t.lwrite) = '0' and r.pci.devsel = '0')
            or (tto = '1') or (ben_err = '1')
        then 
	  term := '1'; 
	else term := '0'; end if;

        -- Retry transfer
        if r.t.state = b_busy then
            if not ((r.t.read and not r.t.lwrite and hstart_ack and read_match) = '1'
                    or (r.t.read or hstart or hstart_ack) = '0'
                    or ((r.t.csel or r.t.psel) and not hstart and not hstart_ack) = '1')
            then 
		retry := '1'; 
	    end if;
        end if;

        -- target state machine
        case r.t.state is

            when idle  =>
                
                if pr.frame = '0' then v.t.state := b_busy; end if; -- !HIT ?
                v.t.addr := pr.ad;
                if readpref = 1 then v.t.burst := '1';
                else v.t.burst := pr.cbe(3); end if;
                v.t.read := not pr.cbe(0); v.t.mult := not pr.cbe(1);
                v.t.csel := (pr.idsel or hosthit) and chit; v.t.psel := phit;
                v.t.msel := r.comm.men and (mhit0 or mhit1); v.t.barsel := mhit1;
            when turn_ar =>
                
                if pr.frame = '1' then 
                    v.t.state := idle;
                    v.t.fifo.raddr := (others => '0'); -- fix reset fifo read address 
                else v.t.state := b_busy; end if; -- !HIT ?
                v.t.addr := pr.ad; v.t.wdel := '1';
                if readpref = 1 then v.t.burst := '1';
                else v.t.burst := pr.cbe(3); end if;
                v.t.read := not pr.cbe(0); v.t.mult := not pr.cbe(1);
                v.t.csel := (pr.idsel or hosthit) and chit; v.t.psel := phit;
                v.t.msel := r.comm.men and (mhit0 or mhit1); v.t.barsel := mhit1;
            when b_busy  =>

                if (pr.frame and pr.irdy) = '1' then
                    v.t.state := idle;

                elsif hit = '1' then
                    v.t.state := s_data;
                    v.t.fifo.raddr := r.t.fifo.raddr + (r.t.read and r.t.msel);
                    readt_dly := '1';
                    
                    if r.t.pending = '0' then
                        v.t.pending := retry and not hstart_ack;
                    end if;
                    
                end if;
--      else v.t.state := backoff; end if;
--      We should not go to back off if the access wasn't to us
                
            when s_data  =>
                
                if r.t.pending = '1' then v.t.pending := not ((habort or not r.pci.trdy) and read_match); end if;
                if (pcii.frame = '0' and r.pci.stop ='0' and (r.pci.trdy or not pcii.irdy) = '1') then
                    v.t.state := backoff;
                    if r.t.last = '0' then v.t.last := r.t.msel and r.t.lwrite and v.t.wdel; end if;
                    v.t.fifo.raddr := r.t.fifo.raddr - (r.t.read and r.t.msel and not fifort_limit);
--      elsif (pcii.frame = '1' and (r.pci.trdy = '0' or r.pci.stop = '0')) then
                elsif (pcii.frame = '1' and (r.t.trdy_del = '0' or r.pci.stop = '0')) then -- (send last word in fifo) bug fix *** 
                    v.t.state := turn_ar;
                    if r.t.last = '0' then v.t.last := r.t.msel and r.t.lwrite and v.t.wdel; end if;
                    v.t.fifo.raddr := r.t.fifo.raddr - (r.t.read and r.t.msel and not fifort_limit);
                end if;
            when backoff =>
                
                if pcii.frame = '1' then v.t.state := turn_ar; end if;
        end case;

        -- #TRDY assert
        if (v.t.state = s_data and habort = '0' and ready = '1' and retry = '0') then v.pci.trdy := '0'; end if;

        -- #STOP assert
        if (v.t.state = backoff or (v.t.state = s_data and ((tabort or ((term or retry) and not habort)) = '1'))) then
            v.pci.stop := '0'; end if;

        -- #DEVSEL assert
        if (((v.t.state = backoff and r.pci.devsel = '0') or v.t.state = s_data) and (read_match and tabort) = '0') then v.pci.devsel := '0'; end if;

        -- Enable #TRDY, #STOP and #DEVSEL
        if (v.t.state = s_data) or (v.t.state = backoff) or (v.t.state = turn_ar) then
            v.pci.oe_ctrl := not hit;
        else v.pci.oe_ctrl := '1'; end if;

        -- Signaled target abort
        if (r.pci.devsel and not (r.pci.stop or r.pci.oe_ctrl)) = '1' then v.stat.sta := '1'; end if;

        if r.t.state = s_data and v.t.state = s_data and r.pci.trdy = '0' 
            and v.pci.trdy = '1' and v.t.wdel = '1' and pcii.frame = '0' then -- (send last word in fifo) bug fix *** 
            v.t.trdy_del := '0';
        else
            v.t.trdy_del := v.pci.trdy;
        end if;

        if r.t.state = s_data and r.pci.trdy = '1' and v.pci.trdy = '0' and pcii.frame = '0' then -- bug fix *** 
            readt_dly := '1';
            v.t.fifo.raddr := r.t.fifo.raddr + (r.t.read and not fifort_limit and t_valid);
        end if;

        -- Latched signals to AHB backend
        if (r.t.state = b_busy) then
            if (hstart or hstart_ack) = '0' then -- must be idle
                v.t.lwrite := not r.t.read;
                
                if r.t.msel = '1' then
                    v.t.lburst := r.t.burst;
                    v.t.lcbe := pr.cbe; 
                    if r.t.barsel = '0' then v.t.laddr := r.page & r.t.addr(MADDR_WIDTH-2 downto 2) & "00";
                    else  v.t.laddr := r2.dmapage & r.t.addr(DMAMADDR_WIDTH-1 downto 2) & "00"; end if;
                    v.t.lmult :=  r.t.mult;
                    rtdone := '0'; v.t.fifo.waddr := (others => '0');
                    hstart := r.t.read and r.t.msel;
                end if;
            end if;
        end if;
        
        -- Read data mux
        if r.t.csel = '1' then tad := cdata;
        elsif r.t.psel = '1' then
            tad(31 downto MADDR_WIDTH-1) := r.page;
            tad(MADDR_WIDTH-2 downto 0) := zero32(MADDR_WIDTH-2 downto 1) & r.bt_enable;
--    elsif (r.t.state = b_busy or (r.pci.trdy or pcii.irdy) = '0') then tad := fifo1o.rdata(31 downto 0);
        elsif (r.t.state = b_busy or (r.pci.trdy or pcii.irdy) = '0' or r.t.wdel = '1') then tad := byte_twist(fifo1o.rdata(31 downto 0), r.bt_enable); -- bug fix *** 
        end if;

        -- FIFO controller
        if ((fifowt_limit and write_access) = '1' or (r.t.last or rtdone) = '1') then
            if hstart = hstart_ack then
                if rtdone = '0' then hstart := not hstart_ack; v.t.fifo.side := hstart; end if;
                if r.t.last = '1' then rtdone := '1'; v.t.last := '0';
                else v.t.fifo.waddr := (others => '0');
                     if rtdone = '1' then
                         rtdone := '0'; hstart := '0'; v.t.fifo.side := '0';
                     end if;
                end if;
            end if;
        end if;

        if (fifort_limit and v.t.wdel) = '1' then
            if hstart_ack = '1' then hstart := '0'; v.t.fifo.raddr := (others => '0');
            else v.t.fifo.raddr := (others => '0'); end if;
        end if;

----------------------        
--- PCI TARGET END ---
----------------------

------------------
--- PCI MASTER ---
------------------

        if MASTER = 1 then

            bus_idle := pcii.frame and pcii.irdy;
            data_transfer := not (pcii.trdy or r.pci.irdy);
            data_transfer_r := not (pr.trdy or pr.irdy);
            data_phase := not ((pcii.trdy and pcii.stop) or r.pci.irdy);
            targ_d_w_data := not (pr.stop or pr.trdy);
            targ_abort := pr.devsel and not pr.stop;


            -- Request from AHB backend to start PCI transaction
            if (pstart and not pstart_ack) = '1' then
                if (r.m.fstate = idle and r.m.request = '0') then
                    v.m.request := '1';
                    rmdone := '0'; v.m.valid := '1';
                    v.m.fifo.waddr := (others => '0');
                    v.m.hwrite := r2.s.pcicomm(0);
                end if;
            end if;

            -- Master timeout and DEVSEL timeout
            if ((pr.irdy and not pr.frame) or (pr.devsel and not r.pci.oe_frame)) = '1' then
                if r.m.cnt /= "000" then v.m.cnt := r.m.cnt - 1;
                else mto := '1'; end if;
            else v.m.cnt := (others => '1'); end if;

            -- Latency counter
            if r.pci.frame = '0' then
                if r.m.ltim > "00000000" then v.m.ltim := r.m.ltim - '1';
                else lto := '1'; end if;
            else
                v.m.ltim := r.ltim;
            end if;

            -- Last data
            case r2.s.pcicomm is
                when MEM_R_MULT | MEM_R_LINE =>
                    if (r.m.fifo.waddr >= (FIFO_FULL - "10") and r.m.fifo.side = '1') then
                        comp := '1';
                    else comp := '0'; end if;
                when MEM_WRITE | MEM_W_INV => comp := not r.m.valid;
                when others => comp := '1';
            end case;

            -- Minimun latency
            --if lto = '0' then grant := '0'; end if;
            if lto = '0' then grant := '0'; -- latency timer bug fix  
            elsif pcii.gnt = '1' then v.m.lto := '1'; end if; 

            -- Data parity error detected
            if (r.m.fstate /= idle and r.stat.dped = '0') then v.stat.dped := r.comm.per and not pcii.perr; end if;

            -- FIFO control state machine
            case r.m.fstate is
                when idle =>
                    
                    v.m.lto := '0'; 
                    if (r.m.request and bus_idle and not pcii.gnt) = '1' and (r.m.state = idle or r.m.state = dr_bus) then
                        v.m.fstate := addr; v.m.fifo.waddr := (others => '0'); v.m.fifo.side := '0'; m_request := '1';
                    end if;
                when addr =>
                    
--      if (wsdone = '1' and (r.m.fifo.raddr + '1') = r2.s.fifo.waddr) then v.m.valid := '0'; end if;
                    if (wsdone = '1' and ((r.m.fifo.raddr + '1') = r2.s.fifo.waddr) and (m_read_side = r2.s.last_side)) then v.m.valid := '0'; end if; --bug fix kc
                    
                    if fiform_limit = '1' then v.m.fstate := last1;
                    else v.m.fstate := incr; end if;
                    v.m.fifo.raddr := r.m.fifo.raddr + r.m.hwrite;
                    v.m.first := '1'; v.m.firstw := '1';
                when incr =>
                    
                    d_ready := '1';
                    
                    if r.m.valid = '0' then v.m.lto := '0'; end if; -- dont look at latency timer if done 

                    if data_transfer = '1' then
                        
                        --if fiform_limit = '1' then v.m.fstate := last1; v.m.split := not backendnr; end if;
                        if fiform_limit = '1' and r.m.lto = '0' then v.m.fstate := last1; v.m.split := not backendnr; end if; -- bug fix latency timer

--        if (wsdone = '1' and (r.m.fifo.raddr + pcii.stop) = r2.s.fifo.waddr) then v.m.valid := '0'; end if;
                        if (wsdone = '1' and ((r.m.fifo.raddr + pcii.stop) = r2.s.fifo.waddr) and (m_read_side = r2.s.last_side)) then v.m.valid := '0'; end if; --bug fix kc

                        v.m.fifo.raddr := r.m.fifo.raddr + r.m.hwrite;
                        v.m.first := '0';
                    end if;
                    if data_transfer_r = '1' then
                        if fifowm_stop = '1' then
                            if r.m.firstw = '1' then
                                if (fifowm_limit and pr.stop) = '1' then v.m.fifo.side := not r.m.fifo.side; v.m.firstw := '0'; pstart_ack := pstart; end if;
                            end if;
                        end if;
                        v.m.fifo.waddr := r.m.fifo.waddr + (not r.m.hwrite);
                    end if;
                    if pr.stop = '0' then
                        if targ_abort = '1' then v.m.fstate := abort;
                        elsif targ_d_w_data = '1' then v.m.fstate := ttermwd;
                        elsif r.m.first = '1' then v.m.fstate := t_retry;
--        else v.m.fstate := ttermnd; end if;
                        else  -- bug fix *** 
--           if r.m.fifo.waddr = "0000000" then v.m.rmdone := '1'; end if;
                            if r.m.fifo.waddr = zero32(FIFO_DEPTH - 2 downto 0) then v.m.rmdone := '1'; end if;
                            v.m.fstate := ttermnd;
                        end if;
                    elsif mto = '1' then v.m.fstate := abort;
                                         --elsif grant = '1' then -- pci_gnt bug fix 
                                         --  if r.m.hwrite = '0' then rmdone := not r.m.fifo.side; v.m.fifo.side := '1'; v.m.fstate := done; pstart_ack := pstart;
                                         --  else v.m.fstate := idle; end if;
                                         
                                         --elsif (pr.frame and not r.m.first) = '1' then
                    elsif (pr.frame and not pr.trdy and not r.m.first) = '1' then -- not done if target not ready *** bug fix
                        if r.m.hwrite = '0' then rmdone := not r.m.fifo.side; v.m.fifo.side := '1'; v.m.fstate := done; pstart_ack := pstart;
                                                 --else v.m.fstate := done; pstart_ack := pstart; end if;
                        else 
                            if r.m.lto = '1' then -- latency timer bug fix
                                v.m.fifo.raddr := r.m.fifo.raddr - r.m.hwrite;
                                v.m.fstate := idle;
                            else
                                v.m.fstate := done; pstart_ack := pstart; 
                            end if;
                        end if;
                    elsif (pr.devsel and not r.m.first) = '1' then
                        if r.m.hwrite = '0' then rmdone := not r.m.fifo.side; v.m.fifo.side := '1'; v.m.fstate := done; pstart_ack := pstart;
                        else v.m.fstate := idle; end if;
                    end if;
                when last1 =>

                    if (pr.trdy and not pr.stop) = '1' then
                        if targ_abort = '1' then v.m.fstate := abort;
                        elsif targ_d_w_data = '1' then v.m.fstate := ttermwd;
                        else v.m.fstate := ttermnd; v.m.valid := '1'; end if;
                        --elsif (pr.frame and not r.m.first and not r.m.split) = '1' then v.m.fstate := done; rmdone := not r.m.fifo.side; pstart_ack := pstart;
                        -- not done if target not ready *** bug fix
                    elsif (pr.frame and not pr.trdy and not r.m.first and not r.m.split) = '1' then v.m.fstate := done; rmdone := not r.m.fifo.side; pstart_ack := pstart;
                    elsif data_transfer = '1' then
                        if r.m.valid = '1' then v.m.fstate := sync; pstart_ack := pstart;
                        else v.m.fstate := done; rmdone := not r.m.fifo.side; pstart_ack := pstart; end if;
                    else d_ready := '1';
                    end if;
                when sync =>
                    
                    if pstart = not pstart_ack then
                        v.m.split := '0';
                        if ((r.m.split or (pr.trdy and not pr.stop and not r.m.split))  = '1' or r.m.state /= m_data) then v.m.fstate := idle; d_ready := '1';
                        else
                            --if (wsdone = '1' and (r.m.fifo.raddr + '1') = r2.s.fifo.waddr) then v.m.valid := '0'; end if;
                            if (r2.trans(4) = '1' and (r.m.fifo.raddr + '1') = r2.s.fifo.waddr) then v.m.valid := '0'; end if; -- not synced wsdone
                            v.m.fstate := incr; data_transfer := '1'; v.m.fifo.raddr := r.m.fifo.raddr + r.m.hwrite; d_ready := '1';
                        end if;
                    else m_read_side := '1';
                    end if;
                when t_retry =>
                    
                    v.m.fifo.raddr := r.m.fifo.raddr - r.m.hwrite; v.m.fstate := idle;

                when ttermwd =>
                    
                    if data_transfer = '1' then v.m.fifo.raddr := r.m.fifo.raddr + r.m.hwrite;
                    elsif pr.trdy = '1' then v.m.fifo.raddr := r.m.fifo.raddr - r.m.hwrite;
                                             if (r.m.hwrite and r.m.valid) = '1' then v.m.fstate := idle;
                                             else v.m.fstate := done; rmdone := not r.m.fifo.side; v.m.fifo.side := '1'; pstart_ack := pstart; end if;
                    end if;
                when ttermnd =>
                    
                    if r.m.hwrite = '1' then
                        v.m.fifo.raddr := r.m.fifo.raddr - '1';
--          if (r.m.fifo.raddr /= (r2.s.fifo.waddr + '1') or wsdone = '0') then v.m.valid := '1'; v.m.fstate := idle; -- bug fix *** 
                        if (r.m.fifo.raddr /= (r2.s.fifo.waddr + '1') or wsdone = '0' or r.m.valid = '1') then v.m.valid := '1'; v.m.fstate := idle;
                        else v.m.fstate := done; rmdone := not r.m.fifo.side; v.m.fifo.side := '1'; pstart_ack := pstart; end if;
--        else v.m.fstate := done; rmdone := not r.m.fifo.side; v.m.fifo.side := '1'; pstart_ack := pstart; end if;
                    else v.m.fstate := done; rmdone := (not r.m.fifo.side or r.m.rmdone); v.m.fifo.side := '1'; pstart_ack := pstart; end if; -- bug fix *** 
                when abort =>
                    
                    v.m.fifo.raddr := (others => '0'); v.m.fifo.waddr := (others => '0');
                    v.m.fstate := done; pstart_ack := pstart; pabort := '1';
                when done =>
                    
                    d_ready := '1'; comp := '1'; v.m.request := '0';
                    if (pstart or pstart_ack) = '0' then
                        v.m.fstate := wdone; v.m.fifo.raddr := (others => '0'); v.m.fifo.side := '0'; rmdone := '1';
                    else pstart_ack := pstart; end if;
                when wdone =>
                    
                    d_ready := '1'; comp := '1';
                    if (r.m.state = idle or r.m.state = dr_bus) then v.m.fstate := idle; pabort := '0';  end if;
            end case;

            -- PCI master state machine
            case r.m.state is
                when idle => -- Master idle
                    v.m.stopframe := '0'; 
                    if (pcii.gnt = '0' and bus_idle = '1') then
                        if m_request = '1' then v.m.state := addr;
                        else v.m.state := dr_bus; end if;
                    end if;
                when addr => -- Always one address cycle at the beginning of an transaction
                    v.m.stopframe := '0'; 
                    v.m.state := m_data;
                when m_data => -- Master transfers data
                    if r.pci.frame = '1' then v.m.stopframe := '1'; end if; -- *** 
                    if (r.pci.frame = '0') or ((r.pci.frame and pcii.trdy and pcii.stop and not mto) = '1') then
                        v.m.state := m_data;
                        if (r.pci.frame and not d_ready) = '1' then d_ready := '1'; end if;
                    elsif ((r.pci.frame and (mto or not pcii.stop)) = '1') then
                        v.m.state := s_tar;
                        v.m.stop_req := '1';
                    else v.m.state := turn_ar; end if;
                when turn_ar => -- Transaction complete
                    
                    if pcii.gnt = '0' then
                        if m_request = '1' then v.m.state := addr;
                        else v.m.state := dr_bus; end if;
                    else v.m.state := idle; end if;
                when s_tar => -- Stop was asserted
                    
                    if pcii.gnt = '0' then v.m.state := dr_bus;
                    else v.m.state := idle; end if;
                when dr_bus => -- Drive bus when parked on this agent
                    
                    if pcii.gnt = '1' then v.m.state := idle;
                    elsif m_request = '1' then v.m.state := addr; end if;
            end case;

            -- FIFO write strobe
            m_fifo_write := not r.m.hwrite and not pr.irdy and not (pr.trdy and (pr.stop or not r.trans(3))) and not r.pci.oe_irdy;

            -- PCI data mux
            if v.m.state = addr then
                if r.m.hwrite = '1' then mad := (r2.s.maddr + ((((not r2.s.fifo.side) & r.m.fifo.raddr)) & "00"));
                else mad := r2.s.maddr; end if;
            elsif (r.m.state = addr or data_transfer = '1') then mad := fifo3o.rdata(31 downto 0);
            end if;

            -- Target abort
            if ((pr.devsel and pr.trdy and not pr.gnt and not pr.stop) = '1') then v.stat.rta := '1'; end if;

            -- Master abort
            if mto = '1' then v.stat.rma := '1'; end if;

            -- Drive FRAME# and IRDY#
            if (v.m.state = addr or v.m.state = m_data) then v.pci.oe_frame := '0'; end if;

            -- Drive CBE#
            if (v.m.state = addr or v.m.state = m_data or v.m.state = dr_bus) then v.pci.oe_cbe := '0'; end if;

            -- Drive IRDY# (FRAME# delayed one pciclk)
            v.pci.oe_irdy := r.pci.oe_frame;

            -- FRAME# assert
            if (v.m.state = addr or (v.m.state = m_data and mto = '0' and v.m.stopframe = '0'  -- stopframe fix frame when pci_gnt is deasserted
                --and ((((pcii.stop or not d_ready) and not (comp or v.m.split or not v.m.valid)) and not grant)) = '1')) -- dont change frame when gnt = 1 if not irdy and trdy or stop
                  and ((((pcii.stop or not d_ready) and not (comp or v.m.split or not v.m.valid)) and not (grant and not pr.irdy and (not pcii.trdy or not pcii.stop) ) )) = '1'))
            then
                v.pci.frame := '0';
            end if;

            -- IRDY# assert
            if (v.m.state = m_data and ((d_ready or mto or (not r.m.valid) or (v.pci.frame and not r.pci.frame)) = '1'))  then v.pci.irdy := '0'; end if;

            -- REQ# assert
            if ((v.m.request = '1' and (r.m.fstate = idle or comp = '0')) and (v.m.stop_req or r.m.stop_req) = '0') then v.pci.req := '0'; end if;

            -- C/BE# assert
            if v.m.state = addr then v.pci.cbe := r2.s.pcicomm; else v.pci.cbe := r2.s.be; end if;

        end if;

---------------------
---PCI MASTER END ---
---------------------

----------------------        
--- SHARED SIGNALS ---
----------------------

        -- Default assertions
        v.pci.oe_par := r.pci.oe_ad; --Delayed one clock
        v.pci.oe_perr := not(r.comm.per and not r.pci.oe_par and not (pr.irdy and pr.trdy)) and (r.pci.oe_perr or r.pci.perr);
        v.pci.par := xorv(r.pci.ad & r.pci.cbe); -- Default asserted by master
        v.pci.ad := mad;  -- Default asserted by master
        v.pci.perr := not (pcii.par xor xorv(pr.ad & pr.cbe)) or pr.irdy or pr.trdy; -- Detect parity error

        -- Drive AD
        -- Master
        if (v.m.state = addr or (v.m.state = m_data and r.m.hwrite = '1') or v.m.state = dr_bus) then
            v.pci.oe_ad := '0';
        end if;
        -- Target
        if r.t.read = '1' then
            if v.t.state = s_data then
                v.pci.oe_ad := '0';
                v.pci.ad := tad; end if;
            if r.t.state = s_data then
                v.pci.par := xorv(r.pci.ad & pcii.cbe);
            end if;
        end if;

        v.noe_ad := not v.pci.oe_ad; v.noe_ctrl := not v.pci.oe_ctrl;
        v.noe_par := not v.pci.oe_par; v.noe_req := not v.pci.oe_req;
        v.noe_frame := not v.pci.oe_frame; v.noe_cbe := not v.pci.oe_cbe;
        v.noe_irdy := not v.pci.oe_irdy; v.noe_perr := not v.pci.oe_perr;
        
	if (scanen = 1) and (syncrst = 1) and (ahbmi.testen = '1') then
            voe_ad := (others => ahbmi.testoen); oe_ad := '1'; oe_ctrl := '1';
            oe_par := '1'; oe_req := '1'; oe_frame := '1'; oe_cbe := '1';
            oe_irdy := '1'; oe_perr := '1';
        elsif oepol  = 0 then
	  if (syncrst = 1) and (pcirstin = '0') then
            voe_ad := (others => '1'); oe_ad := '1'; oe_ctrl := '1';
            oe_par := '1'; oe_req := '1'; oe_frame := '1'; oe_cbe := '1';
            oe_irdy := '1'; oe_perr := '1';
          else
            voe_ad := (others => v.pci.oe_ad);
            oe_ad := r.pci.oe_ad; oe_ctrl := r.pci.oe_ctrl;
            oe_par := r.pci.oe_par; oe_req := r.pci.oe_req;
            oe_frame := r.pci.oe_frame; oe_cbe := r.pci.oe_cbe;
            oe_irdy := r.pci.oe_irdy; oe_perr := r.pci.oe_perr;
          end if;
        else
	  if (syncrst = 1) and (pcirstin = '0') then
            voe_ad := (others => '0'); oe_ad := '0'; oe_ctrl := '0';
            oe_par := '0'; oe_req := '0'; oe_frame := '0'; oe_cbe := '0';
            oe_irdy := '0'; oe_perr := '0';
          else
            voe_ad := (others => v.noe_ad);
            oe_ad := r.noe_ad; oe_ctrl := r.noe_ctrl;
            oe_par := r.noe_par; oe_req := r.noe_req;
            oe_frame := r.noe_frame; oe_cbe := r.noe_cbe;
            oe_irdy := r.noe_irdy; oe_perr := r.noe_perr;
          end if;
        end if;

--------------------------        
--- SHARED SIGNALS END ---
--------------------------
        
        v.trans(0) := hstart;
        v.trans(1) := pabort;
        v.trans(2) := pstart_ack;
        v.trans(3) := pcidc;
        v.trans(4) := rtdone;
        v.trans(5) := rmdone;

        if prrst = '0' then
            v.t.state := idle; v.m.state := idle; v.m.fstate := idle;
            v.bar0 := (others => '0'); v.bar0_conf := '0';
            v.bar1 := (others => '0'); v.bar1_conf := '0';
            v.t.msel := '0'; v.t.csel := '0';
            v.t.pending := '0'; v.t.lwrite := '0';
            v.bt_enable := '1'; -- twisting enabled by default, changed through page0
            v.page(31 downto 30) := "01";
            v.page(29 downto MADDR_WIDTH-1) := zero32(29 downto MADDR_WIDTH-1);
            v.pci.par := '0';
            v.comm.msen := not pr.host; v.comm.men := '0';
            v.comm.mwie := '0'; v.comm.per := '0';
            v.stat.rta := '0'; v.stat.rma := '0';
            v.stat.sta := '0'; v.stat.dped := '0';
            v.stat.dpe := '0';
            v.cline := (others => '0');
            v.ltim := (others => '0');
            v.intline := (others => '0');
            v.trans := (others => '0');
            v.t.fifo.waddr := (others => '0');
            v.t.fifo.raddr := (others => '0');
            v.m.fifo.waddr := (others => '0');
            v.m.fifo.raddr := (others => '0');
            v.t.fifo.side := '0';
            v.m.fifo.side := '0';
            v.m.request := '0';
            v.m.hwrite := '0';
            v.m.valid := '1';
            v.m.split := '0';
            v.m.last := '0'; v.t.last := '0';
        end if;


        cbe_fifoi.wen   <= t_fifo_write;
        cbe_fifoi.waddr <= r.t.fifo.side & r.t.fifo.waddr;
        cbe_fifoi.wdata(3 downto 0) <= pr.cbe;

        fifo2i.wen   <= t_fifo_write;
        fifo2i.waddr <= r.t.fifo.side & r.t.fifo.waddr;
        fifo2i.wdata <= byte_twist(pr.ad, r.bt_enable);
        
        fifo1i.ren   <= '1';
        fifo1i.raddr <= t_read_side & (r.t.fifo.raddr + readt_dly);
        
        fifo4i.wen   <= m_fifo_write;
        fifo4i.waddr <= r.m.fifo.side & r.m.fifo.waddr;
        fifo4i.wdata <= pr.ad;
        
        fifo3i.ren   <= '1';
        fifo3i.raddr <= m_read_side & (r.m.fifo.raddr + data_transfer);
        
        rin <= v;
        rioe_ad <= voe_ad;

        
        pcio.cbeen    <= (others => oe_cbe);
        pcio.cbe      <= r.pci.cbe;

        pcio.vaden    <= roe_ad; 
        pcio.aden     <= oe_ad;
        pcio.ad       <= r.pci.ad;

--    pcio.trdy     <= r.pci.trdy;
        pcio.trdy     <= r.t.trdy_del; -- (send last word in fifo) bug fix *** 
        pcio.ctrlen   <= oe_ctrl;
        pcio.trdyen   <= oe_ctrl;
        pcio.devselen <= oe_ctrl;
        pcio.stopen   <= oe_ctrl;
        pcio.stop     <= r.pci.stop;
        pcio.devsel   <= r.pci.devsel;
        pcio.par      <= r.pci.par;
        pcio.paren    <= oe_par;
        pcio.perren   <= oe_perr;
        pcio.perr     <= r.pci.perr;

        pcio.reqen    <= oe_req;
        pcio.req      <= r.pci.req;
        pcio.frameen  <= oe_frame;
        pcio.frame    <= r.pci.frame;
        pcio.irdyen   <= oe_irdy;
        pcio.irdy     <= r.pci.irdy;

    end process;

    rstinputgen : if hostrst = 0 generate
        pcirstin <= pcii.rst;
        pcio.rst <= '1';
    end generate;
    hostrstgen : if hostrst = 1 generate
        --pcirstin <= rst when pcii.host = '0' else pcii.rst;
        pcirstin <= pcii.rst;
        pcio.rst <= rst when pcii.host = '0' else '1';
    end generate;

    
    pcirst <= ahbmi.testrst when (scanen = 1) and (ahbmi.testen = '1') 
	else  pcirstin;

    pr_regs : process (pciclk)
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
        prrst         <= to_x01(pcirstin);
        pr.gnt        <= to_x01(pcii.gnt);
        pr.host       <= to_x01(pcii.host);
      end if;
    end process;

    regs : process (pciclk, pcirst)
    begin
      if rising_edge (pciclk) then
        r <= rin;
      end if;
      if (syncrst = 0) and (pcirst = '0') then -- asynch reset required
        r.pci.oe_ad <= '1'; r.pci.oe_ctrl <= '1'; r.pci.oe_par <= '1';
        r.pci.oe_req <= '1'; r.pci.oe_frame <= '1'; r.pci.oe_cbe <= '1';
        r.pci.oe_irdy <= '1'; r.pci.oe_perr <= '1';
        r.noe_ad <= '0'; r.noe_ctrl <= '0'; r.noe_par <= '0';
        r.noe_req <= '0'; r.noe_frame <= '0'; r.noe_cbe <= '0';
        r.noe_irdy <= '0'; r.noe_perr <= '0';
      end if;
    end process;

    oeregs_pol0 : if oepol = 0 generate
      oeregs : process (pciclk, pcirst)
      begin
        if rising_edge (pciclk) then
          roe_ad <= rioe_ad; 
        end if;
        if (syncrst = 0) and (pcirst = '0') then -- asynch reset required
          roe_ad <= (others => '1');
        end if;
      end process;
    end generate;

    oeregs_pol1 : if oepol = 1 generate
      oeregs : process (pciclk, pcirst)
      begin
        if rising_edge (pciclk) then
          roe_ad <= rioe_ad; 
        end if;
        if (syncrst = 0) and (pcirst = '0') then -- asynch reset required
          roe_ad <= (others => '0');
        end if;
      end process;
    end generate;

    cpur : process (clk)
    begin
        if rising_edge (clk) then
            r2 <= r2in;
        end if;
    end process;

    oe0 : if oepol = 0 generate 
        pcio.serren   <= '1';
        pcio.inten    <= '1';
        pcio.locken   <= '1';
    end generate;

    oe1 : if oepol = 1 generate
        pcio.serren   <= '0';
        pcio.inten    <= '0';
        pcio.locken   <= '0';
    end generate;
    
    pcio.serr     <= '1';
    pcio.int      <= '1';
    pcio.lock     <= '1';

    pcio.power_state <= (others => '0');
    pcio.pme_enable <= '0';
    pcio.pme_clear <= '0';


    msttgt : if MASTER = 1 generate

        ahbmst0 : pciahbmst generic map (hindex => hmstndx, devid => GAISLER_PCIFBRG, incaddr => 1)
            port map (rst, clk, dmai, dmao, ahbmi, ahbmo);

        fifo1 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH, dbits => FIFO_DATA_BITS, sepclk => 1)
            port map (pciclk, fifo1i.ren, fifo1i.raddr, fifo1o.rdata, clk, fifo1i.wen, fifo1i.waddr, fifo1i.wdata);

        fifo2 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH, dbits => FIFO_DATA_BITS, sepclk => 1)
            port map (clk, fifo2i.ren, fifo2i.raddr, fifo2o.rdata, pciclk, fifo2i.wen, fifo2i.waddr, fifo2i.wdata);

        fifo3 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH, dbits => FIFO_DATA_BITS, sepclk => 1)
            port map (pciclk, fifo3i.ren, fifo3i.raddr, fifo3o.rdata, clk, fifo3i.wen, fifo3i.waddr, fifo3i.wdata);

        fifo4 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH, dbits => FIFO_DATA_BITS, sepclk => 1)
            port map (clk, fifo4i.ren, fifo4i.raddr, fifo4o.rdata, pciclk, fifo4i.wen, fifo4i.waddr, fifo4i.wdata);

        cbe_fifo : syncram_2p generic map (tech => 0, abits => FIFO_DEPTH, dbits => 4, sepclk => 1)
            port map (clk, cbe_fifoi.ren, cbe_fifoi.raddr, cbe_fifoo.rdata(3 downto 0), pciclk, cbe_fifoi.wen, cbe_fifoi.waddr, cbe_fifoi.wdata(3 downto 0));
        
-- pragma translate_off
        bootmsg : report_version
            generic map ("pci_mtf" & tost(hslvndx) &
                         ": 32-bit PCI/AHB bridge  rev " & tost(REVISION) &
                         ", " & tost(2**abits/2**20) & " Mbyte PCI memory BAR, " &
                         tost(2**FIFO_DEPTH) & "-word FIFOs" );
-- pragma translate_on

    end generate;

    tgtonly : if MASTER = 0 generate
        ahbmst0 : pciahbmst generic map (hindex => hmstndx, devid => GAISLER_PCIFBRG, incaddr => 1)
            port map (rst, clk, dmai, dmao, ahbmi, ahbmo);

        fifo1 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH, dbits => FIFO_DATA_BITS, sepclk => 1)
            port map (pciclk, fifo1i.ren, fifo1i.raddr, fifo1o.rdata, clk, fifo1i.wen, fifo1i.waddr, fifo1i.wdata);

        fifo2 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH, dbits => FIFO_DATA_BITS, sepclk => 1)
            port map (clk, fifo2i.ren, fifo2i.raddr, fifo2o.rdata, pciclk, fifo2i.wen, fifo2i.waddr, fifo2i.wdata);

        cbe_fifo : syncram_2p generic map (tech => 0, abits => FIFO_DEPTH, dbits => 4, sepclk => 1)
            port map (clk, cbe_fifoi.ren, cbe_fifoi.raddr, cbe_fifoo.rdata(3 downto 0), pciclk, cbe_fifoi.wen, cbe_fifoi.waddr, cbe_fifoi.wdata(3 downto 0));
        
-- pragma translate_off
        bootmsg : report_version
            generic map ("pci_mtf" & tost(hmstndx) &
                         ": 32-bit PCI/AHB bridge  rev, target-only, " & tost(REVISION) &
                         ", " & tost(2**abits/2**20) & " Mbyte PCI memory BAR, " &
                         tost(2**FIFO_DEPTH) & "-word FIFOs" );
-- pragma translate_on
    end generate;

end;
