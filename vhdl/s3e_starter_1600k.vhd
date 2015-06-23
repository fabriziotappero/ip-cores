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

entity s3e_starter_1600k is
  port (i_clk   : in  std_logic;
        o_hsync : out std_logic;
        o_vsync : out std_logic;
        o_r     : out std_logic;
        o_g     : out std_logic;
        o_b     : out std_logic);
end s3e_starter_1600k;

architecture Behavioral of s3e_starter_1600k is

  component vga_ctrl
    port(
      i_clk       : in  std_logic;
      i_reset     : in  std_logic;
      i_h_sync_en : in  std_logic;
      i_v_sync_en : in  std_logic;
      i_chr_addr  : in  std_logic_vector(c_CHR_ADDR_BUS_W - 1 downto 0);
      i_chr_data  : in  std_logic_vector(c_CHR_DATA_BUS_W - 1 downto 0);
      i_chr_clk   : in  std_logic;
      i_chr_en    : in  std_logic;
      i_chr_we    : in  std_logic_vector(c_CHR_WE_BUS_W - 1 downto 0);
      i_chr_rst   : in  std_logic;
      i_wav_d     : in  std_logic_vector(c_WAVFRM_DATA_BUS_W - 1 downto 0);
      i_wav_clk   : in  std_logic;
      i_wav_we    : in  std_logic;
      i_wav_addr  : in  std_logic_vector(c_WAVFRM_ADDR_BUS_W - 1 downto 0);
      o_h_sync    : out std_logic;
      o_v_sync    : out std_logic;
      o_r         : out std_logic;
      o_g         : out std_logic;
      o_b         : out std_logic;
      o_chr_data  : out std_logic_vector(c_CHR_DATA_BUS_W - 1 downto 0)
      );
  end component;

  signal s_hsync : std_logic;
  signal s_vsync : std_logic;
  signal s_r     : std_logic;
  signal s_g     : std_logic;
  signal s_b     : std_logic;

  signal s_vsync_count : std_logic_vector(7 downto 0) := (others => '0');
  signal s_vsync1      : std_logic;

  signal s_chr_addr : std_logic_vector(c_CHR_ADDR_BUS_W - 1 downto 0);  -- := (others => '0');
  signal s_chr_data : std_logic_vector(c_CHR_DATA_BUS_W - 1 downto 0);  -- := (others => '0');
  signal s_rnd      : std_logic_vector(c_CHR_DATA_BUS_W - 1 downto 0);  -- := (others => '0');
  signal s_chr_we   : std_logic_vector(c_CHR_WE_BUS_W - 1 downto 0);

  signal s_wav_addr : std_logic_vector(c_WAVFRM_ADDR_BUS_W - 1 downto 0);
  signal s_wav_d    : std_logic_vector(c_WAVFRM_DATA_BUS_W - 1 downto 0);
  signal s_mul      : std_logic_vector(7 downto 0);

  signal s_initialized : std_logic := '0';

  attribute U_SET                  : string;
  attribute U_SET of "u1_vga_ctrl" : label is "u1_vga_ctrl_uset";
  
begin
  o_hsync <= s_hsync;
  o_vsync <= s_vsync;
  o_r     <= s_r;
  o_g     <= s_g;
  o_b     <= s_b;
  
  u1_vga_ctrl : vga_ctrl port map(
    i_clk       => i_clk,
    i_reset     => '0',
    o_h_sync    => s_hsync,
    o_v_sync    => s_vsync,
    i_h_sync_en => '1',
    i_v_sync_en => '1',
    o_r         => s_r,
    o_g         => s_g,
    o_b         => s_b,
    i_chr_addr  => s_chr_addr,          --B"000_0000_0000",
    i_chr_data  => s_chr_data,          --X"00000000",
    o_chr_data  => open,
    i_chr_clk   => i_clk,
    i_chr_en    => '1',
    i_chr_we    => s_chr_we,
    i_chr_rst   => '0',
    i_wav_d     => s_wav_d,  --X"0000",  --s_rnd(15 downto 0), --
    i_wav_clk   => i_clk,
    i_wav_we    => '0',  --'0',  -- '1',
    i_wav_addr  => s_wav_addr  --B"00_0000_0000"  --s_chr_addr(9 downto 0) --
    );
  s_wav_addr <= s_rnd(1 downto 0) & s_vsync_count;
  s_mul      <= s_vsync_count(3 downto 0) * s_vsync_count(3 downto 0);
  s_wav_d    <= B"000" & s_rnd(2 downto 0) & B"00" & s_mul;
  --s_wav_d <= B"000" & "100" & B"00" & s_mul;

--  s_chr_data <= s_rnd;
--  p_write_chars : process(i_clk)
--  begin
--    if rising_edge(i_clk) then
--      -- during the sync time in order to avoid flickering
--      -- and each 128 vsync in order to stop for a while
--      -- will write random chars...
--      if s_vsync_count(7) = '1' and (s_hsync = '0' or s_vsync = '0') then
--        -- generate a pseudo random 32 bit number
--        s_rnd <= s_rnd(30 downto 0) & (s_rnd(31) xnor s_rnd(21) xnor s_rnd(1) xnor s_rnd(0));
--        -- increment the address and write enable...
--        s_chr_addr <= s_chr_addr + 1;
--        s_chr_we   <= "1111";
--      else
--        s_chr_addr <= s_chr_addr;
--        s_chr_we   <= "0000";
--        s_rnd      <= s_rnd;
--      end if;
--    end if;
--  end process;

--              cols              cols
--           00_01_02_03  ...  96_97_98_99
--   row_00 "00000000000" ... "00000011000"
--   row_01 "00000100000" ... "00000111000"
--    ...        ...               ...
--   row_37 "10010100000" ... "10010111000"
  p_write_chars : process(i_clk)
  begin
    if rising_edge(i_clk) then
      if s_initialized = '0' then
        case s_vsync_count(2 downto 0) is
          when "000" =>                 -- write ABCD
            s_chr_we   <= "1111";
            s_chr_addr <= "00000000000";
            s_chr_data <= "01000001" & "01000010" & "01000011" & "01000100";
          when "001" =>                 -- write EFGH
            s_chr_we   <= "1111";
            s_chr_addr <= "00000011000";
            s_chr_data <= "01000101" & "01000110" & "01000111" & "01001000";
          when "010" =>                 -- write IJKL
            s_chr_we   <= "1111";
            s_chr_addr <= "00000100000";
            s_chr_data <= "01001001" & "01001010" & "01001011" & "01001100";
          when "011" =>                 -- write MNOP
            s_chr_we   <= "1111";
            s_chr_addr <= "10010100000";
            s_chr_data <= "01001101" & "01001110" & "01001111" & "01010000";
          when "100" =>                 -- write QRST
            s_chr_we   <= "1111";
            s_chr_addr <= "10010111000";
            s_chr_data <= "01010001" & "01010010" & "01010011" & "01010100";
          when "101" =>  -- write config grid and cursor color (overwrite RAM defaults)
            s_chr_we      <= "1111";
            s_chr_addr    <= c_CFG_BG_CUR_COLOR_ADDR(c_CFG_BG_CUR_COLOR_ADDR'left downto 2);  -- c_CFG_BG_CUR_COLOR_ADDR >> 2
            --             ND   bgColor grid,cur   ND       curs_x          curs_y
            s_chr_data    <= "00" & "000" & "101" & "000" & "00111000010" & "0101011110";
            --            |--------108-------|-------109-------|----110-----|--111--|
            s_initialized <= '1';
          when others =>
            s_chr_we   <= (others => '0');
            s_chr_addr <= (others => '1');
            s_chr_data <= "10111110" & "10111101" & "10111100" & "10111011";
        end case;
      else
        s_chr_we <= (others => '0');
      end if;
    end if;
  end process;

--  p_rnd_bit : process(i_clk)
--    variable v_rnd_fb : std_logic;
--    variable v_rnd : std_logic_vector(31 downto 0);
--  begin
--    if rising_edge(i_clk) then
--      s_rnd_bit <= v_rnd_fb;
--      v_rnd_fb := v_rnd(31) xnor v_rnd(21) xnor v_rnd(1) xnor v_rnd(0);
--      v_rnd    := v_rnd(30 downto 0) & v_rnd_fb;
--    end if;
--  end process;

  p_vsync_count : process(i_clk)
  begin
    if rising_edge(i_clk) then
      s_vsync1 <= s_vsync;
      if (not s_vsync and s_vsync1) = '1' then  -- pulse on vsync falling
        s_vsync_count <= s_vsync_count + 1;
      end if;
    end if;
  end process;



end Behavioral;

