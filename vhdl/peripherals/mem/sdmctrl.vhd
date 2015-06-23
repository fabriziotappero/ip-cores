



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
-- Entity  	mctrl
-- File 	mctrl.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	SDRAM memory controller.
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned.conv_integer;
use IEEE.std_logic_arith.conv_unsigned;
use work.peri_mem_config.all;
use work.peri_mem_comp.all;
use work.macro.all;
use work.amba.all;

entity sdmctrl is
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    sdi    : in  sdram_in_type;
    sdo    : out sdram_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    wpo    : in  wprot_out_type;
    sdmo   : out sdram_mctrl_out_type
  );
end; 

architecture rtl of sdmctrl is


type mcycletype is (midle, active, leadout);
type sdcycletype is (act1, act2, act3, rd1, rd2, rd3, rd4, rd5, rd6, rd7, rd8,
		     wr1, wr2, wr3, wr4, sidle);
type icycletype is (iidle, pre, ref1, ref2, lmode, finish);

-- sdram configuration register

type sdram_cfg_type is record
  command          : std_logic_vector(1 downto 0);
  csize            : std_logic_vector(1 downto 0);
  bsize            : std_logic_vector(2 downto 0);
  casdel           : std_logic;  -- CAS to data delay: 2/3 clock cycles
  trfc             : std_logic_vector(2 downto 0);
  trp              : std_logic;  -- precharge to activate: 2/3 clock cycles
  refresh          : std_logic_vector(14 downto 0);
  renable          : std_logic;
end record;

-- local registers

type reg_type is record
  hready        : std_logic;
  hsel          : std_logic;
  bdrive        : std_logic;
  burst         : std_logic;
  busy          : std_logic;
  bdelay        : std_logic;
  wprothit      : std_logic;

  mstate	: mcycletype;
  sdstate	: sdcycletype;
  cmstate	: mcycletype;
  istate	: icycletype;

  cfg           : sdram_cfg_type;
  trfc          : std_logic_vector(2 downto 0);
  refresh       : std_logic_vector(14 downto 0);
  sdcsn  : std_logic_vector(1  downto 0);
  sdwen  : std_logic;
  rasn : std_logic;
  casn : std_logic;
  dqm  : std_logic_vector(3 downto 0);
  -- only needed to keep address lines from switch too much
  address  	: std_logic_vector(16 downto 2);  -- memory address
end record;


signal r, ri : reg_type;

begin

  ctrl : process(rst, apbi, sdi, wpo, r)
  variable v : reg_type;		-- local variables for registers
  variable startsd : std_logic;
  variable dataout : std_logic_vector(31 downto 0); -- data from memory
  variable regsd : std_logic_vector(31 downto 0);   -- data from registers
  variable dqm      : std_logic_vector(3 downto 0);
  variable raddr    : std_logic_vector(12 downto 0);
  variable adec     : std_logic;
  variable rams     : std_logic_vector(1 downto 0);
  variable hresp    : std_logic_vector(1 downto 0);
  variable ba       : std_logic_vector(1 downto 0);

  begin

-- Variable default settings to avoid latches

    v := r; startsd := '0'; v.busy := '0'; hresp := HRESP_OKAY;

    if sdi.hready = '1' then v.hsel := sdi.hsel; end if;
    if (sdi.hready and sdi.hsel ) = '1' then
      if sdi.htrans(1) = '1' then v.hready := '0'; end if;
    end if;


-- main state

    case sdi.hsize is
    when "00" =>
      case sdi.rhaddr(1 downto 0) is
      when "00" => dqm := "0111";
      when "01" => dqm := "1011";
      when "10" => dqm := "1101";
      when others => dqm := "1110";
      end case;
    when "01" =>
      if sdi.rhaddr(1) = '0' then dqm := "0011"; else  dqm := "1100"; end if;
    when others => dqm := "0000";
    end case;

-- main FSM

    case r.mstate is
    when midle =>
      if (v.hsel and sdi.nhtrans(1)) = '1' then
	if (r.sdstate = sidle) and (r.cfg.command = "00") and 
	   (r.cmstate = midle) and (sdi.idle = '1')
        then startsd := '1'; v.mstate := active; end if;
      end if;
    when others => null;
    end case;
      
-- generate row and column address size

    case r.cfg.csize is
    when "00" => raddr := sdi.haddr(22 downto 10);
    when "01" => raddr := sdi.haddr(23 downto 11);
    when "10" => raddr := sdi.haddr(24 downto 12);
    when others => 
      if r.cfg.bsize = "111" then raddr := sdi.haddr(26 downto 14);
      else raddr := sdi.haddr(25 downto 13); end if;
    end case;

-- generate bank address

    ba := genmux(r.cfg.bsize, sdi.haddr(28 downto 21)) &
          genmux(r.cfg.bsize, sdi.haddr(27 downto 20));

-- generate chip select

    adec := genmux(r.cfg.bsize, sdi.haddr(29 downto 22));
    rams := adec & not adec;

-- sdram access FSM

    case r.sdstate is
    when sidle =>
      v.bdelay := '0';
      if startsd = '1' then
        v.address(16 downto 2) := ba & raddr;
	v.sdcsn := not rams(1 downto 0); v.rasn := '0'; v.sdstate := act1; 
      end if;
    when act1 =>
	v.rasn := '1'; 
	if r.cfg.casdel = '1' then v.sdstate := act2; else
	  v.sdstate := act3;
          v.hready := sdi.hwrite and sdi.htrans(0) and sdi.htrans(1);
	end if;
        if CFG_PERIMEM_WPROTEN then 
	  v.wprothit := wpo.wprothit;
	  if wpo.wprothit = '1' then hresp := HRESP_ERROR; end if;
	end if;
    when act2 =>
	v.sdstate := act3; 
        v.hready := sdi.hwrite and sdi.htrans(0) and sdi.htrans(1);
        if CFG_PERIMEM_WPROTEN and (r.wprothit = '1') then 
	  hresp := HRESP_ERROR; v.hready := '0'; 
	end if;
    when act3 =>
      v.casn := '0'; 
      v.address(14 downto 2) := sdi.rhaddr(13 downto 12) & '0' & sdi.rhaddr(11 downto 2);
      v.dqm := dqm; v.burst := r.hready;

      if sdi.hwrite = '1' then

	v.sdstate := wr1; v.sdwen := '0'; v.bdrive := '1';
        if sdi.htrans = "11" or (r.hready = '0') then v.hready := '1'; end if;
        if CFG_PERIMEM_WPROTEN and (r.wprothit = '1') then
	  hresp := HRESP_ERROR; v.hready := '1'; 
	  v.sdstate := wr1; v.sdwen := '1'; v.bdrive := '0'; v.casn := '1';
	end if;
      else v.sdstate := rd1; end if;
    when wr1 =>
      v.address(14 downto 2) := sdi.rhaddr(13 downto 12) & '0' & sdi.rhaddr(11 downto 2);
      if (((r.burst and r.hready) = '1') and (sdi.rhtrans = "11"))
      and not (CFG_PERIMEM_WPROTEN and (r.wprothit = '1'))
      then 
	v.hready := sdi.htrans(0) and sdi.htrans(1) and r.hready;
--	v.hready := sdi.htrans(0) and r.hready;
      else
        v.sdstate := wr2; v.bdrive := '0'; v.casn := '1'; v.sdwen := '1';
	v.dqm := "1111";
      end if;
    when wr2 =>
      v.rasn := '0'; v.sdwen := '0'; v.sdstate := wr3;
    when wr3 =>
      v.sdcsn := "11"; v.rasn := '1'; v.sdwen := '1'; 
      if (r.cfg.trp = '1') then v.sdstate := wr4;
      else v.sdstate := sidle; end if;
    when wr4 =>
      v.sdstate := sidle;
    when rd1 =>
--      v.bdelay := r.cfg.casdel;
      v.casn := '1';
      if CFG_PERIMEM_SDINVCLK then
        if r.cfg.casdel = '1' then v.sdstate := rd2;
        else
          v.sdstate := rd3;
          if sdi.htrans /= "11" then v.rasn := '0'; v.sdwen := '0'; end if;
        end if;
      else v.sdstate := rd7; end if;

    when rd7 =>
      if r.cfg.casdel = '1' then v.sdstate := rd2;
      else
        v.sdstate := rd3;
        if sdi.htrans /= "11" then v.rasn := '0'; v.sdwen := '0'; end if;
      end if;

    when rd2 =>
      v.sdstate := rd3;
      if sdi.htrans /= "11" then v.rasn := '0'; v.sdwen := '0'; end if;

      if v.sdwen = '0' then v.dqm := "1111"; end if;
    when rd3 =>
      v.sdstate := rd4; v.hready := '1';
      if r.sdwen = '0' then
	v.rasn := '1'; v.sdwen := '1'; v.sdcsn := "11"; v.dqm := "1111";
      end if;

    when rd4 =>
      v.hready := '1';

      if sdi.htrans /= "11" or (r.sdcsn = "11") then

        v.hready := '0'; v.dqm := "1111";
        if (r.sdcsn /= "11") then
	  v.rasn := '0'; v.sdwen := '0'; v.sdstate := rd5;
	else
          if r.cfg.trp = '1' then v.sdstate := rd6; 
	  else v.sdstate := sidle; end if;
        end if;
      end if;
    when rd5 =>
--      if (r.cfg.trp or (r.hsel and not sdi.rhaddr(30)))= '1' then 
      if r.cfg.trp = '1' then 
	v.sdstate := rd6; 
      else v.sdstate := sidle; end if;
      v.sdcsn := (others => '1'); v.rasn := '1'; v.sdwen := '1'; v.dqm := "1111";
    when rd6 =>
      v.sdstate := sidle; v.dqm := "1111";

      v.sdcsn := (others => '1'); v.rasn := '1'; v.sdwen := '1';

    when others =>
	v.sdstate := sidle;
    end case;

-- sdram commands

    case r.cmstate is
    when midle =>
      if r.sdstate = sidle then
        case r.cfg.command is
        when "01" => -- precharge
          if (sdi.idle = '1') then
	    v.busy := '1';
	    v.sdcsn := (others => '0'); v.rasn := '0'; v.sdwen := '0';
	    v.address(12) := '1'; v.cmstate := active;
	  end if;
        when "10" => -- auto-refresh
	  v.sdcsn := (others => '0'); v.rasn := '0'; v.casn := '0';
          v.cmstate := active;
        when "11" =>
          if (sdi.idle = '1') then
	    v.busy := '1';
	    v.sdcsn := (others => '0'); v.rasn := '0'; v.casn := '0'; 
	    v.sdwen := '0'; v.cmstate := active;
	    v.address(15 downto 2) := "000010001" & r.cfg.casdel & "0111";
	  end if;
        when others => null;
        end case;
      end if;
    when active =>
      v.sdcsn := (others => '1'); v.rasn := '1'; v.casn := '1'; 
      v.sdwen := '1'; v.cfg.command := "00";
      v.cmstate := leadout; v.trfc := r.cfg.trfc;
    when leadout =>
      v.trfc := r.trfc - 1;
      if r.trfc = "000" then v.cmstate := midle; end if;

    end case;

-- sdram init

    case r.istate is
    when iidle =>
      if (sdi.idle and sdi.enable) = '1' then
        v.cfg.command := "01"; v.istate := pre;
      end if;
    when pre =>
      if r.cfg.command = "00" then
        v.cfg.command := "10"; v.istate := ref1;
      end if;
    when ref1 =>
      if r.cfg.command = "00" then
        v.cfg.command := "10"; v.istate := ref2;
      end if;
    when ref2 =>
      if r.cfg.command = "00" then
        v.cfg.command := "11"; v.istate := lmode;
      end if;
    when lmode =>
      if r.cfg.command = "00" then
        v.istate := finish;
      end if;
    when others =>
      if sdi.enable = '0' then
        v.istate := iidle;
      end if;
    end case;

    if (sdi.hready and sdi.hsel ) = '1' then
      if sdi.htrans(1) = '0' then v.hready := '1'; end if;
    end if;

-- second part of main fsm

    case r.mstate is
    when active =>
      if v.hready = '1' then
	v.mstate := midle;
      end if;
    when others => null;
    end case;

-- sdram refresh counter

-- pragma translate_off
    if not is_x(r.cfg.refresh) then
-- pragma translate_on
      if (r.cfg.renable = '1') and (r.istate = finish) then 
	v.refresh := r.refresh - 1;
        if (v.refresh(14) and not r.refresh(14))  = '1' then 
	  v.refresh := r.cfg.refresh;
	  v.cfg.command := "10";
	end if;
      end if;
-- pragma translate_off
    end if;
-- pragma translate_on

-- APB register access


    if (apbi.psel and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(3 downto 2) is
      when "01" =>
        if sdi.enable = '1' then
          v.cfg.command     :=  apbi.pwdata(20 downto 19); 
        end if;
        v.cfg.csize       :=  apbi.pwdata(22 downto 21); 
        v.cfg.bsize       :=  apbi.pwdata(25 downto 23); 
        v.cfg.casdel      :=  apbi.pwdata(26); 
        v.cfg.trfc        :=  apbi.pwdata(29 downto 27); 
        v.cfg.trp         :=  apbi.pwdata(30); 
        v.cfg.renable     :=  apbi.pwdata(31); 
      when "10" =>
        v.cfg.refresh     :=  apbi.pwdata(26 downto 12); 
        v.refresh         :=  (others => '0');
      when others =>
      end case;
    end if;

    regsd := (others => '0');
    case apbi.paddr(3 downto 2) is
    when "01" => 
      regsd(31 downto 19) := r.cfg.renable & r.cfg.trp & r.cfg.trfc &
	 r.cfg.casdel & r.cfg.bsize & r.cfg.csize & r.cfg.command; 
    when others => 
      regsd(26 downto 12) := r.cfg.refresh; 
    end case;
    apbo.prdata <= regsd;

-- synchronise with sram/prom controller

    if (r.sdstate < wr3) or (v.hsel = '1') then v.busy := '1';end if;
    v.busy := v.busy or r.bdelay;

-- generate memory address

    sdmo.address <= v.address;

-- reset

    if rst = '0' then
      v.sdstate	      := sidle; 
      v.mstate	      := midle; 
      v.istate	      := iidle; 
      v.cmstate	      := midle; 
      v.hsel	      := '0';
      v.cfg.command   := "00";
      v.cfg.csize     := "10";
      v.cfg.bsize     := "000";
      v.cfg.casdel    :=  '1';
      v.cfg.trfc      := "111";
      v.cfg.renable   :=  '0';
      v.cfg.trp       :=  '1';
      v.dqm	      := (others => '1');
      v.sdwen	      := '1';
      v.rasn	      := '1';
      v.casn	      := '1';
      v.hready	      := '1';
    end if;

    ri <= v; 

    sdmo.bdrive  <= v.bdrive;

    sdo.sdcke    <= (others => '1');
    sdo.sdcsn    <= r.sdcsn;
    sdo.sdwen    <= r.sdwen;
    sdo.dqm      <= r.dqm;
    sdo.rasn     <= r.rasn;
    sdo.casn     <= r.casn;
    sdmo.busy    <= v.busy or r.busy;
    sdmo.aload   <= r.busy and not v.busy;

    sdmo.hready  <= r.hready;

    sdmo.hresp   <= hresp;
    sdmo.hsel    <= r.hsel;

  end process;


    regs : process(clk,rst)
    begin 

      if rising_edge(clk) then r <= ri; end if;

      if rst = '0' then
        r.bdrive <= '0';
        r.sdcsn  <= (others => '1');
      end if;
    end process;

end;

