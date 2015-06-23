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
-- Entity:      hs
-- File:        hs.vhd
-- Author:      David Lindh - Gaisler Research
-- Description: High speed DDR memory interface
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
use grlib.amba.all;
library gaisler;
use gaisler.misc.all;
library techmap;
use techmap.gencomp.all;
use techmap.allmem.all;
library gaisler;
use gaisler.ddrrec.all;

entity hs is
  generic(
    tech      : in integer;
    dqsize    : in integer;
    dmsize    : in integer;
    strobesize: in integer;
    clkperiod : in integer);
  port (
    rst       : in std_ulogic;
    clk0      : in std_ulogic;
    clk90     : in std_ulogic;
    clk180    : in std_ulogic;
    clk270    : in std_ulogic;
    hclk      : in std_ulogic;
    hssi      : in  hs_in_type;
    hsso      : out hs_out_type);
 end entity hs;

 architecture rtl of hs is

   type wait_times_row_type is array(7 downto 0) of integer range 0 to 31;
   type wait_times_matrix_type is array(7 downto 0) of wait_times_row_type;

   constant DELAY_15NS  : integer := (((15*1000)-1) / (clkperiod*1000))+1;
   constant DELAY_20NS  : integer := (((20*1000)-1) / (clkperiod*1000))+1;
   constant DELAY_50NS  : integer := (((50*1000)-1) / (clkperiod*1000))+1;
   constant DELAY_75NS  : integer := (((75*1000)-1) / (clkperiod*1000))+1;
   constant DELAY_80NS  : integer := (((80*1000)-1) / (clkperiod*1000))+1;
   constant DELAY_120NS : integer := (((120*1000)-1) / (clkperiod*1000))+1;                            

   
   
   
   constant wait_times : wait_times_matrix_type :=
   -- NOP,BST,READ,WRITE,ACT,PRE,RFSH,LMR
     ((0, 0, 0, 0, 0, 0, 0, 0),
      (0, 0, 0, 0, 0, 0, 0, 0),
      (0, 0, 0, 2, DELAY_20NS, 10, 10, 10),
      (0, 0, 3, 0, DELAY_20NS, 10, 10, 10),
      (0, 0, DELAY_20NS, 1+DELAY_15NS+DELAY_20NS, DELAY_15NS, DELAY_20NS, DELAY_120NS, 2),
      (0, 0, 0, 1+DELAY_15NS, DELAY_50NS, DELAY_20NS, DELAY_120NS, 2),
      (0, 0, DELAY_20NS, 1+DELAY_15NS+DELAY_20NS, 10, DELAY_20NS, DELAY_120NS, 2),
      (0, 0, DELAY_20NS, 1+DELAY_15NS+DELAY_20NS, 10, DELAY_20NS, DELAY_120NS, 2));

    
   
   --signal cmdr : cmd_reg_type; signal cmdri: cmd_reg_type;
   signal rwr  : rw_reg_type; signal rwri : rw_reg_type;
   signal data_out      : std_logic_vector((dqsize-1) downto 0);
   signal data_in       : std_logic_vector((dqsize-1) downto 0);
   signal strobe_out    : std_logic_vector((strobesize-1) downto 0);
   signal mask_out      : std_logic_vector((dmsize-1) downto 0);
   signal dq1_i    : std_logic_vector((dqsize-1) downto 0);
   signal dq1del_i : std_logic_vector((dqsize-1) downto 0);
   signal dq2_i    : std_logic_vector((dqsize-1) downto 0);
   signal dq1_o    : std_logic_vector((dqsize-1) downto 0);
   signal dq2_o    : std_logic_vector((dqsize-1) downto 0);
   signal dm1_o    : std_logic_vector((dmsize-1) downto 0);
   signal dm2_o    : std_logic_vector((dmsize-1) downto 0);
   signal dqs1_o, dqs2_o, w_ce, r_ce, vcc, gnd   : std_ulogic;


   -- DQS delay control signal
   signal uddcntl : std_ulogic;
   signal lock    : std_ulogic;
   signal dqsdel  : std_ulogic;
   signal read    : std_ulogic;
   signal dqso    : std_logic_vector((strobesize-1) downto 0);
   signal ddrclkpol : std_logic_vector((strobesize-1) downto 0);
   signal invrst  : std_logic;
   signal clk_90  :std_ulogic;

begin   
-------------------------------------------------------------------------------   
rwcomb : process(rst, hssi, rwr, dq1_i, dq1del_i, dq2_i)
  variable v : rw_reg_type;
begin
  v:= rwr;
  v.set_cmd := CMD_NOP;
  v.set_adr := (others => '0');
  v.set_cs := "11";
  v.begin_read := '0';
  v.begin_write := '0';


   
-------------------------------------------------------------------------------
   -- Buffer for incoming command
-------------------------------------------------------------------------------
   case v.cbufstate is
      when no_cmd =>
         v.hs_busy := '0';
         if hssi.cmd_valid = '1' then
           v.next_bl  := hssi.bl; v.next_buf := hssi.buf; v.next_cas := hssi.cas;
           v.next_adr := hssi.adr; v.next_cs := hssi.cs; v.next_cmd := hssi.cmd;
           v.next_ml := hssi.ml; v.next_ahb := hssi.ahb;
           v.cbufstate := new_cmd;
         end if;
      when new_cmd =>
         v.hs_busy := '1';
   end case;


   
-------------------------------------------------------------------------------
  -- Send commands
-------------------------------------------------------------------------------
case v.cmdstate is
 when idle =>
    v.holdcnt := 0;

   if rwr.cbufstate = new_cmd then
    v.rw_cmd := rwr.next_cmd;
    v.rw_bl := rwr.next_bl;
    v.rw_cas := 2 + conv_integer(rwr.next_cas(0))+ conv_integer(rwr.next_cas(1));
    v.set_cmd := rwr.next_cmd;
    v.set_adr := rwr.next_adr;
    v.set_cs  := rwr.next_cs;
    v.set_cke := '1'; 
    v.cbufstate := no_cmd;
    v.cmdstate := hold;

      -- Read command, delay start of Read machine
   if rwr.next_cmd = CMD_READ then   
      if rwr.next_cas = "00" then       -- cas 2   
         v.readwait(5) := '1';
         v.bufwait(5):=  rwr.next_buf; 
         v.ahbwait(5) := rwr.next_ahb;
         v.blwait(5) := rwr.next_bl;
         v.caswait(5) := rwr.next_cas(0);         
      else                            -- cas 2.5 or 3
         v.readwait(6) := '1';
         v.bufwait(6):=  rwr.next_buf;
         v.ahbwait(6) := rwr.next_ahb;
         v.blwait(6) := rwr.next_bl;
         v.caswait(6) := rwr.next_cas(0);
      end if;

       -- Calculate delay until write can begin
       v.r2wholdcnt :=  rwr.rw_cas  + rwr.rw_bl/2 +2;

       
     -- Write command, immediately start Write machine 
   elsif rwr.next_cmd = CMD_WRITE then
      v.writewait(1) := '1';
      v.bufwait(1):=  rwr.next_buf;
      v.ahbwait(1) := rwr.next_ahb;
      v.blwait(1) := rwr.next_bl;
      v.mlwait(1) := rwr.next_ml;

      -- Active command, begin count towards ealiest precharge
    elsif rwr.next_cmd = CMD_ACTIVE then
       v.act2precnt := DELAY_50NS-1;    
   end if;
 end if;


    -- Wait until next cmd is valid to send
 when hold =>
     
     v.set_cmd := CMD_NOP;
     v.set_adr := (others => '0');
     v.set_cs := "11";

     -- Some waittimes which isn't constant
     if v.rw_cmd = CMD_READ and rwr.next_cmd = CMD_WRITE then
       v.wait_time := v.rw_cas  + v.rw_bl/2;
     elsif v.rw_cmd = CMD_READ or v.rw_cmd = CMD_WRITE then
       v.wait_time := v.rw_bl/2;
     else
       v.wait_time := 0;
     end if;

     -- Calculate total wait time
     if rwr.cbufstate = new_cmd then
       if ((v.holdcnt+2 >= wait_times(conv_integer(rwr.next_cmd))(conv_integer(v.rw_cmd))+ v.wait_time)
           and (v.r2wholdcnt = 0 or rwr.next_cmd /= CMD_WRITE) 
           and (v.act2precnt = 0 or rwr.next_cmd /= CMD_PRE)) then
         v.cmdstate := idle;
       end if;
     elsif v.holdcnt >= 4+DELAY_120NS then
       v.cmdstate := idle;
     end if;
     
     v.holdcnt := v.holdcnt +1;
end case;

-- Separate count for time beteen a read and write and between  active and precharge
if v.r2wholdcnt /= 0 then v.r2wholdcnt := v.r2wholdcnt -1; end if;
if v.act2precnt /= 0 then v.act2precnt := v.act2precnt -1; end if;

-------------------------------------------------------------------------------
-- Delay cmd data for Read machine during CAS period
-------------------------------------------------------------------------------

  if v.readwait(0) = '1' or v.writewait(0) = '1' then
    v.begin_read :=  v.readwait(0);
    v.begin_write := v.writewait(0);
    v.use_ahb := v.ahbwait(0);
    v.use_buf := v.bufwait(0);
    v.use_bl := v.blwait(0);
    if v.writewait(0) = '1' then
      v.use_ml := v.mlwait(0);
    else
      v.use_cas := v.caswait(0);
    end if;
  end if;
     
  v.readwait := '0' & v.readwait(6 downto 1);
  v.writewait := '0' & v.writewait(1);
  v.bufwait(5 downto 0) :=  v.bufwait(6 downto 1);
  v.ahbwait := 0 & v.ahbwait(6 downto 1);
  v.blwait := 8 & v.blwait(6 downto 1);
  v.mlwait := 1 & v.mlwait(1);
  v.caswait := '0' & v.caswait(6 downto 1);


  
-------------------------------------------------------------------------------
   -- Send/recieve data
-------------------------------------------------------------------------------

  -- Read and Write routines
case v.rwstate is
  when idle =>
    v.sync_adr(0)  := (v.cur_buf(0)+1) & "00";
    v.sync_adr(1)  := (v.cur_buf(1)+1) & "00";
    v.cmdDone   := v.cur_buf;
    v.sync_write:= "00";
    v.dq_dqs_oe := '1';                  
    v.dqs1_o    := '0';                    
    v.w_ce      := '0';                      
    v.r_ce      := '1';                       
    v.cnt       := 0;
        
     if v.begin_write = '1' then
       v.cur_buf(v.use_ahb)  := v.use_buf;
       v.cur_ahb   := v.use_ahb;
       v.dq_dqs_oe := '0';                 
       v.w_ce      := '1';                      
       v.cnt       := v.cnt +2;
       if v.use_bl = 2 then
         v.sync_adr(v.use_ahb) := (v.use_buf +1) & "00";
       else
         v.sync_adr(v.use_ahb) := v.use_buf & "01";
       end if;
       v.rwstate := w;
       
     elsif v.begin_read = '1' then
       v.cur_buf(v.use_ahb)   := v.use_buf;
       v.cur_ahb   := v.use_ahb;
       v.sync_adr(v.use_ahb)  := v.use_buf & "00";
       v.sync_write(v.use_ahb) := '1';
       v.cnt        := v.cnt +2;
       v.cmdDone(v.use_ahb)    := v.use_buf;
       if v.use_cas = '0' then      -- Cas 2 or 3 
         v.sync_wdata((2*dqsize)-1 downto 0) :=  dq1_i & dq2_i;
       else                           -- Cas 2.5
         v.sync_wdata((2*dqsize)-1 downto 0) :=  dq2_i & dq1del_i;
       end if;
       v.rwstate := r;
     end if;

  -- Write
  when w =>
     v.dqs1_o    := '1';                 
     v.dq_dqs_oe := '0';

     if v.cnt = v.use_bl then       
       v.cmdDone(v.cur_ahb)  := v.cur_buf(v.cur_ahb);
       if v.begin_write = '0' then      -- No new write is following
         v.sync_adr(v.cur_ahb) := (v.cur_buf(v.cur_ahb)+1) & "00";
         v.cnt      := 0;
         v.rwstate  := idle; 
       else                             -- New write is following
          v.sync_adr(v.cur_ahb) := (v.cur_buf(v.cur_ahb)+1) & "00";
         if v.use_bl = 2 then
           v.sync_adr(v.use_ahb) := (v.use_buf +1) & "00";
         else
           v.sync_adr(v.use_ahb) := v.use_buf & "01";
         end if;
         v.cur_buf(v.use_ahb)   := v.use_buf;
         v.cur_ahb   := v.use_ahb;
         v.cnt       := 2;
       end if;
     else
       v.cnt := v.cnt +2;
       if v.cnt = v.use_bl then
         v.sync_adr(v.cur_ahb) := (v.cur_buf(v.cur_ahb)+1) & "00";
       else
         v.sync_adr(v.cur_ahb) := v.sync_adr(v.cur_ahb)+1;
       end if;
     end if;
     
  -- Read
  when r =>
    v.cmdDone(v.cur_ahb) := v.cur_buf(v.cur_ahb);
    if v.use_cas = '0' then             -- Cas 2 or 3
      v.sync_wdata((2*dqsize)-1 downto 0) :=  dq1_i & dq2_i;
    else                                -- Cas 2.5
      v.sync_wdata((2*dqsize)-1 downto 0) :=  dq2_i & dq1del_i;
    end if;

    if v.cnt = v.use_bl then
      if v.begin_read = '0' then
        v.sync_write := "00";
        v.sync_adr(v.cur_ahb) := (v.cur_buf(v.cur_ahb)+1) & "00";
        v.cnt        := 0;
        v.rwstate    := idle;
      else
        v.sync_adr(v.cur_ahb) := (v.cur_buf(v.cur_ahb)+1) & "00";
        v.cnt        := 2;
        v.cur_ahb   := v.use_ahb;
        v.cur_buf(v.use_ahb)   := v.use_buf;
        v.sync_adr(v.use_ahb) := v.use_buf & "00";
        if v.use_ahb = 0 then
          v.sync_write := "01";
        else
          v.sync_write := "10";
        end if;
      end if;
    else
      v.cnt := v.cnt +2;
      v.sync_adr(v.cur_ahb) := v.sync_adr(v.cur_ahb) +1;
    end if;
      
  end case;

   -- Calculate and set data mask 
  if v.use_ml+1 < v.cnt then
    v.dm1_o := (others => '1');
    v.dm2_o := (others => '1');
  elsif v.use_ml+1 = v.cnt then
    v.dm1_o(dmsize-1 downto 0) := hssi.dsramso(v.use_ahb).dataout2((2*dqsize+dmsize)-1 downto (2*dqsize));
    v.dm2_o := (others => '1');
  else
    v.dm1_o(dmsize-1 downto 0) := hssi.dsramso(v.use_ahb).dataout2((2*dqsize+dmsize)-1 downto (2*dqsize));
    v.dm2_o(dmsize-1 downto 0) := hssi.dsramso(v.use_ahb).dataout2((2*dqsize+2*dmsize)-1 downto (2*dqsize+dmsize));
  end if;


    
-------------------------------------------------------------------------------
-- Register and reset
  
  if rst = '0' then
    v.cbufstate := no_cmd;
    v.cmdstate  := idle;
    v.rwstate   := idle;
    v.cur_buf   := (others => (others => '1'));
    v.cur_ahb   := 0;
    v.use_bl    := 4;
    v.use_ml    := 2;
    v.use_buf   := (others => '1');
    v.use_cas   := '0';
    v.rw_cmd    := CMD_NOP;
    v.rw_bl     := 4;
    v.rw_cas    := 2;
    v.next_bl   := 4;
    v.next_ml   := 2;
    v.next_buf  := (others => '1');
    v.next_cas  := "00";
    v.next_adr  := (others => '0');
    v.next_cs   := "11";
    v.next_cmd  := CMD_NOP;
    v.set_cmd   := CMD_NOP;
    v.set_adr   := (others => '0');
    v.set_cs    := "00";
    v.set_cke   := '0';
    v.hs_busy   := '0';
    v.cmdDone   := (others => (others => '1'));
    v.begin_read  := '0';
    v.begin_write := '0';
    v.dq_dqs_oe := '1';
    v.w_ce      := '0';
    v.r_ce      := '0';
    v.cnt       := 0;
    v.holdcnt   := 0;
    v.r2wholdcnt:= 0;
    v.act2precnt:= 0;
    v.wait_time := 10;
    v.readwait  := (others => '0');
    v.writewait := (others => '0');
    v.dm1_o     := (others => '1');
    v.dm2_o     := (others => '1');
    v.dqs1_o    := '0';
    v.sync_adr  := (others => (others => '0'));
    v.sync_write := "00";
    v.sync_wdata := (others => '0');
  end if;

  rwri <= v;

 -- Combinatiorial outputs
  hsso.hs_busy <= v.hs_busy;
  dqs1_o <= v.dqs1_o;
  dqs2_o <= '0';
  hsso.dsramsi(0).address2 <= v.sync_adr(0);
  hsso.dsramsi(0).write2 <= v.sync_write(0);
  hsso.dsramsi(0).datain2 <= v.sync_wdata;
  hsso.dsramsi(1).address2 <= v.sync_adr(1);
  hsso.dsramsi(1).write2 <= v.sync_write(1);
  hsso.dsramsi(1).datain2 <= v.sync_wdata;
end process;

-------------------------------------------------------------------------------
-- Clocked processes

-- CLK0, Main register
rwclk : process(clk0)
  begin
    if rising_edge(clk0) then
      rwr <= rwri;

      -- Registered outputs
      r_ce <= rwri.r_ce;
      w_ce <= rwri.w_ce;
      hsso.cmdDone <= rwri.cmdDone;
      dm1_o <= rwri.dm1_o((dmsize-1) downto 0);
      dm2_o <= rwri.dm2_o((dmsize-1) downto 0);

      -- Registers
      dq1del_i <= dq1_i;
      dq1_o <= hssi.dsramso(rwri.use_ahb).dataout2(dqsize-1 downto 0);
      dq2_o <= hssi.dsramso(rwri.use_ahb).dataout2((2*dqsize)-1 downto dqsize);
      
    end if;
end process;     

---- CLK270, Drives output enable signal
--oeclk : process(rst, clk270)
--  begin
--    if rst = '0' then
--      hsso.ddsi.dq_dqs_oe <= '1';
--    elsif rising_edge(clk270) then
--      hsso.ddsi.dq_dqs_oe <= rwri.dq_dqs_oe;
--    end if;
--  end process;


-- CLK0, Drives control signals
 cmdclk : process(clk0)
  begin
     if rising_edge(clk0) then
      hsso.ddsi.control <= rwri.set_cmd;
      hsso.ddsi.adr     <= rwri.set_adr((adrbits-3) downto 0);
      hsso.ddsi.ba      <= rwri.set_adr((adrbits-1) downto (adrbits-2));
      hsso.ddsi.cs      <= rwri.set_cs;
      hsso.ddsi.cke     <= rwri.set_cke;    
   end if;
 end process;
  
  vcc <= '1';
  gnd <= '0';
  data_in <= hssi.ddso.dq((dqsize-1) downto 0);
  hsso.ddsi.dq((dqsize-1) downto 0) <= data_out;
  hsso.ddsi.dqs((strobesize-1) downto 0) <= strobe_out;
  hsso.ddsi.dm((dmsize-1) downto 0) <= mask_out;

  dqot : if dqsize < maxdqsize generate
     hsso.ddsi.dq((maxdqsize-1) downto dqsize) <= (others => '-');
  end generate;
  dqsot : if strobesize < maxstrobesize generate
     hsso.ddsi.dqs((maxstrobesize-1) downto strobesize) <= (others => '-');
  end generate;
  dmot : if dmsize <= maxdmsize generate
    hsso.ddsi.dm((maxdmsize-1) downto dmsize) <= (others => '-');
  end generate;

-------------------------------------------------------------------------------
-- DDR IO registers
-------------------------------------------------------------------------------



 -- Input and Output DQ
         
    dqio : for i in 0 to (dqsize-1) generate
        in1 : ddr_ireg generic map( tech => tech)
          port map(
            Q1 => dq1_i(i),
            Q2 => dq2_i(i),
            C1 => clk0,                
            C2 => clk180,                
            CE => vcc, --r_ce,              
            D  => data_in(i),
            R  => gnd,
            S  => gnd);
       
      out1  : ddr_oreg
        generic map( tech => tech)
        port map(
          Q  => data_out(i),
          C1 => clk180,
          C2 => clk0,                  
          CE => vcc, --w_ce,       
          D1 => dq1_o(i),
          D2 => dq2_o(i),
          R  => gnd,
          S  => gnd);

      dq_tri : ddr_oreg generic map(
          tech => tech)
        port map(
        Q  => hsso.ddsi.dq_oe(i),
        C1 => clk180,
        C2 => clk0,                  
        CE => vcc, --w_ce,       
        D1 => rwri.dq_dqs_oe,
        D2 => rwri.dq_dqs_oe,
        R  => gnd,
        S  => gnd);

    end generate;



 -- output DQS

 dqsio : for i in 0 to (strobesize-1) generate
     dqso : ddr_oreg
      generic map(
        tech => tech)
      port map(
        Q  => strobe_out(i),
        C1 => clk270,
        C2 => clk90,
        CE => vcc,
        D1 => dqs1_o, 
        D2 => dqs2_o,
        R  => gnd,
        S  => gnd);

     dqso_tri : ddr_oreg
      generic map(
        tech => tech)
      port map(
        Q  => hsso.ddsi.dqs_oe(i),
        C1 => clk270,
        C2 => clk90,                  
        CE => vcc, --w_ce,       
        D1 => rwri.dq_dqs_oe,
        D2 => rwri.dq_dqs_oe,
        R  => gnd,
        S  => gnd);
 end generate;



 -- Output DM
     
      dmo : for i in 0 to (dmsize-1) generate
      U4 : ddr_oreg
        generic map(
          tech => tech)
        port map(
          Q  => mask_out(i),
          C1 => clk180,
          C2 => clk0,
          CE => vcc, --w_ce,                --write_ce
          D1 => dm1_o(i), 
          D2 => dm2_o(i),
          R  => gnd,
          S  => gnd);
      end generate;
          
end rtl;          
