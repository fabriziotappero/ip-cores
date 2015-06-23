------------------------------------------------------
--      Hynix 4BANKS X 8M X 16bits DDR2 SDRAM       --
--                                                  --
--                  VHDL Modeling                   --
--                                                  --
--     PART : HY5PS121621F-B400/B533/B667/B800      --
--                                                  --
--                   HHHH    HHHH                   --
--                   HHHH    HHHH                   --
--         ,O0O.  ,O0 .HH ,O0 .HH                   --
--        (O000O)(O00  )H(O00  )H                   --
--         `O0O'  `O0 'HH `O0 'HH                   -- 
--                   HHHH    HHHH  Hynix            --
--                   HHHH    HHHH  Semiconductor    --
------------------------------------------------------
---------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
library grlib;
use grlib.stdlib.all;
--USE IEEE.STD_LOGIC_ARITH.all;
--USE IEEE.STD_LOGIC_UNSIGNED.all;
USE work.HY5PS121621F_PACK.all;
---------------------------------------------------------------------------------------------------

Entity HY5PS121621F Is
  generic (
     TimingCheckFlag : boolean := TRUE;
     PUSCheckFlag : boolean := FALSE;
     Part_Number : PART_NUM_TYPE := B400);
  Port (  DQ    :  inout   std_logic_vector(15 downto 0) := (others => 'Z');
          LDQS  :  inout   std_logic := 'Z';
          LDQSB :  inout   std_logic := 'Z';
          UDQS  :  inout   std_logic := 'Z';
          UDQSB :  inout   std_logic := 'Z';
          LDM   :  in      std_logic;
          WEB   :  in      std_logic;
          CASB  :  in      std_logic;
          RASB  :  in      std_logic;
          CSB   :  in      std_logic;
          BA    :  in      std_logic_vector(1 downto 0);
          ADDR  :  in      std_logic_vector(12 downto 0);
          CKE   :  in      std_logic;
          CLK   :  in      std_logic;
          CLKB  :  in      std_logic;
          UDM   :  in      std_logic );
End HY5PS121621F;

-----------------------------------------------------------------------------------------------------

Architecture Behavioral_Model_HY5PS121621F Of HY5PS121621F Is

signal RD_PIPE_REG : std_logic_vector(6 downto 0) := "0000000";
signal WT_PIPE_REG : std_logic_vector(12 downto 0) := "0000000000000";
signal ADD_PIPE_REG : ADD_PIPE_TYPE;
signal DLL_reset, DLL_lock_enable : std_logic := '0';
signal yburst, RD_WR_ST, caspwt, casp6_rd, casp6_wt : std_logic := '0';
signal casp_wtI, casp_wtII, wt_stdby : std_logic := '0';
signal udspre_enable, ldspre_enable, udsh_dsl_enable, ldsh_dsl_enable : std_logic := '0';
signal dq_bufferH, dq_bufferL : DATA_BUFFER_TYPE := ("0ZZZZZZZZ", "0ZZZZZZZZ", "0ZZZZZZZZ",
                                        "0ZZZZZZZZ", "0ZZZZZZZZ", "0ZZZZZZZZ", "0ZZZZZZZZ");
signal DQS_S : std_logic := 'Z';
signal dqs_count : integer := 0;
signal dqs_pulse1, dqs_pulse2, dqs_pulse3, dqs_pulse4, dqs_pulse5, dqs_pulse6 : std_logic := '0';
signal cur_time : time := 0 ns;
signal Ref_time, clk_cycle_rising : time := 0 ns;
signal tmp_act_trans0, tmp_act_trans1, tmp_act_trans2, tmp_act_trans3 : std_logic := '0';
signal mrs_cmd_in : std_logic := '0';
signal CKEN : CKE_TYPE := (others => '0');
signal CLK_DLY2, CLK_DLY1, CLK_DLY15 : std_logic := '0';
signal tmp_ref_addr1 : std_logic_vector((NUM_OF_ROW_ADD - 1) downto 0) := (others => '0');
signal tmp_ref_addr2 : std_logic_vector((NUM_OF_ROW_ADD + 1) downto 0) := (others => '0');
signal tmp_ref_addr3_B0 : std_logic_vector((NUM_OF_ROW_ADD - 1) downto 0) := (others => '0');
signal tmp_ref_addr3_B1 : std_logic_vector((NUM_OF_ROW_ADD - 1) downto 0) := (others => '0');
signal tmp_ref_addr3_B2 : std_logic_vector((NUM_OF_ROW_ADD - 1) downto 0) := (others => '0');
signal tmp_ref_addr3_B3 : std_logic_vector((NUM_OF_ROW_ADD - 1) downto 0) := (others => '0');
signal tmp_ref_addr3_0, tmp_ref_addr3_1, tmp_ref_addr3_2, tmp_ref_addr3_3 : std_logic := '0';
signal tmp_ref_addr1_trans, tmp_ref_addr2_trans, tmp_ref_addr3_trans : std_logic := '0';
signal RefChkTimeInit : boolean := FALSE;
signal refresh_check : REF_CHECK;
signal real_col_addr : COL_ADDR_TYPE ;
signal Read_CA, Write_CA : std_logic := '0';
signal tmp_w_trans0, tmp_w_trans1, tmp_w_trans2, tmp_w_trans3 : std_logic := '0';
signal RA_Activated_B0 : std_logic_vector ((NUM_OF_ROW_ADD - 1) downto 0) := (others => 'U');
signal RA_Activated_B1 : std_logic_vector ((NUM_OF_ROW_ADD - 1) downto 0) := (others => 'U');
signal RA_Activated_B2 : std_logic_vector ((NUM_OF_ROW_ADD - 1) downto 0) := (others => 'U');
signal RA_Activated_B3 : std_logic_vector ((NUM_OF_ROW_ADD - 1) downto 0) := (others => 'U');
signal SA_ARRAY : SA_ARRAY_TYPE;
signal SA_ARRAY_A0 : SA_TYPE;
signal SA_ARRAY_A1 : SA_TYPE;
signal SA_ARRAY_A2 : SA_TYPE;
signal SA_ARRAY_A3 : SA_TYPE;
signal SA_ARRAY_W0 : SA_TYPE;
signal SA_ARRAY_W1 : SA_TYPE;
signal SA_ARRAY_W2 : SA_TYPE;
signal SA_ARRAY_W3 : SA_TYPE;
signal PcgPdExtFlag, ActPdExtFlag, SlowActPdExtFlag : boolean := FALSE;
signal PUSPCGAFlag1, PUSPCGAFlag2 : boolean := FALSE;
signal PUS_DLL_RESET : boolean := FALSE;
signal ModeRegisterSetFlag : boolean := FALSE;
signal ModeRegisterFlag : boolean := FALSE;
signal BankActivateFlag : boolean := FALSE;
signal BankActivateFinFlag : boolean := FALSE;
signal BankActivatedFlag : std_logic_vector ((NUM_OF_BANKS - 1) downto 0) := (others => '0');
signal PcgPdFlag, ReadFlag : boolean := FALSE;
signal WriteFlag : boolean := FALSE;
signal DataBuffer : BUFFER_TYPE;
signal PrechargeFlag : boolean := FALSE;
signal AutoPrechargeFlag : std_logic_vector ((NUM_OF_BANKS - 1) downto 0) := (others => '0');
signal PrechargeFinFlag : boolean := FALSE;
signal PrechargeAllFlag : boolean := FALSE;
signal PrechargeAllFinFlag : boolean := FALSE;
signal ReadFinFlag : boolean := FALSE;
signal WriteFinFlag : boolean := FALSE;
signal AutoRefFlag : boolean := FALSE;
signal SelfRefFlag : boolean := FALSE;
signal SelfRefExt2NRFlag, SelfRefExt2RDFlag : boolean := FALSE;
signal PUSCheckFinFlag : boolean := FALSE;
signal CurrentState : STATE_TYPE := PWRUP;
signal ModeRegister : MODE_REGISTER := (                                  
  CAS_LATENCY => 2,                                                     
  BURST_MODE => SEQUENTIAL,                                            
  BURST_LENGTH => 4,
  DLL_STATE => NORST,
  SAPD => '0',
  TWR => 2                );
signal ExtModeRegister : EMR_TYPE := (
  DLL_EN => '0',
  AL => 0,
  QOFF => '0',
  DQSB_ENB => '0',
  RDQS_EN => '0',
  OCD_PGM => CAL_EXIT           );
signal ExtModeRegister2 : EMR2_TYPE := (
  SREF_HOT => '0'               );
signal last_ocd_adjust_cmd, clk_cycle : time := 0 ns;
signal clk_last_rising : time := 0 ns;
signal cke_last_rising : time := 0 ns;
signal clk_last_falling : time := 0 ns;
signal udqs_last_rising : time := 0 ns;
signal udqs_last_falling : time := 0 ns;
signal ldqs_last_rising : time := 0 ns;
signal ldqs_last_falling : time := 0 ns;
signal wr_cmd_time : time := 0 ns;
signal ldm_last_rising : time := 0 ns;
signal udm_last_rising : time := 0 ns;
signal b0_last_activate : time := 0 ns;
signal b1_last_activate : time := 0 ns;
signal b2_last_activate : time := 0 ns;
signal b3_last_activate : time := 0 ns;
signal b0_last_precharge : time := 0 ns;
signal b1_last_precharge : time := 0 ns;
signal b2_last_precharge : time := 0 ns;
signal b3_last_precharge : time := 0 ns;
signal b0_last_column_access : time := 0 ns;
signal b1_last_column_access : time := 0 ns;
signal b2_last_column_access : time := 0 ns;
signal b3_last_column_access : time := 0 ns;
signal b0_last_data_in : time := 0 ns;
signal b1_last_data_in : time := 0 ns;
signal b2_last_data_in : time := 0 ns;
signal b3_last_data_in : time := 0 ns;
signal last_mrs_set : time := 0 ns;
signal last_aref : time := 0 ns;
signal tCH : time := 0 ns;
signal tCL : time := 0 ns;
signal tWPRE : time := 0 ns;
signal tRAS, tRCD, tRP, tRC, tCCD : time := 0 ns;
signal tWTR : time := 0 ns;
signal tDQSH : time := 0 ns;
signal tDQSL : time := 0 ns;
signal tWPSTmin : time := 0 ns;
signal tWPSTmax : time := 0 ns;
signal tDQSSmin : time := 0 ns;
signal tDQSSmax : time := 0 ns;
signal tMRD : time := 0 ns;
signal cke_ch : time := 0 ns;
signal rasb_ch : time := 0 ns;
signal casb_ch : time := 0 ns;
signal web_ch : time := 0 ns;
signal csb_ch : time := 0 ns;
signal udm_ch : time := 0 ns;
signal ldm_ch : time := 0 ns;
signal a0_ch : time := 0 ns;
signal a1_ch : time := 0 ns;
signal a2_ch : time := 0 ns;
signal a3_ch : time := 0 ns;
signal a4_ch : time := 0 ns;
signal a5_ch : time := 0 ns;
signal a6_ch : time := 0 ns;
signal a7_ch : time := 0 ns;
signal a8_ch : time := 0 ns;
signal a9_ch : time := 0 ns;
signal a10_ch : time := 0 ns;
signal a11_ch : time := 0 ns;
signal a12_ch : time := 0 ns;
signal ba0_ch : time := 0 ns;
signal ba1_ch : time := 0 ns;
signal dq0_ch : time := 0 ns;
signal dq1_ch : time := 0 ns;
signal dq2_ch : time := 0 ns;
signal dq3_ch : time := 0 ns;
signal dq4_ch : time := 0 ns;
signal dq5_ch : time := 0 ns;
signal dq6_ch : time := 0 ns;
signal dq7_ch : time := 0 ns;
signal dq8_ch : time := 0 ns;
signal dq9_ch : time := 0 ns;
signal dq10_ch : time := 0 ns;
signal dq11_ch : time := 0 ns;
signal dq12_ch : time := 0 ns;
signal dq13_ch : time := 0 ns;
signal dq14_ch : time := 0 ns;
signal dq15_ch : time := 0 ns;

begin

-----------------------------------------------------------------------------------------------------

CLK_CYCLE_CHECK : process(CLK)

begin
  CLK_DLY15 <= transport CLK after 1.5 ns;
  CLK_DLY1 <= transport CLK after 1 ns;
  CLK_DLY2 <= transport CLK after 2 ns;
  if (rising_edge(CLK)) then
    clk_cycle <= transport now - clk_cycle_rising;
    clk_cycle_rising <= transport now;
  end if;
end Process;

-----------------------------------------------------------------------------------------------------

REFRESH_TIME_CHECK : process(tmp_ref_addr1_trans, tmp_ref_addr2_trans, tmp_ref_addr3_trans)

variable i, j : integer := 0;

begin
  i := 0;
  j := 0;
  if (RefChkTimeInit = FALSE) then
    loop
      exit when (i > NUM_OF_BANKS - 1);
      j := 0;
      loop
        exit when (j >= NUM_OF_ROWS);
        refresh_check (i, j) <= 0 ns;
        j := j + 1;
      end loop;
      i := i + 1;
    end loop;
    RefChkTimeInit <= TRUE;
  end if;
  if (tmp_ref_addr1_trans'event and tmp_ref_addr1_trans = '1') then
    refresh_check (0, conv_integer(tmp_ref_addr1)) <= transport now;
    refresh_check (1, conv_integer(tmp_ref_addr1)) <= transport now;
    refresh_check (2, conv_integer(tmp_ref_addr1)) <= transport now;
    refresh_check (3, conv_integer(tmp_ref_addr1)) <= transport now;
  end if;
  if (tmp_ref_addr2_trans'event and tmp_ref_addr2_trans = '1') then
    refresh_check (conv_integer(tmp_ref_addr2(1 downto 0)), conv_integer(tmp_ref_addr2((NUM_OF_ROW_ADD + 1) downto 2))) <= transport now;
  end if;
  if (tmp_ref_addr3_trans'event and tmp_ref_addr3_trans = '1') then
    if (tmp_ref_addr3_0 = '1') then
      refresh_check (0, conv_integer(tmp_ref_addr3_B0)) <= transport now;
    end if;
    if (tmp_ref_addr3_1 = '1') then
      refresh_check (1, conv_integer(tmp_ref_addr3_B1)) <= transport now;
    end if;
    if (tmp_ref_addr3_2 = '1') then
      refresh_check (2, conv_integer(tmp_ref_addr3_B2)) <= transport now;
    end if;
    if (tmp_ref_addr3_3 = '1') then
      refresh_check (3, conv_integer(tmp_ref_addr3_B3)) <= transport now;
    end if;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

CKE_EVAL : process (CLK, CKE)
 
begin
  if (CKE'EVENT and CKE = '1' and CKE'LAST_VALUE = '0') then
    cke_last_rising <= transport now;
  end if;
  if (CLK'EVENT and CLK = '0' and CLK'LAST_VALUE = '1') then
    CKEN(-1) <= CKEN(0);
  elsif (CLK'EVENT and CLK = '1' and CLK'LAST_VALUE = '0') then
    CKEN(0) <= CKE;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

STATE_MACHINE : process (CLK, CKE, BankActivateFinFlag, PrechargeFinFlag, PrechargeAllFinFlag, BankActivatedFlag, PUSCheckFinFlag)
 
variable ChipSelectBar : std_logic := '0';
variable RowAddrStrobeBar : std_logic := '0';
variable ColAddrStrobeBar : std_logic := '0';
variable WriteEnableBar : std_logic := '0';
variable Address10 : std_logic := '0';
variable ClockEnable : CKE_TYPE := (others => '0');
variable NextState, Cur_State : STATE_TYPE := PWRUP;
variable CurrentCommand : COMMAND_TYPE := NOP;
variable OpCode : MROPCODE_TYPE := (others => 'X');
variable MR : MODE_REGISTER;
variable EMR : EMR_TYPE;
variable EMR2 : EMR2_TYPE;
variable BkAdd : std_logic_vector((NUM_OF_BANK_ADD - 1) downto 0) := (others => 'X');
variable BankActFlag : std_logic_vector((NUM_OF_BANKS - 1) downto 0) := (others => '0');
 
begin
  if (CLK'EVENT and CLK = '1' and CLK'LAST_VALUE = '0') then
    ClockEnable(-1) := CKEN(-1);
    ClockEnable(0) := CKE;
    ChipSelectBar := CSB;
    RowAddrStrobeBar := RASB;
    ColAddrStrobeBar := CASB;
    WriteEnableBar := WEB;
    Address10 := ADDR(10);
    BkAdd := BA;
    BankActFlag := BankActivatedFlag;
    Cur_State := CurrentState;
    COMMAND_DECODE (ChipSelectBar, RowAddrStrobeBar, ColAddrStrobeBar,
      WriteEnableBar, Address10, BkAdd, ClockEnable, CurrentCommand, BankActFlag, Cur_State);
    if (DLL_reset = '1' and (CurrentCommand = RD or CurrentCommand = RDAP)) then
      if (TimingCheckFlag = TRUE) then
        assert false report
        "ERROR : (DLL Locking) : 200 clock cycles are needed after DLL reset."
        severity ERROR;
      end if;
    end if;
    Case CurrentState Is
      When IDLE =>
        Case CurrentCommand Is
          When DSEL =>
            NextState := IDLE;
          When NOP =>
            NextState := IDLE;
          When ACT =>
            if (TimingCheckFlag = TRUE) then
              assert (PcgPdExtFlag = FALSE) report
              "WARNING : (tXP_CHECK) : tXP timing error!"
              severity WARNING;
              assert (now - last_aref >= tRFC) report
              "WARNING : (tRFC_CHECK) : tRFC timing error!"
              severity WARNING;
              assert (SelfRefExt2NRFlag /= TRUE) report
              "ERROR : (tXSNR_CHECK) : Needs tXSNR Timing after Self Refresh."
              severity error;
            end if;
            BankActivateFlag <= TRUE;
            NextState := RACT; 
          When PCG =>
            if (TimingCheckFlag = TRUE) then
              assert (SelfRefExt2NRFlag /= TRUE) report
              "ERROR : (tXSNR_CHECK) : Needs tXSNR Timing after Self Refresh."
              severity error;
              assert (PcgPdExtFlag = FALSE) report
              "WARNING : (tXP_CHECK) : tXP timing error!"
              severity WARNING;
            end if;
            NextState := IDLE;
          When PCGA =>
            if (TimingCheckFlag = TRUE) then
              assert (SelfRefExt2NRFlag /= TRUE) report
              "ERROR : (tXSNR_CHECK) : Needs tXSNR Timing after Self Refresh."
              severity error;
              assert (PcgPdExtFlag = FALSE) report
              "WARNING : (tXP_CHECK) : tXP timing error!"
              severity WARNING;
            end if;
            NextState := IDLE;
          When AREF =>
            if (TimingCheckFlag = TRUE) then
              assert (PcgPdExtFlag = FALSE) report
              "WARNING : (tXP_CHECK) : tXP timing error!"
              severity WARNING;
              assert (SelfRefExt2NRFlag /= TRUE) report
              "ERROR : (tXSNR_CHECK) : Needs tXSNR Timing after Self Refresh."
              severity error;
              assert (now - last_aref >= tRFC) report
              "WARNING : (tRFC_CHECK) : tRFC timing error!"
              severity WARNING;
            end if;
            last_aref <= transport now after 1 ns;
            AutoRefFlag <= TRUE, FALSE after 2 ns;
            NextState := IDLE;
          When SREF =>
            if (TimingCheckFlag = TRUE) then
              assert (PcgPdExtFlag = FALSE) report
              "WARNING : (tXP_CHECK) : tXP timing error!"
              severity WARNING;
              assert (SelfRefExt2NRFlag /= TRUE) report
              "ERROR : (tXSNR_CHECK) : Needs tXSNR Timing after Self Refresh."
              severity error;
            end if;
            SelfRefFlag <= TRUE;
            NextState := SLFREF;
          When PDEN =>
            if (TimingCheckFlag = TRUE) then
              assert (PcgPdExtFlag = FALSE) report
              "WARNING : (tXP_CHECK) : tXP timing error!"
              severity WARNING;
              assert (SelfRefExt2NRFlag /= TRUE) report
              "ERROR : (tXSNR_CHECK) : Needs tXSNR Timing after Self Refresh."
              severity error;
            end if;
            PcgPdFlag <= TRUE;
            NextState := PWRDN;
          When EMRS3 =>
            NextState := IDLE;
            mrs_cmd_in <= transport '1', '0' after 2 ns;
          When EMRS1 =>
            OpCode := ADDR(12 downto 0);
            EXT_MODE_REGISTER_SET (OpCode, EMR);
            ExtModeRegister <= EMR;
            NextState := IDLE;
            if (ADDR(0) = '0') then
              DLL_lock_enable <= '1';
            end if;
            mrs_cmd_in <= transport '1', '0' after 2 ns;
         When EMRS2 =>
            OpCode := ADDR(12 downto 0);
            EXT_MODE_REGISTER_SET2 (OpCode, EMR2);
            ExtModeRegister2 <= EMR2;
            NextState := IDLE;
            mrs_cmd_in <= transport '1', '0' after 2 ns;
          When MRS =>
            if (TimingCheckFlag = TRUE) then
              assert (PcgPdExtFlag = FALSE) report
              "WARNING : (tXP_CHECK) : tXP timing error!"
              severity WARNING;
              assert (SelfRefExt2NRFlag /= TRUE) report
              "ERROR : (tXSNR_CHECK) : Needs tXSNR Timing after Self Refresh."
              severity error;
            end if;
            OpCode := ADDR(12 downto 0);
            MODE_REGISTER_SET (OpCode, MR);
            ModeRegister <= MR;
            ModeRegisterSetFlag <= TRUE;
            if (ADDR(8) = '1') then
              DLL_reset <= transport '1', '0' after 200 * clk_cycle;
            end if;
            NextState := IDLE; 
            mrs_cmd_in <= transport '1', '0' after 2 ns;
          When others =>
            assert false report
            "WARNING : (STATE_MACHINE) : Illegal Command Issued. Command Ignored."
            severity warning;
            NextState := IDLE;
        End Case;
      When PWRUP =>
        Case CurrentCommand Is
          When DSEL =>
            if (PUSCheckFlag = TRUE) then
              NextState := PWRUP;
            else
              NextState := IDLE;
            end if;
          When NOP =>
            if (PUSCheckFlag = TRUE) then
              NextState := PWRUP;
            else
              NextState := IDLE;
            end if;
          When EMRS3 =>
            NextState := PWRUP;
            mrs_cmd_in <= transport '1', '0' after 2 ns;
          When EMRS1 =>
            if (TimingCheckFlag = TRUE and PUSCheckFlag = TRUE) then
            assert (PUSPCGAFlag1 = TRUE) report
            "ERROR : (Power Up Sequence) : PCGA Command must be issued before EMRS setting!"
            severity error;
            end if;
            OpCode := ADDR(12 downto 0);
            EXT_MODE_REGISTER_SET (OpCode, EMR);
            ExtModeRegister <= EMR;
            NextState := PWRUP;
            if (ADDR(0) = '0') then
              DLL_lock_enable <= '1';
            end if; 
            mrs_cmd_in <= transport '1', '0' after 2 ns;
         When EMRS2 =>
            OpCode := ADDR(12 downto 0);
            EXT_MODE_REGISTER_SET2 (OpCode, EMR2);
            ExtModeRegister2 <= EMR2;
            NextState := PWRUP;
            mrs_cmd_in <= transport '1', '0' after 2 ns;
          When MRS =>
            if (TimingCheckFlag = TRUE) then
            assert (DLL_lock_enable = '1') report
            "WARNING : (STATE_MACHINE) : EMRS Command (with DLL enable flag) Must be Issued before MRS Command !"
            severity warning;
            end if;
            OpCode := ADDR(12 downto 0);
            MODE_REGISTER_SET (OpCode, MR);
            ModeRegister <= MR;
            ModeRegisterSetFlag <= TRUE;
            NextState := PWRUP;
            if (ADDR(8) = '1') then
              DLL_reset <= transport '1', '0' after 200 * clk_cycle;
            end if;
            mrs_cmd_in <= transport '1', '0' after 2 ns;
          When PCGA =>
            PrechargeAllFlag <= TRUE;
            NextState := PWRUP;
          When AREF =>
            AutoRefFlag <= TRUE, FALSE after 2 ns;
            if (PUSCheckFinFlag = TRUE) then
              NextState := IDLE;
            else
              NextState := PWRUP;
            end if;
            last_aref <= transport now after 1 ns;
          When others =>
            assert false report
            "ERROR : (STATE_MACHINE) : Invalid Command Issued during Power Up Sequence."
            severity error;
        End Case;
      When PWRDN =>
        Case CurrentCommand Is
          When NOP =>
            NextState := PWRDN;
          When PDEX =>
            if (PcgPdFlag = TRUE) then
              PcgPdExtFlag <= transport TRUE, FALSE after tXP * clk_cycle; 
              PcgPdFlag <= FALSE;
              NextState := IDLE;
            elsif (ModeRegister.SAPD = '0') then
              ActPdExtFlag <= transport TRUE, FALSE after tXARD * clk_cycle;
              NextState := RACT;
            elsif (ModeRegister.SAPD = '1') then
              SlowActPdExtFlag <= transport TRUE, FALSE after (6 - ExtModeRegister.AL) * clk_cycle;
              NextState := RACT;
            end if;
          When others =>
            assert false report
            "WARNING : (STATE_MACHINE) : Illegal Command Issued. Command Ignored."
            severity warning;
            NextState := PWRDN;
        End Case; 
      When SLFREF =>
        Case CurrentCommand Is
          When NOP =>
            NextState := SLFREF;
          When SREX =>
            SelfRefExt2NRFlag <= transport TRUE, FALSE after tXSNR;
            SelfRefExt2RDFlag <= transport TRUE, FALSE after tXSRD * clk_cycle;
            SelfRefFlag <= FALSE;
            NextState := IDLE;
          When others =>
            assert false report
            "WARNING : (STATE_MACHINE) : Illegal Command Issued. Command Ignored."
            severity warning;
            NextState := SLFREF;
        End Case;          
      When RACT =>
        Case CurrentCommand Is
          When DSEL =>
            NextState := RACT;
          When NOP =>
            NextState := RACT;
          When RD =>
            if (TimingCheckFlag = TRUE) then
              assert (SelfRefExt2RDFlag /= TRUE) report
              "ERROR : (tXSRD_CHECK) : Needs tXSRD Timing after Self Refresh."
              severity error;
              assert (ActPdExtFlag = FALSE) report
              "WARNING : (tXARD_CHECK) : tXARD timing error!"
              severity WARNING;
              assert (SlowActPdExtFlag = FALSE) report
              "WARNING : (tXARDS_CHECK) : tXARDS timing error!"
              severity WARNING;
            end if;
            Read_CA <= '1', '0' after 2 ns;
            NextState := READ;
          When RDAP =>
            if (TimingCheckFlag = TRUE) then
              assert (SelfRefExt2RDFlag /= TRUE) report
              "ERROR : (tXSRD_CHECK) : Needs tXSRD Timing after Self Refresh."
              severity error;
              assert (ActPdExtFlag = FALSE) report
              "WARNING : (tXARD_CHECK) : tXARD timing error!"
              severity WARNING;
              assert (SlowActPdExtFlag = FALSE) report
              "WARNING : (tXARDS_CHECK) : tXARDS timing error!"
              severity WARNING;
            end if;
            AutoPrechargeFlag(conv_integer(BkAdd)) <= transport 
                        '1' after (ExtModeRegister.AL + ModeRegister.BURST_LENGTH/2 - 2) * clk_cycle + tRTP,
                        '0' after (ExtModeRegister.AL + ModeRegister.BURST_LENGTH/2 - 2) * clk_cycle + tRTP + 2 ns;
            Read_CA <= '1', '0' after 2 ns;
            NextState := READ;
          When WR =>
            Write_CA <= '1', '0' after 2 ns;
            NextState := WRITE;
          When WRAP =>
            AutoPrechargeFlag(conv_integer(BkAdd)) <= transport 
                        '1' after (ExtModeRegister.AL + ModeRegister.CAS_LATENCY - 1 + 
                                    ModeRegister.BURST_LENGTH/2 + ModeRegister.TWR) * clk_cycle,
                        '0' after (ExtModeRegister.AL + ModeRegister.CAS_LATENCY - 1 +
                                    ModeRegister.BURST_LENGTH/2 + ModeRegister.TWR) * clk_cycle + 2 ns;
            Write_CA <= '1', '0' after 2 ns;
            NextState := WRITE;
          When ACT =>
            BankActivateFlag <= TRUE;
            NextState := RACT;
          When PCG =>
            PrechargeFlag <= TRUE;
            if ((BankActivatedFlag = "0001") or (BankActivatedFlag = "0010") or 
                (BankActivatedFlag = "0100") or (BankActivatedFlag = "1000")) then
              NextState := IDLE;
            else
              NextState := RACT;
            end if;
          When PCGA =>
            PrechargeAllFlag <= TRUE;
            NextState := IDLE;
          When PDEN =>
            NextState := PWRDN;
          When others =>
            assert false report
            "WARNING : (STATE_MACHINE) : Illegal Command Issued. Command Ignored."
            severity warning;
            NextState := RACT;
        End Case;
      When READ =>
        Case CurrentCommand Is
          When DSEL =>
            NextState := READ;
          When NOP =>
            NextState := READ;
          When RD =>
            if (TimingCheckFlag = TRUE) then
              assert (SelfRefExt2RDFlag /= TRUE) report
              "ERROR : (tXSRD_CHECK) : Needs tXSRD Timing after Self Refresh."
              severity error;
            end if;
            Read_CA <= '1', '0' after 2 ns;
            NextState := READ;
          When RDAP =>
            if (TimingCheckFlag = TRUE) then
              assert (SelfRefExt2RDFlag /= TRUE) report
              "ERROR : (tXSRD_CHECK) : Needs tXSRD Timing after Self Refresh."
              severity error;
            end if;
            AutoPrechargeFlag(conv_integer(BkAdd)) <= transport 
                        '1' after (ExtModeRegister.AL + ModeRegister.BURST_LENGTH/2 - 2) * clk_cycle + tRTP,
                        '0' after (ExtModeRegister.AL + ModeRegister.BURST_LENGTH/2 - 2) * clk_cycle + tRTP + 2 ns;
            Read_CA <= '1', '0' after 2 ns;
            NextState := READ;
          When WR =>
            Write_CA <= '1', '0' after 2 ns;
            NextState := WRITE;
          When WRAP =>
            AutoPrechargeFlag(conv_integer(BkAdd)) <= transport 
                        '1' after (ExtModeRegister.AL + ModeRegister.CAS_LATENCY - 1 +
                                    ModeRegister.BURST_LENGTH/2 + ModeRegister.TWR) * clk_cycle,
                        '0' after (ExtModeRegister.AL + ModeRegister.CAS_LATENCY - 1 +
                                    ModeRegister.BURST_LENGTH/2 + ModeRegister.TWR) * clk_cycle + 2 ns;
            Write_CA <= '1', '0' after 2 ns;
            NextState := WRITE;
          When ACT =>
            BankActivateFlag <= TRUE;
            NextState := READ;
          When PCG =>
            PrechargeFlag <= TRUE;
            NextState := READ;
          When PCGA =>
            PrechargeAllFlag <= TRUE;
            NextState := READ;
          When others =>
            assert false report
            "WARNING : (STATE_MACHINE) : Illegal Command Issued. Command Ignored."
            severity warning;
            NextState := READ;
        End Case;
      When WRITE =>
        Case CurrentCommand Is
          When DSEL =>
            NextState := WRITE;
          When NOP =>
            NextState := WRITE;
          When RD =>
            if (TimingCheckFlag = TRUE) then
              assert (SelfRefExt2RDFlag /= TRUE) report
              "ERROR : (tXSRD_CHECK) : Needs tXSRD Timing after Self Refresh."
              severity error;
            end if;
            Read_CA <= '1', '0' after 2 ns;
            NextState := READ;
          When RDAP =>
            if (TimingCheckFlag = TRUE) then
              assert (SelfRefExt2RDFlag /= TRUE) report
              "ERROR : (tXSRD_CHECK) : Needs tXSRD Timing after Self Refresh."
              severity error;
            end if;
            AutoPrechargeFlag(conv_integer(BkAdd)) <= transport 
                        '1' after (ExtModeRegister.AL + ModeRegister.BURST_LENGTH/2 - 2) * clk_cycle + tRTP,
                        '0' after (ExtModeRegister.AL + ModeRegister.BURST_LENGTH/2 - 2) * clk_cycle + tRTP + 2 ns;
            Read_CA <= '1', '0' after 2 ns;
            NextState := READ;
          When WR =>
            Write_CA <= '1', '0' after 2 ns;
            NextState := WRITE;
          When WRAP =>
            AutoPrechargeFlag(conv_integer(BkAdd)) <= transport 
                        '1' after (ExtModeRegister.AL + ModeRegister.CAS_LATENCY - 1 +
                                    ModeRegister.BURST_LENGTH/2 + ModeRegister.TWR) * clk_cycle,
                        '0' after (ExtModeRegister.AL + ModeRegister.CAS_LATENCY - 1 +
                                    ModeRegister.BURST_LENGTH/2 + ModeRegister.TWR) * clk_cycle + 2 ns;
            Write_CA <= '1', '0' after 2 ns;
            NextState := WRITE;
          When ACT =>
            BankActivateFlag <= TRUE;
            NextState := WRITE;
          When PCG =>
            PrechargeFlag <= TRUE;
            NextState := WRITE;
          When PCGA =>
            PrechargeAllFlag <= TRUE;
            NextState := WRITE;
          When others =>
            assert false report
            "WARNING : (STATE_MACHINE) : Illegal Command Issued. Command Ignored."
            severity warning;
            NextState := WRITE;
        End Case;
      When others =>
        assert false report
        "ERROR : (STATE_MACHINE) : Invalid Command Issued."
        severity error;
    End case;
  end if;
  if (BankActivateFinFlag = TRUE) then
    BankActivateFlag <= FALSE;
  end if;
  if (PrechargeFinFlag = TRUE) then
    PrechargeFlag <= FALSE;
  end if;
  if (PrechargeAllFinFlag = TRUE) then
    PrechargeAllFlag <= FALSE;
  end if;
  if (PUSCheckFinFlag'EVENT and PUSCheckFinFlag = TRUE) then
    NextState := IDLE;
  end if;
  if (BankActivatedFlag'EVENT and BankActivatedFlag /= BankActivatedFlag'LAST_VALUE) then
    if (BankActivatedFlag = "0000") then
      NextState := IDLE;
    else 
      NextState := RACT;
    end if;
  end if;
  CurrentState <= NextState;
end process;

-----------------------------------------------------------------------------------------------------

MEMORY_BANK_ACTIVATE_PRECHARGE : process (PrechargeFlag, AutoPrechargeFlag, PrechargeAllFlag, BankActivateFlag, CLK)

variable BkAdd : std_logic_vector ((NUM_OF_BANK_ADD - 1) downto 0) := (others => 'X');
variable RA : std_logic_vector ((NUM_OF_ROW_ADD - 1) downto 0) := (others => 'X');
variable MEM_CELL_ARRAY0, MEM_CELL_ARRAY1, MEM_CELL_ARRAY2, MEM_CELL_ARRAY3 : MEM_CELL_TYPE;
variable i, j, k, l, m, u : integer := 0;

begin
  if (CLK'EVENT and CLK = '0') then
    if ((BankActivateFlag = TRUE) or ((BankActivateFlag = FALSE) and (tmp_act_trans0 = '1'))) Then
      tmp_act_trans0 <= '0';
    end if;
    if ((BankActivateFlag = TRUE) or ((BankActivateFlag = FALSE) and (tmp_act_trans1 = '1'))) Then
      tmp_act_trans1 <= '0';
    end if;
    if ((BankActivateFlag = TRUE) or ((BankActivateFlag = FALSE) and (tmp_act_trans2 = '1'))) Then
      tmp_act_trans2 <= '0';
    end if;
    if ((BankActivateFlag = TRUE) or ((BankActivateFlag = FALSE) and (tmp_act_trans3 = '1'))) Then
      tmp_act_trans3 <= '0';
    end if;
  end if;
  if (BankActivateFlag'EVENT and BankActivateFlag = TRUE) then
    BkAdd := (BA);
    RA := ADDR(NUM_OF_ROW_ADD - 1 downto 0);
    BankActivatedFlag(conv_integer(BkAdd)) <= '1';
    i := 0;
    j := 0;
    u := 0;
    if (BankActivatedFlag (conv_integer (BkAdd)) = '1') then
      assert false report
      "WARNING : (MEMORY_BANK_ACTIVATE) : Activating same bank without precharge. Command Ignored."
      severity warning;
      BankActivateFinFlag <= TRUE, FALSE after 2 ns;
    elsif (BankActivatedFlag (conv_integer (BkAdd)) = '0') then
      if (TimingCheckFlag = TRUE) then
        if (now - refresh_check(conv_integer(BkAdd), conv_integer(RA)) > tREF) then
          assert false report
          "WARNING : (REFRESH_INTERVAL) : Refresh Interval Exceeds 64ms. So, This Row's Data Is Lost." 
          severity warning;  
        end if;    
      end if;    
      case BkAdd is 
        when "00" =>
          b0_last_activate <= transport now;
          RA_Activated_B0 <= RA;
        when "01" =>
          b1_last_activate <= transport now;
          RA_Activated_B1 <= RA;
        when "10" =>
          b2_last_activate <= transport now;
          RA_Activated_B2 <= RA;
        when "11" =>
          b3_last_activate <= transport now;
          RA_Activated_B3 <= RA;
        when others =>
          assert false report
          "WARNING : (MEMORY_REFRESH) : Impossible Bank Address"
          severity warning;
      end case;
      if (conv_integer (BkAdd) = 0) then
        if (MEM_CELL_ARRAY0(conv_integer (RA)) = NULL) then
          MEM_CELL_ARRAY0(conv_integer (RA)) := NEW ROW_DATA_TYPE;
          loop
            exit when u >= NUM_OF_COLS;
            MEM_CELL_ARRAY0(conv_integer (RA))(u) := 0;
            u := u + 1;
          end loop;
        end if;
        loop
          exit when i >= NUM_OF_COLS;
          SA_ARRAY_A0(i) <= MEM_CELL_ARRAY0(conv_integer (RA))(i);
          i := i + 1;
        end loop;
        tmp_act_trans0 <= '1';
      elsif (conv_integer (BkAdd) = 1) then
        if (MEM_CELL_ARRAY1(conv_integer (RA)) = NULL) then
          MEM_CELL_ARRAY1(conv_integer (RA)) := NEW ROW_DATA_TYPE;
          loop
            exit when u >= NUM_OF_COLS;
            MEM_CELL_ARRAY1(conv_integer (RA))(u) := 0;
            u := u + 1;
          end loop;
        end if;
        loop
          exit when i >= NUM_OF_COLS;
          SA_ARRAY_A1(i) <= MEM_CELL_ARRAY1(conv_integer (RA))(i);
          i := i + 1;
        end loop;
        tmp_act_trans1 <= '1';
      elsif (conv_integer (BkAdd) = 2) then
        if (MEM_CELL_ARRAY2(conv_integer (RA)) = NULL) then
          MEM_CELL_ARRAY2(conv_integer (RA)) := NEW ROW_DATA_TYPE;
          loop
            exit when u >= NUM_OF_COLS;
            MEM_CELL_ARRAY2(conv_integer (RA))(u) := 0;
            u := u + 1;
          end loop;
        end if;
        loop
          exit when i >= NUM_OF_COLS;
          SA_ARRAY_A2(i) <= MEM_CELL_ARRAY2(conv_integer (RA))(i);
          i := i + 1;
        end loop;
        tmp_act_trans2 <= '1';
      elsif (conv_integer (BkAdd) = 3) then
        if (MEM_CELL_ARRAY3(conv_integer (RA)) = NULL) then
          MEM_CELL_ARRAY3(conv_integer (RA)) := NEW ROW_DATA_TYPE;
          loop
            exit when u >= NUM_OF_COLS;
            MEM_CELL_ARRAY3(conv_integer (RA))(u) := 0;
            u := u + 1;
          end loop;
        end if;
        loop
          exit when i >= NUM_OF_COLS;
          SA_ARRAY_A3(i) <= MEM_CELL_ARRAY3(conv_integer (RA))(i);
          i := i + 1;
        end loop;
        tmp_act_trans3 <= '1';
      end if;
      BankActivateFinFlag <= TRUE, FALSE after 2 ns; 
    else
    end if;
  end if;
  if ((PrechargeFlag'EVENT and PrechargeFlag = TRUE) or 
      (AutoPrechargeFlag(0)'EVENT and AutoPrechargeFlag(0) = '1') or
      (AutoPrechargeFlag(1)'EVENT and AutoPrechargeFlag(1) = '1') or
      (AutoPrechargeFlag(2)'EVENT and AutoPrechargeFlag(2) = '1') or
      (AutoPrechargeFlag(3)'EVENT and AutoPrechargeFlag(3) = '1')) then
    i := 0;
    j := 0;
    if (PrechargeFlag = TRUE) then
      BkAdd := (BA);
    elsif (AutoPrechargeFlag(0) = '1') then
      BkAdd := "00";
    elsif (AutoPrechargeFlag(1) = '1') then
      BkAdd := "01";
    elsif (AutoPrechargeFlag(2) = '1') then
      BkAdd := "10";
    elsif (AutoPrechargeFlag(3) = '1') then
      BkAdd := "11";
    end if;
    if (BkAdd  = "00") then
      if (AutoPrechargeFlag(0) = '1' and (now - b0_last_activate) < tRAS) then
        b0_last_precharge <= transport (tRAS + b0_last_activate) after 1 ns;
      else
        b0_last_precharge <= transport now after 1 ns;
      end if;
      if (BankActivatedFlag (0) /= '1') then
        assert false report
        "WARNING : (MEMORY_PRECHARGE) : Precharging deactivated bank."
        severity warning;
      else
        RA := RA_Activated_B0;
        i := 0;
        loop
          exit when i >= NUM_OF_COLS;
          MEM_CELL_ARRAY0(conv_integer (RA))(i) := SA_ARRAY (conv_integer(BkAdd))(i);
          i := i + 1;
        end loop;
        if (AutoPrechargeFlag(0) = '1' and (now - b0_last_activate) < tRAS) then
          BankActivatedFlag (0) <= transport '0' after (tRAS - (now - b0_last_activate));
        else
          BankActivatedFlag (0) <= '0';
        end if;
        tmp_ref_addr2 <= RA&"00";
      end if;
    elsif (BkAdd = "01") then
      if (AutoPrechargeFlag(1) = '1' and (now - b1_last_activate) < tRAS) then
        b1_last_precharge <= transport (tRAS + b1_last_activate) after 1 ns;
      else
        b1_last_precharge <= transport now after 1 ns;
      end if;
      if (BankActivatedFlag (1) /= '1') then
        assert false report
        "WARNING : (MEMORY_PRECHARGE) : Precharging deactivated bank."
        severity warning;
      else
        RA := RA_Activated_B1;
        i := 0;
        loop
          exit when i >= NUM_OF_COLS;
          MEM_CELL_ARRAY1(conv_integer (RA))(i) := SA_ARRAY (conv_integer(BkAdd))(i);
          i := i + 1;
        end loop;
        if (AutoPrechargeFlag(1) = '1' and (now - b1_last_activate) < tRAS) then
          BankActivatedFlag (1) <= transport '0' after (tRAS - (now - b1_last_activate));
        else
          BankActivatedFlag (1) <= '0';
        end if;
        tmp_ref_addr2 <= RA&"01";
      end if;
    elsif (BkAdd = "10") then
      if (AutoPrechargeFlag(2) = '1' and (now - b2_last_activate) < tRAS) then
        b2_last_precharge <= transport (tRAS + b2_last_activate) after 1 ns;
      else
        b2_last_precharge <= transport now after 1 ns;
      end if;
      if (BankActivatedFlag (2) /= '1') then
        assert false report
        "WARNING : (MEMORY_PRECHARGE) : Precharging deactivated bank."
        severity warning;
      else
        RA := RA_Activated_B2;
        i := 0;
        loop
          exit when i >= NUM_OF_COLS;
          MEM_CELL_ARRAY2(conv_integer (RA))(i) := SA_ARRAY (conv_integer(BkAdd))(i);
          i := i + 1;
        end loop;
        if (AutoPrechargeFlag(2) = '1' and (now - b2_last_activate) < tRAS) then
          BankActivatedFlag (2) <= transport '0' after (tRAS - (now - b2_last_activate));
        else
          BankActivatedFlag (2) <= '0';
        end if;
        tmp_ref_addr2 <= RA&"10";
      end if;
    elsif (BkAdd = "11") then
      if (AutoPrechargeFlag(3) = '1' and (now - b3_last_activate) < tRAS) then
        b3_last_precharge <= transport (tRAS + b3_last_activate) after 1 ns;
      else
        b3_last_precharge <= transport now after 1 ns;
      end if;
      if (BankActivatedFlag (3) /= '1') then
        assert false report
        "WARNING : (MEMORY_PRECHARGE) : Precharging deactivated bank."
        severity warning;
      else
        RA := RA_Activated_B3;
        i := 0;
        loop
          exit when i >= NUM_OF_COLS;
          MEM_CELL_ARRAY3(conv_integer (RA))(i) := SA_ARRAY (conv_integer(BkAdd))(i);
          i := i + 1;
        end loop;
        if (AutoPrechargeFlag(3) = '1' and (now - b3_last_activate) < tRAS) then
          BankActivatedFlag (3) <= transport '0' after (tRAS - (now - b3_last_activate));
        else
          BankActivatedFlag (3) <= '0';
        end if;
        tmp_ref_addr2 <= RA&"11";
      end if;
    end if;
    if (PrechargeFlag = TRUE) then
      PrechargeFinFlag <= TRUE, FALSE after 2 ns;
    end if;
    tmp_ref_addr2_trans <= transport '1', '0' after 1 ns;
  end if;
  if (PrechargeAllFlag'EVENT and PrechargeAllFlag = TRUE) then
    if BankActivatedFlag (0) = '1' then
      BkAdd := "00";
      RA := RA_Activated_B0;
      i := 0;
      loop
        exit when i >= NUM_OF_COLS;
        MEM_CELL_ARRAY0(conv_integer (RA))(i) := SA_ARRAY (conv_integer(BkAdd))(i);
        i := i + 1;
      end loop;
      BankActivatedFlag (0) <= '0';
      tmp_ref_addr3_B0 <= RA;
      tmp_ref_addr3_0 <= transport '1', '0' after 1 ns;
      b0_last_precharge <= transport now after 1 ns;
    end if;
    if BankActivatedFlag (1) = '1' then
      BkAdd := "01";
      RA := RA_Activated_B1;
      i := 0;
      loop
        exit when i >= NUM_OF_COLS;
        MEM_CELL_ARRAY1(conv_integer (RA))(i) := SA_ARRAY (conv_integer(BkAdd))(i);
        i := i + 1;
      end loop;
      BankActivatedFlag (1) <= '0';
      tmp_ref_addr3_B1 <= RA;
      tmp_ref_addr3_1 <= transport '1', '0' after 1 ns;
      b1_last_precharge <= transport now after 1 ns;
    end if;
    if BankActivatedFlag (2) = '1' then
      BkAdd := "10";
      RA := RA_Activated_B2;
      i := 0;
      loop
        exit when i >= NUM_OF_COLS;
        MEM_CELL_ARRAY2(conv_integer (RA))(i) := SA_ARRAY (conv_integer(BkAdd))(i);
        i := i + 1;
      end loop;
      BankActivatedFlag (2) <= '0';
      tmp_ref_addr3_B2 <= RA;
      tmp_ref_addr3_2 <= transport '1', '0' after 1 ns;
      b2_last_precharge <= transport now after 1 ns;
    end if;
    if BankActivatedFlag (3) = '1' then
      BkAdd := "11";
      RA := RA_Activated_B3;
      i := 0;
      loop
        exit when i >= NUM_OF_COLS;
        MEM_CELL_ARRAY3(conv_integer (RA))(i) := SA_ARRAY (conv_integer(BkAdd))(i);
        i := i + 1;
      end loop;
      BankActivatedFlag (3) <= '0';
      tmp_ref_addr3_B3 <= RA;
      tmp_ref_addr3_3 <= transport '1', '0' after 1 ns;
      b3_last_precharge <= transport now after 1 ns;
    end if;
    tmp_ref_addr3_trans <= transport '1', '0' after 1 ns;
    if (BankActivatedFlag = "0000") then
      if (PUSCheckFinFlag = TRUE) then
        assert false report
        "WARNING : (PRECHARGE_ALL) : No Activated Banks, PCGA command ignored."
        severity WARNING;
      else
        BankActivatedFlag (0) <= '0';
        BankActivatedFlag (1) <= '0';
        BankActivatedFlag (2) <= '0';
        BankActivatedFlag (3) <= '0';
      end if;
    end if;
    PrechargeAllFinFlag <= TRUE, FALSE after 2 ns;
  end if;
end process; 

-----------------------------------------------------------------------------------------------------

SENSE_AMPLIFIER_UPDATE : process (tmp_act_trans0, tmp_act_trans1, tmp_act_trans2, tmp_act_trans3, tmp_w_trans0, tmp_w_trans1, tmp_w_trans2, tmp_w_trans3)
begin
  if (tmp_act_trans0'EVENT and tmp_act_trans0 = '1') then 
    SA_ARRAY(0) <= SA_ARRAY_A0; 
  elsif (tmp_act_trans1'EVENT and tmp_act_trans1 = '1') then 
    SA_ARRAY(1) <= SA_ARRAY_A1; 
  elsif (tmp_act_trans2'EVENT and tmp_act_trans2 = '1') then 
    SA_ARRAY(2) <= SA_ARRAY_A2; 
  elsif (tmp_act_trans3'EVENT and tmp_act_trans3 = '1') then 
    SA_ARRAY(3) <= SA_ARRAY_A3; 
  elsif (tmp_w_trans0'EVENT and tmp_w_trans0 = '1') then 
    SA_ARRAY(0) <= SA_ARRAY_W0; 
  elsif (tmp_w_trans1'EVENT and tmp_w_trans1 = '1') then 
    SA_ARRAY(1) <= SA_ARRAY_W1; 
  elsif (tmp_w_trans2'EVENT and tmp_w_trans2 = '1') then 
    SA_ARRAY(2) <= SA_ARRAY_W2; 
  elsif (tmp_w_trans3'EVENT and tmp_w_trans3 = '1') then 
    SA_ARRAY(3) <= SA_ARRAY_W3; 
  End if;
end process; 

-----------------------------------------------------------------------------------------------------

RD_WR_PIPE : process (CLK_DLY1, CLK)

variable CA : std_logic_vector ((NUM_OF_COL_ADD - 1) downto 0) := (others => 'X');
variable BkAdd : std_logic_vector ((NUM_OF_BANK_ADD - 1) downto 0) := (others => 'X');

begin

  if (CLK'EVENT and CLK = '1') then
    BkAdd := (BA);
    CA := ADDR(NUM_OF_COL_ADD - 1 downto 0);
  end if;
  if (CLK_DLY1'EVENT and CLK_DLY1 = '1') then
    RD_PIPE_REG(6 downto 1) <= RD_PIPE_REG(5 downto 0);
    WT_PIPE_REG(12 downto 1) <= WT_PIPE_REG(11 downto 0);
    ADD_PIPE_REG(12) <= ADD_PIPE_REG(11);
    ADD_PIPE_REG(11) <= ADD_PIPE_REG(10);
    ADD_PIPE_REG(10) <= ADD_PIPE_REG(9);
    ADD_PIPE_REG(9) <= ADD_PIPE_REG(8);
    ADD_PIPE_REG(8) <= ADD_PIPE_REG(7);
    ADD_PIPE_REG(7) <= ADD_PIPE_REG(6);
    ADD_PIPE_REG(6) <= ADD_PIPE_REG(5);
    ADD_PIPE_REG(5) <= ADD_PIPE_REG(4);
    ADD_PIPE_REG(4) <= ADD_PIPE_REG(3);
    ADD_PIPE_REG(3) <= ADD_PIPE_REG(2);
    ADD_PIPE_REG(2) <= ADD_PIPE_REG(1);
    ADD_PIPE_REG(1) <= ADD_PIPE_REG(0);
    if (Read_CA = '1' or Write_CA = '1') then
      ADD_PIPE_REG(0) <= BkAdd & CA;
      if (Read_CA = '1') then
        RD_PIPE_REG(0) <= '1';
      else
        RD_PIPE_REG(0) <= '0';
      end if;
      if (Write_CA = '1') then
        WT_PIPE_REG(0) <= '1';
      else
        WT_PIPE_REG(0) <= '0';
      end if;
    else
      ADD_PIPE_REG(0) <= (others => '0');
      RD_PIPE_REG(0) <= '0';
      WT_PIPE_REG(0) <= '0';
    end if;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

casp6_XX_Gen : process (RD_PIPE_REG, WT_PIPE_REG)

begin
  if (RD_PIPE_REG'event and RD_PIPE_REG(ExtModeRegister.AL) = '1') then
    casp6_rd <= transport '1' after 0.5 ns, '0' after 2 ns;
  elsif (WT_PIPE_REG'event and WT_PIPE_REG(ExtModeRegister.AL + ModeRegister.CAS_LATENCY - 2) = '1') then
    caspwt <= transport '1', '0' after 2 ns;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

RD_WT_Flag_GEN : process (caspwt, casp6_rd, ReadFinFlag, WriteFinFlag)

begin
  if (ReadFinFlag'EVENT and ReadFinFlag = TRUE) then
    ReadFlag <= FALSE;
  elsif (WriteFinFlag'EVENT and WriteFinFlag = TRUE) then
    WriteFlag <= FALSE;
  end if;
  if (casp6_rd'event and casp6_rd = '1') then
    ReadFlag <= TRUE;
  elsif (caspwt'event and caspwt = '1') then
    WriteFlag <= TRUE;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

WRITE_ST_GEN : process(CLK_DLY1, caspwt)

begin
  if (caspwt'event and caspwt = '1') then
    wt_stdby <= '1';
  end if;
  if (CLK_DLY1'event and CLK_DLY1 = '1') then
    if (casp_wtII = '1') then
      casp6_wt <= transport '1' after 0.5 ns, '0' after 2 ns;
    end if;
    casp_wtII <= casp_wtI;
    casp_wtI <= wt_stdby;
    wt_stdby <= '0';
  end if;
end process;

-----------------------------------------------------------------------------------------------------

YBURST_GEN : process (casp6_rd, casp6_wt, CLK, ReadFinFlag, WriteFinFlag)

begin
  if ((casp6_rd'event and casp6_rd = '1') or (casp6_wt'event and casp6_wt = '1')) then
    RD_WR_ST <= '1';
    yburst <= '0';
  end if;
  if (CLK'event and CLK = '1') then
    if (RD_WR_ST = '1' and ModeRegister.BURST_LENGTH = 8) then
      yburst <= transport '1' after 2.1 ns;
    end if;
    RD_WR_ST <= '0';
  end if;
  if ((ReadFinFlag'event and ReadFinFlag = TRUE) or (WriteFinFlag'event and WriteFinFlag = TRUE)) then
    yburst <= '0';
  end if;
end process;

-----------------------------------------------------------------------------------------------------

DQS_PULSE_GEN : process (CLK, casp6_rd)
 
begin

  if (casp6_rd'EVENT and casp6_rd = '1') then 
    dqs_pulse1 <= '1';
  end if;
  if (CLK'EVENT and CLK = '1') then
    dqs_pulse6 <= dqs_pulse5;
    dqs_pulse5 <= dqs_pulse4;
    dqs_pulse4 <= dqs_pulse3;
    dqs_pulse3 <= dqs_pulse2;
    dqs_pulse2 <= dqs_pulse1;
    dqs_pulse1 <= '0';
  end if;
end process;
  
-----------------------------------------------------------------------------------------------------

DQS_GENERATION : process(CLK, dqs_pulse1, dqs_pulse2, dqs_pulse3, dqs_pulse4, dqs_pulse5, dqs_pulse6)

begin
  if (CLK'event and CLK = '1') then
    if ((ModeRegister.CAS_LATENCY = 2 and dqs_pulse1 = '1') or
        (ModeRegister.CAS_LATENCY = 3 and dqs_pulse2 = '1') or
        (ModeRegister.CAS_LATENCY = 4 and dqs_pulse3 = '1') or
        (ModeRegister.CAS_LATENCY = 5 and dqs_pulse4 = '1') or
        (ModeRegister.CAS_LATENCY = 6 and dqs_pulse5 = '1')) then
      if (DQS_S = 'Z') then
        DQS_S <= '0';
      elsif (dqs_count = ModeRegister.BURST_LENGTH) then
        DQS_S <= '0';
      else
        DQS_S <= '1';
      end if;
    elsif ((ModeRegister.CAS_LATENCY = 2 and dqs_pulse2 = '1') or
           (ModeRegister.CAS_LATENCY = 3 and dqs_pulse3 = '1') or
           (ModeRegister.CAS_LATENCY = 4 and dqs_pulse4 = '1') or
           (ModeRegister.CAS_LATENCY = 5 and dqs_pulse5 = '1') or
           (ModeRegister.CAS_LATENCY = 6 and dqs_pulse6 = '1')) then
      if (DQS_S = '0') then
        DQS_S <= '1';
      end if;
      dqs_count <= 1;
    elsif (dqs_count = ModeRegister.BURST_LENGTH) then
      if (DQS_S = '0') then
        DQS_S <= 'Z';
      end if;
      dqs_count <= 0;
    elsif (DQS_S = '0') then
      DQS_S <= '1';
      dqs_count <= dqs_count + 1;
    end if;
  elsif (CLK'event and CLK = '0') then
    if (DQS_S = '1') then
      DQS_S <= '0';
      dqs_count <= dqs_count + 1;
    end if;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

DQS_OPERATION : process(DQS_S, ExtModeRegister.OCD_PGM)

begin
  if (ExtModeRegister.QOFF = '0') then
    if (ExtModeRegister.OCD_PGM'event and ExtModeRegister.OCD_PGM = DRIVE0) then
      UDQS <= '0';
      LDQS <= '0';
      if (ExtModeRegister.DQSB_ENB = '1') then
        UDQSB <= '1';
        LDQSB <= '1';
      else
        UDQSB <= 'Z';
        LDQSB <= 'Z';
      end if;
    elsif (ExtModeRegister.OCD_PGM'event and ExtModeRegister.OCD_PGM = DRIVE1) then
      UDQS <= '1';
      LDQS <= '1';
      if (ExtModeRegister.DQSB_ENB = '1') then
        UDQSB <= '0';
        LDQSB <= '0';
      else
        UDQSB <= 'Z';
        LDQSB <= 'Z';
      end if;
    elsif (ExtModeRegister.OCD_PGM'event and ExtModeRegister.OCD_PGM = CAL_EXIT) then
      UDQS <= 'Z';
      LDQS <= 'Z';
      UDQSB <= 'Z';
      LDQSB <= 'Z';
    elsif (DQS_S'event and DQS_S = '1') then
      UDQS <= '1';
      LDQS <= '1';
      if (ExtModeRegister.DQSB_ENB = '0') then
        UDQSB <= '0';
        LDQSB <= '0';
      else
        UDQSB <= 'Z';
        LDQSB <= 'Z';
      end if;
    elsif (DQS_S'event and DQS_S = '0') then
      UDQS <= '0';
      LDQS <= '0';
      if (ExtModeRegister.DQSB_ENB = '0') then
        UDQSB <= '1';
        LDQSB <= '1';
      else
        UDQSB <= 'Z';
        LDQSB <= 'Z';
      end if;
    elsif (DQS_S'event and DQS_S = 'Z' and DQS_S /= DQS_S'LAST_VALUE) then
      UDQS <= 'Z';
      LDQS <= 'Z';
      UDQSB <= 'Z';
      LDQSB <= 'Z';
    end if;
  else
    UDQS <= 'Z';
    LDQS <= 'Z';
    UDQSB <= 'Z';
    LDQSB <= 'Z';
  end if;
end process;

-----------------------------------------------------------------------------------------------------

MEMORY_READ : process (DQS_S, CLK_DLY2, ExtModeRegister.OCD_PGM)

variable BkAdd : std_logic_vector ((NUM_OF_BANK_ADD - 1) downto 0) := (others => 'X');
variable CRBI : integer := 0;
variable i, k, l : integer := 0;
begin
  if (CLK_DLY2'EVENT and CLK_DLY2 = '1') then
    if (casp6_rd = '1' or (ReadFlag = TRUE and yburst = '1')) then
      if (casp6_rd = '1') then
        BkAdd := ADD_PIPE_REG(ExtModeRegister.AL)(NUM_OF_BANK_ADD + NUM_OF_COL_ADD - 1 downto 
                                                  NUM_OF_BANK_ADD + NUM_OF_COL_ADD - 2);
        CRBI := 0;
      end if;
      if (BankActivatedFlag (conv_integer(BkAdd)) = '1') then
        DataBuffer(i, 0) <= conv_std_logic_vector(SA_ARRAY (conv_integer(BkAdd))(conv_integer(real_col_addr(0))), WORD_SIZE); 
        DataBuffer(i, 1) <= conv_std_logic_vector(SA_ARRAY (conv_integer(BkAdd))(conv_integer(real_col_addr(1))), WORD_SIZE); 
        DataBuffer(i, 2) <= conv_std_logic_vector(SA_ARRAY (conv_integer(BkAdd))(conv_integer(real_col_addr(2))), WORD_SIZE); 
        DataBuffer(i, 3) <= conv_std_logic_vector(SA_ARRAY (conv_integer(BkAdd))(conv_integer(real_col_addr(3))), WORD_SIZE); 
        i := i + 1;
        if (i = NUM_OF_BUFFERS) then
          i := 0;
        end if;
        CRBI := CRBI + 4;
        if (CRBI = ModeRegister.BURST_LENGTH) then
          ReadFinFlag <= TRUE, FALSE after 2 ns;
          CRBI := 0;
        end if;
      else
        assert false report
        "WARNING : (MEMORY_READ_PROCESS) : Accessing deactivated bank."
        severity WARNING;
        CRBI := CRBI + 4;
        if (CRBI = ModeRegister.BURST_LENGTH) then
          ReadFinFlag <= TRUE, FALSE after 2 ns;
          CRBI := 0;
        end if;
      end if;
    end if;
  end if;
  if (ExtModeRegister.OCD_PGM'event and ExtModeRegister.OCD_PGM = DRIVE0) then
    DQ <= (others => '0');
  elsif (ExtModeRegister.OCD_PGM'event and ExtModeRegister.OCD_PGM = DRIVE1) then
    DQ <= (others => '1');
  elsif (ExtModeRegister.OCD_PGM'event and ExtModeRegister.OCD_PGM = CAL_EXIT) then
    DQ <= (others => 'Z');
  end if;
  if (DQS_S'EVENT and DQS_S = '1' and DQS_S'LAST_VALUE = '0' and WriteFlag = FALSE) then
    DQ <= transport DataBuffer(k, l), (others => 'Z') after 0.5 * clk_cycle;
    l := l + 1;
  elsif (DQS_S'EVENT and DQS_S = '0' and DQS_S'LAST_VALUE = '1' and WriteFlag = FALSE) then
    DQ <= transport DataBuffer(k, l), (others => 'Z') after 0.5 * clk_cycle;
    if (l = 3) then
      l := 0;
      k := k + 1;    
      if (k = NUM_OF_BUFFERS) then
        k := 0;
      end if;
    else
      l := l + 1;
    end if;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

BURST_RD_WR_ADDR_GEN : process(CLK_DLY15, casp6_rd, casp6_wt, ReadFlag, WriteFlag)

variable CA : std_logic_vector ((NUM_OF_COL_ADD - 1) downto 0) := (others => 'X');
variable i, j : integer := 0;
variable col_addr_count : integer := 0;

begin
  if ((ReadFlag = FALSE) and (WriteFlag = FALSE)) then
    real_col_addr(0) <= (others => '0');
    real_col_addr(1) <= (others => '0');
    real_col_addr(2) <= (others => '0');
    real_col_addr(3) <= (others => '0');
    col_addr_count := 0;
    i := 0;
    j := 0;
  end if;
  if ((casp6_rd'EVENT and casp6_rd = '1') or (casp6_wt'EVENT and casp6_wt = '1') or
      (CLK_DLY15'EVENT and CLK_DLY15 = '1' and yburst = '1')) then
    if (casp6_rd = '1') then
      CA := ADD_PIPE_REG(ExtModeRegister.AL)(NUM_OF_COL_ADD - 1 downto 0);
      col_addr_count := 0;
      i := 0;
      j := 0;
    elsif (casp6_wt = '1') then
      CA := ADD_PIPE_REG(ExtModeRegister.AL + ModeRegister.CAS_LATENCY + 1)(NUM_OF_COL_ADD - 1 downto 0);
      col_addr_count := 0;
      i := 0;
      j := 0;
    end if;
    if (col_addr_count < ModeRegister.BURST_LENGTH/4) then
      loop
        exit when (j > 3);
        if ((col_addr_count = 0) and (j = 0)) then
          real_col_addr(0) <= CA;
        elsif (ModeRegister.BURST_LENGTH = 4) then
          if (ModeRegister.BURST_MODE = SEQUENTIAL) then
            real_col_addr(j) <= CA((NUM_OF_COL_ADD - 1) downto 2)& 
                        conv_std_logic_vector(remainder((conv_integer(CA(1 downto 0)) + i), 4), 2);
          elsif (ModeRegister.BURST_MODE = INTERLEAVE) then
            real_col_addr(j) <= CA((NUM_OF_COL_ADD - 1) downto 2)& 
                        xor_func(CA(1 downto 0), conv_std_logic_vector(i, 2)); 
          end if;
        elsif (ModeRegister.BURST_LENGTH = 8) then
          if (ModeRegister.BURST_MODE = SEQUENTIAL) then
            real_col_addr(j) <= CA((NUM_OF_COL_ADD - 1) downto 3)&
                        conv_std_logic_vector((conv_integer(CA(2)) + col_addr_count), 2)(0)&
                        conv_std_logic_vector(remainder((conv_integer(CA(1 downto 0)) + i), 4), 2);
          elsif (ModeRegister.BURST_MODE = INTERLEAVE) then
            real_col_addr(j) <= CA((NUM_OF_COL_ADD - 1) downto 3)&
                        xor_func(CA(2 downto 0), conv_std_logic_vector(i, 3));
          end if;
        end if;
        i := i + 1;
        j := j + 1;
      end loop;
    end if;
    j := 0;
    col_addr_count := col_addr_count + 1;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

MEMORY_WRITE : process (CLK_DLY2, LDQS, UDQS, CLK)

variable BkAdd : std_logic_vector ((NUM_OF_BANK_ADD - 1) downto 0) := (others => 'X');
variable TMP_VALUE : std_logic_vector ((WORD_SIZE - 1) downto 0) := (others => '0');
variable WriteDriver : SA_TYPE;
variable i, j, k, l, m : integer := 0;
variable CWBI : integer := 0;
variable dq_buffL, dq_buffH : DATA_BUFFER_TYPE;

begin
  if (CLK'event and CLK = '1') then
    dq_buffL(0) := dq_bufferL(0);
    dq_buffL(1) := dq_bufferL(1);
    dq_buffL(2) := dq_bufferL(2);
    dq_buffL(3) := dq_bufferL(3);
    dq_buffH(0) := dq_bufferH(0);
    dq_buffH(1) := dq_bufferH(1);
    dq_buffH(2) := dq_bufferH(2);
    dq_buffH(3) := dq_bufferH(3);
  end if;
  if (CLK_DLY2'EVENT and CLK_DLY2 = '1') then
    if (casp6_wt = '1' or (WriteFlag = TRUE and yburst = '1')) then
      if (casp6_wt = '1') then
        BkAdd := ADD_PIPE_REG(ExtModeRegister.AL + ModeRegister.CAS_LATENCY + 1)
                             (NUM_OF_BANK_ADD + NUM_OF_COL_ADD - 1 downto NUM_OF_BANK_ADD + NUM_OF_COL_ADD - 2);
        CWBI := 0;
        WriteDriver := SA_ARRAY (conv_integer(BkAdd));
      end if;
      if (BankActivatedFlag (conv_integer(BkAdd)) = '1') then
        TMP_VALUE := conv_std_logic_vector(WriteDriver(conv_integer(real_col_addr(0))), WORD_SIZE);
        if (dq_buffL(0)(8) = '0' and dq_buffH(0)(8) = '0') then
          TMP_VALUE := (dq_buffH(0)(7 downto 0) & dq_buffL(0)(7 downto 0));
        elsif (dq_buffL(0)(8) = '0' and dq_buffH(0)(8) = '1') then
          TMP_VALUE := (TMP_VALUE(15 downto 8) & dq_buffL(0)(7 downto 0));
        elsif (dq_buffL(0)(8) = '1' and dq_buffH(0)(8) = '0') then
          TMP_VALUE := (dq_buffH(0)(7 downto 0) & TMP_VALUE(7 downto 0));
        elsif (dq_buffL(0)(8) = '1' and dq_buffH(0)(8) = '1') then
          TMP_VALUE := (TMP_VALUE);
        end if;
        WriteDriver (conv_integer(real_col_addr(0))) := conv_integer(TMP_VALUE);

        TMP_VALUE := conv_std_logic_vector(WriteDriver(conv_integer(real_col_addr(1))), WORD_SIZE);
        if (dq_buffL(1)(8) = '0' and dq_buffH(1)(8) = '0') then
          TMP_VALUE := (dq_buffH(1)(7 downto 0) & dq_buffL(1)(7 downto 0));
        elsif (dq_buffL(1)(8) = '0' and dq_buffH(1)(8) = '1') then
          TMP_VALUE := (TMP_VALUE(15 downto 8) & dq_buffL(1)(7 downto 0));
        elsif (dq_buffL(1)(8) = '1' and dq_buffH(1)(8) = '0') then
          TMP_VALUE := (dq_buffH(1)(7 downto 0) & TMP_VALUE(7 downto 0));
        elsif (dq_buffL(1)(8) = '1' and dq_buffH(1)(8) = '1') then
          TMP_VALUE := (TMP_VALUE);
        end if;
        WriteDriver (conv_integer(real_col_addr(1))) := conv_integer(TMP_VALUE);

        TMP_VALUE := conv_std_logic_vector(WriteDriver(conv_integer(real_col_addr(2))), WORD_SIZE);
        if (dq_buffL(2)(8) = '0' and dq_buffH(2)(8) = '0') then
          TMP_VALUE := (dq_buffH(2)(7 downto 0) & dq_buffL(2)(7 downto 0));
        elsif (dq_buffL(2)(8) = '0' and dq_buffH(2)(8) = '1') then
          TMP_VALUE := (TMP_VALUE(15 downto 8) & dq_buffL(2)(7 downto 0));
        elsif (dq_buffL(2)(8) = '1' and dq_buffH(2)(8) = '0') then
          TMP_VALUE := (dq_buffH(2)(7 downto 0) & TMP_VALUE(7 downto 0));
        elsif (dq_buffL(2)(8) = '1' and dq_buffH(2)(8) = '1') then
          TMP_VALUE := (TMP_VALUE);
        end if;
        WriteDriver (conv_integer(real_col_addr(2))) := conv_integer(TMP_VALUE);

        TMP_VALUE := conv_std_logic_vector(WriteDriver(conv_integer(real_col_addr(3))), WORD_SIZE);
        if (dq_buffL(3)(8) = '0' and dq_buffH(3)(8) = '0') then
          TMP_VALUE := (dq_buffH(3)(7 downto 0) & dq_buffL(3)(7 downto 0));
        elsif (dq_buffL(3)(8) = '0' and dq_buffH(3)(8) = '1') then
          TMP_VALUE := (TMP_VALUE(15 downto 8) & dq_buffL(3)(7 downto 0));
        elsif (dq_buffL(3)(8) = '1' and dq_buffH(3)(8) = '0') then
          TMP_VALUE := (dq_buffH(3)(7 downto 0) & TMP_VALUE(7 downto 0));
        elsif (dq_buffL(3)(8) = '1' and dq_buffH(3)(8) = '1') then
          TMP_VALUE := (TMP_VALUE);
        end if;
        WriteDriver (conv_integer(real_col_addr(3))) := conv_integer(TMP_VALUE);
        if (conv_integer(BkAdd) = 0) then
          SA_ARRAY_W0 <= WriteDriver;
          tmp_w_trans0 <= '1', '0' after 2 ns;
          b0_last_data_in <= (now - 2 ns);
        elsif (conv_integer(BkAdd) = 1) then
          SA_ARRAY_W1 <= WriteDriver;
          tmp_w_trans1 <= '1', '0' after 2 ns;
          b1_last_data_in <= (now - 2 ns);
        elsif (conv_integer(BkAdd) = 2) then
          SA_ARRAY_W2 <= WriteDriver;
          tmp_w_trans2 <= '1', '0' after 2 ns;
          b2_last_data_in <= (now - 2 ns);
        elsif (conv_integer(BkAdd) = 3) then
          SA_ARRAY_W3 <= WriteDriver;
          tmp_w_trans3 <= '1', '0' after 2 ns;
          b3_last_data_in <= (now - 2 ns);
        end if;
        CWBI := CWBI + 4;
        if (CWBI = ModeRegister.BURST_LENGTH and casp_wtI /= '1' and caspwt /= '1') then
          WriteFinFlag <= transport TRUE, FALSE after 2 ns;
          CWBI := 0;
        end if;
      else
        assert false report
        "WARNING : (MEM_WRITE_PROCESS) : Accessing deactivated bank."
        severity WARNING;
        CWBI := CWBI + 4;
        if (CWBI = ModeRegister.BURST_LENGTH and casp_wtI /= '1' and caspwt /= '1') then
          WriteFinFlag <= transport TRUE, FALSE after 2 ns;
          CWBI := 0;
        end if;
      end if;
    end if;
  end if;
  if (LDQS'EVENT and LDQS = '0' and LDQS'LAST_VALUE = '1' and WriteFlag = TRUE) then
    dq_bufferL(2) <= transport dq_bufferL(6);
    dq_bufferL(1) <= transport dq_bufferL(5);
    dq_bufferL(0) <= transport dq_bufferL(4);
    dq_bufferL(3) <= transport (LDM & DQ(7 downto 0));
  end if;
  if (LDQS'EVENT and LDQS = '1' and WriteFlag = TRUE) then
    dq_bufferL(5) <= transport dq_bufferL(3);
    dq_bufferL(4) <= transport dq_bufferL(2);
    dq_bufferL(6) <= transport (LDM & DQ(7 downto 0));
  end if;
  if (UDQS'EVENT and UDQS = '0' and UDQS'LAST_VALUE = '1' and WriteFlag = TRUE) then
    dq_bufferH(2) <= transport dq_bufferH(6);
    dq_bufferH(1) <= transport dq_bufferH(5);
    dq_bufferH(0) <= transport dq_bufferH(4);
    dq_bufferH(3) <= transport (UDM & DQ(15 downto 8));
  end if;
  if (UDQS'EVENT and UDQS = '1' and WriteFlag = TRUE) then
    dq_bufferH(5) <= transport dq_bufferH(3);
    dq_bufferH(4) <= transport dq_bufferH(2);
    dq_bufferH(6) <= transport (UDM & DQ(15 downto 8));
  end if;
end process;

-----------------------------------------------------------------------------------------------------

REFRESH_COUNTER : process(AutoRefFlag, SelfRefFlag, CLK) 

variable rc : integer := 0;

begin
  if (AutoRefFlag'EVENT and AutoRefFlag = TRUE and TimingCheckFlag = TRUE) then
    if (rc >= 8192) then
      rc := rc - 8192;
    end if;
    if (now - refresh_check(0, rc) > tREF) then
      assert false report
      "WARNING : (REFRESH_INTERVAL) : Refresh Interval Exceeds 64ms for Bank0" 
      severity warning;
    end if;
    if (now - refresh_check(1, rc) > tREF) then
      assert false report
      "WARNING : (REFRESH_INTERVAL) : Refresh Interval Exceeds 64ms for Bank1" 
      severity warning;
    end if;
    if (now - refresh_check(2, rc) > tREF) then
      assert false report
      "WARNING : (REFRESH_INTERVAL) : Refresh Interval Exceeds 64ms for Bank2" 
      severity warning;
    end if;
    if (now - refresh_check(3, rc) > tREF) then
      assert false report
      "WARNING : (REFRESH_INTERVAL) : Refresh Interval Exceeds 64ms for Bank3" 
      severity warning;
    end if;
    tmp_ref_addr1 <= conv_std_logic_vector (rc, NUM_OF_ROW_ADD);
    tmp_ref_addr1_trans <= transport '1', '0' after 1 ns;
    rc := rc + 1;
  end if;
  if (CLK'EVENT and CLK = '1') then
    if (SelfRefFlag = TRUE and TimingCheckFlag = TRUE) then
      Ref_time <= Ref_time + clk_cycle; 
      if (Ref_time >= 7812.5 ns/(conv_integer(ExtModeRegister2.SREF_HOT) + 1)) then
        Ref_time <= 0 ns;
        if (rc >= 8192) then
          rc := rc - 8192;
        end if;
        if (now - refresh_check(0, rc) > tREF) then
          assert false report
          "WARNING : (REFRESH_INTERVAL) : Refresh Interval Exceeds 64ms for Bank0" 
          severity warning;
        end if;
        if (now - refresh_check(1, rc) > tREF) then
          assert false report
          "WARNING : (REFRESH_INTERVAL) : Refresh Interval Exceeds 64ms for Bank1" 
          severity warning;
        end if;
        if (now - refresh_check(2, rc) > tREF) then
          assert false report
          "WARNING : (REFRESH_INTERVAL) : Refresh Interval Exceeds 64ms for Bank2" 
          severity warning;
        end if;
        if (now - refresh_check(3, rc) > tREF) then
          assert false report
          "WARNING : (REFRESH_INTERVAL) : Refresh Interval Exceeds 64ms for Bank3" 
          severity warning;
        end if;
        tmp_ref_addr1 <= conv_std_logic_vector (rc, NUM_OF_ROW_ADD);
        tmp_ref_addr1_trans <= transport '1', '0' after 1 ns;
        rc := rc + 1;
      end if;
    end if;
  end if;
  if (SelfRefFlag = FALSE) then
    Ref_time <= 0 ns;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

PUS_CHECK : process(CLK, PrechargeAllFlag, AutoRefFlag, ModeRegister.DLL_STATE)

variable ChipSelectBar : std_logic := '0';
variable RowAddrStrobeBar : std_logic := '0';
variable ColAddrStrobeBar : std_logic := '0';
variable WriteEnableBar : std_logic := '0';
variable Address10 : std_logic := '0';
variable BkAdd : std_logic_vector((NUM_OF_BANK_ADD - 1) downto 0) := (others => 'X');
variable ClockEnable : CKE_TYPE := (others => '0');
variable CurrentCommand : COMMAND_TYPE := NOP;
variable i, j : integer := 0;
variable PUSNOP200USFlag : boolean := FALSE;
variable PUSAREF2Flag : boolean := FALSE;
variable BankActFlag : std_logic_vector((NUM_OF_BANKS - 1) downto 0) := (others => '0');
variable pus_aref : integer := 0;
variable Cur_State : STATE_TYPE := IDLE;

begin
  if (PUSCheckFinFlag /= TRUE and PUSCheckFlag = TRUE) then
    if (CLK'EVENT and CLK = '1') then
      cur_time <= transport now;
--      if (cur_time < 200000 ns) then
--        if (CKE /= '0') then
--          assert false report
--          "ERROR : (Power Up Sequence) : CKE Should Be '0' during initial 200us!"
--          severity error;
--        end if;
--      end if;
    end if;
    if (ModeRegister.DLL_STATE'EVENT and ModeRegister.DLL_STATE = RST and PUS_DLL_RESET = FALSE) then
      PUS_DLL_RESET <= TRUE;
    end if;
    if (PrechargeAllFlag'EVENT and PrechargeAllFlag = TRUE and CurrentState = PWRUP and TimingCheckFlag = TRUE) then
      if (PUSPCGAFlag1 = TRUE) then
        assert (PUS_DLL_RESET = TRUE) report
        "ERROR : (Power Up Sequence) : The 2nd PCGA Command Should Be Issued after DLL Reset!"
        severity error; 
      else
        PUSPCGAFlag1 <= TRUE;
--        assert (cur_time >= tPUS - clk_cycle) report
--        "WARNING : (Power Up Sequence) : PCGA Command Should Be Issued after 200us(Input Stable)!"
--        severity warning;
      end if;
    end if;
    if (AutoRefFlag'EVENT and AutoRefFlag = TRUE) then
      assert (PUSPCGAFlag2 = TRUE) report
      "WARNING : (Power Up Sequence) : Needs Precharge All Bank Command before Auto Refresh !"
      severity warning;
      pus_aref := pus_aref + 1;
      if (pus_aref >= 2) then
        PUSAREF2Flag := TRUE;
      end if;
      if ((PUSNOP200USFlag = TRUE) and (PUSAREF2Flag = TRUE)) then
        PUSCheckFinFlag <= TRUE;
      end if;
    end if;  
    ClockEnable := CKEN;
    if ClockEnable (-1) = '1' then
      ChipSelectBar := CSB;
      RowAddrStrobeBar := RASB;
      ColAddrStrobeBar := CASB;
      WriteEnableBar := WEB;
      Address10 := ADDR(10);
      BkAdd := (BA);
      BankActFlag := BankActivatedFlag;
    end if;
    COMMAND_DECODE (ChipSelectBar, RowAddrStrobeBar, ColAddrStrobeBar, WriteEnableBar,
                    Address10, BkAdd, ClockEnable, CurrentCommand, BankActFlag, Cur_State);
    if ((PUSNOP200USFlag = FALSE) and (PUSAREF2Flag /= TRUE)) then
      if (CLK = '1') then
        i := i + 1;
--        if (i * clk_cycle >= tPUS - clk_cycle) then
          PUSNOP200USFlag := TRUE;
--        end if;
      end if;
    elsif ((CurrentCommand = PCGA) and (PUSNOP200USFlag = TRUE) and (PUSPCGAFlag1 = TRUE) and (PUSAREF2Flag /= TRUE)) then
      PUSPCGAFlag2 <= TRUE;
    end if;
  elsif (PUSCheckFinFlag /= TRUE and PUSCheckFlag = FALSE) then
    PUSCheckFinFlag <= TRUE;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

BUS_CHANGE_DETECT : process(CKE, WEB, CASB, RASB, CSB, LDM, UDM, ADDR, DQ)

begin
    if (CKE'EVENT and CKE /= CKE'LAST_VALUE) then
      cke_ch <= transport now after 0.1 ns; end if;
    if (WEB'EVENT and WEB /= WEB'LAST_VALUE) then
      web_ch <= transport now after 0.1 ns; end if;
    if (CASB'EVENT and CASB /= CASB'LAST_VALUE) then
      casb_ch <= transport now after 0.1 ns; end if;
    if (RASB'EVENT and RASB /= RASB'LAST_VALUE) then
      rasb_ch <= transport now after 0.1 ns; end if;
    if (CSB'EVENT and CSB /= CSB'LAST_VALUE) then
      csb_ch <= transport now after 0.1 ns; end if;
    if (LDM'EVENT and LDM /= LDM'LAST_VALUE) then
      ldm_ch <= transport now after 0.1 ns; end if;
    if (UDM'EVENT and UDM /= UDM'LAST_VALUE) then
      udm_ch <= transport now after 0.1 ns; end if;
    if (ADDR(0)'EVENT and ADDR(0) /= ADDR(0)'LAST_VALUE) then
      a0_ch <= transport now after 0.1 ns; end if;
    if (ADDR(1)'EVENT and ADDR(1) /= ADDR(1)'LAST_VALUE) then
      a1_ch <= transport now after 0.1 ns; end if;
    if (ADDR(2)'EVENT and ADDR(2) /= ADDR(2)'LAST_VALUE) then
      a2_ch <= transport now after 0.1 ns; end if;
    if (ADDR(3)'EVENT and ADDR(3) /= ADDR(3)'LAST_VALUE) then
      a3_ch <= transport now after 0.1 ns; end if;
    if (ADDR(4)'EVENT and ADDR(4) /= ADDR(4)'LAST_VALUE) then
      a4_ch <= transport now after 0.1 ns; end if;
    if (ADDR(5)'EVENT and ADDR(5) /= ADDR(5)'LAST_VALUE) then
      a5_ch <= transport now after 0.1 ns; end if;
    if (ADDR(6)'EVENT and ADDR(6) /= ADDR(6)'LAST_VALUE) then
      a6_ch <= transport now after 0.1 ns; end if;
    if (ADDR(7)'EVENT and ADDR(7) /= ADDR(7)'LAST_VALUE) then
      a7_ch <= transport now after 0.1 ns; end if;
    if (ADDR(8)'EVENT and ADDR(8) /= ADDR(8)'LAST_VALUE) then
      a8_ch <= transport now after 0.1 ns; end if;
    if (ADDR(9)'EVENT and ADDR(9) /= ADDR(9)'LAST_VALUE) then
      a9_ch <= transport now after 0.1 ns; end if;
    if (ADDR(10)'EVENT and ADDR(10) /= ADDR(10)'LAST_VALUE) then
      a10_ch <= transport now after 0.1 ns; end if;
    if (ADDR(11)'EVENT and ADDR(11) /= ADDR(11)'LAST_VALUE) then
      a11_ch <= transport now after 0.1 ns; end if;
    if (ADDR(12)'EVENT and ADDR(12) /= ADDR(12)'LAST_VALUE) then
      a12_ch <= transport now after 0.1 ns; end if;
    if (BA(0)'EVENT and BA(0) /= BA(0)'LAST_VALUE) then
      ba0_ch <= transport now after 0.1 ns; end if;
    if (BA(1)'EVENT and BA(1) /= BA(1)'LAST_VALUE) then
      ba1_ch <= transport now after 0.1 ns; end if;
    if (DQ(0)'EVENT and STD_LOGIC_TO_BIT (DQ(0)) /= STD_LOGIC_TO_BIT (DQ(0)'LAST_VALUE)) then
      dq0_ch <= transport now after 0.1 ns; end if;
    if (DQ(1)'EVENT and STD_LOGIC_TO_BIT (DQ(1)) /= STD_LOGIC_TO_BIT (DQ(1)'LAST_VALUE)) then
      dq1_ch <= transport now after 0.1 ns; end if;
    if (DQ(2)'EVENT and STD_LOGIC_TO_BIT (DQ(2)) /= STD_LOGIC_TO_BIT (DQ(2)'LAST_VALUE)) then
      dq2_ch <= transport now after 0.1 ns; end if;
    if (DQ(3)'EVENT and STD_LOGIC_TO_BIT (DQ(3)) /= STD_LOGIC_TO_BIT (DQ(3)'LAST_VALUE)) then
      dq3_ch <= transport now after 0.1 ns; end if;
    if (DQ(4)'EVENT and STD_LOGIC_TO_BIT (DQ(4)) /= STD_LOGIC_TO_BIT (DQ(4)'LAST_VALUE)) then
      dq4_ch <= transport now after 0.1 ns; end if;
    if (DQ(5)'EVENT and STD_LOGIC_TO_BIT (DQ(5)) /= STD_LOGIC_TO_BIT (DQ(5)'LAST_VALUE)) then
      dq5_ch <= transport now after 0.1 ns; end if;
    if (DQ(6)'EVENT and STD_LOGIC_TO_BIT (DQ(6)) /= STD_LOGIC_TO_BIT (DQ(6)'LAST_VALUE)) then
      dq6_ch <= transport now after 0.1 ns; end if;
    if (DQ(7)'EVENT and STD_LOGIC_TO_BIT (DQ(7)) /= STD_LOGIC_TO_BIT (DQ(7)'LAST_VALUE)) then
      dq7_ch <= transport now after 0.1 ns; end if;
    if (DQ(8)'EVENT and STD_LOGIC_TO_BIT (DQ(8)) /= STD_LOGIC_TO_BIT (DQ(8)'LAST_VALUE)) then
      dq8_ch <= transport now after 0.1 ns; end if;
    if (DQ(9)'EVENT and STD_LOGIC_TO_BIT (DQ(9)) /= STD_LOGIC_TO_BIT (DQ(9)'LAST_VALUE)) then
      dq9_ch <= transport now after 0.1 ns; end if;
    if (DQ(10)'EVENT and STD_LOGIC_TO_BIT (DQ(10)) /= STD_LOGIC_TO_BIT (DQ(10)'LAST_VALUE)) then
      dq10_ch <= transport now after 0.1 ns; end if;
    if (DQ(11)'EVENT and STD_LOGIC_TO_BIT (DQ(11)) /= STD_LOGIC_TO_BIT (DQ(11)'LAST_VALUE)) then
      dq11_ch <= transport now after 0.1 ns; end if;
    if (DQ(12)'EVENT and STD_LOGIC_TO_BIT (DQ(12)) /= STD_LOGIC_TO_BIT (DQ(12)'LAST_VALUE)) then
      dq12_ch <= transport now after 0.1 ns; end if;
    if (DQ(13)'EVENT and STD_LOGIC_TO_BIT (DQ(13)) /= STD_LOGIC_TO_BIT (DQ(13)'LAST_VALUE)) then
      dq13_ch <= transport now after 0.1 ns; end if;
    if (DQ(14)'EVENT and STD_LOGIC_TO_BIT (DQ(14)) /= STD_LOGIC_TO_BIT (DQ(14)'LAST_VALUE)) then
      dq14_ch <= transport now after 0.1 ns; end if;
    if (DQ(15)'EVENT and STD_LOGIC_TO_BIT (DQ(15)) /= STD_LOGIC_TO_BIT (DQ(15)'LAST_VALUE)) then
      dq15_ch <= transport now after 0.1 ns; end if;
end process;

-----------------------------------------------------------------------------------------------------

CLK_TIMING : process (CLK)
  variable clk_last_cycle : time := 0 ns;
  variable i : integer := 0;
begin
  if (CLK'event and CLK='1') then
        if (Part_Number = B400) then
          tRCD <= ModeRegister.CAS_LATENCY * 5 ns;
          tRP <= ModeRegister.CAS_LATENCY * 5 ns;
          if (ModeRegister.CAS_LATENCY = 3) then
            tRAS <= 40 ns;
          else
            tRAS <= 45 ns;
          end if;
        elsif (Part_Number = B533) then
          tRCD <= ModeRegister.CAS_LATENCY * 3.75 ns;
          tRP <= ModeRegister.CAS_LATENCY * 3.75 ns;
          tRAS <= 45 ns;
        elsif (Part_Number = B667) then
          tRCD <= ModeRegister.CAS_LATENCY * 3 ns;
          tRP <= ModeRegister.CAS_LATENCY * 3 ns;
          tRAS <= 45 ns;
        elsif (Part_Number = B800) then
          tRCD <= ModeRegister.CAS_LATENCY * 2.5 ns;
          tRP <= ModeRegister.CAS_LATENCY * 2.5 ns;
          tRAS <= 45 ns;
        end if;
        tRC <= tRAS + tRP;
        tCCD <= 2 * clk_cycle;
        tDQSH <= 0.35 * clk_cycle;
        tDQSL <= 0.35 * clk_cycle;
        tWPSTmin <= 0.4 * clk_cycle;
        tWPSTmax <= 0.6 * clk_cycle;
        tDQSSmin <= 0.75 * clk_cycle;
        tDQSSmax <= 1.25 * clk_cycle;
        tMRD <= 2 * clk_cycle;
        tWPRE <= 0.25 * clk_cycle;
        tCH <= 0.45 * clk_cycle;
        tCL <= 0.45 * clk_cycle;
    if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
      assert (clk_cycle >= tCKmin (Part_Number)) report
      "ERROR : (CLK_TIMING) : Clock period is too small."
      severity error;
      assert (clk_cycle <= tCKmax (Part_Number)) report
      "ERROR : (CLK_TIMING) : Clock period is too large."
      severity error;
    end if;
    assert (now - clk_last_falling >= tCL) report
    "ERROR : (CLK_TIMING) : Clock low time is too small."
    severity error;
    clk_last_rising <= transport now;
  end if;
  if (CLK'event and CLK = '0') then
    clk_last_falling <= transport now;
    if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
      assert (now - clk_last_rising >= tCH) report
      "ERROR : (CLK_TIMING) : Clock high time is too small."
      severity error;
    end if;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

DQS_TIMING : process (LDQS, UDQS, caspwt)

begin
  if (caspwt'EVENT and caspwt = '1') then
    wr_cmd_time <= transport now - 1 ns;
    udspre_enable <= '0';
    ldspre_enable <= '0';
    udsh_dsl_enable <= '0';
    ldsh_dsl_enable <= '0';
  end if;
  if (TimingCheckFlag = TRUE) then
    if (UDQS'EVENT and UDQS = '0' and UDQS'LAST_VALUE = 'Z' and WriteFlag = TRUE) then
      udspre_enable <= '1';
    end if;
    if (LDQS'EVENT and LDQS = '0' and LDQS'LAST_VALUE = 'Z' and WriteFlag = TRUE) then
      ldspre_enable <= '1';
    end if;
    if (UDQS'EVENT and UDQS = '1' and UDQS'LAST_VALUE = '0' and WriteFlag = TRUE) then
      udqs_last_rising <= transport now;
      if (udspre_enable = '1') then
        if ((now - clk_last_falling) < tWPRE) then
          assert false report
          "WARNING : (tWPRE_CHECK) : tWPRE time violation!" 
          severity WARNING;
        end if;
        if ((now - wr_cmd_time) < tDQSSmin) then
          assert false report
          "WARNING : (tDQSS_CHECK) : Minimum tDQSS time violation!"
          severity WARNING;
        end if;
        if ((now - wr_cmd_time) > tDQSSmax) then
          assert false report
          "WARNING : (tDQSS_CHECK) : Maximum tDQSS time violation!"
          severity WARNING;
        end if;
        udspre_enable <= '0';
        udsh_dsl_enable <= '1';
      elsif (udsh_dsl_enable = '1') then
        if ((now - udqs_last_falling) < tDQSL) then
          assert false report
          "ERROR : (tDQSL_CHECK) : Minimum tDQSL time violation!" 
          severity ERROR;
        end if;
      end if;
    elsif (UDQS'EVENT and UDQS = '0' and UDQS'LAST_VALUE = '1' and WriteFlag = TRUE) then
      udqs_last_falling <= transport now;
      if (udsh_dsl_enable = '1') then
        if ((now - udqs_last_rising) < tDQSH) then
          assert false report
          "ERROR : (tDQSH_CHECK) : Minimum tDQSH time violation!" 
          severity ERROR;
        end if;
      end if;
      udspre_enable <= '0';
      ldspre_enable <= '0';
    end if;
    if (LDQS'EVENT and LDQS = '1' and LDQS'LAST_VALUE = '0' and WriteFlag = TRUE) then
      ldqs_last_rising <= transport now;
      if (ldspre_enable = '1') then
        if ((now - clk_last_falling) < tWPRE) then
          assert false report
          "WARNING : (tWPRE_CHECK) : tWPRE time violation!" 
          severity WARNING;
        end if;
        if ((now - wr_cmd_time) < tDQSSmin) then
          assert false report
          "WARNING : (tDQSS_CHECK) : Minimum tDQSS time violation!"
          severity WARNING;
        end if;
        if ((now - wr_cmd_time) > tDQSSmax) then
          assert false report
          "WARNING : (tDQSS_CHECK) : Maximum tDQSS time violation!"
          severity WARNING;
        end if;
        ldspre_enable <= '0';
        ldsh_dsl_enable <= '1';
      elsif (ldsh_dsl_enable = '1') then
        if ((now - ldqs_last_falling) < tDQSL) then
          assert false report
          "ERROR : (tDQSL_CHECK) : Minimum tDQSL time violation!" 
          severity ERROR;
        end if;
      end if;
    elsif (LDQS'EVENT and LDQS = '0' and LDQS'LAST_VALUE = '1' and WriteFlag = TRUE) then
      ldqs_last_falling <= transport now;
      if (ldsh_dsl_enable = '1') then
        if ((now - ldqs_last_rising) < tDQSH) then
            assert false report
          "ERROR : (tDQSH_CHECK) : Minimum tDQSH time violation!" 
          severity ERROR;
        end if;
      end if;
      udspre_enable <= '0';
      ldspre_enable <= '0';
    end if;
    if (LDQS'EVENT and LDQS = 'Z' and LDQS'LAST_VALUE = '0' and WriteFlag = TRUE and caspwt = '0') then
      if ((now - ldqs_last_falling) < tWPSTmin) then
        assert false report
        "WARNING : (tWPST_CHECK) : Minimum tWPST time violation!"
        severity WARNING;
      end if;
      if ((now - ldqs_last_falling) > tWPSTmax) then
        assert false report
        "WARNING : (tWPST_CHECK) : Maximum tWPST time violation!"
        severity WARNING;
      end if;
      ldspre_enable <= '0';
      ldsh_dsl_enable <= '0';
    end if;
    if (UDQS'EVENT and UDQS = 'Z' and UDQS'LAST_VALUE = '0' and WriteFlag = TRUE and caspwt = '0') then
      if ((now - udqs_last_falling) < tWPSTmin) then
        assert false report
        "WARNING : (tWPST_CHECK) : Minimum tWPST time violation!"
        severity WARNING;
      end if;
      if ((now - udqs_last_falling) > tWPSTmax) then
        assert false report
        "WARNING : (tWPST_CHECK) : Maximum tWPST time violation!"
        severity WARNING;
      end if;
      udspre_enable <= '0';
      udsh_dsl_enable <= '0';
    end if;
  end if;
end process;

-----------------------------------------------------------------------------------------------------

SETUP_CHECK : process (CLK, UDQS, LDQS)
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  if (((UDQS'EVENT and UDQS = '1' and UDQS'LAST_VALUE = '0') or (UDQS'EVENT and UDQS = '0') or
      (LDQS'EVENT and LDQS = '1' and LDQS'LAST_VALUE = '0') or (LDQS'EVENT and LDQS = '0')) and 
      (WriteFlag = TRUE)) then
    assert (
      ((now - dq0_ch) >= tDS (Part_Number)) and
      ((now - dq1_ch) >= tDS (Part_Number)) and
      ((now - dq2_ch) >= tDS (Part_Number)) and
      ((now - dq3_ch) >= tDS (Part_Number)) and
      ((now - dq4_ch) >= tDS (Part_Number)) and
      ((now - dq5_ch) >= tDS (Part_Number)) and
      ((now - dq6_ch) >= tDS (Part_Number)) and
      ((now - dq7_ch) >= tDS (Part_Number)) and
      ((now - dq8_ch) >= tDS (Part_Number)) and
      ((now - dq9_ch) >= tDS (Part_Number)) and
      ((now - dq10_ch) >= tDS (Part_Number)) and
      ((now - dq11_ch) >= tDS (Part_Number)) and
      ((now - dq12_ch) >= tDS (Part_Number)) and
      ((now - dq13_ch) >= tDS (Part_Number)) and
      ((now - dq14_ch) >= tDS (Part_Number)) and
      ((now - dq15_ch) >= tDS (Part_Number))) report
    "ERROR : (SETUP_HOLD) : Data input setup/hold time violation."
    severity error;
  end if;
  if (CLK'EVENT and CLK = '1') then
    assert (
      ((now - a0_ch) >= tIS (Part_Number)) and
      ((now - a1_ch) >= tIS (Part_Number)) and
      ((now - a2_ch) >= tIS (Part_Number)) and
      ((now - a3_ch) >= tIS (Part_Number)) and
      ((now - a4_ch) >= tIS (Part_Number)) and
      ((now - a5_ch) >= tIS (Part_Number)) and
      ((now - a6_ch) >= tIS (Part_Number)) and
      ((now - a7_ch) >= tIS (Part_Number)) and
      ((now - a8_ch) >= tIS (Part_Number)) and
      ((now - a9_ch) >= tIS (Part_Number)) and
      ((now - a10_ch) >= tIS (Part_Number)) and
      ((now - a11_ch) >= tIS (Part_Number)) and 
      ((now - a12_ch) >= tIS (Part_Number)) and 
      ((now - ba0_ch) >= tIS (Part_Number)) and
      ((now - ba1_ch) >= tIS (Part_Number))) report
    "ERROR : (SETUP_HOLD) : Address input setup time violation."
    severity error;
    assert (
      ((now - csb_ch) >= tIS (Part_Number)) and
      ((now - rasb_ch) >= tIS (Part_Number)) and
      ((now - casb_ch) >= tIS (Part_Number)) and
      ((now - web_ch) >= tIS (Part_Number))) report
    "ERROR : (SETUP_HOLD) : Command input setup time violation."
    severity error;
    assert (now - cke_ch >= tIS (Part_Number)) report
    "ERROR : (SETUP_HOLD) : Clock enable input setup time violation."
    severity error;
  end if;
end if;
end process;

-----------------------------------------------------------------------------------------------------

DM_SETUP_HOLD_CHECK : process (LDM, UDM, LDQS, UDQS)
begin
if (TimingCheckFlag = TRUE) then
  if (LDM'EVENT and LDM = '1' and WriteFlag = TRUE) then
    ldm_last_rising <= transport now;
  elsif (LDM'EVENT and LDM = '0' and WriteFlag = TRUE) then
    if ((now - ldqs_last_rising) < tDH (Part_Number)) then
      assert false report
      "ERROR : (tDH_CHECK) : LDM Hold Time Violation!"
      severity ERROR;
    end if;
  end if;
  if (UDM'EVENT and UDM = '1' and WriteFlag = TRUE) then
    udm_last_rising <= transport now;
  elsif (UDM'EVENT and UDM = '0' and WriteFlag = TRUE) then
    if ((now - udqs_last_rising) < tDH (Part_Number)) then
      assert false report
      "ERROR : (tDH_CHECK) : UDM Hold Time Violation!"
      severity ERROR;
    end if;
  end if;
  if (LDQS'EVENT and LDQS = '1' and LDQS'LAST_VALUE = '0' and WriteFlag = TRUE) then
    if ((now - ldm_last_rising) < tDS (Part_Number)) then
      assert false report
      "ERROR : (tDS_CHECK) : LDM Setup Time Violation!"
      severity ERROR;
    end if;
  end if;
  if (UDQS'EVENT and UDQS = '1' and UDQS'LAST_VALUE = '0' and WriteFlag = TRUE) then
    if ((now - udm_last_rising) < tDS (Part_Number)) then
      assert false report
      "ERROR : (tDS_CHECK) : UDM Setup Time Violation!"
      severity ERROR;
    end if;
  end if;
end if;
end process;
-----------------------------------------------------------------------------------------------------

A_HOLD_CHECK : process (ADDR)
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  assert ((now - clk_last_rising) >= tIH (Part_Number)) report
  "ERROR : (SETUP_HOLD) : Address hold time violation."
  severity error;
end if;
end process;

-----------------------------------------------------------------------------------------------------

UDQ_HOLD_CHECK : process (DQ(15 downto 8))
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE and WriteFlag = TRUE) then
  assert ((now - udqs_last_rising) >= tDH (Part_Number)) report
  "ERROR : (SETUP_HOLD) : Hold time violation of CLK rising-edge aligned data." 
  severity error;
  assert ((now - udqs_last_falling) >= tDH (Part_Number)) report
  "ERROR : (SETUP_HOLD) : Hold time violation of CLK falling-edge aligned data."
  severity error;
end if;
end process;

-----------------------------------------------------------------------------------------------------

LDQ_HOLD_CHECK : process (DQ(7 downto 0))
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE and WriteFlag = TRUE) then
  assert ((now - ldqs_last_rising) >= tDH (Part_Number)) report
  "ERROR : (SETUP_HOLD) : Hold time violation of CLK rising-edge aligned data."
  severity error;
  assert ((now - udqs_last_falling) >= tDH (Part_Number)) report
  "ERROR : (SETUP_HOLD) : Hold time violation of CLK falling-edge aligned data."
  severity error;
end if;
end process;
-----------------------------------------------------------------------------------------------------

CMD_HOLD_CHECK : process (CSB, WEB, RASB, CASB)
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  assert ((now - clk_last_rising) >= tIH (Part_Number)) report
  "ERROR : (SETUP_HOLD) : Command hold time violation."
  severity error;
end if;
end process;

-----------------------------------------------------------------------------------------------------

CKE_HOLD_CHECK : process (CKE)
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  assert ((now - clk_last_rising) >= tIH (Part_Number)) report
  "ERROR : (SETUP_HOLD) : Clock enable hold time violation."
  severity error;
end if;
end process;

-----------------------------------------------------------------------------------------------------

tRC_CHECK : process (BankActivateFlag)
variable BkAdd : std_logic_vector((NUM_OF_BANK_ADD - 1) downto 0) := (others => 'X');
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  BkAdd := (BA);
  if (BkAdd = "00" and (BankActivateFlag'EVENT and BankActivateFlag = TRUE)) then
    assert ((now - b0_last_activate) >= tRC) report
    "ERROR : (tRC_CHECK) : Row Address Strobe cycle time violation."
    severity error;
  elsif (BkAdd = "01" and (BankActivateFlag'EVENT and BankActivateFlag = TRUE)) then
    assert ((now - b1_last_activate) >= tRC) report
    "ERROR : (tRC_CHECK) : Row Address Strobe cycle time violation."
    severity error;
  elsif (BkAdd = "10" and (BankActivateFlag'EVENT and BankActivateFlag = TRUE)) then
    assert ((now - b2_last_activate) >= tRC) report
    "ERROR : (tRC_CHECK) : Row Address Strobe cycle time violation."
    severity error;
  elsif (BkAdd = "11" and (BankActivateFlag'EVENT and BankActivateFlag = TRUE)) then
    assert ((now - b3_last_activate) >= tRC) report
    "ERROR : (tRC_CHECK) : Row Address Strobe cycle time violation."
    severity error;
  end if;
end if;
end process;

-----------------------------------------------------------------------------------------------------

tRCD_CHECK : process (casp6_rd, casp6_wt)
variable BkAdd : std_logic_vector((NUM_OF_BANK_ADD - 1) downto 0) := (others => 'X');
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  BkAdd := (BA);
  if (BkAdd = "00" and ((casp6_rd'event and casp6_rd = '1') or (casp6_wt'event and casp6_wt = '1'))) then
    assert ((now - b0_last_activate - 1.5 ns) >= tRCD) report
    "ERROR : (tRCD_CHECK) : Active to column Access delay time violation."
    severity error;
    b0_last_column_access <= transport now after 1 ns;
  elsif (BkAdd = "01" and ((casp6_rd'event and casp6_rd = '1') or (casp6_wt'event and casp6_wt = '1'))) then
    assert ((now - b1_last_activate - 1.5 ns) >= tRCD) report
    "ERROR : (tRCD_CHECK) : Active to column Access delay time violation."
    severity error;
    b1_last_column_access <= transport now after 1 ns;
  elsif (BkAdd = "10" and ((casp6_rd'event and casp6_rd = '1') or (casp6_wt'event and casp6_wt = '1'))) then
    assert ((now - b2_last_activate - 1.5 ns) >= tRCD) report
    "ERROR : (tRCD_CHECK) : Active to column Access delay time violation."
    severity error;
    b2_last_column_access <= transport now after 1 ns;
  elsif (BkAdd = "11" and ((casp6_rd'event and casp6_rd = '1') or (casp6_wt'event and casp6_wt = '1'))) then
    assert ((now - b3_last_activate - 1.5 ns) >= tRCD) report
    "ERROR : (tRCD_CHECK) : Active to column Access delay time violation."
    severity error;
    b3_last_column_access <= transport now after 1 ns;
  end if;
end if;
end process;

-----------------------------------------------------------------------------------------------------

tRAS_CHECK : process (BankActivatedFlag(0), BankActivatedFlag(1), BankActivatedFlag(2), BankActivatedFlag(3))
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  if (BankActivatedFlag(0)'EVENT and BankActivatedFlag(0) = '0' and BankActivatedFlag(0)'LAST_VALUE = '1') then
    assert ((now - b0_last_activate) >= tRAS) report
    "ERROR : (tRAS_CHECK) : Bank0 active time minimum violation."
    severity error;
    assert ((now - b0_last_activate) <= tRASmax (Part_Number)) report
    "ERROR : (tRAS_CHECK) : Bank0 active time maximum violation."
    severity error;
  end if;
  if (BankActivatedFlag(1)'EVENT and BankActivatedFlag(1) = '0' and BankActivatedFlag(1)'LAST_VALUE = '1') then
    assert ((now - b1_last_activate) >= tRAS) report
    "ERROR : (tRAS_CHECK) : Bank1 active time minimum violation."
    severity error;
    assert ((now - b1_last_activate) <= tRASmax (Part_Number)) report
    "ERROR : (tRAS_CHECK) : Bank1 active time maximum violation."
    severity error;
  end if;
  if (BankActivatedFlag(2)'EVENT and BankActivatedFlag(2) = '0' and BankActivatedFlag(2)'LAST_VALUE = '1') then
    assert ((now - b2_last_activate) >= tRAS) report
    "ERROR : (tRAS_CHECK) : Bank2 active time minimum violation."
    severity error;
    assert ((now - b2_last_activate) <= tRASmax (Part_Number)) report
    "ERROR : (tRAS_CHECK) : Bank2 active time maximum violation."
    severity error;
  end if;
  if (BankActivatedFlag(3)'EVENT and BankActivatedFlag(3) = '0' and BankActivatedFlag(3)'LAST_VALUE = '1') then
    assert ((now - b3_last_activate) >= tRAS) report
    "ERROR : (tRAS_CHECK) : Bank3 active time minimum violation."
    severity error;
    assert ((now - b3_last_activate) <= tRASmax (Part_Number)) report
    "ERROR : (tRAS_CHECK) : Bank3 active time maximum violation."
    severity error;
  end if;
end if;
end process;

-----------------------------------------------------------------------------------------------------

tRP_CHECK : process (BankActivateFlag)
variable BkAdd : std_logic_vector((NUM_OF_BANK_ADD - 1) downto 0) := (others => 'X');
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  BkAdd := (BA);
  if (BkAdd = "00" and (BankActivateFlag'event and BankActivateFlag = TRUE)) then
    assert ((now - b0_last_precharge) >= tRP) report
    "ERROR : (tRP_CHECK) : Precharge to active delay time violation."
    severity error;
  elsif (BkAdd = "01" and (BankActivateFlag'event and BankActivateFlag = TRUE)) then
    assert ((now - b1_last_precharge) >= tRP) report
    "ERROR : (tRP_CHECK) : Precharge to active delay time violation."
    severity error;
  elsif (BkAdd = "10" and (BankActivateFlag'event and BankActivateFlag = TRUE)) then
    assert ((now - b2_last_precharge) >= tRP) report
    "ERROR : (tRP_CHECK) : Precharge to active delay time violation."
    severity error;
  elsif (BkAdd = "11" and (BankActivateFlag'event and BankActivateFlag = TRUE)) then
    assert ((now - b3_last_precharge) >= tRP) report
    "ERROR : (tRP_CHECK) : Precharge to active delay time violation."
    severity error;
  end if;
end if;
end process;

-----------------------------------------------------------------------------------------------------

tRRD_CHECK : process (BankActivateFlag)
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  if (BankActivateFlag'EVENT and BankActivateFlag = TRUE) then
    assert ((now - b0_last_activate) >= tRRD) report
    "ERROR : (tRRD_CHECK) : Active to the other bank active delay time violation."
    severity error;
    assert ((now - b1_last_activate) >= tRRD) report
    "ERROR : (tRRD_CHECK) : Active to the other bank active delay time violation."
    severity error;
    assert ((now - b2_last_activate) >= tRRD) report
    "ERROR : (tRRD_CHECK) : Active to the other bank active delay time violation."
    severity error;
    assert ((now - b3_last_activate) >= tRRD) report
    "ERROR : (tRRD_CHECK) : Active to the other bank active delay time violation."
    severity error;
  end if;
end if;
end process;

-----------------------------------------------------------------------------------------------------

tCCD_CHECK : process (casp6_rd, casp6_wt)
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  if ((casp6_rd'EVENT and casp6_rd = '1') or (casp6_wt'EVENT and casp6_wt = '1')) then
    assert ((now - b0_last_column_access) >= tCCD) report
    "ERROR : (tCCD_CHECK) : Column access to column access delay time violation."
    severity error;
    assert ((now - b1_last_column_access) >= tCCD) report
    "ERROR : (tCCD_CHECK) : Column access to column access delay time violation."
    severity error;
    assert ((now - b2_last_column_access) >= tCCD) report
    "ERROR : (tCCD_CHECK) : Column access to column access delay time violation."
    severity error;
    assert ((now - b3_last_column_access) >= tCCD) report
    "ERROR : (tCCD_CHECK) : Column access to column access delay time violation."
    severity error;
  end if;
end if;
end process;

-----------------------------------------------------------------------------------------------------

tWR_CHECK : process (PrechargeFlag, PrechargeAllFlag)
variable BkAdd : std_logic_vector((NUM_OF_BANK_ADD - 1) downto 0) := (others => 'X');
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  BkAdd := (BA);
  if (BkAdd = "00" and (PrechargeFlag'EVENT and PrechargeFlag = TRUE)) then
    assert ((now - b0_last_data_in) >= tWR(Part_Number)) report
    "ERROR : (tWR_CHECK) : Last data in to precharge command delay violation."
    severity error;
  elsif (BkAdd = "01" and (PrechargeFlag'EVENT and PrechargeFlag = TRUE)) then
    assert ((now - b1_last_data_in) >= tWR(Part_Number)) report
    "ERROR : (tWR_CHECK) : Last data in to precharge command delay violation."
    severity error;
  elsif (BkAdd = "10" and (PrechargeFlag'EVENT and PrechargeFlag = TRUE)) then
    assert ((now - b2_last_data_in) >= tWR(Part_Number)) report
    "ERROR : (tWR_CHECK) : Last data in to precharge command delay violation."
    severity error;
  elsif (BkAdd = "11" and (PrechargeFlag'EVENT and PrechargeFlag = TRUE)) then
    assert ((now - b3_last_data_in) >= tWR(Part_Number)) report
    "ERROR : (tWR_CHECK) : Last data in to precharge command delay violation."
    severity error;
  elsif (PrechargeAllFlag'EVENT and PrechargeAllFlag = TRUE) then
    assert ((now - b0_last_data_in) >= tWR(Part_Number)) report
    "ERROR : (tWR_CHECK) : Last data in to precharge command delay violation."
    severity error;
    assert ((now - b1_last_data_in) >= tWR(Part_Number)) report
    "ERROR : (tWR_CHECK) : Last data in to precharge command delay violation."
    severity error;
    assert ((now - b2_last_data_in) >= tWR(Part_Number)) report
    "ERROR : (tWR_CHECK) : Last data in to precharge command delay violation."
    severity error;
    assert ((now - b3_last_data_in) >= tWR(Part_Number)) report
    "ERROR : (tWR_CHECK) : Last data in to precharge command delay violation."
    severity error;
  end if;
end if;
end process;

-----------------------------------------------------------------------------------------------------

tWTR_CHECK : process (casp6_rd)
begin
if (TimingCheckFlag = TRUE and ModeRegisterSetFlag = TRUE) then
  if (casp6_rd'event and casp6_rd = '1') then
    assert ((now - b0_last_data_in - 1 ns) >= tWTR) report
    "ERROR : (tWTR_CHECK) : Last data in to read command delay violation."
    severity error;
    assert ((now - b1_last_data_in - 1 ns) >= tWTR) report
    "ERROR : (tWTR_CHECK) : Last data in to read command delay violation."
    severity error;
    assert ((now - b2_last_data_in - 1 ns) >= tWTR) report
    "ERROR : (tWTR_CHECK) : Last data in to read command delay violation."
    severity error;
    assert ((now - b3_last_data_in - 1 ns) >= tWTR) report
    "ERROR : (tWTR_CHECK) : Last data in to read command delay violation."
    severity error;
  end if;
end if;
end process;

-----------------------------------------------------------------------------------------------------

tMRD_CHECK : process (mrs_cmd_in)
begin
if (mrs_cmd_in'event and mrs_cmd_in = '1') then
  assert ((now - last_mrs_set) >= tMRD) report
  "ERROR : (tMRD_CHECK) : MRS to MRS delay violation."
  severity error;
  last_mrs_set <= transport now;
end if;
end process;

-----------------------------------------------------------------------------------------------------

OCD_DEFAULT_CHECK : process (ExtModeRegister.OCD_PGM)
begin
if (TimingCheckFlag = TRUE) then
  if (ExtModeRegister.OCD_PGM = CAL_DEFAULT and DLL_reset = '1') then
    assert false report
    "WARNING : DLL RESET to OCD Default Delay Violation."
    severity warning;
  end if;
end if;
end process;

-----------------------------------------------------------------------------------------------------

OCD_ADJUST_CHECK : process (ExtModeRegister.OCD_PGM)
begin
if (ExtModeRegister.OCD_PGM'event and ExtModeRegister.OCD_PGM = CAL_EXIT) then
  if (TimingCheckFlag = TRUE) then
    assert (now - last_ocd_adjust_cmd >= (ExtModeRegister.AL + ModeRegister.CAS_LATENCY + 1 + 
                                          ModeRegister.TWR) * clk_cycle) report
    "WARNINg : OCD ADJUST to OCD CALIBRATION EXIT Delay Violation."
    severity warning;
  end if;
elsif (ExtModeRegister.OCD_PGM'event and ExtModeRegister.OCD_PGM = ADJUST) then
  last_ocd_adjust_cmd <= transport now;
end if;
end process;

-----------------------------------------------------------------------------------------------------

End Behavioral_Model_HY5PS121621F;

-----------------------------------------------------------------------------------------------------
