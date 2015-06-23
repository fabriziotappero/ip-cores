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
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--use work.txt_util.all;

-------------------------------------------------------------------------------
package addr_lut_pkg is
-------------------------------------------------------------------------------


-- Number of net types
  constant n_net_types_c : integer := 4;

  constant addr_w_c     : integer := 36;
  constant out_addr_w_c : integer := 36;

  type addr_rec is record
    in_addr : std_logic_vector(addr_w_c-1 downto 0);
    mask    : std_logic_vector(addr_w_c-1 downto 0);
  end record;

  constant n_addr_ranges_c : integer := 17;

  type address_array is array (0 to n_addr_ranges_c-1) of addr_rec;

  type number_record is record
    x : integer;
    y : integer;
    z : integer;
  end record;

  type number_array is array (0 to n_net_types_c-1, 0 to n_addr_ranges_c-1) of number_record;

  type res_addr_array is array (0 to n_addr_ranges_c-1) of std_logic_vector(out_addr_w_c-1 downto 0);

  -- Function for initializing address table
  -- nodes have at most three coordinates (x,y,z)
  -- that are translated differently according to net_type.
  -- All nets do not have 3 coordinates, e.g. 2D-mesh has only 2
  function gen_result_addresses (
    constant numb_arr : number_array;
    constant net_type : integer range 0 to n_net_types_c-1)
    return res_addr_array;

  function get_num (
    constant addr     : std_logic_vector(addr_w_c-1 downto 0);
    constant net_type : integer)
    return number_record;


  -- Input addresses: received addr is compared against this table.
  constant addr_table_c : address_array :=
    (
      (x"00b000100", x"0ffffff00"),
      (x"00b000300", x"0ffffff00"),
      (x"00b000500", x"0ffffff00"),
      (x"00b000700", x"0ffffff00"),
      (x"00b000900", x"0ffffff00"),
      (x"00b000b00", x"0ffffff00"),
      (x"00b000d00", x"0ffffff00"),
      (x"00b000f00", x"0ffffff00"),
      (x"00b001100", x"0ffffff00"),
      (x"00b001300", x"0ffffff00"),
      (x"00bfffe00", x"0fffffe00"),
      (x"109000000", x"1ff000000"),
      (x"009000000", x"1ff000000"),
      (x"00bfedd00", x"0ffffff00"),
      (x"00bfedf00", x"0ffffff00"),
      (x"00bfefd00", x"0ffffff00"),
      (x"00bfeff00", x"0ffffff00")
      );


  constant num_table_c : number_array :=
    (
      (                                 -- HIBI (useless, reserved)
        (0, -1, -1),                     --MASTER     
        (1, -1, -1),                     --Slave1
        (2, -1, -1),                     --Slave2
        (3, -1, -1),                     --Slave3
        (4, -1, -1),                     --Slave4
        (5, -1, -1),                     --Slave5
        (6, -1, -1),                     --Slave6
        (7, -1, -1),                     --Slave7
        (8, -1, -1),                     --Slave8
        (9, -1, -1),                     --Slave9
        (10, -1, -1),                     --SDRAM_msg
        (11, -1, -1),                     --SDRAM_data
        (12, -1, -1),                     --RTM
        (13, -1, -1),                     --ME 2
        (14, -1, -1),                     --ME 1
        (15, -1, -1),                     --dctQidct 2
        (16, -1, -1)                      --dctQidct 1      
        ),
      (                                 -- MESH:      
        (0, 0, -1),                     --MASTER     
        (1, 0, -1),                     --Slave1
        (2, 0, -1),                     --Slave2
        (3, 0, -1),                     --Slave3
        (0, 1, -1),                     --Slave4
        (1, 1, -1),                     --Slave5
        (2, 1, -1),                     --Slave6
        (3, 1, -1),                     --Slave7
        (0, 2, -1),                     --Slave8
        (1, 2, -1),                     --Slave9
        (2, 2, -1),                     --SDRAM_msg
        (3, 2, -1),                     --SDRAM_data
        (0, 3, -1),                     --RTM
        (1, 3, -1),                     --ME 2
        (2, 3, -1),                     --ME 1
        (3, 3, -1),                     --dctQidct 2
        (0, 4, -1)                      --dctQidct 1      
        ),
      (                                 -- Octagon:
        (0, 0, 0),                      --MASTER     
        (0, 0, 0),                      --Slave1
        (0, 0, 0),                      --Slave2
        (0, 0, 0),                      --Slave3
        (0, 0, 0),                      --Slave4
        (0, 0, 0),                      --Slave5
        (0, 0, 0),                      --Slave6
        (0, 0, 0),                      --Slave7
        (0, 0, 0),                      --Slave8
        (0, 0, 0),                      --Slave9
        (0, 0, 0),                      --RTM
        (0, 0, 0),                      --SDRAM_msg
        (0, 0, 0),                      --SDRAM_data
        (0, 0, 0),                      --ME 2
        (0, 0, 0),                      --ME 1
        (0, 0, 0),                      --dctQidct 2
        (0, 0, 0)                       --dctQidct 1 
        ),
      (                                 -- Crossbar:
        (0, 0, 0),                      --MASTER     
        (0, 0, 1),                      --Slave1
        (0, 0, 2),                      --Slave2
        (0, 0, 3),                      --Slave3
        (0, 0, 4),                      --Slave4
        (0, 0, 5),                      --Slave5
        (0, 0, 6),                      --Slave6
        (0, 0, 7),                      --Slave7
        (0, 0, 8),                      --Slave8
        (0, 0, 9),                      --Slave9
        (0, 0, 10),                     --RTM
        (0, 0, 11),                     --SDRAM_msg
        (0, 0, 12),                     --SDRAM_data
        (0, 0, 13),                     --ME 2
        (0, 0, 14),                     --ME 1
        (0, 0, 15),                     --dctQidct 2
        (0, 0, 16)                      --dctQidct 1 
        )
      );

end addr_lut_pkg;

-------------------------------------------------------------------------------
package body addr_lut_pkg is
-------------------------------------------------------------------------------

  function gen_result_addresses (
    constant numb_arr : number_array;
    constant net_type : integer range 0 to n_net_types_c-1)
    return res_addr_array is
    variable x, y, z : integer;
    variable results : res_addr_array;
  begin  -- gen_addr

    for i in 0 to n_addr_ranges_c-1 loop

      x := numb_arr(net_type, i).x;
      y := numb_arr(net_type, i).y;
      z := numb_arr(net_type, i).z;

      case net_type is

        when 0 =>
          assert false report "HIBI NOT IN USE" severity failure;
        
        when 1 =>                       -- MESH: Uses X and Y
          assert out_addr_w_c mod 2 = 0 report "out_addr_w_c must be even" severity failure;
          results(i) := conv_std_logic_vector(x + y*(2**(out_addr_w_c/2)), out_addr_w_c);

        when 2 =>
          results(i) := conv_std_logic_vector(x+y+z, out_addr_w_c);

        when 3 =>
          results(i) := conv_std_logic_vector(z, out_addr_w_c);
          
      end case;
    end loop;  -- i
    return results;
  end gen_result_addresses;

  -----------------------------------------------------------------------------
  
  function get_num (
    constant addr     : std_logic_vector(addr_w_c-1 downto 0);
    constant net_type : integer
    )
    return number_record is
  --  variable addr_v  : std_logic_vector(addr_w_c-1 downto 0);
    variable numbers : number_record;

  begin  -- get_num

    numbers.x := -1;
    numbers.y := -1;
    numbers.z := -1;

--    addr_v := conv_std_logic_vector(addr, addr_w_c);

    for i in 0 to n_addr_ranges_c-1 loop
      if (addr and addr_table_c(i).mask) = addr_table_c(i).in_addr then

        numbers := num_table_c(net_type, i);

      end if;

    end loop;  -- i

--    assert numbers.x /= -1 or numbers.y /= -1 or numbers.z /= -1
--      report "Mesh address did not map correctly (" & hstr(addr) & ")"
--      severity failure;

    return numbers;
  end get_num;

  
end addr_lut_pkg;
