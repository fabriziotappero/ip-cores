



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
-- Entity:      apbmst
-- File:        apbmst.vhd
-- Author:      Jiri Gaisler - ESA/ESTEC
-- Description: AMBA AHB/APB bridge
------------------------------------------------------------------------------ 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.amba.all;


entity apbmst is
  port (
    rst     : in  std_logic;
    clk     : in  std_logic;
    ahbi    : in  ahb_slv_in_type;
    ahbo    : out ahb_slv_out_type;
    apbi    : out apb_slv_in_vector(0 to APB_SLV_MAX-1);
    apbo    : in  apb_slv_out_vector(0 to APB_SLV_MAX-1)
  );
end;

architecture rtl of apbmst is

-- registers
type reg_type is record
  haddr   : std_logic_vector(APB_SLV_ADDR_BITS -1 downto 2);   -- address bus
  hsel    : std_logic;
  hwrite  : std_logic;  		     -- read/write
  hready  : std_logic;  		     -- ready
  hready2 : std_logic;  		     -- ready
  penable : std_logic;
end record;

signal r, rin : reg_type;

constant apbmax : integer := APB_SLV_ADDR_BITS -1;
begin
  comb : process(ahbi, apbo, r, rst)
  variable v : reg_type;
  variable psel   : std_logic_vector(0 to APB_SLV_MAX-1);   
  variable prdata : std_logic_vector(31 downto 0);
  variable pwdata : std_logic_vector(31 downto 0);
  variable apbaddr : std_logic_vector(apbmax downto 2);
  variable apbaddr2 : std_logic_vector(31 downto 0);
  variable bindex : integer range 0 to APB_SLV_MAX-1;
  variable esel : std_logic;
  begin

    v := r; v.hready2 := '1';

    -- detect start of cycle
    if (ahbi.hready = '1') then
      if ((ahbi.htrans = HTRANS_NONSEQ) or (ahbi.htrans = HTRANS_SEQ)) and
	  (ahbi.hsel = '1')
      then
        v.hready := '0'; v.hwrite := ahbi.hwrite; v.hsel := '1';
	v.hwrite := ahbi.hwrite; v.hready2 := not ahbi.hwrite;
	v.haddr(apbmax downto 2)  := ahbi.haddr(apbmax downto 2); 
      else v.hsel := '0'; end if;
    end if;

    -- generate hready and penable
    if (r.hsel and r.hready2 and (not r.hready)) = '1' then 
      v.penable := '1'; v.hready := '1';
    else v.penable := '0'; end if;

    -- generate psel and select APB read data
    psel := (others => '0'); prdata := (others => '-');
    apbaddr := r.haddr(apbmax downto 2);
    bindex := 0; esel := '0';

   case apbaddr is
   -- memory controller, 0x00 - 0x08
   when "00000000" | "00000001" | "00000010" => 
     esel := '1'; bindex := 0;
   -- AHB status reg.,   0x0C - 0x10
   when "00000011" | "00000100" =>
     esel := '1'; bindex := 1;
   -- cache controller,  0x14 - 0x18
   when "00000101" | "00000110" =>
     esel := '1'; bindex := 2;
   -- write protection,  0x1C - 0x20
   when "00000111" | "00001000" =>
     if WPROTEN then esel := '1'; bindex := 3; end if;
   -- config register,   0x24 - 0x24
   when "00001001" =>
     if CFGREG then esel := '1'; bindex := 4; end if;
   -- timers,            0x40 - 0x6C
   when "00010000" | "00010001" | "00010010" | "00010011" |
        "00010100" | "00010101" | "00010110" | "00010111" |
        "00011000" | "00011001" | "00011010" | "00011011" => 
     esel := '1'; bindex := 5;
   -- uart1,             0x70 - 0x7C
   when "00011100" | "00011101" | "00011110" | "00011111" =>
     esel := '1'; bindex := 6;
   -- uart2,             0x80 - 0x8C
   when "00100000" | "00100001" | "00100010" | "00100011" =>
     esel := '1'; bindex := 7;
   -- interrupt ctrl     0x90 - 0x9C
   when "00100100" | "00100101" | "00100110" | "00100111" =>
     esel := '1'; bindex := 8;
   -- I/O port           0xA0 - 0xAC
   when "00101000" | "00101001" | "00101010" | "00101011" =>
     esel := '1'; bindex := 9;
   -- 2nd interrupt ctrl 0xB0 - 0xBC
   when "00101100" | "00101101" | "00101110" | "00101111" =>
     if IRQ2EN then esel := '1'; bindex := 10; end if;
   -- DSU uart           0xC0 - 0xCC
   when "00110000" | "00110001" | "00110010" | "00110011" =>
     if DEBUG_UNIT then esel := '1'; bindex := 11; end if;
   when others => 
     if PCIEN and ( r.haddr(apbmax downto apbmax-1) = "01") then
       esel := '1'; bindex := 12;
     end if;
     if PCIARBEN and ( r.haddr(apbmax downto apbmax-1) = "10") then
       esel := '1'; bindex := 13;
     end if;
   end case;

   prdata := apbo(bindex).prdata; psel(bindex) := esel;
--    for i in APB_TABLE'range loop	--'
--      if  APB_TABLE(i).enable and
--	 (apbaddr >= APB_TABLE(i).firstaddr(apbmax downto 2)) and
--         (apbaddr <= APB_TABLE(i).lastaddr(apbmax downto 2)) 
--      then 
--	prdata := apbo(APB_TABLE(i).index).prdata; 
--	psel(APB_TABLE(i).index) := '1';
--      end if;
--    end loop;

    -- AHB respons
    ahbo.hresp  <= HRESP_OKAY;
    ahbo.hready <= r.hready;
    ahbo.hrdata <= prdata;
    ahbo.hsplit <= (others => '0');

    if rst = '0' then
      v.penable := '0'; v.hready := '1'; v.hsel := '0';
-- pragma translate_off
      v.haddr := (others => '0');
-- pragma translate_on
    end if;

    rin <= v;

    -- tie write data to zero if not used to save power (not testable)
    if r.hsel = '1' then pwdata := ahbi.hwdata; 
    else pwdata := (others => '0'); end if;

    -- drive APB bus
    apbaddr2 := (others => '0');
    apbaddr2(apbmax downto 2)    := r.haddr(apbmax downto 2);
    for i in 0 to APB_SLV_MAX-1 loop
      apbi(i).paddr   <= apbaddr2;
      apbi(i).pwdata  <= pwdata;
      apbi(i).pwrite  <= r.hwrite;
      apbi(i).penable <= r.penable;
      apbi(i).psel    <= psel(i) and r.hsel and r.hready2;
    end loop;

  end process;


  reg : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;


end;

