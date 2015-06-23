--
-- Risc5x
-- www.OpenCores.Org - November 2001
--
--
-- This library is free software; you can distribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published
-- by the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU Lesser General Public License for more details.
--
-- A RISC CPU core.
--
-- (c) Mike Johnson 2001. All Rights Reserved.
-- mikej@opencores.org for support or any other issues.
--
-- Revision list
--
-- version 1.0 initial opencores release
--

use work.pkg_risc5x.all;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity REGS is
  port (
    WE              : in  std_logic;
    RE              : in  std_logic;
    BANK            : in  std_logic_vector(1 downto 0);
    LOCATION        : in  std_logic_vector(4 downto 0);
    DIN             : in  std_logic_vector(7 downto 0);
    DOUT            : out std_logic_vector(7 downto 0);
    RESET           : in  std_logic;
    CLK             : in  std_logic
    );
end;
--
-- USE THIS ARCHITECTURE FOR XILINX
--
use work.pkg_risc5x.all;
use work.pkg_xilinx_prims.all;
use work.pkg_prims.all;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

architecture VIRTEX of REGS is

  constant WIDTH : natural := 8;
  constant OP_REG : boolean := false;

  type slv_array is array (natural range <>) of std_logic_vector(WIDTH-1 downto 0);
  signal ram_out : slv_array(4 downto 0);
  signal wen_int : std_logic_vector(4 downto 0);
  signal sel     : std_logic_vector(2 downto 0);

begin -- architecture

  -- ram mapping
  -- bank location
  -- xx   00xxx special registers
  -- xx   01xxx common 8 to all banks
  -- 00   1xxxx 16 bank 0
  -- 01   1xxxx 16 bank 1
  -- 10   1xxxx 16 bank 2
  -- 11   1xxxx 16 bank 3
  p_wen_comb : process (BANK,LOCATION,WE)
    variable addr : std_logic_vector(3 downto 0);
  begin
    addr := (BANK & LOCATION(4 downto 3));
    wen_int <= (others => '0');
    case addr(3 downto 1) is
      when "001" => wen_int(0) <= WE; -- bank0
      when "011" => wen_int(1) <= WE; -- bank1
      when "101" => wen_int(2) <= WE; -- bank2
      when "111" => wen_int(3) <= WE; -- bank3

      when others => null;
    end case;
    if (LOCATION(4 downto 3) = "01") then
      wen_int(4) <= WE; -- common
    end if;
  end process;

  ram_bit : for i in 0 to WIDTH-1 generate
  begin
    rams : for j in 0 to 4 generate
    attribute RLOC of ram: label is "R" & integer'image((WIDTH -1)-i) & "C" & integer'image((j+1)/2) & ".S" & integer'image(1 - ((j+1) mod 2));
    begin
      ram : RAM16X1D
      port map (
        a0    => LOCATION(0),
        a1    => LOCATION(1),
        a2    => LOCATION(2),
        a3    => LOCATION(3),
        dpra0 => LOCATION(0),
        dpra1 => LOCATION(1),
        dpra2 => LOCATION(2),
        dpra3 => LOCATION(3),
        wclk  => CLK,
        we    => wen_int(j),
        d     => DIN(i),
        dpo   => ram_out(j)(i));
    end generate;
  end generate;

  SEL <= BANK & LOCATION(4);

  mux : if true generate
    attribute RLOC of mux8_1: label is "R0C3";
  begin
    mux8_1 : MUX8
      generic map (
        WIDTH         => WIDTH,
        OP_REG        => OP_REG
        )
      port map (
        DIN7          => ram_out(3),
        DIN6          => ram_out(4),
        DIN5          => ram_out(2),
        DIN4          => ram_out(4),
        DIN3          => ram_out(1),
        DIN2          => ram_out(4),
        DIN1          => ram_out(0),
        DIN0          => ram_out(4),

        SEL           => sel,
        ENA           => '1', -- not used
        CLK           => CLK, -- not used

        DOUT          => DOUT
        );
   end generate;
end VIRTEX;

--pragma translate_off

use work.pkg_risc5x.all;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

architecture RTL of REGS is
  signal final_addr : std_logic_vector(6 downto 0);
  constant WIDTH : natural := 8;
  constant OP_REG : boolean := false;

  -- following required for simulation model only
  constant nwords : integer := 2 ** 7;
  type ram_type is array (0 to nwords-1) of std_logic_vector(WIDTH-1 downto 0);
  signal ram_read_data : std_logic_vector(WIDTH-1 downto 0);
  --shared variable ram :ram_type := (others => (others => 'X')); -- helps debug no end!
  shared variable ram :ram_type := (others => (others => '0'));

begin -- architecture
  p_remap : process(BANK,LOCATION)
    variable addr : std_logic_vector(3 downto 0);
  begin
    addr := (BANK & LOCATION(4 downto 3));
    final_addr <= "0000000";
    case addr is
      when "0001" => final_addr <= "0000" & LOCATION(2 downto 0);
      when "0101" => final_addr <= "0000" & LOCATION(2 downto 0);
      when "1001" => final_addr <= "0000" & LOCATION(2 downto 0);
      when "1101" => final_addr <= "0000" & LOCATION(2 downto 0);
      -- bank #0
      when "0010" => final_addr <= "0001" & LOCATION(2 downto 0);
      when "0011" => final_addr <= "0010" & LOCATION(2 downto 0);
      -- bank #1
      when "0110" => final_addr <= "0011" & LOCATION(2 downto 0);
      when "0111" => final_addr <= "0100" & LOCATION(2 downto 0);
      -- bank #2
      when "1010" => final_addr <= "0101" & LOCATION(2 downto 0);
      when "1011" => final_addr <= "0110" & LOCATION(2 downto 0);
      -- bank #3
      when "1110" => final_addr <= "0111" & LOCATION(2 downto 0);
      when "1111" => final_addr <= "1000" & LOCATION(2 downto 0);
      when others => null;
    end case;
  end process;

  -- you should replace the following simulation memory model
  -- with a dpram (no clock delay on read) for synthesis if
  -- you do not wish to use the Xilinx Virtex architecture.
  -- i.e.
  --
  --U1: dpram
  --  generic map (addr_bits => 7,
  --               data_bits => 8)
  --  port map (
  --    reset   => RESET,
  --    wr_clk  => CLK,
  --    wr_en   => WE,
  --    wr_addr => final_addr,
  --    wr_data => DIN,
  --    rd_clk  => '0',
  --    rd_addr => final_addr,
  --    rd_data => DOUT
  --    );

  -- SIMULATION MODEL OF RAM
  p_ram_write : process
    variable ram_addr : integer := 0;
  begin
    wait until CLK'event and (CLK = '1');
    if (WE = '1') then
      ram_addr := slv_to_integer(final_addr);
      ram(ram_addr) := DIN;
    end if;
  end process;

  p_ram_read_comb : process(CLK,final_addr)
    variable ram_addr : integer := 0;
  begin
    ram_addr := slv_to_integer(final_addr);
    ram_read_data <= ram(ram_addr);
  end process;

  opreg : if OP_REG generate
    p_opreg : process
    begin
      wait until CLK'event and (CLK = '1');
      if (RE = '1') then
        DOUT <= ram_read_data;
      end if;
    end process;
  end generate;

  opwire : if not OP_REG generate
    DOUT <= ram_read_data;
  end generate;

end RTL;

--pragma translate_on

