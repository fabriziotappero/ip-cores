--------------------------------------------------------------------------------
-- Numonyx™ 128 Mbit EMBEDDED FLASH MEMORY J3 Version D                       --
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

entity flash is
   port (
      si           : in    slave_in_t;
      so           : out   slave_out_t;
   -- Non Wishbone Signals
      SF_OE        : out   std_logic;
      SF_CE        : out   std_logic;
      SF_WE        : out   std_logic;
      SF_BYTE      : out   std_logic;
      --SF_STS       : in    std_logic;
      SF_A         : out   std_logic_vector(23 downto 0);
      SF_D         : inout std_logic_vector(7 downto 0);
      PF_OE        : out   std_logic;
      LCD_RW       : out   std_logic;
      LCD_E        : out   std_logic;
      SPI_ROM_CS   : out   std_logic;
      SPI_ADC_CONV : out   std_logic;
      SPI_DAC_CS   : out   std_logic
   );
end flash;

architecture rtl of flash is

   type state_t is (Init, Idle, SetupRead, DataRead, WaitRead, DataWrite, 
                    Finish);

   type reg_t is record
      s : state_t;                           -- State.
      n : natural range 0 to 49;             -- Period counter.
      a : natural range 0 to 3;              -- Address incrementer for read.
      d : std_logic_vector(31 downto 0);     -- Latched data for read.
      --w : std_logic_vector(7 downto 0);      -- Latched data for write.
   end record;

   signal r, rin : reg_t;
begin

   -- Disable shared components.
   PF_OE        <= '0';
   LCD_RW       <= '0';
   LCD_E        <= '0';
   SPI_ROM_CS   <= '1';
   SPI_ADC_CONV <= '0';
   SPI_DAC_CS   <= '1';

   -----------------------------------------------------------------------------
   -- Read/Write Control                                                      --
   -----------------------------------------------------------------------------
   SF_A <= si.adr(23 downto 2) & std_logic_vector( to_unsigned(r.a, 2) );

   nsl : process(si, r, SF_D)
   begin

      rin <= r;

      SF_OE   <= '1';
      SF_CE   <= '1';
      SF_WE   <= '1';
      SF_BYTE <= '0';
      SF_D    <= (others => 'Z');

      so.ack <= '0';

      case r.s is

         -- Wait 1µs for the device to be ready at startup.
         -- [Datasheet timing: R12, R13]
         when Init =>
            if r.n = 49 then -- 1µs
               rin.n <= 0;
               rin.s <= Idle;
            else
               rin.n <= r.n + 1;
            end if;

         -- Wait for incomming read or write commands.
         when Idle =>
            if wb_read(si) then
               rin.a <= 0;
               rin.s <= SetupRead;
            elsif wb_write(si) then
               rin.a <= to_integer( unsigned(si.adr(1 downto 0)) );
               -- case si.sel is
                  -- when "0001" => rin.w <= si.dat(7 downto 0);
                  -- when "0010" => rin.w <= si.dat(15 downto 8);
                  -- when "0100" => rin.w <= si.dat(23 downto 16);
                  -- when "1000" => rin.w <= si.dat(31 downto 24);
                  -- when others => rin.w <= si.dat(7 downto 0);
               -- end case;
               rin.s <= DataWrite;
            end if;

         -- Set CE and OE low while waiting 80ns (75ns) for the first data byte
         -- ready to latch. [Datasheet timing: R2, R3]
         when SetupRead =>
            SF_CE <= '0';
            SF_OE <= '0';
            if r.n = 3 then -- 80ns
               rin.n <= 0;
               rin.s <= DataRead;
            else
               rin.n <= r.n + 1;
            end if;

         -- Latch data word four times and increment SF_A[1:0]. After every
         -- read, jump to WaitRead and wait for the next data byte. On the
         -- last read go to FinishRead.
         when DataRead =>
            SF_CE <= '0';
            SF_OE <= '0';
            rin.d <= r.d(23 downto 0) & SF_D;
            if r.a = 3 then
               rin.a <= 0;
               rin.s <= Finish;
            else
               rin.a <= r.a + 1;
               rin.s <= WaitRead;
            end if;

         -- Wait for 40ns (25ns) until the next data byte is ready.
         -- [Datasheet timing: R15]
         when WaitRead =>
            SF_CE <= '0';
            SF_OE <= '0';
            if r.n = 1 then -- 40ns
               rin.n <= 0;
               rin.s <= DataRead;
            else
               rin.n <= r.n + 1;
            end if;

         -- Pull down CE and WE. Wait for 60ns (60ns).
         when DataWrite =>
            SF_CE <= '0';
            SF_WE <= '0';
            --SF_D  <= r.w;
            case si.sel is
               when "0001" => SF_D <= si.dat(7 downto 0);
               when "0010" => SF_D <= si.dat(15 downto 8);
               when "0100" => SF_D <= si.dat(23 downto 16);
               when "1000" => SF_D <= si.dat(31 downto 24);
               when others => SF_D <= si.dat(7 downto 0);
            end case;
            if r.n = 2 then -- 60ns
               rin.n <= 0;
               rin.s <= Finish;
            else
               rin.n <= r.n + 1;
            end if;

         -- Set CE and OE high and wait 20ns (25ns). After that the next command
         -- can be processed. The remaining 5ns are compensated by the Idle
         -- state which takes another 20ns. Wait for si.stb to be low again as
         -- well. [Datasheet timing: R8]
         -- Write recovery before read is 40ns (35ns). Wait at least 20ns and
         -- then go to Idle state which waits for another 20ns.
         -- [Datasheet timing: W12]
         when Finish =>
            so.ack <= '1';
            if si.stb = '0' then
               rin.s <= Idle;
            end if;

      end case;
   end process;

   so.dat <= r.d;

   -----------------------------------------------------------------------------
   -- Registers                                                               --
   -----------------------------------------------------------------------------
   reg : process(si.clk)
   begin
      if rising_edge(si.clk) then
         r <= rin;

         if si.rst = '1' then
            r.s <= Init;
         end if;
      end if;
   end process;
end rtl;

