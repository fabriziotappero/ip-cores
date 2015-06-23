--------------------------------------------------------------------------------
-- layer[2] System-on-a-Chip                                                  --
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
use work.iddr.all;
use work.ivga.all;
use work.ikeyb.all;
use work.ipit.all;
use work.iuart.all;

entity layer2 is
   port(
      CLK_I         : in  std_logic;
   -- Flash
      SF_OE         : out   std_logic;
      SF_CE         : out   std_logic;
      SF_WE         : out   std_logic;
      SF_BYTE       : out   std_logic;
      --SF_STS       : in    std_logic;
      SF_A          : out   std_logic_vector(23 downto 0);
      SF_D          : inout std_logic_vector(7 downto 0);
      PF_OE         : out   std_logic;
      LCD_RW        : out   std_logic;
      LCD_E         : out   std_logic;
      SPI_ROM_CS    : out   std_logic;
      SPI_ADC_CONV  : out   std_logic;
      SPI_DAC_CS    : out   std_logic;
   -- DDR2
      SD_CK_N       : out   std_logic;
      SD_CK_P       : out   std_logic;
      SD_CKE        : out   std_logic;      
      SD_BA         : out   std_logic_vector(1 downto 0);
      SD_A          : out   std_logic_vector(12 downto 0);     
      SD_CMD        : out   std_logic_vector(3 downto 0);
      SD_DM         : out   std_logic_vector(1 downto 0);
      SD_DQS        : inout std_logic_vector(1 downto 0);
      SD_DQ         : inout std_logic_vector(15 downto 0);
   -- VGA
      VGA_HSYNC     : out std_logic;
      VGA_VSYNC     : out std_logic;
      VGA_RED       : out std_logic;
      VGA_GREEN     : out std_logic;
      VGA_BLUE      : out std_logic;
   -- Keyboard   
      PS2_CLK       : in  std_logic;
      PS2_DATA      : in  std_logic;
   -- RS-232 Serial Port
      RS232_DCE_RXD : in  std_logic;
      RS232_DCE_TXD : out std_logic;
      LED           : out std_logic_vector(7 downto 0)
   );
end layer2;

architecture rtl of layer2 is

   -----------------------------------------------------------------------------
   -- Clocks                                                                  --
   -----------------------------------------------------------------------------   
   component clook
      port(
         U1_CLKIN_IN        : in  std_logic;
         U1_RST_IN          : in  std_logic;          
         U1_CLKDV_OUT       : out std_logic;
         U1_CLKIN_IBUFG_OUT : out std_logic;
         U1_CLK0_OUT        : out std_logic;
         U2_CLK0_OUT        : out std_logic;
         U2_CLK90_OUT       : out std_logic;
         U2_LOCKED_OUT      : out std_logic
      );
   end component;
   
   signal clk50MHz     : std_logic; -- 50 MHz clock of DCM 1.
   signal clk50MHz_BUF : std_logic; -- 50 MHz clock for DCM reset operations.
   signal clk25MHz0D   : std_logic; -- 25 MHz phase 0 for DDR.
   signal clk25MHz90D  : std_logic; -- 25 MHz pahse 90 for DDR.   
   
   
   -----------------------------------------------------------------------------
   -- Shared Bus                                                              --
   -----------------------------------------------------------------------------
   signal ci : cpu_in_t;                              -- CPU input signals.
   signal co : cpu_out_t;                             -- CPU output signals.
   signal mi : master_in_t;                           -- CPU WB Master input.
   signal mo : master_out_t;                          -- CPU WB Master output.
   
   signal irq      : std_logic_vector(7 downto 0);    -- Interrupt vector.
   signal pit_intr : std_logic;                       -- PIT interrupt.
   signal key_intr : std_logic;                       -- Keyboard interrupt.
   
   signal brami, flasi, ddri, dispi, keybi, piti, uartri, uartti : slave_in_t;
   signal bramo, flaso, ddro, dispo, keybo, pito, uartro, uartto : slave_out_t;

   
   -----------------------------------------------------------------------------
   -- Global Reset                                                            --
   -----------------------------------------------------------------------------   
   type rst_state_t is (Setup, Done);
   
   type rst_t is record
      s : rst_state_t;
      c : natural range 0 to 3;
   end record;
   
   signal r, rin : rst_t := rst_t'(Setup, 0);
   signal rst    : std_logic;                   -- Global reset signal. 
begin 
 
   -----------------------------------------------------------------------------
   -- Global Reset                                                            --
   -----------------------------------------------------------------------------
   -- Reset for 4 clock cycles at start-up. Something the DCM wishes for.
   nsl : process(r)
   begin
      
      rin <= r;      

      case r.s is       
         when Setup =>
            rst <= '1';
            if r.c = 3 then
               rin.c <= 0;
               rin.s <= Done;
            else
               rin.c <= r.c + 1;
            end if;
            
         when Done =>
            rst <= '0';         
      end case;
   end process;
   
   reg : process(clk50MHz_BUF)
   begin
      if rising_edge(clk50MHz_BUF) then r <= rin; end if;
   end process;   
   
   -----------------------------------------------------------------------------
   -- Clocks                                                                  --
   -----------------------------------------------------------------------------   
   mclk: clook port map(
      U1_CLKIN_IN        => CLK_I,
      U1_RST_IN          => rst,
      U1_CLKDV_OUT       => open,
      U1_CLKIN_IBUFG_OUT => clk50MHz_BUF,
      U1_CLK0_OUT        => clk50MHz,
      U2_CLK0_OUT        => clk25MHz0D,
      U2_CLK90_OUT       => clk25MHz90D,
      U2_LOCKED_OUT      => open
   );
   
   -----------------------------------------------------------------------------
   -- MIPS I Cpu                                                              --
   -----------------------------------------------------------------------------
   irq <= key_intr & "000000" & pit_intr;
   LED <= irq;
   
   mips : cpu port map(
      ci => ci,
      co => co
   );

   -----------------------------------------------------------------------------
   -- Cpu's Wishbone Master                                                   --
   -----------------------------------------------------------------------------
   master : wbm port map(
      mi  => mi,
      mo  => mo,
   -- Non Wishbone Signals
      ci  => ci,
      co  => co,
      irq => irq
   );
   
   -----------------------------------------------------------------------------
   -- Block Memory                                                            --
   -----------------------------------------------------------------------------
   -- NOTE: The starting point of execution.
   ram : mem port map(
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
   ddr2 : ddr port map(
      si       => ddri,
      so       => ddro,
   -- Non Wishbone Signals
      clk0     => clk25MHz0D,
      clk90    => clk25MHz90D,
      SD_CK_N  => SD_CK_N,
      SD_CK_P  => SD_CK_P,
      SD_CKE   => SD_CKE,
      SD_BA    => SD_BA,
      SD_A     => SD_A,      
      SD_CMD   => SD_CMD,
      SD_DM    => SD_DM,
      SD_DQS   => SD_DQS,
      SD_DQ    => SD_DQ
   );   
   
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
      intr      => key_intr
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
      CLK50_I => clk50MHz,
      CLK25_I => clk25MHz0D,
      RST_I   => rst,
      mi      => mi,
      mo      => mo,
      brami   => brami,
      bramo   => bramo,
      flasi   => flasi,
      flaso   => flaso,
      ddri    => ddri,
      ddro    => ddro,
      dispi   => dispi,
      dispo   => dispo,
      keybi   => keybi,
      keybo   => keybo,
      piti    => piti,
      pito    => pito,
      uartri  => uartri,
      uartro  => uartro,
      uartti  => uartti,
      uartto  => uartto
   );
end rtl; 