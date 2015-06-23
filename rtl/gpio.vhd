-------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscompatible_package.all;
-------------------------------------------------------------------------------------------------------------------
entity GPIO is
    generic
    (    
        NumBitsAddr        : natural:=1;
        NumBitsInputPorts  : natural:=2;
        NumBitsOutputPorts : natural:=2
    );
    port
    (
        Clk_I            : in  std_logic;
        Enable_I         : in  std_logic;
        Write_I          : in  std_logic;
        Address_I        : in  std_logic_vector(NumBitsAddr-1 downto 0);
        InputData_I      : in  std_logic_vector(C_NumBitsWord-1 downto 0);
        OutputData_O     : out std_logic_vector(C_NumBitsWord-1 downto 0);
        OutputData_Vld_O : out std_logic;
        InputPorts_I     : in  std_logic_vector(NumBitsInputPorts-1 downto 0);
        OutputPorts_O    : out std_logic_vector(NumBitsOutputPorts-1 downto 0)
    );
end GPIO;
-------------------------------------------------------------------------------------------------------------------
architecture behavioral of GPIO is
   function num_bits(num_io : integer) return integer is
   begin
      case num_io is
         when 0|1|2 =>
             return (1);
         when 3|4 =>
             return (2);
         when 5|6|7|8 =>
             return (3);
         when 9|10|11|12|13|14|15|16 =>
             return (4);
         when 17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32 =>
             return (5);
         when others => return (-1);
      end case;

   end function num_bits;
begin

process (Clk_I,Address_I)
begin
    if Clk_I'event and Clk_I = '1' then
        if (Enable_I = '1') then 
            if (Write_I = '1') and Address_I(Address_I'high)='1' then
                if to_integer(unsigned(Address_I(Address_I'high-1 downto 0))) * C_NumBitsWord < NumBitsOutputPorts then
                    for i in 0 to 31 loop
                        if to_integer(unsigned(Address_I(Address_I'high-1 downto 0))) * C_NumBitsWord + i < NumBitsOutputPorts then
                            OutputPorts_O(i) <= InputData_I(i);
                        end if;
                    end loop;
                end if;
            end if;
        end if;
        if Address_I(Address_I'high)='1' then
            OutputData_Vld_O <= '1';
        else
            OutputData_Vld_O <= '0';
        end if;
        for i in 0 to 31 loop
            if to_integer(unsigned(Address_I(Address_I'high-1 downto 0))) * C_NumBitsWord + i < NumBitsInputPorts then
                OutputData_O(i) <= InputPorts_I(i);
            else
                OutputData_O(i) <= '0';
            end if;
        end loop;
    end if;
end process;

end behavioral;
-------------------------------------------------------------------------------------------------------------------
