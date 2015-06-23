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
-- Entity: 	ddrsp
-- File:	ddrsp.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	16-bit DDR266 SDRAM memory controller.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use grlib.devices.all;
use gaisler.memctrl.all;

entity ddrsp is
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#f00#;
    ioaddr  : integer := 16#000#;
    iomask  : integer := 16#fff#;
    MHz     : integer := 100;
    col     : integer := 9; 
    Mbit    : integer := 256; 
    fast    : integer := 0; 
    pwron   : integer := 0;
    oepol   : integer := 0
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    sdi     : in  sdctrl_in_type;
    sdo     : out sdctrl_out_type
  );
end; 

architecture rtl of ddrsp is

constant REVISION  : integer := 0;

constant CMD_PRE  : std_logic_vector(2 downto 0) := "010";
constant CMD_REF  : std_logic_vector(2 downto 0) := "100";
constant CMD_LMR  : std_logic_vector(2 downto 0) := "110";
constant CMD_EMR  : std_logic_vector(2 downto 0) := "111";

constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_DDRSP, 0, REVISION, 0),
  4 => ahb_membar(haddr, '1', '1', hmask),
  5 => ahb_iobar(ioaddr, iomask),
  others => zero32);

type mcycletype is (midle, active, ext, leadout);
type sdcycletype is (act1, act2, act3, rd1, rd2, rd3, rd4, rd5, rd6, rd7, rd8,
		     wr1, wr2, wr3, wr4a, wr4, wr5, sidle);
type icycletype is (iidle, pre, ref1, ref2, emode, lmode, finish);

-- sdram configuration register

type sdram_cfg_type is record
  command          : std_logic_vector(2 downto 0);
  csize            : std_logic_vector(1 downto 0);
  bsize            : std_logic_vector(2 downto 0);
  casdel           : std_ulogic;  -- tCD : 2/3 clock cycles
  trfc             : std_logic_vector(2 downto 0);
  trp              : std_ulogic;  -- precharge to activate: 2/3 clock cycles
  refresh          : std_logic_vector(11 downto 0);
  renable          : std_ulogic;
  dllrst	   : std_ulogic;
  refon            : std_ulogic;
  cke              : std_ulogic;
end record;

-- local registers

type reg_type is record
  hready        : std_ulogic;
  hsel          : std_ulogic;
  bdrive        : std_ulogic;
  qdrive        : std_ulogic;
  nbdrive       : std_ulogic; 
  burst         : std_ulogic;
  hio           : std_ulogic;
  startsd       : std_ulogic;

  mstate	: mcycletype;
  sdstate	: sdcycletype;
  cmstate	: mcycletype;
  istate	: icycletype;

  haddr         : std_logic_vector(31 downto 0);
  hrdata        : std_logic_vector(31 downto 0);
  hwdata        : std_logic_vector(31 downto 0);
  hwrite        : std_ulogic;
  htrans        : std_logic_vector(1 downto 0);
  hresp 	: std_logic_vector(1 downto 0);
  size		: std_logic_vector(1 downto 0);

  cfg           : sdram_cfg_type;
  trfc          : std_logic_vector(2 downto 0);
  refresh       : std_logic_vector(11 downto 0);
  sdcsn  	: std_logic_vector(1  downto 0);
  sdwen  	: std_ulogic;
  rasn 		: std_ulogic;
  casn 		: std_ulogic;
  dqm  		: std_logic_vector(3 downto 0);
  address  	: std_logic_vector(16 downto 2);  -- memory address
end record;

signal r, ri : reg_type;
signal rbdrive, ribdrive : std_logic_vector(31 downto 0);
attribute syn_preserve : boolean;
attribute syn_preserve of rbdrive : signal is true; 

begin

  ctrl : process(rst, ahbsi, r, sdi, rbdrive)
  variable v       : reg_type;		-- local variables for registers
  variable startsd : std_ulogic;
  variable dataout : std_logic_vector(31 downto 0); -- data from memory
  variable regsd   : std_logic_vector(31 downto 0);   -- data from registers
  variable dqm     : std_logic_vector(3 downto 0);
  variable raddr   : std_logic_vector(12 downto 0);
  variable adec    : std_ulogic;
  variable rams    : std_logic_vector(1 downto 0);
  variable ba      : std_logic_vector(1 downto 0);
  variable haddr   : std_logic_vector(31 downto 0);
  variable dout    : std_logic_vector(31 downto 0);
  variable hsize   : std_logic_vector(1 downto 0);
  variable hwrite  : std_ulogic;
  variable htrans  : std_logic_vector(1 downto 0);
  variable hready  : std_ulogic;
  variable vbdrive : std_logic_vector(31 downto 0);
  variable bdrive  : std_ulogic; 
  begin

-- Variable default settings to avoid latches

    v := r; startsd := '0'; v.hresp := HRESP_OKAY; vbdrive := rbdrive; 
    v.hrdata(31 downto 0) := sdi.data(31 downto 0); 
    v.hwdata := ahbsi.hwdata; v.qdrive :='0';

    if ((ahbsi.hready and ahbsi.hsel(hindex)) = '1') then
      v.size := ahbsi.hsize(1 downto 0); v.hwrite := ahbsi.hwrite;
      v.htrans := ahbsi.htrans;
      if ahbsi.htrans(1) = '1' then
        v.hio := ahbsi.hmbsel(1);
	v.hsel := '1'; v.hready := v.hio;
      end if;
      v.haddr := ahbsi.haddr;
    end if;

    if (r.hsel = '1') and (ahbsi.hready = '0') then 
      haddr := r.haddr;  hsize := r.size;
      htrans := r.htrans; hwrite := r.hwrite;
    else 
      haddr := ahbsi.haddr;  hsize := ahbsi.hsize(1 downto 0); 
      htrans := ahbsi.htrans; hwrite := ahbsi.hwrite;
    end if;
    if fast = 1 then haddr := r.haddr; end if;

    if ahbsi.hready = '1' then v.hsel := ahbsi.hsel(hindex); end if;

-- generate DQM from address and write size

    case r.size is
    when "00" =>
      case r.haddr(1 downto 0) is
      when "00" => dqm := "0111";
      when "01" => dqm := "1011";
      when "10" => dqm := "1101";
      when others => dqm := "1110";
      end case;
    when "01" =>
      if r.haddr(1) = '0' then dqm := "0011"; else  dqm := "1100"; end if;
    when others => dqm := "0000";
    end case;

-- main FSM

    case r.mstate is
    when midle =>
      if ((v.hsel and htrans(1) and not v.hio) = '1') then
	if (r.sdstate = sidle) and (r.cfg.command = "000") and 
	   (r.cmstate = midle) and (v.hio = '0')
        then 
	  if fast = 0 then startsd := '1';  else v.startsd := '1'; end if;
	  v.mstate := active;
	end if;
      end if;
    when others => null;
    end case;
      
    startsd := startsd or r.startsd;

-- generate row and column address size

    case r.cfg.csize is
    when "00" => raddr := haddr(21 downto  9);
    when "01" => raddr := haddr(22 downto 10);
    when "10" => raddr := haddr(23 downto 11);
    when others => 
      if r.cfg.bsize = "110" then raddr := haddr(25 downto 13);
      else raddr := haddr(24 downto 12); end if;
    end case;

-- generate bank address

    ba := genmux(r.cfg.bsize, haddr(28 downto 21)) &
          genmux(r.cfg.bsize, haddr(27 downto 20));

-- generate chip select

    adec := genmux(r.cfg.bsize, haddr(29 downto 22));

    rams := adec & not adec;

-- sdram access FSM

    if r.trfc /= "000" then v.trfc := r.trfc - 1; end if;

    case r.sdstate is
    when sidle =>
      if (startsd = '1') and (r.cfg.command = "000") and (r.cmstate = midle) 
	and (r.istate = finish)
      then
        v.address(16 downto 2) := ba & raddr;
	v.sdcsn := not rams(1 downto 0); v.rasn := '0'; v.sdstate := act1; 
	v.startsd := '0';
      end if;
    when act1 =>
	v.rasn := '1'; v.trfc := r.cfg.trfc;
	if r.cfg.casdel = '1' then v.sdstate := act2; else
	  v.sdstate := act3;
          v.hready := r.hwrite and ahbsi.htrans(0) and ahbsi.htrans(1);
	end if;
    when act2 =>
	v.sdstate := act3; 
        v.hready := r.hwrite and ahbsi.htrans(0) and ahbsi.htrans(1);
    when act3 =>
      v.casn := '0'; 
      v.address(14 downto 2) := r.haddr(12 downto 11) & '0' & r.haddr(10 downto 2) & '0';
      v.dqm := dqm; v.burst := r.hready;
      if r.hwrite = '1' then
	v.sdstate := wr1; v.sdwen := '0'; v.bdrive := '0'; v.qdrive := '1';
        if ahbsi.htrans = "11" or (r.hready = '0') then v.hready := '1'; end if;
      else v.sdstate := rd1; end if;
    when wr1 =>
      v.sdwen := '1';  v.casn := '1';  v.qdrive := '1';
      v.address(14 downto 2) := r.haddr(12 downto 11) & '0' & r.haddr(10 downto 2) & '0';
      if (((r.burst and r.hready) = '1') and (r.htrans = "11")) then 
	v.hready := ahbsi.htrans(0) and ahbsi.htrans(1) and r.hready;
        if (r.hready = '1') and (r.address(4 downto 3) = "11") then
	  v.sdwen := '0'; v.casn := '0';
	end if;
      else
        v.sdstate := wr2;
	v.dqm := (others => '1'); --v.bdrive := '1'; 
      end if;
    when wr2 =>
      v.sdstate := wr3; v.qdrive := '1';
    when wr3 =>
	v.sdstate := wr4a; v.qdrive := '1';
    when wr4a =>
        v.bdrive := '1'; 
	v.rasn := '0'; v.sdwen := '0'; v.sdstate := wr4; v.qdrive := '1';
    when wr4 =>
      v.sdcsn := "11"; v.rasn := '1'; v.sdwen := '1';  v.qdrive := '0';
      v.sdstate := wr5;
    when wr5 =>
      v.sdstate := sidle;
    when rd1 =>
      v.casn := '1'; v.sdstate := rd7;
    when rd7 =>
      v.sdstate := rd2;
    when rd2 =>
      v.sdstate := rd3;
      if ahbsi.htrans /= "11" then v.rasn := '0'; v.sdwen := '0'; end if;
      if v.sdwen = '0' then v.dqm := (others => '1'); end if;
    when rd3 =>
      v.sdstate := rd4; v.hready := '1'; v.casn := '1';
      if r.sdwen = '0' then
	v.rasn := '1'; v.sdwen := '1'; v.sdcsn := "11"; v.dqm := (others => '1');
      elsif r.haddr(4 downto 2) = "000" then 
	v.casn := '0'; v.burst := '1'; v.address(5) := '1';
      end if;
    when rd4 =>
      v.hready := '1'; v.casn := '1';
      if (ahbsi.htrans = "11") and (r.sdcsn /= "11") and
	 (r.haddr(3 downto 2) = "11") and (r.burst = '1')
      then
	v.burst := '0';
      elsif (ahbsi.htrans /= "11") or (r.sdcsn = "11") or
	 (r.haddr(3 downto 2) = "11")
      then
        v.hready := '0'; v.dqm := (others => '1'); v.burst := '0';
        if (r.sdcsn /= "11") then
          if (ahbsi.htrans = "11") and (r.cfg.command(2) = '0') then 
	    v.sdstate := act3;
	  else v.rasn := '0'; v.sdwen := '0'; v.sdstate := rd5; end if;
	else
          if r.cfg.trp = '1' then v.sdstate := rd6; 
	  else v.sdstate := sidle; end if;
        end if;
      end if;
    when rd5 =>
      if r.cfg.trp = '1' then 
	v.sdstate := rd6; 
      else v.sdstate := sidle; end if;
      v.sdcsn := (others => '1'); v.rasn := '1'; v.sdwen := '1'; v.dqm := (others => '1');
    when rd6 =>
      v.sdstate := sidle; v.dqm := (others => '1');
      v.sdcsn := (others => '1'); v.rasn := '1'; v.sdwen := '1';
    when others =>
	v.sdstate := sidle;
    end case;

-- sdram commands

    case r.cmstate is
    when midle =>
      if r.sdstate = sidle then
        case r.cfg.command is
        when CMD_PRE => -- precharge
	    v.sdcsn := (others => '0'); v.rasn := '0'; v.sdwen := '0';
	    v.address(12) := '1'; v.cmstate := active;
        when CMD_REF => -- auto-refresh
	  v.sdcsn := (others => '0'); v.rasn := '0'; v.casn := '0';
          v.cmstate := active;
        when CMD_EMR => -- load-ext-mode-reg
	    v.sdcsn := (others => '0'); v.rasn := '0'; v.casn := '0'; 
	    v.sdwen := '0'; v.cmstate := active;
	    v.address(16 downto 2) := "010000000000000";
        when CMD_LMR => -- load-mode-reg
	    v.sdcsn := (others => '0'); v.rasn := '0'; v.casn := '0'; 
	    v.sdwen := '0'; v.cmstate := active;
--	    v.address(16 downto 2) := "000000" & r.cfg.dllrst & "0" & "01" & r.cfg.casdel & "0011";
	    v.address(16 downto 2) := "000000" & r.cfg.dllrst & "0" & "01" & "00011";
        when others => null;
        end case;
      end if;
    when active =>
      v.sdcsn := (others => '1'); v.rasn := '1'; v.casn := '1'; 
      v.sdwen := '1'; v.cfg.command := "000";
      v.cmstate := leadout; v.trfc := r.cfg.trfc;
    when others =>
      if r.trfc = "000" then v.cmstate := midle; end if;

    end case;

-- sdram init

    case r.istate is
    when iidle =>
      if r.cfg.renable = '1' then
        v.cfg.command := CMD_PRE; v.cfg.cke := '1'; v.cfg.dllrst := '1';
	if r.cfg.cke = '1' then v.istate := pre; end if;
      end if;
    when pre =>
      if r.cfg.command = "000" then
        v.cfg.command := "11" & r.cfg.dllrst; 
	if r.cfg.dllrst = '1' then v.istate := emode; else v.istate := lmode; end if;
      end if;
    when emode =>
      if r.cfg.command = "000" then
        v.istate := lmode; v.cfg.command := CMD_LMR;
      end if;
    when lmode =>
      if r.cfg.command = "000" then
	if r.cfg.dllrst = '1' then 
 	  if r.refresh(9 downto 8) = "00" then -- > 200 clocks delay
            v.cfg.command := CMD_REF; v.istate := ref1;
	  end if;
	else 
	  v.istate := finish; v.cfg.command := CMD_LMR;
	  v.cfg.refon := '1'; v.cfg.renable := '0';
	end if;
      end if;
    when ref1 =>
      if r.cfg.command = "000" then
        v.cfg.command := CMD_REF; v.cfg.dllrst := '0'; v.istate := ref2; 
      end if;
    when ref2 =>
      if r.cfg.command = "000" then
        v.cfg.command := CMD_PRE; v.istate := pre;
      end if;
    when others =>
      if r.cfg.renable = '1' then
        v.istate := iidle; v.cfg.dllrst := '1';
      end if;
    end case;

    if (ahbsi.hready and ahbsi.hsel(hindex) ) = '1' then
      if ahbsi.htrans(1) = '0' then v.hready := '1'; end if;
    end if;

    if (r.hsel and r.hio and not r.hready) = '1' then v.hready := '1'; end if;

-- second part of main fsm

    case r.mstate is
    when active =>
      if v.hready = '1' then
	v.mstate := midle;
      end if;
    when others => null;
    end case;

-- sdram refresh counter

    if ((r.cfg.refon = '1') and (r.istate = finish)) or
	(r.cfg.dllrst = '1')
    then 
	v.refresh := r.refresh - 1;
        if (v.refresh(11) and not r.refresh(11))  = '1' then 
	  v.refresh := r.cfg.refresh;
	  if r.cfg.dllrst = '0' then v.cfg.command := "100"; end if;
	end if;
    end if;

-- AHB register access

    if (r.hsel and r.hio and r.hwrite and r.htrans(1)) = '1' then
      v.cfg.refresh   :=  ahbsi.hwdata(11 downto 0); 
      v.cfg.cke       :=  ahbsi.hwdata(15); 
      v.cfg.renable   :=  ahbsi.hwdata(16); 
      v.cfg.dllrst    :=  ahbsi.hwdata(17); 
      v.cfg.command   :=  ahbsi.hwdata(20 downto 18); 
      v.cfg.csize     :=  ahbsi.hwdata(22 downto 21); 
      v.cfg.bsize     :=  ahbsi.hwdata(25 downto 23); 
      v.cfg.casdel    :=  ahbsi.hwdata(26); 
      v.cfg.trfc      :=  ahbsi.hwdata(29 downto 27); 
      v.cfg.trp       :=  ahbsi.hwdata(30); 
      v.cfg.refon     :=  ahbsi.hwdata(31); 
      v.refresh       :=  (others => '0');
    end if;

    regsd := (others => '0');
    regsd(31 downto 15) := r.cfg.refon & r.cfg.trp & r.cfg.trfc &
	 r.cfg.casdel & r.cfg.bsize & r.cfg.csize & r.cfg.command &
	 r.cfg.dllrst & r.cfg.renable & r.cfg.cke; 
    regsd(11 downto 0) := r.cfg.refresh; 

    if (r.hsel and r.hio) = '1' then dout := regsd;
    else dout := r.hrdata(31 downto 0); end if;

    v.nbdrive := not v.bdrive; 

    if oepol = 1 then bdrive := r.nbdrive; vbdrive := (others => v.nbdrive);
    else bdrive := r.bdrive; vbdrive := (others => v.bdrive);end if; 
    
-- reset

    if rst = '0' then
      v.sdstate	      := sidle; 
      v.mstate	      := midle; 
      v.istate	      := finish; 
      v.cmstate	      := midle; 
      v.hsel	      := '0';
      v.cfg.command   := "000";
      v.cfg.csize     := conv_std_logic_vector(col-8, 2);
      v.cfg.bsize     := conv_std_logic_vector(log2(Mbit/32), 3);
      if MHz > 100 then v.cfg.casdel :=  '1'; else v.cfg.casdel :=  '0'; end if;
      v.cfg.refon     :=  '0';
      v.cfg.trfc      := conv_std_logic_vector(7*MHz/100-2, 3);
      v.cfg.refresh   := conv_std_logic_vector(7800*MHz/1000, 12);
      v.refresh       :=  (others => '0');
      if pwron = 1 then v.cfg.renable :=  '1';
      else v.cfg.renable :=  '0'; end if;
      if MHz > 100 then v.cfg.trp := '1'; else v.cfg.trp := '0'; end if;
      v.dqm	      := (others => '1');
      v.sdwen	      := '1';
      v.rasn	      := '1';
      v.casn	      := '1';
      v.hready	      := '1';
      v.startsd       := '0';
      v.cfg.dllrst    := '0';
      v.cfg.cke       := '0';
    end if;

    ri <= v; 
    ribdrive <= vbdrive; 
    
    ahbso.hready  <= r.hready;
    ahbso.hresp   <= r.hresp;
    ahbso.hrdata  <= dout;
    ahbso.hcache  <= not r.hio;


  end process;

  sdo.sdcke     <= (others => r.cfg.cke);
  ahbso.hconfig <= hconfig;
  ahbso.hirq    <= (others => '0');
  ahbso.hindex  <= hindex;

  regs : process(clk, rst) begin 
    if rising_edge(clk) then
      r <= ri; rbdrive <= ribdrive;
    end if;
    if (rst = '0') then
      r.sdcsn  <= (others => '1'); r.bdrive <= '1'; r.nbdrive <= '0';
      r.cfg.cke <= '1';
      if oepol = 0 then rbdrive <= (others => '1');
      else rbdrive <= (others => '0'); end if;
    end if;
  end process;

  sdo.address  <= ri.address;
  sdo.bdrive   <= r.nbdrive when oepol = 1 else r.bdrive;
  sdo.qdrive   <= not (ri.qdrive or r.nbdrive); 
  sdo.vbdrive  <= rbdrive; 
  sdo.sdcsn    <= ri.sdcsn;
  sdo.sdwen    <= ri.sdwen;
  sdo.dqm      <= "111111111111" & r.dqm;
  sdo.rasn     <= ri.rasn;
  sdo.casn     <= ri.casn;
  sdo.data(31 downto 0) <= r.hwdata;

-- pragma translate_off
  bootmsg : report_version 
  generic map ("sdctrl" & tost(hindex) & 
	": DDR266 controller rev " & tost(REVISION));
-- pragma translate_on

end;

