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

entity IDEC is
  port (
    INST                : in  std_logic_vector(11 downto 0);

    ALU_ASEL            : out std_logic_vector(1 downto 0);
    ALU_BSEL            : out std_logic_vector(1 downto 0);
    ALU_ADDSUB          : out std_logic_vector(1 downto 0);
    ALU_BIT             : out std_logic_vector(1 downto 0);
    ALU_SEL             : out std_logic_vector(1 downto 0);

    WWE_OP              : out std_logic;
    FWE_OP              : out std_logic;

    ZWE                 : out std_logic;
    DCWE                : out std_logic;
    CWE                 : out std_logic;
    BDPOL               : out std_logic;
    OPTION              : out std_logic;
    TRIS                : out std_logic
    );
end;
architecture RTL of IDEC is

-- signal definitions
  signal alu    : std_logic_vector(9 downto 0) := (others => '0');
  signal flags  : std_logic_vector(2 downto 0) := (others => '0');
  signal fwe    : std_logic;
  signal wwe    : std_logic;
  signal we     : std_logic;

begin -- architecture

  -- aluasel,        Select source for ALU A input. 00=W, 01=SBUS, 10=K , 11= SBUS_SWAP
  -- alubsel,        Select source for ALU B input. 00=W, 01=SBUS, 10=BD, 11= "1"
  -- bit             0 : A and B, 1 : A or B, 2 : A xor B, 3 : not A
  -- wwe,            W register Write Enable
  -- fwe,            File Register Write Enable
  -- zwe,            Status register Z bit update
  -- dcwe            Status register DC bit update
  -- cwe,            Status register C bit update
  -- bdpol,          Polarity on bit decode vector (0=no inversion, 1=invert)
  -- tris,           Instruction is an TRIS instruction
  -- option          Instruction is an OPTION instruction

  p_inst_decode_comb : process(INST)
  begin
    BDPOL       <= '0';
    OPTION      <= '0';
    TRIS        <= '0';

    alu         <= (others => '0');
    flags       <= (others => '0');
    fwe         <= '0';
    wwe         <= '0';
    we          <= '0';
    case INST(11 downto 8) is
      when "0000" =>                                    --asel  bsel    +-    bit    sel
          if (INST(7 downto 0) = "00000000") then alu <= "00" & "00" & "00" & "00" & "00"; end if; -- NOP
          if (INST(7 downto 0) = "00000010") then alu <= "00" & "00" & "00" & "00" & "00"; fwe <= '1'; OPTION <= '1'; end if; -- OPTION
          if (INST(7 downto 0) = "00000011") then alu <= "00" & "00" & "00" & "00" & "00"; end if; -- SLEEP
          if (INST(7 downto 0) = "00000100") then alu <= "00" & "00" & "00" & "00" & "00"; end if; -- CLRWDT
          if (INST(7 downto 0) = "00000101") then alu <= "00" & "00" & "00" & "00" & "00"; fwe <= '1'; TRIS <= '1'; end if; -- TRIS 5
          if (INST(7 downto 0) = "00000110") then alu <= "00" & "00" & "00" & "00" & "00"; fwe <= '1'; TRIS <= '1'; end if; -- TRIS 6
          if (INST(7 downto 0) = "00000111") then alu <= "00" & "00" & "00" & "00" & "00"; fwe <= '1'; TRIS <= '1'; end if; -- TRIS 7
          if (INST(7 downto 5) = "001"     ) then alu <= "00" & "00" & "00" & "00" & "00"; fwe <= '1'; end if; -- MOVWF

          if (INST(7 downto 0) = "01000000") then alu <= "00" & "00" & "00" & "10" & "01"; wwe <= '1'; flags <= "100"; end if; -- CLRW
          if (INST(7 downto 5) = "011"     ) then alu <= "00" & "00" & "00" & "10" & "01"; fwe <= '1'; flags <= "100"; end if; -- CLRF

          if (INST(7 downto 6) = "10"      ) then alu <= "01" & "00" & "11" & "00" & "00";  we <= '1'; flags <= "111"; end if; -- SUBWF
          if (INST(7 downto 6) = "11"      ) then alu <= "01" & "11" & "11" & "00" & "00";  we <= '1'; flags <= "100"; end if; -- DECF
      when "0001" =>
        case INST(7 downto 6) is
          when "00" => alu <= "00" & "01" & "00" & "01" & "01"; we <= '1'; flags <= "100"; -- IORWF
          when "01" => alu <= "00" & "01" & "00" & "00" & "01"; we <= '1'; flags <= "100"; -- ANDWF
          when "10" => alu <= "00" & "01" & "00" & "10" & "01"; we <= '1'; flags <= "100"; -- XORWF
          when "11" => alu <= "00" & "01" & "10" & "00" & "00"; we <= '1'; flags <= "111"; -- ADDWF
          when others => null;
        end case;
      when "0010" =>
        case INST(7 downto 6) is
          when "00" => alu <= "01" & "00" & "00" & "00" & "00"; we <= '1'; flags <= "100"; -- MOVF
          when "01" => alu <= "01" & "00" & "00" & "11" & "01"; we <= '1'; flags <= "100"; -- COMF
          when "10" => alu <= "01" & "11" & "10" & "00" & "00"; we <= '1'; flags <= "100"; -- INCF
          when "11" => alu <= "01" & "11" & "11" & "00" & "00"; we <= '1'; flags <= "000"; -- DECFSZ
          when others => null;
        end case;
      when "0011" =>
        case INST(7 downto 6) is
          when "00" => alu <= "01" & "00" & "00" & "00" & "10"; we <= '1'; flags <= "001"; -- RRF
          when "01" => alu <= "01" & "00" & "00" & "00" & "11"; we <= '1'; flags <= "001"; -- RLF
          when "10" => alu <= "11" & "00" & "00" & "00" & "00"; we <= '1'; flags <= "000"; -- SWAPF
          when "11" => alu <= "01" & "11" & "10" & "00" & "00"; we <= '1'; flags <= "000"; -- INCFSZ
          when others => null;
        end case;

      when "0100" => alu <= "01" & "10" & "00" & "00" & "01"; fwe <= '1'; flags <= "000";  BDPOL <= '1'; -- BCF
      when "0101" => alu <= "01" & "10" & "00" & "01" & "01"; fwe <= '1'; flags <= "000"; -- BSF
      when "0110" => alu <= "01" & "10" & "00" & "00" & "01"; -- BTFSC
      when "0111" => alu <= "01" & "10" & "00" & "00" & "01"; -- BTFSS

      when "1000" => alu <= "10" & "00" & "00" & "00" & "00"; wwe <= '1'; -- RETLW
      when "1001" => alu <= "10" & "00" & "00" & "00" & "00"; -- CALL
      when "1010" => alu <= "10" & "00" & "00" & "00" & "00"; -- GOTO
      when "1011" => alu <= "10" & "00" & "00" & "00" & "00"; -- GOTO

      when "1100" => alu <= "10" & "00" & "00" & "00" & "00"; wwe <= '1'; flags <= "000"; -- MOVLW
      when "1101" => alu <= "10" & "00" & "00" & "01" & "01"; wwe <= '1'; flags <= "100"; -- IORLW
      when "1110" => alu <= "10" & "00" & "00" & "00" & "01"; wwe <= '1'; flags <= "100"; -- ANDLW
      when "1111" => alu <= "10" & "00" & "00" & "10" & "01"; wwe <= '1'; flags <= "100"; -- XORLW
      when others => null;
    end case;
  end process;


  p_we_comb : process(wwe,fwe,we,INST)
  begin
    WWE_OP <= '0';
    FWE_OP <= '0';

    if (wwe = '1') or ((we = '1') and (INST(5) ='0')) then
      WWE_OP <= '1';
    end if;

    if (fwe = '1') or ((we = '1') and (INST(5) = '1')) then
      FWE_OP <= '1';
    end if;
  end process;

  ALU_ASEL            <= alu(9 downto 8);
  ALU_BSEL            <= alu(7 downto 6);
  ALU_ADDSUB          <= alu(5 downto 4);
  ALU_BIT             <= alu(3 downto 2);
  ALU_SEL             <= alu(1 downto 0);

  ZWE                 <= flags(2);
  DCWE                <= flags(1);
  CWE                 <= flags(0);
end rtl;
