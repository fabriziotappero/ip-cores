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
-- Entity:      libddr
-- File:        libddr.vhd
-- Author:      David Lindh, Jiri Gaisler - Gaisler Research
-- Description: DDR input/output registers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

package allddr is

component unisim_iddr_reg is
  generic ( tech : integer := virtex4);
  port(
         Q1 : out std_ulogic;
         Q2 : out std_ulogic;
         C1 : in std_ulogic;
         C2 : in std_ulogic;
         CE : in std_ulogic;
         D : in std_ulogic;
         R : in std_ulogic;
         S : in std_ulogic
      );
end component;

component gen_iddr_reg
  port (
    Q1 : out std_ulogic;
    Q2 : out std_ulogic;
    C1 : in std_ulogic;
    C2 : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic);
end component;

component ec_oddr_reg
  port (
      Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end component;

component unisim_oddr_reg
  generic ( tech : integer := virtex4);
  port (
      Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end component;

component gen_oddr_reg
  port (
      Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end component;

component spartan3e_ddr_phy
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

end component;

component virtex4_ddr_phy
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

end component;

component virtex2_ddr_phy
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

end component;

component stratixii_ddr_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ;
	clk_div : integer := 2);

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

end component;

component cycloneiii_ddr_phy
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

end component;

component generic_ddr_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
           dbits : integer := 16; clk_mul : integer := 2 ;
           clk_div : integer := 2; rskew : integer := 0; mobile : integer := 0);

  port (
    rst         : in  std_ulogic;
    clk         : in  std_logic;    -- input clock
    clkout      : out std_ulogic;   -- system clock
    lock        : out std_ulogic;   -- DCM locked

    ddr_clk     : out std_logic_vector(2 downto 0);
    ddr_clkb    : out std_logic_vector(2 downto 0);
    ddr_clk_fb_out : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke     : out std_logic_vector(1 downto 0);
    ddr_csb     : out std_logic_vector(1 downto 0);
    ddr_web     : out std_ulogic;                             -- ddr write enable
    ddr_rasb    : out std_ulogic;                             -- ddr ras
    ddr_casb    : out std_ulogic;                             -- ddr cas
    ddr_dm      : out std_logic_vector (dbits/8-1 downto 0);  -- ddr dm
    ddr_dqs     : inout std_logic_vector (dbits/8-1 downto 0);-- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);         -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);          -- ddr bank address
    ddr_dq      : inout  std_logic_vector (dbits-1 downto 0); -- ddr data

    addr        : in  std_logic_vector (13 downto 0);         -- data mask
    ba          : in  std_logic_vector ( 1 downto 0);         -- data mask
    dqin        : out std_logic_vector (dbits*2-1 downto 0);  -- ddr input data
    dqout       : in  std_logic_vector (dbits*2-1 downto 0);  -- ddr input data
    dm          : in  std_logic_vector (dbits/4-1 downto 0);  -- data mask
    oen         : in  std_ulogic;
    dqs         : in  std_ulogic;
    dqsoen      : in  std_ulogic;
    rasn        : in  std_ulogic;
    casn        : in  std_ulogic;
    wen         : in  std_ulogic;
    csn         : in  std_logic_vector(1 downto 0);
    cke         : in  std_logic_vector(1 downto 0);
    ck          : in  std_logic_vector(2 downto 0);
    moben       : in  std_logic
  );

end component;

component tsmc90_tci_ddr_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
           dbits : integer := 16);

  port (
    rst           : in  std_ulogic;
    clk           : in  std_logic;    -- input clock
    clk90_sigi_0  : in  std_logic;
    rclk_sigi_1   : in  std_logic;
    clkout        : out std_ulogic;   -- system clock
    lock          : out std_ulogic;   -- DCM locked

    ddr_clk     : out std_logic_vector(2 downto 0);
    ddr_clkb    : out std_logic_vector(2 downto 0);
    --ddr_clk_fb_out : out std_logic;
    --ddr_clk_fb  : in std_logic;
    ddr_cke     : out std_logic_vector(1 downto 0);
    ddr_csb     : out std_logic_vector(1 downto 0);
    ddr_web     : out std_ulogic;                             -- ddr write enable
    ddr_rasb    : out std_ulogic;                             -- ddr ras
    ddr_casb    : out std_ulogic;                             -- ddr cas
    ddr_dm      : out std_logic_vector (dbits/8-1 downto 0);  -- ddr dm
    ddr_dqsin   : in std_logic_vector (dbits/8-1 downto 0);-- ddr dqs
    ddr_dqsout  : out std_logic_vector (dbits/8-1 downto 0);-- ddr dqs
    ddr_dqsoen  : out std_logic_vector (dbits/8-1 downto 0);-- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);         -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);          -- ddr bank address
    ddr_dqin    : in  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_dqout   : out  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_dqoen   : out  std_logic_vector (dbits-1 downto 0); -- ddr data

    addr        : in  std_logic_vector (13 downto 0);         -- data mask
    ba          : in  std_logic_vector ( 1 downto 0);         -- data mask
    dqin        : out std_logic_vector (dbits*2-1 downto 0);  -- ddr input data
    dqout       : in  std_logic_vector (dbits*2-1 downto 0);  -- ddr input data
    dm          : in  std_logic_vector (dbits/4-1 downto 0);  -- data mask
    oen         : in  std_ulogic;
    dqs         : in  std_ulogic;
    dqsoen      : in  std_ulogic;
    rasn        : in  std_ulogic;
    casn        : in  std_ulogic;
    wen         : in  std_ulogic;
    csn         : in  std_logic_vector(1 downto 0);
    cke         : in  std_logic_vector(1 downto 0);
    ck          : in  std_logic_vector(2 downto 0);
    moben       : in  std_logic;
    conf        : in  std_logic_vector(63 downto 0);
    tstclkout   : out std_logic_vector(3 downto 0)
  );

end component;

component virtex5_ddr2_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ; clk_div : integer := 2; 
	ddelayb0 : integer := 0; ddelayb1 : integer := 0; ddelayb2 : integer := 0;
	ddelayb3 : integer := 0; ddelayb4 : integer := 0; ddelayb5 : integer := 0;
	ddelayb6 : integer := 0; ddelayb7 : integer := 0;
   numidelctrl : integer := 4; norefclk : integer := 0; 
   tech : integer := virtex5);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkref200 : in  std_logic;			-- input 200MHz clock
    clkout    : out std_ulogic;			-- system clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqsn  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqsn
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_odt	: out std_logic_vector(1 downto 0);

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
    cal_en	: in  std_logic_vector(dbits/8-1 downto 0);
    cal_inc	: in  std_logic_vector(dbits/8-1 downto 0);
    cal_rst	: in  std_logic;
    odt     : in  std_logic_vector(1 downto 0)
 );
end component;

component stratixiii_ddr2_phy
  generic (MHz : integer := 100; rstdelay : integer := 200;
	dbits : integer := 16; clk_mul : integer := 2 ; clk_div : integer := 2; 
	ddelayb0 : integer := 0; ddelayb1 : integer := 0; ddelayb2 : integer := 0;
	ddelayb3 : integer := 0; ddelayb4 : integer := 0; ddelayb5 : integer := 0;
	ddelayb6 : integer := 0; ddelayb7 : integer := 0;
   numidelctrl : integer := 4; norefclk : integer := 0; 
   tech : integer := stratix3; rskew : integer := 0);

  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkref200 : in  std_logic;			-- input 200MHz clock
    clkout    : out std_ulogic;			-- system clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqsn  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqsn
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
    ddr_odt	: out std_logic_vector(1 downto 0);

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
    cal_en	: in  std_logic_vector(dbits/8-1 downto 0);
    cal_inc	: in  std_logic_vector(dbits/8-1 downto 0);
    cal_pll	: in  std_logic_vector(1 downto 0);
    cal_rst	: in  std_logic;
    odt     : in  std_logic_vector(1 downto 0)
 );
end component;


component spartan3a_ddr2_phy
  generic (MHz         : integer := 125; rstdelay : integer := 200;
           dbits       : integer := 16;  clk_mul  : integer := 2;
           clk_div     : integer := 2;   tech     : integer := spartan3;
           rskew       : integer := 0);
  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkout         : out   std_ulogic;  -- system clock
    lock           : out   std_ulogic;  -- DCM locked

    ddr_clk        : out   std_logic_vector(2 downto 0);
    ddr_clkb       : out   std_logic_vector(2 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(1 downto 0);
    ddr_csb        : out   std_logic_vector(1 downto 0);
    ddr_web        : out   std_ulogic;  -- ddr write enable
    ddr_rasb       : out   std_ulogic;  -- ddr ras
    ddr_casb       : out   std_ulogic;  -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);  -- ddr dm
    ddr_dqs        : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqs
    ddr_dqsn       : inout std_logic_vector (dbits/8-1 downto 0);  -- ddr dqsn
    ddr_ad         : out   std_logic_vector (13 downto 0);         -- ddr address
    ddr_ba         : out   std_logic_vector (1 downto 0);          -- ddr bank address
    ddr_dq         : inout std_logic_vector (dbits-1 downto 0);    -- ddr data
    ddr_odt        : out   std_logic_vector(1 downto 0);

    addr           : in    std_logic_vector (13 downto 0);
    ba             : in    std_logic_vector ( 1 downto 0);
    dqin           : out   std_logic_vector (dbits*2-1 downto 0);  -- ddr data
    dqout          : in    std_logic_vector (dbits*2-1 downto 0);  -- ddr data
    dm             : in    std_logic_vector (dbits/4-1 downto 0);  -- data mask
    oen            : in    std_ulogic;
    dqs            : in    std_ulogic;
    dqsoen         : in    std_ulogic;
    rasn           : in    std_ulogic;
    casn           : in    std_ulogic;
    wen            : in    std_ulogic;
    csn            : in    std_logic_vector(1 downto 0);
    cke            : in    std_logic_vector(1 downto 0);
    cal_pll        : in    std_logic_vector(1 downto 0);
    odt            : in    std_logic_vector(1 downto 0)
    );
end component;
end;
