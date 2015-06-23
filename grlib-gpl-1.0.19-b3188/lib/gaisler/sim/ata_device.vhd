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
-- Entity: ata_device 
-- File: ata_device.vhd
-- Author: Erik Jagres, Gaisler Research
-- Description: Simulation of ATA device
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library gaisler;
use gaisler.sim.all;

--************************ENTITY************************************************

Entity ata_device is
generic(sector_length: integer :=512; --in bytes
        disk_size: integer :=32; --in sectors
        log2_size : integer :=14; --Log2(sector_length*disk_size), abits
        Tlr : time := 35 ns
        );
port(
  --for convinience, not part of ATA interface
  clk   : in std_logic;
  rst   : in std_logic;
  
  --interface to host bus adapter
  d   	: inout std_logic_vector(15 downto 0) := (others=>'Z');
  atai  : in  ata_in_type := ATAI_RESET_VECTOR;
  atao  : out ata_out_type:= ATAO_RESET_VECTOR);
end;

--************************ARCHITECTURE******************************************
Architecture behaveioral of ata_device is

type mem_reg_type is record
  a  : std_logic_vector(9 downto 0);    --word adress
  d  : std_logic_vector(15 downto 0);   --data
  lb : std_logic;                       --low byte access (active low)
  ub : std_logic;                       --upper byte access (active low)
  ce : std_logic;                       --chip enable (active low)
  we : std_logic;                       --write enable (active low)
  oe : std_logic;                       --output enable (active low)
end record;

constant MEM_RESET_VECTOR : mem_reg_type := ((others=>'0'),
  (others=>'0'),'1','1','1','1','1');

constant CS1 : integer := 4;
constant CS0 : integer := 3;

--status bits
constant BSY : integer := 7;
constant DRQ : integer := 3;

--control bits
constant NIEN : integer := 1;

--commands
constant READ : std_logic_vector(7 downto 0):=X"20";
constant WRITE : std_logic_vector(7 downto 0):=X"30";
constant WRITE_DMA : std_logic_vector(7 downto 0):=X"CA";
constant READ_DMA : std_logic_vector(7 downto 0):=X"C8";

constant  ALTSTAT : std_logic_vector(4 downto 0):="10110";
constant  CMD     : std_logic_vector(4 downto 0):="01111";
constant  CHR     : std_logic_vector(4 downto 0):="01101";
constant  CLR     : std_logic_vector(4 downto 0):="01100";
constant  DTAR    : std_logic_vector(4 downto 0):="01000";
constant  DTAP    : std_logic_vector(4 downto 0):="00000"; --only CSx used
constant  CTRL    : std_logic_vector(4 downto 0):="10110";
constant  DHR     : std_logic_vector(4 downto 0):="01110";
constant  ERR     : std_logic_vector(4 downto 0):="01001"; --read only
constant  FEAT    : std_logic_vector(4 downto 0):=ERR; --write only
constant  SCR     : std_logic_vector(4 downto 0):="01010";
constant  SNR     : std_logic_vector(4 downto 0):="01011";
constant  STAT    : std_logic_vector(4 downto 0):="01111";

constant sramfile  : string := "disk.srec";  -- ram contents
constant w_adr: integer := log2(sector_length)-1; --word adress bits (within sector)

type ram_type is record
  a : std_logic_vector(log2_size-2 downto 0);
  ce : std_logic;
  we : std_ulogic;
  oe : std_ulogic;
end record;

constant RAM_RESET_VECTOR : ram_type := ((others=>'0'),'0','0','0');

type ata_reg_type is record 			--ATA task file
  altstat : std_logic_vector(7 downto 0);	--Alternate Status register
  cmd     : std_logic_vector(7 downto 0);	--Command register
  chr     : std_logic_vector(7 downto 0);	--Cylinder High register
  clr     : std_logic_vector(7 downto 0);	--Cylinder Low register
  dtar    : std_logic_vector(15 downto 0);	--Data register
  dtap    : std_logic_vector(15 downto 0);	--Data port
  ctrl    : std_logic_vector(7 downto 0);	--Device Control register
  dhr     : std_logic_vector(7 downto 0);	--Device/Head register
  err     : std_logic_vector(7 downto 0);	--Error register
  feat    : std_logic_vector(7 downto 0);	--Features register
  scr     : std_logic_vector(7 downto 0);	--Sector Count register
  snr     : std_logic_vector(7 downto 0);	--Sector Number register
  stat    : std_logic_vector(7 downto 0);	--Status register
end record;

constant ATA_RESET_VECTOR : ata_reg_type := ((others=>'0'),
  (others=>'0'),(others=>'0'),
  (others=>'0'),(others=>'0'),
  (others=>'0'),(others=>'0'),
  (others=>'0'),(others=>'0'),
  (others=>'0'),(others=>'0'),
  (others=>'0'),(others=>'0'));

type reg_type is record
  cmd_started : boolean;
  dtap_written : boolean;
  dtar_written : boolean;
  dtap_read : boolean;
  dtar_read : boolean;
  firstadr : boolean;
  dior : std_logic;
  diow : std_logic;
  regadr : std_logic_vector(4 downto 0);
  byte_cnt : integer;
  offset : integer;
  intrq : boolean;
  pio_started : boolean;
  tf : ata_reg_type;
  ram : ram_type;
  ram_dta : std_logic_vector(15 downto 0);
  scr : std_logic_vector(7 downto 0);
end record;

constant REG_RESET_VECTOR : reg_type := (false,false,false,false,false,true,
  '1','1',(others=>'0'),0,0,false,false,ATA_RESET_VECTOR,RAM_RESET_VECTOR,
  (others=>'0'),(others=>'0'));

signal r,ri : reg_type := REG_RESET_VECTOR;
signal s_d : std_logic_vector(15 downto 0) := (others=>'0'); 

begin
  comb: process(atai,r,s_d,rst)
  variable v : reg_type:= REG_RESET_VECTOR;
  begin
    if (rst='0') then
      v:=REG_RESET_VECTOR;
      d<=(others=>'Z');
      atao.intrq<='0';
      atao.dmarq<='0';
    else
      v:=r;

      v.dior:=atai.dior; v.diow:=atai.diow;

      v.regadr(CS1):=not(atai.cs(1)); v.regadr(CS0):=not(atai.cs(0)); --CS active l
      v.regadr(2 downto 0):=atai.da(2 downto 0);

      --fix for adressing dtap
      if (v.regadr(4 downto 3)="00") then
        v.regadr(2 downto 0):="000";
      end if;

      --*********************************READ/WRITE registers*****************
      if (atai.dior='1' and atai.diow='1' and r.diow='0') then --write register
	case v.regadr is
	  when CMD     => v.tf.cmd:=d(7 downto 0);
            v.cmd_started:=true;
            v.tf.stat(BSY):='1';
            v.tf.feat:="00001111";
            v.byte_cnt:=0;
            atao.dmarq<='0'; -----------------------------------erik 2006-10-17
	  when CHR     => v.tf.chr:=d(7 downto 0);
	  when CLR     => v.tf.clr:=d(7 downto 0);
	  when DTAR    => v.tf.dtar:=d(15 downto 0);
            v.dtar_written:=true;
	  when CTRL    => v.tf.ctrl:=d(7 downto 0);
	  when DHR     => v.tf.dhr:=d(7 downto 0);
	  when FEAT    => v.tf.feat:=d(7 downto 0);
	  when SCR     => v.tf.scr:=d(7 downto 0); v.scr:=d(7 downto 0); 
	  when SNR     => v.tf.snr:=d(7 downto 0);
	  when DTAP    => v.tf.dtap:=d(15 downto 0);
            v.dtap_written:=true;
	  when others => v.tf.stat:=d(7 downto 0);
	end case;

      elsif (atai.dior='0' and r.dior='1' and atai.diow='1') then --read register
	case v.regadr is
	  when ALTSTAT => d(7 downto 0)<=r.tf.altstat; d(15 downto 8)<="00000000";
	  when CHR     => d(7 downto 0)<=r.tf.chr; d(15 downto 8)<="00000000";
	  when CLR     => d(7 downto 0)<=r.tf.clr; d(15 downto 8)<="00000000";
	  when DTAR    => d<=r.tf.dtar; v.dtar_read:=true;
	  when DHR     => d(7 downto 0)<=r.tf.dhr; d(15 downto 8)<="00000000";
	  when ERR     => d(7 downto 0)<=r.tf.err; d(15 downto 8)<="00000000";
	  when SCR     => d(7 downto 0)<=r.tf.scr; d(15 downto 8)<="00000000";
	  when SNR     => d(7 downto 0)<=r.tf.snr; d(15 downto 8)<="00000000";
	  when STAT    => d(7 downto 0)<=r.tf.stat; d(15 downto 8)<="00000000";
    	    atao.intrq<='0'; v.intrq:=false;
	  when DTAP    => 
            d<=r.tf.dtap; v.dtap_read:=true;
            if (v.byte_cnt+2=sector_length) then
              atao.dmarq<='0' after Tlr; 
            end if;

	  when others => d(15 downto 0)<=(others=>'Z');
	end case;
        --*********************************READ/WRITE registers end*************

      else

  	if (r.tf.stat(BSY)='1') then	    --simulate busy, "borrow" feat reg
	  v.tf.feat:=v.tf.feat-1;   	    --count down timer
	  if (v.tf.feat="00000000") then
	    v.tf.stat(BSY):='0'; 	    --clear busy flag
          end if;
        elsif(v.cmd_started) then
	  case r.tf.cmd is
            --********************************************************************
	    when WRITE_DMA =>
              atao.dmarq<='1';
              v.tf.stat(DRQ):='1';
              if v.dtap_written then
                v.dtap_written:=false;
                v.byte_cnt:=v.byte_cnt+2;
                if(v.byte_cnt=sector_length) then
                  v.tf.scr:=v.tf.scr-1;
                  v.byte_cnt:=0;
                  if v.tf.scr=X"00" then
                    atao.dmarq<='0';
                    v.tf.stat(DRQ):='0';
                    v.cmd_started:=false;
                    if v.tf.ctrl(NIEN)='0' then
                      atao.intrq<='1';
                    end if;
                  end if;
                end if;
                if r.dtap_written then
                  v.ram.a(log2_size-2 downto log2(sector_length)-1):=
                  r.scr((log2_size-log2(sector_length)-1) downto 0) - r.tf.scr((log2_size-log2(sector_length)-1) downto 0);
                  v.ram.a(log2(sector_length)-2 downto 0):= 
                  conv_std_logic_vector((r.byte_cnt/2),log2(sector_length)-1);
                  v.ram_dta:=v.tf.dtap; v.ram.oe:='1'; v.ram.ce:='0';v.ram.we:='0';
                end if;
              end if;
            --********************************************************************            
	    when WRITE     =>
              if (not v.pio_started and v.tf.ctrl(NIEN)='0') then
                atao.intrq<='1'; v.pio_started:=true; v.intrq:=true;
              elsif not v.intrq then
                v.tf.stat(DRQ):='1';
                if v.dtar_written then
                  v.dtar_written:=false;
                  v.byte_cnt:=v.byte_cnt+2;
                  if(v.byte_cnt=sector_length) then
                    v.tf.scr:=v.tf.scr-1;
                    if (v.tf.scr=X"00") then
                      v.cmd_started:=false; v.pio_started:=false;
                    end if;
                    v.byte_cnt:=0;
                    v.tf.stat(DRQ):='0';
                    v.tf.stat(BSY):='1';
                    v.tf.feat:="00001111";
                    if v.tf.ctrl(NIEN)='0' then
                      atao.intrq<='1';
                    end if;
                  end if;
                end if;
                if r.dtar_written then
                  v.ram.a(log2_size-2 downto log2(sector_length)-1):=
                  r.scr((log2_size-log2(sector_length)-1) downto 0) - r.tf.scr((log2_size-log2(sector_length)-1) downto 0);
                  v.ram.a(log2(sector_length)-2 downto 0):= 
                  conv_std_logic_vector((r.byte_cnt/2),log2(sector_length)-1);
                  v.ram_dta:=v.tf.dtar; v.ram.oe:='1'; v.ram.ce:='0';v.ram.we:='0';
                end if;
              end if;
            --********************************************************************
	    when READ_DMA  =>
--              atao.dmarq<='1';
              v.tf.stat(DRQ):='1';
              if not (v.byte_cnt+2=sector_length) then
                atao.dmarq<='1';
              end if;
              if v.dtap_read and r.dior='0' and atai.dior='1' then --rising dior detect
                v.dtap_read:=false;
                v.byte_cnt:=v.byte_cnt+2;
                if(v.byte_cnt=sector_length) then
                  v.tf.scr:=v.tf.scr-1;
                  v.byte_cnt:=0;
                  if v.tf.scr=X"00" then
--                    atao.dmarq<='0';
                    v.tf.stat(DRQ):='0';
                    v.cmd_started:=false;
                      v.ram.oe:='1'; v.ram.ce:='1';v.ram.we:='1';
                    if v.tf.ctrl(NIEN)='0' then
                      atao.intrq<='1';
                    end if;
                  end if;
                end if;
              end if;
              v.ram.oe:='0'; v.ram.ce:='0';v.ram.we:='1'; v.tf.dtap:=s_d;
                  v.ram.a(log2_size-2 downto log2(sector_length)-1):=
                  r.scr((log2_size-log2(sector_length)-1) downto 0) - r.tf.scr((log2_size-log2(sector_length)-1) downto 0);
                  v.ram.a(log2(sector_length)-2 downto 0):= 
                  conv_std_logic_vector((r.byte_cnt/2),log2(sector_length)-1);
            --********************************************************************
	    when READ =>
              if (not v.pio_started and v.tf.ctrl(NIEN)='0') then
                atao.intrq<='1'; v.pio_started:=true; v.intrq:=true;
              elsif not v.intrq then
                v.tf.stat(DRQ):='1';
                if v.dtar_read and r.dior='0' and atai.dior='1' then --rising dior detect
                  v.dtar_read:=false;
                  v.byte_cnt:=v.byte_cnt+2;
                  if(v.byte_cnt=sector_length) then
                    v.tf.scr:=v.tf.scr-1;
                    if (v.tf.scr=X"00") then
                      v.cmd_started:=false;
                    end if;
                    v.byte_cnt:=0;
                    v.tf.stat(DRQ):='0';
                    v.tf.stat(BSY):='1';
                    v.tf.feat:="00001111";
                    if v.tf.ctrl(NIEN)='0' then
                      atao.intrq<='1';
                    end if;
                  end if;
                end if;
              end if;
              v.ram.oe:='0'; v.ram.ce:='0';v.ram.we:='1'; v.tf.dtar:=s_d;
                  v.ram.a(log2_size-2 downto log2(sector_length)-1):=
                  r.scr((log2_size-log2(sector_length)-1) downto 0) - r.tf.scr((log2_size-log2(sector_length)-1) downto 0);
                  v.ram.a(log2(sector_length)-2 downto 0):= 
                  conv_std_logic_vector((r.byte_cnt/2),log2(sector_length)-1);
            --********************************************************************
	    when others => v.tf.stat:=v.tf.stat; v.cmd_started:=false;
	  end case;
        end if;

        if r.ram.ce='0' and r.ram.oe='1' then
          v.ram.oe:='1'; v.ram.ce:='1';v.ram.we:='1'; v.ram_dta:=(others=>'Z');
        end if;

        if (r.dior='0' and atai.dior='1') then
          d(15 downto 0)<=(others=>'Z');
        end if;

      end if; --read write reg
    end if; --reset

    ri<=v;
  end process comb;

  with r.ram.oe select
    s_d<=r.ram_dta when '1',
         (others=>'Z') when others;

  disk : sram16 generic map (index => 0, abits => log2_size-1, fname => sramfile)
	port map (r.ram.a, s_d, '0', '0', r.ram.ce, r.ram.we, r.ram.oe);

  --**********************SYNC PROCESS******************************************
  sync: process(clk) --dior/diow insted?
  begin
    if rising_edge(clk) then
      r<=ri;
    end if;
  end process sync;
end;

--************************END OF FILE*******************************************
