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
use ieee.numeric_std.ALL;



entity plb2wb_fifo is
   generic(
      DATA_W : natural := 32;
      ADDR_W : natural := 4    
   );
   port(
      clk            : IN     std_logic;
      rst            : IN     std_logic;
      rd_en          : IN     std_logic;
      wr_en          : IN     std_logic;
      din            : IN     std_logic_vector( DATA_W-1 downto 0 );
      dout           : OUT    std_logic_vector( DATA_W-1 downto 0 );
      empty          : OUT    std_logic;
      full           : OUT    std_logic
   );
end entity plb2wb_fifo;


architecture IMP of plb2wb_fifo is


   type fifo_array_type is array( 2**ADDR_W-1 downto 0 ) 
      of std_logic_vector( DATA_W-1 downto 0 );
  
   type state_type is record 
      read_pointer   : std_logic_vector( ADDR_W-1 downto 0 );
      write_pointer  : std_logic_vector( ADDR_W-1 downto 0 );
      full           : std_logic;
      empty          : std_logic;
   end record;
  
   signal current_state, next_state : state_type         := -- to avoid modelsim warning at time: 0ps, iteration 0
   ( read_pointer => ( others => '0' ), write_pointer => ( others => '0' ), full => '0', empty => '0' );
   signal fifo_array                : fifo_array_type;
   signal read_write_select         : std_logic_vector( 1 downto 0 );
   signal rp_plus_1                 : std_logic_vector( ADDR_W-1 downto 0 );
   signal wp_plus_1                 : std_logic_vector( ADDR_W-1 downto 0 );

begin

   n_state : process( clk, rst ) begin
      
      if rst = '1' then
         current_state.read_pointer    <= ( others => '0' );
         current_state.write_pointer   <= ( others => '0' );
         current_state.full            <= '0';
         current_state.empty           <= '1';
      elsif clk'event and clk='1' then
         current_state <= next_state;
      end if;
   
   end process;


   wp_plus_1         <= std_logic_vector( unsigned (current_state.write_pointer) +1 ); 
   rp_plus_1         <= std_logic_vector( unsigned (current_state.read_pointer)  +1 );
   read_write_select <= wr_en & rd_en  ;

   states : process( current_state, read_write_select, wp_plus_1, rp_plus_1 ) begin

      next_state <= current_state;

      case read_write_select is
         when "00" =>   -- nothing to do
         when "01" =>   -- read
            
            if current_state.empty /= '1' then
               next_state.read_pointer  <= rp_plus_1;
               next_state.full          <= '0';
               if rp_plus_1 = current_state.write_pointer then
                  next_state.empty <= '1';
               end if;
            end if;

         when "10" =>   -- write
            
            if current_state.full /= '1' then
               next_state.write_pointer <= wp_plus_1;
               next_state.empty         <= '0';
               if wp_plus_1 = current_state.read_pointer then
                  next_state.full <= '1';
               end if;
            end if;

         when others =>  -- read and write
            next_state.write_pointer <= wp_plus_1;
            next_state.read_pointer  <= rp_plus_1;
         end case;


   end process;


   write_fifo : process( clk, rst ) begin
      if rst = '1' then
         fifo_array  <= ( others => ( others => '0' ) );
      elsif clk'event and clk='1' then
         if wr_en = '1' and current_state.full = '0' then
            fifo_array( to_integer( unsigned( current_state.write_pointer ))) <= din;
         end if;
      end if;

   end process;

   dout     <= fifo_array( to_integer( unsigned( current_state.read_pointer ) ) );
   full     <= current_state.full;
   empty    <= current_state.empty;


end architecture IMP;



