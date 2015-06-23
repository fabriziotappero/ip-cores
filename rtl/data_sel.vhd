-------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.riscompatible_package.all;
-------------------------------------------------------------------------------------------------------------------
entity data_sel is
    port
    (
        DMEM_OutputData_I : in TRiscoWord;
        GPIO_OutputData_I : in TRiscoWord;
        OutputData_Vld_I  : in std_logic;
        MSPC_OutputData_O : out TRiscoWord
    );
end data_sel;
-------------------------------------------------------------------------------------------------------------------
architecture ark1 of data_sel is
    
begin
    MSPC_OutputData_O <= DMEM_OutputData_I when OutputData_Vld_I = '0' else
                         GPIO_OutputData_I;
end ark1;
-------------------------------------------------------------------------------------------------------------------
