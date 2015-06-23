----------------------------------------------------------------------------
----                                                                    ----
----  File           : cordic_iterative_tb.vhd                          ----
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
----        VHDL Testbench                                              ----
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



LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library std;
use std.textio.all;     -- for reading/writing from/to files
use std.env.all;        -- for finish()

library work;


entity cordic_iterative_tb is

end entity cordic_iterative_tb;


architecture IMP of cordic_iterative_tb is


   constant FRQ_MULT_VALUE          : integer :=18;

   constant stim_file : string := "../../c_octave/tb_data.txt";
   constant err_file  : string := "./error_out.txt";

   constant clk_T       : time := 5 ns; 
   signal clk           : std_logic;
   signal rst           : std_logic;
   signal nrst          : std_logic;

   constant XY_WIDTH    : natural := 25;
   constant A_WIDTH     : natural := 25;
   constant GUARD_BITS  : natural :=  2;
   constant RM_GAIN     : natural :=  5;
   component cordic_iterative_int is
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
   end component cordic_iterative_int;
   signal en        : std_logic;
   signal start     : std_logic;
   signal done      : std_logic;
   signal mode_i    : std_logic_vector( 4-1 downto 0 );
   signal x_i       : std_logic_vector( XY_WIDTH-1  downto 0 );
   signal y_i       : std_logic_vector( XY_WIDTH-1  downto 0 );
   signal a_i       : std_logic_vector( A_WIDTH+2-1 downto 0 );
   signal x_o       : std_logic_vector( XY_WIDTH+GUARD_BITS-1  downto 0 );
   signal y_o       : std_logic_vector( XY_WIDTH+GUARD_BITS-1  downto 0 );
   signal a_o       : std_logic_vector( A_WIDTH+2-1 downto 0 );



begin


   -- --
   -- clock and reset 
   --
   nrst           <= not rst;
   clk_gen : process
   begin
      clk  <= '1';
      wait for clk_T/2;
      clk  <= '0';
      wait for clk_T/2;
   end process;
   rst_gen  : process 
   begin
      rst   <= '1';
      wait for clk_T * 10;
      rst   <= '0';
      wait;
   end process;
  



   dut : cordic_iterative_int 
   generic map (
      XY_WIDTH       => XY_WIDTH  ,
      A_WIDTH        => A_WIDTH   ,
      GUARD_BITS     => GUARD_BITS,
      RM_GAIN        => RM_GAIN   
          )
   port map(
      clk         => clk         ,
      rst         => rst         ,
      en          => en          ,
      start       => start       ,
      done        => done        ,
      mode_i      => mode_i      ,
      x_i         => x_i         ,
      y_i         => y_i         ,
      a_i         => a_i         ,
      x_o         => x_o         ,
      y_o         => y_o         ,
      a_o         => a_o         
       );



  --
  -- 
  --
  stims_p : process

      file     test_pattern_file    : text;
      file     error_pattern_file   : text;
      variable file_status          : file_open_status;
      variable input_line           : line;
      variable input_line_bak       : line;
      variable good                 : boolean;

      type values_t is array ( 0 to 7 ) of integer;
      variable tmp_value : values_t;

      variable x_ex                 : std_logic_vector( x_o'range );
      variable y_ex                 : std_logic_vector( y_o'range );
      variable a_ex                 : std_logic_vector( a_o'range );
      variable err_cnt              : integer := 0;
      variable stim_cnt             : integer := 0;
  begin
  
    err_cnt := 0;

    --
    -- open file
    --
    file_open( file_status, test_pattern_file, stim_file, READ_MODE );
    if file_status /= open_ok then
       report "unable to open input stimulation file, please use cordic_iterative_test.m to create stimulation file" severity error;
       stop( -1 );
    end if;
    file_open( file_status, error_pattern_file,  err_file, WRITE_MODE );
    if file_status /= open_ok then
       report "unable to open output error file" severity error;
       stop( -1 );
    end if;

    -- wait some cycles
    x_i     <= ( others => '0' );
    y_i     <= ( others => '0' );
    a_i     <= ( others => '0' );
    mode_i  <= ( others => '0' );
    start   <= '0';
    wait for clk_T * 20;

    wait until clk'event and clk='1';

    while ( not endfile( test_pattern_file ) )loop


        wait until en='1';
        wait for clk_T;


        -- read line and extract values
        readline( test_pattern_file, input_line );
        input_line_bak := new string'( input_line.ALL );
        for i in 0 to 6 loop
           read( input_line, tmp_value(i), good );
           --report "rd: "& integer'image( i ) & " : " & integer'image( tmp_value( i ) );
        end loop;

        -- assign values to DUT
        x_i    <= std_logic_vector( to_signed  ( tmp_value(0), x_i'length    ) );
        y_i    <= std_logic_vector( to_signed  ( tmp_value(1), y_i'length    ) );
        a_i    <= std_logic_vector( to_signed  ( tmp_value(2), a_i'length    ) );
        x_ex   := std_logic_vector( to_signed  ( tmp_value(3), x_ex'length   ) );
        y_ex   := std_logic_vector( to_signed  ( tmp_value(4), y_ex'length   ) );
        a_ex   := std_logic_vector( to_signed  ( tmp_value(5), a_ex'length   ) );
        mode_i <= std_logic_vector( to_unsigned( tmp_value(6), mode_i'length ) );
        -- start the DUT and wait, until the DUT is done
        start <= '1';
        wait for clk_T;
        start <= '0';

        wait until done = '1';
        wait until clk'event and clk='1';
        stim_cnt := stim_cnt+1;

        if x_ex /= x_o or 
           y_ex /= y_o or
           a_ex /= a_o then
           assert x_ex = x_o report 
                 integer'image( stim_cnt ) & ": Serial Cordic Failed: expected x result:" 
                 & integer'image( tmp_value(5) ) & ", but got:" 
                 & integer'image( to_integer( signed( x_ex ) ) );
           assert y_ex = y_o report 
                 integer'image( stim_cnt ) &   ": Serial Cordic Failed: expected y result:" 
                 & integer'image( tmp_value(6) ) & ", but got:" 
                 & integer'image( to_integer( signed( y_ex ) ) );
           assert a_ex = a_o report 
                 integer'image( stim_cnt ) &   ": Serial Cordic Failed: expected a result:" 
                 & integer'image( tmp_value(7) ) & ", but got:" 
                 & integer'image( to_integer( signed( a_ex ) ) );
            err_cnt := err_cnt + 1;
         writeline( error_pattern_file, input_line_bak );

        end if;
        
        wait for CLK_T * 5;

    end loop;
    report "====>>>> Serial Cordic Verification Result:" & integer'image( err_cnt ) & " of " & integer'image( stim_cnt ) & " tests failed";
    stop( 0 );
  end process stims_p;




   en_test : process
   begin
      en <= '0';
      wait for clk_T * 10;
      en <= '1';
      wait for clk_T * 1000;
      
   end process;


end architecture IMP;




