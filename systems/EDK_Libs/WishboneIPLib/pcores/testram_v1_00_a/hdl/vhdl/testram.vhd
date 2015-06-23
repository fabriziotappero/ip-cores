----------------------------------------------------------------------
----                                                              ----
----  PLB2WB-Bridge                                               ----
----                                                              ----
----  This file is part of the PLB-to-WB-Bridge project           ----
----  http://opencores.org/project,plb2wbbridge                   ----
----                                                              ----
----  Description                                                 ----
----  Implementation of a PLB-to-WB-Bridge according to           ----
----  PLB-to-WB Bridge specification document.                    ----
----                                                              ----
----  To Do:                                                      ----
----   Nothing                                                    ----
----                                                              ----
----  Author(s):                                                  ----
----      - Christian Haettich                                    ----
----        feddischson@opencores.org                             ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2010 Authors                                   ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


use ieee.std_logic_textio.all;
use std.textio.all;



entity testram is

   generic(
      MEM_FILE_NAME     : string  := "onchip_ram.bin";
      WB_ADR_W          : integer := 32;
      WB_DAT_W          : integer := 32;
      RAM_ADR_W         : integer := 15;

      RD_DELAY          : natural := 1;
      WR_DELAY          : natural := 1;
      WITH_ERR_OR_RTY   : std_logic_vector( 1 downto 0 ) := "00";   -- "00" = none, "01" = err, "10" = rty", "11" = none
      ERR_RTY_INTERVAL  : integer := 0
   );
   port(

      wb_clk_i    : in  std_logic;
      wb_rst_i    : in  std_logic;
      wb_adr_i    : in  std_logic_vector( WB_ADR_W-1 downto 0 );
      wb_stb_i    : in  std_logic;
      wb_cyc_i    : in  std_logic;
      wb_we_i     : in  std_logic;
      wb_sel_i    : in  std_logic_vector( (WB_ADR_W/8)-1 downto 0 );
      wb_dat_i    : in  std_logic_vector( WB_DAT_W-1 downto 0 );
      wb_dat_o    : out std_logic_vector( WB_DAT_W-1 downto 0 );
      wb_ack_o    : out std_logic;
      wb_err_o    : out std_logic;
      wb_rty_o    : out std_logic
   );

end entity testram;



architecture IMP of testram is

   type ram_type is array( integer range <> ) of std_logic_vector( WB_DAT_W-1 downto 0 );

   procedure load_ram(signal data_word : inout ram_type ) is
--    file ram_file  : text open read_mode is MEM_FILE_NAME;
   
      type CHRF is file of character;
      file char_file : CHRF;


      variable cbuf        : character;
      variable lbuf        : line;
      variable byte_index  : integer := 0;
      variable line_index  : integer := 0;
      variable data  : std_logic_vector( WB_DAT_W-1 downto 0 );
   begin
      file_open( char_file, MEM_FILE_NAME, read_mode );




      while not endfile( char_file ) and line_index < ( 2**RAM_ADR_W ) loop

         for i in 0 to ( WB_DAT_W/8)-1 loop
            read( char_file, cbuf );
            data_word( line_index )( (i+1)*8-1 downto i*8 ) <= std_logic_vector( to_unsigned( character'pos(cbuf), 8 ) );
            if endfile( char_file ) then
               exit;
            end if;
         end loop;
         line_index := line_index+1;

      end loop;

      while line_index < (2**RAM_ADR_W) loop
         data_word( line_index ) <= (others => '0' );
         line_index := line_index + 1;
      end loop;


   end procedure;



   function log_2( x : positive ) return natural is
      
   begin
      if x <= 1 then
         return 0;
      else
         return 1 + log_2( x/2 );
      end if;

   end function;

   
   --
   --  Returns the maximum of x and y. If x and y are less than 2, 2 is returned.
   --
   function get_delay_count_vsize( x,y : natural ) return positive is
      variable temp : natural;
   begin
      if x > y then
         temp := x;
      else
         temp := y;
      end if;

      if temp < 2 then
         temp := 2;
      end if;
      return temp;
   end function;



   function vec_size ( x : natural ) return natural is
      variable temp, i : natural;
   begin

      temp := 0;
      i    := 0;
      while temp <= x loop
         i     := i + 1;
         temp  := 2**i;
      end loop;
      return i;

   end function vec_size;


   constant test_a : natural := vec_size( RD_DELAY );
   constant test_b : natural := vec_size( WR_DELAY );

   constant DELAY_COUNT_SIZE  : natural := get_delay_count_vsize( vec_size( RD_DELAY ), vec_size( WR_DELAY ) );
   constant DELAY_COUNT_ZERO  : std_logic_vector( DELAY_COUNT_SIZE-1 downto 0 ) := ( others => '0' );


   constant ERR_RTY_COUNT_SIZE : natural := vec_size( ERR_RTY_INTERVAL );
   constant ERR_RTY_COUNT_ZERO : std_logic_vector( ERR_RTY_COUNT_SIZE-1 downto 0 ) := ( others => '0' );

   --
   -- RAM_ADR_LB (low bit) and RAM_ADR_HB (high bit):
   -- => used select the address lines, which we use to address the ram
   --
   --   eg. WB_ADR_W = 64 and RAM_ADR_W = 5:
   --   
   --    We don't want to use the lower 3 bit, because one ram-line contains 8 byte
   --    RAM_ADR_LB = 3
   --    RAM_ADR_HB = 7
   --
   --       ==>> 7 downto 3  = 5 address line, which address 2**5 * 8 byte = 32 * 8 byte
   --
   constant RAM_ADR_LB        : integer := log_2( WB_ADR_W/8);
   constant RAM_ADR_HB        : integer := RAM_ADR_LB + RAM_ADR_W - 1;


   signal ram              : ram_type(2**RAM_ADR_W -1 downto 0);
   signal w_ack, r_ack     : std_logic                                              := '0';
   signal w_err, r_err     : std_logic                                              := '0';
   signal w_rty, r_rty     : std_logic                                              := '0';
   signal r_delay_count    : std_logic_vector( DELAY_COUNT_SIZE -1 downto 0 )       := ( others => '0' );
   signal w_delay_count    : std_logic_vector( DELAY_COUNT_SIZE -1 downto 0 )       := ( others => '0' );
   signal ram_adr          : std_logic_vector( RAM_ADR_W-1 downto 0 )               := ( others => '0' );
   signal ram_line         : std_logic_vector( WB_DAT_W-1 downto 0 )                := ( others => '0' );
   
   signal   err_rty_count_r   : std_logic_vector( ERR_RTY_COUNT_SIZE-1 downto 0 );
   signal   err_rty_count_w   : std_logic_vector( ERR_RTY_COUNT_SIZE-1 downto 0 );
   constant err_rty_zero      : std_logic_vector( ERR_RTY_COUNT_SIZE-1 downto 0 ) := ( others => '0' );



begin


   with wb_rst_i select
      ram_adr <= wb_adr_i( RAM_ADR_HB downto RAM_ADR_LB )   when '0',
               ( others => '0' )                            when others;

   gen_read_ack1 : if RD_DELAY > 1 generate

            -- generate read ack after a delay
            read_ack_p1 : process( wb_clk_i, wb_rst_i ) begin
               if wb_rst_i = '1' then

                  r_rty <= '0';
                  r_ack <= '0';
                  r_err <= '0';
                  r_delay_count     <= std_logic_vector( to_unsigned( RD_DELAY, DELAY_COUNT_SIZE ) );
                  err_rty_count_r <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE ) );

               elsif wb_clk_i'event and wb_clk_i = '1' then

                  r_delay_count <= std_logic_vector( to_unsigned( RD_DELAY, DELAY_COUNT_SIZE ) );

                  if wb_cyc_i = '1' and wb_stb_i = '1' and wb_we_i = '0' 
                     and  not ( r_ack = '1' or r_rty = '1' or r_err = '1' ) then

                     r_delay_count     <= r_delay_count -1;

                     if r_delay_count = DELAY_COUNT_ZERO then
                        
                        r_delay_count     <= std_logic_vector( to_unsigned( RD_DELAY, DELAY_COUNT_SIZE ) );
                        if err_rty_count_r = ERR_RTY_COUNT_ZERO then
                           err_rty_count_r <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE ) );
                        else
                           err_rty_count_r <= err_rty_count_r - 1;
                        end if;
                     end if;
                  end if;



                  if r_delay_count = DELAY_COUNT_ZERO and wb_cyc_i = '1' and wb_stb_i = '1' then
                     err_rty_count_r <= err_rty_count_r - 1;

                     if ( err_rty_count_r = err_rty_zero and WITH_ERR_OR_RTY = "10" ) then
                        r_rty <= '1';
                        r_ack <= '0';
                        r_err <= '0';
                     elsif ( err_rty_count_r = err_rty_zero and WITH_ERR_OR_RTY = "01" ) then
                        r_rty <= '0';
                        r_ack <= '0';
                        r_err <= '1';
                     else
                        r_rty <= '0';
                        r_ack <= '1';
                        r_err <= '0';
                     end if;

                  else
                     r_rty <= '0';
                     r_ack <= '0';
                     r_err <= '0';
                  end if;

               end if;
            end process;
     
   end generate;

   gen_read_ack2 : if RD_DELAY = 1 generate

            -- generate read ack after a delay
            read_ack_p2 : process( wb_clk_i, wb_rst_i ) begin

               if wb_rst_i = '1' then

                  r_ack             <= '0';
                  r_err             <= '0';
                  r_rty             <= '0';
                  err_rty_count_r   <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE ) );

               elsif wb_clk_i'event and wb_clk_i = '1' then

                  if ( wb_cyc_i = '1' and wb_stb_i = '1' and wb_we_i = '0' 
                        and not (r_ack = '1' or r_rty = '1' or r_err = '1' ) ) then

                     if err_rty_count_r = ERR_RTY_COUNT_ZERO then
                        err_rty_count_r <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE ) );
                     else
                        err_rty_count_r <= err_rty_count_r - 1;
                     end if;

                     if ( err_rty_count_r = err_rty_zero and WITH_ERR_OR_RTY = "10" ) then
                        r_rty <= '1';
                        r_ack <= '0';
                        r_err <= '0';
                     elsif ( err_rty_count_r = err_rty_zero and WITH_ERR_OR_RTY = "01" ) then
                        r_rty <= '0';
                        r_ack <= '0';
                        r_err <= '1';
                     else
                        r_rty <= '0';
                        r_ack <= '1';
                        r_err <= '0';
                     end if;

                  else
                     r_ack <= '0';
                     r_err <= '0';
                     r_rty <= '0';
                  end if;

               end if;

            end process;
     
   end generate;

   

   gen_read_ack3 : if RD_DELAY = 0 generate

         read_ack_p3 : process( wb_clk_i, wb_rst_i, wb_cyc_i, wb_stb_i, wb_we_i, err_rty_count_r ) begin
            if wb_rst_i = '1' then
               err_rty_count_r <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE ) );
            elsif wb_clk_i'event and wb_clk_i = '1' then
               if ( wb_cyc_i = '1' and wb_stb_i = '1'  and wb_we_i = '0' ) then
                  if err_rty_count_r = ERR_RTY_COUNT_ZERO then
                     err_rty_count_r <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE ) );
                  else
                     err_rty_count_r <= err_rty_count_r - 1;
                  end if;
               end if;
            end if;

            r_err <= '0';
            r_rty <= '0';
            r_ack <= '0';

            if ( wb_cyc_i = '1' and wb_stb_i = '1'  and wb_we_i = '0' ) then

               if ( err_rty_count_r = err_rty_zero and WITH_ERR_OR_RTY = "10" ) then
                  r_rty <= '1';
               elsif ( err_rty_count_r = err_rty_zero and WITH_ERR_OR_RTY = "01" ) then
                  r_err <= '1';
               else
                  r_ack <= '1';
               end if;

            end if;



         end process;


   end generate;



   gen_write_ack1 : if WR_DELAY > 1 generate

            -- generate write ack after a delay
            -- and write byte-wise data to ram, depending on select
            write_ack_p1 : process( wb_clk_i, wb_rst_i, wb_cyc_i, wb_stb_i, wb_we_i, w_ack ) begin

               if wb_rst_i = '1' then
                  load_ram( ram );
                  w_err <= '0';
                  w_rty <= '0';
                  w_ack <= '0';
                  w_delay_count     <= std_logic_vector( to_unsigned( WR_DELAY, DELAY_COUNT_SIZE )             );
                  err_rty_count_w   <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE )   );

               elsif wb_clk_i'event and wb_clk_i = '1' then

                  w_delay_count <= std_logic_vector( to_unsigned( WR_DELAY, DELAY_COUNT_SIZE ) );

                  if wb_cyc_i = '1' and wb_stb_i = '1' and wb_we_i = '1' 
                     and not ( w_ack = '1' or w_err = '1' or w_rty = '1' ) then
                     w_delay_count <= w_delay_count -1;

                     if w_delay_count = DELAY_COUNT_ZERO then
                        w_delay_count <= std_logic_vector( to_unsigned( WR_DELAY, DELAY_COUNT_SIZE ) );
                        if err_rty_count_w = ERR_RTY_COUNT_ZERO then
                           err_rty_count_w <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE ) );
                        else
                           err_rty_count_w <= err_rty_count_w - 1;
                        end if;
                     end if;
                  end if;

                  if w_delay_count = DELAY_COUNT_ZERO and wb_cyc_i = '1' and wb_stb_i = '1' then

                     err_rty_count_w <= err_rty_count_w - 1;

                     if ( err_rty_count_w = err_rty_zero and WITH_ERR_OR_RTY = "10" ) then
                        w_err <= '0';
                        w_rty <= '1';
                        w_ack <= '0';
                     elsif ( err_rty_count_w = err_rty_zero and WITH_ERR_OR_RTY = "01" ) then
                        w_err <= '1';
                        w_rty <= '0';
                        w_ack <= '0';
                     else
                        w_err <= '0';
                        w_rty <= '0';
                        w_ack <= '1';
                        for i in 0 to ( WB_DAT_W/8)-1 loop
                           if ( wb_sel_i(i) = '1' ) then
                              ram( conv_integer( ram_adr ) )( (i+1)*8-1 downto i*8 ) <= wb_dat_i( (i+1)*8-1 downto i*8 );
                           end if;
                        end loop;
                     end if;

                  else
                     w_err <= '0';
                     w_rty <= '0';
                     w_ack <= '0';
                  end if;

               end if;
            end process;
  
   end generate;


   gen_write_ack2 : if WR_DELAY = 1 generate

            -- generate write ack after a delay
            -- and write byte-wise data to ram, depending on select
            write_ack_p2 : process( wb_clk_i, wb_rst_i, wb_cyc_i, wb_stb_i, wb_we_i, w_ack, w_err, w_rty ) begin

               if wb_rst_i = '1' then

                  load_ram( ram );
                  err_rty_count_w <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE ) );
                  w_err <= '0';
                  w_rty <= '0';
                  w_ack <= '0';

               elsif wb_clk_i'event and wb_clk_i = '1' then

                  if wb_cyc_i = '1' and wb_stb_i = '1' and wb_we_i = '1' 
                     and not ( w_ack = '1' or w_err = '1' or w_rty = '1' ) then

                     if err_rty_count_w = ERR_RTY_COUNT_ZERO then
                        err_rty_count_w <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE ) );
                     else
                        err_rty_count_w <= err_rty_count_w - 1;
                     end if;



                     if ( err_rty_count_w = err_rty_zero and WITH_ERR_OR_RTY = "10" ) then
                        w_err <= '0';
                        w_rty <= '1';
                        w_ack <= '0';
                     elsif ( err_rty_count_w = err_rty_zero and WITH_ERR_OR_RTY = "01" ) then
                        w_err <= '1';
                        w_rty <= '0';
                        w_ack <= '0';
                     else
                        w_err <= '0';
                        w_rty <= '0';
                        w_ack <= '1';
                        for i in 0 to ( WB_DAT_W/8)-1 loop
                           if ( wb_sel_i(i) = '1' ) then
                              ram( conv_integer( ram_adr ) )( (i+1)*8-1 downto i*8 ) <= wb_dat_i( (i+1)*8-1 downto i*8 );
                           end if;
                        end loop;
                     end if;
                  else
                     w_err <= '0';
                     w_rty <= '0';
                     w_ack <= '0';
                  end if;

               end if;




            end process;
  
   end generate;



   gen_write_ack3 : if WR_DELAY = 0 generate


            write_ack_p3 : process( wb_clk_i, wb_rst_i, wb_cyc_i, wb_stb_i, wb_we_i, err_rty_count_w ) begin

               if wb_rst_i = '1' then
                  load_ram( ram );
                  err_rty_count_w <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE ) );
               elsif wb_clk_i = '1' and wb_clk_i'event then

                  if w_ack = '1' or w_rty = '1' or w_err = '1' then
                     if err_rty_count_w = ERR_RTY_COUNT_ZERO then
                        err_rty_count_w <= std_logic_vector( to_unsigned( ERR_RTY_INTERVAL, ERR_RTY_COUNT_SIZE ) );
                     else
                        err_rty_count_w <= err_rty_count_w - 1;
                     end if;
                  end if;

                  if w_ack = '1' then

                     for i in 0 to ( WB_DAT_W/8)-1 loop
                        if ( wb_sel_i(i) = '1' ) then
                           ram( conv_integer( ram_adr ) )( (i+1)*8-1 downto i*8 ) <= wb_dat_i( (i+1)*8-1 downto i*8 );
                        end if;
                     end loop;
                  end if;
               end if;


               w_err <= '0';
               w_rty <= '0';
               w_ack <= '0';


               if ( wb_cyc_i = '1' and wb_stb_i = '1'  and wb_we_i = '1' ) then

                  if ( err_rty_count_w = err_rty_zero and WITH_ERR_OR_RTY = "10" ) then
                     w_rty <= '1';
                  elsif ( err_rty_count_w = err_rty_zero and WITH_ERR_OR_RTY = "01" ) then
                     w_err <= '1';
                  else
                     w_ack <= '1';
                  end if;

               end if;




            end process;

   end generate;



   -- assign byte-wise ram output, depending on select line
   ram_line <= ram( conv_integer( ram_adr ) );
   output_loop : for i in 0 to WB_DAT_W/8-1 generate
      with wb_sel_i( i ) select
         wb_dat_o( (i+1)*8-1 downto i*8 ) <= ram_line( (i+1)*8-1 downto i*8 ) when '1',
                                                                  "00000000"  when others;   
   end generate;
                                 


   wb_ack_o <= w_ack or r_ack; 
   wb_err_o <= w_err or r_err;
   wb_rty_o <= w_rty or r_rty;



end architecture IMP;
