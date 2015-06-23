-- $Id: tb_nx_cram_memctl.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_nx_cram_memctl - sim
-- Description:    Test bench for nx_cram_memctl
--
-- Dependencies:   vlib/simlib/simclk
--                 vlib/simlib/simclkcnt
--                 bplib/micron/mt45w8mw16b
--                 tbd_nx_cram_memctl        [UUT, abstact]
--
-- To test:        nx_cram_memctl_as  (via tbd_nx_cram_memctl_as)
--                 
-- Target Devices: generic
-- Tool versions:  xst 11.4-14.7; ghdl 0.26-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-23   444   1.4    use new simclk/simclkcnt
-- 2011-11-26   433   1.3    renamed from tb_n2_cram_memctl
-- 2011-11-21   432   1.2    now numeric_std clean; update O_FLA_CE_N usage
-- 2010-05-30   297   1.1    use abstact uut tbd_nx_cram_memctl
-- 2010-05-23   293   1.0    Initial version (derived from tb_s3_sram_memctl)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;

entity tb_nx_cram_memctl is
end tb_nx_cram_memctl;

architecture sim of tb_nx_cram_memctl is
  
component tbd_nx_cram_memctl is         -- CRAM driver (abstract) [tb design]
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY : out slbit;                   -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR : in slv22;                    -- address  (32 bit word address)
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32;                     -- data out (memory view)
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N : out slbit;            -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16           -- cram: data lines
  );
end component;

  signal CLK   : slbit := '0';
  signal RESET : slbit := '0';
  signal REQ   : slbit := '0';
  signal WE    : slbit := '0';
  signal BUSY  : slbit := '0';
  signal ACK_R : slbit := '0';
  signal ACK_W : slbit := '0';
  signal ACT_R : slbit := '0';
  signal ACT_W : slbit := '0';
  signal ADDR : slv22 := (others=>'0');
  signal BE : slv4  := (others=>'0');
  signal DI : slv32 := (others=>'0');
  signal DO : slv32 := (others=>'0');
  signal O_MEM_CE_N : slbit  := '0';
  signal O_MEM_BE_N : slv2   := (others=>'0');
  signal O_MEM_WE_N : slbit  := '0';
  signal O_MEM_OE_N : slbit  := '0';
  signal O_MEM_ADV_N : slbit  := '0';
  signal O_MEM_CLK : slbit  := '0';
  signal O_MEM_CRE : slbit  := '0';
  signal I_MEM_WAIT : slbit  := '0';
  signal O_MEM_ADDR  : slv23 := (others=>'0');
  signal IO_MEM_DATA : slv16 := (others=>'0');

  signal R_MEMON : slbit  := '0';
  signal N_CHK_DATA : slbit  := '0';
  signal N_REF_DATA : slv32 := (others=>'0');
  signal N_REF_ADDR : slv22 := (others=>'0');
  signal R_CHK_DATA_AL : slbit  := '0';
  signal R_REF_DATA_AL : slv32 := (others=>'0');
  signal R_REF_ADDR_AL : slv22 := (others=>'0');
  signal R_CHK_DATA_DL : slbit  := '0';
  signal R_REF_DATA_DL : slv32 := (others=>'0');
  signal R_REF_ADDR_DL : slv22 := (others=>'0');
  
  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;

  constant clock_period : time :=  20 ns;
  constant clock_offset : time := 200 ns;
  constant setup_time : time :=  7.5 ns;   -- compatible ucf for
  constant c2out_time : time := 12.0 ns;   -- tbd_nx_cram_memctl_as

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

  MEM : entity work.mt45w8mw16b
    port map (
      CLK   => O_MEM_CLK,
      CE_N  => O_MEM_CE_N,
      OE_N  => O_MEM_OE_N,
      WE_N  => O_MEM_WE_N,
      UB_N  => O_MEM_BE_N(1),
      LB_N  => O_MEM_BE_N(0),
      ADV_N => O_MEM_ADV_N,
      CRE   => O_MEM_CRE,
      MWAIT => I_MEM_WAIT,
      ADDR  => O_MEM_ADDR,
      DATA  => IO_MEM_DATA
    );
  
  UUT : tbd_nx_cram_memctl
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
      O_MEM_CLK   => O_MEM_CLK,
      O_MEM_ADV_N => O_MEM_ADV_N,
      O_MEM_CRE   => O_MEM_CRE,
      I_MEM_WAIT  => I_MEM_WAIT,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  proc_stim: process
    file fstim : text open read_mode is "tb_nx_cram_memctl_stim";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idelta : integer := 0;
    variable iaddr : slv22 := (others=>'0');
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
            writegen(oline, iaddr, right, 7, 16);
            write(oline, string'("     "));
            writegen(oline, idata, right, 9, 16);

            nbusy := 0;
            while BUSY='1' loop
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
            writegen(oline, iaddr, right, 7, 16);
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
        writegen(oline, O_MEM_ADDR, right, 6, 16);
        write(oline, string'(" d="));
        writegen(oline, IO_MEM_DATA, right, 4, 16);
        writeline(output, oline);
      end if;
      
    end loop;
    
  end process proc_memon;


end sim;
