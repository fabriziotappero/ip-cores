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




entity plb2wb_rbuf is
   generic(
      SYNCHRONY                     : boolean := true;
      WB_DWIDTH                     : integer := 32
   );
   port(

      wb_clk_i                      : IN  std_logic;
      SPLB_Clk                      : IN  std_logic;
      plb2wb_rst                      : IN  std_logic;

      wb_dat_i                      : IN  std_logic_vector( WB_DWIDTH-1 downto 0 );

      RBF_rBus                      : out std_logic_vector( WB_DWIDTH-1 downto 0 );
      RBF_empty                     : out std_logic;
      RBF_almostEmpty               : out std_logic;
      RBF_full                      : out std_logic;

      RBF_rdErrOut                  : out std_logic;
      RBF_rdErrIn                   : in  std_logic;

      TCU_rbufWEn                   : in  std_logic;
      TCU_rbufREn                   : in  std_logic
   );
end entity plb2wb_rbuf;



architecture IMP_32 of plb2wb_rbuf is


   signal rbuf_dout     : std_logic_vector( WB_DWIDTH+1-1 downto 0 );
   signal rbuf_din      : std_logic_vector( WB_DWIDTH+1-1 downto 0 );
   signal pre_load_reg  : std_logic_vector( WB_DWIDTH+1-1 downto 0 );
   signal rd_en         : std_logic;
begin


   rbuf_din <= RBF_rdErrIn & wb_dat_i;

   rd_en          <= TCU_rbufREn;
   RBF_rBus       <= rbuf_dout( WB_DWIDTH-1 downto 0 );

   RBF_rdErrOut   <= rbuf_dout(32);



   rbuf : entity plb2wb_bridge_v1_00_a.fifo_rdat( IMP )
   generic map(
      SYNCHRONY      => SYNCHRONY,
      WB_DWIDTH      => WB_DWIDTH
   )
   port map(
      rd_en          => rd_en, 
      wr_en          => TCU_rbufWEn,
      full           => RBF_full,
      empty          => RBF_empty,
      almost_empty   => RBF_almostEmpty,
      wr_clk         => wb_clk_i,
      rst            => plb2wb_rst,
      rd_clk         => SPLB_Clk,
      dout           => rbuf_dout,
      din            => rbuf_din
   );




end architecture IMP_32;

