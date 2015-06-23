library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

-- SHA-224 Constants Package

package shaPkg is

  constant CW     : integer := 8;         -- CLOCK MSG CHUNK WIDTH
  constant CLENBIT: integer := 4;         -- CLOCK MSG CHUNK WIDTH BIT --(SE 0 = CW ALTRIMENTI < CW)
  constant WW     : integer := 32;        -- WORD WIDTH
  constant STBIT  : integer := 6;         -- STEP COUNTER BIT
  constant STMAX  : integer := 64;        -- STEP NUMBER
  constant OS     : integer := 224;       -- OUTPUT SIZE
  constant WOUT   : integer := 7;         -- OUTPUT WORDS
  constant ISS    : integer := 256;       -- INTERNAL STATE SIZE
  constant BS     : integer := 512;       -- BLOCK SIZE
  constant WBLK   : integer := 16;        -- WORD IN BLOCK
  constant LENBIT : integer := 9;         -- MAX BLOCK LENGTH SIZE (EXPONENT)
  constant MSGBIT : integer := 64;        -- MAX MSG SIZE (EXPONENT)

  -- INITIAL HASH VALUE

  constant HASH0  : unsigned(0 to WW-1) := x"c1059ed8";
  constant HASH1  : unsigned(0 to WW-1) := x"367cd507";
  constant HASH2  : unsigned(0 to WW-1) := x"3070dd17";
  constant HASH3  : unsigned(0 to WW-1) := x"f70e5939";
  constant HASH4  : unsigned(0 to WW-1) := x"ffc00b31";
  constant HASH5  : unsigned(0 to WW-1) := x"68581511";
  constant HASH6  : unsigned(0 to WW-1) := x"64f98fa7";
  constant HASH7  : unsigned(0 to WW-1) := x"befa4fa4";
  
end shaPkg;
