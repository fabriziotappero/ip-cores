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


entity fifo_stat2plb is 
   generic
   (
      SYNCHRONY               : boolean := true; -- true = synchron
      WB_DWIDTH               : integer range WB_DWIDTH_MIN to WB_DWIDTH_MAX := 32;
      WB_AWIDTH               : integer range WB_AWIDTH_MIN to WB_AWIDTH_MAX := 32;
      C_SPLB_MID_WIDTH        : integer := 3

   );
   port(
      rd_en   : in  std_logic      := 'X'; 
      wr_en   : in  std_logic      := 'X'; 
      full    : out std_logic; 
      empty   : out std_logic; 
      wr_clk  : in  std_logic      := 'X'; 
      rst     : in  std_logic      := 'X'; 
      rd_clk  : in  std_logic      := 'X'; 
      dout    : out std_logic_vector ( IRQ_INFO_SIZE + WB_AWIDTH + WB_DWIDTH + C_SPLB_MID_WIDTH + STATUS2PLB_INFO_SIZE -1 downto 0 ); 
      din     : in  std_logic_vector ( IRQ_INFO_SIZE + WB_AWIDTH + WB_DWIDTH + C_SPLB_MID_WIDTH + STATUS2PLB_INFO_SIZE -1 downto 0 ) 
   );
end entity fifo_stat2plb;



architecture IMP of fifo_stat2plb is

constant VEC_MIN_SIZE : integer := IRQ_INFO_SIZE + WB_AWIDTH + WB_DWIDTH + 1 + STATUS2PLB_INFO_SIZE;


component fifo_stat2plb_cc_1 is
  port (
    rd_en : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    rst : in STD_LOGIC := 'X'; 
    dout : out STD_LOGIC_VECTOR ( VEC_MIN_SIZE-1 downto 0 ); 
    din : in STD_LOGIC_VECTOR ( VEC_MIN_SIZE-1 downto 0 ) 
  );
end component fifo_stat2plb_cc_1;


component fifo_stat2plb_ic_1 is
  port (
    rd_en : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    wr_clk : in STD_LOGIC := 'X'; 
    rst : in STD_LOGIC := 'X'; 
    rd_clk : in STD_LOGIC := 'X'; 
    dout : out STD_LOGIC_VECTOR ( VEC_MIN_SIZE-1 downto 0 ); 
    din : in STD_LOGIC_VECTOR ( VEC_MIN_SIZE-1 downto 0 ) 
  );
end component fifo_stat2plb_ic_1;

component fifo_stat2plb_cc_2 is
  port (
    rd_en : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    rst : in STD_LOGIC := 'X'; 
    dout : out STD_LOGIC_VECTOR ( VEC_MIN_SIZE+1-1 downto 0 ); 
    din : in STD_LOGIC_VECTOR ( VEC_MIN_SIZE+1-1 downto 0 ) 
  );
end component fifo_stat2plb_cc_2;


component fifo_stat2plb_ic_2 is
  port (
    rd_en : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    wr_clk : in STD_LOGIC := 'X'; 
    rst : in STD_LOGIC := 'X'; 
    rd_clk : in STD_LOGIC := 'X'; 
    dout : out STD_LOGIC_VECTOR ( VEC_MIN_SIZE+1-1 downto 0 ); 
    din : in STD_LOGIC_VECTOR ( VEC_MIN_SIZE+1-1 downto 0 ) 
  );
end component fifo_stat2plb_ic_2;

component fifo_stat2plb_cc_3 is
  port (
    rd_en : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    rst : in STD_LOGIC := 'X'; 
    dout : out STD_LOGIC_VECTOR ( VEC_MIN_SIZE+2-1 downto 0 ); 
    din : in STD_LOGIC_VECTOR ( VEC_MIN_SIZE+2-1 downto 0 ) 
  );
end component fifo_stat2plb_cc_3;


component fifo_stat2plb_ic_3 is
  port (
    rd_en : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    wr_clk : in STD_LOGIC := 'X'; 
    rst : in STD_LOGIC := 'X'; 
    rd_clk : in STD_LOGIC := 'X'; 
    dout : out STD_LOGIC_VECTOR ( VEC_MIN_SIZE+2-1 downto 0 ); 
    din : in STD_LOGIC_VECTOR ( VEC_MIN_SIZE+2-1 downto 0 ) 
  );
end component fifo_stat2plb_ic_3;

component fifo_stat2plb_cc_4 is
  port (
    rd_en : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    rst : in STD_LOGIC := 'X'; 
    dout : out STD_LOGIC_VECTOR ( VEC_MIN_SIZE+3-1 downto 0 ); 
    din : in STD_LOGIC_VECTOR ( VEC_MIN_SIZE+3-1 downto 0 ) 
  );
end component fifo_stat2plb_cc_4;


component fifo_stat2plb_ic_4 is
  port (
    rd_en : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    wr_clk : in STD_LOGIC := 'X'; 
    rst : in STD_LOGIC := 'X'; 
    rd_clk : in STD_LOGIC := 'X'; 
    dout : out STD_LOGIC_VECTOR ( VEC_MIN_SIZE+3-1 downto 0 ); 
    din : in STD_LOGIC_VECTOR ( VEC_MIN_SIZE+3-1 downto 0 ) 
  );
end component fifo_stat2plb_ic_4;



begin

fifo_cc_1: if ( SYNCHRONY = true and WB_DWIDTH = 32 and C_SPLB_MID_WIDTH = 1 ) generate
U_fifo_cc : fifo_stat2plb_cc_1
   port map(
      rd_en    => rd_en,
      wr_en    => wr_en,
      full     => full,
      empty    => empty,
      clk      => rd_clk,  -- rd_clk must be the same than wr_clk
      rst      => rst,
      dout     => dout,
      din      => din
   );
end generate fifo_cc_1;


fifo_cc_2: if ( SYNCHRONY = true and WB_DWIDTH = 32 and C_SPLB_MID_WIDTH = 2 ) generate
U_fifo_cc : fifo_stat2plb_cc_2
   port map(
      rd_en    => rd_en,
      wr_en    => wr_en,
      full     => full,
      empty    => empty,
      clk      => rd_clk,  -- rd_clk must be the same than wr_clk
      rst      => rst,
      dout     => dout,
      din      => din
   );
end generate fifo_cc_2;


fifo_cc_3: if ( SYNCHRONY = true and WB_DWIDTH = 32 and C_SPLB_MID_WIDTH = 3 ) generate
U_fifo_cc : fifo_stat2plb_cc_3
   port map(
      rd_en    => rd_en,
      wr_en    => wr_en,
      full     => full,
      empty    => empty,
      clk      => rd_clk,  -- rd_clk must be the same than wr_clk
      rst      => rst,
      dout     => dout,
      din      => din
   );
end generate fifo_cc_3;


fifo_cc_4: if ( SYNCHRONY = true and WB_DWIDTH = 32 and C_SPLB_MID_WIDTH = 4) generate
U_fifo_cc : fifo_stat2plb_cc_4
   port map(
      rd_en    => rd_en,
      wr_en    => wr_en,
      full     => full,
      empty    => empty,
      clk      => rd_clk,  -- rd_clk must be the same than wr_clk
      rst      => rst,
      dout     => dout,
      din      => din
   );
end generate fifo_cc_4;




fifo_ic_1: if ( SYNCHRONY = false and WB_DWIDTH = 32 and C_SPLB_MID_WIDTH = 1 ) generate
U_fifo_ic : fifo_stat2plb_ic_1
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
end generate fifo_ic_1;


fifo_ic_2: if ( SYNCHRONY = false and WB_DWIDTH = 32 and C_SPLB_MID_WIDTH = 2 ) generate
U_fifo_ic : fifo_stat2plb_ic_2
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
end generate fifo_ic_2;


fifo_ic_3: if ( SYNCHRONY = false and WB_DWIDTH = 32 and C_SPLB_MID_WIDTH = 3 ) generate
U_fifo_ic : fifo_stat2plb_ic_3
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
end generate fifo_ic_3;


fifo_ic_4: if ( SYNCHRONY = false and WB_DWIDTH = 32 and C_SPLB_MID_WIDTH = 4 ) generate
U_fifo_ic : fifo_stat2plb_ic_4
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
end generate fifo_ic_4;





end architecture IMP;
