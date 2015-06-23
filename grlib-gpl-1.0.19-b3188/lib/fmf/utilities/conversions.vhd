--------------------------------------------------------------------------------
--  File Name: conversions_p.vhd
--------------------------------------------------------------------------------
--  Copyright (C) 1997, 1998, 2001 Free Model Foundry; http://eda.org/fmf/
-- 
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License version 2 as
--  published by the Free Software Foundation.
-- 
--  This package was written by SEVA Technologies, Inc. and donated to the FMF.
--  www.seva.com
--
--  MODIFICATION HISTORY:
-- 
--  version: |  author:  | mod date: | changes made:
--    V1.0     R. Steele   97 DEC 05   Added header and formatting to SEVA file
--    V1.1     R. Munden   98 NOV 28   Corrected some comments
--                                     Corrected function b
--    V1.2     R. Munden   01 MAY 27   Corrected function to_nat for weak values
--                                     and combined into a single file
-- 
--------------------------------------------------------------------------------

LIBRARY IEEE;   USE IEEE.std_logic_1164.ALL;

--------------------------------------------------------------------------------
--  CONVERSION FUNCTION SELECTION TABLES
--------------------------------------------------------------------------------
-- 
--  FROM         TO: std_logic_vector std_logic  natural     time     string
--  -----------------|---------------|---------|---------|---------|-----------
--  std_logic_vector |      N/A      |   N/A   |  to_nat | combine | see below
--  std_logic        |      N/A      |   N/A   |  to_nat | combine | see below
--  natural          |     to_slv    |  to_sl  |   N/A   | to_time | see below
--  time             |      N/A      |   N/A   |  to_nat | N/A     | to_time_str
--  hex string       |       h       |   N/A   |    h    | combine | N/A
--  decimal string   |       d       |   N/A   |    d    | combine | N/A
--  octal string     |       o       |   N/A   |    o    | combine | N/A
--  binary string    |       b       |   N/A   |    b    | combine | N/A
--  -----------------|---------------|---------|---------|---------|-----------
--
--  FROM           TO: hex string decimal string octal string  binary string 
--  -----------------|------------|-------------|------------|----------------
--  std_logic_vector | to_hex_str | to_int_str  | to_oct_str |  to_bin_str
--  std_logic        |    N/A     |    N/A      |    N/A     |  to_bin_str
--  natural          | to_hex_str | to_int_str  | to_oct_str |  to_bin_str
--  -----------------|------------|-------------|------------|----------------
-- 
--------------------------------------------------------------------------------

PACKAGE conversions IS
  
    ----------------------------------------------------------------------------
    -- the conversions in this package are not guaranteed to be synthesizable.
    --
    -- others functions available
    -- fill         creates a variable length string of the fill character
    --
    -- 
    --
    -- input parameters of type natural or integer can be in the form:
    --    normal              -> 8, 99, 4_237
    --    base#value#         -> 2#0101#, 16#fa4C#,  8#6_734#
    --    with exponents(x10) -> 8e4, 16#2e#E4
    --
    -- input parameters of type string can be in the form:
    --    "99", "4_237", "0101", "1010_1010"
    --
    -- for bit/bit_vector <-> std_logic/std_logic_vector conversions use 
    --   package std_logic_1164
    --     to_bit(std_logic)
    --     to_bitvector(std_logic_vector)
    --     to_stdlogic(bit)
    --     to_stdlogicvector(bit_vector)
    --
    -- for "synthesizable" signed/unsigned/std_logic_vector/integer
    -- conversions use
    --   package std_logic_arith 
    --     conv_integer(signed/unsigned)
    --     conv_unsigned(integer/signed,size)
    --     conv_signed(integer/unsigned,size)
    --     conv_std_logic_vector(integer/signed/unsigned,size)
    --
    -- for "synthesizable" std_logic_vector -> integer conversions use
    --   package std_logic_unsigned/std_logic_signed
    --            <these packages are mutually exclusive>
    --     conv_integer(std_logic_vector)
    --            <except for this conversion, these packages are unnecessary)
    --     to minimize compile problems write:
    --       use std_logic_unsigned.conv_integer;
    --       use std_logic_signed.conv_integer;
    --
    -- std_logic_vector, signed and unsigned types are "closely related"
    -- no type conversion functions are needed, use type casting or qualified
    -- expressions
    --
    --   type1(object of type2)          <type casting>
    --   type1'(expression of type2)     <qualified expression>
    --
    -- most conversions have 4 parmeters:
    --   x         : value to be converted 
    --   rtn_len   : size of the return value
    --   justify   : justify value 'left' or 'right', default is right
    --   basespec  : print the base of the value - 'yes'/'no', default is yes
    --
    -- Typical ways to call these functions:
    --     simple, all defaults used
    --     to_bin_str(x)
    --         x will be converted to a string of minimum size with a 
    --           base specification appended for clarity
    --         if x is 10101 then return is b"10101" 
    --
    --   to control size of return string
    --     to_hex_str(x,                
    --                6)                
    --         length of string returned will be 6 characters
    --         value will be right justified in the field  
    --         if x is 10101 then return is ....h"15"
    --          where '.' represents a blank 
    --          if 'rtn_len' parm defaults or is set to 0 then
    --           return string will always be minimum size
    --
    --   to left justify and suppress base specification
    --     to_int_str(x,
    --                6,
    --                justify => left, 
    --                basespec => yes)
    --         length of return string will be 6 characters
    --         the base specification will be suppressed
    --         if x is 10101 then return is 21.... 
    --           where '.' represents a blank 
    --
    -- other usage notes
    --
    --   if rtn_len less than or equal to x'length then ignore 
    --      rtn_len and return string of x'length
    --   the 'justify' parm is effectively ignored in this case
    --
    --   if rtn_len greater than x'length then return string 
    --      of rtn_len with blanks based on 'justify' parm
    --
    -- these routines do not handle negative numbers
    ----------------------------------------------------------------------------

    type justify_side is (left, right);
    type b_spec       is (no  , yes);

    -- std_logic_vector to binary string
    function to_bin_str(x          : std_logic_vector;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) 
      return string;

    -- std_logic to binary string
    function to_bin_str(x          : std_logic;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes)
      return string;

    -- natural to binary string
    function to_bin_str(x          : natural;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) 
      return string;
      -- see note above regarding possible formats for x

    -- std_logic_vector to hex string
    function to_hex_str(x          : std_logic_vector;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) 
      return string;

    -- natural to hex string
    function to_hex_str(x          : natural;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) 
      return string;
      -- see note above regarding possible formats for x

    -- std_logic_vector to octal string
    function to_oct_str(x          : std_logic_vector;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) 
      return string;

    -- natural to octal string
    function to_oct_str(x          : natural;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) 
      return string;
      -- see note above regarding possible formats for x

    -- natural to integer string
    function to_int_str(x          : natural;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) 
      return string;
      -- see note above regarding possible formats for x

    -- std_logic_vector to integer string
    function to_int_str(x          : std_logic_vector;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) 
      return string;

    -- time to string
    function to_time_str (x          : time) 
      return string;

    -- add characters to a string
    function fill        (fill_char  : character    := '*';
                          rtn_len    : integer      := 1) 
      return string;
      -- usage:
        -- fill
          -- returns *
        -- fill(' ',10)    
          -- returns ..........  when '.' represents a blank
        -- fill(lf) or fill(ht)  
          -- returns line feed character or tab character respectively

    -- std_logic_vector to natural
    function to_nat      (x        : std_logic_vector) 
      return natural;

    -- std_logic to natural
    function to_nat      (x        : std_logic) 
      return natural;

    -- time to natural
    function to_nat      (x        : time) 
      return natural;

    -- hex string to std_logic_vector
    function h         (x          : string;
                        rtn_len    : positive range 1 to 32 := 32)
      return std_logic_vector;
    -- if rtn_len is < than x'length*4, result will be truncated on the left
    -- if x is other than characters 0 to 9 or a,A to f,F 
    --   or x,X,z,Z,u,U,-,w,W, result will be 0

    -- decimal string to std_logic_vector
    function d         (x          : string;
                        rtn_len    : positive range 1 to 32 := 32)
      return std_logic_vector;
    -- if rtn_len is < than x'length*4, result will be truncated on the left
    -- if x is other than characters 0 to 9 or x,X,z,Z,u,U,-,w,W,
    --   result will be 0

    -- octal string to std_logic_vector
    function o         (x          : string;
                        rtn_len    : positive range 1 to 32 := 32)
      return std_logic_vector;
    -- if rtn_len is < than x'length*4, result will be truncated on the left
    -- if x is other than characters 0 to 7 or x,X,z,Z,u,U,-,w,W,
    --   result will be 0

    -- binary string to std_logic_vector
    function b         (x          : string;
                        rtn_len    : positive range 1 to 32 := 32)
      return std_logic_vector;
    -- if rtn_len is < than x'length*4, result will be truncated on the left
    -- if x is other than characters 0 to 1 or x,X,z,Z,u,U,-,w,W, 
    --   result will be 0

    -- hex string to natural
    function h         (x          : string)
      return natural;
    -- if x is other than characters 0 to 9 or a,A to f,F, result will be 0

    -- decimal string to natural
    function d         (x          : string)
      return natural;
    -- if x is other than characters 0 to 9, result will be 0

    -- octal string to natural
    function o         (x          : string)
      return natural;
    -- if x is other than characters 0 to 7, result will be 0

    -- binary string to natural
    function b         (x          : string)
      return natural;
    -- if x is other than characters 0 to 1, result will be 0

    -- natural to std_logic_vector
    function to_slv    (x          : natural;
                        rtn_len    : positive range 1 to 32 := 32) 
      return std_logic_vector;
      -- if rtn_len is < than sizeof(x), result will be truncated on the left
      -- see note above regarding possible formats for x

    -- natural to std_logic
    function to_sl     (x          : natural) 
      return std_logic;

    -- natural to time
    function to_time   (x          : natural)
      return time;
      -- see note above regarding possible formats for x

END conversions;
-- 
--------------------------------------------------------------------------------
-- 

PACKAGE BODY conversions IS

    -- private declarations for this package 
    type basetype     is (binary, octal, decimal, hex);

    function max(x,y: integer) return integer is
    begin
      if x > y then return x; else return y; end if;
    end max;

    function min(x,y: integer) return integer is
    begin
      if x < y then return x; else return y; end if;
    end min;

    -- consider function sizeof for string/slv/???, return natural

    --  function size(len: natural) return natural is
    --  begin
    --    if len=0 then
    --      return 31;
    --    else return len;
    --    end if;
    --  end size;

      function nextmultof (x    : positive;
                           size : positive) return positive is
      begin
        case x mod size is
          when 0      => return size * x/size;
          when others => return size * (x/size + 1);
        end case;
      end nextmultof;

      function rtn_base (base : basetype) return character is
      begin
        case base is
          when binary  => return 'b';
          when octal   => return 'o';
          when decimal => return 'd';
          when hex     => return 'h';
        end case;
      end rtn_base;

      function format (r          : string;
                       base       : basetype;
                       rtn_len    : natural     ;
                       justify    : justify_side;
                       basespec   : b_spec) return string is
        variable int_rtn_len : integer; 
      begin
        if basespec=yes then 
          int_rtn_len := rtn_len - 3;
        else 
          int_rtn_len := rtn_len;
        end if;
        if int_rtn_len <= r'length then
          case basespec is
            when no  => return r ;
            when yes => return rtn_base(base) & '"' & r & '"';
          end case;
        else 
          case justify is
            when left  =>
              case basespec is
                when no  => 
                  return r & fill(' ',int_rtn_len - r'length);
                when yes  => 
                  return rtn_base(base) & '"' & r & '"' & 
                         fill(' ',int_rtn_len - r'length);
              end case;
            when right =>
              case basespec is
                when no  => 
                  return fill(' ',int_rtn_len - r'length) & r ;
                when yes  => 
                  return fill(' ',int_rtn_len - r'length) & 
                         rtn_base(base) & '"' & r & '"';
              end case;
          end case;
        end if;
      end format;

      -- convert numeric string of any base to natural
      function cnvt_base (x      : string;
                          inbase : natural range 2 to 16) return natural is
        -- assumes x is an unsigned number string of base 'inbase'
        -- values larger than natural'high are not supported
        variable r,t   : natural  := 0;
        variable place : positive := 1;
      begin
        for i in x'reverse_range loop
          case x(i) is
            when '0'     => t := 0;
            when '1'     => t := 1;
            when '2'     => t := 2;
            when '3'     => t := 3;
            when '4'     => t := 4;
            when '5'     => t := 5;
            when '6'     => t := 6;
            when '7'     => t := 7;
            when '8'     => t := 8;
            when '9'     => t := 9;
            when 'a'|'A' => t := 10;
            when 'b'|'B' => t := 11;
            when 'c'|'C' => t := 12;
            when 'd'|'D' => t := 13;
            when 'e'|'E' => t := 14;
            when 'f'|'F' => t := 15;
            when '_'     => t := 0;    -- ignore these characters
                            place := place / inbase;
            when others  => 
              assert false 
                report lf &
                       "CNVT_BASE found input value larger than base: " & lf &
                       "Input value: " & x(i) &
                         " Base: " & to_int_str(inbase) & lf &
                       "converting input to integer 0"
                severity warning;
              return 0;   
          end case;
          if t / inbase > 1 then       -- invalid value for base
            assert false 
              report lf &
                     "CNVT_BASE found input value larger than base: " & lf &
                     "Input value: " & x(i) &
                       " Base: " & to_int_str(inbase) & lf &
                     "converting input to integer 0"
              severity warning;
            return 0;
          else
            r     := r + (t * place);   
            place := place * inbase;
          end if;
        end loop;
        return r;
      end cnvt_base;

    function extend (x   : std_logic;
                     len : positive) return std_logic_vector is
      variable v : std_logic_vector(1 to len) := (others => x); 
    begin
      return v; 
    end extend;


    -- implementation of public declarations

    function to_bin_str(x          : std_logic_vector;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) return string is

      variable int : std_logic_vector(1 to x'length):=x;
      variable r   : string(1 to x'length):=(others=>'$');
    begin
      for i in int'range loop
        r(i to i) := to_bin_str(int(i),basespec=>no);
      end loop;
      return format (r,binary,rtn_len,justify,basespec);
    end to_bin_str;

    function to_bin_str(x          : std_logic;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) return string is
      variable r   : string(1 to 1);
    begin
        case x is
          when '0'    => r(1) := '0';
          when '1'    => r(1) := '1';
          when 'U'    => r(1) := 'U';
          when 'X'    => r(1) := 'X';
          when 'Z'    => r(1) := 'Z';
          when 'W'    => r(1) := 'W';
          when 'H'    => r(1) := 'H';
          when 'L'    => r(1) := 'L';
          when '-'    => r(1) := '-';
        end case;
      return format (r,binary,rtn_len,justify,basespec);
    end to_bin_str;

    function to_bin_str(x          : natural;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) return string is
      variable int : natural := x;
      variable ptr : positive range 2 to 32 := 32;
      variable r   : string(2 to 32):=(others=>'$');
    begin
      if int = 0 then 
        return format ("0",binary,rtn_len,justify,basespec);
      end if;

      while int > 0 loop
        case int rem 2 is
          when 0 => r(ptr) := '0';
          when 1 => r(ptr) := '1';
          when others =>
            assert false report lf & "TO_BIN_STR, shouldn't happen" 
            severity failure;
            return "$";
           null;
        end case;
        int := int / 2;
        ptr := ptr - 1;
      end loop;
      return format (r(ptr+1 to 32),binary,rtn_len,justify,basespec);
    end to_bin_str;

    function to_hex_str(x          : std_logic_vector;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes) return string is
      -- will return x'length/4
      variable nxt : positive := nextmultof(x'length,4);
      variable int : std_logic_vector(1 to nxt):= (others => '0');
      variable ptr : positive range 1 to (nxt/4)+1 := 1;
      variable r   : string(1 to nxt/4):=(others=>'$');
      subtype slv4 is std_logic_vector(1 to 4);
    begin
      int(nxt-x'length+1 to nxt) := x;
      if nxt-x'length > 0 and x(x'left) /= '1' then 
        int(1 to nxt-x'length) := extend(x(x'left),nxt-x'length);
      end if;
      for i in int'range loop
        next when i rem 4 /= 1;
        case slv4'(int(i to i+3)) is
          when "0000" => r(ptr) := '0';
          when "0001" => r(ptr) := '1';
          when "0010" => r(ptr) := '2';
          when "0011" => r(ptr) := '3';
          when "0100" => r(ptr) := '4';
          when "0101" => r(ptr) := '5';
          when "0110" => r(ptr) := '6';
          when "0111" => r(ptr) := '7';
          when "1000" => r(ptr) := '8';
          when "1001" => r(ptr) := '9';
          when "1010" => r(ptr) := 'A';
          when "1011" => r(ptr) := 'B';
          when "1100" => r(ptr) := 'C';
          when "1101" => r(ptr) := 'D';
          when "1110" => r(ptr) := 'E';
          when "1111" => r(ptr) := 'F';
          when "ZZZZ" => r(ptr) := 'Z';
          when "WWWW" => r(ptr) := 'W';
          when "LLLL" => r(ptr) := 'L';
          when "HHHH" => r(ptr) := 'H';
          when "UUUU" => r(ptr) := 'U';
          when "XXXX" => r(ptr) := 'X';
          when "----" => r(ptr) := '-';
          when others =>
            assert false 
              report lf &
                     "TO_HEX_STR found illegal value: " & 
                       to_bin_str(int(i to i+3)) & lf &
                     "converting input to '-'"
              severity warning;
            r(ptr) := '-';
        end case;
        ptr := ptr + 1;
      end loop;
      return format (r,hex,rtn_len,justify,basespec);
    end to_hex_str;

    function to_hex_str(x          : natural;
                        rtn_len    : natural      := 0;
                        justify    : justify_side := right;
                        basespec   : b_spec       := yes)     return string is
      variable int : natural := x;
      variable ptr : positive range 1 to 20 := 20;
      variable r   : string(1 to 20):=(others=>'$');
    begin
      if x=0 then return format ("0",hex,rtn_len,justify,basespec); end if;
      while int > 0 loop
        case int rem 16 is
          when 0  => r(ptr) := '0';
          when 1  => r(ptr) := '1';
          when 2  => r(ptr) := '2';
          when 3  => r(ptr) := '3';
          when 4  => r(ptr) := '4';
          when 5  => r(ptr) := '5';
          when 6  => r(ptr) := '6';
          when 7  => r(ptr) := '7';
          when 8  => r(ptr) := '8';
          when 9  => r(ptr) := '9';
          when 10 => r(ptr) := 'A';
          when 11 => r(ptr) := 'B';
          when 12 => r(ptr) := 'C';
          when 13 => r(ptr) := 'D';
          when 14 => r(ptr) := 'E';
          when 15 => r(ptr) := 'F';
          when others =>
            assert false report lf & "TO_HEX_STR, shouldn't happen"
            severity failure;
            return "$";
        end case;
        int := int / 16;
        ptr := ptr - 1;
      end loop;
      return format (r(ptr+1 to 20),hex,rtn_len,justify,basespec);
    end to_hex_str;

      function to_oct_str(x          : std_logic_vector;
                          rtn_len    : natural      := 0;
                          justify    : justify_side := right;
                          basespec   : b_spec       := yes) return string is
        -- will return x'length/3
        variable nxt : positive := nextmultof(x'length,3);
        variable int : std_logic_vector(1 to nxt):= (others => '0');
        variable ptr : positive range 1 to (nxt/3)+1 := 1;
        variable r   : string(1 to nxt/3):=(others=>'$');
        subtype slv3 is std_logic_vector(1 to 3);
      begin
        int(nxt-x'length+1 to nxt) := x;
        if nxt-x'length > 0 and x(x'left) /= '1' then 
          int(1 to nxt-x'length) := extend(x(x'left),nxt-x'length);
        end if;
        for i in int'range loop
          next when i rem 3 /= 1;
          case slv3'(int(i to i+2)) is
            when "000" => r(ptr) := '0';
            when "001" => r(ptr) := '1';
            when "010" => r(ptr) := '2';
            when "011" => r(ptr) := '3';
            when "100" => r(ptr) := '4';
            when "101" => r(ptr) := '5';
            when "110" => r(ptr) := '6';
            when "111" => r(ptr) := '7';
            when "ZZZ" => r(ptr) := 'Z';
            when "WWW" => r(ptr) := 'W';
            when "LLL" => r(ptr) := 'L';
            when "HHH" => r(ptr) := 'H';
            when "UUU" => r(ptr) := 'U';
            when "XXX" => r(ptr) := 'X';
            when "---" => r(ptr) := '-';
            when others =>
              assert false 
                report lf &
                       "TO_OCT_STR found illegal value: " & 
                         to_bin_str(int(i to i+2)) & lf &
                       "converting input to '-'"
                severity warning;
              r(ptr) := '-';
          end case;
          ptr := ptr + 1;
        end loop;
        return format (r,octal,rtn_len,justify,basespec);
      end to_oct_str;

      function to_oct_str(x          : natural;
                          rtn_len    : natural      := 0;
                          justify    : justify_side := right;
                          basespec   : b_spec       := yes)  return string is
        variable int : natural := x;
        variable ptr : positive range 1 to 20 := 20;
        variable r   : string(1 to 20):=(others=>'$');
      begin
        if x=0 then return format ("0",octal,rtn_len,justify,basespec); end if;
        while int > 0 loop
          case int rem 8 is
            when 0  => r(ptr) := '0';
            when 1  => r(ptr) := '1';
            when 2  => r(ptr) := '2';
            when 3  => r(ptr) := '3';
            when 4  => r(ptr) := '4';
            when 5  => r(ptr) := '5';
            when 6  => r(ptr) := '6';
            when 7  => r(ptr) := '7';
            when others =>
              assert false report lf & "TO_OCT_STR, shouldn't happen" 
              severity failure;
              return "$";
          end case;
          int := int / 8;
          ptr := ptr - 1;
        end loop;
        return format (r(ptr+1 to 20),octal,rtn_len,justify,basespec);
      end to_oct_str;

      function to_int_str(x          : natural;
                          rtn_len    : natural      := 0;
                          justify    : justify_side := right;
                          basespec   : b_spec       := yes) return string is
        variable int : natural := x;
        variable ptr : positive range 1 to 32 := 32;
        variable r   : string(1 to 32):=(others=>'$');
      begin
        if x=0 then return format ("0",hex,rtn_len,justify,basespec); 
        else
        while int > 0 loop
          case int rem 10 is
            when 0 => r(ptr) := '0';
            when 1 => r(ptr) := '1';
            when 2 => r(ptr) := '2';
            when 3 => r(ptr) := '3';
            when 4 => r(ptr) := '4';
            when 5 => r(ptr) := '5';
            when 6 => r(ptr) := '6';
            when 7 => r(ptr) := '7';
            when 8 => r(ptr) := '8';
            when 9 => r(ptr) := '9';
            when others =>
              assert false report lf & "TO_INT_STR, shouldn't happen" 
              severity failure;
              return "$";
          end case;
          int := int / 10;
          ptr := ptr - 1;
        end loop;
        return format (r(ptr+1 to 32),decimal,rtn_len,justify,basespec);
        end if;
      end to_int_str;

      function to_int_str(x          : std_logic_vector;
                          rtn_len    : natural      := 0;
                          justify    : justify_side := right;
                          basespec   : b_spec       := yes) 
        return string is
      begin
        return to_int_str(to_nat(x),rtn_len,justify,basespec);
      end to_int_str;


      function to_time_str (x          : time)
        return string is
      begin
        return to_int_str(to_nat(x),basespec=>no) & " ns";
      end to_time_str;

      function fill        (fill_char  : character    := '*';
                            rtn_len    : integer      := 1) 
        return string is
        variable r : string(1 to max(rtn_len,1)) := (others => fill_char); 
        variable len : integer;
      begin
        if rtn_len < 2 then -- always returns at least 1 fill char 
          len := 1;
        else
          len := rtn_len;
        end if;
        return r(1 to len);
      end fill;  

      function to_nat(x : std_logic_vector) return natural is
        -- assumes x is an unsigned number, lsb on right,
        -- more than 31 bits are truncated on left
        variable t     : std_logic_vector(1 to x'length) := x;
        variable int   : std_logic_vector(1 to 31) := (others => '0');
        variable r     : natural  := 0;
        variable place : positive := 1;
      begin
        if x'length < 32 then
          int(max(32-x'length,1) to 31) := t(1 to x'length);
        else -- x'length >= 32
          int(1 to 31) := t(x'length-30 to x'length);
        end if;
        for i in int'reverse_range loop
          case int(i) is
            when '1' | 'H'    => r := r + place;
            when '0' | 'L'    => null; 
            when others => 
              assert false 
                report lf &
                    "TO_NAT found illegal value: " & to_bin_str(int(i)) & lf &
                    "converting input to integer 0"
                severity warning;
              return 0;
          end case;
          exit when i=1;
          place := place * 2;
        end loop;
        return r;
      end to_nat;

      function to_nat      (x        : std_logic) 
        return natural is
      begin
        case x is
          when '0' => return 0 ;
          when '1' => return 1 ;
          when others =>
              assert false 
                report lf &
                       "TO_NAT found illegal value: " & to_bin_str(x) & lf &
                       "converting input to integer 0"
                severity warning;
              return 0;
        end case;
      end to_nat;

      function to_nat      (x        : time) 
        return natural is
      begin
        return x / 1 ns;
      end to_nat;

      function h(x       : string;
                 rtn_len : positive range 1 to 32 := 32) 
        return std_logic_vector is
      -- if rtn_len is < than x'length*4, result will be truncated on the left
      -- if x is other than characters 0 to 9 or a,A to f,F or 
      -- x,X,z,Z,u,U,-,w,W, 
      --   those result bits will be set to 0
        variable int : string(1 to x'length) := x;
        variable size: positive := max(x'length*4,rtn_len);
        variable ptr : integer range -3 to size := size;
        variable r   : std_logic_vector(1 to size) := (others=>'0');
      begin
        for i in int'reverse_range loop
          case int(i) is
            when '0'     => r(ptr-3 to ptr) := "0000";
            when '1'     => r(ptr-3 to ptr) := "0001";
            when '2'     => r(ptr-3 to ptr) := "0010";
            when '3'     => r(ptr-3 to ptr) := "0011";
            when '4'     => r(ptr-3 to ptr) := "0100";
            when '5'     => r(ptr-3 to ptr) := "0101";
            when '6'     => r(ptr-3 to ptr) := "0110";
            when '7'     => r(ptr-3 to ptr) := "0111";
            when '8'     => r(ptr-3 to ptr) := "1000";
            when '9'     => r(ptr-3 to ptr) := "1001";
            when 'a'|'A' => r(ptr-3 to ptr) := "1010";
            when 'b'|'B' => r(ptr-3 to ptr) := "1011";
            when 'c'|'C' => r(ptr-3 to ptr) := "1100";
            when 'd'|'D' => r(ptr-3 to ptr) := "1101";
            when 'e'|'E' => r(ptr-3 to ptr) := "1110";
            when 'f'|'F' => r(ptr-3 to ptr) := "1111";
            when 'U'     => r(ptr-3 to ptr) := "UUUU";
            when 'X'     => r(ptr-3 to ptr) := "XXXX";
            when 'Z'     => r(ptr-3 to ptr) := "ZZZZ";
            when 'W'     => r(ptr-3 to ptr) := "WWWW";
            when 'H'     => r(ptr-3 to ptr) := "HHHH";
            when 'L'     => r(ptr-3 to ptr) := "LLLL";
            when '-'     => r(ptr-3 to ptr) := "----";
            when '_'     => ptr := ptr + 4;
            when others  => 
              assert false 
                report lf & 
                    "O conversion found illegal input character: " & 
                     int(i) & lf & "converting character to '----'"
                severity warning;
              r(ptr-3 to ptr) := "----";
         end case;
          ptr := ptr - 4;      
        end loop;
        return r(size-rtn_len+1 to size);
      end h;

      function d         (x          : string;
                          rtn_len    : positive range 1 to 32 := 32)
        return std_logic_vector is
      -- if rtn_len is < than binary length of x, result will be truncated on 
      -- the left
      -- if x is other than characters 0 to 9, result will be 0
      begin
        return to_slv(cnvt_base(x,10),rtn_len);
      end d;

      function o         (x          : string;
                          rtn_len    : positive range 1 to 32 := 32)
        return std_logic_vector is
      -- if rtn_len is < than x'length*3, result will be truncated on the left
      -- if x is other than characters 0 to 7 or or x,X,z,Z,u,U,-,w,W,
      --   those result bits will be set to 0
        variable int : string(1 to x'length) := x;
        variable size: positive := max(x'length*3,rtn_len);
        variable ptr : integer range -2 to size := size;
        variable r   : std_logic_vector(1 to size) := (others=>'0');
      begin
        for i in int'reverse_range loop
          case int(i) is
            when '0'     => r(ptr-2 to ptr) := "000";
            when '1'     => r(ptr-2 to ptr) := "001";
            when '2'     => r(ptr-2 to ptr) := "010";
            when '3'     => r(ptr-2 to ptr) := "011";
            when '4'     => r(ptr-2 to ptr) := "100";
            when '5'     => r(ptr-2 to ptr) := "101";
            when '6'     => r(ptr-2 to ptr) := "110";
            when '7'     => r(ptr-2 to ptr) := "111";
            when 'U'     => r(ptr-2 to ptr) := "UUU";
            when 'X'     => r(ptr-2 to ptr) := "XXX";
            when 'Z'     => r(ptr-2 to ptr) := "ZZZ";
            when 'W'     => r(ptr-2 to ptr) := "WWW";
            when 'H'     => r(ptr-2 to ptr) := "HHH";
            when 'L'     => r(ptr-2 to ptr) := "LLL";
            when '-'     => r(ptr-2 to ptr) := "---";
            when '_'     => ptr := ptr + 3;
            when others  => 
              assert false 
                report lf & 
                    "O conversion found illegal input character: " & 
                     int(i) & lf & "converting character to '---'"
                severity warning;
              r(ptr-2 to ptr) := "---";
         end case;
          ptr := ptr - 3;      
        end loop;
        return r(size-rtn_len+1 to size);
      end o;

      function b         (x          : string;
                          rtn_len    : positive range 1 to 32 := 32)
        return std_logic_vector is
      -- if rtn_len is < than x'length, result will be truncated on the left
      -- if x is other than characters 0 to 1 or x,X,z,Z,u,U,-,w,W, 
      --   those result bits will be set to 0
        variable int : string(1 to x'length) := x;
        variable size: positive := max(x'length,rtn_len);
        variable ptr : integer range 0 to size+1 := size; -- csa
        variable r   : std_logic_vector(1 to size) := (others=>'0');
      begin
        for i in int'reverse_range loop
          case int(i) is
            when '0'     => r(ptr) := '0';
            when '1'     => r(ptr) := '1';
            when 'U'     => r(ptr) := 'U';
            when 'X'     => r(ptr) := 'X';
            when 'Z'     => r(ptr) := 'Z';
            when 'W'     => r(ptr) := 'W';
            when 'H'     => r(ptr) := 'H';
            when 'L'     => r(ptr) := 'L';
            when '-'     => r(ptr) := '-';
            when '_'     => ptr := ptr + 1;
            when others  => 
              assert false 
                report lf & 
                    "B conversion found illegal input character: " & 
                     int(i) & lf &  "converting character to '-'"
                severity warning;
              r(ptr) := '-';           
          end case;
          ptr := ptr - 1;      
        end loop;
        return r(size-rtn_len+1 to size);
      end b;

      function h         (x          : string)
        return natural is
      -- only following characters are allowed, otherwise result will be 0
      --   0 to 9 
      --   a,A to f,F 
      --   blanks, underscore
      begin
        return cnvt_base(x,16);
      end h;

      function d         (x          : string)
        return natural is
      -- only following characters are allowed, otherwise result will be 0
      --   0 to 9 
      --   blanks, underscore
      begin
        return cnvt_base(x,10);
      end d;

      function o         (x          : string)
        return natural is
      -- only following characters are allowed, otherwise result will be 0
      --   0 to 7 
      --   blanks, underscore
      begin
        return cnvt_base(x,8);
      end o;

      function b         (x          : string)
        return natural is
      -- only following characters are allowed, otherwise result will be 0
      --   0 to 1 
      --   blanks, underscore
      begin
        return cnvt_base(x,2);
      end b;

      function to_slv(x       : natural;
                      rtn_len : positive range 1 to 32 := 32) 
        return std_logic_vector is
        -- if rtn_len is < than sizeof(x), result will be truncated on the left
        variable int : natural  := x;
        variable ptr : positive := 32;
        variable r   : std_logic_vector(1 to 32) := (others=>'0');
      begin
        while int > 0 loop
          case int rem 2 is
            when 0 => r(ptr) := '0';
            when 1 => r(ptr) := '1';
            when others => 
              assert false report lf & "TO_SLV, shouldn't happen" 
              severity failure;
              return "0";
          end case;
          int := int / 2;
          ptr := ptr - 1;
        end loop;
        return r(33-rtn_len to 32);
      end to_slv;

      function to_sl(x       : natural) 
        return std_logic is
        variable r   : std_logic := '0';
      begin
        case x is
          when 0 => null;
          when 1 => r := '1';
          when others => 
            assert false 
              report lf & 
                "TO_SL found illegal input character: " & 
                 to_int_str(x) & lf & "converting character to '-'"
              severity warning;
            return '-';
        end case; 
        return r;
      end to_sl;

      function to_time (x: natural) return time is
      begin
        return x * 1 ns;
      end to_time;

END conversions;
