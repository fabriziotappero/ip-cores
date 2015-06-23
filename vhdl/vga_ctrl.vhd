--------------------------------------------------------------------------------
----                                                                        ----
---- This file is part of the yaVGA project                                 ----
---- http://www.opencores.org/?do=project&who=yavga                         ----
----                                                                        ----
---- Description                                                            ----
---- Implementation of yaVGA IP core                                        ----
----                                                                        ----
---- To Do:                                                                 ----
----                                                                        ----
----                                                                        ----
---- Author(s):                                                             ----
---- Sandro Amato, sdroamt@netscape.net                                     ----
----                                                                        ----
--------------------------------------------------------------------------------
----                                                                        ----
---- Copyright (c) 2009, Sandro Amato                                       ----
---- All rights reserved.                                                   ----
----                                                                        ----
---- Redistribution  and  use in  source  and binary forms, with or without ----
---- modification,  are  permitted  provided that  the following conditions ----
---- are met:                                                               ----
----                                                                        ----
----     * Redistributions  of  source  code  must  retain the above        ----
----       copyright   notice,  this  list  of  conditions  and  the        ----
----       following disclaimer.                                            ----
----     * Redistributions  in  binary form must reproduce the above        ----
----       copyright   notice,  this  list  of  conditions  and  the        ----
----       following  disclaimer in  the documentation and/or  other        ----
----       materials provided with the distribution.                        ----
----     * Neither  the  name  of  SANDRO AMATO nor the names of its        ----
----       contributors may be used to  endorse or  promote products        ----
----       derived from this software without specific prior written        ----
----       permission.                                                      ----
----                                                                        ----
---- THIS SOFTWARE IS PROVIDED  BY THE COPYRIGHT  HOLDERS AND  CONTRIBUTORS ----
---- "AS IS"  AND  ANY EXPRESS OR  IMPLIED  WARRANTIES, INCLUDING,  BUT NOT ----
---- LIMITED  TO, THE  IMPLIED  WARRANTIES  OF MERCHANTABILITY  AND FITNESS ----
---- FOR  A PARTICULAR  PURPOSE  ARE  DISCLAIMED. IN  NO  EVENT  SHALL  THE ----
---- COPYRIGHT  OWNER  OR CONTRIBUTORS  BE LIABLE FOR ANY DIRECT, INDIRECT, ----
---- INCIDENTAL,  SPECIAL,  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, ----
---- BUT  NOT LIMITED  TO,  PROCUREMENT OF  SUBSTITUTE  GOODS  OR SERVICES; ----
---- LOSS  OF  USE,  DATA,  OR PROFITS;  OR  BUSINESS INTERRUPTION) HOWEVER ----
---- CAUSED  AND  ON  ANY THEORY  OF LIABILITY, WHETHER IN CONTRACT, STRICT ----
---- LIABILITY,  OR  TORT  (INCLUDING  NEGLIGENCE  OR OTHERWISE) ARISING IN ----
---- ANY  WAY OUT  OF THE  USE  OF  THIS  SOFTWARE,  EVEN IF ADVISED OF THE ----
---- POSSIBILITY OF SUCH DAMAGE.                                            ----
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

use work.yavga_pkg.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_ctrl is
--      generic (
--              g_H_SIZE : integer := 800;      -- horizontal size of input image, MAX 800
--              g_V_SIZE : integer := 600       -- vertical size of input image, MAX 600
--      );

  port (
    i_clk   : in std_logic;             -- must be 50MHz
    i_reset : in std_logic;

    -- vga horizontal and vertical sync
    o_h_sync : out std_logic;
    o_v_sync : out std_logic;

    -- horizontal and vertical sync enable (allow power saving on ?VESA? Monitors)
    i_h_sync_en : in std_logic;
    i_v_sync_en : in std_logic;

    -- vga R G B signals (1 bit for each component (8 colors))
    o_r : out std_logic;
    o_g : out std_logic;
    o_b : out std_logic;

    -- chars RAM memory
    i_chr_addr : in  std_logic_vector(c_CHR_ADDR_BUS_W - 1 downto 0);
    i_chr_data : in  std_logic_vector(c_CHR_DATA_BUS_W - 1 downto 0);
    o_chr_data : out std_logic_vector(c_CHR_DATA_BUS_W - 1 downto 0);
    i_chr_clk  : in  std_logic;
    i_chr_en   : in  std_logic;
    i_chr_we   : in  std_logic_vector(c_CHR_WE_BUS_W - 1 downto 0);
    i_chr_rst  : in  std_logic;

    -- waveform RAM memory
    i_wav_d    : in std_logic_vector(c_WAVFRM_DATA_BUS_W - 1 downto 0);
    i_wav_we   : in std_logic;
    i_wav_clk  : in std_logic;
    i_wav_addr : in std_logic_vector(c_WAVFRM_ADDR_BUS_W - 1 downto 0)  --;
    --o_DOA : OUT std_logic_vector(15 downto 0)
    );
end vga_ctrl;

-- vga timings used
--                     0                                    TOT
-- ...-----------------|=============== PERIOD ==============|--...
--                     |                                     |
-- ...__           ___________________________           _______...
--      \_________/                           \_________/
--                                                                 
--      |         |    |               |      |         |    |
--      |         |    |               |      |         |    |
-- ...--|----S----|-F--|=======D=======|==B===|====S====|=F==|--...
--           Y      R          I          A        Y      R
--           N      O          S          C        N      O
--           C      N          P          K        C      N
--           T      T          L          P        T      T
--           I      P          T          O        I      P
--           M      O          I          R        M      O
--           E      R          M          C        E      R
--                  C          E          H               C
--                  H                                     H
--      |         |    |               |      |         |    |
--   ...|---------|----|===============|======|=========|====|--...
-- HPx:     120     56         800        63      120     56    px (h PERIOD = 1039 px)
-- VLn:     6       37         600        23      6       37    ln (v PERIOD = 666 ln)
--
-- and with 50Mhz dot clock (20ns dot time):
--      |         |    |               |      |         |    |
--   ...|---------|----|===============|======|=========|====|--...
--Htime:   2.4     1.12        16        1.26     2.4    1.12   usec  (h PERIOD = 20.78 usec) Hfreq 48123.195 Hz
--Vtime:  124.68  768.86     12468      477.94  124.68  768.68  usec  (v PERIOD = 13839.48 usec) Vfreq 72.257 Hz

architecture rtl of vga_ctrl is

  --
  signal s_h_count      : std_logic_vector(c_H_COUNT_W - 1 downto 0);  -- horizontal pixel counter
  signal s_v_count      : std_logic_vector(c_V_COUNT_W - 1 downto 0);  -- verticalal line counter
  signal s_v_count_d_4  : std_logic_vector(3 downto 0);  -- verticalal line counter mod 16 (char height)
  signal s_h_sync       : std_logic;    -- horizontal sync trigger
  signal s_h_sync_pulse : std_logic;    -- 1-clock pulse on sync trigger

  --
  -- signals for the charmaps Block RAM component...
  signal s_charmaps_en   : std_logic;
  signal s_charmaps_ADDR : std_logic_vector (c_INTCHMAP_ADDR_BUS_W - 1 downto 0);
  signal s_charmaps_DO   : std_logic_vector (c_INTCHMAP_DATA_BUS_W - 1 downto 0);

  --
  -- to manage the outside display region's blanking
  signal s_display : std_logic;
  --

  --
  -- to manage the chars  ram address and the ram ascii
  signal s_chars_ram_addr : std_logic_vector(c_INTCHR_ADDR_BUS_W - 1 downto 0);
  signal s_chars_ascii    : std_logic_vector(c_INTCHR_DATA_BUS_W - 1 downto 0);
  signal s_chars_EN_r     : std_logic;

  -- to manage the waveform ram address and data
  signal s_waveform_ADDRB : std_logic_vector (c_WAVFRM_ADDR_BUS_W - 1 downto 0);
  signal s_waveform_DOB   : std_logic_vector (c_WAVFRM_DATA_BUS_W - 1 downto 0);


  -- charmaps
  -- |------| |-----------------|
  -- |   P  | | D D D D D D D D |
  -- |======| |=================|
  -- |   8  | | 7 6 5 4 3 2 1 0 |
  -- |======| |=================|
  -- | Free | | Row char pixels |
  -- |------| |-----------------|
  --
  component charmaps_rom
    port(
      i_EN    : in  std_logic;
      i_clock : in  std_logic;
      i_ADDR  : in  std_logic_vector(c_INTCHMAP_ADDR_BUS_W - 1 downto 0);  -- 16 x ascii code (W=8 x H=16 pixel)
      o_DO    : out std_logic_vector(c_INTCHMAP_DATA_BUS_W - 1 downto 0)  -- 8 bit char pixel
      );
  end component;



  -- wave form or video-line memory
  -- |------| |-------------------------------------------|
  -- | P  P | |  D  D  D |  D  D  D | D D D D D D D D D D |
  -- |======| |===========================================|
  -- |17 16 | | 15 14 13 | 12 11 10 | 9 8 7 6 5 4 3 2 1 0 |
  -- |======| |===========================================|
  -- | Free | |  Reserv. |  R  G  B |      vert. pos.     |
  -- |------| |-------------------------------------------|
  --
  component waveform_ram
    port(
      i_DIA    : in  std_logic_vector(c_WAVFRM_DATA_BUS_W - 1 downto 0);
      i_WEA    : in  std_logic;
      i_clockA : in  std_logic;
      i_ADDRA  : in  std_logic_vector(c_WAVFRM_ADDR_BUS_W - 1 downto 0);
      --o_DOA : OUT std_logic_vector(15 downto 0);
      --
      i_DIB    : in  std_logic_vector(c_WAVFRM_DATA_BUS_W - 1 downto 0);
      i_WEB    : in  std_logic;
      i_clockB : in  std_logic;
      i_ADDRB  : in  std_logic_vector(c_WAVFRM_ADDR_BUS_W - 1 downto 0);
      o_DOB    : out std_logic_vector(c_WAVFRM_DATA_BUS_W - 1 downto 0)
      );
  end component;

  component chars_RAM
    port(
      i_clock_rw : in  std_logic;
      i_EN_rw    : in  std_logic;
      i_WE_rw    : in  std_logic_vector(c_CHR_WE_BUS_W - 1 downto 0);
      i_ADDR_rw  : in  std_logic_vector(c_CHR_ADDR_BUS_W - 1 downto 0);
      i_DI_rw    : in  std_logic_vector(c_CHR_DATA_BUS_W - 1 downto 0);
      o_DI_rw    : out std_logic_vector(c_CHR_DATA_BUS_W - 1 downto 0);
      i_SSR      : in  std_logic;
      i_clock_r  : in  std_logic;
      i_EN_r     : in  std_logic;
      i_ADDR_r   : in  std_logic_vector(c_INTCHR_ADDR_BUS_W - 1 downto 0);
      o_DO_r     : out std_logic_vector(c_INTCHR_DATA_BUS_W - 1 downto 0)
      );
  end component;


  attribute U_SET                      : string;
  attribute U_SET of "u0_chars_RAM"    : label is "u0_chars_RAM_uset";
  attribute U_SET of "u1_charmaps_rom" : label is "u1_charmaps_rom_uset";
  attribute U_SET of "u2_waveform_ram" : label is "u2_waveform_ram_uset";

  -- to read some configuration params from the char ram
  signal s_config_time  : std_logic;
  --
  -- to manage the background and cursor colors
  signal s_cursor_color : std_logic_vector(2 downto 0) := "000";
  signal s_bg_color     : std_logic_vector(2 downto 0) := "000";
  --
  -- to manage the cursor position  
  signal s_cursor_x     : std_logic_vector(c_H_COUNT_W - 1 downto 0);
  signal s_cursor_y     : std_logic_vector(c_V_COUNT_W - 1 downto 0);

  function f_is_cursor_pixel(
    s_h, s_v, s_cur_x, s_cur_y : std_logic_vector)
    return boolean is
  begin
    return ((s_h = s_cur_x) or (s_v = s_cur_y));
  end f_is_cursor_pixel;

  function f_is_grid_pixel(
    s_h, s_v : std_logic_vector)
    return boolean is
  begin
    return (
      (s_h(c_GRID_BIT downto 0) = c_GRID_SIZE(c_GRID_BIT downto 0)) or
      (s_v(c_GRID_BIT downto 0) = c_GRID_SIZE(c_GRID_BIT downto 0))
      );
  end f_is_grid_pixel;

  function f_is_waveform_pixel(
    s_v, s_wav, s_wav_prev : std_logic_vector)
    return boolean is
  begin
    return (
      ((s_v >= s_wav) and (s_v <= s_wav_prev)) or
      ((s_v                    <= s_wav) and (s_v >= s_wav_prev))
      );
  end f_is_waveform_pixel;

begin
  -- read config params from ram...
  p_config : process(i_clk)
  begin
    if rising_edge(i_clk) then
      case s_chars_ram_addr is
        when c_CFG_BG_CUR_COLOR_ADDR =>  -- bg and curs color are on the same byte byte
          s_config_time  <= '1';
          s_cursor_color <= s_chars_ascii(2 downto 0);
          s_bg_color     <= s_chars_ascii(5 downto 3);
        when c_CFG_CURS_XY1 =>          -- xy coords spans on three bytes 
          s_config_time           <= '1';
          s_cursor_x(10 downto 6) <= s_chars_ascii(4 downto 0);
        when c_CFG_CURS_XY2 =>          -- xy coords spans on three bytes
          s_config_time          <= '1';
          s_cursor_x(5 downto 0) <= s_chars_ascii(7 downto 2);
          s_cursor_y(9 downto 8) <= s_chars_ascii(1 downto 0);
        when c_CFG_CURS_XY3 =>          -- xy coords spans on three bytes
          s_config_time          <= '1';
          s_cursor_y(7 downto 0) <= s_chars_ascii(7 downto 0);
        when others =>
          s_config_time <= '0';
      end case;
    end if;
  end process;

  -- enable the ram both
  --   - during the display time
  --   - to read configuration params
  s_chars_EN_r <= s_display or s_config_time;

  -- modify the chars_ram address
  s_chars_ram_addr <= s_v_count(9 downto 4) & s_h_count(9 downto 3);
  u0_chars_RAM : chars_RAM port map(
    i_clock_rw => i_chr_clk,
    i_EN_rw    => i_chr_en,
    i_WE_rw    => i_chr_we,
    i_ADDR_rw  => i_chr_addr,
    i_DI_rw    => i_chr_data,
    o_DI_rw    => o_chr_data,
    i_SSR      => i_chr_rst,
    i_clock_r  => not i_clk,
    i_EN_r     => s_chars_EN_r,
    i_ADDR_r   => s_chars_ram_addr,
    o_DO_r     => s_chars_ascii
    );


  -- modify the charmaps address (each 16 s_v_count - chars are 16 pixel tall)
  --                  v----- ascii code ------v    v-- vert px mod 16 --v (chars are 16 pixel tall)
  --s_charmaps_ADDR <= (s_chars_ascii(6 downto 0) & s_v_count(3 downto 0));
  s_charmaps_ADDR <= (s_chars_ascii(6 downto 0) & s_v_count_d_4);
  s_charmaps_en   <=
    '1' when s_h_count(2 downto 0) = "111"  -- each 8 h_count (chars are 8 pixel wide)
    else '0';

  u1_charmaps_rom : charmaps_rom port map(
    i_en    => s_charmaps_en,
    i_clock => not i_clk,
    i_ADDR  => s_charmaps_ADDR,
    o_DO    => s_charmaps_DO
    );


  -- modify the waveform address
  s_waveform_ADDRB <= s_h_count(9 downto 0);
  
  u2_waveform_ram : waveform_ram port map(
    i_DIA    => i_wav_d,
    i_WEA    => i_wav_we,
    i_clockA => i_wav_clk,
    i_ADDRA  => i_wav_addr,
    --o_DOA => o_DOA,
    --
    i_DIB    => "1111111111111111",
    i_WEB    => '0',
    i_clockB => not i_clk,
    i_ADDRB  => s_waveform_ADDRB,
    o_DOB    => s_waveform_DOB
    );

  -- generate a single clock pulse on hsync falling
  p_pulse_on_hsync_falling : process(i_clk)
    variable v_h_sync1 : std_logic;
  begin
    if rising_edge(i_clk) then
      s_h_sync_pulse <= not s_h_sync and v_h_sync1;
      v_h_sync1      := s_h_sync;
    end if;
  end process;


  -- control the reset, increment and overflow of the horizontal pixel count
  p_H_PX_COUNT : process(i_clk)                          --, i_reset)
  begin
    if rising_edge(i_clk) then
      if i_reset = '1' or s_h_count = c_H_PERIODpx then  -- sync reset
        s_h_count <= (others => '0');
      else
        s_h_count <= s_h_count + 1;
      end if;
    end if;
  end process;


  -- control the reset, increment and overflow of the vertical pixel count
  p_V_LN_COUNT : process(i_clk)
  begin
    if rising_edge(i_clk) then
      if i_reset = '1' or s_v_count = c_V_PERIODln then  -- sync reset
        s_v_count     <= (others => '0');
        s_v_count_d_4 <= s_v_count(3 downto 0);
      elsif s_h_sync_pulse = '1' then
        s_v_count     <= s_v_count + 1;
        s_v_count_d_4 <= s_v_count(3 downto 0);
      end if;
    end if;
  end process;

  -- set the horizontal sync high time and low time according to the constants
  p_MGM_H_SYNC : process(i_clk)         --, i_reset)
  begin
    if rising_edge(i_clk) then
      if (s_h_count = c_H_DISPLAYpx + c_H_BACKPORCHpx) then
        s_h_sync <= '0';
      elsif (s_h_count = c_H_PERIODpx - c_H_FRONTPORCHpx) then
        s_h_sync <= '1';
      end if;
    end if;
  end process;
  o_h_sync <= s_h_sync and i_h_sync_en;


  -- set the vertical sync high time and low time according to the constants
  p_MGM_V_SYNC : process(i_clk)         --, i_reset)
  begin
    --if falling_edge(i_clk) then
    if rising_edge(i_clk) then
      if i_v_sync_en = '0' or
        (s_v_count = (c_V_DISPLAYln + c_V_BACKPORCHln)) then
        o_v_sync <= '0';
      elsif (s_v_count = (c_V_PERIODln - c_V_FRONTPORCHln)) then  --and (s_h_sync_pulse = '1') then
        o_v_sync <= '1';
      end if;
    end if;
  end process;


  -- asserts the blaking signal (active low)
  p_MGM_BLANK : process (i_clk)         --, i_reset)
  begin
    if rising_edge(i_clk) then
      -- if we are outside the visible range on the screen then tell the RAMDAC to blank
      -- in this section by putting s_display low
      if not (s_h_count < c_H_DISPLAYpx and s_v_count < c_V_DISPLAYln) then
        s_display <= '0';
      else
        s_display <= '1';
      end if;
    end if;
  end process;


  -- generates the r g b signals showing chars, grid and "cross cursor"
  p_MGM_RGB : process (i_clk)
    variable v_previous_pixel : std_logic_vector(9 downto 0) := "0100101100";
  begin
    if rising_edge(i_clk) then          -- not async reset
      if i_reset = '1' then             -- sync reset
        o_r <= '0';
        o_g <= '0';
        o_b <= '0';
      else
        if s_display = '1' then         -- display zone
          if (
            f_is_cursor_pixel(s_h_count, s_v_count, s_cursor_x, s_cursor_y) or
            f_is_grid_pixel(s_h_count, s_v_count)
            ) and (s_v_count(9) = '0')  -- < 512
          then  -- draw the cursor and/or WaveForm Grid references
            o_r <= s_cursor_color(2);
            o_g <= s_cursor_color(1);
            o_b <= s_cursor_color(0);
          elsif
            f_is_waveform_pixel(s_v_count, s_waveform_DOB(c_V_COUNT_W - 1 downto 0), v_previous_pixel)
          then                          -- draw the waveform pixel...
            o_r <= s_waveform_DOB(12) or s_waveform_DOB(15);  -- the "or" is only
            o_g <= s_waveform_DOB(11) or s_waveform_DOB(14);  -- to not warning
            o_b <= s_waveform_DOB(10) or s_waveform_DOB(13);  -- unused signals
          else                          -- draw the background and charmaps
            case (s_h_count(2 downto 0)) is
              when "000"  => o_g <= s_charmaps_DO(7) xor s_bg_color(1);
              when "001"  => o_g <= s_charmaps_DO(6) xor s_bg_color(1);
              when "010"  => o_g <= s_charmaps_DO(5) xor s_bg_color(1);
              when "011"  => o_g <= s_charmaps_DO(4) xor s_bg_color(1);
              when "100"  => o_g <= s_charmaps_DO(3) xor s_bg_color(1);
              when "101"  => o_g <= s_charmaps_DO(2) xor s_bg_color(1);
              when "110"  => o_g <= s_charmaps_DO(1) xor s_bg_color(1);
              when "111"  => o_g <= s_charmaps_DO(0) xor s_bg_color(1);
              when others => o_g <= 'X';
            end case;

            o_r <= s_bg_color(2);
            --o_g <= s_bg_color(1);
            o_b <= s_bg_color(0);
          end if;
        else                            -- blank zone
          -- the blanking zone
          o_r <= '0';
          o_g <= '0';
          o_b <= '0';
        end if;  -- if s_display
        v_previous_pixel := s_waveform_DOB(9 downto 0);
      end if;  -- if i_reset
    end if;  -- if rising_edge(i_clk)
  end process;

end rtl;
