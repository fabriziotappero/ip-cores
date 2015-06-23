-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.cache_config.all;

-- PREFIX: srpl_xxx
package setrepl_lib is

-- 3-way set permutations
-- s012 => set 0 - least recently used
--         set 2 - most recently used
constant s012 : std_logic_vector(2 downto 0) := "000";
constant s021 : std_logic_vector(2 downto 0) := "001";
constant s102 : std_logic_vector(2 downto 0) := "010";
constant s120 : std_logic_vector(2 downto 0) := "011";
constant s201 : std_logic_vector(2 downto 0) := "100";
constant s210 : std_logic_vector(2 downto 0) := "101";


-- 4-way set permutations
-- s0123 => set 0 - least recently used
--          set 3 - most recently used
constant s0123 : std_logic_vector(4 downto 0) := "00000";
constant s0132 : std_logic_vector(4 downto 0) := "00001";
constant s0213 : std_logic_vector(4 downto 0) := "00010";
constant s0231 : std_logic_vector(4 downto 0) := "00011";
constant s0312 : std_logic_vector(4 downto 0) := "00100";
constant s0321 : std_logic_vector(4 downto 0) := "00101";
constant s1023 : std_logic_vector(4 downto 0) := "00110";
constant s1032 : std_logic_vector(4 downto 0) := "00111";
constant s1203 : std_logic_vector(4 downto 0) := "01000";
constant s1230 : std_logic_vector(4 downto 0) := "01001";
constant s1302 : std_logic_vector(4 downto 0) := "01010";
constant s1320 : std_logic_vector(4 downto 0) := "01011";
constant s2013 : std_logic_vector(4 downto 0) := "01100";
constant s2031 : std_logic_vector(4 downto 0) := "01101";
constant s2103 : std_logic_vector(4 downto 0) := "01110";
constant s2130 : std_logic_vector(4 downto 0) := "01111";
constant s2301 : std_logic_vector(4 downto 0) := "10000";
constant s2310 : std_logic_vector(4 downto 0) := "10001";
constant s3012 : std_logic_vector(4 downto 0) := "10010";
constant s3021 : std_logic_vector(4 downto 0) := "10011";
constant s3102 : std_logic_vector(4 downto 0) := "10100";
constant s3120 : std_logic_vector(4 downto 0) := "10101";
constant s3201 : std_logic_vector(4 downto 0) := "10110";
constant s3210 : std_logic_vector(4 downto 0) := "10111";

type lru_3set_table_vector_type is array(0 to 2) of std_logic_vector(2 downto 0);
type lru_3set_table_type is array (0 to 7) of lru_3set_table_vector_type;

constant lru_3set_table : lru_3set_table_type :=
  ( (s120, s021, s012),                   -- s012
    (s210, s021, s012),                   -- s021
    (s120, s021, s102),                   -- s102
    (s120, s201, s102),                   -- s120
    (s210, s201, s012),                   -- s201
    (s210, s201, s102),                   -- s210
    (s210, s201, s102),                   -- dummy
    (s210, s201, s102)                    -- dummy
  );
  
type lru_4set_table_vector_type is array(0 to 3) of std_logic_vector(4 downto 0);
type lru_4set_table_type is array(0 to 31) of lru_4set_table_vector_type;

constant lru_4set_table : lru_4set_table_type :=
  ( (s1230, s0231, s0132, s0123),       -- s0123
    (s1320, s0321, s0132, s0123),       -- s0132
    (s2130, s0231, s0132, s0213),       -- s0213
    (s2310, s0231, s0312, s0213),       -- s0231
    (s3120, s0321, s0312, s0123),       -- s0312    
    (s3210, s0321, s0312, s0213),       -- s0321
    (s1230, s0231, s1032, s1023),       -- s1023
    (s1320, s0321, s1032, s1023),       -- s1032
    (s1230, s2031, s1032, s1203),       -- s1203
    (s1230, s2301, s1302, s1203),       -- s1230
    (s1320, s3021, s1302, s1023),       -- s1302
    (s1320, s3201, s1302, s1203),       -- s1320
    (s2130, s2031, s0132, s2013),       -- s2013
    (s2310, s2031, s0312, s2013),       -- s2031
    (s2130, s2031, s1032, s2103),       -- s2103
    (s2130, s2301, s1302, s2103),       -- s2130      
    (s2310, s2301, s3012, s2013),       -- s2301
    (s2310, s2301, s3102, s2103),       -- s2310
    (s3120, s3021, s3012, s0123),       -- s3012
    (s3210, s3021, s3012, s0213),       -- s3021
    (s3120, s3021, s3102, s1023),       -- s3102
    (s3120, s3201, s3102, s1203),       -- s3120
    (s3210, s3201, s3012, s2013),       -- s3201
    (s3210, s3201, s3102, s2103),       -- s3210
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103)         -- dummy
  );

type lru3_repl_table_single_type is array(0 to 2) of integer range 0 to 2;
type lru3_repl_table_type is array(0 to 7) of lru3_repl_table_single_type;

constant lru3_repl_table : lru3_repl_table_type :=
  ( (0, 1, 2),      -- s012
    (0, 2, 2),      -- s021
    (1, 1, 2),      -- s102
    (1, 1, 2),      -- s120
    (2, 2, 2),      -- s201
    (2, 2, 2),      -- s210
    (2, 2, 2),      -- dummy
    (2, 2, 2)       -- dummy
  );

type lru4_repl_table_single_type is array(0 to 3) of integer range 0 to 3;
type lru4_repl_table_type is array(0 to 31) of lru4_repl_table_single_type;

constant lru4_repl_table : lru4_repl_table_type :=
  ( (0, 1, 2, 3), -- s0123
    (0, 1, 3, 3), -- s0132
    (0, 2, 2, 3), -- s0213
    (0, 2, 2, 3), -- s0231
    (0, 3, 3, 3), -- s0312
    (0, 3, 3, 3), -- s0321
    (1, 1, 2, 3), -- s1023
    (1, 1, 3, 3), -- s1032
    (1, 1, 2, 3), -- s1203
    (1, 1, 2, 3), -- s1230
    (1, 1, 3, 3), -- s1302
    (1, 1, 3, 3), -- s1320
    (2, 2, 2, 3), -- s2013
    (2, 2, 2, 3), -- s2031
    (2, 2, 2, 3), -- s2103
    (2, 2, 2, 3), -- s2130
    (2, 2, 2, 3), -- s2301
    (2, 2, 2, 3), -- s2310
    (3, 3, 3, 3), -- s3012
    (3, 3, 3, 3), -- s3021
    (3, 3, 3, 3), -- s3102
    (3, 3, 3, 3), -- s3120
    (3, 3, 3, 3), -- s3201
    (3, 3, 3, 3), -- s3210
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0)  -- dummy
  );

end setrepl_lib;


package body setrepl_lib is


end setrepl_lib;
