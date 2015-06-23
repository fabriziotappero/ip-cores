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

-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity chars_RAM is
  port (
    i_clock_rw : in  std_logic;         -- Write Clock
    i_EN_rw    : in  std_logic;         -- Write RAM Enable Input
    i_WE_rw    : in  std_logic_vector(c_CHR_WE_BUS_W - 1 downto 0);  -- Write Enable Input
    i_ADDR_rw  : in  std_logic_vector(10 downto 0);  -- Write 11-bit Address Input
    i_DI_rw    : in  std_logic_vector(31 downto 0);  -- Write 32-bit Data Input
    o_DI_rw    : out std_logic_vector(31 downto 0);  -- Write 32-bit Data Input

    i_SSR : in std_logic;               -- Synchronous Set/Reset Input

    i_clock_r : in  std_logic;          -- Read Clock
    i_EN_r    : in  std_logic;
    i_ADDR_r  : in  std_logic_vector(12 downto 0);  -- Read 13-bit Address Input
    o_DO_r    : out std_logic_vector(7 downto 0)    -- Read 8-bit Data Output
    );
end chars_RAM;

architecture Behavioral of chars_RAM is
  signal s0_DO_r : std_logic_vector(7 downto 0);
  signal s1_DO_r : std_logic_vector(7 downto 0);
  signal s2_DO_r : std_logic_vector(7 downto 0);
  signal s3_DO_r : std_logic_vector(7 downto 0);

  constant c_ram_size : natural := 2**(c_CHR_ADDR_BUS_W);

  type t_ram is array (c_ram_size-1 downto 0) of
    std_logic_vector (c_INTCHR_DATA_BUS_W - 1 downto 0);

  shared variable v_ram0 : t_ram := (
    27 => X"05",  -- config "bg and curs color" (108/4 = 27)

    768    => X"00", 769 => X"04", 770 => X"08", 771 => X"0C",
    772    => X"10", 773 => X"14", 774 => X"18", 775 => X"1C",
    1024   => X"20", 1025 => X"24", 1026 => X"28", 1027 => X"2C",
    1028   => X"30", 1029 => X"34", 1030 => X"38", 1031 => X"3C",
    1032   => X"40", 1033 => X"44", 1034 => X"48", 1035 => X"4C",
    1036   => X"50", 1037 => X"54", 1038 => X"58", 1039 => X"5C",
    1040   => X"60", 1041 => X"64", 1042 => X"68", 1043 => X"6C",
    1044   => X"70", 1045 => X"74", 1046 => X"78", 1047 => X"7C",
    1126   => X"53",                    -- S
    1127   => X"72",                    -- r
    1128   => X"6D",                    -- m
    1129   => X"20",                    --  
    1130   => X"64",                    -- d
    1131   => X"6D",                    -- m
    1132   => X"65",                    -- e
    1133   => X"61",                    -- a
    1134   => X"6E",                    -- n
    others => X"00"
    );

  shared variable v_ram1 : t_ram := (
    27 => X"07",  -- config "xy coords spans on three bytes" (108/4 = 27)

    768    => X"01", 769 => X"05", 770 => X"09", 771 => X"0D",
    772    => X"11", 773 => X"15", 774 => X"19", 775 => X"1D",
    1024   => X"21", 1025 => X"25", 1026 => X"29", 1027 => X"2D",
    1028   => X"31", 1029 => X"35", 1030 => X"39", 1031 => X"3D",
    1032   => X"41", 1033 => X"45", 1034 => X"49", 1035 => X"4D",
    1036   => X"51", 1037 => X"55", 1038 => X"59", 1039 => X"5D",
    1040   => X"61", 1041 => X"65", 1042 => X"69", 1043 => X"6D",
    1044   => X"71", 1045 => X"75", 1046 => X"79", 1047 => X"7D",
    1126   => X"61",                    -- a
    1127   => X"6F",                    -- o
    1128   => X"61",                    -- a
    1129   => X"2D",                    -- -
    1130   => X"72",                    -- r
    1131   => X"74",                    -- t
    1132   => X"74",                    -- t
    1133   => X"70",                    -- p
    1134   => X"65",                    -- e
    others => X"00"
    );

  shared variable v_ram2 : t_ram := (
    27 => X"09",  -- config "xy coords spans on three bytes" (108/4 = 27)

    768    => X"02", 769 => X"06", 770 => X"0A", 771 => X"0E",
    772    => X"12", 773 => X"16", 774 => X"1A", 775 => X"1E",
    1024   => X"22", 1025 => X"26", 1026 => X"2A", 1027 => X"2E",
    1028   => X"32", 1029 => X"36", 1030 => X"3A", 1031 => X"3E",
    1032   => X"42", 1033 => X"46", 1034 => X"4A", 1035 => X"4E",
    1036   => X"52", 1037 => X"56", 1038 => X"5A", 1039 => X"5E",
    1040   => X"62", 1041 => X"66", 1042 => X"6A", 1043 => X"6E",
    1044   => X"72", 1045 => X"76", 1046 => X"7A", 1047 => X"7E",
    1126   => X"6E",                    -- n
    1127   => X"20",                    --  
    1128   => X"74",                    -- t
    1129   => X"20",                    --  
    1130   => X"6F",                    -- o
    1131   => X"40",                    -- @
    1132   => X"73",                    -- s
    1133   => X"65",                    -- e
    1134   => X"74",                    -- t
    others => X"00"
    );

  shared variable v_ram3 : t_ram := (
    27 => X"5E",  -- config "xy coords spans on three bytes" (108/4 = 27)

    768    => X"03", 769 => X"07", 770 => X"0B", 771 => X"0F",
    772    => X"13", 773 => X"17", 774 => X"1B", 775 => X"1F",
    1024   => X"23", 1025 => X"27", 1026 => X"2B", 1027 => X"2F",
    1028   => X"33", 1029 => X"37", 1030 => X"3B", 1031 => X"3F",
    1032   => X"43", 1033 => X"47", 1034 => X"4B", 1035 => X"4F",
    1036   => X"53", 1037 => X"57", 1038 => X"5B", 1039 => X"5F",
    1040   => X"63", 1041 => X"67", 1042 => X"6B", 1043 => X"6F",
    1044   => X"73", 1045 => X"77", 1046 => X"7B", 1047 => X"7F",
    1126   => X"64",                    -- d
    1127   => X"41",                    -- A
    1128   => X"6F",                    -- o
    1129   => X"73",                    -- s
    1130   => X"61",                    -- a
    1131   => X"6E",                    -- n
    1132   => X"63",                    -- c
    1133   => X"2E",                    -- .
    1134   => X"20",                    --  
    others => X"00"
    );

begin

  p_rw0_port : process (i_clock_rw)
  begin
    if rising_edge(i_clock_rw) then
      if i_SSR = '1' then
        o_DI_rw(31 downto 24) <= (others => '0');
      elsif (i_EN_rw = '1') then
        o_DI_rw(31 downto 24) <= v_ram0(conv_integer(i_ADDR_rw));
        if (i_WE_rw(0) = '1') then
          v_ram0(conv_integer(i_ADDR_rw)) := i_DI_rw(31 downto 24);
        end if;
      end if;
    end if;
  end process;

  p_rw1_port : process (i_clock_rw)
  begin
    if rising_edge(i_clock_rw) then
      if i_SSR = '1' then
        o_DI_rw(23 downto 16) <= (others => '0');
      elsif (i_EN_rw = '1') then
        o_DI_rw(23 downto 16) <= v_ram1(conv_integer(i_ADDR_rw));
        if (i_WE_rw(1) = '1') then
          v_ram1(conv_integer(i_ADDR_rw)) := i_DI_rw(23 downto 16);
        end if;
      end if;
    end if;
  end process;

  p_rw2_port : process (i_clock_rw)
  begin
    if rising_edge(i_clock_rw) then
      if i_SSR = '1' then
        o_DI_rw(15 downto 8) <= (others => '0');
      elsif (i_EN_rw = '1') then
        o_DI_rw(15 downto 8) <= v_ram2(conv_integer(i_ADDR_rw));
        if (i_WE_rw(2) = '1') then
          v_ram2(conv_integer(i_ADDR_rw)) := i_DI_rw(15 downto 8);
        end if;
      end if;
    end if;
  end process;

  p_rw3_port : process (i_clock_rw)
  begin
    if rising_edge(i_clock_rw) then
      if i_SSR = '1' then
        o_DI_rw(7 downto 0) <= (others => '0');
      elsif (i_EN_rw = '1') then
        o_DI_rw(7 downto 0) <= v_ram3(conv_integer(i_ADDR_rw));
        if (i_WE_rw(3) = '1') then
          v_ram3(conv_integer(i_ADDR_rw)) := i_DI_rw(7 downto 0);
        end if;
      end if;
    end if;
  end process;


  p_ro0_port : process (i_clock_r)
  begin
    if rising_edge(i_clock_r) then
      if i_SSR = '1' then
        s0_DO_r <= (others => '0');
      elsif (i_EN_r = '1') then
        s0_DO_r <= v_ram0(conv_integer(i_ADDR_r(i_ADDR_r'left downto 2)));
      end if;
    end if;
  end process;

  p_ro1_port : process (i_clock_r)
  begin
    if rising_edge(i_clock_r) then
      if i_SSR = '1' then
        s1_DO_r <= (others => '0');
      elsif (i_EN_r = '1') then
        s1_DO_r <= v_ram1(conv_integer(i_ADDR_r(i_ADDR_r'left downto 2)));
      end if;
    end if;
  end process;

  p_ro2_port : process (i_clock_r)
  begin
    if rising_edge(i_clock_r) then
      if i_SSR = '1' then
        s2_DO_r <= (others => '0');
      elsif (i_EN_r = '1') then
        s2_DO_r <= v_ram2(conv_integer(i_ADDR_r(i_ADDR_r'left downto 2)));
      end if;
    end if;
  end process;

  p_ro3_port : process (i_clock_r)
  begin
    if rising_edge(i_clock_r) then
      if i_SSR = '1' then
        s3_DO_r <= (others => '0');
      elsif (i_EN_r = '1') then
        s3_DO_r <= v_ram3(conv_integer(i_ADDR_r(i_ADDR_r'left downto 2)));
      end if;
    end if;
  end process;

  o_DO_r <=
    s0_DO_r when i_ADDR_r(1 downto 0) = "00" else
    s1_DO_r when i_ADDR_r(1 downto 0) = "01" else
    s2_DO_r when i_ADDR_r(1 downto 0) = "10" else
    s3_DO_r when i_ADDR_r(1 downto 0) = "11" else
    (others => 'X');
end Behavioral;
