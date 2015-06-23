-- $Id: tb_cdata2byte.vhd 599 2014-10-25 13:43:56Z mueller $
--
-- Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_cdata2byte - sim
-- Description:    Test bench for cdata2byte and byte2cdata
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 tbd_cdata2byte [UUT]
--
-- To test:        cdata2byte
--                 byte2cdata
--
-- Target Devices: generic
--
-- Verified (with tb_cdata2byte_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 2014-10-25   599  _ssim 0.31  17.1         sc6slx16   c: ok
-- 2014-10-25   599  -     0.31  -                       c: ok
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-10-25   599   1.1.1  use wait_* to control stim and moni timing
-- 2014-10-19   598   1.1    use simfifo with shared variables
-- 2014-10-18   597   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;
use work.comlib.all;

entity tb_cdata2byte is
end tb_cdata2byte;

architecture sim of tb_cdata2byte is
  
  constant clk_dsc : clock_dsc := (20 ns, 1 ns, 1 ns);
  constant clk_offset : time := 200 ns;
  
  signal CLK :  slbit := '0';
  signal RESET :  slbit := '0';
  
  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;
  
  signal C2B_ESCXON : slbit := '0';
  signal C2B_ESCFILL : slbit := '0';
  signal C2B_DI : slv9 := (others=>'0');
  signal C2B_ENA : slbit := '0';
  signal C2B_BUSY : slbit := '0';
  signal C2B_DO : slv8 := (others=>'0');
  signal C2B_VAL : slbit := '0';

  signal B2C_BUSY : slbit := '0';
  signal B2C_DO : slv9 := (others=>'0');
  signal B2C_VAL : slbit := '0';
  signal B2C_HOLD : slbit := '0';

  shared variable sv_sff_monc_cnt : natural := 0;
  shared variable sv_sff_monc_arr : simfifo_type(0 to 7, 7 downto 0);
  shared variable sv_sff_monb_cnt : natural := 0;
  shared variable sv_sff_monb_arr : simfifo_type(0 to 7, 8 downto 0);
  
begin

  CLKGEN : simclk
    generic map (
      PERIOD => clk_dsc.period,
      OFFSET => clk_offset)
    port map (
      CLK       => CLK,
      CLK_STOP  => CLK_STOP
    );
  
  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  UUT : entity work.tbd_cdata2byte
    port map (
      CLK           => CLK,
      RESET         => RESET,
      C2B_ESCXON    => C2B_ESCXON,
      C2B_ESCFILL   => C2B_ESCFILL,
      C2B_DI        => C2B_DI,
      C2B_ENA       => C2B_ENA,
      C2B_BUSY      => C2B_BUSY,
      C2B_DO        => C2B_DO,
      C2B_VAL       => C2B_VAL,
      B2C_BUSY      => B2C_BUSY,
      B2C_DO        => B2C_DO,
      B2C_VAL       => B2C_VAL,
      B2C_HOLD      => B2C_HOLD
    );

  proc_stim: process
    file fstim : text open read_mode is "tb_cdata2byte_stim";
    variable iline : line;
    variable oline : line;
    variable ok : boolean;
    variable dname : string(1 to 6) := (others=>' ');
    variable idel  : natural := 0;
    variable ilen  : natural := 0;
    variable nbusy : integer := 0;

    variable iesc     : slbit := '0';
    variable itxdata9 : slbit := '0';
    variable itxdata  : slv8  := (others=>'0');
    variable irxdata9 : slbit := '0';
    variable irxdata  : slv8  := (others=>'0');
    variable dat9     : slv9  := (others=>'0');
    
  begin

    wait_nextstim(CLK, clk_dsc);
    
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
            wait_nextstim(CLK, clk_dsc);
            RESET <= '0';
            wait_nextstim(CLK, clk_dsc);

          when ".wait " =>              -- .wait 
            read_ea(iline, idel);
            wait_nextstim(CLK, clk_dsc, idel);

          when "escxon" =>              -- escxon
            read_ea(iline, iesc);
            C2B_ESCXON <= iesc;
            
          when "escfil" =>              -- escfil
            read_ea(iline, iesc);
            C2B_ESCFILL <= iesc;
            
          when "bhold " =>              -- bhold
            read_ea(iline, idel);
            read_ea(iline, ilen);
            B2C_HOLD <= '1' after idel*clk_dsc.period,
                        '0' after (idel+ilen)*clk_dsc.period;
            
          when "data  " =>              -- data  
            read_ea(iline, itxdata9);
            readgen_ea(iline, itxdata);
            read_ea(iline, irxdata9);
            if irxdata9 = '0' then
              simfifo_put(sv_sff_monc_cnt, sv_sff_monc_arr, itxdata);
            else
              readgen_ea(iline, irxdata);
              simfifo_put(sv_sff_monc_cnt, sv_sff_monc_arr, c_cdata_escape);
              simfifo_put(sv_sff_monc_cnt, sv_sff_monc_arr, irxdata);
            end if;
            dat9 := itxdata9 & itxdata;
            simfifo_put(sv_sff_monb_cnt, sv_sff_monb_arr, dat9);

            C2B_DI  <= dat9;
            C2B_ENA <= '1';

            wait_stim2moni(CLK, clk_dsc);
            wait_untilsignal(CLK, clk_dsc, C2B_BUSY, '0', nbusy);
            
            writetimestamp(oline, CLK_CYCLE, ": stim ");
            write(oline, itxdata9, right, 2);
            write(oline, itxdata, right,  9);
            writeoptint(oline, "  nbusy=", nbusy);
            writeline(output, oline);

            wait_nextstim(CLK, clk_dsc);
            C2B_ENA <= '0';

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

    writetimestamp(oline, CLK_CYCLE, ": DONE ");
    writeline(output, oline);

    wait_nextstim(CLK, clk_dsc, 12);

    CLK_STOP <= '1';

    wait;                               -- suspend proc_stim forever
                                        -- clock is stopped, sim will end

  end process proc_stim;

  
  proc_monc: process
    variable oline : line;
    variable nhold : integer := 0;
  begin

    loop 
      wait_nextmoni(CLK, clk_dsc);
      
      if C2B_VAL = '1' then
        if B2C_BUSY = '1' then        -- c2b_hold = b2c_busy !
          nhold := nhold + 1;
        else
          writetimestamp(oline, CLK_CYCLE, ": monc ");
          write(oline, string'("  "));
          write(oline, C2B_DO,   right, 9);
          writeoptint(oline, "  nhold=", nhold);
          simfifo_writetest(oline, sv_sff_monc_cnt, sv_sff_monc_arr, C2B_DO);
          writeline(output, oline);
          nhold := 0;
        end if;
      end if;
      
    end loop;
    
  end process proc_monc;


  proc_monb: process
    variable oline : line;
    variable nhold : integer := 0;
  begin

    loop 
      wait_nextmoni(CLK, clk_dsc);

      if B2C_VAL = '1' then
        if B2C_HOLD = '1' then
          nhold := nhold + 1;
        else
          writetimestamp(oline, CLK_CYCLE, ": monb ");
          write(oline, B2C_DO(8), right, 2);
          write(oline, B2C_DO(7 downto 0),   right, 9);
          writeoptint(oline, "  nhold=", nhold);
          simfifo_writetest(oline, sv_sff_monb_cnt, sv_sff_monb_arr, B2C_DO);
          writeline(output, oline);
          nhold := 0;
        end if;
      end if;
      
    end loop;
    
  end process proc_monb;

end sim;
