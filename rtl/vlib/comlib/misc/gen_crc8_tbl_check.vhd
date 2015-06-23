-- $Id: gen_crc8_tbl_check.vhd 410 2011-09-18 11:23:09Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    gen_crc8_tbl - sim
-- Description:    stand-alone program to test crc8 transition table
--
-- Dependencies:   -
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-09-17   410   1.1    use now 'A6' polynomial of Koopman et al.
-- 2007-10-12    88   1.0.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-07-08    65   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity gen_crc8_tbl_check is
end gen_crc8_tbl_check;

architecture sim of gen_crc8_tbl_check is
begin
  
  process
    type crc8_tbl_type is array (0 to 255) of integer;
    
    variable crc8_tbl : crc8_tbl_type :=        -- generated with gen_crc8_tbl
      (  0,  77, 154, 215, 121,  52, 227, 174,
       242, 191, 104,  37, 139, 198,  17,  92,
       169, 228,  51, 126, 208, 157,  74,   7,
        91,  22, 193, 140,  34, 111, 184, 245,
        31,  82, 133, 200, 102,  43, 252, 177,
       237, 160, 119,  58, 148, 217,  14,  67,
       182, 251,  44,  97, 207, 130,  85,  24,
        68,   9, 222, 147,  61, 112, 167, 234,
        62, 115, 164, 233,  71,  10, 221, 144,
       204, 129,  86,  27, 181, 248,  47,  98,
       151, 218,  13,  64, 238, 163, 116,  57,
       101,  40, 255, 178,  28,  81, 134, 203,
        33, 108, 187, 246,  88,  21, 194, 143,
       211, 158,  73,   4, 170, 231,  48, 125,
       136, 197,  18,  95, 241, 188, 107,  38,
       122,  55, 224, 173,   3,  78, 153, 212,
       124,  49, 230, 171,   5,  72, 159, 210,
       142, 195,  20,  89, 247, 186, 109,  32,
       213, 152,  79,   2, 172, 225,  54, 123,
        39, 106, 189, 240,  94,  19, 196, 137,
        99,  46, 249, 180,  26,  87, 128, 205,
       145, 220,  11,  70, 232, 165, 114,  63,
       202, 135,  80,  29, 179, 254,  41, 100,
        56, 117, 162, 239,  65,  12, 219, 150,
        66,  15, 216, 149,  59, 118, 161, 236,
       176, 253,  42, 103, 201, 132,  83,  30,
       235, 166, 113,  60, 146, 223,   8,  69,
        25,  84, 131, 206,  96,  45, 250, 183,
        93,  16, 199, 138,  36, 105, 190, 243,
       175, 226,  53, 120, 214, 155,  76,   1,
       244, 185, 110,  35, 141, 192,  23,  90,
         6,  75, 156, 209, 127,  50, 229, 168
      );

    variable crc : integer := 0;
    variable oline : line;
    
  begin
    
    loop_i: for i in 0 to 255 loop
      write(oline, i, right, 4);
      write(oline, string'(": cycle length = "));
      crc := i;
      loop_n: for n in 1 to 256 loop
        crc := crc8_tbl(crc);
        if crc = i then
          write(oline, n, right, 4);
          writeline(output, oline);
          exit loop_n;
        end if;
      end loop;  -- n
    end loop;  -- i
    wait;
  end process;

end sim;
