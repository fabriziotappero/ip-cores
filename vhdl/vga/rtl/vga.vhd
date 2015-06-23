--------------------------------------------------------------------------------
-- 8-Color 100x37 Textmode Video Controller                                   --
--------------------------------------------------------------------------------
--                                                                            --
-- IMPORTANT NOTICE                                                           --
--                                                                            --
--    I've spent alot of time to get the controller to work correctly. For    --
--    all those who try to implement their own: be strict with the sync       --
--    timing and don't paint outside the display area. To avoid a blurry      --
--    image, paint all 100px per line. I've painted only 99px and some        --
--    characters startet blinking on the edges. This happend because I didn't --
--    latch the sync and visible signals to synchronize them with the         --
--    character output (2 additional cycles). Another reason, why a character --
--    binks is due to the fact that the color needs to latched one cycle as   --
--    well.                                                                   --
--    If you want to save registers however, you can set the display boundary --
--    comparators to '<= H_DISP' and '<= V_DISP'. The display then has        --
--    801x601px but you can delete the 'hsync', 'vsync' and 'vis' shift regs. --
--    Hard to explain. If you get problems just contact me :)                 --
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

entity vga is
   port(
      si        : in  slave_in_t;
      so        : out slave_out_t;
   -- Non Wishbone Signals
      VGA_HSYNC : out std_logic;
      VGA_VSYNC : out std_logic;
      VGA_RED   : out std_logic;
      VGA_GREEN : out std_logic;
      VGA_BLUE  : out std_logic
   );
end vga;

architecture rtl of vga is

   -----------------------------------------------------------------------------
   -- Display settingss for 800x600@72Hz.                                     --
   -----------------------------------------------------------------------------
   constant H_MAX       : natural := 1040;   -- Complete horizontal width.
   constant H_DISP      : natural := 800;    -- Visible Display size.
   constant H_LOW_START : natural := 856;    -- H_DISP + front porch.
   constant H_LOW_END   : natural := 976;    -- H_LOW_START + sync low.

   constant V_MAX       : natural := 666;
   constant V_DISP      : natural := 600;
   constant V_LOW_START : natural := 637;
   constant V_LOW_END   : natural := 643;


   component rom is
      port(
         clk      : in  std_logic;
         rom_addr : in  std_logic_vector(11 downto 0);
         rom_word : out std_logic_vector(7 downto 0)
      );
   end component;

   attribute RAM_STYLE : string;
   attribute RAM_STYLE of rom : component is "BLOCK";

   component ram is
      port(
         clk  : in  std_logic;
         adrs : in  std_logic_vector(11 downto 0);
         adru : in  std_logic_vector(11 downto 0);
         we   : in  std_logic;
         stb  : in  std_logic;
         din  : in  std_logic_vector(15 downto 0);
         chr  : out std_logic_vector(7 downto 0);
         fgc  : out std_logic_vector(2 downto 0);
         bgc  : out std_logic_vector(2 downto 0);
         datu : out std_logic_vector(15 downto 0);
         ack  : out std_logic
      );
   end component;

   type video_t is record
      h     : unsigned(10 downto 0);
      v     : unsigned(9 downto 0);
      hsync : std_logic_vector(1 downto 0);
      vsync : std_logic_vector(1 downto 0);
      vis   : std_logic_vector(1 downto 0);
      fgc   : std_logic_vector(2 downto 0);
      bgc   : std_logic_vector(2 downto 0);
   end record;

   signal vidin, vid : video_t;

   signal adrs : unsigned(11 downto 0);             -- VGA display address.
   signal dat  : std_logic_vector(15 downto 0);     -- User write data.
   signal datu : std_logic_vector(15 downto 0);     -- User read data.
   signal chr  : std_logic_vector(7 downto 0);      -- Character ISO code.
   signal cbit : std_logic;                         -- One bit of 'chr'.

   signal rom_addr : std_logic_vector(11 downto 0); -- Character lines address.
   signal rom_word : std_logic_vector(7 downto 0);    -- One line of a character.

   signal red   : std_logic;
   signal green : std_logic;
   signal blue  : std_logic;

   -- Split up into ram and rom addresses for convinience.
   alias ah : unsigned(7 downto 0) is vid.h(10 downto 3);
   alias av : unsigned(5 downto 0) is vid.v(9 downto 4);
   alias ch : unsigned(2 downto 0) is vid.h(2 downto 0);
   alias cv : unsigned(3 downto 0) is vid.v(3 downto 0);
begin

   -----------------------------------------------------------------------------
   -- SYNCHRONIZATION                                                         --
   -----------------------------------------------------------------------------
   reg : process(si.clk)
   begin
      if rising_edge(si.clk) then
         vid <= vidin;
         if si.rst = '1' then
            vid.h <= "00000000000";
            vid.v <= "0000000000";
         end if;
      end if;
   end process;

   nsl : process(vid.h, vid.v, vid.hsync, vid.vsync, vid.vis)
   begin

      -- Horizontal counter.
      if vid.h = H_MAX-1 then
         vidin.h <= "00000000000";
      else
         vidin.h <= vid.h + 1;
      end if;

      -- Vertical counter.
      if (vid.v = V_MAX-1) and (vid.h >= H_LOW_START) then
         vidin.v <= "0000000000";
      elsif vid.h = H_MAX-1 then
         vidin.v <= vid.v + 1;
      else
         vidin.v <= vid.v;
      end if;

      -- The following 3 signals are implemented as shift registers. A character
      -- read takes 2 cycles. To set the sync and visible signals in time, we
      -- shift them once.

      -- Horizontal sync pulse.
      vidin.hsync(1) <= vid.hsync(0);
      if (vid.h >= H_LOW_START) and (vid.h < H_LOW_END) then
         vidin.hsync(0) <= '0';
      else
         vidin.hsync(0) <= '1';
      end if;

      -- Vertical sync pulse.
      vidin.vsync(1) <= vid.vsync(0);
      if (vid.v >= V_LOW_START) and (vid.v < V_LOW_END)  then
         vidin.vsync(0) <= '0';
      else
         vidin.vsync(0) <= '1';
      end if;

      -- Visible area is limited vertically and horizontally limited by V_DISP
      -- and H_DISP respectively. Drawing outside results in strange display
      -- behaviour.
      vidin.vis(1) <= vid.vis(0);
      if (vid.h < H_DISP) and (vid.v < V_DISP) then
         vidin.vis(0) <= '1';
      else
         vidin.vis(0) <= '0';
      end if;
   end process;

   -- Horizontal and vertical synchronization signals.
   VGA_HSYNC <= vid.hsync(1);
   VGA_VSYNC <= vid.vsync(1);

   -----------------------------------------------------------------------------
   -- DATAPATH                                                                --
   -----------------------------------------------------------------------------
   -- Calculate array loaction of a character the short way: y*100 + x.
   adrs <= (av&"000000") + (av&"00000") + (av&"00") + (ah);

   -- NOTE: Select either upper or lower halfword according to si.sel signal.
   -- Other signals then "1100" will store lower 16 bits!
   dat <= si.dat(31 downto 16) when si.sel = "1100" else si.dat(15 downto 0);

   video_ram : ram port map(
      clk  => si.clk,
      adrs => std_logic_vector(adrs),
      adru => si.adr(12 downto 1),
      we   => si.we,
      stb  => si.stb,
      din  => dat,
      chr  => chr,
      fgc  => vidin.fgc,
      bgc  => vidin.bgc,
      datu => datu,
      ack  => so.ack
   );

   -- Read vga memory.
   so.dat <= datu & x"0000" when si.sel = "1100" else x"0000" & datu;

   -- The current pixel row of a char is determined by its ASCII (or ISO) number
   -- and the row offset y (a character is 16 rows high).
   rom_addr <= chr & std_logic_vector(cv);

   char_table : rom port map(
      clk      => si.clk,
      rom_addr => rom_addr,
      rom_word => rom_word
   );

   -- The Python script <chars.py> creates the <rom.vhd> automatically by
   -- translating a <*.bdf> file. The resulting characters in <rom.vhd> are
   -- in reverese order and rotated 2 positions forward.
   -- The reversal is necessary, since the letters would be printed vertically
   -- inverted. Because of the delay due to the two memory stages (video ram,
   -- character rom), the x position pointer is 2 cycles ahead. By permanently
   -- rotating the character data 2px to the left, we do not need to subtract
   -- the x index by 2.
   cbit <= rom_word( to_integer(ch) );

   -- Determine color bit either foreground if cbit is set, background else.
   red   <= vid.fgc(2) when cbit = '1' else vid.bgc(2);
   green <= vid.fgc(1) when cbit = '1' else vid.bgc(1);
   blue  <= vid.fgc(0) when cbit = '1' else vid.bgc(0);

   -- Check if we are whtin the display area, pull to '0' if not. Otherwise we
   -- get weird behavior.
   VGA_RED   <= red   when vid.vis(1) = '1' else '0';
   VGA_GREEN <= green when vid.vis(1) = '1' else '0';
   VGA_BLUE  <= blue  when vid.vis(1) = '1' else '0';
end rtl;