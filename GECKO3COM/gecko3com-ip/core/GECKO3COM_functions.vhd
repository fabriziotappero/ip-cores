--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
use IEEE.STD_LOGIC_1164.all;


library work;
use work.USB_TMC_IP_Defs.all;
use work.USB_TMC_cmp.all;


package USB_TMC_func is

  
--  type <new_type> is
--    record
--        <type_name>        : std_logic_vector( 7 downto 0);
--        <type_name>        : std_logic;
--    end record;
--
---- Declare constants
--
--  constant <constant_name>		: time := <time_unit> ns;
--  constant <constant_name>		: integer := <value>;
-- 
---- Declare functions and procedure
--
--  function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
--  procedure <procedure_name>	(<type_declaration> <constant_name>	: in <type_declaration>);

procedure rst_header_Reg  (signal reg : out tHeaderReg);

procedure wr_header_Reg_element (variable bl : in integer;
                                 signal data : in std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
                                 signal reg : out tHeaderReg);

procedure rd_header_Reg_element (variable bl : in integer;
                                 signal reg : in tHeaderReg;
                                 signal data : out std_logic_vector(SIZE_DBUS_GPIF-1 downto 0));


end USB_TMC_func;


package body USB_TMC_func is
--
---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;
--
--
---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;
--
---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;

procedure rst_header_Reg  (signal reg : out tHeaderReg) is

  begin
  	 reg.MsgID   <= (others => '0');
	 reg.bTag    <= (others => '0');
	 reg.bTagInv <= (others => '0');
	 reg.res1    <= (others => '0');
	 reg.TfSize  <= (others => '0');
	 reg.bmTfAtt <= (others => '0');
    reg.GPByte1 <= (others => '0');
	 reg.GPByte2 <= (others => '0');
	 reg.GPByte3 <= (others => '0');
	 
end rst_header_Reg;

procedure wr_header_Reg_element (variable bl : in integer;
                                 signal data : in std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
                                 signal reg : out tHeaderReg) is

begin
	case bl is
     
	  when 0 =>
	         reg.MsgID   <= data(BYTE-1 downto 0);
	         reg.bTag    <= data((2*BYTE)-1 downto BYTE);
	  when 1 =>
	         reg.bTagInv <= data(BYTE-1 downto 0);
	         reg.res1    <= data((2*BYTE)-1 downto BYTE);
	  when 2 =>
	         reg.TfSize((2*BYTE)-1 downto 0)      <= data;
	  when 3 =>
	         reg.TfSize((4*BYTE)-1 downto 2*BYTE) <= data;
	  when 4 =>
	         reg.bmTfAtt <= data(BYTE-1 downto 0);
	         reg.GPByte1 <= data((2*BYTE)-1 downto BYTE);
	  when 5 =>
	         reg.GPByte2 <= data(BYTE-1 downto 0);
	         reg.GPByte3 <= data((2*BYTE)-1 downto BYTE);
	  when others =>
   end case;
end wr_header_Reg_element;



procedure rd_header_Reg_element (variable bl : in integer;
                                 signal reg : in tHeaderReg;
                                 signal data : out std_logic_vector(SIZE_DBUS_GPIF-1 downto 0)) is

   begin
	
	case bl is
	  when 0 =>
	         data <= reg.MsgID & reg.bTag;
	  when 1 =>
	         data <= reg.bTagInv & reg.res1;
	  when 2 =>
	         data <= reg.TfSize((2*BYTE)-1 downto 0);
	  when 3 =>
	         data <= reg.TfSize((4*BYTE)-1 downto 2*BYTE);
	  when 4 =>
	         data <= reg.bmTfAtt & reg.GPByte1;
	  when 5 =>
	         data <= reg.GPByte2 & reg.GPByte3;
	  when others =>
            data <= (others => 'X');
	end case;
	
end rd_header_Reg_element;

 
end USB_TMC_func;
