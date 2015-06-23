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
-- Entity:      apbvga
-- File:        vga.vhd
-- Author:      Marcus Hellqvist
-- Description: VGA controller 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.misc.all;
use gaisler.charrom_package.all;

entity apbvga is
  generic(
    memtech     : integer := DEFMEMTECH;
    pindex      : integer := 0; 
    paddr       : integer := 0;
    pmask       : integer := 16#fff#
    );
  port( rst             : in std_ulogic;                        -- Global asynchronous reset
        clk             : in std_ulogic;                        -- Global clock
        vgaclk          : in std_ulogic;                        -- VGA clock
        apbi            : in apb_slv_in_type;
        apbo            : out apb_slv_out_type;
        vgao            : out apbvga_out_type
        );
end entity apbvga;

architecture rtl of apbvga is                                                      

type state_type is (s0,s1,s2);

 constant RAM_DEPTH     : integer := 12;
 constant RAM_DATA_BITS : integer := 8;
 constant MAX_FRAME     : std_logic_vector((RAM_DEPTH-1) downto 0):= X"B90";
 
type ram_out_type is record
 dataout2               : std_logic_vector((RAM_DATA_BITS -1) downto 0);
end record;

type vga_regs is record
 video_out      : std_logic_vector(23 downto 0);
 hsync          : std_ulogic;
 vsync          : std_ulogic;
 csync          : std_ulogic;
 hcnt           : std_logic_vector(9 downto 0);
 vcnt           : std_logic_vector(9 downto 0);
 blank          : std_ulogic;
 linecnt        : std_logic_vector(3 downto 0);
 h_video_on     : std_ulogic;
 v_video_on     : std_ulogic;
 pixel          : std_ulogic;
 state          : state_type; 
 rombit         : std_logic_vector(2 downto 0);
 romaddr        : std_logic_vector(11 downto 0);
 ramaddr2       : std_logic_vector((RAM_DEPTH -1) downto 0);
 ramdatain2     : std_logic_vector((RAM_DATA_BITS -1) downto 0);
 wstartaddr     : std_logic_vector((RAM_DEPTH-1) downto 0);
 raddr          : std_logic_vector((RAM_DEPTH-1) downto 0);
 tmp            : std_logic_vector(RAM_DEPTH-1 downto 0);
end record;

type color_reg_type is record
 bgcolor        : std_logic_vector(23 downto 0);
 txtcolor       : std_logic_vector(23 downto 0);
end record;

type vmmu_reg_type is record
 waddr          : std_logic_vector((RAM_DEPTH-1) downto 0);
 wstartaddr     : std_logic_vector((RAM_DEPTH-1) downto 0);
 ramaddr1       : std_logic_vector((RAM_DEPTH -1) downto 0);
 ramdatain1     : std_logic_vector((RAM_DATA_BITS -1) downto 0);
 ramenable1     : std_ulogic;
 ramwrite1      : std_ulogic;
 color          : color_reg_type;
end record;

constant REVISION       : amba_version_type := 0; 
constant pconfig        : apb_config_type := (
                        0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_VGACTRL, 0, REVISION, 0),
                        1 => apb_iobar(paddr, pmask));
constant hmax           : integer:= 799;
constant vmax           : integer:= 524;
constant hvideo         : integer:= 639;
constant vvideo         : integer:= 480;
constant hfporch        : integer:= 19;
constant vfporch        : integer:= 11;
constant hbporch        : integer:= 45;
constant vbporch        : integer:= 31;
constant hsyncpulse     : integer:= 96;
constant vsyncpulse     : integer:= 2;
constant char_height    : std_logic_vector(3 downto 0):="1100";

signal p,pin            : vmmu_reg_type;
signal ramo             : ram_out_type;
signal r,rin            : vga_regs;
signal romdata          : std_logic_vector(7 downto 0);
signal gnd, vcc         : std_ulogic;

begin

  gnd <= '0'; vcc <= '1';

  comb1: process(rst,r,p,romdata,ramo)
    variable v          : vga_regs;
  begin
    v:=r;
    v.wstartaddr := p.wstartaddr;

    -- horizontal counter
    if r.hcnt < conv_std_logic_vector(hmax,10) then
      v.hcnt := r.hcnt +1;
    else
      v.hcnt := (others => '0');
    end if;
    -- vertical counter
    if (r.vcnt >= conv_std_logic_vector(vmax,10)) and (r.hcnt >= conv_std_logic_vector(hmax,10)) then
      v.vcnt := (others => '0');
    elsif r.hcnt = conv_std_logic_vector(hmax,10) then
      v.vcnt := r.vcnt +1;
    end if;
    -- horizontal pixel out
    if r.hcnt <= conv_std_logic_vector(hvideo,10) then
      v.h_video_on := '1';
    else
      v.h_video_on := '0';
    end if;
    -- vertical pixel out
    if r.vcnt <= conv_std_logic_vector(vvideo,10) then
      v.v_video_on := '1';
    else
      v.v_video_on := '0';
    end if;
    -- generate hsync
    if (r.hcnt <= conv_std_logic_vector((hvideo+hfporch+hsyncpulse),10)) and 
      (r.hcnt >= conv_std_logic_vector((hvideo+hfporch),10)) then
      v.hsync := '0';
    else
      v.hsync := '1';
    end if; 
    -- generate vsync
    if (r.vcnt <= conv_std_logic_vector((vvideo+vfporch+vsyncpulse),10)) and 
      (r.vcnt >= conv_std_logic_vector((vvideo+vfporch),10)) then
      v.vsync := '0';
    else
      v.vsync := '1';
    end if;
    --generate csync & blank
    v.csync := not (v.hsync xor v.vsync);
    v.blank := v.h_video_on and v.v_video_on;

    -- count line of character
    if v.hcnt = conv_std_logic_vector(hvideo,10) then
      if (r.linecnt = char_height) or (v.vcnt = conv_std_logic_vector(vmax,10)) then
        v.linecnt := (others => '0');
      else
        v.linecnt := r.linecnt +1;
      end if;
    end if;
    
    if v.blank = '1' then
      case r.state is
        when s0 =>      v.ramaddr2 := r.raddr;
                        v.raddr := r.raddr +1;
                        v.state := s1;  
        when s1 =>      v.romaddr := v.linecnt & ramo.dataout2; 
                        v.state := s2;
        when s2 =>      if r.rombit = "011" then  
                          v.ramaddr2 := r.raddr;
                          v.raddr := r.raddr +1;
                        elsif r.rombit = "010" then 
                          v.state := s1;
                        end if;
      end case;
      v.rombit := r.rombit - 1;
      v.pixel := romdata(conv_integer(r.rombit));
    end if;

    -- read from same address char_height times
    if v.raddr = (r.tmp + X"050") then
      if (v.linecnt < char_height) then
        v.raddr := r.tmp;
      elsif v.raddr(11 downto 4) = X"FF" then       --check for end of allowed memory(80x51)
        v.raddr := (others => '0');
        v.tmp := (others => '0');
      else
        v.tmp := r.tmp + X"050";
      end if;
    end if;

    if  v.v_video_on = '0'      then
      v.raddr := r.wstartaddr;
      v.tmp := r.wstartaddr;
      v.state := s0;
    end if;
    
    -- define pixel color                                       
    if v.pixel = '1'and  v.blank = '1' then
      v.video_out := p.color.txtcolor;
    else 
      v.video_out := p.color.bgcolor;
    end if;
    
    if rst = '0' then
      v.hcnt := conv_std_logic_Vector(hmax,10);
      v.vcnt := conv_std_logic_Vector(vmax,10);
      v.v_video_on := '0';
      v.h_video_on := '0';
      v.hsync := '0';
      v.vsync := '0';
      v.csync := '0';
      v.blank := '0';
      v.linecnt := (others => '0');
      v.state := s0;
      v.rombit := "111";
      v.pixel := '0';
      v.video_out := (others => '0');
      v.raddr := (others => '0');
      v.tmp := (others => '0');
      v.ramaddr2 := (others => '0');
      v.ramdatain2 := (others => '0');
    end if;
        
    -- update register  
    rin <= v;
    
    -- drive outputs
    vgao.hsync <= r.hsync;
    vgao.vsync <= r.vsync;
    vgao.comp_sync <= r.csync;
    vgao.blank <= r.blank;   
    vgao.video_out_r <= r.video_out(23 downto 16);
    vgao.video_out_g <= r.video_out(15 downto 8);
    vgao.video_out_b <= r.video_out(7 downto 0);
  end process;

        
  comb2: process(rst,r,p,apbi,ramo)
    variable v          : vmmu_reg_type;
    variable rdata : std_logic_vector(31 downto 0);     
  begin
    v := p;
    v.ramenable1 := '0'; v.ramwrite1 := '0';
    rdata := (others => '0'); 
    
    case apbi.paddr(3 downto 2) is
      when "00" =>      if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
                           v.waddr := apbi.pwdata(19 downto 8);
                           v.ramdatain1 :=      apbi.pwdata(7 downto 0);
                           v.ramenable1 := '1';
                           v.ramwrite1  := '1';
                           v.ramaddr1 := apbi.pwdata(19 downto 8);
                         end if;        
      when "01" =>      if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
                          v.color.bgcolor := apbi.pwdata(23 downto 0);
                        end if;
      when "10" =>      if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
                          v.color.txtcolor := apbi.pwdata(23 downto 0);
                        end if;
      when others =>    null;
    end case;

    if (p.waddr - p.wstartaddr) >= MAX_FRAME then               
      if p.wstartaddr(11 downto 4) = X"FA" then    --last position of allowed memory
        v.wstartaddr := X"000"; 
      else
        v.wstartaddr := p.wstartaddr + X"050";  
      end if;
    end if;
        
    if rst = '0' then
      v.waddr    := (others => '0');
      v.wstartaddr  := (others => '0');                 
      v.color.bgcolor := (others => '0');
      v.color.txtcolor := (others => '1');
    end if;

    --update registers
    pin <= v;
    
    --drive outputs
    apbo.prdata <= rdata;
    apbo.pindex <= pindex;
    apbo.pirq <= (others => '0');
  end process;
  
  apbo.pconfig <= pconfig;
  
  reg : process(clk)
  begin
    if clk'event and clk = '1' then
      p <= pin; 
    end if;
  end process;
  
  reg2 : process(vgaclk)
  begin
    if vgaclk'event and vgaclk = '1' then
      r <= rin;
    end if;
  end process;
  
  rom0 : charrom port map(clk=>vgaclk, addr=>r.romaddr, data=>romdata);
  ram0 : syncram_2p generic map (tech => memtech, abits => RAM_DEPTH, 
                                 dbits => RAM_DATA_BITS, sepclk => 1)
    port map (
      rclk => vgaclk, raddress => r.ramaddr2, dataout => ramo.dataout2, renable => vcc,
      wclk => clk, waddress => p.ramaddr1, datain => p.ramdatain1, write => p.ramwrite1 
   );
--  ram0 : syncram_dp generic map (tech => memtech, abits => RAM_DEPTH, dbits => RAM_DATA_BITS)
--    port map ( clk1 => clk, address1 => p.ramaddr1, datain1 => p.ramdatain1, 
--	dataout1 => open, enable1 => p.ramenable1, write1 => p.ramwrite1, 
--	clk2 => vgaclk, address2 => r.ramaddr2, datain2 => r.ramdatain2, 
--	dataout2 => ramo.dataout2, enable2 => gnd, write2 => gnd);
-- pragma translate_off
    bootmsg : report_version 
    generic map ("apbvga" & tost(pindex) & ": APB VGA module rev 0");
-- pragma translate_on

end architecture;
