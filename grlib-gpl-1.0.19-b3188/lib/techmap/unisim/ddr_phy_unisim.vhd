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
-- Entity: 	various
-- File:	clkgen_xilinx.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	DDR PHY for Virtex-2 and Virtex-4
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
-- pragma translate_off
library unisim;
use unisim.BUFG;
use unisim.DCM;
use unisim.ODDR;
use unisim.FD;
use unisim.IDDR;
-- pragma translate_on

library techmap;
use techmap.gencomp.all;

------------------------------------------------------------------
-- Virtex4 DDR PHY -----------------------------------------------
------------------------------------------------------------------

entity virtex4_ddr_phy is
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2; rskew : integer := 0);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
 
    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0);
    ck        	: in  std_logic_vector(2 downto 0)
  );

end;

architecture rtl of virtex4_ddr_phy is

  component DCM
    generic (
      CLKDV_DIVIDE : real := 2.0;
      CLKFX_DIVIDE : integer := 1;
      CLKFX_MULTIPLY : integer := 4;
      CLKIN_DIVIDE_BY_2 : boolean := false;
      CLKIN_PERIOD : real := 10.0;
      CLKOUT_PHASE_SHIFT : string := "NONE";
      CLK_FEEDBACK : string := "1X";
      DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
      DFS_FREQUENCY_MODE : string := "LOW";
      DLL_FREQUENCY_MODE : string := "LOW";
      DSS_MODE : string := "NONE";
      DUTY_CYCLE_CORRECTION : boolean := true;
      FACTORY_JF : bit_vector := X"C080";
      PHASE_SHIFT : integer := 0;
      STARTUP_WAIT : boolean := false 
    );
    port (
      CLKFB    : in  std_logic;
      CLKIN    : in  std_logic;
      DSSEN    : in  std_logic;
      PSCLK    : in  std_logic;
      PSEN     : in  std_logic;
      PSINCDEC : in  std_logic;
      RST      : in  std_logic;
      CLK0     : out std_logic;
      CLK90    : out std_logic;
      CLK180   : out std_logic;
      CLK270   : out std_logic;
      CLK2X    : out std_logic;
      CLK2X180 : out std_logic;
      CLKDV    : out std_logic;
      CLKFX    : out std_logic;
      CLKFX180 : out std_logic;
      LOCKED   : out std_logic;
      PSDONE   : out std_logic;
      STATUS   : out std_logic_vector (7 downto 0));
  end component;
  component BUFG port (O : out std_logic; I : in std_logic); end component;
  component ODDR
    generic
      ( DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
--        INIT : bit := '0';
        SRTYPE : string := "SYNC");
    port
      (
        Q : out std_ulogic;
        C : in std_ulogic;
        CE : in std_ulogic;
        D1 : in std_ulogic;
        D2 : in std_ulogic;
        R : in std_ulogic;
        S : in std_ulogic
      );
  end component;
  component FD
	generic ( INIT : bit := '0');
	port (  Q : out std_ulogic;
		C : in std_ulogic;
		D : in std_ulogic);
  end component;
    component IDDR
      generic ( DDR_CLK_EDGE : string := "SAME_EDGE";
          INIT_Q1 : bit := '0';
          INIT_Q2 : bit := '0';
          SRTYPE : string := "ASYNC");
      port
        ( Q1 : out std_ulogic;
          Q2 : out std_ulogic;
          C : in std_ulogic;
          CE : in std_ulogic;
          D : in std_ulogic;
          R : in std_ulogic;
          S : in std_ulogic);
    end component;

signal vcc, gnd, dqsn, oe, lockl : std_ulogic;
signal ddr_clk_fb_outr : std_ulogic;
signal ddr_clk_fbl, fbclk : std_ulogic;
signal ddr_rasnr, ddr_casnr, ddr_wenr : std_ulogic;
signal ddr_clkl, ddr_clkbl : std_logic_vector(2 downto 0);
signal ddr_csnr, ddr_ckenr, ckel : std_logic_vector(1 downto 0);
signal clk_0ro, clk_90ro, clk_180ro, clk_270ro : std_ulogic;
signal clk_0r, clk_90r, clk_180r, clk_270r : std_ulogic;
signal clk0r, clk90r, clk180r, clk270r : std_ulogic;
signal locked, vlockl, ddrclkfbl, dllfb : std_ulogic;

signal ddr_dqin  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqout  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqoen  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_adr      	: std_logic_vector (13 downto 0);   -- ddr address
signal ddr_bar      	: std_logic_vector (1 downto 0);   -- ddr address
signal ddr_dmr      	: std_logic_vector (dbits/8-1 downto 0);   -- ddr address
signal ddr_dqsin  	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoen 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoutl 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal dqsdel, dqsclk 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal da     		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dqinl		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dllrst		: std_logic_vector(0 to 3);
signal dll0rst, dll2rst	: std_logic_vector(0 to 3);
signal mlock, mclkfb, mclk, mclkfx, mclk0 : std_ulogic;
signal rclk270b, rclk90b, rclk0b : std_ulogic;
signal rclk270, rclk90, rclk0 : std_ulogic;

constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

  attribute keep : boolean;
  attribute keep of rclk90b : signal is true;
  attribute syn_keep : boolean;
  attribute syn_keep of rclk90b : signal is true;
  attribute syn_preserve : boolean;
  attribute syn_preserve of rclk90b : signal is true;

  -- To prevent synplify 9.4 to remove any of these registers.
  attribute syn_noprune : boolean;
  attribute syn_noprune of FD : component is true;
  attribute syn_noprune of IDDR : component is true;
  attribute syn_noprune of ODDR : component is true;

begin

  oe <= not oen;
  vcc <= '1'; gnd <= '0';

  -- Optional DDR clock multiplication

  noclkscale : if clk_mul = clk_div generate
    mclk <= clk;
  end generate;

  clkscale : if clk_mul /= clk_div generate

    rstdel : process (clk, rst)
    begin
        if rst = '0' then dll0rst <= (others => '1');
        elsif rising_edge(clk) then
  	  dll0rst <= dll0rst(1 to 3) & '0';
        end if;
    end process;

    bufg0 : BUFG port map (I => mclkfx, O => mclk);
    bufg1 : BUFG port map (I => mclk0, O => mclkfb);

    dllm : DCM
      generic map (CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div)
      port map ( CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => mclk0,
      LOCKED => mlock, CLKFX => mclkfx );
  end generate;

  -- DDR clock generation

  ddrref_pad : clkpad generic map (tech => virtex4) 
	port map (ddr_clk_fb, ddrclkfbl); 
  
  bufg1 : BUFG port map (I => clk_0ro, O => clk_0r);
--  bufg2 : BUFG port map (I => clk_90ro, O => clk_90r);
  clk_90r <= not clk_270r;
--  bufg3 : BUFG port map (I => clk_180ro, O => clk_180r);
  clk_180r <= not clk_0r;
  bufg4 : BUFG port map (I => clk_270ro, O => clk_270r);

  clkout <= clk_270r; clk0r <= clk_270r; clk90r <= clk_0r;
  clk180r <= clk_90r; clk270r <= clk_180r;

  
  dllfb <= clk_0r;

  dll : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2)
      port map ( CLKIN => mclk, CLKFB => dllfb, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_0ro, 
      CLK90 => clk_90ro, CLK180 => clk_180ro, CLK270 => clk_270ro, 
      LOCKED => lockl);

  rstdel : process (mclk, rst)
  begin
      if rst = '0' then dllrst <= (others => '1');
      elsif rising_edge(mclk) then
	dllrst <= dllrst(1 to 3) & '0';
      end if;
  end process;

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk_0r)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk_0r) then
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

  -- Generate external DDR clock

  fbdclk0r : ODDR port map ( Q => ddr_clk_fb_outr, C => clk90r, CE => vcc,
		D1 => vcc, D2 => gnd, R => gnd, S => gnd);
  fbclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clk_fb_out, ddr_clk_fb_outr);

  ddrclocks : for i in 0 to 2 generate
    dclk0r : ODDR port map ( Q => ddr_clkl(i), C => clk90r, CE => vcc,
		D1 => vcc, D2 => gnd, R => gnd, S => gnd);
    ddrclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clk(i), ddr_clkl(i));

    dclk0rb : ODDR port map ( Q => ddr_clkbl(i), C => clk90r, CE => vcc,
		D1 => gnd, D2 => vcc, R => gnd, S => gnd);
    ddrclkb_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clkb(i), ddr_clkbl(i));
  end generate;

  ddrbanks : for i in 0 to 1 generate
    csn0gen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_csnr(i), C => clk0r, CE => vcc,
		D1 => csn(i), D2 => csn(i), R => gnd, S => gnd);
    csn0_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_csb(i), ddr_csnr(i));

    ckel(i) <= cke(i) and locked;
    ckegen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_ckenr(i), C => clk0r, CE => vcc,
		D1 => ckel(i), D2 => ckel(i), R => gnd, S => gnd);
    cke_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_cke(i), ddr_ckenr(i));
  end generate;

  rasgen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_rasnr, C => clk0r, CE => vcc,
		D1 => rasn, D2 => rasn, R => gnd, S => gnd);
  rasn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_rasb, ddr_rasnr);

  casgen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_casnr, C => clk0r, CE => vcc,
		D1 => casn, D2 => casn, R => gnd, S => gnd);
  casn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_casb, ddr_casnr);

  wengen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_wenr, C => clk0r, CE => vcc,
		D1 => wen, D2 => wen, R => gnd, S => gnd);
  wen_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_web, ddr_wenr);

  dmgen : for i in 0 to dbits/8-1 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
               port map ( Q => ddr_dmr(i), C => clk0r, CE => vcc,
		D1 => dm(i+dbits/8), D2 => dm(i), R => gnd, S => gnd);
    ddr_bm_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_dm(i), ddr_dmr(i));
  end generate;

  bagen : for i in 0 to 1 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
               port map ( Q => ddr_bar(i), C => clk0r, CE => vcc,
		D1 => ba(i), D2 => ba(i), R => gnd, S => gnd);
    ddr_ba_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ba(i), ddr_bar(i));
  end generate;

  dagen : for i in 0 to 13 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
               port map ( Q => ddr_adr(i), C => clk0r, CE => vcc,
		D1 => addr(i), D2 => addr(i), R => gnd, S => gnd);
    ddr_ad_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ad(i), ddr_adr(i));

  end generate;

  -- DQS generation
  dsqreg : FD port map ( Q => dqsn, C => clk180r, D => oe);
  dqsgen : for i in 0 to dbits/8-1 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
    	port map ( Q => ddr_dqsin(i), C => clk90r, CE => vcc,
		D1 => dqsn, D2 => gnd, R => gnd, S => gnd);
    doen : FD port map ( Q => ddr_dqsoen(i), C => clk0r, D => dqsoen);
    dqs_pad : iopad generic map (tech => virtex4, level => sstl2_ii)
         port map (pad => ddr_dqs(i), i => ddr_dqsin(i), en => ddr_dqsoen(i), 
		o => ddr_dqsoutl(i));
  end generate;

  -- Data bus


    read_rstdel : process (clk_0r, lockl)
    begin
        if lockl = '0' then dll2rst <= (others => '1');
        elsif rising_edge(clk_0r) then
  	  dll2rst <= dll2rst(1 to 3) & '0';
        end if;
    end process;

    bufg7 : BUFG port map (I => rclk0, O => rclk0b);
    bufg8 : BUFG port map (I => rclk90, O => rclk90b);
--    bufg9 : BUFG port map (I => rclk270, O => rclk270b);
    rclk270b <= not rclk90b;

  nops : if rskew = 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS")
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;

  ps : if rskew /= 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", 
	CLKOUT_PHASE_SHIFT => "FIXED", PHASE_SHIFT => rskew)
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;

    ddgen : for i in 0 to dbits-1 generate
      qi : IDDR generic map (DDR_CLK_EDGE => "OPPOSITE_EDGE")
      port map ( Q1 => dqinl(i), --(i+dbits), -- 1-bit output for positive edge of clock 
               Q2 => dqin(i), -- 1-bit output for negative edge of clock 
               C => rclk90b, --clk270r, --dqsclk((2*i)/dbits), -- 1-bit clock input 
              CE => vcc, -- 1-bit clock enable input 
               D => ddr_dqin(i), -- 1-bit DDR data input 
               R => gnd, -- 1-bit reset 
               S => gnd -- 1-bit set 
             );

      dinq1 : FD port map ( Q => dqin(i+dbits), C => rclk270b, D => dqinl(i));
      dout : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map ( Q => ddr_dqout(i), C => clk0r, CE => vcc,
		D1 => dqout(i+dbits), D2 => dqout(i), R => gnd, S => gnd);
      doen : FD port map ( Q => ddr_dqoen(i), C => clk0r, D => oen);
      dq_pad : iopad generic map (tech => virtex4, level => sstl2_ii)
         port map (pad => ddr_dq(i), i => ddr_dqout(i), en => ddr_dqoen(i), o => ddr_dqin(i));
    end generate;

end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library unisim;
use unisim.BUFG;
use unisim.DCM;
use unisim.FDDRRSE;
use unisim.IFDDRRSE;
use unisim.FD;
-- pragma translate_on

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
use techmap.oddrv2;

------------------------------------------------------------------
-- Virtex2 DDR PHY -----------------------------------------------
------------------------------------------------------------------

entity virtex2_ddr_phy is
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2; rskew : integer := 0);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
 
    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0)
  );

end;

architecture rtl of virtex2_ddr_phy is

  component DCM
    generic (
      CLKDV_DIVIDE : real := 2.0;
      CLKFX_DIVIDE : integer := 1;
      CLKFX_MULTIPLY : integer := 4;
      CLKIN_DIVIDE_BY_2 : boolean := false;
      CLKIN_PERIOD : real := 10.0;
      CLKOUT_PHASE_SHIFT : string := "NONE";
      CLK_FEEDBACK : string := "1X";
      DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
      DFS_FREQUENCY_MODE : string := "LOW";
      DLL_FREQUENCY_MODE : string := "LOW";
      DSS_MODE : string := "NONE";
      DUTY_CYCLE_CORRECTION : boolean := true;
      FACTORY_JF : bit_vector := X"C080";
      PHASE_SHIFT : integer := 0;
      STARTUP_WAIT : boolean := false 
    );
    port (
      CLKFB    : in  std_logic;
      CLKIN    : in  std_logic;
      DSSEN    : in  std_logic;
      PSCLK    : in  std_logic;
      PSEN     : in  std_logic;
      PSINCDEC : in  std_logic;
      RST      : in  std_logic;
      CLK0     : out std_logic;
      CLK90    : out std_logic;
      CLK180   : out std_logic;
      CLK270   : out std_logic;
      CLK2X    : out std_logic;
      CLK2X180 : out std_logic;
      CLKDV    : out std_logic;
      CLKFX    : out std_logic;
      CLKFX180 : out std_logic;
      LOCKED   : out std_logic;
      PSDONE   : out std_logic;
      STATUS   : out std_logic_vector (7 downto 0));
  end component;
  component BUFG port (O : out std_logic; I : in std_logic); end component;
  component FDDRRSE
--    generic ( INIT : bit := '0');
    port
      (
        Q : out std_ulogic;
        C0 : in std_ulogic;
        C1 : in std_ulogic;
        CE : in std_ulogic;
        D0 : in std_ulogic;
        D1 : in std_ulogic;
        R : in std_ulogic;
        S : in std_ulogic
      );
  end component;

  component IFDDRRSE
	port (
		Q0 : out std_ulogic;
		Q1 : out std_ulogic;
		C0 : in std_ulogic;
		C1 : in std_ulogic;
		CE : in std_ulogic;
		D : in std_ulogic;
		R : in std_ulogic;
		S : in std_ulogic);
  end component;
  component FD
	generic ( INIT : bit := '0');
	port (  Q : out std_ulogic;
		C : in std_ulogic;
		D : in std_ulogic);
  end component;

  component oddrv2
  generic ( tech : integer := virtex4); 
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
  end component;

signal vcc, gnd, dqsn, oe, lockl : std_ulogic;
signal ddr_clk_fb_outr : std_ulogic;
signal ddr_clk_fbl, fbclk : std_ulogic;
signal ddr_rasnr, ddr_casnr, ddr_wenr : std_ulogic;
signal ddr_clkl, ddr_clkbl : std_logic_vector(2 downto 0);
signal ddr_csnr, ddr_ckenr, ckel : std_logic_vector(1 downto 0);
signal clk_0ro, clk_90ro, clk_180ro, clk_270ro : std_ulogic;
signal clk_0r, clk_90r, clk_180r, clk_270r : std_ulogic;
signal clk0r, clk90r, clk180r, clk270r : std_ulogic;
signal locked, vlockl, ddrclkfbl : std_ulogic;
signal ddr_dqin  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqout  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqoen  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_adr      	: std_logic_vector (13 downto 0);   -- ddr address
signal ddr_bar      	: std_logic_vector (1 downto 0);   -- ddr address
signal ddr_dmr      	: std_logic_vector (dbits/8-1 downto 0);   -- ddr address
signal ddr_dqsin  	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoen 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoutl 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal dqsdel, dqsclk 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal da     		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dqinl		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dllrst		: std_logic_vector(0 to 3);
signal dll0rst, dll2rst	: std_logic_vector(0 to 3);
signal mlock, mclkfb, mclk, mclkfx, mclk0 : std_ulogic;
signal rclk270b, rclk90b, rclk0b : std_ulogic;
signal rclk270, rclk90, rclk0 : std_ulogic;

constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

-- To prevent synplify 9.4 to remove any of these registers.
attribute syn_noprune : boolean;
attribute syn_noprune of FD : component is true;
attribute syn_noprune of FDDRRSE : component is true;
attribute syn_noprune of IFDDRRSE : component is true;
attribute syn_noprune of oddrv2 : component is true;

begin

  oe <= not oen;
  vcc <= '1'; gnd <= '0';

  -- Optional DDR clock multiplication

  noclkscale : if clk_mul = clk_div generate
    mclk <= clk; mlock <= rst;
  end generate;

  clkscale : if clk_mul /= clk_div generate

    rstdel : process (clk, rst)
    begin
        if rst = '0' then dll0rst <= (others => '1');
        elsif rising_edge(clk) then
  	  dll0rst <= dll0rst(1 to 3) & '0';
        end if;
    end process;

    bufg0 : BUFG port map (I => mclkfx, O => mclk);
    bufg1 : BUFG port map (I => mclk0, O => mclkfb);

    dllm : DCM
      generic map (CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div,
	CLKIN_PERIOD => 10.0)
      port map ( CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => mclk0,
      LOCKED => mlock, CLKFX => mclkfx );
  end generate;

  -- DDR output clock generation
  
  bufg1 : BUFG port map (I => clk_0ro, O => clk_0r);
--  bufg2 : BUFG port map (I => clk_90ro, O => clk_90r);
  clk_90r <= not clk_270r;
--  bufg3 : BUFG port map (I => clk_180ro, O => clk_180r);
  clk_180r <= not clk_0r;
  bufg4 : BUFG port map (I => clk_270ro, O => clk_270r);

  clkout <= clk_270r; clk0r <= clk_270r; clk90r <= clk_0r;
  clk180r <= clk_90r; clk270r <= clk_180r;

  
  dll : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2)
      port map ( CLKIN => mclk, CLKFB => clk_0r, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_0ro, 
      CLK90 => clk_90ro, CLK180 => clk_180ro, CLK270 => clk_270ro, 
      LOCKED => lockl);

  rstdel : process (mclk, mlock)
  begin
      if mlock = '0' then dllrst <= (others => '1');
      elsif rising_edge(mclk) then
	dllrst <= dllrst(1 to 3) & '0';
      end if;
  end process;

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk_0r)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk_0r) then
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

  -- Generate external DDR clock

  fbdclk0r : FDDRRSE port map ( Q => ddr_clk_fb_outr, C0 => clk90r, C1 => clk270r,
	CE => vcc, D0 => vcc, D1 => gnd, R => gnd, S => gnd);
  fbclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clk_fb_out, ddr_clk_fb_outr);

  ddrclocks : for i in 0 to 2 generate
    dclk0r : FDDRRSE port map ( Q => ddr_clkl(i), C0 => clk90r, C1 => clk270r, 
	CE => vcc, D0 => vcc, D1 => gnd, R => gnd, S => gnd);
    ddrclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clk(i), ddr_clkl(i));

    dclk0rb : FDDRRSE port map ( Q => ddr_clkbl(i), C0 => clk90r, C1 => clk270r,
	CE => vcc, D0 => gnd, D1 => vcc, R => gnd, S => gnd);
    ddrclkb_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clkb(i), ddr_clkbl(i));
  end generate;

  ddrbanks : for i in 0 to 1 generate
    csn0gen : FD port map ( Q => ddr_csnr(i), C => clk0r, D => csn(i));
    csn0_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_csb(i), ddr_csnr(i));

    ckel(i) <= cke(i) and locked;
    ckegen : FD port map ( Q => ddr_ckenr(i), C => clk0r, D => ckel(i));
    cke_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_cke(i), ddr_ckenr(i));

  end generate;

  --  DDR single-edge control signals
  rasgen : FD port map ( Q => ddr_rasnr, C => clk0r, D => rasn);
  rasn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_rasb, ddr_rasnr);

  casgen : FD port map ( Q => ddr_casnr, C => clk0r, D => casn);
  casn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_casb, ddr_casnr);

  wengen : FD port map ( Q => ddr_wenr, C => clk0r, D => wen);
  wen_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_web, ddr_wenr);

  dmgen : for i in 0 to dbits/8-1 generate
    da0 : oddrv2 port map ( Q => ddr_dmr(i), C1 => clk0r, C2 => clk180r,
	CE => vcc, D1 => dm(i+dbits/8), D2 => dm(i), R => gnd, S => gnd);
    ddr_bm_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_dm(i), ddr_dmr(i));
  end generate;

  bagen : for i in 0 to 1 generate
    da0 : FD port map ( Q => ddr_bar(i), C => clk0r, D => ba(i));
    ddr_ba_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ba(i), ddr_bar(i));
  end generate;

  dagen : for i in 0 to 13 generate
    da0 : FD port map ( Q => ddr_adr(i), C => clk0r, D => addr(i));
    ddr_ad_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ad(i), ddr_adr(i));

  end generate;

  -- DQS generation
  dsqreg : FD port map ( Q => dqsn, C => clk180r, D => oe);
  dqsgen : for i in 0 to dbits/8-1 generate
    da0 : oddrv2
    	port map ( Q => ddr_dqsin(i), C1 => clk90r,  C2 => clk270r, 
	CE => vcc, D1 => dqsn, D2 => gnd, R => gnd, S => gnd);
    doen : FD port map ( Q => ddr_dqsoen(i), C => clk0r, D => dqsoen);
    dqs_pad : iopad generic map (tech => virtex4, level => sstl2_ii)
         port map (pad => ddr_dqs(i), i => ddr_dqsin(i), en => ddr_dqsoen(i), 
		o => ddr_dqsoutl(i));
  end generate;

  -- Data bus

  ddrref_pad : clkpad generic map (tech => virtex2) 
	port map (ddr_clk_fb, ddrclkfbl); 

    read_rstdel : process (clk_0r, lockl)
    begin
        if lockl = '0' then dll2rst <= (others => '1');
        elsif rising_edge(clk_0r) then
  	  dll2rst <= dll2rst(1 to 3) & '0';
        end if;
    end process;

    bufg7 : BUFG port map (I => rclk0, O => rclk0b);
    bufg8 : BUFG port map (I => rclk90, O => rclk90b);
--    bufg9 : BUFG port map (I => rclk270, O => rclk270b);
    rclk270b <= not rclk90b;

  nops : if rskew = 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS")
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;

  ps : if rskew /= 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", 
	CLKOUT_PHASE_SHIFT => "FIXED", PHASE_SHIFT => rskew)
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;

  ddgen : for i in 0 to dbits-1 generate
    qi : IFDDRRSE
    port map ( Q0 => dqinl(i), --(i+dbits), -- 1-bit output for positive edge of clock 
               Q1 => dqin(i), -- 1-bit output for negative edge of clock 
	       C0 => rclk90b, -- clk270r, --dqsclk((2*i)/dbits), -- 1-bit clock input 
	       C1 => rclk270b, -- clk90r, --dqsclk((2*i)/dbits), -- 1-bit clock input 
	       CE => vcc, -- 1-bit clock enable input 
		D => ddr_dq(i), -- 1-bit DDR data input 
		R => gnd, -- 1-bit reset 
		S => gnd -- 1-bit set 
	      );

--    dinq1 : FD port map ( Q => dqin(i+dbits), C => clk90r, D => dqinl(i));
    dinq1 : FD port map ( Q => dqin(i+dbits), C => rclk270b, D => dqinl(i));
    dout : oddrv2
	port map ( Q => ddr_dqout(i), C1 => clk0r, C2 => clk180r, CE => vcc,
		D1 => dqout(i+dbits), D2 => dqout(i), R => gnd, S => gnd);
    doen : FD port map ( Q => ddr_dqoen(i), C => clk0r, D => oen);
    dq_pad : iopad generic map (tech => virtex4, level => sstl2_ii)
         port map (pad => ddr_dq(i), i => ddr_dqout(i), en => ddr_dqoen(i), o => open); -- o => ddr_dqin(i));
  end generate;


  
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library unisim;
use unisim.BUFG;
use unisim.DCM;
use unisim.ODDR2;
use unisim.IDDR2;
use unisim.FD;
-- pragma translate_on

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
use techmap.oddrc3e;

------------------------------------------------------------------
-- Spartan3E DDR PHY -----------------------------------------------
------------------------------------------------------------------

entity spartan3e_ddr_phy is
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2; rskew : integer := 0);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- DDR state clock
    clkread   : out std_ulogic;			-- DDR read clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
 
    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0)
  );

end;

architecture rtl of spartan3e_ddr_phy is

component oddrc3e
  generic ( tech : integer := virtex4); 
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end component;

  component DCM
    generic (
      CLKDV_DIVIDE : real := 2.0;
      CLKFX_DIVIDE : integer := 1;
      CLKFX_MULTIPLY : integer := 4;
      CLKIN_DIVIDE_BY_2 : boolean := false;
      CLKIN_PERIOD : real := 10.0;
      CLKOUT_PHASE_SHIFT : string := "NONE";
      CLK_FEEDBACK : string := "1X";
      DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
      DFS_FREQUENCY_MODE : string := "LOW";
      DLL_FREQUENCY_MODE : string := "LOW";
      DSS_MODE : string := "NONE";
      DUTY_CYCLE_CORRECTION : boolean := true;
      FACTORY_JF : bit_vector := X"C080";
      PHASE_SHIFT : integer := 0;
      STARTUP_WAIT : boolean := false 
    );
    port (
      CLKFB    : in  std_logic;
      CLKIN    : in  std_logic;
      DSSEN    : in  std_logic;
      PSCLK    : in  std_logic;
      PSEN     : in  std_logic;
      PSINCDEC : in  std_logic;
      RST      : in  std_logic;
      CLK0     : out std_logic;
      CLK90    : out std_logic;
      CLK180   : out std_logic;
      CLK270   : out std_logic;
      CLK2X    : out std_logic;
      CLK2X180 : out std_logic;
      CLKDV    : out std_logic;
      CLKFX    : out std_logic;
      CLKFX180 : out std_logic;
      LOCKED   : out std_logic;
      PSDONE   : out std_logic;
      STATUS   : out std_logic_vector (7 downto 0));
  end component;
  component BUFG port (O : out std_logic; I : in std_logic); end component;
  component FD
	generic ( INIT : bit := '0');
	port (  Q : out std_ulogic;
		C : in std_ulogic;
		D : in std_ulogic);
  end component;

  component ODDR2
	generic
	(
		DDR_ALIGNMENT : string := "NONE";
		INIT : bit := '0';
		SRTYPE : string := "SYNC"
	);
	port
	(
		Q : out std_ulogic;
		C0 : in std_ulogic;
		C1 : in std_ulogic;
		CE : in std_ulogic;
		D0 : in std_ulogic;
		D1 : in std_ulogic;
		R : in std_ulogic;
		S : in std_ulogic
	);
  end component;
  component IDDR2
	generic
	(
		DDR_ALIGNMENT : string := "NONE";
		INIT_Q0 : bit := '0';
		INIT_Q1 : bit := '0';
		SRTYPE : string := "SYNC"
	);
	port
	(
		Q0 : out std_ulogic;
		Q1 : out std_ulogic;
		C0 : in std_ulogic;
		C1 : in std_ulogic;
		CE : in std_ulogic;
		D : in std_ulogic;
		R : in std_ulogic;
		S : in std_ulogic
	);
  end component;

signal vcc, gnd, dqsn, oe, lockl : std_ulogic;
signal ddr_clk_fb_outr : std_ulogic;
signal ddr_clk_fbl, fbclk : std_ulogic;
signal ddr_rasnr, ddr_casnr, ddr_wenr : std_ulogic;
signal ddr_clkl, ddr_clkbl : std_logic_vector(2 downto 0);
signal ddr_csnr, ddr_ckenr, ckel : std_logic_vector(1 downto 0);
signal clk_0ro, clk_90ro, clk_180ro, clk_270ro : std_ulogic;
signal clk_0r, clk_90r, clk_180r, clk_270r : std_ulogic;
signal clk0r, clk90r, clk180r, clk270r : std_ulogic;
signal locked, vlockl, ddrclkfbl, dllfb : std_ulogic;
signal ddr_dqin  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqout  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqoen  	: std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_adr      	: std_logic_vector (13 downto 0);   -- ddr address
signal ddr_bar      	: std_logic_vector (1 downto 0);   -- ddr address
signal ddr_dmr      	: std_logic_vector (dbits/8-1 downto 0);   -- ddr address
signal ddr_dqsin  	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoen 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoutl 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal dqsdel, dqsclk 	: std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal da     		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dqinl		: std_logic_vector (dbits-1 downto 0); -- ddr data
signal dllrst		: std_logic_vector(0 to 3);
signal dll0rst, dll2rst	: std_logic_vector(0 to 3);
signal mlock, mclkfb, mclk, mclkfx, mclk0 : std_ulogic;
signal rclk270b, rclk90b, rclk0b : std_ulogic;
signal rclk270, rclk90, rclk0 : std_ulogic;

constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

-- To prevent synplify 9.4 to remove any of these registers.
attribute syn_noprune : boolean;
attribute syn_noprune of FD : component is true;
attribute syn_noprune of IDDR2 : component is true;
attribute syn_noprune of ODDR2 : component is true;
attribute syn_noprune of oddrc3e : component is true;

begin

  oe <= not oen;
  vcc <= '1'; gnd <= '0';

  -- Optional DDR clock multiplication

  noclkscale : if clk_mul = clk_div generate
    mclk <= clk; mlock <= rst;
  end generate;

  clkscale : if clk_mul /= clk_div generate

    rstdel : process (clk, rst)
    begin
        if rst = '0' then dll0rst <= (others => '1');
        elsif rising_edge(clk) then
  	  dll0rst <= dll0rst(1 to 3) & '0';
        end if;
    end process;

    bufg0 : BUFG port map (I => mclkfx, O => mclk);
    bufg1 : BUFG port map (I => mclk0, O => mclkfb);

    dllm : DCM
      generic map (CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div,
	CLKIN_PERIOD => 10.0)
      port map ( CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => mclk0,
      LOCKED => mlock, CLKFX => mclkfx );
  end generate;

  -- DDR output clock generation
  
  bufg1 : BUFG port map (I => clk_0ro, O => clk_0r);
--  bufg2 : BUFG port map (I => clk_90ro, O => clk_90r);
  clk_90r <= not clk_270r;
--  bufg3 : BUFG port map (I => clk_180ro, O => clk_180r);
  clk_180r <= not clk_0r;
  bufg4 : BUFG port map (I => clk_270ro, O => clk_270r);

  clkout <= clk_270r; 
--  clkout <= clk_90r when DDR_FREQ > 120 else clk_0r; 

  clk0r <= clk_270r; clk90r <= clk_0r;
  clk180r <= clk_90r; clk270r <= clk_180r;

  dll : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2)
      port map ( CLKIN => mclk, CLKFB => clk_0r, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_0ro, 
      CLK90 => clk_90ro, CLK180 => clk_180ro, CLK270 => clk_270ro, 
      LOCKED => lockl);

  rstdel : process (mclk, mlock)
  begin
      if mlock = '0' then dllrst <= (others => '1');
      elsif rising_edge(mclk) then
	dllrst <= dllrst(1 to 3) & '0';
      end if;
  end process;

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk_0r)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk_0r) then
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

  -- Generate external DDR clock

  fbdclk0r : ODDR2 port map ( Q => ddr_clk_fb_outr, C0 => clk90r, C1 => clk270r,
	CE => vcc, D0 => vcc, D1 => gnd, R => gnd, S => gnd);
  fbclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clk_fb_out, ddr_clk_fb_outr);

  ddrclocks : for i in 0 to 2 generate
    dclk0r : ODDR2 port map ( Q => ddr_clkl(i), C0 => clk90r, C1 => clk270r, 
	CE => vcc, D0 => vcc, D1 => gnd, R => gnd, S => gnd);
    ddrclk_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clk(i), ddr_clkl(i));

    dclk0rb : ODDR2 port map ( Q => ddr_clkbl(i), C0 => clk90r, C1 => clk270r,
	CE => vcc, D0 => gnd, D1 => vcc, R => gnd, S => gnd);
    ddrclkb_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_clkb(i), ddr_clkbl(i));
  end generate;

  ddrbanks : for i in 0 to 1 generate
    csn0gen : FD port map ( Q => ddr_csnr(i), C => clk0r, D => csn(i));
    csn0_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_csb(i), ddr_csnr(i));

    ckel(i) <= cke(i) and locked;
    ckegen : FD port map ( Q => ddr_ckenr(i), C => clk0r, D => ckel(i));
    cke_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_cke(i), ddr_ckenr(i));

  end generate;

  --  DDR single-edge control signals
  rasgen : FD port map ( Q => ddr_rasnr, C => clk0r, D => rasn);
  rasn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_rasb, ddr_rasnr);

  casgen : FD port map ( Q => ddr_casnr, C => clk0r, D => casn);
  casn_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_casb, ddr_casnr);

  wengen : FD port map ( Q => ddr_wenr, C => clk0r, D => wen);
  wen_pad : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_web, ddr_wenr);

  dmgen : for i in 0 to dbits/8-1 generate
    da0 : oddrc3e 
        port map ( Q => ddr_dmr(i), C1 => clk0r, C2 => clk180r,
	CE => vcc, D1 => dm(i+dbits/8), D2 => dm(i), R => gnd, S => gnd);
    ddr_bm_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_dm(i), ddr_dmr(i));
  end generate;

  bagen : for i in 0 to 1 generate
    da0 : FD port map ( Q => ddr_bar(i), C => clk0r, D => ba(i));
    ddr_ba_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ba(i), ddr_bar(i));
  end generate;

  dagen : for i in 0 to 13 generate
    da0 : FD port map ( Q => ddr_adr(i), C => clk0r, D => addr(i));
    ddr_ad_pad  : outpad generic map (tech => virtex4, level => sstl2_i) 
	port map (ddr_ad(i), ddr_adr(i));

  end generate;

  -- DQS generation
  dsqreg : FD port map ( Q => dqsn, C => clk180r, D => oe);
  dqsgen : for i in 0 to dbits/8-1 generate
    da0 : oddrc3e
    	port map ( Q => ddr_dqsin(i), C1 => clk90r,  C2 => clk270r, 
	CE => vcc, D1 => dqsn, D2 => gnd, R => gnd, S => gnd);
    doen : FD port map ( Q => ddr_dqsoen(i), C => clk0r, D => dqsoen);
    dqs_pad : iopad generic map (tech => virtex4, level => sstl2_i)
         port map (pad => ddr_dqs(i), i => ddr_dqsin(i), en => ddr_dqsoen(i), 
		o => ddr_dqsoutl(i));
  end generate;

  -- Data bus

  ddrref_pad : clkpad generic map (tech => virtex2) 
	port map (ddr_clk_fb, ddrclkfbl); 


    read_rstdel : process (clk_0r, lockl)
    begin
        if lockl = '0' then dll2rst <= (others => '1');
        elsif rising_edge(clk_0r) then
  	  dll2rst <= dll2rst(1 to 3) & '0';
        end if;
    end process;

    bufg7 : BUFG port map (I => rclk0, O => rclk0b);
    bufg8 : BUFG port map (I => rclk90, O => rclk90b);
--    bufg9 : BUFG port map (I => rclk270, O => rclk270b);
    rclk270b <= not rclk90b;
    clkread <= not rclk90b;

  nops : if rskew = 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS")
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;
  ps : if rskew /= 0 generate
    read_dll : DCM
      generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", 
	CLKOUT_PHASE_SHIFT => "FIXED", PHASE_SHIFT => rskew)
      port map ( CLKIN => ddrclkfbl, CLKFB => rclk0b, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll2rst(0), CLK0 => rclk0,
      CLK90 => rclk90, CLK270 => rclk270);
  end generate;

  ddgen : for i in 0 to dbits-1 generate
    qi : IDDR2
    port map ( Q0 => dqinl(i), Q1 => dqin(i), C0 => rclk90b, C1 => rclk270b, 
	       CE => vcc, D => ddr_dqin(i), R => gnd, S => gnd );
    dinq1 : FD port map ( Q => dqin(i+dbits), C => rclk270b, D => dqinl(i));
    dout : oddrc3e
	port map ( Q => ddr_dqout(i), C1 => clk0r, C2 => clk180r, CE => vcc,
		D1 => dqout(i+dbits), D2 => dqout(i), R => gnd, S => gnd);
    doen : FD port map ( Q => ddr_dqoen(i), C => clk0r, D => oen);
    dq_pad : iopad generic map (tech => virtex4, level => sstl2_i)
       port map (pad => ddr_dq(i), i => ddr_dqout(i), en => ddr_dqoen(i), o => ddr_dqin(i));
  end generate;

end;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
-- pragma translate_off
library unisim;
use unisim.BUFG;
use unisim.DCM;
use unisim.ODDR;
use unisim.FD;
use unisim.IDELAY;
use unisim.ISERDES;
use unisim.BUFIO;
use unisim.IDELAYCTRL;
-- pragma translate_on

library techmap;
use techmap.gencomp.all;
------------------------------------------------------------------
-- Virtex5 DDR2 PHY ----------------------------------------------
------------------------------------------------------------------

entity virtex5_ddr2_phy is
  generic (MHz : integer := 100; rstdelay : integer := 200;
           dbits : integer := 16; clk_mul : integer := 2; clk_div : integer := 2;
           ddelayb0 : integer := 0; ddelayb1 : integer := 0; ddelayb2 : integer := 0;
           ddelayb3 : integer := 0; ddelayb4 : integer := 0; ddelayb5 : integer := 0;
           ddelayb6 : integer := 0; ddelayb7 : integer := 0; 
           numidelctrl : integer := 4; norefclk : integer := 0; 
           tech : integer := virtex5; odten : integer := 0);

  port (
    rst        : in  std_ulogic;
    clk        : in  std_logic;        -- input clock
    clkref200  : in  std_logic;        -- input 200MHz clock
    clkout     : out std_ulogic;       -- system clock
    lock       : out std_ulogic;       -- DCM locked

    ddr_clk    : out std_logic_vector(2 downto 0);
    ddr_clkb   : out std_logic_vector(2 downto 0);
    ddr_cke    : out std_logic_vector(1 downto 0);
    ddr_csb    : out std_logic_vector(1 downto 0);
    ddr_web    : out std_ulogic;                       -- ddr write enable
    ddr_rasb   : out std_ulogic;                       -- ddr ras
    ddr_casb   : out std_ulogic;                       -- ddr cas
    ddr_dm     : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs    : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqsn   : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqsn
    ddr_ad     : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba     : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq     : inout  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_odt    : out std_logic_vector(1 downto 0);

    addr       : in  std_logic_vector (13 downto 0); -- data mask
    ba         : in  std_logic_vector ( 1 downto 0); -- data mask
    dqin       : out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout      : in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm         : in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen        : in  std_ulogic;
    dqs        : in  std_ulogic;
    dqsoen     : in  std_ulogic;
    rasn       : in  std_ulogic;
    casn       : in  std_ulogic;
    wen        : in  std_ulogic;
    csn        : in  std_logic_vector(1 downto 0);
    cke        : in  std_logic_vector(1 downto 0);
    cal_en     : in  std_logic_vector(dbits/8-1 downto 0);
    cal_inc    : in  std_logic_vector(dbits/8-1 downto 0);
    cal_rst    : in  std_logic;
    odt        : in  std_logic_vector(1 downto 0)
  );

end;

architecture rtl of virtex5_ddr2_phy is

  component DCM
    generic (
      CLKDV_DIVIDE : real := 2.0;
      CLKFX_DIVIDE : integer := 1;
      CLKFX_MULTIPLY : integer := 4;
      CLKIN_DIVIDE_BY_2 : boolean := false;
      CLKIN_PERIOD : real := 10.0;
      CLKOUT_PHASE_SHIFT : string := "NONE";
      CLK_FEEDBACK : string := "1X";
      DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
      DFS_FREQUENCY_MODE : string := "LOW";
      DLL_FREQUENCY_MODE : string := "LOW";
      DSS_MODE : string := "NONE";
      DUTY_CYCLE_CORRECTION : boolean := true;
      FACTORY_JF : bit_vector := X"C080";
      PHASE_SHIFT : integer := 0;
      STARTUP_WAIT : boolean := false 
    );
    port (
      CLKFB    : in  std_logic;
      CLKIN    : in  std_logic;
      DSSEN    : in  std_logic;
      PSCLK    : in  std_logic;
      PSEN     : in  std_logic;
      PSINCDEC : in  std_logic;
      RST      : in  std_logic;
      CLK0     : out std_logic;
      CLK90    : out std_logic;
      CLK180   : out std_logic;
      CLK270   : out std_logic;
      CLK2X    : out std_logic;
      CLK2X180 : out std_logic;
      CLKDV    : out std_logic;
      CLKFX    : out std_logic;
      CLKFX180 : out std_logic;
      LOCKED   : out std_logic;
      PSDONE   : out std_logic;
      STATUS   : out std_logic_vector (7 downto 0));
  end component;

  component BUFG port (O : out std_logic; I : in std_logic); end component;
  component ODDR
    generic
      ( DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
--        INIT : bit := '0';
        SRTYPE : string := "SYNC");
    port
      (
        Q : out std_ulogic;
        C : in std_ulogic;
        CE : in std_ulogic;
        D1 : in std_ulogic;
        D2 : in std_ulogic;
        R : in std_ulogic;
        S : in std_ulogic
      );
  end component;
  component FD
    generic ( INIT : bit := '0');
    port (  Q : out std_ulogic;
      C : in std_ulogic;
      D : in std_ulogic);
  end component;
  component IDDR
    generic ( DDR_CLK_EDGE : string := "SAME_EDGE";
        INIT_Q1 : bit := '0';
        INIT_Q2 : bit := '0';
        SRTYPE : string := "ASYNC");
    port
      ( Q1 : out std_ulogic;
        Q2 : out std_ulogic;
        C : in std_ulogic;
        CE : in std_ulogic;
        D : in std_ulogic;
        R : in std_ulogic;
        S : in std_ulogic);
  end component;

--  component BUFIO
--  port (  O : out std_ulogic;
--    I : in std_ulogic);
--  end component;

  component IDELAY
    generic ( IOBDELAY_TYPE : string := "DEFAULT";
              IOBDELAY_VALUE : integer := 0);
    port (  O : out std_ulogic;
      C : in std_ulogic;
      CE : in std_ulogic;
      I : in std_ulogic;
      INC : in std_ulogic;
      RST : in std_ulogic);
  end component;

--   component ISERDES
--      generic
--      (
--         BITSLIP_ENABLE : boolean := false;
--         DATA_RATE : string := "DDR";
--         DATA_WIDTH : integer := 4;
--         INIT_Q1 : bit := '0';
--         INIT_Q2 : bit := '0';
--         INIT_Q3 : bit := '0';
--         INIT_Q4 : bit := '0';
--         INTERFACE_TYPE : string := "MEMORY";
--         IOBDELAY : string := "NONE";
--         IOBDELAY_TYPE : string := "DEFAULT";
--         IOBDELAY_VALUE : integer := 0;
--         NUM_CE : integer := 2;
--         SERDES_MODE : string := "MASTER";
--         SRVAL_Q1 : bit := '0';
--         SRVAL_Q2 : bit := '0';
--         SRVAL_Q3 : bit := '0';
--         SRVAL_Q4 : bit := '0'
--      );
--      port
--      (
--         O : out std_ulogic;
--         Q1 : out std_ulogic;
--         Q2 : out std_ulogic;
--         Q3 : out std_ulogic;
--         Q4 : out std_ulogic;
--         Q5 : out std_ulogic;
--         Q6 : out std_ulogic;
--         SHIFTOUT1 : out std_ulogic;
--         SHIFTOUT2 : out std_ulogic;
--         BITSLIP : in std_ulogic;
--         CE1 : in std_ulogic;
--         CE2 : in std_ulogic;
--         CLK : in std_ulogic;
--         CLKDIV : in std_ulogic;
--         D : in std_ulogic;
--         DLYCE : in std_ulogic;
--         DLYINC : in std_ulogic;
--         DLYRST : in std_ulogic;
--         OCLK : in std_ulogic;
--         REV : in std_ulogic;
--         SHIFTIN1 : in std_ulogic;
--         SHIFTIN2 : in std_ulogic;
--         SR : in std_ulogic
--      );
--   end component;

   component IDELAYCTRL
   port (  RDY : out std_ulogic;
      REFCLK : in std_ulogic;
      RST : in std_ulogic);
  end component;

--signal vcc, gnd, dqsn, oe, lockl : std_ulogic;
signal vcc, gnd, oe, lockl : std_ulogic;
signal dqsn : std_logic_vector(dbits/8-1 downto 0);

signal ddr_clk_fb_outr : std_ulogic;
signal ddr_clk_fbl, fbclk : std_ulogic;
signal ddr_rasnr, ddr_casnr, ddr_wenr : std_ulogic;
signal ddr_clkl, ddr_clkbl : std_logic_vector(2 downto 0);
signal ddr_csnr, ddr_ckenr, ckel : std_logic_vector(1 downto 0);
signal clk_0ro, clk_90ro, clk_180ro, clk_270ro : std_ulogic;
signal clk_0r, clk_90r, clk_180r, clk_270r : std_ulogic;
signal clk0r, clk90r, clk180r, clk270r : std_ulogic;
signal locked, vlockl, ddrclkfbl, dllfb : std_ulogic;

signal ddr_dqin, ddr_dqin_nodel : std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqout     : std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_dqoen     : std_logic_vector (dbits-1 downto 0); -- ddr data
signal ddr_adr       : std_logic_vector (13 downto 0);   -- ddr address
signal ddr_bar       : std_logic_vector (1 downto 0);   -- ddr address
signal ddr_dmr       : std_logic_vector (dbits/8-1 downto 0);   -- ddr address
signal ddr_dqsin     : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoen    : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal ddr_dqsoutl   : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal dqsdel, dqsclk, dqsclkn : std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
signal da            : std_logic_vector (dbits-1 downto 0); -- ddr data
signal dqinl         : std_logic_vector (dbits-1 downto 0); -- ddr data
signal dllrst        : std_logic_vector(0 to 3);
signal dll0rst, dll2rst : std_logic_vector(0 to 3);
signal mlock, mclkfb, mclk, mclkfx, mclk0 : std_ulogic;
signal rclk270b, rclk90b, rclk0b : std_ulogic;
signal rclk270, rclk90, rclk0 : std_ulogic;
signal clk200, clk200_0, clk200fb, clk200fx, lock200 : std_logic;
signal odtl : std_logic_vector(1 downto 0);
signal refclk_rdy : std_logic_vector(numidelctrl-1 downto 0);

constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

type ddelay_type is array (7 downto 0) of integer;
constant ddelay : ddelay_type := (ddelayb0, ddelayb1, ddelayb2,
                                  ddelayb3, ddelayb4, ddelayb5,
                                  ddelayb6, ddelayb7);

attribute syn_noprune : boolean;
attribute syn_noprune of IDELAYCTRL : component is true;
attribute syn_keep : boolean;
attribute syn_keep of dqsclk : signal is true;
attribute syn_preserve : boolean;
attribute syn_preserve of dqsclk : signal is true;
attribute syn_keep of dqsn : signal is true;
attribute syn_preserve of dqsn : signal is true;

-- To prevent synplify 9.4 to remove any of these registers.
attribute syn_noprune of FD : component is true;
attribute syn_noprune of IDDR : component is true;
attribute syn_noprune of ODDR : component is true;

attribute keep : boolean;
attribute keep of mclkfx : signal is true;
attribute keep of clk_90ro : signal is true;
attribute syn_keep of mclkfx : signal is true;
attribute syn_keep of clk_90ro : signal is true;

begin

   -- Generate 200 MHz ref clock if not supplied
  refclkx : if norefclk = 0 generate
    buf_clk200 : BUFG port map( I => clkref200, O => clk200);
    lock200 <= '1';
  end generate;
  
  norefclkx : if norefclk /= 0 generate
    bufg0 : BUFG port map (I => clk200fx, O => clk200);
    bufg1 : BUFG port map (I => clk200_0, O => clk200fb);

    HMODE_dll200 : if (tech = virtex4 and ((200 >= 210) or (MHz >= 210))) 
                      or (tech = virtex5 and ((200 >= 140) or (MHz >= 140))) generate
      dll200 : DCM
        generic map (CLKFX_MULTIPLY => 2000/MHz, CLKFX_DIVIDE => 10,
                     DFS_FREQUENCY_MODE => "HIGH", DLL_FREQUENCY_MODE => "HIGH")
        port map ( CLKIN => clk, CLKFB => clk200fb, DSSEN => gnd, PSCLK => gnd,
        PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => clk200_0,
        LOCKED => lock200, CLKFX => clk200fx);
    end generate;
    LMODE_dll200 : if not ((tech = virtex4 and ((200 >= 210) or (MHz >= 210))) 
                      or (tech = virtex5 and ((200 >= 140) or (MHz >= 140)))) generate
      dll200 : DCM
        generic map (CLKFX_MULTIPLY => 2000/MHz, CLKFX_DIVIDE => 10,
                     DFS_FREQUENCY_MODE => "LOW", DLL_FREQUENCY_MODE => "LOW")
        port map ( CLKIN => clk, CLKFB => clk200fb, DSSEN => gnd, PSCLK => gnd,
        PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => clk200_0,
        LOCKED => lock200, CLKFX => clk200fx);
    end generate;
   
  end generate;

  -- Delay control
  idelctrl : for i in 0 to numidelctrl-1 generate
     u : IDELAYCTRL port map (rst => dllrst(0), refclk => clk200, rdy => refclk_rdy(i));
  end generate;

  oe <= not oen;
  vcc <= '1'; gnd <= '0';
  
  -- Optional DDR clock multiplication

  noclkscale : if clk_mul = clk_div generate
    --mclk <= clk;
    dll0rst <= dllrst;
    mlock <= '1';
    mbufg0 : BUFG port map (I => clk, O => mclk);
  end generate;

  clkscale : if clk_mul /= clk_div generate

    rstdel : process (clk, rst)
    begin
        if rst = '0' then dll0rst <= (others => '1');
        elsif rising_edge(clk) then
          dll0rst <= dll0rst(1 to 3) & '0';
        end if;
    end process;

    bufg0 : BUFG port map (I => mclkfx, O => mclk);
    bufg1 : BUFG port map (I => mclk0, O => mclkfb);

    HMODE_dllm : if (tech = virtex4 and (((MHz*clk_mul)/clk_div >= 210) or (MHz >= 210))) 
                    or (tech = virtex5 and (((MHz*clk_mul)/clk_div >= 140) or (MHz >= 140))) generate
      dllm : DCM
        generic map (CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div,
                     DFS_FREQUENCY_MODE => "HIGH", DLL_FREQUENCY_MODE => "HIGH")
        port map ( CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
        PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => mclk0,
        LOCKED => mlock, CLKFX => mclkfx );
    end generate;
    LMODE_dllm : if not ((tech = virtex4 and (((MHz*clk_mul)/clk_div >= 210) or (MHz >= 210))) 
                    or (tech = virtex5 and (((MHz*clk_mul)/clk_div >= 140) or (MHz >= 140)))) generate
      dllm : DCM
        generic map (CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div,
                     DFS_FREQUENCY_MODE => "LOW", DLL_FREQUENCY_MODE => "LOW")
        port map ( CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
        PSEN => gnd, PSINCDEC => gnd, RST => dll0rst(0), CLK0 => mclk0,
        LOCKED => mlock, CLKFX => mclkfx );
    end generate;
  end generate;
    
  -- DDR clock generation

--  bufg1 : BUFG port map (I => clk_0ro, O => clk0r);
  clk0r <= mclk;

  bufg2 : BUFG port map (I => clk_90ro, O => clk90r);
--  bufg3 : BUFG port map (I => clk_180ro, O => clk180r);
  clk180r <= not mclk;
--  bufg4 : BUFG port map (I => clk_270ro, O => clk270r);
  clkout <= clk0r;
--  dllfb  <= clk0r;  
  dllfb  <= clk90r;

    HMODE_dll : if (tech = virtex4 and ((MHz*clk_mul)/clk_div >= 150))
                   or (tech = virtex5 and ((MHz*clk_mul)/clk_div >= 120)) generate
      dll : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2, 
                             DFS_FREQUENCY_MODE => "HIGH", DLL_FREQUENCY_MODE => "HIGH", --"HIGH")
                             PHASE_SHIFT => 64, CLKOUT_PHASE_SHIFT => "FIXED")--, CLKIN_PERIOD => real((1000*clk_div)/(MHz*clk_mul)))
          port map ( CLKIN => mclk, CLKFB => dllfb, DSSEN => gnd, PSCLK => gnd,
          PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_90ro,
          CLK90 => open, CLK180 => open, CLK270 => open,
          LOCKED => lockl);
    end generate;
    LMODE_dll : if not ((tech = virtex4 and ((MHz*clk_mul)/clk_div >= 150))
                   or (tech = virtex5 and ((MHz*clk_mul)/clk_div >= 120))) generate
      dll : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2, 
                             DFS_FREQUENCY_MODE => "LOW", DLL_FREQUENCY_MODE => "LOW", --"HIGH")
                             PHASE_SHIFT => 64, CLKOUT_PHASE_SHIFT => "FIXED")--, CLKIN_PERIOD => real((1000*clk_div)/(MHz*clk_mul)))
          port map ( CLKIN => mclk, CLKFB => dllfb, DSSEN => gnd, PSCLK => gnd,
          PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_90ro,
          CLK90 => open, CLK180 => open, CLK270 => open,
          LOCKED => lockl);
    end generate;

--  dll : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2, CLKIN_PERIOD => 6.25,
--                         DFS_FREQUENCY_MODE => "LOW", DLL_FREQUENCY_MODE => "HIGH") --"HIGH")
--      port map ( CLKIN => mclk, CLKFB => dllfb, DSSEN => gnd, PSCLK => gnd,
--      PSEN => gnd, PSINCDEC => gnd, RST => dllrst(0), CLK0 => clk_0ro,
--      CLK90 => clk_90ro, CLK180 => clk_180ro, CLK270 => clk_270ro,
--      LOCKED => lockl);

  rstdel : process (mclk, rst, mlock, lock200)
  begin
      if rst = '0' or mlock = '0' or lock200 = '0' then dllrst <= (others => '1');
      elsif rising_edge(mclk) then
         dllrst <= dllrst(1 to 3) & '0';
      end if;
  end process;

  rdel : if rstdelay /= 0 generate
    --rcnt : process (clk_0r)
    rcnt : process (clk0r)
    variable cnt : std_logic_vector(15 downto 0);
    variable vlock, co : std_ulogic;
    begin
      --if rising_edge(clk_0r) then
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
  lock <= locked and orv(refclk_rdy);

  -- Generate external DDR clock
  ddrclocks : for i in 0 to 2 generate
    dclk0r : ODDR port map ( Q => ddr_clkl(i), C => clk90r, CE => vcc,
                             D1 => vcc, D2 => gnd, R => gnd, S => gnd);
    ddrclk_pad : outpad generic map (tech => virtex5, level => sstl18_i) 
      port map (ddr_clk(i), ddr_clkl(i));
-- Diff ddr_clk
--    ddrclk_pad : outpad_ds generic map(tech => virtex5, level => sstl18_ii)
--      port map (ddr_clk(i), ddr_clkb(i), ddr_clkl(i), gnd);
    dclk0rb : ODDR port map ( Q => ddr_clkbl(i), C => clk90r, CE => vcc,
                              D1 => gnd, D2 => vcc, R => gnd, S => gnd);
    ddrclkb_pad : outpad generic map (tech => virtex5, level => sstl18_i)
      port map (ddr_clkb(i), ddr_clkbl(i));
  end generate;

  -- ODT pads
  odtgen : for i in 0 to 1 generate
    odtl(i) <= locked and orv(refclk_rdy) and odt(i);
    ddr_odt_pad  : outpad generic map (tech => virtex5, level => sstl18_i)
      port map (ddr_odt(i), odtl(i));
  end generate;

  ddrbanks : for i in 0 to 1 generate
    csn0gen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_csnr(i), C => clk0r, CE => vcc,
                 D1 => csn(i), D2 => csn(i), R => gnd, S => gnd);
    csn0_pad : outpad generic map (tech => virtex5, level => sstl18_i) 
      port map (ddr_csb(i), ddr_csnr(i));

    ckel(i) <= cke(i) and locked;
    ckegen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_ckenr(i), C => clk0r, CE => vcc,
                 D1 => ckel(i), D2 => ckel(i), R => gnd, S => gnd);
    cke_pad : outpad generic map (tech => virtex5, level => sstl18_i) 
      port map (ddr_cke(i), ddr_ckenr(i));
  end generate;

  rasgen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
    port map ( Q => ddr_rasnr, C => clk0r, CE => vcc,
               D1 => rasn, D2 => rasn, R => gnd, S => gnd);
  rasn_pad : outpad generic map (tech => virtex5, level => sstl18_i) 
    port map (ddr_rasb, ddr_rasnr);

  casgen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
    port map ( Q => ddr_casnr, C => clk0r, CE => vcc,
               D1 => casn, D2 => casn, R => gnd, S => gnd);
  casn_pad : outpad generic map (tech => virtex5, level => sstl18_i) 
    port map (ddr_casb, ddr_casnr);

  wengen : ODDR  generic map (DDR_CLK_EDGE => "SAME_EDGE")
    port map ( Q => ddr_wenr, C => clk0r, CE => vcc,
               D1 => wen, D2 => wen, R => gnd, S => gnd);
  wen_pad : outpad generic map (tech => virtex5, level => sstl18_i) 
    port map (ddr_web, ddr_wenr);

  dmgen : for i in 0 to dbits/8-1 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_dmr(i), C => clk0r, CE => vcc,
                 D1 => dm(i+dbits/8), D2 => dm(i), R => gnd, S => gnd);
    ddr_bm_pad  : outpad generic map (tech => virtex5, level => sstl18_i) 
      port map (ddr_dm(i), ddr_dmr(i));
  end generate;

  bagen : for i in 0 to 1 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_bar(i), C => clk0r, CE => vcc,
                 D1 => ba(i), D2 => ba(i), R => gnd, S => gnd);
    ddr_ba_pad  : outpad generic map (tech => virtex5, level => sstl18_i)
      port map (ddr_ba(i), ddr_bar(i));
  end generate;

  dagen : for i in 0 to 13 generate
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_adr(i), C => clk0r, CE => vcc,
                 D1 => addr(i), D2 => addr(i), R => gnd, S => gnd);
    ddr_ad_pad  : outpad generic map (tech => virtex5, level => sstl18_i) 
      port map (ddr_ad(i), ddr_adr(i));
  end generate;

  -- DQS generation
  --dsqreg : FD port map ( Q => dqsn, C => clk180r, D => oe);
  dqsgen : for i in 0 to dbits/8-1 generate
    dsqreg : FD port map ( Q => dqsn(i), C => clk180r, D => oe);
    da0 : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
      port map ( Q => ddr_dqsin(i), C => clk90r, CE => vcc,
                 --D1 => dqsn, D2 => gnd, R => gnd, S => gnd);
                 D1 => dqsn(i), D2 => gnd, R => gnd, S => gnd);
    doen : FD port map ( Q => ddr_dqsoen(i), C => clk0r, D => dqsoen);

    dqs_pad : iopad_ds generic map (tech => virtex5, level => sstl18_ii)
      port map (padp => ddr_dqs(i), padn => ddr_dqsn(i),i => ddr_dqsin(i), 
                en => ddr_dqsoen(i), o => ddr_dqsoutl(i));

--    del_dqs0 : IDELAY generic map(IOBDELAY_TYPE => "FIXED", IOBDELAY_VALUE => 10)
--      port map(O => dqsclk(i), I => ddr_dqsoutl(i), C => gnd, CE => gnd,
--               INC => gnd, RST => dllrst(0));
--    --buf_dqs0 : BUFIO port map(O => dqsclk(i), I => dqsdel(i));
--    dqsclkn(i) <= not dqsclk(i);
  end generate;

  -- Data bus
    ddgen : for i in 0 to dbits-1 generate
      del_dq0 : IDELAY generic map(IOBDELAY_TYPE => "VARIABLE", IOBDELAY_VALUE => ddelay(i/8))
        --port map(O => ddr_dqin(i), I => ddr_dqin_nodel(i), C => clk_270r, CE => cal_en(i/8),
        port map(O => ddr_dqin(i), I => ddr_dqin_nodel(i), C => clk0r, CE => cal_en(i/8),
                 INC => cal_inc(i/8), RST => cal_rst);

      qi : IDDR generic map (DDR_CLK_EDGE => "OPPOSITE_EDGE")
      port map ( Q1 => dqinl(i),   --(i+dbits), -- 1-bit output for positive edge of clock 
                 Q2 => dqin(i),    --dqin(i), -- 1-bit output for negative edge of clock 
                 --C => clk_90r,     --clk270r, --dqsclk((2*i)/dbits), -- 1-bit clock input 
                 C => clk180r,     --clk270r, --dqsclk((2*i)/dbits), -- 1-bit clock input 
                 CE => vcc,        -- 1-bit clock enable input 
                 D => ddr_dqin(i), -- 1-bit DDR data input 
                 R => gnd,         -- 1-bit reset 
                 S => gnd          -- 1-bit set 
               );
      --dinq1 : FD port map ( Q => dqin(i+dbits), C => clk_270r, D => dqinl(i));
      dinq1 : FD port map ( Q => dqin(i+dbits), C => clk0r, D => dqinl(i));

      --dqi : ISERDES generic map(IOBDELAY => "IFD", IOBDELAY_TYPE => "FIXED", IOBDELAY_VALUE => 0)
      --  port map(O => open, Q1 => dqin(i), Q2 => dqin(i+dbits), Q3 => open, Q4 => open, Q5 => open, 
      --           Q6 => open, SHIFTOUT1 => open, SHIFTOUT2 => open, BITSLIP => gnd, 
      --           CE1 => vcc, CE2 => vcc, CLK => dqsclk(i/8), CLKDIV => clk0r, D => ddr_dqin(i), 
      --           DLYCE => gnd, DLYINC => gnd, DLYRST => gnd, OCLK => clk0r, REV => gnd, 
      --           SHIFTIN1 => gnd, SHIFTIN2 => gnd, SR => gnd);

      dout : ODDR generic map (DDR_CLK_EDGE => "SAME_EDGE")
        port map ( Q => ddr_dqout(i), C => clk0r, CE => vcc,
                   D1 => dqout(i+dbits), D2 => dqout(i), R => gnd, S => gnd);
      doen : FD port map ( Q => ddr_dqoen(i), C => clk0r, D => oen);

      dq_pad : iopad generic map (tech => virtex5, level => sstl18_ii)
         port map (pad => ddr_dq(i), i => ddr_dqout(i), en => ddr_dqoen(i), o => ddr_dqin_nodel(i)); --o => ddr_dqin(i)); 
    end generate;
end;


------------------------------------------------------------------
-- Spartan 3A DDR2 PHY -------------------------------------------
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
-- pragma translate_off
library unisim;
use unisim.BUFG;
use unisim.DCM;
use unisim.IDDR2;
use unisim.ODDR2;
use unisim.FD;
use unisim.BUFIO;
-- pragma translate_on

library techmap;
use techmap.gencomp.all;

entity spartan3a_ddr2_phy is
  generic (MHz         : integer := 125; rstdelay : integer := 200;
           dbits       : integer := 16;  clk_mul  : integer := 2;
           clk_div     : integer := 2;   tech     : integer := spartan3;
           rskew       : integer := 0);
  port (   rst         : in  std_ulogic;
           clk         : in  std_logic;        -- input clock
           clkout      : out std_ulogic;       -- DDR clock
           lock        : out std_ulogic;       -- DCM locked
           
           ddr_clk     : out std_logic_vector(2 downto 0);
           ddr_clkb    : out std_logic_vector(2 downto 0);
           ddr_clk_fb_out : out std_logic;
           ddr_clk_fb  : in  std_logic;
           ddr_cke     : out std_logic_vector(1 downto 0);
           ddr_csb     : out std_logic_vector(1 downto 0);
           ddr_web     : out std_ulogic;                               -- ddr write enable
           ddr_rasb    : out std_ulogic;                               -- ddr ras
           ddr_casb    : out std_ulogic;                               -- ddr cas
           ddr_dm      : out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
           ddr_dqs     : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
           ddr_dqsn    : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqsn
           ddr_ad      : out std_logic_vector (13 downto 0);           -- ddr address
           ddr_ba      : out std_logic_vector (1 downto 0);            -- ddr bank address
           ddr_dq      : inout  std_logic_vector (dbits-1 downto 0);   -- ddr data
           ddr_odt     : out std_logic_vector(1 downto 0);

           addr        : in  std_logic_vector (13 downto 0);           -- row address
           ba          : in  std_logic_vector ( 1 downto 0);           -- bank address
           dqin        : out std_logic_vector (dbits*2-1 downto 0);    -- ddr input data
           dqout       : in  std_logic_vector (dbits*2-1 downto 0);    -- ddr output data
           dm          : in  std_logic_vector (dbits/4-1 downto 0);    -- data mask
           oen         : in  std_ulogic;
           dqs         : in  std_ulogic;
           dqsoen      : in  std_ulogic;
           rasn        : in  std_ulogic;
           casn        : in  std_ulogic;
           wen         : in  std_ulogic;
           csn         : in  std_logic_vector(1 downto 0);
           cke         : in  std_logic_vector(1 downto 0);
           cal_pll     : in  std_logic_vector(1 downto 0);
           odt         : in  std_logic_vector(1 downto 0));
end;

architecture rtl of spartan3a_ddr2_phy is
  component DCM
    generic (CLKDV_DIVIDE          :     real       := 2.0;
             CLKFX_DIVIDE          :     integer    := 1;
             CLKFX_MULTIPLY        :     integer    := 4;
             CLKIN_DIVIDE_BY_2     :     boolean    := false;
             CLKIN_PERIOD          :     real       := 10.0;
             CLKOUT_PHASE_SHIFT    :     string     := "NONE";
             CLK_FEEDBACK          :     string     := "1X";
             DESKEW_ADJUST         :     string     := "SYSTEM_SYNCHRONOUS";
             DFS_FREQUENCY_MODE    :     string     := "LOW";
             DLL_FREQUENCY_MODE    :     string     := "LOW";
             DSS_MODE              :     string     := "NONE";
             DUTY_CYCLE_CORRECTION :     boolean    := true;
             FACTORY_JF            :     bit_vector := X"C080";
             PHASE_SHIFT           :     integer    := 0;
             STARTUP_WAIT          :     boolean    := false);
    port (   CLKFB                 : in  std_logic;
             CLKIN                 : in  std_logic;
             DSSEN                 : in  std_logic;
             PSCLK                 : in  std_logic;
             PSEN                  : in  std_logic;
             PSINCDEC              : in  std_logic;
             RST                   : in  std_logic;
             CLK0                  : out std_logic;
             CLK90                 : out std_logic;
             CLK180                : out std_logic;
             CLK270                : out std_logic;
             CLK2X                 : out std_logic;
             CLK2X180              : out std_logic;
             CLKDV                 : out std_logic;
             CLKFX                 : out std_logic;
             CLKFX180              : out std_logic;
             LOCKED                : out std_logic;
             PSDONE                : out std_logic;
             STATUS                : out std_logic_vector (7 downto 0));
  end component;

  component BUFG
    port (O : out std_logic;
          I : in std_logic);
  end component;

  component ODDR2
    generic (DDR_ALIGNMENT : string := "NONE"; -- Sets output alignment to "NONE", "C0" or "C1"
             INIT : bit := '0';                -- Sets initial state of the Q0  
             SRTYPE : string := "SYNC");       -- Specifies "SYNC" or "ASYNC" set/reset
    port (   Q  : out std_ulogic;              -- 1-bit DDR output data
             C0 : in  std_ulogic;              -- 1-bit clock input
             C1 : in  std_ulogic;              -- 1-bit clock input
             CE : in  std_ulogic;              -- 1-bit clock enable input
             D0 : in  std_ulogic;              -- 1-bit data input (associated with C1)
             D1 : in  std_ulogic;              -- 1-bit data input (associated with C1)
             R  : in  std_ulogic;              -- 1-bit reset input
             S  : in  std_ulogic);             -- 1-bit set input
  end component;

  component FD
    generic (INIT : bit := '0');
    port (   Q : out std_ulogic;
             C : in std_ulogic;
             D : in std_ulogic);
  end component;

  component IDDR2
    generic (DDR_ALIGNMENT : string := "NONE"; -- Sets output alignment to "NONE", "C0" or "C1"
             INIT_Q0 : bit := '0';             -- Sets initial state of the Q0
             INIT_Q1 : bit := '0';             -- Sets initial state of the Q1
             SRTYPE  : string := "SYNC");      -- Specifies "SYNC" or "ASYNC" set/reset
    port (   Q0 : out std_ulogic;              -- 1-bit output captured with C0 clock
             Q1 : out std_ulogic;              -- 1-bit output captured with C1 clock
             C0 : in  std_ulogic;              -- 1-bit clock input
             C1 : in  std_ulogic;              -- 1-bit clock input
             CE : in  std_ulogic;              -- 1-bit clock enable input
             D  : in  std_ulogic;              -- 1-bit DDR data input
             R  : in  std_ulogic;              -- 1-bit reset input
             S  : in  std_ulogic);             -- 1-bit set input
  end component;

  signal vcc, gnd, oe, lockl : std_ulogic;
  signal dqsn                : std_logic_vector(dbits/8-1 downto 0);

  signal ddr_rasnr, ddr_casnr, ddr_wenr      : std_ulogic;
  signal ddr_clkl, ddr_clkbl                 : std_logic_vector(2 downto 0);
  signal ddr_csnr, ddr_ckenr, ckel           : std_logic_vector(1 downto 0);
  signal ddr_clk_fbl, ddr_clk_fb_outl        : std_ulogic;
  signal clk_90ro                            : std_ulogic;
  signal clk0r, clk90r, clk180r, clk270r     : std_ulogic;
  signal rclk0b, rclk90b, rclk180b, rclk270b : std_ulogic;
  signal rclk0, rclk90, rclk270              : std_ulogic;
  signal rclk0b_high, rclk90b_high, rclk270b_high : std_ulogic;
  signal rclk0_high, rclk90_high, rclk270_high : std_ulogic;
  signal locked, vlockl, dllfb               : std_ulogic;

  signal ddr_dqin                            : std_logic_vector (dbits-1 downto 0);    -- ddr data
  signal ddr_dqout                           : std_logic_vector (dbits-1 downto 0);    -- ddr data
  signal ddr_dqoen                           : std_logic_vector (dbits-1 downto 0);    -- ddr data
  signal ddr_adr                             : std_logic_vector (13 downto 0);         -- ddr row address
  signal ddr_bar                             : std_logic_vector (1 downto 0);          -- ddr bank address
  signal ddr_dmr                             : std_logic_vector (dbits/8-1 downto 0);  -- ddr mask
  signal ddr_dqsin                           : std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
  signal ddr_dqsoen                          : std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
  signal ddr_dqsoutl                         : std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
  signal dqinl                               : std_logic_vector (dbits*2-1 downto 0);  -- ddr data
  signal dllrst                              : std_ulogic;
  signal dll0rst                             : std_ulogic;
  signal dll1rst                             : std_ulogic;
  signal mlock, mclkfb, mclk, mclkfx, mclk0  : std_ulogic;
  signal odtl                                : std_logic_vector(1 downto 0);

  --signals needed for alignment with DQS
  signal dm_delay                            : std_logic_vector (dbits/8-1 downto 0);      
  signal dqout_delay                         : std_logic_vector (dbits-1 downto 0);

  constant DDR_FREQ : integer := (MHz * clk_mul) / clk_div;

  attribute keep                   : boolean;
  attribute syn_keep               : boolean;
  attribute syn_preserve           : boolean;
  attribute syn_keep of dqsn       : signal is true;
  attribute syn_preserve of dqsn   : signal is true;
  attribute keep of mclkfx         : signal is true;
  attribute keep of clk_90ro       : signal is true;
  attribute syn_keep of mclkfx     : signal is true;
  attribute syn_keep of clk_90ro   : signal is true;

  -- To prevent synplify 9.4 to remove any of these registers.
  attribute syn_noprune : boolean;
  attribute syn_noprune of FD : component is true;
  attribute syn_noprune of IDDR2 : component is true;
  attribute syn_noprune of ODDR2 : component is true;

begin

  oe <= not oen;
  vcc <= '1'; gnd <= '0';
  
  -- Optional DDR clock multiplication

  noclkscale : if clk_mul = clk_div generate
    mlock <= '1';
    mbufg0 : BUFG port map (I => clk, O => mclk);
  end generate;

  clkscale : if clk_mul /= clk_div generate
    rstdel : process (clk, rst)
    begin
      if rst = '0' then
        dll0rst <= '1';
      elsif rising_edge(clk) then
        dll0rst <= '0';
      end if;
    end process;

    bufg0 : BUFG port map (I => mclkfx, O => mclk);
    bufg1 : BUFG port map (I => mclk0,  O => mclkfb);

    dllm : DCM
      generic map (CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div)
      port map (CLKIN => clk, CLKFB => mclkfb, DSSEN => gnd, PSCLK => gnd,
                PSEN => gnd, PSINCDEC => gnd, RST => dll0rst, CLK0 => mclk0,
                LOCKED => mlock, CLKFX => mclkfx );
  end generate;

  -- DDR clock generation (90 degrees phase-shifted DLL)

  bufg2 : BUFG port map (I => clk_90ro, O => clk90r);
  dllfb <= clk90r;

  dll : DCM
    generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2, 
                 CLKOUT_PHASE_SHIFT => "FIXED", PHASE_SHIFT => 64)
    port map (CLKIN => mclk, CLKFB => dllfb, DSSEN => gnd, PSCLK => gnd,
              PSEN => gnd, PSINCDEC => gnd, RST => dllrst, CLK0 => clk_90ro,
              CLK90 => open, CLK180 => open, CLK270 => open,
              LOCKED => lockl);

  clk0r   <= mclk;
  clk180r <= not mclk;
  clk270r <= not clk90r;
  clkout  <= mclk;
  
  rstdel : process (mclk, rst, mlock)
  begin
    if rst = '0' or mlock = '0' then
      dllrst <= '1';
    elsif rising_edge(mclk) then
      dllrst <= '0';
    end if;
  end process;

  rdel : if rstdelay /= 0 generate
    rcnt : process (clk0r)
      variable cnt : std_logic_vector(15 downto 0);
      variable vlock, co : std_ulogic;
    begin
      if rising_edge(clk0r) then
        co := cnt(15);
        vlockl <= vlock;
        if lockl = '0' then
          cnt := conv_std_logic_vector(rstdelay*DDR_FREQ, 16);
          vlock := '0';
        elsif vlock = '0' then
          cnt := cnt -1;
          vlock := cnt(15) and not co;
        end if;
      end if;
      if lockl = '0' then
        vlock := '0';
      end if;
    end process;
  end generate;

  locked <= lockl when rstdelay = 0 else vlockl;
  lock   <= locked;

  -- Generate external DDR clock
  ddrclocks : for i in 0 to 2 generate
    dclk0r : ODDR2
      port map (Q => ddr_clkl(i), C0 => clk90r, C1 => clk270r, CE => vcc,
                D0 => vcc, D1 => gnd, R => gnd, S => gnd);
    ddrclk_pad : outpad
      generic map (tech => virtex4, level => sstl18_i) 
      port map (ddr_clk(i), ddr_clkl(i));

    dclk0rb : ODDR2
      port map (Q => ddr_clkbl(i), C0 => clk90r, C1 => clk270r, CE => vcc,
                D0 => gnd, D1 => vcc, R => gnd, S => gnd);
    ddrclkb_pad : outpad
      generic map (tech => virtex4, level => sstl18_i)
      port map (ddr_clkb(i), ddr_clkbl(i));
  end generate;

  -- Generate the DDR clock to be fed back for DQ synchronization
  dclkfb0r : ODDR2
    port map (Q => ddr_clk_fb_outl, C0 => clk90r, C1 => clk270r, CE => vcc,
              D0 => vcc, D1 => gnd, R => gnd, S => gnd);
  ddrclkfb_pad : outpad
    generic map (tech => virtex4, level => sstl18_i) 
    port map (ddr_clk_fb_out, ddr_clk_fb_outl);

  -- The above clock fed back for DQ synchronization
  ddrref_pad : clkpad generic map (tech => virtex4) 
	port map (ddr_clk_fb, ddr_clk_fbl); 
  
  -- ODT pads
  odtgen : for i in 0 to 1 generate
    odtl(i) <= locked and odt(i);
    ddr_odt_pad : outpad
      generic map (tech => virtex4, level => sstl18_i)
      port map (ddr_odt(i), odtl(i));
  end generate;

  --  DDR single-edge control signals
  ddrbanks : for i in 0 to 1 generate
    csn0gen : FD
      port map ( Q => ddr_csnr(i), C => clk0r, D => csn(i));
    csn0_pad : outpad
      generic map (tech => virtex4, level => sstl18_i) 
      port map (ddr_csb(i), ddr_csnr(i));

    ckel(i) <= cke(i) and locked;
    ckegen : FD
      port map ( Q => ddr_ckenr(i), C => clk0r, D => ckel(i));
    cke_pad : outpad
      generic map (tech => virtex4, level => sstl18_i) 
      port map (ddr_cke(i), ddr_ckenr(i));
  end generate;

  rasgen : FD
    port map ( Q => ddr_rasnr, C => clk0r, D => rasn);
  rasn_pad : outpad
    generic map (tech => virtex4, level => sstl18_i) 
    port map (ddr_rasb, ddr_rasnr);

  casgen : FD
    port map ( Q => ddr_casnr, C => clk0r, D => casn);
  casn_pad : outpad
    generic map (tech => virtex4, level => sstl18_i) 
    port map (ddr_casb, ddr_casnr);

  wengen : FD
    port map ( Q => ddr_wenr, C => clk0r, D => wen);
  wen_pad : outpad
    generic map (tech => virtex4, level => sstl18_i) 
    port map (ddr_web, ddr_wenr);

  bagen : for i in 0 to 1 generate
    ba0 : FD
      port map ( Q => ddr_bar(i), C => clk0r, D => ba(i));
    ddr_ba_pad  : outpad
      generic map (tech => virtex4, level => sstl18_i)
      port map (ddr_ba(i), ddr_bar(i));
  end generate;

  addrgen : for i in 0 to 13 generate
    addr0 : FD
      port map ( Q => ddr_adr(i), C => clk0r, D => addr(i));
    ddr_ad_pad : outpad
      generic map (tech => virtex4, level => sstl18_i) 
      port map (ddr_ad(i), ddr_adr(i));
  end generate;

  -- Data mask (DM) generation
  dmgen : for i in 0 to dbits/8-1 generate
    dq_delay : FD
      port map ( Q => dm_delay(i), C => clk0r, D => dm(i));
    dm0 : ODDR2
      generic map (DDR_ALIGNMENT => "NONE")
      port map (Q => ddr_dmr(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                D0 => dm(i+dbits/8), D1 => dm_delay(i), R => gnd, S => gnd);
    ddr_bm_pad : outpad
      generic map (tech => virtex4, level => sstl18_i) 
      port map (ddr_dm(i), ddr_dmr(i));
  end generate;

  -- Data strobe (DQS) generation
  dqsgen : for i in 0 to dbits/8-1 generate
    dsqreg : FD port map ( Q => dqsn(i), C => clk180r, D => oe);
    da0 : ODDR2
      port map ( Q => ddr_dqsin(i), C0 => clk90r, C1 => clk270r, CE => vcc,
                 D0 => dqsn(i), D1 => gnd, R => gnd, S => gnd);
    doen : FD
      port map ( Q => ddr_dqsoen(i), C => clk0r, D => dqsoen);

    dqs_pad : iopad_ds
      generic map (tech => virtex5, level => sstl18_ii)
      port map (padp => ddr_dqs(i), padn => ddr_dqsn(i), i => ddr_dqsin(i), 
                en => ddr_dqsoen(i), o => ddr_dqsoutl(i));
  end generate;

  -- Phase shift the feedback clock and use it to latch DQ
  rstphase : process (ddr_clk_fbl, rst, lockl)
  begin
    if rst = '0' or lockl = '0' then
      dll1rst <= '1';
    elsif rising_edge(ddr_clk_fbl) then
      dll1rst <= '0';
    end if;
  end process;

  bufg7 : BUFG port map (I => rclk90,  O => rclk90b);
  bufg8 : BUFG port map (I => rclk270, O => rclk270b);

  read_dll : DCM
    generic map (clkin_period => 8.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", 
                 CLKOUT_PHASE_SHIFT => "VARIABLE", PHASE_SHIFT => rskew)
    port map ( CLKIN => ddr_clk_fbl, CLKFB => rclk90b, DSSEN => gnd, PSCLK => mclk,
               PSEN => cal_pll(0), PSINCDEC => cal_pll(1), RST => dll1rst, CLK0 => rclk90,
               CLK90 => rclk180b, CLK180 => rclk270);
  
  -- Data bus
  ddgen : for i in 0 to dbits-1 generate
    qi : IDDR2
      port map (Q0 => dqinl(i+dbits), -- 1-bit output for positive edge of C0
                Q1 => dqinl(i),       -- 1-bit output for negative edge of C1
                C0 => rclk90b,        -- 1-bit clock input 
                C1 => rclk270b,       -- 1-bit clock input 
                CE => vcc,            -- 1-bit clock enable input 
                D  => ddr_dqin(i),    -- 1-bit DDR data input 
                R  => gnd,            -- 1-bit reset 
                S  => gnd);           -- 1-bit set 

    dinq0 : FD
      port map ( Q => dqin(i+dbits), C => rclk180b, D => dqinl(i));
    dinq1 : FD
      port map ( Q => dqin(i), C => rclk180b, D => dqinl(i+dbits));

    dq_delay : FD
      port map ( Q => dqout_delay(i), C => clk0r, D => dqout(i));
    
    dout : ODDR2
      generic map (DDR_ALIGNMENT => "NONE")
      port map (Q => ddr_dqout(i), C0 => clk0r, C1 => clk180r, CE => vcc,
                D0 => dqout(i+dbits), D1 => dqout_delay(i), R => gnd, S => gnd);
    doen : FD
      port map (Q => ddr_dqoen(i), C => clk0r, D => oen);

    dq_pad : iopad
      generic map (tech => virtex4, level => sstl18_ii)
      port map (pad => ddr_dq(i), i => ddr_dqout(i), en => ddr_dqoen(i), o => ddr_dqin(i));
  end generate;
end;
