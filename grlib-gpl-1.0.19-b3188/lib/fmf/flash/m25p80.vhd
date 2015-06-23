--------------------------------------------------------------------------------
--  File Name: m25p80.vhd
--------------------------------------------------------------------------------
--  Copyright (C) 2005 Free Model Foundry; http://www.FreeModelFoundry.com
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License version 2 as
--  published by the Free Software Foundation.
--
--  MODIFICATION HISTORY:
--
--  version: |  author:         | mod date: | changes made:
--  V1.0        G.Gojanovic       05 Jun 27   initial version
--
--------------------------------------------------------------------------------
--  PART DESCRIPTION:
--
--  Library:    FLASH MEMORY
--  Technology: CMOS
--  Part:       M25P80
--
--  Description: 8Mbit Serial Flash memory w/ 40MHz SPI Bus Interface
--
--------------------------------------------------------------------------------
LIBRARY IEEE;   USE IEEE.std_logic_1164.ALL;
                USE STD.textio.ALL;
                USE IEEE.VITAL_timing.ALL;
                USE IEEE.VITAL_primitives.ALL;

LIBRARY FMF;    USE FMF.gen_utils.ALL;
                USE FMF.conversions.ALL;
-------------------------------------------------------------------------------
-- ENTITY DECLARATION
-------------------------------------------------------------------------------
ENTITY m25p80 IS
    GENERIC (
        -- tipd delays: interconnect path delays
        tipd_C            : VitalDelayType01 := VitalZeroDelay01;
        tipd_D            : VitalDelayType01 := VitalZeroDelay01;
        tipd_SNeg         : VitalDelayType01 := VitalZeroDelay01;
        tipd_HOLDNeg      : VitalDelayType01 := VitalZeroDelay01;
        tipd_WNeg         : VitalDelayType01 := VitalZeroDelay01;
        -- tpd delays
        tpd_C_Q           : VitalDelayType01  := UnitDelay01;--tV
        tpd_SNeg_Q        : VitalDelayType01Z := UnitDelay01Z;--tDIS
        tpd_HOLDNeg_Q     : VitalDelayType01Z := UnitDelay01Z;--tLZ,tHZ
        --tsetup values
        tsetup_D_C        : VitalDelayType := UnitDelay;  --tDVCH /
        tsetup_SNeg_C     : VitalDelayType := UnitDelay;  --tSLCH /
        tsetup_HOLDNeg_C  : VitalDelayType := UnitDelay;  --tHHCH /
        tsetup_C_HOLDNeg  : VitalDelayType := UnitDelay;  --tHLCH \
        tsetup_WNeg_SNeg  : VitalDelayType := UnitDelay;  --tWHSL \
        --thold values
        thold_D_C         : VitalDelayType := UnitDelay;  --tCHDX /
        thold_SNeg_C      : VitalDelayType := UnitDelay;  --tCHSL /
        thold_HOLDNeg_C   : VitalDelayType := UnitDelay;  --tCHHL /
        thold_C_HOLDNeg   : VitalDelayType := UnitDelay;  --tCHHH \
        thold_WNeg_SNeg   : VitalDelayType := UnitDelay;  --tWPH \
        --tpw values: pulse width
        tpw_C_posedge     : VitalDelayType := UnitDelay; --tCH
        tpw_C_negedge     : VitalDelayType := UnitDelay; --tCL
        tpw_SNeg_posedge  : VitalDelayType := UnitDelay; --tSHSL
        -- tperiod min (calculated as 1/max freq)
        tperiod_C_rd      : VitalDelayType := UnitDelay; -- fC=20MHz
        tperiod_C_fast_rd : VitalDelayType := UnitDelay; -- fC=25/40MHz
        -- tdevice values: values for internal delays
            -- Page Program Operation
        tdevice_PP        : VitalDelayType    := 5 ms;   --tPP
            --Sector Erase Operation
        tdevice_SE        : VitalDelayType    := 3 sec;  --tSE
            --Bulk Erase Operation
        tdevice_BE        : VitalDelayType    := 20 sec; --tBE
            --Write Status Register Operation
        tdevice_WR        : VitalDelayType    := 15 ms;  --tW
            --Deep Power Down
        tdevice_DP        : VitalDelayType    := 3 us;   --tDP
            --Release from Deep Power Down ES not read
        tdevice_RES1      : VitalDelayType    := 3 us;   --tRES1
            --Release from Deep Power Down ES read
        tdevice_RES2      : VitalDelayType    := 1.8 us; --tRES2
            --VCC (min) to S# Low
        tdevice_VSL       : VitalDelayType    := 10 us;  --tVSL
            --Time delay to Write instruction
        tdevice_PUW       : VitalDelayType    := 10 ms;  --tPUW
        -- generic control parameters
        InstancePath      : STRING    := DefaultInstancePath;
        TimingChecksOn    : BOOLEAN   := DefaultTimingChecks;
        MsgOn             : BOOLEAN   := DefaultMsgOn;
        XOn               : BOOLEAN   := DefaultXon;
        -- memory file to be loaded
        mem_file_name     : STRING    := "m25p80.mem";

        UserPreload       : BOOLEAN   := FALSE; --TRUE;
        DebugInfo         : BOOLEAN   := FALSE;
        LongTimming       : BOOLEAN   := TRUE;

        -- For FMF SDF technology file usage
        TimingModel       : STRING    := DefaultTimingModel
    );
    PORT (
        C             : IN    std_ulogic := 'U'; --serial clock input
        D             : IN    std_ulogic := 'U'; --serial data input
        SNeg          : IN    std_ulogic := 'U'; -- chip select input
        HOLDNeg       : IN    std_ulogic := 'U'; -- hold input
        WNeg          : IN    std_ulogic := 'U'; -- write protect input
        Q             : OUT   std_ulogic := 'U'  --serial data output
    );
    ATTRIBUTE VITAL_LEVEL0 of m25p80 : ENTITY IS TRUE;
END m25p80;

-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------
ARCHITECTURE vhdl_behavioral of m25p80 IS
    ATTRIBUTE VITAL_LEVEL0 OF vhdl_behavioral : ARCHITECTURE IS TRUE;

    CONSTANT PartID        : STRING  := "m25p80";
    CONSTANT MaxData       : NATURAL := 16#FF#;   --255;
    CONSTANT SecSize       : NATURAL := 16#FFFF#; --65535
    CONSTANT SecNum        : NATURAL := 15;
    CONSTANT HiAddrBit     : NATURAL := 23;
    CONSTANT AddrRANGE     : NATURAL := 16#FFFFF#;
    CONSTANT BYTE          : NATURAL := 8;
    --Electronic Signature
    CONSTANT ES            : NATURAL := 16#13#;
    -- interconnect path delay signals
    SIGNAL C_ipd          : std_ulogic := 'U';
    SIGNAL D_ipd          : std_ulogic := 'U';
    SIGNAL SNeg_ipd       : std_ulogic := 'U';
    SIGNAL HOLDNeg_ipd    : std_ulogic := 'U';
    SIGNAL WNeg_ipd       : std_ulogic := 'U';

    ---  internal delays
    SIGNAL PP_in          : std_ulogic := '0';
    SIGNAL PP_out         : std_ulogic := '0';
    SIGNAL PUW_in         : std_ulogic := '0';
    SIGNAL PUW_out        : std_ulogic := '0';
    SIGNAL SE_in          : std_ulogic := '0';
    SIGNAL SE_out         : std_ulogic := '0';
    SIGNAL BE_in          : std_ulogic := '0';
    SIGNAL BE_out         : std_ulogic := '0';
    SIGNAL WR_in          : std_ulogic := '0';
    SIGNAL WR_out         : std_ulogic := '0';
    SIGNAL DP_in          : std_ulogic := '0';
    SIGNAL DP_out         : std_ulogic := '0';
    SIGNAL RES1_in        : std_ulogic := '0';
    SIGNAL RES1_out       : std_ulogic := '0';
    SIGNAL RES2_in        : std_ulogic := '0';
    SIGNAL RES2_out       : std_ulogic := '0';
    SIGNAL VSL_in         : std_ulogic := '0';
    SIGNAL VSL_out        : std_ulogic := '0';

BEGIN
    ---------------------------------------------------------------------------
    -- Internal Delays
    ---------------------------------------------------------------------------
    -- Artificial VITAL primitives to incorporate internal delays
    PP     :VitalBuf(PP_out,   PP_in,      (tdevice_PP     ,UnitDelay));
    PUW    :VitalBuf(PUW_out,  PUW_in,     (tdevice_PUW    ,UnitDelay));
    SE     :VitalBuf(SE_out,   SE_in,      (tdevice_SE     ,UnitDelay));
    BE     :VitalBuf(BE_out,   BE_in,      (tdevice_BE     ,UnitDelay));
    WR     :VitalBuf(WR_out,   WR_in,      (tdevice_WR     ,UnitDelay));
    DP     :VitalBuf(DP_out,   DP_in,      (tdevice_DP     ,UnitDelay));
    RES1   :VitalBuf(RES1_out, RES1_in,    (tdevice_RES1   ,UnitDelay));
    RES2   :VitalBuf(RES2_out, RES2_in,    (tdevice_RES2   ,UnitDelay));
    VSL    :VitalBuf(VSL_out,  VSL_in,     (tdevice_VSL    ,UnitDelay));

    ---------------------------------------------------------------------------
    -- Wire Delays
    ---------------------------------------------------------------------------
    WireDelay : BLOCK
    BEGIN

        w_1 : VitalWireDelay (C_ipd, C, tipd_C);
        w_2 : VitalWireDelay (D_ipd, D, tipd_D);
        w_3 : VitalWireDelay (SNeg_ipd, SNeg, tipd_SNeg);
        w_4 : VitalWireDelay (HOLDNeg_ipd, HOLDNeg, tipd_HOLDNeg);
        w_5 : VitalWireDelay (WNeg_ipd, WNeg, tipd_WNeg);

    END BLOCK;

    ---------------------------------------------------------------------------
    -- Main Behavior Block
    ---------------------------------------------------------------------------
    Behavior: BLOCK

        -- State Machine : State_Type
        TYPE state_type IS (IDLE,
                            DP_DOWN,
                            WRITE_SR,
                            SECTOR_ER,
                            BULK_ER,
                            PAGE_PG
                            );

        -- Instruction Type
        TYPE instruction_type IS (NONE,
                                  WREN,
                                  WRDI,
                                  WRSR,
                                  RDSR,
                                  READ,
                                  FAST_READ,
                                  SE,
                                  BE,
                                  PP,
                                  DP,
                                  RES_READ_ES
                                  );

        TYPE WByteType IS ARRAY (0 TO 255) OF INTEGER RANGE -1 TO MaxData;
        --Flash Memory Array
        TYPE MemArray IS ARRAY (0 TO AddrRANGE) OF INTEGER RANGE -1 TO MaxData;

    ---------------------------------------------------------------------------
    --  memory declaration
    ---------------------------------------------------------------------------
        SHARED VARIABLE Mem     : MemArray := (OTHERS => MaxData);

        -- states
        SIGNAL current_state    : state_type;  --
        SIGNAL next_state       : state_type;  --

        SIGNAL WByte            : WByteType := (others => 0);
        SIGNAL Instruct         : instruction_type;
       --zero delay signal
        SIGNAL Q_zd             : std_logic :='Z';
        SIGNAL Q_temp           : std_logic :='Z';
        -- powerup parameters
        SIGNAL ChipSelectOk     : std_logic := '0';
        SIGNAL WriteOk          : std_logic := '0';

        SHARED VARIABLE Status_reg   : std_logic_vector(7 downto 0)
                                                := (others => '0');

        SIGNAL Status_reg_in         : std_logic_vector(7 downto 0)
                                              := (others => '0');

        ALIAS WIP    :std_logic IS Status_reg(0);
        ALIAS WEL    :std_logic IS Status_reg(1);
        ALIAS BP0    :std_logic IS Status_reg(2);
        ALIAS BP1    :std_logic IS Status_reg(3);
        ALIAS BP2    :std_logic IS Status_reg(4);
        ALIAS SRWD   :std_logic IS Status_reg(7);
        --Command Register
        SIGNAL write            : std_logic := '0';
        SIGNAL read_out         : std_logic := '0';

        SIGNAL fast_rd          : boolean   := true;
        SIGNAL rd               : boolean   := false;
        SIGNAL es_read          : boolean   := false;

        SIGNAL change_addr      : std_logic := '0';

        --FSM control signals

        SIGNAL PDONE            : std_logic := '1'; --Page Prog. Done
        SIGNAL PSTART           : std_logic := '0'; --Start Page Programming

        SIGNAL WDONE            : std_logic := '1'; --Write. Done
        SIGNAL WSTART           : std_logic := '0'; --Start Write

        SIGNAL ESTART           : std_logic := '0'; --Start Erase
        SIGNAL EDONE            : std_logic := '1'; --Erase Done

        SIGNAL RES_in           : std_logic := '0'; --RES1_in OR RES2_in

        SIGNAL SA               : NATURAL RANGE 0 TO SecNum := 0;
        SIGNAL Byte_number      : NATURAL RANGE 0 TO 255    := 0;

        SHARED VARIABLE Sec_Prot    : std_logic_vector(SecNum downto 0) :=
                                                   (OTHERS => '0');

        SIGNAL Address          : NATURAL RANGE 0 TO AddrRANGE := 0;

        -- timing check violation
        SIGNAL Viol             : X01 := '0';

        PROCEDURE ADDRHILO_SEC(
            VARIABLE   AddrLOW  : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   AddrHIGH : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   Addr     : NATURAL) IS
            VARIABLE   sector   : NATURAL RANGE 0 TO SecNum;
        BEGIN
            sector   := Addr/16#10000#;
            AddrLOW  := sector*16#10000#;
            AddrHIGH := sector*16#10000# + 16#0FFFF#;
        END AddrHILO_SEC;

        PROCEDURE ADDRHILO_PG(
            VARIABLE   AddrLOW  : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   AddrHIGH : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   Addr     : NATURAL) IS
            VARIABLE   page     : NATURAL RANGE 0 TO 65535;
        BEGIN
            page     := Addr/16#100#;
            AddrLOW  := Page*16#100#;
            AddrHIGH := Page*16#100# + 16#FF#;
        END AddrHILO_PG;

    BEGIN
   ----------------------------------------------------------------------------
    --Power Up parameters timing
    ---------------------------------------------------------------------------

    ChipSelectOk <= '1' AFTER tdevice_VSL;
    WriteOk      <= '1' AFTER tdevice_PUW;

    ---------------------------------------------------------------------------
    -- VITAL Timing Checks Procedures
    ---------------------------------------------------------------------------
    VITALTimingCheck: PROCESS(D_ipd, C_ipd, SNeg_ipd, HOLDNeg_ipd,
                              WNeg_ipd)
         -- Timing Check Variables
        VARIABLE Tviol_D_C       : X01 := '0';
        VARIABLE TD_D_C          : VitalTimingDataType;

        VARIABLE Tviol_HOLD_C    : X01 := '0';
        VARIABLE TD_HOLD_C       : VitalTimingDataType;

        VARIABLE Tviol_S_C       : X01 := '0';
        VARIABLE TD_S_C          : VitalTimingDataType;

        VARIABLE Tviol_WS_S      : X01 := '0';
        VARIABLE TD_WS_S         : VitalTimingDataType;

        VARIABLE Tviol_WH_S      : X01 := '0';
        VARIABLE TD_WH_S         : VitalTimingDataType;

        VARIABLE Pviol_S         : X01 := '0';
        VARIABLE PD_S            : VitalPeriodDataType := VitalPeriodDataInit;

        VARIABLE Pviol_C         : X01 := '0';
        VARIABLE PD_C            : VitalPeriodDataType := VitalPeriodDataInit;

        VARIABLE Pviol_C_rd      : X01 := '0';
        VARIABLE PD_C_rd         : VitalPeriodDataType := VitalPeriodDataInit;

        VARIABLE Pviol_C_fast_rd : X01 := '0';
        VARIABLE PD_C_fast_rd    : VitalPeriodDataType := VitalPeriodDataInit;

        VARIABLE Violation       : X01 := '0';

    BEGIN
    ---------------------------------------------------------------------------
    -- Timing Check Section
    ---------------------------------------------------------------------------
    IF (TimingChecksOn) THEN

        -- Setup/Hold Check between D and C
        VitalSetupHoldCheck (
            TestSignal      => D_ipd,
            TestSignalName  => "D",
            RefSignal       => C_ipd,
            RefSignalName   => "C",
            SetupHigh       => tsetup_D_C,
            SetupLow        => tsetup_D_C,
            HoldHigh        => thold_D_C,
            HoldLow         => thold_D_C,
            CheckEnabled    => true,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_D_C,
            Violation       => Tviol_D_C
        );

        -- Setup/Hold Check between HOLD# and C /
        VitalSetupHoldCheck (
            TestSignal      => HOLDNeg_ipd,
            TestSignalName  => "HOLD#",
            RefSignal       => C_ipd,
            RefSignalName   => "C",
            SetupHigh       => tsetup_C_HOLDNeg,
            SetupLow        => tsetup_HOLDNeg_C,
            HoldHigh        => thold_C_HOLDNeg,
            HoldLow         => thold_HOLDNeg_C,
            CheckEnabled    => true,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_HOLD_C,
            Violation       => Tviol_HOLD_C
        );

        -- Setup/Hold Check between CS# and C
        VitalSetupHoldCheck (
            TestSignal      => SNeg_ipd,
            TestSignalName  => "S#",
            RefSignal       => C_ipd,
            RefSignalName   => "C",
            SetupHigh       => tsetup_SNeg_C,
            SetupLow        => tsetup_SNeg_C,
            HoldHigh        => thold_SNeg_C,
            HoldLow         => thold_SNeg_C,
            CheckEnabled    => true,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_S_C,
            Violation       => Tviol_S_C
        );

        -- Setup Check between W# and CS# \
        VitalSetupHoldCheck (
            TestSignal      => WNeg_ipd,
            TestSignalName  => "W#",
            RefSignal       => SNeg_ipd,
            RefSignalName   => "S#",
            SetupHigh       => tsetup_WNeg_SNeg,
            CheckEnabled    => true,
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WS_S,
            Violation       => Tviol_WS_S
        );

        -- Hold Check between W# and CS# /
        VitalSetupHoldCheck (
            TestSignal      => WNeg_ipd,
            TestSignalName  => "W#",
            RefSignal       => SNeg_ipd,
            RefSignalName   => "S#",
            HoldHigh        => thold_WNeg_SNeg,
            CheckEnabled    => true,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WH_S,
            Violation       => Tviol_WH_S
        );

        -- Period Check S#
        VitalPeriodPulseCheck (
            TestSignal      =>  SNeg_ipd,
            TestSignalName  =>  "S#",
            PulseWidthHigh  =>  tpw_SNeg_posedge,
            PeriodData      =>  PD_S,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_S,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  true );

        -- Period Check C for everything but READ
        VitalPeriodPulseCheck (
            TestSignal      =>  C_ipd,
            TestSignalName  =>  "C",
            PulseWidthLow   =>  tpw_C_negedge,
            PulseWidthHigh  =>  tpw_C_posedge,
            PeriodData      =>  PD_C,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_C,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  true );

        -- Period Check C for READ
        VitalPeriodPulseCheck (
            TestSignal      =>  C_ipd,
            TestSignalName  =>  "C",
            Period          =>  tperiod_C_rd,
            PeriodData      =>  PD_C_rd,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_C_rd,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  rd );

        -- Period Check C for other than READ
        VitalPeriodPulseCheck (
            TestSignal      =>  C_ipd,
            TestSignalName  =>  "C",
            Period          =>  tperiod_C_fast_rd,
            PeriodData      =>  PD_C_fast_rd,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_C_fast_rd,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  fast_rd );

        Violation := Tviol_D_C           OR
                     Tviol_HOLD_C        OR
                     Tviol_S_C           OR
                     Tviol_WS_S          OR
                     Tviol_WH_S          OR
                     Pviol_C             OR
                     Pviol_C_rd          OR
                     Pviol_C_fast_rd     OR
                     Pviol_S;

        Viol <= Violation;

        ASSERT Violation = '0'
            REPORT InstancePath & partID & ": simulation may be" &
                    " inaccurate due to timing violations"
            SEVERITY WARNING;

    END IF;
END PROCESS VITALTimingCheck;

    ----------------------------------------------------------------------------
    -- sequential process for FSM state transition
    ----------------------------------------------------------------------------
    StateTransition : PROCESS(next_state, WriteOk)

    BEGIN
        IF WriteOk = '1' THEN
                current_state <= next_state;
        END IF;
END PROCESS StateTransition;

    ---------------------------------------------------------------------------
    --  Write cycle decode
    ---------------------------------------------------------------------------
    BusCycleDecode : PROCESS(C_ipd, SNeg_ipd, HOLDNeg_ipd, D_ipd, RES_in)

        TYPE bus_cycle_type IS (STAND_BY,
                                CODE_BYTE,
                                ADDRESS_BYTES,
                                DUMMY_BYTES,
                                DATA_BYTES
                                );

        VARIABLE bus_cycle_state : bus_cycle_type;

        VARIABLE data_cnt        : NATURAL := 0;
        VARIABLE addr_cnt        : NATURAL := 0;
        VARIABLE code_cnt        : NATURAL := 0;
        VARIABLE dummy_cnt       : NATURAL := 0;
        VARIABLE bit_cnt         : NATURAL := 0;
        VARIABLE Data_in         : std_logic_vector(2047 downto 0)
                                                    := (others => '0');
        VARIABLE code            : std_logic_vector(7 downto 0);
        VARIABLE code_in         : std_logic_vector(7 downto 0);
        VARIABLE Byte_slv        : std_logic_vector(7 downto 0);
        VARIABLE addr_bytes      : std_logic_vector(HiAddrBit downto 0);
        VARIABLE Address_in      : std_logic_vector(23 downto 0);
    BEGIN

        CASE bus_cycle_state IS
            WHEN STAND_BY =>
                IF falling_edge(SNeg_ipd) THEN
                    Instruct <= NONE;
                    write <= '1';
                    code_cnt := 0;
                    addr_cnt := 0;
                    data_cnt := 0;
                    dummy_cnt := 0;
                    bus_cycle_state := CODE_BYTE;
                END IF;

            WHEN CODE_BYTE =>
                IF rising_edge(C_ipd) AND HOLDNeg_ipd = '1' THEN
                    Code_in(code_cnt) := D_ipd;
                    code_cnt := code_cnt + 1;
                    IF code_cnt = BYTE THEN
                        --MSB first
                        FOR I IN 7 DOWNTO 0 LOOP
                            code(i) := code_in(7-i);
                        END LOOP;
                        CASE code IS
                            WHEN "00000110" =>
                                Instruct <= WREN;
                                bus_cycle_state := DATA_BYTES;
                            WHEN "00000100" =>
                                Instruct <= WRDI;
                                bus_cycle_state := DATA_BYTES;
                            WHEN "00000001" =>
                                Instruct <= WRSR;
                                bus_cycle_state := DATA_BYTES;
                            WHEN "00000101" =>
                                Instruct <= RDSR;
                                bus_cycle_state := DATA_BYTES;
                            WHEN "00000011" =>
                                Instruct <= READ;
                                bus_cycle_state := ADDRESS_BYTES;
                            WHEN "00001011" =>
                                Instruct <= FAST_READ;
                                bus_cycle_state := ADDRESS_BYTES;
                            WHEN "10101011" =>
                                Instruct <= RES_READ_ES;
                                bus_cycle_state := DUMMY_BYTES;
                            WHEN "11011000" =>
                                Instruct <= SE;
                                bus_cycle_state := ADDRESS_BYTES;
                            WHEN "11000111" =>
                                Instruct <= BE;
                                bus_cycle_state := DATA_BYTES;
                            WHEN "00000010" =>
                                Instruct <= PP;
                                bus_cycle_state := ADDRESS_BYTES;
                            WHEN "10111001" =>
                                Instruct <= DP;
                                bus_cycle_state := DATA_BYTES;
                            WHEN others =>
                                null;
                        END CASE;
                    END IF;
                END IF;

                WHEN ADDRESS_BYTES =>
                    IF rising_edge(C_ipd) AND HOLDNeg_ipd = '1' THEN
                        Address_in(addr_cnt) := D_ipd;
                        addr_cnt := addr_cnt + 1;
                        IF addr_cnt = 3*BYTE THEN
                            FOR I IN 23 DOWNTO 0 LOOP
                                addr_bytes(23-i) := Address_in(i);
                            END LOOP;
                            Address <= to_nat(addr_bytes);
                            change_addr <= '1','0' AFTER 1 ns;
                            IF Instruct = FAST_READ THEN
                                bus_cycle_state := DUMMY_BYTES;
                            ELSE
                                bus_cycle_state := DATA_BYTES;
                            END IF;
                        END IF;
                    END IF;

                WHEN DUMMY_BYTES =>
                    IF rising_edge(C_ipd) AND HOLDNeg_ipd = '1' THEN
                        dummy_cnt := dummy_cnt + 1;
                        IF dummy_cnt = BYTE THEN
                            IF Instruct = FAST_READ THEN
                                bus_cycle_state := DATA_BYTES;
                            END IF;
                        ELSIF dummy_cnt = 3*BYTE THEN
                            bus_cycle_state := DATA_BYTES;
                            es_read         <= true;
                        END IF;
                    END IF;

                    IF rising_edge(SNeg_ipd) THEN
                        IF (HOLDNeg_ipd = '1' AND dummy_cnt = 0 AND
                           Instruct = RES_READ_ES) THEN
                            write   <= '0';
                            es_read <= false;
                        END IF;
                        bus_cycle_state := STAND_BY;
                    END IF;

                WHEN DATA_BYTES =>
                    IF falling_edge(C_ipd) AND SNeg_ipd = '0' AND
                        HOLDNeg_ipd = '1' THEN
                        IF Instruct = READ OR Instruct = RES_READ_ES
                           OR Instruct = FAST_READ OR Instruct = RDSR THEN
                            read_out <= '1', '0' AFTER 1 ns;
                        END IF;
                    END IF;

                    IF rising_edge(C_ipd) AND HOLDNeg_ipd = '1' THEN
                        IF data_cnt > 2047 THEN
                        --In case of PP, if more than 256 bytes are
                        --sent to the device
                            IF bit_cnt = 0 THEN
                                FOR I IN 0 TO (255*BYTE - 1) LOOP
                                    Data_in(i) := Data_in(i+8);
                                END LOOP;
                            END IF;
                            Data_in(2040 + bit_cnt) := D_ipd;
                            bit_cnt := bit_cnt + 1;
                            IF bit_cnt = 8 THEN
                                bit_cnt := 0;
                            END IF;
                            data_cnt := data_cnt + 1;
                        ELSE
                            Data_in(data_cnt) := D_ipd;
                            data_cnt := data_cnt + 1;
                            bit_cnt := 0;
                        END IF;
                    END IF;

                    IF rising_edge(SNeg_ipd) THEN
                        bus_cycle_state := STAND_BY;
                        es_read         <= true;
                        IF  HOLDNeg_ipd = '1' AND WriteOk = '1' THEN
                            CASE Instruct IS
                                WHEN WREN | WRDI | DP | BE | SE =>
                                    IF data_cnt = 0 THEN
                                        write <= '0';
                                    END IF;
                                WHEN RES_READ_ES =>
                                    write <= '0';
                                WHEN WRSR =>
                                    IF data_cnt = 8 THEN
                                        write <= '0';
                                        Status_reg_in <= Data_in(7 downto 0);
                                        --MSB first
                                    END IF;
                                WHEN PP =>
                                    IF ((data_cnt mod 8) = 0 AND
                                        data_cnt > BYTE) THEN
                                        write <= '0';
                                        FOR I IN 0 TO 255 LOOP
                                            FOR J IN 7 DOWNTO 0 LOOP
                                                Byte_slv(j) :=
                                                Data_in((i*8) + (7-j));
                                            END LOOP;
                                            WByte(i) <= to_nat(Byte_slv);
                                        END LOOP;
                                        IF data_cnt > 256*BYTE THEN
                                            Byte_number <= 255;
                                        ELSE
                                            Byte_number <= data_cnt/8-1;
                                        END IF;
                                    END IF;
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END IF;

            END CASE;

END PROCESS BusCycleDecode;
    ---------------------------------------------------------------------------
    -- Timing control for the Page Program
    ---------------------------------------------------------------------------
    ProgTime : PROCESS(PSTART)
        VARIABLE pob : time;
    BEGIN
        IF LongTimming THEN
            pob  := tdevice_PP;
        ELSE
            pob  := tdevice_PP / 100;
        END IF;
        IF rising_edge(PSTART) AND PDONE = '1' THEN
            IF NOT Sec_Prot(SA) = '1' THEN
                PDONE <= '0', '1' AFTER pob;
            END IF;
        END IF;
END PROCESS ProgTime;
    ---------------------------------------------------------------------------
    -- Timing control for the Write Status Register
    ---------------------------------------------------------------------------
    WriteTime : PROCESS(WSTART)
        VARIABLE wob      : time;
    BEGIN
        IF LongTimming THEN
            wob  := tdevice_WR;
        ELSE
            wob  := tdevice_WR / 100;
        END IF;
        IF rising_edge(WSTART) AND WDONE = '1' THEN
            WDONE <= '0', '1' AFTER wob;
        END IF;
END PROCESS WriteTime;
    ---------------------------------------------------------------------------
    -- Timing control for the Bulk Erase
    ---------------------------------------------------------------------------
    ErsTime : PROCESS(ESTART)
        VARIABLE seo      : time;
        VARIABLE beo      : time;
        VARIABLE duration : time;
    BEGIN
        IF LongTimming THEN
            seo := tdevice_SE;
            beo := tdevice_BE;
        ELSE
            seo := tdevice_SE / 100;
            beo := tdevice_BE / 100;
        END IF;
        IF rising_edge(ESTART) AND EDONE = '1' THEN
            IF Instruct = BE THEN
                duration := beo;
            ELSE --Instruct = SE
                duration := seo;
            END IF;
            EDONE <= '0', '1' AFTER duration;
        END IF;
END PROCESS ErsTime;

    ---------------------------------------------------------------------------
    -- Main Behavior Process
    -- combinational process for next state generation
    ---------------------------------------------------------------------------
    StateGen :PROCESS(write, SNeg, WDONE, PDONE, EDONE)

        VARIABLE sect   : NATURAL RANGE 0 TO SecNum;

    BEGIN
        -----------------------------------------------------------------------
        -- Functionality Section
        -----------------------------------------------------------------------

        CASE current_state IS
            WHEN IDLE          =>
                IF falling_edge(write) THEN
                    IF Instruct = WRSR AND WEL = '1'
                       AND not(SRWD = '1' AND WNeg = '0') THEN
                       -- can not execute if HPM is entered
                       -- or if WEL bit is zero
                        next_state <= WRITE_SR;
                    ELSIF Instruct = PP AND WEL = '1' THEN
                        sect := Address / 16#10000#;
                        IF Sec_Prot(sect) = '0' THEN
                            next_state <=  PAGE_PG;
                        END IF;
                    ELSIF Instruct = SE AND WEL = '1' THEN
                        sect := Address / 16#10000#;
                        IF Sec_Prot(sect) = '0' THEN
                            next_state <=  SECTOR_ER;
                        END IF;
                    ELSIF Instruct = BE AND WEL = '1' AND
                          (BP0 = '0' AND BP1 = '0' AND BP2 = '0') THEN
                        next_state <= BULK_ER;
                    ELSIF Instruct = DP THEN
                        next_state <= DP_DOWN;
                    ELSE
                        next_state <= IDLE;
                    END IF;
                END IF;

            WHEN WRITE_SR      =>
                IF rising_edge(WDONE) THEN
                    next_state <= IDLE;
                END IF;

            WHEN PAGE_PG       =>
                IF rising_edge(PDONE) THEN
                    next_state <= IDLE;
                END IF;

            WHEN BULK_ER | SECTOR_ER  =>
                IF rising_edge(EDONE) THEN
                    next_state <= IDLE;
                END IF;

            WHEN DP_DOWN     =>
                IF falling_edge(write) AND Instruct = RES_READ_ES THEN
                    next_state <= IDLE;
                END IF;

        END CASE;

END PROCESS StateGen;

    ---------------------------------------------------------------------------
    --FSM Output generation and general funcionality
    ---------------------------------------------------------------------------
    Functional : PROCESS(write,read_out, WDONE, PDONE, EDONE, current_state,
                         SNeg_ipd, HOLDNeg_ipd, Instruct, Address, WByte,
                         WriteOk, RES1_out, RES2_out, change_addr,
                         ChipSelectOk, WNeg_ipd, RES1_in,  RES2_in)

        TYPE WDataType IS ARRAY (0 TO 255) OF INTEGER RANGE -1 TO MaxData;

        VARIABLE WData       : WDataType:= (OTHERS => 0);

        VARIABLE oe          : boolean := FALSE;

        VARIABLE AddrLo      : NATURAL;
        VARIABLE AddrHi      : NATURAL;
        VARIABLE Addr        : NATURAL;

        VARIABLE read_cnt    : NATURAL;
        VARIABLE read_addr   : NATURAL RANGE 0 TO AddrRANGE;
        VARIABLE data_out    : std_logic_vector(7 downto 0);
        VARIABLE ident_out   : std_logic_vector(23 downto 0);

        VARIABLE old_bit     : std_logic_vector(7 downto 0);
        VARIABLE new_bit     : std_logic_vector(7 downto 0);
        VARIABLE old_int     : INTEGER RANGE -1 to MaxData;
        VARIABLE new_int     : INTEGER RANGE -1 to MaxData;
        VARIABLE wr_cnt      : NATURAL RANGE 0 TO 255;

        VARIABLE sect        : NATURAL RANGE 0 TO SecNum;
        VARIABLE BP          : std_logic_vector(2 downto 0) := "000";

    BEGIN
        -----------------------------------------------------------------------
        -- Functionality Section
        -----------------------------------------------------------------------

        oe     := rising_edge(read_out) AND ChipSelectOk = '1';

        RES_in <= RES1_in OR RES2_in; --this way, both timing conditions on
                                      --Release from Deep Power Down are merged

        IF Instruct'EVENT THEN
            read_cnt := 0;
            fast_rd  <= true;
            rd       <= false;
        END IF;

        IF rising_edge(change_addr) THEN
            read_addr := Address;
        END IF;

        IF RES1_out'EVENT AND RES1_out = '1' THEN
            RES1_in <= '0';
        END IF;

        IF RES2_out'EVENT AND RES2_out = '1' THEN
            RES2_in <= '0';
        END IF;

        CASE current_state IS
            WHEN IDLE          =>
                IF falling_edge(write) AND WriteOK = '1' THEN
                    IF RES_in = '1' AND Instruct /= DP THEN
                        ASSERT false
                            REPORT InstancePath & partID & "Command results" &
                                  " can be corrupted, a delay of tRES" &
                                  " currently in progress."
                            SEVERITY WARNING;
                    END IF;
                    IF Instruct = WREN THEN
                        WEL := '1';
                    ELSIF Instruct = WRDI THEN
                        WEL := '0';
                    ELSIF Instruct = WRSR AND WEL = '1'
                          AND not(SRWD = '1' AND WNeg_ipd = '0') THEN
                       -- can not execute if HPM is entered
                       -- or if WEL bit is zero
                        WSTART <= '1', '0' AFTER 1 ns;
                        WIP := '1';
                    ELSIF Instruct = PP AND WEL = '1' THEN
                        sect := Address / 16#10000#;
                        IF Sec_Prot(sect) = '0' THEN
                            PSTART <= '1', '0' AFTER 1 ns;
                            WIP := '1';
                            SA <= sect;
                            Addr := Address;
                            wr_cnt := Byte_number;
                            FOR I IN wr_cnt DOWNTO 0 LOOP
                                IF Viol /= '0' AND Sec_Prot(SA) /= '0' THEN
                                    WData(i) := -1;
                                ELSE
                                    WData(i) := WByte(i);
                                END IF;
                            END LOOP;
                        END IF;
                    ELSIF Instruct = SE AND WEL = '1' THEN
                        sect := Address / 16#10000#;
                        IF Sec_Prot(sect) = '0' THEN
                            ESTART <= '1', '0' AFTER 1 ns;
                            WIP := '1';
                            Addr := Address;
                        END IF;
                    ELSIF Instruct = BE AND WEL = '1' AND
                          (BP0 = '0' AND BP1 = '0' AND BP2 = '0') THEN
                        ESTART <= '1', '0' AFTER 1 ns;
                        WIP := '1';
                    END IF;

                ELSIF oe AND RES_in = '0' THEN
                    IF Instruct = RDSR THEN
                        --Read Status Register
                        Q_zd <= Status_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = READ OR Instruct = FAST_READ THEN
                        --Read Memory array
                        IF Instruct = READ THEN
                            fast_rd <= false;
                            rd      <= true;
                        END IF;
                        data_out := to_slv(Mem(read_addr),8);
                        Q_zd <= data_out(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                            IF read_addr = AddrRANGE THEN
                                read_addr := 0;
                            ELSE
                                read_addr := read_addr + 1;
                            END IF;
                        END IF;
                    ELSE --IF Instruct = RES_READ_ES - look at assertion of oe
                        data_out := to_slv(ES, 8);
                        Q_zd     <= data_out(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;

                ELSIF oe AND RES_in = '1' THEN
                    Q_zd <= 'X';
                    read_cnt := read_cnt + 1;
                    IF read_cnt = 8 THEN
                        read_cnt := 0;
                    END IF;
                    ASSERT false
                        REPORT InstancePath & partID & "Command results" &
                              " can be corrupted, a delay of tRES" &
                              " currently in progress."
                        SEVERITY WARNING;

                END IF;

            WHEN WRITE_SR      =>

                IF oe AND Instruct = RDSR THEN
                    Q_zd <= Status_reg(7-read_cnt);
                    read_cnt := read_cnt + 1;
                    IF read_cnt = 8 THEN
                        read_cnt := 0;
                    END IF;
                END IF;

                IF WDONE = '1' THEN
                    WIP  := '0';
                    WEL  := '0';
                    SRWD := Status_reg_in(0);--MSB first
                    BP2  := Status_reg_in(3);
                    BP1  := Status_reg_in(4);
                    BP0  := Status_reg_in(5);
                    BP   := BP2 & BP1 & BP0;
                    CASE BP IS
                        WHEN "000" =>
                            Sec_Prot := (others => '0');
                        WHEN "001" =>
                            Sec_Prot(15)         := '1';
                        WHEN "010" =>
                            Sec_Prot(15 downto 14):= "11";
                        WHEN "011" =>
                            Sec_Prot(15 downto 12):= to_slv(16#F#,4);
                        WHEN "100" =>
                            Sec_Prot(15 downto 8):= to_slv(16#FF#,8);
                        WHEN others =>
                            Sec_Prot := (others => '1');
                    END CASE;
                END IF;

            WHEN PAGE_PG       =>

                IF oe AND Instruct = RDSR THEN
                    Q_zd <= Status_reg(7-read_cnt);
                    read_cnt := read_cnt + 1;
                    IF read_cnt = 8 THEN
                        read_cnt := 0;
                    END IF;
                END IF;

                ADDRHILO_PG(AddrLo, AddrHi, Addr);

                FOR I IN Addr TO Addr + wr_cnt LOOP
                    new_int := WData(i-Addr);
                    IF (i - AddrLo) >= 256 THEN
                        old_int := Mem(i - 256);
                        IF new_int > -1 THEN
                            new_bit := to_slv(new_int,8);
                            IF old_int > -1 THEN
                                old_bit := to_slv(old_int,8);
                                FOR j IN 0 TO 7 LOOP
                                    IF old_bit(j) = '0' THEN
                                        new_bit(j) := '0';
                                    END IF;
                                END LOOP;
                                new_int := to_nat(new_bit);
                            END IF;
                            WData(i-Addr) := new_int;
                        ELSE
                            WData(i-Addr) := -1;
                        END IF;
                    ELSE
                        old_int := Mem(i);
                        IF new_int > -1 THEN
                            new_bit := to_slv(new_int,8);
                            IF old_int > -1 THEN
                                old_bit := to_slv(old_int,8);
                                FOR j IN 0 TO 7 LOOP
                                    IF old_bit(j) = '0' THEN
                                        new_bit(j) := '0';
                                    END IF;
                                END LOOP;
                                new_int := to_nat(new_bit);
                            END IF;
                            WData(i-Addr) := new_int;
                        ELSE
                            WData(i-Addr) := -1;
                        END IF;
                    END IF;
                END LOOP;

                FOR I IN Addr TO Addr + wr_cnt LOOP
                    IF (i - AddrLo) >= 256 THEN
                        Mem (i - 256) :=  -1;
                    ELSE
                        Mem (i) := -1;
                    END IF;
                END LOOP;

                IF PDONE = '1' THEN
                    WIP := '0';
                    WEL := '0';
                    FOR i IN Addr TO Addr + wr_cnt LOOP
                        IF (i - AddrLo) >= 256 THEN
                            Mem(i - 256) := WData(i-Addr);
                        ELSE
                            Mem (i) := WData(i-Addr);
                        END IF;
                    END LOOP;
                END IF;

            WHEN SECTOR_ER     =>

                IF oe AND Instruct = RDSR THEN
                    Q_zd <= Status_reg(7-read_cnt);
                    read_cnt := read_cnt + 1;
                    IF read_cnt = 8 THEN
                        read_cnt := 0;
                    END IF;
                END IF;

                ADDRHILO_SEC(AddrLo, AddrHi, Addr);
                FOR i IN AddrLo TO AddrHi LOOP
                    Mem(i) := -1;
                END LOOP;
                IF EDONE = '1' THEN
                    WIP := '0';
                    WEL := '0';
                    FOR i IN AddrLo TO AddrHi LOOP
                        Mem(i) :=  MaxData;
                    END LOOP;
                END IF;

            WHEN BULK_ER       =>

                IF oe AND Instruct = RDSR THEN
                    Q_zd <= Status_reg(7-read_cnt);
                    read_cnt := read_cnt + 1;
                    IF read_cnt = 8 THEN
                        read_cnt := 0;
                    END IF;
                END IF;

                FOR i IN 0 TO AddrRANGE LOOP
                    Mem(i) := -1;
                END LOOP;
                IF EDONE = '1' THEN
                    WIP := '0';
                    WEL := '0';
                    FOR i IN 0 TO AddrRANGE LOOP
                        Mem(i) :=  MaxData;
                    END LOOP;
                END IF;

            WHEN DP_DOWN     =>
                IF falling_edge(write) THEN
                    IF Instruct = RES_READ_ES THEN
                        IF es_read THEN
                            RES1_in <= '1';
                        ELSE
                            RES2_in <= '1';
                        END IF;
                    END IF;
                ELSIF oe AND Instruct = RES_READ_ES THEN
                    --Read Electronic Signature
                    data_out := to_slv(ES,8);
                    Q_zd <= data_out(7 - read_cnt);
                    read_cnt := read_cnt + 1;
                    IF read_cnt = 8 THEN
                        read_cnt := 0;
                    END IF;
                END IF;

        END CASE;

        --Output Disable Control
        IF ((SNeg_ipd = '1') OR (HOLDNeg_ipd = '0')) THEN
            Q_temp <= Q_zd;
            Q_zd <= 'Z';
        END IF;

        IF ((SNeg_ipd = '0') AND rising_edge(HOLDNeg_ipd) AND C_ipd = '0') THEN
            Q_zd <= Q_temp;
        END IF;

END PROCESS Functional;

    ---------------------------------------------------------------------------
    ---- File Read Section - Preload Control
    ---------------------------------------------------------------------------
    MemPreload : PROCESS

        -- text file input variables
        FILE mem_file        : text  is  mem_file_name;
        VARIABLE ind         : NATURAL RANGE 0 TO AddrRANGE := 0;
        VARIABLE buf         : line;

    BEGIN
    ---------------------------------------------------------------------------
    --m25p80 memory preload file format  -----------------------------------
    ---------------------------------------------------------------------------
    --   /       - comment
    --   @aaaaa - <aaaaa> stands for address
    --   dd      - <dd> is byte to be written at Mem(aaaaa++)
    --             (aaaaa is incremented at every load)
    --   only first 1-6 columns are loaded. NO empty lines !!!!!!!!!!!!!!!!
    ---------------------------------------------------------------------------

         -- memory preload
        IF (mem_file_name /= "none" AND UserPreload) THEN
            ind := 0;
            Mem := (OTHERS => MaxData);
            WHILE (not ENDFILE (mem_file)) LOOP
                READLINE (mem_file, buf);
                IF buf(1) = '/' THEN
                    NEXT;
                ELSIF buf(1) = '@' THEN
                    ind := h(buf(2 to 6)); --address
                ELSE
                    IF ind <= AddrRANGE THEN
                        Mem(ind) := h(buf(1 to 2));
                    END IF;
                    IF ind < AddrRANGE THEN
                        ind := ind + 1;
                    ELSIF ind >= AddrRANGE THEN
                        ASSERT false
                            REPORT "Given preload address is out of" &
                                   "memory address range"
                            SEVERITY warning;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        WAIT;
    END PROCESS MemPreload;

    Q_OUT: PROCESS(Q_zd)

        VARIABLE Q_GlitchData : VitalGlitchDataType;
    BEGIN
        VitalPathDelay01Z (
            OutSignal       => Q,
            OutSignalName   => "Q",
            OutTemp         => Q_zd,
            GlitchData      => Q_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime => C_ipd'LAST_EVENT,
                      PathDelay       => VitalExtendtofillDelay(tpd_C_Q),
                      PathCondition   => true),
                1 => (InputChangeTime => SNeg_ipd'LAST_EVENT,
                      PathDelay       => tpd_SNeg_Q,
                      PathCondition   => SNeg_ipd = '1'),
                2 => (InputChangeTime => HOLDNeg_ipd'LAST_EVENT,
                      PathDelay       => tpd_HOLDNeg_Q,
                      PathCondition   => TRUE)
            )
        );
    END PROCESS Q_OUT;

    END BLOCK behavior;
END vhdl_behavioral;
