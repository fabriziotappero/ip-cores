----==============================================================----
----                                                              ----
---- Filename: cmpeq.vhd                                          ----
---- Module description: Equality comparator                      ----
----                                                              ----
---- Author: Nikolaos Kavvadias                                   ----
----         nkavv@skiathos.physics.auth.gr                       ----
----                                                              ---- 
----                                                              ----
---- Downloaded from: http://wwww.opencores.org/cores/hwlu        ----
----                                                              ----
---- To Do:                                                       ----
----         Probably remains as current                          ---- 
----         (to promote as stable version)                       ----
----                                                              ----
---- Author: Nikolaos Kavvadias                                   ----
----         nkavv@skiathos.physics.auth.gr                       ----
----                                                              ----
----==============================================================----
----                                                              ----
---- Copyright (C) 2004 Nikolaos Kavvadias                        ----
----                    nick-kavi.8m.com                          ----
----                    nkavv@skiathos.physics.auth.gr            ----
----                    nick_ka_vi@hotmail.com                    ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from <http://www.opencores.org/lgpl.shtml>                   ----
----                                                              ----
----==============================================================----
--
-- CVS Revision History
--    

library IEEE;
use IEEE.std_logic_1164.all;				   


entity cmpeq is		
  generic (
    DW : integer := 8
  );
  port (
    a      : in std_logic_vector(DW-1 downto 0);
    b      : in std_logic_vector(DW-1 downto 0);	
	reset  : in std_logic;
    a_eq_b : out std_logic
  );
end cmpeq;

architecture rtl of cmpeq is
begin
  --
  a_eq_b <= '1' when (a = b and reset = '0') else '0';
  --
end rtl;
