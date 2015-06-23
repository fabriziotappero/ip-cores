library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fp_generic is

subtype fp_type is std_logic_vector(31 downto 0);
subtype fp_sign_type is std_logic;
subtype fp_exp_type is unsigned(7 downto 0);
subtype fp_mantissa_type is unsigned(23 downto 0);
subtype fp_long_mantissa_type is unsigned(47 downto 0);

subtype fp_error_type is std_logic_vector(5 downto 0);
constant FP_ERR_INVALID:fp_error_type:="000001";
constant FP_ERR_DIVBYZERO:fp_error_type:="000100";
constant FP_ERR_OVERFLOW:fp_error_type:="001000";
constant FP_ERR_UNDERFLOW:fp_error_type:="010000";
constant FP_ERR_INEXACT:fp_error_type:="100000";

function fp_sign(fp:fp_type) return fp_sign_type;
function fp_exp(fp:fp_type) return fp_exp_type;
function fp_mantissa(fp:fp_type) return fp_mantissa_type;

function fp_is_normal(fp:fp_type) return boolean;
function fp_is_zero(fp:fp_type) return boolean;
function fp_is_subnormal(fp:fp_type) return boolean;
function fp_is_infinite(fp:fp_type) return boolean;
function fp_is_nan(fp:fp_type) return boolean;
function fp_is_signalling(fp:fp_type) return boolean;
function fp_is_quiet(fp:fp_type) return boolean;
function fp_is_positive(fp:fp_type) return boolean;
function fp_is_negative(fp:fp_type) return boolean;

end package;

package body fp_generic is

function fp_sign(fp:fp_type) return fp_sign_type is
begin
	return fp(31);
end function fp_sign;

function fp_exp(fp:fp_type) return fp_exp_type is
begin
  return(resize((unsigned(fp) srl 23),8));
end function fp_exp;

function fp_mantissa(fp:fp_type) return fp_mantissa_type is
begin
	return(fp_mantissa_type("1"&fp(22 downto 0)));	-- Prepend implied '1' bit of IEEE-754 mantissa in order to return a 24 bit entity
end function fp_mantissa;

function fp_exp_is_min(exp:fp_exp_type) return boolean is
begin
  return (exp=0);
end function fp_exp_is_min;

function fp_exp_is_max(exp:fp_exp_type) return boolean is
begin
  return (exp=255);
end function fp_exp_is_max;

function fp_is_normal(fp:fp_type) return boolean is
	variable exp:fp_exp_type;
begin
	exp:=fp_exp(fp);

  return not fp_exp_is_min(exp) and not fp_exp_is_max(exp);
end function fp_is_normal;

function fp_is_zero(fp:fp_type) return boolean is
begin
	return (fp_exp(fp)=0) and (fp_mantissa(fp)(fp_mantissa_type'high-1 downto 0)=0);
end function fp_is_zero;

function fp_is_subnormal(fp:fp_type) return boolean is
begin
	return (fp_exp(fp)=0) and (fp_mantissa(fp)(fp_mantissa_type'high-1 downto 0)/=0);
end function fp_is_subnormal;

function fp_is_infinite(fp:fp_type) return boolean is
begin
	return (fp_exp_is_max(fp_exp(fp))) and (fp_mantissa(fp)(fp_mantissa_type'high-1 downto 0)=0);
end function fp_is_infinite;

function fp_is_nan(fp:fp_type) return boolean is
begin
	return (fp_exp_is_max(fp_exp(fp))) and (fp_mantissa(fp)(fp_mantissa_type'high-1 downto 0)/=0);
end function fp_is_nan;

function fp_is_signalling(fp:fp_type) return boolean is
begin
	return fp_is_nan(fp) and fp_mantissa(fp)(fp_mantissa_type'high-1)='0';
end function fp_is_signalling;

function fp_is_quiet(fp:fp_type) return boolean is
begin
	return fp_is_nan(fp) and fp_mantissa(fp)(fp_mantissa_type'high-1)='1';
end function fp_is_quiet;

function fp_is_positive(fp:fp_type) return boolean is
begin
  return (fp_sign(fp)='0');
end function fp_is_positive;

function fp_is_negative(fp:fp_type) return boolean is
begin
  return (fp_sign(fp)='1');
end function fp_is_negative;

end package body fp_generic;
