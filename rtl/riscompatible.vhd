-------------------------------------------------------------------------------------------------------------------
-- ____________   _____   ___________   ___________   ___________ 
-- ||||        \ ||||  | ||||        | ||||        | ||||        |
-- ||||_____   | ||||  | ||||   _____| ||||   _____| ||||   __   |
-- ______||||  | ||||  | ||||  |_____  ||||  |       ||||  ||||  |
-- ||||        / ||||  | ||||        | ||||  |       ||||  ||||  |
-- ||||  ___   \ ||||  | ||||_____   | ||||  |       ||||  ||||  |
-- ||||  ||||  | ||||  | ______||||  | ||||  |_____  ||||  ||||  |
-- ||||  ||||  | ||||  | ||||        | ||||        | ||||        |
-- ||||__||||__| ||||__| ||||________| ||||________| ||||________|mpatible
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
entity riscompatible is
    generic
    (
        NumBitsProgramMemory : Natural:=5;
        NumBitsDataMemory    : Natural:=5;
        NumBitsRegBank       : natural:=5;
        NumBitsInputPorts    : natural:=2;
        NumBitsOutputPorts   : natural:=2        
    );
    port
    (
        Clk_I         : in  std_logic;
        Reset_I       : in  std_logic;
        Int_I         : in  std_logic;
        IntAck_O      : out std_logic;
        InputPorts_I  : in  std_logic_vector(NumBitsInputPorts-1 downto 0);
        OutputPorts_O : out std_logic_vector(NumBitsOutputPorts-1 downto 0)
    );
end riscompatible;
-------------------------------------------------------------------------------------------------------------------
architecture behavioral of riscompatible is
    ---------------------------------------------
    -- Wires
    ---------------------------------------------
    -- Program Memory Signals -----------------------------
    signal PMem_Enable_W     : std_logic;
    signal PMem_Write_W      : std_logic;
    signal PMem_Address_W    : std_logic_vector(NumBitsProgramMemory-1 downto 0);
    signal PMem_InputData_W  : TRiscoWord;
    signal PMem_OutputData_W : TRiscoWord;
    -- Data Memory Signals --------------------------------
    signal DMem_Enable_W     : std_logic;
    signal DMem_Write_W      : std_logic;
    signal DMem_Address_W    : std_logic_vector(NumBitsDataMemory-1 downto 0);
    signal DMem_InputData_W  : TRiscoWord;
    signal DMem_OutputData_W : TRiscoWord;  
    -------------------------------------------------------
    signal GPIO_OutputData_W : TRiscoWord;  
    signal MSPC_OutputData_W : TRiscoWord;  
    signal OutputData_Vld_W  : std_logic;
    -------------------------------------------------------
    component GPIO is
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
    end component;
    component Memory is
        generic
        (
            FileName    : String:="dummy.txt";
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
    end component;  
	 component data_sel is
        port
        (
            DMEM_OutputData_I : in TRiscoWord;
            GPIO_OutputData_I : in TRiscoWord;
            OutputData_Vld_I  : in std_logic;
            MSPC_OutputData_O : out TRiscoWord
        );
    end component;
begin

---------------------------------------------
-- Program Memory
---------------------------------------------
u_Program_Memory: Memory
    generic map
    (
        FileName    => "../../bench/program.txt",
        NumBitsAddr => NumBitsProgramMemory,
        DataWidth   => 32
    )
    port map
    (
        Clk_I        => Clk_I,        
        Enable_I     => PMem_Enable_W,     
        Write_I      => PMem_Write_W,      
        Address_I    => PMem_Address_W,    
        InputData_I  => PMem_InputData_W,
        OutputData_O => PMem_OutputData_W
    );

---------------------------------------------
-- Data Memory
---------------------------------------------
u_Data_Memory: Memory
    generic map
    (
        FileName    => "../../bench/data.txt",
        NumBitsAddr => NumBitsDataMemory-1,
        DataWidth   => 32
    )
    port map
    (
        Clk_I        => Clk_I,        
        Enable_I     => DMem_Enable_W,     
        Write_I      => DMem_Write_W,      
        Address_I    => DMem_Address_W(NumBitsDataMemory-2 downto 0),    
        InputData_I  => DMem_InputData_W,
        OutputData_O => DMem_OutputData_W
    );

---------------------------------------------
-- Risco Core
---------------------------------------------
u_Riscompatible_Core: Riscompatible_Core
    generic map
    (
        NumBitsProgramMemory => NumBitsProgramMemory,
        NumBitsDataMemory    => NumBitsDataMemory,
        NumBitsRegBank       => NumBitsRegBank
    )
    port map
    (
        Clk_I             => Clk_I,
        Reset_I           => Reset_I,
        PMem_Enable_O     => PMem_Enable_W,
        PMem_Write_O      => PMem_Write_W,
        PMem_Address_O    => PMem_Address_W,
        PMem_InputData_O  => PMem_InputData_W,
        PMem_OutputData_I => PMem_OutputData_W,
        DMem_Enable_O     => DMem_Enable_W,
        DMem_Write_O      => DMem_Write_W,
        DMem_Address_O    => DMem_Address_W,
        DMem_InputData_O  => DMem_InputData_W,
        DMem_OutputData_I => MSPC_OutputData_W,
        Int_I             => Int_I,
        IntAck_O          => IntAck_O
    );    
---------------------------------------------
-- GPIO
---------------------------------------------    
u_GPIO: GPIO
    generic map
    (    
        NumBitsAddr        => NumBitsDataMemory,
        NumBitsInputPorts  => NumBitsInputPorts,
        NumBitsOutputPorts => NumBitsOutputPorts
    )
    port map
    (
        Clk_I            => Clk_I,
        Enable_I         => DMem_Enable_W,
        Write_I          => DMem_Write_W,
        Address_I        => DMem_Address_W,
        InputData_I      => DMem_InputData_W,
        OutputData_O     => GPIO_OutputData_W,
        OutputData_Vld_O => OutputData_Vld_W,
        InputPorts_I     => InputPorts_I,
        OutputPorts_O    => OutputPorts_O
    );
    
u_data_sel: data_sel
        port map
        (
            DMEM_OutputData_I => DMEM_OutputData_W,
            GPIO_OutputData_I => GPIO_OutputData_W,
            OutputData_Vld_I  => OutputData_Vld_W,
            MSPC_OutputData_O => MSPC_OutputData_W
        );

end behavioral;
