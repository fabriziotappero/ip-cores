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
-- Entity:      charrom
-- File:        charrom.vhd
-- Author:      Marcus Hellqvist
-- Description: Character ROM for video controller
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;

entity charrom is
  port(
    clk         : in std_ulogic;
    addr        : in std_logic_vector(11 downto 0);
    data        : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of charrom is

signal romdata  : std_logic_vector(7 downto 0);
signal romaddr  : std_logic_vector(11 downto 0);

begin
 data <= romdata;
 
 p0: process(clk)
 begin
   if rising_edge(clk) then
     romaddr <= addr;
   end if;
 end process;
 
 p1: process(romaddr)
 begin
 case conv_integer(romaddr) is
        when 16#000# => romdata <= X"00"; -- 
        when 16#100# => romdata <= X"00"; -- 
        when 16#200# => romdata <= X"00"; -- 
        when 16#300# => romdata <= X"00"; -- 
        when 16#400# => romdata <= X"00"; -- 
        when 16#500# => romdata <= X"00"; -- 
        when 16#600# => romdata <= X"00"; -- 
        when 16#700# => romdata <= X"00"; -- 
        when 16#800# => romdata <= X"00"; -- 
        when 16#900# => romdata <= X"00"; -- 
        when 16#a00# => romdata <= X"00"; -- 
        when 16#b00# => romdata <= X"00"; -- 
        when 16#c00# => romdata <= X"00"; -- 
        when 16#020# => romdata <= X"00"; --  
        when 16#120# => romdata <= X"00"; --  
        when 16#220# => romdata <= X"00"; --  
        when 16#320# => romdata <= X"00"; --  
        when 16#420# => romdata <= X"00"; --  
        when 16#520# => romdata <= X"00"; --  
        when 16#620# => romdata <= X"00"; --  
        when 16#720# => romdata <= X"00"; --  
        when 16#820# => romdata <= X"00"; --  
        when 16#920# => romdata <= X"00"; --  
        when 16#a20# => romdata <= X"00"; --  
        when 16#b20# => romdata <= X"00"; --  
        when 16#c20# => romdata <= X"00"; --  
        when 16#021# => romdata <= X"00"; -- !
        when 16#121# => romdata <= X"00"; -- !
        when 16#221# => romdata <= X"10"; -- !
        when 16#321# => romdata <= X"10"; -- !
        when 16#421# => romdata <= X"10"; -- !
        when 16#521# => romdata <= X"10"; -- !
        when 16#621# => romdata <= X"10"; -- !
        when 16#721# => romdata <= X"10"; -- !
        when 16#821# => romdata <= X"10"; -- !
        when 16#921# => romdata <= X"00"; -- !
        when 16#a21# => romdata <= X"10"; -- !
        when 16#b21# => romdata <= X"00"; -- !
        when 16#c21# => romdata <= X"00"; -- !
        when 16#022# => romdata <= X"00"; -- "
        when 16#122# => romdata <= X"00"; -- "
        when 16#222# => romdata <= X"24"; -- "
        when 16#322# => romdata <= X"24"; -- "
        when 16#422# => romdata <= X"24"; -- "
        when 16#522# => romdata <= X"00"; -- "
        when 16#622# => romdata <= X"00"; -- "
        when 16#722# => romdata <= X"00"; -- "
        when 16#822# => romdata <= X"00"; -- "
        when 16#922# => romdata <= X"00"; -- "
        when 16#a22# => romdata <= X"00"; -- "
        when 16#b22# => romdata <= X"00"; -- "
        when 16#c22# => romdata <= X"00"; -- "
        when 16#023# => romdata <= X"00"; -- #
        when 16#123# => romdata <= X"00"; -- #
        when 16#223# => romdata <= X"00"; -- #
        when 16#323# => romdata <= X"24"; -- #
        when 16#423# => romdata <= X"24"; -- #
        when 16#523# => romdata <= X"7e"; -- #
        when 16#623# => romdata <= X"24"; -- #
        when 16#723# => romdata <= X"7e"; -- #
        when 16#823# => romdata <= X"24"; -- #
        when 16#923# => romdata <= X"24"; -- #
        when 16#a23# => romdata <= X"00"; -- #
        when 16#b23# => romdata <= X"00"; -- #
        when 16#c23# => romdata <= X"00"; -- #
        when 16#024# => romdata <= X"00"; -- $
        when 16#124# => romdata <= X"00"; -- $
        when 16#224# => romdata <= X"10"; -- $
        when 16#324# => romdata <= X"3c"; -- $
        when 16#424# => romdata <= X"50"; -- $
        when 16#524# => romdata <= X"50"; -- $
        when 16#624# => romdata <= X"38"; -- $
        when 16#724# => romdata <= X"14"; -- $
        when 16#824# => romdata <= X"14"; -- $
        when 16#924# => romdata <= X"78"; -- $
        when 16#a24# => romdata <= X"10"; -- $
        when 16#b24# => romdata <= X"00"; -- $
        when 16#c24# => romdata <= X"00"; -- $
        when 16#025# => romdata <= X"00"; -- %
        when 16#125# => romdata <= X"00"; -- %
        when 16#225# => romdata <= X"22"; -- %
        when 16#325# => romdata <= X"52"; -- %
        when 16#425# => romdata <= X"24"; -- %
        when 16#525# => romdata <= X"08"; -- %
        when 16#625# => romdata <= X"08"; -- %
        when 16#725# => romdata <= X"10"; -- %
        when 16#825# => romdata <= X"24"; -- %
        when 16#925# => romdata <= X"2a"; -- %
        when 16#a25# => romdata <= X"44"; -- %
        when 16#b25# => romdata <= X"00"; -- %
        when 16#c25# => romdata <= X"00"; -- %
        when 16#026# => romdata <= X"00"; -- &
        when 16#126# => romdata <= X"00"; -- &
        when 16#226# => romdata <= X"00"; -- &
        when 16#326# => romdata <= X"00"; -- &
        when 16#426# => romdata <= X"30"; -- &
        when 16#526# => romdata <= X"48"; -- &
        when 16#626# => romdata <= X"48"; -- &
        when 16#726# => romdata <= X"30"; -- &
        when 16#826# => romdata <= X"4a"; -- &
        when 16#926# => romdata <= X"44"; -- &
        when 16#a26# => romdata <= X"3a"; -- &
        when 16#b26# => romdata <= X"00"; -- &
        when 16#c26# => romdata <= X"00"; -- &
        when 16#027# => romdata <= X"00"; -- '
        when 16#127# => romdata <= X"00"; -- '
        when 16#227# => romdata <= X"10"; -- '
        when 16#327# => romdata <= X"10"; -- '
        when 16#427# => romdata <= X"10"; -- '
        when 16#527# => romdata <= X"00"; -- '
        when 16#627# => romdata <= X"00"; -- '
        when 16#727# => romdata <= X"00"; -- '
        when 16#827# => romdata <= X"00"; -- '
        when 16#927# => romdata <= X"00"; -- '
        when 16#a27# => romdata <= X"00"; -- '
        when 16#b27# => romdata <= X"00"; -- '
        when 16#c27# => romdata <= X"00"; -- '
        when 16#028# => romdata <= X"00"; -- (
        when 16#128# => romdata <= X"00"; -- (
        when 16#228# => romdata <= X"04"; -- (
        when 16#328# => romdata <= X"08"; -- (
        when 16#428# => romdata <= X"08"; -- (
        when 16#528# => romdata <= X"10"; -- (
        when 16#628# => romdata <= X"10"; -- (
        when 16#728# => romdata <= X"10"; -- (
        when 16#828# => romdata <= X"08"; -- (
        when 16#928# => romdata <= X"08"; -- (
        when 16#a28# => romdata <= X"04"; -- (
        when 16#b28# => romdata <= X"00"; -- (
        when 16#c28# => romdata <= X"00"; -- (
        when 16#029# => romdata <= X"00"; -- )
        when 16#129# => romdata <= X"00"; -- )
        when 16#229# => romdata <= X"20"; -- )
        when 16#329# => romdata <= X"10"; -- )
        when 16#429# => romdata <= X"10"; -- )
        when 16#529# => romdata <= X"08"; -- )
        when 16#629# => romdata <= X"08"; -- )
        when 16#729# => romdata <= X"08"; -- )
        when 16#829# => romdata <= X"10"; -- )
        when 16#929# => romdata <= X"10"; -- )
        when 16#a29# => romdata <= X"20"; -- )
        when 16#b29# => romdata <= X"00"; -- )
        when 16#c29# => romdata <= X"00"; -- )
        when 16#02a# => romdata <= X"00"; -- *
        when 16#12a# => romdata <= X"00"; -- *
        when 16#22a# => romdata <= X"24"; -- *
        when 16#32a# => romdata <= X"18"; -- *
        when 16#42a# => romdata <= X"7e"; -- *
        when 16#52a# => romdata <= X"18"; -- *
        when 16#62a# => romdata <= X"24"; -- *
        when 16#72a# => romdata <= X"00"; -- *
        when 16#82a# => romdata <= X"00"; -- *
        when 16#92a# => romdata <= X"00"; -- *
        when 16#a2a# => romdata <= X"00"; -- *
        when 16#b2a# => romdata <= X"00"; -- *
        when 16#c2a# => romdata <= X"00"; -- *
        when 16#02b# => romdata <= X"00"; -- +
        when 16#12b# => romdata <= X"00"; -- +
        when 16#22b# => romdata <= X"00"; -- +
        when 16#32b# => romdata <= X"00"; -- +
        when 16#42b# => romdata <= X"10"; -- +
        when 16#52b# => romdata <= X"10"; -- +
        when 16#62b# => romdata <= X"7c"; -- +
        when 16#72b# => romdata <= X"10"; -- +
        when 16#82b# => romdata <= X"10"; -- +
        when 16#92b# => romdata <= X"00"; -- +
        when 16#a2b# => romdata <= X"00"; -- +
        when 16#b2b# => romdata <= X"00"; -- +
        when 16#c2b# => romdata <= X"00"; -- +
        when 16#02c# => romdata <= X"00"; -- ,
        when 16#12c# => romdata <= X"00"; -- ,
        when 16#22c# => romdata <= X"00"; -- ,
        when 16#32c# => romdata <= X"00"; -- ,
        when 16#42c# => romdata <= X"00"; -- ,
        when 16#52c# => romdata <= X"00"; -- ,
        when 16#62c# => romdata <= X"00"; -- ,
        when 16#72c# => romdata <= X"00"; -- ,
        when 16#82c# => romdata <= X"00"; -- ,
        when 16#92c# => romdata <= X"38"; -- ,
        when 16#a2c# => romdata <= X"30"; -- ,
        when 16#b2c# => romdata <= X"40"; -- ,
        when 16#c2c# => romdata <= X"00"; -- ,
        when 16#02d# => romdata <= X"00"; -- -
        when 16#12d# => romdata <= X"00"; -- -
        when 16#22d# => romdata <= X"00"; -- -
        when 16#32d# => romdata <= X"00"; -- -
        when 16#42d# => romdata <= X"00"; -- -
        when 16#52d# => romdata <= X"00"; -- -
        when 16#62d# => romdata <= X"7c"; -- -
        when 16#72d# => romdata <= X"00"; -- -
        when 16#82d# => romdata <= X"00"; -- -
        when 16#92d# => romdata <= X"00"; -- -
        when 16#a2d# => romdata <= X"00"; -- -
        when 16#b2d# => romdata <= X"00"; -- -
        when 16#c2d# => romdata <= X"00"; -- -
        when 16#02e# => romdata <= X"00"; -- .
        when 16#12e# => romdata <= X"00"; -- .
        when 16#22e# => romdata <= X"00"; -- .
        when 16#32e# => romdata <= X"00"; -- .
        when 16#42e# => romdata <= X"00"; -- .
        when 16#52e# => romdata <= X"00"; -- .
        when 16#62e# => romdata <= X"00"; -- .
        when 16#72e# => romdata <= X"00"; -- .
        when 16#82e# => romdata <= X"00"; -- .
        when 16#92e# => romdata <= X"10"; -- .
        when 16#a2e# => romdata <= X"38"; -- .
        when 16#b2e# => romdata <= X"10"; -- .
        when 16#c2e# => romdata <= X"00"; -- .
        when 16#02f# => romdata <= X"00"; -- /
        when 16#12f# => romdata <= X"00"; -- /
        when 16#22f# => romdata <= X"02"; -- /
        when 16#32f# => romdata <= X"02"; -- /
        when 16#42f# => romdata <= X"04"; -- /
        when 16#52f# => romdata <= X"08"; -- /
        when 16#62f# => romdata <= X"10"; -- /
        when 16#72f# => romdata <= X"20"; -- /
        when 16#82f# => romdata <= X"40"; -- /
        when 16#92f# => romdata <= X"80"; -- /
        when 16#a2f# => romdata <= X"80"; -- /
        when 16#b2f# => romdata <= X"00"; -- /
        when 16#c2f# => romdata <= X"00"; -- /
        when 16#030# => romdata <= X"00"; -- 0
        when 16#130# => romdata <= X"00"; -- 0
        when 16#230# => romdata <= X"18"; -- 0
        when 16#330# => romdata <= X"24"; -- 0
        when 16#430# => romdata <= X"42"; -- 0
        when 16#530# => romdata <= X"42"; -- 0
        when 16#630# => romdata <= X"42"; -- 0
        when 16#730# => romdata <= X"42"; -- 0
        when 16#830# => romdata <= X"42"; -- 0
        when 16#930# => romdata <= X"24"; -- 0
        when 16#a30# => romdata <= X"18"; -- 0
        when 16#b30# => romdata <= X"00"; -- 0
        when 16#c30# => romdata <= X"00"; -- 0
        when 16#031# => romdata <= X"00"; -- 1
        when 16#131# => romdata <= X"00"; -- 1
        when 16#231# => romdata <= X"10"; -- 1
        when 16#331# => romdata <= X"30"; -- 1
        when 16#431# => romdata <= X"50"; -- 1
        when 16#531# => romdata <= X"10"; -- 1
        when 16#631# => romdata <= X"10"; -- 1
        when 16#731# => romdata <= X"10"; -- 1
        when 16#831# => romdata <= X"10"; -- 1
        when 16#931# => romdata <= X"10"; -- 1
        when 16#a31# => romdata <= X"7c"; -- 1
        when 16#b31# => romdata <= X"00"; -- 1
        when 16#c31# => romdata <= X"00"; -- 1
        when 16#032# => romdata <= X"00"; -- 2
        when 16#132# => romdata <= X"00"; -- 2
        when 16#232# => romdata <= X"3c"; -- 2
        when 16#332# => romdata <= X"42"; -- 2
        when 16#432# => romdata <= X"42"; -- 2
        when 16#532# => romdata <= X"02"; -- 2
        when 16#632# => romdata <= X"04"; -- 2
        when 16#732# => romdata <= X"18"; -- 2
        when 16#832# => romdata <= X"20"; -- 2
        when 16#932# => romdata <= X"40"; -- 2
        when 16#a32# => romdata <= X"7e"; -- 2
        when 16#b32# => romdata <= X"00"; -- 2
        when 16#c32# => romdata <= X"00"; -- 2
        when 16#033# => romdata <= X"00"; -- 3
        when 16#133# => romdata <= X"00"; -- 3
        when 16#233# => romdata <= X"7e"; -- 3
        when 16#333# => romdata <= X"02"; -- 3
        when 16#433# => romdata <= X"04"; -- 3
        when 16#533# => romdata <= X"08"; -- 3
        when 16#633# => romdata <= X"1c"; -- 3
        when 16#733# => romdata <= X"02"; -- 3
        when 16#833# => romdata <= X"02"; -- 3
        when 16#933# => romdata <= X"42"; -- 3
        when 16#a33# => romdata <= X"3c"; -- 3
        when 16#b33# => romdata <= X"00"; -- 3
        when 16#c33# => romdata <= X"00"; -- 3
        when 16#034# => romdata <= X"00"; -- 4
        when 16#134# => romdata <= X"00"; -- 4
        when 16#234# => romdata <= X"04"; -- 4
        when 16#334# => romdata <= X"0c"; -- 4
        when 16#434# => romdata <= X"14"; -- 4
        when 16#534# => romdata <= X"24"; -- 4
        when 16#634# => romdata <= X"44"; -- 4
        when 16#734# => romdata <= X"44"; -- 4
        when 16#834# => romdata <= X"7e"; -- 4
        when 16#934# => romdata <= X"04"; -- 4
        when 16#a34# => romdata <= X"04"; -- 4
        when 16#b34# => romdata <= X"00"; -- 4
        when 16#c34# => romdata <= X"00"; -- 4
        when 16#035# => romdata <= X"00"; -- 5
        when 16#135# => romdata <= X"00"; -- 5
        when 16#235# => romdata <= X"7e"; -- 5
        when 16#335# => romdata <= X"40"; -- 5
        when 16#435# => romdata <= X"40"; -- 5
        when 16#535# => romdata <= X"5c"; -- 5
        when 16#635# => romdata <= X"62"; -- 5
        when 16#735# => romdata <= X"02"; -- 5
        when 16#835# => romdata <= X"02"; -- 5
        when 16#935# => romdata <= X"42"; -- 5
        when 16#a35# => romdata <= X"3c"; -- 5
        when 16#b35# => romdata <= X"00"; -- 5
        when 16#c35# => romdata <= X"00"; -- 5
        when 16#036# => romdata <= X"00"; -- 6
        when 16#136# => romdata <= X"00"; -- 6
        when 16#236# => romdata <= X"1c"; -- 6
        when 16#336# => romdata <= X"20"; -- 6
        when 16#436# => romdata <= X"40"; -- 6
        when 16#536# => romdata <= X"40"; -- 6
        when 16#636# => romdata <= X"5c"; -- 6
        when 16#736# => romdata <= X"62"; -- 6
        when 16#836# => romdata <= X"42"; -- 6
        when 16#936# => romdata <= X"42"; -- 6
        when 16#a36# => romdata <= X"3c"; -- 6
        when 16#b36# => romdata <= X"00"; -- 6
        when 16#c36# => romdata <= X"00"; -- 6
        when 16#037# => romdata <= X"00"; -- 7
        when 16#137# => romdata <= X"00"; -- 7
        when 16#237# => romdata <= X"7e"; -- 7
        when 16#337# => romdata <= X"02"; -- 7
        when 16#437# => romdata <= X"04"; -- 7
        when 16#537# => romdata <= X"08"; -- 7
        when 16#637# => romdata <= X"08"; -- 7
        when 16#737# => romdata <= X"10"; -- 7
        when 16#837# => romdata <= X"10"; -- 7
        when 16#937# => romdata <= X"20"; -- 7
        when 16#a37# => romdata <= X"20"; -- 7
        when 16#b37# => romdata <= X"00"; -- 7
        when 16#c37# => romdata <= X"00"; -- 7
        when 16#038# => romdata <= X"00"; -- 8
        when 16#138# => romdata <= X"00"; -- 8
        when 16#238# => romdata <= X"3c"; -- 8
        when 16#338# => romdata <= X"42"; -- 8
        when 16#438# => romdata <= X"42"; -- 8
        when 16#538# => romdata <= X"42"; -- 8
        when 16#638# => romdata <= X"3c"; -- 8
        when 16#738# => romdata <= X"42"; -- 8
        when 16#838# => romdata <= X"42"; -- 8
        when 16#938# => romdata <= X"42"; -- 8
        when 16#a38# => romdata <= X"3c"; -- 8
        when 16#b38# => romdata <= X"00"; -- 8
        when 16#c38# => romdata <= X"00"; -- 8
        when 16#039# => romdata <= X"00"; -- 9
        when 16#139# => romdata <= X"00"; -- 9
        when 16#239# => romdata <= X"3c"; -- 9
        when 16#339# => romdata <= X"42"; -- 9
        when 16#439# => romdata <= X"42"; -- 9
        when 16#539# => romdata <= X"46"; -- 9
        when 16#639# => romdata <= X"3a"; -- 9
        when 16#739# => romdata <= X"02"; -- 9
        when 16#839# => romdata <= X"02"; -- 9
        when 16#939# => romdata <= X"04"; -- 9
        when 16#a39# => romdata <= X"38"; -- 9
        when 16#b39# => romdata <= X"00"; -- 9
        when 16#c39# => romdata <= X"00"; -- 9
        when 16#03a# => romdata <= X"00"; -- :
        when 16#13a# => romdata <= X"00"; -- :
        when 16#23a# => romdata <= X"00"; -- :
        when 16#33a# => romdata <= X"00"; -- :
        when 16#43a# => romdata <= X"10"; -- :
        when 16#53a# => romdata <= X"38"; -- :
        when 16#63a# => romdata <= X"10"; -- :
        when 16#73a# => romdata <= X"00"; -- :
        when 16#83a# => romdata <= X"00"; -- :
        when 16#93a# => romdata <= X"10"; -- :
        when 16#a3a# => romdata <= X"38"; -- :
        when 16#b3a# => romdata <= X"10"; -- :
        when 16#c3a# => romdata <= X"00"; -- :
        when 16#03b# => romdata <= X"00"; -- ;
        when 16#13b# => romdata <= X"00"; -- ;
        when 16#23b# => romdata <= X"00"; -- ;
        when 16#33b# => romdata <= X"00"; -- ;
        when 16#43b# => romdata <= X"10"; -- ;
        when 16#53b# => romdata <= X"38"; -- ;
        when 16#63b# => romdata <= X"10"; -- ;
        when 16#73b# => romdata <= X"00"; -- ;
        when 16#83b# => romdata <= X"00"; -- ;
        when 16#93b# => romdata <= X"38"; -- ;
        when 16#a3b# => romdata <= X"30"; -- ;
        when 16#b3b# => romdata <= X"40"; -- ;
        when 16#c3b# => romdata <= X"00"; -- ;
        when 16#03c# => romdata <= X"00"; -- <
        when 16#13c# => romdata <= X"00"; -- <
        when 16#23c# => romdata <= X"02"; -- <
        when 16#33c# => romdata <= X"04"; -- <
        when 16#43c# => romdata <= X"08"; -- <
        when 16#53c# => romdata <= X"10"; -- <
        when 16#63c# => romdata <= X"20"; -- <
        when 16#73c# => romdata <= X"10"; -- <
        when 16#83c# => romdata <= X"08"; -- <
        when 16#93c# => romdata <= X"04"; -- <
        when 16#a3c# => romdata <= X"02"; -- <
        when 16#b3c# => romdata <= X"00"; -- <
        when 16#c3c# => romdata <= X"00"; -- <
        when 16#03d# => romdata <= X"00"; -- =
        when 16#13d# => romdata <= X"00"; -- =
        when 16#23d# => romdata <= X"00"; -- =
        when 16#33d# => romdata <= X"00"; -- =
        when 16#43d# => romdata <= X"00"; -- =
        when 16#53d# => romdata <= X"7e"; -- =
        when 16#63d# => romdata <= X"00"; -- =
        when 16#73d# => romdata <= X"00"; -- =
        when 16#83d# => romdata <= X"7e"; -- =
        when 16#93d# => romdata <= X"00"; -- =
        when 16#a3d# => romdata <= X"00"; -- =
        when 16#b3d# => romdata <= X"00"; -- =
        when 16#c3d# => romdata <= X"00"; -- =
        when 16#03e# => romdata <= X"00"; -- >
        when 16#13e# => romdata <= X"00"; -- >
        when 16#23e# => romdata <= X"40"; -- >
        when 16#33e# => romdata <= X"20"; -- >
        when 16#43e# => romdata <= X"10"; -- >
        when 16#53e# => romdata <= X"08"; -- >
        when 16#63e# => romdata <= X"04"; -- >
        when 16#73e# => romdata <= X"08"; -- >
        when 16#83e# => romdata <= X"10"; -- >
        when 16#93e# => romdata <= X"20"; -- >
        when 16#a3e# => romdata <= X"40"; -- >
        when 16#b3e# => romdata <= X"00"; -- >
        when 16#c3e# => romdata <= X"00"; -- >
        when 16#03f# => romdata <= X"00"; -- ?
        when 16#13f# => romdata <= X"00"; -- ?
        when 16#23f# => romdata <= X"3c"; -- ?
        when 16#33f# => romdata <= X"42"; -- ?
        when 16#43f# => romdata <= X"42"; -- ?
        when 16#53f# => romdata <= X"02"; -- ?
        when 16#63f# => romdata <= X"04"; -- ?
        when 16#73f# => romdata <= X"08"; -- ?
        when 16#83f# => romdata <= X"08"; -- ?
        when 16#93f# => romdata <= X"00"; -- ?
        when 16#a3f# => romdata <= X"08"; -- ?
        when 16#b3f# => romdata <= X"00"; -- ?
        when 16#c3f# => romdata <= X"00"; -- ?
        when 16#040# => romdata <= X"00"; -- @
        when 16#140# => romdata <= X"00"; -- @
        when 16#240# => romdata <= X"3c"; -- @
        when 16#340# => romdata <= X"42"; -- @
        when 16#440# => romdata <= X"42"; -- @
        when 16#540# => romdata <= X"4e"; -- @
        when 16#640# => romdata <= X"52"; -- @
        when 16#740# => romdata <= X"56"; -- @
        when 16#840# => romdata <= X"4a"; -- @
        when 16#940# => romdata <= X"40"; -- @
        when 16#a40# => romdata <= X"3c"; -- @
        when 16#b40# => romdata <= X"00"; -- @
        when 16#c40# => romdata <= X"00"; -- @
        when 16#041# => romdata <= X"00"; -- A
        when 16#141# => romdata <= X"00"; -- A
        when 16#241# => romdata <= X"18"; -- A
        when 16#341# => romdata <= X"24"; -- A
        when 16#441# => romdata <= X"42"; -- A
        when 16#541# => romdata <= X"42"; -- A
        when 16#641# => romdata <= X"42"; -- A
        when 16#741# => romdata <= X"7e"; -- A
        when 16#841# => romdata <= X"42"; -- A
        when 16#941# => romdata <= X"42"; -- A
        when 16#a41# => romdata <= X"42"; -- A
        when 16#b41# => romdata <= X"00"; -- A
        when 16#c41# => romdata <= X"00"; -- A
        when 16#042# => romdata <= X"00"; -- B
        when 16#142# => romdata <= X"00"; -- B
        when 16#242# => romdata <= X"78"; -- B
        when 16#342# => romdata <= X"44"; -- B
        when 16#442# => romdata <= X"42"; -- B
        when 16#542# => romdata <= X"44"; -- B
        when 16#642# => romdata <= X"78"; -- B
        when 16#742# => romdata <= X"44"; -- B
        when 16#842# => romdata <= X"42"; -- B
        when 16#942# => romdata <= X"44"; -- B
        when 16#a42# => romdata <= X"78"; -- B
        when 16#b42# => romdata <= X"00"; -- B
        when 16#c42# => romdata <= X"00"; -- B
        when 16#043# => romdata <= X"00"; -- C
        when 16#143# => romdata <= X"00"; -- C
        when 16#243# => romdata <= X"3c"; -- C
        when 16#343# => romdata <= X"42"; -- C
        when 16#443# => romdata <= X"40"; -- C
        when 16#543# => romdata <= X"40"; -- C
        when 16#643# => romdata <= X"40"; -- C
        when 16#743# => romdata <= X"40"; -- C
        when 16#843# => romdata <= X"40"; -- C
        when 16#943# => romdata <= X"42"; -- C
        when 16#a43# => romdata <= X"3c"; -- C
        when 16#b43# => romdata <= X"00"; -- C
        when 16#c43# => romdata <= X"00"; -- C
        when 16#044# => romdata <= X"00"; -- D
        when 16#144# => romdata <= X"00"; -- D
        when 16#244# => romdata <= X"78"; -- D
        when 16#344# => romdata <= X"44"; -- D
        when 16#444# => romdata <= X"42"; -- D
        when 16#544# => romdata <= X"42"; -- D
        when 16#644# => romdata <= X"42"; -- D
        when 16#744# => romdata <= X"42"; -- D
        when 16#844# => romdata <= X"42"; -- D
        when 16#944# => romdata <= X"44"; -- D
        when 16#a44# => romdata <= X"78"; -- D
        when 16#b44# => romdata <= X"00"; -- D
        when 16#c44# => romdata <= X"00"; -- D
        when 16#045# => romdata <= X"00"; -- E
        when 16#145# => romdata <= X"00"; -- E
        when 16#245# => romdata <= X"7e"; -- E
        when 16#345# => romdata <= X"40"; -- E
        when 16#445# => romdata <= X"40"; -- E
        when 16#545# => romdata <= X"40"; -- E
        when 16#645# => romdata <= X"78"; -- E
        when 16#745# => romdata <= X"40"; -- E
        when 16#845# => romdata <= X"40"; -- E
        when 16#945# => romdata <= X"40"; -- E
        when 16#a45# => romdata <= X"7e"; -- E
        when 16#b45# => romdata <= X"00"; -- E
        when 16#c45# => romdata <= X"00"; -- E
        when 16#046# => romdata <= X"00"; -- F
        when 16#146# => romdata <= X"00"; -- F
        when 16#246# => romdata <= X"7e"; -- F
        when 16#346# => romdata <= X"40"; -- F
        when 16#446# => romdata <= X"40"; -- F
        when 16#546# => romdata <= X"40"; -- F
        when 16#646# => romdata <= X"78"; -- F
        when 16#746# => romdata <= X"40"; -- F
        when 16#846# => romdata <= X"40"; -- F
        when 16#946# => romdata <= X"40"; -- F
        when 16#a46# => romdata <= X"40"; -- F
        when 16#b46# => romdata <= X"00"; -- F
        when 16#c46# => romdata <= X"00"; -- F
        when 16#047# => romdata <= X"00"; -- G
        when 16#147# => romdata <= X"00"; -- G
        when 16#247# => romdata <= X"3c"; -- G
        when 16#347# => romdata <= X"42"; -- G
        when 16#447# => romdata <= X"40"; -- G
        when 16#547# => romdata <= X"40"; -- G
        when 16#647# => romdata <= X"40"; -- G
        when 16#747# => romdata <= X"4e"; -- G
        when 16#847# => romdata <= X"42"; -- G
        when 16#947# => romdata <= X"46"; -- G
        when 16#a47# => romdata <= X"3a"; -- G
        when 16#b47# => romdata <= X"00"; -- G
        when 16#c47# => romdata <= X"00"; -- G
        when 16#048# => romdata <= X"00"; -- H
        when 16#148# => romdata <= X"00"; -- H
        when 16#248# => romdata <= X"42"; -- H
        when 16#348# => romdata <= X"42"; -- H
        when 16#448# => romdata <= X"42"; -- H
        when 16#548# => romdata <= X"42"; -- H
        when 16#648# => romdata <= X"7e"; -- H
        when 16#748# => romdata <= X"42"; -- H
        when 16#848# => romdata <= X"42"; -- H
        when 16#948# => romdata <= X"42"; -- H
        when 16#a48# => romdata <= X"42"; -- H
        when 16#b48# => romdata <= X"00"; -- H
        when 16#c48# => romdata <= X"00"; -- H
        when 16#049# => romdata <= X"00"; -- I
        when 16#149# => romdata <= X"00"; -- I
        when 16#249# => romdata <= X"7c"; -- I
        when 16#349# => romdata <= X"10"; -- I
        when 16#449# => romdata <= X"10"; -- I
        when 16#549# => romdata <= X"10"; -- I
        when 16#649# => romdata <= X"10"; -- I
        when 16#749# => romdata <= X"10"; -- I
        when 16#849# => romdata <= X"10"; -- I
        when 16#949# => romdata <= X"10"; -- I
        when 16#a49# => romdata <= X"7c"; -- I
        when 16#b49# => romdata <= X"00"; -- I
        when 16#c49# => romdata <= X"00"; -- I
        when 16#04a# => romdata <= X"00"; -- J
        when 16#14a# => romdata <= X"00"; -- J
        when 16#24a# => romdata <= X"1f"; -- J
        when 16#34a# => romdata <= X"04"; -- J
        when 16#44a# => romdata <= X"04"; -- J
        when 16#54a# => romdata <= X"04"; -- J
        when 16#64a# => romdata <= X"04"; -- J
        when 16#74a# => romdata <= X"04"; -- J
        when 16#84a# => romdata <= X"04"; -- J
        when 16#94a# => romdata <= X"44"; -- J
        when 16#a4a# => romdata <= X"38"; -- J
        when 16#b4a# => romdata <= X"00"; -- J
        when 16#c4a# => romdata <= X"00"; -- J
        when 16#04b# => romdata <= X"00"; -- K
        when 16#14b# => romdata <= X"00"; -- K
        when 16#24b# => romdata <= X"42"; -- K
        when 16#34b# => romdata <= X"44"; -- K
        when 16#44b# => romdata <= X"48"; -- K
        when 16#54b# => romdata <= X"50"; -- K
        when 16#64b# => romdata <= X"60"; -- K
        when 16#74b# => romdata <= X"50"; -- K
        when 16#84b# => romdata <= X"48"; -- K
        when 16#94b# => romdata <= X"44"; -- K
        when 16#a4b# => romdata <= X"42"; -- K
        when 16#b4b# => romdata <= X"00"; -- K
        when 16#c4b# => romdata <= X"00"; -- K
        when 16#04c# => romdata <= X"00"; -- L
        when 16#14c# => romdata <= X"00"; -- L
        when 16#24c# => romdata <= X"40"; -- L
        when 16#34c# => romdata <= X"40"; -- L
        when 16#44c# => romdata <= X"40"; -- L
        when 16#54c# => romdata <= X"40"; -- L
        when 16#64c# => romdata <= X"40"; -- L
        when 16#74c# => romdata <= X"40"; -- L
        when 16#84c# => romdata <= X"40"; -- L
        when 16#94c# => romdata <= X"40"; -- L
        when 16#a4c# => romdata <= X"7e"; -- L
        when 16#b4c# => romdata <= X"00"; -- L
        when 16#c4c# => romdata <= X"00"; -- L
        when 16#04d# => romdata <= X"00"; -- M
        when 16#14d# => romdata <= X"00"; -- M
        when 16#24d# => romdata <= X"82"; -- M
        when 16#34d# => romdata <= X"82"; -- M
        when 16#44d# => romdata <= X"c6"; -- M
        when 16#54d# => romdata <= X"aa"; -- M
        when 16#64d# => romdata <= X"92"; -- M
        when 16#74d# => romdata <= X"92"; -- M
        when 16#84d# => romdata <= X"82"; -- M
        when 16#94d# => romdata <= X"82"; -- M
        when 16#a4d# => romdata <= X"82"; -- M
        when 16#b4d# => romdata <= X"00"; -- M
        when 16#c4d# => romdata <= X"00"; -- M
        when 16#04e# => romdata <= X"00"; -- N
        when 16#14e# => romdata <= X"00"; -- N
        when 16#24e# => romdata <= X"42"; -- N
        when 16#34e# => romdata <= X"42"; -- N
        when 16#44e# => romdata <= X"62"; -- N
        when 16#54e# => romdata <= X"52"; -- N
        when 16#64e# => romdata <= X"4a"; -- N
        when 16#74e# => romdata <= X"46"; -- N
        when 16#84e# => romdata <= X"42"; -- N
        when 16#94e# => romdata <= X"42"; -- N
        when 16#a4e# => romdata <= X"42"; -- N
        when 16#b4e# => romdata <= X"00"; -- N
        when 16#c4e# => romdata <= X"00"; -- N
        when 16#04f# => romdata <= X"00"; -- O
        when 16#14f# => romdata <= X"00"; -- O
        when 16#24f# => romdata <= X"3c"; -- O
        when 16#34f# => romdata <= X"42"; -- O
        when 16#44f# => romdata <= X"42"; -- O
        when 16#54f# => romdata <= X"42"; -- O
        when 16#64f# => romdata <= X"42"; -- O
        when 16#74f# => romdata <= X"42"; -- O
        when 16#84f# => romdata <= X"42"; -- O
        when 16#94f# => romdata <= X"42"; -- O
        when 16#a4f# => romdata <= X"3c"; -- O
        when 16#b4f# => romdata <= X"00"; -- O
        when 16#c4f# => romdata <= X"00"; -- O
        when 16#050# => romdata <= X"00"; -- P
        when 16#150# => romdata <= X"00"; -- P
        when 16#250# => romdata <= X"7c"; -- P
        when 16#350# => romdata <= X"42"; -- P
        when 16#450# => romdata <= X"42"; -- P
        when 16#550# => romdata <= X"42"; -- P
        when 16#650# => romdata <= X"7c"; -- P
        when 16#750# => romdata <= X"40"; -- P
        when 16#850# => romdata <= X"40"; -- P
        when 16#950# => romdata <= X"40"; -- P
        when 16#a50# => romdata <= X"40"; -- P
        when 16#b50# => romdata <= X"00"; -- P
        when 16#c50# => romdata <= X"00"; -- P
        when 16#051# => romdata <= X"00"; -- Q
        when 16#151# => romdata <= X"00"; -- Q
        when 16#251# => romdata <= X"3c"; -- Q
        when 16#351# => romdata <= X"42"; -- Q
        when 16#451# => romdata <= X"42"; -- Q
        when 16#551# => romdata <= X"42"; -- Q
        when 16#651# => romdata <= X"42"; -- Q
        when 16#751# => romdata <= X"42"; -- Q
        when 16#851# => romdata <= X"52"; -- Q
        when 16#951# => romdata <= X"4a"; -- Q
        when 16#a51# => romdata <= X"3c"; -- Q
        when 16#b51# => romdata <= X"02"; -- Q
        when 16#c51# => romdata <= X"00"; -- Q
        when 16#052# => romdata <= X"00"; -- R
        when 16#152# => romdata <= X"00"; -- R
        when 16#252# => romdata <= X"7c"; -- R
        when 16#352# => romdata <= X"42"; -- R
        when 16#452# => romdata <= X"42"; -- R
        when 16#552# => romdata <= X"42"; -- R
        when 16#652# => romdata <= X"7c"; -- R
        when 16#752# => romdata <= X"50"; -- R
        when 16#852# => romdata <= X"48"; -- R
        when 16#952# => romdata <= X"44"; -- R
        when 16#a52# => romdata <= X"42"; -- R
        when 16#b52# => romdata <= X"00"; -- R
        when 16#c52# => romdata <= X"00"; -- R
        when 16#053# => romdata <= X"00"; -- S
        when 16#153# => romdata <= X"00"; -- S
        when 16#253# => romdata <= X"3c"; -- S
        when 16#353# => romdata <= X"42"; -- S
        when 16#453# => romdata <= X"40"; -- S
        when 16#553# => romdata <= X"40"; -- S
        when 16#653# => romdata <= X"3c"; -- S
        when 16#753# => romdata <= X"02"; -- S
        when 16#853# => romdata <= X"02"; -- S
        when 16#953# => romdata <= X"42"; -- S
        when 16#a53# => romdata <= X"3c"; -- S
        when 16#b53# => romdata <= X"00"; -- S
        when 16#c53# => romdata <= X"00"; -- S
        when 16#054# => romdata <= X"00"; -- T
        when 16#154# => romdata <= X"00"; -- T
        when 16#254# => romdata <= X"fe"; -- T
        when 16#354# => romdata <= X"10"; -- T
        when 16#454# => romdata <= X"10"; -- T
        when 16#554# => romdata <= X"10"; -- T
        when 16#654# => romdata <= X"10"; -- T
        when 16#754# => romdata <= X"10"; -- T
        when 16#854# => romdata <= X"10"; -- T
        when 16#954# => romdata <= X"10"; -- T
        when 16#a54# => romdata <= X"10"; -- T
        when 16#b54# => romdata <= X"00"; -- T
        when 16#c54# => romdata <= X"00"; -- T
        when 16#055# => romdata <= X"00"; -- U
        when 16#155# => romdata <= X"00"; -- U
        when 16#255# => romdata <= X"42"; -- U
        when 16#355# => romdata <= X"42"; -- U
        when 16#455# => romdata <= X"42"; -- U
        when 16#555# => romdata <= X"42"; -- U
        when 16#655# => romdata <= X"42"; -- U
        when 16#755# => romdata <= X"42"; -- U
        when 16#855# => romdata <= X"42"; -- U
        when 16#955# => romdata <= X"42"; -- U
        when 16#a55# => romdata <= X"3c"; -- U
        when 16#b55# => romdata <= X"00"; -- U
        when 16#c55# => romdata <= X"00"; -- U
        when 16#056# => romdata <= X"00"; -- V
        when 16#156# => romdata <= X"00"; -- V
        when 16#256# => romdata <= X"82"; -- V
        when 16#356# => romdata <= X"82"; -- V
        when 16#456# => romdata <= X"44"; -- V
        when 16#556# => romdata <= X"44"; -- V
        when 16#656# => romdata <= X"44"; -- V
        when 16#756# => romdata <= X"28"; -- V
        when 16#856# => romdata <= X"28"; -- V
        when 16#956# => romdata <= X"28"; -- V
        when 16#a56# => romdata <= X"10"; -- V
        when 16#b56# => romdata <= X"00"; -- V
        when 16#c56# => romdata <= X"00"; -- V
        when 16#057# => romdata <= X"00"; -- W
        when 16#157# => romdata <= X"00"; -- W
        when 16#257# => romdata <= X"82"; -- W
        when 16#357# => romdata <= X"82"; -- W
        when 16#457# => romdata <= X"82"; -- W
        when 16#557# => romdata <= X"82"; -- W
        when 16#657# => romdata <= X"92"; -- W
        when 16#757# => romdata <= X"92"; -- W
        when 16#857# => romdata <= X"92"; -- W
        when 16#957# => romdata <= X"aa"; -- W
        when 16#a57# => romdata <= X"44"; -- W
        when 16#b57# => romdata <= X"00"; -- W
        when 16#c57# => romdata <= X"00"; -- W
        when 16#058# => romdata <= X"00"; -- X
        when 16#158# => romdata <= X"00"; -- X
        when 16#258# => romdata <= X"82"; -- X
        when 16#358# => romdata <= X"82"; -- X
        when 16#458# => romdata <= X"44"; -- X
        when 16#558# => romdata <= X"28"; -- X
        when 16#658# => romdata <= X"10"; -- X
        when 16#758# => romdata <= X"28"; -- X
        when 16#858# => romdata <= X"44"; -- X
        when 16#958# => romdata <= X"82"; -- X
        when 16#a58# => romdata <= X"82"; -- X
        when 16#b58# => romdata <= X"00"; -- X
        when 16#c58# => romdata <= X"00"; -- X
        when 16#059# => romdata <= X"00"; -- Y
        when 16#159# => romdata <= X"00"; -- Y
        when 16#259# => romdata <= X"82"; -- Y
        when 16#359# => romdata <= X"82"; -- Y
        when 16#459# => romdata <= X"44"; -- Y
        when 16#559# => romdata <= X"28"; -- Y
        when 16#659# => romdata <= X"10"; -- Y
        when 16#759# => romdata <= X"10"; -- Y
        when 16#859# => romdata <= X"10"; -- Y
        when 16#959# => romdata <= X"10"; -- Y
        when 16#a59# => romdata <= X"10"; -- Y
        when 16#b59# => romdata <= X"00"; -- Y
        when 16#c59# => romdata <= X"00"; -- Y
        when 16#05a# => romdata <= X"00"; -- Z
        when 16#15a# => romdata <= X"00"; -- Z
        when 16#25a# => romdata <= X"7e"; -- Z
        when 16#35a# => romdata <= X"02"; -- Z
        when 16#45a# => romdata <= X"04"; -- Z
        when 16#55a# => romdata <= X"08"; -- Z
        when 16#65a# => romdata <= X"10"; -- Z
        when 16#75a# => romdata <= X"20"; -- Z
        when 16#85a# => romdata <= X"40"; -- Z
        when 16#95a# => romdata <= X"40"; -- Z
        when 16#a5a# => romdata <= X"7e"; -- Z
        when 16#b5a# => romdata <= X"00"; -- Z
        when 16#c5a# => romdata <= X"00"; -- Z
        when 16#05b# => romdata <= X"00"; -- [
        when 16#15b# => romdata <= X"00"; -- [
        when 16#25b# => romdata <= X"3c"; -- [
        when 16#35b# => romdata <= X"20"; -- [
        when 16#45b# => romdata <= X"20"; -- [
        when 16#55b# => romdata <= X"20"; -- [
        when 16#65b# => romdata <= X"20"; -- [
        when 16#75b# => romdata <= X"20"; -- [
        when 16#85b# => romdata <= X"20"; -- [
        when 16#95b# => romdata <= X"20"; -- [
        when 16#a5b# => romdata <= X"3c"; -- [
        when 16#b5b# => romdata <= X"00"; -- [
        when 16#c5b# => romdata <= X"00"; -- [
        when 16#05c# => romdata <= X"00"; -- \
        when 16#15c# => romdata <= X"00"; -- \
        when 16#25c# => romdata <= X"80"; -- \
        when 16#35c# => romdata <= X"80"; -- \
        when 16#45c# => romdata <= X"40"; -- \
        when 16#55c# => romdata <= X"20"; -- \
        when 16#65c# => romdata <= X"10"; -- \
        when 16#75c# => romdata <= X"08"; -- \
        when 16#85c# => romdata <= X"04"; -- \
        when 16#95c# => romdata <= X"02"; -- \
        when 16#a5c# => romdata <= X"02"; -- \
        when 16#b5c# => romdata <= X"00"; -- \
        when 16#c5c# => romdata <= X"00"; -- \
        when 16#05d# => romdata <= X"00"; -- ]
        when 16#15d# => romdata <= X"00"; -- ]
        when 16#25d# => romdata <= X"78"; -- ]
        when 16#35d# => romdata <= X"08"; -- ]
        when 16#45d# => romdata <= X"08"; -- ]
        when 16#55d# => romdata <= X"08"; -- ]
        when 16#65d# => romdata <= X"08"; -- ]
        when 16#75d# => romdata <= X"08"; -- ]
        when 16#85d# => romdata <= X"08"; -- ]
        when 16#95d# => romdata <= X"08"; -- ]
        when 16#a5d# => romdata <= X"78"; -- ]
        when 16#b5d# => romdata <= X"00"; -- ]
        when 16#c5d# => romdata <= X"00"; -- ]
        when 16#05e# => romdata <= X"00"; -- ^
        when 16#15e# => romdata <= X"00"; -- ^
        when 16#25e# => romdata <= X"10"; -- ^
        when 16#35e# => romdata <= X"28"; -- ^
        when 16#45e# => romdata <= X"44"; -- ^
        when 16#55e# => romdata <= X"00"; -- ^
        when 16#65e# => romdata <= X"00"; -- ^
        when 16#75e# => romdata <= X"00"; -- ^
        when 16#85e# => romdata <= X"00"; -- ^
        when 16#95e# => romdata <= X"00"; -- ^
        when 16#a5e# => romdata <= X"00"; -- ^
        when 16#b5e# => romdata <= X"00"; -- ^
        when 16#c5e# => romdata <= X"00"; -- ^
        when 16#05f# => romdata <= X"00"; -- _
        when 16#15f# => romdata <= X"00"; -- _
        when 16#25f# => romdata <= X"00"; -- _
        when 16#35f# => romdata <= X"00"; -- _
        when 16#45f# => romdata <= X"00"; -- _
        when 16#55f# => romdata <= X"00"; -- _
        when 16#65f# => romdata <= X"00"; -- _
        when 16#75f# => romdata <= X"00"; -- _
        when 16#85f# => romdata <= X"00"; -- _
        when 16#95f# => romdata <= X"00"; -- _
        when 16#a5f# => romdata <= X"00"; -- _
        when 16#b5f# => romdata <= X"fe"; -- _
        when 16#c5f# => romdata <= X"00"; -- _
        when 16#060# => romdata <= X"00"; -- `
        when 16#160# => romdata <= X"10"; -- `
        when 16#260# => romdata <= X"08"; -- `
        when 16#360# => romdata <= X"00"; -- `
        when 16#460# => romdata <= X"00"; -- `
        when 16#560# => romdata <= X"00"; -- `
        when 16#660# => romdata <= X"00"; -- `
        when 16#760# => romdata <= X"00"; -- `
        when 16#860# => romdata <= X"00"; -- `
        when 16#960# => romdata <= X"00"; -- `
        when 16#a60# => romdata <= X"00"; -- `
        when 16#b60# => romdata <= X"00"; -- `
        when 16#c60# => romdata <= X"00"; -- `
        when 16#061# => romdata <= X"00"; -- a
        when 16#161# => romdata <= X"00"; -- a
        when 16#261# => romdata <= X"00"; -- a
        when 16#361# => romdata <= X"00"; -- a
        when 16#461# => romdata <= X"00"; -- a
        when 16#561# => romdata <= X"3c"; -- a
        when 16#661# => romdata <= X"02"; -- a
        when 16#761# => romdata <= X"3e"; -- a
        when 16#861# => romdata <= X"42"; -- a
        when 16#961# => romdata <= X"46"; -- a
        when 16#a61# => romdata <= X"3a"; -- a
        when 16#b61# => romdata <= X"00"; -- a
        when 16#c61# => romdata <= X"00"; -- a
        when 16#062# => romdata <= X"00"; -- b
        when 16#162# => romdata <= X"00"; -- b
        when 16#262# => romdata <= X"40"; -- b
        when 16#362# => romdata <= X"40"; -- b
        when 16#462# => romdata <= X"40"; -- b
        when 16#562# => romdata <= X"5c"; -- b
        when 16#662# => romdata <= X"62"; -- b
        when 16#762# => romdata <= X"42"; -- b
        when 16#862# => romdata <= X"42"; -- b
        when 16#962# => romdata <= X"62"; -- b
        when 16#a62# => romdata <= X"5c"; -- b
        when 16#b62# => romdata <= X"00"; -- b
        when 16#c62# => romdata <= X"00"; -- b
        when 16#063# => romdata <= X"00"; -- c
        when 16#163# => romdata <= X"00"; -- c
        when 16#263# => romdata <= X"00"; -- c
        when 16#363# => romdata <= X"00"; -- c
        when 16#463# => romdata <= X"00"; -- c
        when 16#563# => romdata <= X"3c"; -- c
        when 16#663# => romdata <= X"42"; -- c
        when 16#763# => romdata <= X"40"; -- c
        when 16#863# => romdata <= X"40"; -- c
        when 16#963# => romdata <= X"42"; -- c
        when 16#a63# => romdata <= X"3c"; -- c
        when 16#b63# => romdata <= X"00"; -- c
        when 16#c63# => romdata <= X"00"; -- c
        when 16#064# => romdata <= X"00"; -- d
        when 16#164# => romdata <= X"00"; -- d
        when 16#264# => romdata <= X"02"; -- d
        when 16#364# => romdata <= X"02"; -- d
        when 16#464# => romdata <= X"02"; -- d
        when 16#564# => romdata <= X"3a"; -- d
        when 16#664# => romdata <= X"46"; -- d
        when 16#764# => romdata <= X"42"; -- d
        when 16#864# => romdata <= X"42"; -- d
        when 16#964# => romdata <= X"46"; -- d
        when 16#a64# => romdata <= X"3a"; -- d
        when 16#b64# => romdata <= X"00"; -- d
        when 16#c64# => romdata <= X"00"; -- d
        when 16#065# => romdata <= X"00"; -- e
        when 16#165# => romdata <= X"00"; -- e
        when 16#265# => romdata <= X"00"; -- e
        when 16#365# => romdata <= X"00"; -- e
        when 16#465# => romdata <= X"00"; -- e
        when 16#565# => romdata <= X"3c"; -- e
        when 16#665# => romdata <= X"42"; -- e
        when 16#765# => romdata <= X"7e"; -- e
        when 16#865# => romdata <= X"40"; -- e
        when 16#965# => romdata <= X"42"; -- e
        when 16#a65# => romdata <= X"3c"; -- e
        when 16#b65# => romdata <= X"00"; -- e
        when 16#c65# => romdata <= X"00"; -- e
        when 16#066# => romdata <= X"00"; -- f
        when 16#166# => romdata <= X"00"; -- f
        when 16#266# => romdata <= X"1c"; -- f
        when 16#366# => romdata <= X"22"; -- f
        when 16#466# => romdata <= X"20"; -- f
        when 16#566# => romdata <= X"20"; -- f
        when 16#666# => romdata <= X"7c"; -- f
        when 16#766# => romdata <= X"20"; -- f
        when 16#866# => romdata <= X"20"; -- f
        when 16#966# => romdata <= X"20"; -- f
        when 16#a66# => romdata <= X"20"; -- f
        when 16#b66# => romdata <= X"00"; -- f
        when 16#c66# => romdata <= X"00"; -- f
        when 16#067# => romdata <= X"00"; -- g
        when 16#167# => romdata <= X"00"; -- g
        when 16#267# => romdata <= X"00"; -- g
        when 16#367# => romdata <= X"00"; -- g
        when 16#467# => romdata <= X"00"; -- g
        when 16#567# => romdata <= X"3a"; -- g
        when 16#667# => romdata <= X"44"; -- g
        when 16#767# => romdata <= X"44"; -- g
        when 16#867# => romdata <= X"38"; -- g
        when 16#967# => romdata <= X"40"; -- g
        when 16#a67# => romdata <= X"3c"; -- g
        when 16#b67# => romdata <= X"42"; -- g
        when 16#c67# => romdata <= X"3c"; -- g
        when 16#068# => romdata <= X"00"; -- h
        when 16#168# => romdata <= X"00"; -- h
        when 16#268# => romdata <= X"40"; -- h
        when 16#368# => romdata <= X"40"; -- h
        when 16#468# => romdata <= X"40"; -- h
        when 16#568# => romdata <= X"5c"; -- h
        when 16#668# => romdata <= X"62"; -- h
        when 16#768# => romdata <= X"42"; -- h
        when 16#868# => romdata <= X"42"; -- h
        when 16#968# => romdata <= X"42"; -- h
        when 16#a68# => romdata <= X"42"; -- h
        when 16#b68# => romdata <= X"00"; -- h
        when 16#c68# => romdata <= X"00"; -- h
        when 16#069# => romdata <= X"00"; -- i
        when 16#169# => romdata <= X"00"; -- i
        when 16#269# => romdata <= X"00"; -- i
        when 16#369# => romdata <= X"10"; -- i
        when 16#469# => romdata <= X"00"; -- i
        when 16#569# => romdata <= X"30"; -- i
        when 16#669# => romdata <= X"10"; -- i
        when 16#769# => romdata <= X"10"; -- i
        when 16#869# => romdata <= X"10"; -- i
        when 16#969# => romdata <= X"10"; -- i
        when 16#a69# => romdata <= X"7c"; -- i
        when 16#b69# => romdata <= X"00"; -- i
        when 16#c69# => romdata <= X"00"; -- i
        when 16#06a# => romdata <= X"00"; -- j
        when 16#16a# => romdata <= X"00"; -- j
        when 16#26a# => romdata <= X"00"; -- j
        when 16#36a# => romdata <= X"04"; -- j
        when 16#46a# => romdata <= X"00"; -- j
        when 16#56a# => romdata <= X"0c"; -- j
        when 16#66a# => romdata <= X"04"; -- j
        when 16#76a# => romdata <= X"04"; -- j
        when 16#86a# => romdata <= X"04"; -- j
        when 16#96a# => romdata <= X"04"; -- j
        when 16#a6a# => romdata <= X"44"; -- j
        when 16#b6a# => romdata <= X"44"; -- j
        when 16#c6a# => romdata <= X"38"; -- j
        when 16#06b# => romdata <= X"00"; -- k
        when 16#16b# => romdata <= X"00"; -- k
        when 16#26b# => romdata <= X"40"; -- k
        when 16#36b# => romdata <= X"40"; -- k
        when 16#46b# => romdata <= X"40"; -- k
        when 16#56b# => romdata <= X"44"; -- k
        when 16#66b# => romdata <= X"48"; -- k
        when 16#76b# => romdata <= X"70"; -- k
        when 16#86b# => romdata <= X"48"; -- k
        when 16#96b# => romdata <= X"44"; -- k
        when 16#a6b# => romdata <= X"42"; -- k
        when 16#b6b# => romdata <= X"00"; -- k
        when 16#c6b# => romdata <= X"00"; -- k
        when 16#06c# => romdata <= X"00"; -- l
        when 16#16c# => romdata <= X"00"; -- l
        when 16#26c# => romdata <= X"30"; -- l
        when 16#36c# => romdata <= X"10"; -- l
        when 16#46c# => romdata <= X"10"; -- l
        when 16#56c# => romdata <= X"10"; -- l
        when 16#66c# => romdata <= X"10"; -- l
        when 16#76c# => romdata <= X"10"; -- l
        when 16#86c# => romdata <= X"10"; -- l
        when 16#96c# => romdata <= X"10"; -- l
        when 16#a6c# => romdata <= X"7c"; -- l
        when 16#b6c# => romdata <= X"00"; -- l
        when 16#c6c# => romdata <= X"00"; -- l
        when 16#06d# => romdata <= X"00"; -- m
        when 16#16d# => romdata <= X"00"; -- m
        when 16#26d# => romdata <= X"00"; -- m
        when 16#36d# => romdata <= X"00"; -- m
        when 16#46d# => romdata <= X"00"; -- m
        when 16#56d# => romdata <= X"ec"; -- m
        when 16#66d# => romdata <= X"92"; -- m
        when 16#76d# => romdata <= X"92"; -- m
        when 16#86d# => romdata <= X"92"; -- m
        when 16#96d# => romdata <= X"92"; -- m
        when 16#a6d# => romdata <= X"82"; -- m
        when 16#b6d# => romdata <= X"00"; -- m
        when 16#c6d# => romdata <= X"00"; -- m
        when 16#06e# => romdata <= X"00"; -- n
        when 16#16e# => romdata <= X"00"; -- n
        when 16#26e# => romdata <= X"00"; -- n
        when 16#36e# => romdata <= X"00"; -- n
        when 16#46e# => romdata <= X"00"; -- n
        when 16#56e# => romdata <= X"5c"; -- n
        when 16#66e# => romdata <= X"62"; -- n
        when 16#76e# => romdata <= X"42"; -- n
        when 16#86e# => romdata <= X"42"; -- n
        when 16#96e# => romdata <= X"42"; -- n
        when 16#a6e# => romdata <= X"42"; -- n
        when 16#b6e# => romdata <= X"00"; -- n
        when 16#c6e# => romdata <= X"00"; -- n
        when 16#06f# => romdata <= X"00"; -- o
        when 16#16f# => romdata <= X"00"; -- o
        when 16#26f# => romdata <= X"00"; -- o
        when 16#36f# => romdata <= X"00"; -- o
        when 16#46f# => romdata <= X"00"; -- o
        when 16#56f# => romdata <= X"3c"; -- o
        when 16#66f# => romdata <= X"42"; -- o
        when 16#76f# => romdata <= X"42"; -- o
        when 16#86f# => romdata <= X"42"; -- o
        when 16#96f# => romdata <= X"42"; -- o
        when 16#a6f# => romdata <= X"3c"; -- o
        when 16#b6f# => romdata <= X"00"; -- o
        when 16#c6f# => romdata <= X"00"; -- o
        when 16#070# => romdata <= X"00"; -- p
        when 16#170# => romdata <= X"00"; -- p
        when 16#270# => romdata <= X"00"; -- p
        when 16#370# => romdata <= X"00"; -- p
        when 16#470# => romdata <= X"00"; -- p
        when 16#570# => romdata <= X"5c"; -- p
        when 16#670# => romdata <= X"62"; -- p
        when 16#770# => romdata <= X"42"; -- p
        when 16#870# => romdata <= X"62"; -- p
        when 16#970# => romdata <= X"5c"; -- p
        when 16#a70# => romdata <= X"40"; -- p
        when 16#b70# => romdata <= X"40"; -- p
        when 16#c70# => romdata <= X"40"; -- p
        when 16#071# => romdata <= X"00"; -- q
        when 16#171# => romdata <= X"00"; -- q
        when 16#271# => romdata <= X"00"; -- q
        when 16#371# => romdata <= X"00"; -- q
        when 16#471# => romdata <= X"00"; -- q
        when 16#571# => romdata <= X"3a"; -- q
        when 16#671# => romdata <= X"46"; -- q
        when 16#771# => romdata <= X"42"; -- q
        when 16#871# => romdata <= X"46"; -- q
        when 16#971# => romdata <= X"3a"; -- q
        when 16#a71# => romdata <= X"02"; -- q
        when 16#b71# => romdata <= X"02"; -- q
        when 16#c71# => romdata <= X"02"; -- q
        when 16#072# => romdata <= X"00"; -- r
        when 16#172# => romdata <= X"00"; -- r
        when 16#272# => romdata <= X"00"; -- r
        when 16#372# => romdata <= X"00"; -- r
        when 16#472# => romdata <= X"00"; -- r
        when 16#572# => romdata <= X"5c"; -- r
        when 16#672# => romdata <= X"22"; -- r
        when 16#772# => romdata <= X"20"; -- r
        when 16#872# => romdata <= X"20"; -- r
        when 16#972# => romdata <= X"20"; -- r
        when 16#a72# => romdata <= X"20"; -- r
        when 16#b72# => romdata <= X"00"; -- r
        when 16#c72# => romdata <= X"00"; -- r
        when 16#073# => romdata <= X"00"; -- s
        when 16#173# => romdata <= X"00"; -- s
        when 16#273# => romdata <= X"00"; -- s
        when 16#373# => romdata <= X"00"; -- s
        when 16#473# => romdata <= X"00"; -- s
        when 16#573# => romdata <= X"3c"; -- s
        when 16#673# => romdata <= X"42"; -- s
        when 16#773# => romdata <= X"30"; -- s
        when 16#873# => romdata <= X"0c"; -- s
        when 16#973# => romdata <= X"42"; -- s
        when 16#a73# => romdata <= X"3c"; -- s
        when 16#b73# => romdata <= X"00"; -- s
        when 16#c73# => romdata <= X"00"; -- s
        when 16#074# => romdata <= X"00"; -- t
        when 16#174# => romdata <= X"00"; -- t
        when 16#274# => romdata <= X"00"; -- t
        when 16#374# => romdata <= X"20"; -- t
        when 16#474# => romdata <= X"20"; -- t
        when 16#574# => romdata <= X"7c"; -- t
        when 16#674# => romdata <= X"20"; -- t
        when 16#774# => romdata <= X"20"; -- t
        when 16#874# => romdata <= X"20"; -- t
        when 16#974# => romdata <= X"22"; -- t
        when 16#a74# => romdata <= X"1c"; -- t
        when 16#b74# => romdata <= X"00"; -- t
        when 16#c74# => romdata <= X"00"; -- t
        when 16#075# => romdata <= X"00"; -- u
        when 16#175# => romdata <= X"00"; -- u
        when 16#275# => romdata <= X"00"; -- u
        when 16#375# => romdata <= X"00"; -- u
        when 16#475# => romdata <= X"00"; -- u
        when 16#575# => romdata <= X"44"; -- u
        when 16#675# => romdata <= X"44"; -- u
        when 16#775# => romdata <= X"44"; -- u
        when 16#875# => romdata <= X"44"; -- u
        when 16#975# => romdata <= X"44"; -- u
        when 16#a75# => romdata <= X"3a"; -- u
        when 16#b75# => romdata <= X"00"; -- u
        when 16#c75# => romdata <= X"00"; -- u
        when 16#076# => romdata <= X"00"; -- v
        when 16#176# => romdata <= X"00"; -- v
        when 16#276# => romdata <= X"00"; -- v
        when 16#376# => romdata <= X"00"; -- v
        when 16#476# => romdata <= X"00"; -- v
        when 16#576# => romdata <= X"44"; -- v
        when 16#676# => romdata <= X"44"; -- v
        when 16#776# => romdata <= X"44"; -- v
        when 16#876# => romdata <= X"28"; -- v
        when 16#976# => romdata <= X"28"; -- v
        when 16#a76# => romdata <= X"10"; -- v
        when 16#b76# => romdata <= X"00"; -- v
        when 16#c76# => romdata <= X"00"; -- v
        when 16#077# => romdata <= X"00"; -- w
        when 16#177# => romdata <= X"00"; -- w
        when 16#277# => romdata <= X"00"; -- w
        when 16#377# => romdata <= X"00"; -- w
        when 16#477# => romdata <= X"00"; -- w
        when 16#577# => romdata <= X"82"; -- w
        when 16#677# => romdata <= X"82"; -- w
        when 16#777# => romdata <= X"92"; -- w
        when 16#877# => romdata <= X"92"; -- w
        when 16#977# => romdata <= X"aa"; -- w
        when 16#a77# => romdata <= X"44"; -- w
        when 16#b77# => romdata <= X"00"; -- w
        when 16#c77# => romdata <= X"00"; -- w
        when 16#078# => romdata <= X"00"; -- x
        when 16#178# => romdata <= X"00"; -- x
        when 16#278# => romdata <= X"00"; -- x
        when 16#378# => romdata <= X"00"; -- x
        when 16#478# => romdata <= X"00"; -- x
        when 16#578# => romdata <= X"42"; -- x
        when 16#678# => romdata <= X"24"; -- x
        when 16#778# => romdata <= X"18"; -- x
        when 16#878# => romdata <= X"18"; -- x
        when 16#978# => romdata <= X"24"; -- x
        when 16#a78# => romdata <= X"42"; -- x
        when 16#b78# => romdata <= X"00"; -- x
        when 16#c78# => romdata <= X"00"; -- x
        when 16#079# => romdata <= X"00"; -- y
        when 16#179# => romdata <= X"00"; -- y
        when 16#279# => romdata <= X"00"; -- y
        when 16#379# => romdata <= X"00"; -- y
        when 16#479# => romdata <= X"00"; -- y
        when 16#579# => romdata <= X"42"; -- y
        when 16#679# => romdata <= X"42"; -- y
        when 16#779# => romdata <= X"42"; -- y
        when 16#879# => romdata <= X"46"; -- y
        when 16#979# => romdata <= X"3a"; -- y
        when 16#a79# => romdata <= X"02"; -- y
        when 16#b79# => romdata <= X"42"; -- y
        when 16#c79# => romdata <= X"3c"; -- y
        when 16#07a# => romdata <= X"00"; -- z
        when 16#17a# => romdata <= X"00"; -- z
        when 16#27a# => romdata <= X"00"; -- z
        when 16#37a# => romdata <= X"00"; -- z
        when 16#47a# => romdata <= X"00"; -- z
        when 16#57a# => romdata <= X"7e"; -- z
        when 16#67a# => romdata <= X"04"; -- z
        when 16#77a# => romdata <= X"08"; -- z
        when 16#87a# => romdata <= X"10"; -- z
        when 16#97a# => romdata <= X"20"; -- z
        when 16#a7a# => romdata <= X"7e"; -- z
        when 16#b7a# => romdata <= X"00"; -- z
        when 16#c7a# => romdata <= X"00"; -- z
        when 16#07b# => romdata <= X"00"; -- {
        when 16#17b# => romdata <= X"00"; -- {
        when 16#27b# => romdata <= X"0e"; -- {
        when 16#37b# => romdata <= X"10"; -- {
        when 16#47b# => romdata <= X"10"; -- {
        when 16#57b# => romdata <= X"08"; -- {
        when 16#67b# => romdata <= X"30"; -- {
        when 16#77b# => romdata <= X"08"; -- {
        when 16#87b# => romdata <= X"10"; -- {
        when 16#97b# => romdata <= X"10"; -- {
        when 16#a7b# => romdata <= X"0e"; -- {
        when 16#b7b# => romdata <= X"00"; -- {
        when 16#c7b# => romdata <= X"00"; -- {
        when 16#07c# => romdata <= X"00"; -- |
        when 16#17c# => romdata <= X"00"; -- |
        when 16#27c# => romdata <= X"10"; -- |
        when 16#37c# => romdata <= X"10"; -- |
        when 16#47c# => romdata <= X"10"; -- |
        when 16#57c# => romdata <= X"10"; -- |
        when 16#67c# => romdata <= X"10"; -- |
        when 16#77c# => romdata <= X"10"; -- |
        when 16#87c# => romdata <= X"10"; -- |
        when 16#97c# => romdata <= X"10"; -- |
        when 16#a7c# => romdata <= X"10"; -- |
        when 16#b7c# => romdata <= X"00"; -- |
        when 16#c7c# => romdata <= X"00"; -- |
        when 16#07d# => romdata <= X"00"; -- }
        when 16#17d# => romdata <= X"00"; -- }
        when 16#27d# => romdata <= X"70"; -- }
        when 16#37d# => romdata <= X"08"; -- }
        when 16#47d# => romdata <= X"08"; -- }
        when 16#57d# => romdata <= X"10"; -- }
        when 16#67d# => romdata <= X"0c"; -- }
        when 16#77d# => romdata <= X"10"; -- }
        when 16#87d# => romdata <= X"08"; -- }
        when 16#97d# => romdata <= X"08"; -- }
        when 16#a7d# => romdata <= X"70"; -- }
        when 16#b7d# => romdata <= X"00"; -- }
        when 16#c7d# => romdata <= X"00"; -- }
        when 16#07e# => romdata <= X"00"; -- ~
        when 16#17e# => romdata <= X"00"; -- ~
        when 16#27e# => romdata <= X"24"; -- ~
        when 16#37e# => romdata <= X"54"; -- ~
        when 16#47e# => romdata <= X"48"; -- ~
        when 16#57e# => romdata <= X"00"; -- ~
        when 16#67e# => romdata <= X"00"; -- ~
        when 16#77e# => romdata <= X"00"; -- ~
        when 16#87e# => romdata <= X"00"; -- ~
        when 16#97e# => romdata <= X"00"; -- ~
        when 16#a7e# => romdata <= X"00"; -- ~
        when 16#b7e# => romdata <= X"00"; -- ~
        when 16#c7e# => romdata <= X"00"; -- ~
        when 16#0a0# => romdata <= X"00"; --  
        when 16#1a0# => romdata <= X"00"; --  
        when 16#2a0# => romdata <= X"00"; --  
        when 16#3a0# => romdata <= X"00"; --  
        when 16#4a0# => romdata <= X"00"; --  
        when 16#5a0# => romdata <= X"00"; --  
        when 16#6a0# => romdata <= X"00"; --  
        when 16#7a0# => romdata <= X"00"; --  
        when 16#8a0# => romdata <= X"00"; --  
        when 16#9a0# => romdata <= X"00"; --  
        when 16#aa0# => romdata <= X"00"; --  
        when 16#ba0# => romdata <= X"00"; --  
        when 16#ca0# => romdata <= X"00"; --  
        when 16#0a1# => romdata <= X"00"; -- ¡
        when 16#1a1# => romdata <= X"00"; -- ¡
        when 16#2a1# => romdata <= X"10"; -- ¡
        when 16#3a1# => romdata <= X"00"; -- ¡
        when 16#4a1# => romdata <= X"10"; -- ¡
        when 16#5a1# => romdata <= X"10"; -- ¡
        when 16#6a1# => romdata <= X"10"; -- ¡
        when 16#7a1# => romdata <= X"10"; -- ¡
        when 16#8a1# => romdata <= X"10"; -- ¡
        when 16#9a1# => romdata <= X"10"; -- ¡
        when 16#aa1# => romdata <= X"10"; -- ¡
        when 16#ba1# => romdata <= X"00"; -- ¡
        when 16#ca1# => romdata <= X"00"; -- ¡
        when 16#0a2# => romdata <= X"00"; -- ¢
        when 16#1a2# => romdata <= X"00"; -- ¢
        when 16#2a2# => romdata <= X"10"; -- ¢
        when 16#3a2# => romdata <= X"38"; -- ¢
        when 16#4a2# => romdata <= X"54"; -- ¢
        when 16#5a2# => romdata <= X"50"; -- ¢
        when 16#6a2# => romdata <= X"50"; -- ¢
        when 16#7a2# => romdata <= X"54"; -- ¢
        when 16#8a2# => romdata <= X"38"; -- ¢
        when 16#9a2# => romdata <= X"10"; -- ¢
        when 16#aa2# => romdata <= X"00"; -- ¢
        when 16#ba2# => romdata <= X"00"; -- ¢
        when 16#ca2# => romdata <= X"00"; -- ¢
        when 16#0a3# => romdata <= X"00"; -- £
        when 16#1a3# => romdata <= X"00"; -- £
        when 16#2a3# => romdata <= X"1c"; -- £
        when 16#3a3# => romdata <= X"22"; -- £
        when 16#4a3# => romdata <= X"20"; -- £
        when 16#5a3# => romdata <= X"70"; -- £
        when 16#6a3# => romdata <= X"20"; -- £
        when 16#7a3# => romdata <= X"20"; -- £
        when 16#8a3# => romdata <= X"20"; -- £
        when 16#9a3# => romdata <= X"62"; -- £
        when 16#aa3# => romdata <= X"dc"; -- £
        when 16#ba3# => romdata <= X"00"; -- £
        when 16#ca3# => romdata <= X"00"; -- £
        when 16#0a4# => romdata <= X"00"; -- ¤
        when 16#1a4# => romdata <= X"00"; -- ¤
        when 16#2a4# => romdata <= X"00"; -- ¤
        when 16#3a4# => romdata <= X"00"; -- ¤
        when 16#4a4# => romdata <= X"42"; -- ¤
        when 16#5a4# => romdata <= X"3c"; -- ¤
        when 16#6a4# => romdata <= X"24"; -- ¤
        when 16#7a4# => romdata <= X"24"; -- ¤
        when 16#8a4# => romdata <= X"3c"; -- ¤
        when 16#9a4# => romdata <= X"42"; -- ¤
        when 16#aa4# => romdata <= X"00"; -- ¤
        when 16#ba4# => romdata <= X"00"; -- ¤
        when 16#ca4# => romdata <= X"00"; -- ¤
        when 16#0a5# => romdata <= X"00"; -- ¥
        when 16#1a5# => romdata <= X"00"; -- ¥
        when 16#2a5# => romdata <= X"82"; -- ¥
        when 16#3a5# => romdata <= X"82"; -- ¥
        when 16#4a5# => romdata <= X"44"; -- ¥
        when 16#5a5# => romdata <= X"28"; -- ¥
        when 16#6a5# => romdata <= X"7c"; -- ¥
        when 16#7a5# => romdata <= X"10"; -- ¥
        when 16#8a5# => romdata <= X"7c"; -- ¥
        when 16#9a5# => romdata <= X"10"; -- ¥
        when 16#aa5# => romdata <= X"10"; -- ¥
        when 16#ba5# => romdata <= X"00"; -- ¥
        when 16#ca5# => romdata <= X"00"; -- ¥
        when 16#0a6# => romdata <= X"00"; -- ¦
        when 16#1a6# => romdata <= X"00"; -- ¦
        when 16#2a6# => romdata <= X"10"; -- ¦
        when 16#3a6# => romdata <= X"10"; -- ¦
        when 16#4a6# => romdata <= X"10"; -- ¦
        when 16#5a6# => romdata <= X"10"; -- ¦
        when 16#6a6# => romdata <= X"00"; -- ¦
        when 16#7a6# => romdata <= X"10"; -- ¦
        when 16#8a6# => romdata <= X"10"; -- ¦
        when 16#9a6# => romdata <= X"10"; -- ¦
        when 16#aa6# => romdata <= X"10"; -- ¦
        when 16#ba6# => romdata <= X"00"; -- ¦
        when 16#ca6# => romdata <= X"00"; -- ¦
        when 16#0a7# => romdata <= X"00"; -- §
        when 16#1a7# => romdata <= X"18"; -- §
        when 16#2a7# => romdata <= X"24"; -- §
        when 16#3a7# => romdata <= X"20"; -- §
        when 16#4a7# => romdata <= X"18"; -- §
        when 16#5a7# => romdata <= X"24"; -- §
        when 16#6a7# => romdata <= X"24"; -- §
        when 16#7a7# => romdata <= X"18"; -- §
        when 16#8a7# => romdata <= X"04"; -- §
        when 16#9a7# => romdata <= X"24"; -- §
        when 16#aa7# => romdata <= X"18"; -- §
        when 16#ba7# => romdata <= X"00"; -- §
        when 16#ca7# => romdata <= X"00"; -- §
        when 16#0a8# => romdata <= X"00"; -- ¨
        when 16#1a8# => romdata <= X"24"; -- ¨
        when 16#2a8# => romdata <= X"24"; -- ¨
        when 16#3a8# => romdata <= X"00"; -- ¨
        when 16#4a8# => romdata <= X"00"; -- ¨
        when 16#5a8# => romdata <= X"00"; -- ¨
        when 16#6a8# => romdata <= X"00"; -- ¨
        when 16#7a8# => romdata <= X"00"; -- ¨
        when 16#8a8# => romdata <= X"00"; -- ¨
        when 16#9a8# => romdata <= X"00"; -- ¨
        when 16#aa8# => romdata <= X"00"; -- ¨
        when 16#ba8# => romdata <= X"00"; -- ¨
        when 16#ca8# => romdata <= X"00"; -- ¨
        when 16#0a9# => romdata <= X"00"; -- ©
        when 16#1a9# => romdata <= X"38"; -- ©
        when 16#2a9# => romdata <= X"44"; -- ©
        when 16#3a9# => romdata <= X"92"; -- ©
        when 16#4a9# => romdata <= X"aa"; -- ©
        when 16#5a9# => romdata <= X"a2"; -- ©
        when 16#6a9# => romdata <= X"aa"; -- ©
        when 16#7a9# => romdata <= X"92"; -- ©
        when 16#8a9# => romdata <= X"44"; -- ©
        when 16#9a9# => romdata <= X"38"; -- ©
        when 16#aa9# => romdata <= X"00"; -- ©
        when 16#ba9# => romdata <= X"00"; -- ©
        when 16#ca9# => romdata <= X"00"; -- ©
        when 16#0aa# => romdata <= X"00"; -- ª
        when 16#1aa# => romdata <= X"00"; -- ª
        when 16#2aa# => romdata <= X"38"; -- ª
        when 16#3aa# => romdata <= X"04"; -- ª
        when 16#4aa# => romdata <= X"3c"; -- ª
        when 16#5aa# => romdata <= X"44"; -- ª
        when 16#6aa# => romdata <= X"3c"; -- ª
        when 16#7aa# => romdata <= X"00"; -- ª
        when 16#8aa# => romdata <= X"7c"; -- ª
        when 16#9aa# => romdata <= X"00"; -- ª
        when 16#aaa# => romdata <= X"00"; -- ª
        when 16#baa# => romdata <= X"00"; -- ª
        when 16#caa# => romdata <= X"00"; -- ª
        when 16#0ab# => romdata <= X"00"; -- «
        when 16#1ab# => romdata <= X"00"; -- «
        when 16#2ab# => romdata <= X"00"; -- «
        when 16#3ab# => romdata <= X"12"; -- «
        when 16#4ab# => romdata <= X"24"; -- «
        when 16#5ab# => romdata <= X"48"; -- «
        when 16#6ab# => romdata <= X"90"; -- «
        when 16#7ab# => romdata <= X"48"; -- «
        when 16#8ab# => romdata <= X"24"; -- «
        when 16#9ab# => romdata <= X"12"; -- «
        when 16#aab# => romdata <= X"00"; -- «
        when 16#bab# => romdata <= X"00"; -- «
        when 16#cab# => romdata <= X"00"; -- «
        when 16#0ac# => romdata <= X"00"; -- ¬
        when 16#1ac# => romdata <= X"00"; -- ¬
        when 16#2ac# => romdata <= X"00"; -- ¬
        when 16#3ac# => romdata <= X"00"; -- ¬
        when 16#4ac# => romdata <= X"00"; -- ¬
        when 16#5ac# => romdata <= X"00"; -- ¬
        when 16#6ac# => romdata <= X"7e"; -- ¬
        when 16#7ac# => romdata <= X"02"; -- ¬
        when 16#8ac# => romdata <= X"02"; -- ¬
        when 16#9ac# => romdata <= X"02"; -- ¬
        when 16#aac# => romdata <= X"00"; -- ¬
        when 16#bac# => romdata <= X"00"; -- ¬
        when 16#cac# => romdata <= X"00"; -- ¬
        when 16#0ad# => romdata <= X"00"; -- ­
        when 16#1ad# => romdata <= X"00"; -- ­
        when 16#2ad# => romdata <= X"00"; -- ­
        when 16#3ad# => romdata <= X"00"; -- ­
        when 16#4ad# => romdata <= X"00"; -- ­
        when 16#5ad# => romdata <= X"00"; -- ­
        when 16#6ad# => romdata <= X"3c"; -- ­
        when 16#7ad# => romdata <= X"00"; -- ­
        when 16#8ad# => romdata <= X"00"; -- ­
        when 16#9ad# => romdata <= X"00"; -- ­
        when 16#aad# => romdata <= X"00"; -- ­
        when 16#bad# => romdata <= X"00"; -- ­
        when 16#cad# => romdata <= X"00"; -- ­
        when 16#0ae# => romdata <= X"00"; -- ®
        when 16#1ae# => romdata <= X"38"; -- ®
        when 16#2ae# => romdata <= X"44"; -- ®
        when 16#3ae# => romdata <= X"92"; -- ®
        when 16#4ae# => romdata <= X"aa"; -- ®
        when 16#5ae# => romdata <= X"aa"; -- ®
        when 16#6ae# => romdata <= X"b2"; -- ®
        when 16#7ae# => romdata <= X"aa"; -- ®
        when 16#8ae# => romdata <= X"44"; -- ®
        when 16#9ae# => romdata <= X"38"; -- ®
        when 16#aae# => romdata <= X"00"; -- ®
        when 16#bae# => romdata <= X"00"; -- ®
        when 16#cae# => romdata <= X"00"; -- ®
        when 16#0af# => romdata <= X"00"; -- ¯
        when 16#1af# => romdata <= X"00"; -- ¯
        when 16#2af# => romdata <= X"7e"; -- ¯
        when 16#3af# => romdata <= X"00"; -- ¯
        when 16#4af# => romdata <= X"00"; -- ¯
        when 16#5af# => romdata <= X"00"; -- ¯
        when 16#6af# => romdata <= X"00"; -- ¯
        when 16#7af# => romdata <= X"00"; -- ¯
        when 16#8af# => romdata <= X"00"; -- ¯
        when 16#9af# => romdata <= X"00"; -- ¯
        when 16#aaf# => romdata <= X"00"; -- ¯
        when 16#baf# => romdata <= X"00"; -- ¯
        when 16#caf# => romdata <= X"00"; -- ¯
        when 16#0b0# => romdata <= X"00"; -- °
        when 16#1b0# => romdata <= X"00"; -- °
        when 16#2b0# => romdata <= X"18"; -- °
        when 16#3b0# => romdata <= X"24"; -- °
        when 16#4b0# => romdata <= X"24"; -- °
        when 16#5b0# => romdata <= X"18"; -- °
        when 16#6b0# => romdata <= X"00"; -- °
        when 16#7b0# => romdata <= X"00"; -- °
        when 16#8b0# => romdata <= X"00"; -- °
        when 16#9b0# => romdata <= X"00"; -- °
        when 16#ab0# => romdata <= X"00"; -- °
        when 16#bb0# => romdata <= X"00"; -- °
        when 16#cb0# => romdata <= X"00"; -- °
        when 16#0b1# => romdata <= X"00"; -- ±
        when 16#1b1# => romdata <= X"00"; -- ±
        when 16#2b1# => romdata <= X"00"; -- ±
        when 16#3b1# => romdata <= X"10"; -- ±
        when 16#4b1# => romdata <= X"10"; -- ±
        when 16#5b1# => romdata <= X"7c"; -- ±
        when 16#6b1# => romdata <= X"10"; -- ±
        when 16#7b1# => romdata <= X"10"; -- ±
        when 16#8b1# => romdata <= X"00"; -- ±
        when 16#9b1# => romdata <= X"7c"; -- ±
        when 16#ab1# => romdata <= X"00"; -- ±
        when 16#bb1# => romdata <= X"00"; -- ±
        when 16#cb1# => romdata <= X"00"; -- ±
        when 16#0b2# => romdata <= X"00"; -- ²
        when 16#1b2# => romdata <= X"30"; -- ²
        when 16#2b2# => romdata <= X"48"; -- ²
        when 16#3b2# => romdata <= X"08"; -- ²
        when 16#4b2# => romdata <= X"30"; -- ²
        when 16#5b2# => romdata <= X"40"; -- ²
        when 16#6b2# => romdata <= X"78"; -- ²
        when 16#7b2# => romdata <= X"00"; -- ²
        when 16#8b2# => romdata <= X"00"; -- ²
        when 16#9b2# => romdata <= X"00"; -- ²
        when 16#ab2# => romdata <= X"00"; -- ²
        when 16#bb2# => romdata <= X"00"; -- ²
        when 16#cb2# => romdata <= X"00"; -- ²
        when 16#0b3# => romdata <= X"00"; -- ³
        when 16#1b3# => romdata <= X"30"; -- ³
        when 16#2b3# => romdata <= X"48"; -- ³
        when 16#3b3# => romdata <= X"10"; -- ³
        when 16#4b3# => romdata <= X"08"; -- ³
        when 16#5b3# => romdata <= X"48"; -- ³
        when 16#6b3# => romdata <= X"30"; -- ³
        when 16#7b3# => romdata <= X"00"; -- ³
        when 16#8b3# => romdata <= X"00"; -- ³
        when 16#9b3# => romdata <= X"00"; -- ³
        when 16#ab3# => romdata <= X"00"; -- ³
        when 16#bb3# => romdata <= X"00"; -- ³
        when 16#cb3# => romdata <= X"00"; -- ³
        when 16#0b4# => romdata <= X"00"; -- ´
        when 16#1b4# => romdata <= X"08"; -- ´
        when 16#2b4# => romdata <= X"10"; -- ´
        when 16#3b4# => romdata <= X"00"; -- ´
        when 16#4b4# => romdata <= X"00"; -- ´
        when 16#5b4# => romdata <= X"00"; -- ´
        when 16#6b4# => romdata <= X"00"; -- ´
        when 16#7b4# => romdata <= X"00"; -- ´
        when 16#8b4# => romdata <= X"00"; -- ´
        when 16#9b4# => romdata <= X"00"; -- ´
        when 16#ab4# => romdata <= X"00"; -- ´
        when 16#bb4# => romdata <= X"00"; -- ´
        when 16#cb4# => romdata <= X"00"; -- ´
        when 16#0b5# => romdata <= X"00"; -- µ
        when 16#1b5# => romdata <= X"00"; -- µ
        when 16#2b5# => romdata <= X"00"; -- µ
        when 16#3b5# => romdata <= X"00"; -- µ
        when 16#4b5# => romdata <= X"00"; -- µ
        when 16#5b5# => romdata <= X"42"; -- µ
        when 16#6b5# => romdata <= X"42"; -- µ
        when 16#7b5# => romdata <= X"42"; -- µ
        when 16#8b5# => romdata <= X"42"; -- µ
        when 16#9b5# => romdata <= X"66"; -- µ
        when 16#ab5# => romdata <= X"5a"; -- µ
        when 16#bb5# => romdata <= X"40"; -- µ
        when 16#cb5# => romdata <= X"00"; -- µ
        when 16#0b6# => romdata <= X"00"; -- ¶
        when 16#1b6# => romdata <= X"00"; -- ¶
        when 16#2b6# => romdata <= X"3e"; -- ¶
        when 16#3b6# => romdata <= X"74"; -- ¶
        when 16#4b6# => romdata <= X"74"; -- ¶
        when 16#5b6# => romdata <= X"74"; -- ¶
        when 16#6b6# => romdata <= X"34"; -- ¶
        when 16#7b6# => romdata <= X"14"; -- ¶
        when 16#8b6# => romdata <= X"14"; -- ¶
        when 16#9b6# => romdata <= X"14"; -- ¶
        when 16#ab6# => romdata <= X"14"; -- ¶
        when 16#bb6# => romdata <= X"00"; -- ¶
        when 16#cb6# => romdata <= X"00"; -- ¶
        when 16#0b7# => romdata <= X"00"; -- ·
        when 16#1b7# => romdata <= X"00"; -- ·
        when 16#2b7# => romdata <= X"00"; -- ·
        when 16#3b7# => romdata <= X"00"; -- ·
        when 16#4b7# => romdata <= X"00"; -- ·
        when 16#5b7# => romdata <= X"00"; -- ·
        when 16#6b7# => romdata <= X"18"; -- ·
        when 16#7b7# => romdata <= X"00"; -- ·
        when 16#8b7# => romdata <= X"00"; -- ·
        when 16#9b7# => romdata <= X"00"; -- ·
        when 16#ab7# => romdata <= X"00"; -- ·
        when 16#bb7# => romdata <= X"00"; -- ·
        when 16#cb7# => romdata <= X"00"; -- ·
        when 16#0b8# => romdata <= X"00"; -- ¸
        when 16#1b8# => romdata <= X"00"; -- ¸
        when 16#2b8# => romdata <= X"00"; -- ¸
        when 16#3b8# => romdata <= X"00"; -- ¸
        when 16#4b8# => romdata <= X"00"; -- ¸
        when 16#5b8# => romdata <= X"00"; -- ¸
        when 16#6b8# => romdata <= X"00"; -- ¸
        when 16#7b8# => romdata <= X"00"; -- ¸
        when 16#8b8# => romdata <= X"00"; -- ¸
        when 16#9b8# => romdata <= X"00"; -- ¸
        when 16#ab8# => romdata <= X"00"; -- ¸
        when 16#bb8# => romdata <= X"08"; -- ¸
        when 16#cb8# => romdata <= X"18"; -- ¸
        when 16#0b9# => romdata <= X"00"; -- ¹
        when 16#1b9# => romdata <= X"20"; -- ¹
        when 16#2b9# => romdata <= X"60"; -- ¹
        when 16#3b9# => romdata <= X"20"; -- ¹
        when 16#4b9# => romdata <= X"20"; -- ¹
        when 16#5b9# => romdata <= X"20"; -- ¹
        when 16#6b9# => romdata <= X"70"; -- ¹
        when 16#7b9# => romdata <= X"00"; -- ¹
        when 16#8b9# => romdata <= X"00"; -- ¹
        when 16#9b9# => romdata <= X"00"; -- ¹
        when 16#ab9# => romdata <= X"00"; -- ¹
        when 16#bb9# => romdata <= X"00"; -- ¹
        when 16#cb9# => romdata <= X"00"; -- ¹
        when 16#0ba# => romdata <= X"00"; -- º
        when 16#1ba# => romdata <= X"00"; -- º
        when 16#2ba# => romdata <= X"30"; -- º
        when 16#3ba# => romdata <= X"48"; -- º
        when 16#4ba# => romdata <= X"48"; -- º
        when 16#5ba# => romdata <= X"30"; -- º
        when 16#6ba# => romdata <= X"00"; -- º
        when 16#7ba# => romdata <= X"78"; -- º
        when 16#8ba# => romdata <= X"00"; -- º
        when 16#9ba# => romdata <= X"00"; -- º
        when 16#aba# => romdata <= X"00"; -- º
        when 16#bba# => romdata <= X"00"; -- º
        when 16#cba# => romdata <= X"00"; -- º
        when 16#0bb# => romdata <= X"00"; -- »
        when 16#1bb# => romdata <= X"00"; -- »
        when 16#2bb# => romdata <= X"00"; -- »
        when 16#3bb# => romdata <= X"90"; -- »
        when 16#4bb# => romdata <= X"48"; -- »
        when 16#5bb# => romdata <= X"24"; -- »
        when 16#6bb# => romdata <= X"12"; -- »
        when 16#7bb# => romdata <= X"24"; -- »
        when 16#8bb# => romdata <= X"48"; -- »
        when 16#9bb# => romdata <= X"90"; -- »
        when 16#abb# => romdata <= X"00"; -- »
        when 16#bbb# => romdata <= X"00"; -- »
        when 16#cbb# => romdata <= X"00"; -- »
        when 16#0bc# => romdata <= X"00"; -- ¼
        when 16#1bc# => romdata <= X"40"; -- ¼
        when 16#2bc# => romdata <= X"c0"; -- ¼
        when 16#3bc# => romdata <= X"40"; -- ¼
        when 16#4bc# => romdata <= X"40"; -- ¼
        when 16#5bc# => romdata <= X"42"; -- ¼
        when 16#6bc# => romdata <= X"e6"; -- ¼
        when 16#7bc# => romdata <= X"0a"; -- ¼
        when 16#8bc# => romdata <= X"12"; -- ¼
        when 16#9bc# => romdata <= X"1a"; -- ¼
        when 16#abc# => romdata <= X"06"; -- ¼
        when 16#bbc# => romdata <= X"00"; -- ¼
        when 16#cbc# => romdata <= X"00"; -- ¼
        when 16#0bd# => romdata <= X"00"; -- ½
        when 16#1bd# => romdata <= X"40"; -- ½
        when 16#2bd# => romdata <= X"c0"; -- ½
        when 16#3bd# => romdata <= X"40"; -- ½
        when 16#4bd# => romdata <= X"40"; -- ½
        when 16#5bd# => romdata <= X"4c"; -- ½
        when 16#6bd# => romdata <= X"f2"; -- ½
        when 16#7bd# => romdata <= X"02"; -- ½
        when 16#8bd# => romdata <= X"0c"; -- ½
        when 16#9bd# => romdata <= X"10"; -- ½
        when 16#abd# => romdata <= X"1e"; -- ½
        when 16#bbd# => romdata <= X"00"; -- ½
        when 16#cbd# => romdata <= X"00"; -- ½
        when 16#0be# => romdata <= X"00"; -- ¾
        when 16#1be# => romdata <= X"60"; -- ¾
        when 16#2be# => romdata <= X"90"; -- ¾
        when 16#3be# => romdata <= X"20"; -- ¾
        when 16#4be# => romdata <= X"10"; -- ¾
        when 16#5be# => romdata <= X"92"; -- ¾
        when 16#6be# => romdata <= X"66"; -- ¾
        when 16#7be# => romdata <= X"0a"; -- ¾
        when 16#8be# => romdata <= X"12"; -- ¾
        when 16#9be# => romdata <= X"1a"; -- ¾
        when 16#abe# => romdata <= X"06"; -- ¾
        when 16#bbe# => romdata <= X"00"; -- ¾
        when 16#cbe# => romdata <= X"00"; -- ¾
        when 16#0bf# => romdata <= X"00"; -- ¿
        when 16#1bf# => romdata <= X"00"; -- ¿
        when 16#2bf# => romdata <= X"10"; -- ¿
        when 16#3bf# => romdata <= X"00"; -- ¿
        when 16#4bf# => romdata <= X"10"; -- ¿
        when 16#5bf# => romdata <= X"10"; -- ¿
        when 16#6bf# => romdata <= X"20"; -- ¿
        when 16#7bf# => romdata <= X"40"; -- ¿
        when 16#8bf# => romdata <= X"42"; -- ¿
        when 16#9bf# => romdata <= X"42"; -- ¿
        when 16#abf# => romdata <= X"3c"; -- ¿
        when 16#bbf# => romdata <= X"00"; -- ¿
        when 16#cbf# => romdata <= X"00"; -- ¿
        when 16#0c0# => romdata <= X"00"; -- À
        when 16#1c0# => romdata <= X"10"; -- À
        when 16#2c0# => romdata <= X"08"; -- À
        when 16#3c0# => romdata <= X"00"; -- À
        when 16#4c0# => romdata <= X"18"; -- À
        when 16#5c0# => romdata <= X"24"; -- À
        when 16#6c0# => romdata <= X"42"; -- À
        when 16#7c0# => romdata <= X"42"; -- À
        when 16#8c0# => romdata <= X"7e"; -- À
        when 16#9c0# => romdata <= X"42"; -- À
        when 16#ac0# => romdata <= X"42"; -- À
        when 16#bc0# => romdata <= X"00"; -- À
        when 16#cc0# => romdata <= X"00"; -- À
        when 16#0c1# => romdata <= X"00"; -- Á
        when 16#1c1# => romdata <= X"08"; -- Á
        when 16#2c1# => romdata <= X"10"; -- Á
        when 16#3c1# => romdata <= X"00"; -- Á
        when 16#4c1# => romdata <= X"18"; -- Á
        when 16#5c1# => romdata <= X"24"; -- Á
        when 16#6c1# => romdata <= X"42"; -- Á
        when 16#7c1# => romdata <= X"42"; -- Á
        when 16#8c1# => romdata <= X"7e"; -- Á
        when 16#9c1# => romdata <= X"42"; -- Á
        when 16#ac1# => romdata <= X"42"; -- Á
        when 16#bc1# => romdata <= X"00"; -- Á
        when 16#cc1# => romdata <= X"00"; -- Á
        when 16#0c2# => romdata <= X"00"; -- Â
        when 16#1c2# => romdata <= X"18"; -- Â
        when 16#2c2# => romdata <= X"24"; -- Â
        when 16#3c2# => romdata <= X"00"; -- Â
        when 16#4c2# => romdata <= X"18"; -- Â
        when 16#5c2# => romdata <= X"24"; -- Â
        when 16#6c2# => romdata <= X"42"; -- Â
        when 16#7c2# => romdata <= X"42"; -- Â
        when 16#8c2# => romdata <= X"7e"; -- Â
        when 16#9c2# => romdata <= X"42"; -- Â
        when 16#ac2# => romdata <= X"42"; -- Â
        when 16#bc2# => romdata <= X"00"; -- Â
        when 16#cc2# => romdata <= X"00"; -- Â
        when 16#0c3# => romdata <= X"00"; -- Ã
        when 16#1c3# => romdata <= X"32"; -- Ã
        when 16#2c3# => romdata <= X"4c"; -- Ã
        when 16#3c3# => romdata <= X"00"; -- Ã
        when 16#4c3# => romdata <= X"18"; -- Ã
        when 16#5c3# => romdata <= X"24"; -- Ã
        when 16#6c3# => romdata <= X"42"; -- Ã
        when 16#7c3# => romdata <= X"42"; -- Ã
        when 16#8c3# => romdata <= X"7e"; -- Ã
        when 16#9c3# => romdata <= X"42"; -- Ã
        when 16#ac3# => romdata <= X"42"; -- Ã
        when 16#bc3# => romdata <= X"00"; -- Ã
        when 16#cc3# => romdata <= X"00"; -- Ã
        when 16#0c4# => romdata <= X"00"; -- Ä
        when 16#1c4# => romdata <= X"24"; -- Ä
        when 16#2c4# => romdata <= X"24"; -- Ä
        when 16#3c4# => romdata <= X"00"; -- Ä
        when 16#4c4# => romdata <= X"18"; -- Ä
        when 16#5c4# => romdata <= X"24"; -- Ä
        when 16#6c4# => romdata <= X"42"; -- Ä
        when 16#7c4# => romdata <= X"42"; -- Ä
        when 16#8c4# => romdata <= X"7e"; -- Ä
        when 16#9c4# => romdata <= X"42"; -- Ä
        when 16#ac4# => romdata <= X"42"; -- Ä
        when 16#bc4# => romdata <= X"00"; -- Ä
        when 16#cc4# => romdata <= X"00"; -- Ä
        when 16#0c5# => romdata <= X"00"; -- Å
        when 16#1c5# => romdata <= X"18"; -- Å
        when 16#2c5# => romdata <= X"24"; -- Å
        when 16#3c5# => romdata <= X"18"; -- Å
        when 16#4c5# => romdata <= X"18"; -- Å
        when 16#5c5# => romdata <= X"24"; -- Å
        when 16#6c5# => romdata <= X"42"; -- Å
        when 16#7c5# => romdata <= X"42"; -- Å
        when 16#8c5# => romdata <= X"7e"; -- Å
        when 16#9c5# => romdata <= X"42"; -- Å
        when 16#ac5# => romdata <= X"42"; -- Å
        when 16#bc5# => romdata <= X"00"; -- Å
        when 16#cc5# => romdata <= X"00"; -- Å
        when 16#0c6# => romdata <= X"00"; -- Æ
        when 16#1c6# => romdata <= X"00"; -- Æ
        when 16#2c6# => romdata <= X"6e"; -- Æ
        when 16#3c6# => romdata <= X"90"; -- Æ
        when 16#4c6# => romdata <= X"90"; -- Æ
        when 16#5c6# => romdata <= X"90"; -- Æ
        when 16#6c6# => romdata <= X"9c"; -- Æ
        when 16#7c6# => romdata <= X"f0"; -- Æ
        when 16#8c6# => romdata <= X"90"; -- Æ
        when 16#9c6# => romdata <= X"90"; -- Æ
        when 16#ac6# => romdata <= X"9e"; -- Æ
        when 16#bc6# => romdata <= X"00"; -- Æ
        when 16#cc6# => romdata <= X"00"; -- Æ
        when 16#0c7# => romdata <= X"00"; -- Ç
        when 16#1c7# => romdata <= X"00"; -- Ç
        when 16#2c7# => romdata <= X"3c"; -- Ç
        when 16#3c7# => romdata <= X"42"; -- Ç
        when 16#4c7# => romdata <= X"40"; -- Ç
        when 16#5c7# => romdata <= X"40"; -- Ç
        when 16#6c7# => romdata <= X"40"; -- Ç
        when 16#7c7# => romdata <= X"40"; -- Ç
        when 16#8c7# => romdata <= X"40"; -- Ç
        when 16#9c7# => romdata <= X"42"; -- Ç
        when 16#ac7# => romdata <= X"3c"; -- Ç
        when 16#bc7# => romdata <= X"08"; -- Ç
        when 16#cc7# => romdata <= X"10"; -- Ç
        when 16#0c8# => romdata <= X"00"; -- È
        when 16#1c8# => romdata <= X"10"; -- È
        when 16#2c8# => romdata <= X"08"; -- È
        when 16#3c8# => romdata <= X"00"; -- È
        when 16#4c8# => romdata <= X"7e"; -- È
        when 16#5c8# => romdata <= X"40"; -- È
        when 16#6c8# => romdata <= X"40"; -- È
        when 16#7c8# => romdata <= X"78"; -- È
        when 16#8c8# => romdata <= X"40"; -- È
        when 16#9c8# => romdata <= X"40"; -- È
        when 16#ac8# => romdata <= X"7e"; -- È
        when 16#bc8# => romdata <= X"00"; -- È
        when 16#cc8# => romdata <= X"00"; -- È
        when 16#0c9# => romdata <= X"00"; -- É
        when 16#1c9# => romdata <= X"08"; -- É
        when 16#2c9# => romdata <= X"10"; -- É
        when 16#3c9# => romdata <= X"00"; -- É
        when 16#4c9# => romdata <= X"7e"; -- É
        when 16#5c9# => romdata <= X"40"; -- É
        when 16#6c9# => romdata <= X"40"; -- É
        when 16#7c9# => romdata <= X"78"; -- É
        when 16#8c9# => romdata <= X"40"; -- É
        when 16#9c9# => romdata <= X"40"; -- É
        when 16#ac9# => romdata <= X"7e"; -- É
        when 16#bc9# => romdata <= X"00"; -- É
        when 16#cc9# => romdata <= X"00"; -- É
        when 16#0ca# => romdata <= X"00"; -- Ê
        when 16#1ca# => romdata <= X"18"; -- Ê
        when 16#2ca# => romdata <= X"24"; -- Ê
        when 16#3ca# => romdata <= X"00"; -- Ê
        when 16#4ca# => romdata <= X"7e"; -- Ê
        when 16#5ca# => romdata <= X"40"; -- Ê
        when 16#6ca# => romdata <= X"40"; -- Ê
        when 16#7ca# => romdata <= X"78"; -- Ê
        when 16#8ca# => romdata <= X"40"; -- Ê
        when 16#9ca# => romdata <= X"40"; -- Ê
        when 16#aca# => romdata <= X"7e"; -- Ê
        when 16#bca# => romdata <= X"00"; -- Ê
        when 16#cca# => romdata <= X"00"; -- Ê
        when 16#0cb# => romdata <= X"00"; -- Ë
        when 16#1cb# => romdata <= X"24"; -- Ë
        when 16#2cb# => romdata <= X"24"; -- Ë
        when 16#3cb# => romdata <= X"00"; -- Ë
        when 16#4cb# => romdata <= X"7e"; -- Ë
        when 16#5cb# => romdata <= X"40"; -- Ë
        when 16#6cb# => romdata <= X"40"; -- Ë
        when 16#7cb# => romdata <= X"78"; -- Ë
        when 16#8cb# => romdata <= X"40"; -- Ë
        when 16#9cb# => romdata <= X"40"; -- Ë
        when 16#acb# => romdata <= X"7e"; -- Ë
        when 16#bcb# => romdata <= X"00"; -- Ë
        when 16#ccb# => romdata <= X"00"; -- Ë
        when 16#0cc# => romdata <= X"00"; -- Ì
        when 16#1cc# => romdata <= X"20"; -- Ì
        when 16#2cc# => romdata <= X"10"; -- Ì
        when 16#3cc# => romdata <= X"00"; -- Ì
        when 16#4cc# => romdata <= X"7c"; -- Ì
        when 16#5cc# => romdata <= X"10"; -- Ì
        when 16#6cc# => romdata <= X"10"; -- Ì
        when 16#7cc# => romdata <= X"10"; -- Ì
        when 16#8cc# => romdata <= X"10"; -- Ì
        when 16#9cc# => romdata <= X"10"; -- Ì
        when 16#acc# => romdata <= X"7c"; -- Ì
        when 16#bcc# => romdata <= X"00"; -- Ì
        when 16#ccc# => romdata <= X"00"; -- Ì
        when 16#0cd# => romdata <= X"00"; -- Í
        when 16#1cd# => romdata <= X"08"; -- Í
        when 16#2cd# => romdata <= X"10"; -- Í
        when 16#3cd# => romdata <= X"00"; -- Í
        when 16#4cd# => romdata <= X"7c"; -- Í
        when 16#5cd# => romdata <= X"10"; -- Í
        when 16#6cd# => romdata <= X"10"; -- Í
        when 16#7cd# => romdata <= X"10"; -- Í
        when 16#8cd# => romdata <= X"10"; -- Í
        when 16#9cd# => romdata <= X"10"; -- Í
        when 16#acd# => romdata <= X"7c"; -- Í
        when 16#bcd# => romdata <= X"00"; -- Í
        when 16#ccd# => romdata <= X"00"; -- Í
        when 16#0ce# => romdata <= X"00"; -- Î
        when 16#1ce# => romdata <= X"18"; -- Î
        when 16#2ce# => romdata <= X"24"; -- Î
        when 16#3ce# => romdata <= X"00"; -- Î
        when 16#4ce# => romdata <= X"7c"; -- Î
        when 16#5ce# => romdata <= X"10"; -- Î
        when 16#6ce# => romdata <= X"10"; -- Î
        when 16#7ce# => romdata <= X"10"; -- Î
        when 16#8ce# => romdata <= X"10"; -- Î
        when 16#9ce# => romdata <= X"10"; -- Î
        when 16#ace# => romdata <= X"7c"; -- Î
        when 16#bce# => romdata <= X"00"; -- Î
        when 16#cce# => romdata <= X"00"; -- Î
        when 16#0cf# => romdata <= X"00"; -- Ï
        when 16#1cf# => romdata <= X"44"; -- Ï
        when 16#2cf# => romdata <= X"44"; -- Ï
        when 16#3cf# => romdata <= X"00"; -- Ï
        when 16#4cf# => romdata <= X"7c"; -- Ï
        when 16#5cf# => romdata <= X"10"; -- Ï
        when 16#6cf# => romdata <= X"10"; -- Ï
        when 16#7cf# => romdata <= X"10"; -- Ï
        when 16#8cf# => romdata <= X"10"; -- Ï
        when 16#9cf# => romdata <= X"10"; -- Ï
        when 16#acf# => romdata <= X"7c"; -- Ï
        when 16#bcf# => romdata <= X"00"; -- Ï
        when 16#ccf# => romdata <= X"00"; -- Ï
        when 16#0d0# => romdata <= X"00"; -- Ğ
        when 16#1d0# => romdata <= X"00"; -- Ğ
        when 16#2d0# => romdata <= X"78"; -- Ğ
        when 16#3d0# => romdata <= X"44"; -- Ğ
        when 16#4d0# => romdata <= X"42"; -- Ğ
        when 16#5d0# => romdata <= X"42"; -- Ğ
        when 16#6d0# => romdata <= X"e2"; -- Ğ
        when 16#7d0# => romdata <= X"42"; -- Ğ
        when 16#8d0# => romdata <= X"42"; -- Ğ
        when 16#9d0# => romdata <= X"44"; -- Ğ
        when 16#ad0# => romdata <= X"78"; -- Ğ
        when 16#bd0# => romdata <= X"00"; -- Ğ
        when 16#cd0# => romdata <= X"00"; -- Ğ
        when 16#0d1# => romdata <= X"00"; -- Ñ
        when 16#1d1# => romdata <= X"64"; -- Ñ
        when 16#2d1# => romdata <= X"98"; -- Ñ
        when 16#3d1# => romdata <= X"00"; -- Ñ
        when 16#4d1# => romdata <= X"82"; -- Ñ
        when 16#5d1# => romdata <= X"c2"; -- Ñ
        when 16#6d1# => romdata <= X"a2"; -- Ñ
        when 16#7d1# => romdata <= X"92"; -- Ñ
        when 16#8d1# => romdata <= X"8a"; -- Ñ
        when 16#9d1# => romdata <= X"86"; -- Ñ
        when 16#ad1# => romdata <= X"82"; -- Ñ
        when 16#bd1# => romdata <= X"00"; -- Ñ
        when 16#cd1# => romdata <= X"00"; -- Ñ
        when 16#0d2# => romdata <= X"00"; -- Ò
        when 16#1d2# => romdata <= X"20"; -- Ò
        when 16#2d2# => romdata <= X"10"; -- Ò
        when 16#3d2# => romdata <= X"00"; -- Ò
        when 16#4d2# => romdata <= X"7c"; -- Ò
        when 16#5d2# => romdata <= X"82"; -- Ò
        when 16#6d2# => romdata <= X"82"; -- Ò
        when 16#7d2# => romdata <= X"82"; -- Ò
        when 16#8d2# => romdata <= X"82"; -- Ò
        when 16#9d2# => romdata <= X"82"; -- Ò
        when 16#ad2# => romdata <= X"7c"; -- Ò
        when 16#bd2# => romdata <= X"00"; -- Ò
        when 16#cd2# => romdata <= X"00"; -- Ò
        when 16#0d3# => romdata <= X"00"; -- Ó
        when 16#1d3# => romdata <= X"08"; -- Ó
        when 16#2d3# => romdata <= X"10"; -- Ó
        when 16#3d3# => romdata <= X"00"; -- Ó
        when 16#4d3# => romdata <= X"7c"; -- Ó
        when 16#5d3# => romdata <= X"82"; -- Ó
        when 16#6d3# => romdata <= X"82"; -- Ó
        when 16#7d3# => romdata <= X"82"; -- Ó
        when 16#8d3# => romdata <= X"82"; -- Ó
        when 16#9d3# => romdata <= X"82"; -- Ó
        when 16#ad3# => romdata <= X"7c"; -- Ó
        when 16#bd3# => romdata <= X"00"; -- Ó
        when 16#cd3# => romdata <= X"00"; -- Ó
        when 16#0d4# => romdata <= X"00"; -- Ô
        when 16#1d4# => romdata <= X"18"; -- Ô
        when 16#2d4# => romdata <= X"24"; -- Ô
        when 16#3d4# => romdata <= X"00"; -- Ô
        when 16#4d4# => romdata <= X"7c"; -- Ô
        when 16#5d4# => romdata <= X"82"; -- Ô
        when 16#6d4# => romdata <= X"82"; -- Ô
        when 16#7d4# => romdata <= X"82"; -- Ô
        when 16#8d4# => romdata <= X"82"; -- Ô
        when 16#9d4# => romdata <= X"82"; -- Ô
        when 16#ad4# => romdata <= X"7c"; -- Ô
        when 16#bd4# => romdata <= X"00"; -- Ô
        when 16#cd4# => romdata <= X"00"; -- Ô
        when 16#0d5# => romdata <= X"00"; -- Õ
        when 16#1d5# => romdata <= X"64"; -- Õ
        when 16#2d5# => romdata <= X"98"; -- Õ
        when 16#3d5# => romdata <= X"00"; -- Õ
        when 16#4d5# => romdata <= X"7c"; -- Õ
        when 16#5d5# => romdata <= X"82"; -- Õ
        when 16#6d5# => romdata <= X"82"; -- Õ
        when 16#7d5# => romdata <= X"82"; -- Õ
        when 16#8d5# => romdata <= X"82"; -- Õ
        when 16#9d5# => romdata <= X"82"; -- Õ
        when 16#ad5# => romdata <= X"7c"; -- Õ
        when 16#bd5# => romdata <= X"00"; -- Õ
        when 16#cd5# => romdata <= X"00"; -- Õ
        when 16#0d6# => romdata <= X"00"; -- Ö
        when 16#1d6# => romdata <= X"44"; -- Ö
        when 16#2d6# => romdata <= X"44"; -- Ö
        when 16#3d6# => romdata <= X"00"; -- Ö
        when 16#4d6# => romdata <= X"7c"; -- Ö
        when 16#5d6# => romdata <= X"82"; -- Ö
        when 16#6d6# => romdata <= X"82"; -- Ö
        when 16#7d6# => romdata <= X"82"; -- Ö
        when 16#8d6# => romdata <= X"82"; -- Ö
        when 16#9d6# => romdata <= X"82"; -- Ö
        when 16#ad6# => romdata <= X"7c"; -- Ö
        when 16#bd6# => romdata <= X"00"; -- Ö
        when 16#cd6# => romdata <= X"00"; -- Ö
        when 16#0d7# => romdata <= X"00"; -- ×
        when 16#1d7# => romdata <= X"00"; -- ×
        when 16#2d7# => romdata <= X"00"; -- ×
        when 16#3d7# => romdata <= X"00"; -- ×
        when 16#4d7# => romdata <= X"42"; -- ×
        when 16#5d7# => romdata <= X"24"; -- ×
        when 16#6d7# => romdata <= X"18"; -- ×
        when 16#7d7# => romdata <= X"18"; -- ×
        when 16#8d7# => romdata <= X"24"; -- ×
        when 16#9d7# => romdata <= X"42"; -- ×
        when 16#ad7# => romdata <= X"00"; -- ×
        when 16#bd7# => romdata <= X"00"; -- ×
        when 16#cd7# => romdata <= X"00"; -- ×
        when 16#0d8# => romdata <= X"00"; -- Ø
        when 16#1d8# => romdata <= X"02"; -- Ø
        when 16#2d8# => romdata <= X"3c"; -- Ø
        when 16#3d8# => romdata <= X"46"; -- Ø
        when 16#4d8# => romdata <= X"4a"; -- Ø
        when 16#5d8# => romdata <= X"4a"; -- Ø
        when 16#6d8# => romdata <= X"52"; -- Ø
        when 16#7d8# => romdata <= X"52"; -- Ø
        when 16#8d8# => romdata <= X"52"; -- Ø
        when 16#9d8# => romdata <= X"62"; -- Ø
        when 16#ad8# => romdata <= X"3c"; -- Ø
        when 16#bd8# => romdata <= X"40"; -- Ø
        when 16#cd8# => romdata <= X"00"; -- Ø
        when 16#0d9# => romdata <= X"00"; -- Ù
        when 16#1d9# => romdata <= X"20"; -- Ù
        when 16#2d9# => romdata <= X"10"; -- Ù
        when 16#3d9# => romdata <= X"00"; -- Ù
        when 16#4d9# => romdata <= X"42"; -- Ù
        when 16#5d9# => romdata <= X"42"; -- Ù
        when 16#6d9# => romdata <= X"42"; -- Ù
        when 16#7d9# => romdata <= X"42"; -- Ù
        when 16#8d9# => romdata <= X"42"; -- Ù
        when 16#9d9# => romdata <= X"42"; -- Ù
        when 16#ad9# => romdata <= X"3c"; -- Ù
        when 16#bd9# => romdata <= X"00"; -- Ù
        when 16#cd9# => romdata <= X"00"; -- Ù
        when 16#0da# => romdata <= X"00"; -- Ú
        when 16#1da# => romdata <= X"08"; -- Ú
        when 16#2da# => romdata <= X"10"; -- Ú
        when 16#3da# => romdata <= X"00"; -- Ú
        when 16#4da# => romdata <= X"42"; -- Ú
        when 16#5da# => romdata <= X"42"; -- Ú
        when 16#6da# => romdata <= X"42"; -- Ú
        when 16#7da# => romdata <= X"42"; -- Ú
        when 16#8da# => romdata <= X"42"; -- Ú
        when 16#9da# => romdata <= X"42"; -- Ú
        when 16#ada# => romdata <= X"3c"; -- Ú
        when 16#bda# => romdata <= X"00"; -- Ú
        when 16#cda# => romdata <= X"00"; -- Ú
        when 16#0db# => romdata <= X"00"; -- Û
        when 16#1db# => romdata <= X"18"; -- Û
        when 16#2db# => romdata <= X"24"; -- Û
        when 16#3db# => romdata <= X"00"; -- Û
        when 16#4db# => romdata <= X"42"; -- Û
        when 16#5db# => romdata <= X"42"; -- Û
        when 16#6db# => romdata <= X"42"; -- Û
        when 16#7db# => romdata <= X"42"; -- Û
        when 16#8db# => romdata <= X"42"; -- Û
        when 16#9db# => romdata <= X"42"; -- Û
        when 16#adb# => romdata <= X"3c"; -- Û
        when 16#bdb# => romdata <= X"00"; -- Û
        when 16#cdb# => romdata <= X"00"; -- Û
        when 16#0dc# => romdata <= X"00"; -- Ü
        when 16#1dc# => romdata <= X"24"; -- Ü
        when 16#2dc# => romdata <= X"24"; -- Ü
        when 16#3dc# => romdata <= X"00"; -- Ü
        when 16#4dc# => romdata <= X"42"; -- Ü
        when 16#5dc# => romdata <= X"42"; -- Ü
        when 16#6dc# => romdata <= X"42"; -- Ü
        when 16#7dc# => romdata <= X"42"; -- Ü
        when 16#8dc# => romdata <= X"42"; -- Ü
        when 16#9dc# => romdata <= X"42"; -- Ü
        when 16#adc# => romdata <= X"3c"; -- Ü
        when 16#bdc# => romdata <= X"00"; -- Ü
        when 16#cdc# => romdata <= X"00"; -- Ü
        when 16#0dd# => romdata <= X"00"; -- İ
        when 16#1dd# => romdata <= X"08"; -- İ
        when 16#2dd# => romdata <= X"10"; -- İ
        when 16#3dd# => romdata <= X"00"; -- İ
        when 16#4dd# => romdata <= X"44"; -- İ
        when 16#5dd# => romdata <= X"44"; -- İ
        when 16#6dd# => romdata <= X"28"; -- İ
        when 16#7dd# => romdata <= X"10"; -- İ
        when 16#8dd# => romdata <= X"10"; -- İ
        when 16#9dd# => romdata <= X"10"; -- İ
        when 16#add# => romdata <= X"10"; -- İ
        when 16#bdd# => romdata <= X"00"; -- İ
        when 16#cdd# => romdata <= X"00"; -- İ
        when 16#0de# => romdata <= X"00"; -- Ş
        when 16#1de# => romdata <= X"00"; -- Ş
        when 16#2de# => romdata <= X"40"; -- Ş
        when 16#3de# => romdata <= X"7c"; -- Ş
        when 16#4de# => romdata <= X"42"; -- Ş
        when 16#5de# => romdata <= X"42"; -- Ş
        when 16#6de# => romdata <= X"42"; -- Ş
        when 16#7de# => romdata <= X"7c"; -- Ş
        when 16#8de# => romdata <= X"40"; -- Ş
        when 16#9de# => romdata <= X"40"; -- Ş
        when 16#ade# => romdata <= X"40"; -- Ş
        when 16#bde# => romdata <= X"00"; -- Ş
        when 16#cde# => romdata <= X"00"; -- Ş
        when 16#0df# => romdata <= X"00"; -- ß
        when 16#1df# => romdata <= X"00"; -- ß
        when 16#2df# => romdata <= X"38"; -- ß
        when 16#3df# => romdata <= X"44"; -- ß
        when 16#4df# => romdata <= X"44"; -- ß
        when 16#5df# => romdata <= X"48"; -- ß
        when 16#6df# => romdata <= X"50"; -- ß
        when 16#7df# => romdata <= X"4c"; -- ß
        when 16#8df# => romdata <= X"42"; -- ß
        when 16#9df# => romdata <= X"42"; -- ß
        when 16#adf# => romdata <= X"5c"; -- ß
        when 16#bdf# => romdata <= X"00"; -- ß
        when 16#cdf# => romdata <= X"00"; -- ß
        when 16#0e0# => romdata <= X"00"; -- à
        when 16#1e0# => romdata <= X"00"; -- à
        when 16#2e0# => romdata <= X"10"; -- à
        when 16#3e0# => romdata <= X"08"; -- à
        when 16#4e0# => romdata <= X"00"; -- à
        when 16#5e0# => romdata <= X"3c"; -- à
        when 16#6e0# => romdata <= X"02"; -- à
        when 16#7e0# => romdata <= X"3e"; -- à
        when 16#8e0# => romdata <= X"42"; -- à
        when 16#9e0# => romdata <= X"46"; -- à
        when 16#ae0# => romdata <= X"3a"; -- à
        when 16#be0# => romdata <= X"00"; -- à
        when 16#ce0# => romdata <= X"00"; -- à
        when 16#0e1# => romdata <= X"00"; -- á
        when 16#1e1# => romdata <= X"00"; -- á
        when 16#2e1# => romdata <= X"04"; -- á
        when 16#3e1# => romdata <= X"08"; -- á
        when 16#4e1# => romdata <= X"00"; -- á
        when 16#5e1# => romdata <= X"3c"; -- á
        when 16#6e1# => romdata <= X"02"; -- á
        when 16#7e1# => romdata <= X"3e"; -- á
        when 16#8e1# => romdata <= X"42"; -- á
        when 16#9e1# => romdata <= X"46"; -- á
        when 16#ae1# => romdata <= X"3a"; -- á
        when 16#be1# => romdata <= X"00"; -- á
        when 16#ce1# => romdata <= X"00"; -- á
        when 16#0e2# => romdata <= X"00"; -- â
        when 16#1e2# => romdata <= X"00"; -- â
        when 16#2e2# => romdata <= X"18"; -- â
        when 16#3e2# => romdata <= X"24"; -- â
        when 16#4e2# => romdata <= X"00"; -- â
        when 16#5e2# => romdata <= X"3c"; -- â
        when 16#6e2# => romdata <= X"02"; -- â
        when 16#7e2# => romdata <= X"3e"; -- â
        when 16#8e2# => romdata <= X"42"; -- â
        when 16#9e2# => romdata <= X"46"; -- â
        when 16#ae2# => romdata <= X"3a"; -- â
        when 16#be2# => romdata <= X"00"; -- â
        when 16#ce2# => romdata <= X"00"; -- â
        when 16#0e3# => romdata <= X"00"; -- ã
        when 16#1e3# => romdata <= X"00"; -- ã
        when 16#2e3# => romdata <= X"32"; -- ã
        when 16#3e3# => romdata <= X"4c"; -- ã
        when 16#4e3# => romdata <= X"00"; -- ã
        when 16#5e3# => romdata <= X"3c"; -- ã
        when 16#6e3# => romdata <= X"02"; -- ã
        when 16#7e3# => romdata <= X"3e"; -- ã
        when 16#8e3# => romdata <= X"42"; -- ã
        when 16#9e3# => romdata <= X"46"; -- ã
        when 16#ae3# => romdata <= X"3a"; -- ã
        when 16#be3# => romdata <= X"00"; -- ã
        when 16#ce3# => romdata <= X"00"; -- ã
        when 16#0e4# => romdata <= X"00"; -- ä
        when 16#1e4# => romdata <= X"00"; -- ä
        when 16#2e4# => romdata <= X"24"; -- ä
        when 16#3e4# => romdata <= X"24"; -- ä
        when 16#4e4# => romdata <= X"00"; -- ä
        when 16#5e4# => romdata <= X"3c"; -- ä
        when 16#6e4# => romdata <= X"02"; -- ä
        when 16#7e4# => romdata <= X"3e"; -- ä
        when 16#8e4# => romdata <= X"42"; -- ä
        when 16#9e4# => romdata <= X"46"; -- ä
        when 16#ae4# => romdata <= X"3a"; -- ä
        when 16#be4# => romdata <= X"00"; -- ä
        when 16#ce4# => romdata <= X"00"; -- ä
        when 16#0e5# => romdata <= X"00"; -- å
        when 16#1e5# => romdata <= X"18"; -- å
        when 16#2e5# => romdata <= X"24"; -- å
        when 16#3e5# => romdata <= X"18"; -- å
        when 16#4e5# => romdata <= X"00"; -- å
        when 16#5e5# => romdata <= X"3c"; -- å
        when 16#6e5# => romdata <= X"02"; -- å
        when 16#7e5# => romdata <= X"3e"; -- å
        when 16#8e5# => romdata <= X"42"; -- å
        when 16#9e5# => romdata <= X"46"; -- å
        when 16#ae5# => romdata <= X"3a"; -- å
        when 16#be5# => romdata <= X"00"; -- å
        when 16#ce5# => romdata <= X"00"; -- å
        when 16#0e6# => romdata <= X"00"; -- æ
        when 16#1e6# => romdata <= X"00"; -- æ
        when 16#2e6# => romdata <= X"00"; -- æ
        when 16#3e6# => romdata <= X"00"; -- æ
        when 16#4e6# => romdata <= X"00"; -- æ
        when 16#5e6# => romdata <= X"6c"; -- æ
        when 16#6e6# => romdata <= X"12"; -- æ
        when 16#7e6# => romdata <= X"7c"; -- æ
        when 16#8e6# => romdata <= X"90"; -- æ
        when 16#9e6# => romdata <= X"92"; -- æ
        when 16#ae6# => romdata <= X"6c"; -- æ
        when 16#be6# => romdata <= X"00"; -- æ
        when 16#ce6# => romdata <= X"00"; -- æ
        when 16#0e7# => romdata <= X"00"; -- ç
        when 16#1e7# => romdata <= X"00"; -- ç
        when 16#2e7# => romdata <= X"00"; -- ç
        when 16#3e7# => romdata <= X"00"; -- ç
        when 16#4e7# => romdata <= X"00"; -- ç
        when 16#5e7# => romdata <= X"3c"; -- ç
        when 16#6e7# => romdata <= X"42"; -- ç
        when 16#7e7# => romdata <= X"40"; -- ç
        when 16#8e7# => romdata <= X"40"; -- ç
        when 16#9e7# => romdata <= X"42"; -- ç
        when 16#ae7# => romdata <= X"3c"; -- ç
        when 16#be7# => romdata <= X"08"; -- ç
        when 16#ce7# => romdata <= X"10"; -- ç
        when 16#0e8# => romdata <= X"00"; -- è
        when 16#1e8# => romdata <= X"00"; -- è
        when 16#2e8# => romdata <= X"10"; -- è
        when 16#3e8# => romdata <= X"08"; -- è
        when 16#4e8# => romdata <= X"00"; -- è
        when 16#5e8# => romdata <= X"3c"; -- è
        when 16#6e8# => romdata <= X"42"; -- è
        when 16#7e8# => romdata <= X"7e"; -- è
        when 16#8e8# => romdata <= X"40"; -- è
        when 16#9e8# => romdata <= X"42"; -- è
        when 16#ae8# => romdata <= X"3c"; -- è
        when 16#be8# => romdata <= X"00"; -- è
        when 16#ce8# => romdata <= X"00"; -- è
        when 16#0e9# => romdata <= X"00"; -- é
        when 16#1e9# => romdata <= X"00"; -- é
        when 16#2e9# => romdata <= X"08"; -- é
        when 16#3e9# => romdata <= X"10"; -- é
        when 16#4e9# => romdata <= X"00"; -- é
        when 16#5e9# => romdata <= X"3c"; -- é
        when 16#6e9# => romdata <= X"42"; -- é
        when 16#7e9# => romdata <= X"7e"; -- é
        when 16#8e9# => romdata <= X"40"; -- é
        when 16#9e9# => romdata <= X"42"; -- é
        when 16#ae9# => romdata <= X"3c"; -- é
        when 16#be9# => romdata <= X"00"; -- é
        when 16#ce9# => romdata <= X"00"; -- é
        when 16#0ea# => romdata <= X"00"; -- ê
        when 16#1ea# => romdata <= X"00"; -- ê
        when 16#2ea# => romdata <= X"18"; -- ê
        when 16#3ea# => romdata <= X"24"; -- ê
        when 16#4ea# => romdata <= X"00"; -- ê
        when 16#5ea# => romdata <= X"3c"; -- ê
        when 16#6ea# => romdata <= X"42"; -- ê
        when 16#7ea# => romdata <= X"7e"; -- ê
        when 16#8ea# => romdata <= X"40"; -- ê
        when 16#9ea# => romdata <= X"42"; -- ê
        when 16#aea# => romdata <= X"3c"; -- ê
        when 16#bea# => romdata <= X"00"; -- ê
        when 16#cea# => romdata <= X"00"; -- ê
        when 16#0eb# => romdata <= X"00"; -- ë
        when 16#1eb# => romdata <= X"00"; -- ë
        when 16#2eb# => romdata <= X"24"; -- ë
        when 16#3eb# => romdata <= X"24"; -- ë
        when 16#4eb# => romdata <= X"00"; -- ë
        when 16#5eb# => romdata <= X"3c"; -- ë
        when 16#6eb# => romdata <= X"42"; -- ë
        when 16#7eb# => romdata <= X"7e"; -- ë
        when 16#8eb# => romdata <= X"40"; -- ë
        when 16#9eb# => romdata <= X"42"; -- ë
        when 16#aeb# => romdata <= X"3c"; -- ë
        when 16#beb# => romdata <= X"00"; -- ë
        when 16#ceb# => romdata <= X"00"; -- ë
        when 16#0ec# => romdata <= X"00"; -- ì
        when 16#1ec# => romdata <= X"00"; -- ì
        when 16#2ec# => romdata <= X"20"; -- ì
        when 16#3ec# => romdata <= X"10"; -- ì
        when 16#4ec# => romdata <= X"00"; -- ì
        when 16#5ec# => romdata <= X"30"; -- ì
        when 16#6ec# => romdata <= X"10"; -- ì
        when 16#7ec# => romdata <= X"10"; -- ì
        when 16#8ec# => romdata <= X"10"; -- ì
        when 16#9ec# => romdata <= X"10"; -- ì
        when 16#aec# => romdata <= X"7c"; -- ì
        when 16#bec# => romdata <= X"00"; -- ì
        when 16#cec# => romdata <= X"00"; -- ì
        when 16#0ed# => romdata <= X"00"; -- í
        when 16#1ed# => romdata <= X"00"; -- í
        when 16#2ed# => romdata <= X"10"; -- í
        when 16#3ed# => romdata <= X"20"; -- í
        when 16#4ed# => romdata <= X"00"; -- í
        when 16#5ed# => romdata <= X"30"; -- í
        when 16#6ed# => romdata <= X"10"; -- í
        when 16#7ed# => romdata <= X"10"; -- í
        when 16#8ed# => romdata <= X"10"; -- í
        when 16#9ed# => romdata <= X"10"; -- í
        when 16#aed# => romdata <= X"7c"; -- í
        when 16#bed# => romdata <= X"00"; -- í
        when 16#ced# => romdata <= X"00"; -- í
        when 16#0ee# => romdata <= X"00"; -- î
        when 16#1ee# => romdata <= X"00"; -- î
        when 16#2ee# => romdata <= X"30"; -- î
        when 16#3ee# => romdata <= X"48"; -- î
        when 16#4ee# => romdata <= X"00"; -- î
        when 16#5ee# => romdata <= X"30"; -- î
        when 16#6ee# => romdata <= X"10"; -- î
        when 16#7ee# => romdata <= X"10"; -- î
        when 16#8ee# => romdata <= X"10"; -- î
        when 16#9ee# => romdata <= X"10"; -- î
        when 16#aee# => romdata <= X"7c"; -- î
        when 16#bee# => romdata <= X"00"; -- î
        when 16#cee# => romdata <= X"00"; -- î
        when 16#0ef# => romdata <= X"00"; -- ï
        when 16#1ef# => romdata <= X"00"; -- ï
        when 16#2ef# => romdata <= X"48"; -- ï
        when 16#3ef# => romdata <= X"48"; -- ï
        when 16#4ef# => romdata <= X"00"; -- ï
        when 16#5ef# => romdata <= X"30"; -- ï
        when 16#6ef# => romdata <= X"10"; -- ï
        when 16#7ef# => romdata <= X"10"; -- ï
        when 16#8ef# => romdata <= X"10"; -- ï
        when 16#9ef# => romdata <= X"10"; -- ï
        when 16#aef# => romdata <= X"7c"; -- ï
        when 16#bef# => romdata <= X"00"; -- ï
        when 16#cef# => romdata <= X"00"; -- ï
        when 16#0f0# => romdata <= X"00"; -- ğ
        when 16#1f0# => romdata <= X"24"; -- ğ
        when 16#2f0# => romdata <= X"18"; -- ğ
        when 16#3f0# => romdata <= X"28"; -- ğ
        when 16#4f0# => romdata <= X"04"; -- ğ
        when 16#5f0# => romdata <= X"3c"; -- ğ
        when 16#6f0# => romdata <= X"42"; -- ğ
        when 16#7f0# => romdata <= X"42"; -- ğ
        when 16#8f0# => romdata <= X"42"; -- ğ
        when 16#9f0# => romdata <= X"42"; -- ğ
        when 16#af0# => romdata <= X"3c"; -- ğ
        when 16#bf0# => romdata <= X"00"; -- ğ
        when 16#cf0# => romdata <= X"00"; -- ğ
        when 16#0f1# => romdata <= X"00"; -- ñ
        when 16#1f1# => romdata <= X"00"; -- ñ
        when 16#2f1# => romdata <= X"32"; -- ñ
        when 16#3f1# => romdata <= X"4c"; -- ñ
        when 16#4f1# => romdata <= X"00"; -- ñ
        when 16#5f1# => romdata <= X"5c"; -- ñ
        when 16#6f1# => romdata <= X"62"; -- ñ
        when 16#7f1# => romdata <= X"42"; -- ñ
        when 16#8f1# => romdata <= X"42"; -- ñ
        when 16#9f1# => romdata <= X"42"; -- ñ
        when 16#af1# => romdata <= X"42"; -- ñ
        when 16#bf1# => romdata <= X"00"; -- ñ
        when 16#cf1# => romdata <= X"00"; -- ñ
        when 16#0f2# => romdata <= X"00"; -- ò
        when 16#1f2# => romdata <= X"00"; -- ò
        when 16#2f2# => romdata <= X"20"; -- ò
        when 16#3f2# => romdata <= X"10"; -- ò
        when 16#4f2# => romdata <= X"00"; -- ò
        when 16#5f2# => romdata <= X"3c"; -- ò
        when 16#6f2# => romdata <= X"42"; -- ò
        when 16#7f2# => romdata <= X"42"; -- ò
        when 16#8f2# => romdata <= X"42"; -- ò
        when 16#9f2# => romdata <= X"42"; -- ò
        when 16#af2# => romdata <= X"3c"; -- ò
        when 16#bf2# => romdata <= X"00"; -- ò
        when 16#cf2# => romdata <= X"00"; -- ò
        when 16#0f3# => romdata <= X"00"; -- ó
        when 16#1f3# => romdata <= X"00"; -- ó
        when 16#2f3# => romdata <= X"08"; -- ó
        when 16#3f3# => romdata <= X"10"; -- ó
        when 16#4f3# => romdata <= X"00"; -- ó
        when 16#5f3# => romdata <= X"3c"; -- ó
        when 16#6f3# => romdata <= X"42"; -- ó
        when 16#7f3# => romdata <= X"42"; -- ó
        when 16#8f3# => romdata <= X"42"; -- ó
        when 16#9f3# => romdata <= X"42"; -- ó
        when 16#af3# => romdata <= X"3c"; -- ó
        when 16#bf3# => romdata <= X"00"; -- ó
        when 16#cf3# => romdata <= X"00"; -- ó
        when 16#0f4# => romdata <= X"00"; -- ô
        when 16#1f4# => romdata <= X"00"; -- ô
        when 16#2f4# => romdata <= X"18"; -- ô
        when 16#3f4# => romdata <= X"24"; -- ô
        when 16#4f4# => romdata <= X"00"; -- ô
        when 16#5f4# => romdata <= X"3c"; -- ô
        when 16#6f4# => romdata <= X"42"; -- ô
        when 16#7f4# => romdata <= X"42"; -- ô
        when 16#8f4# => romdata <= X"42"; -- ô
        when 16#9f4# => romdata <= X"42"; -- ô
        when 16#af4# => romdata <= X"3c"; -- ô
        when 16#bf4# => romdata <= X"00"; -- ô
        when 16#cf4# => romdata <= X"00"; -- ô
        when 16#0f5# => romdata <= X"00"; -- õ
        when 16#1f5# => romdata <= X"00"; -- õ
        when 16#2f5# => romdata <= X"32"; -- õ
        when 16#3f5# => romdata <= X"4c"; -- õ
        when 16#4f5# => romdata <= X"00"; -- õ
        when 16#5f5# => romdata <= X"3c"; -- õ
        when 16#6f5# => romdata <= X"42"; -- õ
        when 16#7f5# => romdata <= X"42"; -- õ
        when 16#8f5# => romdata <= X"42"; -- õ
        when 16#9f5# => romdata <= X"42"; -- õ
        when 16#af5# => romdata <= X"3c"; -- õ
        when 16#bf5# => romdata <= X"00"; -- õ
        when 16#cf5# => romdata <= X"00"; -- õ
        when 16#0f6# => romdata <= X"00"; -- ö
        when 16#1f6# => romdata <= X"00"; -- ö
        when 16#2f6# => romdata <= X"24"; -- ö
        when 16#3f6# => romdata <= X"24"; -- ö
        when 16#4f6# => romdata <= X"00"; -- ö
        when 16#5f6# => romdata <= X"3c"; -- ö
        when 16#6f6# => romdata <= X"42"; -- ö
        when 16#7f6# => romdata <= X"42"; -- ö
        when 16#8f6# => romdata <= X"42"; -- ö
        when 16#9f6# => romdata <= X"42"; -- ö
        when 16#af6# => romdata <= X"3c"; -- ö
        when 16#bf6# => romdata <= X"00"; -- ö
        when 16#cf6# => romdata <= X"00"; -- ö
        when 16#0f7# => romdata <= X"00"; -- ÷
        when 16#1f7# => romdata <= X"00"; -- ÷
        when 16#2f7# => romdata <= X"00"; -- ÷
        when 16#3f7# => romdata <= X"10"; -- ÷
        when 16#4f7# => romdata <= X"10"; -- ÷
        when 16#5f7# => romdata <= X"00"; -- ÷
        when 16#6f7# => romdata <= X"7c"; -- ÷
        when 16#7f7# => romdata <= X"00"; -- ÷
        when 16#8f7# => romdata <= X"10"; -- ÷
        when 16#9f7# => romdata <= X"10"; -- ÷
        when 16#af7# => romdata <= X"00"; -- ÷
        when 16#bf7# => romdata <= X"00"; -- ÷
        when 16#cf7# => romdata <= X"00"; -- ÷
        when 16#0f8# => romdata <= X"00"; -- ø
        when 16#1f8# => romdata <= X"00"; -- ø
        when 16#2f8# => romdata <= X"00"; -- ø
        when 16#3f8# => romdata <= X"00"; -- ø
        when 16#4f8# => romdata <= X"02"; -- ø
        when 16#5f8# => romdata <= X"3c"; -- ø
        when 16#6f8# => romdata <= X"46"; -- ø
        when 16#7f8# => romdata <= X"4a"; -- ø
        when 16#8f8# => romdata <= X"52"; -- ø
        when 16#9f8# => romdata <= X"62"; -- ø
        when 16#af8# => romdata <= X"3c"; -- ø
        when 16#bf8# => romdata <= X"40"; -- ø
        when 16#cf8# => romdata <= X"00"; -- ø
        when 16#0f9# => romdata <= X"00"; -- ù
        when 16#1f9# => romdata <= X"00"; -- ù
        when 16#2f9# => romdata <= X"20"; -- ù
        when 16#3f9# => romdata <= X"10"; -- ù
        when 16#4f9# => romdata <= X"00"; -- ù
        when 16#5f9# => romdata <= X"44"; -- ù
        when 16#6f9# => romdata <= X"44"; -- ù
        when 16#7f9# => romdata <= X"44"; -- ù
        when 16#8f9# => romdata <= X"44"; -- ù
        when 16#9f9# => romdata <= X"44"; -- ù
        when 16#af9# => romdata <= X"3a"; -- ù
        when 16#bf9# => romdata <= X"00"; -- ù
        when 16#cf9# => romdata <= X"00"; -- ù
        when 16#0fa# => romdata <= X"00"; -- ú
        when 16#1fa# => romdata <= X"00"; -- ú
        when 16#2fa# => romdata <= X"08"; -- ú
        when 16#3fa# => romdata <= X"10"; -- ú
        when 16#4fa# => romdata <= X"00"; -- ú
        when 16#5fa# => romdata <= X"44"; -- ú
        when 16#6fa# => romdata <= X"44"; -- ú
        when 16#7fa# => romdata <= X"44"; -- ú
        when 16#8fa# => romdata <= X"44"; -- ú
        when 16#9fa# => romdata <= X"44"; -- ú
        when 16#afa# => romdata <= X"3a"; -- ú
        when 16#bfa# => romdata <= X"00"; -- ú
        when 16#cfa# => romdata <= X"00"; -- ú
        when 16#0fb# => romdata <= X"00"; -- û
        when 16#1fb# => romdata <= X"00"; -- û
        when 16#2fb# => romdata <= X"18"; -- û
        when 16#3fb# => romdata <= X"24"; -- û
        when 16#4fb# => romdata <= X"00"; -- û
        when 16#5fb# => romdata <= X"44"; -- û
        when 16#6fb# => romdata <= X"44"; -- û
        when 16#7fb# => romdata <= X"44"; -- û
        when 16#8fb# => romdata <= X"44"; -- û
        when 16#9fb# => romdata <= X"44"; -- û
        when 16#afb# => romdata <= X"3a"; -- û
        when 16#bfb# => romdata <= X"00"; -- û
        when 16#cfb# => romdata <= X"00"; -- û
        when 16#0fc# => romdata <= X"00"; -- ü
        when 16#1fc# => romdata <= X"00"; -- ü
        when 16#2fc# => romdata <= X"28"; -- ü
        when 16#3fc# => romdata <= X"28"; -- ü
        when 16#4fc# => romdata <= X"00"; -- ü
        when 16#5fc# => romdata <= X"44"; -- ü
        when 16#6fc# => romdata <= X"44"; -- ü
        when 16#7fc# => romdata <= X"44"; -- ü
        when 16#8fc# => romdata <= X"44"; -- ü
        when 16#9fc# => romdata <= X"44"; -- ü
        when 16#afc# => romdata <= X"3a"; -- ü
        when 16#bfc# => romdata <= X"00"; -- ü
        when 16#cfc# => romdata <= X"00"; -- ü
        when 16#0fd# => romdata <= X"00"; -- ı
        when 16#1fd# => romdata <= X"00"; -- ı
        when 16#2fd# => romdata <= X"08"; -- ı
        when 16#3fd# => romdata <= X"10"; -- ı
        when 16#4fd# => romdata <= X"00"; -- ı
        when 16#5fd# => romdata <= X"42"; -- ı
        when 16#6fd# => romdata <= X"42"; -- ı
        when 16#7fd# => romdata <= X"42"; -- ı
        when 16#8fd# => romdata <= X"46"; -- ı
        when 16#9fd# => romdata <= X"3a"; -- ı
        when 16#afd# => romdata <= X"02"; -- ı
        when 16#bfd# => romdata <= X"42"; -- ı
        when 16#cfd# => romdata <= X"3c"; -- ı
        when 16#0fe# => romdata <= X"00"; -- ş
        when 16#1fe# => romdata <= X"00"; -- ş
        when 16#2fe# => romdata <= X"00"; -- ş
        when 16#3fe# => romdata <= X"40"; -- ş
        when 16#4fe# => romdata <= X"40"; -- ş
        when 16#5fe# => romdata <= X"5c"; -- ş
        when 16#6fe# => romdata <= X"62"; -- ş
        when 16#7fe# => romdata <= X"42"; -- ş
        when 16#8fe# => romdata <= X"42"; -- ş
        when 16#9fe# => romdata <= X"62"; -- ş
        when 16#afe# => romdata <= X"5c"; -- ş
        when 16#bfe# => romdata <= X"40"; -- ş
        when 16#cfe# => romdata <= X"40"; -- ş
        when 16#0ff# => romdata <= X"00"; -- ÿ
        when 16#1ff# => romdata <= X"00"; -- ÿ
        when 16#2ff# => romdata <= X"24"; -- ÿ
        when 16#3ff# => romdata <= X"24"; -- ÿ
        when 16#4ff# => romdata <= X"00"; -- ÿ
        when 16#5ff# => romdata <= X"42"; -- ÿ
        when 16#6ff# => romdata <= X"42"; -- ÿ
        when 16#7ff# => romdata <= X"42"; -- ÿ
        when 16#8ff# => romdata <= X"46"; -- ÿ
        when 16#9ff# => romdata <= X"3a"; -- ÿ
        when 16#aff# => romdata <= X"02"; -- ÿ
        when 16#bff# => romdata <= X"42"; -- ÿ
        when 16#cff# => romdata <= X"3c"; -- ÿ
        when others => romdata <= (others => '0');
end case;
end process;

end architecture;
	
