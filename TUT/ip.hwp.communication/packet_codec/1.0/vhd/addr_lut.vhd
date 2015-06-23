-------------------------------------------------------------------------------
-- Title      : LUT to transform HIBI address into net addresses
-- Project    : 
-------------------------------------------------------------------------------
-- File       : addr_lut.vhd
-- Author     : 
-- Company    : 
-- Created    : 2006-08-07
-- Last update: 2011-12-01
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Ks Title
-- Revisions  :
-- Date        Version  Author  Description
-- 2006-08-07  1.0      rasmusa Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

--use ieee.std_logic_arith.all;

-- net_type_g: 0 - HIBI (reserved. does nothing)
--             1 - 2D MESH
--             2 - Octagon
--             3 - Crossbar

use work.addr_lut_pkg.all;

-------------------------------------------------------------------------------
entity addr_lut is
  -----------------------------------------------------------------------------
  generic (
    in_addr_w_g  : integer := 32;
    out_addr_w_g : integer := 36;
    cmp_high_g   : integer := 31;
    cmp_low_g    : integer := 0;
    net_type_g   : integer := 1;
    lut_en_g     : integer := 1         -- if disabled (en=0), out_addr <= in_addr
    );
  port (
    addr_in  : in  std_logic_vector(in_addr_w_g-1 downto 0);
    addr_out : out std_logic_vector(out_addr_w_g-1 downto 0)
    );
end addr_lut;

-------------------------------------------------------------------------------
architecture rtl of addr_lut is
-------------------------------------------------------------------------------

  constant res_addr_table_c : res_addr_array := gen_result_addresses(num_table_c, net_type_g);
  
begin  -- rtl

--  cmp_proc : process (addr_in)
--    variable found_addr_v : integer;
--    variable zero_vect_v : std_logic_vector( in_addr_w_g-1 downto 0 ) := (others => '0');
--  begin  -- process cmp_proc
--    addr_out <= (others => '0');
--    found_addr_v := 0;

    
--    -- if LUT is disabled
--    if lut_en_g = 0 then
--      if in_addr_w_g > out_addr_w_g then
--        addr_out <= addr_in(out_addr_w_g-1 downto 0);
--      else
--        addr_out(in_addr_w_g-1 downto 0) <= addr_in;
--      end if;
--      found_addr_v := 1;
      
--    else
--      -- if LUT is enabled
--      for i in 0 to n_addr_ranges_c-1 loop

--        if ((addr_in(cmp_high_g downto cmp_low_g) and
--             addr_table_c(i).mask(cmp_high_g downto cmp_low_g)) = addr_table_c(i).in_addr(cmp_high_g downto cmp_low_g)) then

--          addr_out <= (others => '0');
--          addr_out(out_addr_w_c-1 downto 0) <= res_addr_table_c(i)(out_addr_w_c - 1 downto 0);
--          found_addr_v := 1;

--        end if;
--      end loop;  -- i
--    end if;
----    assert (found_addr_v = 1) or (addr_in = zero_vect_v) report "Address not found: " & hstr(addr_in) severity error;
--  end process cmp_proc;
  -- Fix: make two processes with if-generate
  in_ad_narrower: if in_addr_w_g <= out_addr_w_g generate
    cmp_proc1 : process (addr_in)
    begin  -- process cmp_proc
      addr_out <= (others => '0');

      -- if LUT is disabled
      if lut_en_g = 0 then
          addr_out (out_addr_w_g-1 downto in_addr_w_g) <= (others => '0');
          addr_out (in_addr_w_g-1 downto 0)            <= addr_in(in_addr_w_g-1 downto 0);
          -- The above line was troublesome with regualr if (works with if-generate)
      else
        -- if LUT is enabled

        for i in 0 to n_addr_ranges_c-1 loop
          if ((addr_in (cmp_high_g downto cmp_low_g)
               and addr_table_c(i).mask (cmp_high_g downto cmp_low_g))
              = addr_table_c (i).in_addr (cmp_high_g downto cmp_low_g))
          then
            addr_out <= res_addr_table_c(i)(out_addr_w_g - 1 downto 0);
          end if;
        end loop;  -- i

      end if;
      
    end process cmp_proc1;

  end generate in_ad_narrower;

  

  in_ad_wider: if in_addr_w_g > out_addr_w_g generate
    cmp_proc1 : process (addr_in)
    begin  -- process cmp_proc
      addr_out <= (others => '0');

      -- if LUT is disabled
      if lut_en_g = 0 then
        -- Sis‰‰nmeno leve‰mpi
        addr_out <= addr_in(out_addr_w_g-1 downto 0);

      else
        -- if LUT is enabled

        for i in 0 to n_addr_ranges_c-1 loop
          if ((addr_in (cmp_high_g downto cmp_low_g)
               and addr_table_c(i).mask (cmp_high_g downto cmp_low_g))
              = addr_table_c (i).in_addr (cmp_high_g downto cmp_low_g))
          then
            addr_out <= res_addr_table_c(i)(out_addr_w_g - 1 downto 0);
          end if;
        end loop;  -- i

      end if;
      
    end process cmp_proc1;

  end generate in_ad_wider;

end rtl;
