library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

-- SHA-256 Constants Package

package shaPkg is

  constant CW     : integer := 8;         -- CLOCK MSG CHUNK WIDTH
  constant CLENBIT: integer := 4;         -- CLOCK MSG CHUNK WIDTH BIT --(SE 0 = CW ALTRIMENTI < CW)
  constant WW     : integer := 32;        -- WORD WIDTH
  constant STBIT  : integer := 6;         -- STEP COUNTER BIT
  constant STMAX  : integer := 64;        -- STEP NUMBER
  constant OS     : integer := 256;       -- OUTPUT SIZE
  constant WOUT   : integer := 8;         -- OUTPUT WORDS
  constant ISS    : integer := 256;       -- INTERNAL STATE SIZE
  constant BS     : integer := 512;       -- BLOCK SIZE
  constant WBLK   : integer := 16;        -- WORD IN BLOCK
  constant LENBIT : integer := 9;         -- MAX BLOCK LENGTH SIZE (EXPONENT)
  constant MSGBIT : integer := 64;        -- MAX MSG SIZE (EXPONENT)

  -- INITIAL HASH VALUE

  constant HASH0  : unsigned(0 to WW-1) := x"6a09e667";
  constant HASH1  : unsigned(0 to WW-1) := x"bb67ae85";
  constant HASH2  : unsigned(0 to WW-1) := x"3c6ef372";
  constant HASH3  : unsigned(0 to WW-1) := x"a54ff53a";
  constant HASH4  : unsigned(0 to WW-1) := x"510e527f";
  constant HASH5  : unsigned(0 to WW-1) := x"9b05688c";
  constant HASH6  : unsigned(0 to WW-1) := x"1f83d9ab";
  constant HASH7  : unsigned(0 to WW-1) := x"5be0cd19";
  
end shaPkg;
