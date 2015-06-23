



----------------------------------------------------------------------------
--  This file is a part of the LEON-FT VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--  ALL RIGHTS RESERVED
--
--  This file is the property of ESA and may not be distributed
--  or used without the written authorisation of ESA.
--


LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.STD_LOGIC_ARITH.ALL; 
USE IEEE.STD_LOGIC_UNSIGNED."-"; 
USE IEEE.STD_LOGIC_UNSIGNED."+"; 
use work.amba.all;
use work.leon_iface.all;
 
entity pci_test is 
   port( 

      rst           : in std_logic;   
      clk           : in std_logic;   

      ahbmi 	: in  ahb_mst_in_type;
      ahbmo 	: out ahb_mst_out_type;
      ahbsi 	: in  ahb_slv_in_type;
      ahbso 	: out ahb_slv_out_type
);
          
end; 
 
architecture behav of pci_test is 

begin 

  slave : process (clk)
  variable mo : ahb_mst_out_type;
  variable so : ahb_slv_out_type;
  variable sst : natural := 0;
  variable mst : natural := 0;
  variable saddr, maddr : std_logic_vector(31 downto 0);
  variable mcount : std_logic_vector(9 downto 0);
  variable swrite, ssel, mstart, mwrite : std_logic;
  variable cnt : integer := 0;
  begin
   if clk = '1' then
    if ahbsi.hsel = '1' then 
      ssel := '1'; saddr := ahbsi.haddr; swrite := ahbsi.hwrite;
    else ssel := '0'; end if;
    if ssel = '1' then
      if swrite = '1' then
	case saddr(3 downto 2) is
        when "00" => maddr := ahbsi.hwdata;
        when "01" => mcount := ahbsi.hwdata(9 downto 0);
                     mstart := ahbsi.hwdata(12);
                     mwrite := ahbsi.hwdata(13);
        when others =>
        end case;
      else
	case saddr(3 downto 2) is
        when "00" =>
        when others =>
        end case;
      end if;
    end if;

    case mst is
    when 0 =>
      if mstart = '1' then
	mo.hbusreq := '1';
	if (ahbmi.hready and ahbmi.hgrant) = '1' then 
	  mst := 1; mo.htrans := HTRANS_NONSEQ;
        end if;
      end if;
    when 1 =>
      if ahbmi.hready = '1' then 
	mcount := mcount -1; maddr := maddr + 4;
        if mcount /= "0000000000" then
          mo.htrans := HTRANS_SEQ;
        else
          mo.htrans := HTRANS_IDLE; mo.hbusreq := '0'; mst := 0; mstart := '0';
	  mst := 2; mo.htrans := HTRANS_BUSY; cnt := 20;
        end if;
      end if;
    when 2 =>
      if ahbmi.hready = '1' then 
        mo.htrans := HTRANS_IDLE;
	mst := 0;
	cnt := cnt -1;
	if cnt = 0 then mst := 3; end if;
--        if mcount /= "0000000000" then
--          mo.htrans := HTRANS_SEQ;
--        else
--          mo.htrans := HTRANS_IDLE; mo.hbusreq := '0'; mst := 0; mstart := '0';
--        end if;
      end if;
    when 3 =>
      if ahbmi.hready = '1' then 
	mst := 1;
        if mcount /= "0000000000" then
          mo.htrans := HTRANS_SEQ;
        else
          mo.htrans := HTRANS_IDLE; mo.hbusreq := '0'; mst := 0; mstart := '0';
        end if;
      end if;
    when others =>
    end case;

    mo.hwdata := maddr;
    mo.haddr := maddr; mo.hwrite := mwrite;

    if rst = '0' then
      sst := 0; mst := 0;
      so.hrdata := (others => '0'); so.hready := '1';
      so.hresp  := (others => '0'); so.hsplit := (others => '0');
      mo.hbusreq := '0'; mo.hlock := '0'; mo.htrans := HTRANS_IDLE;
      mo.haddr := (others => '0'); mo.hwrite := '0'; mo.hburst := HBURST_INCR;
      mo.hprot := (others => '0'); mo.hwdata := (others => '0');
      mo.hsize := "010";

      mstart := '0'; maddr := (others => '0'); maddr(30) := '1';
      mwrite := '0'; mcount := "0000000000";
    end if;
    ahbso <= so; ahbmo <= mo;
   end if;
  end process;

end; 
