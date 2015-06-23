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
-- Entity:      unisim_iddr_reg
-- File:        unisim_iddr_reg.vhd
-- Author:      David Lindh, Jiri Gaisler - Gaisler Research
-- Description: Xilinx DDR input register
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.iddr;
--pragma translate_on

entity unisim_iddr_reg is
  generic (tech : integer := virtex4);
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
end;
  
architecture rtl of unisim_iddr_reg is
    attribute BOX_TYPE : string;
--    attribute syn_useioff : boolean; 
--    attribute syn_useioff of rtl : architecture is false;

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
    attribute BOX_TYPE of IDDR : component is "PRIMITIVE";
  signal preQ2 : std_ulogic;
   
begin

      
-- SAME EDGE mode have when this is written an incorrect P&R
-- timing model, instead OPPOSITE_MODE with an extra register is used
--      V4 : if tech = virtex4 generate
--        U0 : IDDR
--          generic map(
--            DDR_CLK_EDGE => "SAME_EDGE",
--            INIT_Q1 =>  '0',
--            INIT_Q2 =>  '0',
--            SRTYPE =>  "ASYNC")
--          Port map(
--            Q1 => Q1,
--            Q2 => Q2,
--            C => C1,
--            CE => CE,                 
--            D => D,
--            R => R,    
--            S => S);
--     end generate;

       V4 : if (tech = virtex4) or (tech = virtex5) generate
       U0 : IDDR generic map( DDR_CLK_EDGE => "OPPOSITE_EDGE"
--           ,INIT_Q1 =>  '0',
--           INIT_Q2 =>  '0',
--           SRTYPE =>  "ASYNC"
)
         Port map( Q1 => Q1, Q2 => preQ2, C => C1, CE => CE,                 
           	   D => D, R => R,    S => S);

      q3reg : process (C1, preQ2, R)
        begin
          if R='1' then --asynchronous reset, active high
            Q2 <= '0';
          elsif C1'event and C1='1' then --Clock event - posedge
            Q2 <= preQ2;
          end if;
        end process;
     end generate;

    V2 : if tech = virtex2 or tech = spartan3 generate

      -- CE and S inputs inactive for virtex 2
      
      q1reg : process (C1, D, R)
      begin
        if R='1' then --asynchronous reset, active high
          Q1 <= '0';
        elsif C1'event and C1='1' then --Clock event - posedge
          Q1 <= D;
        end if;
      end process;

      q2reg : process (C1, D, R)
      begin
        if R='1' then --asynchronous reset, active high
         preQ2 <= '0';
        elsif C1'event and C1='0' then --Clock event - negedge
         preQ2 <= D;
        end if;
      end process;

      q3reg : process (C1, preQ2, R)
      begin
        if R='1' then --asynchronous reset, active high
          Q2 <= '0';
        elsif C1'event and C1='1' then --Clock event - posedge
          Q2 <= preQ2;
        end if;
      end process;

 -- NOTE: You must include the following constraints in the .ucf
 -- file when running back-end tools,
 -- in order to ensure that IOB DDR registers are used:
 -- -- INST "q2_reg" IOB=TRUE;
 -- INST "q1_reg" IOB=TRUE;
 -- -- Depending on the synthesis tools you use, it may be required to
 -- check the edif file for modifications to
 -- original net names...in this case, Synopsys changed the
 -- names: q1 and q2 to q1_reg and q2_reg

    end generate;
      
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.oddr;
use unisim.FDDRRSE;
--pragma translate_on

entity unisim_oddr_reg is
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
end;

architecture rtl of unisim_oddr_reg is
  attribute BOX_TYPE : string;


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
  attribute BOX_TYPE of
    ODDR : component is "PRIMITIVE";

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
  attribute BOX_TYPE of
    FDDRRSE : component is "PRIMITIVE";

  signal preD2 : std_ulogic;
  
begin

-- SAME EDGE mode have when this is written an incorrect P&R
-- timing model, instead OPPOSITE_MODE with an extra register is used
--    V4 : if tech = virtex4 generate
--      U0 : ODDR
--        generic map(
--          DDR_CLK_EDGE => "SAME_EDGE",
--          INIT => '0',
--          SRTYPE => "ASYNC")
--        port map(
--          Q => Q,
--          C => C1,
--          CE => CE,
--          D1 => D1,
--          D2 => D2,
--          R => R,
--          S => S);
--      end generate;

  V4 : if (tech = virtex4) or (tech = virtex5) generate

    d2reg : process (C1, D2, R)
       begin
         if R='1' then --asynchronous reset, active high
           preD2 <= '0';
         elsif C1'event and C1='1' then --Clock event - posedge
           preD2 <= D2;
         end if;
       end process;
  
     U0 : ODDR generic map( DDR_CLK_EDGE => "OPPOSITE_EDGE" -- ,INIT => '0'
         , SRTYPE => "ASYNC")
       port map(
         Q => Q,
         C => C1,
         CE => CE,
         D1 => D1,
         D2 => preD2,
         R => R,
         S => S);
  end generate;

  V2 : if tech = virtex2 or tech = spartan3 generate

      d2reg : process (C1, D2, R)
      begin
        if R='1' then --asynchronous reset, active high
          preD2 <= '0';
        elsif C1'event and C1='1' then --Clock event - posedge
          preD2 <= D2;
        end if;
      end process;

      c_dm : component FDDRRSE
--        generic map( INIT => '0')
        port map(
          Q =>  Q,
          D0 => D1,
          D1 => preD2,
          C0 => C1,
          C1 => C2,
          CE => CE,
          R => R,
          S => S);
  end generate;
      

end ;

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.fd;
use unisim.FDDRRSE;
--pragma translate_on

entity oddrv2 is
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
end;

architecture rtl of oddrv2 is
  component FD
	generic ( INIT : bit := '0');
	port (  Q : out std_ulogic;
		C : in std_ulogic;
		D : in std_ulogic);
  end component;

  component FDDRRSE
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

  signal preD2 : std_ulogic;
  
begin

  rf : FD port map ( Q => preD2, C => C1, D => D2);
  rr : FDDRRSE  port map ( Q => Q, C0 => C1, C1 => C2, 
	CE => CE, D0 => D1, D1 => preD2, R => R, S => R);
end;


library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library unisim;
use unisim.fd;
use unisim.oddr2;
--pragma translate_on

entity oddrc3e is
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
end;

architecture rtl of oddrc3e is
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

  signal preD2 : std_ulogic;
  
begin

  rf : FD port map ( Q => preD2, C => C1, D => D2);
  rr : ODDR2  port map ( Q => Q, C0 => C1, C1 => C2, 
	CE => CE, D0 => D1, D1 => preD2, R => R, S => R);
end;




