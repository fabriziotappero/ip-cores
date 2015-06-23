-------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscompatible_package.all;
-------------------------------------------------------------------------------------------------------------------
entity RegisterBank is
    generic
    (
        NumBitsAddr : natural:=4;
        DataWidth   : natural:=32
    );
    port
    (
        Clk_I           : in std_logic;
        Enable_I        : in std_logic;
        Write_I         : in std_logic;
        RegisterW_I     : in std_logic_vector(NumBitsAddr-1 downto 0);
        Register1_I     : in std_logic_vector(NumBitsAddr-1 downto 0);
        Register2_I     : in std_logic_vector(NumBitsAddr-1 downto 0);
        InputData_I     : in std_logic_vector(DataWidth-1 downto 0);
        FT1OutputData_O : out std_logic_vector(DataWidth-1 downto 0);
        FT2OutputData_O : out std_logic_vector(DataWidth-1 downto 0)
    );
end RegisterBank;
-------------------------------------------------------------------------------------------------------------------
architecture behavioral of RegisterBank is
    type TMemory is array (natural range <> ) of TRiscoWord;
    signal Memory : TMemory (2**NumBitsAddr-1 downto 0):=(others=>(others=>'0'));
begin

process (Clk_I,Enable_I,Write_I,RegisterW_I,Register1_I,Register2_I,InputData_I,Memory)
begin
    if rising_edge(Clk_I) then
        if (Enable_I = '1') then 
            if (Write_I = '1') then
                if to_integer(unsigned(RegisterW_I))/=0 then -- Never write to R00!
                    Memory(to_integer(unsigned(RegisterW_I))) <= InputData_I;
                end if;
            end if;
        end if;
    end if;
    FT1OutputData_O <= Memory(to_integer(unsigned(Register1_I)));
    FT2OutputData_O <= Memory(to_integer(unsigned(Register2_I)));
end process;
end behavioral;
-------------------------------------------------------------------------------------------------------------------
