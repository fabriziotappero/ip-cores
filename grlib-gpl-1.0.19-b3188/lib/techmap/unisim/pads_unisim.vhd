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
-- Package: 	pad_xilinx_gen
-- File:	pad_xilinx_gen.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Xilinx pads wrappers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.IBUF;
-- pragma translate_on

entity virtex_inpad is
  generic (level : integer := 0; voltage : integer := x33v);
  port (pad : in std_ulogic; o : out std_ulogic);
end; 
architecture rtl of virtex_inpad is
  component IBUF generic(
      CAPACITANCE : string := "DONT_CARE"; IOSTANDARD : string := "LVCMOS25");
    port (O : out std_ulogic; I : in std_ulogic); end component;
begin
  pci0 : if level = pci33 generate
    pci_5 : if voltage = x50v generate
      ip : IBUF generic map (IOSTANDARD => "PCI33_5") port map (O => o, I => pad);
    end generate;
    pci_3 : if voltage /= x50v generate
      ip : IBUF generic map (IOSTANDARD => "PCI33_3") port map (O => o, I => pad);
    end generate;
  end generate;
  ttl0 : if level = ttl generate
    ip : IBUF generic map (IOSTANDARD => "LVTTL") port map (O => o, I => pad);
  end generate;
  cmos0 : if level = cmos generate
    cmos_33 : if voltage = x33v generate
      ip : IBUF generic map (IOSTANDARD => "LVCMOS33") port map (O => o, I => pad);
    end generate;
    cmos_25 : if voltage /= x33v generate
      ip : IBUF generic map (IOSTANDARD => "LVCMOS25") port map (O => o, I => pad);
    end generate;
  end generate;
  sstl2x : if level = sstl2_i generate
    ip : IBUF generic map (IOSTANDARD => "SSTL2_I") port map (O => o, I => pad);
  end generate;
  sstl2y : if level = sstl2_ii generate
    ip : IBUF generic map (IOSTANDARD => "SSTL2_II") port map (O => o, I => pad);
  end generate;
  gen0 : if (level /= pci33) and (level /= ttl) and (level /= cmos) 
	and (level /= sstl2_i)and (level /= sstl2_ii) generate
    ip : IBUF port map (O => o, I => pad);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.IOBUF;
-- pragma translate_on

entity virtex_iopad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12);
  port (pad : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end ;
architecture rtl of virtex_iopad is
  component IOBUF generic (
      CAPACITANCE : string := "DONT_CARE"; DRIVE : integer := 12;
      IOSTANDARD  : string := "LVCMOS25"; SLEW : string := "SLOW");
    port (O : out std_ulogic; IO : inout std_logic; I, T : in std_ulogic); end component;
begin
  pci0 : if level = pci33 generate
    pci_5 : if voltage = x50v generate
      op : IOBUF generic map (IOSTANDARD => "PCI33_5")
                 port map (O => o, IO => pad, I => i, T => en);
    end generate;
    pci_3 : if voltage /= x50v generate
      op : IOBUF generic map (IOSTANDARD => "PCI33_3")
                 port map (O => o, IO => pad, I => i, T => en);
    end generate;
  end generate;
  ttl0 : if level = ttl generate
    slow0 : if slew = 0 generate
      op : IOBUF generic map (drive => strength, IOSTANDARD => "LVTTL")
                 port map (O => o, IO => pad, I => i, T => en);
    end generate;
    fast0 : if slew /= 0 generate
      op : IOBUF generic map (drive => strength, IOSTANDARD => "LVTTL", SLEW => "FAST")
                 port map (O => o, IO => pad, I => i, T => en);
    end generate;
  end generate;
  cmos0 : if level = cmos generate
    slow0 : if slew = 0 generate
      op : IOBUF generic map (drive => strength, IOSTANDARD => "LVCMOS33")
                 port map (O => o, IO => pad, I => i, T => en);
    end generate;
    fast0 : if slew /= 0 generate
      op : IOBUF generic map (drive => strength, IOSTANDARD => "LVCMOS33", SLEW => "FAST")
                 port map (O => o, IO => pad, I => i, T => en);
    end generate;
  end generate;
  sstl2x : if level = sstl2_i generate
    op : IOBUF generic map (drive => strength, IOSTANDARD => "SSTL2_I")
                 port map (O => o, IO => pad, I => i, T => en);
  end generate;
  sstl2y : if level = sstl2_ii generate
    op : IOBUF generic map (drive => strength, IOSTANDARD => "SSTL2_II")
                 port map (O => o, IO => pad, I => i, T => en);
  end generate;
  sstl18i : if level = sstl18_i generate
    op : IOBUF generic map (drive => strength, IOSTANDARD => "SSTL18_I")
                 port map (O => o, IO => pad, I => i, T => en);
  end generate;
  sstl18ii : if level = sstl18_ii generate
    op : IOBUF generic map (drive => strength, IOSTANDARD => "SSTL18_II")
                 port map (O => o, IO => pad, I => i, T => en);
  end generate;
  gen0 : if (level /= pci33) and (level /= ttl) and (level /= cmos) and 
	(level /= sstl2_i) and (level /= sstl2_ii) and (level /= sstl18_i) and (level /= sstl18_ii) generate
    op : IOBUF port map (O => o, IO => pad, I => i, T => en);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.OBUF;
-- pragma translate_on

entity virtex_outpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 12);
  port (pad : out std_ulogic; i : in std_ulogic);
end ;
architecture rtl of virtex_outpad is
  component OBUF generic (
      CAPACITANCE : string := "DONT_CARE"; DRIVE : integer := 12;
      IOSTANDARD  : string := "LVCMOS25"; SLEW : string := "SLOW");
    port (O : out std_ulogic; I : in std_ulogic); end component;
begin
  pci0 : if level = pci33 generate
    pci_5 : if voltage = x50v generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "PCI33_5")
                port map (O => pad, I => i);
    end generate;
    pci_3 : if voltage /= x50v generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "PCI33_3")
                port map (O => pad, I => i);
    end generate;
  end generate;
  ttl0 : if level = ttl generate
    slow0 : if slew = 0 generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "LVTTL")
                port map (O => pad, I => i);
    end generate;
    fast0 : if slew /= 0 generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "LVTTL", SLEW => "FAST")
                port map (O => pad, I => i);
    end generate;
  end generate;
  cmos0 : if level = cmos generate
    slow0 : if slew = 0 generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "LVCMOS33")
                port map (O => pad, I => i);
    end generate;
    fast0 : if slew /= 0 generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "LVCMOS33", SLEW => "FAST")
                port map (O => pad, I => i);
    end generate;
  end generate;
  sstl2x : if level = sstl2_i generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "SSTL2_I")
                port map (O => pad, I => i);
  end generate;
  sstl2y : if level = sstl2_ii generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "SSTL2_II")
                port map (O => pad, I => i);
  end generate;
  sstl18i : if level = sstl18_i generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "SSTL18_I")
                port map (O => pad, I => i);
  end generate;
  sstl18ii : if level = sstl18_ii generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "SSTL18_II")
                port map (O => pad, I => i);
  end generate;
  gen0 : if (level /= pci33) and (level /= ttl) and (level /= cmos) and 
	(level /= sstl2_i) and (level /= sstl2_ii) and 
   (level /= sstl18_i) and (level /= sstl18_ii) generate
      op : OBUF port map (O => pad, I => i);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.OBUFT;
-- pragma translate_on

entity virtex_toutpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 12);
  port (pad : out std_ulogic; i, en : in std_ulogic);
end ;
architecture rtl of virtex_toutpad is
  component OBUFT generic (
      CAPACITANCE : string := "DONT_CARE"; DRIVE : integer := 12;
      IOSTANDARD  : string := "LVCMOS25"; SLEW : string := "SLOW");
    port (O : out std_ulogic; I, T : in std_ulogic); end component;
begin
  pci0 : if level = pci33 generate
    pci_5 : if voltage = x50v generate
      op : OBUFT generic map (drive => strength, IOSTANDARD => "PCI33_5")
                 port map (O => pad, I => i, T => en);
    end generate;
    pci_3 : if voltage /= x50v generate
      op : OBUFT generic map (drive => strength, IOSTANDARD => "PCI33_3")
                 port map (O => pad, I => i, T => en);
    end generate;
  end generate;
  ttl0 : if level = ttl generate
    slow0 : if slew = 0 generate
      op : OBUFT generic map (drive => strength, IOSTANDARD => "LVTTL")
                 port map (O => pad, I => i, T => en);
    end generate;
    fast0 : if slew /= 0 generate
      op : OBUFT generic map (drive => strength, IOSTANDARD => "LVTTL", SLEW => "FAST")
                 port map (O => pad, I => i, T => en);
    end generate;
  end generate;
  cmos0 : if level = cmos generate
    slow0 : if slew = 0 generate
      op : OBUFT generic map (drive => strength, IOSTANDARD => "LVCMOS33")
                 port map (O => pad, I => i, T => en);
    end generate;
    fast0 : if slew /= 0 generate
      op : OBUFT generic map (drive => strength, IOSTANDARD => "LVCMOS33", SLEW => "FAST")
                 port map (O => pad, I => i, T => en);
    end generate;
  end generate;
  gen0 : if (level /= pci33) and (level /= ttl) and (level /= cmos) generate
    op : OBUFT port map (O => pad, I => i, T => en);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.OBUF;
use unisim.BUFG;
use unisim.DCM;
-- pragma translate_on

entity virtex_skew_outpad  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := 0; strength : integer := 12; skew : integer := 0);
  port (pad : out std_ulogic; i : in std_ulogic; rst : in std_ulogic;
        o : out std_ulogic);
end ;
architecture rtl of virtex_skew_outpad is
  component OBUF generic (
      CAPACITANCE : string := "DONT_CARE"; DRIVE : integer := 12;
      IOSTANDARD  : string := "LVCMOS25"; SLEW : string := "SLOW");
    port (O : out std_ulogic; I : in std_ulogic); end component;
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
signal reset, clk0, clk0b, gnd, vcc : std_ulogic;
begin
  gnd <= '0'; vcc <= '1';
  reset <= not rst;
  dll0 : DCM
    generic map (clkin_period => 10.0, DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", 
                 CLKOUT_PHASE_SHIFT => "FIXED", PHASE_SHIFT => skew)
    port map ( CLKIN => i, CLKFB => clk0b, DSSEN => gnd, PSCLK => gnd,
    PSEN => gnd, PSINCDEC => gnd, RST => reset, CLK0 => clk0);
  bufg0 : BUFG port map (I => clk0, O => clk0b);

  o <= clk0b; -- output before pad
  
  --x0 : virtex_outpad generic map (level, slew, voltage, strength) port map (pad, clk0b);
  pci0 : if level = pci33 generate
    pci_5 : if voltage = x50v generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "PCI33_5")
                port map (O => pad, I => clk0b);
    end generate;
    pci_3 : if voltage /= x50v generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "PCI33_3")
                port map (O => pad, I => clk0b);
    end generate;
  end generate;
  ttl0 : if level = ttl generate
    slow0 : if slew = 0 generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "LVTTL")
                port map (O => pad, I => clk0b);
    end generate;
    fast0 : if slew /= 0 generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "LVTTL", SLEW => "FAST")
                port map (O => pad, I => clk0b);
    end generate;
  end generate;
  cmos0 : if level = cmos generate
    slow0 : if slew = 0 generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "LVCMOS33")
                port map (O => pad, I => clk0b);
    end generate;
    fast0 : if slew /= 0 generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "LVCMOS33", SLEW => "FAST")
                port map (O => pad, I => clk0b);
    end generate;
  end generate;
  sstl2x : if level = sstl2_i generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "SSTL2_I")
                port map (O => pad, I => clk0b);
  end generate;
  sstl2y : if level = sstl2_ii generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "SSTL2_II")
                port map (O => pad, I => clk0b);
  end generate;
  sstl18i : if level = sstl18_i generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "SSTL18_I")
                port map (O => pad, I => clk0b);
  end generate;
  sstl18ii : if level = sstl18_ii generate
      op : OBUF generic map (drive => strength, IOSTANDARD => "SSTL18_II")
                port map (O => pad, I => clk0b);
  end generate;
  gen0 : if (level /= pci33) and (level /= ttl) and (level /= cmos) and 
	(level /= sstl2_i) and (level /= sstl2_ii) and 
   (level /= sstl18_i) and (level /= sstl18_ii) generate
      op : OBUF port map (O => pad, I => clk0b);
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.IBUFG;
use unisim.IBUF;
use unisim.BUFGMUX;
use unisim.BUFG;
-- pragma translate_on

entity virtex_clkpad is
  generic (level : integer := 0; voltage : integer := x33v; arch : integer := 0; hf : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic; rstn : in std_ulogic := '1'; lock : out std_ulogic);
end; 
architecture rtl of virtex_clkpad is
  component IBUFG  generic(
      CAPACITANCE : string := "DONT_CARE"; IOSTANDARD : string := "LVCMOS25");
    port (O : out std_logic; I : in std_logic); end component;
  component IBUF generic(
      CAPACITANCE : string := "DONT_CARE"; IOSTANDARD : string := "LVCMOS25");
    port (O : out std_ulogic; I : in std_ulogic); end component;
  component BUFGMUX port (O : out std_logic; I0, I1, S : in std_logic); end component;
  component BUFG port (O : out std_logic; I : in std_logic); end component;
  component CLKDLL port ( CLK0    : out std_ulogic; CLK180  : out std_ulogic; CLK270  : out std_ulogic;
      CLK2X   : out std_ulogic; CLK90   : out std_ulogic;  CLKDV   : out std_ulogic;
      LOCKED  : out std_ulogic; CLKFB   : in  std_ulogic;   CLKIN   : in  std_ulogic;
      RST     : in  std_ulogic);
  end component;
  component CLKDLLHF port ( CLK0   : out std_ulogic; CLK180 : out std_ulogic; CLKDV  : out std_ulogic;
      LOCKED : out std_ulogic; CLKFB  : in std_ulogic; CLKIN  : in std_ulogic; RST   : in std_ulogic);
  end component;
  signal gnd, ol, ol2, ol3 : std_ulogic;
  signal rst : std_ulogic;  
begin
  gnd <= '0'; rst <= not rstn;
  g0 : if arch = 0 generate
    pci0 : if level = pci33 generate
      pci_5 : if voltage = x50v generate
        ip : IBUFG generic map (IOSTANDARD => "PCI33_5") port map (O => o, I => pad);
      end generate;
      pci_3 : if voltage /= x50v generate
        ip : IBUFG generic map (IOSTANDARD => "PCI33_3") port map (O => o, I => pad);
      end generate;
    end generate;
    ttl0 : if level = ttl generate
      ip : IBUFG generic map (IOSTANDARD => "LVTTL") port map (O => o, I => pad);
    end generate;
    cmos0 : if level = cmos generate
	  cmos_33 : if voltage = x33v generate
        ip : IBUFG generic map (IOSTANDARD => "LVCMOS33") port map (O => o, I => pad);
      end generate;
      cmos_25 : if voltage /= x33v generate
        ip : IBUFG generic map (IOSTANDARD => "LVCMOS25") port map (O => o, I => pad);
      end generate;
    end generate;
    sstl2 : if level = sstl2_ii generate
      ip : IBUFG generic map (IOSTANDARD => "SSTL2_II") port map (O => o, I => pad);
    end generate;
    gen0 : if (level /= pci33) and (level /= ttl) and (level /= cmos) and (level /= sstl2_ii) generate
      ip : IBUFG port map (O => o, I => pad);
    end generate;
    lock <= '1';
  end generate;
  g1 : if arch = 1 generate
    pci0 : if level = pci33 generate
      pci_5 : if voltage = x50v generate
        ip : IBUF generic map (IOSTANDARD => "PCI33_5") port map (O => ol, I => pad);
        bf : BUFGMUX port map (O => o, I0 => ol, I1 => gnd, S => gnd);
      end generate;
      pci_3 : if voltage /= x50v generate
        ip : IBUF generic map (IOSTANDARD => "PCI33_3") port map (O => ol, I => pad);
        bf : BUFGMUX port map (O => o, I0 => ol, I1 => gnd, S => gnd);
      end generate;
    end generate;
    ttl0 : if level = ttl generate
      ip : IBUF generic map (IOSTANDARD => "LVTTL") port map (O => ol, I => pad);
      bf : BUFGMUX port map (O => o, I0 => ol, I1 => gnd, S => gnd);
    end generate;
    cmos0 : if level = cmos generate
      ip : IBUF generic map (IOSTANDARD => "LVCMOS33") port map (O => ol, I => pad);
      bf : BUFGMUX port map (O => o, I0 => ol, I1 => gnd, S => gnd);
    end generate;
    gen0 : if (level /= pci33) and (level /= ttl) and (level /= cmos) generate
      ip : IBUF port map (O => ol, I => pad);
      bf : BUFGMUX port map (O => o, I0 => ol, I1 => gnd, S => gnd);
    end generate;
    lock <= '1';
  end generate;
  g2 : if arch = 2 generate
    pci0 : if level = pci33 generate
      pci_5 : if voltage = x50v generate
        ip : IBUFG generic map (IOSTANDARD => "PCI33_5") port map (O => ol, I => pad);
        bf : BUFG port map (O => o, I => ol);
      end generate;
      pci_3 : if voltage /= x50v generate
        ip : IBUFG generic map (IOSTANDARD => "PCI33_3") port map (O => ol, I => pad);
        bf : BUFG port map (O => o, I => ol);
      end generate;
    end generate;
    ttl0 : if level = ttl generate
      ip : IBUFG generic map (IOSTANDARD => "LVTTL") port map (O => ol, I => pad);
      bf : BUFG port map (O => o, I => ol);
    end generate;
    cmos0 : if level = cmos generate
      ip : IBUFG generic map (IOSTANDARD => "LVCMOS33") port map (O => ol, I => pad);
      bf : BUFG port map (O => o, I => ol);
    end generate;
    gen0 : if (level /= pci33) and (level /= ttl) and (level /= cmos) generate
      ip : IBUFG port map (O => ol, I => pad);
      bf : BUFG port map (O => o, I => ol);
    end generate;
    lock <= '1';
  end generate;
  g3 : if arch = 3 generate
    ip : IBUFG port map (O => ol, I => pad);
    hf0 : if hf = 0 generate
      dll: CLKDLL port map(
        CLK0 => ol2,
        CLK180 => open,
        CLK270 => open,
        CLK2X  => open,
        CLK90  => open,
        CLKDV  => open,
        LOCKED => lock,
        CLKFB  => ol3,
        CLKIN  => ol,
        RST    => rst);
    end generate;
    hf1 : if hf = 1 generate
      dll : CLKDLLHF
        port map(
          CLK0 => ol2,   
          CLK180 => open,
          CLKDV => open,
          LOCKED => lock,
          CLKFB  => ol3,
          CLKIN  => ol,
          RST    => rst);
    end generate;
    bf : BUFG port map (O => ol3, I => ol2);
    o <= ol3;    
  end generate g3;
end; 

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.OBUFDS_LVDS_25;
use unisim.OBUFDS_LVDS_33;
-- pragma translate_on

entity virtex_outpad_ds  is
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : out std_ulogic; i : in std_ulogic);
end ;
architecture rtl of virtex_outpad_ds is
  component OBUFDS_LVDS_25
     port ( O : out std_ulogic; OB : out std_ulogic; I : in std_ulogic);
  end component;
  component OBUFDS_LVDS_33
     port ( O : out std_ulogic; OB : out std_ulogic; I : in std_ulogic);
  end component;
begin
  xlvds : if level = lvds generate
    lvds_33 : if voltage = x33v generate
      op : OBUFDS_LVDS_33 port map (O => padp, OB => padn, I => i);
    end generate;
    lvds_25 : if voltage /= x33v generate
      op : OBUFDS_LVDS_25 port map (O => padp, OB => padn, I => i);
    end generate;
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.IBUFDS_LVDS_25;
use unisim.IBUFDS_LVDS_33;
-- pragma translate_on

entity virtex_inpad_ds is
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end; 

architecture rtl of virtex_inpad_ds is
  component IBUFDS_LVDS_25
     port ( O : out std_ulogic; I : in std_ulogic; IB : in std_ulogic);
  end component;
  component IBUFDS_LVDS_33
     port ( O : out std_ulogic; I : in std_ulogic; IB : in std_ulogic);
  end component;
begin
  xlvds : if level = lvds generate
    lvds_33 : if voltage = x33v generate
      ip : IBUFDS_LVDS_33 port map (O => o, I => padp, IB => padn);
    end generate;
    lvds_25 : if voltage /= x33v generate
      ip : IBUFDS_LVDS_25 port map (O => o, I => padp, IB => padn);
    end generate;
  end generate;
  beh : if level /= lvds generate
    o <= padp after 1 ns;
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.IBUFGDS_LVDS_25;
use unisim.IBUFGDS_LVDS_33;
-- pragma translate_on

entity virtex_clkpad_ds is
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end; 

architecture rtl of virtex_clkpad_ds is
  component IBUFGDS_LVDS_25
     port ( O : out std_ulogic; I : in std_ulogic; IB : in std_ulogic);
  end component;
  component IBUFGDS_LVDS_33
     port ( O : out std_ulogic; I : in std_ulogic; IB : in std_ulogic);
  end component;
begin
  xlvds : if level = lvds generate
    lvds_33 : if voltage = x33v generate
      ip : IBUFGDS_LVDS_33 port map (O => o, I => padp, IB => padn);
    end generate;
    lvds_25 : if voltage /= x33v generate
      ip : IBUFGDS_LVDS_25 port map (O => o, I => padp, IB => padn);
    end generate;
  end generate;
  beh : if level /= lvds generate
    o <= padp after 1 ns;
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.IBUFDS;
-- pragma translate_on

entity virtex4_inpad_ds is
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end; 

architecture rtl of virtex4_inpad_ds is
  component IBUFDS
  generic ( CAPACITANCE : string := "DONT_CARE";
	DIFF_TERM : boolean := FALSE; IBUF_DELAY_VALUE : string := "0";
	IFD_DELAY_VALUE : string := "AUTO"; IOSTANDARD : string := "DEFAULT");
     port ( O : out std_ulogic; I : in std_ulogic; IB : in std_ulogic);
  end component;
begin
  xlvds : if level = lvds generate
    lvds_33 : if voltage = x33v generate
      ip : IBUFDS generic map (DIFF_TERM => true, IOSTANDARD =>"LVDS_33")
	   port map (O => o, I => padp, IB => padn);
    end generate;
    lvds_25 : if voltage /= x33v generate
      ip : IBUFDS generic map (DIFF_TERM => true, IOSTANDARD =>"LVDS_25")
	   port map (O => o, I => padp, IB => padn);
    end generate;
  end generate;
  beh : if level /= lvds generate
    o <= padp after 1 ns;
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.IBUFGDS;
-- pragma translate_on

entity virtex4_clkpad_ds is
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : in std_ulogic; o : out std_ulogic);
end; 

architecture rtl of virtex4_clkpad_ds is
  component IBUFGDS
  generic ( CAPACITANCE : string := "DONT_CARE";
	DIFF_TERM : boolean := FALSE; IBUF_DELAY_VALUE : string := "0";
	IOSTANDARD : string := "DEFAULT");
     port ( O : out std_ulogic; I : in std_ulogic; IB : in std_ulogic);
  end component;
begin
  xlvds : if level = lvds generate
    lvds_33 : if voltage = x33v generate
      ip : IBUFGDS generic map (DIFF_TERM => true, IOSTANDARD =>"LVDS_33")
	   port map (O => o, I => padp, IB => padn);
    end generate;
    lvds_25 : if voltage /= x33v generate
      ip : IBUFGDS generic map (DIFF_TERM => true, IOSTANDARD =>"LVDS_25")
	   port map (O => o, I => padp, IB => padn);
    end generate;
  end generate;
  beh : if level /= lvds generate
    o <= padp after 1 ns;
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.IOBUFDS;
-- pragma translate_on

entity virtex5_iopad_ds  is
  generic (level : integer := 0; slew : integer := 0;
	   voltage : integer := x33v; strength : integer := 12);
  port (padp, padn : inout std_ulogic; i, en : in std_ulogic; o : out std_ulogic);
end ;
architecture rtl of virtex5_iopad_ds is
  component IOBUFDS generic (
      CAPACITANCE : string := "DONT_CARE"; IBUF_DELAY_VALUE : string := "0";
      IOSTANDARD  : string := "DEFAULT"; IFD_DELAY_VALUE : string := "AUTO");
    port (O : out std_ulogic; IO, IOB : inout std_logic; I, T : in std_ulogic); end component;
begin
      iop : IOBUFDS generic map (IOSTANDARD => "DEFAULT")
                 port map (O => o, IO => padp, IOB => padn, I => i, T => en);
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.OBUFDS;
-- pragma translate_on

entity virtex5_outpad_ds  is
  generic (level : integer := lvds; voltage : integer := x33v);
  port (padp, padn : out std_ulogic; i : in std_ulogic);
end ;
architecture rtl of virtex5_outpad_ds is
  component OBUFDS generic( IOSTANDARD  : string := "DEFAULT");
     port ( O : out std_ulogic; OB : out std_ulogic; I : in std_ulogic);
  end component;
begin
  xlvds : if level = lvds generate
    lvds_33 : if voltage = x33v generate
      op : OBUFDS generic map(IOSTANDARD  => "LVDS_33")
         port map (O => padp, OB => padn, I => i);
    end generate;
    lvds_25 : if voltage /= x33v generate
      op : OBUFDS generic map(IOSTANDARD  => "LVDS_25")
         port map (O => padp, OB => padn, I => i);
    end generate;
  end generate;
  xsstl18_i : if level = sstl18_i generate
      op : OBUFDS generic map(IOSTANDARD  => "SSTL18_I")
         port map (O => padp, OB => padn, I => i);
  end generate;
  xsstl18_ii : if level = sstl18_ii generate
      op : OBUFDS generic map(IOSTANDARD  => "SSTL18_II")
         port map (O => padp, OB => padn, I => i);
  end generate;
end;
