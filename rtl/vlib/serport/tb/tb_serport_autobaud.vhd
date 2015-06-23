-- $Id: tb_serport_autobaud.vhd 476 2013-01-26 22:23:53Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_serport_autobaud - sim
-- Description:    Test bench for serport_autobaud
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 tbd_serport_autobaud [UUT]
--
-- To test:        serport_autobaud
--
-- Target Devices: generic
--
-- Verified (with tb_serport_autobaud_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2007-11-02    93  _tsim 0.26  8.2.03 I34   xc3s1000   d:ok
-- 2007-10-21    91  _ssim 0.26  8.1.03 I27   xc3s1000   c:ok
-- 2007-10-21    91  -     0.26  -            -          c:ok
-- 2007-10-14    89  -     0.26  -            -          c:ok
-- 2007-10-12    88  _ssim 0.26  8.1.03 I27   xc3s1000   c:ok
-- 2007-10-12    88  -     0.26  -            -          c:ok
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   1.2    use new simclk/simclkcnt
-- 2011-10-22   417   1.1.3  now numeric_std clean
-- 2010-04-24   281   1.1.2  use direct instatiation for tbd_
-- 2008-03-24   129   1.1.1  CLK_CYCLE now 31 bits
-- 2007-10-21    91   1.1    now use 'send' command, self-checking (FAIL's)
-- 2007-10-14    89   1.1    add extra stop bit for CLKDIV=0; drop c2out wait;
--                           add moni for autobauder
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-08-27    76   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.serportlib.all;

entity tb_serport_autobaud is
end tb_serport_autobaud;

architecture sim of tb_serport_autobaud is
  
  signal CLK : slbit := '0';
  signal RESET : slbit := '0';
  signal RXSD : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';
  signal CLKDIV : slv13 := (others=>'0');
  signal ABACT : slbit := '0';
  signal ABDONE : slbit := '0';
  signal RXDATA : slv8 := (others=>'0');
  signal RXVAL : slbit := '0';
  signal RXERR  : slbit := '0';
  signal RXACT : slbit := '0';
  signal TXSD2 : slbit := '0';
  signal RXDATA3 : slv8 := (others=>'0');
  signal RXVAL3 : slbit := '0';
  signal RXERR3  : slbit := '0';
  signal RXACT3 : slbit := '0';
  
  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;
  
  signal N_MON_VAL : slbit := '0';
  signal N_MON_DAT : slv8 := (others=>'0');
  signal R_MON_VAL_1 : slbit := '0';
  signal R_MON_DAT_1 : slv8 := (others=>'0');
  signal R_MON_VAL_2 : slbit := '0';
  signal R_MON_DAT_2 : slv8 := (others=>'0');

  constant clock_period : time :=  20 ns;
  constant clock_offset : time := 200 ns;
  constant setup_time : time :=  5 ns;
  constant c2out_time : time := 10 ns;

begin

  CLKGEN : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK       => CLK,
      CLK_STOP  => CLK_STOP
    );

  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  UUT : entity work.tbd_serport_autobaud
    port map (
      CLK     => CLK,
      RESET   => RESET,
      RXSD    => RXSD,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC,
      CLKDIV  => CLKDIV,
      ABACT   => ABACT,
      ABDONE  => ABDONE,
      RXDATA  => RXDATA,
      RXVAL   => RXVAL,
      RXERR   => RXERR,
      RXACT   => RXACT,
      TXSD2   => TXSD2,
      RXDATA3 => RXDATA3,
      RXVAL3  => RXVAL3,
      RXERR3  => RXERR3,
      RXACT3  => RXACT3
    );


  proc_stim: process
    file fstim : text open read_mode is "tb_serport_autobaud_stim";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idelta : integer := 0;
    variable irate : integer := 16;
    variable ival : slbit;
    variable itxdata : slv8 := (others=>'0');

  begin

    RXSD <= '1';
      
    wait for clock_offset - setup_time;

    file_loop: while not endfile(fstim) loop

      readline (fstim, iline);

      readcomment(iline, ok);
      next file_loop when ok;

      readword(iline, dname, ok);
      if ok then
        case dname is
          when ".reset" =>              -- .reset
            write(oline, string'(".reset"));
            writeline(output, oline);
            RESET <= '1';
            wait for clock_period;
            RESET <= '0';
            wait for 9*clock_period;
            
          when ".break" =>              -- .break
            read_ea(iline, idelta);
            write(oline, string'(".break"));
            writeline(output, oline);
            RXSD <= '0';
            wait for idelta*clock_period;
            RXSD <= '1';

          when ".wait " =>              -- .wait 
            read_ea(iline, idelta);
            wait for idelta*clock_period;

          when ".rate " =>              -- .rate 
            read_ea(iline, irate);

          when "send  " =>              -- send
            read_ea(iline, ival);
            read_ea(iline, itxdata);
      
            writetimestamp(oline, CLK_CYCLE, ": send ");
            write(oline, itxdata, right, 10);
            writeline(output, oline);

            RXSD <= '0';                      -- start bit
            N_MON_VAL <= ival;
            N_MON_DAT <= itxdata;
            wait for clock_period;
            N_MON_VAL <= '0';            
            wait for (irate-1)*clock_period;
            RXSD <= '1';

            for i in itxdata'reverse_range loop -- transmit lsb first
              RXSD <= itxdata(i);             -- data bit
              wait for irate*clock_period;
            end loop;
      
            RXSD <= '1';                      -- stop bit (plus extra cycle)
            wait for (irate+1)*clock_period;

          when others =>                -- unknown command
            write(oline, string'("?? unknown command: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;

      else
        report "failed to find command" severity failure;
        
      end if;

    end loop;

    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    wait for 25*irate*clock_period;

    CLK_STOP <= '1';

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  
  proc_moni: process
    variable oline : line;
    variable iabact : slbit := '0';
  begin

    loop 
      wait until rising_edge(CLK);

      if R_MON_VAL_1 = '1' then
        if R_MON_VAL_2 = '1' then
          writetimestamp(oline, CLK_CYCLE, ": moni ");
          write(oline, string'("  FAIL MISSING DATA="));
          write(oline, R_MON_DAT_2);
          writeline(output, oline);
        end if;
        R_MON_VAL_2 <= R_MON_VAL_1;
        R_MON_DAT_2 <= R_MON_DAT_1;
      end if;
      
      R_MON_VAL_1 <= N_MON_VAL;
      R_MON_DAT_1 <= N_MON_DAT;

      if (ABACT xor iabact)='1' then
        writetimestamp(oline, CLK_CYCLE, ": auto   ABACT =");
        write(oline, ABACT, right, 2);
        iabact := ABACT;
        writeline(output, oline);
      end if;
      
      if ABDONE = '1' then
        writetimestamp(oline, CLK_CYCLE, ": auto   CLKDIV =");
        write(oline, to_integer(unsigned(CLKDIV)), right, 3);
        writeline(output, oline);
      end if;
      
      if RXVAL='1' or (ABACT='0' and RXERR='1' and unsigned(RXDATA)/=0) then
        writetimestamp(oline, CLK_CYCLE, ": moni ");
        write(oline, RXDATA, right, 10);
        if RXERR = '1' then
          write(oline, string'("  RXERR=1"));
        end if;

        if R_MON_VAL_2 = '0' then
          write(oline, string'("  FAIL UNEXPECTED"));
        else
          write(oline, string'("  CHECK"));
          R_MON_VAL_2 <= '0';
          
          if R_MON_DAT_2 = RXDATA and
            RXERR='0' then
            write(oline, string'("  OK"));
          else
            write(oline, string'("  FAIL"));
          end if;
          
        end if;
        
        writeline(output, oline);
      end if;

    end loop;
    
  end process proc_moni;

end sim;
