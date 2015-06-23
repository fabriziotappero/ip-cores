-----------------------------------------------------------------------
----                                                               ----
----                                                               ----
---- This file is part of the big_counter project                  ----
---- http://www.opencores.org/cores/big_counter                    ----
----                                                               ----
---- Description                                                   ----
---- Implementation of a large counter made of SRL's               ----
----                                                               ----
----                                                               ----
---- To Do:                                                        ----
----    NA                                                         ----
----                                                               ----
---- Author(s):                                                    ----
----   Andrew Mulcock, amulcock@opencores.org                      ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2007 Authors and OPENCORES.ORG                  ----
----                                                               ----
---- This source file may be used and distributed without          ----
---- restriction provided that this copyright statement is not     ----
---- removed from the file and that any derivative work contains   ----
---- the original copyright notice and the associated disclaimer.  ----
----                                                               ----
---- This source file is free software; you can redistribute it    ----
---- and/or modify it under the terms of the GNU Lesser General    ----
---- Public License as published by the Free Software Foundation;  ----
---- either version 2.1 of the License, or (at your option) any    ----
---- later version.                                                ----
----                                                               ----
---- This source is distributed in the hope that it will be        ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied    ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR       ----
---- PURPOSE. See the GNU Lesser General Public License for more   ----
---- details.                                                      ----
----                                                               ----
---- You should have received a copy of the GNU Lesser General     ----
---- Public License along with this source; if not, download it    ----
---- from http://www.opencores.org/lgpl.shtml                      ----
----                                                               ----
-----------------------------------------------------------------------
--                                                                 ----
-- CVS Revision History                                            ----
--                                                                 ----
-- $Log: not supported by cvs2svn $                                                           ----
--                                                                 ----



library ieee;
use ieee.std_logic_1164.all;

entity am_srl_counter_rtl is
   generic (
      no_of_stages : integer := 200
           );
   port( clk   : in std_logic;
         en_in : in std_logic;
         rco   : out std_logic_vector ( no_of_stages - 1 downto 0)
       );
end am_srl_counter_rtl;

architecture Behavioral of am_srl_counter_rtl is


type	shift_counter_type is array ( no_of_stages - 1 downto 0 ) of STD_LOGIC_VECTOR ( 15 downto 0 ) ;

signal	shift_srl	: shift_counter_type := ( others => X"0001" );
signal   clk_en      : std_logic_vector ( no_of_stages - 1 downto 0) := ( others => '0');
signal   rco_int     : std_logic_vector ( no_of_stages - 1 downto 0) := ( others => '0');


begin


gen_srls : for n in 0 to no_of_stages - 1 generate

  tap_a: if n = 0 generate
   clk_en(n) <= en_in;
   srl_proc_a :process (clk)
      begin
      if rising_edge( clk ) then
        if clk_en(n) = '1' then
            shift_srl(n) <= shift_srl(n)(shift_srl(n)'left-1 downto 0) & shift_srl(n)(shift_srl(n)'left);
        end if;
      end if;
   end process srl_proc_a;
   rco_int(n) <= shift_srl(n)(shift_srl(n)'left);
  end generate tap_a;

               
  tap_b: if n = 1 generate
   clk_en(n) <= rco_int(n-1) and en_in;
   srl_proc_b :process (clk)
      begin
      if rising_edge( clk) then
         if clk_en(n) = '1' then         
             shift_srl(n) <= shift_srl(n)(shift_srl(n)'left-1 downto 0) & shift_srl(n)(shift_srl(n)'left);
         end if;
      end if;
   end process srl_proc_b;
   rco_int(n) <= en_in and shift_srl(n)(shift_srl(n)'left);
  end generate tap_b; 
 
  tap_cp: if n > 1 generate
   clk_en(n) <= rco_int(n-1) and rco_int(0);
   srl_proc_c :process (clk)
      begin
      if rising_edge( clk) then
         if clk_en(n) = '1' then
             shift_srl(n) <= shift_srl(n)(shift_srl(n)'left-1 downto 0) & shift_srl(n)(shift_srl(n)'left);
         end if;
      end if;
   end process srl_proc_c;
   rco_int(n) <= rco_int(n-1) and shift_srl(n)(shift_srl(n)'left);
  end generate tap_cp;

rco <= rco_int;


end generate gen_srls;


end Behavioral;
