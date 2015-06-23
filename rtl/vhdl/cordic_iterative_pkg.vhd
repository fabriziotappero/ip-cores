----------------------------------------------------------------------------
----                                                                    ----
----  File           : cordic_iterative_pkg.vhd                         ----
----  Project        : YAC (Yet Another CORDIC Core)                    ----
----  Creation       : Feb. 2014                                        ----
----  Limitations    :                                                  ----
----  Synthesizer    :                                                  ----
----  Target         :                                                  ----
----                                                                    ----
----  Author(s):     : Christian Haettich                               ----
----  Email          : feddischson@opencores.org                        ----
----                                                                    ----
----                                                                    ----
-----                                                                  -----
----                                                                    ----
----  Description                                                       ----
----        VHDL Package which contains some flabs and                  ----
----        some auto-generated division (multiplication)               ----
----        functions.                                                  ----
----                                                                    ----
----                                                                    ----
----                                                                    ----
-----                                                                  -----
----                                                                    ----
----  TODO                                                              ----
----        Some documentation                                          ----
----                                                                    ----
----                                                                    ----
----                                                                    ----
----                                                                    ----
----------------------------------------------------------------------------
----                                                                    ----
----                  Copyright Notice                                  ----
----                                                                    ----
---- This file is part of YAC - Yet Another CORDIC Core                 ----
---- Copyright (c) 2014, Author(s), All rights reserved.                ----
----                                                                    ----
---- YAC is free software; you can redistribute it and/or               ----
---- modify it under the terms of the GNU Lesser General Public         ----
---- License as published by the Free Software Foundation; either       ----
---- version 3.0 of the License, or (at your option) any later version. ----
----                                                                    ----
---- YAC is distributed in the hope that it will be useful,             ----
---- but WITHOUT ANY WARRANTY; without even the implied warranty of     ----
---- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU  ----
---- Lesser General Public License for more details.                    ----
----                                                                    ----
---- You should have received a copy of the GNU Lesser General Public   ----
---- License along with this library. If not, download it from          ----
---- http://www.gnu.org/licenses/lgpl                                   ----
----                                                                    ----
----------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

package cordic_pkg is

   
   
   constant I_FLAG_VEC_ROT      : natural :=  3;  -- bit index
   constant I_FLAG_ATAN_3       : natural :=  2;  -- bit index (for future usage)
   constant VAL_MODE_CIR      : std_logic_vector( 1 downto 0 ) :=  "00";  -- value
   constant VAL_MODE_LIN      : std_logic_vector( 1 downto 0 ) :=  "01";  -- value
   constant VAL_MODE_HYP      : std_logic_vector( 1 downto 0 ) :=  "10";  -- value

   procedure mult_0_61( signal a    : in    signed; 
                      signal a_sh : inout signed; 
                      signal sum  : inout signed; 
                             cnt  : in    natural;
                      constant RM_GAIN : in natural ); 

   procedure mult_0_21( signal a    : in    signed; 
                      signal a_sh : inout signed; 
                      signal sum  : inout signed; 
                             cnt  : in    natural;
                      constant RM_GAIN : in natural ); 



end package cordic_pkg;


package body cordic_pkg is




--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_01( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_01;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_02( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 4 );
         when   2 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_02;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_03( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   3 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_03;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_04( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_04;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_05( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 12 );
         when   5 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_05;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_06( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_06;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_07( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_07;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_08( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 19 );
         when   8 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_08;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_09( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 22 );
         when   9 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_09;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_10( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 25 );
         when  10 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_10;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_11( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  11 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_11;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_12( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_12;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_13( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_13;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_14( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 39 );
         when  14 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_14;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_15( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  15 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_15;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_16( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_16;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_17( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_17;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_18( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_18;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_19( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_19;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_20( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  20 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_20;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_21( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  20 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  21 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_21;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_22( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  20 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  21 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  22 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_22;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_23( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  20 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  21 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  22 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  23 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_23;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_24( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  20 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  21 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  22 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  23 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  24 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_24;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_25( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  20 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  21 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  22 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  23 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  24 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  25 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_25;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_26( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  20 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  21 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  22 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  23 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  24 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  25 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  26 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_26;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_27( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  20 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  21 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  22 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  23 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  24 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  25 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  26 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 64 );
         when  27 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_27;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_28( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  20 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  21 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  22 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  23 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  24 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  25 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  26 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 64 );
         when  27 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 65 );
         when  28 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_28;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_29( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  20 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  21 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  22 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  23 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  24 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  25 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  26 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 64 );
         when  27 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 65 );
         when  28 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 66 );
         when  29 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_29;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61_30( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= to_signed( 0, sum'length );
                     a_sh <= SHIFT_RIGHT( a, 1 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 3 );
         when   2 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 9 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 13 );
         when   5 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 14 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   7 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 20 );
         when   8 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 23 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 26 );
         when  10 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 28 );
         when  11 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 29 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 34 );
         when  13 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 38 );
         when  14 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 41 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  17 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  18 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 56 );
         when  19 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  20 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  21 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  22 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  23 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  24 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  25 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  26 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 64 );
         when  27 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 65 );
         when  28 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 66 );
         when  29 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 67 );
         when  30 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_61_30;


--
-- Auto-generated procedure to multiply "a" with 0.607253 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_61( signal   a       : in    signed; 
                   signal   a_sh    : inout signed; 
                   signal   sum     : inout signed; 
                            cnt     : in    natural; 
                   constant RM_GAIN : in    natural ) is 
   begin
      case RM_GAIN is
         when 1 => mult_0_61_01( a, a_sh, sum, cnt  );
         when 2 => mult_0_61_02( a, a_sh, sum, cnt  );
         when 3 => mult_0_61_03( a, a_sh, sum, cnt  );
         when 4 => mult_0_61_04( a, a_sh, sum, cnt  );
         when 5 => mult_0_61_05( a, a_sh, sum, cnt  );
         when 6 => mult_0_61_06( a, a_sh, sum, cnt  );
         when 7 => mult_0_61_07( a, a_sh, sum, cnt  );
         when 8 => mult_0_61_08( a, a_sh, sum, cnt  );
         when 9 => mult_0_61_09( a, a_sh, sum, cnt  );
         when 10 => mult_0_61_10( a, a_sh, sum, cnt  );
         when 11 => mult_0_61_11( a, a_sh, sum, cnt  );
         when 12 => mult_0_61_12( a, a_sh, sum, cnt  );
         when 13 => mult_0_61_13( a, a_sh, sum, cnt  );
         when 14 => mult_0_61_14( a, a_sh, sum, cnt  );
         when 15 => mult_0_61_15( a, a_sh, sum, cnt  );
         when 16 => mult_0_61_16( a, a_sh, sum, cnt  );
         when 17 => mult_0_61_17( a, a_sh, sum, cnt  );
         when 18 => mult_0_61_18( a, a_sh, sum, cnt  );
         when 19 => mult_0_61_19( a, a_sh, sum, cnt  );
         when 20 => mult_0_61_20( a, a_sh, sum, cnt  );
         when 21 => mult_0_61_21( a, a_sh, sum, cnt  );
         when 22 => mult_0_61_22( a, a_sh, sum, cnt  );
         when 23 => mult_0_61_23( a, a_sh, sum, cnt  );
         when 24 => mult_0_61_24( a, a_sh, sum, cnt  );
         when 25 => mult_0_61_25( a, a_sh, sum, cnt  );
         when 26 => mult_0_61_26( a, a_sh, sum, cnt  );
         when 27 => mult_0_61_27( a, a_sh, sum, cnt  );
         when 28 => mult_0_61_28( a, a_sh, sum, cnt  );
         when 29 => mult_0_61_29( a, a_sh, sum, cnt  );
         when 30 => mult_0_61_30( a, a_sh, sum, cnt  );
         when others => mult_0_61_30( a, a_sh, sum, cnt  );
      end case;
end procedure mult_0_61;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_01( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 3 ); 
         when   1 => sum  <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_01;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_02( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 4 );
         when   2 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_02;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_03( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 6 );
         when   3 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_03;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_04( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_04;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_05( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 12 );
         when   5 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_05;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_06( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 15 );
         when   6 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_06;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_07( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_07;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_08( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 22 );
         when   8 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_08;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_09( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_09;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_10( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_10;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_11( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 37 );
         when  11 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_11;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_12( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 39 );
         when  12 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_12;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_13( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 42 );
         when  13 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_13;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_14( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 44 );
         when  14 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_14;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_15( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 50 );
         when  15 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_15;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_16( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 52 );
         when  16 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_16;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_17( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_17;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_18( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_18;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_19( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_19;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_20( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  20 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_20;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_21( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  20 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  21 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_21;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_22( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  20 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  21 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  22 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_22;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_23( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  20 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  21 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  22 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  23 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_23;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_24( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  20 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  21 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  22 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  23 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  24 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_24;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_25( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  20 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  21 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  22 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  23 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  24 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 64 );
         when  25 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_25;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_26( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  20 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  21 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  22 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  23 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  24 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 64 );
         when  25 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 65 );
         when  26 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_26;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_27( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  20 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  21 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  22 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  23 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  24 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 64 );
         when  25 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 65 );
         when  26 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 66 );
         when  27 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_27;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_28( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  20 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  21 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  22 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  23 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  24 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 64 );
         when  25 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 65 );
         when  26 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 66 );
         when  27 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 67 );
         when  28 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_28;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_29( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  20 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  21 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  22 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  23 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  24 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 64 );
         when  25 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 65 );
         when  26 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 66 );
         when  27 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 67 );
         when  28 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 68 );
         when  29 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_29;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21_30( signal a    : in    signed; 
                   signal a_sh : inout signed; 
                   signal sum  : inout signed; 
                          cnt  : in    natural ) is 
   begin
      case cnt is
         when   0 => sum  <= a;
                     a_sh <= SHIFT_RIGHT( a, 2 ); 
         when   1 => sum  <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 5 );
         when   2 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 7 );
         when   3 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 8 );
         when   4 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 11 );
         when   5 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 16 );
         when   6 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 17 );
         when   7 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 21 );
         when   8 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 24 );
         when   9 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 27 );
         when  10 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 36 );
         when  11 => sum <= sum + a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 40 );
         when  12 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 43 );
         when  13 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 45 );
         when  14 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 51 );
         when  15 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 53 );
         when  16 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 55 );
         when  17 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 57 );
         when  18 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 58 );
         when  19 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 59 );
         when  20 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 60 );
         when  21 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 61 );
         when  22 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 62 );
         when  23 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 63 );
         when  24 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 64 );
         when  25 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 65 );
         when  26 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 66 );
         when  27 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 67 );
         when  28 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 68 );
         when  29 => sum <= sum - a_sh; 
                 a_sh <= SHIFT_RIGHT( a, 69 );
         when  30 => sum <= sum - a_sh; 
         when others => sum <= sum;
     end case;
end procedure mult_0_21_30;


--
-- Auto-generated procedure to multiply "a" with 0.207497 iteratively
-- a_sh is a temporary register to store the shifted value, and 
-- sum is a temporary register to sum up the result
--
procedure mult_0_21( signal   a       : in    signed; 
                   signal   a_sh    : inout signed; 
                   signal   sum     : inout signed; 
                            cnt     : in    natural; 
                   constant RM_GAIN : in    natural ) is 
   begin
      case RM_GAIN is
         when 1 => mult_0_21_01( a, a_sh, sum, cnt  );
         when 2 => mult_0_21_02( a, a_sh, sum, cnt  );
         when 3 => mult_0_21_03( a, a_sh, sum, cnt  );
         when 4 => mult_0_21_04( a, a_sh, sum, cnt  );
         when 5 => mult_0_21_05( a, a_sh, sum, cnt  );
         when 6 => mult_0_21_06( a, a_sh, sum, cnt  );
         when 7 => mult_0_21_07( a, a_sh, sum, cnt  );
         when 8 => mult_0_21_08( a, a_sh, sum, cnt  );
         when 9 => mult_0_21_09( a, a_sh, sum, cnt  );
         when 10 => mult_0_21_10( a, a_sh, sum, cnt  );
         when 11 => mult_0_21_11( a, a_sh, sum, cnt  );
         when 12 => mult_0_21_12( a, a_sh, sum, cnt  );
         when 13 => mult_0_21_13( a, a_sh, sum, cnt  );
         when 14 => mult_0_21_14( a, a_sh, sum, cnt  );
         when 15 => mult_0_21_15( a, a_sh, sum, cnt  );
         when 16 => mult_0_21_16( a, a_sh, sum, cnt  );
         when 17 => mult_0_21_17( a, a_sh, sum, cnt  );
         when 18 => mult_0_21_18( a, a_sh, sum, cnt  );
         when 19 => mult_0_21_19( a, a_sh, sum, cnt  );
         when 20 => mult_0_21_20( a, a_sh, sum, cnt  );
         when 21 => mult_0_21_21( a, a_sh, sum, cnt  );
         when 22 => mult_0_21_22( a, a_sh, sum, cnt  );
         when 23 => mult_0_21_23( a, a_sh, sum, cnt  );
         when 24 => mult_0_21_24( a, a_sh, sum, cnt  );
         when 25 => mult_0_21_25( a, a_sh, sum, cnt  );
         when 26 => mult_0_21_26( a, a_sh, sum, cnt  );
         when 27 => mult_0_21_27( a, a_sh, sum, cnt  );
         when 28 => mult_0_21_28( a, a_sh, sum, cnt  );
         when 29 => mult_0_21_29( a, a_sh, sum, cnt  );
         when 30 => mult_0_21_30( a, a_sh, sum, cnt  );
         when others => mult_0_21_30( a, a_sh, sum, cnt  );
      end case;
end procedure mult_0_21;




end cordic_pkg;
