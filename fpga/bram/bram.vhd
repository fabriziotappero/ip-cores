-- Copyright (C) 2004 DSP&FPGA
-- Author: SaVa <s.valach@dspfpga.com>
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the OpenIPCore Hardware General Public
-- License as published by the OpenIPCore Organization; either version
-- 0.20-15092000 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- OpenIPCore Hardware General Public License for more details.
--
-- You should have received a copy of the OpenIPCore Hardware Public
-- License along with this program; if not, download it from
-- OpenCores.org (http://www.opencores.org/OIPC/OHGPL.shtml).

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- synthesis translate_off
library UNISIM;
use UNISIM.vcomponents.all;
-- synthesis translate_on

Entity eus_100lx is
Generic(
   E_DATA_WIDTH   : integer :=   32);
Port(
   SDRCLKF        : in     std_logic;                       -- Etrax clocks (50MHz)
   RESET          : in     std_logic;                    -- Global reset
-- ETRAX Bus
   DREQ0          : out    std_logic;                       -- DMA Request (Active high)
   DACK0          : in     std_logic;                       -- DMA ACK (Active high)
   IRQ            : out    std_logic;                       -- Active low
--- Bus signals
   D              : inout  std_logic_vector(E_DATA_WIDTH - 1 downto 0);
   A              : in     std_logic_vector(22 downto 2);
   CSR0           : in     std_logic;                       -- FPGA Programming
   CSR1           : in     std_logic;                       -- LCD Data channel
   CSP0           : in     std_logic;                       -- Internal Registers, control and status
   CSP4           : in     std_logic;                       -- Reserved
   RD             : in     std_logic;                       -- Etrax reads
   WR             : in     std_logic_vector(3 downto 0);    -- Etrax writes
-- USERIOs
   LEDX           : out    std_logic_vector(1 downto 0);    -- Leds
   X              : inout  std_logic_vector(87 downto 0);   -- Generic IOs
   ISAEN          : out    std_logic;                       -- 
-- LCD Outputs   / Generic In/Out 
   Y              : out    std_logic_vector(28 downto 0);
-- Dedicated SDRAM
   SD             : inout  std_logic_vector(15 downto 0);   -- Data Bus
   SA             : out    std_logic_vector(0 to 14);       -- Address and BA signals
   SRAS           : out    std_logic;                       -- SDRAM ras
   SCAS           : out    std_logic;                       -- SDRAM cas
   SCS            : out    std_logic;
   SCLK           : out    std_logic;
   SCKE           : out    std_logic;
   SDQMH          : out    std_logic;
   SDQML          : out    std_logic;
   SWE            : out    std_logic);
end eus_100lx;

architecture behav of eus_100lx is
 
-- Components Declarations 
 
-- Clocks distribution 
 
Component CLK_GEN 
Generic ( 
   ACTIVE_RST     : std_logic := '1'; 
   CLK_M_RATIO    : integer := 2;
   CLK_D_RATIO    : integer := 2;
   CLK_DIV_RATIO  : real := 10.0;         -- LCD divider
   POWER_UP_T     : integer := 20         -- Clk numbers - should be 200ms, for sim is shorter 
      );
Port (
-- Clocks & Resets
   CLK_IN      : in     std_logic;
   CLK_FB      : in     std_logic;
   RESET_IN    : in     std_logic;
   RESET_OUT   : out    std_logic;
   CLK         : out    std_logic;        -- System Clock
   SD_CLK_I    : out    std_logic;        -- Internal SDRAM Clock
   SD_CLK      : out    std_logic;        -- SDRAM Clock     
   LCD_CLK_I   : out    std_logic;        -- Internal Clock for LCD controller, usually CLK divided by 16 - see M/D ratio 
   POWER_UP    : out    std_logic         -- SDRAM Initial time after stable CLK
);
End Component;

attribute WRITE_MODE_A : string;
attribute WRITE_MODE_A of U_RAMB16_S18_S18: label is "READ_FIRST";
attribute WRITE_MODE_B : string;
attribute WRITE_MODE_B of U_RAMB16_S18_S18: label is "READ_FIRST"; 

component RAMB16_S18_S18 
-- pragma translate_off
  generic (
-- "Read during Write" attribute for functional simulation
   WRITE_MODE_A : string := "READ_FIRST" ; -- WRITE_FIRST(default)/ READ_FIRST/ NO_CHANGE
   WRITE_MODE_B : string := "READ_FIRST" ; -- WRITE_FIRST(default)/ READ_FIRST/ NO_CHANGE
     );
-- pragma translate_on
  port (
   DIA     : in std_logic_vector (15 downto 0);
   DIPA    : in std_logic_vector (1 downto 0);
   ADDRA   : in std_logic_vector (9 downto 0);        
   ENA     : in std_logic;
   WEA     : in std_logic;
   SSRA    : in std_logic;
   CLKA    : in std_logic;
   DOA     : out std_logic_vector (15 downto 0);
   DOPA    : out std_logic_vector (1 downto 0);   
--
   DIB     : in std_logic_vector (15 downto 0);
   DIPB    : in std_logic_vector (1 downto 0);
   ADDRB   : in std_logic_vector (9 downto 0);        
   ENB     : in std_logic;
   WEB     : in std_logic;
   SSRB    : in std_logic;
   CLKB    : in std_logic;
   DOB     : out std_logic_vector (15 downto 0);
   DOPB    : out std_logic_vector (1 downto 0)   
   ); 
end component;

--

constant zeros       : std_logic_vector(15 downto 0) := (Others => '0');
constant dist_ram_wd : integer := E_DATA_WIDTH;

-- LOW/HIGH definition
signal low           : std_logic := '0';
signal high          : std_logic := '1';

-- SDRCLKF_internal
signal sdrclkf_i     : std_logic;
signal lcd_clk_i     : std_logic;
signal rst           : std_logic;
signal dreq0_i       : std_logic;

-- Sampled signals by SDRCLKF
signal d_in          : std_logic_vector(E_DATA_WIDTH - 1 downto 0);
signal a_i           : std_logic_vector(22 downto 2);
signal csr0_i        : std_logic := '0';
signal csr1_i        : std_logic := '0';
signal csp0_i        : std_logic := '0';
signal csp4_i        : std_logic := '0';
signal rd_i          : std_logic := '0';
signal wr_i          : std_logic_vector(3 downto 0) := "1111";
signal dack0_i       : std_logic := '0';

signal wr_i_p        : std_logic_vector(3 downto 0) := "0000";

-- Access control - active high
signal sel_wr_0      : std_logic;
signal sel_wr_1      : std_logic;
signal sel_wr_2      : std_logic;

signal csp0_rd       : std_logic;
signal sel_rd_0      : std_logic;
signal sel_rd_1      : std_logic;
signal sel_rd_2      : std_logic;

-- Control Section
signal reg_0         : std_logic_vector(31 downto 0) := x"11111111";                -- Defaul values
signal reg_1         : std_logic_vector(31 downto 0) := x"22222222";
signal reg_2         : std_logic_vector(31 downto 0) := x"33333333";

signal sys_cnt       : std_logic_vector(31 downto 0) := (Others => '0');

signal d_out         : std_logic_vector(31 downto 0);
signal dist_d_out    : std_logic_vector(31 downto 0);

signal led_blink_cnt : std_logic_vector(22 downto 0);

signal dist_ram_we   : std_logic;

signal sd_clk_i      : std_logic;

BEGIN

-- XX_OFUB workaround ISE7.1
DREQ0    <= 'Z';
IRQ      <= 'Z';
X        <= (Others => 'Z');
Y        <= (Others => 'Z');
SD       <= (Others => 'Z');
SA       <= (Others => 'Z');
SRAS     <= 'Z';
SCAS     <= 'Z';
SCS      <= 'Z';
SCLK     <= 'Z';
SCKE     <= 'Z';
SDQMH    <= 'Z';
SDQML    <= 'Z';
SWE      <= 'Z';

-- Windows size for write are 64kB
sel_wr_0 <= '1' When (csp0_i = '0') And (a_i(22 downto 16) = "0000000") Else '0';      -- Base Address = CSP0 + 0x00000   
sel_wr_1 <= '1' When (csp0_i = '0') And (a_i(22 downto 16) = "0000001") Else '0';      -- Base Address = CSP0 + 0x10000
sel_wr_2 <= '1' When (csp0_i = '0') And (a_i(22 downto 16) = "0000010") Else '0';      -- Base Address = CSP0 + 0x20000

-- Selectors without resample - used for dir control read/write
csp0_rd <= '1' When (CSP0 = '0') And (RD = '0') Else '0';                              -- Read selector for CSP0
--Windows size for read are 64kB
sel_rd_0 <= '1' When (csp0_rd = '1') And (A(22 downto 16) = "0000000") Else '0';       -- Base Address = CSP0 + 0x00000
sel_rd_1 <= '1' When (csp0_rd = '1') And (A(22 downto 16) = "0000001") Else '0';       -- Base Address = CSP0 + 0x10000
sel_rd_2 <= '1' When (csp0_rd = '1') And (A(22 downto 16) = "0000010") Else '0';       -- Base Address = CSP0 + 0x20000

-- Components mapping    
CLK_GENERATION : CLK_GEN
Port map(
   CLK_IN      => SDRCLKF,             -- Etrax's Clock (50MHz)
   CLK_FB      => low,                 -- SDRAM Feadback
   RESET_IN    => low,                 -- Global reset
   RESET_OUT   => rst,
   CLK         => sdrclkf_i,           -- Internal system Clock
   SD_CLK_I    => sd_clk_i,            -- Internal SDRAM Clock
   SD_CLK      => open,                -- SDRAM Clock     
   LCD_CLK_I   => lcd_clk_i,           -- Internal Clock for LCD controller, usually CLK divided by 8 see divide ratio 
   POWER_UP    => open                 -- SDRAM Initial time after stable CLK
);

-- write enable
wr_i_p <= Not wr_i;
--
-- Block SelectRAM Instantiation
U_RAMB16_S18_S18: RAMB16_S18_S18
  port map (
   DIA     => d_in(15 downto 0),       -- insert 16 bits data in bus (<15 downto 0>)
   DIPA    => d_in(17 downto 16),      -- insert 2 bits parity data in bus (or <17 downto 16>)
   ADDRA   => a_i(11 downto 2),        -- insert 10 bits address bus        
   ENA     => sel_wr_2,                -- insert enable signal
   WEA     => wr_i_p(3),               -- insert write enable signal
   SSRA    => low,                     -- insert set/reset signal
   CLKA    => sdrclkf_i,               -- insert clock signal
   DOA     => open,                    -- insert 16 bits data out bus (<15 downto 0>)
   DOPA    => open,                    -- insert 2 bits parity data out bus (or <17 downto 16>)
--
   DIB     =>  zeros,                  -- insert 16 bits data in bus (<15 downto 0>)
   DIPB    =>  zeros(1 downto 0),      -- insert 2 bits parity data in bus (or <17 downto 16>)
   ADDRB   =>  A(11 downto 2),         -- insert 10 bits address bus
   ENB     =>  high,                   -- insert enable signal
   WEB     =>  low,                    -- insert write enable signal
   SSRB    =>  low,                    -- insert set/reset signal
   CLKB    =>  sd_clk_i,               -- insert clock signal
   DOB     =>  dist_d_out(15 downto 0),-- insert 16 bits data out bus (<15 downto 0>)
   DOPB    =>  dist_d_out(17 downto 16)-- insert 2 bits parity data out bus (or <17 downto 16>)
   );
--      

RESAMPLE_IN : PROCESS(sdrclkf_i, D, A, CSR0, CSR1, CSP0, CSP4, RD, WR, DACK0)
BEGIN
   If sdrclkf_i'event And sdrclkf_i = '1' Then
      d_in <= D;
      a_i <= A;
      csr0_i <= CSR0;
      csr1_i <= CSR1;
      csp0_i <= CSP0;
      csp4_i <= CSP4;
      rd_i <= RD;
      wr_i <= WR;
      dack0_i <= DACK0;
   End If;
END PROCESS;

USER_REGS : PROCESS(sdrclkf_i)
BEGIN
   If sdrclkf_i'event And sdrclkf_i = '1' Then
      If (sel_wr_0 = '1') And (wr_i(3) = '0') Then      
         Case a_i(15 downto 2) is
            When "00000000000000" =>
               reg_0 <= d_in;         
            When "00000000000001" =>
               reg_1 <= d_in;
            When "00000000000010" =>
               reg_2 <= d_in;
            When Others => NULL;
         End Case;
      End If;
   End If;
END PROCESS;

d_out <= reg_0 When A(15 downto 2) = "00000000000000" Else
         reg_1 When A(15 downto 2) = "00000000000001" Else
         reg_2;

D <= d_out When sel_rd_0 = '1' Else
     sys_cnt When sel_rd_1 = '1' Else
     dist_d_out When sel_rd_2 = '1' Else
     (Others => 'Z');     


ISAEN <= '1'; -- Enable "ISA ios"

LED_BLINK: PROCESS(sdrclkf_i, led_blink_cnt)
BEGIN
   If sdrclkf_i'event And sdrclkf_i = '1' Then
      led_blink_cnt <= led_blink_cnt + 1;
   End If;
END PROCESS;

SYS_TIMER : PROCESS(sdrclkf_i)
BEGIN
   If sdrclkf_i'event And sdrclkf_i = '1' Then
      sys_cnt <= sys_cnt + 1;
   End If;
END PROCESS;

LEDX <= Not (led_blink_cnt(led_blink_cnt'high) & reg_0(0));

end behav;
