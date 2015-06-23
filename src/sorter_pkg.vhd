-------------------------------------------------------------------------------
-- Title      : Definitions for heap-sorter
-- Project    : heap-sorter
-------------------------------------------------------------------------------
-- File       : sorter_pkg.vhd
-- Author     : Wojciech M. Zabolotny <wzab@ise.pw.edu.pl>
-- Company    : 
-- Created    : 2010-05-14
-- Last update: 2011-07-11
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 Wojciech M. Zabolotny
-- This file is published under the BSD license, so you can freely adapt
-- it for your own purposes.
-- Additionally this design has been described in my article:
--    Wojciech M. Zabolotny, "Dual port memory based Heapsort implementation
--    for FPGA", Proc. SPIE 8008, 80080E (2011); doi:10.1117/12.905281
-- I'd be glad if you cite this article when you publish something based
-- on my design.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-05-14  1.0      wzab    Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
library work;
use work.sys_config.all;

package sorter_pkg is
  constant DATA_REC_WIDTH : integer := DATA_REC_SORT_KEY_WIDTH +
                                       DATA_REC_PAYLOAD_WIDTH + 2;
  

  subtype T_SORT_KEY is unsigned (DATA_REC_SORT_KEY_WIDTH - 1 downto 0);
  subtype T_PAYLOAD is std_logic_vector(DATA_REC_PAYLOAD_WIDTH - 1 downto 0);

  --alias T_SORT_KEY is unsigned (12 downto 0);
  type T_DATA_REC is record
    d_key     : T_SORT_KEY;
    init      : std_logic;
    valid     : std_logic;
    d_payload : T_PAYLOAD;
  end record;

  -- Special constant used to initially fill the sorter
  -- Must be sorted so, that is smaller, than any other data
  constant DATA_REC_INIT_DATA : T_DATA_REC := (
    d_key     => to_unsigned(0, DATA_REC_SORT_KEY_WIDTH),
    init      => '1',
    valid     => '0',
    d_payload => (others => '0')
    );

  -- Special constant used to ``flush'' the sorter at the end
  constant DATA_REC_END_DATA : T_DATA_REC := (
    d_key     => to_unsigned(0, DATA_REC_SORT_KEY_WIDTH),
    init      => '1',
    valid     => '1',
    d_payload => (others => '0')
    );

  
  function sort_cmp_lt (
    constant v1 : T_DATA_REC;
    constant v2 : T_DATA_REC)
    return boolean;

  function tdrec2stlv (
    constant drec : T_DATA_REC)
    return std_logic_vector;

  function stlv2tdrec (
    constant dstlv : std_logic_vector)
    return T_DATA_REC;

  procedure wrstlv (
    rline         : inout line;
    constant vect :       std_logic_vector);

  file reports : text open write_mode is "STD_OUTPUT";

end sorter_pkg;

package body sorter_pkg is

  function stlv2tdrec (
    constant dstlv : std_logic_vector)
    return T_DATA_REC is
    variable result : T_DATA_REC;
    variable j      : integer := 0;
  begin  -- stlv2drec
    j                := 0;
    result.d_key     := unsigned(dstlv(j-1+DATA_REC_SORT_KEY_WIDTH downto j));
    j                := j+DATA_REC_SORT_KEY_WIDTH;
    result.valid     := dstlv(j);
    j                := j+1;
    result.init      := dstlv(j);
    j                := j+1;
    result.d_payload := dstlv(j-1+DATA_REC_PAYLOAD_WIDTH downto j);
    j                := j+DATA_REC_PAYLOAD_WIDTH;
    return result;
  end stlv2tdrec;

  function tdrec2stlv (
    constant drec : T_DATA_REC)
    return std_logic_vector is
    variable result : std_logic_vector(DATA_REC_WIDTH-1 downto 0);
    variable j      : integer := 0;
  begin  -- tdrec2stlv
    j                                            := 0;
    result(j-1+DATA_REC_SORT_KEY_WIDTH downto j) := std_logic_vector(drec.d_key);
    j                                            := j+DATA_REC_SORT_KEY_WIDTH;
    result(j)                                    := drec.valid;
    j                                            := j+1;
    result(j)                                    := drec.init;
    j                                            := j+1;
    result(j-1+DATA_REC_PAYLOAD_WIDTH downto j)  := std_logic_vector(drec.d_payload);
    j                                            := j+DATA_REC_PAYLOAD_WIDTH;
    return result;
  end tdrec2stlv;


  -- Function sort_cmp_lt returns TRUE when the first opperand is ``less'' than
  -- the second one
  function sort_cmp_lt (
    constant v1 : T_DATA_REC;
    constant v2 : T_DATA_REC)
    return boolean is
    variable rline : line;
    variable dcomp  : unsigned(DATA_REC_SORT_KEY_WIDTH-1 downto 0) := (others => '0');
  begin  -- sort_cmp_lt
    -- Check the special cases
    if (v1.init = '1') and (v2.init = '0') then
      -- v1 is the special record, v2 is the standard one
      if v1.valid = '0' then
        -- initialization record - ``smaller'' than all standard records
        return true;
      else
        -- end record - ``bigger'' than all standard records
        return false;
      end if;
    elsif (v1.init = '0') and (v2.init = '1') then
      -- v2 is the special record, v1 is the standard one      
      if (v2.valid = '0') then
        -- v2 is the initialization record - it is ``smaller'' than standard record v1
        return false;
      else
        -- v2 is the end record - it is ``bigger'' than standard record v1
        return true;
      end if;
    elsif (v1.init = '1') and (v2.init = '1') then
      -- both v1 and v2 are special records
      if (v1.valid = '0') and (v2.valid = '1') then
        -- v1 - initial record, v2 - end record
        return true;
      else
        -- v1 is end record, so it is ``bigger'' or ``equal'' to other records
        return false;
      end if;
    elsif (v1.init = '0') and (v2.init = '0') then
      -- We compare standard words
      -- We must consider the fact, that in longer sequences of data records
      -- the sort keys may wrap around
      -- therefore we perform subtraction modulo
      -- 2**DATA_REC_SORT_KEY_WIDTH and check the MSB
      dcomp := v1.d_key-v2.d_key;
      if dcomp(DATA_REC_SORT_KEY_WIDTH-1) = '1' then
      --if signed(v1.d_key - v2.d_key)<0 then -- old implementation
        return true;
      elsif v2.d_key = v1.d_key then
        if v2.valid = '1' then
          return true;
        else
          -- Empty data records should wait
          return false;
        end if;
      else
        return false;
      end if;
    else
      assert false report "Wrong records in sort_cmp_lt" severity error;
      return false;
    end if;
    return false;                       -- should never happen
  end sort_cmp_lt;


  procedure wrstlv (
    rline         : inout line;
    constant vect :       std_logic_vector) is
  begin  -- stlv2str
    for i in vect'left downto vect'right loop
      case vect(i) is
        when 'U'    => write(rline, string'("u"));
        when 'Z'    => write(rline, string'("z"));
        when 'X'    => write(rline, string'("x"));
        when 'L'    => write(rline, string'("L"));
        when 'H'    => write(rline, string'("H"));
        when '1'    => write(rline, string'("1"));
        when '0'    => write(rline, string'("0"));
        when others => write(rline, string'("?"));
      end case;
    end loop;  -- i
  end wrstlv;
  
end sorter_pkg;

