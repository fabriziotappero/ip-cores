



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
-- Entity: 	wprot
-- File:	wprot.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	RAM write protection
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_config.all;
use work.peri_mem_comp.all;
use work.amba.all;

entity wprot is
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    wpo    : out wprot_out_type;
    ahbsi  : in  ahb_slv_in_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type
  );
end; 

architecture rtl of wprot is

type wprottype is record
  addr    : std_logic_vector(14 downto 0);
  mask    : std_logic_vector(14 downto 0);
  enable  : std_logic;
  ablock  : std_logic;
end record;

type wprotregs is record
  wprot1, wprot2   : wprottype;
  haddr   	   : std_logic_vector(31 downto 15);
  hwrite           : std_logic;
end record;

signal r, rin : wprotregs;

begin

  ctrl : process(rst, ahbsi, apbi, r)
  variable wprothit, wprothit1, wprothit2 : std_logic;
  variable wprothitx : std_logic;
  variable aprot   : std_logic_vector(14 downto 0); -- 
  variable v : wprotregs;
  variable regsd : std_logic_vector(31 downto 0);   -- data from registers

  begin

    v := r; regsd := (others => '0');

    if (ahbsi.hready = '1') then
      v.hwrite := ahbsi.hwrite; v.haddr  := ahbsi.haddr(31 downto 15);
    end if;

    wprothit := '0'; wprothit1 := '0'; wprothit2 := '0'; 
    if WPROTEN then
      aprot := (r.haddr(29 downto 15) xor r.wprot1.addr) and r.wprot1.mask;
      if (aprot = "000000000000000") then wprothit1 := '1'; end if;
      aprot := (r.haddr(29 downto 15) xor r.wprot2.addr) and r.wprot2.mask;
      if (aprot = "000000000000000") then wprothit2 := '1'; end if;
      if (r.hwrite = '1') and (r.haddr(31 downto 30) = "01") then
	wprothit := 
	  ((r.wprot1.enable and (not wprothit1) and (not r.wprot1.ablock)) or 
	  (r.wprot2.enable and (not wprothit2) and (not r.wprot2.ablock))) or
	  (((r.wprot1.enable and wprothit1 and r.wprot1.ablock) or 
	  (r.wprot2.enable and wprothit2 and r.wprot2.ablock)) and not
	  ((r.wprot1.enable and wprothit1 and (not r.wprot1.ablock)) or 
	  (r.wprot2.enable and wprothit2 and (not r.wprot2.ablock))));
      end if;
    end if;


    case apbi.paddr(2 downto 2) is
    when "1" => 
	if WPROTEN then
	  regsd := r.wprot1.enable & r.wprot1.ablock & 
		   r.wprot1.addr & r.wprot1.mask;
	end if;
    when "0" => 
	if WPROTEN then
	  regsd := r.wprot2.enable & r.wprot2.ablock & 
		   r.wprot2.addr & r.wprot2.mask;
	end if;
    when others => null;
    end case;

    apbo.prdata <= regsd;

    if (apbi.psel and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(2 downto 2) is
      when "1" => 
        v.wprot1.enable := apbi.pwdata(31);
	v.wprot1.ablock := apbi.pwdata(30);
	v.wprot1.addr   := apbi.pwdata(29 downto 15);
	v.wprot1.mask   := apbi.pwdata(14 downto 0);
      when "0" => 
        v.wprot2.enable := apbi.pwdata(31);
	v.wprot2.ablock := apbi.pwdata(30);
	v.wprot2.addr   := apbi.pwdata(29 downto 15);
	v.wprot2.mask   := apbi.pwdata(14 downto 0);
      when others => null;
      end case;
    end if;

    if rst = '0' then
      v.wprot1.enable        := '0';
      v.wprot2.enable        := '0';
    end if;

    rin <= v;
    wpo.wprothit <= wprothit;

  end process;


  wpreggen : if WPROTEN generate 
    wpregs : process(clk)
    begin if rising_edge(clk) then r <= rin; end if; end process;
  end generate;

end;


