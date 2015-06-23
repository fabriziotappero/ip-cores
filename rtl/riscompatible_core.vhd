-------------------------------------------------------------------------------------------------------------------
-- ____________   _____   ___________   ___________   ___________ 
-- ||||        \ ||||  | ||||        | ||||        | ||||        |
-- ||||_____   | ||||  | ||||   _____| ||||   _____| ||||   __   |
-- ______||||  | ||||  | ||||  |_____  ||||  |       ||||  ||||  |
-- ||||        / ||||  | ||||        | ||||  |       ||||  ||||  |
-- ||||  ___   \ ||||  | ||||_____   | ||||  |       ||||  ||||  |
-- ||||  ||||  | ||||  | ______||||  | ||||  |_____  ||||  ||||  |
-- ||||  ||||  | ||||  | ||||        | ||||        | ||||        |
-- ||||__||||__| ||||__| ||||________| ||||________| ||||________|mpatible Core
--
-- RISCOmpatible - Implementation Based on the Instruction Set developed in:
-- "[1] RISCO - Microprocessador RISC CMOS de 32 Bits",
--      by Alexandre Ambrozi Junqueira and Altamiro Amadeu Suzim, 1993.
--      http://hdl.handle.net/10183/21530
-- HDL code by Andre Borin Soares
--
-- Current Features: Harvard architecture, single clock phase, multicycle operation.
--
-- USE THIS CODE AT YOUR OWN RISK !
-- HDL code 'as is' without warranty.  Author liable for nothing.
-------------------------------------------------------------------------------------------------------------------
-- Suffixes and prefixes used in the code:
-- _W - Wire
-- _R - Register
-- _F - Function
-- _O - Output
-- _I - Input
-- C_ - Constant
-------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.riscompatible_package.all;
-------------------------------------------------------------------------------------------------------------------
entity riscompatible_core is
    generic
    (
        NumBitsProgramMemory : natural:=5;
        NumBitsDataMemory    : natural:=5;
        NumBitsRegBank       : natural:=5
    );
    port
    (
        Clk_I             : in std_logic;
        Reset_I           : in std_logic;
        PMem_Enable_O     : out std_logic;
        PMem_Write_O      : out std_logic;
        PMem_Address_O    : out std_logic_vector(NumBitsProgramMemory-1 downto 0);
        PMem_InputData_O  : out TRiscoWord;
        PMem_OutputData_I : in TRiscoWord;
        DMem_Enable_O     : out std_logic;
        DMem_Write_O      : out std_logic;
        DMem_Address_O    : out std_logic_vector(NumBitsDataMemory-1 downto 0);
        DMem_InputData_O  : out TRiscoWord;
        DMem_OutputData_I : in TRiscoWord;
        Int_I             : in std_logic;
        IntAck_O          : out std_logic
    );
end riscompatible_core;
-------------------------------------------------------------------------------------------------------------------
architecture behavioral of riscompatible_core is
    ---------------------------------------------
    -- Registers
    ---------------------------------------------
    signal PSW_W : TRiscoReg;    
    signal PC_W  : TRiscoReg;    
    signal RUA_W : TRiscoReg;    
    signal RUB_W : TRiscoReg;    
    signal RDA_W : TRiscoReg;    
    signal RDB_W : TRiscoReg;
    ---------------------------------------------
    -- Wires
    ---------------------------------------------
    -- Register Bank Signals ------------------------------
    signal RegBnk_Write_W           : std_logic;
    signal RegBnk_RegisterW_W       : std_logic_vector(NumBitsRegBank - 1 downto 0);
    signal RegBnk_Register1_W       : std_logic_vector(NumBitsRegBank - 1 downto 0);
    signal RegBnk_Register2_W       : std_logic_vector(NumBitsRegBank - 1 downto 0);
    signal RegBnk_InputData_W       : TRiscoWord;
    signal RegBkn_FT1_OutputDatai_W : TRiscoWord;
    signal RegBkn_FT2_OutputDatai_W : TRiscoWord;
    -- ULA Signals ----------------------------------------
    alias  ULA_Cy_I_W       : std_logic is PSW_W.Data_O(4);
    signal ULA_Cy_O_W       : std_logic;
    signal ULA_Ng_O_W       : std_logic;     
    signal ULA_Ov_O_W       : std_logic;     
    signal ULA_Zr_O_W       : std_logic;     
    signal ULA_Function_W   : std_logic_vector(4 downto 0);
    signal ULA_Output_W     : TRiscoWord;
    -- UD Signals -----------------------------------------
    alias  UD_InputData_W   : TRiscoWord is RDA_W.Data_O;
    alias  UD_ShiftAmount_W : std_logic_vector(4 downto 0) is RDB_W.Data_O(4 downto 0);
    signal UD_OutputData_W  : TRiscoWord;
    signal UD_Function_W    : std_logic_vector(4 downto 0);
    alias  UD_Cy_I_W        : std_logic is PSW_W.Data_O(4);
    signal UD_Cy_O_W        : std_logic;     
    -------------------------------------------------------
begin

PMem_InputData_O <= (others => '0');

---------------------------------------------
-- Registers
---------------------------------------------

-- Flags
PSW1:reg generic map (NumBits => C_NumBitsWord) port map (Clk_I => Clk_I, Clr_I => PSW_W.Clr_I, Wen_I => PSW_W.Wen_I, Data_I => PSW_W.Data_I, Data_O => PSW_W.Data_O);

-- PC
PC1:reg generic map (NumBits => C_NumBitsWord) port map (Clk_I => Clk_I, Clr_I => PC_W.Clr_I, Wen_I => PC_W.Wen_I, Data_I => PC_W.Data_I, Data_O => PC_W.Data_O);

-- Ula Inputs
RUA1:reg generic map (NumBits => C_NumBitsWord) port map (Clk_I => Clk_I, Clr_I => RUA_W.Clr_I, Wen_I => RUA_W.Wen_I, Data_I => RUA_W.Data_I, Data_O => RUA_W.Data_O);
RUB1:reg generic map (NumBits => C_NumBitsWord) port map (Clk_I => Clk_I, Clr_I => RUB_W.Clr_I, Wen_I => RUB_W.Wen_I, Data_I => RUB_W.Data_I, Data_O => RUB_W.Data_O);

-- UD inputs
RDA1:reg generic map (NumBits => C_NumBitsWord) port map (Clk_I => Clk_I, Clr_I => RDA_W.Clr_I, Wen_I => RDA_W.Wen_I, Data_I => RDA_W.Data_I, Data_O => RDA_W.Data_O);
RDB1:reg generic map (NumBits => C_NumBitsWord) port map (Clk_I => Clk_I, Clr_I => RDB_W.Clr_I, Wen_I => RDB_W.Wen_I, Data_I => RDB_W.Data_I, Data_O => RDB_W.Data_O);

   
---------------------------------------------
-- Register Bank
---------------------------------------------
RegisterBank1: RegisterBank 
    generic map
    (
        NumBitsAddr => NumBitsRegBank,
        DataWidth => 32
    )
    port map
    (
        Clk_I           => Clk_I,
        Enable_I        => '1',
        Write_I         => RegBnk_Write_W,
        RegisterW_I     => RegBnk_RegisterW_W,
        Register1_I     => RegBnk_Register1_W,
        Register2_I     => RegBnk_Register2_W,
        InputData_I     => RegBnk_InputData_W,
        FT1OutputData_O => RegBkn_FT1_OutputDatai_W,
        FT2OutputData_O => RegBkn_FT2_OutputDatai_W
    );

---------------------------------------------
-- ULA - Arithmetic Logic Unit
---------------------------------------------
Ula1: Ula 
    port map
    (
        Cy_I       => ULA_Cy_I_W,
        Source1_I  => RUA_W.Data_O, 
        Source2_I  => RUB_W.Data_O, 
        Function_I => ULA_Function_W,
        Output_O   => ULA_Output_W,
        Cy_O       => ULA_Cy_O_W,
        Ov_O       => ULA_Ov_O_W,
        Zr_O       => ULA_Zr_O_W,
        Ng_O       => ULA_Ng_O_W
    );

---------------------------------------------
-- UD - Shift Unit
---------------------------------------------
UD1: UD
    port map
    (
        InputData_I   => UD_InputData_W,
        ShiftAmount_I => UD_ShiftAmount_W,
        OutputData_O  => UD_OutputData_W,
        Function_I    => UD_Function_W,
        Cy_I          => UD_Cy_I_W,
        Cy_O          => UD_Cy_O_W
    );

---------------------------------------------
-- Control and Signal Selectors
---------------------------------------------
SelectAndControl1 : select_and_control
    generic map
    (
        NumBitsProgramMemory => NumBitsProgramMemory,
        NumBitsDataMemory    => NumBitsDataMemory,
        NumBitsRegBank       => NumBitsRegBank
    )
    port map
    (
        Clk_I                   => Clk_I,
        Reset_I                 => Reset_I,
        PMem_Enable_O           => PMem_Enable_O,
        PMem_Address_O          => PMem_Address_O,
        PMem_Write_O            => PMem_Write_O,
        PMem_OutputData_I       => PMem_OutputData_I,
        DMem_Enable_O           => DMem_Enable_O,
        DMem_Write_O            => DMem_Write_O,
        DMem_Address_O          => DMem_Address_O,
        DMem_InputData_O        => DMem_InputData_O,
        DMem_OutputData_I       => DMem_OutputData_I,
        RegBnk_Register1_O      => RegBnk_Register1_W,
        RegBnk_Register2_O      => RegBnk_Register2_W,
        RegBnk_RegisterW_O      => RegBnk_RegisterW_W,
        RegBnk_Write_O          => RegBnk_Write_W,
        RegBnk_InputData_O      => RegBnk_InputData_W,
        RegBnk_FT1_OutputData_I => RegBkn_FT1_OutputDatai_W,
        RegBnk_FT2_OutputData_I => RegBkn_FT2_OutputDatai_W,
        ULA_Function_O          => ULA_Function_W,
        ULA_Output_I            => ULA_Output_W,
        ULA_Ng_O_I              => ULA_Ng_O_W,
        ULA_Cy_O_I              => ULA_Cy_O_W,
        ULA_Ov_O_I              => ULA_Ov_O_W,
        ULA_Zr_O_I              => ULA_Zr_O_W,
        UD_Function_O           => UD_Function_W,
        UD_OutputData_I         => UD_OutputData_W,
        UD_Cy_O_I               => UD_Cy_O_W,
        RUA_Clr_O               => RUA_W.Clr_I,
        RUB_Clr_O               => RUB_W.Clr_I,
        RDA_Clr_O               => RDA_W.Clr_I,
        RDB_Clr_O               => RDB_W.Clr_I,
        RUA_Wen_O               => RUA_W.Wen_I,
        RUB_Wen_O               => RUB_W.Wen_I,
        RDA_Wen_O               => RDA_W.Wen_I,
        RDB_Wen_O               => RDB_W.Wen_I,
        RUA_Data_O              => RUA_W.Data_I,
        RUB_Data_O              => RUB_W.Data_I,
        RDA_Data_O              => RDA_W.Data_I,
        RDB_Data_O              => RDB_W.Data_I,        
        PC_Clr_O                => PC_W.Clr_I,
        PC_Wen_O                => PC_W.Wen_I,
        PC_Data_I               => PC_W.Data_O,
        PC_Data_O               => PC_W.Data_I,
        PSW_Clr_O               => PSW_W.Clr_I,
        PSW_Wen_O               => PSW_W.Wen_I,
        PSW_Data_I              => PSW_W.Data_O,
        PSW_Data_O              => PSW_W.Data_I,
        Int_I                   => Int_I,
        IntAck_O                => IntAck_O
    );

end behavioral;
