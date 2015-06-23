----==============================================================----
----                                                              ----
---- Filename: csa8.vhd                                           ----
---- Module description: Top-level module of 8-bit carry-select   ----
----                     adder                                    ----
----                                                              ----
---- Author: Nikolaos Kavvadias                                   ----
----         nkavv@skiathos.physics.auth.gr                       ----
----                                                              ---- 
----                                                              ----
---- Downloaded from: http://wwww.opencores.org/cores/hwlu        ----
----                                                              ----
---- To Do:                                                       ----
----         Add a parameterized version of a fast adder          ---- 
----         (probably a carry select adder).                     ----
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
       
       
entity add is 
  generic (
    DW : integer := 8
  );
  port (
    a   : in std_logic_vector(DW-1 downto 0);
    b   : in std_logic_vector(DW-1 downto 0);
    sum : out std_logic_vector(DW-1 downto 0)
  );
end add;

architecture structural of add is
-- Component declarations
component fa
  port (
    a  : in std_logic;
    b  : in std_logic;
    ci : in std_logic;
    s  : out std_logic;
    co : out std_logic
  );
end component;
--             
component mux2_1
  generic (
    DW : integer := 8
  );
  port (
    in0  : in std_logic_vector(DW-1 downto 0);
    in1  : in std_logic_vector(DW-1 downto 0);
    sel  : in std_logic;
	mout : out std_logic_vector(DW-1 downto 0)
  );
end component;                        
--                              
-- Constant declarations
constant zero_1b : std_logic := '0';
constant one_1b  : std_logic := '1';
--
-- Signal declarations
signal carry : std_logic_vector(4 downto 0);
signal c_up_ci0 : std_logic_vector(4 downto 0);
signal c_up_ci1 : std_logic_vector(4 downto 0);
signal s_up_ci0 : std_logic_vector(3 downto 0);
signal s_up_ci1 : std_logic_vector(3 downto 0);
--
begin		
  
  carry(0) <= '0';               
  --
           
  U_fa0_3_cells : for i in 0 to 3 generate
    U_fa : fa 
      port map (
        a => a(i),
        b => b(i),
        ci => carry(i),
        s => sum(i),
        co => carry(i+1)
      );
  end generate U_fa0_3_cells;
  
  c_up_ci0(0) <= zero_1b;
  c_up_ci1(0) <= one_1b;
         
  U_fa4_7_ci0_cells : for i in 0 to 3 generate
    U_fa : fa 
      port map (
        a => a(i+4),
        b => b(i+4),
        ci => c_up_ci0(i),
        s => s_up_ci0(i),
        co => c_up_ci0(i+1)
      );
  end generate U_fa4_7_ci0_cells;

  U_fa4_7_ci1_cells : for i in 0 to 3 generate
    U_fa : fa 
      port map (
        a => a(i+4),
        b => b(i+4),
        ci => c_up_ci1(i),
        s => s_up_ci1(i),
        co => c_up_ci1(i+1)
      );
  end generate U_fa4_7_ci1_cells;
  
  U_mux_s_up : mux2_1 
    generic map (
      DW => 4
    )
    port map (
      in0 => s_up_ci0(3 downto 0),
      in1 => s_up_ci1(3 downto 0),
      sel => carry(4),
      mout => sum(7 downto 4)
    );
    
end structural;
