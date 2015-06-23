library ieee;
use ieee.std_logic_1164.all;
-------------------------------------------------------------------------------------------------------------------
entity reg is
    generic
    (
        NumBits : Natural:=5
    );
    port
    (
        Clk_I : in std_logic;
        Clr_I : in std_logic;
        Wen_I : in std_logic;
        Data_I : in std_logic_vector (NumBits-1 downto 0);
        Data_O : out std_logic_vector (NumBits-1 downto 0)
    );
end reg;
-------------------------------------------------------------------------------------------------------------------
architecture ark1 of reg is
begin
    process (Clk_I)
        variable Data_v : std_logic_vector (Numbits-1 downto 0);
    begin
        if rising_edge(Clk_I) then
            if Clr_I = '1' then
                Data_v := (others => '0');
            elsif Wen_I = '1' then
                Data_v := Data_i;
            end if;
        end if;
        Data_O <= Data_v;
    end process;
end ark1;
