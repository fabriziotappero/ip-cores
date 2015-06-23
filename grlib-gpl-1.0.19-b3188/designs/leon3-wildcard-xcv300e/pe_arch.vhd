------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
--============================================================================--
-- Design unit  : PE architecture (architecture declarations)
--
-- File name    : pe_arch.vhd
--
-- Purpose      : Wrapper for simulation
--
-- Library      : PE_Lib
--
-- Authors      : Mr Sandi Alexander Habinc
--                Gaisler Research
--
-- Contact      : mailto:support@gaisler.com
--                http://www.gaisler.com
--
-- Disclaimer   : All information is provided "as is", there is no warranty that
--                the information is correct or suitable for any purpose,
--                neither implicit nor explicit.
--============================================================================--

--============================== Architecture ================================--

library  IEEE;
use      IEEE.Std_Logic_1164.all;

library  PE_Lib;
use      PE_Lib.PE_Package.all;

architecture Wrapper of PE is

   component WildFpga is
   port (
      Clocks_F_Clk:                in     std_logic;
      Clocks_M_Clk:                in     std_logic;
      Clocks_P_Clk:                in     std_logic;
      Clocks_K_Clk:                in     std_logic;
      Clocks_IO_Clk:               in     std_logic;

      Clocks_M_Clk_Out_PE:         out    std_logic;
      Clocks_M_Clk_Out_CB_Ctrl:    out    std_logic;
      Clocks_M_Clk_Out_Right_Mem:  out    std_logic;
      Clocks_M_Clk_Out_Left_Mem:   out    std_logic;
      Clocks_P_Clk_Out_PE:         out    std_logic;
      Clocks_P_Clk_Out_CB_Ctrl:    out    std_logic;

      Reset_Reset:                 in     std_logic;
      Audio_Audio:                 out    std_logic;

      LAD_Bus_Addr_Data:           inout  std_logic_vector (31 downto 0);
      LAD_Bus_AS_n:                in     std_logic;
      LAD_Bus_DS_n:                in     std_logic;
      LAD_Bus_WR_n:                in     std_logic;
      LAD_Bus_CS_n:                in     std_logic;
      LAD_Bus_Reg_n:               in     std_logic;
      LAD_Bus_Ack_n:               out    std_logic;
      LAD_Bus_Int_Req_n:           out    std_logic;
      LAD_Bus_DMA_0_Data_OK_n:     out    std_logic;
      LAD_Bus_DMA_0_Burst_OK:      out    std_logic;
      LAD_Bus_DMA_1_Data_OK_n:     out    std_logic;
      LAD_Bus_DMA_1_Burst_OK:      out    std_logic;
      LAD_Bus_Reg_Data_OK_n:       out    std_logic;
      LAD_Bus_Reg_Burst_OK:        out    std_logic;
      LAD_Bus_Force_K_Clk_n:       out    std_logic;
      LAD_Bus_Reserved:            out    std_logic;

      Left_Mem_Addr:               out    std_logic_vector (18 downto 0);
      Left_Mem_Data:               inout  std_logic_vector (35 downto 0);
      Left_Mem_Byte_WR_n:          out    std_logic_vector (3 downto 0);
      Left_Mem_CS_n:               out    std_logic;
      Left_Mem_CE_n:               out    std_logic;
      Left_Mem_WE_n:               out    std_logic;
      Left_Mem_OE_n:               out    std_logic;
      Left_Mem_Sleep_EN:           out    std_logic;
      Left_Mem_Load_EN_n:          out    std_logic;
      Left_Mem_Burst_Mode:         out    std_logic;

      Right_Mem_Addr:              out    std_logic_vector (18 downto 0);
      Right_Mem_Data:              inout  std_logic_vector (35 downto 0);
      Right_Mem_Byte_WR_n:         out    std_logic_vector (3 downto 0);
      Right_Mem_CS_n:              out    std_logic;
      Right_Mem_CE_n:              out    std_logic;
      Right_Mem_WE_n:              out    std_logic;
      Right_Mem_OE_n:              out    std_logic;
      Right_Mem_Sleep_EN:          out    std_logic;
      Right_Mem_Load_EN_n:         out    std_logic;
      Right_Mem_Burst_Mode:        out    std_logic;

      Left_IO:                     inout  std_logic_vector (12 downto 0);
      Right_IO:                    inout  std_logic_vector (12 downto 0));
   end component;

   signal   Clocks_M_Clk_Out_Right_Del:  std_logic;
   signal   Clocks_M_Clk_Out_Left_Del:   std_logic;

begin

   Init_PE_Pads ( Pads );

   Pads.Clocks.M_Clk_Out_Right_Mem  <= transport Clocks_M_Clk_Out_Right_Del after 2 ns;
   Pads.Clocks.M_Clk_Out_Left_Mem   <= transport Clocks_M_Clk_Out_Left_Del  after 2 ns;

   FPGA: WildFpga
   port map (
      Clocks_F_Clk                  => Pads.Clocks.F_Clk,
      Clocks_M_Clk                  => Pads.Clocks.M_Clk,
      Clocks_P_Clk                  => Pads.Clocks.P_Clk,
      Clocks_K_Clk                  => Pads.Clocks.K_Clk,
      Clocks_IO_Clk                 => Pads.Clocks.IO_Clk,
      Clocks_M_Clk_Out_PE           => Pads.Clocks.M_Clk_Out_PE,
      Clocks_M_Clk_Out_CB_Ctrl      => Pads.Clocks.M_Clk_Out_CB_Ctrl,
      Clocks_M_Clk_Out_Right_Mem    => Clocks_M_Clk_Out_Right_Del,
      Clocks_M_Clk_Out_Left_Mem     => Clocks_M_Clk_Out_Left_Del,
      Clocks_P_Clk_Out_PE           => Pads.Clocks.P_Clk_Out_PE,
      Clocks_P_Clk_Out_CB_Ctrl      => Pads.Clocks.P_Clk_Out_CB_Ctrl,
      Reset_Reset                   => Pads.Reset,
      Audio_Audio                   => Pads.Audio,
      LAD_Bus_Addr_Data             => Pads.LAD_Bus.Addr_Data,
      LAD_Bus_AS_n                  => Pads.LAD_Bus.AS_n,
      LAD_Bus_DS_n                  => Pads.LAD_Bus.DS_n,
      LAD_Bus_WR_n                  => Pads.LAD_Bus.WR_n,
      LAD_Bus_CS_n                  => Pads.LAD_Bus.CS_n,
      LAD_Bus_Reg_n                 => Pads.LAD_Bus.Reg_n,
      LAD_Bus_Ack_n                 => Pads.LAD_Bus.Ack_n,
      LAD_Bus_Int_Req_n             => Pads.LAD_Bus.Int_Req_n,
      LAD_Bus_DMA_0_Data_OK_n       => Pads.LAD_Bus.DMA_0_Data_OK_n,
      LAD_Bus_DMA_0_Burst_OK        => Pads.LAD_Bus.DMA_0_Burst_OK,
      LAD_Bus_DMA_1_Data_OK_n       => Pads.LAD_Bus.DMA_1_Data_OK_n,
      LAD_Bus_DMA_1_Burst_OK        => Pads.LAD_Bus.DMA_1_Burst_OK,
      LAD_Bus_Reg_Data_OK_n         => Pads.LAD_Bus.Reg_Data_OK_n,
      LAD_Bus_Reg_Burst_OK          => Pads.LAD_Bus.Reg_Burst_OK,
      LAD_Bus_Force_K_Clk_n         => Pads.LAD_Bus.Force_K_Clk_n,
      LAD_Bus_Reserved              => Pads.LAD_Bus.Reserved,
      Left_Mem_Addr                 => Pads.Left_Mem.Addr,
      Left_Mem_Data                 => Pads.Left_Mem.Data,
      Left_Mem_Byte_WR_n            => Pads.Left_Mem.Byte_WR_n,
      Left_Mem_CS_n                 => Pads.Left_Mem.CS_n,
      Left_Mem_CE_n                 => Pads.Left_Mem.CE_n,
      Left_Mem_WE_n                 => Pads.Left_Mem.WE_n,
      Left_Mem_OE_n                 => Pads.Left_Mem.OE_n,
      Left_Mem_Sleep_EN             => Pads.Left_Mem.Sleep_EN,
      Left_Mem_Load_EN_n            => Pads.Left_Mem.Load_EN_n,
      Left_Mem_Burst_Mode           => Pads.Left_Mem.Burst_Mode,
      Right_Mem_Addr                => Pads.Right_Mem.Addr,
      Right_Mem_Data                => Pads.Right_Mem.Data,
      Right_Mem_Byte_WR_n           => Pads.Right_Mem.Byte_WR_n,
      Right_Mem_CS_n                => Pads.Right_Mem.CS_n,
      Right_Mem_CE_n                => Pads.Right_Mem.CE_n,
      Right_Mem_WE_n                => Pads.Right_Mem.WE_n,
      Right_Mem_OE_n                => Pads.Right_Mem.OE_n,
      Right_Mem_Sleep_EN            => Pads.Right_Mem.Sleep_EN,
      Right_Mem_Load_EN_n           => Pads.Right_Mem.Load_EN_n,
      Right_Mem_Burst_Mode          => Pads.Right_Mem.Burst_Mode,
      Left_IO                       => Pads.Left_IO,
      Right_IO                      => Pads.Right_IO);

end architecture Wrapper; --==================================================--
