-- $Id: tst_snhumanio.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    tst_snhumanio - syn
-- Description:    simple stand-alone tester for sn_humanio
--
-- Dependencies:   -
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-10-15   416   1.0.2  fix sensitivity list of proc_next
-- 2011-10-08   412   1.0.1  use better rndm init (so that swi=0 is non-const)
-- 2011-09-17   410   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.comlib.all;

-- ----------------------------------------------------------------------------

entity tst_snhumanio is                 -- tester for rlink
  generic (
    BWIDTH : positive := 4);            -- BTN port width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_MSEC : in slbit;                 -- msec pulse
    SWI : in slv8;                      -- switch settings
    BTN : in slv(BWIDTH-1 downto 0);    -- button settings
    LED : out slv8;                     -- led data
    DSP_DAT : out slv16;                -- display data
    DSP_DP : out slv4                   -- display decimal points    
  );
end tst_snhumanio;

architecture syn of tst_snhumanio is

  constant c_mode_rndm : slv2 := "00";
  constant c_mode_cnt  : slv2 := "01";
  constant c_mode_swi  : slv2 := "10";
  constant c_mode_btst : slv2 := "11";

  type regs_type is record
    mode : slv2;                        -- current mode
    allon : slbit;                      -- all LEDs on if set
    cnt : slv16;                        -- counter
    tcnt : slv16;                       -- swi/btn toggle counter
    rndm : slv8;                        -- random number
    swi_1 : slv8;                       -- last SWI state
    btn_1 : slv(BWIDTH-1 downto 0);     -- last BTN state
    led : slv8;                         -- LED output state
    dsp : slv16;                        -- display data
    dp : slv4;                          -- display decimal points
  end record regs_type;

  -- the rndm start value is /= 0 because a seed of 0 with a SWI setting of 0
  -- will result in a 0-0-0 sequence. The 01010101 start will get trapped in a
  -- constant sequence with a 01100011 switch setting, which is rather unlikely.
  constant rndminit : slv8 := "01010101";
  
  constant btnzero  : slv(BWIDTH-1 downto 0) := (others=>'0');
  
  constant regs_init : regs_type := (
    c_mode_rndm,                        -- mode
    '0',                                -- allon
    (others=>'0'),                      -- cnt
    (others=>'0'),                      -- tcnt
    rndminit,                           -- rndm
    (others=>'0'),                      -- swi_1
    btnzero,                            -- btn_1
    (others=>'0'),                      -- led
    (others=>'0'),                      -- dsp
    (others=>'0')                       -- dp
    
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  signal BTN4 : slbit := '0';
  
begin

  assert BWIDTH>=4
    report "assert(BWIDTH>=4): at least 4 BTNs available"
    severity failure;

  B4YES: if BWIDTH > 4 generate
    BTN4 <= BTN(4);
  end generate B4YES;
  B4NO: if BWIDTH = 4 generate
    BTN4 <= '0';
  end generate B4NO;
  
  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, CE_MSEC, SWI, BTN, BTN4)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable btn03 : slv4 := (others=>'0');

  begin
    r := R_REGS;
    n := R_REGS;

    n.swi_1 := SWI;
    n.btn_1 := BTN;

    if SWI/=r.swi_1 or BTN/=r.btn_1 then
      n.tcnt := slv(unsigned(r.tcnt) + 1);
    end if;

    btn03 := BTN(3 downto 0);
    n.allon := BTN4;

    if unsigned(BTN) /= 0 then          -- is a button being pressed ?
      if r.mode /= c_mode_btst then       -- not in btst mode
        case btn03 is
          when "0001" =>                    -- 0001 single button -> rndm mode
            n.mode := c_mode_rndm;
            n.rndm := rndminit;
            
          when "0010" =>                    -- 0010 single button -> cnt mode
            n.mode := c_mode_cnt;

          when "0100" =>                    -- 0100 single button -> swi mode
            n.mode := c_mode_swi;
                         
          when "1000" =>                    -- 1001 single button -> btst mode
            n.mode := c_mode_btst;
            n.tcnt := (others=>'0');
                         
          when others =>                    -- any 2+ button combo -> led test
            n.allon := '1';
        end case;

      else                                -- button press in btst mode

        case btn03 is
          when "1001" =>                    -- 1001 double btn -> rndm mode 
            n.mode := c_mode_rndm;
          when "1010" =>                    -- 1010 double btn -> rndm cnt
            n.mode := c_mode_cnt;
          when "1100" =>                    -- 1100 double btn -> rndm swi 
            n.mode := c_mode_swi;
          when others => null;
        end case;
        
      end if;

    else                                -- no button being pressed

      if CE_MSEC = '1' then               -- on every usec
        n.cnt := slv(unsigned(r.cnt) + 1);  -- inc counter
        if unsigned(r.cnt(8 downto 0)) = 0 then  -- every 1/2 sec (approx.)
          n.rndm := crc8_update(r.rndm, SWI);      -- update rndm state
        end if;
      end if;
    end if;

    if r.allon = '1' then               -- if led test selected
      n.led := (others=>'1');             -- all led,dsp,dp on
      n.dsp := (others=>'1');
      n.dp  := (others=>'1');

    else                                -- no led test, normal output

      case r.mode is
        when c_mode_rndm =>
          n.led := r.rndm;
          n.dsp(7 downto 0)  :=     r.rndm;
          n.dsp(15 downto 8) := not r.rndm;
         
        when c_mode_cnt  =>
          n.led := r.cnt(14 downto 7);
          n.dsp := r.cnt;
          
        when c_mode_swi  =>
          n.led := SWI;
          n.dsp(7 downto 0)  :=     SWI;
          n.dsp(15 downto 8) := not SWI;

        when c_mode_btst =>
          n.led := SWI;
          n.dsp := r.tcnt;
          
        when others => null;
      end case;

      n.dp := BTN(3 downto 0);
      
    end if;
    
    N_REGS <= n;

    LED     <= r.led;
    DSP_DAT <= r.dsp;
    DSP_DP  <= r.dp;
    
  end process proc_next;

    
end syn;
