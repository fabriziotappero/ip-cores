----==============================================================----
----                                                              ----
---- Filename: index_inc.vhd                                      ----
---- Module description: Index increment-by-one unit              ----
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
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity index_inc is
  generic (
    DW : integer := 8
  );
  port (
    clk            : in std_logic;
    reset          : in std_logic;
    inc_en         : in std_logic;			
	index_plus_one : out std_logic_vector(Dw-1 downto 0);
    index_out      : out std_logic_vector(DW-1 downto 0)
  );
end index_inc;

architecture rtl of index_inc is  
--
-- Component declarations
component add	  
  generic (
    DW : integer := 8
  );
  port (
    a   : in std_logic_vector(DW-1 downto 0);
    b   : in std_logic_vector(DW-1 downto 0);
    sum : out std_logic_vector(DW-1 downto 0)
  );
end component;
--
component reg_dw
  generic (
    DW : integer := 8
  );
  port (			  
    clk   : in std_logic;
    reset : in std_logic;
    load  : in std_logic;
    d     : in std_logic_vector(DW-1 downto 0);
    q     : out std_logic_vector(DW-1 downto 0)
  );
end component;
--  
-- Constant declarations
constant one_dw : std_logic_vector(DW-1 downto 0) := conv_std_logic_vector(1,DW);
--
-- Signal declarations
signal index_rin, index_r : std_logic_vector(DW-1 downto 0);
--
begin		  
  
  U_adder : add					   
    generic map (
	  DW => DW
	)
    port map (
      a => index_r,                            
      b => one_dw,
      sum => index_rin
    );

  U_reg_dw : reg_dw
    generic map (
      DW => DW
    )
    port map (
      clk => clk,
      reset => reset,
      load => inc_en,
      d => index_rin,
      q => index_r
    );            
    
  index_out <= index_r;
  index_plus_one <= index_rin;
	
end rtl;
