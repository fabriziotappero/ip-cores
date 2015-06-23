



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	mctrl
-- File:	mctrl.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	External memory controller.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.devices.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.memctrl.all;
library esa;
use esa.memoryctrl.all;

entity smc_mctrl is
  generic (
    hindex    : integer := 0;
    pindex    : integer := 0;
    romaddr   : integer := 16#000#;
    rommask   : integer := 16#E00#;
    ioaddr    : integer := 16#200#;
    iomask    : integer := 16#E00#;
    ramaddr   : integer := 16#400#;
    rammask   : integer := 16#C00#;
    paddr     : integer := 0;
    pmask     : integer := 16#fff#;
    wprot     : integer := 0;
    invclk    : integer := 0;
    fast      : integer := 0;
    romasel   : integer := 28;
    sdrasel   : integer := 29;
    srbanks   : integer := 4;
    ram8      : integer := 0;
    ram16     : integer := 0;
    sden      : integer := 0;
    sepbus    : integer := 0;
    sdbits    : integer := 32;
    sdlsb     : integer := 2;          -- set to 12 for the GE-HPE board
    oepol     : integer := 0;
    syncrst   : integer := 0
  );
  port (
    rst       : in  std_ulogic;
    clk       : in  std_ulogic;
    memi      : in  memory_in_type;
    memo      : out memory_out_type;
    ahbsi     : in  ahb_slv_in_type;
    ahbso     : out ahb_slv_out_type;
    apbi      : in  apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    wpo       : in  wprot_out_type;
    sdo       : out sdram_out_type;
    eth_aen   : out std_logic; -- for smsc eth
    eth_readn : out std_logic; -- for smsc eth
    eth_writen: out std_logic;  -- for smsc eth
    eth_nbe   : out std_logic_vector(3 downto 0) -- for smsc eth
  );
end;

architecture rtl of smc_mctrl is

constant REVISION  : integer := 0;

constant prom : integer := 1;
constant memory : integer := 0;

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_ESA, ESA_MCTRL, 0, REVISION, 0),
  4 => ahb_membar(romaddr, '1', '1', rommask),
  5 => ahb_membar(ioaddr,  '0', '0', iomask),
  6 => ahb_membar(ramaddr, '1', '1', rammask),
  others => zero32);

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_ESA, ESA_MCTRL, 0, REVISION, 0),
  1 => apb_iobar(paddr, pmask));

constant RAMSEL5 : boolean := srbanks = 5;
constant SDRAMEN : boolean := (sden /= 0);
constant BUS16EN : boolean := (ram16 /= 0);
constant BUS8EN  : boolean := (ram8 /= 0);
constant WPROTEN : boolean := (wprot /= 0);
constant WENDFB  : boolean := false;
constant SDSEPBUS: boolean := (sepbus /= 0);
constant BUS64   : boolean := (sdbits = 64);

constant rom : integer := 0;
constant io  : integer := 1;
constant ram : integer := 2;
type memcycletype is (idle, berr, bread, bwrite, bread8, bwrite8, bread16, bwrite16);

-- memory configuration register 1 type

type mcfg1type is record
  romrws           : std_logic_vector(3 downto 0);
  romwws           : std_logic_vector(3 downto 0);
  romwidth         : std_logic_vector(1 downto 0);
  romwrite         : std_logic;

  ioen             : std_logic;
  iows             : std_logic_vector(3 downto 0);
  bexcen           : std_logic;
  brdyen           : std_logic;
  iowidth          : std_logic_vector(1 downto 0);
end record;

-- memory configuration register 2 type

type mcfg2type is record
  ramrws           : std_logic_vector(1 downto 0);
  ramwws           : std_logic_vector(1 downto 0);
  ramwidth         : std_logic_vector(1 downto 0);
  rambanksz        : std_logic_vector(3 downto 0);
  rmw              : std_logic;
  brdyen           : std_logic;
  srdis            : std_logic;
  sdren            : std_logic;
end record;

-- memory status register type

-- local registers

type reg_type is record
  address          : std_logic_vector(31 downto 0);  -- memory address
  data             : std_logic_vector(31 downto 0);  -- latched memory data
  writedata        : std_logic_vector(31 downto 0);
  writedata8       : std_logic_vector(15 downto 0);  -- lsb write data buffer
  sdwritedata      : std_logic_vector(63 downto 0);
  readdata         : std_logic_vector(31 downto 0);
  brdyn            : std_logic;
  ready            : std_logic;
  ready8           : std_logic;
  bdrive           : std_logic_vector(3 downto 0);
  nbdrive          : std_logic_vector(3 downto 0);
  ws               : std_logic_vector(3 downto 0);
  romsn		   : std_logic_vector(1 downto 0);
  ramsn		   : std_logic_vector(4 downto 0);
  ramoen	   : std_logic_vector(4 downto 0);
  size		   : std_logic_vector(1 downto 0);
  busw		   : std_logic_vector(1 downto 0);
  oen              : std_logic;
  iosn		   : std_logic_vector(1 downto 0);
  read             : std_logic;
  wrn              : std_logic_vector(3 downto 0);
  writen           : std_logic;
  bstate           : memcycletype;
  area  	   : std_logic_vector(0 to 2);
  mcfg1		   : mcfg1type;
  mcfg2		   : mcfg2type;
  bexcn            : std_logic;		-- latched external bexcn
  echeck           : std_logic;
  brmw             : std_logic;
  haddr            : std_logic_vector(31 downto 0);
  hsel             : std_logic;
  srhsel           : std_logic;
  hwrite           : std_logic;
  hburst           : std_logic_vector(2 downto 0);
  htrans           : std_logic_vector(1 downto 0);
  hresp 	   : std_logic_vector(1 downto 0);
  sa    	   : std_logic_vector(14 downto 0);
  sd    	   : std_logic_vector(63 downto 0);
  mben	   	   : std_logic_vector(3 downto 0);

  eth_aen    : std_logic; -- for smsc eth
  eth_readn  : std_logic; -- for smsc eth
  eth_writen : std_logic; -- for smsc eth
  eth_nbe    : std_logic_vector(3 downto 0);-- for smsc eth
end record;

signal r, ri : reg_type;
signal wrnout : std_logic_vector(3 downto 0);
signal sdmo : sdram_mctrl_out_type;
signal sdi  : sdram_in_type;

-- vectored output enable to data pads 
signal rbdrive, ribdrive : std_logic_vector(31 downto 0);
signal rsbdrive, risbdrive : std_logic_vector(63 downto 0);
attribute syn_preserve : boolean;
attribute syn_preserve of rbdrive : signal is true;
attribute syn_preserve of rsbdrive : signal is true; 

-- **** tame: added signal to invert polarity
-- signal bprom_cs : std_ulogic;

begin

  ctrl : process(rst, ahbsi, apbi, memi, r, wpo, sdmo, rbdrive, rsbdrive)
  variable v : reg_type;		-- local variables for registers
  variable start : std_logic;
  variable dataout : std_logic_vector(31 downto 0); -- data from memory
  variable regsd : std_logic_vector(31 downto 0);   -- data from registers
  variable memdata : std_logic_vector(31 downto 0);   -- data to memory
  variable rws : std_logic_vector(3 downto 0);		-- read waitstates
  variable wws : std_logic_vector(3 downto 0);		-- write waitstates
  variable wsnew : std_logic_vector(3 downto 0);		-- write waitstates
  variable adec : std_logic_vector(1 downto 0);
  variable rams : std_logic_vector(4 downto 0);
  variable bready, leadin : std_logic;
  variable csen : std_logic;			-- Generate chip selects
  variable aprot   : std_logic_vector(14 downto 0); --
  variable wrn   : std_logic_vector(3 downto 0); --
  variable bexc, addrerr : std_logic;
  variable ready : std_logic;
  variable writedata : std_logic_vector(31 downto 0);
  variable bwdata : std_logic_vector(31 downto 0);
  variable merrtype  : std_logic_vector(2 downto 0); -- memory error type
  variable noerror : std_logic;
  variable area  : std_logic_vector(0 to 2);
  variable bdrive : std_logic_vector(3 downto 0);
  variable ramsn : std_logic_vector(4 downto 0);
  variable romsn, busw : std_logic_vector(1 downto 0);
  variable iosn : std_logic;
  variable lock : std_logic;
  variable wprothitx : std_logic;
  variable brmw : std_logic;
  variable bidle: std_logic;
  variable haddr   : std_logic_vector(31 downto 0);
  variable hsize   : std_logic_vector(1 downto 0);
  variable hwrite  : std_logic;
  variable hburst  : std_logic_vector(2 downto 0);
  variable htrans  : std_logic_vector(1 downto 0);
  variable sdhsel, srhsel, hready  : std_logic;
  variable vbdrive : std_logic_vector(31 downto 0);
  variable vsbdrive : std_logic_vector(63 downto 0);
  variable bdrive_sel : std_logic_vector(3 downto 0);
  begin 

-- Variable default settings to avoid latches

    v := r; wprothitx := '0'; v.ready8 := '0'; v.iosn(0) := r.iosn(1);

    ready := '0'; addrerr := '0'; regsd := (others => '0'); csen := '0';

    v.ready := '0'; v.echeck := '0';
    merrtype := "---"; bready := '1';

    vbdrive := rbdrive; vsbdrive := rsbdrive; 
    
    v.data := memi.data; v.bexcn := memi.bexcn; v.brdyn := memi.brdyn;
    if (((r.brdyn and r.mcfg1.brdyen) = '1') and (r.area(io) = '1')) or
       (((r.brdyn and r.mcfg2.brdyen) = '1') and (r.area(ram) = '1') and
	 (r.ramsn(4) = '0') and RAMSEL5)
    then
      bready := '0';
    else bready := '1'; end if;

    v.hresp := HRESP_OKAY;

    if SDRAMEN and (r.hsel = '1') and (ahbsi.hready = '0') then
      haddr := r.haddr;  hsize := r.size; hburst := r.hburst;
      htrans := r.htrans; hwrite := r.hwrite;
      area := r.area;
    else
      haddr := ahbsi.haddr;  hsize := ahbsi.hsize(1 downto 0);
      hburst := ahbsi.hburst; htrans := ahbsi.htrans; hwrite := ahbsi.hwrite;
      area := ahbsi.hmbsel(0 to 2);
    end if;

    if SDRAMEN then
      if fast = 1 then
        sdhsel := ahbsi.hsel(hindex) and ahbsi.haddr(sdrasel) and
	   ahbsi.htrans(1) and ahbsi.hmbsel(2);
      else
        sdhsel := ahbsi.hsel(hindex) and ahbsi.htrans(1) and
	  r.mcfg2.sdren and ahbsi.hmbsel(2) and (ahbsi.haddr(sdrasel) or r.mcfg2.srdis);
      end if;
      srhsel := ahbsi.hsel(hindex) and not sdhsel;
    else  sdhsel := '0'; srhsel := ahbsi.hsel(hindex); end if;

-- decode memory area parameters

    leadin := '0'; rws := "----"; wws := "----"; adec := "--";
    busw := (others => '-'); brmw := '0';
    if area(rom) = '1' then
      busw := r.mcfg1.romwidth;
    end if;
    if area(ram) = '1' then
      adec := genmux(r.mcfg2.rambanksz, haddr(sdrasel downto 14)) &
              genmux(r.mcfg2.rambanksz, haddr(sdrasel-1 downto 13));

      if sdhsel = '1' then busw := "10";

      else
        busw := r.mcfg2.ramwidth;
        if ((r.mcfg2.rmw and hwrite) = '1') and
	 ((BUS16EN and (busw = "01") and (hsize = "00")) or
	  ((busw(1) = '1') and (hsize(1) = '0'))

        )
        then brmw := '1'; end if;	 -- do a read-modify-write cycle
      end if;
    end if;
    if area(io) = '1' then
      leadin := '1';
      busw := r.mcfg1.iowidth;
    end if;

-- decode waitstates, illegal access and cacheability

    if r.area(rom) = '1' then
      rws := r.mcfg1.romrws; wws := r.mcfg1.romwws;
      if (r.mcfg1.romwrite or r.read) = '0' then addrerr := '1'; end if;
    end if;
    if r.area(ram) = '1' then
      rws := "00" & r.mcfg2.ramrws; wws := "00" & r.mcfg2.ramwws;
    end if;
    if r.area(io) = '1' then
      rws := r.mcfg1.iows; wws := r.mcfg1.iows;
      if r.mcfg1.ioen = '0' then addrerr := '1'; end if;
    end if;

-- generate data buffer enables

    bdrive := (others => '1');
    case r.busw is
    when "00" => if BUS8EN then bdrive := "0001"; end if;
    when "01" => if BUS16EN then bdrive := "0011"; end if;
    when others =>
    end case;

-- generate chip select and output enable

    rams := '0' & decode(adec);
    case srbanks is
    when 0 => rams := "00000";
    when 1 => rams := "00001";
    when 2 => rams := "000" & (rams(3 downto 2) or rams(1 downto 0));
    when others =>
      if RAMSEL5 and (haddr(sdrasel) = '1') then rams := "10000"; end if;
    end case;

    iosn := '1'; ramsn := (others => '1'); romsn := (others => '1');
    if area(rom) = '1' then
      romsn := (not haddr(romasel)) & haddr(romasel);
    end if;
    if area(ram) = '1' then ramsn := not rams; end if;
    if area(io) = '1' then iosn := '0'; end if;

-- generate write strobe

    wrn := "0000";
    case r.busw is
    when "00" =>
      if BUS8EN then wrn := "1110"; end if;
    when "01" =>
      if BUS16EN then
	if (r.size = "00") and (r.brmw = '0') then
	  wrn := "11" & (not r.address(0)) & r.address(0);
        else wrn := "1100"; end if;
      end if;
    when "10" | "11" =>
      case r.size is
      when "00" =>
        case r.address(1 downto 0) is
        when "00" => wrn := "1110";
        when "01" => wrn := "1101";
        when "10" => wrn := "1011";
        when others => wrn := "0111";
        end case;
      when "01" =>
        wrn := not r.address(1) & not r.address(1) & r.address(1) & r.address(1);
      when others => null;
      end case;
    when others => null;
    end case;

    if (r.mcfg2.rmw = '1') and (r.area(ram) = '1') then wrn := not bdrive; end if;

    if (((ahbsi.hready and ahbsi.hsel(hindex) and ahbsi.htrans(1)) = '1') or (((sdmo.aload and r.hsel) = '1') and SDRAMEN))
    then
      v.area := area;
      v.address  := haddr; 
      if (busw = "00") and (hwrite = '0') and (area(io) = '0') and BUS8EN
      then v.address(1 downto 0) := "00"; end if;
      if (busw = "01") and (hwrite = '0') and (area(io) = '0') and BUS16EN
      then v.address(1 downto 0) := "00"; end if;
      if (brmw = '1') then
	v.read := '1';

      else v.read := not hwrite; end if;
      v.busw := busw; v.brmw := brmw;

    end if;

-- Select read data depending on bus width

    if BUS8EN and (r.busw = "00") then
      memdata := r.readdata(23 downto 0) & r.data(31 downto 24);
    elsif BUS16EN and (r.busw = "01") then
      memdata := r.readdata(15 downto 0) & r.data(31 downto 16);
    else
      memdata := r.data;
    end if;

    bwdata := memdata;

-- Merge data during byte write

    writedata := ahbsi.hwdata;
    if ((r.brmw and r.busw(1)) = '1')

    then
      case r.address(1 downto 0) is

      when "00" =>
	writedata(15 downto 0) := bwdata(15 downto 0);
	if r.size = "00" then
	  writedata(23 downto 16) := bwdata(23 downto 16);
	end if;
      when "01" =>
	writedata(31 downto 24) := bwdata(31 downto 24);
	writedata(15 downto 0) := bwdata(15 downto 0);
      when "10" =>
	writedata(31 downto 16) := bwdata(31 downto 16);
	if r.size = "00" then
	  writedata(7 downto 0) := bwdata(7 downto 0);
	end if;
      when  others =>
	writedata(31 downto 8) := bwdata(31 downto 8);
      end case;
    end if;
    if (r.brmw = '1') and (r.busw = "01") and BUS16EN then
      if (r.address(0) = '0') then
        writedata(23 downto 16) :=  r.data(23 downto 16);
      else
        writedata(31 downto 24) :=  r.data(31 downto 24);
      end if;
    end if;

-- save read data during 8/16 bit reads

    if BUS8EN and (r.ready8 = '1') and (r.busw = "00") then
      v.readdata := v.readdata(23 downto 0) & r.data(31 downto 24);
    elsif BUS16EN and (r.ready8 = '1') and (r.busw = "01") then
      v.readdata := v.readdata(15 downto 0) & r.data(31 downto 16);
    end if;

-- Ram, rom, IO access FSM

    if r.read = '1' then wsnew := rws; else wsnew := wws; end if;

    case r.bstate is
    when idle =>
      v.ws := wsnew;

      if r.bdrive(0) = '1' then

        if r.busw(1) = '1' then v.writedata := writedata;
	else
	  v.writedata(31 downto 16) := writedata(31 downto 16);
	  v.writedata8 := writedata(15 downto 0);
	end if;

      end if;
      if (r.srhsel = '1') and ((sdmo.busy = '0') or not SDRAMEN)

      then
        if WPROTEN then wprothitx := wpo.wprothit; end if;
	if (wprothitx or addrerr) = '1' then
	  v.hresp := HRESP_ERROR; v.bstate := berr; v.bdrive := (others => '1');
	elsif r.read = '0' then
	  if (r.busw = "00") and (r.area(io) = '0') and BUS8EN then
	    v.bstate := bwrite8;
	  elsif (r.busw = "01") and (r.area(io) = '0') and BUS16EN then
	    v.bstate := bwrite16;
   	  else v.bstate := bwrite; end if;
	  v.wrn := wrn; v.writen := '0'; v.bdrive := not bdrive;
	else
	  if r.oen = '1' then v.ramoen := r.ramsn; v.oen := '0';
	  else
	    if (r.busw = "00") and (r.area(io) = '0') and BUS8EN then v.bstate := bread8;
	    elsif (r.busw = "01") and (r.area(io) = '0') and BUS16EN then v.bstate := bread16;
	    else v.bstate := bread; end if;
	  end if;
	end if;
      end if;
    when berr =>
      v.bstate := idle; ready := '1';
      v.hresp := HRESP_ERROR;
      v.ramsn := (others => '1'); v.romsn := (others => '1');
      v.ramoen := (others => '1'); v.oen := '1'; v.iosn := "11"; v.bdrive := (others => '1');
    when bread =>
      if ((r.ws = "0000") and (r.ready = '0') and (bready = '1'))
      then
	if r.brmw = '0' then
	  ready := '1'; v.address := ahbsi.haddr; v.echeck := '1';
	end if;
        if (((ahbsi.hsel(hindex) = '0') or (ahbsi.htrans /= HTRANS_SEQ)) or (r.hburst = HBURST_SINGLE))
        then
  	  v.ramoen := (others => '1'); v.oen := '1'; v.iosn := "11";
   	  v.bstate := idle; v.read := not r.hwrite;
	  if r.brmw = '0' then
  	    v.ramsn := (others => '1'); v.romsn := (others => '1');
	  else
	    v.echeck := '1';
	  end if;
	end if;
      end if;
      if r.ready = '1' then
	v.ws := rws;
      else
	if r.ws /= "0000" then v.ws := r.ws - 1; end if;
      end if;
    when bwrite =>
      if (r.ws = "0000") and (bready = '1') then
	ready := '1'; v.wrn := (others => '1'); v.writen := '1'; v.echeck := '1';
	v.ramsn := (others => '1'); v.romsn := (others => '1'); v.iosn := "11";
	v.bdrive := (others => '1'); v.bstate := idle;
      end if;
      if r.ws /= "0000" then v.ws := r.ws - 1; end if;
    when bread8 =>
      if BUS8EN then
        if (r.ws = "0000") and (r.ready8 = '0') and (bready = '1') then
	  v.ready8 := '1'; v.ws := rws;
	  v.address(1 downto 0) := r.address(1 downto 0) + 1;

          if (r.address(1 downto 0) = "11") then
	    ready := '1'; v.address := ahbsi.haddr; v.echeck := '1';

            if (((ahbsi.hsel(hindex) = '0') or (ahbsi.htrans /= HTRANS_SEQ)) or
	        (r.hburst = HBURST_SINGLE))
            then
  	      v.ramoen := (others => '1'); v.oen := '1'; v.iosn := "11";
   	      v.bstate := idle;

  	      v.ramsn := (others => '1'); v.romsn := (others => '1');

	    end if;
          end if;
        end if;
        if (r.ready8 = '1') then v.ws := rws;
        elsif r.ws /= "0000" then v.ws := r.ws - 1; end if;
      else
	v.bstate := idle;
      end if;
    when bwrite8 =>
      if BUS8EN then
        if (r.ws = "0000") and (r.ready8 = '0') and (bready = '1') then
	  v.ready8 := '1'; v.wrn := (others => '1'); v.writen := '1';
        end if;

        if (r.ws = "0000") and (bready = '1') and
           ((r.address(1 downto 0) = "11") or
            ((r.address(1 downto 0) = "01") and (r.size = "01")) or
	    (r.size = "00"))

        then
	  ready := '1'; v.wrn := (others => '1'); v.writen := '1'; v.echeck := '1';
	  v.ramsn := (others => '1'); v.romsn := (others => '1'); v.iosn := "11";
	  v.bdrive := (others => '1'); v.bstate := idle;

        end if;
        if (r.ready8 = '1') then
	  v.address(1 downto 0) := r.address(1 downto 0) + 1; v.ws := rws;
	  v.writedata(31 downto 16) := r.writedata(23 downto 16) & r.writedata8(15 downto 8);
	  v.writedata8(15 downto 8) := r.writedata8(7 downto 0);
	  v.bstate := idle;

        end if;
        if r.ws /= "0000" then v.ws := r.ws - 1; end if;
      else
	v.bstate := idle;
      end if;
    when bread16 =>
      if BUS16EN then
        if (r.ws = "0000") and (bready = '1') and ((r.address(1) or r.brmw) = '1') and
	   (r.ready8 = '0')
        then
	  if r.brmw = '0' then
	    ready := '1'; v.address := ahbsi.haddr; v.echeck := '1';
	  end if;
          if (((ahbsi.hsel(hindex) = '0') or (ahbsi.htrans /= HTRANS_SEQ)) or
	      (r.hburst = HBURST_SINGLE))
          then
	    if r.brmw = '0' then
  	      v.ramsn := (others => '1'); v.romsn := (others => '1');
	    end if;
  	    v.ramoen := (others => '1'); v.oen := '1'; v.iosn := "11";
   	    v.bstate := idle; v.read := not r.hwrite;
	  end if;
        end if;
        if (r.ws = "0000") and (bready = '1') and (r.ready8 = '0') then
	  v.ready8 := '1'; v.ws := rws;
	  if r.brmw = '0' then v.address(1) := not r.address(1); end if;
        end if;
        if r.ws /= "0000" then v.ws := r.ws - 1; end if;
      else
	v.bstate := idle;
      end if;
    when bwrite16 =>
      if BUS16EN then
        if (r.ws = "0000") and (bready = '1') and
           ((r.address(1 downto 0) = "10") or (r.size(1) = '0'))
        then
	  ready := '1'; v.wrn := (others => '1'); v.writen := '1'; v.echeck := '1';
	  v.ramsn := (others => '1'); v.romsn := (others => '1'); v.iosn := "11";
	  v.bdrive := (others => '1'); v.bstate := idle;
        end if;
        if (r.ws = "0000") and (bready = '1') and (r.ready8 = '0') then
	  v.ready8 := '1'; v.wrn := (others => '1'); v.writen := '1';
        end if;
        if (r.ready8 = '1') then
	  v.address(1) := not r.address(1); v.ws := rws;
	  v.writedata(31 downto 16) := r.writedata8(15 downto 0);
	  v.bstate := idle;
        end if;
        if r.ws /= "0000" then v.ws := r.ws - 1; end if;
      else
	v.bstate := idle;
      end if;
    when others =>
    end case;

-- if BUSY or IDLE cycle seen, or if de-selected, return to idle state
    if (ahbsi.hready = '1') then
      if ((ahbsi.hsel(hindex) = '0') or (ahbsi.htrans = HTRANS_BUSY) or
	(ahbsi.htrans = HTRANS_IDLE))
      then
        v.bstate := idle;
        v.ramsn := (others => '1'); v.romsn := (others => '1');
        v.ramoen := (others => '1'); v.oen := '1'; v.iosn := "11";
        v.bdrive := (others => '1'); v.wrn := (others => '1');
        v.writen := '1'; v.hsel := '0'; ready := ahbsi.hsel(hindex); v.srhsel := '0';
      elsif srhsel = '1' then
        v.romsn := romsn; v.ramsn(4 downto 0) := ramsn(4 downto 0); v.iosn := iosn & '1';
        if v.read = '1' then v.ramoen(4 downto 0) := ramsn(4 downto 0); v.oen := leadin; end if;
      end if;
    end if;

-- error checking and reporting

    noerror := '1';
    if ((r.echeck and r.mcfg1.bexcen and not r.bexcn) = '1') then
      noerror := '0'; v.bstate := berr; v.hresp := HRESP_ERROR; v.bdrive := (others => '1');
    end if;

-- APB register access

    case apbi.paddr(3 downto 2) is
    when "00" =>
      regsd(28 downto 0) := r.mcfg1.iowidth &
	r.mcfg1.brdyen & r.mcfg1.bexcen & "0" & r.mcfg1.iows & r.mcfg1.ioen &
	'0' &

	"000000" & r.mcfg1.romwrite &

	'0' & r.mcfg1.romwidth & r.mcfg1.romwws & r.mcfg1.romrws;
    when "01" =>
      if SDRAMEN then
	regsd(31 downto 19) := sdmo.prdata(31 downto 19);
	if BUS64 then regsd(18) := '1'; end if;
        regsd(14 downto 13) := r.mcfg2.sdren & r.mcfg2.srdis;
      end if;
      regsd(12 downto 9) := r.mcfg2.rambanksz;
      if RAMSEL5 then regsd(7) := r.mcfg2.brdyen; end if;
      regsd(6 downto 0) := r.mcfg2.rmw & r.mcfg2.ramwidth &
	r.mcfg2.ramwws & r.mcfg2.ramrws;
    when "10" =>

      if SDRAMEN then
	regsd(26 downto 12) := sdmo.prdata(26 downto 12);
      end if;
    when others => regsd := (others => '0');
    end case;

    apbo.prdata <= regsd;

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(5 downto 2) is
      when "0000" =>
        v.mcfg1.romrws      :=  apbi.pwdata(3 downto 0);
        v.mcfg1.romwws      :=  apbi.pwdata(7 downto 4);
        v.mcfg1.romwidth    :=  apbi.pwdata(9 downto 8);
        v.mcfg1.romwrite    :=  apbi.pwdata(11);

        v.mcfg1.ioen        :=  apbi.pwdata(19);
        v.mcfg1.iows        :=  apbi.pwdata(23 downto 20);
        v.mcfg1.bexcen      :=  apbi.pwdata(25);
        v.mcfg1.brdyen      :=  apbi.pwdata(26);
        v.mcfg1.iowidth     :=  apbi.pwdata(28 downto 27);
      when "0001" =>
        v.mcfg2.ramrws      := apbi.pwdata(1 downto 0);
        v.mcfg2.ramwws      := apbi.pwdata(3 downto 2);
        v.mcfg2.ramwidth    := apbi.pwdata(5 downto 4);
        v.mcfg2.rmw         := apbi.pwdata(6);
        v.mcfg2.brdyen      := apbi.pwdata(7);
        v.mcfg2.rambanksz   := apbi.pwdata(12 downto 9);
	if SDRAMEN then
          v.mcfg2.srdis     := apbi.pwdata(13);
          v.mcfg2.sdren     := apbi.pwdata(14);
	end if;

      when others => null;
      end case;
    end if;

-- select appropriate data during reads

    if (r.area(rom) or r.area(ram)) = '1' then dataout := memdata;
    else
      if BUS8EN and (r.busw = "00") then
        dataout := r.data(31 downto 24) & r.data(31 downto 24) 
		 & r.data(31 downto 24) & r.data(31 downto 24);
      elsif BUS16EN and (r.busw = "01") then
        dataout := r.data(31 downto 16) & r.data(31 downto 16); 
      else dataout := r.data; end if;
    end if;

    v.ready := ready;
    v.srhsel := r.srhsel and not ready;
    if ahbsi.hready = '1' then v.hsel := ahbsi.hsel(hindex); end if;

    if ((ahbsi.hready and ahbsi.hsel(hindex)) = '1') then
      v.size := ahbsi.hsize(1 downto 0); v.hwrite := ahbsi.hwrite;
      v.hburst := ahbsi.hburst; v.htrans := ahbsi.htrans;
      if ahbsi.htrans(1) = '1' then v.hsel := '1'; v.srhsel := srhsel; end if;
      if SDRAMEN then
	v.haddr := ahbsi.haddr;
      end if;
    end if;

-- sdram synchronisation

    if SDRAMEN then
      v.sa := sdmo.address; v.sd := memi.sd;
      if (r.bstate /= idle) then bidle := '0';
      else
        bidle := '1';
        if (sdmo.busy and not sdmo.aload) = '1' then
          if not SDSEPBUS then
            v.address(sdlsb + 14 downto sdlsb) := sdmo.address;
          end if;
	  v.romsn := (others => '1'); v.ramsn(4 downto 0) := (others => '1');
	  v.iosn := (others =>'1'); v.ramoen(4 downto 0) := (others => '1');
	  v.oen := '1';
          v.bdrive := not (sdmo.bdrive & sdmo.bdrive & sdmo.bdrive & sdmo.bdrive);
	  v.hresp := sdmo.hresp;
        end if;
      end if;
      if (sdmo.aload and r.srhsel) = '1' then
        v.romsn := romsn; v.ramsn(4 downto 0) := ramsn(4 downto 0); v.iosn := iosn & '1';
        if v.read = '1' then v.ramoen(4 downto 0) := ramsn(4 downto 0); v.oen := leadin; end if;
      end if;
      if sdmo.hsel = '1' then
	v.writedata := writedata;
        v.sdwritedata(31 downto 0) := writedata;
        if BUS64 and sdmo.bsel = '1' then
          v.sdwritedata(63 downto 32) := writedata;
        end if; 
        hready := sdmo.hready and noerror and not r.brmw;
	if SDSEPBUS then
	  if BUS64 and sdmo.bsel = '1' then dataout := r.sd(63 downto 32);
	  else dataout := r.sd(31 downto 0); end if;
	end if;
      else hready := r.ready and noerror; end if;
    else
      hready := r.ready and noerror;
    end if;
    
    if v.read = '1' then v.mben := "0000"; else v.mben := v.wrn; end if;

    v.nbdrive := not v.bdrive;

    if oepol = 0 then
      bdrive_sel := r.bdrive;
      vbdrive(31 downto 24) := (others => v.bdrive(0));
      vbdrive(23 downto 16) := (others => v.bdrive(1));
      vbdrive(15 downto 8) := (others => v.bdrive(2));
      vbdrive(7 downto 0) := (others => v.bdrive(3));

      vsbdrive(31 downto 24) := (others => v.bdrive(0));
      vsbdrive(23 downto 16) := (others => v.bdrive(1));
      vsbdrive(15 downto 8) := (others => v.bdrive(2));
      vsbdrive(7 downto 0) := (others => v.bdrive(3));
      
      vsbdrive(63 downto 56) := (others => v.bdrive(0));
      vsbdrive(55 downto 48) := (others => v.bdrive(1));
      vsbdrive(47 downto 40) := (others => v.bdrive(2));
      vsbdrive(39 downto 32) := (others => v.bdrive(3));
    else
      bdrive_sel := r.nbdrive;
      vbdrive(31 downto 24) := (others => v.nbdrive(0));
      vbdrive(23 downto 16) := (others => v.nbdrive(1));
      vbdrive(15 downto 8) := (others => v.nbdrive(2));
      vbdrive(7 downto 0) := (others => v.nbdrive(3));

      vsbdrive(31 downto 24) := (others => v.nbdrive(0));
      vsbdrive(23 downto 16) := (others => v.nbdrive(1));
      vsbdrive(15 downto 8) := (others => v.nbdrive(2));
      vsbdrive(7 downto 0) := (others => v.nbdrive(3));
      
      vsbdrive(63 downto 56) := (others => v.nbdrive(0));
      vsbdrive(55 downto 48) := (others => v.nbdrive(1));
      vsbdrive(47 downto 40) := (others => v.nbdrive(2));
      vsbdrive(39 downto 32) := (others => v.nbdrive(3));
    end if; 
        
-- for smc lan chip ********************************************
    if (r.iosn(0) = '1' and v.iosn(0) = '0') then
       v.eth_aen := '0';
       v.eth_nbe := v.wrn and not (r.read&r.read&r.read&r.read);
    elsif (r.iosn(0) = '1' and r.eth_aen = '0') then 
       v.eth_aen := '1';
       v.eth_nbe := v.wrn;
    end if;
    
    if (r.eth_aen = '0' and v.iosn(0) = '0' and r.read = '1') then
       v.eth_readn := '0';
    else
       v.eth_readn := '1';
    end if;

    if (r.eth_aen = '0' and v.iosn(0) = '0' and r.writen = '0') then
       v.eth_writen := '0';
    else
       v.eth_writen := '1';
    end if;
-- *************************************************************
    
-- reset

    if rst = '0' then

      v.bstate 	 	 := idle; 
      v.read 		 := '1'; 
      v.wrn              := "1111";
      v.writen		 := '1'; 
      v.mcfg1.romwrite   := '0';
      v.mcfg1.ioen       := '0';
      v.mcfg1.brdyen     := '0';
      v.mcfg1.bexcen     := '0';
      v.hsel		 := '0';
      v.srhsel		 := '0';
      v.ready		 := '1';
      v.mcfg1.iows       := "0000";
      v.mcfg2.ramrws     := "00";
      v.mcfg2.ramwws     := "00";
      v.mcfg1.romrws     := "1111";
      v.mcfg1.romwws     := "1111";
      v.mcfg1.romwidth   := memi.bwidth;
      v.mcfg2.srdis      := '0';
      v.mcfg2.sdren      := '0';

      v.eth_aen      := '1'; -- for smsc eth
      v.eth_readn    := '1'; -- for smsc eth
      v.eth_writen   := '1'; -- for smsc eth
      v.eth_nbe      := (others => '1'); -- for smsc eth

      if syncrst = 1 then
        v.ramsn := (others => '1'); v.romsn := (others => '1');
        v.oen := '1'; v.iosn := "11"; v.ramoen := (others => '1');
        v.bdrive := (others => '1'); v.nbdrive := (others => '0');
        if oepol = 0 then vbdrive := (others => '1'); vsbdrive := (others => '1');
        else vbdrive := (others => '0'); vsbdrive := (others => '0'); end if; 
      end if;
    end if;

-- optional feeb-back from write stobe to data bus drivers

    if WENDFB then bdrive := r.bdrive and memi.wrn;
    else bdrive := r.bdrive; end if;

-- pragma translate_off
    for i in dataout'range loop --'
      if is_x(dataout(i)) then dataout(i) := '1'; end if;
    end loop;
-- pragma translate_on


-- drive various register inputs and external outputs

    ri <= v;

    ribdrive <= vbdrive;
    risbdrive <= vsbdrive; 
    
    ahbso.hcache <= not r.area(io);
    memo.address <= r.address;
    memo.sa <= r.sa;
    memo.ramsn          <= "111" & r.ramsn;
    memo.ramoen         <= "111" & r.ramoen;
    memo.romsn       	<= "111111" & r.romsn;
    memo.oen  		<= r.oen;
    memo.iosn  		<= r.iosn(0);
    memo.read  		<= r.read;
    memo.wrn 		<= r.wrn;
    memo.writen 	<= r.writen;
    memo.bdrive  	<= bdrive;
    memo.data		<= r.writedata;
    memo.sddata(31 downto 0)  <= r.sdwritedata(31 downto 0);
    memo.sddata(63 downto 32) <= r.sdwritedata(63 downto 32);
    memo.mben		<= r.mben;
    memo.vbdrive        <= rbdrive;
    memo.svbdrive       <= rsbdrive;
    sdi.idle 		<= bidle;
    sdi.haddr		<= haddr;
    sdi.rhaddr		<= r.haddr;
    sdi.nhtrans		<= htrans;
    sdi.rhtrans		<= r.htrans;
    sdi.htrans		<= ahbsi.htrans;
    sdi.hready		<= ahbsi.hready;
    sdi.hsize		<= r.size;
    sdi.hwrite		<= r.hwrite;
    sdi.hsel		<= sdhsel;
    sdi.enable		<= r.mcfg2.sdren;
    sdi.srdis 		<= r.mcfg2.srdis;

    ahbso.hrdata <= dataout;
    ahbso.hready <= hready;
    ahbso.hresp  <= r.hresp;

    -- for smsc eth
    eth_aen    <= r.eth_aen;
    eth_readn  <= r.eth_readn;
    eth_writen <= r.eth_writen;
    eth_nbe    <= r.eth_nbe;
 
  end process;

  stdregs : process(clk,rst)
  begin
    if rising_edge(clk) then
      r <= ri; rbdrive <= ribdrive; rsbdrive <= risbdrive;
      if rst = '0' then r.ws <= (others => '0'); end if; 
    end if;
    if (syncrst = 0) and (rst = '0') then
      r.ramsn <= (others => '1'); r.romsn <= (others => '1');
      r.oen <= '1'; r.iosn <= "11"; r.ramoen <= (others => '1');
      r.bdrive <= (others => '1'); r.nbdrive <= (others => '0');
      if oepol = 0 then rbdrive <= (others => '1'); rsbdrive <= (others => '1');
      else rbdrive <= (others => '0'); rsbdrive <= (others => '0'); end if; 
    end if;
  end process;

  ahbso.hsplit <= (others => '0');
  ahbso.hconfig <= hconfig;
  ahbso.hirq    <= (others => '0');
  ahbso.hindex <= hindex;
  apbo.pconfig  <= pconfig;
  apbo.pirq     <= (others => '0');
  apbo.pindex   <= pindex;

-- optional sdram controller

  sd0 : if SDRAMEN generate
    sdctrl : sdmctrl generic map (pindex, invclk, fast, wprot, sdbits)
	port map ( rst => rst, clk => clk, sdi => sdi,
	sdo => sdo, apbi => apbi, wpo => wpo, sdmo => sdmo);
  end generate;
  sd1 : if not SDRAMEN generate
	sdo <= ("00", "11", '1', '1', '1', "11111111");
        sdmo.address <= (others => '0'); sdmo.busy <= '0';
        sdmo.aload <= '0'; sdmo.bdrive <= '0'; sdmo.hready <= '1';
        sdmo.hresp <= "11"; sdmo.prdata <= (others => '0');

  end generate;

end;

