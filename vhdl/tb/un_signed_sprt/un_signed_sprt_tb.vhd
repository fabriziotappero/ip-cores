
--------------------------------------------------------------------------------
-- (c) 2005.. Hoffmann RF & DSP  opencores@hoffmann-hochfrequenz.de
-- V1.0 published under BSD license
--------------------------------------------------------------------------------
-- file name:      un_signed_sprt_tb.vhd
-- tool version:   Modelsim 6.1, 6.5
-- description:    test bed for signed / unsigned support library
-- calls libs:     ieee standard
-- calls entities: 
--------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.un_signed_sprt.all;

entity un_signed_sprt_tb is 
begin 
end un_signed_sprt_tb;


architecture tb of un_signed_sprt_tb is


--------------------------------------------------------------------------------

procedure check_to_un_signed is
  variable s:   signed(7 downto 0);
  variable u: unsigned(7 downto 0);
  variable v: string(1 to 8);
begin
  report "Check_to_un_signed()";
  
  
  report "#### signed 0";      
  s := to_signed('0', s);
  if s = to_signed(0, 8)
  then
    report "passed";
  else
    report "s = <"  & signed2string(s) & ">,  should be 0";
  end if;
  
  report "#### signed X";      
  s := to_signed('X', s);
  if signed2string(s) = "XXXXXXXX" 
  then 
    report "passed";
  else
    report "s = <"  & signed2string(s) & ">,  should be XXXXXXXX";
  end if;
  
       
  report "#### signed -1";      
  s := to_signed('1', s);
  if  s = to_signed(-1, 8)
  then
    report "passed";
  else
    report "failed:  s 0 <" & signed2string(s) & ">, should be -1";
  end if;


  report "#### unsigned 0";      
  u := to_unsigned('0', u);
  if  u = to_unsigned(0, 8)
  then
    report "passed";
  else
    report "failed:  <" & unsigned2string(u) & ">, should be 0";
  end if;

  
  report "#### unsigned X";      
  u := to_unsigned('X', u);
  v := unsigned2string(u);
  if v = "XXXXXXXX" 
  then 
    report "passed";
  else
    report "u = <"  & unsigned2string(u) & ">,  should be XXXXXXXX";
  end if;
   
  
  report "#### unsigned 1";      
  u := to_unsigned('1', u);
  if u = to_unsigned(255, 8)
  then
    report "passed";
  else
    report  "<" & unsigned2string(u) & ">, should be 11111111";
  end if;
  
end procedure check_to_un_signed;


--------------------------------------------------------------------------------

procedure check_real2unsigned is
  variable u: unsigned (7 downto 0);
begin
  report "check_real2unsigned()";
  
  u := real2unsigned(0.0, u);
  assert to_integer(u) = 0;
  
  u := real2unsigned(255.0, u);
  assert to_integer(u) = 255;
  
  u := real2unsigned(256.0, u); -- must give warning
  assert to_integer(u) = 0;
  
  u := real2unsigned(-5.0, u);  -- must give warning
  assert to_integer(u) = 0;
end;


--------------------------------------------------------------------------------
procedure check_real2signed is
  variable s: signed (7 downto 0);
begin
  report "check_real2signed()";
  
  s := real2signed(0.0, s);
  assert to_integer(s) = 0;
  
  s := real2signed(7.0, s);
  assert to_integer(s) = 7;
  
  s := real2signed(127.0, s);
  assert to_integer(s) = 127;
  
  s := real2signed(-127.0, s);
  assert to_integer(s) = -127;
  
  s := real2signed(-128.0, s);  -- still must work
  assert to_integer(s) = -128;
  
  s := real2signed(128.0, s); -- must give warning
  assert to_integer(s) = 0;
  
  s := real2signed(-129.0, s);  -- must give warning
  assert to_integer(s) = 0;  
end;

--------------------------------------------------------------------------------

procedure check_unsigned2real is
  variable u: unsigned (7 downto 0);
begin
  report "check_unsigned2real";
  
  u := unsigned'("00000000");
  assert unsigned2real(u) = 0.0;
  
  u := unsigned'("00000100");
  assert unsigned2real(u) = 4.0;
  
  u := unsigned'("11111111");
  assert unsigned2real(u) = 255.0;
  
  u := unsigned'("0XXXXXXX");   -- must give warning
  assert unsigned2real(u) = 0.0;
 
  u := unsigned'("X0000000");   -- must give warning
  assert unsigned2real(u) = 0.0;

end;


--------------------------------------------------------------------------------
-- checking reals for equality is problematic b/c of precision

procedure check_signed2real is
  variable s: signed (7 downto 0);
  variable r: real;
begin
  report "check_signed2real()";
  
  s := signed'("00000000");
  assert signed2real(s) = 0.0;
  
  s := signed'("00000100");
  assert signed2real(s) = 4.0;
 
  s := signed'("11111011");
  r := signed2real(s);
  assert  r = -5.0;
   
  s := signed'("11111111");
  r := signed2real(s);
  assert r = -1.0;
  
  s := signed'("0XXXXXXX");   -- must give warning
  assert signed2real(s) = 0.0;
 
  s := signed'("X0000000");   -- must give warning
  assert signed2real(s) = 0.0;
  
end;

--------------------------------------------------------------------------------

procedure check_fract_unsigned2real is
  variable u:  unsigned (7 downto 0);
  variable u4: unsigned(3 downto 0);
  variable r:  real;
begin
  report "check_frac_unsigned2real()";
    
  u := unsigned'("00000000");  
  r := fract_unsigned2real(u);
  assert r = 0.0;
 
  u4 := unsigned'("0111"); 
  r := fract_unsigned2real(u4); 
  assert r = 1.0/4.0 + 1.0/8.0 + 1.0/16.0;  --  0.4375
  
  u := unsigned'("10000000");  
  r := fract_unsigned2real(u);
  assert r = 0.5;

  u4 := unsigned'("1111"); 
  r := fract_unsigned2real(u4);   
  assert r = 1.0/2.0 + 1.0/4.0 + 1.0/8.0 + 1.0/16.0;  -- 0.9375
 
 
 end;
 
--------------------------------------------------------------------------------

procedure check_fract_signed2real is
  variable s:  signed (7 downto 0);
  variable s4: signed (3 downto 0);
  variable r:  real;
begin
  report "check_frac_signed2real()";
    
  s := signed'("00000000");  
  r := fract_signed2real(s);
  assert r = 0.0;
 
  s4 := signed'("0111"); 
  r := fract_signed2real(s4); 
  assert r = 1.0/2.0 + 1.0/4.0 + 1.0/8.0;
  
  s := signed'("10000000");  
  r := fract_signed2real(s);
  assert r = -1.0;

  s4 := signed'("1111"); 
  r := fract_signed2real(s4);   
  assert r = -0.125;

end;
--------------------------------------------------------------------------------
procedure check_fract_real2unsigned is
  variable u:  unsigned (7 downto 0);
  variable u4: unsigned(3 downto 0);
  variable r:  real;
begin
  report "check_frac_real2unsigned()";
  
  u := fract_real2unsigned(0.0, u);
  assert u = unsigned'("00000000");
  
  u4 := fract_real2unsigned(1.0/4.0 + 1.0/8.0 + 1.0/16.0, u4);  --  0.4375
  assert u4 = unsigned'("0111");
  
  u := fract_real2unsigned(0.5, u);
  assert u = unsigned'("10000000");
  
  u4 := fract_real2unsigned(1.0/2.0 + 1.0/4.0 + 1.0/8.0 + 1.0/16.0, u4);  -- 0.9375
  assert u4 = unsigned'("1111");
 
  u := fract_real2unsigned(1.5, u);   -- must produce a warning
 
  u := fract_real2unsigned(-0.5, u);  -- must produce a warning
 
     
end;


--------------------------------------------------------------------------------

procedure check_fract_real2signed is
  variable s:  signed (7 downto 0);
  variable s4: signed (3 downto 0);
  variable r:  real;
begin
  report "check_frac_real2signed()";  
  
  s := fract_real2signed(0.0, s);
  assert s = signed'("00000000");
  
  s4 := fract_real2signed(1.0/2.0 + 1.0/4.0 + 1.0/8.0, s4);
  assert s4 = signed'("0111");
  
  s := fract_real2signed(-1.0, s);
  assert s = signed'("10000000");
  
  s4 := fract_real2signed(-0.125, s4);
  assert s4 = signed'("1111"); 
  
  s  := fract_real2signed(-1.5, s);  -- must generate a warning
  
  s  := fract_real2signed(1.5, s);   -- must generate a warning
  
end;


--------------------------------------------------------------------------------

begin

p_c: process is 
begin
  check_to_un_signed;        -- ok
  check_real2unsigned;       -- ok
  check_real2signed;         -- ok
  check_unsigned2real;       -- ok
  check_signed2real;         -- ok
  check_fract_signed2real;   -- ok
  check_fract_unsigned2real; -- ok
  check_fract_real2unsigned; -- ok
  check_fract_real2signed;   -- ok
  wait;  -- for good
end process;

end architecture tb;
