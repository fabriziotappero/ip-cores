----==============================================================----
----                                                              ----
---- Filename: mux2_1.vhd                                         ----
---- Module description: 2-to-1 DW-bit multiplexer                ----
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


entity mux2_1 is			
  generic (
    DW : integer := 8
  );
  port (
    in0  : in std_logic_vector(DW-1 downto 0);
    in1  : in std_logic_vector(DW-1 downto 0);
    sel  : in std_logic;
	mout : out std_logic_vector(DW-1 downto 0)
  );
end mux2_1;                        


architecture rtl of mux2_1 is
begin
  process (sel, in0, in1) 
  begin							
	  case sel is
		  when '0' => mout <= in0;
		  when others => mout <= in1;
	  end case;
  end process;
  --
end rtl;
