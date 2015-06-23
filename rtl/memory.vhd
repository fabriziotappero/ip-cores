-------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscompatible_package.all;
-- synopsys translate_off;
use std.textio.all;
use ieee.std_logic_textio.all;
-- synopsys translate_on;
-------------------------------------------------------------------------------------------------------------------
entity Memory is
    generic
    (
-- synopsys translate_off;
        FileName    : String:="dummie.txt";
-- synopsys translate_on;        
        NumBitsAddr : natural:=4;
        DataWidth   : natural:=32
    );
    port
    (
        Clk_I        : in std_logic;
        Enable_I     : in std_logic;
        Write_I      : in std_logic;
        Address_I    : in std_logic_vector(NumBitsAddr-1 downto 0);
        InputData_I  : in std_logic_vector(DataWidth-1 downto 0);
        OutputData_O : out std_logic_vector(DataWidth-1 downto 0)
    );
end Memory;
-------------------------------------------------------------------------------------------------------------------
architecture behavioral of Memory is
-- synopsys translate_off;
    file arq_in_0 : TEXT open READ_MODE is FileName;
-- synopsys translate_on;
    type TMemory is array (natural range <> ) of TRiscoWord;
    signal Memory : TMemory (2**NumBitsAddr-1 downto 0) := (others => (others=>'Z'));
begin

process (Clk_I,Address_I)
-- synopsys translate_off;
    variable file_line : LINE := NULL;
    variable dvalue    : std_logic_vector(31 downto 0);
    variable counter,i   : integer:=0;
-- synopsys translate_on;
begin
    if Clk_I'event and Clk_I = '1' then
        if (Enable_I = '1') then 
            if (Write_I = '1') then
                Memory(to_integer(unsigned(Address_I))) <= InputData_I;
            end if;
-- synopsys translate_off;
        else
            while not endfile(arq_in_0) loop
                readline(arq_in_0, file_line); --read line of file
                Hread(file_line,dvalue);       --extract value from line
                Memory(counter)<=dvalue;
                counter:=counter+1;
            end loop;
-- synopsys translate_on;
        end if;
        OutputData_O <= Memory(to_integer(unsigned(Address_I)));
    end if;
end process;

end behavioral;
-------------------------------------------------------------------------------------------------------------------
