-------------------------------------------------------------------------------
-- Title      : Address look-up table
-- Project    : 
-------------------------------------------------------------------------------
-- File       : address_lut.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-01-12
-- Last update: 2012-05-04
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Converts memory mapped I/O address to NoC address
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-01-12  1.0      ase     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ase_noc_pkg.all;
use work.ase_mesh1_pkg.all;
use work.ase_dring1_pkg.all;
use work.fh_mesh_pkg.all;

entity address_lut is
  
  generic (
    my_id_g        : natural;
    data_width_g   : positive;
    address_mode_g : natural;
    cols_g         : positive;
    rows_g         : positive;
    agent_ports_g  : positive;
    agents_g       : positive;
    noc_type_g     : natural;
    len_width_g    : natural);          -- 2012-05-04

  port (
    addr_in  : in  std_logic_vector(data_width_g-1 downto 0);
    len_in   : in  std_logic_vector(len_width_g-1 downto 0);  -- 2012-05-04
    addr_out : out std_logic_vector(data_width_g-1 downto 0));

end entity address_lut;



architecture rtl of address_lut is

  -- How many different address ranges there are
  constant n_addr_ranges_c : positive := 32;
  constant mesh_ids_c      : positive := cols_g*rows_g*agent_ports_g;

  signal noc_target : integer;


  type addr_range_type is array (0 to 2) of unsigned(data_width_g-1 downto 0);
  type addr_lut_type is array (0 to n_addr_ranges_c-1) of addr_range_type;

  function addr_gen (
    constant target : natural;
    length : integer)
    return unsigned is
    variable retval : unsigned(data_width_g-1 downto 0);
  begin
    if noc_type_g = 0 then
      retval := unsigned(ase_noc_address(my_id_g, target, cols_g, rows_g,
                                         agent_ports_g, data_width_g));
      return retval;
    end if;
    if noc_type_g = 1 then
      retval := unsigned(ase_mesh1_address(my_id_g, target, rows_g, cols_g,
                                           data_width_g));
      return retval;
    end if;
    if noc_type_g = 2 then
      retval := unsigned(dring1_address(my_id_g, target, agents_g,
                                        data_width_g));
      return retval;
    end if;
    if noc_type_g = 3 then
      retval := unsigned(fh_mesh_address(my_id_g, target, rows_g, cols_g,
                                        data_width_g, len_width_g,
                                         length));
      return retval;
    end if;
  end addr_gen;

  function addr_gen_s (
    signal target : integer;
    length : integer)
    return std_logic_vector is
    variable retval : std_logic_vector(data_width_g-1 downto 0);
  begin
    if noc_type_g = 0 then
      retval := ase_noc_address_s(my_id_g, target, cols_g, rows_g,
                                  agent_ports_g, data_width_g);
      return retval;
    end if;
    if noc_type_g = 1 then
      retval := ase_mesh1_address(my_id_g, target, rows_g, cols_g,
                                   data_width_g);
      return retval;
    end if;
    if noc_type_g = 2 then
      retval := dring1_address(my_id_g, target, agents_g, data_width_g);
      return retval;
    end if;
    if noc_type_g = 3 then
      retval := fh_mesh_address(my_id_g, target, rows_g, cols_g,
                                data_width_g, len_width_g, length);
      return retval;
    end if;
  end addr_gen_s;

  -- First  = address range's minimum address
  -- Second = address range's maximum address
  -- Third  = corresponding network address

  constant addr_lut_c : addr_lut_type :=
    (
      (x"00000000", x"00FFFFFF", addr_gen(0,8)),
      (x"01000000", x"01FFFFFF", addr_gen(1,8)),
      (x"02000000", x"02FFFFFF", addr_gen(2,8)),
      (x"03000000", x"03FFFFFF", addr_gen(3,8)),
      (x"04000000", x"04FFFFFF", addr_gen(4,8)),
      (x"05000000", x"05FFFFFF", addr_gen(5,8)),
      (x"06000000", x"06FFFFFF", addr_gen(6,8)),
      (x"07000000", x"07FFFFFF", addr_gen(7,8)),
      (x"08000000", x"08FFFFFF", addr_gen(8,8)),
      (x"09000000", x"09FFFFFF", addr_gen(9,8)),
      (x"0A000000", x"0AFFFFFF", addr_gen(10,8)),
      (x"0B000000", x"0BFFFFFF", addr_gen(11,8)),
      (x"0C000000", x"0CFFFFFF", addr_gen(12,8)),
      (x"0D000000", x"0DFFFFFF", addr_gen(13,8)),
      (x"0E000000", x"0EFFFFFF", addr_gen(14,8)),
      (x"0F000000", x"0FFFFFFF", addr_gen(15,8)),
      (x"10000000", x"10FFFFFF", addr_gen(16,8)),
      (x"11000000", x"11FFFFFF", addr_gen(17,8)),
      (x"12000000", x"12FFFFFF", addr_gen(18,8)),
      (x"13000000", x"13FFFFFF", addr_gen(19,8)),
      (x"14000000", x"14FFFFFF", addr_gen(20,8)),
      (x"15000000", x"15FFFFFF", addr_gen(21,8)),
      (x"16000000", x"16FFFFFF", addr_gen(22,8)),
      (x"17000000", x"17FFFFFF", addr_gen(23,8)),
      (x"18000000", x"18FFFFFF", addr_gen(24,8)),
      (x"19000000", x"19FFFFFF", addr_gen(25,8)),
      (x"1A000000", x"1AFFFFFF", addr_gen(26,8)),
      (x"1B000000", x"1BFFFFFF", addr_gen(27,8)),
      (x"1C000000", x"1CFFFFFF", addr_gen(28,8)),
      (x"1D000000", x"1DFFFFFF", addr_gen(29,8)),
      (x"1E000000", x"1EFFFFFF", addr_gen(30,8)),
      (x"1F000000", x"1FFFFFFF", addr_gen(31,8))
      );

--  constant addr_lut_c : addr_lut_type :=
--    (
--      (x"0000", x"0FFF", addr_gen(0)),
--      (x"1000", x"1FFF", addr_gen(1)),
--      (x"2000", x"2FFF", addr_gen(2)),
--      (x"3000", x"3FFF", addr_gen(3))
--      );

begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- MEMORY MAPPED ADDRESSES
  -----------------------------------------------------------------------------
  use_mem_addr_gen : if address_mode_g = 2 generate
    
    translate_p : process (addr_in) is
    begin  -- process  translate_p
      
      addr_out <= (others => '1');

      for i in 0 to n_addr_ranges_c-1 loop

        if unsigned(addr_in) >= addr_lut_c(i)(0)
          and unsigned(addr_in) <= addr_lut_c(i)(1) then

          addr_out <= std_logic_vector(addr_lut_c(i)(2));
        end if;
        
      end loop;  -- i
      
    end process translate_p;
    
  end generate use_mem_addr_gen;

  -----------------------------------------------------------------------------
  -- INTEGER ADDRESSES
  -----------------------------------------------------------------------------
  use_int_addr_gen : if address_mode_g = 1 generate

    noc_target <= to_integer(unsigned(addr_in(data_width_g-2 downto 0)));
    addr_out   <= addr_gen_s(noc_target, to_integer(unsigned(len_in)));
    
  end generate use_int_addr_gen;

  -----------------------------------------------------------------------------
  -- NO ADDRESS TRANSLATION
  -----------------------------------------------------------------------------
  no_translation_g : if address_mode_g = 0 generate

    addr_out <= addr_in;
    
  end generate no_translation_g;
  
end architecture rtl;
