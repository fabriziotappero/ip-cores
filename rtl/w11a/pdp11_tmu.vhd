-- $Id: pdp11_tmu.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2008-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_tmu - sim
-- Description:    pdp11: trace and monitor unit
--
-- Dependencies:   -
--
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-03   674   1.2    start/stop/suspend overhaul
-- 2011-12-23   444   1.1    use local clkcycle count instead of simbus global
-- 2011-11-18   427   1.0.7  now numeric_std clean
-- 2010-10-17   333   1.0.6  use ibus V2 interface
-- 2010-06-26   309   1.0.5  add ibmreq.dip,.cacc,.racc to trace
-- 2009-05-10   214   1.0.4  add ENA signal (trace enable)
-- 2008-12-14   177   1.0.3  write gpr_* of DM_STAT_DP and dp_ireg_we_last
-- 2008-12-13   176   1.0.2  write only cycle currently used by tmu_conf
-- 2008-08-22   161   1.0.1  rename ubf_ -> ibf_
-- 2008-04-19   137   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.simbus.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_tmu is                     -- trace and monitor unit
  port (
    CLK : in slbit;                     -- clock
    ENA : in slbit := '0';              -- enable trace output
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - dpath
    DM_STAT_VM : in dm_stat_vm_type;    -- debug and monitor status - vmbox
    DM_STAT_CO : in dm_stat_co_type;    -- debug and monitor status - core
    DM_STAT_SY : in dm_stat_sy_type     -- debug and monitor status - system
  );
end pdp11_tmu;


architecture sim of pdp11_tmu is

  signal R_FIRST : slbit := '1';
  
begin

  proc_tm: process (CLK)
    variable oline  : line;
    variable clkcycle : integer := 0;
    variable ipsw   : slv16 := (others=>'0');
    variable ibaddr : slv16 := (others=>'0');
    variable emaddr : slv22 := (others=>'0');
    variable dp_ireg_we_last : slbit := '0';
    variable vm_ibsres_busy_last : slbit := '0';
    variable vm_ibsres_ack_last  : slbit := '0';
    variable wcycle : boolean := false;
    file ofile : text open write_mode is "tmu_ofile";
  begin

    if rising_edge(CLK) then

      clkcycle := clkcycle + 1;
      
      if R_FIRST = '1' then
        R_FIRST <= '0';
        write(oline, string'("#"));
        write(oline, string'(" clkcycle:d"));
        write(oline, string'(" cpu:o"));
        write(oline, string'(" dp.pc:o"));
        write(oline, string'(" dp.psw:o"));
        write(oline, string'(" dp.ireg:o"));
        write(oline, string'(" dp.ireg_we:b"));
        write(oline, string'(" dp.ireg_we_last:b"));  -- is ireg_we last cycle
        write(oline, string'(" dp.dsrc:o"));
        write(oline, string'(" dp.ddst:o"));
        write(oline, string'(" dp.dtmp:o"));
        write(oline, string'(" dp.dres:o"));
        write(oline, string'(" dp.gpr_adst:o"));
        write(oline, string'(" dp.gpr_mode:o"));
        write(oline, string'(" dp.gpr_bytop:b"));
        write(oline, string'(" dp.gpr_we:b"));

        write(oline, string'(" vm.ibmreq.aval:b"));
        write(oline, string'(" vm.ibmreq.re:b"));
        write(oline, string'(" vm.ibmreq.we:b"));
        write(oline, string'(" vm.ibmreq.rmw:b"));
        write(oline, string'(" vm.ibmreq.be0:b"));
        write(oline, string'(" vm.ibmreq.be1:b"));
        write(oline, string'(" vm.ibmreq.cacc:b"));
        write(oline, string'(" vm.ibmreq.racc:b"));
        write(oline, string'(" vm.ibmreq.addr:o"));
        write(oline, string'(" vm.ibmreq.din:o"));
        write(oline, string'(" vm.ibsres.ack:b"));
        write(oline, string'(" vm.ibsres.busy:b"));
        write(oline, string'(" vm.ibsres.dout:o"));

        write(oline, string'(" co.cpugo:b"));
        write(oline, string'(" co.cpususp:b"));
        write(oline, string'(" co.suspint:b"));
        write(oline, string'(" co.suspext:b"));

        write(oline, string'(" sy.emmreq.req:b"));
        write(oline, string'(" sy.emmreq.we:b"));
        write(oline, string'(" sy.emmreq.be:b"));
        write(oline, string'(" sy.emmreq.cancel:b"));
        write(oline, string'(" sy.emmreq.addr:o"));
        write(oline, string'(" sy.emmreq.din:o"));
        write(oline, string'(" sy.emsres.ack_r:b"));
        write(oline, string'(" sy.emsres.ack_w:b"));
        write(oline, string'(" sy.emsres.dout:o"));
        write(oline, string'(" sy.chit:b"));

        writeline(ofile, oline);
      end if;

      ipsw := (others=>'0');
      ipsw(psw_ibf_cmode) := DM_STAT_DP.psw.cmode;
      ipsw(psw_ibf_pmode) := DM_STAT_DP.psw.pmode;
      ipsw(psw_ibf_rset)  := DM_STAT_DP.psw.rset;
      ipsw(psw_ibf_pri)   := DM_STAT_DP.psw.pri;
      ipsw(psw_ibf_tflag) := DM_STAT_DP.psw.tflag;
      ipsw(psw_ibf_cc)    := DM_STAT_DP.psw.cc;

      ibaddr := "1110000000000000";
      ibaddr(DM_STAT_VM.ibmreq.addr'range) := DM_STAT_VM.ibmreq.addr;

      emaddr := (others=>'0');
      emaddr(DM_STAT_SY.emmreq.addr'range) := DM_STAT_SY.emmreq.addr;

      wcycle := false;
      if dp_ireg_we_last='1' or
         DM_STAT_DP.gpr_we='1' or
         DM_STAT_SY.emmreq.req='1' or
         DM_STAT_SY.emsres.ack_r='1' or
         DM_STAT_SY.emsres.ack_w='1' or
         DM_STAT_SY.emmreq.cancel='1' or
         DM_STAT_VM.ibmreq.re='1' or
         DM_STAT_VM.ibmreq.we='1' or
         DM_STAT_VM.ibsres.ack='1'
      then
        wcycle := true;
      end if;

      if DM_STAT_VM.ibsres.busy='0' and
         (vm_ibsres_busy_last='1' and vm_ibsres_ack_last='0')
      then
        wcycle := true;
      end if;

      if ENA = '0' then                 -- if not enabled
        wcycle := false;                -- force to not logged...
      end if;

      if wcycle then
        write(oline, clkcycle, right, 9);
        write(oline, string'(" 0"));
        writeoct(oline, DM_STAT_DP.pc,   right, 7);
        writeoct(oline, ipsw, right, 7);
        writeoct(oline, DM_STAT_DP.ireg, right, 7);
        write(oline,    DM_STAT_DP.ireg_we, right, 2);
        write(oline,    dp_ireg_we_last, right, 2);
        writeoct(oline, DM_STAT_DP.dsrc, right, 7);
        writeoct(oline, DM_STAT_DP.ddst, right, 7);
        writeoct(oline, DM_STAT_DP.dtmp, right, 7);
        writeoct(oline, DM_STAT_DP.dres, right, 7);
        writeoct(oline, DM_STAT_DP.gpr_adst, right, 2);
        writeoct(oline, DM_STAT_DP.gpr_mode, right, 2);
        write(oline, DM_STAT_DP.gpr_bytop, right, 2);
        write(oline, DM_STAT_DP.gpr_we, right, 2);

        write(oline,    DM_STAT_VM.ibmreq.aval, right, 2);
        write(oline,    DM_STAT_VM.ibmreq.re, right, 2);
        write(oline,    DM_STAT_VM.ibmreq.we, right, 2);
        write(oline,    DM_STAT_VM.ibmreq.rmw, right, 2);
        write(oline,    DM_STAT_VM.ibmreq.be0, right, 2);
        write(oline,    DM_STAT_VM.ibmreq.be1, right, 2);
        write(oline,    DM_STAT_VM.ibmreq.cacc, right, 2);
        write(oline,    DM_STAT_VM.ibmreq.racc, right, 2);
        writeoct(oline, ibaddr, right, 7);
        writeoct(oline, DM_STAT_VM.ibmreq.din, right, 7);
        write(oline,    DM_STAT_VM.ibsres.ack, right, 2);
        write(oline,    DM_STAT_VM.ibsres.busy, right, 2);
        writeoct(oline, DM_STAT_VM.ibsres.dout, right, 7);

        write(oline,    DM_STAT_CO.cpugo, right, 2);
        write(oline,    DM_STAT_CO.cpususp, right, 2);
        write(oline,    DM_STAT_CO.suspint, right, 2);
        write(oline,    DM_STAT_CO.suspext, right, 2);

        write(oline,    DM_STAT_SY.emmreq.req, right, 2);
        write(oline,    DM_STAT_SY.emmreq.we, right, 2);
        write(oline,    DM_STAT_SY.emmreq.be, right, 3);
        write(oline,    DM_STAT_SY.emmreq.cancel, right, 2);
        writeoct(oline, emaddr, right, 9);
        writeoct(oline, DM_STAT_SY.emmreq.din, right, 7);
        write(oline,    DM_STAT_SY.emsres.ack_r, right, 2);
        write(oline,    DM_STAT_SY.emsres.ack_w, right, 2);
        writeoct(oline, DM_STAT_SY.emsres.dout, right, 7);
        write(oline,    DM_STAT_SY.chit, right, 2);

        writeline(ofile, oline);
      end if;

      dp_ireg_we_last     := DM_STAT_DP.ireg_we;
      vm_ibsres_busy_last := DM_STAT_VM.ibsres.busy;
      vm_ibsres_ack_last  := DM_STAT_VM.ibsres.ack;
      
    end if;

  end process proc_tm;

end sim;
