--
----- package mem3 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

PACKAGE mem3 IS
   TYPE mem_type_5 IS array (Integer range <>) OF std_logic_vector(17 downto 0);
   TYPE mem_type_6 IS array (Integer range <>) OF std_logic_vector(15 downto 0);
   FUNCTION hex2bin (hex: character) RETURN std_logic_vector;
   FUNCTION str3_slv12 (hex: string) RETURN std_logic_vector;
   FUNCTION data2data (data_w: integer) RETURN integer;
   FUNCTION data2addr_w (data_w: integer) RETURN integer;
   FUNCTION data2data_w (data_w: integer) RETURN integer;
   FUNCTION init_ram (hex: string; DATA_WIDTH_A : integer; DATA_WIDTH_B : integer) RETURN std_logic_vector;
   FUNCTION init_ram1 (hex: string) RETURN mem_type_6;
   FUNCTION str2slv (str: in string) RETURN std_logic_vector;
   FUNCTION Valid_Address (IN_ADDR : in std_logic_vector) return boolean;
END mem3;
PACKAGE BODY mem3 IS

   FUNCTION hex2bin (hex: character) RETURN std_logic_vector IS
        VARIABLE result : std_logic_vector (3 downto 0);
   BEGIN
        CASE hex IS
          WHEN '0' =>
             result := "0000";
          WHEN '1' =>
             result := "0001";
          WHEN '2' =>
             result := "0010";
          WHEN '3' =>
             result := "0011";
          WHEN '4' =>
             result := "0100";
          WHEN '5' =>
             result := "0101";
          WHEN '6' =>
             result := "0110";
          WHEN '7' =>
             result := "0111";
          WHEN '8' =>
             result := "1000";
          WHEN '9' =>
             result := "1001";
          WHEN 'A'|'a' =>
             result := "1010";
          WHEN 'B'|'b' =>
             result := "1011";
          WHEN 'C'|'c' =>
             result := "1100";
          WHEN 'D'|'d' =>
             result := "1101";
          WHEN 'E'|'e' =>
             result := "1110";
          WHEN 'F'|'f' =>
             result := "1111";
          WHEN 'X'|'x' =>
             result := "XXXX";
          WHEN others =>
             NULL;
        END CASE;
        RETURN result;
   END;

   FUNCTION str5_slv18 (s : string(5 downto 1)) return std_logic_vector is
        VARIABLE result : std_logic_vector(17 downto 0);
   BEGIN
       FOR i in 0 to 3 LOOP
          result(((i+1)*4)-1 downto (i*4)) := hex2bin(s(i+1));
       END LOOP;
          result(17 downto 16) := hex2bin(s(5))(1 downto 0);
       RETURN result;
   END;

   FUNCTION str4_slv16 (s : string(4 downto 1)) return std_logic_vector is
        VARIABLE result : std_logic_vector(15 downto 0);
   BEGIN
       FOR i in 0 to 3 LOOP
          result(((i+1)*4)-1 downto (i*4)) := hex2bin(s(i+1));
       END LOOP;
       RETURN result;
   END;

   FUNCTION str3_slv12 (hex: string) return std_logic_vector is
        VARIABLE result : std_logic_vector(11 downto 0);
   BEGIN
       FOR i in 0 to 2 LOOP
          result(((i+1)*4)-1 downto (i*4)) := hex2bin(hex(i+1));
       END LOOP;
       RETURN result;
   END;

   FUNCTION data2addr_w (data_w : integer) return integer is
        VARIABLE result : integer;
   BEGIN
        CASE data_w IS
          WHEN 1 =>
             result := 13;
          WHEN 2 =>
             result := 12;
          WHEN 4 =>
             result := 11;
          WHEN 9 =>
             result := 10;
          WHEN 18 =>
             result := 9;
          WHEN 36 =>
             result := 8;
          WHEN others =>
             NULL;
        END CASE;
       RETURN result;
   END;

   FUNCTION data2data_w (data_w : integer) return integer is
        VARIABLE result : integer;
   BEGIN
        CASE data_w IS
          WHEN 1 =>
             result := 1;
          WHEN 2 =>
             result := 2;
          WHEN 4 =>
             result := 4;
          WHEN 9 =>
             result := 9;
          WHEN 18 =>
             result := 18;
          WHEN 36 =>
             result := 18;
          WHEN others =>
             NULL;
        END CASE;
       RETURN result;
   END;

   FUNCTION data2data (data_w : integer) return integer is
        VARIABLE result : integer;
   BEGIN
        CASE data_w IS
          WHEN 1 =>
             result := 8;
          WHEN 2 =>
             result := 4;
          WHEN 4 =>
             result := 2;
          WHEN 9 =>
             result := 36864;
          WHEN 18 =>
             result := 36864;
          WHEN 36 =>
             result := 36864;
          WHEN others =>
             NULL;
        END CASE;
       RETURN result;
   END;

   FUNCTION init_ram (hex: string; DATA_WIDTH_A : integer; DATA_WIDTH_B : integer) RETURN std_logic_vector IS
        CONSTANT length : integer := hex'length;
        VARIABLE result1 : mem_type_5 (0 to ((length/5)-1));
        VARIABLE result : std_logic_vector(((length*18)/5)-1 downto 0);
   BEGIN
       FOR i in 0 to ((length/5)-1) LOOP
         result1(i) := str5_slv18(hex((i+1)*5 downto (i*5)+1));
       END LOOP;
       IF (DATA_WIDTH_A >= 9 and DATA_WIDTH_B >= 9) THEN
          FOR j in 0 to 511 LOOP
            result(((j*18) + 17) downto (j*18)) := result1(j)(17 downto 0);
          END LOOP;
       ELSE
          FOR j in 0 to 511 LOOP
            result(((j*18) + 7) downto (j*18)) := result1(j)(7 downto 0);
            result((j*18) + 8) := '0';
            result(((j*18) + 16) downto ((j*18) + 9)) := result1(j)(15 downto 8);
            result((j*18) + 17) := '0';
          END LOOP;
       END IF;
       RETURN result;
   END;

   FUNCTION init_ram1 (hex: string) RETURN mem_type_6 IS
        CONSTANT length : integer := hex'length;
        VARIABLE result : mem_type_6 (0 to ((length/4)-1));
   BEGIN
       FOR i in 0 to ((length/4)-1) LOOP
         result(i) := str4_slv16(hex((i+1)*4 downto (i*4)+1));
       END LOOP;
       RETURN result;
   END;

-- String to std_logic_vector

  FUNCTION str2slv (
      str : in string
  ) return std_logic_vector is

  variable j : integer := str'length;
  variable slv : std_logic_vector (str'length downto 1);

  begin
      for i in str'low to str'high loop
          case str(i) is
              when '0' => slv(j) := '0';
              when '1' => slv(j) := '1';
              when 'X' => slv(j) := 'X';
              when 'U' => slv(j) := 'U';
              when others => slv(j) := 'X';
          end case;
          j := j - 1;
      end loop;
      return slv;
  end str2slv;

function Valid_Address (
    IN_ADDR : in std_logic_vector
 ) return boolean is

    variable v_Valid_Flag : boolean := TRUE;

begin

    for i in IN_ADDR'high downto IN_ADDR'low loop
        if (IN_ADDR(i) /= '0' and IN_ADDR(i) /= '1') then
            v_Valid_Flag := FALSE;
        end if;
    end loop;

    return v_Valid_Flag;
end Valid_Address;

END mem3 ;
