-------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------------------------------------------
package riscompatible_package is
    ---------------------------------------------
    constant C_NumBitsWord    : integer:=32;
    constant C_NumBitsRegBank : natural:=3;
    subtype TRiscoWord is std_logic_vector(C_NumBitsWord-1 downto 0);
    subtype TRiscoWordPlusCarry is std_logic_vector(C_NumBitsWord downto 0); -- Carry = bit 32
    ---------------------------------------------
    -- Flags
    ---------------------------------------------
    type TRiscoFlag is record
        Clr_I  : std_logic;
        Wen_I  : std_logic;
        Data_I : std_logic;
        Data_O : std_logic;
    end record;    
    ---------------------------------------------
    -- Registers
    ---------------------------------------------
    type TRiscoReg is record
        Clr_I  : std_logic;
        Wen_I  : std_logic;
        Data_I : std_logic_vector(C_NumBitsWord-1 downto 0);
        Data_O : std_logic_vector(C_NumBitsWord-1 downto 0);
    end record;    
    ---------------------------------------------
    -- Instruction Types
    ---------------------------------------------
    constant INST_ULA : std_logic_vector(1 downto 0):="00";
    constant INST_MEM : std_logic_vector(1 downto 0):="10";
    constant INST_JMP : std_logic_vector(1 downto 0):="01";
    constant INST_SUB : std_logic_vector(1 downto 0):="11";    
    ---------------------------------------------
    -- Arithmetic Logical Instructions
    ---------------------------------------------
    -- ALU
    constant C_AND      : std_logic_vector(4 downto 0):="01111";
    constant C_OR       : std_logic_vector(4 downto 0):="01110";
    constant C_XOR      : std_logic_vector(4 downto 0):="01101";
    
    constant C_SUBRC    : std_logic_vector(4 downto 0):="01011";
    constant C_SUBRCNOT : std_logic_vector(4 downto 0):="01010";
    constant C_SUBR     : std_logic_vector(4 downto 0):="01001";
    constant C_SUBRNC   : std_logic_vector(4 downto 0):="01000";
    
    constant C_SUBC     : std_logic_vector(4 downto 0):="00111";
    constant C_SUBCNOT  : std_logic_vector(4 downto 0):="00110";
    constant C_SUB      : std_logic_vector(4 downto 0):="00101";
    constant C_SUBNC    : std_logic_vector(4 downto 0):="00100";
    
    constant C_ADDCNOT  : std_logic_vector(4 downto 0):="00011";
    constant C_ADDC     : std_logic_vector(4 downto 0):="00010";
    constant C_ADD1     : std_logic_vector(4 downto 0):="00001";
    constant C_ADD      : std_logic_vector(4 downto 0):="00000";
    
    -- UD
    
    constant C_RLL      : std_logic_vector(4 downto 0):="10000";
    constant C_RLLC     : std_logic_vector(4 downto 0):="10001";
    constant C_RLA      : std_logic_vector(4 downto 0):="10010";
    constant C_RLAC     : std_logic_vector(4 downto 0):="10011";
    
    constant C_RRL      : std_logic_vector(4 downto 0):="10100";
    constant C_RRLC     : std_logic_vector(4 downto 0):="10101";
    constant C_RRA      : std_logic_vector(4 downto 0):="10110";
    constant C_RRAC     : std_logic_vector(4 downto 0):="10111";
    
    constant C_SLL      : std_logic_vector(4 downto 0):="11000";
    constant C_SLLC     : std_logic_vector(4 downto 0):="11001";
    constant C_SLA      : std_logic_vector(4 downto 0):="11010";
    constant C_SLAC     : std_logic_vector(4 downto 0):="11011";
    
    constant C_SRL      : std_logic_vector(4 downto 0):="11100";
    constant C_SRLC     : std_logic_vector(4 downto 0):="11101";
    constant C_SRA      : std_logic_vector(4 downto 0):="11110";
    constant C_SRAC     : std_logic_vector(4 downto 0):="11111";
        
    -- NOT PRESENT (PG 101,PG 220,PG 234): C_ADD1, C_ADDCNOT, C_SUBCNOT, C_SUBNC, C_SUBRNC, C_SUBRCNOT
    -- PRESENT ON PG 136
    ---------------------------------------------
    -- Memory Access Instructions
    ---------------------------------------------
    constant C_LD       : std_logic_vector(4 downto 0):="00000";
    constant C_LDPRI    : std_logic_vector(4 downto 0):="00111";
    constant C_LDPOI    : std_logic_vector(4 downto 0):="00101";
    constant C_LDPOD    : std_logic_vector(4 downto 0):="00100";
    constant C_ST       : std_logic_vector(4 downto 0):="10000";
    constant C_STPRI    : std_logic_vector(4 downto 0):="10111";
    constant C_STPOI    : std_logic_vector(4 downto 0):="10101";
    constant C_STPOD    : std_logic_vector(4 downto 0):="10100";
    ---------------------------------------------
    -- Conditions
    ---------------------------------------------
    constant C_TR     : std_logic_vector(4 downto 0):="11111";
    constant C_NS     : std_logic_vector(4 downto 0):="10001";
    constant C_CS     : std_logic_vector(4 downto 0):="10010";
    constant C_OS     : std_logic_vector(4 downto 0):="10100";
    constant C_ZS     : std_logic_vector(4 downto 0):="11000";
    constant C_GE     : std_logic_vector(4 downto 0):="10011";
    constant C_GT     : std_logic_vector(4 downto 0):="10110";
    constant C_EQ     : std_logic_vector(4 downto 0):="11100";
    
    constant C_FL     : std_logic_vector(4 downto 0):="00000";
    constant C_NN     : std_logic_vector(4 downto 0):="00001";
    constant C_NC     : std_logic_vector(4 downto 0):="00010";
    constant C_NO     : std_logic_vector(4 downto 0):="00100";
    constant C_NZ     : std_logic_vector(4 downto 0):="01000";
    constant C_LT     : std_logic_vector(4 downto 0):="00011";
    constant C_LE     : std_logic_vector(4 downto 0):="00110";
    constant C_NE     : std_logic_vector(4 downto 0):="01100";
    ---------------------------------------------
    -- Source Operands 
    ---------------------------------------------
    -- FT1 - Register number of source 1
    -- FT2 - Register number of source 2
    -- SS2 - Bit used to define format
    -- Kp  - Small constant, 11 bits, extends signal
    -- Kgl - Large constant, 17 bits, extends signal
    -- Kgh - Large constant, 16 bits, most significant part
    constant FFS_DST_FT1_FT2  : std_logic_vector(2 downto 0):="000";
    constant FFS_DST_FT1_Kp   : std_logic_vector(2 downto 0):="001";
    constant FFS_DST_R00_Kgl  : std_logic_vector(2 downto 0):="010";--01X
    constant FFS_DST_DST_Kgh  : std_logic_vector(2 downto 0):="100";--10X
    constant FFS_DST_DST_Kgl  : std_logic_vector(2 downto 0):="110";--11X
    ---------------------------------------------
    -- Specific Functions
    ---------------------------------------------
    --- CONSTEXT calculation
    function Kpe_F(Kp : std_logic_vector(10 downto 0)) return TRiscoWord;
    function Kgl_F(Kg : std_logic_vector(16 downto 0)) return TRiscoWord;
    function Kgh_F(Kg : std_logic_vector(16 downto 0)) return TRiscoWord;
    ---
    function IsZero_F(Source : std_logic_vector) return std_logic;
    ---------------------------------------------
    -- Components
    ---------------------------------------------
    component riscompatible_core is
        generic
        (
            NumBitsProgramMemory : Natural:=5;
            NumBitsDataMemory    : Natural:=5;
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
    end component;  
    component RegisterBank is
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
    end component;    
    component Ula is
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
    end component;
    component UD is
        port
        (
            InputData_I   : in TRiscoWord;
            ShiftAmount_I : in std_logic_vector(4 downto 0);
            OutputData_o  : out TRiscoWord;
            Function_I    : in std_logic_vector(4 downto 0);
            Cy_I          : in std_logic;
            Cy_O          : out std_logic
        );
    end component;
    component select_and_control is
        generic
        (
            NumBitsProgramMemory : Natural:=5;
            NumBitsDataMemory    : Natural:=5;
            NumBitsRegBank       : natural:=5
        );
        port
        (
            Clk_I                    : in std_logic;
            Reset_I                  : in std_logic;
            PMem_Enable_O            : out std_logic;
            PMem_Address_O           : out std_logic_vector(NumBitsProgramMemory - 1 downto 0);
            PMem_Write_O             : out std_logic;
            PMem_OutputData_I        : in TRiscoWord;
            DMem_Enable_O            : out std_logic;
            DMem_Write_O             : out std_logic;
            DMem_Address_O           : out std_logic_vector(NumBitsDataMemory - 1 downto 0);
            DMem_InputData_O         : out TRiscoWord;
            DMem_OutputData_I        : in TRiscoWord;
            RegBnk_Register1_O       : out std_logic_vector(NumBitsRegBank - 1 downto 0);
            RegBnk_Register2_O       : out std_logic_vector(NumBitsRegBank - 1 downto 0);
            RegBnk_RegisterW_O       : out std_logic_vector(NumBitsRegBank - 1 downto 0);
            RegBnk_Write_O           : out std_logic;
            RegBnk_InputData_O       : out TRiscoWord;
            RegBnk_FT1_OutputData_I  : in TRiscoWord;
            RegBnk_FT2_OutputData_I  : in TRiscoWord;
            ULA_Function_O           : out std_logic_vector(4 downto 0);
            ULA_Output_I             : in TRiscoWord;
            ULA_Ng_O_I               : in std_logic;
            ULA_Cy_O_I               : in std_logic;
            ULA_Ov_O_I               : in std_logic;
            ULA_Zr_O_I               : in std_logic;
            UD_Function_O            : out std_logic_vector(4 downto 0);
            UD_OutputData_I          : in TRiscoWord;
            UD_Cy_O_I                : in std_logic;
            RUA_Clr_O                : out std_logic;
            RUB_Clr_O                : out std_logic;
            RDA_Clr_O                : out std_logic;
            RDB_Clr_O                : out std_logic;
            RUA_Wen_O                : out std_logic;
            RUB_Wen_O                : out std_logic;
            RDA_Wen_O                : out std_logic;
            RDB_Wen_O                : out std_logic;
            RUA_Data_O               : out std_logic_vector(C_NumBitsWord - 1 downto 0);
            RUB_Data_O               : out std_logic_vector(C_NumBitsWord - 1 downto 0);
            RDA_Data_O               : out std_logic_vector(C_NumBitsWord - 1 downto 0);
            RDB_Data_O               : out std_logic_vector(C_NumBitsWord - 1 downto 0);
            PC_Clr_O                 : out std_logic;
            PC_Wen_O                 : out std_logic;
            PC_Data_I                : in std_logic_vector(C_NumBitsWord - 1 downto 0);
            PC_Data_O                : out std_logic_vector(C_NumBitsWord - 1 downto 0);
            PSW_Clr_O                : out std_logic;
            PSW_Wen_O                : out std_logic;
            PSW_Data_I               : in std_logic_vector(C_NumBitsWord - 1 downto 0);
            PSW_Data_O               : out std_logic_vector(C_NumBitsWord - 1 downto 0);
            Int_I                    : in std_logic;
            IntAck_O                 : out std_logic        
        );
    end component;
    component reg is
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
    end component;    
end package;
package body riscompatible_package is
    ---------------------------------------------
    -- Implementation  of functions
    ---------------------------------------------
    -- Extends signal of Kp 
    function Kpe_F(Kp : std_logic_vector(10 downto 0)) return TRiscoWord is
        variable VKpe : TRiscoWord;
    begin
        VKpe(10 downto 0):=Kp;
        VKpe(TRiscoWord'high downto 11):=(others=>Kp(10));
        return VKpe;
    end function Kpe_F;
    ---------------------------------------------
    -- Extends signal of Kg
    function Kgl_F(Kg : std_logic_vector(16 downto 0)) return TRiscoWord is
        variable VKgl : TRiscoWord;
    begin
        VKgl(16 downto 0):=Kg;
        VKgl(TRiscoWord'high downto 17):=(others=>Kg(16));
        return VKgl;
    end function Kgl_F;
    ---------------------------------------------
    -- Kg go to high order bits; low order bits receive the signal extension of Kg
    function Kgh_F(Kg : std_logic_vector(16 downto 0)) return TRiscoWord is
        variable VKgh : TRiscoWord;
    begin
        VKgh(31 downto 16):=Kg(15 downto 0);
        VKgh(15 downto 0):=(others=>Kg(16));
        return VKgh;
    end function Kgh_F;
    ---------------------------------------------
    -- Set if word is equal to zero
    function IsZero_F(Source : std_logic_vector) return std_logic is
        variable counter : integer range Source'range;
        variable accumulator : std_logic:='0';
    begin
        for counter in 0 to Source'high loop
            accumulator:=accumulator or Source(counter);
        end loop;
        return (not accumulator);
    end function IsZero_F;
end riscompatible_package;
-------------------------------------------------------------------------------------------------------------------
