------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity:      generic_ddr_phy
-- File:        ddr_phy_inferred.vhd
-- Author:      Nils-Johan Wessman - Gaisler Research
-- Description: Generic DDR PHY
------------------------------------------------------------------------------

--###################################################################################
-- Generic DDR Output Register
--###################################################################################
library ieee;
use ieee.std_logic_1164.all;
entity gen_ddr_phy_oreg is
  generic(
    sameedge : integer := 0
         );
  port(
    Q : out std_ulogic;
    C0 : in std_ulogic;
    C1 : in std_ulogic;
    CE : in std_ulogic;
    D0 : in std_ulogic;
    D1 : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic
      );
end;

architecture rtl of gen_ddr_phy_oreg is
signal tmpD1, Q1, Q2 : std_logic;
begin
  same_edge : if sameedge = 0 generate
    tmpD1 <= D1;
  end generate;
  
  nosame_edge : if sameedge = 1 generate
    reg : process(C0)
    begin
      if rising_edge(C0) then
          tmpD1 <= D1;
      end if;
    end process;
  end generate;

  reg : process(C0)
  begin
    if rising_edge(C0) then
      Q1 <= D0; 
    end if;
  end process;

  regn : process(C0)
  begin
    if falling_edge(C0) then
      Q2 <= tmpD1;
    end if;
  end process;

  Q <= Q1 when C0 = '1' else Q2;

end;

--###################################################################################
-- Generic DDR Inout Register
--###################################################################################
library ieee;
use ieee.std_logic_1164.all;
entity gen_ddr_phy_ireg is
  port(
    Q0 : out std_ulogic;
    Q1 : out std_ulogic;
    C0 : in std_ulogic;
    C1 : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic
      );
end;

architecture rtl of gen_ddr_phy_ireg is
begin
  reg0 : process(C0)
  begin
    if rising_edge(C0) then
      if R = '1' then Q0 <= '0';
      elsif S = '1' then Q0 <= '1';
      elsif CE = '1' then Q0 <= D; end if;
    end if;
  end process;
  reg1 : process(C1)
  begin
    if rising_edge(C1) then
      if R = '1' then Q1 <= '0';
      elsif S = '1' then Q1 <= '1';
      elsif CE = '1' then Q1 <= D; end if;
    end if;
  end process;
end;

--###################################################################################
-- Generic DDR Register
--###################################################################################
library ieee;
use ieee.std_logic_1164.all;
entity gen_ddr_phy_reg is
  port(
    Q : out std_ulogic;
    C : in std_ulogic;
    D  : in std_ulogic
      );
end;

architecture rtl of gen_ddr_phy_reg is
begin
  reg : process(C)
  begin
    if rising_edge(C) then Q <= D; end if;
  end process;
end;

--###################################################################################
-- Generic DDR PHY
--###################################################################################
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
library grlib;
use grlib.stdlib.all;

entity generic_ddr_phy is
  generic (MHz : integer := 100; rstdelay : integer := 200;
    dbits : integer := 16; clk_mul : integer := 2 ;
    clk_div : integer := 2; rskew : integer := 0; mobile : integer := 0);
  port(
    rst       : in  std_ulogic;
    clk       : in  std_logic;  -- input clock
    clkout    : out std_ulogic; -- system clock
    --clkread   : out std_ulogic;
    lock      : out std_ulogic; -- DCM locked

    ddr_clk   : out std_logic_vector(2 downto 0);
    ddr_clkb  : out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb: in std_logic;
    ddr_cke   : out std_logic_vector(1 downto 0);
    ddr_csb   : out std_logic_vector(1 downto 0);
    ddr_web   : out std_ulogic;                       -- ddr write enable
    ddr_rasb  : out std_ulogic;                       -- ddr ras
    ddr_casb  : out std_ulogic;                       -- ddr cas
    ddr_dm    : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs   : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad    : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba    : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    : inout  std_logic_vector (dbits-1 downto 0); -- ddr data

    addr      : in  std_logic_vector (13 downto 0); -- data mask
    ba        : in  std_logic_vector ( 1 downto 0); -- data mask
    dqin      : out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout     : in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm        : in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       : in  std_ulogic;
    dqs       : in  std_ulogic;
    dqsoen    : in  std_ulogic;
    rasn      : in  std_ulogic;
    casn      : in  std_ulogic;
    wen       : in  std_ulogic;
    csn       : in  std_logic_vector(1 downto 0);
    cke       : in  std_logic_vector(1 downto 0);
    ck        : in  std_logic_vector(2 downto 0);
    moben     : in  std_logic -- Mobile DDR enable
      );
end;

architecture rtl of generic_ddr_phy is
component gen_ddr_phy_oreg is
generic(sameedge : integer := 0 );
port(Q : out std_ulogic; C0 : in std_ulogic; C1 : in std_ulogic; CE : in std_ulogic;
     D0 : in std_ulogic; D1 : in std_ulogic; R  : in std_ulogic; S  : in std_ulogic);
end component;
component gen_ddr_phy_ireg is
  port(Q0 : out std_ulogic; Q1 : out std_ulogic; C0 : in std_ulogic; C1 : in std_ulogic;
       CE : in std_ulogic; D  : in std_ulogic; R  : in std_ulogic; S  : in std_ulogic);
end component;
component gen_ddr_phy_reg is
  port(Q : out std_ulogic; C : in std_ulogic; D  : in std_ulogic);
end component;

signal vcc, gnd : std_logic;                                    -- VCC and GND
signal clk0r, clk90r, clk180r, clk270r : std_ulogic := '0';     -- Clocks
signal rclk90r, rclk270r : std_ulogic;                          -- DDR Read clock
signal ddr_clkl, ddr_clkbl, ckn : std_logic_vector(2 downto 0); -- DDR clk generation
signal ddr_rasnr, ddr_casnr, ddr_wenr : std_ulogic;             -- RAS, CAS, WEN generation
signal ddr_csnr, ddr_ckenr, ckel : std_logic_vector(1 downto 0);-- CSN, CKE generation
signal ddr_adr      : std_logic_vector (13 downto 0);           -- DDR ADDRESS generation
signal ddr_bar      : std_logic_vector (1 downto 0);            -- DDR BA generation

signal dqsn, oe     : std_logic;                                -- DQS generation
signal ddr_dqsin    : std_logic_vector (dbits/8-1 downto 0);    -- DQS generation
signal ddr_dqsoen   : std_logic_vector (dbits/8-1 downto 0);    -- DQS generation
signal ddr_dqsoutl  : std_logic_vector (dbits/8-1 downto 0);    -- DQS generation

signal ddr_dmr      : std_logic_vector (dbits/8-1 downto 0);    -- DQM generation

signal ddr_dqin     : std_logic_vector (dbits-1 downto 0);      -- DDR DQ generation
signal ddr_dqout    : std_logic_vector (dbits-1 downto 0);      -- DDR DQ generation
signal ddr_dqoen    : std_logic_vector (dbits-1 downto 0);      -- DDR DQ generation
signal dqinl,dqinl2 : std_logic_vector (dbits-1 downto 0);      -- DDR DQ generation
signal dqinl3,dqinl4: std_logic_vector (dbits-1 downto 0);      -- DDR DQ generation

signal lockl, locked, vlockl : std_ulogic;                      -- Lock delay

constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;
constant clkperiod : real := ((100000.0 / real(DDR_FREQ))/2.0)/100.0;
constant phase90 : real := ((100000.0 / real(DDR_FREQ))/4.0)/100.0;
constant readskew : real := ((100000.0 / real(DDR_FREQ))*real(rskew))/25500.0;
begin
  oe <= not oen;
  vcc <= '1'; gnd <= '0';

  -----------------------------------------------------------------------------------
  -- Clock generation (Only for simulation)
  -----------------------------------------------------------------------------------
  -- Phase shifted clocks
  -- *** Should be generated from clk input ***
-- pragma translate_off
  clk0r <= not clk0r after clkperiod* 1 ns;
  clk90r <= transport clk0r after phase90 *1 ns;
-- pragma translate_on
  clk180r <= not clk0r;
  clk270r <= not clk90r;

  -- Clock to DDR controller
  clkout <= clk0r;

  -- Read clocks
-- pragma translate_off
  rclk90r <= transport ddr_clk_fb after readskew*1 ns;
-- pragma translate_on
  rclk270r <= not rclk90r;

  -- Clock generator lock signal
  lockl <= rst;
  
  -----------------------------------------------------------------------------------
  -- Lock delay
  -----------------------------------------------------------------------------------

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk0r)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk0r) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
          cnt := conv_std_logic_vector(rstdelay*DDR_FREQ, 16); vlock := '0';
        else
          if vlock = '0' then
            cnt := cnt -1;  vlock := cnt(15) and not co;
          end if;
        end if;
      end if;
      if lockl = '0' then
        vlock := '0';
      end if;
    end process;
  end generate;

  locked <= lockl when rstdelay = 0 else vlockl;
  lock <= locked;
  -----------------------------------------------------------------------------------
  -- Generate external DDR clock
  -----------------------------------------------------------------------------------

  --fbdclk0r : FDDRRSE port map ( Q => ddr_clk_fb_outr, C0 => clk90r, C1 => clk270r,
  --  CE => vcc, D0 => vcc, D1 => gnd, R => gnd, S => gnd);
  --fbclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
  --  port map (ddr_clk_fb_out, ddr_clk_fb_outr);

  ddrclocks : for i in 0 to 2 generate
    ckn(i) <= not ck(i);

    -- DDR_CLK
    dclk0r : gen_ddr_phy_oreg port map ( Q => ddr_clkl(i), C0 => clk90r, C1 => clk270r, 
      CE => vcc, D0 => ck(i), D1 => gnd, R => gnd, S => gnd);
    ddrclk_pad : outpad generic map (tech => 0) 
      port map (ddr_clk(i), ddr_clkl(i));

    -- DDR_CLKB
    dclk0rb : gen_ddr_phy_oreg port map ( Q => ddr_clkbl(i), C0 => clk90r, C1 => clk270r,
      CE => vcc, D0 => ckn(i), D1 => vcc, R => gnd, S => gnd);
    ddrclkb_pad : outpad generic map (tech => 0) 
      port map (ddr_clkb(i), ddr_clkbl(i));
  end generate;


  -----------------------------------------------------------------------------------
  --  DDR single-edge control signals
  -----------------------------------------------------------------------------------
  -- RAS
  rasgen : gen_ddr_phy_reg port map ( Q => ddr_rasnr, C => clk0r, D => rasn);
  rasn_pad : outpad generic map (tech => 0) 
    port map (ddr_rasb, ddr_rasnr);

  -- CAS
  casgen : gen_ddr_phy_reg port map ( Q => ddr_casnr, C => clk0r, D => casn);
  casn_pad : outpad generic map (tech => 0) 
    port map (ddr_casb, ddr_casnr);

  -- WEN
  wengen : gen_ddr_phy_reg port map ( Q => ddr_wenr, C => clk0r, D => wen);
  wen_pad : outpad generic map (tech => 0) 
    port map (ddr_web, ddr_wenr);

  -- BA
  bagen : for i in 0 to 1 generate
    da0 : gen_ddr_phy_reg port map ( Q => ddr_bar(i), C => clk0r, D => ba(i));
    ddr_ba_pad  : outpad generic map (tech => 0) 
      port map (ddr_ba(i), ddr_bar(i));
  end generate;

  -- ADDRESS
  dagen : for i in 0 to 13 generate
    da0 : gen_ddr_phy_reg port map ( Q => ddr_adr(i), C => clk0r, D => addr(i));
    ddr_ad_pad  : outpad generic map (tech => 0) 
      port map (ddr_ad(i), ddr_adr(i));
  end generate;

  -- CSN and CKE
  ddrbanks : for i in 0 to 1 generate
    csn0gen : gen_ddr_phy_reg port map ( Q => ddr_csnr(i), C => clk0r, D => csn(i));
    csn0_pad : outpad generic map (tech => 0) 
      port map (ddr_csb(i), ddr_csnr(i));
    ckel(i) <= cke(i) and (locked or moben); -- CKE Starts high for Mobile DDR
    ckegen : gen_ddr_phy_reg port map ( Q => ddr_ckenr(i), C => clk0r, D => ckel(i));
    cke_pad : outpad generic map (tech => 0) 
      port map (ddr_cke(i), ddr_ckenr(i));
  end generate;
  
  -----------------------------------------------------------------------------------
  -- DQS generation
  -----------------------------------------------------------------------------------
  dsqreg : gen_ddr_phy_reg port map ( Q => dqsn, C => clk180r, D => oe);
  dqsgen : for i in 0 to dbits/8-1 generate
    da0 : gen_ddr_phy_oreg
      generic map(sameedge => 1)
      port map( Q => ddr_dqsin(i), C0 => clk90r,  C1 => clk270r, 
        CE => vcc, D0 => dqsn, D1 => gnd, R => gnd, S => gnd);
    doen : gen_ddr_phy_reg port map ( Q => ddr_dqsoen(i), C => clk0r, D => dqsoen);
    dqs_pad : iopad generic map (tech => 0)
      port map (pad => ddr_dqs(i), i => ddr_dqsin(i), en => ddr_dqsoen(i), 
        o => ddr_dqsoutl(i));
  end generate;

  -----------------------------------------------------------------------------------
  -- DQM generation
  -----------------------------------------------------------------------------------
  dmgen : for i in 0 to dbits/8-1 generate
    da0 : gen_ddr_phy_oreg
      generic map(sameedge => 1)
      port map ( Q => ddr_dmr(i), C0 => clk0r, C1 => clk180r,
        CE => vcc, D0 => dm(i+dbits/8), D1 => dm(i), R => gnd, S => gnd);
    ddr_bm_pad  : outpad generic map (tech => 0) 
      port map (ddr_dm(i), ddr_dmr(i));
  end generate;

  -----------------------------------------------------------------------------------
  -- Data bus
  -----------------------------------------------------------------------------------

  ddgen : for i in 0 to dbits-1 generate
    -- DQ Input
    nomobile : if mobile = 0 generate -- No Mobile DDR support
      dinq1 : gen_ddr_phy_reg port map ( Q => dqin(i+dbits), C => rclk90r, D => dqinl(i));  -- Standard DDR
      dqin(i) <= dqinl2(i);
    end generate;
    mobsupport : if (mobile = 1) or (mobile = 2) generate -- Standard/Mobile DDR support
      dinq1 : gen_ddr_phy_reg port map ( Q => dqinl3(i), C => rclk90r, D => dqinl(i));      -- Standard DDR
      dinq2 : gen_ddr_phy_reg port map ( Q => dqinl4(i), C => rclk90r, D => dqinl2(i));     -- Mobile DDR    
      dqin(i) <= dqinl2(i) when moben = '0' else dqinl3(i); 
      dqin(i+dbits) <= dqinl3(i) when moben = '0' else dqinl4(i);
    end generate;
    mobenable : if mobile = 3 generate -- Mobile DDR support
      dinq1 : gen_ddr_phy_reg port map ( Q => dqin(i), C => rclk90r, D => dqinl(i));        -- Mobile DDR
      dinq2 : gen_ddr_phy_reg port map ( Q => dqin(i+dbits), C => rclk90r, D => dqinl2(i));
    end generate;
    
    qi : gen_ddr_phy_ireg
    port map ( Q0 => dqinl(i),    -- 1-bit output for positive edge of clock 
               Q1 => dqinl2(i),   -- 1-bit output for negative edge of clock 
               C0 => rclk270r,    -- 1-bit clock input 
               C1 => rclk90r,     -- 1-bit clock input 
               CE => vcc,         -- 1-bit clock enable input 
               D => ddr_dqin(i),  -- 1-bit DDR data input 
               R => gnd,          -- 1-bit reset 
               S => gnd           -- 1-bit set 
             );

    -- DQ Output
    da0 : gen_ddr_phy_oreg
      generic map(sameedge => 1)
      port map ( Q => ddr_dqout(i), C0 => clk0r, C1 => clk180r, CE => vcc,
        D0 => dqout(i+dbits), D1 => dqout(i), R => gnd, S => gnd);
    
    -- DQ Output enable
    doen : gen_ddr_phy_reg port map ( Q => ddr_dqoen(i), C => clk0r, D => oen);
    
    -- DQ PAD
    dq_pad : iopad generic map (tech => 0)
         port map (pad => ddr_dq(i), i => ddr_dqout(i), en => ddr_dqoen(i), o => ddr_dqin(i));
  end generate;

  -----------------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------------

end;
