----------------------------------------------------------------------------
----                                                                    ----
----  File           : cordic_iterative_int.vhd                         ----
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
----        VHDL implementation of YAC                                  ----
----                                                                    ----
----                                                                    ----
----                                                                    ----
-----                                                                  -----
----                                                                    ----
----  TODO                                                              ----
----        Some documentation and function description                 ----
----        Optimization                                                ----
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
library std;
use std.textio.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use ieee.std_logic_textio.all; -- I/O for logic types
use work.cordic_pkg.ALL;
use ieee.math_real.ALL;

entity cordic_iterative_int is
generic(
   XY_WIDTH    : natural := 12;
   A_WIDTH     : natural := 12;
   GUARD_BITS  : natural :=  2;
   RM_GAIN     : natural :=  4
       );
port(
   clk, rst  : in  std_logic;
   en        : in  std_logic;
   start     : in  std_logic;
   done      : out std_logic;
   mode_i    : in  std_logic_vector( 4-1 downto 0 );
   x_i       : in  std_logic_vector( XY_WIDTH-1  downto 0 );
   y_i       : in  std_logic_vector( XY_WIDTH-1  downto 0 );
   a_i       : in  std_logic_vector( A_WIDTH+2-1 downto 0 );
   x_o       : out std_logic_vector( XY_WIDTH+GUARD_BITS-1  downto 0 );
   y_o       : out std_logic_vector( XY_WIDTH+GUARD_BITS-1  downto 0 );
   a_o       : out std_logic_vector( A_WIDTH+2-1 downto 0 )
    );
end entity cordic_iterative_int;


architecture BEHAVIORAL of cordic_iterative_int is
 
   -- log2( max-iteration )
   constant L2_MAX_I    : natural := 8;

   constant MAX_A_WIDTH : natural := 34;

   -- Internal angle width
   constant A_WIDTH_I : natural := A_WIDTH+2;
  

   constant SQRT2_REAL  : real    := 1.4142135623730951454746218587388284504413604;
   constant PI_REAL     : real    := 3.1415926535897931159979634685441851615905762;
   constant PI          : integer := natural( PI_REAL    * real( 2**( A_WIDTH-1 ) ) + 0.5 );
   constant PI_H        : integer := natural( PI_REAL    * real( 2**( A_WIDTH-2 ) ) + 0.5 );
   constant SQRT2       : integer := natural( SQRT2_REAL * real( 2**( XY_WIDTH-1 ) ) + 0.5 );
   constant XY_MAX      : integer := natural( 2**( XY_WIDTH-1)-1);


   constant XY_WIDTH_G : natural := XY_WIDTH + GUARD_BITS;



   type state_st is( ST_IDLE, ST_INIT, ST_ROTATE, ST_RM_GAIN, ST_DONE );
   type state_t is record
      st       : state_st;
      mode     : std_logic_vector( mode_i'range );
      x        : signed( XY_WIDTH_G     -1 downto 0 );
      y        : signed( XY_WIDTH_G     -1 downto 0 );
      x_sh     : signed( XY_WIDTH_G     -1 downto 0 );
      y_sh     : signed( XY_WIDTH_G     -1 downto 0 );
      x_sum    : signed( XY_WIDTH_G     -1 downto 0 );
      y_sum    : signed( XY_WIDTH_G     -1 downto 0 );
      a        : signed( A_WIDTH_I      -1 downto 0 );
      a_tmp    : signed( A_WIDTH_I      -1 downto 0 );
      ylst     : signed( XY_WIDTH_G     -1 downto 0 );
      alst     : signed( A_WIDTH_I      -1 downto 0 );
      i        : signed( L2_MAX_I       -1 downto 0 );
      do_shift : std_logic;
      done     : std_logic;
      repeate  : std_logic;
   end record state_t;
   signal state : state_t;


   ---------------------------------------
   -- Auto-generated function 
   -- by matlab (see c_octave/cordic_iterative_code.m)
   function angular_lut( n : integer; mode : std_logic_vector; ANG_WIDTH : natural ) return signed is
      variable result : signed( ANG_WIDTH-1 downto 0 );
      variable temp : signed( MAX_A_WIDTH-1 downto 0 );
         begin
         if mode = VAL_MODE_CIR then
            case n is
               when 0 => temp := "0110010010000111111011010101000100"; 	-- -1843415740
               when 1 => temp := "0011101101011000110011100000101011"; 	-- -312264661
               when 2 => temp := "0001111101011011011101011111100100"; 	-- 2104350692
               when 3 => temp := "0000111111101010110111010100110101"; 	-- 1068201269
               when 4 => temp := "0000011111111101010101101110110111"; 	-- 536173495
               when 5 => temp := "0000001111111111101010101011011101"; 	-- 268348125
               when 6 => temp := "0000000111111111111101010101010110"; 	-- 134206806
               when 7 => temp := "0000000011111111111111101010101010"; 	-- 67107498
               when 8 => temp := "0000000001111111111111111101010101"; 	-- 33554261
               when 9 => temp := "0000000000111111111111111111101010"; 	-- 16777194
               when 10 => temp := "0000000000011111111111111111111101"; 	-- 8388605
               when others => temp := to_signed( 2**(MAX_A_WIDTH-1-n), MAX_A_WIDTH );
            end case;
         elsif mode = VAL_MODE_HYP then
            case n is
               when 1 => temp := "0100011001001111101010011110101010"; 	-- 423536554
               when 2 => temp := "0010000010110001010111011111010100"; 	-- -2100987948
               when 3 => temp := "0001000000010101100010010001110010"; 	-- 1079387250
               when 4 => temp := "0000100000000010101011000100010101"; 	-- 537571605
               when 5 => temp := "0000010000000000010101010110001000"; 	-- 268522888
               when 6 => temp := "0000001000000000000010101010101100"; 	-- 134228652
               when 7 => temp := "0000000100000000000000010101010101"; 	-- 67110229
               when 8 => temp := "0000000010000000000000000010101010"; 	-- 33554602
               when 9 => temp := "0000000001000000000000000000010101"; 	-- 16777237
               when 10 => temp := "0000000000100000000000000000000010"; 	-- 8388610
               when others => temp := to_signed( 2**(MAX_A_WIDTH-1-n), MAX_A_WIDTH );
            end case;
         elsif mode = VAL_MODE_LIN then
            temp := ( others => '0' );
            temp( temp'high-1-n downto 0  ) := ( others => '1' );
         end if;
      result := temp( temp'high downto temp'high-result'length+1 );
      return result;
   end function angular_lut;
   ---------------------------------------


   function repeat_hyperbolic_it( i : integer ) return boolean is 
      variable res : boolean;
   begin
      case i is
         when 5         => res := true;
         when 14        => res := true;
         when 41        => res := true;
         when 122       => res := true;
         when others    => res := false;
      end case;
      return res;
   end;

begin


   ST : process( clk, rst )
      variable sign : std_logic;
    begin

      if clk'event and clk = '1' then
         if rst = '1' then
             state <= (    st       => ST_IDLE,
                           x        => ( others => '0' ),
                           y        => ( others => '0' ),
                           x_sh     => ( others => '0' ),
                           y_sh     => ( others => '0' ),
                           x_sum    => ( others => '0' ),
                           y_sum    => ( others => '0' ),
                           a        => ( others => '0' ),
                           a_tmp    => ( others => '0' ),
                           ylst     => ( others => '0' ),
                           alst     => ( others => '0' ),
                           mode     => ( others => '0' ),
                           i        => ( others => '0' ),
                           done     => '0',
                           do_shift => '0',
                           repeate  => '0'
                           );
       
         elsif en = '1' then
   
            if state.st = ST_IDLE and start = '1' then
               state.st       <= ST_INIT;
               state.mode     <= mode_i;
               state.x        <= resize( signed( x_i ), state.x'length );
               state.y        <= resize( signed( y_i ), state.y'length );
               state.a        <= resize( signed( a_i ), state.a'length );
               state.i        <= ( others => '0' );
               
            elsif state.st = ST_INIT then
               -- 
               -- initialization state
               --    -> do initial rotation (alignment)
               --    -> check special situations / miss-configurations (TODO)
               --

               state.st       <= ST_ROTATE;
               state.do_shift <= '1';


               if state.mode( 1 downto 0 ) = VAL_MODE_HYP then
                  -- if we do a hyperbolic rotation, we start with 1
                  state.i(0) <= '1';
               end if;




               if     state.mode( I_FLAG_VEC_ROT ) = '0' 
                  and state.mode( 1 downto 0 )   =  VAL_MODE_CIR  then
                  -- circular vector mode

                  if state.a < - PI_H then
                     -- move from third quadrant to first
                     state.a <= state.a + PI;
                     state.x <= - state.x;
                     state.y <= - state.y;
                  elsif state.a > PI_H then
                     -- move from second quadrant to fourth
                     state.a <= state.a - PI;
                     state.x <= - state.x;
                     state.y <= - state.y;
                  end if;

               elsif   state.mode( I_FLAG_VEC_ROT ) = '1'
                   and state.mode( 1 downto 0 )   = VAL_MODE_CIR then
                  -- circular rotation mode

                  if state.x = 0 and state.y = 0 then
                     -- zero-input
                     state.a  <= ( others => '0' );
                     state.y  <= ( others => '0' );
                     state.st <= ST_DONE;

                  elsif state.x = XY_MAX and state.y = XY_MAX then
                     -- all-max 1
                     state.a  <= resize( angular_lut( 0, state.mode( 1 downto 0 ), A_WIDTH ), A_WIDTH_I );
                     state.x  <= to_signed( SQRT2, state.x'length );
                     state.y  <= (others => '0' );
                     state.st <= ST_DONE;
                  elsif state.x = -XY_MAX and state.y = -XY_MAX then
                     -- all-max 2
                     state.a  <= resize( angular_lut( 0, state.mode( 1 downto 0 ), A_WIDTH ), A_WIDTH_I ) - PI;
                     state.x  <= to_signed( SQRT2, state.x'length );
                     state.y  <= (others => '0' );
                     state.st <= ST_DONE;
                  elsif state.x = XY_MAX and state.y = -XY_MAX then
                     -- all-max 3
                     state.a  <= resize( -angular_lut( 0, state.mode( 1 downto 0 ), A_WIDTH ), A_WIDTH_I );
                     state.x  <= to_signed( SQRT2, state.x'length );
                     state.y  <= (others => '0' );
                     state.st <= ST_DONE;
                  elsif state.x = -XY_MAX and state.y = XY_MAX then
                     -- all-max 4
                     state.a  <= PI-  resize( angular_lut( 0, state.mode( 1 downto 0 ), A_WIDTH ), A_WIDTH_I );
                     state.x  <= to_signed( SQRT2, state.x'length );
                     state.y  <= (others => '0' );
                     state.st <= ST_DONE;

                  elsif state.x = 0 and state.y > 0 then
                     -- fixed rotation of pi/2
                     state.a  <= to_signed( PI_H, state.a'length );
                     state.x  <= state.y;
                     state.y  <= ( others => '0' );
                     state.st<= ST_DONE;
                  elsif state.x = 0 and state.y < 0 then
                     -- fixed rotation of -pi/2
                     state.a  <= to_signed( -PI_H, state.a'length );
                     state.x  <= -state.y;
                     state.y  <= ( others => '0' );
                     state.st<= ST_DONE;

                  elsif state.x < 0 and state.y >= 0 then
                     -- move from second quadrant to fourth
                     state.x <= - state.x;
                     state.y <= - state.y;
                     state.a <= to_signed(  PI, state.a'length );
                  elsif state.x < 0 and state.y < 0 then
                     -- move from third quadrant to first
                     state.x <= - state.x;
                     state.y <= - state.y;
                     state.a <= to_signed( -PI, state.a'length );
                  else
                     state.a <= ( others => '0' );
                  end if;
               elsif   state.mode( I_FLAG_VEC_ROT ) = '1'
                   and state.mode( 1 downto 0 )   = VAL_MODE_LIN then
                  -- linear rotation mode
                  if state.x < 0 then
                     state.x <= - state.x;
                     state.y <= - state.y;
                  end if;
                  state.a <= to_signed( 0, state.a'length );

               end if;





            --
            -- rotation state
            --
            -- Each rotation takes 
            --           two steps: in the first step, the shifting is
            --                      done, in the second step, the
            --                      shift-result is added/subtracted
            -- 
            --
            --
            elsif state.st = ST_ROTATE then

               -- get the sign
               if state.mode( I_FLAG_VEC_ROT )  = '0' then
                  if state.a < 0 then 
                     sign := '0';
                  else
                     sign := '1';
                  end if;
               else
                  if state.y < 0 then 
                     sign := '1';
                  else
                     sign := '0';
                  end if;
               end if;



               if state.do_shift = '1' then
                  -- get the angle, do the shifting and set the right angle

                  if sign = '1' then

                     -- circular case
                     if state.mode( 1 downto 0 ) = VAL_MODE_CIR then

                        state.a_tmp <= resize( - angular_lut( to_integer( state.i ), state.mode( 1 downto 0 ), A_WIDTH), A_WIDTH_I );
                        state.y_sh  <= - SHIFT_RIGHT( state.y, to_integer( state.i ) );

                     -- hyperbolic case
                     elsif state.mode( 1 downto 0 ) = VAL_MODE_HYP then

                        state.a_tmp <= resize( - angular_lut( to_integer( state.i ), state.mode( 1 downto 0 ), A_WIDTH), A_WIDTH_I );
                        state.y_sh  <= SHIFT_RIGHT( state.y, to_integer( state.i ) );

                     -- linear case
                     else

                        state.a_tmp <= resize( - angular_lut( to_integer( state.i ), state.mode( 1 downto 0 ), A_WIDTH  ), A_WIDTH_I ) ;
                        state.y_sh  <= ( others => '0' );

                     end if;
                     state.x_sh <=   SHIFT_RIGHT( state.x, to_integer( state.i ) );

                  else

                     -- circular case
                     if state.mode( 1 downto 0 ) = VAL_MODE_CIR then

                        state.a_tmp <= resize( angular_lut( to_integer( state.i ), state.mode( 1 downto 0 ), A_WIDTH ), A_WIDTH_I );
                        state.y_sh  <= SHIFT_RIGHT( state.y, to_integer( state.i ) );

                     -- hyperbolic case
                     elsif state.mode( 1 downto 0 ) = VAL_MODE_HYP then

                        state.a_tmp <= resize( angular_lut( to_integer( state.i ), state.mode( 1 downto 0 ), A_WIDTH ), A_WIDTH_I );
                        state.y_sh  <= - SHIFT_RIGHT( state.y, to_integer( state.i ) );

                     -- linear case
                     else

                        state.a_tmp <= resize( angular_lut( to_integer( state.i ), state.mode( 1 downto 0 ), A_WIDTH ), A_WIDTH_I ) ;
                        state.y_sh  <= ( others => '0' );

                     end if;
                     state.x_sh <= - SHIFT_RIGHT( state.x, to_integer( state.i ) );

                  end if;
                  state.do_shift <= '0';

                  -- abort condition
                  if(   state.mode( I_FLAG_VEC_ROT ) = '0' and
                        state.a = 0 ) then
                     state.st <= ST_RM_GAIN;
                     state.i  <= ( others => '0' );
                  elsif(   state.mode( I_FLAG_VEC_ROT ) = '0' and
                        state.a = state.alst ) then
                     state.st <= ST_RM_GAIN;
                     state.i  <= ( others => '0' );
                  elsif(   state.mode( I_FLAG_VEC_ROT ) = '1' and
                        state.y = 0 ) then
                     state.st <= ST_RM_GAIN;
                     state.i  <= ( others => '0' );
                  elsif(   state.mode( I_FLAG_VEC_ROT ) = '1' and
                        ( state.y = state.ylst ) ) then
                     state.st <= ST_RM_GAIN;
                     state.i  <= ( others => '0' );
                  end if;

                  state.ylst  <= state.y;
                  state.alst  <= state.a;


               else
                  state.x <= state.x + state.y_sh;
                  state.y <= state.y + state.x_sh;
                  state.a <= state.a + state.a_tmp; 
                  if VAL_MODE_HYP = state.mode( 1 downto 0 )         and
                     state.repeate = '0'                             and 
                     repeat_hyperbolic_it( to_integer( state.i ) )   then
                     state.repeate <= '1';
                  else
                     state.repeate  <= '0';
                     state.i        <= state.i+1;
                  end if;
                  state.do_shift <= '1';
               end if;


              


            --
            -- removal of the cordic gain
            --
            elsif state.st = ST_RM_GAIN then
               -- we need RM_GAIN+1 cycles to 
               -- calculate the RM_GAIN steps
               if state.i = (RM_GAIN) then
                 state.st   <= ST_DONE;
                 state.done <= '1';
                   state.i <= ( others => '0' );
               else
                   state.i  <= state.i + 1;
               end if;

               if state.mode( 1 downto 0 ) = VAL_MODE_CIR then
                  mult_0_61( state.x, state.x_sh, state.x_sum, to_integer( state.i ), RM_GAIN );
                  mult_0_61( state.y, state.y_sh, state.y_sum, to_integer( state.i ), RM_GAIN );
               elsif state.mode( 1 downto 0 ) = VAL_MODE_HYP then
                  mult_0_21( state.x, state.x_sh, state.x_sum, to_integer( state.i ), RM_GAIN );
                  mult_0_21( state.y, state.y_sh, state.y_sum, to_integer( state.i ), RM_GAIN );
               else
                  -- TODO  merge ST_DONE and state.done
                  state.done <= '1';
                  state.st    <= ST_DONE;
                  state.x_sum <= state.x;
                  state.y_sum <= state.y;
               end if;


            elsif state.st = ST_DONE then
               state.st    <= ST_IDLE;
               state.done  <= '0';
            end if;
            -- end states



         end if;
         -- end ena


      end if;
      -- end clk

   end process;
   done        <=                   state.done   ;
   x_o         <= std_logic_vector( state.x_sum );
   y_o         <= std_logic_vector( state.y_sum );
   a_o         <= std_logic_vector( state.a );

end architecture BEHAVIORAL;



