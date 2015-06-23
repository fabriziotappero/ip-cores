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

-- Top level design for a Xilinx FPGA with a CPU core and some program block ram.

use work.pkg_risc5x.all;
use work.pkg_xilinx_prims.all;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity RISC5X_XIL is
  port (
    I_PRAM_ADDR       : in  std_logic_vector(10 downto 0);
    I_PRAM_DIN        : in  std_logic_vector(11 downto 0);
    O_PRAM_DOUT       : out std_logic_vector(11 downto 0);
    I_PRAM_WE         : in  std_logic;
    I_PRAM_ENA        : in  std_logic;
    PRAM_CLK          : in  std_logic;
    --
    IO_PORTA_IO       : inout std_logic_vector(7 downto 0);
    IO_PORTB_IO       : inout std_logic_vector(7 downto 0);
    IO_PORTC_IO       : inout std_logic_vector(7 downto 0);

    O_DEBUG_W         : out std_logic_vector(7 downto 0);
    O_DEBUG_PC        : out std_logic_vector(10 downto 0);
    O_DEBUG_INST      : out std_logic_vector(11 downto 0);
    O_DEBUG_STATUS    : out std_logic_vector(7 downto 0);

    RESET             : in  std_logic;
    CLK               : in  std_logic
    );
end;

architecture RTL of RISC5X_XIL is
  signal porta_in        : std_logic_vector(7 downto 0);
  signal porta_out       : std_logic_vector(7 downto 0);
  signal porta_oe_l      : std_logic_vector(7 downto 0);

  signal portb_in        : std_logic_vector(7 downto 0);
  signal portb_out       : std_logic_vector(7 downto 0);
  signal portb_oe_l      : std_logic_vector(7 downto 0);

  signal portc_in        : std_logic_vector(7 downto 0);
  signal portc_out       : std_logic_vector(7 downto 0);
  signal portc_oe_l      : std_logic_vector(7 downto 0);

  signal paddr           : std_logic_vector(10 downto 0);
  signal pdata           : std_logic_vector(11 downto 0);
  signal pram_addr       : std_logic_vector(10 downto 0);
  signal pram_din        : std_logic_vector(11 downto 0);
  signal pram_dout       : std_logic_vector(11 downto 0);
  signal pram_we         : std_logic;
  signal pram_ena        : std_logic;

  signal debug_w         : std_logic_vector(7 downto 0);
  signal debug_pc        : std_logic_vector(10 downto 0);
  signal debug_inst      : std_logic_vector(11 downto 0);
  signal debug_status    : std_logic_vector(7 downto 0);

  signal doa_temp        : std_logic_vector(11 downto 0);
  signal dob_temp        : std_logic_vector(11 downto 0);

  component CPU is
    port (
      PADDR           : out std_logic_vector(10 downto 0);
      PDATA           : in  std_logic_vector(11 downto 0);

      PORTA_IN        : in    std_logic_vector(7 downto 0);
      PORTA_OUT       : out   std_logic_vector(7 downto 0);
      PORTA_OE_L      : out   std_logic_vector(7 downto 0);

      PORTB_IN        : in    std_logic_vector(7 downto 0);
      PORTB_OUT       : out   std_logic_vector(7 downto 0);
      PORTB_OE_L      : out   std_logic_vector(7 downto 0);

      PORTC_IN        : in    std_logic_vector(7 downto 0);
      PORTC_OUT       : out   std_logic_vector(7 downto 0);
      PORTC_OE_L      : out   std_logic_vector(7 downto 0);

      DEBUG_W         : out std_logic_vector(7 downto 0);
      DEBUG_PC        : out std_logic_vector(10 downto 0);
      DEBUG_INST      : out std_logic_vector(11 downto 0);
      DEBUG_STATUS    : out std_logic_vector(7 downto 0);

      RESET           : in  std_logic;
      CLK             : in  std_logic
      );
  end component;

begin
  u0 : CPU
    port map (
      PADDR           => paddr,
      PDATA           => pdata,

      PORTA_IN        => porta_in,
      PORTA_OUT       => porta_out,
      PORTA_OE_L      => porta_oe_l,

      PORTB_IN        => portb_in,
      PORTB_OUT       => portb_out,
      PORTB_OE_L      => portb_oe_l,

      PORTC_IN        => portc_in,
      PORTC_OUT       => portc_out,
      PORTC_OE_L      => portc_oe_l,

     -- DEBUG_W         => debug_w,
     -- DEBUG_PC        => debug_pc,
     -- DEBUG_INST      => debug_inst,
     -- DEBUG_STATUS    => debug_status,

      RESET           => RESET,
      CLK             => CLK
      );

  p_drive_ports_out_comb : process(porta_out,porta_oe_l,portb_out,portb_oe_l,portc_out,portc_oe_l)
  begin
    for i in 0 to 7 loop
      if (porta_oe_l(i) = '0') then
        IO_PORTA_IO(i) <= porta_out(i);
      else
        IO_PORTA_IO(i) <= 'Z';
      end if;

      if (portb_oe_l(i) = '0') then
        IO_PORTB_IO(i) <= portb_out(i);
      else
        IO_PORTB_IO(i) <= 'Z';
      end if;

      if (portc_oe_l(i) = '0') then
        IO_PORTC_IO(i) <= portc_out(i);
      else
        IO_PORTC_IO(i) <= 'Z';
      end if;
    end loop;
  end process;

  p_drive_ports_in_comb : process(IO_PORTA_IO,IO_PORTB_IO,IO_PORTC_IO)
  begin
    porta_in <= IO_PORTA_IO;
    portb_in <= IO_PORTB_IO;
    portc_in <= IO_PORTC_IO;
  end process;

  prams : for i in 0 to 5 generate
    attribute INIT_00 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_01 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_02 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_03 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_04 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_05 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_06 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_07 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_08 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_09 of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0A of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0B of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0C of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0D of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0E of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
    attribute INIT_0F of inst : label is "0000000000000000000000000000000000000000000000000000000000000000";
  begin
  inst : ramb4_s2_s2
    port map (
      dob   => pdata(i*2 +1 downto i*2),
      dib   => "00",
      addrb => paddr,
      web   => '0',
      enb   => '1',
      rstb  => '0',
      clkb  => CLK,

      doa   => pram_dout(i*2 +1 downto i*2),
      dia   => pram_din(i*2 +1 downto i*2),
      addra => pram_addr,
      wea   => pram_we,
      ena   => pram_ena,
      rsta  => '0',
      clka  => PRAM_CLK
      );
  end generate;

  --p_debug : process
  --begin
  --  wait until CLK'event and (CLK = '1');
  --  O_DEBUG_W         <= debug_w;
  --  O_DEBUG_PC        <= debug_pc;
  --  O_DEBUG_INST      <= debug_inst;
  --  O_DEBUG_STATUS    <= debug_status;
  --end process;

  p_pram : process
  begin
    wait until PRAM_CLK'event and (PRAM_CLK = '1');
    pram_addr   <= I_PRAM_ADDR;
    pram_din    <= I_PRAM_DIN;
    O_PRAM_DOUT <= pram_dout;
    pram_we     <= I_PRAM_WE;
    pram_ena    <= I_PRAM_ENA;
  end process;
end RTL;

