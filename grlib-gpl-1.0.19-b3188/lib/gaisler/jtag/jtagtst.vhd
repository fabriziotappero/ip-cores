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
-- Package:     sim
-- File:        sim.vhd
-- Author:      Edvin Catovic - Gaisler Research
-- Description: JTAG debug link communication test 
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
library grlib;
use grlib.stdlib.all;
use grlib.stdio.all;
use grlib.amba.all;

package jtagtst is

  procedure clkj(tmsi, tdii : in std_ulogic; tdoo : out std_ulogic;
                 signal tck, tms, tdi : out std_ulogic;
                 signal tdo           : in std_ulogic;
                 cp                   : in integer);

  procedure shift(dr : in boolean; len : in integer;
                  din : in std_logic_vector; dout : out std_logic_vector;
                  signal tck, tms, tdi : out std_ulogic;
                  signal tdo           : in std_ulogic;
                  cp                   : in integer);                  

  procedure jtagcom(signal tdo           : in std_ulogic;
                    signal tck, tms, tdi : out std_ulogic;
                    cp, start, addr      : in integer;
                                                          -- cp - TCK clock period in ns
                                                          -- start - time in us when JTAG test
                                                          -- is started
                                                          -- addr - read/write operation destination address 
                    haltcpu          : in boolean);
  

end;  


package body jtagtst is

  procedure clkj(tmsi, tdii : in std_ulogic; tdoo : out std_ulogic;
                 signal tck, tms, tdi : out std_ulogic;
                 signal tdo           : in std_ulogic;
                 cp                   : in integer) is
  begin
    tdi <= tdii;
    tck <= '0'; tms <= tmsi;
    wait for 2 * cp * 1 ns;
    tck <= '1'; tdoo := tdo;
    wait for 2 * cp * 1 ns;
  end;        

  procedure shift(dr : in boolean; len : in integer;
                  din : in std_logic_vector; dout : out std_logic_vector;
                  signal tck, tms, tdi : out std_ulogic;
                  signal tdo           : in std_ulogic;
                  cp                   : in integer) is
    variable dc : std_ulogic;
  begin
    clkj('0', '-', dc, tck, tms, tdi, tdo, cp);
    clkj('1', '-', dc, tck, tms, tdi, tdo, cp);
    if (not dr) then clkj('1', '-', dc, tck, tms, tdi, tdo, cp); end if;
    clkj('0', '-', dc, tck, tms, tdi, tdo, cp);  -- capture
    clkj('0', '-', dc, tck, tms, tdi, tdo, cp);  -- shift (state)
    for i in 0 to len-2 loop
      clkj('0', din(i), dout(i), tck, tms, tdi, tdo, cp);  
    end loop;        
    clkj('1', din(len-1), dout(len-1), tck, tms, tdi, tdo, cp);  -- end shift, goto exit1
    clkj('1', '-', dc, tck, tms, tdi, tdo, cp);  -- update ir/dr
    clkj('0', '-', dc, tck, tms, tdi, tdo, cp);  -- run_test/idle                                                      
  end;

  procedure jwrite(addr, data           : in std_logic_vector;
                   signal tck, tms, tdi : out std_ulogic;
                   signal tdo           : in std_ulogic;
                  cp                    : in integer) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
    variable hsize : std_logic_vector(1 downto 0);        
  begin
    hsize := "10";
    wait for 10 * cp * 1 ns;
    shift(false, 6, B"010000", dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;
    tmp2 := '1' & hsize & addr;    
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, 6, B"110000", dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    tmp := '0' & data;
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- write data reg
  end;  

  procedure jread(addr                 : in  std_logic_vector;
                  data                 : out std_logic_vector;
                  signal tck, tms, tdi : out std_ulogic;
                  signal tdo           : in std_ulogic;
                  cp                   : in integer) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
    variable hsize : std_logic_vector(1 downto 0);            
  begin
    hsize := "10";    
    wait for 10 * cp * 1 ns;
    shift(false, 6, B"010000", dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;    
    tmp2 := '0' & hsize & addr;    
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, 6, B"110000", dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    tmp := (others => '0'); --tmp(32) := '1'; 
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
    data := dr(31 downto 0);
  end;

  subtype jword_type is std_logic_vector(31 downto 0);
  type jdata_vector_type is array (integer range <>) of jword_type;
  
  procedure jwritem(addr                 : in std_logic_vector;
                    data                 : in jdata_vector_type;
                    signal tck, tms, tdi : out std_ulogic;
                    signal tdo           : in std_ulogic;
                    cp                   : in integer) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
    variable hsize : std_logic_vector(1 downto 0);        
  begin
    hsize := "10";    
    wait for 10 * cp * 1 ns;
    shift(false, 6, B"010000", dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;
    tmp2 := '1' & hsize & addr;    
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, 6, B"110000", dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    for i in data'left to data'right-1 loop
      tmp := '1' & data(i);
      shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- write data reg
    end loop;
    tmp := '0' & data(data'right);
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- write data reg    
  end;  

  procedure jreadm(addr                 : in  std_logic_vector;
                   data                 : out jdata_vector_type;
                   signal tck, tms, tdi : out std_ulogic;
                   signal tdo           : in std_ulogic;
                   cp                   : in integer) is
    variable tmp : std_logic_vector(32 downto 0);
    variable tmp2 : std_logic_vector(34 downto 0);
    variable dr : std_logic_vector(32 downto 0);
    variable dr2 : std_logic_vector(34 downto 0);
    variable hsize : std_logic_vector(1 downto 0);            
  begin
    hsize := "10";    
    wait for 10 * cp * 1 ns;
    shift(false, 6, B"010000", dr, tck, tms, tdi, tdo, cp);  -- inst = addrreg
    wait for 5 * cp * 1 ns;    
    tmp2 := '0' & hsize & addr;    
    shift(true, 35, tmp2, dr2, tck, tms, tdi, tdo, cp); -- write add reg
    wait for 5 * cp * 1 ns;
    shift(false, 6, B"110000", dr, tck, tms, tdi, tdo, cp);  -- inst = datareg
    wait for 5 * cp * 1 ns;
    for i in data'left to data'right-1 loop
      tmp := (others => '0'); tmp(32) := '1'; 
      shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
      data(i) := dr(31 downto 0);
    end loop;
    tmp := (others => '0');
    shift(true, 33, tmp, dr, tck, tms, tdi, tdo, cp); -- read data reg
    data(data'right) := dr(31 downto 0);
  end;
  
procedure jtagcom(signal tdo : in std_ulogic;
                  signal tck, tms, tdi : out std_ulogic;
                  cp, start, addr  : in integer;
                  haltcpu          : in boolean) is
  variable dc : std_ulogic;
  variable dr : std_logic_vector(32 downto 0);
  variable tmp : std_logic_vector(32 downto 0);
  variable data : std_logic_vector(31 downto 0);
  variable datav : jdata_vector_type(0 to 3);
begin

  tck <= '0'; tms <= '0'; tdi <= '0';

  wait for start * 1 us;    
  print("AHB JTAG TEST");    
  for i in 1 to 5 loop     -- reset
    clkj('1', '0', dc, tck, tms, tdi, tdo, cp);
  end loop;        
  clkj('0', '-', dc, tck, tms, tdi, tdo, cp);

  --read IDCODE
  wait for 10 * cp * 1 ns;
  shift(true, 32, conv_std_logic_vector(0, 32), dr, tck, tms, tdi, tdo, cp);        
  print("JTAG TAP ID:" & tost(dr(31 downto 0)));
 
  wait for 10 * cp * 1 ns;
  shift(false, 6, conv_std_logic_vector(63, 6), dr, tck, tms, tdi, tdo, cp);    -- BYPASS

  --shift data through BYPASS reg
  shift(true, 32, conv_std_logic_vector(16#AAAA#, 16) & conv_std_logic_vector(16#AAAA#, 16), dr,
        tck, tms, tdi, tdo, cp);                

  -- put CPUs in debug mode
  if haltcpu then
      jwrite(X"90000000", X"00000004", tck, tms, tdi, tdo, cp);      
      jwrite(X"90000020", X"0000FFFF", tck, tms, tdi, tdo, cp);
    print("JTAG: Putting CPU in debug mode");
  end if;

  if false then
  jwrite(X"90000000", X"FFFFFFFF", tck, tms, tdi, tdo, cp);
  jread (X"90000000", data, tck, tms, tdi, tdo, cp);  
  print("JTAG WRITE " &  tost(X"90000000") & ":" & tost(X"FFFFFFFF"));
  print("JTAG READ  " &  tost(X"90000000") & ":" & tost(data));
  
  jwrite(X"90100034", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90100034", data, tck, tms, tdi, tdo, cp);
  print("JTAG WRITE " &  tost(X"90100034") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  " &  tost(X"90100034") & ":" & tost(data));  

  jwrite(X"90200058", X"ABCDEF01", tck, tms, tdi, tdo, cp);
  jread (X"90200058", data, tck, tms, tdi, tdo, cp);
  print("JTAG WRITE " &  tost(X"90200058") & ":" & tost(X"ABCDEF01"));
  print("JTAG READ  " &  tost(X"90200058") & ":" & tost(data));  
  
  jwrite(X"90300000", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90300000", data, tck, tms, tdi, tdo, cp);
  print("JTAG WRITE " &  tost(X"90300000") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  " &  tost(X"90300000") & ":" & tost(data));  
  
  jwrite(X"90400000", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90400000", data, tck, tms, tdi, tdo, cp);
  print("JTAG WRITE " &  tost(X"90400000") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  " &  tost(X"90400000") & ":" & tost(data));  

  jwrite(X"90400024", X"0000000C", tck, tms, tdi, tdo, cp);
  jwrite(X"90700100", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90700100", data, tck, tms, tdi, tdo, cp);
  print("JTAG WRITE ITAG :" &  tost(X"00000100") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  ITAG :" &  tost(X"00000100") & ":" & tost(data));  
    
  jwrite(X"90400024", X"0000000D", tck, tms, tdi, tdo, cp);
  jwrite(X"90700100", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90700100", data, tck, tms, tdi, tdo, cp);
  print("JTAG WRITE IDATA:" &  tost(X"00000100") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  IDATA:" &  tost(X"00000100") & ":" & tost(data));  
    
  jwrite(X"90400024", X"0000000E", tck, tms, tdi, tdo, cp);
  jwrite(X"90700100", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90700100", data, tck, tms, tdi, tdo, cp);
  print("JTAG WRITE DTAG :" &  tost(X"00000100") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  DTAG :" &  tost(X"00000100") & ":" & tost(data));  

  jwrite(X"90400024", X"0000000F", tck, tms, tdi, tdo, cp);  
  jwrite(X"90700100", X"ABCD1234", tck, tms, tdi, tdo, cp);
  jread (X"90700100", data, tck, tms, tdi, tdo, cp);
  print("JTAG WRITE DDATA:" &  tost(X"00000100") & ":" & tost(X"ABCD1234"));
  print("JTAG READ  DDATA:" &  tost(X"00000100") & ":" & tost(data));  
  end if;
    
  --jwritem(addr, (X"00000010", X"00000010", X"00000010", X"00000010"), tck, tms, tdi, tdo, cp);
  datav(0) := X"00000010"; datav(1) := X"00000011"; datav(2) := X"00000012";  datav(3) := X"00000013";
  jwritem(conv_std_logic_vector(addr, 32), datav, tck, tms, tdi, tdo, cp);  
  print("JTAG WRITE " &  tost(conv_std_logic_vector(addr,32)) & ":" & tost(X"00000010") & " " & tost(X"00000011") & " " & tost(X"00000012") & " " & tost(X"00000013"));

  datav := (others => (others => '0'));
  jreadm(conv_std_logic_vector(addr, 32), datav, tck, tms, tdi, tdo, cp);
  print("JTAG READ  " &  tost(conv_std_logic_vector(addr,32)) & ":" & tost(datav(0)) & " " & tost(datav(1)) & " "  & tost(datav(2)) & " " & tost(datav(3))); 
    
  assert (datav(0) = X"00000010") and (datav(1) = X"00000011") and (datav(2) = X"00000012") and (datav(3) = X"00000013")
    report "JTAG test failed" severity failure;
  
  assert false report "JTAG test passed, halting with failure." severity failure;

  end procedure;
    
end;

-- pragma translate_on

