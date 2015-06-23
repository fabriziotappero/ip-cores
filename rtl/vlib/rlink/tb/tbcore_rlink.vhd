-- $Id: tbcore_rlink.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2010-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tbcore_rlink - sim
-- Description:    Core for a rlink_cext based test bench
--
-- Dependencies:   simlib/simclkcnt
--
-- To test:        generic, any rlink_cext based target
--
-- Target Devices: generic
-- Tool versions:  xst 11.4-14.7; ghdl 0.26-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-01-04   469   3.1.2  use 1ns wait for .sinit to allow simbus debugging
-- 2011-12-25   445   3.1.1  add SB_ init drivers to avoid SB_VAL='U' at start
-- 2011-12-23   444   3.1    redo clock handling, remove simclk, CLK now input
-- 2011-11-19   427   3.0.1  now numeric_std clean
-- 2010-12-29   351   3.0    rename rritb_core->tbcore_rlink; use rbv3 naming
-- 2010-06-05   301   1.1.2  rename .rpmon -> .rbmon
-- 2010-05-02   287   1.1.1  rename config command .sdata -> .sinit;
--                           use sbcntl_sbf_(cp|rp)mon defs, use rritblib;
-- 2010-04-25   283   1.1    new clk handling in proc_stim, wait period-setup
-- 2010-04-24   282   1.0    Initial version (from vlib/s3board/tb/tb_s3board)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.simbus.all;
use work.rblib.all;
use work.rlinklib.all;
use work.rlinktblib.all;
use work.rlink_cext_vhpi.all;

entity tbcore_rlink is                  -- core of rlink_cext based test bench
  port (
    CLK : in slbit;                     -- control interface clock
    CLK_STOP : out slbit;               -- clock stop trigger
    RX_DATA : out slv8;                 -- read data         (data ext->tb)
    RX_VAL : out slbit;                 -- read data valid   (data ext->tb)
    RX_HOLD : in slbit;                 -- read data hold    (data ext->tb)
    TX_DATA : in slv8;                  -- write data        (data tb->ext)
    TX_ENA : in slbit                   -- write data enable (data tb->ext)
  );
end tbcore_rlink;

architecture sim of tbcore_rlink is
  
  signal CLK_CYCLE : integer := 0;

begin
  
  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  proc_conf: process
    file fconf : text open read_mode is "rlink_cext_conf";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable ien : slbit := '0';
    variable ibit : integer := 0;
    variable iaddr : slv8 := (others=>'0');
    variable idata : slv16 := (others=>'0');
  begin
    
    SB_CNTL <= (others=>'L');
    SB_VAL  <= 'L';
    SB_ADDR <= (others=>'L');
    SB_DATA <= (others=>'L');
  
    file_loop: while not endfile(fconf) loop
      
      readline (fconf, iline);
      readcomment(iline, ok);
      next file_loop when ok;
      readword(iline, dname, ok);
      
      if ok then
        case dname is

          when ".scntl" =>              -- .scntl
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

          when ".rlmon" =>              -- .rlmon
            read_ea(iline, ien);
            if ien = '1' then
              SB_CNTL(sbcntl_sbf_rlmon) <= 'H';
            else
              SB_CNTL(sbcntl_sbf_rlmon) <= 'L';
            end if;

          when ".rbmon" =>              -- .rbmon
            read_ea(iline, ien);
            if ien = '1' then
              SB_CNTL(sbcntl_sbf_rbmon) <= 'H';
            else
              SB_CNTL(sbcntl_sbf_rbmon) <= 'L';
            end if;

          when ".sinit" =>              -- .sinit
            readgen_ea(iline, iaddr, 8);
            readgen_ea(iline, idata, 8);
            SB_ADDR <= iaddr;
            SB_DATA <= idata;
            SB_VAL  <= 'H';
            wait for 1 ns;
            SB_VAL  <= 'L';
            SB_ADDR <= (others=>'L');
            SB_DATA <= (others=>'L');
            wait for 1 ns;

          when others =>                -- bad command
            write(oline, string'("?? unknown command: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;
      else
        report "failed to find command" severity failure;
      end if;

      testempty_ea(iline);
      
    end loop; -- file_loop:

    SB_VAL  <= 'L';
    SB_ADDR <= (others=>'L');
    SB_DATA <= (others=>'L');

    wait;     -- halt process here 
    
  end process proc_conf;
    
  proc_stim: process
    variable irxint : integer := 0;
    variable irxslv : slv24 := (others=>'0');
    variable ibit : integer := 0;
    variable oline : line;
    variable r_sb_cntl : slv16 := (others=>'Z');
    variable iaddr : slv8 := (others=>'0');
    variable idata : slv16 := (others=>'0');
  begin

    -- setup init values for all output ports
    CLK_STOP <= '0';
    RX_DATA  <= (others=>'0');
    RX_VAL   <= '0';

    SB_VAL  <= 'Z';
    SB_ADDR <= (others=>'Z');
    SB_DATA <= (others=>'Z');

    -- wait for 10 clock cycles (design run up)
    for i in 0 to 9 loop
      wait until rising_edge(CLK);
    end loop;  -- i
    
    stim_loop: loop

      wait until falling_edge(CLK);

      SB_ADDR <= (others=>'Z');
      SB_DATA <= (others=>'Z');

      RX_VAL <= '0';

      if RX_HOLD = '0'  then
        irxint := rlink_cext_getbyte(CLK_CYCLE);
        if irxint >= 0 then
          if irxint <= 16#ff# then      -- normal data byte
            RX_DATA <= slv(to_unsigned(irxint, 8));
            RX_VAL  <= '1';
          elsif irxint >= 16#1000000# then  -- out-of-band message
            irxslv := slv(to_unsigned(irxint mod 16#1000000#, 24));
            iaddr := irxslv(23 downto 16);
            idata := irxslv(15 downto  0);
            writetimestamp(oline, CLK_CYCLE, ": OOB-MSG");
            write(oline, irxslv(23 downto 16), right, 9);
            write(oline, irxslv(15 downto  8), right, 9);
            write(oline, irxslv( 7 downto  0), right, 9);
            write(oline, string'(" : "));
            writeoct(oline, iaddr, right, 3);
            writeoct(oline, idata, right, 7);
            writeline(output, oline);
            if unsigned(iaddr) = 0 then
              ibit := to_integer(unsigned(idata(15 downto 8)));
              r_sb_cntl(ibit) := idata(0);
            else
              SB_ADDR <= iaddr;
              SB_DATA <= idata;
              SB_VAL  <= '1';
              wait for 0 ns;
              SB_VAL  <= 'Z';
              wait for 0 ns;
            end if;
          end if;
        elsif irxint = -1 then           -- end-of-file seen
          exit stim_loop;
        else
          report "rlink_cext_getbyte error: " & integer'image(-irxint)
            severity failure;
        end if;
      end if;
      
      SB_CNTL <= r_sb_cntl;
      
    end loop;
    
    -- wait for 50 clock cycles (design run down)
    for i in 0 to 49 loop
      wait until rising_edge(CLK);
    end loop;  -- i
    
    CLK_STOP <= '1';
    
    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  proc_moni: process
    variable itxdata : integer := 0;
    variable itxrc : integer := 0;
    variable oline : line;
  begin
    
    loop
      wait until rising_edge(CLK);
      if TX_ENA = '1' then
        itxdata := to_integer(unsigned(TX_DATA));
        itxrc := rlink_cext_putbyte(itxdata);
        assert itxrc=0
          report "rlink_cext_putbyte error: "  & integer'image(itxrc)
          severity failure;
      end if;

    end loop;
    
  end process proc_moni;

end sim;
