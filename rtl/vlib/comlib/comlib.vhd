-- $Id: comlib.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2007-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   comlib
-- Description:    communication components
--
-- Dependencies:   -
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-09-27   595   1.6    add crc16 (using CRC-CCITT polynomial)
-- 2014-09-14   593   1.5    new iface for cdata2byte and byte2cdata
-- 2011-09-17   410   1.4    now numeric_std clean; use for crc8 'A6' polynomial
--                           of Koopman et al.; crc8_update(_tbl) now function
-- 2011-07-30   400   1.3    added byte2word, word2byte
-- 2007-10-12    88   1.2.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-07-08    65   1.2    added procedure crc8_update_tbl
-- 2007-06-29    61   1.1.1  rename for crc8 SALT->INIT 
-- 2007-06-17    58   1.1    add crc8 
-- 2007-06-03    45   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

package comlib is

component byte2word is                  -- 2 byte -> 1 word stream converter
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv8;                       -- input data (byte)
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv16;                     -- output data (word)
    VAL : out slbit;                    -- read valid
    HOLD : in slbit;                    -- read hold
    ODD : out slbit                     -- odd byte pending
  );
end component;

component word2byte is                  -- 1 word -> 2 byte stream converter
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv16;                      -- input data (word)
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv8;                      -- output data (byte)
    VAL : out slbit;                    -- read valid
    HOLD : in slbit;                    -- read hold
    ODD : out slbit                     -- odd byte pending
  );
end component;

constant c_cdata_escape  : slv8 := "11001010"; -- char escape
constant c_cdata_fill    : slv8 := "11010101"; -- char fill
constant c_cdata_xon     : slv8 := "00010001"; -- char xon:  ^Q = hex 11
constant c_cdata_xoff    : slv8 := "00010011"; -- char xoff: ^S = hex 13
constant c_cdata_ec_xon  : slv3 := "100";      -- escape code: xon
constant c_cdata_ec_xoff : slv3 := "101";      -- escape code: xoff
constant c_cdata_ec_fill : slv3 := "110";      -- escape code: fill
constant c_cdata_ec_esc  : slv3 := "111";      -- escape code: escape
constant c_cdata_ed_pref : slv2 := "01";       -- edata: prefix
subtype  c_cdata_edf_pref is  integer range 7 downto 6; -- edata pref field
subtype  c_cdata_edf_eci  is  integer range 5 downto 3; -- edata  inv field
subtype  c_cdata_edf_ec   is  integer range 2 downto 0; -- edata code field

component cdata2byte is                 -- 9bit comma,data -> byte stream
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    ESCXON : in slbit;                  -- enable xon/xoff escaping
    ESCFILL : in slbit;                 -- enable fill escaping
    DI : in slv9;                       -- input data; bit 8 = comma flag
    ENA : in slbit;                     -- input data enable
    BUSY : out slbit;                   -- input data busy    
    DO : out slv8;                      -- output data
    VAL : out slbit;                    -- output data valid
    HOLD : in slbit                     -- output data hold
  );
end component;

component byte2cdata is                 -- byte stream -> 9bit comma,data
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv8;                       -- input data
    ENA : in slbit;                     -- input data enable
    ERR : in slbit;                     -- input data error
    BUSY : out slbit;                   -- input data busy
    DO : out slv9;                      -- output data; bit 8 = comma flag
    VAL : out slbit;                    -- output data valid
    HOLD : in slbit                     -- output data hold
  );
end component;

component crc8 is                       -- crc-8 generator, checker
  generic (
    INIT: slv8 := "00000000");          -- initial state of crc register
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    ENA : in slbit;                     -- update enable
    DI : in slv8;                       -- input data
    CRC : out slv8                      -- crc code
  );
end component;

component crc16 is                      -- crc-16 generator, checker
  generic (
    INIT: slv16 := (others=>'0'));      -- initial state of crc register
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    ENA : in slbit;                     -- update enable
    DI : in slv8;                       -- input data
    CRC : out slv16                     -- crc code
  );
end component;

  function crc8_update     (crc : in slv8; data : in slv8) return slv8;
  function crc8_update_tbl (crc : in slv8; data : in slv8) return slv8;

  function crc16_update     (crc : in slv16; data : in slv8) return slv16;
  function crc16_update_tbl (crc : in slv16; data : in slv8) return slv16;

end package comlib;

-- ----------------------------------------------------------------------------

package body comlib is

  -- crc8_update and crc8_update_tbl implement the 'A6' polynomial of
  -- Koopman and Chakravarty
  --    x^8 + x^6 + x^3 + x^2 + 1   (0xa6)
  -- see
  -- http://dx.doi.org/10.1109%2FDSN.2004.1311885
  -- http://www.ece.cmu.edu/~koopman/roses/dsn04/koopman04_crc_poly_embedded.pdf
  --
  function crc8_update (crc: in slv8; data: in slv8) return slv8 is
    variable t : slv8 := (others=>'0');
    variable n : slv8 := (others=>'0');
  begin

    t := data xor crc;

    n(0) := t(5) xor t(4) xor t(2) xor t(0);
    n(1) := t(6) xor t(5) xor t(3) xor t(1);
    n(2) := t(7) xor t(6) xor t(5) xor t(0);
    n(3) := t(7) xor t(6) xor t(5) xor t(4) xor t(2) xor t(1) xor t(0);
    n(4) := t(7) xor t(6) xor t(5) xor t(3) xor t(2) xor t(1);
    n(5) := t(7) xor t(6) xor t(4) xor t(3) xor t(2);
    n(6) := t(7) xor t(3) xor t(2) xor t(0);
    n(7) := t(4) xor t(3) xor t(1);

    return n;
    
  end function crc8_update;
  
  function crc8_update_tbl (crc: in slv8; data: in slv8) return slv8 is
    
    type crc8_tbl_type is array (0 to 255) of integer;
    variable crc8_tbl : crc8_tbl_type :=        -- generated with gen_crc8_tbl
      (  0,  77, 154, 215, 121,  52, 227, 174,    -- 00-07
       242, 191, 104,  37, 139, 198,  17,  92,    -- 00-0f
       169, 228,  51, 126, 208, 157,  74,   7,    -- 10-17
        91,  22, 193, 140,  34, 111, 184, 245,    -- 10-1f
        31,  82, 133, 200, 102,  43, 252, 177,    -- 20-27
       237, 160, 119,  58, 148, 217,  14,  67,    -- 20-2f
       182, 251,  44,  97, 207, 130,  85,  24,    -- 30-37
        68,   9, 222, 147,  61, 112, 167, 234,    -- 30-3f
        62, 115, 164, 233,  71,  10, 221, 144,    -- 40-47
       204, 129,  86,  27, 181, 248,  47,  98,    -- 40-4f
       151, 218,  13,  64, 238, 163, 116,  57,    -- 50-57
       101,  40, 255, 178,  28,  81, 134, 203,    -- 50-5f
        33, 108, 187, 246,  88,  21, 194, 143,    -- 60-67
       211, 158,  73,   4, 170, 231,  48, 125,    -- 60-6f
       136, 197,  18,  95, 241, 188, 107,  38,    -- 70-70
       122,  55, 224, 173,   3,  78, 153, 212,    -- 70-7f
       124,  49, 230, 171,   5,  72, 159, 210,    -- 80-87
       142, 195,  20,  89, 247, 186, 109,  32,    -- 80-8f
       213, 152,  79,   2, 172, 225,  54, 123,    -- 90-97
        39, 106, 189, 240,  94,  19, 196, 137,    -- 90-9f
        99,  46, 249, 180,  26,  87, 128, 205,    -- a0-a7
       145, 220,  11,  70, 232, 165, 114,  63,    -- a0-af
       202, 135,  80,  29, 179, 254,  41, 100,    -- b0-b7
        56, 117, 162, 239,  65,  12, 219, 150,    -- b0-bf
        66,  15, 216, 149,  59, 118, 161, 236,    -- c0-c7
       176, 253,  42, 103, 201, 132,  83,  30,    -- c0-cf
       235, 166, 113,  60, 146, 223,   8,  69,    -- d0-d7
        25,  84, 131, 206,  96,  45, 250, 183,    -- d0-df
        93,  16, 199, 138,  36, 105, 190, 243,    -- e0-e7
       175, 226,  53, 120, 214, 155,  76,   1,    -- e0-ef
       244, 185, 110,  35, 141, 192,  23,  90,    -- f0-f7
         6,  75, 156, 209, 127,  50, 229, 168     -- f0-ff
      );
    
  begin

    return slv(to_unsigned(crc8_tbl(to_integer(unsigned(data xor crc))), 8));
    
  end function crc8_update_tbl;
  
  -- crc16_update and crc16_update_tbl implement the CCITT polynomial
  --    x^16 + x^12 + x^5 + 1   (0x1021)
  --
  function crc16_update (crc: in slv16; data: in slv8) return slv16 is
    variable n : slv16 := (others=>'0');
    variable t : slv8  := (others=>'0');
 begin

   t := data xor crc(15 downto 8);
   
   n(0)  := t(4) xor t(0);
   n(1)  := t(5) xor t(1);
   n(2)  := t(6) xor t(2);
   n(3)  := t(7) xor t(3);
   n(4)  := t(4);
   n(5)  := t(5) xor t(4) xor t(0);
   n(6)  := t(6) xor t(5) xor t(1);
   n(7)  := t(7) xor t(6) xor t(2);

   n(8)  := t(7) xor t(3)          xor crc(0);
   n(9)  := t(4)                   xor crc(1);
   n(10) := t(5)                   xor crc(2);
   n(11) := t(6)                   xor crc(3);
   n(12) := t(7) xor t(4) xor t(0) xor crc(4);
   n(13) := t(5) xor t(1)          xor crc(5);
   n(14) := t(6) xor t(2)          xor crc(6);
   n(15) := t(7) xor t(3)          xor crc(7);
    
   return n;
    
  end function crc16_update;
  
  function crc16_update_tbl (crc: in slv16; data: in slv8) return slv16 is
    
    type crc16_tbl_type is array (0 to 255) of integer;
    variable crc16_tbl : crc16_tbl_type :=        
      (    0,  4129,  8258, 12387, 16516, 20645, 24774, 28903,
       33032, 37161, 41290, 45419, 49548, 53677, 57806, 61935,
        4657,   528, 12915,  8786, 21173, 17044, 29431, 25302,
       37689, 33560, 45947, 41818, 54205, 50076, 62463, 58334,
        9314, 13379,  1056,  5121, 25830, 29895, 17572, 21637,
       42346, 46411, 34088, 38153, 58862, 62927, 50604, 54669,
       13907,  9842,  5649,  1584, 30423, 26358, 22165, 18100,
       46939, 42874, 38681, 34616, 63455, 59390, 55197, 51132,
       18628, 22757, 26758, 30887,  2112,  6241, 10242, 14371,
       51660, 55789, 59790, 63919, 35144, 39273, 43274, 47403,
       23285, 19156, 31415, 27286,  6769,  2640, 14899, 10770,
       56317, 52188, 64447, 60318, 39801, 35672, 47931, 43802,
       27814, 31879, 19684, 23749, 11298, 15363,  3168,  7233,
       60846, 64911, 52716, 56781, 44330, 48395, 36200, 40265,
       32407, 28342, 24277, 20212, 15891, 11826,  7761,  3696,
       65439, 61374, 57309, 53244, 48923, 44858, 40793, 36728,
       37256, 33193, 45514, 41451, 53516, 49453, 61774, 57711,
        4224,   161, 12482,  8419, 20484, 16421, 28742, 24679,
       33721, 37784, 41979, 46042, 49981, 54044, 58239, 62302,
         689,  4752,  8947, 13010, 16949, 21012, 25207, 29270,
       46570, 42443, 38312, 34185, 62830, 58703, 54572, 50445,
       13538,  9411,  5280,  1153, 29798, 25671, 21540, 17413,
       42971, 47098, 34713, 38840, 59231, 63358, 50973, 55100,
        9939, 14066,  1681,  5808, 26199, 30326, 17941, 22068,
       55628, 51565, 63758, 59695, 39368, 35305, 47498, 43435,
       22596, 18533, 30726, 26663,  6336,  2273, 14466, 10403,
       52093, 56156, 60223, 64286, 35833, 39896, 43963, 48026,
       19061, 23124, 27191, 31254,  2801,  6864, 10931, 14994,
       64814, 60687, 56684, 52557, 48554, 44427, 40424, 36297,
       31782, 27655, 23652, 19525, 15522, 11395,  7392,  3265,
       61215, 65342, 53085, 57212, 44955, 49082, 36825, 40952,
       28183, 32310, 20053, 24180, 11923, 16050,  3793,  7920
      );

    variable ch : slv16 := (others=>'0');
    variable  t : slv8  := (others=>'0');
    variable td : integer := 0;
    
  begin

    -- (crc<<8) ^ crc16_tbl[((crc>>8) ^ data) & 0x00ff]
    ch := crc(7 downto 0) & "00000000";
    t  := data xor crc(15 downto 8);
    td := crc16_tbl(to_integer(unsigned(t)));
    return ch xor slv(to_unsigned(td, 16));
    
  end function crc16_update_tbl;
   
end package body comlib;
