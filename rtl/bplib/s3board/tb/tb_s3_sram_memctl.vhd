-- $Id: tb_s3_sram_memctl.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    tb_s3_sram_memctl - sim
-- Description:    Test bench for s3_sram_memctl
--
-- Dependencies:   vlib/simlib/simclk
--                 vlib/simlib/simclkcnt
--                 bplib/issi/is61lv25616al
--                 s3_sram_memctl [UUT]
--
-- To test:        s3_sram_memctl
--                 
-- Verified (with tb_s3_sram_memctl_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2007-12-16   101  _ssim 0.26  8.1.03 I27   xc3s1000   c:ok
-- 2007-12-16   101  -     0.26  -            -          c:ok
--
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   1.1    use new simclk/simclkcnt
-- 2011-11-21   432   1.0.6  now numeric_std clean
-- 2010-05-23   293   1.0.5  output # busy cycles; change CHK pipeline logic
-- 2010-05-16   291   1.0.4  rename tb_memctl_s3sram->tb_s3_sram_memctl
-- 2008-03-24   129   1.0.3  CLK_CYCLE now 31 bits
-- 2008-02-17   117   1.0.2  use req,we rather req_r,req_w interface
-- 2008-01-20   113   1.0.1  rename memdrv -> memctl_s3sram
-- 2007-12-15   101   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.s3boardlib.all;
use work.simlib.all;

entity tb_s3_sram_memctl is
end tb_s3_sram_memctl;

architecture sim of tb_s3_sram_memctl is
  
  signal CLK   : slbit := '0';
  signal RESET : slbit := '0';
  signal REQ   : slbit := '0';
  signal WE    : slbit := '0';
  signal BUSY  : slbit := '0';
  signal ACK_R : slbit := '0';
  signal ACK_W : slbit := '0';
  signal ACT_R : slbit := '0';
  signal ACT_W : slbit := '0';
  signal ADDR : slv18 := (others=>'0');
  signal BE : slv4  := (others=>'0');
  signal DI : slv32 := (others=>'0');
  signal DO : slv32 := (others=>'0');
  signal O_MEM_CE_N : slv2   := (others=>'0');
  signal O_MEM_BE_N : slv4   := (others=>'0');
  signal O_MEM_WE_N : slbit  := '0';
  signal O_MEM_OE_N : slbit  := '0';
  signal O_MEM_ADDR  : slv18 := (others=>'0');
  signal IO_MEM_DATA : slv32 := (others=>'0');

  signal R_MEMON : slbit  := '0';
  signal N_CHK_DATA : slbit  := '0';
  signal N_REF_DATA : slv32 := (others=>'0');
  signal N_REF_ADDR : slv18 := (others=>'0');
  signal R_CHK_DATA_AL : slbit  := '0';
  signal R_REF_DATA_AL : slv32 := (others=>'0');
  signal R_REF_ADDR_AL : slv18 := (others=>'0');
  signal R_CHK_DATA_DL : slbit  := '0';
  signal R_REF_DATA_DL : slv32 := (others=>'0');
  signal R_REF_ADDR_DL : slv18 := (others=>'0');
  
  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;

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
      CLK => CLK,
      CLK_STOP => CLK_STOP
    );

  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  MEM_L : entity work.is61lv25616al
    port map (
      CE_N => O_MEM_CE_N(0),
      OE_N => O_MEM_OE_N,
      WE_N => O_MEM_WE_N,
      UB_N => O_MEM_BE_N(1),
      LB_N => O_MEM_BE_N(0),
      ADDR => O_MEM_ADDR,
      DATA => IO_MEM_DATA(15 downto 0)
    );
  
  MEM_U : entity work.is61lv25616al
    port map (
      CE_N => O_MEM_CE_N(1),
      OE_N => O_MEM_OE_N,
      WE_N => O_MEM_WE_N,
      UB_N => O_MEM_BE_N(3),
      LB_N => O_MEM_BE_N(2),
      ADDR => O_MEM_ADDR,
      DATA => IO_MEM_DATA(31 downto 16)
    );
  
  UUT : s3_sram_memctl
    port map (
      CLK     => CLK,
      RESET   => RESET,
      REQ     => REQ,
      WE      => WE,
      BUSY    => BUSY,
      ACK_R   => ACK_R,
      ACK_W   => ACK_W,
      ACT_R   => ACT_R,
      ACT_W   => ACT_W,
      ADDR    => ADDR,
      BE      => BE,
      DI      => DI,
      DO      => DO,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  proc_stim: process
    file fstim : text open read_mode is "tb_s3_sram_memctl_stim";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idelta : integer := 0;
    variable iaddr : slv18 := (others=>'0');
    variable idata : slv32 := (others=>'0');
    variable ibe   : slv4 := (others=>'0');
    variable ival  : slbit := '0';
    variable nbusy : integer := 0;

  begin
    
    wait for clock_offset - setup_time;

    file_loop: while not endfile(fstim) loop

      readline (fstim, iline);
      
      readcomment(iline, ok);
      next file_loop when ok;

      readword(iline, dname, ok);
      if ok then
        case dname is
          when ".memon" =>              -- .memon
            read_ea(iline, ival);
            R_MEMON <= ival;
            wait for 2*clock_period;
            
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
            
          when "read  " =>              -- read
            readgen_ea(iline, iaddr, 16);
            readgen_ea(iline, idata, 16);
            ADDR <= iaddr;
            REQ <= '1';
            WE  <= '0';

            writetimestamp(oline, CLK_CYCLE, ": stim read ");
            writegen(oline, iaddr, right, 6, 16);
            write(oline, string'("     "));
            writegen(oline, idata, right, 9, 16);

            nbusy := 0;
            while BUSY = '1' loop
              nbusy := nbusy + 1;
              wait for clock_period;
            end loop;

            write(oline, string'("  nbusy="));
            write(oline, nbusy, right, 2);
            writeline(output, oline);

            N_CHK_DATA <= '1', '0' after clock_period;
            N_REF_DATA <= idata;
            N_REF_ADDR <= iaddr;

            wait for clock_period;
            REQ <= '0';
            
          when "write " =>              -- write
            readgen_ea(iline, iaddr, 16);
            read_ea(iline, ibe);
            readgen_ea(iline, idata, 16);
            ADDR <= iaddr;
            BE   <= ibe;
            DI   <= idata;
            REQ  <= '1';
            WE   <= '1';
            
            writetimestamp(oline, CLK_CYCLE, ": stim write");
            writegen(oline, iaddr, right, 6, 16);
            writegen(oline, ibe  , right, 5,  2);
            writegen(oline, idata, right, 9, 16);

            nbusy := 0;
            while BUSY = '1' loop
              nbusy := nbusy + 1;
              wait for clock_period;
            end loop;

            write(oline, string'("  nbusy="));
            write(oline, nbusy, right, 2);
            writeline(output, oline);

            wait for clock_period;
            REQ <= '0';            
            
          when others =>                -- bad directive
            write(oline, string'("?? unknown directive: "));
            write(oline, dname);
            writeline(output, oline);
            report "aborting" severity failure;
        end case;
      else
        report "failed to find command" severity failure;
        
      end if;

      testempty_ea(iline);

    end loop; -- file fstim

    wait for 10*clock_period;

    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    CLK_STOP <= '1';

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  
  proc_moni: process
    variable oline : line;
  begin

    loop 
      wait until rising_edge(CLK);

      if ACK_R = '1' then
        writetimestamp(oline, CLK_CYCLE, ": moni ");
        writegen(oline, DO, right, 9, 16);
        if R_CHK_DATA_DL = '1' then
          write(oline, string'("  CHECK"));
          if R_REF_DATA_DL = DO then
            write(oline, string'(" OK"));
          else
            write(oline, string'(" FAIL, exp="));
            writegen(oline, R_REF_DATA_DL, right, 9, 16);
            write(oline, string'(" for a="));
            writegen(oline, R_REF_ADDR_DL, right, 5, 16);
          end if;
          R_CHK_DATA_DL <= '0';
        end if;
        writeline(output, oline);
      end if;

      if R_CHK_DATA_AL = '1' then
        R_CHK_DATA_DL <= R_CHK_DATA_AL;
        R_REF_DATA_DL <= R_REF_DATA_AL;
        R_REF_ADDR_DL <= R_REF_ADDR_AL;
        R_CHK_DATA_AL <= '0';
      end if;
      if N_CHK_DATA = '1' then
        R_CHK_DATA_AL <= N_CHK_DATA;
        R_REF_DATA_AL <= N_REF_DATA;
        R_REF_ADDR_AL <= N_REF_ADDR;
      end if;
      
    end loop;
    
  end process proc_moni;


  proc_memon: process
    variable oline : line;
  begin

    loop 
      wait until rising_edge(CLK);

      if R_MEMON = '1' then
        writetimestamp(oline, CLK_CYCLE, ": mem  ");
        write(oline, string'(" ce="));
        write(oline, not O_MEM_CE_N, right, 2);
        write(oline, string'(" be="));
        write(oline, not O_MEM_BE_N, right, 4);
        write(oline, string'(" we="));
        write(oline, not O_MEM_WE_N, right);
        write(oline, string'(" oe="));
        write(oline, not O_MEM_OE_N, right);
        write(oline, string'(" a="));
        writegen(oline, O_MEM_ADDR, right, 5, 16);
        write(oline, string'(" d="));
        writegen(oline, IO_MEM_DATA, right, 8, 16);
        writeline(output, oline);
      end if;
      
    end loop;
    
  end process proc_memon;


end sim;
