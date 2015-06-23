-- $Id: tb_serport_uart_rx.vhd 476 2013-01-26 22:23:53Z mueller $
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
-- Module Name:    tb_serport_uart_rx - sim
-- Description:    Test bench for serport_uart_rx
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 tbd_serport_uart_rx [UUT]
--
-- To test:        serport_uart_rx
--
-- Target Devices: generic
--
-- Verified (with tb_serport_uart_rx_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2007-11-02    93  _tsim 0.26  8.2.03 I34   xc3s1000   d:ok
-- 2007-10-21    91  _ssim 0.26  8.1.03 I27   xc3s1000   c:ok (63488 cl 15.21s)
-- 2007-10-21    91  -     0.26  -            -          c:ok (63488 cl  7.12s)
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   1.1    use new simclk/simclkcnt
-- 2011-10-22   417   1.0.3  now numeric_std clean
-- 2010-04-24   281   1.0.2  use direct instatiation for tbd_
-- 2008-03-24   129   1.0.1  CLK_CYCLE now 31 bits
-- 2007-10-21    91   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.serportlib.all;

entity tb_serport_uart_rx is
end tb_serport_uart_rx;

architecture sim of tb_serport_uart_rx is
  
  signal CLK :  slbit := '0';
  signal RESET :  slbit := '0';
  signal CLKDIV : slv5 := slv(to_unsigned(15, 5));
  signal RXSD :  slbit := '1';
  signal RXDATA : slv8 := (others=>'0');
  signal RXVAL :  slbit := '0';
  signal RXERR  : slbit := '0';
  signal RXACT : slbit := '0';
  
  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;

  signal N_MON_VAL : slbit := '0';
  signal N_MON_ERR : slbit := '0';
  signal N_MON_DAT : slv8 := (others=>'0');
  signal R_MON_VAL_1 : slbit := '0';
  signal R_MON_ERR_1 : slbit := '0';
  signal R_MON_DAT_1 : slv8 := (others=>'0');
  signal R_MON_VAL_2 : slbit := '0';
  signal R_MON_ERR_2 : slbit := '0';
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

  UUT : entity work.tbd_serport_uart_rx
    port map (
      CLK    => CLK,
      RESET  => RESET,
      CLKDIV => CLKDIV,
      RXSD   => RXSD,
      RXDATA => RXDATA,
      RXVAL  => RXVAL,
      RXERR  => RXERR,
      RXACT  => RXACT
    );


  proc_stim: process
    file fstim : text open read_mode is "tb_serport_uart_rx_stim";
    variable iline : line;
    variable oline : line;
    variable idelta : integer := 0;
    variable itxdata : slv8 := (others=>'0');
    variable irxval  : slbit := '0';
    variable irxerr  : slbit := '0';
    variable irxdata : slv8 := (others=>'0');
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable irate : integer := 16;

    type bit_10_array_type  is array (0 to 9) of slbit;
    type int_10_array_type  is array (0 to 9) of integer;
    variable valpuls : bit_10_array_type := (others=>'0');
    variable delpuls : int_10_array_type := (others=>0);
    variable npuls : integer := 0;
    
  begin

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

          when ".wait " =>              -- .wait 
            read_ea(iline, idelta);
            wait for idelta*clock_period;

          when ".rate " =>              -- .rate 
            idelta := 0;
            while RXACT='1' loop          -- ensure that uart isn't active
              wait for clock_period;
              idelta := idelta + 1;
              exit when idelta>3000;
            end loop;
            read_ea(iline, irate);
            wait for 2*clock_period;
            CLKDIV <= slv(to_unsigned(irate-1, CLKDIV'length));
            wait for 2*clock_period;
              
          when ".xrate" =>              -- .xrate 
            read_ea(iline, irate);
              
          when "puls  " =>              -- puls
            writetimestamp(oline, CLK_CYCLE, ": puls ");

            read_ea(iline, irxval);
            read_ea(iline, irxerr);
            read_ea(iline, irxdata);

            npuls := 0;
            for i in valpuls'range loop
              testempty(iline, ok);
              if ok then
                exit;
              end if;
              read_ea(iline, valpuls(i));
              read_ea(iline, delpuls(i));
              assert delpuls(i)>0
                report "assert puls length > 0" severity failure;
              npuls := npuls + 1;
              write(oline, valpuls(i), right, 3);
              write(oline, delpuls(i), right, 3);
            end loop;  -- i
            writeline(output, oline);

            if npuls > 0 then
              N_MON_VAL <= irxval;
              N_MON_ERR <= irxerr;
              N_MON_DAT <= irxdata;
              for i in 0 to npuls-1 loop
                RXSD <= valpuls(i);
                wait for clock_period;
                N_MON_VAL <= '0';
                wait for (delpuls(i)-1)*clock_period;
              end loop;  -- i
            end if;
            
          when "send  " =>              -- send  
            read_ea(iline, idelta);
            read_ea(iline, itxdata);

            RXSD <= '1';
            wait for idelta*clock_period;

            writetimestamp(oline, CLK_CYCLE, ": send ");
            write(oline, itxdata, right, 10);
            writeline(output, oline);

            N_MON_VAL <= '1';
            N_MON_ERR <= '0';
            N_MON_DAT <= itxdata;

            RXSD <= '0';                      -- start bit
            wait for clock_period;
            N_MON_VAL <= '0';
            wait for (irate-1)*clock_period;
            RXSD <= '1';

            for i in itxdata'reverse_range loop -- transmit lsb first
              RXSD <= itxdata(i);             -- data bit
              wait for irate*clock_period;
            end loop;
      
            RXSD <= '1';                      -- stop bit
            wait for irate*clock_period;

          when others =>                -- unknown command
            write(oline, string'("?? unknown command: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;

      else
        report "failed to find command" severity failure;
        
      end if;
      
      testempty_ea(iline);
    end loop;  -- file_loop: 

    idelta := 0;
    while RXACT='1' loop
      wait for clock_period;
      idelta := idelta + 1;
      exit when idelta>3000;
    end loop;

    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    wait for 12*irate*clock_period;

    CLK_STOP <= '1';

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  
  proc_moni: process
    variable oline : line;
  begin

    loop 
      wait until rising_edge(CLK);

      if R_MON_VAL_1 = '1' then
        if R_MON_VAL_2 = '1' then
          writetimestamp(oline, CLK_CYCLE, ": moni ");
          write(oline, string'("  FAIL MISSING ERR="));
          write(oline, R_MON_ERR_2);
          write(oline, string'("  DATA="));
          write(oline, R_MON_DAT_2);
          writeline(output, oline);
        end if;
        R_MON_VAL_2 <= R_MON_VAL_1;
        R_MON_ERR_2 <= R_MON_ERR_1;
        R_MON_DAT_2 <= R_MON_DAT_1;
      end if;
      
      R_MON_VAL_1 <= N_MON_VAL;
      R_MON_ERR_1 <= N_MON_ERR;
      R_MON_DAT_1 <= N_MON_DAT;

      if RXVAL='1' or RXERR='1' then
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
          
          if R_MON_ERR_2 = '0' then
            if R_MON_DAT_2 = RXDATA and
               RXERR='0' then
              write(oline, string'("  OK"));
            else
              write(oline, string'("  FAIL"));
            end if;

          else
            if RXERR = '1' then
              write(oline, string'("  OK"));
            else
              write(oline, string'("  FAIL, RXERR=1 expected"));
            end if;
            
          end if;
          
        end if;
        
        writeline(output, oline);
      end if;
      
    end loop;
    
  end process proc_moni;

end sim;
