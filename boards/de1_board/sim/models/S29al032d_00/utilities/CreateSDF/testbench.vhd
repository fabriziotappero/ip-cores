------------------------------------------------------------------------------
--  File name : testbench_640.vhd
-------------------------------------------------------------------------------
--  Copyright (C) 2003 AMD.
--
--  MODIFICATION HISTORY :
--
--  version: | author:     | mod date: | changes made:
--    V0.1    M.Marinkovic  11 July 03  Initial
--    v0.2    M.Marinkovic  28 Aug  03  Changed protected sector selection
--
-------------------------------------------------------------------------------
--  PART DESCRIPTION:
--
--  Description:
--              Generic test enviroment for verification of AMD flash memory
--              VITAL models.my_mem
--
-------------------------------------------------------------------------------
--  Note:   VHDL code formating not done
--          For High/Low sector protection selection change:
--             TimingModel constant and TimingModel generic value
--
-------------------------------------------------------------------------------
LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
--USE IEEE.VITAL_timing.ALL;
--USE IEEE.VITAL_primitives.ALL;
    USE STD.textio.ALL;

LIBRARY VITAL2000;
    USE VITAL2000.vital_timing.ALL;
    USE VITAL2000.vital_primitives.ALL;

LIBRARY FMF;
    USE FMF.gen_utils.ALL;
    USE FMF.conversions.ALL;


LIBRARY work;
    USE work.amd_tc_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITY DECLARATION
-------------------------------------------------------------------------------
ENTITY testbench_640 IS
END testbench_640;


-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------
ARCHITECTURE vhdl_behavioral of testbench_640 IS
    COMPONENT my_mem 
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
        tipd_DQ3            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ4            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ5            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ6            : VitalDelayType01 := VitalZeroDelay01; -- data
        tipd_DQ7            : VitalDelayType01 := VitalZeroDelay01; -- lines
        tipd_DQ8            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ9            : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ10           : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ11           : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ12           : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ13           : VitalDelayType01 := VitalZeroDelay01; --
        tipd_DQ14           : VitalDelayType01 := VitalZeroDelay01; --

        tipd_DQ15           : VitalDelayType01 := VitalZeroDelay01; -- DQ15/A-1

        tipd_CENeg          : VitalDelayType01 := VitalZeroDelay01;
        tipd_OENeg          : VitalDelayType01 := VitalZeroDelay01;
        tipd_WENeg          : VitalDelayType01 := VitalZeroDelay01;
        tipd_RESETNeg       : VitalDelayType01 := VitalZeroDelay01;
        tipd_WPNeg          : VitalDelayType01 := VitalZeroDelay01; --WP#/ACC
        tipd_BYTENeg        : VitalDelayType01 := VitalZeroDelay01;

        -- tpd delays
        tpd_A0_DQ0          : VitalDelayType01 := UnitDelay01;--tACC
        tpd_A0_DQ1          : VitalDelayType01 := UnitDelay01;--tPACC
        tpd_CENeg_DQ0       : VitalDelayType01Z := UnitDelay01Z;
        --(tCE,tCE,tDF,-,tDF,-)
        tpd_OENeg_DQ0       : VitalDelayType01Z := UnitDelay01Z;
        --(tOE,tOE,tDF,-,tDF,-)
        tpd_RESETNeg_DQ0    : VitalDelayType01Z := UnitDelay01Z;
        --(-,-,0,-,0,-)
        tpd_CENeg_RY        : VitalDelayType01 := UnitDelay01; --tBUSY
        tpd_WENeg_RY        : VitalDelayType01 := UnitDelay01; --tBUSY

        --tsetup values
        tsetup_A0_CENeg     : VitalDelayType := UnitDelay;  --tAS edge \
        tsetup_A0_OENeg     : VitalDelayType := UnitDelay;  --tASO edge \
        tsetup_DQ0_CENeg    : VitalDelayType := UnitDelay;  --tDS edge /

        --thold values
        thold_CENeg_RESETNeg: VitalDelayType := UnitDelay;   --tRH  edge /
        thold_OENeg_WENeg   : VitalDelayType := UnitDelay;   --tOEH edge /
        thold_A0_CENeg      : VitalDelayType := UnitDelay;   --tAH  edge \
        thold_A0_OENeg      : VitalDelayType := UnitDelay;   --tAHT edge \
        thold_DQ0_CENeg     : VitalDelayType := UnitDelay;   --tDH edge /
        thold_WENeg_OENeg   : VitalDelayType := UnitDelay;   --tGHWL edge /

        --tpw values: pulse width
        tpw_RESETNeg_negedge: VitalDelayType := UnitDelay; --tRP
        tpw_OENeg_posedge   : VitalDelayType := UnitDelay; --tOEPH
        tpw_WENeg_negedge   : VitalDelayType := UnitDelay; --tWP
        tpw_WENeg_posedge   : VitalDelayType := UnitDelay; --tWPH
        tpw_CENeg_negedge   : VitalDelayType := UnitDelay; --tCP
        tpw_CENeg_posedge   : VitalDelayType := UnitDelay; --tCEPH
        tpw_A0_negedge      : VitalDelayType := UnitDelay; --tWC tRC


        -- tdevice values: values for internal delays
            --Effective Write Buffer Program Operation  tWHWH1
        tdevice_WBPB        : VitalDelayType    := 11 us;
            --Program Operation
        tdevice_POB         : VitalDelayType    := 100 us;
            --Sector Erase Operation    tWHWH2
        tdevice_SEO         : VitalDelayType    := 500 ms;
            --Timing Limit Exceeded
        tdevice_HANG        : VitalDelayType    := 400 ms; --?
            --program/erase suspend timeout
        tdevice_START_T1    : VitalDelayType    := 5 us;
            --sector erase command sequence timeout
        tdevice_CTMOUT      : VitalDelayType    := 50 us;
            --device ready after Hardware reset(during embeded algorithm)
        tdevice_READY       : VitalDelayType    := 20 us; --tReady

        -- generic control parameters
        InstancePath        : STRING    := DefaultInstancePath;
        TimingChecksOn      : BOOLEAN   := DefaultTimingChecks;
        MsgOn               : BOOLEAN   := DefaultMsgOn;
        XOn                 : BOOLEAN   := DefaultXon;
        -- memory file to be loaded
        mem_file_name       : STRING    ;--:= "am29lv640m.mem";
        prot_file_name      : STRING    ;--:= "am29lv640m_prot.mem";
        secsi_file_name     : STRING    ;--:= "am29lv_secsi.mem";

        UserPreload         : BOOLEAN   ;--:= TRUE;
        LongTimming         : BOOLEAN   ;--:= TRUE;

        -- For FMF SDF technology file usage
        TimingModel         : STRING    --:= "AM29LV640MH90R"
    );
    PORT (
        A21             : IN    std_logic := 'U'; --
        A20             : IN    std_logic := 'U'; --
        A19             : IN    std_logic := 'U'; --
        A18             : IN    std_logic := 'U'; --
        A17             : IN    std_logic := 'U'; --
        A16             : IN    std_logic := 'U'; --
        A15             : IN    std_logic := 'U'; --
        A14             : IN    std_logic := 'U'; --
        A13             : IN    std_logic := 'U'; --address
        A12             : IN    std_logic := 'U'; --lines
        A11             : IN    std_logic := 'U'; --
        A10             : IN    std_logic := 'U'; --
        A9              : IN    std_logic := 'U'; --
        A8              : IN    std_logic := 'U'; --
        A7              : IN    std_logic := 'U'; --
        A6              : IN    std_logic := 'U'; --
        A5              : IN    std_logic := 'U'; --
        A4              : IN    std_logic := 'U'; --
        A3              : IN    std_logic := 'U'; --
        A2              : IN    std_logic := 'U'; --
        A1              : IN    std_logic := 'U'; --
        A0              : IN    std_logic := 'U'; --

        DQ15            : INOUT std_logic := 'U'; -- DQ15/A-1
        DQ14            : INOUT std_logic := 'U'; --
        DQ13            : INOUT std_logic := 'U'; --
        DQ12            : INOUT std_logic := 'U'; --
        DQ11            : INOUT std_logic := 'U'; --
        DQ10            : INOUT std_logic := 'U'; --
        DQ9             : INOUT std_logic := 'U'; -- data
        DQ8             : INOUT std_logic := 'U'; -- lines
        DQ7             : INOUT std_logic := 'U'; --
        DQ6             : INOUT std_logic := 'U'; --
        DQ5             : INOUT std_logic := 'U'; --
        DQ4             : INOUT std_logic := 'U'; --
        DQ3             : INOUT std_logic := 'U'; --
        DQ2             : INOUT std_logic := 'U'; --
        DQ1             : INOUT std_logic := 'U'; --
        DQ0             : INOUT std_logic := 'U'; --

        CENeg           : IN    std_logic := 'U';
        OENeg           : IN    std_logic := 'U';
        WENeg           : IN    std_logic := 'U';
        RESETNeg        : IN    std_logic := 'U';
        WPNeg           : IN    std_logic := 'U'; --WP#/ACC
        BYTENeg         : IN    std_logic := 'U';
        RY              : OUT   std_logic := 'U'  --RY/BY#
    );
    END COMPONENT;

    FOR ALL: my_mem USE ENTITY WORK.my_mem(VHDL_BEHAVIORAL);

    ---------------------------------------------------------------------------
    --memory configuration
    ---------------------------------------------------------------------------
    CONSTANT MaxData        :   NATURAL :=  16#FF#; --255;
    CONSTANT SecSize        :   NATURAL :=  16#FFFF#; --65535
    CONSTANT SecSiSize      :   NATURAL :=  255;
    CONSTANT SecNum         :   NATURAL :=  127;
    CONSTANT HiAddrBit      :   NATURAL :=  21;
    --Address of the Protected Sector
--    CONSTANT ProtSecNum     :   NATURAL :=  SecNum;

    ---------------------------------------------------------------------------
    --model configuration
    ---------------------------------------------------------------------------
    CONSTANT mem_file       :   STRING  := "am29lv640m.mem";
    CONSTANT prot_file      :   STRING  := "am29lv640m_prot.mem";
    CONSTANT secsi_file     :   STRING  := "am29lv_secsi.mem";

    CONSTANT UserPreload    :   boolean :=  TRUE;
    CONSTANT DebugInfo      :   boolean :=  FALSE;
    CONSTANT LongTimming    :   boolean :=  TRUE;
    CONSTANT TimingModel    :   STRING  :=  "MY_MEM";
	                                     -- "AM29LV640MH90R";--High sect prot.
                                         -- "AM29LV128ML93R";--Low sect. prot.
    ---------------------------------------------------------------------------
    SIGNAL ProtSecNum       :   NATURAL :=  SecNum ;

    --Flash Memory Array
    TYPE SecType  IS ARRAY (0 TO SecSize) OF
                     INTEGER RANGE -1 TO MaxData;
    TYPE MemArray IS ARRAY (0 TO SecNum) OF
                     SecType;

    --Common Flash Interface Query codes
    TYPE CFItype  IS ARRAY (16#10# TO 16#50#) OF
                    NATURAL RANGE 0 TO 16#FF#;

    --SecSi Sector
    TYPE SecSiType  IS ARRAY ( 0 TO SecSiSize) OF
                     INTEGER RANGE -1 TO MaxData;

    ---------------------------------------------------------------------------
    --  memory declaration
    ---------------------------------------------------------------------------
    --             -- Mem(SecAddr)(Address)....
    SHARED  VARIABLE Mem            : MemArray := (OTHERS => (OTHERS=> MaxData));
    SHARED  VARIABLE CFI_array      : CFItype   :=(OTHERS=>0);
    SHARED  VARIABLE SecSi          : SecSiType :=(OTHERS=>0);

    --command sequence
    SHARED VARIABLE cmd_seq         : cmd_seq_type;

    SIGNAL          status          : status_type := none;
    SIGNAL          sts_check       : std_logic_vector(7 downto 0);


    SIGNAL check_err      :   std_logic := '0';
    SIGNAL ErrorInTest    :   std_logic := '0'; --
    ----------------------------------------------------------------------------
    --Personality module:
    --
    --  instanciates the DUT module and adapts generic test signals to it
    --  TBD: block port
    ----------------------------------------------------------------------------
    --DUT port
    SIGNAL T_DQ       : std_logic_vector(15 downto 0) := (OTHERS=>'U');
    SIGNAL T_A        : std_logic_vector(HiAddrBit downto 0) := (OTHERS=>'U');
    SIGNAL T_RESETNeg : std_logic                     := 'U';
    SIGNAL T_CENeg    : std_logic                     := 'U';
    SIGNAL T_WENeg    : std_logic                     := 'U';
    SIGNAL T_OENeg    : std_logic                     := 'U';
    SIGNAL T_WPNeg    : std_logic                     := 'U';
    SIGNAL T_BYTENeg  : std_logic                     := 'U';
    SIGNAL T_RY       : std_logic                     := 'U';

    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    --SecSi ProtectionStatus
    SHARED VARIABLE FactoryProt     : std_logic := '1';
    --Sector Protection Status
    SHARED VARIABLE Sec_Prot        : std_logic_vector (SecNum downto 0) :=
                                                        (OTHERS => '0');
    SHARED VARIABLE Sect            : NATURAL RANGE 0 TO SecNum  := 0;
    SHARED VARIABLE Addr            : NATURAL RANGE 0 TO SecSize := 0;
    SHARED VARIABLE WriteData       : NATURAL RANGE 0 TO MaxData := 0;


    --CONSTANT
    --timming parameters
    CONSTANT RESETNeg_pw            : time    :=  500 ns; --tRP

    SIGNAL pwron                    : std_logic := '0';

    SIGNAL Tseries                  : NATURAL;
    SIGNAL Tcase                    : NATURAL;

    SHARED VARIABLE ts_cnt  :   NATURAL RANGE 1 TO 30:=1; -- testseries counter
    SHARED VARIABLE tc_cnt  :   NATURAL RANGE 0 TO 10:=0;    -- testcase counter


    BEGIN
        DUT : my_mem
        GENERIC MAP (
            -- tipd delays: interconnect path delays
            tipd_A0             => VitalZeroDelay01, --
            tipd_A1             => VitalZeroDelay01, --
            tipd_A2             => VitalZeroDelay01, --
            tipd_A3             => VitalZeroDelay01, --
            tipd_A4             => VitalZeroDelay01, --
            tipd_A5             => VitalZeroDelay01, --
            tipd_A6             => VitalZeroDelay01, --
            tipd_A7             => VitalZeroDelay01, --
            tipd_A8             => VitalZeroDelay01, --
            tipd_A9             => VitalZeroDelay01, --address
            tipd_A10            => VitalZeroDelay01, --lines
            tipd_A11            => VitalZeroDelay01, --
            tipd_A12            => VitalZeroDelay01, --
            tipd_A13            => VitalZeroDelay01, --
            tipd_A14            => VitalZeroDelay01, --
            tipd_A15            => VitalZeroDelay01, --
            tipd_A16            => VitalZeroDelay01, --
            tipd_A17            => VitalZeroDelay01, --
            tipd_A18            => VitalZeroDelay01, --
            tipd_A19            => VitalZeroDelay01, --
            tipd_A20            => VitalZeroDelay01, --
            tipd_A21            => VitalZeroDelay01, --

            tipd_DQ0            => VitalZeroDelay01, --
            tipd_DQ1            => VitalZeroDelay01, --
            tipd_DQ2            => VitalZeroDelay01, --
            tipd_DQ3            => VitalZeroDelay01, --
            tipd_DQ4            => VitalZeroDelay01, --
            tipd_DQ5            => VitalZeroDelay01, --
            tipd_DQ6            => VitalZeroDelay01, -- data
            tipd_DQ7            => VitalZeroDelay01, -- lines
            tipd_DQ8            => VitalZeroDelay01, --
            tipd_DQ9            => VitalZeroDelay01, --
            tipd_DQ10           => VitalZeroDelay01, --
            tipd_DQ11           => VitalZeroDelay01, --
            tipd_DQ12           => VitalZeroDelay01, --
            tipd_DQ13           => VitalZeroDelay01, --
            tipd_DQ14           => VitalZeroDelay01, --

            tipd_DQ15           => VitalZeroDelay01, -- DQ15/A-1

            tipd_CENeg          => VitalZeroDelay01,
            tipd_OENeg          => VitalZeroDelay01,
            tipd_WENeg          => VitalZeroDelay01,
            tipd_RESETNeg       => VitalZeroDelay01,
            tipd_WPNeg          => VitalZeroDelay01,--WP#/ACC
            tipd_BYTENeg        => VitalZeroDelay01,

            -- tpd delays
            tpd_A0_DQ0          => UnitDelay01,--tACC
            tpd_A0_DQ1          => UnitDelay01,--tPACC
            tpd_CENeg_DQ0       => UnitDelay01Z,
            --(tCE,tCE,tDF,-,tDF
            tpd_OENeg_DQ0       => UnitDelay01Z,
            --(tOE,tOE,tDF,-,tDF
            tpd_RESETNeg_DQ0    => UnitDelay01Z,
            --(-,-,0,-,0,-)
            tpd_CENeg_RY        => UnitDelay01, --tBUSY
            tpd_WENeg_RY        => UnitDelay01, --tBUSY

            --tsetup values
            tsetup_A0_CENeg     => UnitDelay,  --tAS edge \
            tsetup_A0_OENeg     => UnitDelay,  --tASO edge \
            tsetup_DQ0_CENeg    => UnitDelay,  --tDS edge /

            --thold values
            thold_CENeg_RESETNeg=> UnitDelay,   --tRH  edge /
            thold_OENeg_WENeg   => UnitDelay,   --tOEH edge /
            thold_A0_CENeg      => UnitDelay,   --tAH  edge \
            thold_A0_OENeg      => UnitDelay,   --tAHT edge \
            thold_DQ0_CENeg     => UnitDelay,   --tDH edge /
            thold_WENeg_OENeg   => UnitDelay,   --tGHVL edge /

            --tpw values: pulse width
            tpw_RESETNeg_negedge=> UnitDelay, --tRP
            tpw_OENeg_posedge   => UnitDelay, --tOEPH
            tpw_WENeg_negedge   => UnitDelay, --tWP
            tpw_WENeg_posedge   => UnitDelay, --tWPH
            tpw_CENeg_negedge   => UnitDelay, --tCP
            tpw_CENeg_posedge   => UnitDelay, --tCEPH
            tpw_A0_negedge      => UnitDelay, --tWC tRC
            -- tdevice values: values for internal delays
                --Effective Write Buffer Program Operation  tWHWH1
            tdevice_WBPB        => 11 us,
                --Program Operation
            tdevice_POB         => 100 us,
                --Sector Erase Operation    tWHWH2
            tdevice_SEO         => 500 ms,
                --Timing Limit Exceeded
            tdevice_HANG        => 400 ms, --?
                --program/erase suspend timeout
            tdevice_START_T1    => 5 us,
                --sector erase command sequence timeout
            tdevice_CTMOUT      => 50 us,
                --device ready after Hardware reset(during embeded algorithm)
            tdevice_READY       => 20 us, --tReady

            -- generic control parameters
            InstancePath        => DefaultInstancePath,
            TimingChecksOn      => TRUE,--DefaultTimingChecks,
            MsgOn               => DefaultMsgOn,
            XOn                 => DefaultXon,
            -- memory file to be loaded
            mem_file_name       => mem_file,
            prot_file_name      => prot_file ,
            secsi_file_name     => secsi_file,

            UserPreload         => UserPreload,
            LongTimming         => LongTimming,
            -- For FMF SDF technology file usage
            TimingModel         => "AM29LV640MH90R" -- TimingModel
        )
        PORT MAP(
            A21        => T_A(21), --
            A20        => T_A(20), --
            A19        => T_A(19), --
            A18        => T_A(18), --
            A17        => T_A(17), --
            A16        => T_A(16), --
            A15        => T_A(15), --
            A14        => T_A(14), --
            A13        => T_A(13), --address
            A12        => T_A(12), --lines
            A11        => T_A(11), --
            A10        => T_A(10), --
            A9         => T_A(9), --
            A8         => T_A(8), --
            A7         => T_A(7), --
            A6         => T_A(6), --
            A5         => T_A(5),--
            A4         => T_A(4),--
            A3         => T_A(3), --
            A2         => T_A(2), --
            A1         => T_A(1), --
            A0         => T_A(0), --

            DQ15       => T_DQ(15), -- DQ15/A-1
            DQ14       => T_DQ(14), --
            DQ13       => T_DQ(13), --
            DQ12       => T_DQ(12), --
            DQ11       => T_DQ(11), --
            DQ10       => T_DQ(10), --
            DQ9        => T_DQ(9), -- data
            DQ8        => T_DQ(8), -- lines
            DQ7        => T_DQ(7), --
            DQ6        => T_DQ(6), --
            DQ5        => T_DQ(5), --
            DQ4        => T_DQ(4), --
            DQ3        => T_DQ(3), --
            DQ2        => T_DQ(2), --
            DQ1        => T_DQ(1), --
            DQ0        => T_DQ(0), --

            CENeg      => T_CENeg,
            OENeg      => T_OENeg,
            WENeg      => T_WENeg,
            RESETNeg   => T_RESETNeg,
            WPNeg      => T_WPNeg, --WP#/ACC
            BYTENeg    => T_BYTENeg,
            RY         => T_RY  --RY/BY#
        );

    ---------------------------------------------------------------------------
    --protected sector
    ---------------------------------------------------------------------------
    ProtSecNum <= SecNum WHEN  TimingModel(11) = 'H' ELSE
                  0 ;--  WHEN  TimingModel = "AM29LV128ML93R"

    pwron <= '0', '1' after 1 ns;

--At the end of the simulation, if ErrorInTest='0' there were no errors
err_ctrl : PROCESS ( check_err  )
    BEGIN
        IF check_err = '1' THEN
            ErrorInTest <= '1';
        END IF;
    END PROCESS err_ctrl;

tb  :PROCESS

    --------------------------------------------------------------------------
    --= PROCEDURE to select TC
    -- can be modified to read TC list from file, or to generate random list
    --------------------------------------------------------------------------
    PROCEDURE   Pick_TC
        (Model   :  IN  STRING  := "AM29LV640MH90R"  )
    IS
    BEGIN
        IF TC_cnt < tc(TS_cnt) THEN
            TC_cnt := TC_cnt+1;
        ELSE
            TC_cnt:=1;
            IF TS_cnt<30 THEN
                TS_cnt := TS_cnt+1;
            ELSE
                -- end test
                IF ErrorInTest='0' THEN
                    REPORT "Test Ended without errors"
                    SEVERITY note;
                ELSE
                    REPORT "There were errors in test"
                    SEVERITY note;
                END IF;
                WAIT;
            END IF;
        END IF;
    END PROCEDURE Pick_TC;

   ---------------------------------------------------------------------------
    --bus commands, device specific implementation
    ---------------------------------------------------------------------------
    TYPE bus_type IS (bus_idle,
                      bus_standby,  --CE# deasseretd, others are don't care
                      bus_enable,   --CE# asserted, others deasserted
                      bus_output_disable,
                      bus_reset,
                      bus_write,
                      bus_read);

    --bus drive for specific command sequence cycle
    PROCEDURE bus_cycle(
        bus_cmd :IN   bus_type := bus_idle;
        byte    :IN   boolean                      ;
        data    :IN   INTEGER RANGE -2 TO MaxData  := -2; -- -1 for all Z
        dataHi  :IN   INTEGER RANGE -2 TO MaxData  := -2; -- -2 for ignore
        sector  :IN   INTEGER RANGE -1 TO SecNum   := -1; -- -1 for ignore addr
        address :IN   NATURAL RANGE  0 TO SecSize  := 0;
        disable :IN   boolean                      := false;
        violate :IN   boolean                      := false;
        tm      :IN   TIME                         := 10 ns)
    IS

        VARIABLE tmp : std_logic_vector(15 downto 0);
    BEGIN

        IF data=-1 THEN -- HiZ
            T_DQ(7 downto 0) <= (OTHERS => 'Z');
        END IF;

        IF (NOT byte)THEN --word access
            IF dataHi=-1 THEN -- HiZ
                T_DQ(15 downto 8) <= (OTHERS => 'Z');
            END IF;
            T_BYTENeg <= '1';
        ELSE                 --byte access
            T_BYTENeg <= '0';
            T_DQ(14 downto 8) <= (OTHERS => 'Z');
        END IF;

        IF sector > -1 THEN
            T_A(HiAddrBit downto 15) <= to_slv(sector, HiAddrbit-14);
            tmp := to_slv(address, 16);
            IF byte THEN
                T_A(14 downto 0) <= tmp(15 downto 1);
                T_DQ(15) <= tmp(0);
            ELSE
                T_A(14 downto 0) <= tmp(14 downto 0);
            END IF;

        END IF;

        wait for 1 ns;

        CASE bus_cmd IS
            WHEN bus_output_disable    =>
                T_OENeg    <= '1';
                WAIT FOR 20 ns;

            WHEN bus_idle       =>
                T_RESETNeg <= '1';
                T_WENeg    <= '1';
                T_CENeg    <= '1';
                T_OENeg    <= '1';
                IF disable THEN
                    T_WPNeg <= '0';
                ELSE
                    T_WPNeg <= '1';
                END IF;
                WAIT FOR 30 ns;

            WHEN bus_standby             =>
                T_CENeg    <= '1';
                WAIT FOR 30 ns;

            WHEN bus_reset               =>
                T_RESETNeg <= '0', '1' AFTER tm ;
                -- WAIT FOR 500 ns should follow this bus cmd for reset to
                --complete
                WAIT FOR 30 ns;

            WHEN bus_enable              =>
                T_WENeg    <= '1' AFTER 50 ns;   ---
                T_CENeg    <= '0' AFTER 50 ns;   ---
                T_OENeg    <= '1' AFTER 30 ns;   ---

                WAIT FOR tm ;

            WHEN bus_write  =>
                T_OENeg <= '1' ;-- AFTER 5 ns;
                T_CENeg <= '0' AFTER 10 ns ;
                T_WENeg <= '0' AFTER 20 ns;

                IF data>-1 THEN
                    T_DQ(7 downto 0) <= to_slv(data,8);
                END IF;
                IF NOT byte THEN
                    IF dataHi>-1 THEN
                        T_DQ(15 downto 8) <= to_slv(dataHi,8);
                    END IF;
                END IF;

                IF violate THEN
                    T_WENeg <= '1';
                    WAIT FOR 50 ns;
                    T_WENeg <= '0', '1' AFTER tm;
                    WAIT FOR 50 ns;
                ELSE
                    WAIT FOR 100 ns;
                END IF;

            WHEN bus_read  =>

                T_CENeg     <= '0' ;
                T_WENeg     <= '1'AFTER 10 ns;
                IF NOT disable  THEN
                    T_OENeg <= '0' AFTER 15 ns;
                ELSE
                    T_OENeg <= '1';
                END IF;

                IF NOT byte THEN
                    T_DQ(15 downto 8) <= (OTHERS => 'Z');
                END IF;
                T_DQ(7 downto 0)      <= (OTHERS => 'Z');

                WAIT FOR 100 ns;

                -- T_OENeg <= '1' ; -----------

        END CASE;


    END PROCEDURE;


   ---------------------------------------------------------------------------
    --procedure to decode commands into specific bus command sequence
    ---------------------------------------------------------------------------
    PROCEDURE cmd_dc
        (   command  :   IN  cmd_rec   )
    IS
        VARIABLE    D_hi    : NATURAL ;--RANGE 0 to MaxData;
        VARIABLE    D_lo    : NATURAL RANGE 0 to MaxData;
        VARIABLE    Addr    : NATURAL RANGE 0 to SecSize  :=0;
        VARIABLE    Addrfix : NATURAL RANGE 0 to SecSize/2:=0;
        VARIABLE    Sect    : INTEGER RANGE -1 to SecNum  :=0;
        VARIABLE    slv_1, slv_2 : std_logic_vector(7 downto 0);
        VARIABLE    byte    : boolean;
        VARIABLE    i       : NATURAL;
    BEGIN
        CASE command.cmd IS
            WHEN    idle        =>
                bus_cycle(bus_cmd => bus_idle,
                          byte    => command.byte,
                          disable => command.aux=disable);

            WHEN    h_reset     =>
                bus_cycle(bus_cmd => bus_reset,
                          byte    => command.byte,
                          tm      => command.wtime);

            WHEN    rd        =>
                bus_cycle(bus_cmd => bus_enable,
                          byte    => command.byte,
                          data    => -1,
                          sector  => command.sect,
                          address => command.addr,
                          tm      => 90 ns);

                bus_cycle(bus_cmd => bus_read,
                          byte    => command.byte,
                          data    => -1,
                          dataHi  => -1,
                          sector  => command.sect,
                          address => command.addr,
                          disable => command.aux=disable);

                bus_cycle(bus_cmd => bus_output_disable,
                          byte    => command.byte);

            WHEN    rd_page     =>
                bus_cycle(bus_cmd => bus_enable,
                          byte    => command.byte,
                          data    => -1,
                          sector  => 0,
                          address => 0,
                          tm      => 90 ns);

                Addr :=  command.addr;
                Sect :=  command.sect;
                byte :=  command.byte;
                ---- 08July----
                WAIT FOR 10 ns;
                --------------
                i := 0;
                WHILE i < command.d_hi LOOP

                    IF command.wtime > 0 ns THEN

                        bus_cycle(bus_cmd => bus_output_disable,  ----
                                  byte    => byte);       ----

                        --byte toggle mode
                        bus_cycle(bus_cmd => bus_enable,
                                  byte    => byte,
                                  data    => -1,
                                  sector  => -1,
                                  tm      => 10 ns);
                        byte := false;
                        bus_cycle(bus_cmd => bus_enable,
                                  byte    => byte,
                                  data    => -1,
                                  sector  => -1,
                                  tm      => 10 ns);
                        Addrfix := Addr /2;
                        IF Addr < SecSize THEN
                            Addr := Addr+1;
                        ELSE
                            Addr := 0;
                            IF Sect < SecNum THEN
                                Sect := Sect+1;
                            ELSE
                                REPORT "No more locations to read !!!"
                                SEVERITY warning;
                            END IF;
                        END IF;
                        --word read;
                        bus_cycle(bus_cmd => bus_read,
                                  byte    => byte,
                                  data    => -1,
                                  dataHi  => -1,
                                  sector  => Sect,
                                  address => Addrfix);

                        bus_cycle(bus_cmd => bus_output_disable,  ----
                                  byte    => byte);       ----

                        bus_cycle(bus_cmd => bus_enable,
                                  byte    => byte,
                                  data    => -1,
                                  sector  => -1,
                                  tm      => 10 ns);
                        byte := true;
                        bus_cycle(bus_cmd => bus_enable,
                                  byte    => byte,
                                  data    => -1,
                                  sector  => -1,
                                  tm      => 30 ns);

                        --first byte read
                        bus_cycle(bus_cmd => bus_read,
                                  byte    => byte,
                                  data    => -1,
                                  dataHi  => -1,
                                  sector  => Sect,
                                  address => Addr);

                        bus_cycle(bus_cmd => bus_output_disable,  ----
                                  byte    => byte);       ----

                        IF Addr < SecSize THEN
                            Addr := Addr+1;
                        ELSE
                            Addr := 0;
                            IF Sect < SecNum THEN
                                Sect := Sect+1;
                            ELSE
                                REPORT "No more locations to read !!!"
                                SEVERITY warning;
                            END IF;
                        END IF;
                        i := i +3;
                        wait for 10 ns; -------
                    ELSE
                        byte :=  command.byte;
                    END IF;
                    --second byte read in byte toggle mode
                    bus_cycle(bus_cmd => bus_read,
                              byte    => byte,
                              data    => -1,
                              dataHi  => -1,
                              sector  => Sect,
                              address => Addr);


                    IF Addr < SecSize THEN
                        Addr := Addr+1;
                    ELSE
                        Addr := 0;
                        IF Sect < SecNum THEN
                            Sect := Sect+1;
                        ELSE
                            REPORT "No more locations to read !!!"
                            SEVERITY warning;
                        END IF;
                    END IF;
                    i := i +1;
                    WAIT FOR 10 ns;
                END LOOP;
                bus_cycle(bus_cmd => bus_output_disable,
                          byte    => command.byte);



            WHEN    w_cycle     =>

                D_lo    :=  16#AA# ; --first command data
                Addr    :=  16#AAA#; --first command byte address
                D_hi    :=  16#55#;  --second command data
                Addrfix :=  16#555#; --second command byte address
                IF NOT command.byte THEN
                    --if word addressing
                    Addr    := 16#555#; --first command byte address
                    Addrfix := 16#2AA#; --second command byte address
                END IF;

                bus_cycle(bus_cmd => bus_write,
                         byte    => command.byte,
                         data    => D_lo,
                         dataHi  => 0,
                         sector  => 0,
                         address => Addr,
                         violate => command.aux=violate,
                         tm      => command.wtime);

                bus_cycle(bus_cmd => bus_standby,
                         byte    => command.byte);

                bus_cycle(bus_cmd => bus_write,
                         byte    => command.byte,
                         data    => D_hi,
                         dataHi  => 0,
                         sector  => 0,
                         address => Addrfix);

                bus_cycle(bus_cmd => bus_standby,
                         byte    => command.byte);


            WHEN    w_reset | w_prog | w_erase | w_unlock |
                    w_autoselect | w_enter_sec   =>
                Addr    :=  16#AAA#;
                IF NOT command.byte THEN
                    --if word addressing
                    Addr    := 16#555#; --first command byte address
                END IF;

                CASE  command.cmd IS
                    WHEN w_reset =>
                        d_lo := 16#F0#;
                    WHEN w_prog =>
                        d_lo := 16#A0#;
                    WHEN w_erase =>
                        d_lo := 16#80#;
                    WHEN w_unlock =>
                        d_lo := 16#20#;
                    WHEN w_autoselect  =>
                        d_lo := 16#90#;
                    WHEN w_enter_sec =>
                        d_lo := 16#88#;
                    WHEN OTHERS  =>
                        d_lo :=  0;
                END CASE;

                bus_cycle(bus_cmd => bus_write,
                         byte    => command.byte,
                         data    => d_lo,
                         dataHi  => 0,
                         sector  => 0,
                         address => Addr);
                bus_cycle(bus_cmd => bus_standby,
                         byte    => command.byte);



            WHEN w_unlock_reset =>
                Addr    :=  16#AAA#; --first command byte address
                IF NOT command.byte THEN
                    --if word addressing
                    Addr    := 16#555#; --first command byte address
                END IF;
                bus_cycle(bus_cmd => bus_write,
                         byte    => command.byte,
                         data    => 16#90#,
                         dataHi  => 0,
                         sector  => 0,
                         address => Addr);

                bus_cycle(bus_cmd => bus_standby,
                         byte    => command.byte);

                bus_cycle(bus_cmd => bus_write,
                         byte    => command.byte,
                         data    => 16#F0#,
                         dataHi  => 0,
                         sector  => 0,
                         address => Addr);

                bus_cycle(bus_cmd => bus_standby,
                         byte    => command.byte);

            WHEN w_chip_ers =>
                Addr    :=  16#AAA#; --first command byte address
                IF NOT command.byte THEN
                    --if word addressing
                    Addr    := 16#555#; --first command byte address
                END IF;
                bus_cycle(bus_cmd => bus_write,
                         byte    => command.byte,
                         data    => 16#10#,
                         dataHi  => 0,
                         sector  => 0,
                         Address => Addr);
                FOR i IN 0 TO SecNum LOOP
                    IF Sec_Prot(i)/='1' THEN
                        mem(i) := (OTHERS=>16#FF#);
                    END IF;
                END LOOP;
                bus_cycle(bus_cmd => bus_standby,
                         byte    => command.byte);


            WHEN w_cfi =>
                Addr    :=  16#AA#; --first command byte address
                IF NOT command.byte THEN
                    --if word addressing
                    Addr    := 16#55#; --first command byte address
                END IF;
                bus_cycle(bus_cmd => bus_write,
                         byte    => command.byte,
                         data    => 16#98#,
                         dataHi  => 0,
                         sector  => 0,
                         Address => Addr);

                bus_cycle(bus_cmd => bus_standby,
                         byte    => command.byte);



            WHEN w_suspend =>
                bus_cycle(bus_cmd => bus_write,
                         byte    => command.byte,
                         data    => 16#B0#,
                         dataHi  => 0,
                         sector  => -1);

                bus_cycle(bus_cmd => bus_standby,
                         byte    => command.byte);

            WHEN w_resume =>
                bus_cycle(bus_cmd => bus_write,
                         byte    => command.byte,
                         data    => 16#30#,
                         dataHi  => 0,
                         sector  => -1);

                bus_cycle(bus_cmd => bus_standby,
                         byte    => command.byte);


            WHEN w_data =>

                D_hi :=  command.d_hi MOD 16#100#;
                D_lo :=  command.d_lo ;
                Addr :=  command.addr;
                Sect :=  command.sect;

                bus_cycle(bus_cmd => bus_write,
                         byte     => command.byte,
                         data     => D_lo,
                         dataHi   => D_hi,
                         sector   => Sect,
                         address  => Addr);

                bus_cycle(bus_cmd => bus_standby,
                         byte    => command.byte);


                IF NOT command.byte THEN
                    Addr := Addr*2;
                END IF;

                --write value(s) in default mem
                IF status = erase_active AND Sec_Prot(Sect)/='1'THEN
                    --sector should be erased
                    mem(Sect) := (OTHERS=>16#FF#);

                ELSIF status = erase_na AND Sec_Prot(Sect)/='1'THEN
                    --sector erase terminated = data integrity violated
                    mem(Sect) := (OTHERS=>-1);

                ELSIF status = readX AND Sec_Prot(Sect)/='1' THEN
                    mem(Sect)(Addr) := -1;
                    IF NOT command.byte THEN
                        mem(Sect)(Addr+1) := -1;
                    END IF;

                -- Write to Secure Silicon Sector Region
                ELSIF status = rd_SecSi AND FactoryProt/='1' THEN
                    slv_1 := to_slv(d_lo,8);
                    IF SecSi(Addr)>-1 THEN
                        slv_2 := to_slv(SecSi(Addr),8);
                    ELSE
                        slv_2 := (OTHERS=>'X');
                    END IF;

                    FOR i IN 0 to 7 LOOP
                        IF slv_2(i)='0' THEN
                            slv_1(i):='0';
                        END IF;
                    END LOOP;
                    SecSi(Addr) := to_nat(slv_1);
                    IF NOT command.byte THEN
                        slv_1 := to_slv(d_hi,8);
                        IF SecSi(Addr+1)>-1 THEN
                            slv_2 := to_slv(SecSi(Addr+1),8);
                        ELSE
                            slv_2 := (OTHERS=>'X');
                        END IF;
                        FOR i IN 0 to 7 LOOP
                            IF slv_2(i)='0' THEN
                                slv_1(i):='0';
                            END IF;
                        END LOOP;
                        SecSi(Addr+1) := to_nat(slv_1);
                    END IF;

                ELSIF status=buff_wr_busy THEN
                    --Write to Buffer command cycle
                    null;

                ELSIF status=erase_na THEN
                    --sector erase command sequence violation
                    null;

                -- Write to Flash Memory Array
                ELSIF status /= err AND Sec_Prot(Sect)/='1'THEN
                    slv_1 := to_slv(d_lo,8);
                    IF mem(Sect)(Addr)>-1 THEN
                        slv_2 := to_slv(mem(Sect)(Addr),8);
                    ELSE
                        slv_2 := (OTHERS=>'X');
                    END IF;

                    FOR i IN 0 to 7 LOOP
                        IF slv_2(i)='0' THEN
                            slv_1(i):='0';
                        END IF;
                    END LOOP;
                    mem(Sect)(Addr) := to_nat(slv_1);
                    IF NOT command.byte THEN
                        slv_1 := to_slv(d_hi,8);
                        IF mem(Sect)(Addr+1)>-1 THEN
                            slv_2 := to_slv(mem(Sect)(Addr+1),8);
                        ELSE
                            slv_2 := (OTHERS=>'X');
                        END IF;
                        FOR i IN 0 to 7 LOOP
                            IF slv_2(i)='0' THEN
                                slv_1(i):='0';
                            END IF;
                        END LOOP;
                        mem(Sect)(Addr+1) := to_nat(slv_1);
                    END IF;
                END IF;


            WHEN    wt          =>
                WAIT FOR command.wtime;

            WHEN    wt_rdy      =>
                IF T_RY/='1' THEN
                    WAIT UNTIL rising_edge(T_RY) FOR command.wtime;
                END IF;

            WHEN    wt_bsy      =>
                IF T_RY='1' THEN
                    WAIT UNTIL falling_edge(T_RY) FOR command.wtime;
                END IF;

            WHEN    OTHERS  =>  null;
        END CASE;
    END PROCEDURE;


    VARIABLE cmd_cnt    :   NATURAL;
    VARIABLE command    :   cmd_rec;  --

BEGIN
    Pick_TC (Model   =>  "AM29LV640MH90R"   );

    Tseries <=  ts_cnt  ;
    Tcase   <=  tc_cnt  ;

    Generate_TC
        (Model       => "AM29LV640MH90R"  ,
         Series      => ts_cnt,
         TestCase    => tc_cnt,
         command_seq => cmd_seq);


    cmd_cnt := 1;
    WHILE cmd_seq(cmd_cnt).cmd/=done LOOP
        command:= cmd_seq(cmd_cnt);
        IF command.sect = -1 THEN
            command.sect := ProtSecNum;
        END IF;
        status   <=  command.status;
        sts_check<=  to_slv(command.d_lo,8); --used only for toggle/status check
        cmd_dc(command);
        cmd_cnt :=cmd_cnt +1;

    END LOOP;

END PROCESS tb;

--process to monitor WP#
PROCESS(T_WPNeg)
VARIABLE reg : std_logic;
BEGIN
    IF falling_edge(T_WPNeg) THEN
        reg := Sec_Prot(ProtSecNum);
        Sec_Prot(ProtSecNum) := '1';
    ELSIF rising_edge(T_WPNeg) THEN
        Sec_Prot(ProtSecNum) := reg;
    END IF;
END PROCESS;

--------------------------------------------------------------------------------
-- Checker process,
-- Bus transition extractor: when bus cycle is read samples addr and data
-- Transition checker      : verifies correct read data using default memory
--------------------------------------------------------------------------------
checker: PROCESS
    VARIABLE RAddr      :   NATURAL;
    VARIABLE RSect      :   NATURAL;
    VARIABLE longread   :   boolean;
    VARIABLE shortread  :   boolean;
    VARIABLE toggle     :   boolean:=false;
    VARIABLE toggle_sts :   std_logic_vector(7 downto 0);

BEGIN
--    Transition extractor
    IF (T_CENeg='0'AND T_OENeg='0'AND T_WENeg='1') THEN
        IF T_BYTENeg='1' THEN
            RAddr := to_nat(T_A(14 downto 0)&'0');
        ELSE
            RAddr := to_nat(T_A(14 downto 0)&T_DQ(15));
        END IF;
        RSect := to_nat(T_A(HiAddrBit downto 15));

        shortread:= false;
        longread := false;

        --DUT specific timing
        IF (T_CENeg'EVENT OR T_WENeg'EVENT OR T_A(HiAddrBit downto 2)'EVENT)AND   --
           (status=read OR status=rd_cfi OR status=rd_secsi) THEN --OR status=readX)
            longread := true;
            CASE TimingModel IS
                WHEN    "AM29LV640MH90R"    |
                        "AM29LV640ML90R"   =>  WAIT FOR 95 ns;
--                WHEN  "AM29LV640MH101"  |
--                        "AM29LV640ML101"   =>  WAIT FOR 105 ns;
--                WHEN  "AM29LV640MH101R" |
--                        "AM29LV640ML101R"  =>  WAIT FOR 105 ns;
--                WHEN  "AM29LV640MH112"  |
--                      "AM29LV640ML112"   =>  WAIT FOR 115 ns;
--                WHEN  "AM29LV640MH112R" |
--                      "AM29LV640ML112R"  =>  WAIT FOR 115 ns;
--                WHEN  "AM29LV640MH120"  |
--                      "AM29LV640ML120"   =>  WAIT FOR 125 ns;
--                WHEN  "AM29LV640MH120R" |
--                      "AM29LV640ML120R"  =>  WAIT FOR 125 ns;
                WHEN OTHERS                 =>
                    REPORT "Timing model NOT supported : "&TimingModel
                    SEVERITY error;
            END CASE;

        ELSIF T_A(1 downto 0)'EVENT OR
             (T_DQ(15)'EVENT AND T_BYTENeg='0')OR
             (T_BYTENeg'EVENT) OR
              T_OENeg'EVENT OR
              (status/=read AND status/=rd_cfi AND
               status/=rd_secsi)  THEN  --AND status/=readX)
            shortread:=true;
            CASE TimingModel IS
                WHEN    "AM29LV640MH90R"    |
                 "AM29LV640ML90R"   =>  WAIT FOR 30 ns;
--                WHEN  "AM29LV640MH101"  |
--                        "AM29LV640ML101"   =>  WAIT FOR 40 ns;
--                WHEN  "AM29LV640MH101R" |
--                        "AM29LV640ML101R"  =>  WAIT FOR 40 ns;
--                WHEN  "AM29LV640MH112"  |
--                        "AM29LV640ML112"   =>  WAIT FOR 45 ns;
--                WHEN  "AM29LV640MH112R" |
--                        "AM29LV640ML112R"  =>  WAIT FOR 45 ns;
--                WHEN  "AM29LV640MH120"  |
--                       "AM29LV640ML120"   =>  WAIT FOR 45 ns;
--                WHEN  "AM29LV640MH120R" |
--                      "AM29LV640ML120R"  =>  WAIT FOR 45 ns;
                WHEN OTHERS                 =>
                    REPORT "Timing model NOT supported : "&TimingModel
                    SEVERITY error;
            END CASE;

        END IF;



        --Checker
        IF longread OR shortread THEN

            CASE status IS
                WHEN none       =>
                    toggle := false;

                -- read memory array data
                WHEN read       =>
                    toggle := false;
                    Check_read (
                        DQ       => T_DQ,
                        D_lo     => mem(RSect)(RAddr),
                        D_hi     => mem(RSect)(RAddr+1),
                        Byte     => T_BYTENeg,
                        check_err=> check_err);

                -- read secure silicon region
                WHEN rd_secsi =>
                    toggle := false;
                    Check_SecSi (
                        DQ       => T_DQ,
                        D_lo     => SecSi(RAddr),
                        D_hi     => SecSi(RAddr+1),
                        Byte     => T_BYTENeg,
                        check_err=>check_err);


                --read CFI query codes
                WHEN rd_cfi =>
                    RAddr := to_nat(T_A(14 downto 0));   --x16 addressing
                    toggle := false;
                    Check_CFI (
                        DQ       => T_DQ,
                        D_lo     => CFI_array(RAddr) ,
                        D_hi     => 0 ,
                        Byte     => T_BYTENeg,
                        check_err=>check_err);



                -- read Autoselect codes
                WHEN rd_AS =>
                    RAddr := to_nat(T_A(14 downto 0));   --x16 addressing
                    toggle := false;
                    Check_AS (
                        DQ       => T_DQ,
                        addr     => RAddr,
                        ProtSecNum=>ProtSecNum,
                        secProt  => Sec_Prot(RSect),
                        FactoryProt=>FactoryProt ,
                        Byte     => T_BYTENeg,
                        AS_E     => to_slv(16#0C#,8),
                        AS_F     => to_slv(1,8),

                        check_err=>check_err);


                WHEN rd_HiZ   =>
                    toggle:=false;
                    Check_Z (
                        DQ       => T_DQ,
                        check_err=>check_err);



                WHEN readX   =>
                    toggle:=false;
                    Check_X (
                        DQ       => T_DQ,
                        check_err=>check_err);


                WHEN erase_na  | erase_active  =>
                    IF toggle THEN
                        Check_Erase (
                            DQ       => T_DQ(7 downto 0),
                            sts      => status,
                            toggle   => toggle_sts,
                            sts_check=>sts_check,
                            RY       => T_RY,
                            check_err=>check_err);

                        toggle_sts := T_DQ(7 downto 0); --update toggle check
                    END IF;

                WHEN ers_susp_e  =>
                    IF toggle THEN
                        Check_Ers_Susp (
                            DQ       => T_DQ(7 downto 0),
                            sts      => status,
                            toggle   => toggle_sts,
                            sts_check=>sts_check,
                            RY       => T_RY,
                            check_err=>check_err);


                        toggle_sts := T_DQ(7 downto 0); --update toggle check
                    END IF;

--

                WHEN ers_susp_prog_na  | ers_susp_prog  =>
                    IF toggle THEN
                        Check_Ers_Susp_Prog (
                            DQ       => T_DQ(7 downto 0),
                            sts      => status,
                            toggle   => toggle_sts,
                            sts_check=>sts_check,
                            RY       => T_RY,
                            check_err=>check_err);

                        toggle_sts := T_DQ(7 downto 0); --update toggle check
                    END IF;

--

                WHEN prog_na  | prog_active  =>
                    IF toggle THEN
                        Check_Progr (
                            DQ       => T_DQ(7 downto 0),
                            sts      => status,
                            toggle   => toggle_sts,
                            sts_check=>sts_check,
                            RY       => T_RY,
                            check_err=>check_err);

                        toggle_sts := T_DQ(7 downto 0); --update toggle check
                    END IF;

                WHEN buff_wr_busy  | buff_wr_N_busy  =>
                    IF toggle THEN
                        Check_Buff_Busy (
                            DQ       => T_DQ(7 downto 0),
                            sts      => status,
                            toggle   => toggle_sts,
                            sts_check=>sts_check,
                            RY       => T_RY,
                            check_err=>check_err);

                        toggle_sts := T_DQ(7 downto 0); --update toggle check
                    END IF;

                WHEN buff_abort =>
                    IF toggle THEN
                        Check_Abort (
                            DQ       => T_DQ(7 downto 0),
                            sts      => status,
                            toggle   => toggle_sts,
                            sts_check=>sts_check,
                            RY       => T_RY,
                            check_err=>check_err);

                        toggle_sts := T_DQ(7 downto 0); --update toggle check
                    END IF;
                WHEN OTHERS     =>  null;
            END CASE;

            -- get firs data for toggle check
            CASE status IS
                WHEN prog_active      | prog_na      |
                     erase_active     | erase_na     |
                     ers_susp_e       |
                     ers_susp_prog    | ers_susp_prog_na |
                     buff_wr_busy     | buff_wr_N_busy |
                     buff_abort       | get_toggle   =>

                     IF (NOT toggle) OR (status=get_toggle) THEN
                        toggle:=true;
                        toggle_sts := T_DQ(7 downto 0);
                     END IF;

                WHEN OTHERS => null;
            END CASE;


        END IF;

    END IF;

    WAIT ON T_A, T_CENeg, T_OENeg, T_WENeg, T_DQ(15), T_BYTENeg;

END PROCESS checker;


default:    PROCESS
        -- text file input variables
        FILE mem_f          : text  is  mem_file;
        FILE prot_f         : text  is  prot_file;
        FILE secsi_f        : text  is  secsi_file;

        VARIABLE S_ind         : NATURAL RANGE 0 TO SecNum:= 0;
        VARIABLE ind           : NATURAL RANGE 0 TO SecSize:= 0;
        VARIABLE buf           : line;

BEGIN
    --Preload Control
    -----------------------------------------------------------------------
    -- File Read Section
    -----------------------------------------------------------------------
    IF UserPreload THEN
            --- Sector protection preload
            IF (prot_file /= "none" ) THEN
                ind   := 0;
                FactoryProt := '0';
                Sec_Prot := (OTHERS => '0');
                WHILE (not ENDFILE (prot_f)) LOOP
                    READLINE (prot_f, buf);
                    IF buf(1) = '/' THEN
                        NEXT;
                    ELSIF buf(1) = '@' THEN
                        ind := h(buf(2 to 3)); --address
                    ELSE
                        IF ind > SecNum THEN
                            --SecSi Factory protect preload
                            IF buf(1)='1' THEN
                                FactoryProt := '1';
                            END IF;
                        ELSE
                            -- Standard Sector prload
                            IF buf(1)='1' THEN
                                Sec_Prot(ind):= '1';
                            END IF;
                            ind := ind + 1;
                        END IF;
                    END IF;
                END LOOP;
            END IF;

            -- Secure Silicon Sector Region preload
            IF (SecSi_file /= "none" ) THEN
                SecSi := (OTHERS => MaxData);
                ind := 0;
                WHILE (not ENDFILE (SecSi_f)) LOOP
                    READLINE (SecSi_f, buf);
                    IF buf(1) = '/' THEN
                        NEXT;
                    ELSIF buf(1) = '@' THEN
                        ind := h(buf(2 to 3)); --address
                    ELSE
                        IF ind <= SecSiSize THEN
                            SecSi(ind) := h(buf(1 TO 2));
                            ind := ind + 1;
                        END IF;
                    END IF;
                END LOOP;
            END IF;

            --- Memory Preload
            IF (mem_file /= "none" ) THEN
                ind   := 0;
                Mem := (OTHERS => (OTHERS => MaxData));
                -- load sector 0
                WHILE (not ENDFILE (mem_f)) LOOP
                    READLINE (mem_f, buf);
                    IF buf(1) = '/' THEN
                        NEXT;
                    ELSIF buf(1) = '@' THEN
                        ind := h(buf(2 to 5)); --address
                    ELSE
                        IF ind <= SecSize THEN
                            Mem(0)(ind) := h(buf(1 to 2));
                            ind := ind + 1;
                        END IF;
                    END IF;
                END LOOP;
                -- load other sectors
                FOR i IN 1 TO SecNum LOOP
                    Mem(i) := Mem(0);
                END LOOP;
            END IF;

    END IF;
    -----------------------------------------------------------------------
    --CFI array data / AM29LV640MH90R !!! DEVICE SPECIFIC
    -----------------------------------------------------------------------
    --CFI query identification string
    -- !!!!!! WORD ADDRESSES (x16) - for x8 addressing double addr
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
    CFI_array(16#1F#) := 16#07#;
    CFI_array(16#20#) := 16#07#;
    CFI_array(16#21#) := 16#0A#;
    CFI_array(16#22#) := 16#00#;
    CFI_array(16#23#) := 16#01#;
    CFI_array(16#24#) := 16#05#;
    CFI_array(16#25#) := 16#04#;
    CFI_array(16#26#) := 16#00#;
    --device geometry definition
    CFI_array(16#27#) := 16#17#;
    CFI_array(16#28#) := 16#02#;
    CFI_array(16#29#) := 16#00#;
    CFI_array(16#2A#) := 16#05#;
    CFI_array(16#2B#) := 16#00#;
    CFI_array(16#2C#) := 16#01#;
    CFI_array(16#2D#) := 16#7F#;
    CFI_array(16#2E#) := 16#00#;
    CFI_array(16#2F#) := 16#00#;
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
    CFI_array(16#44#) := 16#33#;
    CFI_array(16#45#) := 16#08#;
    CFI_array(16#46#) := 16#02#;
    CFI_array(16#47#) := 16#01#;
    CFI_array(16#48#) := 16#01#;
    CFI_array(16#49#) := 16#04#;
    CFI_array(16#4A#) := 16#00#;
    CFI_array(16#4B#) := 16#00#;
    CFI_array(16#4C#) := 16#01#;
    CFI_array(16#4D#) := 16#B5#;
    CFI_array(16#4E#) := 16#C5#;
    IF TimingModel(11) = 'L' THEN
        CFI_array(16#4F#) := 16#04#;
    ELSE
        CFI_array(16#4F#) := 16#05#; --uniform sectors top protect
    END IF;
    CFI_array(16#50#) := 16#01#;

    WAIT;

END PROCESS default;



END vhdl_behavioral;

