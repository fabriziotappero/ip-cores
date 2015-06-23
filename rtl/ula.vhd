-------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscompatible_package.all;
-------------------------------------------------------------------------------------------------------------------
entity Ula is
    port
    (
        Cy_I       : in std_logic;
        Source1_I  : in TRiscoWord;
        Source2_I  : in TRiscoWord;
        Function_I : in std_logic_vector(4 downto 0);
        Output_O   : out TRiscoWord;
        Cy_O       : out std_logic;
        Ov_O       : out std_logic;
        Zr_O       : out std_logic;
        Ng_O       : out std_logic
    );
end Ula;
-------------------------------------------------------------------------------------------------------------------
architecture behavioral of ula is
    signal UlaTemp_W : std_logic_vector(32 downto 0);
    signal Carry_W : TRiscoWord;
begin
    Carry_W(0) <= Cy_I;
    Carry_W(TRiscoWord'high downto 1) <= (others => '0');
    with Function_I select
        -- Fig. 5.8 of [1]
        -- Carry -> bit 32
        UlaTemp_W <= 
                     ('0'&Source1_I) and ('0'&Source2_I)                                                                    when C_AND,
                     ('0'&Source1_I) or  ('0'&Source2_I)                                                                    when C_OR,
                     ('0'&Source1_I) xor ('0'&Source2_I)                                                                    when C_XOR,

                     std_logic_vector(unsigned('0'&not(Source1_I)) + unsigned('0'&Source2_I)      + unsigned(not(Carry_W))) when C_SUBRC,
                     std_logic_vector(unsigned('0'&not(Source1_I)) + unsigned('0'&Source2_I)      + unsigned(Carry_W)     ) when C_SUBRCNOT,
                     std_logic_vector(unsigned('0'&not(Source1_I)) + unsigned('0'&Source2_I)      + 1                     ) when C_SUBR,
                     std_logic_vector(unsigned('0'&not(Source1_I)) + unsigned('0'&Source2_I)      + 0                     ) when C_SUBRNC,

                     std_logic_vector(unsigned('0'&Source1_I)      + unsigned('0'&not(Source2_I)) + unsigned(not(Carry_W))) when C_SUBC,
                     std_logic_vector(unsigned('0'&Source1_I)      + unsigned('0'&not(Source2_I)) + unsigned(Carry_W)     ) when C_SUBCNOT,
                     std_logic_vector(unsigned('0'&Source1_I)      + unsigned('0'&not(Source2_I)) + 1                     ) when C_SUB,
                     std_logic_vector(unsigned('0'&Source1_I)      + unsigned('0'&not(Source2_I)) + 0                     ) when C_SUBNC,

                     std_logic_vector(unsigned('0'&Source1_I)      + unsigned('0'&Source2_I)      + unsigned(not(Carry_W))) when C_ADDCNOT,
                     std_logic_vector(unsigned('0'&Source1_I)      + unsigned('0'&Source2_I)      + unsigned(Carry_W)     ) when C_ADDC,
                     std_logic_vector(unsigned('0'&Source1_I)      + unsigned('0'&Source2_I)      + 1                     ) when C_ADD1,
                     std_logic_vector(unsigned('0'&Source1_I)      + unsigned('0'&Source2_I)      + 0                     ) when C_ADD,

                     (others => '0')                                                                                        when others;
    Output_O <= UlaTemp_W(Output_O'range);
    Cy_O <= UlaTemp_W(32);
    Ov_O <= UlaTemp_W(32);
    Zr_O <= IsZero_F(UlaTemp_W);
    Ng_O <= UlaTemp_W(31);
end behavioral;
-------------------------------------------------------------------------------------------------------------------
