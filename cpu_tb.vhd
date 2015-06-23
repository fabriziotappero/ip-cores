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
-- NOTE THIS JUST A TOP LEVEL TEST BENCH

use work.pkg_risc5x.all;
use std.textio.ALL;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity cpu_tb is
end;

architecture Sim of cpu_tb is
  signal clk             : std_logic;
  signal reset           : std_logic := '1';

  signal paddr           : std_logic_vector(10 downto 0);
  signal pdata           : std_logic_vector(11 downto 0) := (others => '0');

  signal porta_in        : std_logic_vector(7 downto 0);
  signal porta_out       : std_logic_vector(7 downto 0);
  signal porta_oe_l      : std_logic_vector(7 downto 0);

  signal portb_in        : std_logic_vector(7 downto 0);
  signal portb_out       : std_logic_vector(7 downto 0);
  signal portb_oe_l      : std_logic_vector(7 downto 0);

  signal portc_in        : std_logic_vector(7 downto 0);
  signal portc_out       : std_logic_vector(7 downto 0);
  signal portc_oe_l      : std_logic_vector(7 downto 0);

  signal porta_io        : std_logic_vector(7 downto 0) := (others => 'H');
  signal portb_io        : std_logic_vector(7 downto 0) := (others => 'H');
  signal portc_io        : std_logic_vector(7 downto 0) := (others => 'H');

  signal debug_w         : std_logic_vector(7 downto 0);
  signal debug_pc        : std_logic_vector(10 downto 0);
  signal debug_inst      : std_logic_vector(11 downto 0);
  signal debug_status    : std_logic_vector(7 downto 0);
  signal test_addr, test_val : integer;
  signal inst_string     : string(8 downto 1);
  signal pc_t1           : std_logic_vector(10 downto 0);

  signal cnt             : std_logic_vector(7 downto 0) := (others => '0');
  constant cDelay : time := 5 ns;
  constant ClkPeriod : time := 20 ns;
  constant filename : string := "JUMPTEST.HEX";
  constant nwords : integer := 2 ** 11;

  type ram_type is array (0 to nwords-1) of std_logic_vector(11 downto 0);
  shared variable ram :ram_type := (others => (others => '0'));

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

      DEBUG_W         => debug_w,
      DEBUG_PC        => debug_pc,
      DEBUG_INST      => debug_inst,
      DEBUG_STATUS    => debug_status,

      RESET           => reset,
      CLK             => clk
      );

  p_drive_ports_out_comb : process(porta_out,porta_oe_l,portb_out,portb_oe_l,portc_out,portc_oe_l)
  begin
    for i in 0 to 7 loop
      if (porta_oe_l(i) = '0') then
        porta_io(i) <= porta_out(i);
      else
        porta_io(i) <= 'Z';
      end if;

      if (portb_oe_l(i) = '0') then
        portb_io(i) <= portb_out(i);
      else
        portb_io(i) <= 'Z';
      end if;

      if (portc_oe_l(i) = '0') then
        portc_io(i) <= portc_out(i);
      else
        portc_io(i) <= 'Z';
      end if;
    end loop;

  end process;

  p_pullup : process(porta_io,portb_io,portc_io)
  begin
    -- stop unknowns in simulation
    porta_io <= (others => 'H');
    portb_io <= (others => 'H');
    portc_io <= (others => 'H');
  end process;

  p_drive_ports_in_comb : process(porta_io,portb_io,portc_io)
  begin
    porta_in <= porta_io;
    portb_in <= portb_io;
    portc_in <= portc_io;
  end process;

  p_clks : process
  begin
    CLK <= '0';
    wait for ClkPeriod / 2;
    CLK <= '1';
    wait for ClkPeriod / 2;
  end process;

  p_prom : process (RESET,CLK)
  begin
    if (RESET = '1') then
      pdata <= (others=>'0');
    elsif CLK'event and (CLK ='1') then
      pdata <= ram(slv_to_integer(paddr));
    end if;
  end process;

  p_pc : process
  begin
    wait until CLK'event and (CLK = '1');
    pc_t1 <= debug_pc;
  end process;

  p_drive_a : process
  begin
    porta_io <= x"02";
    wait for ClkPeriod * 50;
    porta_io <= x"03";
    wait for ClkPeriod * 50;
  end process;

  p_cpu_top : process
  begin
    reset <= '1';
    wait until CLK'event and CLK = '1';
    reset <= '0' after 100 ns;
    wait;
  end process;

  p_readhex : process
    function digit_value(c : character) return integer is
      begin
        if (c >= '0') and (c <= '9') then
           return (character'pos(c) - character'pos('0'));
        elsif (c >= 'a') and (c <= 'f') THEN
           return (character'pos(c) - character'pos('a') + 10);
        elsif (c >= 'A') and (c <= 'F') THEN
           return (character'pos(c) - character'pos('A') + 10);
        else
           assert false report "ERROR IN HEX FILE !!" severity note;
           return 999;
        end if;
      end;

    file hex_file : TEXT open read_mode is filename;
    variable l : line;
    variable val, pos : integer := 0;
    variable numbytes,addr,ltype : integer := 0;
    variable ram_data : std_logic_vector(11 downto 0);
  begin
    assert false report "Loading hex file" & filename severity note;
    while not endfile (hex_file) loop
      readline (hex_file, l);
      if l'left > l'right then next; end if; -- ignore blanks
       --hex file format
       --BBAAAATT HH CC

       --BB number of HH's, AAAA addr, TT 00 - data (ignore others), CC - checksum
       --skip any spaces or :'s
      pos := l'low;
      for i in l'low TO l'high loop
        case l(i) IS
          when ' ' | ':' | ht  => pos := i + 1;
          when others => exit;
        end case;
      end loop;

      numbytes := digit_value(l(pos)) * 16;
      numbytes := numbytes + digit_value(l(pos + 1));

      addr := digit_value(l(pos+2)) * 16 * 16 * 16;
      addr := addr + digit_value(l(pos + 3)) * 16 * 16;
      addr := addr + digit_value(l(pos + 4)) * 16;
      addr := addr + digit_value(l(pos + 5)) ;
      addr := addr /2; -- word address
      ltype := digit_value(l(pos+6)) * 16;
      ltype := ltype + digit_value(l(pos+7));

      if not (ltype = 0) then next; end if;
      pos := pos + 8;
      for i in 1 to (numbytes/2) loop
        val := digit_value(l(pos)) * 16;
        val := val + digit_value(l(pos + 1));
        val := val + digit_value(l(pos + 2)) * 16 * 16 * 16;
        val := val + digit_value(l(pos + 3)) * 16 * 16;
        test_val <= val;
        test_addr <= addr;
        if (addr > nwords-1) then assert false report "ADDRESS TOO BIG !!";
          report "(have you included the configuration bits ??)"
          severity failure; exit;
        end if;
        if (val > (2**12)-1) then assert false report "DATA TOO BIG !!"
          severity failure; exit;
        end if;
         -- wait for 10 ns; -- debug
        ram_data := integer_to_slv(val,12);
        ram(addr) := ram_data;
        addr := addr + 1;
        pos := pos + 4;
      end loop;
    end loop;
    assert false report "Load hex done" severity note;
    wait;
  end process;

  p_debug_comb : process(DEBUG_INST)
  begin
    inst_string <= "-XXXXXX-";
    if DEBUG_INST(11 downto 0) = "000000000000" then inst_string <= "NOP     "; end if;
    if DEBUG_INST(11 downto 5) = "0000001"      then inst_string <= "MOVWF   "; end if;
    if DEBUG_INST(11 downto 0) = "000001000000" then inst_string <= "CLRW    "; end if;
    if DEBUG_INST(11 downto 5) = "0000011"      then inst_string <= "CLRF    "; end if;
    if DEBUG_INST(11 downto 6) = "000010"       then inst_string <= "SUBWF   "; end if;
    if DEBUG_INST(11 downto 6) = "000011"       then inst_string <= "DECF    "; end if;
    if DEBUG_INST(11 downto 6) = "000100"       then inst_string <= "IORWF   "; end if;
    if DEBUG_INST(11 downto 6) = "000101"       then inst_string <= "ANDWF   "; end if;
    if DEBUG_INST(11 downto 6) = "000110"       then inst_string <= "XORWF   "; end if;
    if DEBUG_INST(11 downto 6) = "000111"       then inst_string <= "ADDWF   "; end if;
    if DEBUG_INST(11 downto 6) = "001000"       then inst_string <= "MOVF    "; end if;
    if DEBUG_INST(11 downto 6) = "001001"       then inst_string <= "COMF    "; end if;
    if DEBUG_INST(11 downto 6) = "001010"       then inst_string <= "INCF    "; end if;
    if DEBUG_INST(11 downto 6) = "001011"       then inst_string <= "DECFSZ  "; end if;
    if DEBUG_INST(11 downto 6) = "001100"       then inst_string <= "RRF     "; end if;
    if DEBUG_INST(11 downto 6) = "001101"       then inst_string <= "RLF     "; end if;
    if DEBUG_INST(11 downto 6) = "001110"       then inst_string <= "SWAPF   "; end if;
    if DEBUG_INST(11 downto 6) = "001111"       then inst_string <= "INCFSZ  "; end if;

    --   *** Bit-Oriented File Register Operations
    if DEBUG_INST(11 downto 8) = "0100"         then inst_string <= "BCF     "; end if;
    if DEBUG_INST(11 downto 8) = "0101"         then inst_string <= "BSF     "; end if;
    if DEBUG_INST(11 downto 8) = "0110"         then inst_string <= "BTFSC   "; end if;
    if DEBUG_INST(11 downto 8) = "0111"         then inst_string <= "BTFSS   "; end if;

    --   *** Literal and Control Operations
    if DEBUG_INST(11 downto 0) = "000000000010" then inst_string <= "OPTION  "; end if;
    if DEBUG_INST(11 downto 0) = "000000000011" then inst_string <= "SLEEP   "; end if;
    if DEBUG_INST(11 downto 0) = "000000000100" then inst_string <= "CLRWDT  "; end if;
    if DEBUG_INST(11 downto 0) = "000000000101" then inst_string <= "TRIS    "; end if;
    if DEBUG_INST(11 downto 0) = "000000000110" then inst_string <= "TRIS    "; end if;
    if DEBUG_INST(11 downto 0) = "000000000111" then inst_string <= "TRIS    "; end if;
    if DEBUG_INST(11 downto 8) = "1000"         then inst_string <= "RETLW   "; end if;
    if DEBUG_INST(11 downto 8) = "1001"         then inst_string <= "CALL    "; end if;
    if DEBUG_INST(11 downto 9) = "101"          then inst_string <= "GOTO    "; end if;
    if DEBUG_INST(11 downto 8) = "1100"         then inst_string <= "MOVLW   "; end if;
    if DEBUG_INST(11 downto 8) = "1101"         then inst_string <= "IORLW   "; end if;
    if DEBUG_INST(11 downto 8) = "1110"         then inst_string <= "ANDLW   "; end if;
    if DEBUG_INST(11 downto 8) = "1111"         then inst_string <= "XORLW   "; end if;
  end process;

end Sim;

