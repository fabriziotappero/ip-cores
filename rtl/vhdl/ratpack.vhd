--------------------------------------------------------------------------------
-- Filename: ratpack.vhd
-- Purpose : Rational arithmetic package
-- Author  : Nikolaos Kavvadias <nikolaos.kavvadias@gmail.com>
-- Date    : 21-Feb-2014
-- Version : 0.1.0
-- Revision: 0.0.0 (2009/07/25)
--           Initial version. Added the definition of a rational number, and the
--           implementation of the "+", "-", "*", "/" operators on reduced
--           rational numbers (i.e. relative primes), the gcd(x,y) and the
--           mediant operator.
--           0.0.1 (2009/07/28)
--           Added: numerator, denominator, abs, relational operators (>, <, >=,
--           <=, =, /=, changed the int2rat to to_rational, new version of
--           int2rat (casting an integer to a rational).
--           0.0.2 (2010/11/17)
--           Added an iterative version for the gcd computation (gcditer).
--           0.0.3 (2012/02/11)
--           Added max, min.
--           0.1.0 (2014/02/21)
--           Upgraded to version 0.1.0.
-- License : Copyright (C) 2009, 2010, 2011, 2012, 2013, 2014 by Nikolaos Kavvadias
--           This program is free software. You can redistribute it and/or 
--           modify it under the terms of the GNU Lesser General Public License, 
--           either version 3 of the License, or (at your option) any later 
--           version. See COPYING.
--
--------------------------------------------------------------------------------

package ratpack is 

  -- A rational number is defined by the pair (numerator, denominator) where 
  -- both numbers. -- are in the range [-16384, 16383].
  constant numer : INTEGER := 0; -- numerator
  constant denom : INTEGER := 1; -- denominator
  type rational is array (natural range numer to denom) of 
    integer; -- range -16384 to 16383;
  constant RAT_ZERO : rational := (0, 1);
  constant RAT_ONE  : rational := (1, 1);
  
  function to_rational (a, b : integer) return rational;
  function int2rat (a : integer) return rational;
  function numerator (a : rational) return integer;
  function denominator (a : rational) return integer;
  function "+" (a, b : rational) return rational;
  function "-" (a, b : rational) return rational;
  function "*" (a, b : rational) return rational;
  function "/" (a, b : rational) return rational;
  function "abs" (a : rational)  return rational;
  function max (a, b : rational) return rational;
  function min (a, b : rational) return rational;
  function ">" (a, b : rational) return boolean;
  function "<" (a, b : rational) return boolean;
  function ">=" (a, b : rational) return boolean;
  function "<=" (a, b : rational) return boolean;
  function "=" (a, b : rational) return boolean;
  function "/=" (a, b : rational) return boolean;
  function gcd (a, b : integer)  return integer;
  function gcditer (a, b : integer)  return integer;
  function mediant (a, b : rational) return rational;

end ratpack;


package body ratpack is

  function to_rational (a, b : integer) return rational is
    variable r : rational;
  begin
    r(numer) := a;
    r(denom) := b;
    return r;
  end to_rational;

  function int2rat (a : integer) return rational is
    variable r : rational;
  begin
    r(numer) := a;
    r(denom) := 1;
    return r;
  end int2rat;
  
  function numerator (a : rational) return integer is
    variable n : integer;
  begin
    n := a(numer);
    return n;
  end numerator;

  function denominator (a : rational) return integer is
    variable d : integer;
  begin
    d := a(denom);
    return d;
  end denominator;

  function "+" (a, b : rational) return rational is
    variable r : rational;
    variable tn, td : integer;
  begin
    tn := a(numer)*b(denom) + a(denom)*b(numer);
    td := a(denom) * b(denom);
    if ( gcd(abs(tn), abs(td)) > 0 ) then
      r(numer) := tn / gcd(abs(tn), abs(td));
      r(denom) := td / gcd(abs(tn), abs(td));
    else
      r(numer) := tn;
      r(denom) := td;
    end if;
    return r;
  end "+";

  function "-" (a, b : rational) return rational is
    variable r : rational;
    variable tn, td : integer;
  begin
    tn := a(numer)*b(denom) - a(denom)*b(numer);
    td := a(denom) * b(denom);
    if ( gcd(abs(tn), abs(td)) > 0 ) then
      r(numer) := tn / gcd(abs(tn), abs(td));
      r(denom) := td / gcd(abs(tn), abs(td));
    else
      r(numer) := tn;
      r(denom) := td;
    end if;
    return r;
  end "-";
    
  function "*" (a, b : rational) return rational is
    variable r : rational;
    variable tn, td : integer;
  begin
    tn := a(numer) * b(numer);
    td := a(denom) * b(denom);
    if ( gcd(abs(tn), abs(td)) > 0 ) then
      r(numer) := tn / gcd(abs(tn), abs(td));
      r(denom) := td / gcd(abs(tn), abs(td));
    else
      r(numer) := tn;
      r(denom) := td;
    end if;
    return r;
  end "*";

  function "/" (a, b : rational) return rational is
    variable r : rational;
    variable tn, td : integer;
  begin
    tn := a(numer) * b(denom);
    td := a(denom) * b(numer);
    if ( gcd(abs(tn), abs(td)) > 0 ) then
      r(numer) := tn / gcd(abs(tn), abs(td));
      r(denom) := td / gcd(abs(tn), abs(td));
    else
      r(numer) := tn;
      r(denom) := td;
    end if;
    return r;
  end "/";
    
  function "abs" (a : rational) return rational is
    variable ta, tb, y : integer;
    variable r : rational;
  begin
    ta := a(numer);
    tb := a(denom);
    if (ta < 0) then
      ta := - a(numer);
    end if;
    if (tb < 0) then
      tb := - a(denom);
    end if;
    r := to_rational(ta, tb);
    return r;
  end "abs";
  
  function max (a, b : rational) return rational is
    variable w, x, y, z : integer;
    variable t1, t2 : integer;
    variable maxv : rational;
  begin
    w := numerator(a);
    x := denominator(a);
    y := numerator(b);
    z := denominator(b);
    t1 := w*z;
    t2 := x*y;
    if (t1 > t2) then
      maxv := a;
    else
      maxv := b;
    end if; 
    return maxv;
  end max;
  
  function min (a, b : rational) return rational is
    variable w, x, y, z : integer;
    variable t1, t2 : integer;
    variable minv : rational;
  begin
    w := numerator(a);
    x := denominator(a);
    y := numerator(b);
    z := denominator(b);
    t1 := w*z;
    t2 := x*y;
    if (t1 < t2) then
      minv := a;
    else
      minv := b;
    end if; 
    return minv;
  end min;  
  
  function ">" (a, b : rational) return boolean is
    variable diff : rational := a - b;
  begin
    return (((diff(numer) > 0) and (diff(denom) > 0)) or 
            ((diff(numer) < 0) and (diff(denom) < 0)));
  end ">";
 
  function "<" (a, b : rational) return boolean is
    variable diff : rational := a - b;
  begin
    return (((diff(numer) > 0) and (diff(denom) < 0)) or 
            ((diff(numer) < 0) and (diff(denom) > 0)));
  end "<";
   
  function ">=" (a, b : rational) return boolean is
    variable diff : rational := a - b;
  begin
    return (((diff(numer) >= 0) and (diff(denom) > 0)) or 
            ((diff(numer) <= 0) and (diff(denom) < 0)));
  end ">=";

  function "<=" (a, b : rational) return boolean is
    variable diff : rational := a - b;
  begin
    return (((diff(numer) >= 0) and (diff(denom) < 0)) or 
            ((diff(numer) <= 0) and (diff(denom) > 0)));
  end "<=";

  function "=" (a, b : rational) return boolean is
    variable diff : rational := a - b;
  begin
    return (diff(numer) = 0);
  end "=";

  function "/=" (a, b : rational) return boolean is
    variable diff : rational := a - b;
  begin
    return (diff(numer) /= 0);
  end "/=";

  function gcd (a, b : integer) return integer is
  begin
    if a = 0 then
      return b;
    end if;
    if b = 0 then
      return a;
    end if;
    if (a > b) then
      return gcd(b, a mod b);
    else
      return gcd(a, b mod a);
    end if;
  end gcd;
   
  function gcditer (a, b : integer) return integer is
    variable x, y : integer;
  begin
    x := a;
    y := b;
    if ((x = 0) and (y = 0)) then
      return 0;
    end if;
    while (x /= y) loop
      if (x >= y) then
        x := x - y;
      else
        y := y - x;
      end if;
    end loop;
    return x;
  end gcditer;
   
  function mediant (a, b : rational) return rational is
    variable r : rational;
    variable tn, td : integer;
  begin
    tn := a(numer) + b(numer);
    td := a(denom) + b(denom);
    if ( gcditer(abs(tn), abs(td)) > 0 ) then
      r(numer) := tn / gcditer(abs(tn), abs(td));
      r(denom) := td / gcditer(abs(tn), abs(td));
    else
      r(numer) := tn;
      r(denom) := td;
    end if;
    return r;
  end mediant;

end ratpack;
