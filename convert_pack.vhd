-- A package containing various conversion functions useful in testbenches,
-- especially when used with text file IO in reading and displaying
-- hexadecimal values.
--
-- Author           : Bill Grigsby
-- Modifications by : John Clayton
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package convert_pack is

------------------------------------------------------------------------------------
-- function calls
------------------------------------------------------------------------------------
    function string_to_integer (in_string : string) return integer ;
    function vector_to_string (in_vector : std_logic_vector) return string ;
    function char_to_bit (in_char : character) return std_logic ;
    function char_to_hex (in_char : character) return std_logic_vector ;

    function slv2string(in_vector : std_logic_vector; nibbles : natural) return string ; -- Name changed by John Clayton
    function u2string(in_vector : unsigned; nibbles : natural) return string ; -- Added by John Clayton
    function u2asciichar(in_vector : unsigned(7 downto 0)) return character ; -- Added by John Clayton
    function asciichar2u(in_char : character) return unsigned; -- Added by John Clayton

    function hex_to_ascii(in_vector : std_logic_vector; nibbles : natural) return string ;
    function u2ascii(in_vector : unsigned; nibbles : natural) return string ; -- Added by John Clayton
    function hex_data_wrd(in_vector : std_logic_vector) return string ;
    function hex_data_dblwrd(in_vector : std_logic_vector) return string ;
    function hex_data_dblwrdz(in_vector : std_logic_vector) return string ;

    function is_hex(c : character) return boolean;    -- Added by John Clayton
    function is_std_logic(c : character) return boolean;    -- Added by John Clayton
    function is_space(c : character) return boolean;  -- Added by John Clayton
    function char2sl(in_char : character) return std_logic;  -- Added by John Clayton
    function char2slv(in_char : character) return std_logic_vector;
    function char2u(in_char : character) return unsigned;
    function slv2u(in_a : std_logic_vector) return unsigned; -- Added by John Clayton
    function u2slv(in_a : unsigned) return std_logic_vector; -- Added by John Clayton
    function slv2s(in_a : std_logic_vector) return signed; -- Added by John Clayton
    function s2slv(in_a : signed) return std_logic_vector; -- Added by John Clayton
    function str2u(in_string : string; out_size:integer) return unsigned; -- Added by John Clayton
    function str2s(in_string : string; out_size:integer) return   signed; -- Added by John Clayton
    function "**"(in_a : natural; in_b : natural) return natural; -- Added by John Clayton
    function pow_2_u(in_a : natural; out_size:integer) return unsigned; -- Added by John Clayton
    function asr_function(in_vect : signed; in_a : natural) return signed; -- Added by John Clayton

    function slv_resize(in_vect : std_logic_vector; out_size : integer) return std_logic_vector; -- Added by John Clayton
    function slv_resize_l(in_vect : std_logic_vector; out_size : integer) return std_logic_vector; -- Added by John Clayton
    function slv_resize_se(in_vect : std_logic_vector; out_size : integer) return std_logic_vector; -- Added by John Clayton
    function s_resize(in_vect : signed; out_size : integer) return signed; -- Added by John Clayton
    function s_resize_l(in_vect : signed; out_size : integer) return signed; -- Added by John Clayton
    function s_resize_se(in_vect : signed; out_size : integer) return signed; -- Added by John Clayton
    function u_resize(in_vect : unsigned; out_size : integer) return unsigned; -- Added by John Clayton
    function u_resize_l(in_vect : unsigned; out_size : integer) return unsigned; -- Added by John Clayton
    function u_reverse(in_vect : unsigned) return unsigned; -- Added by John Clayton

    function u_recursive_parity ( x : unsigned ) return std_logic;

------------------------------------------------------------------------------------
-- procedures
------------------------------------------------------------------------------------


end convert_pack;


package body convert_pack is      

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------
--* Title           :  TEST_PARITY
--* Filename & Ext  :  test_parity.vhdl
--* Author          :  David Bishop X-66788
--* Created         :  3/18/97
--* Version         :  1.2
--* Revision Date   :  97/04/15
--* SCCSid          :  1.2 04/15/97 test_parity.vhdl
--* WORK Library    :  testchip
--* Mod History     :  
--* Description     :  This is a parity generator which is written recursively
--*                 :  It is designed to test the ability of Simulation and
--*                 :  Synthesis tools to check this capability.
--* Known Bugs      :  
--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


  function u_recursive_parity ( x : unsigned ) return std_logic is
    variable Upper, Lower : std_logic;
    variable Half : integer;
    variable BUS_int : unsigned( x'length-1 downto 0 );
    variable Result : std_logic;
  begin
    BUS_int := x;
    if ( BUS_int'length = 1 ) then
      Result := BUS_int ( BUS_int'left );
    elsif ( BUS_int'length = 2 ) then
      Result := BUS_int ( BUS_int'right ) xor BUS_int ( BUS_int'left );
    else
      Half := ( BUS_int'length + 1 ) / 2 + BUS_int'right;
      Upper := u_recursive_parity ( BUS_int ( BUS_int'left downto Half ));
      Lower := u_recursive_parity ( BUS_int ( Half - 1 downto BUS_int'right ));
      Result := Upper xor Lower;
    end if;
    return Result;
  end;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function vector_to_string (in_vector : std_logic_vector) return string is
	
    variable out_string : string(32 downto 1);
        
    begin
	
    	for i in in_vector'range loop
	    	if in_vector(i) = '1' then
		    	out_string(i+1) := '1';
    		elsif in_vector(i) = '0' then
	    		out_string(i+1) := '0';
            else
                assert false
                report " illegal bit vector to bit string"
                severity note;
    		end if;
    	end loop;
    	return out_string;

    end vector_to_string;      

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function string_to_integer (in_string : string) return integer is

    variable int : integer := 0;
    begin 
    
        for j in in_string'range loop
          case in_string(j) is
            when '0' => int := int;
            when '1' => int := int + (1 * 10**(j-1));
            when '2' => int := int + (2 * 10**(j-1));
            when '3' => int := int + (3 * 10**(j-1));
            when '4' => int := int + (4 * 10**(j-1));
            when '5' => int := int + (5 * 10**(j-1));
            when '6' => int := int + (6 * 10**(j-1));
            when '7' => int := int + (7 * 10**(j-1));
            when '8' => int := int + (8 * 10**(j-1));
            when '9' => int := int + (9 * 10**(j-1));
            when others =>           
                assert false
                report " illegal character to integer"
                severity note;
          end case;
        end loop;
        return  int;
    end string_to_integer;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function char_to_bit (in_char : character) return std_logic is
  
    variable out_bit : std_logic;
    
    begin
    
        if (in_char = '1') then
            out_bit := '1';
        elsif (in_char = '0') then
            out_bit := '0';
        else
            assert false
            report "illegal character to bit"
            severity note;
        end if;
        
        return out_bit;
    end char_to_bit;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------
    function char_to_hex (in_char : character) return std_logic_vector is

    variable out_vec : std_logic_vector(3 downto 0);

      
    begin   
            case in_char is
              when '0' => out_vec := "0000";
              when '1' => out_vec := "0001";
              when '2' => out_vec := "0010";
              when '3' => out_vec := "0011";
              when '4' => out_vec := "0100";
              when '5' => out_vec := "0101";
              when '6' => out_vec := "0110";
              when '7' => out_vec := "0111";
              when '8' => out_vec := "1000";
              when '9' => out_vec := "1001";
              when 'A' | 'a' => out_vec := "1010";
              when 'B' | 'b' => out_vec := "1011";
              when 'C' | 'c' => out_vec := "1100";
              when 'D' | 'd' => out_vec := "1101";
              when 'E' | 'e' => out_vec := "1110";
              when 'F' | 'f' => out_vec := "1111";
              when others =>
                assert false
                report " illegal character to hex"
                severity note;
          end case;
        return out_vec;
    end char_to_hex;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function slv2string(in_vector : std_logic_vector; nibbles : natural) return string is
    variable out_string : string(1 to nibbles);
    variable temp_in_vector : std_logic_vector(4*nibbles-1 downto 0);
    variable vector     : std_logic_vector(3 downto 0);
    
    begin
    temp_in_vector := in_vector(in_vector'length-1 downto in_vector'length-temp_in_vector'length);
        for i in 1 to nibbles loop
            vector := temp_in_vector((4*(nibbles-i)+3) downto 4*(nibbles-i));
            case vector is
                when "0000" => out_string(i) := '0';
                when "0001" => out_string(i) := '1';
                when "0010" => out_string(i) := '2';
                when "0011" => out_string(i) := '3';
                when "0100" => out_string(i) := '4';
                when "0101" => out_string(i) := '5';
                when "0110" => out_string(i) := '6';
                when "0111" => out_string(i) := '7';
                when "1000" => out_string(i) := '8';
                when "1001" => out_string(i) := '9';
                when "1010" => out_string(i) := 'A';
                when "1011" => out_string(i) := 'B';
                when "1100" => out_string(i) := 'C';
                when "1101" => out_string(i) := 'D';
                when "1110" => out_string(i) := 'E';
                when "1111" => out_string(i) := 'F';
                when others =>
                   out_string(i) := 'J';
                   assert false
                   report " illegal std_logic_vector to string"
                   severity note;
            end case;
        end loop;
        return out_string;
     end;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function u2string(in_vector : unsigned; nibbles : natural) return string is
    variable out_string     : string(1 to nibbles);
    variable temp_in_vector : unsigned(4*nibbles-1 downto 0);
    variable vector         : unsigned(3 downto 0);
    
    begin
    temp_in_vector := in_vector(in_vector'length-1 downto in_vector'length-temp_in_vector'length);
        for i in 1 to nibbles loop
            vector := temp_in_vector((4*(nibbles-i)+3) downto 4*(nibbles-i));
            case vector is
                when "0000" => out_string(i) := '0';
                when "0001" => out_string(i) := '1';
                when "0010" => out_string(i) := '2';
                when "0011" => out_string(i) := '3';
                when "0100" => out_string(i) := '4';
                when "0101" => out_string(i) := '5';
                when "0110" => out_string(i) := '6';
                when "0111" => out_string(i) := '7';
                when "1000" => out_string(i) := '8';
                when "1001" => out_string(i) := '9';
                when "1010" => out_string(i) := 'A';
                when "1011" => out_string(i) := 'B';
                when "1100" => out_string(i) := 'C';
                when "1101" => out_string(i) := 'D';
                when "1110" => out_string(i) := 'E';
                when "1111" => out_string(i) := 'F';
                when others =>
                   out_string(i) := 'U';
                   assert false report " illegal unsigned to string" severity note;
            end case;
        end loop;
        return out_string;
     end;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function u2asciichar(in_vector : unsigned(7 downto 0)) return character is
    variable out_char       : character;
    
    begin
      case in_vector is
          when "00001001" => out_char :=  HT; -- Horizontal Tab
          when "00100000" => out_char := ' ';
          when "00100001" => out_char := '!';
          when "00100010" => out_char := '"';
          when "00100011" => out_char := '#';
          when "00100100" => out_char := '$';
          when "00100101" => out_char := '%';
          when "00100110" => out_char := '&';
          when "00100111" => out_char := ''';
          when "00101000" => out_char := '(';
          when "00101001" => out_char := ')';
          when "00101010" => out_char := '*';
          when "00101011" => out_char := '+';
          when "00101100" => out_char := ',';
          when "00101101" => out_char := '-';
          when "00101110" => out_char := '.';
          when "00101111" => out_char := '/';
          when "00110000" => out_char := '0';
          when "00110001" => out_char := '1';
          when "00110010" => out_char := '2';
          when "00110011" => out_char := '3';
          when "00110100" => out_char := '4';
          when "00110101" => out_char := '5';
          when "00110110" => out_char := '6';
          when "00110111" => out_char := '7';
          when "00111000" => out_char := '8';
          when "00111001" => out_char := '9';
          when "00111010" => out_char := ':';
          when "00111011" => out_char := ';';
          when "00111100" => out_char := '<';
          when "00111101" => out_char := '=';
          when "00111110" => out_char := '>';
          when "00111111" => out_char := '?';
          when "01000000" => out_char := '@';
          when "01000001" => out_char := 'A';
          when "01000010" => out_char := 'B';
          when "01000011" => out_char := 'C';
          when "01000100" => out_char := 'D';
          when "01000101" => out_char := 'E';
          when "01000110" => out_char := 'F';
          when "01000111" => out_char := 'G';
          when "01001000" => out_char := 'H';
          when "01001001" => out_char := 'I';
          when "01001010" => out_char := 'J';
          when "01001011" => out_char := 'K';
          when "01001100" => out_char := 'L';
          when "01001101" => out_char := 'M';
          when "01001110" => out_char := 'N';
          when "01001111" => out_char := 'O';
          when "01010000" => out_char := 'P';
          when "01010001" => out_char := 'Q';
          when "01010010" => out_char := 'R';
          when "01010011" => out_char := 'S';
          when "01010100" => out_char := 'T';
          when "01010101" => out_char := 'U';
          when "01010110" => out_char := 'V';
          when "01010111" => out_char := 'W';
          when "01011000" => out_char := 'X';
          when "01011001" => out_char := 'Y';
          when "01011010" => out_char := 'Z';
          when "01011011" => out_char := '[';
          when "01011100" => out_char := '\';
          when "01011101" => out_char := ']';
          when "01011110" => out_char := '^';
          when "01011111" => out_char := '_';
          when "01100000" => out_char := '`';
          when "01100001" => out_char := 'a';
          when "01100010" => out_char := 'b';
          when "01100011" => out_char := 'c';
          when "01100100" => out_char := 'd';
          when "01100101" => out_char := 'e';
          when "01100110" => out_char := 'f';
          when "01100111" => out_char := 'g';
          when "01101000" => out_char := 'h';
          when "01101001" => out_char := 'i';
          when "01101010" => out_char := 'j';
          when "01101011" => out_char := 'k';
          when "01101100" => out_char := 'l';
          when "01101101" => out_char := 'm';
          when "01101110" => out_char := 'n';
          when "01101111" => out_char := 'o';
          when "01110000" => out_char := 'p';
          when "01110001" => out_char := 'q';
          when "01110010" => out_char := 'r';
          when "01110011" => out_char := 's';
          when "01110100" => out_char := 't';
          when "01110101" => out_char := 'u';
          when "01110110" => out_char := 'v';
          when "01110111" => out_char := 'w';
          when "01111000" => out_char := 'x';
          when "01111001" => out_char := 'y';
          when "01111010" => out_char := 'z';
          when "01111011" => out_char := '{';
          when "01111100" => out_char := '|';
          when "01111101" => out_char := '}';
          when "01111110" => out_char := '~';
          when others =>
             out_char := '*';
             --assert false report " illegal unsigned to ascii character" severity note;
      end case;
      return out_char;
     end;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function asciichar2u(in_char : character) return unsigned is
    variable out_vect : unsigned(7 downto 0);
    
    begin
      case in_char is
          when  HT => out_vect := "00001001";
          when ' ' => out_vect := "00100000";
          when '!' => out_vect := "00100001";
          when '"' => out_vect := "00100010";
          when '#' => out_vect := "00100011";
          when '$' => out_vect := "00100100";
          when '%' => out_vect := "00100101";
          when '&' => out_vect := "00100110";
          when ''' => out_vect := "00100111";
          when '(' => out_vect := "00101000";
          when ')' => out_vect := "00101001";
          when '*' => out_vect := "00101010";
          when '+' => out_vect := "00101011";
          when ',' => out_vect := "00101100";
          when '-' => out_vect := "00101101";
          when '.' => out_vect := "00101110";
          when '/' => out_vect := "00101111";
          when '0' => out_vect := "00110000";
          when '1' => out_vect := "00110001";
          when '2' => out_vect := "00110010";
          when '3' => out_vect := "00110011";
          when '4' => out_vect := "00110100";
          when '5' => out_vect := "00110101";
          when '6' => out_vect := "00110110";
          when '7' => out_vect := "00110111";
          when '8' => out_vect := "00111000";
          when '9' => out_vect := "00111001";
          when ':' => out_vect := "00111010";
          when ';' => out_vect := "00111011";
          when '<' => out_vect := "00111100";
          when '=' => out_vect := "00111101";
          when '>' => out_vect := "00111110";
          when '?' => out_vect := "00111111";
          when '@' => out_vect := "01000000";
          when 'A' => out_vect := "01000001";
          when 'B' => out_vect := "01000010";
          when 'C' => out_vect := "01000011";
          when 'D' => out_vect := "01000100";
          when 'E' => out_vect := "01000101";
          when 'F' => out_vect := "01000110";
          when 'G' => out_vect := "01000111";
          when 'H' => out_vect := "01001000";
          when 'I' => out_vect := "01001001";
          when 'J' => out_vect := "01001010";
          when 'K' => out_vect := "01001011";
          when 'L' => out_vect := "01001100";
          when 'M' => out_vect := "01001101";
          when 'N' => out_vect := "01001110";
          when 'O' => out_vect := "01001111";
          when 'P' => out_vect := "01010000";
          when 'Q' => out_vect := "01010001";
          when 'R' => out_vect := "01010010";
          when 'S' => out_vect := "01010011";
          when 'T' => out_vect := "01010100";
          when 'U' => out_vect := "01010101";
          when 'V' => out_vect := "01010110";
          when 'W' => out_vect := "01010111";
          when 'X' => out_vect := "01011000";
          when 'Y' => out_vect := "01011001";
          when 'Z' => out_vect := "01011010";
          when '[' => out_vect := "01011011";
          when '\' => out_vect := "01011100";
          when ']' => out_vect := "01011101";
          when '^' => out_vect := "01011110";
          when '_' => out_vect := "01011111";
          when '`' => out_vect := "01100000";
          when 'a' => out_vect := "01100001";
          when 'b' => out_vect := "01100010";
          when 'c' => out_vect := "01100011";
          when 'd' => out_vect := "01100100";
          when 'e' => out_vect := "01100101";
          when 'f' => out_vect := "01100110";
          when 'g' => out_vect := "01100111";
          when 'h' => out_vect := "01101000";
          when 'i' => out_vect := "01101001";
          when 'j' => out_vect := "01101010";
          when 'k' => out_vect := "01101011";
          when 'l' => out_vect := "01101100";
          when 'm' => out_vect := "01101101";
          when 'n' => out_vect := "01101110";
          when 'o' => out_vect := "01101111";
          when 'p' => out_vect := "01110000";
          when 'q' => out_vect := "01110001";
          when 'r' => out_vect := "01110010";
          when 's' => out_vect := "01110011";
          when 't' => out_vect := "01110100";
          when 'u' => out_vect := "01110101";
          when 'v' => out_vect := "01110110";
          when 'w' => out_vect := "01110111";
          when 'x' => out_vect := "01111000";
          when 'y' => out_vect := "01111001";
          when 'z' => out_vect := "01111010";
          when '{' => out_vect := "01111011";
          when '|' => out_vect := "01111100";
          when '}' => out_vect := "01111101";
          when '~' => out_vect := "01111110";
          when others =>
             out_vect := "00101010";
             --assert false report " illegal char to unsigned" severity note;
      end case;
      return out_vect;
     end;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------
    function char2slv (in_char : character) return std_logic_vector is

    variable out_vec : std_logic_vector(3 downto 0);
      
    begin   
      case in_char is
        when '0' => out_vec := "0000";
        when '1' => out_vec := "0001";
        when '2' => out_vec := "0010";
        when '3' => out_vec := "0011";
        when '4' => out_vec := "0100";
        when '5' => out_vec := "0101";
        when '6' => out_vec := "0110";
        when '7' => out_vec := "0111";
        when '8' => out_vec := "1000";
        when '9' => out_vec := "1001";
        when 'A' | 'a' => out_vec := "1010";
        when 'B' | 'b' => out_vec := "1011";
        when 'C' | 'c' => out_vec := "1100";
        when 'D' | 'd' => out_vec := "1101";
        when 'E' | 'e' => out_vec := "1110";
        when 'F' | 'f' => out_vec := "1111";
        when others =>
          out_vec := "0000";
      end case;
      return out_vec;
    end char2slv;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------
    function char2u(in_char : character) return unsigned is

    variable out_vec : unsigned(3 downto 0);
      
    begin   
      case in_char is
        when '0' => out_vec := "0000";
        when '1' => out_vec := "0001";
        when '2' => out_vec := "0010";
        when '3' => out_vec := "0011";
        when '4' => out_vec := "0100";
        when '5' => out_vec := "0101";
        when '6' => out_vec := "0110";
        when '7' => out_vec := "0111";
        when '8' => out_vec := "1000";
        when '9' => out_vec := "1001";
        when 'A' | 'a' => out_vec := "1010";
        when 'B' | 'b' => out_vec := "1011";
        when 'C' | 'c' => out_vec := "1100";
        when 'D' | 'd' => out_vec := "1101";
        when 'E' | 'e' => out_vec := "1110";
        when 'F' | 'f' => out_vec := "1111";
        when others =>
          out_vec := "0000";
      end case;
      return out_vec;
    end char2u;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function hex_to_ascii(in_vector : std_logic_vector; nibbles : natural) return string is
    variable out_string : string(1 to nibbles);
    variable temp_in_vector : std_logic_vector(4*nibbles-1 downto 0);
    variable vector     : std_logic_vector(3 downto 0);
    
    begin
    temp_in_vector := in_vector(in_vector'length-1 downto in_vector'length-temp_in_vector'length);
        for i in 1 to nibbles loop
            vector := temp_in_vector((4*(nibbles-i)+3) downto 4*(nibbles-i));
            case vector is
                when "0000" => out_string(i) := '0';
                when "0001" => out_string(i) := '1';
                when "0010" => out_string(i) := '2';
                when "0011" => out_string(i) := '3';
                when "0100" => out_string(i) := '4';
                when "0101" => out_string(i) := '5';
                when "0110" => out_string(i) := '6';
                when "0111" => out_string(i) := '7';
                when "1000" => out_string(i) := '8';
                when "1001" => out_string(i) := '9';
                when "1010" => out_string(i) := 'A';
                when "1011" => out_string(i) := 'B';
                when "1100" => out_string(i) := 'C';
                when "1101" => out_string(i) := 'D';
                when "1110" => out_string(i) := 'E';
                when "1111" => out_string(i) := 'F';
                when others =>
                   out_string(i) := 'J';
                   assert false
                   report " illegal std_logic_vector to string"
                   severity note;
            end case;
        end loop;
        return out_string;
     end;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function u2ascii(in_vector : unsigned; nibbles : natural) return string is
    variable out_string     : string(1 to nibbles);
    variable temp_in_vector : unsigned(4*nibbles-1 downto 0);
    variable vector         : unsigned(3 downto 0);
    
    begin
    temp_in_vector := in_vector(in_vector'length-1 downto in_vector'length-temp_in_vector'length);
        for i in 1 to nibbles loop
            vector := temp_in_vector((4*(nibbles-i)+3) downto 4*(nibbles-i));
            case vector is
                when "0000" => out_string(i) := '0';
                when "0001" => out_string(i) := '1';
                when "0010" => out_string(i) := '2';
                when "0011" => out_string(i) := '3';
                when "0100" => out_string(i) := '4';
                when "0101" => out_string(i) := '5';
                when "0110" => out_string(i) := '6';
                when "0111" => out_string(i) := '7';
                when "1000" => out_string(i) := '8';
                when "1001" => out_string(i) := '9';
                when "1010" => out_string(i) := 'A';
                when "1011" => out_string(i) := 'B';
                when "1100" => out_string(i) := 'C';
                when "1101" => out_string(i) := 'D';
                when "1110" => out_string(i) := 'E';
                when "1111" => out_string(i) := 'F';
                when others =>
                   out_string(i) := 'U';
                   assert false report " illegal unsigned to string" severity note;
            end case;
        end loop;
        return out_string;
     end;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function hex_data_wrd(in_vector : std_logic_vector) return string is
    variable out_string : string(1 to 8);
    variable temp_in_vector : std_logic_vector(31 downto 0);
    variable vector     : std_logic_vector(3 downto 0);
    
    begin
    temp_in_vector := in_vector;
        for i in 1 to 8 loop
            vector := temp_in_vector((35-(4*i)) downto (32-(4*i)));
            case vector is
                when "0000" => out_string(i) := '0';
                when "0001" => out_string(i) := '1';
                when "0010" => out_string(i) := '2';
                when "0011" => out_string(i) := '3';
                when "0100" => out_string(i) := '4';
                when "0101" => out_string(i) := '5';
                when "0110" => out_string(i) := '6';
                when "0111" => out_string(i) := '7';
                when "1000" => out_string(i) := '8';
                when "1001" => out_string(i) := '9';
                when "1010" => out_string(i) := 'A';
                when "1011" => out_string(i) := 'B';
                when "1100" => out_string(i) := 'C';
                when "1101" => out_string(i) := 'D';
                when "1110" => out_string(i) := 'E';
                when "1111" => out_string(i) := 'F';
                when others =>
                   out_string(i) := 'J';
                   assert false
                   report " illegal std_logic_vector to string"
                   severity note;
            end case;
        end loop;
        return out_string;
     end;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function hex_data_dblwrd(in_vector : std_logic_vector) return string is
    variable out_string : string(1 to 16);
    variable temp_in_vector : std_logic_vector(63 downto 0);
    variable vector     : std_logic_vector(3 downto 0);
    
    begin
    temp_in_vector := in_vector;
        for i in 1 to 16 loop
            vector := temp_in_vector((67-(4*i)) downto (64-(4*i)));
            case vector is
                when "0000" => out_string(i) := '0';
                when "0001" => out_string(i) := '1';
                when "0010" => out_string(i) := '2';
                when "0011" => out_string(i) := '3';
                when "0100" => out_string(i) := '4';
                when "0101" => out_string(i) := '5';
                when "0110" => out_string(i) := '6';
                when "0111" => out_string(i) := '7';
                when "1000" => out_string(i) := '8';
                when "1001" => out_string(i) := '9';
                when "1010" => out_string(i) := 'A';
                when "1011" => out_string(i) := 'B';
                when "1100" => out_string(i) := 'C';
                when "1101" => out_string(i) := 'D';
                when "1110" => out_string(i) := 'E';
                when "1111" => out_string(i) := 'F';
                when others =>
                   out_string(i) := 'J';
                   assert false
                   report " illegal std_logic_vector to string"
                   severity note;
            end case;
        end loop;
        return out_string;
     end;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function hex_data_dblwrdz(in_vector : std_logic_vector) return string is
    variable out_string : string(1 to 16);
    variable temp_in_vector : std_logic_vector(63 downto 0);
    variable vector     : std_logic_vector(3 downto 0);
    
    begin
    temp_in_vector := in_vector;
        for i in 1 to 16 loop
            vector := temp_in_vector((67-(4*i)) downto (64-(4*i)));
            case vector is
                when "0000" => out_string(i) := '0';
                when "0001" => out_string(i) := '1';
                when "0010" => out_string(i) := '2';
                when "0011" => out_string(i) := '3';
                when "0100" => out_string(i) := '4';
                when "0101" => out_string(i) := '5';
                when "0110" => out_string(i) := '6';
                when "0111" => out_string(i) := '7';
                when "1000" => out_string(i) := '8';
                when "1001" => out_string(i) := '9';
                when "1010" => out_string(i) := 'A';
                when "1011" => out_string(i) := 'B';
                when "1100" => out_string(i) := 'C';
                when "1101" => out_string(i) := 'D';
                when "1110" => out_string(i) := 'E';
                when "1111" => out_string(i) := 'F';
                when "ZZZZ" => out_string(i) := 'Z';
                when others =>
                   out_string(i) := 'J';
                   assert false
                   report " illegal std_logic_vector to string"
                   severity note;
            end case;
        end loop;
        return out_string;
     end;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------
    -- returns true if the character is a valid hexadecimal character.
    function is_hex(c : character) return boolean is
    begin
      case c is
        when '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' |
             'A' | 'B' | 'C' | 'D' | 'E' | 'F' | 'a' | 'b' | 'c' | 'd' | 
             'e' | 'f' =>
          return(true);
        when others =>
          return(false);
      end case;
    end is_hex;
      
------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------
    -- returns true if the character is a valid hexadecimal character.
    function is_std_logic(c : character) return boolean is
    begin
      case c is
        when '0' | '1' | 'u' | 'U' | 'x' | 'X' | 'z' | 'Z' =>
          return(true);
        when others =>
          return(false);
      end case;
    end is_std_logic;
      
------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------
    -- returns true if the character is whitespace.
    function is_space(c : character) return boolean is
    begin
      case c is
        when ' ' | HT =>
          return(true);
        when others =>
          return(false);
      end case;
    end is_space;
      
------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function char2sl(in_char : character) return std_logic is
  
    variable out_bit : std_logic;
    
    begin
    
        if (in_char = '1') then
            out_bit := '1';
        elsif (in_char = '0') then
            out_bit := '0';
        elsif (in_char = 'x') then
            out_bit := 'X';
        elsif (in_char = 'X') then
            out_bit := 'X';
        elsif (in_char = 'u') then
            out_bit := 'U';
        elsif (in_char = 'U') then
            out_bit := 'U';
        elsif (in_char = 'z') then
            out_bit := 'Z';
        elsif (in_char = 'Z') then
            out_bit := 'Z';
        else
            assert false
            report "illegal character to std_logic"
            severity note;
        end if;

-- Mysteriously, the following code did not work in place of the
-- above chain of if-elsif-else logic... it seemed to always return '1'.
-- I cannot tell why. -- John Clayton
--        case in_char is
--          when '1' =>
--            out_bit:= '1';
--          when '0' =>
--            out_bit:= '1';
--          when 'u' | 'U' =>
--            out_bit:= 'U';
--          when 'x' | 'X' =>
--            out_bit:= 'X';
--          when 'z' | 'Z' =>
--            out_bit:= 'Z';
--          when others =>
--            assert false
--            report "illegal character to std_logic"
--            severity note;
--        end case;
        
        return out_bit;
    end char2sl;



------------------------------------------------------------------------------------
-- Converts Standard Logic Vectors to Unsigned
------------------------------------------------------------------------------------

  function slv2u(in_a : std_logic_vector) return unsigned is
  variable i : natural;
  variable o : unsigned(in_a'length-1 downto 0);

  begin
  
  o := (others=>'0');
  for i in 0 to in_a'length-1 loop
      o(i) := in_a(i);
  end loop;
  
  return(o);
  
  end;

------------------------------------------------------------------------------------
-- Converts Unsigned to Standard Logic Vector
------------------------------------------------------------------------------------

  function u2slv(in_a : unsigned) return std_logic_vector is
  variable i : natural;
  variable o : std_logic_vector(in_a'length-1 downto 0);

  begin
  
  o := (others=>'0');
  for i in 0 to in_a'length-1 loop
      o(i) := in_a(i);
  end loop;
  
  return(o);
  
  end;

------------------------------------------------------------------------------------
-- Converts Standard Logic Vectors to Signed
------------------------------------------------------------------------------------

  function slv2s(in_a : std_logic_vector) return signed is
  variable i : natural;
  variable o : signed(in_a'length-1 downto 0);

  begin
  
  o := (others=>'0');
  for i in 0 to in_a'length-1 loop
      o(i) := in_a(i);
  end loop;
  
  return(o);
  
  end;

------------------------------------------------------------------------------------
-- Converts Signed to Standard Logic Vector
------------------------------------------------------------------------------------

  function s2slv(in_a : signed) return std_logic_vector is
  variable i : natural;
  variable o : std_logic_vector(in_a'length-1 downto 0);

  begin
  
  o := (others=>'0');
  for i in 0 to in_a'length-1 loop
      o(i) := in_a(i);
  end loop;
  
  return(o);
  
  end;

------------------------------------------------------------------------------------
-- Resizes Standard Logic Vectors, "right justified" i.e. starts at LSB...
------------------------------------------------------------------------------------

  function slv_resize(in_vect : std_logic_vector; out_size : integer) return std_logic_vector is
  variable i      : integer;
  variable o_vect : std_logic_vector(out_size-1 downto 0);

  begin
  
  o_vect := (others=>'0');
  for i in 0 to in_vect'length-1 loop
    if (i<out_size) then
      o_vect(i) := in_vect(i);
    end if;
  end loop;
  
  return(o_vect);
  
  end slv_resize;

------------------------------------------------------------------------------------
-- Resizes Standard Logic Vectors, "left justified" i.e. starts at MSB...
------------------------------------------------------------------------------------

  function slv_resize_l(in_vect : std_logic_vector; out_size : integer) return std_logic_vector is
  variable i      : integer;
  variable j      : integer;
  variable o_vect : std_logic_vector(out_size-1 downto 0);

  begin
  
  o_vect := (others=>'0');
  j := out_size-1;
  for i in in_vect'length-1 downto 0 loop
    if (j>=0) then
      o_vect(j) := in_vect(i);
      j := j-1;
    end if;
  end loop;
  
  return(o_vect);
  
  end slv_resize_l;

------------------------------------------------------------------------------------
-- Resizes Standard Logic Vectors, "right justified with sign extension"
------------------------------------------------------------------------------------

  function slv_resize_se(in_vect : std_logic_vector; out_size : integer) return std_logic_vector is
  variable i      : integer;
  variable o_vect : std_logic_vector(out_size-1 downto 0);

  begin
  
  o_vect := (others=>in_vect(in_vect'length-1));
  for i in 0 to in_vect'length-1 loop
    if (i<out_size) then
      o_vect(i) := in_vect(i);
    end if;
  end loop;
  
  return(o_vect);
  
  end slv_resize_se;

------------------------------------------------------------------------------------
-- Resizes Signed, "right justified" i.e. starts at LSB...
------------------------------------------------------------------------------------

  function s_resize(in_vect : signed; out_size : integer) return signed is
  variable i      : integer;
  variable o_vect : signed(out_size-1 downto 0);

  begin
  
  o_vect := (others=>'0');
  for i in 0 to in_vect'length-1 loop
    if (i<out_size) then
      o_vect(i) := in_vect(i);
    end if;
  end loop;
  
  return(o_vect);
  
  end s_resize;

------------------------------------------------------------------------------------
-- Resizes Signed, "left justified" i.e. starts at MSB...
------------------------------------------------------------------------------------

  function s_resize_l(in_vect : signed; out_size : integer) return signed is
  variable i      : integer;
  variable j      : integer;
  variable o_vect : signed(out_size-1 downto 0);

  begin
  
  o_vect := (others=>'0');
  j := out_size-1;
  for i in in_vect'length-1 downto 0 loop
    if (j>=0) then
      o_vect(j) := in_vect(i);
      j := j-1;
    end if;
  end loop;
  
  return(o_vect);
  
  end s_resize_l;

------------------------------------------------------------------------------------
-- Resizes Signed, "right justified with sign extension"
------------------------------------------------------------------------------------

  function s_resize_se(in_vect : signed; out_size : integer) return signed is
  variable i      : integer;
  variable o_vect : signed(out_size-1 downto 0);

  begin
  
  o_vect := (others=>in_vect(in_vect'length-1));
  for i in 0 to in_vect'length-1 loop
    if (i<out_size) then
      o_vect(i) := in_vect(i);
    end if;
  end loop;
  
  return(o_vect);
  
  end s_resize_se;

------------------------------------------------------------------------------------
-- Resizes Unsigned, "right justified" i.e. starts at LSB...
------------------------------------------------------------------------------------

  function u_resize(in_vect : unsigned; out_size : integer) return unsigned is
  variable i      : integer;
  variable i_vect : unsigned(in_vect'length-1 downto 0);
  variable o_vect : unsigned(out_size-1 downto 0);

  begin
  i_vect := in_vect;
  o_vect := (others=>'0');
  for i in 0 to in_vect'length-1 loop
    if (i<out_size) then
      o_vect(i) := i_vect(i);
    end if;
  end loop;
  
  return(o_vect);
  
  end u_resize;

------------------------------------------------------------------------------------
-- Resizes Unsigned, "left justified" i.e. starts at MSB...
------------------------------------------------------------------------------------

  function u_resize_l(in_vect : unsigned; out_size : integer) return unsigned is
  variable i      : integer;
  variable j      : integer;
  variable o_vect : unsigned(out_size-1 downto 0);

  begin
  
  o_vect := (others=>'0');
  j := out_size-1;
  for i in in_vect'length-1 downto 0 loop
    if (j>=0) then
      o_vect(j) := in_vect(i);
      j := j-1;
    end if;
  end loop;
  
  return(o_vect);
  
  end u_resize_l;

------------------------------------------------------------------------------------
-- Bit Reverses the input vector
------------------------------------------------------------------------------------

  function u_reverse(in_vect : unsigned) return unsigned is
  variable i      : integer;
  variable o_vect : unsigned(in_vect'length-1 downto 0);

  begin
  
  for i in in_vect'length-1 downto 0 loop
    o_vect(in_vect'length-1-i) := in_vect(i);
  end loop;
  
  return(o_vect);
  
  end u_reverse;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function str2u(in_string : string; out_size:integer) return unsigned is

    variable uval   : unsigned(out_size-1 downto 0);
    variable nibble : unsigned(3 downto 0);
    begin 
      uval := (others=>'0');
      for j in in_string'range loop
        uval(uval'length-1 downto 4) := uval(uval'length-5 downto 0);
        uval(3 downto 0) := char2u(in_string(j));
      end loop;
      return uval;
    end str2u;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

    function str2s(in_string : string; out_size:integer) return signed is

    variable uval   : signed(out_size-1 downto 0);
    variable nibble : signed(3 downto 0);
    begin 
      uval := (others=>'0');
      for j in in_string'range loop
        uval(uval'length-1 downto 4) := uval(uval'length-5 downto 0);
        uval(3 downto 0) := signed(char2u(in_string(j)));
      end loop;
      return uval;
    end str2s;

------------------------------------------------------------------------------------
-- Power Function for naturals
------------------------------------------------------------------------------------

  function "**"(in_a : natural; in_b : natural) return natural is
  variable i : natural;
  variable o : natural;

  begin

  -- Coded with a for loop: works in simulation, but Synplify will not synthesize.
--  if (in_b=0) then
--    o := 1;
--  else
--    o := in_a;
--    if (in_b>1) then
--      for i in 2 to in_b loop
--        o := o * in_a;
--      end loop;
--    end if;
--  end if;  
--  return(o);
  
  if (in_b=0) then
    o := 1;
  else
    o := in_a;
    i := 1;
    while (i<in_b) loop
      o := o * in_a;
      i := i+1;
    end loop;
  end if;  
  return(o);

  end;

------------------------------------------------------------------------------------
-- Function for 2^(natural)
------------------------------------------------------------------------------------

  function pow_2_u(in_a : natural; out_size:integer) return unsigned is
  variable i : natural;
  variable j : natural;
  variable o : unsigned(out_size-1 downto 0);

  begin

  j := in_a;
  o := to_unsigned(1,o'length);
  for i in 0 to out_size-1 loop
    if (j>0) then
      o := o(out_size-2 downto 0) & '0';
      j := j-1;
    end if;
  end loop;
  return(o);
  
  end;

------------------------------------------------------------------------------------
-- A sort of "barrel shifter."  Produces the ASR by in_a of the input...
------------------------------------------------------------------------------------

  function asr_function(in_vect : signed; in_a : natural) return signed is
  variable i      : natural;
  variable j      : natural;
  variable o_vect : signed(in_vect'length-1 downto 0);

  begin
  
  o_vect := in_vect;
  j := in_a;
  for i in 0 to in_vect'length-1 loop -- Now loop to fill in the actual results
    if (j>0) then
      o_vect := o_vect(o_vect'length-1) & o_vect(o_vect'length-1 downto 1);
      j := j-1;
    end if;
  end loop;
  
  return(o_vect);
  
  end asr_function;

------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------

end convert_pack;



