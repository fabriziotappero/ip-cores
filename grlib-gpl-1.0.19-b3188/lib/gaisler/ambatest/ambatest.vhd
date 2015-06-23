------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	ambatest
-- File:	ambatest.vhd
-- Author:	Alf Vaerneus
-- Description:	Test package for emulators
------------------------------------------------------------------------------

-- pragma translate_off
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library gaisler;
use grlib.devices.all;
use grlib.stdlib.all;
library std;
use std.textio.all;

package ambatest is

function printhex(value : std_logic_vector; len : integer) return string;
function conv_std_logic_vector(value : string; len : integer) return std_logic_vector;
function trimlen(str : string) return integer;
procedure printf(str : string; timestamp : boolean := false);
procedure printf(str : string; vari : integer; timestamp : boolean := false);
procedure printf(str : string; vari : std_logic_vector; timestamp : boolean := false);
procedure printf(str : string; vari : string; timestamp : boolean := false);
procedure compfiles(file1 : string(18 downto 1); file2 : string(18 downto 1); format : integer);
procedure compfiles(file1 : string(18 downto 1); file2 : string(18 downto 1); format : integer;  printlvl : integer; err : out boolean);

type command_type is (RD_SINGLE,
                      RD_INCR,
                      RD_WRAP4,
                      RD_INCR4,
                      RD_WRAP8,
                      RD_INCR8,
                      RD_WRAP16,
                      RD_INCR16,
                      WR_SINGLE,
                      WR_INCR,
                      WR_WRAP4,
                      WR_INCR4,
                      WR_WRAP8,
                      WR_INCR8,
                      WR_WRAP16,
                      WR_INCR16,
                      M_READ,
                      M_READ_LINE,
                      M_READ_MULT,
                      M_WRITE,
                      M_WRITE_INV,
                      C_READ,
                      C_WRITE,
                      I_READ,
                      I_WRITE
                      );

constant MAX_NO_TB : integer := 20;

type tb_in_type is record
  address   : std_logic_vector(31 downto 0);
  data      : std_logic_vector(31 downto 0);
  start     : std_logic;
  command   : command_type;
  no_words  : natural;
  userfile  : boolean;
  usewfile  : boolean;
  rfile     : string(18 downto 1);
  wfile     : string(18 downto 1);
end record;

type tbi_array_type is array(0 to MAX_NO_TB) of tb_in_type;

type status_type is (OK, ERR, TIMEOUT, RETRY);
type tb_out_type is record
  data      : std_logic_vector(31 downto 0);
  ready     : std_logic;
  status    : status_type;
end record;

type tbo_array_type is array(0 to MAX_NO_TB) of tb_out_type;

type ctrl_type is record
  address   : std_logic_vector(31 downto 0);
  data      : std_logic_vector(31 downto 0);
  status    : status_type;
  curword   : natural;
  no_words  : natural;
  userfile  : boolean;
  usewfile  : boolean;
  rfile     : string(18 downto 1);
  wfile     : string(18 downto 1);
end record;

constant tb_in_init : tb_in_type := (
  address => (others => '0'),
  data => (others => '0'),
  start => '0',
  command => RD_SINGLE,
  no_words => 0,
  userfile => false,
  usewfile => false,
  rfile => "                  ",
  wfile => "                  ");

constant ctrl_init : ctrl_type := (
  address => (others => '0'),
  data => (others => '0'),
  status => OK,
  curword => 0,
  no_words => 1,
  userfile => false,
  usewfile => false,
  rfile => "                  ",
  wfile => "                  ");

constant AHB_IDLE : ahb_mst_out_type := (
  hbusreq => '0',
  hlock => '0',
  htrans => HTRANS_IDLE,
  haddr => (others => '0'),
  hwrite => '0',
  hsize => HSIZE_WORD,
  hburst => HBURST_SINGLE,
  hprot => (others => '0'),
  hwdata => (others => '0'),
  hirq => (others => '0'),
  hconfig => (others => zero32),
  hindex => 0
  );

constant READ_SINGLE : ahb_mst_out_type := (
  hbusreq => '0',
  hlock => '0',
  htrans => HTRANS_NONSEQ,
  haddr => (others => '0'),
  hwrite => '0',
  hsize => HSIZE_WORD,
  hburst => HBURST_SINGLE,
  hprot => (others => '0'),
  hwdata => (others => '0'),
  hirq => (others => '0'),
  hconfig => (others => zero32),
  hindex => 0
  );

constant READ_INCR : ahb_mst_out_type := (
  hbusreq => '0',
  hlock => '0',
  htrans => HTRANS_NONSEQ,
  haddr => (others => '0'),
  hwrite => '0',
  hsize => HSIZE_WORD,
  hburst => HBURST_INCR,
  hprot => (others => '0'),
  hwdata => (others => '0'),
  hirq => (others => '0'),
  hconfig => (others => zero32),
  hindex => 0
  );

constant WRITE_SINGLE : ahb_mst_out_type := (
  hbusreq => '0',
  hlock => '0',
  htrans => HTRANS_NONSEQ,
  haddr => (others => '0'),
  hwrite => '1',
  hsize => HSIZE_WORD,
  hburst => HBURST_SINGLE,
  hprot => (others => '0'),
  hwdata => (others => '0'),
  hirq => (others => '0'),
  hconfig => (others => zero32),
  hindex => 0
  );

constant WRITE_INCR : ahb_mst_out_type := (
  hbusreq => '0',
  hlock => '0',
  htrans => HTRANS_NONSEQ,
  haddr => (others => '0'),
  hwrite => '1',
  hsize => HSIZE_WORD,
  hburst => HBURST_INCR,
  hprot => (others => '0'),
  hwdata => (others => '0'),
  hirq => (others => '0'),
  hconfig => (others => zero32),
  hindex => 0
  );


-- AHB Master Emulator
component ahbmst_em
  generic(
    hindex    : integer := 0;
    timeoutc  : integer := 100;
    dbglevel  : integer := 2
  );
  port(
    rst       : in std_logic;
    clk       : in std_logic;
    -- AMBA signals
    ahbmi     : in  ahb_mst_in_type;
    ahbmo     : out ahb_mst_out_type;
    -- TB signals
    tbi       : in  tb_in_type;
    tbo       : out  tb_out_type
  );
end component;

-- AHB Slave Emulator
component ahbslv_em
  generic(
    hindex    : integer := 0;
    abits     : integer := 10;
    waitcycles : integer := 2;
    retries   : integer := 0;
    memaddr   : integer := 16#E00#;
    memmask   : integer := 16#FFF#;
    ioaddr    : integer := 16#000#;
    timeoutc   : integer := 100;
    dbglevel  : integer := 2
  );
  port(
    rst       : in std_logic;
    clk       : in std_logic;
    -- AMBA signals
    ahbsi     : in  ahb_slv_in_type;
    ahbso     : out ahb_slv_out_type;
    -- TB signals
    tbi       : in  tb_in_type;
    tbo       : out  tb_out_type
  );
end component;

end ambatest;


package body ambatest is

function printhex( value : std_logic_vector; len : integer) return string is
 variable str1, str2 : string (1 to 8);
 variable stmp  : string (8 downto 1);
 variable x : std_logic_vector(31 downto 0);
 begin
     x:= (others => '0');
     x(len-1 downto 0) := value;
  case len is
  when 4 | 8 | 12 | 16 | 20 | 24 | 28 | 32 =>
    for i in 0 to (len/4)-1 loop
      case conv_integer(x(((len-1)-(i*4)) downto ((len-1)-(i*4)-3))) is
        when 0 => stmp(i+1) := '0';
        when 1 => stmp(i+1) := '1';
        when 2 => stmp(i+1) := '2';
        when 3 => stmp(i+1) := '3';
        when 4 => stmp(i+1) := '4';
        when 5 => stmp(i+1) := '5';
        when 6 => stmp(i+1) := '6';
        when 7 => stmp(i+1) := '7';
        when 8 => stmp(i+1) := '8';
        when 9 => stmp(i+1) := '9';
        when 10 => stmp(i+1) := 'A';
        when 11 => stmp(i+1) := 'B';
        when 12 => stmp(i+1) := 'C';
        when 13 => stmp(i+1) := 'D';
        when 14 => stmp(i+1) := 'E';
        when 15 => stmp(i+1) := 'F';
        when others => stmp(i+1) := 'X';
      end case;
    end loop;
  when others => stmp := (others => ' ');
  end case;


  str2(1 to 8) := stmp(8 downto 1);
  for i in 1 to 8 loop
    str1(i) := str2(9-i);
  end loop;

  return(str1);
end printhex;

function to_char( x : INTEGER range 0 to 15) return character is
 begin
  case x is
    when 0 => return('0');
    when 1 => return('1');
    when 2 => return('2');
    when 3 => return('3');
    when 4 => return('4');
    when 5 => return('5');
    when 6 => return('6');
    when 7 => return('7');
    when 8 => return('8');
    when 9 => return('9');
    when 10 => return('A');
    when 11 => return('B');
    when 12 => return('C');
    when 13 => return('D');
    when 14 => return('E');
    when 15 => return('F');
  end case;
end to_char;

function conv_std_logic_vector(value : string; len : integer) return std_logic_vector is
  variable tmpvect : std_logic_vector(31 downto 0);
  variable str1,str2 : string(1 to 8);
  begin
    str1 := value;
    for i in 1 to (len/4) loop
      str2(i) := str1(((len/4)+1)-i);
    end loop;
    case len is
    when 4 | 8 | 12 | 16 | 20 | 24 | 28 | 32 =>
      for i in 0 to 7 loop
        case str2(i+1) is
        when '0' => tmpvect(((i*4)+3) downto (i*4)) := "0000";
        when '1' => tmpvect(((i*4)+3) downto (i*4)) := "0001";
        when '2' => tmpvect(((i*4)+3) downto (i*4)) := "0010";
        when '3' => tmpvect(((i*4)+3) downto (i*4)) := "0011";
        when '4' => tmpvect(((i*4)+3) downto (i*4)) := "0100";
        when '5' => tmpvect(((i*4)+3) downto (i*4)) := "0101";
        when '6' => tmpvect(((i*4)+3) downto (i*4)) := "0110";
        when '7' => tmpvect(((i*4)+3) downto (i*4)) := "0111";
        when '8' => tmpvect(((i*4)+3) downto (i*4)) := "1000";
        when '9' => tmpvect(((i*4)+3) downto (i*4)) := "1001";
        when 'A' => tmpvect(((i*4)+3) downto (i*4)) := "1010";
        when 'B' => tmpvect(((i*4)+3) downto (i*4)) := "1011";
        when 'C' => tmpvect(((i*4)+3) downto (i*4)) := "1100";
        when 'D' => tmpvect(((i*4)+3) downto (i*4)) := "1101";
        when 'E' => tmpvect(((i*4)+3) downto (i*4)) := "1110";
        when 'F' => tmpvect(((i*4)+3) downto (i*4)) := "1111";
        when 'a' => tmpvect(((i*4)+3) downto (i*4)) := "1010";
        when 'b' => tmpvect(((i*4)+3) downto (i*4)) := "1011";
        when 'c' => tmpvect(((i*4)+3) downto (i*4)) := "1100";
        when 'd' => tmpvect(((i*4)+3) downto (i*4)) := "1101";
        when 'e' => tmpvect(((i*4)+3) downto (i*4)) := "1110";
        when 'f' => tmpvect(((i*4)+3) downto (i*4)) := "1111";        
        when others => tmpvect(((i*4)+3) downto (i*4)) := "0000";
        end case;
      end loop;
    when others => tmpvect := (others => '0');
    end case;

    return(tmpvect(len-1 downto 0));
end conv_std_logic_vector;

procedure printf(str : string; timestamp : boolean := false) is
  variable lenstr,offset,i : integer;
  variable rstr : string(1 to 128);
  variable L : line;
  begin
    lenstr := str'length; offset := 1; i := 1;
    while i <= lenstr loop
      rstr(offset) := str(i); offset := offset+1; i := i+1;
    end loop;

    rstr(offset+1) := NUL;
    if timestamp then
        write(L, rstr & " : ");
        write(L, Now, Left, 15);
    else
        write(L,rstr);
    end if;
    writeline(output,L);

end procedure;

procedure printf(str : string; vari : integer; timestamp : boolean := false) is
  variable lenstr,offset,i,j,x,y,z : integer;
  variable rstr : string(1 to 128);
  variable tmpstr : string(1 to 8);
  variable remzer : boolean;
  variable L : line;
  begin
    lenstr := str'length; offset := 1; i := 1; x := vari;
    while i <= lenstr loop
      if str(i) = '%' then
        if vari = 0 then
          rstr(offset) := '0'; offset := offset+1;
        else
          if vari = 0 then tmpstr := (others => '0');
          else
            j := 8;
            l2: while true loop
              j := j-1;
              exit l2 when j = 0;
              y := x/10;
              z := x - y*10;
              x := y;
              tmpstr(j) := to_char(z);
            end loop;
            if x>0 then printf("Value is out of range"); end if;
          end if;
--          tmpstr := printhex(conv_std_logic_vector(vari,32),32);
          remzer := false;
          for k in 1 to 8 loop
            if (tmpstr(k) /= '0' or remzer = true) then
              rstr(offset) := tmpstr(k); remzer := true; offset := offset+1;
            end if;
          end loop;
        end if;
        i := i+2;
      else
        rstr(offset) := str(i); offset := offset+1; i := i+1;
      end if;
    end loop;

    rstr(offset+1) := NUL;
    if timestamp then
         write(L, rstr & " : ");
         write(L, Now, Left, 15);
    else
        write(L,rstr);
    end if;
    writeline(output,L);

end procedure;

procedure printf(
  str : string;
  vari : std_logic_vector;
  timestamp : boolean := false) is
    
  constant zero32 : std_logic_vector(31 downto 0) := (others => '0');
  variable lenstr,lenvct,offset,i : integer;
  variable rstr : string(1 to 128);
  variable tmpstr : string(1 to 8);
  variable L : line;
  begin
    lenstr := str'length; offset := 1;
    lenvct := vari'length; i := 1;
    while i <= lenstr loop
      if str(i) = '%' then
        if vari = zero32(lenvct-1 downto 0) then
          rstr(offset) := '0'; offset := offset+1;
        else
          tmpstr := printhex(vari,lenvct);
          for j in 1 to 8 loop
              rstr(offset) := tmpstr(j); offset := offset+1;
          end loop;
        end if;
        i := i+2;
      else
        rstr(offset) := str(i); offset := offset+1; i := i+1;
      end if;
    end loop;

    rstr(offset+1) := NUL;
    if timestamp then
        write(L, rstr & " : ");
        write(L, Now, Left, 15);
    else
        write(L,rstr);
    end if;
    writeline(output,L);

end procedure;

function trimlen(str : string) return integer is
  variable lenstr,i : integer;
  begin
    lenstr := str'length; i := 1;
    while str(lenstr) /= ' ' loop
      i := i+1 ; lenstr := lenstr-1;
    end loop;
    return(lenstr+1);
end function;

procedure printf(
  str : string;
  vari : string;
  timestamp : boolean := false) is
  variable lenstr,lenvct,offset,i : integer;
  variable rstr : string(1 to 128);
  variable L : line;
  begin
    lenstr := str'length; offset := 1;
    lenvct := vari'length; i := 1;
    while i <= lenstr loop
      if str(i) = '%' then
        for j in 1 to lenvct loop
            rstr(offset) := vari(j); offset := offset+1;
        end loop;
        i := i+2;
      else
        rstr(offset) := str(i); offset := offset+1; i := i+1;
      end if;
    end loop;

    rstr(offset+1) := NUL;
     if timestamp then
         write(L, rstr & " : ");
         write(L, Now, Left, 15);
    else
        write(L,rstr);
    end if;
    writeline(output,L);

end procedure;

procedure compfiles(
  file1 : string(18 downto 1);
  file2 : string(18 downto 1);
  format : integer) is
  file comp1, comp2 : text;
  variable L1, L2 : line;
  variable datahex1, datahex2 : string(1 to 8);
  variable dataint1, dataint2, pos, errs : integer;
  begin

    pos := 0; errs := 0;
    file_open(comp1, external_name => file1(18 downto trimlen(file1)), open_kind => read_mode);
    file_open(comp2, external_name => file2(18 downto trimlen(file2)), open_kind => read_mode);
    readline(comp1,L1);
    readline(comp2,L2);
    pos := pos+1;
    if format = 0 then
      read(L1,dataint1);
      read(L2,dataint2);
      if dataint1 /= dataint2 then
        errs := errs+1;
        printf("Comparision error at pos. %d",pos);
        printf("Expected data: %d",dataint1);
        printf("Compared data: %d",dataint2);
      end if;
    elsif format = 1 then
      read(L1,datahex1);
      read(L2,datahex2);
      if conv_std_logic_vector(datahex1,32) /= conv_std_logic_vector(datahex2,32) then
        errs := errs+1;
        printf("Comparision error at pos. %d",pos);
        printf("Expected data: %x",datahex1);
        printf("Compared data: %x",datahex2);
      end if;
    end if;
    while not (endfile(comp1) or endfile(comp2)) loop
      readline(comp1,L1);
      readline(comp2,L2);
      pos := pos+1;
      if format = 0 then
        read(L1,dataint1);
        read(L2,dataint2);
        if dataint1 /= dataint2 then
          errs := errs+1;
          printf("Comparision error at pos. %d",pos);
          printf("Expected data: %d",dataint1);
          printf("Compared data: %d",dataint2);
        end if;
      elsif format = 1 then
        read(L1,datahex1);
        read(L2,datahex2);
        if conv_std_logic_vector(datahex1,32) /= conv_std_logic_vector(datahex2,32) then
          errs := errs+1;
          printf("Comparision error at pos. %d",pos);
          printf("Expected data: %x",datahex1);
          printf("Compared data: %x",datahex2);
        end if;
      end if;
    end loop;
    if endfile(comp1) /= endfile(comp2) then
      printf("Compared files have different size!"); errs := errs+1;
    end if;
    file_close(comp1); file_close(comp2);
    if errs = 0 then
      printf("Comparision complete. No failure.");
    elsif errs = 1 then
      printf("Comparision complete. 1 failure.");
    else
      printf("Comparision complete. %d failures.",errs);
    end if;
end procedure;


procedure compfiles(file1 : string(18 downto 1); file2 : string(18 downto 1); format : integer; printlvl : integer; err : out boolean) is
  file comp1, comp2 : text;
  variable L1, L2 : line;
  variable datahex1, datahex2 : string(1 to 8);
  variable dataint1, dataint2, pos, errs : integer;
  begin

    pos := 0; errs := 0;
    file_open(comp1, external_name => file1(18 downto trimlen(file1)), open_kind => read_mode);
    file_open(comp2, external_name => file2(18 downto trimlen(file2)), open_kind => read_mode);
    readline(comp1,L1);
    readline(comp2,L2);
    pos := pos+1;
    if format = 0 then
      read(L1,dataint1);
      read(L2,dataint2);
      if dataint1 /= dataint2 then
        errs := errs+1;
        if printlvl /= 0 then
            printf("Comparision error at pos. %d",pos);
            printf("Expected data: %d",dataint1);
            printf("Compared data: %d",dataint2);
        end if;
      end if;
    elsif format = 1 then
      read(L1,datahex1);
      read(L2,datahex2);
      if conv_std_logic_vector(datahex1,32) /= conv_std_logic_vector(datahex2,32) then
        errs := errs+1;
        if printlvl /= 0 then
            printf("Comparision error at pos. %d",pos);
            printf("Expected data: %x",datahex1);
            printf("Compared data: %x",datahex2);
         end if;
      end if;
    end if;
    while not (endfile(comp1) or endfile(comp2)) loop
      readline(comp1,L1);
      readline(comp2,L2);
      pos := pos+1;
      if format = 0 then
        read(L1,dataint1);
        read(L2,dataint2);
        if dataint1 /= dataint2 then
          errs := errs+1;
          if printlvl /= 0 then
              printf("Comparision error at pos. %d",pos);
              printf("Expected data: %d",dataint1);
              printf("Compared data: %d",dataint2);
          end if;
        end if;
      elsif format = 1 then
        read(L1,datahex1);
        read(L2,datahex2);
        if conv_std_logic_vector(datahex1,32) /= conv_std_logic_vector(datahex2,32) then
          errs := errs+1;
          if printlvl /= 0 then
              printf("Comparision error at pos. %d",pos);
              printf("Expected data: %x",datahex1);
              printf("Compared data: %x",datahex2);
          end if;
        end if;
      end if;
    end loop;
    if endfile(comp1) /= endfile(comp2) then
        if printlvl /= 0 then
            printf("Compared files have different size!"); errs := errs+1;
        end if;
    end if;
    file_close(comp1); file_close(comp2);
    err := true;
    if errs = 0 then
      err := false;
      if printlvl >= 2 then
          printf("Comparision complete. No failure.");
      end if;
    elsif errs = 1 then
      if printlvl >= 1 then 
          printf("Comparision complete. 1 failure.");
      end if;
    else
      if printlvl >= 1 then
          printf("Comparision complete. %d failures.",errs);
      end if;
    end if;
end procedure;


end ambatest;
-- pragma translate_on

