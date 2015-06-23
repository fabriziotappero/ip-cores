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

library plb2wb_bridge_v1_00_a;



entity plb2wb_wbuf is

   generic(
      SYNCHRONY                     : boolean := true;
      C_SPLB_DWIDTH                 : integer := 32;
      C_SPLB_NATIVE_DWIDTH          : integer := 32;
      C_SPLB_SIZE_WIDTH             : integer := 4
   );
   port(
      wb_clk_i                      : IN  std_logic;
      SPLB_Clk                      : IN  std_logic;
      plb2wb_rst                    : IN  std_logic;


      PLB_size                      : in  std_logic_vector( 0 to C_SPLB_SIZE_WIDTH-1   );
      PLB_wrDBus                    : IN  std_logic_vector( 0 to C_SPLB_DWIDTH-1       );


      TCU_wbufWEn                   : in  std_logic;
      TCU_wbufREn                   : in  std_logic;
      
      WBF_empty                     : OUT std_logic;
      WBF_full                      : OUT std_logic;
      WBF_wBus                      : OUT std_logic_vector( 0 to C_SPLB_NATIVE_DWIDTH-1  )
      


   );
end entity plb2wb_wbuf;


architecture IMP_32 of plb2wb_wbuf is
   
   constant FIFO_IN_OUT_SIZE  : integer := C_SPLB_NATIVE_DWIDTH ;

   signal wbuf_dout           : std_logic_vector( FIFO_IN_OUT_SIZE-1 downto 0 );
   signal wbuf_din            : std_logic_vector( FIFO_IN_OUT_SIZE-1 downto 0 );
   signal wbuf_wen            : std_logic;   

begin

   --TODO: WBF_full must be or'ed with mid-buffer-full
   -- and it must not be written to mid-buffer if it is full!


   wbuf_wen <= TCU_wbufWEn; 
   wbuf_din <= PLB_wrDBus( 0 to 31 );
   WBF_wBus <= wbuf_dout( 31 downto 0 );

   wbuf : entity plb2wb_bridge_v1_00_a.fifo_wdat( IMP )
   generic map(
      SYNCHRONY            => SYNCHRONY,
      C_SPLB_NATIVE_DWIDTH => C_SPLB_NATIVE_DWIDTH
   )
   port map(
      rd_en          => TCU_wbufREn,
      wr_en          => wbuf_wen,
      full           => WBF_full,
      empty          => WBF_empty,
      wr_clk         => SPLB_Clk,
      rst            => plb2wb_rst,
      rd_clk         => wb_clk_i,
      dout           => wbuf_dout,
      din            => wbuf_din
   );

end architecture IMP_32;
