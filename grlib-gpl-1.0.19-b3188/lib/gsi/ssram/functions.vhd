-----------------------------------------------------------
-- VHDL file for FUNCTIONs used in verilog2vhdl files
-- DO NOT MODIFY THIS FILE
-- Author : S.O
-- Date   : March 14, 1995
-- Modification History --
-- 3/31/95 Added shift operations (S.O)
-- 4/6/95 Added arithmetic operations for std_logic_vectors (S.O)
-- 4/11/95 Added conversion functions
-- 10/5/95 added to_boolean conversions
-- 1/31/96 added funcs. for std_logic and std_logic
-- 2/28/96 added funcs. for TERNARY combinations
-- 4/18/96 added logical operations bet. std_logic_vector and integer/boolean
-- 7/9/96  modified all TERNARY functions with *ulogic* conditional
-----------------------------------------------------------

library ieee;
library GSI;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
library grlib;
use grlib.stdlib.all;

package FUNCTIONS is

-- TYPE used in conversion function
TYPE direction is (LITTLE_ENDIAN, BIG_ENDIAN);

TYPE hex_digit IS ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A',
		   'B', 'C', 'D', 'E', 'F', 'a', 'b', 'c', 'd', 'e', 'f');
TYPE hex_number IS array (POSITIVE range <>) OF hex_digit;

TYPE hexstdlogic IS ARRAY (hex_digit'LOW TO hex_digit'HIGH) of std_logic_vector(3 DOWNTO 0);

-- This conversion table would not accept X or Z.
-- To convert a hex number with X or Z use to_stdlogicvector(hex : STRING).
--CONSTANT hex_to_stdlogic : hexstdlogic := (x"0", x"1", x"2", x"3", x"4", x"5",
--	 x"6", x"7", x"8", x"9", x"A", x"B", x"C", x"D", x"E", x"F", x"A", x"B",
--       x"C", x"D", x"E", x"F");

-- Signals used for v2v

--SIGNAL v2v_std_logic : std_logic;
--SIGNAL v2v_sig_integer : integer;
--SIGNAL v2v_boolean : boolean;
--SIGNAL v2v_real : real;

-- FUNCTIONs for unary operations

FUNCTION U_AND(a : std_ulogic_vector) return std_ulogic;
FUNCTION U_AND(a : std_logic_vector) return std_logic;

FUNCTION U_NAND(a : std_ulogic_vector) return std_ulogic;
FUNCTION U_NAND(a : std_logic_vector) return std_logic;

FUNCTION U_OR(a : std_ulogic_vector) return std_ulogic;
FUNCTION U_OR(a : std_logic_vector) return std_logic;

FUNCTION U_NOR(a : std_ulogic_vector) return std_ulogic;
FUNCTION U_NOR(a : std_logic_vector) return std_logic;

FUNCTION U_XOR(a : std_ulogic_vector) return std_ulogic;
FUNCTION U_XOR(a : std_logic_vector) return std_logic;

FUNCTION U_XNOR(a : std_ulogic_vector) return std_ulogic;
FUNCTION U_XNOR(a : std_logic_vector) return std_logic;

-- FUNCTIONs for ternary operations
	
FUNCTION TERNARY(a,b,c : boolean) return boolean;
FUNCTION TERNARY(a : boolean; b,c : std_ulogic) return std_ulogic;
FUNCTION TERNARY(a : boolean; b,c : std_ulogic_vector) return std_ulogic_vector;
FUNCTION TERNARY(a : boolean; b,c : std_logic_vector) return std_logic_vector;
--pragma synthesis_off
FUNCTION TERNARY(a : boolean; b,c : real) return real;
FUNCTION TERNARY(a : boolean; b,c : time) return time;
--pragma synthesis_on

FUNCTION TERNARY(a,b,c : integer) return integer;
FUNCTION TERNARY(a : integer; b,c : std_ulogic) return std_ulogic;
FUNCTION TERNARY(a : integer; b,c : std_ulogic_vector) return std_ulogic_vector;
FUNCTION TERNARY(a : integer; b,c : std_logic_vector) return std_logic_vector;
--pragma synthesis_off
FUNCTION TERNARY(a : integer; b,c : real) return real;
FUNCTION TERNARY(a : integer; b,c : time) return time;
--pragma synthesis_on

FUNCTION TERNARY(a,b,c : std_ulogic) return std_ulogic;
FUNCTION TERNARY(a : std_ulogic; b,c : integer) return integer;
FUNCTION TERNARY(a : std_ulogic; b,c : std_ulogic_vector) return std_ulogic_vector;
FUNCTION TERNARY(a : std_ulogic; b,c : std_logic_vector) return std_logic_vector;
--pragma synthesis_off
FUNCTION TERNARY(a : std_ulogic; b,c : real) return real;
FUNCTION TERNARY(a : std_ulogic; b,c : time) return time;
--pragma synthesis_on

FUNCTION TERNARY(a,b,c : std_ulogic_vector) return std_ulogic_vector;
FUNCTION TERNARY(a : std_ulogic_vector; b,c : integer) return integer;
FUNCTION TERNARY(a : std_ulogic_vector; b,c : std_ulogic) return std_ulogic;
FUNCTION TERNARY(a : std_ulogic_vector; b,c : std_logic_vector) return std_logic_vector;
--pragma synthesis_off
FUNCTION TERNARY(a : std_ulogic_vector; b,c : real) return real;
FUNCTION TERNARY(a : std_ulogic_vector; b,c : time) return time;
--pragma synthesis_on

FUNCTION TERNARY(a,b,c : std_logic_vector) return std_logic_vector;
FUNCTION TERNARY(a : std_logic_vector; b,c : integer) return integer;
FUNCTION TERNARY(a : std_logic_vector; b,c : std_ulogic) return std_ulogic;
FUNCTION TERNARY(a : std_logic_vector; b,c : std_ulogic_vector) return std_ulogic_vector;
--pragma synthesis_off
FUNCTION TERNARY(a : std_logic_vector; b,c : real) return real;
FUNCTION TERNARY(a : std_logic_vector; b,c : time) return time;

FUNCTION TERNARY(a,b,c : real) return real;
FUNCTION TERNARY(a : real; b,c : std_ulogic) return std_ulogic;
FUNCTION TERNARY(a : real; b,c : std_ulogic_vector) return std_ulogic_vector;
FUNCTION TERNARY(a : real; b,c : std_logic_vector) return std_logic_vector;
FUNCTION TERNARY(a : real; b,c : integer) return integer;
FUNCTION TERNARY(a : real; b,c : time) return time;
--pragma synthesis_on

-- functions for TERNARY combination
FUNCTION TERNARY(a : std_ulogic; b : std_logic_vector; c: std_ulogic) return 
	std_logic_vector;

FUNCTION TERNARY(a : std_ulogic; b : std_ulogic; c: std_logic_vector) return 
	std_logic_vector;

FUNCTION TERNARY(a : std_ulogic; b : integer; c: std_ulogic) return 
	integer;

FUNCTION TERNARY(a : std_ulogic; b : std_ulogic; c: integer) return 
	integer;

FUNCTION TERNARY(a : integer; b : integer; c: std_ulogic) return 
	integer;

FUNCTION TERNARY(a : integer; b : std_ulogic; c: integer) return 
	integer;

FUNCTION TERNARY(a : integer; b : std_logic_vector; c: std_ulogic) return 
	std_logic_vector;

FUNCTION TERNARY(a : integer; b : std_ulogic; c: std_logic_vector) return 
	std_logic_vector;





--end functions for TERNARY combination

-- FUNCTIONS for shift operations

FUNCTION "sll"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector;
FUNCTION "sll"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector;

FUNCTION "srl"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector;
FUNCTION "srl"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector;

FUNCTION "sla"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector;
FUNCTION "sla"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector;

FUNCTION "sra"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector;
FUNCTION "sra"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector;

FUNCTION "rol"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector;
FUNCTION "rol"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector;

FUNCTION "ror"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector;
FUNCTION "ror"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector;


-- FUNCTIONs for integer operations

FUNCTION "not" (l: integer) return integer;
FUNCTION "and" (l,r: integer) return integer;
FUNCTION "nand" (l,r: integer) return integer;
FUNCTION "or" (l,r: integer) return integer;
FUNCTION "nor" (l,r: integer) return integer;
FUNCTION "xor" (l,r: integer) return integer;
FUNCTION "xnor" (l,r: integer) return integer;
FUNCTION "sll" (l,r: integer) return integer;
FUNCTION "srl" (l,r: integer) return integer;


-- FUNCTIONs for std_logic/std_ulogic_vector/std_logic_vector operations

-- FUNCTIONs for combination of Boolean and ints

FUNCTION "="  ( l : Boolean; r : natural ) RETURN boolean;
FUNCTION "/="  ( l : Boolean; r : natural ) RETURN boolean;


FUNCTION "="  ( l : integer; r : std_logic_vector ) RETURN boolean;
FUNCTION "/=" ( l : integer;  r : std_logic_vector ) RETURN boolean;
FUNCTION "<"  ( l : integer;  r : std_logic_vector ) RETURN boolean;
FUNCTION ">"  ( l : integer;  r : std_logic_vector ) RETURN boolean;
FUNCTION "<=" ( l : integer;  r : std_logic_vector ) RETURN boolean;
FUNCTION ">=" ( l : integer;  r : std_logic_vector ) RETURN boolean;


FUNCTION "="  ( l : std_logic_vector;  r : integer ) RETURN boolean;
FUNCTION "/=" ( l : std_logic_vector;  r : integer ) RETURN boolean;
FUNCTION "<"  ( l : std_logic_vector;  r : integer ) RETURN boolean;
FUNCTION ">"  ( l : std_logic_vector;  r : integer ) RETURN boolean;
FUNCTION "<=" ( l : std_logic_vector;  r : integer ) RETURN boolean;
FUNCTION ">=" ( l : std_logic_vector;  r : integer ) RETURN boolean;

--logical functions between std_logic_vector and integer, std_logic_vector and boolean

FUNCTION "and" ( l : std_logic_vector;  r : integer ) RETURN std_logic_vector;
FUNCTION "nand"  ( l : std_logic_vector;  r : integer ) RETURN std_logic_vector;
FUNCTION "or"  ( l : std_logic_vector;  r : integer ) RETURN std_logic_vector;
FUNCTION "nor" ( l : std_logic_vector;  r : integer ) RETURN std_logic_vector;
FUNCTION "xor" ( l : std_logic_vector;  r : integer ) RETURN std_logic_vector;

FUNCTION "and"  ( l : integer; r : std_logic_vector ) RETURN integer;
FUNCTION "nand" ( l : integer;  r : std_logic_vector ) RETURN integer;
FUNCTION "or"  ( l : integer;  r : std_logic_vector ) RETURN integer;
FUNCTION "nor"  ( l : integer;  r : std_logic_vector ) RETURN integer;
FUNCTION "xor" ( l : integer;  r : std_logic_vector ) RETURN integer;

FUNCTION "and" ( l : std_logic_vector;  r : boolean ) RETURN std_logic_vector;
FUNCTION "nand"  ( l : std_logic_vector;  r : boolean ) RETURN std_logic_vector;
FUNCTION "or"  ( l : std_logic_vector;  r : boolean ) RETURN std_logic_vector;
FUNCTION "nor" ( l : std_logic_vector;  r : boolean ) RETURN std_logic_vector;
FUNCTION "xor" ( l : std_logic_vector;  r : boolean ) RETURN std_logic_vector;

FUNCTION "and"  ( l : boolean; r : std_logic_vector ) RETURN boolean;
FUNCTION "nand" ( l : boolean;  r : std_logic_vector ) RETURN boolean;
FUNCTION "or"  ( l : boolean;  r : std_logic_vector ) RETURN boolean;
FUNCTION "nor"  ( l : boolean;  r : std_logic_vector ) RETURN boolean;
FUNCTION "xor" ( l : boolean;  r : std_logic_vector ) RETURN boolean;

--logical functions between std_logic_vector and integer, std_logic_vector and boolean

-- Added functions for std_logic, integer
FUNCTION "="  ( l : std_logic;  r : integer ) RETURN boolean;
FUNCTION "/=" ( l : std_logic;  r : integer ) RETURN boolean;
FUNCTION "<"  ( l : std_logic;  r : integer ) RETURN boolean;
FUNCTION ">"  ( l : std_logic;  r : integer ) RETURN boolean;
FUNCTION "<=" ( l : std_logic;  r : integer ) RETURN boolean;
FUNCTION ">=" ( l : std_logic;  r : integer ) RETURN boolean;
-- Functions for std_logic, integer

--pragma synthesis_off

-- arithmetic operations for real and int and int and real
FUNCTION "+"  ( l : real;  r : integer ) RETURN real;
FUNCTION "-" ( l : real;  r : integer ) RETURN real;
FUNCTION "/"  ( l : real;  r : integer ) RETURN real;
FUNCTION "*"  ( l : real;  r : integer ) RETURN real;


FUNCTION "+"  ( l : integer;  r : real ) RETURN real;
FUNCTION "-" ( l : integer;  r : real ) RETURN real;
FUNCTION "/"  ( l : integer;  r : real ) RETURN real;
FUNCTION "*"  ( l : integer;  r : real ) RETURN real;

-- end arithmetic operations for real and int and int and real

FUNCTION "="  ( l : real;  r : integer ) RETURN boolean;
FUNCTION "/=" ( l : real;  r : integer ) RETURN boolean;
FUNCTION "<"  ( l : real;  r : integer ) RETURN boolean;
FUNCTION ">"  ( l : real;  r : integer ) RETURN boolean;
FUNCTION "<=" ( l : real;  r : integer ) RETURN boolean;
FUNCTION ">=" ( l : real;  r : integer ) RETURN boolean;

FUNCTION "="  ( l : integer;  r : real ) RETURN boolean;
FUNCTION "/=" ( l : integer;  r : real ) RETURN boolean;
FUNCTION "<"  ( l : integer;  r : real ) RETURN boolean;
FUNCTION ">"  ( l : integer;  r : real ) RETURN boolean;
FUNCTION "<=" ( l : integer;  r : real ) RETURN boolean;
FUNCTION ">=" ( l : integer;  r : real ) RETURN boolean;
--pragma synthesis_on

FUNCTION "+"   ( l, r : std_logic_vector ) RETURN std_logic_vector;
FUNCTION "-"   ( l, r : std_logic_vector ) RETURN std_logic_vector;
FUNCTION "*"   ( l, r : std_logic_vector ) RETURN std_logic_vector;
FUNCTION "/"   ( l, r : std_logic_vector ) RETURN std_logic_vector;
FUNCTION "REM" ( l, r : std_logic_vector ) RETURN std_logic_vector;


FUNCTION "+"   ( l : std_logic_vector; r : integer ) RETURN std_logic_vector;
FUNCTION "-"   ( l : std_logic_vector; r : integer ) RETURN std_logic_vector;
FUNCTION "*"   ( l : std_logic_vector; r : integer ) RETURN std_logic_vector;
FUNCTION "/"   ( l : std_logic_vector; r : integer ) RETURN std_logic_vector;
FUNCTION "REM" ( l : std_logic_vector; r : integer ) RETURN std_logic_vector;
FUNCTION "&" ( l : std_logic_vector; r : integer ) RETURN std_logic_vector;
FUNCTION "&" ( l : std_logic_vector; r : boolean ) RETURN std_logic_vector;

-- need logical functions bet. std_logic_vector and std_logic
FUNCTION "and" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector;
FUNCTION "nand" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector;
FUNCTION "or" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector;
FUNCTION "nor" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector;
FUNCTION "xor" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector;
--FUNCTION "xnor" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector;

FUNCTION "and" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector;
FUNCTION "nand" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector;
FUNCTION "or" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector;
FUNCTION "nor" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector;
FUNCTION "xor" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector;
--FUNCTION "xnor" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector;

-- end logical functions for std_logic_vector and std_logic

-- need arith functions bet std_logic and std_logic
-- used only when the int can be 0 or 1
-- need arithmetic functions bet. std_logic_vector and std_logic
FUNCTION "+"   ( l : std_logic; r : std_logic ) RETURN std_logic;
FUNCTION "-"   ( l : std_logic; r : std_logic ) RETURN std_logic;
FUNCTION "*"   ( l : std_logic; r : std_logic ) RETURN std_logic;
FUNCTION "/"   ( l : std_logic; r : std_logic ) RETURN std_logic;
FUNCTION "REM" ( l : std_logic; r : std_logic ) RETURN std_logic;

-- need arithmetic functions bet. std_logic_vector and std_logic
FUNCTION "+"   ( l : std_logic_vector; r : std_logic ) RETURN std_logic_vector;
FUNCTION "-"   ( l : std_logic_vector; r : std_logic ) RETURN std_logic_vector;
FUNCTION "*"   ( l : std_logic_vector; r : std_logic ) RETURN std_logic_vector;
FUNCTION "/"   ( l : std_logic_vector; r : std_logic ) RETURN std_logic_vector;
FUNCTION "REM" ( l : std_logic_vector; r : std_logic ) RETURN std_logic_vector;

-- need arithmetic func. between std_logic and std_logic_vector, caveat, returns type of 'r'
FUNCTION "+"   ( l : std_logic; r : std_logic_vector ) RETURN std_logic_vector;
FUNCTION "-"   ( l : std_logic; r : std_logic_vector ) RETURN std_logic_vector;
FUNCTION "*"   ( l : std_logic; r : std_logic_vector ) RETURN std_logic_vector;
FUNCTION "/"   ( l : std_logic; r : std_logic_vector ) RETURN std_logic_vector;
FUNCTION "REM" ( l : std_logic; r : std_logic_vector ) RETURN std_logic_vector;


FUNCTION "+"   ( l : integer; r : std_logic_vector ) RETURN integer;
FUNCTION "-"   ( l : integer; r : std_logic_vector ) RETURN integer;
FUNCTION "*"   ( l : integer; r : std_logic_vector ) RETURN integer;
FUNCTION "/"   ( l : integer; r : std_logic_vector ) RETURN integer;
FUNCTION "REM" ( l : integer; r : std_logic_vector ) RETURN integer;

-- need arith. functions bet std_logic and integer
FUNCTION "+" ( l : std_logic; r : integer )  RETURN integer;
FUNCTION "-" ( l : std_logic; r : integer ) RETURN integer;
FUNCTION "*" ( l : std_logic; r : integer ) RETURN integer;
FUNCTION "/" ( l : std_logic; r : integer ) RETURN integer;
FUNCTION "REM" ( l : std_logic; r : integer ) RETURN integer;

FUNCTION "and" ( l : std_logic; r : integer )  RETURN std_logic;
FUNCTION "nand" ( l : std_logic; r : integer ) RETURN std_logic;
FUNCTION "or" ( l : std_logic; r : integer ) RETURN std_logic;
FUNCTION "nor" ( l : std_logic; r : integer ) RETURN std_logic;
FUNCTION "xor" ( l : std_logic; r : integer ) RETURN std_logic;
FUNCTION "&" ( l : std_logic; r : integer ) RETURN std_logic_vector;
FUNCTION "xnor" ( l : std_logic; r : integer ) RETURN std_logic;

FUNCTION "and" ( l : integer; r : std_logic ) RETURN integer;
FUNCTION "nand" ( l : integer; r : std_logic ) RETURN integer;
FUNCTION "or" ( l : integer; r : std_logic ) RETURN integer;
FUNCTION "nor" ( l : integer; r : std_logic ) RETURN integer;
FUNCTION "xor" ( l : integer; r : std_logic ) RETURN integer;
FUNCTION "&" ( l : integer; r : std_logic ) RETURN std_logic_vector;
FUNCTION "xnor" ( l : integer; r : std_logic ) RETURN integer;

-- need functions for operations between std_logic and integer
FUNCTION "+"   ( l : integer; r : std_logic ) RETURN integer;
FUNCTION "-"   ( l : integer; r : std_logic ) RETURN integer;
FUNCTION "*"   ( l : integer; r : std_logic ) RETURN integer;
FUNCTION "/"   ( l : integer; r : std_logic ) RETURN integer;
FUNCTION "REM" ( l : integer; r : std_logic ) RETURN integer;

FUNCTION "and" ( l : std_logic; r : boolean )  RETURN std_logic;
FUNCTION "nand" ( l : std_logic; r : boolean ) RETURN std_logic;
FUNCTION "or" ( l : std_logic; r : boolean ) RETURN std_logic;
FUNCTION "nor" ( l : std_logic; r : boolean ) RETURN std_logic;
FUNCTION "xor" ( l : std_logic; r : boolean ) RETURN std_logic;
FUNCTION "&" ( l : std_logic; r : boolean ) RETURN std_logic_vector;
FUNCTION "xnor" ( l : std_logic; r : boolean ) RETURN std_logic;

FUNCTION "and" ( l : boolean; r : std_logic ) RETURN boolean;
FUNCTION "nand" ( l : boolean; r : std_logic ) RETURN boolean;
FUNCTION "or" ( l : boolean; r : std_logic ) RETURN boolean;
FUNCTION "nor" ( l : boolean; r : std_logic ) RETURN boolean;
FUNCTION "xor" ( l : boolean; r : std_logic ) RETURN boolean;
FUNCTION "&" ( l : boolean; r : std_logic ) RETURN std_logic_vector;
FUNCTION "xnor" ( l : boolean; r : std_logic ) RETURN boolean;


FUNCTION "and" ( l : integer; r : boolean ) RETURN integer;
FUNCTION "nand" ( l : integer; r : boolean ) RETURN integer;
FUNCTION "or" ( l : integer; r : boolean ) RETURN integer;
FUNCTION "nor" ( l : integer; r : boolean ) RETURN integer;
FUNCTION "xor" ( l : integer; r : boolean ) RETURN integer;
FUNCTION "&" ( l : integer; r : boolean ) RETURN std_logic_vector;
FUNCTION "xnor" ( l : integer; r : boolean ) RETURN integer;

FUNCTION "and" ( l : boolean; r : integer ) RETURN boolean;
FUNCTION "nand" ( l : boolean; r : integer ) RETURN boolean;
FUNCTION "or" ( l : boolean; r : integer ) RETURN boolean;
FUNCTION "nor" ( l : boolean; r : integer ) RETURN boolean;
FUNCTION "xor" ( l : boolean; r : integer ) RETURN boolean;
FUNCTION "&" ( l : boolean; r : integer ) RETURN std_logic_vector;
FUNCTION "xnor" ( l : boolean; r : integer ) RETURN boolean;

-- Overloaded function for text output
FUNCTION to_bitvector ( a : bit ) RETURN bit_vector;
FUNCTION to_bitvector ( a : std_ulogic ) RETURN bit_vector;
FUNCTION to_bitvector ( a : integer ) RETURN bit_vector;

--Conversion functions
FUNCTION to_stdlogicvector(l : integer; size : natural; dir : direction := LITTLE_ENDIAN) RETURN std_logic_vector;
FUNCTION to_stdlogicvector(l : std_logic_vector) RETURN std_logic_vector;
FUNCTION to_stdlogicvector(l : std_logic_vector; size : natural;dir : direction := little_endian ) RETURN std_logic_vector;
FUNCTION to_stdlogicvector ( hex : STRING ) RETURN std_logic_vector;
FUNCTION to_stdlogicvector(l : std_logic; size : natural) RETURN std_logic_vector;
FUNCTION to_stdlogicvector(l : boolean; size : natural) RETURN std_logic_vector;

FUNCTION to_integer(l : std_logic_vector; dir : direction := little_endian) RETURN integer;
FUNCTION to_integer(l : integer) RETURN integer;
FUNCTION to_integer(l : std_logic) RETURN integer;
FUNCTION to_integer(l : boolean) RETURN integer;

-- functions for resolving ambiguity
FUNCTION v2v_to_integer(l : std_logic_vector; dir : direction := little_endian) RETURN integer;
FUNCTION v2v_to_integer(l : integer) RETURN integer;
FUNCTION v2v_to_integer(l : std_logic) RETURN integer;
FUNCTION v2v_to_integer(l : boolean) RETURN integer;

FUNCTION to_stdlogic(l : integer) RETURN std_logic;
FUNCTION to_stdlogic(l : Boolean) RETURN std_logic;
FUNCTION to_stdlogic(l : std_logic) RETURN std_logic;
FUNCTION to_stdlogic(l : std_logic_vector) RETURN std_logic;

--pragma synthesis_off
FUNCTION to_real(l : integer) RETURN real;
FUNCTION to_real (l : real) RETURN real;
--pragma synthesis_on

FUNCTION to_boolean(l : std_logic) RETURN boolean;
FUNCTION to_boolean(l : integer) RETURN boolean;
FUNCTION to_boolean(l : std_logic_vector) RETURN boolean;
FUNCTION to_boolean(l : boolean) RETURN boolean;

end FUNCTIONS;

library ieee;
library GSI;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--library grlib;
--use grlib.stdlib.all;

Package body FUNCTIONS is

  --============= Local Subprograms (from numeric_std.vhd)=====================

  function MAX (LEFT, RIGHT: INTEGER) return INTEGER is
  begin
    if LEFT > RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end MAX;

  function MIN (LEFT, RIGHT: INTEGER) return INTEGER is
  begin
    if LEFT < RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end MIN;


-- unary operations
TYPE stdlogic_boolean_table is array(std_ulogic, std_ulogic) of boolean;
TYPE stdlogic_1d IS ARRAY (std_ulogic) OF std_ulogic;
    TYPE stdlogic_table IS ARRAY(std_ulogic, std_ulogic) OF std_ulogic;


FUNCTION U_AND(a : std_ulogic_vector) return std_ulogic is

VARIABLE result : std_ulogic := '1';
begin
	FOR i in a'RANGE LOOP	
		result := result and a(i);
	END LOOP;
	return result;
end U_AND;

FUNCTION U_AND(a : std_logic_vector) return std_logic is

VARIABLE result : std_logic := '1';
begin
	FOR i in a'RANGE LOOP	
		result := result and a(i);
	END LOOP;
	return result;
end U_AND;

FUNCTION U_NAND(a : std_ulogic_vector) return std_ulogic is

VARIABLE result : std_ulogic := '1';
begin
	FOR i in a'RANGE LOOP	
		result := result and a(i);
	END LOOP;
	return not(result);
end U_NAND;

FUNCTION U_NAND(a : std_logic_vector) return std_logic is

VARIABLE result : std_logic := '1';
begin
	FOR i in a'RANGE LOOP	
		result := result and a(i);
	END LOOP;
	return not(result);
end U_NAND;

FUNCTION U_OR(a : std_ulogic_vector) return std_ulogic is

VARIABLE result : std_ulogic := '0';
begin
	FOR i in a'RANGE LOOP	
		result := result or a(i);
	END LOOP;
	return result;
end U_OR;

FUNCTION U_OR(a : std_logic_vector) return std_logic is

VARIABLE result : std_logic := '0';
begin
	FOR i in a'RANGE LOOP	
		result := result or a(i);
	END LOOP;
	return result;
end U_OR;

FUNCTION U_NOR(a : std_ulogic_vector) return std_ulogic is

VARIABLE result : std_ulogic := '0';
begin
	FOR i in a'RANGE LOOP	
		result := result or a(i);
	END LOOP;
	return not(result);
end U_NOR;

FUNCTION U_NOR(a : std_logic_vector) return std_logic is

VARIABLE result : std_logic := '0';
begin
	FOR i in a'RANGE LOOP	
		result := result or a(i);
	END LOOP;
	return not(result);
end U_NOR;

FUNCTION U_XOR(a : std_ulogic_vector) return std_ulogic is

VARIABLE result : std_ulogic := '0';
begin
	FOR i in a'RANGE LOOP	
		result := result xor a(i);
	END LOOP;
	return result;
end U_XOR;

FUNCTION U_XOR(a : std_logic_vector) return std_logic is

VARIABLE result : std_logic := '0';
begin
	FOR i in a'RANGE LOOP	
		result := result xor a(i);
	END LOOP;
	return result;
end U_XOR;

FUNCTION U_XNOR(a : std_ulogic_vector) return std_ulogic is

VARIABLE result : std_ulogic := '0';
begin
	FOR i in a'RANGE LOOP	
		result := result xor a(i);
	END LOOP;
	return not(result);
end U_XNOR;

FUNCTION U_XNOR(a : std_logic_vector) return std_logic is

VARIABLE result : std_logic := '0';
begin
	FOR i in a'RANGE LOOP	
		result := result xor a(i);
	END LOOP;
	return not(result);
end U_XNOR;

-- ternary operations
FUNCTION TERNARY(a,b,c : boolean) return boolean IS

begin
	IF a = TRUE THEN
		RETURN b;
	ELSE
		RETURN c;
	END IF;
end TERNARY;

---------------------------------------------------
FUNCTION TERNARY(a : boolean; b,c : std_ulogic) return std_ulogic IS

begin
	IF a = TRUE THEN
		RETURN b;
	ELSE
		RETURN c;
	END IF;
end TERNARY;

---------------------------------------------------
FUNCTION TERNARY(a : boolean; b,c : std_ulogic_vector) return std_ulogic_vector IS

begin
	IF a = TRUE THEN
		RETURN b;
	ELSE
		RETURN c;
	END IF;
end TERNARY;

---------------------------------------------------
FUNCTION TERNARY(a : boolean; b,c : std_logic_vector) return std_logic_vector IS

begin
	IF a = TRUE THEN
		RETURN b;
	ELSE
		RETURN c;
	END IF;
end TERNARY;

--pragma synthesis_off
---------------------------------------------------
FUNCTION TERNARY(a : boolean; b,c : real) return real IS

begin
	IF a = TRUE THEN
		RETURN b;
	ELSE
		RETURN c;
	END IF;
end TERNARY;

---------------------------------------------------
FUNCTION TERNARY(a : boolean; b,c : time) return time IS

begin
	IF a = TRUE THEN
		RETURN b;
	ELSE
		RETURN c;
	END IF;
end TERNARY;
--pragma synthesis_on
---------------------------------------------------

FUNCTION TERNARY(a,b,c : integer) return integer is

begin
	IF (a /= 0) THEN
		return b;
	ELSE
		return c;
	END IF;
end TERNARY;

FUNCTION TERNARY(a : integer; b,c : std_ulogic) return std_ulogic is

begin
	IF (a /= 0) THEN
		return b;
	ELSE
		return c;
	END IF;
end TERNARY;


FUNCTION TERNARY(a : integer; b,c : std_ulogic_vector) return std_ulogic_vector is

begin 
        IF (a /= 0) THEN 
                return b; 
        ELSE 
                return c; 
        END IF; 
end TERNARY;  

FUNCTION TERNARY(a : integer; b,c : std_logic_vector) return std_logic_vector is

begin  
        IF (a /= 0) THEN  
                return b;  
        ELSE  
                return c;  
        END IF;  
end TERNARY;   

--pragma synthesis_off
FUNCTION TERNARY(a : integer; b,c : real) return real is

begin
        IF (a /= 0) THEN
                return b;
        ELSE
                return c;
        END IF;
end TERNARY;

FUNCTION TERNARY(a : integer; b,c : time) return time is

begin 
        IF (a /= 0) THEN 
                return b; 
        ELSE 
                return c; 
        END IF; 
end TERNARY;
--pragma synthesis_on

FUNCTION TERNARY(a,b,c : std_ulogic) return std_ulogic is

begin
	IF (a = '1') THEN
                return b;
        ELSIF (a = '0') THEN
                return c;
--pragma synthesis_off
	ELSIF (b = c AND NOT Is_X(b)) THEN
		return b;
	ELSE
		return 'X';
--pragma synthesis_on
        END IF;
end TERNARY;

FUNCTION TERNARY(a : std_ulogic; b,c : integer) return integer is

begin 
	IF (a = '1') THEN
                return b;
        ELSIF (a = '0') THEN
                return c;
--pragma synthesis_off
	ELSIF (b = c) THEN
		return b;
	ELSE
		return 0;
--pragma synthesis_on
        END IF;
end TERNARY;  

FUNCTION TERNARY(a : std_ulogic; b,c : std_ulogic_vector) return std_ulogic_vector is
--pragma synthesis_off
    constant SIZE: NATURAL := MAX(b'LENGTH, c'LENGTH);
    variable b01 : std_ulogic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable c01 : std_ulogic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable result : std_ulogic_vector(SIZE-1 downto 0);
--pragma synthesis_on
begin  
	IF (a = '1') THEN
                return b;
        ELSIF (a = '0') THEN
                return c;
--pragma synthesis_off
	ELSIF (b = c AND NOT Is_X(b)) THEN
		return b;
	ELSE
		b01(b'LENGTH-1 downto 0) := b;
		c01(c'LENGTH-1 downto 0) := c;
		FOR I IN SIZE-1 DOWNTO 0 LOOP
		    IF (b01(I) = c01(I) AND NOT Is_X(b01(I))) THEN
			result(I) := b01(I);
		    ELSE
			result(I) := 'X';
		    END IF;
		END LOOP;
		return result;
--pragma synthesis_on
        END IF;
end TERNARY;

FUNCTION TERNARY(a : std_ulogic; b,c : std_logic_vector) return std_logic_vector is
--pragma synthesis_off
    constant SIZE: NATURAL := MAX(b'LENGTH, c'LENGTH);
    variable b01 : std_logic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable c01 : std_logic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable result : std_logic_vector(SIZE-1 downto 0);
--pragma synthesis_on
begin  
	IF (a = '1') THEN
                return b;
        ELSIF (a = '0') THEN
                return c;
--pragma synthesis_off
	ELSIF (b = c AND NOT Is_X(b)) THEN
		return b;
	ELSE
		b01(b'LENGTH-1 downto 0) := b;
		c01(c'LENGTH-1 downto 0) := c;
		FOR I IN SIZE-1 DOWNTO 0 LOOP
		    IF (b01(I) = c01(I) AND NOT Is_X(b01(I))) THEN
			result(I) := b01(I);
		    ELSE
			result(I) := 'X';
		    END IF;
		END LOOP;
		return result;
--pragma synthesis_on
        END IF;
end TERNARY; 

--pragma synthesis_off
FUNCTION TERNARY(a : std_ulogic; b,c : real) return real is

begin 
	IF (a = '1') THEN
                return b;
        ELSIF (a = '0') THEN
                return c;
	ELSIF (b = c) THEN
		return b;
	ELSE
		return 0.0;
        END IF;
end TERNARY;  

FUNCTION TERNARY(a : std_ulogic; b,c : time) return time is

begin     
	IF (a = '1') THEN
                return b;
        ELSIF (a = '0') THEN
                return c;
	ELSIF (b = c) THEN
		return b;
	ELSE
		return 0 ns;
        END IF;
end TERNARY;   
--pragma synthesis_on

FUNCTION TERNARY(a,b,c : std_ulogic_vector) return std_ulogic_vector is
--pragma synthesis_off
    constant SIZE: NATURAL := MAX(b'LENGTH, c'LENGTH);
    variable b01 : std_ulogic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable c01 : std_ulogic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable result : std_ulogic_vector(SIZE-1 downto 0);
--pragma synthesis_on
begin
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
--pragma synthesis_off
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE 
		b01(b'LENGTH-1 downto 0) := b;
		c01(c'LENGTH-1 downto 0) := c;
		FOR I IN SIZE-1 DOWNTO 0 LOOP
		    IF (b01(I) = c01(I) AND NOT Is_X(b01(I))) THEN
			result(I) := b01(I);
		    ELSE
			result(I) := 'X';
		    END IF;
		END LOOP;
		return result;
	    END IF;
--pragma synthesis_on
        ELSE 
                return c; 
        END IF; 
end TERNARY;

FUNCTION TERNARY(a : std_ulogic_vector; b,c : integer) return integer is

begin 
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
--pragma synthesis_off
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE return 0;
	    END IF;
--pragma synthesis_on
        ELSE 
                return c; 
        END IF; 
end TERNARY;

FUNCTION TERNARY(a : std_ulogic_vector; b,c : std_ulogic) return std_ulogic is

begin  
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
--pragma synthesis_off
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE return 'X';
	    END IF;
--pragma synthesis_on
        ELSE 
                return c; 
        END IF; 
end TERNARY;

FUNCTION TERNARY(a : std_ulogic_vector; b,c : std_logic_vector) return std_logic_vector is
--pragma synthesis_off
    constant SIZE: NATURAL := MAX(b'LENGTH, c'LENGTH);
    variable b01 : std_logic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable c01 : std_logic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable result : std_logic_vector(SIZE-1 downto 0);
--pragma synthesis_on
begin
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
--pragma synthesis_off
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE 
		b01(b'LENGTH-1 downto 0) := b;
		c01(c'LENGTH-1 downto 0) := c;
		FOR I IN SIZE-1 DOWNTO 0 LOOP
		    IF (b01(I) = c01(I) AND NOT Is_X(b01(I))) THEN
			result(I) := b01(I);
		    ELSE
			result(I) := 'X';
		    END IF;
		END LOOP;
		return result;
	    END IF;
--pragma synthesis_on
        ELSE 
                return c; 
        END IF; 
end TERNARY;

--pragma synthesis_off
FUNCTION TERNARY(a : std_ulogic_vector; b,c : real) return real is

begin    
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE return 0.0;
	    END IF;
        ELSE 
                return c; 
        END IF; 
end TERNARY;

FUNCTION TERNARY(a : std_ulogic_vector; b,c : time) return time is

begin     
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE return 0 ns;
	    END IF;
        ELSE 
                return c; 
        END IF; 
end TERNARY;
--pragma synthesis_on

FUNCTION TERNARY(a,b,c : std_logic_vector) return std_logic_vector is
--pragma synthesis_off
    constant SIZE: NATURAL := MAX(b'LENGTH, c'LENGTH);
    variable b01 : std_logic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable c01 : std_logic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable result : std_logic_vector(SIZE-1 downto 0);
--pragma synthesis_on
begin
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
--pragma synthesis_off
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE 
		b01(b'LENGTH-1 downto 0) := b;
		c01(c'LENGTH-1 downto 0) := c;
		FOR I IN SIZE-1 DOWNTO 0 LOOP
		    IF (b01(I) = c01(I) AND NOT Is_X(b01(I))) THEN
			result(I) := b01(I);
		    ELSE
			result(I) := 'X';
		    END IF;
		END LOOP;
		return result;
	    END IF;
--pragma synthesis_on
        ELSE 
                return c; 
        END IF; 
end TERNARY;

FUNCTION TERNARY(a : std_logic_vector; b,c : integer) return integer is

begin       
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
--pragma synthesis_off
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE return 0;
	    END IF;
--pragma synthesis_on
        ELSE 
                return c; 
        END IF; 
end TERNARY;


FUNCTION TERNARY(a : std_logic_vector; b,c : std_ulogic) return std_ulogic is

begin        
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
--pragma synthesis_off
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE return 'X';
	    END IF;
--pragma synthesis_on
        ELSE 
                return c; 
        END IF; 
end TERNARY;


FUNCTION TERNARY(a : std_logic_vector; b,c : std_ulogic_vector) return std_ulogic_vector is
--pragma synthesis_off
    constant SIZE: NATURAL := MAX(b'LENGTH, c'LENGTH);
    variable b01 : std_ulogic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable c01 : std_ulogic_vector(SIZE-1 downto 0) := (OTHERS => '0');
    variable result : std_ulogic_vector(SIZE-1 downto 0);
--pragma synthesis_on
begin
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
--pragma synthesis_off
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE 
		b01(b'LENGTH-1 downto 0) := b;
		c01(c'LENGTH-1 downto 0) := c;
		FOR I IN SIZE-1 DOWNTO 0 LOOP
		    IF (b01(I) = c01(I) AND NOT Is_X(b01(I))) THEN
			result(I) := b01(I);
		    ELSE
			result(I) := 'X';
		    END IF;
		END LOOP;
		return result;
	    END IF;
--pragma synthesis_on
        ELSE 
                return c; 
        END IF; 
end TERNARY;

--pragma synthesis_off
FUNCTION TERNARY(a : std_logic_vector; b,c : real) return real is

begin 
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE return 0.0;
	    END IF;
        ELSE 
                return c; 
        END IF; 
end TERNARY;

FUNCTION TERNARY(a : std_logic_vector; b,c : time) return time is

begin  
        IF to_boolean(to_stdlogicvector(to_bitvector(a))) THEN 
                return b; 
	ELSIF (Is_X(a)) THEN
	    IF (b = c) THEN return b;
	    ELSE return 0 ns;
	    END IF;
        ELSE 
                return c; 
        END IF; 
end TERNARY;

FUNCTION TERNARY(a,b,c : real) return real is

begin   
        IF (a /= 0) THEN  
                return b;  
        ELSE   
                return c;   
        END IF;   
end TERNARY;

FUNCTION TERNARY(a : real; b,c : std_ulogic) return std_ulogic is

begin    
        IF (a /= 0) THEN   
                return b;   
        ELSE    
                return c;    
        END IF;    
end TERNARY;

FUNCTION TERNARY(a : real; b,c : std_ulogic_vector) return std_ulogic_vector is

begin     
        IF (a /= 0) THEN    
                return b;     
        ELSE      
                return c;      
        END IF;      
end TERNARY;

FUNCTION TERNARY(a : real; b,c : std_logic_vector) return std_logic_vector is

begin      
        IF (a /= 0) THEN     
                return b;      
        ELSE       
                return c;       
        END IF;       
end TERNARY;

FUNCTION TERNARY(a : real; b,c : integer) return integer is

begin       
        IF (a /= 0) THEN      
                return b;       
        ELSE        
                return c;        
        END IF;        
end TERNARY;

FUNCTION TERNARY(a : real; b,c : time) return time is

begin        
        IF (a /= 0) THEN       
                return b;        
        ELSE         
                return c;         
        END IF;         
end TERNARY;
--pragma synthesis_on 

-- functions for TERNARY combination
FUNCTION TERNARY(a : std_ulogic; b : std_logic_vector; c: std_ulogic) return 
	std_logic_vector IS
    variable c01 : std_logic_vector(b'LENGTH-1 downto 0) := (OTHERS => '0');
--pragma synthesis_off
    variable b01 : std_logic_vector(b'LENGTH-1 downto 0) := b;
    variable result : std_logic_vector(b'LENGTH-1 downto 0);
--pragma synthesis_on
BEGIN  
	c01(0) := c;
	IF (a = '1') THEN
                return b;
        ELSIF (a = '0') THEN
                return c01;
--pragma synthesis_off
	ELSIF (b01 = c01 AND NOT Is_X(b)) THEN
		return b;
	ELSE
		FOR I IN b'LENGTH-1 DOWNTO 0 LOOP
		    IF (b01(I) = c01(I) AND NOT Is_X(b01(I))) THEN
			result(I) := b01(I);
		    ELSE
			result(I) := 'X';
		    END IF;
		END LOOP;
		return result;
--pragma synthesis_on
        END IF;
END TERNARY;

FUNCTION TERNARY(a : std_ulogic; b : std_ulogic; c: std_logic_vector) return 
	std_logic_vector  IS
    variable b01 : std_logic_vector(c'LENGTH-1 downto 0) := (OTHERS => '0');
--pragma synthesis_off
    variable c01 : std_logic_vector(c'LENGTH-1 downto 0) := c;
    variable result : std_logic_vector(c'LENGTH-1 downto 0);
--pragma synthesis_on
BEGIN  
	b01(0) := b;
	IF (a = '1') THEN
                return b01;
        ELSIF (a = '0') THEN
                return c;
--pragma synthesis_off
	ELSIF (b01 = c01 AND NOT Is_X(b01)) THEN
		return b01;
	ELSE
		FOR I IN c'LENGTH-1 DOWNTO 0 LOOP
		    IF (b01(I) = c01(I) AND NOT Is_X(b01(I))) THEN
			result(I) := b01(I);
		    ELSE
			result(I) := 'X';
		    END IF;
		END LOOP;
		return result;
--pragma synthesis_on
        END IF;
END TERNARY;

FUNCTION TERNARY(a : std_ulogic; b : integer; c: std_ulogic) return 
	integer IS
BEGIN
	IF (a = '0') THEN 
		return to_integer(c);
        ELSIF (a = '1') THEN 
                return b;
--pragma synthesis_off
	ELSIF (b = to_integer(c) AND NOT Is_X(c)) THEN
		return b;
	ELSE
		return 0;
--pragma synthesis_on
        END IF; 
END TERNARY;

FUNCTION TERNARY(a : std_ulogic; b : std_ulogic; c: integer) return 
	integer IS
BEGIN
	IF (a = '0') THEN 
		return c;
        ELSIF (a = '1') THEN 
                return to_integer(b);
--pragma synthesis_off
	ELSIF (to_integer(b) = c AND NOT Is_X(b)) THEN
		return c;
	ELSE
		return 0;
--pragma synthesis_on
        END IF; 
END TERNARY;

FUNCTION TERNARY(a : integer; b : integer; c: std_ulogic) return 
	integer IS
BEGIN
	IF (a /= 0) THEN 
		return b;
        ELSE 
                return to_integer(c);
        END IF; 
	
END TERNARY;

FUNCTION TERNARY(a : integer; b : std_ulogic; c: integer) return 
	integer IS
BEGIN
	IF (a /= 0) THEN 
		return to_integer(b);
        ELSE 
                return c;
        END IF; 

END TERNARY;

FUNCTION TERNARY(a : integer; b : std_logic_vector; c: std_ulogic) return 
	std_logic_vector IS
VARIABLE temp : std_logic_vector(0 downto 0);
BEGIN
	IF (a /= 0) THEN 
                return b; 
        ELSE 
		temp(0) := c;
                return temp;
        END IF; 
END TERNARY;

FUNCTION TERNARY(a : integer; b : std_ulogic; c: std_logic_vector) return 
	std_logic_vector IS
VARIABLE temp : std_logic_vector(0 downto 0);
BEGIN
	IF (a /= 0) THEN 
                temp(0) := b;
                return temp;
        ELSE 
                return c;
        END IF; 

END TERNARY;

--end functions for TERNARY combination 

-- FUNCTIONS for integer operations

FUNCTION "not" (l: integer) return integer is

VARIABLE temp : SIGNED(31 downto 0) := TO_SIGNED(l,32);
begin
	return TO_INTEGER(NOT(temp));
end "not";

FUNCTION "and" (l,r: integer) return integer is

VARIABLE temp1 : SIGNED(31 downto 0) := TO_SIGNED(l,32);
VARIABLE temp2 : SIGNED(31 downto 0) := TO_SIGNED(r,32);

begin
	return TO_INTEGER(temp1 AND temp2);
end "and";

FUNCTION "nand" (l,r: integer) return integer is

VARIABLE temp1 : SIGNED(31 downto 0) := TO_SIGNED(l,32);
VARIABLE temp2 : SIGNED(31 downto 0) := TO_SIGNED(r,32);

begin
	return TO_INTEGER(temp1 NAND temp2);
end "nand";

FUNCTION "or" (l,r: integer) return integer is

VARIABLE temp1 : SIGNED(31 downto 0) := TO_SIGNED(l,32); 
VARIABLE temp2 : SIGNED(31 downto 0) := TO_SIGNED(r,32);
 
begin
        return TO_INTEGER(temp1 OR temp2);
end "or";

FUNCTION "nor" (l,r: integer) return integer is

VARIABLE temp1 : SIGNED(31 downto 0) := TO_SIGNED(l,32); 
VARIABLE temp2 : SIGNED(31 downto 0) := TO_SIGNED(r,32);
 
begin
        return TO_INTEGER(temp1 NOR temp2);
end "nor";

FUNCTION "xor" (l,r: integer) return integer is

VARIABLE temp1 : SIGNED(31 downto 0) := TO_SIGNED(l,32); 
VARIABLE temp2 : SIGNED(31 downto 0) := TO_SIGNED(r,32); 
  
begin 
        return TO_INTEGER(temp1 XOR temp2); 
end "xor";

FUNCTION "xnor" (l,r: integer) return integer is

VARIABLE temp1 : SIGNED(31 downto 0) := TO_SIGNED(l,32);  
VARIABLE temp2 : SIGNED(31 downto 0) := TO_SIGNED(r,32);  
   
begin  
        return TO_INTEGER(temp1 XNOR temp2);  
end "xnor";

FUNCTION "sll" (l,r: integer) return integer is

VARIABLE temp1 : SIGNED(31 downto 0) := TO_SIGNED(l,32);   
    
begin   
        return TO_INTEGER(temp1 SLL r);   
end "sll";

FUNCTION "srl" (l,r: integer) return integer is

VARIABLE temp1 : SIGNED(31 downto 0) := TO_SIGNED(l,32);    
     
begin    
        return TO_INTEGER(temp1 SRL r);    
end "srl";


-- functions for std_ulogic operations
-- first add all the tables needed

 -- truth table for "=" function
CONSTANT eq_table : stdlogic_boolean_table := (
--      ----------------------------------------------------------------------------
--      |  U       X      0     1      Z      W      L      H      D         |   |
--      ----------------------------------------------------------------------------
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | U |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | X |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | 0 |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | 1 |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | Z |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | W |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | L |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | H |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE )   -- | D |
    );

-- truth table for "/=" function
CONSTANT neq_table : stdlogic_boolean_table := (
--      ----------------------------------------------------------------------------
--      |  U       X      0     1      Z      W      L      H      D         |   |
--      ----------------------------------------------------------------------------
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | U |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | X |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | 0 |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | 1 |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | Z |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | W |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | L |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | H |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE )   -- | D |
    );

-- truth table for "<" function
CONSTANT ltb_table : stdlogic_boolean_table := (
--      ----------------------------------------------------------------------------
--      |  U       X      0     1      Z      W      L      H      D         |   |
--      ----------------------------------------------------------------------------
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | U |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | X |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | 0 |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | 1 |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | Z |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | W |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | L |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | H |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE )   -- | D |
    );

 -- truth table for ">" function
CONSTANT gtb_table : stdlogic_boolean_table := (
--      ----------------------------------------------------------------------------
--      |  U       X      0     1      Z      W      L      H      D         |   |
--      ----------------------------------------------------------------------------
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | U |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | X |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | 0 |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | 1 |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | Z |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | W |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ),  -- | L |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | H |
        ( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE )   -- | D |
    );

-- truth table for "<=" function
CONSTANT leb_table : stdlogic_boolean_table := (
--      ----------------------------------------------------------------------------
--      |  U       X      0     1      Z      W      L      H      D         |   |
--      ----------------------------------------------------------------------------
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | U |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | X |
        ( TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE ),  -- | 0 |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | 1 |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | Z |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | W |
        ( TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE ),  -- | L |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE ),  -- | H |
        ( FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE )   -- | D |
    );

-- truth table for ">=" function
CONSTANT geb_table : stdlogic_boolean_table := (
--      ----------------------------------------------------------------------------
--      |  U       X      0     1      Z      W      L      H      D         |   |
--      ----------------------------------------------------------------------------
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | U |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | X |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | 0 |
        ( TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE ),  -- | 1 |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | Z |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | W |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE ),  -- | L |
        ( TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE ),  -- | H |
        ( FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE )   -- | D |
    );

CONSTANT lt_table : stdlogic_table := (
--      ----------------------------------------------------
--      |  U    X    0    1    Z    W    L    H    D         |   |
--      ----------------------------------------------------
        ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ),  -- | U |
        ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),  -- | X |
        ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ),  -- | 0 |
        ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ),  -- | 1 |
        ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),  -- | Z |
        ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),  -- | W |
        ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ),  -- | L |
        ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ),  -- | H |
        ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' )   -- | D |
    );

 -- truth table for ">" function
CONSTANT gt_table : stdlogic_table := (
--      ----------------------------------------------------
--      |  U    X    0    1    Z    W    L    H    D         |   |
--      ----------------------------------------------------
        ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ),  -- | U |
        ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),  -- | X |
        ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ),  -- | 0 |
        ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ),  -- | 1 |
        ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),  -- | Z |
        ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),  -- | W |
        ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ),  -- | L |
        ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ),  -- | H |
        ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' )   -- | D |
    );

-- truth table for "<=" function
        CONSTANT le_table : stdlogic_table := (
        --      ----------------------------------------------------
        --      |  U    X    0    1    Z    W    L    H    D         |   |
        --      ----------------------------------------------------
                ( 'U', 'U', 'U', '1', 'U', 'U', 'U', '1', 'U' ),  -- | U |
                ( 'U', 'X', 'X', '1', 'X', 'X', 'X', '1', 'X' ),  -- | X |
                ( '1', '1', '1', '1', '1', '1', '1', '1', '1' ),  -- | 0 |
                ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ),  -- | 1 |
                ( 'U', 'X', 'X', '1', 'X', 'X', 'X', '1', 'X' ),  -- | Z |
                ( 'U', 'X', 'X', '1', 'X', 'X', 'X', '1', 'X' ),  -- | W |
                ( '1', '1', '1', '1', '1', '1', '1', '1', '1' ),  -- | L |
                ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ),  -- | H |
                ( 'U', 'X', 'X', '1', 'X', 'X', 'X', '1', 'X' )   -- | D |
    );

-- truth table for ">=" function
        CONSTANT ge_table : stdlogic_table := (
        --      ----------------------------------------------------
        --      |  U    X    0    1    Z    W    L    H    D         |   |
        --      ----------------------------------------------------
                ( 'U', 'U', '1', 'U', 'U', 'U', '1', 'U', 'U' ),  -- | U |
                ( 'U', 'X', '1', 'X', 'X', 'X', '1', 'X', 'X' ),  -- | X |
                ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ),  -- | 0 |
                ( '1', '1', '1', '1', '1', '1', '1', '1', '1' ),  -- | 1 |
                ( 'U', 'X', '1', 'X', 'X', 'X', '1', 'X', 'X' ),  -- | Z |
                ( 'U', 'X', '1', 'X', 'X', 'X', '1', 'X', 'X' ),  -- | W |
                ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ),  -- | L |
                ( '1', '1', '1', '1', '1', '1', '1', '1', '1' ),  -- | H |
                ( 'U', 'X', '1', 'X', 'X', 'X', '1', 'X', 'X' )   -- | D |
    );


FUNCTION "="  ( l : Boolean;  r : natural ) RETURN Boolean is

begin
	IF l = TRUE AND r = 1 THEN
		return TRUE;
	ELSIF l = FALSE AND r = 0 THEN
		return TRUE;
	ELSE
		return FALSE;
	END IF;
end "=";

FUNCTION "/="  ( l : Boolean;  r : natural ) RETURN Boolean is

begin
	return NOT (l = r);
end "/=";

-----------------------------------------------------------------

FUNCTION "="  ( l : integer; r : std_logic_vector ) RETURN boolean IS

BEGIN
	RETURN l = SIGNED(r);
END "=";

-----------------------------------------------------------------
FUNCTION "/=" ( l : integer;  r : std_logic_vector ) RETURN boolean IS

BEGIN
	RETURN l /= SIGNED(r);
END "/=";

-----------------------------------------------------------------
FUNCTION "<"  ( l : integer;  r : std_logic_vector ) RETURN boolean IS

BEGIN
	RETURN l < SIGNED(r);
END "<";

-----------------------------------------------------------------
FUNCTION ">"  ( l : integer;  r : std_logic_vector ) RETURN boolean IS

BEGIN
	RETURN l > SIGNED(r);
END ">";

-----------------------------------------------------------------
FUNCTION "<=" ( l : integer;  r : std_logic_vector ) RETURN boolean IS

BEGIN
	RETURN l <= SIGNED(r);
END "<=";

-----------------------------------------------------------------
FUNCTION ">=" ( l : integer;  r : std_logic_vector ) RETURN boolean IS

BEGIN
	RETURN l >= SIGNED(r);
END ">=";

-----------------------------------------------------------------

FUNCTION "="  ( l : std_logic_vector;  r : integer ) RETURN boolean IS

BEGIN
	RETURN SIGNED(l) = r;
END "=";

-----------------------------------------------------------------
FUNCTION "/=" ( l : std_logic_vector;  r : integer ) RETURN boolean IS

BEGIN
	RETURN SIGNED(l) /= r;
END "/=";

-----------------------------------------------------------------
FUNCTION "<"  ( l : std_logic_vector;  r : integer ) RETURN boolean IS

BEGIN
	RETURN SIGNED(l) < r;
END "<";

-----------------------------------------------------------------
FUNCTION ">"  ( l : std_logic_vector;  r : integer ) RETURN boolean IS

BEGIN
	RETURN SIGNED(l) > r;
END ">";

-----------------------------------------------------------------
FUNCTION "<=" ( l : std_logic_vector;  r : integer ) RETURN boolean IS

BEGIN
	RETURN SIGNED(l) <= r;
END "<=";

-----------------------------------------------------------------
FUNCTION ">=" ( l : std_logic_vector;  r : integer ) RETURN boolean IS

BEGIN
	RETURN SIGNED(l) >= r;
END ">=";

-----------------------------------------------------------------
--logical functions between std_logic_vector and integer, std_logic_vector and boolean

FUNCTION "and" ( l : std_logic_vector;  r : integer ) RETURN std_logic_vector is
BEGIN
	RETURN l and to_stdlogicvector(l, 32);
END;

-----------------------------------------------------------------

FUNCTION "nand"  ( l : std_logic_vector;  r : integer ) RETURN std_logic_vector IS
BEGIN 
	RETURN l nand to_stdlogicvector(l, 32);
END;

-----------------------------------------------------------------

FUNCTION "or"  ( l : std_logic_vector;  r : integer ) RETURN std_logic_vector IS
BEGIN
	RETURN l or to_stdlogicvector(l, 32);
END;

-----------------------------------------------------------------

FUNCTION "nor" ( l : std_logic_vector;  r : integer ) RETURN std_logic_vector IS
BEGIN
	RETURN l nor to_stdlogicvector(l, 32);
END;

-----------------------------------------------------------------

FUNCTION "xor" ( l : std_logic_vector;  r : integer ) RETURN std_logic_vector IS
BEGIN
	RETURN l xor to_stdlogicvector(l, 32);
END;

-----------------------------------------------------------------

FUNCTION "and"  ( l : integer; r : std_logic_vector ) RETURN integer IS
BEGIN
	RETURN l and v2v_to_integer(r);
END;

-----------------------------------------------------------------

FUNCTION "nand" ( l : integer;  r : std_logic_vector ) RETURN integer IS
BEGIN
	RETURN l nand v2v_to_integer(r);
END; 

-----------------------------------------------------------------

FUNCTION "or"  ( l : integer;  r : std_logic_vector ) RETURN integer IS
BEGIN
	RETURN l or v2v_to_integer(r);
END;

-----------------------------------------------------------------

FUNCTION "nor"  ( l : integer;  r : std_logic_vector ) RETURN integer IS
BEGIN
	RETURN l nor v2v_to_integer(r);
END;

-----------------------------------------------------------------

FUNCTION "xor" ( l : integer;  r : std_logic_vector ) RETURN integer IS
BEGIN
	RETURN l xor v2v_to_integer(r);
END;

-----------------------------------------------------------------

FUNCTION "and" ( l : std_logic_vector;  r : boolean ) RETURN std_logic_vector IS
BEGIN
	RETURN l and to_stdlogicvector(r,32);
END;

-----------------------------------------------------------------

FUNCTION "nand"  ( l : std_logic_vector;  r : boolean ) RETURN std_logic_vector IS
BEGIN
	RETURN l nand to_stdlogicvector(r,32);
END;

-----------------------------------------------------------------

FUNCTION "or"  ( l : std_logic_vector;  r : boolean ) RETURN std_logic_vector IS
BEGIN
	RETURN l or to_stdlogicvector(r,32);
END;

-----------------------------------------------------------------

FUNCTION "nor" ( l : std_logic_vector;  r : boolean ) RETURN std_logic_vector IS
BEGIN
	RETURN l nor to_stdlogicvector(r,32);
END;

-----------------------------------------------------------------

FUNCTION "xor" ( l : std_logic_vector;  r : boolean ) RETURN std_logic_vector IS
BEGIN
	RETURN l xor to_stdlogicvector(r,32);
END; 

-----------------------------------------------------------------

FUNCTION "and"  ( l : boolean; r : std_logic_vector ) RETURN boolean IS
BEGIN
	RETURN l and to_boolean(r);
END;

-----------------------------------------------------------------

FUNCTION "nand" ( l : boolean;  r : std_logic_vector ) RETURN boolean IS
BEGIN
	RETURN l nand to_boolean(r);
END;

-----------------------------------------------------------------

FUNCTION "or"  ( l : boolean;  r : std_logic_vector ) RETURN boolean IS
BEGIN
	RETURN l or to_boolean(r);
END;

-----------------------------------------------------------------

FUNCTION "nor"  ( l : boolean;  r : std_logic_vector ) RETURN boolean IS
BEGIN
	RETURN l nor to_boolean(r);
END;

-----------------------------------------------------------------

FUNCTION "xor" ( l : boolean;  r : std_logic_vector ) RETURN boolean IS
BEGIN
	RETURN l xor to_boolean(r);
END;

--logical functions between std_logic_vector and integer, std_logic_vector and boolean
-----------------------------------------------------------------
-- Added functions for std_logic, integer
FUNCTION "="  ( l : std_logic;  r : integer ) RETURN boolean IS
BEGIN
	RETURN to_integer(l) = r;
END "=";
-----------------------------------------------------------------

FUNCTION "/=" ( l : std_logic;  r : integer ) RETURN boolean IS
BEGIN
	RETURN to_integer(l) /= r;
END "/=";
-----------------------------------------------------------------

FUNCTION "<"  ( l : std_logic;  r : integer ) RETURN boolean IS
BEGIN
	RETURN to_integer(l) < r;
END "<";
-----------------------------------------------------------------

FUNCTION ">"  ( l : std_logic;  r : integer ) RETURN boolean IS
BEGIN
	RETURN to_integer(l) > r;
END ">";
-----------------------------------------------------------------

FUNCTION "<=" ( l : std_logic;  r : integer ) RETURN boolean IS
BEGIN
	RETURN to_integer(l) <= r;
END "<=";
-----------------------------------------------------------------

FUNCTION ">=" ( l : std_logic;  r : integer ) RETURN boolean IS
BEGIN
	RETURN to_integer(l) >= r;
END ">=";
-----------------------------------------------------------------

-- Functions for std_logic, integer
-----------------------------------------------------------------

--pragma synthesis_off
-- arithmetic operations for real and int and int and real
FUNCTION "+"  ( l : real;  r : integer ) RETURN real IS
BEGIN
	RETURN l + to_real(r);
END;

FUNCTION "-" ( l : real;  r : integer ) RETURN real IS
BEGIN
	RETURN l - to_real(r);
END;

FUNCTION "/"  ( l : real;  r : integer ) RETURN real IS
BEGIN
	RETURN l / to_real(r);
END;

FUNCTION "*"  ( l : real;  r : integer ) RETURN real IS
BEGIN
	RETURN l * to_real(r);
END ;


FUNCTION "+"  ( l : integer;  r : real ) RETURN real  IS
BEGIN
	RETURN to_real(l) + r;
END;

FUNCTION "-" ( l : integer;  r : real ) RETURN real IS
BEGIN
	RETURN to_real(l) - r;
END;

FUNCTION "/"  ( l : integer;  r : real ) RETURN real  IS
BEGIN
	RETURN to_real(l) / l;
END;

FUNCTION "*"  ( l : integer;  r : real ) RETURN real IS
BEGIN
	RETURN to_real(l) * r;
END;


-- end arithmetic operations for real and int and int and real
-----------------------------------------------------------------

FUNCTION "="  ( l : real;  r : integer ) RETURN boolean IS

BEGIN
	RETURN INTEGER(l) = r;

END "=";

-----------------------------------------------------------------
FUNCTION "/=" ( l : real;  r : integer ) RETURN boolean IS

BEGIN
	RETURN INTEGER(l) /= r;

END "/=";

-----------------------------------------------------------------
FUNCTION "<"  ( l : real;  r : integer ) RETURN boolean IS

BEGIN
	RETURN INTEGER(l) < r;

END "<";

-----------------------------------------------------------------
FUNCTION ">"  ( l : real;  r : integer ) RETURN boolean IS

BEGIN
	RETURN INTEGER(l) > r;

END ">";

-----------------------------------------------------------------
FUNCTION "<=" ( l : real;  r : integer ) RETURN boolean IS

BEGIN
	RETURN INTEGER(l) <= r;

END "<=";

-----------------------------------------------------------------
FUNCTION ">=" ( l : real;  r : integer ) RETURN boolean IS

BEGIN
	RETURN INTEGER(l) >= r;

END ">=";

-----------------------------------------------------------------

FUNCTION "="  ( l : integer;  r : real ) RETURN boolean IS

BEGIN
	RETURN l = INTEGER(r);

END "=";

-----------------------------------------------------------------
FUNCTION "/=" ( l : integer;  r : real ) RETURN boolean IS

BEGIN
	RETURN l /= INTEGER(r);

END "/=";



-----------------------------------------------------------------
FUNCTION "<"  ( l : integer;  r : real ) RETURN boolean IS

BEGIN
	RETURN l < INTEGER(r);

END "<";

-----------------------------------------------------------------
FUNCTION ">"  ( l : integer;  r : real ) RETURN boolean IS

BEGIN
	RETURN l > INTEGER(r);

END ">";

-----------------------------------------------------------------
FUNCTION "<=" ( l : integer;  r : real ) RETURN boolean IS

BEGIN
	RETURN l <= INTEGER(r);

END "<=";

-----------------------------------------------------------------
FUNCTION ">=" ( l : integer;  r : real ) RETURN boolean IS

BEGIN
	RETURN l >= INTEGER(r);

END ">=";

--pragma synthesis_on
-----------------------------------------------------------------

FUNCTION "+"   ( l, r : std_logic_vector ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(UNSIGNED(l) + UNSIGNED(r));

end "+";
------------------------------------------------------------------
FUNCTION "-"   ( l, r : std_logic_vector ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(UNSIGNED(l) - UNSIGNED(r));

end "-";

------------------------------------------------------------------
FUNCTION "*"   ( l, r : std_logic_vector ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(UNSIGNED(l) * UNSIGNED(r));

end "*";
------------------------------------------------------------------
FUNCTION "/"   ( l, r : std_logic_vector ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(UNSIGNED(l) / UNSIGNED(r));

end "/";

------------------------------------------------------------------

FUNCTION "REM" ( l, r : std_logic_vector ) RETURN std_logic_vector is
begin
	return STD_LOGIC_VECTOR(UNSIGNED(l) rem UNSIGNED(r));

end "REM";

------------------------------------------------------------------

FUNCTION "+"   ( l : std_logic_vector; r : integer ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(SIGNED(l) + r);

end "+";
------------------------------------------------------------------
FUNCTION "-"   ( l : std_logic_vector; r : integer ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(SIGNED(l) - r);

end "-";
------------------------------------------------------------------
FUNCTION "*"   ( l : std_logic_vector; r : integer ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(SIGNED(l) * r);

end "*";
------------------------------------------------------------------
FUNCTION "/"   ( l : std_logic_vector; r : integer ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(SIGNED(l) / r);

end "/";
------------------------------------------------------------------
FUNCTION "REM" ( l : std_logic_vector; r : integer ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(SIGNED(l) rem r);

end "REM";

------------------------------------------------------------------
FUNCTION "&" ( l : std_logic_vector; r : integer ) RETURN std_logic_vector is

begin
	return l & to_stdlogic(r);

end "&";

------------------------------------------------------------------
FUNCTION "&" ( l : std_logic_vector; r : boolean ) RETURN std_logic_vector is

begin
	return l & to_stdlogic(r);

end "&";

------------------------------------------------------------------
FUNCTION "+"   ( l : std_logic_vector; r : std_logic ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(SIGNED(l) + to_integer(r));

end "+";
------------------------------------------------------------------
FUNCTION "-"   ( l : std_logic_vector; r : std_logic ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(SIGNED(l) - to_integer(r));

end "-";
------------------------------------------------------------------
FUNCTION "*"   ( l : std_logic_vector; r : std_logic ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(SIGNED(l) * to_integer(r));

end "*";
------------------------------------------------------------------
FUNCTION "/"   ( l : std_logic_vector; r : std_logic ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(SIGNED(l) / to_integer(r));

end "/";
------------------------------------------------------------------
FUNCTION "REM" ( l : std_logic_vector; r : std_logic ) RETURN std_logic_vector is

begin
	return STD_LOGIC_VECTOR(SIGNED(l) rem to_integer(r));

end "REM";

------------------------------------------------------------------
FUNCTION "+"   ( l : std_logic; r : std_logic_vector ) RETURN std_logic_vector is
begin
	return STD_LOGIC_VECTOR(to_integer(l) + SIGNED(r));
END "+";

------------------------------------------------------------------

FUNCTION "-"   ( l : std_logic; r : std_logic_vector ) RETURN std_logic_vector is
begin
	return STD_LOGIC_VECTOR(to_integer(l) - SIGNED(r));
END "-"; 
------------------------------------------------------------------

FUNCTION "*"   ( l : std_logic; r : std_logic_vector ) RETURN std_logic_vector is
begin
	return STD_LOGIC_VECTOR(to_integer(l) * SIGNED(r));
END "*";
------------------------------------------------------------------

FUNCTION "/"   ( l : std_logic; r : std_logic_vector ) RETURN std_logic_vector is
begin
	return STD_LOGIC_VECTOR(to_integer(l) / SIGNED(r));
END "/"; 
------------------------------------------------------------------

FUNCTION "REM" ( l : std_logic; r : std_logic_vector ) RETURN std_logic_vector is
begin
	return STD_LOGIC_VECTOR(to_integer(l) REM SIGNED(r));
END "REM"; 
-------------------------------------------------------------
-- need logical functions bet. std_logic_vector and std_logic
FUNCTION "and" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector IS
BEGIN
	RETURN l and to_stdlogicvector(r, l'length);
END "and";
--------------------------------------------------------------

FUNCTION "nand" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector IS
BEGIN
	RETURN l nand to_stdlogicvector(r, l'length);
END "nand";
--------------------------------------------------------------
FUNCTION "or" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector IS
BEGIN
	RETURN l or to_stdlogicvector(r, l'length);
END "or";
--------------------------------------------------------------

FUNCTION "nor" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector IS
BEGIN
	RETURN l nor to_stdlogicvector(r, l'length);
END "nor";
--------------------------------------------------------------

FUNCTION "xor" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector IS
BEGIN
	RETURN l xor to_stdlogicvector(r, l'length);
END "xor";
--------------------------------------------------------------

FUNCTION "xnor" ( l : std_logic_vector; r : std_logic )  RETURN std_logic_vector IS

BEGIN
	RETURN NOT(l xor to_stdlogicvector(r, l'length));
END "xnor";
--------------------------------------------------------------

FUNCTION "and" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector IS
BEGIN
	RETURN to_stdlogicvector(l, r'length) and r;
END "and";
--------------------------------------------------------------

FUNCTION "nand" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector IS
BEGIN
	RETURN to_stdlogicvector(l, r'length) nand r;
END "nand";
--------------------------------------------------------------
FUNCTION "or" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector IS
BEGIN
	RETURN to_stdlogicvector(l, r'length) or r;
END "or";
--------------------------------------------------------------

FUNCTION "nor" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector IS
BEGIN
	RETURN to_stdlogicvector(l, r'length) nor r;
END "nor";
--------------------------------------------------------------

FUNCTION "xor" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector IS
BEGIN
	RETURN to_stdlogicvector(l, r'length) xor r;
END "xor";
--------------------------------------------------------------
FUNCTION "xnor" ( l : std_logic; r : std_logic_vector )  RETURN std_logic_vector IS
BEGIN
	RETURN NOT(to_stdlogicvector(l, r'length) xor r);
END "xnor";
--------------------------------------------------------------

-- end logical functions for std_logic_vector and std_logic
------------------------------------------------------------------
-- need arith functions bet std_logic and std_logic
-- used only when the int can be 0 or 1
-- need arithmetic functions bet. std_logic_vector and std_logic

FUNCTION "+"   ( l : std_logic; r : std_logic ) RETURN std_logic IS
BEGIN
	return to_stdlogic(to_integer(l) + to_integer(r));
END "+";

FUNCTION "-"   ( l : std_logic; r : std_logic ) RETURN std_logic IS
BEGIN
	return to_stdlogic(to_integer(l) - to_integer(r));
END "-"; 

FUNCTION "*"   ( l : std_logic; r : std_logic ) RETURN std_logic IS
BEGIN
	return to_stdlogic(to_integer(l) * to_integer(r));
END "*"; 

FUNCTION "/"   ( l : std_logic; r : std_logic ) RETURN std_logic IS
BEGIN
	return to_stdlogic(to_integer(l) / to_integer(r));
END "/";

FUNCTION "REM" ( l : std_logic; r : std_logic ) RETURN std_logic IS
BEGIN
	return to_stdlogic(to_integer(l) REM to_integer(r));
END "REM";


------- Arithmatic operations between std_logic and integer
-- caveat, functions below return integer

FUNCTION "+" ( l : std_logic; r : integer )  RETURN integer IS
BEGIN
	return to_integer(l) + r;
END "+";

-------------------------------------------------------

FUNCTION "-" ( l : std_logic; r : integer ) RETURN integer IS
BEGIN
	return to_integer(l) - r;
END "-";

-------------------------------------------------------
FUNCTION "*" ( l : std_logic; r : integer ) RETURN integer IS
BEGIN
	return to_integer(l) * r;
END "*";
 
-------------------------------------------------------
FUNCTION "/" ( l : std_logic; r : integer ) RETURN integer IS
BEGIN
	return to_integer(l) / r;
END "/";

------------------------------------------------------- 
FUNCTION "REM" ( l : std_logic; r : integer ) RETURN integer IS
BEGIN
	return to_integer(l) REM r;
END "REM";

-------------------------------------------------------
-------------------------------------------------------
FUNCTION "+"   ( l : integer; r : std_logic ) RETURN integer IS
begin
	return l + to_integer(r);
END "+";
-------------------------------------------------------

FUNCTION "-"   ( l : integer; r : std_logic ) RETURN integer IS
begin
	return l - to_integer(r);
END "-"; 
-------------------------------------------------------
FUNCTION "*"   ( l : integer; r : std_logic ) RETURN integer IS
begin
	return l * to_integer(r);
END "*";
 
-------------------------------------------------------
FUNCTION "/"   ( l : integer; r : std_logic ) RETURN integer IS
begin
	return l / to_integer(r);
END "/"; 

-------------------------------------------------------
FUNCTION "REM" ( l : integer; r : std_logic ) RETURN integer IS
begin
	return l REM to_integer(r);
END "REM";

-------------------------------------------------------
FUNCTION "+"   ( l : integer; r : std_logic_vector ) RETURN integer IS

BEGIN
	RETURN to_integer(l + SIGNED(r));
END "+";
------------------------------------------------------------------

FUNCTION "-"   ( l : integer; r : std_logic_vector ) RETURN integer IS

BEGIN
	RETURN to_integer(l - SIGNED(r));
END "-";
------------------------------------------------------------------
FUNCTION "*"   ( l : integer; r : std_logic_vector ) RETURN integer IS

BEGIN
	RETURN to_integer(l * SIGNED(r));
END "*";
------------------------------------------------------------------
FUNCTION "/"   ( l : integer; r : std_logic_vector ) RETURN integer IS

BEGIN
	RETURN to_integer(l / SIGNED(r));
END "/";
------------------------------------------------------------------
FUNCTION "REM" ( l : integer; r : std_logic_vector ) RETURN integer IS

BEGIN
	RETURN to_integer(l REM SIGNED(r));
END "REM";
------------------------------------------------------------------


FUNCTION "and" ( l : std_logic; r : integer )  RETURN std_logic IS

BEGIN
	RETURN l and to_stdlogic(r);
END "and";

------------------------------------------------------------------
FUNCTION "nand" ( l : std_logic; r : integer ) RETURN std_logic IS

BEGIN
	RETURN l nand to_stdlogic(r);
END "nand";

------------------------------------------------------------------
FUNCTION "or" ( l : std_logic; r : integer ) RETURN std_logic IS

BEGIN
	RETURN l or to_stdlogic(r);
END "or";

------------------------------------------------------------------
FUNCTION "nor" ( l : std_logic; r : integer ) RETURN std_logic IS

BEGIN
	RETURN l nor to_stdlogic(r);
END "nor";

------------------------------------------------------------------
FUNCTION "xor" ( l : std_logic; r : integer ) RETURN std_logic IS

BEGIN
	RETURN l xor to_stdlogic(r);
END "xor";

------------------------------------------------------------------
FUNCTION "&" ( l : std_logic; r : integer ) RETURN std_logic_vector IS

BEGIN
	RETURN l & to_stdlogic(r);
END "&";

------------------------------------------------------------------

FUNCTION "xnor" ( l : std_logic; r : integer ) RETURN std_logic IS

BEGIN
	RETURN not(l xor to_stdlogic(r));
END "xnor";

------------------------------------------------------------------

FUNCTION "and" ( l : integer; r : std_logic ) RETURN integer IS

VARIABLE tmp : integer := 0;

BEGIN
	RETURN l and to_integer(r);

END "and";

------------------------------------------------------------------
FUNCTION "nand" ( l : integer; r : std_logic ) RETURN integer IS

VARIABLE tmp : integer := 0;
BEGIN
	RETURN l nand to_integer(r); 

END "nand";

------------------------------------------------------------------
FUNCTION "or" ( l : integer; r : std_logic ) RETURN integer IS

VARIABLE tmp : integer := 0;
BEGIN
	RETURN l or to_integer(r);

END "or";

------------------------------------------------------------------
FUNCTION "nor" ( l : integer; r : std_logic ) RETURN integer IS

VARIABLE tmp : integer := 0;
BEGIN
	RETURN l nor to_integer(r);

END "nor";

------------------------------------------------------------------
FUNCTION "xor" ( l : integer; r : std_logic ) RETURN integer IS

VARIABLE tmp : integer := 0;
BEGIN
	RETURN l xor to_integer(r);

END "xor";

------------------------------------------------------------------
FUNCTION "&" ( l : integer; r : std_logic ) RETURN std_logic_vector IS
BEGIN
	RETURN to_stdlogic(l) & r;

END "&";
------------------------------------------------------------------

FUNCTION "xnor" ( l : integer; r : std_logic ) RETURN integer IS

VARIABLE tmp : integer := 0;
BEGIN
	RETURN l xnor to_integer(r);

END "xnor";

------------------------------------------------------------------

FUNCTION "and" ( l : std_logic ;  r : boolean )  RETURN std_logic IS 
BEGIN
	RETURN l AND to_stdlogic(r);
END "and";
------------------------------------------------------------------

FUNCTION "nand" ( l : std_logic ;  r : boolean ) RETURN std_logic IS 
BEGIN
	RETURN l NAND to_stdlogic(r);
END "nand";
------------------------------------------------------------------

FUNCTION "or" ( l : std_logic ;  r : boolean ) RETURN std_logic IS 
BEGIN
	RETURN l OR to_stdlogic(r);	
END "or";
------------------------------------------------------------------

FUNCTION "nor" ( l : std_logic ;  r : boolean ) RETURN std_logic IS 
BEGIN
	RETURN l NOR to_stdlogic(r);	
END "nor";
------------------------------------------------------------------

FUNCTION "xor" ( l : std_logic ;  r : boolean ) RETURN std_logic IS 
BEGIN
	RETURN l XOR to_stdlogic(r);	
END "xor";
------------------------------------------------------------------
FUNCTION "&" ( l : std_logic; r : boolean ) RETURN std_logic_vector IS
BEGIN
	RETURN l & to_stdlogic(r);	
END "&";
------------------------------------------------------------------

FUNCTION "xnor" ( l : std_logic ;  r : boolean ) RETURN std_logic IS 
BEGIN
	RETURN NOT(l XOR to_stdlogic(r));	
END "xnor";
------------------------------------------------------------------


FUNCTION "and" ( l : boolean ;  r : std_logic ) RETURN boolean IS 

VARIABLE tmp : std_logic := 'U';
BEGIN
	tmp := to_stdlogic(l) AND r;
	RETURN to_boolean(tmp);
END "and";
------------------------------------------------------------------

FUNCTION "nand" ( l : boolean ;  r : std_logic ) RETURN boolean IS 
VARIABLE tmp : std_logic := 'U';
BEGIN
	tmp := to_stdlogic(l) NAND r;
	RETURN to_boolean(tmp);
END "nand";
------------------------------------------------------------------

FUNCTION "or" ( l : boolean ;  r : std_logic ) RETURN boolean IS 
VARIABLE tmp : std_logic := 'U';
BEGIN
	tmp := to_stdlogic(l) OR r;
	RETURN to_boolean(tmp);
END "or";
------------------------------------------------------------------

FUNCTION "nor" ( l : boolean ;  r : std_logic ) RETURN boolean IS 
VARIABLE tmp : std_logic := 'U';
BEGIN
	tmp := to_stdlogic(l) NOR r;
	RETURN to_boolean(tmp);
END "nor";
------------------------------------------------------------------

FUNCTION "xor" ( l : boolean ;  r : std_logic ) RETURN boolean IS 
VARIABLE tmp : std_logic := 'U';
BEGIN
	tmp := to_stdlogic(l) XOR r;
	RETURN to_boolean(tmp);
END "xor";
------------------------------------------------------------------
FUNCTION "&" ( l : boolean ;  r : std_logic ) RETURN std_logic_vector IS 
BEGIN
	RETURN to_stdlogic(l) & r;
END "&";
------------------------------------------------------------------

FUNCTION "xnor" ( l : boolean ;  r : std_logic ) RETURN boolean IS 
VARIABLE tmp : std_logic := 'U';
BEGIN
	tmp := NOT(to_stdlogic(l) XOR r);
	RETURN to_boolean(tmp);
END "xnor";
------------------------------------------------------------------

FUNCTION "and" ( l : integer; r : boolean ) RETURN integer IS
BEGIN
	RETURN l and to_integer(r);
END "and";

------------------------------------------------------------------
FUNCTION "nand" ( l : integer; r : boolean ) RETURN integer IS
BEGIN
	RETURN l nand to_integer(r);
END "nand";
------------------------------------------------------------------
FUNCTION "or" ( l : integer; r : boolean ) RETURN integer IS
BEGIN
	RETURN l or to_integer(r);
END "or";
------------------------------------------------------------------
FUNCTION "nor" ( l : integer; r : boolean ) RETURN integer IS
BEGIN
	RETURN l nor to_integer(r);
END "nor";
------------------------------------------------------------------
FUNCTION "xor" ( l : integer; r : boolean ) RETURN integer IS
BEGIN
	RETURN l xor to_integer(r);
END "xor";
------------------------------------------------------------------
FUNCTION "&" ( l : integer; r : boolean ) RETURN std_logic_vector IS
BEGIN
	RETURN to_stdlogic(l) & to_stdlogic(r);
END "&";
------------------------------------------------------------------
FUNCTION "xnor" ( l : integer; r : boolean ) RETURN integer IS
BEGIN
	RETURN l xnor to_integer(r);
END "xnor";
------------------------------------------------------------------

FUNCTION "and" ( l : boolean; r : integer ) RETURN boolean IS
BEGIN
	RETURN l AND to_boolean(r);
END "and";
------------------------------------------------------------------
FUNCTION "nand" ( l : boolean; r : integer ) RETURN boolean IS
BEGIN
	RETURN l NAND to_boolean(r);
END "nand";
------------------------------------------------------------------
FUNCTION "or" ( l : boolean; r : integer ) RETURN boolean IS
BEGIN
	RETURN l or to_boolean(r);
END "or";
------------------------------------------------------------------
FUNCTION "nor" ( l : boolean; r : integer ) RETURN boolean IS
BEGIN
	RETURN l nor to_boolean(r);
END "nor";
------------------------------------------------------------------
FUNCTION "xor" ( l : boolean; r : integer ) RETURN boolean IS
BEGIN
	RETURN l xor to_boolean(r);
END "xor";
------------------------------------------------------------------
FUNCTION "&" ( l : boolean; r : integer ) RETURN std_logic_vector IS
BEGIN
	RETURN to_stdlogic(l) & to_stdlogic(r);
END "&";

------------------------------------------------------------------
FUNCTION "xnor" ( l : boolean; r : integer ) RETURN boolean IS
BEGIN
	RETURN l xnor to_boolean(r);
END "xnor";
------------------------------------------------------------------


-- Overloaded function for text output

FUNCTION to_bitvector ( a : bit ) RETURN bit_vector IS
VARIABLE s : bit_vector ( 1 TO 1 );
BEGIN
	s(1) := a;
	RETURN s;
END to_bitvector;

------------------------------------------------------------------

FUNCTION to_bitvector ( a : std_ulogic ) RETURN bit_vector IS
VARIABLE s : bit_vector ( 1 TO 1 );
BEGIN
	s(1) := to_bit(a);
	RETURN s;
END to_bitvector;

------------------------------------------------------------------

FUNCTION to_bitvector ( a : integer ) RETURN bit_vector IS
VARIABLE s : bit_vector ( 31 DOWNTO 0 );
BEGIN
	s := to_bitvector(STD_LOGIC_VECTOR(to_signed(a, 32)));
	RETURN s;
END to_bitvector;

------------------------------------------------------------------

FUNCTION to_stdlogicvector(l : integer; size : natural; dir : direction := little_endian) RETURN std_logic_vector IS

BEGIN
	IF dir = little_endian THEN
		RETURN STD_LOGIC_VECTOR(to_signed(l,size));
	ELSE
		RETURN STD_LOGIC_VECTOR(to_signed(l,size) ROL size); -- rotate left by size times
	END IF;

END to_stdlogicvector;

------------------------------------------------------------------
FUNCTION to_stdlogicvector(l : std_logic_vector ) RETURN std_logic_vector IS

BEGIN
	RETURN l;

END to_stdlogicvector;

------------------------------------------------------------------
FUNCTION to_stdlogicvector(l : std_logic_vector; size : natural; dir : direction := little_endian ) 
	RETURN std_logic_vector IS
VARIABLE tmp1 : UNSIGNED(l'length-1 downto 0);
VARIABLE tmp2 : UNSIGNED(size-1 downto 0);
BEGIN
	IF dir = little_endian THEN
		RETURN STD_LOGIC_VECTOR(resize(UNSIGNED(l),size));
	ELSE
		-- using function ROTATE_LEFT to make it both 87 and 93 compliant
		-- first get eqiv. in descending range
		-- second resize
		-- finally, rotate and return

		tmp1 :=  ROTATE_LEFT(UNSIGNED(l),l'length);
                tmp2 := resize(UNSIGNED(tmp1),size);
		RETURN STD_LOGIC_VECTOR(ROTATE_LEFT(UNSIGNED(tmp2),size));
	END IF;

END to_stdlogicvector;

------------------------------------------------------------------
FUNCTION to_stdlogicvector(l : std_logic; size : natural) RETURN std_logic_vector IS

VARIABLE tmp : std_logic_vector(size-1 DOWNTO 0) := (OTHERS => '0');
BEGIN
	tmp(0) := l;
	RETURN tmp; 
END to_stdlogicvector;

------------------------------------------------------------------
FUNCTION to_stdlogicvector(l : boolean; size : natural) RETURN std_logic_vector IS

VARIABLE tmp : std_logic_vector(size-1 DOWNTO 0) := (OTHERS => '0');
BEGIN
	tmp(0) := to_stdlogic(l);
	RETURN tmp; 
END to_stdlogicvector;

------------------------------------------------------------------
FUNCTION to_integer(l : integer) RETURN integer IS

BEGIN
	RETURN l;
END to_integer;

------------------------------------------------------------------
FUNCTION to_integer(l : std_logic) RETURN integer IS

BEGIN
	IF ( l = '0') THEN
		RETURN 0;
	ELSIF (l = '1') THEN
		RETURN 1;
	ELSE
		ASSERT FALSE REPORT("Std_logic values other than '0' and '1' cannot be converted to integer type")
		SEVERITY WARNING;
		RETURN 0;
	END IF;
END to_integer;

------------------------------------------------------------------
FUNCTION to_integer(l : boolean) RETURN integer IS

BEGIN
	IF ( l = TRUE) THEN
		RETURN 0;
	ELSE
		RETURN 1;
	END IF;
END to_integer;

------------------------------------------------------------------
FUNCTION to_stdlogic(l : integer) RETURN std_logic IS

VARIABLE ret_val : std_logic := '0';
BEGIN
	IF l = 0 THEN
		ret_val := '0';
	ELSIF l = 1 THEN
		ret_val := '1';
	ELSE
		ASSERT FALSE REPORT("Integers other than 0 and 1 cannot be converted to std_logic type")
		SEVERITY WARNING;
	END IF;
	RETURN ret_val;
END to_stdlogic;

------------------------------------------------------------------
FUNCTION to_stdlogic(l : Boolean) RETURN std_logic IS

VARIABLE ret_val : std_logic := '0';
BEGIN
	IF l = FALSE THEN
		ret_val := '0';
	ELSE
		ret_val := '1';
	END IF;

	RETURN ret_val;
END to_stdlogic;

------------------------------------------------------------------
FUNCTION to_stdlogic(l : std_logic) RETURN std_logic IS

BEGIN
	RETURN l;
END to_stdlogic;
------------------------------------------------------------------
FUNCTION to_stdlogic(l : std_logic_vector) RETURN std_logic IS


BEGIN
	RETURN l(l'LOW);
END to_stdlogic;

------------------------------------------------------------------

FUNCTION to_integer(l : std_logic_vector; dir : direction := little_endian) RETURN integer IS

BEGIN
	IF dir = little_endian THEN
--		RETURN to_integer(SIGNED(l));
		RETURN to_integer(UNSIGNED(l));
	ELSE
--		RETURN to_integer(SIGNED(l) ROR l'LENGTH);
		RETURN to_integer(UNSIGNED(l) ROR l'LENGTH);
	END IF;	

END to_integer;

------------------------------------------------------------------

FUNCTION v2v_to_integer(l : std_logic_vector; dir : direction := little_endian) RETURN integer IS

BEGIN
	IF dir = little_endian THEN
--		RETURN to_integer(SIGNED(l));
		RETURN to_integer(UNSIGNED(l));
	ELSE
		--NOTE, since ROR is not available in 87, we will use ROTATE_RIGHT
                RETURN to_integer(ROTATE_RIGHT(UNSIGNED(l) , l'LENGTH));
--		RETURN to_integer(UNSIGNED(l) ROR l'LENGTH);
	END IF;	

END v2v_to_integer;

------------------------------------------------------------------
FUNCTION v2v_to_integer(l : integer) RETURN integer IS

BEGIN
	RETURN l;
END v2v_to_integer;

------------------------------------------------------------------
FUNCTION v2v_to_integer(l : std_logic) RETURN integer IS

BEGIN
	IF ( l = '0') THEN
		RETURN 0;
	ELSIF (l = '1') THEN
		RETURN 1;
	ELSE
		ASSERT FALSE REPORT("Std_logic values other than '0' and '1' cannot be converted to integer type")
		SEVERITY WARNING;
		RETURN 0;
	END IF;
END v2v_to_integer;

------------------------------------------------------------------
FUNCTION v2v_to_integer(l : boolean) RETURN integer IS

BEGIN
	IF ( l = TRUE) THEN
		RETURN 0;
	ELSE
		RETURN 1;
	END IF;
END v2v_to_integer;

------------------------------------------------------------------
--pragma synthesis_off
------------------------------------------------------------------
FUNCTION to_real(l : integer) RETURN real IS

BEGIN
	RETURN REAL(l);
END to_real;

------------------------------------------------------------------
FUNCTION to_real(l : real) RETURN real IS

BEGIN
	RETURN l;
END to_real;
--pragma synthesis_on

------------------------------------------------------------------
FUNCTION to_boolean(l : std_logic) RETURN boolean IS

BEGIN
	IF ( l = '0' ) THEN
		RETURN FALSE;
	ELSIF (l = '1') THEN
		RETURN TRUE;
	ELSE
		ASSERT FALSE REPORT("Std_logic values other than '0' and '1' cannot be converted to boolean type")
		SEVERITY WARNING;
		RETURN FALSE;
	END IF;

END to_boolean;
------------------------------------------------------------------
FUNCTION to_boolean(l : std_logic_vector) RETURN boolean IS

VARIABLE tmp : std_logic_vector(l'RANGE);
BEGIN
	tmp := (OTHERS=>'1');
	if to_integer(l AND tmp) /= 0 THEN
		RETURN TRUE;
	END IF;
	RETURN FALSE;

END to_boolean;

------------------------------------------------------------------
FUNCTION to_boolean(l : boolean) RETURN boolean IS

BEGIN
	IF ( l) THEN
		RETURN TRUE;
	END IF;
	RETURN FALSE;

END to_boolean;

------------------------------------------------------------------
FUNCTION to_boolean(l : integer) RETURN boolean IS

BEGIN
	IF ( l = 0 ) THEN
		RETURN FALSE;
	ELSE
		RETURN TRUE;
	END IF;

END to_boolean;

------------------------------------------------------------------

    FUNCTION "sll"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector IS
         VARIABLE v : std_logic_vector(l'RANGE) := (others=>'0');
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "srl"(l,-r);
	ELSIF r<l'LENGTH THEN
		IF l'LEFT<l'RIGHT THEN
			FOR i IN l'LEFT TO (l'RIGHT-r) LOOP
		 	  v(i) := l(i+r);
			END LOOP;
		ELSE
			FOR i IN l'LEFT DOWNTO (l'RIGHT+r) LOOP
		 	  v(i) := l(i-r);
			END LOOP;
		END IF;
	END IF;
	RETURN v;
    END;
	
    FUNCTION "sll"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector IS
         VARIABLE v : std_ulogic_vector(l'RANGE) := (others=>'0');
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "srl"(l,-r);
	ELSIF r<l'LENGTH THEN
		IF l'LEFT<l'RIGHT THEN
			FOR i IN l'LEFT TO (l'RIGHT-r) LOOP
		 	  v(i) := l(i+r);
			END LOOP;
		ELSE
			FOR i IN l'LEFT DOWNTO (l'RIGHT+r) LOOP
		 	  v(i) := l(i-r);
			END LOOP;
		END IF;
	END IF;
	RETURN v;
    END;
	
    FUNCTION "srl"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector IS
         VARIABLE v : std_logic_vector(l'RANGE) := (others=>'0');
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "sll"(l,-r);
	ELSIF r<l'LENGTH THEN
		IF l'LEFT<l'RIGHT THEN
			FOR i IN l'LEFT TO (l'RIGHT-r) LOOP
			   v(i+r) := l(i);
			END LOOP;
		ELSE
			FOR i IN l'LEFT DOWNTO (l'RIGHT+r) LOOP
			   v(i-r) := l(i);
			END LOOP;
		END IF;
	END IF;
	RETURN v;
    END;

    FUNCTION "srl"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector IS
         VARIABLE v : std_ulogic_vector(l'RANGE) := (others=>'0');
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "sll"(l,-r);
	ELSIF r<l'LENGTH THEN
		IF l'LEFT<l'RIGHT THEN
			FOR i IN l'LEFT TO (l'RIGHT-r) LOOP
			   v(i+r) := l(i);
			END LOOP;
		ELSE
			FOR i IN l'LEFT DOWNTO (l'RIGHT+r) LOOP
			   v(i-r) := l(i);
			END LOOP;
		END IF;
	END IF;
	RETURN v;
    END;

    FUNCTION "sla"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector IS
         VARIABLE v : std_logic_vector(l'RANGE) := (others=>l(l'RIGHT));
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "sra"(l,-r);
	ELSIF r<l'LENGTH THEN
		IF l'LEFT<l'RIGHT THEN
			FOR i IN l'LEFT TO (l'RIGHT-r) LOOP
		 	  v(i) := l(i+r);
			END LOOP;
		ELSE
			FOR i IN l'LEFT DOWNTO (l'RIGHT+r) LOOP
		 	  v(i) := l(i-r);
			END LOOP;
		END IF;
	END IF;
	RETURN v;
    END;
	
    FUNCTION "sla"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector IS
         VARIABLE v : std_ulogic_vector(l'RANGE) := (others=>l(l'RIGHT));
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "sra"(l,-r);
	ELSIF r<l'LENGTH THEN
		IF l'LEFT<l'RIGHT THEN
			FOR i IN l'LEFT TO (l'RIGHT-r) LOOP
		 	  v(i) := l(i+r);
			END LOOP;
		ELSE
			FOR i IN l'LEFT DOWNTO (l'RIGHT+r) LOOP
		 	  v(i) := l(i-r);
			END LOOP;
		END IF;
	END IF;
	RETURN v;
    END;
	
    FUNCTION "sra"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector IS
         VARIABLE v : std_logic_vector(l'RANGE) := (others=>l(l'RIGHT));
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "sla"(l,-r);
	ELSIF r<l'LENGTH THEN
		IF l'LEFT<l'RIGHT THEN
			FOR i IN l'LEFT TO (l'RIGHT-r) LOOP
			   v(i+r) := l(i);
			END LOOP;
		ELSE
			FOR i IN l'LEFT DOWNTO (l'RIGHT+r) LOOP
			   v(i-r) := l(i);
			END LOOP;
		END IF;
	END IF;
	RETURN v;
    END;
	
    FUNCTION "sra"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector IS
         VARIABLE v : std_ulogic_vector(l'RANGE) := (others=>l(l'RIGHT));
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "sla"(l,-r);
	ELSIF r<l'LENGTH THEN
		IF l'LEFT<l'RIGHT THEN
			FOR i IN l'LEFT TO (l'RIGHT-r) LOOP
			   v(i+r) := l(i);
			END LOOP;
		ELSE
			FOR i IN l'LEFT DOWNTO (l'RIGHT+r) LOOP
			   v(i-r) := l(i);
			END LOOP;
		END IF;
	END IF;
	RETURN v;
    END;
	
    FUNCTION "rol"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector IS
         VARIABLE v : std_logic_vector(0 TO l'LENGTH*2-1);
	 VARIABLE v1 : std_logic_vector(l'RANGE);
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "ror"(l,-r);
	ELSE
		v(0 TO l'LENGTH-1) := l;
		v(l'LENGTH TO v'LENGTH-1) := l;
		v1 := v(r TO r+l'LENGTH-1);
		RETURN v1;
	END IF;
    END;
	    FUNCTION "rol"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector IS
         VARIABLE v : std_ulogic_vector(0 TO l'LENGTH*2-1);
	 VARIABLE v1 : std_ulogic_vector(l'RANGE);
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "ror"(l,-r);
	ELSE
		v(0 TO l'LENGTH-1) := l;
		v(l'LENGTH TO v'LENGTH-1) := l;
		v1 := v(r TO r+l'LENGTH-1);
		RETURN v1;
	END IF;
    END;
	
    FUNCTION "ror"  ( l : std_logic_vector; r : integer) RETURN std_logic_vector IS
         VARIABLE v : std_logic_vector(0 TO l'LENGTH*2-1);
	 VARIABLE v1 : std_logic_vector(l'RANGE);
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "rol"(l,-r);
	ELSE
		v(0 TO l'LENGTH-1) := l;
		v(l'LENGTH TO v'LENGTH-1) := l;
		v1 := v(l'LENGTH-r TO v'LENGTH-r-1);
		RETURN v1;
	END IF;
    END;
    FUNCTION "ror"  ( l : std_ulogic_vector; r : integer) RETURN std_ulogic_vector IS
         VARIABLE v : std_ulogic_vector(0 TO l'LENGTH*2-1);
	 VARIABLE v1 : std_ulogic_vector(l'RANGE);
    BEGIN
	IF r=0 THEN
		RETURN l;
	ELSIF r<0 THEN
		RETURN "rol"(l,-r);
	ELSE
		v(0 TO l'LENGTH-1) := l;
		v(l'LENGTH TO v'LENGTH-1) := l;
		v1 := v(l'LENGTH-r TO v'LENGTH-r-1);
		RETURN v1;
	END IF;
    END;

FUNCTION to_stdlogicvector(hex : STRING) RETURN std_logic_vector IS
	VARIABLE result : std_logic_vector(4 * hex'LENGTH DOWNTO 1);
BEGIN
-- Note: The hex parameter can have a range with hex'LOW > 1.
-- For these cases, variable index i in assignments in the FOR loop is normalized
-- to 1 by subtracting hex'LOW	** sas 2/13/96 ** 
    FOR i in hex'RANGE LOOP
	CASE hex(i) IS
	WHEN '0' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"0";
	WHEN '1' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"1";
	WHEN '2' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"2";
	WHEN '3' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"3";
	WHEN '4' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"4";
	WHEN '5' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"5";
	WHEN '6' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"6";
	WHEN '7' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"7";
	WHEN '8' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"8";
	WHEN '9' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"9";
	WHEN 'A' | 'a' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"A";
	WHEN 'B' | 'b' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"B";
	WHEN 'C' | 'c' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"C";
	WHEN 'D' | 'd' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"D";
	WHEN 'E' | 'e' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"E";
	WHEN 'F' | 'f' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := x"F";
	WHEN 'X' | 'x' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := "XXXX";
	WHEN 'Z' | 'z' => 
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := "ZZZZ";
	WHEN OTHERS =>
	result(4*(hex'LENGTH - (i-hex'LOW)) DOWNTO 4*(hex'LENGTH - (i-hex'LOW)) -3) := "XXXX";
	END CASE;
    END LOOP;
    RETURN result;
END to_stdlogicvector;

end FUNCTIONS;


