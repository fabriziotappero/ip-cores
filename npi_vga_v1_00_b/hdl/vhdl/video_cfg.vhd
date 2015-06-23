----------------------------------------------------------------------
----                                                              ----
---- Cfg package                                                  ----
----                                                              ----
---- Author(s):                                                   ----
---- - Slavek Valach, s.valach@dspfpga.com                        ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU General          ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.0 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU General Public License for more details.----
----                                                              ----
---- You should have received a copy of the GNU General           ----
---- Public License along with this source; if not, download it   ----
---- from http://www.gnu.org/licenses/gpl.txt                     ----
----                                                              ----
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package video_cfg is

type video_params_t is record 
   x_size         : natural;
   y_size         : natural;
   pixel_depth    : natural;
   h_back_porch   : natural;
   h_front_porch  : natural;
   h_sync_width   : natural;
   h_sync_pol     : std_logic;
   v_back_porch   : natural;
   v_front_porch  : natural;
   v_sync_width   : natural;
   v_sync_pol     : std_logic;
end record;

function log2(x : natural) return integer;
function get_NPI_Size(constant C_NPI_DATA_WIDTH : natural; constant C_NPI_BURST_SIZE : natural) return std_logic_vector;

end video_cfg;

package body video_cfg is

function log2(x : natural) return integer is
   variable i  : integer := 0;   
begin 
   if x = 0 then 
      return 0;
   else
      while 2**i < x loop
         i := i+1;
      end loop;
      return i;
   end if;
end function log2; 

function get_NPI_Size(constant C_NPI_DATA_WIDTH : natural; constant C_NPI_BURST_SIZE : natural) return std_logic_vector is
BEGIN
   Case C_NPI_BURST_SIZE is
      When 4 => 
         If C_NPI_DATA_WIDTH = 64 Then
         ASSERT FALSE
            REPORT "4 byte NPI Burst size is not supported for 64bit interface!"
            SEVERITY ERROR;
            return x"F";
         Else
            return x"0";
         End If;
         
      When 8 => 
         If C_NPI_DATA_WIDTH = 64 Then
            return x"0";
         Else
            REPORT "8 byte NPI Burst size is not supported for 32bit interface!"
            SEVERITY ERROR;
            return x"F";
         End If;

      When 16 =>
         If C_NPI_DATA_WIDTH = 64 Then
            return x"1";
         Else
            return x"1";
         End If;

      When 32 =>      
         If C_NPI_DATA_WIDTH = 64 Then
            return x"2";
         Else
            return x"2";
         End If;
         
      When 64 =>
         If C_NPI_DATA_WIDTH = 64 Then
            return x"3";
         Else
            return x"3";
         End If;

      When 128 =>
         If C_NPI_DATA_WIDTH = 64 Then
            return x"4";
         Else
            return x"4";
         End If;
      When 256 =>                   
         If C_NPI_DATA_WIDTH = 64 Then
            return x"5";
         Else
            ASSERT FALSE
               REPORT "NPI Burst size is not supported!"
               SEVERITY ERROR;
            return x"F";
         End If;

      When Others => 
         ASSERT FALSE
            REPORT "NPI Burst size is not supported!"
            SEVERITY ERROR;
         return x"F";
   End Case;
END FUNCTION get_NPI_Size;

end video_cfg;
