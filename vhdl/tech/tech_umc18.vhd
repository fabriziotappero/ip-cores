



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	tech_umc18
-- File:	tech_umc18.vhd
-- Author:	Raijmond Keulen, Irotech
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Contains UMC umc18 specific pads and ram generators
------------------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;

package tech_umc18 is

-- sync ram generator

  component umc18_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector(abits -1 downto 0);
    clk      : in std_logic;
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable   : in std_logic;
    write    : in std_logic);
  end component;

-- regfile generator

  component umc18_regfile
  generic ( abits : integer := 8; dbits : integer := 32; words : integer := 128);
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    clkn     : in clk_type;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
  end component;

-- pads

  component umc18_inpad 
    port (pad : in std_logic; q : out std_logic);
  end component; 
  component umc18_smpad
    port (pad : in std_logic; q : out std_logic);
  end component;
  component umc18_outpad
    generic (drive : integer := 1);
    port (d : in  std_logic; pad : out  std_logic);
  end component; 
  component umc18_toutpadu
    generic (drive : integer := 1);
    port (d, en : in  std_logic; pad : out  std_logic);
  end component; 
  component umc18_iopad
    generic (drive : integer := 1);
    port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component umc18_iopadu 
    generic (drive : integer := 1);
    port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component umc18_iodpad 
    generic (drive : integer := 1);
    port ( d : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component umc18_odpad
    generic (drive : integer := 1);
    port ( d : in std_logic; pad : out std_logic);
  end component;
  component umc18_smiopad
    generic (drive : integer := 1);
    port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  
end;

------------------------------------------------------------------
-- behavioural pad models --------------------------------------------
------------------------------------------------------------------
-- Only needed for simulation, not synthesis.
-- pragma translate_off

-- input pad 1xDrive
library IEEE;
use IEEE.std_logic_1164.all;
entity C3I40 is port (PAD : in std_logic; DI : out std_logic); end; 
architecture rtl of C3I40 is begin DI <= to_x01(PAD) after 1 ns; end;

-- input schmitt pad 1xDrive
library IEEE;
use IEEE.std_logic_1164.all;
entity C3I42 is port (PAD : in std_logic; DI : out std_logic); end; 
architecture rtl of C3I42 is begin DI <= to_x01(PAD) after 1 ns; end;

-- output pad 2mA
library IEEE;
use IEEE.std_logic_1164.all;
entity C3O10 is port (DO : in  std_logic; PAD : out  std_logic); end; 
architecture rtl of C3O10 is begin PAD <= to_x01(DO) after 2 ns; end;

-- output pad 4mA
library IEEE;
use IEEE.std_logic_1164.all;
entity C3O20 is port (DO : in  std_logic; PAD : out  std_logic); end; 
architecture rtl of C3O20 is begin PAD <= to_x01(DO) after 2 ns; end;

-- output pad 8mA
library IEEE;
use IEEE.std_logic_1164.all;
entity C3O40 is port (DO : in  std_logic; PAD : out  std_logic); end; 
architecture rtl of C3O40 is begin PAD <= to_x01(DO) after 2 ns; end;

-- bidirectional pad pullup 2mA, used as tri-state output pad with pull-up *
library IEEE;
use IEEE.std_logic_1164.all;
entity C3B10U is
  port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
end; 
architecture rtl of C3B10U is
begin 
  PAD <= to_x01(DO) after 2 ns when EN = '1' else 'Z' after 2 ns;
  DI <= to_x01(PAD) after 2 ns;
end;

-- bidirectional pad pullup 4mA, used as tri-state output pad with pull-up *
library IEEE;
use IEEE.std_logic_1164.all;
entity C3B20U is
  port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
end; 
architecture rtl of C3B20U is
begin 
  PAD <= to_x01(DO) after 2 ns when EN = '1' else 'Z' after 2 ns;
  DI <= to_x01(PAD) after 2 ns;
end;

-- bidirectional pad pullup 8mA, used as tri-state output pad with pull-up *
library IEEE;
use IEEE.std_logic_1164.all;
entity C3B40U is
  port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
end; 
architecture rtl of C3B40U is
begin 
  PAD <= to_x01(DO) after 2 ns when EN = '1' else 'Z' after 2 ns;
  DI <= to_x01(PAD) after 2 ns;
end;

-- bidirectional pad 2mA *
library IEEE;
use IEEE.std_logic_1164.all;
entity C3B10 is
  port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
end; 
architecture rtl of C3B10 is
begin 
  PAD <= to_x01(DO) after 2 ns when EN = '1' else 'Z' after 2 ns;
  DI <= to_x01(PAD) after 2 ns;
end;

-- bidirectional pad 4mA *
library IEEE;
use IEEE.std_logic_1164.all;
entity C3B20 is
  port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
end; 
architecture rtl of C3B20 is
begin 
  PAD <= to_x01(DO) after 2 ns when EN = '1' else 'Z' after 2 ns;
  DI <= to_x01(PAD) after 2 ns;
end;

-- bidirectional pad 8mA *
library IEEE;
use IEEE.std_logic_1164.all;
entity C3B40 is
  port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
end; 
architecture rtl of C3B40 is
begin 
  PAD <= to_x01(DO) after 2 ns when EN = '1' else 'Z' after 2 ns;
  DI <= to_x01(PAD) after 2 ns;
end;

-- bidirectional pad 2mA with open drain
library IEEE;
use IEEE.std_logic_1164.all;
entity CD3B10T is
  port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
end; 
architecture rtl of CD3B10T is
begin 
  PAD <= '0' after 2 ns when (EN and not DO) = '1' else 'Z' after 2 ns;
  DI <= to_x01(PAD) after 2 ns;
end;

-- bidirectional pad 4mA with open drain
library IEEE;
use IEEE.std_logic_1164.all;
entity CD3B20T is
  port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
end; 
architecture rtl of CD3B20T is
begin 
  PAD <= '0' after 2 ns when (EN and not DO) = '1' else 'Z' after 2 ns;
  DI <= to_x01(PAD) after 2 ns;
end;

-- bidirectional pad 8mA with open drain
library IEEE;
use IEEE.std_logic_1164.all;
entity CD3B40T is
  port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
end; 
architecture rtl of CD3B40T is
begin 
  PAD <= '0' after 2 ns when (EN and not DO) = '1' else 'Z' after 2 ns;
  DI <= to_x01(PAD) after 2 ns;
end;

-- output pad 2mA with open drain
library IEEE;
use IEEE.std_logic_1164.all;
entity CD3O10T is
  port ( DO : in std_logic; PAD : out std_logic);
end; 
architecture rtl of CD3O10T is
begin 
  PAD <= '0' after 2 ns when DO = '0' else 'Z' after 2 ns;
end;

-- output pad 4mA with open drain
library IEEE;
use IEEE.std_logic_1164.all;
entity CD3O20T is
  port ( DO : in std_logic; PAD : out std_logic);
end; 
architecture rtl of CD3O20T is
begin 
  PAD <= '0' after 2 ns when DO = '0' else 'Z' after 2 ns;
end;

-- output pad 8mA with open drain
library IEEE;
use IEEE.std_logic_1164.all;
entity CD3O40T is
  port ( DO : in std_logic; PAD : out std_logic);
end; 
architecture rtl of CD3O40T is
begin 
  PAD <= '0' after 2 ns when DO = '0' else 'Z' after 2 ns;
end;

-- bidirectional pad 8mA schmitt trigger
library IEEE;
use IEEE.std_logic_1164.all;
entity C3B42 is
  port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
end; 
architecture rtl of C3B42 is
begin 
  PAD <= to_x01(DO) after 2 ns when EN = '1' else 'Z' after 2 ns;
  DI <= to_x01(PAD) after 2 ns;
end;

------------------------------------------------------------------
-- behavioural ram models ----------------------------------------
------------------------------------------------------------------
--  Address and control latched on rising clka, data latched on falling clkb. 

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity umc18_dpram_ss is
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    DI: in std_logic_vector (dbits -1 downto 0);
    RADR,WADR: in std_logic_vector (abits -1 downto 0);
    REN,WEN : in std_logic;
    RCK,WCK : in std_logic;
    DOUT: out std_logic_vector (dbits -1 downto 0)
  );
end;

architecture behav of umc18_dpram_ss is
  signal DI_l,DOUT_l : std_logic_vector (dbits -1 downto 0);
  signal RADR_l, WADR_l : std_logic_vector (abits -1 downto 0);
  signal REN_l, WEN_l : std_logic;
  type dregtype is array (0 to words - 1) 
       of std_logic_vector(dbits -1 downto 0);
  signal data : dregtype;
  attribute syn_ramstyle : string;
  attribute syn_ramstyle of data: signal is "block_ram";
begin

  writeport : process(WCK)
  begin
    if rising_edge(WCK) then
      DI_l <= DI;
      WEN_l <= WEN;
      WADR_l <= WADR;
    end if;
  end process;

  readport : process(RCK)
  begin
    if rising_edge(RCK) then
      REN_l <= REN;
      RADR_l <= RADR;
    end if;
  end process;
  
  ram : process(DI_l, WEN_l, WADR_l, REN_l, RADR_l, data)
  begin
    if WEN_l = '0' then
      if not ( is_x(WADR_l) or (conv_integer(unsigned(WADR_l)) >= words)) then
   	  data(conv_integer(unsigned(WADR_l))) <= DI_l; 
      end if;
    end if;
    if REN_l = '0' then
      if not (is_x(RADR_l) or (conv_integer(unsigned(RADR_l)) >= words)) then
        DOUT_l <= data(conv_integer(unsigned(RADR_l)));
      else
        DOUT_l <= (others => 'X');
      end if;
    else 
      DOUT_l <= (others => 'Z');
    end if;
  end process;

  DOUT <= DOUT_l;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity umc18_syncram_ss is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    ADR   : in std_logic_vector((abits -1) downto 0);
    DI    : in std_logic_vector((dbits -1) downto 0);
    DOUT    : out std_logic_vector((dbits -1) downto 0);
    CK    : in std_logic;
    WEN   : in std_logic;
    CEN   : in std_logic;
    OEN   : in std_logic
  ); 
end;     

architecture behavioral of umc18_syncram_ss is

  type mem is array(0 to (2**abits -1)) 
	of std_logic_vector((dbits -1) downto 0);
  signal memarr : mem;
  attribute syn_ramstyle : string;
  attribute syn_ramstyle of memarr: signal is "block_ram";
  signal ADR_l   : std_logic_vector((abits -1) downto 0);
  signal DI_l    : std_logic_vector((dbits -1) downto 0);
  signal WEN_l   : std_logic;
  signal CEN_l   : std_logic;
  signal DOUT_l    : std_logic_vector((dbits -1) downto 0);
begin

  input_latch : process(CK)
  begin
    if rising_edge(CK) then
      ADR_l <= ADR;
      DI_l  <= DI;
      WEN_l <= WEN;
      CEN_l <= CEN;
    end if;
  end process;

  ram : process(ADR_l,DI_l,WEN_l,CEN_l,memarr)
  begin
    if CEN_l = '0' then
      if WEN_l = '0' then
        if not is_x(ADR_l) then
          memarr(conv_integer(unsigned(ADR_l))) <= DI_l;
        end if;
      end if;
      if not is_x(ADR_l) then
        DOUT_l <= memarr(conv_integer(unsigned(ADR_l)));
      else
        DOUT_l <= (others => 'X');
      end if;     
     end if;
  end process;

  DOUT <= DOUT_l when OEN = '0' else (others => 'Z');

end;

-- syncronous umc18 sram

LIBRARY ieee;
use IEEE.std_logic_1164.all;
package tech_umc18_sim is

component umc18_syncram_ss
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    ADR   : in std_logic_vector((abits -1) downto 0);
    DI    : in std_logic_vector((dbits -1) downto 0);
    DOUT    : out std_logic_vector((dbits -1) downto 0);
    CK    : in std_logic;
    WEN   : in std_logic;
    CEN   : in std_logic;
    OEN   : in std_logic
  ); 
end component;     

-- syncronous umc18 dpram

component umc18_dpram_ss
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    DI: in std_logic_vector (dbits -1 downto 0);
    RADR: in std_logic_vector (abits -1 downto 0);
    WADR: in std_logic_vector (abits -1 downto 0);
    REN,WEN : in std_logic;
    RCK,WCK : in std_logic;
    DOUT: out std_logic_vector (dbits -1 downto 0)
  );
end component;

end;
-- Address, control and data signals latched on rising ME. 
-- Write enable (WEN) active low.

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_umc18_sim.all;

entity R256X24M4 is
  port (
    ADR   : in std_logic_vector(7 downto 0);
    DI    : in std_logic_vector(23 downto 0);
    DOUT    : out std_logic_vector(23 downto 0);
    CK    : in std_logic;
    WEN   : in std_logic;
    CEN   : in std_logic;
    OEN   : in std_logic
  );
end;

architecture behavioral of R256X24M4 is
begin
  syncram0 : umc18_syncram_ss
    generic map ( abits => 8, dbits => 24)
    port map ( ADR => ADR, DI => DI, DOUT => DOUT, CK => CK, 
               WEN => WEN, CEN => CEN, OEN => OEN);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_umc18_sim.all;

entity R256X25M4 is
  port (
    ADR   : in std_logic_vector(7 downto 0);
    DI    : in std_logic_vector(24 downto 0);
    DOUT    : out std_logic_vector(24 downto 0);
    CK    : in std_logic;
    WEN   : in std_logic;
    CEN   : in std_logic;
    OEN   : in std_logic
  );
end;

architecture behavioral of R256X25M4 is
begin
  syncram0 : umc18_syncram_ss
    generic map ( abits => 8, dbits => 25)
    port map ( ADR => ADR, DI => DI, DOUT => DOUT, CK => CK, 
               WEN => WEN, CEN => CEN, OEN => OEN);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_umc18_sim.all;

entity R256X26M4 is
  port (
    ADR   : in std_logic_vector(7 downto 0);
    DI    : in std_logic_vector(25 downto 0);
    DOUT    : out std_logic_vector(25 downto 0);
    CK    : in std_logic;
    WEN   : in std_logic;
    CEN   : in std_logic;
    OEN   : in std_logic
  );
end;

architecture behavioral of R256X26M4 is
begin
  syncram0 : umc18_syncram_ss
    generic map ( abits => 8, dbits => 26)
    port map ( ADR => ADR, DI => DI, DOUT => DOUT, CK => CK, 
               WEN => WEN, CEN => CEN, OEN => OEN);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_umc18_sim.all;

entity R1024X32M4 is
  port (
    ADR   : in std_logic_vector(9 downto 0);
    DI    : in std_logic_vector(31 downto 0);
    DOUT    : out std_logic_vector(31 downto 0);
    CK    : in std_logic;
    WEN   : in std_logic;
    CEN   : in std_logic;
    OEN   : in std_logic
  );
end;

architecture behavioral of R1024X32M4 is
begin
  syncram0 : umc18_syncram_ss
    generic map ( abits => 10, dbits => 32)
    port map ( ADR => ADR, DI => DI, DOUT => DOUT, CK => CK, 
               WEN => WEN, CEN => CEN, OEN => OEN);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_umc18_sim.all;

entity R2048X32M8 is
  port (
    ADR   : in std_logic_vector(10 downto 0);
    DI    : in std_logic_vector(31 downto 0);
    DOUT    : out std_logic_vector(31 downto 0);
    CK    : in std_logic;
    WEN   : in std_logic;
    CEN   : in std_logic;
    OEN   : in std_logic
  );
end;

architecture behavioral of R2048X32M8 is
begin
  syncram0 : umc18_syncram_ss
    generic map ( abits => 11, dbits => 32)
    port map ( ADR => ADR, DI => DI, DOUT => DOUT, CK => CK, 
               WEN => WEN, CEN => CEN, OEN => OEN);
end behavioral;


library ieee;
use IEEE.std_logic_1164.all;
use work.tech_umc18_sim.all;

entity R256X28M4 is
  port (
    ADR   : in std_logic_vector(7 downto 0);
    DI    : in std_logic_vector(27 downto 0);
    DOUT    : out std_logic_vector(27 downto 0);
    CK    : in std_logic;
    WEN   : in std_logic;
    CEN   : in std_logic;
    OEN   : in std_logic
  );
end;

architecture behavioral of R256X28M4 is
begin
  syncram0 : umc18_syncram_ss
    generic map ( abits => 8, dbits => 28)
    port map ( ADR => ADR, DI => DI, DOUT => DOUT, CK => CK, 
               WEN => WEN, CEN => CEN, OEN => OEN);
end behavioral;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_umc18_sim.all;

entity RF136X32M1 is
    port ( RCK    : in  std_logic;
         REN    : in  std_logic;
         RADR   : in  std_logic_vector(7 downto 0);
         WCK    : in  std_logic;
         WEN    : in  std_logic;
         WADR   : in  std_logic_vector(7 downto 0);
         DI     : in  std_logic_vector(31 downto 0);
         DOUT   : out std_logic_vector(31 downto 0) );
  end;

architecture behav of RF136X32M1 is
begin
    dp0 : umc18_dpram_ss 
      generic map (abits => 8, dbits => 32, words => 136)
      port map ( DI => DI, RADR => RADR, WADR => WADR, WEN => WEN,
		 REN => REN, RCK => RCK, WCK => WCK, DOUT => DOUT);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_umc18_sim.all;

entity RF168X32M1 is
    port ( RCK    : in  std_logic;
         REN    : in  std_logic;
         RADR   : in  std_logic_vector(7 downto 0);
         WCK    : in  std_logic;
         WEN    : in  std_logic;
         WADR   : in  std_logic_vector(7 downto 0);
         DI     : in  std_logic_vector(31 downto 0);
         DOUT   : out std_logic_vector(31 downto 0) );
  end;

architecture behav of RF168X32M1 is
begin
    dp0 : umc18_dpram_ss 
      generic map (abits => 8, dbits => 32, words => 168)
      port map ( DI => DI, RADR => RADR, WADR => WADR, WEN => WEN,
		 REN => REN, RCK => RCK, WCK => WCK, DOUT => DOUT);
end;

-- simple gate models
library IEEE;
use IEEE.std_logic_1164.all;
entity INVDL is port( A : in std_logic;  Z : out std_logic); end;
architecture rtl of INVDL is begin Z <= not A; end;

library IEEE;
use IEEE.std_logic_1164.all;
entity AND2DL is port( A1, A2 : in std_logic;  Z : out std_logic); end;
architecture rtl of AND2DL is begin Z <= A1 and A2; end;

library IEEE;
use IEEE.std_logic_1164.all;
entity OR2DL is port( A1, A2 : in std_logic;  Z : out std_logic); end;
architecture rtl of OR2DL is begin Z <= A1 or A2; end;

library IEEE;
use IEEE.std_logic_1164.all;
entity EXOR2DL is port( A1, A2 : in std_logic;  Z : out std_logic); end;
architecture rtl of EXOR2DL is begin Z <= A1 xor A2; end;

-- pragma translate_on

-- component declarations from true tech library
LIBRARY ieee;
use IEEE.std_logic_1164.all;
package tech_umc18_syn is

  component RF136X32M1 
    port ( RCK    : in  std_logic;
         REN    : in  std_logic;
         RADR   : in  std_logic_vector(7 downto 0);
         WCK    : in  std_logic;
         WEN    : in  std_logic;
         WADR   : in  std_logic_vector(7 downto 0);
         DI     : in  std_logic_vector(31 downto 0);
         DOUT   : out std_logic_vector(31 downto 0) );
  end component;

  component RF168X32M1 
    port ( RCK    : in  std_logic;
         REN    : in  std_logic;
         RADR   : in  std_logic_vector(7 downto 0);
         WCK    : in  std_logic;
         WEN    : in  std_logic;
         WADR   : in  std_logic_vector(7 downto 0);
         DI     : in  std_logic_vector(31 downto 0);
         DOUT   : out std_logic_vector(31 downto 0) );
  end component;

  component R256X24M4
    port ( ADR   : in std_logic_vector(7 downto 0);
	 DI    : in std_logic_vector(23 downto 0);
	 DOUT    : out std_logic_vector(23 downto 0);
	 CK    : in std_logic;
	 WEN   : in std_logic;
	 CEN   : in std_logic;
	 OEN   : in std_logic );
  end component;

  component R256X25M4
    port ( ADR   : in std_logic_vector(7 downto 0);
	 DI    : in std_logic_vector(25 downto 0);
	 DOUT    : out std_logic_vector(25 downto 0);
	 CK    : in std_logic;
	 WEN   : in std_logic;
	 CEN   : in std_logic;
	 OEN   : in std_logic );
  end component;

  component R256X26M4
    port ( ADR   : in std_logic_vector(7 downto 0);
	 DI    : in std_logic_vector(25 downto 0);
	 DOUT    : out std_logic_vector(25 downto 0);
	 CK    : in std_logic;
	 WEN   : in std_logic;
	 CEN   : in std_logic;
	 OEN   : in std_logic );
  end component;

  component R1024X32M4
    port ( ADR   : in std_logic_vector(9 downto 0);
	 DI    : in std_logic_vector(31 downto 0);
	 DOUT    : out std_logic_vector(31 downto 0);
	 CK    : in std_logic;
	 WEN   : in std_logic;
	 CEN   : in std_logic;
	 OEN   : in std_logic );
  end component;

  component R2048x32M8
    port ( ADR   : in std_logic_vector(10 downto 0);
	 DI    : in std_logic_vector(31 downto 0);
	 DOUT    : out std_logic_vector(31 downto 0);
	 CK    : in std_logic;
	 WEN   : in std_logic;
	 CEN   : in std_logic;
	 OEN   : in std_logic );
  end component;

  component C3I40 
    port (PAD : in std_logic; DI : out std_logic); 
  end component; 
  component C3I42 
    port (PAD : in std_logic; DI : out std_logic); 
  end component; 
  component C3O10 
    port (DO : in  std_logic; PAD : out  std_logic); 
  end component; 
  component C3O20 
    port (DO : in  std_logic; PAD : out  std_logic); 
  end component; 
  component C3O40 
    port (DO : in  std_logic; PAD : out  std_logic); 
  end component; 
  component C3B10U
    port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
  end component; 
  component C3B20U
    port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
  end component; 
  component C3B40U
    port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
  end component; 
  component C3B10
    port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
  end component; 
  component C3B20
    port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
  end component; 
  component C3B40
    port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
  end component; 
  component CD3B10T
    port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
  end component; 
  component CD3B20T
    port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
  end component; 
  component CD3B40T
    port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
  end component; 
  component CD3O10T
    port ( DO : in std_logic; PAD : out std_logic);
  end component; 
  component CD3O20T
    port ( DO : in std_logic; PAD : out std_logic);
  end component; 
  component CD3O40T
    port ( DO : in std_logic; PAD : out std_logic);
  end component; 
  component C3B42
    port ( DO, EN : in std_logic; DI : out std_logic; PAD : inout std_logic);
  end component; 

  component INVDL port( A : in std_logic;  Z : out std_logic); end component;
  component AND2DL port( A1, A2 : in std_logic;  Z : out std_logic); end component;
  component OR2DL port( A1, A2 : in std_logic;  Z : out std_logic); end component;
  component EXOR2DL port( A1, A2 : in std_logic;  Z : out std_logic); end component;

end;


------------------------------------------------------------------
-- sync ram generator --------------------------------------------
------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_umc18_syn.all;

entity umc18_syncram is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector(abits -1 downto 0);
    clk      : in std_logic;
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable   : in std_logic;
    write    : in std_logic
  );
end;

architecture rtl of umc18_syncram is
  signal gnd   : std_logic;
  signal wr   : std_logic;
  signal a    : std_logic_vector(19 downto 0);
  signal d, q : std_logic_vector(37 downto 0);
  constant synopsys_bug : std_logic_vector(37 downto 0) := (others => '0');
begin

  wr <= not write; 
  gnd <= '0'; 
  a(abits -1 downto 0) <= address; 
  a(abits+1 downto abits) <= synopsys_bug(abits+1 downto abits);
  d(dbits -1 downto 0) <= datain; 
  d(dbits+1 downto dbits) <= synopsys_bug(dbits+1 downto dbits);

  dataout <= q(dbits -1 downto 0);

  a8d24 : if (abits <= 8) and (dbits <= 24) generate
    id0 : R256X24M4 
	  port map ( ADR => a(7 downto 0), DI => d(23 downto 0), 
	             DOUT => q(23 downto 0), CK => clk, WEN => wr,
		     CEN => gnd, OEN => gnd);
  end generate;
  a8d25 : if (abits <= 8) and (dbits = 25) generate
    id0 : R256X26M4 
	  port map ( ADR => a(7 downto 0), DI => d(25 downto 0), 
	             DOUT => q(25 downto 0), CK => clk, WEN => wr,
		     CEN => gnd, OEN => gnd);
  end generate;
  a8d26 : if (abits <= 8) and (dbits = 26) generate
    id0 : R256X26M4 
	  port map ( ADR => a(7 downto 0), DI => d(25 downto 0), 
	             DOUT => q(25 downto 0), CK => clk, WEN => wr,
		     CEN => gnd, OEN => gnd);
  end generate;
  a10d32 : if (abits = 10) and (dbits <= 32) generate
    id0 : R1024X32M4 
	  port map ( ADR => a(9 downto 0), DI => d(31 downto 0), 
	             DOUT => q(31 downto 0), CK => clk, WEN => wr,
		     CEN => gnd, OEN => gnd);
  end generate;
  a11d32 : if (abits = 11) and (dbits <= 32) generate
    id0 : R2048X32M8 
	  port map ( ADR => a(10 downto 0), DI => d(31 downto 0), 
	             DOUT => q(31 downto 0), CK => clk, WEN => wr,
		     CEN => gnd, OEN => gnd);
  end generate;

end rtl;

------------------------------------------------------------------
-- regfile generator  --------------------------------------------
------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_iface.all;
use work.tech_umc18_syn.all;

entity umc18_regfile is
  generic ( 
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 128
  );
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    clkn     : in clk_type;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
end;

architecture rtl of umc18_regfile is

signal qq1, qq2 : std_logic_vector(dbits-1 downto 0);
signal wen, ren1, ren2 : std_logic;

begin
  ren1 <= not rfi.ren1;
  ren2 <= not rfi.ren2;
  wen <= not rfi.wren;

  dp136x32 : if (words = 136) and (dbits = 32) generate
    u0: RF136X32M1

	port map (RCK => clkn, REN => ren1, RADR => rfi.rd1addr(abits -1 downto 0),
	          WCK => clk, WEN => wen, WADR => rfi.wraddr(abits -1 downto 0), 

		  DI => rfi.wrdata(dbits -1 downto 0), DOUT => qq1);
    u1: RF136X32M1

	port map (RCK => clkn, REN => ren2, RADR => rfi.rd2addr(abits -1 downto 0),
	          WCK => clk, WEN => wen, WADR => rfi.wraddr(abits -1 downto 0), 

		  DI => rfi.wrdata(dbits -1 downto 0), DOUT => qq2);
  end generate;

  dp168x32 : if (words = 168) and (dbits = 32) generate
    u0: RF168X32M1

	port map (RCK => clkn, REN => ren1, RADR => rfi.rd1addr(abits -1 downto 0),
	          WCK => clk, WEN => wen, WADR => rfi.wraddr(abits -1 downto 0), 

		  DI => rfi.wrdata(dbits -1 downto 0), DOUT => qq1);
    u1: RF168X32M1

	port map (RCK => clkn, REN => ren2, RADR => rfi.rd2addr(abits -1 downto 0),
	          WCK => clk, WEN => wen, WADR => rfi.wraddr(abits -1 downto 0), 

		  DI => rfi.wrdata(dbits -1 downto 0), DOUT => qq2);
  end generate;

  rfo.data1 <= qq1(dbits-1 downto 0);
  rfo.data2 <= qq2(dbits-1 downto 0);

end;


------------------------------------------------------------------
-- mapping generic pads on tech pads ---------------------------------
------------------------------------------------------------------

-- input pad
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_umc18_syn.all;
entity umc18_inpad is port (pad : in std_logic; q : out std_logic); end; 
architecture syn of umc18_inpad is begin 
  i0 : C3I40 port map (PAD => pad, DI => q); 
end;

-- input schmitt pad
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_umc18_syn.all;
entity umc18_smpad is port (pad : in std_logic; q : out std_logic); end; 
architecture syn of umc18_smpad is begin 
  i0 : C3I42 port map (PAD => pad, DI => q); 
end;

-- output pads
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_umc18_syn.all;
entity umc18_outpad is
  generic (drive : integer := 1);
  port (d : in std_logic; pad : out std_logic);
 end; 
architecture syn of umc18_outpad is begin 
  d1 : if drive = 1 generate
    u0 : C3O10 port map (PAD => pad, DO => d);
  end generate;
  d2 : if drive = 2 generate
    i0 : C3O20 port map (PAD => pad, DO => d);
  end generate;
  d3 : if drive > 2 generate
    i0 : C3O40 port map (PAD => pad, DO => d);
  end generate;
end;

-- tri-state output pads with pull-up
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_umc18_syn.all;
entity umc18_toutpadu is 
  generic (drive : integer := 1);
  port (d, en : in  std_logic; pad : out  std_logic);
end; 
architecture syn of umc18_toutpadu is 
signal nc,p : std_logic;
begin 
  d1 : if drive = 1 generate
    i0 : C3B10U port map (PAD => p, DO => d, DI => nc, EN => en);
  end generate;
  d2 : if drive = 2 generate
    i0 : C3B20U port map (PAD => p, DO => d, DI => nc, EN => en);
  end generate;
  d3 : if drive > 2 generate
    i0 : C3B40U port map (PAD => p, DO => d, DI => nc, EN => en);
  end generate;
  pad <= p;
end;

-- bidirectional pad 2/4/8mA 4X
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_umc18_syn.all;
entity umc18_iopad is
  generic (drive : integer := 1);
  port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
end;
architecture syn of umc18_iopad is 
signal eni : std_logic;
begin 
  eni <= not en;
  d1 : if drive = 1 generate
    i0 : C3B10 port map (PAD => pad, DO => d, EN => eni, DI => q);
  end generate;
  d2 : if drive = 2 generate
    i0 : C3B20 port map (PAD => pad, DO => d, EN => eni, DI => q);
  end generate;
  d3 : if drive > 2 generate
    i0 : C3B40 port map (PAD => pad, DO => d, EN => eni, DI => q);
  end generate;
end;

-- bidirectional pad with open-drain
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_umc18_syn.all;
entity umc18_iodpad is
  generic (drive : integer := 1);
  port ( d : in std_logic; q : out std_logic; pad : inout std_logic);
end;
architecture syn of umc18_iodpad is 
signal vcc : std_logic;
begin 
  vcc <= '1';
  d1 : if drive = 1 generate
    i0 : CD3B10T port map (PAD => pad, DO => d, EN => vcc, DI => q);
  end generate;
  d2 : if drive = 2 generate
    i0 : CD3B20T port map (PAD => pad, DO => d, EN => vcc, DI => q);
  end generate;
  d3 : if drive > 2 generate
    i0 : CD3B40T port map (PAD => pad, DO => d, EN => vcc, DI => q);
  end generate;
end;

-- output pad with open-drain
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_umc18_syn.all;
entity umc18_odpad is
  generic (drive : integer := 1);
  port (d : in std_logic; pad : out std_logic);
end;
architecture syn of umc18_odpad is 
begin 
  d1 : if drive = 1 generate
    i0 : CD3O10T port map (PAD => pad, DO => d);
  end generate;
  d2 : if drive = 2 generate
    i0 : CD3O20T port map (PAD => pad, DO => d);
  end generate;
  d3 : if drive > 2 generate
    i0 : CD3O40T port map (PAD => pad, DO => d);
  end generate;
end;

-- bidirectional pad 8mA 4X schmitt trigger
library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_umc18_syn.all;
entity umc18_smiopad is
  generic (drive : integer := 1);
  port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
end;
architecture syn of umc18_smiopad is 
signal eni : std_logic;
begin 
  eni <= not en;
  i0 : C3B42 port map (PAD => pad, DO => d, EN => eni, DI => q);
end;

