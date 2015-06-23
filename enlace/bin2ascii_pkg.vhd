--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package bin2ascii_pkg is

  
  type <new_type> is
    record
        <type_name>        : std_logic_vector( 7 downto 0);
        <type_name>        : std_logic;
    end record;

-- Declare constants

  constant <constant_name>		: time := <time_unit> ns;
  constant <constant_name>		: integer := <value>;
 
-- Declare functions and procedure

  function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
  procedure <procedure_name>	(<type_declaration> <constant_name>	: in <type_declaration>);

end bin2ascii_pkg;


package body <Package_Name> is

-- Example 1
  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
    variable <variable_name>     : <type_declaration>;
  begin
    <variable_name> := <signal_name> xor <signal_name>);
    return <variable_name>; 
  end <function_name>;


-- Example 2
  function <function_name>  (signal <signal_name> : in <type_declaration>;
                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
  begin
    if (<signal_name> = '1') then
      return <signal_name>;
    else
      return 'Z';
    end if;
  end <function_name>;

-- Procedure Example
  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
    
  begin
    
  end <procedure_name>;
 
end bin2ascii_pkg;
