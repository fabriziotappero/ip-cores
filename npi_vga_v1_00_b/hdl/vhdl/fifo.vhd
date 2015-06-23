----------------------------------------------------------------------
----                                                              ----
---- fifo wrapper                                                 ----
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity d_fifo is
generic (
   C_VD_DATA_WIDTH               : integer := 64;
   C_FAMILY                      : string  := "virtex5");
port (
-- System interface      
   Sys_Clk                       : in     std_logic;                    -- Base system clock
   NPI_CLK                       : in     std_logic;
   Sys_Rst                       : in     std_logic;                    -- System reset

-- DMA Channel interface
--   DMA_CLK                       : in     std_logic;     -- DMA clock time domain (the asynchronous FIFO will be used)
   DMA_DREQ                      : out    std_logic;     -- Data request
   DMA_DACK                      : in     std_logic;     -- Data ack
   DMA_RSYNC                     : out    std_logic;     -- Synchronization reset (restarts the channel)
   DMA_TC                        : in     std_logic;     -- Terminal count (the signal is generated at the end of the transfer)
   DMA_DATA                      : in     std_logic_vector(C_VD_DATA_WIDTH - 1 downto 0);

-- User interface (the reader side)
   USER_CLK                      : in     std_logic;                    -- User clk is used as an asynchronous read clock
   USER_RST                      : in     std_logic;
   USER_DREQ                     : in     std_logic;
   USER_RD                       : in     std_logic;
   USER_DRDY                     : out    std_logic;

   XXX                           : out    std_logic_vector(3 downto 0);
   
   USER_DATA                     : out    std_logic_vector(31 downto 0));

end d_fifo;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------
architecture implementation of d_fifo is

component fifo_sp_64
port (
   din                        : in     std_logic_vector(63 downto 0);
   rd_clk                     : in     std_logic;
   rd_en                      : in     std_logic;
   rst                        : in     std_logic;
   wr_clk                     : in     std_logic;
   wr_en                      : in     std_logic;
   dout                       : out    std_logic_vector(31 downto 0);
   empty                      : out    std_logic;
   full                       : out    std_logic;
   prog_empty                 : out    std_logic;
   prog_full                  : out    std_logic);
end component;

component fifo_v4_64
port (
   din                        : in     std_logic_vector(63 downto 0);
   rd_clk                     : in     std_logic;
   rd_en                      : in     std_logic;
   rst                        : in     std_logic;
   wr_clk                     : in     std_logic;
   wr_en                      : in     std_logic;
   dout                       : out    std_logic_vector(31 downto 0);
   empty                      : out    std_logic;
   full                       : out    std_logic;
   prog_empty                 : out    std_logic;
   prog_full                  : out    std_logic);
end component;

component fifo_v5_64
port (
   din                        : in     std_logic_vector(63 downto 0);
   rd_clk                     : in     std_logic;
   rd_en                      : in     std_logic;
   rst                        : in     std_logic;
   wr_clk                     : in     std_logic;
   wr_en                      : in     std_logic;
   dout                       : out    std_logic_vector(31 downto 0);
   empty                      : out    std_logic;
   full                       : out    std_logic;
   prog_empty                 : out    std_logic;
   prog_full                  : out    std_logic);
end component;

component fifo_sp_32
port (
   din                        : in     std_logic_vector(31 downto 0);
   rd_clk                     : in     std_logic;
   rd_en                      : in     std_logic;
   rst                        : in     std_logic;
   wr_clk                     : in     std_logic;
   wr_en                      : in     std_logic;
   dout                       : out    std_logic_vector(31 downto 0);
   empty                      : out    std_logic;
   full                       : out    std_logic;
   prog_empty                 : out    std_logic;
   prog_full                  : out    std_logic);
end component;

component fifo_v4_32
port (
   din                        : in     std_logic_vector(31 downto 0);
   rd_clk                     : in     std_logic;
   rd_en                      : in     std_logic;
   rst                        : in     std_logic;
   wr_clk                     : in     std_logic;
   wr_en                      : in     std_logic;
   dout                       : out    std_logic_vector(31 downto 0);
   empty                      : out    std_logic;
   full                       : out    std_logic;
   prog_empty                 : out    std_logic;
   prog_full                  : out    std_logic);
end component;

component fifo_v5_32
port (
   din                        : in     std_logic_vector(31 downto 0);
   rd_clk                     : in     std_logic;
   rd_en                      : in     std_logic;
   rst                        : in     std_logic;
   wr_clk                     : in     std_logic;
   wr_en                      : in     std_logic;
   dout                       : out    std_logic_vector(31 downto 0);
   empty                      : out    std_logic;
   full                       : out    std_logic;
   prog_empty                 : out    std_logic;
   prog_full                  : out    std_logic);
end component;

constant low                     : std_logic := '0';
constant high                    : std_logic := '1';

signal fifo_prog_full            : std_logic;
signal fifo_rst                  : std_logic;
signal fifo_prog_empty           : std_logic;
signal fifo_data_out             : std_logic_vector(31 downto 0);
signal fifo_full                 : std_logic;
signal fifo_empty                : std_logic;
signal fifo_wr_en                : std_logic;

begin -- architecture IMP

   DMA_DREQ <= '1' When (USER_DREQ = '1') And (fifo_prog_full = '0') Else '0';
   fifo_rst <= '1' When (Sys_Rst = '1') Or (USER_RST = '1') Else '0';
   USER_DRDY <= Not fifo_prog_empty;

  fifo_wr_en <= '1' When DMA_DACK = '1' And Sys_Rst = '0' Else '0';
  
gen_sp : if (C_FAMILY = "spartan3e") Or (C_FAMILY = "spartan3a") generate
   sp_fw_64 :  If C_VD_DATA_WIDTH = 64 generate 
      data_fifo : fifo_sp_64   
      port map (
         din                     => DMA_DATA,
         rd_clk                  => User_Clk,
         rd_en                   => USER_RD,
         rst                     => fifo_rst,
         wr_clk                  => NPI_CLK,
         wr_en                   => fifo_wr_en,--DMA_DACK,
         dout                    => fifo_data_out,
         empty                   => fifo_empty,
         full                    => fifo_full,
         prog_empty              => fifo_prog_empty,
         prog_full               => fifo_prog_full);
   End Generate;  
   sp_fw_32 :  If C_VD_DATA_WIDTH = 32 generate 
      data_fifo : fifo_sp_32   
      port map (
         din                     => DMA_DATA,
         rd_clk                  => User_Clk,
         rd_en                   => USER_RD,
         rst                     => fifo_rst,
         wr_clk                  => NPI_CLK,
         wr_en                   => fifo_wr_en,--DMA_DACK,
         dout                    => fifo_data_out,
         empty                   => fifo_empty,
         full                    => fifo_full,
         prog_empty              => fifo_prog_empty,
         prog_full               => fifo_prog_full);
   End Generate;
End Generate;

gen_v4 : if (C_FAMILY = "virtex4") generate
   v4_fw_64 :  If C_VD_DATA_WIDTH = 64 generate 
      data_fifo : fifo_v4_64   
      port map (
         din                     => DMA_DATA,
         rd_clk                  => User_Clk,
         rd_en                   => USER_RD,
         rst                     => fifo_rst,
         wr_clk                  => NPI_CLK,
         wr_en                   => fifo_wr_en,--DMA_DACK,
         dout                    => fifo_data_out,
         empty                   => fifo_empty,
         full                    => fifo_full,
         prog_empty              => fifo_prog_empty,
         prog_full               => fifo_prog_full);
   End Generate;  
   v4_fw_32 :  If C_VD_DATA_WIDTH = 32 generate 
      data_fifo : fifo_v4_32   
      port map (
         din                     => DMA_DATA,
         rd_clk                  => User_Clk,
         rd_en                   => USER_RD,
         rst                     => fifo_rst,
         wr_clk                  => NPI_CLK,
         wr_en                   => fifo_wr_en,--DMA_DACK,
         dout                    => fifo_data_out,
         empty                   => fifo_empty,
         full                    => fifo_full,
         prog_empty              => fifo_prog_empty,
         prog_full               => fifo_prog_full);
   End Generate;
End Generate;

gen_v5 : if (C_FAMILY = "virtex5") generate
   v5_fw_64 :  If C_VD_DATA_WIDTH = 64 generate 
      data_fifo : fifo_v5_64   
      port map (
         din                     => DMA_DATA,
         rd_clk                  => User_Clk,
         rd_en                   => USER_RD,
         rst                     => fifo_rst,
         wr_clk                  => NPI_CLK,
         wr_en                   => fifo_wr_en,--DMA_DACK,
         dout                    => fifo_data_out,
         empty                   => fifo_empty,
         full                    => fifo_full,
         prog_empty              => fifo_prog_empty,
         prog_full               => fifo_prog_full);
   End Generate;  
   v5_fw_32 :  If C_VD_DATA_WIDTH = 32 generate 
      data_fifo : fifo_v5_32   
      port map (
         din                     => DMA_DATA,
         rd_clk                  => User_Clk,
         rd_en                   => USER_RD,
         rst                     => fifo_rst,
         wr_clk                  => NPI_CLK,
         wr_en                   => fifo_wr_en,--DMA_DACK,
         dout                    => fifo_data_out,
         empty                   => fifo_empty,
         full                    => fifo_full,
         prog_empty              => fifo_prog_empty,
         prog_full               => fifo_prog_full);
   End Generate;
End Generate;

USER_DATA <= fifo_data_out;

XXX <= fifo_rst & fifo_prog_full & fifo_full & fifo_empty;

end implementation;
