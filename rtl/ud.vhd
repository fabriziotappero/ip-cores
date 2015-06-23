-------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscompatible_package.all;
use work.ud_package.all;
-------------------------------------------------------------------------------------------------------------------
entity UD is
    port
    (
        InputData_I   : in TRiscoWord;
        ShiftAmount_I : in std_logic_vector(4 downto 0);
        OutputData_o  : out TRiscoWord;
        Function_I    : in std_logic_vector(4 downto 0);
        Cy_I          : in std_logic;
        Cy_O          : out std_logic
    );
end UD;
-------------------------------------------------------------------------------------------------------------------
architecture behavioral of UD is
    signal OutputData_w : TRiscoWordPlusCarry;
begin
    with Function_I select
        OutputData_w <= 
                        Cy_I & SRL_F(InputData_I,ShiftAmount_I)        when C_SRL,
                        Cy_I & SLL_F(InputData_I,ShiftAmount_I)        when C_SLL,
                        Cy_I & SRA_F(InputData_I,ShiftAmount_I)        when C_SRA,
                        Cy_I & SLA_F(InputData_I,ShiftAmount_I)        when C_SLA,
                        Cy_I & RRL_F(InputData_I,ShiftAmount_I)        when C_RRL,
                        Cy_I & RLL_F(InputData_I,ShiftAmount_I)        when C_RLL,
                        Cy_I & RRA_F(InputData_I,ShiftAmount_I)        when C_RRA,
                        Cy_I & RLA_F(InputData_I,ShiftAmount_I)        when C_RLA,
                         SRLC_F(InputData_I,ShiftAmount_I,Cy_I)        when C_SRLC,
                         SLLC_F(InputData_I,ShiftAmount_I,Cy_I)        when C_SLLC,
                         SRAC_F(InputData_I,ShiftAmount_I,Cy_I)        when C_SRAC,
                         SLAC_F(InputData_I,ShiftAmount_I,Cy_I)        when C_SLAC,
                         RRLC_F(InputData_I,ShiftAmount_I,Cy_I)        when C_RRLC,
                         RLLC_F(InputData_I,ShiftAmount_I,Cy_I)        when C_RLLC,
                         RRAC_F(InputData_I,ShiftAmount_I,Cy_I)        when C_RRAC,
                         RLAC_F(InputData_I,ShiftAmount_I,Cy_I)        when C_RLAC,
                                                (others => '0')        when others;
                                                
    OutputData_O <= OutputData_w(OutputData_O'high downto 0);
    Cy_O <= OutputData_w(OutputData_w'high);
end behavioral;
-------------------------------------------------------------------------------------------------------------------
