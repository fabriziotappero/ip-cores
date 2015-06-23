-- $Id: tb_pdp11core.vhd 675 2015-05-08 21:05:08Z mueller $
--
-- Copyright 2006-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_pdp11core - sim
-- Description:    Test bench for pdp11_core
--
-- Dependencies:   simlib/simclk
--                 tbd_pdp11core [UUT]
--                 pdp11_intmap
--
-- To test:        pdp11_core
--
-- Target Devices: generic
-- Tool versions:  ghdl 0.18-0.31; ISim 14.7
--
-- Verified (with tb_pdp11core_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2014-12-23   620  -     0.31  14.7 131013  -          u:ok
-- 2010-12-30   351  -     0.29  -            -          u:ok
-- 2010-12-30   351  _ssim 0.29  12.1   M53d  xc3s1000   u:ok
-- 2010-06-20   308  -     0.29  -            -          u:ok
-- 2009-11-22   252  -     0.26  -            -          u:ok
-- 2007-12-30   107  -     0.25  -            -          u:ok
-- 2007-10-26    92  _tsim 0.26  8.1.03 I27   xc3s1000   c:fail -> blog_ghdl
-- 2007-10-26    92  _tsim 0.26  9.2.02 J39   xc3s1000   d:ok (full tsim!)
-- 2007-10-26    92  _tsim 0.26  9.1    J30   xc3s1000   d:ok (full tsim!)
-- 2007-10-26    92  _tsim 0.26  8.2.03 I34   xc3s1000   d:ok (full tsim!)
-- 2007-10-26    92  _fsim 0.26  8.2.03 I34   xc3s1000   d:ok
-- 2007-10-26    92  _ssim 0.26  8.2.03 I34   xc3s1000   d:ok
-- 2007-10-08    88  _ssim 0.18  8.2.03 I34   xc3s1000   d:ok
-- 2007-10-08    88  _ssim 0.18  9.1    J30   xc3s1000   d:ok
-- 2007-10-08    88  _ssim 0.18  9.2.02 J39   xc3s1000   d:ok
-- 2007-10-07    88  _ssim 0.26  8.1.03 I27   xc3s1000   c:ok
-- 2007-10-07    88  _ssim 0.26  8.1    I24   xc3s1000   c:fail -> blog_webpack
-- 2007-10-07    88  -     0.26  -            -          c:ok
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-08   675   1.5    start/stop/suspend overhaul
-- 2014-12-26   621   1.4.1  adopt wmembe,ribr,wibr emulation to new 4k window
-- 2011-12-23   444   1.4    use new simclk/simclkcnt
-- 2011-11-18   427   1.3.2  now numeric_std clean
-- 2011-01-02   352   1.3.1  rename .cpmon->.rlmon
-- 2010-12-30   351   1.3    rename tb_pdp11_core -> tb_pdp11core
-- 2010-06-20   308   1.2.2  add wibrb, ribr, wibr commands for ibr accesses
-- 2010-06-20   307   1.2.1  add CP_ADDR_racc, CP_ADDR_be to tbd interface
-- 2010-06-13   305   1.2    add CP_CNTL_rnum and CP_ADDR_...;  emulate old
--                           'sta' behaviour with new 'stapc' command; rename
--                           lal,lah -> wal,wah and implement locally; new
--                           output format with cpfunc name
-- 2010-06-05   301   1.1.14 renamed .rpmon -> .rbmon
-- 2010-04-24   281   1.1.13 use direct instatiation for tbd_
-- 2009-11-28   253   1.1.12 add hack for ISim 11.3
-- 2009-05-10   214   1.1.11 add .scntl command (set/clear SB_CNTL bits)
-- 2008-08-29   163   1.1.10 allow, but ignore, the wtlam command
-- 2008-05-03   143   1.1.9  rename _cpursta->_cpurust
-- 2008-04-27   140   1.1.8  use cpursta interface, remove cpufail
-- 2008-04-19   137   1.1.7  use SB_CLKCYCLE now
-- 2008-03-24   129   1.1.6  CLK_CYCLE now 31 bits
-- 2008-03-02   121   1.1.5  redo sta,cont,wtgo commands; sta,cont now wait for
--                           command completion, wtgo waits for CPU to halt.
--                           added .cerr,.merr directive, check cmd(m)err state
--                           added .sdef as ignored directive
-- 2008-02-24   119   1.1.4  added lah,rps,wps command
-- 2008-01-26   114   1.1.3  add handling of d=val,msk
-- 2008-01-06   111   1.1.2  remove .eireq, EI's now handled in tbd_pdp11_core
-- 2007-10-26    92   1.0.2  use DONE timestamp at end of execution
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-09-02    79   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.simbus.all;
use work.pdp11_sim.all;
use work.pdp11.all;

entity tb_pdp11core is
end tb_pdp11core;

architecture sim of tb_pdp11core is

  signal CLK : slbit := '0';
  signal RESET : slbit := '0';
  signal UNUSEDSIGNAL : slbit := '0';   -- FIXME: hack to make ISim 11.3 happy
  signal CP_CNTL_req  : slbit := '0';
  signal CP_CNTL_func : slv5 := (others=>'0');
  signal CP_CNTL_rnum : slv3 := (others=>'0');
  signal CP_ADDR_addr : slv22_1 := (others=>'0');
  signal CP_ADDR_racc : slbit := '0';
  signal CP_ADDR_be   : slv2  := "11";
  signal CP_ADDR_ena_22bit : slbit := '0';
  signal CP_ADDR_ena_ubmap : slbit := '0';
  signal CP_DIN : slv16 := (others=>'0');
  signal CP_STAT_cmdbusy : slbit := '0';
  signal CP_STAT_cmdack : slbit := '0';
  signal CP_STAT_cmderr : slbit := '0';
  signal CP_STAT_cmdmerr : slbit := '0';
  signal CP_STAT_cpugo : slbit := '0';
  signal CP_STAT_cpustep : slbit := '0';
  signal CP_STAT_cpuwait : slbit := '0';
  signal CP_STAT_cpususp : slbit := '0';
  signal CP_STAT_cpurust : slv4 := (others=>'0');
  signal CP_STAT_suspint : slbit := '0';
  signal CP_STAT_suspext : slbit := '0';
  signal CP_DOUT : slv16 := (others=>'0');

  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;

  signal R_CHKDAT : slv16 := (others=>'0');
  signal R_CHKMSK : slv16 := (others=>'0');
  signal R_CHKREQ : slbit := '0';

  signal R_WAITCMD  : slbit := '0';
  signal R_WAITSTEP : slbit := '0';
  signal R_WAITGO   : slbit := '0';
  signal R_WAITOK   : slbit := '0';
  signal R_CP_STAT : cp_stat_type := cp_stat_init;
  signal R_CP_DOUT : slv16 := (others=>'0');
  
begin 

  CLKGEN : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK => CLK,
      CLK_STOP  => CLK_STOP
    );
  
  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  UUT: entity work.tbd_pdp11core
    port map (
      CLK             => CLK,
      RESET           => RESET,
      CP_CNTL_req     => CP_CNTL_req,
      CP_CNTL_func    => CP_CNTL_func,
      CP_CNTL_rnum    => CP_CNTL_rnum,
      CP_ADDR_addr    => CP_ADDR_addr,
      CP_ADDR_racc    => CP_ADDR_racc,
      CP_ADDR_be      => CP_ADDR_be,
      CP_ADDR_ena_22bit => CP_ADDR_ena_22bit,
      CP_ADDR_ena_ubmap => CP_ADDR_ena_ubmap,
      CP_DIN          => CP_DIN,
      CP_STAT_cmdbusy => CP_STAT_cmdbusy,
      CP_STAT_cmdack  => CP_STAT_cmdack,
      CP_STAT_cmderr  => CP_STAT_cmderr,
      CP_STAT_cmdmerr => CP_STAT_cmdmerr,
      CP_STAT_cpugo   => CP_STAT_cpugo,
      CP_STAT_cpustep => CP_STAT_cpustep,
      CP_STAT_cpuwait => CP_STAT_cpuwait,
      CP_STAT_cpususp => CP_STAT_cpususp,
      CP_STAT_cpurust => CP_STAT_cpurust,
      CP_STAT_suspint => CP_STAT_suspint,
      CP_STAT_suspext => CP_STAT_suspext,
      CP_DOUT         => CP_DOUT
    );
  
  proc_stim: process
    file ifile : text open read_mode is "tb_pdp11core_stim";
    variable iline  : line;
    variable oline  : line;
    variable idelta : integer := 0;
    variable idummy : integer := 0;
    variable dcycle : integer := 0;
    variable irqline : integer := 0;
    variable ireq  : boolean := false;
    variable ifunc : slv5  := (others=>'0');
    variable irnum : slv3  := (others=>'0');
    variable idin  : slv16 := (others=>'0');
    variable imsk  : slv16 := (others=>'1');
    variable idin3 : slv3  := (others=>'0');
    variable ichk  : boolean := false;
    variable idosta: slbit  := '0';

    variable ok    : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable rind  : integer := 0;
    variable nblk  : integer := 0;
    variable xmicmd : string(1 to 3) := (others=>' ');
    variable iwtstp : boolean := false;
    variable iwtgo  : boolean := false;
    variable icerr  : integer := 0;
    variable imerr  : integer := 0;
    variable to_cmd : integer := 50;
    variable to_stp : integer := 100;
    variable to_go  : integer := 5000;
    variable ien    : slbit := '0';
    variable ibit   : integer := 0;
    variable imemi  : boolean := false;
    variable iaddr  : slv16 := (others=>'0');
    variable idoibr : boolean := false;

    variable r_addr : slv22_1 := (others=>'0');
    variable r_ena_22bit : slbit := '0';
    variable r_ena_ubmap : slbit := '0';
    variable r_membe : slv2     := "11";
    variable r_membestick : slbit := '0';
    
  begin

    SB_CNTL <= (others=>'L');

    wait for clock_offset - setup_time;

    RESET <= '1';
    wait for clock_period;

    RESET <= '0';
    wait for 9*clock_period;
    
    file_loop: while not endfile(ifile) loop

      -- this logic is a quick hack to implement the 'stapc' command
      if idosta = '0' then
        readline (ifile, iline);

        iwtstp := false;
        iwtgo  := false;
        
        if nblk>0 and                     -- outstanding [rw]mi lines ?
          iline'length>=3 and            -- and 3 leading blanks
          iline(iline'left to iline'left+2)="   " then
          nblk := nblk - 1;               -- than fill [rw]mi command in again
          iline(iline'left to iline'left+2) := xmicmd;
        end if;
        
        readcomment(iline, ok);
        next file_loop when ok;

        readword(iline, dname, ok);

      else
        idosta := '0';
        dname  := "sta   ";
        ok     := true;
      end if;

      if ok then

        case dname is
          when "rsp   " => dname := "rr6   ";   -- rsp -> rr6
          when "rpc   " => dname := "rr7   ";   -- rpc -> rr7
          when "wsp   " => dname := "wr6   ";   -- wsp -> wr6
          when "wpc   " => dname := "wr7   ";   -- wpc -> wr7
          when others => null;
        end case;
        
        rind := character'pos(dname(3)) - character'pos('0');
        
        if (dname(1)='r' or dname(1)='w') and  -- check for [rw]r[0-7]
           dname(2)='r' and
           (rind>=0 and rind<=7) then
          dname(3) := '|';                     -- replace with [rw]r|
        end if;

        if dname(1) = '.' then
          case dname is
            when ".mode " =>            -- .mode
              readword_ea(iline, dname);
              assert dname="pdpcp "
                report "assert .mode == pdpcp" severity failure;

            when ".reset" =>            -- .reset
              write(oline, string'(".reset"));
              writeline(output, oline);
              RESET <= '1';
              wait for clock_period;

              RESET <= '0';
              wait for 9*clock_period;

            when ".wait " =>            -- .wait
              read_ea(iline, idelta);
              wait for idelta*clock_period;

            when ".tocmd" =>            -- .tocmd
              read_ea(iline, idelta);
              to_cmd := idelta;

            when ".tostp" =>            -- .tostp
              read_ea(iline, idelta);
              to_stp := idelta;

            when ".togo " =>            -- .togo
              read_ea(iline, idelta);
              to_go := idelta;

            when ".sdef " =>            -- .sdef (ignore it)
              readempty(iline);
              
            when ".cerr " =>            -- .cerr
              read_ea(iline, icerr);
            when ".merr " =>            -- .merr
              read_ea(iline, imerr);

            when ".anena" =>            -- .anena (ignore it)
              readempty(iline);
            when ".rlmon" =>            -- .rlmon (ignore it)
              readempty(iline);
            when ".rbmon" =>            -- .rbmon (ignore it)
              readempty(iline);

            when ".scntl" =>            -- .scntl
              read_ea(iline, ibit);
              read_ea(iline, ien);
              assert (ibit>=SB_CNTL'low and ibit<=SB_CNTL'high)
                report "assert bit number in range of SB_CNTL"
                severity failure;
              if ien = '1' then
                SB_CNTL(ibit) <= 'H';
              else
                SB_CNTL(ibit) <= 'L';
              end if;

            when others =>              -- bad directive
              write(oline, string'("-E: unknown directive: "));
              write(oline, dname);
              writeline(output, oline);
              report "aborting" severity failure;
          end case;

          testempty_ea(iline);
          next file_loop;

        else

          ireq   := true;
          ifunc  := c_cpfunc_noop;
          irnum  := "000";
          ichk   := false;
          idin   := (others=>'0');
          imsk   := (others=>'1');
          imemi  := false;
          idoibr := false;
          
          case dname is
            when "brm   " =>            -- brm
              read_ea(iline, nblk);
              xmicmd := "rmi";
              next file_loop;
            when "bwm   " =>            -- bwm
              read_ea(iline, nblk);
              xmicmd := "wmi";
              next file_loop;

            when "rr|   " =>            -- rr[0-7]
              ifunc := c_cpfunc_rreg;
              irnum := slv(to_unsigned(rind, 3));
              readtagval2_ea(iline, "d", ichk, idin, imsk, 8);

            when "wr|   " =>            -- wr[0-7]
              ifunc := c_cpfunc_wreg;
              irnum := slv(to_unsigned(rind, 3));
              readoct_ea(iline, idin);

            -- Note: there are no field definitions for wal, wah, wmembe because
            --       there is no corresponding cp command. Therefore the
            --       rbus field definitions are used here
            when "wal   " =>            -- wal
              readoct_ea(iline, idin);
              r_addr      := (others=>'0'); -- write to al clears ah !!
              r_ena_22bit := '0';
              r_ena_ubmap := '0';
              r_addr(c_al_rbf_addr) := idin(c_al_rbf_addr);
              testempty_ea(iline);
              next file_loop;
              
            when "wah   " =>            -- wah
              readoct_ea(iline, idin);
              r_addr(21 downto 16) := idin(c_ah_rbf_addr);
              r_ena_22bit          := idin(c_ah_rbf_ena_22bit);
              r_ena_ubmap          := idin(c_ah_rbf_ena_ubmap);
              testempty_ea(iline);
              next file_loop;

            when "wmembe" =>            -- wmembe
              read_ea(iline, idin3);
              r_membestick := idin3(c_membe_rbf_stick);
              r_membe      := idin3(c_membe_rbf_be);
              testempty_ea(iline);
              next file_loop;

            when "rm    " =>            -- rm
              ifunc := c_cpfunc_rmem;
              readtagval2_ea(iline, "d", ichk, idin, imsk, 8);
            when "rmi   " =>            -- rmi
              ifunc := c_cpfunc_rmem;
              imemi := true;
              readtagval2_ea(iline, "d", ichk, idin, imsk, 8);

            when "wm    " =>            -- wm
              ifunc := c_cpfunc_wmem;
              readoct_ea(iline, idin);
            when "wmi   " =>            -- wmi
              ifunc := c_cpfunc_wmem;
              imemi := true;
              readoct_ea(iline, idin);

            when "ribr  " =>            -- ribr
              ifunc  := c_cpfunc_rmem;
              idoibr := true;
              readoct_ea(iline, iaddr);
              readtagval2_ea(iline, "d", ichk, idin, imsk, 8);
            when "wibr  " =>            -- wibr
              ifunc  := c_cpfunc_wmem;
              idoibr := true;
              readoct_ea(iline, iaddr);
              readoct_ea(iline, idin);

            when "rps   " =>            -- rps
              ifunc := c_cpfunc_rpsw;
              readtagval2_ea(iline, "d", ichk, idin, imsk, 8);
            when "wps   " =>            -- wps
              ifunc := c_cpfunc_wpsw;
              readoct_ea(iline, idin);

            -- Note: in old version 'sta addr' was an atomic operation, loading
            --       the pc and starting the cpu. Now this is action is two step
            --       first a wpc followed by a 'sta'.
            when "stapc " =>            -- stapc
              ifunc := c_cpfunc_wreg;
              irnum := c_gpr_pc;
              readoct_ea(iline, idin);
              idosta := '1';              -- request 'sta' to be done next

            when "sta   " =>            -- sta
              ifunc := c_cpfunc_start;
            when "sto   " =>            -- sto
              ifunc := c_cpfunc_stop;
            when "step  " =>            -- step
              ifunc := c_cpfunc_step;
              iwtstp := true;
            when "cres  " =>            -- cres
              ifunc := c_cpfunc_creset;
            when "bres  " =>            -- bres
              ifunc := c_cpfunc_breset;
            when "susp  " =>            -- susp
              ifunc := c_cpfunc_suspend;
            when "resu  " =>            -- resu
              ifunc := c_cpfunc_resume;

            when "wtgo  " =>            -- wtgo
              iwtgo := true;
              ireq  := false;             -- no cp request !

            when "wtlam " =>            -- wtlam (ignore it)
              readempty(iline);
              next file_loop;

            when others =>              -- bad directive
              write(oline, string'("-E: unknown directive: "));
              write(oline, dname);
              writeline(output, oline);
              report "aborting" severity failure;
          end case;
          
        end if;
        testempty_ea(iline);

      end if;
      
      CP_ADDR_be <= r_membe;
      if idoibr then
        CP_ADDR_addr(15 downto 13) <= "111";
        CP_ADDR_addr(12 downto 1)  <= iaddr(12 downto 1);
        CP_ADDR_racc      <= '1';
        CP_ADDR_ena_22bit <= '0';
        CP_ADDR_ena_ubmap <= '0';
      else
        CP_ADDR_addr      <= r_addr;
        CP_ADDR_racc      <= '0';
        CP_ADDR_be        <= "11";
        CP_ADDR_ena_22bit <= r_ena_22bit;
        CP_ADDR_ena_ubmap <= r_ena_ubmap;
      end if;

      if ireq then
        CP_CNTL_req  <= '1';
        CP_CNTL_func <= ifunc;
        CP_CNTL_rnum <= irnum;
      end if;
      
      if ichk then
        CP_DIN   <= (others=>'0');
        R_CHKDAT <= idin;
        R_CHKMSK <= imsk;
        R_CHKREQ <= '1';
      else
        CP_DIN   <= idin;
        R_CHKREQ <= '0';
      end if;
           
      R_WAITCMD  <= '0';
      R_WAITSTEP <= '0';
      R_WAITGO   <= '0';
      if iwtgo then
        idelta := to_go;
        R_WAITGO <= '1';
      elsif iwtstp then
        idelta := to_stp;
        R_WAITSTEP <= '1';
      else
        idelta := to_cmd;
        R_WAITCMD <= '1';        
      end if;

      wait for clock_period;
      CP_CNTL_req <= '0';

      dcycle := 1;
      while idelta>0 and R_WAITOK='0' loop
        wait for clock_period;
        dcycle := dcycle + 1;
        idelta := idelta - 1;
      end loop;

      if imemi then                     -- rmi or wmi seen ? then inc ar
        r_addr := slv(unsigned(r_addr) + 1);
      end if;

      if ifunc = c_cpfunc_wmem and      -- emulate be sticky logic of rbus iface
         r_membestick = '0' then
        r_membe := "11";
      end if;
      
      write(oline, dcycle, right, 4);
      write(oline, string'(" "));
      if ireq then
        case ifunc is
          when c_cpfunc_rreg => write(oline, string'("rreg"));
          when c_cpfunc_wreg => write(oline, string'("wreg"));
          when c_cpfunc_rpsw => write(oline, string'("rpsw"));
          when c_cpfunc_wpsw => write(oline, string'("wpsw"));
          when c_cpfunc_rmem =>
            if idoibr then
              write(oline, string'("ribr"));
            else
              write(oline, string'("rmem"));
            end if;
          when c_cpfunc_wmem =>
            if idoibr then
              write(oline, string'("wibr"));
            else
              write(oline, string'("wmem"));
            end if;
          when c_cpfunc_start   => write(oline, string'("sta "));
          when c_cpfunc_stop    => write(oline, string'("sto "));
          when c_cpfunc_step    => write(oline, string'("step"));
          when c_cpfunc_creset  => write(oline, string'("cres"));
          when c_cpfunc_breset  => write(oline, string'("bres"));
          when c_cpfunc_suspend => write(oline, string'("susp"));
          when c_cpfunc_resume  => write(oline, string'("resu"));
          when others =>
            write(oline, string'("?"));
            writeoct(oline, ifunc, right, 2);
            write(oline, string'("?"));
        end case;
        writeoct(oline, irnum, right, 2);
        writeoct(oline, idin, right, 8);
      else
        write(oline, string'("---- -  ------"));
      end if;

      write(oline, R_CP_STAT.cmdbusy, right, 3);
      write(oline, R_CP_STAT.cmdack, right, 2);
      write(oline, R_CP_STAT.cmderr, right, 2);
      write(oline, R_CP_STAT.cmdmerr, right, 2);
      writeoct(oline, R_CP_DOUT, right, 8);
      write(oline, R_CP_STAT.cpugo, right, 3);
      write(oline, R_CP_STAT.cpustep, right, 1);
      write(oline, R_CP_STAT.cpuwait, right, 1);
      write(oline, R_CP_STAT.cpususp, right, 1);
      write(oline, R_CP_STAT.suspint, right, 1);
      write(oline, R_CP_STAT.suspext, right, 1);
      writeoct(oline, R_CP_STAT.cpurust, right, 3);

      if R_WAITOK = '1' then
        if R_CP_STAT.cmderr='1' or icerr=1 then
          if    R_CP_STAT.cmderr='1' and icerr=0 then
            write(oline, string'("  FAIL CMDERR"));
          elsif R_CP_STAT.cmderr='1' and icerr=1 then
            write(oline, string'("  CHECK CMDERR SEEN"));
          elsif R_CP_STAT.cmderr='0' and icerr=1 then
            write(oline, string'("  FAIL CMDERR EXPECTED,MISSED"));
          end if;
        elsif R_CP_STAT.cmdmerr='1' or imerr=1 then
          if    R_CP_STAT.cmdmerr='1' and imerr=0 then
            write(oline, string'("  FAIL CMDMERR"));
          elsif R_CP_STAT.cmdmerr='1' and imerr=1 then
            write(oline, string'("  CHECK CMDMERR SEEN"));
          elsif R_CP_STAT.cmdmerr='0' and imerr=1 then
            write(oline, string'("  FAIL CMDMERR EXPECTED,MISSED"));
          end if;
        elsif R_CHKREQ='1' then
          if unsigned((R_CP_DOUT xor R_CHKDAT) and (not R_CHKMSK))=0 then
            write(oline, string'("  CHECK OK"));
          else
            write(oline, string'("  CHECK FAILED, d="));
            writeoct(oline, R_CHKDAT, right, 7);
            if unsigned(R_CHKMSK)/=0 then
              write(oline, string'(","));
              writeoct(oline, R_CHKMSK, right, 7);
            end if;
          end if;
        end if;

        if iwtgo then
          write(oline, string'("  WAIT GO OK  "));
        elsif iwtstp then
          write(oline, string'("  WAIT STEP OK"));
        end if;
        
      else
        write(oline, string'("  WAIT FAILED (will reset)"));
        RESET <= '1';
        wait for clock_period;

        RESET <= '0';
        wait for 9*clock_period;
        
      end if;
      writeline(output, oline);
      
    end loop;
    
    wait for 4*clock_period;
    CLK_STOP <= '1';

    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);
    
    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;
  
  proc_moni: process
  begin

    loop 
      wait until rising_edge(CLK);
      wait for c2out_time;

      R_WAITOK <= '0';
      if R_WAITCMD = '1' then
        if CP_STAT_cmdack = '1' then
          R_WAITOK <= '1';
        end if;
      elsif R_WAITGO = '1' then
        if CP_STAT_cmdbusy='0' and CP_STAT_cpugo='0' then
          R_WAITOK <= '1';
        end if;
      elsif R_WAITSTEP = '1' then
        if CP_STAT_cmdbusy='0' and CP_STAT_cpustep='0' then
          R_WAITOK <= '1';
        end if;
      end if;
      
      R_CP_STAT.cmdbusy <= CP_STAT_cmdbusy;
      R_CP_STAT.cmdack  <= CP_STAT_cmdack;
      R_CP_STAT.cmderr  <= CP_STAT_cmderr;
      R_CP_STAT.cmdmerr <= CP_STAT_cmdmerr;
      R_CP_STAT.cpugo   <= CP_STAT_cpugo;
      R_CP_STAT.cpustep <= CP_STAT_cpustep;
      R_CP_STAT.cpuwait <= CP_STAT_cpuwait;
      R_CP_STAT.cpususp <= CP_STAT_cpususp;
      R_CP_STAT.cpurust <= CP_STAT_cpurust;
      R_CP_STAT.suspint <= CP_STAT_suspint;
      R_CP_STAT.suspext <= CP_STAT_suspext;
      R_CP_DOUT <= CP_DOUT;
      
    end loop;
    
  end process proc_moni;
  
end sim;
