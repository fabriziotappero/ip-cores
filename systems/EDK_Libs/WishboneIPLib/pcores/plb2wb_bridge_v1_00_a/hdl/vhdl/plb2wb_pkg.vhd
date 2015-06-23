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
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

package plb2wb_pkg is

   --
   --    The range of the address pipeline depth
   constant PIPE_D_MIN        : integer := 2;
   constant PIPE_D_MAX        : integer := 512;


   --     The range of the wishbone-data-bus width
   constant WB_DWIDTH_MIN     : integer := 32;
   constant WB_DWIDTH_MAX     : integer := 64;

   --     The range of the wishbone-address-bus width
   constant WB_AWIDTH_MIN     : integer := 32;
   constant WB_AWIDTH_MAX     : integer := 64;

   constant PLB_DWIDTH_MIN    : integer := 32;
   constant PLB_DWIDTH_MAX    : integer := 128;




   --
   -- error and reset info types and functions
   --
   constant STATUS2PLB_INFO_SIZE : integer := 3;

   constant STATUS2PLB_W_ERR     : integer := 0 ;
   constant STATUS2PLB_RST       : integer := 1 ;
   constant STATUS2PLB_IRQ       : integer := 2 ;

   --     The size data-size of the read/write buffer
   constant RBUF_DWIDTH32     : integer := 33;
   constant WBUF_DWIDTH32     : integer := 32;



   constant STATUS_CONTINUE  : std_logic_vector := "0";
   constant STATUS_ABORT     : std_logic_vector := "1";



   constant IRQ_INFO_SIZE  : integer := 32;


   function log2( steps : natural ) return natural;

end package plb2wb_pkg;



package body plb2wb_pkg is


   function log2( steps : natural ) return natural is
   variable size : natural := 1;
   begin
      while( 2**size < steps ) loop
         size := size + 1;
      end loop;
      return size;
   end log2;

end package body plb2wb_pkg;


