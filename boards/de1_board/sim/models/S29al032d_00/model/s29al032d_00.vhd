------------------------------------------------------------------------------
--  File name : s29al032d_00.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--  Copyright (C) 2005 Spansion, LLC.
--
--  MODIFICATION HISTORY :
--
--  version:   | author:     | mod date:    | changes made:
--   V1.0       D.Lukovic     05 May 16      Initial release
--   
-------------------------------------------------------------------------------
--  PART DESCRIPTION:
--
--  Library:        FLASH
--  Technology:     Flash memory
--  Part:           s29al032d_00
--
--  Description:    32Mbit (4M x 8-Bit)  Flash Memory
--
--
-------------------------------------------------------------------------------
--  Known Bugs:
--
-------------------------------------------------------------------------------
LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.VITAL_timing.ALL;
    USE IEEE.VITAL_primitives.ALL;
    USE STD.textio.ALL;

LIBRARY FMF;
    USE FMF.gen_utils.all;
    USE FMF.conversions.all;
-------------------------------------------------------------------------------
-- ENTITY DECLARATION
-------------------------------------------------------------------------------
ENTITY s29al032d_00 IS
    GENERIC (
        -- tipd delays: interconnect path delays
        tipd_A0             : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A1             : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A2             : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A3             : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A4             : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A5             : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A6             : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A7             : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A8             : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A9             : VitalDelayType01 := VitalZeroDelay01; --address
        tipd_A10            : VitalDelayType01 := VitalZeroDelay01; --lines
        tipd_A11            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A12            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A13            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A14            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A15            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A16            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A17            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A18            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A19            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A20            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_A21            : VitalDelayType01 := VitalZeroDelay01; --

        tipd_DQ0            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ1            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ2            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ3            : VitalDelayType01 := VitalZeroDelay01; --  data
        tipd_DQ4            : VitalDelayType01 := VitalZeroDelay01; -- lines
        tipd_DQ5            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ6            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ7            : VitalDelayType01 := VitalZeroDelay01; --

        tipd_CENeg          : VitalDelayType01 := VitalZeroDelay01;
        tipd_OENeg          : VitalDelayType01 := VitalZeroDelay01;
        tipd_WENeg          : VitalDelayType01 := VitalZeroDelay01;
        tipd_RESETNeg       : VitalDelayType01 := VitalZeroDelay01;
        tipd_ACC            : VitalDelayType01 := VitalZeroDelay01;

        -- tpd delays
        tpd_A0_DQ0          : VitalDelayType01  := UnitDelay01;--tACC
        tpd_CENeg_DQ0       : VitalDelayType01Z := UnitDelay01Z;
        --(tCE,tCE,tDF,-,tDF,-)
        tpd_OENeg_DQ0       : VitalDelayType01Z := UnitDelay01Z;
        --(tOE,tOE,tDF,-,tDF,-)
        tpd_RESETNeg_DQ0    : VitalDelayType01Z := UnitDelay01Z;
        --(-,-,0,-,0,-)
        tpd_CENeg_RY        : VitalDelayType01Z := UnitDelay01Z; --tBUSY
        tpd_WENeg_RY        : VitalDelayType01Z := UnitDelay01Z; --tBUSY

        --tsetup values
        tsetup_A0_WENeg     : VitalDelayType := UnitDelay;  --tAS edge \
        tsetup_DQ0_WENeg    : VitalDelayType := UnitDelay;  --tDS edge /

        --thold values
        thold_CENeg_RESETNeg: VitalDelayType := UnitDelay;   --tRH  edge /
        thold_A0_WENeg      : VitalDelayType := UnitDelay;   --tAH  edge \
        thold_DQ0_CENeg     : VitalDelayType := UnitDelay;   --tDH edge /
        thold_OENeg_WENeg_noedge_negedge
                            : VitalDelayType := UnitDelay;   --tOEH edge /
        thold_OENeg_WENeg_noedge_posedge
                            : VitalDelayType := UnitDelay;   --tOEH edge /

        --tpw values: pulse width
        tpw_RESETNeg_negedge: VitalDelayType := UnitDelay; --tRP
        tpw_WENeg_negedge   : VitalDelayType := UnitDelay; --tWP
        tpw_WENeg_posedge   : VitalDelayType := UnitDelay; --tWPH
        tpw_CENeg_negedge   : VitalDelayType := UnitDelay; --tCP
        tpw_CENeg_posedge   : VitalDelayType := UnitDelay; --tCEPH
        tpw_A0_negedge      : VitalDelayType := UnitDelay; --tWC tRC

        -- tdevice values: values for internal delays

        tdevice_POB         : VitalDelayType    := 9 us;
        --word write
        tdevice_SEO         : VitalDelayType    := 700 ms;
            --Timing Limit Exceeded
        tdevice_HANG        : VitalDelayType    := 400 ms; --?
            --erase suspend timeout - only max time specified
        tdevice_ESTART_T1   : VitalDelayType   := 20 us;--max 20 us
            --sector erase command sequence timeout
        tdevice_CTMOUTS     : VitalDelayType    := 50 us;
            --device ready after Hardware reset(during embeded algorithm)
        tdevice_READYR      : VitalDelayType    := 20 us; --tReady

        -- generic control parameters
        InstancePath        : STRING    := DefaultInstancePath;
        TimingChecksOn      : BOOLEAN   := DefaultTimingChecks;
        MsgOn               : BOOLEAN   := DefaultMsgOn;
        XOn                 : BOOLEAN   := DefaultXon;
        -- memory file to be loaded
        mem_file_name       : STRING    := "none";--"s29al032d_00.mem";
        prot_file_name      : STRING    := "none";--"s29al032d_00_prot.mem";
        secsi_file_name     : STRING    := "none";--"s29al032d_00_secsi.mem";

        UserPreload         : BOOLEAN   := FALSE;
        LongTimming         : BOOLEAN   := TRUE;

        -- For FMF SDF technology file usage
        TimingModel         : STRING    := DefaultTimingModel
    );
    PORT (
        A21             : IN    std_ulogic := 'U'; --
        A20             : IN    std_ulogic := 'U'; --
        A19             : IN    std_ulogic := 'U'; --
        A18             : IN    std_ulogic := 'U'; --
        A17             : IN    std_ulogic := 'U'; --
        A16             : IN    std_ulogic := 'U'; --
        A15             : IN    std_ulogic := 'U'; --
        A14             : IN    std_ulogic := 'U'; --
        A13             : IN    std_ulogic := 'U'; --address
        A12             : IN    std_ulogic := 'U'; --lines
        A11             : IN    std_ulogic := 'U'; --
        A10             : IN    std_ulogic := 'U'; --
        A9              : IN    std_ulogic := 'U'; --
        A8              : IN    std_ulogic := 'U'; --
        A7              : IN    std_ulogic := 'U'; --
        A6              : IN    std_ulogic := 'U'; --
        A5              : IN    std_ulogic := 'U'; --
        A4              : IN    std_ulogic := 'U'; --
        A3              : IN    std_ulogic := 'U'; --
        A2              : IN    std_ulogic := 'U'; --
        A1              : IN    std_ulogic := 'U'; --
        A0              : IN    std_ulogic := 'U'; --

        DQ7             : INOUT std_ulogic := 'U'; --
        DQ6             : INOUT std_ulogic := 'U'; --
        DQ5             : INOUT std_ulogic := 'U'; --
        DQ4             : INOUT std_ulogic := 'U'; --
        DQ3             : INOUT std_ulogic := 'U'; --
        DQ2             : INOUT std_ulogic := 'U'; --
        DQ1             : INOUT std_ulogic := 'U'; --
        DQ0             : INOUT std_ulogic := 'U'; --

        CENeg           : IN    std_ulogic := 'U';
        OENeg           : IN    std_ulogic := 'U';
        WENeg           : IN    std_ulogic := 'U';
        RESETNeg        : IN    std_ulogic := 'U';
        ACC             : IN    std_ulogic := 'U';
        RY              : OUT   std_ulogic := 'U'  --RY/BY#
    );
    ATTRIBUTE VITAL_LEVEL0 of s29al032d_00 : ENTITY IS TRUE;
END s29al032d_00;

-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------
ARCHITECTURE vhdl_behavioral of s29al032d_00 IS
    ATTRIBUTE VITAL_LEVEL0 of vhdl_behavioral : ARCHITECTURE IS TRUE;

    CONSTANT PartID        : STRING  := "s29al032d_00";
    CONSTANT MaxData       : NATURAL := 16#FF#; --255;
    CONSTANT SecSize       : NATURAL := 16#FFFF#; --65535
    CONSTANT SecSiSize     : NATURAL := 255;
    CONSTANT MemSize       : NATURAL := 16#3FFFFF#;
    CONSTANT SecNum        : NATURAL := 63;
    CONSTANT HiAddrBit     : NATURAL := 21;

    -- interconnect path delay signals
    SIGNAL A21_ipd         : std_ulogic := 'U';
    SIGNAL A20_ipd         : std_ulogic := 'U';
    SIGNAL A19_ipd         : std_ulogic := 'U';
    SIGNAL A18_ipd         : std_ulogic := 'U';
    SIGNAL A17_ipd         : std_ulogic := 'U';
    SIGNAL A16_ipd         : std_ulogic := 'U';
    SIGNAL A15_ipd         : std_ulogic := 'U';
    SIGNAL A14_ipd         : std_ulogic := 'U';
    SIGNAL A13_ipd         : std_ulogic := 'U';
    SIGNAL A12_ipd         : std_ulogic := 'U';
    SIGNAL A11_ipd         : std_ulogic := 'U';
    SIGNAL A10_ipd         : std_ulogic := 'U';
    SIGNAL A9_ipd          : std_ulogic := 'U';
    SIGNAL A8_ipd          : std_ulogic := 'U';
    SIGNAL A7_ipd          : std_ulogic := 'U';
    SIGNAL A6_ipd          : std_ulogic := 'U';
    SIGNAL A5_ipd          : std_ulogic := 'U';
    SIGNAL A4_ipd          : std_ulogic := 'U';
    SIGNAL A3_ipd          : std_ulogic := 'U';
    SIGNAL A2_ipd          : std_ulogic := 'U';
    SIGNAL A1_ipd          : std_ulogic := 'U';
    SIGNAL A0_ipd          : std_ulogic := 'U';

    SIGNAL DQ7_ipd         : std_ulogic := 'U';
    SIGNAL DQ6_ipd         : std_ulogic := 'U';
    SIGNAL DQ5_ipd         : std_ulogic := 'U';
    SIGNAL DQ4_ipd         : std_ulogic := 'U';
    SIGNAL DQ3_ipd         : std_ulogic := 'U';
    SIGNAL DQ2_ipd         : std_ulogic := 'U';
    SIGNAL DQ1_ipd         : std_ulogic := 'U';
    SIGNAL DQ0_ipd         : std_ulogic := 'U';

    SIGNAL CENeg_ipd       : std_ulogic := 'U';
    SIGNAL OENeg_ipd       : std_ulogic := 'U';
    SIGNAL WENeg_ipd       : std_ulogic := 'U';
    SIGNAL RESETNeg_ipd    : std_ulogic := 'U';
    SIGNAL ACC_ipd         : std_ulogic := 'U';

    ---  internal delays
    SIGNAL POB_in          : std_ulogic := '0';
    SIGNAL POB_out         : std_ulogic := '0';
    SIGNAL SEO_in          : std_ulogic := '0';
    SIGNAL SEO_out         : std_ulogic := '0';

    SIGNAL HANG_out        : std_ulogic := '0'; --Program/Erase Timing Limit
    SIGNAL HANG_in         : std_ulogic := '0';
    SIGNAL START_T1        : std_ulogic := '0'; --Start TimeOut; SUSPEND
    SIGNAL START_T1_in     : std_ulogic := '0';
    SIGNAL CTMOUT          : std_ulogic := '0'; --Sector Erase TimeOut
    SIGNAL CTMOUT_in       : std_ulogic := '0';
    SIGNAL READY_in        : std_ulogic := '0';
    SIGNAL READY           : std_ulogic := '0'; -- Device ready after reset
BEGIN

    ---------------------------------------------------------------------------
    -- Internal Delays
    ---------------------------------------------------------------------------
    -- Artificial VITAL primitives to incorporate internal delays
    POB     :VitalBuf(POB_out,  POB_in,      (tdevice_POB     ,UnitDelay));
    SEO     :VitalBuf(SEO_out,  SEO_in,      (tdevice_SEO     ,UnitDelay));
    HANG    :VitalBuf(HANG_out, HANG_in,     (tdevice_HANG    ,UnitDelay));
    ESTART_T1:VitalBuf(START_T1, START_T1_in, (tdevice_ESTART_T1 ,UnitDelay));
    CTMOUTS :VitalBuf(CTMOUT,   CTMOUT_in,   (tdevice_CTMOUTS ,UnitDelay));
    READYR  :VitalBuf(READY,    READY_in,    (tdevice_READYR  ,UnitDelay));
    ---------------------------------------------------------------------------
    -- Wire Delays
    ---------------------------------------------------------------------------
    WireDelay : BLOCK
    BEGIN
        w_1  : VitalWireDelay (A21_ipd, A21, tipd_A21);
        w_2  : VitalWireDelay (A20_ipd, A20, tipd_A20);
        w_3  : VitalWireDelay (A19_ipd, A19, tipd_A19);
        w_4  : VitalWireDelay (A18_ipd, A18, tipd_A18);
        w_5  : VitalWireDelay (A17_ipd, A17, tipd_A17);
        w_6  : VitalWireDelay (A16_ipd, A16, tipd_A16);
        w_7  : VitalWireDelay (A15_ipd, A15, tipd_A15);
        w_8  : VitalWireDelay (A14_ipd, A14, tipd_A14);
        w_9  : VitalWireDelay (A13_ipd, A13, tipd_A13);
        w_10 : VitalWireDelay (A12_ipd, A12, tipd_A12);
        w_11 : VitalWireDelay (A11_ipd, A11, tipd_A11);
        w_12 : VitalWireDelay (A10_ipd, A10, tipd_A10);
        w_13 : VitalWireDelay (A9_ipd, A9, tipd_A9);
        w_14 : VitalWireDelay (A8_ipd, A8, tipd_A8);
        w_15 : VitalWireDelay (A7_ipd, A7, tipd_A7);
        w_16 : VitalWireDelay (A6_ipd, A6, tipd_A6);
        w_17 : VitalWireDelay (A5_ipd, A5, tipd_A5);
        w_18 : VitalWireDelay (A4_ipd, A4, tipd_A4);
        w_19 : VitalWireDelay (A3_ipd, A3, tipd_A3);
        w_20 : VitalWireDelay (A2_ipd, A2, tipd_A2);
        w_21 : VitalWireDelay (A1_ipd, A1, tipd_A1);
        w_22 : VitalWireDelay (A0_ipd, A0, tipd_A0);

        w_23 : VitalWireDelay (DQ7_ipd, DQ7, tipd_DQ7);
        w_24 : VitalWireDelay (DQ6_ipd, DQ6, tipd_DQ6);
        w_25 : VitalWireDelay (DQ5_ipd, DQ5, tipd_DQ5);
        w_26 : VitalWireDelay (DQ4_ipd, DQ4, tipd_DQ4);
        w_27 : VitalWireDelay (DQ3_ipd, DQ3, tipd_DQ3);
        w_28 : VitalWireDelay (DQ2_ipd, DQ2, tipd_DQ2);
        w_29 : VitalWireDelay (DQ1_ipd, DQ1, tipd_DQ1);
        w_30 : VitalWireDelay (DQ0_ipd, DQ0, tipd_DQ0);
        w_31 : VitalWireDelay (OENeg_ipd, OENeg, tipd_OENeg);
        w_32 : VitalWireDelay (WENeg_ipd, WENeg, tipd_WENeg);
        w_33 : VitalWireDelay (RESETNeg_ipd, RESETNeg, tipd_RESETNeg);
        w_34 : VitalWireDelay (CENeg_ipd, CENeg, tipd_CENeg);
        w_35 : VitalWireDelay (ACC_ipd,   ACC,  tipd_ACC);

    END BLOCK;

    ---------------------------------------------------------------------------
    -- Main Behavior Block
    ---------------------------------------------------------------------------
    Behavior: BLOCK

        PORT (
            A              : IN    std_logic_vector(HiAddrBit downto 0) :=
                                               (OTHERS => 'U');
            DIn            : IN    std_logic_vector(7 downto 0) :=
                                               (OTHERS => 'U');
            DOut           : OUT   std_ulogic_vector(7 downto 0) :=
                                               (OTHERS => 'Z');
            CENeg          : IN    std_ulogic := 'U';
            OENeg          : IN    std_ulogic := 'U';
            WENeg          : IN    std_ulogic := 'U';
            RESETNeg       : IN    std_ulogic := 'U';
            ACC            : IN    std_ulogic := 'U';

            RY             : OUT   std_ulogic := 'U'
        );
        PORT MAP (
            A(21)    => A21_ipd,
            A(20)    => A20_ipd,
            A(19)    => A19_ipd,
            A(18)    => A18_ipd,
            A(17)    => A17_ipd,
            A(16)    => A16_ipd,
            A(15)    => A15_ipd,
            A(14)    => A14_ipd,
            A(13)    => A13_ipd,
            A(12)    => A12_ipd,
            A(11)    => A11_ipd,
            A(10)    => A10_ipd,
            A(9)     => A9_ipd,
            A(8)     => A8_ipd,
            A(7)     => A7_ipd,
            A(6)     => A6_ipd,
            A(5)     => A5_ipd,
            A(4)     => A4_ipd,
            A(3)     => A3_ipd,
            A(2)     => A2_ipd,
            A(1)     => A1_ipd,
            A(0)     => A0_ipd,

            DIn(7)   => DQ7_ipd,
            DIn(6)   => DQ6_ipd,
            DIn(5)   => DQ5_ipd,
            DIn(4)   => DQ4_ipd,
            DIn(3)   => DQ3_ipd,
            DIn(2)   => DQ2_ipd,
            DIn(1)   => DQ1_ipd,
            DIn(0)   => DQ0_ipd,

            DOut(7)  => DQ7,
            DOut(6)  => DQ6,
            DOut(5)  => DQ5,
            DOut(4)  => DQ4,
            DOut(3)  => DQ3,
            DOut(2)  => DQ2,
            DOut(1)  => DQ1,
            DOut(0)  => DQ0,

            CENeg    => CENeg_ipd,
            OENeg    => OENeg_ipd,
            WENeg    => WENeg_ipd,
            ACC      => ACC_ipd,
            RESETNeg => RESETNeg_ipd,
            RY       => RY
        );

        -- State Machine : State_Type
        TYPE state_type IS (
                            RESET,
                            Z001,
                            CFI,
                            PREL_SETBWB,
                            PREL_ULBYPASS,
                            PREL_ULBYPASS_RESET,
                            AS,
                            AS_CFI,
                            A0SEEN,
                            C8,
                            C8_Z001,
                            C8_PREL,
                            OTP,
                            OTP_Z001,
                            OTP_PREL,
                            OTP_AS,
                            OTP_AS_CFI,
                            OTP_A0SEEN,
                            ERS,
                            SERS,
                            ESPS,
                            SERS_EXEC,
                            ESP,
                            ESP_CFI,
                            ESP_Z001,
                            ESP_PREL,
                            ESP_AS,
                            ESP_AS_CFI,
                            PGMS
                            );

        --Flash Memory Array
        TYPE SecType  IS ARRAY (0 TO SecSize) OF
                         INTEGER RANGE -1 TO MaxData;

        TYPE MemArray IS ARRAY (0 TO SecNum) OF
                         SecType;

        TYPE SecSiType  IS ARRAY ( 0 TO SecSiSize) OF
                         INTEGER RANGE -1 TO MaxData;

        -- states
        SIGNAL current_state    : state_type;  --
        SIGNAL next_state       : state_type;  --

        -- powerup
        SIGNAL PoweredUp        : std_logic := '0';

        --zero delay signals
        SIGNAL DOut_zd          : std_logic_vector(7 downto 0):=(OTHERS=>'Z');
        SIGNAL DOut_Pass        : std_logic_vector(7 downto 0):=(OTHERS=>'Z');
        SIGNAL RY_zd            : std_logic := 'Z';

        --FSM control signals
        SIGNAL ULBYPASS         : std_logic := '0'; --Unlock Bypass Active
        SIGNAL ESP_ACT          : std_logic := '0'; --Erase Suspend
        SIGNAL OTP_ACT          : std_logic := '0';

        --Model should never hang!!!!!!!!!!!!!!!
        SIGNAL HANG             : std_logic := '0';

        SIGNAL PDONE            : std_logic := '1'; --Prog. Done
        SIGNAL PSTART           : std_logic := '0'; --Start Programming

        --Program location is in protected sector
        SIGNAL PERR             : std_logic := '0';

        SIGNAL EDONE            : std_logic := '1'; --Ers. Done
        SIGNAL ESTART           : std_logic := '0'; --Start Erase
        SIGNAL ESUSP            : std_logic := '0'; --Suspend Erase
        SIGNAL ERES             : std_logic := '0'; --Resume Erase
        --All sectors selected for erasure are protected
        SIGNAL EERR             : std_logic := '0';
        --Sectors selected for erasure
        SIGNAL ERS_QUEUE        : std_logic_vector(SecNum downto 0) :=
                                                   (OTHERS => '0');
        --Command Register
        SIGNAL write            : std_logic := '0';
        SIGNAL read             : std_logic := '0';

        -- Access time variables
        SHARED VARIABLE OPENLATCH    : BOOLEAN;
        SHARED VARIABLE FROMCE       : BOOLEAN;
        SHARED VARIABLE FROMOE       : BOOLEAN;

        SHARED VARIABLE AS_SecSi_FP  : std_logic := '0';
        SHARED VARIABLE AS_addr      : NATURAL := 0; 
        SHARED VARIABLE AS_ID        : BOOLEAN := FALSE;
        SHARED VARIABLE AS_ID2       : BOOLEAN := FALSE;
        
        --Sector Address
        SIGNAL SecAddr          : NATURAL RANGE 0 TO SecNum := 0;

        SIGNAL SA               : NATURAL RANGE 0 TO SecNum := 0;

        --Address within sector
        SIGNAL Address          : NATURAL RANGE 0 TO SecSize := 0;

        SIGNAL D_tmp            : NATURAL RANGE 0 TO MaxData;
        SIGNAL D_tmp1           : NATURAL RANGE 0 TO MaxData;

        --A19:A11 Don't Care
        SIGNAL Addr             : NATURAL RANGE 0 TO 16#FFFF# := 0;
        SIGNAL Mem_address      : NATURAL;
        --glitch protection
        SIGNAL gWE_n            : std_logic := '1';
        SIGNAL gCE_n            : std_logic := '1';
        SIGNAL gOE_n            : std_logic := '1';
        SIGNAL RST              : std_logic := '1';

        SIGNAL reseted          : std_logic := '0';

            -- Mem(SecAddr)(Address)....
        SHARED VARIABLE Mem         : MemArray := (OTHERS =>(OTHERS=> MaxData));

        SHARED VARIABLE Sec_Prot    : std_logic_vector(SecNum downto 0) :=
                                                   (OTHERS => '0');
        SHARED VARIABLE SecSi       : SecSiType := (OTHERS => 0);

        -- timing check violation
        SIGNAL Viol                : X01 := '0';

        SIGNAL FactoryProt         : std_logic := '0';

        SIGNAL temp_data : INTEGER;

    BEGIN

   ----------------------------------------------------------------------------
    --Power Up time 100 ns;
    ---------------------------------------------------------------------------
    PoweredUp <= '1' AFTER 100 ns;

    RST <= RESETNeg AFTER 500 ns;

    ---------------------------------------------------------------------------
    -- VITAL Timing Checks Procedures
    ---------------------------------------------------------------------------
    VITALTimingCheck: PROCESS(A, Din, CENeg, OENeg, WENeg, RESETNeg)
         -- Timing Check Variables
        VARIABLE Tviol_A0_CENeg        : X01 := '0';
        VARIABLE TD_A0_CENeg           : VitalTimingDataType;

        VARIABLE Tviol_A0_WENeg        : X01 := '0';
        VARIABLE TD_A0_WENeg           : VitalTimingDataType;

        VARIABLE Tviol_DQ0_CENeg       : X01 := '0';
        VARIABLE TD_DQ0_CENeg          : VitalTimingDataType;

        VARIABLE Tviol_DQ0_WENeg       : X01 := '0';
        VARIABLE TD_DQ0_WENeg          : VitalTimingDataType;

        VARIABLE Tviol_CENeg_RESETNeg  : X01 := '0';
        VARIABLE TD_CENeg_RESETNeg     : VitalTimingDataType;

        VARIABLE Tviol_OENeg_RESETNeg  : X01 := '0';
        VARIABLE TD_OENeg_RESETNeg     : VitalTimingDataType;

        VARIABLE Tviol_OENeg_WENeg  : X01 := '0';
        VARIABLE TD_OENeg_WENeg     : VitalTimingDataType;

        VARIABLE Tviol_OENeg_WENeg_R   : X01 := '0';
        VARIABLE TD_OENeg_WENeg_R      : VitalTimingDataType;

        VARIABLE Pviol_RESETNeg   : X01 := '0';
        VARIABLE PD_RESETNeg      : VitalPeriodDataType := VitalPeriodDataInit;

        VARIABLE Pviol_CENeg      : X01 := '0';
        VARIABLE PD_CENeg         : VitalPeriodDataType := VitalPeriodDataInit;

        VARIABLE Pviol_WENeg      : X01 := '0';
        VARIABLE PD_WENeg         : VitalPeriodDataType := VitalPeriodDataInit;

        VARIABLE Pviol_A0         : X01 := '0';
        VARIABLE PD_A0            : VitalPeriodDataType := VitalPeriodDataInit;

        VARIABLE Violation        : X01 := '0';
    BEGIN

    ---------------------------------------------------------------------------
    -- Timing Check Section
    ---------------------------------------------------------------------------
    IF (TimingChecksOn) THEN
        -- Setup/Hold Check between A and CENeg
        VitalSetupHoldCheck (
            TestSignal      => A,
            TestSignalName  => "A",
            RefSignal       => CENeg,
            RefSignalName   => "CE#",
            SetupHigh       => tsetup_A0_WENeg,
            SetupLow        => tsetup_A0_WENeg,
            HoldHigh        => thold_A0_WENeg,
            HoldLow         => thold_A0_WENeg,
            CheckEnabled    => WENeg = '0' AND OENeg = '1',
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_A0_CENeg,
            Violation       => Tviol_A0_CENeg
        );
        -- Setup/Hold Check between A and WENeg
        VitalSetupHoldCheck (
            TestSignal      => A,
            TestSignalName  => "A",
            RefSignal       => WENeg,
            RefSignalName   => "WE#",
            SetupHigh       => tsetup_A0_WENeg,
            SetupLow        => tsetup_A0_WENeg,
            HoldHigh        => thold_A0_WENeg,
            HoldLow         => thold_A0_WENeg,
            CheckEnabled    => CENeg = '0' AND OENeg = '1',
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_A0_WENeg,
            Violation       => Tviol_A0_WENeg
        );
        -- Setup/Hold Check between DQ and CENeg
        VitalSetupHoldCheck (
            TestSignal      => DQ0,
            TestSignalName  => "DQ",
            RefSignal       => CENeg,
            RefSignalName   => "CE#",
            SetupHigh       => tsetup_DQ0_WENeg,
            SetupLow        => tsetup_DQ0_WENeg,
            HoldHigh        => thold_DQ0_CENeg,
            HoldLow         => thold_DQ0_CENeg,
            CheckEnabled    => WENeg = '0' AND OENeg = '1',
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_DQ0_CENeg,
            Violation       => Tviol_DQ0_CENeg
        );
        -- Setup/Hold Check between DQ and WENeg
        VitalSetupHoldCheck (
            TestSignal      => DQ0,
            TestSignalName  => "DQ",
            RefSignal       => WENeg,
            RefSignalName   => "WE#",
            SetupHigh       => tsetup_DQ0_WENeg,
            SetupLow        => tsetup_DQ0_WENeg,
            HoldHigh        => thold_DQ0_CENeg,
            HoldLow         => thold_DQ0_CENeg,
            CheckEnabled    => CENeg = '0' AND OENeg = '1',
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_DQ0_WENeg,
            Violation       => Tviol_DQ0_WENeg
        );
        -- Hold Check between CENeg and RESETNeg
        VitalSetupHoldCheck (
            TestSignal      => CENeg,
            TestSignalName  => "CE#",
            RefSignal       => RESETNeg,
            RefSignalName   => "RESET#",
            HoldHigh        => thold_CENeg_RESETNeg,
            CheckEnabled    => TRUE,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_CENeg_RESETNeg,
            Violation       => Tviol_CENeg_RESETNeg
        );
        -- Hold Check between OENeg and RESETNeg
        VitalSetupHoldCheck (
            TestSignal      => OENeg,
            TestSignalName  => "OE#",
            RefSignal       => RESETNeg,
            RefSignalName   => "RESET#",
            HoldHigh        => thold_CENeg_RESETNeg,
            CheckEnabled    => TRUE,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_OENeg_RESETNeg,
            Violation       => Tviol_OENeg_RESETNeg
        );

        VitalSetupHoldCheck (
            TestSignal      => OENeg,
            TestSignalName  => "OE#",
            RefSignal       => WENeg,
            RefSignalName   => "WE#",
            HoldHigh        => thold_OENeg_WENeg_noedge_posedge,--toeh
            HoldLow         => thold_OENeg_WENeg_noedge_posedge,--toeh
            CheckEnabled    => PDONE = '0' OR EDONE = '0',--toggle
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_OENeg_WENeg,
            Violation       => Tviol_OENeg_WENeg
         );
        VitalSetupHoldCheck (
            TestSignal      => OENeg,
            TestSignalName  => "OE#",
            RefSignal       => WENeg,
            RefSignalName   => "WE#",
            HoldHigh        => thold_OENeg_WENeg_noedge_negedge,--toeh
            HoldLow         => thold_OENeg_WENeg_noedge_negedge,--toeh
            CheckEnabled    => PDONE = '1' AND EDONE = '1', --read
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_OENeg_WENeg_R,
            Violation       => Tviol_OENeg_WENeg_R
         );

    -- PulseWidth Check for RESETNeg
        VitalPeriodPulseCheck (
            TestSignal        => RESETNeg,
            TestSignalName    => "RESET#",
            PulseWidthLow     => tpw_RESETNeg_negedge,
            CheckEnabled      => TRUE,
            HeaderMsg         => InstancePath & PartID,
            PeriodData        => PD_RESETNeg,
            Violation         => Pviol_RESETNeg
        );
        -- PulseWidth Check for WENeg
        VitalPeriodPulseCheck (
            TestSignal        => WENeg,
            TestSignalName    => "WE#",
            PulseWidthHigh    => tpw_WENeg_posedge,
            PulseWidthLow     => tpw_WENeg_negedge,
            CheckEnabled      => TRUE,
            HeaderMsg         => InstancePath & PartID,
            PeriodData        => PD_WENeg,
            Violation         => Pviol_WENeg
        );
        -- PulseWidth Check for CENeg
        VitalPeriodPulseCheck (
            TestSignal        => CENeg,
            TestSignalName    => "CE#",
            PulseWidthHigh    => tpw_WENeg_posedge,
            PulseWidthLow     => tpw_WENeg_negedge,
            CheckEnabled      => TRUE,
            HeaderMsg         => InstancePath & PartID,
            PeriodData        => PD_CENeg,
            Violation         => Pviol_CENeg
        );
        -- PulseWidth Check for A
        VitalPeriodPulseCheck (
            TestSignal        => A(0),
            TestSignalName    => "A",
            PulseWidthHigh    => tpw_A0_negedge,
            PulseWidthLow     => tpw_A0_negedge,
            CheckEnabled      => TRUE,
            HeaderMsg         => InstancePath & PartID,
            PeriodData        => PD_A0,
            Violation         => Pviol_A0
        );

        Violation := Tviol_A0_CENeg         OR
                     Tviol_A0_WENeg         OR
                     Tviol_DQ0_WENeg        OR
                     Tviol_DQ0_CENeg        OR
                     Tviol_CENeg_RESETNeg  	OR
                     Tviol_OENeg_RESETNeg  	OR
                     Tviol_OENeg_WENeg_R  	OR
                     Tviol_OENeg_WENeg     	OR
                     Pviol_RESETNeg        	OR
                     Pviol_CENeg           	OR
                     Pviol_WENeg           	OR
                     Pviol_A0      	       ;

        Viol <= Violation;

        ASSERT Violation = '0'
            REPORT InstancePath & partID & ": simulation may be" &
                    " inaccurate due to timing violations"
            SEVERITY WARNING;
    END IF;
END PROCESS VITALTimingCheck;

    ----------------------------------------------------------------------------
    -- sequential process for reset control and FSM state transition
    ----------------------------------------------------------------------------
    StateTransition : PROCESS(next_state, RESETNeg, RST, READY, PDone, EDone,
                              PoweredUp)
        VARIABLE R  : std_logic := '0'; --prog or erase in progress
        VARIABLE E  : std_logic := '0'; --reset timming error
    BEGIN
        IF PoweredUp='1' THEN
        --Hardware reset timing control
            IF falling_edge(RESETNeg) THEN
                E := '0';
                IF (PDONE='0' OR EDONE='0') THEN
                    --if program or erase in progress
                    READY_in <= '1';
                    R :='1';
                ELSE
                    READY_in <= '0';
                    R:='0';         --prog or erase not in progress
                END IF;
            ELSIF rising_edge(RESETNeg) AND RST='1' THEN
                --RESET# pulse < tRP
                READY_in <= '0';
                R := '0';
                E := '1';
            END IF;

            IF  RESETNeg='1' AND ( R='0' OR (R='1' AND READY='1')) THEN
                current_state <= next_state;
                READY_in <= '0';
                E := '0';
                R := '0';
                reseted <= '1';

            ELSIF (R='0' AND RESETNeg='0' AND RST='0')OR
                  (R='1' AND RESETNeg='0' AND RST='0' AND READY='0')OR
                  (R='1' AND RESETNeg='1' AND RST='0' AND READY='0')OR
                  (R='1' AND RESETNeg='1' AND RST='1' AND READY='0') THEN
                --no state transition while RESET# low

                current_state <= RESET; --reset start
                reseted       <= '0';
            END IF;

        ELSE
            current_state <= RESET;      -- reset
            reseted       <= '0';
            E := '0';
            R := '0';
        END IF;

END PROCESS StateTransition;

    ---------------------------------------------------------------------------
    --Glitch Protection: Inertial Delay does not propagate pulses <5ns
    ---------------------------------------------------------------------------
    gWE_n <= WENeg AFTER 5 ns;
    gCE_n <= CENeg AFTER 5 ns;
    gOE_n <= OENeg AFTER 5 ns;

    ---------------------------------------------------------------------------
    --Process that reports warning when changes on signals WE#, CE#, OE# are
    --discarded
    ---------------------------------------------------------------------------
    PulseWatch : PROCESS (WENeg, CENeg, OENeg, gWE_n, gCE_n, gOE_n)
    BEGIN
        IF NOW /= 0 ns THEN
            IF (WENeg'EVENT AND (WENeg=gWE_n)) THEN
                ASSERT false
                       REPORT "Glitch detected on WE# signals"
                       SEVERITY warning;
            END IF;
            IF (CENeg'EVENT AND (CENeg=gCE_n)) THEN
                ASSERT false
                       REPORT "Glitch detected on CE# signals"
                       SEVERITY warning;
            END IF;
            IF (OENeg'EVENT AND (OENeg=gOE_n)) THEN
                ASSERT false
                       REPORT "Glitch detected on OE# signals"
                       SEVERITY warning;
            END IF;
        END IF;
    END PROCESS PulseWatch;

    --latch address on rising edge and data on falling edge of write
    write_dc: PROCESS (gWE_n, gCE_n, gOE_n, RESETNeg, reseted)
    BEGIN
        IF RESETNeg /= '0' AND reseted = '1' THEN
            IF (gWE_n = '0') AND (gCE_n = '0') AND (gOE_n = '1') THEN
                write <= '1';
            ELSE
                write <= '0';
            END IF;
        END IF;

        IF ((gWE_n = '1') AND (gCE_n = '0') AND (gOE_n = '0') )THEN
            read <= '1';
        ELSE
            read <= '0';
        END IF;

    END PROCESS write_dc;

    ---------------------------------------------------------------------------
    --Latch address on falling edge of WE# or CE# what ever comes later
    --Latches data on rising edge of WE# or CE# what ever comes first
    -- also Write cycle decode
    ---------------------------------------------------------------------------
    BusCycleDecode : PROCESS(A, Din, write, WENeg, CENeg, OENeg, reseted)

        VARIABLE A_tmp   : NATURAL RANGE 0 TO 16#FF#;
        VARIABLE SA_tmp  : NATURAL RANGE 0 TO SecNum;
        VARIABLE A_tmp1  : NATURAL RANGE 0 TO SecSize;
        VARIABLE Mem_tmp : NATURAL RANGE 0 TO MemSize;

        VARIABLE CE     : std_logic;
        VARIABLE i      : NATURAL;
    BEGIN
        IF reseted='1' THEN
            IF (falling_edge(WENeg) AND CENeg='0' AND OENeg = '1' ) OR
               (falling_edge(CENeg) AND WENeg /= OENeg ) OR
               (falling_edge(OENeg) AND WENeg='1' AND CENeg = '0' ) OR
               ( A'EVENT AND WENeg = '1' AND CENeg='0' AND OENeg = '0' )
            THEN
                A_tmp     := to_nat(A(7 downto 0));
                SA_tmp    := to_nat(A(HiAddrBit downto 16));
                A_tmp1    := to_nat(A(15 downto 0));
                Mem_tmp   := to_nat(A(HiAddrBit downto 0));
                AS_addr   := to_nat(A(21));

            ELSIF (rising_edge(WENeg) OR rising_edge(CENeg))
                AND write = '1' THEN
                D_tmp <= to_nat(Din);
            END IF;

            IF rising_edge(write) OR
               falling_edge(OENeg) OR
               falling_edge(CENeg) OR
               (A'EVENT AND WENeg = '1' AND CENeg = '0' AND OENeg = '0') THEN
                SecAddr <= SA_tmp;
                Address <= A_tmp1;
                Mem_address <= Mem_tmp;
                Addr <= A_tmp;
                CE := CENeg;
            END IF;
        END IF;

END PROCESS BusCycleDecode;

    ---------------------------------------------------------------------------
    -- Timing control for the Program Operations
    ---------------------------------------------------------------------------
    ProgTime :PROCESS(PSTART, OTP_ACT, ESP_ACT, reseted)
        VARIABLE duration : time;
        VARIABLE pob      : time;

    BEGIN
        IF LongTimming THEN
            pob  := tdevice_POB;
        ELSE
            pob  := tdevice_POB/1;
        END IF;
        IF rising_edge(reseted) THEN
            PDONE <= '1';  -- reset done, programing terminated
        ELSIF reseted = '1' THEN
            IF rising_edge(PSTART) AND PDONE='1' THEN
                IF (((Sec_Prot(SA) = '0' AND
                   (Ers_queue(SA) = '0' OR ESP_ACT = '0')) AND
                   (OTP_ACT = '0')) OR (OTP_ACT = '1' AND 
                   FactoryProt = '0')) THEN
                    duration := pob + 5 ns;
                    PDONE <= '0', '1' AFTER duration;
                ELSE
                    PERR <= '1', '0' AFTER 1005 ns;
                END IF;
            END IF;
        END IF;
END PROCESS ProgTime;

    ---------------------------------------------------------------------------
    -- Timing control for the Erase Operations
    ---------------------------------------------------------------------------
    ErsTime :PROCESS(ESTART, ESUSP, ERES, Ers_Queue, reseted)
        VARIABLE cnt      : NATURAL RANGE 0 TO SecNum +1 := 0;
        VARIABLE elapsed  : time;
        VARIABLE duration : time;
        VARIABLE start    : time;
        VARIABLE seo      : time;
    BEGIN
        IF LongTimming THEN
            seo  := tdevice_SEO;
        ELSE
            seo  := tdevice_SEO/100;
        END IF;
        IF rising_edge(reseted) THEN
            EDONE <= '1';  -- reset done, ERASE terminated
        ELSIF reseted = '1' THEN
            IF rising_edge(ESTART) AND EDONE = '1' THEN
                cnt := 0;
                FOR i IN Ers_Queue'RANGE LOOP
                    IF Ers_Queue(i) = '1' AND Sec_Prot(i) /= '1' THEN
                        cnt := cnt +1;
                    END IF;
                END LOOP;
                IF cnt > 0 THEN
                    elapsed := 0 ns;
                    duration := cnt* seo;
                    EDONE <= '0', '1' AFTER duration + 5 ns;
                    start := NOW;
                ELSE
                    EERR <= '1', '0' AFTER 100005 ns;
                END IF;
            ELSIF rising_edge(ESUSP) AND EDONE = '0' THEN
                elapsed  := NOW - start;
                duration := duration - elapsed;
                EDONE <= '0';
            ELSIF rising_edge(ERES) AND EDONE = '0' THEN
                start := NOW;
                EDONE <= '0', '1' AFTER duration;
            END IF;
        END IF;
END PROCESS;

    ---------------------------------------------------------------------------
    -- Main Behavior Process
    -- combinational process for next state generation
    ---------------------------------------------------------------------------
    StateGen :PROCESS(write, Addr, D_tmp, ULBYPASS, PDONE, EDONE, HANG, CTMOUT,
                       START_T1, reseted, READY, PERR, EERR)
        VARIABLE PATTERN_1         : boolean := FALSE;
        VARIABLE PATTERN_2         : boolean := FALSE;
        VARIABLE A_PAT_1           : boolean := FALSE;
        VARIABLE A_PAT_2           : boolean := FALSE;
        VARIABLE A_PAT_3           : boolean := FALSE;
        VARIABLE DataByte          : NATURAL RANGE 0 TO MaxData := 0;
    BEGIN
        -----------------------------------------------------------------------
        -- Functionality Section
        -----------------------------------------------------------------------
        IF falling_edge(write) THEN
            DataByte  := D_tmp;
            PATTERN_1 := DataByte = 16#AA# ;
            PATTERN_2 := DataByte = 16#55# ;
            A_PAT_1   := TRUE;
            A_PAT_2   := (Address = 16#AAA#);
            A_PAT_3   := (Address = 16#555#);         
        END IF;
        IF reseted /= '1' THEN
            next_state <= current_state;
        ELSE
        CASE current_state IS
            WHEN RESET          =>
                IF falling_edge(write) THEN
                    IF (PATTERN_1)THEN
                        next_state <= Z001;
                    ELSIF (DataByte=16#98#) THEN
                        next_state <= CFI;
                    ELSE
                        next_state <= RESET;
                    END IF;
                END IF;

            WHEN Z001           =>
                IF falling_edge(write) THEN
                    IF (PATTERN_2) THEN
                        next_state <= PREL_SETBWB;
                    ELSE
                        next_state <= RESET;
                    END IF;
                END IF;

            WHEN CFI            =>
                IF falling_edge(write) THEN
                    IF (D_tmp=16#F0#) THEN
                        next_state <= RESET;
                    ELSE
                        next_state <= CFI;
                    END IF;
                END IF;

            WHEN PREL_SETBWB    =>
                IF falling_edge(write) THEN
                    IF (A_PAT_1 AND (DataByte = 16#20#)) THEN
                        next_state <= PREL_ULBYPASS;
                    ELSIF (A_PAT_1 AND (DataByte = 16#90#)) THEN
                        next_state <= AS;
                    ELSIF (A_PAT_1 AND (DataByte = 16#88#)) THEN
                        next_state <= OTP;
                    ELSIF (A_PAT_1 AND (DataByte = 16#A0#)) THEN
                        next_state <= A0SEEN;
                    ELSIF (A_PAT_1 AND (DataByte = 16#80#)) THEN
                        next_state <= C8;
                    ELSE
                        next_state <= RESET;
                    END IF;
                END IF;

            WHEN PREL_ULBYPASS  =>
                IF falling_edge(write) THEN
                    IF (DataByte = 16#90#) THEN
                        next_state <= PREL_ULBYPASS_RESET;
                    ELSIF (A_PAT_1 AND (DataByte = 16#A0#)) THEN
                        next_state <= A0SEEN;
                    ELSE
                        next_state <= PREL_ULBYPASS;
                    END IF;
                END IF;

            WHEN PREL_ULBYPASS_RESET  =>
                IF falling_edge(write) THEN
                    IF (DataByte = 16#00#) THEN
                        IF ESP_ACT = '1' THEN
                            next_state <= ESP;
                        ELSE
                            next_state <= RESET;
                        END IF;
                    ELSE
                        next_state <= PREL_ULBYPASS;
                    END IF;
                END IF;

            WHEN AS             =>
                IF falling_edge(write) THEN
                    IF (DataByte = 16#F0#) THEN
                        next_state <= RESET;
                    ELSIF (D_tmp=16#98#) THEN
                        next_state <= AS_CFI;
                    ELSE
                        next_state <= AS;
                    END IF;
                END IF;

            WHEN AS_CFI            =>
                IF falling_edge(write) THEN
                    IF (D_tmp=16#F0#) THEN
                        next_state <= AS;
                    ELSE
                        next_state <= AS_CFI;
                    END IF;
                END IF;

            WHEN A0SEEN         =>
                IF falling_edge(write) THEN
                    next_state <= PGMS;
                ELSE
                    next_state <= A0SEEN;
                END IF;

            WHEN OTP            =>
                IF falling_edge(write) THEN
                    IF PATTERN_1 THEN
                        next_state <= OTP_Z001;
                    ELSE
                        next_state <= OTP;
                    END IF;
                END IF;

            WHEN OTP_Z001       =>
                IF falling_edge(write) THEN
                    IF PATTERN_2 THEN
                        next_state <= OTP_PREL;
                    ELSE
                        next_state <= OTP;
                    END IF;
                END IF;

            WHEN OTP_PREL        =>
                IF falling_edge(write) THEN
                    IF (DataByte = 16#90#) THEN
                        next_state <= OTP_AS;
                    ELSIF (DataByte = 16#A0#) THEN
                        next_state <= OTP_A0SEEN;
                    ELSE
                        next_state <= OTP;
                    END IF;
                END IF;

            WHEN OTP_AS        =>
                IF falling_edge(write) THEN
                    IF (DataByte = 16#00#) THEN
                        IF ESP_ACT = '1' THEN
                            next_state <= ESP;
                        ELSE
                            next_state <= RESET;
                        END IF;
                    ELSIF (DataByte = 16#F0#) THEN
                        next_state <= OTP;
                    ELSIF (DataByte = 16#98#) THEN
                        next_state <= OTP_AS_CFI;                  
                    ELSE
                        next_state <= OTP_AS;
                    END IF;
                END IF; 
                
            WHEN OTP_AS_CFI      =>
                 IF falling_edge(write) THEN
                     IF (DataByte = 16#F0#) THEN 
                         next_state <= OTP_AS;
                     ELSE
                         next_state <= OTP_AS_CFI;
                     END IF;
                 END IF;                   
                     
            WHEN OTP_A0SEEN      =>
                 IF falling_edge(write) THEN
                     IF ((Address >= 16#FF00#) AND (Address <= 16#FFFF#) 
                     AND (SecAddr = 16#3F#)) THEN 
                         next_state <= PGMS;
                     ELSE
                         next_state <= OTP;
                     END IF;
                 END IF;

            WHEN C8             =>
                IF falling_edge(write) THEN
                    IF PATTERN_1 THEN
                        next_state <= C8_Z001;
                    ELSE
                        next_state <= RESET;
                    END IF;
                END IF;

            WHEN C8_Z001        =>
                IF falling_edge(write) THEN
                    IF PATTERN_2 THEN
                        next_state <= C8_PREL;
                    ELSE
                        next_state <= RESET;
                    END IF;
                END IF;

            WHEN C8_PREL        =>
                IF falling_edge(write) THEN
                    IF A_PAT_1 AND DataByte = 16#10# THEN
                        next_state <= ERS;
                    ELSIF DataByte = 16#30# THEN
                        next_state <= SERS;
                    ELSE
                        next_state <= RESET;
                    END IF;
                END IF;

            WHEN ERS            =>
                IF rising_edge(EDONE) OR falling_edge(EERR) THEN
                    next_state <= RESET;
                END IF;

            WHEN SERS           =>
                IF CTMOUT = '1' THEN
                    next_state <= SERS_EXEC;
                ELSIF falling_edge(write) THEN
                    IF (DataByte = 16#B0#) THEN
                        next_state <= ESP;
                    ELSIF (DataByte = 16#30#) THEN
                        next_state <= SERS;
                    ELSE
                        next_state <= RESET;
                    END IF;
                END IF;

            WHEN ESPS           =>
                IF (START_T1 = '1') THEN
                    next_state <= ESP;
                END IF;

            WHEN SERS_EXEC      =>
                IF rising_edge(EDONE) OR falling_edge(EERR) THEN
                    next_state <= RESET;
                ELSIF EERR /= '1' THEN
                    IF falling_edge(write) THEN
                        IF DataByte = 16#B0# THEN
                            next_state <= ESPS;
                        END IF;
                    END IF;
                END IF;

            WHEN ESP            =>
                IF falling_edge(write) THEN
                    IF DataByte = 16#30# THEN
                        next_state <= SERS_EXEC;
                    ELSE
                        IF PATTERN_1 THEN
                            next_state <= ESP_Z001;
                        ELSIF D_tmp = 16#98#  THEN
                            next_state <= ESP_CFI;
                        END IF;
                    END IF;
                END IF;

            WHEN ESP_CFI        =>
                IF falling_edge(write) THEN
                    IF D_tmp = 16#F0# THEN
                        next_state <= ESP;
                    ELSE
                        next_state <= ESP_CFI;
                    END IF;
                END IF;

            WHEN ESP_Z001       =>
                IF falling_edge(write) THEN
                    IF PATTERN_2 THEN
                        next_state <= ESP_PREL;
                    ELSE
                        next_state <= ESP;
                    END IF;
                END IF;

            WHEN ESP_PREL       =>
                IF falling_edge(write) THEN
                    IF A_PAT_1 AND DataByte = 16#A0# THEN
                        next_state <= A0SEEN;
                    ELSIF A_PAT_1 AND DataByte = 16#20# THEN
                        next_state <= PREL_ULBYPASS;
                    ELSIF A_PAT_1 AND DataByte = 16#88# THEN
                        next_state <= OTP;
                    ELSIF A_PAT_1 AND DataByte = 16#90# THEN
                        next_state <= ESP_AS;
                    ELSE
                        next_state <= ESP;
                    END IF;
                END IF;
            
            WHEN ESP_AS         =>
                IF falling_edge(write) THEN
                    IF DataByte = 16#F0# THEN
                        next_state <= ESP;
                    ELSIF (D_tmp=16#98#) THEN
                        next_state <= ESP_AS_CFI;
                    END IF;
                END IF;

            WHEN ESP_AS_CFI        =>
                IF falling_edge(write) THEN
                    IF D_tmp = 16#F0# THEN
                        next_state <= ESP_AS;
                    ELSE
                        next_state <= ESP_AS_CFI;
                    END IF;
                END IF;
                
            WHEN PGMS           =>
                IF rising_edge(PDONE) OR falling_edge(PERR) THEN
                    IF ULBYPASS = '1' THEN
                        next_state <= PREL_ULBYPASS;
                    ELSIF OTP_ACT = '1' THEN
                        next_state <= OTP;
                    ELSIF ESP_ACT = '1' THEN
                        next_state <= ESP;
                    ELSE
                        next_state <= RESET;
                    END IF;
                END IF;

        END CASE;
        END IF;
END PROCESS StateGen;

    ---------------------------------------------------------------------------
    --FSM Output generation and general funcionality
    ---------------------------------------------------------------------------
    Functional : PROCESS(write, read, D_tmp, D_tmp1, Mem_address,
                         PDONE, EDONE, HANG, START_T1, CTMOUT, RST, reseted,
                         READY, gOE_n, current_state)

        --Common Flash Interface Query codes
        TYPE CFItype  IS ARRAY (16#10# TO 16#4F#) OF
                    INTEGER RANGE -1 TO 16#FF#;
        VARIABLE CFI_array   : CFItype   := (OTHERS => -1);

        --Program
        VARIABLE WData       : INTEGER RANGE -1 TO MaxData;
        VARIABLE WAddr       : INTEGER RANGE -1 TO SecSize;
        VARIABLE cnt         : NATURAL RANGE 0 TO 31 := 0;

        VARIABLE PATTERN_1   : boolean := FALSE;
        VARIABLE PATTERN_2   : boolean := FALSE;
        VARIABLE A_PAT_1     : boolean := FALSE;

        VARIABLE A_PAT_2     : boolean := FALSE;
        VARIABLE A_PAT_3     : boolean := FALSE;
        VARIABLE oe          : boolean := FALSE;
        --Status reg.
        VARIABLE Status      : std_logic_vector(7 downto 0):= (OTHERS=>'0');

        VARIABLE old_bit     : std_logic_vector(7 downto 0);
        VARIABLE new_bit     : std_logic_vector(7 downto 0);
        VARIABLE old_int     : INTEGER RANGE -1 to MaxData;
        VARIABLE new_int     : INTEGER RANGE -1 to MaxData;
        VARIABLE wr_cnt      : NATURAL RANGE 0 TO 31;

        --DATA Byte
        VARIABLE DataByte    : NATURAL RANGE 0 TO MaxData := 0;

        VARIABLE SecSiAddr   : NATURAL RANGE 0 TO SecSiSize := 0;

        VARIABLE temp        : std_logic_vector(7 downto 0);
        
    BEGIN
        -----------------------------------------------------------------------
        -- Functionality Section
        -----------------------------------------------------------------------
        IF falling_edge(write) THEN
            DataByte    := D_tmp;
            PATTERN_1 := DataByte = 16#AA# ;
            PATTERN_2 := DataByte = 16#55# ;
            A_PAT_1   := TRUE;
            A_PAT_2   := (Address = 16#AAA#);
            A_PAT_3   := (Address = 16#555#);         
            
        END IF;
        oe:= rising_edge(read) OR (read = '1' AND Mem_address'EVENT);
        IF reseted = '1' THEN
        CASE current_state IS
            WHEN RESET          =>
                ESP_ACT   <= '0';
                OTP_ACT   <= '0';
                ULBYPASS  <= '0';
                CTMOUT_in <= '0';
                IF falling_edge(write) THEN
                    IF A_PAT_2 AND PATTERN_1 THEN 
                        AS_SecSi_FP := '1';
                    ELSE
                        AS_SecSi_FP := '0';
                    END IF;
                END IF;
                IF oe THEN
                    IF Mem(SecAddr)(Address) = -1 THEN
                        DOut_zd <= (OTHERS=>'X');
                    ELSE
                        DOut_zd <= to_slv(Mem(SecAddr)(Address),8);
                    END IF;
                END IF;
                --ready signal active
                RY_zd <= '1';

            WHEN Z001           =>
                IF falling_edge(write)THEN
                    IF A_PAT_3 AND PATTERN_2 THEN 
                        null;
                    ELSE
                        AS_SecSi_FP := '0';
                    END IF;
                END IF;
            
                null;

            WHEN PREL_SETBWB    =>
                IF falling_edge(write) THEN
                    IF (A_PAT_1 AND (DataByte = 16#20#)) THEN
                        ULBYPASS <= '1';
                    ELSIF (A_PAT_1 AND (DataByte = 16#90#)) THEN
                        IF A_PAT_2 THEN 
                            null;
                        ELSE
                            AS_SecSi_FP := '0';
                        END IF;
                        IF  AS_addr = 0 THEN
                            AS_ID := TRUE; 
                            AS_ID2:= FALSE;
                        ELSE
                            AS_ID := FALSE;
                            AS_ID2:= TRUE;
                        END IF;
                        ULBYPASS <= '0';
                    ELSIF (A_PAT_1 AND (DataByte = 16#88#)) THEN
                        ULBYPASS <= '0';
                        OTP_ACT  <= '1';
                    END IF;
                END IF;

            WHEN PREL_ULBYPASS  =>
                ULBYPASS <= '1';
                IF falling_edge(write) THEN
                    IF (A_PAT_1 AND (DataByte = 16#90#)) THEN
                        ULBYPASS <= '0';
                    END IF;
                END IF;
                --ready signal active
                RY_zd <= '1';

            WHEN PREL_ULBYPASS_RESET =>
                IF falling_edge(write) AND (DataByte /= 16#00# ) THEN
                    ULBYPASS <= '1';
                END IF;

            WHEN A0SEEN         =>
                IF falling_edge(write) THEN
                    PSTART <= '1', '0' AFTER 1 ns;
                    WData := DataByte;
                    WAddr := Address;
                    SA <= SecAddr;
                    temp := to_slv(DataByte, 8);
                    Status(7) := NOT temp(7);
                END IF;

            WHEN OTP             =>
                OTP_ACT <= '1';
                IF falling_edge(write) THEN
                    IF A_PAT_2 AND PATTERN_1 THEN 
                        AS_SecSi_FP := '1';
                    ELSE
                        AS_SecSi_FP := '0';
                    END IF;
                END IF;

                IF oe THEN
                     IF ((Address >= 16#FF00#) AND (Address <= 16#FFFF#) 
                     AND (SecAddr = 16#3F#)) THEN 
                         SecSiAddr := Address MOD (SecSiSize +1);
                         IF SecSi(SecSiAddr)=-1 THEN
                             DOut_zd <= (OTHERS=>'X');
                         ELSE
                             DOut_zd <= to_slv(SecSi(SecSiAddr),8);
                         END IF;
                     ELSE
                        ASSERT false
                            REPORT "Invalid address in SecSi region. " 
                            SEVERITY warning;
                     END IF;  
                END IF;
                -- ready signal active
                Ry_zd <= '1';

            WHEN OTP_Z001       =>
                IF falling_edge(write) THEN
                    IF A_PAT_3 AND PATTERN_2 THEN 
                        null;
                    ELSE
                        AS_SecSi_FP := '0';
                    END IF;
                END IF;

            WHEN OTP_PREL       =>
                IF falling_edge(write) THEN
                    IF (A_PAT_1 AND (DataByte = 16#90#))THEN
                        IF A_PAT_2 THEN 
                            null;
                        ELSE
                            AS_SecSi_FP := '0';
                        END IF;
                        IF  AS_addr = 0 THEN
                            AS_ID := TRUE;
                            AS_ID2:= FALSE;
                        ELSE
                            AS_ID := FALSE;
                            AS_ID2:= TRUE;
                        END IF;
                        ULBYPASS <= '0';
                    END IF;
                END IF;

            WHEN OTP_A0SEEN     =>
                IF falling_edge(write) THEN
                     IF ((Address >= 16#FF00#) AND (Address <= 16#FFFF#) 
                     AND (SecAddr = 16#3F#)) THEN 
                         SecSiAddr := Address MOD (SecSiSize +1);
                         OTP_ACT <= '1';
                         PSTART <= '1', '0' AFTER 1 ns;
                         WData := DataByte;
                         WAddr := SecSiAddr;
                         SA <= SecAddr;
                         temp := to_slv(DataByte, 8);
                         Status(7) := NOT temp(7);
                     ELSE
                         ASSERT false
                            REPORT "Invalid program Address in SecSi"
                            SEVERITY warning;
                     END IF; 
                END IF;

            WHEN CFI | AS_CFI | ESP_CFI  | ESP_AS_CFI | OTP_AS_CFI  =>
                IF oe THEN
                    IF ((Mem_address >= 16#10# AND Mem_address <= 16#3C#) OR
                        (Mem_address >= 16#40# AND Mem_address <= 16#4F#))
                    THEN
                        IF (CFI_array(Address) /= -1) THEN
                            DOut_zd <= to_slv(CFI_array(Mem_address),8);
                        END IF;
                    ELSE
                        ASSERT FALSE
                        REPORT "Invalid CFI query address"
                        SEVERITY warning;
                        DOut_zd <= (OTHERS =>'Z');
                    END IF;
                END IF;

            WHEN C8             =>
                IF falling_edge(write) THEN
                    null;
                END IF;

            WHEN C8_Z001        =>
                IF falling_edge(write) THEN
                    null;
                END IF;

            WHEN C8_PREL        =>
                IF falling_edge(write) THEN
                    IF A_PAT_1 AND DataByte = 16#10# THEN
                        --Start Chip Erase
                        ESTART <= '1', '0' AFTER 1 ns;
                        ESUSP  <= '0';
                        ERES   <= '0';
                        Ers_Queue <= (OTHERS => '1');
                        Status := (OTHERS => '0');
                    ELSIF DataByte = 16#30# THEN
                        --put selected sector to sec. ers. queue
                        --start timeout
                        Ers_Queue <= (OTHERS => '0');
                        Ers_Queue(SecAddr) <= '1';
                        CTMOUT_in <= '1';
                    END IF;
                END IF;

            WHEN ERS            =>
                IF oe THEN
                    -----------------------------------------------------------
                    -- read status / embeded erase algorithm - Chip Erase
                    -----------------------------------------------------------
                    Status(7) := '0';
                    Status(6) := NOT Status(6); --toggle
                    Status(5) := '0';
                    Status(3) := '1';
                    Status(2) := NOT Status(2); --toggle

                    DOut_zd <= Status;
                END IF;
                IF EERR /= '1' THEN
                    FOR i IN 0 TO SecNum LOOP
                         IF Sec_Prot(i) /= '1' THEN
                              Mem(i):= (OTHERS => -1);
                        END IF;
                    END LOOP;
                    IF EDONE = '1' THEN
                        FOR i IN 0 TO SecNum LOOP
                            IF Sec_Prot(i) /= '1' THEN
                                Mem(i):= (OTHERS => MaxData);
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
                -- busy signal active
                RY_zd <= '0';

            WHEN SERS           =>
                IF CTMOUT = '1' THEN
                    CTMOUT_in <= '0';

                    START_T1_in <= '0';
                    ESTART <= '1', '0' AFTER 1 ns;
                    ESUSP  <= '0';
                    ERES   <= '0';

                ELSIF falling_edge(write) THEN
                    IF (DataByte = 16#B0#) THEN
                        --need to start erase process prior to suspend
                        ESTART <= '1', '0' AFTER 1 ns;
                        ERES   <= '0';
                        -- CTMOUT reset
                        CTMOUT_in <= '0';
                        ESUSP <= '1' AFTER 1 ns, '0' AFTER 2 ns;
                    ELSIF (DataByte = 16#30#) THEN
                        CTMOUT_in <= '0', '1' AFTER 1 ns;
                        Ers_Queue(SecAddr) <= '1';
                    ELSE
                        CTMOUT_in <= '0';
                    END IF;
                ELSIF oe THEN
                    -----------------------------------------------------------
                    --read status - sector erase timeout
                    -----------------------------------------------------------
                    Status(3) := '0';
                    Status(7) := '1';
                    DOut_zd <= Status;
                END IF;
                --ready signal active
                RY_zd <= '0';

            WHEN ESPS           =>
                IF (START_T1 = '1') THEN
                    ESP_ACT     <= '1';
                    START_T1_in <= '0';
                ELSIF oe THEN
                    -----------------------------------------------------------
                    --read status / erase suspend timeout - stil erasing
                    -----------------------------------------------------------
                    IF Ers_Queue(SecAddr)='1' THEN
                        Status(7) := '0';
                        Status(2) := NOT Status(2); --toggle
                    ELSE
                        Status(7) := '1';
                    END IF;
                    Status(6) := NOT Status(6); --toggle
                    Status(5) := '0';
                    Status(3) := '1';

                    DOut_zd <= Status;

                END IF;
                --busy signal active
                RY_zd <= '0';

            WHEN SERS_EXEC      =>
                IF oe THEN
                    -----------------------------------------------------------
                    --read status Erase Busy
                    -----------------------------------------------------------
                    IF Ers_Queue(SecAddr) = '1' THEN
                        Status(7) := '0';
                        Status(2) := NOT Status(2); --toggle
                    ELSE
                        Status(7) := '1';
                    END IF;
                    Status(6) := NOT Status(6); --toggle
                    Status(5) := '0';
                    Status(3) := '1';

                    DOut_zd <= Status;
                END IF;
                IF EERR /= '1' THEN
                    FOR i IN Ers_Queue'RANGE LOOP
                         IF  Ers_Queue(i) = '1' AND Sec_Prot(i) /= '1' THEN
                              Mem(i) := (OTHERS => -1);
                         END IF;
                    END LOOP;
                    IF EDONE = '1' THEN
                        FOR i IN Ers_Queue'RANGE LOOP
                            IF Ers_Queue(i) = '1' AND Sec_Prot(i) /= '1' THEN
                                Mem(i) := (OTHERS => MaxData);
                            END IF;
                        END LOOP;
                    ELSIF falling_edge(write) THEN
                        IF DataByte = 16#B0# THEN
                            START_T1_in <= '1';
                            ESUSP       <= '1', '0' AFTER 1 ns;
                        END IF;
                    END IF;
                END IF;
                --busy signal active
                RY_zd <= '0';

            WHEN ESP            =>
                IF falling_edge(write) THEN
                    IF A_PAT_2 AND PATTERN_1 THEN 
                        AS_SecSi_FP := '1';
                    ELSE
                        AS_SecSi_FP := '0';
                    END IF;                       
                    IF DataByte = 16#30# THEN
                        --resume erase
                        ERES <= '1', '0' AFTER 1 ns;
                    END IF;
                ELSIF oe THEN
                    IF Ers_Queue(SecAddr) = '1' AND Sec_Prot(SecAddr) /= '1'THEN
                        -------------------------------------------------------
                        --read status
                        -------------------------------------------------------
                        Status(7) := '1';
                        -- Status(6) No toggle
                        Status(5) := '0';
                        Status(2) := NOT Status(2); --toggle
                        DOut_zd <= Status;
                    ELSE
                        -------------------------------------------------------
                        --read
                        -------------------------------------------------------
                        IF Mem(SecAddr)(Address) = -1 THEN
                            DOut_zd <= (OTHERS=>'X');
                        ELSE
                            DOut_zd <= to_slv(Mem(SecAddr)(Address),8);
                        END IF;
                    END IF;
                END IF;
                --ready signal active
                RY_zd <= '1';

            WHEN ESP_Z001       =>
                IF falling_edge(write) THEN
                    IF A_PAT_3 AND PATTERN_2 THEN 
                       null;
                    ELSE
                       AS_SecSi_FP := '0';
                    END IF;
                END IF;                       

            WHEN ESP_PREL       =>
                IF falling_edge(write) THEN
                    IF (A_PAT_2 AND DataByte = 16#90#) THEN 
                        null;
                    ELSE
                        AS_SecSi_FP := '0';
                    END IF;
                    IF  AS_addr = 0 THEN
                        AS_ID := TRUE; 
                        AS_ID2:= FALSE;
                    ELSE
                        AS_ID := FALSE;
                        AS_ID2:= TRUE;
                    END IF;
                END IF;                       
                null;

            WHEN AS | ESP_AS | OTP_AS     =>
                IF falling_edge(write) THEN
                    IF (DataByte = 16#00#) THEN
                        OTP_ACT <= '0';
                        IF ESP_ACT = '1' THEN
                            ULBYPASS  <= '0';
                        END IF;
                    ELSIF (DataByte = 16#F0#) THEN
                        AS_ID := FALSE;
                        AS_ID2 := FALSE;
                        AS_SecSi_FP := '0';
                    END IF;
                ELSIF oe THEN
                    IF AS_addr = 0 THEN
                        null;
                    ELSE
                        AS_ID := FALSE;
                    END IF;
                    IF ((Addr = 0) AND AS_ID ) THEN
                        DOut_zd <= to_slv(1,8);
                    ELSIF ((Addr = 1) AND AS_ID ) THEN
                        DOut_zd <= to_slv(16#A3#,8);
                    ELSIF (Addr = 2) AND (((SecAddr < 32) AND AS_ID) 
                        OR ((SecAddr > 31) AND AS_ID2)) THEN
                            DOut_zd    <= (OTHERS => '0');
                            DOut_zd(0) <= Sec_Prot(SecAddr);
                    ELSIF (Addr = 6 AND AS_SecSi_FP = '1') THEN
                       IF FactoryProt = '1' THEN 
                           DOut_zd <= to_slv(16#99#,8);
                       ELSE
                           DOut_zd <= to_slv(16#19#,8);
                       END IF;
                    ELSE
                        Dout_zd <= "ZZZZZZZZ";
                    END IF;
                END IF;

            WHEN PGMS           =>
                IF oe THEN
                    -----------------------------------------------------------
                    --read status
                    -----------------------------------------------------------
                    Status(6) := NOT Status(6); --toggle
                    Status(5) := '0';
                    --Status(2) no toggle
                    Status(1) := '0';
                    DOut_zd <= Status;
                    IF (SecAddr = SA) OR OTP_ACT = '1' THEN
                        DOut_zd(7) <= Status(7);
                    ELSE
                        DOut_zd(7) <= NOT Status(7);
                    END IF;

                END IF;
                IF PERR /= '1' THEN
                    new_int := WData;
                    IF OTP_ACT /= '1' THEN
                      old_int := Mem(SA)(WAddr);
                    ELSE
                      old_int := SecSi(Waddr);
                    END IF;
                    IF new_int>-1 THEN
                        new_bit:=to_slv(new_int,8);
                        IF old_int>-1 THEN
                            old_bit:=to_slv(old_int,8);
                            FOR j IN 0 TO 7 LOOP
                                IF old_bit(j) = '0' THEN
                                    new_bit(j) := '0';
                                END IF;
                            END LOOP;
                            new_int:=to_nat(new_bit);
                        END IF;
                        WData:= new_int;
                    ELSE
                        WData:= -1;
                    END IF;
                    IF OTP_ACT /= '1' THEN
                        Mem(SA)(WAddr) := -1;
                    ELSE
                        SecSi(Waddr) := -1;
                    END IF;
                    IF HANG /= '1' AND PDONE='1' AND (NOT PERR'EVENT) THEN
                      IF OTP_ACT /= '1' THEN
                        Mem(SA)(WAddr) := WData;
                      ELSE
                        SecSi(Waddr) := Wdata;
                      END IF;
                        WData:= -1;
                    END IF;
                END IF;
                --busy signal active
                RY_zd <= '0';
        END CASE;
        END IF;

        --Output Disable Control
        IF (gOE_n = '1') OR (gCE_n = '1') OR (RESETNeg = '0' AND RST = '0') THEN
            DOut_zd <= (OTHERS=>'Z');
        END IF;

        IF NOW = 0 ns THEN
            --CFI query identification string
            CFI_array(16#10#) := 16#51#;
            CFI_array(16#11#) := 16#52#;
            CFI_array(16#12#) := 16#59#;
            CFI_array(16#13#) := 16#02#;
            CFI_array(16#14#) := 16#00#;
            CFI_array(16#15#) := 16#40#;
            CFI_array(16#16#) := 16#00#;
            CFI_array(16#17#) := 16#00#;
            CFI_array(16#18#) := 16#00#;
            CFI_array(16#19#) := 16#00#;
            CFI_array(16#1A#) := 16#00#;
            --system interface string
            CFI_array(16#1B#) := 16#27#;
            CFI_array(16#1C#) := 16#36#;
            CFI_array(16#1D#) := 16#00#;
            CFI_array(16#1E#) := 16#00#;
            CFI_array(16#1F#) := 16#04#;
            CFI_array(16#20#) := 16#00#;
            CFI_array(16#21#) := 16#0A#;
            CFI_array(16#22#) := 16#00#;
            CFI_array(16#23#) := 16#05#;
            CFI_array(16#24#) := 16#00#;
            CFI_array(16#25#) := 16#04#;
            CFI_array(16#26#) := 16#00#;
            --device geometry definition
            CFI_array(16#27#) := 16#16#;
            CFI_array(16#28#) := 16#00#;
            CFI_array(16#29#) := 16#00#;
            CFI_array(16#2A#) := 16#00#;
            CFI_array(16#2B#) := 16#00#;
            CFI_array(16#2C#) := 16#01#;
            CFI_array(16#2D#) := 16#3F#;
            CFI_array(16#2E#) := 16#00#;
            CFI_array(16#2F#) := 16#20#;
            CFI_array(16#30#) := 16#01#;
            CFI_array(16#31#) := 16#00#;
            CFI_array(16#32#) := 16#00#;
            CFI_array(16#33#) := 16#00#;
            CFI_array(16#34#) := 16#00#;
            CFI_array(16#35#) := 16#00#;
            CFI_array(16#36#) := 16#00#;
            CFI_array(16#37#) := 16#00#;
            CFI_array(16#38#) := 16#00#;
            CFI_array(16#39#) := 16#00#;
            CFI_array(16#3A#) := 16#00#;
            CFI_array(16#3B#) := 16#00#;
            CFI_array(16#3C#) := 16#00#;

            --primary vendor-specific extended query
            CFI_array(16#40#) := 16#50#;
            CFI_array(16#41#) := 16#52#;
            CFI_array(16#42#) := 16#49#;
            CFI_array(16#43#) := 16#31#;
            CFI_array(16#44#) := 16#31#;
            CFI_array(16#45#) := 16#01#;
            CFI_array(16#46#) := 16#02#;
            CFI_array(16#47#) := 16#01#;
            CFI_array(16#48#) := 16#01#;
            CFI_array(16#49#) := 16#04#;
            CFI_array(16#4A#) := 16#00#;
            CFI_array(16#4B#) := 16#00#;
            CFI_array(16#4C#) := 16#00#;
            CFI_array(16#4D#) := 16#B5#;
            CFI_array(16#4E#) := 16#C5#;
            CFI_array(16#4F#) := 16#00#;
       END IF;

    END PROCESS Functional;

    ---------------------------------------------------------------------------
    ---- File Read Section - Preload Control
    ---------------------------------------------------------------------------
    MemPreload : PROCESS

        -- text file input variables
        FILE mem_file          : text  is  mem_file_name;
        FILE prot_file         : text  is  prot_file_name;
        FILE secsi_file        : text  is  secsi_file_name;

        VARIABLE ind           : NATURAL RANGE 0 TO SecSize:= 0;
        VARIABLE buf           : line;

        CONSTANT SecS          : NATURAL := 16#10000#;
        CONSTANT MemSize       : NATURAL := 16#3FFFFF#;

        VARIABLE addr_ind      : NATURAL;
        VARIABLE sec_ind       : NATURAL;
        VARIABLE offset        : NATURAL;
        variable temp_vector   : std_logic_vector(3 downto 0);

    BEGIN
        IF ( mem_file_name /= "none" AND UserPreload ) THEN
            -------------------------------------------------------------------
            -----s29al032d_00 memory preload file format ----------------------
            -------------------------------------------------------------------
            --   /       - comment
            --   @aaaaaa  - <aaaaaa> stands for address within Memory
            --   dd       - <dd> is byte to be written at Mem(aaaaaa++)
            --             (aaaaaa is incremented at every load)
            --   only first 1-7 columns are loaded. NO empty lines !!!!!!!!!!!!
            -------------------------------------------------------------------
            addr_ind := 0;
            Mem      := (OTHERS => (OTHERS => MaxData));

            WHILE (not ENDFILE (mem_file)) LOOP
                READLINE (mem_file, buf);
                IF buf(1) = '/' THEN --comment
                    NEXT;
                ELSIF buf(1) = '@' THEN --address
                    addr_ind := h(buf(2 to 7));
                    sec_ind  := addr_ind / SecS;
                    offset   := addr_ind - ( sec_ind * SecS );
                ELSE
                    IF addr_ind <= MemSize THEN
                        Mem(sec_ind)(offset) := h(buf(1 to 2));
                        addr_ind := (addr_ind + 1);
                        sec_ind  := addr_ind / SecS;
                        offset   := addr_ind - ( sec_ind * SecS );
                    ELSE
                        ASSERT FALSE
                        REPORT " Memory address out of range"
                        SEVERITY warning;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        IF (prot_file_name /= "none" AND UserPreload ) THEN
            -------------------------------------------------------------------
            -----s29al032d_00 sector protect preload file format --------------
            -------------------------------------------------------------------
            --   /       - comment
            --   @ss  - <ss> stands for sector number
            --   d    - <d> is bit to be written at SecProt(ss++)
            --             (sec is incremented at every load)
            --   only first 1-3 columns are loaded. NO empty lines !!!!!!!!!!!!
            -------------------------------------------------------------------
            -------------------------------------------------------------------
            ind   := 0;
            Sec_Prot := (OTHERS => '0');

            WHILE (not ENDFILE (prot_file)) LOOP
            -- Always load as top, convert if bottom
                READLINE (prot_file, buf);
                IF buf(1)='/' THEN --comment
                    NEXT;
                ELSIF buf(1) = '@' THEN --address
                    ind := h(buf(2 to 3));
                ELSE
                    IF (buf(1) = '1') AND (ind <= SecNum) THEN
                        Sec_Prot(ind) := '1';
                    ELSE 
                        IF ind > SecNum THEN
                            IF (buf(1) = '1') THEN
                                FactoryProt <= '1';
                            END IF;
                         END IF;
                    END IF;
                    ind := ind + 1;
                END IF;
            END LOOP;
            FOR i IN 0 TO 15 LOOP
                IF Sec_Prot(4*i+3 DOWNTO 4*i) /= "0000" AND
                    Sec_Prot(4*i+3 DOWNTO 4*i) /= "1111"
                THEN
                -- every 4-group sectors protect bit must equal
                    REPORT "Bad preload " & to_int_str(i) &
                    "th sector protect group"
                    SEVERITY warning;
                END IF;
            END LOOP;
        END IF;

         -- Secure Silicon Sector Region preload
        IF (SecSi_file_name /= "none" AND UserPreload ) THEN
            -------------------------------------------------------------------
            -----s29al032d_00 SecSi preload file format------------------------
            -------------------------------------------------------------------
            --   /       - comment
            --   @aaaa     - <aaaa> stands for address within sector
            --   dd        - <dd> is byte to be written at SecSi(aaaa++)
            --             (aaaa is incremented at every load)
            --   only first 1-5 columns are loaded. NO empty lines !!!!!!!!!!!!
            --------------------------------------------------------------------
            SecSi := (OTHERS => MaxData);
            ind := 0;
            WHILE (not ENDFILE (SecSi_file)) LOOP
                READLINE (SecSi_file, buf);
                IF buf(1) = '/' THEN
                    NEXT;
                ELSIF buf(1) = '@' THEN
                    ind := h(buf(2 TO 3));
                ELSE
                    IF ind <= SecSiSize THEN
                        SecSi(ind) := h(buf(1 TO 2));
                        ind := ind + 1;
                    END IF;
                END IF;
            END LOOP;
         END IF;
    WAIT ;
    END PROCESS MemPreload;

    DOutPassThrough : PROCESS(DOut_zd)
        VARIABLE ValidData         : std_logic_vector(7 downto 0);
        VARIABLE CEDQ_t            : TIME;
        VARIABLE OEDQ_t            : TIME;
        VARIABLE ADDRDQ_t          : TIME;

    BEGIN
       IF DOut_zd(0) /= 'Z' THEN
           OPENLATCH := TRUE;
           CEDQ_t    := -CENeg'LAST_EVENT + tpd_CENeg_DQ0(trz0);
           OEDQ_t    := -OENeg'LAST_EVENT + tpd_OENeg_DQ0(trz0);
           ADDRDQ_t  := -A'LAST_EVENT     + tpd_A0_DQ0(tr01);
           FROMOE    := (OEDQ_t >= CEDQ_t) AND (OEDQ_t > 0 ns);
           FROMCE    := (CEDQ_t > OEDQ_t)  AND (CEDQ_t > 0 ns);
           ValidData := "XXXXXXXX";
           IF ((ADDRDQ_t > 0 ns) AND
           (((ADDRDQ_t > CEDQ_t) AND FROMCE) OR
            ((ADDRDQ_t > OEDQ_t) AND FROMOE))) THEN
               DOut_Pass <= ValidData,
                            DOut_zd AFTER ADDRDQ_t;
           ELSE
               DOut_Pass <= DOut_zd;
           END IF;
       ELSE
           CEDQ_t := -CENeg'LAST_EVENT + tpd_CENeg_DQ0(tr0z);
           OEDQ_t := -OENeg'LAST_EVENT + tpd_OENeg_DQ0(tr0z);
           FROMOE := (OEDQ_t <= CEDQ_t) AND (OEDQ_t > 0 ns);
           FROMCE := (CEDQ_t < OEDQ_t)  AND (CEDQ_t > 0 ns);
           DOut_Pass <= DOut_zd;
           OPENLATCH := FALSE;
       END IF;
   END PROCESS DOutPassThrough;

        -----------------------------------------------------------------------
        -- Path Delay Section
        -----------------------------------------------------------------------
    RY_OUT: PROCESS(RY_zd)

        VARIABLE RY_GlitchData : VitalGlitchDataType;
        VARIABLE RYData        : std_logic;
    BEGIN
        IF RY_zd = '1' THEN
            RYData := 'Z';
        ELSE
            RYData := RY_zd;
        END IF;
        VitalPathDelay01Z(
            OutSignal     => RY,
            OutSignalName => "RY/BY#",
            OutTemp       => RYData,
            Mode          => VitalTransport,
            GlitchData    => RY_GlitchData,
            Paths         => (
            0 => (InputChangeTime   => CENeg'LAST_EVENT,
                  PathDelay         => tpd_WENeg_RY,
                  PathCondition     => TRUE),
            1 => (InputChangeTime   => WENeg'LAST_EVENT,
                  PathDelay         => tpd_WENeg_RY,
                  PathCondition     => TRUE),
            2 => (InputChangeTime   => READY'LAST_EVENT,
                  PathDelay         => VitalZeroDelay01Z,
                  PathCondition     => EDONE = '1'),
            3 => (InputChangeTime   => EDONE'LAST_EVENT,
                  PathDelay         => VitalZeroDelay01Z,
                  PathCondition     => EDONE = '1'),
            4 => (InputChangeTime   => PDONE'LAST_EVENT,
                  PathDelay         => VitalZeroDelay01Z,
                  PathCondition     => PDONE = '1')
            )
        );
    END PROCESS RY_Out;

    ---------------------------------------------------------------------------
    -- Path Delay Section for DOut signal
    ---------------------------------------------------------------------------
    D_Out_PathDelay_Gen : FOR i IN 0 TO 7 GENERATE
    PROCESS(DOut_Pass(i))
        VARIABLE D0_GlitchData     : VitalGlitchDataType;

        BEGIN
            VitalPathDelay01Z(
                OutSignal           => DOut(i),
                OutSignalName       => "DOut",
                OutTemp             => DOut_Pass(i),
                GlitchData          => D0_GlitchData,
                IgnoreDefaultDelay  => TRUE,
                Mode                => VitalTransport,
                RejectFastPath      => FALSE,
                Paths               => (
                0 => (InputChangeTime => CENeg'LAST_EVENT,
                      PathDelay       => tpd_CENeg_DQ0,
                      PathCondition   => (NOT OPENLATCH AND NOT FROMOE)
                                          OR (OPENLATCH AND FROMCE)),
                1 => (InputChangeTime => OENeg'LAST_EVENT,
                      PathDelay       => tpd_OENeg_DQ0,
                      PathCondition   => (NOT OPENLATCH AND NOT FROMCE) OR
                                         (OPENLATCH AND FROMOE)),
                2 => (InputChangeTime => A'LAST_EVENT,
                      PathDelay       => VitalExtendToFillDelay(tpd_A0_DQ0),
                      PathCondition   => (NOT FROMOE) AND (NOT FROMCE)),
                3 => (InputChangeTime => RESETNeg'LAST_EVENT,
                      PathDelay       => tpd_RESETNeg_DQ0,
                      PathCondition   => RESETNeg='0')
                )
            );
        END PROCESS;
   END GENERATE D_Out_PathDelay_Gen;
   END BLOCK behavior;
END vhdl_behavioral;
