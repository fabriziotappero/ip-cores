library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscompatible_package.all;
-------------------------------------------------------------------------------------------------------------------
entity select_and_control is
    generic
    (
        NumBitsProgramMemory : natural:=5;
        NumBitsDataMemory    : natural:=5;
        NumBitsRegBank       : natural:=5
    );
    port
    (
        Clk_I                    : in std_logic;
        Reset_I                  : in std_logic;
        PMem_Enable_O            : out std_logic;
        PMem_Address_O           : out std_logic_vector(NumBitsProgramMemory-1 downto 0);
        PMem_Write_O             : out std_logic;
        PMem_OutputData_I        : in TRiscoWord;
        DMem_Enable_O            : out std_logic;        
        DMem_Write_O             : out std_logic;
        DMem_Address_O           : out std_logic_vector(NumBitsDataMemory-1 downto 0);
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
        ULA_Ng_O_I               : in std_logic; -- Negative
        ULA_Cy_O_I               : in std_logic; -- Carry
        ULA_Ov_O_I               : in std_logic; -- Overflow
        ULA_Zr_O_I               : in std_logic; -- Zero
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
        RUA_Data_O               : out std_logic_vector(C_NumBitsWord-1 downto 0);
        RUB_Data_O               : out std_logic_vector(C_NumBitsWord-1 downto 0);
        RDA_Data_O               : out std_logic_vector(C_NumBitsWord-1 downto 0);
        RDB_Data_O               : out std_logic_vector(C_NumBitsWord-1 downto 0);
        PC_Clr_O                 : out std_logic;
        PC_Wen_O                 : out std_logic;
        PC_Data_I                : in std_logic_vector(C_NumBitsWord-1 downto 0);
        PC_Data_O                : out std_logic_vector(C_NumBitsWord-1 downto 0);
        PSW_Clr_O                : out std_logic;
        PSW_Wen_O                : out std_logic;
        PSW_Data_I               : in std_logic_vector(C_NumBitsWord-1 downto 0);
        PSW_Data_O               : out std_logic_vector(C_NumBitsWord-1 downto 0);
        Int_I                    : in std_logic;
        IntAck_O                 : out std_logic        
    );
end select_and_control;
-------------------------------------------------------------------------------------------------------------------
architecture Ark1 of select_and_control is
    ---------------------------------------------
    -- Special Registers
    ---------------------------------------------
    constant C_R00      : integer range 0 to 31:=0;
    constant C_PSW      : integer range 0 to 31:=1;
    constant C_PC       : integer range 0 to 31:=2**NumBitsRegBank - 1;
    constant C_SPISR    : integer range 0 to 31:=C_PC - 1; -- SP of the Interrupt Service Routine
    ---------------------------------------------
    alias InterruptEnable_w : std_logic is PSW_Data_I(8);
    ---------------------------------------------
    signal DMem_Address_W : std_logic_vector(NumBitsDataMemory-1 downto 0);
    ---------------------------------------------
    procedure p_DecomposeInstructionIntoFields
    (
        PMemOutputData_I  : in TRiscoWord;
        T1_T0_O           : out std_logic_vector(1 downto 0);      
        C4_C0_O           : out std_logic_vector(4 downto 0);      
        F1_F0_SS2_O       : out std_logic_vector(2 downto 0);  
        APS_O             : out std_logic;                           
        DST_O             : out std_logic_vector(4 downto 0);
        FT1_O             : out std_logic_vector(4 downto 0);
        FT2_O             : out std_logic_vector(4 downto 0);
        Kp_O              : out std_logic_vector(10 downto 0);        
        Kg_O              : out std_logic_vector(16 downto 0)
    ) is
    begin
        T1_T0_O := PMemOutputData_I(31 downto 30);
        C4_C0_O := PMemOutputData_I(29 downto 25);
        APS_O := PMemOutputData_I(24);
        F1_F0_SS2_O := PMemOutputData_I(23 downto 22)&PMemOutputData_I(11);
        DST_O := PMemOutputData_I(21 downto 17);
        FT1_O := PMemOutputData_I(16 downto 12);
        FT2_O := PMemOutputData_I(10 downto 6);
        Kg_O := PMemOutputData_I(16 downto 0);
        Kp_O := PMemOutputData_I(10 downto 0);    
    end procedure p_DecomposeInstructionIntoFields;
    ---------------------------------------------
    function f_SelectRegOutput
    (
        FTx_I               : in std_logic_vector(NumBitsRegBank - 1 downto 0);
        PSW_I               : in TRiscoWord;
        PC_I                : in TRiscoWord;
        RegBnk_OutputData_I : in TRiscoWord
    ) return TRiscoWord is
        variable FTxi : integer;
    begin
        FTXi := to_integer(unsigned(FTx_I));
        case FTxi is
            when C_R00 =>
                return (others => '0');
            when C_PSW =>
                return PSW_I;
            when C_PC =>
                return PC_I;
            when others =>
                return RegBnk_OutputData_I;             -- Source 1 and Source 2
        end case;       
    end function f_SelectRegOutput;
    ---------------------------------------------
    procedure p_SelectRegInput1
    (
        F1_F0_SS2_I               : in std_logic_vector(2 downto 0);
        DST_I                     : in std_logic_vector(4 downto 0);
        FT1_I                     : in std_logic_vector(4 downto 0);
        FT2_I                     : in std_logic_vector(4 downto 0);
        signal RegBnk_Register1_O : out std_logic_vector(NumBitsRegBank - 1 downto 0)
    ) is
        variable F1_F0_SS2_v : std_logic_vector(2 downto 0);    
    begin
        if F1_F0_SS2_I(2 downto 1) /= "00" then
            F1_F0_SS2_v(0) := '0'; -- Remove X
        else
            F1_F0_SS2_v(0) := F1_F0_SS2_I(0);
        end if;
        F1_F0_SS2_v(2 downto 1) := F1_F0_SS2_I(2 downto 1);    
        case F1_F0_SS2_v is
            when FFS_DST_DST_Kgh | FFS_DST_DST_Kgl => 
                RegBnk_Register1_O <= DST_I(NumBitsRegBank - 1 downto 0);
            when FFS_DST_FT1_FT2 | FFS_DST_FT1_Kp =>
                RegBnk_Register1_O <= FT1_I(NumBitsRegBank - 1 downto 0);
            when others =>
                RegBnk_Register1_O <= (others=>'0');
        end case;    
    end procedure p_SelectRegInput1;
    ---------------------------------------------    
    procedure p_SelectRegInput2
    (
        F1_F0_SS2_I               : in std_logic_vector(2 downto 0);
        DST_I                     : in std_logic_vector(4 downto 0);
        FT1_I                     : in std_logic_vector(4 downto 0);
        FT2_I                     : in std_logic_vector(4 downto 0);
        signal RegBnk_Register2_O : out std_logic_vector(NumBitsRegBank - 1 downto 0)
    ) is
        variable F1_F0_SS2_v : std_logic_vector(2 downto 0);
    begin
        if F1_F0_SS2_I(2 downto 1) /= "00" then
            F1_F0_SS2_v(0) := '0'; -- Remove X
        else
            F1_F0_SS2_v(0) := F1_F0_SS2_I(0);
        end if;
        F1_F0_SS2_v(2 downto 1) := F1_F0_SS2_I(2 downto 1);
        case F1_F0_SS2_v is
            when FFS_DST_FT1_FT2 =>
                RegBnk_Register2_O <= FT2_I(NumBitsRegBank - 1 downto 0);
            when others =>
                RegBnk_Register2_O <= (others=>'0');
        end case;    
    end procedure p_SelectRegInput2;
    ---------------------------------------------    
begin

    p_select_and_control: process(Reset_I,Clk_I,PMem_OutputData_I,DMem_OutputData_I,RegBnk_FT1_OutputData_I,RegBnk_FT2_OutputData_I,ULA_Output_I,ULA_Ng_O_I,ULA_Cy_O_I,ULA_Ov_O_I,ULA_Zr_O_I,UD_OutputData_I,UD_Cy_O_I,PC_Data_I,DMem_Address_W,PSW_Data_I,PSW_Data_I)
        type TPhase is (RESET,IFETCH,IDECODE,OFETCH,IEXEC1,IEXEC2,IEXEC3);
        variable Phase_v            : TPhase;                        -- Phase of the Machine Cycle
        variable NextPhase_v        : TPhase;                        
        variable T1_T0_v            : std_logic_vector(1 downto 0);  -- Instruction Type
        variable C4_C0_v            : std_logic_vector(4 downto 0);  -- Instruction inside its type
        variable F1_F0_SS2_v        : std_logic_vector(2 downto 0);  -- Format of operands
        variable APS_v              : std_logic;                     -- Update or not Status Word
        variable DST_v              : std_logic_vector(4 downto 0);  -- Index of Destination
        variable FT1_v              : std_logic_vector(4 downto 0);  -- Index of Source 1
        variable FT2_v              : std_logic_vector(4 downto 0);  -- Index of Source 2
        variable Kp_v               : std_logic_vector(10 downto 0); -- Small Constant (Used to determine Constext)
        variable Kg_v               : std_logic_vector(16 downto 0); -- Large Constant (Used to determine Constext)
        variable Condition_v        : std_logic;                     -- Evaluate Condition
        variable IntAck_v           : std_logic;                     -- Interrupt Acknowledge
        variable IntMask_v          : std_logic;                     -- Masks interruption during first instruction of the ISR
    begin
        if rising_edge(Clk_I) then
            -------
            -- FSM
            -------
            Phase_v := NextPhase_v;
            if Reset_I ='1' then
                NextPhase_v := RESET;
                Phase_v := RESET;
                IntAck_v := '0';
                IntMask_v := '0';
                
            elsif Phase_v = RESET then
                NextPhase_v := IFETCH;
                
            elsif Phase_v = IFETCH then
                NextPhase_v := IDECODE;
                if Int_I = '0' then
                    IntAck_v := '0';
                end if;
                
            elsif Phase_v = IDECODE then
                --
                NextPhase_v := OFETCH;
                
            elsif Phase_v = OFETCH then    
                if Int_I = '0' or IntMask_v = '1' or InterruptEnable_w = '0' then -- without reentrant interrupts...
                    p_DecomposeInstructionIntoFields(PMem_OutputData_I,T1_T0_v,C4_C0_v,F1_F0_SS2_v,APS_v,DST_v,FT1_v,FT2_v,Kp_v,Kg_v);
                    IntMask_v := '0';
                else -- Interrupt = inst sub; SPISR = R30 (original); SPISR = SPISR - 1; M[R30] = PC; PC = R00 + Kpe(0400h)
                    T1_T0_v := INST_SUB;
                    C4_C0_v := C_TR;
                    F1_F0_SS2_v := FFS_DST_FT1_Kp;
                    APS_v := '0';
                    DST_v := std_logic_vector(to_unsigned(C_SPISR,DST_v'high+1)); -- beware with the register used to recover the PC with smaller sizes of RegBank...
                    FT1_v := std_logic_vector(to_unsigned(C_R00,FT1_v'high+1));
                    Kp_v := "10000000000"; -- 400h -> address FFFFFC00
                    IntAck_v := '1';
                    IntMask_v := '1';
                end if;             
                NextPhase_v := IEXEC1;
                
            elsif Phase_v = IEXEC1 then 
                IntAck_v := '0';
                if T1_T0_v = INST_ULA then
                   NextPhase_v := IFETCH;
                elsif T1_T0_v = INST_MEM and C4_C0_v = C_ST then
                   NextPhase_v := IFETCH;
                else
                   NextPhase_v := IEXEC2;
                end if;
                
            elsif Phase_v = IEXEC2 then 
                if (T1_T0_v = INST_MEM and (C4_C0_v = C_LDPOI or C4_C0_v = C_LDPOD or C4_C0_v = C_LDPRI)) or (T1_T0_v = INST_SUB) then
                   NextPhase_v := IEXEC3;
                else
                   NextPhase_v := IFETCH;
                end if;
                
            elsif Phase_v = IEXEC3 then 
                NextPhase_v := IFETCH;

            end if;    
        end if;
        -------------------------
        -- Selectors and Outputs
        -------------------------

        if Reset_I = '1' then
            IntAck_O <= '0';
            IntAck_v := '0';
        else
            IntAck_O <= IntAck_v;
        end if;
        
        if Reset_I = '1' then
            PMem_Enable_O <= '0';
            DMem_Enable_O <= '0';
        else
            PMem_Enable_O <= '1';
            DMem_Enable_O <= '1';
        end if;
        
        -- Condition
        Condition_v := '0';
        if Phase_v = OFETCH then
            case C4_C0_v is
                when C_TR  => Condition_v := '1';
                when C_NS  => Condition_v := ULA_Ng_O_I;
                when C_CS  => Condition_v := ULA_Cy_O_I;
                when C_OS  => Condition_v := ULA_Ov_O_I;
                when C_ZS  => Condition_v := ULA_Zr_O_I;
                when C_GE  => Condition_v := (not ULA_Ng_O_I);
                when C_GT  => Condition_v := (not ULA_Ng_O_I) and (not ULA_Zr_O_I);
                when C_EQ  => Condition_v := ULA_Zr_O_I;
                when C_FL  => Condition_v := '0';
                when C_NN  => Condition_v := not ULA_Ng_O_I;
                when C_NC  => Condition_v := not ULA_Cy_O_I;
                when C_NO  => Condition_v := not ULA_Ov_O_I;
                when C_NZ  => Condition_v := not ULA_Zr_O_I;
                when C_LT  => Condition_v := ULA_Ng_O_I;
                when C_LE  => Condition_v := ULA_Ng_O_I or ULA_Zr_O_I;
                when C_NE  => Condition_v := not ULA_Zr_O_I;
                when others => Condition_v := '0';
            end case;
        end if;
            
        -- Data Memory
        DMem_Address_W <= (others => '0');-- Default
        DMem_InputData_O <= (others => '0');
        DMem_Write_O <= '0';        
        case Phase_v is
            when IEXEC1 =>
                if T1_T0_v = INST_MEM and (C4_C0_v = C_ST or C4_C0_v = C_STPOI or C4_C0_v = C_STPOD) then
                    DMem_Address_W <= ULA_Output_I(DMem_Address_W'range);
                    DMem_InputData_O <= RegBnk_FT1_OutputData_I;
                    DMem_Write_O <= '1';
                elsif T1_T0_v = INST_MEM and (C4_C0_v = C_LD or C4_C0_v = C_LDPOI or C4_C0_v = C_LDPOD) then
                    DMem_Address_W <= ULA_Output_I(DMem_Address_W'range);
                elsif T1_T0_v = INST_SUB and Condition_v = '1' then
                    DMem_Address_W <= ULA_Output_I(DMem_Address_W'range);
                    DMem_InputData_O <= PC_Data_I;
                    DMem_Write_O <= '1';
                end if;
            when IEXEC2 =>
                if T1_T0_v = INST_MEM and C4_C0_v = C_STPRI then
                    DMem_Address_W <= ULA_Output_I(DMem_Address_W'range);
                    DMem_InputData_O <= RegBnk_FT1_OutputData_I;
                    DMem_Write_O <= '1';
                elsif T1_T0_v = INST_MEM and C4_C0_v = C_LDPRI then
                    DMem_Address_W <= ULA_Output_I(DMem_Address_W'range);
                    DMem_InputData_O <= RegBnk_FT1_OutputData_I;
                end if;
            when others =>
                DMem_Address_W <= (others => '0');
                DMem_InputData_O <= (others => '0');
                DMem_Write_O <= '0';                    
        end case;
        
        -- Register Bank
        RegBnk_Register1_O <= (others=>'0');-- Default
        RegBnk_Register2_O <= (others=>'0');
        RegBnk_RegisterW_O <= (others=>'0');
        RegBnk_Write_O <= '0';
        RegBnk_InputData_O <= (others => '0');
        case Phase_v is
            when OFETCH =>
                -- Type of operands
                if T1_T0_v = INST_ULA then
                    p_SelectRegInput1(F1_F0_SS2_v,DST_v,FT1_v,FT2_v,RegBnk_Register1_O);
                    p_SelectRegInput2(F1_F0_SS2_v,DST_v,FT1_v,FT2_v,RegBnk_Register2_O);
                elsif T1_T0_v = INST_MEM or T1_T0_v = INST_JMP then
                    p_SelectRegInput1(F1_F0_SS2_v,DST_v,FT1_v,FT2_v,RegBnk_Register1_O);
                    p_SelectRegInput2(F1_F0_SS2_v,DST_v,FT1_v,FT2_v,RegBnk_Register2_O);
                    RegBnk_RegisterW_O <= DST_v(NumBitsRegBank - 1 downto 0);
                elsif T1_T0_v = INST_SUB then
                    RegBnk_Register1_O <= DST_v(NumBitsRegBank - 1 downto 0);                
                end if;
            when IEXEC1 =>
                -- Execute
                if T1_T0_v = INST_ULA and DST_v(NumBitsRegBank - 1 downto 0) /= std_logic_vector(to_unsigned(C_PC,RegBnk_Register1_O'high+1)) then --If DST=PC, write to PC
                    RegBnk_RegisterW_O <= DST_v(NumBitsRegBank - 1 downto 0);
                    RegBnk_Write_O <= '1';
                    case C4_C0_v is -- Choose between ULA and UD result
                        -- ULA
                        when C_ADD | C_ADDC  | C_SUB | C_SUBC | C_SUBR | C_SUBRC | C_AND | C_OR | C_XOR =>
                            RegBnk_InputData_O <= ULA_Output_I;
                        -- Shifter 
                        when C_SRL | C_SLL | C_SRA | C_SLA | C_RRL | C_RLL | C_RRA | C_RLA =>
                            RegBnk_InputData_O <= UD_OutputData_I;
                        when C_SRLC | C_SLLC | C_SRAC | C_SLAC | C_RRLC | C_RLLC | C_RRAC | C_RLAC =>
                            RegBnk_InputData_O <= UD_OutputData_I;
                        when others  =>
                            RegBnk_InputData_O <= (others => '0');
                    end case;
                elsif T1_T0_v = INST_MEM and (C4_C0_v = C_ST or C4_C0_v = C_STPOI or C4_C0_v = C_STPOD) then
                    RegBnk_Register1_O <= DST_v(NumBitsRegBank - 1 downto 0);
                elsif T1_T0_v = INST_MEM and (C4_C0_v = C_STPRI or C4_C0_v = C_LDPRI) then
                    RegBnk_RegisterW_O <= FT2_v(NumBitsRegBank - 1 downto 0);
                    RegBnk_Write_O <= '1';
                    RegBnk_InputData_O <= ULA_Output_I;
                    p_SelectRegInput1(F1_F0_SS2_v,DST_v,FT1_v,FT2_v,RegBnk_Register1_O);                       
                elsif T1_T0_v = INST_SUB and Condition_v = '1' then
                    RegBnk_RegisterW_O <= DST_v(NumBitsRegBank - 1 downto 0);
                    RegBnk_Write_O <= '1';
                    RegBnk_InputData_O <= ULA_Output_I;
                    p_SelectRegInput1(F1_F0_SS2_v,DST_v,FT1_v,FT2_v,RegBnk_Register1_O);
                    p_SelectRegInput2(F1_F0_SS2_v,DST_v,FT1_v,FT2_v,RegBnk_Register2_O);                
                end if; 
            when IEXEC2 =>            
                if T1_T0_v = INST_MEM and (C4_C0_v = C_LD or C4_C0_v = C_LDPOI or C4_C0_v = C_LDPOD) then
                    RegBnk_RegisterW_O <= DST_v(NumBitsRegBank - 1 downto 0);
                    RegBnk_Write_O <= '1';
                    RegBnk_InputData_O <= DMem_OutputData_I;   
                elsif T1_T0_v = INST_MEM and (C4_C0_v = C_STPOI or C4_C0_v = C_STPOD) then
                    RegBnk_RegisterW_O <= FT2_v(NumBitsRegBank - 1 downto 0);
                    RegBnk_Write_O <= '1';
                    RegBnk_InputData_O <= ULA_Output_I;       
                elsif T1_T0_v = INST_MEM and C4_C0_v = C_STPRI then
                    RegBnk_Register1_O <= DST_v(NumBitsRegBank - 1 downto 0);                   
                end if;            
            when IEXEC3 =>
                if T1_T0_v = INST_MEM and C4_C0_v = C_LDPRI then
                    RegBnk_RegisterW_O <= DST_v(NumBitsRegBank - 1 downto 0);
                    RegBnk_Write_O <= '1';
                    RegBnk_InputData_O <= DMem_OutputData_I;  
                elsif T1_T0_v = INST_MEM and (C4_C0_v = C_LDPOI or C4_C0_v = C_LDPOD) then
                    RegBnk_RegisterW_O <= FT2_v(NumBitsRegBank - 1 downto 0);
                    RegBnk_Write_O <= '1';
                    RegBnk_InputData_O <= ULA_Output_I;   
                end if;
            when others =>            
                RegBnk_Register1_O <= (others => '0'); 
                RegBnk_Register2_O <= (others => '0');
                RegBnk_Write_O <= '0';
                RegBnk_InputData_O <= (others => '0');
        end case;
        
        -- PSW
        -- When APS = 1, update flags for ULA/UD operations with flags values
        -- When APS = 0, update flags only via store operation on PSW (R01)
        PSW_Data_O <= (others => '0');
        PSW_Wen_O <= '0';
        case Phase_v is
            when IEXEC1 =>
                if T1_T0_v = INST_ULA then
                   case C4_C0_v is -- Choose between ULA and UD result
                        -- ULA
                        when C_ADD | C_ADDC  | C_SUB | C_SUBC | C_SUBR | C_SUBRC | C_AND | C_OR | C_XOR =>
                            if DST_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PSW,RegBnk_Register1_O'high+1)) then
                                PSW_Data_O <= ULA_Output_I;
                            else
                                PSW_Data_O <= PSW_Data_I;
                            end if;
                            if APS_v = '1' then
                                PSW_Data_O(7 downto 4) <= ULA_Ng_O_I & ULA_Ov_O_I & ULA_Zr_O_I & ULA_Cy_O_I;
                            end if;
                        -- Shifter 
                        when C_SRL | C_SLL | C_SRA | C_SLA | C_RRL | C_RLL | C_RRA | C_RLA =>
                            if DST_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PSW,RegBnk_Register1_O'high+1)) then
                                PSW_Data_O <= UD_OutputData_I;
                            else
                                PSW_Data_O <= PSW_Data_I;
                            end if;

                        when C_SRLC | C_SLLC | C_SRAC | C_SLAC | C_RRLC | C_RLLC | C_RRAC | C_RLAC =>
                            if DST_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PSW,RegBnk_Register1_O'high+1)) then
                                PSW_Data_O <= UD_OutputData_I;
                            else
                                PSW_Data_O <= PSW_Data_I;
                            end if;
                            if APS_v = '1' then
                                PSW_Data_O(4) <= UD_Cy_O_I;
                            end if;
                        when others  =>
                            PSW_Data_O <= (others => '0');
                    end case;
                    PSW_Wen_O <= '1';
                elsif T1_T0_v = INST_MEM and (C4_C0_v = C_STPRI or C4_C0_v = C_LDPRI) and FT2_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PSW,RegBnk_Register1_O'high+1)) then
                    PSW_Data_O <= ULA_Output_I;
                    PSW_Wen_O <= '1';
                elsif T1_T0_v = INST_SUB and Condition_v = '1' and DST_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PSW,RegBnk_Register1_O'high+1)) then
                    PSW_Data_O <= ULA_Output_I;
                    PSW_Wen_O <= '1';
                end if;                    
            when IEXEC2 =>            
                if T1_T0_v = INST_MEM and (C4_C0_v = C_LD or C4_C0_v = C_LDPOI or C4_C0_v = C_LDPOD) and DST_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PSW,RegBnk_Register1_O'high+1)) then
                    PSW_Data_O <= DMem_OutputData_I;   
                    PSW_Wen_O <= '1';
                elsif T1_T0_v = INST_MEM and (C4_C0_v = C_STPOI or C4_C0_v = C_STPOD) and FT2_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PSW,RegBnk_Register1_O'high+1)) then
                    PSW_Data_O <= ULA_Output_I;       
                    PSW_Wen_O <= '1';
                end if;            
            when IEXEC3 =>
                if T1_T0_v = INST_MEM and C4_C0_v = C_LDPRI and DST_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PSW,RegBnk_Register1_O'high+1)) then
                    PSW_Data_O <= DMem_OutputData_I;  
                    PSW_Wen_O <= '1';
                elsif T1_T0_v = INST_MEM and (C4_C0_v = C_LDPOI or C4_C0_v = C_LDPOD) and FT2_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PSW,RegBnk_Register1_O'high+1)) then
                    PSW_Data_O <= ULA_Output_I;   
                    PSW_Wen_O <= '1';
                end if;                
            when others =>
                PSW_Data_O <= (others => '0');
                PSW_Wen_O <= '0';                               
        end case;            
        
        -- PC
        PC_Wen_O <= '0';
        PC_Data_O <= (others => '0');
        case Phase_v is
            when IEXEC1 =>
                if (T1_T0_v = INST_ULA and DST_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PC,RegBnk_Register1_O'high+1))) then -- PC=R31
                    PC_Wen_O <= '1';
                    PC_Data_O <= ULA_Output_I;
                elsif (T1_T0_v = INST_JMP and Condition_v = '1' and DST_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PC,RegBnk_Register1_O'high + 1))) then
                    PC_Wen_O <= '1';
                    PC_Data_O <= ULA_Output_I;
                else
                    PC_Wen_O <= '1';
                    PC_Data_O <= std_logic_vector(unsigned(PC_Data_I) + 1);
                end if;
            when IEXEC2 =>
                if T1_T0_v = INST_SUB and Condition_v = '1' then
                    PC_Wen_O <= '1';
                    PC_Data_O <= ULA_Output_I;
                elsif T1_T0_v = INST_MEM and C4_C0_v = C_LDPOI and DST_v(NumBitsRegBank - 1 downto 0) = std_logic_vector(to_unsigned(C_PC,RegBnk_Register1_O'high + 1)) then
                    PC_Wen_O <= '1';
                    PC_Data_O <= DMem_OutputData_I;
                end if;
            when others =>
                PC_Wen_O <= '0';
                PC_Data_O <= (others => '0');            
        end case;
               
        -- ULA,UD
        ULA_Function_O <= (others=>'0');-- default
        UD_Function_O <= (others=>'0');
        case Phase_v is
            when IEXEC1 =>
                -- ULA/UD Function
                if T1_T0_v = INST_ULA then
                    ULA_Function_O <= C4_C0_v;
                    UD_Function_O <= C4_C0_v;               
                elsif T1_T0_v = INST_MEM and C4_C0_v = C_ST then
                    ULA_Function_O <= C_ADD;         
                elsif T1_T0_v = INST_MEM and C4_C0_v = C_LD then
                    ULA_Function_O <= C_ADD;
                elsif T1_T0_v = INST_JMP then
                    ULA_Function_O <= C_ADD;   
                elsif T1_T0_v = INST_SUB then
                    ULA_Function_O <= C_SUB;                     
                end if;
            when IEXEC2 =>
                case T1_T0_v is   -- ULA and UD function based on instruction type
                    when INST_MEM => 
                        if C4_C0_v = C_STPOI or C4_C0_v = C_STPOD then
                            ULA_Function_O <= C_ADD;         
                        end if;                                 
                    when INST_SUB => 
                        if Condition_v = '1' then
                            ULA_Function_O <= C_ADD;   
                        end if;
                    when others   => 
                        ULA_Function_O <= (others=>'0');
                        UD_Function_O <= (others=>'0');
                end case;            
            when IEXEC3 =>
                if T1_T0_v = INST_MEM and (C4_C0_v = C_LDPOI or C4_C0_v = C_LDPOD) then
                    ULA_Function_O <= C_ADD;         
                end if;
            when others =>
                ULA_Function_O <= (others=>'0');
                UD_Function_O <= (others=>'0');
        end case;
        
        -- RUA,RUB,RDA,RDB
        RUA_Wen_O <= '0'; RUB_Wen_O <= '0'; RDA_Wen_O <= '0'; RDB_Wen_O <= '0';
        RUA_Data_O <= (others=>'0');        RUB_Data_O <= (others=>'0');
        RDA_Data_O <= (others=>'0');        RDB_Data_O <= (others=>'0'); 
        case Phase_v is
            when OFETCH =>
                RUA_Wen_O <= '1'; RUB_Wen_O <= '1'; RDA_Wen_O <= '1'; RDB_Wen_O <= '1';
                if T1_T0_v = INST_MEM and (C4_C0_v = C_STPRI or C4_C0_v = C_LDPRI) then
                    RUA_Data_O <= std_logic_vector(to_unsigned(1,RUA_Data_O'high+1));
                    case (F1_F0_SS2_v) is
                        when FFS_DST_FT1_FT2 => RUB_Data_O <= f_SelectRegOutput(FT2_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT2_OutputData_I);
                        when FFS_DST_FT1_Kp  => RUB_Data_O <= Kpe_F(Kp_v);             -- Source 1 and Kp
                        when FFS_DST_R00_Kgl => RUB_Data_O <= Kgl_F(Kg_v);             -- R00 and Kgl
                        when FFS_DST_DST_Kgl => RUB_Data_O <= Kgl_F(Kg_v);             -- DST and Kgl 
                        when others          => RUB_Data_O <= (others=>'0');           -- Not Specified
                    end case;
                elsif T1_T0_v = INST_SUB then
                    RUA_Data_O <= f_SelectRegOutput(DST_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I;
                    RUB_Data_O <= std_logic_vector(to_unsigned(1,RUA_Data_O'high+1));
                else
                    -- Operand fetch for ULA and UD
                    case (F1_F0_SS2_v) is
                        when FFS_DST_FT1_FT2 => RUA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I; -- Source 1 and Source 2  
                                                RUB_Data_O <= f_SelectRegOutput(FT2_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT2_OutputData_I); --RegBnk_FT2_OutputData_I; 
                                                RDA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I;   
                                                RDB_Data_O <= f_SelectRegOutput(FT2_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT2_OutputData_I); --RegBnk_FT2_OutputData_I;
                        when FFS_DST_FT1_Kp  => RUA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I; -- Source 1 and Kp  
                                                RUB_Data_O <= Kpe_F(Kp_v);             
                                                RDA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I;   
                                                RDB_Data_O <= Kpe_F(Kp_v);             
                        when FFS_DST_R00_Kgl => RUA_Data_O <= (others => '0');         -- R00 and Kgl            
                                                RUB_Data_O <= Kgl_F(Kg_v);             
                                                RDA_Data_O <= (others => '0');                     
                                                RDB_Data_O <= Kgl_F(Kg_v);             
                        when FFS_DST_DST_Kgl => RUA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I; -- DST and Kgl  
                                                RUB_Data_O <= Kgl_F(Kg_v);              
                                                RDA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I;   
                                                RDB_Data_O <= Kgl_F(Kg_v);
                        when others          => RUA_Data_O <= (others=>'0');           -- Not Specified  
                                                RUB_Data_O <= (others=>'0');           
                                                RDA_Data_O <= (others=>'0');             
                                                RDB_Data_O <= (others=>'0');
                    end case;
                end if;
            when IEXEC1 =>
                if T1_T0_v = INST_MEM and (C4_C0_v = C_STPOI or C4_C0_v = C_LDPOI) then
                    RUA_Data_O <= std_logic_vector(to_unsigned(1,RUA_Data_O'high+1));
                    RUA_Wen_O <= '1';
                elsif T1_T0_v = INST_MEM and (C4_C0_v = C_STPOD or C4_C0_v = C_LDPOD) then
                    RUA_Data_O <= std_logic_vector(to_signed(-1,RUA_Data_O'high+1));
                    RUA_Wen_O <= '1';
                elsif T1_T0_v = INST_MEM and (C4_C0_v = C_STPRI or C4_C0_v = C_LDPRI) then
                    case (F1_F0_SS2_v) is
                        when FFS_DST_FT1_FT2 => RUA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I;
                        when FFS_DST_FT1_Kp  => RUA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I;
                        when FFS_DST_R00_Kgl => RUA_Data_O <= (others => '0');
                        when FFS_DST_DST_Kgl => RUA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I;
                        when others          => RUA_Data_O <= (others=>'0');
                    end case;                
                    RUA_Wen_O <= '1';
                    RUB_Data_O <= ULA_Output_I;
                    RUB_Wen_O <= '1';
                elsif T1_T0_v = INST_SUB and Condition_v = '1' then
                    case (F1_F0_SS2_v) is
                        when FFS_DST_FT1_FT2 => 
                            RUA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I; -- Source 1 and Source   
                            RUB_Data_O <= f_SelectRegOutput(FT2_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT2_OutputData_I); --RegBnk_FT2_OutputData_I; 
                        when FFS_DST_FT1_Kp  => 
                            RUA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I; -- Source 1 and K  
                            RUB_Data_O <= Kpe_F(Kp_v);             
                        when FFS_DST_R00_Kgl => 
                            RUA_Data_O <= (others => '0');         -- R00 and Kgl            
                            RUB_Data_O <= Kgl_F(Kg_v);             
                        when FFS_DST_DST_Kgl => 
                            RUA_Data_O <= f_SelectRegOutput(FT1_v(NumBitsRegBank - 1 downto 0),PSW_Data_I,PC_Data_I,RegBnk_FT1_OutputData_I); --RegBnk_FT1_OutputData_I; -- DST and Kgl  
                            RUB_Data_O <= Kgl_F(Kg_v);              
                        when others          => 
                        RUA_Data_O <= (others=>'0');               -- Not Specified
                        RUB_Data_O <= (others=>'0');           
                    end case; 
                    RUA_Wen_O <= '1';
                    RUB_Wen_O <= '1';                    
                end if;
            when others =>
                RUA_Wen_O <= '0'; RUB_Wen_O <= '0'; RDA_Wen_O <= '0'; RDB_Wen_O <= '0';
                RUA_Data_O <= (others=>'0');        RUB_Data_O <= (others=>'0');
                RDA_Data_O <= (others=>'0');        RDB_Data_O <= (others=>'0');  
        end case;

        -- RUA_Clr_O, RUB_Clr_O, RDA_Clr_O, RDB_Clr_O, PSW_Clr_O
        case Phase_v is
            when RESET =>
                RUA_Clr_O <= '1'; RUB_Clr_O <= '1'; RDA_Clr_O <= '1'; RDB_Clr_O <= '1'; PC_Clr_O <= '1'; PSW_Clr_O <= '1';
            when others =>
                RUA_Clr_O <= '0'; RUB_Clr_O <= '0'; RDA_Clr_O <= '0'; RDB_Clr_O <= '0'; PC_Clr_O <= '0'; PSW_Clr_O <= '0';
        end case;

    end process;

PMem_Write_O <= '0';                                                      -- Program Memory Read
PMem_Address_O <= PC_Data_I(PMem_Address_O'range) when Reset_I = '0' else -- Set memory address
                  (others => '0');
                  
DMem_Address_O <= DMem_Address_W when Reset_I = '0' else -- Set memory address
                  (others => '0');

end Ark1;