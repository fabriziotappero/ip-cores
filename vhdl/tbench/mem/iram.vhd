-----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.


-------------------------------------------------------------------------------
-- File name    : iram.vhd
-- Title        : Ram
-- project      : LEON
-- Library      : IEEE
-- Author(s)    : Jiri Gaisler
-- Purpose      : Ram model which reads data from file
--
-------------------------------------------------------------------------------
-- Modification history :
-------------------------------------------------------------------------------
-- Version No : | Author | Mod. Date : | Changes made :
-------------------------------------------------------------------------------
-- v 1.0        |  JG    | 97-05-17    | first version
--.............................................................................
-------------------------------------------------------------------------------
-- Copyright ESA/ESTEC
-------------------------------------------------------------------------------
---------|---------|---------|---------|---------|---------|---------|--------|

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_arith.all;
   use ieee.std_logic_unsigned.conv_integer;
   use std.textio.all;
   use work.leon_iface.all;
   use work.macro.all;

entity IRAM is
      generic (index : integer := 0;		-- Byte lane (0 - 3)
	       Abits: Positive := 10;		-- Default 10 address bits (1 Kbyte)
	       Echk : integer := 0;		-- Generate EDAC checksum
	       tacc : integer := 10;		-- access time (ns)
	       fname : string := "soft/tbenchsoft/ram.dat");	-- File to read from
      port (  
	A : in std_logic_vector;
        D : inout std_logic_vector(7 downto 0);
        CE1 : in std_logic;
        WE : in std_logic;
        OE : in std_logic
); end IRAM;     


architecture BEHAVIORAL of IRAM is

  subtype BYTE is std_logic_vector(7 downto 0);
  type MEM is array(0 to ((2**Abits)-1)) of BYTE;
  signal DINT,DI,DO : BYTE;

  constant ahigh : integer := abits - 1;
  signal wrpre : std_logic;

  function Vpar(vec : std_logic_vector) return std_logic is
  variable par : std_logic := '1';
  begin
    for i in vec'range loop	--'
      par := par xor vec(i);
    end loop;
    return par;
  end;

  procedure CHAR2QUADBITS(C: character; RESULT: out bit_vector(3 downto 0);
            GOOD: out boolean; ISSUE_ERROR: in boolean) is
  begin
    case C is
    when '0' => RESULT :=  x"0"; GOOD := true;
    when '1' => RESULT :=  x"1"; GOOD := true;
    when '2' => RESULT :=  X"2"; GOOD := true;
    when '3' => RESULT :=  X"3"; GOOD := true;
    when '4' => RESULT :=  X"4"; GOOD := true;
    when '5' => RESULT :=  X"5"; GOOD := true;
    when '6' => RESULT :=  X"6"; GOOD := true;
    when '7' => RESULT :=  X"7"; GOOD := true;
    when '8' => RESULT :=  X"8"; GOOD := true;
    when '9' => RESULT :=  X"9"; GOOD := true;
    when 'A' => RESULT :=  X"A"; GOOD := true;
    when 'B' => RESULT :=  X"B"; GOOD := true;
    when 'C' => RESULT :=  X"C"; GOOD := true;
    when 'D' => RESULT :=  X"D"; GOOD := true;
    when 'E' => RESULT :=  X"E"; GOOD := true;
    when 'F' => RESULT :=  X"F"; GOOD := true;

    when 'a' => RESULT :=  X"A"; GOOD := true;
    when 'b' => RESULT :=  X"B"; GOOD := true;
    when 'c' => RESULT :=  X"C"; GOOD := true;
    when 'd' => RESULT :=  X"D"; GOOD := true;
    when 'e' => RESULT :=  X"E"; GOOD := true;
    when 'f' => RESULT :=  X"F"; GOOD := true;
    when others =>
      if ISSUE_ERROR then
        assert false report 
	  "HREAD Error: Read a '" & C & "', expected a Hex character (0-F).";
      end if;
      GOOD := false;
    end case;
  end;

  procedure HREAD(L:inout line; VALUE:out bit_vector)  is
                variable OK: boolean;
                variable C:  character;
                constant NE: integer := VALUE'length/4;	--'
                variable BV: bit_vector(0 to VALUE'length-1);	--'
                variable S:  string(1 to NE-1);
  begin
    if VALUE'length mod 4 /= 0 then	--'
      assert false report
        "HREAD Error: Trying to read vector " &
        "with an odd (non multiple of 4) length";
      return;
    end if;
 
    loop                                    -- skip white space
      read(L,C);
      exit when ((C /= ' ') and (C /= CR) and (C /= HT));
    end loop;
 
    CHAR2QUADBITS(C, BV(0 to 3), OK, false);
    if not OK then
      return;
    end if;
 
    read(L, S, OK);
--    if not OK then
--      assert false report "HREAD Error: Failed to read the STRING";
--      return;
--    end if;
 
    for I in 1 to NE-1 loop
      CHAR2QUADBITS(S(I), BV(4*I to 4*I+3), OK, false);
      if not OK then
        return;
      end if;
    end loop;
    VALUE := BV;
  end HREAD;

  procedure HREAD(L:inout line; VALUE:out std_ulogic_vector) is
    variable TMP: bit_vector(VALUE'length-1 downto 0);	--'
  begin
    HREAD(L, TMP);
    VALUE := TO_X01(TMP);
  end HREAD;

  procedure HREAD(L:inout line; VALUE:out std_logic_vector) is
    variable TMP: std_ulogic_vector(VALUE'length-1 downto 0);	--'
  begin
    HREAD(L, TMP);
    VALUE := std_logic_vector(TMP);
  end HREAD;

  function ishex(c:character) return boolean is
  variable tmp : bit_vector(3 downto 0);
  variable OK : boolean;
  begin
    CHAR2QUADBITS(C, tmp, OK, false);
    return OK;
  end ishex;
 

begin

  RAM : process(CE1,WE,DI,A,OE,D)
  variable MEMA : MEM;
  variable L1,L2 : line;
  variable FIRST : boolean := true;
  variable LEN : integer := 0;
  variable LEN2 : integer := 0;
  variable ADR : std_logic_vector(19 downto 0);
  variable ADR2 : std_logic_vector(15 downto 0);
  variable ADR3 : std_logic_vector(31 downto 0);
  variable BUF : std_logic_vector(31 downto 0);
  variable CH : character;
  variable ai : integer;
  file TCF : text is in fname;
  begin
    if FIRST then

      L1:= new string'("");	--'
      while not endfile(TCF) loop
        readline(TCF,L1);
        if (L1'length /= 0) then	--'
          while (not (L1'length=0)) and (L1(L1'left) = ' ') loop
            std.textio.read(L1,CH);
          end loop;

          if L1'length > 0 then	--'
            if not (L1'length=0)and ishex(L1(L1'left)) and ishex(L1(L1'left+1)) 	--'
	    then
	      if (L1(L1'left+8) = ' ') then	--'
                HREAD(L1,ADR3);	-- read address
		adr := adr3(19 downto 0);
	      elsif (L1(L1'left+4) = ' ') then	--'
                HREAD(L1,ADR2);	-- read address
		adr := "0000" & adr2;
	      else
                HREAD(L1,ADR);	-- read address
	      end if;
	      if Echk = 4 then
	        len := conv_integer(adr(ahigh+1 downto 1));
	      elsif Echk > 1 then
	        len := conv_integer(adr(ahigh downto 0));
	        adr := "000000" &  adr(15 downto 2);
		adr(ahigh downto ahigh-1) := "11";
	        len2 := conv_integer(adr(ahigh downto 0));
	      else
	        len := conv_integer(adr(ahigh+2 downto 2));
	      end if;
 	      for i in 0 to 3 loop
                HREAD(L1,BUF);
	 	case Echk is
		when 0 =>
                  MEMA(LEN+i) := BUF((31-index*8) downto (24-index*8));

		when 2 =>
                  MEMA(LEN+(i*4))   := BUF(31 downto 24);
                  MEMA(LEN+(i*4)+1) := BUF(23 downto 16);
                  MEMA(LEN+(i*4)+2) := BUF(15 downto 8);
                  MEMA(LEN+(i*4)+3) := BUF(7 downto 0);

		when 4 =>
                  MEMA(LEN+i*2) := BUF((31-index*8) downto (24-index*8));
                  MEMA(LEN+i*2+1) := BUF((15-index*8) downto (8-index*8));
		when others => null;
		end case;
	      end loop;
            end if;
          end if;
        end if;
      end loop;

      FIRST := false;

    else
      if (TO_X01(not CE1) = '1') then
        if not is_x(a) then ai := conv_integer(A); else ai := 0; end if;
        dint <= mema(ai);
      end if;
      if (TO_X01(CE1 or WE) = '1') then
        if wrpre = '1' then
          mema(ai) := std_logic_vector(DI);
        end if;
      end if;
    end if;
    wrpre <= TO_X01((not CE1) and (not WE));
    DI <= D;
  end process;
 
  BUFS : process(CE1,WE,DINT,OE)
  variable DRIVEB : std_logic;
  begin
    DRIVEB := TO_X01((not CE1) and (not OE) and WE);
    case DRIVEB is
      when '1' => D <= DINT after tacc * 1 ns;
      when '0' => D <= "ZZZZZZZZ" after 5 ns;
      when others => D <= "XXXXXXXX";
    end case;
  end process;

end BEHAVIORAL;
