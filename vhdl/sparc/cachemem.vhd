



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 2003  Gaisler Research
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	cachemem
-- File:	cachemem.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Contains ram cells for both instruction and data caches
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_target.all;
use work.leon_config.all;
use work.mmuconfig.all;
use work.leon_iface.all;
use work.macro.all;
use work.tech_map.all;

entity cachemem is
  port (
        clk   : in  clk_type;
	crami : in  cram_in_type;
	cramo : out cram_out_type
  );
end;

architecture rtl of cachemem is

  constant ITDEPTH : natural := 2**IOFFSET_BITS;
  constant DTDEPTH : natural := 2**DOFFSET_BITS;

  -- i/d tag layout
  -- +-----+----------+--------+-----+-------+
  -- | LRR | LOCK_BIT | MMUCTX | TAG | VALID |
  -- +-----+----------+--------+-----+-------+

  constant ITWIDTH : natural := ITAG_BITS + ILRR_BIT + ICLOCK_BIT + MMUCTX_BITS;
  constant DTWIDTH : natural := DTAG_BITS + DLRR_BIT + DCLOCK_BIT + MMUCTX_BITS;
  constant IDWIDTH : natural := 32;
  constant DDWIDTH : natural := 32;

  subtype dtdatain_vector is std_logic_vector(DTWIDTH downto 0);
  type dtdatain_type is array (0 to MAXSETS-1) of dtdatain_vector;
  subtype itdatain_vector is std_logic_vector(ITWIDTH downto 0);
  type itdatain_type is array (0 to MAXSETS-1) of itdatain_vector;
  
  subtype itdataout_vector is std_logic_vector(ITWIDTH downto 0);
  type itdataout_type is array (0 to MAXSETS-1) of itdataout_vector;
  subtype iddataout_vector is std_logic_vector(IDWIDTH -1 downto 0);
  type iddataout_type is array (0 to MAXSETS-1) of iddataout_vector;
  subtype dtdataout_vector is std_logic_vector(DTWIDTH downto 0);
  type dtdataout_type is array (0 to MAXSETS-1) of dtdataout_vector;
  subtype dddataout_vector is std_logic_vector(DDWIDTH -1 downto 0);
  type dddataout_type is array (0 to MAXSETS-1) of dddataout_vector;
  

  signal itaddr    : std_logic_vector(IOFFSET_BITS + ILINE_BITS -1 downto ILINE_BITS);
  signal idaddr    : std_logic_vector(IOFFSET_BITS + ILINE_BITS -1 downto 0);


  --signal itdatain  : std_logic_vector(ITWIDTH -1 downto 0);
  signal itdatain  : itdatain_type; 
  signal itdataout : itdataout_type;
  signal iddatain  : std_logic_vector(IDWIDTH -1 downto 0);
  signal iddataout : iddataout_type;

  signal itenable  : std_logic;
  signal idenable  : std_logic;
  signal itwrite   : std_logic_vector(0 to MAXSETS-1);
  signal idwrite   : std_logic_vector(0 to MAXSETS-1);

  signal dtaddr    : std_logic_vector(DOFFSET_BITS + DLINE_BITS -1 downto DLINE_BITS);
  signal dtaddr2   : std_logic_vector(DOFFSET_BITS + DLINE_BITS -1 downto DLINE_BITS);
  signal ddaddr    : std_logic_vector(DOFFSET_BITS + DLINE_BITS -1 downto 0);

  --signal dtdatain  : std_logic_vector(DTWIDTH -1 downto 0);
  signal dtdatain  : dtdatain_type; 
--  signal dtdatain2 : std_logic_vector(DTWIDTH -1 downto 0);
  signal dtdatain2 : dtdatain_type;
  signal dtdataout : dtdataout_type;
  signal dtdataout2: dtdataout_type;
  signal dddatain  : std_logic_vector(DDWIDTH -1 downto 0);
  signal dddataout : dddataout_type;
  signal ldataout  : std_logic_vector(31 downto 0);

  signal dtenable  : std_logic;
  signal dtenable2 : std_logic;
  signal ddenable  : std_logic;
  signal dtwrite   : std_logic_vector(0 to MAXSETS-1);
  signal dtwrite2  : std_logic_vector(0 to MAXSETS-1);
  signal ddwrite   : std_logic_vector(0 to MAXSETS-1);

  signal vcc, gnd  : std_logic;

begin

  vcc <= '1'; gnd <= '0'; 
  itaddr <= crami.icramin.idramin.address(IOFFSET_BITS + ILINE_BITS -1 downto ILINE_BITS);
  idaddr <= crami.icramin.idramin.address;


  itinsel : process(crami, dtdataout2)

  variable viddatain  : std_logic_vector(IDWIDTH -1 downto 0);
  variable vdddatain  : std_logic_vector(DDWIDTH -1 downto 0);
  variable vitdatain : itdatain_type;
  variable vdtdatain : dtdatain_type;
  variable vdtdatain2 : dtdatain_type;
  begin
    viddatain := (others => '0');
    vdddatain := (others => '0');

    viddatain(31 downto 0) := crami.icramin.idramin.data;

    for i in 0 to DSETS-1 loop
      vdtdatain(i) := (others => '0');
      if M_EN then
        vdtdatain(i)((DTWIDTH - (DLRR_BIT+DCLOCK_BIT+1)) downto (DTWIDTH - (DLRR_BIT+DCLOCK_BIT+M_CTX_SZ))) := crami.dcramin.dtramin.ctx;
      end if;
      vdtdatain(i)(DTWIDTH-(DLRR_BIT + DCLOCK_BIT)) := crami.dcramin.dtramin.lrr(i);
      vdtdatain(i)(DTWIDTH-DCLOCK_BIT) := crami.dcramin.dtramin.lock(i);          
      vdtdatain(i)(DTAG_BITS-1 downto 0) := crami.dcramin.dtramin.tag & crami.dcramin.dtramin.valid;
      if (DSETS > 1) and (crami.dcramin.dtramin.flush = '1') then
	vdtdatain(i)(DLINE_SIZE+1 downto DLINE_SIZE) :=  std_logic_vector(conv_unsigned(i,2));
      end if;
    end loop;

    vdtdatain2 := (others => (others => '0'));
    for i in 0 to DSETS-1 loop

      vdtdatain2(i)(DTWIDTH-(DLRR_BIT + DCLOCK_BIT)) := dtdataout2(i)(DTWIDTH-(DLRR_BIT+DCLOCK_BIT));
      vdtdatain2(i)(DTWIDTH-DCLOCK_BIT) := dtdataout2(i)(DTWIDTH-DCLOCK_BIT);
      vdtdatain2(i)(DTAG_BITS-1 downto DLINE_SIZE) := crami.dcramin.dtraminsn.tag;
    end loop;
    vdddatain(32 - 1 downto 0) := crami.dcramin.ddramin.data;


    for i in 0 to ISETS-1 loop
      vitdatain(i) := (others => '0');
      if M_EN then
        vitdatain(i)((ITWIDTH - (ILRR_BIT+ICLOCK_BIT+1)) downto (ITWIDTH - (ILRR_BIT+ICLOCK_BIT+M_CTX_SZ))) := crami.icramin.itramin.ctx;
      end if;
      vitdatain(i)(ITWIDTH-(ILRR_BIT + ICLOCK_BIT)) := crami.icramin.itramin.lrr;
      vitdatain(i)(ITWIDTH-ICLOCK_BIT) := crami.icramin.itramin.lock;
      vitdatain(i)(ITAG_BITS-1 downto 0) := crami.icramin.itramin.tag & crami.icramin.itramin.valid;
      if (ISETS > 1) and (crami.icramin.itramin.flush = '1') then
	vitdatain(i)(ILINE_SIZE+1 downto ILINE_SIZE) :=  std_logic_vector(conv_unsigned(i,2));
      end if;
    end loop;

    itdatain <= vitdatain; iddatain <= viddatain;
    dtdatain <= vdtdatain; dtdatain2 <= vdtdatain2; dddatain <= vdddatain;

  end process;

  
  itwrite   <= crami.icramin.itramin.write;
  idwrite   <= crami.icramin.idramin.write;
  itenable  <= crami.icramin.itramin.enable;
  idenable  <= crami.icramin.idramin.enable;

  dtaddr <= crami.dcramin.ddramin.address(DOFFSET_BITS + DLINE_BITS -1 downto DLINE_BITS);
  dtaddr2 <= crami.dcramin.dtraminsn.address;
  ddaddr <= crami.dcramin.ddramin.address;
  dtwrite   <= crami.dcramin.dtramin.write;
  dtwrite2  <= crami.dcramin.dtraminsn.write;
  ddwrite   <= crami.dcramin.ddramin.write;
  dtenable  <= crami.dcramin.dtramin.enable;
  dtenable2 <= crami.dcramin.dtraminsn.enable;
  ddenable  <= crami.dcramin.ddramin.enable;


  it0 : for i in 0 to ISETS-1 generate
    itags0 : syncram
      generic map ( dbits => ITWIDTH, abits => IOFFSET_BITS)
      port map ( itaddr, clk, itdatain(i)(ITWIDTH-1 downto 0), itdataout(i)(ITWIDTH-1 downto 0), itenable, itwrite(i));
  end generate;

  dtags0 : if not DSNOOP generate
    dt0 : for i in 0 to DSETS-1 generate
      dtags0 : syncram
      generic map ( dbits => DTWIDTH, abits => DOFFSET_BITS)
      port map ( dtaddr, clk, dtdatain(i)(DTWIDTH-1 downto 0), dtdataout(i)(DTWIDTH-1 downto 0), dtenable, dtwrite(i));
    end generate;
  end generate;

  dtags1 : if DSNOOP generate
    dt0 : for i in 0 to DSETS-1 generate
      dtags0 : dpsyncram
      generic map ( dbits => DTWIDTH, abits => DOFFSET_BITS)
      port map ( dtaddr, clk, dtdatain(i)(DTWIDTH-1 downto 0), dtdataout(i)(DTWIDTH-1 downto 0), dtenable, dtwrite(i),
                 dtaddr2, dtdatain2(i)(DTWIDTH-1 downto 0), dtdataout2(i)(DTWIDTH-1 downto 0), dtenable2, dtwrite2(i));
    end generate;
  end generate;

  id0 : for i in 0 to ISETS-1 generate
    idata0 : syncram
      generic map ( dbits => IDWIDTH, abits => IOFFSET_BITS+ILINE_BITS)
      port map ( idaddr, clk, iddatain, iddataout(i), idenable, idwrite(i));
  end generate;

  dd0 : for i in 0 to DSETS-1 generate
    ddata0 : syncram
     generic map ( dbits => DDWIDTH, abits => DOFFSET_BITS+DLINE_BITS)
      port map ( ddaddr, clk, dddatain, dddataout(i), ddenable, ddwrite(i));
  end generate;

  ld0 : if LOCAL_RAM generate
    ldata0 : syncram
     generic map ( dbits => 32, abits => LOCAL_RAM_BITS)
      port map ( crami.dcramin.ldramin.address, clk, dddatain, ldataout, 
		crami.dcramin.ldramin.enable, crami.dcramin.ldramin.write);
  end generate;

  itx : for i in 0 to ISETS-1 generate
    itdataout(i)(ITWIDTH) <= '0';
    cramo.icramout.itramout(i).valid <= itdataout(i)(ILINE_SIZE -1 downto 0);
    cramo.icramout.itramout(i).tag <= itdataout(i)(ITAG_BITS-1 downto ILINE_SIZE);
    cramo.icramout.itramout(i).lrr <= itdataout(i)(ITWIDTH - (ILRR_BIT+ICLOCK_BIT));
    cramo.icramout.itramout(i).lock <= itdataout(i)(ITWIDTH-ICLOCK_BIT);     
    cramo.icramout.itramout(i).ctx <= itdataout(i)((ITWIDTH - (ILRR_BIT+ICLOCK_BIT+1)) downto (ITWIDTH - (ILRR_BIT+ICLOCK_BIT+M_CTX_SZ)));
    cramo.icramout.idramout(i).data <= iddataout(i)(31 downto 0);

  end generate;


  itd : for i in 0 to DSETS-1 generate
    dtdataout(i)(DTWIDTH) <= '0';
    dtdataout2(i)(DTWIDTH) <= '0';
    cramo.dcramout.dtramout(i).valid <= dtdataout(i)(DLINE_SIZE -1 downto 0);
    cramo.dcramout.dtramout(i).tag <= dtdataout(i)(DTAG_BITS-1 downto DLINE_SIZE);
    cramo.dcramout.dtramout(i).lrr <= dtdataout(i)(DTWIDTH-(DLRR_BIT+DCLOCK_BIT));
    cramo.dcramout.dtramout(i).lock <= dtdataout(i)(DTWIDTH-DCLOCK_BIT);
    cramo.dcramout.dtramout(i).ctx <= dtdataout(i)((DTWIDTH - (DLRR_BIT+DCLOCK_BIT+1)) downto (DTWIDTH - (DLRR_BIT+DCLOCK_BIT+M_CTX_SZ)));
    cramo.dcramout.dtramoutsn(i).tag <= dtdataout2(i)(DTAG_BITS-1 downto DLINE_SIZE);
    cramo.dcramout.ddramout(i).data <= ldataout when LOCAL_RAM and (crami.dcramin.ldramin.read = '1')
    else dddataout(i)(31 downto 0);

  end generate;

end ;

