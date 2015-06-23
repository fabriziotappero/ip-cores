-- $Id: tb_tst_serloop.vhd 476 2013-01-26 22:23:53Z mueller $
--
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_tst_serloop - sim
-- Description:    Generic test bench for sys_tst_serloop_xx
--
-- Dependencies:   vlib/simlib/simclkcnt
--                 vlib/serport/serport_uart_rxtx
--                 vlib/serport/serport_xontx
--
-- To test:        sys_tst_serloop_xx
--
-- Target Devices: generic
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   1.1    use new simclkcnt
-- 2011-11-13   425   1.0    Initial version
-- 2011-11-06   420   0.5    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.serportlib.all;

entity tb_tst_serloop is
  port (
    CLKS : in slbit;                    -- clock for serport
    CLKH : in slbit;                    -- clock for humanio
    CLK_STOP : out slbit;               -- clock stop
    P0_RXD : out slbit;                 -- port 0 receive data (board view)
    P0_TXD : in slbit;                  -- port 0 transmit data (board view)
    P0_RTS_N : in slbit;                -- port 0 rts_n
    P0_CTS_N : out slbit;               -- port 0 cts_n
    P1_RXD : out slbit;                 -- port 1 receive data (board view)
    P1_TXD : in slbit;                  -- port 1 transmit data (board view)
    P1_RTS_N : in slbit;                -- port 1 rts_n
    P1_CTS_N : out slbit;               -- port 1 cts_n
    SWI : out slv8;                     -- hio switches
    BTN : out slv4                      -- hio buttons
  );
end tb_tst_serloop;

architecture sim of tb_tst_serloop is
  
  signal CLK_STOP_L  : slbit := '0';  
  signal CLK_CYCLE : integer := 0;
  
  signal UART_RESET : slbit := '0';
  signal UART_RXD : slbit := '1';
  signal UART_TXD : slbit := '1';
  signal CTS_N : slbit := '0';
  signal RTS_N : slbit := '0';

  signal CLKDIV : slv13 := (others=>'0');
  signal RXDATA : slv8 := (others=>'0');
  signal RXVAL : slbit := '0';
  signal RXERR : slbit := '0';
  signal RXACT : slbit := '0';
  signal TXDATA : slv8 := (others=>'0');
  signal TXENA : slbit := '0';
  signal TXBUSY : slbit := '0';

  signal UART_TXDATA : slv8 := (others=>'0');
  signal UART_TXENA : slbit := '0';
  signal UART_TXBUSY : slbit := '0';
  
  signal ACTPORT : slbit := '0';
  signal BREAK : slbit := '0';
  
  signal CTS_CYCLE : integer := 0;
  signal CTS_FRACT : integer := 0;
  signal XON_CYCLE : integer := 0;
  signal XON_FRACT : integer := 0;

  signal S2M_ACTIVE : slbit := '0';
  signal S2M_SIZE : integer := 0;
  signal S2M_ENAESC : slbit := '0';
  signal S2M_ENAXON : slbit := '0';
  
  signal M2S_XONSEEN : slbit := '0';
  signal M2S_XOFFSEEN : slbit := '0';

  signal R_XONRXOK : slbit := '1';
  signal R_XONTXOK : slbit := '1';

begin

  CLKCNT : simclkcnt port map (CLK => CLKS, CLK_CYCLE => CLK_CYCLE);

  UART : serport_uart_rxtx
    generic map (
      CDWIDTH => 13)
    port map (
      CLK    => CLKS,
      RESET  => UART_RESET,
      CLKDIV => CLKDIV,
      RXSD   => UART_RXD,
      RXDATA => RXDATA,
      RXVAL  => RXVAL,
      RXERR  => RXERR,
      RXACT  => RXACT,
      TXSD   => UART_TXD,
      TXDATA => UART_TXDATA,
      TXENA  => UART_TXENA,
      TXBUSY => UART_TXBUSY
    );

  XONTX : serport_xontx
    port map (
      CLK         => CLKS,
      RESET       => UART_RESET,
      ENAXON      => S2M_ENAXON,
      ENAESC      => S2M_ENAESC,
      UART_TXDATA => UART_TXDATA,
      UART_TXENA  => UART_TXENA,
      UART_TXBUSY => UART_TXBUSY,
      TXDATA      => TXDATA,
      TXENA       => TXENA,
      TXBUSY      => TXBUSY,
      RXOK        => R_XONRXOK,
      TXOK        => R_XONTXOK
    );
  
  proc_port_mux: process (ACTPORT, BREAK, UART_TXD, CTS_N,
                          P0_TXD, P0_RTS_N, P1_TXD, P1_RTS_N)
    variable eff_txd : slbit := '0';
  begin

    if BREAK = '0' then                 -- if no break active
      eff_txd := UART_TXD;                -- send uart
    else                                -- otherwise
      eff_txd := '0';                     -- force '0'
    end if;
    
    if ACTPORT = '0' then               -- use port 0
      P0_RXD   <= eff_txd;                -- write port 0 inputs
      P0_CTS_N <= CTS_N;
      UART_RXD <= P0_TXD;                 -- get port 0 outputs
      RTS_N    <= P0_RTS_N;
      P1_RXD   <= '1';                    -- port 1 inputs to idle state
      P1_CTS_N <= '0';
    else                                -- use port 1
      P1_RXD   <= eff_txd;                -- write port 1 inputs
      P1_CTS_N <= CTS_N;
      UART_RXD <= P1_TXD;                 -- get port 1 outputs
      RTS_N    <= P1_RTS_N;
      P0_RXD   <= '1';                    -- port 0 inputs to idle state
      P0_CTS_N <= '0';
    end if;
  end process proc_port_mux;

  proc_cts: process(CLKS)
    variable cts_timer : integer := 0;
  begin
    
    if rising_edge(CLKS) then    
      if CTS_CYCLE = 0 then               -- if cts throttle off
        CTS_N <= '0';                       -- cts permanently asserted

      else                                -- otherwise determine throttling

        if cts_timer>0 and cts_timer<CTS_CYCLE then  -- unless beyond ends
          cts_timer := cts_timer - 1;                  -- decrement
        else
          cts_timer := CTS_CYCLE-1;                    -- otherwise reload
        end if;

        if cts_timer < cts_fract then     -- if in lower 'fract' counts
          CTS_N <= '1';                     -- throttle: deassert CTS
        else                              -- otherwise
          CTS_N <= '0';                     -- let go: assert CTS
        end if;

      end if;
    end if;

  end process proc_cts;
  
  proc_xonrxok: process(CLKS)
    variable xon_timer : integer := 0;
  begin    
    if rising_edge(CLKS) then
      if XON_CYCLE = 0 then               -- if xon throttle off
        R_XONRXOK <= '1';                   -- xonrxok permanently asserted

      else                                -- otherwise determine throttling

        if xon_timer>0 and xon_timer<XON_CYCLE then  -- unless beyond ends
          xon_timer := xon_timer - 1;                  -- decrement
        else
          xon_timer := XON_CYCLE-1;                    -- otherwise reload
        end if;

        if xon_timer < xon_fract then     -- if in lower 'fract' counts
          R_XONRXOK <= '0';                 -- throttle: deassert xonrxok
        else                              -- otherwise
          R_XONRXOK <= '1';                 -- let go: assert xonrxok
        end if;

      end if;
    end if;
  end process proc_xonrxok;
  
  proc_xontxok: process(CLKS)
  begin    
    if rising_edge(CLKS) then
      if M2S_XONSEEN = '1' then
        R_XONTXOK <= '1';
      elsif M2S_XOFFSEEN = '1' then
        R_XONTXOK <= '0';
      end if;
    end if;
  end process proc_xontxok;
  
  proc_stim: process
    file fstim : text open read_mode is "tb_tst_serloop_stim";
    variable iline : line;
    variable oline : line;
    variable idelta : integer := 0;
    variable iactport : slbit := '0';
    variable iswi : slv8 := (others=>'0');
    variable btn_num : integer := 0;
    variable i_cycle : integer := 0;
    variable i_fract : integer := 0;
    variable nbyte : integer := 0;
    variable enaesc : slbit := '0';
    variable enaxon : slbit := '0';
    variable bcnt : integer := 0;
    variable itxdata : slv8 := (others=>'0');
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');

    procedure waitclk(ncyc  : in integer) is
    begin 
     for i in 1 to ncyc loop
       wait until rising_edge(CLKS);
     end loop;  -- i
    end procedure waitclk;

  begin

    -- initialize some top level out signals
    SWI <= (others=>'0');
    BTN <= (others=>'0');
  
    wait until rising_edge(CLKS);

    file_loop: while not endfile(fstim) loop

      readline (fstim, iline);

      readcomment(iline, ok);
      next file_loop when ok;

      readword(iline, dname, ok);
      if ok then
        case dname is
          when "wait  " =>              -- wait  
            read_ea(iline, idelta);
            writetimestamp(oline, CLK_CYCLE, ": wait  ");
            write(oline, idelta, right, 5);
            writeline(output, oline);
            waitclk(idelta);

          when "port  " =>              -- switch rs232 port
            read_ea(iline, iactport);
            ACTPORT <= iactport;
            writetimestamp(oline, CLK_CYCLE, ": port  ");
            write(oline, iactport, right, 5);
            writeline(output, oline);             
            
          when "cts   " =>              -- setup cts throttling
            read_ea(iline, i_cycle);
            read_ea(iline, i_fract);
            CTS_CYCLE <= i_cycle;
            CTS_FRACT <= i_fract;
            writetimestamp(oline, CLK_CYCLE, ": cts   ");
            write(oline, i_cycle, right, 5);
            write(oline, i_fract, right, 5);
            writeline(output, oline);             
            
          when "xon   " =>              -- setup xon throttling
            read_ea(iline, i_cycle);
            read_ea(iline, i_fract);
            XON_CYCLE <= i_cycle;
            XON_FRACT <= i_fract;
            writetimestamp(oline, CLK_CYCLE, ": cts   ");
            write(oline, i_cycle, right, 5);
            write(oline, i_fract, right, 5);
            writeline(output, oline);             
            
          when "swi   " =>              -- new SWI settings
            read_ea(iline, iswi);
            read_ea(iline, idelta);
            writetimestamp(oline, CLK_CYCLE, ": swi   ");
            write(oline, iswi, right, 10);
              write(oline, idelta, right, 5);
            writeline(output, oline);             
            wait until rising_edge(CLKH);
            SWI <= iswi;
            wait until rising_edge(CLKS);
            waitclk(idelta);
            
          when "btn   " =>              -- BTN push (3 cyc down + 3 cyc wait)
            read_ea(iline, btn_num);
            read_ea(iline, idelta);
            if btn_num>=0 and btn_num<=3 then
              writetimestamp(oline, CLK_CYCLE, ": btn   ");
              write(oline, btn_num, right, 5);
              write(oline, idelta, right, 5);
              writeline(output, oline);                           
              wait until rising_edge(CLKH);
              BTN(btn_num) <= '1';      -- 3 cycle BTN pulse
              wait until rising_edge(CLKH);
              wait until rising_edge(CLKH);
              wait until rising_edge(CLKH);
              BTN(btn_num) <= '0';
              wait until rising_edge(CLKH);
              wait until rising_edge(CLKH);
              wait until rising_edge(CLKH);
              wait until rising_edge(CLKS);
              waitclk(idelta);
            else
              write(oline, string'("!! btn: btn number out of range"));
              writeline(output, oline);
            end if;
            
          when "expect" =>              -- expect n bytes data
            read_ea(iline, nbyte);
            read_ea(iline, enaesc);
            read_ea(iline, enaxon);
            writetimestamp(oline, CLK_CYCLE, ": expect");
            write(oline, nbyte, right, 5);
            write(oline, enaesc, right, 3);
            write(oline, enaxon, right, 3);
            writeline(output, oline);

            if nbyte > 0 then
              S2M_ACTIVE  <= '1';
              S2M_SIZE   <= nbyte;
            else
              S2M_ACTIVE  <= '0';
            end if;
            S2M_ENAESC <= enaesc;
            S2M_ENAXON <= enaxon;
            wait until rising_edge(CLKS);

          when "send  " =>              -- send n bytes data
            read_ea(iline, nbyte);
            read_ea(iline, enaesc);
            read_ea(iline, enaxon);
            writetimestamp(oline, CLK_CYCLE, ": send  ");
            write(oline, nbyte, right, 5);
            write(oline, enaesc, right, 3);
            write(oline, enaxon, right, 3);
            writeline(output, oline);
            bcnt := 0;
            itxdata := (others=>'0');
            
            wait until falling_edge(CLKS);
            while bcnt < nbyte loop
              while TXBUSY='1' or RTS_N='1' loop
                wait until falling_edge(CLKS);
              end loop;

              TXDATA <= itxdata;
              itxdata := slv(unsigned(itxdata) + 1);
              bcnt   := bcnt + 1;              
              
              TXENA  <= '1';
              wait until falling_edge(CLKS);
              TXENA  <= '0';             
              wait until falling_edge(CLKS);
            end loop;
            while TXBUSY='1' or RTS_N='1' loop -- wait till last char send...
              wait until falling_edge(CLKS);
            end loop;
            wait until rising_edge(CLKS);
            
          when "break " =>              -- send a break for n cycles
            read_ea(iline, idelta);
            writetimestamp(oline, CLK_CYCLE, ": break ");
            write(oline, idelta, right, 5);
            writeline(output, oline);
            -- send break for n cycles
            BREAK <= '1';
            waitclk(idelta);
            BREAK <= '0';
            -- wait for 3 bit cell width
            waitclk(3*to_integer(unsigned(CLKDIV)+1));
            -- send 'sync' character
            wait until falling_edge(CLKS);
            TXDATA <= "10000000";
            TXENA  <= '1';
            wait until falling_edge(CLKS);
            TXENA  <= '0';             
            wait until rising_edge(CLKS);
            
          when "clkdiv" =>              -- set new clock divider
            read_ea(iline, idelta);
            writetimestamp(oline, CLK_CYCLE, ": clkdiv");
            write(oline, idelta, right, 5);
            writeline(output, oline);
            CLKDIV <= slv(to_unsigned(idelta, CLKDIV'length));
            UART_RESET <= '1';
            wait until rising_edge(CLKS);
            UART_RESET <= '0';

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
    end loop;   -- file_loop

    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    -- extra wait for at least two character times (20 bit times)
    -- to allow tx and rx of the last character
    waitclk(20*(to_integer(unsigned(CLKDIV))+1));

    CLK_STOP_L <= '1';

    wait for 500 ns;                    -- allows dcm's to stop

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  CLK_STOP <= CLK_STOP_L;
  
  proc_moni: process
    variable oline : line;
    variable dclk : integer := 0;
    variable active_1 : slbit := '0';
    variable irxdata : slv8 := (others=>'0');
    variable irxeff : slv8 := (others=>'0');
    variable irxval : slbit := '0';
    variable doesc : slbit := '0';
    variable bcnt : integer := 0;
    variable xseen : slbit := '0';
  begin

    loop 
      wait until falling_edge(CLKS);

      M2S_XONSEEN  <= '0';
      M2S_XOFFSEEN <= '0';

      if S2M_ACTIVE='1' and active_1='0' then -- start expect message
        irxdata := (others=>'0');
        bcnt := 0;
      end if;

      if S2M_ACTIVE='0' and active_1='1' then -- end expect message
        if bcnt = S2M_SIZE then
          writetimestamp(oline, CLK_CYCLE, ": OK: message seen");
        else
          writetimestamp(oline, CLK_CYCLE, ": FAIL: missing chars, seen=");
          write(oline, bcnt, right, 5);
          write(oline, string'("  expect="));
          write(oline, S2M_SIZE, right, 5);
        end if;
        writeline(output, oline);
      end if;

      active_1 := S2M_ACTIVE;
      
      if RXVAL = '1' then
        writetimestamp(oline, CLK_CYCLE, ": char: ");
        write(oline, RXDATA, right, 10);
        write(oline, string'(" ("));
        writeoct(oline, RXDATA, right, 3);
        write(oline, string'(") dt="));
        write(oline, dclk, right, 4);

        irxeff := RXDATA;
        irxval := '1';
        if doesc = '1' then
          irxeff := not RXDATA;
          irxval := '1';
          doesc  := '0';
          write(oline, string'("  eff="));
          write(oline, irxeff, right, 10);
          write(oline, string'(" ("));
          writeoct(oline, irxeff, right, 3);
          write(oline, string'(")"));
        elsif S2M_ENAESC='1' and RXDATA=c_serport_xesc then
          doesc  := '1';
          irxval := '0';
          write(oline, string'("  XESC seen"));
        end if;

        xseen := '0';
        if S2M_ENAXON = '1' then
          if RXDATA = c_serport_xon then
            write(oline, string'("  XON seen"));
            M2S_XONSEEN <= '1';
            xseen := '1';
          elsif RXDATA = c_serport_xoff then
            write(oline, string'("  XOFF seen"));
            M2S_XOFFSEEN <= '1';            
            xseen := '1';
          end if;
        end if;
        
        if S2M_ACTIVE='1' and irxval='1' and xseen='0' then
          if irxeff = irxdata then
            write(oline, string'("  OK"));
          else
            write(oline, string'("  FAIL: expect="));
            write(oline, irxdata, right, 10);
          end if;
          irxdata := slv(unsigned(irxdata) + 1);
          bcnt := bcnt + 1;
        end if;
        
        writeline(output, oline);
        dclk := 0;

      end if;

      if RXERR = '1' then
        writetimestamp(oline, CLK_CYCLE, ": FAIL: RXERR='1'");
        writeline(output, oline);                   
      end if;
      
      dclk := dclk + 1;
   
    end loop;
    
  end process proc_moni;

end sim;
