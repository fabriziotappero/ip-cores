
--------------------------------------------------------------------------------
-- (c) 2011.. Hoffmann RF & DSP  opencores@hoffmann-hochfrequenz.de
-- V1.0 published under BSD license
--------------------------------------------------------------------------------
-- file name:      un_signed_sprt.vhd
-- tool version:   Modelsim 6.1, 6.5
-- description:    additional support routines for signed/unsigned
--                 conversions between real and signed / unsigned
--                 the frac_xxx routines assume the decimal point to the left
--                 so that the range is -0.999999 or 0.0   to +0.9999999
--                 Note that the bits have different weights for unsigned vs. signed
-- calls libs:     ieee standard
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package un_signed_sprt is 


  function signed2string       (s:   signed) return string;
  function unsigned2string     (u: unsigned) return string;
    
  function to_unsigned         (x: std_logic; proto: unsigned) return unsigned;
  function to_signed           (x: std_logic; proto:   signed) return   signed;
  
  function unsigned2real       (u: unsigned)  return real;
  function signed2real         (s: signed)    return real;
  function fract_unsigned2real (u: unsigned)  return real;
  function fract_signed2real   (s: signed)    return real;

  function fits_into_unsigned  (r: real; proto: unsigned) return boolean;
  function fits_into_signed    (r: real; proto:   signed) return boolean;

  function real2unsigned       (r: real; proto: unsigned) return unsigned; 
  function real2signed         (r: real; proto:   signed) return signed;
  function fract_real2unsigned (r: real; proto: unsigned) return unsigned;
  function fract_real2signed   (r: real; proto:   signed) return signed;

end un_signed_sprt;


package body un_signed_sprt is


function signed2string(s: signed) return string is
  variable x: string(1 to s'length);
begin
  for i in s'range loop
    if s(i) = '1' -- damn strong typing
    then
      x(i+1) := '1';
    elsif s(i) = '0'
    then
      x(i+1) := '0';
    else
      x(i+1) := 'X';  -- FIXME includes Z, weak values...
    end if;
  end loop;
  return x;
end;


function unsigned2string(u: unsigned) return string is
  variable x: string(1 to u'length);
begin
  for i in u'range loop
    if u(i) = '1'
    then
      x(i+1) := '1';
    elsif u(i) = '0'
    then
      x(i+1) := '0';
    else
      x(i+1) := 'X';
    end if;
  end loop;
  return x;
end;

-----------------------------------------------------------------------------------------------------------

-- blow up a standard_logic value to an entire singned or unsigned vector
-- proto is the variable that the function return value will be assigned to.
-- It is r/o and delivers only its bounds to the function.
-- (easier than extracting and passing two bounds)
-- Overloads functions of the same name but with different parameters.

function to_unsigned(x: std_logic; proto: unsigned) return unsigned is
  variable u: unsigned(proto'range);
begin
  for n in proto'range loop
    u(n) := x;
  end loop;
  return u;
end function;


function to_signed(x: std_logic; proto: signed) return signed is
  variable s: signed(proto'range);
begin
  for n in proto'range loop
    s(n) := x;
  end loop;
  return s;
end function;

-----------------------------------------------------------------------------------------------------------

-- unsigned-integer conversions are nice but limited to 32 bits in VHDL,
-- without the value 0x8000 0000
-- use reals instead for larger vectors. 
-- Beware that it might be impossible to be bit-accurate
-- but sometimes we only need bigger pseudo-analog vectors.

function unsigned2real (u: unsigned) return real is
	
	variable r, bit_value: real;

begin

   if u'length < 1 then
      assert false
          report "unsigned2real: input vector has null size, returning 0.0"
          severity WARNING;
      return 0.0;
    end if;

	r := 0.0;
	bit_value := 1.0 ** u'low;
	
	for i in u'low to u'high loop
		if u(i) = '1'
		then
			r := r + bit_value;
		elsif u(i) = '0'
		then
		  null;
		else
		  assert false
		  report "unsigned2real(): input vector contains non-01-bits, returning 0.0"
		  severity WARNING;
		  return 0.0;
		end if;
		bit_value := 2.0 * bit_value;
	end loop;
	
	return r;
end unsigned2real;



function signed2real (s: signed) return real is
	
	variable result, bit_value: real;

begin

   if s'length < 2 then   -- may be unneccessary
      assert false
          report "signed2real: input vector too short, returning 0.0"
          severity WARNING;
      return 0.0;
    end if;

	result := 0.0;
	bit_value := 1.0 ** s'low;
	
	for i in s'low to s'high-1 loop
		if s(i) = '1'
		then
			result := result + bit_value;
		elsif s(i) = '0'
		then
		  null;
		else
		  assert false
		  report "signed2real(): input vector contains non-01-bits, returning 0.0"
		  severity WARNING;
		  return 0.0; 
		end if;
		bit_value := 2.0 * bit_value;
	end loop;
	
  if s(s'high) = '1' 
  then 
    result := result - bit_value;  -- subtract sign bit again
    return result;
  elsif s(s'high) = '0'
  then 
    return result;
  else
    assert false
  		  report "signed2real(): sign bit is neither 0 nor 1, returning 0.0"
		  severity WARNING;
		  return 0.0;

  end if;
end signed2real;

-----------------------------------------------------------------------------------------------------------

function fract_signed2real(s: signed) return real is
begin
  return signed2real(s) / (2.0 ** (s'length-1));
end function fract_signed2real;


function fract_unsigned2real(u: unsigned) return real is
begin
  return unsigned2real(u) / (2.0 ** u'length);
end function fract_unsigned2real;

-----------------------------------------------------------------------------------------------------------

function fits_into_unsigned(r: real; proto: unsigned) return boolean is
begin
  return (r >=0.0) and (r < 2.0 ** proto'length); 
end;


-- for 8 bits, -128 to +127 would fit

function fits_into_signed(r: real; proto: signed) return boolean is
begin
  return (r >= -(2.0 ** (proto'length-1))) and (r < 2.0 ** (proto'length-1)); 
end;

------------------------------------------------------------------------------------------------------------

function real2unsigned(r: real; proto: unsigned) return unsigned is 
  variable u: unsigned(proto'range);
  variable e: integer;
  variable rr: real := r;   -- r is constant;
begin
  if not fits_into_unsigned(r, proto)
  then
    assert false 
    report "real2unsigned(): value does not fit into supplied unsigned "
         & real'image(r)
         & " vs. capacity: 0 to "
         & real'image((2.0 ** proto'length) -1.0)
    severity warning;
    u := to_unsigned('X', u);
  else
    -- extract the bits starting from the highest. 
    e := proto'length -1;
    for n in proto'range loop
      if rr >= 2.0 ** e
      then
        u(n) := '1';
        rr   := rr - 2.0 ** e;
      else
        u(n) := '0';
      end if;
      e := e - 1;
    end loop;
  end if;
  return u;
end function real2unsigned;


function real2signed(r: real; proto: signed) return signed is 
  variable s: signed(proto'range);
  variable e: integer;
  variable rr: real := r;   -- r is constant;
  variable neg: boolean;
begin
  neg := r < 0.0;
  rr  := abs(r);
  if not fits_into_signed(r, proto)
  then
    assert false 
    report "real2signed(): value does not fit into supplied signed "
         & real'image(rr)
         & " vs. capacity  -"
         & real'image(2.0 ** (proto'length-1))
         & " to +"
         & real'image((2.0 ** (proto'length-1)) -1.0)       
    severity warning;
    s := to_signed('X', s);
  else
    -- extract the bits starting from the highest.
    s(proto'high) := '0';
    e := proto'length -1;
    for n in proto'high downto proto'low loop
      if rr >= 2.0 ** e
      then
        s(n) := '1';
        rr   := rr - 2.0 ** e;
      else
        s(n) := '0';
      end if;
      e := e - 1;
    end loop;
  end if;
  if neg
    then s := -s;
  end if;
  return s;
end function real2signed;


-----------------------------------------------------------------------------------------------------------
-- may produce internal overflows for very long vectors

function fract_real2unsigned (r: real; proto: unsigned) return unsigned is
  variable rr: real;
  variable upper_bound: real;
begin
  upper_bound := (1.0 - 2.0** (-proto'length));
  if (r < 0.0 or r > upper_bound )
  then
    assert false
      report "fract_real2unsigned(): arg must be 0.0 .. "
           & real'image(upper_bound)
           & " but it is "
           & real'image(r)
      severity warning;
    return to_unsigned('X', proto);
  end if;
  
  rr := r * 2.0**proto'length;      -- use the non-fractional routine
  return real2unsigned(rr, proto);
  
end function fract_real2unsigned;



function fract_real2signed   (r: real; proto:   signed) return signed is
  variable rr: real;
begin
  if (r< -1.0) or (r> 1.0 - (2.0**(-proto'length)))
  then
    assert false
      report "fract_real2unsigned(): arg must be in interval -1.0 to "
           & real'image(1.0 - (2.0**(-proto'length)))  -- FIXME hi bound maybe off by epsilon??
           & " but it is "
           & real'image(r)
      severity warning;
    return to_signed('X', proto);
  end if;
  
  rr := r * 2.0**(proto'length-1); -- use the non-fractional routine
  return real2signed(rr, proto);
    
end function fract_real2signed;

end package body un_signed_sprt;
