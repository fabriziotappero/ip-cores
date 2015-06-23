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
-- Entity:      net
-- File:        net.vhd
-- Author:      Erik Jagre - Gaisler Research
-- Description: Generic FIFO, based on syncram in grlib
-----------------------------------------------------------------------------

--ATA controller, bus-master
--Erik Jagre 2006-10-04

Library ieee;
Use ieee.std_logic_1164.all;
use work.ata_inf.all;
Library gaisler;
Use gaisler.ata.all;
Library grlib;
Use grlib.stdlib.all;

--************************ENTITY************************************************
Entity atahost_ahbmst is
generic(fdepth: integer := 8);
Port(clk : in std_logic;
     rst : in std_logic; --active low
     i   : in bmi_type;
     o   : out bmo_type
  );
end;

--************************ARCHITECTURE******************************************
Architecture rtl of atahost_ahbmst is
constant abits : integer := Log2(fdepth);

type state_type is (IDLE,INIT,PREPARE,BURST_TO_ATA,BURST_TO_MEM,BURST_WAIT);

type reg_type is record
  state : state_type;
  o : bmo_type;
  adr_cnt : std_logic_vector(abits-1 downto 0);
  cur_base : std_logic_vector(31 downto 0);
  cur_length : std_logic_vector(15 downto 0);
  cur_cnt : std_logic_vector(15 downto 0);
  prdtb_offset : std_logic_vector(15 downto 0);
  edt : std_logic;
  bmen : std_logic;
  adr_set : std_logic;
end record;

constant RESET_VECTOR : reg_type := (IDLE, BMO_RESET_VECTOR, zero32(abits-1 downto 0),
  zero32, X"0000", X"0000", X"0000", '0', '0', '0');

signal r,ri : reg_type;
begin
  --**********************COMBINATORIAL LGOIC***********************************
  comb: process(rst,r,i)
  variable v : reg_type;
  variable v_diff : std_logic_vector(15 downto 0);
  variable v_temp : std_logic_vector(31 downto 0);
  begin
    v:=r;
    
    v.bmen:=i.fr_slv.en;
    v.o.we:=not i.fr_slv.dir;
    case v.state is
      when IDLE =>      -------------------IDLE STATE---------------------------
        if i.fr_slv.en='1' and r.bmen='0' then
          v.state:=INIT;  v.o.to_slv.done:='0'; 
          v.adr_cnt:=conv_std_logic_vector(0,abits); end if;

      when INIT =>      -------------------INIT STATE---------------------------
        v.o.to_mst.write:='0'; v.o.to_ctr.sel:='0';
---------------------- nytt test
        v.o.to_mst.address:=i.fr_slv.prdtb+v.prdtb_offset; v.adr_set:='1';
        if i.fr_mst.active='0' and r.adr_set='1' then
          v.o.to_mst.burst:='1'; v.o.to_mst.start:='1'; end if;
----------------------- slut test          
--        if i.fr_mst.active='0' then
--          v.o.to_mst.burst:='1'; v.o.to_mst.start:='1'; end if;
--          v.o.to_mst.address:=i.fr_slv.prdtb+v.prdtb_offset;
        if i.fr_mst.ready='1' then 
          if r.adr_cnt=conv_std_logic_vector(0,abits) then
            if i.fr_slv.prd_belec='1' then --prd in mem is big endian
              v.cur_base(31 downto 24):=i.fr_mst.rdata(7 downto 0);
              v.cur_base(23 downto 16):=i.fr_mst.rdata(15 downto 8);
              v.cur_base(15 downto 8):=i.fr_mst.rdata(23 downto 16);
              v.cur_base(7 downto 0):=i.fr_mst.rdata(31 downto 24);
            else --prd in mem is little endian
              v.cur_base:=i.fr_mst.rdata; 
            end if;
            v.adr_cnt:=conv_std_logic_vector(1,abits);
          elsif r.adr_cnt=conv_std_logic_vector(1,abits) then
            if i.fr_slv.prd_belec='1' then --prd in mem is big endian
              v.edt:=i.fr_mst.rdata(7); v.cur_cnt:=(others=>'0');
              v.cur_length(15 downto 8):=i.fr_mst.rdata(23 downto 16);
              v.cur_length(7 downto 0):=i.fr_mst.rdata(31 downto 24);
            else --prd in mem is little endian
              v.edt:=i.fr_mst.rdata(31); v.cur_cnt:=(others=>'0');
              v.cur_length:=i.fr_mst.rdata(15 downto 0);
            end if;
            v.state:=PREPARE;  v.adr_set:='0';
            v.o.to_mst.address:=v.cur_base;
          end if;
        end if;
        if v.o.to_mst.start='1' and r.adr_cnt=conv_std_logic_vector(1,abits)
          and i.fr_mst.start='1' then
          v.o.to_mst.start:='0'; v.o.to_mst.burst:='0'; end if;
        
      when PREPARE =>
        v.o.to_ctr.ack:='0'; v.o.to_ctr.force_rdy:='0';
        v.o.to_mst.address:=v.cur_base+v.cur_cnt;
        v.adr_cnt:=conv_std_logic_vector(0,abits);
        if ((v.edt='1' and v.cur_cnt>=v.cur_length) or i.fr_ctr.irq='1')
        and i.fr_ctr.tip='0' then
          v.state:=IDLE;
          if (v.edt='1' and v.cur_cnt>=v.cur_length) then 
            v.o.to_slv.done:='1'; v.o.to_ctr.ack:='1'; end if;
        end if;
        if not(v.edt='1' and v.cur_cnt>=v.cur_length) then
          if i.fr_ctr.fifo_rdy='0' and i.fr_slv.dir='0' then 
            --might fail for AHB ram?
            v.o.to_mst.burst:='1'; v.o.to_mst.write:='0';
            v.o.to_mst.start:='1'; v.state:=BURST_TO_ATA;
          elsif i.fr_ctr.fifo_rdy='0' and i.fr_slv.dir='1' then
            --might fail for AHB ram?
            v.o.to_ctr.sel:='1';
            v.o.to_mst.burst:='1'; v.o.to_mst.write:='1';
            v.o.to_mst.start:='1'; v.state:=BURST_TO_MEM;
          end if;
        end if;

      when BURST_TO_ATA =>
        if i.fr_mst.start='1' and v.o.to_ctr.force_rdy='0' then 
          v_temp:=r.o.to_mst.address+4;
          --abort burst due to PRD exhausted  --------------------new
          if r.cur_cnt+4>=r.cur_length then
            v.o.to_mst.start:='0'; v.o.to_mst.burst:='0'; end if;
          --...due to fifo full
          if r.adr_cnt=conv_std_logic_vector(fdepth-1,abits) then
            v.o.to_mst.start:='0'; v.o.to_mst.burst:='0'; end if;
          --...due to AMBA 1k limit
          if not(v_temp(11 downto 10) = v.o.to_mst.address(11 downto 10))
          and not(r.edt='1' and r.cur_cnt>=r.cur_length) then
            v.o.to_mst.start:='0'; v.o.to_mst.burst:='0';
          end if;
        end if;
        if i.fr_mst.ready='1' and v.o.to_ctr.force_rdy='0' then
          v.o.to_mst.address:=r.o.to_mst.address+4; o.d<=i.fr_mst.rdata;
          v.adr_cnt:=r.adr_cnt+1; v.cur_cnt:=r.cur_cnt+4; v.o.to_ctr.sel:='1';
          if r.adr_cnt=conv_std_logic_vector(fdepth-1,abits) then
            v.o.to_ctr.force_rdy:='1'; end if;
          --state transition when AMBA 1k limit
          if not(v.o.to_mst.address(11 downto 10) = 
                 r.o.to_mst.address(11 downto 10))
          and v.o.to_ctr.force_rdy='0'
          and not(r.edt='1' and r.cur_cnt>=r.cur_length) then
            v.state:=BURST_WAIT; end if;
        else v.o.to_ctr.sel:='0'; end if;
        --state transition when FIFO filled
        if v.cur_cnt>=v.cur_length and v.edt='0' 
--        and i.fr_ctr.fifo_rdy='1' then
        and (i.fr_ctr.fifo_rdy='1'or r.cur_cnt+4>=r.cur_length) then
          v.prdtb_offset:=v.prdtb_offset+X"0008"; v.cur_cnt:=X"0000";
          v.adr_cnt:=conv_std_logic_vector(0,abits); v.state:=INIT;
        elsif i.fr_ctr.fifo_rdy='1' then v.state:=PREPARE; end if;
                   
      when BURST_TO_MEM =>
        v.o.to_ctr.sel:='0';
        if i.fr_mst.start='1' and v.o.to_ctr.force_rdy='0' then 
          v_temp:=r.o.to_mst.address+4; o.to_mst.wdata<=i.fr_ctr.q;
          --abort burst due to PRD exhausted
          if r.cur_cnt+4>=r.cur_length then
            v.o.to_mst.start:='0'; v.o.to_mst.burst:='0'; end if;
          --...due to fifo empty
          if r.adr_cnt=conv_std_logic_vector(fdepth-1,abits) then
            v.o.to_mst.start:='0'; v.o.to_mst.burst:='0'; end if;
          --...due to AMBA 1k limit
          if not(v_temp(11 downto 10) = v.o.to_mst.address(11 downto 10))
          and not(r.edt='1' and r.cur_cnt>=r.cur_length) then
            v.o.to_mst.start:='0'; v.o.to_mst.burst:='0';
          end if;
        end if;
        if i.fr_mst.ready='1' and v.o.to_ctr.force_rdy='0' then 
          v.o.to_mst.address:=r.o.to_mst.address+4;
          v.adr_cnt:=r.adr_cnt+1; v.cur_cnt:=r.cur_cnt+4;
          --fifo emptied, set ready
          if r.adr_cnt=conv_std_logic_vector(fdepth-1,abits) then
            v.o.to_ctr.force_rdy:='1'; end if;
          --fifo NOT emptied, keep reading
          if r.adr_cnt < conv_std_logic_vector(fdepth-1,abits) 
          and r.cur_cnt+4<r.cur_length then
            v.o.to_ctr.sel:='1'; else v.o.to_ctr.sel:='0'; end if;
          --state transition when AMBA 1k limit
          if not(v.o.to_mst.address(11 downto 10) = 
                 r.o.to_mst.address(11 downto 10))
          and v.o.to_ctr.force_rdy='0'
          and not(r.edt='1' and r.cur_cnt>=r.cur_length) then
            v.state:=BURST_WAIT; end if;
        else v.o.to_ctr.sel:='0'; --2007-1-15
        end if;
        if i.fr_mst.active='0' then
          if v.cur_cnt>=v.cur_length and v.edt='0' 
          and (i.fr_ctr.fifo_rdy='1'or r.cur_cnt+4>=r.cur_length) then
            v.prdtb_offset:=v.prdtb_offset+X"0008"; v.cur_cnt:=X"0000";
            v.adr_cnt:=conv_std_logic_vector(0,abits); v.state:=INIT;
          elsif i.fr_ctr.fifo_rdy='1' then v.state:=PREPARE; end if;
        end if;

      when BURST_WAIT =>
        if i.fr_mst.active='0' then
          v.o.to_ctr.sel:='0'; v.o.to_mst.burst:='1'; v.o.to_mst.start:='1';
          if i.fr_slv.dir='1' then
            v.o.to_mst.write:='1'; v.state:=BURST_TO_MEM;
          else
            v.o.to_mst.write:='0'; v.state:=BURST_TO_ATA;
          end if;
        end if;

      when others  => ----------------------------------------------------------
        v.state:=IDLE;
    end case;
    
    if rst='0' or (i.fr_slv.en='0' and r.bmen='1') or i.fr_mst.mexc='1' then 
      v:=RESET_VECTOR; end if;

    ----------------------ASSIGN OUTPUTS----------------------------------------
    v.o.to_slv.cur_base:=v.cur_base; v.o.to_slv.cur_cnt:=v.cur_cnt; --2006-11-13
    o.to_slv<=r.o.to_slv;
    o.we<=r.o.we;
    o.to_mst.address<=r.o.to_mst.address;
    o.to_mst.start<=v.o.to_mst.start;
    o.to_mst.burst<=v.o.to_mst.burst;
    o.to_mst.write<=v.o.to_mst.write;
    o.to_mst.busy<=r.o.to_mst.busy;
    o.to_mst.irq<=r.o.to_mst.irq;
    o.to_mst.size<=r.o.to_mst.size;
    o.to_ctr.force_rdy<=r.o.to_ctr.force_rdy;
    o.to_ctr.ack<=r.o.to_ctr.ack;
    o.to_ctr.sel<=v.o.to_ctr.sel;
    o.to_slv.err<=i.fr_mst.mexc; --2007-02-06
    
    o.to_mst.wdata<=i.fr_ctr.q; --2006-11-16
    o.d<=i.fr_mst.rdata; --2006-11-16
    
    ri<=v;
  end process comb;

  --**********************FLIP FLOPS********************************************
  sync: process(clk)
  begin
    if rising_edge(clk) then r<=ri; end if;
  end process sync;
end;

--************************END OF FILE*******************************************
