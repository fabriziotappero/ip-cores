-- $Id: sn_humanio_demu.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    sn_humanio_demu - syn
-- Description:    All BTN, SWI, LED handling for atlys
--
-- Dependencies:   bpgen/bp_swibtnled
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-10-10   413 13.1    O40d xc3s1000-4    67   66    0   55 s  6.1 ns 
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-10-11   414   1.0.1  take care of RESET BTN being active low
-- 2011-10-10   413   1.0    Initial version
------------------------------------------------------------------------------
--    

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.bpgenlib.all;

-- ----------------------------------------------------------------------------

entity sn_humanio_demu is               -- human i/o handling: swi,btn,led only
  generic (
    DEBOUNCE : boolean := true);        -- instantiate debouncer for SWI,BTN
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    SWI : out slv8;                     -- switch settings, debounced
    BTN : out slv4;                     -- button settings, debounced
    LED : in slv8;                      -- led data
    DSP_DAT : in slv16;                 -- display data
    DSP_DP : in slv4;                   -- display decimal points
    I_SWI : in slv8;                    -- pad-i: switches
    I_BTN : in slv6;                    -- pad-i: buttons
    O_LED : out slv8                    -- pad-o: leds
  );
end sn_humanio_demu;

architecture syn of sn_humanio_demu is
  
  constant c_mode_led  : slv2 := "00";
  constant c_mode_dp   : slv2 := "01";
  constant c_mode_datl : slv2 := "10";
  constant c_mode_dath : slv2 := "11";

  type regs_type is record
    mode : slv2;                        -- current mode
    cnt : slv9;                         -- msec counter
    up_1 : slbit;                       -- btn up last cycle
    dn_1 : slbit;                       -- btn dn last cycle
    led : slv8;                         -- led state
  end record regs_type;

  constant regs_init : regs_type := (
    c_mode_led,                         -- mode
    (others=>'0'),                      -- cnt
    '0','0',                            -- up_1, dn_1
    (others=>'0')                       -- led
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  signal BTN_HW :  slv6 := (others=>'0');
  signal LED_HW :  slv8 := (others=>'0');
  
begin

 HIO : bp_swibtnled
    generic map (
      SWIDTH   => 8,
      BWIDTH   => 6,
      LWIDTH   => 8,
      DEBOUNCE => DEBOUNCE)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      SWI     => SWI,                   
      BTN     => BTN_HW,                   
      LED     => LED_HW,                   
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED
    );

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

  proc_next: process (R_REGS, CE_MSEC, LED, DSP_DAT, DSP_DP, BTN_HW)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable ibtn : slv4 := (others=>'0');
    variable iup : slbit := '0';
    variable idn : slbit := '0';
    variable ipuls : slbit := '0';

  begin
    r := R_REGS;
    n := R_REGS;

    ibtn(0) := not BTN_HW(5);           -- RESET button is act. low !
    ibtn(1) := BTN_HW(1);
    ibtn(2) := BTN_HW(4);
    ibtn(3) := BTN_HW(3);
    iup     := BTN_HW(0);
    idn     := BTN_HW(2);

    ipuls := '0';
    

    n.up_1 := iup;
    n.dn_1 := idn;

    if iup='0' and idn='0' then
      n.cnt := (others=>'0');
    else
      if CE_MSEC = '1' then
        n.cnt := slv(unsigned(r.cnt) + 1);
        if r.cnt = "111111111" then
          ipuls := '1';
        end if;
      end if;
    end if;

    if iup='1' or idn='1' then
      n.led := (others=>'0');
      case r.mode is
        when c_mode_led  => n.led(0) := '1';
        when c_mode_dp   => n.led(1) := '1';
        when c_mode_datl => n.led(2) := '1';
        when c_mode_dath => n.led(3) := '1';
        when others => null;
      end case;
      
      if    iup='1' and (r.up_1='0' or ipuls='1') then
        n.mode := slv(unsigned(r.mode) + 1);
      elsif idn='1' and (r.dn_1='0' or ipuls='1') then
        n.mode := slv(unsigned(r.mode) - 1);
      end if;
      
    else
      case r.mode is
        when c_mode_led  => n.led := LED;
        when c_mode_dp   => n.led := "0000" & DSP_DP;
        when c_mode_datl => n.led := DSP_DAT( 7 downto 0);
        when c_mode_dath => n.led := DSP_DAT(15 downto 8);
        when others => null;
      end case;
    end if;
      
    N_REGS <= n;

    BTN    <= ibtn;
    LED_HW <= r.led;
    
  end process proc_next;

end syn;
