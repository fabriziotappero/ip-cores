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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library plb2wb_bridge_v1_00_a;
use plb2wb_bridge_v1_00_a.plb2wb_pkg.all;


entity fifo_wdat is 
   generic
   (
      SYNCHRONY               : boolean := true; -- true = synchron
                                                 -- false = asynchron
      C_SPLB_NATIVE_DWIDTH    : integer 
               range PLB_DWIDTH_MIN to PLB_DWIDTH_MAX := WBUF_DWIDTH32
   );
   port(
      rd_en   : in  std_logic      := 'X'; 
      wr_en   : in  std_logic      := 'X'; 
      wr_clk  : in  std_logic      := 'X'; 
      rst     : in  std_logic      := 'X'; 
      rd_clk  : in  std_logic      := 'X'; 
      din     : in  std_logic_vector ( WBUF_DWIDTH32-1 downto 0 );
      full    : out std_logic; 
      empty   : out std_logic; 
      dout    : out std_logic_vector ( WBUF_DWIDTH32-1 downto 0 ) 
   );
end entity fifo_wdat;




architecture IMP of fifo_wdat is


   component fifo_wdat_cc_32 is
     port (
       rd_en : in STD_LOGIC := 'X'; 
       wr_en : in STD_LOGIC := 'X'; 
       full : out STD_LOGIC; 
       empty : out STD_LOGIC; 
       clk : in STD_LOGIC := 'X'; 
       rst : in STD_LOGIC := 'X'; 
       dout : out STD_LOGIC_VECTOR ( WBUF_DWIDTH32-1 downto 0 ); 
       din : in STD_LOGIC_VECTOR ( WBUF_DWIDTH32-1 downto 0 ) 
     );
   end component fifo_wdat_cc_32;
   
   
   component fifo_wdat_ic_32 is
     port (
       rd_en : in STD_LOGIC := 'X'; 
       wr_en : in STD_LOGIC := 'X'; 
       full : out STD_LOGIC; 
       empty : out STD_LOGIC; 
       wr_clk : in STD_LOGIC := 'X'; 
       rst : in STD_LOGIC := 'X'; 
       rd_clk : in STD_LOGIC := 'X'; 
       dout : out STD_LOGIC_VECTOR ( WBUF_DWIDTH32-1 downto 0 ); 
       din : in STD_LOGIC_VECTOR ( WBUF_DWIDTH32-1 downto 0 ) 
     );
   end component fifo_wdat_ic_32;

begin



fifo1: if ( SYNCHRONY = true and C_SPLB_NATIVE_DWIDTH = WBUF_DWIDTH32 ) 
generate
U_fifo_cc : fifo_wdat_cc_32
   port map(
      rd_en    => rd_en,
      wr_en    => wr_en,
      full     => full,
      empty    => empty,
      clk      => rd_clk,     -- rd_clk is the same than wr_clk
      rst      => rst,
      dout     => dout,
      din      => din
   );
end generate fifo1;

fifo2: if ( SYNCHRONY = false and C_SPLB_NATIVE_DWIDTH = WBUF_DWIDTH32 ) 
generate
U_fifo_ic : fifo_wdat_ic_32
   port map(
      rd_en    => rd_en,
      wr_en    => wr_en,
      full     => full,
      empty    => empty,
      rd_clk   => rd_clk,
      wr_clk   => wr_clk,
      rst      => rst,
      dout     => dout,
      din      => din
   );
end generate fifo2;




end architecture IMP;
