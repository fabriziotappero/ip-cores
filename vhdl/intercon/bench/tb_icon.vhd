--------------------------------------------------------------------------------
-- layer[2] Testbench                                                         --
--------------------------------------------------------------------------------
-- Version: 1.0.0                                                             --
-- VHDL:    2002                                                              --
-- Sim:     Modelsim 10.0a PE Student Edition                                 --
--                                                                            --
--------------------------------------------------------------------------------
-- Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.iwb.all;
use work.iwbm.all;
use work.icon.all;
use work.icpu.all;
use work.imem.all;
use work.iflash.all;
-- use work.iddr.all;
use work.ivga.all;
use work.ikeyb.all;
use work.ipit.all;
use work.iuart.all;

entity tb_icon is
end tb_icon;

architecture tb of tb_icon is

   constant SIZE : positive := 11;     -- address bus size
   constant BUSS : positive := 32;     -- address bus width
   constant GRAN : positive := 8;      -- granularity  
   
   signal SF_OE        : std_logic;
   signal SF_CE        : std_logic;
   signal SF_WE        : std_logic;
   signal SF_BYTE      : std_logic;
   -- signal SF_STS       : in    std_logic;
   signal SF_A         : std_logic_vector(23 downto 0);
   signal SF_D         : std_logic_vector(7 downto 0);
   signal PF_OE        : std_logic;
   signal LCD_RW       : std_logic;
   signal LCD_E        : std_logic;
   signal SPI_ROM_CS   : std_logic;
   signal SPI_ADC_CONV : std_logic;
   signal SPI_DAC_CS   : std_logic;

   signal SD_CK_N  : std_logic;
   signal SD_CK_P  : std_logic;
   signal SD_CKE   : std_logic;
   signal SD_BA    : std_logic_vector(1 downto 0);
   signal SD_A     : std_logic_vector(12 downto 0);
   signal SD_CMD   : std_logic_vector(3 downto 0);
   signal SD_DM    : std_logic_vector(1 downto 0);
   signal SD_DQS   : std_logic_vector(1 downto 0);
   signal SD_DQ    : std_logic_vector(15 downto 0);
   
   signal VGA_HSYNC : std_logic;
   signal VGA_VSYNC : std_logic;
   signal VGA_RED   : std_logic;
   signal VGA_GREEN : std_logic;
   signal VGA_BLUE  : std_logic;
   
   signal PS2_CLK   : std_logic;
   signal PS2_DATA  : std_logic;
   
   signal RS232_DCE_RXD : std_logic;
   signal RS232_DCE_TXD : std_logic;
   
   signal ci : cpu_in_t;
   signal co : cpu_out_t;
   signal mi : master_in_t;
   signal mo : master_out_t;
   
   signal irq      : std_logic_vector(7 downto 0);
   signal pit_intr : std_logic;
   
   signal brami, flasi, ddri, dispi, keybi, piti, uartri, uartti : slave_in_t;
   signal bramo, flaso, ddro, dispo, keybo, pito, uartro, uartto : slave_out_t;
   
   signal LED : std_logic_vector(7 downto 0);
   
   signal CLK50_I : std_logic;
   signal CLK25_I : std_logic;    
   signal CLK25P90_I : std_logic;
   constant clk50_period : time := 20 ns;
   
   signal RST_I : std_logic;  
begin  
   
   irq <= "0000000" & pit_intr;

   clk50 : process
   begin
      CLK50_I <= '0';
      CLK25_I <= '0';
      CLK25P90_I <= '1';
      wait for clk50_period / 4;
      CLK50_I <= '1';
      CLK25_I <= '0';
      CLK25P90_I <= '0';
      wait for clk50_period / 4;  
      CLK50_I <= '0';
      CLK25_I <= '1';
      CLK25P90_I <= '0';
      wait for clk50_period / 4;
      CLK50_I <= '1';
      CLK25_I <= '1';
      CLK25P90_I <= '1';
      wait for clk50_period / 4;       
   end process;

   -----------------------------------------------------------------------------
   -- MIPS I Cpu                                                              --
   -----------------------------------------------------------------------------   
   cpu0 : cpu port map(
      ci => ci,
      co => co    
   );

   -----------------------------------------------------------------------------
   -- Cpu's Wishbone Master                                                   --
   -----------------------------------------------------------------------------   
   uut1 : wbm port map(
      ci  => ci,
      co  => co,
      mi  => mi,
      mo  => mo,
      LED => LED,
      irq => irq
   );

   -----------------------------------------------------------------------------
   -- Block Memory                                                            --
   -----------------------------------------------------------------------------
   -- NOTE: The starting point of execution.   
   mem0 : mem
      port map(
         si => brami,
         so => bramo
      );
      
   -----------------------------------------------------------------------------
   -- Flash Memory                                                            --
   -----------------------------------------------------------------------------
   flas : flash port map(
      si           => flasi,
      so           => flaso,
   -- Non Wishbone Signals
      SF_OE        => SF_OE,
      SF_CE        => SF_CE,
      SF_WE        => SF_WE,
      SF_BYTE      => SF_BYTE,
      --SF_STS       => SF_STS,
      SF_A         => SF_A,
      SF_D         => SF_D,
      PF_OE        => PF_OE,
      LCD_RW       => LCD_RW,
      LCD_E        => LCD_E,
      SPI_ROM_CS   => SPI_ROM_CS,
      SPI_ADC_CONV => SPI_ADC_CONV,
      SPI_DAC_CS   => SPI_DAC_CS
   );
   
   -----------------------------------------------------------------------------
   -- DDR2 Memory                                                             --
   -----------------------------------------------------------------------------   
   -- ddr2 : ddr port map(
      -- si       => ddri,
      -- so       => ddro,
   --Non Wishbone Signals
      -- clk0     => CLK25_I,
      -- clk90    => CLK25P90_I,
      -- SD_CK_N  => SD_CK_N,
      -- SD_CK_P  => SD_CK_P,
      -- SD_CKE   => SD_CKE,
      -- SD_BA    => SD_BA,
      -- SD_A     => SD_A,      
      -- SD_CMD   => SD_CMD,
      -- SD_DM    => SD_DM,
      -- SD_DQS   => SD_DQS,
      -- SD_DQ    => SD_DQ
   -- );   
   
   -----------------------------------------------------------------------------
   -- VGA 100x37 Text Display                                                 --
   -----------------------------------------------------------------------------   
   disp : vga port map(
      si        => dispi,
      so        => dispo,
   -- Non Wishbone Signals
      VGA_HSYNC => VGA_HSYNC,
      VGA_VSYNC => VGA_VSYNC,
      VGA_RED   => VGA_RED,
      VGA_GREEN => VGA_GREEN,
      VGA_BLUE  => VGA_BLUE
   );

   -----------------------------------------------------------------------------
   -- Keyboard                                                                --
   -----------------------------------------------------------------------------   
   key : keyb port map(
      si        => keybi,
      so        => keybo,
   -- Non-Wishbone Signals
      PS2_CLK   => PS2_CLK,
      PS2_DATA  => PS2_DATA,
      intr      => open
   );

   -----------------------------------------------------------------------------
   -- Programmable Intervall Timer                                            --
   -----------------------------------------------------------------------------   
   pit0 : pit port map(
      si   => piti,
      so   => pito,
   -- Non-Wishbone Signals
      intr => pit_intr
   );
   
   -----------------------------------------------------------------------------
   -- RS-232 Receiver                                                         --
   -----------------------------------------------------------------------------
   recv : uartr port map(
      si            => uartri,
      so            => uartro,
   -- Non-Wishbone Signals
      RS232_DCE_RXD => RS232_DCE_RXD
   );
   
   -----------------------------------------------------------------------------
   -- RS-232 Transmitter                                                      --
   -----------------------------------------------------------------------------
   send : uartt port map(
      si            => uartti,
      so            => uartto,
   -- Non-Wishbone Signals
      RS232_DCE_TXD => RS232_DCE_TXD
   );
   
   -----------------------------------------------------------------------------
   -- Shared Bus                                                              --
   -----------------------------------------------------------------------------
   sbus : intercon port map(
      CLK50_I  => CLK50_I,
      CLK25_I  => CLK25_I,
      RST_I    => RST_I,
      mi       => mi,
      mo       => mo,
      brami    => brami,
      bramo    => bramo,
      flasi    => flasi,
      flaso    => flaso,
      ddri     => ddri,
      ddro     => ddro,
      dispi    => dispi,
      dispo    => dispo,
      keybi    => keybi,
      keybo    => keybo,
      piti     => piti,
      pito     => pito,
      uartri   => uartri,
      uartro   => uartro,
      uartti   => uartti,
      uartto   => uartto
   );

   sti : process
   begin   
      RST_I <= '1';
      wait for 3*clk50_period/2;
      RST_I <= '0'; 
      wait;                            -- Important: no wait, no simulation.
   end process;   
end tb; 